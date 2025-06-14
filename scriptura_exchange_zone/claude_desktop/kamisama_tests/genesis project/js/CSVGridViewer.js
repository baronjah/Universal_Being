/**
 * CSVGridViewer.js
 * 
 * A spreadsheet-like interface for viewing and manipulating CSV data.
 * Features:
 * - Grid visualization with row/column headers
 * - Cell editing and formatting
 * - Cell connections between spreadsheets
 * - Folding/unfolding of nested content
 * - Import/export capabilities
 */

class CSVGridViewer {
    constructor(options = {}) {
        // Configuration options
        this.config = {
            container: null,               // Container element
            data: null,                    // CSV data object
            path: '',                      // Path to the CSV file
            editable: true,                // Whether cells are editable
            resizable: true,               // Whether columns are resizable
            showLineNumbers: true,         // Whether to show line numbers
            maxHeight: '80vh',             // Maximum height of the grid
            cellMinWidth: 100,             // Minimum cell width
            cellHeight: 32,                // Cell height
            onCellChange: null,            // Callback when a cell value changes
            onSelectCell: null,            // Callback when a cell is selected
            onConnectCell: null,           // Callback when a cell connection is created
            ...options                     // Merge user options
        };
        
        // Internal state
        this.state = {
            selectedCell: null,            // Currently selected cell
            editingCell: null,             // Currently editing cell
            columnWidths: {},              // Custom column widths
            connecting: false,             // Whether in connection mode
            connectionSource: null,        // Source cell for connection
            focusedRow: null,              // Row with focus
            focusedColumn: null,           // Column with focus
            scrollPosition: { x: 0, y: 0 },// Current scroll position
            viewportRows: [],              // Rows currently in viewport
            viewportRange: { start: 0, end: 0 }, // Viewport row range
            expandedCells: new Set(),      // Set of expanded cells
            nestedViewers: {},             // Nested CSV viewers
            connections: [],               // Cell connections
            clipboard: null,               // Clipboard data
            undoStack: [],                 // For undo functionality
            redoStack: []                  // For redo functionality
        };
        
        // Elements
        this.elements = {
            container: null,
            grid: null,
            header: null,
            body: null,
            rowNumbers: null,
            resizeHandles: [],
            connectionLines: []
        };
        
        // Initialize if we have a container
        if (this.config.container) {
            this.initialize();
        }
    }
    
    /**
     * Initialize the grid viewer
     */
    initialize() {
        // Verify we have a container
        if (!this.config.container) {
            throw new Error('Container element is required');
        }
        
        // Create the grid structure
        this._createGridStructure();
        
        // Load data if provided
        if (this.config.data) {
            this.loadData(this.config.data);
        } else if (this.config.path) {
            this.loadFromPath(this.config.path);
        }
        
        // Register event handlers
        this._registerEventHandlers();
        
        return this;
    }
    
    /**
     * Create the grid structure
     * @private
     */
    _createGridStructure() {
        const container = this.config.container;
        container.classList.add('csv-grid-viewer');
        container.innerHTML = '';
        
        // Add CSS styles if not already added
        this._injectStyles();
        
        // Create grid container
        const gridContainer = document.createElement('div');
        gridContainer.className = 'csv-grid-container';
        
        // Create header row
        const headerRow = document.createElement('div');
        headerRow.className = 'csv-header-row';
        
        // Add corner cell if showing line numbers
        if (this.config.showLineNumbers) {
            const cornerCell = document.createElement('div');
            cornerCell.className = 'csv-corner-cell';
            headerRow.appendChild(cornerCell);
        }
        
        // Create grid body
        const gridBody = document.createElement('div');
        gridBody.className = 'csv-grid-body';
        
        // Create row numbers container if needed
        if (this.config.showLineNumbers) {
            const rowNumbers = document.createElement('div');
            rowNumbers.className = 'csv-row-numbers';
            gridContainer.appendChild(rowNumbers);
            this.elements.rowNumbers = rowNumbers;
        }
        
        // Create toolbar
        const toolbar = document.createElement('div');
        toolbar.className = 'csv-grid-toolbar';
        
        // Add toolbar buttons
        toolbar.innerHTML = `
            <div class="csv-toolbar-group">
                <button class="csv-btn csv-btn-add-row" title="Add Row">
                    <i class="fas fa-plus"></i> Row
                </button>
                <button class="csv-btn csv-btn-add-column" title="Add Column">
                    <i class="fas fa-plus"></i> Column
                </button>
                <button class="csv-btn csv-btn-delete-row" title="Delete Row">
                    <i class="fas fa-minus"></i> Row
                </button>
                <button class="csv-btn csv-btn-delete-column" title="Delete Column">
                    <i class="fas fa-minus"></i> Column
                </button>
            </div>
            <div class="csv-toolbar-group">
                <button class="csv-btn csv-btn-connect" title="Connect Cells">
                    <i class="fas fa-link"></i>
                </button>
                <button class="csv-btn csv-btn-fold-all" title="Fold All">
                    <i class="fas fa-compress-alt"></i>
                </button>
                <button class="csv-btn csv-btn-unfold-all" title="Unfold All">
                    <i class="fas fa-expand-alt"></i>
                </button>
            </div>
            <div class="csv-toolbar-group">
                <button class="csv-btn csv-btn-import" title="Import">
                    <i class="fas fa-file-import"></i>
                </button>
                <button class="csv-btn csv-btn-export" title="Export">
                    <i class="fas fa-file-export"></i>
                </button>
            </div>
            <div class="csv-toolbar-group">
                <button class="csv-btn csv-btn-undo" title="Undo" disabled>
                    <i class="fas fa-undo"></i>
                </button>
                <button class="csv-btn csv-btn-redo" title="Redo" disabled>
                    <i class="fas fa-redo"></i>
                </button>
            </div>
        `;
        
        // Assemble the structure
        gridContainer.appendChild(headerRow);
        gridContainer.appendChild(gridBody);
        
        container.appendChild(toolbar);
        container.appendChild(gridContainer);
        
        // Save references
        this.elements.container = container;
        this.elements.grid = gridContainer;
        this.elements.header = headerRow;
        this.elements.body = gridBody;
    }
    
    /**
     * Inject required CSS styles
     * @private
     */
    _injectStyles() {
        const styleId = 'csv-grid-viewer-styles';
        
        // Check if styles already exist
        if (document.getElementById(styleId)) {
            return;
        }
        
        const style = document.createElement('style');
        style.id = styleId;
        style.textContent = `
            .csv-grid-viewer {
                --csv-bg-primary: #1e1e1e;
                --csv-bg-secondary: #252525;
                --csv-bg-header: #333333;
                --csv-text-primary: #f0f0f0;
                --csv-text-secondary: #a0a0a0;
                --csv-border-color: #454545;
                --csv-selected-bg: rgba(30, 150, 255, 0.2);
                --csv-selected-border: #3794ff;
                --csv-hover-bg: rgba(255, 255, 255, 0.05);
                --csv-editing-bg: #2d2d2d;
                
                display: flex;
                flex-direction: column;
                height: 100%;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                color: var(--csv-text-primary);
                background-color: var(--csv-bg-primary);
                position: relative;
                overflow: hidden;
            }
            
            .csv-grid-toolbar {
                display: flex;
                padding: 5px;
                background-color: var(--csv-bg-header);
                border-bottom: 1px solid var(--csv-border-color);
                gap: 10px;
            }
            
            .csv-toolbar-group {
                display: flex;
                gap: 5px;
                border-right: 1px solid var(--csv-border-color);
                padding-right: 10px;
                margin-right: 5px;
            }
            
            .csv-toolbar-group:last-child {
                border-right: none;
            }
            
            .csv-btn {
                background-color: transparent;
                border: 1px solid var(--csv-border-color);
                color: var(--csv-text-primary);
                padding: 4px 8px;
                border-radius: 3px;
                cursor: pointer;
                display: flex;
                align-items: center;
                gap: 5px;
                font-size: 12px;
            }
            
            .csv-btn:hover {
                background-color: var(--csv-hover-bg);
            }
            
            .csv-btn:disabled {
                opacity: 0.5;
                cursor: not-allowed;
            }
            
            .csv-btn i {
                font-size: 14px;
            }
            
            .csv-grid-container {
                display: flex;
                flex-direction: column;
                flex: 1;
                overflow: auto;
                position: relative;
            }
            
            .csv-header-row {
                display: flex;
                position: sticky;
                top: 0;
                z-index: 2;
                background-color: var(--csv-bg-header);
                border-bottom: 1px solid var(--csv-border-color);
            }
            
            .csv-corner-cell {
                min-width: 40px;
                height: ${this.config.cellHeight}px;
                border-right: 1px solid var(--csv-border-color);
                position: sticky;
                left: 0;
                z-index: 3;
                background-color: var(--csv-bg-header);
                display: flex;
                align-items: center;
                justify-content: center;
            }
            
            .csv-header-cell {
                min-width: ${this.config.cellMinWidth}px;
                height: ${this.config.cellHeight}px;
                border-right: 1px solid var(--csv-border-color);
                display: flex;
                align-items: center;
                padding: 0 8px;
                font-weight: bold;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
                position: relative;
                cursor: pointer;
            }
            
            .csv-header-cell:hover {
                background-color: var(--csv-hover-bg);
            }
            
            .csv-resize-handle {
                position: absolute;
                top: 0;
                right: 0;
                width: 4px;
                height: 100%;
                cursor: col-resize;
                z-index: 2;
            }
            
            .csv-resize-handle:hover,
            .csv-resize-handle.resizing {
                background-color: var(--csv-selected-border);
            }
            
            .csv-grid-body {
                display: flex;
                flex-direction: column;
                flex: 1;
                z-index: 1;
            }
            
            .csv-row {
                display: flex;
                height: ${this.config.cellHeight}px;
                border-bottom: 1px solid var(--csv-border-color);
            }
            
            .csv-row:hover {
                background-color: var(--csv-hover-bg);
            }
            
            .csv-row-number {
                min-width: 40px;
                height: ${this.config.cellHeight}px;
                border-right: 1px solid var(--csv-border-color);
                position: sticky;
                left: 0;
                z-index: 2;
                background-color: var(--csv-bg-secondary);
                display: flex;
                align-items: center;
                justify-content: center;
                color: var(--csv-text-secondary);
                font-size: 12px;
            }
            
            .csv-cell {
                min-width: ${this.config.cellMinWidth}px;
                height: ${this.config.cellHeight}px;
                border-right: 1px solid var(--csv-border-color);
                padding: 0 8px;
                display: flex;
                align-items: center;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
                cursor: cell;
            }
            
            .csv-cell.selected {
                background-color: var(--csv-selected-bg);
                border: 1px solid var(--csv-selected-border);
            }
            
            .csv-cell.editing {
                padding: 0;
                background-color: var(--csv-editing-bg);
            }
            
            .csv-cell-edit-input {
                width: 100%;
                height: 100%;
                border: none;
                background-color: transparent;
                color: var(--csv-text-primary);
                font-family: inherit;
                font-size: inherit;
                padding: 0 8px;
                outline: none;
            }
            
            .csv-cell.has-connection {
                position: relative;
            }
            
            .csv-cell.has-connection::after {
                content: '';
                position: absolute;
                right: 5px;
                top: 5px;
                width: 6px;
                height: 6px;
                border-radius: 50%;
                background-color: var(--csv-selected-border);
            }
            
            .csv-cell.expandable {
                cursor: pointer;
                background-color: rgba(100, 100, 150, 0.1);
            }
            
            .csv-cell.expanded {
                border-bottom-width: 0;
            }
            
            .csv-nested-content {
                grid-column: 1 / -1;
                padding: 10px;
                background-color: var(--csv-bg-secondary);
                border: 1px solid var(--csv-border-color);
                border-top: none;
                position: relative;
            }
            
            .csv-connection-line {
                position: absolute;
                pointer-events: none;
                z-index: 10;
                background-color: var(--csv-selected-border);
                height: 2px;
                transform-origin: 0 0;
            }
            
            .csv-connecting .csv-cell:hover {
                background-color: rgba(0, 255, 0, 0.1);
                border: 1px dashed rgba(0, 255, 0, 0.5);
            }
            
            .csv-connection-source {
                background-color: rgba(0, 255, 0, 0.1);
                border: 1px solid rgba(0, 255, 0, 0.5);
            }
            
            /* Right-click context menu */
            .csv-context-menu {
                position: absolute;
                background-color: var(--csv-bg-secondary);
                border: 1px solid var(--csv-border-color);
                border-radius: 3px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
                z-index: 1000;
            }
            
            .csv-context-menu-item {
                padding: 8px 12px;
                cursor: pointer;
                display: flex;
                align-items: center;
                gap: 8px;
            }
            
            .csv-context-menu-item:hover {
                background-color: var(--csv-hover-bg);
            }
            
            .csv-context-menu-separator {
                height: 1px;
                background-color: var(--csv-border-color);
                margin: 5px 0;
            }
        `;
        
        document.head.appendChild(style);
    }
    
