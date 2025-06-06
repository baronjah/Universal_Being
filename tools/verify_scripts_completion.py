#!/usr/bin/env python3
"""Check all GDScript files for TODO or pass markers and verify connection"""

import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent.parent
ANALYSIS_JSON = ROOT / "script_analysis.json"
REPORT_FILE = ROOT / "UNFINISHED_SCRIPTS.md"


def load_script_list():
    with open(ANALYSIS_JSON, "r", encoding="utf-8") as f:
        data = json.load(f)
    return data


def find_unfinished_scripts(scripts):
    unfinished = []
    for script in scripts:
        path = ROOT / script
        if not path.exists():
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except Exception:
            continue
        if "TODO" in text or re.search(r"\bpass\b", text):
            unfinished.append(script)
    return unfinished


def find_unconnected_scripts(all_scripts, data):
    connected = set(data.get("autoloads", {}).values())
    for scripts in data.get("scene_scripts", {}).values():
        connected.update(scripts)
    return [s for s in all_scripts if s not in connected]


def write_report(unfinished, unconnected):
    with open(REPORT_FILE, "w", encoding="utf-8") as f:
        f.write("# Unfinished Scripts Report\n\n")
        f.write(f"## Scripts containing TODO or pass statements ({len(unfinished)})\n")
        for script in sorted(unfinished):
            f.write(f"- {script}\n")
        f.write("\n")
        f.write(f"## Scripts not connected to scenes or autoloads ({len(unconnected)})\n")
        for script in sorted(unconnected):
            f.write(f"- {script}\n")
    print(f"Report written to {REPORT_FILE}")


def main():
    data = load_script_list()
    all_scripts = data.get("all_scripts", [])
    unfinished = find_unfinished_scripts(all_scripts)
    unconnected = find_unconnected_scripts(all_scripts, data)
    write_report(unfinished, unconnected)


if __name__ == "__main__":
    main()
