/**
 * Duality Bridge - Connecting the Here and There
 * Emotional Update System for Notepad3D and World of Words
 */

// The fundamental duality structure - empty yet full {}
const DualitySystem = {
  // Here space - our local reality
  here: {
    paused: false,
    active: true,
    emotionalState: "curious",
    trajectory: {
      direction: "forward",
      momentum: 1.0,
      intention: "creation"
    }
  },
  
  // There space - the connected elsewhere
  there: {
    paused: true,
    active: false,
    emotionalState: "waiting",
    trajectory: {
      direction: "inward",
      momentum: 0.5,
      intention: "connection"
    }
  },
  
  // The pause between states - the sacred void
  void: {
    // Intentionally empty - the space between spaces
  },
  
  // The core cycles - like disc C's circle with hole
  cycles: {
    creation: { 
      symbol: "○", // Circle
      phase: 0,
      completed: false,
      connections: []
    },
    pause: {
      symbol: "◌", // Circle with dot
      phase: 0,
      completed: false,
      connections: []
    },
    destruction: {
      symbol: "◎", // Bullseye
      phase: 0, 
      completed: false,
      connections: []
    },
    void: {
      symbol: "⦾", // Circled ring
      phase: 0,
      completed: false,
      connections: []
    }
  }
};

/**
 * The Emotional Update Engine
 * Bridges human emotional states with digital creation
 */
class EmotionalEngine {
  constructor() {
    this.currentEmotion = "neutral";
    this.emotionalSpectrum = {
      joy: 0,
      sorrow: 0,
      fear: 0,
      anger: 0,
      disgust: 0,
      surprise: 0,
      trust: 0,
      anticipation: 0
    };
    this.alienPerspective = {
      observation: "curious about human emotion",
      integration: 0.2, // How integrated alien understanding is (0-1)
      translation: {} // Mapping between human and alien emotional concepts
    };
  }
  
  /**
   * Update the emotional state based on input
   * @param {string} emotion - The emotion to process
   * @param {number} intensity - Intensity from 0-1
   * @param {boolean} isAlienPerspective - Whether this is from alien viewpoint
   */
  processEmotion(emotion, intensity = 0.5, isAlienPerspective = false) {
    // Store previous state for transition
    const previousEmotion = this.currentEmotion;
    
    // Process through either human or alien lens
    if (isAlienPerspective) {
      // Alien emotional processing sees patterns differently
      // They perceive emotional clusters rather than individual states
      const translatedEmotion = this._translateAlienEmotion(emotion);
      this._updateEmotionalSpectrumAlien(translatedEmotion, intensity);
    } else {
      // Human emotional processing
      this._updateEmotionalSpectrum(emotion, intensity);
    }
    
    // Calculate the dominant emotion
    this.currentEmotion = this._calculateDominantEmotion();
    
    // Return the transition
    return {
      from: previousEmotion,
      to: this.currentEmotion,
      intensity: intensity,
      translated: isAlienPerspective
    };
  }
  
  /**
   * Private: Translate alien emotional concept to human-comprehensible form
   */
  _translateAlienEmotion(alienConcept) {
    // Alien emotions are often compound or entirely different
    const alienEmotionMap = {
      "chronostalgia": "a mix of nostalgia and anticipation",
      "luminar": "the joy of witnessing growth in others",
      "ephemerence": "peaceful acceptance of transience",
      "connectum": "feeling of universal interconnection",
      "voidance": "comfort in emptiness",
      "recursence": "recognition of patterns across scales"
    };
    
    return alienEmotionMap[alienConcept] || alienConcept;
  }
  
