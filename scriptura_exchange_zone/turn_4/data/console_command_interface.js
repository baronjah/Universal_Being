/**
 * Console Command Interface
 * Turn 4 (Temporal Flow) - 12 Turns Word Game
 * 
 * Provides a unified interface for console commands across terminals,
 * with support for turn phases, file management, and evolution.
 */

class ConsoleCommandInterface {
    constructor() {
        this.basePath = "/mnt/c/Users/Percision 15/12_turns_system";
        this.commandHistory = [];
        this.phaseManager = null;
        this.currentTerminal = "Core 1";
        this.commandHandlers = new Map();
        this.luckyNumbers = [4, 7, 8, 'L'];
        this.symbols = new Map();
        this.activeSessions = new Map();
        this.gameFiles = new Map();
        this.updateQueue = [];
    }

    /**
     * Initialize the console interface
     */
    initialize() {
        console.log("Initializing Console Command Interface for Turn 4");
        
        // Load Phase Manager if available
        try {
            const { PhaseManager } = require('./phase_manager.js');
            this.phaseManager = new PhaseManager(this.basePath);
            this.phaseManager.initialize();
            console.log("Phase Manager loaded successfully");
        } catch (error) {
            console.error(`Failed to load Phase Manager: ${error.message}`);
            // Create a minimal phase manager
            this.phaseManager = {
                currentTurn: 4,
                executeConsoleCommand: () => ({ error: "Phase Manager not available" }),
                getConsoleCommands: () => []
            };
        }
        
        // Register core commands
        this.registerCommand("help", (args) => this.handleHelpCommand(args));
        this.registerCommand("ls", (args) => this.handleListCommand(args));
        this.registerCommand("cd", (args) => this.handleChangeDirectoryCommand(args));
        this.registerCommand("cat", (args) => this.handleViewFileCommand(args));
        this.registerCommand("edit", (args) => this.handleEditFileCommand(args));
        this.registerCommand("mkdir", (args) => this.handleMakeDirectoryCommand(args));
        this.registerCommand("touch", (args) => this.handleCreateFileCommand(args));
        this.registerCommand("rm", (args) => this.handleRemoveCommand(args));
        this.registerCommand("cp", (args) => this.handleCopyCommand(args));
        this.registerCommand("mv", (args) => this.handleMoveCommand(args));
        this.registerCommand("clear", (args) => this.handleClearCommand(args));
        this.registerCommand("history", (args) => this.handleHistoryCommand(args));
        this.registerCommand("terminal", (args) => this.handleTerminalCommand(args));
        
        // Register game-specific commands
        this.registerCommand("claude", (args) => this.handleClaudeCommand(args));
        this.registerCommand("operate", (args) => this.handleOperateCommand(args));
        this.registerCommand("npm", (args) => this.handleNpmCommand(args));
        this.registerCommand("node", (args) => this.handleNodeCommand(args));
        this.registerCommand("api", (args) => this.handleApiCommand(args));
        this.registerCommand("accelerate", (args) => this.handleAccelerateCommand(args));
        this.registerCommand("account", (args) => this.handleAccountCommand(args));
        this.registerCommand("project", (args) => this.handleProjectCommand(args));
        this.registerCommand("shape", (args) => this.handleShapeCommand(args));
        this.registerCommand("merger", (args) => this.handleMergerCommand(args));

        // Register turn-specific commands (delegate to phase manager)
        this.registerCommand("turn", (args) => this.phaseManager.handleTurnCommand(args));
        this.registerCommand("phase", (args) => this.phaseManager.handlePhaseCommand(args));
        this.registerCommand("evolve", (args) => this.phaseManager.handleEvolveCommand(args));
        this.registerCommand("stitch", (args) => this.phaseManager.handleStitchCommand(args));
        this.registerCommand("update", (args) => this.phaseManager.handleUpdateCommand(args));
        
        // Register symbol commands
        this.registerSymbol("JSH", "Core identity symbol");
        this.registerSymbol("⌛", "Temporal flow");
        this.registerSymbol("🧠", "Consciousness and awareness");
        this.registerSymbol("∞", "Infinite possibilities");
        this.registerSymbol("⚡", "Speed and acceleration");
        this.registerSymbol("🔄", "Change and difference");
        
        // Scan for game files
        this.scanGameFiles();
        
        return {
            status: "initialized",
            terminal: this.currentTerminal,
            turn: this.phaseManager.currentTurn,
            commands: this.getRegisteredCommands()
        };
    }
    
    /**
     * Register a command
     */
    registerCommand(name, handler) {
        this.commandHandlers.set(name, handler);
        return true;
    }
    
    /**
     * Register a symbol
     */
    registerSymbol(symbol, description) {
        this.symbols.set(symbol, {
            symbol: symbol,
            description: description,
            registered: new Date()
        });
        return true;
    }
    
    /**
     * Execute a command
     */
    executeCommand(commandLine, terminal = null) {
        if (terminal) {
            this.currentTerminal = terminal;
        }
        
        // Add to history
        this.commandHistory.push({
            command: commandLine,
            terminal: this.currentTerminal,
            timestamp: new Date()
        });
        
        // Parse command line
        const trimmedCommand = commandLine.trim();
        if (!trimmedCommand) {
            return { result: "" };
        }
        
        // Check for lucky number prefix
        let luckyNumber = null;
        let effectiveCommand = trimmedCommand;
        
        for (const num of this.luckyNumbers) {
            if (trimmedCommand.startsWith(`${num} `)) {
                luckyNumber = num;
                effectiveCommand = trimmedCommand.substring(String(num).length).trim();
                break;
            }
        }
        
        // Check for symbol prefix
        let activeSymbol = null;
        for (const symbol of this.symbols.keys()) {
            if (effectiveCommand.startsWith(`${symbol} `) || 
                effectiveCommand.startsWith(`${symbol}-`)) {
                activeSymbol = symbol;
                effectiveCommand = effectiveCommand.substring(symbol.length).trim();
                if (effectiveCommand.startsWith('-')) {
                    effectiveCommand = effectiveCommand.substring(1).trim();
                }
                break;
            }
        }
        
        // Parse base command and args
        const parts = effectiveCommand.split(/\s+/);
        const baseCommand = parts[0];
        const args = parts.slice(1);
        
        // Calculate power multiplier based on lucky number
        let powerMultiplier = 1.0;
        if (luckyNumber === 4) powerMultiplier = 1.4;
        if (luckyNumber === 7) powerMultiplier = 1.7;
        if (luckyNumber === 8) powerMultiplier = 1.8;
        if (luckyNumber === 'L') powerMultiplier = 1.5;
        
        // Add symbol power if applicable
        if (activeSymbol) {
            powerMultiplier += 0.2;
        }
        
        // Special case for turn-specific commands
        if (['turn', 'phase', 'evolve', 'stitch', 'update'].includes(baseCommand)) {
            const result = this.phaseManager.executeConsoleCommand(effectiveCommand);
            return {
                command: commandLine,
                baseCommand: baseCommand,
                args: args,
                luckyNumber: luckyNumber,
                symbol: activeSymbol,
                powerMultiplier: powerMultiplier,
                result: result,
                terminal: this.currentTerminal
            };
        }
        
        // Find handler for base command
        if (this.commandHandlers.has(baseCommand)) {
            const handler = this.commandHandlers.get(baseCommand);
            const result = handler(args);
            
            return {
                command: commandLine,
                baseCommand: baseCommand,
                args: args,
                luckyNumber: luckyNumber,
                symbol: activeSymbol,
                powerMultiplier: powerMultiplier,
                result: result,
                terminal: this.currentTerminal
            };
        }
        
        // Command not found
        return {
            command: commandLine,
            error: `Command not found: ${baseCommand}`,
            suggestions: this.getSuggestions(baseCommand),
            terminal: this.currentTerminal
        };
    }
    
