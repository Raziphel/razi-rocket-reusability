-- Factorio 2.1 maintenance of redplasticstraw's Rocket Reusability.
-- Existing prototype names and interface are preserved for save compatibility.
local DEFAULT_PACK = "space-platform-starter-pack"

local function debug_log(message)
    if settings.global["debug-mode"].value then log("[razi-rocket-reusability] " .. message) end
end

local function whitelist_for(force)
    storage.platform_type_whitelist = storage.platform_type_whitelist or {}
    local all = storage.platform_type_whitelist
    all[force] = all[force] or {}
    return all[force]
end

local function is_whitelisted(pack, force)
    return pack == DEFAULT_PACK or whitelist_for(force or "player")[pack] == true
end

script.on_init(function()
    storage.platform_type_whitelist = storage.platform_type_whitelist or {}
end)

script.on_configuration_changed(function()
    storage.platform_type_whitelist = storage.platform_type_whitelist or {}
    for _, allowed in pairs(storage.platform_type_whitelist) do
        for _, pack in ipairs(allowed) do
            if type(pack) == "string" then allowed[pack] = true end
        end
        for key in pairs(allowed) do
            if type(key) == "number" then allowed[key] = nil end
        end
    end
end)

remote.add_interface("razi-rocket-reusability", {
    add_whitelist = function(pack, force)
        if type(pack) ~= "string" then return false end
        whitelist_for(force or "player")[pack] = true
        return true
    end,
    remove_whitelist = function(pack, force)
        if type(pack) ~= "string" then return false end
        whitelist_for(force or "player")[pack] = nil
        return true
    end,
    is_whitelisted = function(pack, force)
        return is_whitelisted(pack, force)
    end
})

commands.add_command("razi-rocket-reset-whitelist", "Clear custom starter packs for a force (default: player).", function(cmd)
    local force = cmd.parameter and cmd.parameter ~= "" and cmd.parameter or "player"
    storage.platform_type_whitelist = storage.platform_type_whitelist or {}
    storage.platform_type_whitelist[force] = {}
    debug_log("Reset platform whitelist for " .. force)
end)

local function eligible_platforms(planet, force)
    local candidates, priority = {}, {}
    -- Factorio 2.1 returns built platforms at a given planet.
    for _, platform in pairs(planet.get_space_platforms(force)) do
        local pack = platform.starter_pack
        local allow_all = settings.global["razi-rocket-reusability-allow-modded-platforms"].value
        if (allow_all or not pack or is_whitelisted(pack.name, force.name))
            and platform.hub and platform.hub.valid then
            local surface = platform.surface
            if surface then
                candidates[#candidates + 1] = platform
                for _, beacon in pairs(surface.find_entities_filtered({name = "remnant-beacon"})) do
                    if beacon.valid and (beacon.status == defines.entity_status.working or
                        beacon.status == defines.entity_status.low_power) then
                        priority[#priority + 1] = platform
                        break
                    end
                end
            end
        end
    end
    return candidates, priority
end

local function spawn_wreck(platform)
    local surface = platform.surface
    local distance = settings.global["razi-rocket-reusability-spawn-distance"].value
    -- Restore the published 1.0.7 collision-checking behaviour, absent from GitHub.
    for _ = 1, 12 do
        local position = {x = math.random(-80, 80), y = -distance - math.random(0, 40)}
        if surface.can_place_entity({name = "used-rocket-asteroid", position = position}) then
            if surface.create_entity({name = "used-rocket-asteroid", position = position}) then
                return true
            end
        end
    end
    return false
end

script.on_event(defines.events.on_rocket_launched, function(event)
    local silo = event.rocket_silo
    if not silo or not silo.valid then return end
    local force = silo.force
    if not force.is_space_platforms_unlocked() then return end
    local research = force.technologies["rocket-chunk-processing"]
    if not research or not research.researched then return end
    if math.random() > settings.global["razi-rocket-reusability-recovery-chance"].value then return end

    local planet
    for _, candidate in pairs(game.planets) do
        if candidate.surface == silo.surface then
            planet = candidate
            break
        end
    end
    if not planet then
        debug_log("Rocket launch without an associated planet")
        return
    end

    local candidates, priority = eligible_platforms(planet, force)
    local pool = #priority > 0 and priority or candidates
    if #pool == 0 then
        debug_log("No built platform in orbit of " .. planet.name)
        return
    end
    local target = pool[math.random(#pool)]
    if spawn_wreck(target) then
        debug_log("Wreck spawned near " .. target.name)
    else
        debug_log("No safe wreck position near " .. target.name)
    end
end)
