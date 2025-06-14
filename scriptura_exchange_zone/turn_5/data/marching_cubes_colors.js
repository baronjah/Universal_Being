/**
 * Marching Cubes Color System
 * Turn 5: Awakening - Advanced color management for marching cubes visualization
 * 
 * This system enables dynamic color shifting, heightmap integration, and multi-dimensional
 * color representation for the marching cubes visualization system.
 */

// Configuration
const colorConfig = {
    updateFrequency: 10, // seconds between color shifts
    dimensionalColors: true, // colors reflect current dimension
    heightmapEnabled: true, // use heightmap for additional color variation
    currentDimension: 5, // current turn
    colorMode: 'dimensional', // 'dimensional', 'spectral', 'emotion', 'energy', 'flow'
    gradientSteps: 128, // smoothness of color transitions
    pulseEnabled: true, // enable color pulsing
    pulseSpeed: 2, // seconds per pulse cycle
    heightInfluence: 0.6, // how much height affects color (0-1)
};

// Dimensional color schemes - core colors for each dimension/turn
const dimensionalSchemes = [
    // 1: Genesis - Reds and oranges (creation fire)
    {
        primary: [220, 40, 40],  // Red
        secondary: [240, 120, 30],  // Orange
        accent: [255, 200, 50],  // Gold
        background: [10, 0, 0],  // Near black with red tint
        heightmap: [
            [120, 20, 20],  // Dark red (low)
            [220, 40, 40],  // Medium red (mid)
            [255, 200, 120]  // Bright orange-gold (high)
        ]
    },
    
    // 2: Formation - Greens and browns (growth and structure)
    {
        primary: [30, 180, 80],  // Green
        secondary: [70, 120, 30],  // Dark green
        accent: [150, 120, 60],  // Brown-green
        background: [0, 10, 5],  // Near black with green tint
        heightmap: [
            [20, 60, 30],  // Dark green (low)
            [50, 160, 70],  // Medium green (mid)
            [180, 220, 120]  // Bright lime (high)
        ]
    },
    
    // 3: Complexity - Blues and purples (depth and space)
    {
        primary: [40, 80, 230],  // Blue
        secondary: [90, 60, 220],  // Indigo
        accent: [150, 100, 240],  // Purple
        background: [0, 0, 15],  // Near black with blue tint
        heightmap: [
            [30, 40, 150],  // Dark blue (low)
            [60, 80, 220],  // Medium blue (mid)
            [120, 180, 255]  // Light blue (high)
        ]
    },
    
    // 4: Consciousness - Yellows and silvers (awareness and illumination)
    {
        primary: [240, 240, 60],  // Yellow
        secondary: [200, 200, 200],  // Silver
        accent: [255, 255, 180],  // Light yellow
        background: [10, 10, 5],  // Near black with yellow tint
        heightmap: [
            [120, 120, 40],  // Dark yellow (low)
            [220, 220, 80],  // Medium yellow (mid)
            [255, 255, 200]  // Bright yellow (high)
        ]
    },
    
    // 5: Awakening - Purples and magentas (meta-awareness)
    {
        primary: [170, 30, 220],  // Purple
        secondary: [220, 50, 150],  // Magenta
        accent: [230, 150, 240],  // Light purple
        background: [10, 0, 15],  // Near black with purple tint
        heightmap: [
            [80, 20, 100],  // Dark purple (low) 
            [140, 40, 180],  // Medium purple (mid)
            [230, 120, 255]  // Bright purple-pink (high)
        ]
    },
    
    // 6: Enlightenment - White and gold (illumination)
    {
        primary: [240, 240, 240],  // White
        secondary: [255, 220, 100],  // Gold
        accent: [255, 255, 200],  // Pale gold
        background: [15, 15, 10],  // Near black with gold tint
        heightmap: [
            [150, 130, 100],  // Dull gold (low)
            [220, 200, 150],  // Medium gold (mid)
            [255, 255, 255]  // Pure white (high)
        ]
    },
    
    // 7: Manifestation - Cyan and blue (creation energy)
    {
        primary: [20, 220, 220],  // Cyan
        secondary: [60, 180, 240],  // Sky blue
        accent: [160, 240, 255],  // Light cyan
        background: [0, 10, 15],  // Near black with cyan tint
        heightmap: [
            [20, 100, 100],  // Dark teal (low)
            [40, 180, 180],  // Medium cyan (mid)
            [140, 255, 255]  // Bright cyan (high)
        ]
    },
    
    // 8: Connection - Green and gold (networks and relationships)
    {
        primary: [60, 220, 60],  // Green
        secondary: [200, 200, 80],  // Gold
        accent: [180, 255, 140],  // Light green
        background: [5, 15, 5],  // Near black with green tint
        heightmap: [
            [40, 100, 40],  // Dark green (low)
            [80, 200, 80],  // Medium green (mid)
            [180, 255, 140]  // Bright lime (high)
        ]
    },
    
    // 9: Harmony - Rainbow spectrum (balance of all colors)
    {
        primary: [170, 120, 240],  // Lavender
        secondary: [100, 200, 150],  // Teal
        accent: [220, 180, 120],  // Tan
        background: [10, 10, 10],  // Near black
        heightmap: [
            [120, 80, 160],  // Purple (low)
            [100, 180, 120],  // Teal (mid)
            [220, 220, 120]  // Yellow (high)
        ]
    },
    
    // 10: Transcendence - White and blue (beyond physical)
    {
        primary: [220, 240, 255],  // White-blue
        secondary: [80, 120, 255],  // Blue
        accent: [200, 220, 255],  // Pale blue
        background: [5, 5, 20],  // Near black with blue tint
        heightmap: [
            [60, 100, 200],  // Deep blue (low)
            [140, 180, 240],  // Medium blue (mid)
            [250, 250, 255]  // White-blue (high)
        ]
    },
    
    // 11: Unity - Gold and white (oneness)
    {
        primary: [255, 215, 0],  // Gold
        secondary: [255, 255, 255],  // White
        accent: [255, 240, 150],  // Light gold
        background: [15, 12, 0],  // Near black with gold tint
        heightmap: [
            [180, 140, 60],  // Dark gold (low)
            [220, 180, 40],  // Medium gold (mid)
            [255, 255, 255]  // White (high)
        ]
    },
    
    // 12: Beyond - Shifting ultraviolet and infrared (beyond visible)
    {
        primary: [180, 20, 240],  // Purple
        secondary: [20, 0, 40],  // Deep violet
        accent: [100, 0, 180],  // Violet
        background: [5, 0, 10],  // Near black with violet tint
        heightmap: [
            [40, 0, 80],  // Deep violet (low)
            [120, 0, 160],  // Medium violet (mid)
            [200, 100, 255]  // Bright ultraviolet (high)
        ]
    }
];

