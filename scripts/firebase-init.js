import admin from 'firebase-admin';

// Initialize Firebase Admin SDK from GitHub Actions secret
const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://finstar-prod-default-rtdb.asia-southeast1.firebasedatabase.app',
});

export const db = admin.firestore();
export const rtdb = admin.database();
export default admin;
