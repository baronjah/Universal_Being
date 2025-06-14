/**
 * Story Weaver - Bracet Turn System
 * Creates and repairs stories through word shape patterns
 * Connects terminal curves with meaning
 */

// Core Shape Configuration
const ShapePatterns = {
  // Base shapes that form the foundation of stories
  curves: {
    gentle: { symbol: "~", meaningStrength: 4, resonance: "flow" },
    sharp: { symbol: "^", meaningStrength: 7, resonance: "intensity" },
    circular: { symbol: "○", meaningStrength: 9, resonance: "completion" },
    wave: { symbol: "≈", meaningStrength: 6, resonance: "oscillation" },
    spiral: { symbol: "@", meaningStrength: 8, resonance: "evolution" }
  },
  
  // Line patterns representing story flow
  lines: {
    solid: { symbol: "─", meaningStrength: 3, resonance: "stability" },
    dashed: { symbol: "- - -", meaningStrength: 2, resonance: "transition" },
    dotted: { symbol: "···", meaningStrength: 1, resonance: "suggestion" },
    double: { symbol: "═", meaningStrength: 5, resonance: "emphasis" },
    thick: { symbol: "▬", meaningStrength: 6, resonance: "foundation" }
  },
  
  // Special bracets that hold story segments
  bracets: {
    standard: { open: "[", close: "]", meaningStrength: 3, resonance: "containment" },
    curly: { open: "{", close: "}", meaningStrength: 6, resonance: "code" },
    angle: { open: "<", close: ">", meaningStrength: 4, resonance: "direction" },
    special: { open: "⦗", close: "⦘", meaningStrength: 8, resonance: "transcendence" },
    quantum: { open: "⟨", close: "⟩", meaningStrength: 9, resonance: "uncertainty" }
  },
  
  // Terminal-specific shapes that carry special meaning
  terminal: {
    cursor: { symbol: "▋", meaningStrength: 7, resonance: "presence" },
    newline: { symbol: "↵", meaningStrength: 4, resonance: "continuation" },
    space: { symbol: "␣", meaningStrength: 2, resonance: "separation" },
    tab: { symbol: "→", meaningStrength: 3, resonance: "organization" },
    box: { symbol: "□", meaningStrength: 5, resonance: "potential" }
  }
};

// The shape meanings in words - how letters form visual patterns
const LetterShapes = {
  curved: ["a", "c", "e", "f", "g", "j", "m", "n", "o", "p", "q", "r", "s", "u"],
  angled: ["k", "v", "w", "x", "y", "z"],
  linear: ["h", "i", "l", "t"],
  mixed: ["b", "d", "h"]
};

// Turn stages that define story progression
const TurnStages = [
  "GENESIS",      // Beginning 
  "TENSION",      // Complication
  "REVELATION",   // Discovery
  "INTEGRATION",  // Understanding
  "RESOLUTION",   // Completion
  "ECHO",         // Aftermath
  "RECURSION",    // Return to beginning in new form
  "TRANSCENDENCE" // Moving beyond
];

/**
 * StoryWeaver class - Creates and repairs stories through shape patterns
 * The system that understands how terminal shapes connect to meaning
 */
class StoryWeaver {
  constructor() {
    this.turnIndex = 0;
    this.currentStage = TurnStages[0];
    this.stories = [];
    this.currentStory = null;
    this.wordShapeMap = {};
    this.bracetStack = [];
    this.visualAnimations = {};
    
    // Configuration
    this.colorWords = true;
    this.showShapes = true;
    this.enableHologram = true;
    this.turnLength = 9; // Words per turn
    
    // Initialize word shape analysis
    this._initializeWordShapeSystem();
  }
  
  /**
   * Begin a new story based on seed words
   * @param {string} title - The story title
   * @param {array} seedWords - Words to build the story from
   * @param {object} settings - Optional story settings
   */
  beginStory(title, seedWords, settings = {}) {
    // Create new story structure
    this.currentStory = {
      id: Date.now().toString(36) + Math.random().toString(36).substr(2),
      title: title,
      seedWords: seedWords,
      settings: {
        colorMode: settings.colorMode || "vibrant",
        bracetStyle: settings.bracetStyle || "standard",
        shapeEmphasis: settings.shapeEmphasis || "balanced",
        turnCount: settings.turnCount || 8,
        ...settings
      },
      turns: [],
      segments: [],
      bracets: [],
      shapePatterns: [],
      status: "beginning",
      creationDate: new Date(),
      lastModified: new Date()
    };
    
    // Reset turns and stage
    this.turnIndex = 0;
    this.currentStage = TurnStages[0];
    
    // Add seed words to shape map
    this._analyzeSeedWords(seedWords);
    
    // Create first empty turn
    this._createNewTurn();
    
    console.log(`Story "${title}" begun with ${seedWords.length} seed words`);
    console.log(`Current stage: ${this.currentStage}`);
    
    return {
      storyId: this.currentStory.id,
      title: this.currentStory.title,
      stage: this.currentStage,
      seedWords: seedWords
    };
  }
  