    /**
     * Get suggestions for a mistyped command
     */
    getSuggestions(command) {
        const allCommands = Array.from(this.commandHandlers.keys());
        
        // Find commands that start with the same letter
        const sameLetter = allCommands.filter(cmd => cmd[0] === command[0]);
        
        // Find similar commands (simple Levenshtein)
        const similar = allCommands.filter(cmd => {
            const distance = this.getLevenshteinDistance(command, cmd);
            return distance <= 2; // Allow up to 2 character differences
        });
        
        return [...new Set([...sameLetter, ...similar])].slice(0, 3);
    }
    
    /**
     * Calculate Levenshtein distance between two strings
     */
    getLevenshteinDistance(str1, str2) {
        const m = str1.length;
        const n = str2.length;
        
        // Create matrix
        const dp = Array(m + 1).fill().map(() => Array(n + 1).fill(0));
        
        // Initialize
        for (let i = 0; i <= m; i++) dp[i][0] = i;
        for (let j = 0; j <= n; j++) dp[0][j] = j;
        
        // Fill matrix
        for (let i = 1; i <= m; i++) {
            for (let j = 1; j <= n; j++) {
                const cost = str1[i - 1] === str2[j - 1] ? 0 : 1;
                dp[i][j] = Math.min(
                    dp[i - 1][j] + 1,      // deletion
                    dp[i][j - 1] + 1,      // insertion
                    dp[i - 1][j - 1] + cost // substitution
                );
            }
        }
        
        return dp[m][n];
    }
    
    /**
     * Get registered commands
     */
    getRegisteredCommands() {
        return Array.from(this.commandHandlers.keys());
    }
    
    /**
     * Scan for game files
     */
    scanGameFiles() {
        const fs = require('fs');
        const path = require('path');
        
        const scanDir = (dirPath, relativePath = "") => {
            if (!fs.existsSync(dirPath)) {
                return;
            }
            
            const entries = fs.readdirSync(dirPath, { withFileTypes: true });
            
            for (const entry of entries) {
                const fullPath = path.join(dirPath, entry.name);
                const relPath = path.join(relativePath, entry.name);
                
                if (entry.isDirectory()) {
                    // Scan subdirectory
                    scanDir(fullPath, relPath);
                } else if (entry.isFile()) {
                    // Add file to gameFiles map
                    this.gameFiles.set(relPath, {
                        name: entry.name,
                        path: fullPath,
                        relativePath: relPath,
                        extension: path.extname(entry.name),
                        size: fs.statSync(fullPath).size,
                        mtime: fs.statSync(fullPath).mtime
                    });
                }
            }
        };
        
        // Scan the base path
        scanDir(this.basePath);
        
        console.log(`Found ${this.gameFiles.size} game files`);
    }
    
    // ---- Command Handlers ----
    
    /**
     * Handle 'help' command
     */
    handleHelpCommand(args) {
        // Basic help
        if (!args.length) {
            const allCommands = this.getRegisteredCommands();
            
            return {
                message: "Available commands:",
                commands: allCommands.sort(),
                usage: "help [command]",
                note: "For more information on a specific command, type 'help command'."
            };
        }
        
        // Help for specific command
        const commandName = args[0];
        
        // Special case for turn-specific commands
        if (['turn', 'phase', 'evolve', 'stitch', 'update'].includes(commandName)) {
            const phaseCommands = this.phaseManager.getConsoleCommands();
            const commandInfo = phaseCommands.find(cmd => cmd.name === commandName);
            
            if (commandInfo) {
                return {
                    command: commandName,
                    description: commandInfo.description,
                    usage: commandInfo.usage,
                    example: commandInfo.example
                };
            }
        }
        
        // Regular command help
        const descriptions = {
            help: "Display help information about available commands",
            ls: "List files and directories",
            cd: "Change current directory",
            cat: "Display file contents",
            edit: "Edit file contents",
            mkdir: "Create a new directory",
            touch: "Create a new file",
            rm: "Remove files or directories",
            cp: "Copy files or directories",
            mv: "Move or rename files or directories",
            clear: "Clear the console screen",
            history: "Show command history",
            terminal: "Switch between terminals",
            claude: "Activate Claude AI in terminal",
            operate: "Control system operations across terminals",
            npm: "Node package manager for JavaScript",
            node: "Execute JavaScript runtime",
            turn: "Display or change current turn",
            phase: "Display phase information",
            evolve: "Evolve game to next phase",
            stitch: "Connect files across turns",
            update: "Update game components"
        };
        
        const usage = {
            help: "help [command]",
            ls: "ls [path]",
            cd: "cd [path]",
            cat: "cat <file>",
            edit: "edit <file> [content]",
            mkdir: "mkdir <directory>",
            touch: "touch <file>",
            rm: "rm <file|directory> [-r]",
            cp: "cp <source> <destination>",
            mv: "mv <source> <destination>",
            clear: "clear",
            history: "history [count]",
            terminal: "terminal [name]",
            claude: "claude <prompt>",
            operate: "operate <action> [options]",
            npm: "npm <command> [options]",
            node: "node <file|code>",
            turn: "turn [number]",
            phase: "phase [number]",
            evolve: "evolve [component]",
            stitch: "stitch <source_file> <target_file>",
            update: "update [component]"
        };
        
        if (descriptions[commandName]) {
            return {
                command: commandName,
                description: descriptions[commandName],
                usage: usage[commandName] || `${commandName}`
            };
        }
        
        return {
            error: `No help available for '${commandName}'`,
            suggestion: "Type 'help' for a list of all commands."
        };
    }
    
