/**
 * Phase Manager System
 * Turn 4 (Temporal Flow) - 12 Turns Word Game
 * 
 * Manages turn phases, stores historical state, and enables evolution
 * through file management and connection creation.
 */

class PhaseManager {
    constructor(basePath = "/mnt/c/Users/Percision 15/12_turns_system") {
        this.basePath = basePath;
        this.currentTurn = 4; // Current turn (Temporal Flow)
        this.phases = [];
        this.turnSymbols = ['α', 'β', 'γ', 'δ', 'ε', 'ζ', 'η', 'θ', 'ι', 'κ', 'λ', 'μ'];
        this.turnNames = [
            "Genesis", "Formation", "Complexity", "Consciousness", 
            "Awakening", "Enlightenment", "Manifestation", "Connection", 
            "Harmony", "Transcendence", "Unity", "Beyond"
        ];
        this.fileConnections = new Map();
        this.phaseHistory = [];
        this.evolutionPaths = [];
        this.consoleCommands = new Map();
    }

    /**
     * Initialize the phase manager
     */
    initialize() {
        console.log("Initializing Phase Manager in Turn 4 (Temporal Flow)");
        
        // Initialize phases array with default data
        for (let i = 0; i < 12; i++) {
            const phaseNumber = i + 1;
            this.phases.push({
                number: phaseNumber,
                name: this.turnNames[i],
                symbol: this.turnSymbols[i],
                dimension: `${phaseNumber}D`,
                activated: phaseNumber <= this.currentTurn,
                completed: phaseNumber < this.currentTurn,
                files: [],
                commands: []
            });
        }
        
        // Register console commands for turn management
        this.registerConsoleCommand("turn", {
            description: "Display or change current turn",
            usage: "turn [number]",
            example: "turn 5",
            handler: (args) => this.handleTurnCommand(args)
        });
        
        this.registerConsoleCommand("phase", {
            description: "Display phase information",
            usage: "phase [number]",
            example: "phase 4",
            handler: (args) => this.handlePhaseCommand(args)
        });
        
        this.registerConsoleCommand("history", {
            description: "Display turn history",
            usage: "history [limit]",
            example: "history 5",
            handler: (args) => this.handleHistoryCommand(args)
        });
        
        this.registerConsoleCommand("evolve", {
            description: "Evolve game to next phase",
            usage: "evolve [component]",
            example: "evolve files",
            handler: (args) => this.handleEvolveCommand(args)
        });
        
        this.registerConsoleCommand("stitch", {
            description: "Connect files across turns",
            usage: "stitch <source_file> <target_file>",
            example: "stitch turn_3/data.js turn_4/system.js",
            handler: (args) => this.handleStitchCommand(args)
        });
        
        this.registerConsoleCommand("update", {
            description: "Update game components",
            usage: "update <component>",
            example: "update all",
            handler: (args) => this.handleUpdateCommand(args)
        });
        
        // Load existing phase history
        this.loadPhaseHistory();
        
        // Scan for files in each turn directory
        this.scanTurnFiles();
        
        // Create evolution paths
        this.createEvolutionPaths();
        
        return {
            currentTurn: this.currentTurn,
            phaseName: this.phases[this.currentTurn - 1].name,
            phaseSymbol: this.phases[this.currentTurn - 1].symbol,
            commandsRegistered: this.consoleCommands.size,
            status: "initialized"
        };
    }
    
    /**
     * Register a console command
     */
    registerConsoleCommand(name, config) {
        this.consoleCommands.set(name, {
            name: name,
            description: config.description || "No description provided",
            usage: config.usage || name,
            example: config.example || name,
            handler: config.handler || (() => ({ error: "No handler defined" }))
        });
        
        console.log(`Console command registered: ${name}`);
        
        return this.consoleCommands.get(name);
    }
    
