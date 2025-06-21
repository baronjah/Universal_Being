/**
 * Genesis Project - Application Controller
 * 
 * This controller integrates the window management system with the NetSuite
 * mock system and provides core application functionality.
 */
class GenesisAppController {
    constructor() {
        // Core systems
        this.windowManager = null;
        this.netSuiteClient = null;
        this.dataParser = null;
        this.settingsManager = null;
        
        // Application state
        this.state = {
            currentProject: null,
            openFiles: [],
            activeFile: null,
            lastSaved: null,
            theme: 'dark',
            autoRefresh: true,
            consoleHistory: []
        };
        
        // Event listeners
        this.eventListeners = {};
    }
    
    /**
     * Initialize the application
     */
    async initialize() {
        try {
            this.logInfo("Initializing Genesis Application...");
            
            // Initialize settings
            this.settingsManager = new SettingsManager();
            await this.settingsManager.loadSettings();
            
            // Apply initial theme
            this.applyTheme(this.settingsManager.getSetting('theme'));
            
            // Initialize data parser
            this.dataParser = new DataParser();
            
            // Initialize window manager
            this.windowManager = new WindowManager({
                containerId: 'content',
                maxWindows: 10,
                defaultWindows: [] // We'll create them manually
            });
            
            // Initialize NetSuite client
            this.netSuiteClient = new NetSuiteClient();
            
            // Generate sample data if needed
            if (this.settingsManager.getSetting('generateSampleData')) {
                this.generateSampleData();
            }
            
            // Create default windows
            this.createDefaultWindows();
            
            // Set up event listeners
            this.setupEventListeners();
            
            this.logSuccess("Genesis Application initialized successfully");
            this.updateStatusBar("Ready");
        } catch (error) {
            this.logError("Failed to initialize application", error.message);
            this.updateStatusBar("Initialization failed");
        }
    }
    
    /**
     * Create default windows for the application
     */
    createDefaultWindows() {
        // Create explorer window
        const explorerWindow = this.windowManager.createWindow('explorer', {
            title: 'Explorer',
            x: 10,
            y: 10,
            width: 250,
            height: 600
        });
        
        // Create editor window
        const editorWindow = this.windowManager.createWindow('editor', {
            title: 'Editor',
            x: 270,
            y: 10,
            width: 600,
            height: 400
        });
        
        // Create console window
        const consoleWindow = this.windowManager.createWindow('console', {
            title: 'Console',
            x: 270,
            y: 420,
            width: 600,
            height: 190
        });
        
        // Create visualization window
        const visualizationWindow = this.windowManager.createWindow('visualization', {
            title: 'Galaxy Visualization',
            x: 880,
            y: 10,
            width: 600,
            height: 600
        });
        
        // Initialize windows with content
        this.initializeExplorerWindow(explorerWindow);
        this.initializeEditorWindow(editorWindow);
        this.initializeConsoleWindow(consoleWindow);
        this.initializeVisualizationWindow(visualizationWindow);
    }
    
    /**
     * Initialize explorer window with content
     */
    initializeExplorerWindow(windowId) {
        const window = this.windowManager.windows[windowId];
        if (!window) return;
        
        // Get the content element
        const contentEl = window.element.querySelector('.window-content');
        
        // Add refresh button to the explorer toolbar
        const explorerToolbar = contentEl.querySelector('.explorer-toolbar');
        if (explorerToolbar) {
            explorerToolbar.querySelector('.refresh-btn').addEventListener('click', () => {
                this.refreshExplorer();
            });
        }
        
        // Set up file explorer click events
        const fileExplorer = contentEl.querySelector('.file-explorer');
        if (fileExplorer) {
            fileExplorer.addEventListener('click', (e) => {
                const fileEl = e.target.closest('.file');
                const folderEl = e.target.closest('.folder');
                
                if (fileEl) {
                    // Handle file click
                    const fileName = fileEl.textContent.trim();
                    this.openFile(fileName);
                } else if (folderEl) {
                    // Toggle folder expansion
                    const folderContent = folderEl.querySelector('ul');
                    if (folderContent) {
                        folderContent.style.display = folderContent.style.display === 'none' ? 'block' : 'none';
                    }
                }
            });
        }
        
        // Populate with available files
        this.refreshExplorer();
    }
    
