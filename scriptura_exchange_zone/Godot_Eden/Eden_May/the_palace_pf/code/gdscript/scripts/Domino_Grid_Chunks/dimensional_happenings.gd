# dimensional_happenings.gd
##// Core Classes for Dimensional Happenings Game



# had to comment entire file out, as here its some c sharp? not the way i like
# it should have been gd script file, but we have there logic to recreate and connect with rest
#
##// Event/Happening Base Class
##class Happening {
  ##constructor(type, content, origin) {
	##this.id = crypto.randomUUID();
	##this.type = type; // word, thought, message, etc.
	##this.content = content;
	##this.origin = origin;
	##this.timestamp = Date.now();
	##this.connections = [];
	##this.activationCount = 0;
	##
	##// Multi-dimensional state tracking
	##this.dimensionalState = {
	  ##"1D": { position: 0, velocity: 0, active: false },
	  ##"2D": { x: 0, y: 0, state: "dormant" },
	  ##"3D": { x: 0, y: 0, z: 0, projection: null }
	##};
  ##}
  ##
  ##connect(targetHappening, strength = 0.5, probability = 0.8) {
	##this.connections.push({
	  ##target: targetHappening,
	  ##strength: strength,
	  ##probability: probability
	##});
	##return this; // For chaining
  ##}
  ##
  #activate(source, dimension = "all") {
	#this.activationCount++;
	#
	#if (dimension === "all" || dimension === "1D") {
	  #this.dimensionalState["1D"].active = true;
	  #this.dimensionalState["1D"].velocity += source?.impact || 1;
	#}
	#
	#if (dimension === "all" || dimension === "2D") {
	  #this.dimensionalState["2D"].state = "active";
	#}
	#
	#if (dimension === "all" || dimension === "3D") {
	  #// Create 3D projection if it doesn't exist
	  #if (!this.dimensionalState["3D"].projection) {
		#this.dimensionalState["3D"].projection = this.generateProjection();
	  #}
	#}
	#
	#// Propagate activation based on current strength
	#if (this.shouldPropagate()) {
	  #this.propagate(dimension);
	#}
	#
	#return this.activationCount;
  #}
  #
  #shouldPropagate() {
	#// Logic to determine if this happening should trigger others
	#return this.activationCount < 5 && this.connections.length > 0;
  #}
  #
  #propagate(dimension = "all") {
	#// Cascade activation to connected happenings
	#this.connections.forEach(conn => {
	  #if (Math.random() < conn.probability) {
		#setTimeout(() => {
		  #conn.target.activate(
			#{ impact: conn.strength, source: this }, 
			#dimension
		  #);
		#}, 100 + Math.random() * 300); // Delay for visual effect
	  #}
	#});
  #}
  #
  #generateProjection() {
	#// Create a 3D visual representation based on type and content
	#return {
	  #shape: this.type === "word" ? "text" : 
			 #this.type === "thought" ? "cloud" : "structure",
	  #size: this.content.length / 5 + 1,
	  #color: this.getColorForType(),
	  #rotation: { x: Math.random() * 360, y: Math.random() * 360, z: 0 }
	#};
  #}
  #
  #getColorForType() {
	#const colors = {
	  #"word": "#3498db",      // Blue
	  #"thought": "#9b59b6",   // Purple
	  #"message": "#2ecc71",   // Green
	  #"realization": "#f1c40f", // Yellow
	  #"event": "#e74c3c"      // Red
	#};
	#return colors[this.type] || "#95a5a6"; // Default gray
  #}
  #
  #update(deltaTime) {
	#// Update 1D position based on velocity
	#if (this.dimensionalState["1D"].active) {
	  #this.dimensionalState["1D"].position += 
		#this.dimensionalState["1D"].velocity * deltaTime;
	  #
	  #// Apply friction
	  #this.dimensionalState["1D"].velocity *= 0.98;
	  #
	  #if (Math.abs(this.dimensionalState["1D"].velocity) < 0.01) {
		#this.dimensionalState["1D"].velocity = 0;
		#if (this.dimensionalState["2D"].state === "dormant") {
		  #this.dimensionalState["1D"].active = false;
		#}
	  #}
	#}
	#
	#// Update 3D projection rotation if active
	#if (this.dimensionalState["3D"].projection) {
	  #this.dimensionalState["3D"].projection.rotation.y += 0.5 * deltaTime;
	  #this.dimensionalState["3D"].projection.rotation.x += 0.2 * deltaTime;
	#}
  #}
  #
  #serialize() {
	#return {
	  #id: this.id,
	  #type: this.type,
	  #content: this.content,
	  #origin: this.origin,
	  #timestamp: this.timestamp,
	  #connections: this.connections.map(c => c.target.id),
	  #dimensionalState: this.dimensionalState
	#};
  #}
