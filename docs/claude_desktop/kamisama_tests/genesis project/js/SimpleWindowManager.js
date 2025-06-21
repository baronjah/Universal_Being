/**
 * SimpleWindowManager.js - A lightweight window manager for the Genesis system
 * This simplifies the existing window-manager.js to focus on the core functionality
 */

class SimpleWindowManager {
    constructor() {
        this.windows = {};
        this.windowTypes = {};
        this.activeWindowId = null;
        this.zIndex = 1000;
        
        // Create container for windows if it doesn't exist
        this.container = document.getElementById('genesis-windows-container');
        if (!this.container) {
            this.container = document.createElement('div');
            this.container.id = 'genesis-windows-container';
            document.body.appendChild(this.container);
        }
    }
    
    /**
     * Register a window type
     * @param {Object} windowType - Window type configuration
     */
    registerWindowType(windowType) {
        if (!windowType.id) {
            console.error("Window type must have an id");
            return;
        }
        
        this.windowTypes[windowType.id] = {
            id: windowType.id,
            title: windowType.title || 'Window',
            width: windowType.width || '400px',
            height: windowType.height || '300px',
            component: windowType.component,
            position: windowType.position || 'center',
            resizable: windowType.resizable !== undefined ? windowType.resizable : true
        };
        
        console.log(`Registered window type: ${windowType.id}`);
    }
    
    /**
     * Create a new window
     * @param {string} typeId - Window type ID
     * @param {Object} data - Data to pass to the window
     * @returns {Object} Window instance
     */
    createWindow(typeId, data = {}) {
        const windowType = this.windowTypes[typeId];
        if (!windowType) {
            console.error(`Window type not found: ${typeId}`);
            return null;
        }
        
        const windowId = `window-${typeId}-${Date.now()}`;
        
        // Create window element
        const windowElement = document.createElement('div');
        windowElement.id = windowId;
        windowElement.className = 'genesis-window';
        windowElement.dataset.type = typeId;
        
        // Set initial size and position
        windowElement.style.width = windowType.width;
        windowElement.style.height = windowType.height;
        windowElement.style.zIndex = this.zIndex++;
        
        // Position the window
        this._positionWindow(windowElement, windowType.position);
        
        // Create window content
        windowElement.innerHTML = `
            <div class="genesis-window-header">
                <div class="genesis-window-title">${windowType.title}</div>
                <div class="genesis-window-controls">
                    ${windowType.resizable ? '<button class="genesis-window-maximize"><i class="fas fa-expand"></i></button>' : ''}
                    <button class="genesis-window-close"><i class="fas fa-times"></i></button>
                </div>
            </div>
            <div class="genesis-window-content" id="${windowId}-content"></div>
        `;
        
        // Add to container
        this.container.appendChild(windowElement);
        
        // Create window instance
        const windowInstance = {
            id: windowId,
            element: windowElement,
            contentElement: document.getElementById(`${windowId}-content`),
            config: windowType,
            data: data,
            isVisible: true,
            isMaximized: false,
            
            show: () => this._showWindow(windowId),
            hide: () => this._hideWindow(windowId),
            close: () => this._closeWindow(windowId),
            maximize: () => this._maximizeWindow(windowId),
            restore: () => this._restoreWindow(windowId)
        };
        
        // Store window instance
        this.windows[windowId] = windowInstance;
        
        // Set as active window
        this._setActiveWindow(windowId);
        
        // Setup event handlers
        this._setupWindowEvents(windowInstance);
        
        return windowInstance;
    }
    
    /**
     * Show a window
     * @param {string} windowId - Window ID
     * @private
     */
    _showWindow(windowId) {
        const windowInstance = this.windows[windowId];
        if (!windowInstance) return;
        
        windowInstance.element.style.display = 'flex';
        windowInstance.isVisible = true;
        this._setActiveWindow(windowId);
    }
    
    /**
     * Hide a window
     * @param {string} windowId - Window ID
     * @private
     */
    _hideWindow(windowId) {
        const windowInstance = this.windows[windowId];
        if (!windowInstance) return;
        
        windowInstance.element.style.display = 'none';
        windowInstance.isVisible = false;
        
        // Set another window as active if needed
        if (this.activeWindowId === windowId) {
            const visibleWindows = Object.keys(this.windows).filter(id => 
                id !== windowId && this.windows[id].isVisible
            );
            
            if (visibleWindows.length > 0) {
                this._setActiveWindow(visibleWindows[visibleWindows.length - 1]);
            } else {
                this.activeWindowId = null;
            }
        }
    }
    
    /**
     * Close a window
     * @param {string} windowId - Window ID
     * @private
     */
    _closeWindow(windowId) {
        const windowInstance = this.windows[windowId];
        if (!windowInstance) return;
        
        // Remove from DOM
        windowInstance.element.remove();
        
        // Remove from windows object
        delete this.windows[windowId];
        
        // Set another window as active if needed
        if (this.activeWindowId === windowId) {
            const visibleWindows = Object.keys(this.windows).filter(id => 
                this.windows[id].isVisible
            );
            
            if (visibleWindows.length > 0) {
                this._setActiveWindow(visibleWindows[visibleWindows.length - 1]);
            } else {
                this.activeWindowId = null;
            }
        }
    }
    