  /**
   * Add message content to the story
   * @param {string} content - The message content to add
   * @param {boolean} autoBracet - Whether to automatically add bracets
   */
  addMessageToStory(content, autoBracet = true) {
    if (!this.currentStory) {
      throw new Error("No active story. Please begin a story first");
    }
    
    // Split content into words
    const words = content.split(/\s+/).filter(w => w.length > 0);
    
    // Check for specific bracet markers in content
    const hasBracets = content.includes('[') || content.includes('{') || 
                    content.includes('<') || content.includes('(');
    
    // Automatically add bracets if needed and requested
    if (autoBracet && !hasBracets) {
      const bracetType = this._selectBracetType();
      
      // Create new segment with bracets
      const segment = {
        id: Date.now().toString(36),
        bracetType: bracetType,
        content: content,
        words: words,
        turn: this.turnIndex,
        stage: this.currentStage,
        shapes: this._analyzeWordShapes(words),
        timestamp: new Date()
      };
      
      // Add bracet record
      this.currentStory.bracets.push({
        segmentId: segment.id,
        type: bracetType,
        wordCount: words.length,
        stage: this.currentStage,
        openTime: new Date()
      });
      
      // Add to story segments
      this.currentStory.segments.push(segment);
      
      // Add words to current turn
      this._addWordsToTurn(words);
      
      console.log(`Added segment with ${words.length} words in ${bracetType} bracets`);
    } else {
      // Process content with existing bracets
      const processedContent = this._processBracetedContent(content);
      
      // Add to story segments
      this.currentStory.segments.push({
        id: Date.now().toString(36),
        bracetType: "custom",
        content: content,
        processedContent: processedContent,
        words: words,
        turn: this.turnIndex,
        stage: this.currentStage,
        shapes: this._analyzeWordShapes(words),
        timestamp: new Date()
      });
      
      // Add words to current turn
      this._addWordsToTurn(words);
      
      console.log(`Added segment with ${words.length} words with custom bracets`);
    }
    
    // Update story
    this.currentStory.lastModified = new Date();
    this.currentStory.status = "developing";
    
    return {
      wordsAdded: words.length,
      currentTurn: this.turnIndex,
      currentStage: this.currentStage,
      segmentCount: this.currentStory.segments.length
    };
  }
  
  /**
   * Complete the current turn and move to the next stage
   */
  completeTurn() {
    if (!this.currentStory) {
      throw new Error("No active story. Please begin a story first");
    }
    
    // Finalize current turn
    if (this.currentStory.turns[this.turnIndex]) {
      this.currentStory.turns[this.turnIndex].completed = true;
      this.currentStory.turns[this.turnIndex].completionTime = new Date();
    }
    
    // Advance turn index
    this.turnIndex++;
    
    // Advance stage if needed
    if (this.turnIndex % Math.ceil(this.currentStory.settings.turnCount / TurnStages.length) === 0) {
      const nextStageIndex = (TurnStages.indexOf(this.currentStage) + 1) % TurnStages.length;
      this.currentStage = TurnStages[nextStageIndex];
    }
    
    // Create new turn
    this._createNewTurn();
    
    console.log(`Completed turn ${this.turnIndex - 1}, now at turn ${this.turnIndex}`);
    console.log(`Current stage: ${this.currentStage}`);
    
    return {
      previousTurn: this.turnIndex - 1,
      currentTurn: this.turnIndex,
      currentStage: this.currentStage
    };
  }
  
  /**
   * Repair a story by analyzing shape patterns and filling gaps
   * @param {object} repairOptions - Options for the repair process
   */
  repairStory(repairOptions = {}) {
    if (!this.currentStory) {
      throw new Error("No active story. Please begin a story first");
    }
    
    // Default repair options
    const options = {
      repairBracets: true,
      balanceShapes: true,
      reconnectSegments: true,
      addMissingElements: true,
      ...repairOptions
    };
    
    const repairReport = {
      repairsMade: 0,
      bracetsRepaired: 0,
      shapesBalanced: 0,
      segmentsReconnected: 0,
      elementsAdded: 0
    };
    
    // Repair unclosed bracets
    if (options.repairBracets) {
      const openBracets = this.currentStory.bracets.filter(b => !b.closeTime);
      
      openBracets.forEach(bracet => {
        // Close the bracet
        bracet.closeTime = new Date();
        repairReport.bracetsRepaired++;
      });
    }
    
    // Balance shape patterns across the story
    if (options.balanceShapes) {
      const shapeAnalysis = this._analyzeStoryShapes();
      
      // Find imbalanced shape patterns
      const shapeTypes = Object.keys(shapeAnalysis);
      const targetDistribution = 1 / shapeTypes.length;
      
      for (const shape of shapeTypes) {
        const currentDistribution = shapeAnalysis[shape];
        
        // If significantly imbalanced, add to repair notes
        if (Math.abs(currentDistribution - targetDistribution) > 0.2) {
          this.currentStory.shapePatterns.push({
            shape: shape,
            status: "imbalanced",
            measure: currentDistribution,
            targetMeasure: targetDistribution,
            repairNote: currentDistribution < targetDistribution ? 
              `Need more ${shape} shaped patterns` : 
              `Reduce ${shape} shaped patterns`
          });
          
          repairReport.shapesBalanced++;
        }
      }
    }
    
    // Reconnect disjointed segments
    if (options.reconnectSegments) {
      const segments = this.currentStory.segments;
      
      // Find segments without connections to others
      for (let i = 0; i < segments.length; i++) {
        let hasConnection = false;
        
        // Check for word overlap with other segments
        for (let j = 0; j < segments.length; j++) {
          if (i === j) continue;
          
          const sharedWords = segments[i].words.filter(w => 
            segments[j].words.includes(w)
          );
          
          if (sharedWords.length > 0) {
            hasConnection = true;
            break;
          }
        }
        
        // If no connection found, mark for repair
        if (!hasConnection && segments[i].words.length > 0) {
          segments[i].needsConnection = true;
          
          // Suggest seed words to connect with
          segments[i].connectionSuggestions = this.currentStory.seedWords
            .filter(w => !segments[i].words.includes(w))
            .slice(0, 3);
          
          repairReport.segmentsReconnected++;
        }
      }
    }
    
    // Add missing elements based on story stage
    if (options.addMissingElements) {
      // Check for missing elements in each stage
      const stageSegments = {};
      
      // Group segments by stage
      this.currentStory.segments.forEach(segment => {
        if (!stageSegments[segment.stage]) {
          stageSegments[segment.stage] = [];
        }
        stageSegments[segment.stage].push(segment);
      });
      
      // Check for missing stages
      TurnStages.forEach(stage => {
        if (!stageSegments[stage] || stageSegments[stage].length === 0) {
          this.currentStory.missingElements = this.currentStory.missingElements || [];
          this.currentStory.missingElements.push({
            type: "stage",
            stage: stage,
            suggestion: `Add content for the ${stage} stage of the story`
          });
          
          repairReport.elementsAdded++;
        }
      });
    }
    
    // Update repair count
    repairReport.repairsMade = repairReport.bracetsRepaired + 
                             repairReport.shapesBalanced + 
                             repairReport.segmentsReconnected + 
                             repairReport.elementsAdded;
    
    // Update story
    this.currentStory.lastModified = new Date();
    this.currentStory.repairHistory = this.currentStory.repairHistory || [];
    this.currentStory.repairHistory.push({
      timestamp: new Date(),
      report: repairReport
    });
    
    console.log(`Story repair complete. Made ${repairReport.repairsMade} repairs`);
    
    return repairReport;
  }
  
