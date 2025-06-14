#!/usr/bin/env python3
# Connection Manager - Enhances connection capabilities for WishConsole
# Provides advanced connection features, visualization, and synchronization

import os
import sys
import time
import json
import random
import threading
import requests
import socket
from datetime import datetime
from typing import Dict, List, Any, Optional, Tuple, Set

class ConnectionType:
    """Defines different types of connections with their properties"""
    API = "api"           # External API connections
    MEMORY = "memory"     # Memory system connections
    DRIVE = "drive"       # Drive system connections
    DIMENSION = "dimension" # Dimensional connections
    GODOT = "godot"       # Connection to Godot visualization
    TERMINAL = "terminal" # Terminal interface connections
    NETWORK = "network"   # Network connections
    REASON = "reason"     # Reason engine connections
    SHAPE = "shape"       # Shape system connections

class ConnectionState:
    """Possible states for a connection"""
    ACTIVE = "active"     # Connection is active and healthy
    DORMANT = "dormant"   # Connection is established but inactive
    FAILED = "failed"     # Connection attempt failed
    UNKNOWN = "unknown"   # Connection state is unknown
    GLITCHED = "glitched" # Connection is experiencing glitches
    HEALING = "healing"   # Connection is in healing process
    SYNCING = "syncing"   # Connection is synchronizing
    EVOLVING = "evolving" # Connection is evolving/upgrading

class Connection:
    """Represents a connection between system components"""
    
    def __init__(self, 
                 name: str, 
                 conn_type: str,
                 source: str,
                 target: str,
                 properties: Dict[str, Any] = None):
        self.name = name
        self.conn_type = conn_type
        self.source = source
        self.target = target
        self.properties = properties or {}
        self.state = ConnectionState.UNKNOWN
        self.created_at = datetime.now()
        self.last_active = None
        self.attempts = 0
        self.success_count = 0
        self.failure_count = 0
        self.glitch_level = 0
        self.latency = 0.0  # Connection latency in seconds
        self.bandwidth = 0.0  # Connection bandwidth capacity
        
    def activate(self) -> bool:
        """Attempt to activate the connection"""
        self.attempts += 1
        
        # Simulate connection activation logic
        success = random.random() > (0.1 * self.failure_count)
        
        if success:
            self.state = ConnectionState.ACTIVE
            self.last_active = datetime.now()
            self.success_count += 1
            self.latency = random.uniform(0.01, 0.5)  # Simulate latency
            return True
        else:
            self.state = ConnectionState.FAILED
            self.failure_count += 1
            return False
            
    def deactivate(self) -> None:
        """Deactivate the connection"""
        self.state = ConnectionState.DORMANT
    
    def introduce_glitch(self, level: int = 1) -> None:
        """Introduce a glitch to the connection"""
        self.glitch_level = min(level, 9)  # Cap at level 9
        self.state = ConnectionState.GLITCHED
        
        # Apply glitch effects to properties
        for key in self.properties:
            if isinstance(self.properties[key], str) and random.random() < 0.3:
                # Randomly glitch string values
                self.properties[key] = self._glitch_string(self.properties[key])
    
    def _glitch_string(self, text: str) -> str:
        """Apply glitch effects to a string based on glitch level"""
        if not text or self.glitch_level == 0:
            return text
            
        glitch_chars = "█▓▒░█▓▒░!@#$%^&*()_+-="
        result = list(text)
        
        # Replace characters based on glitch level
        for i in range(min(self.glitch_level * 2, len(text))):
            idx = random.randint(0, len(text) - 1)
            result[idx] = random.choice(glitch_chars)
            
        return ''.join(result)
    
    def heal(self) -> bool:
        """Attempt to heal a glitched connection"""
        if self.state != ConnectionState.GLITCHED:
            return True
            
        # Healing chance decreases with glitch level
        success = random.random() > (self.glitch_level * 0.1)
        
        if success:
            self.state = ConnectionState.HEALING
            self.glitch_level = max(0, self.glitch_level - 1)
            
            if self.glitch_level == 0:
                self.state = ConnectionState.ACTIVE
                
            return True
        return False
        
    def to_dict(self) -> Dict[str, Any]:
        """Convert connection to dictionary for saving"""
        return {
            "name": self.name,
            "type": self.conn_type,
            "source": self.source,
            "target": self.target,
            "properties": self.properties,
            "state": self.state,
            "created_at": self.created_at.isoformat(),
            "last_active": self.last_active.isoformat() if self.last_active else None,
            "attempts": self.attempts,
            "success_count": self.success_count,
            "failure_count": self.failure_count,
            "glitch_level": self.glitch_level,
            "latency": self.latency,
            "bandwidth": self.bandwidth
        }
        
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'Connection':
        """Create connection from dictionary"""
        conn = cls(
            name=data["name"],
            conn_type=data["type"],
            source=data["source"],
            target=data["target"],
            properties=data["properties"]
        )
        
        conn.state = data["state"]
        conn.created_at = datetime.fromisoformat(data["created_at"])
        conn.last_active = datetime.fromisoformat(data["last_active"]) if data["last_active"] else None
        conn.attempts = data["attempts"]
        conn.success_count = data["success_count"]
        conn.failure_count = data["failure_count"]
        conn.glitch_level = data["glitch_level"]
        conn.latency = data["latency"]
        conn.bandwidth = data["bandwidth"]
        
        return conn

