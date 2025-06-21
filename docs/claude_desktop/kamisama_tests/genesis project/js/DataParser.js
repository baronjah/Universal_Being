/**
 * DataParser.js
 * 
 * A utility for parsing, transforming, and converting between different data formats.
 * Supports CSV, JSON, XML, and structured text formats.
 */

class DataParser {
    constructor() {
        // Parser configuration
        this.config = {
            csvDelimiter: ',',
            csvQuoteChar: '"',
            csvEscapeChar: '"',
            csvHeaderRow: true,
            jsonIndent: 2,
            xmlIndent: 2,
            defaultEncoding: 'utf-8'
        };
        
        // Cache for parsed data
        this.cache = new Map();
        
        // Supported format handlers
        this.formatHandlers = {
            'csv': {
                parse: this.parseCSV.bind(this),
                stringify: this.stringifyCSV.bind(this),
                detect: this._isCSV.bind(this)
            },
            'json': {
                parse: this.parseJSON.bind(this),
                stringify: this.stringifyJSON.bind(this),
                detect: this._isJSON.bind(this)
            },
            'xml': {
                parse: this.parseXML.bind(this),
                stringify: this.stringifyXML.bind(this),
                detect: this._isXML.bind(this)
            },
            'txt': {
                parse: this.parseTXT.bind(this),
                stringify: this.stringifyTXT.bind(this),
                detect: () => true // Default fallback
            }
        };
    }
    
    /**
     * Detect the format of a string
     * @param {string} data - Data string to analyze
     * @returns {string} Detected format ('csv', 'json', 'xml', 'txt')
     */
    detectFormat(data) {
        if (!data || typeof data !== 'string') {
            return 'txt';
        }
        
        // Try each format detector
        for (const [format, handler] of Object.entries(this.formatHandlers)) {
            if (handler.detect && handler.detect(data)) {
                return format;
            }
        }
        
        // Default to text
        return 'txt';
    }
    
    /**
     * Parse data from any format
     * @param {string} data - Data string to parse
     * @param {string} format - Format to parse as (optional, auto-detected if not provided)
     * @param {object} options - Parsing options
     * @returns {any} Parsed data
     */
    parse(data, format = null, options = {}) {
        // Auto-detect format if not provided
        if (!format) {
            format = this.detectFormat(data);
        }
        
        // Get the appropriate parser
        const handler = this.formatHandlers[format];
        if (!handler || !handler.parse) {
            throw new Error(`Unsupported format: ${format}`);
        }
        
        try {
            // Parse the data
            return handler.parse(data, options);
        } catch (error) {
            console.error(`Error parsing ${format} data:`, error);
            throw error;
        }
    }
    
    /**
     * Convert data to a specific format
     * @param {any} data - Data to convert
     * @param {string} format - Target format
     * @param {object} options - Conversion options
     * @returns {string} Data in the target format
     */
    stringify(data, format, options = {}) {
        // Get the appropriate stringifier
        const handler = this.formatHandlers[format];
        if (!handler || !handler.stringify) {
            throw new Error(`Unsupported format: ${format}`);
        }
        
        try {
            // Convert the data
            return handler.stringify(data, options);
        } catch (error) {
            console.error(`Error stringifying to ${format}:`, error);
            throw error;
        }
    }
    
    /**
     * Convert data from one format to another
     * @param {string} data - Input data string
     * @param {string} fromFormat - Source format
     * @param {string} toFormat - Target format
     * @param {object} options - Conversion options
     * @returns {string} Converted data
     */
    convert(data, fromFormat, toFormat, options = {}) {
        // Parse the input data
        const parsed = this.parse(data, fromFormat, options);
        
        // Convert to the target format
        return this.stringify(parsed, toFormat, options);
    }
    
