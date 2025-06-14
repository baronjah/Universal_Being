/**
 * User Memory System - Temporal Dimension
 * Created in Turn 4 (Consciousness/Temporal Flow)
 * Stores user memory symbols and associations across time
 */

class UserMemorySystem {
    constructor() {
        this.memories = new Map();
        this.symbols = new Set();
        this.temporalLinks = new Map();
        this.whimRecords = [];
        this.consoleStates = new Map();
        this.apiStateRecords = [];
    }
    
    /**
     * Store a new memory with associated symbol
     */
    storeMemory(content, symbol = null, metadata = {}) {
        const timestamp = new Date();
        const memoryId = `memory_${timestamp.getTime()}_${Math.floor(Math.random() * 1000)}`;
        
        const memory = {
            id: memoryId,
            content: content,
            symbol: symbol,
            timestamp: timestamp,
            timeContext: metadata.timeContext || "present",
            console: metadata.console || "primary",
            apiSource: metadata.apiSource || "current",
            tags: metadata.tags || [],
            whims: []
        };
        
        // Store the memory
        this.memories.set(memoryId, memory);
        
        // Register the symbol if provided
        if (symbol) {
            this.symbols.add(symbol);
            
            // Create temporal links for this symbol
            if (\!this.temporalLinks.has(symbol)) {
                this.temporalLinks.set(symbol, {
                    past: [],
                    present: [],
                    future: []
                });
            }
            
            // Add to appropriate temporal category
            const timeContext = metadata.timeContext || "present";
            this.temporalLinks.get(symbol)[timeContext].push(memoryId);
        }
        
        console.log(`Memory stored with ID: ${memoryId}`);
        if (symbol) {
            console.log(`Associated with symbol: ${symbol}`);
        }
        
        return memoryId;
    }
    
    /**
     * Record a user whim (random focus of attention)
     */
    recordWhim(focus, intensity = 0.5, metadata = {}) {
        const timestamp = new Date();
        const whimId = `whim_${timestamp.getTime()}_${Math.floor(Math.random() * 1000)}`;
        
        const whim = {
            id: whimId,
            focus: focus,
            intensity: intensity,
            timestamp: timestamp,
            duration: metadata.duration || "unknown",
            associatedMemories: [],
            timeContext: metadata.timeContext || "present"
        };
        
        // Store the whim
        this.whimRecords.push(whim);
        
        console.log(`Whim recorded: ${focus} (intensity: ${intensity})`);
        
        return whimId;
    }
    
    /**
     * Record console state
     */
    recordConsoleState(consoleName, state, metadata = {}) {
        const timestamp = new Date();
        const stateRecord = {
            console: consoleName,
            state: state,
            timestamp: timestamp,
            apiConnected: metadata.apiConnected || false,
            visible: metadata.visible || true
        };
        
        // Store console state
        if (\!this.consoleStates.has(consoleName)) {
            this.consoleStates.set(consoleName, []);
        }
        
        this.consoleStates.get(consoleName).push(stateRecord);
        
        console.log(`Console state recorded for: ${consoleName}`);
        
        return stateRecord;
    }
    
    /**
     * Record API state
     */
    recordApiState(apiName, state, metadata = {}) {
        const timestamp = new Date();
        const apiRecord = {
            api: apiName,
            state: state,
            timestamp: timestamp,
            endpoint: metadata.endpoint || "default",
            responseCode: metadata.responseCode || 200,
            latency: metadata.latency || 0
        };
        
        // Store API state
        this.apiStateRecords.push(apiRecord);
        
        console.log(`API state recorded for: ${apiName}`);
        
        return apiRecord;
    }
    
    /**
     * Retrieve memories by symbol
     */
    getMemoriesBySymbol(symbol, timeContext = null) {
        if (\!this.symbols.has(symbol)) {
            return [];
        }
        
        const memoryIds = [];
        
        if (timeContext) {
            // Only get memories from specific time context
            if (this.temporalLinks.has(symbol) && 
                this.temporalLinks.get(symbol)[timeContext]) {
                memoryIds.push(...this.temporalLinks.get(symbol)[timeContext]);
            }
        } else {
            // Get all memories for this symbol
            if (this.temporalLinks.has(symbol)) {
                const links = this.temporalLinks.get(symbol);
                memoryIds.push(...links.past, ...links.present, ...links.future);
            }
        }
        
        // Retrieve all memory objects
        return memoryIds
            .map(id => this.memories.get(id))
            .filter(mem => mem \!== undefined);
    }
    
    /**
     * Get all recorded whims
     */
    getAllWhims() {
        return [...this.whimRecords];
    }
    
    /**
     * Get all console states
     */
    getConsoleStates(consoleName = null) {
        if (consoleName) {
            return this.consoleStates.get(consoleName) || [];
        }
        
        // Return all console states
        const allStates = [];
        for (const states of this.consoleStates.values()) {
            allStates.push(...states);
        }
        
        return allStates;
    }
    
    /**
     * Get all registered symbols
     */
    getAllSymbols() {
        return [...this.symbols];
    }
    
    /**
     * Link memory to another memory
     */
    linkMemories(sourceMemoryId, targetMemoryId, linkType = "association") {
        const sourceMemory = this.memories.get(sourceMemoryId);
        const targetMemory = this.memories.get(targetMemoryId);
        
        if (\!sourceMemory || \!targetMemory) {
            console.error("Cannot link: one or both memories not found");
            return false;
        }
        
        // Create links array if it doesn't exist
        if (\!sourceMemory.links) {
            sourceMemory.links = [];
        }
        
        // Add the link
        sourceMemory.links.push({
            targetId: targetMemoryId,
            type: linkType,
            timestamp: new Date()
        });
        
        console.log(`Linked memories: ${sourceMemoryId} -> ${targetMemoryId} (${linkType})`);
        
        return true;
    }
    
    /**
     * Create a memory selection for Core 1
     */
    createSelectionForCore1(symbol = null, count = 5) {
        let selectedMemories;
        
        if (symbol) {
            // Get memories by symbol
            selectedMemories = this.getMemoriesBySymbol(symbol);
        } else {
            // Get most recent memories
            selectedMemories = Array.from(this.memories.values());
        }
        
        // Sort by timestamp (newest first) and take requested count
        return selectedMemories
            .sort((a, b) => b.timestamp - a.timestamp)
            .slice(0, count);
    }
}

// Export for Node.js
if (typeof module \!== 'undefined') {
    module.exports = { UserMemorySystem };
}

// For browser environment
if (typeof window \!== 'undefined') {
    window.userMemorySystem = new UserMemorySystem();
}

console.log("User Memory System initialized in Turn 4 (Temporal Dimension)");
