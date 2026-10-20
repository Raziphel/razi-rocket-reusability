data:extend({
    {
        type = "bool-setting",
        name = "enable-incomplete-rocket-parts",
        setting_type = "startup",
        default_value = true,
        order = "a"
    },
    {
        type = "bool-setting",
        name = "enable-incomplete-rocket-parts-productivity",
        setting_type = "startup",
        default_value = false,
        order = "b"
    },
    {
        type = "double-setting",
        name = "razi-rocket-reusability-recovery-chance",
        setting_type = "runtime-global",
        default_value = 1.0,
        minimum_value = 0,
        maximum_value = 1,
        order = "c"
    },
    {
        type = "int-setting",
        name = "razi-rocket-reusability-spawn-distance",
        setting_type = "runtime-global",
        default_value = 96,
        minimum_value = 64,
        maximum_value = 200,
        order = "d"
    },
    {
        type = "bool-setting",
        name = "razi-rocket-reusability-allow-modded-platforms",
        setting_type = "runtime-global",
        default_value = true,
        order = "e"
    },
    {
        type = "bool-setting",
        name = "debug-mode",
        setting_type = "runtime-global",
        default_value = false,
        order = "z"
    }
})
