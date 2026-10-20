-- Use shared RAZI recipe/technology editing and fail fast on broken prototypes.
local Settings = require("__razi_lib__/lib/settings")
local Recipe = require("__razi_lib__/lib/recipe")
local Technology = require("__razi_lib__/lib/technology")
local Validation = require("__razi_lib__/lib/validation")

local incomplete = Settings.enabled("enable-incomplete-rocket-parts", true)

if incomplete then
    Recipe.get("rocket-part"):set_ingredients({
        { type = "item", name = "rocket-fuel", amount = 1 },
        { type = "item", name = "incomplete-rocket-part", amount = 1 },
    })
    Technology.get("rocket-silo"):unlock("incomplete-rocket-part")
    Validation.prototype("item", "incomplete-rocket-part")
    Validation.ingredient("rocket-part", "incomplete-rocket-part")
    Validation.unlock("rocket-silo", "incomplete-rocket-part")
end

Validation.prototype("asteroid", "used-rocket-asteroid")
Validation.prototype("asteroid-chunk", "rocket-chunk")
Validation.prototype("radar", "remnant-beacon")
Validation.prototype("item", "remnant-beacon")
Validation.ingredient("rocket-chunk-processing", "rocket-chunk")
Validation.result("rocket-chunk-processing", incomplete and "incomplete-rocket-part" or "processing-unit")
Validation.unlock("rocket-chunk-processing", "rocket-chunk-processing")
Validation.unlock("remnant-beacon", "remnant-beacon")
Validation.prerequisite("remnant-beacon", "rocket-chunk-processing")