class ConnectionPath:
    """Represents a path of connections between source and destination"""
    
    def __init__(self, source: str, destination: str):
        self.source = source
        self.destination = destination
        self.connections: List[Connection] = []
        self.active = False
        self.total_latency = 0.0
        self.bottleneck = 0.0
        
    def add_connection(self, connection: Connection) -> None:
        """Add a connection to the path"""
        self.connections.append(connection)
        self._recalculate_metrics()
        
    def _recalculate_metrics(self) -> None:
        """Recalculate path metrics"""
        self.total_latency = sum(c.latency for c in self.connections)
        self.bottleneck = min(c.bandwidth for c in self.connections) if self.connections else 0
        self.active = all(c.state == ConnectionState.ACTIVE for c in self.connections)
        
    def activate_path(self) -> bool:
        """Attempt to activate the entire path"""
        success = True
        for connection in self.connections:
            if not connection.activate():
                success = False
                
        self._recalculate_metrics()
        return success
        
    def find_alternative_path(self, available_connections: List[Connection]) -> Optional['ConnectionPath']:
        """Find an alternative path if this one fails"""
        # Simple implementation - in real system would use pathfinding algorithm
        alt_path = ConnectionPath(self.source, self.destination)
        
        # Find connections that connect source to destination but aren't in current path
        connection_ids = {c.name for c in self.connections}
        for conn in available_connections:
            if (conn.name not in connection_ids and
                conn.source == self.source and 
                conn.target == self.destination):
                alt_path.add_connection(conn)
                return alt_path
                
        return None
        
    def to_dict(self) -> Dict[str, Any]:
        """Convert path to dictionary for saving"""
        return {
            "source": self.source,
            "destination": self.destination,
            "connections": [c.name for c in self.connections],
            "active": self.active,
            "total_latency": self.total_latency,
            "bottleneck": self.bottleneck
        }

