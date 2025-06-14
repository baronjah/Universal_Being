#!/usr/bin/env python3
"""
Symbol Data Evolution System

This module provides functionality for evolving symbol data across memory pools,
implementing folding/unfolding patterns, and supporting data evolution through
stages. It connects with the symbol_reason_system and auto_repeat_connector
to provide a comprehensive framework for evolving data representations.

Core concepts:
- Memory pools with dynamic folding/unfolding
- Symbol evolution through defined stages
- Data compression and expansion patterns
- Integration with turn-based systems
- Low-resource compatibility
"""

import os
import time
import random
import hashlib
import json
from enum import Enum, auto
from typing import Dict, List, Optional, Set, Tuple, Union, Any, Callable
from datetime import datetime
from pathlib import Path
from threading import Thread, Lock
import re

# Try to import related modules, with graceful fallback
try:
    from symbol_reason_system import Symbol, Reason, IconHash, SymbolConnection
    SYMBOL_SYSTEM_AVAILABLE = True
except ImportError:
    SYMBOL_SYSTEM_AVAILABLE = False
    print("Warning: symbol_reason_system not available, some features disabled")

try:
    from auto_repeat_connector import CommandRepeat, ClaudeFileMonitor
    AUTO_REPEAT_AVAILABLE = True
except ImportError:
    AUTO_REPEAT_AVAILABLE = False
    print("Warning: auto_repeat_connector not available, some features disabled")

try:
    import twelve_turns_system
    TWELVE_TURNS_AVAILABLE = True
except ImportError:
    TWELVE_TURNS_AVAILABLE = False
    print("Warning: twelve_turns_system not available, some features disabled")

# Constants
MAX_EVOLUTION_STAGE = 91  # Maximum folding pattern (91 levels)
DEFAULT_POOL_SIZE = 12    # Default memory pool size
MEMORY_DRIVES = ["C", "D", "E", "F", "G", "H"]  # Available memory drives
DATA_FOLD_PATTERNS = [2, 3, 5, 8, 13, 21, 34, 55, 89]  # Fibonacci-based folding

class EvolutionStage(Enum):
    """Stages of symbol data evolution"""
    SEED = auto()          # Initial data seed
    GROWTH = auto()        # Early development
    SPLIT = auto()         # Data division
    MERGE = auto()         # Pattern combination
    COMBINE = auto()       # Complex integration
    EVOLVE = auto()        # Transformation
    ARCHIVE = auto()       # Long-term storage
    DESTROY = auto()       # Controlled removal
    TRANSCEND = auto()     # Beyond standard patterns
    RECYCLE = auto()       # Reintegration

class DataDimension(Enum):
    """Dimensions for data organization"""
    VISUAL = auto()        # Image-like patterns
    TEXTUAL = auto()       # Word-based patterns
    CONCEPTUAL = auto()    # Idea-based patterns
    TEMPORAL = auto()      # Time-based patterns
    STRUCTURAL = auto()    # Organization patterns
    RELATIONAL = auto()    # Connection patterns
    EMERGENT = auto()      # New/unexpected patterns
    HARMONIC = auto()      # Resonance patterns
    COMPOSITE = auto()     # Mixed-type patterns
    META = auto()          # Self-referential patterns
    QUANTUM = auto()       # Probability patterns
    NARRATIVE = auto()     # Story-based patterns

