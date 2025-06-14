/**
 * Game Command Handler
 * Provides interface for game creation and management
 * Part of the 12 Turns System - Turn 4 (Consciousness/Temporal Flow)
 */

const LuminousOS = require('./luminous_os').LuminousOS;

class GameCommandHandler {
  constructor() {
    this.luminousOS = new LuminousOS();
    this.commands = {
      create: this.createGame.bind(this),
      play: this.playGame.bind(this),
      list: this.listGames.bind(this),
      status: this.getStatus.bind(this),
      save: this.saveGame.bind(this),
      load: this.loadGame.bind(this),
      combine: this.combineGames.bind(this),
      godmode: this.activateGodMode.bind(this),
      organize: this.organizeGames.bind(this),
    };
    
    // Game templates available
    this.gameTemplates = {
      "divine_word": "Divine Word Game - A game of word creation with divine powers",
      "shape_realm": "Shape Realm - Create and interact with 3D geometric shapes",
      "temporal_turns": "Temporal Turns - Navigate through time with the 12 turns system",
      "notepad3d": "3D Notepad - Visualize and organize information in 3D space",
      "akashic_journey": "Akashic Journey - Explore the Akashic Records",
      "consciousness_flow": "Consciousness Flow - Guide consciousness through dimensions",
      "word_salem": "Word Salem - Identify word roles in a cosmic Salem game",
      "jsh_universe": "JSH Universe - Create and manage your own universe",
      "light_quest": "Light Quest - Navigate through realms of light and shadow",
      "all_combined": "All Combined - Ultimate game combining all systems"
    };
  }

  /**
   * Process game commands with lucky number and symbol enhancements
   */
  processCommand(args, terminal, symbols = [], luckyNumbers = []) {
    const [subCommand, ...subArgs] = args;
    
    if (!subCommand || !this.commands[subCommand]) {
      return this.getHelp();
    }
    
    // Apply lucky number power multipliers
    const powerMultiplier = luckyNumbers.includes(4) ? 4 : 
                           luckyNumbers.includes(7) ? 7 :
                           luckyNumbers.includes(8) ? 8 : 
                           luckyNumbers.includes('L') ? 12 : 1;
    
    // Apply symbol enhancements
    const temporalEnhanced = symbols.includes('⌛');
    const consciousnessEnhanced = symbols.includes('🧠');
    const jshEnhanced = symbols.includes('JSH');
    const godModeActive = symbols.includes('GOD');
    
    const enhancementContext = {
      powerMultiplier,
      temporalEnhanced,
      consciousnessEnhanced,
      jshEnhanced,
      godModeActive,
      terminal,
      symbols,
      luckyNumbers
    };
    
    return this.commands[subCommand](subArgs, enhancementContext);
  }

  /**
   * Create a new game
   */
  createGame(args, context) {
    const [gameType = 'divine_word', complexity = '1.0', dimension = '4'] = args;
    
    // Validate game type
    if (!this.gameTemplates[gameType] && gameType !== 'custom') {
      return {
        error: `Unknown game type: ${gameType}`,
        availableTemplates: this.gameTemplates,
        tip: "Use 'game list' to see all available game types"
      };
    }
    
    // Enhance game attributes based on context
    let enhancedGameType = gameType;
    if (context.jshEnhanced) enhancedGameType = `jsh_enhanced_${enhancedGameType}`;
    if (context.temporalEnhanced) enhancedGameType = `temporal_${enhancedGameType}`;
    if (context.consciousnessEnhanced) enhancedGameType = `consciousness_${enhancedGameType}`;
    if (context.godModeActive) enhancedGameType = `divine_${enhancedGameType}`;
    
    const actualComplexity = parseFloat(complexity) * context.powerMultiplier;
    let actualDimension = parseInt(dimension);
    
    // God mode unlocks higher dimensions
    if (context.godModeActive && actualDimension < 12) {
      actualDimension = 12;
    }
    
    // Selected game template or custom
    const gameTemplate = gameType === 'custom' ? 'custom' : this.gameTemplates[gameType];
    
    const game = this.luminousOS.createGame(enhancedGameType, actualComplexity, actualDimension, {
      terminal: context.terminal,
      template: gameTemplate,
      temporalVariant: context.temporalEnhanced ? 'multi-temporal' : 'sequential',
      consciousnessLevel: context.consciousnessEnhanced ? 'awakened' : 'standard',
      jshEnhanced: context.jshEnhanced,
      godMode: context.godModeActive
    });
    
    return {
      message: `Created ${enhancedGameType} game with complexity ${actualComplexity} in ${actualDimension} dimensions`,
      gameId: game.id,
      gameStructure: game.structure,
      systems: game.systems,
      accessCommands: game.accessCommands,
      visualElements: game.visualElements,
      dimensionalProperties: game.dimensionalProperties
    };
  }

