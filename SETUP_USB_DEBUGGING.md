# USB Debugging Setup Guide

## Prerequisites
1. Enable USB Debugging on your Android device:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times to enable Developer Options
   - Go to Settings → Developer Options
   - Enable "USB Debugging"

2. Connect your device via USB to your desktop

3. Verify connection:
   ```bash
   flutter devices
   ```
   You should see your device listed.

## Configure Backend Connection

Since your physical device can't use `localhost` to connect to your desktop's backend, you need to:

1. **Find your desktop's local IP address:**
   - **Windows**: Open Command Prompt and run `ipconfig`
     - Look for "IPv4 Address" under your active network adapter
     - Example: `192.168.1.100`
   - **Mac/Linux**: Open Terminal and run `ifconfig` or `ip addr`
     - Look for your network interface (usually `en0` or `eth0`)
     - Example: `192.168.1.100`

2. **Update the API base URL:**
   - Open `lib/core/constants/app_constants.dart`
   - Replace `YOUR_DESKTOP_IP` with your actual IP address
   - Example: `static const String baseUrl = 'http://192.168.1.100:3000/api/v1';`

3. **Ensure your backend is accessible:**
   - Make sure your backend server is running on your desktop
   - Verify it's listening on `0.0.0.0:3000` (not just `localhost:3000`)
   - Check your firewall allows connections on port 3000

## Run the App

```bash
cd frontend
flutter run
```

Flutter will automatically detect your connected device and install the app.

## Troubleshooting

- **Device not detected**: 
  - Try `adb devices` to check if ADB sees your device
  - Re-enable USB debugging on your device
  - Try a different USB cable/port

- **Can't connect to backend**:
  - Verify your desktop and phone are on the same WiFi network
  - Check firewall settings on your desktop
  - Try pinging your desktop IP from your phone's browser: `http://YOUR_IP:3000/health`

- **Connection refused**:
  - Make sure backend is running
  - Verify backend is listening on `0.0.0.0` not just `127.0.0.1`
