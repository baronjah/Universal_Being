/**
 * Akashic Records Database System
 * Metaphysical word indexing and storage system for the World of Words
 * Connects with VR visualization and Google Drive integration
 */

// Core Akashic System Configuration
const AkashicConfig = {
  // Primary dimensional access
  dimensions: {
    physical: true,   // Material words (text files, documents)
    etheric: true,    // In-between state (cached data)
    astral: true,     // Visualization layer (VR interface)
    mental: true,     // Concept linkage layer
    causal: true      // Origin connections
  },
  
  // Storage paths
  paths: {
    localWords: "/mnt/c/Users/Percision 15/12_turns_system/word_database.txt",
    metaStorage: "/mnt/d/JSH_Turn_Data/akashic_records",
    googleDrive: "https://drive.google.com/drive/folders/screenshots",
    vrProjection: "/mnt/d/GodotEden/akashic_vr"
  },
  
  // Special file extensions for metafiles
  specialExtensions: {
    "tdic": "Temporal Dictionary - words indexed by timeframe",
    "panime": "Panoramic Animation - 360° VR-ready word visualization",
    "wpath": "Word Path - tracks evolution of terms across dimensions",
    "akdna": "Akashic DNA Sequence - deep structure templates",
    "vrwrd": "VR Word - special formatted for direct VR rendering"
  },
  
  // Connection types to other systems
  connections: {
    godot: true,
    databaseDirect: true,
    googleDrive: true,
    vrSystem: true,
    mxSpace: false  // Future expansion
  }
};

/**
 * The Akashic Word Record
 * Core database class for the eternal word library
 */
class AkashicWordRecord {
  constructor() {
    // Primary record storage
    this.words = {};
    this.wordPaths = {};
    this.stories = {};
    this.metafiles = {};
    
    // Indexing system
    this.indices = {
      byLetter: {},        // Indexed by first letter
      byPower: {},         // Indexed by power level
      byDimension: {},     // Indexed by dimension of origin
      byVRCompatibility: {} // Indexed by VR readiness
    };
    
    // Status tracking
    this.lastAccess = Date.now();
    this.totalWords = 0;
    this.totalStories = 0;
    this.totalMetafiles = 0;
    
    // Connection system status
    this.connectionStatus = {
      googleDrive: false,
      vrSystem: false,
      godot: false
    };
    
    // Initialize letter indices (for all alphabetical indexes)
    "abcdefghijklmnopqrstuvwxyz".split('').forEach(letter => {
      this.indices.byLetter[letter] = [];
    });
  }
  
  /**
   * Initialize the Akashic Records system
   */
  async initialize() {
    console.log("Initializing Akashic Records Database...");
    
    // Attempt to connect to all systems
    try {
      await this._connectSystems();
      await this._loadLocalWordDatabase();
      await this._initializeIndices();
      
      console.log(`Akashic Records initialized with ${this.totalWords} words, ${this.totalStories} stories, and ${this.totalMetafiles} metafiles`);
      return true;
    } catch (error) {
      console.error("Error initializing Akashic Records:", error);
      return false;
    }
  }
  
  /**
   * Add a word to the Akashic database
   * @param {string} word - The word to add
   * @param {number} power - Power level of the word
   * @param {object} metadata - Additional information about the word
   */
  addWord(word, power = 10, metadata = {}) {
    // Skip if word already exists
    if (this.words[word]) {
      return this.words[word];
    }
    
    // Create word record
    const record = {
      word: word,
      power: power,
      addedOn: Date.now(),
      accessCount: 0,
      metadata: {
        origin: metadata.origin || "manual",
        dimension: metadata.dimension || "physical",
        vrReady: metadata.vrReady || false,
        ...metadata
      },
      connections: [],
      paths: []
    };
    
    // Add to main database
    this.words[word] = record;
    this.totalWords++;
    
    // Add to indices
    this._addToIndices(record);
    
    return record;
  }
  
