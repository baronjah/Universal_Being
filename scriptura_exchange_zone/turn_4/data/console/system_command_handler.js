/**
 * System Command Handler
 * Provides command interface for OCR, startup, compilation, and self-check systems
 * Part of the 12 Turns System - Turn 4 (Consciousness/Temporal Flow)
 */

const OCRSystem = require('../ocr_system');
const StartupAutomation = require('../startup_automation');
const GameCompiler = require('../game_compiler');
const SelfCheckSystem = require('../self_check_system');

class SystemCommandHandler {
  constructor() {
    this.ocrSystem = OCRSystem;
    this.startupAutomation = StartupAutomation;
    this.gameCompiler = GameCompiler;
    this.selfCheckSystem = SelfCheckSystem;
    
    this.commands = {
      // OCR commands
      "ocr": this.handleOCR.bind(this),
      "recognize": this.handleOCR.bind(this),
      "text": this.handleOCR.bind(this),
      
      // Startup commands
      "startup": this.handleStartup.bind(this),
      "automate": this.handleStartup.bind(this),
      "shortcut": this.handleShortcut.bind(this),
      
      // Compile commands
      "compile": this.handleCompile.bind(this),
      "build": this.handleCompile.bind(this),
      "world": this.handleBuildWorld.bind(this),
      
      // Self-check commands
      "check": this.handleSelfCheck.bind(this),
      "repair": this.handleRepair.bind(this),
      "status": this.handleStatus.bind(this),
      
      // Spell commands
      "spell": this.handleSpell.bind(this)
    };
    
    // Spell words and their functions
    this.spellWords = {
      "exti": { function: "healing", power: 7 },
      "vaeli": { function: "cleaning", power: 4 },
      "lemi": { function: "perspective", power: 8 },
      "pelo": { function: "integration", power: 5 }
    };
  }

