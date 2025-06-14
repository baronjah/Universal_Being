/**
 * Akashic Browser Connector
 * 
 * This system provides a browser-based interface to connect with the Akashic Records system.
 * It allows for cross-device memory synchronization, data visualization, and integration
 * with the Notepad3D and memory systems.
 */

// Configuration
const AkashicConnectorConfig = {
    // Connection settings
    SERVER_URL: 'http://localhost:8080',          // Default local server URL
    WEBSOCKET_URL: 'ws://localhost:8081',         // WebSocket for real-time updates
    CLOUD_SYNC_URL: 'https://api.akashicrecords.example.com', // Cloud sync endpoint (placeholder)
    SYNC_INTERVAL: 60000,                         // Sync every 60 seconds by default
    
    // Authentication
    AUTH_REQUIRED: false,                         // Set to true to require auth
    AUTH_TOKEN_KEY: 'akashic_browser_auth_token', // Local storage key for auth token
    
    // Storage settings
    LOCAL_STORAGE_KEY: 'akashic_browser_data',    // Local storage key for cached data
    MAX_LOCAL_STORAGE_SIZE: 5 * 1024 * 1024,      // 5MB max local storage
    USE_INDEXED_DB: true,                         // Use IndexedDB for larger storage
    DB_NAME: 'AkashicRecordsDB',                  // IndexedDB database name
    DB_VERSION: 1,                                // Database version
    
    // Connection settings
    CONNECTION_TIMEOUT: 10000,                    // 10 second connection timeout
    RETRY_ATTEMPTS: 3,                            // Number of connection retry attempts
    RETRY_DELAY: 2000,                            // Delay between retries (ms)
    
    // Memory system settings
    MEMORY_TYPES: [
        'temporal',    // Time-based memories
        'spatial',     // Space-based memories
        'semantic',    // Meaning-based memories
        'procedural',  // Action-based memories
        'emotional'    // Feeling-based memories
    ],
    
    // Database tables/stores
    STORES: [
        {name: 'records', keyPath: 'id'},
        {name: 'connections', keyPath: 'id'},
        {name: 'memories', keyPath: 'id'},
        {name: 'dimensions', keyPath: 'id'},
        {name: 'realities', keyPath: 'id'},
        {name: 'symbols', keyPath: 'id'},
        {name: 'fileLinks', keyPath: 'id'}
    ],
    
    // Visualization settings
    ENABLE_3D_VISUALIZATION: true,
    DIMENSION_COUNT: 3,
    REALITY_TYPES: ['physical', 'digital', 'astral', 'memory', 'dream'],
    COLOR_SCHEME: {
        background: '#1a1a2e',
        nodes: '#0f3460',
        connections: '#e94560',
        highlights: '#16213e',
        text: '#ffffff'
    }
};

/**
 * Main Akashic Browser Connector class
 */
class AkashicBrowserConnector {
    constructor(config = {}) {
        // Merge provided config with defaults
        this.config = {...AkashicConnectorConfig, ...config};
        
        // State
        this.initialized = false;
        this.connected = false;
        this.authenticated = false;
        this.db = null;
        this.ws = null;
        this.syncInterval = null;
        this.currentDimension = this.config.DIMENSION_COUNT;
        this.currentReality = this.config.REALITY_TYPES[1]; // Default to digital
        this.records = new Map();
        this.memories = new Map();
        this.connections = new Map();
        
        // Event handlers
        this.eventHandlers = {
            'connect': [],
            'disconnect': [],
            'sync': [],
            'error': [],
            'dimensionChange': [],
            'realityChange': [],
            'recordCreated': [],
            'recordUpdated': [],
            'recordDeleted': [],
            'memoryStored': [],
            'queryCompleted': []
        };
        
        // DOM elements for visualization
        this.visualizationContainer = null;
        this.canvas = null;
        this.threejsScene = null;
        
        // API methods are bound to this instance
        this.initialize = this.initialize.bind(this);
        this.connect = this.connect.bind(this);
        this.disconnect = this.disconnect.bind(this);
        this.authenticate = this.authenticate.bind(this);
        this.storeRecord = this.storeRecord.bind(this);
        this.retrieveRecord = this.retrieveRecord.bind(this);
        this.queryRecords = this.queryRecords.bind(this);
        this.deleteRecord = this.deleteRecord.bind(this);
        this.syncWithCloud = this.syncWithCloud.bind(this);
    }
    
    /**
     * Initialize the Akashic Browser Connector
     */
    async initialize() {
        console.log('Initializing Akashic Browser Connector...');
        
        try {
            // Initialize database
            await this._initDatabase();
            
            // Load cached data
            await this._loadCachedData();
            
            // Initialize visualization if enabled
            if (this.config.ENABLE_3D_VISUALIZATION) {
                this._initVisualization();
            }
            
            // Establish connection if online
            if (navigator.onLine) {
                this.connect();
            }
            
            // Set up event listeners
            window.addEventListener('online', () => {
                console.log('Device online, connecting to Akashic system...');
                this.connect();
            });
            
            window.addEventListener('offline', () => {
                console.log('Device offline, working in local mode...');
                this.disconnect();
            });
            
            // Set up sync interval
            this.syncInterval = setInterval(() => {
                if (navigator.onLine && this.connected) {
                    this.syncWithCloud();
                }
            }, this.config.SYNC_INTERVAL);
            
            this.initialized = true;
            console.log('Akashic Browser Connector initialized successfully.');
            
            return true;
        } catch (error) {
            console.error('Failed to initialize Akashic Browser Connector:', error);
            this._emitEvent('error', {message: 'Initialization failed', error});
            return false;
        }
    }
    
