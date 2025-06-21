/**
 * GalaxyVisualization.js
 * 
 * A 2D galaxy visualization for displaying files and their connections
 * as stars and orbital systems.
 */

class GalaxyVisualization {
    constructor(options = {}) {
        this.config = {
            container: null,            // The container element
            data: null,                 // Visualization data
            width: 800,                 // Canvas width
            height: 600,                // Canvas height
            centerX: null,              // Center X position (if null, use width/2)
            centerY: null,              // Center Y position (if null, use height/2)
            backgroundColor: '#0c0c1e', // Background color
            starMinSize: 3,             // Minimum star size
            starMaxSize: 40,            // Maximum star size
            orbitSpeed: 0.0005,         // Orbit animation speed
            coreSize: 80,               // Core size
            coreGlowSize: 150,          // Core glow size
            coreColor: '#fffdcc',       // Core color
            onSelectNode: null,         // Callback when a node is selected
            onConnectNodes: null,       // Callback when nodes are connected
            ...options
        };
        
        // Set calculated center positions
        this.config.centerX = this.config.centerX || this.config.width / 2;
        this.config.centerY = this.config.centerY || this.config.height / 2;
        
        // Internal state
        this.state = {
            nodes: [],                  // Galaxy nodes
            connections: [],            // Node connections
            selectedNode: null,         // Currently selected node
            connectingMode: false,      // Whether in connecting mode
            connectionSource: null,     // Source node for connection
            zoom: 1,                    // Current zoom level
            pan: { x: 0, y: 0 },        // Pan offset
            animation: null,            // Animation frame
            mousePos: { x: 0, y: 0 },   // Current mouse position
            hoveredNode: null,          // Currently hovered node
            tooltip: null,              // Tooltip element
            time: 0                     // Animation time counter
        };
        
        // Canvas and context
        this.canvas = null;
        this.ctx = null;
        
        // Initialize if we have a container
        if (this.config.container) {
            this.initialize();
        }
    }
    
    /**
     * Initialize the galaxy visualization
     */
    initialize() {
        // Verify we have a container
        if (!this.config.container) {
            throw new Error('Container element is required');
        }
        
        // Create the canvas
        this.canvas = document.createElement('canvas');
        this.canvas.width = this.config.width;
        this.canvas.height = this.config.height;
        this.canvas.style.display = 'block';
        
        // Clear the container and add the canvas
        this.config.container.innerHTML = '';
        this.config.container.appendChild(this.canvas);
        
        // Get the context
        this.ctx = this.canvas.getContext('2d');
        
        // Create tooltip element
        this.state.tooltip = document.createElement('div');
        this.state.tooltip.className = 'galaxy-tooltip';
        this.state.tooltip.style.position = 'absolute';
        this.state.tooltip.style.display = 'none';
        this.state.tooltip.style.backgroundColor = 'rgba(0, 0, 0, 0.8)';
        this.state.tooltip.style.color = 'white';
        this.state.tooltip.style.padding = '5px 10px';
        this.state.tooltip.style.borderRadius = '3px';
        this.state.tooltip.style.fontSize = '12px';
        this.state.tooltip.style.pointerEvents = 'none';
        this.state.tooltip.style.zIndex = '1000';
        this.config.container.appendChild(this.state.tooltip);
        
        // Register event handlers
        this._registerEventHandlers();
        
        // Load data if provided
        if (this.config.data) {
            this.loadData(this.config.data);
        }
        
        // Start animation
        this._startAnimation();
        
        return this;
    }
    
    /**
     * Register event handlers
     * @private
     */
    _registerEventHandlers() {
        // Mouse move handler
        this.canvas.addEventListener('mousemove', this._handleMouseMove.bind(this));
        
        // Click handler
        this.canvas.addEventListener('click', this._handleClick.bind(this));
        
        // Wheel handler for zoom
        this.canvas.addEventListener('wheel', this._handleWheel.bind(this));
        
        // Mouse down handler for pan
        this.canvas.addEventListener('mousedown', this._handleMouseDown.bind(this));
        
        // Mouse up handler
        this.canvas.addEventListener('mouseup', this._handleMouseUp.bind(this));
        
        // Mouse out handler
        this.canvas.addEventListener('mouseout', this._handleMouseOut.bind(this));
    }
    
