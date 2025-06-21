/**
 * MemoryManager.js - Manages memory/cache for the application
 * Provides debugging and optimization capabilities
 */

class MemoryManager {
    constructor(options = {}) {
        // Cache storage
        this.cache = {};
        this.sessionStorage = {};
        this.persistentStorage = {};
        
        // Memory tracking
        this.memoryStats = {
            cacheSize: 0,
            sessionStorageSize: 0,
            persistentStorageSize: 0,
            history: []
        };
        
        // Cache settings
        this.cacheSettings = {
            maxSize: options.maxCacheSize || 50 * 1024 * 1024, // 50MB default
            cleanupInterval: options.cleanupInterval || 60000, // 1 minute
            ttl: options.ttl || 3600000 // 1 hour
        };
        
        // Set up periodic cleaning
        setInterval(() => this.cleanupCache(), this.cacheSettings.cleanupInterval);
        
        // Set up memory tracking
        setInterval(() => this.trackMemoryUsage(), 10000); // Every 10 seconds
        
        // Load persistent data from localStorage
        this._loadPersistentData();
    }
    
    /**
     * Store an item in cache
     * @param {string} key - Cache key
     * @param {*} value - Value to store
     * @param {Object} options - Cache options
     */
    store(key, value, options = {}) {
        // Normalize key
        const normalizedKey = this._normalizeKey(key);
        
        // Determine storage type
        const storage = options.persistent ? this.persistentStorage : 
                        options.session ? this.sessionStorage : this.cache;
        
        // Calculate size
        const valueSize = this._getObjectSize(value);
        
        // Check if we need to clean up before storing
        if (storage === this.cache && this.memoryStats.cacheSize + valueSize > this.cacheSettings.maxSize) {
            this.cleanupCache();
            
            // If still too big, don't store
            if (this.memoryStats.cacheSize + valueSize > this.cacheSettings.maxSize) {
                console.warn(`Cache item ${normalizedKey} is too large to store (${valueSize} bytes)`);
                return false;
            }
        }
        
        // Store the item
        storage[normalizedKey] = {
            data: value,
            size: valueSize,
            created: Date.now(),
            expires: options.ttl ? Date.now() + options.ttl : Date.now() + this.cacheSettings.ttl,
            metadata: options.metadata || {}
        };
        
// Update memory stats
if (storage === this.cache) {
    this.memoryStats.cacheSize += valueSize;
} else if (storage === this.sessionStorage) {
    this.memoryStats.sessionStorageSize += valueSize;
} else if (storage === this.persistentStorage) {
    this.memoryStats.persistentStorageSize += valueSize;
    this._savePersistentData();
}

return true;
}

/**
* Retrieve an item from cache
* @param {string} key - Cache key
* @param {Object} options - Retrieval options
* @returns {*} Cached value or null if not found
*/
retrieve(key, options = {}) {
// Normalize key
const normalizedKey = this._normalizeKey(key);

// Determine storage type
const storage = options.persistent ? this.persistentStorage : 
                options.session ? this.sessionStorage : this.cache;

// Check if the item exists
if (!storage[normalizedKey]) {
    return null;
}

const item = storage[normalizedKey];

// Check if the item has expired
if (item.expires < Date.now() && !options.ignoreExpiry) {
    this.remove(key, options);
    return null;
}

// Refresh expiry if auto-refresh is enabled
if (options.refreshTTL) {
    item.expires = Date.now() + (options.ttl || this.cacheSettings.ttl);
}

return item.data;
}

/**
* Remove an item from cache
* @param {string} key - Cache key
* @param {Object} options - Removal options
* @returns {boolean} True if removed, false if not found
*/
remove(key, options = {}) {
// Normalize key
const normalizedKey = this._normalizeKey(key);

// Determine storage type
const storage = options.persistent ? this.persistentStorage : 
                options.session ? this.sessionStorage : this.cache;

// Check if the item exists
if (!storage[normalizedKey]) {
    return false;
}

// Get the item size
const size = storage[normalizedKey].size;

// Remove the item
delete storage[normalizedKey];

// Update memory stats
if (storage === this.cache) {
    this.memoryStats.cacheSize -= size;
} else if (storage === this.sessionStorage) {
    this.memoryStats.sessionStorageSize -= size;
} else if (storage === this.persistentStorage) {
    this.memoryStats.persistentStorageSize -= size;
    this._savePersistentData();
}

return true;
}

/**
* Clean up expired cache items
* @returns {number} Number of items removed
*/
cleanupCache() {
const now = Date.now();
let removedCount = 0;

// Clean up main cache
Object.keys(this.cache).forEach(key => {
    if (this.cache[key].expires < now) {
        this.remove(key);
        removedCount++;
    }
});

// Clean up session storage
Object.keys(this.sessionStorage).forEach(key => {
    if (this.sessionStorage[key].expires < now) {
        this.remove(key, { session: true });
        removedCount++;
    }
});

return removedCount;
}

/**
* Track memory usage
* @private
*/
trackMemoryUsage() {
const memorySnapshot = {
    timestamp: Date.now(),
    cacheSize: this.memoryStats.cacheSize,
    sessionStorageSize: this.memoryStats.sessionStorageSize,
    persistentStorageSize: this.memoryStats.persistentStorageSize,
    totalItems: Object.keys(this.cache).length + 
                Object.keys(this.sessionStorage).length + 
                Object.keys(this.persistentStorage).length
};

// Add browser memory info if available
if (window.performance && window.performance.memory) {
    memorySnapshot.jsHeapSizeLimit = window.performance.memory.jsHeapSizeLimit;
    memorySnapshot.totalJSHeapSize = window.performance.memory.totalJSHeapSize;
    memorySnapshot.usedJSHeapSize = window.performance.memory.usedJSHeapSize;
}

// Keep history limited to last 100 entries
this.memoryStats.history.push(memorySnapshot);
if (this.memoryStats.history.length > 100) {
    this.memoryStats.history.shift();
}
}

/**
* Get memory usage statistics
* @returns {Object} Memory stats
*/
getMemoryStats() {
return {
    current: {
        cacheSize: this.formatBytes(this.memoryStats.cacheSize),
        sessionStorageSize: this.formatBytes(this.memoryStats.sessionStorageSize),
        persistentStorageSize: this.formatBytes(this.memoryStats.persistentStorageSize),
        totalCached: Object.keys(this.cache).length,
        totalSession: Object.keys(this.sessionStorage).length,
        totalPersistent: Object.keys(this.persistentStorage).length
    },
    history: this.memoryStats.history.map(snapshot => ({
        timestamp: new Date(snapshot.timestamp).toISOString(),
        cacheSize: this.formatBytes(snapshot.cacheSize),
        sessionStorageSize: this.formatBytes(snapshot.sessionStorageSize),
        persistentStorageSize: this.formatBytes(snapshot.persistentStorageSize),
        totalItems: snapshot.totalItems,
        jsHeapSizeLimit: snapshot.jsHeapSizeLimit ? this.formatBytes(snapshot.jsHeapSizeLimit) : 'N/A',
        totalJSHeapSize: snapshot.totalJSHeapSize ? this.formatBytes(snapshot.totalJSHeapSize) : 'N/A',
        usedJSHeapSize: snapshot.usedJSHeapSize ? this.formatBytes(snapshot.usedJSHeapSize) : 'N/A'
    })),
    limits: {
        maxCacheSize: this.formatBytes(this.cacheSettings.maxSize),
        cleanupInterval: `${this.cacheSettings.cleanupInterval / 1000}s`,
        defaultTTL: `${this.cacheSettings.ttl / 1000}s`
    }
};
}

/**
* Load persistent data from localStorage
* @private
*/
_loadPersistentData() {
try {
    const storedData = localStorage.getItem('genesis-persistent-cache');
    if (storedData) {
        const data = JSON.parse(storedData);
        this.persistentStorage = data.storage || {};
        this.memoryStats.persistentStorageSize = data.size || 0;
        console.log(`Loaded ${Object.keys(this.persistentStorage).length} items from persistent storage`);
    }
} catch (error) {
    console.error('Error loading persistent data:', error);
    this.persistentStorage = {};
    this.memoryStats.persistentStorageSize = 0;
}
}

/**
* Save persistent data to localStorage
* @private
*/
_savePersistentData() {
try {
    const dataToStore = {
        storage: this.persistentStorage,
        size: this.memoryStats.persistentStorageSize,
        updated: Date.now()
    };
    
    localStorage.setItem('genesis-persistent-cache', JSON.stringify(dataToStore));
} catch (error) {
    console.error('Error saving persistent data:', error);
    
    // If it's a quota error, try to clear some space
    if (error.name === 'QuotaExceededError') {
        this._handleStorageQuotaExceeded();
    }
}
}

/**
* Handle storage quota exceeded
* @private
*/
_handleStorageQuotaExceeded() {
console.warn('Storage quota exceeded, clearing old persistent data');

// Sort items by age
const items = Object.entries(this.persistentStorage)
    .map(([key, value]) => ({ key, created: value.created }))
    .sort((a, b) => a.created - b.created);

// Remove the oldest 25%
const toRemove = Math.ceil(items.length * 0.25);
items.slice(0, toRemove).forEach(item => {
    this.remove(item.key, { persistent: true });
});

// Try saving again
this._savePersistentData();
}

/**
* Normalize a cache key
* @param {string} key - Key to normalize
* @returns {string} Normalized key
* @private
*/
_normalizeKey(key) {
// Convert to string if not already
key = String(key);

// Remove special characters and spaces
return key.replace(/[^a-zA-Z0-9_.-]/g, '_').toLowerCase();
}

/**
* Get the size of an object in bytes (approximate)
* @param {*} obj - Object to measure
* @returns {number} Size in bytes
* @private
*/
_getObjectSize(obj) {
const objectList = [];
const stack = [obj];
let bytes = 0;

while (stack.length) {
    const value = stack.pop();
    
    if (typeof value === 'boolean') {
        bytes += 4;
    } else if (typeof value === 'string') {
        bytes += value.length * 2;
    } else if (typeof value === 'number') {
        bytes += 8;
    } else if (typeof value === 'object' && objectList.indexOf(value) === -1) {
        objectList.push(value);
        
        if (Array.isArray(value)) {
            for (let i = 0; i < value.length; i++) {
                stack.push(value[i]);
            }
        } else if (value !== null) {
            for (const key in value) {
                if (Object.prototype.hasOwnProperty.call(value, key)) {
                    bytes += key.length * 2;
                    stack.push(value[key]);
                }
            }
        }
    }
}

return bytes;
}

/**
* Format bytes to human-readable string
* @param {number} bytes - Bytes to format
* @returns {string} Formatted string
*/
formatBytes(bytes) {
if (bytes === 0) return '0 Bytes';

const k = 1024;
const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
const i = Math.floor(Math.log(bytes) / Math.log(k));

return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}
}

// Export the class
window.MemoryManager = MemoryManager;