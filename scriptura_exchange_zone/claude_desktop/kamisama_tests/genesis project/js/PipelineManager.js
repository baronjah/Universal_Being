/**
 * PipelineManager.js - Manages the flow of data and UI operations across components
 * This acts as the central nervous system connecting different parts of the application
 */

class PipelineManager {
    constructor() {
        // Component references
        this.components = {
            genesis: null,           // Main Genesis system
            csvEditor: null,         // CSV Grid Editor
            settingsManager: null,   // Settings Manager
            connectionManager: null, // Connection Manager
            visualizationEngine: null, // Visualization Engine
            windowManager: null,     // Window Manager
            taskManager: null        // Task Manager for background operations
        };
        
        // Pipeline states
        this.activeView = 'grid';    // Current active view
        this.activeFile = null;      // Current active file
        this.activeWindow = null;    // Current active window
        this.processingTasks = [];   // Currently running tasks
        
        // Event registry
        this.eventHandlers = {};
    }
    
    /**
     * Initialize the pipeline with component references
     * @param {Object} componentRefs - Object containing references to components
     */
    initialize(componentRefs) {
        console.log("🔄 Initializing Pipeline Manager");
        
        // Store component references
        Object.assign(this.components, componentRefs);
        
        // Register cross-component event listeners
        this._registerEventHandlers();
        
        // Initialize the Window Manager to handle multiple windows
        this._initializeWindowManager();
        
        console.log("🔄 Pipeline Manager initialized");
        return this;
    }
    
    /**
     * Register event handlers for cross-component communication
     * @private
     */
    _registerEventHandlers() {
        // Listen for settings changes
        document.addEventListener('settings-settingsApplied', (e) => {
            this.applySettingsToAllComponents(e.detail);
        });
        
        // Listen for file selection
        document.addEventListener('genesis-fileSelected', (e) => {
            this.handleFileSelection(e.detail);
        });
        
        // Listen for view changes
        document.addEventListener('genesis-viewChanged', (e) => {
            this.handleViewChange(e.detail);
        });
        
        // Listen for connection requests
        document.addEventListener('connection-connectionCreated', (e) => {
            this.handleNewConnection(e.detail);
        });
        
        // Listen for window requests
        document.addEventListener('window-openRequest', (e) => {
            this.openWindow(e.detail.type, e.detail.data);
        });
    }
    
    /**
     * Initialize the Window Manager for handling multiple windows
     * @private
     */
    _initializeWindowManager() {
        if (!this.components.windowManager) {
            console.warn("Window Manager not available");
            return;
        }
        
        // Define window types
        const windowTypes = [
            {
                id: 'csv-editor',
                title: 'CSV Editor',
                width: '80%',
                height: '80%',
                component: 'csvEditor',
                resizable: true
            },
            {
                id: 'settings',
                title: 'Settings',
                width: '400px',
                height: '90%',
                component: 'settingsManager',
                position: 'right',
                resizable: false
            },
            {
                id: 'connection-manager',
                title: 'Manage Connections',
                width: '500px',
                height: '400px',
                component: 'connectionManager',
                resizable: true
            },
            {
                id: 'task-manager',
                title: 'Tasks',
                width: '400px',
                height: '300px',
                component: 'taskManager',
                position: 'bottom-right',
                resizable: true
            }
        ];
        
        // Register window types
        windowTypes.forEach(winType => {
            this.components.windowManager.registerWindowType(winType);
        });
    }
    
    /**
     * Apply settings to all components
     * @param {Object} settings - The settings object
     */
    applySettingsToAllComponents(settings) {
        console.log("Applying settings to all components:", settings);
        
        // Apply to each component that has an applySettings method
        Object.values(this.components).forEach(component => {
            if (component && typeof component.applySettings === 'function') {
                component.applySettings(settings);
            }
        });
        
        // Apply CSS variables globally
        this._applyCSSVariables(settings);
    }
    
    /**
     * Apply CSS variables based on settings
     * @param {Object} settings - The settings object
     * @private
     */
    _applyCSSVariables(settings) {
        const theme = settings.theme || 'dark';
        const variables = {
            // Background colors
            '--genesis-bg-dark': theme === 'dark' ? '#1e1e1e' : '#f5f5f5',
            '--genesis-bg-darker': theme === 'dark' ? '#151515' : '#e0e0e0',
            '--genesis-bg-light': theme === 'dark' ? '#252525' : '#ffffff',
            
            // Text colors
            '--genesis-text-primary': theme === 'dark' ? '#f0f0f0' : '#333333',
            '--genesis-text-secondary': theme === 'dark' ? '#a0a0a0' : '#666666',
            
            // Border color
            '--genesis-border-color': theme === 'dark' ? '#454545' : '#cccccc',
            
            // Custom colors
            '--genesis-accent-color': settings.accentColor || '#0078d7',
            '--genesis-text-color': settings.textColor || (theme === 'dark' ? '#f0f0f0' : '#333333'),
            
            // Sizes
            '--genesis-font-size': `${settings.fontSize || 14}px`,
            
            // Additional variables
            '--csv-grid-bg': theme === 'dark' ? '#1e1e1e' : '#ffffff',
            '--csv-grid-header-bg': theme === 'dark' ? '#252525' : '#f0f0f0',
            '--csv-grid-cell-bg': theme === 'dark' ? '#1e1e1e' : '#ffffff'
        };
        
        // Apply all CSS variables
        Object.entries(variables).forEach(([property, value]) => {
            document.documentElement.style.setProperty(property, value);
        });
    }
    
