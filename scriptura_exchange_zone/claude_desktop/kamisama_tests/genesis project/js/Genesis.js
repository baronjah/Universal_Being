/**
 * Genesis.js - Self-Evolving System Core
 * 
 * This is the bootstrap file for the Galaxies Site system.
 * It analyzes the current environment, organizes files,
 * and establishes the core CSV visualization grid system.
 */




class Genesis {
    constructor() {
        // System state
        this.initialized = false;
        this.rootPath = "";
        this.fileStructure = {};
        this.filesByExtension = {};
        this.csvData = {};
        this.connections = {};
        this.visualizers = {};
        this.csvGridEditor = null;
        this.connectionManager = null;
        this.settingsManager = null;
        
        // Configuration
        this.config = {
            supportedExtensions: [
                "html", "css", "js", "csv", "json", "xml", 
                "md", "py", "gd", "gdshader", "glsl", "cpp", "h", "tsx"
            ],
            visualizationTypes: ["grid", "galaxy", "map", "network", "tree"],
            defaultVisualization: "grid",
            theme: "dark",
            fontSize: "14",
            animations: true,
            autoScan: true,
            autoConnect: true
        };
        
        // DOM Elements
        this.elements = {
            container: null,
            
            grid: null,
            toolbar: null,
            sidebar: null,
            statusBar: null
        };
        


        
        
        // new stuff here
        this._initializeComponents();






        // Connection state
        this.connectionState = {
            active: false,
            source: null,
            target: null
        };
        
        // Initialize event listeners
        this.eventListeners = {};
    }
    
    /**
     * Initialize the Genesis system
     * @param {Object} options - Initialization options
     */
    async initialize(options = {}) {
        console.log("🌌 Genesis system initializing...");
        
        // Load saved settings from localStorage if available
        this._loadSettings();
        
        // Merge options with defaults
        this.config = {...this.config, ...options};
        
        // Set the root path
        this.rootPath = options.rootPath || this._detectRootPath();
        
        // Scan the file system
        await this._scanFileSystem();
        
        // Initialize the UI
        this._initializeUI();
        
        // Create visualizers
        this._initializeVisualizers();
        
        // Register event handlers
        this._registerEventHandlers();
        
        this.initialized = true;
        console.log("🌌 Genesis system initialized");
        
        // Trigger initial visualization
        this.visualize(this.config.defaultVisualization);
        
        return this;
    }
    
    /**
     * Load settings from localStorage
     * @private
     */
    _loadSettings() {
        try {
            const savedSettings = localStorage.getItem('genesis-settings');
            if (savedSettings) {
                const settings = JSON.parse(savedSettings);
                this.config = {...this.config, ...settings};
                
                // Apply theme
                if (this.config.theme === 'light') {
                    document.documentElement.style.setProperty('--genesis-bg-dark', '#f5f5f5');
                    document.documentElement.style.setProperty('--genesis-bg-darker', '#e0e0e0');
                    document.documentElement.style.setProperty('--genesis-bg-light', '#ffffff');
                    document.documentElement.style.setProperty('--genesis-text-primary', '#333333');
                    document.documentElement.style.setProperty('--genesis-text-secondary', '#666666');
                    document.documentElement.style.setProperty('--genesis-border-color', '#cccccc');
                }
                
                // Apply font size
                document.documentElement.style.setProperty('--genesis-font-size', `${this.config.fontSize}px`);
            }
        } catch (error) {
            console.error('Error loading settings:', error);
        }
    }
    
    /**
     * Detect the root path of the application
     * @private
     */
    _detectRootPath() {
        // In browser environment, use the current path
        return window.location.pathname.substring(0, window.location.pathname.lastIndexOf('/') + 1);
    }
    
    /**
     * Scan the file system to build the file structure
     * @private
     */
    async _scanFileSystem() {
        console.log("📂 Scanning file structure...");
        
        try {
            // In a real environment, this would use the FileSystem API
            // For now, we'll simulate with a fetch to a manifest file or API
            
            const response = await fetch(`${this.rootPath}api/file-structure`).catch(() => {
                // If API fails, try to use a static manifest file
                return fetch(`${this.rootPath}file-structure.json`);
            }).catch(() => {
                // If both fail, use the demo data
                return Promise.resolve({
                    ok: true,
                    json: () => Promise.resolve(this._getDemoFileStructure())
                });
            });
            
            if (response.ok) {
                const data = await response.json();
                this.fileStructure = data;
                this._categorizeFilesByExtension();
                console.log("📂 File structure scan complete");
            } else {
                console.error("Failed to scan file structure");
                // Use demo data as fallback
                this.fileStructure = this._getDemoFileStructure();
                this._categorizeFilesByExtension();
            }
        } catch (error) {
            console.error("Error scanning file structure:", error);
            // Use demo data as fallback
            this.fileStructure = this._getDemoFileStructure();
            this._categorizeFilesByExtension();
        }
    }
    
    /**
     * Get a demo file structure for testing
     * @private
     */
    _getDemoFileStructure() {
        return {
            "name": "galaxies-site",
            "type": "directory",
            "children": [
                {
                    "name": "assets",
                    "type": "directory",
                    "children": []
                },
                {
                    "name": "css",
                    "type": "directory",
                    "children": [
                        {
                            "name": "main.css",
                            "type": "file",
                            "size": 2085,
                            "extension": "css",
                            "path": "/css/main.css"
                        },
                        {
                            "name": "window-styles.css",
                            "type": "file",
                            "size": 8851,
                            "extension": "css",
                            "path": "/css/window-styles.css"
                        }
                    ]
                },
                {
                    "name": "js",
                    "type": "directory",
                    "children": [
                        {
                            "name": "Visualization-engine.js",
                            "type": "file",
                            "size": 15220,
                            "extension": "js",
                            "path": "/js/Visualization-engine.js"
                        },
                        {
                            "name": "Data_Connector.js",
                            "type": "file",
                            "size": 13986,
                            "extension": "js",
                            "path": "/js/Data_Connector.js"
                        }
                    ]
                },
                {
                    "name": "csv",
                    "type": "directory",
                    "children": [
                        {
                            "name": "sample_kit_items.csv",
                            "type": "file",
                            "size": 1561,
                            "extension": "csv",
                            "path": "/csv/sample_kit_items.csv"
                        },
                        {
                            "name": "sample_component_items.csv",
                            "type": "file",
                            "size": 2466,
                            "extension": "csv",
                            "path": "/csv/sample_component_items.csv"
                        }
                    ]
                },
                {
                    "name": "html",
                    "type": "directory",
                    "children": [
                        {
                            "name": "index.html",
                            "type": "file",
                            "size": 2155,
                            "extension": "html",
                            "path": "/html/index.html"
                        },
                        {
                            "name": "map-page.html",
                            "type": "file",
                            "size": 17740,
                            "extension": "html",
                            "path": "/html/map-page.html"
                        },
                        {
                            "name": "netsuite-console.html",
                            "type": "file",
                            "size": 60544,
                            "extension": "html",
                            "path": "/html/netsuite-console.html"
                        }
                    ]
                }
            ]
        };
    }
    
    /**
     * Categorize files by extension for easier access
     * @private
     */
    _categorizeFilesByExtension() {
        // Reset the file extension map
        this.filesByExtension = {};
        
        const processNode = (node, path = "") => {
            if (node.type === "file") {
                const ext = node.extension || this._getExtension(node.name);
                
                if (!this.filesByExtension[ext]) {
                    this.filesByExtension[ext] = [];
                }
                
                this.filesByExtension[ext].push({
                    ...node,
                    path: path + "/" + node.name
                });
            } else if (node.type === "directory" && node.children) {
                node.children.forEach(child => {
                    processNode(child, path + "/" + node.name);
                });
            }
        };
        
        // Start processing from the root
        if (this.fileStructure.children) {
            this.fileStructure.children.forEach(node => {
                processNode(node, "");
            });
        }
        
        console.log("🔍 Files categorized by extension:", Object.keys(this.filesByExtension));
    }
    
    /**
     * Get the file extension from a filename
     * @private
     */
    _getExtension(filename) {
        return filename.slice((filename.lastIndexOf(".") - 1 >>> 0) + 2);
    }
    
