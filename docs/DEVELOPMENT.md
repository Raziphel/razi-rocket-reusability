# Development guide

This repository is the independent **Razi Rocket Reusability** maintenance fork, targeting **Factorio 2.1 + Space Age**.

## Layout

| Path | Purpose |
| --- | --- |
| `data.lua`, `data-final-fixes.lua` | Wrecks, chunks, recipes, research and final-stage integrations |
| `control.lua` | Launch handling, Remnant Beacon selection, front recovery |
| `runtime/side-arrivals.lua` | Optional left/right orbital recovery lanes |
| `compatibility/k2so.lua` | K2SO-specific recipes and salvage balancing |
| `prototypes/remnant-beacon.lua` | Beacon item, entity, recipe and technology |
| `graphics/`, `thumbnail.png` | Existing original-style mod artwork |
| `locale/en/english.cfg` | Text shown in Factorio |
| `scripts/` | Offline JavaScript regression tests and reproducible graphic polish |

**RAZI Library** (`razi_lib >= 1.2.0`) supplies shared settings, data-stage helpers and runtime utilities. **Razi Protocol is not required.**

## Checks

Run the static source/manifest checks:

```bash
python3 ../razi-rocket-reusability-release-tooling/validate.py
```

For local Lua smoke tests, Node.js is required. The dependencies are **developer-only** and are never shipped in the mod:

```bash
npm install --prefix .tools --no-save fengari luaparse pngjs
node scripts/test_razilib_integration.js /path/to/RaziLib
node scripts/test_report_regressions.js /path/to/RaziLib
node scripts/test_k2so_compatibility.js /path/to/RaziLib
node scripts/test_side_arrivals.js /path/to/RaziLib
node scripts/validate_graphics.js
```

Run these against **RAZI Library 1.2.0** at minimum. Tests with newer source are useful but not a substitute for testing the published dependency.

The Lua smoke-test harness uses **mocked Factorio APIs**. These checks catch regressions but **cannot guarantee that a mod loads or behaves correctly in Factorio**. Use [TESTING.md](TESTING.md) for real in-game acceptance.

## Build the release archive

```bash
python3 ../razi-rocket-reusability-release-tooling/package.py
```

The archive is written to `dist/razi-rocket-reusability_<version>.zip`. Packaging is **allowlisted**: it includes playable files, metadata, existing graphics, and licensing, but excludes tests, developer documentation, backups and local tools.

Do not manually rename the ZIP to a new version. Update `info.json` and the changelog for an actual release.

## Remote interface

The interface name is `razi-rocket-reusability`, with the compatibility functions:

- `add_whitelist(pack, force)`
- `remove_whitelist(pack, force)`
- `is_whitelisted(pack, force)`

It accepts custom platform starter-pack names and optional force identifiers. For compatibility reasons, these names have not been renamed. The console command `/razi-rocket-reset-whitelist [force]` clears the custom list.

## Artwork

The graphics are original-source artwork with only small contrast edits. Do not replace them with newly generated artwork as part of routine maintenance.

`scripts/polish_original_graphics.js` reads a pinned baseline commit. `scripts/validate_graphics.js` verifies original dimensions, alpha, shadows, normals, roughness and the bounded colour changes.

## License and attribution

The original mod's author is **redplasticstraw**, source at https://github.com/minstrel1/rocket-reusability. Preserve both credits and [MIT license](../LICENSE).


## Portal-safe source and upload

Python maintenance tools are stored **outside the mod repository**. For a public checkout without the maintainer tooling, create a release archive from an explicit allowlist (never upload **GitHub Code → Download ZIP**):

```bash
name="razi-rocket-reusability_$(node -p 'require("./info.json").version')"
mkdir -p dist
git archive --format=zip --prefix="$name/" -o "dist/$name.zip" HEAD info.json LICENSE README.md changelog.txt thumbnail.png settings.lua data.lua data-final-fixes.lua control.lua graphics locale prototypes compatibility runtime
```

Check with `unzip -Z1 "dist/$name.zip"`. Files ending in `.exe`, `.bat`, `.ps1`, `.sh`, or `.py` must never appear in the package.