    /**
     * Handle file selection events
     * @param {Object} fileData - Data about the selected file
     */
    handleFileSelection(fileData) {
        console.log("File selected:", fileData);
        this.activeFile = fileData;
        
        // If it's a CSV file, open it in the CSV editor window
        if (fileData.extension === 'csv') {
            this.openWindow('csv-editor', { path: fileData.path });
        }
        // Handle other file types appropriately
        else if (['js', 'html', 'css'].includes(fileData.extension)) {
            // We could implement a code editor here
            console.log(`TODO: Open ${fileData.extension} file in code editor`);
        }
    }
    
    /**
     * Handle view change events
     * @param {Object} viewData - Data about the view change
     */
    handleViewChange(viewData) {
        console.log("View changed:", viewData);
        this.activeView = viewData.view;
        
        // Update any components that need to know about the view change
        if (this.components.visualizationEngine) {
            this.components.visualizationEngine.switchView(viewData.view);
        }
    }
    
    /**
     * Handle new connection creation
     * @param {Object} connectionData - Data about the new connection
     */
    handleNewConnection(connectionData) {
        console.log("New connection created:", connectionData);
        
        // Update visualization if needed
        if (this.components.visualizationEngine) {
            this.components.visualizationEngine.addConnection(connectionData.connection);
        }
        
        // If Genesis has a connections property, update it
        if (this.components.genesis && this.components.genesis.connections) {
            const { sourceId, targetId, type } = connectionData.connection;
            this.components.genesis.createConnection(sourceId, targetId, type);
        }
    }
    
    /**
     * Open a window of the specified type
     * @param {string} windowType - Type of window to open
     * @param {Object} data - Data to pass to the window
     */
    openWindow(windowType, data) {
        if (!this.components.windowManager) {
            console.warn("Window Manager not available");
            return;
        }
        
        // Create a window instance
        const windowInstance = this.components.windowManager.createWindow(windowType, data);
        
        if (windowInstance) {
            this.activeWindow = windowInstance;
            windowInstance.show();
            
            // Pass data to the component inside the window
            if (data) {
                const componentType = windowInstance.config.component;
                const component = this.components[componentType];
                
                if (component) {
                    // If it's a CSV Editor, load the file
                    if (componentType === 'csvEditor' && data.path) {
                        component.loadData(this.components.genesis.csvData[data.path], data.path);
                    }
                    // If it's another component, pass data appropriately
                    else if (typeof component.loadData === 'function') {
                        component.loadData(data);
                    }
                }
            }
        }
    }
    
    /**
     * Run a task in the background
     * @param {Object} taskConfig - Task configuration
     */
    runTask(taskConfig) {
        if (!this.components.taskManager) {
            console.warn("Task Manager not available");
            return null;
        }
        
        const task = this.components.taskManager.createTask(taskConfig);
        this.processingTasks.push(task);
        
        // Start the task
        task.start();
        
        return task;
    }
    
    /**
     * Load a configuration template from a CSV file
     * @param {string} templatePath - Path to the CSV template file
     * @returns {Promise<Object>} The loaded configuration
     */
    async loadConfigTemplate(templatePath) {
        try {
            // Use Genesis to load the CSV file
            if (!this.components.genesis) {
                throw new Error("Genesis component not available");
            }
            
            // If not already loaded, load it
            if (!this.components.genesis.csvData[templatePath]) {
                await this.components.genesis._loadCsvFile(templatePath);
            }
            
            const csvData = this.components.genesis.csvData[templatePath];
            
            // Convert CSV to configuration object
            const config = {};
            csvData.rows.forEach(row => {
                if (row.key && row.value) {
                    // Handle different value types
                    let value = row.value;
                    if (value === 'true') value = true;
                    else if (value === 'false') value = false;
                    else if (!isNaN(value)) value = parseFloat(value);
                    
                    config[row.key] = value;
                }
            });
            
            return config;
        } catch (error) {
            console.error("Error loading config template:", error);
            return null;
        }
    }
}

// Export the class
window.PipelineManager = PipelineManager;