    /**
     * Initialize IndexedDB database
     */
    async _initDatabase() {
        if (!this.config.USE_INDEXED_DB) {
            console.log('IndexedDB disabled, using local storage only.');
            return;
        }
        
        return new Promise((resolve, reject) => {
            if (!window.indexedDB) {
                console.warn('IndexedDB not supported, falling back to local storage.');
                this.config.USE_INDEXED_DB = false;
                resolve();
                return;
            }
            
            const request = indexedDB.open(this.config.DB_NAME, this.config.DB_VERSION);
            
            request.onerror = (event) => {
                console.error('IndexedDB error:', event.target.error);
                this.config.USE_INDEXED_DB = false;
                reject(new Error('Failed to open database'));
            };
            
            request.onupgradeneeded = (event) => {
                console.log('Creating or upgrading database...');
                this.db = event.target.result;
                
                // Create object stores for each type of data
                this.config.STORES.forEach(store => {
                    if (!this.db.objectStoreNames.contains(store.name)) {
                        const objectStore = this.db.createObjectStore(store.name, { keyPath: store.keyPath });
                        
                        // Create indexes for common queries
                        if (store.name === 'records' || store.name === 'memories') {
                            objectStore.createIndex('timestamp', 'timestamp', { unique: false });
                            objectStore.createIndex('reality', 'reality', { unique: false });
                            objectStore.createIndex('dimension', 'dimension', { unique: false });
                        }
                        
                        if (store.name === 'connections') {
                            objectStore.createIndex('sourceId', 'sourceId', { unique: false });
                            objectStore.createIndex('targetId', 'targetId', { unique: false });
                        }
                    }
                });
            };
            
            request.onsuccess = (event) => {
                this.db = event.target.result;
                console.log('Database initialized successfully.');
                resolve();
            };
        });
    }
    
    /**
     * Load data from database or local storage
     */
    async _loadCachedData() {
        if (this.config.USE_INDEXED_DB && this.db) {
            try {
                // Load records from IndexedDB
                await this._loadDataFromDB('records', this.records);
                await this._loadDataFromDB('memories', this.memories);
                await this._loadDataFromDB('connections', this.connections);
                
                console.log(`Loaded ${this.records.size} records, ${this.memories.size} memories, and ${this.connections.size} connections from IndexedDB.`);
            } catch (error) {
                console.error('Error loading data from IndexedDB:', error);
                this._fallbackToLocalStorage();
            }
        } else {
            this._fallbackToLocalStorage();
        }
    }
    
    /**
     * Load data from IndexedDB into a Map
     */
    async _loadDataFromDB(storeName, targetMap) {
        return new Promise((resolve, reject) => {
            if (!this.db) {
                reject(new Error('Database not initialized'));
                return;
            }
            
            const transaction = this.db.transaction(storeName, 'readonly');
            const store = transaction.objectStore(storeName);
            const request = store.getAll();
            
            request.onsuccess = () => {
                const items = request.result;
                items.forEach(item => {
                    targetMap.set(item.id, item);
                });
                resolve();
            };
            
            request.onerror = (event) => {
                reject(new Error(`Error loading ${storeName}: ${event.target.error}`));
            };
        });
    }
    
    /**
     * Fall back to local storage if IndexedDB fails
     */
    _fallbackToLocalStorage() {
        console.log('Falling back to local storage...');
        
        try {
            const data = localStorage.getItem(this.config.LOCAL_STORAGE_KEY);
            if (data) {
                const parsedData = JSON.parse(data);
                
                if (parsedData.records) {
                    this.records = new Map(Object.entries(parsedData.records));
                }
                
                if (parsedData.memories) {
                    this.memories = new Map(Object.entries(parsedData.memories));
                }
                
                if (parsedData.connections) {
                    this.connections = new Map(Object.entries(parsedData.connections));
                }
                
                console.log(`Loaded ${this.records.size} records, ${this.memories.size} memories, and ${this.connections.size} connections from local storage.`);
            }
        } catch (error) {
            console.error('Error loading data from local storage:', error);
            
            // Reset to empty maps if data is corrupted
            this.records = new Map();
            this.memories = new Map();
            this.connections = new Map();
        }
    }
    
    /**
     * Save current state to persistent storage
     */
    async _saveState() {
        if (this.config.USE_INDEXED_DB && this.db) {
            try {
                await this._saveMapToDB('records', this.records);
                await this._saveMapToDB('memories', this.memories);
                await this._saveMapToDB('connections', this.connections);
            } catch (error) {
                console.error('Error saving to IndexedDB, falling back to local storage:', error);
                this._saveToLocalStorage();
            }
        } else {
            this._saveToLocalStorage();
        }
    }
    