    /**
     * Parse CSV data into a structured object
     * @param {string} csv - CSV string
     * @param {object} options - Parsing options
     * @returns {object} Parsed data with headers and rows
     */
    parseCSV(csv, options = {}) {
        // Merge options with defaults
        const opts = {
            delimiter: options.delimiter || this.config.csvDelimiter,
            quoteChar: options.quoteChar || this.config.csvQuoteChar,
            escapeChar: options.escapeChar || this.config.csvEscapeChar,
            headerRow: options.headerRow !== undefined ? options.headerRow : this.config.csvHeaderRow,
            skipEmptyLines: options.skipEmptyLines !== undefined ? options.skipEmptyLines : true,
            dynamicTyping: options.dynamicTyping !== undefined ? options.dynamicTyping : false
        };
        
        // Split into lines
        const lines = csv.split(/\r?\n/);
        
        // Filter out empty lines if requested
        const filteredLines = opts.skipEmptyLines ? 
            lines.filter(line => line.trim() !== '') : lines;
        
        if (filteredLines.length === 0) {
            return { headers: [], rows: [] };
        }
        
        // Parse header row if present
        let headers = [];
        let startIndex = 0;
        
        if (opts.headerRow) {
            headers = this._parseCSVLine(filteredLines[0], opts);
            startIndex = 1;
        } else {
            // Generate numeric headers (0, 1, 2, ...)
            const firstRow = this._parseCSVLine(filteredLines[0], opts);
            headers = firstRow.map((_, idx) => String(idx));
        }
        
        // Parse data rows
        const rows = [];
        for (let i = startIndex; i < filteredLines.length; i++) {
            const values = this._parseCSVLine(filteredLines[i], opts);
            
            // Skip if row is empty
            if (values.length === 0 || (values.length === 1 && values[0] === '')) {
                continue;
            }
            
            // Create object from headers and values
            const row = {};
            headers.forEach((header, idx) => {
                const value = idx < values.length ? values[idx] : '';
                row[header] = opts.dynamicTyping ? this._typeCast(value) : value;
            });
            
            rows.push(row);
        }
        
        return { headers, rows };
    }
    
    /**
     * Parse a single CSV line respecting quotes and escapes
     * @param {string} line - CSV line
     * @param {object} options - Parsing options
     * @returns {string[]} Array of field values
     * @private
     */
    _parseCSVLine(line, options) {
        const { delimiter, quoteChar, escapeChar } = options;
        const result = [];
        let field = '';
        let inQuotes = false;
        
        for (let i = 0; i < line.length; i++) {
            const char = line[i];
            const nextChar = i < line.length - 1 ? line[i + 1] : '';
            
            // Handle escape sequences
            if (char === escapeChar && inQuotes && nextChar === quoteChar) {
                field += quoteChar;
                i++; // Skip the next character
                continue;
            }
            
            // Handle quotes
            if (char === quoteChar) {
                inQuotes = !inQuotes;
                continue;
            }
            
            // Handle delimiters
            if (char === delimiter && !inQuotes) {
                result.push(field);
                field = '';
                continue;
            }
            
            // Add character to field
            field += char;
        }
        
        // Add the last field
        result.push(field);
        
        return result;
    }
    
    /**
     * Try to cast a string value to the appropriate type
     * @param {string} value - String value to cast
     * @returns {any} Cast value
     * @private
     */
    _typeCast(value) {
        // Null or undefined
        if (value === null || value === undefined || value === '') {
            return null;
        }
        
        // Boolean
        if (value.toLowerCase() === 'true') return true;
        if (value.toLowerCase() === 'false') return false;
        
        // Number
        if (!isNaN(value) && value.trim() !== '') {
            // Integer
            if (parseInt(value).toString() === value) {
                return parseInt(value, 10);
            }
            // Float
            return parseFloat(value);
        }
        
        // Date (ISO format)
        const isoDateRegex = /^\d{4}-\d{2}-\d{2}(T\d{2}:\d{2}:\d{2}(\.\d{3})?Z?)?$/;
        if (isoDateRegex.test(value)) {
            const date = new Date(value);
            if (!isNaN(date.getTime())) {
                return date;
            }
        }
        
        // Default: return as string
        return value;
    }
    