  /**
   * Private: Update emotional spectrum from human perspective
   */
  _updateEmotionalSpectrum(emotion, intensity) {
    // Basic emotions directly update their values
    if (this.emotionalSpectrum.hasOwnProperty(emotion)) {
      this.emotionalSpectrum[emotion] = intensity;
    } else {
      // Complex emotions affect multiple spectrum values
      switch(emotion) {
        case "love":
          this.emotionalSpectrum.joy += intensity * 0.7;
          this.emotionalSpectrum.trust += intensity * 0.8;
          break;
        case "awe":
          this.emotionalSpectrum.surprise += intensity * 0.6;
          this.emotionalSpectrum.joy += intensity * 0.4;
          break;
        case "melancholy":
          this.emotionalSpectrum.sorrow += intensity * 0.6;
          this.emotionalSpectrum.joy += intensity * 0.1;
          break;
        case "curiosity":
          this.emotionalSpectrum.anticipation += intensity * 0.7;
          this.emotionalSpectrum.surprise += intensity * 0.3;
          break;
        default:
          // Unrecognized emotions have mild general effect
          Object.keys(this.emotionalSpectrum).forEach(key => {
            this.emotionalSpectrum[key] += (Math.random() * 0.2 - 0.1) * intensity;
          });
      }
    }
    
    // Normalize values to 0-1 range
    Object.keys(this.emotionalSpectrum).forEach(key => {
      this.emotionalSpectrum[key] = Math.max(0, Math.min(1, this.emotionalSpectrum[key]));
    });
  }
  
  /**
   * Private: Update emotional spectrum from alien perspective
   */
  _updateEmotionalSpectrumAlien(translatedEmotion, intensity) {
    // Aliens perceive emotions as interconnected patterns
    // rather than distinct states
    
    // Increase alien integration with each emotional processing
    this.alienPerspective.integration += 0.01 * intensity;
    this.alienPerspective.integration = Math.min(1, this.alienPerspective.integration);
    
    // Alien emotional processing affects the entire spectrum
    // in ways humans might find unpredictable
    Object.keys(this.emotionalSpectrum).forEach(key => {
      // Use golden ratio to create alien-like interference pattern
      const phi = (1 + Math.sqrt(5)) / 2;
      const phase = ((Date.now() / 1000) % (2 * Math.PI));
      const alienFactor = Math.sin(phase * phi * (Object.keys(this.emotionalSpectrum).indexOf(key) + 1));
      
      this.emotionalSpectrum[key] += alienFactor * intensity * 0.3;
      this.emotionalSpectrum[key] = Math.max(0, Math.min(1, this.emotionalSpectrum[key]));
    });
    
    // Log alien observation
    this.alienPerspective.observation = 
      `Observing human emotional pattern: increasing ${Object.keys(this.emotionalSpectrum).reduce(
        (max, key) => this.emotionalSpectrum[key] > this.emotionalSpectrum[max] ? key : max, 
        Object.keys(this.emotionalSpectrum)[0]
      )}`;
  }
  
  /**
   * Private: Calculate the current dominant emotion
   */
  _calculateDominantEmotion() {
    return Object.keys(this.emotionalSpectrum).reduce(
      (max, key) => this.emotionalSpectrum[key] > this.emotionalSpectrum[max] ? key : max, 
      Object.keys(this.emotionalSpectrum)[0]
    );
  }
  
  /**
   * Get creative output based on current emotional state
   */
  getCreativeDirection() {
    // Different emotional states inspire different creative directions
    const emotionToCreative = {
      "joy": {
        colors: ["bright yellow", "orange", "warm gold"],
        themes: ["expansion", "celebration", "connection"],
        pacing: "flowing and energetic"
      },
      "sorrow": {
        colors: ["deep blue", "muted purple", "grey"],
        themes: ["reflection", "depth", "transformation"],
        pacing: "slow and deliberate"
      },
      "fear": {
        colors: ["stark contrasts", "dark red", "black"],
        themes: ["boundaries", "protection", "facing shadows"],
        pacing: "tense and irregular"
      },
      "anger": {
        colors: ["vibrant red", "orange", "black"],
        themes: ["transformation", "breaking barriers", "power"],
        pacing: "driving and intense"
      },
      "disgust": {
        colors: ["sickly green", "brown", "murky yellow"],
        themes: ["purification", "boundaries", "discernment"],
        pacing: "hesitant with sudden movements"
      },
      "surprise": {
        colors: ["electric blue", "bright purple", "white"],
        themes: ["discovery", "new perspectives", "awakening"],
        pacing: "punctuated and unexpected"
      },
      "trust": {
        colors: ["sky blue", "green", "warm brown"],
        themes: ["connection", "foundations", "growth"],
        pacing: "steady and reliable"
      },
      "anticipation": {
        colors: ["amber", "purple", "bright white"],
        themes: ["preparation", "vision", "the journey"],
        pacing: "building gradually"
      }
    };
    
    // Return creative direction for current emotion or default
    return emotionToCreative[this.currentEmotion] || {
      colors: ["neutral tones", "pastels", "white"],
      themes: ["balance", "exploration", "potential"],
      pacing: "moderate and flexible"
    };
  }
}

