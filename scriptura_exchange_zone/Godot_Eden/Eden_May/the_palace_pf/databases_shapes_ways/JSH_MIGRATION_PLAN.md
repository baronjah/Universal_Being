# JSH Ethereal Engine - Documentation Migration Plan

This document outlines the plan for migrating documentation from the user directory to the Godot project structure.

## Overview

The JSH Ethereal Engine documentation is currently spread across multiple locations. This plan centralizes all documentation in the Godot project folder for better organization and accessibility.

## Migration Steps

### 1. Initial Assessment (Completed)

- Identified documentation files in `/mnt/c/Users/Percision 15/`
- Identified documentation files in `/home/kamisama/`
- Examined the Godot project structure in `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/`

### 2. Create Gateway Files (Completed)

- Created `/mnt/c/Users/Percision 15/JSH_PROJECT_GATEWAY.md` as a central navigation point
- Created `/home/kamisama/JSH_PROJECT_GATEWAY.md` for WSL environment navigation

### 3. Documentation Migration (In Progress)

#### Files to Migrate from User Directory:

| Source File | Destination | Status |
|-------------|-------------|--------|
| `/mnt/c/Users/Percision 15/JSH_ENTITY_README.md` | `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/entity/` | Pending |
| `/mnt/c/Users/Percision 15/JSH_DATABASE_README.md` | `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/database/` | Pending |
| `/mnt/c/Users/Percision 15/JSH_SPATIAL_README.md` | `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/spatial/` | Pending |
| `/mnt/c/Users/Percision 15/JSH_UI_README.md` | `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/ui/` | Pending |
| `/mnt/c/Users/Percision 15/JSH_ADVANCED_FEATURES_README.md` | `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/core/` | Pending |
| `/mnt/c/Users/Percision 15/console_integration_plan.md` | `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/console/` | Pending |
| `/mnt/c/Users/Percision 15/PHASE4_CONSOLE_SUMMARY.md` | `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/phase_planning/` | Pending |
| `/mnt/c/Users/Percision 15/menu_keyboard_console_integration.md` | `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/ui/` | Pending |
| `/mnt/c/Users/Percision 15/IMPLEMENTATION_SUMMARY.md` | `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/summaries/` | Pending |
| `/mnt/c/Users/Percision 15/JSH_INTEGRATION_PLAN.md` | `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/summaries/integration/` | Pending |
| `/mnt/c/Users/Percision 15/JSH_GETTING_STARTED.md` | `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/summaries/integration/` | Pending |
| `/mnt/c/Users/Percision 15/JSH_IMPLEMENTATION_REPORT.md` | `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/summaries/integration/` | Pending |
| `/mnt/c/Users/Percision 15/JSH_WORD_MANIFESTATION_README.md` | `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/word/` | Pending |
| `/mnt/c/Users/Percision 15/code_explained/` (all files) | `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/` | Pending |

#### Detailed Entity Documentation:

| Source File | Destination | Status |
|-------------|-------------|--------|
| `/mnt/c/Users/Percision 15/code_explained/entity/JSHEntityManager.md` | `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/entity/` | Pending |
| `/mnt/c/Users/Percision 15/code_explained/entity/JSHEntityEvolution.md` | `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/entity/` | Pending |
| `/mnt/c/Users/Percision 15/code_explained/entity/JSHEntityVisualizer.md` | `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/entity/` | Pending |
| `/mnt/c/Users/Percision 15/code_explained/entity/JSHEntityCommands.md` | `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/entity/` | Pending |

#### Detailed Word Documentation:

| Source File | Destination | Status |
|-------------|-------------|--------|
| `/mnt/c/Users/Percision 15/code_explained/word/JSHDictionaryManager.md` | `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/word/` | Pending |
| `/mnt/c/Users/Percision 15/code_explained/word/JSHPhoneticAnalyzer.md` | `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/word/` | Pending |
| `/mnt/c/Users/Percision 15/code_explained/word/JSHSemanticAnalyzer.md` | `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/word/` | Pending |

### 4. Code Implementation Migration (Planned)

- Move implementation files (.gd) to their appropriate locations in the Godot project
- Ensure all paths and references are updated accordingly
- Test functionality after migration

### 5. Update References and Indexes (Planned)

- Update all cross-references in documentation to reflect new paths
- Create or update index files in each subdirectory
- Ensure the main project index references the correct locations

### 6. Cleanup (Planned)

- Once migration is confirmed successful, add deprecation notices to original locations
- Create symbolic links for backward compatibility if needed
- Document the new structure in the project README

## Migration Execution

To execute this migration plan:

1. Create the necessary directory structure in the Godot project
2. Use the `cp` command to copy files:
   ```bash
   mkdir -p "/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/entity/"
   cp "/mnt/c/Users/Percision 15/code_explained/entity/JSHEntityManager.md" "/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/code_explained/entity/"
   ```

3. Verify file integrity after copying
4. Update references within files to point to the new locations
5. Create index files for each subdirectory

## Post-Migration Verification

After migration, verify:

1. All files are accessible in their new locations
2. All internal references are correctly updated
3. Documentation hierarchy is consistent
4. Godot project structure is maintained
5. Navigation between components works as expected

## Timeline

- Documentation Migration: May 10-15, 2025
- Code Implementation Migration: May 15-20, 2025
- Reference Updates and Testing: May 20-25, 2025
- Final Cleanup: May 25-30, 2025

This migration plan was last updated: May 10, 2025