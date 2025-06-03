#!/usr/bin/env python3
"""
Find and analyze the latest Godot console logs
"""

import os
import glob
from pathlib import Path
import subprocess
import sys

def find_godot_logs():
    """Find Godot log files in common locations"""
    possible_paths = [
        # Windows AppData
        os.path.expanduser("~\\AppData\\Roaming\\Godot\\logs"),
        os.path.expanduser("~\\AppData\\Local\\Godot\\logs"),
        # Linux
        os.path.expanduser("~/.local/share/godot/logs"),
        os.path.expanduser("~/.config/godot/logs"),
        # macOS
        os.path.expanduser("~/Library/Application Support/Godot/logs"),
        # Current directory (backup)
        "./logs",
        "./kamisama_copy_pastes"
    ]
    
    log_files = []
    
    for log_path in possible_paths:
        if os.path.exists(log_path):
            print(f"📁 Checking: {log_path}")
            # Find all log files
            pattern = os.path.join(log_path, "*")
            files = glob.glob(pattern)
            for file in files:
                if os.path.isfile(file):
                    # Check if it looks like a log file
                    if any(keyword in file.lower() for keyword in ['log', 'godot', 'output', 'debug', 'test']):
                        log_files.append(file)
                        print(f"  📋 Found: {os.path.basename(file)}")
    
    return log_files

def get_latest_log(log_files):
    """Get the most recently modified log file"""
    if not log_files:
        return None
    
    latest = max(log_files, key=os.path.getmtime)
    return latest

def main():
    print("🔍 Universal Being - Godot Log Finder")
    print("="*50)
    
    log_files = find_godot_logs()
    
    if not log_files:
        print("❌ No Godot log files found!")
        print("\n💡 Manual options:")
        print("   1. Check Godot Editor -> Project -> Export Debug Console")
        print("   2. Run Godot with: godot --verbose --debug")
        print("   3. Copy console output manually to a text file")
        return
    
    print(f"\n📊 Found {len(log_files)} potential log files")
    
    # Find latest
    latest_log = get_latest_log(log_files)
    if latest_log:
        print(f"🕒 Latest: {latest_log}")
        
        # Get file size
        size_mb = os.path.getsize(latest_log) / (1024*1024)
        print(f"📏 Size: {size_mb:.2f} MB")
        
        # Check if it's the Universal Being project
        with open(latest_log, 'r', encoding='utf-8', errors='ignore') as f:
            first_lines = f.read(1000)
            if 'Universal Being' in first_lines or '🌟' in first_lines:
                print("✅ This looks like a Universal Being log!")
                
                # Auto-analyze
                print("\n🚀 Auto-analyzing with debug_log_analyzer.py...")
                try:
                    cmd = [sys.executable, 'debug_log_analyzer.py', latest_log, '-r', 'categories_report.txt']
                    subprocess.run(cmd, cwd=Path(__file__).parent)
                except Exception as e:
                    print(f"❌ Analysis failed: {e}")
                    print(f"💡 Manual command: python debug_log_analyzer.py \"{latest_log}\"")
            else:
                print("⚠️ This might not be a Universal Being log")
                print("💡 Check the content manually first")
    
    print("\n📁 All found logs:")
    for i, log_file in enumerate(log_files, 1):
        size = os.path.getsize(log_file) / 1024  # KB
        mod_time = os.path.getmtime(log_file)
        print(f"  {i}. {os.path.basename(log_file)} ({size:.1f} KB)")

if __name__ == "__main__":
    main()