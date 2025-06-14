/**
 * Light Command Handler
 * Provides command interface for the Light System
 * Part of the 12 Turns System - Turn 4 (Consciousness/Temporal Flow)
 */

const LuminousOS = require('./luminous_os').LuminousOS;

class LightCommandHandler {
  constructor() {
    this.luminousOS = new LuminousOS();
    this.commands = {
      create: this.createLight.bind(this),
      update: this.updateLight.bind(this),
      illuminate: this.illuminateArea.bind(this),
      pulse: this.createPulse.bind(this),
      pattern: this.createPattern.bind(this),
      combine: this.combinePatterns.bind(this),
      reset: this.resetLight.bind(this),
      godmode: this.activateGodMode.bind(this),
      game: this.createLightGame.bind(this),
      organize: this.organizePatterns.bind(this),
      terminal: this.terminalLight.bind(this),
      list: this.listCommands.bind(this),
      status: this.getStatus.bind(this),
    };
    
    // Special number meanings
    this.numberMeanings = {
      2: "duality/balance", 
      11: "spiritual awakening",
      29: "reset/new beginning"
    };
  }

  /**
   * Process light commands with lucky number and symbol enhancements
   */
  processCommand(args, terminal, symbols = [], luckyNumbers = []) {
    const [subCommand, ...subArgs] = args;
    
    // Handle numerical commands based on their spiritual meaning
    if (!isNaN(parseInt(subCommand))) {
      const number = parseInt(subCommand);
      
      if (number === 29) {
        // 29 means reset
        return this.resetLight(subArgs, { terminal, symbols, luckyNumbers });
      } else if (number === 11) {
        // 11 means spiritual awakening
        return this.illuminateArea(["consciousness", "awakening"], { terminal, symbols, luckyNumbers });
      } else if (number === 2) {
        // 2 means duality/balance
        return this.createPattern(["balance", "dual"], { terminal, symbols, luckyNumbers });
      }
    }
    
    // Process regular commands
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
   * Create a new light source
   */
  createLight(args, context) {
    const [type = 'ambient', intensity = '1.0', color = 'white'] = args;
    
    // Enhanced light types based on symbols
    let enhancedType = type;
    if (context.jshEnhanced) enhancedType = `jsh_${enhancedType}`;
    if (context.temporalEnhanced) enhancedType = `temporal_${enhancedType}`;
    if (context.consciousnessEnhanced) enhancedType = `consciousness_${enhancedType}`;
    if (context.godModeActive) enhancedType = `divine_${enhancedType}`;
    
    // Intensity multiplier based on lucky numbers
    const actualIntensity = parseFloat(intensity) * context.powerMultiplier;
    
    const light = this.luminousOS.createLight(enhancedType, actualIntensity, color, {
      terminal: context.terminal,
      temporalState: context.temporalEnhanced ? 'multi-temporal' : 'present',
      consciousnessLevel: context.consciousnessEnhanced ? 'awakened' : 'standard',
      divineInfluence: context.godModeActive
    });
    
    return {
      message: `Created ${enhancedType} light at intensity ${actualIntensity} with color ${color}`,
      lightId: light.id,
      affectedSystems: light.affectedSystems,
      visualImpact: light.visualElements,
      temporalResonance: light.temporalResonance
    };
  }

  /**
   * Update an existing light source
   */
  updateLight(args, context) {
    const [lightId, attribute, value] = args;
    
    if (!lightId) {
      return { error: "Light ID is required for update" };
    }
    
    if (!attribute || !value) {
      return { error: "Both attribute and value are required for update" };
    }
    
    const validAttributes = ['intensity', 'color', 'pattern', 'frequency', 'range'];
    
    if (!validAttributes.includes(attribute)) {
      return { 
        error: `Invalid attribute: ${attribute}`,
        validAttributes
      };
    }
    
    // Apply multipliers and enhancements based on context
    let enhancedValue = value;
    if (attribute === 'intensity') {
      enhancedValue = parseFloat(value) * context.powerMultiplier;
    } else if (attribute === 'range') {
      enhancedValue = parseFloat(value) * (context.godModeActive ? 12 : context.powerMultiplier);
    } else if (attribute === 'pattern') {
      if (context.jshEnhanced) enhancedValue = `jsh_${enhancedValue}`;
      if (context.temporalEnhanced) enhancedValue = `temporal_${enhancedValue}`;
      if (context.consciousnessEnhanced) enhancedValue = `consciousness_${enhancedValue}`;
      if (context.godModeActive) enhancedValue = `divine_${enhancedValue}`;
    }
    
    const updateResult = this.luminousOS.updateLight(lightId, attribute, enhancedValue, {
      terminal: context.terminal,
      userLevel: context.godModeActive ? 'divine' : 'standard',
      temporalContext: context.temporalEnhanced ? 'multi-temporal' : 'present'
    });
    
    return {
      message: `Updated ${lightId} ${attribute} to ${enhancedValue}`,
      previous: updateResult.previousValue,
      current: updateResult.currentValue,
      affectedSystems: updateResult.affectedSystems,
      visualChange: updateResult.visualChange
    };
  }

  /**
   * Illuminate an area with light
   */
  illuminateArea(args, context) {
    const [area = 'local', intensity = '1.0', duration = 'permanent'] = args;
    
    // Enhance area based on context
    let enhancedArea = area;
    if (context.jshEnhanced) enhancedArea = `jsh_${enhancedArea}`;
    if (context.temporalEnhanced) enhancedArea = `temporal_${enhancedArea}`;
    if (context.consciousnessEnhanced) enhancedArea = `consciousness_${enhancedArea}`;
    if (context.godModeActive) enhancedArea = `divine_${enhancedArea}`;
    
    // Adjust intensity and duration based on context
    const actualIntensity = parseFloat(intensity) * context.powerMultiplier;
    let actualDuration = duration;
    if (context.godModeActive && duration !== 'permanent') {
      actualDuration = 'eternal';
    } else if (context.temporalEnhanced) {
      actualDuration = 'multi-temporal';
    }
    
    const illumination = this.luminousOS.illuminateArea(enhancedArea, actualIntensity, actualDuration, {
      terminal: context.terminal,
      consciousnessLevel: context.consciousnessEnhanced ? 'awakened' : 'standard',
      divineInfluence: context.godModeActive
    });
    
    return {
      message: `Illuminated ${enhancedArea} at intensity ${actualIntensity} for ${actualDuration} duration`,
      illuminationId: illumination.id,
      affectedRegions: illumination.affectedRegions,
      visualElements: illumination.visualElements,
      consciousnessImpact: illumination.consciousnessImpact,
      temporalReach: illumination.temporalReach
    };
  }

  /**
   * Create a pulsing light effect
   */
  createPulse(args, context) {
    const [frequency = 'medium', intensity = '1.0', color = 'white'] = args;
    
    // Enhance attributes based on context
    let enhancedFrequency = frequency;
    if (context.temporalEnhanced) {
      if (frequency === 'low') enhancedFrequency = 'temporal_slow';
      else if (frequency === 'medium') enhancedFrequency = 'temporal_medium';
      else if (frequency === 'high') enhancedFrequency = 'temporal_rapid';
      else enhancedFrequency = `temporal_${frequency}`;
    }
    
    if (context.godModeActive) {
      enhancedFrequency = `divine_${enhancedFrequency}`;
    }
    
    const actualIntensity = parseFloat(intensity) * context.powerMultiplier;
    
    // Create pulse with enhanced parameters
    const pulse = this.luminousOS.createPulse(enhancedFrequency, actualIntensity, color, {
      terminal: context.terminal,
      consciousnessResonance: context.consciousnessEnhanced,
      jshEnhanced: context.jshEnhanced,
      divineMode: context.godModeActive
    });
    
    return {
      message: `Created ${enhancedFrequency} pulse at intensity ${actualIntensity} with ${color} color`,
      pulseId: pulse.id,
      visualEffects: pulse.visualEffects,
      consciousnessImpact: pulse.consciousnessImpact,
      temporalResonance: pulse.temporalResonance,
      divineQuality: pulse.divineQuality
    };
  }

  /**
   * Create a light pattern
   */
  createPattern(args, context) {
    const [type = 'simple', complexity = '1.0', colors = 'white'] = args;
    
    // Enhance pattern type based on context
    let enhancedType = type;
    if (context.jshEnhanced) enhancedType = `jsh_${enhancedType}`;
    if (context.temporalEnhanced) enhancedType = `temporal_${enhancedType}`;
    if (context.consciousnessEnhanced) enhancedType = `consciousness_${enhancedType}`;
    if (context.godModeActive) enhancedType = `divine_${enhancedType}`;
    
    // Adjust complexity and color handling
    const actualComplexity = parseFloat(complexity) * context.powerMultiplier;
    let colorArray = colors.split(',');
    
    if (context.godModeActive) {
      colorArray.push('divine_gold', 'divine_white');
    }
    
    if (context.temporalEnhanced) {
      colorArray.push('temporal_blue', 'time_green');
    }
    
    if (context.consciousnessEnhanced) {
      colorArray.push('consciousness_purple', 'mind_indigo');
    }
    
    const pattern = this.luminousOS.createPattern(enhancedType, actualComplexity, colorArray, {
      terminal: context.terminal,
      userLevel: context.godModeActive ? 'divine' : 'standard',
      temporalContext: context.temporalEnhanced ? 'multi-temporal' : 'present',
      consciousnessLevel: context.consciousnessEnhanced ? 'awakened' : 'standard'
    });
    
    return {
      message: `Created ${enhancedType} pattern with complexity ${actualComplexity} using colors ${colorArray.join(', ')}`,
      patternId: pattern.id,
      visualElements: pattern.visualElements,
      complexityRating: pattern.complexityRating,
      dimensionalDepth: pattern.dimensionalDepth,
      temporalReach: pattern.temporalReach,
      divineQuality: pattern.divineQuality
    };
  }

  /**
   * Combine multiple light patterns
   */
  combinePatterns(args, context) {
    const [patternIds, resultName = 'combined_pattern'] = args;
    
    if (!patternIds) {
      return { error: "Pattern IDs are required for combination" };
    }
    
    const patterns = patternIds.split(',');
    
    if (patterns.length < 2) {
      return { error: "At least two patterns are required for combination" };
    }
    
    // Enhance result name based on context
    let enhancedName = resultName;
    if (context.jshEnhanced) enhancedName = `jsh_${enhancedName}`;
    if (context.temporalEnhanced) enhancedName = `temporal_${enhancedName}`;
    if (context.consciousnessEnhanced) enhancedName = `consciousness_${enhancedName}`;
    if (context.godModeActive) enhancedName = `divine_${enhancedName}`;
    
    const combination = this.luminousOS.combinePatterns(patterns, enhancedName, {
      powerMultiplier: context.powerMultiplier,
      terminal: context.terminal,
      divineInfluence: context.godModeActive,
      temporalMerge: context.temporalEnhanced,
      consciousnessIntegration: context.consciousnessEnhanced
    });
    
    return {
      message: `Combined patterns ${patterns.join(', ')} into ${enhancedName}`,
      combinationId: combination.id,
      resultPattern: combination.patternData,
      complexityLevel: combination.complexityLevel * context.powerMultiplier,
      energySignature: combination.energySignature,
      dimensionalProperties: combination.dimensionalProperties
    };
  }

  /**
   * Reset light systems
   */
  resetLight(args, context) {
    const [scope = 'current', preservePatterns = 'false'] = args;
    
    // Determine reset scope based on context
    let actualScope = scope;
    if (context.godModeActive) {
      actualScope = 'all';
    } else if (context.temporalEnhanced) {
      actualScope = 'temporal';
    } else if (context.jshEnhanced) {
      actualScope = 'jsh_domain';
    }
    
    const shouldPreservePatterns = preservePatterns.toLowerCase() === 'true';
    
    const resetResult = this.luminousOS.resetLightSystems(actualScope, shouldPreservePatterns, {
      terminal: context.terminal,
      resetLevel: context.godModeActive ? 'divine' : 'standard',
      temporalPreservation: context.temporalEnhanced,
      consciousnessState: context.consciousnessEnhanced ? 'preserved' : 'reset'
    });
    
    return {
      message: `Reset light systems with scope ${actualScope}, patterns ${shouldPreservePatterns ? 'preserved' : 'reset'}`,
      resetId: resetResult.id,
      systemsAffected: resetResult.systemsAffected,
      preservedElements: resetResult.preservedElements,
      newDefaultState: resetResult.newDefaultState
    };
  }

  /**
   * Activate God Mode for light system
   */
  activateGodMode(args, context) {
    const [duration = 'session', intensity = '10.0'] = args;
    
    // Only proceed if user has divine symbol or lucky L
    if (!context.godModeActive && !context.luckyNumbers.includes('L')) {
      return { 
        message: "Divine authorization required for God Mode",
        tip: "Add GOD symbol or L lucky number to enable divine functionality",
        currentStatus: "Unauthorized"
      };
    }
    
    // Determine activation parameters
    const actualDuration = context.temporalEnhanced ? 'multi-temporal' : duration;
    const actualIntensity = parseFloat(intensity) * (context.luckyNumbers.includes('L') ? 12 : context.powerMultiplier);
    
    const godModeResult = this.luminousOS.activateGodMode(actualDuration, actualIntensity, {
      terminal: context.terminal,
      jshEnhanced: context.jshEnhanced,
      consciousnessState: context.consciousnessEnhanced ? 'awakened' : 'standard',
      temporalReach: context.temporalEnhanced ? 'omnipresent' : 'present'
    });
    
    return {
      message: `God Mode activated for ${actualDuration} at intensity ${actualIntensity}`,
      godModeId: godModeResult.id,
      divineCapabilities: godModeResult.divineCapabilities,
      enhancedCommands: godModeResult.enhancedCommands,
      lightSignature: godModeResult.lightSignature,
      universeInfluence: godModeResult.universeInfluence
    };
  }

  /**
   * Create a light-based game
   */
  createLightGame(args, context) {
    const [gameType = 'standard', complexity = '1.0', players = '1'] = args;
    
    // Enhance game type based on context
    let enhancedType = gameType;
    if (context.jshEnhanced) enhancedType = `jsh_${enhancedType}`;
    if (context.temporalEnhanced) enhancedType = `temporal_${enhancedType}`;
    if (context.consciousnessEnhanced) enhancedType = `consciousness_${enhancedType}`;
    if (context.godModeActive) enhancedType = `divine_${enhancedType}`;
    
    // Adjust complexity and players
    const actualComplexity = parseFloat(complexity) * context.powerMultiplier;
    let actualPlayers = parseInt(players);
    
    if (context.godModeActive && actualPlayers === 1) {
      actualPlayers = 12; // Divine game mode expands to symbolic 12 players
    }
    
    const game = this.luminousOS.createLightGame(enhancedType, actualComplexity, actualPlayers, {
      terminal: context.terminal,
      dimensionalLevel: context.godModeActive ? 'divine' : 'standard',
      temporalRules: context.temporalEnhanced ? 'multi-temporal' : 'sequential',
      consciousnessIntegration: context.consciousnessEnhanced
    });
    
    return {
      message: `Created ${enhancedType} light game with complexity ${actualComplexity} for ${actualPlayers} players`,
      gameId: game.id,
      gameRules: game.rules,
      lightElements: game.lightElements,
      interactionModes: game.interactionModes,
      gameObjectives: game.objectives,
      dimensionalProperties: game.dimensionalProperties
    };
  }

  /**
   * Organize light patterns
   */
  organizePatterns(args, context) {
    const [organizationType = 'standard', scope = 'current'] = args;
    
    // Enhance organization type based on context
    let enhancedType = organizationType;
    if (context.jshEnhanced) enhancedType = `jsh_${enhancedType}`;
    if (context.temporalEnhanced) enhancedType = `temporal_${enhancedType}`;
    if (context.consciousnessEnhanced) enhancedType = `consciousness_${enhancedType}`;
    if (context.godModeActive) enhancedType = `divine_${enhancedType}`;
    
    // Determine actual scope
    let actualScope = scope;
    if (context.godModeActive) {
      actualScope = 'all';
    } else if (context.temporalEnhanced) {
      actualScope = 'multi-temporal';
    }
    
    const organizationResult = this.luminousOS.organizePatterns(enhancedType, actualScope, {
      terminal: context.terminal,
      organizationPower: context.powerMultiplier,
      jshEnhanced: context.jshEnhanced,
      consciousnessAlignment: context.consciousnessEnhanced
    });
    
    return {
      message: `Organized patterns using ${enhancedType} organization with scope ${actualScope}`,
      organizationId: organizationResult.id,
      patternsAffected: organizationResult.patternsAffected,
      newStructure: organizationResult.structureCreated,
      efficiencyGain: organizationResult.efficiencyGain * context.powerMultiplier,
      visualEnhancement: organizationResult.visualEnhancement
    };
  }

  /**
   * Configure terminal light integration
   */
  terminalLight(args, context) {
    const [terminalId = context.terminal, mode = 'standard', intensity = '1.0'] = args;
    
    // Enhance mode based on context
    let enhancedMode = mode;
    if (context.jshEnhanced) enhancedMode = `jsh_${enhancedMode}`;
    if (context.temporalEnhanced) enhancedMode = `temporal_${enhancedMode}`;
    if (context.consciousnessEnhanced) enhancedMode = `consciousness_${enhancedMode}`;
    if (context.godModeActive) enhancedMode = `divine_${enhancedMode}`;
    
    const actualIntensity = parseFloat(intensity) * context.powerMultiplier;
    
    const terminalConfig = this.luminousOS.configureTerminalLight(terminalId, enhancedMode, actualIntensity, {
      userLevel: context.godModeActive ? 'divine' : 'standard',
      temporalState: context.temporalEnhanced ? 'multi-temporal' : 'present',
      consciousnessEnhancement: context.consciousnessEnhanced
    });
    
    return {
      message: `Configured ${terminalId} terminal with ${enhancedMode} light mode at intensity ${actualIntensity}`,
      configId: terminalConfig.id,
      terminalCapabilities: terminalConfig.newCapabilities,
      visualMode: terminalConfig.visualMode,
      commandEnhancements: terminalConfig.enhancedCommands,
      lightSignature: terminalConfig.lightSignature
    };
  }

  /**
   * List all available commands
   */
  listCommands(args, context) {
    const [format = 'standard'] = args;
    
    // Enhanced format if in god mode
    const actualFormat = context.godModeActive ? 'divine' : format;
    
    // Get command list with enhancements based on context
    const commandResult = this.luminousOS.getCommandList('light', actualFormat, {
      terminal: context.terminal,
      userLevel: context.godModeActive ? 'divine' : 'standard',
      temporalVariants: context.temporalEnhanced,
      consciousnessEnhancements: context.consciousnessEnhanced
    });
    
    return {
      message: `Available Light System Commands (Format: ${actualFormat})`,
      commands: commandResult.commands,
      specialNumbers: this.numberMeanings,
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
      }
    };
  }

