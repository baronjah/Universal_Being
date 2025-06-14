/**
 * Shape System Integrator
 * Turn 4 (Temporal Flow) - 12 Turns Word Game
 * 
 * Integrates shape-based stories and concepts into the temporal flow,
 * creating connections between shapes and word manifestations.
 */

class ShapeSystemIntegrator {
    constructor() {
        this.basePath = "/mnt/c/Users/Percision 15/12_turns_system";
        this.shapes = new Map();
        this.stories = new Map();
        this.connections = new Map();
        this.temporalShapes = { past: [], present: [], future: [] };
        this.dimension = "4D"; // Temporal Flow
        this.baseShapes = ["square", "circle", "triangle", "hexagon", "pentagon", "octagon"];
        this.complexShapes = ["cube", "sphere", "tetrahedron", "dodecahedron", "icosahedron"];
        this.temporalShapes = ["timecube", "echosphere", "wavefront", "pastcone", "futurecone"];
    }

    /**
     * Initialize the shape system
     */
    initialize() {
        console.log("Initializing Shape System Integrator");
        
        // Initialize base shapes
        this.initializeShapes();
        
        // Initialize temporal shape variants
        this.initializeTemporalShapes();
        
        return {
            status: "initialized",
            shapeCount: this.shapes.size,
            storyCount: this.stories.size,
            dimension: this.dimension
        };
    }

    /**
     * Initialize shapes
     */
    initializeShapes() {
        // Initialize base shapes
        for (const shapeName of this.baseShapes) {
            this.shapes.set(shapeName, {
                name: shapeName,
                type: "base",
                dimension: 2,
                vertices: this.calculateVertices(shapeName),
                edges: this.calculateEdges(shapeName),
                properties: {
                    stability: 0.8,
                    flexibility: 0.5,
                    resonance: 0.4
                },
                created: new Date()
            });
        }
        
        // Initialize complex shapes
        for (const shapeName of this.complexShapes) {
            this.shapes.set(shapeName, {
                name: shapeName,
                type: "complex",
                dimension: 3,
                vertices: this.calculateVertices(shapeName),
                edges: this.calculateEdges(shapeName),
                faces: this.calculateFaces(shapeName),
                properties: {
                    stability: 0.7,
                    flexibility: 0.6,
                    resonance: 0.6
                },
                created: new Date()
            });
        }
        
        console.log(`Initialized ${this.shapes.size} shapes`);
    }

    /**
     * Initialize temporal shape variants
     */
    initializeTemporalShapes() {
        // Initialize temporal shapes
        for (const shapeName of this.temporalShapes) {
            this.shapes.set(shapeName, {
                name: shapeName,
                type: "temporal",
                dimension: 4,
                vertices: this.calculateVertices(shapeName),
                edges: this.calculateEdges(shapeName),
                faces: this.calculateFaces(shapeName),
                cells: this.calculateCells(shapeName),
                properties: {
                    stability: 0.5,
                    flexibility: 0.9,
                    resonance: 0.8,
                    temporalEcho: 0.7
                },
                timeStates: ["past", "present", "future"],
                created: new Date()
            });
            
            // Create temporal variants for past, present, future
            this.temporalShapes.past.push(`${shapeName}_past`);
            this.temporalShapes.present.push(`${shapeName}_present`);
            this.temporalShapes.future.push(`${shapeName}_future`);
        }
        
        console.log(`Initialized ${this.temporalShapes.length * 3} temporal shape variants`);
    }

    /**
     * Calculate vertices for a shape
     */
    calculateVertices(shapeName) {
        // Simplified calculation
        switch (shapeName) {
            case "square": return 4;
            case "triangle": return 3;
            case "pentagon": return 5;
            case "hexagon": return 6;
            case "octagon": return 8;
            case "circle": return Infinity;
            case "cube": return 8;
            case "sphere": return Infinity;
            case "tetrahedron": return 4;
            case "dodecahedron": return 20;
            case "icosahedron": return 12;
            case "timecube": return 16;
            case "echosphere": return Infinity;
            case "wavefront": return 24;
            case "pastcone": return 13;
            case "futurecone": return 13;
            default: return 0;
        }
    }

