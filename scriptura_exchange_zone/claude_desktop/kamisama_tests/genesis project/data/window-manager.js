/**
 * Window Manager System for Genesis Project
 * 
 * Provides functionality for creating, managing, and arranging windows
 * with support for layers, minimizing, maximizing, and closing.
 */
class WindowManager {
    constructor(options = {}) {
        // Default options
        this.options = {
            containerId: 'content',
            maxWindows: 10,
            defaultWindows: ['explorer', 'editor', 'console', 'visualization'],
            ...options
        };
        
        // Window storage
        this.windows = {};
        this.layers = [];
        this.activeWindow = null;
        this.activeLayer = 0;
        this.windowCounter = 0;
        
        // DOM elements
        this.container = document.getElementById(this.options.containerId);
        if (!this.container) {
            throw new Error(`Container element with ID "${this.options.containerId}" not found`);
        }
        
        // Create layer controls
        this.createLayerControls();
        
        // Initialize the default windows if specified
        if (this.options.defaultWindows && this.options.defaultWindows.length > 0) {
            this.initializeDefaultWindows();
        }
        
        // Event listeners for window management
        this.eventListeners = {};
    }
    
    /**
     * Create layer controls at the bottom of the screen
     */
    createLayerControls() {
        // Create layer bar at the bottom
        this.layerBar = document.createElement('div');
        this.layerBar.className = 'layer-bar';
        this.layerBar.innerHTML = `
            <div class="layer-controls">
                <button class="layer-add" title="Add Layer"><i class="fas fa-plus"></i></button>
                <div class="layer-tabs"></div>
            </div>
        `;
        document.body.insertBefore(this.layerBar, document.getElementById('status-bar'));
        
        // Add event listeners
        this.layerBar.querySelector('.layer-add').addEventListener('click', () => this.addLayer());
        
        // Create initial layer
        this.addLayer();
    }
    
    /**
     * Add a new layer
     */
    addLayer() {
        const layerId = this.layers.length;
        const layerDiv = document.createElement('div');
        layerDiv.className = 'layer';
        layerDiv.dataset.layerId = layerId;
        layerDiv.style.zIndex = layerId;
        
        // Hide all layers except the new one
        const existingLayers = this.container.querySelectorAll('.layer');
        existingLayers.forEach(layer => layer.classList.add('hidden'));
        
        this.container.appendChild(layerDiv);
        this.layers.push({
            id: layerId,
            element: layerDiv,
            windows: []
        });
        
        // Create layer tab
        this.createLayerTab(layerId);
        
        // Set as active layer
        this.setActiveLayer(layerId);
        
        // Trigger event
        this.triggerEvent('layerAdded', layerId);
        
        return layerId;
    }
    
    /**
     * Create a tab for the layer in the layer bar
     */
    createLayerTab(layerId) {
        const layerTabs = this.layerBar.querySelector('.layer-tabs');
        const tab = document.createElement('div');
        tab.className = 'layer-tab';
        tab.dataset.layerId = layerId;
        
        // Get a color for the layer based on its ID
        const color = this.getSpectrumColor(layerId / 10);
        const rgbColor = `rgb(${Math.round(color.r * 255)}, ${Math.round(color.g * 255)}, ${Math.round(color.b * 255)})`;
        
        tab.innerHTML = `
            <div class="layer-color" style="background-color: ${rgbColor}"></div>
            <div class="layer-name">Layer ${layerId + 1}</div>
            <div class="layer-actions">
                <button class="layer-visibility" title="Toggle Visibility"><i class="fas fa-eye"></i></button>
                <button class="layer-delete" title="Delete Layer"><i class="fas fa-times"></i></button>
            </div>
        `;
        
        // Add event listeners
        tab.addEventListener('click', (e) => {
            if (!e.target.closest('.layer-actions')) {
                this.setActiveLayer(layerId);
            }
        });
        
        tab.querySelector('.layer-visibility').addEventListener('click', (e) => {
            e.stopPropagation();
            this.toggleLayerVisibility(layerId);
        });
        
        tab.querySelector('.layer-delete').addEventListener('click', (e) => {
            e.stopPropagation();
            this.deleteLayer(layerId);
        });
        
        layerTabs.appendChild(tab);
    }
    
