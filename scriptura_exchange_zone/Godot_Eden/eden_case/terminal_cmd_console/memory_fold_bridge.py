#!/usr/bin/env python3
"""
Memory Fold Bridge System

This module provides functionality for bridging between memory 
systems, handling data folding/unfolding across drives, and connecting the
symbol evolution system with existing word systems and wish engines.

Core concepts:
- Memory bridge between drives and systems
- Hashtag-based data evolution
- Fold/unfold operations for data compression
- Claude integration for memory persistence
"""

import os
import time
import json
import hashlib
import random
import re
from enum import Enum, auto
from typing import Dict, List, Optional, Set, Tuple, Union, Any, Callable
from datetime import datetime
from pathlib import Path
from threading import Thread, Lock
import subprocess

# Try to import related modules, with graceful fallback
try:
    from symbol_data_evolution import SymbolEvolution, MemoryPool, DataDimension, EvolutionStage
    SYMBOL_EVOLUTION_AVAILABLE = True
except ImportError:
    SYMBOL_EVOLUTION_AVAILABLE = False
    print("Warning: symbol_data_evolution not available, some features disabled")

try:
    import twelve_turns_system
    TWELVE_TURNS_AVAILABLE = True
except ImportError:
    TWELVE_TURNS_AVAILABLE = False
    print("Warning: twelve_turns_system not available, some features disabled")

# Constants
DEFAULT_CLAUDE_FILE = "CLAUDE.md"
DEFAULT_MEMORY_FOLD_COUNT = 3
DEFAULT_MEMORY_BRIDGES = 5
MAX_MEMORY_TRANSFER_SIZE = 10 * 1024 * 1024  # 10MB
DRIVES = ["C", "D", "E", "F", "G", "H"]
MEMORY_TAGS = ["#memory", "#evolution", "#fold", "#unfold", "#bridge", "#dimension", "#transfer", "#cycle"]
WORD_TAGS = ["#word", "#shape", "#symbol", "#wish", "#reason", "#turn", "#dream"]

class MemoryBridgeType(Enum):
    """Types of memory bridges"""
    DIRECT = auto()        # Direct connection between drives
    FOLDED = auto()        # Folded/compressed connection
    SYMBOLIC = auto()      # Symbol-based connection
    DIMENSIONAL = auto()   # Dimension-based connection
    TEMPORAL = auto()      # Time-based connection
    SEMANTIC = auto()      # Meaning-based connection
    QUANTUM = auto()       # Probability-based connection

class MemoryTransferMode(Enum):
    """Modes for memory transfer"""
    COPY = auto()          # Copy data between locations
    MOVE = auto()          # Move data between locations
    LINK = auto()          # Create connection without moving data
    FOLD = auto()          # Compress and transfer
    UNFOLD = auto()        # Transfer and decompress
    EVOLVE = auto()        # Transform during transfer

