/**
 * TaskManager.js - Manages background tasks and processes
 */

class TaskManager {
    constructor() {
        this.tasks = {};
        this.nextTaskId = 1;
        
        // UI elements
        this.taskListElement = null;
        
        // Stats
        this.stats = {
            completed: 0,
            failed: 0,
            total: 0
        };
    }
    
    /**
     * Initialize the Task Manager
     * @param {HTMLElement} container - Container for the task list UI
     */
    initialize(container) {
        console.log("🔄 Initializing Task Manager");
        
        // Create task list UI if container provided
        if (container) {
            this._createTaskListUI(container);
        }
        
        console.log("🔄 Task Manager initialized");
        return this;
    }
    
    /**
     * Create the task list UI
     * @param {HTMLElement} container - Container element
     * @private
     */
    _createTaskListUI(container) {
        // Create task list element
        this.taskListElement = document.createElement('div');
        this.taskListElement.className = 'genesis-task-list';
        
        // Create task list header
        const header = document.createElement('div');
        header.className = 'genesis-task-list-header';
        header.innerHTML = `
            <h3>Tasks</h3>
            <div class="genesis-task-stats">
                <span class="completed">0</span>/<span class="total">0</span> completed
            </div>
        `;
        
        // Create task list content
        const content = document.createElement('div');
        content.className = 'genesis-task-list-content';
        
        // Assemble UI
        this.taskListElement.appendChild(header);
        this.taskListElement.appendChild(content);
        container.appendChild(this.taskListElement);
    }
    
    /**
     * Create a new task
     * @param {Object} taskConfig - Task configuration
     * @returns {Object} Task object
     */
    createTask(taskConfig) {
        const taskId = `task-${this.nextTaskId++}`;
        
        // Create task object
        const task = {
            id: taskId,
            name: taskConfig.name || `Task ${taskId}`,
            description: taskConfig.description || '',
            status: 'pending',
            progress: 0,
            startTime: null,
            endTime: null,
            error: null,
            result: null,
            onProgress: taskConfig.onProgress,
            onComplete: taskConfig.onComplete,
            onError: taskConfig.onError,
            execute: taskConfig.execute,
            cancel: () => this.cancelTask(taskId)
        };
        
        // Add task to the list
        this.tasks[taskId] = task;
        this.stats.total++;
        
        // Update UI
        this._updateTaskListUI();
        this._createTaskUI(task);
        
        return task;
    }
    
    /**
     * Start a task
     * @param {string} taskId - Task ID
     */
    startTask(taskId) {
        const task = this.tasks[taskId];
        if (!task || task.status !== 'pending') return;
        
        console.log(`Starting task: ${task.name}`);
        
        // Update task state
        task.status = 'running';
        task.startTime = new Date();
        
        // Update UI
        this._updateTaskUI(task);
        
        // Execute the task asynchronously
        setTimeout(async () => {
            try {
                // Execute the task function
                if (typeof task.execute === 'function') {
                    const result = await task.execute((progress) => {
                        // Update progress
                        task.progress = Math.min(Math.max(0, progress), 100);
                        this._updateTaskUI(task);
                        
                        // Call progress callback if provided
                        if (typeof task.onProgress === 'function') {
                            task.onProgress(task.progress);
                        }
                    });
                    
                    // Task completed successfully
                    this.completeTask(taskId, result);
                } else {
                    throw new Error('Task has no execute function');
                }
            } catch (error) {
                // Task failed
                this.failTask(taskId, error);
            }
        }, 0);
    }
    
    /**
     * Mark a task as completed
     * @param {string} taskId - Task ID
     * @param {*} result - Task result
     */
    completeTask(taskId, result) {
        const task = this.tasks[taskId];
        if (!task || task.status === 'completed' || task.status === 'failed') return;
        
        console.log(`Task completed: ${task.name}`);
        
        // Update task state
        task.status = 'completed';
        task.progress = 100;
        task.endTime = new Date();
        task.result = result;
        
        // Update stats
        this.stats.completed++;
        
        // Update UI
        this._updateTaskUI(task);
        this._updateTaskListUI();
        
        // Call complete callback if provided
        if (typeof task.onComplete === 'function') {
            task.onComplete(result);
        }
    }
    
    /**
     * Mark a task as failed
     * @param {string} taskId - Task ID
     * @param {Error} error - Error object
     */
    failTask(taskId, error) {
        const task = this.tasks[taskId];
        if (!task || task.status === 'completed' || task.status === 'failed') return;
        
        console.error(`Task failed: ${task.name}`, error);
        
        // Update task state
        task.status = 'failed';
        task.endTime = new Date();
        task.error = error;
        
        // Update stats
        this.stats.failed++;
        
        // Update UI
        this._updateTaskUI(task);
        this._updateTaskListUI();
        
        // Call error callback if provided
        if (typeof task.onError === 'function') {
            task.onError(error);
        }
    }
    
