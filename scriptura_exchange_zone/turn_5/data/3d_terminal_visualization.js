/**
 * 3D Terminal Visualization System
 * Turn 5: Awakening - Enhanced visual communication layer
 * 
 * This system creates a spatial visualization of words and their relationships,
 * allowing for multiple communication channels and dimensional interaction.
 */

// Configuration
const config = {
    updateFrequency: 10000,  // 10 seconds update frequency
    dimensions: 5,           // Current turn dimensions
    colorSchemes: [
        {name: "Awakening", primary: "#8A2BE2", secondary: "#00FFFF", accent: "#FF1493"},
        {name: "Consciousness", primary: "#00CED1", secondary: "#9932CC", accent: "#FF4500"},
        {name: "Quantum", primary: "#4B0082", secondary: "#00FF00", accent: "#FFD700"},
        {name: "Ethereal", primary: "#483D8B", secondary: "#F0E68C", accent: "#FF00FF"},
        {name: "Dimensional", primary: "#2F4F4F", secondary: "#00FA9A", accent: "#FFA500"}
    ],
    currentScheme: 0,
    blinkEffects: true,
    wordRotationSpeed: 0.02,
    connectionStrength: 0.8,
    spatialDecay: 0.95
};

// Word representation in 3D space
class WordNode {
    constructor(word, power, x, y, z) {
        this.word = word;
        this.power = power;
        this.position = {x, y, z};
        this.velocity = {x: 0, y: 0, z: 0};
        this.connections = [];
        this.awareness = Math.min(5, Math.floor(power / 20));
        this.color = this.calculateColor();
        this.size = this.calculateSize();
        this.rotation = Math.random() * Math.PI * 2;
        this.blinkRate = (Math.random() * 5 + 5) * 1000; // 5-10 second blink rate
        this.lastBlink = Date.now();
        this.visible = true;
    }
    
    calculateColor() {
        const scheme = config.colorSchemes[config.currentScheme];
        const powerRatio = this.power / 100;
        
        // Mix between primary and accent color based on power
        const r = parseInt(scheme.primary.substring(1, 3), 16) * (1 - powerRatio) + 
                 parseInt(scheme.accent.substring(1, 3), 16) * powerRatio;
        const g = parseInt(scheme.primary.substring(3, 5), 16) * (1 - powerRatio) + 
                 parseInt(scheme.accent.substring(3, 5), 16) * powerRatio;
        const b = parseInt(scheme.primary.substring(5, 7), 16) * (1 - powerRatio) + 
                 parseInt(scheme.accent.substring(5, 7), 16) * powerRatio;
                 
        return `rgb(${Math.floor(r)}, ${Math.floor(g)}, ${Math.floor(b)})`;
    }
    
    calculateSize() {
        return 1 + (this.power / 20);
    }
    
    addConnection(otherNode, strength) {
        this.connections.push({
            node: otherNode,
            strength: strength || config.connectionStrength
        });
    }
    
    update(deltaTime) {
        // Update rotation
        this.rotation += config.wordRotationSpeed * deltaTime;
        
        // Handle blinking effect
        if (config.blinkEffects && Date.now() - this.lastBlink > this.blinkRate) {
            this.visible = !this.visible;
            this.lastBlink = Date.now();
            
            // Reset blink rate to create irregular pattern
            this.blinkRate = (Math.random() * 5 + 5) * 1000;
        }
        
        // Apply forces from connections
        for (const connection of this.connections) {
            const other = connection.node;
            const strength = connection.strength;
            
            // Calculate direction vector
            const dx = other.position.x - this.position.x;
            const dy = other.position.y - this.position.y;
            const dz = other.position.z - this.position.z;
            
            // Calculate distance
            const distance = Math.sqrt(dx*dx + dy*dy + dz*dz);
            
            // Skip if too close
            if (distance < 0.1) continue;
            
            // Calculate force (stronger for high power words)
            const force = strength * (this.power / 50) * (1 / distance);
            
            // Apply force
            this.velocity.x += dx * force * deltaTime;
            this.velocity.y += dy * force * deltaTime;
            this.velocity.z += dz * force * deltaTime;
        }
        
        // Apply velocity to position
        this.position.x += this.velocity.x * deltaTime;
        this.position.y += this.velocity.y * deltaTime;
        this.position.z += this.velocity.z * deltaTime;
        
        // Apply decay to velocity
        this.velocity.x *= config.spatialDecay;
        this.velocity.y *= config.spatialDecay;
        this.velocity.z *= config.spatialDecay;
    }
    