    /**
     * Maximize a window
     * @param {string} windowId - Window ID
     * @private
     */
    _maximizeWindow(windowId) {
        const windowInstance = this.windows[windowId];
        if (!windowInstance || !windowInstance.config.resizable) return;
        
        // Store current size and position for restore
        if (!windowInstance.isMaximized) {
            windowInstance.prevStyles = {
                width: windowInstance.element.style.width,
                height: windowInstance.element.style.height,
                left: windowInstance.element.style.left,
                top: windowInstance.element.style.top
            };
        }
        
        // Set to maximum size
        windowInstance.element.style.width = '100%';
        windowInstance.element.style.height = '100%';
        windowInstance.element.style.left = '0';
        windowInstance.element.style.top = '0';
        windowInstance.isMaximized = true;
        
        // Update button icon
        const maximizeBtn = windowInstance.element.querySelector('.genesis-window-maximize i');
        if (maximizeBtn) {
            maximizeBtn.className = 'fas fa-compress';
        }
    }
    
    /**
     * Restore a window to its previous size
     * @param {string} windowId - Window ID
     * @private
     */
    _restoreWindow(windowId) {
        const windowInstance = this.windows[windowId];
        if (!windowInstance || !windowInstance.isMaximized) return;
        
        // Restore previous size and position
        if (windowInstance.prevStyles) {
            Object.assign(windowInstance.element.style, windowInstance.prevStyles);
        } else {
            // Default if no previous state
            windowInstance.element.style.width = windowInstance.config.width;
            windowInstance.element.style.height = windowInstance.config.height;
            this._positionWindow(windowInstance.element, windowInstance.config.position);
        }
        
        windowInstance.isMaximized = false;
        
        // Update button icon
        const maximizeBtn = windowInstance.element.querySelector('.genesis-window-maximize i');
        if (maximizeBtn) {
            maximizeBtn.className = 'fas fa-expand';
        }
    }
    
    /**
     * Set a window as the active window
     * @param {string} windowId - Window ID
     * @private
     */
    _setActiveWindow(windowId) {
        // Remove active class from current active window
        if (this.activeWindowId && this.windows[this.activeWindowId]) {
            this.windows[this.activeWindowId].element.classList.remove('active');
        }
        
        // Set new active window
        if (windowId && this.windows[windowId]) {
            this.activeWindowId = windowId;
            this.windows[windowId].element.classList.add('active');
            this.windows[windowId].element.style.zIndex = this.zIndex++;
        } else {
            this.activeWindowId = null;
        }
    }
    
    /**
     * Position a window on the screen
     * @param {HTMLElement} windowElement - Window element
     * @param {string} position - Position ('center', 'left', 'right', etc.)
     * @private
     */
    _positionWindow(windowElement, position) {
        // Get window dimensions
        const width = windowElement.offsetWidth || parseInt(windowElement.style.width);
        const height = windowElement.offsetHeight || parseInt(windowElement.style.height);
        
        // Calculate position
        switch (position) {
            case 'center':
                windowElement.style.left = `calc(50% - ${width / 2}px)`;
                windowElement.style.top = `calc(50% - ${height / 2}px)`;
                break;
            case 'left':
                windowElement.style.left = '20px';
                windowElement.style.top = `calc(50% - ${height / 2}px)`;
                break;
            case 'right':
                windowElement.style.right = '20px';
                windowElement.style.top = `calc(50% - ${height / 2}px)`;
                break;
            case 'top':
                windowElement.style.left = `calc(50% - ${width / 2}px)`;
                windowElement.style.top = '20px';
                break;
            case 'bottom':
                windowElement.style.left = `calc(50% - ${width / 2}px)`;
                windowElement.style.bottom = '20px';
                break;
            case 'top-left':
                windowElement.style.left = '20px';
                windowElement.style.top = '20px';
                break;
            case 'top-right':
                windowElement.style.right = '20px';
                windowElement.style.top = '20px';
                break;
            case 'bottom-left':
                windowElement.style.left = '20px';
                windowElement.style.bottom = '20px';
                break;
            case 'bottom-right':
                windowElement.style.right = '20px';
                windowElement.style.bottom = '20px';
                break;
            default:
                windowElement.style.left = `calc(50% - ${width / 2}px)`;
                windowElement.style.top = `calc(50% - ${height / 2}px)`;
        }
    }
    
