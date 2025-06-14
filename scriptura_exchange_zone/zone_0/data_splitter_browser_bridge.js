/**
 * Data Splitter Browser Bridge
 * Connects the Godot-based data splitter with web browser visualization
 * Allows for cross-platform data visualization and manipulation
 */

// Configuration
const CONFIG = {
  // Connection settings
  serverPort: 8080,
  pollingInterval: 500,
  connectionTimeout: 10000,
  
  // Visualization settings
  maxDataStreams: 9,
  maxDataChunks: 100,
  maxSplitsPerView: 12,
  
  // Reality types from the main system
  realityTypes: ["physical", "digital", "astral", "quantum", "memory", "dream"],
  
  // Color scheme
  colors: {
    streams: {
      physical: "#3b82f6", // Blue
      digital: "#10b981", // Green
      astral: "#8b5cf6", // Purple
      quantum: "#ec4899", // Pink
      memory: "#f59e0b", // Orange
      dream: "#6366f1"   // Indigo
    },
    chunks: {
      binary: "#2563eb",
      text: "#059669",
      image: "#7c3aed",
      sound: "#db2777",
      command: "#d97706",
      memory: "#4f46e5"
    },
    backgrounds: {
      "1D": "#18181b", // Slate 900
      "3D": "#1e293b", // Slate 800
      "5D": "#0f172a", // Slate 900
      "7D": "#0c0a09", // Stone 950
      "9D": "#0c0a09", // Stone 950
      "12D": "#030712" // Gray 950
    }
  },
  
  // DOM element IDs
  elements: {
    container: "data-splitter-container",
    streamList: "data-streams-list",
    chunkContainer: "data-chunks-container",
    splitVisualizer: "data-splits-visualizer",
    moonPhase: "moon-phase-indicator",
    connectionStatus: "connection-status",
    realitySelector: "reality-selector",
    dimensionSelector: "dimension-selector"
  }
};

// State management
let STATE = {
  connected: false,
  connectionError: null,
  lastUpdate: null,
  dataStreams: [],
  dataChunks: {},
  dataSplits: {},
  currentReality: "digital",
  currentDimension: "3D",
  moonPhase: 0,
  activeVisualization: null,
  selectedChunks: []
};