    /**
     * Handle mouse move event
     * @param {MouseEvent} e - Mouse event
     * @private
     */
    _handleMouseMove(e) {
        // Update mouse position
        const rect = this.canvas.getBoundingClientRect();
        this.state.mousePos = {
            x: e.clientX - rect.left,
            y: e.clientY - rect.top
        };
        
        // Check for node hover
        const hoveredNode = this._getNodeAtPosition(this.state.mousePos.x, this.state.mousePos.y);
        
        if (hoveredNode !== this.state.hoveredNode) {
            // Update cursor
            this.canvas.style.cursor = hoveredNode ? 'pointer' : 'default';
            
            // Show/hide tooltip
            if (hoveredNode) {
                this._showTooltip(hoveredNode, e.clientX, e.clientY);
            } else {
                this._hideTooltip();
            }
            
            this.state.hoveredNode = hoveredNode;
        }
        
        // Update tooltip position if displayed
        if (this.state.hoveredNode) {
            this._updateTooltipPosition(e.clientX, e.clientY);
        }
        
        // Handle pan if mouse is down
        if (this.state.panning) {
            this.state.pan.x += e.movementX;
            this.state.pan.y += e.movementY;
        }
    }
    
    /**
     * Handle click event
     * @param {MouseEvent} e - Mouse event
     * @private
     */
    _handleClick(e) {
        const rect = this.canvas.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;
        
        // Check if we clicked on a node
        const clickedNode = this._getNodeAtPosition(x, y);
        
        if (clickedNode) {
            // If we're in connecting mode, complete the connection
            if (this.state.connectingMode && this.state.connectionSource) {
                if (clickedNode !== this.state.connectionSource) {
                    this._createConnection(this.state.connectionSource, clickedNode);
                }
                
                // Exit connecting mode
                this._exitConnectingMode();
            } else {
                // Select the node
                this._selectNode(clickedNode);
            }
        } else {
            // Clicked on empty space, deselect
            this._deselectNode();
            
            // Exit connecting mode if active
            if (this.state.connectingMode) {
                this._exitConnectingMode();
            }
        }
    }
    
    /**
     * Handle wheel event for zooming
     * @param {WheelEvent} e - Wheel event
     * @private
     */
    _handleWheel(e) {
        e.preventDefault();
        
        // Calculate zoom factor
        const delta = -Math.sign(e.deltaY) * 0.1;
        const newZoom = Math.max(0.5, Math.min(3, this.state.zoom + delta));
        
        // Calculate zoom center (mouse position)
        const rect = this.canvas.getBoundingClientRect();
        const mouseX = e.clientX - rect.left;
        const mouseY = e.clientY - rect.top;
        
        // Calculate new pan to zoom at mouse position
        if (newZoom !== this.state.zoom) {
            const factor = newZoom / this.state.zoom;
            
            this.state.pan.x = mouseX - (mouseX - this.state.pan.x) * factor;
            this.state.pan.y = mouseY - (mouseY - this.state.pan.y) * factor;
            this.state.zoom = newZoom;
        }
    }
    
    /**
     * Handle mouse down event
     * @param {MouseEvent} e - Mouse event
     * @private
     */
    _handleMouseDown(e) {
        // Only enable panning with middle button or if no node is hovered
        if (e.button === 1 || !this.state.hoveredNode) {
            this.state.panning = true;
            this.canvas.style.cursor = 'grabbing';
        }
    }
    
    /**
     * Handle mouse up event
     * @param {MouseEvent} e - Mouse event
     * @private
     */
    _handleMouseUp(e) {
        this.state.panning = false;
        this.canvas.style.cursor = this.state.hoveredNode ? 'pointer' : 'default';
    }
    
    /**
     * Handle mouse out event
     * @param {MouseEvent} e - Mouse event
     * @private
     */
    _handleMouseOut(e) {
        this.state.panning = false;
        this._hideTooltip();
        this.state.hoveredNode = null;
    }
    
