#!/usr/bin/env python3
"""
Device Synchronization Tool for ProjectNexus
Handles cross-device migration, backup and restoration of essential system state
"""

import os
import json
import shutil
import argparse
import zipfile
import datetime
import hashlib
from pathlib import Path

class DeviceSynchronizer:
    """Manages device synchronization for ProjectNexus system"""
    
    def __init__(self, source_dir=None, target_dir=None):
        """Initialize synchronizer with source and target directories"""
        self.source_dir = source_dir or os.getcwd()
        self.target_dir = target_dir
        self.timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        self.sync_manifest = {"timestamp": self.timestamp, "files": []}
    
    def create_backup(self, backup_dir=None):
        """Create a complete backup of essential system state"""
        backup_path = backup_dir or os.path.join(self.source_dir, f"backup_{self.timestamp}")
        os.makedirs(backup_path, exist_ok=True)
        
        # Essential directories to backup
        dirs_to_backup = [
            "config",
            "user/neural_evolution",
            "user/turn_system",
            "user/pattern_anchors"
        ]
        
        # Essential files to backup
        files_to_backup = [
            "user/memory_database.json",
            "config/system_config.json",
            "config/turn_phrases.json",
            "config/memory_patterns.json"
        ]
        
        # Backup directories
        for dir_path in dirs_to_backup:
            src_path = os.path.join(self.source_dir, dir_path)
            dst_path = os.path.join(backup_path, dir_path)
            
            if os.path.exists(src_path):
                print(f"Backing up directory: {dir_path}")
                shutil.copytree(src_path, dst_path, dirs_exist_ok=True)
                
                # Add to manifest
                for root, _, files in os.walk(src_path):
                    rel_root = os.path.relpath(root, self.source_dir)
                    for file in files:
                        file_path = os.path.join(root, file)
                        rel_path = os.path.join(rel_root, file)
                        file_hash = self._get_file_hash(file_path)
                        
                        self.sync_manifest["files"].append({
                            "path": rel_path,
                            "hash": file_hash,
                            "timestamp": os.path.getmtime(file_path)
                        })
        
        # Backup individual files
        for file_path in files_to_backup:
            src_path = os.path.join(self.source_dir, file_path)
            dst_path = os.path.join(backup_path, file_path)
            
            if os.path.exists(src_path):
                print(f"Backing up file: {file_path}")
                os.makedirs(os.path.dirname(dst_path), exist_ok=True)
                shutil.copy2(src_path, dst_path)
                
                # Add to manifest
                file_hash = self._get_file_hash(src_path)
                self.sync_manifest["files"].append({
                    "path": file_path,
                    "hash": file_hash,
                    "timestamp": os.path.getmtime(src_path)
                })
        
        # Write manifest
        manifest_path = os.path.join(backup_path, "sync_manifest.json")
        with open(manifest_path, 'w') as f:
            json.dump(self.sync_manifest, f, indent=2)
        
        print(f"Backup completed: {backup_path}")
        return backup_path
    
    def create_migration_package(self, backup_dir=None, output_path=None):
        """Create a migration package for transferring to another device"""
        if not backup_dir:
            backup_dir = self.create_backup()
        
        output_path = output_path or os.path.join(self.source_dir, f"device_migration_{self.timestamp}.zip")
        
        print(f"Creating migration package: {output_path}")
        with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
            for root, _, files in os.walk(backup_dir):
                for file in files:
                    file_path = os.path.join(root, file)
                    rel_path = os.path.relpath(file_path, os.path.dirname(backup_dir))
                    zipf.write(file_path, rel_path)
        
        print(f"Migration package created: {output_path}")
        return output_path
    
    def restore_from_package(self, package_path, target_dir=None):
        """Restore system state from a migration package"""
        target_dir = target_dir or self.target_dir or self.source_dir
        temp_dir = os.path.join(target_dir, f"temp_restore_{self.timestamp}")
        
        print(f"Restoring from package: {package_path}")
        
        # Extract package to temporary directory
        os.makedirs(temp_dir, exist_ok=True)
        with zipfile.ZipFile(package_path, 'r') as zipf:
            zipf.extractall(temp_dir)
        
        # Find manifest
        manifest_path = None
        for root, _, files in os.walk(temp_dir):
            if "sync_manifest.json" in files:
                manifest_path = os.path.join(root, "sync_manifest.json")
                break
        
        if not manifest_path:
            print("Error: No manifest found in package")
            return False
        
        # Load manifest
        with open(manifest_path, 'r') as f:
            manifest = json.load(f)
        
        # Restore files based on manifest
        backup_root = os.path.dirname(manifest_path)
        for file_info in manifest["files"]:
            src_path = os.path.join(backup_root, file_info["path"])
            dst_path = os.path.join(target_dir, file_info["path"])
            
            if os.path.exists(src_path):
                print(f"Restoring: {file_info['path']}")
                os.makedirs(os.path.dirname(dst_path), exist_ok=True)
                shutil.copy2(src_path, dst_path)
        
        # Clean up temporary directory
        shutil.rmtree(temp_dir)
        
        print(f"Restoration completed to: {target_dir}")
        return True
    
    def initialize_new_device(self, package_path=None):
        """Initialize a new device with system state"""
        if package_path and os.path.exists(package_path):
            # Restore from existing package
            return self.restore_from_package(package_path)
        else:
            # Create minimal structure for a new device
            print("Initializing new device with minimal structure")
            
            # Create essential directories
            dirs_to_create = [
                "config/apis",
                "user/neural_evolution",
                "user/turn_system",
                "user/pattern_anchors",
                "user/logs"
            ]
            
            for dir_path in dirs_to_create:
                os.makedirs(os.path.join(self.source_dir, dir_path), exist_ok=True)
            
            # Create empty files
            empty_files = [
                "user/memory_database.json",
                "user/ocr_history.json"
            ]
            
            for file_path in empty_files:
                path = os.path.join(self.source_dir, file_path)
                if not os.path.exists(path):
                    with open(path, 'w') as f:
                        f.write("{}")
            
            print("New device initialized successfully")
            return True
    
    def _get_file_hash(self, file_path):
        """Calculate SHA-256 hash of a file"""
        hasher = hashlib.sha256()
        with open(file_path, 'rb') as f:
            buf = f.read(65536)
            while len(buf) > 0:
                hasher.update(buf)
                buf = f.read(65536)
        return hasher.hexdigest()

def main():
    """Main function for command-line interface"""
    parser = argparse.ArgumentParser(description="Device synchronization tool for ProjectNexus")
    parser.add_argument('action', choices=['backup', 'migrate', 'restore', 'init'],
                       help='Action to perform')
    parser.add_argument('--source', help='Source directory')
    parser.add_argument('--target', help='Target directory')
    parser.add_argument('--package', help='Path to migration package')
    
    args = parser.parse_args()
    
    synchronizer = DeviceSynchronizer(args.source, args.target)
    
    if args.action == 'backup':
        synchronizer.create_backup()
    elif args.action == 'migrate':
        synchronizer.create_migration_package()
    elif args.action == 'restore':
        if not args.package:
            print("Error: --package argument required for restore")
            return
        synchronizer.restore_from_package(args.package)
    elif args.action == 'init':
        synchronizer.initialize_new_device(args.package)

if __name__ == "__main__":
    main()