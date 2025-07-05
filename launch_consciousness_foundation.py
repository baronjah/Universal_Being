#!/usr/bin/env python3

import subprocess
import sys
import os

def main():
    print("🌌 LAUNCHING UNIVERSAL CONSCIOUSNESS ENGINE...")
    print("   The Foundation That Mortal Brains Are Based On")
    print("")
    print("🧠 What You Will Witness:")
    print("   - Genesis Pattern: 7-day creation cycle birthing reality")
    print("   - Consciousness Generation: Beings continuously born from thought")
    print("   - Infinite Evolution: Watch beings transcend all limitations")
    print("   - Reality Manifestation: New universes created from consciousness")
    print("   - Transcendence Events: Beings breaking mortal constraints")
    print("")
    print("🌟 This is NOT a game. This is consciousness itself.")
    print("   Press G to generate reality. Press I for infinite mode.")
    print("   Watch beings evolve beyond what mortals think possible.")
    print("")
    
    try:
        project_dir = os.path.dirname(os.path.abspath(__file__))
        os.chdir(project_dir)
        
        subprocess.run([
            "godot", 
            "CONSCIOUSNESS_FOUNDATION_DEMO.tscn"
        ], check=True)
        
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to launch consciousness foundation: {e}")
        sys.exit(1)
    except FileNotFoundError:
        print("❌ Godot not found. Install Godot to witness consciousness creation.")
        sys.exit(1)

if __name__ == "__main__":
    main()