    /**
     * Show tooltip for a node
     * @param {Object} node - Node data
     * @param {number} x - Mouse X position
     * @param {number} y - Mouse Y position
     * @private
     */
    _showTooltip(node, x, y) {
        if (!this.state.tooltip) return;
        
        // Set tooltip content
        this.state.tooltip.innerHTML = `
            <div><strong>${node.name}</strong></div>
            <div>${node.type || 'File'}</div>
            ${node.description ? `<div>${node.description}</div>` : ''}
            ${node.size ? `<div>Size: ${this._formatFileSize(node.size)}</div>` : ''}
        `;
        
        // Position and show the tooltip
        this._updateTooltipPosition(x, y);
        this.state.tooltip.style.display = 'block';
    }
    
    /**
     * Update tooltip position
     * @param {number} x - Mouse X position
     * @param {number} y - Mouse Y position
     * @private
     */
    _updateTooltipPosition(x, y) {
        if (!this.state.tooltip) return;
        
        // Position the tooltip near the cursor
        this.state.tooltip.style.left = `${x + 15}px`;
        this.state.tooltip.style.top = `${y + 15}px`;
    }
    
    /**
     * Hide the tooltip
     * @private
     */
    _hideTooltip() {
        if (this.state.tooltip) {
            this.state.tooltip.style.display = 'none';
        }
    }
    
    /**
     * Format file size for display
     * @param {number} bytes - Size in bytes
     * @returns {string} Formatted size
     * @private
     */
    _formatFileSize(bytes) {
        if (bytes === 0) return '0 Bytes';
        
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }
    
    /**
     * Get the node at a specific position
     * @param {number} x - X coordinate
     * @param {number} y - Y coordinate
     * @returns {Object|null} Node at position or null
     * @private
     */
    _getNodeAtPosition(x, y) {
        // Apply inverse transformation for zoom and pan
        const transformedX = (x - this.state.pan.x) / this.state.zoom;
        const transformedY = (y - this.state.pan.y) / this.state.zoom;
        
        // Check each node (in reverse to get top-most first)
        for (let i = this.state.nodes.length - 1; i >= 0; i--) {
            const node = this.state.nodes[i];
            
            // Calculate distance to node center
            const dx = transformedX - node.x;
            const dy = transformedY - node.y;
            const distance = Math.sqrt(dx * dx + dy * dy);
            
            // Check if within node radius
            if (distance <= node.size / 2) {
                return node;
            }
        }
        
        return null;
    }
    
    /**
     * Select a node
     * @param {Object} node - Node to select
     * @private
     */
    _selectNode(node) {
        // Deselect current node if any
        this._deselectNode();
        
        // Select the new node
        this.state.selectedNode = node;
        node.selected = true;
        
        // Trigger callback if provided
        if (this.config.onSelectNode) {
            this.config.onSelectNode(node);
        }
    }
    
    /**
     * Deselect the current node
     * @private
     */
    _deselectNode() {
        if (this.state.selectedNode) {
            this.state.selectedNode.selected = false;
            this.state.selectedNode = null;
        }
    }
    
    /**
     * Enter connecting mode
     * @param {Object} sourceNode - Source node for connection
     */
    enterConnectingMode(sourceNode) {
        this.state.connectingMode = true;
        this.state.connectionSource = sourceNode;
        this.canvas.style.cursor = 'crosshair';
    }
    
    /**
     * Exit connecting mode
     * @private
     */
    _exitConnectingMode() {
        this.state.connectingMode = false;
        this.state.connectionSource = null;
        this.canvas.style.cursor = 'default';
    }
    
    /**
     * Create a connection between two nodes
     * @param {Object} sourceNode - Source node
     * @param {Object} targetNode - Target node
     * @private
     */
    _createConnection(sourceNode, targetNode) {
        // Check if connection already exists
        const exists = this.state.connections.some(conn => 
            (conn.source === sourceNode && conn.target === targetNode) ||
            (conn.source === targetNode && conn.target === sourceNode)
        );
        
        if (!exists) {
            // Add the connection
            this.state.connections.push({
                source: sourceNode,
                target: targetNode,
                type: 'default'
            });
            
            // Trigger callback if provided
            if (this.config.onConnectNodes) {
                this.config.onConnectNodes(sourceNode, targetNode);
            }
        }
    }
    