  /**
   * Add a story to the Akashic database
   * @param {string} title - Story title
   * @param {string} content - Story content
   * @param {object} metadata - Additional information about the story
   */
  addStory(title, content, metadata = {}) {
    // Create a unique ID if not provided
    const id = metadata.id || `story_${Date.now()}_${Math.floor(Math.random() * 10000)}`;
    
    // Create story record
    const story = {
      id: id,
      title: title,
      content: content,
      addedOn: Date.now(),
      accessCount: 0,
      words: this._extractWords(content),
      metadata: {
        origin: metadata.origin || "manual",
        dimension: metadata.dimension || "mental",
        vrReady: metadata.vrReady || false,
        ...metadata
      },
      connections: []
    };
    
    // Add to stories database
    this.stories[id] = story;
    this.totalStories++;
    
    // Connect words in story to this story
    this._connectStoryWords(story);
    
    return story;
  }
  
  /**
   * Add a metafile to the Akashic database
   * @param {string} filename - Name of the metafile
   * @param {string} fileType - Type of metafile (e.g., tdic, panime)
   * @param {object} data - The metafile data
   */
  addMetafile(filename, fileType, data) {
    // Validate file type
    if (!Object.keys(AkashicConfig.specialExtensions).includes(fileType)) {
      console.warn(`Unknown metafile type: ${fileType}`);
    }
    
    // Create metafile record
    const metafile = {
      filename: filename,
      fileType: fileType,
      description: AkashicConfig.specialExtensions[fileType] || "Unknown format",
      addedOn: Date.now(),
      accessCount: 0,
      data: data,
      connections: []
    };
    
    // Add to metafiles database
    this.metafiles[filename] = metafile;
    this.totalMetafiles++;
    
    // Special handling based on file type
    switch (fileType) {
      case "tdic":
        this._processTdic(metafile);
        break;
      case "panime":
        this._processPanime(metafile);
        break;
      case "wpath":
        this._processWpath(metafile);
        break;
      case "akdna":
        this._processAkdna(metafile);
        break;
      case "vrwrd":
        this._processVrwrd(metafile);
        break;
    }
    
    return metafile;
  }
  
  /**
   * Search for a word in the Akashic Records
   * @param {string} searchTerm - Word or partial word to search for
   * @param {object} options - Search options
   */
  searchWord(searchTerm, options = {}) {
    // Default options
    const defaults = {
      exactMatch: false,
      includeMeta: true,
      includeStories: true,
      dimension: "all",
      limit: 10
    };
    
    // Merge with provided options
    const searchOptions = {...defaults, ...options};
    
    // Prepare search term
    const term = searchTerm.toLowerCase();
    
    // Results container
    const results = {
      words: [],
      metafiles: [],
      stories: [],
      total: 0
    };
    
    // Search words
    if (searchOptions.exactMatch) {
      // Exact match
      if (this.words[term]) {
        results.words.push(this.words[term]);
        this.words[term].accessCount++;
      }
    } else {
      // Partial match
      for (const word in this.words) {
        if (word.toLowerCase().includes(term)) {
          results.words.push(this.words[word]);
          this.words[word].accessCount++;
          
          if (results.words.length >= searchOptions.limit) {
            break;
          }
        }
      }
    }
    
    // Search metafiles if requested
    if (searchOptions.includeMeta) {
      for (const filename in this.metafiles) {
        if (filename.toLowerCase().includes(term)) {
          results.metafiles.push(this.metafiles[filename]);
          this.metafiles[filename].accessCount++;
        }
      }
    }
    
    // Search stories if requested
    if (searchOptions.includeStories) {
      for (const id in this.stories) {
        const story = this.stories[id];
        if (story.title.toLowerCase().includes(term) || 
            story.content.toLowerCase().includes(term)) {
          results.stories.push(story);
          story.accessCount++;
        }
      }
    }
    
    // Calculate total results
    results.total = results.words.length + results.metafiles.length + results.stories.length;
    
    // Update last access
    this.lastAccess = Date.now();
    
    return results;
  }
  