    /**
     * Set the active layer
     */
    setActiveLayer(layerId) {
        // Update active layer
        this.activeLayer = layerId;
        
        // Update layer tabs
        const tabs = this.layerBar.querySelectorAll('.layer-tab');
        tabs.forEach(tab => {
            if (parseInt(tab.dataset.layerId) === layerId) {
                tab.classList.add('active');
            } else {
                tab.classList.remove('active');
            }
        });
        
        // Show active layer, hide others
        const layers = this.container.querySelectorAll('.layer');
        layers.forEach(layer => {
            if (parseInt(layer.dataset.layerId) === layerId) {
                layer.classList.remove('hidden');
            } else {
                layer.classList.add('hidden');
            }
        });
        
        // Trigger event
        this.triggerEvent('layerActivated', layerId);
    }
    
    /**
     * Toggle layer visibility
     */
    toggleLayerVisibility(layerId) {
        const layer = this.layers.find(l => l.id === layerId);
        if (!layer) return;
        
        const isHidden = layer.element.classList.contains('hidden');
        
        if (isHidden) {
            layer.element.classList.remove('hidden');
            document.querySelector(`.layer-tab[data-layer-id="${layerId}"] .layer-visibility i`)
                .classList.replace('fa-eye-slash', 'fa-eye');
        } else {
            layer.element.classList.add('hidden');
            document.querySelector(`.layer-tab[data-layer-id="${layerId}"] .layer-visibility i`)
                .classList.replace('fa-eye', 'fa-eye-slash');
        }
        
        // Trigger event
        this.triggerEvent('layerVisibilityChanged', { layerId, visible: !isHidden });
    }
    
    /**
     * Delete a layer
     */
    deleteLayer(layerId) {
        // Don't delete if it's the only layer
        if (this.layers.length <= 1) {
            console.warn('Cannot delete the only layer');
            return;
        }
        
        // Find the layer
        const layerIndex = this.layers.findIndex(l => l.id === layerId);
        if (layerIndex === -1) return;
        
        const layer = this.layers[layerIndex];
        
        // Remove all windows in this layer
        layer.windows.forEach(windowId => {
            this.removeWindow(windowId);
        });
        
        // Remove layer element
        this.container.removeChild(layer.element);
        
        // Remove layer tab
        const tab = document.querySelector(`.layer-tab[data-layer-id="${layerId}"]`);
        if (tab) tab.remove();
        
        // Remove from layers array
        this.layers.splice(layerIndex, 1);
        
        // If this was the active layer, set another one as active
        if (this.activeLayer === layerId) {
            this.setActiveLayer(this.layers[0].id);
        }
        
        // Trigger event
        this.triggerEvent('layerRemoved', layerId);
    }
    
    /**
     * Initialize the default windows
     */
    initializeDefaultWindows() {
        // Create windows with default positions
        const positions = [
            { x: 10, y: 10, width: 250, height: 600 },     // Explorer
            { x: 270, y: 10, width: 600, height: 400 },    // Editor
            { x: 270, y: 420, width: 600, height: 190 },   // Console
            { x: 880, y: 10, width: 600, height: 600 }     // Visualization
        ];
        
        this.options.defaultWindows.forEach((type, index) => {
            const pos = positions[index] || { x: 50 * index, y: 50 * index, width: 400, height: 300 };
            this.createWindow(type, {
                title: this.getDefaultTitle(type),
                ...pos
            });
        });
    }
    