  /**
   * Play an existing game
   */
  playGame(args, context) {
    const [gameId, mode = 'standard', players = '1'] = args;
    
    if (!gameId) {
      return { error: "Game ID is required to play a game" };
    }
    
    // Enhance game mode based on context
    let enhancedMode = mode;
    if (context.jshEnhanced) enhancedMode = `jsh_${enhancedMode}`;
    if (context.temporalEnhanced) enhancedMode = `temporal_${enhancedMode}`;
    if (context.consciousnessEnhanced) enhancedMode = `consciousness_${enhancedMode}`;
    if (context.godModeActive) enhancedMode = `divine_${enhancedMode}`;
    
    // Adjust player count for special modes
    let actualPlayers = parseInt(players);
    if (context.godModeActive && actualPlayers === 1) {
      actualPlayers = 12; // Divine game mode expands to symbolic 12 players
    }
    
    const gameSession = this.luminousOS.playGame(gameId, enhancedMode, actualPlayers, {
      terminal: context.terminal,
      powerLevel: context.powerMultiplier,
      temporalState: context.temporalEnhanced ? 'multi-temporal' : 'present',
      consciousnessState: context.consciousnessEnhanced ? 'awakened' : 'standard'
    });
    
    return {
      message: `Started ${enhancedMode} game session for ${gameId} with ${actualPlayers} players`,
      sessionId: gameSession.id,
      gameState: gameSession.initialState,
      commands: gameSession.availableCommands,
      visualState: gameSession.visualState,
      turnsSystem: gameSession.turnsSystem,
      dimensionalView: gameSession.dimensionalView
    };
  }

  /**
   * List available games
   */
  listGames(args, context) {
    const [filter = 'all', format = 'standard'] = args;
    
    // Determine actual filter based on context
    let actualFilter = filter;
    if (context.jshEnhanced && filter === 'all') {
      actualFilter = 'jsh';
    } else if (context.temporalEnhanced && filter === 'all') {
      actualFilter = 'temporal';
    } else if (context.consciousnessEnhanced && filter === 'all') {
      actualFilter = 'consciousness';
    }
    
    // Enhanced format if in god mode
    const actualFormat = context.godModeActive ? 'divine' : format;
    
    const gamesList = this.luminousOS.listGames(actualFilter, actualFormat, {
      terminal: context.terminal,
      detailLevel: context.powerMultiplier,
      includeHidden: context.godModeActive
    });
    
    return {
      message: `Available Games (Filter: ${actualFilter}, Format: ${actualFormat})`,
      games: gamesList.games,
      templates: context.godModeActive ? gamesList.allTemplates : this.gameTemplates,
      activeGames: gamesList.activeGames,
      recentGames: gamesList.recentGames,
      featuredGames: gamesList.featuredGames
    };
  }

  /**
   * Get game status
   */
  getStatus(args, context) {
    const [gameId = 'all'] = args;
    
    // Determine scope based on context
    let actualGameId = gameId;
    if (gameId === 'all' && context.jshEnhanced) {
      actualGameId = 'jsh_games';
    } else if (gameId === 'all' && context.temporalEnhanced) {
      actualGameId = 'temporal_games';
    } else if (gameId === 'all' && context.consciousnessEnhanced) {
      actualGameId = 'consciousness_games';
    }
    
    const status = this.luminousOS.getGameStatus(actualGameId, {
      detailLevel: context.powerMultiplier,
      terminal: context.terminal,
      includeHidden: context.godModeActive
    });
    
    return {
      message: `Game Status - ${actualGameId}`,
      status: status.status,
      activeGames: status.activeGames,
      activeSessions: status.activeSessions,
      activeUsers: status.activeUsers,
      systemResources: status.systemResources,
      dimensionalStability: status.dimensionalStability
    };
  }