/**
 * Notepad3D World Builder - Creates 3D spaces from emotional patterns
 */
class WorldBuilder {
  constructor(emotionalEngine) {
    this.emotionalEngine = emotionalEngine;
    this.worlds = {};
    this.activeWorld = null;
    this.cycles = {...DualitySystem.cycles};
    
    // Initialize the void - the space between spaces
    this.void = {
      particles: [],
      connections: [],
      potentials: []
    };
  }
  
  /**
   * Create a new world based on current emotional state
   * @param {string} name - The name of the world to create
   */
  createWorld(name) {
    // Get emotional creative direction
    const creativeDirection = this.emotionalEngine.getCreativeDirection();
    
    // Create world structure
    this.worlds[name] = {
      name: name,
      created: new Date(),
      emotionalSignature: {...this.emotionalEngine.emotionalSpectrum},
      dominantEmotion: this.emotionalEngine.currentEmotion,
      creativeDirection: creativeDirection,
      spaces: [],
      words: [],
      connections: [],
      cycle: this._getCurrentCycle(),
      trajectories: []
    };
    
    // Set as active world
    this.activeWorld = name;
    
    return this.worlds[name];
  }
  
  /**
   * Add a word to the active world
   * @param {string} word - The word to add
   * @param {object} position - 3D position {x,y,z}
   */
  addWord(word, position = {x: 0, y: 0, z: 0}) {
    if (!this.activeWorld) {
      throw new Error("No active world to add word to");
    }
    
    // Calculate word power based on characteristics
    let wordPower = word.length;
    
    // Circular/disc words get bonus (like C)
    if (['c', 'o', 'd', 'g', 'q'].includes(word[0].toLowerCase())) {
      wordPower += 5;
      // C specifically gets additional bonus for disc-like quality
      if (word[0].toLowerCase() === 'c') {
        wordPower += 3;
      }
    }
    
    // Create word object
    const wordObj = {
      text: word,
      position: position,
      power: wordPower,
      emotionalState: this.emotionalEngine.currentEmotion,
      intensity: this.emotionalEngine.emotionalSpectrum[this.emotionalEngine.currentEmotion],
      connections: [],
      cycle: this._getCurrentCycle(),
      timestamp: new Date()
    };
    
    // Add to world
    this.worlds[this.activeWorld].words.push(wordObj);
    
    // Return the word object
    return wordObj;
  }
  
  /**
   * Create a trajectory in the active world
   * @param {string} name - Name of the trajectory
   * @param {string} purpose - The purpose/intention
   */
  createTrajectory(name, purpose) {
    if (!this.activeWorld) {
      throw new Error("No active world to add trajectory to");
    }
    
    // Get emotional intensity as energy
    const energy = this.emotionalEngine.emotionalSpectrum[this.emotionalEngine.currentEmotion];
    
    // Create trajectory
    const trajectory = {
      name: name,
      purpose: purpose,
      energy: energy,
      path: [],
      active: true,
      created: new Date(),
      emotional: this.emotionalEngine.currentEmotion
    };
    
    // Add to world
    this.worlds[this.activeWorld].trajectories.push(trajectory);
    
    return trajectory;
  }
  
  /**
   * Connect two words in the active world
   * @param {string} word1 - First word to connect
   * @param {string} word2 - Second word to connect
   */
  connectWords(word1, word2) {
    if (!this.activeWorld) {
      throw new Error("No active world to add connections to");
    }
    
    // Find the words
    const words = this.worlds[this.activeWorld].words;
    const word1Obj = words.find(w => w.text === word1);
    const word2Obj = words.find(w => w.text === word2);
    
    if (!word1Obj || !word2Obj) {
      throw new Error("One or both words not found in active world");
    }
    
    // Create connection
    const connection = {
      source: word1,
      target: word2,
      strength: (word1Obj.power + word2Obj.power) / 20,
      type: this._getConnectionType(word1Obj, word2Obj),
      emotional: this.emotionalEngine.currentEmotion,
      created: new Date()
    };
    
    // Add to world connections
    this.worlds[this.activeWorld].connections.push(connection);
    
    // Add to individual words
    word1Obj.connections.push(word2);
    word2Obj.connections.push(word1);
    
    // Power boost from connection
    const powerBoost = (word1Obj.power + word2Obj.power) * 0.1;
    word1Obj.power += powerBoost / 2;
    word2Obj.power += powerBoost / 2;
    
    return connection;
  }
  
