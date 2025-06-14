/**
 * DynamicControlPanel.js - A unified control panel for the entire system
 * 
 * This component creates a dynamic, customizable control panel that integrates
 * controls from multiple components in a unified interface.
 */

class DynamicControlPanel {
    constructor(options = {}) {
        this.container = options.container || this._createContainer();
        this.panels = [];
        this.activePanel = null;
        this.controlGroups = {};
        
        // Quick access buttons
        this.quickAccessButtons = [];
        
        // Control panel state
        this.isExpanded = true;
        this.isMinimized = false;
        
        // Initialize the UI
        this._initializeUI();
    }
    
    /**
     * Create the control panel container if not provided
     * @private
     */
    _createContainer() {
        const container = document.createElement('div');
        container.id = 'dynamic-control-panel';
        container.className = 'dynamic-control-panel';
        document.body.appendChild(container);
        return container;
    }
    
    /**
     * Initialize the UI of the control panel
     * @private
     */
    _initializeUI() {
        // Create header
        const header = document.createElement('div');
        header.className = 'control-panel-header';
        header.innerHTML = `
            <div class="control-panel-title">
                <i class="fas fa-solar-panel"></i>
                <span>Control Panel</span>
            </div>
            <div class="control-panel-actions">
                <button class="control-panel-minimize" title="Minimize">
                    <i class="fas fa-window-minimize"></i>
                </button>
                <button class="control-panel-toggle" title="Toggle Panel">
                    <i class="fas fa-chevron-left"></i>
                </button>
            </div>
        `;
        
        // Create quick access bar
        const quickAccessBar = document.createElement('div');
        quickAccessBar.className = 'quick-access-bar';
        
        // Create panels container
        const panelsContainer = document.createElement('div');
        panelsContainer.className = 'control-panel-panels';
        
        // Add elements to container
        this.container.appendChild(header);
        this.container.appendChild(quickAccessBar);
        this.container.appendChild(panelsContainer);
        
        // Store references
        this.header = header;
        this.quickAccessBar = quickAccessBar;
        this.panelsContainer = panelsContainer;
        
        // Setup event handlers
        this._setupEventHandlers();
    }
    
    /**
     * Setup event handlers for the control panel
     * @private
     */
    _setupEventHandlers() {
        // Toggle panel expansion
        const toggleBtn = this.header.querySelector('.control-panel-toggle');
        toggleBtn.addEventListener('click', () => this.toggleExpansion());
        
        // Minimize/restore panel
        const minimizeBtn = this.header.querySelector('.control-panel-minimize');
        minimizeBtn.addEventListener('click', () => this.toggleMinimize());
        
        // Make the panel draggable
        this._makeDraggable(this.container, this.header);
    }
    
    /**
     * Make an element draggable by a handle
     * @param {HTMLElement} element - Element to make draggable
     * @param {HTMLElement} handle - Element to use as drag handle
     * @private
     */
    _makeDraggable(element, handle) {
        let offsetX, offsetY;
        
        handle.style.cursor = 'move';
        
        const onMouseDown = (e) => {
            // Don't drag if minimized
            if (this.isMinimized) return;
            
            e.preventDefault();
            
            // Get the initial mouse cursor position
            offsetX = e.clientX - element.offsetLeft;
            offsetY = e.clientY - element.offsetTop;
            
            // Add event listeners for dragging
            document.addEventListener('mousemove', onMouseMove);
            document.addEventListener('mouseup', onMouseUp);
        };
        
        const onMouseMove = (e) => {
            e.preventDefault();
            
            // Calculate the new position
            const x = e.clientX - offsetX;
            const y = e.clientY - offsetY;
            
            // Set the element position
            element.style.left = `${x}px`;
            element.style.top = `${y}px`;
        };
        
        const onMouseUp = () => {
            // Remove event listeners for dragging
            document.removeEventListener('mousemove', onMouseMove);
            document.removeEventListener('mouseup', onMouseUp);
        };
        
        // Attach the mousedown event
        handle.addEventListener('mousedown', onMouseDown);
    }
    
