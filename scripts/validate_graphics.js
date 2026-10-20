#!/usr/bin/env node
// Check the gentle asset pass has not changed original geometry or alpha.
const fs=require("node:fs");
const path=require("node:path");
const {execFileSync}=require("node:child_process");
const {PNG}=require("../.tools/node_modules/pngjs");
const root=path.resolve(__dirname,"..");
const baseline="1bebdfc3961484738c1f5e09591de820c9cea69d";
const files=[
"thumbnail.png",
"graphics/icons/incomplete-rocket-part.png",
"graphics/icons/remnant-beacon-technology.png",
"graphics/icons/remnant-beacon.png",
"graphics/icons/rocket-chunk-crushing.png",
"graphics/icons/rocket-chunk.png",
"graphics/icons/rocket-reusability-research.png",
"graphics/icons/used-rocket-icon.png",
"graphics/asteroid/rocket-chunk.png",
];
let changedPixels=0;
for(const file of files){
  const old=PNG.sync.read(execFileSync("git",["show",baseline+":"+file],{cwd:root,maxBuffer:4*1024*1024}));
  const current=PNG.sync.read(fs.readFileSync(path.join(root,file)));
  if(old.width!==current.width||old.height!==current.height)throw Error(file+": dimensions changed");
  let delta=0, pixels=0;
  for(let i=0;i<old.data.length;i+=4){
    if(old.data[i+3]!==current.data[i+3])throw Error(file+": silhouette/alpha changed");
    for(let j=0;j<3;j++){
      const diff=Math.abs(old.data[i+j]-current.data[i+j]);
      if(diff>14)throw Error(file+": RGB edit too aggressive: "+diff);
      if(diff)delta++;
    }
    if(old.data[i]!==current.data[i]||old.data[i+1]!==current.data[i+1]||old.data[i+2]!==current.data[i+2])pixels++;
  }
  changedPixels+=pixels;
  console.log("PASS "+file+": same dimensions and alpha, subtle RGB change");
}
for(const file of [
"graphics/asteroid/used-rocket.png",
"graphics/entity/remnant-beacon/remnant-beacon.png",
"graphics/asteroid/rocket-chunk-normal.png",
"graphics/asteroid/rocket-chunk-roughness.png",
"graphics/asteroid/used-rocket-normal.png",
"graphics/asteroid/used-rocket-roughness.png",
"graphics/entity/remnant-beacon/remnant-beacon-shadow.png"
]){
 const original=execFileSync("git",["show",baseline+":"+file],{cwd:root,maxBuffer:4*1024*1024});
 const current=fs.readFileSync(path.join(root,file));
 if(!original.equals(current))throw Error("Material/shadow technical map modified: "+file);
}
const code=fs.readFileSync(path.join(root,"data.lua"),"utf8");
if(!code.includes('rocket-reusability-research.png",\n        icon_size = 190'))
 throw Error("Rocket recovery research icon_size does not match original 190x190 artwork");
if(changedPixels===0)throw Error("No graphic improvements applied");
console.log("PASS: all source silhouettes preserved; normals, roughness and shadows unchanged; icon metadata correct");
