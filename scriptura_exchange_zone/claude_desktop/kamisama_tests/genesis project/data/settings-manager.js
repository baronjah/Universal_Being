/**
 * Settings Manager for Genesis Project
 * 
 * Manages application settings and preferences with local storage persistence.
 */
class SettingsManager {
    constructor(options = {}) {
        // Default options
        this.options = {
            storageKey: 'genesis_app_settings',
            ...options
        };
        
        // Default settings
        this.defaults = {
            theme: 'dark',
            editorFontSize: 14,
            editorShowLineNumbers: true,
            editorSyntaxTheme: 'monokai',
            colorSpectrum: [
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
            ],
            visualizationAutoUpdate: true,
            visualizationNodeSize: 3,
            consoleMaxLines: 100,
            explorerShowHidden: false,
            windowSnapToGrid: false,
            windowSnapGridSize: 20,
            layerTabPosition: 'bottom',
            generateSampleData: true,
            confirmDialogs: true,
            autoSave: false,
            autoSaveInterval: 60, // seconds
            fileExplorerMode: 'tree', // 'tree' or 'list'
            currentProject: null
        };
        
        // Settings storage
        this.settings = {};
        
        // Event listeners
        this.eventListeners = {};
    }
    
    /**
     * Load settings from local storage
     */
    async loadSettings() {
        try {
            // Try to load from local storage
            const storedSettings = localStorage.getItem(this.options.storageKey);
            
            if (storedSettings) {
                // Parse stored settings
                const parsed = JSON.parse(storedSettings);
                
                // Merge with defaults (so any new settings get default values)
                this.settings = {...this.defaults, ...parsed};
            } else {
                // Use defaults
                this.settings = {...this.defaults};
            }
            
            this.triggerEvent('settingsLoaded', this.settings);
            return this.settings;
        } catch (error) {
            console.error('Error loading settings:', error);
            
            // Use defaults on error
            this.settings = {...this.defaults};
            return this.settings;
        }
    }
    
    /**
     * Save settings to local storage
     */
    async saveSettings() {
        try {
            localStorage.setItem(this.options.storageKey, JSON.stringify(this.settings));
            this.triggerEvent('settingsSaved', this.settings);
            return true;
        } catch (error) {
            console.error('Error saving settings:', error);
            return false;
        }
    }
    
    /**
     * Get a setting value
     */
    getSetting(key) {
        return this.settings[key] !== undefined ? this.settings[key] : this.defaults[key];
    }
    
    /**
     * Set a setting value
     */
    setSetting(key, value) {
        const oldValue = this.settings[key];
        this.settings[key] = value;
        
        // Save to storage
        this.saveSettings();
        
        // Trigger events
        this.triggerEvent('settingChanged', key, oldValue, value);
        this.triggerEvent(`${key}Changed`, oldValue, value);
    }
    
    /**
     * Reset settings to defaults
     */
    resetSettings() {
        this.settings = {...this.defaults};
        this.saveSettings();
        this.triggerEvent('settingsReset', this.settings);
    }
    
    /**
     * Reset a specific setting to its default
     */
    resetSetting(key) {
        if (this.defaults[key] !== undefined) {
            const oldValue = this.settings[key];
            this.settings[key] = this.defaults[key];
            this.saveSettings();
            
            this.triggerEvent('settingChanged', key, oldValue, this.settings[key]);
            this.triggerEvent(`${key}Changed`, oldValue, this.settings[key]);
        }
    }
    
    /**
     * Import settings from a JSON object
     */
    importSettings(jsonSettings) {
        try {
            const newSettings = typeof jsonSettings === 'string' 
                ? JSON.parse(jsonSettings) 
                : jsonSettings;
                
            // Only import known settings
            const validSettings = {};
            for (const key in this.defaults) {
                if (newSettings[key] !== undefined) {
                    validSettings[key] = newSettings[key];
                }
            }
            
            // Merge with current settings
            this.settings = {...this.settings, ...validSettings};
            this.saveSettings();
            
            this.triggerEvent('settingsImported', this.settings);
            return true;
        } catch (error) {
            console.error('Error importing settings:', error);
            return false;
        }
    }
    
    /**
     * Export settings as a JSON string
     */
    exportSettings() {
        return JSON.stringify(this.settings, null, 2);
    }
    
    /**
     * Create the settings UI in a window
     */
    createSettingsUI(container) {
        if (!container) return;