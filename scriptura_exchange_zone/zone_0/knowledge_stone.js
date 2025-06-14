/**
 * Knowledge Stone - JavaScript library for GitHub integration
 * Connects your knowledge stones to remote repositories
 */

// Configuration
const config = {
  stonesPath: "D:/JSH_Turn_Data/knowledge_stones",
  githubRepo: "https://github.com/user/12-turns-system",
  useOCR: true,
  useVarInsteadOfLet: true  // var vs let distinction
};

// Stone class - represents a knowledge unit
class Stone {
  constructor(name, power) {
    // Use var instead of let if configured
    if (config.useVarInsteadOfLet) {
      var stoneName = name;
      var stonePower = power || 10;
      var connections = [];
      var creationTime = new Date();
      var content = "";
      
      // Make these available to methods via this
      this.stoneName = stoneName;
      this.stonePower = stonePower;
      this.connections = connections;
      this.creationTime = creationTime;
      this.content = content;
    } else {
      this.stoneName = name;
      this.stonePower = power || 10;
      this.connections = [];
      this.creationTime = new Date();
      this.content = "";
    }
  }
  
  // Add content to stone
  addContent(text) {
    this.content += text;
    // Increase power based on content length
    this.stonePower += Math.floor(text.length / 100);
    return this;
  }
  
  // Connect to another stone
  connectTo(otherStone) {
    if (!this.connections.includes(otherStone.stoneName)) {
      this.connections.push(otherStone.stoneName);
      // Connection increases power for both stones
      const powerBoost = Math.floor((this.stonePower + otherStone.stonePower) * 0.1);
      this.stonePower += powerBoost;
      otherStone.stonePower += powerBoost;
      
      // Also connect the other stone back to this one
      if (!otherStone.connections.includes(this.stoneName)) {
        otherStone.connections.push(this.stoneName);
      }
    }
    return this;
  }
  
  // Convert to JSON
  toJSON() {
    return {
      stone_name: this.stoneName,
      power_level: this.stonePower,
      connections: this.connections,
      creation_time: this.creationTime.toISOString(),
      content: this.content
    };
  }
  
  // Load from JSON
  static fromJSON(json) {
    const stone = new Stone(json.stone_name, json.power_level);
    stone.connections = json.connections || [];
    stone.creationTime = new Date(json.creation_time);
    stone.content = json.content || "";
    return stone;
  }
}

// StoneManager - manages collections of stones
class StoneManager {
  constructor() {
    this.stones = {};
    this.totalPower = 0;
    this.goldPoints = 0;
  }
  
  // Create a new stone
  createStone(name, power) {
    if (this.stones[name]) {
      console.warn(`Stone ${name} already exists`);
      return this.stones[name];
    }
    
    const stone = new Stone(name, power);
    this.stones[name] = stone;
    this.totalPower += stone.stonePower;
    return stone;
  }
  
  // Get a stone by name
  getStone(name) {
    return this.stones[name];
  }
  
  // Connect two stones by name
  connectStones(name1, name2) {
    const stone1 = this.getStone(name1);
    const stone2 = this.getStone(name2);
    
    if (!stone1 || !stone2) {
      console.error("Cannot connect: one or both stones do not exist");
      return false;
    }
    
    stone1.connectTo(stone2);
    this.totalPower = Object.values(this.stones).reduce((sum, stone) => sum + stone.stonePower, 0);
    return true;
  }
  
  // Process a word for points
  processWord(word) {
    // Calculate base power
    let wordPower = word.length;
    
    // C words get bonus
    if (word.toLowerCase().startsWith('c')) {
      wordPower += 5;
    }
    
    // Powerful words get extra bonus
    const powerfulWords = ["divine", "creation", "reality", "consciousness", "eternal"];
    if (powerfulWords.includes(word.toLowerCase())) {
      wordPower += 15;
    }
    
    // Add gold points
    this.goldPoints += wordPower;
    
    // Create or update a stone for this word
    let stone = this.getStone(`word_${word}`);
    if (stone) {
      stone.stonePower += wordPower;
    } else {
      stone = this.createStone(`word_${word}`, wordPower);
    }
    
    return wordPower;
  }
  
  // Save all stones to file system (mock function)
  saveStones() {
    console.log(`Saving ${Object.keys(this.stones).length} stones to ${config.stonesPath}`);
    return true;
  }
  
  // Load stones from file system (mock function)
  loadStones() {
    console.log(`Loading stones from ${config.stonesPath}`);
    // This would typically load from files
    return true;
  }
  
  // Get stats about the stone collection
  getStats() {
    return {
      stoneCount: Object.keys(this.stones).length,
      totalPower: this.totalPower,
      goldPoints: this.goldPoints,
      mostPowerfulStone: this.getMostPowerfulStone()
    };
  }
  
  // Get the most powerful stone
  getMostPowerfulStone() {
    let mostPowerful = null;
    let highestPower = 0;
    
    for (const stoneName in this.stones) {
      if (this.stones[stoneName].stonePower > highestPower) {
        highestPower = this.stones[stoneName].stonePower;
        mostPowerful = stoneName;
      }
    }
    
    return mostPowerful;
  }
  
  // OCR integration (simulated)
  processImageWithOCR(imagePath) {
    if (!config.useOCR) {
      console.error("OCR is disabled in configuration");
      return null;
    }
    
    console.log(`Processing image ${imagePath} with OCR`);
    // This would call an OCR service in a real implementation
    return {
      text: "Simulated OCR text from image",
      confidence: 0.89
    };
  }
  
  // GitHub operations (simulated)
  pushToGitHub() {
    console.log(`Pushing stones to GitHub repository: ${config.githubRepo}`);
    // This would use GitHub API in a real implementation
    return {
      success: true,
      commit: "abc1234",
      message: "Updated knowledge stones"
    };
  }
}

// Export for Node.js
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    Stone,
    StoneManager,
    config
  };
}

// Example usage:
// const manager = new StoneManager();
// manager.createStone("divine_word", 75);
// manager.createStone("consciousness", 60);
// manager.connectStones("divine_word", "consciousness");
// console.log(manager.getStats());