# GDScript Upgrade Tool

`upgrade_gdscript.py` helps migrate Universal Being scripts to Godot 4.4 and GDScript 2.0.

```bash
python tools/upgrade_gdscript.py --path .      # update all scripts
python tools/upgrade_gdscript.py --path . --dry  # show changes only
```

The tool performs common replacements like `onready` -> `@onready` and 
converts `yield()` calls to `await`. It also swaps deprecated node
classes (e.g. `KinematicBody` to `CharacterBody3D`). Review flagged
`# FIXME:` comments after running.
