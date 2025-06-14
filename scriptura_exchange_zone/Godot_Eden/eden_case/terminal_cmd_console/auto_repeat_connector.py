#!/usr/bin/env python3
# Auto Repeat Connector - Handles command repetition and Claude file monitoring
# Provides low-resource connecting layer between all system components
# Integrates with symbol_reason_system for symbol-based command verification

import os
import sys
import time
import json
import random
import threading
import hashlib
import re
from datetime import datetime
from typing import Dict, List, Any, Optional, Tuple, Set, Union, Callable

# Import Symbol Reason System components
from symbol_reason_system import (
    Symbol, Reason, SymbolConnection, SymbolReasonSystem,
    SymbolType, ReasonType, AttentionLevel, SymbolVerificationResult,
    ProcessingMode, DEFAULT_CONFIG_PATH
)

# Constants
CONFIG = {
    "claude_files": [
        "/mnt/c/Users/Percision 15/CLAUDE.md",
        "/mnt/c/Users/Percision 15/CLAUDE.local.md"
    ],
    "check_interval": 5,           # Check files every 5 seconds
    "auto_repeat_enabled": True,   # Enable command auto-repeating
    "max_repeat_count": 5,         # Maximum number of times to repeat a command
    "repeat_interval": 10,         # Seconds between command repeats
    "repeat_variation": 0.2,       # Variation in repeat timing (0-1)
    "word_tracking_enabled": True, # Track word usage and repetition
    "connection_check_interval": 15, # Check connections every 15 seconds 
    "low_resource_mode": True,     # Optimize for low resource usage
    "max_memory_usage": 50,        # Max memory usage in MB
    "log_commands": True,          # Log commands to file
    "log_file": "auto_repeat.log", # Log file name
    "command_history_size": 100,   # Number of commands to keep in history
    "auto_todos": True,            # Automatically generate todos for repeated tasks
    "claude_sync_commands": [      # Commands to sync with Claude files
        "check", "update", "sync", "repeat", "word"
    ],
    "debug_mode": True,            # Enable debug output
    "cheap_ocr": True,             # Use low-resource OCR
    "ocr_accuracy": 0.7,           # Simulated OCR accuracy (0-1)
    "reason_tag_format": r"##[\w@!~$%]*",  # Regex for reason tags
    "console_width": 80,           # Console display width
    "connection_timeout": 2.0,     # Connection timeout in seconds
    "save_interval": 120,          # Save state every 2 minutes
    "auto_recovery_enabled": True, # Enable automatic recovery
    "symbol_system_config_path": os.path.join(os.path.dirname(os.path.abspath(__file__)), "symbols_config.json"),
    "symbol_auto_verification": True,  # Enable auto verification of commands via symbols
    "symbols_file_path": "symbols_data.json", # Path to save/load symbols data
    "symbol_hashtag_pattern": r"#[\w]+" # Regex for symbol hashtags in commands
}