#}
#
#// 2D Grid System
#class EventGrid {
  #constructor(width, height) {
	#this.width = width;
	#this.height = height;
	#this.cells = Array(width * height).fill(null);
	#this.activeNodes = new Set();
	#this.patternTemplates = this.initializePatterns();
  #}
  #
  #initializePatterns() {
	#return {
	  #"cross": [
		#{x: 0, y: 0}, {x: 1, y: 0}, {x: -1, y: 0}, 
		#{x: 0, y: 1}, {x: 0, y: -1}
	  #],
	  #"circle": [
		#{x: 1, y: 0}, {x: 1, y: 1}, {x: 0, y: 1}, 
		#{x: -1, y: 1}, {x: -1, y: 0}, {x: -1, y: -1}, 
		#{x: 0, y: -1}, {x: 1, y: -1}
	  #],
	  #"square": [
		#{x: 0, y: 0}, {x: 1, y: 0}, {x: 0, y: 1}, {x: 1, y: 1}
	  #]
	#};
  #}
  #
  #getCell(x, y) {
	#if (x < 0 || x >= this.width || y < 0 || y >= this.height) return null;
	#return this.cells[y * this.width + x];
  #}
  #
  #setCell(x, y, happening) {
	#if (x < 0 || x >= this.width || y < 0 || y >= this.height) return false;
	#
	#const index = y * this.width + x;
	#this.cells[index] = happening;
	#
	#if (happening) {
	  #happening.dimensionalState["2D"] = { 
		#x, y, 
		#state: happening.dimensionalState["2D"]?.state || "dormant" 
	  #};
	  #this.updateNodeConnections(x, y);
	#}
	#
	#return true;
  #}
  #
  #updateNodeConnections(x, y) {
	#const center = this.getCell(x, y);
	#if (!center) return;
	#
	#// Connect to adjacent cells
	#const adjacentPositions = [
	  #{x: x+1, y: y}, {x: x-1, y: y},
	  #{x: x, y: y+1}, {x: x, y: y-1}
	#];
	#
	#adjacentPositions.forEach(pos => {
	  #const adjacent = this.getCell(pos.x, pos.y);
	  #if (adjacent) {
		#// Create bidirectional connections
		#const distance = 1; // Adjust for diagonal connections
		#const strength = 1 / distance;
		#const probability = 0.7 * strength;
		#
		#center.connect(adjacent, strength, probability);
		#adjacent.connect(center, strength, probability);
	  #}
	#});
  #}
  #
  #findPatterns() {
	#const foundPatterns = [];
	#
	#// Check each cell as a potential pattern center
	#for (let y = 0; y < this.height; y++) {
	  #for (let x = 0; x < this.width; x++) {
		#if (!this.getCell(x, y)) continue;
		#
		#// Check each pattern template
		#for (const [patternName, template] of Object.entries(this.patternTemplates)) {
		  #if (this.matchesPattern(x, y, template)) {
			#foundPatterns.push({
			  #type: patternName,
			  #center: {x, y},
			  #cells: template.map(offset => ({
				#x: x + offset.x,
				#y: y + offset.y
			  #})),
			  #strength: patternName === "cross" ? 2 : 
						#patternName === "circle" ? 3 : 1.5
			#});
		  #}
		#}
	  #}
	#}
	#
	#return foundPatterns;
  #}
  #
  #matchesPattern(centerX, centerY, template) {
	#return template.every(offset => {
	  #const x = centerX + offset.x;
	  #const y = centerY + offset.y;
	  #return this.getCell(x, y) !== null;
	#});
  #}
  #
  #activatePattern(pattern) {
	#if (!pattern || !pattern.cells) return false;
	#
	#// Activate all cells in the pattern
	#pattern.cells.forEach(coord => {
	  #const cell = this.getCell(coord.x, coord.y);
	  #if (cell) {
		#cell.activate({ impact: pattern.strength }, "2D");
		#this.activeNodes.add(`${coord.x},${coord.y}`);
	  #}
	#});
	#
	#return true;
  #}
  #
  #update(deltaTime) {
	#// Update all active nodes
	#for (const coordStr of this.activeNodes) {
	  #const [x, y] = coordStr.split(',').map(Number);
	  #const cell = this.getCell(x, y);
	  #
	  #if (cell) {
		#cell.update(deltaTime);
		#
		#// Check if cell is no longer active
		#if (cell.dimensionalState["2D"].state !== "active") {
		  #this.activeNodes.delete(coordStr);
		#}
	  #} else {
		#this.activeNodes.delete(coordStr);
	  #}
	#}
	#
	#// Check for new patterns occasionally (not every frame)
	#if (Math.random() < 0.05) {
	  #const patterns = this.findPatterns();
	  #if (patterns.length > 0) {
		#// Activate a random pattern
		#const randomPattern = patterns[Math.floor(Math.random() * patterns.length)];
		#this.activatePattern(randomPattern);
	  #}
	#}
  #}
