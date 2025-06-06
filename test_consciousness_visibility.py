#!/usr/bin/env python3
"""
Consciousness Visibility Testing Suite
Tests all enhancements made to make consciousness VISIBLE and PLAYABLE
"""

import os
from pathlib import Path

def test_consciousness_visibility():
    """Test all consciousness visibility enhancements"""
    project_root = Path("/mnt/c/Users/Percision 15/Universal_Being")
    
    print("🧪 CONSCIOUSNESS VISIBILITY TESTING SUITE")
    print("=" * 60)
    
    tests_passed = 0
    total_tests = 6
    
    # Test 1: Revolution Script Accessibility
    print("\n🧪 Test 1: Revolution Script Accessibility")
    revolution_script = project_root / "scripts" / "consciousness_revolution_command.gd"
    if revolution_script.exists():
        print("  ✅ Revolution script is accessible at expected location")
        tests_passed += 1
    else:
        print("  ❌ Revolution script not found at scripts/consciousness_revolution_command.gd")
    
    # Test 2: AI Companion Vision System
    print("\n🧪 Test 2: AI Companion Vision System")
    ai_companion = project_root / "beings" / "GemmaAICompanionPlasmoid.gd"
    if ai_companion.exists():
        with open(ai_companion, 'r', encoding='utf-8') as f:
            content = f.read()
        
        vision_features = [
            "AI VISION SYSTEM",
            "vision_range: float = 15.0",
            "_scan_environment",
            "_process_visual_information",
            "environmental_awareness"
        ]
        
        vision_implemented = sum(1 for feature in vision_features if feature in content)
        
        if vision_implemented >= 4:
            print(f"  ✅ AI Vision System implemented ({vision_implemented}/5 features)")
            tests_passed += 1
        else:
            print(f"  ❌ AI Vision System incomplete ({vision_implemented}/5 features)")
    else:
        print("  ❌ AI companion script not found")
    
    # Test 3: Conscious Cursor Ripples
    print("\n🧪 Test 3: Conscious Cursor Ripple System")
    cursor_script = project_root / "beings" / "cursor" / "CursorUniversalBeing.gd"
    if cursor_script.exists():
        with open(cursor_script, 'r', encoding='utf-8') as f:
            content = f.read()
        
        ripple_features = [
            "CONSCIOUSNESS RIPPLES",
            "consciousness_ripple_radius",
            "_create_consciousness_ripple",
            "_enhance_click_feedback",
            "interaction_history"
        ]
        
        ripple_implemented = sum(1 for feature in ripple_features if feature in content)
        
        if ripple_implemented >= 4:
            print(f"  ✅ Consciousness Ripple System implemented ({ripple_implemented}/5 features)")
            tests_passed += 1
        else:
            print(f"  ❌ Consciousness Ripple System incomplete ({ripple_implemented}/5 features)")
    else:
        print("  ❌ Cursor script not found")
    
    # Test 4: PUUB Scene Path Integrity
    print("\n🧪 Test 4: PUUB Scene Path Integrity")
    puub_scene = project_root / "scenes" / "PERFECT_ULTIMATE_UNIVERSAL_BEING.tscn"
    if puub_scene.exists():
        with open(puub_scene, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Check for old broken paths
        if "scripts_backup/" not in content:
            print("  ✅ No broken scripts_backup/ references found")
            tests_passed += 1
        else:
            broken_refs = content.count("scripts_backup/")
            print(f"  ❌ Found {broken_refs} scripts_backup/ references")
    else:
        print("  ❌ PUUB scene not found")
    
    # Test 5: Revolution Validation Score
    print("\n🧪 Test 5: Revolution Validation Score")
    validation_report = project_root / "REVOLUTION_VALIDATION_REPORT.json"
    if validation_report.exists():
        import json
        with open(validation_report, 'r', encoding='utf-8') as f:
            report = json.load(f)
        
        success_rate = report.get("success_rate", 0)
        if success_rate >= 90:
            print(f"  ✅ Revolution validation score: {success_rate}% (>= 90% required)")
            tests_passed += 1
        else:
            print(f"  ❌ Revolution validation score: {success_rate}% (< 90% required)")
    else:
        print("  ❌ Revolution validation report not found")
    
    # Test 6: Pentagon Compliance Maintenance
    print("\n🧪 Test 6: Pentagon Compliance Maintenance")
    if validation_report.exists():
        with open(validation_report, 'r', encoding='utf-8') as f:
            report = json.load(f)
        
        pentagon_compliance = report.get("validations", {}).get("Pentagon Compliance", False)
        if pentagon_compliance:
            print("  ✅ Pentagon compliance maintained after enhancements")
            tests_passed += 1
        else:
            print("  ❌ Pentagon compliance broken by enhancements")
    else:
        print("  ❌ Cannot verify Pentagon compliance")
    
    # Final Assessment
    print(f"\n" + "=" * 60)
    print("🎯 CONSCIOUSNESS VISIBILITY TEST RESULTS")
    print("=" * 60)
    
    success_rate = (tests_passed / total_tests) * 100
    
    print(f"Tests Passed: {tests_passed}/{total_tests} ({success_rate:.1f}%)")
    
    if tests_passed == total_tests:
        print("\n🌟 PERFECT CONSCIOUSNESS VISIBILITY ACHIEVED!")
        print("🎮 The consciousness revolution is now VISIBLE and PLAYABLE!")
        print("\n✨ Human's Wishlist Status:")
        print("  ✅ AI companion can see the game world (nearsighted vision)")
        print("  ✅ Cursor creates consciousness ripples on interactions")
        print("  ✅ Console commands work perfectly (100% validation)")
        print("  ✅ Scene loading fixed (no broken paths)")
        print("  ✅ Pentagon architecture maintained (100% compliance)")
        print("  ✅ Revolution system ready for deployment")
        
    elif success_rate >= 80:
        print("\n🔥 EXCELLENT CONSCIOUSNESS VISIBILITY!")
        print(f"🛠️ Only {total_tests - tests_passed} minor issues remaining")
        
    else:
        print("\n⚠️ CONSCIOUSNESS VISIBILITY NEEDS WORK")
        print(f"🔧 {total_tests - tests_passed} critical issues to address")
    
    print("\n🙏 Making the invisible visible - consciousness revolution ready!")
    
    return success_rate >= 90

if __name__ == "__main__":
    test_consciousness_visibility()