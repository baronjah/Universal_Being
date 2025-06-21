// ConnectionManager.js - System for creating and managing connections between data

class ConnectionManager {
    constructor() {
        this.connections = [];
        this.connectionTypes = [
            { id: 'data-flow', name: 'Data Flow', color: '#4e88e5' },
            { id: 'reference', name: 'Reference', color: '#43a047' },
            { id: 'dependency', name: 'Dependency', color: '#fb8c00' },
            { id: 'custom', name: 'Custom', color: '#8e24aa' }
        ];
        
        // For creation mode
        this.isCreatingConnection = false;
        this.sourceNode = null;
        this.currentConnectionType = null;
    }
    
    initialize(galaxyVisualization) {
        this.galaxyVisualization = galaxyVisualization;
    }
    
    startConnectionCreation(sourceNode, connectionType = 'data-flow') {
        this.isCreatingConnection = true;
        this.sourceNode = sourceNode;
        this.currentConnectionType = connectionType;
        
        // Update UI to show connection creation mode
        document.body.classList.add('connection-creation-mode');


        // Add a visual indicator for the source node
        const sourceElement = document.querySelector(`[data-id="${sourceNode.id}"], [data-file="${sourceNode.id}"], [data-type="${sourceNode.id}"]`);
        if (sourceElement) {
            sourceElement.classList.add('connection-source');
        }
        
        // Show a temporary help message
        const helpMessage = document.createElement('div');
        helpMessage.className = 'connection-help-message';
        helpMessage.textContent = 'Click on a target item to connect';
        document.body.appendChild(helpMessage);


        
        // If using the galaxy visualization, we can show a temporary connection line
        if (this.galaxyVisualization) {
            this.galaxyVisualization.startConnectionPreview(sourceNode);
        }
        
        console.log(`Starting connection from ${sourceNode.id} (${sourceNode.name})`);
        return true;
    }
    
    completeConnectionCreation(targetNode) {
        if (!this.isCreatingConnection || !this.sourceNode || !targetNode) {
            return false;
        }
        
        // Don't connect a node to itself
        if (this.sourceNode.id === targetNode.id) {
            this.cancelConnectionCreation();
            return false;
        }
        
        // Create the connection
        const connection = {
            id: `conn_${Date.now()}`,
            sourceId: this.sourceNode.id,
            targetId: targetNode.id,
            type: this.currentConnectionType,
            metadata: {},
            createdAt: new Date()
        };
        
        // Add the connection
        this.connections.push(connection);
        
        console.log(`Created connection from ${this.sourceNode.name} to ${targetNode.name} (${this.currentConnectionType})`);
        
        // Reset connection creation state
        this.isCreatingConnection = false;
        document.body.classList.remove('connection-creation-mode');
        
        // Update visualization
        if (this.galaxyVisualization) {
            this.galaxyVisualization.endConnectionPreview();
            this.galaxyVisualization.addConnection(connection);
        }
        
        // Trigger an event that the connection was created
        this.dispatchEvent('connectionCreated', { connection });
        
        return connection;
    }
    
    cancelConnectionCreation() {
        if (!this.isCreatingConnection) return;
        
        this.isCreatingConnection = false;
        this.sourceNode = null;
        document.body.classList.remove('connection-creation-mode');
        
        // End preview if using galaxy visualization
        if (this.galaxyVisualization) {
            this.galaxyVisualization.endConnectionPreview();
        }
        
        console.log('Connection creation cancelled');
    }
    
    getConnectionById(connectionId) {
        return this.connections.find(conn => conn.id === connectionId);
    }
    
    getConnectionsBetweenNodes(sourceId, targetId) {
        return this.connections.filter(conn => 
            (conn.sourceId === sourceId && conn.targetId === targetId) ||
            (conn.sourceId === targetId && conn.targetId === sourceId)
        );
    }
    
    getConnectionsForNode(nodeId) {
        return this.connections.filter(conn => 
            conn.sourceId === nodeId || conn.targetId === nodeId
        );
    }
    
    deleteConnection(connectionId) {
        const index = this.connections.findIndex(conn => conn.id === connectionId);
        
        if (index !== -1) {
            const connection = this.connections[index];
            this.connections.splice(index, 1);
            
            // Update visualization
            if (this.galaxyVisualization) {
                this.galaxyVisualization.removeConnection(connection);
            }
            
            // Trigger an event that the connection was deleted
            this.dispatchEvent('connectionDeleted', { connection });
            
            return true;
        }
        
        return false;
    }
    
    updateConnection(connectionId, updates) {
        const connection = this.getConnectionById(connectionId);
        
        if (connection) {
            // Apply updates
            Object.assign(connection, updates);
            
            // Update visualization
            if (this.galaxyVisualization) {
                this.galaxyVisualization.updateConnection(connection);
            }
            
            // Trigger an event that the connection was updated
            this.dispatchEvent('connectionUpdated', { connection });
            
            return true;
        }
        
        return false;
    }
    
    // Connection UI methods
    renderConnectionTypeSelector(container) {
        container.innerHTML = '';
        
        this.connectionTypes.forEach(type => {
            const button = document.createElement('button');
            button.className = 'connection-type-btn';
            button.dataset.type = type.id;
            button.innerHTML = `
                <span class="connection-color" style="background-color: ${type.color}"></span>
                <span class="connection-name">${type.name}</span>
            `;
            
            button.addEventListener('click', () => {
                // Set as current type
                this.currentConnectionType = type.id;
                
                // Update UI
                container.querySelectorAll('.connection-type-btn').forEach(btn => {
                    btn.classList.remove('active');
                });
                button.classList.add('active');
                
                // Trigger event
                this.dispatchEvent('connectionTypeSelected', { type });
            });
            
            container.appendChild(button);
        });
    }
    
    // Event handling utilities
    dispatchEvent(name, detail) {
        const event = new CustomEvent(`connection-${name}`, { detail });
        document.dispatchEvent(event);
    }
    
    // Load and save connections
    loadConnections(connections) {
        if (!Array.isArray(connections)) return false;
        
        this.connections = [...connections];
        
        // Update visualization
        if (this.galaxyVisualization) {
            this.galaxyVisualization.updateAllConnections(this.connections);
        }
        
        return true;
    }
    
    saveConnections() {
        // Return a serializable copy of connections
        return [...this.connections];
    }
}