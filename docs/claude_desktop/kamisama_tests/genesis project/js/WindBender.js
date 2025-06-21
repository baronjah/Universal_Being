/**
 * WindBender.js - Fast dynamic resource loading system
 * 
 * This component allows for quick loading of scripts, styles, and data files
 * on demand without needing to reload the page.
 */

class WindBender {
    constructor() {
        this.loadedResources = {
            scripts: {},
            styles: {},
            data: {}
        };
        
        this.pendingLoads = {};
        this.loadQueue = [];
        this.isProcessingQueue = false;
        this.maxConcurrentLoads = 5;
        
        // Track load times for performance monitoring
        this.loadTimes = [];
    }
    
    /**
     * Load a JavaScript file dynamically
     * @param {string} url - URL of the script
     * @param {boolean} executeImmediately - Whether to execute the script immediately
     * @returns {Promise} Promise that resolves when the script is loaded
     */
    loadScript(url, executeImmediately = true) {
        // If already loaded, return existing promise
        if (this.loadedResources.scripts[url]) {
            return Promise.resolve(this.loadedResources.scripts[url]);
        }
        
        // If already pending, return the pending promise
        if (this.pendingLoads[url]) {
            return this.pendingLoads[url];
        }
        
        // Create a new promise for this load
        const loadPromise = new Promise((resolve, reject) => {
            const startTime = performance.now();
            
            const script = document.createElement('script');
            script.src = url;
            script.async = true;
            
            script.onload = () => {
                const loadTime = performance.now() - startTime;
                this.loadTimes.push({ url, type: 'script', time: loadTime });
                console.log(`🌪️ Loaded script: ${url} (${loadTime.toFixed(2)}ms)`);
                
                this.loadedResources.scripts[url] = script;
                delete this.pendingLoads[url];
                resolve(script);
            };
            
            script.onerror = (error) => {
                console.error(`Failed to load script: ${url}`, error);
                delete this.pendingLoads[url];
                reject(error);
            };
            
            if (executeImmediately) {
                document.head.appendChild(script);
            }
        });
        
        this.pendingLoads[url] = loadPromise;
        return loadPromise;
    }
    
    /**
     * Load a CSS file dynamically
     * @param {string} url - URL of the stylesheet
     * @returns {Promise} Promise that resolves when the stylesheet is loaded
     */
    loadStyle(url) {
        // If already loaded, return existing promise
        if (this.loadedResources.styles[url]) {
            return Promise.resolve(this.loadedResources.styles[url]);
        }
        
        // If already pending, return the pending promise
        if (this.pendingLoads[url]) {
            return this.pendingLoads[url];
        }
        
        // Create a new promise for this load
        const loadPromise = new Promise((resolve, reject) => {
            const startTime = performance.now();
            
            const link = document.createElement('link');
            link.rel = 'stylesheet';
            link.href = url;
            
            link.onload = () => {
                const loadTime = performance.now() - startTime;
                this.loadTimes.push({ url, type: 'style', time: loadTime });
                console.log(`🌪️ Loaded style: ${url} (${loadTime.toFixed(2)}ms)`);
                
                this.loadedResources.styles[url] = link;
                delete this.pendingLoads[url];
                resolve(link);
            };
            
            link.onerror = (error) => {
                console.error(`Failed to load style: ${url}`, error);
                delete this.pendingLoads[url];
                reject(error);
            };
            
            document.head.appendChild(link);
        });
        
        this.pendingLoads[url] = loadPromise;
        return loadPromise;
    }
    
    /**
     * Load data from a URL (JSON, CSV, etc.)
     * @param {string} url - URL of the data file
     * @param {string} dataType - Type of data ('json', 'csv', 'text')
     * @returns {Promise} Promise that resolves with the loaded data
     */
    async loadData(url, dataType = 'json') {
        // If already loaded, return existing data
        if (this.loadedResources.data[url]) {
            return Promise.resolve(this.loadedResources.data[url]);
        }
        
        // If already pending, return the pending promise
        if (this.pendingLoads[url]) {
            return this.pendingLoads[url];
        }
        
        // Create a new promise for this load
        const loadPromise = new Promise(async (resolve, reject) => {
            const startTime = performance.now();
            
            try {
                const response = await fetch(url);
                
                if (!response.ok) {
                    throw new Error(`Failed to load data: ${response.status} ${response.statusText}`);
                }
                
                let data;
                
                switch (dataType.toLowerCase()) {
                    case 'json':
                        data = await response.json();
                        break;
                    case 'csv':
                        // If Papa Parse is available, use it
                        if (window.Papa) {
                            const text = await response.text();
                            data = window.Papa.parse(text, { header: true, skipEmptyLines: true });
                        } else {
                            // Basic CSV parsing if Papa Parse is not available
                            const text = await response.text();
                            data = this._parseCSV(text);
                        }
                        break;
                    case 'text':
                    default:
                        data = await response.text();
                        break;
                }
                
                const loadTime = performance.now() - startTime;
                this.loadTimes.push({ url, type: 'data', time: loadTime });
                console.log(`🌪️ Loaded data: ${url} (${loadTime.toFixed(2)}ms)`);
                
                this.loadedResources.data[url] = data;
                delete this.pendingLoads[url];
                resolve(data);
            } catch (error) {
                console.error(`Failed to load data: ${url}`, error);
                delete this.pendingLoads[url];
                reject(error);
            }
        });
        
        this.pendingLoads[url] = loadPromise;
        return loadPromise;
    }
    