class CommandRepeat:
    """Represents a command to be repeated"""
    
    def __init__(self, command: str, repeat_count: int = 3, interval: float = 10.0):
        self.command = command
        self.original_command = command
        self.repeat_count = repeat_count
        self.max_repeats = repeat_count
        self.interval = interval
        self.last_run = time.time()
        self.runs_completed = 0
        self.active = True
        self.success_count = 0
        self.failure_count = 0
        self.variations = self._generate_variations()
        self.next_variation_index = 0
        self.associated_words = self._extract_words()
        self.reason_tags = self._extract_reason_tags()
        self.symbol_hashtags = self._extract_symbol_hashtags()
        self.verified_symbols = []
        self.verification_status = None
        
    def _generate_variations(self) -> List[str]:
        """Generate slight variations of the command for more natural repetition"""
        variations = [self.command]  # Original command
        
        # Add variations with different spacing/formatting
        variations.append(self.command.strip())
        
        # Add variations with different capitalizations
        if len(self.command) > 0:
            variations.append(self.command[0].upper() + self.command[1:])
            
        # Add variations with trailing punctuation if not present
        if not self.command.endswith((".", "!", "?")):
            variations.append(self.command + ".")
            
        # Add variations with prefixes
        prefixes = ["repeat: ", "again: ", "do: "]
        variations.extend([prefix + self.command for prefix in prefixes])
        
        return variations
        
    def _extract_words(self) -> List[str]:
        """Extract significant words from command"""
        # Remove common words and symbols
        common_words = {"the", "and", "a", "to", "in", "of", "for", "is", "on", "with"}
        words = re.findall(r'\b\w+\b', self.command.lower())
        return [word for word in words if word not in common_words and len(word) > 2]
        
    def _extract_reason_tags(self) -> List[str]:
        """Extract reason tags from command"""
        return re.findall(CONFIG["reason_tag_format"], self.command)
    
    def _extract_symbol_hashtags(self) -> List[str]:
        """Extract symbol hashtags from command"""
        return re.findall(CONFIG["symbol_hashtag_pattern"], self.command)
        
    def get_next_variation(self) -> str:
        """Get the next variation of the command"""
        if not self.variations:
            return self.command
            
        # Cycle through variations
        variation = self.variations[self.next_variation_index]
        self.next_variation_index = (self.next_variation_index + 1) % len(self.variations)
        
        return variation
        
    def should_run(self) -> bool:
        """Check if it's time to run this command again"""
        if not self.active or self.runs_completed >= self.repeat_count:
            return False
            
        current_time = time.time()
        # Add slight variation to interval
        variation = self.interval * random.uniform(1 - CONFIG["repeat_variation"], 1 + CONFIG["repeat_variation"])
        return current_time - self.last_run >= variation
        
    def mark_executed(self, success: bool = True) -> None:
        """Mark this command as executed"""
        self.last_run = time.time()
        self.runs_completed += 1
        
        if success:
            self.success_count += 1
        else:
            self.failure_count += 1
            
        # Deactivate if max repeats reached
        if self.runs_completed >= self.repeat_count:
            self.active = False
            
    def reset(self) -> None:
        """Reset the command for a new repeat cycle"""
        self.runs_completed = 0
        self.active = True
        self.last_run = time.time()
        
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization"""
        return {
            "command": self.command,
            "original_command": self.original_command,
            "repeat_count": self.repeat_count,
            "max_repeats": self.max_repeats,
            "interval": self.interval,
            "last_run": self.last_run,
            "runs_completed": self.runs_completed,
            "active": self.active,
            "success_count": self.success_count,
            "failure_count": self.failure_count,
            "variations": self.variations,
            "next_variation_index": self.next_variation_index,
            "associated_words": self.associated_words,
            "reason_tags": self.reason_tags,
            "symbol_hashtags": self.symbol_hashtags,
            "verified_symbols": self.verified_symbols,
            "verification_status": self.verification_status
        }
        
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'CommandRepeat':
        """Create a CommandRepeat from dictionary"""
        cmd = cls(
            data["command"],
            data["repeat_count"],
            data["interval"]
        )
        
        cmd.original_command = data["original_command"]
        cmd.max_repeats = data["max_repeats"]
        cmd.last_run = data["last_run"]
        cmd.runs_completed = data["runs_completed"]
        cmd.active = data["active"]
        cmd.success_count = data["success_count"]
        cmd.failure_count = data["failure_count"]
        cmd.variations = data["variations"]
        cmd.next_variation_index = data["next_variation_index"]
        cmd.associated_words = data["associated_words"]
        cmd.reason_tags = data["reason_tags"]
        cmd.symbol_hashtags = data.get("symbol_hashtags", [])
        cmd.verified_symbols = data.get("verified_symbols", [])
        cmd.verification_status = data.get("verification_status")
        
        return cmd

class ClaudeFileMonitor:
    """Monitors Claude files for changes"""
    
    def __init__(self, file_paths: List[str]):
        self.file_paths = file_paths
        self.file_hashes = {}
        self.last_modified = {}
        self.change_callbacks: List[Callable] = []
        self.content_cache = {}
        self.last_check = time.time()
        self.changes_detected = 0
        self.tracked_files = 0
        self.symbol_hashtags = set() # Set of hashtags found in monitored files
        
        # Initialize file info
        self._init_file_info()
        
    def _init_file_info(self) -> None:
        """Initialize file hash and modification info"""
        for file_path in self.file_paths:
            if os.path.exists(file_path):
                self.tracked_files += 1
                try:
                    self.file_hashes[file_path] = self._calculate_file_hash(file_path)
                    self.last_modified[file_path] = os.path.getmtime(file_path)
                    
                    # Cache content if not too large
                    file_size = os.path.getsize(file_path)
                    if file_size < 1024 * 1024:  # 1MB limit
                        with open(file_path, 'r', encoding='utf-8') as f:
                            content = f.read()
                            self.content_cache[file_path] = content
                            # Extract hashtags for symbol system integration
                            self._extract_symbol_hashtags(content)
                except Exception as e:
                    print(f"Error initializing file info for {file_path}: {e}")
                    
    def _calculate_file_hash(self, file_path: str) -> str:
        """Calculate MD5 hash of file"""
        if not os.path.exists(file_path):
            return ""
            
        try:
            with open(file_path, 'rb') as f:
                file_hash = hashlib.md5()
                # Read in chunks for large files
                for chunk in iter(lambda: f.read(4096), b""):
                    file_hash.update(chunk)
                return file_hash.hexdigest()
        except Exception as e:
            print(f"Error calculating hash for {file_path}: {e}")
            return ""
    
    def _extract_symbol_hashtags(self, content: str) -> None:
        """Extract symbol hashtags from content and update the set"""
        hashtags = re.findall(CONFIG["symbol_hashtag_pattern"], content)
        if hashtags:
            self.symbol_hashtags.update(hashtags)
            
    def add_change_callback(self, callback: Callable) -> None:
        """Add a callback to be called when a file changes"""
        if callback not in self.change_callbacks:
            self.change_callbacks.append(callback)
            
    def check_for_changes(self) -> List[str]:
        """Check for changes in monitored files"""
        changed_files = []
        
        for file_path in self.file_paths:
            if not os.path.exists(file_path):
                continue
                
            try:
                # Check modification time first (faster)
                current_mtime = os.path.getmtime(file_path)
                if file_path in self.last_modified and current_mtime > self.last_modified[file_path]:
                    # File has been modified, check hash
                    current_hash = self._calculate_file_hash(file_path)
                    if current_hash != self.file_hashes.get(file_path, ""):
                        changed_files.append(file_path)
                        self.file_hashes[file_path] = current_hash
                        self.last_modified[file_path] = current_mtime
                        
                        # Update content cache and extract hashtags
                        with open(file_path, 'r', encoding='utf-8') as f:
                            content = f.read()
                            self.content_cache[file_path] = content
                            self._extract_symbol_hashtags(content)
                            
            except Exception as e:
                print(f"Error checking file {file_path}: {e}")
                
        # Invoke callbacks if any files changed
        if changed_files and self.change_callbacks:
            self.changes_detected += len(changed_files)
            for callback in self.change_callbacks:
                try:
                    callback(changed_files)
                except Exception as e:
                    print(f"Error in change callback: {e}")
                    
        self.last_check = time.time()
        return changed_files
        
    def get_file_content(self, file_path: str) -> str:
        """Get content of a file, from cache if available"""
        if file_path in self.content_cache:
            return self.content_cache[file_path]
            
        if not os.path.exists(file_path):
            return ""
            
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                self.content_cache[file_path] = content
                # Extract hashtags for symbol system integration
                self._extract_symbol_hashtags(content)
                return content
        except Exception as e:
            print(f"Error reading file {file_path}: {e}")
            return ""
    
    def get_symbol_hashtags(self) -> Set[str]:
        """Get the set of symbol hashtags found in monitored files"""
        return self.symbol_hashtags
            
    def get_status(self) -> Dict[str, Any]:
        """Get status information about the monitor"""
        return {
            "tracked_files": self.tracked_files,
            "changes_detected": self.changes_detected,
            "last_check": self.last_check,
            "symbol_hashtags": list(self.symbol_hashtags),
            "files": {
                file_path: {
                    "exists": os.path.exists(file_path),
                    "size": os.path.getsize(file_path) if os.path.exists(file_path) else 0,
                    "last_modified": self.last_modified.get(file_path, 0)
                }
                for file_path in self.file_paths
            }
        }

class WordTracker:
    """Tracks word usage and repetition"""
    
    def __init__(self):
        self.word_counts = {}
        self.word_last_seen = {}
        self.repeated_words = {}
        self.total_words = 0
        self.common_words = {
            "the", "and", "a", "to", "in", "of", "for", "is", "on", "with",
            "this", "that", "it", "you", "not", "are", "be", "will", "as"
        }
        self.word_categories = {
            "action": ["run", "jump", "move", "create", "delete", "update", "check"],
            "system": ["file", "command", "program", "code", "function", "class"],
            "attribute": ["color", "size", "shape", "position", "style", "format"],
            "connection": ["link", "connect", "join", "relate", "bind", "tie"],
            "symbolic": ["symbol", "reason", "hashtag", "verify", "token", "icon"]
        }
        self.category_counts = {cat: 0 for cat in self.word_categories}
        
    def track_words(self, text: str) -> Dict[str, int]:
        """Track words in the given text"""
        # Extract words
        words = re.findall(r'\b\w+\b', text.lower())
        
        # Update counts
        new_counts = {}
        for word in words:
            if len(word) <= 2 or word in self.common_words:
                continue
                
            self.word_counts[word] = self.word_counts.get(word, 0) + 1
            new_counts[word] = self.word_counts[word]
            
            # Check for repetition
            current_time = time.time()
            if word in self.word_last_seen:
                time_diff = current_time - self.word_last_seen[word]
                if time_diff < 60:  # Repeated within a minute
                    self.repeated_words[word] = self.repeated_words.get(word, 0) + 1
                    
            self.word_last_seen[word] = current_time
            
            # Update category counts
            for category, category_words in self.word_categories.items():
                if word in category_words:
                    self.category_counts[category] += 1
                    
        # Update total
        self.total_words += len([w for w in words if len(w) > 2 and w not in self.common_words])
        
        return new_counts
        
    def get_top_words(self, count: int = 10) -> List[Tuple[str, int]]:
        """Get top used words"""
        sorted_words = sorted(self.word_counts.items(), key=lambda x: x[1], reverse=True)
        return sorted_words[:count]
        
    def get_top_repeated_words(self, count: int = 5) -> List[Tuple[str, int]]:
        """Get top repeated words"""
        sorted_repeated = sorted(self.repeated_words.items(), key=lambda x: x[1], reverse=True)
        return sorted_repeated[:count]
        
    def get_word_categories_distribution(self) -> Dict[str, float]:
        """Get distribution of words by category"""
        total_categorized = sum(self.category_counts.values())
        if total_categorized == 0:
            return {cat: 0.0 for cat in self.category_counts}
            
        return {
            cat: (count / total_categorized) * 100 
            for cat, count in self.category_counts.items()
        }
        
    def get_statistics(self) -> Dict[str, Any]:
        """Get statistics about tracked words"""
        return {
            "total_unique_words": len(self.word_counts),
            "total_words": self.total_words,
            "top_words": self.get_top_words(),
            "top_repeated": self.get_top_repeated_words(),
            "categories": self.get_word_categories_distribution()
        }

class TodoItem:
    """Represents a todo item for repeated tasks"""
    
    def __init__(self, title: str, source_command: str = "", priority: str = "medium"):
        self.title = title
        self.source_command = source_command
        self.creation_time = time.time()
        self.completion_time = None
        self.is_completed = False
        self.priority = priority  # low, medium, high
        self.notes = []
        self.tags = []
        self.related_commands = []
        self.associated_symbols = []  # List of associated symbol IDs
        
    def complete(self) -> None:
        """Mark this todo as completed"""
        self.is_completed = True
        self.completion_time = time.time()
        
    def add_note(self, note: str) -> None:
        """Add a note to this todo"""
        self.notes.append({
            "text": note,
            "time": time.time()
        })
        
    def add_tag(self, tag: str) -> None:
        """Add a tag to this todo"""
        if tag not in self.tags:
            self.tags.append(tag)
            
    def add_related_command(self, command: str) -> None:
        """Add a related command to this todo"""
        if command not in self.related_commands:
            self.related_commands.append(command)
    
    def add_associated_symbol(self, symbol_id: str) -> None:
        """Add an associated symbol ID to this todo"""
        if symbol_id not in self.associated_symbols:
            self.associated_symbols.append(symbol_id)
            
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization"""
        return {
            "title": self.title,
            "source_command": self.source_command,
            "creation_time": self.creation_time,
            "completion_time": self.completion_time,
            "is_completed": self.is_completed,
            "priority": self.priority,
            "notes": self.notes,
            "tags": self.tags,
            "related_commands": self.related_commands,
            "associated_symbols": self.associated_symbols
        }
        
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'TodoItem':
        """Create a TodoItem from dictionary"""
        todo = cls(
            data["title"],
            data["source_command"],
            data["priority"]
        )
        
        todo.creation_time = data["creation_time"]
        todo.completion_time = data["completion_time"]
        todo.is_completed = data["is_completed"]
        todo.notes = data["notes"]
        todo.tags = data["tags"]
        todo.related_commands = data["related_commands"]
        todo.associated_symbols = data.get("associated_symbols", [])
        
        return todo