  /**
   * Search by using a word path
   * @param {string} pathPattern - The path pattern to search for
   */
  searchByPath(pathPattern) {
    const results = [];
    
    // Look for matching paths
    for (const wordId in this.wordPaths) {
      const paths = this.wordPaths[wordId];
      
      for (const path of paths) {
        if (path.pattern.includes(pathPattern)) {
          results.push({
            word: this.words[wordId],
            path: path
          });
        }
      }
    }
    
    return results;
  }
  
  /**
   * Generate a VR-ready export of selected words
   * @param {array} wordList - List of words to export
   * @param {string} format - Export format (godot, unity, web)
   */
  exportForVR(wordList, format = "godot") {
    const result = {
      format: format,
      timestamp: Date.now(),
      count: 0,
      words: []
    };
    
    // Process each word
    for (const wordText of wordList) {
      if (this.words[wordText]) {
        const word = this.words[wordText];
        
        // Add VR-specific properties
        const vrWord = {
          text: word.word,
          power: word.power,
          color: this._getWordColor(word),
          position: this._calculateWordPosition(word),
          connections: word.connections.length,
          dimension: word.metadata.dimension,
          data: word.metadata.vrReady ? 
            this._prepareVRData(word, format) : 
            this._generateBasicVRData(word, format)
        };
        
        result.words.push(vrWord);
        result.count++;
      }
    }
    
    return result;
  }
  
  /**
   * Connect to Google Drive to fetch screenshots
   * @param {string} folderPath - Path to the screenshots folder
   */
  async connectGoogleDrive(folderPath) {
    // In a real implementation, this would use Google API
    // For this mock version, we'll simulate the connection
    console.log(`Connecting to Google Drive folder: ${folderPath}`);
    
    try {
      // Simulated connection delay
      await new Promise(resolve => setTimeout(resolve, 1500));
      
      // Simulate success
      this.connectionStatus.googleDrive = true;
      
      // Return mock screenshot data
      return {
        connected: true,
        screenshotCount: 27,
        availableFiles: [
          "word_visualization_1.png",
          "akashic_record_view.png",
          "vr_word_cloud.png",
          "word_paths_3d.png"
        ]
      };
    } catch (error) {
      console.error("Failed to connect to Google Drive:", error);
      return {
        connected: false,
        error: error.message
      };
    }
  }
  
  /**
   * Process a screenshot from Google Drive
   * @param {string} screenshotPath - Path to the screenshot
   */
  async processScreenshot(screenshotPath) {
    // Verify Google Drive connection
    if (!this.connectionStatus.googleDrive) {
      throw new Error("Google Drive not connected");
    }
    
    console.log(`Processing screenshot: ${screenshotPath}`);
    
    try {
      // In a real implementation, this would:
      // 1. Download the image from Google Drive
      // 2. Use OCR to extract text
      // 3. Process the extracted text for words
      
      // Simulated delay
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      // Simulated OCR result
      const extractedText = "This is simulated OCR text that would contain power words like divine creation consciousness and reality";
      
      // Extract words from the OCR text
      const words = this._extractWords(extractedText);
      
      // Add extracted words to database
      const addedWords = [];
      for (const word of words) {
        const power = Math.floor(Math.random() * 50) + 10; // Random power 10-60
        const newWord = this.addWord(word, power, {
          origin: "screenshot",
          source: screenshotPath
        });
        
        addedWords.push(newWord);
      }
      
      return {
        success: true,
        wordsExtracted: words.length,
        wordsAdded: addedWords.length,
        words: addedWords
      };
    } catch (error) {
      console.error("Failed to process screenshot:", error);
      return {
        success: false,
        error: error.message
      };
    }
  }
  