    /**
     * Initialize editor window with content
     */
    initializeEditorWindow(windowId) {
        const window = this.windowManager.windows[windowId];
        if (!window) return;
        
        // Set up Ace editor
        const editorElement = window.element.querySelector('.editor');
        if (editorElement) {
            const editor = ace.edit(editorElement.id);
            
            // Apply editor settings
            editor.setTheme(`ace/theme/${this.settingsManager.getSetting('editorSyntaxTheme')}`);
            editor.session.setMode("ace/mode/javascript");
            editor.setFontSize(this.settingsManager.getSetting('editorFontSize'));
            editor.setShowPrintMargin(false);
            editor.renderer.setShowGutter(this.settingsManager.getSetting('editorShowLineNumbers'));
            
            // Add change event listener
            editor.session.on('change', () => {
                // Mark file as modified
                if (this.state.activeFile) {
                    this.markFileModified(this.state.activeFile);
                }
            });
        }
    }
    
    /**
     * Initialize console window with content
     */
    initializeConsoleWindow(windowId) {
        const window = this.windowManager.windows[windowId];
        if (!window) return;
        
        // Get the console element
        const consoleEl = window.element.querySelector('.console');
        
        // Add initial message
        this.logToConsole("Welcome to Genesis Project - NetSuite Galaxy Console", "info");
        this.logToConsole("Type 'help' for available commands", "info");
    }
    
    /**
     * Initialize visualization window with content
     */
    initializeVisualizationWindow(windowId) {
        const window = this.windowManager.windows[windowId];
        if (!window) return;
        
        // Get the canvas element
        const canvasEl = window.element.querySelector('canvas');
        if (!canvasEl) return;
        
        // Make sure the canvas fills the container
        const resizeCanvas = () => {
            const content = window.element.querySelector('.window-content');
            if (content) {
                canvasEl.width = content.clientWidth;
                canvasEl.height = content.clientHeight;
                
                // Redraw visualization
                this.renderVisualization(canvasEl);
            }
        };
        
        // Set initial size
        resizeCanvas();
        
        // Add resize event listener to window
        window.element.addEventListener('resize', resizeCanvas);
        
        // Add interaction events
        this.setupVisualizationEvents(canvasEl, windowId);
    }
    
    /**
     * Set up visualization interaction events
     */
    setupVisualizationEvents(canvasEl, windowId) {
        // Store visualization state
        this.state.visualization = {
            zoom: 1,
            panX: 0,
            panY: 0,
            isDragging: false,
            lastX: 0,
            lastY: 0,
            hoveredNode: null
        };
        
        // Add mouse events
        canvasEl.addEventListener('mousedown', (e) => {
            this.state.visualization.isDragging = true;
            this.state.visualization.lastX = e.clientX;
            this.state.visualization.lastY = e.clientY;
            canvasEl.style.cursor = 'grabbing';
        });
        
        canvasEl.addEventListener('mousemove', (e) => {
            const rect = canvasEl.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            
            if (this.state.visualization.isDragging) {
                // Pan the view
                const deltaX = e.clientX - this.state.visualization.lastX;
                const deltaY = e.clientY - this.state.visualization.lastY;
                
                this.state.visualization.panX += deltaX / this.state.visualization.zoom;
                this.state.visualization.panY += deltaY / this.state.visualization.zoom;
                
                this.state.visualization.lastX = e.clientX;
                this.state.visualization.lastY = e.clientY;
                
                // Redraw
                this.renderVisualization(canvasEl);
            } else {
                // Check for node hover
                const nodeUnderCursor = this.findNodeAt(x, y);
                
                if (nodeUnderCursor !== this.state.visualization.hoveredNode) {
                    this.state.visualization.hoveredNode = nodeUnderCursor;
                    canvasEl.style.cursor = nodeUnderCursor ? 'pointer' : 'default';
                    
                    // Update tooltip
                    this.updateNodeTooltip(nodeUnderCursor, x, y, windowId);
                    
                    // Redraw with highlight
                    this.renderVisualization(canvasEl);
                }
            }
        });
        
        canvasEl.addEventListener('mouseup', () => {
            this.state.visualization.isDragging = false;
            canvasEl.style.cursor = 'default';
        });
        
        canvasEl.addEventListener('mouseleave', () => {
            this.state.visualization.isDragging = false;
            
            // Hide tooltip
            this.hideNodeTooltip();
        });
        
        canvasEl.addEventListener('wheel', (e) => {
            e.preventDefault();
            
            // Zoom in/out
            const zoomFactor = e.deltaY > 0 ? 0.9 : 1.1;
            this.state.visualization.zoom *= zoomFactor;
            
            // Limit zoom
            this.state.visualization.zoom = Math.max(0.1, Math.min(5, this.state.visualization.zoom));
            
            // Redraw
            this.renderVisualization(canvasEl);
        });
        
        canvasEl.addEventListener('click', (e) => {
            const rect = canvasEl.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            
            // Check if clicked on a node
            const node = this.findNodeAt(x, y);
            if (node) {
                this.handleNodeClick(node);
            }
        });
        
        // Initial rendering
        this.renderVisualization(canvasEl);
    }
    
