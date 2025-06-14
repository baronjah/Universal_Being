#!/usr/bin/env python3
"""
Project Organization System

This module provides functionality for organizing projects, folders, and chat files
into a structured system with integration for various tools. It connects with the
symbol evolution system and memory fold bridge to provide a comprehensive framework
for project management with symbolic reasoning.

Core concepts:
- Project/folder/chat separation with clear boundaries
- Tool integration across different project components
- Symbol-based project organization
- Memory persistence across project structures
"""

import os
import time
import json
import hashlib
import random
import re
import shutil
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
    from memory_fold_bridge import MemoryFoldManager, MemoryBridge, MemoryTransferMode
    MEMORY_FOLD_AVAILABLE = True
except ImportError:
    MEMORY_FOLD_AVAILABLE = False
    print("Warning: memory_fold_bridge not available, some features disabled")

try:
    from symbol_reason_system import Symbol, Reason, IconHash, SymbolConnection
    SYMBOL_REASON_AVAILABLE = True
except ImportError:
    SYMBOL_REASON_AVAILABLE = False
    print("Warning: symbol_reason_system not available, some features disabled")

# Constants
DEFAULT_PROJECTS_ROOT = os.path.expanduser("~/projects")
DEFAULT_CHAT_ROOT = os.path.expanduser("~/chats")
DEFAULT_TOOLS_ROOT = os.path.expanduser("~/tools")
MAX_PROJECT_NAME_LENGTH = 50
VALID_PROJECT_NAME_PATTERN = r'^[a-zA-Z0-9_\-]+$'
DEFAULT_CLAUDE_FILE = "CLAUDE.md"
PROJECT_CONFIG_FILENAME = "project_config.json"
TOOL_CONFIG_FILENAME = "tool_config.json"
CHAT_HISTORY_FILENAME = "chat_history.json"

class ProjectType(Enum):
    """Types of projects"""
    STANDARD = auto()      # Regular project structure
    SYMBOLIC = auto()      # Symbol-based project
    MEMORY = auto()        # Memory-oriented project
    VISUALIZATION = auto() # Visualization-focused project
    INTEGRATION = auto()   # Tool integration project
    DISTRIBUTED = auto()   # Multi-location project
    EVOLUTION = auto()     # Data evolution project
    EXPERIMENTAL = auto()  # Experimental structure

class ToolIntegrationType(Enum):
    """Types of tool integrations"""
    EMBEDDED = auto()      # Integrated within project
    LINKED = auto()        # Referenced from external location
    SYMBOLIC = auto()      # Symbol-based integration
    API = auto()           # Connected via API
    COMMAND = auto()       # Command-line integration
    SHARED_MEMORY = auto() # Shared memory space
    BRIDGE = auto()        # Connected via bridge
    CUSTOM = auto()        # Custom integration method

class ChatStatus(Enum):
    """Status of chat sessions"""
    ACTIVE = auto()        # Currently in use
    ARCHIVED = auto()      # Stored for reference
    TEMPLATE = auto()      # Used as template
    EVOLVING = auto()      # Under active development
    MERGED = auto()        # Combined from multiple chats
    SPLIT = auto()         # Divided from single chat
    SYMBOLIC = auto()      # Symbol-based chat
    HISTORICAL = auto()    # Historical reference