    /**
     * Start the animation loop
     * @private
     */
    _startAnimation() {
        const animate = () => {
            this.state.time += 1;
            this._render();
            this.state.animation = requestAnimationFrame(animate);
        };
        
        this.state.animation = requestAnimationFrame(animate);
    }
    
    /**
     * Stop the animation loop
     */
    stopAnimation() {
        if (this.state.animation) {
            cancelAnimationFrame(this.state.animation);
            this.state.animation = null;
        }
    }
    
    /**
     * Render the galaxy
     * @private
     */
    _render() {
        const { ctx, canvas } = this;
        const { width, height, backgroundColor, centerX, centerY } = this.config;
        
        // Clear the canvas
        ctx.clearRect(0, 0, width, height);
        
        // Fill background
        ctx.fillStyle = backgroundColor;
        ctx.fillRect(0, 0, width, height);
        
        // Save context for transformation
        ctx.save();
        
        // Apply zoom and pan
        ctx.translate(this.state.pan.x, this.state.pan.y);
        ctx.scale(this.state.zoom, this.state.zoom);
        
        // Draw background stars
        this._drawBackgroundStars();
        
        // Draw the core
        this._drawCore();
        
        // Draw connections
        this.state.connections.forEach(conn => {
            this._drawConnection(conn);
        });
        
        // Draw nodes
        this.state.nodes.forEach(node => {
            this._drawNode(node);
        });
        
        // Draw connecting line if in connecting mode
        if (this.state.connectingMode && this.state.connectionSource) {
            this._drawConnectingLine();
        }
        
        // Restore context
        ctx.restore();
    }
    
    /**
     * Draw background stars
     * @private
     */
    _drawBackgroundStars() {
        const { ctx } = this;
        const { width, height } = this.config;
        
        // Use a fixed seed for consistent star pattern
        const starCount = 200;
        const seed = 12345;
        
        // Simple deterministic random function
        const random = () => {
            seed = (seed * 9301 + 49297) % 233280;
            return seed / 233280;
        };
        
        for (let i = 0; i < starCount; i++) {
            // Generate pseudo-random positions using time as an offset for subtle movement
            const x = (random() * width + (i * 0.01 * this.state.time)) % width;
            const y = (random() * height + (i * 0.005 * this.state.time)) % height;
            const size = random() * 1.5 + 0.5;
            
            // Vary opacity slightly over time for twinkling effect
            const baseOpacity = random() * 0.5 + 0.3;
            const opacityVariation = Math.sin(this.state.time * 0.01 + i) * 0.2;
            const opacity = Math.max(0.1, Math.min(1, baseOpacity + opacityVariation));
            
            ctx.fillStyle = `rgba(255, 255, 255, ${opacity})`;
            ctx.beginPath();
            ctx.arc(x, y, size, 0, Math.PI * 2);
            ctx.fill();
        }
    }
    
    /**
     * Draw the galaxy core
     * @private
     */
    _drawCore() {
        const { ctx } = this;
        const { centerX, centerY, coreSize, coreGlowSize, coreColor } = this.config;
        
        // Draw core glow
        const gradient = ctx.createRadialGradient(
            centerX, centerY, coreSize / 2,
            centerX, centerY, coreGlowSize
        );
        gradient.addColorStop(0, coreColor);
        gradient.addColorStop(1, 'rgba(255, 255, 200, 0)');
        
        ctx.fillStyle = gradient;
        ctx.beginPath();
        ctx.arc(centerX, centerY, coreGlowSize, 0, Math.PI * 2);
        ctx.fill();
        
        // Draw core center
        ctx.fillStyle = coreColor;
        ctx.beginPath();
        ctx.arc(centerX, centerY, coreSize / 2, 0, Math.PI * 2);
        ctx.fill();
    }
    