    /**
     * Find a node at the given coordinates
     */
    findNodeAt(x, y) {
        if (!this.state.visualizationData) return null;
        
        for (const node of this.state.visualizationData) {
            const distance = Math.sqrt(
                Math.pow(x - (node.x * this.state.visualization.zoom + this.state.visualization.panX), 2) + 
                Math.pow(y - (node.y * this.state.visualization.zoom + this.state.visualization.panY), 2)
            );
            
            if (distance < 15) {
                return node;
            }
        }
        
        return null;
    }
    
    /**
     * Update the node tooltip
     */
    updateNodeTooltip(node, x, y, windowId) {
        if (!node) {
            this.hideNodeTooltip();
            return;
        }
        
        // Create tooltip if it doesn't exist
        let tooltip = document.getElementById('node-tooltip');
        if (!tooltip) {
            tooltip = document.createElement('div');
            tooltip.id = 'node-tooltip';
            tooltip.className = 'node-tooltip';
            document.body.appendChild(tooltip);
        }
        
        // Update tooltip content
        let content = `<h4>${node.name}</h4>`;
        content += `<p>Type: ${node.type}</p>`;
        
        if (node.data) {
            for (const [key, value] of Object.entries(node.data)) {
                content += `<p>${key}: ${value}</p>`;
            }
        }
        
        tooltip.innerHTML = content;
        
        // Position tooltip relative to the cursor
        const window = this.windowManager.windows[windowId];
        const windowRect = window.element.getBoundingClientRect();
        
        tooltip.style.left = `${windowRect.left + x + 10}px`;
        tooltip.style.top = `${windowRect.top + y + 10}px`;
        tooltip.style.display = 'block';
    }
    
    /**
     * Hide the node tooltip
     */
    hideNodeTooltip() {
        const tooltip = document.getElementById('node-tooltip');
        if (tooltip) {
            tooltip.style.display = 'none';
        }
    }
    
    /**
     * Handle node click
     */
    handleNodeClick(node) {
        this.logInfo(`Clicked on node: ${node.name}`);
        
        // Open the node in the appropriate editor
        if (node.type === 'file') {
            this.openFile(node.name);
        } else if (node.type === 'record') {
            this.openRecordViewer(node);
        }
    }
    
    /**
     * Render the visualization
     */
    renderVisualization(canvas) {
        const ctx = canvas.getContext('2d');
        if (!ctx) return;
        
        // Clear canvas
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        
        // Draw background
        ctx.fillStyle = '#0c0c1e';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        
        // Create visualization data if it doesn't exist
        if (!this.state.visualizationData) {
            this.state.visualizationData = this.generateVisualizationData();
        }
        
        // Draw background stars
        this.drawBackgroundStars(ctx, canvas.width, canvas.height);
        
        // Draw the galaxy core
        this.drawGalaxyCore(ctx, canvas.width / 2, canvas.height / 2);
        
        // Draw data nodes
        this.drawDataNodes(ctx);
    }
    
