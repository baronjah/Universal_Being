#!/usr/bin/env python3
"""
Symbol Reason System
-------------------
Implements symbolic representation and hash-based icon recognition for the 12 turns system.
Connects with hashtag communication and provides autocommand verification.

This system provides:
- Symbol class for representing visual, textual, and conceptual symbols
- Reason class for attaching meaning to symbols
- IconHash for hash-based visual recognition
- SymbolConnection for creating networks of related symbols
- Low-resource operation capabilities
- Integration with the twelve turns system
- Hashtag-based command integration
- Visual rendering capabilities
"""

import os
import json
import hashlib
import time
import base64
from enum import Enum
from collections import defaultdict
from typing import Dict, List, Tuple, Union, Optional, Callable

# Configuration and constants
DEFAULT_CONFIG_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "symbols_config.json")
HASH_SALT = "divine_symbol_salt_12_turns"  # Salt for hashing
DEFAULT_COLOR_MAP = {
    "attention": {
        "high": "#FF5733",    # Bright red-orange for high attention
        "medium": "#FFC300",  # Gold for medium attention
        "low": "#DAF7A6"      # Light green for low attention
    },
    "symbol_types": {
        "visual": "#3498DB",   # Blue for visual symbols
        "textual": "#2ECC71",  # Green for textual symbols
        "conceptual": "#9B59B6" # Purple for conceptual symbols
    }
}

# Enum definitions
class SymbolType(Enum):
    VISUAL = "visual"
    TEXTUAL = "textual"
    CONCEPTUAL = "conceptual"

class ReasonType(Enum):
    FUNCTIONAL = "functional"  # Describes what a symbol does
    SEMANTIC = "semantic"      # Describes what a symbol means
    RELATIONAL = "relational"  # Describes how a symbol relates to others

class AttentionLevel(Enum):
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"

class ProcessingMode(Enum):
    LOW_RESOURCE = "low_resource"
    STANDARD = "standard"
    ENHANCED = "enhanced"

class SymbolVerificationResult(Enum):
    VERIFIED = "verified"
    REJECTED = "rejected"
    PENDING = "pending"

# Core symbol class
class Symbol:
    """
    Base class for symbolic representation.
    Symbols can be visual, textual, or conceptual.
    """
    def __init__(
        self,
        symbol_id: str,
        symbol_type: SymbolType,
        value: str,
        attention_level: AttentionLevel = AttentionLevel.MEDIUM,
        metadata: Dict = None
    ):
        self.id = symbol_id
        self.type = symbol_type
        self.value = value
        self.attention_level = attention_level
        self.metadata = metadata or {}
        self.creation_time = time.time()
        self.reasons = []
        self.connections = []
        self.hashtags = []
        
        # Generate hash for verification
        self._hash = self._generate_hash()
    
    def _generate_hash(self) -> str:
        """Generate a unique hash for this symbol"""
        hash_input = f"{self.id}:{self.type.value}:{self.value}:{HASH_SALT}"
        return hashlib.sha256(hash_input.encode()).hexdigest()
    
    def verify(self) -> bool:
        """Verify this symbol's integrity"""
        current_hash = self._generate_hash()
        return current_hash == self._hash
    
    def add_reason(self, reason) -> None:
        """Add a reason to this symbol"""
        self.reasons.append(reason)
        
    def add_connection(self, connection) -> None:
        """Add a connection to this symbol"""
        self.connections.append(connection)
    
    def add_hashtag(self, hashtag: str) -> None:
        """Add a hashtag to this symbol"""
        if hashtag.startswith('#'):
            self.hashtags.append(hashtag)
        else:
            self.hashtags.append(f"#{hashtag}")
    
    def get_color(self, color_map: Dict = None) -> str:
        """Get the color for this symbol based on its attention level"""
        if not color_map:
            color_map = DEFAULT_COLOR_MAP
        
        # First try symbol type color
        type_color = color_map.get("symbol_types", {}).get(self.type.value)
        if type_color:
            return type_color
            
        # Fall back to attention color
        return color_map.get("attention", {}).get(self.attention_level.value, "#CCCCCC")
    
    def to_dict(self) -> Dict:
        """Convert symbol to dictionary for serialization"""
        return {
            "id": self.id,
            "type": self.type.value,
            "value": self.value,
            "attention_level": self.attention_level.value,
            "metadata": self.metadata,
            "creation_time": self.creation_time,
            "hash": self._hash,
            "hashtags": self.hashtags,
            "reasons": [reason.to_dict() for reason in self.reasons]
        }
    
    @classmethod
    def from_dict(cls, data: Dict) -> 'Symbol':
        """Create a symbol from a dictionary"""
        symbol = cls(
            symbol_id=data["id"],
            symbol_type=SymbolType(data["type"]),
            value=data["value"],
            attention_level=AttentionLevel(data["attention_level"]),
            metadata=data.get("metadata", {})
        )
        symbol.creation_time = data.get("creation_time", time.time())
        symbol._hash = data.get("hash", symbol._generate_hash())
        symbol.hashtags = data.get("hashtags", [])
        
        # Note: Reasons and connections must be added separately
        return symbol

