# Manual acceptance tests: Factorio 2.1 / Razi Rocket Reusability 1.1.5

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

## Krastorio 2 Spaced Out acceptance

16. Start Factorio 2.1 with current Krastorio 2 + K2SO, RaziLib, Space Age and this mod. Confirm no dependency or prototype errors.
17. Research Rocket Chunk Processing in K2SO. Verify science-card progression has no skipped or impossible requirements.
18. Check rocket chunk crushing in the Space Age Crusher and the Krastorio crushing machine category.
19. Compare rocket-part costs and research productivity before and after enabling the mod. Existing K2SO modifiers must remain unchanged.
20. Test a standard rocket silo and a modified cheaper rocket silo. Confirm component yields match the declared silo craft requirement.
21. Repeat with Muluna + K2SO together, both incomplete-parts setting choices, and modded platforms.
22. Verify disabling K2SO leaves vanilla Space Age salvage functional.

## Optional harder side approaches

23. With side arrivals OFF, launch repeatedly and confirm all wrecks enter
    from the front as before.
24. Turn side arrivals ON (35% chance). Launch several rockets at a stationary
    platform and observe genuine left/right approaches toward the hull.
25. Test chance 0% (front only) and 100% (both sides eligible) while in-game.
26. Test a short/narrow platform, a wide irregular platform and a long ship.
    Wrecks must not materialize on top of foundation tiles.
27. Block one side with nearby wrecks and verify the opposite side can receive
    a wreck; block both and verify recovery falls back to the front.
28. Confirm the existing maximum active wreck limit and Remnant Beacon
    prioritization still apply. One launch must never create multiple wrecks.
29. Confirm side approaches are dangerous but interceptable by side turrets.
    Test both stopped and moving space platforms with Space Age and K2SO.

## Developer commands

Run these in the repository's checkout:

    python3 scripts/validate.py
    npm install --prefix .tools --no-save fengari luaparse
    node scripts/test_razilib_integration.js /path/to/RaziLib
    node scripts/test_report_regressions.js /path/to/RaziLib
    node scripts/test_k2so_compatibility.js /path/to/RaziLib
    node scripts/test_side_arrivals.js /path/to/RaziLib
    python3 scripts/package.py

The generated ZIP is a **development build**, not a verified release, until in-game acceptance testing has been completed.