class Project:
    """Represents a project with its structure and metadata"""
    
    def __init__(self, 
                 name: str, 
                 root_path: Optional[str] = None,
                 project_type: ProjectType = ProjectType.STANDARD,
                 description: str = ""):
        """Initialize a project"""
        self.name = name
        self.project_type = project_type
        self.description = description
        self.creation_time = time.time()
        self.last_modified = self.creation_time
        self.root_path = root_path or os.path.join(DEFAULT_PROJECTS_ROOT, name)
        self.folders: Dict[str, Dict[str, Any]] = {}
        self.tools: Dict[str, Dict[str, Any]] = {}
        self.chats: Dict[str, Dict[str, Any]] = {}
        self.symbols: Dict[str, Dict[str, Any]] = {}
        self.metadata: Dict[str, Any] = {}
        self.tags: Set[str] = set()
        self._lock = Lock()
        
        self.symbol_evolution = None
        self.memory_fold_manager = None
        
        # Create folder structure if it doesn't exist
        self._init_structure()
        self._init_integrations()
    
    def _init_structure(self) -> None:
        """Initialize the project folder structure"""
        # Create project root
        os.makedirs(self.root_path, exist_ok=True)
        
        # Create standard folders based on project type
        standard_folders = ["src", "docs", "resources", "tools", "tests", "chats"]
        
        if self.project_type == ProjectType.SYMBOLIC:
            standard_folders.extend(["symbols", "reasons", "connections"])
        
        if self.project_type == ProjectType.MEMORY:
            standard_folders.extend(["memories", "bridges", "dimensions"])
        
        if self.project_type == ProjectType.VISUALIZATION:
            standard_folders.extend(["visuals", "models", "data"])
        
        if self.project_type == ProjectType.EVOLUTION:
            standard_folders.extend(["stages", "cycles", "transforms"])
        
        # Create folders and add to dictionary
        for folder in standard_folders:
            folder_path = os.path.join(self.root_path, folder)
            os.makedirs(folder_path, exist_ok=True)
            
            self.folders[folder] = {
                "path": folder_path,
                "creation_time": time.time(),
                "last_modified": time.time(),
                "files": []
            }
        
        # Create project configuration file
        self._create_project_config()
    
    def _create_project_config(self) -> None:
        """Create the project configuration file"""
        config = {
            "name": self.name,
            "type": self.project_type.name,
            "description": self.description,
            "creation_time": self.creation_time,
            "last_modified": self.last_modified,
            "folders": list(self.folders.keys()),
            "tools": [],
            "chats": [],
            "symbols": [],
            "metadata": self.metadata,
            "tags": list(self.tags)
        }
        
        config_path = os.path.join(self.root_path, PROJECT_CONFIG_FILENAME)
        
        with open(config_path, 'w') as f:
            json.dump(config, f, indent=2)
    
    def _init_integrations(self) -> None:
        """Initialize integrations with other systems"""
        if SYMBOL_EVOLUTION_AVAILABLE:
            try:
                self.symbol_evolution = SymbolEvolution()
                
                # Create project-specific pool
                pool_id = f"project_{self.name.lower().replace(' ', '_')}"
                
                dimension = DataDimension.STRUCTURAL
                if self.project_type == ProjectType.SYMBOLIC:
                    dimension = DataDimension.CONCEPTUAL
                elif self.project_type == ProjectType.MEMORY:
                    dimension = DataDimension.META
                elif self.project_type == ProjectType.VISUALIZATION:
                    dimension = DataDimension.VISUAL
                
                # Try to create the pool
                try:
                    self.symbol_evolution.create_pool(
                        pool_id=pool_id,
                        drive="C",  # Default drive
                        dimension=dimension
                    )
                    
                    # Set as active pool
                    self.symbol_evolution.set_active_pool(pool_id)
                except Exception as e:
                    print(f"Error creating symbol evolution pool: {e}")
            except Exception as e:
                print(f"Error initializing symbol evolution: {e}")
        
        if MEMORY_FOLD_AVAILABLE:
            try:
                # Find Claude file in project
                claude_path = os.path.join(self.root_path, DEFAULT_CLAUDE_FILE)
                if not os.path.exists(claude_path):
                    # Use default if not found
                    claude_path = None
                
                self.memory_fold_manager = MemoryFoldManager(claude_file_path=claude_path)
            except Exception as e:
                print(f"Error initializing memory fold manager: {e}")
    
    def add_folder(self, name: str, description: str = "") -> bool:
        """Add a folder to the project"""
        with self._lock:
            if name in self.folders:
                return False
            
            folder_path = os.path.join(self.root_path, name)
            os.makedirs(folder_path, exist_ok=True)
            
            self.folders[name] = {
                "path": folder_path,
                "description": description,
                "creation_time": time.time(),
                "last_modified": time.time(),
                "files": []
            }
            
            self.last_modified = time.time()
            self._update_project_config()
            
            return True
    
    def add_tool(self, 
                name: str, 
                tool_path: str, 
                integration_type: ToolIntegrationType = ToolIntegrationType.LINKED,
                description: str = "") -> bool:
        """Add a tool to the project"""
        with self._lock:
            if name in self.tools:
                return False
            
            # Create tool config
            tool_config = {
                "name": name,
                "path": tool_path,
                "integration_type": integration_type.name,
                "description": description,
                "creation_time": time.time(),
                "last_modified": time.time(),
                "active": True,
                "metadata": {}
            }
            
            # Create tool directory if needed
            tools_dir = os.path.join(self.root_path, "tools")
            os.makedirs(tools_dir, exist_ok=True)
            
            # Create tool config file
            tool_config_path = os.path.join(tools_dir, f"{name}_{TOOL_CONFIG_FILENAME}")
            
            with open(tool_config_path, 'w') as f:
                json.dump(tool_config, f, indent=2)
            
            # Add to tools dictionary
            self.tools[name] = tool_config
            
            # Update project config
            self.last_modified = time.time()
            self._update_project_config()
            
            return True
    
    def create_chat(self, 
                   name: str, 
                   status: ChatStatus = ChatStatus.ACTIVE,
                   description: str = "") -> bool:
        """Create a new chat for the project"""
        with self._lock:
            if name in self.chats:
                return False
            
            # Create chat directory
            chats_dir = os.path.join(self.root_path, "chats")
            os.makedirs(chats_dir, exist_ok=True)
            
            chat_dir = os.path.join(chats_dir, name)
            os.makedirs(chat_dir, exist_ok=True)
            
            # Create chat history file
            chat_history_path = os.path.join(chat_dir, CHAT_HISTORY_FILENAME)
            
            chat_data = {
                "name": name,
                "status": status.name,
                "description": description,
                "creation_time": time.time(),
                "last_modified": time.time(),
                "project": self.name,
                "messages": [],
                "metadata": {},
                "tags": []
            }
            
            with open(chat_history_path, 'w') as f:
                json.dump(chat_data, f, indent=2)
            
            # Add to chats dictionary
            self.chats[name] = {
                "path": chat_dir,
                "status": status.name,
                "description": description,
                "creation_time": time.time(),
                "last_modified": time.time(),
                "message_count": 0
            }
            
            # Update project config
            self.last_modified = time.time()
            self._update_project_config()
            
            # Create Claude file in chat directory
            claude_path = os.path.join(chat_dir, DEFAULT_CLAUDE_FILE)
            with open(claude_path, 'w') as f:
                f.write(f"# Chat: {name}\n")
                f.write(f"# Project: {self.name}\n")
                f.write(f"# Created: {datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S')}\n\n")
                f.write(f"{description}\n\n")
                f.write("# Chat Instructions:\n")
                f.write("- This chat is part of the project organization system\n")
                f.write("- Memory integration is enabled across projects\n")
                f.write("- Symbol evolution and tool integration are supported\n")
            
            return True
    
    def add_chat_message(self, 
                        chat_name: str, 
                        role: str, 
                        content: str,
                        metadata: Optional[Dict[str, Any]] = None) -> bool:
        """Add a message to a chat"""
        with self._lock:
            if chat_name not in self.chats:
                return False
            
            chat_dir = self.chats[chat_name]["path"]
            chat_history_path = os.path.join(chat_dir, CHAT_HISTORY_FILENAME)
            
            if not os.path.exists(chat_history_path):
                return False
            
            # Load current history
            with open(chat_history_path, 'r') as f:
                chat_data = json.load(f)
            
            # Add message
            message = {
                "role": role,
                "content": content,
                "timestamp": time.time(),
                "metadata": metadata or {}
            }
            
            chat_data["messages"].append(message)
            chat_data["last_modified"] = time.time()
            
            # Update chat history file
            with open(chat_history_path, 'w') as f:
                json.dump(chat_data, f, indent=2)
            
            # Update chat in project
            self.chats[chat_name]["last_modified"] = time.time()
            self.chats[chat_name]["message_count"] = len(chat_data["messages"])
            
            # Update Claude file
            claude_path = os.path.join(chat_dir, DEFAULT_CLAUDE_FILE)
            if os.path.exists(claude_path):
                with open(claude_path, 'a') as f:
                    f.write(f"\n\n## {role.capitalize()} ({datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S')})\n\n")
                    f.write(content)
            
            # Extract hashtags and update symbol evolution if available
            if self.symbol_evolution:
                hashtags = re.findall(r'#\w+', content)
                
                if hashtags:
                    # Get active pool
                    pool_id = self.symbol_evolution.active_pool_id
                    if pool_id:
                        # Add hashtags to the pool
                        for tag in hashtags:
                            self.symbol_evolution.memory_pools[pool_id].tags.add(tag)
                        
                        # Add message as item
                        item = {
                            "type": "chat_message",
                            "chat": chat_name,
                            "role": role,
                            "content": content,
                            "tags": hashtags,
                            "timestamp": time.time(),
                            "project": self.name
                        }
                        
                        self.symbol_evolution.add_item(item, pool_id)
            
            # Update project config
            self.last_modified = time.time()
            self._update_project_config()
            
            return True
    
    def create_symbol(self, 
                     name: str, 
                     symbol_type: str, 
                     data: Any,
                     description: str = "") -> bool:
        """Create a symbol for the project"""
        with self._lock:
            if name in self.symbols:
                return False
            
            # Create symbols directory
            symbols_dir = os.path.join(self.root_path, "symbols")
            os.makedirs(symbols_dir, exist_ok=True)
            
            # Create symbol file
            symbol_path = os.path.join(symbols_dir, f"{name}.json")
            
            symbol_data = {
                "name": name,
                "type": symbol_type,
                "description": description,
                "creation_time": time.time(),
                "last_modified": time.time(),
                "data": data
            }
            
            with open(symbol_path, 'w') as f:
                json.dump(symbol_data, f, indent=2)
            
            # Add to symbols dictionary
            self.symbols[name] = {
                "path": symbol_path,
                "type": symbol_type,
                "description": description,
                "creation_time": time.time(),
                "last_modified": time.time()
            }
            
            # Create in symbol evolution if available
            if SYMBOL_REASON_AVAILABLE and self.symbol_evolution:
                try:
                    Symbol.create(name, symbol_type, data)
                except Exception as e:
                    print(f"Error creating symbol in evolution system: {e}")
            
            # Update project config
            self.last_modified = time.time()
            self._update_project_config()
            
            return True
    
    def connect_tool_to_chat(self, tool_name: str, chat_name: str) -> bool:
        """Connect a tool to a chat"""
        with self._lock:
            if tool_name not in self.tools or chat_name not in self.chats:
                return False
            
            # Update tool config
            self.tools[tool_name]["connected_chats"] = self.tools[tool_name].get("connected_chats", [])
            
            if chat_name not in self.tools[tool_name]["connected_chats"]:
                self.tools[tool_name]["connected_chats"].append(chat_name)
            
            # Save tool config
            tools_dir = os.path.join(self.root_path, "tools")
            tool_config_path = os.path.join(tools_dir, f"{tool_name}_{TOOL_CONFIG_FILENAME}")
            
            with open(tool_config_path, 'w') as f:
                json.dump(self.tools[tool_name], f, indent=2)
            
            # Update project config
            self.last_modified = time.time()
            self._update_project_config()
            
            return True
    
    def _update_project_config(self) -> None:
        """Update the project configuration file"""
        config = {
            "name": self.name,
            "type": self.project_type.name,
            "description": self.description,
            "creation_time": self.creation_time,
            "last_modified": self.last_modified,
            "folders": {name: folder["description"] for name, folder in self.folders.items()},
            "tools": {name: tool["description"] for name, tool in self.tools.items()},
            "chats": {name: chat["description"] for name, chat in self.chats.items()},
            "symbols": {name: symbol["description"] for name, symbol in self.symbols.items()},
            "metadata": self.metadata,
            "tags": list(self.tags)
        }
        
        config_path = os.path.join(self.root_path, PROJECT_CONFIG_FILENAME)
        
        with open(config_path, 'w') as f:
            json.dump(config, f, indent=2)
    
    def get_status(self) -> Dict[str, Any]:
        """Get project status summary"""
        with self._lock:
            return {
                "name": self.name,
                "type": self.project_type.name,
                "description": self.description,
                "creation_time": self.creation_time,
                "last_modified": self.last_modified,
                "folder_count": len(self.folders),
                "tool_count": len(self.tools),
                "chat_count": len(self.chats),
                "symbol_count": len(self.symbols),
                "tags": list(self.tags),
                "root_path": self.root_path
            }
    
    def save_to_memory(self) -> bool:
        """Save project state to memory system"""
        if not MEMORY_FOLD_AVAILABLE or not self.memory_fold_manager:
            return False
        
        try:
            # Prepare project data
            project_data = {
                "name": self.name,
                "type": self.project_type.name,
                "description": self.description,
                "creation_time": self.creation_time,
                "last_modified": self.last_modified,
                "folders": list(self.folders.keys()),
                "tools": list(self.tools.keys()),
                "chats": list(self.chats.keys()),
                "symbols": list(self.symbols.keys()),
                "metadata": self.metadata,
                "tags": list(self.tags)
            }
            
            # Add hashtags
            tags = [f"#project_{self.name}", f"#{self.project_type.name.lower()}_project"]
            tags.extend([f"#{tag}" for tag in self.tags if not tag.startswith("#")])
            
            # Transfer to memory system
            result = self.memory_fold_manager.fold_data_across_drives(project_data, tags)
            
            return result["status"] == "success"
        except Exception as e:
            print(f"Error saving project to memory: {e}")
            return False
    
    def load_from_memory(self) -> bool:
        """Load project state from memory system"""
        if not MEMORY_FOLD_AVAILABLE or not self.memory_fold_manager:
            return False
        
        try:
            # Extract from Claude file
            extraction = self.memory_fold_manager.extract_hashtags_from_claude()
            
            if extraction["status"] != "success":
                return False
            
            # Find project-related tags
            project_tags = [tag for tag in extraction.get("other_tags", []) 
                           if tag.startswith(f"#project_{self.name}")]
            
            if not project_tags:
                return False
            
            # Successfully loaded
            return True
        except Exception as e:
            print(f"Error loading project from memory: {e}")
            return False