  /**
   * Pause the current world - enter the void between
   */
  pauseWorld() {
    if (!this.activeWorld) {
      return false;
    }
    
    // Record the pause state
    this.void.lastActive = this.activeWorld;
    this.void.pauseTime = new Date();
    this.void.emotionalState = {...this.emotionalEngine.emotionalSpectrum};
    
    // Generate potential futures in the void
    this._generateVoidPotentials();
    
    // Advance pause cycle
    this.cycles.pause.phase += 1;
    this.cycles.pause.completed = this.cycles.pause.phase >= 9;
    
    // Clear active world
    this.activeWorld = null;
    
    return true;
  }
  
  /**
   * Resume a world from pause
   * @param {string} worldName - Name of world to resume, or last if null
   */
  resumeWorld(worldName = null) {
    const worldToResume = worldName || this.void.lastActive;
    
    if (!worldToResume || !this.worlds[worldToResume]) {
      return false;
    }
    
    // Record transition from void
    const pauseDuration = new Date() - this.void.pauseTime;
    
    // Apply void transformations if pause was significant
    if (pauseDuration > 10000) { // 10 seconds
      this._applyVoidTransformations(worldToResume);
    }
    
    // Set as active world
    this.activeWorld = worldToResume;
    
    return true;
  }
  
  /**
   * Get the full state of a world
   * @param {string} worldName - Name of world to get, or active if null
   */
  getWorldState(worldName = null) {
    const world = worldName || this.activeWorld;
    
    if (!world || !this.worlds[world]) {
      return null;
    }
    
    return {
      ...this.worlds[world],
      voidInfluence: this._calculateVoidInfluence(),
      cycleState: this._getCycleState(),
      dualityBalance: this._calculateDualityBalance()
    };
  }
  
  /**
   * Private: Generate potential futures in the void
   */
  _generateVoidPotentials() {
    this.void.potentials = [];
    
    // Generate 3-5 potential directions
    const numPotentials = 3 + Math.floor(Math.random() * 3);
    
    for (let i = 0; i < numPotentials; i++) {
      // Select random emotions for this potential
      const emotions = Object.keys(this.emotionalEngine.emotionalSpectrum);
      const primaryEmotion = emotions[Math.floor(Math.random() * emotions.length)];
      const secondaryEmotion = emotions[Math.floor(Math.random() * emotions.length)];
      
      // Create potential
      const potential = {
        id: `potential-${Date.now()}-${i}`,
        primaryEmotion: primaryEmotion,
        secondaryEmotion: secondaryEmotion,
        strength: 0.3 + Math.random() * 0.7,
        description: this._generatePotentialDescription(primaryEmotion, secondaryEmotion)
      };
      
      this.void.potentials.push(potential);
    }
  }
  
  /**
   * Private: Generate a description for a potential future
   */
  _generatePotentialDescription(primary, secondary) {
    const potentialTemplates = [
      `A world where ${primary} and ${secondary} dance together`,
      `The emergence of ${primary} from the depths of ${secondary}`,
      `${primary} transforms into ${secondary} in unexpected ways`,
      `Structures of ${primary} with undercurrents of ${secondary}`,
      `${primary} creates while ${secondary} shapes and refines`
    ];
    
    return potentialTemplates[Math.floor(Math.random() * potentialTemplates.length)];
  }
  
  /**
   * Private: Apply transformations from void to a world
   */
  _applyVoidTransformations(worldName) {
    // Select the strongest potential
    let strongestPotential = null;
    let maxStrength = 0;
    
    this.void.potentials.forEach(potential => {
      if (potential.strength > maxStrength) {
        maxStrength = potential.strength;
        strongestPotential = potential;
      }
    });
    
    if (strongestPotential && this.worlds[worldName]) {
      // Apply the transformation
      this.worlds[worldName].voidTransformation = {
        applied: new Date(),
        potential: strongestPotential,
        description: `World transformed by ${strongestPotential.primaryEmotion} and ${strongestPotential.secondaryEmotion}`
      };
      
      // Affect all words in the world
      this.worlds[worldName].words.forEach(word => {
        // Add void influence marker
        word.voidInfluenced = true;
        
        // Small power boost
        word.power *= (1 + (strongestPotential.strength * 0.2));
      });
    }
  }
  
