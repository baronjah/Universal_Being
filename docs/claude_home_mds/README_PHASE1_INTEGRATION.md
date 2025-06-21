# Akashic Records Phase 1 Integration Guide

This guide covers the implementation of Phase 1 (Basic Integration) for connecting the Akashic Records system to your Eden Space Game's JSH console.

## Files in this Package

1. `akashic_records_main_integration.gd` - Code snippets to add to your main.gd file
2. `create_akashic_directories.gd` - Script to create the necessary directories for the Akashic Records system
3. `akashic_records_demo.gd` - Demo script showing how to use the Akashic Records system
4. This README file

## Step-by-Step Integration Instructions

### Step 1: Create Required Directories

1. Open the Godot editor
2. Create a new script in your project (temporary)
3. Copy the contents of `create_akashic_directories.gd` into the script
4. Run the script to create the necessary directories
5. Once the directories are created, you can delete the temporary script

### Step 2: Modify main.gd

1. Open your `main.gd` file (in the layer_0.tscn scene)
2. Refer to `akashic_records_main_integration.gd` and follow these steps:
   - Add the import statement at the top of your file
   - Add the class variable for the Akashic Records integration
   - Copy the `_initialize_akashic_records()` function to your file
   - Add the `get_akashic_records()` accessor method
   - Add the `view_area` variable if you don't already have it
   - Add the `add_to_view_area()` method if you don't already have it
   - Add the system registration methods if you don't already have them
   - Add the menu entry management method if you don't already have it
   - Add the message display function if you don't already have it
3. In your `_ready()` function, add a call to `_initialize_akashic_records()` after initializing your menu system

### Step 3: Create or Verify the ViewArea Node

1. Open the layer_0.tscn scene in Godot
2. Check if there's already a Control node named "ViewArea"
3. If not, add a Control node named "ViewArea"
4. Set its layout to expand to fill available space
5. Position it where you want the Akashic Records UI to appear

### Step 4: Test the Integration

1. Run the layer_0.tscn scene
2. Check the console output for "Akashic Records system initialized"
3. Look for new menu entries in your "Things" menu related to Akashic Records
4. Click on these entries to access the Akashic Records UI

### Step 5: Try the Demo (Optional)

1. Create a new node in your scene
2. Attach the `akashic_records_demo.gd` script to it
3. Run the scene to create demo dictionary entries
4. Check the dictionary folders to see the saved entries

## Troubleshooting

- **Script errors**: Ensure all paths in the import statements match your project structure
- **Menu entries not appearing**: Check that the Akashic Records integration is being initialized correctly
- **UI not displaying**: Make sure the ViewArea node exists and is properly set up
- **Missing files**: Verify all required Akashic Records system files are in their correct locations

## Next Steps (Phase 2)

After completing Phase 1 integration:

1. Test creating dictionary entries through the UI
2. Test interactions between entries
3. Configure evolution parameters
4. Test the 3D visualization
5. Proceed to Phase 2: Element Integration

## Need Help?

If you encounter any issues during this phase of integration, check the provided integration guide and troubleshooting section first. If problems persist, refer to the Akashic Records system documentation for more detailed information.