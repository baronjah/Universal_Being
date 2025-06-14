/**
 * API Merger System
 * Turn 4 (Temporal Flow) - 12 Turns Word Game
 * 
 * Merges different Claude API tiers and OpenAI API into a unified interface
 * for seamless game experience with memory integration.
 */

class ApiMergerSystem {
    constructor() {
        this.basePath = "/mnt/c/Users/Percision 15/12_turns_system";
        this.apiKeys = new Map();
        this.connections = new Map();
        this.apiTiers = {
            claude: ["free", "plus", "max", "premium", "pro", "api"],
            openai: ["free", "plus", "pro", "api"]
        };
        this.activeSubscriptions = new Map();
        this.memoryStore = new Map();
        this.gameStateMemory = new Map();
        this.accountLinker = new Map();
        this.currentTier = "max";
        this.currentProvider = "claude";
        this.mergedApis = false;
    }

    /**
     * Initialize the API merger
     */
    initialize() {
        console.log("Initializing API Merger System");
        
        // Initialize API tiers
        this.initializeApiTiers();
        
        // Load API keys from environment
        this.loadApiKeys();
        
        return {
            status: "initialized",
            apiTiers: this.apiTiers,
            activeProvider: this.currentProvider,
            activeTier: this.currentTier,
            mergedApis: this.mergedApis
        };
    }

    /**
     * Initialize API tiers with capabilities
     */
    initializeApiTiers() {
        // Define capabilities for Claude tiers
        this.apiTiers.claudeCapabilities = {
            "free": {
                requestsPerDay: 5,
                contextSize: 100000,
                priority: 1,
                memoriesEnabled: false
            },
            "plus": {
                requestsPerDay: 50,
                contextSize: 150000,
                priority: 2,
                memoriesEnabled: true
            },
            "max": {
                requestsPerDay: 500,
                contextSize: 200000,
                priority: 4,
                memoriesEnabled: true
            },
            "premium": {
                requestsPerDay: 1000,
                contextSize: 200000,
                priority: 5,
                memoriesEnabled: true
            },
            "pro": {
                requestsPerDay: Infinity,
                contextSize: 200000,
                priority: 10,
                memoriesEnabled: true
            },
            "api": {
                requestsPerDay: Infinity,
                contextSize: 200000,
                priority: 20,
                memoriesEnabled: true
            }
        };
        
        // Define capabilities for OpenAI tiers
        this.apiTiers.openaiCapabilities = {
            "free": {
                requestsPerDay: 5,
                contextSize: 16000,
                priority: 1,
                memoriesEnabled: false
            },
            "plus": {
                requestsPerDay: 50,
                contextSize: 32000,
                priority: 2,
                memoriesEnabled: true
            },
            "pro": {
                requestsPerDay: 1000,
                contextSize: 128000,
                priority: 5,
                memoriesEnabled: true
            },
            "api": {
                requestsPerDay: Infinity,
                contextSize: 128000,
                priority: 20,
                memoriesEnabled: true
            }
        };
    }

    /**
     * Load API keys from environment
     */
    loadApiKeys() {
        const fs = require('fs');
        const path = require('path');
        
        // Path to .env file
        const envPath = path.join(this.basePath, "turn_4", "data", ".env");
        
        if (fs.existsSync(envPath)) {
            const content = fs.readFileSync(envPath, 'utf8');
            const lines = content.split('\n');
            
            // Extract API keys
            for (const line of lines) {
                if (line.startsWith('#') || line.trim() === '') continue;
                
                const [key, value] = line.split('=');
                if (!key || !value) continue;
                
                const trimmedKey = key.trim();
                const trimmedValue = value.trim();
                
                if (trimmedKey === 'OPENAI_API_KEY') {
                    this.apiKeys.set('openai', trimmedValue);
                } else if (trimmedKey === 'CLAUDE_API_KEY') {
                    this.apiKeys.set('claude', trimmedValue);
                }
            }
        }
        
        console.log(`Loaded ${this.apiKeys.size} API keys`);
    }