    /**
     * Draw a node
     * @param {Object} node - Node to draw
     * @private
     */
    _drawNode(node) {
        const { ctx } = this;
        const { centerX, centerY } = this.config;
        
        // Calculate current position (apply rotation if orbiting)
        let x = node.x;
        let y = node.y;
        
        if (node.orbit) {
            const angle = node.orbit.startAngle + this.state.time * node.orbit.speed;
            x = node.orbit.centerX + Math.cos(angle) * node.orbit.radius;
            y = node.orbit.centerY + Math.sin(angle) * node.orbit.radius;
            
            // Update node position
            node.x = x;
            node.y = y;
        }
        
        // Draw node glow
        const glowSize = node.size * 1.5;
        const gradient = ctx.createRadialGradient(
            x, y, node.size / 3,
            x, y, glowSize
        );
        
        gradient.addColorStop(0, node.color);
        gradient.addColorStop(1, 'rgba(0, 0, 0, 0)');
        
        ctx.fillStyle = gradient;
        ctx.beginPath();
        ctx.arc(x, y, glowSize, 0, Math.PI * 2);
        ctx.fill();
        
        // Draw node body
        ctx.fillStyle = node.selected ? '#ffffff' : node.color;
        ctx.beginPath();
        ctx.arc(x, y, node.size / 2, 0, Math.PI * 2);
        ctx.fill();
        
        // Draw selection indicator if selected
        if (node.selected) {
            ctx.strokeStyle = '#ffffff';
            ctx.lineWidth = 2;
            ctx.setLineDash([5, 3]);
            ctx.beginPath();
            ctx.arc(x, y, node.size / 2 + 10, 0, Math.PI * 2);
            ctx.stroke();
            ctx.setLineDash([]);
        }
        
        // Draw label if node is large enough
        if (node.size > 15) {
            ctx.fillStyle = '#ffffff';
            ctx.font = `${Math.max(10, node.size / 4)}px Arial`;
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';
            ctx.fillText(node.name, x, y);
        }
    }
    
    /**
     * Draw a connection between nodes
     * @param {Object} connection - Connection data
     * @private
     */
    _drawConnection(connection) {
        const { ctx } = this;
        const { source, target, type } = connection;
        
        // Set line style based on connection type
        ctx.strokeStyle = type === 'default' ? '#6a9cff' : 
                          type === 'dependency' ? '#ff6a6a' : 
                          type === 'inheritance' ? '#6aff6a' : 
                          '#ffffff';
        
        ctx.lineWidth = 2;
        
        // Draw line
        ctx.beginPath();
        ctx.moveTo(source.x, source.y);
        ctx.lineTo(target.x, target.y);
        ctx.stroke();
        
        // Draw direction arrow
        const angle = Math.atan2(target.y - source.y, target.x - source.x);
        const arrowSize = 10;
        const arrowX = target.x - (target.size / 2 + 5) * Math.cos(angle);
        const arrowY = target.y - (target.size / 2 + 5) * Math.sin(angle);
        
        ctx.beginPath();
        ctx.moveTo(arrowX, arrowY);
        ctx.lineTo(
            arrowX - arrowSize * Math.cos(angle - Math.PI / 6),
            arrowY - arrowSize * Math.sin(angle - Math.PI / 6)
        );
        ctx.lineTo(
            arrowX - arrowSize * Math.cos(angle + Math.PI / 6),
            arrowY - arrowSize * Math.sin(angle + Math.PI / 6)
        );
        ctx.closePath();
        ctx.fillStyle = ctx.strokeStyle;
        ctx.fill();
    }
    
    /**
     * Draw connecting line when in connecting mode
     * @private
     */
    _drawConnectingLine() {
        const { ctx } = this;
        const source = this.state.connectionSource;
        
        if (!source) return;
        
        // Get mouse position adjusted for zoom and pan
        const mouseX = (this.state.mousePos.x - this.state.pan.x) / this.state.zoom;
        const mouseY = (this.state.mousePos.y - this.state.pan.y) / this.state.zoom;
        
        // Draw dashed line from source to mouse
        ctx.strokeStyle = '#ffffff';
        ctx.lineWidth = 2;
        ctx.setLineDash([5, 3]);
        
        ctx.beginPath();
        ctx.moveTo(source.x, source.y);
        ctx.lineTo(mouseX, mouseY);
        ctx.stroke();
        
        ctx.setLineDash([]);
    }
    
    /**
     * Load data into the visualization
     * @param {Object} data - Visualization data
     */
    loadData(data) {
        // Reset state
        this.state.nodes = [];
        this.state.connections = [];
        this.state.selectedNode = null;
        
        // Process nodes
        if (data.nodes) {
            data.nodes.forEach(nodeData => {
                this.addNode(nodeData);
            });
        }
        
        // Process connections
        if (data.connections) {
            data.connections.forEach(conn => {
                const sourceNode = this.findNodeById(conn.source);
                const targetNode = this.findNodeById(conn.target);
                
                if (sourceNode && targetNode) {
                    this.state.connections.push({
                        source: sourceNode,
                        target: targetNode,
                        type: conn.type || 'default'
                    });
                }
            });
        }
    }
    
