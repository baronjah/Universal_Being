// SettingsManager.js - Manage application settings and preferences

class SettingsManager {
    constructor() {
        this.settings = {
            // Theme settings
            theme: 'dark', // 'dark' or 'light'
            accentColor: '#0078d7',
            textColor: '#f0f0f0',
            fontSize: 14,
            
            // Grid settings
            gridShowLineNumbers: true,
            gridAutoSave: false,
            gridMaxRows: 10000,
            
            // Visualization settings
            galaxyNodeSize: 30,
            galaxyAnimationSpeed: 1.0,
            showConnectionLabels: true,
            
            // System settings
            autoScanFiles: true,
            autoEvolution: false,
            evolutionSpeed: 5, // seconds between evolution steps
            
            // User preferences
            defaultView: 'grid', // 'grid', 'galaxy', 'network'
            confirmBeforeDelete: true,
            showTooltips: true
        };
        
        // Load settings from storage if available
        this.loadSettings();
    }
    
    initialize(container) {
        this.container = typeof container === 'string' ? document.getElementById(container) : container;
        
        // Render the settings panel
        this.renderSettingsPanel();
        
        // Apply current settings to the application
        this.applySettings();
    }
    
    renderSettingsPanel() {
        if (!this.container) return;
        
        this.container.innerHTML = `
            <div class="settings-header">
                <h2>Settings</h2>
                <button id="settings-close-btn" class="settings-close-btn">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            
            <div class="settings-content">
                <div class="settings-section">
                    <h3>Appearance</h3>
                    
                    <div class="settings-group">
                        <label for="setting-theme">Theme</label>
                        <select id="setting-theme" data-setting="theme">
                            <option value="dark">Dark</option>
                            <option value="light">Light</option>
                        </select>
                    </div>
                    
                    <div class="settings-group">
                        <label for="setting-accent-color">Accent Color</label>
                        <input type="color" id="setting-accent-color" data-setting="accentColor">
                    </div>
                    
                    <div class="settings-group">
                        <label for="setting-text-color">Text Color</label>
                        <input type="color" id="setting-text-color" data-setting="textColor">
                    </div>
                    
                    <div class="settings-group">
                        <label for="setting-font-size">Font Size</label>
                        <input type="range" id="setting-font-size" data-setting="fontSize" 
                               min="10" max="24" step="1">
                        <span class="setting-value" id="font-size-value">14px</span>
                    </div>
                </div>
                
                <div class="settings-section">
                    <h3>Grid View</h3>
                    
                    <div class="settings-group">
                        <label for="setting-grid-line-numbers">Show Line Numbers</label>
                        <input type="checkbox" id="setting-grid-line-numbers" data-setting="gridShowLineNumbers">
                    </div>
                    
                    <div class="settings-group">
                        <label for="setting-grid-auto-save">Auto Save Changes</label>
                        <input type="checkbox" id="setting-grid-auto-save" data-setting="gridAutoSave">
                    </div>
                </div>
                
                <div class="settings-section">
                    <h3>Visualization</h3>
                    
                    <div class="settings-group">
                        <label for="setting-galaxy-node-size">Node Size</label>
                        <input type="range" id="setting-galaxy-node-size" data-setting="galaxyNodeSize" 
                               min="10" max="60" step="1">
                        <span class="setting-value" id="galaxy-node-size-value">30px</span>
                    </div>
                    
                    <div class="settings-group">
                        <label for="setting-animation-speed">Animation Speed</label>
                        <input type="range" id="setting-animation-speed" data-setting="galaxyAnimationSpeed" 
                               min="0.1" max="2" step="0.1">
                        <span class="setting-value" id="animation-speed-value">1.0x</span>
                    </div>
                    
                    <div class="settings-group">
                        <label for="setting-show-connection-labels">Show Connection Labels</label>
                        <input type="checkbox" id="setting-show-connection-labels" data-setting="showConnectionLabels">
                    </div>
                </div>
                
                <div class="settings-section">
                    <h3>System</h3>
                    
                    <div class="settings-group">
                        <label for="setting-auto-scan">Auto-scan for Files</label>
                        <input type="checkbox" id="setting-auto-scan" data-setting="autoScanFiles">
                    </div>
                    
<div class="settings-group">
                       <label for="setting-auto-evolution">Enable Auto-Evolution</label>
                       <input type="checkbox" id="setting-auto-evolution" data-setting="autoEvolution">
                   </div>
                   
                   <div class="settings-group">
                       <label for="setting-evolution-speed">Evolution Speed</label>
                       <input type="range" id="setting-evolution-speed" data-setting="evolutionSpeed" 
                              min="1" max="20" step="1">
                       <span class="setting-value" id="evolution-speed-value">5s</span>
                   </div>
               </div>
               
               <div class="settings-section">
                   <h3>User Preferences</h3>
                   
                   <div class="settings-group">
                       <label for="setting-default-view">Default View</label>
                       <select id="setting-default-view" data-setting="defaultView">
                           <option value="grid">Grid View</option>
                           <option value="galaxy">Galaxy View</option>
                           <option value="network">Network View</option>
                       </select>
                   </div>
                   
                   <div class="settings-group">
                       <label for="setting-confirm-delete">Confirm Before Delete</label>
                       <input type="checkbox" id="setting-confirm-delete" data-setting="confirmBeforeDelete">
                   </div>
                   
                   <div class="settings-group">
                       <label for="setting-show-tooltips">Show Tooltips</label>
                       <input type="checkbox" id="setting-show-tooltips" data-setting="showTooltips">
                   </div>
               </div>
           </div>
           
           <div class="settings-footer">
               <button id="reset-settings-btn" class="secondary-btn">Reset to Defaults</button>
               <button id="save-settings-btn" class="primary-btn">Save Settings</button>
           </div>
       `;
       
       // Populate form fields with current settings
       this.populateSettingsForm();
       
       // Set up event listeners
       this.setupSettingsEventListeners();
   }
   