    /**
     * Calculate edges for a shape
     */
    calculateEdges(shapeName) {
        // Simplified calculation
        switch (shapeName) {
            case "square": return 4;
            case "triangle": return 3;
            case "pentagon": return 5;
            case "hexagon": return 6;
            case "octagon": return 8;
            case "circle": return Infinity;
            case "cube": return 12;
            case "sphere": return Infinity;
            case "tetrahedron": return 6;
            case "dodecahedron": return 30;
            case "icosahedron": return 30;
            case "timecube": return 32;
            case "echosphere": return Infinity;
            case "wavefront": return 36;
            case "pastcone": return 24;
            case "futurecone": return 24;
            default: return 0;
        }
    }

    /**
     * Calculate faces for a shape
     */
    calculateFaces(shapeName) {
        // Simplified calculation
        switch (shapeName) {
            case "cube": return 6;
            case "sphere": return Infinity;
            case "tetrahedron": return 4;
            case "dodecahedron": return 12;
            case "icosahedron": return 20;
            case "timecube": return 24;
            case "echosphere": return Infinity;
            case "wavefront": return 14;
            case "pastcone": return 12;
            case "futurecone": return 12;
            default: return 0;
        }
    }

    /**
     * Calculate cells for a shape
     */
    calculateCells(shapeName) {
        // Simplified calculation - only 4D shapes have cells
        switch (shapeName) {
            case "timecube": return 8;
            case "echosphere": return Infinity;
            case "wavefront": return 12;
            case "pastcone": return 10;
            case "futurecone": return 10;
            default: return 0;
        }
    }

    /**
     * Create a story with shapes
     */
    createShapeStory(title, shapes, content) {
        if (!title || !shapes || !content) {
            return {
                error: "Title, shapes, and content are required"
            };
        }
        
        // Validate shapes
        const validShapes = shapes.filter(shape => this.shapes.has(shape));
        if (validShapes.length === 0) {
            return {
                error: "No valid shapes provided",
                availableShapes: Array.from(this.shapes.keys())
            };
        }
        
        // Calculate story power based on shapes and content
        const shapePower = validShapes.reduce((total, shape) => {
            const shapeObj = this.shapes.get(shape);
            if (!shapeObj) return total;
            
            const dimensionFactor = shapeObj.dimension;
            const resonance = shapeObj.properties.resonance;
            
            return total + (dimensionFactor * resonance * 10);
        }, 0);
        
        // Calculate content power
        const contentPower = Math.min(100, content.length / 10);
        
        // Total power
        const totalPower = shapePower + contentPower;
        
        // Create story
        const storyId = `story_${Date.now()}`;
        const story = {
            id: storyId,
            title: title,
            shapes: validShapes,
            content: content,
            power: totalPower,
            created: new Date(),
            dimension: this.dimension,
            timeState: "present" // Default to present
        };
        
        // Store story
        this.stories.set(storyId, story);
        
        // Create connections between shapes and story
        for (const shape of validShapes) {
            const connectionId = `${shape}_to_${storyId}`;
            this.connections.set(connectionId, {
                source: shape,
                target: storyId,
                type: "shape_to_story",
                strength: 0.8,
                created: new Date()
            });
        }
        
        console.log(`Created story "${title}" with ${validShapes.length} shapes`);
        
        return {
            message: `Story created: ${title}`,
            id: storyId,
            power: totalPower,
            shapeCount: validShapes.length
        };
    }

    /**
     * Create a temporal echo of a story
     */
    createTemporalEcho(storyId, timeState) {
        if (!this.stories.has(storyId)) {
            return {
                error: `Story not found: ${storyId}`,
                hint: "Create a story first"
            };
        }
        
        if (!["past", "present", "future"].includes(timeState)) {
            return {
                error: `Invalid time state: ${timeState}`,
                valid: ["past", "present", "future"]
            };
        }
        
        // Get original story
        const originalStory = this.stories.get(storyId);
        
        // Create a temporal echo with modified shapes
        const echoShapes = originalStory.shapes.map(shape => {
            // For each shape, try to find a temporal variant
            if (this.temporalShapes[timeState].includes(`${shape}_${timeState}`)) {
                return `${shape}_${timeState}`;
            }
            return shape;
        });
        
        // Create echo story
        const echoId = `${storyId}_${timeState}`;
        const echoStory = {
            id: echoId,
            title: `${originalStory.title} (${timeState})`,
            shapes: echoShapes,
            content: originalStory.content,
            power: originalStory.power * (timeState === "future" ? 1.2 : (timeState === "past" ? 0.8 : 1.0)),
            created: new Date(),
            dimension: this.dimension,
            timeState: timeState,
            originalStory: storyId
        };
        
        // Store echo story
        this.stories.set(echoId, echoStory);
        
        // Create connection to original story
        const connectionId = `${storyId}_to_${echoId}`;
        this.connections.set(connectionId, {
            source: storyId,
            target: echoId,
            type: "temporal_echo",
            strength: 0.9,
            created: new Date(),
            timeState: timeState
        });
        
        console.log(`Created ${timeState} echo of story "${originalStory.title}"`);
        
        return {
            message: `Created ${timeState} echo of story "${originalStory.title}"`,
            id: echoId,
            timeState: timeState,
            power: echoStory.power
        };
    }

