/**
 * Claude-Luminous Connection
 * Advanced integration between Claude AI and Luminous OS
 * Part of Turn 8 (Lines/Temporal Cleansing)
 */

const LuminousCleanupSystem = require('./luminous_cleanup_system');

class ClaudeLuminousConnection {
  constructor() {
    this.cleanupSystem = LuminousCleanupSystem;
    this.connectionActive = false;
    this.messageHistory = [];
    this.lineMapping = {};
    this.splitThreshold = 8192; // Default token limit for splitting
    
    // Connection metrics
    this.metrics = {
      messagesProcessed: 0,
      totalTokensProcessed: 0,
      averageTokensPerMessage: 0,
      dataCleansed: 0,
      temporalEchoes: 0,
      linePatternMatches: 0
    };
    
    // Claude model mapping
    this.claudeModels = {
      'claude': { 
        maxTokens: 100000,
        maxFiles: 3,
        temporalReach: 0.7,
        cleansePower: 1.0
      },
      'claude-instant': { 
        maxTokens: 100000,
        maxFiles: 2,
        temporalReach: 0.4,
        cleansePower: 0.7
      },
      'claude-opus': { 
        maxTokens: 200000,
        maxFiles: 4,
        temporalReach: 0.9,
        cleansePower: 1.2
      },
      'claude-sonnet': { 
        maxTokens: 180000,
        maxFiles: 3,
        temporalReach: 0.8,
        cleansePower: 1.1
      }
    };
    
    this.currentModel = 'claude';
    
    // Line pattern mappings for Turn 8
    this.linePatternIdentifiers = {
      consecutiveNewlines: 'parallel',
      bulletPoints: 'parallel',
      numberList: 'parallel',
      tableSeparators: 'intersecting',
      codeSections: 'intersecting',
      circularReferences: 'spiral',
      recursiveStructure: 'fractal',
      complexJson: 'fractal'
    };
    
    // Database storage simulation
    this.database = {
      messageFragments: [],
      linePatterns: {},
      tokenDistribution: {},
      temporalAlignments: {}
    };
  }

  /**
   * Initialize connection with Claude
   */
  initializeConnection(options = {}) {
    const config = {
      model: options.model || 'claude',
      maxTokens: options.maxTokens || this.claudeModels[this.currentModel].maxTokens,
      temporalAlignment: options.temporalAlignment !== undefined ? options.temporalAlignment : true,
      dataCleaningEnabled: options.dataCleaningEnabled !== undefined ? options.dataCleaningEnabled : true,
      splitMessagesAutomatically: options.splitMessagesAutomatically !== undefined ? options.splitMessagesAutomatically : true,
      trackLinePatterns: options.trackLinePatterns !== undefined ? options.trackLinePatterns : true,
      powerLevel: options.powerLevel || 1
    };
    
    // Check if model is valid
    if (!this.claudeModels[config.model]) {
      return {
        error: `Invalid Claude model: ${config.model}`,
        validModels: Object.keys(this.claudeModels)
      };
    }
    
    // Update current model
    this.currentModel = config.model;
    
    // Update split threshold based on model
    this.splitThreshold = Math.floor(this.claudeModels[config.model].maxTokens * 0.8);
    
    // Connect to Luminous system
    const luminousConnection = this.cleanupSystem.connectToLuminousOS({
      connectionType: 'enhanced',
      temporalState: config.temporalAlignment ? 'all' : 'present',
      powerLevel: config.powerLevel,
      integrationLevel: 'full',
      securityProtocol: 'enhanced',
      enableDiabolic: options.enableDiabolic
    });
    
    // Connect to Claude AI
    const claudeConnection = this.cleanupSystem.connectToAI(config.model, {
      connectionType: 'api',
      temporalAccess: config.temporalAlignment ? 'all' : 'present',
      dataSharing: 'full',
      responseFormat: 'enhanced',
      tokenLimit: config.maxTokens,
      powerLevel: config.powerLevel
    });
    
    // Activate connection
    this.connectionActive = true;
    
    return {
      status: "Claude-Luminous connection initialized",
      model: config.model,
      maxTokens: config.maxTokens,
      splitThreshold: this.splitThreshold,
      temporalAlignment: config.temporalAlignment,
      dataCleaningEnabled: config.dataCleaningEnabled,
      trackLinePatterns: config.trackLinePatterns,
      luminousConnection: luminousConnection,
      claudeConnection: claudeConnection,
      readyForMessages: true
    };
  }