class Reason:
    """
    Represents a reason attached to a symbol.
    Reasons provide explanation and justification for symbols.
    """
    def __init__(
        self,
        reason_id: str,
        reason_type: ReasonType,
        description: str,
        confidence: float = 0.5,
        metadata: Dict = None
    ):
        self.id = reason_id
        self.type = reason_type
        self.description = description
        self.confidence = max(0.0, min(1.0, confidence))  # Clamp between 0 and 1
        self.metadata = metadata or {}
        self.creation_time = time.time()
    
    def to_dict(self) -> Dict:
        """Convert reason to dictionary for serialization"""
        return {
            "id": self.id,
            "type": self.type.value,
            "description": self.description,
            "confidence": self.confidence,
            "metadata": self.metadata,
            "creation_time": self.creation_time
        }
    
    @classmethod
    def from_dict(cls, data: Dict) -> 'Reason':
        """Create a reason from a dictionary"""
        reason = cls(
            reason_id=data["id"],
            reason_type=ReasonType(data["type"]),
            description=data["description"],
            confidence=data.get("confidence", 0.5),
            metadata=data.get("metadata", {})
        )
        reason.creation_time = data.get("creation_time", time.time())
        return reason

class SymbolConnection:
    """
    Represents a connection between two symbols.
    Connections create a network of related symbols.
    """
    def __init__(
        self,
        connection_id: str,
        source_symbol: Symbol,
        target_symbol: Symbol,
        strength: float = 0.5,
        relationship_type: str = "related",
        metadata: Dict = None
    ):
        self.id = connection_id
        self.source = source_symbol
        self.target = target_symbol
        self.strength = max(0.0, min(1.0, strength))  # Clamp between 0 and 1
        self.relationship_type = relationship_type
        self.metadata = metadata or {}
        self.creation_time = time.time()
    
    def to_dict(self) -> Dict:
        """Convert connection to dictionary for serialization"""
        return {
            "id": self.id,
            "source_id": self.source.id,
            "target_id": self.target.id,
            "strength": self.strength,
            "relationship_type": self.relationship_type,
            "metadata": self.metadata,
            "creation_time": self.creation_time
        }
    
    @staticmethod
    def from_dict(data: Dict, symbol_map: Dict[str, Symbol]) -> Optional['SymbolConnection']:
        """Create a connection from a dictionary and a map of symbols"""
        source_id = data.get("source_id")
        target_id = data.get("target_id")
        
        if source_id not in symbol_map or target_id not in symbol_map:
            return None
            
        connection = SymbolConnection(
            connection_id=data["id"],
            source_symbol=symbol_map[source_id],
            target_symbol=symbol_map[target_id],
            strength=data.get("strength", 0.5),
            relationship_type=data.get("relationship_type", "related"),
            metadata=data.get("metadata", {})
        )
        connection.creation_time = data.get("creation_time", time.time())
        return connection

class IconHash:
    """
    Manages hash-based icon recognition.
    Can match visual symbols based on hash similarity.
    """
    def __init__(self, hash_size: int = 16):
        self.hash_size = hash_size
        self.hash_map = {}  # Maps hash values to symbol IDs
    
    def add_symbol(self, symbol: Symbol) -> None:
        """Add a symbol to the hash map"""
        if symbol.type != SymbolType.VISUAL:
            return
            
        icon_data = symbol.metadata.get("icon_data")
        if not icon_data:
            return
            
        hash_value = self._compute_hash(icon_data)
        self.hash_map[hash_value] = symbol.id
    
    def find_matching_symbol(self, icon_data: str, threshold: float = 0.8) -> Optional[str]:
        """Find a matching symbol ID for the given icon data"""
        target_hash = self._compute_hash(icon_data)
        
        best_match = None
        best_similarity = 0.0
        
        for hash_value, symbol_id in self.hash_map.items():
            similarity = self._hash_similarity(target_hash, hash_value)
            if similarity > threshold and similarity > best_similarity:
                best_match = symbol_id
                best_similarity = similarity
        
        return best_match
    
    def _compute_hash(self, icon_data: str) -> str:
        """Compute a perceptual hash for the icon data"""
        # In a real implementation, this would use a perceptual hashing algorithm
        # For this simplified version, we'll just use a basic hash
        return hashlib.md5(icon_data.encode()).hexdigest()[:self.hash_size]
    
    def _hash_similarity(self, hash1: str, hash2: str) -> float:
        """Compute similarity between two hashes (0.0 to 1.0)"""
        if len(hash1) != len(hash2):
            return 0.0
            
        matching_bits = sum(c1 == c2 for c1, c2 in zip(hash1, hash2))
        return matching_bits / len(hash1)