// Connection and data fetching
const API = {
  /**
   * Initialize the connection to the Godot data splitter
   */
  initialize: async function() {
    console.log("Initializing Data Splitter Browser Bridge...");
    
    try {
      const response = await fetch(`http://localhost:${CONFIG.serverPort}/status`);
      
      if (response.ok) {
        const data = await response.json();
        STATE.connected = true;
        STATE.lastUpdate = new Date();
        STATE.currentReality = data.current_reality || STATE.currentReality;
        STATE.currentDimension = data.current_dimension || STATE.currentDimension;
        STATE.moonPhase = data.moon_phase || STATE.moonPhase;
        
        console.log("Connected to Data Splitter server");
        UI.updateConnectionStatus(true);
        
        // Start polling for updates
        this.startPolling();
        return true;
      } else {
        throw new Error("Server responded with status: " + response.status);
      }
    } catch (error) {
      console.error("Failed to connect to Data Splitter server:", error);
      STATE.connected = false;
      STATE.connectionError = error.message;
      UI.updateConnectionStatus(false, error.message);
      
      // Try to connect using the WebSocket fallback
      this.tryWebSocketConnection();
      return false;
    }
  },
  
  /**
   * Alternative WebSocket connection if HTTP fails
   */
  tryWebSocketConnection: function() {
    console.log("Attempting WebSocket connection...");
    
    const socket = new WebSocket(`ws://localhost:${CONFIG.serverPort}/ws`);
    
    socket.onopen = () => {
      console.log("WebSocket connection established");
      STATE.connected = true;
      STATE.connectionError = null;
      STATE.lastUpdate = new Date();
      UI.updateConnectionStatus(true, "Connected via WebSocket");
      
      // Set up message handler
      socket.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data);
          this.processUpdate(data);
        } catch (e) {
          console.error("Error processing WebSocket message:", e);
        }
      };
    };
    
    socket.onerror = (error) => {
      console.error("WebSocket connection error:", error);
      STATE.connected = false;
      STATE.connectionError = "WebSocket connection failed";
      UI.updateConnectionStatus(false, "All connection attempts failed");
    };
    
    socket.onclose = () => {
      console.log("WebSocket connection closed");
      STATE.connected = false;
      UI.updateConnectionStatus(false, "Connection closed");
    };
  },
  
  /**
   * Start polling for updates from the server
   */
  startPolling: function() {
    setInterval(async () => {
      if (!STATE.connected) return;
      
      try {
        const response = await fetch(`http://localhost:${CONFIG.serverPort}/data`);
        
        if (response.ok) {
          const data = await response.json();
          this.processUpdate(data);
        } else {
          console.warn("Server responded with status:", response.status);
        }
      } catch (error) {
        console.error("Error polling for updates:", error);
        STATE.connectionError = error.message;
        UI.updateConnectionStatus(false, "Polling error: " + error.message);
      }
    }, CONFIG.pollingInterval);
  },
  
  /**
   * Process data updates from the server
   */
  processUpdate: function(data) {
    STATE.lastUpdate = new Date();
    
    // Update system state
    if (data.current_reality) STATE.currentReality = data.current_reality;
    if (data.current_dimension) STATE.currentDimension = data.current_dimension;
    if (data.moon_phase !== undefined) STATE.moonPhase = data.moon_phase;
    
    // Update data structures
    if (data.streams) STATE.dataStreams = data.streams;
    if (data.chunks) STATE.dataChunks = data.chunks;
    if (data.splits) STATE.dataSplits = data.splits;
    
    // Update UI with new data
    UI.updateStreamList();
    UI.updateChunkDisplay();
    UI.updateSplitVisualizer();
    UI.updateMoonPhase();
    UI.updateEnvironment();
  },
  
  /**
   * Send a command to the data splitter
   */
  sendCommand: async function(command, params = {}) {
    if (!STATE.connected) {
      console.error("Cannot send command - not connected");
      return { success: false, error: "Not connected" };
    }
    
    try {
      const response = await fetch(`http://localhost:${CONFIG.serverPort}/command`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          command: command,
          parameters: params
        })
      });
      
      if (response.ok) {
        return await response.json();
      } else {
        const errorText = await response.text();
        throw new Error(`Server error: ${response.status} - ${errorText}`);
      }
    } catch (error) {
      console.error("Error sending command:", error);
      return { success: false, error: error.message };
    }
  },
  
  /**
   * Create a new data split operation
   */
  createSplit: async function(chunkIds, splitFactor = 3) {
    return await this.sendCommand("split", { 
      chunk_ids: chunkIds,
      split_factor: splitFactor
    });
  },
  
  /**
   * Merge multiple data chunks
   */
  mergeChunks: async function(chunkIds, mergeType = "concatenate") {
    return await this.sendCommand("merge", {
      chunk_ids: chunkIds, 
      merge_type: mergeType
    });
  },
  
  /**
   * Change the current reality
   */
  changeReality: async function(realityType) {
    return await this.sendCommand("change_reality", {
      reality: realityType
    });
  },
  
  /**
   * Create a new data stream
   */
  createStream: async function(streamType = "binary", size = 16) {
    return await this.sendCommand("create_stream", {
      type: streamType,
      size: size
    });
  }
};

