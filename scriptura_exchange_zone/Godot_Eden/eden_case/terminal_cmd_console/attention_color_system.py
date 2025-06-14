#!/usr/bin/env python3
# Attention Color System - Manages attention rounds and color-based data processing
# Integrates with sensory_layer_system and twelve_turns_system for comprehensive experience

import os
import sys
import time
import json
import random
import math
import threading
import colorsys
from datetime import datetime
from typing import Dict, List, Any, Optional, Tuple, Set, Union, Callable

# Try to import from other modules
try:
    from sensory_layer_system import CONFIG as SENSORY_CONFIG
    SENSORY_AVAILABLE = True
except ImportError:
    SENSORY_AVAILABLE = False
    SENSORY_CONFIG = {}

try:
    from twelve_turns_system import CONFIG as TURNS_CONFIG
    TURNS_AVAILABLE = True
except ImportError:
    TURNS_AVAILABLE = False
    TURNS_CONFIG = {}

# Constants
CONFIG = {
    "attention_rounds": 9,         # Number of attention rounds
    "round_duration": 60,          # Seconds per attention round
    "attention_decay_rate": 0.03,  # Rate at which attention decays
    "data_pool_size": 1000,        # Maximum size of data pool
    "data_pool_clean_interval": 300, # Clean data pool every 5 minutes
    "two_way_looking": True,       # Enable looking at data from two perspectives
    "reason_tags_enabled": True,   # Enable reason tags for data items
    "color_palette_size": 9,       # Number of colors in palette
    "color_palettes": {            # Predefined color palettes
        "standard": [              # Standard colors
            "#0000FF",  # Blue
            "#FF0000",  # Red
            "#00FF00",  # Green
            "#FFFFFF",  # White
            "#000000",  # Black
            "#FFFF00",  # Yellow
            "#FF00FF",  # Magenta
            "#00FFFF",  # Cyan
            "#FFA500"   # Orange
        ],
        "heaven": [                # Heaven-inspired palette
            "#87CEEB",  # Sky Blue
            "#E0FFFF",  # Light Cyan
            "#FFFFFF",  # White
            "#F0FFFF",  # Azure
            "#FFFAFA",  # Snow
            "#F8F8FF",  # Ghost White
            "#E6E6FA",  # Lavender
            "#B0E0E6",  # Powder Blue
            "#FFEFD5"   # Papaya Whip
        ],
        "hell": [                  # Hell-inspired palette
            "#8B0000",  # Dark Red
            "#FF0000",  # Red
            "#B22222",  # Fire Brick
            "#A52A2A",  # Brown
            "#800000",  # Maroon
            "#A0522D",  # Sienna
            "#FF8C00",  # Dark Orange
            "#FF4500",  # Orange Red
            "#CD5C5C"   # Indian Red
        ],
        "neutral": [               # Neutral palette
            "#808080",  # Gray
            "#A9A9A9",  # Dark Gray
            "#C0C0C0",  # Silver
            "#D3D3D3",  # Light Gray
            "#DCDCDC",  # Gainsboro
            "#F5F5F5",  # White Smoke
            "#F5F5DC",  # Beige
            "#E8E8E8",  # Light Silver
            "#D8D8D8"   # Lighter Silver
        ]
    },
    "active_palette": "standard",  # Currently active color palette
    "color_meaning_shift_rate": 0.01, # Rate at which color meanings shift over time
    "attention_visualization_enabled": True, # Enable visualization of attention
    "funny_data_probability": 0.15, # Probability of generating "funny" data
    "experience_length": 8,        # Hours of simulated experience
    "preparation_time": 30,        # Minutes of preparation time
    "data_meaning_evolution": True, # Allow data meanings to evolve over time
    "debug_mode": False,           # Show debug information
    "offline_mode": True,          # Work without external dependencies
    "save_interval": 300,          # Save state every 5 minutes
    "reason_levels": 5,            # Levels of reasoning (1-5)
    "reason_prefix_counts": {      # Number of # prefixes for each reason level
        1: 1,                      # Level 1: #
        2: 2,                      # Level 2: ##
        3: 3,                      # Level 3: ###
        4: 4,                      # Level 4: ####
        5: 5                       # Level 5: #####
    }
}

# Color names for readability
COLOR_NAMES = {
    "#0000FF": "Blue",
    "#FF0000": "Red",
    "#00FF00": "Green",
    "#FFFFFF": "White",
    "#000000": "Black",
    "#FFFF00": "Yellow",
    "#FF00FF": "Magenta",
    "#00FFFF": "Cyan",
    "#FFA500": "Orange",
    "#808080": "Gray",
    "#A9A9A9": "Dark Gray",
    "#C0C0C0": "Silver",
    "#87CEEB": "Sky Blue",
    "#E0FFFF": "Light Cyan",
    "#F0FFFF": "Azure",
    "#FFFAFA": "Snow",
    "#F8F8FF": "Ghost White",
    "#E6E6FA": "Lavender",
    "#B0E0E6": "Powder Blue",
    "#FFEFD5": "Papaya Whip",
    "#8B0000": "Dark Red",
    "#B22222": "Fire Brick",
    "#A52A2A": "Brown",
    "#800000": "Maroon",
    "#A0522D": "Sienna",
    "#FF8C00": "Dark Orange",
    "#FF4500": "Orange Red",
    "#CD5C5C": "Indian Red"
}