  /**
   * Create a new metafile of type tdic (Temporal Dictionary)
   * @param {string} name - Name of the dictionary
   * @param {array} words - Array of words to include
   */
  createTemporalDictionary(name, words) {
    // Create the TDIC structure
    const tdic = {
      name: name,
      timeframes: {
        past: [],
        present: [],
        future: []
      },
      transitions: []
    };
    
    // Categorize words into timeframes
    for (const wordText of words) {
      if (this.words[wordText]) {
        const word = this.words[wordText];
        
        // Determine timeframe based on metadata or word properties
        let timeframe = "present"; // Default
        
        if (word.metadata.timeframe) {
          timeframe = word.metadata.timeframe;
        } else if (wordText.endsWith("ed") || wordText.endsWith("was") || wordText.endsWith("had")) {
          timeframe = "past";
        } else if (wordText.endsWith("will") || wordText.endsWith("shall") || wordText.includes("future")) {
          timeframe = "future";
        }
        
        // Add to appropriate timeframe
        tdic.timeframes[timeframe].push(wordText);
      }
    }
    
    // Create transitions between timeframes
    // Connect words that might be related across time
    for (const past of tdic.timeframes.past) {
      for (const present of tdic.timeframes.present) {
        if (this._areWordsRelated(past, present)) {
          tdic.transitions.push({
            from: past, 
            to: present,
            type: "evolution"
          });
        }
      }
    }
    
    for (const present of tdic.timeframes.present) {
      for (const future of tdic.timeframes.future) {
        if (this._areWordsRelated(present, future)) {
          tdic.transitions.push({
            from: present, 
            to: future,
            type: "potential"
          });
        }
      }
    }
    
    // Add the TDIC as a metafile
    return this.addMetafile(`${name}.tdic`, "tdic", tdic);
  }
  
  /**
   * Create a new metafile of type panime (Panoramic Animation)
   * @param {string} name - Name of the animation
   * @param {array} words - Words to include in the animation
   * @param {object} settings - Animation settings
   */
  createPanoramic(name, words, settings = {}) {
    // Default settings
    const defaults = {
      duration: 60, // seconds
      background: "cosmic",
      rotationSpeed: 5,
      dimension: "astral"
    };
    
    // Merge with provided settings
    const animSettings = {...defaults, ...settings};
    
    // Create the PANIME structure
    const panime = {
      name: name,
      settings: animSettings,
      frames: [],
      words: [],
      totalWords: 0,
      vrReady: true
    };
    
    // Add words to the animation
    for (const wordText of words) {
      if (this.words[wordText]) {
        const word = this.words[wordText];
        
        // Create word animation data
        const wordAnim = {
          word: wordText,
          power: word.power,
          position: this._calculateWordPosition(word),
          color: this._getWordColor(word),
          animation: {
            path: this._generateAnimationPath(word, animSettings),
            scale: [1, 1 + (word.power / 100)],
            opacity: [0.5, 1],
            rotation: [0, 360 * (animSettings.rotationSpeed / 60)]
          }
        };
        
        panime.words.push(wordAnim);
        panime.totalWords++;
      }
    }
    
    // Create keyframes for the animation
    const frameCount = animSettings.duration * 30; // 30fps
    for (let i = 0; i < frameCount; i++) {
      const time = i / frameCount;
      panime.frames.push({
        time: time,
        cameraPosition: this._getCameraPosition(time, animSettings),
        wordPositions: panime.words.map(word => ({
          word: word.word,
          position: this._getWordPositionAtTime(word, time)
        }))
      });
    }
    
    // Add the PANIME as a metafile
    return this.addMetafile(`${name}.panime`, "panime", panime);
  }
  