    /**
     * Save a Map to IndexedDB
     */
    async _saveMapToDB(storeName, dataMap) {
        return new Promise((resolve, reject) => {
            if (!this.db) {
                reject(new Error('Database not initialized'));
                return;
            }
            
            const transaction = this.db.transaction(storeName, 'readwrite');
            const store = transaction.objectStore(storeName);
            
            // Convert Map to array of values
            const values = Array.from(dataMap.values());
            
            // Clear store and add all values
            const clearRequest = store.clear();
            
            clearRequest.onsuccess = () => {
                let completed = 0;
                
                if (values.length === 0) {
                    resolve();
                    return;
                }
                
                values.forEach(value => {
                    const request = store.add(value);
                    
                    request.onsuccess = () => {
                        completed++;
                        if (completed === values.length) {
                            resolve();
                        }
                    };
                    
                    request.onerror = (event) => {
                        console.error(`Error adding item to ${storeName}:`, event.target.error);
                        completed++;
                        if (completed === values.length) {
                            resolve(); // Still resolve to continue the process
                        }
                    };
                });
            };
            
            clearRequest.onerror = (event) => {
                reject(new Error(`Error clearing ${storeName}: ${event.target.error}`));
            };
        });
    }
    
    /**
     * Save data to local storage
     */
    _saveToLocalStorage() {
        try {
            // Convert Maps to objects
            const data = {
                records: Object.fromEntries(this.records),
                memories: Object.fromEntries(this.memories),
                connections: Object.fromEntries(this.connections),
                lastSaved: Date.now()
            };
            
            const jsonString = JSON.stringify(data);
            
            // Check if we exceed local storage size
            if (jsonString.length > this.config.MAX_LOCAL_STORAGE_SIZE) {
                console.warn(`Data exceeds maximum local storage size (${jsonString.length} > ${this.config.MAX_LOCAL_STORAGE_SIZE}). Some data may be lost.`);
                
                // Simplified approach: just keep the most recent items
                this._pruneDataForStorage();
                return this._saveToLocalStorage(); // Retry with pruned data
            }
            
            localStorage.setItem(this.config.LOCAL_STORAGE_KEY, jsonString);
            console.log('State saved to local storage successfully.');
        } catch (error) {
            console.error('Error saving to local storage:', error);
            
            if (error instanceof DOMException && error.name === 'QuotaExceededError') {
                // If quota exceeded, try to prune data
                this._pruneDataForStorage();
                this._saveToLocalStorage(); // Retry
            }
        }
    }
    
    /**
     * Prune data to fit within storage limits
     */
    _pruneDataForStorage() {
        // Get all records sorted by timestamp (newest first)
        const sortedRecords = Array.from(this.records.values())
            .sort((a, b) => b.timestamp - a.timestamp);
        
        const sortedMemories = Array.from(this.memories.values())
            .sort((a, b) => b.timestamp - a.timestamp);
        
        // Keep only the newest items
        const recordsToKeep = sortedRecords.slice(0, Math.floor(sortedRecords.length * 0.7));
        const memoriesToKeep = sortedMemories.slice(0, Math.floor(sortedMemories.length * 0.7));
        
        // Create new Maps
        this.records = new Map(recordsToKeep.map(r => [r.id, r]));
        this.memories = new Map(memoriesToKeep.map(m => [m.id, m]));
        
        // Prune connections that reference deleted records or memories
        const validIds = new Set([
            ...this.records.keys(),
            ...this.memories.keys()
        ]);
        
        this.connections = new Map(
            Array.from(this.connections.values())
                .filter(c => validIds.has(c.sourceId) && validIds.has(c.targetId))
                .map(c => [c.id, c])
        );
        
        console.log(`Pruned data: ${sortedRecords.length - recordsToKeep.length} records and ${sortedMemories.length - memoriesToKeep.length} memories removed.`);
    }
    
    /**
     * Initialize 3D visualization if enabled
     */
    _initVisualization() {
        // Check for THREE.js
        if (typeof THREE === 'undefined') {
            console.warn('THREE.js not found, visualization disabled.');
            this.config.ENABLE_3D_VISUALIZATION = false;
            return;
        }
        
        // Find or create container
        this.visualizationContainer = document.getElementById('akashic-visualization');
        if (!this.visualizationContainer) {
            this.visualizationContainer = document.createElement('div');
            this.visualizationContainer.id = 'akashic-visualization';
            this.visualizationContainer.style.position = 'absolute';
            this.visualizationContainer.style.top = '0';
            this.visualizationContainer.style.left = '0';
            this.visualizationContainer.style.width = '100%';
            this.visualizationContainer.style.height = '100%';
            this.visualizationContainer.style.zIndex = '-1';
            document.body.appendChild(this.visualizationContainer);
        }
        
        // Set up THREE.js scene
        this._setupThreeJsScene();
    }
    
