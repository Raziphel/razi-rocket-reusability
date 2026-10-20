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
- `razi-rocket-reusability-spawn-distance`: 96 tiles, range 64-200.
- `razi-rocket-reusability-allow-modded-platforms`: enabled.

Use `/razi-rocket-reset-whitelist [force]` to clear custom starter packs.

## RAZI Library integration

This is a required dependency. RAZI Library supplies settings prototypes and safe
settings reads, item/entity cloning, 2.1 recipe normalization, recipe/tech edits,
prototype validation, a runtime event registry, namespaced storage and remote APIs.

Existing recipe, research, item and setting names remain stable. On upgrade,
previously saved per-force platform starter-pack whitelists are migrated into
RAZI-managed storage. This mod does not require Razi Protocol.

## Development and release

```bash
python3 scripts/validate.py
python3 scripts/package.py

# Optional local smoke tests against a checkout of published RAZI Library 1.2.0:
npm install --prefix .tools --no-save fengari luaparse
node scripts/test_razilib_integration.js /path/to/RaziLib
```

Output: `dist/razi-rocket-reusability_1.1.1.zip`.

**Not yet runtime verified**. Test with the 2.1 executable and Space Age, including multiple planets, platforms, beacons, modded starter packs, and old saves. See `PORTAL.md` for publishing guidance.

## Credits

Forked from [minstrel1/rocket-reusability](https://github.com/minstrel1/rocket-reusability), originally by **redplasticstraw**. Original graphics and source remain MIT licensed. The published original v1.0.7 contained spawn fixes missing from public GitHub; analogous fixes have been reconstructed here.