    /**
     * Register event handlers
     * @private
     */
    _registerEventHandlers() {
        // Toolbar button handlers
        const toolbar = this.elements.container.querySelector('.csv-grid-toolbar');
        
        // Add row button
        toolbar.querySelector('.csv-btn-add-row').addEventListener('click', () => {
            this.addRow();
        });
        
        // Add column button
        toolbar.querySelector('.csv-btn-add-column').addEventListener('click', () => {
            this.addColumn();
        });
        
        // Delete row button
        toolbar.querySelector('.csv-btn-delete-row').addEventListener('click', () => {
            if (this.state.selectedCell) {
                this.deleteRow(this.state.selectedCell.row);
            }
        });
        
        // Delete column button
        toolbar.querySelector('.csv-btn-delete-column').addEventListener('click', () => {
            if (this.state.selectedCell) {
                this.deleteColumn(this.state.selectedCell.col);
            }
        });
        
        // Connect cells button
        toolbar.querySelector('.csv-btn-connect').addEventListener('click', () => {
            this.toggleConnectionMode();
        });
        
        // Import button
        toolbar.querySelector('.csv-btn-import').addEventListener('click', () => {
            this.importData();
        });
        
        // Export button
        toolbar.querySelector('.csv-btn-export').addEventListener('click', () => {
            this.exportData();
        });
        
        // Undo button
        toolbar.querySelector('.csv-btn-undo').addEventListener('click', () => {
            this.undo();
        });
        
        // Redo button
        toolbar.querySelector('.csv-btn-redo').addEventListener('click', () => {
            this.redo();
        });
        
        // Fold all button
        toolbar.querySelector('.csv-btn-fold-all').addEventListener('click', () => {
            this.foldAll();
        });
        
        // Unfold all button
        toolbar.querySelector('.csv-btn-unfold-all').addEventListener('click', () => {
            this.unfoldAll();
        });
        
        // Grid keyboard events
        this.elements.grid.addEventListener('keydown', (e) => this._handleGridKeydown(e));
        
        // Grid mouse events for context menu
        this.elements.grid.addEventListener('contextmenu', (e) => this._handleContextMenu(e));
        
        // Document click to hide context menu
        document.addEventListener('click', () => {
            const menu = document.querySelector('.csv-context-menu');
            if (menu) {
                menu.remove();
            }
        });
    }
    
    /**
     * Handle keyboard events on the grid
     * @param {KeyboardEvent} e - Keyboard event
     * @private
     */
    _handleGridKeydown(e) {
        // Only process if we have a selected cell
        if (!this.state.selectedCell) return;
        
        const { row, col } = this.state.selectedCell;
        
        // Handle navigation keys
        if (e.key === 'ArrowUp' && !e.shiftKey) {
            e.preventDefault();
            this.selectCell(Math.max(0, row - 1), col);
        } else if (e.key === 'ArrowDown' && !e.shiftKey) {
            e.preventDefault();
            this.selectCell(Math.min(this.config.data.rows.length - 1, row + 1), col);
        } else if (e.key === 'ArrowLeft' && !e.shiftKey) {
            e.preventDefault();
            this.selectCell(row, Math.max(0, col - 1));
        } else if (e.key === 'ArrowRight' && !e.shiftKey) {
            e.preventDefault();
            this.selectCell(row, Math.min(this.config.data.headers.length - 1, col + 1));
        } else if (e.key === 'Tab') {
            e.preventDefault();
            if (e.shiftKey) {
                // Move to previous cell or previous row last cell
                if (col > 0) {
                    this.selectCell(row, col - 1);
                } else if (row > 0) {
                    this.selectCell(row - 1, this.config.data.headers.length - 1);
                }
            } else {
                // Move to next cell or next row first cell
                if (col < this.config.data.headers.length - 1) {
                    this.selectCell(row, col + 1);
                } else if (row < this.config.data.rows.length - 1) {
                    this.selectCell(row + 1, 0);
                }
            }
        } else if (e.key === 'Enter') {
            e.preventDefault();
            if (!this.state.editingCell) {
                // Start editing if not already editing
                this.editCell(row, col);
            } else {
                // Finish editing and move to next row
                this.finishEditing();
                if (row < this.config.data.rows.length - 1) {
                    this.selectCell(row + 1, col);
                }
            }
        } else if (e.key === 'Escape' && this.state.editingCell) {
            e.preventDefault();
            this.cancelEditing();
        } else if ((e.key === 'Delete' || e.key === 'Backspace') && !this.state.editingCell) {
            e.preventDefault();
            this.clearCell(row, col);
        } else if (e.key === 'c' && e.ctrlKey) {
            e.preventDefault();
            this.copySelectedCell();
        } else if (e.key === 'x' && e.ctrlKey) {
            e.preventDefault();
            this.cutSelectedCell();
        } else if (e.key === 'v' && e.ctrlKey) {
            e.preventDefault();
            this.pasteToSelectedCell();
        } else if (e.key === 'z' && e.ctrlKey) {
            e.preventDefault();
            this.undo();
        } else if (e.key === 'y' && e.ctrlKey) {
            e.preventDefault();
            this.redo();
        } else if (!this.state.editingCell && e.key.length === 1 && !e.ctrlKey && !e.metaKey) {
            // Start editing with the typed character
            this.editCell(row, col, e.key);
            e.preventDefault();
        }
    }
    
    /**
     * Handle right-click context menu
     * @param {MouseEvent} e - Mouse event
     * @private
     */
    _handleContextMenu(e) {
        e.preventDefault();
        
        // Remove any existing context menu
        const existingMenu = document.querySelector('.csv-context-menu');
        if (existingMenu) {
            existingMenu.remove();
        }
        
        // Get the target cell
        const cell = e.target.closest('.csv-cell');
        if (!cell) return;
        
        // Get cell position
        const row = parseInt(cell.dataset.row);
        const col = parseInt(cell.dataset.col);
        
        // Select the cell
        this.selectCell(row, col);
        
        // Create the context menu
        const menu = document.createElement('div');
        menu.className = 'csv-context-menu';
        menu.style.left = `${e.pageX}px`;
        menu.style.top = `${e.pageY}px`;
        
        // Add menu items
        menu.innerHTML = `
            <div class="csv-context-menu-item" data-action="edit">
                <i class="fas fa-edit"></i> Edit Cell
            </div>
            <div class="csv-context-menu-item" data-action="connect">
                <i class="fas fa-link"></i> Create Connection
            </div>
            <div class="csv-context-menu-item" data-action="insert-nested">
                <i class="fas fa-table"></i> Insert Nested Grid
            </div>
            <div class="csv-context-menu-separator"></div>
            <div class="csv-context-menu-item" data-action="copy">
                <i class="fas fa-copy"></i> Copy
            </div>
            <div class="csv-context-menu-item" data-action="cut">
                <i class="fas fa-cut"></i> Cut
            </div>
            <div class="csv-context-menu-item" data-action="paste">
                <i class="fas fa-paste"></i> Paste
            </div>
            <div class="csv-context-menu-separator"></div>
            <div class="csv-context-menu-item" data-action="insert-row-above">
                <i class="fas fa-plus"></i> Insert Row Above
            </div>
            <div class="csv-context-menu-item" data-action="insert-row-below">
                <i class="fas fa-plus"></i> Insert Row Below
            </div>
            <div class="csv-context-menu-item" data-action="insert-column-left">
                <i class="fas fa-plus"></i> Insert Column Left
            </div>
            <div class="csv-context-menu-item" data-action="insert-column-right">
                <i class="fas fa-plus"></i> Insert Column Right
            </div>
            <div class="csv-context-menu-separator"></div>
            <div class="csv-context-menu-item" data-action="delete-row">
                <i class="fas fa-trash"></i> Delete Row
            </div>
            <div class="csv-context-menu-item" data-action="delete-column">
                <i class="fas fa-trash"></i> Delete Column
            </div>
        `;
        
        // Add event handlers
        menu.querySelectorAll('.csv-context-menu-item').forEach(item => {
            item.addEventListener('click', () => {
                const action = item.dataset.action;
                
                switch (action) {
                    case 'edit':
                        this.editCell(row, col);
                        break;
                    case 'connect':
                        this.startConnection(row, col);
                        break;
                    case 'insert-nested':
                        this.insertNestedGrid(row, col);
                        break;
                    case 'copy':
                        this.copySelectedCell();
                        break;
                    case 'cut':
                        this.cutSelectedCell();
                        break;
                    case 'paste':
                        this.pasteToSelectedCell();
                        break;
                    case 'insert-row-above':
                        this.insertRow(row);
                        break;
                    case 'insert-row-below':
                        this.insertRow(row + 1);
                        break;
                    case 'insert-column-left':
                        this.insertColumn(col);
                        break;
                    case 'insert-column-right':
                        this.insertColumn(col + 1);
                        break;
                    case 'delete-row':
                        this.deleteRow(row);
                        break;
                    case 'delete-column':
                        this.deleteColumn(col);
                        break;
                }
                
                // Remove the menu
                menu.remove();
            });
        });
        
        // Add to document
        document.body.appendChild(menu);
    }
    
