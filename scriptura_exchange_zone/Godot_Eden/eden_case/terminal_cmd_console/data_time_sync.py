#!/usr/bin/env python3
"""
Data Time Synchronization System
Core component for synchronizing time and space data across terminals and drives
"""
import os
import time
import json
import datetime
import uuid
import threading
from pathlib import Path

class DataTimeSync:
    def __init__(self, base_path=None, node_id=None):
        # Set up base path - where data will be stored
        self.base_path = base_path or os.path.join(os.path.expanduser("~"), "time_data_store")
        
        # Create directory if it doesn't exist
        os.makedirs(self.base_path, exist_ok=True)
        
        # Node identification (0 and 1 are special reserved IDs)
        self.node_id = node_id or str(uuid.uuid4())
        self.is_primary = self.node_id in ["0", "1"]
        
        # Storage for sync data
        self.time_markers = {}
        self.space_markers = {}
        self.sync_nodes = {}
        
        # Thread sync
        self.lock = threading.Lock()
        self.running = True
        
        # Start sync thread
        self.sync_thread = threading.Thread(target=self._sync_worker, daemon=True)
        self.sync_thread.start()
        
        print(f"DataTimeSync initialized with node_id: {self.node_id}")
        print(f"Storage path: {self.base_path}")
        print(f"Primary node: {self.is_primary}")

    def register_time_marker(self, marker_id, timestamp=None, metadata=None):
        """Register a time marker for synchronization"""
        with self.lock:
            timestamp = timestamp or time.time()
            
            marker = {
                "id": marker_id,
                "timestamp": timestamp,
                "registered_by": self.node_id,
                "datetime": datetime.datetime.fromtimestamp(timestamp).isoformat(),
                "metadata": metadata or {}
            }
            
            self.time_markers[marker_id] = marker
            self._save_data("time_markers.json", self.time_markers)
            
            return marker

    def register_space_marker(self, marker_id, coordinates, metadata=None):
        """Register a space marker for synchronization"""
        with self.lock:
            marker = {
                "id": marker_id,
                "coordinates": coordinates,
                "registered_by": self.node_id,
                "timestamp": time.time(),
                "metadata": metadata or {}
            }
            
            self.space_markers[marker_id] = marker
            self._save_data("space_markers.json", self.space_markers)
            
            return marker

    def register_sync_node(self, node_id, node_type, capabilities=None):
        """Register another node for synchronization"""
        with self.lock:
            node = {
                "id": node_id,
                "type": node_type,
                "capabilities": capabilities or [],
                "last_seen": time.time(),
                "registered_by": self.node_id
            }
            
            self.sync_nodes[node_id] = node
            self._save_data("sync_nodes.json", self.sync_nodes)
            
            return node

    def get_time_marker(self, marker_id):
        """Get a time marker by ID"""
        with self.lock:
            return self.time_markers.get(marker_id)

    def get_space_marker(self, marker_id):
        """Get a space marker by ID"""
        with self.lock:
            return self.space_markers.get(marker_id)

    def get_all_time_markers(self):
        """Get all time markers"""
        with self.lock:
            return dict(self.time_markers)

    def get_all_space_markers(self):
        """Get all space markers"""
        with self.lock:
            return dict(self.space_markers)

    def get_all_sync_nodes(self):
        """Get all synchronized nodes"""
        with self.lock:
            return dict(self.sync_nodes)

    def calculate_time_delta(self, marker_id1, marker_id2):
        """Calculate time difference between two markers"""
        marker1 = self.get_time_marker(marker_id1)
        marker2 = self.get_time_marker(marker_id2)
        
        if not marker1 or not marker2:
            return None
        
        return marker2["timestamp"] - marker1["timestamp"]

    def calculate_space_distance(self, marker_id1, marker_id2):
        """Calculate space distance between two markers"""
        marker1 = self.get_space_marker(marker_id1)
        marker2 = self.get_space_marker(marker_id2)
        
        if not marker1 or not marker2:
            return None
        
        # Simple Euclidean distance
        coords1 = marker1["coordinates"]
        coords2 = marker2["coordinates"]
        
        # Make sure we have the same dimensions
        dimensions = min(len(coords1), len(coords2))
        
        sum_squared = 0
        for i in range(dimensions):
            sum_squared += (coords2[i] - coords1[i]) ** 2
            
        return sum_squared ** 0.5

    def sync_with_other_nodes(self):
        """Force synchronization with other nodes"""
        self._load_data_from_all_drives()
        return {
            "time_markers": len(self.time_markers),
            "space_markers": len(self.space_markers),
            "sync_nodes": len(self.sync_nodes)
        }

    def _save_data(self, filename, data):
        """Save data to JSON file"""
        file_path = os.path.join(self.base_path, filename)
        
        try:
            with open(file_path, 'w') as f:
                json.dump(data, f, indent=2)
            return True
        except Exception as e:
            print(f"Error saving {filename}: {e}")
            return False

    def _load_data(self, filename):
        """Load data from JSON file"""
        file_path = os.path.join(self.base_path, filename)
        
        if not os.path.exists(file_path):
            return {}
        
        try:
            with open(file_path, 'r') as f:
                return json.load(f)
        except Exception as e:
            print(f"Error loading {filename}: {e}")
            return {}

    def _load_data_from_drive(self, drive_path):
        """Load data from a specific drive path"""
        time_path = os.path.join(drive_path, "time_markers.json")
        space_path = os.path.join(drive_path, "space_markers.json")
        nodes_path = os.path.join(drive_path, "sync_nodes.json")
        
        # Check if paths exist
        data_found = False
        
        if os.path.exists(time_path):
            try:
                with open(time_path, 'r') as f:
                    time_data = json.load(f)
                    with self.lock:
                        for marker_id, marker in time_data.items():
                            if marker_id not in self.time_markers:
                                self.time_markers[marker_id] = marker
                    data_found = True
            except Exception as e:
                print(f"Error loading time markers from {drive_path}: {e}")
        
        if os.path.exists(space_path):
            try:
                with open(space_path, 'r') as f:
                    space_data = json.load(f)
                    with self.lock:
                        for marker_id, marker in space_data.items():
                            if marker_id not in self.space_markers:
                                self.space_markers[marker_id] = marker
                    data_found = True
            except Exception as e:
                print(f"Error loading space markers from {drive_path}: {e}")
        
        if os.path.exists(nodes_path):
            try:
                with open(nodes_path, 'r') as f:
                    nodes_data = json.load(f)
                    with self.lock:
                        for node_id, node in nodes_data.items():
                            if node_id not in self.sync_nodes:
                                self.sync_nodes[node_id] = node
                    data_found = True
            except Exception as e:
                print(f"Error loading sync nodes from {drive_path}: {e}")
        
        return data_found

    def _load_data_from_all_drives(self):
        """Attempt to load data from all available drives"""
        # Load local data first
        self.time_markers = self._load_data("time_markers.json")
        self.space_markers = self._load_data("space_markers.json")
        self.sync_nodes = self._load_data("sync_nodes.json")
        
        # Look for other potential storage locations
        potential_paths = []
        
        # Windows drive letters
        for letter in "CDEFGHIJKLMNOPQRSTUVWXYZ":
            drive = f"{letter}:"
            sync_dir = os.path.join(drive, "time_data_store")
            if os.path.exists(sync_dir):
                potential_paths.append(sync_dir)
        
        # Linux common mount points
        for mount in ["/mnt", "/media"]:
            if os.path.exists(mount):
                for subdir in os.listdir(mount):
                    sync_dir = os.path.join(mount, subdir, "time_data_store")
                    if os.path.exists(sync_dir):
                        potential_paths.append(sync_dir)
        
        # Home directory for other users
        home_base = os.path.expanduser("~")
        home_parent = os.path.dirname(home_base)
        for subdir in os.listdir(home_parent):
            user_home = os.path.join(home_parent, subdir)
            if os.path.isdir(user_home):
                sync_dir = os.path.join(user_home, "time_data_store")
                if os.path.exists(sync_dir):
                    potential_paths.append(sync_dir)
        
        # Load from each path
        for path in potential_paths:
            if path != self.base_path:  # Skip own path
                self._load_data_from_drive(path)
        
        # Save merged data back
        self._save_data("time_markers.json", self.time_markers)
        self._save_data("space_markers.json", self.space_markers)
        self._save_data("sync_nodes.json", self.sync_nodes)

    def _sync_worker(self):
        """Background thread for periodic synchronization"""
        while self.running:
            # Update this node's timestamp
            if self.node_id in self.sync_nodes:
                self.sync_nodes[self.node_id]["last_seen"] = time.time()
            else:
                # Register self if not registered
                self.register_sync_node(
                    self.node_id,
                    "primary" if self.is_primary else "secondary",
                    ["time", "space", "sync"]
                )
            
            # Save updated node data
            self._save_data("sync_nodes.json", self.sync_nodes)
            
            # Sync with other nodes periodically
            self._load_data_from_all_drives()
            
            # Sleep for a while
            time.sleep(60)  # Sync every minute

    def shutdown(self):
        """Properly shutdown the sync system"""
        self.running = False
        if self.sync_thread.is_alive():
            self.sync_thread.join(2)  # Wait up to 2 seconds
        
        # Final save
        with self.lock:
            self._save_data("time_markers.json", self.time_markers)
            self._save_data("space_markers.json", self.space_markers)
            self._save_data("sync_nodes.json", self.sync_nodes)