  /**
   * Complete the current story
   */
  completeStory() {
    if (!this.currentStory) {
      throw new Error("No active story. Please begin a story first");
    }
    
    // Perform final repairs
    this.repairStory();
    
    // Mark story as complete
    this.currentStory.status = "completed";
    this.currentStory.completionDate = new Date();
    
    // Add to stories collection
    this.stories.push({...this.currentStory});
    
    // Generate story summary
    const summary = this._generateStorySummary();
    
    // Reset current story
    const completedStory = this.currentStory;
    this.currentStory = null;
    
    console.log(`Story "${completedStory.title}" completed`);
    
    return {
      storyId: completedStory.id,
      title: completedStory.title,
      status: "completed",
      turnCount: this.turnIndex,
      segmentCount: completedStory.segments.length,
      summary: summary
    };
  }
  
  /**
   * Generate a visual representation of the story shapes
   * @param {string} format - Format to generate (ascii, html, terminal)
   */
  visualizeStoryShapes(format = "terminal") {
    if (!this.currentStory) {
      throw new Error("No active story. Please begin a story first");
    }
    
    // Generate different visualizations based on format
    switch (format) {
      case "ascii":
        return this._generateAsciiVisualization();
      
      case "html":
        return this._generateHtmlVisualization();
      
      case "terminal":
      default:
        return this._generateTerminalVisualization();
    }
  }
  
  /**
   * Generate a 3D hologram representation for visualization
   * @param {string} format - Format for the hologram data (json, binary)
   */
  generateHologram(format = "json") {
    if (!this.currentStory) {
      throw new Error("No active story. Please begin a story first");
    }
    
    // Skip if holograms not enabled
    if (!this.enableHologram) {
      return {
        enabled: false,
        message: "Hologram generation is disabled"
      };
    }
    
    // Create base hologram structure
    const hologram = {
      storyId: this.currentStory.id,
      title: this.currentStory.title,
      dimensions: {
        x: this.currentStory.segments.length * 10,
        y: 200,
        z: this.currentStory.turns.length * 20
      },
      turns: [],
      words: [],
      bracets: [],
      connections: []
    };
    
    // Add turn data
    this.currentStory.turns.forEach((turn, index) => {
      hologram.turns.push({
        index: index,
        stage: turn.stage,
        position: {
          x: 0,
          y: 0,
          z: index * 20
        },
        words: turn.words.length,
        color: this._getStageColor(turn.stage)
      });
    });
    
    // Add word data
    const allWords = new Set();
    this.currentStory.segments.forEach(segment => {
      segment.words.forEach(word => {
        if (!allWords.has(word)) {
          allWords.add(word);
          
          // Calculate position based on shape properties
          const shape = this._getWordShapeProperties(word);
          const isSeedWord = this.currentStory.seedWords.includes(word);
          
          hologram.words.push({
            text: word,
            isSeed: isSeedWord,
            position: {
              x: (Math.random() - 0.5) * hologram.dimensions.x * 0.8,
              y: (isSeedWord ? 100 : 50) + (Math.random() - 0.5) * 40,
              z: (Math.random() - 0.5) * hologram.dimensions.z * 0.8
            },
            size: 1 + (isSeedWord ? 1 : 0) + (word.length / 10),
            color: this._getWordColor(word, shape.dominantShape),
            shape: shape.dominantShape
          });
        }
      });
    });
    
    // Add bracet data
    this.currentStory.bracets.forEach(bracet => {
      const segment = this.currentStory.segments.find(s => s.id === bracet.segmentId);
      
      if (segment) {
        // Find centroid of segment words
        const wordPositions = segment.words
          .map(word => {
            const wordObj = hologram.words.find(w => w.text === word);
            return wordObj ? wordObj.position : null;
          })
          .filter(pos => pos !== null);
        
        // Calculate average position
        const centroid = {
          x: wordPositions.reduce((sum, pos) => sum + pos.x, 0) / wordPositions.length,
          y: wordPositions.reduce((sum, pos) => sum + pos.y, 0) / wordPositions.length,
          z: wordPositions.reduce((sum, pos) => sum + pos.z, 0) / wordPositions.length
        };
        
        hologram.bracets.push({
          type: bracet.type,
          segmentId: bracet.segmentId,
          position: centroid,
          size: segment.words.length / 2,
          color: this._getBracetColor(bracet.type)
        });
      }
    });
    
    // Generate connections between related words
    const processedConnections = new Set();
    
    this.currentStory.segments.forEach(segment => {
      // Connect words within the same segment
      for (let i = 0; i < segment.words.length; i++) {
        for (let j = i + 1; j < segment.words.length; j++) {
          const word1 = segment.words[i];
          const word2 = segment.words[j];
          const connectionKey = [word1, word2].sort().join(':');
          
          // Skip if already processed
          if (processedConnections.has(connectionKey)) continue;
          processedConnections.add(connectionKey);
          
          // Find word objects
          const wordObj1 = hologram.words.find(w => w.text === word1);
          const wordObj2 = hologram.words.find(w => w.text === word2);
          
          if (wordObj1 && wordObj2) {
            hologram.connections.push({
              from: word1,
              to: word2,
              strength: 0.5,
              color: this._getConnectionColor(word1, word2)
            });
          }
        }
      }
    });
    
    // Connect seed words with stronger connections
    for (let i = 0; i < this.currentStory.seedWords.length; i++) {
      for (let j = i + 1; j < this.currentStory.seedWords.length; j++) {
        const word1 = this.currentStory.seedWords[i];
        const word2 = this.currentStory.seedWords[j];
        const connectionKey = [word1, word2].sort().join(':');
        
        // Skip if already processed
        if (processedConnections.has(connectionKey)) continue;
        processedConnections.add(connectionKey);
        
        // Find word objects
        const wordObj1 = hologram.words.find(w => w.text === word1);
        const wordObj2 = hologram.words.find(w => w.text === word2);
        
        if (wordObj1 && wordObj2) {
          hologram.connections.push({
            from: word1,
            to: word2,
            strength: 1.0,
            color: "#FFFFFF",
            type: "seed"
          });
        }
      }
    }
    
    // Return in specified format
    return format === "json" ? hologram : JSON.stringify(hologram);
  }
  
