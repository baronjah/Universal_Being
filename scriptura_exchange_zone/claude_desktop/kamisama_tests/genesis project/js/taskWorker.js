// taskWorker.js
self.onmessage = function(e) {
    const { taskId, type, data, script } = e.data;
    
    try {
        // Start processing
        console.log(`Worker processing task ${taskId} of type ${type}`);
        
        let result;
        
        // Different task types
        if (script) {
            // Execute dynamic script
            result = executeScript(script, data);
        } else {
            // Handle built-in task types
            switch (type) {
                case 'processData':
                    result = processData(data);
                    break;
                case 'loadFile':
                    result = loadFile(data);
                    break;
                case 'parseCSV':
                    result = parseCSV(data);
                    break;
                default:
                    // Generic processing
                    result = { processed: true, data };
            }
        }
        
        // Send successful result
        self.postMessage({
            type: 'completed',
            taskId,
            result
        });
    } catch (error) {
        // Send error
        self.postMessage({
            type: 'error',
            taskId,
            error: error.toString()
        });
    }
};

/**
 * Execute a dynamic script
 * @param {string} script - Script to execute
 * @param {Object} data - Data for the script
 */
function executeScript(script, data) {
    // Create a function from the script
    const scriptFn = new Function('data', 'postProgress', script);
    
    // Execute with data and progress function
    return scriptFn(data, (progress) => {
        self.postMessage({
            type: 'progress',
            progress
        });
    });
}

/**
 * Process data (example function)
 */
function processData(data) {
    // Simulate processing
    const result = {};
    
    for (const key in data) {
        if (typeof data[key] === 'string') {
            result[key] = data[key].toUpperCase();
        } else if (typeof data[key] === 'number') {
            result[key] = data[key] * 2;
        } else {
            result[key] = data[key];
        }
    }
    
    return result;
}

/**
 * Load file (example function)
 */
function loadFile(data) {
    // In a worker, you can use fetch
    // This is async but simplified for the example
    return { fileLoaded: true, path: data.path };
}

/**
 * Parse CSV (example function)
 */
function parseCSV(data) {
    const lines = data.content.split('\n');
    const headers = lines[0].split(',');
    const rows = [];
    
    for (let i = 1; i < lines.length; i++) {
        if (!lines[i].trim()) continue;
        
        const values = lines[i].split(',');
        const row = {};
        
        headers.forEach((header, index) => {
            row[header.trim()] = values[index] ? values[index].trim() : '';
        });
        
        rows.push(row);
    }
    
    return { headers, rows };
}