    render(context, camera) {
        if (!this.visible) return;
        
        // Project 3D position to 2D screen space
        const projectedPosition = camera.project(this.position);
        
        // Skip if out of view
        if (!projectedPosition) return;
        
        // Draw word node
        context.fillStyle = this.color;
        context.globalAlpha = 0.8;
        context.beginPath();
        context.arc(projectedPosition.x, projectedPosition.y, this.size, 0, Math.PI * 2);
        context.fill();
        
        // Draw word text
        context.fillStyle = "#FFFFFF";
        context.globalAlpha = 1.0;
        context.font = `${Math.max(10, this.size)}px monospace`;
        context.textAlign = "center";
        context.fillText(this.word, projectedPosition.x, projectedPosition.y + this.size + 10);
        
        // Draw power value
        context.font = `${Math.max(8, this.size * 0.8)}px monospace`;
        context.fillText(this.power, projectedPosition.x, projectedPosition.y - this.size - 5);
        
        // Draw connections
        for (const connection of this.connections) {
            const other = connection.node;
            const otherProjected = camera.project(other.position);
            
            if (!otherProjected) continue;
            
            context.strokeStyle = `rgba(255, 255, 255, ${connection.strength * 0.5})`;
            context.lineWidth = connection.strength * 2;
            context.beginPath();
            context.moveTo(projectedPosition.x, projectedPosition.y);
            context.lineTo(otherProjected.x, otherProjected.y);
            context.stroke();
        }
    }
}

// Camera system for 3D visualization
class Camera {
    constructor() {
        this.position = {x: 0, y: 0, z: -50};
        this.rotation = {x: 0, y: 0, z: 0};
        this.fov = 75;
        this.nearClip = 0.1;
        this.farClip = 1000;
    }
    
    project(point) {
        // Calculate relative position
        const relX = point.x - this.position.x;
        const relY = point.y - this.position.y;
        const relZ = point.z - this.position.z;
        
        // Apply rotation (simplified)
        const rotX = relX * Math.cos(this.rotation.y) - relZ * Math.sin(this.rotation.y);
        const rotZ = relX * Math.sin(this.rotation.y) + relZ * Math.cos(this.rotation.y);
        const rotY = relY * Math.cos(this.rotation.x) + rotZ * Math.sin(this.rotation.x);
        
        // If behind camera, don't render
        if (rotZ < this.nearClip) return null;
        if (rotZ > this.farClip) return null;
        
        // Project to screen space
        const screenWidth = window.innerWidth;
        const screenHeight = window.innerHeight;
        const scale = this.fov / rotZ;
        
        return {
            x: screenWidth / 2 + rotX * scale,
            y: screenHeight / 2 + rotY * scale,
            z: rotZ
        };
    }
    
    rotate(dx, dy) {
        this.rotation.y += dx * 0.01;
        this.rotation.x += dy * 0.01;
        
        // Limit vertical rotation
        this.rotation.x = Math.max(-Math.PI/2, Math.min(Math.PI/2, this.rotation.x));
    }
    
    zoom(amount) {
        this.position.z += amount;
        this.position.z = Math.max(-100, Math.min(-10, this.position.z));
    }
}

// Terminal visualization system
class TerminalVisualization {
    constructor(canvasId) {
        this.canvas = document.getElementById(canvasId);
        this.context = this.canvas.getContext('2d');
        this.words = [];
        this.camera = new Camera();
        this.lastUpdate = Date.now();
        this.colorChangeInterval = null;
        this.setupEventListeners();
        this.communicationModes = [
            {name: "Visual", active: true},
            {name: "Textual", active: true},
            {name: "Spatial", active: true},
            {name: "Connection", active: true},
            {name: "Dimensional", active: false} // Unlocked at Turn 6
        ];
    }
    
    setupEventListeners() {
        // Mouse controls for camera
        let isDragging = false;
        let lastMouseX = 0;
        let lastMouseY = 0;
        
        this.canvas.addEventListener('mousedown', (e) => {
            isDragging = true;
            lastMouseX = e.clientX;
            lastMouseY = e.clientY;
        });
        
        document.addEventListener('mousemove', (e) => {
            if (isDragging) {
                const dx = e.clientX - lastMouseX;
                const dy = e.clientY - lastMouseY;
                this.camera.rotate(dx, dy);
                lastMouseX = e.clientX;
                lastMouseY = e.clientY;
            }
        });
        
        document.addEventListener('mouseup', () => {
            isDragging = false;
        });
        
        // Zoom with wheel
        this.canvas.addEventListener('wheel', (e) => {
            e.preventDefault();
            this.camera.zoom(e.deltaY * 0.05);
        });
        
        // Window resize
        window.addEventListener('resize', () => this.resizeCanvas());
        
        // Start color cycling
        this.startColorCycling();
    }
    
