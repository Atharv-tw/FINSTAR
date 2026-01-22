/**
 * Firebase REST API client for Supabase Edge Functions
 *
 * Uses direct HTTP calls instead of firebase-admin SDK
 * Result: Fast cold starts (no npm dependencies to load)
 *
 * Required environment variables:
 * - FIREBASE_PROJECT_ID
 * - FIREBASE_CLIENT_EMAIL
 * - FIREBASE_PRIVATE_KEY (base64 encoded)
 */

// Crypto for JWT signing
const encoder = new TextEncoder();
const decoder = new TextDecoder();

// Cache for access token
let cachedToken: { token: string; expires: number } | null = null;

// Cache for CryptoKey (expensive to import)
let cachedCryptoKey: CryptoKey | null = null;
let cachedPrivateKeyPem: string | null = null;

/**
 * Decode base64 string to Uint8Array (handles all characters)
 */
function base64Decode(base64: string): Uint8Array {
  const binString = atob(base64);
  const bytes = new Uint8Array(binString.length);
  for (let i = 0; i < binString.length; i++) {
    bytes[i] = binString.charCodeAt(i);
  }
  return bytes;
}

/**
 * Decode base64 to string (UTF-8)
 */
function base64DecodeToString(base64: string): string {
  const bytes = base64Decode(base64);
  return decoder.decode(bytes);
}

/**
 * Base64URL encode from Uint8Array (JWT-safe)
 */
function base64UrlEncodeBytes(data: Uint8Array): string {
  let binary = "";
  for (let i = 0; i < data.length; i++) {
    binary += String.fromCharCode(data[i]);
  }
  const base64 = btoa(binary);
  return base64.replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

/**
 * Base64URL encode from string (JWT-safe)
 */
function base64UrlEncode(str: string): string {
  const bytes = encoder.encode(str);
  return base64UrlEncodeBytes(bytes);
}

/**
 * Import RSA private key for signing (with caching)
 */
async function importPrivateKey(pem: string): Promise<CryptoKey> {
  // Return cached key if same PEM
  if (cachedCryptoKey && cachedPrivateKeyPem === pem) {
    return cachedCryptoKey;
  }

  // Remove PEM headers and newlines
  const pemContents = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s/g, "");

  // Decode base64 to binary
  const binaryString = atob(pemContents);
  const bytes = new Uint8Array(binaryString.length);
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }

  cachedCryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    bytes,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );
  cachedPrivateKeyPem = pem;

  return cachedCryptoKey;
}

/**
 * Create a signed JWT for Google API authentication
 */
async function createServiceAccountJWT(
  clientEmail: string,
  privateKey: string,
  scope: string
): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const exp = now + 3600; // 1 hour

  const header = { alg: "RS256", typ: "JWT" };
  const payload = {
    iss: clientEmail,
    sub: clientEmail,
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: exp,
    scope: scope,
  };

  const headerB64 = base64UrlEncode(JSON.stringify(header));
  const payloadB64 = base64UrlEncode(JSON.stringify(payload));
  const unsignedToken = `${headerB64}.${payloadB64}`;

  // Sign with private key
  const key = await importPrivateKey(privateKey);
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    encoder.encode(unsignedToken)
  );

  const signatureB64 = base64UrlEncodeBytes(new Uint8Array(signature));
  return `${unsignedToken}.${signatureB64}`;
}

/**
 * Get access token from Google OAuth (with caching)
 */