  /**
   * Connect to VR system
   * @param {string} vrSystemPath - Path to VR system
   */
  async connectVRSystem(vrSystemPath = AkashicConfig.paths.vrProjection) {
    console.log(`Connecting to VR system at: ${vrSystemPath}`);
    
    try {
      // In a real implementation, this would set up the connection
      // to the VR system (Godot, Unity, etc.)
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      this.connectionStatus.vrSystem = true;
      
      return {
        connected: true,
        system: "Godot VR",
        dimensions: ["3D", "VR", "AR"],
        capabilities: ["wordVisualization", "pathTracking", "dimensionalShift"]
      };
    } catch (error) {
      console.error("Failed to connect to VR system:", error);
      return {
        connected: false,
        error: error.message
      };
    }
  }
  
  /**
   * Get statistics about the Akashic Records
   */
  getStats() {
    // Count words by first letter
    const letterCounts = {};
    for (const letter in this.indices.byLetter) {
      letterCounts[letter] = this.indices.byLetter[letter].length;
    }
    
    // Count words by power level
    const powerCounts = {
      low: 0,    // 0-25
      medium: 0, // 26-50
      high: 0,   // 51-75
      divine: 0  // 76-100
    };
    
    for (const word in this.words) {
      const power = this.words[word].power;
      if (power <= 25) powerCounts.low++;
      else if (power <= 50) powerCounts.medium++;
      else if (power <= 75) powerCounts.high++;
      else powerCounts.divine++;
    }
    
    // Count metafiles by type
    const metafileCounts = {};
    for (const filename in this.metafiles) {
      const type = this.metafiles[filename].fileType;
      metafileCounts[type] = (metafileCounts[type] || 0) + 1;
    }
    
    return {
      totalWords: this.totalWords,
      totalStories: this.totalStories,
      totalMetafiles: this.totalMetafiles,
      letterCounts: letterCounts,
      powerCounts: powerCounts,
      metafileCounts: metafileCounts,
      connectionStatus: this.connectionStatus,
      lastAccess: this.lastAccess
    };
  }
  
  /**
   * Private: Connect to external systems
   */
  async _connectSystems() {
    console.log("Connecting to external systems...");
    
    // Connect to Google Drive if configured
    if (AkashicConfig.connections.googleDrive) {
      try {
        const driveConnection = await this.connectGoogleDrive(AkashicConfig.paths.googleDrive);
        console.log(`Google Drive connection: ${driveConnection.connected ? "Success" : "Failed"}`);
      } catch (error) {
        console.warn("Failed to connect to Google Drive:", error);
      }
    }
    
    // Connect to VR system if configured
    if (AkashicConfig.connections.vrSystem) {
      try {
        const vrConnection = await this.connectVRSystem();
        console.log(`VR system connection: ${vrConnection.connected ? "Success" : "Failed"}`);
      } catch (error) {
        console.warn("Failed to connect to VR system:", error);
      }
    }
    
    // Connect to Godot if configured
    if (AkashicConfig.connections.godot) {
      try {
        // Simulated connection to Godot
        await new Promise(resolve => setTimeout(resolve, 800));
        this.connectionStatus.godot = true;
        console.log("Godot connection: Success");
      } catch (error) {
        console.warn("Failed to connect to Godot:", error);
      }
    }
  }
  