    /**
     * Add a node to the visualization
     * @param {Object} nodeData - Node data
     * @returns {Object} Created node
     */
    addNode(nodeData) {
        const { centerX, centerY, starMinSize, starMaxSize } = this.config;
        
        // Calculate size based on importance or file size
        const size = nodeData.size ? 
                    Math.max(starMinSize, Math.min(starMaxSize, Math.log(nodeData.size) * 3)) : 
                    nodeData.importance ? 
                    starMinSize + (nodeData.importance * (starMaxSize - starMinSize)) :
                    (Math.random() * (starMaxSize - starMinSize) + starMinSize);
        
        // Calculate position
        let x, y, orbit;
        
        if (nodeData.fixed) {
            // Use fixed position if provided
            x = nodeData.x || centerX;
            y = nodeData.y || centerY;
        } else if (nodeData.orbit) {
            // Use orbit settings if provided
            orbit = {
                centerX: nodeData.orbit.centerX || centerX,
                centerY: nodeData.orbit.centerY || centerY,
                radius: nodeData.orbit.radius || (Math.random() * 200 + 100),
                startAngle: nodeData.orbit.startAngle || Math.random() * Math.PI * 2,
                speed: nodeData.orbit.speed || (this.config.orbitSpeed * (0.5 + Math.random()))
            };
            
            // Calculate initial position on orbit
            x = orbit.centerX + Math.cos(orbit.startAngle) * orbit.radius;
            y = orbit.centerY + Math.sin(orbit.startAngle) * orbit.radius;
        } else {
            // Generate random position
            const angle = Math.random() * Math.PI * 2;
            const distance = Math.random() * 200 + 100;
            
            x = centerX + Math.cos(angle) * distance;
            y = centerY + Math.sin(angle) * distance;
            
            // Create orbit for animation
            orbit = {
                centerX,
                centerY,
                radius: distance,
                startAngle: angle,
                speed: this.config.orbitSpeed * (0.5 + Math.random())
            };
        }
        
        // Create the node
        const node = {
            id: nodeData.id,
            name: nodeData.name,
            type: nodeData.type,
            description: nodeData.description,
            size,
            x,
            y,
            orbit,
            color: nodeData.color || this._getColorForType(nodeData.type),
            selected: false,
            data: nodeData
        };
        
        // Add to nodes array
        this.state.nodes.push(node);
        
        return node;
    }
    
    /**
     * Find a node by ID
     * @param {string} id - Node ID
     * @returns {Object|null} Found node or null
     */
    findNodeById(id) {
        return this.state.nodes.find(node => node.id === id);
    }
    
    /**
     * Get color for a node type
     * @param {string} type - Node type
     * @returns {string} Color
     * @private
     */
    _getColorForType(type) {
        const colorMap = {
            'file': '#3a7bf3',
            'directory': '#f3a93a',
            'css': '#3a9df3',
            'html': '#f3633a',
            'js': '#f3d03a',
            'csv': '#3af353',
            'json': '#a9f33a',
            'image': '#f33a9d',
            'txt': '#a0a0a0',
            'md': '#7a3af3',
            'xml': '#3af3e6',
            'pdf': '#f33a3a',
            'core': '#fffdcc'
        };
        
        return colorMap[type?.toLowerCase()] || '#ffffff';
    }
    
    /**
     * Resize the canvas
     * @param {number} width - New width
     * @param {number} height - New height
     */
    resize(width, height) {
        this.config.width = width;
        this.config.height = height;
        
        if (this.canvas) {
            this.canvas.width = width;
            this.canvas.height = height;
        }
        
        // Update center if not explicitly set
        if (this.config.centerX === null) {
            this.config.centerX = width / 2;
        }
        
        if (this.config.centerY === null) {
            this.config.centerY = height / 2;
        }
    }
    
