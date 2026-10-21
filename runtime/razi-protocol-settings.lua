-- Source-owned native Factorio Map setting synchronization.
-- Razi Protocol itself CANNOT assign settings owned by this mod. As the
-- setting owner, Rocket Reusability can update its own runtime-global values.
-- Startup settings, cosmetic controls and third-party settings are untouched.
local M={}
local POLICY_KEY="protocol_owned_settings_policy"
local LEGACY_KEY="protocol_side_arrivals_policy"
local SIDE="razi-rocket-reusability-side-arrivals"

-- All values are actual runtime-global setting IDs registered in settings.lua,
-- within the exact permitted bounds for those prototypes.
M.profiles={
    hard={
        ["razi-rocket-reusability-recovery-chance"]=0.90,
        ["razi-rocket-reusability-spawn-distance"]=56,
        ["razi-rocket-reusability-max-active-wrecks"]=4,
        [SIDE]=true,
        ["razi-rocket-reusability-side-arrival-chance"]=55,
    },
    nightmare={
        ["razi-rocket-reusability-recovery-chance"]=0.75,
        ["razi-rocket-reusability-spawn-distance"]=44,
        ["razi-rocket-reusability-max-active-wrecks"]=6,
        [SIDE]=true,
        ["razi-rocket-reusability-side-arrival-chance"]=80,
    },
}

-- Keep a saved pre-preset preference once per setting. The old 1.1.7
-- side-arrivals snapshot is migrated so existing saves never lose it.
local function snapshot(state, global_settings)
    local previous=state:get(POLICY_KEY,nil)
    if previous and previous.active then return previous end
    local originals={}
    local legacy=state:get(LEGACY_KEY,nil)
    if legacy and legacy.active then originals[SIDE]=legacy.original==true end
    for setting in pairs(M.profiles.hard) do
        local owned=global_settings and global_settings[setting]
        if owned and originals[setting]==nil then
            originals[setting]=owned.value
        end
    end
    local result={active=true,originals=originals}
    state:set(POLICY_KEY,result)
    if legacy and legacy.active then state:set(LEGACY_KEY,{active=false}) end
    return result
end

local function restore(state, global_settings)
    local previous=state:get(POLICY_KEY,nil)
    local legacy=state:get(LEGACY_KEY,nil)
    -- Upgrade or rollback directly from the 1.1.7 bridge.
    if (not previous or not previous.active) and legacy and legacy.active then
        previous={active=true,originals={[SIDE]=legacy.original==true}}
    end
    if not previous or not previous.active then return false end
    -- Mark inactive FIRST to avoid overwriting old manual preferences if an
    -- unrelated event runs after a change notification.
    state:set(POLICY_KEY,{active=false})
    if legacy and legacy.active then state:set(LEGACY_KEY,{active=false}) end
    local modified=false
    for name,value in pairs(previous.originals or {}) do
        local owned=global_settings and global_settings[name]
        if owned and owned.value~=value then
            global_settings[name]={value=value}
            modified=true
        end
    end
    return modified
end

function M.sync(startup,global_settings,state)
    local setting=startup and startup["razi-difficulty-preset"]
    local selected=setting and setting.value
    local profile=M.profiles[selected]
    if not profile then return restore(state,global_settings) end
    snapshot(state,global_settings)
    local modified=false
    for name,value in pairs(profile) do
        local owned=global_settings and global_settings[name]
        if owned and owned.value~=value then
            -- Allowed only because these settings belong to THIS mod.
            global_settings[name]={value=value}
            modified=true
        end
    end
    return modified
end

return M