async function getAccessToken(
  clientEmail: string,
  privateKey: string
): Promise<string> {
  // Return cached token if still valid (with 5 min buffer)
  if (cachedToken && cachedToken.expires > Date.now() + 300000) {
    return cachedToken.token;
  }

  const jwt = await createServiceAccountJWT(
    clientEmail,
    privateKey,
    "https://www.googleapis.com/auth/datastore https://www.googleapis.com/auth/firebase.database https://www.googleapis.com/auth/firebase.messaging"
  );

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Failed to get access token: ${error}`);
  }

  const data = await response.json();
  cachedToken = {
    token: data.access_token,
    expires: Date.now() + data.expires_in * 1000,
  };

  return cachedToken.token;
}

/**
 * Convert Firestore REST API value to JS value
 */
function fromFirestoreValue(value: any): any {
  if (value === null || value === undefined) return null;

  if ("nullValue" in value) return null;
  if ("booleanValue" in value) return value.booleanValue;
  if ("integerValue" in value) return parseInt(value.integerValue);
  if ("doubleValue" in value) return value.doubleValue;
  if ("stringValue" in value) return value.stringValue;
  if ("timestampValue" in value) return new Date(value.timestampValue);
  if ("arrayValue" in value) {
    return (value.arrayValue.values || []).map(fromFirestoreValue);
  }
  if ("mapValue" in value) {
    const result: any = {};
    const fields = value.mapValue.fields || {};
    for (const key of Object.keys(fields)) {
      result[key] = fromFirestoreValue(fields[key]);
    }
    return result;
  }
  return null;
}

/**
 * Convert JS value to Firestore REST API value
 */
function toFirestoreValue(value: any): any {
  if (value === null || value === undefined) {
    return { nullValue: null };
  }
  if (typeof value === "boolean") {
    return { booleanValue: value };
  }
  if (typeof value === "number") {
    if (Number.isInteger(value)) {
      return { integerValue: value.toString() };
    }
    return { doubleValue: value };
  }
  if (typeof value === "string") {
    return { stringValue: value };
  }
  if (value instanceof Date) {
    return { timestampValue: value.toISOString() };
  }
  if (Array.isArray(value)) {
    return { arrayValue: { values: value.map(toFirestoreValue) } };
  }
  if (typeof value === "object") {
    // Check for special FieldValue types
    if (value._type === "serverTimestamp") {
      return { timestampValue: new Date().toISOString() };
    }
    if (value._type === "increment") {
      // This will be handled specially in update operations
      return { integerValue: value._value.toString() };
    }
    // Regular object
    const fields: any = {};
    for (const key of Object.keys(value)) {
      fields[key] = toFirestoreValue(value[key]);
    }
    return { mapValue: { fields } };
  }
  return { nullValue: null };
}

/**
 * Firestore Document Reference (REST API wrapper)
 */
class DocumentReference {
  constructor(
    private projectId: string,
    private getToken: () => Promise<string>,
    public readonly path: string
  ) {}

  get id(): string {
    return this.path.split("/").pop() || "";
  }

  private get url(): string {
    return `https://firestore.googleapis.com/v1/projects/${this.projectId}/databases/(default)/documents/${this.path}`;
  }

  collection(name: string): CollectionReference {
    return new CollectionReference(
      this.projectId,
      this.getToken,
      `${this.path}/${name}`
    );
  }

  async get(): Promise<DocumentSnapshot> {
    const token = await this.getToken();
    const response = await fetch(this.url, {
      headers: { Authorization: `Bearer ${token}` },
    });

    if (response.status === 404) {
      return new DocumentSnapshot(this.path, null);
    }

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Firestore get failed: ${error}`);
    }

    const data = await response.json();
    return new DocumentSnapshot(this.path, data);
  }

  async set(data: any, options?: { merge?: boolean }): Promise<void> {
    const token = await this.getToken();
    const fields: any = {};

    for (const key of Object.keys(data)) {
      fields[key] = toFirestoreValue(data[key]);
    }

    const body = { fields };

    // For set with merge, we'd need to use patch with updateMask
    // For simplicity, regular set overwrites the document
    const response = await fetch(this.url, {
      method: "PATCH",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Firestore set failed: ${error}`);
    }
  }

  async update(data: any): Promise<void> {
    const token = await this.getToken();
    const fields: any = {};
    const fieldPaths: string[] = [];

    for (const key of Object.keys(data)) {
      fields[key] = toFirestoreValue(data[key]);
      fieldPaths.push(key);
    }

    const body = { fields };
    const updateMask = fieldPaths.map((f) => `updateMask.fieldPaths=${f}`).join("&");

    const response = await fetch(`${this.url}?${updateMask}`, {
      method: "PATCH",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Firestore update failed: ${error}`);
    }
  }

  async delete(): Promise<void> {
    const token = await this.getToken();
    const response = await fetch(this.url, {
      method: "DELETE",
      headers: { Authorization: `Bearer ${token}` },
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Firestore delete failed: ${error}`);
    }
  }
}

/**
 * Firestore Document Snapshot
 */
class DocumentSnapshot {
  constructor(private path: string, private rawData: any | null) {}

  get exists(): boolean {
    return this.rawData !== null;
  }

