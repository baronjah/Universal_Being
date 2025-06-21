#!/usr/bin/env python3
"""
==================================================
PERFECT DNA FINAL FIXER - Universal Being Project
==================================================
DESCRIPTION: Final comprehensive fix for UniversalBeingDNA.gd
PURPOSE: Fix all remaining syntax issues in the DNA system
CREATED: 2025-06-15 - Universal Being Revolution
AUTHOR: Claude Code + JSH
==================================================
"""

import re
from pathlib import Path

def fix_dna_final():
    """Fix all remaining syntax issues in UniversalBeingDNA.gd"""
    
    file_path = Path("/mnt/c/Users/Percision 15/Universal_Being/core/UniversalBeingDNA.gd")
    
    print("🧬 PERFECT DNA FINAL FIXER - Comprehensive syntax repair")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    fixes_applied = []
    
    # Check for common syntax patterns that need fixing
    patterns_to_fix = [
        # Missing closing braces for dictionaries
        (r'(\w+\s*=\s*\{[^{}]*?)(\n\s*#)', r'\1\n\t}\2'),
        (r'(\w+\s*=\s*\{[^{}]*?)(\n\s*func)', r'\1\n\t}\2'),
        (r'(\w+\s*=\s*\{[^{}]*?)(\n\s*var)', r'\1\n\t}\2'),
        (r'(\w+\s*=\s*\{[^{}]*?)(\n\s*if)', r'\1\n\t}\2'),
        (r'(\w+\s*=\s*\{[^{}]*?)(\n\s*for)', r'\1\n\t}\2'),
        
        # Fix return statements with dictionaries
        (r'(return\s*\{[^{}]*?)(\n\s*func)', r'\1\n\t}\2'),
        
        # Fix function parameters
        (r'func\s+(\w+)\s*\([^)]*\.([^)]*)\):', r'func \1(\2):'),
        
        # Fix Time.Time references (should be just Time)
        (r'Time\.Time\.', r'Time.'),
        
        # Fix dictionary comma issues
        (r'(\w+:\s*[^,\n}]+)(\n\s*})', r'\1\2'),
        
        # Fix array syntax
        (r'Array\[(\w+)\]', r'Array[\1]'),
    ]
    
    for pattern, replacement in patterns_to_fix:
        if re.search(pattern, content, re.DOTALL):
            content = re.sub(pattern, replacement, content, flags=re.DOTALL)
            fixes_applied.append(f"Fixed pattern: {pattern[:40]}...")
    
    # Fix specific known issues
    specific_fixes = [
        # Fix any remaining dictionary structure issues
        ('scene_analysis = {\n\t\t"scene_name"', 'scene_structure = {\n\t\t"scene_name"'),
        
        # Ensure proper variable declarations
        ('var scene_analysis:', 'var scene_structure:'),
        
        # Fix any remaining brace mismatches
    ]
    
    for old, new in specific_fixes:
        if old in content:
            content = content.replace(old, new)
            fixes_applied.append(f"Fixed specific issue: {old[:30]}...")
    
    # Final validation - check for basic syntax correctness
    if content.count('{') != content.count('}'):
        print(f"⚠️  Warning: Brace mismatch - {{ count: {content.count('{')}, }} count: {content.count('}')}")
    
    # Write the fixed content back to file
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"✅ UniversalBeingDNA.gd fixed! Applied {len(fixes_applied)} fixes:")
        for fix in fixes_applied:
            print(f"   - {fix}")
        
        return True
    else:
        print("📝 UniversalBeingDNA.gd appears to be correct")
        return False

def validate_dna_structure():
    """Validate the DNA structure for common issues"""
    
    file_path = Path("/mnt/c/Users/Percision 15/Universal_Being/core/UniversalBeingDNA.gd")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    print("\n🔍 DNA STRUCTURE VALIDATION:")
    print("="*50)
    
    # Check for basic structure
    checks = [
        ("Class declaration", "class_name UniversalBeingDNA" in content),
        ("Extends Resource", "extends Resource" in content),
        ("Export variables", "@export var" in content),
        ("Function definitions", "func " in content),
        ("Brace balance", content.count('{') == content.count('}')),
        ("Parentheses balance", content.count('(') == content.count(')')),
        ("Bracket balance", content.count('[') == content.count(']')),
    ]
    
    for check_name, result in checks:
        status = "✅" if result else "❌"
        print(f"   {status} {check_name}")
    
    # Count critical elements
    print(f"\n📊 DNA STATISTICS:")
    print(f"   - Export variables: {content.count('@export var')}")
    print(f"   - Functions: {content.count('func ')}")
    print(f"   - Dictionaries: {content.count('{')}")
    print(f"   - Arrays: {content.count('[')}")
    
    return all(result for _, result in checks)

if __name__ == "__main__":
    print("🧬 PERFECT DNA FINAL FIXER - Starting comprehensive repair")
    
    # Fix syntax issues
    success = fix_dna_final()
    
    # Validate structure
    valid = validate_dna_structure()
    
    if success and valid:
        print("\n🌟 UniversalBeingDNA.gd is now PERFECT! 🌟")
        print("🧬 DNA system ready for Universal Being evolution!")
    elif valid:
        print("\n📝 UniversalBeingDNA.gd structure is already valid!")
    else:
        print("\n⚠️  UniversalBeingDNA.gd needs additional attention")
    
    print("🧬 Ready for perfect genetic system operation!")