    /**
     * Add resources to the load queue
     * @param {Array} resources - Array of resource objects to load
     * @returns {Promise} Promise that resolves when all resources are loaded
     */
    queueResources(resources) {
        // Add resources to the queue
        this.loadQueue.push(...resources);
        
        // Start processing the queue if not already doing so
        if (!this.isProcessingQueue) {
            this._processQueue();
        }
        
        // Return a promise that resolves when all these resources are loaded
        return Promise.all(resources.map(resource => {
            const { url, type } = resource;
            
            switch (type) {
                case 'script':
                    return this.loadScript(url);
                case 'style':
                    return this.loadStyle(url);
                case 'data':
                    return this.loadData(url, resource.dataType || 'json');
                default:
                    return Promise.reject(new Error(`Unknown resource type: ${type}`));
            }
        }));
    }
    
    /**
     * Process the load queue
     * @private
     */
    async _processQueue() {
        if (this.loadQueue.length === 0) {
            this.isProcessingQueue = false;
            return;
        }
        
        this.isProcessingQueue = true;
        
        // Calculate how many more resources we can load concurrently
        const currentlyLoading = Object.keys(this.pendingLoads).length;
        const availableSlots = Math.max(0, this.maxConcurrentLoads - currentlyLoading);
        
        // Load up to availableSlots resources from the queue
        const resourcesToLoad = this.loadQueue.splice(0, availableSlots);
        
        // Start loading each resource
        const loadPromises = resourcesToLoad.map(resource => {
            const { url, type } = resource;
            
            switch (type) {
                case 'script':
                    return this.loadScript(url);
                case 'style':
                    return this.loadStyle(url);
                case 'data':
                    return this.loadData(url, resource.dataType || 'json');
                default:
                    return Promise.reject(new Error(`Unknown resource type: ${type}`));
            }
        });
        
        // Wait for the current batch to finish loading
        await Promise.allSettled(loadPromises);
        
        // Continue processing the queue
        this._processQueue();
    }
    
    /**
     * Load a module dynamically using ES6 import()
     * @param {string} url - URL of the module
     * @returns {Promise} Promise that resolves with the loaded module
     */
    async loadModule(url) {
        try {
            const startTime = performance.now();
            const module = await import(url);
            
            const loadTime = performance.now() - startTime;
            this.loadTimes.push({ url, type: 'module', time: loadTime });
            console.log(`🌪️ Loaded module: ${url} (${loadTime.toFixed(2)}ms)`);
            
            return module;
        } catch (error) {
            console.error(`Failed to load module: ${url}`, error);
            throw error;
        }
    }
    
    /**
     * Load multiple resources in parallel
     * @param {Array} resources - Array of resource URLs to load
     * @returns {Promise} Promise that resolves when all resources are loaded
     */
    loadBundle(resources) {
        const promises = resources.map(resource => {
            if (typeof resource === 'string') {
                // Determine type from extension
                const extension = resource.split('.').pop().toLowerCase();
                
                switch (extension) {
                    case 'js':
                        return this.loadScript(resource);
                    case 'css':
                        return this.loadStyle(resource);
                    case 'json':
                        return this.loadData(resource, 'json');
                    case 'csv':
                        return this.loadData(resource, 'csv');
                    default:
                        return this.loadData(resource, 'text');
                }
            } else {
                // Resource is an object with type and url
                const { url, type, dataType } = resource;
                
                switch (type) {
                    case 'script':
                        return this.loadScript(url);
                    case 'style':
                        return this.loadStyle(url);
                    case 'data':
                        return this.loadData(url, dataType || 'json');
                    case 'module':
                        return this.loadModule(url);
                    default:
                        return Promise.reject(new Error(`Unknown resource type: ${type}`));
                }
            }
        });
        
        return Promise.all(promises);
    }
    
    /**
     * Simple CSV parser
     * @param {string} text - CSV text content
     * @returns {Object} Parsed CSV data with headers and rows
     * @private
     */
    _parseCSV(text) {
        const lines = text.split('\n');
        const headers = lines[0].split(',').map(header => header.trim());
        
        const rows = lines.slice(1)
            .filter(line => line.trim()) // Skip empty lines
            .map(line => {
                const values = line.split(',');
                const row = {};
                
                headers.forEach((header, index) => {
                    row[header] = values[index] ? values[index].trim() : '';
                });
                
                return row;
            });
        
        return { headers, rows, data: rows };
    }
    
    /**
     * Get performance stats for loaded resources
     * @returns {Object} Performance statistics
     */
    getPerformanceStats() {
        const stats = {
            totalResources: this.loadTimes.length,
            totalLoadTime: this.loadTimes.reduce((sum, item) => sum + item.time, 0),
            averageLoadTime: 0,
            fastestLoad: { url: '', time: Infinity },
            slowestLoad: { url: '', time: 0 },
            resourcesByType: {}
        };
        
        // Calculate average load time
        if (stats.totalResources > 0) {
            stats.averageLoadTime = stats.totalLoadTime / stats.totalResources;
        }
        
        // Find fastest and slowest loads
        this.loadTimes.forEach(item => {
            if (item.time < stats.fastestLoad.time) {
                stats.fastestLoad = { url: item.url, time: item.time };
            }
            
            if (item.time > stats.slowestLoad.time) {
                stats.slowestLoad = { url: item.url, time: item.time };
            }
            
            // Count resources by type
            stats.resourcesByType[item.type] = (stats.resourcesByType[item.type] || 0) + 1;
        });
        
        return stats;
    }
}

// Export the class
window.WindBender = WindBender;