    /**
     * Load data into the grid
     * @param {Object} data - The CSV data object
     */
    loadData(data) {
        this.config.data = data;
        this._renderGrid();
        
        // Enable or disable undo/redo buttons
        this._updateUndoRedoButtons();
    }
    
    /**
     * Load CSV data from a path
     * @param {string} path - Path to the CSV file
     */
    async loadFromPath(path) {
        try {
            const response = await fetch(path);
            if (!response.ok) {
                throw new Error(`Failed to load CSV: ${response.status} ${response.statusText}`);
            }
            
            const text = await response.text();
            const data = this._parseCSV(text);
            
            this.config.path = path;
            this.loadData(data);
        } catch (error) {
            console.error('Error loading CSV from path:', error);
            // Load empty data
            this.loadData({
                headers: ['Column 1', 'Column 2', 'Column 3'],
                rows: [
                    { 'Column 1': '', 'Column 2': '', 'Column 3': '' },
                    { 'Column 1': '', 'Column 2': '', 'Column 3': '' },
                    { 'Column 1': '', 'Column 2': '', 'Column 3': '' }
                ]
            });
        }
    }
    
    /**
     * Parse CSV text into structured data
     * @param {string} text - CSV text content
     * @returns {Object} Parsed CSV data
     * @private
     */
    _parseCSV(text) {
        const lines = text.split('\n');
        const headers = lines[0].split(',').map(header => header.trim());
        
        const rows = lines.slice(1).filter(line => line.trim()).map(line => {
            const values = line.split(',');
            const row = {};
            
            headers.forEach((header, index) => {
                row[header] = values[index] ? values[index].trim() : '';
            });
            
            return row;
        });
        
        return { headers, rows };
    }
    
    /**
     * Render the grid with current data
     * @private
     */
    _renderGrid() {
        if (!this.config.data) return;
        
        const { headers, rows } = this.config.data;
        
        // Clear existing content
        this.elements.header.innerHTML = '';
        this.elements.body.innerHTML = '';
        
        if (this.elements.rowNumbers) {
            this.elements.rowNumbers.innerHTML = '';
        }
        
        // Add corner cell if showing line numbers
        if (this.config.showLineNumbers) {
            const cornerCell = document.createElement('div');
            cornerCell.className = 'csv-corner-cell';
            this.elements.header.appendChild(cornerCell);
        }
        
        // Add header cells
        headers.forEach((header, colIndex) => {
            const headerCell = document.createElement('div');
            headerCell.className = 'csv-header-cell';
            headerCell.textContent = header;
            headerCell.dataset.col = colIndex;
            
            // Apply custom width if set
            if (this.state.columnWidths[colIndex]) {
                headerCell.style.width = `${this.state.columnWidths[colIndex]}px`;
            }
            
            // Add click handler for sorting
            headerCell.addEventListener('click', () => {
                this._sortByColumn(colIndex);
            });
            
            // Add resize handle if resizable
            if (this.config.resizable) {
                const resizeHandle = document.createElement('div');
                resizeHandle.className = 'csv-resize-handle';
                resizeHandle.dataset.col = colIndex;
                
                // Add resize event handlers
                this._addResizeHandlers(resizeHandle);
                
                headerCell.appendChild(resizeHandle);
                this.elements.resizeHandles.push(resizeHandle);
            }
            
            this.elements.header.appendChild(headerCell);
        });
        
        // Add rows
        rows.forEach((rowData, rowIndex) => {
            const rowElement = document.createElement('div');
            rowElement.className = 'csv-row';
            rowElement.dataset.row = rowIndex;
            
            // Add row number if needed
            if (this.config.showLineNumbers) {
                const rowNumber = document.createElement('div');
                rowNumber.className = 'csv-row-number';
                rowNumber.textContent = rowIndex + 1;
                rowElement.appendChild(rowNumber);
            }
            
            // Add cells
            headers.forEach((header, colIndex) => {
                const cellElement = document.createElement('div');
                cellElement.className = 'csv-cell';
                cellElement.dataset.row = rowIndex;
                cellElement.dataset.col = colIndex;
                cellElement.dataset.header = header;
                cellElement.textContent = rowData[header] || '';
                
                // Apply custom width if set
                if (this.state.columnWidths[colIndex]) {
                    cellElement.style.width = `${this.state.columnWidths[colIndex]}px`;
                }
                
                // Check if this cell has a connection
                if (this._cellHasConnection(rowIndex, colIndex)) {
                    cellElement.classList.add('has-connection');
                }
                
                // Add nested content if this cell is expanded
                if (this._isCellExpanded(rowIndex, colIndex)) {
                    cellElement.classList.add('expanded');
                    // Nested content added separately to avoid click handler issues
                }
                
                // Add click handler
                cellElement.addEventListener('click', (e) => {
                    // Check if we're in connection mode
                    if (this.state.connecting) {
                        this.completeConnection(rowIndex, colIndex);
                    } else {
                        this.selectCell(rowIndex, colIndex);
                        
                        // Double click starts editing
                        if (e.detail === 2 && this.config.editable) {
                            this.editCell(rowIndex, colIndex);
                        }
                    }
                });
                
                rowElement.appendChild(cellElement);
            });
            
            this.elements.body.appendChild(rowElement);
            
            // Add nested content if any cell in this row is expanded
            headers.forEach((header, colIndex) => {
                if (this._isCellExpanded(rowIndex, colIndex)) {
                    this._renderNestedContent(rowIndex, colIndex);
                }
            });
        });
    }
    
    /**
     * Add resize handlers to column resize handles
     * @param {HTMLElement} handle - Resize handle element
     * @private
     */
    _addResizeHandlers(handle) {
        let startX, startWidth, colIndex;
        
        handle.addEventListener('mousedown', (e) => {
            e.preventDefault();
            e.stopPropagation();
            
            colIndex = parseInt(handle.dataset.col);
            const headerCell = this.elements.header.children[colIndex + (this.config.showLineNumbers ? 1 : 0)];
            startX = e.clientX;
            startWidth = headerCell.offsetWidth;
            
            handle.classList.add('resizing');
            
            // Add document-level event handlers
            document.addEventListener('mousemove', handleMouseMove);
            document.addEventListener('mouseup', handleMouseUp);
        });
        
        const handleMouseMove = (e) => {
            if (!handle.classList.contains('resizing')) return;
            
            const width = Math.max(startWidth + e.clientX - startX, this.config.cellMinWidth);
            
            // Update column width in state
            this.state.columnWidths[colIndex] = width;
            
            // Update header cell width
            const headerCell = this.elements.header.children[colIndex + (this.config.showLineNumbers ? 1 : 0)];
            headerCell.style.width = `${width}px`;
            
            // Update all cells in this column
            const cells = this.elements.body.querySelectorAll(`.csv-cell[data-col="${colIndex}"]`);
            cells.forEach(cell => {
                cell.style.width = `${width}px`;
            });
        };
        
        const handleMouseUp = () => {















// another first cut happen here















            handle.classList.remove('resizing');
            
            // Remove document-level event handlers
            document.removeEventListener('mousemove', handleMouseMove);
            document.removeEventListener('mouseup', handleMouseUp);
        };
    }
    
    /**
     * Check if a cell has any connections
     * @param {number} row - Row index
     * @param {number} col - Column index
     * @returns {boolean} Whether the cell has connections
     * @private
     */
    _cellHasConnection(row, col) {
        return this.state.connections.some(conn => 
            (conn.sourceRow === row && conn.sourceCol === col) || 
            (conn.targetRow === row && conn.targetCol === col)
        );
    }
    
    /**
     * Check if a cell is expanded
     * @param {number} row - Row index
     * @param {number} col - Column index
     * @returns {boolean} Whether the cell is expanded
     * @private
     */
    _isCellExpanded(row, col) {
        return this.state.expandedCells.has(`${row},${col}`);
    }
    
    /**
     * Render nested content for an expanded cell
     * @param {number} row - Row index
     * @param {number} col - Column index
     * @private
     */
    _renderNestedContent(row, col) {
        const cellKey = `${row},${col}`;
        
        // Create container for nested content
        const nestedContainer = document.createElement('div');
        nestedContainer.className = 'csv-nested-content';
        nestedContainer.dataset.parent = cellKey;
        
        // Add close button
        const closeButton = document.createElement('button');
        closeButton.className = 'csv-nested-close';
        closeButton.innerHTML = '<i class="fas fa-times"></i>';
        closeButton.style.position = 'absolute';
        closeButton.style.top = '5px';
        closeButton.style.right = '5px';
        closeButton.style.background = 'transparent';
        closeButton.style.border = 'none';
        closeButton.style.color = 'var(--csv-text-primary)';
        closeButton.style.cursor = 'pointer';
        
        closeButton.addEventListener('click', () => {
            this.foldCell(row, col);
        });
        
        nestedContainer.appendChild(closeButton);
        
        // Check if we have a nested viewer for this cell
        if (this.state.nestedViewers[cellKey]) {
            // Get the nested viewer
            const nestedViewer = this.state.nestedViewers[cellKey];
            
            // Create a container for the nested viewer
            const viewerContainer = document.createElement('div');
            viewerContainer.style.height = '300px';
            viewerContainer.style.overflow = 'auto';
            
            nestedContainer.appendChild(viewerContainer);
            
            // Wait for the container to be added to the DOM
            setTimeout(() => {
                // Initialize the nested viewer with the container
                nestedViewer.config.container = viewerContainer;
                nestedViewer.initialize();
            }, 0);
        } else {
            // Just show the cell value in a bigger area
            const header = this.config.data.headers[col];
            const value = this.config.data.rows[row][header] || '';
            
            const content = document.createElement('div');
            content.textContent = value;
            content.style.padding = '10px';
            content.style.whiteSpace = 'pre-wrap';
            
            nestedContainer.appendChild(content);
        }
        
        // Find the row element
        const rowElement = this.elements.body.querySelector(`.csv-row[data-row="${row}"]`);
        
        // Insert after the row
        rowElement.parentNode.insertBefore(nestedContainer, rowElement.nextSibling);
    }
    
    /**
     * Update undo/redo buttons state
     * @private
     */
    _updateUndoRedoButtons() {
        const undoBtn = this.elements.container.querySelector('.csv-btn-undo');
        const redoBtn = this.elements.container.querySelector('.csv-btn-redo');
        
        undoBtn.disabled = this.state.undoStack.length === 0;
        redoBtn.disabled = this.state.redoStack.length === 0;
    }
    