    /**
     * Draw background stars
     */
    drawBackgroundStars(ctx, width, height) {
        // Create stars if they don't exist
        if (!this.state.backgroundStars) {
            this.state.backgroundStars = [];
            
            for (let i = 0; i < 200; i++) {
                this.state.backgroundStars.push({
                    x: Math.random() * width,
                    y: Math.random() * height,
                    size: Math.random() * 1.5,
                    opacity: Math.random() * 0.8 + 0.2
                });
            }
        }
        
        // Draw stars
        for (const star of this.state.backgroundStars) {
            ctx.fillStyle = `rgba(255, 255, 255, ${star.opacity})`;
            ctx.beginPath();
            ctx.arc(star.x, star.y, star.size, 0, Math.PI * 2);
            ctx.fill();
        }
    }
    
    /**
     * Draw the galaxy core
     */
    drawGalaxyCore(ctx, x, y) {
        // Apply transformation
        const transformedX = x + this.state.visualization.panX;
        const transformedY = y + this.state.visualization.panY;
        
        // Draw galaxy core
        const gradient = ctx.createRadialGradient(
            transformedX, transformedY, 10, 
            transformedX, transformedY, 70 * this.state.visualization.zoom
        );
        
        gradient.addColorStop(0, 'rgba(255, 255, 200, 0.8)');
        gradient.addColorStop(1, 'rgba(255, 255, 200, 0)');
        
        ctx.fillStyle = gradient;
        ctx.beginPath();
        ctx.arc(transformedX, transformedY, 70 * this.state.visualization.zoom, 0, Math.PI * 2);
        ctx.fill();
    }
    
    /**
     * Draw data nodes
     */
    drawDataNodes(ctx) {
        if (!this.state.visualizationData) return;
        
        for (const node of this.state.visualizationData) {
            // Apply zoom and pan
            const x = node.x * this.state.visualization.zoom + this.state.visualization.panX;
            const y = node.y * this.state.visualization.zoom + this.state.visualization.panY;
            
            // Get color for the node
            const color = this.getSpectrumColor(node.value);
            
            // Check if node is hovered
            const isHovered = node === this.state.visualization.hoveredNode;
            
            // Draw the node
            this.drawDataNode(ctx, x, y, node, color, isHovered);
        }
    }
    
    /**
     * Draw a data node
     */
    drawDataNode(ctx, x, y, node, color, isHovered) {
        // Determine node size based on zoom and hover state
        const baseSize = 20 * this.state.visualization.zoom;
        const nodeSize = isHovered ? baseSize * 1.3 : baseSize;
        
        // Draw node glow
        const gradient = ctx.createRadialGradient(x, y, 2, x, y, nodeSize);
        gradient.addColorStop(0, `rgba(${Math.round(color.r * 255)}, ${Math.round(color.g * 255)}, ${Math.round(color.b * 255)}, 0.8)`);
        gradient.addColorStop(1, `rgba(${Math.round(color.r * 255)}, ${Math.round(color.g * 255)}, ${Math.round(color.b * 255)}, 0)`);
        
        ctx.fillStyle = gradient;
        ctx.beginPath();
        ctx.arc(x, y, nodeSize, 0, Math.PI * 2);
        ctx.fill();
        
        // Draw node center
        const centerSize = isHovered ? 5 : 3;
        ctx.fillStyle = `rgb(${Math.round(color.r * 255)}, ${Math.round(color.g * 255)}, ${Math.round(color.b * 255)})`;
        ctx.beginPath();
        ctx.arc(x, y, centerSize, 0, Math.PI * 2);
        ctx.fill();
        
        // Draw label
        ctx.fillStyle = isHovered ? '#ffffff' : '#cccccc';
        ctx.font = isHovered ? 'bold 12px Consolas' : '10px Consolas';
        ctx.fillText(node.name, x + 15, y + 5);
        
        // Save node position for interaction
        node.screenX = x;
        node.screenY = y;
    }
    
    /**
     * Generate visualization data
     */
    generateVisualizationData() {
        const nodes = [];
        const types = ['file', 'folder', 'script', 'record', 'item', 'customer', 'vendor'];
        
        // Generate nodes in a spiral pattern
        const centerX = 400;
        const centerY = 300;
        
        for (let i = 0; i < 40; i++) {
            const angle = i * 0.35;
            const distance = 20 + i * 8;
            const x = centerX + Math.cos(angle) * distance;
            const y = centerY + Math.sin(angle) * distance;
            
            const type = types[i % types.length];
            const value = Math.random(); // 0-1 value for color
            
            nodes.push({
                id: 1000 + i,
                name: `${type.charAt(0).toUpperCase() + type.slice(1)} ${1000 + i}`,
                type,
                value,
                x, y,
                data: {
                    size: Math.floor(Math.random() * 1000),
                    lines: Math.floor(Math.random() * 500),
                    modified: new Date().toISOString().split('T')[0]
                }
            });
        }
        
        return nodes;
    }
    
