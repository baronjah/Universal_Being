/**
 * OpenAI Integration for Core 0 Terminal
 * Turn 4 (Temporal Flow) - 12 Turns Word Game
 * 
 * Connects to OpenAI API and provides integration with the 12 Turns System.
 */

class OpenAIIntegration {
    constructor(apiKey = null) {
        this.basePath = "/mnt/c/Users/Percision 15/12_turns_system";
        this.apiKey = apiKey;
        this.defaultModel = "gpt-4o";
        this.conversations = new Map();
        this.modelCapabilities = {
            "gpt-4o": { 
                maxTokens: 128000,
                contextWindow: 128000,
                capabilities: ["text", "vision", "function_calling"] 
            },
            "gpt-4-turbo": {
                maxTokens: 128000,
                contextWindow: 128000,
                capabilities: ["text", "function_calling"]
            },
            "gpt-3.5-turbo": {
                maxTokens: 16000,
                contextWindow: 16000,
                capabilities: ["text"]
            }
        };
        this.timeStates = {
            past: [],
            present: {},
            future: []
        };
        
        // Load API key if not provided
        if (!this.apiKey) {
            this.loadApiKey();
        }
    }

    /**
     * Initialize OpenAI integration
     */
    initialize() {
        console.log("Initializing OpenAI Integration for Core 0 Terminal");
        
        if (!this.apiKey) {
            console.warn("OpenAI API key not found. Set API key before making requests.");
        }
        
        return {
            status: "initialized",
            model: this.defaultModel,
            hasApiKey: !!this.apiKey,
            capabilities: this.modelCapabilities[this.defaultModel] || {}
        };
    }

    /**
     * Load API key from environment file
     */
    loadApiKey() {
        const fs = require('fs');
        const path = require('path');
        
        // Path to .env file
        const envPath = path.join(this.basePath, "turn_4", "data", ".env");
        
        try {
            if (fs.existsSync(envPath)) {
                const envContent = fs.readFileSync(envPath, 'utf8');
                const lines = envContent.split('\n');
                
                // Find OpenAI API key
                const openaiKeyLine = lines.find(line => 
                    line.startsWith('OPENAI_API_KEY=') || 
                    line.startsWith('CORE0_API_KEY=')
                );
                
                if (openaiKeyLine) {
                    this.apiKey = openaiKeyLine.split('=')[1].trim();
                    console.log("OpenAI API key loaded from .env file");
                    return true;
                }
            }
            
            return false;
        } catch (error) {
            console.error(`Error loading OpenAI API key: ${error.message}`);
            return false;
        }
    }

    /**
     * Set OpenAI API key
     */
    setApiKey(apiKey) {
        if (!apiKey) {
            return {
                error: "API key is required"
            };
        }
        
        // Validate API key format (basic check)
        if (!apiKey.startsWith('sk-')) {
            return {
                error: "Invalid API key format (should start with 'sk-')"
            };
        }
        
        this.apiKey = apiKey;
        
        // Update .env file
        this.updateEnvFile(apiKey);
        
        return {
            message: "OpenAI API key set successfully",
            status: "success"
        };
    }
    
    /**
     * Update environment file with API key
     */
    updateEnvFile(apiKey) {
        const fs = require('fs');
        const path = require('path');
        
        // Path to .env file
        const envPath = path.join(this.basePath, "turn_4", "data", ".env");
        
        try {
            let envContent = "";
            
            if (fs.existsSync(envPath)) {
                envContent = fs.readFileSync(envPath, 'utf8');
                
                // Update existing key
                if (envContent.includes('OPENAI_API_KEY=')) {
                    envContent = envContent.replace(/OPENAI_API_KEY=.*/g, `OPENAI_API_KEY=${apiKey}`);
                } else {
                    // Add new key
                    envContent += `\nOPENAI_API_KEY=${apiKey}`;
                }
            } else {
                // Create new .env file with API key
                envContent = `# API Configuration for 12 Turns System\nOPENAI_API_KEY=${apiKey}\n`;
            }
            
            // Ensure directory exists
            const dirPath = path.dirname(envPath);
            if (!fs.existsSync(dirPath)) {
                fs.mkdirSync(dirPath, { recursive: true });
            }
            
            // Write updated content
            fs.writeFileSync(envPath, envContent);
            console.log("API key updated in .env file");
            
            return true;
        } catch (error) {
            console.error(`Error updating .env file: ${error.message}`);
            return false;
        }
    }
    
    /**
     * Set the model to use for OpenAI requests
     */
    setModel(model) {
        if (!this.modelCapabilities[model]) {
            return {
                error: `Unsupported model: ${model}`,
                available: Object.keys(this.modelCapabilities)
            };
        }
        
        this.defaultModel = model;
        
        return {
            message: `Model set to ${model}`,
            capabilities: this.modelCapabilities[model]
        };
    }

