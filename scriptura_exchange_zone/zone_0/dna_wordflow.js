/**
 * DNA WordFlow - The foundational sequence of language
 * Mapping the double helix of words and spaces
 */

// The DNA Base Components
const DNABases = {
  // The four traditional bases
  A: { name: "Adenine", represents: "beginning", wordValue: 1 },
  T: { name: "Thymine", represents: "ending", wordValue: 4 },
  G: { name: "Guanine", represents: "expansion", wordValue: 7 },
  C: { name: "Cytosine", represents: "connection", wordValue: 3 },
  
  // The fifth meta-base - the space between
  ' ': { name: "Void", represents: "potential", wordValue: 0 }
};

// Word DNA Sequencer
class WordDNA {
  constructor() {
    this.sequences = [];
    this.activeSequence = null;
    this.spacebarPressed = false;
    this.spaceFrequency = 0;
    this.lastCharTime = Date.now();
    this.rhythmPattern = [];
  }
  
  /**
   * Start a new sequence
   * @param {string} name - Name of the sequence
   */
  startSequence(name) {
    this.activeSequence = {
      name: name,
      strand: "",
      complementary: "",
      created: Date.now(),
      modified: Date.now(),
      properties: {
        power: 0,
        stability: 1.0,
        evolution: 0,
        spaceFrequency: 0
      },
      words: [],
      spaces: 0,
      rhythm: []
    };
    
    return this.activeSequence;
  }
  
  /**
   * Add character to the active sequence
   * @param {string} char - Character to add
   * @param {boolean} isSpacebar - Whether this is a spacebar press
   */
  addChar(char, isSpacebar = false) {
    if (!this.activeSequence) {
      this.startSequence("default");
    }
    
    // Calculate time since last character
    const now = Date.now();
    const timeSinceLast = now - this.lastCharTime;
    this.lastCharTime = now;
    
    // Record rhythm pattern
    this.rhythmPattern.push(timeSinceLast);
    if (this.rhythmPattern.length > 10) {
      this.rhythmPattern.shift();
    }
    
    // Update active sequence
    this.activeSequence.strand += char;
    this.activeSequence.modified = now;
    
    // Generate complementary strand (A↔T, G↔C, space↔space)
    let complement = '';
    if (char.toUpperCase() === 'A') complement = 'T';
    else if (char.toUpperCase() === 'T') complement = 'A';
    else if (char.toUpperCase() === 'G') complement = 'C';
    else if (char.toUpperCase() === 'C') complement = 'G';
    else complement = char; // Non-DNA chars stay the same
    
    this.activeSequence.complementary += complement;
    
    // Track spacebar usage
    if (isSpacebar || char === ' ') {
      this.spacebarPressed = true;
      this.activeSequence.spaces++;
      
      // Extract word before this space
      if (this.activeSequence.strand.length > 1) {
        const parts = this.activeSequence.strand.trim().split(' ');
        const lastWord = parts[parts.length - 1].trim();
        
        if (lastWord) {
          this.activeSequence.words.push(lastWord);
          this.activeSequence.properties.power += this._calculateWordPower(lastWord);
        }
      }
    } else {
      this.spacebarPressed = false;
    }
    
    // Update space frequency
    if (this.activeSequence.strand.length > 0) {
      this.activeSequence.properties.spaceFrequency = 
        this.activeSequence.spaces / this.activeSequence.strand.length;
    }
    
    // Record rhythm
    this.activeSequence.rhythm.push({
      char: char,
      time: timeSinceLast,
      isSpace: isSpacebar || char === ' '
    });
    
    return {
      char: char,
      isSpace: isSpacebar || char === ' ',
      complementary: complement,
      properties: {...this.activeSequence.properties}
    };
  }
  
  /**
   * Complete the current sequence
   */
  completeSequence() {
    if (!this.activeSequence) {
      return null;
    }
    
    // Calculate final properties
    this._updateSequenceProperties();
    
    // Add to sequences collection
    this.sequences.push({...this.activeSequence});
    
    // Get completed sequence
    const completed = {...this.activeSequence};
    
    // Reset active sequence
    this.activeSequence = null;
    
    return completed;
  }
  