    /**
     * Convert structured data to CSV
     * @param {object} data - Data with headers and rows
     * @param {object} options - Conversion options
     * @returns {string} CSV string
     */
    stringifyCSV(data, options = {}) {
        // Merge options with defaults
        const opts = {
            delimiter: options.delimiter || this.config.csvDelimiter,
            quoteChar: options.quoteChar || this.config.csvQuoteChar,
            escapeChar: options.escapeChar || this.config.csvEscapeChar,
            headerRow: options.headerRow !== undefined ? options.headerRow : true,
            quoteAll: options.quoteAll !== undefined ? options.quoteAll : false
        };
        
        let headers = [];
        let rows = [];
        
        // Handle different input formats
        if (Array.isArray(data)) {
            // Array of objects
            if (data.length > 0 && typeof data[0] === 'object' && !Array.isArray(data[0])) {
                headers = Object.keys(data[0]);
                rows = data;
            } 
            // Array of arrays
            else if (data.length > 0 && Array.isArray(data[0])) {
                headers = data[0];
                rows = data.slice(1).map(row => {
                    const obj = {};
                    headers.forEach((header, idx) => {
                        obj[header] = idx < row.length ? row[idx] : '';
                    });
                    return obj;
                });
            }
            // Empty array
            else {
                return '';
            }
        } 
        // Object with headers and rows
        else if (data.headers && data.rows) {
            headers = data.headers;
            rows = data.rows;
        }
        // Other object
        else if (typeof data === 'object') {
            headers = Object.keys(data);
            rows = [data];
        }
        
        // Generate CSV content
        const lines = [];
        
        // Add header row
        if (opts.headerRow) {
            lines.push(
                headers.map(header => this._escapeCSVField(String(header), opts)).join(opts.delimiter)
            );
        }
        
        // Add data rows
        for (const row of rows) {
            const line = headers.map(header => {
                const value = row[header] !== undefined ? row[header] : '';
                return this._escapeCSVField(String(value), opts);
            }).join(opts.delimiter);
            
            lines.push(line);
        }
        
        return lines.join('\n');
    }
    
    /**
     * Escape a CSV field value
     * @param {string} field - Field value
     * @param {object} options - Escaping options
     * @returns {string} Escaped value
     * @private
     */
    _escapeCSVField(field, options) {
        const { delimiter, quoteChar, escapeChar, quoteAll } = options;
        
        // Check if quoting is needed
        const needsQuoting = quoteAll || 
            field.includes(delimiter) || 
            field.includes(quoteChar) || 
            field.includes('\n') ||
            field.includes('\r');
        
        if (!needsQuoting) {
            return field;
        }
        
        // Escape quote characters
        const escaped = field.replace(new RegExp(quoteChar, 'g'), escapeChar + quoteChar);
        
        // Add quotes
        return quoteChar + escaped + quoteChar;
    }
    
    /**
     * Parse JSON data
     * @param {string} json - JSON string
     * @param {object} options - Parsing options
     * @returns {any} Parsed data
     */
    parseJSON(json, options = {}) {
        try {
            return JSON.parse(json);
        } catch (error) {
            if (options.strict === false) {
                // Try to recover malformed JSON
                return this._recoverJSON(json);
            }
            throw error;
        }
    }
    
    /**
     * Convert data to JSON
     * @param {any} data - Data to convert
     * @param {object} options - Conversion options
     * @returns {string} JSON string
     */
    stringifyJSON(data, options = {}) {
        const indent = options.indent !== undefined ? options.indent : this.config.jsonIndent;
        return JSON.stringify(data, null, indent);
    }
    
    /**
     * Try to recover malformed JSON
     * @param {string} json - Malformed JSON string
     * @returns {any} Recovered object or null
     * @private
     */
    _recoverJSON(json) {
        // Simple recovery attempts
        try {
            // Try wrapping in quotes
            if (json.indexOf('{') !== 0 && json.indexOf('[') !== 0) {
                return JSON.parse(`"${json.replace(/"/g, '\\"')}"`);
            }
            
            // Try with single quotes
            if (json.indexOf("'") !== -1) {
                return JSON.parse(json.replace(/'/g, '"'));
            }
            
            // Try removing trailing commas
            return JSON.parse(json.replace(/,\s*([\]}])/g, '$1'));
        } catch (e) {
            return null;
        }
    }
    
