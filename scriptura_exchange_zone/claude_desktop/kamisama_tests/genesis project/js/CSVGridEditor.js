// CSVGridEditor.js - Extends your existing CSVGridViewer with editing capabilities

class CSVGridEditor {
    constructor(container, options = {}) {
        this.container = typeof container === 'string' ? document.getElementById(container) : container;
        this.options = {
            editable: true,
            allowAddRows: true,
            allowAddColumns: true,
            allowDelete: true,
            maxRows: 10000,
            maxColumns: 100,
            ...options
        };
        
        this.data = null;
        this.currentFileId = null;
        this.isModified = false;
        this.undoStack = [];
        this.redoStack = [];
        
        this.initUI();
    }
    
    initUI() {
        // Create the main grid container
        this.container.innerHTML = `
            <div class="csv-grid-toolbar">
                <button id="add-row-btn" title="Add Row"><i class="fas fa-plus-square"></i> Row</button>
                <button id="add-col-btn" title="Add Column"><i class="fas fa-plus-square"></i> Column</button>
                <button id="delete-btn" title="Delete Selected"><i class="fas fa-trash"></i></button>
                <span class="separator"></span>
                <button id="save-btn" title="Save Changes"><i class="fas fa-save"></i> Save</button>
                <button id="undo-btn" title="Undo" disabled><i class="fas fa-undo"></i></button>
                <button id="redo-btn" title="Redo" disabled><i class="fas fa-redo"></i></button>
                <span class="flex-spacer"></span>
                <div class="file-status">No file loaded</div>
            </div>
            <div class="csv-grid-container">
                <table class="csv-grid">
                    <thead>
                        <tr>
                            <th class="row-header">#</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
            <div class="csv-grid-footer">
                <span class="row-count">0 rows</span>
                <span class="separator">|</span>
                <span class="col-count">0 columns</span>
                <span class="selection-info"></span>
            </div>
        `;
        
        // Get references to elements
        this.gridTable = this.container.querySelector('.csv-grid');
        this.gridHeader = this.gridTable.querySelector('thead tr');
        this.gridBody = this.gridTable.querySelector('tbody');
        this.fileStatus = this.container.querySelector('.file-status');
        this.rowCountElement = this.container.querySelector('.row-count');
        this.colCountElement = this.container.querySelector('.col-count');
        this.selectionInfo = this.container.querySelector('.selection-info');
        
        // Set up event listeners
        this.setupEventListeners();
    }
    
    setupEventListeners() {
        // Button event listeners
        const addRowBtn = this.container.querySelector('#add-row-btn');
        const addColBtn = this.container.querySelector('#add-col-btn');
        const deleteBtn = this.container.querySelector('#delete-btn');
        const saveBtn = this.container.querySelector('#save-btn');
        const undoBtn = this.container.querySelector('#undo-btn');
        const redoBtn = this.container.querySelector('#redo-btn');
        
        addRowBtn.addEventListener('click', () => this.addRow());
        addColBtn.addEventListener('click', () => this.addColumn());
        deleteBtn.addEventListener('click', () => this.deleteSelected());
        saveBtn.addEventListener('click', () => this.saveChanges());
        undoBtn.addEventListener('click', () => this.undo());
        redoBtn.addEventListener('click', () => this.redo());
        
        // Grid event listeners
        this.gridTable.addEventListener('click', (e) => this.handleGridClick(e));
        this.gridTable.addEventListener('dblclick', (e) => this.handleGridDoubleClick(e));
        this.gridTable.addEventListener('keydown', (e) => this.handleGridKeyDown(e));
        
        // Selection handling with mouse drag
        this.gridTable.addEventListener('mousedown', (e) => this.startSelection(e));
        document.addEventListener('mousemove', (e) => this.updateSelection(e));
        document.addEventListener('mouseup', () => this.endSelection());
    }
    
    loadData(data, fileId = null) {
        if (!data || !data.headers || !data.rows) {
            console.error('Invalid data format');
            return false;
        }
        
        // Before loading new data, clear any pending changes
        this.clearUndoRedo();
        this.isModified = false;
        
        this.data = {
            headers: [...data.headers],
            rows: data.rows.map(row => ({...row}))  // Create a deep copy
        };
        this.currentFileId = fileId;
        
        // Update file status
        if (fileId) {
            this.fileStatus.textContent = `File: ${fileId}`;
        } else {
            this.fileStatus.textContent = 'Unsaved Data';
        }
        
        this.renderGrid();
        return true;
    }
    