    /**
     * Generate sample data for testing
     */
    generateSampleData() {
        // Use the sample data generator
        const generator = new SampleDataGenerator();
        const data = generator.generateCompleteSampleData({
            numItems: 20,
            numCustomers: 10,
            numVendors: 5,
            numTransactions: 15
        });
        
        // Add to NetSuite client
        this.netSuiteClient.loadSampleData(data);
        
        // Generate kit data
        const kitData = generator.generateKitAnalysisData(15, 40);
        
        // Load the kit data into sample files
        const kitCsv = generator.convertToCSV(kitData.kitItems);
        const componentCsv = generator.convertToCSV(kitData.componentItems);
        
        // Add sample files
        this.state.files = {
            'sample_kit_items.csv': kitCsv,
            'sample_component_items.csv': componentCsv,
            'test_script.js': this.getDefaultScript()
        };
        
        this.logInfo("Sample data generated successfully");
    }
    
    /**
     * Get a default script for testing
     */
    getDefaultScript() {
        return `/**
 * NetSuite Test Script
 * 
 * @NApiVersion 2.1
 * @NScriptType Suitelet
 */
define(['N/search', 'N/log'], function(search, log) {
    
    function onRequest(context) {
        log.debug('Script started', 'Processing request');
        
        // Create a simple search
        var itemSearch = search.create({
            type: search.Type.ITEM,
            filters: [
                ['isinactive', 'is', 'F']
            ],
            columns: [
                'itemid',
                'displayname'
            ]
        });
        
        // Run the search and process results
        var results = itemSearch.run().getRange(0, 10);
        log.audit('Search complete', 'Found ' + results.length + ' items');
        
        // Return the results
        return results;
    }
    
    return {
        onRequest: onRequest
    };
});`;
    }
    
    /**
     * Set up application event listeners
     */
    setupEventListeners() {
        // Toolbar buttons
        document.getElementById('run-button')?.addEventListener('click', () => {
            this.runCurrentScript();
        });
        
        document.getElementById('save-button')?.addEventListener('click', () => {
            this.saveCurrentFile();
        });
        
        document.getElementById('new-button')?.addEventListener('click', () => {
            this.windowManager.showWindowTypeSelector();
        });
        
        document.getElementById('theme-toggle')?.addEventListener('click', () => {
            this.toggleTheme();
        });
        
        // Window manager events
        this.windowManager.addEventListener('windowCreated', (windowId, type) => {
            this.logInfo(`Window created: ${type} (${windowId})`);
        });
        
        this.windowManager.addEventListener('windowClosed', (windowId, type) => {
            this.logInfo(`Window closed: ${type} (${windowId})`);
        });
        
        // Settings events
        this.settingsManager.addEventListener('settingChanged', (key, value) => {
            if (key === 'theme') {
                this.applyTheme(value);
            }
        });
    }
    
    /**
     * Toggle between light and dark themes
     */
    toggleTheme() {
        const currentTheme = this.settingsManager.getSetting('theme');
        const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
        
        this.settingsManager.setSetting('theme', newTheme);
        this.applyTheme(newTheme);
    }
    
    /**
     * Apply a theme
     */
    applyTheme(theme) {
        if (theme === 'light') {
            document.body.classList.add('light-theme');
        } else {
            document.body.classList.remove('light-theme');
        }
        
        // Update state
        this.state.theme = theme;
        
        // Update icon
        const themeToggle = document.getElementById('theme-toggle');
        if (themeToggle) {
            const icon = themeToggle.querySelector('i');
            if (icon) {
                icon.className = theme === 'light' ? 'fas fa-moon' : 'fas fa-sun';
            }
        }
        
        this.logInfo(`Theme switched to ${theme}`);
    }
    