    /**
     * Set API key
     */
    setApiKey(provider, key) {
        if (!provider || !key) {
            return {
                error: "Provider and key are required"
            };
        }
        
        // Normalize provider name
        const normalizedProvider = provider.toLowerCase();
        
        // Validate provider
        if (!['claude', 'openai'].includes(normalizedProvider)) {
            return {
                error: `Invalid provider: ${provider}`,
                valid: ['claude', 'openai']
            };
        }
        
        // Store API key
        this.apiKeys.set(normalizedProvider, key);
        
        console.log(`Set API key for ${normalizedProvider}`);
        
        return {
            message: `API key set for ${normalizedProvider}`,
            provider: normalizedProvider
        };
    }

    /**
     * Merge all API tiers
     */
    mergeApiTiers() {
        if (this.mergedApis) {
            return {
                message: "APIs already merged",
                status: "already_merged"
            };
        }
        
        // Create a merged API configuration with maximum capabilities
        const mergedCapabilities = {
            requestsPerDay: Infinity,
            contextSize: Math.max(
                this.apiTiers.claudeCapabilities.api.contextSize,
                this.apiTiers.openaiCapabilities.api.contextSize
            ),
            priority: Math.max(
                this.apiTiers.claudeCapabilities.api.priority,
                this.apiTiers.openaiCapabilities.api.priority
            ),
            memoriesEnabled: true,
            providers: ['claude', 'openai'],
            tiers: [...this.apiTiers.claude, ...this.apiTiers.openai]
        };
        
        // Set as merged
        this.mergedApis = true;
        this.currentTier = "merged";
        
        // Store merged capabilities
        this.apiTiers.mergedCapabilities = mergedCapabilities;
        
        console.log("All API tiers merged successfully");
        
        return {
            message: "All API tiers merged successfully",
            capabilities: mergedCapabilities,
            status: "merged"
        };
    }

    /**
     * Link account to memories
     */
    linkAccountToMemories(accountId) {
        if (!accountId) {
            return {
                error: "Account ID is required"
            };
        }
        
        // Create a new account link
        this.accountLinker.set(accountId, {
            id: accountId,
            linked: new Date(),
            memories: new Set(),
            gameStates: new Set()
        });
        
        console.log(`Linked account ${accountId} to memory system`);
        
        return {
            message: `Account ${accountId} linked to memory system`,
            status: "linked"
        };
    }

    /**
     * Store memory
     */
    storeMemory(content, metadata = {}) {
        if (!content) {
            return {
                error: "Memory content is required"
            };
        }
        
        // Create memory ID
        const memoryId = `memory_${Date.now()}`;
        
        // Store memory
        this.memoryStore.set(memoryId, {
            id: memoryId,
            content: content,
            created: new Date(),
            accessed: new Date(),
            metadata: {
                ...metadata,
                provider: this.currentProvider,
                tier: this.currentTier
            }
        });
        
        // Link to account if available
        if (metadata.accountId && this.accountLinker.has(metadata.accountId)) {
            const accountLink = this.accountLinker.get(metadata.accountId);
            accountLink.memories.add(memoryId);
        }
        
        console.log(`Stored memory: ${memoryId}`);
        
        return {
            message: `Memory stored: ${memoryId}`,
            id: memoryId
        };
    }

    /**
     * Store game state memory
     */
    storeGameState(gameState, accountId = null) {
        if (!gameState) {
            return {
                error: "Game state is required"
            };
        }
        
        // Create state ID
        const stateId = `game_state_${Date.now()}`;
        
        // Store game state
        this.gameStateMemory.set(stateId, {
            id: stateId,
            state: gameState,
            created: new Date(),
            accessed: new Date(),
            accountId: accountId
        });
        
        // Link to account if available
        if (accountId && this.accountLinker.has(accountId)) {
            const accountLink = this.accountLinker.get(accountId);
            accountLink.gameStates.add(stateId);
        }
        
        console.log(`Stored game state: ${stateId}`);
        
        return {
            message: `Game state stored: ${stateId}`,
            id: stateId
        };
    }

