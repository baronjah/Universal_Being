#!/usr/bin/env python3
"""
Universal Being Project Cleaner
================================
Organizes the project according to JSH's perfect 20W brain architecture.

ALLOWED STRUCTURE:
- Root: Only icon, project files, main.*, and info files
- addons/          = Godot addons only  
- ai_integration/  = AI companion systems
- ai_models/       = Gemma AI models
- akashic_library/ = ALL scattered assets/components/beings/etc
- autoloads/       = Autoload .gd files
- core/            = Core system .gd files  
- scripts/         = All other .gd files
- scenes/          = All .tscn files
- docs/            = Documentation .md files
- tools/           = Python/shell tools

EVERYTHING ELSE GETS SORTED OR DELETED.
"""

import os
import shutil
import json
from pathlib import Path
from typing import List, Dict, Set

class UniversalBeingCleaner:
    def __init__(self, project_root: str):
        self.root = Path(project_root)
        self.log = []
        
        # ALLOWED FOLDERS (JSH's perfect structure)
        self.allowed_folders = {
            '.godot', '.claude', '.git', '.cursor',  # System folders
            'addons', 'ai_integration', 'ai_models',  # External systems  
            'akashic_library',  # THE unified library
            'autoloads', 'core', 'scripts',  # Scripts organized
            'scenes', 'docs', 'tools'  # Content organized
        }
        
        # ALLOWED ROOT FILES ONLY
        self.allowed_root_files = {
            'icon.svg', 'project.godot', 'main.gd', 'main.tscn',
            '.cursorrules', 'CLAUDE.md', 'CLAUDE_CODE.md', 'CLAUDE_DESKTOP.md',
            'clean_project.py',    # Project cleaner
            'validate_pentagon.py', # Pentagon validator
            'clean_docs.py'        # Docs organizer
        }
        
        # CONSOLIDATION TARGETS (scattered mess → akashic_library)
        self.akashic_sources = {
            'libraries', 'assets', 'beings', 'cli', 'components', 
            'data', 'effects', 'library', 'systems', 'materials',
            'saves', 'narrative', 'collaboration'
        }
        
        # CORE SYSTEM FILES (special .gd files)
        self.core_files = {
            'UniversalBeing', 'FloodGates', 'Pentagon', 'AkashicRecords',
            'Component', 'Connector', 'UniversalBeingControl', 'UniversalBeingDNA',
            'UniversalBeingInterface', 'UniversalBeingSocket', 'ZipPackageManager'
        }
        
        # AUTOLOAD FILES  
        self.autoload_files = {
            'SystemBootstrap', 'GemmaAI', 'akashic_loader'
        }

    def log_action(self, action: str, source: str, target: str = ""):
        """Log cleanup actions"""
        entry = f"{action}: {source}"
        if target:
            entry += f" → {target}"
        self.log.append(entry)
        print(f"🧹 {entry}")

    def ensure_structure(self):
        """Create the perfect folder structure"""
        for folder in self.allowed_folders:
            folder_path = self.root / folder
            if not folder_path.exists() and not folder.startswith('.'):
                folder_path.mkdir(exist_ok=True)
                self.log_action("CREATE", str(folder))

    def clean_root_directory(self):
        """Clean root - only allowed files remain"""
        print("🎯 CLEANING ROOT DIRECTORY...")
        
        for item in self.root.iterdir():
            if item.name.startswith('.'):
                continue  # Skip hidden system folders
                
            if item.is_file():
                if item.name not in self.allowed_root_files:
                    if item.suffix == '.md':
                        self.move_to_docs(item)
                    elif item.suffix in ['.py', '.sh']:
                        self.move_to_tools(item)
                    elif item.suffix == '.gd':
                        self.sort_script_file(item)
                    elif item.suffix == '.tscn':
                        self.move_to_scenes(item)
                    else:
                        self.log_action("DELETE", item.name)
                        item.unlink()
            
            elif item.is_dir():
                if item.name not in self.allowed_folders:
                    self.handle_forbidden_folder(item)

    def handle_forbidden_folder(self, folder_path: Path):
        """Handle folders that shouldn't be in root"""
        folder_name = folder_path.name
        
        if folder_name in self.akashic_sources:
            self.consolidate_to_akashic(folder_path)
        elif folder_name in ['debug', 'testing', 'tests', 'test']:
            self.consolidate_to_tools(folder_path)
        elif folder_name in ['ui', 'interfaces', 'examples', 'demo']:
            self.consolidate_to_scenes(folder_path)
        else:
            # Try to salvage useful content
            self.salvage_folder_contents(folder_path)

    def consolidate_to_akashic(self, source_folder: Path):
        """Move folder contents to akashic_library"""
        target = self.root / 'akashic_library' / source_folder.name
        target.mkdir(parents=True, exist_ok=True)
        
        self.log_action("CONSOLIDATE", str(source_folder), str(target))
        shutil.copytree(source_folder, target, dirs_exist_ok=True)
        shutil.rmtree(source_folder)

    def consolidate_to_tools(self, source_folder: Path):
        """Move debugging/testing tools to tools/"""
        for item in source_folder.rglob('*'):
            if item.is_file():
                if item.suffix in ['.py', '.sh', '.gd']:
                    target = self.root / 'tools' / item.name
                    target.parent.mkdir(exist_ok=True)
                    shutil.move(str(item), str(target))
                    self.log_action("MOVE", str(item), str(target))
        
        shutil.rmtree(source_folder)
        self.log_action("DELETE", str(source_folder))

    def consolidate_to_scenes(self, source_folder: Path):
        """Move UI/interface scenes to scenes/"""
        target_dir = self.root / 'scenes' / source_folder.name
        target_dir.mkdir(parents=True, exist_ok=True)
        
        for item in source_folder.rglob('*.tscn'):
            target = target_dir / item.name
            shutil.move(str(item), str(target))
            self.log_action("MOVE", str(item), str(target))
        
        shutil.rmtree(source_folder)

    def salvage_folder_contents(self, folder_path: Path):
        """Salvage useful files from unknown folders"""
        for item in folder_path.rglob('*'):
            if item.is_file():
                if item.suffix == '.gd':
                    self.sort_script_file(item)
                elif item.suffix == '.tscn':
                    self.move_to_scenes(item)
                elif item.suffix == '.md':
                    self.move_to_docs(item)
                elif item.suffix in ['.py', '.sh']:
                    self.move_to_tools(item)
                # Skip other files - probably cruft
        
        shutil.rmtree(folder_path)
        self.log_action("SALVAGE+DELETE", str(folder_path))

    def sort_script_file(self, gd_file: Path):
        """Sort .gd files into autoloads/core/scripts based on content"""
        file_stem = gd_file.stem
        
        if any(name in file_stem for name in self.autoload_files):
            target = self.root / 'autoloads' / gd_file.name
        elif any(name in file_stem for name in self.core_files):
            target = self.root / 'core' / gd_file.name
        else:
            target = self.root / 'scripts' / gd_file.name
        
        target.parent.mkdir(exist_ok=True)
        shutil.move(str(gd_file), str(target))
        self.log_action("SORT", str(gd_file), str(target))

    def move_to_scenes(self, tscn_file: Path):
        """Move .tscn files to scenes/"""
        target = self.root / 'scenes' / tscn_file.name
        target.parent.mkdir(exist_ok=True)
        shutil.move(str(tscn_file), str(target))
        self.log_action("MOVE", str(tscn_file), str(target))

    def move_to_docs(self, md_file: Path):
        """Move .md files to docs/"""
        target = self.root / 'docs' / md_file.name
        target.parent.mkdir(exist_ok=True)
        shutil.move(str(md_file), str(target))
        self.log_action("MOVE", str(md_file), str(target))

    def move_to_tools(self, tool_file: Path):
        """Move tool files to tools/"""
        target = self.root / 'tools' / tool_file.name
        target.parent.mkdir(exist_ok=True)
        shutil.move(str(tool_file), str(target))
        self.log_action("MOVE", str(tool_file), str(target))

    def organize_existing_allowed_folders(self):
        """Clean up the allowed folders that already exist"""
        print("🎯 ORGANIZING EXISTING FOLDERS...")
        
        # Clean up scenes/ - ensure only .tscn files
        scenes_dir = self.root / 'scenes'
        if scenes_dir.exists():
            for item in scenes_dir.rglob('*'):
                if item.is_file() and item.suffix != '.tscn':
                    if item.suffix == '.gd':
                        self.sort_script_file(item)
                    else:
                        item.unlink()
                        self.log_action("DELETE", str(item))

        # Clean up docs/ - ensure only .md files  
        docs_dir = self.root / 'docs'
        if docs_dir.exists():
            for item in docs_dir.rglob('*'):
                if item.is_file() and item.suffix != '.md':
                    if item.suffix in ['.py', '.sh']:
                        self.move_to_tools(item)
                    else:
                        item.unlink()
                        self.log_action("DELETE", str(item))

    def generate_report(self):
        """Generate cleanup report"""
        report_path = self.root / 'docs' / 'CLEANUP_REPORT.md'
        report_path.parent.mkdir(exist_ok=True)
        
        with open(report_path, 'w') as f:
            f.write("# Universal Being Project Cleanup Report\\n\\n")
            f.write(f"**Actions Performed:** {len(self.log)}\\n\\n")
            f.write("## Perfect Structure Achieved\\n\\n")
            
            f.write("```\\n")
            f.write("Universal_Being/\\n")
            f.write("├── main.tscn (THE GAME)\\n")
            f.write("├── main.gd\\n")  
            f.write("├── project.godot\\n")
            f.write("├── icon.svg\\n")
            f.write("├── CLAUDE*.md\\n")
            f.write("│\\n")
            f.write("├── addons/          # Godot plugins\\n")
            f.write("├── ai_integration/  # AI companion\\n")
            f.write("├── ai_models/       # Gemma models\\n")
            f.write("├── akashic_library/ # ALL assets unified\\n")
            f.write("├── autoloads/       # System singletons\\n")
            f.write("├── core/            # Core systems\\n")
            f.write("├── scripts/         # Game scripts\\n")
            f.write("├── scenes/          # All .tscn files\\n")
            f.write("├── docs/            # Documentation\\n")
            f.write("└── tools/           # Dev tools\\n")
            f.write("```\\n\\n")
            
            f.write("## Cleanup Actions\\n\\n")
            for action in self.log:
                f.write(f"- {action}\\n")
        
        print(f"📊 Cleanup report saved: {report_path}")

    def run_cleanup(self):
        """Execute the full cleanup process"""
        print("🌟 STARTING UNIVERSAL BEING PROJECT CLEANUP...")
        print(f"📁 Project: {self.root}")
        print(f"🎯 Target: JSH's Perfect 20W Brain Architecture")
        print()
        
        # Create perfect structure
        self.ensure_structure()
        
        # Clean root directory
        self.clean_root_directory()
        
        # Organize existing folders
        self.organize_existing_allowed_folders()
        
        # Generate report
        self.generate_report()
        
        print()
        print("✨ CLEANUP COMPLETE!")
        print(f"🎯 Actions performed: {len(self.log)}")
        print("🎮 Your project is now PERFECTLY organized!")
        print("📊 See docs/CLEANUP_REPORT.md for details")

def main():
    """Main cleanup function"""
    project_root = os.path.dirname(os.path.abspath(__file__))
    cleaner = UniversalBeingCleaner(project_root)
    cleaner.run_cleanup()

if __name__ == "__main__":
    main()