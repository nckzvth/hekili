# TBC Port Notes

## Flavor Routing
- Flavor is selected via `ns.Flavor.Current()` (see `Hekili.lua`).
- TBC TOC (`Hekili_TBC.toc`) sets `X-Flavor: TBC`.

## Compat Layer
- `Compat/Bootstrap.lua`
  - Provides safe fallback APIs for TBC:
    - metadata (`GetAddOnMetadata` / `C_AddOns`)
    - spell data (`C_Spell`)
    - items (`C_Container.GetItemCooldown`)
    - classic-safe `GetPlayerAuraBySpellID`
    - fallback `Enum.PowerType`
    - BFA Azerite stubs to avoid runtime errors on non-retail clients
- `Compat/Talents.lua`
  - TBC talent tab helpers and Paladin TBC spec routing.
- `Compat/SpellbookRanks.lua`
  - Spellbook scanning and rank resolver.

## Spell Rank Resolution
- Map shape:
  - `name -> { ids = { [spellID] = true }, bestID, bestRank }`
- Resolver:
  - `ns.GetBestKnownSpellIDByName(name)`
- Source:
  - Scans spellbook tabs/slots and parses rank text.
- Events:
  - `PLAYER_LOGIN`, `SPELLS_CHANGED`, `LEARNED_SPELL_IN_TAB`.

## TBC Paladin Extension
- File: `TBC/Paladin.lua`
- Specs:
  - `65` Holy
  - `66` Protection
  - `70` Retribution
- Shipped packs:
  - `Paladin_Protection_TBC`
  - `Paladin_Retribution_TBC`
  - `Paladin_Holy_TBC`
- Pack install path:
  - Uses `RegisterPackTable` payloads in core pack registration.

## Adding Another TBC Spec
1. Add/extend TBC module under `TBC/`.
2. Register specialization IDs using `Hekili:NewSpecialization`.
3. Register abilities/auras using rank resolver (`BestID` helper pattern).
4. Add built-in pack payload via `RegisterPackTable`.
5. Add pack to `/hekili tbc validate` list in `Options.lua`.
6. Update `Hekili_TBC.toc` load order.