class ProjectManager:
    """Manages multiple projects and their organization"""
    
    def __init__(self, 
                projects_root: str = DEFAULT_PROJECTS_ROOT,
                chat_root: str = DEFAULT_CHAT_ROOT,
                tools_root: str = DEFAULT_TOOLS_ROOT):
        """Initialize the project manager"""
        self.projects_root = projects_root
        self.chat_root = chat_root
        self.tools_root = tools_root
        self.projects: Dict[str, Project] = {}
        self.global_tools: Dict[str, Dict[str, Any]] = {}
        self.global_chats: Dict[str, Dict[str, Any]] = {}
        self.active_project: Optional[str] = None
        self._lock = Lock()
        
        # Ensure root directories exist
        os.makedirs(self.projects_root, exist_ok=True)
        os.makedirs(self.chat_root, exist_ok=True)
        os.makedirs(self.tools_root, exist_ok=True)
        
        # Load existing projects
        self._load_existing_projects()
        self._load_global_tools()
        self._load_global_chats()
    
    def _load_existing_projects(self) -> None:
        """Load existing projects from the projects root directory"""
        try:
            # List all subdirectories
            for item in os.listdir(self.projects_root):
                project_dir = os.path.join(self.projects_root, item)
                
                if os.path.isdir(project_dir):
                    # Check for project config file
                    config_path = os.path.join(project_dir, PROJECT_CONFIG_FILENAME)
                    
                    if os.path.exists(config_path):
                        # Load project config
                        try:
                            with open(config_path, 'r') as f:
                                config = json.load(f)
                            
                            # Create project object
                            project_type = ProjectType[config.get("type", "STANDARD")]
                            
                            project = Project(
                                name=config.get("name", item),
                                root_path=project_dir,
                                project_type=project_type,
                                description=config.get("description", "")
                            )
                            
                            # Load folders
                            for folder_name, folder_desc in config.get("folders", {}).items():
                                folder_path = os.path.join(project_dir, folder_name)
                                
                                if os.path.exists(folder_path):
                                    project.folders[folder_name] = {
                                        "path": folder_path,
                                        "description": folder_desc,
                                        "creation_time": os.path.getctime(folder_path),
                                        "last_modified": os.path.getmtime(folder_path),
                                        "files": []
                                    }
                            
                            # Load tools
                            tools_dir = os.path.join(project_dir, "tools")
                            if os.path.exists(tools_dir):
                                for tool_file in os.listdir(tools_dir):
                                    if tool_file.endswith(TOOL_CONFIG_FILENAME):
                                        tool_path = os.path.join(tools_dir, tool_file)
                                        
                                        try:
                                            with open(tool_path, 'r') as f:
                                                tool_config = json.load(f)
                                            
                                            tool_name = tool_config.get("name", tool_file.replace(f"_{TOOL_CONFIG_FILENAME}", ""))
                                            project.tools[tool_name] = tool_config
                                        except Exception as e:
                                            print(f"Error loading tool {tool_file}: {e}")
                            
                            # Load chats
                            chats_dir = os.path.join(project_dir, "chats")
                            if os.path.exists(chats_dir):
                                for chat_name in os.listdir(chats_dir):
                                    chat_dir = os.path.join(chats_dir, chat_name)
                                    
                                    if os.path.isdir(chat_dir):
                                        chat_history_path = os.path.join(chat_dir, CHAT_HISTORY_FILENAME)
                                        
                                        if os.path.exists(chat_history_path):
                                            try:
                                                with open(chat_history_path, 'r') as f:
                                                    chat_data = json.load(f)
                                                
                                                project.chats[chat_name] = {
                                                    "path": chat_dir,
                                                    "status": chat_data.get("status", "ACTIVE"),
                                                    "description": chat_data.get("description", ""),
                                                    "creation_time": chat_data.get("creation_time", os.path.getctime(chat_dir)),
                                                    "last_modified": chat_data.get("last_modified", os.path.getmtime(chat_dir)),
                                                    "message_count": len(chat_data.get("messages", []))
                                                }
                                            except Exception as e:
                                                print(f"Error loading chat {chat_name}: {e}")
                            
                            # Load symbols
                            symbols_dir = os.path.join(project_dir, "symbols")
                            if os.path.exists(symbols_dir):
                                for symbol_file in os.listdir(symbols_dir):
                                    if symbol_file.endswith(".json"):
                                        symbol_path = os.path.join(symbols_dir, symbol_file)
                                        
                                        try:
                                            with open(symbol_path, 'r') as f:
                                                symbol_data = json.load(f)
                                            
                                            symbol_name = symbol_data.get("name", symbol_file.replace(".json", ""))
                                            project.symbols[symbol_name] = {
                                                "path": symbol_path,
                                                "type": symbol_data.get("type", "unknown"),
                                                "description": symbol_data.get("description", ""),
                                                "creation_time": symbol_data.get("creation_time", os.path.getctime(symbol_path)),
                                                "last_modified": symbol_data.get("last_modified", os.path.getmtime(symbol_path))
                                            }
                                        except Exception as e:
                                            print(f"Error loading symbol {symbol_file}: {e}")
                            
                            # Add to projects dictionary
                            self.projects[project.name] = project
                            
                            # Set as active if no active project
                            if self.active_project is None:
                                self.active_project = project.name
                        
                        except Exception as e:
                            print(f"Error loading project {item}: {e}")
        except Exception as e:
            print(f"Error loading projects: {e}")
    
    def _load_global_tools(self) -> None:
        """Load global tools from the tools root directory"""
        try:
            # Create tools index file if it doesn't exist
            tools_index_path = os.path.join(self.tools_root, "tools_index.json")
            
            if not os.path.exists(tools_index_path):
                with open(tools_index_path, 'w') as f:
                    json.dump({"tools": {}}, f, indent=2)
            
            # Load tools index
            with open(tools_index_path, 'r') as f:
                tools_index = json.load(f)
            
            # Load tools
            for tool_name, tool_data in tools_index.get("tools", {}).items():
                self.global_tools[tool_name] = tool_data
        except Exception as e:
            print(f"Error loading global tools: {e}")
    
    def _load_global_chats(self) -> None:
        """Load global chats from the chats root directory"""
        try:
            # Load chats from chat root
            for chat_name in os.listdir(self.chat_root):
                chat_dir = os.path.join(self.chat_root, chat_name)
                
                if os.path.isdir(chat_dir):
                    chat_history_path = os.path.join(chat_dir, CHAT_HISTORY_FILENAME)
                    
                    if os.path.exists(chat_history_path):
                        try:
                            with open(chat_history_path, 'r') as f:
                                chat_data = json.load(f)
                            
                            self.global_chats[chat_name] = {
                                "path": chat_dir,
                                "status": chat_data.get("status", "ACTIVE"),
                                "description": chat_data.get("description", ""),
                                "creation_time": chat_data.get("creation_time", os.path.getctime(chat_dir)),
                                "last_modified": chat_data.get("last_modified", os.path.getmtime(chat_dir)),
                                "message_count": len(chat_data.get("messages", []))
                            }
                        except Exception as e:
                            print(f"Error loading chat {chat_name}: {e}")
        except Exception as e:
            print(f"Error loading global chats: {e}")
    
    def create_project(self, 
                      name: str, 
                      project_type: ProjectType = ProjectType.STANDARD,
                      description: str = "") -> Optional[str]:
        """Create a new project"""
        with self._lock:
            # Validate project name
            if not name or len(name) > MAX_PROJECT_NAME_LENGTH or not re.match(VALID_PROJECT_NAME_PATTERN, name):
                return None
            
            # Check if project already exists
            if name in self.projects:
                return None
            
            # Create project
            try:
                project = Project(
                    name=name,
                    root_path=os.path.join(self.projects_root, name),
                    project_type=project_type,
                    description=description
                )
                
                # Add to projects dictionary
                self.projects[name] = project
                
                # Set as active if no active project
                if self.active_project is None:
                    self.active_project = name
                
                return name
            except Exception as e:
                print(f"Error creating project {name}: {e}")
                return None
    
    def delete_project(self, name: str, delete_files: bool = False) -> bool:
        """Delete a project"""
        with self._lock:
            if name not in self.projects:
                return False
            
            project = self.projects[name]
            
            # Delete files if requested
            if delete_files:
                try:
                    shutil.rmtree(project.root_path)
                except Exception as e:
                    print(f"Error deleting project files: {e}")
                    return False
            
            # Remove from projects dictionary
            del self.projects[name]
            
            # Update active project if needed
            if self.active_project == name:
                self.active_project = next(iter(self.projects.keys())) if self.projects else None
            
            return True
    
    def set_active_project(self, name: str) -> bool:
        """Set the active project"""
        with self._lock:
            if name not in self.projects:
                return False
            
            self.active_project = name
            return True
    
    def create_global_chat(self, 
                          name: str, 
                          status: ChatStatus = ChatStatus.ACTIVE,
                          description: str = "") -> bool:
        """Create a new global chat"""
        with self._lock:
            if name in self.global_chats:
                return False
            
            # Create chat directory
            chat_dir = os.path.join(self.chat_root, name)
            os.makedirs(chat_dir, exist_ok=True)
            
            # Create chat history file
            chat_history_path = os.path.join(chat_dir, CHAT_HISTORY_FILENAME)
            
            chat_data = {
                "name": name,
                "status": status.name,
                "description": description,
                "creation_time": time.time(),
                "last_modified": time.time(),
                "project": None,  # No associated project
                "messages": [],
                "metadata": {},
                "tags": []
            }
            
            with open(chat_history_path, 'w') as f:
                json.dump(chat_data, f, indent=2)
            
            # Add to global chats dictionary
            self.global_chats[name] = {
                "path": chat_dir,
                "status": status.name,
                "description": description,
                "creation_time": time.time(),
                "last_modified": time.time(),
                "message_count": 0
            }
            
            # Create Claude file in chat directory
            claude_path = os.path.join(chat_dir, DEFAULT_CLAUDE_FILE)
            with open(claude_path, 'w') as f:
                f.write(f"# Global Chat: {name}\n")
                f.write(f"# Created: {datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S')}\n\n")
                f.write(f"{description}\n\n")
                f.write("# Chat Instructions:\n")
                f.write("- This is a global chat in the project organization system\n")
                f.write("- Memory integration is enabled across projects\n")
                f.write("- Symbol evolution and tool integration are supported\n")
            
            return True
    
    def add_global_chat_message(self, 
                               chat_name: str, 
                               role: str, 
                               content: str,
                               metadata: Optional[Dict[str, Any]] = None) -> bool:
        """Add a message to a global chat"""
        with self._lock:
            if chat_name not in self.global_chats:
                return False
            
            chat_dir = self.global_chats[chat_name]["path"]
            chat_history_path = os.path.join(chat_dir, CHAT_HISTORY_FILENAME)
            
            if not os.path.exists(chat_history_path):
                return False
            
            # Load current history
            with open(chat_history_path, 'r') as f:
                chat_data = json.load(f)
            
            # Add message
            message = {
                "role": role,
                "content": content,
                "timestamp": time.time(),
                "metadata": metadata or {}
            }
            
            chat_data["messages"].append(message)
            chat_data["last_modified"] = time.time()
            
            # Update chat history file
            with open(chat_history_path, 'w') as f:
                json.dump(chat_data, f, indent=2)
            
            # Update chat in global chats
            self.global_chats[chat_name]["last_modified"] = time.time()
            self.global_chats[chat_name]["message_count"] = len(chat_data["messages"])
            
            # Update Claude file
            claude_path = os.path.join(chat_dir, DEFAULT_CLAUDE_FILE)
            if os.path.exists(claude_path):
                with open(claude_path, 'a') as f:
                    f.write(f"\n\n## {role.capitalize()} ({datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S')})\n\n")
                    f.write(content)
            
            return True
    
    def add_global_tool(self, 
                       name: str, 
                       tool_path: str, 
                       integration_type: ToolIntegrationType = ToolIntegrationType.LINKED,
                       description: str = "") -> bool:
        """Add a global tool"""
        with self._lock:
            if name in self.global_tools:
                return False
            
            # Create tool config
            tool_config = {
                "name": name,
                "path": tool_path,
                "integration_type": integration_type.name,
                "description": description,
                "creation_time": time.time(),
                "last_modified": time.time(),
                "active": True,
                "metadata": {}
            }
            
            # Create tool directory if needed
            tool_dir = os.path.join(self.tools_root, name)
            os.makedirs(tool_dir, exist_ok=True)
            
            # Create tool config file
            tool_config_path = os.path.join(tool_dir, TOOL_CONFIG_FILENAME)
            
            with open(tool_config_path, 'w') as f:
                json.dump(tool_config, f, indent=2)
            
            # Add to global tools dictionary
            self.global_tools[name] = tool_config
            
            # Update tools index
            tools_index_path = os.path.join(self.tools_root, "tools_index.json")
            
            try:
                with open(tools_index_path, 'r') as f:
                    tools_index = json.load(f)
            except:
                tools_index = {"tools": {}}
            
            tools_index["tools"][name] = {
                "path": tool_dir,
                "config_path": tool_config_path,
                "description": description
            }
            
            with open(tools_index_path, 'w') as f:
                json.dump(tools_index, f, indent=2)
            
            return True
    
    def link_tool_to_project(self, tool_name: str, project_name: str) -> bool:
        """Link a global tool to a project"""
        with self._lock:
            if tool_name not in self.global_tools or project_name not in self.projects:
                return False
            
            project = self.projects[project_name]
            
            # Add tool to project
            return project.add_tool(
                name=tool_name,
                tool_path=self.global_tools[tool_name]["path"],
                integration_type=ToolIntegrationType[self.global_tools[tool_name].get("integration_type", "LINKED")],
                description=self.global_tools[tool_name].get("description", "")
            )
    
    def link_chat_to_project(self, chat_name: str, project_name: str) -> bool:
        """Link a global chat to a project"""
        with self._lock:
            if chat_name not in self.global_chats or project_name not in self.projects:
                return False
            
            project = self.projects[project_name]
            
            # Create symbolic link to chat in project chats directory
            chat_dir = self.global_chats[chat_name]["path"]
            project_chats_dir = os.path.join(project.root_path, "chats")
            os.makedirs(project_chats_dir, exist_ok=True)
            
            link_path = os.path.join(project_chats_dir, chat_name)
            
            try:
                # Create symbolic link if it doesn't exist
                if not os.path.exists(link_path):
                    # On Windows, use directory junction instead of symlink
                    if os.name == 'nt':
                        subprocess.run(["mklink", "/J", link_path, chat_dir], shell=True)
                    else:
                        os.symlink(chat_dir, link_path, target_is_directory=True)
                
                # Add to project chats
                project.chats[chat_name] = {
                    "path": link_path,
                    "status": self.global_chats[chat_name]["status"],
                    "description": self.global_chats[chat_name]["description"],
                    "creation_time": self.global_chats[chat_name]["creation_time"],
                    "last_modified": self.global_chats[chat_name]["last_modified"],
                    "message_count": self.global_chats[chat_name]["message_count"],
                    "linked": True
                }
                
                # Update project config
                project.last_modified = time.time()
                project._update_project_config()
                
                return True
            except Exception as e:
                print(f"Error linking chat to project: {e}")
                return False
    
    def process_hashtag_command(self, command: str) -> Dict[str, Any]:
        """Process hashtag-based command for project management"""
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
            if parts[0] == "#project":
                # #project create [name] [type] [description]
                if len(parts) < 3 or parts[1] != "create":
                    results["status"] = "error"
                    results["message"] = "Invalid project command format"
                    return results
                
                name = parts[2]
                
                # Determine project type
                project_type = ProjectType.STANDARD
                if len(parts) > 3:
                    try:
                        project_type = ProjectType[parts[3].upper()]
                    except KeyError:
                        pass
                
                # Get description
                description = " ".join(parts[4:]) if len(parts) > 4 else ""
                
                # Create project
                project_name = self.create_project(name, project_type, description)
                
                if project_name:
                    results["project_name"] = project_name
                    results["actions"].append(f"Created project {project_name}")
                else:
                    results["status"] = "error"
                    results["message"] = f"Failed to create project {name}"
            
            elif parts[0] == "#chat":
                # #chat create [name] [status] [description]
                if len(parts) < 3 or parts[1] != "create":
                    results["status"] = "error"
                    results["message"] = "Invalid chat command format"
                    return results
                
                name = parts[2]
                
                # Determine chat status
                status = ChatStatus.ACTIVE
                if len(parts) > 3:
                    try:
                        status = ChatStatus[parts[3].upper()]
                    except KeyError:
                        pass
                
                # Get description
                description = " ".join(parts[4:]) if len(parts) > 4 else ""
                
                # Determine if global or project chat
                if self.active_project:
                    # Create project chat
                    project = self.projects[self.active_project]
                    success = project.create_chat(name, status, description)
                    
                    if success:
                        results["chat_name"] = name
                        results["project"] = self.active_project
                        results["actions"].append(f"Created chat {name} in project {self.active_project}")
                    else:
                        results["status"] = "error"
                        results["message"] = f"Failed to create chat {name} in project {self.active_project}"
                else:
                    # Create global chat
                    success = self.create_global_chat(name, status, description)
                    
                    if success:
                        results["chat_name"] = name
                        results["global"] = True
                        results["actions"].append(f"Created global chat {name}")
                    else:
                        results["status"] = "error"
                        results["message"] = f"Failed to create global chat {name}"
            
            elif parts[0] == "#tool":
                # #tool add [name] [path] [type] [description]
                if len(parts) < 4 or parts[1] != "add":
                    results["status"] = "error"
                    results["message"] = "Invalid tool command format"
                    return results
                
                name = parts[2]
                path = parts[3]
                
                # Determine integration type
                integration_type = ToolIntegrationType.LINKED
                if len(parts) > 4:
                    try:
                        integration_type = ToolIntegrationType[parts[4].upper()]
                    except KeyError:
                        pass
                
                # Get description
                description = " ".join(parts[5:]) if len(parts) > 5 else ""
                
                # Determine if project or global tool
                if self.active_project:
                    # Add to project
                    project = self.projects[self.active_project]
                    success = project.add_tool(name, path, integration_type, description)
                    
                    if success:
                        results["tool_name"] = name
                        results["project"] = self.active_project
                        results["actions"].append(f"Added tool {name} to project {self.active_project}")
                    else:
                        results["status"] = "error"
                        results["message"] = f"Failed to add tool {name} to project {self.active_project}"
                else:
                    # Add global tool
                    success = self.add_global_tool(name, path, integration_type, description)
                    
                    if success:
                        results["tool_name"] = name
                        results["global"] = True
                        results["actions"].append(f"Added global tool {name}")
                    else:
                        results["status"] = "error"
                        results["message"] = f"Failed to add global tool {name}"
            
            elif parts[0] == "#link":
                # #link tool [tool_name] [project_name]
                # #link chat [chat_name] [project_name]
                if len(parts) < 4:
                    results["status"] = "error"
                    results["message"] = "Invalid link command format"
                    return results
                
                item_type = parts[1]
                item_name = parts[2]
                project_name = parts[3]
                
                if item_type == "tool":
                    # Link tool to project
                    success = self.link_tool_to_project(item_name, project_name)
                    
                    if success:
                        results["tool_name"] = item_name
                        results["project_name"] = project_name
                        results["actions"].append(f"Linked tool {item_name} to project {project_name}")
                    else:
                        results["status"] = "error"
                        results["message"] = f"Failed to link tool {item_name} to project {project_name}"
                
                elif item_type == "chat":
                    # Link chat to project
                    success = self.link_chat_to_project(item_name, project_name)
                    
                    if success:
                        results["chat_name"] = item_name
                        results["project_name"] = project_name
                        results["actions"].append(f"Linked chat {item_name} to project {project_name}")
                    else:
                        results["status"] = "error"
                        results["message"] = f"Failed to link chat {item_name} to project {project_name}"
                
                else:
                    results["status"] = "error"
                    results["message"] = f"Unknown item type: {item_type}"
            
            elif parts[0] == "#active":
                # #active [project_name]
                if len(parts) < 2:
                    # Report active project
                    results["active_project"] = self.active_project
                    results["actions"].append(f"Active project is {self.active_project}" if self.active_project else "No active project")
                else:
                    # Set active project
                    project_name = parts[1]
                    success = self.set_active_project(project_name)
                    
                    if success:
                        results["active_project"] = project_name
                        results["actions"].append(f"Set active project to {project_name}")
                    else:
                        results["status"] = "error"
                        results["message"] = f"Project {project_name} not found"
            
            elif parts[0] == "#symbol":
                # Forward to active project's symbol evolution
                if self.active_project and self.projects[self.active_project].symbol_evolution:
                    symbol_result = self.projects[self.active_project].symbol_evolution.process_hashtag_command(command)
                    
                    results["symbol_result"] = symbol_result
                    results["actions"].append("Processed command in symbol evolution system")
                else:
                    results["status"] = "error"
                    results["message"] = "No active project with symbol evolution"
            
            elif parts[0] == "#memory":
                # Forward to active project's memory fold manager
                if self.active_project and self.projects[self.active_project].memory_fold_manager:
                    memory_result = self.projects[self.active_project].memory_fold_manager.process_hashtag_command(command)
                    
                    results["memory_result"] = memory_result
                    results["actions"].append("Processed command in memory fold system")
                else:
                    results["status"] = "error"
                    results["message"] = "No active project with memory fold manager"
            
            elif parts[0] == "#status":
                # #status [project_name]
                project_name = parts[1] if len(parts) > 1 else self.active_project
                
                if project_name and project_name in self.projects:
                    # Get project status
                    status = self.projects[project_name].get_status()
                    
                    results["project_status"] = status
                    results["actions"].append(f"Got status for project {project_name}")
                else:
                    # Get overall status
                    results["projects"] = list(self.projects.keys())
                    results["active_project"] = self.active_project
                    results["global_tools"] = list(self.global_tools.keys())
                    results["global_chats"] = list(self.global_chats.keys())
                    results["actions"].append("Got overall status")
            
            elif parts[0] == "#save":
                # #save [project_name]
                project_name = parts[1] if len(parts) > 1 else self.active_project
                
                if project_name and project_name in self.projects:
                    # Save project to memory
                    success = self.projects[project_name].save_to_memory()
                    
                    if success:
                        results["project_name"] = project_name
                        results["actions"].append(f"Saved project {project_name} to memory")
                    else:
                        results["status"] = "error"
                        results["message"] = f"Failed to save project {project_name} to memory"
                else:
                    results["status"] = "error"
                    results["message"] = "No project specified or active"
            
            elif parts[0] == "#load":
                # #load [project_name]
                project_name = parts[1] if len(parts) > 1 else self.active_project
                
                if project_name and project_name in self.projects:
                    # Load project from memory
                    success = self.projects[project_name].load_from_memory()
                    
                    if success:
                        results["project_name"] = project_name
                        results["actions"].append(f"Loaded project {project_name} from memory")
                    else:
                        results["status"] = "error"
                        results["message"] = f"Failed to load project {project_name} from memory"
                else:
                    results["status"] = "error"
                    results["message"] = "No project specified or active"
            
            else:
                # Unknown command
                results["status"] = "error"
                results["message"] = f"Unknown command: {parts[0]}"
            
            return results

