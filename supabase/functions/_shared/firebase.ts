/**
 * Firebase Admin SDK initialization for Supabase Edge Functions
 *
 * Required environment variables:
 * - FIREBASE_PROJECT_ID
 * - FIREBASE_CLIENT_EMAIL
 * - FIREBASE_PRIVATE_KEY (base64 encoded)
 */

import { initializeApp, cert, getApps, App } from "npm:firebase-admin/app";
import { getFirestore, Firestore, FieldValue } from "npm:firebase-admin/firestore";
import { getDatabase, Database } from "npm:firebase-admin/database";
import { getAuth, Auth } from "npm:firebase-admin/auth";
import { getMessaging, Messaging } from "npm:firebase-admin/messaging";

let app: App | null = null;
let db: Firestore | null = null;
let rtdb: Database | null = null;
let auth: Auth | null = null;
let messaging: Messaging | null = null;

export function initializeFirebase(): { db: Firestore; rtdb: Database; auth: Auth; messaging: Messaging } {
  if (app && db && rtdb && auth && messaging) {
    return { db, rtdb, auth, messaging };
  }

  const projectId = Deno.env.get("FIREBASE_PROJECT_ID");
  const clientEmail = Deno.env.get("FIREBASE_CLIENT_EMAIL");
  const privateKeyBase64 = Deno.env.get("FIREBASE_PRIVATE_KEY");

  if (!projectId || !clientEmail || !privateKeyBase64) {
    throw new Error("Missing Firebase configuration environment variables");
  }

  // Decode base64 private key
  const privateKey = atob(privateKeyBase64).replace(/\\n/g, "\n");

  if (getApps().length === 0) {
    app = initializeApp({
      credential: cert({
        projectId,
        clientEmail,
        privateKey,
      }),
      databaseURL: `https://${projectId}-default-rtdb.asia-southeast1.firebasedatabase.app`,
    });
  } else {
    app = getApps()[0];
  }

  db = getFirestore(app);
  rtdb = getDatabase(app);
  auth = getAuth(app);
  messaging = getMessaging(app);

  return { db, rtdb, auth, messaging };
}

export { FieldValue };
export type { Firestore, Database, Auth, Messaging };
