# ⚔️ BLOOD & GLORY REVIVAL

![Platform](https://img.shields.io/badge/Platform-Android%2015-3DDC84?style=flat-square&logo=android&logoColor=white)
![Base Game](https://img.shields.io/badge/Base%20Game-v1.1.6-orange?style=flat-square)
![Build](https://img.shields.io/badge/Build-V5%20LIGHT%20%2F%20WALLET__COMPAT-red?style=flat-square)
![Status](https://img.shields.io/badge/Status-Experimental-yellow?style=flat-square)

Unofficial Android compatibility and preservation project for the original Glu Mobile game **BLOOD & GLORY (`1.1.6`)**.

[Česká verze](#) · [Installation](#installation) · [Testing](#what-is-working) · [Changelog](#technical-background)

> [!IMPORTANT]
> **Project status:** `V5 LIGHT / WALLET_COMPAT` — confirmed to launch and run on one Android 15 phone. This is an experimental, device-tested compatibility build, not a guarantee of compatibility with other devices.

---

## ✅ What is working?

The maintainer has confirmed that the game starts on **Android 15** and has played the original game, navigated menus, fought battles, and used the in-game shop. The `V5 LIGHT` build was also reported working. 

The currently installed V5 application was exported from the phone together with the original OBB data and repackaged as an `.xapk`. The export script verified the archive contents and SHA-256 hashes; a clean installation of this XAPK has not been tested yet.

| Feature | Status |
| :--- | :--- |
| **Android 15 startup (Redmi `tanzanite`)** | ✅ Confirmed |
| **Game menu and battles** | ✅ Confirmed |
| **Normal in-game shop** | ✅ Confirmed |
| **V5 LIGHT launch** | ✅ Confirmed |
| **New premium-currency reward triggers** | ⚠️ Not independently confirmed |
| **Save persistence of new rewards** | ⚠️ Not confirmed |
| **Full airplane-mode / offline startup** | ⚠️ Not confirmed |
| **Historical Glu special offers / online backend** | ❌ Not restored |
| **Clean install of phone-exported XAPK** | ⚠️ Not confirmed |

---

## 🔧 Technical background

The original `1.1.6` app uses a legacy **32-bit Unity/Mono runtime**. 
* **V1–V2:** Initial compatibility tests encountered Android linker failures (`libmono.so` text relocations and subsequent loader errors).
* **V3:** Switched from legacy loader modules to the original embedded native game libraries, allowing the game to reach the loading and version-check screens. An offline test lacking `INTERNET` permission crashed due to an uncaught `SecurityException` in Unity's `WWW` request thread.
* **V4:** Restored the permission, after which the user confirmed the game worked.
* **V5 LIGHT:** Built on that baseline with wallet compatibility adjustments.

> [!NOTE]
> The application requests `INTERNET` permission for compatibility with the old startup code. That alone does not demonstrate complete offline support. Offline currency/rewards still need testing and may have issues.

---

## 📦 Release approach & Helper Tools

The repository hosts project documentation, test notes, and helper tools. The repository owner will publish GitHub Releases separately. Release APK/OBB/XAPK files are not part of the source tree. *Only distribute game binaries and assets if you have the necessary rights or permission.*

The `tools/` directory includes:
* **`VYTAHNI_HRU_Z_TELEFONU.bat` + `EXPORT_INSTALLED_APK_OBB_TO_XAPK.ps1`**  
  Export an installed APK and its OBB files using ADB; package them into an `.xapk`.
* **`DOKONCI_XAPK_BEZ_TELEFONU.bat` + `DOKONCI_XAPK_BEZ_TELEFONU.ps1`**  
  Rebuild and verify an `.xapk` using APK/OBB files already pulled to `EXPORTS/`.

> [!WARNING]
> These are utility scripts only; they do not install, fix, or modify the game itself, and APK+OBB export does not back up private save files.

---

## ⚖️ Legal notice

**BLOOD & GLORY**, its code, graphics, assets, and trademarks are the property of their respective owners. This is an independent, unofficial compatibility/preservation project; it is not affiliated with or endorsed by Glu or its successors. This repository does not grant redistribution rights for any proprietary game content or private signing materials.

---

<p align="center">
  Maintained by <a href="https://github.com/Geper23"><b>Geper23</b></a>
</p>
