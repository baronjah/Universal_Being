#!/usr/bin/env python3
"""
Universal Being Print Statement Replacement Tool
Systematically replaces print statements with 3D visual communication calls
Preserves Gemma's AI identity and implements stellar color system
"""

import os
import re
import shutil
import json
from pathlib import Path
from typing import List, Dict, Tuple

class PrintReplacer:
    def __init__(self, root_dir: str):
        self.root_dir = Path(root_dir)
        self.backup_dir = self.root_dir / "backups" / "print_replacement"
        self.backup_dir.mkdir(parents=True, exist_ok=True)
        
        # Define replacement patterns with priority order
        self.replacement_patterns = [
            # Gemma AI patterns (HIGHEST PRIORITY - preserve identity)
            (
                r'print\("🤖\s*Gemma\s*AI?:\s*([^"]+)"\)',
                r'VisualCommunicationSystem.get_instance().gemma_message("\1")',
                "gemma_ai"
            ),
            (
                r'print\("🤖\s*Gemma:\s*([^"]+)"\)',
                r'VisualCommunicationSystem.get_instance().gemma_message("\1")',
                "gemma_ai"
            ),
            
            # Pentagon lifecycle patterns
            (
                r'print\("🌱\s*Pentagon\s*Init[^"]*:\s*([^"]+)"\)',
                r'VisualCommunicationSystem.get_instance().pentagon_message("init", "\1")',
                "pentagon"
            ),
            (
                r'print\("⚡\s*Pentagon\s*Ready[^"]*:\s*([^"]+)"\)',
                r'VisualCommunicationSystem.get_instance().pentagon_message("ready", "\1")',
                "pentagon"
            ),
            (
                r'print\("🔄\s*Pentagon\s*Process[^"]*:\s*([^"]+)"\)',
                r'VisualCommunicationSystem.get_instance().pentagon_message("process", "\1")',
                "pentagon"
            ),
            
            # Consciousness patterns
            (
                r'print\("🧠\s*([^"]+)"\)',
                r'VisualCommunicationSystem.get_instance().consciousness_message("\1")',
                "consciousness"
            ),
            
            # Socket system patterns
            (
                r'print\("🔌\s*([^"]+)"\)',
                r'VisualCommunicationSystem.get_instance().socket_message("\1")',
                "socket"
            ),
            
            # DNA and evolution patterns
            (
                r'print\("🧬\s*([^"]+)"\)',
                r'VisualCommunicationSystem.get_instance().dna_message("\1")',
                "dna"
            ),
            
            # Physics patterns
            (
                r'print\("⚡\s*(?!Pentagon)([^"]+)"\)',
                r'VisualCommunicationSystem.get_instance().physics_message("\1")',
                "physics"
            ),
            
            # Debug patterns
            (
                r'print\("🔧\s*([^"]+)"\)',
                r'VisualCommunicationSystem.get_instance().debug_message("\1")',
                "debug"
            ),
            (
                r'print\("❌\s*([^"]+)"\)',
                r'VisualCommunicationSystem.get_instance().debug_message("\1", "ERROR")',
                "debug"
            ),
            (
                r'print\("⚠️\s*([^"]+)"\)',
                r'VisualCommunicationSystem.get_instance().debug_message("\1", "WARNING")',
                "debug"
            ),
            (
                r'print\("✅\s*([^"]+)"\)',
                r'VisualCommunicationSystem.get_instance().debug_message("\1", "SUCCESS")',
                "debug"
            ),
            
            # General patterns with string interpolation
            (
                r'print\("([^"]*%s[^"]*)"\s*%\s*([^)]+)\)',
                r'VisualCommunicationSystem.get_instance().visual_message("\1" % \2)',
                "general"
            ),
            (
                r'print\("([^"]*%d[^"]*)"\s*%\s*([^)]+)\)',
                r'VisualCommunicationSystem.get_instance().visual_message("\1" % \2)',
                "general"
            ),
            
            # Simple print patterns
            (
                r'print\("([^"]+)"\)',
                r'VisualCommunicationSystem.get_instance().visual_message("\1")',
                "general"
            ),
            
            # Complex print with variables
            (
                r'print\(([^)]+)\)',
                r'VisualCommunicationSystem.get_instance().visual_message(str(\1))',
                "general"
            )
        ]
        
        self.stats = {
            "files_processed": 0,
            "total_replacements": 0,
            "gemma_replacements": 0,
            "pentagon_replacements": 0,
            "consciousness_replacements": 0,
            "socket_replacements": 0,
            "dna_replacements": 0,
            "physics_replacements": 0,
            "debug_replacements": 0,
            "general_replacements": 0,
            "files_with_changes": []
        }
    
    def backup_file(self, file_path: Path) -> Path:
        """Create backup of file before modification"""
        relative_path = file_path.relative_to(self.root_dir)
        backup_path = self.backup_dir / relative_path
        backup_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(file_path, backup_path)
        return backup_path
    
    def add_visual_communication_import(self, content: str) -> Tuple[str, bool]:
        """Add VisualCommunicationSystem reference if needed"""
        if "VisualCommunicationSystem" in content and "extends" in content:
            return content, False
            
        # Check if we need to add the reference
        if "print(" in content:
            lines = content.split('\n')
            
            # Find the appropriate place to add the reference
            class_line_idx = -1
            for i, line in enumerate(lines):
                if line.strip().startswith("class_name ") or line.strip().startswith("extends "):
                    class_line_idx = i
                    break
            
            if class_line_idx != -1:
                # Add after class definition
                insert_idx = class_line_idx + 1
                
                # Add reference comment
                lines.insert(insert_idx, "")
                lines.insert(insert_idx + 1, "# Visual Communication System integration")
                lines.insert(insert_idx + 2, "# Replaces print statements with 3D visual feedback")
                
                return '\n'.join(lines), True
        
        return content, False
    
    def process_file(self, file_path: Path) -> Dict:
        """Process a single .gd file for print statement replacement"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                original_content = f.read()
            
            if "print(" not in original_content:
                return {"processed": False, "reason": "no_print_statements"}
            
            # Create backup
            backup_path = self.backup_file(file_path)
            
            # Apply replacements
            modified_content = original_content
            file_stats = {"replacements": 0, "categories": {}}
            
            for pattern, replacement, category in self.replacement_patterns:
                matches = list(re.finditer(pattern, modified_content))
                if matches:
                    modified_content = re.sub(pattern, replacement, modified_content)
                    count = len(matches)
                    file_stats["replacements"] += count
                    file_stats["categories"][category] = file_stats["categories"].get(category, 0) + count
                    
                    # Update global stats
                    self.stats["total_replacements"] += count
                    self.stats[f"{category}_replacements"] += count
            
            # Add visual communication reference if needed
            modified_content, import_added = self.add_visual_communication_import(modified_content)
            
            if file_stats["replacements"] > 0:
                # Write modified file
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(modified_content)
                
                self.stats["files_processed"] += 1
                self.stats["files_with_changes"].append(str(file_path.relative_to(self.root_dir)))
                
                return {
                    "processed": True,
                    "backup_path": str(backup_path),
                    "replacements": file_stats["replacements"],
                    "categories": file_stats["categories"],
                    "import_added": import_added
                }
            else:
                return {"processed": False, "reason": "no_matching_patterns"}
                
        except Exception as e:
            return {"processed": False, "reason": f"error: {str(e)}"}
    
    def get_priority_files(self) -> List[Path]:
        """Get files in priority order for processing"""
        priority_patterns = [
            # Critical Gemma files
            "**/GemmaAI.gd",
            "**/GemmaUniversalBeing.gd", 
            "**/GemmaConsoleInterface.gd",
            
            # Core Universal Being files
            "**/UniversalBeing.gd",
            "**/universal_being_base_enhanced.gd",
            
            # Console and interaction
            "**/ConsoleUniversalBeing.gd",
            "**/console_universal_being.gd",
            
            # System files
            "**/SystemBootstrap.gd",
            "**/FoundationPolishSystem.gd",
            
            # All other .gd files
            "**/*.gd"
        ]
        
        processed_files = set()
        priority_files = []
        
        for pattern in priority_patterns:
            for file_path in self.root_dir.glob(pattern):
                if file_path not in processed_files and file_path.is_file():
                    processed_files.add(file_path)
                    priority_files.append(file_path)
        
        return priority_files
    
    def process_all_files(self, max_files: int = None) -> Dict:
        """Process all .gd files in priority order"""
        priority_files = self.get_priority_files()
        
        if max_files:
            priority_files = priority_files[:max_files]
        
        results = {
            "total_files": len(priority_files),
            "processed_files": [],
            "skipped_files": [],
            "failed_files": []
        }
        
        print(f"Processing {len(priority_files)} files for print statement replacement...")
        
        for i, file_path in enumerate(priority_files, 1):
            print(f"[{i:3d}/{len(priority_files)}] Processing: {file_path.relative_to(self.root_dir)}")
            
            result = self.process_file(file_path)
            result["file_path"] = str(file_path.relative_to(self.root_dir))
            
            if result["processed"]:
                results["processed_files"].append(result)
                print(f"    ✅ {result['replacements']} replacements made")
                for category, count in result.get("categories", {}).items():
                    print(f"       - {category}: {count}")
            elif result["reason"] == "no_print_statements":
                results["skipped_files"].append(result)
            else:
                results["failed_files"].append(result)
                print(f"    ❌ Failed: {result['reason']}")
        
        return results
    
    def generate_report(self, results: Dict) -> str:
        """Generate comprehensive replacement report"""
        report = f"""