    /**
     * Connect a shape to words
     */
    connectShapeToWords(shapeName, words) {
        if (!this.shapes.has(shapeName)) {
            return {
                error: `Shape not found: ${shapeName}`,
                availableShapes: Array.from(this.shapes.keys())
            };
        }
        
        if (!Array.isArray(words) || words.length === 0) {
            return {
                error: "Words must be a non-empty array"
            };
        }
        
        const shape = this.shapes.get(shapeName);
        const connections = [];
        
        // Connect each word to the shape
        for (const word of words) {
            const connectionId = `${shapeName}_to_${word}_${Date.now()}`;
            
            this.connections.set(connectionId, {
                source: shapeName,
                target: word,
                type: "shape_to_word",
                strength: 0.7,
                created: new Date(),
                dimension: shape.dimension,
                properties: {
                    resonance: shape.properties.resonance,
                    wordPower: word.length * 5
                }
            });
            
            connections.push({
                word: word,
                connectionId: connectionId
            });
        }
        
        console.log(`Connected shape ${shapeName} to ${words.length} words`);
        
        return {
            message: `Connected shape ${shapeName} to ${words.length} words`,
            shape: shapeName,
            connections: connections
        };
    }

    /**
     * Get all shapes for a time state
     */
    getShapesForTimeState(timeState) {
        if (!["past", "present", "future"].includes(timeState)) {
            return {
                error: `Invalid time state: ${timeState}`,
                valid: ["past", "present", "future"]
            };
        }
        
        // Collect all shapes for this time state
        const timeShapes = [];
        
        // Add temporal shapes specific to this time state
        timeShapes.push(...this.temporalShapes[timeState]);
        
        // Add basic shapes (they exist in all time states)
        if (timeState === "present") {
            timeShapes.push(...this.baseShapes);
            timeShapes.push(...this.complexShapes);
        }
        
        return {
            timeState: timeState,
            shapes: timeShapes,
            count: timeShapes.length
        };
    }

    /**
     * Get all stories for a time state
     */
    getStoriesForTimeState(timeState) {
        if (!["past", "present", "future", "all"].includes(timeState)) {
            return {
                error: `Invalid time state: ${timeState}`,
                valid: ["past", "present", "future", "all"]
            };
        }
        
        // Collect stories for this time state
        const timeStories = [];
        
        for (const [id, story] of this.stories.entries()) {
            if (timeState === "all" || story.timeState === timeState) {
                timeStories.push({
                    id: id,
                    title: story.title,
                    shapeCount: story.shapes.length,
                    power: story.power,
                    timeState: story.timeState
                });
            }
        }
        
        return {
            timeState: timeState === "all" ? "all" : timeState,
            stories: timeStories,
            count: timeStories.length
        };
    }

    /**
     * Get status of the shape system
     */
    getStatus() {
        return {
            shapes: {
                total: this.shapes.size,
                base: this.baseShapes.length,
                complex: this.complexShapes.length,
                temporal: Object.values(this.temporalShapes).flat().length
            },
            stories: {
                total: this.stories.size,
                past: Array.from(this.stories.values()).filter(s => s.timeState === "past").length,
                present: Array.from(this.stories.values()).filter(s => s.timeState === "present").length,
                future: Array.from(this.stories.values()).filter(s => s.timeState === "future").length
            },
            connections: {
                total: this.connections.size,
                shapeToStory: Array.from(this.connections.values()).filter(c => c.type === "shape_to_story").length,
                shapeToWord: Array.from(this.connections.values()).filter(c => c.type === "shape_to_word").length,
                temporalEcho: Array.from(this.connections.values()).filter(c => c.type === "temporal_echo").length
            },
            dimension: this.dimension
        };
    }
}

// For Node.js environment
if (typeof module !== 'undefined') {
    module.exports = { ShapeSystemIntegrator };
}

// Initialize when run directly
if (require.main === module) {
    const integrator = new ShapeSystemIntegrator();
    const result = integrator.initialize();
    console.log("Shape System Integrator initialized:", result);
}