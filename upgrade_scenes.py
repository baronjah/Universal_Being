#!/usr/bin/env python3
"""
upgrade_scenes.py – migrate .tscn / .tres resources for Godot 4.4

Usage:
    python upgrade_scenes.py [--path <project_root>] [--dry]
"""

import argparse
import re
from pathlib import Path

CLASS_MAP = {
    "KinematicBody": "CharacterBody3D",
    "KinematicBody2D": "CharacterBody2D",
    "Spatial": "Node3D",
    "Area ": "Area3D ",    # note space to avoid 'Area2D'
}

RE_EMPTY_META = re.compile(r'\[__meta__\][\s\S]*?\n{2}', re.MULTILINE)


def transform_text(txt: str) -> str:
    for old, new in CLASS_MAP.items():
        txt = txt.replace(old, new)
    txt = RE_EMPTY_META.sub("", txt)  # strip empty __meta__ blobs
    return txt


def process_file(path: Path, dry: bool = False) -> bool:
    raw = path.read_text(encoding='utf-8')
    new = transform_text(raw)
    if new != raw and not dry:
        path.write_text(new, encoding='utf-8')
    return new != raw


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--path", default=".", help="Project root")
    p.add_argument("--dry", action="store_true")
    a = p.parse_args()

    root = Path(a.path).resolve()
    targets = list(root.rglob("*.tscn")) + list(root.rglob("*.tres"))

    upd = sum(process_file(f, dry=a.dry) for f in targets)
    print(f"\n=== Summary: {upd}/{len(targets)} resources patched ===")


if __name__ == "__main__":
    main()
