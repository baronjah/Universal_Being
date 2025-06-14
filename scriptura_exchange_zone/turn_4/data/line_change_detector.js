/**
 * Line Change Detector
 * Created by word manifestation: "line by line but change and difference is needed too"
 * For use in Turn 4 (Temporal Flow) to track changes across time states
 */

class LineChangeDetector {
    constructor() {
        this.lastState = null;
        this.currentState = null;
        this.changes = [];
        this.temporalEchos = [];
        this.sensitivityLevel = 0.75;
        this.detailThreshold = 0.4;
        this.diffAlgorithm = "levenshtein"; // Default diff algorithm
    }

    /**
     * Initialize with optional custom settings
     */
    initialize(options = {}) {
        this.sensitivityLevel = options.sensitivity || 0.75;
        this.detailThreshold = options.detailThreshold || 0.4;
        this.diffAlgorithm = options.diffAlgorithm || "levenshtein";
        
        console.log(`Line Change Detector initialized with sensitivity ${this.sensitivityLevel}`);
        console.log(`Detail threshold set to ${this.detailThreshold}`);
        console.log(`Using ${this.diffAlgorithm} algorithm for difference detection`);
        
        return {
            status: "initialized",
            ready: true,
            timeAware: true
        };
    }
    
    /**
     * Set the previous state (can be text, code, or structured data)
     */
    setPreviousState(content, type = "text", metadata = {}) {
        // If we already have a current state, move it to lastState
        if (this.currentState) {
            this.lastState = this.currentState;
        }
        
        // Set new state as current state
        this.currentState = {
            content: content,
            type: type,
            lines: this.splitIntoLines(content),
            timestamp: metadata.timestamp || new Date(),
            metadata: metadata,
            hash: this.computeHash(content)
        };
        
        // If we now have both states, compute differences
        if (this.lastState && this.currentState) {
            this.computeDifferences();
        }
        
        return {
            hash: this.currentState.hash,
            lineCount: this.currentState.lines.length,
            recorded: true
        };
    }
    
    /**
     * Set the current state and compute differences from previous
     */
    setCurrentState(content, type = "text", metadata = {}) {
        // If no previous state, set it from current (if exists)
        if (!this.lastState && this.currentState) {
            this.lastState = this.currentState;
        }
        
        // Set new current state
        this.currentState = {
            content: content,
            type: type,
            lines: this.splitIntoLines(content),
            timestamp: metadata.timestamp || new Date(),
            metadata: metadata,
            hash: this.computeHash(content)
        };
        
        // If we now have both states, compute differences
        if (this.lastState && this.currentState) {
            this.computeDifferences();
        }
        
        return {
            hash: this.currentState.hash,
            lineCount: this.currentState.lines.length,
            recorded: true
        };
    }
    
    /**
     * Compute differences between previous and current state
     */
    computeDifferences() {
        if (!this.lastState || !this.currentState) {
            return { error: "Missing state data" };
        }
        
        this.changes = [];
        const lastLines = this.lastState.lines;
        const currentLines = this.currentState.lines;
        
        // Basic line-by-line comparison
        const minLength = Math.min(lastLines.length, currentLines.length);
        const maxLength = Math.max(lastLines.length, currentLines.length);
        
        // Compare lines that exist in both states
        for (let i = 0; i < minLength; i++) {
            const lineNum = i + 1;
            const similarity = this.calculateSimilarity(lastLines[i], currentLines[i]);
            
            if (similarity < this.sensitivityLevel) {
                // Lines are different enough to register as a change
                const change = {
                    lineNumber: lineNum,
                    from: lastLines[i],
                    to: currentLines[i],
                    type: this.categorizeChange(lastLines[i], currentLines[i]),
                    similarity: similarity,
                    timestamp: new Date(),
                    detailChanges: this.detectDetailChanges(lastLines[i], currentLines[i])
                };
                
                this.changes.push(change);
                
                // Check for temporal echo patterns
                if (this.detectTemporalPattern(change)) {
                    this.temporalEchos.push({
                        origin: change,
                        pattern: this.analyzeTemporalPattern(change),
                        probability: this.calculatePatternProbability(change)
                    });
                }
            }
        }
        
        // Handle added or removed lines
        if (lastLines.length < currentLines.length) {
            // Lines were added
            for (let i = minLength; i < maxLength; i++) {
                const lineNum = i + 1;
                this.changes.push({
                    lineNumber: lineNum,
                    type: "addition",
                    from: null,
                    to: currentLines[i],
                    timestamp: new Date()
                });
            }
        } else if (lastLines.length > currentLines.length) {
            // Lines were removed
            for (let i = minLength; i < maxLength; i++) {
                const lineNum = i + 1;
                this.changes.push({
                    lineNumber: lineNum,
                    type: "deletion",
                    from: lastLines[i],
                    to: null,
                    timestamp: new Date()
                });
            }
        }
        
        return this.changes;
    }
    
    /**
     * Get all detected changes
     */
    getChanges() {
        return {
            changes: this.changes,
            temporalEchos: this.temporalEchos,
            total: this.changes.length,
            timestamp: new Date()
        };
    }
    