  /**
   * Save game state
   */
  saveGame(args, context) {
    const [gameId, saveName = 'auto_save', includeState = 'true'] = args;
    
    if (!gameId) {
      return { error: "Game ID is required to save a game" };
    }
    
    // Enhance save name based on context
    let enhancedSaveName = saveName;
    if (context.jshEnhanced) enhancedSaveName = `jsh_${enhancedSaveName}`;
    if (context.temporalEnhanced) enhancedSaveName = `temporal_${enhancedSaveName}`;
    if (context.consciousnessEnhanced) enhancedSaveName = `consciousness_${enhancedSaveName}`;
    if (context.godModeActive) enhancedSaveName = `divine_${enhancedSaveName}`;
    
    // Parse includeState
    const shouldIncludeState = includeState.toLowerCase() === 'true';
    
    const saveResult = this.luminousOS.saveGame(gameId, enhancedSaveName, shouldIncludeState, {
      terminal: context.terminal,
      compressionLevel: context.powerMultiplier,
      saveTemporalState: context.temporalEnhanced,
      saveConsciousnessState: context.consciousnessEnhanced,
      divineProtection: context.godModeActive
    });
    
    return {
      message: `Saved game ${gameId} as ${enhancedSaveName} with state ${shouldIncludeState ? 'included' : 'excluded'}`,
      saveId: saveResult.id,
      timestamp: saveResult.timestamp,
      dataSize: saveResult.dataSize,
      includedSystems: saveResult.includedSystems,
      temporalBackups: saveResult.temporalBackups,
      divineProtection: saveResult.divineProtection
    };
  }

  /**
   * Load game state
   */
  loadGame(args, context) {
    const [saveId, gameTarget = 'new', restoreMode = 'full'] = args;
    
    if (!saveId) {
      return { error: "Save ID is required to load a game" };
    }
    
    // Enhance restore mode based on context
    let enhancedRestoreMode = restoreMode;
    if (context.jshEnhanced) enhancedRestoreMode = `jsh_${enhancedRestoreMode}`;
    if (context.temporalEnhanced) enhancedRestoreMode = `temporal_${enhancedRestoreMode}`;
    if (context.consciousnessEnhanced) enhancedRestoreMode = `consciousness_${enhancedRestoreMode}`;
    if (context.godModeActive) enhancedRestoreMode = `divine_${enhancedRestoreMode}`;
    
    const loadResult = this.luminousOS.loadGame(saveId, gameTarget, enhancedRestoreMode, {
      terminal: context.terminal,
      loadPower: context.powerMultiplier,
      temporalAlignment: context.temporalEnhanced ? 'multi-temporal' : 'present',
      consciousnessState: context.consciousnessEnhanced ? 'awakened' : 'standard'
    });
    
    return {
      message: `Loaded game save ${saveId} to ${gameTarget} with ${enhancedRestoreMode} restore mode`,
      loadId: loadResult.id,
      gameId: loadResult.gameId,
      restoredSystems: loadResult.restoredSystems,
      gameState: loadResult.gameState,
      temporalState: loadResult.temporalState,
      consciousnessState: loadResult.consciousnessState,
      divineProtection: loadResult.divineProtection
    };
  }

  /**
   * Combine multiple games
   */
  combineGames(args, context) {
    const [gameIds, resultName = 'combined_game'] = args;
    
    if (!gameIds) {
      return { error: "Game IDs are required for combination" };
    }
    
    const games = gameIds.split(',');
    
    if (games.length < 2) {
      return { error: "At least two games are required for combination" };
    }
    
    // Enhance result name based on context
    let enhancedName = resultName;
    if (context.jshEnhanced) enhancedName = `jsh_${enhancedName}`;
    if (context.temporalEnhanced) enhancedName = `temporal_${enhancedName}`;
    if (context.consciousnessEnhanced) enhancedName = `consciousness_${enhancedName}`;
    if (context.godModeActive) enhancedName = `divine_${enhancedName}`;
    
    const combination = this.luminousOS.combineGames(games, enhancedName, {
      powerMultiplier: context.powerMultiplier,
      terminal: context.terminal,
      divineInfluence: context.godModeActive,
      temporalMerge: context.temporalEnhanced,
      consciousnessIntegration: context.consciousnessEnhanced
    });
    
    return {
      message: `Combined games ${games.join(', ')} into ${enhancedName}`,
      combinationId: combination.id,
      resultGame: combination.gameData,
      complexityLevel: combination.complexityLevel * context.powerMultiplier,
      systemsIntegrated: combination.systemsIntegrated,
      dimensionalProperties: combination.dimensionalProperties
    };
  }