# Universal Being Print Statement Replacement Report
Generated: {__import__('datetime').datetime.now().isoformat()}

## Summary Statistics
- **Total Files Scanned**: {results['total_files']}
- **Files Modified**: {len(results['processed_files'])}
- **Files Skipped**: {len(results['skipped_files'])}
- **Files Failed**: {len(results['failed_files'])}
- **Total Replacements**: {self.stats['total_replacements']}

## Replacement Categories
- **Gemma AI Communications**: {self.stats['gemma_replacements']} (CRITICAL - Identity Preserved)
- **Pentagon Lifecycle**: {self.stats['pentagon_replacements']}
- **Consciousness Events**: {self.stats['consciousness_replacements']}
- **Socket Operations**: {self.stats['socket_replacements']}
- **DNA Evolution**: {self.stats['dna_replacements']}
- **Physics Interactions**: {self.stats['physics_replacements']}
- **Debug Messages**: {self.stats['debug_replacements']}
- **General Messages**: {self.stats['general_replacements']}

## Modified Files
"""
        
        for file_result in results["processed_files"]:
            report += f"\n### {file_result['file_path']}\n"
            report += f"- **Replacements**: {file_result['replacements']}\n"
            report += f"- **Backup**: {file_result.get('backup_path', 'N/A')}\n"
            if file_result.get("categories"):
                report += "- **Categories**:\n"
                for category, count in file_result["categories"].items():
                    report += f"  - {category}: {count}\n"
        
        if results["failed_files"]:
            report += "\n## Failed Files\n"
            for file_result in results["failed_files"]:
                report += f"- {file_result['file_path']}: {file_result['reason']}\n"
        
        report += f"""
