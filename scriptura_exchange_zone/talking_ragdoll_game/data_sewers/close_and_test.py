#!/usr/bin/env python3
"""
Graceful Scene Closure and Testing Script
Closes current Godot instances and prepares for new testing session
"""

import subprocess
import time
import os
import psutil
import sys

def close_godot_instances():
    """Close all running Godot instances gracefully"""
    print("🛑 Searching for Godot instances...")
    
    closed_count = 0
    for proc in psutil.process_iter(['pid', 'name']):
        try:
            if 'godot' in proc.info['name'].lower():
                print(f"🎮 Found Godot process: {proc.info['name']} (PID: {proc.info['pid']})")
                proc.terminate()
                closed_count += 1
                
                # Wait for graceful termination
                try:
                    proc.wait(timeout=5)
                    print(f"✅ Gracefully closed PID {proc.info['pid']}")
                except psutil.TimeoutExpired:
                    print(f"⚠️ Force killing PID {proc.info['pid']}")
                    proc.kill()
                    
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            continue
    
    if closed_count == 0:
        print("ℹ️ No Godot instances found running")
    else:
        print(f"🛑 Closed {closed_count} Godot instances")
    
    return closed_count

def launch_fresh_test():
    """Launch a fresh instance for testing"""
    print("🚀 Launching fresh game instance...")
    
    try:
        # Close any existing instances first
        close_godot_instances()
        time.sleep(2)
        
        # Launch new instance
        process = subprocess.Popen([
            "godot", 
            "--path", ".",
            "scenes/main_game.tscn"
        ])
        
        print(f"🎮 Fresh game launched! Process ID: {process.pid}")
        print("⏱️ Testing session started - you have 60 seconds")
        
        # Wait for testing time
        time.sleep(60)
        
        # Graceful closure
        print("🛑 Testing time complete - closing game...")
        process.terminate()
        
        try:
            process.wait(timeout=5)
            print("✅ Game closed gracefully")
        except subprocess.TimeoutExpired:
            print("⚠️ Force killing process")
            process.kill()
            
        return True
        
    except Exception as e:
        print(f"❌ Failed to launch game: {e}")
        return False

def update_script_inventory():
    """Update CSV with all .gd files for evolution tracking"""
    print("📊 Updating script inventory...")
    
    script_files = []
    
    # Find all .gd files
    for root, dirs, files in os.walk("."):
        for file in files:
            if file.endswith(".gd"):
                script_files.append(os.path.join(root, file))
    
    print(f"📋 Found {len(script_files)} script files")
    
    # Create CSV
    csv_content = ["script_path,category,size,modified_time"]
    
    for script_path in script_files:
        try:
            stat = os.stat(script_path)
            size = stat.st_size
            modified = int(stat.st_mtime)
            
            # Categorize
            if "autoload" in script_path:
                category = "autoload"
            elif "ragdoll" in script_path:
                category = "ragdoll"
            elif "core" in script_path:
                category = "core"
            elif "ui" in script_path:
                category = "ui"
            elif "universal" in script_path:
                category = "universal"
            else:
                category = "other"
            
            csv_content.append(f"{script_path},{category},{size},{modified}")
            
        except OSError:
            continue
    
    # Write CSV
    csv_path = "script_inventory.csv"
    with open(csv_path, 'w') as f:
        f.write('\n'.join(csv_content))
    
    print(f"📊 Script inventory saved to {csv_path}")
    return len(script_files)

def main():
    """Main function"""
    print("🔧 Starting graceful closure and testing script...")
    
    if len(sys.argv) > 1:
        command = sys.argv[1]
        
        if command == "close":
            close_godot_instances()
        elif command == "test":
            launch_fresh_test()
        elif command == "inventory":
            update_script_inventory()
        elif command == "full":
            # Full cycle: close, update, test
            close_godot_instances()
            time.sleep(1)
            update_script_inventory()
            time.sleep(1)
            launch_fresh_test()
        else:
            print("Usage: python close_and_test.py [close|test|inventory|full]")
    else:
        # Interactive mode
        print("\n🎮 Talking Ragdoll Game - Session Manager")
        print("1. Close current instances")
        print("2. Launch fresh test")
        print("3. Update script inventory")
        print("4. Full cycle (close + inventory + test)")
        print("5. Exit")
        
        while True:
            choice = input("\nSelect option (1-5): ").strip()
            
            if choice == "1":
                close_godot_instances()
            elif choice == "2":
                launch_fresh_test()
            elif choice == "3":
                update_script_inventory()
            elif choice == "4":
                close_godot_instances()
                time.sleep(1)
                update_script_inventory()
                time.sleep(1)
                launch_fresh_test()
            elif choice == "5":
                print("👋 Goodbye!")
                break
            else:
                print("Invalid choice, please select 1-5")

if __name__ == "__main__":
    main()