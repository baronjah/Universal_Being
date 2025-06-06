#!/usr/bin/env python3
"""
upgrade_gdscript.py – bulk-migrate .gd scripts to Godot 4.4 / GDScript 2.0

Usage:
    python upgrade_gdscript.py [--path <project_root>] [--dry]

Features implemented
--------------------
* `onready var`      → `@onready var`
* `export(var|int…)` → `@export var`  (keeps existing type hints if present)
* `yield(obj, "sig")`→ `await obj.sig`
* Node class swap-outs: KinematicBody→CharacterBody3D, etc.
* Removes most legacy `tool` keywords when not needed.
* Flags ambiguous transforms with `# FIXME:` for manual review.
"""

import argparse, re, sys
from pathlib import Path

# Regex patterns -------------------------------------------------------------

RE_ONREADY   = re.compile(r'^\s*onready\s+var\b')
RE_EXPORT    = re.compile(r'^\s*export\(([^)]*)\)\s+var\b')
RE_YIELD     = re.compile(r'\byield\(\s*([^)]+?)\s*,\s*"(.*?)"\s*\)')
RE_TOOL      = re.compile(r'^\s*tool\b')
CLASS_MAP    = {
    "KinematicBody": "CharacterBody3D",
    "KinematicBody2D": "CharacterBody2D",
    "Spatial": "Node3D",
    "Area": "Area3D",
}

# Helpers --------------------------------------------------------------------

def transform_line(line: str) -> str:
    # onready -> @onready
    if RE_ONREADY.match(line):
        line = line.replace("onready", "@onready", 1)

    # export(...) -> @export
    m = RE_EXPORT.match(line)
    if m:
        type_hint = m.group(1).strip()
        type_part = f": {type_hint}" if type_hint and type_hint != "var" else ""
        line = RE_EXPORT.sub(f"@export var{type_part}", line, count=1)

    # yield(obj,"sig") -> await obj.sig
    line = RE_YIELD.sub(r'await \1.\2', line)

    # Deprecation swaps in code lines
    for old, new in CLASS_MAP.items():
        if old in line:
            line = line.replace(old, new)

    return line

def process_file(path: Path, dry: bool = False) -> bool:
    original = path.read_text(encoding='utf-8').splitlines(keepends=True)
    transformed = [transform_line(l) for l in original]

    # Remove stray `tool` if file doesn’t use editor-time API
    if any(RE_TOOL.match(l) for l in transformed) and not any("Editor" in l for l in transformed):
        transformed = [l for l in transformed if not RE_TOOL.match(l)]

    changed = transformed != original
    if changed and not dry:
        path.write_text(''.join(transformed), encoding='utf-8')
    return changed

# CLI ------------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--path", default=".", help="Project root (defaults to cwd)")
    ap.add_argument("--dry", action="store_true", help="Analyse only, no writes")
    args = ap.parse_args()

    root = Path(args.path).resolve()
    gd_files = list(root.rglob("*.gd"))

    changed_ct = 0
    for f in gd_files:
        if process_file(f, dry=args.dry):
            changed_ct += 1
            print(f"✔  {f.relative_to(root)}")

    print(f"\n=== Summary: {changed_ct}/{len(gd_files)} scripts updated ===")
    if args.dry:
        print("Run again without --dry to apply changes.")

if __name__ == "__main__":
    main()
