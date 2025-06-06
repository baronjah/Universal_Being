#!/usr/bin/env python3
"""Utility to upgrade GDScript files to Godot 4.4 / GDScript 2.0 syntax."""
import re
from pathlib import Path
import argparse

REPLACEMENTS = [
    # Avoid double applying by ensuring the keyword is not already prefixed with '@'
    (re.compile(r"(?<!@)\bonready var\b"), "@onready var"),
    (re.compile(r"(?<!@)\bexport var\b"), "@export var"),
    (re.compile(r"(?<!@)\bexport\(([^)]+)\)"), r"@export(\1)"),
    # Clean up duplicates from previous runs
    (re.compile(r"@{2,}(onready var)"), r"@\1"),
    (re.compile(r"@{2,}(export var)"), r"@\1"),
    (re.compile(r"@{2,}(export\()"), r"@\1"),
    (re.compile(r"\bKinematicBody2D\b"), "CharacterBody2D"),
    (re.compile(r"\bKinematicBody\b"), "CharacterBody3D"),
    (re.compile(r"\bSpatial\b"), "Node3D"),
    (re.compile(r"\bArea\b"), "Area3D"),
]

def convert_yield(line: str) -> str:
    # yield(obj, "signal") -> await obj.signal
    m = re.search(r"yield\(([^,]+),\s*\"([^\"]+)\"\)", line)
    if m:
        obj, sig = m.group(1).strip(), m.group(2)
        return re.sub(r"yield\([^)]*\)", f"await {obj}.{sig}", line)
    return line


def upgrade_file(path: Path) -> bool:
    """Upgrade one .gd file. Returns True if changed."""
    text = path.read_text(encoding="utf-8")
    original = text
    lines = text.splitlines()
    for i, line in enumerate(lines):
        line = convert_yield(line)
        for pattern, repl in REPLACEMENTS:
            line = pattern.sub(repl, line)
        lines[i] = line
    text = "\n".join(lines)
    if text != original:
        path.write_text(text, encoding="utf-8")
        return True
    return False


def main(root: str):
    root_path = Path(root)
    gd_files = list(root_path.rglob('*.gd'))
    changed = 0
    for gd in gd_files:
        if upgrade_file(gd):
            changed += 1
    print(f"Processed {len(gd_files)} .gd files, upgraded {changed}.")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Upgrade GDScript files")
    parser.add_argument('--root', default='.', help='Project root')
    args = parser.parse_args()
    main(args.root)
