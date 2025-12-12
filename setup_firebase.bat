@echo off
echo ========================================
echo Firebase Setup for FINSTAR APP
echo ========================================
echo.

echo Step 1: Login to Firebase
echo Run this command manually in your terminal:
echo firebase login
echo.
pause

echo.
echo Step 2: Initialize Firebase
firebase init

echo.
echo Step 3: Configure FlutterFire
dart pub global run flutterfire_cli:flutterfire configure

echo.
echo Step 4: Install function dependencies
cd functions
npm install
cd ..

echo.
echo Step 5: Get Flutter dependencies
flutter pub get

echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Deploy backend: firebase deploy
echo 2. Run app: flutter run
echo.
pause
