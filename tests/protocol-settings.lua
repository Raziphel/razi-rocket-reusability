-- Factorio-free regression checks: lua tests/protocol-settings.lua
package.path="./?.lua;./?/init.lua;"..package.path
local bridge=require("runtime.razi-protocol-settings")
local source="razi-rocket-reusability-side-arrivals"
local store={value={}}
function store:get(key,default)
 local found=self.value[key]
 return found==nil and default or found
end
function store:set(key,value) self.value[key]=value end
local startup={["razi-difficulty-preset"]={value="normal"}}
local map={[source]={value=false}}
local function run(mode)
 if mode~=nil then startup["razi-difficulty-preset"]={value=mode} end
 return bridge.sync(startup,map,store)
end
assert(not run("normal"),"Normal should not change source setting")
assert(run("hard"),"Hard should change the real source setting")
assert(map[source].value==true,"Hard must be visibly enabled")
assert(store.value.protocol_side_arrivals_policy.original==false,"original choice lost")
assert(not run("hard"),"same preset should be idempotent")
map[source]={value=false}
assert(run("nightmare"),"Nightmare should re-enable after user changes checkbox")
assert(map[source].value==true,"Nightmare not enforced")
assert(run("easy"),"Easy should restore original unchecked state")
assert(map[source].value==false,"Easy didn't restore user choice")
map[source]={value=true}
assert(not run("normal"),"Normal respects manual side approaches")
assert(not run("hard"),"Already-on manual state remains on")
assert(not run("custom"),"Custom retains previously checked state")
assert(map[source].value==true,"Custom manual override lost")
assert(not run("hard"),"Hard remains enabled")
startup["razi-difficulty-preset"]=nil
assert(not run(),"Standalone should restore manual selection")
assert(map[source].value==true,"Standalone should preserve chosen true")
print("Rocket Reusability Protocol settings bridge: PASS")
