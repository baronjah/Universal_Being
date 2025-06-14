# Getting Started with JSH Ethereal Engine

Welcome to the JSH Ethereal Engine, a powerful system for creating, evolving, and manipulating entities in a virtual space. This guide will help you get started with the basic functionality of the engine.

## Setup

1. Open the Godot Engine and load the Eden_May project.
2. Open the layer_0.tscn scene from the scenes folder.
3. Add a new node to the scene:
   - Right-click on the `main` node
   - Select "Add Child Node"
   - Search for "JshEtherealIntegration" or add a new script to a Node
   - If adding a new script, load `/code/gdscript/scripts/JshEtherealIntegration.gd`

4. Run the scene by pressing F5 or clicking the Play button.
5. The JSH Ethereal Engine will initialize automatically.
6. Press Tab to toggle the interface.

## User Interface

The JSH Ethereal Engine provides a tabbed interface with four main panels:

### Command Console

The console allows you to enter commands for direct interaction with the engine. Available commands:

```
- create [word] [x] [y] [z] [evolution_stage]: Create an entity from a word
- remove [entity_id]: Remove an entity
- evolve [entity_id]: Evolve an entity to the next stage
- transform [entity_id] [form]: Transform an entity to a new form
- connect [entity1_id] [entity2_id] [connection_type]: Connect two entities
- pattern [word] [type] [count] [radius] [x] [y] [z]: Create a pattern of entities
- list: List all entities
- help: Show help text
```

### Entity Creation

This panel provides a graphical interface for creating and managing entities:

1. Enter a word in the "Word" field.
2. Set the position using the X, Y, Z spinners or click "Use Camera Position".
3. Set the evolution stage using the slider.
4. Click "Create Entity" to create the entity.
5. The entity list shows all active entities.
6. Select an entity and use the buttons to remove or evolve it.

### Pattern Generator

This panel allows you to create patterns of entities:

1. Enter a word in the "Word" field.
2. Select a pattern type (Circle, Grid, Random, Sphere).
3. Set the count and radius.
4. Set the center position or click "Use Camera Position".
5. Click "Generate Pattern" to create the pattern.

### Information

This panel provides details about the JSH Ethereal Engine, including explanations of the systems and commands.

## Key Concepts

### Universal Entity

The core object in the JSH Ethereal Engine. Each entity:
- Is manifested from a word
- Has properties based on the word
- Can transform between different forms
- Can evolve through multiple stages
- Can connect to other entities

### Word Manifestation

The process of converting a word into an entity:
1. The word is analyzed for phonetic, semantic, and pattern properties.
2. These properties determine the entity's appearance and behavior.
3. Different words create different types of entities.

### Entity Forms

Entities can take different visual forms:
- seed, flame, droplet, crystal, wisp, flow, void_spark
- spark, pattern, orb, sprout, light_mote, shadow_essence

### Entity Evolution

Entities can evolve through stages, becoming more complex and powerful:
1. Each evolution stage enhances the entity's properties.
2. Higher evolution stages unlock new abilities and visual effects.
3. At certain complexity thresholds, entities may split into multiple entities.

### Pattern Generation

Create organized groups of entities in various arrangements:
- **circle**: Entities arranged in a circle
- **grid**: Entities arranged in a grid
- **random**: Entities scattered randomly within a radius
- **sphere**: Entities arranged in a 3D spherical pattern

## Example: Creating a Fire Circle

1. Press Tab to open the interface.
2. Go to the Pattern Generator tab.
3. Enter "fire" as the Word.
4. Select "Circle" as the Pattern Type.
5. Set Count to 8 and Radius to 5.
6. Click "Use Camera Position" to center the pattern at your current view.
7. Click "Generate Pattern".

A circle of fire entities will appear around your selected position.

## Example: Evolving an Entity

1. Press Tab to open the interface.
2. Go to the Entity Creation tab.
3. Create a new entity or select an existing one.
4. Click "Evolve Selected" to advance it to the next evolution stage.
5. Observe the visual changes as the entity evolves.

## Example: Transforming an Entity

1. Press Tab to open the interface.
2. Go to the Console tab.
3. Type `list` to see all entities.
4. Find the ID of the entity you want to transform.
5. Type `transform [entity_id] crystal` to change its form to crystal.
6. Observe the visual transformation.

## Navigation

- Use WASD keys to move the camera.
- Hold left mouse button and drag to rotate the camera.
- Press Tab to toggle the interface.
- Use the tabs at the top to switch between panels.

## Next Steps

After mastering the basic functionality, experiment with:
1. Creating complex patterns of different entity types.
2. Connecting entities to see how they interact.
3. Evolving entities to higher stages to unlock new capabilities.
4. Transforming entities between different forms.
5. Creating custom combinations of entities.

Enjoy exploring the possibilities of the JSH Ethereal Engine!