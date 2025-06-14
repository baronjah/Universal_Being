# Project Regenesis - Eden Claude Helper

## Development Guidelines

1. Class naming conventions:
   - All newly added classes that might conflict with autoload singletons should have the "Core" prefix
   - Original class names: ThingCreator, ThingCreatorUI, UniversalBridge, AkashicRecordsManager
   - New class names: CoreThingCreator, CoreThingCreatorUI, CoreUniversalBridge, CoreAkashicRecordsManager
   
2. Entity system:
   - The UniversalEntity class is the foundation class for all entities
   - The CoreEntityManager handles creation and management of entities
   - Pattern generation is supported (circle, grid, random, sphere)
   
3. File structure:
   - Core classes: `/code/gdscript/scripts/core/`
   - Entity scripts: `/code/gdscript/scripts/akashic_records/`
   - UI components: `/code/gdscript/scripts/ui/`
   - Test scripts: `/code/gdscript/scripts/tests/`
   
4. Type safety:
   - When using modulo operations, always convert values to integers explicitly:
     ```gdscript
     var grid_size = int(ceil(sqrt(count)))
     var x = (i % int(grid_size))
     ```

5. Null reference handling:
   - All critical components should have robust error handling
   - Use dummy implementations for critical components that can't be loaded

## Commands to Run

- Test script: Load the universal_entity_test.tscn scene
- Type checking: N/A for GDScript (dynamically typed)
- Linting: N/A without specialized tools

## Project Status

The UniversalEntity system has been implemented with the following functionality:
- Entity creation and management
- Transformation between different types
- Interaction between entities
- Pattern generation (circle, grid, random, sphere)
- Serialization to and from dictionaries

Current work:
- Resolved naming conflicts between classes and autoload singletons
- Fixed type errors with modulo operations
- Added robust error handling for null references

## Current Limitations

- The UniversalEntity system relies on the Akashic Records system for word definitions
- Some functionality depends on the Zone Manager for spatial organization
- Visual representations are currently basic 3D primitives