class CheapOCR:
    """Simple, low-resource OCR simulation"""
    
    def __init__(self, accuracy: float = 0.7):
        self.accuracy = accuracy
        self.last_processed = {}
        self.process_count = 0
        
    def process_text(self, image_path: str) -> str:
        """Simulate OCR processing of an image file"""
        if not os.path.exists(image_path):
            return f"Error: Image file not found: {image_path}"
            
        # Check if we've already processed this image
        if image_path in self.last_processed:
            return self.last_processed[image_path]
            
        # Get image file info
        try:
            file_size = os.path.getsize(image_path)
            file_ext = os.path.splitext(image_path)[1].lower()
            
            # Simulate extraction based on file info
            
            # Base text - extract some info from filename
            base_text = f"Image {os.path.basename(image_path)} "
            
            # Add simulated extracted words
            word_count = int((file_size / 1024) * 2)  # Roughly 2 words per KB
            word_count = min(max(5, word_count), 100)  # Between 5-100 words
            
            # Generate fake extracted text
            words = [
                "text", "document", "information", "data", "content",
                "screen", "image", "file", "system", "process",
                "view", "display", "window", "program", "application",
                "symbol", "reason", "hashtag", "connection", "visual"  # Add Symbol system words
            ]
            
            extracted_words = []
            for _ in range(word_count):
                if random.random() < self.accuracy:
                    # Add a correctly "recognized" word
                    extracted_words.append(random.choice(words))
                else:
                    # Add a "misrecognized" word (with some errors)
                    word = random.choice(words)
                    # Introduce errors
                    chars = list(word)
                    error_pos = random.randint(0, len(chars) - 1)
                    chars[error_pos] = random.choice("abcdefghijklmnopqrstuvwxyz")
                    extracted_words.append("".join(chars))
                    
            # Combine into text
            result = base_text + " ".join(extracted_words)
            
            # Save result for future reference
            self.last_processed[image_path] = result
            self.process_count += 1
            
            return result
            
        except Exception as e:
            return f"OCR error: {e}"
            
    def clear_cache(self) -> None:
        """Clear the processed image cache"""
        self.last_processed = {}
        
    def get_statistics(self) -> Dict[str, Any]:
        """Get statistics about OCR usage"""
        return {
            "processes": self.process_count,
            "cached_images": len(self.last_processed),
            "accuracy": self.accuracy
        }

