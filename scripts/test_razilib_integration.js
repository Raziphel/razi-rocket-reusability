// Offline Lua smoke tests against a checked-out RAZI Library (v1.2.0+).
// Run: npm install --prefix .tools --no-save fengari luaparse
//      node scripts/test_razilib_integration.js /path/to/RaziLib
// This is NOT an in-engine Factorio prototype validation.
const fs = require("node:fs");
const path = require("node:path");
const { lua, lauxlib, lualib, to_luastring, to_jsstring } =
  require("../.tools/node_modules/fengari");

const root = path.resolve(__dirname, "..");
const lib = path.resolve(process.argv[2] || "../razilib-reference");
const source = (name) => {
  if (name.startsWith("__razi_lib__/")) return fs.readFileSync(path.join(lib, name.slice(13) + ".lua"), "utf8");
  if (name.startsWith("__space-age__")) {
    if (name.endsWith("explosion-animations")) return "return { asteroid_explosion_chunk = function() return {} end }";
    return "return {}";
  }
  return fs.readFileSync(path.join(root, name + (name.endsWith(".lua") ? "" : ".lua")), "utf8");
};

function execute(body) {
  const L = lauxlib.luaL_newstate();
  lualib.luaL_openlibs(L);
  lua.lua_pushjsfunction(L, state => {
    const name = to_jsstring(lua.lua_tostring(state, 1));
    try {
      lua.lua_pushstring(state, to_luastring(source(name)));
      return 1;
    } catch (error) {
      return lauxlib.luaL_error(state, to_luastring(String(error)));
    }
  });
  lua.lua_setglobal(L, to_luastring("_load_source"));
  const script = `
    local cache = {}
    function require(name)
      if cache[name] then return cache[name] end
      local fn, err = load(_load_source(name), "@" .. name)
      assert(fn, err)
      local result = fn()
      cache[name] = result or true
      return cache[name]
    end
    ` + body;
  const result = lauxlib.luaL_dostring(L, to_luastring(script));
  if (result !== lua.LUA_OK) {
    const message = to_jsstring(lua.lua_tostring(L, -1));
    throw new Error(message);
  }
}

for (const incomplete of [true, false]) {
  execute(`
    data = { raw = {
      item = { radar = {type="item",name="radar"}, ["rocket-part"] = {type="item",name="rocket-part",hidden=true} },
      radar = { radar = {type="radar",name="radar"} },
      recipe = { ["rocket-part"] = {type="recipe", name="rocket-part",
        ingredients={{type="item",name="processing-unit",amount=2},
                     {type="item",name="low-density-structure",amount=2},
                     {type="item",name="rocket-fuel",amount=2}},
        maximum_productivity=3,allow_productivity=true,results={{type="item",name="rocket-part",amount=1}}} },
      technology = {
        ["rocket-silo"] = {type="technology",name="rocket-silo",effects={}},
        ["rocket-part-productivity-muluna"] = {type="technology",name="rocket-part-productivity-muluna",
          effects={{type="change-recipe-productivity",recipe="rocket-part",change=0.1}}}
      }
    }}
    function data:extend(entries)
      for _, e in ipairs(entries) do
        self.raw[e.type] = self.raw[e.type] or {}
        assert(not self.raw[e.type][e.name], "duplicate prototype " .. e.name)
        self.raw[e.type][e.name] = e
      end
    end
    util = { by_pixel = function(x,y) return {x=x,y=y} end }
    settings = {startup={
      ["enable-incomplete-rocket-parts"]={value=${incomplete}},
      ["enable-incomplete-rocket-parts-productivity"]={value=false}
    }}
    local fn=assert(load(_load_source("settings.lua"))); fn()
    fn=assert(load(_load_source("data.lua"))); fn()
    fn=assert(load(_load_source("data-final-fixes.lua"))); fn()
    assert(data.raw.radar["remnant-beacon"])
    assert(data.raw.recipe["rocket-chunk-processing"])
    assert(data.raw["asteroid-chunk"]["rocket-chunk"])
    assert(data.raw["double-setting"]["razi-rocket-reusability-recovery-chance"])
    assert(data.raw.recipe["rocket-chunk-processing"].categories[1] == "crushing")
    assert((data.raw.item["incomplete-rocket-part"] ~= nil) == ${incomplete})
    local rocket=data.raw.recipe["rocket-part"]
    assert(rocket.maximum_productivity==3 and rocket.allow_productivity)
    local bonuses=data.raw.technology["rocket-part-productivity-muluna"].effects
    assert(#bonuses==1 and bonuses[1].recipe=="rocket-part" and bonuses[1].change==0.1)
    assert(#rocket.ingredients == (${incomplete} and 2 or 3))
    local fuel,parts,processor=0,0,0
    for _, ingredient in pairs(rocket.ingredients) do
      if ingredient.name=="rocket-fuel" then fuel=ingredient.amount end
      if ingredient.name=="incomplete-rocket-part" then parts=ingredient.amount end
      if ingredient.name=="processing-unit" then processor=ingredient.amount end
    end
    assert(fuel==2 and parts==(${incomplete} and 2 or 0) and processor==(${incomplete} and 0 or 2))
  `);
  console.log("PASS: RAZI Library data stage (incomplete parts " + incomplete + ")");
}

execute(`
  storage = {platform_type_whitelist={player={["old-pack"]=true,"legacy-pack"}}}
  settings={global={
    ["debug-mode"]={value=false},
    ["razi-rocket-reusability-allow-modded-platforms"]={value=true},
    ["razi-rocket-reusability-spawn-distance"]={value=64},
    ["razi-rocket-reusability-recovery-chance"]={value=1}
  }}
  local handlers={}
  script={
    on_init=function(cb) handlers.init=cb end,
    on_configuration_changed=function(cb) handlers.config=cb end,
    on_event=function(id,cb) handlers[id]=cb end
  }
  remote={interfaces={},add_interface=function(name,methods) remote.interfaces[name]=methods end}
  commands={add_command=function()end}
  defines={events={on_rocket_launched=42},entity_status={working=1,low_power=2}}
  log=function() end
  local fn=assert(load(_load_source("control.lua"))); fn()
  assert(handlers.init and handlers.config and handlers[42])
  handlers.init()
  assert(storage.platform_type_whitelist == nil)
  local api=remote.interfaces["razi-rocket-reusability"]
  assert(api and api.is_whitelisted("old-pack","player"))
  assert(api.is_whitelisted("legacy-pack","player"))
  assert(api.remove_whitelist("old-pack","player"))
  handlers.config()
  assert(not api.is_whitelisted("old-pack","player"))
  local spawned=0
  local orbit={
    find_entities_filtered=function() return {} end,
    count_entities_filtered=function() return 0 end,
    find_tiles_filtered=function() return {} end,
    can_place_entity=function() return true end,
    create_entity=function(args)
      assert(args.velocity and args.velocity.y>0)
      assert(args.position.y < -32)
      spawned=spawned+1
      return {}
    end
  }
  local platform={name="test",hub={valid=true,position={x=0,y=0}},surface=orbit,speed=0}
  local ground={}
  local planet={name="nauvis",surface=ground,get_space_platforms=function()return {platform}end}
  game={planets={planet}}
  local force={name="player",technologies={["rocket-chunk-processing"]={researched=true}},
    is_space_platforms_unlocked=function()return true end}
  handlers[42]({rocket_silo={valid=true,force=force,surface=ground}})
  assert(spawned==1)
`);
console.log("PASS: RAZI Library runtime events, storage migration, remote API, stationary spawn");

module.exports = { execute };