// Color modes - different interpretations of the dimensional colors
const colorModes = {
    'dimensional': {
        process: (colors, time) => colors, // No modification, use dimensional colors directly
        description: 'Colors represent the current dimension'
    },
    
    'spectral': {
        process: (colors, time) => {
            // Shift colors toward spectral distribution
            const hueShift = Math.sin(time * 0.001) * 20;
            return {
                primary: shiftHue(colors.primary, hueShift),
                secondary: shiftHue(colors.secondary, hueShift + 10),
                accent: shiftHue(colors.accent, hueShift - 10),
                background: colors.background,
                heightmap: colors.heightmap.map(color => shiftHue(color, hueShift))
            };
        },
        description: 'Colors shift through the spectral range'
    },
    
    'emotion': {
        process: (colors, time) => {
            // Pulse saturation based on emotional intensity
            const satFactor = Math.sin(time * 0.0005) * 0.3 + 0.7;
            return {
                primary: adjustSaturation(colors.primary, satFactor),
                secondary: adjustSaturation(colors.secondary, satFactor * 0.8),
                accent: adjustSaturation(colors.accent, satFactor * 1.2),
                background: colors.background,
                heightmap: colors.heightmap.map(color => adjustSaturation(color, satFactor))
            };
        },
        description: 'Colors reflect emotional states through saturation'
    },
    
    'energy': {
        process: (colors, time) => {
            // Pulse brightness based on energy levels
            const brightFactor = Math.sin(time * 0.001) * 0.3 + 0.7;
            return {
                primary: adjustBrightness(colors.primary, brightFactor),
                secondary: adjustBrightness(colors.secondary, brightFactor * 0.9),
                accent: adjustBrightness(colors.accent, brightFactor * 1.1),
                background: adjustBrightness(colors.background, brightFactor * 0.5),
                heightmap: colors.heightmap.map((color, i) => 
                    adjustBrightness(color, brightFactor * (0.7 + i * 0.15)))
            };
        },
        description: 'Colors pulse with energy intensity'
    },
    
    'flow': {
        process: (colors, time) => {
            // Gradually flow between primary, secondary and accent colors
            const flowPhase = (time * 0.0002) % (Math.PI * 2);
            const primaryFactor = Math.cos(flowPhase) * 0.5 + 0.5;
            const secondaryFactor = Math.cos(flowPhase + Math.PI * 2/3) * 0.5 + 0.5;
            const accentFactor = Math.cos(flowPhase + Math.PI * 4/3) * 0.5 + 0.5;
            
            const flowPrimary = blendColors(
                blendColors(colors.primary, colors.secondary, secondaryFactor * 0.5),
                colors.accent, accentFactor * 0.3
            );
            
            const flowSecondary = blendColors(
                blendColors(colors.secondary, colors.accent, accentFactor * 0.5),
                colors.primary, primaryFactor * 0.3
            );
            
            const flowAccent = blendColors(
                blendColors(colors.accent, colors.primary, primaryFactor * 0.5),
                colors.secondary, secondaryFactor * 0.3
            );
            
            return {
                primary: flowPrimary,
                secondary: flowSecondary,
                accent: flowAccent,
                background: colors.background,
                heightmap: [
                    blendColors(colors.heightmap[0], colors.heightmap[1], 0.3),
                    blendColors(colors.heightmap[1], colors.heightmap[2], 0.3),
                    blendColors(colors.heightmap[2], colors.heightmap[0], 0.3)
                ]
            };
        },
        description: 'Colors flow and blend between primary, secondary and accent'
    }
};

