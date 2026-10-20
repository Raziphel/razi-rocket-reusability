# Factorio Mod Portal listing draft

**Internal name:** `razi-rocket-reusability`  
**Title:** Razi Rocket Reusability  
**Summary:** Reclaim spent rockets in orbit and recycle their wreckage. A Factorio 2.1 continuation of Rocket Reusability.  
**Required:** Factorio 2.1, Space Age and RAZI Library >= 1.2.0
**Licence:** MIT  
**Source:** https://github.com/Raziphel/razi-rocket-reusability

## Description

What happens to all those rockets after launch? Razi Rocket Reusability brings spent rockets back into the gameplay loop.

- **Recover rocket wrecks:** Once Rocket Chunk Processing is researched, successful rocket launches can create used-rocket asteroids on platforms orbiting the launch planet.
- **Recycle your materials:** Break wrecks into chunks and crush them into components for new rocket parts.
- **Guide recoveries:** Powered Remnant Beacons prioritize selected platforms.
- **Balance to taste:** Adjust recovery chance and spawn distance. Optional incomplete rocket parts help avoid material duplication.
- **Space Age friendly:** Supports built platforms and other modded space locations.
- **RAZI Library integration:** Shares reliable settings, recipes, prototype validation and runtime helpers. Does not require Razi Protocol.

### Improvements since the original

Wrecks now approach stationary platforms, avoid forward hulls and cause less impact damage. Rocket and chunk lighting has been softened. Rocket-part conversions preserve Muluna's ingredient ratios and productivity research.


### K2 Spaced Out compatibility

Optional, explicitly supported Krastorio 2 Spaced Out 2.0.x integration: enables salvage in Krastorio crushers, preserves rocket productivity and science progression, and balances yields against the rocket silo's configured launch cost. No requirement for Razi Protocol.

### Compatibility

Requires Factorio **2.1**, **Space Age**, and **[RAZI Library](https://mods.factorio.com/mod/razi_lib) 1.2.0+**. Do not enable alongside the original Rocket Reusability mod. Save backups are recommended when switching between mods, pending migration testing.

### Credits

Independent continuation maintained by **Raziphel**, based on **Rocket Reusability** by **redplasticstraw** (source: **minstrel1**), shared under the **MIT licence**. Thanks to the original creator for the mechanics and artwork.

## Before publishing

1. Verify the upload ZIP is named `razi-rocket-reusability_1.1.3.zip` and contains the same-name top-level directory.
2. Run the offline validator and perform an actual Factorio 2.1 + Space Age game-load test.
3. Check actual gameplay: launched rockets, orbiting platforms, recovery, beacons, recycling, and existing saves.
4. Set the new Mod Portal slug to `razi-rocket-reusability`, confirm the owner and MIT licence, and link the repository.
5. Use the existing thumbnail for the initial continuation, subject to the original MIT attribution, or replace it with original artwork later.

**Release status:** Prepared source; *not gameplay verified or published*.