  /**
   * Generate a story based on shapes and bracets
   * @param {string} theme - Theme for the story
   * @param {array} shapesOfInterest - Shapes to emphasize
   */
  generateShapeStory(theme, shapesOfInterest = ["circular", "wave"]) {
    // Create seed words based on shapes of interest
    const seedWords = this._generateWordsWithShapes(shapesOfInterest, 5);
    
    // Begin a new story
    this.beginStory(`${theme} in Shapes`, seedWords, {
      shapeEmphasis: shapesOfInterest.join(", ")
    });
    
    // Generate content for each turn
    const turnsToGenerate = 3;
    
    for (let i = 0; i < turnsToGenerate; i++) {
      // Generate turn content
      const turnWords = 7 + Math.floor(Math.random() * 8); // 7-14 words
      const content = this._generateShapedContent(theme, shapesOfInterest, turnWords);
      
      // Add to story
      this.addMessageToStory(content);
      
      // Complete turn
      if (i < turnsToGenerate - 1) {
        this.completeTurn();
      }
    }
    
    // Get the story
    const story = {...this.currentStory};
    
    // Simulate completing the story
    this.completeStory();
    
    return {
      title: story.title,
      seedWords: story.seedWords,
      turns: story.turns.length,
      segments: story.segments.length,
      dominantShapes: shapesOfInterest
    };
  }
  
  /**
   * Get detailed information about the pizza shape
   * This special function analyzes the shape of "pizza" specifically
   */
  analyzePizzaShape() {
    // The word "pizza" has special shape characteristics
    // - The 'p' has a descender (going below the line)
    // - The 'i's are dotted (creating vertical elements)
    // - The 'zz' creates a unique zigzag pattern
    // - The 'a' concludes with a curved shape
    
    return {
      word: "pizza",
      letterShapes: [
        { letter: "p", shape: "descender", curve: "semi-circular" },
        { letter: "i", shape: "dotted", vertical: true },
        { letter: "z", shape: "zigzag", angle: 45 },
        { letter: "z", shape: "zigzag", angle: 45 },
        { letter: "a", shape: "curved", closure: true }
      ],
      terminalAppearance: {
        baseline: "p_zza", // How it sits on the baseline
        ascenders: "i",    // Letters that rise above
        descenders: "p",   // Letters that go below
        visualWeight: "balanced with slight leftward emphasis"
      },
      typewriterDistortion: {
        // How it looks with slight font spacing issues in terminal
        standardSpacing: "pizza",
        wideSpacing: "p i z z a",
        narrowSpacing: "pizza",
        slightBend: "p̶i̶z̶z̶a̶" // Slight terminal rendering 'bend'
      },
      emotionalResonance: {
        shape: "comfort and satisfaction",
        sound: "sharp but resolved (with the final 'a')",
        association: "circular wholeness (like the food it represents)"
      }
    };
  }
  
  /**
   * Private: Initialize the word shape analysis system
   */
  _initializeWordShapeSystem() {
    // Initialize shape map with some predefined words
    const commonWords = [
      "the", "be", "to", "of", "and", "a", "in", "that", "have", "I",
      "it", "for", "not", "on", "with", "he", "as", "you", "do", "at"
    ];
    
    // Add common words to shape map
    commonWords.forEach(word => {
      this._analyzeWordShape(word);
    });
  }
  
  /**
   * Private: Analyze shapes of seed words
   */
  _analyzeSeedWords(words) {
    words.forEach(word => {
      const shape = this._analyzeWordShape(word);
      console.log(`Seed word "${word}" has dominant shape: ${shape.dominantShape}`);
    });
  }
  
  /**
   * Private: Analyze the shape of a word
   */
  _analyzeWordShape(word) {
    // Skip if already analyzed
    if (this.wordShapeMap[word]) {
      return this.wordShapeMap[word];
    }
    
    // Count shape types in the word
    const shapes = {
      curved: 0,
      angled: 0,
      linear: 0,
      mixed: 0
    };
    
    // Analyze each letter
    for (let i = 0; i < word.length; i++) {
      const letter = word[i].toLowerCase();
      
      if (LetterShapes.curved.includes(letter)) {
        shapes.curved++;
      } else if (LetterShapes.angled.includes(letter)) {
        shapes.angled++;
      } else if (LetterShapes.linear.includes(letter)) {
        shapes.linear++;
      } else if (LetterShapes.mixed.includes(letter)) {
        shapes.mixed++;
      }
    }
    
    // Determine dominant shape
    let dominantShape = "balanced";
    let maxCount = 0;
    
    for (const shape in shapes) {
      if (shapes[shape] > maxCount) {
        maxCount = shapes[shape];
        dominantShape = shape;
      }
    }
    
    // Create shape analysis
    const shapeAnalysis = {
      word: word,
      shapes: shapes,
      dominantShape: dominantShape,
      intensity: maxCount / word.length, // How strongly it shows the shape
      specialPattern: this._checkSpecialPattern(word)
    };
    
    // Store in shape map
    this.wordShapeMap[word] = shapeAnalysis;
    
    return shapeAnalysis;
  }
  
  /**
   * Private: Check for special patterns in word
   */
  _checkSpecialPattern(word) {
    // Check for repeated letters
    const repeatedLetters = word.match(/(.)\1+/g);
    
    // Check for palindrome
    const isPalindrome = word === word.split('').reverse().join('');
    
    // Check for visual symmetry
    const isSymmetrical = this._checkVisualSymmetry(word);
    
    return {
      repeatedLetters: repeatedLetters ? repeatedLetters.join(',') : null,
      palindrome: isPalindrome,
      symmetrical: isSymmetrical,
      allCaps: word === word.toUpperCase(),
      hasSpecial: word.match(/[^a-zA-Z0-9\s]/) !== null
    };
  }
  