    /**
     * Add a state to the undo stack
     * @param {string} action - Action name
     * @param {object} state - State to save
     * @private
     */
    _addToUndoStack(action, state) {
        this.state.undoStack.push({
            action,
            state: JSON.parse(JSON.stringify(state))
        });
        
        // Clear redo stack when a new action is performed
        this.state.redoStack = [];
        
        // Update buttons
        this._updateUndoRedoButtons();
    }
    
    /**
     * Select a cell
     * @param {number} row - Row index
     * @param {number} col - Column index
     */
    selectCell(row, col) {
        // Clear previous selection
        if (this.state.selectedCell) {
            const prevCell = this.elements.body.querySelector(`.csv-cell[data-row="${this.state.selectedCell.row}"][data-col="${this.state.selectedCell.col}"]`);
            if (prevCell) {
                prevCell.classList.remove('selected');
            }
        }
        
        // Set new selection
        this.state.selectedCell = { row, col };
        
        // Highlight the cell
        const cell = this.elements.body.querySelector(`.csv-cell[data-row="${row}"][data-col="${col}"]`);
        if (cell) {
            cell.classList.add('selected');
            
            // Ensure cell is visible
            cell.scrollIntoView({ block: 'nearest', inline: 'nearest' });
        }
        
        // Trigger callback if provided
        if (this.config.onSelectCell) {
            const header = this.config.data.headers[col];
            const value = this.config.data.rows[row][header];
            this.config.onSelectCell(row, col, header, value);
        }
    }
    
