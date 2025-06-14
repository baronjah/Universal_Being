/**
 * Console Command Interface
 * Main interface for processing console commands across the 12 Turns System
 * Turn 4 (Consciousness/Temporal Flow)
 */

const apiCommandHandler = require('./api_command_handler');
const accelerationCommandHandler = require('./acceleration_command_handler');
const accountCommandHandler = require('./account_command_handler');
const projectCommandHandler = require('./project_command_handler');
const shapeCommandHandler = require('./shape_command_handler');
const mergerCommandHandler = require('./merger_command_handler');
const luminousCommandHandler = require('./luminous_command_handler');
const lightCommandHandler = require('../light_command_handler');
const gameCommandHandler = require('../game_command_handler');
const continueCommandHandler = require('../continue_command_handler');
const systemCommandHandler = require('./system_command_handler');

class ConsoleCommandInterface {
  constructor() {
    this.commandHandlers = {
      'api': apiCommandHandler,
      'acceleration': accelerationCommandHandler,
      'account': accountCommandHandler,
      'project': projectCommandHandler,
      'shape': shapeCommandHandler,
      'merger': mergerCommandHandler,
      'luminous': luminousCommandHandler,
      'light': lightCommandHandler,
      'game': gameCommandHandler,
      'continue': continueCommandHandler,
      'system': systemCommandHandler,
      // Add aliases for common commands
      'update_of_light': lightCommandHandler,
      'update': lightCommandHandler,
      'create': lightCommandHandler,
      'create_game': gameCommandHandler,
      'organize': gameCommandHandler,
      'god': lightCommandHandler,
      'godmode': gameCommandHandler,
      'combine': gameCommandHandler,
      'commands': lightCommandHandler,
      'list': gameCommandHandler,
      'yes': continueCommandHandler,
      // OCR and system commands
      'ocr': systemCommandHandler,
      'text': systemCommandHandler,
      'recognize': systemCommandHandler,
      'compile': systemCommandHandler,
      'build': systemCommandHandler,
      'world': systemCommandHandler,
      'check': systemCommandHandler,
      'self': systemCommandHandler,
      'repair': systemCommandHandler,
      'startup': systemCommandHandler,
      'shortcut': systemCommandHandler,
      'spell': systemCommandHandler
    };
  }

  /**
   * Process a command string and route to appropriate handler
   * Supports symbols and lucky numbers for enhanced capabilities
   */
  processCommand(commandString, terminal = 'core0') {
    // Parse command string
    const { command, args, symbols, luckyNumbers } = this.parseCommandString(commandString);

    // Handle continuation commands specially
    if (command === 'continue' || command === 'yes') {
      const continueResult = continueCommandHandler.processCommand(args, terminal, symbols, luckyNumbers);

      // If we got a command to continue, execute it
      if (continueResult.commandToContinue) {
        const continuedCommand = continueResult.commandToContinue;
        const handler = this.commandHandlers[continuedCommand.command];

        if (handler) {
          const result = handler.processCommand(
            continuedCommand.args,
            terminal,
            continuedCommand.symbols,
            continuedCommand.luckyNumbers
          );

          return {
            message: `Continued: ${continuedCommand.command}`,
            originalCommand: continuedCommand.command,
            continuationResult: result,
            continuationType: continueResult.continuationType
          };
        }
      } else if (continueResult.commandsToContinue) {
        // Process a sequence of commands
        const results = continueResult.commandsToContinue.map(continuedCommand => {
          const handler = this.commandHandlers[continuedCommand.command];

          if (handler) {
            return handler.processCommand(
              continuedCommand.args,
              terminal,
              continuedCommand.symbols,
              continuedCommand.luckyNumbers
            );
          }

          return { error: `Unknown command: ${continuedCommand.command}` };
        });

        return {
          message: `Continued sequence of ${results.length} commands`,
          continuationResults: results,
          continuationType: continueResult.continuationType
        };
      }

      return continueResult;
    }

    // Route to appropriate handler for regular commands
    if (this.commandHandlers[command]) {
      const result = this.commandHandlers[command].processCommand(args, terminal, symbols, luckyNumbers);

      // Register command for potential continuation
      if (command !== 'help') {
        continueCommandHandler.registerCommand(command, args, symbols, luckyNumbers, result, terminal);
      }

      return result;
    }

    // Handle unknown commands
    return this.getHelp(command);
  }

