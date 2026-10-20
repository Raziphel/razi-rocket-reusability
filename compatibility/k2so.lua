-- K2 Spaced Out / Factorio 2.1 compatibility.
-- Edits only our own prototypes; imports no code or assets from K2SO.
local Recipe = require("__razi_lib__/lib/recipe")
local Validation = require("__razi_lib__/lib/validation")

local K2SO = {}

function K2SO.apply()
    if not (mods and mods["Krastorio2-spaced-out"]) then return false end

    -- Enable salvaging with both Space Age and Krastorio crushing machines.
    Validation.prototype("recipe-category", "kr-crushing")
    local salvage = Recipe.get("rocket-chunk-processing")
    local categories = Recipe.categories_of(salvage:raw())
    local already_supported = false
    for _, category in ipairs(categories) do
        if category == "kr-crushing" then already_supported = true end
    end
    if not already_supported then categories[#categories + 1] = "kr-crushing" end
    salvage:set_categories(categories)

    -- Rocket-part crafts per launch can change in overhaul packs. We scale
    -- only our own returns, never K2SO's recipe or productivity modifiers.
    local required
    for _, silo in pairs(data.raw["rocket-silo"] or {}) do
        local count = silo.rocket_parts_required
        if type(count) == "number" and count > 0 then
            required = required and math.min(required, count) or count
        end
    end
    required = required or 50
    local minimum = math.max(1, math.min(3, math.floor(required * 0.06)))
    local maximum = math.max(minimum, math.min(10, math.floor(required * 0.20)))

    for _, output in pairs(salvage:raw().results or {}) do
        if output.name == "incomplete-rocket-part"
            or output.name == "processing-unit"
            or output.name == "low-density-structure" then
            output.amount = nil
            output.amount_min = minimum
            output.amount_max = maximum
        end
    end
    -- The base space-science-pack prerequisite already participates in
    -- K2SO's reworked technology-card progression.
    Validation.ingredient("rocket-chunk-processing", "rocket-chunk")
    return true
end

return K2SO