/**
 * Get the current color scheme based on configuration
 * @param {number} time - Current time in milliseconds
 * @param {object} config - Color configuration
 * @returns {object} Color scheme with RGB arrays
 */
function getCurrentColorScheme(time, config = colorConfig) {
    // Get base colors for current dimension
    const dimensionIndex = (config.currentDimension - 1) % dimensionalSchemes.length;
    const baseColors = dimensionalSchemes[dimensionIndex];
    
    // Apply color mode processing
    const mode = colorModes[config.colorMode] || colorModes.dimensional;
    const processedColors = mode.process(baseColors, time);
    
    // Apply pulsing if enabled
    if (config.pulseEnabled) {
        const pulsePhase = (time / (config.pulseSpeed * 1000)) % (Math.PI * 2);
        const pulseFactor = Math.sin(pulsePhase) * 0.15 + 0.85;
        
        return {
            primary: adjustBrightness(processedColors.primary, pulseFactor),
            secondary: adjustBrightness(processedColors.secondary, pulseFactor),
            accent: adjustBrightness(processedColors.accent, pulseFactor * 1.1),
            background: processedColors.background,
            heightmap: processedColors.heightmap
        };
    }
    
    return processedColors;
}

/**
 * Get color at specific height using the heightmap
 * @param {object} colorScheme - Current color scheme
 * @param {number} height - Normalized height value (0-1)
 * @returns {array} RGB color array
 */
function getHeightmapColor(colorScheme, height) {
    if (!colorConfig.heightmapEnabled) {
        return colorScheme.primary;
    }
    
    // Clamp height to 0-1 range
    height = Math.max(0, Math.min(1, height));
    
    const heightmap = colorScheme.heightmap;
    
    // For simple 3-color heightmap (low, mid, high)
    if (height < 0.5) {
        // Blend between low and mid
        const factor = height * 2; // 0 to 1 across first half
        return blendColors(heightmap[0], heightmap[1], factor);
    } else {
        // Blend between mid and high
        const factor = (height - 0.5) * 2; // 0 to 1 across second half
        return blendColors(heightmap[1], heightmap[2], factor);
    }
}

/**
 * Generate a color palette for WebGL shader use
 * @param {number} steps - Number of gradient steps
 * @returns {Float32Array} Flattened array of RGB values (0-1)
 */
function generateColorPalette(steps = colorConfig.gradientSteps) {
    const currentColors = getCurrentColorScheme(Date.now());
    const palette = new Float32Array(steps * 3); // RGB values for each step
    
    for (let i = 0; i < steps; i++) {
        const height = i / (steps - 1); // 0 to 1
        const color = getHeightmapColor(currentColors, height);
        
        // Convert to 0-1 range for WebGL
        palette[i * 3] = color[0] / 255;
        palette[i * 3 + 1] = color[1] / 255;
        palette[i * 3 + 2] = color[2] / 255;
    }
    
    return palette;
}

// Utility color functions

