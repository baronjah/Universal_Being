# Thing Creator Installation Instructions

This document provides step-by-step instructions to install the Thing Creator system into your Eden Space Game project.

## Step 1: Copy Files to Correct Locations

Copy the following files to their respective locations in your project:

### Core Files

Copy to `res://code/gdscript/scripts/akashic_records/` folder:
- `thing_creator.gd`
- `thing_creator_ui.gd`

### Scene Files

Copy to `res://code/gdscript/scenes/` folder:
- `thing_creator_ui.tscn`

### Menu Integration Files

Copy to `res://code/gdscript/scripts/Menu_Keyboard_Console/` folder:
- `thing_creator_integration.gd`
- `thing_creator_commands.gd`

### Utility Scripts

Copy to your project's script folder (where other utility scripts are):
- `thing_creator_setup.gd`
- `thing_creator_auto_setup.gd`
- `jsh_connector.gd`
- `scene_diagnostics.gd`

### Documentation 

Keep these files for reference:
- `THING_CREATOR_README.md`
- `THING_CREATOR_INTEGRATION_GUIDE.md`
- `THING_CREATOR_LAYER0_INTEGRATION.md`
- `THING_CREATOR_FINAL_INTEGRATION.md`
- `INSTALL_INSTRUCTIONS.md` (this file)

## Step 2: Choose an Integration Method

You have three options for integrating the Thing Creator system:

### Option 1: Automatic Setup (Recommended for Testing)

1. Open your layer_0.tscn scene in the Godot editor
2. Add a new Node to your scene
3. Name it "ThingCreatorAutoSetup"
4. Attach the `thing_creator_auto_setup.gd` script to it
5. Run your scene to automatically set up the Thing Creator system
6. Check the console for the setup report

### Option 2: Manual Integration with Diagnostics (Recommended for Production)

1. First run diagnostics:
   - Add a temporary Node to your scene
   - Attach the `scene_diagnostics.gd` script to it
   - Run your scene and note the paths in the console output
   - Remove the diagnostics node

2. Modify your main.gd:
   - Add the code from `main_thing_creator_integration.gd`
   - Update the JSH console and view area paths based on diagnostics
   - Add `_initialize_thing_creator()` call to your `_ready()` function

### Option 3: Setup Script (Recommended for Clean Integration)

1. Open your layer_0.tscn scene in the Godot editor
2. Add a new Node to your scene
3. Name it "ThingCreatorSetup"
4. Attach the `thing_creator_setup.gd` script to it
5. Run your scene

## Step 3: Verify Installation

Regardless of which method you choose, verify the installation:

1. Run your layer_0.tscn scene
2. Check the console for initialization messages
3. Try using JSH console commands:
   ```
   thing-help
   thing-create fire 0 1 0
   thing-list
   ```
4. Look for Thing Creator entries in your menu system
5. Try opening and using the Thing Creator UI

## Troubleshooting

If you encounter issues:

1. **Files not found**
   - Double-check that all files were copied to the correct locations
   - Make sure the paths in the scripts match your project structure

2. **Integration not working**
   - Try using the ThingCreatorAutoSetup script first to diagnose issues
   - Check the console for specific error messages
   - Ensure Akashic Records system is fully initialized before Thing Creator

3. **JSH console commands not responding**
   - Try using the jsh_connector.gd as an alternative connection method
   - Verify your JSH console is initialized properly

4. **UI not displaying**
   - Check that your view area is correctly found or created
   - Make sure your menu system supports the integration methods

## Need More Information?

Refer to these documentation files for more details:

- `THING_CREATOR_README.md` - General usage guide
- `THING_CREATOR_INTEGRATION_GUIDE.md` - Technical integration details
- `THING_CREATOR_LAYER0_INTEGRATION.md` - Specific layer_0.tscn integration
- `THING_CREATOR_FINAL_INTEGRATION.md` - Comprehensive integration package

## Next Steps

After successful installation:

1. Create some dictionary entries through the Akashic Records UI
2. Use the Thing Creator to materialize these entries
3. Experiment with interactions between things
4. Connect Thing Creator to your game mechanics