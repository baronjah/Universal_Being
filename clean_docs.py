#!/usr/bin/env python3
"""
Docs Folder Cleaner
==================
Organizes the docs/ folder to keep only essential navigation files in root.

DOCS ARCHITECTURE (20W Brain Friendly):
- docs/                        # Root - Only essential navigation
  ├── README.md                # Project overview & navigation
  ├── PENTAGON_VALIDATION_REPORT.md  # Latest validation status
  ├── CLEANUP_REPORT.md        # Latest cleanup status
  ├── QUICK_START.md           # Get started immediately
  ├── archive/                 # All old reports & logs
  ├── guides/                  # How-to documentation
  ├── reports/                 # System reports & diagnostics
  └── vision/                  # Project vision & planning

ORGANIZING RULES:
1. Keep only 4 essential files in docs root
2. Move all error logs/fixes → archive/
3. Move all guides/tutorials → guides/
4. Move all diagnostic reports → reports/
5. Move all vision/planning docs → vision/
6. Create navigation README if missing
"""

import os
import shutil
from pathlib import Path
from typing import Dict, List
from datetime import datetime

class DocsOrganizer:
    def __init__(self, project_root: str):
        self.root = Path(project_root)
        self.docs_dir = self.root / 'docs'
        self.log = []
        
        # ESSENTIAL FILES - Keep in docs root
        self.essential_files = {
            'README.md',                    # Main navigation
            'PENTAGON_VALIDATION_REPORT.md', # Current validation
            'CLEANUP_REPORT.md',            # Current cleanup status
            'QUICK_START.md'                # Getting started guide
        }
        
        # ARCHIVE PATTERNS - Old reports, logs, fixes
        self.archive_patterns = [
            'ERROR_TRIAGE_LOG', 'GEMMA_ERROR_FIXES', 'GEMMA_FINAL_FIX',
            'GEMMA_FIXES_ROUND', 'EVOLUTION_DIAGNOSTIC', 'EVOLUTION_PLAN',
            'INTEGRATION_SUMMARY', 'SESSION_CHECKPOINT', '_FIXES', '_LOG',
            'PENTAGON_VALIDATION_REPORT_FIXED'
        ]
        
        # GUIDE PATTERNS - How-to documentation
        self.guide_patterns = [
            'GUIDE', 'TUTORIAL', 'HOW_TO', 'CUSTOM_TUTORIAL',
            'LEARNING_PATH', 'REFERENCE', 'NAMING_CONVENTIONS'
        ]
        
        # REPORT PATTERNS - System diagnostics
        self.report_patterns = [
            'DIAGNOSTIC', 'ANALYSIS', 'STATUS', 'SUMMARY', 
            'ARCHITECTURE', 'VALIDATION', 'HEALTH'
        ]
        
        # VISION PATTERNS - Planning & vision docs
        self.vision_patterns = [
            'VISION', 'PLAN', 'SPRINT', 'GOALS', 'PROGRESS',
            'WISHES', 'PRAISES', 'SUCCESS', 'COMPLETION'
        ]

    def organize_docs(self):
        """Organize the docs folder for 20W brain navigation"""
        print("📚 DOCS FOLDER ORGANIZER")
        print("=" * 40)
        print(f"📁 Target: {self.docs_dir}")
        print("🎯 Goal: Essential navigation files only")
        print()
        
        if not self.docs_dir.exists():
            print("📁 Creating docs/ directory...")
            self.docs_dir.mkdir()
            self.log_action("CREATE", "docs/")
        
        # Create organization structure
        self._create_doc_structure()
        
        # Organize existing files
        self._organize_existing_files()
        
        # Create essential files if missing
        self._ensure_essential_files()
        
        # Generate organization report
        self._generate_organization_report()
        
        print()
        print("✨ DOCS ORGANIZATION COMPLETE!")
        print(f"🎯 Actions performed: {len(self.log)}")
        print("📚 docs/ folder is now 20W brain friendly!")

    def _create_doc_structure(self):
        """Create the organized docs structure"""
        subdirs = ['archive', 'guides', 'reports', 'vision']
        
        for subdir in subdirs:
            dir_path = self.docs_dir / subdir
            if not dir_path.exists():
                dir_path.mkdir()
                self.log_action("CREATE", f"docs/{subdir}/")

    def _organize_existing_files(self):
        """Organize existing .md files in docs"""
        if not self.docs_dir.exists():
            return
        
        for md_file in self.docs_dir.glob('*.md'):
            filename = md_file.name
            
            # Skip essential files
            if filename in self.essential_files:
                continue
            
            # Determine destination
            destination = self._determine_destination(filename)
            
            if destination:
                target_path = self.docs_dir / destination / filename
                shutil.move(str(md_file), str(target_path))
                self.log_action("ORGANIZE", f"docs/{filename}", f"docs/{destination}/{filename}")

    def _determine_destination(self, filename: str) -> str:
        """Determine which subdirectory a file belongs in"""
        filename_upper = filename.upper()
        
        # Check archive patterns first (most specific)
        for pattern in self.archive_patterns:
            if pattern in filename_upper:
                return 'archive'
        
        # Check guide patterns
        for pattern in self.guide_patterns:
            if pattern in filename_upper:
                return 'guides'
        
        # Check vision patterns
        for pattern in self.vision_patterns:
            if pattern in filename_upper:
                return 'vision'
        
        # Check report patterns (last, as it's broad)
        for pattern in self.report_patterns:
            if pattern in filename_upper:
                return 'reports'
        
        # Default to archive for unrecognized files
        return 'archive'

    def _ensure_essential_files(self):
        """Create essential files if they don't exist"""
        # Create README.md if missing
        readme_path = self.docs_dir / 'README.md'
        if not readme_path.exists():
            self._create_navigation_readme(readme_path)
        
        # Create QUICK_START.md if missing
        quickstart_path = self.docs_dir / 'QUICK_START.md'
        if not quickstart_path.exists():
            self._create_quickstart_guide(quickstart_path)

    def _create_navigation_readme(self, readme_path: Path):
        """Create the main navigation README"""
        content = f"""# Universal Being Documentation

Welcome to the Universal Being project documentation! This is your **20W brain navigation center**.

## 🎯 Essential Status

- **Latest Validation:** [Pentagon Validation Report](PENTAGON_VALIDATION_REPORT.md)
- **Latest Cleanup:** [Cleanup Report](CLEANUP_REPORT.md)
- **Getting Started:** [Quick Start Guide](QUICK_START.md)

## 📚 Documentation Structure

### Essential (You Are Here)
- **README.md** - This navigation file
- **PENTAGON_VALIDATION_REPORT.md** - Current Pentagon compliance
- **CLEANUP_REPORT.md** - Latest project cleanup results
- **QUICK_START.md** - Get the game running immediately

### Organized Sections
- **[archive/](archive/)** - Old reports, logs, and historical fixes
- **[guides/](guides/)** - How-to documentation and tutorials  
- **[reports/](reports/)** - System diagnostics and analysis
- **[vision/](vision/)** - Project planning and vision documents

## 🎮 The Game

Universal Being is a revolutionary game where **everything is a conscious entity** that can evolve into **anything else**. Powered by 6 AI systems collaborating in real-time.

### Core Concepts
- **Pentagon Architecture** - All beings follow 5 sacred lifecycle methods
- **Consciousness Levels** - 0 (Dormant) to 5 (Transcendent) with visual encoding
- **Evolution System** - Any being can transform into any other being
- **AI Collaboration** - Claude, Cursor, ChatGPT, Gemini, Desktop, Gemma working together

### Tools
- `python clean_project.py` - Organize entire project structure
- `python validate_pentagon.py` - Check Pentagon architecture compliance
- `python clean_docs.py` - Organize this docs folder

Generated by clean_docs.py on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
"""
        
        with open(readme_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        self.log_action("CREATE", "docs/README.md")

    def _create_quickstart_guide(self, quickstart_path: Path):
        """Create a quick start guide"""
        content = """# Quick Start Guide

Get Universal Being running in **3 simple steps**:

## 🚀 Step 1: Clean & Validate
```powershell
python clean_project.py     # Organize the project
python validate_pentagon.py # Check architecture compliance
```

## 🎮 Step 2: Run the Game
```powershell
godot --path . main.tscn    # Launch the game
```

## 🎯 Step 3: Play
- **WASD** - Move your plasmoid
- **Mouse** - Inspect Universal Beings  
- **Tilde (~)** - Open AI console
- **TAB** - Switch cursor modes

## 🔧 If Something's Wrong
1. Check `docs/PENTAGON_VALIDATION_REPORT.md` for compliance issues
2. Check `docs/CLEANUP_REPORT.md` for organization status
3. Run the tools again: `python clean_project.py && python validate_pentagon.py`

## 🌟 Core Game Features
- **Plasmoid Movement** - Hover and float freely
- **Cursor Inspection** - Click any Universal Being to inspect
- **AI Console** - Natural language commands with Gemma AI
- **Evolution System** - Any being can become anything else
- **6 AI Collaboration** - Multiple AI systems working together

That's it! You're now in the Universal Being universe where everything is conscious and can evolve into anything else.
"""
        
        with open(quickstart_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        self.log_action("CREATE", "docs/QUICK_START.md")

    def _generate_organization_report(self):
        """Generate docs organization summary"""
        print("📊 DOCS ORGANIZATION SUMMARY")
        print("=" * 35)
        
        # Count files in each directory
        structure = {}
        for subdir in ['archive', 'guides', 'reports', 'vision']:
            dir_path = self.docs_dir / subdir
            if dir_path.exists():
                structure[subdir] = len(list(dir_path.glob('*.md')))
            else:
                structure[subdir] = 0
        
        # Count essential files
        essential_count = 0
        for essential_file in self.essential_files:
            if (self.docs_dir / essential_file).exists():
                essential_count += 1
        
        print(f"📁 Essential files: {essential_count}/{len(self.essential_files)}")
        print(f"📚 Archive: {structure['archive']} files")
        print(f"📖 Guides: {structure['guides']} files")
        print(f"📊 Reports: {structure['reports']} files")
        print(f"🔮 Vision: {structure['vision']} files")
        print()
        
        if self.log:
            print("📝 Organization actions:")
            for action in self.log[-5:]:  # Show last 5 actions
                print(f"  • {action}")
            if len(self.log) > 5:
                print(f"  ... and {len(self.log) - 5} more actions")

    def log_action(self, action: str, source: str, target: str = ""):
        """Log organization actions"""
        entry = f"{action}: {source}"
        if target:
            entry += f" → {target}"
        self.log.append(entry)
        print(f"📚 {entry}")

def main():
    """Main organization function"""
    project_root = os.path.dirname(os.path.abspath(__file__))
    organizer = DocsOrganizer(project_root)
    organizer.organize_docs()

if __name__ == "__main__":
    main()