    /**
     * Set up THREE.js scene for data visualization
     */
    _setupThreeJsScene() {
        // This is a placeholder for THREE.js setup
        // In a real implementation, this would initialize a THREE.js scene,
        // camera, renderer, and controls for 3D visualization
        
        console.log('THREE.js visualization initialized.');
        
        // Create a simple notification to indicate visualization is ready
        const notification = document.createElement('div');
        notification.style.position = 'fixed';
        notification.style.bottom = '20px';
        notification.style.right = '20px';
        notification.style.padding = '10px 20px';
        notification.style.backgroundColor = 'rgba(0, 0, 0, 0.7)';
        notification.style.color = 'white';
        notification.style.borderRadius = '5px';
        notification.textContent = 'Akashic Records 3D Visualization Active';
        document.body.appendChild(notification);
        
        // Remove after 3 seconds
        setTimeout(() => {
            notification.style.opacity = '0';
            notification.style.transition = 'opacity 0.5s ease';
            setTimeout(() => notification.remove(), 500);
        }, 3000);
    }
    
    /**
     * Connect to the Akashic system server
     */
    async connect() {
        if (this.connected) {
            console.log('Already connected to Akashic system.');
            return true;
        }
        
        console.log(`Connecting to Akashic system at ${this.config.SERVER_URL}...`);
        
        // Attempt to connect with retries
        for (let attempt = 1; attempt <= this.config.RETRY_ATTEMPTS; attempt++) {
            try {
                const response = await fetch(`${this.config.SERVER_URL}/status`, {
                    method: 'GET',
                    headers: this._getAuthHeaders(),
                    timeout: this.config.CONNECTION_TIMEOUT
                });
                
                if (response.ok) {
                    const data = await response.json();
                    this.connected = true;
                    
                    console.log('Connected to Akashic system:', data);
                    
                    // Set up WebSocket for real-time updates
                    this._setupWebSocket();
                    
                    // Sync with server
                    this.syncWithCloud();
                    
                    // Emit connect event
                    this._emitEvent('connect', {serverInfo: data});
                    
                    return true;
                } else {
                    throw new Error(`Server returned ${response.status}: ${response.statusText}`);
                }
            } catch (error) {
                console.warn(`Connection attempt ${attempt} failed:`, error);
                
                if (attempt < this.config.RETRY_ATTEMPTS) {
                    console.log(`Retrying in ${this.config.RETRY_DELAY / 1000} seconds...`);
                    await new Promise(resolve => setTimeout(resolve, this.config.RETRY_DELAY));
                } else {
                    console.error('All connection attempts failed. Working in offline mode.');
                    this._emitEvent('error', {message: 'Connection failed', error});
                    return false;
                }
            }
        }
        
        return false;
    }
    
    /**
     * Disconnect from the Akashic system server
     */
    disconnect() {
        if (!this.connected) {
            return;
        }
        
        console.log('Disconnecting from Akashic system...');
        
        // Close WebSocket connection
        if (this.ws) {
            this.ws.close();
            this.ws = null;
        }
        
        this.connected = false;
        this._emitEvent('disconnect');
    }
    
    /**
     * Set up WebSocket connection for real-time updates
     */
    _setupWebSocket() {
        if (!this.config.WEBSOCKET_URL) {
            return;
        }
        
        // Close existing connection if any
        if (this.ws) {
            this.ws.close();
        }
        
        try {
            this.ws = new WebSocket(this.config.WEBSOCKET_URL);
            
            this.ws.onopen = () => {
                console.log('WebSocket connection established.');
                
                // Send authentication if required
                if (this.config.AUTH_REQUIRED && this.authenticated) {
                    this.ws.send(JSON.stringify({
                        type: 'auth',
                        token: localStorage.getItem(this.config.AUTH_TOKEN_KEY)
                    }));
                }
            };
            
            this.ws.onmessage = (event) => {
                try {
                    const message = JSON.parse(event.data);
                    this._handleWebSocketMessage(message);
                } catch (error) {
                    console.error('Error processing WebSocket message:', error);
                }
            };
            
            this.ws.onclose = () => {
                console.log('WebSocket connection closed.');
                this.ws = null;
                
                // Attempt to reconnect if we're still supposed to be connected
                if (this.connected) {
                    setTimeout(() => {
                        if (this.connected) {
                            this._setupWebSocket();
                        }
                    }, 5000);
                }
            };
            
            this.ws.onerror = (error) => {
                console.error('WebSocket error:', error);
            };
            
        } catch (error) {
            console.error('Failed to create WebSocket connection:', error);
        }
    }
    
    /**
     * Handle incoming WebSocket messages
     */
    _handleWebSocketMessage(message) {
        switch (message.type) {
            case 'record_update':
                this._handleRecordUpdate(message.data);
                break;
                
            case 'memory_update':
                this._handleMemoryUpdate(message.data);
                break;
                
            case 'connection_update':
                this._handleConnectionUpdate(message.data);
                break;
                
            case 'dimension_change':
                this.currentDimension = message.dimension;
                this._emitEvent('dimensionChange', {
                    dimension: message.dimension,
                    previousDimension: this.currentDimension
                });
                break;
                
            case 'reality_change':
                this.currentReality = message.reality;
                this._emitEvent('realityChange', {
                    reality: message.reality,
                    previousReality: this.currentReality
                });
                break;
                
            case 'sync_request':
                this.syncWithCloud();
                break;
                
            default:
                console.warn('Unknown WebSocket message type:', message.type);
        }
    }
    