    /**
     * Parse XML data
     * @param {string} xml - XML string
     * @param {object} options - Parsing options
     * @returns {object} Parsed object
     */
    parseXML(xml, options = {}) {
        // Use browser's DOMParser if available
        if (typeof DOMParser !== 'undefined') {
            const parser = new DOMParser();
            const xmlDoc = parser.parseFromString(xml, 'text/xml');
            
            // Check for parsing errors
            const parseError = xmlDoc.querySelector('parsererror');
            if (parseError) {
                throw new Error(`XML parsing error: ${parseError.textContent}`);
            }
            
            // Convert to object
            return this._xmlToObject(xmlDoc, options);
        }
        
        // Fallback: simple regex-based parser
        return this._parseXmlWithRegex(xml, options);
    }
    
    /**
     * Convert XML document to JavaScript object
     * @param {Document} xmlDoc - XML document
     * @param {object} options - Conversion options
     * @returns {object} JavaScript object
     * @private
     */
    _xmlToObject(xmlDoc, options = {}) {
        const root = xmlDoc.documentElement;
        return this._nodeToObject(root, options);
    }
    
    /**
     * Convert XML node to JavaScript object
     * @param {Node} node - XML node
     * @param {object} options - Conversion options
     * @returns {any} JavaScript representation
     * @private
     */
    _nodeToObject(node, options = {}) {
        // Text node
        if (node.nodeType === 3) {
            return node.nodeValue.trim();
        }
        
        // Element node
        if (node.nodeType === 1) {
            const obj = {};
            
            // Add attributes
            if (node.attributes && node.attributes.length > 0) {
                obj['@attributes'] = {};
                for (let i = 0; i < node.attributes.length; i++) {
                    const attr = node.attributes[i];
                    obj['@attributes'][attr.nodeName] = attr.nodeValue;
                }
            }
            
            // Add child nodes
            for (let i = 0; i < node.childNodes.length; i++) {
                const child = node.childNodes[i];
                
                // Skip empty text nodes
                if (child.nodeType === 3 && child.nodeValue.trim() === '') {
                    continue;
                }
                
                const childObj = this._nodeToObject(child, options);
                
                // Text content
                if (child.nodeType === 3) {
                    if (node.childNodes.length === 1) {
                        // Only text content
                        return childObj;
                    } else {
                        obj['#text'] = childObj;
                    }
                    continue;
                }
                
                // Element nodes
                const name = child.nodeName;
                
                if (obj[name] === undefined) {
                    // First occurrence
                    obj[name] = childObj;
                } else if (Array.isArray(obj[name])) {
                    // Already an array, add to it
                    obj[name].push(childObj);
                } else {
                    // Convert to array
                    obj[name] = [obj[name], childObj];
                }
            }
            
            return obj;
        }
        
        // Other node types
        return null;
    }
    
