-- Factorio 2.1 maintenance of redplasticstraw's Rocket Reusability.
-- Existing prototype names and interface are preserved for save compatibility.
local Events = require("__razi_lib__/runtime/events")
local Storage = require("__razi_lib__/runtime/storage")
local Remote = require("__razi_lib__/runtime/remote")
local Settings = require("__razi_lib__/lib/settings")
local SideArrivals = require("runtime/side-arrivals")
local ProtocolSettings = require("runtime/razi-protocol-settings")

local state = Storage.namespace("razi_rocket_reusability", { platform_type_whitelist = {} })
local events = Events.new()
local DEFAULT_PACK = "space-platform-starter-pack"

local function debug_log(message)
    if Settings.enabled("debug-mode", false, "runtime-global") then log("[razi-rocket-reusability] " .. message) end
end

local function whitelist_for(force)
    local all = state:get("platform_type_whitelist", {})
    all[force] = all[force] or {}
    return all[force]
end

local function is_whitelisted(pack, force)
    return pack == DEFAULT_PACK or whitelist_for(force or "player")[pack] == true
end

local function prepare_state()
    state:ensure()
    -- Upgrade earlier saves storing per-force whitelists at the storage root.
    local legacy = storage.platform_type_whitelist
    if type(legacy) ~= "table" then return end
    local all = state:get("platform_type_whitelist", {})
    for force, allowed in pairs(legacy) do
        if type(allowed) == "table" then
            all[force] = all[force] or {}
            for _, pack in ipairs(allowed) do
                if type(pack) == "string" then all[force][pack] = true end
            end
            for pack, enabled in pairs(allowed) do
                if type(pack) == "string" and enabled == true then
                    all[force][pack] = true
                end
            end
        end
    end
    state:set("platform_type_whitelist", all)
    -- Clear only after successful migration; removed packs must stay removed.
    storage.platform_type_whitelist = nil
end

events:on_init(prepare_state):on_configuration_changed(prepare_state)