    /**
     * Run the current script
     */
    runCurrentScript() {
        // Check if there's an active file
        if (!this.state.activeFile) {
            this.logWarning("No script selected to run");
            return;
        }
        
        // Get the script content
        const editorWindow = this.findWindowByType('editor');
        if (!editorWindow) {
            this.logError("No editor window found");
            return;
        }
        
        const editorElement = editorWindow.element.querySelector('.editor');
        if (!editorElement) {
            this.logError("No editor element found");
            return;
        }
        
        const editor = ace.edit(editorElement.id);
        const scriptContent = editor.getValue();
        
        // Execute the script
        this.logInfo("Running script...");
        this.updateStatusBar("Running script...");
        
        try {
            // Execute the script using the NetSuite client
            const result = this.netSuiteClient.executeScript(scriptContent, {
                entryPoint: 'onRequest',
                context: {}
            });
            
            // Log the result
            this.logSuccess("Script executed successfully");
            this.logToConsole(JSON.stringify(result, null, 2), 'info');
            
            // Update visualization with the result
            this.updateVisualizationWithResult(result);
            
            this.updateStatusBar("Script executed successfully");
        } catch (error) {
            this.logError("Script execution failed", error.message);
            this.updateStatusBar("Script execution failed");
        }
    }
    
    /**
     * Update visualization with script result
     */
    updateVisualizationWithResult(result) {
        // Check if result is an array
        if (!Array.isArray(result)) {
            this.logWarning("Script result is not an array, cannot visualize");
            return;
        }
        
        // Generate visualization data from result
        const nodes = [];
        const centerX = 400;
        const centerY = 300;
        
        result.forEach((item, index) => {
            const angle = index * 0.35;
            const distance = 20 + index * 8;
            const x = centerX + Math.cos(angle) * distance;
            const y = centerY + Math.sin(angle) * distance;
            
            // Determine item type
            let type = 'unknown';
            if (item.recordType) {
                type = item.recordType;
            } else if (typeof item === 'object') {
                type = 'record';
            }
            
            // Get a value for color
            let value = index / result.length;
            
            nodes.push({
                id: typeof item.id !== 'undefined' ? item.id : index,
                name: typeof item.id !== 'undefined' ? `${type} ${item.id}` : `Result ${index + 1}`,
                type,
                value,
                x, y,
                data: item
            });
        });
        
        // Update visualization data
        this.state.visualizationData = nodes;
        
        // Redraw visualization
        const visualizationWindow = this.findWindowByType('visualization');
        if (visualizationWindow) {
            const canvas = visualizationWindow.element.querySelector('canvas');
            if (canvas) {
                this.renderVisualization(canvas);
            }
        }
    }
    
    /**
     * Save the current file
     */
    saveCurrentFile() {
        if (!this.state.activeFile) {
            this.logWarning("No file selected to save");
            return;
        }
        
        // Get the file content
        const editorWindow = this.findWindowByType('editor');
        if (!editorWindow) {
            this.logError("No editor window found");
            return;
        }
        
        const editorElement = editorWindow.element.querySelector('.editor');
        if (!editorElement) {
            this.logError("No editor element found");
            return;
        }
        
        const editor = ace.edit(editorElement.id);
        const fileContent = editor.getValue();
        
        // Save the file
        this.state.files[this.state.activeFile] = fileContent;
        this.state.lastSaved = new Date();
        
        // Update window title
        editorWindow.element.querySelector('.window-title').textContent = `Editor - ${this.state.activeFile}`;
        
        this.logSuccess(`File saved: ${this.state.activeFile}`);
        this.updateStatusBar(`File saved: ${this.state.activeFile}`);
    }
    
    /**
     * Open a file in the editor
     */
    openFile(fileName) {
        // Check if file exists
        if (!this.state.files || !this.state.files[fileName]) {
            this.logWarning(`File not found: ${fileName}`);
            return;
        }
        
        // Get the file content
        const fileContent = this.state.files[fileName];
        
        // Find an editor window
        const editorWindow = this.findWindowByType('editor');
        if (!editorWindow) {
            this.logWarning("No editor window found, creating one");
            
            // Create a new editor window
            const windowId = this.windowManager.createWindow('editor', {
                title: `Editor - ${fileName}`,
                x: 270,
                y: 10,
                width: 600,
                height: 400
            });
            
            // Initialize the editor
            this.initializeEditorWindow(windowId);
            
            // Wait for editor to initialize
            setTimeout(() => {
                this.setEditorContent(windowId, fileName, fileContent);
            }, 100);
            
            return;
        }
        
        // Set the editor content
        this.setEditorContent(editorWindow.id, fileName, fileContent);
    }
    
