// Test Command Connections - Turn 4 Temporal Flow

// Import the connection system
const { CommandApiConnector } = require('./command_api_connections.js');

// Initialize connector
const connector = new CommandApiConnector();
connector.initialize();

// Display all available commands
console.log("\n=== AVAILABLE COMMANDS ===");
for (const [name, command] of connector.commands.entries()) {
  console.log(`Command: ${name} (Power: ${command.powerLevel})`);
  console.log(`  Description: ${command.description}`);
  console.log(`  API Target: ${command.apiTarget || "none"}`);
  console.log(`  Lucky Number: ${command.luckyNumber || "none"}`);
  console.log(`  Symbol: ${command.symbol || "none"}`);
  console.log();
}

// Test executing commands
console.log("\n=== EXECUTING COMMANDS ===");

// Test claude command in Core 1
const claudeResult = connector.executeCommand("claude", "Core 1", {
  prompt: "Test prompt in temporal dimension"
});
console.log("Claude Command Result:");
console.log(JSON.stringify(claudeResult, null, 2));

// Test operate command in Core 0
const operateResult = connector.executeCommand("operate", "Core 0", {
  action: "synchronize",
  target: "all_terminals"
});
console.log("\nOperate Command Result:");
console.log(JSON.stringify(operateResult, null, 2));

// Test npm command in Dev Terminal
const npmResult = connector.executeCommand("npm", "Dev Terminal", {
  command: "install",
  package: "temporal-connector"
});
console.log("\nNPM Command Result:");
console.log(JSON.stringify(npmResult, null, 2));

// Display lucky number connections
console.log("\n=== LUCKY NUMBER CONNECTIONS ===");
const luckySymbols = connector.getLuckySymbols();
console.log(JSON.stringify(luckySymbols, null, 2));

// Display terminal connections
console.log("\n=== TERMINAL CONNECTIONS ===");
const core1Connections = connector.getTerminalConnections("Core 1");
console.log("Core 1 Connections:");
console.log(JSON.stringify(core1Connections, null, 2));

const core0Connections = connector.getTerminalConnections("Core 0");
console.log("\nCore 0 Connections:");
console.log(JSON.stringify(core0Connections, null, 2));