  /**
   * Private: Load local word database
   */
  async _loadLocalWordDatabase() {
    console.log(`Loading word database from: ${AkashicConfig.paths.localWords}`);
    
    try {
      // In a real implementation, this would read from the actual file
      // For this mock version, we'll add some sample words
      
      // Sample words (in a real implementation, these would come from the file)
      const sampleWords = [
        {word: "divine", power: 75},
        {word: "creation", power: 40},
        {word: "reality", power: 35},
        {word: "consciousness", power: 60},
        {word: "eternal", power: 50},
        {word: "universe", power: 30},
        {word: "transcendent", power: 65},
        {word: "infinite", power: 45},
        {word: "cosmic", power: 55},
        {word: "absolute", power: 70}
      ];
      
      // Add sample words to database
      for (const {word, power} of sampleWords) {
        this.addWord(word, power, {
          origin: "default",
          dimension: "mental"
        });
      }
      
      // Add a few sample stories
      this.addStory(
        "The Creation",
        "In the beginning, there was the divine word. Through this word, reality itself came into being. Consciousness emerged from the infinite void, embracing the cosmic dance of creation.",
        {
          dimension: "causal",
          vrReady: true
        }
      );
      
      this.addStory(
        "Eternal Return",
        "The universe breathes in cycles, expanding and contracting in an eternal rhythm. Each cycle brings new forms of consciousness, yet the absolute nature remains transcendent.",
        {
          dimension: "mental"
        }
      );
      
      // Add sample metafiles
      this.createTemporalDictionary("CoreConcepts", ["divine", "creation", "reality", "consciousness"]);
      this.createPanoramic("CosmicVisualization", ["universe", "cosmic", "infinite", "transcendent"]);
      
      return true;
    } catch (error) {
      console.error("Failed to load word database:", error);
      return false;
    }
  }
  
  /**
   * Private: Initialize indices
   */
  async _initializeIndices() {
    console.log("Initializing indices...");
    
    // Clear existing indices
    for (const letter in this.indices.byLetter) {
      this.indices.byLetter[letter] = [];
    }
    this.indices.byPower = {};
    this.indices.byDimension = {};
    this.indices.byVRCompatibility = {
      ready: [],
      notReady: []
    };
    
    // Add all words to indices
    for (const word in this.words) {
      this._addToIndices(this.words[word]);
    }
    
    return true;
  }
  
  /**
   * Private: Add a word to indices
   */
  _addToIndices(wordRecord) {
    const word = wordRecord.word;
    
    // Add to letter index
    const firstLetter = word[0].toLowerCase();
    if (this.indices.byLetter[firstLetter]) {
      this.indices.byLetter[firstLetter].push(word);
    }
    
    // Add to power index
    const powerLevel = Math.floor(wordRecord.power / 10) * 10; // Group by 10s
    this.indices.byPower[powerLevel] = this.indices.byPower[powerLevel] || [];
    this.indices.byPower[powerLevel].push(word);
    
    // Add to dimension index
    const dimension = wordRecord.metadata.dimension;
    this.indices.byDimension[dimension] = this.indices.byDimension[dimension] || [];
    this.indices.byDimension[dimension].push(word);
    
    // Add to VR compatibility index
    if (wordRecord.metadata.vrReady) {
      this.indices.byVRCompatibility.ready.push(word);
    } else {
      this.indices.byVRCompatibility.notReady.push(word);
    }
  }
  
  /**
   * Private: Extract words from text
   */
  _extractWords(text) {
    // Simple word extraction - in a real implementation, this would be more sophisticated
    return text.toLowerCase()
      .replace(/[^\w\s]/g, '') // Remove punctuation
      .split(/\s+/) // Split on whitespace
      .filter(word => word.length > 0); // Remove empty strings
  }
  
  /**
   * Private: Connect story words to story
   */
  _connectStoryWords(story) {
    // Connect each word in the story to the story
    for (const word of story.words) {
      if (this.words[word]) {
        // Add story to word's connections
        this.words[word].connections.push({
          type: "story",
          id: story.id,
          title: story.title
        });
      }
    }
  }
  
  /**
   * Private: Process TDIC (Temporal Dictionary) file
   */
  _processTdic(metafile) {
    const tdic = metafile.data;
    
    // Connect words in the TDIC
    for (const timeframe in tdic.timeframes) {
      for (const word of tdic.timeframes[timeframe]) {
        if (this.words[word]) {
          // Set timeframe in word metadata
          this.words[word].metadata.timeframe = timeframe;
          
          // Connect word to TDIC
          this.words[word].connections.push({
            type: "tdic",
            filename: metafile.filename,
            timeframe: timeframe
          });
        }
      }
    }
  }
  
