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
- **Optional side approaches:** Let wrecks arrive from either side of a platform for an extra challenge. **Off by default** in standalone, Easy and Normal campaigns, with an adjustable 0–100% side-arrival chance. **Razi Protocol Hard and Nightmare enable side approaches by updating Rocket Reusability's actual in-game Map setting** after the map begins. When leaving Hard/Nightmare, the original manual checkbox is restored; Easy, Normal and Custom retain their own choices. This is handled entirely by this mod's Lua code and needs no external program.
- **Beacon priority:** Powered Remnant Beacons designate preferred recovery platforms.
- **Modded platform support:** Includes compatibility handling for additional space locations and platform types.

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
| Side-arriving wrecks | **Off** | Allow left/right approaches. In Razi Protocol Hard/Nightmare, this Map setting is actually switched On by Rocket Reusability on the next one-second check |
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