    /**
     * Edit a cell
     * @param {number} row - Row index
     * @param {number} col - Column index
     * @param {string} initialValue - Optional initial value
     */
    editCell(row, col, initialValue) {
        if (!this.config.editable) return;
        
        // Select the cell first
        this.selectCell(row, col);
        
        // Get cell element
        const cell = this.elements.body.querySelector(`.csv-cell[data-row="${row}"][data-col="${col}"]`);
        if (!cell) return;
        
        // Mark as editing
        this.state.editingCell = { row, col };
        cell.classList.add('editing');
        
        // Get current value
        const header = this.config.data.headers[col];
        let value = this.config.data.rows[row][header] || '';
        
        // Create input element
        const input = document.createElement('input');
        input.type = 'text';
        input.className = 'csv-cell-edit-input';
        input.value = initialValue !== undefined ? initialValue : value;
        
        // Replace cell content with input
        cell.textContent = '';
        cell.appendChild(input);
        
        // Focus and select all text
        input.focus();
        input.select();
        
        // Handle input events
        input.addEventListener('blur', () => {
            this.finishEditing();
        });
        
        input.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                e.preventDefault();
                this.finishEditing();
            } else if (e.key === 'Escape') {
                e.preventDefault();
                this.cancelEditing();
            } else if (e.key === 'Tab') {
                e.preventDefault();
                this.finishEditing();
                
                // Move to next/previous cell
                if (e.shiftKey) {
                    if (col > 0) {
                        this.selectCell(row, col - 1);
                        this.editCell(row, col - 1);
                    } else if (row > 0) {
                        this.selectCell(row - 1, this.config.data.headers.length - 1);
                        this.editCell(row - 1, this.config.data.headers.length - 1);
                    }
                } else {
                    if (col < this.config.data.headers.length - 1) {
                        this.selectCell(row, col + 1);
                        this.editCell(row, col + 1);
                    } else if (row < this.config.data.rows.length - 1) {
                        this.selectCell(row + 1, 0);
                        this.editCell(row + 1, 0);
                    }
                }
            }
        });
    }
    
    /**
     * Finish editing the current cell
     */
    finishEditing() {
        if (!this.state.editingCell) return;
        
        const { row, col } = this.state.editingCell;
        const cell = this.elements.body.querySelector(`.csv-cell[data-row="${row}"][data-col="${col}"]`);
        const input = cell.querySelector('input');
        
        if (!cell || !input) return;
        
        // Get the new value
        const newValue = input.value;
        
        // Get the header
        const header = this.config.data.headers[col];
        
        // Get the old value
        const oldValue = this.config.data.rows[row][header] || '';
        
        // Only update if the value changed
        if (newValue !== oldValue) {
            // Save the old state for undo
            this._addToUndoStack('edit-cell', {
                row,
                col,
                header,
                oldValue,
                newValue
            });
            
            // Update the data
            this.config.data.rows[row][header] = newValue;
            
            // Update the cell content
            cell.textContent = newValue;
            
            // Trigger callback if provided
            if (this.config.onCellChange) {
                this.config.onCellChange(row, col, header, oldValue, newValue);
            }
        } else {
            // Just restore the cell content
            cell.textContent = oldValue;
        }
        
        // Clear editing state
        cell.classList.remove('editing');
        this.state.editingCell = null;
    }
    
    /**
     * Cancel editing the current cell
     */
    cancelEditing() {
        if (!this.state.editingCell) return;
        
        const { row, col } = this.state.editingCell;
        const cell = this.elements.body.querySelector(`.csv-cell[data-row="${row}"][data-col="${col}"]`);
        
        if (!cell) return;
        
        // Get the original value
        const header = this.config.data.headers[col];
        const value = this.config.data.rows[row][header] || '';
        
        // Restore the cell content
        cell.textContent = value;
        
        // Clear editing state
        cell.classList.remove('editing');
        this.state.editingCell = null;
    }
    
    /**
     * Clear the content of a cell
     * @param {number} row - Row index
     * @param {number} col - Column index
     */
    clearCell(row, col) {
        const header = this.config.data.headers[col];
        const oldValue = this.config.data.rows[row][header] || '';
        
        // Save the old state for undo
        this._addToUndoStack('clear-cell', {
            row,
            col,
            header,
            oldValue
        });
        
        // Clear the value
        this.config.data.rows[row][header] = '';
        
        // Update the cell in the DOM
        const cell = this.elements.body.querySelector(`.csv-cell[data-row="${row}"][data-col="${col}"]`);
        if (cell) {
            cell.textContent = '';
        }
        
        // Trigger callback if provided
        if (this.config.onCellChange) {
            this.config.onCellChange(row, col, header, oldValue, '');
        }
    }
    
    /**
     * Start creating a connection from a cell
     * @param {number} row - Source row index
     * @param {number} col - Source column index
     */
    startConnection(row, col) {
        // Enable connection mode
        this.state.connecting = true;
        this.state.connectionSource = { row, col };
        
        // Add connecting class to the grid container
        this.elements.grid.classList.add('csv-connecting');
        
        // Add source class to the cell
        const cell = this.elements.body.querySelector(`.csv-cell[data-row="${row}"][data-col="${col}"]`);
        if (cell) {
            cell.classList.add('csv-connection-source');
        }
    }
    
    /**
     * Complete a connection to a target cell
     * @param {number} row - Target row index
     * @param {number} col - Target column index
     */
    completeConnection(row, col) {
        if (!this.state.connecting || !this.state.connectionSource) return;
        
        const { row: sourceRow, col: sourceCol } = this.state.connectionSource;
        
        // Don't connect to the same cell
        if (sourceRow === row && sourceCol === col) {
            this.cancelConnection();
            return;
        }
        
        // Create the connection
        this.state.connections.push({
            sourceRow,
            sourceCol,
            targetRow: row,
            targetCol: col,
            type: 'default'
        });
        
        // Add connection indicators to cells
        const sourceCell = this.elements.body.querySelector(`.csv-cell[data-row="${sourceRow}"][data-col="${sourceCol}"]`);
        const targetCell = this.elements.body.querySelector(`.csv-cell[data-row="${row}"][data-col="${col}"]`);
        
        if (sourceCell) sourceCell.classList.add('has-connection');
        if (targetCell) targetCell.classList.add('has-connection');
        
        // Draw the connection line
        this._drawConnectionLine(sourceRow, sourceCol, row, col);
        
        // Save state for undo
        this._addToUndoStack('add-connection', {
            sourceRow,
            sourceCol,
            targetRow: row,
            targetCol: col
        });
        
        // Reset connection state
        this.cancelConnection();
        
        // Trigger callback if provided
        if (this.config.onConnectCell) {
            const sourceHeader = this.config.data.headers[sourceCol];
            const targetHeader = this.config.data.headers[col];
            
            this.config.onConnectCell(
                sourceRow, sourceCol, sourceHeader,
                row, col, targetHeader
            );
        }
    }
    
    /**
     * Cancel the current connection
     */
    cancelConnection() {
        // Reset connection state
        this.state.connecting = false;
        
        // Remove connecting class from grid
        this.elements.grid.classList.remove('csv-connecting');
        
        // Remove source class from cell
        if (this.state.connectionSource) {
            const { row, col } = this.state.connectionSource;
            const cell = this.elements.body.querySelector(`.csv-cell[data-row="${row}"][data-col="${col}"]`);
            if (cell) {
                cell.classList.remove('csv-connection-source');
            }
        }
        
        this.state.connectionSource = null;
    }
    
    /**
     * Draw a connection line between two cells
     * @param {number} sourceRow - Source row index
     * @param {number} sourceCol - Source column index
     * @param {number} targetRow - Target row index
     * @param {number} targetCol - Target column index
     * @private
     */
    _drawConnectionLine(sourceRow, sourceCol, targetRow, targetCol) {
        // Get the cell elements
        const sourceCell = this.elements.body.querySelector(`.csv-cell[data-row="${sourceRow}"][data-col="${sourceCol}"]`);
        const targetCell = this.elements.body.querySelector(`.csv-cell[data-row="${targetRow}"][data-col="${targetCol}"]`);
        
        if (!sourceCell || !targetCell) return;
        
        // Get cell positions
        const sourceRect = sourceCell.getBoundingClientRect();
        const targetRect = targetCell.getBoundingClientRect();
        const gridRect = this.elements.grid.getBoundingClientRect();
        
        // Calculate center points relative to the grid
        const sourceX = sourceRect.left + sourceRect.width / 2 - gridRect.left;
        const sourceY = sourceRect.top + sourceRect.height / 2 - gridRect.top;
        const targetX = targetRect.left + targetRect.width / 2 - gridRect.left;
        const targetY = targetRect.top + targetRect.height / 2 - gridRect.top;
        
        // Calculate line length and angle
        const length = Math.sqrt(Math.pow(targetX - sourceX, 2) + Math.pow(targetY - sourceY, 2));
        const angle = Math.atan2(targetY - sourceY, targetX - sourceX) * 180 / Math.PI;
        
        // Create the line element
        const line = document.createElement('div');
        line.className = 'csv-connection-line';
        line.dataset.source = `${sourceRow},${sourceCol}`;
        line.dataset.target = `${targetRow},${targetCol}`;
        line.style.width = `${length}px`;
        line.style.left = `${sourceX}px`;
        line.style.top = `${sourceY}px`;
        line.style.transform = `rotate(${angle}deg)`;
        
        // Add to the grid
        this.elements.grid.appendChild(line);
        this.elements.connectionLines.push(line);
    }
    
    /**
     * Toggle connection mode
     */
    toggleConnectionMode() {
        if (this.state.connecting) {
            this.cancelConnection();
        } else if (this.state.selectedCell) {
            this.startConnection(this.state.selectedCell.row, this.state.selectedCell.col);
        }
    }
    
    /**
     * Insert a new row at the specified index
     * @param {number} index - Row index
     */
    insertRow(index) {
        // Create a new row object
        const newRow = {};
        this.config.data.headers.forEach(header => {
            newRow[header] = '';
        });
        
        // Insert the row
        this.config.data.rows.splice(index, 0, newRow);
        
        // Save state for undo
        this._addToUndoStack('insert-row', { index });
        
        // Re-render the grid
        this._renderGrid();
    }
    
    /**
     * Delete a row at the specified index
     * @param {number} index - Row index
     */
    deleteRow(index) {
        // Save the row for undo
        const row = this.config.data.rows[index];
        
        // Save state for undo
        this._addToUndoStack('delete-row', { index, row });
        
        // Remove the row
        this.config.data.rows.splice(index, 1);
        
        // Re-render the grid
        this._renderGrid();
    }
    
    /**
     * Insert a new column at the specified index
     * @param {number} index - Column index
     */
    insertColumn(index) {
        // Create a new header
        let newHeader = 'Column ' + (this.config.data.headers.length + 1);
        
        // Make sure the header is unique
        let counter = 1;
        while (this.config.data.headers.includes(newHeader)) {
            counter++;
            newHeader = 'Column ' + (this.config.data.headers.length + counter);
        }
        
        // Insert the header
        this.config.data.headers.splice(index, 0, newHeader);
        
        // Add the column to each row
        this.config.data.rows.forEach(row => {
            row[newHeader] = '';
        });
        
        // Save state for undo
        this._addToUndoStack('insert-column', { index, header: newHeader });
        
        // Re-render the grid
        this._renderGrid();
    }
    
    /**
     * Delete a column at the specified index
     * @param {number} index - Column index
     */
    deleteColumn(index) {
        // Get the header
        const header = this.config.data.headers[index];
        
        // Save column data for undo
        const columnData = this.config.data.rows.map(row => row[header]);
        
        // Save state for undo
        this._addToUndoStack('delete-column', { index, header, columnData });
        
        // Remove the header
        this.config.data.headers.splice(index, 1);
        
        // Remove the column from each row
        this.config.data.rows.forEach(row => {
            delete row[header];
        });
        
        // Re-render the grid
        this._renderGrid();
    }
    
    /**
     * Add a new row at the end
     */
    addRow() {
        this.insertRow(this.config.data.rows.length);
    }
    
    /**
     * Add a new column at the end
     */
    addColumn() {
        this.insertColumn(this.config.data.headers.length);
    }
    
    /**
     * Sort the data by a column
     * @param {number} colIndex - Column index
     * @private
     */
    _sortByColumn(colIndex) {
        const header = this.config.data.headers[colIndex];
        
        // Get current data for undo
        const currentOrder = [...this.config.data.rows];
        
        // Save state for undo
        this._addToUndoStack('sort', { colIndex, originalOrder: currentOrder });
        
        // Sort the rows
        this.config.data.rows.sort((a, b) => {
            const aValue = a[header] || '';
            const bValue = b[header] || '';
            
            // Try to use numeric sort if possible
            const aNum = parseFloat(aValue);
            const bNum = parseFloat(bValue);
            
            if (!isNaN(aNum) && !isNaN(bNum)) {
                return aNum - bNum;
            }
            
            // Fallback to string comparison
            return aValue.localeCompare(bValue);
        });
        
        // Re-render the grid
        this._renderGrid();
    }
    
    /**
     * Copy the currently selected cell
     */
    copySelectedCell() {
        if (!this.state.selectedCell) return;
        
        const { row, col } = this.state.selectedCell;
        const header = this.config.data.headers[col];
        const value = this.config.data.rows[row][header] || '';
        
        // Store in clipboard state
        this.state.clipboard = {
            type: 'cell',
            value: value,
            sourceRow: row,
            sourceCol: col
        };
    }
    
    /**
     * Cut the currently selected cell
     */
    cutSelectedCell() {
        if (!this.state.selectedCell) return;
        
        // First copy
        this.copySelectedCell();
        
        // Then clear
        this.clearCell(this.state.selectedCell.row, this.state.selectedCell.col);
    }
    
    /**
     * Paste to the currently selected cell
     */
    pasteToSelectedCell() {
        if (!this.state.selectedCell || !this.state.clipboard) return;
        
        const { row, col } = this.state.selectedCell;
        const header = this.config.data.headers[col];
        const oldValue = this.config.data.rows[row][header] || '';
        const newValue = this.state.clipboard.value || '';
        
        // Save state for undo
        this._addToUndoStack('paste', {
            row,
            col,
            header,
            oldValue,
            newValue
        });
        
        // Update the cell
        this.config.data.rows[row][header] = newValue;
        
        // Update the cell in the DOM
        const cell = this.elements.body.querySelector(`.csv-cell[data-row="${row}"][data-col="${col}"]`);
        if (cell) {
            cell.textContent = newValue;
        }
        
        // Trigger callback if provided
        if (this.config.onCellChange) {
            this.config.onCellChange(row, col, header, oldValue, newValue);
        }
    }
    
    /**
     * Undo the last action
     */
    undo() {
        if (this.state.undoStack.length === 0) return;
        
        // Get the last action
        const action = this.state.undoStack.pop();
        
        // Save current state for redo
        this.state.redoStack.push(action);
        
        // Apply the undo
        switch (action.action) {
            case 'edit-cell':
            case 'paste':
                // Restore the old value
                this.config.data.rows[action.state.row][action.state.header] = action.state.oldValue;
                break;
                
            case 'clear-cell':
                // Restore the old value
                this.config.data.rows[action.state.row][action.state.header] = action.state.oldValue;
                break;
                
            case 'insert-row':
                // Remove the inserted row
                this.config.data.rows.splice(action.state.index, 1);
                break;
                
            case 'delete-row':
                // Restore the deleted row
                this.config.data.rows.splice(action.state.index, 0, action.state.row);
                break;
                
            case 'insert-column':
                // Remove the inserted column
                const header = this.config.data.headers[action.state.index];
                this.config.data.headers.splice(action.state.index, 1);
                this.config.data.rows.forEach(row => {
                    delete row[header];
                });
                break;
                
            case 'delete-column':
                // Restore the deleted column
                this.config.data.headers.splice(action.state.index, 0, action.state.header);
                this.config.data.rows.forEach((row, i) => {
                    row[action.state.header] = action.state.columnData[i];
                });
                break;
                
            case 'sort':
                // Restore the original order
                this.config.data.rows = [...action.state.originalOrder];
                break;
                
            case 'add-connection':
                // Remove the connection
                this.state.connections = this.state.connections.filter(conn => 
                    !(conn.sourceRow === action.state.sourceRow && 
                      conn.sourceCol === action.state.sourceCol && 
                      conn.targetRow === action.state.targetRow && 
                      conn.targetCol === action.state.targetCol)
                );
                break;
        }
        
        // Update the grid
        this._renderGrid();
        
        // Update button states
        this._updateUndoRedoButtons();
    }
    
    /**
     * Redo the last undone action
     */
    redo() {
        if (this.state.redoStack.length === 0) return;
        
        // Get the last undone action
        const action = this.state.redoStack.pop();
        
        // Save current state for undo
        this.state.undoStack.push(action);
        
        // Apply the redo
        switch (action.action) {
            case 'edit-cell':
            case 'paste':
                // Apply the new value
                this.config.data.rows[action.state.row][action.state.header] = action.state.newValue;
                break;
                
            case 'clear-cell':
                // Clear the value
                this.config.data.rows[action.state.row][action.state.header] = '';
                break;
                
            case 'insert-row':
                // Insert a new row
                const newRow = {};
                this.config.data.headers.forEach(header => {
                    newRow[header] = '';
                });
                this.config.data.rows.splice(action.state.index, 0, newRow);
                break;
                
            case 'delete-row':
                // Delete the row
                this.config.data.rows.splice(action.state.index, 1);
                break;
                
            case 'insert-column':
                // Insert the column
                this.config.data.headers.splice(action.state.index, 0, action.state.header);
                this.config.data.rows.forEach(row => {
                    row[action.state.header] = '';
                });
                break;
                
            case 'delete-column':
                // Delete the column
                this.config.data.headers.splice(action.state.index, 1);
                this.config.data.rows.forEach(row => {
                    delete row[action.state.header];
                });
                break;
                
            case 'sort':
                // Re-apply the sort
                this._sortByColumn(action.state.colIndex);
                break;
                
            case 'add-connection':
                // Add the connection back
                this.state.connections.push({
                    sourceRow: action.state.sourceRow,
                    sourceCol: action.state.sourceCol,
                    targetRow: action.state.targetRow,
                    targetCol: action.state.targetCol,
                    type: 'default'
                });
                break;
        }
        
        // Update the grid
        this._renderGrid();
        
        // Update button states
        this._updateUndoRedoButtons();
    }
    
    /**
     * Insert a nested grid into a cell
     * @param {number} row - Row index
     * @param {number} col - Column index
     */
    insertNestedGrid(row, col) {
        const cellKey = `${row},${col}`;
        
        // Create a new CSV viewer for this cell
        const nestedViewer = new CSVGridViewer({
            data: {
                headers: ['Item', 'Value', 'Notes'],
                rows: [
                    { 'Item': 'Item 1', 'Value': '100', 'Notes': '' },
                    { 'Item': 'Item 2', 'Value': '200', 'Notes': '' },
                    { 'Item': 'Item 3', 'Value': '300', 'Notes': '' }
                ]
            },
            editable: true,
            showLineNumbers: true
        });
        
        // Store the nested viewer
        this.state.nestedViewers[cellKey] = nestedViewer;
        
        // Expand the cell
        this.expandCell(row, col);
    }
    
    /**
     * Expand a cell to show nested content
     * @param {number} row - Row index
     * @param {number} col - Column index
     */
    expandCell(row, col) {
        const cellKey = `${row},${col}`;
        
        // Add to expanded cells set
        this.state.expandedCells.add(cellKey);
        
        // Update the cell appearance
        const cell = this.elements.body.querySelector(`.csv-cell[data-row="${row}"][data-col="${col}"]`);
        if (cell) {
            cell.classList.add('expanded');
        }
        
        // Render the nested content
        this._renderNestedContent(row, col);
    }
    
    /**
     * Fold a cell to hide nested content
     * @param {number} row - Row index
     * @param {number} col - Column index
     */
    foldCell(row, col) {
        const cellKey = `${row},${col}`;
        
        // Remove from expanded cells set
        this.state.expandedCells.delete(cellKey);
        
        // Update the cell appearance
        const cell = this.elements.body.querySelector(`.csv-cell[data-row="${row}"][data-col="${col}"]`);
        if (cell) {
            cell.classList.remove('expanded');
        }
        
        // Remove the nested content
        const nestedContent = this.elements.body.querySelector(`.csv-nested-content[data-parent="${cellKey}"]`);
        if (nestedContent) {
            nestedContent.remove();
        }
    }
    
    /**
     * Fold all expanded cells
     */
    foldAll() {
        // Make a copy of the set to avoid modification during iteration
        const expandedCells = [...this.state.expandedCells];
        
        expandedCells.forEach(cellKey => {
            const [row, col] = cellKey.split(',').map(Number);
            this.foldCell(row, col);
        });
    }
    
    /**
     * Unfold all expandable cells
     */
    unfoldAll() {
        // Find all cells with nested content
        this.config.data.headers.forEach((header, colIndex) => {
            this.config.data.rows.forEach((row, rowIndex) => {
                const cellKey = `${rowIndex},${colIndex}`;
                
                // Check if this cell has a nested viewer
                if (this.state.nestedViewers[cellKey]) {
                    this.expandCell(rowIndex, colIndex);
                }
            });
        });
    }
    
    /**
     * Import data from various formats
     */
    importData() {
        // Create a file input
        const input = document.createElement('input');
        input.type = 'file';
        input.accept = '.csv,.json,.txt';
        
        // Handle file selection
        input.addEventListener('change', async (e) => {
            const file = e.target.files[0];
            if (!file) return;
            
            try {
                // Read the file
                const text = await this._readFile(file);
                
                // Parse based on extension
                let data;
                if (file.name.endsWith('.csv')) {
                    data = this._parseCSV(text);
                } else if (file.name.endsWith('.json')) {
                    data = JSON.parse(text);
                } else {
                    // Try to auto-detect
                    if (text.includes(',') && text.includes('\n')) {
                        data = this._parseCSV(text);
                    } else {
                        try {
                            data = JSON.parse(text);
                        } catch (e) {
                            throw new Error('Unsupported file format');
                        }
                    }
                }
                
                // Save current data for undo
                const currentData = JSON.parse(JSON.stringify(this.config.data));
                
                // Save state for undo
                this._addToUndoStack('import', { previousData: currentData });
                
                // Load the data
                this.loadData(data);
            } catch (error) {
                console.error('Error importing data:', error);
                alert('Error importing data: ' + error.message);
            }
        });
        
        // Trigger the file selection
        input.click();
    }
    
    /**
     * Read a file as text
     * @param {File} file - File object
     * @returns {Promise<string>} File contents as text
     * @private
     */
    async _readFile(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = e => resolve(e.target.result);
            reader.onerror = e => reject(e);
            reader.readAsText(file);
        });
    }
    
    /**
     * Export data to CSV
     */
    exportData() {
        // Create CSV content
        const { headers, rows } = this.config.data;
        
        // Create header row
        let csv = headers.join(',') + '\n';
        
        // Add data rows
        rows.forEach(row => {
            const rowValues = headers.map(header => {
                // Escape commas and quotes
                let value = row[header] || '';
                if (value.includes(',') || value.includes('"')) {
                    value = `"${value.replace(/"/g, '""')}"`;
                }
                return value;
            });
            
            csv += rowValues.join(',') + '\n';
        });
        
        // Create a download link
        const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = 'export.csv';
        
        // Trigger the download
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }
}