    /**
     * Toggle the expansion state of the control panel
     */
    toggleExpansion() {
        this.isExpanded = !this.isExpanded;
        
        // Update UI
        this.container.classList.toggle('collapsed', !this.isExpanded);
        
        // Update toggle button icon
        const toggleIcon = this.header.querySelector('.control-panel-toggle i');
        toggleIcon.className = this.isExpanded ? 'fas fa-chevron-left' : 'fas fa-chevron-right';
    }
    
    /**
     * Toggle the minimize state of the control panel
     */
    toggleMinimize() {
        this.isMinimized = !this.isMinimized;
        
        // Update UI
        this.container.classList.toggle('minimized', this.isMinimized);
        
        // Update minimize button icon
        const minimizeIcon = this.header.querySelector('.control-panel-minimize i');
        minimizeIcon.className = this.isMinimized ? 'fas fa-window-restore' : 'fas fa-window-minimize';
    }
    
    /**
     * Add a panel to the control panel
     * @param {string} id - Panel ID
     * @param {string} title - Panel title
     * @param {string} icon - Panel icon class (FontAwesome)
     * @returns {HTMLElement} The panel content element
     */
    addPanel(id, title, icon) {
        // Create panel
        const panel = document.createElement('div');
        panel.className = 'control-panel-panel';
        panel.dataset.panelId = id;
        
        // Create panel header
        const panelHeader = document.createElement('div');
        panelHeader.className = 'panel-header';
        panelHeader.innerHTML = `
            <div class="panel-title">
                <i class="${icon}"></i>
                <span>${title}</span>
            </div>
            <div class="panel-actions">
                <button class="panel-collapse" title="Collapse Panel">
                    <i class="fas fa-chevron-up"></i>
                </button>
            </div>
        `;
        
        // Create panel content
        const panelContent = document.createElement('div');
        panelContent.className = 'panel-content';
        
        // Add to panel
        panel.appendChild(panelHeader);
        panel.appendChild(panelContent);
        
        // Add to panels container
        this.panelsContainer.appendChild(panel);
        
        // Add quick access button
        this.addQuickAccessButton(id, title, icon);
        
        // Setup panel event handlers
        this._setupPanelEventHandlers(panel);
        
        // Add to panels array
        this.panels.push({
            id,
            element: panel,
            contentElement: panelContent,
            isCollapsed: false
        });
        
        // Activate this panel
        this.activatePanel(id);
        
        return panelContent;
    }
    
    /**
     * Setup event handlers for a panel
     * @param {HTMLElement} panel - Panel element
     * @private
     */
    _setupPanelEventHandlers(panel) {
        // Collapse/expand panel
        const collapseBtn = panel.querySelector('.panel-collapse');
        collapseBtn.addEventListener('click', () => {
            const panelId = panel.dataset.panelId;
            this.togglePanelCollapse(panelId);
        });
        
        // Activate panel on click
        panel.addEventListener('click', () => {
            const panelId = panel.dataset.panelId;
            this.activatePanel(panelId);
        });
    }
    
    /**
     * Toggle the collapse state of a panel
     * @param {string} panelId - Panel ID
     */
    togglePanelCollapse(panelId) {
        const panel = this.panels.find(p => p.id === panelId);
        if (!panel) return;
        
        panel.isCollapsed = !panel.isCollapsed;
        
        // Update UI
        panel.element.classList.toggle('collapsed', panel.isCollapsed);
        
        // Update collapse button icon
        const collapseIcon = panel.element.querySelector('.panel-collapse i');
        collapseIcon.className = panel.isCollapsed ? 'fas fa-chevron-down' : 'fas fa-chevron-up';
    }
    