class ConnectionManager:
    """Manages system connections and provides visualization"""
    
    def __init__(self):
        self.connections: Dict[str, Connection] = {}
        self.paths: Dict[str, ConnectionPath] = {}
        self.monitor_thread = None
        self.running = False
        self.heal_cycle = 0
        
    def add_connection(self, connection: Connection) -> None:
        """Add a new connection to the manager"""
        self.connections[connection.name] = connection
        
    def remove_connection(self, name: str) -> None:
        """Remove a connection from the manager"""
        if name in self.connections:
            del self.connections[name]
            
    def get_connection(self, name: str) -> Optional[Connection]:
        """Get a connection by name"""
        return self.connections.get(name)
        
    def create_connection(self, 
                         name: str, 
                         conn_type: str,
                         source: str,
                         target: str,
                         properties: Dict[str, Any] = None) -> Connection:
        """Create and add a new connection"""
        connection = Connection(name, conn_type, source, target, properties)
        self.add_connection(connection)
        return connection
    
    def create_path(self, source: str, destination: str, connection_names: List[str]) -> Optional[ConnectionPath]:
        """Create a path between source and destination using specified connections"""
        path = ConnectionPath(source, destination)
        
        for name in connection_names:
            conn = self.get_connection(name)
            if conn:
                path.add_connection(conn)
            else:
                print(f"Warning: Connection '{name}' not found")
                
        path_id = f"{source}_to_{destination}"
        self.paths[path_id] = path
        return path
        
    def start_monitor(self) -> None:
        """Start connection monitoring thread"""
        def monitor_connections():
            while self.running:
                # Check all connections
                for name, conn in self.connections.items():
                    if conn.state == ConnectionState.ACTIVE:
                        # Randomly introduce glitches
                        if random.random() < 0.01:  # 1% chance of glitch
                            conn.introduce_glitch(random.randint(1, 3))
                
                # Healing cycle
                if self.heal_cycle % 10 == 0:  # Every 10 cycles
                    for name, conn in self.connections.items():
                        if conn.state == ConnectionState.GLITCHED:
                            conn.heal()
                
                self.heal_cycle += 1
                time.sleep(1)  # Check every second
        
        self.running = True
        self.monitor_thread = threading.Thread(target=monitor_connections)
        self.monitor_thread.daemon = True
        self.monitor_thread.start()
        
    def stop_monitor(self) -> None:
        """Stop connection monitoring"""
        self.running = False
        if self.monitor_thread:
            self.monitor_thread.join(timeout=1.0)
            
    def visualize_connections(self, color_enabled: bool = True) -> str:
        """Generate ASCII visualization of connections"""
        result = []
        result.append("CONNECTION VISUALIZATION")
        result.append("=======================")
        
        # Group connections by type
        conn_by_type: Dict[str, List[Connection]] = {}
        for conn in self.connections.values():
            if conn.conn_type not in conn_by_type:
                conn_by_type[conn.conn_type] = []
            conn_by_type[conn.conn_type].append(conn)
            
        # Display connections by type
        for conn_type, conns in conn_by_type.items():
            result.append(f"\n[{conn_type.upper()} CONNECTIONS]")
            
            for conn in conns:
                # Get status indicator and color
                if conn.state == ConnectionState.ACTIVE:
                    status = "✓" if color_enabled else "ACTIVE"
                    color = "\033[92m" if color_enabled else ""  # Green
                elif conn.state == ConnectionState.GLITCHED:
                    status = "!" if color_enabled else "GLITCH"
                    color = "\033[91m" if color_enabled else ""  # Red
                elif conn.state == ConnectionState.FAILED:
                    status = "✗" if color_enabled else "FAILED"
                    color = "\033[31m" if color_enabled else ""  # Dark red
                else:
                    status = "○" if color_enabled else "DORMANT"
                    color = "\033[94m" if color_enabled else ""  # Blue
                
                reset = "\033[0m" if color_enabled else ""
                
                # Format connection info
                latency_info = f"{conn.latency:.2f}s" if conn.latency > 0 else "N/A"
                glitch_info = f"G:{conn.glitch_level}" if conn.glitch_level > 0 else ""
                
                line = f"{color}{status}{reset} {conn.name:<20} {conn.source} → {conn.target} [{latency_info}] {glitch_info}"
                result.append(line)
                
        return "\n".join(result)
        
    def visualize_network_for_godot(self) -> Dict[str, Any]:
        """Generate visualization data for Godot integration"""
        nodes = {}
        edges = []
        
        # Create nodes for all sources and targets
        for conn in self.connections.values():
            if conn.source not in nodes:
                nodes[conn.source] = {
                    "id": conn.source,
                    "type": "source",
                    "connections": 0
                }
            
            if conn.target not in nodes:
                nodes[conn.target] = {
                    "id": conn.target,
                    "type": "target", 
                    "connections": 0
                }
                
            # Increment connection count
            nodes[conn.source]["connections"] += 1
            nodes[conn.target]["connections"] += 1
            
            # Create edge
            edge = {
                "source": conn.source,
                "target": conn.target,
                "type": conn.conn_type,
                "state": conn.state,
                "latency": conn.latency,
                "glitch_level": conn.glitch_level
            }
            edges.append(edge)
            
        return {
            "nodes": list(nodes.values()),
            "edges": edges
        }
        
    def save_to_file(self, filename: str) -> bool:
        """Save connection information to file"""
        try:
            data = {
                "connections": {name: conn.to_dict() for name, conn in self.connections.items()},
                "paths": {name: path.to_dict() for name, path in self.paths.items()}
            }
            
            with open(filename, "w") as f:
                json.dump(data, f, indent=2)
            return True
        except Exception as e:
            print(f"Error saving connections: {e}")
            return False
            
    def load_from_file(self, filename: str) -> bool:
        """Load connection information from file"""
        try:
            with open(filename, "r") as f:
                data = json.load(f)
                
            # Clear existing data
            self.connections = {}
            self.paths = {}
            
            # Load connections
            for name, conn_data in data.get("connections", {}).items():
                self.connections[name] = Connection.from_dict(conn_data)
                
            # TODO: Load paths
            # This would require reconstructing the Connection objects in the paths
            
            return True
        except Exception as e:
            print(f"Error loading connections: {e}")
            return False
            
    def integrate_with_wish_console(self, wish_console) -> None:
        """Integrate connection manager with wish console"""
        # Create API connections
        for api_name, api in wish_console.apis.items():
            conn_name = f"api_{api_name}"
            conn = self.create_connection(
                conn_name,
                ConnectionType.API,
                "wish_console",
                api_name,
                {"url": api.url, "is_online": api.is_online}
            )
            
            # Set state based on API status
            if api.is_online:
                conn.state = ConnectionState.ACTIVE
                conn.latency = api.response_time
            else:
                conn.state = ConnectionState.FAILED
        
        # Create memory connections
        for i, memory in enumerate(wish_console.memories):
            # Connect memories to their dimensions
            for dim in memory.dimensions:
                dim_name = wish_console.dimension_names.get(dim, f"DIM_{dim}")
                conn_name = f"mem_{i}_dim_{dim}"
                
                conn = self.create_connection(
                    conn_name,
                    ConnectionType.DIMENSION,
                    f"memory_{i}",
                    dim_name,
                    {"tags": memory.tags}
                )
                conn.state = ConnectionState.ACTIVE
        
        # Create drive connections
        drives = ["C", "D", "M", "G", "T", "L", "A", "E", "V"]
        for drive in drives:
            conn_name = f"drive_{drive}"
            conn = self.create_connection(
                conn_name,
                ConnectionType.DRIVE,
                "wish_console",
                f"drive_{drive}",
                {"drive_letter": drive}
            )
            conn.state = ConnectionState.DORMANT
            
            # Randomly activate some drives
            if random.random() < 0.7:  # 70% chance of being active
                conn.activate()

# Example usage
if __name__ == "__main__":
    # Create connection manager
    manager = ConnectionManager()
    
    # Create some test connections
    manager.create_connection(
        "api_openai",
        ConnectionType.API,
        "wish_console",
        "openai",
        {"url": "https://api.openai.com/v1"}
    )
    
    manager.create_connection(
        "mem_reality",
        ConnectionType.DIMENSION,
        "memory_0",
        "REALITY",
        {"tags": ["#1", "#memory"]}
    )
    
    manager.create_connection(
        "drive_c",
        ConnectionType.DRIVE,
        "wish_console",
        "drive_C",
        {"drive_letter": "C"}
    )
    
    # Activate connections
    for conn in manager.connections.values():
        conn.activate()
    
    # Start monitoring
    manager.start_monitor()
    
    # Visualize connections
    print(manager.visualize_connections())
    
    # Create a path
    manager.create_path(
        "wish_console",
        "REALITY",
        ["api_openai", "mem_reality"]
    )
    
    # Save to file
    manager.save_to_file("connections.json")
    
    # Cleanup
    manager.stop_monitor()