    /**
     * Retrieve memories for account
     */
    getAccountMemories(accountId) {
        if (!accountId) {
            return {
                error: "Account ID is required"
            };
        }
        
        if (!this.accountLinker.has(accountId)) {
            return {
                error: `Account not found: ${accountId}`,
                hint: "Link account first with linkAccountToMemories()"
            };
        }
        
        const accountLink = this.accountLinker.get(accountId);
        const memories = [];
        
        // Collect all memories
        for (const memoryId of accountLink.memories) {
            if (this.memoryStore.has(memoryId)) {
                const memory = this.memoryStore.get(memoryId);
                memories.push({
                    id: memory.id,
                    content: memory.content,
                    created: memory.created,
                    metadata: memory.metadata
                });
                
                // Update access time
                memory.accessed = new Date();
            }
        }
        
        console.log(`Retrieved ${memories.length} memories for account ${accountId}`);
        
        return {
            accountId: accountId,
            memories: memories,
            count: memories.length
        };
    }

    /**
     * Retrieve game states for account
     */
    getAccountGameStates(accountId) {
        if (!accountId) {
            return {
                error: "Account ID is required"
            };
        }
        
        if (!this.accountLinker.has(accountId)) {
            return {
                error: `Account not found: ${accountId}`,
                hint: "Link account first with linkAccountToMemories()"
            };
        }
        
        const accountLink = this.accountLinker.get(accountId);
        const states = [];
        
        // Collect all game states
        for (const stateId of accountLink.gameStates) {
            if (this.gameStateMemory.has(stateId)) {
                const state = this.gameStateMemory.get(stateId);
                states.push({
                    id: state.id,
                    state: state.state,
                    created: state.created
                });
                
                // Update access time
                state.accessed = new Date();
            }
        }
        
        console.log(`Retrieved ${states.length} game states for account ${accountId}`);
        
        return {
            accountId: accountId,
            states: states,
            count: states.length
        };
    }

    /**
     * Connect API provider
     */
    connectProvider(provider, tier = null) {
        if (!provider) {
            return {
                error: "Provider is required"
            };
        }
        
        // Normalize provider name
        const normalizedProvider = provider.toLowerCase();
        
        // Validate provider
        if (!['claude', 'openai', 'merged'].includes(normalizedProvider)) {
            return {
                error: `Invalid provider: ${provider}`,
                valid: ['claude', 'openai', 'merged']
            };
        }
        
        // Handle merged case
        if (normalizedProvider === 'merged') {
            if (!this.mergedApis) {
                const mergeResult = this.mergeApiTiers();
                if (mergeResult.error) {
                    return mergeResult;
                }
            }
            
            this.currentProvider = 'merged';
            this.currentTier = 'merged';
            
            return {
                message: "Connected to merged API providers",
                provider: 'merged',
                tier: 'merged',
                capabilities: this.apiTiers.mergedCapabilities
            };
        }
        
        // Set current provider
        this.currentProvider = normalizedProvider;
        
        // Check if API key is available
        if (!this.apiKeys.has(normalizedProvider)) {
            return {
                warning: `No API key found for ${normalizedProvider}`,
                provider: normalizedProvider,
                status: "connected_without_key"
            };
        }
        
        // Set tier if provided
        if (tier) {
            const normalizedTier = tier.toLowerCase();
            const tierList = this.apiTiers[normalizedProvider];
            
            if (!tierList || !tierList.includes(normalizedTier)) {
                return {
                    error: `Invalid tier for ${normalizedProvider}: ${tier}`,
                    valid: this.apiTiers[normalizedProvider]
                };
            }
            
            this.currentTier = normalizedTier;
        } else {
            // Default to highest tier
            const tierList = this.apiTiers[normalizedProvider];
            this.currentTier = tierList[tierList.length - 1];
        }
        
        console.log(`Connected to ${normalizedProvider} API (${this.currentTier} tier)`);
        
        return {
            message: `Connected to ${normalizedProvider} API (${this.currentTier} tier)`,
            provider: normalizedProvider,
            tier: this.currentTier,
            capabilities: this.apiTiers[`${normalizedProvider}Capabilities`][this.currentTier]
        };
    }

    /**
     * Get available API providers
     */
    getAvailableProviders() {
        const providers = [];
        
        // Add Claude if key is available
        if (this.apiKeys.has('claude')) {
            providers.push({
                name: 'claude',
                tiers: this.apiTiers.claude,
                capabilities: this.apiTiers.claudeCapabilities
            });
        }
        
        // Add OpenAI if key is available
        if (this.apiKeys.has('openai')) {
            providers.push({
                name: 'openai',
                tiers: this.apiTiers.openai,
                capabilities: this.apiTiers.openaiCapabilities
            });
        }
        
        // Add merged if enabled
        if (this.mergedApis) {
            providers.push({
                name: 'merged',
                tiers: ['merged'],
                capabilities: this.apiTiers.mergedCapabilities
            });
        }
        
        return {
            providers: providers,
            count: providers.length,
            current: {
                provider: this.currentProvider,
                tier: this.currentTier
            }
        };
    }