// UI Management
const UI = {
  /**
   * Initialize the UI
   */
  initialize: function() {
    console.log("Initializing UI...");
    this.createBaseElements();
    this.setupEventListeners();
    this.updateEnvironment();
  },
  
  /**
   * Create main UI elements if they don't exist
   */
  createBaseElements: function() {
    // Check if container exists
    let container = document.getElementById(CONFIG.elements.container);
    if (!container) {
      console.log("Creating main container");
      container = document.createElement('div');
      container.id = CONFIG.elements.container;
      container.className = 'data-splitter-main';
      document.body.appendChild(container);
      
      // Add basic CSS
      const style = document.createElement('style');
      style.textContent = `
        .data-splitter-main {
          display: flex;
          flex-direction: column;
          height: 100vh;
          background-color: ${CONFIG.colors.backgrounds["3D"]};
          color: white;
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          transition: background-color 1s ease;
        }
        
        .data-splitter-header {
          display: flex;
          justify-content: space-between;
          padding: 1rem;
          background-color: rgba(0, 0, 0, 0.3);
        }
        
        .data-splitter-content {
          display: flex;
          flex: 1;
          overflow: hidden;
        }
        
        .data-splitter-sidebar {
          width: 250px;
          background-color: rgba(0, 0, 0, 0.2);
          padding: 1rem;
          overflow-y: auto;
        }
        
        .data-splitter-main-content {
          flex: 1;
          padding: 1rem;
          overflow-y: auto;
          display: flex;
          flex-direction: column;
        }
        
        .data-stream-item {
          margin-bottom: 0.5rem;
          padding: 0.5rem;
          border-radius: 4px;
          background-color: rgba(0, 0, 0, 0.2);
          cursor: pointer;
          transition: background-color 0.3s ease;
        }
        
        .data-stream-item:hover {
          background-color: rgba(0, 0, 0, 0.4);
        }
        
        .data-stream-item.active {
          background-color: rgba(255, 255, 255, 0.1);
        }
        
        .data-chunk {
          display: inline-block;
          width: 120px;
          height: 120px;
          margin: 0.5rem;
          padding: 0.5rem;
          border-radius: 4px;
          background-color: rgba(0, 0, 0, 0.3);
          border: 1px solid rgba(255, 255, 255, 0.1);
          overflow: hidden;
          position: relative;
          cursor: pointer;
          transition: all 0.3s ease;
        }
        
        .data-chunk:hover {
          transform: translateY(-5px);
          box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
        }
        
        .data-chunk.selected {
          border: 2px solid white;
          box-shadow: 0 0 10px rgba(255, 255, 255, 0.5);
        }
        
        .data-chunk-content {
          font-size: 0.8rem;
          word-break: break-all;
          height: 70px;
          overflow: hidden;
        }
        
        .data-chunk-info {
          font-size: 0.7rem;
          position: absolute;
          bottom: 0.5rem;
          left: 0.5rem;
          right: 0.5rem;
          opacity: 0.8;
        }
        
        .data-splits-visualizer {
          flex: 1;
          min-height: 300px;
          background-color: rgba(0, 0, 0, 0.1);
          margin-top: 1rem;
          border-radius: 4px;
          display: flex;
          justify-content: center;
          align-items: center;
          position: relative;
        }
        
        .moon-phase-indicator {
          width: 30px;
          height: 30px;
          border-radius: 50%;
          background-color: #f0f0f0;
          box-shadow: inset -5px 0 10px rgba(0, 0, 0, 0.2);
          transition: box-shadow 0.5s ease;
        }
        
        .connection-status {
          display: flex;
          align-items: center;
        }
        
        .connection-indicator {
          width: 12px;
          height: 12px;
          border-radius: 50%;
          margin-right: 0.5rem;
        }
        
        .connection-indicator.connected {
          background-color: #10b981;
        }
        
        .connection-indicator.disconnected {
          background-color: #ef4444;
        }
        
        .action-button {
          padding: 0.5rem 1rem;
          border-radius: 4px;
          background-color: rgba(79, 70, 229, 0.8);
          color: white;
          border: none;
          cursor: pointer;
          transition: background-color 0.3s ease;
          margin-right: 0.5rem;
        }
        
        .action-button:hover {
          background-color: rgba(79, 70, 229, 1);
        }
        
        .action-button:disabled {
          background-color: rgba(79, 70, 229, 0.3);
          cursor: not-allowed;
        }
      `;
      document.head.appendChild(style);
      
      // Create basic structure
      container.innerHTML = `
        <div class="data-splitter-header">
          <div class="connection-status" id="${CONFIG.elements.connectionStatus}">
            <div class="connection-indicator disconnected"></div>
            <span>Disconnected</span>
          </div>
          <div class="reality-controls">
            <select id="${CONFIG.elements.realitySelector}">
              ${CONFIG.realityTypes.map(r => `<option value="${r}">${r.charAt(0).toUpperCase() + r.slice(1)}</option>`).join('')}
            </select>
            <select id="${CONFIG.elements.dimensionSelector}">
              <option value="1D">1D - Linear</option>
              <option value="3D" selected>3D - Space</option>
              <option value="5D">5D - Consciousness</option>
              <option value="7D">7D - Creation</option>
              <option value="9D">9D - Harmony</option>
              <option value="12D">12D - Beyond</option>
            </select>
            <div class="${CONFIG.elements.moonPhase}" id="${CONFIG.elements.moonPhase}" title="Moon Phase 0/7"></div>
          </div>
        </div>
        <div class="data-splitter-content">
          <div class="data-splitter-sidebar">
            <h3>Data Streams</h3>
            <div id="${CONFIG.elements.streamList}">
              <div class="loading">Loading streams...</div>
            </div>
            <div class="sidebar-controls">
              <button class="action-button" id="create-stream-button">New Stream</button>
            </div>
          </div>
          <div class="data-splitter-main-content">
            <h3>Data Chunks</h3>
            <div id="${CONFIG.elements.chunkContainer}" class="data-chunks-container">
              <div class="loading">Select a stream to view chunks</div>
            </div>
            <div class="chunk-controls">
              <button class="action-button" id="split-button" disabled>Split</button>
              <button class="action-button" id="merge-button" disabled>Merge</button>
            </div>
            <div id="${CONFIG.elements.splitVisualizer}" class="data-splits-visualizer">
              <div class="placeholder">Select chunks to visualize splits</div>
            </div>
          </div>
        </div>
      `;
    }
  },
  
  /**
   * Set up event listeners for UI interactions
   */
  setupEventListeners: function() {
    // Reality selector
    const realitySelector = document.getElementById(CONFIG.elements.realitySelector);
    if (realitySelector) {
      realitySelector.addEventListener('change', (e) => {
        const newReality = e.target.value;
        API.changeReality(newReality);
      });
    }
    
    // Dimension selector
    const dimensionSelector = document.getElementById(CONFIG.elements.dimensionSelector);
    if (dimensionSelector) {
      dimensionSelector.addEventListener('change', (e) => {
        const newDimension = e.target.value;
        API.sendCommand("change_dimension", { dimension: newDimension });
      });
    }
    
    // Create stream button
    const createStreamButton = document.getElementById('create-stream-button');
    if (createStreamButton) {
      createStreamButton.addEventListener('click', () => {
        const streamType = prompt("Enter stream type (binary, text, image, sound):", "binary");
        const size = parseInt(prompt("Enter stream size (bytes):", "1024"));
        
        if (streamType && !isNaN(size)) {
          API.createStream(streamType, size);
        }
      });
    }
    
    // Split button
    const splitButton = document.getElementById('split-button');
    if (splitButton) {
      splitButton.addEventListener('click', () => {
        if (STATE.selectedChunks.length > 0) {
          const splitFactor = parseInt(prompt("Enter split factor (2-5):", "3"));
          
          if (!isNaN(splitFactor) && splitFactor >= 2 && splitFactor <= 5) {
            API.createSplit(STATE.selectedChunks, splitFactor);
          }
        }
      });
    }
    
    // Merge button
    const mergeButton = document.getElementById('merge-button');
    if (mergeButton) {
      mergeButton.addEventListener('click', () => {
        if (STATE.selectedChunks.length >= 2) {
          const mergeType = prompt("Enter merge type (concatenate, interleave):", "concatenate");
          
          if (mergeType) {
            API.mergeChunks(STATE.selectedChunks, mergeType);
          }
        }
      });
    }
  },
  
  /**
   * Update the stream list in the sidebar
   */
  updateStreamList: function() {
    const streamList = document.getElementById(CONFIG.elements.streamList);
    if (!streamList) return;
    
    if (STATE.dataStreams.length === 0) {
      streamList.innerHTML = '<div class="empty-state">No data streams available</div>';
      return;
    }
    
    streamList.innerHTML = '';
    STATE.dataStreams.forEach(stream => {
      const streamEl = document.createElement('div');
      streamEl.className = 'data-stream-item';
      streamEl.dataset.streamId = stream.id;
      
      // Set background color based on reality type
      const realityType = stream.reality || STATE.currentReality;
      streamEl.style.borderLeft = `4px solid ${CONFIG.colors.streams[realityType] || '#ccc'}`;
      
      streamEl.innerHTML = `
        <div class="stream-name">${stream.id}</div>
        <div class="stream-info">
          Type: ${stream.type}, Size: ${stream.size} bytes
        </div>
        <div class="stream-meta">
          Chunks: ${stream.chunks ? stream.chunks.length : 0}
        </div>
      `;
      
      streamEl.addEventListener('click', () => {
        // Clear existing selection
        document.querySelectorAll('.data-stream-item.active').forEach(el => {
          el.classList.remove('active');
        });
        
        // Mark as active
        streamEl.classList.add('active');
        
        // Update chunks view
        this.displayChunksForStream(stream.id);
      });
      
      streamList.appendChild(streamEl);
    });
  },
  
  /**
   * Display chunks for the selected stream
   */
  displayChunksForStream: function(streamId) {
    const chunkContainer = document.getElementById(CONFIG.elements.chunkContainer);
    if (!chunkContainer) return;
    
    // Find the stream
    const stream = STATE.dataStreams.find(s => s.id === streamId);
    if (!stream) {
      chunkContainer.innerHTML = '<div class="empty-state">Stream not found</div>';
      return;
    }
    
    // Reset selected chunks
    STATE.selectedChunks = [];
    this.updateChunkButtons();
    
    chunkContainer.innerHTML = '';
    
    if (!stream.chunks || stream.chunks.length === 0) {
      chunkContainer.innerHTML = '<div class="empty-state">No chunks in this stream</div>';
      return;
    }
    
    // Get chunks for this stream
    const chunks = Object.values(STATE.dataChunks).filter(chunk => 
      chunk.parent_stream === streamId
    );
    
    chunks.forEach(chunk => {
      const chunkEl = document.createElement('div');
      chunkEl.className = 'data-chunk';
      chunkEl.dataset.chunkId = chunk.id;
      
      // Set color based on chunk type
      const type = chunk.type || (typeof chunk.content === 'string' ? 'text' : 'binary');
      chunkEl.style.backgroundColor = CONFIG.colors.chunks[type] || '#333';
      
      // Truncate content for display
      let displayContent = chunk.content;
      if (typeof displayContent === 'string' && displayContent.length > 100) {
        displayContent = displayContent.substring(0, 97) + '...';
      }
      
      chunkEl.innerHTML = `
        <div class="data-chunk-content">${displayContent}</div>
        <div class="data-chunk-info">
          Size: ${chunk.size} bytes<br>
          ID: ${chunk.id.substring(0, 8)}...
        </div>
      `;
      
      // Add click handler for selection
      chunkEl.addEventListener('click', (e) => {
        const chunkId = chunkEl.dataset.chunkId;
        
        if (e.ctrlKey || e.metaKey) {
          // Multi-select with Ctrl/Cmd
          if (STATE.selectedChunks.includes(chunkId)) {
            // Deselect
            STATE.selectedChunks = STATE.selectedChunks.filter(id => id !== chunkId);
            chunkEl.classList.remove('selected');
          } else {
            // Add to selection
            STATE.selectedChunks.push(chunkId);
            chunkEl.classList.add('selected');
          }
        } else {
          // Single select
          document.querySelectorAll('.data-chunk.selected').forEach(el => {
            el.classList.remove('selected');
          });
          
          STATE.selectedChunks = [chunkId];
          chunkEl.classList.add('selected');
        }
        
        this.updateChunkButtons();
        this.updateSplitVisualizer();
      });
      
      chunkContainer.appendChild(chunkEl);
    });
  },
  
  /**
   * Update enabled state of chunk action buttons
   */
  updateChunkButtons: function() {
    const splitButton = document.getElementById('split-button');
    const mergeButton = document.getElementById('merge-button');
    
    if (splitButton) {
      splitButton.disabled = STATE.selectedChunks.length !== 1;
    }
    
    if (mergeButton) {
      mergeButton.disabled = STATE.selectedChunks.length < 2;
    }
  },
  
  /**
   * Update all chunks in the display
   */
  updateChunkDisplay: function() {
    // If a stream is selected, refresh its chunks
    const activeStream = document.querySelector('.data-stream-item.active');
    if (activeStream) {
      this.displayChunksForStream(activeStream.dataset.streamId);
    }
  },
  
  /**
   * Update the split visualizer with selected chunks
   */
  updateSplitVisualizer: function() {
    const visualizer = document.getElementById(CONFIG.elements.splitVisualizer);
    if (!visualizer) return;
    
    if (STATE.selectedChunks.length === 0) {
      visualizer.innerHTML = '<div class="placeholder">Select chunks to visualize splits</div>';
      return;
    }
    
    // If one chunk is selected, show its splits
    if (STATE.selectedChunks.length === 1) {
      const chunkId = STATE.selectedChunks[0];
      
      // Find splits for this chunk
      const relatedSplits = Object.values(STATE.dataSplits).filter(split => 
        split.original_chunk === chunkId ||
        split.resulting_chunks.includes(chunkId)
      );
      
      if (relatedSplits.length === 0) {
        visualizer.innerHTML = `<div class="placeholder">No splits found for chunk ${chunkId}</div>`;
        return;
      }
      
      // Create visualization canvas
      visualizer.innerHTML = '<canvas id="split-canvas" width="600" height="400"></canvas>';
      
      // Draw visualization
      const canvas = document.getElementById('split-canvas');
      if (canvas) {
        this.drawSplitVisualization(canvas, chunkId, relatedSplits);
      }
    } 
    // If multiple chunks are selected, show merge preview
    else if (STATE.selectedChunks.length > 1) {
      visualizer.innerHTML = `
        <div class="merge-preview">
          <h4>Merge Preview</h4>
          <p>Selected ${STATE.selectedChunks.length} chunks for merging</p>
          <div class="merge-visualization">
            ${STATE.selectedChunks.map(id => `
              <div class="merge-chunk" style="background-color: ${this.getChunkColor(id)}">
                ${id.substring(0, 8)}...
              </div>
            `).join('<div class="merge-arrow">→</div>')}
            <div class="merge-arrow">→</div>
            <div class="merge-result">
              Result
            </div>
          </div>
        </div>
      `;
    }
  },
  
  /**
   * Draw split visualization on canvas
   */
  drawSplitVisualization: function(canvas, chunkId, splits) {
    const ctx = canvas.getContext('2d');
    const width = canvas.width;
    const height = canvas.height;
    
    // Clear canvas
    ctx.fillStyle = 'rgba(0, 0, 0, 0.2)';
    ctx.fillRect(0, 0, width, height);
    
    // Draw connection lines
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.5)';
    ctx.lineWidth = 2;
    
    // Draw original chunk
    ctx.fillStyle = this.getChunkColor(chunkId);
    ctx.fillRect(width/2 - 40, 50, 80, 80);
    
    // Draw text
    ctx.fillStyle = 'white';
    ctx.font = '12px sans-serif';
    ctx.textAlign = 'center';
    ctx.fillText(chunkId.substring(0, 8) + '...', width/2, 90);
    
    // Draw splits
    splits.forEach((split, index) => {
      // Calculate positions for resulting chunks
      const resultChunks = split.resulting_chunks;
      const chunkCount = resultChunks.length;
      const spacing = width / (chunkCount + 1);
      
      // Draw split arrow
      ctx.beginPath();
      ctx.moveTo(width/2, 130);
      ctx.lineTo(width/2, 180);
      ctx.stroke();
      
      // Draw split factor
      ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
      ctx.fillText(`Split Factor: ${split.factor}`, width/2, 160);
      
      // Draw resulting chunks
      resultChunks.forEach((resultId, i) => {
        const x = (i + 1) * spacing - 30;
        const y = 200;
        
        // Connection line
        ctx.beginPath();
        ctx.moveTo(width/2, 180);
        ctx.lineTo(x + 30, 200);
        ctx.stroke();
        
        // Chunk rectangle
        ctx.fillStyle = this.getChunkColor(resultId);
        ctx.fillRect(x, y, 60, 60);
        
        // Chunk text
        ctx.fillStyle = 'white';
        ctx.fillText(resultId.substring(0, 6) + '...', x + 30, y + 30);
      });
    });
  },
  
  /**
   * Get color for a chunk based on its type
   */
  getChunkColor: function(chunkId) {
    const chunk = STATE.dataChunks[chunkId];
    if (!chunk) return '#666';
    
    const type = chunk.type || 'binary';
    return CONFIG.colors.chunks[type] || '#666';
  },
  
  /**
   * Update moon phase indicator
   */
  updateMoonPhase: function() {
    const moonEl = document.getElementById(CONFIG.elements.moonPhase);
    if (!moonEl) return;
    
    // Update title
    moonEl.title = `Moon Phase: ${STATE.moonPhase}/7`;
    
    // Phase 0 = full moon, phase 4 = new moon
    // Update shadow effect to show phase
    const shadowIntensity = Math.abs(STATE.moonPhase - 4) / 4.0;
    const shadowOffset = STATE.moonPhase < 4 ? 
      -15 + STATE.moonPhase * 7.5 : 
      -45 + STATE.moonPhase * 7.5;

    moonEl.style.boxShadow = `inset ${shadowOffset}px 0 10px rgba(0, 0, 0, ${1 - shadowIntensity})`;
    
    // Adjust colors based on phase
    if (STATE.moonPhase <= 1 || STATE.moonPhase >= 7) {
      // Full/almost full
      moonEl.style.backgroundColor = '#f0f0f0';
    } else if (STATE.moonPhase >= 3 && STATE.moonPhase <= 5) {
      // New/almost new
      moonEl.style.backgroundColor = '#737373';
    } else {
      // Quarter
      moonEl.style.backgroundColor = '#b3b3b3';
    }
  },
  
  /**
   * Update connection status indicator
   */
  updateConnectionStatus: function(connected, message = null) {
    const statusEl = document.getElementById(CONFIG.elements.connectionStatus);
    if (!statusEl) return;
    
    const indicator = statusEl.querySelector('.connection-indicator');
    const text = statusEl.querySelector('span');
    
    if (connected) {
      indicator.classList.remove('disconnected');
      indicator.classList.add('connected');
      text.textContent = message || 'Connected';
    } else {
      indicator.classList.remove('connected');
      indicator.classList.add('disconnected');
      text.textContent = message || 'Disconnected';
    }
  },
  
  /**
   * Update environment based on current dimension
   */
  updateEnvironment: function() {
    const container = document.getElementById(CONFIG.elements.container);
    if (!container) return;
    
    // Set background color based on dimension
    container.style.backgroundColor = CONFIG.colors.backgrounds[STATE.currentDimension] || CONFIG.colors.backgrounds["3D"];
    
    // Update dimension selector
    const dimensionSelector = document.getElementById(CONFIG.elements.dimensionSelector);
    if (dimensionSelector) {
      dimensionSelector.value = STATE.currentDimension;
    }
    
    // Update reality selector
    const realitySelector = document.getElementById(CONFIG.elements.realitySelector);
    if (realitySelector) {
      realitySelector.value = STATE.currentReality;
    }
    
    // Apply special effects based on dimension
    const splitVisualizer = document.getElementById(CONFIG.elements.splitVisualizer);
    if (splitVisualizer) {
      // Reset effects
      splitVisualizer.style.filter = '';
      
      // Apply dimension-specific effects
      if (STATE.currentDimension === "5D") {
        // Consciousness - blur effect
        splitVisualizer.style.filter = 'blur(1px)';
      } else if (STATE.currentDimension === "7D") {
        // Creation - glow effect
        splitVisualizer.style.filter = 'brightness(1.2) saturate(1.2)';
      } else if (STATE.currentDimension === "12D") {
        // Beyond - ethereal effect
        splitVisualizer.style.filter = 'brightness(1.5) contrast(1.2) saturate(0.8)';
      }
    }
  }
};

// Initialize when document is ready
document.addEventListener('DOMContentLoaded', function() {
  UI.initialize();
  API.initialize();
});

// Expose API for external access
window.DataSplitterBridge = {
  API: API,
  STATE: STATE,
  CONFIG: CONFIG
};