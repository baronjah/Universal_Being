# Thing Creator Integration Plan

This document outlines the plan for consolidating and organizing the various Thing Creator scripts in the Eden project.

## Current Issues

1. **Duplicate Scripts**: There are multiple scripts with similar functionality but in different locations
   - `/code/gdscript/scripts/akashic_records/thing_creator.gd`
   - `/code/gdscript/scripts/akashic_records/thing_creator_standalone.gd`
   - `/code/gdscript/scripts/kamisama_home/thing_creator_standalone.gd`

2. **Inconsistent Class Naming**: Some classes use the 'A' suffix, some don't
   - `ThingCreatorA`
   - `AkashicRecordsManagerA`

3. **Scattered UI Components**: UI components are mixed with core functionality
   - `thing_creator_ui.gd` is in the same folder as the core `thing_creator.gd`

## Integration Plan

### Phase 1: Standardize Class Names (COMPLETED)

1. ✅ Remove the 'A' suffix from all classes
   - `ThingCreatorA` -> `ThingCreator`
   - `AkashicRecordsManagerA` -> `AkashicRecordsManager`
   - `ThingCreatorStandaloneA` -> `ThingCreatorStandalone`

2. ✅ Use a consistent naming scheme
   - Base classes: Noun format (e.g., `ThingCreator`)
   - UI classes: NounUI format (e.g., `ThingCreatorUI`)
   - Integration classes: NounIntegration format (e.g., `ThingCreatorIntegration`)

### Phase 2: Directory Structure Consolidation (COMPLETED)

1. Core System Files:
   - ✅ `/code/gdscript/scripts/core/thing_creator.gd`
   - ✅ `/code/gdscript/scripts/core/akashic_records_manager.gd`
   - ✅ `/code/gdscript/scripts/core/universal_bridge.gd`

2. UI Files:
   - ✅ `/code/gdscript/scripts/ui/thing_creator_ui.gd`
   - ✅ `/code/gdscript/scripts/ui/akashic_records_ui.gd`
   - ✅ `/code/gdscript/scripts/ui/thing_creator_standalone.gd`

3. Integration Files:
   - ✅ `/code/gdscript/scripts/integration/thing_creator_integration.gd`
   - ✅ `/code/gdscript/scripts/integration/console_integration_helper.gd`
   - ✅ `/code/gdscript/scripts/integration/path_updater.gd`
   - ✅ `/code/gdscript/scripts/integration/integration_test.gd`

4. Scene Files:
   - ✅ `/code/gdscript/scenes/thing_creator_ui.tscn`
   - ✅ `/code/gdscript/scenes/akashic_records_ui.tscn`
   - ✅ `/code/gdscript/scenes/thing_creator_standalone.tscn`

### Phase 3: Unified API Development (COMPLETED)

1. ✅ Create consistent API interfaces for all systems
2. ✅ Standardize method signatures and parameter names
3. ✅ Create consistent signal naming and parameters

### Phase 3.5: Class Name Conflict Resolution (COMPLETED)

1. ✅ Add "Core" prefix to classes that conflict with autoload singletons
   - `ThingCreator` → `CoreThingCreator`
   - `AkashicRecordsManager` → `CoreAkashicRecordsManager`
   - `UniversalBridge` → `CoreUniversalBridge`
   - `ThingCreatorUI` → `CoreThingCreatorUI`
   - `ThingCreatorStandalone` → `CoreThingCreatorStandalone`
   - `EntityManager` → `CoreEntityManager`

2. ✅ Update file names to match new class names
   - `thing_creator.gd` → `core_thing_creator.gd`
   - `akashic_records_manager.gd` → `core_akashic_records_manager.gd`

3. ✅ Update references in code to use new class names
   - Allow fallback compatibility with both naming schemes during transition

### Phase 4: Documentation (IN PROGRESS)

1. ✅ API reference for core classes
2. ✅ Usage examples for UI components
3. ⬜ Diagrams showing system connections

### Phase 5: Testing and Refinement (IN PROGRESS)

1. ✅ Created integration tests
2. ⬜ Run tests and fix any issues
3. ⬜ Performance optimization

## Implementation Steps

1. ✅ Create core directory structure
2. ✅ Move and rename files
3. ✅ Update class references
4. ✅ Create integration test scripts
5. ✅ Update documentation

## Next Steps

1. ✅ Run the path_updater.gd script to update import paths throughout the codebase
2. ✅ Created CLAUDE.md with naming conventions and project information
3. ✅ Update class references to use "Core" prefix for consistency
4. Run integration tests to verify functionality
5. Address any issues found during testing
6. Complete remaining documentation
7. Optimize performance where needed