# Command line interface
if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Data Time Synchronization System")
    parser.add_argument("--node-id", help="Node ID (0 and 1 are primary nodes)")
    parser.add_argument("--path", help="Base path for data storage")
    parser.add_argument("--time-marker", help="Register a time marker")
    parser.add_argument("--space-marker", help="Register a space marker (format: id,x,y,z)")
    parser.add_argument("--list", choices=["time", "space", "nodes"], help="List stored markers")
    parser.add_argument("--sync", action="store_true", help="Force synchronization")
    
    args = parser.parse_args()
    
    # Create sync system
    sync = DataTimeSync(args.path, args.node_id)
    
    # Process commands
    if args.time_marker:
        marker = sync.register_time_marker(args.time_marker)
        print(f"Registered time marker: {marker}")
    
    elif args.space_marker:
        parts = args.space_marker.split(",")
        if len(parts) >= 4:
            marker_id = parts[0]
            coordinates = [float(x) for x in parts[1:4]]
            marker = sync.register_space_marker(marker_id, coordinates)
            print(f"Registered space marker: {marker}")
        else:
            print("Invalid space marker format. Use: id,x,y,z")
    
    elif args.list:
        if args.list == "time":
            markers = sync.get_all_time_markers()
            print(f"Time Markers ({len(markers)}):")
            for marker_id, marker in markers.items():
                print(f"  {marker_id}: {marker['datetime']}")
        
        elif args.list == "space":
            markers = sync.get_all_space_markers()
            print(f"Space Markers ({len(markers)}):")
            for marker_id, marker in markers.items():
                print(f"  {marker_id}: {marker['coordinates']}")
        
        elif args.list == "nodes":
            nodes = sync.get_all_sync_nodes()
            print(f"Sync Nodes ({len(nodes)}):")
            for node_id, node in nodes.items():
                last_seen = datetime.datetime.fromtimestamp(node["last_seen"]).strftime("%Y-%m-%d %H:%M:%S")
                print(f"  {node_id} ({node['type']}): Last seen {last_seen}")
    
    elif args.sync:
        result = sync.sync_with_other_nodes()
        print(f"Synchronization complete: {result}")
    
    else:
        # Interactive mode
        print("====================================")
        print("Data Time Sync Interactive Terminal")
        print("====================================")
        print("Type 'help' for available commands")
        
        while True:
            try:
                cmd = input("> ").strip()
                
                if cmd == "exit" or cmd == "quit":
                    break
                
                elif cmd == "help":
                    print("Available commands:")
                    print("  time <id> [metadata]  - Create a time marker")
                    print("  space <id> x y z      - Create a space marker")
                    print("  list time             - List all time markers")
                    print("  list space            - List all space markers")
                    print("  list nodes            - List all sync nodes")
                    print("  sync                  - Force synchronization")
                    print("  exit/quit             - Exit program")
                
                elif cmd.startswith("time "):
                    parts = cmd[5:].split(" ", 1)
                    marker_id = parts[0]
                    metadata = None
                    if len(parts) > 1:
                        metadata = {"note": parts[1]}
                    
                    marker = sync.register_time_marker(marker_id, metadata=metadata)
                    print(f"Registered time marker: {marker['id']} at {marker['datetime']}")
                
                elif cmd.startswith("space "):
                    parts = cmd[6:].split()
                    if len(parts) >= 4:
                        marker_id = parts[0]
                        try:
                            coordinates = [float(parts[1]), float(parts[2]), float(parts[3])]
                            marker = sync.register_space_marker(marker_id, coordinates)
                            print(f"Registered space marker: {marker['id']} at {marker['coordinates']}")
                        except ValueError:
                            print("Invalid coordinates. Must be numbers.")
                    else:
                        print("Invalid command. Format: space <id> x y z")
                
                elif cmd == "list time":
                    markers = sync.get_all_time_markers()
                    print(f"Time Markers ({len(markers)}):")
                    for marker_id, marker in markers.items():
                        print(f"  {marker_id}: {marker['datetime']}")
                
                elif cmd == "list space":
                    markers = sync.get_all_space_markers()
                    print(f"Space Markers ({len(markers)}):")
                    for marker_id, marker in markers.items():
                        print(f"  {marker_id}: {marker['coordinates']}")
                
                elif cmd == "list nodes":
                    nodes = sync.get_all_sync_nodes()
                    print(f"Sync Nodes ({len(nodes)}):")
                    for node_id, node in nodes.items():
                        last_seen = datetime.datetime.fromtimestamp(node["last_seen"]).strftime("%Y-%m-%d %H:%M:%S")
                        print(f"  {node_id} ({node['type']}): Last seen {last_seen}")
                
                elif cmd == "sync":
                    result = sync.sync_with_other_nodes()
                    print(f"Synchronization complete: {result}")
                
                else:
                    print("Unknown command. Type 'help' for available commands")
            
            except KeyboardInterrupt:
                break
            except Exception as e:
                print(f"Error: {e}")
    
    # Clean shutdown
    sync.shutdown()
    print("Data Time Sync terminated")