    /**
     * Initialize the UI components
     * @private
     */
    _initializeUI() {
        console.log("🖥️ Initializing UI...");
        
        // Create or find the container element
        this.elements.container = document.getElementById('genesis-container');
        if (!this.elements.container) {
            this.elements.container = document.createElement('div');
            this.elements.container.id = 'genesis-container';
            document.body.appendChild(this.elements.container);
        }
        
        // Create the base layout
        this.elements.container.innerHTML = `
            <div id="genesis-toolbar" class="genesis-toolbar">
                <div class="genesis-logo">
                    <i class="fas fa-project-diagram"></i>
                    <span>Genesis</span>
                </div>
                <div class="genesis-tools">
                    <button id="genesis-btn-grid" title="Grid View"><i class="fas fa-th"></i></button>
                    <button id="genesis-btn-galaxy" title="Galaxy View"><i class="fas fa-star"></i></button>
                    <button id="genesis-btn-map" title="Map View"><i class="fas fa-project-diagram"></i></button>
                    <button id="genesis-btn-add" title="Add Connection"><i class="fas fa-plus"></i></button>
                    <button id="genesis-btn-settings" title="Settings"><i class="fas fa-cog"></i></button>
                </div>
            </div>
            <div class="genesis-main">
                <div id="genesis-sidebar" class="genesis-sidebar">
                    <div class="genesis-sidebar-section">
                        <h3>Files</h3>
                        <div id="genesis-file-tree" class="genesis-file-tree"></div>
                    </div>
                    <div class="genesis-sidebar-section">
                        <h3>Connections</h3>
                        <div id="genesis-connections" class="genesis-connections"></div>
                    </div>
                </div>
                <div id="genesis-content" class="genesis-content">
                    <div id="genesis-grid-view" class="genesis-view"></div>
                    <div id="genesis-galaxy-view" class="genesis-view" style="display: none;"></div>
                    <div id="genesis-map-view" class="genesis-view" style="display: none;"></div>
                </div>
            </div>
            <div id="genesis-status-bar" class="genesis-status-bar">
                Ready | Genesis System v0.1 | Visualization: Grid
            </div>
        `;
        
        // Save references to important elements
        this.elements.toolbar = document.getElementById('genesis-toolbar');
        this.elements.sidebar = document.getElementById('genesis-sidebar');
        this.elements.gridView = document.getElementById('genesis-grid-view');
        this.elements.galaxyView = document.getElementById('genesis-galaxy-view');
        this.elements.mapView = document.getElementById('genesis-map-view');
        this.elements.statusBar = document.getElementById('genesis-status-bar');
        
        // Inject CSS
        this._injectStyles();
        
        console.log("🖥️ UI initialized");
    }
    
    /**
     * Inject the required CSS styles
     * @private
     */
    _injectStyles() {
        const styleId = 'genesis-styles';
        
        // Check if styles already exist
        if (document.getElementById(styleId)) {
            return;
        }
        
        const style = document.createElement('style');
        style.id = styleId;
        style.textContent = `
            :root {
                --genesis-bg-dark: #1e1e1e;
                --genesis-bg-darker: #151515;
                --genesis-bg-light: #252525;
                --genesis-text-primary: #f0f0f0;
                --genesis-text-secondary: #a0a0a0;
                --genesis-accent-blue: #0078d7;
                --genesis-accent-green: #6a9955;
                --genesis-accent-red: #f14c4c;
                --genesis-accent-yellow: #dcdcaa;
                --genesis-accent-purple: #c586c0;
                --genesis-border-color: #454545;
                --genesis-font-size: 14px;
            }
            
            #genesis-container {
                display: flex;
                flex-direction: column;
                height: 100vh;
                overflow: hidden;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                color: var(--genesis-text-primary);
                background-color: var(--genesis-bg-dark);
                font-size: var(--genesis-font-size);
            }
            
            .genesis-toolbar {
                height: 40px;
                background-color: var(--genesis-bg-darker);
                border-bottom: 1px solid var(--genesis-border-color);
                display: flex;
                align-items: center;
                padding: 0 10px;
                justify-content: space-between;
            }
            
            .genesis-logo {
                display: flex;
                align-items: center;
                font-weight: bold;
            }
            
            .genesis-logo i {
                margin-right: 8px;
                color: var(--genesis-accent-blue);
            }
            
            .genesis-tools button {
                background: transparent;
                border: 1px solid var(--genesis-border-color);
                color: var(--genesis-text-primary);
                padding: 4px 8px;
                margin-right: 5px;
                cursor: pointer;
                border-radius: 3px;
            }
            
            .genesis-tools button:hover {
                background-color: var(--genesis-bg-light);
            }
            
            .genesis-main {
                display: flex;
                flex: 1;
                overflow: hidden;
            }
            
            /* Updated sidebar styles for more modern look */
            .genesis-sidebar {
                width: 250px;
                background-color: var(--genesis-bg-darker);
                border-right: 1px solid var(--genesis-border-color);
                display: flex;
                flex-direction: column;
                overflow: auto;
                transition: width 0.3s ease;
                box-shadow: 2px 0 5px rgba(0, 0, 0, 0.1);
            }
            
            .genesis-sidebar-section {
                margin-bottom: 10px;
            }
            
            .genesis-sidebar-section h3 {
                padding: 12px 15px;
                margin: 0;
                font-size: 14px;
                color: var(--genesis-text-secondary);
                font-weight: 500;
                letter-spacing: 0.5px;
                background-color: rgba(0, 0, 0, 0.1);
            }
            
            .genesis-file-tree, .genesis-connections {
                padding: 8px 0;
            }
            
            .genesis-tree-item, .genesis-connection-item {
                padding: 8px 15px;
                display: flex;
                align-items: center;
                cursor: pointer;
                transition: background-color 0.2s;
                border-left: 3px solid transparent;
            }
            
            .genesis-tree-item:hover, .genesis-connection-item:hover {
                background-color: var(--genesis-bg-light);
                border-left-color: var(--genesis-accent-blue);
            }
            
            .genesis-tree-item i, .genesis-connection-item i {
                margin-right: 8px;
                width: 16px;
                text-align: center;
            }
            
            .genesis-content {
                flex: 1;
                position: relative;
                overflow: hidden;
            }
            
            .genesis-view {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                overflow: auto;
            }
            
            .genesis-status-bar {
                height: 25px;
                background-color: var(--genesis-bg-darker);
                border-top: 1px solid var(--genesis-border-color);
                display: flex;
                align-items: center;
                padding: 0 10px;
                font-size: 12px;
                color: var(--genesis-text-secondary);
            }
            
            /* Grid View Specific */
            .genesis-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
                gap: 10px;
                padding: 10px;
            }
            
            .genesis-cell {
                background-color: var(--genesis-bg-darker);
                border: 1px solid var(--genesis-border-color);
                border-radius: 3px;
                padding: 10px;
                position: relative;
                overflow: hidden;
                min-height: 60px;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
                cursor: pointer;
            }
            
            .genesis-cell:hover {
                border-color: var(--genesis-accent-blue);
            }
            
            .genesis-cell.selected {
                background-color: var(--genesis-bg-light);
                border-color: var(--genesis-accent-blue);
            }
            
            .genesis-cell.connection-source {
                border: 2px solid var(--genesis-accent-green);
                box-shadow: 0 0 8px var(--genesis-accent-green);
            }
            
            .genesis-cell-content {
                word-break: break-word;
                text-align: center;
                font-size: 12px;
            }
            
            .genesis-cell-icon {
                margin-bottom: 5px;
                font-size: 24px;
            }
            
            /* Connection line styles */
            .genesis-connection-line {
                position: absolute;
                pointer-events: none;
                z-index: 1;
                background-color: var(--genesis-accent-blue);
                height: 2px;
                transform-origin: 0 0;
            }
            
            /* Galaxy view styles */
            .genesis-star {
                position: absolute;
                border-radius: 50%;
                cursor: pointer;
                display: flex;
                align-items: center;
                justify-content: center;
                transition: transform 0.2s;
                box-shadow: 0 0 10px rgba(255, 255, 255, 0.2);
            }
            
            .genesis-star:hover {
                transform: scale(1.1);
            }
            
            .genesis-star.selected {
                box-shadow: 0 0 15px rgba(255, 255, 255, 0.5);
            }
            
            .genesis-star.connection-source {
                border: 2px solid var(--genesis-accent-green);
                box-shadow: 0 0 15px var(--genesis-accent-green);
            }
            
            .genesis-star-label {
                position: absolute;
                bottom: -20px;
                font-size: 12px;
                white-space: nowrap;
                background-color: rgba(0, 0, 0, 0.7);
                padding: 2px 5px;
                border-radius: 3px;
            }
            
            /* CSV specific styles */
            .genesis-csv-grid {
                display: table;
                border-collapse: collapse;
            }
            
            .genesis-csv-row {
                display: table-row;
            }
            
            .genesis-csv-row.selected {
                background-color: rgba(0, 120, 215, 0.1);
            }
            
            .genesis-csv-cell {
                display: table-cell;
                border: 1px solid var(--genesis-border-color);
                padding: 5px 10px;
                min-width: 100px;
            }
            
            .genesis-csv-header {
                background-color: var(--genesis-bg-darker);
                font-weight: bold;
            }
            
            .genesis-csv-header.selected {
                background-color: rgba(0, 120, 215, 0.3);
            }
            
            /* Details panel */
            .genesis-details-panel {
                position: absolute;
                right: 0;
                top: 0;
                width: 300px;
                height: 100%;
                background-color: var(--genesis-bg-darker);
                border-left: 1px solid var(--genesis-border-color);
                overflow: auto;
                transform: translateX(100%);
                transition: transform 0.3s;
                z-index: 10;
            }
            
            .genesis-details-panel.visible {
                transform: translateX(0);
            }
            
            .genesis-details-header {
                padding: 10px;
                border-bottom: 1px solid var(--genesis-border-color);
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            
            .genesis-details-close {
                cursor: pointer;
                color: var(--genesis-text-secondary);
            }
            
            .genesis-details-content {
                padding: 10px;
            }
            
            /* Map node styles with hover effect */
            .genesis-map-node {
                position: absolute;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-weight: bold;
                text-align: center;
                cursor: pointer;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
                z-index: 2;
                user-select: none;
                transition: transform 0.3s ease, box-shadow 0.3s ease;
            }
            
            .genesis-map-node:hover {
                transform: scale(1.1);
                z-index: 10;
                box-shadow: 0 6px 12px rgba(0, 0, 0, 0.4);
            }
            
            .genesis-map-node.connection-source {
                border: 2px solid var(--genesis-accent-green);
                box-shadow: 0 0 15px var(--genesis-accent-green);
            }
            
            /* Modal styles for settings, connections */
            .genesis-modal-overlay {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(0, 0, 0, 0.5);
                display: flex;
                justify-content: center;
                align-items: center;
                z-index: 1000;
            }






























            
            .genesis-modal {
                background-color: var(--genesis-bg-dark);
                border-radius: 5px;
                box-shadow: 0 5px 15px rgba(0, 0, 0, 0.5);
                width: 500px;
                max-width: 90%;
                max-height: 90vh;
                display: flex;
                flex-direction: column;
                overflow: hidden;
            }
            
            .genesis-modal-header {
                padding: 15px;
                border-bottom: 1px solid var(--genesis-border-color);
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            
            .genesis-modal-header h3 {
                margin: 0;
                font-size: 18px;
            }
            
            .genesis-modal-close {
                background: none;
                border: none;
                color: var(--genesis-text-secondary);
                font-size: 16px;
                cursor: pointer;
            }
            
            .genesis-modal-content {
                padding: 15px;
                overflow-y: auto;
                flex: 1;
            }
            
            .genesis-modal-footer {
                padding: 15px;
                border-top: 1px solid var(--genesis-border-color);
                display: flex;
                justify-content: flex-end;
                gap: 10px;
            }
            
            /* Button styles */
            .genesis-btn {
                padding: 8px 12px;
                border-radius: 4px;
                cursor: pointer;
                font-size: 14px;
                border: none;
            }
            
            .genesis-btn-primary {
                background-color: var(--genesis-accent-blue);
                color: white;
            }
            
            .genesis-btn-secondary {
                background-color: var(--genesis-bg-light);
                color: var(--genesis-text-primary);
                border: 1px solid var(--genesis-border-color);
            }
            
            /* Settings-specific styles */
            .genesis-settings-section {
                margin-bottom: 20px;
            }
            
            .genesis-settings-section h4 {
                margin-top: 0;
                margin-bottom: 10px;
                padding-bottom: 5px;
                border-bottom: 1px solid var(--genesis-border-color);
            }
            
            .genesis-setting-item {
                display: flex;
                align-items: center;
                margin-bottom: 10px;
                justify-content: space-between;
            }
            
            .genesis-setting-item label {
                margin-right: 10px;
            }
            
            .genesis-setting-item input,
            .genesis-setting-item select {
                padding: 5px;
                border-radius: 3px;
                background-color: var(--genesis-bg-light);
                color: var(--genesis-text-primary);
                border: 1px solid var(--genesis-border-color);
            }
            
            /* Toggle switch styles */
            .toggle-switch {
                position: relative;
                display: inline-block;
                width: 40px;
                height: 22px;
            }
            
            .toggle-switch input {
                opacity: 0;
                width: 0;
                height: 0;
            }
            
            .toggle-slider {
                position: absolute;
                cursor: pointer;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background-color: var(--genesis-bg-light);
                transition: .4s;
                border-radius: 22px;
            }
            
            .toggle-slider:before {
                position: absolute;
                content: "";
                height: 16px;
                width: 16px;
                left: 3px;
                bottom: 3px;
                background-color: var(--genesis-text-primary);
                transition: .4s;
                border-radius: 50%;
            }
            
            input:checked + .toggle-slider {
                background-color: var(--genesis-accent-blue);
            }
            
            input:checked + .toggle-slider:before {
                transform: translateX(18px);
            }
            
            /* Notification styles */
            .genesis-notification {
                position: fixed;
                bottom: 20px;
                right: 20px;
                background-color: var(--genesis-accent-green);
                color: white;
                padding: 10px 15px;
                border-radius: 5px;
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
                z-index: 1000;
                opacity: 0;
                transition: opacity 0.3s;
            }
            
            .genesis-notification.error {
                background-color: var(--genesis-accent-red);
            }
        `;
        
        document.head.appendChild(style);
    }

    