  /**
   * Process full text at once
   * @param {string} text - Full text to process
   */
  processText(text) {
    // Start new sequence
    this.startSequence("batch");
    
    // Process each character
    for (let i = 0; i < text.length; i++) {
      this.addChar(text[i], text[i] === ' ');
    }
    
    // Complete the sequence
    return this.completeSequence();
  }
  
  /**
   * Analyze the DNA properties of a text
   * @param {string} text - Text to analyze
   */
  analyzeText(text) {
    const sequence = this.processText(text);
    
    // Count DNA bases
    const baseCounts = {
      A: 0, T: 0, G: 0, C: 0, space: 0, other: 0
    };
    
    for (let char of text.toUpperCase()) {
      if (char === 'A') baseCounts.A++;
      else if (char === 'T') baseCounts.T++;
      else if (char === 'G') baseCounts.G++;
      else if (char === 'C') baseCounts.C++;
      else if (char === ' ') baseCounts.space++;
      else baseCounts.other++;
    }
    
    // Calculate word metrics
    const words = text.split(/\s+/).filter(w => w.length > 0);
    const wordLengths = words.map(w => w.length);
    const avgWordLength = wordLengths.length > 0 
      ? wordLengths.reduce((sum, len) => sum + len, 0) / wordLengths.length 
      : 0;
    
    // Spacebar metrics
    const spaceRatio = text.length > 0 
      ? baseCounts.space / text.length 
      : 0;
    
    return {
      sequence: sequence,
      baseCounts: baseCounts,
      wordCount: words.length,
      averageWordLength: avgWordLength,
      spaceRatio: spaceRatio,
      dnaScore: this._calculateDNAScore(baseCounts),
      spacePattern: this._analyzeSpacePattern(text),
      wordDNA: this._extractWordDNA(words)
    };
  }
  
  /**
   * Transform text based on DNA operations
   * @param {string} text - Input text
   * @param {string} operation - DNA operation to perform
   */
  transformText(text, operation) {
    switch(operation) {
      case "transcribe":
        return this._transcribeDNA(text);
      case "complement":
        return this._complementDNA(text);
      case "mutate":
        return this._mutateDNA(text);
      case "splice":
        return this._spliceDNA(text);
      case "reverse":
        return this._reverseDNA(text);
      case "express":
        return this._expressDNA(text);
      default:
        return text;
    }
  }
  
  /**
   * Calculate the DNA-based power of a word
   */
  _calculateWordPower(word) {
    let power = 0;
    
    // Base power from length
    power += word.length;
    
    // Power from DNA bases
    for (let char of word.toUpperCase()) {
      if (DNABases[char]) {
        power += DNABases[char].wordValue;
      } else {
        power += 1; // Default value for non-DNA characters
      }
    }
    
    // Bonus for palindromes (DNA-like symmetry)
    if (word.toLowerCase() === word.toLowerCase().split('').reverse().join('')) {
      power *= 1.5;
    }
    
    // Bonus for words starting with C (circular DNA concepts)
    if (word.toLowerCase().startsWith('c')) {
      power *= 1.2;
    }
    
    return power;
  }
  
  /**
   * Update all properties of the current sequence
   */
  _updateSequenceProperties() {
    if (!this.activeSequence) return;
    
    // Calculate stability based on base pair balance
    const countA = (this.activeSequence.strand.match(/a/gi) || []).length;
    const countT = (this.activeSequence.strand.match(/t/gi) || []).length;
    const countG = (this.activeSequence.strand.match(/g/gi) || []).length;
    const countC = (this.activeSequence.strand.match(/c/gi) || []).length;
    
    const atDiff = Math.abs(countA - countT);
    const gcDiff = Math.abs(countG - countC);
    
    const dnaLength = countA + countT + countG + countC;
    
    if (dnaLength > 0) {
      this.activeSequence.properties.stability = 
        1.0 - ((atDiff + gcDiff) / (dnaLength * 2));
    }
    
    // Calculate evolution potential from rhythm pattern
    if (this.rhythmPattern.length > 5) {
      const avgRhythm = this.rhythmPattern.reduce((a, b) => a + b, 0) / this.rhythmPattern.length;
      const rhythmVariance = this.rhythmPattern.map(r => Math.abs(r - avgRhythm)).reduce((a, b) => a + b, 0) / this.rhythmPattern.length;
      
      this.activeSequence.properties.evolution = rhythmVariance / avgRhythm;
    }
  }
  