    /**
     * Handle record updates from WebSocket
     */
    _handleRecordUpdate(data) {
        if (data.deleted) {
            this.records.delete(data.id);
            this._emitEvent('recordDeleted', {id: data.id});
        } else {
            const existing = this.records.get(data.id);
            
            if (existing) {
                // Update existing record
                const updated = {...existing, ...data, updatedAt: Date.now()};
                this.records.set(data.id, updated);
                this._emitEvent('recordUpdated', {record: updated, previous: existing});
            } else {
                // Create new record
                const record = {
                    ...data,
                    createdAt: Date.now(),
                    updatedAt: Date.now()
                };
                this.records.set(data.id, record);
                this._emitEvent('recordCreated', {record});
            }
        }
        
        // Save changes
        this._saveState();
    }
    
    /**
     * Handle memory updates from WebSocket
     */
    _handleMemoryUpdate(data) {
        if (data.deleted) {
            this.memories.delete(data.id);
        } else {
            const existing = this.memories.get(data.id);
            
            if (existing) {
                // Update existing memory
                const updated = {...existing, ...data, updatedAt: Date.now()};
                this.memories.set(data.id, updated);
            } else {
                // Create new memory
                const memory = {
                    ...data,
                    createdAt: Date.now(),
                    updatedAt: Date.now()
                };
                this.memories.set(data.id, memory);
            }
            
            this._emitEvent('memoryStored', {
                memory: this.memories.get(data.id),
                isNew: !existing
            });
        }
        
        // Save changes
        this._saveState();
    }
    
    /**
     * Handle connection updates from WebSocket
     */
    _handleConnectionUpdate(data) {
        if (data.deleted) {
            this.connections.delete(data.id);
        } else {
            const connection = {
                ...data,
                updatedAt: Date.now()
            };
            this.connections.set(data.id, connection);
        }
        
        // Save changes
        this._saveState();
    }
    