    /**
     * Handle the 'turn' command
     */
    handleTurnCommand(args = []) {
        if (args.length === 0) {
            // Display current turn
            return {
                turn: this.currentTurn,
                name: this.phases[this.currentTurn - 1].name,
                symbol: this.phases[this.currentTurn - 1].symbol,
                dimension: `${this.currentTurn}D`,
                completed: false
            };
        }
        
        // Change turn if number provided
        const newTurn = parseInt(args[0]);
        if (isNaN(newTurn) || newTurn < 1 || newTurn > 12) {
            return {
                error: "Invalid turn number. Must be between 1 and 12."
            };
        }
        
        // Record turn change in history
        this.recordTurnChange(this.currentTurn, newTurn);
        
        // Update current turn
        this.currentTurn = newTurn;
        
        // Update phase status
        for (let i = 0; i < 12; i++) {
            const phaseNumber = i + 1;
            this.phases[i].activated = phaseNumber <= this.currentTurn;
            this.phases[i].completed = phaseNumber < this.currentTurn;
        }
        
        return {
            message: `Turn changed to ${newTurn}: ${this.phases[newTurn - 1].name} (${this.phases[newTurn - 1].symbol})`,
            dimension: `${newTurn}D`,
            symbol: this.phases[newTurn - 1].symbol
        };
    }
    
    /**
     * Handle the 'phase' command
     */
    handlePhaseCommand(args = []) {
        let phaseNumber = this.currentTurn;
        
        if (args.length > 0) {
            phaseNumber = parseInt(args[0]);
            if (isNaN(phaseNumber) || phaseNumber < 1 || phaseNumber > 12) {
                return {
                    error: "Invalid phase number. Must be between 1 and 12."
                };
            }
        }
        
        const phase = this.phases[phaseNumber - 1];
        
        return {
            phase: phaseNumber,
            name: phase.name,
            symbol: phase.symbol,
            dimension: `${phaseNumber}D`,
            activated: phase.activated,
            completed: phase.completed,
            fileCount: phase.files.length,
            commandCount: phase.commands.length
        };
    }
    
    /**
     * Handle the 'history' command
     */
    handleHistoryCommand(args = []) {
        let limit = 10; // Default limit
        
        if (args.length > 0) {
            limit = parseInt(args[0]);
            if (isNaN(limit) || limit < 1) {
                limit = 10;
            }
        }
        
        // Return limited history
        return {
            history: this.phaseHistory.slice(-limit),
            count: Math.min(this.phaseHistory.length, limit),
            total: this.phaseHistory.length
        };
    }
    
    /**
     * Handle the 'evolve' command
     */
    handleEvolveCommand(args = []) {
        let component = "all";
        
        if (args.length > 0) {
            component = args[0].toLowerCase();
        }
        
        switch (component) {
            case "files":
                return this.evolveFiles();
            case "commands":
                return this.evolveCommands();
            case "connections":
                return this.evolveConnections();
            case "all":
                const filesResult = this.evolveFiles();
                const commandsResult = this.evolveCommands();
                const connectionsResult = this.evolveConnections();
                
                return {
                    message: "Game evolved successfully",
                    components: {
                        files: filesResult,
                        commands: commandsResult,
                        connections: connectionsResult
                    }
                };
            default:
                return {
                    error: `Unknown component: ${component}. Valid options: files, commands, connections, all`
                };
        }
    }
    
    /**
     * Handle the 'stitch' command
     */
    handleStitchCommand(args = []) {
        if (args.length < 2) {
            return {
                error: "Stitch command requires source and target file paths"
            };
        }
        
        const sourceFile = args[0];
        const targetFile = args[1];
        
        // Create connection between files
        return this.createFileConnection(sourceFile, targetFile);
    }
    
    /**
     * Handle the 'update' command
     */
    handleUpdateCommand(args = []) {
        let component = "all";
        
        if (args.length > 0) {
            component = args[0].toLowerCase();
        }
        
        switch (component) {
            case "files":
                return this.updateFiles();
            case "system":
                return this.updateSystem();
            case "connections":
                return this.updateConnections();
            case "all":
                const filesResult = this.updateFiles();
                const systemResult = this.updateSystem();
                const connectionsResult = this.updateConnections();
                
                return {
                    message: "Game updated successfully",
                    components: {
                        files: filesResult,
                        system: systemResult,
                        connections: connectionsResult
                    }
                };
            default:
                return {
                    error: `Unknown component: ${component}. Valid options: files, system, connections, all`
                };
        }
    }
    
    /**
     * Record a turn change in history
     */
    recordTurnChange(fromTurn, toTurn) {
        const timestamp = new Date();
        
        const historyEntry = {
            type: "turn_change",
            fromTurn: fromTurn,
            toTurn: toTurn,
            fromName: this.phases[fromTurn - 1].name,
            toName: this.phases[toTurn - 1].name,
            fromSymbol: this.phases[fromTurn - 1].symbol,
            toSymbol: this.phases[toTurn - 1].symbol,
            timestamp: timestamp,
            files: {
                fromCount: this.phases[fromTurn - 1].files.length,
                toCount: this.phases[toTurn - 1].files.length
            }
        };
        
        this.phaseHistory.push(historyEntry);
        
        // Save history to file
        this.savePhaseHistory();
        
        return historyEntry;
    }
    