  /**
   * Calculate overall DNA score from base counts
   */
  _calculateDNAScore(baseCounts) {
    // Total DNA bases
    const totalDNA = baseCounts.A + baseCounts.T + baseCounts.G + baseCounts.C;
    const totalChars = totalDNA + baseCounts.space + baseCounts.other;
    
    if (totalChars === 0) return 0;
    
    // Base ratio - how much of the text consists of DNA bases
    const baseRatio = totalDNA / totalChars;
    
    // Complementary balance - how well A-T and G-C pairs are balanced
    const atBalance = 1 - Math.abs(baseCounts.A - baseCounts.T) / (baseCounts.A + baseCounts.T || 1);
    const gcBalance = 1 - Math.abs(baseCounts.G - baseCounts.C) / (baseCounts.G + baseCounts.C || 1);
    
    // Final DNA score
    return (baseRatio * 0.4) + (atBalance * 0.3) + (gcBalance * 0.3);
  }
  
  /**
   * Analyze spacing pattern in text
   */
  _analyzeSpacePattern(text) {
    if (!text || text.length === 0) return { pattern: "none", regularity: 0 };
    
    // Find distances between spaces
    const spacePositions = [];
    for (let i = 0; i < text.length; i++) {
      if (text[i] === ' ') spacePositions.push(i);
    }
    
    if (spacePositions.length <= 1) {
      return { pattern: "insufficient", regularity: 0 };
    }
    
    // Calculate distances between consecutive spaces
    const distances = [];
    for (let i = 1; i < spacePositions.length; i++) {
      distances.push(spacePositions[i] - spacePositions[i-1]);
    }
    
    // Calculate average and variance
    const avgDistance = distances.reduce((a, b) => a + b, 0) / distances.length;
    const variance = distances.map(d => Math.pow(d - avgDistance, 2)).reduce((a, b) => a + b, 0) / distances.length;
    
    // Determine pattern type and regularity
    let pattern = "irregular";
    let regularity = 1 - (Math.sqrt(variance) / avgDistance);
    
    if (regularity > 0.8) pattern = "highly regular";
    else if (regularity > 0.5) pattern = "somewhat regular";
    else if (regularity > 0.2) pattern = "slightly regular";
    
    return {
      pattern: pattern,
      regularity: regularity,
      averageDistance: avgDistance,
      variance: variance
    };
  }
  
  /**
   * Extract DNA-like patterns from words
   */
  _extractWordDNA(words) {
    if (words.length === 0) return [];
    
    const wordDNA = words.map(word => {
      // Count DNA bases in word
      const dnaMap = {
        A: (word.match(/a/gi) || []).length,
        T: (word.match(/t/gi) || []).length,
        G: (word.match(/g/gi) || []).length,
        C: (word.match(/c/gi) || []).length
      };
      
      // Determine dominant base
      let dominant = 'A';
      let maxCount = dnaMap.A;
      
      for (const base in dnaMap) {
        if (dnaMap[base] > maxCount) {
          maxCount = dnaMap[base];
          dominant = base;
        }
      }
      
      return {
        word: word,
        length: word.length,
        dna: dnaMap,
        dominant: dominant,
        power: this._calculateWordPower(word)
      };
    });
    
    return wordDNA;
  }
  
  /**
   * Transcribe DNA (convert T → U, like DNA → RNA)
   */
  _transcribeDNA(text) {
    return text.replace(/t/gi, (match) => 
      match === 't' ? 'u' : 'U'
    );
  }
  