    /**
     * Transform memory to game visualization
     */
    transformMemoryToGame(memoryId, accountId = null) {
        if (!memoryId && !accountId) {
            return {
                error: "Either memory ID or account ID is required"
            };
        }
        
        let memories = [];
        
        if (memoryId) {
            // Get specific memory
            if (!this.memoryStore.has(memoryId)) {
                return {
                    error: `Memory not found: ${memoryId}`
                };
            }
            
            const memory = this.memoryStore.get(memoryId);
            memories.push(memory);
        } else if (accountId) {
            // Get all memories for account
            const accountMemories = this.getAccountMemories(accountId);
            if (accountMemories.error) {
                return accountMemories;
            }
            
            memories = accountMemories.memories.map(m => this.memoryStore.get(m.id));
        }
        
        // Create game visualization from memories
        const visualization = {
            gameElements: [],
            connections: [],
            metadata: {
                timestamp: new Date(),
                provider: this.currentProvider,
                tier: this.currentTier,
                memoryCount: memories.length
            }
        };
        
        // Process each memory
        for (const memory of memories) {
            // Extract key concepts from memory
            const concepts = this.extractConcepts(memory.content);
            
            // Create game elements
            for (const concept of concepts) {
                visualization.gameElements.push({
                    id: `element_${Date.now()}_${Math.floor(Math.random() * 1000)}`,
                    type: concept.type,
                    name: concept.name,
                    properties: concept.properties,
                    source: memory.id
                });
            }
            
            // Create connections between concepts
            for (let i = 0; i < concepts.length; i++) {
                for (let j = i + 1; j < concepts.length; j++) {
                    visualization.connections.push({
                        source: concepts[i].name,
                        target: concepts[j].name,
                        strength: 0.5 + Math.random() * 0.5, // Random strength between 0.5 and 1.0
                        type: "concept_link"
                    });
                }
            }
        }
        
        // Store as game state
        const storeResult = this.storeGameState({
            visualization: visualization,
            source: {
                type: memoryId ? "memory" : "account",
                id: memoryId || accountId
            }
        }, accountId);
        
        return {
            message: "Memory transformed to game visualization",
            gameState: storeResult.id,
            elements: visualization.gameElements.length,
            connections: visualization.connections.length
        };
    }
    
    /**
     * Extract concepts from memory content
     */
    extractConcepts(content) {
        if (!content || typeof content !== 'string') {
            return [];
        }
        
        const concepts = [];
        
        // Define concept patterns
        const conceptPatterns = [
            { type: "entity", regex: /([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)/g },
            { type: "keyword", regex: /\b(game|memories|account|api|claude|openai|turn|stage|process|evolution|shape|story|system|tool|command|connection|bridge|flow|time|dimension)\b/gi },
            { type: "action", regex: /\b(merge|connect|link|store|retrieve|transform|visualize|create|update|delete|play|interact|evolve)\b/gi },
            { type: "numeric", regex: /\b(\d+(?:\.\d+)?)\b/g }
        ];
        
        // Extract concepts using patterns
        for (const pattern of conceptPatterns) {
            const matches = content.match(pattern.regex) || [];
            
            // Add unique concepts
            for (const match of matches) {
                if (!concepts.some(c => c.name === match && c.type === pattern.type)) {
                    concepts.push({
                        type: pattern.type,
                        name: match,
                        properties: {
                            weight: match.length / 5, // Simple weight calculation
                            frequency: (content.match(new RegExp(match, 'gi')) || []).length
                        }
                    });
                }
            }
        }
        
        return concepts;
    }
}

// For Node.js environment
if (typeof module !== 'undefined') {
    module.exports = { ApiMergerSystem };
}

// Initialize when run directly
if (require.main === module) {
    const merger = new ApiMergerSystem();
    const result = merger.initialize();
    console.log("API Merger System initialized:", result);
}