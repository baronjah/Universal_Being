# Script Documentation: JSHDictionaryManager

## Overview
JSHDictionaryManager provides a comprehensive dictionary and word relationship system for the JSH Ethereal Engine. It stores word definitions, categorizes words, tracks relationships between words, and manages element properties. The manager also features a dynamic learning system that can generate definitions for new words based on their observed properties.

## File Information
- **File Path:** `/code/word/JSHDictionaryManager.gd`
- **Lines of Code:** 359
- **Class Name:** JSHDictionaryManager
- **Extends:** Node

## Dependencies
- JSHWordManifestor (optional connection for word learning)

## Core Properties

### Dictionary Storage
| Property | Type | Description |
|----------|------|-------------|
| word_definitions | Dictionary | Maps words to their definitions |
| word_categories | Dictionary | Maps words to categories they belong to |
| word_relationships | Dictionary | Maps words to their relationships with other words |
| element_properties | Dictionary | Maps element names to their properties |

### Learning System
| Property | Type | Description |
|----------|------|-------------|
| learned_words | Dictionary | Words dynamically learned from word manifestation |
| definition_counts | Dictionary | Tracks how many times a word has been seen |
| auto_learn_new_words | bool | Whether to automatically learn new words |
| min_confidence_threshold | float | Minimum confidence for accepting learned definitions |

## Signals
| Signal | Parameters | Description |
|--------|------------|-------------|
| word_defined | word, definition | Emitted when a word definition is added |
| word_learned | word, properties | Emitted when a new word is learned |
| relationship_established | word1, word2, relationship_type | Emitted when a relationship between words is established |

## Core Methods

### Singleton Management
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| get_instance | | JSHDictionaryManager | Returns the singleton instance, creating it if needed |
| _init | | void | Initializes the dictionaries with basic words |
| _ready | | void | Connects to word manifestor if available |

### Dictionary Operations
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| add_word_definition | word, definition | void | Adds a definition for a word |
| get_word_definition | word | String | Gets a word's definition |
| add_word_to_category | word, category | void | Adds a word to a category |
| get_word_categories | word | Array | Gets all categories a word belongs to |
| add_word_relationship | word1, word2, relationship_type | void | Establishes a relationship between words |
| get_related_words | word, relationship_type | Dictionary | Gets words related to the given word |
| get_element_properties | element | Dictionary | Gets properties of an element |
| get_all_words_in_category | category | Array | Gets all words in a category |

### Learning System
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| learn_word | word, properties | void | Learns a new word based on its properties |
| _generate_definition | word, properties | String | Generates a definition based on word properties |

### Signal Handlers
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| _on_word_analyzed | word, analysis | void | Handles word analysis signals |
| _on_word_manifested | word, entity | void | Handles word manifestation signals |
| _on_word_relationship_created | word1, word2, relationship_type | void | Handles relationship creation signals |

## Dictionary System

### Word Definitions
The manager maintains a dictionary of word definitions, initialized with basic elements and concepts:

```gdscript
# Element definitions
add_word_definition("fire", "A primordial element associated with heat, light, energy, passion, and transformation.")
add_word_definition("water", "A primordial element associated with fluidity, adaptability, emotions, healing, and purification.")
# ...

# Concept definitions
add_word_definition("creation", "The act or process of bringing something into existence, forming something from nothing.")
add_word_definition("destruction", "The act of destroying or state of being destroyed, breaking down into components.")
# ...
```

### Word Categories
Words are organized into categories for easy retrieval:

```gdscript
# Elements
add_word_to_category("fire", "element")
add_word_to_category("water", "element")
# ...

# Concepts
add_word_to_category("creation", "concept")
add_word_to_category("destruction", "concept")
# ...
```

### Word Relationships
The manager tracks relationships between words:

```gdscript
# Element relationships
add_word_relationship("fire", "water", "opposes")
add_word_relationship("fire", "earth", "strengthens")
add_word_relationship("water", "fire", "weakens")
# ...
```

### Element Properties
Detailed properties are defined for elemental words:

```gdscript
element_properties = {
    "fire": {
        "primary_properties": ["heat", "light", "energy"],
        "secondary_properties": ["passion", "transformation", "purification"],
        "opposing_elements": ["water", "ice"],
        "complementary_elements": ["air", "lightning"],
        "visual_traits": ["red", "orange", "yellow", "flicker", "glow"]
    },
    # ...
}
```