   populateSettingsForm() {
       // For each input element with a data-setting attribute, set its value
       this.container.querySelectorAll('[data-setting]').forEach(input => {
           const settingName = input.dataset.setting;
           const settingValue = this.settings[settingName];
           
           if (input.type === 'checkbox') {
               input.checked = settingValue;
           } else if (input.type === 'range') {
               input.value = settingValue;
               // Update the displayed value
               const valueDisplay = this.container.querySelector(`#${input.id}-value`);
               if (valueDisplay) {
                   let displayValue = settingValue;
                   if (settingName === 'fontSize') displayValue += 'px';
                   else if (settingName === 'galaxyNodeSize') displayValue += 'px';
                   else if (settingName === 'galaxyAnimationSpeed') displayValue += 'x';
                   else if (settingName === 'evolutionSpeed') displayValue += 's';
                   valueDisplay.textContent = displayValue;
               }
           } else {
               input.value = settingValue;
           }
       });
   }
   
   setupSettingsEventListeners() {
       // Close button
       const closeBtn = this.container.querySelector('#settings-close-btn');
       if (closeBtn) {
           closeBtn.addEventListener('click', () => {
               this.hideSettingsPanel();
           });
       }
       
       // Save button
       const saveBtn = this.container.querySelector('#save-settings-btn');
       if (saveBtn) {
           saveBtn.addEventListener('click', () => {
               this.saveSettingsFromForm();
           });
       }
       
       // Reset button
       const resetBtn = this.container.querySelector('#reset-settings-btn');
       if (resetBtn) {
           resetBtn.addEventListener('click', () => {
               this.resetSettings();
           });
       }
       
       // Update value displays for range inputs
       this.container.querySelectorAll('input[type="range"]').forEach(range => {
           range.addEventListener('input', () => {
               const valueDisplay = this.container.querySelector(`#${range.id}-value`);
               if (valueDisplay) {
                   let displayValue = range.value;
                   if (range.dataset.setting === 'fontSize') displayValue += 'px';
                   else if (range.dataset.setting === 'galaxyNodeSize') displayValue += 'px';
                   else if (range.dataset.setting === 'galaxyAnimationSpeed') displayValue += 'x';
                   else if (range.dataset.setting === 'evolutionSpeed') displayValue += 's';
                   valueDisplay.textContent = displayValue;
               }
           });
       });
       
       // Theme changes should apply immediately for preview
       const themeSelect = this.container.querySelector('#setting-theme');
       if (themeSelect) {
           themeSelect.addEventListener('change', () => {
               this.applyTheme(themeSelect.value);
           });
       }
       
       // Color changes should apply immediately for preview
       const colorInputs = this.container.querySelectorAll('input[type="color"]');
       colorInputs.forEach(input => {
           input.addEventListener('input', () => {
               const settingName = input.dataset.setting;
               this.settings[settingName] = input.value;
               this.applyTheme();
           });
       });
   }
   
   saveSettingsFromForm() {
       // Gather all settings from the form
       this.container.querySelectorAll('[data-setting]').forEach(input => {
           const settingName = input.dataset.setting;
           
           if (input.type === 'checkbox') {
               this.settings[settingName] = input.checked;
           } else if (input.type === 'range' || input.type === 'number') {
               this.settings[settingName] = parseFloat(input.value);
           } else {
               this.settings[settingName] = input.value;
           }
       });
       
       // Save to storage
       this.saveSettings();
       
       // Apply the settings
       this.applySettings();
       
       // Show a success message
       this.showMessage('Settings saved successfully');
   }
   
   resetSettings() {
       if (confirm('Are you sure you want to reset all settings to their default values?')) {
           // Create a new settings manager to get default values
           const defaultSettings = new SettingsManager().settings;
           
           // Apply defaults
           this.settings = {...defaultSettings};
           
           // Update the form
           this.populateSettingsForm();
           
           // Apply settings
           this.applySettings();
           
           // Save to storage
           this.saveSettings();
           
           // Show a success message
           this.showMessage('Settings have been reset to defaults');
       }
   }
   
