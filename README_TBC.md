# Hekili TBC Anniversary Port

This branch provides a Burning Crusade Classic Anniversary Edition addon flavor.

## Supported Client
- Game: World of Warcraft - Burning Crusade Classic Anniversary Edition
- TOC Interface: `20505`
- AddOn folder name: `Hekili_TBC`

## MVP Supported Specs
- Paladin Protection
- Paladin Retribution
- Paladin Holy (focus/target/party healing mode)

## Installation
1. For local dev deployment, run:
   `powershell -ExecutionPolicy Bypass -File .\tools\deploy_tbc.ps1`
   This bootstraps `Libs/` and creates a junction.
2. Place the packaged addon folder at:
   `Interface/AddOns/Hekili_TBC`
3. Ensure the folder contains `Hekili_TBC.toc`.
4. Start game and verify addon is enabled.
5. Run `/reload`.

## Commands
- `/hekili tbc validate`
  - Compiles shipped TBC Paladin packs and prints a summary.
- `/hekili tbc debug`
  - Toggles TBC debug logging.
- `/hekili tbc debug on`
- `/hekili tbc debug off`

## Known MVP Limitations
- Seal twisting is not implemented in the shipped Retribution APL.
- Holy mode is intentionally simple and unit-driven (`focus`, `target`, `party1-4`).
- enUS spell-name spellbook rank resolution is primary in this MVP.

## Troubleshooting
- No recommendations:
  - Verify current pack under `/hekili` > Spec options.
  - Run `/hekili tbc validate` and check missing/failed counts.
- Wrong rank behavior:
  - Trigger `/reload` to rebuild spellbook rank cache.
- No Holy recommendations:
  - Set a valid healing target with `/hekili set healing_target ...` in Holy.
  - Confirm target unit exists and is friendly.