## Dynamic Learning System

The dictionary manager can learn new words and generate definitions based on observed properties:

### Learning Process
1. When a word is analyzed or manifested, its properties are recorded
2. After seeing a word multiple times, it is "learned"
3. A definition is generated based on observed properties
4. Confidence increases with each subsequent observation
5. Learned words are integrated into the dictionary system

### Definition Generation
The manager generates definitions by combining property information:

```
"A [element]-aligned [entity type] with [property descriptions]. 
Manifested from the word '[word]'."
```

For example, a learned word "crystal" might generate:
```
"An earth-aligned entity with substantial mass, association with stability. 
Manifested from the word 'crystal'."
```

## Usage Examples

### Basic Dictionary Operations
```gdscript
# Get the dictionary manager
var dict_manager = JSHDictionaryManager.get_instance()

# Get a word definition
var definition = dict_manager.get_word_definition("fire")
print(definition)  # "A primordial element associated with heat, light, energy..."

# Check word categories
var categories = dict_manager.get_word_categories("water")
print(categories)  # ["element"]

# Get related words
var related = dict_manager.get_related_words("fire")
print(related)  # {"water": "opposes", "earth": "strengthens"}

# Get element properties
var properties = dict_manager.get_element_properties("air")
print(properties.primary_properties)  # ["movement", "lightness", "invisibility"]
```

### Finding Words by Category
```gdscript
# Get all elements
var elements = dict_manager.get_all_words_in_category("element")
print(elements)  # ["fire", "water", "earth", "air", "lightning", "ice", "metal", "wood"]

# Get all concepts
var concepts = dict_manager.get_all_words_in_category("concept")
print(concepts)  # ["creation", "destruction", "transformation", "protection"]
```

### Adding New Definitions
```gdscript
# Add a new word definition
dict_manager.add_word_definition("crystal", "A solid mineral substance with a regularly ordered internal structure.")
dict_manager.add_word_to_category("crystal", "material")

# Define relationships
dict_manager.add_word_relationship("crystal", "earth", "derived_from")
dict_manager.add_word_relationship("crystal", "light", "refracts")
```

### Dynamic Learning
```gdscript
# Learn a new word
var word_properties = {
    "element_affinity": "earth",
    "entity_type": "material",
    "energy": 40,
    "mass": 85,
    "concept_triggers": ["stability", "permanence"]
}
dict_manager.learn_word("quartz", word_properties)

# Get the generated definition
print(dict_manager.get_word_definition("quartz"))
```

## Element System

The dictionary manager defines properties for various elements:

### Core Elements
- **Fire**: Heat, light, energy; passionate and transformative
- **Water**: Fluidity, adaptability, cleansing; emotional and healing
- **Earth**: Stability, solidity, fertility; patient and enduring
- **Air**: Movement, lightness, invisibility; intellectual and free

### Derived Elements
- **Lightning**: Electricity, speed, power; revealing and inspiring
- **Ice**: Cold, solidity, preservation; clear and reflective

### Element Relationships
- **Opposing**: Elements that counteract each other (fire/water)
- **Complementary**: Elements that enhance each other (fire/air)
- **Derived**: Elements that come from others (ice from water)

## Integration Points

The JSHDictionaryManager integrates with several other components:

- **JSHWordManifestor**: Receives signals about analyzed and manifested words
- **JSHPhoneticAnalyzer**: Uses element affinities for definition generation
- **JSHSemanticAnalyzer**: Uses concept triggers for definition generation
- **CoreUniversalEntity**: Provides entity properties for word learning

## Notes and Considerations

1. **Word Casing**: All dictionary operations are case-insensitive
2. **Dynamic Learning**: The quality of learned definitions improves over time
3. **Confidence Thresholds**: Learned words start with 0.5 confidence and increase with observations
4. **Performance**: Dictionary lookups are fast, but definition generation can be more intensive
5. **Extensibility**: Can be extended with custom categories and relationship types

## Related Documentation

- [JSHWordManifestor](JSHWordManifestor.md) - Word manifestation system
- [JSHPhoneticAnalyzer](JSHPhoneticAnalyzer.md) - Phonetic analysis component
- [JSHSemanticAnalyzer](JSHSemanticAnalyzer.md) - Semantic analysis component
- [JSHPatternAnalyzer](JSHPatternAnalyzer.md) - Pattern analysis component