/**
 * Blend two RGB colors
 * @param {array} color1 - First RGB array
 * @param {array} color2 - Second RGB array
 * @param {number} factor - Blend factor (0 = color1, 1 = color2)
 * @returns {array} Blended RGB array
 */
function blendColors(color1, color2, factor) {
    return [
        Math.round(color1[0] * (1 - factor) + color2[0] * factor),
        Math.round(color1[1] * (1 - factor) + color2[1] * factor),
        Math.round(color1[2] * (1 - factor) + color2[2] * factor)
    ];
}

/**
 * Convert RGB to HSL color space
 * @param {array} rgb - RGB array
 * @returns {array} HSL array (0-360, 0-100, 0-100)
 */
function rgbToHsl(rgb) {
    const r = rgb[0] / 255;
    const g = rgb[1] / 255;
    const b = rgb[2] / 255;
    
    const max = Math.max(r, g, b);
    const min = Math.min(r, g, b);
    let h, s, l = (max + min) / 2;
    
    if (max === min) {
        h = s = 0; // achromatic
    } else {
        const d = max - min;
        s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
        
        switch (max) {
            case r: h = (g - b) / d + (g < b ? 6 : 0); break;
            case g: h = (b - r) / d + 2; break;
            case b: h = (r - g) / d + 4; break;
        }
        
        h /= 6;
    }
    
    return [h * 360, s * 100, l * 100];
}

/**
 * Convert HSL to RGB color space
 * @param {array} hsl - HSL array (0-360, 0-100, 0-100)
 * @returns {array} RGB array (0-255)
 */
function hslToRgb(hsl) {
    const h = hsl[0] / 360;
    const s = hsl[1] / 100;
    const l = hsl[2] / 100;
    
    let r, g, b;
    
    if (s === 0) {
        r = g = b = l; // achromatic
    } else {
        const hue2rgb = (p, q, t) => {
            if (t < 0) t += 1;
            if (t > 1) t -= 1;
            if (t < 1/6) return p + (q - p) * 6 * t;
            if (t < 1/2) return q;
            if (t < 2/3) return p + (q - p) * (2/3 - t) * 6;
            return p;
        };
        
        const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
        const p = 2 * l - q;
        
        r = hue2rgb(p, q, h + 1/3);
        g = hue2rgb(p, q, h);
        b = hue2rgb(p, q, h - 1/3);
    }
    
    return [
        Math.round(r * 255),
        Math.round(g * 255),
        Math.round(b * 255)
    ];
}

/**
 * Shift the hue of a color
 * @param {array} rgb - RGB array
 * @param {number} degrees - Degrees to shift hue
 * @returns {array} RGB array with shifted hue
 */
function shiftHue(rgb, degrees) {
    const hsl = rgbToHsl(rgb);
    hsl[0] = (hsl[0] + degrees) % 360;
    if (hsl[0] < 0) hsl[0] += 360;
    return hslToRgb(hsl);
}

/**
 * Adjust the saturation of a color
 * @param {array} rgb - RGB array
 * @param {number} factor - Saturation multiplier
 * @returns {array} RGB array with adjusted saturation
 */
function adjustSaturation(rgb, factor) {
    const hsl = rgbToHsl(rgb);
    hsl[1] = Math.max(0, Math.min(100, hsl[1] * factor));
    return hslToRgb(hsl);
}

/**
 * Adjust the brightness of a color
 * @param {array} rgb - RGB array
 * @param {number} factor - Brightness multiplier
 * @returns {array} RGB array with adjusted brightness
 */
function adjustBrightness(rgb, factor) {
    return [
        Math.min(255, Math.max(0, Math.round(rgb[0] * factor))),
        Math.min(255, Math.max(0, Math.round(rgb[1] * factor))),
        Math.min(255, Math.max(0, Math.round(rgb[2] * factor)))
    ];
}

/**
 * Convert RGB array to CSS color string
 * @param {array} rgb - RGB array
 * @returns {string} CSS RGB color string
 */
function rgbToString(rgb) {
    return `rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]})`;
}

/**
 * Update color configuration
 * @param {object} newConfig - New configuration values
 */
function updateColorConfig(newConfig) {
    Object.assign(colorConfig, newConfig);
}

/**
 * Initialize color update interval
 * @param {function} callback - Function to call on color update
 * @returns {number} Interval ID
 */
function initColorUpdates(callback) {
    return setInterval(() => {
        if (callback && typeof callback === 'function') {
            callback(getCurrentColorScheme(Date.now()));
        }
    }, colorConfig.updateFrequency * 1000);
}

