# 🔥 Firebase OTP Authentication - Complete Setup Guide

## 📋 Table of Contents
1. [Overview](#overview)
2. [What Was Implemented](#what-was-implemented)
3. [Quick Setup (5 Minutes)](#quick-setup-5-minutes)
4. [Testing Instructions](#testing-instructions)
5. [Backend Requirements](#backend-requirements)
6. [Code Changes Reference](#code-changes-reference)
7. [Troubleshooting](#troubleshooting)

---

## Overview

This app now uses Firebase Authentication for phone number verification with OTP. After successful verification, the user's name, phone number, and Firebase token are sent to your backend server for authentication.

**Project Details:**
- **Firebase Project:** topgrade-86000
- **Package Name:** com.topgrade.app
- **Platform:** Android (configured)
- **Build Status:** ✅ Successful (86MB APK)

---

## What Was Implemented

### ✅ Features Added

1. **"Full name" field** added above phone number in mobile sign-in
2. **Firebase OTP sending** via SMS
3. **6-digit OTP verification** with Firebase
4. **Firebase token generation** after successful verification
5. **Backend integration** - sends name, phone, and Firebase token to your server
6. **Resend OTP** functionality
7. **Change number** option
8. **Loading states** during API calls
9. **Error handling** with user-friendly messages
10. **Success notifications**

### 📱 User Flow

```
1. User enters full name + phone number
   ↓
2. User clicks "SEND OTP"
   ↓
3. Firebase sends SMS with 6-digit code
   ↓
4. User enters OTP
   ↓
5. User clicks "VERIFY & SIGN IN"
   ↓
6. Firebase verifies OTP and generates token
   ↓
7. App sends to backend:
   {
     "name": "User Name",
     "phoneNumber": "+911234567890",
     "firebaseToken": "eyJhbGc..."
   }
   ↓
8. Backend verifies Firebase token and returns access/refresh tokens
   ↓
9. User logged in successfully
```

### 📦 Files Modified

**New Files:**
- `lib/firebase_options.dart` - Firebase configuration
- `lib/features/data/model/phone_otp_response_model.dart`
- `lib/features/data/model/phone_signin_response_model.dart`

**Modified Files:**
- `pubspec.yaml` - Added Firebase dependencies
- `lib/main.dart` - Firebase initialization
- `lib/features/presentation/controllers/auth_controller.dart` - OTP logic
- `lib/features/data/source/remote_source.dart` - Backend API methods
- `lib/features/presentation/views/auth/signin_mobile_screen.dart` - UI updates
- `android/build.gradle.kts` - Google services plugin
- `android/app/build.gradle.kts` - Firebase plugin & minSdk

**Configuration Files:**
- `android/app/google-services.json` - Firebase Android config ✅

---

## Quick Setup (5 Minutes)

### ✅ Already Completed
- [x] Code implementation
- [x] Firebase dependencies installed
- [x] google-services.json added
- [x] firebase_options.dart configured
- [x] Android Gradle files configured
- [x] App builds successfully

### ⚠️ Step 1: Add SHA Certificates to Firebase (REQUIRED)

Firebase Phone Auth requires SHA certificates for security.

**Your SHA Certificates:**

**SHA-1:**
```
26:EF:26:DD:0E:44:B2:5B:DC:F6:9A:DD:27:3A:73:D4:C6:EA:1F:A0
```

**SHA-256:**
```
77:57:0E:FF:E5:92:9A:FB:21:3B:EE:44:D3:DB:10:48:BB:DC:23:B0:B1:08:9D:CE:94:30:25:3B:94:F4:E0:67
```

**How to Add:**
1. Go to: https://console.firebase.google.com/project/topgrade-86000/settings/general
2. Scroll down to **"Your apps"** section
3. Find your Android app: **com.topgrade.app**
4. Click **"Add fingerprint"**
5. Paste the **SHA-1** certificate → Click **"Save"**
6. Click **"Add fingerprint"** again
7. Paste the **SHA-256** certificate → Click **"Save"**

> **Note:** These are DEBUG certificates. For production, you'll need to add RELEASE certificates from your release keystore.

### ⚠️ Step 2: Enable Phone Authentication (REQUIRED)

1. Go to: https://console.firebase.google.com/project/topgrade-86000/authentication/providers
2. Click **"Get Started"** (if first time using Authentication)
3. Click on the **"Sign-in method"** tab
4. Find **"Phone"** in the provider list
5. Click on it to expand
6. Toggle the **"Enable"** switch
7. Click **"Save"**

### 🧪 Step 3: Add Test Phone Numbers (Optional - Recommended for Development)

To test without using real SMS (saves costs and quota):

1. In Firebase Console → Authentication → Sign-in method
2. Scroll down to **"Phone numbers for testing"**
3. Click the pencil icon to expand
4. Click **"Add phone number"**
5. Enter:
   - **Phone number:** `+911234567890`
   - **Verification code:** `123456`
6. Click **"Add"**
7. Click **"Save"**

Now you can test with this number without receiving real SMS!

### 🚀 Step 4: Run the App

```bash
# Connect Android device/emulator
flutter devices

# Run the app
flutter run
```

---

## Testing Instructions

### Prerequisites
- ✅ SHA certificates added to Firebase
- ✅ Phone authentication enabled in Firebase
- ✅ Android device/emulator connected
- ✅ Internet connection

### Test with Test Phone Number (Recommended)

1. Launch the app
2. Navigate to: **Sign In** → **"Sign In with Mobile"**
3. Fill in:
   - **Full name:** Test User
   - **Phone:** `1234567890` (without +91)
4. Click **"SEND OTP"**
5. Wait for confirmation message
6. Enter OTP: `123456` (the test code you configured)
7. Click **"VERIFY & SIGN IN"**

**Expected Result:**
- OTP verification succeeds
- App sends request to backend
- User is logged in (or shows backend error if not implemented yet)

### Test with Real Phone Number

1. Follow steps 1-4 above with a real phone number
2. Check SMS for 6-digit OTP code
3. Enter the code from SMS
4. Click **"VERIFY & SIGN IN"**

### Features to Test

- ✅ Name field validation (required)
- ✅ Phone validation (must be 10 digits)
- ✅ Send OTP button (shows loading state)
- ✅ OTP field appears after sending
- ✅ Resend OTP button works
- ✅ Change Number button clears all fields
- ✅ Verify button (shows loading state)
- ✅ Error messages display correctly
- ✅ Success messages display correctly

---

## Backend Requirements

Your backend must implement the following endpoint to complete the authentication flow:

### Endpoint

**POST** `https://topgradeinnovation.com/api/auth/phone-signin`

### Request Headers
```
Content-Type: application/json
```
### Request Body
```json
{
  "name": "User Full Name",
  "phoneNumber": "+911234567890",
  "firebaseToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjFlMDNkN..."
}
```

### Backend Implementation Steps

1. **Verify Firebase Token** (Required)
   ```javascript
   // Example using Firebase Admin SDK (Node.js)
   const admin = require('firebase-admin');
   
   try {
     const decodedToken = await admin.auth().verifyIdToken(firebaseToken);
     const phoneFromToken = decodedToken.phone_number;
     
     // Verify phone matches request
     if (phoneFromToken !== phoneNumber) {
       return res.status(401).json({ error: 'Phone number mismatch' });
     }
   } catch (error) {
     return res.status(401).json({ error: 'Invalid Firebase token' });
   }
   ```

2. **Create or Update User**
   - Check if user exists with this phone number
   - If new: Create user with name and phone
   - If existing: Update last login time

3. **Generate Your Tokens**
   - Create JWT access token
   - Create JWT refresh token
   - Set appropriate expiration times

4. **Return Response**

### Expected Response

```json
{
  "success": true,
  "message": "Login successful",
  "accessToken": "your-backend-access-token",
  "refreshToken": "your-backend-refresh-token",
  "hasAreaOfIntrest": false,
  "user": {
    "id": 1,
    "fullname": "User Full Name",
    "email": null,
    "phoneNumber": "+911234567890"
  }
}
```

### Error Response

```json
{
  "success": false,
  "message": "Invalid Firebase token"
}
```

### Backend Setup Resources

**Node.js:**
- Install: `npm install firebase-admin`
- Docs: https://firebase.google.com/docs/auth/admin/verify-id-tokens

**Python:**
- Install: `pip install firebase-admin`
- Docs: https://firebase.google.com/docs/auth/admin/verify-id-tokens

**Java:**
- Docs: https://firebase.google.com/docs/auth/admin/verify-id-tokens

---

## Code Changes Reference

### Dependencies Added (pubspec.yaml)

```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
```

### Firebase Initialization (lib/main.dart)

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // ... rest of code
}
```

### Auth Controller Methods (lib/features/presentation/controllers/auth_controller.dart)

**Send OTP:**
```dart
Future<void> sendOtp() async {
  // Validates name and phone
  // Calls Firebase verifyPhoneNumber()
  // Handles success/error callbacks
}
```

**Verify OTP:**
```dart
Future<void> verifyOtp() async {
  // Validates OTP input
  // Creates PhoneAuthCredential
  // Signs in to Firebase
  // Gets Firebase token
  // Sends to backend with name and phone
}
```

**Resend OTP:**
```dart
Future<void> resendOtp() async {
  // Clears OTP field
  // Calls sendOtp() with resend token
}
```

### Remote Source Method (lib/features/data/source/remote_source.dart)

```dart
Future<PhoneSigninResponseModel> phoneSignin({
  required String name,
  required String phoneNumber,
  required String firebaseToken,
}) async {
  final response = await dio.post(
    ApiEndpoints.phoneSigninUrl,
    data: {
      'name': name,
      'phoneNumber': phoneNumber,
      'firebaseToken': firebaseToken,
    },
  );
  return PhoneSigninResponseModel.fromJson(response.data);
}
```

### Android Configuration

**android/app/build.gradle.kts:**
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // Added
}

android {
    defaultConfig {
        minSdk = 21  // Required for Firebase Auth
        multiDexEnabled = true  // Required
    }
}
```

**android/build.gradle.kts:**
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

---

## Troubleshooting

### Issue: "MISSING_CLIENT_IDENTIFIER"

**Cause:** SHA certificates not added to Firebase Console

**Solution:**
1. Add SHA-1 certificate to Firebase (see Step 1 above)
2. Add SHA-256 certificate to Firebase
3. Wait 5 minutes for changes to propagate
4. Rebuild app: `flutter clean && flutter run`

### Issue: OTP Not Received / "Network Error"

**Causes & Solutions:**

1. **Phone Auth not enabled**
   - Enable it in Firebase Console (see Step 2 above)

2. **No internet connection**
   - Check device internet connectivity
   - Try switching between WiFi and mobile data

3. **Invalid phone format**
   - Phone must be 10 digits
   - App automatically adds +91 prefix

4. **Firebase quota exceeded**
   - Use test phone numbers during development
   - Check Firebase Console → Usage

### Issue: "API_KEY_INVALID"

**Cause:** google-services.json not found or incorrect

**Solution:**
1. Verify `google-services.json` exists in `android/app/`
2. Re-download from Firebase Console if needed
3. Clean and rebuild: `flutter clean && flutter run`

### Issue: "TOO_MANY_ATTEMPTS_TRY_LATER"

**Cause:** Too many OTP requests from same device/number

**Solutions:**
- Use test phone numbers (see Step 3 above)
- Wait 24 hours before trying again
- Try with different phone number
- Use different device/emulator

### Issue: Backend Returns 401 "Invalid Token"

**Causes & Solutions:**

1. **Backend not verifying token correctly**
   - Use Firebase Admin SDK to verify
   - Check token hasn't expired (1 hour validity)
   - Verify phone number from token matches request

2. **CORS issues**
   - Configure backend to accept requests from app
   - Check backend logs for details

3. **Backend not set up**
   - Implement the endpoint (see Backend Requirements above)

### Issue: Build Fails

**Solution:**
```bash
# Clean all build artifacts
cd android
./gradlew clean
cd ..
flutter clean

# Reinstall dependencies
flutter pub get

# Rebuild
flutter run
```

### Issue: App Crashes on Launch

**Check:**
1. Firebase initialized correctly in `main.dart`
2. `google-services.json` is in correct location
3. Check logcat for error details:
   ```bash
   flutter run --verbose
   ```

### Issue: "Invalid phone number format"

**Solution:**
- Phone number must be exactly 10 digits
- App adds +91 prefix automatically
- Remove any spaces, dashes, or special characters

---

## Production Checklist

Before releasing to production:

- [ ] Add **RELEASE** SHA certificates from release keystore
  ```bash
  keytool -list -v -keystore /path/to/release.keystore -alias your-alias
  ```
- [ ] Remove test phone numbers from Firebase
- [ ] Enable **Firebase App Check** for production security
- [ ] Implement rate limiting on backend
- [ ] Set up monitoring and alerts
- [ ] Test with multiple real phone numbers
- [ ] Configure proper error tracking (e.g., Sentry, Firebase Crashlytics)
- [ ] Review Firebase Authentication quota limits
- [ ] Set up proper logging (remove debug prints)
- [ ] Test in release mode: `flutter run --release`

---

## Security Notes

### Best Practices

1. **Never commit sensitive files**
   - `google-services.json` (already in .gitignore)
   - Firebase private keys
   - Backend API keys

2. **Token Verification**
   - Always verify Firebase tokens on backend
   - Never trust client-side validation alone
   - Check token expiration (1 hour)

3. **Rate Limiting**
   - Firebase has built-in SMS rate limits
   - Implement additional rate limiting on backend
   - Monitor for abuse patterns

4. **Phone Number Validation**
   - Validate format on both client and server
   - Consider allowing international numbers in future

5. **Production Security**
   - Enable Firebase App Check
   - Use HTTPS for all backend endpoints
   - Implement proper CORS policies
   - Set up security rules in Firebase

---

## Support & Resources

### Firebase Console Links

- **Project Dashboard:** https://console.firebase.google.com/project/topgrade-86000
- **Authentication:** https://console.firebase.google.com/project/topgrade-86000/authentication
- **Settings:** https://console.firebase.google.com/project/topgrade-86000/settings/general

### Documentation

- **Firebase Phone Auth (Android):** https://firebase.google.com/docs/auth/android/phone-auth
- **Firebase Admin SDK:** https://firebase.google.com/docs/auth/admin/verify-id-tokens
- **Flutter Firebase:** https://firebase.google.com/docs/flutter/setup

### API Endpoints

- **Current:** `https://topgradeinnovation.com/api/auth/phone-signin`
- **Configured in:** `lib/utils/constants/api_endpoints.dart`

---

## Quick Reference

### SHA Certificates (Debug)

```
SHA-1:    26:EF:26:DD:0E:44:B2:5B:DC:F6:9A:DD:27:3A:73:D4:C6:EA:1F:A0
SHA-256:  77:57:0E:FF:E5:92:9A:FB:21:3B:EE:44:D3:DB:10:48:BB:DC:23:B0:B1:08:9D:CE:94:30:25:3B:94:F4:E0:67
```

### Test Phone Number

```
Phone:    +911234567890
OTP Code: 123456
```

### Commands

```bash
# Run app
flutter run

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Check for issues
flutter doctor

# Build APK
flutter build apk --debug
```

---

## Status

| Component | Status |
|-----------|--------|
| Code Implementation | ✅ Complete |
| Firebase Dependencies | ✅ Installed |
| Android Configuration | ✅ Complete |
| google-services.json | ✅ Configured |
| Build | ✅ Successful (86MB) |
| SHA Certificates | ⚠️ Need to add to Firebase |
| Phone Auth Enabled | ⚠️ Need to enable in Firebase |
| Backend Endpoint | ⏳ Needs implementation |

---

## Next Steps

### Right Now (5 minutes)
1. ✅ Add SHA-1 certificate to Firebase Console
2. ✅ Add SHA-256 certificate to Firebase Console
3. ✅ Enable Phone Authentication in Firebase
4. ✅ Add test phone number (optional)
5. ✅ Run: `flutter run`

### Soon (1-2 hours)
1. ⏳ Implement backend verification endpoint
2. ⏳ Test with test phone numbers
3. ⏳ Test with real phone numbers
4. ⏳ Verify end-to-end flow

### Before Production (1 day)
1. ⏳ Add release SHA certificates
2. ⏳ Enable Firebase App Check
3. ⏳ Set up monitoring
4. ⏳ Complete security review
5. ⏳ Test in release mode

---

## 🎉 You're Almost There!

Complete Step 1 and Step 2 in the [Quick Setup](#quick-setup-5-minutes) section, then run the app to test the complete OTP authentication flow!

Need help? Check the [Troubleshooting](#troubleshooting) section or Firebase documentation links above.