  /**
   * Process a message through the connection
   */
  processMessage(message, options = {}) {
    if (!this.connectionActive) {
      return {
        error: "Connection not initialized",
        solution: "Call initializeConnection() first"
      };
    }
    
    const config = {
      cleanBeforeProcessing: options.cleanBeforeProcessing !== undefined ? options.cleanBeforeProcessing : true,
      detectLines: options.detectLines !== undefined ? options.detectLines : true,
      splitIfNeeded: options.splitIfNeeded !== undefined ? options.splitIfNeeded : true,
      preserveLinePatterns: options.preserveLinePatterns !== undefined ? options.preserveLinePatterns : true,
      temporalProcessing: options.temporalProcessing !== undefined ? options.temporalProcessing : true,
      powerLevel: options.powerLevel || 1
    };
    
    // Estimate token count
    const estimatedTokens = this._estimateTokens(message);
    
    // Record message
    const messageRecord = {
      id: `msg_${Date.now()}`,
      timestamp: new Date().toISOString(),
      estimatedTokens: estimatedTokens,
      length: message.length,
      processingOptions: config
    };
    
    // Update metrics
    this.metrics.messagesProcessed++;
    this.metrics.totalTokensProcessed += estimatedTokens;
    this.metrics.averageTokensPerMessage = this.metrics.totalTokensProcessed / this.metrics.messagesProcessed;
    
    // Detect line patterns if requested
    let linePatterns = null;
    if (config.detectLines) {
      linePatterns = this._detectLinePatterns(message);
      
      // Update metrics
      this.metrics.linePatternMatches += linePatterns.patternCount;
      
      // Record line patterns
      messageRecord.linePatterns = linePatterns.patterns;
      
      // Store in database
      this._storeLinePatterns(messageRecord.id, linePatterns);
    }
    
    // Clean data if requested
    let cleanedMessage = message;
    if (config.cleanBeforeProcessing) {
      cleanedMessage = this._cleanMessageData(message, linePatterns, config);
      
      // Update metrics
      this.metrics.dataCleansed += (message.length - cleanedMessage.length) / message.length;
      
      // Record cleaning metrics
      messageRecord.originalLength = message.length;
      messageRecord.cleanedLength = cleanedMessage.length;
      messageRecord.reductionPercentage = (message.length - cleanedMessage.length) / message.length * 100;
    }
    
    // Split message if needed and requested
    let messageParts = [];
    if (config.splitIfNeeded && estimatedTokens > this.splitThreshold) {
      messageParts = this._splitMessage(cleanedMessage, config.preserveLinePatterns ? linePatterns : null);
      
      // Record splitting metrics
      messageRecord.splitIntoParts = messageParts.length;
      messageRecord.averagePartSize = messageParts.reduce((sum, part) => sum + part.length, 0) / messageParts.length;
      
      // Store fragments in database
      messageParts.forEach((part, index) => {
        this.database.messageFragments.push({
          messageId: messageRecord.id,
          partIndex: index,
          content: part.substring(0, 100) + '...',
          length: part.length,
          estimatedTokens: this._estimateTokens(part)
        });
      });
    } else {
      messageParts = [cleanedMessage];
      messageRecord.splitIntoParts = 1;
    }
    
    // Add message to history
    this.messageHistory.push(messageRecord);
    
    return {
      status: "Message processed successfully",
      messageId: messageRecord.id,
      originalTokens: estimatedTokens,
      originalLength: message.length,
      cleanedLength: cleanedMessage.length,
      partsGenerated: messageParts.length,
      linePatterns: linePatterns ? linePatterns.patterns : null,
      dominantPattern: linePatterns ? linePatterns.dominantPattern : null,
      processingMetrics: {
        reductionPercentage: messageRecord.reductionPercentage,
        linePatternMatches: linePatterns ? linePatterns.patternCount : 0,
        processingTime: Math.floor(Math.random() * 500) + 100 // simulated processing time
      },
      messageParts: messageParts.map((part, index) => ({
        index,
        length: part.length,
        estimatedTokens: this._estimateTokens(part),
        excerpt: part.substring(0, 50) + '...'
      }))
    };
  }