// If running in a browser environment, add to window
if (typeof window !== 'undefined') {
    window.CSVGridViewer = CSVGridViewer;
}/**
 * CSVGridViewer.js
 * 
 * A spreadsheet-like interface for viewing and manipulating CSV data.
 * Features:
 * - Grid visualization with row/column headers
 * - Cell editing and formatting
 * - Cell connections between spreadsheets
 * - Folding/unfolding of nested content
 * - Import/export capabilities
 */

class CSVGridViewer {
    constructor(options = {}) {
        // Configuration options
        this.config = {
            container: null,               // Container element
            data: null,                    // CSV data object
            path: '',                      // Path to the CSV file
            editable: true,                // Whether cells are editable
            resizable: true,               // Whether columns are resizable
            showLineNumbers: true,         // Whether to show line numbers
            maxHeight: '80vh',             // Maximum height of the grid
            cellMinWidth: 100,             // Minimum cell width
            cellHeight: 32,                // Cell height
            onCellChange: null,            // Callback when a cell value changes
            onSelectCell: null,            // Callback when a cell is selected
            onConnectCell: null,           // Callback when a cell connection is created
            ...options                     // Merge user options
        };
        
        // Internal state
        this.state = {
            selectedCell: null,            // Currently selected cell
            editingCell: null,             // Currently editing cell
            columnWidths: {},              // Custom column widths
            connecting: false,             // Whether in connection mode
            connectionSource: null,        // Source cell for connection
            focusedRow: null,              // Row with focus
            focusedColumn: null,           // Column with focus
            scrollPosition: { x: 0, y: 0 },// Current scroll position
            viewportRows: [],              // Rows currently in viewport
            viewportRange: { start: 0, end: 0 }, // Viewport row range
            expandedCells: new Set(),      // Set of expanded cells
            nestedViewers: {},             // Nested CSV viewers
            connections: [],               // Cell connections
            clipboard: null,               // Clipboard data
            undoStack: [],                 // For undo functionality
            redoStack: []                  // For redo functionality
        };
        
        // Elements
        this.elements = {
            container: null,
            grid: null,
            header: null,
            body: null,
            rowNumbers: null,
            resizeHandles: [],
            connectionLines: []
        };
        
        // Initialize if we have a container
        if (this.config.container) {
            this.initialize();
        }
    }
    
    /**
     * Initialize the grid viewer
     */
    initialize() {
        // Verify we have a container
        if (!this.config.container) {
            throw new Error('Container element is required');
        }
        
        // Create the grid structure
        this._createGridStructure();
        
        // Load data if provided
        if (this.config.data) {
            this.loadData(this.config.data);
        } else if (this.config.path) {
            this.loadFromPath(this.config.path);
        }
        
        // Register event handlers
        this._registerEventHandlers();
        
        return this;
    }
    
    /**
     * Create the grid structure
     * @private
     */
    _createGridStructure() {
        const container = this.config.container;
        container.classList.add('csv-grid-viewer');
        container.innerHTML = '';
        
        // Add CSS styles if not already added
        this._injectStyles();
        
        // Create grid container
        const gridContainer = document.createElement('div');
        gridContainer.className = 'csv-grid-container';
        
        // Create header row
        const headerRow = document.createElement('div');
        headerRow.className = 'csv-header-row';
        
        // Add corner cell if showing line numbers
        if (this.config.showLineNumbers) {
            const cornerCell = document.createElement('div');
            cornerCell.className = 'csv-corner-cell';
            headerRow.appendChild(cornerCell);
        }
        
        // Create grid body
        const gridBody = document.createElement('div');
        gridBody.className = 'csv-grid-body';
        
        // Create row numbers container if needed
        if (this.config.showLineNumbers) {
            const rowNumbers = document.createElement('div');
            rowNumbers.className = 'csv-row-numbers';
            gridContainer.appendChild(rowNumbers);
            this.elements.rowNumbers = rowNumbers;
        }
        
        // Create toolbar
        const toolbar = document.createElement('div');
        toolbar.className = 'csv-grid-toolbar';
        
        // Add toolbar buttons
        toolbar.innerHTML = `
            <div class="csv-toolbar-group">
                <button class="csv-btn csv-btn-add-row" title="Add Row">
                    <i class="fas fa-plus"></i> Row
                </button>
                <button class="csv-btn csv-btn-add-column" title="Add Column">
                    <i class="fas fa-plus"></i> Column
                </button>
                <button class="csv-btn csv-btn-delete-row" title="Delete Row">
                    <i class="fas fa-minus"></i> Row
                </button>
                <button class="csv-btn csv-btn-delete-column" title="Delete Column">
                    <i class="fas fa-minus"></i> Column
                </button>
            </div>
            <div class="csv-toolbar-group">
                <button class="csv-btn csv-btn-connect" title="Connect Cells">
                    <i class="fas fa-link"></i>
                </button>
                <button class="csv-btn csv-btn-fold-all" title="Fold All">
                    <i class="fas fa-compress-alt"></i>
                </button>
                <button class="csv-btn csv-btn-unfold-all" title="Unfold All">
                    <i class="fas fa-expand-alt"></i>
                </button>
            </div>
            <div class="csv-toolbar-group">
                <button class="csv-btn csv-btn-import" title="Import">
                    <i class="fas fa-file-import"></i>
                </button>
                <button class="csv-btn csv-btn-export" title="Export">
                    <i class="fas fa-file-export"></i>
                </button>
            </div>
            <div class="csv-toolbar-group">
                <button class="csv-btn csv-btn-undo" title="Undo" disabled>
                    <i class="fas fa-undo"></i>
                </button>
                <button class="csv-btn csv-btn-redo" title="Redo" disabled>
                    <i class="fas fa-redo"></i>
                </button>
            </div>
        `;
        
        // Assemble the structure
        gridContainer.appendChild(headerRow);
        gridContainer.appendChild(gridBody);
        
        container.appendChild(toolbar);
        container.appendChild(gridContainer);
        
        // Save references
        this.elements.container = container;
        this.elements.grid = gridContainer;
        this.elements.header = headerRow;
        this.elements.body = gridBody;
    }
    
