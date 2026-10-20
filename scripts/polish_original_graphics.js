#!/usr/bin/env node
// Gentle, deterministic color-grade of the ACTUAL original rocket-reusability assets.
// No generated art, compositing, repositioning, rescaling, redrawing or shape changes.
// For repeatability, always read the original graphics from Git history, not from
// previously graded output. The source commit is intentionally pinned.
const fs = require("node:fs");
const path = require("node:path");
const {execFileSync} = require("node:child_process");
const {PNG} = require("../.tools/node_modules/pngjs");

const root = path.resolve(__dirname, "..");
const originalRevision = "1bebdfc3961484738c1f5e09591de820c9cea69d";
const profiles = new Map([
  ["thumbnail.png", {contrast:1.032, gamma:0.987, saturation:0.965}],
  ["graphics/icons/incomplete-rocket-part.png", {contrast:1.035, gamma:0.982, saturation:0.995}],
  ["graphics/icons/remnant-beacon-technology.png", {contrast:1.026, gamma:0.990, saturation:0.992}],
  ["graphics/icons/remnant-beacon.png", {contrast:1.035, gamma:0.985, saturation:0.995}],
  ["graphics/icons/rocket-chunk-crushing.png", {contrast:1.035, gamma:0.980, saturation:0.995}],
  ["graphics/icons/rocket-chunk.png", {contrast:1.034, gamma:0.980, saturation:0.995}],
  ["graphics/icons/rocket-reusability-research.png", {contrast:1.028, gamma:0.988, saturation:0.990}],
  ["graphics/icons/used-rocket-icon.png", {contrast:1.034, gamma:0.982, saturation:0.990}],
  ["graphics/asteroid/rocket-chunk.png", {contrast:1.024, gamma:0.986, saturation:0.995}],
]);
const clamp = x => Math.min(255, Math.max(0, Math.round(x)));
for (const [name, profile] of profiles) {
  const original = execFileSync("git", ["show", originalRevision + ":" + name], {
    cwd:root, maxBuffer: 4*1024*1024
  });
  const png = PNG.sync.read(original);
  const baseline = Buffer.from(png.data);
  let changed=0, totalDelta=0, maxDelta=0, alphaChanged=0;
  for (let i=0; i<png.data.length; i+=4) {
    const a = baseline[i+3];
    if (a < 12) continue; // Keep transparent fringe pixels exactly unchanged.
    const r=baseline[i],g=baseline[i+1],b=baseline[i+2];
    const lum=0.2126*r+0.7152*g+0.0722*b;
    if (lum < 7) continue; // Leave very dark silhouettes and backdrop alone.
    const lift=255*Math.pow(lum/255, profile.gamma);
    const outputLum=(lift-116)*profile.contrast+116;
    for (let ch=0;ch<3;ch++) {
      const next=clamp(outputLum+(baseline[i+ch]-lum)*profile.saturation);
      const delta=Math.abs(next-baseline[i+ch]);
      png.data[i+ch]=next;
      if (delta)changed++;
      totalDelta+=delta;
      maxDelta=Math.max(maxDelta,delta);
    }
    if(png.data[i+3]!==a) alphaChanged++;
  }
  if(alphaChanged || maxDelta>14) throw new Error(name+": exceeded subtle-artwork constraint: "+maxDelta);
  const finalPNG=PNG.sync.write(png,{colorType:6,inputColorType:6,bitDepth:8,deflateLevel:9,filterType:-1});
  fs.writeFileSync(path.join(root,name),finalPNG);
  const n=png.width*png.height;
  console.log(name+": "+png.width+"x"+png.height+
      ", max RGB delta="+maxDelta+", avg RGB delta="+(totalDelta/(n*3)).toFixed(2)+
      ", unchanged alpha, "+(finalPNG.length/1024).toFixed(1)+" KiB");
}
// Deliberately never modify PBR normals, roughness atlases or shadow layers.