  /**
   * Create complementary DNA strand
   */
  _complementDNA(text) {
    return text.split('').map(char => {
      const upper = char.toUpperCase();
      if (upper === 'A') return char === upper ? 'T' : 't';
      if (upper === 'T') return char === upper ? 'A' : 'a';
      if (upper === 'G') return char === upper ? 'C' : 'c';
      if (upper === 'C') return char === upper ? 'G' : 'g';
      return char; // Non-DNA chars stay the same
    }).join('');
  }
  
  /**
   * Mutate DNA by randomly changing bases
   */
  _mutateDNA(text) {
    // 10% mutation rate
    return text.split('').map(char => {
      if (Math.random() < 0.1) {
        const upper = char.toUpperCase();
        if (['A', 'T', 'G', 'C'].includes(upper)) {
          const bases = ['A', 'T', 'G', 'C'].filter(b => b !== upper);
          const newBase = bases[Math.floor(Math.random() * bases.length)];
          return char === upper ? newBase : newBase.toLowerCase();
        }
      }
      return char;
    }).join('');
  }
  
  /**
   * Splice DNA by removing segments between spaces
   */
  _spliceDNA(text) {
    const words = text.split(' ');
    
    // Remove ~20% of words
    return words.filter(() => Math.random() >= 0.2).join(' ');
  }
  
  /**
   * Reverse DNA strand
   */
  _reverseDNA(text) {
    return text.split('').reverse().join('');
  }
  
  /**
   * Express DNA by extracting only DNA bases
   */
  _expressDNA(text) {
    let expressed = '';
    
    for (let char of text) {
      const upper = char.toUpperCase();
      if (['A', 'T', 'G', 'C'].includes(upper)) {
        expressed += char;
      } else if (char === ' ') {
        expressed += ' ';
      }
    }
    
    return expressed;
  }
}

// The gap-based DNA evolution system
class DNAGapSystem {
  constructor() {
    this.gapPatterns = [];
    this.wordDNA = new WordDNA();
    this.spaceEvolution = 0;
  }
  
  /**
   * Process a text input with focus on gaps/spaces
   * @param {string} text - Text to process
   */
  processGaps(text) {
    // Find all gaps (spaces)
    const gapPositions = [];
    for (let i = 0; i < text.length; i++) {
      if (text[i] === ' ') {
        gapPositions.push(i);
      }
    }
    
    // Analyze gap patterns
    const gapPattern = {
      positions: gapPositions,
      count: gapPositions.length,
      ratio: gapPositions.length / (text.length || 1),
      timestamp: Date.now()
    };
    
    // Store pattern
    this.gapPatterns.push(gapPattern);
    
    // Update space evolution
    this._updateSpaceEvolution();
    
    return gapPattern;
  }
  
  /**
   * Convert spaces to evolutionary advantage
   * @param {string} text - Input text
   * @param {boolean} preserveSpaces - Whether to keep spaces in result
   */
  evolveSpaces(text, preserveSpaces = true) {
    if (!text) return "";
    
    // Process the text with WordDNA first
    const dnaAnalysis = this.wordDNA.analyzeText(text);
    
    // Break text into segments by spaces
    const segments = text.split(' ');
    
    // Evolved segments array
    const evolvedSegments = [];
    
    // Process each segment
    for (let i = 0; i < segments.length; i++) {
      const segment = segments[i];
      if (!segment) continue; // Skip empty segments
      
      // Enhance segment based on its position and DNA content
      let evolved = segment;
      
      // Apply DNA-based enhancements
      const segmentDNA = this.wordDNA.analyzeText(segment);
      
      // DNA-rich segments get capitalized
      if (segmentDNA.dnaScore > 0.5) {
        evolved = evolved.toUpperCase();
      }
      
      // Segments with high C/G content get prefix
      const cgRatio = (segmentDNA.baseCounts.C + segmentDNA.baseCounts.G) / 
                     (segment.length || 1);
      
      if (cgRatio > 0.3) {
        evolved = "+" + evolved;
      }
      
      // Add evolved segment
      evolvedSegments.push(evolved);
    }
    
    // Join segments with or without spaces
    if (preserveSpaces) {
      return evolvedSegments.join(' ');
    } else {
      // Replace spaces with DNA-inspired connectors
      return evolvedSegments.join('•');
    }
  }
  