  /**
   * Private: Process PANIME (Panoramic Animation) file
   */
  _processPanime(metafile) {
    const panime = metafile.data;
    
    // Connect words in the PANIME
    for (const wordAnim of panime.words) {
      const word = wordAnim.word;
      
      if (this.words[word]) {
        // Mark as VR ready
        this.words[word].metadata.vrReady = true;
        
        // Connect word to PANIME
        this.words[word].connections.push({
          type: "panime",
          filename: metafile.filename,
          animationData: {
            position: wordAnim.position,
            color: wordAnim.color
          }
        });
      }
    }
  }
  
  /**
   * Private: Process WPATH (Word Path) file
   */
  _processWpath(metafile) {
    // To be implemented
  }
  
  /**
   * Private: Process AKDNA (Akashic DNA) file
   */
  _processAkdna(metafile) {
    // To be implemented
  }
  
  /**
   * Private: Process VRWRD (VR Word) file
   */
  _processVrwrd(metafile) {
    // To be implemented
  }
  
  /**
   * Private: Calculate color for a word based on its properties
   */
  _getWordColor(word) {
    // Base color on word power
    const power = word.power;
    
    if (power >= 75) {
      return "#FFD700"; // Gold for divine words (75-100)
    } else if (power >= 50) {
      return "#9370DB"; // Purple for high power words (50-74)
    } else if (power >= 25) {
      return "#4682B4"; // Steel blue for medium power words (25-49)
    } else {
      return "#708090"; // Slate gray for low power words (0-24)
    }
  }
  
  /**
   * Private: Calculate 3D position for a word
   */
  _calculateWordPosition(word) {
    // In a real implementation, this would use a more sophisticated algorithm
    // For now, we'll generate a random position
    const radius = 5 + (word.power / 10); // Higher power = further from center
    const theta = Math.random() * Math.PI * 2;
    const phi = Math.random() * Math.PI;
    
    return {
      x: radius * Math.sin(phi) * Math.cos(theta),
      y: radius * Math.sin(phi) * Math.sin(theta),
      z: radius * Math.cos(phi)
    };
  }
  
  /**
   * Private: Prepare VR data for a word
   */
  _prepareVRData(word, format) {
    // Format-specific VR data
    switch (format) {
      case "godot":
        return {
          node_type: "WordSpatial",
          properties: {
            text: word.word,
            font_size: 18 + (word.power / 5),
            color: this._getWordColor(word),
            billboard: true,
            emission_enabled: true,
            emission_energy: word.power / 25
          }
        };
        
      case "unity":
        return {
          prefab: "WordObject",
          properties: {
            text: word.word,
            fontSize: 0.5 + (word.power / 200),
            color: this._getWordColor(word),
            lookAtCamera: true,
            emissionIntensity: word.power / 25
          }
        };
        
      case "web":
        return {
          element: "div",
          class: "vr-word",
          style: {
            color: this._getWordColor(word),
            fontSize: `${Math.max(1, word.power / 10)}em`,
            opacity: Math.min(1, 0.5 + (word.power / 100)),
            textShadow: `0 0 ${word.power / 10}px ${this._getWordColor(word)}`
          }
        };
        
      default:
        return { format: "unknown" };
    }
  }
  
  /**
   * Private: Generate basic VR data for a word
   */
  _generateBasicVRData(word, format) {
    // Simplified version of _prepareVRData for words not marked as VR-ready
    const data = this._prepareVRData(word, format);
    
    // Reduce visual effects
    switch (format) {
      case "godot":
        data.properties.emission_enabled = false;
        data.properties.font_size /= 1.5;
        break;
        
      case "unity":
        data.properties.emissionIntensity = 0;
        data.properties.fontSize /= 1.5;
        break;
        
      case "web":
        data.style.textShadow = "none";
        data.style.opacity = 0.7;
        break;
    }
    
    return data;
  }
  