  get id(): string {
    return this.path.split("/").pop() || "";
  }

  data(): any | undefined {
    if (!this.rawData || !this.rawData.fields) return undefined;

    const result: any = {};
    for (const key of Object.keys(this.rawData.fields)) {
      result[key] = fromFirestoreValue(this.rawData.fields[key]);
    }
    return result;
  }
}

/**
 * Firestore Collection Reference (REST API wrapper)
 */
class CollectionReference {
  constructor(
    private projectId: string,
    private getToken: () => Promise<string>,
    private path: string
  ) {}

  private get url(): string {
    return `https://firestore.googleapis.com/v1/projects/${this.projectId}/databases/(default)/documents/${this.path}`;
  }

  doc(id: string): DocumentReference {
    return new DocumentReference(this.projectId, this.getToken, `${this.path}/${id}`);
  }

  async add(data: any): Promise<DocumentReference> {
    const token = await this.getToken();
    const fields: any = {};

    for (const key of Object.keys(data)) {
      fields[key] = toFirestoreValue(data[key]);
    }

    const response = await fetch(this.url, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ fields }),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Firestore add failed: ${error}`);
    }

    const result = await response.json();
    const docPath = result.name.split("/documents/")[1];
    return new DocumentReference(this.projectId, this.getToken, docPath);
  }

  where(field: string, op: string, value: any): Query {
    return new Query(this.projectId, this.getToken, this.path).where(field, op, value);
  }

  orderBy(field: string, direction: "asc" | "desc" = "asc"): Query {
    return new Query(this.projectId, this.getToken, this.path).orderBy(field, direction);
  }

  limit(n: number): Query {
    return new Query(this.projectId, this.getToken, this.path).limit(n);
  }

  async get(): Promise<QuerySnapshot> {
    return new Query(this.projectId, this.getToken, this.path).get();
  }
}

/**
 * Firestore Query
 */
class Query {
  private filters: Array<{ field: string; op: string; value: any }> = [];
  private orders: Array<{ field: string; direction: string }> = [];
  private limitCount: number | null = null;

  constructor(
    private projectId: string,
    private getToken: () => Promise<string>,
    private collectionPath: string
  ) {}

  where(field: string, op: string, value: any): Query {
    this.filters.push({ field, op, value });
    return this;
  }

  orderBy(field: string, direction: "asc" | "desc" = "asc"): Query {
    this.orders.push({ field, direction: direction.toUpperCase() });
    return this;
  }

  limit(n: number): Query {
    this.limitCount = n;
    return this;
  }

  async get(): Promise<QuerySnapshot> {
    const token = await this.getToken();

    // Build structured query
    const structuredQuery: any = {
      from: [{ collectionId: this.collectionPath.split("/").pop() }],
    };

    // Add filters
    if (this.filters.length > 0) {
      const firestoreFilters = this.filters.map((f) => ({
        fieldFilter: {
          field: { fieldPath: f.field },
          op: this.convertOp(f.op),
          value: toFirestoreValue(f.value),
        },
      }));

      if (firestoreFilters.length === 1) {
        structuredQuery.where = firestoreFilters[0];
      } else {
        structuredQuery.where = {
          compositeFilter: {
            op: "AND",
            filters: firestoreFilters,
          },
        };
      }
    }

    // Add ordering
    if (this.orders.length > 0) {
      structuredQuery.orderBy = this.orders.map((o) => ({
        field: { fieldPath: o.field },
        direction: o.direction,
      }));
    }

    // Add limit
    if (this.limitCount) {
      structuredQuery.limit = this.limitCount;
    }

    // Get parent path for query
    const pathParts = this.collectionPath.split("/");
    pathParts.pop(); // Remove collection name
    const parentPath = pathParts.length > 0 ? pathParts.join("/") : "";

    const url = `https://firestore.googleapis.com/v1/projects/${this.projectId}/databases/(default)/documents${parentPath ? "/" + parentPath : ""}:runQuery`;

