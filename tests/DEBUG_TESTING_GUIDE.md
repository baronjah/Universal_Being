# 🧪 Debug System Testing Guide

## Quick Test Steps:

1. **Run the test scene:**
   - Open: `res://tests/debug_system_test.tscn`
   - Press Play

2. **Test the Debug Overlay:**
   - Look directly at a chunk (aim camera at it)
   - Press **F4** to open debug overlay
   - You should see a translucent panel with properties

3. **Test Interactions:**
   - **Edit Values**: Click on values in the tree and type new ones
   - **Action Buttons**: Click buttons at the bottom
   - **Close**: Press F4 again (toggle) or click elsewhere

## Known Issues Fixed:
- ✅ Try/except syntax replaced with GDScript patterns
- ✅ Singleton access using get_node_or_null("/root/...")
- ✅ Added get_consciousness_color() method
- ✅ Test script now uses proper structure

## What Should Work:
- F4 toggles overlay when looking at chunks
- Properties display in tree view
- Values can be edited
- Action buttons execute chunk methods
- Overlay hides when toggled again

## Console Output:
You should see:
- "🧪 Debug System Test Starting..."
- "🔌 Singleton Status:" with checkmarks
- "🔌 Registered debuggable:" messages for each chunk
- "🧪 Test chunks created!"

## If Something Doesn't Work:
1. Check console for errors
2. Ensure all autoloads are enabled in Project Settings
3. Make sure you're looking directly at a chunk when pressing F4