class SymbolVisualizer:
    """Helper class for visualizing symbols in connector outputs"""
    
    def __init__(self, use_color: bool = True):
        self.use_color = use_color
        self.console_width = CONFIG.get("console_width", 80)
        self.color_map = {
            "visual": "\033[36m",      # Cyan for visual symbols
            "textual": "\033[32m",     # Green for textual symbols
            "conceptual": "\033[35m",  # Magenta for conceptual symbols
            "high": "\033[1;31m",      # Bright red for high attention
            "medium": "\033[1;33m",    # Bright yellow for medium attention
            "low": "\033[1;32m",       # Bright green for low attention
            "reset": "\033[0m"         # Reset color
        }
    
    def format_symbol(self, symbol: Symbol) -> str:
        """Format a symbol for display"""
        if not self.use_color:
            return f"[{symbol.id}:{symbol.type.value}] {symbol.value}"
            
        type_color = self.color_map.get(symbol.type.value, "")
        attention_color = self.color_map.get(symbol.attention_level.value, "")
        reset = self.color_map["reset"]
        
        return f"{type_color}[{symbol.id}:{attention_color}{symbol.attention_level.value}{type_color}]{reset} {symbol.value}"
    
    def format_symbol_hashtags(self, hashtags: List[str]) -> str:
        """Format symbol hashtags for display"""
        if not hashtags:
            return ""
            
        if not self.use_color:
            return ", ".join(hashtags)
            
        colored_tags = []
        for tag in hashtags:
            color = self.color_map.get("medium", "")
            reset = self.color_map["reset"]
            colored_tags.append(f"{color}{tag}{reset}")
            
        return " ".join(colored_tags)
    
    def format_command_verification(self, command: str, status: SymbolVerificationResult) -> str:
        """Format command verification status"""
        if status == SymbolVerificationResult.VERIFIED:
            color = self.color_map.get("high", "")
            status_text = "VERIFIED"
        elif status == SymbolVerificationResult.REJECTED:
            color = self.color_map.get("low", "")
            status_text = "REJECTED"
        else:
            color = self.color_map.get("medium", "")
            status_text = "PENDING"
            
        reset = self.color_map["reset"]
        
        return f"{color}[{status_text}]{reset} {command}"
    
    def create_symbol_summary(self, symbol_system: SymbolReasonSystem) -> str:
        """Create a summary of symbols in the system"""
        if not symbol_system:
            return "No symbol system available"
            
        lines = []
        lines.append("Symbol System Summary")
        lines.append("=" * min(30, self.console_width))
        lines.append(f"Total Symbols: {len(symbol_system.symbols)}")
        lines.append(f"Current Turn: {symbol_system.turn_count}, Dimension: {symbol_system.current_dimension}")
        
        # Count symbols by type
        type_counts = {}
        for symbol in symbol_system.symbols.values():
            type_name = symbol.type.value
            type_counts[type_name] = type_counts.get(type_name, 0) + 1
            
        lines.append("\nSymbols by Type:")
        for type_name, count in type_counts.items():
            color = self.color_map.get(type_name, "")
            reset = self.color_map["reset"]
            lines.append(f"- {color}{type_name}{reset}: {count}")
            
        # Show hashtag counts
        hashtag_counts = {}
        for hashtag, symbol_ids in symbol_system.hashtag_map.items():
            hashtag_counts[hashtag] = len(symbol_ids)
            
        if hashtag_counts:
            lines.append("\nTop Hashtags:")
            sorted_hashtags = sorted(hashtag_counts.items(), key=lambda x: x[1], reverse=True)[:5]
            for hashtag, count in sorted_hashtags:
                lines.append(f"- {hashtag}: {count} symbols")
                
        return "\n".join(lines)