    /**
     * Save phase history to file
     */
    savePhaseHistory() {
        const fs = require('fs');
        const path = require('path');
        
        const historyPath = path.join(this.basePath, `turn_${this.currentTurn}/data/phase_history.json`);
        
        try {
            // Ensure directory exists
            const dirPath = path.dirname(historyPath);
            if (!fs.existsSync(dirPath)) {
                fs.mkdirSync(dirPath, { recursive: true });
            }
            
            fs.writeFileSync(historyPath, JSON.stringify({
                current_turn: this.currentTurn,
                history: this.phaseHistory,
                updated: new Date()
            }, null, 2));
            
            console.log(`Phase history saved to ${historyPath}`);
            return true;
        } catch (error) {
            console.error(`Error saving phase history: ${error.message}`);
            return false;
        }
    }
    
    /**
     * Load phase history from file
     */
    loadPhaseHistory() {
        const fs = require('fs');
        const path = require('path');
        
        // Try to load from current turn first
        let historyPath = path.join(this.basePath, `turn_${this.currentTurn}/data/phase_history.json`);
        
        if (!fs.existsSync(historyPath)) {
            // Try previous turn
            const prevTurn = this.currentTurn - 1;
            if (prevTurn >= 1) {
                historyPath = path.join(this.basePath, `turn_${prevTurn}/data/phase_history.json`);
            }
        }
        
        if (fs.existsSync(historyPath)) {
            try {
                const historyData = JSON.parse(fs.readFileSync(historyPath, 'utf8'));
                this.phaseHistory = historyData.history || [];
                console.log(`Loaded ${this.phaseHistory.length} history entries from ${historyPath}`);
                return true;
            } catch (error) {
                console.error(`Error loading phase history: ${error.message}`);
                this.phaseHistory = [];
                return false;
            }
        } else {
            console.log("No existing phase history found. Starting with empty history.");
            this.phaseHistory = [];
            return false;
        }
    }
    
    /**
     * Scan for files in each turn directory
     */
    scanTurnFiles() {
        const fs = require('fs');
        const path = require('path');
        
        // For each turn
        for (let i = 0; i < 12; i++) {
            const turnNumber = i + 1;
            const turnPath = path.join(this.basePath, `turn_${turnNumber}`);
            
            if (fs.existsSync(turnPath)) {
                const files = this.scanDirectory(turnPath);
                this.phases[i].files = files;
                console.log(`Found ${files.length} files for Turn ${turnNumber}`);
            }
        }
    }
    
    /**
     * Recursively scan a directory for files
     */
    scanDirectory(dirPath, relativePath = '') {
        const fs = require('fs');
        const path = require('path');
        
        if (!fs.existsSync(dirPath)) {
            return [];
        }
        
        let files = [];
        
        const entries = fs.readdirSync(dirPath, { withFileTypes: true });
        
        for (const entry of entries) {
            const entryPath = path.join(dirPath, entry.name);
            const entryRelativePath = path.join(relativePath, entry.name);
            
            if (entry.isDirectory()) {
                // Recursively scan subdirectory
                const subDirFiles = this.scanDirectory(entryPath, entryRelativePath);
                files = files.concat(subDirFiles);
            } else if (entry.isFile()) {
                // Add file to list
                files.push({
                    name: entry.name,
                    path: entryPath,
                    relativePath: entryRelativePath,
                    extension: path.extname(entry.name),
                    size: fs.statSync(entryPath).size,
                    updated: fs.statSync(entryPath).mtime
                });
            }
        }
        
        return files;
    }
    