class MemoryPool:
    """A container for memory items that supports folding and unfolding operations"""
    
    def __init__(self, 
                 pool_id: str, 
                 size: int = DEFAULT_POOL_SIZE,
                 drive: str = "C",
                 dimension: DataDimension = DataDimension.TEXTUAL):
        self.pool_id = pool_id
        self.size = size
        self.drive = drive
        self.dimension = dimension
        self.items: List[Dict[str, Any]] = []
        self.folded: bool = False
        self.fold_level: int = 0
        self.last_accessed: float = time.time()
        self.evolution_stage: EvolutionStage = EvolutionStage.SEED
        self.tags: Set[str] = set()
        self.connections: Dict[str, List[str]] = {}
        self.metadata: Dict[str, Any] = {}
        self._access_lock = Lock()
    
    def add_item(self, item: Dict[str, Any]) -> bool:
        """Add an item to the memory pool"""
        with self._access_lock:
            if len(self.items) >= self.size and not self.folded:
                return False
            
            # Add evolution timestamp
            item["_evolution"] = {
                "added": time.time(),
                "stage": self.evolution_stage.name,
                "fold_level": self.fold_level,
                "dimension": self.dimension.name
            }
            
            self.items.append(item)
            self.last_accessed = time.time()
            
            # Extract tags
            if "tags" in item:
                for tag in item["tags"]:
                    if tag.startswith("#"):
                        self.tags.add(tag)
            
            return True
    
    def fold(self, levels: int = 1) -> bool:
        """Fold the memory pool to compress data"""
        with self._access_lock:
            if self.folded or levels <= 0:
                return False
            
            # Apply folding pattern based on Fibonacci numbers
            pattern_index = min(levels - 1, len(DATA_FOLD_PATTERNS) - 1)
            fold_factor = DATA_FOLD_PATTERNS[pattern_index]
            
            # Compress items based on fold_factor
            if len(self.items) > fold_factor:
                # Group items by tags
                tag_groups = {}
                for item in self.items:
                    item_tags = item.get("tags", [])
                    key = frozenset(item_tags)
                    if key not in tag_groups:
                        tag_groups[key] = []
                    tag_groups[key].append(item)
                
                # Combine similar items
                new_items = []
                for group in tag_groups.values():
                    if len(group) <= 1:
                        new_items.extend(group)
                        continue
                    
                    # Create compressed item
                    compressed = {
                        "type": "folded_group",
                        "count": len(group),
                        "sample": group[0],
                        "tags": list(group[0].get("tags", [])),
                        "fold_factor": fold_factor,
                        "original_size": sum(len(json.dumps(i)) for i in group),
                        "_folded": True,
                        "_children": group
                    }
                    new_items.append(compressed)
                
                self.items = new_items
            
            self.folded = True
            self.fold_level += levels
            self.last_accessed = time.time()
            
            # Update evolution stage
            if self.evolution_stage == EvolutionStage.SEED:
                self.evolution_stage = EvolutionStage.GROWTH
            elif self.evolution_stage == EvolutionStage.GROWTH:
                self.evolution_stage = EvolutionStage.SPLIT
            
            return True
    
    def unfold(self, levels: int = 1) -> bool:
        """Unfold the memory pool to expand data"""
        with self._access_lock:
            if not self.folded or levels <= 0 or self.fold_level < levels:
                return False
            
            # Expand folded items
            new_items = []
            for item in self.items:
                if item.get("_folded", False) and "_children" in item:
                    new_items.extend(item["_children"])
                else:
                    new_items.append(item)
            
            self.items = new_items
            self.fold_level -= levels
            self.folded = self.fold_level > 0
            self.last_accessed = time.time()
            
            # Update evolution stage
            if self.evolution_stage == EvolutionStage.SPLIT:
                self.evolution_stage = EvolutionStage.MERGE
            elif self.evolution_stage == EvolutionStage.MERGE:
                self.evolution_stage = EvolutionStage.COMBINE
            
            return True
    
    def evolve(self) -> bool:
        """Advance the evolution stage of the memory pool"""
        with self._access_lock:
            stages = list(EvolutionStage)
            current_index = stages.index(self.evolution_stage)
            
            if current_index < len(stages) - 1:
                self.evolution_stage = stages[current_index + 1]
                
                # Apply stage-specific transformations
                if self.evolution_stage == EvolutionStage.EVOLVE:
                    # Cross-pollinate tags between items
                    all_tags = set()
                    for item in self.items:
                        all_tags.update(item.get("tags", []))
                    
                    # Add some shared tags to items
                    for item in self.items:
                        if "tags" not in item:
                            item["tags"] = []
                        
                        # Add 1-3 random tags
                        potential_tags = list(all_tags - set(item.get("tags", [])))
                        num_tags = min(random.randint(1, 3), len(potential_tags))
                        new_tags = random.sample(potential_tags, num_tags) if potential_tags else []
                        item["tags"].extend(new_tags)
                
                elif self.evolution_stage == EvolutionStage.ARCHIVE:
                    # Mark items for long-term storage
                    for item in self.items:
                        item["_archived"] = True
                        item["archive_date"] = datetime.now().isoformat()
                
                elif self.evolution_stage == EvolutionStage.DESTROY:
                    # Keep only essential items
                    self.items = [item for item in self.items if item.get("essential", False)]
                
                return True
            
            return False
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert the pool to a dictionary for serialization"""
        with self._access_lock:
            return {
                "pool_id": self.pool_id,
                "size": self.size,
                "drive": self.drive,
                "dimension": self.dimension.name,
                "items_count": len(self.items),
                "folded": self.folded,
                "fold_level": self.fold_level,
                "last_accessed": self.last_accessed,
                "evolution_stage": self.evolution_stage.name,
                "tags": list(self.tags),
                "connections": self.connections,
                "metadata": self.metadata
            }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'MemoryPool':
        """Create a memory pool from a dictionary"""
        pool = cls(
            pool_id=data["pool_id"],
            size=data["size"],
            drive=data["drive"],
            dimension=DataDimension[data["dimension"]]
        )
        
        pool.folded = data["folded"]
        pool.fold_level = data["fold_level"]
        pool.last_accessed = data["last_accessed"]
        pool.evolution_stage = EvolutionStage[data["evolution_stage"]]
        pool.tags = set(data["tags"])
        pool.connections = data["connections"]
        pool.metadata = data["metadata"]
        
        return pool

class SymbolEvolution:
    """Manages the evolution of symbols across memory pools"""
    
    def __init__(self, data_directory: Optional[str] = None):
        self.memory_pools: Dict[str, MemoryPool] = {}
        self.active_pool_id: Optional[str] = None
        self.data_directory = data_directory or os.path.join(os.path.expanduser("~"), ".symbol_evolution")
        
        # Ensure data directory exists
        os.makedirs(self.data_directory, exist_ok=True)
        
        # Integration with other systems
        self.symbol_system = None
        self.command_repeat = None
        self.claude_monitor = None
        self.twelve_turns = None
        
        # Initialize integration if available
        self._init_integrations()
        
        # Create default memory pools
        self._create_default_pools()
    
    def _init_integrations(self) -> None:
        """Initialize integrations with other systems"""
        if SYMBOL_SYSTEM_AVAILABLE:
            # Use a simple proxy class if the real one isn't available
            class SymbolSystemProxy:
                def __init__(self):
                    self.symbols = {}
                
                def create_symbol(self, name, type_str, data):
                    self.symbols[name] = {"type": type_str, "data": data}
                    return True
                
                def get_symbol(self, name):
                    return self.symbols.get(name)
            
            # Use real or proxy
            try:
                if 'Symbol' in globals():
                    self.symbol_system = {
                        "Symbol": Symbol,
                        "Reason": Reason,
                        "IconHash": IconHash,
                        "SymbolConnection": SymbolConnection
                    }
                else:
                    self.symbol_system = SymbolSystemProxy()
            except NameError:
                self.symbol_system = SymbolSystemProxy()
        
        if AUTO_REPEAT_AVAILABLE:
            try:
                if 'CommandRepeat' in globals():
                    self.command_repeat = CommandRepeat()
                    self.claude_monitor = ClaudeFileMonitor()
            except NameError:
                pass
        
        if TWELVE_TURNS_AVAILABLE:
            try:
                self.twelve_turns = twelve_turns_system
            except NameError:
                pass
    
    def _create_default_pools(self) -> None:
        """Create default memory pools for each dimension"""
        dimensions = list(DataDimension)
        for i, dimension in enumerate(dimensions):
            drive = MEMORY_DRIVES[i % len(MEMORY_DRIVES)]
            pool_id = f"pool_{dimension.name.lower()}_{drive}"
            
            self.memory_pools[pool_id] = MemoryPool(
                pool_id=pool_id,
                drive=drive,
                dimension=dimension
            )
        
        # Set first pool as active
        if self.memory_pools:
            self.active_pool_id = next(iter(self.memory_pools.keys()))
    
    def create_pool(self, 
                   pool_id: str, 
                   size: int = DEFAULT_POOL_SIZE,
                   drive: str = "C",
                   dimension: DataDimension = DataDimension.TEXTUAL) -> bool:
        """Create a new memory pool"""
        if pool_id in self.memory_pools:
            return False
        
        self.memory_pools[pool_id] = MemoryPool(
            pool_id=pool_id,
            size=size,
            drive=drive,
            dimension=dimension
        )
        
        return True
    
    def delete_pool(self, pool_id: str) -> bool:
        """Delete a memory pool"""
        if pool_id not in self.memory_pools:
            return False
        
        del self.memory_pools[pool_id]
        
        if self.active_pool_id == pool_id:
            self.active_pool_id = next(iter(self.memory_pools.keys())) if self.memory_pools else None
        
        return True
    
    def set_active_pool(self, pool_id: str) -> bool:
        """Set the active memory pool"""
        if pool_id not in self.memory_pools:
            return False
        
        self.active_pool_id = pool_id
        return True
    
    def add_item(self, item: Dict[str, Any], pool_id: Optional[str] = None) -> bool:
        """Add an item to a memory pool"""
        target_pool_id = pool_id or self.active_pool_id
        
        if target_pool_id is None or target_pool_id not in self.memory_pools:
            return False
        
        return self.memory_pools[target_pool_id].add_item(item)
    
    def add_hashtag_item(self, text: str, tags: Optional[List[str]] = None) -> bool:
        """Add an item from text with hashtags"""
        if not text:
            return False
        
        # Extract hashtags from text
        extracted_tags = re.findall(r'#\w+', text)
        
        # Combine extracted and provided tags
        combined_tags = list(set(extracted_tags + (tags or [])))
        
        # Create item
        item = {
            "text": text,
            "tags": combined_tags,
            "timestamp": time.time(),
            "source": "hashtag_extraction"
        }
        
        # Add to active pool
        return self.add_item(item)
    
    def fold_pool(self, pool_id: Optional[str] = None, levels: int = 1) -> bool:
        """Fold a memory pool"""
        target_pool_id = pool_id or self.active_pool_id
        
        if target_pool_id is None or target_pool_id not in self.memory_pools:
            return False
        
        return self.memory_pools[target_pool_id].fold(levels)
    
    def unfold_pool(self, pool_id: Optional[str] = None, levels: int = 1) -> bool:
        """Unfold a memory pool"""
        target_pool_id = pool_id or self.active_pool_id
        
        if target_pool_id is None or target_pool_id not in self.memory_pools:
            return False
        
        return self.memory_pools[target_pool_id].unfold(levels)
    
    def evolve_pool(self, pool_id: Optional[str] = None) -> bool:
        """Evolve a memory pool to the next stage"""
        target_pool_id = pool_id or self.active_pool_id
        
        if target_pool_id is None or target_pool_id not in self.memory_pools:
            return False
        
        return self.memory_pools[target_pool_id].evolve()
    
    def create_symbol_from_pool(self, pool_id: Optional[str] = None, symbol_name: Optional[str] = None) -> Optional[Any]:
        """Create a symbol from a memory pool's data"""
        if not SYMBOL_SYSTEM_AVAILABLE or not self.symbol_system:
            return None
        
        target_pool_id = pool_id or self.active_pool_id
        
        if target_pool_id is None or target_pool_id not in self.memory_pools:
            return None
        
        pool = self.memory_pools[target_pool_id]
        
        # Generate a name if not provided
        if not symbol_name:
            timestamp = int(time.time())
            symbol_name = f"pool_symbol_{pool.dimension.name.lower()}_{timestamp}"
        
        # Extract all tags
        all_tags = list(pool.tags)
        
        # Determine symbol type based on dimension
        symbol_type_map = {
            DataDimension.VISUAL: "visual",
            DataDimension.TEXTUAL: "textual",
            DataDimension.CONCEPTUAL: "conceptual"
        }
        
        symbol_type = symbol_type_map.get(pool.dimension, "textual")
        
        # Create data for symbol
        symbol_data = {
            "pool_id": pool.pool_id,
            "tags": all_tags,
            "evolution_stage": pool.evolution_stage.name,
            "fold_level": pool.fold_level,
            "item_count": len(pool.items),
            "sample_items": pool.items[:3] if pool.items else []
        }
        
        # Create symbol
        try:
            Symbol = self.symbol_system.get("Symbol", self.symbol_system)
            if callable(getattr(Symbol, "create", None)):
                return Symbol.create(symbol_name, symbol_type, symbol_data)
            elif isinstance(self.symbol_system, dict):
                SymbolClass = self.symbol_system.get("Symbol")
                if SymbolClass:
                    return SymbolClass(symbol_name, symbol_type, symbol_data)
            else:
                return self.symbol_system.create_symbol(symbol_name, symbol_type, symbol_data)
        except Exception as e:
            print(f"Error creating symbol: {e}")
            return None
    
    def connect_pools(self, source_pool_id: str, target_pool_id: str, connection_type: str = "related") -> bool:
        """Connect two memory pools"""
        if (source_pool_id not in self.memory_pools or
            target_pool_id not in self.memory_pools):
            return False
        
        source_pool = self.memory_pools[source_pool_id]
        
        if "connections" not in source_pool.connections:
            source_pool.connections[connection_type] = []
        
        if target_pool_id not in source_pool.connections[connection_type]:
            source_pool.connections[connection_type].append(target_pool_id)
        
        return True
    
    def find_items_by_tag(self, tag: str) -> List[Tuple[str, Dict[str, Any]]]:
        """Find items across all pools by tag"""
        results = []
        
        for pool_id, pool in self.memory_pools.items():
            for item in pool.items:
                if "tags" in item and tag in item["tags"]:
                    results.append((pool_id, item))
        
        return results
    
    def find_pools_by_tag(self, tag: str) -> List[str]:
        """Find pools that contain a specific tag"""
        results = []
        
        for pool_id, pool in self.memory_pools.items():
            if tag in pool.tags:
                results.append(pool_id)
        
        return results
    
    def save_state(self, filename: Optional[str] = None) -> bool:
        """Save the current state to a file"""
        if not filename:
            timestamp = int(time.time())
            filename = f"symbol_evolution_state_{timestamp}.json"
        
        filepath = os.path.join(self.data_directory, filename)
        
        try:
            state = {
                "active_pool_id": self.active_pool_id,
                "timestamp": time.time(),
                "pools": {
                    pool_id: pool.to_dict()
                    for pool_id, pool in self.memory_pools.items()
                }
            }
            
            with open(filepath, 'w') as f:
                json.dump(state, f, indent=2)
            
            return True
        except Exception as e:
            print(f"Error saving state: {e}")
            return False
    
    def load_state(self, filename: str) -> bool:
        """Load state from a file"""
        filepath = os.path.join(self.data_directory, filename)
        
        if not os.path.exists(filepath):
            return False
        
        try:
            with open(filepath, 'r') as f:
                state = json.load(f)
            
            # Recreate pools
            self.memory_pools = {}
            for pool_id, pool_data in state["pools"].items():
                self.memory_pools[pool_id] = MemoryPool.from_dict(pool_data)
            
            # Set active pool
            self.active_pool_id = state.get("active_pool_id")
            
            return True
        except Exception as e:
            print(f"Error loading state: {e}")
            return False
    
    def execute_evolution_cycle(self) -> Dict[str, Any]:
        """Execute a full evolution cycle on all pools"""
        results = {
            "evolved_pools": [],
            "folded_pools": [],
            "unfolded_pools": [],
            "created_symbols": []
        }
        
        # Get current turn if twelve_turns is available
        current_turn = None
        if self.twelve_turns and hasattr(self.twelve_turns, "get_current_turn"):
            current_turn = self.twelve_turns.get_current_turn()
        
        # Process each pool based on turn
        for pool_id, pool in self.memory_pools.items():
            # Determine action based on turn or random if turn system not available
            if current_turn is not None:
                turn_num = current_turn.get("number", 0) if isinstance(current_turn, dict) else current_turn
                action = turn_num % 3
            else:
                action = random.randint(0, 2)
            
            if action == 0:
                # Evolve
                if pool.evolve():
                    results["evolved_pools"].append(pool_id)
            elif action == 1:
                # Fold
                if pool.fold():
                    results["folded_pools"].append(pool_id)
            else:
                # Unfold or create symbol
                if pool.folded and random.random() < 0.7:
                    if pool.unfold():
                        results["unfolded_pools"].append(pool_id)
                else:
                    # Create symbol
                    symbol = self.create_symbol_from_pool(pool_id)
                    if symbol:
                        results["created_symbols"].append(str(symbol))
        
        return results
    
    def process_hashtag_command(self, command: str) -> Dict[str, Any]:
        """Process a hashtag-based command"""
        results = {
            "command": command,
            "actions": [],
            "success": False
        }
        
        # Extract command parts
        parts = command.split()
        if not parts:
            return results
        
        # Process commands
        if parts[0] == "#fold":
            # #fold [pool_id] [levels]
            pool_id = parts[1] if len(parts) > 1 else self.active_pool_id
            levels = int(parts[2]) if len(parts) > 2 else 1
            
            if self.fold_pool(pool_id, levels):
                results["actions"].append(f"Folded pool {pool_id} by {levels} levels")
                results["success"] = True
        
        elif parts[0] == "#unfold":
            # #unfold [pool_id] [levels]
            pool_id = parts[1] if len(parts) > 1 else self.active_pool_id
            levels = int(parts[2]) if len(parts) > 2 else 1
            
            if self.unfold_pool(pool_id, levels):
                results["actions"].append(f"Unfolded pool {pool_id} by {levels} levels")
                results["success"] = True
        
        elif parts[0] == "#evolve":
            # #evolve [pool_id]
            pool_id = parts[1] if len(parts) > 1 else self.active_pool_id
            
            if self.evolve_pool(pool_id):
                results["actions"].append(f"Evolved pool {pool_id}")
                results["success"] = True
        
        elif parts[0] == "#connect":
            # #connect [source_pool] [target_pool] [type]
            if len(parts) < 3:
                results["actions"].append("Invalid connect command format")
                return results
            
            source_pool = parts[1]
            target_pool = parts[2]
            conn_type = parts[3] if len(parts) > 3 else "related"
            
            if self.connect_pools(source_pool, target_pool, conn_type):
                results["actions"].append(f"Connected {source_pool} to {target_pool} as {conn_type}")
                results["success"] = True
        
        elif parts[0] == "#symbol":
            # #symbol [pool_id] [symbol_name]
            pool_id = parts[1] if len(parts) > 1 else self.active_pool_id
            symbol_name = parts[2] if len(parts) > 2 else None
            
            symbol = self.create_symbol_from_pool(pool_id, symbol_name)
            if symbol:
                results["actions"].append(f"Created symbol from pool {pool_id}")
                results["symbol"] = str(symbol)
                results["success"] = True
        
        elif parts[0] == "#cycle":
            # #cycle - Run evolution cycle on all pools
            cycle_results = self.execute_evolution_cycle()
            results["actions"].append("Executed evolution cycle")
            results["cycle_results"] = cycle_results
            results["success"] = True
        
        elif parts[0].startswith("#"):
            # Treat as a tag to add to active pool
            hashtag = parts[0]
            text = command
            
            if self.add_hashtag_item(text, [hashtag]):
                results["actions"].append(f"Added hashtag {hashtag} item to active pool")
                results["success"] = True
        
        return results