    // new thingy here

    /**
     * Initialize additional components
     * @private
     */
    _initializeComponents() {
        console.log("🧩 Initializing additional components...");
        
        // Initialize CSV Grid Editor
        const gridContainer = document.getElementById('csv-grid-container');
        if (gridContainer) {
            this.csvGridEditor = new CSVGridEditor(gridContainer, {
                editable: true,
                allowAddRows: true,
                allowAddColumns: true,
                maxRows: 10000
            });
            
            // Add event listeners
            gridContainer.addEventListener('csv-grid-dataSaved', (e) => {
                console.log('CSV data saved:', e.detail);
                // Update data cache
                if (e.detail.fileId) {
                    this.csvData[e.detail.fileId] = e.detail.data;
                }
            });
        }
        
        // Initialize Connection Manager
        this.connectionManager = new ConnectionManager();
        
        // Initialize Settings Manager
        const settingsContainer = document.getElementById('settings-panel');
        if (settingsContainer) {
            this.settingsManager = new SettingsManager();
            this.settingsManager.initialize(settingsContainer);
            
            // Listen for settings changes
            document.addEventListener('settings-settingsApplied', (e) => {
                console.log('Settings applied:', e.detail);
                this._applySettings(e.detail);
            });
        }
        
        console.log("🧩 Components initialized");
    }














    /**
     * Apply settings to components
     * @param {Object} settings - The settings object
     * @private
     */
    _applySettings(settings) {
        // Apply to CSV Grid Editor
        if (this.csvGridEditor) {
            if (this.csvGridEditor.options) {
                this.csvGridEditor.options.editable = true;
                this.csvGridEditor.options.allowAddRows = true;
                this.csvGridEditor.options.allowAddColumns = true;
                this.csvGridEditor.options.maxRows = settings.gridMaxRows || 10000;
            }
            
            // Re-render if needed
            if (this.csvGridEditor.data) {
                this.csvGridEditor.renderGrid();
            }
        }
        
        // Apply theme
        if (settings.theme === 'light') {
            document.documentElement.style.setProperty('--genesis-bg-dark', '#f5f5f5');
            document.documentElement.style.setProperty('--genesis-bg-darker', '#e0e0e0');
            document.documentElement.style.setProperty('--genesis-bg-light', '#ffffff');
            document.documentElement.style.setProperty('--genesis-text-primary', '#333333');
            document.documentElement.style.setProperty('--genesis-text-secondary', '#666666');
            document.documentElement.style.setProperty('--genesis-border-color', '#cccccc');
        } else {
            document.documentElement.style.setProperty('--genesis-bg-dark', '#1e1e1e');
            document.documentElement.style.setProperty('--genesis-bg-darker', '#151515');
            document.documentElement.style.setProperty('--genesis-bg-light', '#252525');
            document.documentElement.style.setProperty('--genesis-text-primary', '#f0f0f0');
            document.documentElement.style.setProperty('--genesis-text-secondary', '#a0a0a0');
            document.documentElement.style.setProperty('--genesis-border-color', '#454545');
        }
        
        // Apply font size
        document.documentElement.style.setProperty('--genesis-font-size', `${settings.fontSize || 14}px`);
        
        // Update configuration
        this.config = {...this.config, ...settings};
    }




    /**
     * Initialize the different visualization methods
     * @private
     */
    _initializeVisualizers() {
        // Grid visualizer
        this.visualizers.grid = {
            render: (data) => this._renderGridView(data)
        };
        
        // Galaxy visualizer
        this.visualizers.galaxy = {
            render: (data) => this._renderGalaxyView(data)
        };
        
        // Map visualizer
        this.visualizers.map = {
            render: (data) => this._renderMapView(data)
        };
    }
    
    /**
     * Register event handlers for UI elements
     * @private
     */
    _registerEventHandlers() {
        // View toggle buttons
        document.getElementById('genesis-btn-grid').addEventListener('click', () => this.visualize('grid'));
        document.getElementById('genesis-btn-galaxy').addEventListener('click', () => this.visualize('galaxy'));
        document.getElementById('genesis-btn-map').addEventListener('click', () => this.visualize('map'));
        
        // Add connection button
        document.getElementById('genesis-btn-add').addEventListener('click', () => this._startConnectionMode());
        
        // Settings button
        document.getElementById('genesis-btn-settings').addEventListener('click', () => this._showSettings());
    }
    
/**
     * Visualize the data using the specified visualization type
     * @param {string} type - Visualization type ('grid', 'galaxy', 'map')
     * @param {Object} data - Data to visualize (optional)
     */
    visualize(type, data) {
        if (!this.visualizers[type]) {
            console.error(`Visualization type '${type}' not supported`);
            return;
        }
        
        // Hide all views
        this.elements.gridView.style.display = 'none';
        this.elements.galaxyView.style.display = 'none';
        this.elements.mapView.style.display = 'none';
        
        // Show the selected view
        this.elements[`${type}View`].style.display = 'block';
        
        // Update status bar
        this.elements.statusBar.textContent = `Ready | Genesis System v0.1 | Visualization: ${type.charAt(0).toUpperCase() + type.slice(1)}`;
        
        // Render the visualization
        this.visualizers[type].render(data || this._getVisualizationData());
        
        // Add hover effect for map view
        if (type === 'map') {
            this._enhanceMapView();
        }
    }
    