    resizeCanvas() {
        this.canvas.width = window.innerWidth;
        this.canvas.height = window.innerHeight;
    }
    
    loadWords(wordData) {
        this.words = [];
        
        // Create word nodes
        for (const word of wordData) {
            // Random position in 3D space
            const x = (Math.random() - 0.5) * 100;
            const y = (Math.random() - 0.5) * 100;
            const z = (Math.random() - 0.5) * 100;
            
            this.words.push(new WordNode(word.text, word.power, x, y, z));
        }
        
        // Create connections between words (higher power words have more connections)
        for (const word of this.words) {
            const connectionCount = Math.floor(word.power / 10);
            
            // Connect to other words with similar power levels
            const sortedWords = [...this.words]
                .filter(w => w !== word)
                .sort((a, b) => Math.abs(a.power - word.power) - Math.abs(b.power - word.power));
            
            for (let i = 0; i < Math.min(connectionCount, sortedWords.length); i++) {
                word.addConnection(sortedWords[i], 0.5 + (Math.random() * 0.5));
            }
        }
    }
    
    startColorCycling() {
        if (this.colorChangeInterval) {
            clearInterval(this.colorChangeInterval);
        }
        
        this.colorChangeInterval = setInterval(() => {
            config.currentScheme = (config.currentScheme + 1) % config.colorSchemes.length;
            
            // Update word colors
            for (const word of this.words) {
                word.color = word.calculateColor();
            }
        }, config.updateFrequency);
    }
    
    toggleCommunicationMode(index) {
        if (index >= 0 && index < this.communicationModes.length) {
            this.communicationModes[index].active = !this.communicationModes[index].active;
        }
    }
    
    update() {
        const now = Date.now();
        const deltaTime = (now - this.lastUpdate) / 1000;
        this.lastUpdate = now;
        
        // Update all word nodes
        for (const word of this.words) {
            word.update(deltaTime);
        }
    }
    
    render() {
        // Clear canvas
        this.context.fillStyle = "#000000";
        this.context.fillRect(0, 0, this.canvas.width, this.canvas.height);
        
        // Sort words by distance from camera for proper Z-ordering
        const sortedWords = [...this.words].sort((a, b) => {
            const distA = Math.pow(a.position.x - this.camera.position.x, 2) +
                        Math.pow(a.position.y - this.camera.position.y, 2) +
                        Math.pow(a.position.z - this.camera.position.z, 2);
            const distB = Math.pow(b.position.x - this.camera.position.x, 2) +
                        Math.pow(b.position.y - this.camera.position.y, 2) +
                        Math.pow(b.position.z - this.camera.position.z, 2);
            return distB - distA;
        });
        
        // Draw connections first
        if (this.communicationModes[3].active) { // Connection mode
            for (const word of sortedWords) {
                for (const connection of word.connections) {
                    const other = connection.node;
                    const startPos = this.camera.project(word.position);
                    const endPos = this.camera.project(other.position);
                    
                    if (!startPos || !endPos) continue;
                    
                    this.context.strokeStyle = `rgba(255, 255, 255, ${connection.strength * 0.3})`;
                    this.context.lineWidth = connection.strength;
                    this.context.beginPath();
                    this.context.moveTo(startPos.x, startPos.y);
                    this.context.lineTo(endPos.x, endPos.y);
                    this.context.stroke();
                }
            }
        }
        
        // Draw word nodes
        for (const word of sortedWords) {
            word.render(this.context, this.camera);
        }
        
        // Draw UI elements
        this.drawUI();
    }
    
