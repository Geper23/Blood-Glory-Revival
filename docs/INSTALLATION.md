# Installation / Instalace

## Current status

The phone-exported XAPK has not been independently tested in a clean install. The verified baseline is an already installed V5 LIGHT / WALLET_COMPAT build reported working on Android 15 (Redmi tanzanite).

The game package is com.glu.gladiator, app version 1.1.6 (116), with accompanying OBB file at Android/obb/com.glu.gladiator/main.116.com.glu.gladiator.obb.

## Android 15 caveats

- Android 15 ordinarily blocks installation of applications with very old target SDK values.
- For installations you are authorized to perform, ADB may support the documented option: adb install --bypass-low-target-sdk-block path/to/app.apk
- Installing an older-target build over a newer-target build may fail with error -26. Back up your app and saves before removing any existing installation.
- XAPK is a ZIP-format package combining APK and OBB. An installer must both install the APK and extract the OBB.
- Exporting APK and OBB does not save the private player profile, progress or currency.

## Export from a working phone

Copy the four files in tools/ together into a temporary Windows directory. Enable USB debugging and use VYTAHNI_HRU_Z_TELEFONU.bat to export the currently installed app and its OBB via ADB. Select the physical phone, not an emulator, if more than one ADB device is connected.

If the files have already been downloaded into the EXPORTS folder, DOKONCI_XAPK_BEZ_TELEFONU.bat can rebuild and verify the XAPK without copying from the phone again.

Do not publish proprietary game binaries without the appropriate rights.