class MemoryBridge:
    """Connects memory systems and manages data transfer between them"""
    
    def __init__(self, 
                 source_drive: str, 
                 target_drive: str,
                 bridge_type: MemoryBridgeType = MemoryBridgeType.DIRECT,
                 claude_file_path: Optional[str] = None):
        """Initialize a memory bridge between drives"""
        self.source_drive = source_drive
        self.target_drive = target_drive
        self.bridge_type = bridge_type
        self.creation_time = time.time()
        self.last_transfer_time = 0
        self.transfer_count = 0
        self.total_bytes_transferred = 0
        self.active = True
        self.tags: Set[str] = set()
        self.claude_file_path = claude_file_path or self._find_claude_file()
        self.symbol_evolution = None
        self._lock = Lock()
        
        # Initialize components
        self._init_components()
    
    def _find_claude_file(self) -> str:
        """Find the CLAUDE.md file in common locations"""
        potential_paths = [
            os.path.join(os.path.expanduser("~"), DEFAULT_CLAUDE_FILE),
            os.path.join("/mnt/c/Users/Percision 15", DEFAULT_CLAUDE_FILE),
            os.path.join(".", DEFAULT_CLAUDE_FILE)
        ]
        
        for path in potential_paths:
            if os.path.exists(path):
                return path
        
        # Default to home directory
        return os.path.join(os.path.expanduser("~"), DEFAULT_CLAUDE_FILE)
    
    def _init_components(self) -> None:
        """Initialize required components"""
        # Initialize symbol evolution if available
        if SYMBOL_EVOLUTION_AVAILABLE:
            try:
                self.symbol_evolution = SymbolEvolution()
            except Exception as e:
                print(f"Error initializing symbol evolution: {e}")
    
    def transfer(self, 
                data: Any, 
                mode: MemoryTransferMode = MemoryTransferMode.COPY,
                tags: Optional[List[str]] = None) -> Dict[str, Any]:
        """Transfer data between drives"""
        with self._lock:
            # Convert data to serializable form if needed
            if not isinstance(data, (str, dict, list)):
                try:
                    data = str(data)
                except Exception:
                    data = {"data": repr(data), "type": type(data).__name__}
            
            # Create transfer metadata
            transfer_time = time.time()
            transfer_id = hashlib.md5(f"{self.source_drive}_{self.target_drive}_{transfer_time}".encode()).hexdigest()
            
            all_tags = set(tags or [])
            all_tags.update(self.tags)
            
            transfer_metadata = {
                "id": transfer_id,
                "timestamp": transfer_time,
                "source_drive": self.source_drive,
                "target_drive": self.target_drive,
                "bridge_type": self.bridge_type.name,
                "transfer_mode": mode.name,
                "size": len(json.dumps(data)) if isinstance(data, (dict, list)) else len(data),
                "tags": list(all_tags)
            }
            
            # Apply transfer mode
            if mode == MemoryTransferMode.FOLD:
                # Apply folding (data compression)
                folded_data = self._fold_data(data)
                transfer_metadata["folded"] = True
                transfer_metadata["fold_factor"] = folded_data.get("fold_factor", 1)
                processed_data = folded_data
            
            elif mode == MemoryTransferMode.UNFOLD:
                # Unfold data if it was previously folded
                is_folded = isinstance(data, dict) and data.get("_folded", False)
                if is_folded:
                    unfolded_data = self._unfold_data(data)
                    transfer_metadata["unfolded"] = True
                    processed_data = unfolded_data
                else:
                    transfer_metadata["error"] = "Data was not folded"
                    processed_data = data
            
            elif mode == MemoryTransferMode.EVOLVE:
                # Transform data during transfer
                evolved_data = self._evolve_data(data)
                transfer_metadata["evolved"] = True
                transfer_metadata["evolution_type"] = evolved_data.get("evolution_type", "unknown")
                processed_data = evolved_data
            
            else:
                # Simple copy or move
                processed_data = data
            
            # Update bridge statistics
            self.last_transfer_time = transfer_time
            self.transfer_count += 1
            self.total_bytes_transferred += transfer_metadata["size"]
            
            # Add to symbol evolution system if available
            if self.symbol_evolution:
                # Create descriptive item
                item = {
                    "type": "memory_transfer",
                    "metadata": transfer_metadata,
                    "data_sample": self._get_data_sample(processed_data),
                    "tags": list(all_tags),
                    "timestamp": transfer_time
                }
                
                # Determine dimension based on tags
                dimension = self._determine_dimension_from_tags(all_tags)
                
                # Create pool if needed
                pool_id = f"transfer_{self.source_drive}_{self.target_drive}"
                if pool_id not in self.symbol_evolution.memory_pools:
                    self.symbol_evolution.create_pool(
                        pool_id=pool_id,
                        drive=self.target_drive,
                        dimension=dimension
                    )
                
                # Add to pool
                self.symbol_evolution.add_item(item, pool_id)
            
            # Store in Claude file for persistence
            self._store_in_claude_file(transfer_metadata, processed_data)
            
            return {
                "status": "success",
                "metadata": transfer_metadata,
                "data": processed_data
            }
    
    def _fold_data(self, data: Any) -> Dict[str, Any]:
        """Fold (compress) data for efficient transfer"""
        if isinstance(data, dict):
            # Already a dictionary, add folding metadata
            folded = {
                "_folded": True,
                "fold_factor": 2,
                "original_type": "dict",
                "folded_timestamp": time.time(),
                "data": {}
            }
            
            # Group similar keys
            key_groups = {}
            for key, value in data.items():
                # Create a category for this key
                key_type = type(value).__name__
                if key_type not in key_groups:
                    key_groups[key_type] = {}
                
                key_groups[key_type][key] = value
            
            # Store grouped data
            folded["data"] = key_groups
            
            return folded
        
        elif isinstance(data, list):
            # Group similar list items
            item_groups = {}
            for item in data:
                item_type = type(item).__name__
                if item_type not in item_groups:
                    item_groups[item_type] = []
                
                item_groups[item_type].append(item)
            
            # Create folded structure
            folded = {
                "_folded": True,
                "fold_factor": 2,
                "original_type": "list",
                "original_length": len(data),
                "folded_timestamp": time.time(),
                "data": item_groups
            }
            
            return folded
        
        elif isinstance(data, str):
            # For strings, create a simple compression
            lines = data.split("\n")
            
            # Group similar lines
            line_groups = {}
            for line in lines:
                # Create a category based on first few chars
                category = line[:5] if len(line) >= 5 else line
                if category not in line_groups:
                    line_groups[category] = []
                
                line_groups[category].append(line)
            
            # Create folded structure
            folded = {
                "_folded": True,
                "fold_factor": max(1, len(lines) // max(1, sum(len(g) for g in line_groups.values()))),
                "original_type": "string",
                "original_length": len(data),
                "line_count": len(lines),
                "folded_timestamp": time.time(),
                "data": line_groups
            }
            
            return folded
        
        else:
            # For other types, convert to string first
            folded = {
                "_folded": True,
                "fold_factor": 1,
                "original_type": type(data).__name__,
                "folded_timestamp": time.time(),
                "data": str(data)
            }
            
            return folded
    
    def _unfold_data(self, folded_data: Dict[str, Any]) -> Any:
        """Unfold previously folded data"""
        if not isinstance(folded_data, dict) or not folded_data.get("_folded", False):
            return folded_data
        
        original_type = folded_data.get("original_type", "dict")
        
        if original_type == "dict":
            # Unfold dictionary
            unfolded = {}
            for type_name, type_group in folded_data.get("data", {}).items():
                unfolded.update(type_group)
            
            return unfolded
        
        elif original_type == "list":
            # Unfold list
            unfolded = []
            for type_name, items in folded_data.get("data", {}).items():
                unfolded.extend(items)
            
            return unfolded
        
        elif original_type == "string":
            # Unfold string
            lines = []
            for category, category_lines in folded_data.get("data", {}).items():
                lines.extend(category_lines)
            
            return "\n".join(lines)
        
        else:
            # Return data as is for other types
            return folded_data.get("data", folded_data)
    
    def _evolve_data(self, data: Any) -> Dict[str, Any]:
        """Transform data during transfer, applying evolution rules"""
        evolution_type = random.choice([
            "mutation", "expansion", "contraction", 
            "fusion", "separation", "randomization"
        ])
        
        if isinstance(data, dict):
            # Apply dictionary evolution
            if evolution_type == "mutation":
                # Change values slightly
                evolved = {}
                for key, value in data.items():
                    if isinstance(value, (int, float)):
                        # Slightly modify numeric values
                        evolved[key] = value * (1 + (random.random() - 0.5) * 0.2)
                    elif isinstance(value, str) and len(value) > 5:
                        # Modify strings by adding a suffix
                        evolved[key] = value + f" [{evolution_type}]"
                    else:
                        evolved[key] = value
            
            elif evolution_type == "expansion":
                # Add new derived keys
                evolved = dict(data)
                for key, value in list(data.items()):
                    new_key = f"{key}_evolved"
                    if isinstance(value, (int, float)):
                        evolved[new_key] = value * 1.5
                    elif isinstance(value, str):
                        evolved[new_key] = f"Evolved: {value}"
                    elif isinstance(value, list):
                        evolved[new_key] = value + [f"evolved_{i}" for i in range(3)]
            
            elif evolution_type == "contraction":
                # Remove some keys
                evolved = {}
                for key, value in data.items():
                    if random.random() > 0.3:  # 70% chance to keep
                        evolved[key] = value
            
            else:
                # Default: just add evolution metadata
                evolved = dict(data)
            
        elif isinstance(data, list):
            # Apply list evolution
            if evolution_type == "mutation":
                # Modify some elements
                evolved = []
                for item in data:
                    if isinstance(item, (int, float)):
                        evolved.append(item * (1 + (random.random() - 0.5) * 0.2))
                    elif isinstance(item, str) and len(item) > 5:
                        evolved.append(f"{item} [{evolution_type}]")
                    else:
                        evolved.append(item)
            
            elif evolution_type == "expansion":
                # Add new elements
                evolved = list(data)
                num_new = max(1, len(data) // 4)
                if all(isinstance(x, (int, float)) for x in data):
                    # For numeric lists, add related numbers
                    avg = sum(data) / len(data) if data else 0
                    evolved.extend([avg * (0.8 + random.random() * 0.4) for _ in range(num_new)])
                elif all(isinstance(x, str) for x in data):
                    # For string lists, add derived strings
                    evolved.extend([f"Evolved_{i}" for i in range(num_new)])
                else:
                    # Mixed list, just duplicate some items
                    if data:
                        evolved.extend(random.choices(data, k=num_new))
            
            elif evolution_type == "contraction":
                # Remove some elements
                evolved = [item for item in data if random.random() > 0.3]  # 70% chance to keep
            
            else:
                # Default: just return original
                evolved = list(data)
            
        elif isinstance(data, str):
            # Apply string evolution
            lines = data.split("\n")
            
            if evolution_type == "mutation":
                # Modify some lines
                evolved_lines = []
                for line in lines:
                    if len(line) > 5 and random.random() > 0.7:
                        evolved_lines.append(f"{line} [{evolution_type}]")
                    else:
                        evolved_lines.append(line)
                
                evolved = "\n".join(evolved_lines)
            
            elif evolution_type == "expansion":
                # Add new lines
                evolved_lines = list(lines)
                num_new = max(1, len(lines) // 5)
                for i in range(num_new):
                    if lines:
                        base_line = random.choice(lines)
                        evolved_lines.append(f"{base_line} [expanded {i}]")
                    else:
                        evolved_lines.append(f"New evolved line {i}")
                
                evolved = "\n".join(evolved_lines)
            
            elif evolution_type == "contraction":
                # Remove some lines
                evolved_lines = [line for line in lines if random.random() > 0.3]  # 70% chance to keep
                evolved = "\n".join(evolved_lines)
            
            else:
                # Default: add an evolution marker
                evolved = f"{data}\n[Evolved: {evolution_type}]"
        
        else:
            # Default for other types: convert to string
            evolved = f"{data} [Evolved]"
        
        # Add evolution metadata
        result = {
            "evolved": True,
            "evolution_type": evolution_type,
            "original_type": type(data).__name__,
            "evolution_timestamp": time.time(),
            "bridge_id": f"{self.source_drive}_{self.target_drive}",
            "data": evolved
        }
        
        return result
    
    def _get_data_sample(self, data: Any) -> Any:
        """Get a sample of the data suitable for storage"""
        if isinstance(data, dict):
            # For dictionaries, take a few keys
            sample = {}
            keys = list(data.keys())[:5]  # First 5 keys
            for key in keys:
                sample[key] = data[key]
            
            return sample
        
        elif isinstance(data, list):
            # For lists, take first few elements
            return data[:5]
        
        elif isinstance(data, str):
            # For strings, take the first portion
            max_length = 1000
            if len(data) > max_length:
                return data[:max_length] + "..."
            return data
        
        else:
            # For other types, convert to string and sample
            data_str = str(data)
            max_length = 1000
            if len(data_str) > max_length:
                return data_str[:max_length] + "..."
            return data_str
    
    def _determine_dimension_from_tags(self, tags: Set[str]) -> DataDimension:
        """Determine the appropriate dimension based on tags"""
        # Map tags to dimensions
        tag_dimension_map = {
            "#visual": DataDimension.VISUAL,
            "#image": DataDimension.VISUAL,
            "#picture": DataDimension.VISUAL,
            
            "#text": DataDimension.TEXTUAL,
            "#word": DataDimension.TEXTUAL,
            "#string": DataDimension.TEXTUAL,
            
            "#concept": DataDimension.CONCEPTUAL,
            "#idea": DataDimension.CONCEPTUAL,
            "#thought": DataDimension.CONCEPTUAL,
            
            "#time": DataDimension.TEMPORAL,
            "#temporal": DataDimension.TEMPORAL,
            "#sequence": DataDimension.TEMPORAL,
            
            "#structure": DataDimension.STRUCTURAL,
            "#organization": DataDimension.STRUCTURAL,
            "#layout": DataDimension.STRUCTURAL,
            
            "#relation": DataDimension.RELATIONAL,
            "#connection": DataDimension.RELATIONAL,
            "#link": DataDimension.RELATIONAL,
            
            "#emergent": DataDimension.EMERGENT,
            "#new": DataDimension.EMERGENT,
            "#surprise": DataDimension.EMERGENT,
            
            "#harmonic": DataDimension.HARMONIC,
            "#resonance": DataDimension.HARMONIC,
            "#vibration": DataDimension.HARMONIC,
            
            "#composite": DataDimension.COMPOSITE,
            "#mixed": DataDimension.COMPOSITE,
            "#combined": DataDimension.COMPOSITE,
            
            "#meta": DataDimension.META,
            "#self": DataDimension.META,
            "#recursive": DataDimension.META,
            
            "#quantum": DataDimension.QUANTUM,
            "#probability": DataDimension.QUANTUM,
            "#uncertainty": DataDimension.QUANTUM,
            
            "#narrative": DataDimension.NARRATIVE,
            "#story": DataDimension.NARRATIVE,
            "#description": DataDimension.NARRATIVE
        }
        
        # Check for dimension-specific tags
        for tag in tags:
            if tag in tag_dimension_map:
                return tag_dimension_map[tag]
        
        # Default based on bridge type
        bridge_dimension_map = {
            MemoryBridgeType.DIRECT: DataDimension.TEXTUAL,
            MemoryBridgeType.FOLDED: DataDimension.STRUCTURAL,
            MemoryBridgeType.SYMBOLIC: DataDimension.CONCEPTUAL,
            MemoryBridgeType.DIMENSIONAL: DataDimension.COMPOSITE,
            MemoryBridgeType.TEMPORAL: DataDimension.TEMPORAL,
            MemoryBridgeType.SEMANTIC: DataDimension.NARRATIVE,
            MemoryBridgeType.QUANTUM: DataDimension.QUANTUM
        }
        
        return bridge_dimension_map.get(self.bridge_type, DataDimension.TEXTUAL)
    
    def _store_in_claude_file(self, metadata: Dict[str, Any], data: Any) -> bool:
        """Store transfer information in the Claude file for persistence"""
        if not self.claude_file_path or not os.path.exists(self.claude_file_path):
            return False
        
        try:
            # Read current file
            with open(self.claude_file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Prepare data summary
            data_summary = self._get_data_sample(data)
            if isinstance(data_summary, dict):
                data_str = json.dumps(data_summary, indent=2)
            elif isinstance(data_summary, list):
                data_str = "\n".join(str(item) for item in data_summary[:5])
                if len(data_summary) > 5:
                    data_str += f"\n... ({len(data_summary)} items total)"
            else:
                data_str = str(data_summary)
            
            # Create memory marker
            memory_entry = (
                f"\n<memory-bridge-transfer>\n"
                f"Source: Drive {self.source_drive}\n"
                f"Target: Drive {self.target_drive}\n"
                f"Type: {self.bridge_type.name}\n"
                f"Mode: {metadata.get('transfer_mode', 'UNKNOWN')}\n"
                f"ID: {metadata.get('id', 'unknown')}\n"
                f"Time: {datetime.fromtimestamp(metadata.get('timestamp', time.time())).strftime('%Y-%m-%d %H:%M:%S')}\n"
                f"Tags: {' '.join(metadata.get('tags', []))}\n"
                f"Data Sample:\n{data_str}\n"
                f"</memory-bridge-transfer>\n"
            )
            
            # Append to file
            with open(self.claude_file_path, 'a', encoding='utf-8') as f:
                f.write(memory_entry)
            
            return True
        except Exception as e:
            print(f"Error storing in Claude file: {e}")
            return False
    
    def extract_from_claude_file(self) -> List[Dict[str, Any]]:
        """Extract memory bridge transfers from Claude file"""
        if not self.claude_file_path or not os.path.exists(self.claude_file_path):
            return []
        
        try:
            # Read file
            with open(self.claude_file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Extract transfer blocks
            transfer_pattern = r"<memory-bridge-transfer>(.*?)</memory-bridge-transfer>"
            transfer_blocks = re.findall(transfer_pattern, content, re.DOTALL)
            
            results = []
            for block in transfer_blocks:
                # Parse block
                source_match = re.search(r"Source: Drive (\w+)", block)
                target_match = re.search(r"Target: Drive (\w+)", block)
                type_match = re.search(r"Type: (\w+)", block)
                mode_match = re.search(r"Mode: (\w+)", block)
                id_match = re.search(r"ID: (\w+)", block)
                time_match = re.search(r"Time: ([\d-]+ [\d:]+)", block)
                tags_match = re.search(r"Tags: (.*?)$", block, re.MULTILINE)
                
                if source_match and target_match:
                    # Check if it involves this bridge
                    source = source_match.group(1)
                    target = target_match.group(1)
                    
                    if (source == self.source_drive and target == self.target_drive) or \
                       (source == self.target_drive and target == self.source_drive):
                        # Extract metadata
                        transfer = {
                            "source_drive": source,
                            "target_drive": target,
                            "bridge_type": type_match.group(1) if type_match else "UNKNOWN",
                            "transfer_mode": mode_match.group(1) if mode_match else "UNKNOWN",
                            "id": id_match.group(1) if id_match else "unknown",
                            "timestamp": time_match.group(1) if time_match else "unknown",
                            "tags": tags_match.group(1).split() if tags_match else [],
                            "data_block": block
                        }
                        
                        results.append(transfer)
            
            return results
        except Exception as e:
            print(f"Error extracting from Claude file: {e}")
            return []
    
    def close(self) -> None:
        """Close the memory bridge and release resources"""
        self.active = False

class MemoryFoldManager:
    """Manages memory bridges and fold operations across drives"""
    
    def __init__(self, 
                claude_file_path: Optional[str] = None,
                fold_count: int = DEFAULT_MEMORY_FOLD_COUNT,
                bridge_count: int = DEFAULT_MEMORY_BRIDGES):
        """Initialize the memory fold manager"""
        self.claude_file_path = claude_file_path
        self.fold_count = fold_count
        self.bridge_count = bridge_count
        self.bridges: Dict[str, MemoryBridge] = {}
        self.active = True
        self.symbol_evolution = None
        self._lock = Lock()
        
        # Initialize components
        self._init_symbol_evolution()
        self._create_default_bridges()
    
    def _init_symbol_evolution(self) -> None:
        """Initialize symbol evolution if available"""
        if SYMBOL_EVOLUTION_AVAILABLE:
            try:
                self.symbol_evolution = SymbolEvolution()
            except Exception as e:
                print(f"Error initializing symbol evolution: {e}")
    
    def _create_default_bridges(self) -> None:
        """Create default memory bridges"""
        bridge_types = list(MemoryBridgeType)
        
        for i in range(min(self.bridge_count, len(DRIVES) * 2)):
            # Select drives and bridge type
            source_idx = i % len(DRIVES)
            target_idx = (i + 1) % len(DRIVES)
            bridge_type = bridge_types[i % len(bridge_types)]
            
            # Create bridge ID
            bridge_id = f"{DRIVES[source_idx]}_{DRIVES[target_idx]}_{bridge_type.name.lower()}"
            
            # Create bridge
            self.bridges[bridge_id] = MemoryBridge(
                source_drive=DRIVES[source_idx],
                target_drive=DRIVES[target_idx],
                bridge_type=bridge_type,
                claude_file_path=self.claude_file_path
            )
    
    def create_bridge(self,
                     source_drive: str,
                     target_drive: str,
                     bridge_type: MemoryBridgeType = MemoryBridgeType.DIRECT) -> Optional[str]:
        """Create a new memory bridge"""
        with self._lock:
            # Create bridge ID
            bridge_id = f"{source_drive}_{target_drive}_{bridge_type.name.lower()}"
            
            # Check if already exists
            if bridge_id in self.bridges:
                return None
            
            # Create bridge
            self.bridges[bridge_id] = MemoryBridge(
                source_drive=source_drive,
                target_drive=target_drive,
                bridge_type=bridge_type,
                claude_file_path=self.claude_file_path
            )
            
            return bridge_id
    
    def close_bridge(self, bridge_id: str) -> bool:
        """Close a memory bridge"""
        with self._lock:
            if bridge_id not in self.bridges:
                return False
            
            self.bridges[bridge_id].close()
            del self.bridges[bridge_id]
            
            return True
    
    def transfer_data(self,
                     data: Any,
                     source_drive: str,
                     target_drive: str,
                     mode: MemoryTransferMode = MemoryTransferMode.COPY,
                     tags: Optional[List[str]] = None) -> Dict[str, Any]:
        """Transfer data between drives using available bridges"""
        with self._lock:
            # Find appropriate bridge
            bridge = None
            for bridge_id, b in self.bridges.items():
                if b.source_drive == source_drive and b.target_drive == target_drive:
                    bridge = b
                    break
            
            # Create bridge if none exists
            if bridge is None:
                bridge_id = self.create_bridge(source_drive, target_drive)
                if bridge_id:
                    bridge = self.bridges[bridge_id]
            
            # Perform transfer
            if bridge:
                return bridge.transfer(data, mode, tags)
            else:
                return {
                    "status": "error",
                    "message": f"No bridge available between {source_drive} and {target_drive}"
                }
    
    def fold_data_across_drives(self, data: Any, tags: Optional[List[str]] = None) -> Dict[str, Any]:
        """Fold data and distribute across available drives"""
        with self._lock:
            if not self.bridges:
                return {
                    "status": "error",
                    "message": "No bridges available"
                }
            
            # Create results container
            results = {
                "status": "success",
                "fold_timestamp": time.time(),
                "fold_count": self.fold_count,
                "transfers": []
            }
            
            # Perform initial fold
            current_data = data
            
            # Apply progressive folding across drives
            bridges = list(self.bridges.values())
            for i in range(min(self.fold_count, len(bridges))):
                bridge = bridges[i]
                
                # Apply appropriate mode based on iteration
                if i == 0:
                    # First transfer: fold
                    mode = MemoryTransferMode.FOLD
                elif i == self.fold_count - 1:
                    # Last transfer: evolve
                    mode = MemoryTransferMode.EVOLVE
                else:
                    # Middle transfers: alternating fold/unfold
                    mode = MemoryTransferMode.FOLD if i % 2 == 0 else MemoryTransferMode.UNFOLD
                
                # Add fold-specific tags
                fold_tags = list(tags or [])
                fold_tags.append(f"#fold_{i+1}")
                
                # Perform transfer
                transfer_result = bridge.transfer(current_data, mode, fold_tags)
                
                # Update for next iteration
                if transfer_result["status"] == "success":
                    current_data = transfer_result["data"]
                    results["transfers"].append({
                        "bridge_id": f"{bridge.source_drive}_{bridge.target_drive}_{bridge.bridge_type.name.lower()}",
                        "mode": mode.name,
                        "success": True
                    })
                else:
                    results["transfers"].append({
                        "bridge_id": f"{bridge.source_drive}_{bridge.target_drive}_{bridge.bridge_type.name.lower()}",
                        "mode": mode.name,
                        "success": False,
                        "error": transfer_result.get("message", "Unknown error")
                    })
            
            # Store final result in symbol evolution if available
            if self.symbol_evolution:
                # Create a pool if needed
                pool_id = "folded_data_pool"
                if pool_id not in self.symbol_evolution.memory_pools:
                    self.symbol_evolution.create_pool(
                        pool_id=pool_id,
                        drive=bridges[-1].target_drive if bridges else "C",
                        dimension=DataDimension.COMPOSITE
                    )
                
                # Add item describing the folding process
                fold_item = {
                    "type": "folded_data",
                    "fold_count": self.fold_count,
                    "timestamp": time.time(),
                    "tags": list(tags or []) + ["#folded", "#memory_bridge"],
                    "transfers": results["transfers"],
                    "data_sample": self._get_data_sample(current_data)
                }
                
                self.symbol_evolution.add_item(fold_item, pool_id)
            
            # Set final data and status
            results["final_data"] = current_data
            
            return results
    
    def unfold_data_from_drives(self, folded_data: Any, tags: Optional[List[str]] = None) -> Dict[str, Any]:
        """Retrieve and unfold data from bridges across drives"""
        with self._lock:
            if not self.bridges:
                return {
                    "status": "error",
                    "message": "No bridges available"
                }
            
            # Create results container
            results = {
                "status": "success",
                "unfold_timestamp": time.time(),
                "unfold_count": self.fold_count,
                "transfers": []
            }
            
            # Start with the folded data
            current_data = folded_data
            
            # Apply progressive unfolding across drives
            bridges = list(reversed(list(self.bridges.values())))
            for i in range(min(self.fold_count, len(bridges))):
                bridge = bridges[i]
                
                # Apply appropriate mode based on iteration
                if i == 0:
                    # First transfer: unfold
                    mode = MemoryTransferMode.UNFOLD
                elif i == self.fold_count - 1:
                    # Last transfer: copy (to preserve original)
                    mode = MemoryTransferMode.COPY
                else:
                    # Middle transfers: alternating unfold/fold
                    mode = MemoryTransferMode.UNFOLD if i % 2 == 0 else MemoryTransferMode.FOLD
                
                # Add unfold-specific tags
                unfold_tags = list(tags or [])
                unfold_tags.append(f"#unfold_{i+1}")
                
                # Perform transfer
                transfer_result = bridge.transfer(current_data, mode, unfold_tags)
                
                # Update for next iteration
                if transfer_result["status"] == "success":
                    current_data = transfer_result["data"]
                    results["transfers"].append({
                        "bridge_id": f"{bridge.source_drive}_{bridge.target_drive}_{bridge.bridge_type.name.lower()}",
                        "mode": mode.name,
                        "success": True
                    })
                else:
                    results["transfers"].append({
                        "bridge_id": f"{bridge.source_drive}_{bridge.target_drive}_{bridge.bridge_type.name.lower()}",
                        "mode": mode.name,
                        "success": False,
                        "error": transfer_result.get("message", "Unknown error")
                    })
            
            # Set final data and status
            results["final_data"] = current_data
            
            return results
    
    def extract_hashtags_from_claude(self) -> Dict[str, Any]:
        """Extract memory-related hashtags from Claude file"""
        with self._lock:
            results = {
                "status": "success",
                "timestamp": time.time(),
                "memory_tags": [],
                "word_tags": [],
                "other_tags": []
            }
            
            # Find Claude file
            claude_file = self.claude_file_path
            if not claude_file:
                for bridge in self.bridges.values():
                    if bridge.claude_file_path and os.path.exists(bridge.claude_file_path):
                        claude_file = bridge.claude_file_path
                        break
            
            if not claude_file or not os.path.exists(claude_file):
                results["status"] = "error"
                results["message"] = "Claude file not found"
                return results
            
            try:
                # Read file
                with open(claude_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Extract hashtags
                hashtags = re.findall(r'#\w+', content)
                
                # Categorize hashtags
                for tag in hashtags:
                    if tag in MEMORY_TAGS:
                        if tag not in results["memory_tags"]:
                            results["memory_tags"].append(tag)
                    elif tag in WORD_TAGS:
                        if tag not in results["word_tags"]:
                            results["word_tags"].append(tag)
                    else:
                        if tag not in results["other_tags"]:
                            results["other_tags"].append(tag)
                
                # Process hashtags in symbol evolution if available
                if self.symbol_evolution:
                    for tag in hashtags:
                        # Find active pool or create one
                        active_pool_id = self.symbol_evolution.active_pool_id
                        if not active_pool_id and self.symbol_evolution.memory_pools:
                            active_pool_id = next(iter(self.symbol_evolution.memory_pools.keys()))
                        
                        # Add tag to active pool
                        if active_pool_id:
                            pool = self.symbol_evolution.memory_pools[active_pool_id]
                            pool.tags.add(tag)
                
                return results
            except Exception as e:
                results["status"] = "error"
                results["message"] = f"Error extracting hashtags: {e}"
                return results
    
    def process_hashtag_command(self, command: str) -> Dict[str, Any]:
        """Process hashtag-based commands"""
        with self._lock:
            results = {
                "command": command,
                "status": "success",
                "actions": []
            }
            
            # Extract command parts
            parts = command.split()
            if not parts or not parts[0].startswith("#"):
                results["status"] = "error"
                results["message"] = "Not a hashtag command"
                return results
            
            # Process commands
            if parts[0] == "#fold":
                # #fold [source] [target] [data]
                if len(parts) < 4:
                    results["status"] = "error"
                    results["message"] = "Invalid fold command format"
                    return results
                
                source = parts[1]
                target = parts[2]
                data = " ".join(parts[3:])
                
                # Extract tags
                tags = re.findall(r'#\w+', data)
                
                # Perform transfer
                transfer_result = self.transfer_data(
                    data=data,
                    source_drive=source,
                    target_drive=target,
                    mode=MemoryTransferMode.FOLD,
                    tags=tags
                )
                
                results["transfer_result"] = transfer_result
                results["actions"].append(f"Folded data from {source} to {target}")
            
            elif parts[0] == "#unfold":
                # #unfold [source] [target] [data]
                if len(parts) < 4:
                    results["status"] = "error"
                    results["message"] = "Invalid unfold command format"
                    return results
                
                source = parts[1]
                target = parts[2]
                data = " ".join(parts[3:])
                
                # Extract tags
                tags = re.findall(r'#\w+', data)
                
                # Perform transfer
                transfer_result = self.transfer_data(
                    data=data,
                    source_drive=source,
                    target_drive=target,
                    mode=MemoryTransferMode.UNFOLD,
                    tags=tags
                )
                
                results["transfer_result"] = transfer_result
                results["actions"].append(f"Unfolded data from {source} to {target}")
            
            elif parts[0] == "#bridge":
                # #bridge [source] [target] [type]
                if len(parts) < 4:
                    results["status"] = "error"
                    results["message"] = "Invalid bridge command format"
                    return results
                
                source = parts[1]
                target = parts[2]
                
                try:
                    bridge_type = MemoryBridgeType[parts[3].upper()]
                except (KeyError, IndexError):
                    bridge_type = MemoryBridgeType.DIRECT
                
                # Create bridge
                bridge_id = self.create_bridge(source, target, bridge_type)
                
                if bridge_id:
                    results["bridge_id"] = bridge_id
                    results["actions"].append(f"Created bridge from {source} to {target} of type {bridge_type.name}")
                else:
                    results["status"] = "error"
                    results["message"] = f"Bridge from {source} to {target} already exists"
            
            elif parts[0] == "#evolve":
                # #evolve [data]
                if len(parts) < 2:
                    results["status"] = "error"
                    results["message"] = "Invalid evolve command format"
                    return results
                
                data = " ".join(parts[1:])
                
                # Extract tags
                tags = re.findall(r'#\w+', data)
                
                # Use first available bridge
                if self.bridges:
                    bridge = next(iter(self.bridges.values()))
                    
                    # Perform transfer
                    transfer_result = bridge.transfer(
                        data=data,
                        mode=MemoryTransferMode.EVOLVE,
                        tags=tags
                    )
                    
                    results["transfer_result"] = transfer_result
                    results["actions"].append(f"Evolved data using bridge {bridge.source_drive} to {bridge.target_drive}")
                else:
                    results["status"] = "error"
                    results["message"] = "No bridges available"
            
            elif parts[0] == "#foldacross":
                # #foldacross [data]
                if len(parts) < 2:
                    results["status"] = "error"
                    results["message"] = "Invalid foldacross command format"
                    return results
                
                data = " ".join(parts[1:])
                
                # Extract tags
                tags = re.findall(r'#\w+', data)
                
                # Perform folding across drives
                fold_result = self.fold_data_across_drives(data, tags)
                
                results["fold_result"] = fold_result
                results["actions"].append(f"Folded data across {len(fold_result.get('transfers', []))} bridges")
            
            elif parts[0] == "#extract":
                # #extract - Extract hashtags from Claude file
                extraction_result = self.extract_hashtags_from_claude()
                
                results["extraction_result"] = extraction_result
                results["actions"].append("Extracted hashtags from Claude file")
            
            elif parts[0] == "#status":
                # #status - Report bridge status
                results["bridges"] = {}
                for bridge_id, bridge in self.bridges.items():
                    results["bridges"][bridge_id] = {
                        "source": bridge.source_drive,
                        "target": bridge.target_drive,
                        "type": bridge.bridge_type.name,
                        "active": bridge.active,
                        "transfer_count": bridge.transfer_count,
                        "total_bytes": bridge.total_bytes_transferred
                    }
                
                results["actions"].append(f"Reported status of {len(self.bridges)} bridges")
            
            elif self.symbol_evolution and parts[0] in ["#symbol", "#cycle", "#dimension"]:
                # Forward to symbol evolution
                symbol_result = self.symbol_evolution.process_hashtag_command(command)
                
                results["symbol_result"] = symbol_result
                results["actions"].append("Processed command in symbol evolution system")
            
            else:
                # Unknown command, just extract hashtags and store
                tags = re.findall(r'#\w+', command)
                
                results["extracted_tags"] = tags
                results["actions"].append(f"Extracted {len(tags)} hashtags from command")
                
                # Store in symbol evolution if available
                if self.symbol_evolution:
                    for tag in tags:
                        # Find appropriate pool based on tag
                        pools = self.symbol_evolution.find_pools_by_tag(tag)
                        if pools:
                            # Add to first matching pool
                            pool_id = pools[0]
                        elif self.symbol_evolution.active_pool_id:
                            # Add to active pool
                            pool_id = self.symbol_evolution.active_pool_id
                        elif self.symbol_evolution.memory_pools:
                            # Add to first available pool
                            pool_id = next(iter(self.symbol_evolution.memory_pools.keys()))
                        else:
                            # Create a new pool
                            pool_id = f"hashtag_pool_{tag}"
                            self.symbol_evolution.create_pool(
                                pool_id=pool_id,
                                drive=DRIVES[0],
                                dimension=DataDimension.TEXTUAL
                            )
                        
                        # Add tag to pool
                        pool = self.symbol_evolution.memory_pools[pool_id]
                        pool.tags.add(tag)
                        
                        # Add item with command text
                        item = {
                            "text": command,
                            "tags": tags,
                            "timestamp": time.time(),
                            "source": "hashtag_command"
                        }
                        
                        self.symbol_evolution.add_item(item, pool_id)
                        
                        results["actions"].append(f"Added tag {tag} to pool {pool_id}")
            
            return results
    
    def _get_data_sample(self, data: Any) -> Any:
        """Get a sample of data for storage"""
        if isinstance(data, dict):
            # Take a sample of the dictionary
            sample = {}
            keys = list(data.keys())[:5]  # First 5 keys
            for key in keys:
                sample[key] = data[key]
            
            if len(data) > 5:
                sample["..."] = f"({len(data)} keys total)"
            
            return sample
        
        elif isinstance(data, list):
            # Take a sample of the list
            if len(data) <= 5:
                return data
            else:
                return data[:5] + ["..."]
        
        elif isinstance(data, str):
            # Take a sample of the string
            max_length = 1000
            if len(data) > max_length:
                return data[:max_length] + "..."
            return data
        
        else:
            # For other types, convert to string
            data_str = str(data)
            max_length = 1000
            if len(data_str) > max_length:
                return data_str[:max_length] + "..."
            return data_str
    
    def close(self) -> None:
        """Close the manager and all bridges"""
        with self._lock:
            self.active = False
            
            for bridge in list(self.bridges.values()):
                bridge.close()
            
            self.bridges.clear()

def main():
    """Main function for CLI usage"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Memory Fold Bridge System")
    parser.add_argument("--init", action="store_true", help="Initialize the system with default bridges")
    parser.add_argument("--fold", nargs=3, metavar=('SOURCE', 'TARGET', 'DATA'), help="Fold data from source to target")
    parser.add_argument("--unfold", nargs=3, metavar=('SOURCE', 'TARGET', 'DATA'), help="Unfold data from source to target")
    parser.add_argument("--bridge", nargs=3, metavar=('SOURCE', 'TARGET', 'TYPE'), help="Create a new bridge")
    parser.add_argument("--foldacross", metavar='DATA', help="Fold data across all available bridges")
    parser.add_argument("--extract", action="store_true", help="Extract hashtags from Claude file")
    parser.add_argument("--status", action="store_true", help="Show bridge status")
    parser.add_argument("--command", metavar='CMD', help="Process a hashtag command")
    parser.add_argument("--claude", metavar='PATH', help="Path to Claude file")
    
    args = parser.parse_args()
    
    # Create manager
    manager = MemoryFoldManager(claude_file_path=args.claude)
    
    if args.init:
        print("Initializing system with default bridges...")
        manager._create_default_bridges()
    
    if args.fold:
        source, target, data = args.fold
        result = manager.transfer_data(
            data=data,
            source_drive=source,
            target_drive=target,
            mode=MemoryTransferMode.FOLD
        )
        print(f"Fold result: {result['status']}")
        if "data" in result:
            print(f"Folded data: {manager._get_data_sample(result['data'])}")
    
    if args.unfold:
        source, target, data = args.unfold
        result = manager.transfer_data(
            data=data,
            source_drive=source,
            target_drive=target,
            mode=MemoryTransferMode.UNFOLD
        )
        print(f"Unfold result: {result['status']}")
        if "data" in result:
            print(f"Unfolded data: {manager._get_data_sample(result['data'])}")
    
    if args.bridge:
        source, target, bridge_type = args.bridge
        try:
            bridge_type_enum = MemoryBridgeType[bridge_type.upper()]
        except KeyError:
            print(f"Invalid bridge type: {bridge_type}")
            bridge_type_enum = MemoryBridgeType.DIRECT
        
        bridge_id = manager.create_bridge(source, target, bridge_type_enum)
        if bridge_id:
            print(f"Bridge created: {bridge_id}")
        else:
            print(f"Bridge from {source} to {target} already exists")
    
    if args.foldacross:
        result = manager.fold_data_across_drives(args.foldacross)
        print(f"Fold across result: {result['status']}")
        print(f"Transfers: {len(result.get('transfers', []))}")
        if "final_data" in result:
            print(f"Final data: {manager._get_data_sample(result['final_data'])}")
    
    if args.extract:
        result = manager.extract_hashtags_from_claude()
        print(f"Extraction result: {result['status']}")
        if result['status'] == "success":
            print(f"Memory tags: {result.get('memory_tags', [])}")
            print(f"Word tags: {result.get('word_tags', [])}")
            print(f"Other tags: {result.get('other_tags', [])}")
    
    if args.status:
        print("Bridge Status:")
        for bridge_id, bridge in manager.bridges.items():
            print(f"- {bridge_id}:")
            print(f"  Source: Drive {bridge.source_drive}")
            print(f"  Target: Drive {bridge.target_drive}")
            print(f"  Type: {bridge.bridge_type.name}")
            print(f"  Active: {bridge.active}")
            print(f"  Transfers: {bridge.transfer_count}")
            print(f"  Bytes transferred: {bridge.total_bytes_transferred}")
    
    if args.command:
        result = manager.process_hashtag_command(args.command)
        print(f"Command result: {result['status']}")
        print(f"Actions: {', '.join(result.get('actions', []))}")
    
    # Cleanup
    manager.close()

if __name__ == "__main__":
    main()