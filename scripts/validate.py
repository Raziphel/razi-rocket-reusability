#!/usr/bin/env python3
"""Static sanity checks; this does not replace a Factorio 2.1 test."""
import json
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
info = json.loads((root / "info.json").read_text())
assert info["factorio_version"] == "2.1"
assert info["version"] == "1.1.0"
assert info["name"] == "razi-rocket-reusability"
assert "! rocket-reusability" in info["dependencies"]
assert any(d.startswith("space-age") for d in info["dependencies"])
assert (root / "LICENSE").exists()
lua_files = list(root.rglob("*.lua"))
data = (root / "data.lua").read_text()
assert "independent_probability = 0.1" in data
assert "probability = 0.1" not in data.replace("independent_probability = 0.1", "")
for file in lua_files:
    references = re.findall(r"__razi-rocket-reusability__/([\w/.-]+)", file.read_text())
    for reference in references:
        assert (root / reference).is_file(), f"{file}: missing {reference}"
for name in ["razi-rocket-reusability-recovery-chance", "razi-rocket-reusability-spawn-distance",
             "razi-rocket-reusability-allow-modded-platforms"]:
    assert name in (root / "settings.lua").read_text()
    assert name in (root / "locale/en/english.cfg").read_text()
print(f"PASS: manifest, probability, referenced assets, locale, {len(lua_files)} Lua files")
