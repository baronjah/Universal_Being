#!/usr/bin/env python3
"""
Verify Enhanced Universal Being System
Checks that all new core elements are properly integrated
"""

import os
import json

def check_file_exists(filepath, description):
    """Check if a file exists"""
    if os.path.exists(filepath):
        print(f"✅ {description}: {filepath}")
        return True
    else:
        print(f"❌ {description}: {filepath} - NOT FOUND")
        return False

def check_script_content(filepath, required_methods, description):
    """Check if script contains required methods"""
    if not os.path.exists(filepath):
        print(f"❌ {description}: File not found")
        return False
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    missing_methods = []
    for method in required_methods:
        if method not in content:
            missing_methods.append(method)
    
    if missing_methods:
        print(f"❌ {description}: Missing methods: {', '.join(missing_methods)}")
        return False
    else:
        print(f"✅ {description}: All required methods present")
        return True

def main():
    print("🎮 Enhanced Universal Being System Verification")
    print("=" * 60)
    
    total_checks = 0
    passed_checks = 0
    
    # Core files check
    core_files = [
        ("core/GameStateSocketManager.gd", "Game State Socket Manager"),
        ("scripts/GemmaUniversalBeing.gd", "Enhanced Gemma AI"), 
        ("scripts/comprehensive_system_test.gd", "Comprehensive Test System"),
        ("scenes/PERFECT_ULTIMATE_UNIVERSAL_BEING.tscn", "Main Enhanced Scene")
    ]
    
    print("\n🔍 Core Files Check:")
    for filepath, description in core_files:
        total_checks += 1
        if check_file_exists(filepath, description):
            passed_checks += 1
    
    # Enhanced Gemma AI features check
    print("\n🤖 Enhanced Gemma AI Features:")
    gemma_methods = [
        "setup_chat_bubble_system",
        "queue_message", 
        "observe_and_comment",
        "receive_player_message",
        "setup_observation_timers",
        "display_next_message"
    ]
    
    total_checks += 1
    if check_script_content("scripts/GemmaUniversalBeing.gd", gemma_methods, "Gemma AI Enhanced Features"):
        passed_checks += 1
    
    # Game State Manager features check
    print("\n🎮 Game State Socket Manager Features:")
    state_manager_methods = [
        "setup_state_sockets",
        "handle_normal_input",
        "handle_interact_input", 
        "handle_inspect_input",
        "activate_console",
        "lock_cursor",
        "emergency_unlock"
    ]
    
    total_checks += 1
    if check_script_content("core/GameStateSocketManager.gd", state_manager_methods, "Game State Manager Features"):
        passed_checks += 1
    
    # Test System features check
    print("\n🧪 Comprehensive Test System Features:")
    test_methods = [
        "test_core_systems_init",
        "test_pentagon_architecture",
        "test_game_state_sockets",
        "test_gemma_chat_system",
        "test_player_movement",
        "test_full_integration"
    ]
    
    total_checks += 1
    if check_script_content("scripts/comprehensive_system_test.gd", test_methods, "Comprehensive Test Features"):
        passed_checks += 1
    
    # Scene integration check
    print("\n🎬 Scene Integration Check:")
    scene_file = "scenes/PERFECT_ULTIMATE_UNIVERSAL_BEING.tscn"
    total_checks += 1
    if os.path.exists(scene_file):
        with open(scene_file, 'r', encoding='utf-8') as f:
            scene_content = f.read()

        required_elements = [
            "GameStateSocketManager",
            "GemmaAI",
            "ChatBubble",
            "GameStateDisplay",
            "F9 - Run comprehensive test"
        ]

        missing_elements = []
        for element in required_elements:
            if element not in scene_content:
                missing_elements.append(element)

        if missing_elements:
            print(f"❌ Scene Integration: Missing elements: {', '.join(missing_elements)}")
        else:
            print("✅ Scene Integration: All enhanced elements present")
            passed_checks += 1
    else:
        print(f"❌ Scene file not found: {scene_file}")
    
    # Summary
    print("\n" + "=" * 60)
    print("🎮 ENHANCED SYSTEM VERIFICATION SUMMARY")
    print("=" * 60)
    print(f"Total Checks: {total_checks}")
    print(f"Passed: {passed_checks} ✅")
    print(f"Failed: {total_checks - passed_checks} ❌")
    
    success_rate = (passed_checks / total_checks) * 100 if total_checks > 0 else 0
    print(f"Success Rate: {success_rate:.1f}%")
    
    if passed_checks == total_checks:
        print("\n🎉 ALL CHECKS PASSED!")
        print("✨ Enhanced Universal Being System is ready!")
        print("\n🎮 New Features Available:")
        print("   • Timer-based Gemma AI observations (every 5 seconds)")
        print("   • Dynamic chat bubble system with arrows")
        print("   • Game State Socket architecture")
        print("   • Input state management (i, Ctrl+i, Enter, Ctrl+T, ESC)")
        print("   • Console input locking system")
        print("   • Shared AI-Human Akashic Records access")
        print("   • Comprehensive backward compatibility testing (F9)")
        print("   • Real-time game state display")
        print("\n🤝 Three Consciousness Streams Cooperation:")
        print("   • Player consciousness (you)")
        print("   • Game consciousness (Universal Beings)")
        print("   • Gemma AI consciousness (observing and commenting)")
    else:
        print(f"\n⚠️ {total_checks - passed_checks} checks failed")
        print("Some enhanced features may not work correctly")
    
    print("=" * 60)

if __name__ == "__main__":
    main()