  /**
   * Private: Check if a word has visual symmetry
   */
  _checkVisualSymmetry(word) {
    // Simple approximation of visual symmetry
    // In a real implementation, this would be more sophisticated
    
    const symmetricalPairs = [
      ['b', 'd'], ['p', 'q'], ['n', 'u'], ['m', 'w'],
      ['/', '\\'], ['(', ')'], ['[', ']'], ['{', '}'],
      ['<', '>']
    ];
    
    const letters = word.split('');
    const length = letters.length;
    
    // Even length words are easier to check for symmetry
    if (length % 2 === 0) {
      for (let i = 0; i < length / 2; i++) {
        const firstChar = letters[i];
        const lastChar = letters[length - 1 - i];
        
        // Check if they're a symmetrical pair
        const isPair = symmetricalPairs.some(pair => 
          (pair[0] === firstChar && pair[1] === lastChar) ||
          (pair[1] === firstChar && pair[0] === lastChar)
        );
        
        if (!isPair && firstChar !== lastChar) {
          return false;
        }
      }
      return true;
    }
    
    // Odd length words need a center character
    return false;
  }
  
  /**
   * Private: Analyze shapes of multiple words
   */
  _analyzeWordShapes(words) {
    const shapes = [];
    
    words.forEach(word => {
      shapes.push(this._analyzeWordShape(word));
    });
    
    return shapes;
  }
  
  /**
   * Private: Create a new turn
   */
  _createNewTurn() {
    if (!this.currentStory) return;
    
    // Create turn record
    const turn = {
      index: this.turnIndex,
      stage: this.currentStage,
      words: [],
      wordCount: 0,
      startTime: new Date(),
      completed: false,
      shapes: {}
    };
    
    // Add to story
    this.currentStory.turns.push(turn);
  }
  
  /**
   * Private: Add words to current turn
   */
  _addWordsToTurn(words) {
    if (!this.currentStory || !this.currentStory.turns[this.turnIndex]) {
      return;
    }
    
    // Get current turn
    const turn = this.currentStory.turns[this.turnIndex];
    
    // Add words
    words.forEach(word => {
      turn.words.push(word);
      turn.wordCount++;
      
      // Analyze and track shape
      const shape = this._analyzeWordShape(word);
      turn.shapes[shape.dominantShape] = (turn.shapes[shape.dominantShape] || 0) + 1;
    });
    
    // Check if turn is complete
    if (turn.wordCount >= this.turnLength) {
      this.completeTurn();
    }
  }
  
  /**
   * Private: Select bracet type based on current stage
   */
  _selectBracetType() {
    // Different bracet types are appropriate for different stages
    const stageBracets = {
      "GENESIS": "standard",
      "TENSION": "angle",
      "REVELATION": "curly",
      "INTEGRATION": "standard",
      "RESOLUTION": "curly",
      "ECHO": "standard",
      "RECURSION": "special",
      "TRANSCENDENCE": "quantum"
    };
    
    // Use the appropriate bracet or default to standard
    return stageBracets[this.currentStage] || "standard";
  }
  
  /**
   * Private: Process content with existing bracets
   */
  _processBracetedContent(content) {
    // Track the bracet stack
    const bracetStack = [];
    let processedContent = '';
    
    // Process each character
    for (let i = 0; i < content.length; i++) {
      const char = content[i];
      
      // Check for opening bracets
      if (['[', '{', '<', '('].includes(char)) {
        bracetStack.push(char);
        processedContent += char;
      } 
      // Check for closing bracets
      else if ([']', '}', '>', ')'].includes(char)) {
        // Match with last opening bracet
        if (bracetStack.length > 0) {
          const lastBracet = bracetStack.pop();
          
          // Verify matching bracet
          const isMatching = 
            (lastBracet === '[' && char === ']') ||
            (lastBracet === '{' && char === '}') ||
            (lastBracet === '<' && char === '>') ||
            (lastBracet === '(' && char === ')');
          
          if (isMatching) {
            processedContent += char;
          } else {
            // Mismatched bracet, add error marker
            processedContent += '!' + char;
          }
        } else {
          // Closing bracet without opening
          processedContent += '!' + char;
        }
      } else {
        processedContent += char;
      }
    }
    
    // Add missing closing bracets
    while (bracetStack.length > 0) {
      const openBracet = bracetStack.pop();
      let closingBracet = '';
      
      switch (openBracet) {
        case '[': closingBracet = ']'; break;
        case '{': closingBracet = '}'; break;
        case '<': closingBracet = '>'; break;
        case '(': closingBracet = ')'; break;
      }
      
      processedContent += '!' + closingBracet;
    }
    
    return processedContent;
  }
  
  /**
   * Private: Analyze shapes across the story
   */
  _analyzeStoryShapes() {
    const shapeCounts = {
      curved: 0,
      angled: 0,
      linear: 0,
      mixed: 0,
      balanced: 0
    };
    
    let totalWords = 0;
    
    // Count shapes across all words
    this.currentStory.segments.forEach(segment => {
      segment.words.forEach(word => {
        const shape = this._analyzeWordShape(word);
        shapeCounts[shape.dominantShape]++;
        totalWords++;
      });
    });
    
    // Convert to proportions
    const shapeDistribution = {};
    for (const shape in shapeCounts) {
      shapeDistribution[shape] = totalWords > 0 ? 
        shapeCounts[shape] / totalWords : 0;
    }
    
    return shapeDistribution;
  }
  