def main():
    """Main function for CLI usage"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Project Organization System")
    parser.add_argument("--init", action="store_true", help="Initialize the system")
    parser.add_argument("--create-project", nargs='+', metavar=('NAME', 'TYPE'), help="Create a new project")
    parser.add_argument("--create-chat", nargs='+', metavar=('NAME', 'STATUS'), help="Create a new chat")
    parser.add_argument("--add-tool", nargs='+', metavar=('NAME', 'PATH', 'TYPE'), help="Add a tool")
    parser.add_argument("--link", nargs=3, metavar=('TYPE', 'NAME', 'PROJECT'), help="Link an item to a project")
    parser.add_argument("--active", metavar='PROJECT', help="Set active project")
    parser.add_argument("--status", nargs='?', const='all', metavar='PROJECT', help="Show status")
    parser.add_argument("--command", metavar='CMD', help="Process a hashtag command")
    
    args = parser.parse_args()
    
    # Create project manager
    manager = ProjectManager()
    
    if args.init:
        print("Initializing project organization system...")
        # Nothing to do here, as the manager initializes itself
    
    if args.create_project:
        name = args.create_project[0]
        
        # Determine project type
        project_type = ProjectType.STANDARD
        if len(args.create_project) > 1:
            try:
                project_type = ProjectType[args.create_project[1].upper()]
            except KeyError:
                print(f"Invalid project type: {args.create_project[1]}, using STANDARD")
        
        # Get description
        description = " ".join(args.create_project[2:]) if len(args.create_project) > 2 else ""
        
        # Create project
        project_name = manager.create_project(name, project_type, description)
        
        if project_name:
            print(f"Created project: {project_name}")
        else:
            print(f"Failed to create project: {name}")
    
    if args.create_chat:
        name = args.create_chat[0]
        
        # Determine chat status
        status = ChatStatus.ACTIVE
        if len(args.create_chat) > 1:
            try:
                status = ChatStatus[args.create_chat[1].upper()]
            except KeyError:
                print(f"Invalid chat status: {args.create_chat[1]}, using ACTIVE")
        
        # Get description
        description = " ".join(args.create_chat[2:]) if len(args.create_chat) > 2 else ""
        
        # Determine if global or project chat
        if manager.active_project:
            # Create project chat
            project = manager.projects[manager.active_project]
            success = project.create_chat(name, status, description)
            
            if success:
                print(f"Created chat {name} in project {manager.active_project}")
            else:
                print(f"Failed to create chat {name} in project {manager.active_project}")
        else:
            # Create global chat
            success = manager.create_global_chat(name, status, description)
            
            if success:
                print(f"Created global chat: {name}")
            else:
                print(f"Failed to create global chat: {name}")
    
    if args.add_tool:
        name = args.add_tool[0]
        path = args.add_tool[1] if len(args.add_tool) > 1 else ""
        
        # Determine integration type
        integration_type = ToolIntegrationType.LINKED
        if len(args.add_tool) > 2:
            try:
                integration_type = ToolIntegrationType[args.add_tool[2].upper()]
            except KeyError:
                print(f"Invalid integration type: {args.add_tool[2]}, using LINKED")
        
        # Get description
        description = " ".join(args.add_tool[3:]) if len(args.add_tool) > 3 else ""
        
        # Determine if project or global tool
        if manager.active_project:
            # Add to project
            project = manager.projects[manager.active_project]
            success = project.add_tool(name, path, integration_type, description)
            
            if success:
                print(f"Added tool {name} to project {manager.active_project}")
            else:
                print(f"Failed to add tool {name} to project {manager.active_project}")
        else:
            # Add global tool
            success = manager.add_global_tool(name, path, integration_type, description)
            
            if success:
                print(f"Added global tool: {name}")
            else:
                print(f"Failed to add global tool: {name}")
    
    if args.link:
        item_type = args.link[0]
        item_name = args.link[1]
        project_name = args.link[2]
        
        if item_type == "tool":
            # Link tool to project
            success = manager.link_tool_to_project(item_name, project_name)
            
            if success:
                print(f"Linked tool {item_name} to project {project_name}")
            else:
                print(f"Failed to link tool {item_name} to project {project_name}")
        
        elif item_type == "chat":
            # Link chat to project
            success = manager.link_chat_to_project(item_name, project_name)
            
            if success:
                print(f"Linked chat {item_name} to project {project_name}")
            else:
                print(f"Failed to link chat {item_name} to project {project_name}")
        
        else:
            print(f"Unknown item type: {item_type}")
    
    if args.active:
        # Set active project
        success = manager.set_active_project(args.active)
        
        if success:
            print(f"Set active project to {args.active}")
        else:
            print(f"Project {args.active} not found")
    
    if args.status:
        if args.status != 'all' and args.status in manager.projects:
            # Get project status
            status = manager.projects[args.status].get_status()
            
            print(f"Status for project: {args.status}")
            for key, value in status.items():
                print(f"  {key}: {value}")
        else:
            # Get overall status
            print("Project Organization System Status:")
            print(f"  Active project: {manager.active_project}")
            print(f"  Projects: {', '.join(manager.projects.keys())}")
            print(f"  Global tools: {', '.join(manager.global_tools.keys())}")
            print(f"  Global chats: {', '.join(manager.global_chats.keys())}")
    
    if args.command:
        # Process hashtag command
        result = manager.process_hashtag_command(args.command)
        
        print(f"Command result: {result['status']}")
        print(f"Actions: {', '.join(result.get('actions', []))}")
        
        if result['status'] == "error":
            print(f"Error: {result.get('message', 'Unknown error')}")

if __name__ == "__main__":
    main()