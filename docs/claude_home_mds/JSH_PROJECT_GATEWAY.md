# JSH Ethereal Engine - WSL Environment Gateway

## Project Location

The JSH Ethereal Engine project has been centralized in the Windows Godot project folder. This WSL environment serves as a support and resource area for the main project.

## Project Directories

### Main Project Location (Windows)
- **Godot Project**: `/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/`
- This is the primary location where all project files, documentation, and code should be organized.

### WSL Environment (This Environment)
- **WSL Root**: `/home/kamisama/`
- Contains additional resources and integration tools
- Houses navigation scripts and secondary documentation

## Key Files in WSL Environment

1. **Project Navigation**:
   - `/home/kamisama/goto_jsh_project.sh`: Script for navigating between project components
   - `/home/kamisama/JSH_PROJECT_INDEX.md`: Master project index

2. **Zero Point Entity Implementation**:
   - `/home/kamisama/zero_point_entity/`: Original Zero Point Entity implementation files
   - These are being integrated into the main Godot project

3. **Documentation Resources**:
   - `/home/kamisama/space_game_docs/`: Additional documentation resources

## Integration with Godot Project

The WSL environment is integrated with the Godot project through:

1. **Shared Filesystem**: The Windows filesystem is mounted at `/mnt/c/`
2. **Navigation Tools**: Scripts to help move between environments
3. **Documentation Mapping**: Cross-references between WSL and Windows paths

## Getting Started

To work on the JSH Ethereal Engine from the WSL environment:

1. Use the navigation script to access project components:
   ```bash
   bash /home/kamisama/goto_jsh_project.sh
   ```

2. Navigate to the main Godot project:
   ```bash
   cd "/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/"
   ```

3. Review the project index for an overview of all components:
   ```bash
   cat "/home/kamisama/JSH_PROJECT_INDEX.md"
   ```

## Important Notes

1. **Primary Development**: All primary development work should be done in the Godot project directory.

2. **Resource Integration**: WSL resources are being integrated into the main project.

3. **Documentation Consistency**: New documentation should be added to the Godot project structure.

4. **Cross-Environment References**: Remember to convert paths when moving between environments:
   - Windows to WSL: `C:\Users\Percision 15\...` → `/mnt/c/Users/Percision 15/...`
   - WSL to Windows: `/mnt/c/Users/Percision 15/...` → `C:\Users\Percision 15\...`

This gateway file was last updated: May 10, 2025