/**
 * ThreadPoolManager.js - Manages web workers for concurrent task processing
 * Inspired by GDScript thread pool implementation
 */

class ThreadPoolManager {
    constructor(options = {}) {
        // Configuration
        this.maxWorkers = options.maxWorkers || (navigator.hardwareConcurrency || 4);
        this.taskTimeout = options.taskTimeout || 5000; // 5 seconds
        
        // Thread tracking
        this.workers = {};
        this.activeWorkers = 0;
        this.taskQueue = [];
        this.completedTasks = {};
        
        // Mutex-like locks (using simple flags since JS is single-threaded)
        this.isProcessingQueue = false;
        
        // Event handling
        this.eventHandlers = {
            taskCompleted: [],
            taskFailed: [],
            workerCreated: [],
            queueUpdated: []
        };
        
        this.initialize();
    }
    
    initialize() {
        console.log(`Initializing ThreadPoolManager with ${this.maxWorkers} workers`);
        
        // Create a basic worker script if needed
        this._ensureWorkerScript();
        
        // Set up worker pool
        for (let i = 0; i < this.maxWorkers; i++) {
            this.workers[i] = {
                worker: null,
                task: null,
                startTime: 0,
                status: "idle"
            };
        }
        
        // Set up timeout checking
        setInterval(() => this.checkTimeouts(), 1000);
    }
    
