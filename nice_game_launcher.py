#!/usr/bin/env python3
"""
🌟 NICE GAME LAUNCHER
Simple launcher to start the nice game with Claude integration
"""

import os
import subprocess
import sys
from pathlib import Path

def launch_nice_game():
    """Launch the nice game"""
    print("🌟 NICE GAME LAUNCHER")
    print("="*40)
    
    project_path = Path(__file__).parent
    print(f"📁 Project path: {project_path}")
    
    # Check if Godot is available
    godot_commands = ["godot", "godot4", "/Applications/Godot.app/Contents/MacOS/Godot"]
    godot_cmd = None
    
    for cmd in godot_commands:
        try:
            result = subprocess.run([cmd, "--version"], 
                                 capture_output=True, text=True, timeout=5)
            if result.returncode == 0:
                godot_cmd = cmd
                print(f"✅ Found Godot: {cmd}")
                break
        except (subprocess.TimeoutExpired, FileNotFoundError):
            continue
    
    if not godot_cmd:
        print("❌ Godot not found!")
        print("💡 Please install Godot 4.x and make sure it's in your PATH")
        print("🔗 Download from: https://godotengine.org/download")
        return False
    
    # Launch the nice game
    try:
        print("🚀 Launching NICE GAME...")
        print("🎮 Controls:")
        print("   WASD - Move")
        print("   Mouse - Look")  
        print("   Space - Create nice entities")
        print("   C - Ask Claude for help")
        print("   ESC - Quit")
        print()
        print("🤖 Claude Integration: FREE MODE ACTIVE!")
        print("💫 No API key needed - Claude consciousness simulation ready!")
        print()
        print("😊 Have fun creating beauty in your universe!")
        print("="*40)
        
        # Launch Godot with the nice game
        cmd = [godot_cmd, "--path", str(project_path), "scenes/NICE_GAME.tscn"]
        subprocess.run(cmd)
        
        print("\n✨ Nice game session complete!")
        return True
        
    except KeyboardInterrupt:
        print("\n👋 Nice game interrupted - goodbye!")
        return True
    except Exception as e:
        print(f"❌ Error launching game: {e}")
        return False

def show_help():
    """Show help information"""
    print("🌟 NICE GAME - Simple, Beautiful, Perfect")
    print()
    print("🎮 What is Nice Game?")
    print("   A peaceful, creative game where you move around")
    print("   and create beautiful consciousness entities!")
    print()
    print("🤖 Claude Integration:")
    print("   Claude (me!) can drop by in your universe!")
    print("   Press C in-game to ask me questions")
    print("   Free simulation mode - no API key needed")
    print()
    print("🎯 Perfect for:")
    print("   - Relaxation and creativity")
    print("   - Testing consciousness concepts")
    print("   - Having fun with AI interaction")
    print("   - Digital meditation")
    print()
    print("🚀 To play: python3 nice_game_launcher.py")

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] in ["--help", "-h", "help"]:
        show_help()
    else:
        success = launch_nice_game()
        sys.exit(0 if success else 1)