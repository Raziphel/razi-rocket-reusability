#!/usr/bin/env python3
"""Package only playable Factorio mod files. Developer files never enter the ZIP."""

import json
import zipfile
from pathlib import Path

root = Path(__file__).resolve().parents[1]
manifest = json.loads((root / "info.json").read_text())
mod_folder = f"{manifest['name']}_{manifest['version']}"
dist = root / "dist"
dist.mkdir(exist_ok=True)
archive = dist / (mod_folder + ".zip")

# Explicit allowlist instead of maintaining an ever-growing exclude list.
root_files = (
    "info.json",
    "LICENSE",
    "README.md",
    "changelog.txt",
    "thumbnail.png",
    "settings.lua",
    "data.lua",
    "data-final-fixes.lua",
    "control.lua",
)
asset_directories = ("graphics", "locale", "prototypes", "compatibility", "runtime")

included = []
for file_name in root_files:
    file = root / file_name
    if not file.is_file():
        raise FileNotFoundError(f"Required mod file missing: {file_name}")
    included.append(file)

for directory in asset_directories:
    asset_root = root / directory
    if not asset_root.is_dir():
        raise FileNotFoundError(f"Required mod directory missing: {directory}")
    for file in sorted(asset_root.rglob("*")):
        if file.is_file() and not file.name.startswith("."):
            if ".razi-backup-" in file.name or "__pycache__" in file.parts:
                continue
            included.append(file)

with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED) as z:
    for file in sorted(included, key=lambda p: p.relative_to(root).as_posix()):
        z.write(file, str(Path(mod_folder) / file.relative_to(root)))

# Verify the generated archive can be opened, not just written.
with zipfile.ZipFile(archive) as z:
    if z.testzip() is not None:
        raise RuntimeError("Generated mod ZIP failed integrity check")

print(archive)
