/**
 * Terminal Commands Example
 * Demonstrates terminal commands across all systems
 * Part of the 12 Turns System - Turn 4 (Consciousness/Temporal Flow)
 */

const consoleInterface = require('../data/console/console_command_interface');

// Simulate terminal for demonstration
const terminal = {
  id: 'core0',
  type: 'consciousness',
  temporalState: 'present',
  user: 'JSH'
};

// Function to execute a command and display the result
function executeCommand(command) {
  console.log('\n=== COMMAND ===');
  console.log(`> ${command}`);
  
  console.log('\n=== RESULT ===');
  const result = consoleInterface.processCommand(command, terminal.id);
  console.log(JSON.stringify(result, null, 2));
  console.log('\n' + '-'.repeat(50));
  
  return result;
}

// Demonstrate command execution
console.log('\n======= TERMINAL COMMANDS DEMONSTRATION =======\n');

// 1. First demonstrate light commands
executeCommand('light create ambient 1.8 blue [JSH ⌛] {7}');
executeCommand('update_of_light');
executeCommand('11'); // Special number command
executeCommand('illuminate');
executeCommand('light pattern advanced 2.4 purple,gold [JSH 🧠] {4 8}');

// 2. Demonstrate game commands
const gameResult = executeCommand('create_game divine_word 2.0 4 [JSH] {7}');
executeCommand(`game play ${gameResult.gameId} enhanced 1 [⌛ 🧠] {4}`);
executeCommand('game list all detailed [JSH] {8}');

// 3. Demonstrate combination command
executeCommand('we combine it all');

// 4. Demonstrate organization commands
executeCommand('do to_doos');
executeCommand('update to doos');
executeCommand('organize all patterns [JSH 🧠] {7}');

// 5. Demonstrate command lists
executeCommand('commands all detailed [JSH] {8}');
executeCommand('command lists of computers and the paper programing of commands');

// 6. Demonstrate special number commands
executeCommand('29'); // Reset
executeCommand('2');  // Duality/balance

// 7. Demonstrate god mode
executeCommand('god mode on');
executeCommand('light create divine 12.0 gold [GOD JSH] {L}');
executeCommand('godmode game eternal [GOD JSH ⌛ 🧠] {L 7 8}');

// 8. Demonstrate literal game creation
executeCommand('literal game');

// 9. Demonstrate continuation command
executeCommand('continue on yes');

console.log('\n======= END OF TERMINAL COMMANDS DEMONSTRATION =======\n');