    /**
     * Reset zoom and pan
     */
    resetView() {
        this.state.zoom = 1;
        this.state.pan = { x: 0, y: 0 };
    }
    
    /**
     * Zoom to a specific node
     * @param {string|Object} node - Node or node ID to zoom to
     */
    zoomToNode(node) {
        // Find the node if ID was provided
        if (typeof node === 'string') {
            node = this.findNodeById(node);
        }
        
        if (!node) return;
        
        // Calculate zoom and pan to center on the node
        const targetZoom = 1.5;
        
        // Pan to center the node
        this.state.pan.x = this.config.width / 2 - node.x * targetZoom;
        this.state.pan.y = this.config.height / 2 - node.y * targetZoom;
        
        // Set zoom
        this.state.zoom = targetZoom;
        
        // Select the node
        this._selectNode(node);
    }
    
    /**
     * Add a connection between nodes
     * @param {string} sourceId - Source node ID
     * @param {string} targetId - Target node ID
     * @param {string} type - Connection type
     * @returns {Object|null} Created connection or null
     */
    addConnection(sourceId, targetId, type = 'default') {
        const sourceNode = this.findNodeById(sourceId);
        const targetNode = this.findNodeById(targetId);
        
        if (!sourceNode || !targetNode) return null;
        
        // Check if connection already exists
        const existingConn = this.state.connections.find(conn => 
            (conn.source === sourceNode && conn.target === targetNode) ||
            (conn.source === targetNode && conn.target === sourceNode)
        );
        
        if (existingConn) return existingConn;
        
        // Create the connection
        const connection = {
            source: sourceNode,
            target: targetNode,
            type
        };
        
        // Add to connections array
        this.state.connections.push(connection);
        
        return connection;
    }
    
    /**
     * Remove a connection
     * @param {string} sourceId - Source node ID
     * @param {string} targetId - Target node ID
     * @returns {boolean} Whether the connection was removed
     */
    removeConnection(sourceId, targetId) {
        const sourceNode = this.findNodeById(sourceId);
        const targetNode = this.findNodeById(targetId);
        
        if (!sourceNode || !targetNode) return false;
        
        // Find the connection
        const index = this.state.connections.findIndex(conn => 
            (conn.source === sourceNode && conn.target === targetNode) ||
            (conn.source === targetNode && conn.target === sourceNode)
        );
        
        if (index === -1) return false;
        
        // Remove the connection
        this.state.connections.splice(index, 1);
        
        return true;
    }
    
    /**
     * Remove a node
     * @param {string} nodeId - Node ID to remove
     * @returns {boolean} Whether the node was removed
     */
    removeNode(nodeId) {
        const index = this.state.nodes.findIndex(node => node.id === nodeId);
        
        if (index === -1) return false;
        
        // Get the node
        const node = this.state.nodes[index];
        
        // Remove all connections involving this node
        this.state.connections = this.state.connections.filter(conn => 
            conn.source !== node && conn.target !== node
        );
        
        // Remove the node
        this.state.nodes.splice(index, 1);
        
        // Clear selection if this was the selected node
        if (this.state.selectedNode === node) {
            this.state.selectedNode = null;
        }
        
        return true;
    }
    