    /**
     * Get data for visualization
     * @private
     */
    _getVisualizationData() {
        // For now, return the file structure
        return {
            fileStructure: this.fileStructure,
            filesByExtension: this.filesByExtension,
            connections: this.connections
        };
    }
    
    /**
     * Improve the Map View with hover enlargement
     * @private
     */
    _enhanceMapView() {
        // Find all map nodes
        const nodes = document.querySelectorAll('.genesis-map-node');
        
        nodes.forEach(node => {
            // Add hover effects (already in CSS)
            // Additional effects can be added here if needed
        });
    }
    
    /**
     * Render the grid view
     * @param {Object} data - Data to visualize
     * @private
     */
    _renderGridView(data) {
        console.log("🌐 Rendering grid view");
        
        // Clear the view
        this.elements.gridView.innerHTML = '';
        
        // Create a grid container
        const grid = document.createElement('div');
        grid.className = 'genesis-grid';
        
        // Add cells for each file type category
        Object.keys(data.filesByExtension).forEach(ext => {
            const files = data.filesByExtension[ext];
            
            // Create a cell for this extension
            const cell = document.createElement('div');
            cell.className = 'genesis-cell';
            cell.dataset.type = 'extension';
            cell.dataset.extension = ext;
            
            // Add content to the cell
            cell.innerHTML = `
                <div class="genesis-cell-icon">
                    <i class="fas ${this._getIconForExtension(ext)}"></i>
                </div>
                <div class="genesis-cell-content">
                    ${ext.toUpperCase()} (${files.length})
                </div>
            `;
            
            // Add click handler
            cell.addEventListener('click', () => this._showExtensionDetails(ext));
            
            // Add the cell to the grid
            grid.appendChild(cell);
        });
        
        // Add the grid to the view
        this.elements.gridView.appendChild(grid);
    }
    
    /**
     * Render the galaxy view
     * @param {Object} data - Data to visualize
     * @private
     */
    _renderGalaxyView(data) {
        console.log("🌌 Rendering galaxy view");
        
        // Clear the view
        this.elements.galaxyView.innerHTML = '';
        
        // Create a starfield background
        this._createStarfieldBackground(this.elements.galaxyView);
        
        // Calculate the center of the view
        const rect = this.elements.galaxyView.getBoundingClientRect();
        const centerX = rect.width / 2;
        const centerY = rect.height / 2;
        
        // Add a central "core" star
        const coreSize = 100;
        const core = document.createElement('div');
        core.className = 'genesis-star';
        core.style.width = `${coreSize}px`;
        core.style.height = `${coreSize}px`;
        core.style.backgroundColor = 'rgba(255, 255, 200, 0.8)';
        core.style.left = `${centerX - coreSize/2}px`;
        core.style.top = `${centerY - coreSize/2}px`;
        core.style.boxShadow = '0 0 50px rgba(255, 255, 200, 0.5)';
        core.innerHTML = `<span class="genesis-star-label">Root</span>`;
        
        this.elements.galaxyView.appendChild(core);
        
        // Add stars for each file type
        const types = Object.keys(data.filesByExtension);
        types.forEach((type, index) => {
            const files = data.filesByExtension[type];
            
            // Calculate position in orbit around the core
            const angle = (index / types.length) * Math.PI * 2;
            const distance = 200;
            const x = centerX + Math.cos(angle) * distance;
            const y = centerY + Math.sin(angle) * distance;
            
            // Create star for this file type
            const starSize = 50 + Math.min(files.length * 2, 50);
            const star = document.createElement('div');
            star.className = 'genesis-star';
            star.dataset.type = type;
            star.style.width = `${starSize}px`;
            star.style.height = `${starSize}px`;
            star.style.backgroundColor = this._getColorForExtension(type);
            star.style.left = `${x - starSize/2}px`;
            star.style.top = `${y - starSize/2}px`;
            star.innerHTML = `<span class="genesis-star-label">${type.toUpperCase()} (${files.length})</span>`;
            
            // Add click handler
            star.addEventListener('click', () => this._showExtensionDetails(type));
            
            this.elements.galaxyView.appendChild(star);
            
            // Draw connection line to core
            this._drawConnectionLine(
                this.elements.galaxyView,
                centerX, centerY,
                x, y,
                this._getColorForExtension(type)
            );
            
            // For files within this type, add smaller stars in orbit
            files.slice(0, 5).forEach((file, fileIndex) => {
                const fileAngle = (fileIndex / Math.min(files.length, 5)) * Math.PI * 2 + angle;
                const fileDistance = 80;
                const fileX = x + Math.cos(fileAngle) * fileDistance;
                const fileY = y + Math.sin(fileAngle) * fileDistance;
                
                const fileStar = document.createElement('div');
                fileStar.className = 'genesis-star';
                fileStar.dataset.file = file.path;
                fileStar.style.width = '20px';
                fileStar.style.height = '20px';
                fileStar.style.backgroundColor = this._getColorForExtension(type, 0.7);
                fileStar.style.left = `${fileX - 10}px`;
                fileStar.style.top = `${fileY - 10}px`;
                fileStar.title = file.name;
                
                // Add click handler
                fileStar.addEventListener('click', (e) => {
                    e.stopPropagation();
                    this._showFileDetails(file);
                });
                
                this.elements.galaxyView.appendChild(fileStar);
                
                // Draw connection line to parent star
                this._drawConnectionLine(
                    this.elements.galaxyView,
                    x, y,
                    fileX, fileY,
                    this._getColorForExtension(type, 0.5)
                );
            });
        });
    }
    
    /**
     * Create a starfield background
     * @param {HTMLElement} container - Container element
     * @private
     */
    _createStarfieldBackground(container) {
        // Add background color
        container.style.backgroundColor = '#0c0c1e';
        
        // Add stars
        for (let i = 0; i < 100; i++) {
            const star = document.createElement('div');
            star.style.position = 'absolute';
            star.style.width = `${Math.random() * 2 + 1}px`;
            star.style.height = star.style.width;
            star.style.backgroundColor = 'rgba(255, 255, 255, ' + (Math.random() * 0.7 + 0.3) + ')';
            star.style.borderRadius = '50%';
            star.style.left = `${Math.random() * 100}%`;
            star.style.top = `${Math.random() * 100}%`;
            container.appendChild(star);
        }
    }
    
    /**
     * Draw a connection line between two points
     * @param {HTMLElement} container - Container element
     * @param {number} x1 - Start X coordinate
     * @param {number} y1 - Start Y coordinate
     * @param {number} x2 - End X coordinate
     * @param {number} y2 - End Y coordinate
     * @param {string} color - Line color
     * @private
     */
    _drawConnectionLine(container, x1, y1, x2, y2, color) {
        const length = Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
        const angle = Math.atan2(y2 - y1, x2 - x1) * 180 / Math.PI;
        
        const line = document.createElement('div');
        line.className = 'genesis-connection-line';
        line.style.width = `${length}px`;
        line.style.left = `${x1}px`;
        line.style.top = `${y1}px`;
        line.style.backgroundColor = color || 'rgba(255, 255, 255, 0.5)';
        line.style.transform = `rotate(${angle}deg)`;
        
        container.appendChild(line);
    }
    