    renderGrid() {
        if (!this.data) return;
        
        // Clear existing grid
        while (this.gridHeader.children.length > 1) {
            this.gridHeader.removeChild(this.gridHeader.lastChild);
        }
        this.gridBody.innerHTML = '';
        
        // Add column headers
        this.data.headers.forEach((header, index) => {
            const th = document.createElement('th');
            th.textContent = header;
            th.dataset.colIndex = index;
            th.className = 'column-header';
            th.title = header;
            this.gridHeader.appendChild(th);
        });
        
        // Add rows
        this.data.rows.forEach((row, rowIndex) => {
            const tr = document.createElement('tr');
            
            // Add row header (row number)
            const th = document.createElement('th');
            th.textContent = rowIndex + 1;
            th.className = 'row-header';
            tr.appendChild(th);
            
            // Add cells
            this.data.headers.forEach((header, colIndex) => {
                const td = document.createElement('td');
                td.textContent = row[header] !== undefined ? row[header] : '';
                td.dataset.rowIndex = rowIndex;
                td.dataset.colIndex = colIndex;
                td.dataset.header = header;
                tr.appendChild(td);
            });
            
            this.gridBody.appendChild(tr);
        });
        
        // Update counters
        this.updateCounters();
    }
    
    updateCounters() {
        if (!this.data) return;
        
        this.rowCountElement.textContent = `${this.data.rows.length} rows`;
        this.colCountElement.textContent = `${this.data.headers.length} columns`;
    }
    
    addRow(atIndex = null) {
        if (!this.data || !this.options.allowAddRows) return;
        
        // Don't exceed maximum rows
        if (this.data.rows.length >= this.options.maxRows) {
            alert(`Cannot add more rows. Maximum limit (${this.options.maxRows}) reached.`);
            return;
        }
        
        // Create a new empty row
        const newRow = {};
        this.data.headers.forEach(header => {
            newRow[header] = '';
        });
        
        // Save state for undo
        this.saveState();
        
        // Insert the row at the specified index or at the end
        if (atIndex !== null && atIndex >= 0 && atIndex <= this.data.rows.length) {
            this.data.rows.splice(atIndex, 0, newRow);
        } else {
            this.data.rows.push(newRow);
        }
        
        this.isModified = true;
        this.renderGrid();
        
        // Focus the first cell of the new row
        const newRowIndex = atIndex !== null ? atIndex : this.data.rows.length - 1;
        if (this.data.headers.length > 0) {
            const cell = this.gridBody.querySelector(`tr:nth-child(${newRowIndex + 1}) td:first-child`);
            if (cell) {
                cell.click();
            }
        }
    }
    
    addColumn(atIndex = null) {
        if (!this.data || !this.options.allowAddColumns) return;
        
        // Don't exceed maximum columns
        if (this.data.headers.length >= this.options.maxColumns) {
            alert(`Cannot add more columns. Maximum limit (${this.options.maxColumns}) reached.`);
            return;
        }
        
        // Create a unique column name
        let colName = 'Column';
        let counter = this.data.headers.length + 1;
        let newHeader = `${colName}${counter}`;
        
        while (this.data.headers.includes(newHeader)) {
            counter++;
            newHeader = `${colName}${counter}`;
        }
        
        // Save state for undo
        this.saveState();
        
        // Insert the new column at the specified index or at the end
        if (atIndex !== null && atIndex >= 0 && atIndex <= this.data.headers.length) {
            this.data.headers.splice(atIndex, 0, newHeader);
        } else {
            this.data.headers.push(newHeader);
        }
        
        // Add the new column to each row
        this.data.rows.forEach(row => {
            row[newHeader] = '';
        });
        
        this.isModified = true;
        this.renderGrid();
        
        // Optional: Open column rename dialog
        this.promptRenameColumn(newHeader);
    }
    
    promptRenameColumn(header) {
        const newName = prompt('Enter column name:', header);
        if (newName && newName !== header && !this.data.headers.includes(newName)) {
            this.renameColumn(header, newName);
        }
    }
    
    renameColumn(oldHeader, newHeader) {
        if (!this.data || !oldHeader || !newHeader) return;
        
        // Validate the new header is unique
        if (this.data.headers.includes(newHeader)) {
            alert('Column name already exists. Please choose a different name.');
            return;
        }
        
        // Save state for undo
        this.saveState();
        
        // Update the header in the headers array
        const headerIndex = this.data.headers.indexOf(oldHeader);
        if (headerIndex !== -1) {
            this.data.headers[headerIndex] = newHeader;
            
            // Update the header in all rows
            this.data.rows.forEach(row => {
                row[newHeader] = row[oldHeader];
                delete row[oldHeader];
            });
            
            this.isModified = true;
            this.renderGrid();
        }
    }
    
    deleteSelected() {
        // Implementation of deletion for selected rows/columns
        // This would involve tracking selected cells and removing them
        alert('Delete functionality will be implemented');
    }
    
    saveChanges() {
        if (!this.data || !this.isModified) return;
        
        // Here you would integrate with your file system or storage mechanism
        // For now, we'll just log the data
        console.log('Saving data:', this.data);
        
        // If your Genesis system has a saveFile method, you could use it:
        if (window.genesisSystem && window.genesisSystem.saveFile) {
            window.genesisSystem.saveFile(this.currentFileId, this.data);
        }
        
        this.isModified = false;
        this.fileStatus.textContent = this.currentFileId ? `File: ${this.currentFileId} (Saved)` : 'Saved Data';
        
        // Notify listeners that data was saved
        this.dispatchEvent('dataSaved', { fileId: this.currentFileId, data: this.data });
    }
    