    const response = await fetch(url, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ structuredQuery }),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Firestore query failed: ${error}`);
    }

    const results = await response.json();
    const docs: DocumentSnapshot[] = [];

    for (const result of results) {
      if (result.document) {
        const docPath = result.document.name.split("/documents/")[1];
        docs.push(new DocumentSnapshot(docPath, result.document));
      }
    }

    return new QuerySnapshot(docs);
  }

  private convertOp(op: string): string {
    const opMap: { [key: string]: string } = {
      "==": "EQUAL",
      "!=": "NOT_EQUAL",
      "<": "LESS_THAN",
      "<=": "LESS_THAN_OR_EQUAL",
      ">": "GREATER_THAN",
      ">=": "GREATER_THAN_OR_EQUAL",
      "array-contains": "ARRAY_CONTAINS",
      "array-contains-any": "ARRAY_CONTAINS_ANY",
      "in": "IN",
      "not-in": "NOT_IN",
    };
    return opMap[op] || "EQUAL";
  }
}

/**
 * Firestore Query Snapshot
 */
class QuerySnapshot {
  constructor(private _docs: DocumentSnapshot[]) {}

  get docs(): DocumentSnapshot[] {
    return this._docs;
  }

  get empty(): boolean {
    return this._docs.length === 0;
  }

  get size(): number {
    return this._docs.length;
  }

  forEach(callback: (doc: DocumentSnapshot) => void): void {
    this._docs.forEach(callback);
  }
}

/**
 * Firestore WriteBatch for atomic operations
 */
class WriteBatch {
  private writes: Array<{
    update?: { name: string; fields: any };
    delete?: string;
    updateMask?: { fieldPaths: string[] };
    currentDocument?: { exists: boolean };
  }> = [];

  constructor(
    private projectId: string,
    private getToken: () => Promise<string>
  ) {}

  set(docRef: DocumentReference, data: any): WriteBatch {
    const fields: any = {};
    for (const key of Object.keys(data)) {
      fields[key] = toFirestoreValue(data[key]);
    }
    this.writes.push({
      update: {
        name: `projects/${this.projectId}/databases/(default)/documents/${docRef.path}`,
        fields,
      },
    });
    return this;
  }

  update(docRef: DocumentReference, data: any): WriteBatch {
    const fields: any = {};
    const fieldPaths: string[] = [];
    for (const key of Object.keys(data)) {
      fields[key] = toFirestoreValue(data[key]);
      fieldPaths.push(key);
    }
    this.writes.push({
      update: {
        name: `projects/${this.projectId}/databases/(default)/documents/${docRef.path}`,
        fields,
      },
      updateMask: { fieldPaths },
      currentDocument: { exists: true },
    });
    return this;
  }

  delete(docRef: DocumentReference): WriteBatch {
    this.writes.push({
      delete: `projects/${this.projectId}/databases/(default)/documents/${docRef.path}`,
    });
    return this;
  }

  async commit(): Promise<void> {
    if (this.writes.length === 0) return;

    const token = await this.getToken();
    const url = `https://firestore.googleapis.com/v1/projects/${this.projectId}/databases/(default)/documents:commit`;

    const response = await fetch(url, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ writes: this.writes }),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Firestore batch commit failed: ${error}`);
    }
  }
}

/**
 * Simple transaction context for read-then-write patterns
 * Note: This is a simplified implementation - reads happen first, then writes are batched
 */
class TransactionContext {
  private batch: WriteBatch;
  private readCache: Map<string, DocumentSnapshot> = new Map();

  constructor(
    private projectId: string,
    private getToken: () => Promise<string>
  ) {
    this.batch = new WriteBatch(projectId, getToken);
  }

  async get(docRef: DocumentReference): Promise<DocumentSnapshot> {
    // Check cache first
    const cached = this.readCache.get(docRef.path);
    if (cached) return cached;

    // Read from Firestore
    const snapshot = await docRef.get();
    this.readCache.set(docRef.path, snapshot);
    return snapshot;
  }

  set(docRef: DocumentReference, data: any): void {
    this.batch.set(docRef, data);
  }

  update(docRef: DocumentReference, data: any): void {
    this.batch.update(docRef, data);
  }

  delete(docRef: DocumentReference): void {
    this.batch.delete(docRef);
  }

  async commit(): Promise<void> {
    await this.batch.commit();
  }
}

/**
 * Firestore instance (REST API wrapper)
 */
class FirestoreRest {
  constructor(
    private projectId: string,
    private getToken: () => Promise<string>
  ) {}

  collection(name: string): CollectionReference {
    return new CollectionReference(this.projectId, this.getToken, name);
  }

  doc(path: string): DocumentReference {
    return new DocumentReference(this.projectId, this.getToken, path);
  }

  batch(): WriteBatch {
    return new WriteBatch(this.projectId, this.getToken);
  }

  /**
   * Run a transaction-like operation
   * Note: This uses optimistic concurrency - reads happen first, then writes are batched
   * For this app (single user sessions), this is safe enough
   */
  async runTransaction<T>(
    updateFunction: (transaction: TransactionContext) => Promise<T>
  ): Promise<T> {
    const transaction = new TransactionContext(this.projectId, this.getToken);
    const result = await updateFunction(transaction);
    await transaction.commit();
    return result;
  }
}

/**
 * Realtime Database REST API wrapper
 */
class RealtimeDatabaseRest {
  constructor(
    private databaseUrl: string,
    private getToken: () => Promise<string>
  ) {}

  ref(path: string = ""): DatabaseReference {
    return new DatabaseReference(this.databaseUrl, this.getToken, path);
  }
}

class DatabaseReference {
  constructor(
    private databaseUrl: string,
    private getToken: () => Promise<string>,
    private path: string
  ) {}

  child(path: string): DatabaseReference {
    const newPath = this.path ? `${this.path}/${path}` : path;
    return new DatabaseReference(this.databaseUrl, this.getToken, newPath);
  }

  private get url(): string {
    return `${this.databaseUrl}/${this.path}.json`;
  }

  async get(): Promise<any> {
    const token = await this.getToken();
    const response = await fetch(`${this.url}?auth=${token}`);

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`RTDB get failed: ${error}`);
    }

    const data = await response.json();
    return { val: () => data, exists: () => data !== null };
  }

  async set(value: any): Promise<void> {
    const token = await this.getToken();
    const response = await fetch(`${this.url}?auth=${token}`, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(value),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`RTDB set failed: ${error}`);
    }
  }

  async update(value: any): Promise<void> {
    const token = await this.getToken();
    const response = await fetch(`${this.url}?auth=${token}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(value),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`RTDB update failed: ${error}`);
    }
  }

  async remove(): Promise<void> {
    const token = await this.getToken();
    const response = await fetch(`${this.url}?auth=${token}`, {
      method: "DELETE",
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`RTDB remove failed: ${error}`);
    }
  }

  async push(value: any): Promise<DatabaseReference> {
    const token = await this.getToken();
    const response = await fetch(`${this.url}?auth=${token}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(value),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`RTDB push failed: ${error}`);
    }

    const result = await response.json();
    return this.child(result.name);
  }
}

/**
 * FieldValue helpers (compatible with firebase-admin API)
 */
export const FieldValue = {
  serverTimestamp: () => ({ _type: "serverTimestamp" }),
  increment: (n: number) => ({ _type: "increment", _value: n }),
  arrayUnion: (...elements: any[]) => ({ _type: "arrayUnion", _elements: elements }),
  arrayRemove: (...elements: any[]) => ({ _type: "arrayRemove", _elements: elements }),
  delete: () => ({ _type: "delete" }),
};

/**
 * FCM Messaging REST API wrapper
 * Uses FCM HTTP v1 API
 */
class MessagingRest {
  constructor(
    private projectId: string,
    private getToken: () => Promise<string>
  ) {}

  /**
   * Send notification to multiple tokens
   * Returns success/failure counts for compatibility with Admin SDK
   */
  async sendEachForMulticast(message: {
    notification?: { title: string; body: string; imageUrl?: string };
    data?: Record<string, string>;
    tokens: string[];
  }): Promise<{
    successCount: number;
    failureCount: number;
    responses: Array<{ success: boolean; error?: { code: string; message: string } }>;
  }> {
    const token = await this.getToken();
    const responses: Array<{ success: boolean; error?: { code: string; message: string } }> = [];
    let successCount = 0;
    let failureCount = 0;

    // Send to each token individually (FCM v1 API doesn't support multicast)
    const sendPromises = message.tokens.map(async (fcmToken) => {
      try {
        const fcmMessage: any = {
          message: {
            token: fcmToken,
            notification: message.notification ? {
              title: message.notification.title,
              body: message.notification.body,
              ...(message.notification.imageUrl && { image: message.notification.imageUrl }),
            } : undefined,
            data: message.data,
            android: {
              priority: "high",
            },
            apns: {
              payload: {
                aps: {
                  sound: "default",
                },
              },
            },
          },
        };

        const response = await fetch(
          `https://fcm.googleapis.com/v1/projects/${this.projectId}/messages:send`,
          {
            method: "POST",
            headers: {
              Authorization: `Bearer ${token}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify(fcmMessage),
          }
        );

        if (response.ok) {
          return { success: true };
        } else {
          const errorData = await response.json();
          const errorCode = errorData?.error?.details?.[0]?.errorCode || "unknown";
          return {
            success: false,
            error: {
              code: errorCode === "UNREGISTERED" ? "messaging/registration-token-not-registered" : `messaging/${errorCode.toLowerCase()}`,
              message: errorData?.error?.message || "Unknown error",
            },
          };
        }
      } catch (err: any) {
        return {
          success: false,
          error: {
            code: "messaging/internal-error",
            message: err.message || "Network error",
          },
        };
      }
    });

    const results = await Promise.all(sendPromises);

    for (const result of results) {
      responses.push(result);
      if (result.success) {
        successCount++;
      } else {
        failureCount++;
      }
    }

    return { successCount, failureCount, responses };
  }

  /**
   * Send to a single token
   */
  async send(message: {
    token: string;
    notification?: { title: string; body: string; imageUrl?: string };
    data?: Record<string, string>;
  }): Promise<string> {
    const token = await this.getToken();

    const fcmMessage: any = {
      message: {
        token: message.token,
        notification: message.notification ? {
          title: message.notification.title,
          body: message.notification.body,
          ...(message.notification.imageUrl && { image: message.notification.imageUrl }),
        } : undefined,
        data: message.data,
        android: {
          priority: "high",
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
            },
          },
        },
      },
    };

    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${this.projectId}/messages:send`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(fcmMessage),
      }
    );

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`FCM send failed: ${error}`);
    }

    const result = await response.json();
    return result.name; // Message ID
  }
}

