# Google Sign-In Fix for Android

## Problem
Google Sign-In works on Windows (not supported) but fails on Android devices/emulators with errors.

## Root Cause
Google Sign-In on Android requires SHA-1 certificate fingerprints to be registered in Firebase Console.

---

## ✅ Solution (5 minutes)

### Step 1: Get Your SHA-1 Certificate Fingerprint

Open Command Prompt and run:

```bash
cd "C:\Users\tiwar\Desktop\FINSTAR APP\android"
./gradlew signingReport
```

**Look for this section:**
```
Variant: debug
Config: debug
Store: C:\Users\tiwar\.android\debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
SHA-256: ...
```

**Copy the SHA1 value** (e.g., `AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD`)

---

### Step 2: Add SHA-1 to Firebase Console

1. Go to Firebase Console: https://console.firebase.google.com/project/finstar-prod/settings/general
2. Scroll down to "Your apps"
3. Click on your Android app (**com.finstar.app**)
4. Click **"Add fingerprint"**
5. Paste your SHA-1 value
6. Click **"Save"**

---

### Step 3: Download Updated google-services.json

1. Still in Firebase Console → Project Settings
2. Scroll to "Your apps" → Android app
3. Click **"Download google-services.json"**
4. Replace the old file:
   - Location: `C:\Users\tiwar\Desktop\FINSTAR APP\android\app\google-services.json`
   - Overwrite with the new download

---

### Step 4: Clean and Rebuild

```bash
cd "C:\Users\tiwar\Desktop\FINSTAR APP"
flutter clean
flutter pub get
flutter run
```

---

## Test Google Sign-In

1. Launch the app on Android (phone or emulator)
2. On login/signup screen, click **"Continue with Google"**
3. Should now show Google account picker
4. Select account and sign in
5. Should redirect to home screen

---

## ✅ Success Indicators

**Working:**
- Google account picker appears
- Can select account
- Redirects to home screen after selection
- User appears in Firebase Authentication console

**Still failing?** Check:
1. SHA-1 was added correctly (check Firebase Console)
2. Downloaded new google-services.json file
3. File is in correct location (`android/app/google-services.json`)
4. Ran `flutter clean` and `flutter pub get`
5. Internet connection is active

---

## Why This Happens

**Google Sign-In Security:**
- Google requires app signature verification
- SHA-1 fingerprint identifies your app
- Without it, Google rejects sign-in attempts
- This is a security feature to prevent impersonation

**Debug vs Release:**
- Debug builds use `debug.keystore` (SHA-1 from Step 1)
- Release builds need **release keystore SHA-1** (different!)
- For now, we're only fixing debug builds

---

## Alternative: Email/Password Authentication

If you don't need Google Sign-In right now, **Email/Password** works perfectly:

1. Use the Sign Up screen
2. Enter: Name, Email, Password
3. Click "Sign Up"
4. Works on all platforms (Windows, Android, iOS, Web)

---

## Next Steps (Optional - For Release)

When building release APK:

1. Generate release keystore:
   ```bash
   keytool -genkey -v -keystore finstar-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias finstar
   ```

2. Get release SHA-1:
   ```bash
   keytool -list -v -keystore finstar-release.jks -alias finstar
   ```

3. Add release SHA-1 to Firebase Console

4. Configure signing in `android/app/build.gradle`

---

## Quick Reference

**Firebase Console:** https://console.firebase.google.com/project/finstar-prod

**Get SHA-1:**
```bash
cd "C:\Users\tiwar\Desktop\FINSTAR APP\android"
./gradlew signingReport
```

**File Location:**
```
C:\Users\tiwar\Desktop\FINSTAR APP\android\app\google-services.json
```

**Test Command:**
```bash
flutter clean && flutter pub get && flutter run
```

---

**Questions?** Check Firebase Console logs or run `flutter doctor` to verify setup.
