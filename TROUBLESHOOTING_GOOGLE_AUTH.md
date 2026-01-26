# Troubleshooting Google Authentication

## Common Error: "Something went wrong. Please try again."

This error usually occurs when Google sign-in succeeds but backend sync fails.

## Step-by-Step Troubleshooting

### 1. Check Backend Server Status

Ensure your backend is running:
```bash
cd backend
npm run dev
```

You should see:
```
🚀 Server running on port 3000
📡 Health check: http://localhost:3000/health
```

### 2. Verify Backend URL

Check `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'http://192.168.1.42:3000/api/v1';
```

**Important**: 
- For ADB over WiFi (`adb connect 192.168.1.42:5555`), use the same IP
- Make sure your desktop and phone are on the same WiFi network
- The IP address should match your desktop's local network IP

### 3. Test Backend Connectivity

From your phone's browser, try accessing:
```
http://192.168.1.42:3000/health
```

You should see: `{"status":"ok","timestamp":"..."}`

If this fails:
- Backend is not running, OR
- Firewall is blocking port 3000, OR
- Wrong IP address

### 4. Check Console Logs

When you try to sign in with Google, check the console for:

**Look for these log sections:**
- `🔵 [GOOGLE AUTH] Starting Google sign in`
- `✅ [GOOGLE AUTH] Firebase sign in successful`
- `🔄 [GOOGLE AUTH] Starting backend sync...`
- `❌ [AUTH] Backend sync error` ← This is where the problem is

**Common error patterns:**
- `Failed host lookup` → Wrong IP or backend not running
- `Connection refused` → Backend not running or firewall blocking
- `Connection timeout` → Network issue or backend too slow
- `Status 401` → Backend authentication issue
- `Status 500` → Backend server error

### 5. Verify Firebase Configuration

1. **Enable Google Sign-In in Firebase Console:**
   - Go to Firebase Console → Authentication → Sign-in method
   - Enable "Google" provider
   - Add your app's SHA-1 fingerprint (for Android)

2. **Check Firebase Admin SDK:**
   - Ensure backend has correct Firebase credentials in `.env`
   - Verify `FIREBASE_PROJECT_ID`, `FIREBASE_PRIVATE_KEY`, `FIREBASE_CLIENT_EMAIL`

### 6. Check Network/Firewall

**Windows Firewall:**
```powershell
# Allow port 3000
netsh advfirewall firewall add rule name="Node.js Backend" dir=in action=allow protocol=TCP localport=3000
```

**Verify backend is listening on all interfaces:**
Check `backend/src/server.ts` - should have:
```typescript
app.listen(PORT, '0.0.0.0', () => {
```

### 7. Test Backend Endpoint Directly

Use a tool like Postman or curl to test:
```bash
# Get Firebase ID token first (from app logs)
curl -X POST http://192.168.1.42:3000/api/v1/auth/login \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN" \
  -H "Content-Type: application/json"
```

## Quick Fixes

### If backend is not accessible:
1. Check if backend is running: `npm run dev` in backend folder
2. Verify IP address matches your desktop's local IP
3. Check firewall settings
4. Ensure both devices are on same WiFi network

### If Firebase auth works but backend fails:
1. Check backend logs for errors
2. Verify MongoDB connection
3. Check Firebase Admin SDK credentials
4. Verify backend endpoint `/auth/login` exists

### If you see "Connection refused":
- Backend is not running → Start it with `npm run dev`
- Wrong IP address → Update `app_constants.dart`
- Firewall blocking → Allow port 3000

## Debug Mode

Enable detailed logging by checking console output. All authentication steps are logged with:
- 🔵 Google Auth steps
- 🔄 Backend sync steps  
- ❌ Error details
- ✅ Success confirmations

Look for the error message in logs - it will tell you exactly what went wrong.
