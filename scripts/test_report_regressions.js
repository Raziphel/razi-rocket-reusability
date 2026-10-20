// Additional 2.1 regression cases taken from original Mod Portal reports.
const { execute } = require("./test_razilib_integration.js");

execute(`
  data = {raw = {
    item = {radar={type="item",name="radar"},["rocket-part"]={type="item",name="rocket-part",hidden=true}},
    radar={radar={type="radar",name="radar"}},
    recipe={["rocket-part"]={type="recipe",name="rocket-part",
      categories={"rocket-building"}, maximum_productivity=2.75, allow_productivity=true,
      surface_conditions={{property="gravity",min=1,max=100}},
      ingredients={
        {type="item",name="processing-unit",amount=3},
        {type="item",name="low-density-structure",amount=2},
        {type="item",name="rocket-fuel",amount=2},
        {type="item",name="steel-plate",amount=1}
      }, results={{type="item",name="rocket-part",amount=1}}}},
    technology={["rocket-silo"]={type="technology",name="rocket-silo",effects={}},
      ["muluna-bonus"]={type="technology",name="muluna-bonus",
        effects={{type="change-recipe-productivity",recipe="rocket-part",change=0.2}}}}
  }}
  function data:extend(entries)
    for _, e in ipairs(entries) do
      self.raw[e.type]=self.raw[e.type] or {}
      assert(not self.raw[e.type][e.name])
      self.raw[e.type][e.name]=e
    end
  end
  util={by_pixel=function(x,y)return{x=x,y=y}end}
  settings={startup={
    ["enable-incomplete-rocket-parts"]={value=true},
    ["enable-incomplete-rocket-parts-productivity"]={value=false}
  }}
  assert(load(_load_source("settings.lua")))()
  assert(load(_load_source("data.lua")))()
  assert(load(_load_source("data-final-fixes.lua")))()
  local r=data.raw.recipe["rocket-part"]
  assert(r.maximum_productivity==2.75 and r.allow_productivity)
  assert(r.categories[1]=="rocket-building" and r.surface_conditions[1].max==100)
  local have={}
  for _, input in ipairs(r.ingredients) do have[input.name]=input.amount end
  assert(have["incomplete-rocket-part"]==2)
  assert(have["processing-unit"]==1)
  assert(have["low-density-structure"]==nil)
  assert(have["rocket-fuel"]==2 and have["steel-plate"]==1)
  assert(data.raw.technology["muluna-bonus"].effects[1].change==0.2)
`);
console.log("PASS: Muluna-style recipe, existing multipliers and productivity effects preserved");

execute(`
  storage={}
  settings={global={
    ["debug-mode"]={value=false},
    ["razi-rocket-reusability-allow-modded-platforms"]={value=true},
    ["razi-rocket-reusability-spawn-distance"]={value=64},
    ["razi-rocket-reusability-recovery-chance"]={value=1}
  }}
  local handlers={}
  script={
    on_init=function(cb)handlers.init=cb end,
    on_configuration_changed=function(cb)handlers.config=cb end,
    on_event=function(id,cb)handlers[id]=cb end,
  }
  remote={interfaces={},add_interface=function(name,methods)remote.interfaces[name]=methods end}
  commands={add_command=function()end}
  defines={events={on_rocket_launched=42},entity_status={working=1,low_power=2}}
  log=function()end
  assert(load(_load_source("control.lua")))()
  handlers.init()
  local chosen={}
  local ground={}
  local beacon_mode="working"
  local allow_positions=true
  local active_wrecks=0
  local tiles={{position={x=28,y=-140}}}
  local orbit={
    find_entities_filtered=function()return {}end,
    count_entities_filtered=function()return active_wrecks end,
    find_tiles_filtered=function(filter)
      if filter.area[2][2]>0 then return tiles end
      return allow_positions and {} or {tiles[1]}
    end,
    can_place_entity=function()return allow_positions end,
    create_entity=function(args)
      chosen[#chosen+1]=args
      return {}
    end
  }
  local orbit2={
    find_entities_filtered=function()
      return {{valid=true,status=beacon_mode=="working" and 1 or 2}}
    end,
    count_entities_filtered=function()return 0 end,
    find_tiles_filtered=function()return {}end,
    can_place_entity=function()return true end,
    create_entity=function(args)chosen[#chosen+1]=args;return {}end
  }
  local stationary={name="stationary",speed=0,hub={valid=true,position={x=30,y=10}},
                    surface=orbit}
  local prioritized={name="beacon platform",speed=0,hub={valid=true,position={x=10,y=0}},
                     surface=orbit2}
  local candidates={stationary,prioritized}
  local planet={name="muluna",surface=ground,get_space_platforms=function()return candidates end}
  game={planets={planet}}
  local force={name="player",technologies={["rocket-chunk-processing"]={researched=true}},
    is_space_platforms_unlocked=function()return true end}
  local fire=function() handlers[42]({rocket_silo={valid=true,force=force,surface=ground}}) end
  -- Working beacon takes precedence, even with another eligible platform.
  fire()
  assert(#chosen==1 and chosen[1].position.x<=18)
  -- Low power is not sufficient; use the one remaining eligible platform.
  beacon_mode="low"
  candidates={stationary}
  fire()
  assert(#chosen==2)
  assert(chosen[2].position.x>=22 and chosen[2].position.x<=38)
  assert(chosen[2].position.y<=-158) -- 18 tiles before the forward hull edge
  assert(chosen[2].velocity.y>0)
  -- Blocked spawn must never create a wreck inside platform tiles.
  allow_positions=false
  fire()
  assert(#chosen==2)
  -- Reaching a per-platform cap prevents infinite wreck accumulation.
  allow_positions=true
  active_wrecks=3
  fire()
  assert(#chosen==2)
  active_wrecks=0
  -- No platform cannot generate a wreck in an unrelated orbit.
  candidates={}
  fire()
  assert(#chosen==2)
`);
console.log("PASS: beacon priority, stationary movement, hull safety, capacity cap");