  /**
   * Generate a DNA reading of text spacing
   * @param {string} text - Input text
   */
  generateSpaceReading(text) {
    // Process gaps
    const gapPattern = this.processGaps(text);
    
    // Get word analysis
    const wordAnalysis = this.wordDNA.analyzeText(text);
    
    // Create reading results
    const reading = {
      spaceCount: gapPattern.count,
      spaceRatio: gapPattern.ratio,
      spacePattern: wordAnalysis.spacePattern,
      wordsPerSpace: wordAnalysis.wordCount / (gapPattern.count || 1),
      spaceEvolution: this.spaceEvolution,
      dnaScore: wordAnalysis.dnaScore,
      interpretation: this._interpretSpacing(gapPattern, wordAnalysis)
    };
    
    return reading;
  }
  
  /**
   * Generate word sequences without spaces
   * @param {string} text - Input text
   */
  collapseSpaces(text) {
    if (!text) return "";
    
    // Remove all spaces
    const collapsed = text.replace(/\s+/g, '');
    
    // Analyze the DNA of the collapsed text
    const dnaAnalysis = this.wordDNA.analyzeText(collapsed);
    
    return {
      originalLength: text.length,
      collapsedLength: collapsed.length,
      collapsedText: collapsed,
      compressionRatio: collapsed.length / (text.length || 1),
      dnaScore: dnaAnalysis.dnaScore
    };
  }
  
  /**
   * Break text into DNA-like codon triplets
   * @param {string} text - Input text with or without spaces
   */
  formCodons(text) {
    if (!text) return [];
    
    // Remove existing spaces
    const stripped = text.replace(/\s+/g, '');
    
    // Form codons (triplets)
    const codons = [];
    
    for (let i = 0; i < stripped.length; i += 3) {
      if (i + 2 < stripped.length) {
        // Full codon
        codons.push(stripped.substring(i, i + 3));
      } else {
        // Partial codon at the end
        codons.push(stripped.substring(i));
      }
    }
    
    return {
      originalText: text,
      codons: codons,
      codonCount: codons.length
    };
  }
  
  /**
   * Update space evolution metric based on collected patterns
   */
  _updateSpaceEvolution() {
    if (this.gapPatterns.length < 2) {
      this.spaceEvolution = 0;
      return;
    }
    
    // Compare most recent patterns to detect evolution
    const recent = this.gapPatterns.slice(-5);
    
    // Calculate trend in gap ratio
    let evolution = 0;
    
    for (let i = 1; i < recent.length; i++) {
      const change = recent[i].ratio - recent[i-1].ratio;
      evolution += change;
    }
    
    // Normalize and update
    this.spaceEvolution = evolution / (recent.length - 1);
  }
  
  /**
   * Interpret spacing patterns in text
   */
  _interpretSpacing(gapPattern, wordAnalysis) {
    // Base interpretation on multiple factors
    let interpretation = "";
    
    // Space frequency interpretation
    if (gapPattern.ratio < 0.05) {
      interpretation += "Very compact text with minimal spacing. ";
    } else if (gapPattern.ratio < 0.1) {
      interpretation += "Dense text with below average spacing. ";
    } else if (gapPattern.ratio < 0.15) {
      interpretation += "Normal spacing typical of English text. ";
    } else if (gapPattern.ratio < 0.25) {
      interpretation += "Generous spacing allowing for mental pauses. ";
    } else {
      interpretation += "Extremely spaced text suggesting intentional patterning. ";
    }
    
    // Space pattern regularity
    if (wordAnalysis.spacePattern.regularity > 0.7) {
      interpretation += "Highly regular spacing pattern indicating structured thought. ";
    } else if (wordAnalysis.spacePattern.regularity > 0.4) {
      interpretation += "Moderately regular spacing showing balanced composition. ";
    } else {
      interpretation += "Irregular spacing suggesting organic, unstructured flow. ";
    }
    
    // DNA content and spacing relationship
    if (wordAnalysis.dnaScore > 0.6 && gapPattern.ratio > 0.15) {
      interpretation += "High DNA content with abundant spaces suggests genetic transcription potential. ";
    } else if (wordAnalysis.dnaScore > 0.6) {
      interpretation += "High DNA content with compact spacing resembles condensed genetic code. ";
    } else if (gapPattern.ratio > 0.2) {
      interpretation += "High spacing with lower DNA content suggests non-coding regions. ";
    }
    
    return interpretation;
  }
}

