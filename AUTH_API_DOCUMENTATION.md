# Authentication API Documentation

This document provides comprehensive guidance for backend developers to implement the required authentication endpoints for the Flutter application.

## Table of Contents
- [Overview](#overview)
- [Base Configuration](#base-configuration)
- [Authentication Endpoints](#authentication-endpoints)
- [Error Handling](#error-handling)
- [Security Considerations](#security-considerations)
- [Testing](#testing)

## Overview

The Flutter application implements a comprehensive authentication system with the following features:
- Email/Password Sign In
- Phone/OTP Sign In
- User Registration (Sign Up)
- Password Reset Flow
- Google OAuth Integration
- Mobile OTP Verification

## Base Configuration

### Headers
All API requests include the following headers:
```
Content-Type: application/json; charset=UTF-8
```

### Timeouts
- Send Timeout: 60 seconds
- Receive Timeout: 60 seconds

### Base Response Format
All successful responses should return HTTP status codes `200` or `201`.

## Authentication Endpoints

### 1. Email/Password Sign In

**Endpoint:** `POST /login`

**Description:** Authenticates user with email and password credentials.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "userpassword123"
}
```

**Request Validation:**
- `email`: Required, must be a valid email format
- `password`: Required, minimum 6 characters

**Success Response (200/201):**
```json
{
  "id": 1,
  "name": "John Doe",
  "username": "johndoe",
  "email": "user@example.com",
  "phone": "+1234567890",
  "access_token": "jwt_token_here",
  "refresh_token": "refresh_token_here"
}
```

**Error Responses:**

*400 Bad Request:*
```json
{
  "error": "Invalid email or password"
}
```

*500 Internal Server Error:*
```json
{
  "error": "Internal server error message"
}
```

---

### 2. Phone OTP Sign In

**Note:** Currently implemented as simulation in the app. Backend should implement the following endpoints:

#### 2.1 Send OTP to Phone

**Endpoint:** `POST /auth/send-otp`

**Description:** Sends OTP to the provided phone number.

**Request Body:**
```json
{
  "phone": "+1234567890"
}
```

**Request Validation:**
- `phone`: Required, minimum 10 digits, should include country code

**Success Response (200):**
```json
{
  "message": "OTP sent successfully",
  "phone": "+1234567890",
  "expires_in": 300
}
```

**Error Responses:**
```json
{
  "error": "Invalid phone number"
}
```

#### 2.2 Verify OTP and Sign In

**Endpoint:** `POST /auth/verify-otp`

**Description:** Verifies OTP and signs in the user.

**Request Body:**
```json
{
  "phone": "+1234567890",
  "otp": "123456"
}
```

**Request Validation:**
- `phone`: Required, must match the phone number OTP was sent to
- `otp`: Required, exactly 6 digits

**Success Response (200):**
```json
{
  "id": 1,
  "name": "John Doe",
  "username": "johndoe",
  "email": "user@example.com",
  "phone": "+1234567890",
  "website": "https://johndoe.com",
  "access_token": "jwt_token_here",
  "refresh_token": "refresh_token_here"
}
```

**Error Responses:**
```json
{
  "error": "Invalid or expired OTP"
}
```

---

### 3. User Registration (Sign Up)

**Endpoint:** `POST /auth/register`

**Description:** Creates a new user account.

**Request Body:**
```json
{
  "full_name": "John Doe",
  "email": "user@example.com",
  "password": "userpassword123",
  "confirm_password": "userpassword123"
}
```

**Request Validation:**
- `full_name`: Required, non-empty string
- `email`: Required, valid email format, must be unique
- `password`: Required, minimum 6 characters
- `confirm_password`: Required, must match password

**Success Response (201):**
```json
{
  "id": 1,
  "name": "John Doe",
  "username": "johndoe",
  "email": "user@example.com",
  "phone": null,
  "access_token": "jwt_token_here",
  "refresh_token": "refresh_token_here"
}
```

**Error Responses:**

*400 Bad Request:*
```json
{
  "error": "Email already exists"
}
```

*422 Unprocessable Entity:*
```json
{
  "error": "Passwords do not match"
}
```

---

### 4. Password Reset Flow

The password reset process involves three steps:

#### 4.1 Send Reset Password OTP

**Endpoint:** `POST /auth/forgot-password`

**Description:** Sends verification code to user's email for password reset.

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Request Validation:**
- `email`: Required, valid email format, must exist in system

**Success Response (200):**
```json
{
  "message": "Verification code sent to email",
  "email": "user@example.com",
  "expires_in": 600
}
```

**Error Responses:**
```json
{
  "error": "Email not found"
}
```

#### 4.2 Verify Reset OTP

**Endpoint:** `POST /auth/verify-reset-otp`

**Description:** Verifies the reset password OTP.

**Request Body:**
```json
{
  "email": "user@example.com",
  "otp": "123456"
}
```

**Request Validation:**
- `email`: Required, must match email from step 1
- `otp`: Required, exactly 6 digits

**Success Response (200):**
```json
{
  "message": "OTP verified successfully",
  "reset_token": "temporary_reset_token_here"
}
```

**Error Responses:**
```json
{
  "error": "Invalid or expired verification code"
}
```

#### 4.3 Reset Password

**Endpoint:** `POST /auth/reset-password`

**Description:** Sets new password using the reset token.

**Request Body:**
```json
{
  "reset_token": "temporary_reset_token_here",
  "new_password": "newpassword123",
  "confirm_password": "newpassword123"
}
```

**Request Validation:**
- `reset_token`: Required, valid token from step 2
- `new_password`: Required, minimum 6 characters
- `confirm_password`: Required, must match new_password

**Success Response (200):**
```json
{
  "message": "Password reset successfully"
}
```

**Error Responses:**
```json
{
  "error": "Invalid or expired reset token"
}
```

---

### 5. Google OAuth Integration

**Note:** Currently simulated in the app. Backend should implement OAuth flow.

#### 5.1 Google Sign In/Sign Up

**Endpoint:** `POST /auth/google`

**Description:** Authenticates or creates user account using Google OAuth.

**Request Body:**
```json
{
  "google_token": "google_oauth_token_here",
  "action": "signin"
}
```

**Request Validation:**
- `google_token`: Required, valid Google OAuth token
- `action`: Required, either "signin" or "signup"

**Success Response (200/201):**
```json
{
  "id": 1,
  "name": "John Doe",
  "username": "johndoe",
  "email": "user@gmail.com",
  "phone": null,
  "website": null,
  "access_token": "jwt_token_here",
  "refresh_token": "refresh_token_here",
  "is_new_user": false
}
```

**Error Responses:**
```json
{
  "error": "Invalid Google token"
}
```

---

## Error Handling

The Flutter app expects specific error response formats:

### HTTP Status Codes
- `400`: Bad Request - Invalid input data
- `401`: Unauthorized - Invalid credentials
- `404`: Not Found - Resource not found
- `422`: Unprocessable Entity - Validation errors
- `500`: Internal Server Error - Server-side errors

### Error Response Format
All error responses should include an `error` field with a descriptive message:

```json
{
  "error": "Descriptive error message here"
}
```

### Client-Side Error Handling
The app handles errors as follows:
- `400` status: Displays `response.data['error']` message
- `500` status: Displays `response.data` as string
- Other exceptions: Displays generic error message

---

## Security Considerations

### 1. Password Requirements
- Minimum 6 characters
- Consider implementing additional complexity requirements

### 2. OTP Security
- OTP should expire after 5-10 minutes
- Implement rate limiting for OTP requests
- Use secure random number generation

### 3. JWT Tokens
- Implement proper JWT token validation
- Use secure signing algorithms (RS256 recommended)
- Set appropriate expiration times

### 4. Rate Limiting
- Implement rate limiting on all authentication endpoints
- Particularly important for OTP and password reset endpoints

### 5. Input Validation
- Validate all input parameters
- Sanitize email addresses
- Validate phone number formats

---

## Testing

### Test Accounts
For development and testing, you can use these sample credentials:

**Default Test Account:**
- Email: `dhinesh.tech2001@gmail.com`
- Password: `12345`

### Sample API Calls

#### Login Test
```bash
curl -X POST http://your-api-base-url/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "dhinesh.tech2001@gmail.com",
    "password": "12345"
  }'
```

#### Registration Test
```bash
curl -X POST http://your-api-base-url/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Test User",
    "email": "test@example.com",
    "password": "testpass123",
    "confirm_password": "testpass123"
  }'
```

---

## Implementation Notes

1. **Base URL Configuration**: The app uses a configurable base URL through the DioClient. Ensure your API base URL is properly configured.

2. **Response Model**: The app expects user data in the `DemoModel` format. Ensure your API responses match this structure.

3. **Navigation Flow**: Successful authentication redirects users to the home screen (`/home` route).

4. **State Management**: The app uses GetX for state management. Authentication state is managed through the `AuthController`.

5. **Validation**: Client-side validation is implemented, but server-side validation is also required for security.

6. **Error Messages**: Error messages should be user-friendly and descriptive to provide good user experience.

---

## Questions or Issues?

If you have any questions about implementing these endpoints or need clarification on any requirements, please refer to the Flutter app code or contact the mobile development team.