    /**
     * Create a connection between two files
     */
    createFileConnection(sourceFile, targetFile) {
        const fs = require('fs');
        const path = require('path');
        
        // Build full paths if not already
        let sourcePath = sourceFile;
        if (!sourcePath.startsWith('/')) {
            sourcePath = path.join(this.basePath, sourceFile);
        }
        
        let targetPath = targetFile;
        if (!targetPath.startsWith('/')) {
            targetPath = path.join(this.basePath, targetFile);
        }
        
        // Check if files exist
        if (!fs.existsSync(sourcePath)) {
            return {
                error: `Source file not found: ${sourceFile}`
            };
        }
        
        // Create target directory if needed
        const targetDir = path.dirname(targetPath);
        if (!fs.existsSync(targetDir)) {
            try {
                fs.mkdirSync(targetDir, { recursive: true });
            } catch (error) {
                return {
                    error: `Failed to create target directory: ${error.message}`
                };
            }
        }
        
        // Create connection ID
        const connectionId = `${sourceFile}->${targetFile}`;
        
        // Record connection
        this.fileConnections.set(connectionId, {
            source: sourceFile,
            target: targetFile,
            created: new Date(),
            sourceTurn: this.extractTurnFromPath(sourceFile),
            targetTurn: this.extractTurnFromPath(targetFile)
        });
        
        console.log(`File connection created: ${connectionId}`);
        
        // If target doesn't exist, create a reference file
        if (!fs.existsSync(targetPath)) {
            try {
                // Create a reference file that imports/requires the source
                const fileExtension = path.extname(targetPath);
                let referenceContent = '';
                
                if (fileExtension === '.js') {
                    // JavaScript reference
                    const relativePath = path.relative(path.dirname(targetPath), sourcePath);
                    referenceContent = `/**
 * File created by 12 Turns Phase Manager (Turn ${this.currentTurn})
 * Connection to: ${sourceFile}
 * Created: ${new Date().toISOString()}
 */

// Import connected file
const sourceModule = require('${relativePath}');

// Re-export with enhancements
module.exports = {
  ...sourceModule,
  
  // Enhanced properties for current turn
  _turn: ${this.currentTurn},
  _turnName: "${this.phases[this.currentTurn - 1].name}",
  _turnSymbol: "${this.phases[this.currentTurn - 1].symbol}",
  _connectionId: "${connectionId}",
  _sourceFile: "${sourceFile}",
  
  // Enhanced methods
  getConnectionInfo() {
    return {
      source: "${sourceFile}",
      target: "${targetFile}",
      created: "${new Date().toISOString()}",
      turn: ${this.currentTurn}
    };
  },
  
  // Add turn-specific enhancements
  ${this.currentTurn === 4 ? '// Turn 4 (Temporal Flow) enhancements\ntimeTravel(state) { return { past: state, present: state, future: state }; },' : ''}
  ${this.currentTurn === 5 ? '// Turn 5 (Probability Waves) enhancements\nquantumState(options) { return options[Math.floor(Math.random() * options.length)]; },' : ''}
  ${this.currentTurn === 6 ? '// Turn 6 (Phase Resonance) enhancements\nresonateWith(pattern) { return { frequency: pattern.length, amplitude: pattern.split("").reduce((a, b) => a + b.charCodeAt(0), 0) / 100 }; },' : ''}
};
`;
                } else if (fileExtension === '.json') {
                    // JSON reference
                    referenceContent = JSON.stringify({
                        _connection: {
                            source: sourceFile,
                            target: targetFile,
                            created: new Date().toISOString(),
                            turn: this.currentTurn,
                            turnName: this.phases[this.currentTurn - 1].name,
                            turnSymbol: this.phases[this.currentTurn - 1].symbol
                        },
                        _sourceReference: true,
                        _importSource: `require('${sourceFile}')`
                    }, null, 2);
                } else {
                    // Text reference for other file types
                    referenceContent = `# File created by 12 Turns Phase Manager (Turn ${this.currentTurn})
# Connection to: ${sourceFile}
# Created: ${new Date().toISOString()}

# This file references content from ${sourceFile}
# Turn: ${this.currentTurn} (${this.phases[this.currentTurn - 1].name} - ${this.phases[this.currentTurn - 1].symbol})

SOURCE_FILE="${sourceFile}"
TARGET_FILE="${targetFile}"
CONNECTION_ID="${connectionId}"
`;
                }
                
                fs.writeFileSync(targetPath, referenceContent);
                console.log(`Created reference file: ${targetPath}`);
            } catch (error) {
                return {
                    error: `Failed to create reference file: ${error.message}`
                };
            }
        }
        
        return {
            message: `Files stitched successfully: ${connectionId}`,
            connection: {
                source: sourceFile,
                target: targetFile,
                created: new Date(),
                sourceTurn: this.extractTurnFromPath(sourceFile),
                targetTurn: this.extractTurnFromPath(targetFile)
            }
        };
    }
    
