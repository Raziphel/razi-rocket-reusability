# Krastorio 2 Spaced Out compatibility

Razi Rocket Reusability 1.1.3 supports **Krastorio 2 Spaced Out 2.0.x** and
remains fully standalone without it. Factorio 2.1, Space Age, and
`razi_lib >= 1.2.0` remain mandatory.

## Verified source facts

- K2SO's internal mod name is `Krastorio2-spaced-out` (capital K).
- Its October 2026 2.0.19 source depends on `Krastorio2` and `k2so-assets`.
- K2SO adds `kr-crushing` to the vanilla `crusher` crafting categories.
- K2SO adjusts rocket-part productivity research and the science card system.
- Source reviewed: https://github.com/Polka37/Krastorio2-spaced-out

## Behaviour when K2SO is installed

1. Optional dependency orders our final-fixes after K2SO. There is no required
   K2SO dependency for regular Space Age players.
2. Salvage recipes work in both `crushing` and `kr-crushing` machine categories.
   We only edit our own recipe, not Krastorio's recipes or machines.
3. Salvage's component yield is scaled to the fewest configured
   `RocketSiloPrototype.rocket_parts_required` among installed rocket silos.
   This is conservative for packs adding cheaper rockets. The result is
   capped at 1-3 minimum and 1-10 maximum; for a 50-part rocket it's 3-10.
4. K2SO's altered space-science research provides the natural unlock gate.
   We leave K2SO technology costs and productivity modifiers untouched.
5. Rocket-part ingredient conversions retain all non-paired inputs, fuel,
   crafting restrictions and productivity. If no matching processing-unit/LDS
   pair exists, recovered outputs fall back to those two ordinary components
   instead of stranded incomplete rocket parts.
6. Muluna remains a separate, optional dependency and may coexist.

## Tests and limitations

Run `node scripts/test_k2so_compatibility.js /path/to/RaziLib` after installing
the local test harness dependencies documented in README. It verifies no-K2SO,
50-part and 12-part K2SO rockets, and a modified K2-style rocket recipe.
Also run `test_report_regressions.js` to check Muluna-style productivity and
stationary-platform wreck spawning.

These are offline, mocked data-stage tests. **Full Factorio 2.1 + current
K2SO 2.0.19 + Krastorio 2 2.1.4 + RaziLib game-load and gameplay verification
is still pending.** Specifically test the standard and Krastorio crushers,
research prerequisites, actual rocket-part cost, recipe productivity, and
salvage rates on rockets using alternative silos. Do not publish the ZIP as
a tested release until these manual tests are completed.