    /**
     * Add a task to the queue
     * @param {Object} taskData - Task configuration
     */
    addTask(taskData) {
        const task = {
            id: taskData.id || `task_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
            type: taskData.type || 'generic',
            data: taskData.data || {},
            priority: taskData.priority || 0,
            script: taskData.script || null,
            createdAt: Date.now()
        };
        
        // Add to queue based on priority
        const insertIndex = this.taskQueue.findIndex(t => t.priority < task.priority);
        if (insertIndex === -1) {
            this.taskQueue.push(task);
        } else {
            this.taskQueue.splice(insertIndex, 0, task);
        }
        
        // Trigger event
        this._triggerEvent('queueUpdated', { queue: this.taskQueue });
        
        // Process queue
        this.processQueue();
        
        return task.id;
    }
    
    /**
     * Process tasks in the queue
     */
    processQueue() {
        // Single-threaded mutex simulation
        if (this.isProcessingQueue) return;
        this.isProcessingQueue = true;
        
        try {
            while (this.taskQueue.length > 0) {
                const availableWorker = this._findAvailableWorker();
                if (availableWorker === -1) break;
                
                const task = this.taskQueue.shift();
                this._startTask(availableWorker, task);
                
                // Trigger event
                this._triggerEvent('queueUpdated', { queue: this.taskQueue });
            }
        } finally {
            this.isProcessingQueue = false;
        }
    }
    
    /**
     * Find an available worker
     * @returns {number} Worker ID or -1 if none available
     * @private
     */
    _findAvailableWorker() {
        for (const workerId in this.workers) {
            if (this.workers[workerId].status === "idle") {
                return parseInt(workerId);
            }
        }
        return -1;
    }
    
    /**
     * Start a task on a specific worker
     * @param {number} workerId - Worker ID
     * @param {Object} task - Task data
     * @private
     */
    _startTask(workerId, task) {
        // Create new worker if needed
        if (!this.workers[workerId].worker) {
            this.workers[workerId].worker = new Worker('js/taskWorker.js');
            
            // Set up message handling
            this.workers[workerId].worker.onmessage = (e) => {
                this._handleWorkerMessage(workerId, e.data);
            };
            
            this.workers[workerId].worker.onerror = (error) => {
                this._handleWorkerError(workerId, error);
            };
            
            // Trigger event
            this._triggerEvent('workerCreated', { workerId });
        }
        
        // Update worker state
        this.workers[workerId].task = task;
        this.workers[workerId].startTime = Date.now();
        this.workers[workerId].status = "running";
        this.activeWorkers++;
        
        // Send the task to the worker
        this.workers[workerId].worker.postMessage({
            taskId: task.id,
            type: task.type,
            data: task.data,
            script: task.script
        });
        
        console.log(`Started task ${task.id} on worker ${workerId}`);
    }
    
    /**
     * Handle completed message from worker
     * @param {number} workerId - Worker ID
     * @param {Object} message - Message data
     * @private
     */
    _handleWorkerMessage(workerId, message) {
        const worker = this.workers[workerId];
        
        if (!worker || !worker.task) {
            console.warn(`Received message from worker ${workerId} but no task is registered`);
            return;
        }
        
        const task = worker.task;
        
        // Handle different message types
        if (message.type === 'completed') {
            // Store result
            this.completedTasks[task.id] = {
                result: message.result,
                task: task,
                completedAt: Date.now(),
                duration: Date.now() - worker.startTime
            };
            
            // Trigger event
            this._triggerEvent('taskCompleted', { 
                taskId: task.id, 
                result: message.result,
                task: task,
                duration: Date.now() - worker.startTime
            });
            
            console.log(`Task ${task.id} completed in ${Date.now() - worker.startTime}ms`);
        } else if (message.type === 'progress') {
            // Could handle progress updates here
            console.log(`Task ${task.id} progress: ${message.progress}%`);
        } else if (message.type === 'error') {
            // Trigger event
            this._triggerEvent('taskFailed', { 
                taskId: task.id, 
                error: message.error,
                task: task
            });
            
            console.error(`Task ${task.id} failed: ${message.error}`);
        }
        
        if (message.type === 'completed' || message.type === 'error') {
            // Clean up worker
            this._cleanupWorker(workerId);
        }
    }
    
    /**
     * Handle worker error
     * @param {number} workerId - Worker ID
     * @param {Error} error - Error object
     * @private
     */
    _handleWorkerError(workerId, error) {
        const worker = this.workers[workerId];
        
        if (!worker || !worker.task) {
            console.warn(`Received error from worker ${workerId} but no task is registered`);
            return;
        }
        
        const task = worker.task;
        
        // Trigger event
        this._triggerEvent('taskFailed', { 
            taskId: task.id, 
            error: error.message,
            task: task
        });
        
        console.error(`Worker ${workerId} error:`, error);
        
        // Clean up worker
        this._cleanupWorker(workerId);
    }
    
    /**
     * Clean up a worker after task completion or error
     * @param {number} workerId - Worker ID
     * @private
     */
    _cleanupWorker(workerId) {
        if (!this.workers[workerId]) return;
        
        // Update state
        this.workers[workerId].task = null;
        this.workers[workerId].status = "idle";
        this.activeWorkers--;
        
        // Process queue for any pending tasks
        this.processQueue();
    }
    
    /**
     * Check for task timeouts
     */
    checkTimeouts() {
        const now = Date.now();
        
        for (const workerId in this.workers) {
            const worker = this.workers[workerId];
            
            if (worker.status === "running") {
                const duration = now - worker.startTime;
                
                if (duration > this.taskTimeout) {
                    this._handleTaskTimeout(parseInt(workerId));
                }
            }
        }
    }
    
    /**
     * Handle a task timeout
     * @param {number} workerId - Worker ID
     * @private
     */
    _handleTaskTimeout(workerId) {
        const worker = this.workers[workerId];
        
        if (!worker || !worker.task) return;
        
        const task = worker.task;
        
        console.warn(`Task ${task.id} timed out after ${this.taskTimeout}ms`);
        
        // Terminate the worker and create a new one
        if (worker.worker) {
            worker.worker.terminate();
            worker.worker = null;
        }
        
        // Trigger event
        this._triggerEvent('taskFailed', { 
            taskId: task.id, 
            error: "Task timed out",
            task: task
        });
        
        // Clean up
        this._cleanupWorker(workerId);
    }
    
    /**
     * Event handling
     * @param {string} eventName - Event name
     * @param {function} handler - Event handler
     */
    on(eventName, handler) {
        if (this.eventHandlers[eventName]) {
            this.eventHandlers[eventName].push(handler);
        }
        return this;
    }
    
    /**
     * Trigger an event
     * @param {string} eventName - Event name
     * @param {Object} data - Event data
     * @private
     */
    _triggerEvent(eventName, data) {
        if (this.eventHandlers[eventName]) {
            this.eventHandlers[eventName].forEach(handler => {
                try {
                    handler(data);
                } catch (error) {
                    console.error(`Error in ${eventName} handler:`, error);
                }
            });
        }
    }
    
    /**
     * Ensure the worker script exists
     * @private
     */
    _ensureWorkerScript() {
        // In a real implementation, you would check if the file exists
        // Here we'll just log a reminder
        console.log("Make sure taskWorker.js exists in your js directory");
    }
    
    /**
     * Get stats about the thread pool
     * @returns {Object} Stats object
     */
    getStats() {
        return {
            maxWorkers: this.maxWorkers,
            activeWorkers: this.activeWorkers,
            queueLength: this.taskQueue.length,
            completedTasks: Object.keys(this.completedTasks).length,
            workerStates: Object.fromEntries(
                Object.entries(this.workers).map(([id, worker]) => [
                    id, 
                    {
                        status: worker.status,
                        taskId: worker.task?.id || null,
                        taskType: worker.task?.type || null,
                        runningTime: worker.status === 'running' ? Date.now() - worker.startTime : 0
                    }
                ])
            )
        };
    }
}

// Export the class
window.ThreadPoolManager = ThreadPoolManager;