    /**
     * Create a new window
     */
    createWindow(type, options = {}) {
        // Check if we've reached the maximum number of windows
        if (Object.keys(this.windows).length >= this.options.maxWindows) {
            console.warn(`Maximum number of windows (${this.options.maxWindows}) reached`);
            return null;
        }
        
        const windowId = `window-${type}-${++this.windowCounter}`;
        
        // Default options
        const windowOptions = {
            title: this.getDefaultTitle(type),
            x: Math.random() * 100,
            y: Math.random() * 100,
            width: 400,
            height: 300,
            layerId: this.activeLayer,
            ...options
        };
        
        // Create window element
        const windowEl = document.createElement('div');
        windowEl.className = 'window';
        windowEl.id = windowId;
        windowEl.dataset.type = type;
        windowEl.style.left = `${windowOptions.x}px`;
        windowEl.style.top = `${windowOptions.y}px`;
        windowEl.style.width = `${windowOptions.width}px`;
        windowEl.style.height = `${windowOptions.height}px`;
        windowEl.style.zIndex = 1;
        
        // Window structure
        windowEl.innerHTML = `
            <div class="window-header">
                <div class="window-title">${windowOptions.title}</div>
                <div class="window-controls">
                    <i class="fas fa-window-minimize window-minimize" title="Minimize"></i>
                    <i class="fas fa-expand window-maximize" title="Maximize"></i>
                    <i class="fas fa-times window-close" title="Close"></i>
                </div>
            </div>
            <div class="window-content ${type}-content">
                ${this.getDefaultContent(type)}
            </div>
        `;
        
        // Add to the active layer
        const layerElement = this.layers.find(l => l.id === windowOptions.layerId)?.element;
        if (!layerElement) {
            console.error(`Layer ${windowOptions.layerId} not found`);
            return null;
        }
        
        layerElement.appendChild(windowEl);
        
        // Add to windows object
        this.windows[windowId] = {
            id: windowId,
            type,
            element: windowEl,
            layerId: windowOptions.layerId,
            minimized: false,
            maximized: false,
            options: windowOptions
        };
        
        // Add to layer windows array
        const layerIndex = this.layers.findIndex(l => l.id === windowOptions.layerId);
        if (layerIndex !== -1) {
            this.layers[layerIndex].windows.push(windowId);
        }
        
        // Make it draggable
        this.makeWindowDraggable(windowId);
        
        // Attach event listeners
        this.attachWindowEventListeners(windowId);
        
        // Set as active window
        this.setActiveWindow(windowId);
        
        // Trigger event
        this.triggerEvent('windowCreated', windowId, type);
        
        return windowId;
    }
    
    /**
     * Get default title based on window type
     */
    getDefaultTitle(type) {
        switch (type) {
            case 'explorer': return 'Explorer';
            case 'editor': return 'Editor';
            case 'console': return 'Console';
            case 'visualization': return 'Galaxy Visualization';
            case 'settings': return 'Settings';
            default: return type.charAt(0).toUpperCase() + type.slice(1);
        }
    }
    
    /**
     * Get default content based on window type
     */
    getDefaultContent(type) {
        switch (type) {
            case 'explorer':
                return `
                    <div class="explorer-toolbar">
                        <button class="refresh-btn" title="Refresh"><i class="fas fa-sync"></i></button>
                        <button class="settings-btn" title="Settings"><i class="fas fa-cog"></i></button>
                    </div>
                    <ul class="file-explorer">
                        <!-- Explorer content will be added dynamically -->
                    </ul>
                `;
            case 'editor':
                return `<div id="editor-${this.windowCounter}" class="editor"></div>`;
            case 'console':
                return `<div class="console"></div>`;
            case 'visualization':
                return `<canvas width="600" height="600"></canvas>`;
            case 'settings':
                return `<div class="settings-panel">Settings content will be added dynamically</div>`;
            default:
                return `<div class="empty-content">No content available for ${type}</div>`;
        }
    }
    
    /**
     * Make a window draggable
     */
    makeWindowDraggable(windowId) {
        const windowEl = this.windows[windowId].element;
        const header = windowEl.querySelector('.window-header');
        
        let pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
        
        header.onmousedown = dragMouseDown.bind(this);
        
        function dragMouseDown(e) {
            e.preventDefault();
            // Get the mouse cursor position at startup
            pos3 = e.clientX;
            pos4 = e.clientY;
            
            // Bring window to front
            this.setActiveWindow(windowId);
            
            document.onmouseup = closeDragElement.bind(this);
            document.onmousemove = elementDrag.bind(this);
        }
        
        function elementDrag(e) {
            e.preventDefault();
            // Calculate the new cursor position
            pos1 = pos3 - e.clientX;
            pos2 = pos4 - e.clientY;
            pos3 = e.clientX;
            pos4 = e.clientY;
            
            // Set the element's new position
            const newTop = windowEl.offsetTop - pos2;
            const newLeft = windowEl.offsetLeft - pos1;
            
            windowEl.style.top = `${newTop}px`;
            windowEl.style.left = `${newLeft}px`;
            
            // Check if window is out of the container
            const container = this.container.getBoundingClientRect();
            const windowRect = windowEl.getBoundingClientRect();
            
            // Add a slight shade when window is outside visible area
            if (windowRect.left < container.left || 
                windowRect.right > container.right || 
                windowRect.top < container.top || 
                windowRect.bottom > container.bottom) {
                windowEl.classList.add('outside-bounds');
            } else {
                windowEl.classList.remove('outside-bounds');
            }
            
            // Trigger move event
            this.triggerEvent('windowMoved', windowId, { x: newLeft, y: newTop });
        }
        
        function closeDragElement() {
            // Stop moving when mouse button is released
            document.onmouseup = null;
            document.onmousemove = null;
        }
    }
    