    /**
     * Setup event handlers for a window
     * @param {Object} windowInstance - Window instance
     * @private
     */
    _setupWindowEvents(windowInstance) {
        const element = windowInstance.element;
        const header = element.querySelector('.genesis-window-header');
        const closeBtn = element.querySelector('.genesis-window-close');
        const maximizeBtn = element.querySelector('.genesis-window-maximize');
        
        // Make the window draggable by the header
        this._makeDraggable(windowInstance, header);
        
        // Make the window resizable if configured
        if (windowInstance.config.resizable) {
            this._makeResizable(windowInstance);
        }
        
        // Close button
        if (closeBtn) {
            closeBtn.addEventListener('click', () => {
                this._closeWindow(windowInstance.id);
            });
        }
        
        // Maximize/Restore button
        if (maximizeBtn) {
            maximizeBtn.addEventListener('click', () => {
                if (windowInstance.isMaximized) {
                    this._restoreWindow(windowInstance.id);
                } else {
                    this._maximizeWindow(windowInstance.id);
                }
            });
        }
        
        // Activate window on click
        element.addEventListener('mousedown', () => {
            this._setActiveWindow(windowInstance.id);
        });
    }
    
    /**
     * Make a window draggable
     * @param {Object} windowInstance - Window instance
     * @param {HTMLElement} handle - Element to use as drag handle
     * @private
     */
    _makeDraggable(windowInstance, handle) {
        let offsetX, offsetY;
        
        handle.style.cursor = 'move';
        
        const onMouseDown = (e) => {
            // Don't drag if maximized
            if (windowInstance.isMaximized) return;
            
            e.preventDefault();
            
            // Get the initial mouse cursor position
            offsetX = e.clientX - windowInstance.element.offsetLeft;
            offsetY = e.clientY - windowInstance.element.offsetTop;
            
            // Add event listeners for dragging
            document.addEventListener('mousemove', onMouseMove);
            document.addEventListener('mouseup', onMouseUp);
        };
        
        const onMouseMove = (e) => {
            e.preventDefault();
            
            // Calculate the new position
            const x = e.clientX - offsetX;
            const y = e.clientY - offsetY;
            
            // Set the window position
            windowInstance.element.style.left = `${x}px`;
            windowInstance.element.style.top = `${y}px`;
        };
        
        const onMouseUp = () => {
            // Remove event listeners for dragging
            document.removeEventListener('mousemove', onMouseMove);
            document.removeEventListener('mouseup', onMouseUp);
        };
        
        // Attach the mousedown event
        handle.addEventListener('mousedown', onMouseDown);
    }
    
    /**
     * Make a window resizable
     * @param {Object} windowInstance - Window instance
     * @private
     */
    _makeResizable(windowInstance) {
        // Create resize handles
        const directions = ['n', 'e', 's', 'w', 'ne', 'se', 'sw', 'nw'];
        
        directions.forEach(direction => {
            const handle = document.createElement('div');
            handle.className = `genesis-window-resize-handle ${direction}`;
            windowInstance.element.appendChild(handle);
            
            // Set up resize functionality
            this._setupResizeHandle(windowInstance, handle, direction);
        });
    }
    
    /**
     * Set up a resize handle
     * @param {Object} windowInstance - Window instance
     * @param {HTMLElement} handle - Resize handle
     * @param {string} direction - Resize direction ('n', 'e', 's', 'w', 'ne', 'se', 'sw', 'nw')
     * @private
     */
    _setupResizeHandle(windowInstance, handle, direction) {
        let startX, startY, startWidth, startHeight, startLeft, startTop;
        
        const onMouseDown = (e) => {
            // Don't resize if maximized
            if (windowInstance.isMaximized) return;
            
            e.preventDefault();
            
            // Get the initial mouse cursor position
            startX = e.clientX;
            startY = e.clientY;
            
            // Get the initial window dimensions and position
            startWidth = windowInstance.element.offsetWidth;
            startHeight = windowInstance.element.offsetHeight;
            startLeft = windowInstance.element.offsetLeft;
            startTop = windowInstance.element.offsetTop;
            
            // Add event listeners for resizing
            document.addEventListener('mousemove', onMouseMove);
            document.addEventListener('mouseup', onMouseUp);
        };
        
        const onMouseMove = (e) => {
            e.preventDefault();
            
            // Calculate the distance moved
            const dx = e.clientX - startX;
            const dy = e.clientY - startY;
            
            // Resize based on direction
            if (direction.includes('e')) {
                windowInstance.element.style.width = `${startWidth + dx}px`;
            }
            if (direction.includes('s')) {
                windowInstance.element.style.height = `${startHeight + dy}px`;
            }
            if (direction.includes('w')) {
                windowInstance.element.style.width = `${startWidth - dx}px`;
                windowInstance.element.style.left = `${startLeft + dx}px`;
            }
            if (direction.includes('n')) {
                windowInstance.element.style.height = `${startHeight - dy}px`;
                windowInstance.element.style.top = `${startTop + dy}px`;
            }
        };
        
        const onMouseUp = () => {
            // Remove event listeners for resizing
            document.removeEventListener('mousemove', onMouseMove);
            document.removeEventListener('mouseup', onMouseUp);
        };
        
        // Attach the mousedown event
        handle.addEventListener('mousedown', onMouseDown);
    }
}

// Export the class
window.SimpleWindowManager = SimpleWindowManager;