  /**
   * Activate God Mode for game
   */
  activateGodMode(args, context) {
    const [gameId, duration = 'session', powerLevel = '10.0'] = args;
    
    if (!gameId) {
      return { error: "Game ID is required to activate God Mode" };
    }
    
    // Only proceed if user has divine symbol or lucky L
    if (!context.godModeActive && !context.luckyNumbers.includes('L')) {
      return { 
        message: "Divine authorization required for God Mode",
        tip: "Add GOD symbol or L lucky number to enable divine functionality",
        currentStatus: "Unauthorized",
        gameId: gameId
      };
    }
    
    // Determine activation parameters
    const actualDuration = context.temporalEnhanced ? 'multi-temporal' : duration;
    const actualPowerLevel = parseFloat(powerLevel) * (context.luckyNumbers.includes('L') ? 12 : context.powerMultiplier);
    
    const godModeResult = this.luminousOS.activateGameGodMode(gameId, actualDuration, actualPowerLevel, {
      terminal: context.terminal,
      jshEnhanced: context.jshEnhanced,
      consciousnessState: context.consciousnessEnhanced ? 'awakened' : 'standard',
      temporalReach: context.temporalEnhanced ? 'omnipresent' : 'present'
    });
    
    return {
      message: `God Mode activated for game ${gameId} for ${actualDuration} at power level ${actualPowerLevel}`,
      godModeId: godModeResult.id,
      gameId: godModeResult.gameId,
      divineCapabilities: godModeResult.divineCapabilities,
      enhancedCommands: godModeResult.enhancedCommands,
      gameSignature: godModeResult.gameSignature,
      creatorPowers: godModeResult.creatorPowers
    };
  }

  /**
   * Organize games
   */
  organizeGames(args, context) {
    const [organizationType = 'standard', scope = 'all'] = args;
    
    // Enhance organization type based on context
    let enhancedType = organizationType;
    if (context.jshEnhanced) enhancedType = `jsh_${enhancedType}`;
    if (context.temporalEnhanced) enhancedType = `temporal_${enhancedType}`;
    if (context.consciousnessEnhanced) enhancedType = `consciousness_${enhancedType}`;
    if (context.godModeActive) enhancedType = `divine_${enhancedType}`;
    
    // Determine actual scope
    let actualScope = scope;
    if (scope === 'all' && context.jshEnhanced) {
      actualScope = 'jsh_games';
    } else if (scope === 'all' && context.temporalEnhanced) {
      actualScope = 'temporal_games';
    } else if (scope === 'all' && context.consciousnessEnhanced) {
      actualScope = 'consciousness_games';
    }
    
    const organizationResult = this.luminousOS.organizeGames(enhancedType, actualScope, {
      terminal: context.terminal,
      organizationPower: context.powerMultiplier,
      includeHidden: context.godModeActive
    });
    
    return {
      message: `Organized games using ${enhancedType} organization with scope ${actualScope}`,
      organizationId: organizationResult.id,
      gamesAffected: organizationResult.gamesAffected,
      newStructure: organizationResult.structureCreated,
      efficiencyGain: organizationResult.efficiencyGain * context.powerMultiplier,
      systemEnhancement: organizationResult.systemEnhancement
    };
  }

  /**
   * Display help information
   */
  getHelp() {
    return {
      message: "Game Command Handler",
      commands: {
        create: "Create a new game",
        play: "Play an existing game",
        list: "List available games",
        status: "Get game status",
        save: "Save game state",
        load: "Load game state",
        combine: "Combine multiple games",
        godmode: "Activate God Mode for game",
        organize: "Organize games"
      },
      gameTemplates: this.gameTemplates,
      enhancementSymbols: {
        "⌛": "Enables temporal enhancement",
        "🧠": "Enables consciousness enhancement",
        "JSH": "Enables JSH special enhancement",
        "GOD": "Enables divine/god mode"
      },
      luckyNumbers: {
        "4": "Consciousness multiplier",
        "7": "Manifestation multiplier",
        "8": "Infinity/expansion multiplier",
        "L": "Light/divine multiplier (12x)"
      },
      usage: "game [command] [args...] [symbols] [luckyNumbers]"
    };
  }
}

module.exports = new GameCommandHandler();