    /**
     * Attach event listeners to a window
     */
    attachWindowEventListeners(windowId) {
        const windowEl = this.windows[windowId].element;
        
        // Set as active window when clicked
        windowEl.addEventListener('mousedown', () => {
            this.setActiveWindow(windowId);
        });
        
        // Window controls
        const minimizeBtn = windowEl.querySelector('.window-minimize');
        if (minimizeBtn) {
            minimizeBtn.addEventListener('click', () => {
                this.minimizeWindow(windowId);
            });
        }
        
        const maximizeBtn = windowEl.querySelector('.window-maximize');
        if (maximizeBtn) {
            maximizeBtn.addEventListener('click', () => {
                this.maximizeWindow(windowId);
            });
        }
        
        const closeBtn = windowEl.querySelector('.window-close');
        if (closeBtn) {
            closeBtn.addEventListener('click', () => {
                this.removeWindow(windowId);
            });
        }
    }
    
    /**
     * Show window type selector modal
     */
    showWindowTypeSelector() {
        // Create modal for window type selection
        const modal = document.createElement('div');
        modal.className = 'window-type-selector';
        modal.innerHTML = `
            <div class="window-type-selector-content">
                <h3>Add New Window</h3>
                <div class="window-type-options">
                    <div class="window-type" data-type="explorer">
                        <i class="fas fa-folder"></i>
                        <span>Explorer</span>
                    </div>
                    <div class="window-type" data-type="editor">
                        <i class="fas fa-code"></i>
                        <span>Editor</span>
                    </div>
                    <div class="window-type" data-type="console">
                        <i class="fas fa-terminal"></i>
                        <span>Console</span>
                    </div>
                    <div class="window-type" data-type="visualization">
                        <i class="fas fa-project-diagram"></i>
                        <span>Visualization</span>
                    </div>
                    <div class="window-type" data-type="settings">
                        <i class="fas fa-cog"></i>
                        <span>Settings</span>
                    </div>
                </div>
                <button class="cancel-btn">Cancel</button>
            </div>
        `;
        
        document.body.appendChild(modal);
        
        // Add event listeners
        modal.querySelectorAll('.window-type').forEach(el => {
            el.addEventListener('click', () => {
                const type = el.dataset.type;
                this.createWindow(type);
                document.body.removeChild(modal);
            });
        });
        
        modal.querySelector('.cancel-btn').addEventListener('click', () => {
            document.body.removeChild(modal);
        });
    }
    
    /**
     * Set active window
     */
    setActiveWindow(windowId) {
        // Update active window
        this.activeWindow = windowId;
        
        // Update z-index of all windows in the same layer
        const layerId = this.windows[windowId]?.layerId;
        if (layerId === undefined) return;
        
        const layerWindows = Object.values(this.windows)
            .filter(w => w.layerId === layerId);
        
        layerWindows.forEach(w => {
            if (w.id === windowId) {
                w.element.style.zIndex = 10;
                w.element.classList.add('active-window');
            } else {
                w.element.style.zIndex = 1;
                w.element.classList.remove('active-window');
            }
        });
        
        // Trigger event
        this.triggerEvent('windowActivated', windowId);
    }
    
