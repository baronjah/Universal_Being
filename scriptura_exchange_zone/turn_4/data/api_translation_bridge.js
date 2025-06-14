/**
 * API Translation Bridge
 * Turn 4 (Temporal Flow) - 12 Turns Word Game
 * 
 * Connects external APIs to the game system, allowing translation
 * between what the user sees and the game world.
 */

class ApiTranslationBridge {
    constructor() {
        this.basePath = "/mnt/c/Users/Percision 15/12_turns_system";
        this.apiKeys = new Map();
        this.activeConnections = new Map();
        this.translationCache = new Map();
        this.terminalMappings = {
            "Core 0": "openai",
            "Core 1": "claude",
            "Dev Terminal": "node"
        };
        this.luckyNumbers = [4, 7, 8, 'L'];
        this.symbolMap = {
            "JSH": { power: 1.5, domain: "identity" },
            "⌛": { power: 1.4, domain: "time" },
            "🧠": { power: 1.3, domain: "consciousness" },
            "∞": { power: 1.7, domain: "infinity" },
            "⚡": { power: 1.2, domain: "speed" }
        };
    }

    /**
     * Initialize the API bridge
     */
    initialize() {
        console.log("Initializing API Translation Bridge");
        this.loadApiConfiguration();
        return {
            status: "initialized",
            apis: Array.from(this.apiKeys.keys()),
            terminals: Object.keys(this.terminalMappings)
        };
    }

    /**
     * Load API configuration from environment files
     */
    loadApiConfiguration() {
        const fs = require('fs');
        const path = require('path');
        
        // Path to .env file in the turn directory
        const envPath = path.join(this.basePath, "turn_4", "data", ".env");
        
        try {
            if (fs.existsSync(envPath)) {
                const envContent = fs.readFileSync(envPath, 'utf8');
                const lines = envContent.split('\n');
                
                // Process each line
                lines.forEach(line => {
                    // Skip comments and empty lines
                    if (line.startsWith('#') || !line.trim()) return;
                    
                    const [key, value] = line.split('=');
                    if (key && value) {
                        const trimmedKey = key.trim();
                        const trimmedValue = value.trim();
                        
                        // Store API keys
                        if (trimmedKey.includes('API_KEY')) {
                            const apiName = trimmedKey.replace('_API_KEY', '').toLowerCase();
                            this.apiKeys.set(apiName, trimmedValue);
                        }
                    }
                });
                
                console.log(`Loaded ${this.apiKeys.size} API configurations`);
            } else {
                // Create default .env file
                this.createDefaultEnvFile(envPath);
            }
        } catch (error) {
            console.error(`Error loading API configuration: ${error.message}`);
        }
    }
    
    /**
     * Create default .env file
     */
    createDefaultEnvFile(envPath) {
        const fs = require('fs');
        const path = require('path');
        
        // Create directory if it doesn't exist
        const dirPath = path.dirname(envPath);
        if (!fs.existsSync(dirPath)) {
            fs.mkdirSync(dirPath, { recursive: true });
        }
        
        // Default environment variables
        const defaultEnv = `# API Configuration for 12 Turns System
# Turn 4 (Temporal Flow)

# OpenAI API configuration for Core 0 terminal
OPENAI_API_KEY=sk-proj-xxxx

# Claude API configuration for Core 1 terminal
CLAUDE_API_KEY=sk-xxxx

# Terminal mapping
CORE0_TERMINAL=openai
CORE1_TERMINAL=claude
DEV_TERMINAL=node

# Lucky numbers configuration
LUCKY_NUMBERS=4,7,8,L

# Symbol power configuration
SYMBOL_JSH=1.5
SYMBOL_TIME=1.4
SYMBOL_BRAIN=1.3
SYMBOL_INFINITY=1.7
SYMBOL_LIGHTNING=1.2
`;
        
        // Write default configuration
        fs.writeFileSync(envPath, defaultEnv);
        console.log(`Created default API configuration at ${envPath}`);
    }

    /**
     * Set API key
     */
    setApiKey(apiName, apiKey) {
        if (!apiName || !apiKey) {
            return {
                error: "API name and key are required"
            };
        }
        
        const normalizedName = apiName.toLowerCase();
        this.apiKeys.set(normalizedName, apiKey);
        
        // Update .env file
        this.updateEnvFile(normalizedName, apiKey);
        
        return {
            message: `API key set for ${apiName}`,
            apis: Array.from(this.apiKeys.keys())
        };
    }
    
    /**
     * Update .env file with new API key
     */
    updateEnvFile(apiName, apiKey) {
        const fs = require('fs');
        const path = require('path');
        
        const envPath = path.join(this.basePath, "turn_4", "data", ".env");
        
        try {
            if (fs.existsSync(envPath)) {
                let envContent = fs.readFileSync(envPath, 'utf8');
                const upperApiName = apiName.toUpperCase();
                const keyPattern = new RegExp(`${upperApiName}_API_KEY=.*`, 'i');
                
                if (envContent.match(keyPattern)) {
                    // Update existing key
                    envContent = envContent.replace(keyPattern, `${upperApiName}_API_KEY=${apiKey}`);
                } else {
                    // Add new key
                    envContent += `\n${upperApiName}_API_KEY=${apiKey}`;
                }
                
                fs.writeFileSync(envPath, envContent);
                console.log(`Updated API key for ${apiName} in .env file`);
            } else {
                this.createDefaultEnvFile(envPath);
                this.updateEnvFile(apiName, apiKey);
            }
        } catch (error) {
            console.error(`Error updating .env file: ${error.message}`);
        }
    }

