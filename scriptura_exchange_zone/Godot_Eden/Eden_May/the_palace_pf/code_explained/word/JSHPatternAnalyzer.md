# JSHPatternAnalyzer

The `JSHPatternAnalyzer` system identifies and evaluates structural patterns within words, analyzing repetition, symmetry, and visual properties. This pattern-based analysis contributes to the word manifestation process in the JSH Ethereal Engine by determining pattern power and visual harmony.

## Overview

While the Phonetic Analyzer examines how words sound, the Pattern Analyzer examines how words are structured. The system detects various types of patterns including palindromes, alliteration, rhymes, and consonance, which influence the manifestation power and visual representation of words in the JSH Ethereal Engine.

## Core Concepts

### Pattern Types

The system recognizes several fundamental pattern types:
- **Palindrome**: Words that read the same backward as forward (e.g., "level")
- **Alliteration**: Repeated consonant sounds (e.g., "wild winds")
- **Rhyme**: Similar ending sounds (e.g., "bright night")
- **Assonance**: Repeated vowel sounds (e.g., "fleet feet")
- **Consonance**: Consonant repetition with different vowels (e.g., "pitter patter")
- **Reduplication**: Repeating syllables (e.g., "murmur")
- **Anagram**: Rearrangements of same letters
- **Chiasmus**: Crosswise arrangement (e.g., ABBA pattern)

### Pattern Significance

Different patterns contribute varying levels of significance to a word's power:
- **Repetition**: Repeated elements enhance pattern recognition (weight: 0.3)
- **Symmetry**: Balanced or mirrored structures (weight: 0.25)
- **Progression**: Sequential patterns (weight: 0.2)
- **Alternation**: Alternating elements (weight: 0.15)
- **Clustering**: Groups of similar characters (weight: 0.1)

### Pattern Power

Each pattern type has an inherent baseline power:
- Palindrome: 0.9 - Highest pattern power
- Reduplication: 0.8 - High pattern power
- Alliteration/Chiasmus: 0.7 - Strong pattern power
- Rhyme/Anagram: 0.6 - Moderate pattern power
- Assonance/Consonance: 0.5 - Average pattern power

### Visual Balance

Words have a visual aesthetic based on:
- Character weight distribution
- Visual symmetry
- Character placement balance
- Proportional structure

## Key Features

### Comprehensive Pattern Analysis

The analyzer examines words for their structural patterns, generating a detailed profile including:
- Repetition count and unique character ratio
- Symmetry score (0.0-1.0)
- Identified patterns with strength ratings
- Pattern-based power (0.0-1.0)
- Character distribution statistics
- Sequence patterns (increasing, decreasing, alternating)
- Visual balance/harmony (0.0-1.0)

### Pattern Identification

The system identifies multiple pattern types simultaneously:
- Analysis of character repetition and distribution
- Syllable-based pattern detection
- Alphabetical progression analysis
- Alternating pattern recognition
- Symmetry and palindrome evaluation

### Visual Balance Evaluation

Words are evaluated for their visual aesthetic properties:
- **Character Weight**: Some characters have more visual "weight" (m, w, g vs. i, l, t)
- **Left-Right Balance**: Distribution of visual weight across the word
- **Symmetry**: Contribution to visual harmony
- **Length Effects**: Impact of word length on visual balance

## Implementation Details

### Character Statistics

The system calculates detailed character metrics:
- Total character count
- Unique character count
- Most frequent character identification
- Repetition count
- Unique character ratio

### Symmetry Calculation

Symmetry is determined through:
- Perfect palindrome detection (complete symmetry)
- Partial symmetry calculation based on character matching
- Boosted scoring for near-palindromes
- Length-based symmetry weighting

### Pattern Detection Algorithm