  /**
   * Parse a command string to extract command, args, symbols, and lucky numbers
   * Supports special syntax: command arg1 arg2 [symbol1 symbol2] {luckyNumber1 luckyNumber2}
   * Also supports shorthand commands:
   * - Numbers like 29, 11, 2 are special commands
   * - "yes" and "continue on yes" indicates continuation of previous command
   * - Phrases like "god mode on" automatically activate god mode
   */
  parseCommandString(commandString) {
    // Handle shorthand inputs first
    if (commandString.trim().toLowerCase() === "yes" ||
        commandString.trim().toLowerCase() === "continue on yes") {
      return {
        command: "continue",
        args: ["previous"],
        symbols: ["JSH"],
        luckyNumbers: [7]
      };
    }

    if (commandString.trim().toLowerCase() === "god mode on") {
      return {
        command: "godmode",
        args: ["activate"],
        symbols: ["GOD", "JSH"],
        luckyNumbers: ["L"]
      };
    }

    // Special number handling (pass through to the light command handler)
    if (/^\d+$/.test(commandString.trim())) {
      return {
        command: "light",
        args: [commandString.trim()],
        symbols: [],
        luckyNumbers: []
      };
    }

    // Extract symbols: [JSH ⌛ 🧠]
    const symbolRegex = /\[(.*?)\]/;
    const symbolMatch = commandString.match(symbolRegex);
    const symbols = symbolMatch ? symbolMatch[1].split(/\s+/).filter(Boolean) : [];

    // Extract lucky numbers: {4 7 8 L}
    const luckyNumberRegex = /\{(.*?)\}/;
    const luckyNumberMatch = commandString.match(luckyNumberRegex);
    const luckyNumbers = luckyNumberMatch ?
      luckyNumberMatch[1].split(/\s+/).filter(Boolean).map(n => n === 'L' ? 'L' : parseInt(n)) :
      [];

    // Remove symbol and lucky number sections
    let cleanCommand = commandString
      .replace(symbolRegex, '')
      .replace(luckyNumberRegex, '')
      .trim();

    // Split into command and args
    const parts = cleanCommand.split(/\s+/);
    const command = parts[0].toLowerCase();
    const args = parts.slice(1);

    // Handle special command formats
    if (command === "to_doos" || command === "do" && args[0] === "to_doos") {
      return { command: "organize", args: ["all"], symbols: ["JSH"], luckyNumbers: [7] };
    }

    if (command === "update" && args[0] === "to" && args[1] === "doos") {
      return { command: "organize", args: ["update"], symbols: ["JSH", "⌛"], luckyNumbers: [7] };
    }

    if (command === "command" && args[0] === "lists") {
      return { command: "commands", args: ["all"], symbols: [], luckyNumbers: [] };
    }

    if (command === "we" && args[0] === "combine" && args[1] === "it" && args[2] === "all") {
      return { command: "combine", args: ["all"], symbols: ["JSH", "GOD"], luckyNumbers: ["L"] };
    }

    if (command === "lets" && args[0] === "continue" && args[1] === "and" && args[2] === "create") {
      return { command: "create_game", args: ["all_combined"], symbols: ["JSH", "⌛", "🧠"], luckyNumbers: [7, 8] };
    }

    if (command === "literal" && args[0] === "game") {
      return { command: "game", args: ["create", "divine_word"], symbols: ["JSH"], luckyNumbers: [4] };
    }

    // OCR and text recognition commands
    if (command === "turn" && args[0] === "on" && args[1] === "ocr") {
      return { command: "ocr", args: ["activate", "all", "screen,clipboard,files", "true"], symbols: ["JSH"], luckyNumbers: [7] };
    }

    if (command === "compile" && args[0] === "game") {
      return { command: "compile", args: ["game", "windows", "production", "exe"], symbols: ["JSH"], luckyNumbers: [7] };
    }

    // Self-check commands
    if (command === "self" && args[0] === "check") {
      return { command: "check", args: ["perform", "all", "standard", "true"], symbols: [], luckyNumbers: [] };
    }

    if (command === "self" && args[0] === "check" && args[1] === "creation") {
      return { command: "check", args: ["creation"], symbols: ["JSH", "GOD"], luckyNumbers: [7] };
    }

    // Spell word commands - check for the four spell words
    const spellWords = ["exti", "vaeli", "lemi", "pelo"];
    if (spellWords.includes(command.toLowerCase())) {
      return { command: "spell", args: [command.toLowerCase(), "system", "1.0"], symbols: ["JSH"], luckyNumbers: [7] };
    }

    // Combined spell command
    if (spellWords.includes(args[0]?.toLowerCase()) &&
        spellWords.includes(args[1]?.toLowerCase()) &&
        spellWords.includes(args[2]?.toLowerCase()) &&
        spellWords.includes(args[3]?.toLowerCase())) {
      return { command: "spell", args: [args[0].toLowerCase(), "system", "7.8"], symbols: ["JSH", "GOD"], luckyNumbers: ["L"] };
    }

    return { command, args, symbols, luckyNumbers };
  }

  /**
   * Get help information
   */
  getHelp(specificCommand = null) {
    if (specificCommand && this.commandHandlers[specificCommand]) {
      return this.commandHandlers[specificCommand].getHelp();
    }
    
    return {
      message: "12 Turns System Console - Turn 4 (Consciousness/Temporal Flow)",
      availableCommands: Object.keys(this.commandHandlers),
      enhancementSymbols: {
        "⌛": "Enables temporal enhancement",
        "🧠": "Enables consciousness enhancement",
        "JSH": "Enables JSH special enhancement"
      },
      luckyNumbers: {
        "4": "Consciousness multiplier",
        "7": "Manifestation multiplier",
        "8": "Infinity/expansion multiplier",
        "L": "Light-based multiplier"
      },
      usage: "command [args...] [symbols] [luckyNumbers]",
      example: "api translate 'Hello world' [JSH ⌛] {4 7}"
    };
  }
}

module.exports = new ConsoleCommandInterface();