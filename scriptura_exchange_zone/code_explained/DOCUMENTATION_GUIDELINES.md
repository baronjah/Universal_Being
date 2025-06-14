# Documentation Guidelines

## File Size and Organization

1. **Maximum File Size:**
   - Documentation files should not exceed 1000 lines
   - Preferred size is 300-500 lines per file
   - Break larger documentation into multiple linked files

2. **File Naming:**
   - Use the same name as the corresponding script file, replacing `.gd` with `.md`
   - For multi-part documentation, use suffixes like `_part1.md`, `_part2.md`, etc.

3. **Directory Structure:**
   - Documentation directory structure mirrors code directory structure
   - Each directory contains an `_INDEX.md` file listing and describing all documentation files

## Content Guidelines

1. **Structure:**
   - Each documentation file should follow the template structure
   - Include file information, properties, methods, signals, examples, and integration points
   - Use Markdown tables for structured information (properties, methods, etc.)

2. **Navigation:**
   - Include a table of contents at the beginning of each file for files longer than 200 lines
   - Provide navigation links to related documentation
   - Add "Back to Index" links at the end of each file

3. **Code Examples:**
   - Include practical code examples showing how to use the script
   - Format code blocks with appropriate syntax highlighting
   - Keep examples concise and focused on demonstrating specific functionality

4. **Cross-References:**
   - Link to related documentation files using relative paths
   - Mention integration points with other components
   - Use consistent terminology across all documentation files

## Documentation Index

Each folder should contain an `_INDEX.md` file that:
1. Lists all documentation files in the folder with brief descriptions
2. Provides navigation to other section indexes
3. Includes a diagram or explanation of how components in this section relate to each other

## Documentation Maintenance

1. **Updates:**
   - Update documentation whenever corresponding code changes
   - Note the last modification date in the file information section
   - Highlight significant changes in a changelog section

2. **Consistency:**
   - Use consistent formatting throughout all documentation
   - Follow the same structure for similar components
   - Maintain consistent terminology across the project

3. **Completeness:**
   - Document all public methods, properties, and signals
   - Include descriptions of parameters and return values
   - Provide context for how each component fits into the larger system

## Template Usage

Use the provided `script_documentation_template.md` as a starting point for all script documentation. Customize sections as needed while maintaining the overall structure.