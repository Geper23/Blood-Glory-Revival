# Changelog

## V5 — experimental Offline Economy / WALLET_COMPAT

- User confirmed that V5 LIGHT launches and the game works on Android 15.
- Test build intended to add Glu Points rewards for battles, tournaments and achievements, and replace obsolete offer actions with in-game information.
- **Reward amounts, persistence, and full offline compatibility still require device verification.**
- Successful phone export: APK + OBB packaged into an XAPK and validated by SHA-256; no clean reinstall test yet.

## V4 — network crash fix (confirmed playable baseline)

- Preserved V3's native-library loader workaround.
- Restored the `INTERNET` Android permission to avoid uncaught Unity `WWW` `SecurityException` at the version-check stage.
- User confirmed that gameplay, menus and ordinary in-game shopping work.

## V3 — native direct loader experiment

- Replaced legacy Unity/Mono loader modules with original game library payloads from the application.
- Game began loading and reached the original "Checking Version" screen.

## V2 / V2.1 — low-target Android compatibility tests

- Tested Android 15 sideload compatibility for target SDK 13/22; corrected installation workflow for a previously installed newer-target app.
- Resolved the immediate text relocation *rejection*, but hit a legacy loader `no vspace available` failure.

## V1 — initial Android 15 compatibility test

- Confirmed old Unity `libmono.so` text relocation load failure on Android 15.