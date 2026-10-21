# Razi Rocket Reusability

**Recover the rockets you launch. Reclaim their wreckage. Put the materials back to work.**

![Original Rocket Reusability artwork](thumbnail.png)

Razi Rocket Reusability is a small **Factorio 2.1 / Space Age** mod that turns spent rockets into salvageable orbital debris. It is an independently maintained continuation of [Rocket Reusability](https://mods.factorio.com/mod/rocket-reusability) by **redplasticstraw**.

## How it works

1. Research **Rocket Chunk Processing** and build a space platform in orbit around a planet.
2. Launch rockets from that planet. Eligible launches can send a **used rocket wreck** toward a platform in orbit.
3. Defend the platform, break apart the wreck, collect its chunks, and **crush them into reusable rocket components**.
4. Research and power a **Remnant Beacon** to prioritize that platform for incoming wrecks.

Beacons **choose a destination**. They do **not** increase the number or chance of wrecks.

## Features

- **Orbital rocket salvage:** Wrecks can approach moving or stationary space platforms.
- **Recycling:** Process recovered rocket chunks into useful materials; optionally craft and recover incomplete rocket parts.
- **Recovery control:** Configure the recovery chance, approach distance, and maximum intact wrecks per platform.
- **Optional side approaches:** Let wrecks arrive from either side of a platform for an extra challenge. **Off by default** in standalone, Easy and Normal campaigns, with an adjustable 0–100% side-arrival chance. **Razi Protocol Hard and Nightmare synchronize five of Rocket Reusability's real Map settings** after the map begins: recovery chance, wreck spawn distance, active wreck cap, side-arrivals toggle and side-arrival chance. The previous manual values are saved per game and restored on Easy, Normal, Custom or standalone. This is performed entirely by Rocket Reusability's own Lua, not by a separate program or by Razi editing a different mod's settings.
- **Beacon priority:** Powered Remnant Beacons designate preferred recovery platforms.
- **Modded platform support:** Includes compatibility handling for additional space locations and platform types.

### Razi Protocol difficulty presets (Rocket Reusability 1.1.8+)

The owner's Lua adapter changes the following **actual values under Settings > Mod settings > Map** whenever Hard or Nightmare is selected in Razi Protocol.

| Native Rocket Reusability setting | Hard | Nightmare |
| --- | ---: | ---: |
| Rocket recovery chance | 90% | 75% |
| Wreck spawn distance | 56 tiles | 44 tiles |
| Maximum active wrecks per platform | 4 | 6 |
| Side-arriving wrecks | On | On |
| Side-arrival chance | 55% | 80% |

Easy, Normal, Custom and standalone use the player’s own previous settings. Other options, including platform compatibility and debug logging, are never overridden. A restart is necessary after changing Razi’s startup difficulty. A save must then be loaded or created for the bridge to update the Map settings, on the next one-second check. Compatible with normal Factorio mod packaging. The values have not yet been verified in a live modded game.

## Requirements and compatibility

| Mod | Requirement | Notes |
| --- | --- | --- |
| **Factorio 2.1 + Space Age** | Required | Rocket and space platform gameplay |
| [**RAZI Library**](https://mods.factorio.com/mod/razi_lib) **1.2.0+** | Required | Shared settings, recipe, and runtime infrastructure |
| **Krastorio 2 Spaced Out** | Optional | Adds Krastorio crushing support and cost-aware salvage balancing |
| **Muluna** | Optional | Preserves modified rocket-part inputs and productivity effects |
| **Razi Protocol** | Optional | When installed, Hard and Nightmare enable side arrivals automatically; its Expedition Journal and salvage industries offer further integration |

This mod **cannot be enabled alongside the original** `rocket-reusability`. Save migration from that mod has not been verified in-game, so back up existing saves before switching. K2SO and Muluna support have automated offline checks, but still need full in-game verification.

## Settings

All settings are available in Factorio's mod settings.

| Setting | Default | Purpose |
| --- | --- | --- |
| Incomplete rocket parts | On | Use recoverable components in rocket construction |
| Incomplete rocket parts productivity | Off | Allow productivity for those parts; may affect balance |
| Rocket recovery chance | 100% | Chance of a wreck on an eligible launch |
| Wreck spawn distance | 64 tiles | Minimum approach distance; accounts for long hulls |
| Allow modded platforms | On | Include constructed platforms from other mods |
| Maximum active wrecks | 3 | Limit intact wrecks per platform |
| Side-arriving wrecks | **Off** | Hard/Nightmare force the real setting On; five Map settings participate in native difficulty synchronization |
| Side-arrival chance | 35% | Chance of a side approach when enabled, 0–100% |
| Debug logging | Off | Write diagnostics to the Factorio log |

If a side approach is unsafe, the mod tries the opposite side and then falls back to a front arrival. A rocket launch never generates extra wrecks just because side mode or multiple beacons are enabled.

## Documentation

- **[Mod Portal description](MOD_PORTAL.md)**: ready-to-use listing copy
- **[K2SO compatibility](docs/K2SO_COMPATIBILITY.md)**: integration details and caveats
- **[Testing checklist](docs/TESTING.md)**: manual acceptance tests
- **[Development](docs/DEVELOPMENT.md)**: local validation, packaging and API
- **[Publishing](docs/RELEASING.md)**: release checklist

## Credits and license

Original **Rocket Reusability** concept, source code, and artwork by **redplasticstraw** ([minstrel1 on GitHub](https://github.com/minstrel1/rocket-reusability)). This independent continuation is maintained by **Raziphel** and preserves the original art direction and attribution.

Licensed under [MIT](LICENSE). This is **not** the original Mod Portal listing.