    /**
     * Cancel a task
     * @param {string} taskId - Task ID
     */
    cancelTask(taskId) {
        const task = this.tasks[taskId];
        if (!task || task.status !== 'running') return;
        
        console.log(`Cancelling task: ${task.name}`);
        
        // Update task state
        task.status = 'cancelled';
        task.endTime = new Date();
        
        // Update UI
        this._updateTaskUI(task);
    }
    
    /**
     * Get all tasks
     * @returns {Object} Tasks object
     */
    getAllTasks() {
        return {...this.tasks};
    }
    
    /**
     * Get a specific task
     * @param {string} taskId - Task ID
     * @returns {Object} Task object
     */
    getTask(taskId) {
        return this.tasks[taskId];
    }
    
    /**
     * Remove a completed or failed task
     * @param {string} taskId - Task ID
     */
    removeTask(taskId) {
        const task = this.tasks[taskId];
        if (!task) return;
        
        // Only remove completed, failed, or cancelled tasks
        if (['completed', 'failed', 'cancelled'].includes(task.status)) {
            delete this.tasks[taskId];
            
            // Remove from UI
            const taskElement = document.getElementById(`task-element-${taskId}`);
            if (taskElement) {
                taskElement.remove();
            }
        }
    }
    
    /**
     * Update the task list UI
     * @private
     */
    _updateTaskListUI() {
        // Update stats
        if (this.taskListElement) {
            const statsElement = this.taskListElement.querySelector('.genesis-task-stats');
            if (statsElement) {
                statsElement.querySelector('.completed').textContent = this.stats.completed;
                statsElement.querySelector('.total').textContent = this.stats.total;
            }
        }
    }
    
    /**
     * Create UI for a task
     * @param {Object} task - Task object
     * @private
     */
    _createTaskUI(task) {
        if (!this.taskListElement) return;
        
        const content = this.taskListElement.querySelector('.genesis-task-list-content');
        if (!content) return;
        
        // Create task element
        const taskElement = document.createElement('div');
        taskElement.id = `task-element-${task.id}`;
        taskElement.className = `genesis-task-item status-${task.status}`;
        taskElement.innerHTML = `
            <div class="task-header">
                <div class="task-name">${task.name}</div>
                <div class="task-status">${task.status}</div>
            </div>
            <div class="task-progress-bar">
                <div class="task-progress" style="width: ${task.progress}%"></div>
            </div>
            <div class="task-details">
                <div class="task-description">${task.description}</div>
                <div class="task-controls">
                    <button class="task-cancel-btn" ${task.status !== 'running' ? 'disabled' : ''}>Cancel</button>
                    <button class="task-remove-btn" ${!['completed', 'failed', 'cancelled'].includes(task.status) ? 'disabled' : ''}>Remove</button>
                </div>
            </div>
        `;
        
        // Add event listeners
        const cancelBtn = taskElement.querySelector('.task-cancel-btn');
        if (cancelBtn) {
            cancelBtn.addEventListener('click', () => this.cancelTask(task.id));
        }
        
        const removeBtn = taskElement.querySelector('.task-remove-btn');
        if (removeBtn) {
            removeBtn.addEventListener('click', () => this.removeTask(task.id));
        }
        
        // Add to content
        content.appendChild(taskElement);
    }
    
    /**
     * Update UI for a task
     * @param {Object} task - Task object
     * @private
     */
    _updateTaskUI(task) {
        if (!this.taskListElement) return;
        
        const taskElement = document.getElementById(`task-element-${task.id}`);
        if (!taskElement) {
            // Create UI if it doesn't exist
            return this._createTaskUI(task);
        }
        
        // Update class
        taskElement.className = `genesis-task-item status-${task.status}`;
        
        // Update status
        const statusElement = taskElement.querySelector('.task-status');
        if (statusElement) {
            statusElement.textContent = task.status;
        }
        
        // Update progress
        const progressElement = taskElement.querySelector('.task-progress');
        if (progressElement) {
            progressElement.style.width = `${task.progress}%`;
        }
        
        // Update buttons
        const cancelBtn = taskElement.querySelector('.task-cancel-btn');
        if (cancelBtn) {
            cancelBtn.disabled = task.status !== 'running';
        }
        
        const removeBtn = taskElement.querySelector('.task-remove-btn');
        if (removeBtn) {
            removeBtn.disabled = !['completed', 'failed', 'cancelled'].includes(task.status);
        }
    }
 }
 
 // Export the class
 window.TaskManager = TaskManager;