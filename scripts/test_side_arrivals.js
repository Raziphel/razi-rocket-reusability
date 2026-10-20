// Offline 2D asteroid approach tests with the published RAZI Library.
// The mod must also be tested in a running Factorio 2.1 instance.
const {execute} = require("./test_razilib_integration.js");

execute(`
  storage={}
  settings={global={
    ["debug-mode"]={value=false},
    ["razi-rocket-reusability-allow-modded-platforms"]={value=true},
    ["razi-rocket-reusability-spawn-distance"]={value=64},
    ["razi-rocket-reusability-recovery-chance"]={value=1},
    ["razi-rocket-reusability-max-active-wrecks"]={value=3},
    ["razi-rocket-reusability-side-arrivals"]={value=false},
    ["razi-rocket-reusability-side-arrival-chance"]={value=35},
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
  local output={}
  local hull={{position={x=-130,y=-12}}, {position={x=185,y=-12}},
              {position={x=0,y=-198}}, {position={x=-5,y=0}}, {position={x=5,y=0}}}
  local active_wrecks=0
  local blocked_side=nil
  local hull_overlap_side=nil
  local side_roll=1
  local side_open=true
  local desired_side=1
  local surface={
    count_entities_filtered=function()return active_wrecks end,
    find_entities_filtered=function()return {}end,
    find_tiles_filtered=function(query)
      if query.limit and hull_overlap_side=="left" and query.area[1][1]< -120 then
        return {{position={x=query.area[1][1]+1,y=query.area[1][2]+1}}}
      end
      if not side_open and query.area[1][1] <= -512 then return {} end
      local result={}
      for _,tile in ipairs(hull) do
        local x,y=tile.position.x,tile.position.y
        if x>=query.area[1][1] and x<=query.area[2][1]
          and y>=query.area[1][2] and y<=query.area[2][2] then
          result[#result+1]=tile
          if query.limit and #result>=query.limit then return result end
        end
      end
      return result
    end,
    can_place_entity=function(args)
      if blocked_side=="both" and math.abs(args.position.x)>120 then return false end
      if blocked_side=="left" and args.position.x< -150 then return false end
      return true
    end,
    create_entity=function(args)
      assert(args.name=="used-rocket-asteroid")
      local norm=math.sqrt(args.velocity.x^2+args.velocity.y^2)
      assert(norm>=0.034 and norm<=0.04501)
      output[#output+1]=args
      return {}
    end
  }
  local ground={}
  local platform={name="test",speed=0,hub={valid=true,position={x=0,y=0}},surface=surface}
  local planet={name="nauvis",surface=ground,get_space_platforms=function()return {platform}end}
  game={planets={planet}}
  local force={name="player",technologies={["rocket-chunk-processing"]={researched=true}},
    is_space_platforms_unlocked=function()return true end}
  local original_random=math.random
  math.random=function(a,b)
    if not a then return 0.0 end  -- Recovery chance succeeds.
    if a==100 then return side_roll end   -- Side selection probability succeeds.
    if a==2 and not b then return desired_side end
    if a==1 and not b then return 1 end
    if b then return a end         -- Consistent offsets and lateral candidates.
    return 1
  end

  assert(load(_load_source("control.lua")))()
  handlers.init()
  local fire=function()handlers[42]({rocket_silo={valid=true,force=force,surface=ground}})end
  local take=function()
    local item=output[#output]
    assert(item)
    return item
  end
  local function is_front(item)
    return item.velocity.x==0 and item.velocity.y==0.035 and item.position.y<-210
  end

  -- Default OFF must preserve previous front approach.
  fire()
  assert(#output==1 and is_front(take()))

  -- Left approach clears irregular 130-wide wing and targets the hub.
  settings.global["razi-rocket-reusability-side-arrivals"].value=true
  settings.global["razi-rocket-reusability-side-arrival-chance"].value=100
  desired_side=1
  fire()
  assert(#output==2)
  local left=take()
  assert(left.position.x<= -194 and left.velocity.x>0 and left.velocity.y>0)
  local time_to_center=(0-left.position.x)/left.velocity.x
  assert(math.abs(left.position.y+time_to_center*left.velocity.y+2)<0.001)

  -- Right approach clears asymmetric 185-wide wing. No front-only bias.
  desired_side=2
  fire()
  assert(#output==3)
  local right=take()
  assert(right.position.x>=249 and right.velocity.x<0 and right.velocity.y>0)
  local right_time=(0-right.position.x)/right.velocity.x
  assert(math.abs(right.position.y+right_time*right.velocity.y+2)<0.001)

  -- 0% immediately returns to front-only without recreating/modifying save.
  settings.global["razi-rocket-reusability-side-arrival-chance"].value=0
  fire()
  assert(#output==4 and is_front(take()))

  -- If chosen left is blocked, right-side retries still deliver a wreck.
  settings.global["razi-rocket-reusability-side-arrival-chance"].value=100
  desired_side=1
  blocked_side="left"
  fire()
  assert(#output==5 and take().velocity.x<0)
  blocked_side="both"

  -- Both side lanes unusable: original front spawn remains reliable.
  fire()
  assert(#output==6 and is_front(take()))
  blocked_side=nil

  -- A real foundation overlap must block the left even if can_place_entity
  -- mistakenly reports success, and should safely retry the right lane.
  hull_overlap_side="left"
  fire()
  assert(#output==7 and take().velocity.x<0)
  hull_overlap_side=nil

  -- No clear side boundary => graceful front fallback.
  side_open=false
  fire()
  assert(#output==8 and is_front(take()))
  side_open=true

  -- A side-scan safety limit prevents wide/unknown hull overlaps.
  hull[#hull+1]={position={x=-505,y=0}}
  fire()
  assert(#output==9 and is_front(take()))
  hull[#hull]=nil

  -- Existing capacity cap still applies to BOTH arrival paths.
  active_wrecks=3
  fire()
  assert(#output==9)
  active_wrecks=0

  -- Disable harder arrivals mid-game: default front-only is restored.
  settings.global["razi-rocket-reusability-side-arrivals"].value=false
  fire()
  assert(#output==10 and is_front(take()))

  -- Chance is a conditional percentage, with exact boundary behavior.
  settings.global["razi-rocket-reusability-side-arrivals"].value=true
  settings.global["razi-rocket-reusability-side-arrival-chance"].value=35
  desired_side=2
  side_roll=35
  fire()
  assert(#output==11 and take().velocity.x<0)
  side_roll=36
  fire()
  assert(#output==12 and is_front(take()))

  math.random=original_random
`);
console.log("PASS: side mode opt-in, left/right heading, asymmetric hull clearance");
console.log("PASS: live chance 0/100, unsafe-side fallback, width guard, capacity limit");