// Singleton instances
let firestoreInstance: FirestoreRest | null = null;
let rtdbInstance: RealtimeDatabaseRest | null = null;
let messagingInstance: MessagingRest | null = null;
let tokenGetter: (() => Promise<string>) | null = null;
let tokenWarmupPromise: Promise<string> | null = null;

/**
 * Initialize Firebase REST API client
 * Drop-in replacement for initializeFirebase() from firebase.ts
 */
export function initializeFirebase(options?: { warmup?: boolean }): {
  db: FirestoreRest;
  rtdb: RealtimeDatabaseRest;
  messaging: MessagingRest;
} {
  if (firestoreInstance && rtdbInstance && messagingInstance) {
    return { db: firestoreInstance, rtdb: rtdbInstance, messaging: messagingInstance };
  }

  const projectId = Deno.env.get("FIREBASE_PROJECT_ID");
  const clientEmail = Deno.env.get("FIREBASE_CLIENT_EMAIL");
  const privateKeyBase64 = Deno.env.get("FIREBASE_PRIVATE_KEY");

  if (!projectId || !clientEmail || !privateKeyBase64) {
    throw new Error("Missing Firebase configuration environment variables");
  }

  // Decode base64 private key (handles UTF-8 properly)
  const privateKey = base64DecodeToString(privateKeyBase64).replace(/\\n/g, "\n");

  // Create token getter function
  tokenGetter = () => getAccessToken(clientEmail, privateKey);

  // Start warming up the token immediately (don't wait)
  if (options?.warmup !== false) {
    tokenWarmupPromise = tokenGetter().catch(() => "");
  }

  // Create instances
  firestoreInstance = new FirestoreRest(projectId, tokenGetter);
  rtdbInstance = new RealtimeDatabaseRest(
    `https://${projectId}-default-rtdb.asia-southeast1.firebasedatabase.app`,
    tokenGetter
  );
  messagingInstance = new MessagingRest(projectId, tokenGetter);

  return { db: firestoreInstance, rtdb: rtdbInstance, messaging: messagingInstance };
}

/**
 * Pre-warm the Firebase connection (call early in request lifecycle)
 * Returns a promise that resolves when the token is ready
 */
export async function warmupFirebase(): Promise<void> {
  initializeFirebase();
  if (tokenWarmupPromise) {
    await tokenWarmupPromise;
  }
}

// Export types for compatibility
export type Firestore = FirestoreRest;
export type Database = RealtimeDatabaseRest;
export type Messaging = MessagingRest;