#}
#
#// Repository for storing captured elements
#class Repository {
  #constructor() {
	#this.items = new Map();
	#this.categories = {
	  #"word": new Set(),
	  #"thought": new Set(),
	  #"message": new Set(),
	  #"event": new Set(),
	  #"realization": new Set()
	#};
  #}
  #
  #add(happening) {
	#this.items.set(happening.id, happening);
	#
	#if (this.categories[happening.type]) {
	  #this.categories[happening.type].add(happening.id);
	#} else {
	  #this.categories[happening.type] = new Set([happening.id]);
	#}
	#
	#return happening.id;
  #}
  #
  #get(id) {
	#return this.items.get(id);
  #}
  #
  #getByType(type) {
	#if (!this.categories[type]) return [];
	#
	#return Array.from(this.categories[type])
	  #.map(id => this.items.get(id))
	  #.filter(item => item !== undefined);
  #}
  #
  #remove(id) {
	#const item = this.items.get(id);
	#if (!item) return false;
	#
	#this.items.delete(id);
	#if (this.categories[item.type]) {
	  #this.categories[item.type].delete(id);
	#}
	#
	#return true;
  #}
  #
  #search(query) {
	#const results = [];
	#
	#for (const item of this.items.values()) {
	  #if (item.content.toLowerCase().includes(query.toLowerCase())) {
		#results.push(item);
	  #}
	#}
	#
	#return results;
  #}
  #
  #getStats() {
	#const stats = {
	  #totalItems: this.items.size,
	  #byType: {}
	#};
	#
	#for (const [type, ids] of Object.entries(this.categories)) {
	  #stats.byType[type] = ids.size;
	#}
	#
	#return stats;
  #}
#}
#
#// Combination Engine for merging elements
#class CombinationEngine {
  #constructor(repository) {
	#this.repository = repository;
	#this.rules = this.initializeRules();
	#this.history = [];
  #}
  #
  #initializeRules() {
	#return [
	  #// Words combinations
	  #{
		#types: ["word", "word"],
		#validator: (a, b) => true, // Any two words can combine
		#resultType: "phrase",
		#process: (a, b) => new Happening(
		  #"phrase", 
		  #`${a.content} ${b.content}`, 
		  #"combination"
		#)
	  #},
	  #
	  #// Word + Thought
	  #{
		#types: ["word", "thought"],
		#validator: (a, b) => true,
		#resultType: "message",
		#process: (a, b) => new Happening(
		  #"message", 
		  #`The word "${a.content}" enriches the thought: ${b.content}`, 
		  #"combination"
		#)
	  #},
	  #
	  #// Message combinations
	  #{
		#types: ["message", "message"],
		#validator: (a, b) => a.id !== b.id, // Different messages
		#resultType: "conversation",
		#process: (a, b) => new Happening(
		  #"conversation", 
		  #`First message: "${a.content}"\nResponse: "${b.content}"`, 
		  #"dialogue"
		#)
	  #},
	  #
	  #// Thought combinations
	  #{
		#types: ["thought", "thought"],
		#validator: (a, b) => a.id !== b.id,
		#resultType: "realization",
		#process: (a, b) => new Happening(
		  #"realization", 
		  #`Connecting ${a.content} with ${b.content} leads to a new understanding`, 
		  #"insight"
		#)
	  #},
	  #
	  #// Event interactions
	  #{
		#types: ["event", "thought"],
		#validator: (a, b) => true,
		#resultType: "interpretation",
		#process: (a, b) => new Happening(
		  #"interpretation", 
		  #`The event "${a.content}" is seen through the lens of "${b.content}"`, 
		  #"perspective"
		#)
	  #}
	#];
  #}
  #
  #findCompatibleRules(typeA, typeB) {
	#return this.rules.filter(rule => 
	  #(rule.types[0] === typeA && rule.types[1] === typeB) ||
	  #(rule.types[0] === typeB && rule.types[1] === typeA)
	#);
  #}
  #
  #attemptCombination(elementA, elementB) {
	#if (!elementA || !elementB) return null;
	#
	#// Find applicable rules
	#const applicableRules = this.findCompatibleRules(elementA.type, elementB.type);
	#
	#// No rules found
	#if (applicableRules.length === 0) {
	  #return null;
	#}
	#
	#// Try each rule
	#for (const rule of applicableRules) {
	  #// Make sure arguments are in the right order
	  #const a = rule.types[0] === elementA.type ? elementA : elementB;
	  #const b = rule.types[1] === elementB.type ? elementB : elementA;
	  #
	  #if (rule.validator(a, b)) {
		#const result = rule.process(a, b);
		#
		#// Connect the new result to its components
		#result.connect(elementA, 0.8, 0.9);
		#result.connect(elementB, 0.8, 0.9);
		#
		#// Log the combination
		#this.history.push({
		  #timestamp: Date.now(),
		  #components: [elementA.id, elementB.id],
		  #result: result.id,
		  #rule: rule.resultType
		#});
		#
		#// Add to repository
		#this.repository.add(result);
		#
		#return result;
	  #}
	#}
	#
	#return null; // No valid combination found
  #}
  #
  #suggestCombinations(element) {
	#if (!element) return [];
	#
	#const suggestions = [];
	#const allItems = Array.from(this.repository.items.values());
	#
	#for (const item of allItems) {
	  #if (item.id === element.id) continue;
	  #
	  #const compatibleRules = this.findCompatibleRules(element.type, item.type);
	  #if (compatibleRules.length > 0) {
		#suggestions.push({
		  #item: item,
		  #compatibility: compatibleRules.some(rule => rule.validator(element, item)) ? "high" : "low",
		  #resultType: compatibleRules[0].resultType
		#});
	  #}
	#}
	#
	#// Sort by compatibility
	#return suggestions.sort((a, b) => 
	  #a.compatibility === "high" && b.compatibility !== "high" ? -1 : 1
	#);
  #}