    /**
     * Simple regex-based XML parser
     * @param {string} xml - XML string
     * @param {object} options - Parsing options
     * @returns {object} Parsed object
     * @private
     */
    _parseXmlWithRegex(xml, options = {}) {
        // This is a very basic implementation
        const obj = {};
        const tagRegex = /<(\/?)([\w:-]+)(?:\s+([^>]*))?>/g;
        const stack = [{ node: obj }];
        let lastMatchEnd = 0;
        let match;
        
        while ((match = tagRegex.exec(xml)) !== null) {
            const isClosing = match[1] === '/';
            const tagName = match[2];
            const attrs = match[3];
            
            // Get text content before this tag
            const textContent = xml.substring(lastMatchEnd, match.index).trim();
            if (textContent && stack.length > 0) {
                const current = stack[stack.length - 1];
                
                if (!current.textCollected) {
                    current.text = current.text || '';
                    current.text += textContent;
                }
            }
            
            lastMatchEnd = tagRegex.lastIndex;
            
            if (isClosing) {
                // Closing tag
                if (stack.length > 1) {
                    const completed = stack.pop();
                    
                    // If text was collected, assign it
                    if (completed.text) {
                        completed.node = completed.text;
                    }
                    
                    // Add to parent
                    const parent = stack[stack.length - 1];
                    
                    if (!parent.node[tagName]) {
                        parent.node[tagName] = completed.node;
                    } else if (Array.isArray(parent.node[tagName])) {
                        parent.node[tagName].push(completed.node);
                    } else {
                        parent.node[tagName] = [parent.node[tagName], completed.node];
                    }
                }
            } else if (xml.substring(match.index + match[0].length).trim().startsWith('</')) {
                // Self-closing tag (due to immediate close tag)
                const selfClose = {};
                
                // Parse attributes
                if (attrs) {
                    const attrObj = this._parseXmlAttributes(attrs);
                    Object.assign(selfClose, attrObj);
                }
                
                // Add to current node
                const current = stack[stack.length - 1];
                
                if (!current.node[tagName]) {
                    current.node[tagName] = selfClose;
                } else if (Array.isArray(current.node[tagName])) {
                    current.node[tagName].push(selfClose);
                } else {
                    current.node[tagName] = [current.node[tagName], selfClose];
                }
                
                // Mark text as collected so we don't add it again
                current.textCollected = true;
                
            } else {
                // Opening tag
                const newNode = {};
                
                // Parse attributes
                if (attrs) {
                    const attrObj = this._parseXmlAttributes(attrs);
                    Object.assign(newNode, attrObj);
                }
                
                stack.push({ node: newNode, text: '' });
            }
        }
        
        return obj;
    }
    
    /**
     * Parse XML attributes string
     * @param {string} attrs - Attributes string
     * @returns {object} Attributes object
     * @private
     */
    _parseXmlAttributes(attrs) {
        const attrObj = {};
        const attrRegex = /(\w+)=["']([^"']*)["']/g;
        let attrMatch;
        
        while ((attrMatch = attrRegex.exec(attrs)) !== null) {
            attrObj[attrMatch[1]] = attrMatch[2];
        }
        
        return attrObj;
    }
    
    /**
     * Convert data to XML
     * @param {any} data - Data to convert
     * @param {object} options - Conversion options
     * @returns {string} XML string
     */
    stringifyXML(data, options = {}) {
        const indent = options.indent !== undefined ? options.indent : this.config.xmlIndent;
        const rootName = options.rootName || 'root';
        
        // Start with XML declaration
        let xml = '<?xml version="1.0" encoding="UTF-8"?>\n';
        
        // Add root element and its content
        xml += this._objectToXml(data, rootName, 0, indent);
        
        return xml;
    }
    
    /**
     * Convert object to XML string
     * @param {any} obj - Object to convert
     * @param {string} nodeName - XML node name
     * @param {number} level - Indentation level
     * @param {number} indent - Spaces per indentation level
     * @returns {string} XML string
     * @private
     */
    _objectToXml(obj, nodeName, level, indent) {
        if (obj === null || obj === undefined) {
            return this._indent(`<${nodeName}/>\n`, level, indent);
        }
        
        // Simple types (string, number, boolean)
        if (typeof obj !== 'object') {
            return this._indent(`<${nodeName}>${obj}</${nodeName}>\n`, level, indent);
        }
        
        // Arrays
        if (Array.isArray(obj)) {
            return obj.map(item => this._objectToXml(item, nodeName, level, indent)).join('');
        }
        
        // Extract attributes (properties starting with @)
        const attributes = {};
        const children = {};
        let textContent = null;
        
        Object.entries(obj).forEach(([key, value]) => {
            if (key === '@attributes') {
                Object.assign(attributes, value);
            } else if (key === '#text') {
                textContent = value;
            } else {
                children[key] = value;
            }
        });
        
        // Build attributes string
        const attrStr = Object.entries(attributes)
            .map(([key, value]) => `${key}="${value}"`)
            .join(' ');
        
        // Opening tag with attributes
        let xml = this._indent(`<${nodeName}${attrStr ? ' ' + attrStr : ''}>`, level, indent);
        
        // Add text content and/or child nodes
        if (textContent !== null) {
            xml += textContent;
        } else if (Object.keys(children).length === 0) {
            // Empty element, close the tag
            xml = xml.slice(0, -1) + '/>\n';
            return xml;
        } else {
            xml += '\n';
            
            // Add child nodes
            for (const [childName, childValue] of Object.entries(children)) {
                xml += this._objectToXml(childValue, childName, level + 1, indent);
            }
            
            // Closing tag with indentation
            xml += this._indent(``, level, indent);
        }
        
        // Close the tag
        if (xml.endsWith('>') || xml.endsWith('\n')) {
            xml += xml.endsWith('\n') ? this._indent(`</${nodeName}>\n`, level, indent) : `</${nodeName}>\n`;
        }
        
        return xml;
    }
    