    /**
     * Set editor content and update state
     */
    setEditorContent(windowId, fileName, content) {
        const window = this.windowManager.windows[windowId];
        if (!window) return;
        
        // Update window title
        window.element.querySelector('.window-title').textContent = `Editor - ${fileName}`;
        
        // Get the editor element
        const editorElement = window.element.querySelector('.editor');
        if (!editorElement) return;
        
        // Set the content
        const editor = ace.edit(editorElement.id);
        
        // Determine file type and set mode
        const fileExtension = fileName.split('.').pop().toLowerCase();
        let mode = "ace/mode/text";
        
        switch (fileExtension) {
            case 'js':
                mode = "ace/mode/javascript";
                break;
            case 'html':
                mode = "ace/mode/html";
                break;
            case 'css':
                mode = "ace/mode/css";
                break;
            case 'json':
                mode = "ace/mode/json";
                break;
            case 'csv':
                mode = "ace/mode/text";
                break;
            default:
                mode = "ace/mode/text";
        }
        
        editor.session.setMode(mode);
        editor.setValue(content, -1); // Move cursor to start
        
        // Update state
        this.state.activeFile = fileName;
        if (!this.state.openFiles.includes(fileName)) {
            this.state.openFiles.push(fileName);
        }
        
        this.logInfo(`File opened: ${fileName}`);
        this.updateStatusBar(`Editing: ${fileName}`);
    }
    
    /**
     * Mark a file as modified
     */
    markFileModified(fileName) {
        const editorWindow = this.findWindowByType('editor');
        if (!editorWindow) return;
        
        // Update window title with asterisk
        const titleEl = editorWindow.element.querySelector('.window-title');
        if (titleEl && !titleEl.textContent.includes('*')) {
            titleEl.textContent = `${titleEl.textContent} *`;
        }
    }
    
    /**
     * Refresh the explorer window
     */
    refreshExplorer() {
        const explorerWindow = this.findWindowByType('explorer');
        if (!explorerWindow) return;
        
        // Get the file explorer element
        const explorerEl = explorerWindow.element.querySelector('.file-explorer');
        if (!explorerEl) return;
        
        // Clear existing content
        explorerEl.innerHTML = '';
        
        // Create file structure
        const structure = this.buildFileStructure();
        
        // Build the HTML
        for (const [folderName, folderContent] of Object.entries(structure)) {
            const folderEl = document.createElement('li');
            folderEl.className = 'folder';
            folderEl.innerHTML = `<i class="fas fa-folder"></i> ${folderName}`;
            
            // Create subfolder list
            const listEl = document.createElement('ul');
            
            // Add files
            folderContent.forEach(file => {
                const fileEl = document.createElement('li');
                fileEl.className = 'file';
                
                // Determine icon based on file extension
                let iconClass = 'fa-file';
                const ext = file.split('.').pop().toLowerCase();
                
                switch (ext) {
                    case 'js':
                        iconClass = 'fa-file-code';
                        break;
                    case 'csv':
                        iconClass = 'fa-file-csv';
                        break;
                    case 'json':
                        iconClass = 'fa-file-code';
                        break;
                    case 'html':
                        iconClass = 'fa-file-code';
                        break;
                }
                
                fileEl.innerHTML = `<i class="fas ${iconClass}"></i> ${file}`;
                listEl.appendChild(fileEl);
            });
            
            folderEl.appendChild(listEl);
            explorerEl.appendChild(folderEl);
        }
    }
    
    /**
     * Build a file structure for the explorer
     */
    buildFileStructure() {
        const structure = {
            'NetSuite Scripts': [],
            'Sample Data': [],
            'Analysis Results': []
        };
        
        // Categorize files
        if (this.state.files) {
            for (const [fileName, content] of Object.entries(this.state.files)) {
                if (fileName.endsWith('.js')) {
                    structure['NetSuite Scripts'].push(fileName);
                } else if (fileName.includes('sample') || fileName.includes('test')) {
                    structure['Sample Data'].push(fileName);
                } else {
                    structure['Analysis Results'].push(fileName);
                }
            }
        }
        
        return structure;
    }
    
