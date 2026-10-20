-- Surgical conversion: retain all original rocket-part recipe modifiers and costs.
-- Muluna and other planet mods may alter ingredient amounts, productivity or
-- crafting restrictions. Do not replace the entire ingredient list.
local Core = require("__razi_lib__/lib/core")
local Settings = require("__razi_lib__/lib/settings")
local Recipe = require("__razi_lib__/lib/recipe")
local Technology = require("__razi_lib__/lib/technology")
local Validation = require("__razi_lib__/lib/validation")

local incomplete = Settings.enabled("enable-incomplete-rocket-parts", true)

local function convert_rocket_ingredients(variant)
    local processor_count, structure_count = 0, 0
    for _, ingredient in pairs(variant.ingredients or {}) do
        local name = ingredient.name or ingredient[1]
        local amount = ingredient.amount or ingredient[2] or 0
        if name == "processing-unit" then processor_count = processor_count + amount end
        if name == "low-density-structure" then structure_count = structure_count + amount end
    end
    -- Incomplete parts consist of one processor plus one LDS. Only convert
    -- whole pairs, leaving unequal or fractional additional costs intact.
    local pairs_to_convert = math.floor(math.min(processor_count, structure_count))
    if pairs_to_convert < 1 then return false end

    local remaining_processor = pairs_to_convert
    local remaining_structure = pairs_to_convert
    local rewritten = {}
    for _, ingredient in ipairs(variant.ingredients or {}) do
        local copy = Core.deepcopy(ingredient)
        local name = copy.name or copy[1]
        local available = copy.amount or copy[2] or 0
        local used = 0
        if name == "processing-unit" then
            used = math.min(available, remaining_processor)
            remaining_processor = remaining_processor - used
        elseif name == "low-density-structure" then
            used = math.min(available, remaining_structure)
            remaining_structure = remaining_structure - used
        end
        if available - used > 0 then
            if copy.name then copy.amount = available - used
            else copy[2] = available - used end
            rewritten[#rewritten + 1] = copy
        end
    end
    rewritten[#rewritten + 1] = { type = "item", name = "incomplete-rocket-part", amount = pairs_to_convert }
    variant.ingredients = rewritten
    return true
end

if incomplete then
    local converted = false
    Recipe.get("rocket-part"):each_variant(function(variant)
        if convert_rocket_ingredients(variant) then converted = true end
    end)
    if converted then
        Technology.get("rocket-silo"):unlock("incomplete-rocket-part")
        Validation.prototype("item", "incomplete-rocket-part")
        Validation.ingredient("rocket-part", "incomplete-rocket-part")
        Validation.unlock("rocket-silo", "incomplete-rocket-part")
    else
        -- Overhauls that remove processors or LDS from rocket parts must not
        -- leave salvage producing an item with no unlocked crafting route.
        Recipe.get("rocket-chunk-processing"):set_results({
            {type="item", name="processing-unit", amount_min=3, amount_max=10},
            {type="item", name="low-density-structure", amount_min=3, amount_max=10},
            {type="item", name="rocket-chunk", amount=1, independent_probability=0.1},
        })
    end
end

-- Explicit K2SO compatibility runs after other mods' data-final-fixes.
require("compatibility/k2so").apply()

Validation.prototype("asteroid", "used-rocket-asteroid")
Validation.prototype("asteroid-chunk", "rocket-chunk")
Validation.prototype("radar", "remnant-beacon")
Validation.prototype("item", "remnant-beacon")
Validation.ingredient("rocket-chunk-processing", "rocket-chunk")
local salvage_outputs = data.raw.recipe["rocket-chunk-processing"].results
local returns_incomplete = false
for _, result in pairs(salvage_outputs) do
    if result.name == "incomplete-rocket-part" then returns_incomplete = true end
end
Validation.result("rocket-chunk-processing", returns_incomplete and "incomplete-rocket-part" or "processing-unit")
Validation.unlock("rocket-chunk-processing", "rocket-chunk-processing")
Validation.unlock("remnant-beacon", "remnant-beacon")
Validation.prerequisite("remnant-beacon", "rocket-chunk-processing")