    /**
     * Get detailed analysis of changes
     */
    getChangeAnalysis() {
        if (this.changes.length === 0) {
            return { message: "No changes detected" };
        }
        
        const categories = {};
        let totalSimilarity = 0;
        
        // Categorize changes by type
        for (const change of this.changes) {
            if (!categories[change.type]) {
                categories[change.type] = 0;
            }
            categories[change.type]++;
            
            if (change.similarity !== undefined) {
                totalSimilarity += change.similarity;
            }
        }
        
        // Calculate average similarity across changes
        const avgSimilarity = totalSimilarity / this.changes.length;
        
        // Find most significant change
        let mostSignificant = null;
        let leastSimilarity = 1.0;
        
        for (const change of this.changes) {
            if (change.similarity !== undefined && change.similarity < leastSimilarity) {
                leastSimilarity = change.similarity;
                mostSignificant = change;
            }
        }
        
        return {
            changeCount: this.changes.length,
            categories: categories,
            averageSimilarity: avgSimilarity,
            mostSignificantChange: mostSignificant,
            temporalPatterns: this.temporalEchos.length,
            analysis: this.generateAnalysisSummary()
        };
    }
    
    /**
     * Generate a summary of the analysis
     */
    generateAnalysisSummary() {
        if (this.changes.length === 0) {
            return "No changes detected between states.";
        }
        
        let summary = `Detected ${this.changes.length} changes between states. `;
        
        // Categorize changes
        const additions = this.changes.filter(c => c.type === "addition").length;
        const deletions = this.changes.filter(c => c.type === "deletion").length;
        const modifications = this.changes.filter(c => !["addition", "deletion"].includes(c.type)).length;
        
        if (additions > 0) {
            summary += `${additions} new line${additions > 1 ? 's' : ''} added. `;
        }
        
        if (deletions > 0) {
            summary += `${deletions} line${deletions > 1 ? 's' : ''} removed. `;
        }
        
        if (modifications > 0) {
            summary += `${modifications} line${modifications > 1 ? 's' : ''} modified. `;
        }
        
        // Add temporal pattern information
        if (this.temporalEchos.length > 0) {
            summary += `${this.temporalEchos.length} potential temporal pattern${this.temporalEchos.length > 1 ? 's' : ''} detected.`;
        }
        
        return summary;
    }
    
    /**
     * Helper: Split content into lines
     */
    splitIntoLines(content) {
        if (typeof content !== 'string') {
            return [];
        }
        return content.split('\n');
    }
    
    /**
     * Helper: Compute hash for content
     */
    computeHash(content) {
        // Simple hash function for demonstration
        let hash = 0;
        for (let i = 0; i < content.length; i++) {
            hash = ((hash << 5) - hash) + content.charCodeAt(i);
            hash |= 0; // Convert to 32-bit integer
        }
        return `${Math.abs(hash)}`;
    }
    
    /**
     * Helper: Calculate similarity between two strings
     */
    calculateSimilarity(str1, str2) {
        if (str1 === str2) return 1.0;
        if (!str1 || !str2) return 0.0;
        
        if (this.diffAlgorithm === "levenshtein") {
            return this.levenshteinSimilarity(str1, str2);
        } else {
            // Default simple algorithm
            return this.simpleSimilarity(str1, str2);
        }
    }
    
    /**
     * Helper: Simple similarity calculation
     */
    simpleSimilarity(str1, str2) {
        const maxLength = Math.max(str1.length, str2.length);
        if (maxLength === 0) return 1.0;
        
        let differences = 0;
        const minLength = Math.min(str1.length, str2.length);
        
        // Compare characters
        for (let i = 0; i < minLength; i++) {
            if (str1[i] !== str2[i]) {
                differences++;
            }
        }
        
        // Add remaining length difference
        differences += (maxLength - minLength);
        
        return 1 - (differences / maxLength);
    }
    
    /**
     * Helper: Levenshtein distance based similarity
     */
    levenshteinSimilarity(str1, str2) {
        const len1 = str1.length;
        const len2 = str2.length;
        
        // Create distance matrix
        const matrix = Array(len1 + 1).fill().map(() => Array(len2 + 1).fill(0));
        
        // Initialize first row and column
        for (let i = 0; i <= len1; i++) matrix[i][0] = i;
        for (let j = 0; j <= len2; j++) matrix[0][j] = j;
        
        // Fill the matrix
        for (let i = 1; i <= len1; i++) {
            for (let j = 1; j <= len2; j++) {
                const cost = str1[i-1] === str2[j-1] ? 0 : 1;
                matrix[i][j] = Math.min(
                    matrix[i-1][j] + 1,      // deletion
                    matrix[i][j-1] + 1,      // insertion
                    matrix[i-1][j-1] + cost  // substitution
                );
            }
        }
        
        // Calculate similarity from distance
        const distance = matrix[len1][len2];
        const maxLength = Math.max(len1, len2);
        if (maxLength === 0) return 1.0;
        
        return 1 - (distance / maxLength);
    }
    