    /**
     * Extract turn number from file path
     */
    extractTurnFromPath(filePath) {
        const turnMatch = filePath.match(/turn_(\d+)/i);
        if (turnMatch && turnMatch[1]) {
            return parseInt(turnMatch[1]);
        }
        return null;
    }
    
    /**
     * Create evolution paths
     */
    createEvolutionPaths() {
        // Define evolution paths based on current turn
        this.evolutionPaths = [
            {
                name: "File Evolution",
                description: "Evolve files from previous turns to current",
                command: "evolve files",
                previousTurn: this.currentTurn - 1,
                currentTurn: this.currentTurn,
                fileTypes: [".js", ".json", ".md"]
            },
            {
                name: "Command Evolution",
                description: "Evolve console commands to incorporate current turn abilities",
                command: "evolve commands",
                previousCommands: ["turn", "phase"],
                newCommands: ["stitch", "update"]
            },
            {
                name: "Connection Evolution",
                description: "Evolve connections between turns to enhance data flow",
                command: "evolve connections",
                connectableTurns: [this.currentTurn - 1, this.currentTurn]
            }
        ];
        
        // Add turn-specific evolution path
        switch (this.currentTurn) {
            case 4:
                this.evolutionPaths.push({
                    name: "Temporal Evolution",
                    description: "Use time dimension to evolve past files into future states",
                    command: "evolve temporal",
                    timeStates: ["past", "present", "future"]
                });
                break;
            case 5:
                this.evolutionPaths.push({
                    name: "Probability Evolution",
                    description: "Use probability to create multiple evolution paths",
                    command: "evolve probability",
                    probabilityStates: ["certain", "likely", "uncertain"]
                });
                break;
        }
        
        return this.evolutionPaths;
    }
    
    /**
     * Evolve files from previous turn to current
     */
    evolveFiles() {
        const prevTurn = this.currentTurn - 1;
        if (prevTurn < 1) {
            return {
                error: "No previous turn to evolve files from"
            };
        }
        
        const prevFiles = this.phases[prevTurn - 1].files;
        const evolved = [];
        const failed = [];
        
        // Find files to evolve (data directory files)
        for (const file of prevFiles) {
            if (file.relativePath.includes('/data/') && ['.js', '.json', '.md'].includes(file.extension)) {
                // Build target path in current turn
                const targetRelativePath = file.relativePath.replace(`turn_${prevTurn}`, `turn_${this.currentTurn}`);
                const targetFile = `turn_${this.currentTurn}/${targetRelativePath.split('/', 2)[1]}`;
                
                // Stitch the file
                const result = this.createFileConnection(`turn_${prevTurn}/${file.relativePath}`, targetFile);
                
                if (result.error) {
                    failed.push({
                        source: `turn_${prevTurn}/${file.relativePath}`,
                        target: targetFile,
                        reason: result.error
                    });
                } else {
                    evolved.push({
                        source: `turn_${prevTurn}/${file.relativePath}`,
                        target: targetFile
                    });
                }
            }
        }
        
        return {
            message: `Evolved ${evolved.length} files from Turn ${prevTurn} to Turn ${this.currentTurn}`,
            evolved: evolved,
            failed: failed
        };
    }
    
    /**
     * Evolve commands for current turn
     */
    evolveCommands() {
        // Add turn-specific commands to current phase
        const currentPhase = this.phases[this.currentTurn - 1];
        
        switch (this.currentTurn) {
            case 4:
                // Add temporal commands
                currentPhase.commands.push("timeflow", "temporal", "echo");
                break;
            case 5:
                // Add probability commands
                currentPhase.commands.push("quantum", "probability", "wave");
                break;
            case 6:
                // Add resonance commands
                currentPhase.commands.push("resonate", "amplify", "frequency");
                break;
        }
        
        return {
            message: `Commands evolved for Turn ${this.currentTurn}`,
            commands: currentPhase.commands
        };
    }
    