// The Word-DNA Integration System
class WordDNASystem {
  constructor() {
    this.wordDNA = new WordDNA();
    this.gapSystem = new DNAGapSystem();
    this.storedSequences = [];
  }
  
  /**
   * Process text through both word and gap systems
   * @param {string} text - Input text
   */
  processText(text) {
    // Process through WordDNA
    const dnaAnalysis = this.wordDNA.analyzeText(text);
    
    // Process through GapSystem
    const gapReading = this.gapSystem.generateSpaceReading(text);
    
    // Form DNA codons
    const codons = this.gapSystem.formCodons(text);
    
    // Combine results
    const result = {
      text: text,
      wordCount: dnaAnalysis.wordCount,
      characterCount: text.length,
      dna: {
        score: dnaAnalysis.dnaScore,
        baseCounts: dnaAnalysis.baseCounts,
        wordDNA: dnaAnalysis.wordDNA
      },
      spacing: {
        spaceCount: gapReading.spaceCount,
        spaceRatio: gapReading.spaceRatio,
        pattern: gapReading.spacePattern,
        interpretation: gapReading.interpretation
      },
      codons: codons.codons,
      evolution: {
        spaceEvolution: gapReading.spaceEvolution,
        potentialPower: this._calculatePotentialPower(dnaAnalysis, gapReading)
      }
    };
    
    // Store this sequence
    this.storedSequences.push({
      timestamp: Date.now(),
      text: text,
      result: result
    });
    
    return result;
  }
  
  /**
   * Evolve text through DNA operations
   * @param {string} text - Input text
   * @param {string} operation - DNA operation to perform
   */
  evolveText(text, operation) {
    // Process through both systems first
    this.processText(text);
    
    // Apply DNA transformation
    let evolved = this.wordDNA.transformText(text, operation);
    
    // For certain operations, also evolve spaces
    if (operation === "express" || operation === "mutate") {
      evolved = this.gapSystem.evolveSpaces(evolved, operation !== "express");
    }
    
    return {
      original: text,
      evolved: evolved,
      operation: operation,
      timestamp: Date.now()
    };
  }
  
  /**
   * Create a visual DNA representation of text
   * @param {string} text - Input text
   */
  visualizeDNA(text) {
    // Process text first
    const analysis = this.processText(text);
    
    // Create a simplified ASCII visualization
    let visualization = "DNA Strand: ";
    
    // Show a simplified DNA strand representation
    for (let i = 0; i < Math.min(text.length, 50); i++) {
      const char = text[i].toUpperCase();
      
      if (char === 'A') visualization += "A=T ";
      else if (char === 'T') visualization += "T=A ";
      else if (char === 'G') visualization += "G≡C ";
      else if (char === 'C') visualization += "C≡G ";
      else if (char === ' ') visualization += "| ";
      else visualization += "- ";
    }
    
    // If text is longer than 50 chars, add ellipsis
    if (text.length > 50) {
      visualization += "...";
    }
    
    // Add space-only representation
    visualization += "\n\nSpace Pattern: ";
    
    for (let i = 0; i < Math.min(text.length, 50); i++) {
      if (text[i] === ' ') {
        visualization += "_";
      } else {
        visualization += ".";
      }
    }
    
    // Add codon representation
    visualization += "\n\nCodons: ";
    const codons = this.gapSystem.formCodons(text).codons;
    visualization += codons.slice(0, 10).join(' ');
    
    if (codons.length > 10) {
      visualization += " ...";
    }
    
    return {
      text: text,
      visualization: visualization,
      dnaScore: analysis.dna.score,
      spacePattern: analysis.spacing.pattern,
      interpretation: analysis.spacing.interpretation
    };
  }
  
