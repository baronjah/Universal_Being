/**
 * Command & API Connection System
 * Turn 4 (Temporal Flow) - 12 Turns Word Game
 * 
 * Maps terminal commands to API endpoints and manages cross-system integration
 */

class CommandApiConnector {
    constructor() {
        this.commands = new Map();
        this.apis = new Map();
        this.connections = new Map();
        this.terminals = new Map();
        this.luckyNumbers = [4, 7, 8]; // Lucky numbers for enhanced connections
        this.symbolConnections = new Map();
    }

    /**
     * Initialize the connector system with default settings
     */
    initialize() {
        console.log("Initializing Command API Connector in Turn 4 (Temporal Flow)");
        
        // Set up core commands
        this.registerCommand("claude", {
            description: "Activate Claude AI in terminal",
            terminalType: "primary",
            apiTarget: "claude",
            powerLevel: 75,
            luckyNumber: 4,
            symbol: "JSH"
        });
        
        this.registerCommand("operate", {
            description: "Control system operations across terminals",
            terminalType: "multi",
            apiTarget: "operation_controller",
            powerLevel: 70,
            luckyNumber: 7,
            symbol: "⚡"
        });
        
        // Set up NPM/Node connections
        this.registerCommand("npm", {
            description: "Node package manager for JavaScript",
            terminalType: "development",
            apiTarget: "node",
            powerLevel: 65,
            luckyNumber: 8,
            symbol: "🔄"
        });
        
        this.registerCommand("node", {
            description: "Execute JavaScript runtime",
            terminalType: "development",
            apiTarget: "node",
            powerLevel: 65,
            luckyNumber: 8,
            symbol: "🔄"
        });
        
        // Register APIs
        this.registerApi("claude", {
            endpoint: "https://api.anthropic.com",
            version: "v1",
            authType: "key",
            modelType: "claude-3-opus-20240229",
            responseFormat: "json",
            symbols: ["JSH", "⌛", "🧠"]
        });
        
        this.registerApi("openai", {
            endpoint: "https://api.openai.com",
            version: "v1",
            authType: "key",
            modelType: "gpt-4o",
            responseFormat: "json",
            symbols: ["JSH", "∞", "⚡"]
        });
        
        this.registerApi("node", {
            endpoint: "local://nodejs",
            version: "v18+",
            authType: "none",
            runtime: "javascript",
            responseFormat: "any",
            symbols: ["🔄", "📊"]
        });
        
        this.registerApi("operation_controller", {
            endpoint: "local://system",
            version: "current",
            authType: "system",
            controlLevel: "elevated",
            responseFormat: "terminal",
            symbols: ["⚡", "🔑"]
        });
        
        // Register terminals
        this.registerTerminal("Core 1", {
            type: "primary",
            commands: ["claude", "operate", "npm", "node"],
            apis: ["claude", "node", "operation_controller"],
            active: true,
            luckyNumber: 4,
            symbols: ["JSH", "⌛", "🧠"]
        });
        
        this.registerTerminal("Core 0", {
            type: "secondary",
            commands: ["operate", "npm", "node"],
            apis: ["openai", "node", "operation_controller"],
            active: true,
            luckyNumber: 7,
            symbols: ["JSH", "∞", "⚡"]
        });
        
        this.registerTerminal("Dev Terminal", {
            type: "development",
            commands: ["npm", "node"],
            apis: ["node"],
            active: true,
            luckyNumber: 8,
            symbols: ["🔄", "📊"]
        });
        
        // Create connections between commands and APIs
        this.connectCommandToApi("claude", "claude");
        this.connectCommandToApi("operate", "operation_controller");
        this.connectCommandToApi("npm", "node");
        this.connectCommandToApi("node", "node");
        
        // Connect lucky numbers to symbols
        this.connectLuckyNumberToSymbol(4, "JSH");
        this.connectLuckyNumberToSymbol(7, "⚡");
        this.connectLuckyNumberToSymbol(8, "🔄");
        this.connectLuckyNumberToSymbol(4, "⌛");
        
        console.log("Command API Connector initialized with:");
        console.log(`- ${this.commands.size} commands`);
        console.log(`- ${this.apis.size} APIs`);
        console.log(`- ${this.terminals.size} terminals`);
        console.log(`- ${this.luckyNumbers.length} lucky numbers`);
        
        return {
            status: "initialized",
            commands: Array.from(this.commands.keys()),
            apis: Array.from(this.apis.keys()),
            terminals: Array.from(this.terminals.keys())
        };
    }
    
    /**
     * Register a terminal command
     */
    registerCommand(name, config) {
        this.commands.set(name, {
            name: name,
            description: config.description || "No description provided",
            terminalType: config.terminalType || "any",
            apiTarget: config.apiTarget || null,
            powerLevel: config.powerLevel || 50,
            luckyNumber: config.luckyNumber || null,
            symbol: config.symbol || null,
            registered: new Date()
        });
        
        console.log(`Command registered: ${name} (Power: ${config.powerLevel || 50})`);
        
        return this.commands.get(name);
    }
    
    /**
     * Register an API
     */
    registerApi(name, config) {
        this.apis.set(name, {
            name: name,
            endpoint: config.endpoint || "unknown",
            version: config.version || "v1",
            authType: config.authType || "none",
            responseFormat: config.responseFormat || "json",
            symbols: config.symbols || [],
            registered: new Date()
        });
        
        console.log(`API registered: ${name} (Endpoint: ${config.endpoint || "unknown"})`);
        
        return this.apis.get(name);
    }
    
