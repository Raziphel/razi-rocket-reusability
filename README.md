# Razi Rocket Reusability

**A maintained Factorio 2.1 + Space Age continuation of Rocket Reusability.**

Original mod by **redplasticstraw** ([minstrel1](https://github.com/minstrel1/rocket-reusability)). Independent continuation maintained by **Raziphel**. Licensed under MIT. This is not the original Mod Portal listing.

## Gameplay

After researching **Rocket Chunk Processing**, launching rockets can generate spent wrecks on a built platform orbiting the launch planet. Destroy wrecks to recover chunks, then crush those chunks for reusable components. A powered **Remnant Beacon** makes its platform the preferred destination.

Optional incomplete rocket parts prevent free material loops and keep recycling balanced.

## Compatibility

- Factorio 2.1, Space Age and **RAZI Library (razi_lib) >= 1.2.0** required.
- Internal mod ID: `razi-rocket-reusability`.
- Cannot be enabled alongside `rocket-reusability`. Disable the original before switching.
- Existing technology/item/recipe/entity names remain unchanged, but migrating existing saves is **not yet tested in-game**. Back up saves first.
- Remote interface: `razi-rocket-reusability`, with `add_whitelist`, `remove_whitelist` and `is_whitelisted`.

## Settings

Legacy keys remain: `enable-incomplete-rocket-parts`, `enable-incomplete-rocket-parts-productivity`, and `debug-mode`.

New runtime-global settings:
- `razi-rocket-reusability-recovery-chance`: 1.0 default, range 0-1.
- `razi-rocket-reusability-spawn-distance`: 64 tiles, range 32-200; adjusted forward of long hulls.
- `razi-rocket-reusability-allow-modded-platforms`: enabled.
- `razi-rocket-reusability-max-active-wrecks`: 3, adjustable 1-12.
- `razi-rocket-reusability-side-arrivals`: false (OFF, harder when enabled).
- `razi-rocket-reusability-side-arrival-chance`: 35%, adjustable 0-100% when enabled.

Use `/razi-rocket-reset-whitelist [force]` to clear custom starter packs.

## RAZI Library integration

This is a required dependency. RAZI Library supplies settings prototypes and safe
settings reads, item/entity cloning, 2.1 recipe normalization, recipe/tech edits,
prototype validation, a runtime event registry, namespaced storage and remote APIs.

Existing recipe, research, item and setting names remain stable. On upgrade,
previously saved per-force platform starter-pack whitelists are migrated into
RAZI-managed storage. This mod does not require Razi Protocol.

## K2 Spaced Out compatibility (1.1.3)

K2SO (internal ID `Krastorio2-spaced-out`, version >= 2.0.0) is an optional
dependency. You do not need K2SO or Razi Protocol to use the standalone mod.

- Salvage can run in either Space Age `crushing` or Krastorio `kr-crushing`
  machines, including K2SO's expanded Crusher.
- Recovered materials scale with the number of rocket-part crafts required by
  the rocket silo. A 50-part rocket recovers 3-10 components per chunk; a
  12-part rocket recovers 1-2.
- K2SO's space-science technology progression remains intact, with no
  artificial advanced-tech-card gate or research shortcut.
- Modified rocket costs, crafting conditions and productivity are retained.
  If incomplete rocket parts cannot be crafted under an overhaul, salvage
  falls back to usable processors and low-density structures.
- Muluna and K2SO can both be enabled.

See `K2SO_COMPATIBILITY.md` and `TEST_PLAN.md` for verification details.

## Optional side-arriving wrecks (1.1.5)

Enable **Side-arriving rocket wrecks (Harder)** in mod settings to allow used
rockets to approach from the left or right of a space platform, instead of
always coming from the front. This option is **OFF by default**.

- Side arrival probability defaults to **35%** of eligible recoveries and can
  be adjusted from 0% to 100% without restarting the game.
- Wrecks are placed beyond observed platform foundations, checked for
  collisions, and travel diagonally toward the hub. They approach faster
  than ordinary front wrecks and can bypass front-only defenses.
- A blocked/unsafe side is retried from the other side; if neither is safe,
  the normal front approach is used rather than losing that salvage.
- Rocket recovery probability, Remnant Beacon priority, and the existing
  **active-wreck cap** remain in force. Side mode never creates extra wrecks.
- **Extra challenge:** Allow rocket wrecks to approach from the sides of
  your space platform.

## Historical report fixes (1.1.2)

- Wrecks approach stationary platforms with explicit velocity.
- Hull-aware positions avoid spawning inside long ships.
- Collision damage is less extreme while wrecks remain worthwhile salvage.
- Wreck and chunk lighting is dimmer and less reflective (visual testing pending).
- Fully powered Remnant Beacons prioritize platforms, not spawn rate.
- The default limit of three simultaneous wrecks per platform prevents backlogs.
- Muluna rocket-part costs and productivity effects are preserved: only matched
  processing-unit + low-density-structure pairs are converted.
- Muluna is an optional load-order dependency, not a required mod.

## Original graphics preservation (1.1.4)

A very light color and contrast pass was applied to the **existing** thumbnail,
icons and the small rocket-chunk color texture. The original
rocket, arrows, beacon composition and every sprite silhouette are preserved.
Large rocket/beacon sprites, transparency, dimensions, normal/roughness maps and shadows
are unchanged. No newly
generated or replacement artwork is used. The Rocket Chunk Processing research
icon metadata now matches the actual original 190x190 PNG, avoiding an invalid
256x256 sprite read. Maintainers can reproduce the tiny adjustments via
`scripts/polish_original_graphics.js` and verify with
`scripts/validate_graphics.js` (install `pngjs` in `.tools` first).

## Development and release

```bash
python3 scripts/validate.py
python3 scripts/package.py

# Optional local smoke tests against a checkout of published RAZI Library 1.2.0:
npm install --prefix .tools --no-save fengari luaparse
node scripts/test_razilib_integration.js /path/to/RaziLib
node scripts/test_report_regressions.js /path/to/RaziLib
node scripts/test_k2so_compatibility.js /path/to/RaziLib
node scripts/test_side_arrivals.js /path/to/RaziLib
```

Output: `dist/razi-rocket-reusability_1.1.5.zip`.

**Not yet runtime verified**. Test with the 2.1 executable and Space Age, including multiple planets, platforms, beacons, modded starter packs, and old saves. See `PORTAL.md` for publishing guidance.

## Credits

Forked from [minstrel1/rocket-reusability](https://github.com/minstrel1/rocket-reusability), originally by **redplasticstraw**. Original graphics and source remain MIT licensed. The published original v1.0.7 contained spawn fixes missing from public GitHub; analogous fixes have been reconstructed here.