    /**
     * Indent a string
     * @param {string} str - String to indent
     * @param {number} level - Indentation level
     * @param {number} spaces - Spaces per level
     * @returns {string} Indented string
     * @private
     */
    _indent(str, level, spaces) {
        return ' '.repeat(level * spaces) + str;
    }
    
    /**
     * Parse plain text into a structured format
     * @param {string} text - Text content
     * @param {object} options - Parsing options
     * @returns {any} Parsed data
     */
    parseTXT(text, options = {}) {
        // Try to guess the structure
        const lines = text.split(/\r?\n/);
        
        // Check if it looks like a CSV
        if (this._isCSV(text)) {
            return this.parseCSV(text, options);
        }
        
        // Check if it looks like key-value pairs
        if (this._isKeyValue(text)) {
            return this._parseKeyValue(text);
        }
        
        // Return as simple text if no structure detected
        return text;
    }
    
    /**
     * Convert data to plain text
     * @param {any} data - Data to convert
     * @param {object} options - Conversion options
     * @returns {string} Text string
     */
    stringifyTXT(data, options = {}) {
        if (typeof data === 'string') {
            return data;
        }
        
        if (typeof data === 'object') {
            // Try to stringify as key-value pairs
            return this._stringifyKeyValue(data);
        }
        
        // Convert other types to string
        return String(data);
    }
    
    /**
     * Parse key-value pairs
     * @param {string} text - Text with key-value pairs
     * @returns {object} Parsed object
     * @private
     */
    _parseKeyValue(text) {
        const result = {};
        const lines = text.split(/\r?\n/);
        
        for (const line of lines) {
            const trimmed = line.trim();
            if (!trimmed || trimmed.startsWith('#')) continue;
            
            // Find the first separator (: or =)
            const colonIndex = trimmed.indexOf(':');
            const equalsIndex = trimmed.indexOf('=');
            
            let separator;
            if (colonIndex === -1) separator = '=';
            else if (equalsIndex === -1) separator = ':';
            else separator = colonIndex < equalsIndex ? ':' : '=';
            
            const parts = trimmed.split(separator);
            
            if (parts.length >= 2) {
                const key = parts[0].trim();
                const value = parts.slice(1).join(separator).trim();
                result[key] = value;
            }
        }
        
        return result;
    }
    
    /**
     * Convert object to key-value pairs
     * @param {object} obj - Object to convert
     * @returns {string} Key-value string
     * @private
     */
    _stringifyKeyValue(obj) {
        if (!obj || typeof obj !== 'object' || Array.isArray(obj)) {
            return String(obj);
        }
        
        return Object.entries(obj)
            .map(([key, value]) => {
                if (typeof value === 'object') {
                    value = JSON.stringify(value);
                }
                return `${key} = ${value}`;
            })
            .join('\n');
    }
    
    /**
     * Check if a string appears to be CSV
     * @param {string} str - String to check
     * @returns {boolean} Whether the string appears to be CSV
     * @private
     */
    _isCSV(str) {
        if (!str || typeof str !== 'string') return false;
        
        // Split into lines
        const lines = str.split(/\r?\n/).filter(line => line.trim());
        
        if (lines.length < 2) return false;
        
        // Count commas in first two lines
        const commas1 = (lines[0].match(/,/g) || []).length;
        const commas2 = (lines[1].match(/,/g) || []).length;
        
        // If consistent number of commas and at least one, likely CSV
        return commas1 > 0 && commas1 === commas2;
    }
    