  /**
   * Split a message into appropriate fragments
   */
  _splitMessage(message, linePatterns = null) {
    // If line patterns are available, use them to guide the splitting
    if (linePatterns && linePatterns.patterns.length > 0) {
      return this._splitByLinePatterns(message, linePatterns);
    }
    
    // Otherwise, split by estimated token count
    const estimatedTokens = this._estimateTokens(message);
    
    if (estimatedTokens <= this.splitThreshold) {
      return [message];
    }
    
    // Simple splitting by paragraphs
    const paragraphs = message.split(/\n\s*\n/);
    
    // Group paragraphs into parts that fit within token limit
    const parts = [];
    let currentPart = '';
    let currentPartTokens = 0;
    
    for (const paragraph of paragraphs) {
      const paragraphTokens = this._estimateTokens(paragraph);
      
      if (currentPartTokens + paragraphTokens <= this.splitThreshold) {
        currentPart += (currentPart ? '\n\n' : '') + paragraph;
        currentPartTokens += paragraphTokens;
      } else {
        // If the current part is not empty, add it to parts
        if (currentPart) {
          parts.push(currentPart);
        }
        
        // Start new part with current paragraph
        currentPart = paragraph;
        currentPartTokens = paragraphTokens;
      }
    }
    
    // Add the last part if not empty
    if (currentPart) {
      parts.push(currentPart);
    }
    
    return parts;
  }

  /**
   * Split message guided by line patterns
   */
  _splitByLinePatterns(message, linePatterns) {
    // Get the dominant pattern to guide splitting
    const dominantPattern = linePatterns.dominantPattern;
    
    let parts = [];
    
    // Determine splitting strategy based on dominant pattern
    if (dominantPattern === 'parallel') {
      // Split at consecutive newlines (paragraph breaks)
      parts = this._splitByParagraphs(message);
    } else if (dominantPattern === 'intersecting') {
      // Split at section boundaries (headers, code blocks, tables)
      parts = this._splitBySections(message);
    } else if (dominantPattern === 'spiral') {
      // Split by logical segments while preserving connections
      parts = this._splitByLogicalSegments(message);
    } else if (dominantPattern === 'fractal') {
      // Split by hierarchy levels, preserving the structure
      parts = this._splitByHierarchy(message);
    } else {
      // Fallback to simple token-based splitting
      parts = this._splitByTokens(message);
    }
    
    // Ensure each part is under the token threshold
    return this._ensurePartSizes(parts);
  }

  /**
   * Split by paragraphs (for parallel pattern)
   */
  _splitByParagraphs(message) {
    const paragraphs = message.split(/\n\s*\n/);
    return this._groupByTokenThreshold(paragraphs);
  }

