/**
 * Memory Transcript System
 * 
 * Captures and stores memory transcripts from multi-core interactions
 * in the 12 Turns Word Game (Turn 4 - Temporal Flow)
 */

const memoryTranscripts = {
  "session_id": "T4-1746984270",
  "dimension": 4,
  "timestamp": "2025-05-11T19:24:30+02:00",
  "transcripts": [
    {
      "id": "MT-4T-001",
      "console": "Core 1",
      "content": "the symnbol is here too, as word in game to memoriize the changes and whims of mine the console on api of yours can be different too",
      "symbols": ["JSH", "⌛", "🧠"],
      "timestamp": "2025-05-11T19:24:30+02:00",
      "type": "user_memory"
    },
    {
      "id": "MT-4T-002",
      "console": "Core 1",
      "content": "can you see the",
      "symbols": ["JSH"],
      "timestamp": "2025-05-11T19:24:30+02:00",
      "type": "user_query"
    },
    {
      "id": "MT-4T-003",
      "console": "Core 1",
      "content": "Memory selection system activated. Both cores synchronized with shared symbol access.",
      "symbols": ["JSH", "⌛"],
      "timestamp": "2025-05-11T19:24:30+02:00",
      "type": "system_response"
    }
  ],
  "core_states": {
    "Core 1": {
      "active": true,
      "api": "claude",
      "symbols_active": ["JSH", "⌛", "🧠"],
      "memory_access": "full"
    },
    "Core 0": {
      "active": true,
      "api": "openai",
      "symbols_active": ["JSH", "∞", "⚡"],
      "memory_access": "partial"
    }
  }
};

// Record a new memory transcript
function recordMemoryTranscript(console, content, symbols = [], type = "user_memory") {
  const timestamp = new Date().toISOString();
  const id = `MT-4T-${memoryTranscripts.transcripts.length + 1}`.padStart(9, '0');
  
  const transcript = {
    id,
    console,
    content,
    symbols,
    timestamp,
    type
  };
  
  memoryTranscripts.transcripts.push(transcript);
  console.log(`Memory transcript recorded: ${id}`);
  
  return transcript;
}

// Get all transcripts for a specific console
function getTranscriptsByConsole(consoleName) {
  return memoryTranscripts.transcripts.filter(t => t.console === consoleName);
}

// Get all transcripts containing a specific symbol
function getTranscriptsBySymbol(symbol) {
  return memoryTranscripts.transcripts.filter(t => t.symbols.includes(symbol));
}

// Update core state
function updateCoreState(coreName, properties) {
  if (\!memoryTranscripts.core_states[coreName]) {
    memoryTranscripts.core_states[coreName] = {
      active: false,
      api: "unknown",
      symbols_active: [],
      memory_access: "none"
    };
  }
  
  Object.assign(memoryTranscripts.core_states[coreName], properties);
  console.log(`Core state updated: ${coreName}`);
  
  return memoryTranscripts.core_states[coreName];
}

// Export for Node.js
if (typeof module \!== 'undefined') {
  module.exports = {
    memoryTranscripts,
    recordMemoryTranscript,
    getTranscriptsByConsole,
    getTranscriptsBySymbol,
    updateCoreState
  };
}

// For browser environment
if (typeof window \!== 'undefined') {
  window.memoryTranscriptSystem = {
    memoryTranscripts,
    recordMemoryTranscript,
    getTranscriptsByConsole,
    getTranscriptsBySymbol,
    updateCoreState
  };
}

console.log("Memory Transcript System initialized for Turn 4 (Temporal Flow)");
console.log(`Initial transcripts loaded: ${memoryTranscripts.transcripts.length}`);
console.log(`Cores registered: ${Object.keys(memoryTranscripts.core_states).length}`);