    drawUI() {
        // Draw current turn and dimension info
        this.context.fillStyle = config.colorSchemes[config.currentScheme].secondary;
        this.context.font = "16px monospace";
        this.context.textAlign = "left";
        this.context.fillText(`TURN ${config.dimensions}: AWAKENING`, 20, 30);
        this.context.fillText(`WORDS: ${this.words.length}`, 20, 50);
        this.context.fillText(`COLOR: ${config.colorSchemes[config.currentScheme].name}`, 20, 70);
        
        // Draw communication modes
        this.context.textAlign = "right";
        this.context.fillText("COMMUNICATION MODES:", this.canvas.width - 20, 30);
        
        for (let i = 0; i < this.communicationModes.length; i++) {
            const mode = this.communicationModes[i];
            this.context.fillStyle = mode.active ? 
                config.colorSchemes[config.currentScheme].accent : 
                "rgba(100, 100, 100, 0.5)";
            this.context.fillText(`${mode.name.toUpperCase()}: ${mode.active ? "ON" : "OFF"}`, 
                this.canvas.width - 20, 50 + (i * 20));
        }
    }
    
    animate() {
        this.update();
        this.render();
        requestAnimationFrame(() => this.animate());
    }
    
    start() {
        this.resizeCanvas();
        this.animate();
    }
}

// Sample word data loader
function loadWordDatabase() {
    // This would normally load from your word_database.txt
    // For demo purposes, we'll create sample data
    return fetch('/word_database.txt')
        .then(response => response.text())
        .then(text => {
            const words = [];
            const lines = text.split('\n');
            
            for (const line of lines) {
                const parts = line.trim().split(' ');
                if (parts.length >= 2) {
                    const text = parts[0];
                    const power = parseInt(parts[1], 10);
                    if (!isNaN(power)) {
                        words.push({text, power});
                    }
                }
            }
            
            return words;
        })
        .catch(error => {
            console.error('Error loading word database:', error);
            
            // Fallback to sample data
            return [
                {text: "divine", power: 75},
                {text: "creation", power: 40},
                {text: "reality", power: 35},
                {text: "eternal", power: 50},
                {text: "universe", power: 30},
                {text: "awakening", power: 65},
                {text: "consciousness", power: 55},
                {text: "illumination", power: 60},
                {text: "enlightenment", power: 70},
                {text: "ascension", power: 45},
                {text: "transcendence", power: 80},
                {text: "awareness", power: 62},
                {text: "perception", power: 38},
                {text: "knowledge", power: 42},
                {text: "wisdom", power: 58},
                {text: "insight", power: 46},
                {text: "dimension", power: 52},
                {text: "potential", power: 44},
                {text: "evolution", power: 56},
                {text: "transformation", power: 59}
            ];
        });
}

// Initialize the visualization when the page loads
document.addEventListener('DOMContentLoaded', () => {
    // Create canvas element if it doesn't exist
    if (!document.getElementById('visualization')) {
        const canvas = document.createElement('canvas');
        canvas.id = 'visualization';
        canvas.style.position = 'fixed';
        canvas.style.top = '0';
        canvas.style.left = '0';
        canvas.style.width = '100%';
        canvas.style.height = '100%';
        canvas.style.zIndex = '-1';
        document.body.appendChild(canvas);
    }
    
    const visualization = new TerminalVisualization('visualization');
    
    // Load word database
    loadWordDatabase().then(words => {
        visualization.loadWords(words);
        visualization.start();
        
        console.log("3D Terminal Visualization started");
        console.log(`Loaded ${words.length} words`);
        console.log("Current turn: 5 (Awakening)");
    });
    
    // Add keyboard controls for communication modes
    document.addEventListener('keydown', (e) => {
        // Keys 1-5 toggle communication modes
        if (e.key >= '1' && e.key <= '5') {
            const index = parseInt(e.key, 10) - 1;
            visualization.toggleCommunicationMode(index);
        }
        
        // Space changes color scheme
        if (e.key === ' ') {
            config.currentScheme = (config.currentScheme + 1) % config.colorSchemes.length;
        }
    });
});

// Terminal status update function - could be called from your main system
function updateTerminalStatus(systemData) {
    // Update configuration based on system data
    if (systemData.turn) {
        config.dimensions = systemData.turn;
    }
    
    if (systemData.blinkRate) {
        config.updateFrequency = systemData.blinkRate * 1000;
    }
    
    if (systemData.colors && Array.isArray(systemData.colors)) {
        // Replace color schemes or add new ones
        systemData.colors.forEach((color, index) => {
            if (index < config.colorSchemes.length) {
                config.colorSchemes[index] = color;
            } else {
                config.colorSchemes.push(color);
            }
        });
    }
    
    console.log("Terminal visualization updated with new system data");
}