class SymbolReasonSystem:
    """
    Main system for managing symbols, reasons, and their connections.
    Integrates with the twelve turns system and provides command verification.
    """
    def __init__(
        self, 
        config_path: str = DEFAULT_CONFIG_PATH,
        processing_mode: ProcessingMode = ProcessingMode.STANDARD
    ):
        self.symbols = {}  # symbol_id -> Symbol
        self.connections = {}  # connection_id -> SymbolConnection
        self.reasons = {}  # reason_id -> Reason
        self.hashtag_map = defaultdict(list)  # hashtag -> [symbol_ids]
        self.color_map = DEFAULT_COLOR_MAP.copy()
        self.processing_mode = processing_mode
        self.icon_hash = IconHash()
        self.turn_count = 1
        self.current_dimension = 1
        self.command_handlers = {}  # command_hashtag -> handler_function
        
        # Load configuration if available
        if os.path.exists(config_path):
            self.load_config(config_path)
        else:
            self.save_config(config_path)  # Create default config
    
    def register_command_handler(self, hashtag: str, handler: Callable) -> None:
        """Register a handler function for a specific command hashtag"""
        if not hashtag.startswith('#'):
            hashtag = f"#{hashtag}"
        self.command_handlers[hashtag] = handler
    
    def process_command(self, command: str) -> Tuple[bool, str]:
        """Process a command and return success status and response"""
        parts = command.strip().split(' ', 1)
        hashtag = parts[0]
        args = parts[1] if len(parts) > 1 else ""
        
        if hashtag in self.command_handlers:
            try:
                result = self.command_handlers[hashtag](args)
                return True, result
            except Exception as e:
                return False, f"Error processing command: {str(e)}"
        
        # Find symbols with matching hashtag
        if hashtag in self.hashtag_map:
            symbol_ids = self.hashtag_map[hashtag]
            symbols_info = [f"{s_id}: {self.symbols[s_id].value}" for s_id in symbol_ids if s_id in self.symbols]
            return True, f"Found {len(symbols_info)} symbols for {hashtag}:\n" + "\n".join(symbols_info)
        
        return False, f"Unknown command or hashtag: {hashtag}"
    
    def create_symbol(
        self,
        symbol_id: str,
        symbol_type: Union[SymbolType, str],
        value: str,
        attention_level: Union[AttentionLevel, str] = AttentionLevel.MEDIUM,
        metadata: Dict = None,
        hashtags: List[str] = None
    ) -> Symbol:
        """Create a new symbol and add it to the system"""
        # Convert string enums to proper enum values
        if isinstance(symbol_type, str):
            symbol_type = SymbolType(symbol_type)
        
        if isinstance(attention_level, str):
            attention_level = AttentionLevel(attention_level)
        
        # Create the symbol
        symbol = Symbol(
            symbol_id=symbol_id,
            symbol_type=symbol_type,
            value=value,
            attention_level=attention_level,
            metadata=metadata or {}
        )
        
        # Add hashtags
        if hashtags:
            for hashtag in hashtags:
                symbol.add_hashtag(hashtag)
                if not hashtag.startswith('#'):
                    hashtag = f"#{hashtag}"
                self.hashtag_map[hashtag].append(symbol_id)
        
        # Add to the system
        self.symbols[symbol_id] = symbol
        
        # Add to icon hash if it's a visual symbol
        if symbol_type == SymbolType.VISUAL and metadata and "icon_data" in metadata:
            self.icon_hash.add_symbol(symbol)
        
        return symbol
    
    def add_reason_to_symbol(
        self,
        symbol_id: str,
        reason_id: str,
        reason_type: Union[ReasonType, str],
        description: str,
        confidence: float = 0.5,
        metadata: Dict = None
    ) -> Optional[Reason]:
        """Add a reason to an existing symbol"""
        if symbol_id not in self.symbols:
            return None
        
        # Convert string enum to proper enum value
        if isinstance(reason_type, str):
            reason_type = ReasonType(reason_type)
        
        # Create the reason
        reason = Reason(
            reason_id=reason_id,
            reason_type=reason_type,
            description=description,
            confidence=confidence,
            metadata=metadata or {}
        )
        
        # Add to system and symbol
        self.reasons[reason_id] = reason
        self.symbols[symbol_id].add_reason(reason)
        
        return reason
    
    def connect_symbols(
        self,
        source_id: str,
        target_id: str,
        connection_id: str,
        strength: float = 0.5,
        relationship_type: str = "related",
        metadata: Dict = None
    ) -> Optional[SymbolConnection]:
        """Connect two symbols with a relationship"""
        if source_id not in self.symbols or target_id not in self.symbols:
            return None
        
        # Create the connection
        connection = SymbolConnection(
            connection_id=connection_id,
            source_symbol=self.symbols[source_id],
            target_symbol=self.symbols[target_id],
            strength=strength,
            relationship_type=relationship_type,
            metadata=metadata or {}
        )
        
        # Add to system and symbols
        self.connections[connection_id] = connection
        self.symbols[source_id].add_connection(connection)
        
        return connection
    
    def verify_command(self, command: str, required_symbols: List[str] = None) -> SymbolVerificationResult:
        """
        Verify if a command should be auto-accepted based on symbol verification.
        
        Args:
            command: The command to verify
            required_symbols: List of symbol IDs that must be present and verified
            
        Returns:
            SymbolVerificationResult: VERIFIED, REJECTED, or PENDING
        """
        if not required_symbols:
            return SymbolVerificationResult.PENDING
        
        # Check if all required symbols exist and are verified
        for symbol_id in required_symbols:
            if symbol_id not in self.symbols:
                return SymbolVerificationResult.REJECTED
            
            symbol = self.symbols[symbol_id]
            if not symbol.verify():
                return SymbolVerificationResult.REJECTED
        
        # If we get here, all symbols are verified
        return SymbolVerificationResult.VERIFIED
    
    def find_symbols_by_hashtag(self, hashtag: str) -> List[Symbol]:
        """Find all symbols with a specific hashtag"""
        if not hashtag.startswith('#'):
            hashtag = f"#{hashtag}"
        
        symbol_ids = self.hashtag_map.get(hashtag, [])
        return [self.symbols[sid] for sid in symbol_ids if sid in self.symbols]
    
    def set_turn_and_dimension(self, turn: int, dimension: int) -> None:
        """Update the current turn and dimension"""
        self.turn_count = turn
        self.current_dimension = dimension
    
    def get_dimension_symbols(self) -> List[Symbol]:
        """Get symbols relevant to the current dimension"""
        return [s for s in self.symbols.values() 
                if s.metadata.get("dimension") == self.current_dimension]
    
    def auto_repetition_check(self, text: str, symbols: List[str]) -> bool:
        """Check if text contains auto-repeating patterns for given symbols"""
        if not symbols:
            return False
            
        # In a real implementation, this would do more sophisticated pattern detection
        # For this basic implementation, we just check for repeated sequences
        repeat_threshold = 3
        for symbol_id in symbols:
            if symbol_id in self.symbols:
                value = self.symbols[symbol_id].value
                if value and value * repeat_threshold in text:
                    return True
        
        return False
    
    def load_config(self, config_path: str) -> bool:
        """Load configuration from a JSON file"""
        try:
            with open(config_path, 'r') as f:
                config = json.load(f)
            
            # Apply configuration
            if "color_map" in config:
                self.color_map = config["color_map"]
            
            if "processing_mode" in config:
                self.processing_mode = ProcessingMode(config["processing_mode"])
            
            return True
        except Exception as e:
            print(f"Error loading configuration: {str(e)}")
            return False
    
    def save_config(self, config_path: str) -> bool:
        """Save configuration to a JSON file"""
        config = {
            "color_map": self.color_map,
            "processing_mode": self.processing_mode.value
        }
        
        try:
            os.makedirs(os.path.dirname(config_path), exist_ok=True)
            with open(config_path, 'w') as f:
                json.dump(config, f, indent=2)
            return True
        except Exception as e:
            print(f"Error saving configuration: {str(e)}")
            return False
    
    def save_symbols(self, file_path: str) -> bool:
        """Save all symbols and connections to a JSON file"""
        try:
            data = {
                "symbols": [s.to_dict() for s in self.symbols.values()],
                "reasons": [r.to_dict() for r in self.reasons.values()],
                "connections": [c.to_dict() for c in self.connections.values()],
                "hashtag_map": {k: v for k, v in self.hashtag_map.items()},
                "turn_count": self.turn_count,
                "current_dimension": self.current_dimension,
                "processing_mode": self.processing_mode.value
            }
            
            os.makedirs(os.path.dirname(file_path), exist_ok=True)
            with open(file_path, 'w') as f:
                json.dump(data, f, indent=2)
            return True
        except Exception as e:
            print(f"Error saving symbols: {str(e)}")
            return False
    
    def load_symbols(self, file_path: str) -> bool:
        """Load symbols and connections from a JSON file"""
        try:
            with open(file_path, 'r') as f:
                data = json.load(f)
            
            # Clear current data
            self.symbols = {}
            self.reasons = {}
            self.connections = {}
            self.hashtag_map = defaultdict(list)
            
            # Load symbols
            for symbol_data in data.get("symbols", []):
                symbol = Symbol.from_dict(symbol_data)
                self.symbols[symbol.id] = symbol
            
            # Load reasons
            for reason_data in data.get("reasons", []):
                reason = Reason.from_dict(reason_data)
                self.reasons[reason.id] = reason
            
            # Reassociate reasons with symbols
            for symbol_data in data.get("symbols", []):
                symbol_id = symbol_data["id"]
                if symbol_id in self.symbols:
                    symbol = self.symbols[symbol_id]
                    symbol.reasons = []
                    for reason_data in symbol_data.get("reasons", []):
                        reason_id = reason_data["id"]
                        if reason_id in self.reasons:
                            symbol.reasons.append(self.reasons[reason_id])
            
            # Load connections
            for connection_data in data.get("connections", []):
                connection = SymbolConnection.from_dict(connection_data, self.symbols)
                if connection:
                    self.connections[connection.id] = connection
                    # Re-associate with source symbol
                    source_id = connection_data["source_id"]
                    if source_id in self.symbols:
                        self.symbols[source_id].connections.append(connection)
            
            # Load hashtag map
            self.hashtag_map = defaultdict(list)
            for hashtag, symbol_ids in data.get("hashtag_map", {}).items():
                self.hashtag_map[hashtag] = symbol_ids
            
            # Load other settings
            self.turn_count = data.get("turn_count", 1)
            self.current_dimension = data.get("current_dimension", 1)
            
            if "processing_mode" in data:
                self.processing_mode = ProcessingMode(data["processing_mode"])
            
            # Rebuild icon hash
            self.icon_hash = IconHash()
            for symbol in self.symbols.values():
                if symbol.type == SymbolType.VISUAL and "icon_data" in symbol.metadata:
                    self.icon_hash.add_symbol(symbol)
            
            return True
        except Exception as e:
            print(f"Error loading symbols: {str(e)}")
            return False

    def visualize_symbols(self, format_type: str = "text") -> str:
        """
        Visualize symbols and their connections in various formats.
        
        Args:
            format_type: The type of visualization to generate (text, html, json)
            
        Returns:
            str: The visualization as a string
        """
        if format_type == "html":
            return self._generate_html_visualization()
        elif format_type == "json":
            return json.dumps({
                "symbols": [s.to_dict() for s in self.symbols.values()],
                "connections": [c.to_dict() for c in self.connections.values()]
            }, indent=2)
        else:
            # Default text visualization
            return self._generate_text_visualization()
    
    def _generate_text_visualization(self) -> str:
        """Generate a text-based visualization of symbols and connections"""
        result = []
        result.append("=== Symbol Reason System Visualization ===")
        result.append(f"Current Turn: {self.turn_count}")
        result.append(f"Current Dimension: {self.current_dimension}")
        result.append(f"Total Symbols: {len(self.symbols)}")
        result.append(f"Total Connections: {len(self.connections)}")
        result.append("\n--- Symbols ---")
        
        for symbol in self.symbols.values():
            result.append(f"Symbol: {symbol.id} [{symbol.type.value}] = {symbol.value}")
            if symbol.hashtags:
                result.append(f"  Hashtags: {' '.join(symbol.hashtags)}")
            if symbol.reasons:
                result.append("  Reasons:")
                for reason in symbol.reasons:
                    result.append(f"    - {reason.description} ({reason.type.value}, {reason.confidence:.2f})")
        
        result.append("\n--- Connections ---")
        for connection in self.connections.values():
            result.append(f"Connection: {connection.id}")
            result.append(f"  {connection.source.id} --{connection.relationship_type}--> {connection.target.id}")
            result.append(f"  Strength: {connection.strength:.2f}")
        
        return "\n".join(result)
    
    def _generate_html_visualization(self) -> str:
        """Generate an HTML visualization of symbols and connections"""
        html = []
        html.append('<!DOCTYPE html>')
        html.append('<html><head><title>Symbol Reason System Visualization</title>')
        html.append('<style>')
        html.append('body { font-family: Arial, sans-serif; margin: 20px; }')
        html.append('.symbol { border: 1px solid #ccc; padding: 10px; margin: 10px; border-radius: 5px; }')
        html.append('.visual { border-left: 5px solid #3498DB; }')
        html.append('.textual { border-left: 5px solid #2ECC71; }')
        html.append('.conceptual { border-left: 5px solid #9B59B6; }')
        html.append('.reason { margin-left: 20px; font-style: italic; }')
        html.append('.connection { margin: 15px 0; padding: 10px; background-color: #f9f9f9; }')
        html.append('.hashtag { background-color: #f0f0f0; padding: 2px 5px; border-radius: 3px; margin-right: 5px; }')
        html.append('</style>')
        html.append('</head><body>')
        
        html.append(f'<h1>Symbol Reason System</h1>')
        html.append(f'<p>Current Turn: {self.turn_count} | Current Dimension: {self.current_dimension}</p>')
        html.append(f'<p>Total Symbols: {len(self.symbols)} | Total Connections: {len(self.connections)}</p>')
        
        html.append('<h2>Symbols</h2>')
        for symbol in self.symbols.values():
            html.append(f'<div class="symbol {symbol.type.value}">')
            html.append(f'<h3>{symbol.id}: {symbol.value}</h3>')
            
            if symbol.hashtags:
                html.append('<p>')
                for hashtag in symbol.hashtags:
                    html.append(f'<span class="hashtag">{hashtag}</span>')
                html.append('</p>')
            
            if symbol.reasons:
                html.append('<h4>Reasons:</h4>')
                html.append('<ul>')
                for reason in symbol.reasons:
                    html.append(f'<li class="reason">{reason.description} <small>({reason.type.value}, confidence: {reason.confidence:.2f})</small></li>')
                html.append('</ul>')
            
            html.append('</div>')
        
        html.append('<h2>Connections</h2>')
        for connection in self.connections.values():
            html.append(f'<div class="connection">')
            html.append(f'<p><strong>{connection.id}</strong>: {connection.source.id} <em>--{connection.relationship_type}--&gt;</em> {connection.target.id}</p>')
            html.append(f'<p>Strength: {connection.strength:.2f}</p>')
            html.append('</div>')
        
        html.append('</body></html>')
        return '\n'.join(html)