    /**
     * Authenticate with the Akashic system server
     */
    async authenticate(credentials) {
        if (!this.config.AUTH_REQUIRED) {
            console.log('Authentication not required.');
            this.authenticated = true;
            return {success: true};
        }
        
        if (!this.connected) {
            await this.connect();
        }
        
        if (!this.connected) {
            return {success: false, error: 'Not connected to server'};
        }
        
        try {
            const response = await fetch(`${this.config.SERVER_URL}/auth`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(credentials)
            });
            
            if (response.ok) {
                const data = await response.json();
                
                if (data.token) {
                    localStorage.setItem(this.config.AUTH_TOKEN_KEY, data.token);
                    this.authenticated = true;
                    
                    // Re-establish WebSocket with authentication
                    this._setupWebSocket();
                    
                    return {success: true, data};
                } else {
                    return {success: false, error: 'No authentication token received'};
                }
            } else {
                const error = await response.text();
                return {success: false, error};
            }
        } catch (error) {
            console.error('Authentication error:', error);
            return {success: false, error: error.message};
        }
    }
    
    /**
     * Get authentication headers for API requests
     */
    _getAuthHeaders() {
        const headers = {
            'Content-Type': 'application/json'
        };
        
        if (this.config.AUTH_REQUIRED && this.authenticated) {
            const token = localStorage.getItem(this.config.AUTH_TOKEN_KEY);
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }
        }
        
        return headers;
    }
    
    /**
     * Store a record in the Akashic system
     */
    async storeRecord(record) {
        // Generate ID if not provided
        if (!record.id) {
            record.id = this._generateId();
        }
        
        // Add metadata if not present
        const now = Date.now();
        const completeRecord = {
            ...record,
            createdAt: record.createdAt || now,
            updatedAt: now,
            dimension: record.dimension || this.currentDimension,
            reality: record.reality || this.currentReality
        };
        
        // Store locally
        this.records.set(completeRecord.id, completeRecord);
        this._saveState();
        
        // Emit event
        this._emitEvent('recordCreated', {record: completeRecord});
        
        // Store remotely if connected
        if (this.connected) {
            try {
                const response = await fetch(`${this.config.SERVER_URL}/records`, {
                    method: 'POST',
                    headers: this._getAuthHeaders(),
                    body: JSON.stringify(completeRecord)
                });
                
                if (!response.ok) {
                    throw new Error(`Server returned ${response.status}: ${response.statusText}`);
                }
                
                const result = await response.json();
                
                // Update local record with any server-side changes
                if (result.record && result.record.id === completeRecord.id) {
                    this.records.set(result.record.id, result.record);
                    this._saveState();
                }
                
                return {success: true, record: result.record || completeRecord};
            } catch (error) {
                console.error('Error storing record remotely:', error);
                // We still return success since the record was stored locally
                return {
                    success: true,
                    record: completeRecord,
                    warning: 'Stored locally only due to connection error: ' + error.message
                };
            }
        }
        
        return {success: true, record: completeRecord, warning: 'Stored locally only (not connected)'};
    }
    
    /**
     * Retrieve a record from the Akashic system
     */
    async retrieveRecord(id, forceRefresh = false) {
        // Check local cache first, unless force refresh requested
        if (!forceRefresh && this.records.has(id)) {
            return {success: true, record: this.records.get(id), source: 'local'};
        }
        
        // If connected, try to get from server
        if (this.connected) {
            try {
                const response = await fetch(`${this.config.SERVER_URL}/records/${id}`, {
                    method: 'GET',
                    headers: this._getAuthHeaders()
                });
                
                if (response.ok) {
                    const data = await response.json();
                    
                    // Update local cache
                    if (data.record) {
                        this.records.set(id, data.record);
                        this._saveState();
                        return {success: true, record: data.record, source: 'remote'};
                    } else {
                        return {success: false, error: 'Record not found on server'};
                    }
                } else if (response.status === 404) {
                    // Record not found on server, check local cache as fallback
                    if (this.records.has(id)) {
                        return {
                            success: true,
                            record: this.records.get(id),
                            source: 'local',
                            warning: 'Record not found on server, using local copy'
                        };
                    } else {
                        return {success: false, error: 'Record not found'};
                    }
                } else {
                    throw new Error(`Server returned ${response.status}: ${response.statusText}`);
                }
            } catch (error) {
                console.error('Error retrieving record from server:', error);
                
                // Fall back to local cache
                if (this.records.has(id)) {
                    return {
                        success: true,
                        record: this.records.get(id),
                        source: 'local',
                        warning: 'Server error, using local copy: ' + error.message
                    };
                } else {
                    return {success: false, error: 'Record not found locally or remotely'};
                }
            }
        } else {
            // Not connected, check local cache only
            if (this.records.has(id)) {
                return {
                    success: true,
                    record: this.records.get(id),
                    source: 'local',
                    warning: 'Not connected to server, using local copy only'
                };
            } else {
                return {success: false, error: 'Record not found locally and not connected to server'};
            }
        }
    }
    
    /**
     * Query records based on criteria
     */
    queryRecords(criteria = {}) {
        // Filter records based on criteria
        const results = Array.from(this.records.values()).filter(record => {
            for (const key in criteria) {
                if (key === 'dimension' && criteria.dimension !== undefined) {
                    if (record.dimension !== criteria.dimension) {
                        return false;
                    }
                    continue;
                }
                
                if (key === 'reality' && criteria.reality !== undefined) {
                    if (record.reality !== criteria.reality) {
                        return false;
                    }
                    continue;
                }
                
                if (key === 'type' && criteria.type !== undefined) {
                    if (record.type !== criteria.type) {
                        return false;
                    }
                    continue;
                }
                
                if (key === 'tags' && criteria.tags !== undefined) {
                    if (!record.tags || !Array.isArray(record.tags)) {
                        return false;
                    }
                    
                    // Check if record has all required tags
                    for (const tag of criteria.tags) {
                        if (!record.tags.includes(tag)) {
                            return false;
                        }
                    }
                    continue;
                }
                
                if (key === 'search' && criteria.search !== undefined) {
                    const searchStr = criteria.search.toLowerCase();
                    
                    // Search in content and title
                    const contentMatch = record.content && 
                        typeof record.content === 'string' && 
                        record.content.toLowerCase().includes(searchStr);
                    
                    const titleMatch = record.title && 
                        typeof record.title === 'string' && 
                        record.title.toLowerCase().includes(searchStr);
                    
                    if (!contentMatch && !titleMatch) {
                        return false;
                    }
                    continue;
                }
                
                if (key === 'createdAfter' && criteria.createdAfter !== undefined) {
                    if (!record.createdAt || record.createdAt < criteria.createdAfter) {
                        return false;
                    }
                    continue;
                }
                
                if (key === 'createdBefore' && criteria.createdBefore !== undefined) {
                    if (!record.createdAt || record.createdAt > criteria.createdBefore) {
                        return false;
                    }
                    continue;
                }
                
                // Default property comparison
                if (record[key] !== criteria[key]) {
                    return false;
                }
            }
            
            return true;
        });
        
        // Sort results if sort criteria provided
        if (criteria.sort) {
            const {field, direction} = criteria.sort;
            
            results.sort((a, b) => {
                if (a[field] < b[field]) {
                    return direction === 'asc' ? -1 : 1;
                }
                if (a[field] > b[field]) {
                    return direction === 'asc' ? 1 : -1;
                }
                return 0;
            });
        } else {
            // Default sort by updatedAt (most recent first)
            results.sort((a, b) => (b.updatedAt || 0) - (a.updatedAt || 0));
        }
        
        // Apply pagination if specified
        if (criteria.page !== undefined && criteria.perPage !== undefined) {
            const page = criteria.page || 1;
            const perPage = criteria.perPage || 20;
            const startIndex = (page - 1) * perPage;
            const endIndex = startIndex + perPage;
            
            const paginatedResults = results.slice(startIndex, endIndex);
            
            this._emitEvent('queryCompleted', {
                count: results.length,
                page,
                perPage,
                totalPages: Math.ceil(results.length / perPage),
                results: paginatedResults
            });
            
            return {
                success: true,
                count: results.length,
                page,
                perPage,
                totalPages: Math.ceil(results.length / perPage),
                results: paginatedResults
            };
        }
        
        // Return all results if no pagination
        this._emitEvent('queryCompleted', {
            count: results.length,
            results
        });
        
        return {
            success: true,
            count: results.length,
            results
        };
    }
    
    /**
     * Delete a record from the Akashic system
     */
    async deleteRecord(id) {
        // Delete locally first
        const record = this.records.get(id);
        if (!record) {
            return {success: false, error: 'Record not found'};
        }
        
        this.records.delete(id);
        this._saveState();
        
        // Emit event
        this._emitEvent('recordDeleted', {id, record});
        
        // Delete remotely if connected
        if (this.connected) {
            try {
                const response = await fetch(`${this.config.SERVER_URL}/records/${id}`, {
                    method: 'DELETE',
                    headers: this._getAuthHeaders()
                });
                
                if (!response.ok) {
                    throw new Error(`Server returned ${response.status}: ${response.statusText}`);
                }
                
                return {success: true};
            } catch (error) {
                console.error('Error deleting record from server:', error);
                return {
                    success: true,
                    warning: 'Deleted locally but server deletion failed: ' + error.message
                };
            }
        }
        
        return {success: true, warning: 'Deleted locally only (not connected)'};
    }
    
    /**
     * Sync with cloud server
     */
    async syncWithCloud() {
        if (!this.connected) {
            return {success: false, error: 'Not connected to server'};
        }
        
        console.log('Syncing with cloud server...');
        
        try {
            // Get last sync timestamp from local storage
            const lastSyncTimestamp = localStorage.getItem('akashic_last_sync_timestamp') || 0;
            
            // Request changes since last sync
            const response = await fetch(`${this.config.SERVER_URL}/sync`, {
                method: 'POST',
                headers: this._getAuthHeaders(),
                body: JSON.stringify({
                    lastSyncTimestamp,
                    localChanges: {
                        records: Array.from(this.records.values()).filter(r => r.updatedAt > lastSyncTimestamp),
                        memories: Array.from(this.memories.values()).filter(m => m.updatedAt > lastSyncTimestamp),
                        connections: Array.from(this.connections.values()).filter(c => c.updatedAt > lastSyncTimestamp)
                    }
                })
            });
            
            if (!response.ok) {
                throw new Error(`Server returned ${response.status}: ${response.statusText}`);
            }
            
            const syncData = await response.json();
            
            // Process server changes
            let recordsUpdated = 0;
            let memoriesUpdated = 0;
            let connectionsUpdated = 0;
            
            // Update records
            if (syncData.serverChanges.records) {
                syncData.serverChanges.records.forEach(record => {
                    // Check if the server version is newer
                    const localRecord = this.records.get(record.id);
                    if (!localRecord || localRecord.updatedAt < record.updatedAt) {
                        this.records.set(record.id, record);
                        recordsUpdated++;
                    }
                });
            }
            
            // Update memories
            if (syncData.serverChanges.memories) {
                syncData.serverChanges.memories.forEach(memory => {
                    // Check if the server version is newer
                    const localMemory = this.memories.get(memory.id);
                    if (!localMemory || localMemory.updatedAt < memory.updatedAt) {
                        this.memories.set(memory.id, memory);
                        memoriesUpdated++;
                    }
                });
            }
            
            // Update connections
            if (syncData.serverChanges.connections) {
                syncData.serverChanges.connections.forEach(connection => {
                    // Check if the server version is newer
                    const localConnection = this.connections.get(connection.id);
                    if (!localConnection || localConnection.updatedAt < connection.updatedAt) {
                        this.connections.set(connection.id, connection);
                        connectionsUpdated++;
                    }
                });
            }
            
            // Save changes locally
            this._saveState();
            
            // Update last sync timestamp
            localStorage.setItem('akashic_last_sync_timestamp', Date.now().toString());
            
            // Emit sync event
            this._emitEvent('sync', {
                success: true,
                recordsUpdated,
                memoriesUpdated,
                connectionsUpdated,
                timestamp: Date.now()
            });
            
            console.log(`Sync completed: Updated ${recordsUpdated} records, ${memoriesUpdated} memories, ${connectionsUpdated} connections.`);
            
            return {
                success: true,
                recordsUpdated,
                memoriesUpdated,
                connectionsUpdated
            };
        } catch (error) {
            console.error('Sync error:', error);
            
            this._emitEvent('error', {message: 'Sync failed', error});
            
            return {success: false, error: error.message};
        }
    }
    
    /**
     * Generate a unique ID
     */
    _generateId() {
        return 'akr_' + Date.now().toString(36) + Math.random().toString(36).substr(2, 9);
    }
    
    /**
     * Register an event handler
     */
    on(eventName, handler) {
        if (this.eventHandlers[eventName]) {
            this.eventHandlers[eventName].push(handler);
        } else {
            console.warn(`Unknown event: ${eventName}`);
        }
        
        return this; // For chaining
    }
    
    /**
     * Remove an event handler
     */
    off(eventName, handler) {
        if (this.eventHandlers[eventName]) {
            this.eventHandlers[eventName] = this.eventHandlers[eventName]
                .filter(h => h !== handler);
        }
        
        return this; // For chaining
    }
    
    /**
     * Emit an event
     */
    _emitEvent(eventName, data = {}) {
        if (this.eventHandlers[eventName]) {
            this.eventHandlers[eventName].forEach(handler => {
                try {
                    handler(data);
                } catch (error) {
                    console.error(`Error in event handler for ${eventName}:`, error);
                }
            });
        }
    }
    
    /**
     * Store a memory
     */
    async storeMemory(memory) {
        // Generate ID if not provided
        if (!memory.id) {
            memory.id = this._generateId();
        }
        
        // Add metadata if not present
        const now = Date.now();
        const completeMemory = {
            ...memory,
            type: memory.type || 'semantic',
            createdAt: memory.createdAt || now,
            updatedAt: now,
            dimension: memory.dimension || this.currentDimension,
            reality: memory.reality || this.currentReality,
            timestamp: memory.timestamp || now
        };
        
        // Store locally
        this.memories.set(completeMemory.id, completeMemory);
        this._saveState();
        
        // Emit event
        this._emitEvent('memoryStored', {memory: completeMemory, isNew: true});
        
        // Store remotely if connected
        if (this.connected) {
            try {
                const response = await fetch(`${this.config.SERVER_URL}/memories`, {
                    method: 'POST',
                    headers: this._getAuthHeaders(),
                    body: JSON.stringify(completeMemory)
                });
                
                if (!response.ok) {
                    throw new Error(`Server returned ${response.status}: ${response.statusText}`);
                }
                
                const result = await response.json();
                
                // Update local memory with any server-side changes
                if (result.memory && result.memory.id === completeMemory.id) {
                    this.memories.set(result.memory.id, result.memory);
                    this._saveState();
                }
                
                return {success: true, memory: result.memory || completeMemory};
            } catch (error) {
                console.error('Error storing memory remotely:', error);
                // We still return success since the memory was stored locally
                return {
                    success: true,
                    memory: completeMemory,
                    warning: 'Stored locally only due to connection error: ' + error.message
                };
            }
        }
        
        return {success: true, memory: completeMemory, warning: 'Stored locally only (not connected)'};
    }
    
    /**
     * Create a connection between two entities
     */
    async createConnection(sourceId, targetId, type = 'related', metadata = {}) {
        const id = `conn_${sourceId}_${targetId}_${Math.random().toString(36).substr(2, 9)}`;
        
        const connection = {
            id,
            sourceId,
            targetId,
            type,
            metadata,
            createdAt: Date.now(),
            updatedAt: Date.now(),
            dimension: metadata.dimension || this.currentDimension,
            reality: metadata.reality || this.currentReality
        };
        
        // Store locally
        this.connections.set(id, connection);
        this._saveState();
        
        // Store remotely if connected
        if (this.connected) {
            try {
                const response = await fetch(`${this.config.SERVER_URL}/connections`, {
                    method: 'POST',
                    headers: this._getAuthHeaders(),
                    body: JSON.stringify(connection)
                });
                
                if (!response.ok) {
                    throw new Error(`Server returned ${response.status}: ${response.statusText}`);
                }
            } catch (error) {
                console.error('Error storing connection remotely:', error);
                // Connection was still stored locally
            }
        }
        
        return {success: true, connection};
    }
    
    /**
     * Change the current dimension
     */
    changeDimension(dimension) {
        const previousDimension = this.currentDimension;
        this.currentDimension = dimension;
        
        // Emit event
        this._emitEvent('dimensionChange', {dimension, previousDimension});
        
        // Notify server if connected
        if (this.connected && this.ws && this.ws.readyState === WebSocket.OPEN) {
            this.ws.send(JSON.stringify({
                type: 'dimension_change',
                dimension
            }));
        }
        
        return {success: true, dimension, previousDimension};
    }
    
    /**
     * Change the current reality
     */
    changeReality(reality) {
        const previousReality = this.currentReality;
        this.currentReality = reality;
        
        // Emit event
        this._emitEvent('realityChange', {reality, previousReality});
        
        // Notify server if connected
        if (this.connected && this.ws && this.ws.readyState === WebSocket.OPEN) {
            this.ws.send(JSON.stringify({
                type: 'reality_change',
                reality
            }));
        }
        
        return {success: true, reality, previousReality};
    }
}

// Create and export a default instance
const akashicConnector = new AkashicBrowserConnector();

// Auto-initialize when the DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    akashicConnector.initialize().catch(error => {
        console.error('Failed to initialize Akashic Browser Connector:', error);
    });
});

// Export the class and default instance
window.AkashicBrowserConnector = AkashicBrowserConnector;
window.akashicConnector = akashicConnector;

// Export as a module if supported
if (typeof module !== 'undefined' && typeof module.exports !== 'undefined') {
    module.exports = {
        AkashicBrowserConnector,
        akashicConnector
    };
}