    /**
     * Register a terminal
     */
    registerTerminal(name, config) {
        this.terminals.set(name, {
            name: name,
            type: config.type || "general",
            commands: config.commands || [],
            apis: config.apis || [],
            active: config.active !== undefined ? config.active : true,
            luckyNumber: config.luckyNumber || null,
            symbols: config.symbols || [],
            registered: new Date()
        });
        
        console.log(`Terminal registered: ${name} (Type: ${config.type || "general"})`);
        
        return this.terminals.get(name);
    }
    
    /**
     * Connect a command to an API
     */
    connectCommandToApi(commandName, apiName) {
        if (!this.commands.has(commandName)) {
            console.error(`Cannot connect: Command '${commandName}' not found`);
            return false;
        }
        
        if (!this.apis.has(apiName)) {
            console.error(`Cannot connect: API '${apiName}' not found`);
            return false;
        }
        
        const connectionId = `${commandName}->${apiName}`;
        this.connections.set(connectionId, {
            command: commandName,
            api: apiName,
            active: true,
            created: new Date(),
            lastUsed: null
        });
        
        console.log(`Connection established: ${commandName} -> ${apiName}`);
        
        return this.connections.get(connectionId);
    }
    
    /**
     * Connect a lucky number to a symbol
     */
    connectLuckyNumberToSymbol(number, symbol) {
        if (!this.luckyNumbers.includes(number)) {
            this.luckyNumbers.push(number);
        }
        
        if (!this.symbolConnections.has(number)) {
            this.symbolConnections.set(number, []);
        }
        
        if (!this.symbolConnections.get(number).includes(symbol)) {
            this.symbolConnections.get(number).push(symbol);
        }
        
        console.log(`Lucky number ${number} connected to symbol ${symbol}`);
        
        return this.symbolConnections.get(number);
    }
    
    /**
     * Execute a command in a specific terminal
     */
    executeCommand(commandName, terminalName, args = {}) {
        if (!this.commands.has(commandName)) {
            return {
                success: false,
                error: `Command '${commandName}' not found`
            };
        }
        
        if (!this.terminals.has(terminalName)) {
            return {
                success: false,
                error: `Terminal '${terminalName}' not found`
            };
        }
        
        const terminal = this.terminals.get(terminalName);
        if (!terminal.commands.includes(commandName)) {
            return {
                success: false,
                error: `Command '${commandName}' not available in terminal '${terminalName}'`
            };
        }
        
        const command = this.commands.get(commandName);
        let response = {
            command: commandName,
            terminal: terminalName,
            timestamp: new Date(),
            args: args
        };
        
        // Find the connected API
        if (command.apiTarget && this.apis.has(command.apiTarget)) {
            const api = this.apis.get(command.apiTarget);
            
            // Update connection usage
            const connectionId = `${commandName}->${command.apiTarget}`;
            if (this.connections.has(connectionId)) {
                const connection = this.connections.get(connectionId);
                connection.lastUsed = new Date();
            }
            
            // Apply lucky number enhancement if applicable
            let powerBoost = 1.0;
            if (command.luckyNumber && this.luckyNumbers.includes(command.luckyNumber)) {
                powerBoost = 1.0 + (command.luckyNumber / 10);
                response.luckyEffect = `Enhanced by lucky number ${command.luckyNumber}`;
                response.powerBoost = powerBoost;
            }
            
            // Apply symbol power if applicable
            if (command.symbol) {
                response.symbol = command.symbol;
                response.symbolPower = true;
            }
            
            // Success response
            response.success = true;
            response.power = Math.round(command.powerLevel * powerBoost);
            response.apiUsed = command.apiTarget;
            response.apiEndpoint = api.endpoint;
            
            console.log(`Command '${commandName}' executed in terminal '${terminalName}'`);
            console.log(`Power: ${response.power} (base: ${command.powerLevel}, boost: ${powerBoost})`);
        } else {
            // No API target
            response.success = true;
            response.power = command.powerLevel;
            response.apiUsed = null;
            
            console.log(`Command '${commandName}' executed in terminal '${terminalName}' (no API)`);
        }
        
        return response;
    }
    
    /**
     * Get all connections for a terminal
     */
    getTerminalConnections(terminalName) {
        if (!this.terminals.has(terminalName)) {
            return {
                success: false,
                error: `Terminal '${terminalName}' not found`
            };
        }
        
        const terminal = this.terminals.get(terminalName);
        const connections = [];
        
        for (const commandName of terminal.commands) {
            if (this.commands.has(commandName)) {
                const command = this.commands.get(commandName);
                if (command.apiTarget && this.apis.has(command.apiTarget)) {
                    connections.push({
                        command: commandName,
                        api: command.apiTarget,
                        lucky: command.luckyNumber,
                        symbol: command.symbol
                    });
                }
            }
        }
        
        return {
            terminal: terminalName,
            connections: connections,
            count: connections.length,
            symbols: terminal.symbols,
            luckyNumber: terminal.luckyNumber
        };
    }
    
    /**
     * Get all symbols associated with lucky numbers
     */
    getLuckySymbols() {
        const result = {};
        
        for (const [number, symbols] of this.symbolConnections.entries()) {
            result[number] = symbols;
        }
        
        return result;
    }
}

// For Node.js
if (typeof module !== 'undefined') {
    module.exports = { CommandApiConnector };
}

// For browser environment
if (typeof window !== 'undefined') {
    window.commandApiConnector = new CommandApiConnector();
    window.commandApiConnector.initialize();
}

// Self-initialization when run directly
const connector = new CommandApiConnector();
connector.initialize();

console.log("Command API Connection System initialized for Turn 4");