Patterns are identified through multiple specialized detectors:
1. Palindrome check via symmetry analysis
2. Alliteration detection through initial consonant analysis
3. Assonance detection via vowel sequence analysis
4. Consonance evaluation through consonant repetition
5. Reduplication identification through syllable comparison
6. Rhyme detection through ending syllable analysis
7. Chiasmus pattern recognition for specific sequences

### Pattern Power Calculation

Pattern power is calculated through:
1. Starting with a base power level (0.3)
2. Adding weighted contributions from identified patterns
3. Incorporating symmetry factor with appropriate weighting
4. Adjusting based on unique character ratio
5. Clamping final result to a 0.1-1.0 range

### Visual Balance Algorithm

Visual balance is determined by:
1. Starting with a moderate balance score (0.5)
2. Applying perfect symmetry bonus when applicable
3. Calculating visual weight for left and right sides of the word
4. Analyzing character weight based on character shapes
5. Calculating balance ratio from weight distribution
6. Applying length-based adjustment factors

## Practical Use

### Basic Pattern Analysis

```gdscript
# Get the analyzer instance
var analyzer = JSHPatternAnalyzer.get_instance()

# Analyze a word
var result = analyzer.analyze("level")

# Access pattern properties
print("Symmetry: " + str(result.symmetry))
print("Unique character ratio: " + str(result.unique_chars_ratio))
print("Pattern power: " + str(result.power))
print("Visual balance: " + str(result.visual_balance))
```

### Identifying Specific Patterns

```gdscript
# Analyze a word for patterns
var analyzer = JSHPatternAnalyzer.get_instance()
var analysis = analyzer.analyze("murmur")

# Check for specific patterns
for pattern in analysis.patterns:
    print("Pattern: " + pattern.type + ", Strength: " + str(pattern.strength))

# Check for specific sequence patterns
for seq_pattern in analysis.sequence_patterns:
    print("Sequence: " + seq_pattern.type + ", Strength: " + str(seq_pattern.strength))
```

### Using Pattern Analysis for Entity Creation

```gdscript
# Analyze a word for pattern properties
var pattern_analyzer = JSHPatternAnalyzer.get_instance()
var pattern_analysis = pattern_analyzer.analyze("crystal")

# Get phonetic analysis as well
var phonetic_analyzer = JSHPhoneticAnalyzer.get_instance()
var phonetic_analysis = phonetic_analyzer.analyze("crystal")

# Create entity using combined analysis
var entity_manager = JSHEntityManager.get_instance()
var entity = entity_manager.create_entity("crystal")

# Set properties based on pattern analysis
entity.set_property("symmetry", pattern_analysis.symmetry)
entity.set_property("pattern_power", pattern_analysis.power)
entity.set_property("visual_balance", pattern_analysis.visual_balance)

# Combine with phonetic properties
entity.set_property("combined_power", 
    (pattern_analysis.power + phonetic_analysis.power) / 2)
```

## Integration with Other Systems

The `JSHPatternAnalyzer` integrates with:

- **JSHWordManifestor**: Provides pattern analysis for word manifestation properties
- **JSHPhoneticAnalyzer**: Complements sound analysis with pattern structure
- **JSHSemanticAnalyzer**: Combined with pattern analysis for complete word profiling
- **JSHEntityVisualizer**: Pattern qualities influence entity visual representation
- **JSHEntityEvolution**: Pattern power contributes to entity evolution potential

## Technical Considerations

### Performance

The pattern analysis is efficient for most words:
- Analysis complexity generally scales linearly with word length
- Most operations complete in a single pass
- No external dependencies required

### Extensibility

The system can be extended through:
- Adding new pattern types to the detection system
- Adjusting pattern weights to emphasize different qualities
- Enhancing visual balance algorithms with typography concepts
- Creating new sequence pattern detectors

### Limitations

Current implementation has some limitations:
- Simplified syllable splitting may not be linguistically accurate
- Visual balance calculation is approximated
- Analysis works best with standard Latin alphabets
- Limited support for diacritics and special characters