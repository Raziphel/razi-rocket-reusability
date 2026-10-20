# Manual acceptance tests: Factorio 2.1 / Razi Rocket Reusability 1.1.2

Offline smoke tests in the repository are useful, but do **not** replace in-game testing. Use RAZI Library 1.2.0 or newer and Space Age. The original Rocket Reusability must be disabled.

## Wreck generation and movement

1. Research Rocket Chunk Processing, then launch several rockets from Nauvis.
2. Leave a small platform **stationary** in Nauvis orbit, with asteroid defenses. Confirm used rockets approach the front and can be collected after destruction.
3. Repeat with a **moving platform**, then a long/irregular platform extending more than 64 tiles ahead of its hub. Check wrecks never materialize overlapping the hull.
4. Remove all constructed orbital platforms, launch again, and check for errors and unexpected spawns.
5. Try multiple platforms at the same planet. Add one powered Remnant Beacon and confirm its platform receives wrecks; disconnect its power and confirm priority stops.
6. Put several beacons on one platform and verify it is prioritized once, not given multiple wrecks for one launch. The recovery chance setting determines the chance of a wreck, not beacon count.
6a. Leave three intact wrecks on the platform (or set the maximum to 1 for easier testing). A new launch should not create additional wrecks there while at the cap. An alternative uncapped platform may receive the next wreck.
7. Repeat at Muluna and at another modded planet, with non-default starter packs. Check Lua log for errors.

## Graphics and collision balancing

8. Compare visual brightness of used rockets and chunks with regular asteroids against dark and illuminated platform backgrounds. The new lighting should not appear washed out.
9. Test an undefended sacrificial platform in a disposable save. Check that a wreck collision is damaging but substantially less catastrophic than the original 5,000 HP / default collision multiplier.
10. Test normal, laser and explosive turret builds to confirm the 2,000 HP wreck still needs noticeable effort but isn't an absurd ammunition sink.

## Recipe compatibility

11. With incomplete parts ON, confirm the standard 1 processor + 1 LDS substitution and unchanged rocket fuel use. With incomplete parts OFF, confirm vanilla/Muluna recipes are untouched.
12. With **Muluna**, inspect the rocket-part recipe and research productivity effects. Verify planet-specific cost multipliers and rocket-part productivity remain effective.
13. With other rocket-part mods, check that nonmatching extra ingredients, recipe surface conditions and module productivity settings are preserved.
14. Load a save from Razi Rocket Reusability 1.1.1; verify whitelisted starter packs are retained and mod-provided items, beacons and technology survive.
15. Load a save from the original Rocket Reusability **only after backing up the save**, with the original mod disabled. Test migration manually: identical prototype names help but do not guarantee a clean Factorio mod-name transition.

## Developer commands

Run these in the repository's checkout:

    python3 scripts/validate.py
    npm install --prefix .tools --no-save fengari luaparse
    node scripts/test_razilib_integration.js /path/to/RaziLib
    node scripts/test_report_regressions.js /path/to/RaziLib
    python3 scripts/package.py

The generated ZIP is a **development build**, not a verified release, until in-game acceptance testing has been completed.