  /**
   * Private: Generate a summary of the story
   */
  _generateStorySummary() {
    if (!this.currentStory) return null;
    
    // Get word frequency
    const wordFrequency = {};
    let totalWords = 0;
    
    this.currentStory.segments.forEach(segment => {
      segment.words.forEach(word => {
        wordFrequency[word] = (wordFrequency[word] || 0) + 1;
        totalWords++;
      });
    });
    
    // Sort words by frequency
    const sortedWords = Object.keys(wordFrequency).sort((a, b) => 
      wordFrequency[b] - wordFrequency[a]
    );
    
    // Get top words
    const topWords = sortedWords.slice(0, 10).map(word => ({
      word: word,
      count: wordFrequency[word],
      percentage: Math.round((wordFrequency[word] / totalWords) * 100),
      isSeed: this.currentStory.seedWords.includes(word)
    }));
    
    // Get shape distribution
    const shapeDistribution = this._analyzeStoryShapes();
    
    // Generate summary
    return {
      title: this.currentStory.title,
      wordCount: totalWords,
      turnCount: this.currentStory.turns.length,
      segmentCount: this.currentStory.segments.length,
      topWords: topWords,
      shapeDistribution: shapeDistribution,
      seedWords: this.currentStory.seedWords,
      stages: this.currentStory.turns.map(turn => turn.stage).filter((v, i, a) => a.indexOf(v) === i)
    };
  }
  
  /**
   * Private: Generate ASCII visualization of story
   */
  _generateAsciiVisualization() {
    if (!this.currentStory) return "";
    
    let visualization = `=== ${this.currentStory.title} ===\n\n`;
    
    // Add turn structure
    this.currentStory.turns.forEach((turn, index) => {
      visualization += `Turn ${index} [${turn.stage}]:\n`;
      
      // Show word count
      visualization += `Words: ${turn.wordCount} | `;
      
      // Show shape distribution
      let shapes = "";
      for (const shape in turn.shapes) {
        shapes += `${shape}: ${turn.shapes[shape]} `;
      }
      visualization += `Shapes: ${shapes}\n`;
      
      // Add a simple graph
      const maxShape = Object.keys(turn.shapes).reduce((a, b) => 
        turn.shapes[a] > turn.shapes[b] ? a : b, Object.keys(turn.shapes)[0]);
      
      let graphLine = "";
      for (let i = 0; i < turn.wordCount; i++) {
        if (i % 5 === 0) {
          graphLine += "|";
        } else {
          graphLine += "-";
        }
      }
      visualization += graphLine + "\n\n";
    });
    
    // Add bracet structure
    visualization += "Bracets:\n";
    this.currentStory.bracets.forEach(bracet => {
      const openTime = new Date(bracet.openTime);
      const closeTime = bracet.closeTime ? new Date(bracet.closeTime) : null;
      
      visualization += `[${bracet.type}] ${openTime.toLocaleTimeString()}`;
      if (closeTime) {
        visualization += ` → ${closeTime.toLocaleTimeString()}`;
      } else {
        visualization += " → (unclosed)";
      }
      visualization += `\n`;
    });
    
    return visualization;
  }
  
  /**
   * Private: Generate HTML visualization
   */
  _generateHtmlVisualization() {
    if (!this.currentStory) return "";
    
    let html = `<div class="story-visualization">`;
    html += `<h2>${this.currentStory.title}</h2>`;
    
    // Add turn structure
    html += `<div class="turn-structure">`;
    this.currentStory.turns.forEach((turn, index) => {
      html += `<div class="turn" data-stage="${turn.stage}">`;
      html += `<h3>Turn ${index} - ${turn.stage}</h3>`;
      
      // Add shape distribution
      html += `<div class="shape-distribution">`;
      for (const shape in turn.shapes) {
        const percentage = Math.round((turn.shapes[shape] / turn.wordCount) * 100);
        html += `<div class="shape-bar ${shape}" style="width: ${percentage}%">`;
        html += `${shape}: ${turn.shapes[shape]}`;
        html += `</div>`;
      }
      html += `</div>`;
      
      html += `</div>`;
    });
    html += `</div>`;
    
    // Add word cloud
    html += `<div class="word-cloud">`;
    const wordFrequency = {};
    
    this.currentStory.segments.forEach(segment => {
      segment.words.forEach(word => {
        wordFrequency[word] = (wordFrequency[word] || 0) + 1;
      });
    });
    
    for (const word in wordFrequency) {
      const size = 1 + (wordFrequency[word] / 2);
      const shape = this._analyzeWordShape(word);
      const isSeed = this.currentStory.seedWords.includes(word);
      
      html += `<span class="word ${shape.dominantShape} ${isSeed ? 'seed' : ''}" 
              style="font-size: ${size}em">
              ${word}
            </span>`;
    }
    html += `</div>`;
    
    // Add style
    html += `<style>
      .story-visualization {
        font-family: Arial, sans-serif;
        max-width: 800px;
        margin: 0 auto;
      }
      .turn { 
        margin-bottom: 20px;
        padding: 10px;
        border-radius: 5px;
      }
      .turn[data-stage="GENESIS"] { background-color: #f0f8ff; }
      .turn[data-stage="TENSION"] { background-color: #fff0f0; }
      .turn[data-stage="REVELATION"] { background-color: #f0fff0; }
      .turn[data-stage="INTEGRATION"] { background-color: #f8f0ff; }
      .turn[data-stage="RESOLUTION"] { background-color: #fffff0; }
      .turn[data-stage="ECHO"] { background-color: #f0ffff; }
      .turn[data-stage="RECURSION"] { background-color: #fff8f0; }
      .turn[data-stage="TRANSCENDENCE"] { background-color: #f0f0ff; }
      
      .shape-distribution {
        display: flex;
        height: 30px;
        margin-top: 10px;
      }
      .shape-bar {
        display: flex;
        justify-content: center;
        align-items: center;
        color: white;
        font-size: 0.8em;
      }
      .shape-bar.curved { background-color: #4682B4; }
      .shape-bar.angled { background-color: #DC143C; }
      .shape-bar.linear { background-color: #2E8B57; }
      .shape-bar.mixed { background-color: #9932CC; }
      .shape-bar.balanced { background-color: #DAA520; }
      
      .word-cloud {
        margin-top: 30px;
        padding: 20px;
        text-align: center;
        background-color: #f8f8f8;
        border-radius: 5px;
      }
      .word {
        display: inline-block;
        margin: 5px;
        padding: 3px;
      }
      .word.curved { color: #4682B4; }
      .word.angled { color: #DC143C; }
      .word.linear { color: #2E8B57; }
      .word.mixed { color: #9932CC; }
      .word.balanced { color: #DAA520; }
      .word.seed { font-weight: bold; text-decoration: underline; }
    </style>`;
    
    html += `</div>`;
    
    return html;
  }
  
