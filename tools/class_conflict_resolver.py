#!/usr/bin/env python3
"""
🎯 CLASS CONFLICT RESOLVER - Surgical removal of duplicate class declarations
Protects core/UniversalBeing.gd while removing scriptura duplicates
"""

import os
import re
from pathlib import Path
import shutil

class ClassConflictResolver:
    def __init__(self, project_path: str):
        self.project_path = Path(project_path)
        self.protected_core = self.project_path / "core" / "UniversalBeing.gd"
        self.backup_dir = self.project_path / "backups" / "class_conflict_fixes"
        self.fixed_files = 0
        
        self.backup_dir.mkdir(parents=True, exist_ok=True)
        print("🎯 CLASS CONFLICT RESOLVER: Protecting core UniversalBeing.gd")
        print(f"🛡️ Protected file: {self.protected_core}")
    
    def backup_file(self, file_path: Path) -> bool:
        try:
            relative_path = file_path.relative_to(self.project_path)
            backup_path = self.backup_dir / relative_path
            backup_path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(file_path, backup_path)
            return True
        except Exception:
            return False
    
    def resolve_class_conflicts(self):
        """Remove duplicate class_name declarations in scriptura_exchange_zone"""
        print("🎯 Searching for duplicate UniversalBeing class declarations...")
        
        # Target only scriptura_exchange_zone
        target_path = self.project_path / "scriptura_exchange_zone"
        if not target_path.exists():
            print("✅ No scriptura_exchange_zone found - no conflicts to resolve")
            return
        
        gdscript_files = list(target_path.rglob("*.gd"))
        print(f"🎯 Scanning {len(gdscript_files)} files in scriptura_exchange_zone...")
        
        for file_path in gdscript_files:
            # Skip if this is our protected core file (shouldn't be, but safety first)
            if file_path.resolve() == self.protected_core.resolve():
                continue
            
            try:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
            except Exception:
                continue
            
            # Check if this file has conflicting class_name declarations
            class_declarations = re.findall(r'class_name\s+(UniversalBeing\w*)', content)
            
            if any('UniversalBeing' in decl for decl in class_declarations):
                # Back up the file
                if self.backup_file(file_path):
                    # Comment out the conflicting class_name lines
                    modified_content = re.sub(
                        r'^(\s*class_name\s+UniversalBeing\w*)$',
                        r'# DISABLED DUPLICATE: \1',
                        content,
                        flags=re.MULTILINE
                    )
                    
                    if modified_content != content:
                        try:
                            with open(file_path, 'w', encoding='utf-8') as f:
                                f.write(modified_content)
                            self.fixed_files += 1
                            print(f"   🎯 Fixed: {file_path.relative_to(self.project_path)}")
                        except Exception:
                            continue
        
        print(f"\n🎯 CLASS CONFLICT RESOLUTION COMPLETE!")
        print(f"✅ Files fixed: {self.fixed_files}")
        print(f"🛡️ Core UniversalBeing.gd: PROTECTED")
        print(f"📁 Backups: {self.backup_dir}")
        print("\n🌟 Your core UniversalBeing architecture is now the ONLY UniversalBeing!")

def main():
    import sys
    if len(sys.argv) != 2:
        print("Usage: python class_conflict_resolver.py <project_path>")
        sys.exit(1)
    
    project_path = sys.argv[1]
    if not os.path.exists(project_path):
        print(f"❌ Project path does not exist: {project_path}")
        sys.exit(1)
    
    resolver = ClassConflictResolver(project_path)
    resolver.resolve_class_conflicts()

if __name__ == "__main__":
    main()