    /**
     * Inject required CSS styles
     * @private
     */
    _injectStyles() {
        const styleId = 'csv-grid-viewer-styles';
        
        // Check if styles already exist
        if (document.getElementById(styleId)) {
            return;
        }
        
        const style = document.createElement('style');
        style.id = styleId;
        style.textContent = `
            .csv-grid-viewer {
                --csv-bg-primary: #1e1e1e;
                --csv-bg-secondary: #252525;
                --csv-bg-header: #333333;
                --csv-text-primary: #f0f0f0;
                --csv-text-secondary: #a0a0a0;
                --csv-border-color: #454545;
                --csv-selected-bg: rgba(30, 150, 255, 0.2);
                --csv-selected-border: #3794ff;
                --csv-hover-bg: rgba(255, 255, 255, 0.05);
                --csv-editing-bg: #2d2d2d;
                
                display: flex;
                flex-direction: column;
                height: 100%;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                color: var(--csv-text-primary);
                background-color: var(--csv-bg-primary);
                position: relative;
                overflow: hidden;
            }
            
            .csv-grid-toolbar {
                display: flex;
                padding: 5px;
                background-color: var(--csv-bg-header);
                border-bottom: 1px solid var(--csv-border-color);
                gap: 10px;
            }
            
            .csv-toolbar-group {
                display: flex;
                gap: 5px;
                border-right: 1px solid var(--csv-border-color);
                padding-right: 10px;
                margin-right: 5px;
            }
            
            .csv-toolbar-group:last-child {
                border-right: none;
            }
            
            .csv-btn {
                background-color: transparent;
                border: 1px solid var(--csv-border-color);
                color: var(--csv-text-primary);
                padding: 4px 8px;
                border-radius: 3px;
                cursor: pointer;
                display: flex;
                align-items: center;
                gap: 5px;
                font-size: 12px;
            }
            
            .csv-btn:hover {
                background-color: var(--csv-hover-bg);
            }
            
            .csv-btn:disabled {
                opacity: 0.5;
                cursor: not-allowed;
            }
            
            .csv-btn i {
                font-size: 14px;
            }
            
            .csv-grid-container {
                display: flex;
                flex-direction: column;
                flex: 1;
                overflow: auto;
                position: relative;
            }
            
            .csv-header-row {
                display: flex;
                position: sticky;
                top: 0;
                z-index: 2;
                background-color: var(--csv-bg-header);
                border-bottom: 1px solid var(--csv-border-color);
            }
            
            .csv-corner-cell {
                min-width: 40px;
                height: ${this.config.cellHeight}px;
                border-right: 1px solid var(--csv-border-color);
                position: sticky;
                left: 0;
                z-index: 3;
                background-color: var(--csv-bg-header);
                display: flex;
                align-items: center;
                justify-content: center;
            }
            
            .csv-header-cell {
                min-width: ${this.config.cellMinWidth}px;
                height: ${this.config.cellHeight}px;
                border-right: 1px solid var(--csv-border-color);
                display: flex;
                align-items: center;
                padding: 0 8px;
                font-weight: bold;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
                position: relative;
                cursor: pointer;
            }
            
            .csv-header-cell:hover {
                background-color: var(--csv-hover-bg);
            }
            
            .csv-resize-handle {
                position: absolute;
                top: 0;
                right: 0;
                width: 4px;
                height: 100%;
                cursor: col-resize;
                z-index: 2;
            }
            
            .csv-resize-handle:hover,
            .csv-resize-handle.resizing {
                background-color: var(--csv-selected-border);
            }
            
            .csv-grid-body {
                display: flex;
                flex-direction: column;
                flex: 1;
                z-index: 1;
            }
            
            .csv-row {
                display: flex;
                height: ${this.config.cellHeight}px;
                border-bottom: 1px solid var(--csv-border-color);
            }
            
            .csv-row:hover {
                background-color: var(--csv-hover-bg);
            }
            
            .csv-row-number {
                min-width: 40px;
                height: ${this.config.cellHeight}px;
                border-right: 1px solid var(--csv-border-color);
                position: sticky;
                left: 0;
                z-index: 2;
                background-color: var(--csv-bg-secondary);
                display: flex;
                align-items: center;
                justify-content: center;
                color: var(--csv-text-secondary);
                font-size: 12px;
            }
            
            .csv-cell {
                min-width: ${this.config.cellMinWidth}px;
                height: ${this.config.cellHeight}px;
                border-right: 1px solid var(--csv-border-color);
                padding: 0 8px;
                display: flex;
                align-items: center;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
                cursor: cell;
            }
            
            .csv-cell.selected {
                background-color: var(--csv-selected-bg);
                border: 1px solid var(--csv-selected-border);
            }
            
            .csv-cell.editing {
                padding: 0;
                background-color: var(--csv-editing-bg);
            }
            
            .csv-cell-edit-input {
                width: 100%;
                height: 100%;
                border: none;
                background-color: transparent;
                color: var(--csv-text-primary);
                font-family: inherit;
                font-size: inherit;
                padding: 0 8px;
                outline: none;
            }
            
            .csv-cell.has-connection {
                position: relative;
            }
            
            .csv-cell.has-connection::after {
                content: '';
                position: absolute;
                right: 5px;
                top: 5px;
                width: 6px;
                height: 6px;
                border-radius: 50%;
                background-color: var(--csv-selected-border);
            }
            
            .csv-cell.expandable {
                cursor: pointer;
                background-color: rgba(100, 100, 150, 0.1);
            }
            
            .csv-cell.expanded {
                border-bottom-width: 0;
            }
            
            .csv-nested-content {
                grid-column: 1 / -1;
                padding: 10px;
                background-color: var(--csv-bg-secondary);
                border: 1px solid var(--csv-border-color);
                border-top: none;
                position: relative;
            }
            
            .csv-connection-line {
                position: absolute;
                pointer-events: none;
                z-index: 10;
                background-color: var(--csv-selected-border);
                height: 2px;
                transform-origin: 0 0;
            }
            
            .csv-connecting .csv-cell:hover {
                background-color: rgba(0, 255, 0, 0.1);
                border: 1px dashed rgba(0, 255, 0, 0.5);
            }
            
            .csv-connection-source {
                background-color: rgba(0, 255, 0, 0.1);
                border: 1px solid rgba(0, 255, 0, 0.5);
            }
            
            /* Right-click context menu */
            .csv-context-menu {
                position: absolute;
                background-color: var(--csv-bg-secondary);
                border: 1px solid var(--csv-border-color);
                border-radius: 3px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
                z-index: 1000;
            }
            
            .csv-context-menu-item {
                padding: 8px 12px;
                cursor: pointer;
                display: flex;
                align-items: center;
                gap: 8px;
            }
            
            .csv-context-menu-item:hover {
                background-color: var(--csv-hover-bg);
            }
            
            .csv-context-menu-separator {
                height: 1px;
                background-color: var(--csv-border-color);
                margin: 5px 0;
            }
        `;
        
        document.head.appendChild(style);
    }
    
    /**
     * Register event handlers
     * @private
     */
    _registerEventHandlers() {
        // Toolbar button handlers
        const toolbar = this.elements.container.querySelector('.csv-grid-toolbar');
        
        // Add row button
        toolbar.querySelector('.csv-btn-add-row').addEventListener('click', () => {
            this.addRow();
        });
        
        // Add column button
        toolbar.querySelector('.csv-btn-add-column').addEventListener('click', () => {
            this.addColumn();
        });
        
        // Delete row button
        toolbar.querySelector('.csv-btn-delete-row').addEventListener('click', () => {
            if (this.state.selectedCell) {
                this.deleteRow(this.state.selectedCell.row);
            }
        });
        
        // Delete column button
        toolbar.querySelector('.csv-btn-delete-column').addEventListener('click', () => {
            if (this.state.selectedCell) {
                this.deleteColumn(this.state.selectedCell.col);
            }
        });
        
        // Connect cells button
        toolbar.querySelector('.csv-btn-connect').addEventListener('click', () => {
            this.toggleConnectionMode();
        });
        
        // Import button
        toolbar.querySelector('.csv-btn-import').addEventListener('click', () => {
            this.importData();
        });
        
        // Export button
        toolbar.querySelector('.csv-btn-export').addEventListener('click', () => {
            this.exportData();
        });
        
        // Undo button
        toolbar.querySelector('.csv-btn-undo').addEventListener('click', () => {
            this.undo();
        });
        
        // Redo button
        toolbar.querySelector('.csv-btn-redo').addEventListener('click', () => {
            this.redo();
        });
        
        // Fold all button
        toolbar.querySelector('.csv-btn-fold-all').addEventListener('click', () => {
            this.foldAll();
        });
        
        // Unfold all button
        toolbar.querySelector('.csv-btn-unfold-all').addEventListener('click', () => {
            this.unfoldAll();
        });
        
        // Grid keyboard events
        this.elements.grid.addEventListener('keydown', (e) => this._handleGridKeydown(e));
        
        // Grid mouse events for context menu
        this.elements.grid.addEventListener('contextmenu', (e) => this._handleContextMenu(e));
        
        // Document click to hide context menu
        document.addEventListener('click', () => {
            const menu = document.querySelector('.csv-context-menu');
            if (menu) {
                menu.remove();
            }
        });
    }
    
    /**
     * Handle keyboard events on the grid
     * @param {KeyboardEvent} e - Keyboard event
     * @private
     */
    _handleGridKeydown(e) {
        // Only process if we have a selected cell
        if (!this.state.selectedCell) return;
        
        const { row, col } = this.state.selectedCell;
        
        // Handle navigation keys
        if (e.key === 'ArrowUp' && !e.shiftKey) {
            e.preventDefault();
            this.selectCell(Math.max(0, row - 1), col);
        } else if (e.key === 'ArrowDown' && !e.shiftKey) {
            e.preventDefault();
            this.selectCell(Math.min(this.config.data.rows.length - 1, row + 1), col);
        } else if (e.key === 'ArrowLeft' && !e.shiftKey) {
            e.preventDefault();
            this.selectCell(row, Math.max(0, col - 1));
        } else if (e.key === 'ArrowRight' && !e.shiftKey) {
            e.preventDefault();
            this.selectCell(row, Math.min(this.config.data.headers.length - 1, col + 1));
        } else if (e.key === 'Tab') {
            e.preventDefault();
            if (e.shiftKey) {
                // Move to previous cell or previous row last cell
                if (col > 0) {
                    this.selectCell(row, col - 1);
                } else if (row > 0) {
                    this.selectCell(row - 1, this.config.data.headers.length - 1);
                }
            } else {
                // Move to next cell or next row first cell
                if (col < this.config.data.headers.length - 1) {
                    this.selectCell(row, col + 1);
                } else if (row < this.config.data.rows.length - 1) {
                    this.selectCell(row + 1, 0);
                }
            }
        } else if (e.key === 'Enter') {
            e.preventDefault();
            if (!this.state.editingCell) {
                // Start editing if not already editing
                this.editCell(row, col);
            } else {
                // Finish editing and move to next row
                this.finishEditing();
                if (row < this.config.data.rows.length - 1) {
                    this.selectCell(row + 1, col);
                }
            }
        } else if (e.key === 'Escape' && this.state.editingCell) {
            e.preventDefault();
            this.cancelEditing();
        } else if ((e.key === 'Delete' || e.key === 'Backspace') && !this.state.editingCell) {
            e.preventDefault();
            this.clearCell(row, col);
        } else if (e.key === 'c' && e.ctrlKey) {
            e.preventDefault();
            this.copySelectedCell();
        } else if (e.key === 'x' && e.ctrlKey) {
            e.preventDefault();
            this.cutSelectedCell();
        } else if (e.key === 'v' && e.ctrlKey) {
            e.preventDefault();
            this.pasteToSelectedCell();
        } else if (e.key === 'z' && e.ctrlKey) {
            e.preventDefault();
            this.undo();
        } else if (e.key === 'y' && e.ctrlKey) {
            e.preventDefault();
            this.redo();
        } else if (!this.state.editingCell && e.key.length === 1 && !e.ctrlKey && !e.metaKey) {
            // Start editing with the typed character
            this.editCell(row, col, e.key);
            e.preventDefault();
        }
    }
    
