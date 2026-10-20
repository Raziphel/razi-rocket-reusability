// Regression checks for Krastorio2-spaced-out (2.0.x), vanilla and Muluna-style recipes.
// Requires local RAZI Library checkout, but does NOT pretend to boot Factorio.
const { execute } = require("./test_razilib_integration.js");

function dataStage({ k2so, parts, convertible, incomplete = true, muluna = false }) {
  execute(`
    mods = ${k2so ? (muluna ? '{["Krastorio2-spaced-out"]="2.0.19", Krastorio2="2.1.4", ["planet-muluna"]="2.0.0"}' : '{["Krastorio2-spaced-out"]="2.0.19", Krastorio2="2.1.4"}') : '{}'}
    local rocket_inputs
    if ${convertible} then
      rocket_inputs={
        {type="item",name="processing-unit",amount=4},
        {type="item",name="low-density-structure",amount=2},
        {type="item",name="rocket-fuel",amount=3},
        {type="item",name="kr-steel-beam",amount=1},
      }
    else
      rocket_inputs={
        {type="item",name="kr-steel-beam",amount=4},
        {type="item",name="rocket-fuel",amount=3},
      }
    end
    data={raw={
      item={radar={type="item",name="radar"},["rocket-part"]={type="item",name="rocket-part"}},
      radar={radar={type="radar",name="radar"}},
      ["recipe-category"]=${k2so ? '{["kr-crushing"]={type="recipe-category",name="kr-crushing"}}' : '{}'},
      ["rocket-silo"]={
        ["rocket-silo"]={type="rocket-silo",name="rocket-silo",rocket_parts_required=${parts}}
      },
      recipe={
        ["rocket-part"]={type="recipe",name="rocket-part",ingredients=rocket_inputs,
          maximum_productivity=3,allow_productivity=true,results={{type="item",name="rocket-part",amount=1}}}
      },
      technology={
        ["rocket-silo"]={type="technology",name="rocket-silo",effects={}},
        ["rocket-part-productivity"]={type="technology",name="rocket-part-productivity",
          effects={{type="change-recipe-productivity",recipe="rocket-part",change=0.1}}},
        ["space-science-pack"]={type="technology",name="space-science-pack",
          prerequisites={"kr-research-server"}}
      },
    }}
    function data:extend(entries)
      for _, item in ipairs(entries) do
        self.raw[item.type]=self.raw[item.type] or {}
        assert(not self.raw[item.type][item.name], "duplicate " .. item.name)
        self.raw[item.type][item.name]=item
      end
    end
    util={by_pixel=function(x,y) return {x=x,y=y} end}
    settings={startup={
      ["enable-incomplete-rocket-parts"]={value=${incomplete}},
      ["enable-incomplete-rocket-parts-productivity"]={value=false}
    }}
    assert(load(_load_source("settings.lua")))()
    assert(load(_load_source("data.lua")))()
    assert(load(_load_source("data-final-fixes.lua")))()

    local scrap=data.raw.recipe["rocket-chunk-processing"]
    assert(scrap.categories[1]=="crushing")
    assert(#scrap.categories==${k2so ? 2 : 1})
    if ${k2so} then assert(scrap.categories[2]=="kr-crushing") end
    local parts = ${parts}
    local expected_min = ${k2so ? 'math.max(1,math.min(3,math.floor(parts * 0.06)))' : '3'}
    local expected_max = ${k2so ? 'math.max(expected_min,math.min(10,math.floor(parts * 0.20)))' : '10'}
    local part_recipe=data.raw.recipe["rocket-part"]
    assert(part_recipe.maximum_productivity==3 and part_recipe.allow_productivity)
    assert(data.raw.technology["rocket-part-productivity"].effects[1].change==0.1)
    assert(data.raw.technology["space-science-pack"].prerequisites[1]=="kr-research-server")
    local actual={}
    for _, input in ipairs(part_recipe.ingredients) do actual[input.name]=input.amount end
    assert(actual["rocket-fuel"]==3)
    assert(actual["kr-steel-beam"]==(${convertible} and 1 or 4))
    assert(actual["processing-unit"]==((${convertible} and ${incomplete}) and 2 or (${convertible} and 4 or nil)))
    assert(actual["incomplete-rocket-part"]==((${convertible} and ${incomplete}) and 2 or nil))
    local out_by_name={}
    for _, result in ipairs(scrap.results) do out_by_name[result.name]=result end
    local output=out_by_name[${convertible && incomplete ? '"incomplete-rocket-part"' : '"processing-unit"'}]
    assert(output and output.amount_min==expected_min and output.amount_max==expected_max)
    assert(out_by_name["rocket-chunk"].independent_probability==0.1)
    if not (${convertible} and ${incomplete}) then
      assert(out_by_name["incomplete-rocket-part"]==nil)
      assert(data.raw.technology["rocket-silo"].effects[1]==nil)
    end
    local tech=data.raw.technology["rocket-chunk-processing"]
    local packs={}
    for _, entry in ipairs(tech.unit.ingredients) do packs[entry[1]]=true end
    assert(packs["space-science-pack"] and packs["production-science-pack"] and packs["utility-science-pack"])
    assert(not packs["kr-advanced-tech-card"]) -- no artificial progression skip/gate
  `);
}

dataStage({k2so:false, parts:50, convertible:true});
console.log("PASS: standalone Space Age salvage unaffected");
dataStage({k2so:true, parts:50, convertible:true});
console.log("PASS: K2SO crushing and 50-part rocket launch returns 3-10");
dataStage({k2so:true, parts:12, convertible:true});
console.log("PASS: K2SO 12-part rocket launch returns 1-2");
dataStage({k2so:true, parts:20, convertible:false});
console.log("PASS: K2SO alternate rocket recipe uses craftable fallback returns");

dataStage({k2so:true, parts:50, convertible:true, incomplete:false});
console.log("PASS: K2SO incomplete-parts option disabled leaves rocket ingredients alone");
dataStage({k2so:true, parts:50, convertible:true, muluna:true});
console.log("PASS: K2SO and Muluna can coexist without recipe/property overrides");