class DataItem:
    """Represents a single data item in the system"""
    
    def __init__(self, 
                content: str = "", 
                data_type: str = "text", 
                color: str = "#FFFFFF"):
        self.content = content
        self.data_type = data_type
        self.color = color
        self.color_name = COLOR_NAMES.get(color, "Unknown")
        self.creation_time = time.time()
        self.last_accessed = time.time()
        self.access_count = 0
        self.attention_score = 0.5
        self.meaning = ""
        self.tags: List[str] = []
        self.reason_level = 1
        self.funny = False
        self.cleaned = False
        self.connections: Dict[str, float] = {}  # id -> strength
        self.properties: Dict[str, Any] = {}
        
    def access(self) -> None:
        """Record access to this data item"""
        self.last_accessed = time.time()
        self.access_count += 1
        self.attention_score = min(1.0, self.attention_score + 0.1)
        
    def update_attention(self, decay_rate: float) -> None:
        """Update attention score with decay"""
        # Apply decay
        self.attention_score *= (1.0 - decay_rate)
        
        # Apply boost based on access recency and count
        time_factor = 1.0 / (1.0 + (time.time() - self.last_accessed) / 3600)  # Decay over hours
        count_factor = min(1.0, self.access_count / 10)  # Cap at 10 accesses
        
        boost = time_factor * 0.05 + count_factor * 0.05
        self.attention_score = min(1.0, self.attention_score + boost)
        
    def add_tag(self, tag: str) -> None:
        """Add a tag to this data item"""
        if tag not in self.tags:
            self.tags.append(tag)
            
    def parse_reason_level(self) -> None:
        """Parse reason level from tags"""
        if not CONFIG["reason_tags_enabled"]:
            return
            
        max_level = 1
        for tag in self.tags:
            if tag.startswith("#"):
                # Count consecutive # characters
                level = 0
                for char in tag:
                    if char == "#":
                        level += 1
                    else:
                        break
                        
                max_level = max(max_level, min(level, CONFIG["reason_levels"]))
                
        self.reason_level = max_level
        
    def generate_meaning(self) -> str:
        """Generate meaning for this data item"""
        # Base meaning from content
        base_meaning = f"Data about {self.content[:20]}" if self.content else "Empty data"
        
        # Adjust based on color
        color_meaning = f" with {self.color_name} significance"
        
        # Adjust based on reason level
        reason_meaning = ""
        if self.reason_level > 1:
            reason_meanings = [
                "",
                "basic understanding",
                "contextual awareness",
                "interconnected insight",
                "deep realization",
                "transcendent comprehension"
            ]
            reason_meaning = f" at {reason_meanings[self.reason_level]} level"
            
        # Combine meanings
        self.meaning = base_meaning + color_meaning + reason_meaning
        return self.meaning
        
    def shift_color_meaning(self) -> None:
        """Shift the color meaning over time"""
        if not CONFIG["data_meaning_evolution"]:
            return
            
        # Get current palette
        palette = CONFIG["color_palettes"][CONFIG["active_palette"]]
        
        # Small probability to shift color
        if random.random() < CONFIG["color_meaning_shift_rate"]:
            # Shift to adjacent color in palette
            current_index = palette.index(self.color) if self.color in palette else 0
            direction = random.choice([-1, 1])
            new_index = (current_index + direction) % len(palette)
            self.color = palette[new_index]
            self.color_name = COLOR_NAMES.get(self.color, "Unknown")
            
            # Update meaning
            self.generate_meaning()
            
    def clean(self) -> bool:
        """Clean this data item (remove noise, normalize)"""
        if self.cleaned:
            return False
            
        # Simple cleaning operations
        if self.content:
            # Remove extra whitespace
            self.content = " ".join(self.content.split())
            
            # Remove duplicate tags
            self.tags = list(set(self.tags))
            
        self.cleaned = True
        return True
        
    def make_funny(self) -> None:
        """Make this data item 'funny' in some way"""
        if self.funny:
            return
            
        # Add funny property
        self.funny = True
        
        # Apply funny transformations
        funny_transforms = [
            lambda x: f"LOL! {x} 😂",
            lambda x: f"{x} (but hilarious)",
            lambda x: f"Imagine {x} but wearing a clown nose",
            lambda x: f"{x} walks into a bar...",
            lambda x: f"If {x} was a meme"
        ]
        
        transform = random.choice(funny_transforms)
        self.content = transform(self.content)
        
        # Add funny tag
        self.add_tag("#funny")
        
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization"""
        return {
            "content": self.content,
            "data_type": self.data_type,
            "color": self.color,
            "color_name": self.color_name,
            "creation_time": self.creation_time,
            "last_accessed": self.last_accessed,
            "access_count": self.access_count,
            "attention_score": self.attention_score,
            "meaning": self.meaning,
            "tags": self.tags,
            "reason_level": self.reason_level,
            "funny": self.funny,
            "cleaned": self.cleaned,
            "connections": self.connections,
            "properties": self.properties
        }
        
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'DataItem':
        """Create data item from dictionary"""
        item = cls(
            content=data["content"],
            data_type=data["data_type"],
            color=data["color"]
        )
        
        item.color_name = data["color_name"]
        item.creation_time = data["creation_time"]
        item.last_accessed = data["last_accessed"]
        item.access_count = data["access_count"]
        item.attention_score = data["attention_score"]
        item.meaning = data["meaning"]
        item.tags = data["tags"]
        item.reason_level = data["reason_level"]
        item.funny = data["funny"]
        item.cleaned = data["cleaned"]
        item.connections = data["connections"]
        item.properties = data["properties"]
        
        return item

class AttentionRound:
    """Represents a round of attention"""
    
    def __init__(self, round_id: int, name: str = ""):
        self.round_id = round_id
        self.name = name or f"Round {round_id}"
        self.start_time = None
        self.end_time = None
        self.active = False
        self.complete = False
        self.focus_items: List[str] = []  # IDs of focused items
        self.focus_colors: List[str] = []  # Colors focused on
        self.primary_perspective = "objective"  # objective or subjective
        self.secondary_perspective = "subjective"  # subjective or objective
        self.attention_threshold = 0.6  # Threshold for focusing attention
        self.data_processed = 0
        self.insights_gained = 0
        self.notes: List[str] = []
        
    def start(self) -> None:
        """Start the attention round"""
        self.start_time = time.time()
        self.active = True
        
    def end(self) -> None:
        """End the attention round"""
        self.end_time = time.time()
        self.active = False
        self.complete = True
        
    def add_focus_item(self, item_id: str) -> None:
        """Add an item to focus list"""
        if item_id not in self.focus_items:
            self.focus_items.append(item_id)
            
    def add_focus_color(self, color: str) -> None:
        """Add a color to focus list"""
        if color not in self.focus_colors:
            self.focus_colors.append(color)
            
    def switch_perspectives(self) -> None:
        """Switch primary and secondary perspectives"""
        self.primary_perspective, self.secondary_perspective = \
            self.secondary_perspective, self.primary_perspective
            
    def add_note(self, note: str) -> None:
        """Add a note to this round"""
        self.notes.append(note)
        
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization"""
        return {
            "round_id": self.round_id,
            "name": self.name,
            "start_time": self.start_time,
            "end_time": self.end_time,
            "active": self.active,
            "complete": self.complete,
            "focus_items": self.focus_items,
            "focus_colors": self.focus_colors,
            "primary_perspective": self.primary_perspective,
            "secondary_perspective": self.secondary_perspective,
            "attention_threshold": self.attention_threshold,
            "data_processed": self.data_processed,
            "insights_gained": self.insights_gained,
            "notes": self.notes
        }
        
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'AttentionRound':
        """Create attention round from dictionary"""
        round_obj = cls(data["round_id"], data["name"])
        
        round_obj.start_time = data["start_time"]
        round_obj.end_time = data["end_time"]
        round_obj.active = data["active"]
        round_obj.complete = data["complete"]
        round_obj.focus_items = data["focus_items"]
        round_obj.focus_colors = data["focus_colors"]
        round_obj.primary_perspective = data["primary_perspective"]
        round_obj.secondary_perspective = data["secondary_perspective"]
        round_obj.attention_threshold = data["attention_threshold"]
        round_obj.data_processed = data["data_processed"]
        round_obj.insights_gained = data["insights_gained"]
        round_obj.notes = data["notes"]
        
        return round_obj