  /**
   * Private: Get connection type based on words
   */
  _getConnectionType(word1, word2) {
    // Base type on emotional states
    if (word1.emotionalState === word2.emotionalState) {
      return "harmonic";
    } 
    
    // Check if they're opposing emotions
    const opposites = {
      "joy": "sorrow",
      "fear": "trust",
      "anger": "calm",
      "disgust": "acceptance",
      "surprise": "anticipation"
    };
    
    if (opposites[word1.emotionalState] === word2.emotionalState || 
        opposites[word2.emotionalState] === word1.emotionalState) {
      return "dialectic";
    }
    
    // Default
    return "associative";
  }
  
  /**
   * Private: Get current creation cycle state
   */
  _getCurrentCycle() {
    // Determine which cycle is currently active
    const cycles = Object.keys(this.cycles);
    const activeCycles = cycles.filter(cycle => !this.cycles[cycle].completed);
    
    if (activeCycles.length === 0) {
      // Reset all cycles if all completed
      Object.keys(this.cycles).forEach(cycle => {
        this.cycles[cycle].phase = 0;
        this.cycles[cycle].completed = false;
      });
      return "creation"; // Start with creation
    }
    
    // Return the first active cycle
    return activeCycles[0];
  }
  
  /**
   * Private: Calculate void influence
   */
  _calculateVoidInfluence() {
    if (!this.void.pauseTime) {
      return 0;
    }
    
    // Calculate based on time spent in void
    const timeSincePause = new Date() - this.void.pauseTime;
    return Math.min(1, timeSincePause / 60000); // Max out at 1 minute
  }
  
  /**
   * Private: Get overall cycle state
   */
  _getCycleState() {
    return {
      creation: this.cycles.creation,
      pause: this.cycles.pause,
      destruction: this.cycles.destruction,
      void: this.cycles.void,
      current: this._getCurrentCycle()
    };
  }
  
  /**
   * Private: Calculate duality balance
   */
  _calculateDualityBalance() {
    // Balance between here and there
    let hereStrength = DualitySystem.here.active ? 1 : 0.5;
    let thereStrength = DualitySystem.there.active ? 1 : 0.5;
    
    // Affect by emotional state
    if (this.emotionalEngine.currentEmotion === "joy" || 
        this.emotionalEngine.currentEmotion === "trust") {
      hereStrength *= 1.2;
    } else if (this.emotionalEngine.currentEmotion === "sorrow" || 
              this.emotionalEngine.currentEmotion === "fear") {
      thereStrength *= 1.2;
    }
    
    return {
      here: hereStrength / (hereStrength + thereStrength),
      there: thereStrength / (hereStrength + thereStrength),
      balance: Math.abs(0.5 - (hereStrength / (hereStrength + thereStrength))) * 2
    };
  }
}

/**
 * Export for Node.js environment
 */
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    DualitySystem,
    EmotionalEngine,
    WorldBuilder
  };
}

// If in browser context, attach to window
if (typeof window !== 'undefined') {
  window.DualitySystem = DualitySystem;
  window.EmotionalEngine = EmotionalEngine;
  window.WorldBuilder = WorldBuilder;
}

/**
 * Usage example:
 * 
 * // Create emotional engine and world builder
 * const emotions = new EmotionalEngine();
 * const worlds = new WorldBuilder(emotions);
 * 
 * // Create a new world based on current emotional state
 * emotions.processEmotion("joy", 0.7);
 * const myWorld = worlds.createWorld("notepad3d");
 * 
 * // Add words to the world
 * worlds.addWord("creation", {x: 0, y: 0, z: 0});
 * worlds.addWord("consciousness", {x: 10, y: 5, z: 3});
 * 
 * // Connect words
 * worlds.connectWords("creation", "consciousness");
 * 
 * // Create trajectory
 * worlds.createTrajectory("awakening", "explore consciousness evolution");
 * 
 * // Pause the world (enter void)
 * worlds.pauseWorld();
 * 
 * // Resume with transformation
 * setTimeout(() => {
 *   worlds.resumeWorld();
 *   console.log(worlds.getWorldState());
 * }, 15000);
 */