Remote.add_interface("razi-rocket-reusability", {
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
    whitelist_for(force)
    state:get("platform_type_whitelist")[force] = {}
    debug_log("Reset platform whitelist for " .. force)
end)

local function eligible_platforms(planet, force)
    local candidates, priority = {}, {}
    -- Factorio 2.1 returns built platforms at a given planet.
    for _, platform in pairs(planet.get_space_platforms(force)) do
        local pack = platform.starter_pack
        local allow_all = Settings.enabled("razi-rocket-reusability-allow-modded-platforms", true, "runtime-global")
        if (allow_all or not pack or is_whitelisted(pack.name, force.name))
            and platform.hub and platform.hub.valid then
            local surface = platform.surface
            if surface then
                candidates[#candidates + 1] = platform
                for _, beacon in pairs(surface.find_entities_filtered({name = "remnant-beacon"})) do
                    if beacon.valid and beacon.status == defines.entity_status.working then
                        priority[#priority + 1] = platform
                        break
                    end
                end
            end
        end
    end
    return candidates, priority
end

local function spawn_front_wreck(platform)
    local surface, hub = platform.surface, platform.hub
    -- Work relative to the hub, not absolute space coordinates.
    local center = hub.position
    local distance = Settings.value("razi-rocket-reusability-spawn-distance", 64, "runtime-global")
    local northernmost = center.y

    -- An unusually long ship may stretch beyond the nominal spawning lane.
    -- Keep the 18x18 wreck fully ahead of actual platform foundation tiles.
    local tiles = surface.find_tiles_filtered({
        name = "space-platform-foundation",
        area = {{center.x - 24, center.y - 256}, {center.x + 24, center.y + 4}},
    })
    for _, tile in pairs(tiles) do
        if tile.position.y < northernmost then northernmost = tile.position.y end
    end

    local y = math.min(center.y - distance, northernmost - 18)
    for _ = 1, 12 do
        local position = {
            x = center.x + math.random(-8, 8),
            y = y - math.random(0, 12),
        }
        -- can_place_entity alone is not a sufficient platform-floor check.
        local hull = surface.find_tiles_filtered({
            name = "space-platform-foundation",
            area = {{position.x - 10, position.y - 10}, {position.x + 10, position.y + 10}},
            limit = 1,
        })
        if #hull == 0 and
            surface.can_place_entity({name = "used-rocket-asteroid", position = position}) then
            -- Explicit positive Y movement is essential for stationary platforms.
            local wreck = surface.create_entity({
                name = "used-rocket-asteroid",
                position = position,
                velocity = {x = 0, y = 0.035},
            })
            if wreck then return true end
        end
    end
    return false
end

-- Razi Protocol cannot write another mod's saved settings. This owning mod
-- can synchronize its OWN Map settings after the map starts, via native Lua.
-- Until the first scheduled sync, this read maintains Hard/Nightmare behaviour.
-- Standalone, Easy, Normal and Custom keep their saved manual preferences.
local function side_arrivals_enabled()
    local manual = Settings.enabled("razi-rocket-reusability-side-arrivals", false, "runtime-global")
    local protocol = settings.startup["razi-difficulty-preset"]
    local preset = protocol and protocol.value
    return manual or preset == "hard" or preset == "nightmare"
end

-- Side approaches are an opt-in challenge. Their probability is conditional
-- on the existing recovery roll, so they never add extra wrecks per launch.
local function spawn_wreck(platform)
    if side_arrivals_enabled() then
        local chance = Settings.value("razi-rocket-reusability-side-arrival-chance", 35, "runtime-global")
        if chance > 0 and math.random(100) <= chance then
            local spawned, side = SideArrivals.try_spawn(platform,
                Settings.value("razi-rocket-reusability-spawn-distance", 64, "runtime-global"))
            if spawned then return true, side end
            debug_log("Side lanes unsafe on " .. platform.name .. "; attempting normal front arrival")
        end
    end
    return spawn_front_wreck(platform), "front"
end

events:on_event(defines.events.on_rocket_launched, function(event)
    local silo = event.rocket_silo
    if not silo or not silo.valid then return end
    local force = silo.force
    if not force.is_space_platforms_unlocked() then return end
    local research = force.technologies["rocket-chunk-processing"]
    if not research or not research.researched then return end
    if math.random() > Settings.value("razi-rocket-reusability-recovery-chance", 1, "runtime-global") then return end

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
    local max_wrecks = Settings.value("razi-rocket-reusability-max-active-wrecks", 3, "runtime-global")
    local function below_limit(platform)
        return platform.surface.count_entities_filtered({
            name = "used-rocket-asteroid",
            limit = max_wrecks,
        }) < max_wrecks
    end
    local preferred, fallback = {}, {}
    for _, platform in ipairs(priority) do
        if below_limit(platform) then preferred[#preferred + 1] = platform end
    end
    if #preferred == 0 then
        for _, platform in ipairs(candidates) do
            if below_limit(platform) then fallback[#fallback + 1] = platform end
        end
    end
    local pool = #preferred > 0 and preferred or fallback
    if #pool == 0 then
        debug_log("No available platform in orbit of " .. planet.name .. " (all busy or none built)")
        return
    end
    local target = pool[math.random(#pool)]
    local spawned, approach = spawn_wreck(target)
    if spawned then
        debug_log("Wreck approaching " .. target.name .. " from the " .. approach)
    else
        debug_log("No safe wreck position near " .. target.name)
    end
end)

events:install()

-- One check each second, not every tick. This writes only OUR OWN
-- runtime-global side-arrivals setting. In Hard/Nightmare the actual
-- Mod Settings > Map checkbox becomes On; after leaving those modes
-- the previously saved manual checkbox is restored. Never touch the
-- other mods' values, startup settings, or on_load game state.
script.on_nth_tick(60, function()
    ProtocolSettings.sync(settings.startup, settings.global, state)
end)