    /**
     * Render the map view
     * @param {Object} data - Data to visualize
     * @private
     */
    _renderMapView(data) {
        console.log("🗺️ Rendering map view");
        
        // Clear the view
        this.elements.mapView.innerHTML = '';
        
        // Create a map container
        const mapContainer = document.createElement('div');
        mapContainer.className = 'genesis-map-container';
        
        // Add nodes for each main component
        const components = [
            { id: 'jsh-ethereal', name: 'JSH Ethereal Engine', color: '#3a7bf3', x: 400, y: 150 },
            { id: 'kit-analyzer', name: 'Kit Analyzer', color: '#43a047', x: 200, y: 300 },
            { id: 'netsuite-console', name: 'NetSuite Console', color: '#fb8c00', x: 400, y: 300 },
            { id: 'integrated-solution', name: 'Integrated Solution', color: '#8e24aa', x: 600, y: 300 },
            { id: 'integrated-app', name: 'Enterprise Dev Suite', color: '#d81b60', x: 400, y: 450 }
        ];
        
        // Define connections between components
        const connections = [
            { from: 'jsh-ethereal', to: 'kit-analyzer' },
            { from: 'jsh-ethereal', to: 'netsuite-console' },
            { from: 'jsh-ethereal', to: 'integrated-solution' },
            { from: 'kit-analyzer', to: 'integrated-solution' },
            { from: 'netsuite-console', to: 'integrated-solution' },
            { from: 'integrated-app', to: 'kit-analyzer' },
            { from: 'integrated-app', to: 'netsuite-console' },
            { from: 'integrated-app', to: 'integrated-solution' }
        ];
        
        // Draw connections first (so nodes appear on top)
        connections.forEach(conn => {
            const fromComp = components.find(c => c.id === conn.from);
            const toComp = components.find(c => c.id === conn.to);
            
            if (fromComp && toComp) {
                const line = document.createElement('div');
                line.className = 'genesis-map-connection';
                line.style.position = 'absolute';
                line.style.zIndex = '1';
                line.style.height = '2px';
                line.style.pointerEvents = 'none';
                
                // Set line properties
                const length = Math.sqrt(Math.pow(toComp.x - fromComp.x, 2) + Math.pow(toComp.y - fromComp.y, 2));
                const angle = Math.atan2(toComp.y - fromComp.y, toComp.x - fromComp.x) * 180 / Math.PI;
                
                line.style.width = `${length}px`;
                line.style.left = `${fromComp.x}px`;
                line.style.top = `${fromComp.y}px`;
                line.style.backgroundColor = fromComp.color;
                line.style.opacity = '0.6';
                line.style.transformOrigin = '0 0';
                line.style.transform = `rotate(${angle}deg)`;
                
                mapContainer.appendChild(line);
            }
        });
        
        // Add nodes
        components.forEach(comp => {
            const node = document.createElement('div');
            node.className = 'genesis-map-node';
            node.dataset.id = comp.id;
            node.style.position = 'absolute';
            node.style.left = `${comp.x - 50}px`;
            node.style.top = `${comp.y - 50}px`;
            node.style.width = '100px';
            node.style.height = '100px';
            node.style.borderRadius = '50%';
            node.style.backgroundColor = comp.color;
            node.style.display = 'flex';
            node.style.alignItems = 'center';
            node.style.justifyContent = 'center';
            node.style.color = 'white';
            node.style.fontWeight = 'bold';
            node.style.textAlign = 'center';
            node.style.cursor = 'pointer';
            node.style.boxShadow = '0 4px 8px rgba(0, 0, 0, 0.3)';
            node.style.zIndex = '2';
            node.style.userSelect = 'none';
            
            node.innerHTML = `<div style="padding: 10px">${comp.name}</div>`;
            
            // Add click event
            node.addEventListener('click', () => this._showComponentDetails(comp));
            
            mapContainer.appendChild(node);
        });
        
        // Add details panel
        const detailsPanel = document.createElement('div');
        detailsPanel.className = 'genesis-map-details';
        detailsPanel.id = 'genesis-map-details';
        detailsPanel.style.position = 'absolute';
        detailsPanel.style.right = '20px';
        detailsPanel.style.top = '20px';
        detailsPanel.style.width = '300px';
        detailsPanel.style.backgroundColor = 'var(--genesis-bg-light)';
        detailsPanel.style.border = '1px solid var(--genesis-border-color)';
        detailsPanel.style.borderRadius = '5px';
        detailsPanel.style.padding = '15px';
        detailsPanel.style.display = 'none';
        
        mapContainer.appendChild(detailsPanel);
        
        // Add the map to the view
        this.elements.mapView.appendChild(mapContainer);
    }
    
    /**
     * Show details for a component in the map view
     * @param {Object} comp - Component data
     * @private
     */
    _showComponentDetails(comp) {
        const detailsPanel = document.getElementById('genesis-map-details');
        
        detailsPanel.innerHTML = `
            <h2 style="margin-top: 0; border-bottom: 1px solid var(--genesis-border-color); padding-bottom: 10px;">${comp.name}</h2>
            <p>Type: Component</p>
            <p>ID: ${comp.id}</p>
            <div id="detail-connections">
                <h3>Connections:</h3>
                <ul id="connections-list"></ul>
            </div>
            <a href="#" style="display: inline-block; background-color: var(--genesis-accent-blue); color: white; padding: 5px 15px; border-radius: 3px; text-decoration: none; margin-top: 10px;">Open Component</a>
        `;
        
        detailsPanel.style.display = 'block';
    }
    
    /**
     * Get an icon class for a file extension
     * @param {string} ext - File extension
     * @private
     */
    _getIconForExtension(ext) {
        const iconMap = {
            'html': 'fa-html5',
            'css': 'fa-css3-alt',
            'js': 'fa-js',
            'json': 'fa-code',
            'csv': 'fa-table',
            'xml': 'fa-code',
            'md': 'fa-markdown',
            'py': 'fa-python',
            'gd': 'fa-code',
            'gdshader': 'fa-code',
            'glsl': 'fa-code',
            'cpp': 'fa-code',
            'h': 'fa-code',
            'tsx': 'fa-react'
        };
        
        return iconMap[ext] || 'fa-file-code';
    }
    
    /**
     * Get a color for a file extension
     * @param {string} ext - File extension
     * @param {number} opacity - Color opacity
     * @private
     */
    _getColorForExtension(ext, opacity = 1) {
        const colorMap = {
            'html': `rgba(227, 79, 38, ${opacity})`,   // HTML orange
            'css': `rgba(33, 150, 243, ${opacity})`,   // CSS blue
            'js': `rgba(247, 223, 30, ${opacity})`,    // JS yellow
            'json': `rgba(137, 189, 4, ${opacity})`,   // JSON green
            'csv': `rgba(0, 200, 83, ${opacity})`,     // CSV green
            'xml': `rgba(114, 137, 218, ${opacity})`,  // XML purple
            'md': `rgba(108, 174, 221, ${opacity})`,   // MD blue
            'py': `rgba(55, 118, 171, ${opacity})`,    // Python blue
            'gd': `rgba(65, 105, 225, ${opacity})`,    // GD royal blue
            'gdshader': `rgba(106, 90, 205, ${opacity})`, // GDShader slate blue
            'glsl': `rgba(219, 112, 147, ${opacity})`, // GLSL pink
            'cpp': `rgba(0, 128, 128, ${opacity})`,    // CPP teal
            'h': `rgba(0, 128, 128, ${opacity})`,      // H teal
            'tsx': `rgba(97, 218, 251, ${opacity})`    // TSX react blue
        };
        
        return colorMap[ext] || `rgba(180, 180, 180, ${opacity})`;
    }
    
    /**
     * Show details for a specific file extension
     * @param {string} ext - File extension
     * @private
     */
    _showExtensionDetails(ext) {
        const files = this.filesByExtension[ext] || [];
        console.log(`Showing details for ${ext} files (${files.length} files)`);
        
        // If it's a CSV extension, show the CSV grid editor instead of the modal
        if (ext === 'csv' && files.length > 0) {
            this._loadCsvFileWithEditor(files[0].path);
        }
    }

    /**
     * Load and display a CSV file with the enhanced editor
     * @param {string} path - Path to the CSV file
     * @private
     */
    async _loadCsvFileWithEditor(path) {
        console.log(`Loading CSV file with editor: ${path}`);
        
        try {
            // Check if we already have this CSV in cache
            if (this.csvData[path]) {
                // Make the container visible
                const container = document.getElementById('csv-grid-container');
                container.classList.remove('hidden');
                
                // Load data into the editor
                // Add a title to the container
                const title = document.createElement('div');
                title.className = 'csv-grid-title';
                title.innerHTML = `<h3>${path.split('/').pop()}</h3><button class="close-btn"><i class="fas fa-times"></i></button>`;
                
                // Clear previous content
                container.innerHTML = '';
                container.appendChild(title);
                
                // Add close button functionality
                title.querySelector('.close-btn').addEventListener('click', () => {
                    container.classList.add('hidden');
                });
                
                // Create grid container
                const gridContainer = document.createElement('div');
                gridContainer.className = 'csv-grid-wrapper';
                container.appendChild(gridContainer);
                
                // Initialize editor in this container
                this.csvGridEditor = new CSVGridEditor(gridContainer, {
                    editable: true,
                    allowAddRows: true,
                    allowAddColumns: true,
                    maxRows: 10000
                });
                
                // Load data into the editor
                this.csvGridEditor.loadData(this.csvData[path], path);
                return;
            }
            
            // Load the CSV file
            const response = await fetch(path);
            
            if (!response.ok) {
                throw new Error(`Failed to load CSV: ${response.status} ${response.statusText}`);
            }
            
            const text = await response.text();
            
            // Parse the CSV
            const csvData = this._parseCSV(text);
            
            // Cache the data
            this.csvData[path] = csvData;
            
            // Make the container visible
            const container = document.getElementById('csv-grid-container');
            container.classList.remove('hidden');
            
            // Display the CSV in the editor
            this.csvGridEditor.loadData(csvData, path);
        } catch (error) {
            console.error('Error loading CSV file:', error);
            
            // Use sample data as fallback
            const sampleData = this._getSampleCsvData();
            this.csvGridEditor.loadData(sampleData, path);
        }
    }
    
    /**
     * Show details for a specific file
     * @param {Object} file - File object
     * @private
     */
    _showFileDetails(file) {
        console.log('Showing details for file:', file);
        
        // If it's a CSV file, load it into the grid
        if (file.extension === 'csv') {
            this._loadCsvFile(file.path);
        }
    }
    
    /**
     * Load and display a CSV file
     * @param {string} path - Path to the CSV file
     * @private
     */
    async _loadCsvFile(path) {
        console.log(`Loading CSV file: ${path}`);
        
        try {
            // Check if we already have this CSV in cache
            if (this.csvData[path]) {
                this._renderCsvGrid(this.csvData[path], path);
                return;
            }
            
            // Load the CSV file
            const response = await fetch(path);
            
            if (!response.ok) {
                throw new Error(`Failed to load CSV: ${response.status} ${response.statusText}`);
            }
            
            const text = await response.text();
            
            // Parse the CSV
            const csvData = this._parseCSV(text);
            
            // Cache the data
            this.csvData[path] = csvData;
            
            // Display the CSV grid
            this._renderCsvGrid(csvData, path);
        } catch (error) {
            console.error('Error loading CSV file:', error);
            
            // Use sample data as fallback
            const sampleData = this._getSampleCsvData();
            this._renderCsvGrid(sampleData, path);
        }
    }
    
