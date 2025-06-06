#!/usr/bin/env python3
"""Upgrade .tscn and .tres files for Godot 4 compatibility."""
import argparse
import re
from pathlib import Path

NODE_REPLACEMENTS = {
    'KinematicBody2D': 'CharacterBody2D',
    'KinematicBody': 'CharacterBody3D',
    'Spatial': 'Node3D',
    'Area ': 'Area3D ',
}

META_PATTERN = re.compile(r'\n__meta__ = \{[^\}]*\}\n', re.MULTILINE)


def upgrade_text(text: str) -> str:
    for old, new in NODE_REPLACEMENTS.items():
        text = text.replace(old, new)
    text = META_PATTERN.sub('\n', text)
    return text


def upgrade_file(path: Path) -> bool:
    original = path.read_text(encoding='utf-8')
    updated = upgrade_text(original)
    if updated != original:
        path.write_text(updated, encoding='utf-8')
        return True
    return False


def main(root: str):
    root_path = Path(root)
    files = list(root_path.rglob('*.tscn')) + list(root_path.rglob('*.tres'))
    changed = 0
    for f in files:
        if upgrade_file(f):
            changed += 1
    print(f"Processed {len(files)} scene/resource files, upgraded {changed}.")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Upgrade scenes and resources')
    parser.add_argument('--root', default='.', help='Project root')
    args = parser.parse_args()
    main(args.root)