    /**
     * Activate a panel
     * @param {string} panelId - Panel ID
     */
    activatePanel(panelId) {
        // Deactivate current active panel
        if (this.activePanel) {
            const prevPanel = this.panels.find(p => p.id === this.activePanel);
            if (prevPanel) {
                prevPanel.element.classList.remove('active');
            }
        }
        
        // Activate new panel
        const panel = this.panels.find(p => p.id === panelId);
        if (panel) {
            panel.element.classList.add('active');
            this.activePanel = panelId;
        }
    }
    
    /**
     * Add a quick access button
     * @param {string} id - Button ID
     * @param {string} title - Button title
     * @param {string} icon - Button icon class (FontAwesome)
     */
    addQuickAccessButton(id, title, icon) {
        // Create button
        const button = document.createElement('button');
        button.className = 'quick-access-button';
        button.dataset.targetPanel = id;
        button.title = title;
        button.innerHTML = `<i class="${icon}"></i>`;
        
        // Add to quick access bar
        this.quickAccessBar.appendChild(button);
        
        // Add click handler
        button.addEventListener('click', () => {
            // Activate the associated panel
            this.activatePanel(id);
            
            // Ensure the panel is expanded
            const panel = this.panels.find(p => p.id === id);
            if (panel && panel.isCollapsed) {
                this.togglePanelCollapse(id);
            }
            
            // Ensure the control panel is expanded
            if (!this.isExpanded) {
                this.toggleExpansion();
            }
        });
        
        // Add to quick access buttons array
        this.quickAccessButtons.push({
            id,
            element: button
        });
    }
    
    /**
     * Add a control group to a panel
     * @param {string} panelId - Panel ID
     * @param {string} groupId - Control group ID
     * @param {string} title - Control group title
     * @returns {HTMLElement} The control group content element
     */
    addControlGroup(panelId, groupId, title) {
        // Find the panel
        const panel = this.panels.find(p => p.id === panelId);
        if (!panel) return null;
        
        // Create control group
        const group = document.createElement('div');
        group.className = 'control-group';
        group.dataset.groupId = groupId;
        
        // Create group header
        const groupHeader = document.createElement('div');
        groupHeader.className = 'group-header';
        groupHeader.innerHTML = `
            <div class="group-title">${title}</div>
            <div class="group-actions">
                <button class="group-collapse" title="Collapse Group">
                    <i class="fas fa-chevron-up"></i>
                </button>
            </div>
        `;
        
        // Create group content
        const groupContent = document.createElement('div');
        groupContent.className = 'group-content';
        
        // Add to group
        group.appendChild(groupHeader);
        group.appendChild(groupContent);
        
        // Add to panel content
        panel.contentElement.appendChild(group);
        
        // Setup group event handlers
        this._setupGroupEventHandlers(group);
        
        // Add to control groups
        this.controlGroups[groupId] = {
            id: groupId,
            panelId,
            element: group,
            contentElement: groupContent,
            isCollapsed: false
        };
        
        return groupContent;
    }
    
    /**
     * Setup event handlers for a control group
     * @param {HTMLElement} group - Control group element
     * @private
     */
    _setupGroupEventHandlers(group) {
        // Collapse/expand group
        const collapseBtn = group.querySelector('.group-collapse');
        collapseBtn.addEventListener('click', () => {
            const groupId = group.dataset.groupId;
            this.toggleGroupCollapse(groupId);
        });
    }
    
    /**
     * Toggle the collapse state of a control group
     * @param {string} groupId - Control group ID
     */
    toggleGroupCollapse(groupId) {
        const group = this.controlGroups[groupId];
        if (!group) return;
        
        group.isCollapsed = !group.isCollapsed;
        
        // Update UI
        group.element.classList.toggle('collapsed', group.isCollapsed);
        
        // Update collapse button icon
        const collapseIcon = group.element.querySelector('.group-collapse i');
        collapseIcon.className = group.isCollapsed ? 'fas fa-chevron-down' : 'fas fa-chevron-up';
    }
    
    /**
     * Add a control to a control group
     * @param {string} groupId - Control group ID
     * @param {string} controlId - Control ID
     * @