    /**
     * Helper: Categorize the type of change
     */
    categorizeChange(from, to) {
        if (!from) return "addition";
        if (!to) return "deletion";
        
        // Analyze the nature of the change
        const fromWords = from.split(/\s+/).filter(Boolean);
        const toWords = to.split(/\s+/).filter(Boolean);
        
        if (Math.abs(fromWords.length - toWords.length) > fromWords.length * 0.5) {
            // Substantial difference in word count
            return "rewrite";
        }
        
        // Check for word order change (similar words but different order)
        const sameWords = fromWords.filter(word => toWords.includes(word));
        if (sameWords.length >= fromWords.length * 0.7 && sameWords.length >= toWords.length * 0.7) {
            return "reordering";
        }
        
        // Check for formatting changes (whitespace, capitalization, punctuation)
        const normalized1 = from.toLowerCase().replace(/\s+/g, ' ').replace(/[^\w\s]/g, '');
        const normalized2 = to.toLowerCase().replace(/\s+/g, ' ').replace(/[^\w\s]/g, '');
        
        if (normalized1 === normalized2) {
            return "formatting";
        }
        
        // Default to general modification
        return "modification";
    }
    
    /**
     * Helper: Detect detailed changes
     */
    detectDetailChanges(from, to) {
        if (!from || !to) return [];
        
        const details = [];
        
        // Split into words
        const fromWords = from.split(/\s+/).filter(Boolean);
        const toWords = to.split(/\s+/).filter(Boolean);
        
        // Look for word replacements, additions, and deletions
        const commonPrefix = this.findCommonPrefix(fromWords, toWords);
        const commonSuffix = this.findCommonSuffix(fromWords, toWords);
        
        // Extract the middle changed section
        const fromChanged = fromWords.slice(commonPrefix, fromWords.length - commonSuffix);
        const toChanged = toWords.slice(commonPrefix, toWords.length - commonSuffix);
        
        if (fromChanged.length === 0 && toChanged.length > 0) {
            // Words were added
            details.push({
                type: "word_addition",
                words: toChanged,
                position: commonPrefix
            });
        } else if (fromChanged.length > 0 && toChanged.length === 0) {
            // Words were removed
            details.push({
                type: "word_deletion",
                words: fromChanged,
                position: commonPrefix
            });
        } else if (fromChanged.length === 1 && toChanged.length === 1) {
            // Single word replacement
            details.push({
                type: "word_replacement",
                from: fromChanged[0],
                to: toChanged[0],
                position: commonPrefix,
                similarity: this.calculateSimilarity(fromChanged[0], toChanged[0])
            });
        } else {
            // More complex change
            details.push({
                type: "complex_change",
                fromSection: fromChanged,
                toSection: toChanged,
                position: commonPrefix
            });
        }
        
        return details;
    }
    
    /**
     * Helper: Find common prefix length
     */
    findCommonPrefix(arr1, arr2) {
        let i = 0;
        while (i < arr1.length && i < arr2.length && arr1[i] === arr2[i]) {
            i++;
        }
        return i;
    }
    
    /**
     * Helper: Find common suffix length
     */
    findCommonSuffix(arr1, arr2) {
        let i = 0;
        while (
            i < arr1.length && 
            i < arr2.length && 
            arr1[arr1.length - 1 - i] === arr2[arr2.length - 1 - i]
        ) {
            i++;
        }
        return i;
    }
    
    /**
     * Helper: Detect if a change might have temporal significance
     */
    detectTemporalPattern(change) {
        // This is a placeholder for more sophisticated pattern recognition
        if (!change.from || !change.to) return false;
        
        // Look for time-related words
        const timeWords = ['time', 'past', 'present', 'future', 'before', 'after', 
                          'then', 'now', 'later', 'earlier', 'yesterday', 'today', 
                          'tomorrow', 'moment', 'second', 'minute', 'hour'];
        
        const fromHasTime = timeWords.some(word => 
            change.from.toLowerCase().includes(word)
        );
        
        const toHasTime = timeWords.some(word => 
            change.to.toLowerCase().includes(word)
        );
        
        // Change in temporal reference might indicate a pattern
        return fromHasTime || toHasTime;
    }
    
    /**
     * Helper: Analyze detected temporal pattern
     */
    analyzeTemporalPattern(change) {
        // This would be a complex analysis in a real implementation
        return {
            type: "temporal_shift",
            direction: Math.random() < 0.5 ? "past_to_present" : "present_to_future",
            strength: Math.random() * 0.5 + 0.3, // 0.3 to 0.8
            consistency: Math.random() * 0.7 + 0.3 // 0.3 to 1.0
        };
    }
    
    /**
     * Helper: Calculate probability of temporal pattern significance
     */
    calculatePatternProbability(change) {
        // This would use more sophisticated algorithms in a real implementation
        return Math.random() * 0.6 + 0.4; // 0.4 to 1.0
    }
}

// For Node.js environment
if (typeof module !== 'undefined') {
    module.exports = { LineChangeDetector };
}

// For browser environment
if (typeof window !== 'undefined') {
    window.lineChangeDetector = new LineChangeDetector();
}

console.log("Line Change Detector created for Temporal Flow dimension (Turn 4).");