   showSettingsPanel() {
       if (this.container) {
           this.container.classList.add('active');
       }
   }
   
   hideSettingsPanel() {
       if (this.container) {
           this.container.classList.remove('active');
       }
   }
   
   toggleSettingsPanel() {
       if (this.container) {
           this.container.classList.toggle('active');
       }
   }
   
   // Settings application
   applySettings() {
        // Apply theme
        const theme = this.settings.theme;
        const textColor = this.settings.textColor;
        const accentColor = this.settings.accentColor;
        const fontSize = this.settings.fontSize;
        
        // Apply theme globally
        document.body.className = `theme-${theme}`;
        
        // Define all CSS variables to update
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
            '--genesis-accent-color': accentColor,
            '--genesis-text-color': textColor,
            
            // Sizes
            '--genesis-font-size': `${fontSize}px`,
            
            // CSV Grid specific variables
            '--csv-grid-bg': theme === 'dark' ? '#1e1e1e' : '#ffffff',
            '--csv-grid-header-bg': theme === 'dark' ? '#252525' : '#f0f0f0',
            '--csv-grid-border': theme === 'dark' ? '#454545' : '#dddddd',
            '--csv-grid-text': theme === 'dark' ? '#f0f0f0' : '#333333',
            '--csv-grid-selected-bg': theme === 'dark' ? 'rgba(0, 120, 215, 0.2)' : 'rgba(0, 120, 215, 0.1)'
        };
        
        // Apply all CSS variables
        Object.entries(variables).forEach(([property, value]) => {
            document.documentElement.style.setProperty(property, value);
        });
        
        // Dispatch an event so other components can respond to settings changes
        this.dispatchEvent('settingsApplied', this.settings);
}
   
   applyTheme(theme = null) {
       const currentTheme = theme || this.settings.theme;
       
       // Update body class
       document.body.classList.remove('theme-dark', 'theme-light');
       document.body.classList.add(`theme-${currentTheme}`);
       
       // Update CSS variables
       document.documentElement.style.setProperty('--accent-color', this.settings.accentColor);
       document.documentElement.style.setProperty('--text-color', this.settings.textColor);
       
       // Set other theme-specific variables
       if (currentTheme === 'dark') {
           document.documentElement.style.setProperty('--bg-color', '#1e1e1e');
           document.documentElement.style.setProperty('--bg-light', '#252525');
           document.documentElement.style.setProperty('--bg-lighter', '#2d2d2d');
           document.documentElement.style.setProperty('--border-color', '#454545');
       } else {
           document.documentElement.style.setProperty('--bg-color', '#f0f0f0');
           document.documentElement.style.setProperty('--bg-light', '#e0e0e0');
           document.documentElement.style.setProperty('--bg-lighter', '#d0d0d0');
           document.documentElement.style.setProperty('--border-color', '#cccccc');
       }
   }
   
   // Storage methods
   saveSettings() {
       try {
           localStorage.setItem('genesis-settings', JSON.stringify(this.settings));
           return true;
       } catch (e) {
           console.error('Failed to save settings:', e);
           return false;
       }
   }
   
   loadSettings() {
       try {
           const storedSettings = localStorage.getItem('genesis-settings');
           if (storedSettings) {
               const parsedSettings = JSON.parse(storedSettings);
               // Merge with defaults to ensure all properties exist
               this.settings = {...this.settings, ...parsedSettings};
               return true;
           }
       } catch (e) {
           console.error('Failed to load settings:', e);
       }
       return false;
   }
   
   // Utility methods
   showMessage(message, type = 'info') {
       // This would integrate with your notification system
       console.log(`[${type}] ${message}`);
       
       // Create a simple toast notification if no system exists
       const toast = document.createElement('div');
       toast.className = `toast toast-${type}`;
       toast.textContent = message;
       
       document.body.appendChild(toast);
       
       // Remove after 3 seconds
       setTimeout(() => {
           toast.classList.add('toast-hiding');
           setTimeout(() => {
               document.body.removeChild(toast);
           }, 300);
       }, 3000);
   }
   
   dispatchEvent(name, detail) {
       const event = new CustomEvent(`settings-${name}`, { detail });
       document.dispatchEvent(event);
   }
   
   // Get a specific setting
   getSetting(name) {
       return this.settings[name];
   }
   
   // Update a specific setting
   updateSetting(name, value) {
       if (name in this.settings) {
           this.settings[name] = value;
           this.saveSettings();
           
           // Apply the setting if it's related to immediate visual changes
           if (['theme', 'accentColor', 'textColor', 'fontSize'].includes(name)) {
               this.applySettings();
           }
           
           return true;
       }
       return false;
   }
}