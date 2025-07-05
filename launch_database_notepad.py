#!/usr/bin/env python3

import subprocess
import sys
import os

def main():
    print("🗄️ LAUNCHING WORKING DATABASE NOTEPAD 3D...")
    print("📝 A real 3D database where you can swim through your data!")
    print("")
    print("🎮 CONTROLS:")
    print("   ESC - Toggle mouse capture")
    print("   WASD - Swim horizontally")
    print("   Space/Shift - Swim up/down")
    print("   Mouse - Look around")
    print("   E - Create note at current position")
    print("   R - Select nearest note")
    print("   T - Swim to random note")
    print("")
    print("🏊 You will spawn in 3D space with several notes floating around.")
    print("   Swim to them to read them, create new ones with E!")
    print("")
    
    try:
        # Change to the project directory
        project_dir = os.path.dirname(os.path.abspath(__file__))
        os.chdir(project_dir)
        
        # Launch Godot with the working database notepad scene
        subprocess.run([
            "godot", 
            "WORKING_DATABASE_NOTEPAD_3D.tscn"
        ], check=True)
        
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to launch: {e}")
        print("Make sure Godot is installed and in your PATH")
        sys.exit(1)
    except FileNotFoundError:
        print("❌ Godot not found in PATH")
        print("Please install Godot or add it to your PATH")
        sys.exit(1)

if __name__ == "__main__":
    main()