    /**
     * Evolve connections between turns
     */
    evolveConnections() {
        const connections = Array.from(this.fileConnections.values());
        const evolved = [];
        
        // For each existing connection
        for (const connection of connections) {
            // If connection is to a previous turn, create new connection to current turn
            if (connection.targetTurn < this.currentTurn) {
                // Create a new target in current turn
                const newTarget = connection.target.replace(`turn_${connection.targetTurn}`, `turn_${this.currentTurn}`);
                
                // Create new connection
                const result = this.createFileConnection(connection.target, newTarget);
                
                if (!result.error) {
                    evolved.push({
                        originalConnection: `${connection.source}->${connection.target}`,
                        newConnection: `${connection.target}->${newTarget}`
                    });
                }
            }
        }
        
        return {
            message: `Evolved ${evolved.length} connections to Turn ${this.currentTurn}`,
            evolved: evolved
        };
    }
    
    /**
     * Update all files for current turn
     */
    updateFiles() {
        const fs = require('fs');
        const path = require('path');
        
        // Update turn manifests
        let manifestPath = path.join(this.basePath, `turn_${this.currentTurn}/manifest.json`);
        
        try {
            if (fs.existsSync(manifestPath)) {
                // Update existing manifest
                const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
                manifest.updated = new Date().toISOString();
                fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2));
                console.log(`Updated manifest for Turn ${this.currentTurn}`);
            } else {
                // Create new manifest
                const manifest = {
                    turn: this.currentTurn,
                    created: new Date().toISOString(),
                    updated: new Date().toISOString(),
                    active: true,
                    completed: false,
                    size_limit: 1048576
                };
                
                // Ensure directory exists
                const dirPath = path.dirname(manifestPath);
                if (!fs.existsSync(dirPath)) {
                    fs.mkdirSync(dirPath, { recursive: true });
                }
                
                fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2));
                console.log(`Created manifest for Turn ${this.currentTurn}`);
            }
            
            // Rescan files to update the phase information
            this.scanTurnFiles();
            
            return {
                message: `Files updated for Turn ${this.currentTurn}`,
                fileCount: this.phases[this.currentTurn - 1].files.length
            };
        } catch (error) {
            return {
                error: `Failed to update files: ${error.message}`
            };
        }
    }
    
    /**
     * Update system components
     */
    updateSystem() {
        const fs = require('fs');
        const path = require('path');
        
        // Update current_turn.txt
        const turnFilePath = path.join(this.basePath, 'current_turn.txt');
        
        try {
            fs.writeFileSync(turnFilePath, this.currentTurn.toString());
            console.log(`Updated current_turn.txt to ${this.currentTurn}`);
            
            return {
                message: `System updated to Turn ${this.currentTurn}`,
                turn: this.currentTurn,
                name: this.phases[this.currentTurn - 1].name,
                symbol: this.phases[this.currentTurn - 1].symbol
            };
        } catch (error) {
            return {
                error: `Failed to update system: ${error.message}`
            };
        }
    }
    
    /**
     * Update connections
     */
    updateConnections() {
        const updatedConnections = [];
        
        // For each connection
        for (const [id, connection] of this.fileConnections.entries()) {
            // Check if files still exist and update metadata
            connection.lastChecked = new Date();
            connection.isValid = true; // Assume valid for now
            
            updatedConnections.push({
                id: id,
                source: connection.source,
                target: connection.target,
                lastChecked: connection.lastChecked
            });
        }
        
        return {
            message: `Updated ${updatedConnections.length} connections`,
            connections: updatedConnections
        };
    }
    
    /**
     * Get available console commands
     */
    getConsoleCommands() {
        return Array.from(this.consoleCommands.entries()).map(([name, command]) => ({
            name: name,
            description: command.description,
            usage: command.usage,
            example: command.example
        }));
    }
    
    /**
     * Execute a console command
     */
    executeConsoleCommand(commandLine) {
        // Parse command line
        const parts = commandLine.trim().split(/\s+/);
        const commandName = parts[0];
        const args = parts.slice(1);
        
        if (!this.consoleCommands.has(commandName)) {
            return {
                error: `Unknown command: ${commandName}`,
                availableCommands: Array.from(this.consoleCommands.keys())
            };
        }
        
        const command = this.consoleCommands.get(commandName);
        return command.handler(args);
    }
}

// For Node.js
if (typeof module !== 'undefined') {
    module.exports = { PhaseManager };
}

// For browser environment
if (typeof window !== 'undefined') {
    window.phaseManager = new PhaseManager();
    window.phaseManager.initialize();
}

// Self-initialization when run directly
const manager = new PhaseManager();
manager.initialize();

console.log("Phase Manager initialized for Turn 4 (Temporal Flow)");