class FoldingDimensionVisualizer:
    """Visualizes the folding dimensions of memory pools"""
    
    def __init__(self, symbol_evolution: SymbolEvolution):
        self.symbol_evolution = symbol_evolution
    
    def text_visualization(self) -> str:
        """Generate a text-based visualization of memory pools"""
        if not self.symbol_evolution.memory_pools:
            return "No memory pools available"
        
        output = []
        output.append("=== MEMORY POOLS VISUALIZATION ===")
        
        # Group pools by dimension
        dimension_pools = {}
        for pool_id, pool in self.symbol_evolution.memory_pools.items():
            dim_name = pool.dimension.name
            if dim_name not in dimension_pools:
                dimension_pools[dim_name] = []
            
            dimension_pools[dim_name].append(pool)
        
        # Generate visualization for each dimension
        for dim_name, pools in dimension_pools.items():
            output.append(f"\n== DIMENSION: {dim_name} ==")
            
            for pool in pools:
                # Generate pool header
                active_marker = " *" if pool.pool_id == self.symbol_evolution.active_pool_id else ""
                output.append(f"POOL: {pool.pool_id}{active_marker} [Drive: {pool.drive}]")
                
                # Show evolution stage and fold level
                output.append(f"  Stage: {pool.evolution_stage.name}")
                output.append(f"  Fold Level: {pool.fold_level}")
                
                # Visualize folding with brackets
                fold_viz = "["
                for _ in range(pool.fold_level):
                    fold_viz += "["
                
                fold_viz += f" {len(pool.items)} items "
                
                for _ in range(pool.fold_level):
                    fold_viz += "]"
                fold_viz += "]"
                
                output.append(f"  Data: {fold_viz}")
                
                # Show tags
                if pool.tags:
                    tag_str = " ".join(sorted(pool.tags))
                    output.append(f"  Tags: {tag_str}")
                
                # Show connections
                if pool.connections:
                    output.append("  Connections:")
                    for conn_type, targets in pool.connections.items():
                        output.append(f"    {conn_type}: {', '.join(targets)}")
                
                output.append("")
        
        return "\n".join(output)
    
    def html_visualization(self) -> str:
        """Generate an HTML visualization of memory pools"""
        if not self.symbol_evolution.memory_pools:
            return "<p>No memory pools available</p>"
        
        html = []
        html.append("<div class='memory-visualization'>")
        html.append("<h2>Memory Pools Visualization</h2>")
        
        # Group pools by dimension
        dimension_pools = {}
        for pool_id, pool in self.symbol_evolution.memory_pools.items():
            dim_name = pool.dimension.name
            if dim_name not in dimension_pools:
                dimension_pools[dim_name] = []
            
            dimension_pools[dim_name].append(pool)
        
        # Generate visualization for each dimension
        for dim_name, pools in dimension_pools.items():
            # Create dimension section
            html.append(f"<div class='dimension' data-dimension='{dim_name}'>")
            html.append(f"<h3>Dimension: {dim_name}</h3>")
            html.append("<div class='dimension-pools'>")
            
            # Create pool boxes
            for pool in pools:
                # Determine CSS classes
                pool_classes = ['pool']
                if pool.pool_id == self.symbol_evolution.active_pool_id:
                    pool_classes.append('active')
                
                # Add stage and fold classes
                pool_classes.append(f"stage-{pool.evolution_stage.name.lower()}")
                pool_classes.append(f"drive-{pool.drive.lower()}")
                
                # Create pool element
                html.append(f"<div class='{' '.join(pool_classes)}' id='pool-{pool.pool_id}'>")
                
                # Pool header
                html.append(f"<div class='pool-header'>{pool.pool_id}</div>")
                
                # Pool metadata
                html.append("<div class='pool-metadata'>")
                html.append(f"<span class='stage'>{pool.evolution_stage.name}</span>")
                html.append(f"<span class='drive'>Drive {pool.drive}</span>")
                html.append(f"<span class='fold-level'>Fold: {pool.fold_level}</span>")
                html.append("</div>")
                
                # Data visualization
                html.append("<div class='pool-data'>")
                # Create nested divs for fold levels
                data_html = f"<div class='items'>{len(pool.items)} items</div>"
                for _ in range(pool.fold_level):
                    data_html = f"<div class='fold-level'>{data_html}</div>"
                
                html.append(data_html)
                html.append("</div>")
                
                # Tags section
                if pool.tags:
                    html.append("<div class='pool-tags'>")
                    for tag in sorted(pool.tags):
                        html.append(f"<span class='tag'>{tag}</span>")
                    html.append("</div>")
                
                # Close pool div
                html.append("</div>")
            
            # Close dimension pools and dimension div
            html.append("</div>")
            html.append("</div>")
        
        # Add CSS style
        html.append("<style>")
        html.append("""
        .memory-visualization {
            font-family: Arial, sans-serif;
            max-width: 1200px;
            margin: 0 auto;
        }
        .dimension {
            margin-bottom: 20px;
            border: 1px solid #ccc;
            border-radius: 5px;
            padding: 10px;
        }
        .dimension h3 {
            margin-top: 0;
            border-bottom: 1px solid #eee;
            padding-bottom: 5px;
        }
        .dimension-pools {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }
        .pool {
            width: 200px;
            border: 1px solid #ddd;
            border-radius: 5px;
            padding: 10px;
            background-color: #f9f9f9;
        }
        .pool.active {
            border: 2px solid #007bff;
            background-color: #e7f1ff;
        }
        .pool-header {
            font-weight: bold;
            padding-bottom: 5px;
            border-bottom: 1px solid #eee;
            margin-bottom: 5px;
        }
        .pool-metadata {
            font-size: 0.8em;
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }
        .pool-data {
            text-align: center;
            padding: 5px;
        }
        .fold-level {
            border: 1px solid #ddd;
            padding: 2px;
            margin: 2px;
            background-color: rgba(0,0,0,0.02);
        }
        .items {
            background-color: #e7f1ff;
            padding: 5px;
            border-radius: 3px;
        }
        .pool-tags {
            margin-top: 10px;
            display: flex;
            flex-wrap: wrap;
            gap: 5px;
        }
        .tag {
            background-color: #007bff;
            color: white;
            padding: 2px 5px;
            border-radius: 3px;
            font-size: 0.7em;
        }
        /* Stage-specific colors */
        .stage-seed { border-left: 5px solid #4caf50; }
        .stage-growth { border-left: 5px solid #8bc34a; }
        .stage-split { border-left: 5px solid #cddc39; }
        .stage-merge { border-left: 5px solid #ffc107; }
        .stage-combine { border-left: 5px solid #ff9800; }
        .stage-evolve { border-left: 5px solid #ff5722; }
        .stage-archive { border-left: 5px solid #9c27b0; }
        .stage-destroy { border-left: 5px solid #f44336; }
        .stage-transcend { border-left: 5px solid #2196f3; }
        .stage-recycle { border-left: 5px solid #009688; }
        """)
        html.append("</style>")
        
        # Close main div
        html.append("</div>")
        
        return "\n".join(html)

    def json_visualization(self) -> Dict[str, Any]:
        """Generate a JSON representation of memory pools"""
        if not self.symbol_evolution.memory_pools:
            return {"error": "No memory pools available"}
        
        # Group pools by dimension
        dimension_pools = {}
        for pool_id, pool in self.symbol_evolution.memory_pools.items():
            dim_name = pool.dimension.name
            if dim_name not in dimension_pools:
                dimension_pools[dim_name] = []
            
            pool_data = {
                "id": pool.pool_id,
                "active": pool.pool_id == self.symbol_evolution.active_pool_id,
                "drive": pool.drive,
                "evolution_stage": pool.evolution_stage.name,
                "fold_level": pool.fold_level,
                "items_count": len(pool.items),
                "tags": list(pool.tags),
                "connections": pool.connections,
                "last_accessed": pool.last_accessed
            }
            
            dimension_pools[dim_name].append(pool_data)
        
        result = {
            "dimensions": {},
            "active_pool_id": self.symbol_evolution.active_pool_id,
            "total_pools": len(self.symbol_evolution.memory_pools)
        }
        
        for dim_name, pools in dimension_pools.items():
            result["dimensions"][dim_name] = {
                "pools": pools,
                "count": len(pools)
            }
        
        return result