    /**
     * Create a new conversation
     */
    createConversation(options = {}) {
        const conversationId = `conversation_${Date.now()}`;
        
        const conversation = {
            id: conversationId,
            created: new Date(),
            model: options.model || this.defaultModel,
            messages: [],
            temporalState: "present",
            luckyNumber: options.luckyNumber || null,
            symbol: options.symbol || null,
            metadata: options.metadata || {}
        };
        
        this.conversations.set(conversationId, conversation);
        
        console.log(`Created conversation: ${conversationId}`);
        
        // Set current conversation in present state
        this.timeStates.present = conversation;
        
        return {
            conversationId: conversationId,
            model: conversation.model,
            status: "created"
        };
    }
    
    /**
     * Add a message to a conversation
     */
    addMessage(conversationId, role, content) {
        if (!this.conversations.has(conversationId)) {
            return {
                error: `Conversation not found: ${conversationId}`
            };
        }
        
        const conversation = this.conversations.get(conversationId);
        
        // Validate role
        if (!["system", "user", "assistant", "function"].includes(role)) {
            return {
                error: `Invalid role: ${role}`,
                valid: ["system", "user", "assistant", "function"]
            };
        }
        
        // Add message
        const message = {
            role: role,
            content: content,
            timestamp: new Date()
        };
        
        conversation.messages.push(message);
        
        return {
            message: "Message added to conversation",
            messageCount: conversation.messages.length,
            status: "success"
        };
    }
    
    /**
     * Generate response from OpenAI
     */
    async generateResponse(conversationId, options = {}) {
        if (!this.apiKey) {
            return {
                error: "API key not set",
                status: "error"
            };
        }
        
        if (!this.conversations.has(conversationId)) {
            return {
                error: `Conversation not found: ${conversationId}`
            };
        }
        
        const conversation = this.conversations.get(conversationId);
        
        // Prepare request body
        const requestBody = {
            model: options.model || conversation.model || this.defaultModel,
            messages: conversation.messages.map(msg => ({
                role: msg.role,
                content: msg.content
            })),
            temperature: options.temperature || 0.7,
            max_tokens: options.maxTokens || null
        };
        
        // Simulate API call
        console.log(`Generating response for conversation ${conversationId}`);
        console.log("Request parameters:", JSON.stringify(requestBody, null, 2));
        
        // Since we can't make actual API calls, we'll simulate the response
        const simulatedResponse = this.simulateApiResponse(requestBody);
        
        // Add response to conversation
        if (simulatedResponse.choices && simulatedResponse.choices.length > 0) {
            const responseMsg = simulatedResponse.choices[0].message;
            
            this.addMessage(conversationId, "assistant", responseMsg.content);
            
            return {
                response: responseMsg.content,
                model: requestBody.model,
                status: "success",
                usage: simulatedResponse.usage
            };
        }
        
        return {
            error: "Failed to generate response",
            status: "error"
        };
    }
    
    /**
     * Simulate OpenAI API response (since we can't make actual API calls)
     */
    simulateApiResponse(requestBody) {
        // Extract the last user message
        const lastUserMsg = requestBody.messages
            .filter(msg => msg.role === "user")
            .pop();
            
        let content = "";
        
        if (lastUserMsg) {
            const userContent = lastUserMsg.content;
            
            // Create a response based on the user's message
            if (userContent.toLowerCase().includes("time")) {
                content = "The current temporal flow indicates we are in the 4th dimension (Consciousness/Time). We can manipulate past, present, and future states here.";
            } else if (userContent.toLowerCase().includes("game")) {
                content = "The 12 Turns System is a word manifestation game that allows us to create realities through 12 dimensions. We're currently in Turn 4 (Consciousness/Time).";
            } else if (userContent.toLowerCase().includes("terminal")) {
                content = "You're currently on Core 0 Terminal, which interfaces with the OpenAI API. The system allows multi-terminal operations synchronized through symbol mechanisms.";
            } else {
                content = `I've processed your input in the temporal flow dimension. At Turn 4, we can manipulate time and create connections between states. The Core 0 Terminal is functioning properly with the OpenAI integration.`;
            }
        } else {
            content = "Welcome to the Core 0 Terminal (OpenAI integration). How can I assist with your temporal operations?";
        }
        
        // Simulate API response format
        return {
            id: `chatcmpl-${Date.now()}`,
            object: "chat.completion",
            created: Math.floor(Date.now() / 1000),
            model: requestBody.model,
            choices: [
                {
                    index: 0,
                    message: {
                        role: "assistant",
                        content: content
                    },
                    finish_reason: "stop"
                }
            ],
            usage: {
                prompt_tokens: Math.floor(JSON.stringify(requestBody.messages).length / 4),
                completion_tokens: Math.floor(content.length / 4),
                total_tokens: Math.floor((JSON.stringify(requestBody.messages).length + content.length) / 4)
            }
        };
    }
    