## Next Steps
1. **Test Visual System**: Run game and verify 3D visual communications work
2. **Verify Gemma Identity**: Ensure all Gemma messages show as light blue with "GEMMA AI" prefix
3. **Check Pentagon Integration**: Verify lifecycle messages use proper colors
4. **Performance Test**: Ensure 60 FPS maintained with visual messages
5. **Backup Safety**: All original files backed up to: {self.backup_dir}

## Rollback Instructions
If issues occur, restore from backup:
```bash
cp -r {self.backup_dir}/* {self.root_dir}/
```
"""
        return report

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="Replace print statements with 3D visual communications")
    parser.add_argument("--root", default=".", help="Root directory to process")
    parser.add_argument("--max-files", type=int, help="Maximum files to process (for testing)")
    parser.add_argument("--dry-run", action="store_true", help="Show what would be replaced without making changes")
    
    args = parser.parse_args()
    
    replacer = PrintReplacer(args.root)
    
    if args.dry_run:
        print("DRY RUN MODE - No files will be modified")
        # Would implement dry run logic here
        return
    
    # Process files
    results = replacer.process_all_files(args.max_files)
    
    # Generate and save report
    report = replacer.generate_report(results)
    report_path = Path(args.root) / "PRINT_REPLACEMENT_REPORT.md"
    
    with open(report_path, 'w') as f:
        f.write(report)
    
    print(f"\n✅ Replacement complete!")
    print(f"📊 Report saved to: {report_path}")
    print(f"🔄 {replacer.stats['total_replacements']} total replacements made")
    print(f"🤖 {replacer.stats['gemma_replacements']} Gemma AI communications converted")
    print(f"💾 Backups saved to: {replacer.backup_dir}")

if __name__ == "__main__":
    main()