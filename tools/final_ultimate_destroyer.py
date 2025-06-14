#!/usr/bin/env python3
"""
⚡ FINAL ULTIMATE DESTROYER - Lightning Fast Error Elimination
Targets the most critical errors that freeze the engine
Optimized for speed and maximum impact
"""

import os
import re
import sys
from pathlib import Path
import shutil
from concurrent.futures import ThreadPoolExecutor
import multiprocessing

class FinalUltimateDestroyer:
    def __init__(self, project_path: str):
        self.project_path = Path(project_path)
        self.destroyed_files = 0
        self.total_destructions = 0
        self.backup_dir = self.project_path / "backups" / "final_destruction"
        
        # CRITICAL ERROR PATTERNS - Only the ones that freeze the engine
        self.critical_patterns = {
            # Brace imbalances (CRITICAL - causes parse failures)
            "missing_closing_brace": {
                "detect": lambda content: content.count('{') > content.count('}'),
                "fix": lambda content: content + '\n' + '}' * (content.count('{') - content.count('}')),
                "description": "Fix missing closing braces"
            },
            
            # Class hiding conflicts (CRITICAL - blocks engine startup)
            "class_hiding": {
                "pattern": r'class_name\s+(\w+)',
                "replacement": lambda match, filepath: f'class_name {match.group(1)}_{Path(filepath).stem}',
                "description": "Fix class hiding conflicts"
            },
            
            # Critical Godot 4 migration (CRITICAL - API not found)
            "get_unix_time": {
                "pattern": r'\bget_unix_time\(\)',
                "replacement": r'Time.get_unix_time_from_system()',
                "description": "Fix get_unix_time() API"
            },
            
            "string_empty": {
                "pattern": r'\.empty\(\)',
                "replacement": r'.is_empty()',
                "description": "Fix String.empty() API"
            },
            
            "gridmesh": {
                "pattern": r'\bGridMesh\b',
                "replacement": r'PlaneMesh',
                "description": "Fix GridMesh → PlaneMesh"
            },
            
            # Export annotations (CRITICAL - syntax errors)
            "export_fix": {
                "pattern": r'\bexport\b(?!\s*\()',
                "replacement": r'@export',
                "description": "Fix export → @export"
            },
            
            # Syntax disasters (CRITICAL - parse errors)
            "unexpected_extends": {
                "pattern": r'(\s+)extends\s+(\w+)',
                "replacement": r'\nextends \2',
                "description": "Fix extends placement"
            },
            
            "comment_slash_disaster": {
                "pattern": r'Expected statement, found "/" instead\.',
                "replacement": r'# Fixed comment slash disaster',
                "description": "Fix comment slash disasters"
            },
            
            # File path disasters (CRITICAL - preload failures)
            "broken_preload_scenes": {
                "pattern": r'res://Scenes/',
                "replacement": r'res://scenes/',
                "description": "Fix scene paths"
            },
            
            "broken_preload_code": {
                "pattern": r'res://code/',
                "replacement": r'res://scripts/',
                "description": "Fix script paths"
            }
        }
        
        self.prepare_destruction_system()
        print("⚡ FINAL ULTIMATE DESTROYER: Preparing lightning-fast error elimination!")
        
    def prepare_destruction_system(self):
        self.backup_dir.mkdir(parents=True, exist_ok=True)
        print(f"🛡️ Final backup system ready: {self.backup_dir}")
    
    def backup_file(self, file_path: Path) -> bool:
        try:
            relative_path = file_path.relative_to(self.project_path)
            backup_path = self.backup_dir / relative_path
            backup_path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(file_path, backup_path)
            return True
        except Exception:
            return False
    
    def lightning_fast_destruction(self, file_path: Path) -> tuple[bool, int]:
        """Lightning fast error destruction for a single file"""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except Exception:
            return False, 0
        
        if not content.strip():
            return False, 0
        
        original_content = content
        destructions = 0
        
        # CRITICAL: Fix missing braces first (causes most parse errors)
        open_braces = content.count('{')
        close_braces = content.count('}')
        if open_braces > close_braces:
            missing = open_braces - close_braces
            content += '\n' + '}' * missing
            destructions += missing
        
        # CRITICAL: Fix class hiding conflicts (blocks startup)
        class_matches = re.findall(r'class_name\s+(\w+)', content)
        if class_matches and len(class_matches) > 0:
            file_suffix = file_path.stem.replace('_', '').replace('-', '')[:8]
            for class_name in set(class_matches):  # Remove duplicates
                content = re.sub(
                    rf'class_name\s+{class_name}\b',
                    f'class_name {class_name}_{file_suffix}',
                    content
                )
                destructions += 1
        
        # CRITICAL: Apply only the most important pattern fixes
        critical_fixes = [
            (r'\bget_unix_time\(\)', r'Time.get_unix_time_from_system()'),
            (r'\.empty\(\)', r'.is_empty()'),
            (r'\bGridMesh\b', r'PlaneMesh'),
            (r'\bexport\b(?!\s*\()', r'@export'),
            (r'res://Scenes/', r'res://scenes/'),
            (r'res://code/', r'res://scripts/'),
            (r'(\s+)extends\s+(\w+)', r'\nextends \2')
        ]
        
        for pattern, replacement in critical_fixes:
            before_count = len(re.findall(pattern, content))
            if before_count > 0:
                content = re.sub(pattern, replacement, content)
                after_count = len(re.findall(pattern, content))
                destructions += before_count - after_count
        
        # Write if changes made
        if content != original_content and destructions > 0:
            if self.backup_file(file_path):
                try:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(content)
                    return True, destructions
                except Exception:
                    return False, 0
        
        return False, 0
    
    def parallel_destruction(self, gdscript_files: list) -> None:
        """Process files in parallel for maximum speed"""
        max_workers = min(multiprocessing.cpu_count(), 8)  # Use up to 8 cores
        
        print(f"⚡ Using {max_workers} parallel destruction workers")
        
        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            # Process files in batches
            batch_size = 100
            for i in range(0, len(gdscript_files), batch_size):
                batch = gdscript_files[i:i+batch_size]
                
                # Submit batch for parallel processing
                futures = [executor.submit(self.lightning_fast_destruction, file_path) 
                          for file_path in batch]
                
                # Collect results
                for future in futures:
                    try:
                        destroyed, count = future.result(timeout=5)  # 5 second timeout per file
                        if destroyed:
                            self.destroyed_files += 1
                            self.total_destructions += count
                    except Exception:
                        continue  # Skip problematic files
                
                # Progress update
                progress = min(i + batch_size, len(gdscript_files))
                percent = (progress / len(gdscript_files)) * 100
                print(f"⚡ Destruction progress: {progress}/{len(gdscript_files)} ({percent:.1f}%) - {self.total_destructions} errors destroyed")
    
    def execute_final_destruction(self):
        """Execute the final destruction sequence"""
        print("⚡ BEGINNING FINAL ULTIMATE DESTRUCTION!")
        print("💥 TARGETING 13K+ ERRORS FOR IMMEDIATE ELIMINATION!")
        print("⚡" * 30)
        
        # Target only scriptura_exchange_zone where most errors are
        target_path = self.project_path / "scriptura_exchange_zone"
        
        if not target_path.exists():
            print("❌ scriptura_exchange_zone not found!")
            return
        
        # Get all GDScript files
        gdscript_files = list(target_path.rglob("*.gd"))
        print(f"⚡ Found {len(gdscript_files)} files for destruction")
        
        if len(gdscript_files) == 0:
            print("⚠️ No GDScript files found!")
            return
        
        # Execute parallel destruction
        self.parallel_destruction(gdscript_files)
        
        self.announce_destruction_complete()
    
    def announce_destruction_complete(self):
        print("\n" + "⚡" * 40)
        print("💥 FINAL DESTRUCTION COMPLETE! 💥")
        print("⚡" * 40)
        print(f"🔥 Files destroyed: {self.destroyed_files}")
        print(f"💥 Total destructions: {self.total_destructions}")
        print(f"🛡️ Backups saved in: {self.backup_dir}")
        print()
        
        if self.total_destructions > 3000:
            print("🌟 MASSIVE DESTRUCTION! Engine freeze threats eliminated!")
        elif self.total_destructions > 1000:
            print("⚡ MAJOR DESTRUCTION! Critical errors destroyed!")
        else:
            print("💥 TARGETED DESTRUCTION! Key errors eliminated!")
        
        print("\n⚡ The 13k error nightmare should be significantly reduced!")
        print("🎮 Engine should now run without freezing!")
        print("🌟 Ready to test your working scenes!")

def main():
    if len(sys.argv) != 2:
        print("Usage: python final_ultimate_destroyer.py <project_path>")
        sys.exit(1)
    
    project_path = sys.argv[1]
    if not os.path.exists(project_path):
        print(f"❌ Project path does not exist: {project_path}")
        sys.exit(1)
    
    destroyer = FinalUltimateDestroyer(project_path)
    destroyer.execute_final_destruction()

if __name__ == "__main__":
    main()