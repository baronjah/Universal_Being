# Script Documentation: CoreWordManifestor

## Overview
CoreWordManifestor is a central component of the JSH Ethereal Engine that handles the conversion of words into entities with properties. It analyzes words through phonetic, semantic, and pattern analyzers to determine their characteristics, then manifests them as entities in the world. This component enables the core "words shape reality" functionality of the system.

## File Information
- **File Path:** `/code/core/CoreWordManifestor.gd`
- **Lines of Code:** 1017
- **Class Name:** CoreWordManifestor
- **Extends:** Node

## Dependencies
- JSHPhoneticAnalyzer (or fallback PhoneticAnalyzer)
- JSHSemanticAnalyzer (or fallback SemanticAnalyzer)
- JSHPatternAnalyzer (or fallback PatternAnalyzer)
- JSHEntityManager/CoreEntityManager (or fallback ThingCreatorA)
- JSHDictionaryManager (optional)

## Constants and Configuration

### Constants
| Constant | Value | Description |
|----------|-------|-------------|
| MAX_WORD_HISTORY | 100 | Maximum number of words to keep in history |
| WORD_DB_FILE | "user://word_database.json" | Path to word database file |
| CONCEPT_MAP_FILE | "user://concept_map.json" | Path to concept relationship map file |

### Configuration Properties
| Property | Type | Description |
|----------|------|-------------|
| default_manifestation_influence | float | Base influence level for manifesting words (default: 1.0) |
| phonetic_weight | float | Weight given to phonetic analysis (default: 0.3) |
| semantic_weight | float | Weight given to semantic analysis (default: 0.5) |
| pattern_weight | float | Weight given to pattern analysis (default: 0.2) |

## Core Properties

### Dictionaries and Maps
| Property | Type | Description |
|----------|------|-------------|
| word_properties | Dictionary | Known properties of analyzed words |
| concept_relationships | Dictionary | How concepts connect to each other |
| word_history | Array | Recently used words |
| word_relationships | Dictionary | How words relate to each other |
| recent_manifestations | Array | Recently manifested words |

### Analysis Components
| Property | Type | Description |
|----------|------|-------------|
| phonetic_analyzer | Object | Component that analyzes phonetic properties of words |
| semantic_analyzer | Object | Component that analyzes semantic meaning of words |
| pattern_analyzer | Object | Component that analyzes patterns within words |

### External Systems
| Property | Type | Description |
|----------|------|-------------|
| entity_manager | Object | Manager for creating and tracking entities |
| dictionary_manager | Object | Manager for word definitions and relationships |
| map_system | Object | System for spatial organization of entities |
| player_node | Node3D | Reference to player node for positioning entities |

## Signals
| Signal | Parameters | Description |
|--------|------------|-------------|
| word_manifested | word, entity | Emitted when a word is converted into an entity |
| concept_discovered | concept, properties | Emitted when a new concept is discovered |
| word_combination_created | words, result | Emitted when words are combined |
| word_analyzed | word, analysis | Emitted when word analysis is completed |
| word_relationship_created | word1, word2, relationship_type | Emitted when a relationship between words is created |

## Core Methods

### Initialization
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| _init | | void | Initializes analyzers, configuration, and loads databases |
| _ready | | void | Sets up connections to other systems |
| initialize | p_map_system, p_player | void | Connects to map system and player |
| _initialize_analyzers | | void | Sets up word analysis components |
| _setup_default_configuration | | void | Sets default weights and parameters |

### Core Manifestation
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| manifest_word | word, position, extra_properties | Object | Creates an entity from a word at position |
| manifest_word_sequence | sequence, start_position, spacing | Array | Creates entities from a sequence of words |
| manifest_words | words, relationship_type, options | Array | Creates entities with relationships between them |
| combine_words | words, position | Object | Combines multiple words into a complex entity |

### Word Analysis
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| analyze_word | word | Dictionary | Analyzes a word's properties |
| _calculate_power_level | word, phonetic_result, semantic_result, pattern_result | float | Calculates word's power level from analysis results |
| _determine_element_affinity | word, phonetic_result | String | Determines elemental affinity of a word |
| _extract_concept_triggers | word, semantic_result | Array | Extracts concept triggers from a word |
| _determine_entity_type | properties | String | Determines entity type from properties |
| _generate_entity_properties | analysis | Dictionary | Generates entity properties from analysis |

