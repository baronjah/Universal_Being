/**
 * Continue Command Handler
 * Handles continuation of previous operations
 * Part of the 12 Turns System - Turn 4 (Consciousness/Temporal Flow)
 */

class ContinueCommandHandler {
  constructor() {
    this.previousCommands = {};
    this.previousResults = {};
    this.commands = {
      previous: this.continuePrevious.bind(this),
      enhance: this.enhancePrevious.bind(this),
      all: this.continueAll.bind(this),
      literal: this.continueLiteral.bind(this)
    };
  }

  /**
   * Register a command execution for potential continuation
   */
  registerCommand(command, args, symbols, luckyNumbers, result, terminal) {
    if (!this.previousCommands[terminal]) {
      this.previousCommands[terminal] = [];
      this.previousResults[terminal] = [];
    }
    
    // Keep last 10 commands per terminal
    if (this.previousCommands[terminal].length >= 10) {
      this.previousCommands[terminal].shift();
      this.previousResults[terminal].shift();
    }
    
    this.previousCommands[terminal].push({
      command,
      args,
      symbols,
      luckyNumbers,
      timestamp: Date.now()
    });
    
    this.previousResults[terminal].push(result);
  }

  /**
   * Process continue commands with lucky number and symbol enhancements
   */
  processCommand(args, terminal, symbols = [], luckyNumbers = []) {
    const [subCommand = 'previous', ...subArgs] = args;
    
    if (!this.commands[subCommand]) {
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
   * Continue the previous command
   */
  continuePrevious(args, context) {
    if (!this.previousCommands[context.terminal] || 
        this.previousCommands[context.terminal].length === 0) {
      return { 
        error: "No previous command to continue",
        terminal: context.terminal
      };
    }
    
    // Get the most recent command
    const previousCommand = this.previousCommands[context.terminal][this.previousCommands[context.terminal].length - 1];
    const previousResult = this.previousResults[context.terminal][this.previousResults[context.terminal].length - 1];
    
    // Enhance the previous command based on current context
    const enhancedCommand = { ...previousCommand };
    
    // Merge symbols (keep unique)
    const uniqueSymbols = [...new Set([...previousCommand.symbols, ...context.symbols])];
    
    // Merge lucky numbers (keep unique)
    const uniqueNumbers = [...new Set([...previousCommand.luckyNumbers, ...context.luckyNumbers])];
    
    // Compose the enhanced command object
    enhancedCommand.symbols = uniqueSymbols;
    enhancedCommand.luckyNumbers = uniqueNumbers;
    enhancedCommand.continued = true;
    enhancedCommand.previousResult = previousResult;
    
    // Return the enhanced command for execution
    return {
      message: `Continuing ${previousCommand.command} command with enhanced context`,
      commandToContinue: enhancedCommand,
      continuationType: "direct",
      terminal: context.terminal,
      timestamp: Date.now()
    };
  }

  /**
   * Enhance the previous command with additional power
   */
  enhancePrevious(args, context) {
    if (!this.previousCommands[context.terminal] || 
        this.previousCommands[context.terminal].length === 0) {
      return { 
        error: "No previous command to enhance",
        terminal: context.terminal
      };
    }
    
    // Get the most recent command
    const previousCommand = this.previousCommands[context.terminal][this.previousCommands[context.terminal].length - 1];
    const previousResult = this.previousResults[context.terminal][this.previousResults[context.terminal].length - 1];
    
    // Create a significantly enhanced version with increased power
    const enhancedCommand = { ...previousCommand };
    
    // Add all enhancement symbols if not present
    if (!enhancedCommand.symbols.includes('JSH')) enhancedCommand.symbols.push('JSH');
    if (!enhancedCommand.symbols.includes('⌛')) enhancedCommand.symbols.push('⌛');
    if (!enhancedCommand.symbols.includes('🧠')) enhancedCommand.symbols.push('🧠');
    
    // Add god mode if requested
    if (context.godModeActive && !enhancedCommand.symbols.includes('GOD')) {
      enhancedCommand.symbols.push('GOD');
    }
    
    // Enhance lucky numbers
    enhancedCommand.luckyNumbers = [4, 7, 8];
    if (context.luckyNumbers.includes('L')) {
      enhancedCommand.luckyNumbers.push('L');
    }
    
    // Mark as enhanced continuation
    enhancedCommand.continued = true;
    enhancedCommand.enhanced = true;
    enhancedCommand.previousResult = previousResult;
    
    // Return the enhanced command for execution
    return {
      message: `Enhancing ${previousCommand.command} command with maximum power`,
      commandToContinue: enhancedCommand,
      continuationType: "enhanced",
      terminal: context.terminal,
      timestamp: Date.now()
    };
  }

  /**
   * Continue all previous commands in sequence
   */
  continueAll(args, context) {
    if (!this.previousCommands[context.terminal] || 
        this.previousCommands[context.terminal].length <= 1) {
      return { 
        error: "Not enough previous commands to continue all",
        terminal: context.terminal,
        commandCount: this.previousCommands[context.terminal]?.length || 0
      };
    }
    
    // Get the last five commands (or fewer if not available)
    const commandCount = Math.min(5, this.previousCommands[context.terminal].length);
    const recentCommands = this.previousCommands[context.terminal].slice(-commandCount);
    const recentResults = this.previousResults[context.terminal].slice(-commandCount);
    
    // Enhance all commands with current context
    const enhancedCommands = recentCommands.map((cmd, index) => {
      const enhancedCmd = { ...cmd };
      
      // Merge symbols (keep unique)
      const uniqueSymbols = [...new Set([...cmd.symbols, ...context.symbols])];
      
      // Merge lucky numbers (keep unique)
      const uniqueNumbers = [...new Set([...cmd.luckyNumbers, ...context.luckyNumbers])];
      
      // Add continuation metadata
      enhancedCmd.symbols = uniqueSymbols;
      enhancedCmd.luckyNumbers = uniqueNumbers;
      enhancedCmd.continued = true;
      enhancedCmd.previousResult = recentResults[index];
      
      return enhancedCmd;
    });
    
    // Return the command sequence for execution
    return {
      message: `Continuing sequence of ${commandCount} previous commands with enhanced context`,
      commandsToContinue: enhancedCommands,
      continuationType: "sequence",
      terminal: context.terminal,
      timestamp: Date.now()
    };
  }

  /**
   * Continue with a literal interpretation of previous command
   */
  continueLiteral(args, context) {
    if (!this.previousCommands[context.terminal] || 
        this.previousCommands[context.terminal].length === 0) {
      return { 
        error: "No previous command for literal continuation",
        terminal: context.terminal
      };
    }
    
    // Get the most recent command
    const previousCommand = this.previousCommands[context.terminal][this.previousCommands[context.terminal].length - 1];
    const previousResult = this.previousResults[context.terminal][this.previousResults[context.terminal].length - 1];
    
    // Create a literal interpretation by adding 'literal' to the command
    const literalCommand = { ...previousCommand };
    literalCommand.args = ['literal', ...literalCommand.args];
    
    // Add JSH symbol if not present for creator permissions
    if (!literalCommand.symbols.includes('JSH')) {
      literalCommand.symbols.push('JSH');
    }
    
    // Mark as literal continuation
    literalCommand.continued = true;
    literalCommand.literal = true;
    literalCommand.previousResult = previousResult;
    
    // Return the literal command for execution
    return {
      message: `Continuing ${previousCommand.command} command with literal interpretation`,
      commandToContinue: literalCommand,
      continuationType: "literal",
      terminal: context.terminal,
      timestamp: Date.now()
    };
  }

  /**
   * Display help information
   */
  getHelp() {
    return {
      message: "Continue Command Handler",
      commands: {
        previous: "Continue the previous command",
        enhance: "Enhance previous command with additional power",
        all: "Continue all previous commands in sequence",
        literal: "Continue with a literal interpretation of previous command"
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
      usage: "continue [subcommand] [args...] [symbols] {luckyNumbers}"
    };
  }
}

module.exports = new ContinueCommandHandler();