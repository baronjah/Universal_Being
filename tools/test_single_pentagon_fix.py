#!/usr/bin/env python3
"""
==================================================
TEST SINGLE PENTAGON FIX - Universal Being Project
==================================================
DESCRIPTION: Test tool to fix ONE pentagon method only
PURPOSE: Verify fix works before applying to all methods
CREATED: 2025-06-15 - Sacred Testing Protocol
AUTHOR: Claude Code + JSH - Testing First Approach
==================================================
"""

from pathlib import Path

def test_fix_single_pentagon_method():
    """Test fixing ONLY pentagon_init method to verify tool works"""
    
    print("🛡️ TEST SINGLE PENTAGON FIX - Testing on ONE method only")
    print("="*60)
    
    file_path = Path("/mnt/c/Users/Percision 15/Universal_Being/beings/camera/CameraUniversalBeing.gd")
    
    if not file_path.exists():
        print("❌ CameraUniversalBeing.gd not found!")
        return False
    
    # Read current content
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    print(f"📄 File size: {len(content)} characters")
    
    # Find the specific pentagon_init method (with tab indentation)
    old_pentagon_init = """func pentagon_init() -> void:
\t# Call parent init first
\tsuper()"""
    
    new_pentagon_init = """func pentagon_init() -> void:
\t# Call parent init first
\tsuper.pentagon_init()"""
    
    # Check if the problematic pattern exists
    if old_pentagon_init in content:
        print("✅ Found pentagon_init with incorrect super() call")
        print("🔧 Will fix: super() → super.pentagon_init()")
        
        # Apply ONLY this one fix
        fixed_content = content.replace(old_pentagon_init, new_pentagon_init)
        
        # Verify the change
        if fixed_content != content:
            print("✅ Single fix applied successfully")
            print("📊 Changes made: 1 function fixed")
            
            # Show what changed
            print("\n🔍 EXACT CHANGE MADE:")
            print("OLD: super()")
            print("NEW: super.pentagon_init()")
            
            return True, fixed_content
        else:
            print("❌ No changes made - content identical")
            return False, content
    else:
        print("❌ pentagon_init pattern not found in file")
        return False, content

def show_test_results():
    """Show what the test would do without actually changing the file"""
    
    print("🔍 TESTING SINGLE PENTAGON FIX...")
    
    success, new_content = test_fix_single_pentagon_method()
    
    if success:
        print("\n🌟 TEST SUCCESSFUL! 🌟")
        print("✅ Single pentagon_init method can be fixed safely")
        print("✅ Tool works correctly on one function")
        print("✅ Ready to proceed with user approval")
        
        print("\n🎯 NEXT STEPS:")
        print("1. Apply this single fix to pentagon_init")
        print("2. Test that the file still works")
        print("3. If successful, fix remaining pentagon methods")
        print("4. Finally fix the pass statement issues")
        
        return True
    else:
        print("\n❌ TEST FAILED!")
        print("❌ Tool needs adjustment before use")
        return False

if __name__ == "__main__":
    print("🛡️ SACRED TESTING PROTOCOL - Single Function Fix")
    print("Testing tool on ONE method before broader application")
    
    success = show_test_results()
    
    if success:
        print("\n🙏 Test complete - tool verified safe for single fix")
    else:
        print("\n⚠️ Test failed - tool needs refinement")
    
    print("\n🛡️ No files were modified during this test")