#}
#
#// Game system to coordinate all components
#class DimensionalHappeningsGame {
  #constructor(settings = {}) {
	#this.settings = Object.assign({
	  #gridWidth: 20,
	  #gridHeight: 20,
	  #initialHappenings: 10
	#}, settings);
	#
	#this.repository = new Repository();
	#this.grid = new EventGrid(this.settings.gridWidth, this.settings.gridHeight);
	#this.combinationEngine = new CombinationEngine(this.repository);
	#
	#this.activeDimension = "1D"; // Current view dimension
	#this.lastUpdateTime = 0;
	#this.isRunning = false;
	#
	#// Metrics
	#this.metrics = {
	  #happeningsCreated: 0,
	  #combinationsPerformed: 0,
	  #patternsFound: 0,
	  #dominoEffectsTriggered: 0
	#};
  #}
  #
  #initialize() {
	#// Create initial happenings
	#const initialTypes = ["word", "thought", "message", "event"];
	#const initialContents = [
	  #"beginning", "connection", "pattern", "observe",
	  #"dimension", "flow", "cascade", "emergence",
	  #"ripple", "transform", "sequence", "point"
	#];
	#
	#for (let i = 0; i < this.settings.initialHappenings; i++) {
	  #const type = initialTypes[Math.floor(Math.random() * initialTypes.length)];
	  #const content = initialContents[Math.floor(Math.random() * initialContents.length)];
	  #
	  #const happening = new Happening(type, content, "initialization");
	  #this.repository.add(happening);
	  #this.metrics.happeningsCreated++;
	  #
	  #// Place some happenings on the grid
	  #if (Math.random() < 0.7) {
		#const x = Math.floor(Math.random() * this.settings.gridWidth);
		#const y = Math.floor(Math.random() * this.settings.gridHeight);
		#this.grid.setCell(x, y, happening);
	  #}
	#}
	#
	#// Create initial connections
	#const items = Array.from(this.repository.items.values());
	#for (let i = 0; i < items.length; i++) {
	  #const source = items[i];
	  #
	  #// Connect to 1-3 random other items
	  #const connectionCount = Math.floor(Math.random() * 3) + 1;
	  #for (let j = 0; j < connectionCount; j++) {
		#const targetIndex = Math.floor(Math.random() * items.length);
		#if (targetIndex !== i) {
		  #const target = items[targetIndex];
		  #const strength = 0.3 + Math.random() * 0.5;
		  #const probability = 0.5 + Math.random() * 0.3;
		  #source.connect(target, strength, probability);
		#}
	  #}
	#}
	#
	#this.lastUpdateTime = Date.now();
	#this.isRunning = true;
	#
	#return this;
  #}
  #
  #update() {
	#if (!this.isRunning) return;
	#
	#const currentTime = Date.now();
	#const deltaTime = (currentTime - this.lastUpdateTime) / 1000; // Convert to seconds
	#this.lastUpdateTime = currentTime;
	#
	#// Update grid state
	#this.grid.update(deltaTime);
	#
	#// Update all happenings in repository
	#for (const happening of this.repository.items.values()) {
	  #happening.update(deltaTime);
	#}
	#
	#// Occasionally trigger random events
	#if (Math.random() < 0.01) {
	  #this.triggerRandomEvent();
	#}
  #}
  #
  #triggerRandomEvent() {
	#const items = Array.from(this.repository.items.values());
	#if (items.length === 0) return;
	#
	#const randomItem = items[Math.floor(Math.random() * items.length)];
	#randomItem.activate({ impact: 1 + Math.random() * 2 });
	#
	#this