    /**
     * Find a window by its type
     */
    findWindowByType(type) {
        for (const windowId in this.windowManager.windows) {
            const window = this.windowManager.windows[windowId];
            if (window.type === type) {
                return window;
            }
        }
        return null;
    }
    
    /**
     * Get a spectrum color based on value
     */
    getSpectrumColor(value) {
        // Ensure value is between 0 and 1
        value = Math.max(0, Math.min(1, value));
        
        // Map 0-1 to our color points
        const colorIndex = value * 10;  // 10 segments for 11 colors
        const colors = [
            {r: 0.0, g: 0.0, b: 0.0},      // 1. Black
            {r: 1.0, g: 1.0, b: 1.0},      // 2. White
            {r: 0.0, g: 0.0, b: 0.0},      // 3. Black
            {r: 0.45, g: 0.25, b: 0.0},    // 4. Brown
            {r: 1.0, g: 0.0, b: 0.0},      // 5. Red
            {r: 1.0, g: 0.5, b: 0.0},      // 6. Orange
            {r: 1.0, g: 1.0, b: 0.0},      // 7. Yellow
            {r: 1.0, g: 1.0, b: 1.0},      // 8. White
            {r: 0.0, g: 1.0, b: 0.0},      // 9. Green
            {r: 0.0, g: 0.0, b: 1.0},      // 10. Blue
            {r: 0.5, g: 0.0, b: 0.5}       // 11. Purple
        ];
        
        const lowerIndex = Math.floor(colorIndex);
        const upperIndex = Math.ceil(colorIndex);
        const t = colorIndex - lowerIndex;
        
        const lowerColor = colors[lowerIndex];
        const upperColor = colors[Math.min(upperIndex, 10)];
        
        // Lerp between colors
        return {
            r: lowerColor.r + (upperColor.r - lowerColor.r) * t,
            g: lowerColor.g + (upperColor.g - lowerColor.g) * t,
            b: lowerColor.b + (upperColor.b - lowerColor.b) * t
        };
    }
    
    /**
     * Update the status bar with a message
     */
    updateStatusBar(message) {
        const statusBar = document.getElementById('status-bar');
        if (statusBar) {
            statusBar.textContent = `${message} | NetSuite Galaxy Console v0.2 | ${new Date().toLocaleTimeString()}`;
        }
    }
    
    /**
     * Log a message to the console
     */
    logToConsole(message, type = '') {
        // Add to console history
        this.state.consoleHistory.push({
            message,
            type,
            timestamp: new Date()
        });
        
        // Find all console windows
        for (const windowId in this.windowManager.windows) {
            const window = this.windowManager.windows[windowId];
            if (window.type === 'console') {
                const consoleEl = window.element.querySelector('.console');
                if (consoleEl) {
                    const line = document.createElement('div');
                    line.className = 'console-line';
                    
                    const prompt = document.createElement('span');
                    prompt.className = 'console-prompt';
                    prompt.textContent = '>';
                    
                    const content = document.createElement('span');
                    content.className = type ? `console-${type}` : '';
                    content.textContent = message;
                    
                    line.appendChild(prompt);
                    line.appendChild(content);
                    consoleEl.appendChild(line);
                    
                    // Auto-scroll to bottom
                    consoleEl.scrollTop = consoleEl.scrollHeight;
                }
            }
        }
    }
    
    // Logging shortcuts
    logInfo(message) {
        this.logToConsole(message, 'info');
        console.info(message);
    }
    
    logSuccess(message) {
        this.logToConsole(message, 'success');
        console.log(message);
    }
    
    logWarning(message) {
        this.logToConsole(message, 'warning');
        console.warn(message);
    }
    
    logError(message, error = '') {
        const errorMsg = error ? `${message}: ${error}` : message;
        this.logToConsole(errorMsg, 'error');
        console.error(errorMsg);
    }
}

// Initialize the application when the DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.genesisApp = new GenesisAppController();
    window.genesisApp.initialize();
});