class AutoRepeatConnector:
    """
    Connects the Symbol Reason System with auto-repeat functionality.
    Integrates with hashtag commands and the twelve turns system.
    """
    def __init__(self, symbol_system: SymbolReasonSystem):
        self.symbol_system = symbol_system
        self.turn_history = []
        self.command_log = []
        self.auto_accept_patterns = []
        self.attention_color_map = {}
        
        # Register standard hashtag handlers
        self._register_standard_handlers()
    
    def _register_standard_handlers(self):
        """Register standard hashtag command handlers"""
        self.symbol_system.register_command_handler("#symbol", self._handle_symbol_command)
        self.symbol_system.register_command_handler("#reason", self._handle_reason_command)
        self.symbol_system.register_command_handler("#connect", self._handle_connect_command)
        self.symbol_system.register_command_handler("#verify", self._handle_verify_command)
        self.symbol_system.register_command_handler("#attention", self._handle_attention_command)
        self.symbol_system.register_command_handler("#visualize", self._handle_visualize_command)
        self.symbol_system.register_command_handler("#turn", self._handle_turn_command)
        self.symbol_system.register_command_handler("#auto", self._handle_auto_command)
    
    def _handle_symbol_command(self, args: str) -> str:
        """Handle symbol creation and management commands"""
        parts = args.split(' ', 2)
        if len(parts) < 2:
            return "Usage: #symbol create|get|list [args]"
        
        sub_command = parts[0]
        if sub_command == "create":
            if len(parts) < 3:
                return "Usage: #symbol create <id>:<type> <value>"
            
            id_type = parts[1].split(':')
            if len(id_type) != 2:
                return "Symbol ID and type must be provided as id:type"
            
            symbol_id, symbol_type = id_type
            value = parts[2]
            
            try:
                symbol = self.symbol_system.create_symbol(
                    symbol_id=symbol_id,
                    symbol_type=symbol_type,
                    value=value,
                    hashtags=[symbol_id]  # Auto-add ID as hashtag
                )
                return f"Created symbol {symbol.id} of type {symbol.type.value}"
            except Exception as e:
                return f"Error creating symbol: {str(e)}"
        
        elif sub_command == "get":
            symbol_id = parts[1]
            if symbol_id in self.symbol_system.symbols:
                symbol = self.symbol_system.symbols[symbol_id]
                result = [f"Symbol: {symbol.id} [{symbol.type.value}] = {symbol.value}"]
                
                if symbol.hashtags:
                    result.append(f"Hashtags: {' '.join(symbol.hashtags)}")
                
                if symbol.reasons:
                    result.append("Reasons:")
                    for reason in symbol.reasons:
                        result.append(f"- {reason.description} ({reason.type.value}, {reason.confidence:.2f})")
                
                return "\n".join(result)
            else:
                return f"Symbol not found: {symbol_id}"
        
        elif sub_command == "list":
            filter_type = parts[1] if len(parts) > 1 else None
            
            if filter_type and filter_type not in [t.value for t in SymbolType]:
                return f"Invalid symbol type filter: {filter_type}"
                
            symbols = self.symbol_system.symbols.values()
            if filter_type:
                symbols = [s for s in symbols if s.type.value == filter_type]
                
            if not symbols:
                return "No symbols found"
                
            result = []
            for symbol in symbols:
                result.append(f"{symbol.id} [{symbol.type.value}]: {symbol.value}")
            
            return "\n".join(result)
        
        else:
            return f"Unknown symbol sub-command: {sub_command}"
    
    def _handle_reason_command(self, args: str) -> str:
        """Handle reason creation and management commands"""
        parts = args.split(' ', 3)
        if len(parts) < 2:
            return "Usage: #reason add|list [args]"
        
        sub_command = parts[0]
        if sub_command == "add":
            if len(parts) < 4:
                return "Usage: #reason add <symbol_id> <reason_type> <description>"
            
            symbol_id = parts[1]
            reason_type = parts[2]
            description = parts[3]
            
            try:
                # Generate a reason ID
                reason_id = f"reason_{symbol_id}_{int(time.time())}"
                
                reason = self.symbol_system.add_reason_to_symbol(
                    symbol_id=symbol_id,
                    reason_id=reason_id,
                    reason_type=reason_type,
                    description=description
                )
                
                if reason:
                    return f"Added reason to {symbol_id}: {description}"
                else:
                    return f"Failed to add reason: Symbol {symbol_id} not found"
            except Exception as e:
                return f"Error adding reason: {str(e)}"
        
        elif sub_command == "list":
            symbol_id = parts[1]
            if symbol_id in self.symbol_system.symbols:
                symbol = self.symbol_system.symbols[symbol_id]
                
                if not symbol.reasons:
                    return f"No reasons found for symbol {symbol_id}"
                
                result = [f"Reasons for {symbol_id}:"]
                for reason in symbol.reasons:
                    result.append(f"- {reason.description} ({reason.type.value}, {reason.confidence:.2f})")
                
                return "\n".join(result)
            else:
                return f"Symbol not found: {symbol_id}"
        
        else:
            return f"Unknown reason sub-command: {sub_command}"
    
    def _handle_connect_command(self, args: str) -> str:
        """Handle connection creation and management commands"""
        parts = args.split(' ', 3)
        if len(parts) < 3:
            return "Usage: #connect <source_id> <target_id> [relationship_type]"
        
        source_id = parts[0]
        target_id = parts[1]
        relationship_type = parts[2] if len(parts) > 2 else "related"
        
        try:
            # Generate a connection ID
            connection_id = f"connection_{source_id}_{target_id}_{int(time.time())}"
            
            connection = self.symbol_system.connect_symbols(
                source_id=source_id,
                target_id=target_id,
                connection_id=connection_id,
                relationship_type=relationship_type
            )
            
            if connection:
                return f"Connected {source_id} to {target_id} with relationship: {relationship_type}"
            else:
                return f"Failed to connect: Symbol(s) not found"
        except Exception as e:
            return f"Error connecting symbols: {str(e)}"
    
    def _handle_verify_command(self, args: str) -> str:
        """Handle command verification"""
        parts = args.split(' ', 1)
        if len(parts) < 2:
            return "Usage: #verify <symbols> <command>"
        
        symbol_ids = parts[0].split(',')
        command = parts[1]
        
        result = self.symbol_system.verify_command(command, symbol_ids)
        return f"Verification result: {result.value}"
    
    def _handle_attention_command(self, args: str) -> str:
        """Handle attention color management"""
        parts = args.split(' ', 2)
        if len(parts) < 2:
            return "Usage: #attention get|set [args]"
        
        sub_command = parts[0]
        if sub_command == "set":
            if len(parts) < 3:
                return "Usage: #attention set <level> <color>"
            
            level = parts[1]
            color = parts[2]
            
            if level not in [l.value for l in AttentionLevel]:
                return f"Invalid attention level: {level}"
            
            self.attention_color_map[level] = color
            return f"Set attention color for {level} to {color}"
        
        elif sub_command == "get":
            level = parts[1] if len(parts) > 1 else None
            
            if level:
                if level not in [l.value for l in AttentionLevel]:
                    return f"Invalid attention level: {level}"
                    
                color = self.attention_color_map.get(level, 
                         self.symbol_system.color_map["attention"].get(level))
                return f"Attention color for {level}: {color}"
            else:
                result = ["Attention Colors:"]
                for level in [l.value for l in AttentionLevel]:
                    color = self.attention_color_map.get(level, 
                            self.symbol_system.color_map["attention"].get(level))
                    result.append(f"- {level}: {color}")
                return "\n".join(result)
        
        else:
            return f"Unknown attention sub-command: {sub_command}"
    
    def _handle_visualize_command(self, args: str) -> str:
        """Handle visualization of the symbol system"""
        format_type = args if args else "text"
        
        if format_type not in ["text", "html", "json"]:
            return f"Invalid visualization format: {format_type}"
        
        try:
            visualization = self.symbol_system.visualize_symbols(format_type)
            
            # For text format, just return directly
            if format_type == "text":
                return visualization
            
            # For HTML and JSON, save to a file and return the path
            file_format = "html" if format_type == "html" else "json"
            file_path = f"symbol_visualization_{int(time.time())}.{file_format}"
            
            with open(file_path, 'w') as f:
                f.write(visualization)
            
            return f"Visualization saved to: {file_path}"
        except Exception as e:
            return f"Error generating visualization: {str(e)}"
    
    def _handle_turn_command(self, args: str) -> str:
        """Handle turn and dimension management"""
        parts = args.split(' ', 1)
        if len(parts) < 1:
            return "Usage: #turn advance|set|get [args]"
        
        sub_command = parts[0]
        if sub_command == "advance":
            # Advance the turn
            self.symbol_system.turn_count += 1
            
            # If we complete a 12-turn cycle, move to the next dimension
            if self.symbol_system.turn_count > 12:
                self.symbol_system.turn_count = 1
                self.symbol_system.current_dimension += 1
            
            # Save the turn state
            self.turn_history.append({
                "turn": self.symbol_system.turn_count,
                "dimension": self.symbol_system.current_dimension,
                "timestamp": time.time()
            })
            
            return f"Advanced to Turn {self.symbol_system.turn_count}, Dimension {self.symbol_system.current_dimension}"
        
        elif sub_command == "set":
            if len(parts) < 2:
                return "Usage: #turn set <turn>:<dimension>"
            
            turn_dim = parts[1].split(':')
            if len(turn_dim) != 2:
                return "Turn and dimension must be provided as turn:dimension"
            
            try:
                turn = int(turn_dim[0])
                dimension = int(turn_dim[1])
                
                self.symbol_system.set_turn_and_dimension(turn, dimension)
                
                # Save the turn state
                self.turn_history.append({
                    "turn": turn,
                    "dimension": dimension,
                    "timestamp": time.time()
                })
                
                return f"Set to Turn {turn}, Dimension {dimension}"
            except ValueError:
                return "Turn and dimension must be integers"
        
        elif sub_command == "get":
            return f"Current Turn: {self.symbol_system.turn_count}, Dimension: {self.symbol_system.current_dimension}"
        
        else:
            return f"Unknown turn sub-command: {sub_command}"
    
    def _handle_auto_command(self, args: str) -> str:
        """Handle auto-acceptance pattern management"""
        parts = args.split(' ', 2)
        if len(parts) < 2:
            return "Usage: #auto add|remove|list [args]"
        
        sub_command = parts[0]
        if sub_command == "add":
            if len(parts) < 3:
                return "Usage: #auto add <symbol_ids> <pattern>"
            
            symbol_ids = parts[1].split(',')
            pattern = parts[2]
            
            # Check if all symbols exist
            missing_symbols = [sid for sid in symbol_ids if sid not in self.symbol_system.symbols]
            if missing_symbols:
                return f"Symbols not found: {', '.join(missing_symbols)}"
            
            # Add the auto-accept pattern
            self.auto_accept_patterns.append({
                "symbols": symbol_ids,
                "pattern": pattern
            })
            
            return f"Added auto-accept pattern for symbols: {', '.join(symbol_ids)}"
        
        elif sub_command == "remove":
            index = int(parts[1])
            if index < 0 or index >= len(self.auto_accept_patterns):
                return f"Invalid pattern index: {index}"
            
            removed = self.auto_accept_patterns.pop(index)
            return f"Removed auto-accept pattern for symbols: {', '.join(removed['symbols'])}"
        
        elif sub_command == "list":
            if not self.auto_accept_patterns:
                return "No auto-accept patterns defined"
            
            result = ["Auto-Accept Patterns:"]
            for i, pattern in enumerate(self.auto_accept_patterns):
                symbols_str = ', '.join(pattern['symbols'])
                result.append(f"{i}: Symbols: {symbols_str}, Pattern: {pattern['pattern']}")
            
            return "\n".join(result)
        
        else:
            return f"Unknown auto sub-command: {sub_command}"
    
    def process_text(self, text: str) -> Tuple[bool, str]:
        """
        Process text, checking for commands, hashtags, and auto-repeat patterns.
        
        Args:
            text: The text to process
            
        Returns:
            Tuple[bool, str]: (was_processed, response)
        """
        # Check if it's a command (starts with #)
        if text.strip().startswith('#'):
            # Log the command
            self.command_log.append({
                "command": text,
                "timestamp": time.time(),
                "turn": self.symbol_system.turn_count,
                "dimension": self.symbol_system.current_dimension
            })
            
            # Process the command
            success, response = self.symbol_system.process_command(text)
            return success, response
        
        # Check for hashtags in the text
        hashtags = []
        words = text.split()
        for word in words:
            if word.startswith('#'):
                hashtags.append(word)
        
        # If hashtags found, collect the associated symbols
        associated_symbols = []
        for hashtag in hashtags:
            symbols = self.symbol_system.find_symbols_by_hashtag(hashtag)
            associated_symbols.extend(symbols)
        
        # Check auto-repeat patterns if we have associated symbols
        if associated_symbols:
            symbol_ids = [s.id for s in associated_symbols]
            
            # Check for auto-repetition
            if self.symbol_system.auto_repetition_check(text, symbol_ids):
                return True, "Auto-repetition detected: " + ", ".join(symbol_ids)
            
            # Check against auto-accept patterns
            for pattern_def in self.auto_accept_patterns:
                pattern_symbols = pattern_def["symbols"]
                pattern = pattern_def["pattern"]
                
                # If any of the pattern symbols match our associated symbols
                if any(sym_id in symbol_ids for sym_id in pattern_symbols):
                    if pattern in text:
                        return True, f"Auto-accept pattern matched: {pattern}"
        
        # If text wasn't processed by any special handler
        return False, "Text received but not processed by the symbol system"
    
    def connect_with_turn_system(self, turn_system) -> bool:
        """
        Connect with an existing turn system from the 12 turns system.
        
        Args:
            turn_system: The turn system object to connect with
            
        Returns:
            bool: True if connected successfully, False otherwise
        """
        try:
            # Update current turn and dimension from the turn system
            self.symbol_system.turn_count = turn_system.current_turn
            self.symbol_system.current_dimension = turn_system.current_dimension
            
            # Connect signals if available (for GDScript integration)
            if hasattr(turn_system, "connect"):
                turn_system.connect("turn_changed", 
                                    lambda t: self._on_turn_changed(t))
                turn_system.connect("dimension_changed", 
                                    lambda new_dim, old_dim: self._on_dimension_changed(new_dim, old_dim))
            
            return True
        except Exception as e:
            print(f"Error connecting with turn system: {str(e)}")
            return False
    
    def _on_turn_changed(self, new_turn: int) -> None:
        """Handler for turn change events"""
        self.symbol_system.turn_count = new_turn
        
        # Save the turn state
        self.turn_history.append({
            "turn": new_turn,
            "dimension": self.symbol_system.current_dimension,
            "timestamp": time.time()
        })
    
    def _on_dimension_changed(self, new_dimension: int, old_dimension: int) -> None:
        """Handler for dimension change events"""
        self.symbol_system.current_dimension = new_dimension
        
        # Find symbols associated with this dimension
        dimension_symbols = self.symbol_system.get_dimension_symbols()
        
        print(f"Dimension changed from {old_dimension} to {new_dimension}")
        print(f"Found {len(dimension_symbols)} symbols for dimension {new_dimension}")