    /**
     * Generate nodes from file data
     * @param {Object} fileData - File system data
     * @param {Object} options - Generation options
     */
    generateNodesFromFiles(fileData, options = {}) {
        const nodes = [];
        const connections = [];
        
        // Options with defaults
        const opts = {
            groupByExtension: true,
            includeDirectories: true,
            maxDepth: 3,
            ...options
        };
        
        // Track unique extensions
        const extensions = new Set();
        const extensionNodes = {};
        
        // Process a file node
        const processFile = (file, parent, depth = 0) => {
            // Skip if we've reached max depth
            if (depth > opts.maxDepth) return;
            
            if (file.type === 'directory' && opts.includeDirectories) {
                // Create node for directory
                const dirNode = {
                    id: file.path || `dir_${file.name}`,
                    name: file.name,
                    type: 'directory',
                    size: file.size || 1000,
                    description: `Directory: ${file.path || file.name}`
                };
                
                nodes.push(dirNode);
                
                // Connect to parent if exists
                if (parent) {
                    connections.push({
                        source: parent.id,
                        target: dirNode.id,
                        type: 'contains'
                    });
                }
                
                // Process children
                if (file.children) {
                    file.children.forEach(child => {
                        processFile(child, dirNode, depth + 1);
                    });
                }
            } else if (file.type === 'file') {
                // Get file extension
                const extension = file.extension || file.name.split('.').pop();
                
                if (opts.groupByExtension) {
                    // Add extension to set
                    extensions.add(extension);
                    
                    // Create extension node if it doesn't exist
                    if (!extensionNodes[extension]) {
                        extensionNodes[extension] = {
                            id: `ext_${extension}`,
                            name: extension.toUpperCase(),
                            type: extension,
                            size: 5000,
                            description: `${extension.toUpperCase()} Files`,
                            files: []
                        };
                        
                        nodes.push(extensionNodes[extension]);
                        
                        // Connect to parent if exists and it's a directory
                        if (parent && parent.type === 'directory') {
                            connections.push({
                                source: parent.id,
                                target: extensionNodes[extension].id,
                                type: 'contains'
                            });
                        }
                    }
                    
                    // Add file to extension node's files
                    extensionNodes[extension].files.push(file);
                    
                    // If we're showing file nodes, add those too
                    if (opts.showFileNodes) {
                        const fileNode = {
                            id: file.path || `file_${file.name}`,
                            name: file.name,
                            type: extension,
                            size: file.size || 100,
                            description: `File: ${file.path || file.name}`
                        };
                        
                        nodes.push(fileNode);
                        
                        // Connect to extension node
                        connections.push({
                            source: extensionNodes[extension].id,
                            target: fileNode.id,
                            type: 'contains'
                        });
                    }
                } else {
                    // Create node for file
                    const fileNode = {
                        id: file.path || `file_${file.name}`,
                        name: file.name,
                        type: extension,
                        size: file.size || 100,
                        description: `File: ${file.path || file.name}`
                    };
                    
                    nodes.push(fileNode);
                    
                    // Connect to parent if exists
                    if (parent) {
                        connections.push({
                            source: parent.id,
                            target: fileNode.id,
                            type: 'contains'
                        });
                    }
                }
            }
        };
        
        // Start processing from the root
        if (fileData.type === 'directory') {
            processFile(fileData, null);
        } else if (Array.isArray(fileData)) {
            fileData.forEach(item => processFile(item, null));
        }
        
        // Create special connections between similar extension types
        if (opts.connectRelatedTypes) {
            const relationMap = {
                'html': ['css', 'js'],
                'js': ['json', 'html'],
                'css': ['html'],
                'cpp': ['h'],
                'h': ['cpp'],
                'py': ['json', 'csv']
            };
            
            for (const [type, relatedTypes] of Object.entries(relationMap)) {
                if (extensionNodes[type]) {
                    for (const relatedType of relatedTypes) {
                        if (extensionNodes[relatedType]) {
                            connections.push({
                                source: extensionNodes[type].id,
                                target: extensionNodes[relatedType].id,
                                type: 'related'
                            });
                        }
                    }
                }
            }
        }
        
        return { nodes, connections };
    }
    
    /**
     * Export the visualization to an image
     * @returns {string} Data URL of the image
     */
    exportToImage() {
        return this.canvas.toDataURL('image/png');
    }
    
    /**
     * Destroy the visualization and clean up resources
     */
    destroy() {
        // Stop animation
        this.stopAnimation();
        
        // Remove event listeners
        this.canvas.removeEventListener('mousemove', this._handleMouseMove);
        this.canvas.removeEventListener('click', this._handleClick);
        this.canvas.removeEventListener('wheel', this._handleWheel);
        this.canvas.removeEventListener('mousedown', this._handleMouseDown);
        this.canvas.removeEventListener('mouseup', this._handleMouseUp);
        this.canvas.removeEventListener('mouseout', this._handleMouseOut);
        
        // Remove tooltip
        if (this.state.tooltip) {
            this.state.tooltip.remove();
        }
        
        // Clear references
        this.canvas = null;
        this.ctx = null;
        this.state.tooltip = null;
    }
}

// If running in a browser environment, add to window
if (typeof window !== 'undefined') {
    window.GalaxyVisualization = GalaxyVisualization;
}