#!/usr/bin/env python3
"""
Quick cleanup for duplicate class conflicts
Removes problematic global class declarations that conflict
"""
import os
from pathlib import Path

def cleanup_class_conflicts():
    """Remove duplicate class declarations causing conflicts"""
    project_root = Path("/mnt/c/Users/Percision 15/Universal_Being")
    
    # Files causing "hides a global script class" errors
    problematic_files = [
        "scripts_backup/cosmic_lod_system.gd",
        "scripts_backup/matrix_chunk_system.gd", 
        "scripts_backup/lightweight_chunk_system.gd",
        "scripts_backup/GemmaUniversalBeing.gd",
        "scripts_backup/generation_coordinator.gd",
        "scripts/consciousness_revolution_command.gd"
    ]
    
    print("🧹 CLEANING DUPLICATE CLASS CONFLICTS")
    print("=" * 50)
    
    for file_path in problematic_files:
        full_path = project_root / file_path
        if full_path.exists():
            print(f"📁 Processing: {file_path}")
            
            # Read the file
            with open(full_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Check if it has a class_name declaration
            if "class_name " in content:
                lines = content.split('\n')
                new_lines = []
                
                for line in lines:
                    # Comment out class_name declarations to prevent conflicts
                    if line.strip().startswith("class_name "):
                        new_lines.append("# " + line + "  # Commented to prevent duplicate class conflict")
                        print(f"  ✅ Commented out: {line.strip()}")
                    else:
                        new_lines.append(line)
                
                # Write back the modified content
                with open(full_path, 'w', encoding='utf-8') as f:
                    f.write('\n'.join(new_lines))
                    
                print(f"  💾 Updated: {file_path}")
            else:
                print(f"  ℹ️ No class_name found in: {file_path}")
        else:
            print(f"  ❌ File not found: {file_path}")
    
    print("\n🎯 CLEANUP COMPLETE")
    print("Duplicate class conflicts should now be resolved!")

if __name__ == "__main__":
    cleanup_class_conflicts()