# Helper functions for the module

def create_symbol_system(config_path: str = None, processing_mode: str = "standard") -> Tuple[SymbolReasonSystem, AutoRepeatConnector]:
    """
    Create a new symbol system with auto-repeat connector.
    
    Args:
        config_path: Path to configuration file
        processing_mode: Processing mode (low_resource, standard, enhanced)
        
    Returns:
        Tuple containing the symbol system and connector
    """
    if config_path is None:
        config_path = DEFAULT_CONFIG_PATH
    
    try:
        proc_mode = ProcessingMode(processing_mode)
    except ValueError:
        proc_mode = ProcessingMode.STANDARD
    
    symbol_system = SymbolReasonSystem(config_path=config_path, processing_mode=proc_mode)
    connector = AutoRepeatConnector(symbol_system)
    
    return symbol_system, connector

def load_symbol_system(symbols_path: str, config_path: str = None) -> Tuple[Optional[SymbolReasonSystem], Optional[AutoRepeatConnector]]:
    """
    Load a symbol system from saved files.
    
    Args:
        symbols_path: Path to saved symbols file
        config_path: Path to configuration file
        
    Returns:
        Tuple containing the loaded symbol system and connector, or None if loading failed
    """
    if config_path is None:
        config_path = DEFAULT_CONFIG_PATH
    
    try:
        symbol_system = SymbolReasonSystem(config_path=config_path)
        if not symbol_system.load_symbols(symbols_path):
            return None, None
        
        connector = AutoRepeatConnector(symbol_system)
        return symbol_system, connector
    except Exception as e:
        print(f"Error loading symbol system: {str(e)}")
        return None, None