    /**
     * Parse CSV text into structured data
     * @param {string} text - CSV text content
     * @returns {Object} Parsed CSV data
     * @private
     */
    _parseCSV(text) {
        const lines = text.split('\n');
        const headers = lines[0].split(',').map(header => header.trim());
        
        const rows = lines.slice(1).filter(line => line.trim()).map(line => {
            const values = line.split(',');
            const row = {};
            
            headers.forEach((header, index) => {
                row[header] = values[index] ? values[index].trim() : '';
            });
            
            return row;
        });
        
        return { headers, rows };
    }
    
    /**
     * Get sample CSV data for demonstration
     * @returns {Object} Sample CSV data
     * @private
     */
    _getSampleCsvData() {
        const headers = ['id', 'name', 'type', 'date', 'value'];
        const rows = [
            { id: '1', name: 'Item 1', type: 'Type A', date: '2025-01-01', value: '100' },
            { id: '2', name: 'Item 2', type: 'Type B', date: '2025-01-02', value: '200' },
            { id: '3', name: 'Item 3', type: 'Type A', date: '2025-01-03', value: '300' },
            { id: '4', name: 'Item 4', type: 'Type C', date: '2025-01-04', value: '400' },
            { id: '5', name: 'Item 5', type: 'Type B', date: '2025-01-05', value: '500' }
        ];
        
        return { headers, rows };
    }














    
    /**
     * Render a CSV grid view
     * @param {Object} data - CSV data object with headers and rows
     * @param {string} path - Path to the CSV file
     * @private
     */
    _renderCsvGrid(data, path) {
        // Create a modal for the CSV viewer
        const modal = document.createElement('div');
        modal.className = 'genesis-csv-modal';
        modal.style.position = 'fixed';
        modal.style.top = '0';
        modal.style.left = '0';
        modal.style.width = '100%';
        modal.style.height = '100%';
        modal.style.backgroundColor = 'rgba(0, 0, 0, 0.8)';
        modal.style.zIndex = '1000';
        modal.style.display = 'flex';
        modal.style.justifyContent = 'center';
        modal.style.alignItems = 'center';
        
        // Create the CSV viewer container
        const container = document.createElement('div');
        container.className = 'genesis-csv-viewer';
        container.style.width = '90%';
        container.style.height = '90%';
        container.style.backgroundColor = 'var(--genesis-bg-dark)';
        container.style.border = '1px solid var(--genesis-border-color)';
        container.style.borderRadius = '5px';
        container.style.display = 'flex';
        container.style.flexDirection = 'column';
        container.style.overflow = 'hidden';
        
        // Add header
        const header = document.createElement('div');
        header.className = 'genesis-csv-header';
        header.style.padding = '10px';
        header.style.borderBottom = '1px solid var(--genesis-border-color)';
        header.style.display = 'flex';
        header.style.justifyContent = 'space-between';
        header.style.alignItems = 'center';
        
        // Add file name
        const fileName = document.createElement('div');
        fileName.className = 'genesis-csv-filename';
        fileName.textContent = path.split('/').pop();
        fileName.style.fontWeight = 'bold';
        
        // Add close button
        const closeBtn = document.createElement('button');
        closeBtn.className = 'genesis-csv-close';
        closeBtn.innerHTML = '<i class="fas fa-times"></i>';
        closeBtn.style.background = 'transparent';
        closeBtn.style.border = 'none';
        closeBtn.style.color = 'var(--genesis-text-primary)';
        closeBtn.style.cursor = 'pointer';
        closeBtn.style.fontSize = '16px';
        
        closeBtn.addEventListener('click', () => {
            document.body.removeChild(modal);
        });
        
        header.appendChild(fileName);
        header.appendChild(closeBtn);
        
        // Add grid container
        const gridContainer = document.createElement('div');
        gridContainer.className = 'genesis-csv-grid-container';
        gridContainer.style.flex = '1';
        gridContainer.style.overflow = 'auto';
        gridContainer.style.padding = '10px';
        
        // Create CSV grid
        const csvGrid = document.createElement('div');
        csvGrid.className = 'genesis-csv-grid';
        csvGrid.style.width = '100%';
        
        // Add header row
        const headerRow = document.createElement('div');
        headerRow.className = 'genesis-csv-row';
        
        data.headers.forEach(header => {
            const cell = document.createElement('div');
            cell.className = 'genesis-csv-cell genesis-csv-header';
            cell.textContent = header;
            
            // Add click handler for column selection
            cell.addEventListener('click', () => {
                // Toggle selected class
                const isSelected = cell.classList.toggle('selected');
                
                // Enable/disable delete column button
                const deleteColumnBtn = document.getElementById('delete-column-btn');
                if (deleteColumnBtn) {
                    deleteColumnBtn.disabled = !isSelected;
                }
            });
            
            headerRow.appendChild(cell);
        });
        
        csvGrid.appendChild(headerRow);
        
        // Add data rows
        data.rows.forEach(row => {
            const dataRow = document.createElement('div');
            dataRow.className = 'genesis-csv-row';
            
            // Add click handler for row selection
            dataRow.addEventListener('click', (e) => {
                // Only if clicking the row itself, not a cell
                if (e.target === dataRow) {
                    // Toggle selected class
                    const isSelected = dataRow.classList.toggle('selected');
                    
                    // Enable/disable delete row button
                    const deleteRowBtn = document.getElementById('delete-row-btn');
                    if (deleteRowBtn) {
                        deleteRowBtn.disabled = !isSelected;
                    }
                }
            });
            
            data.headers.forEach(header => {
                const cell = document.createElement('div');
                cell.className = 'genesis-csv-cell';
                cell.textContent = row[header] || '';
                
                // Add click handler for cell
                cell.addEventListener('click', () => {
                    this._editCsvCell(cell, row, header);
                });
                
                dataRow.appendChild(cell);
            });
            
            csvGrid.appendChild(dataRow);
        });
        
        gridContainer.appendChild(csvGrid);
        
        // Add toolbar
        const toolbar = document.createElement('div');
        toolbar.className = 'genesis-csv-toolbar';
        toolbar.style.padding = '10px';
        toolbar.style.borderTop = '1px solid var(--genesis-border-color)';
        toolbar.style.display = 'flex';
        toolbar.style.gap = '10px';
        
        // Add buttons with enhanced styling
        const addRowBtn = document.createElement('button');
        addRowBtn.innerHTML = '<i class="fas fa-plus"></i> Add Row';
        addRowBtn.className = 'genesis-btn genesis-btn-secondary';
        addRowBtn.id = 'add-row-btn';
        
        const addColumnBtn = document.createElement('button');
        addColumnBtn.innerHTML = '<i class="fas fa-plus"></i> Add Column';
        addColumnBtn.className = 'genesis-btn genesis-btn-secondary';
        addColumnBtn.id = 'add-column-btn';
        
        const deleteRowBtn = document.createElement('button');
        deleteRowBtn.innerHTML = '<i class="fas fa-minus"></i> Delete Row';
        deleteRowBtn.className = 'genesis-btn genesis-btn-secondary';
        deleteRowBtn.id = 'delete-row-btn';
        deleteRowBtn.disabled = true; // Enable when a row is selected
        
        const deleteColumnBtn = document.createElement('button');
        deleteColumnBtn.innerHTML = '<i class="fas fa-minus"></i> Delete Column';
        deleteColumnBtn.className = 'genesis-btn genesis-btn-secondary';
        deleteColumnBtn.id = 'delete-column-btn';
        deleteColumnBtn.disabled = true; // Enable when a column is selected
        
        const saveBtn = document.createElement('button');
        saveBtn.innerHTML = '<i class="fas fa-save"></i> Save Changes';
        saveBtn.className = 'genesis-btn genesis-btn-primary';
        saveBtn.style.marginLeft = 'auto';
        
        // Add buttons to toolbar
        toolbar.appendChild(addRowBtn);
        toolbar.appendChild(addColumnBtn);
        toolbar.appendChild(deleteRowBtn);
        toolbar.appendChild(deleteColumnBtn);
        toolbar.appendChild(saveBtn);
        
        // Add button handlers
        addRowBtn.addEventListener('click', () => {
            this._addCsvRow(csvGrid, data);
        });
        
        addColumnBtn.addEventListener('click', () => {
            this._addCsvColumn(csvGrid, data);
        });
        
        deleteRowBtn.addEventListener('click', () => {
            this._deleteCsvRow(csvGrid, data);
        });
        
        deleteColumnBtn.addEventListener('click', () => {
            this._deleteCsvColumn(csvGrid, data);
        });
        
        saveBtn.addEventListener('click', () => {
            this._saveCsvChanges(data, path);
        });
        
        // Assemble the modal
        container.appendChild(header);
        container.appendChild(gridContainer);
        container.appendChild(toolbar);
        modal.appendChild(container);
        
        // Add the modal to the document
        document.body.appendChild(modal);
    }
 
    