  /**
   * Process system commands with lucky number and symbol enhancements
   */
  processCommand(args, terminal, symbols = [], luckyNumbers = []) {
    const [subCommand, ...subArgs] = args;
    
    if (!subCommand || !this.commands[subCommand.toLowerCase()]) {
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
    const divineMode = symbols.includes('GOD');
    
    const enhancementContext = {
      powerMultiplier,
      temporalEnhanced,
      consciousnessEnhanced,
      jshEnhanced,
      divineMode,
      terminal,
      symbols,
      luckyNumbers
    };
    
    // Check for spell words in the command
    const spellWords = subArgs.filter(arg => this.spellWords.hasOwnProperty(arg.toLowerCase()));
    const hasSpells = spellWords.length > 0;
    
    // Invoke the appropriate command handler
    return this.commands[subCommand.toLowerCase()](
      subArgs.filter(arg => !this.spellWords.hasOwnProperty(arg.toLowerCase())), // Remove spells from args
      {
        ...enhancementContext,
        spellEnhanced: hasSpells,
        spellWords: spellWords
      }
    );
  }

  /**
   * Handle OCR commands
   */
  handleOCR(args, context) {
    const [action = 'status', ...actionArgs] = args;
    
    switch (action.toLowerCase()) {
      case 'activate':
      case 'enable':
      case 'on':
        return this.ocrSystem.activate({
          engineLevel: actionArgs[0] || 'standard',
          modes: actionArgs[1] ? actionArgs[1].split(',') : ['text', 'symbols', 'numbers'],
          devices: actionArgs[2] ? actionArgs[2].split(',') : ['screen', 'clipboard', 'files'],
          powerLevel: context.powerMultiplier,
          temporalEnhanced: context.temporalEnhanced,
          consciousnessEnhanced: context.consciousnessEnhanced,
          jshEnhanced: context.jshEnhanced,
          divineMode: context.divineMode
        });
        
      case 'recognize':
      case 'scan':
        const source = actionArgs[0] || 'Current screen content would be scanned in a real implementation';
        return this.ocrSystem.recognizeText(source, {
          sourceType: actionArgs[1] || 'screen',
          region: actionArgs[2] || 'full',
          format: actionArgs[3] || 'text',
          enhancementLevel: context.powerMultiplier,
          temporalState: context.temporalEnhanced ? 'all' : 'present',
          consciousnessLevel: context.consciousnessEnhanced ? 'high' : 'standard',
          processSpells: context.spellEnhanced
        });
        
      case 'enhance':
        const enhancements = {};
        if (actionArgs[0]) enhancements.engine = actionArgs[0];
        if (actionArgs[1]) enhancements.mode = actionArgs[1].split(',');
        if (actionArgs[2]) enhancements.device = actionArgs[2].split(',');
        if (context.spellWords.length > 0) enhancements.spell = context.spellWords;
        
        return this.ocrSystem.enhanceCapabilities(enhancements, {
          powerLevel: context.powerMultiplier,
          jshEnhanced: context.jshEnhanced,
          spellFunction: context.spellWords.length > 0 ? 
            this.spellWords[context.spellWords[0]].function : null
        });
        
      case 'status':
      default:
        return this.ocrSystem.getStatus();
    }
  }

  /**
   * Handle startup automation commands
   */
  handleStartup(args, context) {
    const [action = 'status', ...actionArgs] = args;
    
    switch (action.toLowerCase()) {
      case 'setup':
      case 'configure':
      case 'init':
        return this.startupAutomation.setupAutomation({
          platform: actionArgs[0] || 'windows',
          components: actionArgs[1] ? actionArgs[1].split(',') : ['gameCreation', 'textRecognition'],
          autostart: actionArgs[2] === 'true' || context.jshEnhanced,
          startupDelay: parseInt(actionArgs[3] || '10'),
          powerLevel: context.powerMultiplier,
          userType: context.jshEnhanced ? 'jsh' : 'standard',
          temporalVariant: context.temporalEnhanced ? 'all' : 'present',
          spellEnhanced: context.spellEnhanced
        });
        
      case 'ocr':
      case 'enableocr':
        return this.startupAutomation.enableOCR({
          engines: actionArgs[0] ? actionArgs[0].split(',') : ['standard'],
          sources: actionArgs[1] ? actionArgs[1].split(',') : ['screen', 'clipboard'],
          autoCapture: actionArgs[2] === 'true' || context.temporalEnhanced,
          captureInterval: parseInt(actionArgs[3] || '60'),
          saveResults: actionArgs[4] !== 'false',
          resultFormat: actionArgs[5] || 'txt',
          powerLevel: context.powerMultiplier
        });
        
      case 'report':
      case 'reporting':
      case 'console':
        return this.startupAutomation.enableConsoleReporting({
          reportLevel: actionArgs[0] || context.jshEnhanced ? 'advanced' : 'standard',
          reportDestination: actionArgs[1] || 'file',
          includeTimestamp: actionArgs[2] !== 'false',
          includePowerLevel: actionArgs[3] !== 'false',
          autoReport: actionArgs[4] !== 'false' || context.temporalEnhanced,
          reportInterval: parseInt(actionArgs[5] || '300')
        });
        
      default:
        // Return simulated status
        return {
          status: "Startup automation status",
          configured: true,
          autoStart: context.jshEnhanced,
          components: {
            gameCreation: true,
            textRecognition: true,
            consoleReporting: true,
            selfCheck: context.consciousnessEnhanced
          },
          platform: "windows",
          startupFolder: "%APPDATA%\\Microsoft\\Windows\\Start Menu\\Programs\\Startup"
        };
    }
  }

  /**
   * Handle shortcut commands
   */
  handleShortcut(args, context) {
    const [action = 'create', ...actionArgs] = args;
    
    if (action.toLowerCase() === 'create' || action.toLowerCase() === 'add') {
      const apps = actionArgs[0] ? actionArgs[0].split(',') : ['game'];
      
      return this.startupAutomation.createShortcuts(apps, {
        destination: actionArgs[1] || 'desktop',
        shortcutType: context.jshEnhanced ? 'enhanced' : 'standard',
        combineApps: actionArgs[2] === 'true' || apps.length > 2,
        launchMode: context.divineMode ? 'admin' : 'normal',
        powerLevel: context.powerMultiplier
      });
    }
    
    return {
      error: "Unknown shortcut action",
      validActions: ['create', 'add']
    };
  }

  /**
   * Handle compile commands
   */
  handleCompile(args, context) {
    const [action = 'game', ...actionArgs] = args;
    
    if (action.toLowerCase() === 'game' || action.toLowerCase() === 'build') {
      return this.gameCompiler.compileGame({
        platform: actionArgs[0] || 'windows',
        buildConfiguration: context.divineMode ? 'godmode' : (actionArgs[1] || 'production'),
        outputFormat: actionArgs[2] || 'exe',
        outputDirectory: actionArgs[3] || 'dist',
        version: actionArgs[4] || '1.0.0',
        modules: actionArgs[5] ? actionArgs[5].split(',') : 
                context.jshEnhanced ? ['core', 'world', 'ui', 'api', 'physics', 'ai'] : 
                ['core', 'world', 'ui', 'api'],
        includeAssets: actionArgs[6] !== 'false',
        generateDocumentation: actionArgs[7] === 'true' || context.jshEnhanced,
        spellEnhanced: context.spellEnhanced,
        powerLevel: context.powerMultiplier,
        divineMode: context.divineMode
      });
    } else if (action.toLowerCase() === 'status') {
      return this.gameCompiler.getBuildStatus(actionArgs[0] || null);
    } else {
      return {
        error: "Unknown compile action",
        validActions: ['game', 'build', 'status']
      };
    }
  }

  /**
   * Handle world build commands
   */
  handleBuildWorld(args, context) {
    const [action = 'build', ...actionArgs] = args;
    
    if (action.toLowerCase() === 'build' || action.toLowerCase() === 'create') {
      return this.gameCompiler.buildWorld({
        worldSize: actionArgs[0] || context.divineMode ? 'infinite' : 'medium',
        dimensions: parseInt(actionArgs[1] || context.divineMode ? '12' : '4'),
        complexity: actionArgs[2] || context.divineMode ? 'divine' : 'standard',
        generationType: actionArgs[3] || 'procedural',
        themes: actionArgs[4] ? actionArgs[4].split(',') : ['default'],
        seedValue: parseInt(actionArgs[5] || Math.floor(Math.random() * 1000000)),
        includePresets: actionArgs[6] !== 'false',
        powerLevel: context.powerMultiplier,
        spellEnhanced: context.spellEnhanced,
        divineMode: context.divineMode
      });
    } else {
      return {
        error: "Unknown world action",
        validActions: ['build', 'create']
      };
    }
  }

  /**
   * Handle self-check commands
   */
  handleSelfCheck(args, context) {
    const [action = 'perform', ...actionArgs] = args;
    
    switch (action.toLowerCase()) {
      case 'perform':
      case 'run':
      case 'start':
        return this.selfCheckSystem.performCheck({
          components: actionArgs[0] ? actionArgs[0].split(',') : ['all'],
          checkLevel: actionArgs[1] || context.divineMode ? 'divine' : 
                      context.jshEnhanced ? 'advanced' : 'standard',
          autoRepair: actionArgs[2] === 'true' || context.jshEnhanced,
          reportLevel: actionArgs[3] || context.consciousnessEnhanced ? 'diagnostic' : 'detailed',
          spellEnhanced: context.spellEnhanced,
          powerLevel: context.powerMultiplier,
          divineMode: context.divineMode
        });
        
      case 'creation':
        // Special command for self-check creation
        return this.selfCheckSystem.performCheck({
          components: ['core', 'game', 'world'],
          checkLevel: context.divineMode ? 'divine' : 'advanced',
          autoRepair: true,
          reportLevel: 'detailed',
          spellEnhanced: true,
          powerLevel: context.powerMultiplier * 2,
          divineMode: context.divineMode
        });
        
      default:
        return {
          error: "Unknown self-check action",
          validActions: ['perform', 'run', 'start', 'creation']
        };
    }
  }

  /**
   * Handle repair commands
   */
  handleRepair(args, context) {
    const [action = 'system', ...actionArgs] = args;
    
    if (action.toLowerCase() === 'system' || action.toLowerCase() === 'fix') {
      return this.selfCheckSystem.repairSystem({
        components: actionArgs[0] ? actionArgs[0].split(',') : ['all'],
        repairLevel: actionArgs[1] || context.divineMode ? 'divine' : 
                    context.jshEnhanced ? 'advanced' : 'standard',
        forceRepair: actionArgs[2] === 'true' || context.divineMode,
        backupBeforeRepair: actionArgs[3] !== 'false',
        spellEnhanced: context.spellEnhanced,
        powerLevel: context.powerMultiplier
      });
    } else {
      return {
        error: "Unknown repair action",
        validActions: ['system', 'fix']
      };
    }
  }

  /**
   * Handle status commands
   */
  handleStatus(args, context) {
    return this.selfCheckSystem.getSystemStatus();
  }

  /**
   * Handle spell commands
   */
  handleSpell(args, context) {
    const [spellWord = '', target = 'system', power = '1.0'] = args;
    
    // Check if spell word is valid
    if (!this.spellWords.hasOwnProperty(spellWord.toLowerCase())) {
      return {
        error: "Unknown spell word",
        validSpells: Object.keys(this.spellWords),
        spellInfo: this.spellWords
      };
    }
    
    // Get spell details
    const spell = this.spellWords[spellWord.toLowerCase()];
    const actualPower = parseFloat(power) * context.powerMultiplier * spell.power;
    
    // Apply spell effects based on target
    switch (target.toLowerCase()) {
      case 'system':
        return this.selfCheckSystem.repairSystem({
          components: ['all'],
          repairLevel: 'advanced',
          forceRepair: true,
          backupBeforeRepair: true,
          spellEnhanced: true,
          powerLevel: actualPower / 10
        });
        
      case 'ocr':
        return this.ocrSystem.enhanceCapabilities(
          { spell: [spellWord] },
          { powerLevel: actualPower / 10, spellFunction: spell.function }
        );
        
      case 'game':
        return this.gameCompiler.compileGame({
          platform: 'windows',
          buildConfiguration: 'production',
          outputFormat: 'exe',
          spellEnhanced: true,
          powerLevel: actualPower / 10,
          spellWords: [spellWord]
        });
        
      case 'world':
        return this.gameCompiler.buildWorld({
          worldSize: 'medium',
          dimensions: 4,
          complexity: 'standard',
          spellEnhanced: true,
          powerLevel: actualPower / 10,
          spellWords: [spellWord]
        });
        
      default:
        return {
          error: "Unknown spell target",
          validTargets: ['system', 'ocr', 'game', 'world']
        };
    }
  }

  /**
   * Get help information
   */
  getHelp() {
    return {
      message: "System Command Handler",
      commands: {
        ocr: {
          description: "Manage OCR capabilities",
          subcommands: ["activate", "recognize", "enhance", "status"]
        },
        startup: {
          description: "Manage startup automation",
          subcommands: ["setup", "ocr", "report"]
        },
        shortcut: {
          description: "Manage application shortcuts",
          subcommands: ["create"]
        },
        compile: {
          description: "Compile the game",
          subcommands: ["game", "status"]
        },
        world: {
          description: "Build game world",
          subcommands: ["build"]
        },
        check: {
          description: "Perform system self-check",
          subcommands: ["perform", "creation"]
        },
        repair: {
          description: "Repair system issues",
          subcommands: ["system"]
        },
        status: {
          description: "Get system status",
          subcommands: []
        },
        spell: {
          description: "Cast spell words",
          spellWords: this.spellWords,
          targets: ["system", "ocr", "game", "world"]
        }
      },
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
      usage: "system [command] [args...] [symbols] [luckyNumbers]"
    };
  }
}

module.exports = new SystemCommandHandler();