# BLOOD & GLORY REVIVAL

**Neoficiální projekt pro zachování a spuštění původní hry BLOOD & GLORY 1.1.6 od Glu na moderním Androidu.**

[English](README.md) · [Instalace](docs/INSTALLATION.md) · [Testování](docs/TESTING.md) · [Historie](CHANGELOG.md)

**Stav: V5 LIGHT / WALLET_COMPAT – uživatelem potvrzené spuštění a hraní na Androidu 15.**

## Co bylo ověřeno

Na telefonu Redmi `tanzanite` s Androidem 15 fungují základní herní obrazovky, menu, souboje i běžný obchod. Uživatel rovněž potvrdil spuštění V5 LIGHT. Byla vytvořena kopie aktuálně nainstalovaného APK (18 926 266 bajtů) a OBB (131 667 125 bajtů) a sestaveno XAPK s ověřenými soubory.

**Zatím není potvrzená čistá instalace výsledného XAPK na jiném zařízení, úplná funkčnost bez internetu, ani správné přičítání a ukládání bonusových Glu Points ve V5.** Staré speciální nabídky Glu nejsou obnovené.

## Průběh opravy

- V1: Android odmítal staré knihovny Unity/Mono kvůli textovým relokacím.
- V2: nižší target SDK povolilo kompatibilní načítání, ale staré loader moduly selhaly.
- V3: nahrazení zastaralých nativních loaderů skutečnými knihovnami hry, postup až na „Checking Version“.
- V4: obnovení oprávnění `INTERNET` odstranilo chybu `SecurityException`, uživatel potvrdil funkční hru.
- V5 LIGHT: upravená ekonomika WALLET_COMPAT, samotná hra stále funkční; nové odměny vyžadují ověření.
- V5 PHONE EXPORT: funkční instalace vytažena přes ADB, XAPK sestaveno a ověřeno; samostatná reinstalace z XAPK netestována.

## Nástroje

Ve složce `tools/` jsou PowerShell a BAT skripty pro vytažení nainstalovaného APK/OBB z telefonu a pro dokončení XAPK z již stažených souborů. Nevytahují uložený postup ani interní data aplikace.

## Upozornění

Repozitář obsahuje dokumentaci a pomocné skripty, nikoli původní komerční herní data nebo podpisové klíče. APK a OBB publikujte pouze s odpovídajícím oprávněním. Release vytvoří správce projektu samostatně.