class DataPool:
    """Manages a pool of data items"""
    
    def __init__(self, max_size: int = 1000):
        self.max_size = max_size
        self.items: Dict[str, DataItem] = {}  # id -> DataItem
        self.item_count = 0
        self.last_cleaned = time.time()
        self.clean_interval = CONFIG["data_pool_clean_interval"]
        self.total_attention = 0.0
        self.attention_distribution: Dict[str, float] = {}  # id -> attention portion
        self.color_distribution: Dict[str, int] = {}  # color -> count
        
    def add_item(self, item: DataItem) -> str:
        """Add a data item to the pool and return its ID"""
        # Generate ID
        item_id = f"data_{len(self.items)}_{int(time.time())}"
        
        # Clean up if at max size
        if len(self.items) >= self.max_size:
            self._clean_oldest()
            
        # Add to pool
        self.items[item_id] = item
        self.item_count += 1
        
        # Update color distribution
        self.color_distribution[item.color] = self.color_distribution.get(item.color, 0) + 1
        
        # Return ID
        return item_id
        
    def get_item(self, item_id: str) -> Optional[DataItem]:
        """Get a data item by ID"""
        item = self.items.get(item_id)
        
        if item:
            # Record access
            item.access()
            
        return item
        
    def update_attention(self) -> None:
        """Update attention scores for all items"""
        # Skip if no items
        if not self.items:
            return
            
        # Update each item
        for item in self.items.values():
            item.update_attention(CONFIG["attention_decay_rate"])
            
        # Calculate total attention
        self.total_attention = sum(item.attention_score for item in self.items.values())
        
        # Calculate attention distribution
        if self.total_attention > 0:
            self.attention_distribution = {
                item_id: item.attention_score / self.total_attention
                for item_id, item in self.items.items()
            }
            
    def clean(self, force: bool = False) -> int:
        """Clean data pool, return number of items cleaned"""
        current_time = time.time()
        
        # Skip if not time to clean yet, unless forced
        if not force and current_time - self.last_cleaned < self.clean_interval:
            return 0
            
        cleaned_count = 0
        
        # Clean each item
        for item in self.items.values():
            if item.clean():
                cleaned_count += 1
                
        # Update last cleaned time
        self.last_cleaned = current_time
        
        return cleaned_count
        
    def _clean_oldest(self) -> None:
        """Remove oldest items when pool is full"""
        # Skip if not at max size
        if len(self.items) < self.max_size:
            return
            
        # Sort by creation time
        sorted_items = sorted(
            self.items.items(),
            key=lambda x: x[1].creation_time
        )
        
        # Remove oldest 10% or at least 1
        remove_count = max(1, int(len(self.items) * 0.1))
        
        for i in range(remove_count):
            if i < len(sorted_items):
                item_id, item = sorted_items[i]
                if item_id in self.items:
                    # Update color distribution
                    if item.color in self.color_distribution:
                        self.color_distribution[item.color] -= 1
                        if self.color_distribution[item.color] <= 0:
                            del self.color_distribution[item.color]
                            
                    # Remove item
                    del self.items[item_id]
                    
    def get_high_attention_items(self, threshold: float = 0.6, limit: int = 10) -> List[Tuple[str, DataItem]]:
        """Get items with attention score above threshold"""
        high_attention = [
            (item_id, item) for item_id, item in self.items.items()
            if item.attention_score >= threshold
        ]
        
        # Sort by attention score (highest first)
        sorted_items = sorted(high_attention, key=lambda x: x[1].attention_score, reverse=True)
        
        # Return limited number
        return sorted_items[:limit]
        
    def get_items_by_color(self, color: str) -> List[Tuple[str, DataItem]]:
        """Get items with specified color"""
        return [
            (item_id, item) for item_id, item in self.items.items()
            if item.color == color
        ]
        
    def get_items_by_tag(self, tag: str) -> List[Tuple[str, DataItem]]:
        """Get items with specified tag"""
        return [
            (item_id, item) for item_id, item in self.items.items()
            if tag in item.tags
        ]
        
    def get_items_by_reason_level(self, level: int) -> List[Tuple[str, DataItem]]:
        """Get items with specified reason level"""
        return [
            (item_id, item) for item_id, item in self.items.items()
            if item.reason_level == level
        ]
        
    def get_funny_items(self) -> List[Tuple[str, DataItem]]:
        """Get all funny items"""
        return [
            (item_id, item) for item_id, item in self.items.items()
            if item.funny
        ]
        
    def generate_color_report(self) -> Dict[str, Any]:
        """Generate a report on color distribution"""
        # Skip if no items
        if not self.items:
            return {"total": 0, "colors": {}}
            
        # Count by color name
        color_counts = {}
        for item in self.items.values():
            color_name = item.color_name
            color_counts[color_name] = color_counts.get(color_name, 0) + 1
            
        # Calculate percentages
        total = sum(color_counts.values())
        color_percentages = {
            color: (count / total) * 100
            for color, count in color_counts.items()
        }
        
        # Sort by count (highest first)
        sorted_colors = sorted(
            color_counts.items(),
            key=lambda x: x[1],
            reverse=True
        )
        
        return {
            "total": total,
            "colors": color_counts,
            "percentages": color_percentages,
            "sorted": sorted_colors
        }
        
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization"""
        return {
            "max_size": self.max_size,
            "items": {
                item_id: item.to_dict() 
                for item_id, item in self.items.items()
            },
            "item_count": self.item_count,
            "last_cleaned": self.last_cleaned,
            "clean_interval": self.clean_interval,
            "total_attention": self.total_attention,
            "color_distribution": self.color_distribution
        }

class AttentionColorSystem:
    """Main system for managing attention rounds and color processing"""
    
    def __init__(self):
        # System state
        self.running = False
        self.rounds: List[AttentionRound] = []
        self.current_round_index = 0
        self.current_round: Optional[AttentionRound] = None
        self.data_pool = DataPool(CONFIG["data_pool_size"])
        self.round_thread = None
        self.current_palette = CONFIG["color_palettes"][CONFIG["active_palette"]]
        self.last_update = time.time()
        self.last_save = time.time()
        self.experience_start_time = None
        self.preparation_complete = False
        self.connections_to_turns = {}  # Map to Twelve Turns System
        self.connections_to_sensory = {}  # Map to Sensory Layer System
        self.stats = {
            "data_items_created": 0,
            "data_items_accessed": 0,
            "data_items_cleaned": 0,
            "attention_rounds_completed": 0,
            "perspectives_switched": 0,
            "funny_data_generated": 0,
            "color_meanings_shifted": 0,
            "high_reason_items": 0
        }
        
        # Initialize attention rounds
        self._init_rounds()
        
    def _init_rounds(self) -> None:
        """Initialize attention rounds"""
        self.rounds = []
        
        for i in range(CONFIG["attention_rounds"]):
            # Create round with name
            round_obj = AttentionRound(i, f"Round {i+1}")
            
            # Set perspectives (alternate)
            if i % 2 == 0:
                round_obj.primary_perspective = "objective"
                round_obj.secondary_perspective = "subjective"
            else:
                round_obj.primary_perspective = "subjective"
                round_obj.secondary_perspective = "objective"
                
            # Add to rounds list
            self.rounds.append(round_obj)
            
        # Set current round
        self.current_round_index = 0
        self.current_round = self.rounds[0]
        
    def start(self) -> bool:
        """Start the attention color system"""
        if self.running:
            return True  # Already running
            
        # Record experience start time
        self.experience_start_time = time.time()
        
        # Set running flag
        self.running = True
        
        # Start current round
        self.current_round.start()
        
        # Start round processing thread
        self.round_thread = threading.Thread(target=self._round_processing_thread)
        self.round_thread.daemon = True
        self.round_thread.start()
        
        return True
        
    def stop(self) -> None:
        """Stop the attention color system"""
        self.running = False
        
        # Wait for thread to end
        if self.round_thread:
            self.round_thread.join(timeout=1.0)
            
        # Save state before exiting
        self._save_state()
        
    def _round_processing_thread(self) -> None:
        """Thread for processing attention rounds"""
        last_clean = time.time()
        
        while self.running:
            current_time = time.time()
            
            # Check for preparation time
            if not self.preparation_complete:
                prep_elapsed = current_time - self.experience_start_time
                prep_duration = CONFIG["preparation_time"] * 60  # Convert to seconds
                
                if prep_elapsed >= prep_duration:
                    self.preparation_complete = True
                    self._prepare_complete()
                else:
                    # Still in preparation phase
                    time.sleep(0.1)
                    continue
                    
            # Check if current round should end
            if (self.current_round and self.current_round.active and 
                current_time - self.current_round.start_time >= CONFIG["round_duration"]):
                self.advance_round()
                
            # Clean data pool periodically
            if current_time - last_clean >= CONFIG["data_pool_clean_interval"]:
                cleaned_count = self.data_pool.clean()
                self.stats["data_items_cleaned"] += cleaned_count
                last_clean = current_time
                
            # Update data pool attention
            self.data_pool.update_attention()
            
            # Save state periodically
            if current_time - self.last_save >= CONFIG["save_interval"]:
                self._save_state()
                self.last_save = current_time
                
            # Check for experience end time
            if self.experience_start_time:
                experience_elapsed = current_time - self.experience_start_time
                total_duration = CONFIG["experience_length"] * 3600  # Convert to seconds
                
                if experience_elapsed >= total_duration:
                    self.running = False
                    break
                    
            # Sleep to reduce CPU usage
            time.sleep(0.1)
            
    def _prepare_complete(self) -> None:
        """Handle completion of preparation phase"""
        # Generate initial data items
        self._generate_initial_data()
        
        # Log preparation complete
        print(f"Preparation phase complete after {CONFIG['preparation_time']} minutes.")
        print(f"Beginning attention rounds with {len(self.data_pool.items)} initial data items.")
        print(f"Experience will last for {CONFIG['experience_length']} hours.")
        
    def _generate_initial_data(self) -> None:
        """Generate initial data items for the pool"""
        # Create some items for each color in the palette
        for color in self.current_palette:
            for i in range(5):  # 5 items per color
                # Generate content
                color_name = COLOR_NAMES.get(color, "Unknown")
                content = f"Initial data about {color_name} color experience"
                
                # Create data item
                item = DataItem(content, "text", color)
                
                # Add tags
                item.add_tag(f"#{color_name.lower()}")
                item.add_tag("#initial")
                
                # Add reason level
                reason_level = random.randint(1, 3)  # Initial items have low-mid reason levels
                reason_tag = "#" * reason_level
                item.add_tag(f"{reason_tag}reason")
                item.parse_reason_level()
                
                # Generate meaning
                item.generate_meaning()
                
                # Make some items funny
                if random.random() < CONFIG["funny_data_probability"]:
                    item.make_funny()
                    self.stats["funny_data_generated"] += 1
                    
                # Add to pool
                self.data_pool.add_item(item)
                self.stats["data_items_created"] += 1
                
    def advance_round(self) -> bool:
        """Advance to the next attention round"""
        # End current round
        if self.current_round:
            if self.current_round.active:
                self.current_round.end()
                self.stats["attention_rounds_completed"] += 1
                
        # Move to next round
        self.current_round_index = (self.current_round_index + 1) % len(self.rounds)
        
        # Set new current round
        self.current_round = self.rounds[self.current_round_index]
        
        # Start the new round
        self.current_round.start()
        
        # Focus on high attention items
        self._focus_on_high_attention()
        
        return True
        
    def _focus_on_high_attention(self) -> None:
        """Focus on items with high attention scores"""
        # Get high attention items
        high_attention = self.data_pool.get_high_attention_items(
            self.current_round.attention_threshold
        )
        
        # Add to focus items
        for item_id, item in high_attention:
            self.current_round.add_focus_item(item_id)
            self.current_round.add_focus_color(item.color)
            
        # Update round stats
        self.current_round.data_processed = len(high_attention)
        
        # Add note about focus
        if high_attention:
            self.current_round.add_note(
                f"Focusing on {len(high_attention)} high attention items "
                f"with {len(set(item.color for _, item in high_attention))} colors"
            )
            
    def switch_perspectives(self) -> None:
        """Switch primary and secondary perspectives"""
        if self.current_round:
            self.current_round.switch_perspectives()
            self.stats["perspectives_switched"] += 1
            
    def add_data_item(self, 
                     content: str, 
                     data_type: str = "text", 
                     tags: List[str] = None) -> str:
        """Add a data item to the pool"""
        # Skip empty content
        if not content:
            return ""
            
        # Choose color based on content sentiment (simple version)
        color = self._choose_color_for_content(content)
        
        # Create data item
        item = DataItem(content, data_type, color)
        
        # Add tags
        if tags:
            for tag in tags:
                item.add_tag(tag)
                
        # Add color tag
        color_name = COLOR_NAMES.get(color, "Unknown")
        item.add_tag(f"#{color_name.lower()}")
        
        # Parse reason level from tags
        item.parse_reason_level()
        
        # Generate meaning
        item.generate_meaning()
        
        # Make funny occasionally
        if random.random() < CONFIG["funny_data_probability"]:
            item.make_funny()
            self.stats["funny_data_generated"] += 1
            
        # Track high reason items
        if item.reason_level >= 4:
            self.stats["high_reason_items"] += 1
            
        # Add to pool
        item_id = self.data_pool.add_item(item)
        self.stats["data_items_created"] += 1
        
        return item_id
        
    def _choose_color_for_content(self, content: str) -> str:
        """Choose a color for content based on simple sentiment analysis"""
        # Default to random color from palette
        if not content:
            return random.choice(self.current_palette)
            
        # Simple keyword matching for colors
        content_lower = content.lower()
        
        # Check for color names in content
        for color, name in COLOR_NAMES.items():
            if name.lower() in content_lower:
                # If color is in our palette, use it
                if color in self.current_palette:
                    return color
                    
        # Sentiment-based selection (very simplistic)
        positive_words = {"good", "great", "happy", "excellent", "positive", "joy", "beautiful"}
        negative_words = {"bad", "terrible", "sad", "awful", "negative", "gloomy", "ugly"}
        thoughtful_words = {"think", "reason", "logic", "analyze", "consider", "reflect", "ponder"}
        emotional_words = {"feel", "emotion", "heart", "love", "hate", "anger", "fear"}
        
        # Count word occurrences
        positive_count = sum(1 for word in content_lower.split() if word in positive_words)
        negative_count = sum(1 for word in content_lower.split() if word in negative_words)
        thoughtful_count = sum(1 for word in content_lower.split() if word in thoughtful_words)
        emotional_count = sum(1 for word in content_lower.split() if word in emotional_words)
        
        # Determine dominant sentiment
        max_count = max(positive_count, negative_count, thoughtful_count, emotional_count)
        
        if max_count == 0:
            # No clear sentiment, choose random
            return random.choice(self.current_palette)
            
        if max_count == positive_count:
            # Positive sentiment - blues, greens, yellows
            possible_colors = ["#0000FF", "#00FF00", "#FFFF00", "#87CEEB", "#E0FFFF"]
        elif max_count == negative_count:
            # Negative sentiment - reds, blacks, browns
            possible_colors = ["#FF0000", "#000000", "#8B0000", "#A52A2A", "#800000"]
        elif max_count == thoughtful_count:
            # Thoughtful - purples, blues, silvers
            possible_colors = ["#800080", "#0000FF", "#C0C0C0", "#9B59B6", "#6495ED"]
        else:  # emotional_count
            # Emotional - reds, pinks, oranges
            possible_colors = ["#FF0000", "#FF00FF", "#FFA500", "#FF69B4", "#FF4500"]
            
        # Filter to colors in current palette
        palette_colors = [c for c in possible_colors if c in self.current_palette]
        
        if palette_colors:
            return random.choice(palette_colors)
        else:
            return random.choice(self.current_palette)
            
    def process_text(self, text: str, reason_tags: List[str] = None) -> List[str]:
        """Process text into multiple data items"""
        if not text:
            return []
            
        # Split into sentences
        sentences = [s.strip() for s in text.split(".") if s.strip()]
        
        # Process each sentence
        item_ids = []
        for sentence in sentences:
            # Skip very short sentences
            if len(sentence) < 5:
                continue
                
            # Create tags list from reason_tags
            tags = reason_tags.copy() if reason_tags else []
            
            # Extract any hashtags in the sentence
            words = sentence.split()
            for word in words:
                if word.startswith("#"):
                    tags.append(word)
                    
            # Add data item
            item_id = self.add_data_item(sentence, "text", tags)
            if item_id:
                item_ids.append(item_id)
                
        return item_ids
        
    def get_data_item(self, item_id: str) -> Optional[DataItem]:
        """Get a data item by ID"""
        item = self.data_pool.get_item(item_id)
        
        if item:
            self.stats["data_items_accessed"] += 1
            
        return item
        
    def clean_data_pool(self, force: bool = False) -> int:
        """Clean the data pool, return number of items cleaned"""
        cleaned = self.data_pool.clean(force)
        self.stats["data_items_cleaned"] += cleaned
        return cleaned
        
    def change_color_palette(self, palette_name: str) -> bool:
        """Change the active color palette"""
        if palette_name not in CONFIG["color_palettes"]:
            return False
            
        CONFIG["active_palette"] = palette_name
        self.current_palette = CONFIG["color_palettes"][palette_name]
        
        # Add note to current round
        if self.current_round:
            self.current_round.add_note(f"Changed color palette to {palette_name}")
            
        return True
        
    def look_at_data(self, perspective: str = None) -> Dict[str, Any]:
        """Look at current data from specified perspective"""
        if not CONFIG["two_way_looking"]:
            return {"error": "Two-way looking is not enabled"}
            
        # Use current round's primary perspective if not specified
        if not perspective and self.current_round:
            perspective = self.current_round.primary_perspective
            
        # Default to objective if still not set
        perspective = perspective or "objective"
        
        # Get high attention items
        high_attention = self.data_pool.get_high_attention_items()
        
        # Analyze based on perspective
        result = {
            "perspective": perspective,
            "timestamp": datetime.now().isoformat(),
            "items_analyzed": len(high_attention),
            "insights": []
        }
        
        if perspective == "objective":
            # Objective analysis focuses on factual aspects
            
            # Count by color
            colors = {}
            for _, item in high_attention:
                colors[item.color_name] = colors.get(item.color_name, 0) + 1
                
            # Count by reason level
            reason_levels = {}
            for _, item in high_attention:
                level = item.reason_level
                reason_levels[level] = reason_levels.get(level, 0) + 1
                
            # Add insights
            result["insights"].append({
                "type": "color_distribution",
                "content": colors
            })
            
            result["insights"].append({
                "type": "reason_levels",
                "content": reason_levels
            })
            
            # Add word frequency if items exist
            if high_attention:
                word_counts = {}
                for _, item in high_attention:
                    for word in item.content.lower().split():
                        if len(word) > 3:  # Skip short words
                            word_counts[word] = word_counts.get(word, 0) + 1
                            
                # Sort by frequency
                sorted_words = sorted(word_counts.items(), key=lambda x: x[1], reverse=True)
                
                result["insights"].append({
                    "type": "word_frequency",
                    "content": sorted_words[:10]  # Top 10 words
                })
                
        else:  # subjective
            # Subjective analysis focuses on interpretive aspects
            
            # Analyze emotional tone
            tones = {}
            for _, item in high_attention:
                # Simple tone extraction
                tone = self._extract_tone(item.content)
                tones[tone] = tones.get(tone, 0) + 1
                
            # Analyze color meanings
            color_meanings = {}
            for _, item in high_attention:
                color_meaning = self._get_color_meaning(item.color)
                color_meanings[item.color_name] = color_meaning
                
            # Add insights
            result["insights"].append({
                "type": "emotional_tones",
                "content": tones
            })
            
            result["insights"].append({
                "type": "color_meanings",
                "content": color_meanings
            })
            
            # Add personal interpretations
            if high_attention:
                interpretations = []
                for _, item in high_attention:
                    interpretations.append({
                        "content": item.content,
                        "color": item.color_name,
                        "meaning": item.meaning
                    })
                    
                result["insights"].append({
                    "type": "interpretations",
                    "content": interpretations[:5]  # Limit to 5
                })
                
        # Update current round
        if self.current_round:
            self.current_round.insights_gained += 1
            
        return result
        
    def _extract_tone(self, text: str) -> str:
        """Extract emotional tone from text (simple version)"""
        if not text:
            return "neutral"
            
        text_lower = text.lower()
        
        # Simple keyword matching
        positive_words = {"happy", "good", "great", "excellent", "joy", "love", "beautiful"}
        negative_words = {"sad", "bad", "terrible", "awful", "hate", "anger", "ugly"}
        neutral_words = {"normal", "average", "typical", "standard", "moderate"}
        
        # Count occurrences
        positive_count = sum(1 for word in text_lower.split() if word in positive_words)
        negative_count = sum(1 for word in text_lower.split() if word in negative_words)
        neutral_count = sum(1 for word in text_lower.split() if word in neutral_words)
        
        # Determine dominant tone
        if positive_count > max(negative_count, neutral_count):
            return "positive"
        elif negative_count > max(positive_count, neutral_count):
            return "negative"
        elif neutral_count > 0:
            return "neutral"
        else:
            return "indeterminate"
            
    def _get_color_meaning(self, color: str) -> str:
        """Get subjective meaning of a color"""
        # Basic color meanings
        meanings = {
            "#0000FF": "Calmness, depth, stability, trust",
            "#FF0000": "Passion, energy, danger, strength",
            "#00FF00": "Growth, harmony, freshness, fertility",
            "#FFFFFF": "Purity, innocence, cleanliness, simplicity",
            "#000000": "Power, elegance, mystery, death",
            "#FFFF00": "Joy, happiness, intellect, energy",
            "#FF00FF": "Creativity, imagination, dreams, sensitivity",
            "#00FFFF": "Serenity, clarity, purification, relaxation",
            "#FFA500": "Enthusiasm, fascination, happiness, creativity",
            "#808080": "Balance, neutrality, sophistication, wisdom",
            "#A9A9A9": "Reliability, security, maturity, conservative",
            "#C0C0C0": "Sleekness, modernity, innovation, technology",
            "#87CEEB": "Tranquility, peace, openness, inspiration",
            "#E0FFFF": "Freshness, clarity, renewal, gentle energy",
            "#F0FFFF": "Purity, peace, enlightenment, transcendence",
            "#FFFAFA": "Innocence, new beginnings, perfection, cleanliness",
            "#F8F8FF": "Ethereal, spiritual, mystery, otherworldly",
            "#E6E6FA": "Feminine energy, gentleness, nostalgia, romance",
            "#B0E0E6": "Tranquility, clarity, harmony, trustworthiness",
            "#FFEFD5": "Warmth, comfort, nurturing, support",
            "#8B0000": "Intensity, passion, depth of emotion, power",
            "#B22222": "Urgency, vitality, courage, attention",
            "#A52A2A": "Stability, reliability, earthiness, foundation",
            "#800000": "Historic significance, depth, seriousness, tradition",
            "#A0522D": "Earthiness, durability, reliability, foundation",
            "#FF8C00": "Energy, enthusiasm, courage, stimulation",
            "#FF4500": "Action, adventure, vitality, confidence",
            "#CD5C5C": "Restrained passion, sophistication, grace, emotion"
        }
        
        return meanings.get(color, "Unknown meaning")
        
    def _save_state(self) -> None:
        """Save system state to file"""
        try:
            state = {
                "timestamp": datetime.now().isoformat(),
                "rounds": [round_obj.to_dict() for round_obj in self.rounds],
                "current_round_index": self.current_round_index,
                "data_pool": self.data_pool.to_dict(),
                "active_palette": CONFIG["active_palette"],
                "experience_start_time": self.experience_start_time,
                "preparation_complete": self.preparation_complete,
                "stats": self.stats
            }
            
            with open("attention_color_state.json", "w") as f:
                json.dump(state, f, indent=2)
                
            if CONFIG["debug_mode"]:
                print(f"Attention color state saved at {datetime.now().isoformat()}")
                
        except Exception as e:
            if CONFIG["debug_mode"]:
                print(f"Error saving attention color state: {e}")
                
    def get_system_visualization(self) -> str:
        """Generate a visualization of the system state"""
        result = []
        result.append("ATTENTION COLOR SYSTEM")
        result.append("=====================")
        
        # Experience information
        if self.experience_start_time:
            elapsed = time.time() - self.experience_start_time
            elapsed_hours = elapsed / 3600
            total_hours = CONFIG["experience_length"]
            percent = (elapsed_hours / total_hours) * 100
            
            result.append(f"Experience: {elapsed_hours:.1f} hours / {total_hours} hours ({percent:.1f}%)")
            
            if not self.preparation_complete:
                prep_elapsed = elapsed / 60  # Minutes
                prep_total = CONFIG["preparation_time"]
                prep_percent = (prep_elapsed / prep_total) * 100
                result.append(f"Preparation: {prep_elapsed:.1f} minutes / {prep_total} minutes ({prep_percent:.1f}%)")
                
        # Current round information
        if self.current_round:
            result.append(f"Current Round: {self.current_round.name}")
            
            # Round status
            status = "Active" if self.current_round.active else "Inactive"
            if self.current_round.complete:
                status = "Complete"
                
            result.append(f"Status: {status}")
            
            # Perspective
            result.append(f"Primary Perspective: {self.current_round.primary_perspective}")
            result.append(f"Secondary Perspective: {self.current_round.secondary_perspective}")
            
            # Focus information
            result.append(f"Focus Items: {len(self.current_round.focus_items)}")
            result.append(f"Focus Colors: {len(self.current_round.focus_colors)}")
            
            # Show focus colors
            if self.current_round.focus_colors:
                color_names = [COLOR_NAMES.get(color, "Unknown") for color in self.current_round.focus_colors]
                result.append(f"Colors in focus: {', '.join(color_names)}")
                
        # Color palette information
        result.append("")
        result.append(f"Active Palette: {CONFIG['active_palette']}")
        
        # Data pool information
        result.append("")
        result.append("DATA POOL")
        result.append("---------")
        result.append(f"Items: {len(self.data_pool.items)} / {self.data_pool.max_size}")
        
        # Color distribution
        color_report = self.data_pool.generate_color_report()
        if color_report["total"] > 0:
            result.append("Color Distribution:")
            
            for color_name, count in color_report["sorted"][:5]:  # Top 5 colors
                percentage = color_report["percentages"][color_name]
                result.append(f"  {color_name}: {count} items ({percentage:.1f}%)")
                
        # Statistics
        result.append("")
        result.append("STATISTICS")
        result.append("----------")
        result.append(f"Data Items Created: {self.stats['data_items_created']}")
        result.append(f"Data Items Accessed: {self.stats['data_items_accessed']}")
        result.append(f"Data Items Cleaned: {self.stats['data_items_cleaned']}")
        result.append(f"Attention Rounds Completed: {self.stats['attention_rounds_completed']}")
        result.append(f"Perspectives Switched: {self.stats['perspectives_switched']}")
        result.append(f"Funny Data Generated: {self.stats['funny_data_generated']}")
        result.append(f"High Reason Items: {self.stats['high_reason_items']}")
        
        return "\n".join(result)
        
    def integrate_with_sensory(self, sensory_system) -> bool:
        """Integrate with Sensory Layer System"""
        if not SENSORY_AVAILABLE:
            return False
            
        # Check if sensory system has necessary attributes
        if not hasattr(sensory_system, "layers") or not hasattr(sensory_system, "add_sensory_input"):
            return False
            
        # Store reference
        self.connections_to_sensory["system"] = sensory_system
        
        # Create mapping between attention rounds and sensory layers
        for i, round_obj in enumerate(self.rounds):
            layer_index = i % len(sensory_system.layers)
            self.connections_to_sensory[f"round_{i}"] = layer_index
            
        return True
        
    def integrate_with_turns(self, turns_system) -> bool:
        """Integrate with Twelve Turns System"""
        if not TURNS_AVAILABLE:
            return False
            
        # Check if turns system has necessary attributes
        if not hasattr(turns_system, "turns") or not hasattr(turns_system, "add_command"):
            return False
            
        # Store reference
        self.connections_to_turns["system"] = turns_system
        
        # Create mapping between attention rounds and turns
        for i, round_obj in enumerate(self.rounds):
            turn_index = i % len(turns_system.turns)
            self.connections_to_turns[f"round_{i}"] = turn_index
            
        return True

def main():
    """Main function for testing the Attention Color System"""
    print("Initializing Attention Color System...")
    system = AttentionColorSystem()
    
    # Start the system
    system.start()
    
    print("\nAttention Color System started")
    print("- Type 'quit' or 'exit' to stop")
    print("- Type 'status' to show system status")
    print("- Type 'round' to advance to next round")
    print("- Type 'switch' to switch perspectives")
    print("- Type 'look objective' or 'look subjective' to look at data")
    print("- Type 'palette NAME' to change color palette (standard, heaven, hell, neutral)")
    print("- Type 'clean' to clean the data pool")
    print("- Type anything else to process as text input")
    
    # Main loop
    try:
        while system.running:
            command = input("> ").strip()
            
            if command.lower() in ["quit", "exit"]:
                break
            elif command.lower() == "status":
                print("\n" + system.get_system_visualization())
            elif command.lower() == "round":
                system.advance_round()
                print("Advanced to next attention round")
            elif command.lower() == "switch":
                system.switch_perspectives()
                print("Switched primary and secondary perspectives")
            elif command.lower().startswith("look "):
                perspective = command.split()[1] if len(command.split()) > 1 else None
                result = system.look_at_data(perspective)
                print(f"\nLooking at data from {result['perspective']} perspective")
                print(f"Analyzed {result['items_analyzed']} items")
                
                for insight in result["insights"]:
                    print(f"\n{insight['type'].upper()}:")
                    print(insight['content'])
            elif command.lower().startswith("palette "):
                palette_name = command.split()[1] if len(command.split()) > 1 else None
                if system.change_color_palette(palette_name):
                    print(f"Changed color palette to {palette_name}")
                else:
                    print(f"Invalid palette name. Try: {', '.join(CONFIG['color_palettes'].keys())}")
            elif command.lower() == "clean":
                cleaned = system.clean_data_pool(True)
                print(f"Cleaned {cleaned} data items")
            else:
                # Extract reason tags
                words = command.split()
                reason_tags = [word for word in words if word.startswith("#")]
                
                # Process as text
                item_ids = system.process_text(command, reason_tags)
                print(f"Created {len(item_ids)} data items from text")
                
            # Update system
            time.sleep(0.1)
            
    except KeyboardInterrupt:
        print("\nExiting...")
    finally:
        # Stop system
        system.stop()
        print("Attention Color System stopped")

if __name__ == "__main__":
    main()