    /**
     * Check if a string appears to be JSON
     * @param {string} str - String to check
     * @returns {boolean} Whether the string appears to be JSON
     * @private
     */
    _isJSON(str) {
        if (!str || typeof str !== 'string') return false;
        
        // Trim whitespace
        str = str.trim();
        
        // Check if it starts with { or [
        if (!(str.startsWith('{') || str.startsWith('['))) return false;
        
        // Check if it ends with } or ]
        if (!(str.endsWith('}') || str.endsWith(']'))) return false;
        
        // Try to parse it
        try {
            JSON.parse(str);
            return true;
        } catch (e) {
            return false;
        }
    }
    
    /**
     * Check if a string appears to be XML
     * @param {string} str - String to check
     * @returns {boolean} Whether the string appears to be XML
     * @private
     */
    _isXML(str) {
        if (!str || typeof str !== 'string') return false;
        
        // Trim whitespace
        str = str.trim();
        
        // Check for XML declaration
        if (str.startsWith('<?xml')) return true;
        
        // Check for tags
        const tagMatch = str.match(/<(\w+)[^>]*>(.*?)<\/\1>/s);
        return !!tagMatch;
    }
    
    /**
     * Check if a string appears to be key-value pairs
     * @param {string} str - String to check
     * @returns {boolean} Whether the string appears to be key-value pairs
     * @private
     */
    _isKeyValue(str) {
        if (!str || typeof str !== 'string') return false;
        
        // Split into lines
        const lines = str.split(/\r?\n/).filter(line => line.trim() && !line.startsWith('#'));
        
        if (lines.length === 0) return false;
        
        // Check if most lines have a colon or equals sign
        const kvLines = lines.filter(line => line.includes(':') || line.includes('='));
        return kvLines.length / lines.length > 0.5;
    }
    
    /**
     * Clear the cache
     */
    clearCache() {
        this.cache.clear();
    }
    
    /**
     * Get type information about a file by its name or extension
     * @param {string} filename - Filename or extension
     * @returns {object} File type information
     */
    getFileTypeInfo(filename) {
        const extension = filename.includes('.') 
            ? filename.split('.').pop().toLowerCase()
            : filename.toLowerCase();
        
        const typeMap = {
            'csv': {
                name: 'CSV',
                description: 'Comma-Separated Values',
                mime: 'text/csv',
                parser: 'csv',
                editable: true
            },
            'json': {
                name: 'JSON',
                description: 'JavaScript Object Notation',
                mime: 'application/json',
                parser: 'json',
                editable: true
            },
            'xml': {
                name: 'XML',
                description: 'Extensible Markup Language',
                mime: 'application/xml',
                parser: 'xml',
                editable: true
            },
            'txt': {
                name: 'Text',
                description: 'Plain Text',
                mime: 'text/plain',
                parser: 'txt',
                editable: true
            },
            'js': {
                name: 'JavaScript',
                description: 'JavaScript Source Code',
                mime: 'application/javascript',
                parser: 'txt',
                editable: true
            },
            'html': {
                name: 'HTML',
                description: 'Hypertext Markup Language',
                mime: 'text/html',
                parser: 'xml',
                editable: true
            },
            'css': {
                name: 'CSS',
                description: 'Cascading Style Sheets',
                mime: 'text/css',
                parser: 'txt',
                editable: true
            },
            'md': {
                name: 'Markdown',
                description: 'Markdown Document',
                mime: 'text/markdown',
                parser: 'txt',
                editable: true
            }
        };
        
        return typeMap[extension] || {
            name: extension.toUpperCase(),
            description: 'Unknown File Type',
            mime: 'application/octet-stream',
            parser: 'txt',
            editable: false
        };
    }
}

// If running in a browser environment, add to window
if (typeof window !== 'undefined') {
    window.DataParser = DataParser;
}