    /**
     * Add a new row to the CSV data
     * @param {HTMLElement} grid - The CSV grid element
     * @param {Object} data - The CSV data object
     * @private
     */
    _addCsvRow(grid, data) {
        // Create empty row object
        const newRow = {};
        data.headers.forEach(header => {
            newRow[header] = '';
        });
        
        // Add to data
        data.rows.push(newRow);
        
        // Create HTML row
        const dataRow = document.createElement('div');
        dataRow.className = 'genesis-csv-row';
        
        data.headers.forEach(header => {
            const cell = document.createElement('div');
            cell.className = 'genesis-csv-cell';
            cell.textContent = '';
            
            // Add click handler for cell
            cell.addEventListener('click', () => {
                this._editCsvCell(cell, newRow, header);
            });
            
            dataRow.appendChild(cell);
        });
        
        // Add to grid
        grid.appendChild(dataRow);
        
        // Scroll to the new row
        dataRow.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }

    /**
     * Add a new column to the CSV data
     * @param {HTMLElement} grid - The CSV grid element
     * @param {Object} data - The CSV data object
     * @private
     */
    _addCsvColumn(grid, data) {
        // Prompt for column name
        const columnName = prompt('Enter new column name:', '');
        if (!columnName) return;
        
        // Check if column already exists
        if (data.headers.includes(columnName)) {
            alert('Column already exists. Please use a different name.');
            return;
        }
        
        // Add to headers
        data.headers.push(columnName);
        
        // Add empty value to all rows
        data.rows.forEach(row => {
            row[columnName] = '';
        });
        
        // Update the header row
        const headerRow = grid.querySelector('.genesis-csv-row:first-child');
        const headerCell = document.createElement('div');
        headerCell.className = 'genesis-csv-cell genesis-csv-header';
        headerCell.textContent = columnName;
        headerRow.appendChild(headerCell);
        
        // Update all data rows
        const dataRows = grid.querySelectorAll('.genesis-csv-row:not(:first-child)');
        dataRows.forEach((row, index) => {
            const cell = document.createElement('div');
            cell.className = 'genesis-csv-cell';
            cell.textContent = '';
            
            // Add click handler
            cell.addEventListener('click', () => {
                this._editCsvCell(cell, data.rows[index], columnName);
            });
            
            row.appendChild(cell);
        });
    }

    /**
     * Delete a row from the CSV data
     * @param {HTMLElement} grid - The CSV grid element
     * @param {Object} data - The CSV data object
     * @private
     */
    _deleteCsvRow(grid, data) {
        // Find selected row
        const selectedRow = grid.querySelector('.genesis-csv-row.selected');
        if (!selectedRow) {
            alert('Please select a row to delete');
            return;
        }
        
        // Get row index (subtract 1 to account for header row)
        const rows = Array.from(grid.querySelectorAll('.genesis-csv-row'));
        const rowIndex = rows.indexOf(selectedRow) - 1;
        
        if (rowIndex >= 0) {
            // Remove from data
            data.rows.splice(rowIndex, 1);
            
            // Remove from grid
            grid.removeChild(selectedRow);
        }
    }

    /**
     * Delete a column from the CSV data
     * @param {HTMLElement} grid - The CSV grid element
     * @param {Object} data - The CSV data object
     * @private
     */
    _deleteCsvColumn(grid, data) {
        // Find selected column
        const selectedHeader = grid.querySelector('.genesis-csv-header.selected');
        if (!selectedHeader) {
            alert('Please select a column to delete');
            return;
        }
        
        const columnName = selectedHeader.textContent;
        
        // Remove from headers
        const headerIndex = data.headers.indexOf(columnName);
        if (headerIndex !== -1) {
            data.headers.splice(headerIndex, 1);
            
            // Remove property from all rows
            data.rows.forEach(row => {
                delete row[columnName];
            });
            
            // Update all rows in the grid
            const rows = grid.querySelectorAll('.genesis-csv-row');
            rows.forEach(row => {
                // Get the cell at the correct index
                const cells = row.querySelectorAll('.genesis-csv-cell');
                if (cells[headerIndex]) {
                    row.removeChild(cells[headerIndex]);
                }
            });
        }
    }

    /**
     * Save CSV changes
     * @param {Object} data - The CSV data object
     * @param {string} path - Path to the CSV file
     * @private
     */
    _saveCsvChanges(data, path) {
        // Convert data back to CSV string
        let csvContent = data.headers.join(',') + '\n';
        
        data.rows.forEach(row => {
            const rowValues = data.headers.map(header => {
                // Handle values with commas by wrapping in quotes
                const value = row[header] || '';
                if (value.includes(',')) {
                    return `"${value}"`;
                }
                return value;
            });
            
            csvContent += rowValues.join(',') + '\n';
        });
        
        // In a real app, we would send this to the server
        // For now, we'll simulate saving
        console.log('Saving CSV:', csvContent);
        
        // Update cached data
        this.csvData[path] = data;
        
        // Show success message
        const notification = document.createElement('div');
        notification.className = 'genesis-notification';
        notification.innerHTML = '<i class="fas fa-check-circle"></i> Changes saved successfully';
        notification.style.position = 'fixed';
        notification.style.bottom = '20px';
        notification.style.right = '20px';
        notification.style.backgroundColor = 'var(--genesis-accent-green)';
        notification.style.color = 'white';
        notification.style.padding = '10px 15px';
        notification.style.borderRadius = '5px';
        notification.style.boxShadow = '0 2px 8px rgba(0, 0, 0, 0.2)';
        notification.style.zIndex = '1000';
        notification.style.opacity = '0';
        notification.style.transition = 'opacity 0.3s';
        
        document.body.appendChild(notification);
        
        // Fade in
        setTimeout(() => {
            notification.style.opacity = '1';
        }, 100);
        
        // Remove after delay
        setTimeout(() => {
            notification.style.opacity = '0';
            setTimeout(() => {
                document.body.removeChild(notification);
            }, 300);
        }, 3000);
    }


















    /**
     * Edit a CSV cell
     * @param {HTMLElement} cell - Cell element
     * @param {Object} row - Row data
     * @param {string} header - Column header
     * @private
     */
    _editCsvCell(cell, row, header) {
        const currentValue = cell.textContent;
        
        // Create input element
        const input = document.createElement('input');
        input.type = 'text';
        input.value = currentValue;
        input.style.width = '100%';
        input.style.padding = '2px 5px';
        input.style.border = 'none';
        input.style.backgroundColor = 'var(--genesis-bg-light)';
        input.style.color = 'var(--genesis-text-primary)';
        
        // Replace cell content with input
        cell.textContent = '';
        cell.appendChild(input);
        
        // Focus the input
        input.focus();
        
        // Handle input events
        input.addEventListener('blur', () => {
            // Update row data
            row[header] = input.value;
            
            // Update cell content
            cell.textContent = input.value;
        });
        
        input.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                input.blur();
            } else if (e.key === 'Escape') {
                // Revert to original value
                input.value = currentValue;
                input.blur();
            }
        });
    }
    
    /**
     * Start connection creation mode
     * @private
     */
    _startConnectionMode() {
        console.log("➕ Starting connection mode");
        
    // If we have the connection manager, use it
    if (this.connectionManager) {
        // Get the currently selected node/item
        const selectedItem = document.querySelector('.genesis-cell.selected, .genesis-star.selected, .genesis-map-node.selected');
        
        if (selectedItem) {
            const sourceId = selectedItem.dataset.id || selectedItem.dataset.file || selectedItem.dataset.type;
            if (sourceId) {
                this.connectionManager.startConnectionCreation({id: sourceId, name: sourceId});
            } else {
                alert('Please select a valid source item first');
            }
        } else {
            alert('Please select an item to connect from');
        }
    } else {


        // Change cursor and add a class to the container
        document.body.style.cursor = 'crosshair';
        this.elements.container.classList.add('connection-mode');
        
        // Show a modal with instructions
        const instructionsModal = document.createElement('div');
        instructionsModal.className = 'genesis-modal-overlay';
        instructionsModal.innerHTML = `
            <div class="genesis-modal">
                <div class="genesis-modal-header">
                    <h3>Create Connection</h3>
                    <button class="genesis-modal-close"><i class="fas fa-times"></i></button>
                </div>
                <div class="genesis-modal-content">
                    <p>Click on a source item, then click on a target item to create a connection.</p>
                    <p>Press ESC or click Cancel to exit connection mode.</p>
                </div>
                <div class="genesis-modal-footer">
                    <button class="genesis-btn genesis-btn-secondary" id="cancel-connection">Cancel</button>
                </div>
            </div>
        `;
        
        document.body.appendChild(instructionsModal);
        
        // Setup event handlers for the modal
        document.querySelector('.genesis-modal-close').addEventListener('click', () => {
            this._cancelConnectionMode();
        });
        
        document.getElementById('cancel-connection').addEventListener('click', () => {
            this._cancelConnectionMode();
        });
        
        // Handle ESC key
        const escHandler = (e) => {
            if (e.key === 'Escape') {
                this._cancelConnectionMode();
                document.removeEventListener('keydown', escHandler);
            }
        };
        
        document.addEventListener('keydown', escHandler);
        
        // Setup connection state
        this.connectionState = {
            active: true,
            source: null,
            target: null
        };
        
        // Add click handlers for items
        const items = document.querySelectorAll('.genesis-cell, .genesis-star, .genesis-map-node');
        items.forEach(item => {
            item.addEventListener('click', this._handleConnectionItemClick.bind(this));
        });









    }



































    }

    /**
     * Handle clicks on items during connection creation
     * @param {Event} e - Click event
     * @private
     */
    _handleConnectionItemClick(e) {
        if (!this.connectionState || !this.connectionState.active) return;
        
        const item = e.currentTarget;
        
        if (!this.connectionState.source) {
            // First click - set source
            this.connectionState.source = item;
            item.classList.add('connection-source');
            
            // Update instructions
            document.querySelector('.genesis-modal-content').innerHTML = 
                '<p>Now click on a target item to complete the connection.</p>';
        } else {
            // Second click - set target and create connection
            this.connectionState.target = item;
            
            // Create the connection
            const sourceId = item.dataset.id || item.dataset.file || item.dataset.type;
            const targetId = item.dataset.id || item.dataset.file || item.dataset.type;
            
            if (sourceId && targetId && sourceId !== targetId) {
                this.createConnection(sourceId, targetId);
                
                // Show success message
                document.querySelector('.genesis-modal-content').innerHTML = 
                    `<p class="success">Connection created successfully!</p>`;
                
                // Auto-close after a delay
                setTimeout(() => {
                    this._cancelConnectionMode();
                }, 1500);
            } else {
                // Invalid connection
                document.querySelector('.genesis-modal-content').innerHTML = 
                    `<p class="error">Invalid connection. Please try again.</p>`;
                
                // Reset source selection
                this.connectionState.source.classList.remove('connection-source');
                this.connectionState.source = null;
            }
        }
    }

    /**
     * Cancel connection creation mode
     * @private
     */
    _cancelConnectionMode() {
        // Reset cursor and remove class
        document.body.style.cursor = 'default';
        this.elements.container.classList.remove('connection-mode');
        
        // Remove modal
        const modal = document.querySelector('.genesis-modal-overlay');
        if (modal) {
            document.body.removeChild(modal);
        }
        
        // Reset connection state
        if (this.connectionState && this.connectionState.source) {
            this.connectionState.source.classList.remove('connection-source');
        }
        
        this.connectionState = {
            active: false,
            source: null,
            target: null
        };
        
        // Remove click handlers
        const items = document.querySelectorAll('.genesis-cell, .genesis-star, .genesis-map-node');
        items.forEach(item => {
            item.removeEventListener('click', this._handleConnectionItemClick);
        });
    }
    