def main():
    """Main function for CLI usage"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Symbol Data Evolution System")
    parser.add_argument("--init", action="store_true", help="Initialize the system with default pools")
    parser.add_argument("--add", help="Add hashtag text to active pool")
    parser.add_argument("--fold", nargs="?", const="active", help="Fold a pool (provide pool_id or use active)")
    parser.add_argument("--unfold", nargs="?", const="active", help="Unfold a pool (provide pool_id or use active)")
    parser.add_argument("--evolve", nargs="?", const="active", help="Evolve a pool (provide pool_id or use active)")
    parser.add_argument("--cycle", action="store_true", help="Execute an evolution cycle on all pools")
    parser.add_argument("--view", choices=["text", "html", "json"], default="text", help="View pools visualization")
    parser.add_argument("--save", nargs="?", const="auto", help="Save state (provide filename or use auto)")
    parser.add_argument("--load", help="Load state from file")
    
    args = parser.parse_args()
    
    # Create symbol evolution system
    system = SymbolEvolution()
    
    if args.init:
        print("Initializing system with default pools...")
        system._create_default_pools()
    
    if args.add:
        if system.add_hashtag_item(args.add):
            print(f"Added text to active pool: {system.active_pool_id}")
        else:
            print("Failed to add text to active pool")
    
    if args.fold:
        pool_id = None if args.fold == "active" else args.fold
        if system.fold_pool(pool_id):
            target_id = pool_id or system.active_pool_id
            print(f"Folded pool: {target_id}")
        else:
            print("Failed to fold pool")
    
    if args.unfold:
        pool_id = None if args.unfold == "active" else args.unfold
        if system.unfold_pool(pool_id):
            target_id = pool_id or system.active_pool_id
            print(f"Unfolded pool: {target_id}")
        else:
            print("Failed to unfold pool")
    
    if args.evolve:
        pool_id = None if args.evolve == "active" else args.evolve
        if system.evolve_pool(pool_id):
            target_id = pool_id or system.active_pool_id
            print(f"Evolved pool: {target_id}")
        else:
            print("Failed to evolve pool")
    
    if args.cycle:
        results = system.execute_evolution_cycle()
        print("Evolution cycle executed:")
        print(f"- Evolved pools: {', '.join(results['evolved_pools']) if results['evolved_pools'] else 'None'}")
        print(f"- Folded pools: {', '.join(results['folded_pools']) if results['folded_pools'] else 'None'}")
        print(f"- Unfolded pools: {', '.join(results['unfolded_pools']) if results['unfolded_pools'] else 'None'}")
        print(f"- Created symbols: {len(results['created_symbols'])}")
    
    if args.view:
        visualizer = FoldingDimensionVisualizer(system)
        
        if args.view == "text":
            print(visualizer.text_visualization())
        elif args.view == "html":
            html = visualizer.html_visualization()
            # Save HTML to file
            html_file = os.path.join(system.data_directory, "visualization.html")
            with open(html_file, 'w') as f:
                f.write(html)
            print(f"HTML visualization saved to {html_file}")
        elif args.view == "json":
            json_data = visualizer.json_visualization()
            # Save JSON to file
            json_file = os.path.join(system.data_directory, "visualization.json")
            with open(json_file, 'w') as f:
                json.dump(json_data, f, indent=2)
            print(f"JSON visualization saved to {json_file}")
    
    if args.save:
        filename = f"state_{int(time.time())}.json" if args.save == "auto" else args.save
        if system.save_state(filename):
            print(f"State saved to {filename}")
        else:
            print("Failed to save state")
    
    if args.load:
        if system.load_state(args.load):
            print(f"State loaded from {args.load}")
        else:
            print(f"Failed to load state from {args.load}")

if __name__ == "__main__":
    main()