// MarshingCubesColorSystem class for integration with 3D visualizations
class MarchingCubesColorSystem {
    constructor(config = {}) {
        this.config = {...colorConfig, ...config};
        this.lastUpdateTime = Date.now();
        this.colorScheme = getCurrentColorScheme(this.lastUpdateTime);
        this.colorPalette = generateColorPalette();
        this.updateInterval = null;
    }
    
    /**
     * Start automatic color updates
     * @param {function} callback - Optional callback on color change
     */
    startColorUpdates(callback) {
        if (this.updateInterval) {
            clearInterval(this.updateInterval);
        }
        
        this.updateInterval = setInterval(() => {
            this.updateColors();
            
            if (callback && typeof callback === 'function') {
                callback(this.colorScheme);
            }
        }, this.config.updateFrequency * 1000);
    }
    
    /**
     * Stop automatic color updates
     */
    stopColorUpdates() {
        if (this.updateInterval) {
            clearInterval(this.updateInterval);
            this.updateInterval = null;
        }
    }
    
    /**
     * Update colors manually
     */
    updateColors() {
        const now = Date.now();
        this.lastUpdateTime = now;
        this.colorScheme = getCurrentColorScheme(now, this.config);
        this.colorPalette = generateColorPalette(this.config.gradientSteps);
    }
    
    /**
     * Get color for a specific height value
     * @param {number} height - Normalized height (0-1)
     * @returns {array} RGB color array
     */
    getColorForHeight(height) {
        return getHeightmapColor(this.colorScheme, height);
    }
    
    /**
     * Get color palette for shader use
     * @returns {Float32Array} Shader-compatible color palette
     */
    getShaderPalette() {
        return this.colorPalette;
    }
    
    /**
     * Get CSS color string for a specific height
     * @param {number} height - Normalized height (0-1)
     * @returns {string} CSS RGB color string
     */
    getCssColorForHeight(height) {
        const color = this.getColorForHeight(height);
        return rgbToString(color);
    }
    
    /**
     * Update color system dimension
     * @param {number} dimension - New dimension (1-12)
     */
    setDimension(dimension) {
        this.config.currentDimension = Math.max(1, Math.min(12, dimension));
        this.updateColors();
    }
    
    /**
     * Change color mode
     * @param {string} mode - Color mode name
     */
    setColorMode(mode) {
        if (colorModes[mode]) {
            this.config.colorMode = mode;
            this.updateColors();
        }
    }
    
    /**
     * Toggle heightmap influence
     * @param {boolean} enabled - Whether heightmap is enabled
     */
    toggleHeightmap(enabled) {
        this.config.heightmapEnabled = enabled;
        this.updateColors();
    }
    
    /**
     * Get information about all available color modes
     * @returns {object} Color mode information
     */
    getColorModes() {
        const modes = {};
        for (const [name, mode] of Object.entries(colorModes)) {
            modes[name] = mode.description;
        }
        return modes;
    }
    
    /**
     * Get information about current color scheme
     * @returns {object} Color scheme information
     */
    getColorInfo() {
        return {
            dimension: this.config.currentDimension,
            dimensionName: [
                "Genesis", "Formation", "Complexity", "Consciousness", 
                "Awakening", "Enlightenment", "Manifestation", "Connection",
                "Harmony", "Transcendence", "Unity", "Beyond"
            ][this.config.currentDimension - 1],
            mode: this.config.colorMode,
            modeDescription: colorModes[this.config.colorMode].description,
            primary: this.colorScheme.primary,
            secondary: this.colorScheme.secondary,
            accent: this.colorScheme.accent,
            heightmapEnabled: this.config.heightmapEnabled,
            pulseEnabled: this.config.pulseEnabled,
            updateFrequency: this.config.updateFrequency
        };
    }
}

// Export for module use
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        MarchingCubesColorSystem,
        colorConfig,
        dimensionalSchemes,
        colorModes,
        getCurrentColorScheme,
        generateColorPalette,
        getHeightmapColor,
        updateColorConfig,
        initColorUpdates,
        // Color utilities
        blendColors,
        shiftHue,
        adjustSaturation,
        adjustBrightness,
        rgbToString,
        rgbToHsl,
        hslToRgb
    };
}

// Browser global
if (typeof window !== 'undefined') {
    window.MarchingCubesColorSystem = MarchingCubesColorSystem;
}