-- Native Razi Protocol integration for the owner's own runtime setting.
-- This module intentionally knows only settings that belong to our mod:
-- Factorio forbids a mod from writing another mod's Mod Settings values.
local M={}
local SETTING="razi-rocket-reusability-side-arrivals"
local KEY="protocol_side_arrivals_policy"

function M.sync(startup, global_settings, state)
    local own=global_settings and global_settings[SETTING]
    if not own then return false end
    local parent=startup and startup["razi-difficulty-preset"]
    local selected=parent and parent.value
    local enforce=selected=="hard" or selected=="nightmare"
    local remembered=state:get(KEY, nil)

    if enforce then
        -- Snapshot the player's original choice once, so this mod can return
        -- to their configuration when Protocol no longer forces harder wrecks.
        if not remembered or not remembered.active then
            state:set(KEY, {active=true, original=own.value==true})
        end
        if own.value~=true then
            global_settings[SETTING]={value=true}
            return true
        end
    elseif remembered and remembered.active then
        -- Easy, Normal, Custom and standalone games never keep a stale
        -- Hard/Nightmare-enforced value.
        local original=remembered.original==true
        state:set(KEY, {active=false})
        if own.value~=original then
            global_settings[SETTING]={value=original}
            return true
        end
    end
    return false
end

return M
