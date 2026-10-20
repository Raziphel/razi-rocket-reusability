#!/usr/bin/env python3
"""Static sanity checks; this does not replace a Factorio 2.1 test."""
import json
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
info = json.loads((root / "info.json").read_text())
assert info["factorio_version"] == "2.1"
assert info["version"] == "1.1.4"
assert "razi_lib >= 1.2.0" in info["dependencies"]
assert "? planet-muluna" in info["dependencies"]
assert "? Krastorio2-spaced-out >= 2.0.0" in info["dependencies"]
assert info["name"] == "razi-rocket-reusability"
assert "! rocket-reusability" in info["dependencies"]
assert any(d.startswith("space-age") for d in info["dependencies"])
assert (root / "LICENSE").exists()
lua_files = [p for p in root.rglob("*.lua") if ".tools" not in p.relative_to(root).parts and ".git" not in p.relative_to(root).parts]
data = (root / "data.lua").read_text()
assert "independent_probability = 0.1" in data
assert "probability = 0.1" not in data.replace("independent_probability = 0.1", "")
for file in lua_files:
    references = re.findall(r"__razi-rocket-reusability__/([\w/.-]+)", file.read_text())
    for reference in references:
        assert (root / reference).is_file(), f"{file}: missing {reference}"
for name in ["razi-rocket-reusability-recovery-chance", "razi-rocket-reusability-spawn-distance",
             "razi-rocket-reusability-allow-modded-platforms",
             "razi-rocket-reusability-max-active-wrecks"]:
    assert name in (root / "settings.lua").read_text()
    assert name in (root / "locale/en/english.cfg").read_text()
required = {
    "settings.lua": ["lib/settings"],
    "data.lua": ["lib/item", "lib/recipe", "lib/settings"],
    "data-final-fixes.lua": ["lib/recipe", "lib/technology", "lib/validation"],
    "compatibility/k2so.lua": ["lib/recipe", "lib/validation"],
    "prototypes/remnant-beacon.lua": ["lib/item", "lib/entity", "lib/recipe"],
    "control.lua": ["runtime/events", "runtime/storage", "runtime/remote", "lib/settings"],
}
for name, modules in required.items():
    text = (root / name).read_text()
    for module in modules:
        assert f'require("__razi_lib__/{module}")' in text, f"{name} missing RAZI Library {module}"
assert 'require("compatibility/k2so").apply()' in (root / "data-final-fixes.lua").read_text()
assert "storage.platform_type_whitelist = nil" in (root / "control.lua").read_text()
print(f"PASS: manifest, RAZI modules, probability, referenced assets, locale, {len(lua_files)} Lua files")