/**
* Show settings panel
* @private
*/
_showSettings() {
    console.log("⚙️ Showing settings");
 
    
     // If we have the settings manager, use it
     if (this.settingsManager) {
         this.settingsManager.showSettingsPanel();
     } else {
 
 
 
 
 
    
         // Create settings modal
         const settingsModal = document.createElement('div');
         settingsModal.className = 'genesis-modal-overlay';
         settingsModal.innerHTML = `
             <div class="genesis-modal genesis-settings-modal">
                 <div class="genesis-modal-header">
                     <h3>Settings</h3>
                     <button class="genesis-modal-close"><i class="fas fa-times"></i></button>
                 </div>
                 <div class="genesis-modal-content">
                     <div class="genesis-settings-section">
                         <h4>Appearance</h4>
                         <div class="genesis-setting-item">
                             <label for="theme-select">Theme:</label>
                             <select id="theme-select">
                                 <option value="dark" selected>Dark</option>
                                 <option value="light">Light</option>
                             </select>
                         </div>
                         <div class="genesis-setting-item">
                             <label for="font-size">Font Size:</label>
                             <input type="range" id="font-size" min="12" max="20" value="14">
                             <span id="font-size-value">14px</span>
                         </div>
                     </div>
                     
                     <div class="genesis-settings-section">
                         <h4>Visualization</h4>
                         <div class="genesis-setting-item">
                             <label for="default-view">Default View:</label>
                             <select id="default-view">
                                 <option value="grid">Grid View</option>
                                 <option value="galaxy" selected>Galaxy View</option>
                                 <option value="map">Map View</option>
                             </select>
                         </div>
                         <div class="genesis-setting-item">
                             <label for="animation-toggle">Animations:</label>
                             <label class="toggle-switch">
                                 <input type="checkbox" id="animation-toggle" checked>
                                 <span class="toggle-slider"></span>
                             </label>
                         </div>
                     </div>
                     
                     <div class="genesis-settings-section">
                         <h4>System</h4>
                         <div class="genesis-setting-item">
                             <label for="auto-scan">Auto-scan files:</label>
                             <label class="toggle-switch">
                                 <input type="checkbox" id="auto-scan" checked>
                                 <span class="toggle-slider"></span>
                             </label>
                         </div>
                         <div class="genesis-setting-item">
                             <label for="auto-connect">Suggest connections:</label>
                             <label class="toggle-switch">
                                 <input type="checkbox" id="auto-connect" checked>
                                 <span class="toggle-slider"></span>
                             </label>
                         </div>
                     </div>
                 </div>
                 <div class="genesis-modal-footer">
                     <button class="genesis-btn genesis-btn-secondary" id="reset-settings">Reset to Default</button>
                     <button class="genesis-btn genesis-btn-primary" id="save-settings">Save Changes</button>
                 </div>
             </div>
         `;
         
         document.body.appendChild(settingsModal);
         
         // Setup event handlers
         document.querySelector('.genesis-modal-close').addEventListener('click', () => {
             document.body.removeChild(settingsModal);
         });
         
         // Font size slider
         const fontSizeSlider = document.getElementById('font-size');
         const fontSizeValue = document.getElementById('font-size-value');
         
         fontSizeSlider.addEventListener('input', () => {
             fontSizeValue.textContent = `${fontSizeSlider.value}px`;
         });
         
         // Save settings button
         document.getElementById('save-settings').addEventListener('click', () => {
             // Get all settings values
             const theme = document.getElementById('theme-select').value;
             const fontSize = document.getElementById('font-size').value;
             const defaultView = document.getElementById('default-view').value;
             const animations = document.getElementById('animation-toggle').checked;
             const autoScan = document.getElementById('auto-scan').checked;
             const autoConnect = document.getElementById('auto-connect').checked;
             
             // Update config
             this.config.defaultVisualization = defaultView;
             this.config.autoScan = autoScan;
             this.config.autoConnect = autoConnect;
             this.config.animations = animations;
             this.config.theme = theme;
             this.config.fontSize = fontSize;
             
             // Apply theme
             if (theme === 'light') {
                 document.documentElement.style.setProperty('--genesis-bg-dark', '#f5f5f5');
                 document.documentElement.style.setProperty('--genesis-bg-darker', '#e0e0e0');
                 document.documentElement.style.setProperty('--genesis-bg-light', '#ffffff');
                 document.documentElement.style.setProperty('--genesis-text-primary', '#333333');
                 document.documentElement.style.setProperty('--genesis-text-secondary', '#666666');
                 document.documentElement.style.setProperty('--genesis-border-color', '#cccccc');
             } else {
                 document.documentElement.style.setProperty('--genesis-bg-dark', '#1e1e1e');
                 document.documentElement.style.setProperty('--genesis-bg-darker', '#151515');
                 document.documentElement.style.setProperty('--genesis-bg-light', '#252525');
                 document.documentElement.style.setProperty('--genesis-text-primary', '#f0f0f0');
                 document.documentElement.style.setProperty('--genesis-text-secondary', '#a0a0a0');
                 document.documentElement.style.setProperty('--genesis-border-color', '#454545');
             }
             
             // Apply font size
             document.documentElement.style.setProperty('--genesis-font-size', `${fontSize}px`);
             
             // Save settings to localStorage
             localStorage.setItem('genesis-settings', JSON.stringify(this.config));
             
             // Close modal
             document.body.removeChild(settingsModal);
             
             // Refresh visualization
             this.visualize(this.config.defaultVisualization);
         });
         
         // Reset settings button
         document.getElementById('reset-settings').addEventListener('click', () => {
             // Reset to defaults
             document.getElementById('theme-select').value = 'dark';
             document.getElementById('font-size').value = '14';
             document.getElementById('font-size-value').textContent = '14px';
             document.getElementById('default-view').value = 'grid';
             document.getElementById('animation-toggle').checked = true;
             document.getElementById('auto-scan').checked = true;
             document.getElementById('auto-connect').checked = true;
         });
     }
 }
    
    /**
     * Get a formatted file size string
     * @param {number} bytes - Size in bytes
     * @returns {string} Formatted size string
     */
    formatFileSize(bytes) {
        if (bytes === 0) return '0 Bytes';
        
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }
    
    /**
     * Load and display a CSV file from a specific path
     * @param {string} path - Path to the CSV file
     */
    loadCsvFile(path) {
        this._loadCsvFile(path);
    }
    
    /**
     * Create a new connection between files
     * @param {string} source - Source file path
     * @param {string} target - Target file path
     * @param {string} type - Connection type
     */
    createConnection(source, target, type = 'default') {
        if (!this.connections[source]) {
            this.connections[source] = [];
        }
        
        this.connections[source].push({
            target,
            type,
            created: new Date().toISOString()
        });
        
        console.log(`Connection created: ${source} -> ${target} (${type})`);
    }
}

// Create a global instance
window.genesis = new Genesis();

// Initialize the system when the document is ready
document.addEventListener('DOMContentLoaded', function() {
    window.genesis.initialize();
});