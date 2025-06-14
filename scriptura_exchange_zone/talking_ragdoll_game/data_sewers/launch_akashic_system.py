#!/usr/bin/env python3
"""
Akashic System Launcher - Complete tutorial and file sync system
Launches server, connects to game, manages tutorial steps
"""

import subprocess
import time
import os
import sys
import threading
import json
from pathlib import Path

class AkashicLauncher:
    def __init__(self):
        self.server_process = None
        self.game_process = None
        self.project_path = Path.cwd()
        self.godot_executable = "godot"  # Will be updated if found
        
    def check_dependencies(self):
        """Check if required dependencies are available"""
        print("🔍 Checking dependencies...")
        
        # Check Python websockets
        try:
            import websockets
            print("✅ websockets library available")
        except ImportError:
            print("❌ websockets library missing")
            print("   Install with: pip install websockets")
            return False
        
        # Check Godot
        godot_paths = [
            "godot",  # In PATH
            r"C:\Program Files\Godot\godot.exe",
            r"C:\Program Files (x86)\Godot\godot.exe",
            r"C:\Users\Percision 15\Downloads\Godot_v4.5-dev4_mono_win64\Godot_v4.5-dev4_mono_win64.exe",
            r"C:\Godot\godot.exe",
            "godot.exe"  # Current directory
        ]
        
        godot_found = False
        godot_path = None
        
        for path in godot_paths:
            try:
                result = subprocess.run([path, "--version"], 
                                      capture_output=True, text=True, timeout=5)
                if result.returncode == 0:
                    print(f"✅ Godot available: {result.stdout.strip()}")
                    godot_found = True
                    godot_path = path
                    self.godot_executable = path  # Store for later use
                    break
            except (subprocess.TimeoutExpired, FileNotFoundError):
                continue
        
        if not godot_found:
            print("❌ Godot not found in common locations")
            print("   Please ensure Godot is installed")
            print("   Common locations checked:")
            for path in godot_paths[1:]:  # Skip "godot" in PATH
                print(f"   - {path}")
            return False
        
        # Check project files
        if not (self.project_path / "project.godot").exists():
            print("❌ project.godot not found")
            return False
        
        print("✅ All dependencies available")
        return True
    
    def create_tutorial_files(self):
        """Create tutorial files for the system"""
        print("📚 Creating tutorial files...")
        
        # Create user directory structure
        user_dir = self.project_path / "user"
        lists_dir = user_dir / "lists"
        lists_dir.mkdir(parents=True, exist_ok=True)
        
        # Game rules file
        game_rules = lists_dir / "game_rules.txt"
        if not game_rules.exists():
            with open(game_rules, 'w') as f:
                f.write("""# Akashic Game Rules - Tutorial System
# These rules guide the tutorial process

# Tutorial progression rules
WHEN tutorial_active THEN check_player_progress
WHEN step_completed THEN advance_to_next_step
WHEN all_steps_complete THEN celebrate_success

# Object interaction rules
WHEN player_clicks_object THEN show_object_info
WHEN universal_being_spawned THEN enable_transformation
WHEN transformation_requested THEN execute_safely

# System health rules
WHEN fps_drops THEN optimize_performance
WHEN memory_high THEN cleanup_unused_objects
WHEN error_detected THEN attempt_self_repair
""")
        
        # Scene forest file
        scene_forest = lists_dir / "scene_forest.txt"
        if not scene_forest.exists():
            with open(scene_forest, 'w') as f:
                f.write("""# Forest Scene Configuration
# Objects and layout for forest tutorial

# Trees in circle pattern
pattern:forest_circle
tree 5 0 5
tree 3 0 7
tree 0 0 8
tree -3 0 7
tree -5 0 5
tree -7 0 0
tree -5 0 -5
tree 0 0 -8
tree 5 0 -5

# Interactive elements
pattern:interactive
universal_being 0 3 0 special=tutorial_guide
box 2 1 2 clickable=true tutorial_step=3
""")
        
        # Tutorial steps file
        tutorial_steps = lists_dir / "tutorial_steps.txt"
        if not tutorial_steps.exists():
            with open(tutorial_steps, 'w') as f:
                f.write("""# Tutorial Steps Configuration
# Step-by-step progression through the game

step:1
title=Welcome to Talking Ragdoll Game
description=Press Tab to open console
action=check_console_open
validation=console_visible

step:2
title=Test Console Commands
description=Type 'help' and press Enter
action=use_command
command=help
validation=help_displayed

step:3
title=Spawn Your First Object
description=Type 'tree' to create a tree
action=use_command
command=tree
validation=object_spawned

step:4
title=Click to Inspect
description=Click on the tree you just created
action=click_object
target=tree
validation=object_clicked

step:5
title=Create Universal Being
description=Type 'spawn_universal_being'
action=use_command
command=spawn_universal_being
validation=universal_being_exists

step:6
title=Transform Universal Being
description=Type 'being_transform box'
action=use_command
command=being_transform box
validation=transformation_completed

step:7
title=Check System Health
description=Type 'repair_status'
action=use_command
command=repair_status
validation=status_displayed

step:8
title=Tutorial Complete!
description=Your game is fully operational
action=celebration
validation=tutorial_finished
""")
        
        # Player progress file
        player_progress = lists_dir / "player_progress.txt"
        if not player_progress.exists():
            with open(player_progress, 'w') as f:
                f.write("""# Player Progress Tracking
# Automatically updated by the tutorial system

session_start=0
current_step=0
completed_steps=[]
total_play_time=0
objects_spawned=0
commands_used=[]
achievements=[]

# Achievements system
achievement:first_steps
name=First Steps
description=Completed tutorial step 1
unlocked=false

achievement:object_master
name=Object Master  
description=Spawned 10 objects
unlocked=false

achievement:transformation_expert
name=Transformation Expert
description=Successfully transformed Universal Being
unlocked=false

achievement:system_consciousness
name=System Consciousness
description=Used self-repair system
unlocked=false
""")
        
        print("✅ Tutorial files created")
    
    def start_akashic_server(self):
        """Start the Akashic Records server"""
        print("🌌 Starting Akashic Records server...")
        
        server_script = self.project_path / "akashic_server.py"
        if not server_script.exists():
            print("❌ akashic_server.py not found")
            return False
        
        try:
            self.server_process = subprocess.Popen([
                sys.executable, str(server_script)
            ], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            
            # Give server time to start
            time.sleep(3)
            
            # Check if server is running
            if self.server_process.poll() is None:
                print("✅ Akashic server started successfully")
                print("🌐 HTML Interface: http://localhost:8888")
                print("🔗 WebSocket: ws://localhost:8889")
                return True
            else:
                print("❌ Akashic server failed to start")
                return False
                
        except Exception as e:
            print(f"❌ Failed to start server: {e}")
            return False
    
    def start_game_with_akashic(self):
        """Start the game with Akashic Bridge enabled"""
        print("🎮 Starting game with Akashic Bridge...")
        
        try:
            self.game_process = subprocess.Popen([
                self.godot_executable,
                "--path", str(self.project_path),
                "scenes/main_game.tscn"
            ])
            
            print("✅ Game launched with Akashic connection")
            return True
            
        except Exception as e:
            print(f"❌ Failed to start game: {e}")
            return False
    
    def monitor_tutorial_progress(self):
        """Monitor tutorial progress and provide guidance"""
        print("📚 Tutorial monitor started...")
        
        progress_file = self.project_path / "user" / "lists" / "player_progress.txt"
        last_step = 0
        
        while True:
            try:
                if progress_file.exists():
                    with open(progress_file, 'r') as f:
                        content = f.read()
                    
                    # Simple progress parsing
                    if "current_step=" in content:
                        for line in content.split('\n'):
                            if line.startswith("current_step="):
                                current_step = int(line.split('=')[1])
                                if current_step > last_step:
                                    print(f"🎯 Tutorial progress: Step {current_step}")
                                    last_step = current_step
                
                time.sleep(2)  # Check every 2 seconds
                
            except (ValueError, FileNotFoundError, PermissionError):
                time.sleep(5)  # Wait longer if file issues
            except KeyboardInterrupt:
                print("📚 Tutorial monitor stopped")
                break
    
    def launch_complete_system(self):
        """Launch the complete Akashic system"""
        print("🚀 Launching Complete Akashic System...")
        print("=" * 50)
        
        # Step 1: Check dependencies
        if not self.check_dependencies():
            print("❌ Dependency check failed")
            return False
        
        # Step 2: Create tutorial files
        self.create_tutorial_files()
        
        # Step 3: Start server
        if not self.start_akashic_server():
            print("❌ Server startup failed")
            return False
        
        # Step 4: Start game
        if not self.start_game_with_akashic():
            print("❌ Game startup failed")
            self.cleanup()
            return False
        
        # Step 5: Start tutorial monitor in background
        monitor_thread = threading.Thread(target=self.monitor_tutorial_progress, daemon=True)
        monitor_thread.start()
        
        print("=" * 50)
        print("✅ AKASHIC SYSTEM FULLY OPERATIONAL!")
        print()
        print("🌐 Open browser: http://localhost:8888")
        print("🎮 Game running with tutorial system")
        print("📚 Tutorial will guide you through all features")
        print("🔧 Self-repair system monitoring everything")
        print()
        print("Press Ctrl+C to shutdown everything")
        print("=" * 50)
        
        try:
            # Keep system running
            while True:
                time.sleep(1)
                
                # Check if processes are still running
                if self.server_process and self.server_process.poll() is not None:
                    print("⚠️ Server process died")
                    break
                
                if self.game_process and self.game_process.poll() is not None:
                    print("⚠️ Game process ended")
                    break
        
        except KeyboardInterrupt:
            print("\n🛑 Shutdown requested")
        
        finally:
            self.cleanup()
        
        return True
    
    def cleanup(self):
        """Clean up processes"""
        print("🧹 Cleaning up processes...")
        
        if self.game_process:
            print("🎮 Stopping game...")
            self.game_process.terminate()
            try:
                self.game_process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                self.game_process.kill()
        
        if self.server_process:
            print("🌌 Stopping Akashic server...")
            self.server_process.terminate()
            try:
                self.server_process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                self.server_process.kill()
        
        print("✅ Cleanup complete")
    
    def show_menu(self):
        """Show interactive menu"""
        while True:
            print("\n🌌 AKASHIC RECORDS SYSTEM")
            print("=" * 30)
            print("1. 🚀 Launch Complete System")
            print("2. 🌐 Start Server Only")
            print("3. 🎮 Start Game Only")
            print("4. 📚 Create Tutorial Files")
            print("5. 🔍 Check Dependencies")
            print("6. 🛑 Exit")
            print("=" * 30)
            
            choice = input("Select option (1-6): ").strip()
            
            if choice == "1":
                self.launch_complete_system()
            elif choice == "2":
                self.start_akashic_server()
                input("Press Enter to stop server...")
                self.cleanup()
            elif choice == "3":
                self.start_game_with_akashic()
                input("Press Enter to stop game...")
                self.cleanup()
            elif choice == "4":
                self.create_tutorial_files()
            elif choice == "5":
                self.check_dependencies()
            elif choice == "6":
                print("👋 Goodbye!")
                break
            else:
                print("Invalid choice, please select 1-6")

def main():
    """Main function"""
    launcher = AkashicLauncher()
    
    if len(sys.argv) > 1:
        command = sys.argv[1]
        if command == "full":
            launcher.launch_complete_system()
        elif command == "server":
            launcher.start_akashic_server()
        elif command == "game":
            launcher.start_game_with_akashic()
        elif command == "check":
            launcher.check_dependencies()
        else:
            print("Usage: python launch_akashic_system.py [full|server|game|check]")
    else:
        launcher.show_menu()

if __name__ == "__main__":
    main()