  /**
   * Get status of light systems
   */
  getStatus(args, context) {
    const [component = 'all'] = args;
    
    // Determine components to check based on context
    let componentsToCheck = [component];
    
    if (component === 'all') {
      componentsToCheck = ['lights', 'patterns', 'games', 'terminals'];
      
      if (context.temporalEnhanced) {
        componentsToCheck.push('temporal_lights');
      }
      
      if (context.consciousnessEnhanced) {
        componentsToCheck.push('consciousness_lights');
      }
      
      if (context.godModeActive) {
        componentsToCheck.push('divine_lights');
      }
    }
    
    const status = this.luminousOS.getLightSystemStatus(componentsToCheck, {
      detailLevel: context.powerMultiplier,
      terminal: context.terminal
    });
    
    return {
      message: `Light System Status - ${componentsToCheck.join(', ')}`,
      status: status.components,
      activeLights: status.activeLights,
      activePatterns: status.activePatterns,
      activeGames: status.activeGames,
      terminalsConfigured: status.terminalsConfigured,
      godModeStatus: status.godModeStatus,
      systemHealth: status.systemHealth
    };
  }

  /**
   * Display help information
   */
  getHelp() {
    return {
      message: "Light Command Handler",
      commands: {
        create: "Create a new light source",
        update: "Update an existing light",
        illuminate: "Illuminate an area with light",
        pulse: "Create a pulsing light effect",
        pattern: "Create a light pattern",
        combine: "Combine multiple light patterns",
        reset: "Reset light systems",
        godmode: "Activate God Mode for light system",
        game: "Create a light-based game",
        organize: "Organize light patterns",
        terminal: "Configure terminal light integration",
        list: "List all available commands",
        status: "Get status of light systems"
      },
      specialNumbers: this.numberMeanings,
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
      usage: "light [command] [args...] [symbols] [luckyNumbers]"
    };
  }
}

module.exports = new LightCommandHandler();