### Word History Management
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| _add_to_word_history | word | void | Adds a word to history trackers |
| get_recent_manifestations | count | Array | Gets recently manifested words |

### Word Relationship Management
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| _create_word_relationship | word1, word2, relationship_type | void | Creates a relationship between words |
| get_related_words | word | Dictionary | Gets words related to given word |
| _add_word_combination | words, result | void | Records a word combination |

### Learning System
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| _learn_word_properties | word, properties | void | Stores word properties for future use |

### Saving and Loading
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| save_word_database | | void | Saves word properties to file |
| load_word_database | | void | Loads word properties from file |
| save_concept_map | | void | Saves concept relationships to file |
| load_concept_map | | void | Loads concept relationships from file |
| _initialize_starter_words | | void | Initializes database with basic words |

### Utility Functions
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| get_opposite_concept | concept | String | Gets opposite of a concept if known |

### Console Command Processing
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| process_command | command | Dictionary | Processes text commands for entity creation |
| _find_entity_by_word | word | Object | Finds entity with given source word |

## Inner Classes

### PhoneticAnalyzer
A fallback analyzer used when JSHPhoneticAnalyzer is not available. Analyzes words based on vowel/consonant patterns.

### SemanticAnalyzer
A fallback analyzer used when JSHSemanticAnalyzer is not available. Identifies concept relationships based on root words.

### PatternAnalyzer
A fallback analyzer used when JSHPatternAnalyzer is not available. Identifies patterns like repetition and symmetry in words.

## Usage Examples

### Manifesting a Word
```gdscript
# Get the word manifestor
var word_manifestor = CoreWordManifestor.get_instance()

# Manifest a word at the player's position
var player = get_node("Player")
var entity = word_manifestor.manifest_word("fire", player.global_position)

# Check the result
if entity:
    print("Created a fire entity with ID: " + entity.get_id())
```

### Combining Words
```gdscript
# Combine multiple words to create a new entity
var words = ["fire", "water"]
var combined_entity = word_manifestor.combine_words(words)

if combined_entity:
    print("Combined " + str(words) + " into: " + combined_entity.source_word)
```

### Processing Console Commands
```gdscript
# Process a command from the creation console
var command = "create fireball"
var result = word_manifestor.process_command(command)

if result.success:
    print(result.message)
    # Do something with result.entity
else:
    print("Command failed: " + result.message)
```

### Analyzing a Word
```gdscript
# Analyze properties of a word
var properties = word_manifestor.analyze_word("crystal")
print("Element affinity: " + properties.element_affinity)
print("Energy level: " + str(properties.energy))
```

## Integration Points
CoreWordManifestor integrates with several other components:

- **Entity Management System**: Creates entities through the EntityManager
- **Dictionary System**: Uses word definitions and relationships from the DictionaryManager
- **Map System**: Places entities in the world through the map system
- **Console System**: Processes commands from the CreationConsole
- **Analysis System**: Uses specialized analyzers for word properties

## Fallback Mechanisms
The script implements fallback mechanisms when specialized components are not available:

1. If JSHPhoneticAnalyzer is not available, uses internal PhoneticAnalyzer
2. If JSHSemanticAnalyzer is not available, uses internal SemanticAnalyzer
3. If JSHPatternAnalyzer is not available, uses internal PatternAnalyzer
4. If JSHEntityManager is not available, tries CoreEntityManager, then ThingCreatorA
5. If JSHDictionaryManager is not available, dictionary features are limited

## Notes and Considerations
- The word analysis system combines phonetic, semantic, and pattern analysis
- The word database is persistent between sessions
- The concept map stores relationships between concepts
- Word combinations create more complex entities
- Element affinity strongly influences the resulting entity properties
- Words that have been analyzed before use cached properties for consistency

## Related Documentation
- [CoreUniversalEntity](CoreUniversalEntity.md)
- [JSHPhoneticAnalyzer](../word/JSHPhoneticAnalyzer.md)
- [JSHSemanticAnalyzer](../word/JSHSemanticAnalyzer.md)
- [JSHPatternAnalyzer](../word/JSHPatternAnalyzer.md)
- [JSHDictionaryManager](../word/JSHDictionaryManager.md)