class AutoRepeatConnector:
    """Main connector class for auto-repeating commands and monitoring files"""
    
    def __init__(self):
        # State
        self.running = False
        self.commands: Dict[str, CommandRepeat] = {}
        self.command_history = []
        self.todos: List[TodoItem] = []
        self.connected_systems = {}
        self.last_update = time.time()
        self.last_save = time.time()
        
        # Component instances
        self.file_monitor = ClaudeFileMonitor(CONFIG["claude_files"])
        self.file_monitor.add_change_callback(self._on_claude_file_changed)
        
        self.word_tracker = WordTracker()
        self.ocr = CheapOCR(CONFIG["ocr_accuracy"])
        
        # Initialize Symbol Reason System
        self._init_symbol_system()
        
        # Visualization
        self.symbol_visualizer = SymbolVisualizer()
        
        # Threading
        self.update_thread = None
        self.command_thread = None
        
        # Initialize log file
        if CONFIG["log_commands"]:
            with open(CONFIG["log_file"], "w") as f:
                f.write(f"Auto Repeat Connector Log - {datetime.now().isoformat()}\n")
                f.write("=" * 50 + "\n\n")
    
    def _init_symbol_system(self) -> None:
        """Initialize the Symbol Reason System"""
        try:
            # Create the processing mode based on config
            proc_mode = ProcessingMode.LOW_RESOURCE if CONFIG["low_resource_mode"] else ProcessingMode.STANDARD
            
            # Initialize the symbol system
            self.symbol_system = SymbolReasonSystem(
                config_path=CONFIG["symbol_system_config_path"],
                processing_mode=proc_mode
            )
            
            # Try to load saved symbols if the file exists
            if os.path.exists(CONFIG["symbols_file_path"]):
                self.symbol_system.load_symbols(CONFIG["symbols_file_path"])
                
            # Register command verification handler
            self._register_symbol_handlers()
            
            self._log_message("Symbol Reason System initialized")
        except Exception as e:
            print(f"Error initializing Symbol Reason System: {e}")
            self.symbol_system = None
                
    def start(self) -> bool:
        """Start the connector"""
        if self.running:
            return True  # Already running
            
        # Set running flag
        self.running = True
        
        # Start update thread
        self.update_thread = threading.Thread(target=self._update_thread)
        self.update_thread.daemon = True
        self.update_thread.start()
        
        # Start command thread
        self.command_thread = threading.Thread(target=self._command_thread)
        self.command_thread.daemon = True
        self.command_thread.start()
        
        print("Auto Repeat Connector started")
        return True
        
    def stop(self) -> None:
        """Stop the connector"""
        self.running = False
        
        # Wait for threads to end
        if self.update_thread:
            self.update_thread.join(timeout=1.0)
            
        if self.command_thread:
            self.command_thread.join(timeout=1.0)
            
        # Save state before exiting
        self._save_state()
        
        # Save symbol system if available
        if self.symbol_system:
            self.symbol_system.save_symbols(CONFIG["symbols_file_path"])
        
        print("Auto Repeat Connector stopped")
        
    def _update_thread(self) -> None:
        """Thread for regular updates and monitoring"""
        last_file_check = time.time()
        last_connection_check = time.time()
        
        while self.running:
            current_time = time.time()
            
            try:
                # Check Claude files for changes
                if current_time - last_file_check >= CONFIG["check_interval"]:
                    self.file_monitor.check_for_changes()
                    last_file_check = current_time
                    
                # Check connections
                if current_time - last_connection_check >= CONFIG["connection_check_interval"]:
                    self._check_connections()
                    last_connection_check = current_time
                    
                # Garbage collection and memory management if in low resource mode
                if CONFIG["low_resource_mode"]:
                    self._manage_resources()
                    
                # Save state periodically
                if current_time - self.last_save >= CONFIG["save_interval"]:
                    self._save_state()
                    
                    # Also save symbol system if available
                    if self.symbol_system:
                        self.symbol_system.save_symbols(CONFIG["symbols_file_path"])
                        
                    self.last_save = current_time
                    
            except Exception as e:
                print(f"Error in update thread: {e}")
                
                # Auto recovery if enabled
                if CONFIG["auto_recovery_enabled"]:
                    self._attempt_recovery()
                    
            # Sleep to reduce CPU usage
            time.sleep(0.1)
            
    def _command_thread(self) -> None:
        """Thread for executing repeated commands"""
        while self.running:
            try:
                # Check for commands to repeat
                for cmd_id, command in list(self.commands.items()):
                    if command.should_run():
                        # Get next variation of the command
                        variation = command.get_next_variation()
                        
                        # Verify command with symbol system if enabled
                        if CONFIG["symbol_auto_verification"] and self.symbol_system and command.symbol_hashtags:
                            # Extract symbol IDs from hashtags
                            symbol_ids = []
                            for hashtag in command.symbol_hashtags:
                                symbols = self.symbol_system.find_symbols_by_hashtag(hashtag)
                                symbol_ids.extend([s.id for s in symbols])
                                
                            if symbol_ids:
                                # Verify the command
                                verification_result = self.symbol_system.verify_command(variation, symbol_ids)
                                command.verification_status = verification_result
                                command.verified_symbols = symbol_ids
                                
                                # Skip execution if rejected
                                if verification_result == SymbolVerificationResult.REJECTED:
                                    self._log_message(f"Command '{variation}' rejected by symbol verification")
                                    command.mark_executed(False)
                                    continue
                        
                        # Execute the command
                        success = self._execute_command(variation)
                        
                        # Mark as executed
                        command.mark_executed(success)
                        
                        # Remove if completed and not active
                        if not command.active:
                            # Log completion
                            self._log_message(
                                f"Command '{command.original_command}' completed "
                                f"after {command.runs_completed} repeats. "
                                f"Success: {command.success_count}, Failure: {command.failure_count}"
                            )
                            
                # Clean up completed commands
                self._cleanup_completed_commands()
                
            except Exception as e:
                print(f"Error in command thread: {e}")
                
            # Sleep to reduce CPU usage
            time.sleep(0.5)
    
    def _register_symbol_handlers(self) -> None:
        """Register handlers for symbol system integration"""
        if not self.symbol_system:
            return
            
        # Register a handler for auto-acceptance commands
        self.symbol_system.register_command_handler("#auto_accept", self._handle_auto_accept_command)
        
    def _handle_auto_accept_command(self, args: str) -> str:
        """Handle auto-acceptance command via symbol system"""
        parts = args.split(' ', 2)
        if len(parts) < 2:
            return "Usage: #auto_accept <command_id> <symbol_ids>"
            
        command_id = parts[0]
        symbol_ids = parts[1].split(',')
        
        if command_id not in self.commands:
            return f"Command {command_id} not found"
            
        # Update command with verified symbols
        command = self.commands[command_id]
        command.verified_symbols = symbol_ids
        command.verification_status = SymbolVerificationResult.VERIFIED
        
        return f"Command {command_id} auto-accepted with symbols: {', '.join(symbol_ids)}"
            
    def _execute_command(self, command: str) -> bool:
        """Execute a command and return success/failure"""
        print(f"Executing command: {command}")
        
        # Log command
        self._log_command(command)
        
        # Track words
        self.word_tracker.track_words(command)
        
        # Add to history
        self.command_history.append({
            "command": command,
            "time": time.time(),
            "executed": True
        })
        
        # Limit history size
        if len(self.command_history) > CONFIG["command_history_size"]:
            self.command_history = self.command_history[-CONFIG["command_history_size"]:]
            
        # Process command with connected systems
        all_success = True
        for system_name, system in self.connected_systems.items():
            try:
                # Check if system has the right method
                if hasattr(system, "process_command"):
                    system.process_command(command)
                elif hasattr(system, "add_command"):
                    system.add_command(command)
                else:
                    all_success = False
            except Exception as e:
                print(f"Error executing command with {system_name}: {e}")
                all_success = False
        
        # Check for symbol hashtags and process with symbol system if available
        if self.symbol_system:
            hashtags = re.findall(CONFIG["symbol_hashtag_pattern"], command)
            if hashtags:
                for hashtag in hashtags:
                    try:
                        # Process the hashtag as a command
                        success, response = self.symbol_system.process_command(hashtag)
                        if not success:
                            all_success = False
                    except Exception as e:
                        print(f"Error processing symbol hashtag {hashtag}: {e}")
                        all_success = False
                
        return all_success
        
    def _log_command(self, command: str) -> None:
        """Log a command to the log file"""
        if not CONFIG["log_commands"]:
            return
            
        try:
            with open(CONFIG["log_file"], "a") as f:
                timestamp = datetime.now().isoformat()
                f.write(f"[{timestamp}] CMD: {command}\n")
        except Exception as e:
            print(f"Error logging command: {e}")
            
    def _log_message(self, message: str) -> None:
        """Log a message to the log file"""
        if not CONFIG["log_commands"]:
            return
            
        try:
            with open(CONFIG["log_file"], "a") as f:
                timestamp = datetime.now().isoformat()
                f.write(f"[{timestamp}] MSG: {message}\n")
        except Exception as e:
            print(f"Error logging message: {e}")
            
    def _cleanup_completed_commands(self) -> None:
        """Remove completed commands"""
        to_remove = []
        for cmd_id, command in self.commands.items():
            if not command.active:
                to_remove.append(cmd_id)
                
        for cmd_id in to_remove:
            del self.commands[cmd_id]
            
    def _check_connections(self) -> None:
        """Check connections to other systems"""
        for system_name, system in list(self.connected_systems.items()):
            # Check if system is still available
            try:
                # Simple check - see if object exists and has expected attribute
                if system is None or not hasattr(system, "__class__"):
                    # System is no longer valid
                    del self.connected_systems[system_name]
                    self._log_message(f"Connection to {system_name} lost")
            except Exception:
                # Error accessing system, remove it
                del self.connected_systems[system_name]
                self._log_message(f"Error checking connection to {system_name}")
                
    def _manage_resources(self) -> None:
        """Manage resources in low resource mode"""
        # Clear OCR cache periodically
        if random.random() < 0.1:  # 10% chance each check
            self.ocr.clear_cache()
            
        # Limit memory usage
        try:
            import psutil
            process = psutil.Process(os.getpid())
            memory_usage = process.memory_info().rss / (1024 * 1024)  # MB
            
            if memory_usage > CONFIG["max_memory_usage"]:
                # Clear caches to reduce memory
                self.ocr.clear_cache()
                
                # Trim command history
                if len(self.command_history) > 20:
                    self.command_history = self.command_history[-20:]
                    
                # Log memory management
                self._log_message(
                    f"Memory management: Usage {memory_usage:.1f}MB exceeds "
                    f"limit of {CONFIG['max_memory_usage']}MB. Cleared caches."
                )
        except ImportError:
            # psutil not available, skip memory check
            pass
            
    def _on_claude_file_changed(self, changed_files: List[str]) -> None:
        """Handle changed Claude files"""
        if not changed_files:
            return
            
        self._log_message(f"Claude files changed: {', '.join(changed_files)}")
        
        for file_path in changed_files:
            # Get new content
            content = self.file_monitor.get_file_content(file_path)
            
            # Track words
            new_words = self.word_tracker.track_words(content)
            
            # Look for commands to sync
            self._extract_sync_commands(content)
            
            # Look for todo items
            self._extract_todos(content)
            
            # Look for symbol hashtags for the symbol system
            self._extract_symbol_hashtags(content)
            
            # Generate a summary
            summary = f"Updated {os.path.basename(file_path)}: "
            summary += f"{len(content)} chars, {len(new_words)} new words"
            print(summary)
    
    def _extract_symbol_hashtags(self, content: str) -> None:
        """Extract symbol hashtags from content and process with symbol system"""
        if not self.symbol_system:
            return
            
        hashtags = re.findall(CONFIG["symbol_hashtag_pattern"], content)
        if not hashtags:
            return
            
        self._log_message(f"Found symbol hashtags: {', '.join(hashtags)}")
        
        # Process each hashtag with the symbol system
        for hashtag in hashtags:
            try:
                # Process the hashtag as a command if it seems to be a command format
                if ' ' in hashtag or hashtag.startswith('#symbol') or hashtag.startswith('#reason'):
                    success, response = self.symbol_system.process_command(hashtag)
                    if success:
                        self._log_message(f"Processed symbol hashtag: {hashtag} -> {response}")
            except Exception as e:
                print(f"Error processing symbol hashtag {hashtag}: {e}")
            
    def _extract_sync_commands(self, content: str) -> None:
        """Extract commands to sync from content"""
        lines = content.split("\n")
        
        for line in lines:
            for cmd_keyword in CONFIG["claude_sync_commands"]:
                if cmd_keyword in line.lower():
                    # Found a potential command
                    # Make sure it's actually a command (starts with the keyword or has it after a common separator)
                    parts = re.split(r'[:\-,.]', line)
                    for part in parts:
                        part = part.strip().lower()
                        if part.startswith(cmd_keyword):
                            # Extract the command
                            command = line.strip()
                            
                            # Add as a command to repeat
                            self.add_repeat_command(command)
                            break
                            
    def _extract_todos(self, content: str) -> None:
        """Extract todo items from content"""
        if not CONFIG["auto_todos"]:
            return
            
        # Simple regex for todo-like items
        todo_patterns = [
            r'TODO:? (.+)$',
            r'- \[ \] (.+)$',
            r'• (.+) \(todo\)',
            r'Task:? (.+)$'
        ]
        
        found_todos = []
        
        lines = content.split("\n")
        for line in lines:
            for pattern in todo_patterns:
                match = re.search(pattern, line, re.IGNORECASE)
                if match:
                    todo_text = match.group(1).strip()
                    found_todos.append(todo_text)
                    break
                    
        # Add found todos
        for todo_text in found_todos:
            # Check if this todo already exists
            existing = any(todo.title == todo_text for todo in self.todos)
            if not existing:
                # Create new todo
                todo = TodoItem(todo_text, priority="medium")
                
                # Add symbol hashtags if present in todo_text
                hashtags = re.findall(CONFIG["symbol_hashtag_pattern"], todo_text)
                if hashtags and self.symbol_system:
                    for hashtag in hashtags:
                        # Find symbols with this hashtag
                        symbols = self.symbol_system.find_symbols_by_hashtag(hashtag)
                        for symbol in symbols:
                            todo.add_associated_symbol(symbol.id)
                
                # Add to todos list
                self.todos.append(todo)
                
                # Log
                self._log_message(f"Added todo: {todo_text}")
                
    def _attempt_recovery(self) -> None:
        """Attempt recovery after an error"""
        print("Attempting recovery...")
        
        # Log recovery attempt
        self._log_message("Recovery attempt initiated")
        
        # Save state if possible
        try:
            self._save_state()
        except:
            pass
            
        # Restart threads if needed
        if self.update_thread and not self.update_thread.is_alive():
            self.update_thread = threading.Thread(target=self._update_thread)
            self.update_thread.daemon = True
            self.update_thread.start()
            
        if self.command_thread and not self.command_thread.is_alive():
            self.command_thread = threading.Thread(target=self._command_thread)
            self.command_thread.daemon = True
            self.command_thread.start()
            
        # Clear any resource issues
        if CONFIG["low_resource_mode"]:
            self.ocr.clear_cache()
            
        # Log recovery completion
        self._log_message("Recovery attempt completed")
        
    def _save_state(self) -> None:
        """Save current state"""
        try:
            state = {
                "timestamp": datetime.now().isoformat(),
                "commands": {
                    cmd_id: cmd.to_dict() 
                    for cmd_id, cmd in self.commands.items()
                },
                "command_history": self.command_history[-50:],  # Last 50 commands
                "todos": [todo.to_dict() for todo in self.todos],
                "word_stats": self.word_tracker.get_statistics(),
                "ocr_stats": self.ocr.get_statistics(),
                "connected_systems": list(self.connected_systems.keys()),
                "symbol_system_status": {
                    "available": self.symbol_system is not None,
                    "symbols_count": len(self.symbol_system.symbols) if self.symbol_system else 0,
                    "processing_mode": self.symbol_system.processing_mode.value if self.symbol_system else "unavailable",
                    "turn_count": self.symbol_system.turn_count if self.symbol_system else 0,
                    "current_dimension": self.symbol_system.current_dimension if self.symbol_system else 0
                }
            }
            
            with open("auto_repeat_state.json", "w") as f:
                json.dump(state, f, indent=2)
                
            self.last_save = time.time()
        except Exception as e:
            print(f"Error saving state: {e}")
            
    def add_repeat_command(self, command: str, repeat_count: int = None, interval: float = None) -> str:
        """Add a command to be repeated"""
        if not CONFIG["auto_repeat_enabled"]:
            return "Auto-repeat is disabled"
            
        # Use default values if not specified
        repeat_count = repeat_count or CONFIG["max_repeat_count"]
        interval = interval or CONFIG["repeat_interval"]
        
        # Create command
        cmd = CommandRepeat(command, repeat_count, interval)
        
        # Generate ID using hash of command and timestamp
        cmd_id = f"cmd_{abs(hash(command))%10000}_{int(time.time())}"
        
        # Verify with symbol system if available and command contains hashtags
        if self.symbol_system and cmd.symbol_hashtags:
            # Extract symbol IDs from hashtags
            symbol_ids = []
            for hashtag in cmd.symbol_hashtags:
                symbols = self.symbol_system.find_symbols_by_hashtag(hashtag)
                symbol_ids.extend([s.id for s in symbols])
                
            if symbol_ids:
                # Verify the command
                verification_result = self.symbol_system.verify_command(command, symbol_ids)
                cmd.verification_status = verification_result
                cmd.verified_symbols = symbol_ids
                
                # Log verification result
                self._log_message(
                    f"Command '{command}' verification: {verification_result.value} "
                    f"with symbols: {', '.join(symbol_ids)}"
                )
        
        # Add to commands
        self.commands[cmd_id] = cmd
        
        # Log
        self._log_message(f"Added repeat command: {command} (repeat {repeat_count} times every {interval}s)")
        
        return cmd_id
        
    def connect_system(self, system_name: str, system: Any) -> bool:
        """Connect an external system"""
        if system is None:
            return False
            
        # Check if system has required methods
        if not (hasattr(system, "process_command") or hasattr(system, "add_command")):
            return False
            
        # Add to connected systems
        self.connected_systems[system_name] = system
        
        # Log connection
        self._log_message(f"Connected system: {system_name}")
        
        return True
        
    def disconnect_system(self, system_name: str) -> bool:
        """Disconnect an external system"""
        if system_name not in self.connected_systems:
            return False
            
        # Remove from connected systems
        del self.connected_systems[system_name]
        
        # Log disconnection
        self._log_message(f"Disconnected system: {system_name}")
        
        return True

    def connect_symbol_system(self, symbol_system: SymbolReasonSystem) -> bool:
        """Connect an external symbol system"""
        if not symbol_system:
            return False
            
        # Replace current symbol system
        self.symbol_system = symbol_system
        
        # Register handlers
        self._register_symbol_handlers()
        
        # Log connection
        self._log_message(f"Connected external symbol system")
        
        return True
        
    def process_image_ocr(self, image_path: str) -> str:
        """Process an image with OCR"""
        if not CONFIG["cheap_ocr"]:
            return "OCR is disabled"
            
        result = self.ocr.process_text(image_path)
        
        # Track words in result
        self.word_tracker.track_words(result)
        
        return result
        
    def create_todo(self, title: str, command: str = "", priority: str = "medium") -> int:
        """Create a new todo item"""
        # Create todo item
        todo = TodoItem(title, command, priority)
        
        # Check for symbol hashtags
        if self.symbol_system:
            hashtags = re.findall(CONFIG["symbol_hashtag_pattern"], title)
            if hashtags:
                for hashtag in hashtags:
                    # Find symbols with this hashtag
                    symbols = self.symbol_system.find_symbols_by_hashtag(hashtag)
                    for symbol in symbols:
                        todo.add_associated_symbol(symbol.id)
        
        # Add to todos list
        self.todos.append(todo)
        
        # Log creation
        self._log_message(f"Created todo: {title}")
        
        return len(self.todos) - 1  # Return index
        
    def get_active_todo_items(self) -> List[Dict[str, Any]]:
        """Get active (not completed) todo items"""
        return [
            todo.to_dict() 
            for todo in self.todos 
            if not todo.is_completed
        ]
        
    def complete_todo(self, index: int) -> bool:
        """Mark a todo item as completed"""
        if index < 0 or index >= len(self.todos):
            return False
            
        self.todos[index].complete()
        
        # Log completion
        self._log_message(f"Completed todo: {self.todos[index].title}")
        
        return True
        
    def get_word_statistics(self) -> Dict[str, Any]:
        """Get word usage statistics"""
        return self.word_tracker.get_statistics()
        
    def get_repeated_commands(self) -> List[Dict[str, Any]]:
        """Get information about currently repeating commands"""
        return [
            {
                "id": cmd_id,
                "command": cmd.command,
                "progress": f"{cmd.runs_completed}/{cmd.repeat_count}",
                "interval": cmd.interval,
                "active": cmd.active,
                "next_run": max(0, cmd.interval - (time.time() - cmd.last_run)),
                "symbol_hashtags": cmd.symbol_hashtags,
                "verification_status": cmd.verification_status.value if cmd.verification_status else "none"
            }
            for cmd_id, cmd in self.commands.items()
        ]
        
    def get_claude_monitor_status(self) -> Dict[str, Any]:
        """Get status of Claude file monitor"""
        return self.file_monitor.get_status()
    
    def get_symbol_system_status(self) -> Dict[str, Any]:
        """Get status of the Symbol Reason System"""
        if not self.symbol_system:
            return {"available": False}
            
        return {
            "available": True,
            "symbols_count": len(self.symbol_system.symbols),
            "connections_count": len(self.symbol_system.connections),
            "hashtags_count": len(self.symbol_system.hashtag_map),
            "processing_mode": self.symbol_system.processing_mode.value,
            "turn_count": self.symbol_system.turn_count,
            "current_dimension": self.symbol_system.current_dimension
        }
    
    def verify_command_symbols(self, command: str, symbol_ids: List[str]) -> Dict[str, Any]:
        """Verify a command using symbols"""
        if not self.symbol_system:
            return {"status": "error", "message": "Symbol system not available"}
            
        try:
            # Verify the command
            result = self.symbol_system.verify_command(command, symbol_ids)
            
            # Return the result
            return {
                "status": "success",
                "verification_result": result.value,
                "command": command,
                "symbol_ids": symbol_ids
            }
        except Exception as e:
            return {
                "status": "error",
                "message": str(e)
            }
        
    def generate_status_report(self) -> str:
        """Generate a full status report"""
        report = ["AUTO REPEAT CONNECTOR STATUS REPORT"]
        report.append("=" * 50)
        report.append(f"Time: {datetime.now().isoformat()}")
        report.append(f"Running: {self.running}")
        
        # Command information
        report.append("\nCOMMAND STATUS")
        report.append("-" * 20)
        report.append(f"Active Commands: {len(self.commands)}")
        report.append(f"Command History: {len(self.command_history)}")
        
        # Active commands
        if self.commands:
            report.append("\nACTIVE REPEAT COMMANDS")
            for cmd_id, cmd in self.commands.items():
                status_text = f"({cmd.runs_completed}/{cmd.repeat_count})"
                if cmd.verification_status:
                    status_text += f" [{cmd.verification_status.value}]"
                report.append(f"- {cmd.command} {status_text}")
                if cmd.symbol_hashtags:
                    report.append(f"  Hashtags: {', '.join(cmd.symbol_hashtags)}")
                
        # Todo information
        active_todos = [todo for todo in self.todos if not todo.is_completed]
        report.append(f"\nTODO ITEMS: {len(active_todos)} active, {len(self.todos) - len(active_todos)} completed")
        
        # Active todos
        if active_todos:
            report.append("\nACTIVE TODO ITEMS")
            for i, todo in enumerate(active_todos):
                report.append(f"- {todo.title} (Priority: {todo.priority})")
                if todo.associated_symbols:
                    report.append(f"  Symbols: {', '.join(todo.associated_symbols)}")
                
        # Word statistics
        word_stats = self.word_tracker.get_statistics()
        report.append(f"\nWORD STATISTICS")
        report.append(f"Unique Words: {word_stats['total_unique_words']}")
        report.append(f"Total Words: {word_stats['total_words']}")
        
        # Top words
        if word_stats['top_words']:
            report.append("\nTOP WORDS")
            for word, count in word_stats['top_words'][:5]:
                report.append(f"- {word}: {count}")
                
        # Connected systems
        report.append(f"\nCONNECTED SYSTEMS: {len(self.connected_systems)}")
        if self.connected_systems:
            for system_name in self.connected_systems:
                report.append(f"- {system_name}")
                
        # Claude file monitor
        monitor_status = self.file_monitor.get_status()
        report.append(f"\nCLAUDE FILE MONITOR")
        report.append(f"Tracked Files: {monitor_status['tracked_files']}")
        report.append(f"Changes Detected: {monitor_status['changes_detected']}")
        if 'symbol_hashtags' in monitor_status and monitor_status['symbol_hashtags']:
            report.append(f"Symbol Hashtags Found: {len(monitor_status['symbol_hashtags'])}")
            
        # Symbol system status
        if self.symbol_system:
            report.append("\nSYMBOL SYSTEM STATUS")
            report.append(f"Processing Mode: {self.symbol_system.processing_mode.value}")
            report.append(f"Symbols: {len(self.symbol_system.symbols)}")
            report.append(f"Connections: {len(self.symbol_system.connections)}")
            report.append(f"Turn: {self.symbol_system.turn_count}, Dimension: {self.symbol_system.current_dimension}")
            
            # Add top symbol hashtags
            if self.symbol_system.hashtag_map:
                top_hashtags = sorted(self.symbol_system.hashtag_map.items(), 
                                     key=lambda x: len(x[1]), reverse=True)[:5]
                if top_hashtags:
                    report.append("\nTOP SYMBOL HASHTAGS")
                    for hashtag, symbol_ids in top_hashtags:
                        report.append(f"- {hashtag}: {len(symbol_ids)} symbols")
        
        return "\n".join(report)