    /**
     * Minimize a window
     */
    minimizeWindow(windowId) {
        const window = this.windows[windowId];
        if (!window) return;
        
        if (window.minimized) {
            // Restore
            window.element.querySelector('.window-content').style.display = 'flex';
            window.element.style.height = window.previousHeight || '300px';
            window.minimized = false;
            
            // Update icon
            const icon = window.element.querySelector('.window-minimize');
            icon.className = icon.className.replace('fa-window-restore', 'fa-window-minimize');
            icon.title = 'Minimize';
        } else {
            // Minimize
            window.previousHeight = window.element.style.height;
            window.element.querySelector('.window-content').style.display = 'none';
            window.element.style.height = 'auto';
            window.minimized = true;
            
            // Update icon
            const icon = window.element.querySelector('.window-minimize');
            icon.className = icon.className.replace('fa-window-minimize', 'fa-window-restore');
            icon.title = 'Restore';
        }
        
        // Trigger event
        this.triggerEvent('windowMinimized', windowId, window.minimized);
    }
    
    /**
     * Maximize a window
     */
    maximizeWindow(windowId) {
        const window = this.windows[windowId];
        if (!window) return;
        
        if (window.maximized) {
            // Restore
            window.element.style.top = window.prevPos.top;
            window.element.style.left = window.prevPos.left;
            window.element.style.width = window.prevPos.width;
            window.element.style.height = window.prevPos.height;
            window.maximized = false;
            
            // Update icon
            const icon = window.element.querySelector('.window-maximize');
            icon.className = icon.className.replace('fa-compress', 'fa-expand');
            icon.title = 'Maximize';
        } else {
            // Store current position and size
            window.prevPos = {
                top: window.element.style.top,
                left: window.element.style.left,
                width: window.element.style.width,
                height: window.element.style.height
            };
            
            // Get parent container dimensions
            const layerEl = this.layers.find(l => l.id === window.layerId).element;
            const rect = layerEl.getBoundingClientRect();
            
            // Maximize
            window.element.style.top = '0px';
            window.element.style.left = '0px';
            window.element.style.width = `${rect.width}px`;
            window.element.style.height = `${rect.height}px`;
            window.maximized = true;
            
            // Update icon
            const icon = window.element.querySelector('.window-maximize');
            icon.className = icon.className.replace('fa-expand', 'fa-compress');
            icon.title = 'Restore';
        }
        
        // Trigger event
        this.triggerEvent('windowMaximized', windowId, window.maximized);
    }
    
    /**
     * Remove a window
     */
    removeWindow(windowId) {
        const window = this.windows[windowId];
        if (!window) return;
        
        // Confirm window close
        if (this.options.confirmClose && !confirm('Are you sure you want to close this window?')) {
            return;
        }
        
        // Remove from DOM
        window.element.parentNode.removeChild(window.element);
        
        // Remove from layer windows array
        const layerIndex = this.layers.findIndex(l => l.id === window.layerId);
        if (layerIndex !== -1) {
            const windowIndex = this.layers[layerIndex].windows.indexOf(windowId);
            if (windowIndex !== -1) {
                this.layers[layerIndex].windows.splice(windowIndex, 1);
            }
        }
        
        // Remove from windows object
        delete this.windows[windowId];
        
        // If this was the active window, set another one as active
        if (this.activeWindow === windowId) {
            const layerWindows = Object.keys(this.windows).filter(id => 
                this.windows[id].layerId === window.layerId
            );
            
            if (layerWindows.length > 0) {
                this.setActiveWindow(layerWindows[0]);
            } else {
                this.activeWindow = null;
            }
        }
        
        // Trigger event
        this.triggerEvent('windowRemoved', windowId, window.type);
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
     * Add an event listener
     */
    addEventListener(event, callback) {
        if (!this.eventListeners[event]) {
            this.eventListeners[event] = [];
        }
        this.eventListeners[event].push(callback);
    }
    
    /**
     * Remove an event listener
     */
    removeEventListener(event, callback) {
        if (this.eventListeners[event]) {
            this.eventListeners[event] = this.eventListeners[event].filter(cb => cb !== callback);
        }
    }
    
    /**
     * Trigger an event
     */
    triggerEvent(event, ...args) {
        if (this.eventListeners[event]) {
            this.eventListeners[event].forEach(callback => {
                try {
                    callback(...args);
                } catch (error) {
                    console.error(`Error in ${event} event handler:`, error);
                }
            });
        }
    }
}