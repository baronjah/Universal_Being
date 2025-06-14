/**
 * Module Exports Wrapper
 * Turn 4 (Temporal Flow) - 12 Turns Word Game
 *
 * Provides proper module exports for Node.js environment
 * to ensure compatibility with the run script.
 */

// Core system classes
const PhaseManager = require('./phase_manager.js').PhaseManager;
const ConsoleCommandInterface = require('./console/console_command_interface.js');

// Console command handlers
const ApiCommandHandler = require('./console/api_command_handler.js');
const AccelerationCommandHandler = require('./console/acceleration_command_handler.js');
const AccountCommandHandler = require('./console/account_command_handler.js');
const ProjectCommandHandler = require('./console/project_command_handler.js');
const ShapeCommandHandler = require('./console/shape_command_handler.js');
const MergerCommandHandler = require('./console/merger_command_handler.js');
const LuminousCommandHandler = require('./console/luminous_command_handler.js');

// API Integration classes
const ApiTranslationBridge = require('./api_translation_bridge.js').ApiTranslationBridge;
const OpenAIIntegration = require('./openai_integration.js').OpenAIIntegration;
const AccelerationProtocol = require('./acceleration_protocol.js').AccelerationProtocol;
const SharedAccountConnector = require('./shared_account_connector.js').SharedAccountConnector;

// Project Continuation classes
const ProjectContinuation = require('./project_continuation.js').ProjectContinuation;
const ShapeSystemIntegrator = require('./shape_system_integrator.js').ShapeSystemIntegrator;
const ApiMergerSystem = require('./api_merger_system.js').ApiMergerSystem;
const LuminousOS = require('./luminous_os.js').LuminousOS;

// Export all modules
module.exports = {
    // Core classes
    PhaseManager,
    ConsoleCommandInterface,
    ApiTranslationBridge,
    OpenAIIntegration,
    AccelerationProtocol,
    SharedAccountConnector,
    ProjectContinuation,
    ShapeSystemIntegrator,
    ApiMergerSystem,
    LuminousOS,

    // Console command handlers
    ApiCommandHandler,
    AccelerationCommandHandler,
    AccountCommandHandler,
    ProjectCommandHandler,
    ShapeCommandHandler,
    MergerCommandHandler,
    LuminousCommandHandler,

    // Create and initialize instances
    createPhaseManager: function(config = {}) {
        const basePath = config.basePath || "/mnt/c/Users/Percision 15/12_turns_system";
        const manager = new PhaseManager(basePath);
        manager.initialize();
        return manager;
    },

    createConsoleInterface: function(config = {}) {
        const interface = new ConsoleCommandInterface();
        interface.initialize();
        return interface;
    },

    createApiBridge: function(config = {}) {
        const bridge = new ApiTranslationBridge();
        bridge.initialize();
        return bridge;
    },

    createOpenAI: function(config = {}) {
        const openai = new OpenAIIntegration(config.apiKey);
        openai.initialize();
        return openai;
    },

    createAccelerationProtocol: function(config = {}) {
        const protocol = new AccelerationProtocol();
        protocol.initialize();
        return protocol;
    },

    createSharedAccountConnector: function(config = {}) {
        const connector = new SharedAccountConnector();
        connector.initialize();
        return connector;
    },

    createProjectContinuation: function(config = {}) {
        const project = new ProjectContinuation();
        project.initialize();
        return project;
    },

    createShapeSystemIntegrator: function(config = {}) {
        const integrator = new ShapeSystemIntegrator();
        integrator.initialize();
        return integrator;
    },

    createApiMergerSystem: function(config = {}) {
        const merger = new ApiMergerSystem();
        merger.initialize();
        return merger;
    },

    createLuminousOS: function(config = {}) {
        const os = new LuminousOS();
        os.initialize();
        return os;
    },

    // Helper functions
    executeCommand: function(command, terminal = "Core 1") {
        return ConsoleCommandInterface.processCommand(command, terminal);
    },

    translateInput: function(input, terminal = "Core 1") {
        const bridge = new ApiTranslationBridge();
        bridge.initialize();
        return bridge.translateInput(input, terminal);
    },

    translateOutput: function(gameContent, terminal = "Core 1") {
        const bridge = new ApiTranslationBridge();
        bridge.initialize();
        return bridge.translateOutput(gameContent, terminal);
    },

    // API terminal interaction
    interactWithTerminal: function(message, terminal = "Core 0") {
        if (terminal === "Core 0") {
            const openai = new OpenAIIntegration();
            openai.initialize();
            const convo = openai.createConversation();
            openai.addMessage(convo.conversationId, "user", message);
            return openai.generateResponse(convo.conversationId);
        } else {
            // Default to console interface
            const interface = new ConsoleCommandInterface();
            interface.initialize();
            return interface.executeCommand(message, terminal);
        }
    },

    // Version information
    version: "1.0.0",
    turn: 4,
    dimension: "Consciousness/Temporal Flow",

    // API endpoints
    endpoints: {
        openai: "/api/openai",
        claude: "/api/claude",
        translate: "/api/translate"
    }
};