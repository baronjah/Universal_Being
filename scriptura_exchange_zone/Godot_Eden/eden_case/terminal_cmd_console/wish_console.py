#!/usr/bin/env python3
# Wish Console - Command & API processing system
# Integrates with memory systems using # organization
# Max 369 lines with ASCII visualization

import os
import sys
import time
import json
import random
import threading
import requests
from datetime import datetime
from typing import Dict, List, Any, Optional, Tuple, Set

# ------[ COLOR SUPPORT ]------
class Colors:
    """Terminal color support"""
    RESET = "\033[0m"
    
    # Text colors
    BLACK = "\033[30m"
    RED = "\033[31m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    BLUE = "\033[34m"
    MAGENTA = "\033[35m"
    CYAN = "\033[36m"
    WHITE = "\033[37m"
    
    # Bright text colors
    BRIGHT_BLACK = "\033[90m"
    BRIGHT_RED = "\033[91m"
    BRIGHT_GREEN = "\033[92m"
    BRIGHT_YELLOW = "\033[93m"
    BRIGHT_BLUE = "\033[94m"
    BRIGHT_MAGENTA = "\033[95m"
    BRIGHT_CYAN = "\033[96m"
    BRIGHT_WHITE = "\033[97m"
    
    # Background colors
    BG_BLACK = "\033[40m"
    BG_RED = "\033[41m"
    BG_GREEN = "\033[42m"
    BG_YELLOW = "\033[43m"
    BG_BLUE = "\033[44m"
    BG_MAGENTA = "\033[45m"
    BG_CYAN = "\033[46m"
    BG_WHITE = "\033[47m"
    
    # Text styles
    BOLD = "\033[1m"
    ITALIC = "\033[3m"
    UNDERLINE = "\033[4m"
    BLINK = "\033[5m"  # Not supported in all terminals
    REVERSE = "\033[7m"
    
    # Map dimension to color
    DIMENSION_COLORS = {
        1: BLUE,
        2: GREEN,
        3: YELLOW,
        4: RED,
        5: MAGENTA,
        6: CYAN,
        7: BRIGHT_BLUE,
        8: BRIGHT_GREEN,
        9: BRIGHT_YELLOW,
        10: BRIGHT_RED,
        11: BRIGHT_MAGENTA,
        12: BRIGHT_CYAN
    }
    
    # Map tag types to colors
    TAG_COLORS = {
        "#": GREEN,
        "##": BRIGHT_GREEN,
        "#>": BLUE,
        "#-": CYAN,
        "#^": MAGENTA,
        "#~": YELLOW,
        "#*": BRIGHT_YELLOW,
        "#!": RED,
        "#?": BRIGHT_CYAN,
        "#=": WHITE,
        "#t": BRIGHT_BLUE,
        "#0": BRIGHT_RED,
        "#p": BRIGHT_GREEN,
        "#d": BRIGHT_MAGENTA,
        "#g": BRIGHT_GREEN,
        "#o": BRIGHT_CYAN,
        "#2d": BRIGHT_YELLOW,
        "#3d": BRIGHT_BLUE,
        "#s": BRIGHT_WHITE,
        "#c": BRIGHT_CYAN,
        "#$": BRIGHT_GREEN,
        "#adv": BRIGHT_YELLOW,
        "####": RED + BLINK,    # Glitch trigger
        "#r": MAGENTA + BOLD    # Reign tag
    }
    
    # Map drive letters to colors
    DRIVE_COLORS = {
        "C": BLUE,
        "D": GREEN,
        "M": MAGENTA,
        "G": BRIGHT_GREEN,
        "T": BRIGHT_YELLOW,
        "L": BRIGHT_BLUE,
        "A": BRIGHT_CYAN,
        "E": BRIGHT_RED,
        "V": BRIGHT_MAGENTA
    }
    
    @classmethod
    def colorize(cls, text: str, color: str) -> str:
        """Add color to text with automatic reset"""
        return f"{color}{text}{cls.RESET}"
    
    @classmethod
    def colorize_tag(cls, tag: str) -> str:
        """Colorize a tag based on its type"""
        for prefix, color in cls.TAG_COLORS.items():
            if tag.startswith(prefix):
                return cls.colorize(tag, color)
        return tag
    
    @classmethod
    def colorize_dimension(cls, dim: int) -> str:
        """Colorize text based on dimension number"""
        dim_text = f"D{dim}"
        color = cls.DIMENSION_COLORS.get(dim, cls.WHITE)
        return cls.colorize(dim_text, color)
    
    @classmethod
    def colorize_drive(cls, drive: str) -> str:
        """Colorize text based on drive letter"""
        color = cls.DRIVE_COLORS.get(drive, cls.WHITE)
        return cls.colorize(drive, color)
    
    @classmethod
    def rainbow(cls, text: str) -> str:
        """Apply rainbow effect to text"""
        colors = [cls.RED, cls.YELLOW, cls.GREEN, cls.CYAN, cls.BLUE, cls.MAGENTA]
        result = ""
        for i, char in enumerate(text):
            color = colors[i % len(colors)]
            result += cls.colorize(char, color)
        return result

# ------[ ANIMATED CURSOR ]------
class AnimatedCursor:
    """Provides animated cursor effects"""
    
    # Cursor animation frames
    SPINNERS = {
        "classic": ["-", "\\", "|", "/"],
        "dots": ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"],
        "pulse": ["█", "▓", "▒", "░", "▒", "▓"],
        "bounce": ["⠁", "⠂", "⠄", "⠠", "⠐", "⠈"],
        "bar": ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█", "▇", "▆", "▅", "▄", "▃", "▂"],
        "wave": ["☱", "☲", "☴", "☰"]
    }
    
    def __init__(self, style: str = "classic"):
        self.frames = self.SPINNERS.get(style, self.SPINNERS["classic"])
        self.frame_index = 0
        self.active = False
        
    def next_frame(self) -> str:
        """Get the next frame in the animation"""
        if not self.active:
            return ""
            
        frame = self.frames[self.frame_index]
        self.frame_index = (self.frame_index + 1) % len(self.frames)
        return frame
        
    def start(self) -> None:
        """Start the animation"""
        self.active = True
        self.frame_index = 0
        
    def stop(self) -> None:
        """Stop the animation"""
        self.active = False

# ------[ GAME FEEL SYSTEM ]------
class GameFeel:
    """Enhances the console experience with game feel elements"""
    
    # Different feel presets
    FEEL_TYPES = {
        "smooth": {
            "cursor": "bar",
            "animation_speed": 0.08,
            "colors": True,
            "feedback_intensity": 0.5,
            "sound_enabled": False,
            "transitions": True
        },
        "digital": {
            "cursor": "classic",
            "animation_speed": 0.2,
            "colors": True,
            "feedback_intensity": 0.8,
            "sound_enabled": False,
            "transitions": False
        },
        "glitch": {
            "cursor": "pulse",
            "animation_speed": 0.05,
            "colors": True,
            "feedback_intensity": 1.0,
            "sound_enabled": False,
            "transitions": True,
            "glitch_frequency": 0.2
        },
        "minimal": {
            "cursor": None,
            "animation_speed": 0,
            "colors": False,
            "feedback_intensity": 0.1,
            "sound_enabled": False,
            "transitions": False
        },
        "maximal": {
            "cursor": "dots",
            "animation_speed": 0.05,
            "colors": True,
            "feedback_intensity": 1.0,
            "sound_enabled": True,
            "transitions": True
        }
    }
    
    def __init__(self, feel_type: str = "digital"):
        self.type = feel_type if feel_type in self.FEEL_TYPES else "digital"
        self.settings = self.FEEL_TYPES[self.type].copy()
        self.last_update = time.time()
        self.transition_active = False
        self.feedback_queue = []
        
    def apply_to_config(self, config: dict) -> dict:
        """Apply game feel settings to the configuration"""
        config["cursor_style"] = self.settings["cursor"]
        config["cursor_active"] = self.settings["cursor"] is not None
        config["color_mode"] = self.settings["colors"]
        return config
        
    def get_feedback(self, action_type: str) -> str:
        """Get feedback text for an action"""
        if self.settings["feedback_intensity"] <= 0:
            return ""
            
        feedbacks = {
            "save": [
                "Saved.", 
                "State persisted.",
                "Memory written.",
                "Data stored.",
                "Changes committed."
            ],
            "load": [
                "Loaded.",
                "State retrieved.",
                "Memory recalled.",
                "Data accessed.",
                "System restored."
            ],
            "create": [
                "Created.",
                "New instance formed.",
                "Data materialized.",
                "Item generated.",
                "Entry registered."
            ],
            "delete": [
                "Deleted.",
                "Instance removed.",
                "Data erased.",
                "Item eliminated.",
                "Entry purged."
            ],
            "error": [
                "Error encountered.",
                "Operation failed.",
                "Process interrupted.",
                "Execution halted.",
                "System exception."
            ]
        }
        
        if action_type not in feedbacks:
            return ""
            
        options = feedbacks[action_type]
        feedback = random.choice(options)
        
        # Apply glitch if enabled and random chance hits
        if self.type == "glitch" and random.random() < self.settings["glitch_frequency"]:
            feedback = self._apply_glitch_to_text(feedback)
            
        return feedback
        
    def _apply_glitch_to_text(self, text: str) -> str:
        """Apply glitch effect to text"""
        glitch_chars = "█▓▒░▄■◆●"
        result = list(text)
        
        # Randomly replace characters
        for _ in range(min(len(text) // 3, 5)):
            if result:
                pos = random.randint(0, len(result) - 1)
                result[pos] = random.choice(glitch_chars)
        
        return "".join(result)
        
    def get_transition(self, from_state: str, to_state: str) -> List[str]:
        """Get transition animation frames between states"""
        if not self.settings["transitions"]:
            return []
            
        # Simple transition effect
        frames = []
        if from_state == "command" and to_state == "result":
            frames = [
                "►       ",
                " ►      ",
                "  ►     ",
                "   ►    ",
                "    ►   ",
                "     ►  ",
                "      ► ",
                "       ►"
            ]
        elif from_state == "normal" and to_state == "glitch":
            frames = [
                "Normal   ",
                "Norma█   ",
                "Norm▒█   ",
                "Nor▓▒█   ",
                "No▓█▒█   ",
                "N▓█▓▒█   ",
                "▓█▓█▒█   ",
                "G█▓█▒█   ",
                "Gl█▓█▒   ",
                "Gli█▓█   ",
                "Glit█▓   ",
                "Glitc█   ",
                "Glitch   "
            ]
            
        return frames

# ------[ REASON SYSTEM ]------
class ReasonEngine:
    """Tracks and manages reasons for actions and states"""
    
    def __init__(self):
        self.reasons = {}  # id -> reason mapping
        self.meta_reasons = {}  # reason category -> explanation
        self.context_stack = []  # Stack of current context reasons
        
    def add_reason(self, entity_id: str, reason: str) -> None:
        """Add a reason for an entity's existence or state"""
        self.reasons[entity_id] = reason
        
    def add_meta_reason(self, category: str, explanation: str) -> None:
        """Add a meta-reason explaining a category of reasons"""
        self.meta_reasons[category] = explanation
        
    def push_context(self, reason: str) -> None:
        """Push a reason onto the context stack"""
        self.context_stack.append({
            "reason": reason,
            "timestamp": datetime.now().isoformat(),
            "depth": len(self.context_stack)
        })
        
    def pop_context(self) -> Optional[Dict[str, Any]]:
        """Pop a reason from the context stack"""
        if self.context_stack:
            return self.context_stack.pop()
        return None
        
    def get_current_reason(self) -> Optional[str]:
        """Get the current context reason"""
        if self.context_stack:
            return self.context_stack[-1]["reason"]
        return None
        
    def get_reason_for(self, entity_id: str) -> Optional[str]:
        """Get the reason for an entity"""
        return self.reasons.get(entity_id)
        
    def get_reason_chain(self) -> List[str]:
        """Get the full chain of reasons in the current context"""
        return [ctx["reason"] for ctx in self.context_stack]
        
    def get_categories(self) -> List[str]:
        """Get all reason categories"""
        return list(self.meta_reasons.keys())
        
    def explain_category(self, category: str) -> Optional[str]:
        """Get explanation for a reason category"""
        return self.meta_reasons.get(category)

# ------[ CONFIGURATION ]------
CONFIG = {
    "max_wishes": 369,
    "check_interval": 60,  # Check APIs every 60 seconds
    "offline_mode": False,
    "debug_mode": True,
    "api_keys": {},        # Will load from api_keys.json
    "dimension": 1,        # Current dimension (1-12)
    "device": 0,           # Current device (0-3)
    "auto_save": True,
    "memory_format": "#",  # Use # for memory organization
    "ascii_mode": True,    # Show ASCII visualization
    "max_memory": 100,     # Maximum memories to store
    "color_mode": True,    # Enable color output
    "cursor_style": "dots", # Animated cursor style
    "cursor_active": True,  # Whether cursor animation is active
    "game_feel": "digital", # Game feel preset
    "reason_tracking": True # Whether to track reasons
}

# ------[ DATA STRUCTURES ]------
class Wish:
    # Emoji symbols for wish categories
    EMOJI_MAP = {
        "creation": "✨",
        "knowledge": "🧠",
        "connection": "🔄",
        "growth": "🌱",
        "harmony": "☯️",
        "power": "⚡",
        "transformation": "🦋",
        "balance": "⚖️",
        "unity": "🔗",
        "transcendence": "🌌",
        "default": "🔮"
    }
    
    def __init__(self, text: str, dimension: int = 1, tags: List[str] = None, 
                category: str = "default", emoji: str = None, pinpoint_date: str = None,
                details: str = ""):
        self.id = f"wish_{int(time.time())}_{random.randint(1000, 9999)}"
        self.text = text
        self.dimension = dimension
        self.tags = tags or []
        self.category = category.lower()
        self.emoji = emoji or self.EMOJI_MAP.get(self.category, self.EMOJI_MAP["default"])
        self.created_at = datetime.now()
        self.fulfilled = False
        self.fulfilled_at = None
        self.memories_used = []
        self.pinpoint_date = pinpoint_date or self.created_at.strftime("%Y-%m-%d")
        self.details = details
        self.power_level = 1  # Base power level
        self.interactions = 0  # Number of times this wish has been interacted with
    
    def add_details(self, details: str) -> None:
        """Add additional details to the wish"""
        if self.details:
            self.details += f"\n{details}"
        else:
            self.details = details
        self.interactions += 1
        
    def increase_power(self, amount: int = 1) -> None:
        """Increase the power level of the wish"""
        self.power_level += amount
        self.interactions += 1
    
    def get_display_text(self, detailed: bool = False) -> str:
        """Get formatted display text for the wish"""
        status = "✓" if self.fulfilled else "○"
        base_text = f"{self.emoji} {status} [{self.pinpoint_date}] {self.text}"
        
        if detailed:
            date_str = self.created_at.strftime("%Y-%m-%d %H:%M")
            power_stars = "★" * min(self.power_level, 5)
            details = f"\n   Details: {self.details}" if self.details else ""
            return f"{base_text}\n   Created: {date_str} | Power: {power_stars} | Dim: {self.dimension}{details}"
        return base_text
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            "id": self.id,
            "text": self.text,
            "dimension": self.dimension,
            "tags": self.tags,
            "category": self.category,
            "emoji": self.emoji,
            "created_at": self.created_at.isoformat(),
            "fulfilled": self.fulfilled,
            "fulfilled_at": self.fulfilled_at.isoformat() if self.fulfilled_at else None,
            "memories_used": self.memories_used,
            "pinpoint_date": self.pinpoint_date,
            "details": self.details,
            "power_level": self.power_level,
            "interactions": self.interactions
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'Wish':
        wish = cls(
            data["text"], 
            data["dimension"], 
            data["tags"],
            data.get("category", "default"),
            data.get("emoji", None),
            data.get("pinpoint_date", None),
            data.get("details", "")
        )
        wish.id = data["id"]
        wish.created_at = datetime.fromisoformat(data["created_at"])
        wish.fulfilled = data["fulfilled"]
        wish.fulfilled_at = datetime.fromisoformat(data["fulfilled_at"]) if data["fulfilled_at"] else None
        wish.memories_used = data["memories_used"]
        wish.power_level = data.get("power_level", 1)
        wish.interactions = data.get("interactions", 0)
        return wish

class ShapeOverlay:
    """2D Shape overlay for terminal visualization"""
    # Basic keyboard-mapped shapes
    SHAPES = {
        "square": "■",
        "circle": "●", 
        "triangle": "▲",
        "diamond": "◆",
        "star": "★",
        "cross": "✚",
        "plus": "+",
        "heart": "♥",
        "spade": "♠",
        "club": "♣",
        "wave": "≈",
        "infinity": "∞"
    }
    
    # Keyboard mapping to shapes
    KEY_MAP = {
        "q": "triangle", "w": "triangle", "e": "triangle", "r": "diamond", "t": "star", "y": "star",
        "u": "diamond", "i": "circle", "o": "circle", "p": "square",
        "a": "square", "s": "diamond", "d": "circle", "f": "cross", "g": "plus", "h": "plus",
        "j": "cross", "k": "diamond", "l": "square",
        "z": "wave", "x": "infinity", "c": "heart", "v": "spade", "b": "club", "n": "spade",
        "m": "heart", ",": "wave", ".": "infinity"
    }
    
    def __init__(self, width: int = 10, height: int = 5):
        self.width = width
        self.height = height
        self.grid = [[" " for _ in range(width)] for _ in range(height)]
        self.truth_values = {}  # Store truth values for cells
        
    def set_cell(self, x: int, y: int, shape: str = "square", truth_value: float = 1.0):
        """Set a cell in the grid with a shape and truth value"""
        if 0 <= x < self.width and 0 <= y < self.height:
            shape_symbol = self.SHAPES.get(shape, "■")
            self.grid[y][x] = shape_symbol
            self.truth_values[(x, y)] = truth_value
            
    def set_from_key(self, x: int, y: int, key: str, truth_value: float = 1.0):
        """Set a cell based on keyboard key"""
        if 0 <= x < self.width and 0 <= y < self.height:
            shape = self.KEY_MAP.get(key.lower(), "square")
            self.set_cell(x, y, shape, truth_value)
            
    def clear(self):
        """Clear the grid"""
        self.grid = [[" " for _ in range(self.width)] for _ in range(self.height)]
        self.truth_values = {}
        
    def get_overlay(self) -> str:
        """Get string representation of the overlay"""
        result = []
        
        # Add top border
        result.append("+" + "-" * (self.width * 2 + 1) + "+")
        
        # Add grid rows with truth values
        for y in range(self.height):
            line = "| "
            for x in range(self.width):
                line += self.grid[y][x] + " "
            line += "|"
            result.append(line)
            
            # Add truth value line
            truth_line = "| "
            for x in range(self.width):
                truth_value = self.truth_values.get((x, y), 0.0)
                # Use character to represent truth value (0-9)
                truth_char = str(min(9, int(truth_value * 10)))
                truth_line += truth_char + " "
            truth_line += "|"
            result.append(truth_line)
        
        # Add bottom border
        result.append("+" + "-" * (self.width * 2 + 1) + "+")
        
        return "\n".join(result)
        
    def fill_from_memory(self, memory: 'Memory') -> None:
        """Fill the grid with shapes based on memory content"""
        content = memory.content.lower()
        
        # Clear the grid first
        self.clear()
        
        # Map each character to a position and shape
        for i, char in enumerate(content[:min(len(content), self.width * self.height)]):
            x = i % self.width
            y = i // self.width
            
            if char.isalpha():
                self.set_from_key(x, y, char)
            elif char.isdigit():
                # Use digit as truth value (0-9)
                truth_value = int(char) / 10.0
                self.set_cell(x, y, "square", truth_value)
            elif char in ".,;:!?-_+*/=()[]{}":
                # Use symbols for special shapes
                symbol_map = {
                    ".": "circle", ",": "diamond", ";": "triangle", 
                    ":": "square", "!": "star", "?": "cross",
                    "-": "wave", "_": "infinity", "+": "plus",
                    "*": "star", "/": "diamond", "=": "square"
                }
                shape = symbol_map.get(char, "square")
                self.set_cell(x, y, shape, 0.8)

class Memory:
    # Memory tag prefixes and their meanings
    TAG_TYPES = {
        "#":   "Standard tag - Basic memory marker",
        "##":  "Core tag - Important system memory",
        "#>":  "Flow tag - Directional memory flow",
        "#-":  "Thread tag - Connects across dimensions",
        "#^":  "Ascend tag - Elevates to higher dimension",
        "#~":  "Wave tag - Fluctuating or unstable memory",
        "#*":  "Star tag - Highly significant memory",
        "#!":  "Alert tag - Critical or warning memory",
        "#?":  "Query tag - Question or exploration memory",
        "#=":  "Equal tag - Balanced or stabilized memory",
        "#t":  "Time tag - Temporal/time-related memory",
        "#0":  "Core 0 - Multithreading root memory",
        "#p":  "Project tag - Project-specific memory",
        "#d":  "Drive tag - Cross-drive memory storage",
        "#g":  "Godot tag - For Godot-related memories",
        "#o":  "Overlay tag - Desktop overlay related",
        "#2d": "2D tag - 2D application memory",
        "#3d": "3D tag - 3D world/application memory",
        "#s":  "Shape tag - 2D shape visualization",
        "#c":  "Continuity tag - Self-replicating memory",
        "#$":  "Stronghold tag - Data stronghold memory",
        "#adv": "Advanced tag - Advanced word processing",
        "####": "Glitch tag - Triggers data manipulation glitches",
        "#r":   "Reign tag - Word reign control system"
    }
    
    # ASCII representations for different tag types
    ASCII_SYMBOLS = {
        "#":   "■",
        "##":  "█",
        "#>":  "►",
        "#-":  "─",
        "#^":  "▲",
        "#~":  "≈",
        "#*":  "★",
        "#!":  "!",
        "#?":  "?",
        "#=":  "=",
        "#t":  "τ",
        "#0":  "0",
        "#p":  "P",
        "#d":  "D",
        "#g":  "G",
        "#o":  "O",
        "#2d": "2",
        "#3d": "3"
    }
    
    # Storage pools (9 total)
    STORAGE_POOLS = {
        1: "Primary",
        2: "Secondary", 
        3: "Tertiary",
        4: "Quaternary",
        5: "Quinary",
        6: "Senary", 
        7: "Septenary",
        8: "Octonary",
        9: "Nonary"
    }
    
    # Drive systems for cross-device memory storage
    DRIVE_SYSTEMS = {
        "C": "Windows System Drive",
        "D": "Data Drive",
        "M": "Memory Drive", 
        "G": "Godot Storage",
        "T": "Temple OS Connection",
        "L": "Luminus OS Connection",
        "A": "AI Drive",
        "E": "External Storage",
        "V": "Virtual Memory System"
    }
    
    def __init__(self, content: str, dimension: int = 1, device: int = 0, 
                 tags: List[str] = None, storage_pool: int = 1, drive: str = "C"):
        self.id = f"mem_{int(time.time())}_{random.randint(1000, 9999)}"
        self.content = content
        self.dimension = dimension
        self.device = device
        self.tags = tags or []
        self.created_at = datetime.now()
        self.connections = []
        self.storage_pool = min(max(storage_pool, 1), 9)  # Ensure between 1-9
        self.thread_id = random.randint(0, 15)  # Assign a thread ID (0-15)
        self.spread_lines = []  # For storing additional lines when using spread tags
        self.drive = drive if drive in self.DRIVE_SYSTEMS else "C"  # Default to C drive if invalid
        self.animation_frames = []  # For storing animation frames
        self.token_size = len(content) // 4  # Approximate token size (1 token ≈ 4 chars)
        self.is_project = False  # Whether this is a project memory
        self.project_id = None  # Project ID if part of a project
        self.akashic_depth = 0  # Depth in the akashic records (0-9)
        self.ctrl_shifts = []  # For storing control shift operations
        self.shape_overlay = None  # 2D shape overlay for visualization
        self.truth_value = 1.0  # Truth value for this memory (0.0-1.0)
        self.continuity = False  # Whether this memory has continuity (self-replicating)
        self.replication_count = 0  # Number of times this memory has replicated
        self.stronghold = False  # Whether this memory is a data stronghold
        self.stronghold_level = 0  # Level of the data stronghold (0-5)
        self.word_advancement = 0  # Level of word advancement (0-10)
        
        # Handle shape overlay for #s tagged memories
        if any(tag.startswith("#s") for tag in self.tags):
            # Create a shape overlay based on content
            self.shape_overlay = ShapeOverlay(10, 5)  # Default 10x5 grid
            self.shape_overlay.fill_from_memory(self)
            
            # Extract truth value if specified in tag
            for tag in self.tags:
                if tag.startswith("#s:") and len(tag) > 3:
                    try:
                        self.truth_value = float(tag[3:]) 
                        self.truth_value = max(0.0, min(1.0, self.truth_value))  # Clamp between 0-1
                    except ValueError:
                        pass
        
        # Extract any spread lines from content if it contains multiple lines
        if "\n" in content and any(tag.startswith("#") for tag in self.tags):
            lines = content.split("\n")
            self.content = lines[0]  # First line is main content
            
            # Store up to 15 additional lines (as mentioned in the request)
            self.spread_lines = lines[1:min(len(lines), 16)]
            
            # Check for animation frames (lines starting with "frame:")
            animation_lines = [line[6:].strip() for line in self.spread_lines if line.startswith("frame:")]
            if animation_lines:
                self.animation_frames = animation_lines
        
        # Handle project memories (#p tag)
        if any(tag.startswith("#p") for tag in self.tags):
            self.is_project = True
            # Generate a project ID based on the content
            self.project_id = f"proj_{abs(hash(content)) % 10000}"
            
        # Handle drive-specific memories (#d tag)
        for tag in self.tags:
            if tag.startswith("#d:") and len(tag) > 3:
                drive_letter = tag[3:4].upper()
                if drive_letter in self.DRIVE_SYSTEMS:
                    self.drive = drive_letter
                    
        # Set akashic depth for memories with akashic references
        if "akashic" in content.lower() or any(tag == "#*" for tag in self.tags):
            # Calculate depth based on content complexity and dimension
            content_complexity = min(len(set(content.lower())), 9)  # Unique chars, max 9
            self.akashic_depth = min((content_complexity + dimension) // 2, 9)
    
    def get_ascii_symbol(self) -> str:
        """Get the ASCII representation for this memory's tag"""
        if not self.tags:
            return "•"
            
        # Find the first tag that has an ASCII symbol
        for tag in self.tags:
            for prefix, symbol in self.ASCII_SYMBOLS.items():
                if tag.startswith(prefix):
                    return symbol
        
        return "•"  # Default if no matching tag
    
    def get_tag_type(self) -> str:
        """Get the type description for this memory's primary tag"""
        if not self.tags:
            return ""
            
        # Find the first tag that has a type description
        for tag in self.tags:
            for prefix, description in self.TAG_TYPES.items():
                if tag.startswith(prefix):
                    return description
        
        return ""
    
    def is_multithreaded(self) -> bool:
        """Check if this memory is multithreaded (#0 tag)"""
        return any(tag.startswith("#0") for tag in self.tags)
    
    def get_memory_detail(self, include_animation: bool = False) -> str:
        """Get detailed string representation of the memory"""
        tag_str = " ".join(self.tags) if self.tags else ""
        pool_name = self.STORAGE_POOLS.get(self.storage_pool, "Unknown")
        thread_info = f"T{self.thread_id}" if self.is_multithreaded() else ""
        drive_info = f"[{self.drive}:{self.DRIVE_SYSTEMS.get(self.drive, 'Unknown')}]"
        token_info = f"Tokens:{self.token_size}"
        
        # Build header with all relevant information
        header_parts = [
            self.id,
            f"D{self.dimension}:{self.device}",
            f"[{pool_name}]",
            drive_info,
            token_info
        ]
        
        if thread_info:
            header_parts.append(thread_info)
            
        if self.is_project:
            header_parts.append(f"Project:{self.project_id}")
            
        if self.akashic_depth > 0:
            header_parts.append(f"Akashic:{self.akashic_depth}")
        
        # Add tags at the end
        if tag_str:
            header_parts.append(tag_str)
            
        # Construct the detail string
        header = " ".join(header_parts)
        detail = f"{header}\n{self.content}"
        
        # Add spread lines if they exist
        if self.spread_lines:
            for i, line in enumerate(self.spread_lines):
                detail += f"\n  #{i+1}: {line}"
        
        # Add animation frames if requested and they exist
        if include_animation and self.animation_frames:
            detail += "\n\n--- ANIMATION FRAMES ---"
            for i, frame in enumerate(self.animation_frames):
                detail += f"\n  Frame {i+1}:\n{frame}"
                
        # Add project information if this is a project memory
        if self.is_project:
            detail += f"\n\n--- PROJECT: {self.project_id} ---"
            detail += f"\n  Path: {self.drive}:/{self.project_id}"
            
        return detail
        
    def generate_animation_frame(self, frame_index: int = 0) -> str:
        """Generate an ASCII animation frame"""
        if not self.animation_frames:
            # Create a default animation if none exists
            content_chars = list(self.content.replace(" ", "."))
            height = 5
            width = min(len(content_chars), 30)
            
            # Create a simple falling animation
            frame = []
            
            # Calculate offset based on frame index (cycle through 0-4)
            offset = frame_index % 5
            
            for y in range(height):
                line = ""
                for x in range(width):
                    # Determine if this position should have a character
                    if (y + offset) % height == x % 5:
                        char_index = (x + y + offset) % len(content_chars)
                        line += content_chars[char_index]
                    else:
                        line += " "
                frame.append(line)
                
            return "\n".join(frame)
        else:
            # Return the specified animation frame, cycling if needed
            frame_index = frame_index % len(self.animation_frames)
            return self.animation_frames[frame_index]
            
    def add_ctrl_shift(self, shift_type: str) -> None:
        """Add a control shift operation to modify memory behavior"""
        self.ctrl_shifts.append({
            "type": shift_type,
            "timestamp": datetime.now().isoformat(),
            "dimension": self.dimension
        })
        
        # Apply the shift effect
        if shift_type == "ascend":
            # Move to a higher dimension
            self.dimension = min(self.dimension + 1, 12)
        elif shift_type == "descend":
            # Move to a lower dimension
            self.dimension = max(self.dimension - 1, 1)
        elif shift_type == "pool_shift":
            # Change storage pool
            self.storage_pool = (self.storage_pool % 9) + 1
        elif shift_type == "drive_shift":
            # Cycle through drives
            drives = list(self.DRIVE_SYSTEMS.keys())
            current_index = drives.index(self.drive) if self.drive in drives else 0
            self.drive = drives[(current_index + 1) % len(drives)]
        elif shift_type == "word_advance":
            # Advance the word level
            self.word_advancement = min(self.word_advancement + 1, 10)
            
    def enable_continuity(self) -> None:
        """Enable continuity (self-replication) for this memory"""
        self.continuity = True
        
    def replicate_to_drive(self, target_drive: str) -> Optional['Memory']:
        """Replicate this memory to another drive"""
        if not self.continuity:
            return None
            
        # Create a copy with the same content but on a different drive
        replica = Memory(
            self.content,
            self.dimension,
            self.device,
            self.tags.copy(),
            self.storage_pool,
            target_drive
        )
        
        # Copy key properties
        replica.spread_lines = self.spread_lines.copy()
        replica.animation_frames = self.animation_frames.copy()
        replica.token_size = self.token_size
        replica.is_project = self.is_project
        replica.project_id = self.project_id
        replica.akashic_depth = self.akashic_depth
        replica.truth_value = self.truth_value
        
        # Set continuity but increment replication count
        replica.continuity = True
        replica.replication_count = self.replication_count + 1
        
        # Update this memory's replication count
        self.replication_count += 1
        
        # Add a special tag to show it's a replica
        if not any(tag.startswith("#c") for tag in replica.tags):
            replica.tags.append(f"#c:{self.replication_count}")
        
        return replica
    
    def create_stronghold(self, level: int = 1) -> None:
        """Convert this memory into a data stronghold"""
        self.stronghold = True
        self.stronghold_level = min(max(level, 1), 5)  # Level 1-5
        
        # Strongholds always have continuity
        self.continuity = True
        
        # Add stronghold tag if not present
        if not any(tag.startswith("#$") for tag in self.tags):
            self.tags.append(f"#$:{self.stronghold_level}")
            
    def advance_word(self, level: int = 1) -> None:
        """Advance the word level for this memory"""
        self.word_advancement = min(self.word_advancement + level, 10)
        
        # Add word advancement tag if not present
        if not any(tag.startswith("#adv") for tag in self.tags):
            self.tags.append(f"#adv:{self.word_advancement}")
            
        # Word advancement adds small truth boost
        self.truth_value = min(self.truth_value + (level * 0.05), 1.0)
        
    def add_glitch_trigger(self, intensity: int = 3) -> str:
        """Add a glitch trigger to this memory for data manipulation"""
        # Glitch tags are represented as #### with a number of intensity
        intensity = min(max(intensity, 1), 9)  # Clamp between 1-9
        glitch_tag = "####" + "3" * intensity
        
        # Add glitch tag
        self.tags.append(glitch_tag)
        
        # Generate glitched content
        glitched_content = self._generate_glitched_text(self.content, intensity)
        
        # Store original content in spread lines if not already there
        if not self.spread_lines:
            self.spread_lines.append("ORIGINAL: " + self.content)
            
        # Add glitched version
        self.spread_lines.append("GLITCH: " + glitched_content)
        
        return glitched_content
    
    def _generate_glitched_text(self, text: str, intensity: int) -> str:
        """Generate glitched version of text"""
        import random
        
        # Characters to randomly insert
        glitch_chars = "█▓▒░█▓▒░▄■▲▼◆●◉☒☐░▒▓█░▒▓█"
        
        # Copy original
        glitched = list(text)
        
        # Apply different glitch effects based on intensity
        for _ in range(intensity * 3):
            effect = random.randint(0, 5)
            
            if effect == 0 and glitched:  # Replace random character
                pos = random.randint(0, len(glitched) - 1)
                glitched[pos] = random.choice(glitch_chars)
                
            elif effect == 1 and len(glitched) > 5:  # Swap characters
                pos1 = random.randint(0, len(glitched) - 2)
                pos2 = random.randint(0, len(glitched) - 2)
                glitched[pos1], glitched[pos2] = glitched[pos2], glitched[pos1]
                
            elif effect == 2:  # Insert glitch character
                pos = random.randint(0, len(glitched))
                glitched.insert(pos, random.choice(glitch_chars))
                
            elif effect == 3 and glitched:  # Duplicate character
                pos = random.randint(0, len(glitched) - 1)
                glitched.insert(pos, glitched[pos])
                
            elif effect == 4 and len(glitched) > intensity:  # Remove character
                pos = random.randint(0, len(glitched) - 1)
                glitched.pop(pos)
                
            elif effect == 5 and len(glitched) > 4:  # UPPERCASE section
                start = random.randint(0, len(glitched) - 4)
                length = random.randint(2, min(5, len(glitched) - start))
                for i in range(start, start + length):
                    if i < len(glitched) and glitched[i].isalpha():
                        glitched[i] = glitched[i].upper()
        
        return "".join(glitched)
    
    def establish_word_reign(self, target_memories: List['Memory'] = None) -> None:
        """Establish word reign control over other memories"""
        # Add reign tag if not present
        if not any(tag.startswith("#r") for tag in self.tags):
            self.tags.append("#r:master")
        
        # If no target memories provided, no connections to make
        if not target_memories:
            return
            
        # Connect to target memories with reign control
        for target in target_memories:
            # Skip if target is already under reign control
            if any(tag.startswith("#r:controlled") for tag in target.tags):
                continue
                
            # Add controlled tag to target
            target.tags.append(f"#r:controlled:{self.id}")
            
            # Add connection in both directions
            if target.id not in self.connections:
                self.connections.append(target.id)
            if self.id not in target.connections:
                target.connections.append(self.id)
            
            # If target has word advancements, boost this memory
            if target.word_advancement > 0:
                self.word_advancement += max(1, target.word_advancement // 2)
                
            # Apply a small amount of content from this memory to the target
            if len(self.content) > 10 and len(target.content) > 10:
                # Insert a fragment of this memory's content into the target
                insert_pos = random.randint(0, len(target.content) - 5)
                fragment_start = random.randint(0, len(self.content) - 5)
                fragment_length = min(5, len(self.content) - fragment_start)
                fragment = self.content[fragment_start:fragment_start + fragment_length]
                
                # Modify target content
                target_chars = list(target.content)
                for i, char in enumerate(fragment):
                    if insert_pos + i < len(target_chars):
                        target_chars[insert_pos + i] = char
                
                # Add original content to spread lines if not already there
                if not target.spread_lines:
                    target.spread_lines.append("ORIGINAL: " + target.content)
                
                # Update target content
                target.content = "".join(target_chars)
    
    def to_dict(self) -> Dict[str, Any]:
        # Handle shape overlay for saving
        has_shape_overlay = self.shape_overlay is not None
        shape_data = None
        if has_shape_overlay:
            # Save minimal representation of the shape overlay
            shape_data = {
                "width": self.shape_overlay.width,
                "height": self.shape_overlay.height,
                "grid": [row[:] for row in self.shape_overlay.grid],  # Copy grid
                "truth_values": {str(k): v for k, v in self.shape_overlay.truth_values.items()}  # Convert tuple keys to strings
            }
        
        return {
            "id": self.id,
            "content": self.content,
            "dimension": self.dimension,
            "device": self.device,
            "tags": self.tags,
            "created_at": self.created_at.isoformat(),
            "connections": self.connections,
            "storage_pool": self.storage_pool,
            "thread_id": self.thread_id,
            "spread_lines": self.spread_lines,
            "drive": self.drive,
            "animation_frames": self.animation_frames,
            "token_size": self.token_size,
            "is_project": self.is_project,
            "project_id": self.project_id,
            "akashic_depth": self.akashic_depth,
            "ctrl_shifts": self.ctrl_shifts,
            "has_shape_overlay": has_shape_overlay,
            "shape_data": shape_data,
            "truth_value": self.truth_value
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'Memory':
        memory = cls(
            data["content"], 
            data["dimension"], 
            data["device"], 
            data["tags"],
            data.get("storage_pool", 1),
            data.get("drive", "C")
        )
        memory.id = data["id"]
        memory.created_at = datetime.fromisoformat(data["created_at"])
        memory.connections = data["connections"]
        memory.thread_id = data.get("thread_id", 0)
        memory.spread_lines = data.get("spread_lines", [])
        memory.animation_frames = data.get("animation_frames", [])
        memory.token_size = data.get("token_size", len(data["content"]) // 4)
        memory.is_project = data.get("is_project", False)
        memory.project_id = data.get("project_id", None)
        memory.akashic_depth = data.get("akashic_depth", 0)
        memory.ctrl_shifts = data.get("ctrl_shifts", [])
        memory.truth_value = data.get("truth_value", 1.0)
        
        # Restore shape overlay if present
        if data.get("has_shape_overlay", False) and data.get("shape_data"):
            shape_data = data["shape_data"]
            memory.shape_overlay = ShapeOverlay(shape_data["width"], shape_data["height"])
            memory.shape_overlay.grid = shape_data["grid"]
            
            # Convert string keys back to tuples
            truth_values = {}
            for k_str, v in shape_data["truth_values"].items():
                # Parse the tuple string "(x,y)" back to a tuple
                try:
                    coords = k_str.strip("()").split(",")
                    key = (int(coords[0]), int(coords[1]))
                    truth_values[key] = v
                except:
                    pass  # Skip invalid keys
                    
            memory.shape_overlay.truth_values = truth_values
            
        # Recreate shape overlay for #s tagged memories that don't have saved overlay data
        elif any(tag.startswith("#s") for tag in memory.tags) and not memory.shape_overlay:
            memory.shape_overlay = ShapeOverlay(10, 5)  # Default size
            memory.shape_overlay.fill_from_memory(memory)
            
        return memory

class APIConnection:
    def __init__(self, name: str, url: str, key: str = "", headers: Dict[str, str] = None, 
                 request_format: Dict[str, Any] = None, response_path: str = None):
        self.name = name
        self.url = url
        self.key = key
        self.headers = headers or {}
        self.last_check = None
        self.is_online = False
        self.response_time = 0
        # Custom API settings
        self.request_format = request_format or {}  # Template for structuring API requests
        self.response_path = response_path  # JSON path to extract response (dot notation)
        
    def check_status(self) -> bool:
        try:
            start_time = time.time()
            response = requests.get(self.url, headers=self.headers, timeout=5)
            self.response_time = time.time() - start_time
            self.is_online = response.status_code == 200
            self.last_check = datetime.now()
            return self.is_online
        except:
            self.is_online = False
            self.last_check = datetime.now()
            return False
    
    def send_request(self, endpoint: str, method: str = "GET", 
                    data: Dict[str, Any] = None) -> Optional[Dict[str, Any]]:
        if not self.is_online:
            return None
            
        full_url = f"{self.url.rstrip('/')}/{endpoint.lstrip('/')}"
        
        # Apply custom request format if available
        request_data = data
        if self.request_format and data:
            # Deep copy to avoid modifying the template
            import copy
            formatted_data = copy.deepcopy(self.request_format)
            # Use a recursive function to insert data at specified path
            self._apply_template_data(formatted_data, data)
            request_data = formatted_data
        
        try:
            if method.upper() == "GET":
                response = requests.get(full_url, headers=self.headers, params=request_data, timeout=10)
            elif method.upper() == "POST":
                response = requests.post(full_url, headers=self.headers, json=request_data, timeout=10)
            elif method.upper() == "PUT":
                response = requests.put(full_url, headers=self.headers, json=request_data, timeout=10)
            elif method.upper() == "DELETE":
                response = requests.delete(full_url, headers=self.headers, timeout=10)
            else:
                return None
                
            if 200 <= response.status_code < 300:  # Accept any 2xx status code
                return response.json()
            return None
        except Exception as e:
            if CONFIG["debug_mode"]:
                print(f"# API Error: {str(e)}")
            self.is_online = False
            return None
    
    def _apply_template_data(self, template: Dict[str, Any], data: Dict[str, Any]) -> None:
        """Recursively apply data to template based on special markers"""
        # Look for special placeholder "$input" to replace with the input text
        if isinstance(template, dict):
            for key, value in template.items():
                if value == "$input" and "text" in data:
                    template[key] = data["text"]
                elif isinstance(value, (dict, list)):
                    self._apply_template_data(value, data)
        elif isinstance(template, list):
            for i, item in enumerate(template):
                if item == "$input" and "text" in data:
                    template[i] = data["text"]
                elif isinstance(item, (dict, list)):
                    self._apply_template_data(item, data)
    
    def extract_response(self, response: Dict[str, Any]) -> Optional[str]:
        """Extract relevant text from API response using response_path"""
        if not response or not self.response_path:
            return None
            
        # Navigate nested response using dot notation (e.g., "choices.0.message.content")
        try:
            parts = self.response_path.split(".")
            current = response
            for part in parts:
                # Handle array indices
                if part.isdigit():
                    current = current[int(part)]
                else:
                    current = current[part]
            
            # Convert to string if necessary
            if isinstance(current, str):
                return current
            else:
                return str(current)
        except (KeyError, IndexError, TypeError) as e:
            if CONFIG["debug_mode"]:
                print(f"# Error extracting response: {str(e)}")
            return None
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert API connection to dictionary for saving"""
        return {
            "name": self.name,
            "url": self.url,
            "key": self.key,
            "headers": self.headers,
            "request_format": self.request_format,
            "response_path": self.response_path
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'APIConnection':
        """Create API connection from dictionary"""
        return cls(
            name=data["name"],
            url=data["url"],
            key=data["key"],
            headers=data.get("headers", {}),
            request_format=data.get("request_format"),
            response_path=data.get("response_path")
        )

# ------[ SYSTEM STATE ]------
class WishConsole:
    def __init__(self):
        self.wishes: List[Wish] = []
        self.memories: List[Memory] = []
        self.apis: Dict[str, APIConnection] = {}
        self.dimension_names = {
            1: "REALITY", 2: "LINEAR", 3: "SPATIAL", 4: "TEMPORAL", 
            5: "CONSCIOUS", 6: "CONNECTION", 7: "CREATION", 8: "NETWORK", 
            9: "HARMONY", 10: "UNITY", 11: "TRANSCENDENT", 12: "META"
        }
        self.api_check_thread = None
        self.running = False
        self.command_history = []
        self.shared_lines = []  # Lines shared at the bottom
        self.active_line_index = 0  # Currently active shared line
        self.display_footer = True  # Whether to show footer
        self.enhanced_header = True  # Show enhanced header
        self.daily_wishes: Dict[str, List[str]] = {}  # Organize wishes by date
        self.cursor = AnimatedCursor(CONFIG.get("cursor_style", "dots"))  # Animated cursor
        self.cursor_thread = None  # Thread for cursor animation
        self.last_cursor_update = time.time()  # Track cursor animation timing
        self.load_config()
        self.setup_apis()
        
    def load_config(self):
        try:
            if os.path.exists("wish_console_config.json"):
                with open("wish_console_config.json", "r") as f:
                    loaded_config = json.load(f)
                    CONFIG.update(loaded_config)
        except Exception as e:
            print(f"# ERROR loading config: {e}")
        
        try:
            if os.path.exists("api_keys.json"):
                with open("api_keys.json", "r") as f:
                    CONFIG["api_keys"] = json.load(f)
        except Exception as e:
            print(f"# ERROR loading API keys: {e}")
    
    def setup_apis(self):
        # Default APIs
        self.apis["openai"] = APIConnection(
            "OpenAI", 
            "https://api.openai.com/v1",
            CONFIG["api_keys"].get("openai", ""),
            {"Authorization": f"Bearer {CONFIG['api_keys'].get('openai', '')}"}
        )
        
        self.apis["anthropic"] = APIConnection(
            "Anthropic", 
            "https://api.anthropic.com/v1",
            CONFIG["api_keys"].get("anthropic", ""),
            {"x-api-key": CONFIG["api_keys"].get("anthropic", "")}
        )
        
        # Check all APIs initially
        for api_name, api in self.apis.items():
            api.check_status()
    
    def start_api_check_thread(self):
        def check_apis_periodically():
            while self.running:
                for api_name, api in self.apis.items():
                    api.check_status()
                    if CONFIG["debug_mode"]:
                        status = "ONLINE" if api.is_online else "OFFLINE"
                        print(f"# API {api_name}: {status} ({api.response_time:.2f}s)")
                
                time.sleep(CONFIG["check_interval"])
        
        self.api_check_thread = threading.Thread(target=check_apis_periodically)
        self.api_check_thread.daemon = True
        self.api_check_thread.start()
    
    def stop_api_check_thread(self):
        self.running = False
        if self.api_check_thread:
            self.api_check_thread.join(timeout=1)
    
    def save_state(self):
        # Create API dict representations for saving
        api_dicts = {}
        for name, api in self.apis.items():
            if hasattr(api, 'to_dict'):
                api_dicts[name] = api.to_dict()
        
        state = {
            "wishes": [wish.to_dict() for wish in self.wishes],
            "memories": [memory.to_dict() for memory in self.memories],
            "config": CONFIG,
            "shared_lines": self.shared_lines,
            "active_line_index": self.active_line_index,
            "daily_wishes": self.daily_wishes,
            "apis": api_dicts
        }
        
        try:
            # Create backups before saving
            if os.path.exists("wish_console_state.json"):
                backup_file = f"wish_console_state.bak.{int(time.time())}"
                os.rename("wish_console_state.json", backup_file)
                # Keep only the latest 3 backups
                backups = [f for f in os.listdir(".") if f.startswith("wish_console_state.bak.")]
                if len(backups) > 3:
                    oldest = sorted(backups)[0]
                    os.remove(oldest)
            
            with open("wish_console_state.json", "w") as f:
                json.dump(state, f, indent=2)
                
            if CONFIG["debug_mode"]:
                print("# State saved successfully")
        except Exception as e:
            print(f"# ERROR saving state: {e}")
    
    def load_state(self):
        try:
            if os.path.exists("wish_console_state.json"):
                with open("wish_console_state.json", "r") as f:
                    state = json.load(f)
                    
                self.wishes = [Wish.from_dict(w) for w in state.get("wishes", [])]
                self.memories = [Memory.from_dict(m) for m in state.get("memories", [])]
                CONFIG.update(state.get("config", {}))
                
                # Load shared lines and active index
                self.shared_lines = state.get("shared_lines", [])
                self.active_line_index = state.get("active_line_index", 0)
                
                # Ensure active_line_index is valid
                if self.shared_lines and self.active_line_index >= len(self.shared_lines):
                    self.active_line_index = len(self.shared_lines) - 1
                
                # Load daily wishes
                self.daily_wishes = state.get("daily_wishes", {})
                
                # Load custom APIs
                api_dicts = state.get("apis", {})
                for name, api_dict in api_dicts.items():
                    if name not in self.apis and api_dict.get("url"):
                        self.apis[name] = APIConnection.from_dict(api_dict)
                
                if CONFIG["debug_mode"]:
                    print(f"# Loaded {len(self.wishes)} wishes, {len(self.memories)} memories, {len(self.shared_lines)} shared lines")
        except Exception as e:
            print(f"# ERROR loading state: {e}")
    
    def add_wish(self, text: str, tags: List[str] = None) -> Wish:
        wish = Wish(text, CONFIG["dimension"], tags or [])
        self.wishes.append(wish)
        
        if CONFIG["auto_save"]:
            self.save_state()
            
        return wish
    
    def add_memory(self, content: str, tags: List[str] = None, storage_pool: int = None) -> Memory:
        # Trim memories if exceeding max
        while len(self.memories) >= CONFIG["max_memory"]:
            self.memories.pop(0)  # Remove oldest memory
            
        # Auto-detect storage pool from content if not specified
        if storage_pool is None:
            # If content contains a pool reference like [P3] or [POOL:5]
            if "[P" in content and "]" in content:
                try:
                    pool_start = content.index("[P") + 2
                    pool_end = content.index("]", pool_start)
                    pool_num = int(content[pool_start:pool_end])
                    storage_pool = min(max(pool_num, 1), 9)
                except (ValueError, IndexError):
                    pass
            elif "[POOL:" in content and "]" in content:
                try:
                    pool_start = content.index("[POOL:") + 6
                    pool_end = content.index("]", pool_start)
                    pool_num = int(content[pool_start:pool_end])
                    storage_pool = min(max(pool_num, 1), 9)
                except (ValueError, IndexError):
                    pass
        
        # If still not determined, use default logic
        if storage_pool is None:
            # Use dimension number modulo 3 + 1 (1-3) as default
            storage_pool = (CONFIG["dimension"] - 1) % 3 + 1
            
            # Special handling for tagged memories
            if tags and any(tag.startswith("#") for tag in tags):
                # Find the first tag with a # prefix
                for tag in tags:
                    if tag.startswith("#"):
                        # Calculate storage pool based on tag type
                        if tag.startswith("##"):  # Core tag
                            storage_pool = 1  # Primary storage
                        elif tag.startswith("#>"):  # Flow tag
                            storage_pool = 2  # Secondary storage
                        elif tag.startswith("#-"):  # Thread tag
                            storage_pool = 3  # Tertiary storage
                        elif tag.startswith("#^"):  # Ascend tag
                            storage_pool = min(CONFIG["dimension"], 9)  # Pool based on dimension
                        elif tag.startswith("#~"):  # Wave tag
                            storage_pool = random.randint(1, 9)  # Random pool
                        elif tag.startswith("#*"):  # Star tag
                            storage_pool = 4  # Quaternary storage
                        elif tag.startswith("#!"):  # Alert tag
                            storage_pool = 5  # Quinary storage
                        elif tag.startswith("#?"):  # Query tag
                            storage_pool = 6  # Senary storage
                        elif tag.startswith("#="):  # Equal tag
                            storage_pool = 7  # Septenary storage
                        elif tag.startswith("#t"):  # Time tag
                            storage_pool = 8  # Octonary storage
                        elif tag.startswith("#0"):  # Core 0 tag
                            storage_pool = 9  # Nonary storage - reserved for multithreading
                        break
        
        # Create memory with appropriate storage pool
        memory = Memory(content, CONFIG["dimension"], CONFIG["device"], tags or [], storage_pool)
        
        # If this is a multithreaded memory (#0 tag), assign to thread
        if tags and any(tag.startswith("#0") for tag in tags):
            # Extract thread ID from tag if specified (e.g., #0:5)
            for tag in tags:
                if tag.startswith("#0:") and len(tag) > 3:
                    try:
                        thread_id = int(tag[3:])
                        memory.thread_id = thread_id % 16  # Keep within 0-15 range
                    except ValueError:
                        pass
        
        # Add memory to collection
        self.memories.append(memory)
        
        if CONFIG["auto_save"]:
            self.save_state()
            
        # Check if this memory fulfills any wishes
        self.check_wish_fulfillment(memory)
            
        return memory
    
    def check_wish_fulfillment(self, memory: Memory) -> List[Wish]:
        fulfilled_wishes = []
        memory_content = memory.content.lower()
        
        for wish in self.wishes:
            if wish.fulfilled:
                continue
                
            # Simple word matching for wish fulfillment
            wish_words = set(wish.text.lower().split())
            memory_words = set(memory_content.split())
            
            # Check if at least 3 important words match
            important_words = [w for w in wish_words if len(w) > 3]
            matches = [w for w in important_words if w in memory_words]
            
            if len(matches) >= 3:
                wish.fulfilled = True
                wish.fulfilled_at = datetime.now()
                wish.memories_used.append(memory.id)
                fulfilled_wishes.append(wish)
                
                print(f"# WISH FULFILLED: {wish.text}")
                
        if fulfilled_wishes and CONFIG["auto_save"]:
            self.save_state()
            
        return fulfilled_wishes
    
    def connect_to_api(self, name: str, prompt: str) -> Optional[str]:
        """Send prompt to specified API and return response"""
        if not self.apis.get(name) or not self.apis[name].is_online:
            return f"# ERROR: API {name} is not available"
        
        api = self.apis[name]
        
        if name == "openai":
            response = api.send_request(
                "chat/completions", 
                "POST",
                {
                    "model": "gpt-3.5-turbo",
                    "messages": [{"role": "user", "content": prompt}],
                    "max_tokens": 500
                }
            )
            if response and "choices" in response:
                return response["choices"][0]["message"]["content"]
                
        elif name == "anthropic":
            response = api.send_request(
                "messages",
                "POST",
                {
                    "model": "claude-3-opus-20240229",
                    "max_tokens": 500,
                    "messages": [{"role": "user", "content": prompt}]
                }
            )
            if response and "content" in response:
                return response["content"][0]["text"]
        
        return "# ERROR: Failed to get response"
    
    def process_command(self, command: str) -> str:
        """Process user command and return response"""
        self.command_history.append(command)
        
        # Split command into parts
        parts = command.strip().split(maxsplit=1)
        cmd = parts[0].lower() if parts else ""
        args = parts[1] if len(parts) > 1 else ""
        
        # Process command
        if cmd in ["exit", "quit", "q"]:
            self.save_state()
            self.stop_api_check_thread()
            return "# Exiting Wish Console..."
            
        elif cmd == "help":
            return self.show_help()
            
        elif cmd == "wish":
            # Check for extended format with category and date
            # Format: wish [category:emoji] [date:YYYY-MM-DD] [details:text] main wish text
            category = "default"
            emoji = None
            pinpoint_date = None
            details = ""
            wish_text = args
            
            # Parse optional parameters
            if "[" in args and "]" in args:
                params = []
                while args.startswith("[") and "]" in args:
                    param_end = args.index("]") + 1
                    params.append(args[:param_end])
                    args = args[param_end:].strip()
                
                wish_text = args  # After removing all parameters
                
                for param in params:
                    param = param[1:-1]  # Remove brackets
                    if ":" in param:
                        key, value = param.split(":", 1)
                        key = key.lower().strip()
                        value = value.strip()
                        
                        if key == "category":
                            category = value
                        elif key == "emoji":
                            emoji = value
                        elif key == "date":
                            pinpoint_date = value
                        elif key == "details":
                            details = value
            
            wish = Wish(
                wish_text, 
                CONFIG["dimension"],
                tags=None,
                category=category,
                emoji=emoji,
                pinpoint_date=pinpoint_date,
                details=details
            )
            self.wishes.append(wish)
            
            # Add to daily wishes tracking
            if wish.pinpoint_date not in self.daily_wishes:
                self.daily_wishes[wish.pinpoint_date] = []
            self.daily_wishes[wish.pinpoint_date].append(wish.id)
            
            if CONFIG["auto_save"]:
                self.save_state()
                
            return f"# Created wish: {wish.id}\n{wish.get_display_text(True)}"
            
        elif cmd == "memory":
            memory = self.add_memory(args)
            return f"# Created memory: {memory.id}\n{memory.content}"
            
        elif cmd == "dimension":
            try:
                dim = int(args)
                if 1 <= dim <= 12:
                    CONFIG["dimension"] = dim
                    return f"# Changed to dimension {dim}: {self.dimension_names.get(dim)}"
                else:
                    return "# ERROR: Dimension must be between 1 and 12"
            except:
                return "# ERROR: Invalid dimension number"
                
        elif cmd == "device":
            try:
                dev = int(args)
                if 0 <= dev <= 3:
                    CONFIG["device"] = dev
                    return f"# Changed to device {dev}"
                else:
                    return "# ERROR: Device must be between 0 and 3"
            except:
                return "# ERROR: Invalid device number"
                
        elif cmd == "list":
            if args == "wishes":
                return self.list_wishes()
            elif args == "memories":
                return self.list_memories()
            elif args == "apis":
                return self.list_apis()
            elif args == "drives":
                return self.list_drive_systems()
            elif args == "projects":
                return self.list_projects()
            elif args.startswith("wishes "):
                date = args.split(maxsplit=1)[1]
                return self.list_wishes_by_date(date)
            else:
                return "# ERROR: Unknown list type. Use: wishes, memories, apis, drives, projects"
                
    def list_drive_systems(self) -> str:
        """List all drive systems and memory statistics for each"""
        result = ["# DRIVE SYSTEMS:"]
        drives_used = set(m.drive for m in self.memories)
        
        for drive, desc in Memory.DRIVE_SYSTEMS.items():
            drive_memories = [m for m in self.memories if m.drive == drive]
            status = "ACTIVE" if drive in drives_used else "INACTIVE"
            memory_count = len(drive_memories)
            total_tokens = sum(m.token_size for m in drive_memories)
            
            result.append(f"# {drive}: {desc}")
            result.append(f"#   Status: {status} | Memories: {memory_count} | Tokens: {total_tokens}")
            
            # Show storage pools used in this drive
            pools_used = set(m.storage_pool for m in drive_memories)
            if pools_used:
                pool_info = []
                for pool in sorted(pools_used):
                    pool_name = Memory.STORAGE_POOLS.get(pool, "Unknown")
                    pool_memories = [m for m in drive_memories if m.storage_pool == pool]
                    pool_info.append(f"{pool_name}:{len(pool_memories)}")
                    
                result.append(f"#   Pools: {' | '.join(pool_info)}")
            
            result.append("#")
        
        return "\n".join(result)
        
    def list_projects(self) -> str:
        """List all project memories"""
        project_memories = [m for m in self.memories if m.is_project]
        
        if not project_memories:
            return "# No projects found"
            
        result = ["# PROJECTS:"]
        
        # Group by project ID
        projects = {}
        for memory in project_memories:
            if memory.project_id not in projects:
                projects[memory.project_id] = []
            projects[memory.project_id].append(memory)
        
        # List projects
        for project_id, memories in projects.items():
            # Use the first memory's content as project title
            title = memories[0].content
            drive = memories[0].drive
            result.append(f"# {project_id} [{drive}] - {title}")
            result.append(f"#   Memories: {len(memories)} | Path: {drive}:/{project_id}")
            
            # List tags used in this project
            all_tags = set()
            for memory in memories:
                all_tags.update(memory.tags)
            if all_tags:
                result.append(f"#   Tags: {' '.join(sorted(all_tags))}")
                
            result.append("#")
        
        return "\n".join(result)
                
        elif cmd == "save":
            self.save_state()
            return "# State saved successfully"
            
        elif cmd == "load":
            self.load_state()
            return "# State loaded successfully"
                
        elif cmd == "api":
            # Format: api <name> <prompt>
            parts = args.split(maxsplit=1)
            if len(parts) != 2:
                return "# ERROR: Format is 'api <name> <prompt>'"
                
            api_name, prompt = parts
            return self.connect_to_api(api_name, prompt)
            
        elif cmd == "addapi":
            # Format: addapi <name> <url> <key> <response_path>
            parts = args.split(maxsplit=3)
            if len(parts) < 2:
                return "# ERROR: Format is 'addapi <name> <url> [key] [response_path]'"
                
            name = parts[0]
            url = parts[1]
            key = parts[2] if len(parts) > 2 else ""
            response_path = parts[3] if len(parts) > 3 else None
            
            if name in self.apis:
                return f"# ERROR: API {name} already exists"
                
            headers = {}
            if key:
                # Auto-determine header format based on URL
                if "openai" in url.lower():
                    headers = {"Authorization": f"Bearer {key}"}
                elif "anthropic" in url.lower():
                    headers = {"x-api-key": key}
                else:
                    headers = {"Authorization": f"Bearer {key}"}  # Default
            
            self.apis[name] = APIConnection(
                name=name,
                url=url,
                key=key,
                headers=headers,
                response_path=response_path
            )
            
            # Check the API status
            is_online = self.apis[name].check_status()
            status = "ONLINE" if is_online else "OFFLINE"
            
            return f"# Added API: {name} ({url}) - Status: {status}"
            
        elif cmd == "check":
            if args:
                if args in self.apis:
                    self.apis[args].check_status()
                    status = "ONLINE" if self.apis[args].is_online else "OFFLINE"
                    response_time = f"{self.apis[args].response_time:.2f}s" if self.apis[args].response_time else "N/A"
                    return f"# API {args}: {status} (Response: {response_time})"
                else:
                    return f"# ERROR: Unknown API {args}"
            else:
                results = []
                for api_name, api in self.apis.items():
                    api.check_status()
                    status = "ONLINE" if api.is_online else "OFFLINE"
                    response_time = f"{api.response_time:.2f}s" if api.response_time else "N/A"
                    results.append(f"# API {api_name}: {status} (Response: {response_time})")
                return "\n".join(results)
                
        elif cmd == "ascii":
            return self.generate_ascii_visualization()
            
        elif cmd == "story":
            # Get number of turns from args if provided
            turns = 12  # Default
            if args and args.isdigit():
                turns = int(args)
            return self.generate_story(turns)
            
        elif cmd == "animate":
            # Format: animate <memory_id> [frame_number]
            parts = args.split()
            if not parts:
                return "# ERROR: Missing memory ID. Format: animate <memory_id> [frame]"
                
            memory_id = parts[0]
            frame = 0
            if len(parts) > 1 and parts[1].isdigit():
                frame = int(parts[1])
                
            memory = next((m for m in self.memories if m.id == memory_id), None)
            if not memory:
                return f"# ERROR: Memory with ID {memory_id} not found"
                
            animation = memory.generate_animation_frame(frame)
            
            result = [f"# ANIMATION: {memory_id} - FRAME {frame}"]
            result.append(f"#{'=' * 78}#")
            
            # Add the animation frame lines
            for line in animation.split("\n"):
                result.append(f"# {line}")
                
            result.append(f"#{'=' * 78}#")
            result.append(f"# Memory: {memory.content}")
            if memory.animation_frames:
                result.append(f"# Total frames: {len(memory.animation_frames)}")
            
            return "\n".join(result)
            
        elif cmd == "drive":
            # Switch active drive
            if not args or len(args) != 1:
                return "# ERROR: Please specify a drive letter (C, D, M, G, T, L, A, E, V)"
                
            drive = args.upper()
            if drive not in Memory.DRIVE_SYSTEMS:
                return f"# ERROR: Unknown drive '{drive}'. Valid drives: {', '.join(Memory.DRIVE_SYSTEMS.keys())}"
                
            # Update device based on drive (to be used for visualization)
            drive_list = list(Memory.DRIVE_SYSTEMS.keys())
            CONFIG["device"] = drive_list.index(drive) % 4  # Map to device 0-3
            
            drive_name = Memory.DRIVE_SYSTEMS[drive]
            return f"# Changed to drive {drive}: {drive_name} (Device {CONFIG['device']})"
            
        elif cmd == "tokens":
            # Show token usage stats
            token_stats = {}
            
            # Count tokens by pool
            for pool in range(1, 10):
                pool_memories = [m for m in self.memories if m.storage_pool == pool]
                if pool_memories:
                    token_stats[pool] = sum(m.token_size for m in pool_memories)
            
            # Count tokens by drive
            drive_tokens = {}
            for drive in Memory.DRIVE_SYSTEMS:
                drive_memories = [m for m in self.memories if m.drive == drive]
                if drive_memories:
                    drive_tokens[drive] = sum(m.token_size for m in drive_memories)
            
            # Generate report
            result = ["# TOKEN USAGE STATISTICS"]
            result.append(f"#{'=' * 78}#")
            
            # By pool
            result.append("# BY STORAGE POOL:")
            for pool, tokens in sorted(token_stats.items()):
                pool_name = Memory.STORAGE_POOLS.get(pool, "Unknown")
                memories = len([m for m in self.memories if m.storage_pool == pool])
                result.append(f"# {pool}. {pool_name}: {tokens} tokens in {memories} memories")
                
            result.append("#")
            
            # By drive
            result.append("# BY DRIVE SYSTEM:")
            for drive, tokens in sorted(drive_tokens.items()):
                drive_name = Memory.DRIVE_SYSTEMS.get(drive, "Unknown")
                memories = len([m for m in self.memories if m.drive == drive])
                result.append(f"# {drive}: {drive_name}: {tokens} tokens in {memories} memories")
                
            result.append(f"#{'=' * 78}#")
            
            # Total
            total_tokens = sum(m.token_size for m in self.memories)
            total_memories = len(self.memories)
            result.append(f"# TOTAL: {total_tokens} tokens in {total_memories} memories")
            
            # Average
            if total_memories > 0:
                avg_tokens = total_tokens / total_memories
                result.append(f"# AVERAGE: {avg_tokens:.1f} tokens per memory")
                
            result.append(f"#{'=' * 78}#")
            
            return "\n".join(result)
            
        elif cmd == "ctrl+shift" or cmd == "ctrl":
            # Format: ctrl+shift <memory_id> <shift_type>
            parts = args.split()
            if len(parts) < 2:
                return "# ERROR: Format is 'ctrl+shift <memory_id> <shift_type>'"
                
            memory_id = parts[0]
            shift_type = parts[1]
            
            # Validate shift type
            valid_shifts = ["ascend", "descend", "pool_shift", "drive_shift"]
            if shift_type not in valid_shifts:
                return f"# ERROR: Invalid shift type. Use one of: {', '.join(valid_shifts)}"
                
            # Find memory
            memory = next((m for m in self.memories if m.id == memory_id), None)
            if not memory:
                return f"# ERROR: Memory with ID {memory_id} not found"
                
            # Save old state for reporting
            old_dim = memory.dimension
            old_pool = memory.storage_pool
            old_drive = memory.drive
            
            # Apply the shift
            memory.add_ctrl_shift(shift_type)
            
            # Report the changes
            result = [f"# CTRL+SHIFT: {shift_type} applied to {memory_id}"]
            result.append(f"# Dimension: {old_dim} → {memory.dimension}")
            result.append(f"# Storage Pool: {old_pool} ({Memory.STORAGE_POOLS.get(old_pool)}) → " +
                         f"{memory.storage_pool} ({Memory.STORAGE_POOLS.get(memory.storage_pool)})")
            result.append(f"# Drive: {old_drive} ({Memory.DRIVE_SYSTEMS.get(old_drive)}) → " +
                         f"{memory.drive} ({Memory.DRIVE_SYSTEMS.get(memory.drive)})")
            result.append(f"# Content: {memory.content}")
            
            if CONFIG["auto_save"]:
                self.save_state()
                
            return "\n".join(result)
            
        elif cmd == "truth" or cmd == "terminal":
            # Terminal of Truth visualization
            # Format: truth [memory_id]
            if not args:
                # Create a visualization of all shape memories
                shape_memories = [m for m in self.memories if m.shape_overlay is not None]
                if not shape_memories:
                    return "# No shape memories found. Create one with the #s tag."
                    
                # Show a summary of available shape memories
                result = ["# TERMINAL OF TRUTH - SHAPE MEMORIES"]
                result.append(f"#{'=' * 78}#")
                
                for memory in shape_memories:
                    truth_pct = int(memory.truth_value * 100)
                    result.append(f"# {memory.id} - Truth: {truth_pct}% - {memory.content[:40]}")
                    
                result.append(f"#{'=' * 78}#")
                result.append("# Use 'truth <memory_id>' to view a specific shape overlay")
                
                return "\n".join(result)
            else:
                # Show a specific memory's shape overlay
                memory_id = args
                memory = next((m for m in self.memories if m.id == memory_id), None)
                
                if not memory:
                    return f"# ERROR: Memory with ID {memory_id} not found"
                
                # If this memory doesn't have a shape overlay, create one
                if memory.shape_overlay is None:
                    memory.shape_overlay = ShapeOverlay(10, 5)
                    memory.shape_overlay.fill_from_memory(memory)
                    memory.tags.append("#s")  # Add shape tag
                
                # Generate the visualization
                result = [f"# TERMINAL OF TRUTH - {memory_id}"]
                result.append(f"#{'=' * 78}#")
                
                # Add content summary
                result.append(f"# Content: {memory.content[:60]}")
                result.append(f"# Dimension: {memory.dimension} | Drive: {memory.drive} | Truth: {int(memory.truth_value * 100)}%")
                result.append(f"#{'=' * 78}#")
                
                # Add the shape overlay
                overlay_lines = memory.shape_overlay.get_overlay().split("\n")
                for line in overlay_lines:
                    result.append(f"# {line}")
                
                # Add keyboard mapping reference
                result.append(f"#{'=' * 78}#")
                result.append("# KEYBOARD TO SHAPE MAPPING:")
                
                key_rows = [
                    "Q W E R T Y U I O P",
                    "A S D F G H J K L",
                    "Z X C V B N M , ."
                ]
                
                for i, row in enumerate(key_rows):
                    keys = row.split()
                    shapes = []
                    
                    for key in keys:
                        key = key.lower()
                        shape = ShapeOverlay.KEY_MAP.get(key, "square")
                        shape_symbol = ShapeOverlay.SHAPES.get(shape, "■")
                        shapes.append(f"{key.upper()}={shape_symbol}")
                        
                    result.append(f"# {' | '.join(shapes)}")
                
                result.append(f"#{'=' * 78}#")
                
                return "\n".join(result)
            
        elif cmd == "shape":
            # Create or update a shape overlay
            # Format: shape <memory_id> <width> <height>
            parts = args.split()
            if len(parts) < 1:
                return "# ERROR: Please specify a memory ID"
                
            memory_id = parts[0]
            width = 10  # Default
            height = 5  # Default
            
            if len(parts) > 1 and parts[1].isdigit():
                width = min(20, max(5, int(parts[1])))
            if len(parts) > 2 and parts[2].isdigit():
                height = min(10, max(3, int(parts[2])))
                
            memory = next((m for m in self.memories if m.id == memory_id), None)
            if not memory:
                return f"# ERROR: Memory with ID {memory_id} not found"
                
            # Create or recreate the shape overlay
            memory.shape_overlay = ShapeOverlay(width, height)
            memory.shape_overlay.fill_from_memory(memory)
            
            # Add shape tag if not present
            if not any(tag.startswith("#s") for tag in memory.tags):
                memory.tags.append("#s")
                
            # Show the overlay
            result = [f"# Created shape overlay for {memory_id} ({width}x{height})"]
            overlay_lines = memory.shape_overlay.get_overlay().split("\n")
            for line in overlay_lines:
                result.append(f"# {line}")
                
            return "\n".join(result)
            
        elif cmd == "clear":
            if args == "memories":
                self.memories = []
                return "# All memories cleared"
            elif args == "wishes":
                self.wishes = []
                self.daily_wishes = {}
                return "# All wishes cleared"
            elif args == "all":
                self.memories = []
                self.wishes = []
                self.daily_wishes = {}
                return "# All memories and wishes cleared"
            elif args == "lines":
                self.shared_lines = []
                self.active_line_index = 0
                return "# All shared lines cleared"
            else:
                return "# ERROR: Specify what to clear: memories, wishes, lines, all"
                
        elif cmd == "connect":
            parts = args.split()
            if len(parts) != 2:
                return "# ERROR: Format is 'connect <memory_id> <memory_id>'"
                
            mem1, mem2 = parts
            m1 = next((m for m in self.memories if m.id == mem1), None)
            m2 = next((m for m in self.memories if m.id == mem2), None)
            
            if not m1 or not m2:
                return "# ERROR: Memory not found"
                
            m1.connections.append(m2.id)
            m2.connections.append(m1.id)
            
            return f"# Connected memories: {m1.id} <-> {m2.id}"
        
        elif cmd == "today":
            # Create a wish pinpointed to today
            today = datetime.now().strftime("%Y-%m-%d")
            wish = Wish(
                args, 
                CONFIG["dimension"],
                pinpoint_date=today,
                category="creation"
            )
            self.wishes.append(wish)
            
            # Add to daily wishes tracking
            if today not in self.daily_wishes:
                self.daily_wishes[today] = []
            self.daily_wishes[today].append(wish.id)
            
            if CONFIG["auto_save"]:
                self.save_state()
                
            return f"# Created today's wish: {wish.id}\n{wish.get_display_text(True)}"
            
        elif cmd.startswith("#"):
            # Special format command - create tagged memory
            
            # Determine if this is a multi-line spread content
            lines = command.split("\n")
            if len(lines) > 1:
                # This is a spread memory with multiple lines
                memory = self.add_memory(command, [cmd])
                
                result = f"# Created spread memory with {len(memory.spread_lines)+1} lines (tag: {cmd})\n"
                result += f"# ID: {memory.id} | Pool: {Memory.STORAGE_POOLS.get(memory.storage_pool)}\n"
                result += f"# Main: {memory.content}\n"
                
                for i, line in enumerate(memory.spread_lines):
                    result += f"# Line {i+1}: {line}\n"
                
                return result
                
            # Special handling for multithread tags (#0)
            elif cmd.startswith("#0"):
                # This is a multithreaded memory (Core 0)
                thread_id = 0  # Default thread ID
                
                # Check if thread ID is specified (e.g., #0:5)
                if ":" in cmd:
                    try:
                        thread_id = int(cmd.split(":", 1)[1])
                    except ValueError:
                        pass
                    
                # Create the memory with the Core 0 tag
                memory = self.add_memory(command, [cmd], storage_pool=9)  # Use Nonary storage for Core 0
                
                return f"# Created multithreaded memory (Core 0, Thread {memory.thread_id})\n" + \
                       f"# ID: {memory.id} | Pool: {Memory.STORAGE_POOLS.get(memory.storage_pool)}\n" + \
                       f"# Content: {memory.content}"
            
            # Handle other special tag types
            else:
                # Get tag description if available
                tag_type = ""
                for prefix, description in Memory.TAG_TYPES.items():
                    if cmd.startswith(prefix):
                        tag_type = description
                        break
                
                # Create the memory with the tag
                memory = self.add_memory(command, [cmd])
                
                tag_info = f" - {tag_type}" if tag_type else ""
                return f"# Created tagged memory ({cmd}{tag_info})\n" + \
                       f"# ID: {memory.id} | Pool: {Memory.STORAGE_POOLS.get(memory.storage_pool)}\n" + \
                       f"# Content: {memory.content}"
        
        else:
            # Default: create memory with content
            memory = self.add_memory(command)
            return f"# Created memory: {memory.id}\n{memory.content}"
            
    def list_wishes_by_date(self, date: str) -> str:
        """List wishes for a specific date"""
        if date not in self.daily_wishes or not self.daily_wishes[date]:
            return f"# No wishes found for date: {date}"
            
        result = [f"# WISHES FOR {date}:"]
        for wish_id in self.daily_wishes[date]:
            wish = next((w for w in self.wishes if w.id == wish_id), None)
            if wish:
                result.append(wish.get_display_text(True))
            
        return "\n".join(result)
        
    def generate_story(self, turns: int = 12) -> str:
        """Generate a 12-turn story using memories across dimensions"""
        if not self.memories:
            return "# No memories found to create a story"
            
        result = [f"# THE {turns} TURN STORY"]
        result.append(f"#{'=' * 78}#")
        
        # Try to find memories from each dimension if possible
        dimension_memories = {}
        for dim in range(1, 13):
            dim_mems = [m for m in self.memories if m.dimension == dim]
            if dim_mems:
                dimension_memories[dim] = dim_mems
        
        # Determine how many turns we can create
        available_dims = len(dimension_memories)
        actual_turns = min(turns, available_dims, 12)
        
        # If we have fewer than requested turns, repeat some dimensions
        if actual_turns < turns:
            # Supplement with memories from any dimension
            all_mems = sorted(self.memories, key=lambda m: m.created_at)
            while len(dimension_memories) < turns:
                for i, memory in enumerate(all_mems):
                    if len(dimension_memories) >= turns:
                        break
                    # Add this memory to a new "virtual" dimension
                    virtual_dim = len(dimension_memories) + 1
                    dimension_memories[virtual_dim] = [memory]
        
        # Generate the story with one memory per turn/dimension
        for turn in range(1, turns + 1):
            if turn in dimension_memories:
                # Select a memory for this turn
                memories = dimension_memories[turn]
                
                # Prefer memories with higher token counts or more connections
                memories.sort(key=lambda m: (len(m.connections), m.token_size), reverse=True)
                memory = memories[0]
                
                # Get dimension name
                dim_name = self.dimension_names.get(turn, f"DIMENSION {turn}")
                
                # Add story entry
                result.append(f"# TURN {turn}: {dim_name}")
                
                # Get memory symbol
                symbol = memory.get_ascii_symbol()
                
                # Format the memory content
                content = memory.content
                if memory.spread_lines:
                    content += "..."
                
                # Add memory details
                result.append(f"# {symbol} [{memory.drive}:{memory.storage_pool}] {memory.id[-8:]}")
                result.append(f"# {content}")
                
                # If memory has tags, add them
                if memory.tags:
                    result.append(f"# Tags: {' '.join(memory.tags)}")
                
                # Show connections if any
                if memory.connections:
                    conn_ids = [c[-4:] for c in memory.connections[:3]]
                    result.append(f"# Connects to: {', '.join(conn_ids)}")
                    
                # Add separator between turns
                result.append(f"#{'- ' * 39}#")
            else:
                # No memory for this turn/dimension
                result.append(f"# TURN {turn}: UNKNOWN")
                result.append(f"# No memory found for this turn")
                result.append(f"#{'- ' * 39}#")
        
        # Add epilogue
        result.append(f"#{'=' * 78}#")
        result.append("# STORY SUMMARY:")
        
        # Count unique drives, pools, and total tokens
        drives_used = set(m.drive for turn in dimension_memories for m in dimension_memories[turn] if turn <= turns)
        pools_used = set(m.storage_pool for turn in dimension_memories for m in dimension_memories[turn] if turn <= turns)
        total_tokens = sum(m.token_size for turn in dimension_memories for m in dimension_memories[turn] if turn <= turns)
        
        result.append(f"# Spans {len(drives_used)} drives, {len(pools_used)} pools, and {total_tokens} tokens")
        result.append(f"#{'=' * 78}#")
        
        return "\n".join(result)
    
    def show_help(self) -> str:
        help_text = """
# WISH CONSOLE COMMANDS #
-------------------------
wish <text>                      - Create a new wish
wish [category:type] [date:YYYY-MM-DD] [details:text] <text> - Create detailed wish
today <text>                    - Create wish pinpointed to today
memory <text>                   - Create a new memory
#<text>                         - Create tagged memory
#p <text>                       - Create project memory
#d:<drive> <text>               - Create drive-specific memory
#0 <text>                       - Create multithreaded memory
#0:<thread> <text>              - Create memory on specific thread
#s <text>                       - Create memory with shape overlay
#s:<truth> <text>               - Create memory with shape overlay and truth value
dimension <1-12>                - Change current dimension
device <0-3>                    - Change current device
drive <letter>                  - Change current drive (C, D, M, G, T, L, A, E, V)
list wishes                     - List all wishes
list wishes <date>              - List wishes for specific date
list memories                   - List all memories
list drives                     - List all drive systems
list apis                       - List available APIs
list projects                   - List all project memories
api <name> <text>               - Send text to API
addapi <name> <url> [key] [path] - Add new custom API
check [api_name]                - Check API status
connect <id> <id>               - Connect two memories
project <id>                    - View project details
animate <id> [frame]            - Show animation for memory
ctrl+shift <id> <type>          - Apply control shift to memory
truth [id]                      - View Terminal of Truth shape overlay
terminal [id]                   - Same as truth command
shape <id> [width] [height]     - Create/update shape overlay for memory
story [turns]                   - Display 12-turn story across dimensions
ascii                           - Show ASCII visualization
tokens                          - Show token usage across pools
up                              - Navigate up through shared lines
down                            - Navigate down through shared lines
add                             - Add new shared line
save                            - Save current state
load                            - Load saved state
clear memories                  - Clear all memories
clear wishes                    - Clear all wishes
clear lines                     - Clear all shared lines
help                            - Show this help
exit/quit                       - Exit console

# SPECIAL FEATURES #
- Press Enter with no command to use active shared line
- Use [↑/↓] for navigating shared lines
- The 9x9 grid shows memory visualization by drive
- Daily wishes are tracked by date
- Tokens usage is estimated for each storage pool
- Animation frames can be created with 'frame:' prefix in multi-line memories
- Control shifts allow memories to move between dimensions and drives

# MEMORY TAG TYPES #
Standard # | Core ## | Flow #> | Thread #- | Ascend #^
Wave #~ | Star #* | Alert #! | Query #? | Equal #=
Time #t | Core 0 #0 | Project #p | Drive #d | Godot #g
Overlay #o | 2D App #2d | 3D World #3d

# WISH CATEGORIES #
Creation ✨ | Knowledge 🧠 | Connection 🔄 | Growth 🌱
Harmony ☯️ | Power ⚡ | Transformation 🦋 | Balance ⚖️  
Unity 🔗 | Transcendence 🌌

# DRIVE SYSTEMS #
C: Windows | D: Data | M: Memory | G: Godot | T: Temple OS 
L: Luminus OS | A: AI Drive | E: External | V: Virtual
"""
        return help_text
    
    def list_wishes(self) -> str:
        if not self.wishes:
            return "# No wishes found"
            
        result = ["# WISHES:"]
        for i, wish in enumerate(self.wishes):
            status = "FULFILLED" if wish.fulfilled else "PENDING"
            result.append(f"{i+1}. [{status}] {wish.id}: {wish.text}")
        
        return "\n".join(result)
    
    def list_memories(self) -> str:
        if not self.memories:
            return "# No memories found"
            
        result = ["# MEMORIES:"]
        for i, memory in enumerate(self.memories):
            tags = " ".join(memory.tags) if memory.tags else ""
            result.append(f"{i+1}. D{memory.dimension} {memory.id}: {tags} {memory.content}")
        
        return "\n".join(result)
    
    def list_apis(self) -> str:
        result = ["# APIS:"]
        for name, api in self.apis.items():
            status = "ONLINE" if api.is_online else "OFFLINE"
            last_check = api.last_check.strftime("%H:%M:%S") if api.last_check else "Never"
            result.append(f"- {name}: {status} (Last check: {last_check})")
        
        return "\n".join(result)
    
    def generate_ascii_visualization(self) -> str:
        """Generate enhanced ASCII art visualization with # tag symbols and multi-threading"""
        # Skip if ASCII mode is disabled
        if not CONFIG["ascii_mode"]:
            return "# ASCII visualization is disabled"
            
        # Generate dynamic ASCII visualization based on current dimensions and memories
        dim = CONFIG["dimension"]
        device = CONFIG["device"]
        
        # First construct header
        ascii_art = [
            f"#{'=' * 78}#",
            f"# DIMENSION {dim}: {self.dimension_names.get(dim)} | DEVICE {device} | STORAGE POOLS: {len(set(m.storage_pool for m in self.memories))}",
            f"#{'=' * 78}#"
        ]
        
        # Explanation of ASCII symbols
        symbol_legend = "# SYMBOLS: "
        for i, (tag, symbol) in enumerate(Memory.ASCII_SYMBOLS.items()):
            if i < 6:  # Just show first 6 for space reasons
                symbol_legend += f"{symbol}={tag} "
        ascii_art.append(symbol_legend)
        
        # Filter memories for current dimension and device
        current_memories = [m for m in self.memories if m.dimension == dim and m.device == device]
        
        # Show multithreaded status
        has_multithreaded = any(m.is_multithreaded() for m in current_memories)
        thread_status = f"# CORE 0: {'ACTIVE' if has_multithreaded else 'INACTIVE'} | {'MULTITHREADING ENABLED' if has_multithreaded else 'SINGLE THREAD MODE'}"
        ascii_art.append(thread_status)
        
        # Generate memory map
        if not current_memories:
            ascii_art.append(f"#{'=' * 78}#")
            ascii_art.append("#       No memories in current dimension/device")
            ascii_art.append(f"#{'=' * 78}#")
        else:
            # Generate the multi-drive display
            ascii_art.append(f"#{'=' * 78}#")
            ascii_art.append("# DRIVE SYSTEMS:")
            
            # Show active drives
            active_drives = set(m.drive for m in self.memories)
            drive_status = []
            for drive, desc in Memory.DRIVE_SYSTEMS.items():
                status = "ACTIVE" if drive in active_drives else "INACTIVE"
                icon = "●" if drive in active_drives else "○"
                drive_status.append(f"{icon} {drive}:{desc[:15]}")
            
            # Display in 3 columns for compactness
            for i in range(0, len(drive_status), 3):
                line = "# "
                for j in range(3):
                    if i + j < len(drive_status):
                        line += f"{drive_status[i+j]:<25}"
                ascii_art.append(line)
            
            # Generate the 9x9 grid
            ascii_art.append(f"#{'=' * 78}#")
            
            # Get the current drive - use device to determine
            current_drive = list(Memory.DRIVE_SYSTEMS.keys())[min(device, len(Memory.DRIVE_SYSTEMS)-1)]
            ascii_art.append(f"# MEMORY GRID - DRIVE {current_drive}:{Memory.DRIVE_SYSTEMS.get(current_drive)}")
            
            # Create a 9x9 grid for visualization
            grid = [["·" for _ in range(9)] for _ in range(9)]
            memory_lookup = {}  # To store memory details for each position
            
            # Populate grid with memories from current drive
            drive_memories = [m for m in current_memories if m.drive == current_drive]
            for memory in drive_memories:
                # Pool determines row (y), thread determines column (x)
                pool = memory.storage_pool - 1  # 0-8
                thread = memory.thread_id % 9  # 0-8
                
                # Skip if position already filled (first wins)
                if grid[pool][thread] != "·":
                    continue
                    
                # Use the memory's tag symbol
                symbol = memory.get_ascii_symbol()
                grid[pool][thread] = symbol
                memory_lookup[(pool, thread)] = memory
            
            # Mark current dimension and pool with X
            if 0 <= dim-1 < 9 and 0 <= CONFIG["dimension"]-1 < 9:
                # Only if not occupied by a memory
                if grid[CONFIG["dimension"]-1][dim-1] == "·":
                    grid[CONFIG["dimension"]-1][dim-1] = "X"
            
            # Print grid with coordinates
            # Column headers (dimensions 1-9)
            line = "#  "
            for x in range(9):
                line += f"D{x+1} "
            ascii_art.append(line)
            
            # Grid rows with pool numbers
            for y in range(9):
                pool_name = Memory.STORAGE_POOLS.get(y+1, "")[0]  # First letter of pool name
                token_count = sum(m.token_size for m in self.memories if m.storage_pool == y+1 and m.drive == current_drive)
                pool_info = f"{pool_name}:{token_count:<2}"  # Show token count for pool
                line = f"# {pool_info}"
                for x in range(9):
                    line += f" {grid[y][x]} "
                ascii_art.append(line)
            
            # Show some memory details below grid
            ascii_art.append(f"#{'=' * 78}#")
            ascii_art.append("# MEMORY DETAILS:")
            
            # Show detail for up to 3 recent memories in the current dimension/device
            shown_memories = current_memories[-3:] if current_memories else []
            for memory in shown_memories:
                # Get tag type description if available
                tag_type = memory.get_tag_type()
                tag_info = f" - {tag_type}" if tag_type else ""
                
                # Truncate content for display
                content = memory.content[:40] + "..." if len(memory.content) > 40 else memory.content
                
                # Show memory details
                ascii_art.append(f"# {memory.get_ascii_symbol()} {memory.id[-8:]} [P{memory.storage_pool}]{tag_info}")
                ascii_art.append(f"#   {content}")
                
                # Add spread lines if they exist (limited to first 2)
                if memory.spread_lines:
                    for i, line in enumerate(memory.spread_lines[:2]):
                        truncated = line[:40] + "..." if len(line) > 40 else line
                        ascii_art.append(f"#   #{i+1}: {truncated}")
            
            # Show thread connections if multithreaded
            if has_multithreaded:
                ascii_art.append(f"#{'=' * 78}#")
                ascii_art.append("# THREAD CONNECTIONS:")
                thread_groups = {}
                
                # Group memories by thread ID
                for memory in current_memories:
                    if memory.is_multithreaded():
                        thread_id = memory.thread_id
                        if thread_id not in thread_groups:
                            thread_groups[thread_id] = []
                        thread_groups[thread_id].append(memory.id[-4:])
                
                # Display active threads (up to 3)
                for i, (thread_id, memories) in enumerate(list(thread_groups.items())[:3]):
                    memory_ids = ", ".join(memories)
                    ascii_art.append(f"# T{thread_id}: {memory_ids}")
        
        # Show daily wishes
        today = datetime.now().strftime("%Y-%m-%d")
        today_wishes = [w for w in self.wishes if w.pinpoint_date == today]
        
        if today_wishes:
            ascii_art.append(f"#{'=' * 78}#")
            ascii_art.append(f"# TODAY'S WISHES ({today}):")
            
            for i, wish in enumerate(today_wishes[:3]):  # Show up to 3 wishes
                text = wish.text[:50] + "..." if len(wish.text) > 50 else wish.text
                power = "★" * min(wish.power_level, 5)
                status = "✓" if wish.fulfilled else "○"
                ascii_art.append(f"# {wish.emoji} {status} {power} {text}")
        
        ascii_art.append(f"#{'=' * 78}#")
        
        return "\n".join(ascii_art)
    
    def display_footer(self) -> str:
        """Generate and return the footer with shared lines optimized for Windows terminal"""
        if not self.shared_lines:
            return "# No shared lines - type 'add' to create new line commands"
        
        # Get current time for timestamp
        current_time = datetime.now().strftime("%H:%M:%S")
        
        # Create horizontal separator
        footer = [f"#{'=' * 78}#"]
        footer.append(f"# CMD LIBRARY | Active: {self.active_line_index+1}/{len(self.shared_lines)} | Enter=Execute | Up/Down=Navigate")
        
        # Format shared lines more compactly
        max_lines = min(5, len(self.shared_lines))  # Show up to 5 lines
        start_idx = max(0, min(self.active_line_index - max_lines//2, len(self.shared_lines) - max_lines))
        
        for i in range(start_idx, start_idx + max_lines):
            if i < len(self.shared_lines):
                marker = "▶" if i == self.active_line_index else " "
                # Truncate long lines
                line_text = self.shared_lines[i]
                if len(line_text) > 65:
                    line_text = line_text[:62] + "..."
                footer.append(f"# {marker} {i+1:2d}: {line_text}")
        
        # Add token status and time
        today = datetime.now().strftime("%Y-%m-%d")
        memory_count = len(self.memories)
        wish_count = len(self.wishes)
        
        footer.append(f"#{'=' * 78}#")
        footer.append(f"# Time: {current_time} | Memories: {memory_count} | Wishes: {wish_count} | Type 'help' for commands")
        
        return "\n".join(footer)
    
    def add_shared_line(self, line: str) -> None:
        """Add a new shared line to the collection"""
        self.shared_lines.append(line)
        self.active_line_index = len(self.shared_lines) - 1
        if CONFIG["auto_save"]:
            self.save_state()
    
    def use_active_line(self) -> str:
        """Process the currently active shared line"""
        if not self.shared_lines or self.active_line_index >= len(self.shared_lines):
            return "# No active line to use"
        
        active_line = self.shared_lines[self.active_line_index]
        return self.process_command(active_line)
    
    def navigate_shared_lines(self, direction: int) -> None:
        """Navigate up/down through shared lines"""
        if not self.shared_lines:
            return
            
        new_index = self.active_line_index + direction
        if 0 <= new_index < len(self.shared_lines):
            self.active_line_index = new_index
    
    def display_header(self) -> str:
        """Generate and return the enhanced header optimized for 9x9 window"""
        today = datetime.now().strftime("%Y-%m-%d")
        today_wishes = len([w for w in self.wishes if w.pinpoint_date == today])
        fulfilled_wishes = len([w for w in self.wishes if w.fulfilled])
        
        dim_name = self.dimension_names.get(CONFIG["dimension"], "UNKNOWN")
        
        # Calculate token usage estimates
        openai_tokens = 0
        anthropic_tokens = 0
        
        # Estimate token usage based on memories and wishes
        # Rough approximation: 1 token ≈ 4 characters for English text
        for memory in self.memories:
            chars = len(memory.content)
            openai_tokens += chars // 4
            anthropic_tokens += chars // 4
            
        for wish in self.wishes:
            chars = len(wish.text) + len(wish.details or "")
            openai_tokens += chars // 4
            anthropic_tokens += chars // 4
        
        # Format tokens with K suffix if > 1000
        def format_tokens(count):
            if count > 1000:
                return f"{count/1000:.1f}K"
            return str(count)
        
        header = [
            f"#{'=' * 78}#",
            f"# WISH-{CONFIG['dimension']}-{dim_name[:3]} | DEV-{CONFIG['device']} | {today} | ✓:{fulfilled_wishes}/{len(self.wishes)}",
        ]
        
        # Check API status with token info
        api_status = []
        for name, api in self.apis.items():
            symbol = "✓" if api.is_online else "✗"
            tokens = format_tokens(openai_tokens if name == "openai" else anthropic_tokens)
            api_status.append(f"{name}:{symbol}[{tokens}]")
        
        # Construct 9x9 grid representation (simplified)
        grid = [["·" for _ in range(9)] for _ in range(9)]
        
        # Place memories in the grid
        memory_count = min(len(self.memories), 81)  # Max 9x9 cells
        for i in range(memory_count):
            x = i % 9
            y = i // 9
            memory = self.memories[len(self.memories) - memory_count + i]
            # Use first character of memory content or special symbols
            if memory.tags and memory.tags[0].startswith("#"):
                grid[y][x] = memory.tags[0][1]  # Use first char after #
            else:
                grid[y][x] = memory.content[0].upper() if memory.content else "M"
        
        # Mark current dimension and device
        d = CONFIG["dimension"] % 9
        v = CONFIG["device"] % 9
        if 0 <= d < 9 and 0 <= v < 9:
            grid[v][d] = "X"
        
        # Add grid to header
        header.append(f"# APIs: {' | '.join(api_status)}")
        header.append(f"#{'=' * 78}#")
        
        # Add 9x9 grid
        for row in grid:
            header.append("# " + " ".join(row) + " #")
        
        header.append(f"#{'=' * 78}#")
        
        return "\n".join(header)
    
    def clear_screen(self):
        """Clear the terminal screen based on platform"""
        os.system('cls' if os.name == 'nt' else 'clear')
    
    def start_cursor_animation(self):
        """Start the animated cursor in a separate thread"""
        if not CONFIG["cursor_active"]:
            return
            
        def animate_cursor():
            while self.running and CONFIG["cursor_active"]:
                # Don't actually print anything here - we'll update during input
                time.sleep(0.1)
                
        self.cursor.start()
        self.cursor_thread = threading.Thread(target=animate_cursor)
        self.cursor_thread.daemon = True
        self.cursor_thread.start()
        
    def stop_cursor_animation(self):
        """Stop the animated cursor"""
        self.cursor.stop()
        if self.cursor_thread:
            self.cursor_thread.join(timeout=1)
            
    def get_prompt(self) -> str:
        """Get colorized prompt with animated cursor"""
        dim = CONFIG["dimension"]
        drive = list(Memory.DRIVE_SYSTEMS.keys())[min(CONFIG["device"], len(Memory.DRIVE_SYSTEMS)-1)]
        
        # Base prompt with dimension and drive
        if CONFIG["color_mode"]:
            prompt = f"{Colors.colorize_dimension(dim)}:{Colors.colorize_drive(drive)}> "
        else:
            prompt = f"D{dim}:{drive}> "
            
        # Add animated cursor if active
        if CONFIG["cursor_active"] and self.cursor.active:
            cursor_frame = self.cursor.next_frame()
            if CONFIG["color_mode"]:
                cursor_frame = Colors.colorize(cursor_frame, Colors.BRIGHT_CYAN)
            prompt = f"{cursor_frame} {prompt}"
            
        return prompt
        
    def run(self):
        self.running = True
        self.load_state()
        self.start_api_check_thread()
        self.start_cursor_animation()
        
        # Organize wishes by date for daily pinpointing
        for wish in self.wishes:
            if wish.pinpoint_date not in self.daily_wishes:
                self.daily_wishes[wish.pinpoint_date] = []
            self.daily_wishes[wish.pinpoint_date].append(wish.id)
        
        # Windows terminal setup for special keys
        try:
            import msvcrt
            windows_terminal = True
        except ImportError:
            windows_terminal = False
        
        self.clear_screen()
        header = self.display_header()
        
        # Add colorized welcome text
        welcome_lines = []
        if CONFIG["color_mode"]:
            welcome_lines.append(Colors.colorize("# Type 'help' for available commands", Colors.BRIGHT_GREEN))
            welcome_lines.append(Colors.colorize("# Press Enter to use the active shared line", Colors.BRIGHT_YELLOW))
            welcome_lines.append(Colors.rainbow("# WISH CONSOLE - MEMORY SYSTEM"))
        else:
            welcome_lines.append("# Type 'help' for available commands")
            welcome_lines.append("# Press Enter to use the active shared line")
            welcome_lines.append("# WISH CONSOLE - MEMORY SYSTEM")
        
        print(header)
        for line in welcome_lines:
            print(line)
        print()
        
        if self.shared_lines:
            print(self.display_footer())
        
        try:
            while self.running:
                try:
                    # Get prompt with possible animation
                    prompt = self.get_prompt()
                    command = input(prompt)
                    
                    # Handle special commands based on empty input (Enter key)
                    if not command.strip():
                        if self.shared_lines:
                            result = self.use_active_line()
                            self.clear_screen()
                            print(self.display_header())
                            print(result)
                            print(self.display_footer())
                        continue
                    
                    # Check for navigation commands
                    if command.lower() == "up":
                        self.navigate_shared_lines(-1)
                        self.clear_screen()
                        print(self.display_header())
                        print(self.display_footer())
                        continue
                        
                    elif command.lower() == "down":
                        self.navigate_shared_lines(1)
                        self.clear_screen()
                        print(self.display_header())
                        print(self.display_footer())
                        continue
                    
                    elif command.lower() == "add":
                        new_line = input(Colors.colorize("Enter new shared line: ", Colors.BRIGHT_GREEN) if CONFIG["color_mode"] else "Enter new shared line: ")
                        if new_line.strip():
                            self.add_shared_line(new_line)
                        self.clear_screen()
                        print(self.display_header())
                        print(self.display_footer())
                        continue
                    
                    # Process normal command
                    response = self.process_command(command)
                    
                    self.clear_screen()
                    print(self.display_header())
                    
                    # Colorize response headers if in color mode
                    if CONFIG["color_mode"] and response.startswith("#"):
                        lines = response.split("\n")
                        colorized_lines = []
                        
                        for line in lines:
                            if line.startswith("# "):
                                # Headers - bright cyan
                                if "=" in line or "-" in line:
                                    colorized_lines.append(Colors.colorize(line, Colors.BRIGHT_CYAN))
                                # Normal headers - green
                                else:
                                    colorized_lines.append(Colors.colorize(line, Colors.GREEN))
                            # Memory ID and tags with color
                            elif "mem_" in line and any(tag in line for tag in Memory.TAG_TYPES):
                                # Find and colorize tags
                                for tag in Memory.TAG_TYPES:
                                    if tag in line:
                                        line = line.replace(tag, Colors.colorize_tag(tag))
                                colorized_lines.append(line)
                            else:
                                colorized_lines.append(line)
                                
                        print("\n".join(colorized_lines))
                    else:
                        print(response)
                    
                    if self.shared_lines:
                        print(self.display_footer())
                    
                    if command.lower() in ["exit", "quit", "q"]:
                        break
                except Exception as e:
                    # Handle internal errors with color if enabled
                    if CONFIG["color_mode"]:
                        print(Colors.colorize(f"# ERROR: {str(e)}", Colors.RED))
                    else:
                        print(f"# ERROR: {str(e)}")
                        
        except KeyboardInterrupt:
            print("\n# Exiting Wish Console...")
        finally:
            self.save_state()
            self.stop_api_check_thread()
            self.stop_cursor_animation()

# ------[ MAIN EXECUTION ]------
if __name__ == "__main__":
    console = WishConsole()
    console.run()