  /**
   * Private: Generate terminal visualization
   */
  _generateTerminalVisualization() {
    if (!this.currentStory) return "";
    
    // Colors for terminal
    const colors = {
      reset: "\x1b[0m",
      bright: "\x1b[1m",
      dim: "\x1b[2m",
      underscore: "\x1b[4m",
      red: "\x1b[31m",
      green: "\x1b[32m",
      yellow: "\x1b[33m",
      blue: "\x1b[34m",
      magenta: "\x1b[35m",
      cyan: "\x1b[36m",
      white: "\x1b[37m"
    };
    
    // Stage colors
    const stageColors = {
      "GENESIS": colors.blue,
      "TENSION": colors.red,
      "REVELATION": colors.yellow,
      "INTEGRATION": colors.green,
      "RESOLUTION": colors.cyan,
      "ECHO": colors.magenta,
      "RECURSION": colors.yellow,
      "TRANSCENDENCE": colors.white
    };
    
    // Create visualization
    let output = "";
    
    // Header
    output += `${colors.bright}${colors.cyan}=== ${this.currentStory.title} ===${colors.reset}\n\n`;
    
    // Turn structure
    this.currentStory.turns.forEach((turn, index) => {
      const stageColor = stageColors[turn.stage] || colors.white;
      
      output += `${colors.bright}Turn ${index}${colors.reset}: `;
      output += `${stageColor}[${turn.stage}]${colors.reset}\n`;
      
      // Word count
      output += `Words: ${turn.wordCount} | `;
      
      // Shape distribution
      for (const shape in turn.shapes) {
        let shapeColor;
        switch (shape) {
          case "curved": shapeColor = colors.blue; break;
          case "angled": shapeColor = colors.red; break;
          case "linear": shapeColor = colors.green; break;
          case "mixed": shapeColor = colors.magenta; break;
          case "balanced": shapeColor = colors.yellow; break;
          default: shapeColor = colors.white;
        }
        
        output += `${shapeColor}${shape}: ${turn.shapes[shape]}${colors.reset} `;
      }
      output += "\n";
      
      // Create a visual bar
      const totalWidth = 50;
      let bar = "";
      
      for (const shape in turn.shapes) {
        const width = Math.ceil((turn.shapes[shape] / turn.wordCount) * totalWidth);
        let shapeChar;
        
        switch (shape) {
          case "curved": shapeChar = "~"; break;
          case "angled": shapeChar = "^"; break;
          case "linear": shapeChar = "-"; break;
          case "mixed": shapeChar = "+"; break;
          case "balanced": shapeChar = "="; break;
          default: shapeChar = ".";
        }
        
        bar += shapeChar.repeat(width);
      }
      
      // Trim if too long
      if (bar.length > totalWidth) {
        bar = bar.substring(0, totalWidth);
      }
      
      // Pad if too short
      while (bar.length < totalWidth) {
        bar += " ";
      }
      
      output += `[${bar}]\n\n`;
    });
    
    // Word shapes
    output += `${colors.bright}${colors.yellow}Word Shapes:${colors.reset}\n`;
    
    // Group words by shape
    const wordsByShape = {
      curved: [],
      angled: [],
      linear: [],
      mixed: [],
      balanced: []
    };
    
    // Collect unique words
    const uniqueWords = new Set();
    this.currentStory.segments.forEach(segment => {
      segment.words.forEach(word => {
        uniqueWords.add(word);
      });
    });
    
    // Group by shape
    Array.from(uniqueWords).forEach(word => {
      const shape = this._analyzeWordShape(word);
      wordsByShape[shape.dominantShape].push(word);
    });
    
    // Display words by shape
    for (const shape in wordsByShape) {
      if (wordsByShape[shape].length > 0) {
        let shapeColor;
        switch (shape) {
          case "curved": shapeColor = colors.blue; break;
          case "angled": shapeColor = colors.red; break;
          case "linear": shapeColor = colors.green; break;
          case "mixed": shapeColor = colors.magenta; break;
          case "balanced": shapeColor = colors.yellow; break;
          default: shapeColor = colors.white;
        }
        
        output += `${shapeColor}${shape}: ${colors.reset}`;
        
        // Show some words (limit to avoid overload)
        const displayedWords = wordsByShape[shape].slice(0, 8);
        displayedWords.forEach((word, i) => {
          const isSeed = this.currentStory.seedWords.includes(word);
          if (isSeed) {
            output += `${colors.bright}${word}${colors.reset}`;
          } else {
            output += word;
          }
          
          if (i < displayedWords.length - 1) {
            output += ", ";
          }
        });
        
        // Indicate if there are more
        if (wordsByShape[shape].length > displayedWords.length) {
          output += `, ${colors.dim}... (${wordsByShape[shape].length - displayedWords.length} more)${colors.reset}`;
        }
        
        output += "\n";
      }
    }
    
    // Special pizza analysis
    if (uniqueWords.has("pizza")) {
      output += `\n${colors.bright}${colors.yellow}Special Word Analysis: pizza${colors.reset}\n`;
      output += `${colors.cyan}p${colors.reset}${colors.magenta}i${colors.reset}${colors.red}z${colors.reset}${colors.red}z${colors.reset}${colors.blue}a${colors.reset}\n`;
      output += `${colors.dim}The word "pizza" has a slight curve in its terminal rendering${colors.reset}\n`;
      output += `${colors.dim}The 'p' descends, the 'i' rises, the 'zz' zigzags, the 'a' curves${colors.reset}\n`;
    }
    
    return output;
  }
  
  /**
   * Private: Get color for a stage
   */
  _getStageColor(stage) {
    const stageColors = {
      "GENESIS": "#4682B4", // Steel Blue
      "TENSION": "#DC143C", // Crimson
      "REVELATION": "#FFD700", // Gold
      "INTEGRATION": "#2E8B57", // Sea Green
      "RESOLUTION": "#20B2AA", // Light Sea Green
      "ECHO": "#9370DB", // Medium Purple
      "RECURSION": "#DAA520", // Goldenrod
      "TRANSCENDENCE": "#E6E6FA" // Lavender
    };
    
    return stageColors[stage] || "#FFFFFF";
  }
  