  /**
   * Split by sections (for intersecting pattern)
   */
  _splitBySections(message) {
    // Find section boundaries (headers, code blocks, etc.)
    const sectionMatches = [...message.matchAll(/(?:^|\n)(?:#{1,6} |```|---|\|[\-|]+\|)/g)];
    
    if (sectionMatches.length <= 1) {
      return [message];
    }
    
    // Create sections
    const sections = [];
    for (let i = 0; i < sectionMatches.length; i++) {
      const start = sectionMatches[i].index;
      const end = i < sectionMatches.length - 1 ? sectionMatches[i + 1].index : message.length;
      sections.push(message.substring(start, end));
    }
    
    return this._groupByTokenThreshold(sections);
  }

  /**
   * Split by logical segments (for spiral pattern)
   */
  _splitByLogicalSegments(message) {
    // Try to find logical segments (numbered lists, Q&A pairs, etc.)
    const segments = [];
    let currentSegment = '';
    let inCodeBlock = false;
    
    // Split message into lines
    const lines = message.split('\n');
    
    for (const line of lines) {
      // Check for code block boundaries
      if (line.trim().startsWith('```')) {
        inCodeBlock = !inCodeBlock;
      }
      
      // Look for segment boundaries when not in code block
      if (!inCodeBlock && 
          (line.match(/^\d+[\.\)]\s+/) || // Numbered list item
           line.match(/^[QA][\d\.]+:/) || // Q&A pattern
           line.match(/^#+\s+/))) { // Header
        
        // Save current segment if not empty
        if (currentSegment) {
          segments.push(currentSegment);
        }
        
        // Start new segment
        currentSegment = line;
      } else {
        // Continue current segment
        currentSegment += '\n' + line;
      }
    }
    
    // Add the last segment if not empty
    if (currentSegment) {
      segments.push(currentSegment);
    }
    
    return segments.length > 0 ? this._groupByTokenThreshold(segments) : [message];
  }

  /**
   * Split by hierarchy (for fractal pattern)
   */
  _splitByHierarchy(message) {
    // Try to identify hierarchical structures like nested lists or JSON
    const isJSON = message.trim().startsWith('{') && message.trim().endsWith('}');
    
    if (isJSON) {
      try {
        // Parse JSON to split by top-level keys
        const json = JSON.parse(message);
        const segments = [];
        
        for (const key of Object.keys(json)) {
          segments.push(JSON.stringify({ [key]: json[key] }, null, 2));
        }
        
        return this._groupByTokenThreshold(segments);
      } catch (e) {
        // Not valid JSON, fall back to other methods
      }
    }
    
    // Identify sections by heading levels
    const headingMatches = [...message.matchAll(/(?:^|\n)(#{1,6})\s+(.+)(?:\n|$)/g)];
    
    if (headingMatches.length > 0) {
      // Split by top-level headings
      const sections = [];
      let currentSection = '';
      let currentLevel = 1;
      
      for (const match of headingMatches) {
        const level = match[1].length;
        const heading = match[0];
        
        if (level <= currentLevel) {
          // Save current section if not empty
          if (currentSection) {
            sections.push(currentSection);
          }
          
          // Start new section
          currentSection = heading;
          currentLevel = level;
        } else {
          // Continue current section with subsection
          currentSection += '\n' + heading;
        }
      }
      
      // Add the remainder of the message to the last section
      if (currentSection) {
        sections.push(currentSection);
      }
      
      return this._groupByTokenThreshold(sections);
    }
    
    // Fallback to regular splitting if hierarchy not detected
    return this._splitByParagraphs(message);
  }

  /**
   * Split by tokens (for any pattern)
   */
  _splitByTokens(message) {
    const estimatedTokens = this._estimateTokens(message);
    
    if (estimatedTokens <= this.splitThreshold) {
      return [message];
    }
    
    // Calculate roughly how many parts we need
    const numParts = Math.ceil(estimatedTokens / this.splitThreshold);
    const charPerPart = Math.ceil(message.length / numParts);
    
    // Split into roughly equal parts, trying to split at sentence boundaries
    const parts = [];
    let startIndex = 0;
    
    while (startIndex < message.length) {
      let endIndex = Math.min(startIndex + charPerPart, message.length);
      
      // Try to find a sentence boundary
      if (endIndex < message.length) {
        const nextPeriod = message.indexOf('.', endIndex - 20);
        if (nextPeriod !== -1 && nextPeriod < endIndex + 20) {
          endIndex = nextPeriod + 1;
        }
      }
      
      parts.push(message.substring(startIndex, endIndex));
      startIndex = endIndex;
    }
    
    return parts;
  }

  /**
   * Group segments into parts that fit within the token threshold
   */
  _groupByTokenThreshold(segments) {
    const parts = [];
    let currentPart = '';
    let currentPartTokens = 0;
    
    for (const segment of segments) {
      const segmentTokens = this._estimateTokens(segment);
      
      if (currentPartTokens + segmentTokens <= this.splitThreshold) {
        currentPart += (currentPart ? '\n\n' : '') + segment;
        currentPartTokens += segmentTokens;
      } else {
        // If the current part is not empty, add it to parts
        if (currentPart) {
          parts.push(currentPart);
        }
        
        // If a single segment exceeds the threshold, it needs to be split further
        if (segmentTokens > this.splitThreshold) {
          const segmentParts = this._splitByTokens(segment);
          parts.push(...segmentParts);
        } else {
          // Start new part with current segment
          currentPart = segment;
          currentPartTokens = segmentTokens;
        }
      }
    }
    
    // Add the last part if not empty
    if (currentPart) {
      parts.push(currentPart);
    }
    
    return parts;
  }

  /**
   * Ensure all parts are under the token threshold
   */
  _ensurePartSizes(parts) {
    const result = [];
    
    for (const part of parts) {
      const partTokens = this._estimateTokens(part);
      
      if (partTokens <= this.splitThreshold) {
        result.push(part);
      } else {
        // Recursively split this part
        const subParts = this._splitByTokens(part);
        result.push(...subParts);
      }
    }
    
    return result;
  }

  /**
   * Clean message data
   */
  _cleanMessageData(message, linePatterns, config) {
    // If no line patterns, perform basic cleaning
    if (!linePatterns) {
      return this._basicCleanMessage(message);
    }
    
    // Use dominant pattern to guide cleaning
    const dominantPattern = linePatterns.dominantPattern;
    
    if (dominantPattern === 'parallel') {
      return this._cleanParallelPattern(message, linePatterns);
    } else if (dominantPattern === 'intersecting') {
      return this._cleanIntersectingPattern(message, linePatterns);
    } else if (dominantPattern === 'spiral') {
      return this._cleanSpiralPattern(message, linePatterns);
    } else if (dominantPattern === 'fractal') {
      return this._cleanFractalPattern(message, linePatterns);
    } else {
      return this._basicCleanMessage(message);
    }
  }

  /**
   * Basic message cleaning
   */
  _basicCleanMessage(message) {
    // Remove excessive whitespace
    let cleaned = message.replace(/\n{3,}/g, '\n\n');
    
    // Remove repeated words
    cleaned = cleaned.replace(/\b(\w+)\s+\1\b/gi, '$1');
    
    // Remove trailing whitespace from lines
    cleaned = cleaned.replace(/[ \t]+$/gm, '');
    
    return cleaned;
  }

  /**
   * Clean parallel pattern messages
   */
  _cleanParallelPattern(message, linePatterns) {
    // Optimize parallel structures
    let cleaned = message;
    
    // Remove redundant parallel markers
    cleaned = cleaned.replace(/^[-*+]\s+[-*+]\s+/gm, '- ');
    
    // Convert inconsistent list markers to consistent ones
    cleaned = cleaned.replace(/^[*+]\s+/gm, '- ');
    
    // Normalize numbered lists
    let listNumber = 1;
    cleaned = cleaned.replace(/^\d+[\.\)]\s+/gm, (match) => {
      return `${listNumber++}. `;
    });
    
    // Preserve paragraph breaks but remove excessive newlines
    cleaned = cleaned.replace(/\n{3,}/g, '\n\n');
    
    return cleaned;
  }

  /**
   * Clean intersecting pattern messages
   */
  _cleanIntersectingPattern(message, linePatterns) {
    // Optimize intersecting structures like tables and code blocks
    let cleaned = message;
    
    // Simplify table separators
    cleaned = cleaned.replace(/\|[\-:]+\|[\-:]+\|/g, '|---|---|');
    
    // Ensure code blocks are properly formatted
    cleaned = cleaned.replace(/```\s+/g, '```\n');
    cleaned = cleaned.replace(/\s+```/g, '\n```');
    
    // Fix inconsistent heading levels
    let lastLevel = 0;
    cleaned = cleaned.replace(/^(#{1,6})\s+(.+)$/gm, (match, hashes, title) => {
      const level = hashes.length;
      
      // Ensure heading levels don't skip more than one level
      if (lastLevel === 0 || level <= lastLevel + 1) {
        lastLevel = level;
        return match;
      } else {
        const newLevel = lastLevel + 1;
        lastLevel = newLevel;
        return `${'#'.repeat(newLevel)} ${title}`;
      }
    });
    
    return cleaned;
  }

  /**
   * Clean spiral pattern messages
   */
  _cleanSpiralPattern(message, linePatterns) {
    // Optimize circular references and recursive elements
    let cleaned = message;
    
    // Identify and remove duplicate references
    const references = new Set();
    
    // Remove duplicated references like "[1] See above" that occur multiple times
    cleaned = cleaned.replace(/\[([^\]]+)\]\s+[^[\n]+/g, (match, ref) => {
      if (references.has(ref)) {
        return ''; // Remove duplicate reference
      }
      references.add(ref);
      return match;
    });
    
    // Simplify recursive aspects while preserving structure
    cleaned = cleaned.replace(/\(see also: ([^)]+)\)/g, '→ $1');
    
    return cleaned;
  }

  /**
   * Clean fractal pattern messages
   */
  _cleanFractalPattern(message, linePatterns) {
    // Optimize hierarchical structures
    let cleaned = message;
    
    // Simplify JSON-like structures if identified
    if (message.includes('{') && message.includes('}')) {
      // Remove unnecessary whitespace in JSON
      cleaned = cleaned.replace(/{\s+"/g, '{"');
      cleaned = cleaned.replace(/"\s+}/g, '"}');
      cleaned = cleaned.replace(/",\s+"/g, '","');
    }
    
    // Optimize nested list structures
    let previousIndent = 0;
    cleaned = cleaned.replace(/^(\s*)([*+-]|\d+\.)\s+/gm, (match, indent, marker) => {
      // Ensure indentation is consistent
      const indentLevel = indent.length;
      
      if (indentLevel > previousIndent && indentLevel - previousIndent > 2) {
        // Too much indentation, reduce it
        return ' '.repeat(previousIndent + 2) + marker + ' ';
      }
      
      previousIndent = indentLevel;
      return match;
    });
    
    return cleaned;
  }

  /**
   * Detect line patterns in message
   */
  _detectLinePatterns(message) {
    const patterns = [];
    let patternCount = 0;
    
    // Check for parallel lines pattern
    const parallelCount = (message.match(/\n\n/g) || []).length +
                        (message.match(/^[-*+]\s+/gm) || []).length +
                        (message.match(/^\d+[\.\)]\s+/gm) || []).length;
    
    if (parallelCount > 0) {
      patterns.push({
        type: 'parallel',
        count: parallelCount,
        score: parallelCount * 1.0
      });
      patternCount += parallelCount;
    }
    
    // Check for intersecting lines pattern
    const intersectingCount = (message.match(/\|[\-|]+\|/g) || []).length +
                             (message.match(/```/g) || []).length / 2 +
                             (message.match(/^#{1,6}\s+/gm) || []).length;
    
    if (intersectingCount > 0) {
      patterns.push({
        type: 'intersecting',
        count: intersectingCount,
        score: intersectingCount * 1.2
      });
      patternCount += intersectingCount;
    }
    
    // Check for spiral pattern
    const spiralCount = (message.match(/\(see also: [^)]+\)/g) || []).length +
                       (message.match(/\[[^\]]+\]/g) || []).length +
                       (message.match(/\bcircular\b|\bloop\b|\brecursion\b/gi) || []).length;
    
    if (spiralCount > 0) {
      patterns.push({
        type: 'spiral',
        count: spiralCount,
        score: spiralCount * 1.5
      });
      patternCount += spiralCount;
    }
    
    // Check for fractal pattern
    const fractalCount = (message.match(/\{\s*"/g) || []).length + // JSON opening braces
                        (message.match(/^\s+[-*+]\s+/gm) || []).length + // Nested list items
                        (message.match(/^\s+\d+[\.\)]\s+/gm) || []).length; // Nested numbered lists
    
    if (fractalCount > 0) {
      patterns.push({
        type: 'fractal',
        count: fractalCount,
        score: fractalCount * 1.8
      });
      patternCount += fractalCount;
    }
    
    // Determine dominant pattern
    patterns.sort((a, b) => b.score - a.score);
    const dominantPattern = patterns.length > 0 ? patterns[0].type : null;
    
    return {
      patterns,
      patternCount,
      dominantPattern
    };
  }

  /**
   * Store line patterns in database
   */
  _storeLinePatterns(messageId, linePatterns) {
    this.database.linePatterns[messageId] = linePatterns;
    
    // Update token distribution statistics
    if (linePatterns.dominantPattern) {
      if (!this.database.tokenDistribution[linePatterns.dominantPattern]) {
        this.database.tokenDistribution[linePatterns.dominantPattern] = 0;
      }
      
      this.database.tokenDistribution[linePatterns.dominantPattern]++;
    }
  }

  /**
   * Estimate tokens in a text
   */
  _estimateTokens(text) {
    // Simple estimation: ~4 characters per token on average
    const tokenSize = this.tokenMetrics.standardTokenSize || 4;
    return Math.ceil(text.length / tokenSize);
  }

  /**
   * Get connection statistics
   */
  getConnectionStats() {
    return {
      status: this.connectionActive ? "Connected" : "Disconnected",
      currentModel: this.currentModel,
      modelCapabilities: this.claudeModels[this.currentModel],
      metrics: this.metrics,
      patternDistribution: this.database.tokenDistribution,
      messagesProcessed: this.messageHistory.length,
      fragmentsStored: this.database.messageFragments.length,
      dominantLinePattern: Object.entries(this.database.tokenDistribution)
        .sort((a, b) => b[1] - a[1])
        .map(entry => entry[0])[0] || 'none'
    };
  }

  /**
   * Analyze message splitting statistics
   */
  analyzeMessageSplitting() {
    // Analyze historical data on message splitting
    const splitMessages = this.messageHistory.filter(msg => msg.splitIntoParts > 1);
    
    if (splitMessages.length === 0) {
      return {
        status: "No split messages found",
        totalMessages: this.messageHistory.length,
        splitMessages: 0
      };
    }
    
    // Calculate statistics
    const totalParts = splitMessages.reduce((sum, msg) => sum + msg.splitIntoParts, 0);
    const averageParts = totalParts / splitMessages.length;
    const averageReduction = splitMessages.reduce((sum, msg) => sum + (msg.reductionPercentage || 0), 0) / splitMessages.length;
    
    // Group by dominant pattern
    const patternStats = {};
    
    splitMessages.forEach(msg => {
      if (msg.linePatterns && msg.linePatterns.dominantPattern) {
        const pattern = msg.linePatterns.dominantPattern;
        
        if (!patternStats[pattern]) {
          patternStats[pattern] = {
            count: 0,
            totalParts: 0,
            totalReduction: 0
          };
        }
        
        patternStats[pattern].count++;
        patternStats[pattern].totalParts += msg.splitIntoParts;
        patternStats[pattern].totalReduction += msg.reductionPercentage || 0;
      }
    });
    
    // Calculate averages for each pattern
    Object.keys(patternStats).forEach(pattern => {
      patternStats[pattern].averageParts = patternStats[pattern].totalParts / patternStats[pattern].count;
      patternStats[pattern].averageReduction = patternStats[pattern].totalReduction / patternStats[pattern].count;
    });
    
    return {
      status: "Message splitting analysis",
      totalMessages: this.messageHistory.length,
      splitMessages: splitMessages.length,
      averageParts: averageParts,
      averageReduction: averageReduction,
      patternStats: patternStats,
      mostEfficientPattern: Object.entries(patternStats)
        .sort((a, b) => b[1].averageReduction - a[1].averageReduction)
        .map(entry => entry[0])[0] || 'none'
    };
  }

  /**
   * Reset connection and metrics
   */
  resetConnection() {
    this.connectionActive = false;
    this.messageHistory = [];
    this.lineMapping = {};
    
    // Reset metrics
    this.metrics = {
      messagesProcessed: 0,
      totalTokensProcessed: 0,
      averageTokensPerMessage: 0,
      dataCleansed: 0,
      temporalEchoes: 0,
      linePatternMatches: 0
    };
    
    // Reset database
    this.database = {
      messageFragments: [],
      linePatterns: {},
      tokenDistribution: {},
      temporalAlignments: {}
    };
    
    return {
      status: "Connection reset",
      readyToInitialize: true
    };
  }
}

module.exports = new ClaudeLuminousConnection();