    /**
     * Handle right-click context menu
     * @param {MouseEvent} e - Mouse event
     * @private
     */
    _handleContextMenu(e) {
        e.preventDefault();
        
        // Remove any existing context menu
        const existingMenu = document.querySelector('.csv-context-menu');
        if (existingMenu) {
            existingMenu.remove();
        }
        
        // Get the target cell
        const cell = e.target.closest('.csv-cell');
        if (!cell) return;
        
        // Get cell position
        const row = parseInt(cell.dataset.row);
        const col = parseInt(cell.dataset.col);
        
        // Select the cell
        this.selectCell(row, col);
        
        // Create the context menu
        const menu = document.createElement('div');
        menu.className = 'csv-context-menu';
        menu.style.left = `${e.pageX}px`;
        menu.style.top = `${e.pageY}px`;
        
        // Add menu items
        menu.innerHTML = `
            <div class="csv-context-menu-item" data-action="edit">
                <i class="fas fa-edit"></i> Edit Cell
            </div>
            <div class="csv-context-menu-item" data-action="connect">
                <i class="fas fa-link"></i> Create Connection
            </div>
            <div class="csv-context-menu-item" data-action="insert-nested">
                <i class="fas fa-table"></i> Insert Nested Grid
            </div>
            <div class="csv-context-menu-separator"></div>
            <div class="csv-context-menu-item" data-action="copy">
                <i class="fas fa-copy"></i> Copy
            </div>
            <div class="csv-context-menu-item" data-action="cut">
                <i class="fas fa-cut"></i> Cut
            </div>
            <div class="csv-context-menu-item" data-action="paste">
                <i class="fas fa-paste"></i> Paste
            </div>
            <div class="csv-context-menu-separator"></div>
            <div class="csv-context-menu-item" data-action="insert-row-above">
                <i class="fas fa-plus"></i> Insert Row Above
            </div>
            <div class="csv-context-menu-item" data-action="insert-row-below">
                <i class="fas fa-plus"></i> Insert Row Below
            </div>
            <div class="csv-context-menu-item" data-action="insert-column-left">
                <i class="fas fa-plus"></i> Insert Column Left
            </div>
            <div class="csv-context-menu-item" data-action="insert-column-right">
                <i class="fas fa-plus"></i> Insert Column Right
            </div>
            <div class="csv-context-menu-separator"></div>
            <div class="csv-context-menu-item" data-action="delete-row">
                <i class="fas fa-trash"></i> Delete Row
            </div>
            <div class="csv-context-menu-item" data-action="delete-column">
                <i class="fas fa-trash"></i> Delete Column
            </div>
        `;
        
        // Add event handlers
        menu.querySelectorAll('.csv-context-menu-item').forEach(item => {
            item.addEventListener('click', () => {
                const action = item.dataset.action;
                
                switch (action) {
                    case 'edit':
                        this.editCell(row, col);
                        break;
                    case 'connect':
                        this.startConnection(row, col);
                        break;
                    case 'insert-nested':
                        this.insertNestedGrid(row, col);
                        break;
                    case 'copy':
                        this.copySelectedCell();
                        break;
                    case 'cut':
                        this.cutSelectedCell();
                        break;
                    case 'paste':
                        this.pasteToSelectedCell();
                        break;
                    case 'insert-row-above':
                        this.insertRow(row);
                        break;
                    case 'insert-row-below':
                        this.insertRow(row + 1);
                        break;
                    case 'insert-column-left':
                        this.insertColumn(col);
                        break;
                    case 'insert-column-right':
                        this.insertColumn(col + 1);
                        break;
                    case 'delete-row':
                        this.deleteRow(row);
                        break;
                    case 'delete-column':
                        this.deleteColumn(col);
                        break;
                }
                
                // Remove the menu
                menu.remove();
            });
        });
        
        // Add to document
        document.body.appendChild(menu);
    }
    
    /**
     * Load data into the grid
     * @param {Object} data - The CSV data object
     */
    loadData(data) {
        this.config.data = data;
        this._renderGrid();
        
        // Enable or disable undo/redo buttons
        this._updateUndoRedoButtons();
    }
    
    /**
     * Load CSV data from a path
     * @param {string} path - Path to the CSV file
     */
    async loadFromPath(path) {
        try {
            const response = await fetch(path);
            if (!response.ok) {
                throw new Error(`Failed to load CSV: ${response.status} ${response.statusText}`);
            }
            
            const text = await response.text();
            const data = this._parseCSV(text);
            
            this.config.path = path;
            this.loadData(data);
        } catch (error) {
            console.error('Error loading CSV from path:', error);
            // Load empty data
            this.loadData({
                headers: ['Column 1', 'Column 2', 'Column 3'],
                rows: [
                    { 'Column 1': '', 'Column 2': '', 'Column 3': '' },
                    { 'Column 1': '', 'Column 2': '', 'Column 3': '' },
                    { 'Column 1': '', 'Column 2': '', 'Column 3': '' }
                ]
            });
        }
    }
    
    /**
     * Parse CSV text into structured data
     * @param {string} text - CSV text content
     * @returns {Object} Parsed CSV data
     * @private
     */
    _parseCSV(text) {
        const lines = text.split('\n');
        const headers = lines[0].split(',').map(header => header.trim());
        
        const rows = lines.slice(1).filter(line => line.trim()).map(line => {
            const values = line.split(',');
            const row = {};
            
            headers.forEach((header, index) => {
                row[header] = values[index] ? values[index].trim() : '';
            });
            
            return row;
        });
        
        return { headers, rows };
    }
    
    /**
     * Render the grid with current data
     * @private
     */
    _renderGrid() {
        if (!this.config.data) return;
        
        const { headers, rows } = this.config.data;
        
        // Clear existing content
        this.elements.header.innerHTML = '';
        this.elements.body.innerHTML = '';
        
        if (this.elements.rowNumbers) {
            this.elements.rowNumbers.innerHTML = '';
        }
        
        // Add corner cell if showing line numbers
        if (this.config.showLineNumbers) {
            const cornerCell = document.createElement('div');
            cornerCell.className = 'csv-corner-cell';
            this.elements.header.appendChild(cornerCell);
        }
        
        // Add header cells
        headers.forEach((header, colIndex) => {
            const headerCell = document.createElement('div');
            headerCell.className = 'csv-header-cell';
            headerCell.textContent = header;
            headerCell.dataset.col = colIndex;
            
            // Apply custom width if set
            if (this.state.columnWidths[colIndex]) {
                headerCell.style.width = `${this.state.columnWidths[colIndex]}px`;
            }
            
            // Add click handler for sorting
            headerCell.addEventListener('click', () => {
                this._sortByColumn(colIndex);
            });
            
            // Add resize handle if resizable
            if (this.config.resizable) {
                const resizeHandle = document.createElement('div');
                resizeHandle.className = 'csv-resize-handle';
                resizeHandle.dataset.col = colIndex;
                
                // Add resize event handlers
                this._addResizeHandlers(resizeHandle);
                
                headerCell.appendChild(resizeHandle);
                this.elements.resizeHandles.push(resizeHandle);
            }
            
            this.elements.header.appendChild(headerCell);
        });
        
        // Add rows
        rows.forEach((rowData, rowIndex) => {
            const rowElement = document.createElement('div');
            rowElement.className = 'csv-row';
            rowElement.dataset.row = rowIndex;
            
            // Add row number if needed
            if (this.config.showLineNumbers) {
                const rowNumber = document.createElement('div');
                rowNumber.className = 'csv-row-number';
                rowNumber.textContent = rowIndex + 1;
                rowElement.appendChild(rowNumber);
            }
            
            // Add cells
            headers.forEach((header, colIndex) => {
                const cellElement = document.createElement('div');
                cellElement.className = 'csv-cell';
                cellElement.dataset.row = rowIndex;
                cellElement.dataset.col = colIndex;
                cellElement.dataset.header = header;
                cellElement.textContent = rowData[header] || '';
                
                // Apply custom width if set
                if (this.state.columnWidths[colIndex]) {
                    cellElement.style.width = `${this.state.columnWidths[colIndex]}px`;
                }
                
                // Check if this cell has a connection
                if (this._cellHasConnection(rowIndex, colIndex)) {
                    cellElement.classList.add('has-connection');
                }
                
                // Add nested content if this cell is expanded
                if (this._isCellExpanded(rowIndex, colIndex)) {
                    cellElement.classList.add('expanded');
                    // Nested content added separately to avoid click handler issues
                }
                
                // Add click handler
                cellElement.addEventListener('click', (e) => {
                    // Check if we're in connection mode
                    if (this.state.connecting) {
                        this.completeConnection(rowIndex, colIndex);
                    } else {
                        this.selectCell(rowIndex, colIndex);
                        
                        // Double click starts editing
                        if (e.detail === 2 && this.config.editable) {
                            this.editCell(rowIndex, colIndex);
                        }
                    }
                });
                
                rowElement.appendChild(cellElement);
            });
            
            this.elements.body.appendChild(rowElement);
            
            // Add nested content if any cell in this row is expanded
            headers.forEach((header, colIndex) => {
                if (this._isCellExpanded(rowIndex, colIndex)) {
                    this._renderNestedContent(rowIndex, colIndex);
                }
            });
        });
    }
    
    /**
     * Add resize handlers to column resize handles
     * @param {HTMLElement} handle - Resize handle element
     * @private
     */
    _addResizeHandlers(handle) {
        let startX, startWidth, colIndex;
        
        handle.addEventListener('mousedown', (e) => {
            e.preventDefault();
            e.stopPropagation();
            
            colIndex = parseInt(handle.dataset.col);
            const headerCell = this.elements.header.children[colIndex + (this.config.showLineNumbers ? 1 : 0)];
            startX = e.clientX;
            startWidth = headerCell.offsetWidth;
            
            handle.classList.add('resizing');
            
            // Add document-level event handlers
            document.addEventListener('mousemove', handleMouseMove);
            document.addEventListener('mouseup', handleMouseUp);
        });
        
        const handleMouseMove = (e) => {
            if (!handle.classList.contains('resizing')) return;
            
            const width = Math.max(startWidth + e.clientX - startX, this.config.cellMinWidth);
            
            // Update column width in state
            this.state.columnWidths[colIndex] = width;
            
            // Update header cell width
            const headerCell = this.elements.header.children[colIndex + (this.config.showLineNumbers ? 1 : 0)];
            headerCell.style.width = `${width}px`;
            
            // Update all cells in this column
            const cells = this.elements.body.querySelectorAll(`.csv-cell[data-col="${colIndex}"]`);
            cells.forEach(cell => {
                cell.style.width = `${width}px`;
            });
        };
        // cutted here at the end
    }    
}    
        //const handleMouseUp = () => {
            