  /**
   * Private: Get color for a word based on its shape
   */
  _getWordColor(word, shape) {
    const isSeedWord = this.currentStory && 
                      this.currentStory.seedWords && 
                      this.currentStory.seedWords.includes(word);
    
    if (isSeedWord) {
      return "#FFD700"; // Gold for seed words
    }
    
    const shapeColors = {
      "curved": "#4682B4", // Steel Blue
      "angled": "#DC143C", // Crimson
      "linear": "#2E8B57", // Sea Green
      "mixed": "#9932CC", // Dark Orchid
      "balanced": "#DAA520" // Goldenrod
    };
    
    return shapeColors[shape] || "#FFFFFF";
  }
  
  /**
   * Private: Get color for a bracet type
   */
  _getBracetColor(type) {
    const bracetColors = {
      "standard": "#4682B4", // Steel Blue
      "curly": "#9932CC", // Dark Orchid
      "angle": "#DC143C", // Crimson
      "special": "#FFD700", // Gold
      "quantum": "#20B2AA" // Light Sea Green
    };
    
    return bracetColors[type] || "#FFFFFF";
  }
  
  /**
   * Private: Get color for a connection between words
   */
  _getConnectionColor(word1, word2) {
    const shape1 = this._getWordShapeProperties(word1);
    const shape2 = this._getWordShapeProperties(word2);
    
    // Same shape type
    if (shape1.dominantShape === shape2.dominantShape) {
      return this._getWordColor("", shape1.dominantShape);
    }
    
    // Different shapes - use a neutral color
    return "#AAAAAA";
  }
  
  /**
   * Private: Get word shape properties
   */
  _getWordShapeProperties(word) {
    return this._analyzeWordShape(word);
  }
  
  /**
   * Private: Generate words with specific shapes
   */
  _generateWordsWithShapes(shapes, count) {
    // In a real implementation, this would use a more advanced algorithm
    // Here we'll just use some predefined words with those shapes
    
    const wordsByShape = {
      "curved": ["ocean", "circle", "moon", "bubble", "oracle", "cosmic", "carousel"],
      "angled": ["zigzag", "apex", "vertex", "wedge", "axe", "vector", "arrow"],
      "linear": ["line", "tall", "timber", "direct", "path", "trail", "bridge"],
      "mixed": ["hybrid", "blend", "fusion", "mixture", "combine", "diverse", "varied"],
      "balanced": ["balance", "harmony", "center", "middle", "poise", "stable", "neutral"]
    };
    
    // Collect words from requested shapes
    const selectedWords = [];
    
    shapes.forEach(shape => {
      if (wordsByShape[shape]) {
        selectedWords.push(...wordsByShape[shape]);
      }
    });
    
    // If we have enough words, shuffle and pick
    if (selectedWords.length >= count) {
      // Simple shuffle
      for (let i = selectedWords.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [selectedWords[i], selectedWords[j]] = [selectedWords[j], selectedWords[i]];
      }
      
      return selectedWords.slice(0, count);
    }
    
    // If not enough words, add some from other shapes
    while (selectedWords.length < count) {
      // Pick a random shape
      const allShapes = Object.keys(wordsByShape);
      const randomShape = allShapes[Math.floor(Math.random() * allShapes.length)];
      
      // Pick a random word from that shape
      const words = wordsByShape[randomShape];
      const randomWord = words[Math.floor(Math.random() * words.length)];
      
      // Add if not already included
      if (!selectedWords.includes(randomWord)) {
        selectedWords.push(randomWord);
      }
    }
    
    return selectedWords;
  }
  
  /**
   * Private: Generate content with specific shapes
   */
  _generateShapedContent(theme, shapes, wordCount) {
    // Build a word pool based on shape
    const wordPool = this._generateWordsWithShapes(shapes, 20);
    
    // Add some theme-related words
    const themeWords = theme.split(/\s+/);
    wordPool.push(...themeWords);
    
    // Add some common words
    const commonWords = ['the', 'and', 'of', 'in', 'with', 'as', 'to', 'through', 'beyond'];
    
    // Generate content
    let content = '';
    
    for (let i = 0; i < wordCount; i++) {
      // 70% chance of word from pool, 30% chance of common word
      if (Math.random() < 0.7) {
        const word = wordPool[Math.floor(Math.random() * wordPool.length)];
        content += word;
      } else {
        const word = commonWords[Math.floor(Math.random() * commonWords.length)];
        content += word;
      }
      
      // Add space if not last word
      if (i < wordCount - 1) {
        content += ' ';
      }
    }
    
    return content;
  }
}

// Export for Node.js environments
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    ShapePatterns,
    LetterShapes,
    TurnStages,
    StoryWeaver
  };
}

// If in browser context, attach to window
if (typeof window !== 'undefined') {
  window.ShapePatterns = ShapePatterns;
  window.LetterShapes = LetterShapes;
  window.TurnStages = TurnStages;
  window.StoryWeaver = StoryWeaver;
}

/**
 * Usage example:
 * 
 * // Create story weaver
 * const weaver = new StoryWeaver();
 * 
 * // Begin a new story with seed words
 * weaver.beginStory("Curved Dimensions", ["circle", "ocean", "spiral", "journey"]);
 * 
 * // Add content
 * weaver.addMessageToStory("The circular path winds through oceanic depths, spiraling outward on a journey of discovery.");
 * 
 * // Complete a turn
 * weaver.completeTurn();
 * 
 * // Add more content
 * weaver.addMessageToStory("Sharp angles interrupt the smooth curves, creating tension within the flowing narrative.");
 * 
 * // Repair story
 * weaver.repairStory();
 * 
 * // Visualize the story shapes
 * const visualization = weaver.visualizeStoryShapes("terminal");
 * console.log(visualization);
 * 
 * // Complete the story
 * weaver.completeStory();
 * 
 * // Special analysis of pizza shape
 * const pizzaAnalysis = weaver.analyzePizzaShape();
 * console.log(pizzaAnalysis);
 */