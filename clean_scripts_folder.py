#!/usr/bin/env python3
"""
Universal Being Scripts Folder Cleaner
Organizes the 236+ scripts in the scripts/ folder based on analysis
Generated: 2025-06-06 - Post-Architecture Documentation
"""

import os
import shutil
from pathlib import Path
import json

class ScriptsCleaner:
    def __init__(self, project_root=None):
        # Auto-detect project root from script location
        if project_root is None:
            project_root = os.path.dirname(os.path.abspath(__file__))
        
        self.project_root = Path(project_root)
        self.scripts_dir = self.project_root / "scripts"
        
        # Track operations
        self.stats = {
            "deleted": 0,
            "archived": 0,
            "moved_to_beings": 0,
            "moved_to_systems": 0,
            "moved_to_tests": 0,
            "moved_to_tools": 0,
            "kept_in_scripts": 0
        }
        
        self.operations_log = []
    
    def log_operation(self, operation, file_path, destination=None):
        """Log an operation for reporting"""
        entry = {
            "operation": operation,
            "file": str(file_path),
            "destination": str(destination) if destination else None
        }
        self.operations_log.append(entry)
        print(f"  {operation}: {file_path.name}")
        
    def delete_empty_files(self):
        """Delete completely empty or broken files"""
        print("🗑️ Deleting empty/broken files...")
        
        empty_files = [
            "socket_cell_universal_being.gd",
            "universal_being_template.gd"
        ]
        
        for filename in empty_files:
            file_path = self.scripts_dir / filename
            if file_path.exists() and file_path.stat().st_size <= 1:
                file_path.unlink()
                self.stats["deleted"] += 1
                self.log_operation("DELETED", file_path)
    
    def remove_duplicates(self):
        """Remove files that are duplicated in other directories"""
        print("🔄 Removing duplicate files...")
        
        duplicates = [
            "AkashicLibrary.gd",  # Exists in systems/
            "input_focus_manager.gd",  # Exists in systems/input/
            # Note: Check UniversalConsole.gd for updates before removing
        ]
        
        for filename in duplicates:
            file_path = self.scripts_dir / filename
            if file_path.exists():
                # Check if the duplicate has unique content
                if self.should_preserve_duplicate(file_path):
                    print(f"    ⚠️ Preserving {filename} - has unique content")
                    continue
                    
                file_path.unlink()
                self.stats["deleted"] += 1
                self.log_operation("DELETED (duplicate)", file_path)
    
    def should_preserve_duplicate(self, file_path):
        """Check if a duplicate file has unique content worth preserving"""
        # For now, preserve all duplicates - manual review needed
        return True
    
    def create_organization_folders(self):
        """Create the organizational folder structure"""
        print("📁 Creating organizational folders...")
        
        folders = [
            self.scripts_dir / "archive",
            self.scripts_dir / "tools", 
            self.scripts_dir / "tests",
            self.scripts_dir / "beings",
            self.scripts_dir / "bridges",
            self.project_root / "tests"  # Main tests folder
        ]
        
        for folder in folders:
            folder.mkdir(parents=True, exist_ok=True)
            print(f"  Created: {folder}")
    
    def categorize_and_move_scripts(self):
        """Categorize and move scripts to appropriate locations"""
        print("📦 Categorizing and moving scripts...")
        
        # Archive candidates - old, legacy, fix scripts
        archive_patterns = [
            "main_OLD_", "main_SIMPLE", "_fix.gd", "_fixed.gd", 
            "systembootstrap_quickfix", "immediate_fix", 
            "performance_fix_", "console_butterfly_fix",
            "GemmaUniverseInjector_enhancements", "enhanced_",
            "quick_", "simple_", "_old."
        ]
        
        # Test scripts
        test_patterns = [
            "test_", "debug_", "monitor_", "run_tests", 
            "run_path_", "run_asset_", "diagnostic",
            "health_check", "integration_test", "validation"
        ]
        
        # Being scripts
        being_patterns = [
            "ButterflyUniversalBeing", "TreeUniversalBeing", 
            "PortalUniversalBeing", "SimpleMovablePlasmoid",
            "player_universal_being", "ground_universal_being",
            "light_universal_being", "icon_universal_being"
        ]
        
        # Tool/utility scripts
        tool_patterns = [
            "validator", "checker", "audit", "scanner",
            "gdscript_", "naming_", "path_", "asset_",
            "archaeological_", "component_loader"
        ]
        
        # AI Bridge scripts
        bridge_patterns = [
            "chatgpt_", "claude_", "google_gemini_", 
            "remote_godot_", "gemini_api", "bridge"
        ]
        
        # System scripts that should move to systems/
        system_patterns = [
            "ConsciousnessFeedbackSystem", "FoundationPolishSystem",
            "consciousness_", "foundation_", "feedback_",
            "enlightened_", "pentagon_network_"
        ]
        
        # Check if scripts directory exists
        if not self.scripts_dir.exists():
            print(f"  ⚠️ Scripts directory not found: {self.scripts_dir}")
            return
        
        # Process all .gd files in scripts/
        for file_path in self.scripts_dir.glob("*.gd"):
            filename = file_path.name
            moved = False
            
            # Check each category
            if any(pattern in filename for pattern in archive_patterns):
                self.move_to_archive(file_path)
                moved = True
            elif any(pattern in filename for pattern in test_patterns):
                self.move_to_tests(file_path)
                moved = True
            elif any(pattern in filename for pattern in being_patterns):
                self.move_to_beings(file_path)
                moved = True
            elif any(pattern in filename for pattern in bridge_patterns):
                self.move_to_bridges(file_path)
                moved = True
            elif any(pattern in filename for pattern in tool_patterns):
                self.move_to_tools(file_path)
                moved = True
            elif any(pattern in filename for pattern in system_patterns):
                self.move_to_systems(file_path)
                moved = True
            
            if not moved:
                self.stats["kept_in_scripts"] += 1
    
    def move_to_archive(self, file_path):
        """Move file to archive folder"""
        destination = self.scripts_dir / "archive" / file_path.name
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(file_path), str(destination))
        self.stats["archived"] += 1
        self.log_operation("ARCHIVED", file_path, destination)
    
    def move_to_tests(self, file_path):
        """Move file to tests folder"""
        # Move to main tests/ folder for better organization
        destination = self.project_root / "tests" / file_path.name
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(file_path), str(destination))
        self.stats["moved_to_tests"] += 1
        self.log_operation("MOVED TO TESTS", file_path, destination)
    
    def move_to_beings(self, file_path):
        """Move file to beings folder structure"""
        # Determine subfolder based on being type
        filename = file_path.name
        if "Butterfly" in filename:
            subfolder = "butterfly"
        elif "Tree" in filename:
            subfolder = "tree"  
        elif "Portal" in filename:
            subfolder = "portal"
        elif "player" in filename:
            subfolder = "player"
        else:
            subfolder = "misc"
            
        destination_dir = self.project_root / "beings" / subfolder
        destination_dir.mkdir(parents=True, exist_ok=True)
        destination = destination_dir / file_path.name
        
        shutil.move(str(file_path), str(destination))
        self.stats["moved_to_beings"] += 1
        self.log_operation("MOVED TO BEINGS", file_path, destination)
    
    def move_to_bridges(self, file_path):
        """Move AI bridge files to bridges subfolder"""
        destination = self.scripts_dir / "bridges" / file_path.name
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(file_path), str(destination))
        self.stats["moved_to_tools"] += 1  # Count as tools
        self.log_operation("MOVED TO BRIDGES", file_path, destination)
    
    def move_to_tools(self, file_path):
        """Move file to tools folder"""
        destination = self.scripts_dir / "tools" / file_path.name
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(file_path), str(destination))
        self.stats["moved_to_tools"] += 1
        self.log_operation("MOVED TO TOOLS", file_path, destination)
    
    def move_to_systems(self, file_path):
        """Move system files to systems/ folder"""
        destination = self.project_root / "systems" / file_path.name
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(file_path), str(destination))
        self.stats["moved_to_systems"] += 1
        self.log_operation("MOVED TO SYSTEMS", file_path, destination)
    
    def check_file_sizes(self):
        """Check for suspiciously small files that might be stubs"""
        print("📏 Checking for stub files...")
        
        if not self.scripts_dir.exists():
            print("  Scripts directory not found")
            return
            
        stub_files = []
        for file_path in self.scripts_dir.rglob("*.gd"):
            try:
                if file_path.stat().st_size < 1000:  # Less than 1KB
                    stub_files.append((file_path, file_path.stat().st_size))
            except:
                continue
        
        if stub_files:
            print(f"  Found {len(stub_files)} small files (< 1KB):")
            for file_path, size in sorted(stub_files, key=lambda x: x[1]):
                print(f"    {file_path.name}: {size} bytes")
        else:
            print("  No suspiciously small files found")
    
    def generate_report(self):
        """Generate a comprehensive cleanup report"""
        print("\n📊 Generating cleanup report...")
        
        report = {
            "timestamp": "2025-06-06",
            "operation": "Scripts Folder Cleanup",
            "statistics": self.stats,
            "operations": self.operations_log,
            "recommendations": [
                "Review archived files periodically for deletion",
                "Check bridges/ folder for duplicate AI integrations", 
                "Validate that moved test files still run correctly",
                "Consider further organizing tools/ by function",
                "Review beings/ subfolders for consolidation opportunities"
            ]
        }
        
        # Create docs directory if it doesn't exist
        docs_dir = self.project_root / "docs"
        docs_dir.mkdir(parents=True, exist_ok=True)
        
        report_path = docs_dir / "SCRIPTS_CLEANUP_REPORT.md"
        
        with open(report_path, 'w', encoding='utf-8') as f:
            f.write("# Scripts Folder Cleanup Report\n")
            f.write(f"**Generated**: {report['timestamp']}\n\n")
            
            f.write("## Statistics\n")
            for key, value in self.stats.items():
                f.write(f"- **{key.replace('_', ' ').title()}**: {value}\n")
            
            f.write(f"\n**Total Operations**: {len(self.operations_log)}\n\n")
            
            f.write("## Operations Log\n")
            for op in self.operations_log:
                f.write(f"- {op['operation']}: `{Path(op['file']).name}`")
                if op['destination']:
                    f.write(f" → `{op['destination']}`")
                f.write("\n")
            
            f.write("\n## Recommendations\n")
            for rec in report['recommendations']:
                f.write(f"- {rec}\n")
        
        print(f"📄 Report saved to: {report_path}")
        
        # Also save JSON for programmatic access
        json_path = self.project_root / "scripts_cleanup_log.json"
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2)
    
    def run_cleanup(self):
        """Execute the complete cleanup process"""
        print("🧹 Universal Being Scripts Folder Cleanup")
        print("=" * 50)
        
        print(f"📂 Working directory: {self.scripts_dir}")
        
        # Check if scripts directory exists
        if not self.scripts_dir.exists():
            print(f"\n❌ ERROR: Scripts directory not found!")
            print(f"  Expected location: {self.scripts_dir}")
            print(f"  Current directory: {os.getcwd()}")
            print(f"\n💡 Make sure the 'scripts' folder exists in your project.")
            return
        
        initial_count = len(list(self.scripts_dir.glob("*.gd")))
        print(f"📊 Initial script count: {initial_count}")
        
        if initial_count == 0:
            print("\n⚠️ No GDScript files found in scripts folder!")
            print("  The scripts folder might be empty or files may have already been organized.")
            return
        
        # Create backup
        print("\n💾 Creating backup...")
        backup_dir = self.project_root / "scripts_backup"
        if backup_dir.exists():
            shutil.rmtree(backup_dir)
        shutil.copytree(self.scripts_dir, backup_dir)
        print(f"  Backup created at: {backup_dir}")
        
        # Execute cleanup steps
        self.delete_empty_files()
        self.create_organization_folders()
        self.categorize_and_move_scripts()
        self.remove_duplicates()  # After moving to avoid conflicts
        self.check_file_sizes()
        
        # Final statistics
        final_count = len(list(self.scripts_dir.glob("*.gd")))
        print(f"\n📊 Final script count in scripts/: {final_count}")
        print(f"📉 Reduction: {initial_count - final_count} files")
        
        self.generate_report()
        
        print("\n✅ Scripts folder cleanup complete!")
        print("🔍 Review the backup and report before deleting backup folder")

def main():
    # Get project root from current script location
    project_root = os.path.dirname(os.path.abspath(__file__))
    cleaner = ScriptsCleaner(project_root)
    cleaner.run_cleanup()

if __name__ == "__main__":
    main()
