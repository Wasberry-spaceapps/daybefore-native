# Installing Day Before Native

## Android
1. Download `DayBefore-android.apk` from the Releases page.
2. Settings → Security → Enable "Install from unknown sources" for your browser.
3. Open the APK. Tap "Install".
4. If Play Protect warns: tap "Install anyway".

## Windows
1. Download `DayBefore-windows.zip` from the Releases page.
2. Extract the zip to any folder.
3. Double-click `daybefore.exe`.
4. SmartScreen blocks it: click **"More info"** → **"Run anyway"**.

## macOS
1. Download `DayBefore-macos.zip` from the Releases page.
2. Extract (double-click in Finder).
3. Right-click `daybefore.app` → **"Open"** (bypasses Gatekeeper first time).
4. If blocked: System Settings → Privacy & Security → **"Open Anyway"**.
5. Or run `xattr -cr ~/Downloads/daybefore.app` in Terminal first.

## iPhone (requires a computer)
The iOS build is unsigned. Install via sideloading:

### Sideloadly (recommended)
1. Download [Sideloadly](https://sideloadly.io/) on Mac or PC.
2. Connect iPhone via USB. Download `DayBefore-ios-unsigned.ipa`.
3. Drag .ipa into Sideloadly, enter Apple ID, click Start.
4. iPhone: Settings → General → VPN & Device Management → trust your Apple ID.
5. ⚠️ Free Apple ID apps expire every 7 days. Re-sideload when needed.

### AltStore (alternative)
1. Install [AltStore](https://altstore.io/) on computer + iPhone.
2. Open the .ipa with AltStore. Same 7-day re-signing limit.