    /**
     * Connect to an API
     */
    connectToApi(apiName, options = {}) {
        const normalizedName = apiName.toLowerCase();
        
        if (!this.apiKeys.has(normalizedName)) {
            return {
                error: `API key not found for ${apiName}`,
                available: Array.from(this.apiKeys.keys())
            };
        }
        
        const connectionId = `${normalizedName}_${Date.now()}`;
        this.activeConnections.set(connectionId, {
            api: normalizedName,
            connected: new Date(),
            options: options,
            status: "connected"
        });
        
        console.log(`Connected to ${apiName} API with connection ID ${connectionId}`);
        
        return {
            message: `Connected to ${apiName} API`,
            connectionId: connectionId,
            status: "connected"
        };
    }

    /**
     * Translate user input to game world representation
     */
    translateInput(input, terminal = "Core 1") {
        if (!input) {
            return {
                error: "Input is required"
            };
        }
        
        // Get API for terminal
        const api = this.terminalMappings[terminal] || "claude";
        
        // Check for lucky numbers
        let luckyMultiplier = 1.0;
        for (const num of this.luckyNumbers) {
            const prefix = `${num} `;
            if (input.startsWith(prefix)) {
                luckyMultiplier = Number(num) / 5 + 1; // Convert L to 1.2 multiplier
                if (num === 'L') luckyMultiplier = 1.5;
                input = input.substring(prefix.length);
                break;
            }
        }
        
        // Check for symbols
        let symbolPower = 1.0;
        for (const [symbol, config] of Object.entries(this.symbolMap)) {
            if (input.startsWith(symbol + " ") || input.startsWith(symbol + "-")) {
                symbolPower = config.power;
                input = input.substring(symbol.length + 1); // +1 for the space or dash
                break;
            }
        }
        
        // Calculate total power
        const totalPower = luckyMultiplier * symbolPower;
        
        // Create translation result
        const translationId = `translation_${Date.now()}`;
        const translation = {
            original: input,
            terminal: terminal,
            api: api,
            luckyMultiplier: luckyMultiplier,
            symbolPower: symbolPower,
            totalPower: totalPower,
            created: new Date(),
            gameWorld: {
                dimension: "4D",
                timeState: "present",
                consciousness: totalPower > 2.0 ? "awakened" : "normal",
                manifestPower: Math.floor(totalPower * 100)
            }
        };
        
        // Cache translation
        this.translationCache.set(translationId, translation);
        
        return {
            id: translationId,
            translation: translation,
            message: `Translated input with power level ${translation.gameWorld.manifestPower}`
        };
    }

    /**
     * Translate game world to user visible output
     */
    translateOutput(gameContent, terminal = "Core 1") {
        if (!gameContent) {
            return {
                error: "Game content is required"
            };
        }
        
        // Get API for terminal
        const api = this.terminalMappings[terminal] || "claude";
        
        // Create translation
        const translationId = `output_${Date.now()}`;
        const translation = {
            gameContent: gameContent,
            terminal: terminal,
            api: api,
            created: new Date(),
            userVisible: this.processGameContent(gameContent, api)
        };
        
        // Cache translation
        this.translationCache.set(translationId, translation);
        
        return {
            id: translationId,
            translation: translation,
            message: "Game content translated for user visibility"
        };
    }
    
    /**
     * Process game content based on API
     */
    processGameContent(content, api) {
        // Add API-specific formatting
        switch (api) {
            case "openai":
                // OpenAI specific formatting
                return {
                    text: content,
                    model: "gpt-4o",
                    formatted: true
                };
            case "claude":
                // Claude specific formatting
                return {
                    text: content,
                    model: "claude-3-opus-20240229",
                    formatted: true
                };
            case "node":
                // Node specific formatting (raw)
                return {
                    text: content,
                    raw: true
                };
            default:
                return { text: content };
        }
    }

    /**
     * Set terminal API mapping
     */
    setTerminalApi(terminal, api) {
        if (!terminal || !api) {
            return {
                error: "Terminal and API are required"
            };
        }
        
        if (!Object.keys(this.terminalMappings).includes(terminal)) {
            return {
                error: `Unknown terminal: ${terminal}`,
                available: Object.keys(this.terminalMappings)
            };
        }
        
        this.terminalMappings[terminal] = api.toLowerCase();
        
        return {
            message: `Terminal ${terminal} mapped to ${api} API`,
            terminals: this.terminalMappings
        };
    }
    
    /**
     * Get all terminal mappings
     */
    getTerminalMappings() {
        return {
            mappings: this.terminalMappings,
            default: "Core 1"
        };
    }
    
    /**
     * Clear translation cache
     */
    clearCache() {
        const cacheSize = this.translationCache.size;
        this.translationCache.clear();
        
        return {
            message: `Cleared ${cacheSize} cached translations`
        };
    }
}

// For Node.js environment
if (typeof module !== 'undefined') {
    module.exports = { ApiTranslationBridge };
}

// Initialize when run directly
if (require.main === module) {
    const bridge = new ApiTranslationBridge();
    const result = bridge.initialize();
    console.log("API Translation Bridge initialized:", result);
}