    /**
     * Handle 'ls' command
     */
    handleListCommand(args) {
        const fs = require('fs');
        const path = require('path');
        
        let targetPath = this.basePath;
        if (args.length > 0) {
            const relativePath = args[0];
            targetPath = path.resolve(this.basePath, relativePath);
        }
        
        // Check that path is within game directory
        if (!targetPath.startsWith(this.basePath)) {
            return {
                error: "Access denied: Path must be within game directory"
            };
        }
        
        if (!fs.existsSync(targetPath)) {
            return {
                error: `Path not found: ${args[0] || ''}`
            };
        }
        
        try {
            const entries = fs.readdirSync(targetPath, { withFileTypes: true });
            const files = [];
            const directories = [];
            
            for (const entry of entries) {
                if (entry.isDirectory()) {
                    directories.push({
                        name: entry.name,
                        type: "directory"
                    });
                } else {
                    const stats = fs.statSync(path.join(targetPath, entry.name));
                    files.push({
                        name: entry.name,
                        type: "file",
                        size: stats.size,
                        modified: stats.mtime
                    });
                }
            }
            
            return {
                path: targetPath.replace(this.basePath, '').replace(/^\//, '') || '/',
                directories: directories.sort((a, b) => a.name.localeCompare(b.name)),
                files: files.sort((a, b) => a.name.localeCompare(b.name)),
                count: directories.length + files.length
            };
        } catch (error) {
            return {
                error: `Failed to list directory: ${error.message}`
            };
        }
    }
    
    /**
     * Handle 'cd' command
     */
    handleChangeDirectoryCommand(args) {
        // Not implementing actual directory change here, as the command interface is abstract
        // But we can validate that the directory exists
        
        const fs = require('fs');
        const path = require('path');
        
        let targetPath = this.basePath;
        if (args.length > 0) {
            const relativePath = args[0];
            targetPath = path.resolve(this.basePath, relativePath);
        }
        
        // Check that path is within game directory
        if (!targetPath.startsWith(this.basePath)) {
            return {
                error: "Access denied: Path must be within game directory"
            };
        }
        
        if (!fs.existsSync(targetPath)) {
            return {
                error: `Directory not found: ${args[0] || ''}`
            };
        }
        
        if (!fs.statSync(targetPath).isDirectory()) {
            return {
                error: `Not a directory: ${args[0] || ''}`
            };
        }
        
        return {
            message: `Changed directory to: ${targetPath.replace(this.basePath, '').replace(/^\//, '') || '/'}`
        };
    }
    
    /**
     * Handle 'cat' command
     */
    handleViewFileCommand(args) {
        if (args.length === 0) {
            return {
                error: "File path required"
            };
        }
        
        const fs = require('fs');
        const path = require('path');
        
        const relativePath = args[0];
        const filePath = path.resolve(this.basePath, relativePath);
        
        // Check that path is within game directory
        if (!filePath.startsWith(this.basePath)) {
            return {
                error: "Access denied: Path must be within game directory"
            };
        }
        
        if (!fs.existsSync(filePath)) {
            return {
                error: `File not found: ${relativePath}`
            };
        }
        
        if (fs.statSync(filePath).isDirectory()) {
            return {
                error: `Cannot display directory contents: ${relativePath}`
            };
        }
        
        try {
            const content = fs.readFileSync(filePath, 'utf8');
            return {
                file: relativePath,
                content: content
            };
        } catch (error) {
            return {
                error: `Failed to read file: ${error.message}`
            };
        }
    }
    
    /**
     * Handle 'edit' command
     */
    handleEditFileCommand(args) {
        if (args.length === 0) {
            return {
                error: "File path required"
            };
        }
        
        const fs = require('fs');
        const path = require('path');
        
        const relativePath = args[0];
        const filePath = path.resolve(this.basePath, relativePath);
        
        // Check that path is within game directory
        if (!filePath.startsWith(this.basePath)) {
            return {
                error: "Access denied: Path must be within game directory"
            };
        }
        
        // If file exists, but args length is 1, return current content for editing
        if (fs.existsSync(filePath) && !fs.statSync(filePath).isDirectory() && args.length === 1) {
            try {
                const content = fs.readFileSync(filePath, 'utf8');
                return {
                    file: relativePath,
                    content: content,
                    message: "File opened for editing"
                };
            } catch (error) {
                return {
                    error: `Failed to read file: ${error.message}`
                };
            }
        }
        
        // Extract content (everything after the file path)
        const content = args.slice(1).join(' ');
        
        // Create parent directory if it doesn't exist
        const dirPath = path.dirname(filePath);
        if (!fs.existsSync(dirPath)) {
            try {
                fs.mkdirSync(dirPath, { recursive: true });
            } catch (error) {
                return {
                    error: `Failed to create directory: ${error.message}`
                };
            }
        }
        
        // Write content to file
        try {
            fs.writeFileSync(filePath, content);
            
            // Update game files map
            this.gameFiles.set(relativePath, {
                name: path.basename(filePath),
                path: filePath,
                relativePath: relativePath,
                extension: path.extname(filePath),
                size: fs.statSync(filePath).size,
                mtime: fs.statSync(filePath).mtime
            });
            
            return {
                file: relativePath,
                message: fs.existsSync(filePath) ? "File updated successfully" : "File created successfully",
                size: fs.statSync(filePath).size
            };
        } catch (error) {
            return {
                error: `Failed to write file: ${error.message}`
            };
        }
    }
    
    /**
     * Handle 'mkdir' command
     */
    handleMakeDirectoryCommand(args) {
        if (args.length === 0) {
            return {
                error: "Directory path required"
            };
        }
        
        const fs = require('fs');
        const path = require('path');
        
        const relativePath = args[0];
        const dirPath = path.resolve(this.basePath, relativePath);
        
        // Check that path is within game directory
        if (!dirPath.startsWith(this.basePath)) {
            return {
                error: "Access denied: Path must be within game directory"
            };
        }
        
        if (fs.existsSync(dirPath)) {
            return {
                error: `Directory already exists: ${relativePath}`
            };
        }
        
        try {
            fs.mkdirSync(dirPath, { recursive: true });
            return {
                message: `Directory created: ${relativePath}`
            };
        } catch (error) {
            return {
                error: `Failed to create directory: ${error.message}`
            };
        }
    }
    
    /**
     * Handle 'touch' command
     */
    handleCreateFileCommand(args) {
        if (args.length === 0) {
            return {
                error: "File path required"
            };
        }
        
        const fs = require('fs');
        const path = require('path');
        
        const relativePath = args[0];
        const filePath = path.resolve(this.basePath, relativePath);
        
        // Check that path is within game directory
        if (!filePath.startsWith(this.basePath)) {
            return {
                error: "Access denied: Path must be within game directory"
            };
        }
        
        // Create parent directory if it doesn't exist
        const dirPath = path.dirname(filePath);
        if (!fs.existsSync(dirPath)) {
            try {
                fs.mkdirSync(dirPath, { recursive: true });
            } catch (error) {
                return {
                    error: `Failed to create directory: ${error.message}`
                };
            }
        }
        
        try {
            // Create empty file if it doesn't exist, or update timestamp if it does
            const fd = fs.openSync(filePath, 'a');
            fs.closeSync(fd);
            fs.utimesSync(filePath, new Date(), new Date());
            
            // Update game files map
            this.gameFiles.set(relativePath, {
                name: path.basename(filePath),
                path: filePath,
                relativePath: relativePath,
                extension: path.extname(filePath),
                size: fs.statSync(filePath).size,
                mtime: fs.statSync(filePath).mtime
            });
            
            return {
                message: fs.existsSync(filePath) ? "File timestamp updated" : "File created",
                file: relativePath
            };
        } catch (error) {
            return {
                error: `Failed to create file: ${error.message}`
            };
        }
    }
    
    /**
     * Handle 'rm' command
     */
    handleRemoveCommand(args) {
        if (args.length === 0) {
            return {
                error: "File or directory path required"
            };
        }
        
        const fs = require('fs');
        const path = require('path');
        
        // Check for recursive flag
        const recursive = args.includes('-r') || args.includes('-R') || args.includes('--recursive');
        if (recursive) {
            // Remove recursive flag from args
            args = args.filter(arg => arg !== '-r' && arg !== '-R' && arg !== '--recursive');
        }
        
        if (args.length === 0) {
            return {
                error: "File or directory path required"
            };
        }
        
        const relativePath = args[0];
        const targetPath = path.resolve(this.basePath, relativePath);
        
        // Check that path is within game directory
        if (!targetPath.startsWith(this.basePath)) {
            return {
                error: "Access denied: Path must be within game directory"
            };
        }
        
        if (!fs.existsSync(targetPath)) {
            return {
                error: `Path not found: ${relativePath}`
            };
        }
        
        try {
            const isDirectory = fs.statSync(targetPath).isDirectory();
            
            if (isDirectory && !recursive) {
                return {
                    error: `Cannot remove directory without recursive flag: use rm -r ${relativePath}`
                };
            }
            
            if (isDirectory && recursive) {
                fs.rmdirSync(targetPath, { recursive: true });
                return {
                    message: `Directory removed: ${relativePath}`
                };
            } else {
                fs.unlinkSync(targetPath);
                
                // Remove from game files map
                if (this.gameFiles.has(relativePath)) {
                    this.gameFiles.delete(relativePath);
                }
                
                return {
                    message: `File removed: ${relativePath}`
                };
            }
        } catch (error) {
            return {
                error: `Failed to remove: ${error.message}`
            };
        }
    }
    
    /**
     * Handle 'cp' command
     */
    handleCopyCommand(args) {
        if (args.length < 2) {
            return {
                error: "Source and destination paths required"
            };
        }
        
        const fs = require('fs');
        const path = require('path');
        
        const sourcePath = path.resolve(this.basePath, args[0]);
        const destPath = path.resolve(this.basePath, args[1]);
        
        // Check that paths are within game directory
        if (!sourcePath.startsWith(this.basePath) || !destPath.startsWith(this.basePath)) {
            return {
                error: "Access denied: Paths must be within game directory"
            };
        }
        
        if (!fs.existsSync(sourcePath)) {
            return {
                error: `Source path not found: ${args[0]}`
            };
        }
        
        try {
            const isDirectory = fs.statSync(sourcePath).isDirectory();
            
            if (isDirectory) {
                return {
                    error: "Directory copy not implemented"
                };
            }
            
            // Create destination directory if it doesn't exist
            const destDir = path.dirname(destPath);
            if (!fs.existsSync(destDir)) {
                fs.mkdirSync(destDir, { recursive: true });
            }
            
            // Copy file
            fs.copyFileSync(sourcePath, destPath);
            
            // Update game files map
            const relativeDestPath = path.relative(this.basePath, destPath);
            this.gameFiles.set(relativeDestPath, {
                name: path.basename(destPath),
                path: destPath,
                relativePath: relativeDestPath,
                extension: path.extname(destPath),
                size: fs.statSync(destPath).size,
                mtime: fs.statSync(destPath).mtime
            });
            
            return {
                message: `File copied: ${args[0]} → ${args[1]}`
            };
        } catch (error) {
            return {
                error: `Failed to copy: ${error.message}`
            };
        }
    }
    
    /**
     * Handle 'mv' command
     */
    handleMoveCommand(args) {
        if (args.length < 2) {
            return {
                error: "Source and destination paths required"
            };
        }
        
        const fs = require('fs');
        const path = require('path');
        
        const sourcePath = path.resolve(this.basePath, args[0]);
        const destPath = path.resolve(this.basePath, args[1]);
        
        // Check that paths are within game directory
        if (!sourcePath.startsWith(this.basePath) || !destPath.startsWith(this.basePath)) {
            return {
                error: "Access denied: Paths must be within game directory"
            };
        }
        
        if (!fs.existsSync(sourcePath)) {
            return {
                error: `Source path not found: ${args[0]}`
            };
        }
        
        try {
            // Create destination directory if it doesn't exist
            const destDir = path.dirname(destPath);
            if (!fs.existsSync(destDir)) {
                fs.mkdirSync(destDir, { recursive: true });
            }
            
            // Move file
            fs.renameSync(sourcePath, destPath);
            
            // Update game files map
            const relativeSourcePath = path.relative(this.basePath, sourcePath);
            const relativeDestPath = path.relative(this.basePath, destPath);
            
            if (this.gameFiles.has(relativeSourcePath)) {
                const fileInfo = this.gameFiles.get(relativeSourcePath);
                fileInfo.path = destPath;
                fileInfo.relativePath = relativeDestPath;
                fileInfo.name = path.basename(destPath);
                fileInfo.mtime = fs.statSync(destPath).mtime;
                
                this.gameFiles.delete(relativeSourcePath);
                this.gameFiles.set(relativeDestPath, fileInfo);
            }
            
            return {
                message: `File moved: ${args[0]} → ${args[1]}`
            };
        } catch (error) {
            return {
                error: `Failed to move: ${error.message}`
            };
        }
    }
    
    /**
     * Handle 'clear' command
     */
    handleClearCommand(args) {
        return {
            clear: true
        };
    }
    
    /**
     * Handle 'history' command
     */
    handleHistoryCommand(args) {
        let limit = this.commandHistory.length;
        
        if (args.length > 0) {
            const parsedLimit = parseInt(args[0]);
            if (!isNaN(parsedLimit) && parsedLimit > 0) {
                limit = Math.min(parsedLimit, this.commandHistory.length);
            }
        }
        
        // Get the most recent commands up to the limit
        const history = this.commandHistory.slice(-limit);
        
        return {
            history: history.map((entry, index) => ({
                index: this.commandHistory.length - limit + index + 1,
                command: entry.command,
                terminal: entry.terminal,
                timestamp: entry.timestamp
            })),
            count: history.length,
            total: this.commandHistory.length
        };
    }
    
    /**
     * Handle 'terminal' command
     */
    handleTerminalCommand(args) {
        if (args.length === 0) {
            return {
                current: this.currentTerminal,
                available: ["Core 1", "Core 0", "Dev Terminal"]
            };
        }
        
        const terminalName = args.join(' ');
        
        if (!["Core 1", "Core 0", "Dev Terminal"].includes(terminalName)) {
            return {
                error: `Unknown terminal: ${terminalName}`,
                available: ["Core 1", "Core 0", "Dev Terminal"]
            };
        }
        
        this.currentTerminal = terminalName;
        
        return {
            message: `Switched to terminal: ${terminalName}`
        };
    }
    
    /**
     * Handle 'claude' command
     */
    handleClaudeCommand(args) {
        if (this.currentTerminal !== "Core 1") {
            return {
                error: "Claude command is only available in Core 1 terminal"
            };
        }
        
        if (args.length === 0) {
            return {
                message: "Claude AI activated. Enter a prompt to continue."
            };
        }
        
        const prompt = args.join(' ');
        
        // Create a session ID for this interaction
        const sessionId = `claude_${Date.now()}`;
        this.activeSessions.set(sessionId, {
            type: "claude",
            prompt: prompt,
            started: new Date(),
            completed: false
        });
        
        return {
            message: "Processing with Claude AI...",
            prompt: prompt,
            session: sessionId,
            status: "processing",
            estimatedTime: "2-5 seconds"
        };
    }
    
    /**
     * Handle 'operate' command
     */
    handleOperateCommand(args) {
        if (args.length === 0) {
            return {
                message: "Operation controller activated. Specify an action to continue.",
                actions: ["synchronize", "status", "connect", "disconnect"]
            };
        }
        
        const action = args[0];
        const actionArgs = args.slice(1);
        
        switch (action) {
            case "synchronize":
                return this.handleOperateSynchronize(actionArgs);
            case "status":
                return this.handleOperateStatus(actionArgs);
            case "connect":
                return this.handleOperateConnect(actionArgs);
            case "disconnect":
                return this.handleOperateDisconnect(actionArgs);
            default:
                return {
                    error: `Unknown action: ${action}`,
                    available: ["synchronize", "status", "connect", "disconnect"]
                };
        }
    }
    
    /**
     * Handle 'operate synchronize' command
     */
    handleOperateSynchronize(args) {
        let target = "all_terminals";
        
        if (args.length > 0) {
            target = args[0];
        }
        
        if (target === "all_terminals") {
            return {
                message: "Synchronizing all terminals...",
                status: "success",
                synchronized: ["Core 1", "Core 0", "Dev Terminal"],
                timestamp: new Date()
            };
        } else {
            if (!["Core 1", "Core 0", "Dev Terminal"].includes(target)) {
                return {
                    error: `Unknown terminal: ${target}`,
                    available: ["Core 1", "Core 0", "Dev Terminal", "all_terminals"]
                };
            }
            
            return {
                message: `Synchronizing terminal: ${target}`,
                status: "success",
                synchronized: [target],
                timestamp: new Date()
            };
        }
    }
    
    /**
     * Handle 'operate status' command
     */
    handleOperateStatus(args) {
        return {
            terminals: {
                "Core 1": {
                    active: true,
                    connected: true,
                    apis: ["claude"],
                    sessions: 1,
                    symbols: ["JSH", "⌛", "🧠"]
                },
                "Core 0": {
                    active: true,
                    connected: true,
                    apis: ["openai"],
                    sessions: 0,
                    symbols: ["JSH", "∞", "⚡"]
                },
                "Dev Terminal": {
                    active: true,
                    connected: true,
                    apis: ["node"],
                    sessions: 0,
                    symbols: ["🔄", "📊"]
                }
            },
            current: this.currentTerminal,
            turn: this.phaseManager.currentTurn,
            apiStatus: {
                claude: "operational",
                openai: "operational",
                node: "operational"
            }
        };
    }
    
    /**
     * Handle 'operate connect' command
     */
    handleOperateConnect(args) {
        if (args.length === 0) {
            return {
                error: "Target terminal required",
                usage: "operate connect <terminal>"
            };
        }
        
        const target = args[0];
        
        if (!["Core 1", "Core 0", "Dev Terminal"].includes(target)) {
            return {
                error: `Unknown terminal: ${target}`,
                available: ["Core 1", "Core 0", "Dev Terminal"]
            };
        }
        
        return {
            message: `Connected to terminal: ${target}`,
            status: "success",
            timestamp: new Date()
        };
    }
    
    /**
     * Handle 'operate disconnect' command
     */
    handleOperateDisconnect(args) {
        if (args.length === 0) {
            return {
                error: "Target terminal required",
                usage: "operate disconnect <terminal>"
            };
        }
        
        const target = args[0];
        
        if (!["Core 1", "Core 0", "Dev Terminal"].includes(target)) {
            return {
                error: `Unknown terminal: ${target}`,
                available: ["Core 1", "Core 0", "Dev Terminal"]
            };
        }
        
        return {
            message: `Disconnected from terminal: ${target}`,
            status: "success",
            timestamp: new Date()
        };
    }
    
    /**
     * Handle 'npm' command
     */
    handleNpmCommand(args) {
        if (args.length === 0) {
            return {
                message: "Node Package Manager activated. Specify a command to continue.",
                commands: ["install", "update", "list", "run"]
            };
        }
        
        const command = args[0];
        const commandArgs = args.slice(1);
        
        switch (command) {
            case "install":
                return this.handleNpmInstall(commandArgs);
            case "update":
                return this.handleNpmUpdate(commandArgs);
            case "list":
                return this.handleNpmList(commandArgs);
            case "run":
                return this.handleNpmRun(commandArgs);
            default:
                return {
                    error: `Unknown npm command: ${command}`,
                    available: ["install", "update", "list", "run"]
                };
        }
    }
    
    /**
     * Handle 'npm install' command
     */
    handleNpmInstall(args) {
        if (args.length === 0) {
            return {
                error: "Package name required",
                usage: "npm install <package>"
            };
        }
        
        const packageName = args[0];
        
        // Add to update queue
        this.updateQueue.push({
            type: "npm_install",
            package: packageName,
            queued: new Date()
        });
        
        return {
            message: `Package queued for installation: ${packageName}`,
            status: "queued",
            queuePosition: this.updateQueue.length,
            estimatedTime: "30-60 seconds"
        };
    }
    
    /**
     * Handle 'npm update' command
     */
    handleNpmUpdate(args) {
        if (args.length === 0) {
            // Update all packages
            return {
                message: "All packages queued for update",
                status: "queued",
                queuePosition: this.updateQueue.length + 1,
                estimatedTime: "60-120 seconds"
            };
        }
        
        const packageName = args[0];
        
        // Add to update queue
        this.updateQueue.push({
            type: "npm_update",
            package: packageName,
            queued: new Date()
        });
        
        return {
            message: `Package queued for update: ${packageName}`,
            status: "queued",
            queuePosition: this.updateQueue.length,
            estimatedTime: "30-60 seconds"
        };
    }
    
    /**
     * Handle 'npm list' command
     */
    handleNpmList(args) {
        return {
            packages: [
                {
                    name: "temporal-bridge",
                    version: "1.0.0",
                    description: "Bridge for temporal connections",
                    dependencies: ["time-flow", "dimension-connector"]
                },
                {
                    name: "auto-knowledge",
                    version: "1.2.3",
                    description: "Automatic knowledge system",
                    dependencies: ["trust-verifier", "memory-tier"]
                },
                {
                    name: "line-change-detector",
                    version: "0.9.5",
                    description: "Detects changes in lines",
                    dependencies: ["diff-algorithm", "temporal-echo"]
                }
            ]
        };
    }
    
    /**
     * Handle 'npm run' command
     */
    handleNpmRun(args) {
        if (args.length === 0) {
            return {
                error: "Script name required",
                usage: "npm run <script>"
            };
        }
        
        const scriptName = args[0];
        
        // Add to active sessions
        const sessionId = `npm_run_${Date.now()}`;
        this.activeSessions.set(sessionId, {
            type: "npm_run",
            script: scriptName,
            started: new Date(),
            completed: false
        });
        
        return {
            message: `Running script: ${scriptName}`,
            status: "running",
            session: sessionId,
            estimatedTime: "5-10 seconds"
        };
    }
    
    /**
     * Handle 'node' command
     */
    handleNodeCommand(args) {
        if (args.length === 0) {
            return {
                message: "Node.js REPL activated. Enter JavaScript code to execute."
            };
        }

        const isFile = args[0].endsWith('.js');

        if (isFile) {
            const fs = require('fs');
            const path = require('path');

            const filePath = path.resolve(this.basePath, args[0]);

            // Check that path is within game directory
            if (!filePath.startsWith(this.basePath)) {
                return {
                    error: "Access denied: Path must be within game directory"
                };
            }

            if (!fs.existsSync(filePath)) {
                return {
                    error: `File not found: ${args[0]}`
                };
            }

            // Add to active sessions
            const sessionId = `node_file_${Date.now()}`;
            this.activeSessions.set(sessionId, {
                type: "node_file",
                file: args[0],
                started: new Date(),
                completed: false
            });

            return {
                message: `Executing JavaScript file: ${args[0]}`,
                status: "running",
                session: sessionId,
                estimatedTime: "1-3 seconds"
            };
        } else {
            // Direct JavaScript code execution
            const code = args.join(' ');

            // Add to active sessions
            const sessionId = `node_code_${Date.now()}`;
            this.activeSessions.set(sessionId, {
                type: "node_code",
                code: code,
                started: new Date(),
                completed: false
            });

            return {
                message: "Executing JavaScript code...",
                code: code,
                status: "running",
                session: sessionId,
                estimatedTime: "1-2 seconds"
            };
        }
    }

    /**
     * Handle 'api' command
     */
    handleApiCommand(args) {
        try {
            // Try to load API modules
            const { ApiTranslationBridge } = require('./api_translation_bridge.js');
            const { OpenAIIntegration } = require('./openai_integration.js');

            // Instantiate bridge
            const apiBridge = new ApiTranslationBridge();
            apiBridge.initialize();

            if (args.length === 0) {
                return {
                    message: "API command activated. Specify a subcommand to continue.",
                    commands: ["translate", "key", "connect", "terminal", "status"]
                };
            }

            const subCommand = args[0];
            const subArgs = args.slice(1);

            switch (subCommand) {
                case "translate":
                    return this.handleApiTranslate(apiBridge, subArgs);
                case "key":
                    return this.handleApiKey(apiBridge, subArgs);
                case "connect":
                    return this.handleApiConnect(apiBridge, subArgs);
                case "terminal":
                    return this.handleApiTerminal(apiBridge, subArgs);
                case "status":
                    return this.handleApiStatus(apiBridge, subArgs);
                default:
                    return {
                        error: `Unknown API subcommand: ${subCommand}`,
                        available: ["translate", "key", "connect", "terminal", "status"]
                    };
            }
        } catch (error) {
            // Handle module load errors
            return {
                error: `API command error: ${error.message}`,
                hint: "Make sure api_translation_bridge.js is available"
            };
        }
    }

    /**
     * Handle 'api translate' command
     */
    handleApiTranslate(apiBridge, args) {
        if (args.length === 0) {
            return {
                error: "Input required for translation",
                usage: "api translate <input>"
            };
        }

        const input = args.join(' ');
        const result = apiBridge.translateInput(input, this.currentTerminal);

        return {
            message: "Translation complete",
            translation: result.translation,
            manifestPower: result.translation.gameWorld.manifestPower
        };
    }

    /**
     * Handle 'api key' command
     */
    handleApiKey(apiBridge, args) {
        if (args.length < 2) {
            return {
                error: "API name and key required",
                usage: "api key <api_name> <api_key>"
            };
        }

        const apiName = args[0];
        const apiKey = args[1];

        const result = apiBridge.setApiKey(apiName, apiKey);

        return result;
    }

    /**
     * Handle 'api connect' command
     */
    handleApiConnect(apiBridge, args) {
        if (args.length === 0) {
            return {
                error: "API name required",
                usage: "api connect <api_name>"
            };
        }

        const apiName = args[0];
        const options = {};

        // Parse options if provided
        if (args.length > 1) {
            const optionsStr = args.slice(1).join(' ');
            try {
                Object.assign(options, JSON.parse(optionsStr));
            } catch (e) {
                return {
                    error: `Invalid options format: ${e.message}`,
                    hint: "Options should be valid JSON"
                };
            }
        }

        const result = apiBridge.connectToApi(apiName, options);

        return result;
    }

    /**
     * Handle 'api terminal' command
     */
    handleApiTerminal(apiBridge, args) {
        if (args.length < 2) {
            return {
                error: "Terminal name and API name required",
                usage: "api terminal <terminal_name> <api_name>"
            };
        }

        const terminal = args[0];
        const api = args[1];

        const result = apiBridge.setTerminalApi(terminal, api);

        return result;
    }

    /**
     * Handle 'api status' command
     */
    handleApiStatus(apiBridge, args) {
        // Get all terminal mappings
        const mappings = apiBridge.getTerminalMappings();

        return {
            mappings: mappings.mappings,
            defaultTerminal: mappings.default,
            currentTerminal: this.currentTerminal,
            apis: Array.from(apiBridge.apiKeys ? apiBridge.apiKeys.keys() : [])
        };
    }

    /**
     * Handle 'accelerate' command
     */
    handleAccelerateCommand(args) {
        try {
            // Try to load Acceleration Protocol
            const { AccelerationProtocol } = require('./acceleration_protocol.js');

            // Instantiate protocol
            const protocol = new AccelerationProtocol();
            protocol.initialize();

            if (args.length === 0) {
                return {
                    message: "Acceleration command activated. Specify a subcommand to continue.",
                    commands: ["speed", "timeflow", "max", "sync", "process", "status"]
                };
            }

            const subCommand = args[0];
            const subArgs = args.slice(1);

            switch (subCommand) {
                case "speed":
                    return this.handleAccelerateSpeed(protocol, subArgs);
                case "timeflow":
                    return this.handleAccelerateTimeFlow(protocol, subArgs);
                case "max":
                    return this.handleAccelerateMax(protocol, subArgs);
                case "sync":
                    return this.handleAccelerateSync(protocol, subArgs);
                case "process":
                    return this.handleAccelerateProcess(protocol, subArgs);
                case "status":
                    return this.handleAccelerateStatus(protocol, subArgs);
                default:
                    return {
                        error: `Unknown acceleration subcommand: ${subCommand}`,
                        available: ["speed", "timeflow", "max", "sync", "process", "status"]
                    };
            }
        } catch (error) {
            // Handle module load errors
            return {
                error: `Acceleration command error: ${error.message}`,
                hint: "Make sure acceleration_protocol.js is available"
            };
        }
    }

    /**
     * Handle 'accelerate speed' command
     */
    handleAccelerateSpeed(protocol, args) {
        let factor = null;

        if (args.length > 0) {
            factor = parseFloat(args[0]);
            if (isNaN(factor)) {
                return {
                    error: "Invalid acceleration factor",
                    hint: "Factor must be a number"
                };
            }
        }

        const result = protocol.accelerateTimeFlow(factor);

        return {
            message: `System acceleration set to ${result.currentRate}x`,
            previousRate: result.previousRate,
            currentRate: result.currentRate
        };
    }

    /**
     * Handle 'accelerate timeflow' command
     */
    handleAccelerateTimeFlow(protocol, args) {
        let factor = null;

        if (args.length > 0) {
            factor = parseFloat(args[0]);
            if (isNaN(factor)) {
                return {
                    error: "Invalid time flow factor",
                    hint: "Factor must be a number"
                };
            }
        }

        const result = protocol.accelerateTimeFlow(factor);

        return {
            message: `Time flow accelerated to ${result.currentRate}x`,
            previousRate: result.previousRate,
            currentRate: result.currentRate
        };
    }

    /**
     * Handle 'accelerate max' command
     */
    handleAccelerateMax(protocol, args) {
        const result = protocol.calculateMaximumAcceleration();

        return {
            message: `Maximum acceleration calculated`,
            theoretical: result.theoretical,
            practical: result.practical,
            recommended: result.recommended
        };
    }

    /**
     * Handle 'accelerate sync' command
     */
    handleAccelerateSync(protocol, args) {
        const result = protocol.synchronizeTerminals();

        return {
            message: result.message,
            timestamp: result.timestamp,
            status: result.status
        };
    }

    /**
     * Handle 'accelerate process' command
     */
    handleAccelerateProcess(protocol, args) {
        if (args.length === 0) {
            return {
                error: "Process name required",
                usage: "accelerate process <name> [factor]"
            };
        }

        const processName = args[0];
        let factor = null;

        if (args.length > 1) {
            factor = parseFloat(args[1]);
            if (isNaN(factor)) {
                return {
                    error: "Invalid acceleration factor",
                    hint: "Factor must be a number"
                };
            }
        }

        const options = {};
        if (factor !== null) {
            options.factor = factor;
        }

        const result = protocol.accelerateProcess(processName, options);

        return {
            message: result.message,
            duration: result.duration,
            expires: result.expires
        };
    }

    /**
     * Handle 'accelerate status' command
     */
    handleAccelerateStatus(protocol, args) {
        return {
            acceleration: protocol.acceleration,
            timeFlowRate: protocol.timeFlowRate,
            dimensions: protocol.dimensions,
            luckyNumbers: protocol.luckyNumbers
        };
    }

    /**
     * Handle 'account' command
     */
    handleAccountCommand(args) {
        try {
            // Try to load Shared Account Connector
            const { SharedAccountConnector } = require('./shared_account_connector.js');

            // Instantiate connector
            const connector = new SharedAccountConnector();
            connector.initialize();

            if (args.length === 0) {
                return {
                    message: "Account command activated. Specify a subcommand to continue.",
                    commands: ["connect", "windows", "godot", "status", "sync", "accelerate"]
                };
            }

            const subCommand = args[0];
            const subArgs = args.slice(1);

            switch (subCommand) {
                case "connect":
                    return this.handleAccountConnect(connector, subArgs);
                case "windows":
                    return this.handleAccountWindows(connector, subArgs);
                case "godot":
                    return this.handleAccountGodot(connector, subArgs);
                case "status":
                    return this.handleAccountStatus(connector, subArgs);
                case "sync":
                    return this.handleAccountSync(connector, subArgs);
                case "accelerate":
                    return this.handleAccountAccelerate(connector, subArgs);
                default:
                    return {
                        error: `Unknown account subcommand: ${subCommand}`,
                        available: ["connect", "windows", "godot", "status", "sync", "accelerate"]
                    };
            }
        } catch (error) {
            // Handle module load errors
            return {
                error: `Account command error: ${error.message}`,
                hint: "Make sure shared_account_connector.js is available"
            };
        }
    }

    /**
     * Handle 'account connect' command
     */
    handleAccountConnect(connector, args) {
        if (args.length === 0) {
            return {
                error: "Account name required",
                usage: "account connect <name>"
            };
        }

        const accountName = args[0];
        const result = connector.connectAccount(accountName);

        return result;
    }

    /**
     * Handle 'account windows' command
     */
    handleAccountWindows(connector, args) {
        const result = connector.connectWindowsAccount();

        return result;
    }

    /**
     * Handle 'account godot' command
     */
    handleAccountGodot(connector, args) {
        const result = connector.connectGodotAccount();

        return result;
    }

    /**
     * Handle 'account status' command
     */
    handleAccountStatus(connector, args) {
        const result = connector.getConnectedAccounts();

        return {
            message: `${result.count} accounts connected`,
            accounts: result.accounts,
            syncStatus: result.syncStatus
        };
    }

    /**
     * Handle 'account sync' command
     */
    handleAccountSync(connector, args) {
        const result = connector.synchronizeAll();

        return {
            message: result.message,
            timestamp: result.timestamp,
            nextSync: result.nextSync
        };
    }

    /**
     * Handle 'account accelerate' command
     */
    handleAccountAccelerate(connector, args) {
        let factor = 2.0;

        if (args.length > 0) {
            factor = parseFloat(args[0]);
            if (isNaN(factor)) {
                return {
                    error: "Invalid acceleration factor",
                    hint: "Factor must be a number"
                };
            }
        }

        const result = connector.accelerate(factor);

        return {
            message: result.message,
            previousFactor: result.previousFactor,
            newFactor: result.newFactor,
            syncInterval: result.syncInterval
        };
    }

    /**
     * Handle 'project' command
     */
    handleProjectCommand(args) {
        try {
            // Try to load Project Continuation
            const { ProjectContinuation } = require('./project_continuation.js');

            // Instantiate project
            const project = new ProjectContinuation();
            project.initialize();

            if (args.length === 0) {
                return {
                    message: "Project command activated. Specify a subcommand to continue.",
                    commands: ["continue", "status", "connect", "akashic", "word", "notepad", "data"]
                };
            }

            const subCommand = args[0];
            const subArgs = args.slice(1);

            switch (subCommand) {
                case "continue":
                    return this.handleProjectContinue(project, subArgs);
                case "status":
                    return this.handleProjectStatus(project, subArgs);
                case "connect":
                    return this.handleProjectConnect(project, subArgs);
                case "akashic":
                    return this.handleProjectAkashic(project, subArgs);
                case "word":
                    return this.handleProjectWord(project, subArgs);
                case "notepad":
                    return this.handleProjectNotepad(project, subArgs);
                case "data":
                    return this.handleProjectData(project, subArgs);
                default:
                    return {
                        error: `Unknown project subcommand: ${subCommand}`,
                        available: ["continue", "status", "connect", "akashic", "word", "notepad", "data"]
                    };
            }
        } catch (error) {
            // Handle module load errors
            return {
                error: `Project command error: ${error.message}`,
                hint: "Make sure project_continuation.js is available"
            };
        }
    }

    /**
     * Handle 'project continue' command
     */
    handleProjectContinue(project, args) {
        const result = project.continueProject();

        return {
            message: result.message,
            evolution: result.evolution,
            connections: result.connections
        };
    }

    /**
     * Handle 'project status' command
     */
    handleProjectStatus(project, args) {
        const result = project.getStatus();

        return {
            evolutionStage: result.evolutionStage,
            nextEvolutionStage: result.nextEvolutionStage,
            dimension: result.dimension,
            nextDimension: result.nextDimension,
            progress: result.progress,
            connectedStructures: result.connectedStructures,
            connections: result.connections,
            temporalEchoes: result.temporalEchoes
        };
    }

    /**
     * Handle 'project connect' command
     */
    handleProjectConnect(project, args) {
        if (args.length === 0) {
            return {
                error: "Connect target required",
                usage: "project connect <target>",
                available: ["akashic", "word", "notepad"]
            };
        }

        const target = args[0].toLowerCase();

        switch (target) {
            case "akashic":
                return this.handleProjectAkashic(project, ["connect"]);
            case "word":
                return this.handleProjectWord(project, ["connect"]);
            case "notepad":
                return this.handleProjectNotepad(project, ["connect"]);
            default:
                return {
                    error: `Unknown connection target: ${target}`,
                    available: ["akashic", "word", "notepad"]
                };
        }
    }

    /**
     * Handle 'project akashic' command
     */
    handleProjectAkashic(project, args) {
        const subCommand = args.length > 0 ? args[0] : "connect";

        if (subCommand === "connect") {
            return project.connectToAkashicRecords();
        } else if (subCommand === "add" && args.length > 1) {
            const data = args.slice(1).join(' ');
            return project.addData("akashic_records", data);
        } else {
            return {
                error: `Unknown akashic subcommand: ${subCommand}`,
                available: ["connect", "add <data>"]
            };
        }
    }

    /**
     * Handle 'project word' command
     */
    handleProjectWord(project, args) {
        const subCommand = args.length > 0 ? args[0] : "connect";

        if (subCommand === "connect") {
            return project.connectToWorldOfWord();
        } else if (subCommand === "add" && args.length > 1) {
            const data = args.slice(1).join(' ');
            return project.addData("world_of_word", data);
        } else {
            return {
                error: `Unknown word subcommand: ${subCommand}`,
                available: ["connect", "add <data>"]
            };
        }
    }

    /**
     * Handle 'project notepad' command
     */
    handleProjectNotepad(project, args) {
        const subCommand = args.length > 0 ? args[0] : "connect";

        if (subCommand === "connect") {
            return project.connectTo3DNotepad();
        } else if (subCommand === "add" && args.length > 1) {
            const data = args.slice(1).join(' ');
            return project.addData("3D_Notepad", data);
        } else {
            return {
                error: `Unknown notepad subcommand: ${subCommand}`,
                available: ["connect", "add <data>"]
            };
        }
    }

    /**
     * Handle 'project data' command
     */
    handleProjectData(project, args) {
        if (args.length < 2) {
            return {
                error: "Structure name and data required",
                usage: "project data <structure> <data>"
            };
        }

        const structure = args[0];
        const data = args.slice(1).join(' ');

        return project.addData(structure, data);
    }

    /**
     * Handle 'shape' command
     */
    handleShapeCommand(args) {
        try {
            // Try to load Shape System Integrator
            const { ShapeSystemIntegrator } = require('./shape_system_integrator.js');

            // Instantiate integrator
            const integrator = new ShapeSystemIntegrator();
            integrator.initialize();

            if (args.length === 0) {
                return {
                    message: "Shape command activated. Specify a subcommand to continue.",
                    commands: ["list", "story", "echo", "connect", "status", "time"]
                };
            }

            const subCommand = args[0];
            const subArgs = args.slice(1);

            switch (subCommand) {
                case "list":
                    return this.handleShapeList(integrator, subArgs);
                case "story":
                    return this.handleShapeStory(integrator, subArgs);
                case "echo":
                    return this.handleShapeEcho(integrator, subArgs);
                case "connect":
                    return this.handleShapeConnect(integrator, subArgs);
                case "status":
                    return this.handleShapeStatus(integrator, subArgs);
                case "time":
                    return this.handleShapeTime(integrator, subArgs);
                default:
                    return {
                        error: `Unknown shape subcommand: ${subCommand}`,
                        available: ["list", "story", "echo", "connect", "status", "time"]
                    };
            }
        } catch (error) {
            // Handle module load errors
            return {
                error: `Shape command error: ${error.message}`,
                hint: "Make sure shape_system_integrator.js is available"
            };
        }
    }

    /**
     * Handle 'shape list' command
     */
    handleShapeList(integrator, args) {
        const timeState = args.length > 0 ? args[0] : "present";

        return integrator.getShapesForTimeState(timeState);
    }

    /**
     * Handle 'shape story' command
     */
    handleShapeStory(integrator, args) {
        if (args.length < 3) {
            return {
                error: "Title, shapes, and content required",
                usage: "shape story <title> <shape1,shape2,...> <content>"
            };
        }

        const title = args[0];
        const shapes = args[1].split(',');
        const content = args.slice(2).join(' ');

        return integrator.createShapeStory(title, shapes, content);
    }

    /**
     * Handle 'shape echo' command
     */
    handleShapeEcho(integrator, args) {
        if (args.length < 2) {
            return {
                error: "Story ID and time state required",
                usage: "shape echo <story_id> <time_state>"
            };
        }

        const storyId = args[0];
        const timeState = args[1];

        return integrator.createTemporalEcho(storyId, timeState);
    }

    /**
     * Handle 'shape connect' command
     */
    handleShapeConnect(integrator, args) {
        if (args.length < 2) {
            return {
                error: "Shape name and words required",
                usage: "shape connect <shape> <word1,word2,...>"
            };
        }

        const shapeName = args[0];
        const words = args[1].split(',');

        return integrator.connectShapeToWords(shapeName, words);
    }

    /**
     * Handle 'shape status' command
     */
    handleShapeStatus(integrator, args) {
        return integrator.getStatus();
    }

    /**
     * Handle 'shape time' command
     */
    handleShapeTime(integrator, args) {
        const timeState = args.length > 0 ? args[0] : "all";

        return integrator.getStoriesForTimeState(timeState);
    }

    /**
     * Handle 'merger' command
     */
    handleMergerCommand(args) {
        try {
            // Try to load API Merger System
            const { ApiMergerSystem } = require('./api_merger_system.js');

            // Instantiate merger
            const merger = new ApiMergerSystem();
            merger.initialize();

            if (args.length === 0) {
                return {
                    message: "API Merger command activated. Specify a subcommand to continue.",
                    commands: ["merge", "connect", "provider", "account", "memory", "game", "status", "transform"]
                };
            }

            const subCommand = args[0];
            const subArgs = args.slice(1);

            switch (subCommand) {
                case "merge":
                    return this.handleMergerMerge(merger, subArgs);
                case "connect":
                    return this.handleMergerConnect(merger, subArgs);
                case "provider":
                    return this.handleMergerProvider(merger, subArgs);
                case "account":
                    return this.handleMergerAccount(merger, subArgs);
                case "memory":
                    return this.handleMergerMemory(merger, subArgs);
                case "game":
                    return this.handleMergerGame(merger, subArgs);
                case "status":
                    return this.handleMergerStatus(merger, subArgs);
                case "transform":
                    return this.handleMergerTransform(merger, subArgs);
                default:
                    return {
                        error: `Unknown merger subcommand: ${subCommand}`,
                        available: ["merge", "connect", "provider", "account", "memory", "game", "status", "transform"]
                    };
            }
        } catch (error) {
            // Handle module load errors
            return {
                error: `Merger command error: ${error.message}`,
                hint: "Make sure api_merger_system.js is available"
            };
        }
    }

    /**
     * Handle 'merger merge' command
     */
    handleMergerMerge(merger, args) {
        return merger.mergeApiTiers();
    }

    /**
     * Handle 'merger connect' command
     */
    handleMergerConnect(merger, args) {
        if (args.length === 0) {
            return {
                error: "Provider is required",
                usage: "merger connect <provider> [tier]"
            };
        }

        const provider = args[0];
        const tier = args.length > 1 ? args[1] : null;

        return merger.connectProvider(provider, tier);
    }

    /**
     * Handle 'merger provider' command
     */
    handleMergerProvider(merger, args) {
        return merger.getAvailableProviders();
    }

    /**
     * Handle 'merger account' command
     */
    handleMergerAccount(merger, args) {
        if (args.length === 0) {
            return {
                error: "Account ID is required",
                usage: "merger account <account_id>"
            };
        }

        const accountId = args[0];

        return merger.linkAccountToMemories(accountId);
    }

    /**
     * Handle 'merger memory' command
     */
    handleMergerMemory(merger, args) {
        if (args.length < 2) {
            return {
                error: "Subcommand and content are required",
                usage: "merger memory <store|get> <content|account_id>"
            };
        }

        const memorySubCommand = args[0];

        if (memorySubCommand === "store") {
            const content = args.slice(1).join(' ');
            return merger.storeMemory(content);
        } else if (memorySubCommand === "get") {
            const accountId = args[1];
            return merger.getAccountMemories(accountId);
        } else {
            return {
                error: `Unknown memory subcommand: ${memorySubCommand}`,
                available: ["store", "get"]
            };
        }
    }

    /**
     * Handle 'merger game' command
     */
    handleMergerGame(merger, args) {
        if (args.length < 2) {
            return {
                error: "Subcommand and ID are required",
                usage: "merger game <store|get> <game_state|account_id>"
            };
        }

        const gameSubCommand = args[0];

        if (gameSubCommand === "store") {
            const gameState = args.slice(1).join(' ');
            return merger.storeGameState(gameState);
        } else if (gameSubCommand === "get") {
            const accountId = args[1];
            return merger.getAccountGameStates(accountId);
        } else {
            return {
                error: `Unknown game subcommand: ${gameSubCommand}`,
                available: ["store", "get"]
            };
        }
    }

    /**
     * Handle 'merger status' command
     */
    handleMergerStatus(merger, args) {
        return {
            mergedApis: merger.mergedApis,
            currentProvider: merger.currentProvider,
            currentTier: merger.currentTier,
            apiKeys: Array.from(merger.apiKeys.keys()),
            memoryCount: merger.memoryStore.size,
            gameStateCount: merger.gameStateMemory.size,
            accountCount: merger.accountLinker.size
        };
    }

    /**
     * Handle 'merger transform' command
     */
    handleMergerTransform(merger, args) {
        if (args.length === 0) {
            return {
                error: "Memory ID or account ID is required",
                usage: "merger transform <memory_id|account_id>"
            };
        }

        const id = args[0];

        // Check if it's a memory ID or account ID
        if (id.startsWith('memory_')) {
            return merger.transformMemoryToGame(id);
        } else {
            return merger.transformMemoryToGame(null, id);
        }
    }
}

// For Node.js
if (typeof module !== 'undefined') {
    module.exports = { ConsoleCommandInterface };
}

// For browser environment
if (typeof window !== 'undefined') {
    window.consoleCommandInterface = new ConsoleCommandInterface();
    window.consoleCommandInterface.initialize();
}

// Self-initialization when run directly
const consoleInterface = new ConsoleCommandInterface();
consoleInterface.initialize();

console.log("Console Command Interface initialized for Turn 4");