-- RAZI Library builds and validates our setting prototypes.
local Settings = require("__razi_lib__/lib/settings")

data:extend({
    Settings.bool("enable-incomplete-rocket-parts", "startup", true, "a"),
    Settings.bool("enable-incomplete-rocket-parts-productivity", "startup", false, "b"),
    Settings.double("razi-rocket-reusability-recovery-chance", "runtime-global", 1.0, 0, 1, "c"),
    Settings.int("razi-rocket-reusability-spawn-distance", "runtime-global", 64, 32, 200, "d"),
    Settings.bool("razi-rocket-reusability-allow-modded-platforms", "runtime-global", true, "e"),
    Settings.int("razi-rocket-reusability-max-active-wrecks", "runtime-global", 3, 1, 12, "f"),
    Settings.bool("debug-mode", "runtime-global", false, "z"),
})
