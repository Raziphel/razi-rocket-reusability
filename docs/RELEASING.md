# Publishing Razi Rocket Reusability

This is the **maintainer checklist**, not the public description. The ready-to-paste listing is at **[MOD_PORTAL.md](../MOD_PORTAL.md)**.

## Listing details

| Field | Value |
| --- | --- |
| Title | Razi Rocket Reusability |
| Internal name / Mod Portal slug | `razi-rocket-reusability` |
| Current source version | `1.1.5` |
| Factorio version | `2.1` |
| License | `MIT` |
| Source code | https://github.com/Raziphel/razi-rocket-reusability |
| Original mod | https://mods.factorio.com/mod/rocket-reusability |
| Required mods | `base >= 2.1.0`, `space-age >= 2.1.0`, `razi_lib >= 1.2.0` |
| Optional integrations | `Krastorio2-spaced-out >= 2.0.0`, `planet-muluna` |
| Incompatible | `rocket-reusability` |

**Suggested short summary:** Recover spent rocket wrecks on orbital platforms and recycle their debris into useful materials. Includes optional harder side approaches.

## Before uploading

1. Verify actual gameplay under **Factorio 2.1 + Space Age + RAZI Library**. Confirm research unlocks, launch event handling, asteroid movement, collisions, chunk collection, processing and Remnant Beacon behavior.
2. Perform a second real game-load with **K2 Spaced Out**. Check crusher categories, productivity and progression. Repeat with **Muluna** where possible.
3. Test stationary and moving platforms, wide hulls, side-arrival mode at 0% and 100%, and changes to settings in existing saves. See [TESTING.md](TESTING.md).
4. Back up saves before trying to replace the original mod. Matching prototype names **do not guarantee** that the mod-name transition preserves all game state.
5. Run the repository checks from [DEVELOPMENT.md](DEVELOPMENT.md), including the package content check.
6. Review the [public description](../MOD_PORTAL.md) for accuracy and remove any testing caveats **only after the corresponding test is complete**.
7. Upload the ZIP from `dist/` under the **new** internal name `razi-rocket-reusability`, never under the original mod's ID.
8. Preserve the original author's credit and MIT license. The thumbnail in this repo is a conservative refinement of the original artwork.

## Release status

The code has **offline smoke-test coverage**, including K2SO and Muluna prototype fixtures, but full gameplay and existing-save migration have **not yet been verified in the game engine**. The ZIP is a development build until acceptance tests pass.

Do not change the mod version simply to update GitHub documentation. Bump `info.json` and `changelog.txt` when preparing a new uploadable release.