def main() -> None:
    """Main function for testing Auto Repeat Connector"""
    print("Initializing Auto Repeat Connector...")
    connector = AutoRepeatConnector()
    
    # Start the connector
    connector.start()
    
    print("\nAuto Repeat Connector started")
    print("- Type 'exit' or 'quit' to exit")
    print("- Type 'status' to show status")
    print("- Type 'repeat COMMAND [COUNT] [INTERVAL]' to add a repeat command")
    print("- Type 'todo TITLE' to add a todo item")
    print("- Type 'check' to check Claude files")
    print("- Type 'words' to see word statistics")
    print("- Type 'ocr PATH' to process an image with OCR")
    print("- Type 'symbol STATUS|VERIFY' to work with the symbol system")
    print("- Type anything else to execute as a normal command")
    
    # Command processing loop
    try:
        while connector.running:
            command = input("> ").strip()
            
            if command.lower() in ["exit", "quit"]:
                break
            elif command.lower() == "status":
                print(connector.generate_status_report())
            elif command.lower().startswith("repeat "):
                # Parse repeat command
                parts = command.split()
                if len(parts) < 2:
                    print("Usage: repeat COMMAND [COUNT] [INTERVAL]")
                    continue
                    
                repeat_cmd = parts[1]
                count = int(parts[2]) if len(parts) > 2 and parts[2].isdigit() else None
                interval = float(parts[3]) if len(parts) > 3 and parts[3].replace('.', '').isdigit() else None
                
                # Add repeat command
                cmd_id = connector.add_repeat_command(repeat_cmd, count, interval)
                print(f"Added repeat command with ID: {cmd_id}")
            elif command.lower().startswith("todo "):
                # Parse todo command
                if len(command) <= 5:
                    print("Usage: todo TITLE")
                    continue
                    
                title = command[5:].strip()
                
                # Add todo
                index = connector.create_todo(title)
                print(f"Added todo item at index {index}")
            elif command.lower() == "check":
                # Check Claude files for changes
                changed = connector.file_monitor.check_for_changes()
                if changed:
                    print(f"Changes detected in: {', '.join(changed)}")
                else:
                    print("No changes detected")
            elif command.lower() == "words":
                # Show word statistics
                stats = connector.get_word_statistics()
                print("\nWORD STATISTICS")
                print(f"Unique Words: {stats['total_unique_words']}")
                print(f"Total Words: {stats['total_words']}")
                
                print("\nTOP WORDS")
                for word, count in stats['top_words']:
                    print(f"- {word}: {count}")
                    
                print("\nTOP REPEATED WORDS")
                for word, count in stats['top_repeated']:
                    print(f"- {word}: {count}")
            elif command.lower().startswith("ocr "):
                # Parse OCR command
                if len(command) <= 4:
                    print("Usage: ocr IMAGE_PATH")
                    continue
                    
                image_path = command[4:].strip()
                
                # Process with OCR
                result = connector.process_image_ocr(image_path)
                print(f"OCR Result:\n{result}")
            elif command.lower().startswith("symbol "):
                # Parse symbol command
                parts = command.split()
                if len(parts) < 2:
                    print("Usage: symbol status|verify [args]")
                    continue
                
                sub_command = parts[1].lower()
                
                if sub_command == "status":
                    # Show symbol system status
                    status = connector.get_symbol_system_status()
                    if status.get("available", False):
                        print("\nSYMBOL SYSTEM STATUS")
                        for key, value in status.items():
                            print(f"- {key}: {value}")
                    else:
                        print("Symbol system is not available")
                        
                elif sub_command == "verify":
                    # Verify command with symbols
                    if len(parts) < 4:
                        print("Usage: symbol verify SYMBOL_IDS COMMAND")
                        continue
                        
                    symbol_ids = parts[2].split(',')
                    verify_command = ' '.join(parts[3:])
                    
                    result = connector.verify_command_symbols(verify_command, symbol_ids)
                    print(f"Verification result: {result}")
                    
                else:
                    print(f"Unknown symbol sub-command: {sub_command}")
            else:
                # Execute as normal command
                success = connector._execute_command(command)
                print(f"Command executed: {'Success' if success else 'Failure'}")
                
            # Sleep a bit to let threads work
            time.sleep(0.1)
            
    except KeyboardInterrupt:
        print("\nExiting...")
    finally:
        # Stop connector
        connector.stop()

if __name__ == "__main__":
    main()