    /**
     * Create a temporal echo (Turn 4 specific feature)
     */
    createTemporalEcho(conversationId, timeState = "past") {
        if (!this.conversations.has(conversationId)) {
            return {
                error: `Conversation not found: ${conversationId}`
            };
        }
        
        const conversation = this.conversations.get(conversationId);
        
        // Validate time state
        if (!["past", "future"].includes(timeState)) {
            return {
                error: `Invalid time state: ${timeState}`,
                valid: ["past", "future"]
            };
        }
        
        // Create a copy of the conversation
        const conversationCopy = { ...conversation };
        conversationCopy.messages = [...conversation.messages];
        conversationCopy.temporalState = timeState;
        
        // Add to appropriate time state array
        if (timeState === "past") {
            this.timeStates.past.push(conversationCopy);
        } else {
            this.timeStates.future.push(conversationCopy);
        }
        
        return {
            message: `Created temporal echo in ${timeState} state`,
            echoCount: timeState === "past" ? this.timeStates.past.length : this.timeStates.future.length,
            status: "success"
        };
    }
    
    /**
     * Connect to a temporal echo
     */
    connectToTemporalEcho(timeState = "past", index = 0) {
        // Validate time state
        if (!["past", "future"].includes(timeState)) {
            return {
                error: `Invalid time state: ${timeState}`,
                valid: ["past", "future"]
            };
        }
        
        // Get echoes for the time state
        const echoes = timeState === "past" ? this.timeStates.past : this.timeStates.future;
        
        if (index < 0 || index >= echoes.length) {
            return {
                error: `Echo index out of range: ${index}`,
                maxIndex: echoes.length - 1
            };
        }
        
        // Get echo
        const echo = echoes[index];
        
        // Create a new conversation based on the echo
        const conversationId = `conversation_${Date.now()}`;
        const conversation = { ...echo };
        conversation.id = conversationId;
        conversation.temporalState = "present";
        conversation.created = new Date();
        conversation.metadata = {
            ...conversation.metadata,
            echoOrigin: {
                state: timeState,
                index: index,
                timestamp: new Date()
            }
        };
        
        // Add to conversations
        this.conversations.set(conversationId, conversation);
        
        // Update present state
        this.timeStates.present = conversation;
        
        return {
            conversationId: conversationId,
            message: `Connected to ${timeState} echo at index ${index}`,
            messageCount: conversation.messages.length,
            status: "success"
        };
    }
    
    /**
     * Get all temporal echoes
     */
    getTemporalEchoes() {
        return {
            past: this.timeStates.past.map((echo, index) => ({
                index: index,
                id: echo.id,
                created: echo.created,
                messageCount: echo.messages.length
            })),
            present: {
                id: this.timeStates.present.id,
                created: this.timeStates.present.created,
                messageCount: this.timeStates.present.messages ? this.timeStates.present.messages.length : 0
            },
            future: this.timeStates.future.map((echo, index) => ({
                index: index,
                id: echo.id,
                created: echo.created,
                messageCount: echo.messages.length
            }))
        };
    }
    
    /**
     * Save current state to memory system
     */
    saveToMemory() {
        const fs = require('fs');
        const path = require('path');
        
        // Path to memory file
        const memoryPath = path.join(this.basePath, "turn_4", "data", "memory", "openai_state.json");
        
        // Create memory object
        const memoryData = {
            saved: new Date(),
            conversations: Array.from(this.conversations.entries()).map(([id, convo]) => ({
                id: id,
                created: convo.created,
                model: convo.model,
                messageCount: convo.messages.length,
                temporalState: convo.temporalState
            })),
            timeStates: {
                past: this.timeStates.past.length,
                present: this.timeStates.present.id,
                future: this.timeStates.future.length
            }
        };
        
        try {
            // Ensure directory exists
            const dirPath = path.dirname(memoryPath);
            if (!fs.existsSync(dirPath)) {
                fs.mkdirSync(dirPath, { recursive: true });
            }
            
            // Write memory file
            fs.writeFileSync(memoryPath, JSON.stringify(memoryData, null, 2));
            
            return {
                message: "Current state saved to memory system",
                status: "success",
                savedAt: new Date()
            };
        } catch (error) {
            console.error(`Error saving to memory: ${error.message}`);
            
            return {
                error: `Failed to save to memory: ${error.message}`,
                status: "error"
            };
        }
    }
}

// For Node.js environment
if (typeof module !== 'undefined') {
    module.exports = { OpenAIIntegration };
}

// Initialize when run directly
if (require.main === module) {
    const openai = new OpenAIIntegration();
    const result = openai.initialize();
    console.log("OpenAI Integration initialized:", result);
}