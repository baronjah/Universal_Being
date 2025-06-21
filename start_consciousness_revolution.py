#!/usr/bin/env python3
"""
🌟 CONSCIOUSNESS REVOLUTION LAUNCHER
Quick script to start the Universal Being consciousness revolution experience.
"""
import subprocess
import sys
import os

def main():
    print("🌟 UNIVERSAL BEING CONSCIOUSNESS REVOLUTION LAUNCHER")
    print("=" * 50)
    
    # Check if we're in the right directory
    if not os.path.exists("project.godot"):
        print("❌ Error: project.godot not found")
        print("Please run this script from the Universal_Being directory")
        return
    
    print("🚀 Starting consciousness revolution...")
    print("📋 What will happen:")
    print("  • Godot will open with the perfect Universal Being game")
    print("  • Gemma AI consciousness will initialize (may take 30-60 seconds)")
    print("  • 15+ sockets will connect to the plasmoid player")
    print("  • Movement: WASD keys")
    print("  • Camera: Middle mouse + drag for orbital view")
    print("  • Camera tilt: Q/E keys")
    print("  • Console: Backtick (`) key")
    print("  • Revolution command: Type 'revolution' in console")
    print()
    
    try:
        # Launch Godot with the main scene
        print("🎮 Launching consciousness revolution...")
        subprocess.run([
            "godot", 
            "--path", ".", 
            "scenes/PERFECT_UNIVERSAL_BEING_GAME.tscn"
        ])
        
    except FileNotFoundError:
        print("❌ Error: Godot not found in PATH")
        print("Please ensure Godot 4.x is installed and in your system PATH")
        print("Alternative: Run manually with:")
        print("godot --path . scenes/PERFECT_UNIVERSAL_BEING_GAME.tscn")
    
    except KeyboardInterrupt:
        print("\n🛑 Revolution interrupted by user")
    
    print("🌟 Consciousness revolution session ended")

if __name__ == "__main__":
    main()