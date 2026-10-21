-- Run: lua tests/protocol-settings.lua
package.path="./?.lua;./?/init.lua;"..package.path
local bridge=require("runtime.razi-protocol-settings")
local store={values={}}
function store:get(key,default)
    local value=self.values[key]
    return value==nil and default or value
end
function store:set(key,value) self.values[key]=value end
local parent={["razi-difficulty-preset"]={value="normal"}}
local map={
 ["razi-rocket-reusability-recovery-chance"]={value=1},
 ["razi-rocket-reusability-spawn-distance"]={value=64},
 ["razi-rocket-reusability-max-active-wrecks"]={value=3},
 ["razi-rocket-reusability-side-arrivals"]={value=false},
 ["razi-rocket-reusability-side-arrival-chance"]={value=35},
 ["razi-rocket-reusability-allow-modded-platforms"]={value=false},
 debug_mode={value=true},
}
local original={}
for k,entry in pairs(map) do original[k]=entry.value end
local function set_mode(mode)
    parent["razi-difficulty-preset"]=mode and {value=mode} or nil
    return bridge.sync(parent,map,store)
end
local function check(mode)
    local profile=bridge.profiles[mode]
    for name,value in pairs(profile) do
        assert(map[name].value==value,mode..": "..name.." expected "..tostring(value))
    end
end
assert(not set_mode("normal"))
assert(set_mode("hard"),"Hard must update native settings")
check("hard")
assert(store.values.protocol_owned_settings_policy.originals["razi-rocket-reusability-side-arrivals"]==false)
assert(not set_mode("hard"),"same preset must be idempotent")
map["razi-rocket-reusability-recovery-chance"]={value=0.1}
assert(set_mode("hard"),"manually changed hard value should be re-enforced")
check("hard")
assert(set_mode("nightmare"),"nightmare must update values")
check("nightmare")
assert(not set_mode("nightmare"),"nightmare stable")
assert(map["razi-rocket-reusability-allow-modded-platforms"].value==false)
assert(map.debug_mode.value==true)
assert(set_mode("custom"),"Custom must restore original settings")
for name,value in pairs(original) do
    assert(map[name].value==value,"restore "..name)
end
assert(not set_mode("easy"),"Easy respects manual preferences")
map["razi-rocket-reusability-side-arrivals"]={value=true}
map["razi-rocket-reusability-recovery-chance"]={value=0.4}
assert(set_mode("hard"))
check("hard")
assert(set_mode("normal"))
assert(map["razi-rocket-reusability-side-arrivals"].value==true,
    "manual true should survive transition")
assert(map["razi-rocket-reusability-recovery-chance"].value==0.4,
    "manual recovery chance should survive transition")
-- Save migration: the pre-1.1.8 bridge had a one-setting snapshot.
store.values.protocol_owned_settings_policy=nil
store.values.protocol_side_arrivals_policy={active=true,original=false}
map["razi-rocket-reusability-side-arrivals"]={value=true}
assert(set_mode("normal"),"migration must restore original side checkbox")
assert(map["razi-rocket-reusability-side-arrivals"].value==false)
store.values.protocol_owned_settings_policy=nil
store.values.protocol_side_arrivals_policy={active=true,original=true}
map["razi-rocket-reusability-side-arrivals"]={value=true}
assert(set_mode("nightmare"))
check("nightmare")
assert(set_mode(nil),"standalone mode must restore prior choices")
assert(map["razi-rocket-reusability-side-arrivals"].value==true)
assert(not set_mode(nil),"standalone idempotent")
print("Native Rocket Reusability 5-setting difficulty bridge: PASS")