    handleGridClick(e) {
        const cell = e.target.closest('td');
        if (!cell) return;
        
        // Handle cell selection
        this.selectCell(cell);
    }
    
    handleGridDoubleClick(e) {
        const cell = e.target.closest('td');
        if (!cell || !this.options.editable) return;
        
        // Start editing the cell
        this.startCellEdit(cell);
    }
    
    startCellEdit(cell) {
        const rowIndex = parseInt(cell.dataset.rowIndex);
        const header = cell.dataset.header;
        const currentValue = this.data.rows[rowIndex][header] || '';
        
        // Create an input element for editing
        const input = document.createElement('input');
        input.type = 'text';
        input.value = currentValue;
        input.className = 'cell-editor';
        
        // Replace the cell content with the input
        cell.textContent = '';
        cell.appendChild(input);
        
        // Focus the input and select all text
        input.focus();
        input.select();
        
        // Handle input events
        input.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                this.finishCellEdit(cell, input.value);
            } else if (e.key === 'Escape') {
                this.cancelCellEdit(cell, currentValue);
            }
        });
        
        // Handle blur event to finish editing
        input.addEventListener('blur', () => {
            this.finishCellEdit(cell, input.value);
        });
    }
    
    finishCellEdit(cell, newValue) {
        const rowIndex = parseInt(cell.dataset.rowIndex);
        const header = cell.dataset.header;
        const currentValue = this.data.rows[rowIndex][header];
        
        // Only make a change if the value is different
        if (newValue !== currentValue) {
            // Save state for undo
            this.saveState();
            
            // Update the data
            this.data.rows[rowIndex][header] = newValue;
            this.isModified = true;
        }
        
        // Update the cell display
        cell.textContent = newValue;
        
        // Restore selection
        this.selectCell(cell);
    }
    
    cancelCellEdit(cell, originalValue) {
        // Restore the original value
        cell.textContent = originalValue;
        
        // Restore selection
        this.selectCell(cell);
    }
    
    selectCell(cell) {
        // Clear previous selections
        this.gridTable.querySelectorAll('.selected').forEach(el => {
            el.classList.remove('selected');
        });
        
        // Add selected class to the cell
        cell.classList.add('selected');
        
        // Update selection info
        const rowIndex = parseInt(cell.dataset.rowIndex);
        const colIndex = parseInt(cell.dataset.colIndex);
        const header = cell.dataset.header;
        
        this.selectionInfo.textContent = `Selected: R${rowIndex + 1}, C${colIndex + 1} (${header})`;
        
        // Dispatch selection event
        this.dispatchEvent('cellSelected', {
            rowIndex,
            colIndex,
            header,
            value: this.data.rows[rowIndex][header]
        });
    }
    
    // Undo/Redo functionality
    saveState() {
        if (!this.data) return;
        
        // Create a deep copy of the current state
        const state = {
            headers: [...this.data.headers],
            rows: this.data.rows.map(row => ({...row}))
        };
        
        this.undoStack.push(state);
        this.redoStack = []; // Clear redo stack when a new action is performed
        
        // Enable/disable undo/redo buttons
        this.updateUndoRedoButtons();
    }
    
    undo() {
        if (this.undoStack.length === 0) return;
        
        // Save current state to redo stack
        const currentState = {
            headers: [...this.data.headers],
            rows: this.data.rows.map(row => ({...row}))
        };
        this.redoStack.push(currentState);
        
        // Restore previous state
        const previousState = this.undoStack.pop();
        this.data = previousState;
        this.isModified = true;
        
        this.renderGrid();
        this.updateUndoRedoButtons();
    }
    
    redo() {
        if (this.redoStack.length === 0) return;
        
        // Save current state to undo stack
        const currentState = {
            headers: [...this.data.headers],
            rows: this.data.rows.map(row => ({...row}))
        };
        this.undoStack.push(currentState);
        
        // Restore next state
        const nextState = this.redoStack.pop();
        this.data = nextState;
        this.isModified = true;
        
        this.renderGrid();
        this.updateUndoRedoButtons();
    }
    
    updateUndoRedoButtons() {
        const undoBtn = this.container.querySelector('#undo-btn');
        const redoBtn = this.container.querySelector('#redo-btn');
        
        if (undoBtn) undoBtn.disabled = this.undoStack.length === 0;
        if (redoBtn) redoBtn.disabled = this.redoStack.length === 0;
    }
    
    clearUndoRedo() {
        this.undoStack = [];
        this.redoStack = [];
        this.updateUndoRedoButtons();
    }
    
    // Event handling utilities
    dispatchEvent(name, detail) {
        const event = new CustomEvent(`csv-grid-${name}`, { detail });
        this.container.dispatchEvent(event);
    }
    
    // Selection with mouse drag
    startSelection(e) {
        // Implementation for mouse drag selection
        // This would track start cell and allow for range selection
    }
    
    updateSelection(e) {
        // Update selection range during mouse drag
    }
    
    endSelection() {
        // Finalize selection after mouse drag ends
    }
    
    handleGridKeyDown(e) {
        // Handle keyboard navigation and editing shortcuts
        // For example: Tab to move between cells, Enter to edit, Delete to clear
    }
}