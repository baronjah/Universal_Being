# Scribbles, Blueprints & Testing Directory

## Purpose

This directory contains experimental code, design blueprints, and testing implementations for the JSH Ethereal Engine. It serves as a sandbox for exploring ideas, prototyping features, and conducting experiments before integrating them into the main codebase.

## Directory Structure

The directory is organized by system to match the main codebase structure:

```
scribbles_blueprints_testing/
├── entity/         # Entity system experiments and prototypes
├── word/           # Word system experiments and prototypes
├── spatial/        # Spatial system experiments and prototypes
├── akashic/        # Akashic records system experiments
├── console/        # Console system experiments
└── integration/    # Cross-system integration experiments
```

## Usage Guidelines

### When to Use This Directory

- **Experimental Features**: When developing a new feature that's not ready for the main codebase
- **Prototyping**: For quick proof-of-concept implementations
- **Alternative Approaches**: To explore different implementation strategies
- **Testing Ideas**: For trying out ideas without affecting the main systems
- **Learning Experiments**: For code written while learning about a system

### Workflow

1. **Create Script**: Create your experimental script in the appropriate subdirectory
2. **Prototype**: Develop and test your idea
3. **Evaluation**: Evaluate the success of the experiment
4. **Integration or Archiving**:
   - If successful, refine the code and move it to the main codebase
   - If not successful but has future potential, document findings and keep for reference
   - If not useful, either delete or clearly mark as deprecated

### Naming Conventions

- Use descriptive names that indicate the purpose of the experiment
- Include a prefix to indicate the stage:
  - `proto_`: For early prototypes
  - `exp_`: For experiments
  - `alt_`: For alternative implementations to existing systems
  - `test_`: For test-focused implementations
  - `blueprint_`: For design blueprints
  - `scratch_`: For quick scratch implementations

Example: `proto_entity_lifecycle.gd`, `exp_word_evolution.gd`, `blueprint_spatial_zones.gd`

## Documentation

Each experimental script should include:

1. **Purpose Header**: A comment at the top explaining the purpose of the experiment
2. **Status**: Current status (In Progress, Completed, Abandoned)
3. **Date**: When the experiment was started
4. **Dependencies**: Any dependencies on other systems
5. **Findings**: Key findings or outcomes of the experiment
6. **Next Steps**: What should be done with this code

Example header:
```gdscript
# -----------------------------------------------
# Purpose: Experiment with new entity lifecycle management
# Status: Completed
# Date: 2025-05-10
# Dependencies: JSHEntityManager, JSHEventSystem
# Findings:
#   - Event-based lifecycle is more efficient
#   - Reduced memory usage by 30%
#   - Complexity increased for simple entities
# Next Steps:
#   - Refine the event system integration
#   - Create unit tests
#   - Integrate with main entity manager
# -----------------------------------------------
```

## Moving to Production

When an experiment is ready for production:

1. **Refactor**: Clean up experimental code and ensure it meets codebase standards
2. **Documentation**: Create proper documentation in the code_explained directory
3. **Testing**: Create comprehensive tests
4. **Integration**: Move the code to the appropriate location in the main codebase
5. **Reference**: Leave a note in the experimental file about where the production version exists

## Archive Policy

This directory should be periodically reviewed to:
- Archive successful experiments that have been integrated
- Document and archive failed experiments with useful lessons
- Remove redundant or outdated experiments

---

Remember: This is a space for creativity and exploration. Don't worry about perfection here; focus on innovation and learning.