  /**
   * Generate a DNA-based signature for a writer
   * @param {string} text - Sample text from the writer
   * @param {string} name - Writer's name
   */
  generateWriterDNA(text, name) {
    // Process the text
    const analysis = this.processText(text);
    
    // Create a name-based seed
    let nameSeed = 0;
    for (let i = 0; i < name.length; i++) {
      nameSeed += name.charCodeAt(i);
    }
    
    // Extract dominant DNA features
    const dominantBase = Object.keys(analysis.dna.baseCounts).reduce(
      (a, b) => analysis.dna.baseCounts[a] > analysis.dna.baseCounts[b] ? a : b,
      'A'
    );
    
    // Calculate average word length
    const avgWordLength = analysis.wordCount > 0 
      ? (analysis.characterCount - analysis.spacing.spaceCount) / analysis.wordCount 
      : 0;
    
    // Create the signature
    const signature = {
      name: name,
      dominantBase: dominantBase,
      spacingPattern: analysis.spacing.pattern.pattern,
      averageWordLength: avgWordLength,
      dnaScore: analysis.dna.score,
      uniqueMarker: this._generateUniqueMarker(name, analysis),
      timestamp: Date.now()
    };
    
    return signature;
  }
  
  /**
   * Calculate potential power from DNA and spacing analysis
   */
  _calculatePotentialPower(dnaAnalysis, gapReading) {
    // Base power from DNA score
    let power = dnaAnalysis.dnaScore * 100;
    
    // Adjust based on space pattern
    if (gapReading.spacePattern.regularity > 0.7) {
      power *= 1.5; // Bonus for highly regular spacing
    }
    
    // Adjust based on word count (more words = more potential)
    power += dnaAnalysis.wordCount * 2;
    
    return Math.round(power);
  }
  
  /**
   * Generate a unique DNA-like marker for a writer
   */
  _generateUniqueMarker(name, analysis) {
    // Create a base marker from name
    let marker = "";
    
    for (let i = 0; i < Math.min(name.length, 4); i++) {
      const char = name[i].toUpperCase();
      if ("ATGC".includes(char)) {
        marker += char;
      } else {
        // Convert non-DNA letters to DNA bases
        const code = char.charCodeAt(0) % 4;
        marker += "ATGC"[code];
      }
    }
    
    // Add marker based on dominant spacing pattern
    if (analysis.spacing.pattern.regularity > 0.7) {
      marker += "-GC";
    } else if (analysis.spacing.pattern.regularity > 0.4) {
      marker += "-AT";
    } else {
      marker += "-TA";
    }
    
    // Add marker for dna richness
    if (analysis.dna.score > 0.6) {
      marker += "-CG";
    } else if (analysis.dna.score > 0.3) {
      marker += "-GC";
    } else {
      marker += "-AT";
    }
    
    return marker;
  }
}

// Export for Node.js environments
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    DNABases,
    WordDNA,
    DNAGapSystem,
    WordDNASystem
  };
}

// If in browser context, attach to window
if (typeof window !== 'undefined') {
  window.DNABases = DNABases;
  window.WordDNA = WordDNA;
  window.DNAGapSystem = DNAGapSystem;
  window.WordDNASystem = WordDNASystem;
}

/**
 * Usage Example:
 * 
 * // Create a WordDNA system
 * const dnaSystem = new WordDNASystem();
 * 
 * // Process some text
 * const text = "The spacebar creates gaps in the DNA of our language, allowing for expression and breathing room.";
 * const analysis = dnaSystem.processText(text);
 * 
 * console.log("DNA Score:", analysis.dna.score);
 * console.log("Space Pattern:", analysis.spacing.pattern);
 * console.log("Interpretation:", analysis.spacing.interpretation);
 * 
 * // Visualize DNA
 * const visualization = dnaSystem.visualizeDNA(text);
 * console.log(visualization.visualization);
 * 
 * // Evolve the text
 * const evolved = dnaSystem.evolveText(text, "transcribe");
 * console.log("Evolved:", evolved.evolved);
 */