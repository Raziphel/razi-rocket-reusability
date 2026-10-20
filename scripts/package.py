#!/usr/bin/env python3
"""Generate the correctly named Factorio mod ZIP without developer files."""
import json
import zipfile
from pathlib import Path

root = Path(__file__).resolve().parents[1]
info = json.loads((root / "info.json").read_text())
name = f"{info['name']}_{info['version']}"
dist = root / "dist"
dist.mkdir(exist_ok=True)
archive = dist / (name + ".zip")
excluded = {".git", "dist", "scripts", ".tools", ".gitignore", "PORTAL.md", "TEST_PLAN.md", "K2SO_COMPATIBILITY.md", "__pycache__", ".DS_Store"}
with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED) as z:
    for path in sorted(root.rglob("*")):
        if not path.is_file() or path.suffix == ".zip" or any(part in excluded or ".razi-backup-" in part for part in path.parts):
            continue
        z.write(path, str(Path(name) / path.relative_to(root)))
print(archive)