def hash_icon_data(icon_data: bytes) -> str:
    """
    Generate a hash for icon data.
    
    Args:
        icon_data: The raw icon data as bytes
        
    Returns:
        str: The base64-encoded hash
    """
    hash_value = hashlib.sha256(icon_data).digest()
    return base64.b64encode(hash_value).decode('utf-8')

def main():
    """Main function for command line usage"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Symbol Reason System")
    parser.add_argument('--create', action='store_true', help="Create a new symbol system")
    parser.add_argument('--load', type=str, help="Load a symbol system from file")
    parser.add_argument('--save', type=str, help="Save a symbol system to file")
    parser.add_argument('--visualize', type=str, choices=['text', 'html', 'json'], 
                       default='text', help="Visualize the symbol system")
    parser.add_argument('--config', type=str, help="Path to configuration file")
    parser.add_argument('--mode', type=str, choices=['low_resource', 'standard', 'enhanced'],
                       default='standard', help="Processing mode")
    
    args = parser.parse_args()
    
    if args.create:
        system, connector = create_symbol_system(args.config, args.mode)
        print(f"Created new symbol system in {args.mode} mode")
        
        # Add some example symbols
        system.create_symbol("example_visual", SymbolType.VISUAL, "Example visual symbol", 
                           AttentionLevel.HIGH, hashtags=["example", "visual"])
        system.create_symbol("example_textual", SymbolType.TEXTUAL, "Example textual symbol", 
                           AttentionLevel.MEDIUM, hashtags=["example", "text"])
        system.create_symbol("example_conceptual", SymbolType.CONCEPTUAL, "Example conceptual symbol", 
                           AttentionLevel.LOW, hashtags=["example", "concept"])
                           
        # Add reasons
        system.add_reason_to_symbol("example_visual", "reason1", ReasonType.FUNCTIONAL, 
                                  "This is a functional reason")
        system.add_reason_to_symbol("example_textual", "reason2", ReasonType.SEMANTIC, 
                                  "This is a semantic reason")
                                  
        # Connect symbols
        system.connect_symbols("example_visual", "example_textual", "connection1", 
                             relationship_type="illustrates")
        system.connect_symbols("example_conceptual", "example_visual", "connection2", 
                             relationship_type="manifests")
        
        # Visualize
        visualization = system.visualize_symbols(args.visualize)
        print(visualization)
        
        # Save if requested
        if args.save:
            if system.save_symbols(args.save):
                print(f"Saved symbol system to {args.save}")
            else:
                print("Failed to save symbol system")
    
    elif args.load:
        system, connector = load_symbol_system(args.load, args.config)
        if system and connector:
            print(f"Loaded symbol system from {args.load}")
            
            # Visualize
            visualization = system.visualize_symbols(args.visualize)
            print(visualization)
            
            # Save to a different file if requested
            if args.save and args.save != args.load:
                if system.save_symbols(args.save):
                    print(f"Saved symbol system to {args.save}")
                else:
                    print("Failed to save symbol system")
        else:
            print(f"Failed to load symbol system from {args.load}")
    
    else:
        parser.print_help()

if __name__ == "__main__":
    main()