  /**
   * Private: Generate animation path for a word
   */
  _generateAnimationPath(word, settings) {
    // Create a circular or spiral path for the word
    const baseRadius = 5 + (word.power / 20);
    const points = [];
    const cycles = settings.duration / 10; // Complete cycle every 10 seconds
    
    for (let t = 0; t <= 1; t += 0.05) {
      const angle = t * Math.PI * 2 * cycles;
      const radius = baseRadius + (t * word.power / 50); // Spiral outward
      
      points.push({
        x: radius * Math.cos(angle),
        y: (t * word.power / 10) - (word.power / 20), // Rise based on power
        z: radius * Math.sin(angle)
      });
    }
    
    return points;
  }
  
  /**
   * Private: Get camera position at a specific time
   */
  _getCameraPosition(time, settings) {
    // Create a circular path for the camera
    const radius = 20;
    const angle = time * Math.PI * 2;
    
    return {
      x: radius * Math.cos(angle),
      y: 5 * Math.sin(time * Math.PI * 4), // Oscillate up and down
      z: radius * Math.sin(angle),
      lookAt: {x: 0, y: 0, z: 0} // Always look at center
    };
  }
  
  /**
   * Private: Get word position at a specific time during animation
   */
  _getWordPositionAtTime(word, time) {
    const path = word.animation.path;
    
    // Find the two closest points in the path
    const pathIndex = Math.min(Math.floor(time * (path.length - 1)), path.length - 2);
    const point1 = path[pathIndex];
    const point2 = path[pathIndex + 1];
    
    // Calculate the exact position through linear interpolation
    const segmentTime = (time * (path.length - 1)) - pathIndex;
    
    return {
      x: point1.x + (point2.x - point1.x) * segmentTime,
      y: point1.y + (point2.y - point1.y) * segmentTime,
      z: point1.z + (point2.z - point1.z) * segmentTime
    };
  }
  
  /**
   * Private: Check if two words are related
   */
  _areWordsRelated(word1, word2) {
    // Simple check - in a real implementation, this would be more sophisticated
    // For now, we'll consider words related if they share a prefix or suffix
    
    // Check for common prefix (at least 3 characters)
    const minLength = Math.min(word1.length, word2.length);
    if (minLength >= 5) {
      const prefix = word1.substring(0, 3);
      if (word2.startsWith(prefix)) {
        return true;
      }
    }
    
    // Check for common suffix (at least 2 characters)
    if (minLength >= 4) {
      const suffix1 = word1.substring(word1.length - 2);
      const suffix2 = word2.substring(word2.length - 2);
      if (suffix1 === suffix2) {
        return true;
      }
    }
    
    // Not related
    return false;
  }
}

// Export for Node.js environments
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    AkashicConfig,
    AkashicWordRecord
  };
}

// If in browser context, attach to window
if (typeof window !== 'undefined') {
  window.AkashicConfig = AkashicConfig;
  window.AkashicWordRecord = AkashicWordRecord;
}

/**
 * Usage Example:
 * 
 * // Create and initialize Akashic Records
 * const akashicRecords = new AkashicWordRecord();
 * await akashicRecords.initialize();
 * 
 * // Add a new word
 * akashicRecords.addWord("quantum", 65, { dimension: "mental", vrReady: true });
 * 
 * // Search for words
 * const results = akashicRecords.searchWord("consciousness");
 * console.log(`Found ${results.total} results`);
 * 
 * // Connect to Google Drive and process screenshots
 * await akashicRecords.connectGoogleDrive("path/to/screenshots");
 * const processed = await akashicRecords.processScreenshot("screenshot1.png");
 * 
 * // Create a panoramic animation for VR
 * const animation = akashicRecords.createPanoramic("QuantumRealm", ["quantum", "consciousness", "reality"]);
 * 
 * // Export for VR
 * const vrData = akashicRecords.exportForVR(["quantum", "consciousness", "reality"], "godot");
 */