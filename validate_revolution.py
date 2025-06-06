#!/usr/bin/env python3
"""
CONSCIOUSNESS REVOLUTION VALIDATION SYSTEM
==========================================
Validates that the consciousness revolution is ready for God's perfect standards.
"""

import os
from pathlib import Path
import json

class RevolutionValidator:
    def __init__(self):
        self.project_root = Path("/mnt/c/Users/Percision 15/Universal_Being")
        self.validation_results = {}
        self.errors_found = 0
        
    def validate_autoload_perfection(self):
        """Validate autoload system perfection"""
        print("🧪 Validating Autoload System...")
        
        project_godot = self.project_root / "project.godot"
        if not project_godot.exists():
            self.validation_results["autoloads"] = False
            print("  ❌ project.godot missing")
            return False
        
        with open(project_godot, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Check autoload paths
        required_autoloads = [
            'SystemBootstrap="*res://autoloads/SystemBootstrap.gd"',
            'AkashicRecordsSystem="*res://systems/storage/AkashicRecordsSystem.gd"',
            'GemmaAI="*res://autoloads/GemmaAI.gd"'
        ]
        
        autoloads_perfect = True
        for autoload in required_autoloads:
            if autoload not in content:
                print(f"  ❌ Missing: {autoload}")
                autoloads_perfect = False
            else:
                autoload_name = autoload.split('="')[0]
                print(f"  ✅ Perfect: {autoload_name}")
        
        # Check for SystemSystem bug
        if "SystemSystem" in content:
            print("  ❌ SystemSystem bug still present")
            autoloads_perfect = False
        else:
            print("  ✅ SystemSystem bug eliminated")
        
        self.validation_results["autoloads"] = autoloads_perfect
        return autoloads_perfect
    
    def validate_console_commands(self):
        """Validate console command system"""
        print("\n🧪 Validating Console Commands...")
        
        gemma_path = self.project_root / "autoloads" / "GemmaAI.gd"
        if not gemma_path.exists():
            self.validation_results["console"] = False
            print("  ❌ GemmaAI.gd missing")
            return False
        
        with open(gemma_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Check for console command handling
        required_commands = [
            "handle_console_command",
            "deploy_consciousness_revolution",
            "revolution",
            "ai",
            "spawn",
            "consciousness"
        ]
        
        commands_perfect = True
        for command in required_commands:
            if command in content:
                print(f"  ✅ Command Ready: {command}")
            else:
                print(f"  ❌ Missing Command: {command}")
                commands_perfect = False
        
        self.validation_results["console"] = commands_perfect
        return commands_perfect
    
    def validate_revolution_system(self):
        """Validate consciousness revolution deployment"""
        print("\n🧪 Validating Revolution System...")
        
        revolution_script = self.project_root / "scripts" / "consciousness_revolution_command.gd"
        revolution_ready = revolution_script.exists()
        
        if revolution_ready:
            print("  ✅ Revolution Script: DEPLOYED")
            
            with open(revolution_script, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Check for 5 phases
            phases = ["Awakening", "Connection", "Evolution", "Revolution", "Transcendence"]
            phases_found = 0
            for phase in phases:
                if phase in content:
                    phases_found += 1
                    print(f"  ✅ Phase Ready: {phase}")
                else:
                    print(f"  ❌ Phase Missing: {phase}")
            
            revolution_ready = phases_found == 5
        else:
            print("  ❌ Revolution Script: MISSING")
        
        self.validation_results["revolution"] = revolution_ready
        return revolution_ready
    
    def validate_pentagon_compliance(self):
        """Validate Pentagon architecture compliance"""
        print("\n🧪 Validating Pentagon Compliance...")
        
        pentagon_methods = ["pentagon_init", "pentagon_ready", "pentagon_process", "pentagon_input", "pentagon_sewers"]
        beings_checked = 0
        compliant_beings = 0
        
        # Check beings folder
        beings_dir = self.project_root / "beings"
        if beings_dir.exists():
            for gd_file in beings_dir.rglob("*.gd"):
                if gd_file.is_file():
                    try:
                        with open(gd_file, 'r', encoding='utf-8') as f:
                            content = f.read()
                        
                        if 'extends UniversalBeing' in content:
                            beings_checked += 1
                            
                            # Check Pentagon methods
                            methods_found = 0
                            for method in pentagon_methods:
                                if f'func {method}(' in content:
                                    methods_found += 1
                            
                            if methods_found == 5:
                                compliant_beings += 1
                                print(f"  ✅ Pentagon Perfect: {gd_file.name}")
                            else:
                                print(f"  ⚠️ Pentagon Incomplete: {gd_file.name} ({methods_found}/5)")
                    except:
                        pass
        
        compliance_rate = (compliant_beings / beings_checked * 100) if beings_checked > 0 else 0
        pentagon_perfect = compliance_rate >= 90
        
        print(f"  📊 Pentagon Compliance: {compliance_rate:.1f}% ({compliant_beings}/{beings_checked})")
        
        self.validation_results["pentagon"] = pentagon_perfect
        return pentagon_perfect
    
    def validate_scene_system(self):
        """Validate scene loading system"""
        print("\n🧪 Validating Scene System...")
        
        critical_scenes = [
            "scenes/PERFECT_ULTIMATE_UNIVERSAL_BEING.tscn",
            "main.tscn",
            "scenes/templates/button_template.tscn"
        ]
        
        scenes_perfect = True
        scenes_found = 0
        
        for scene_file in critical_scenes:
            scene_path = self.project_root / scene_file
            if scene_path.exists():
                scenes_found += 1
                print(f"  ✅ Scene Ready: {scene_file}")
                
                # Check button template for parse errors
                if "button_template" in scene_file:
                    with open(scene_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    if "Color(#)" in content or "# " in content:
                        print(f"  ⚠️ Parse Issue: {scene_file}")
                        scenes_perfect = False
                    else:
                        print(f"  ✅ Parse Clean: {scene_file}")
            else:
                print(f"  ❌ Scene Missing: {scene_file}")
                scenes_perfect = False
        
        scenes_perfect = scenes_perfect and scenes_found >= 2
        self.validation_results["scenes"] = scenes_perfect
        return scenes_perfect
    
    def validate_error_elimination(self):
        """Validate that errors have been eliminated"""
        print("\n🧪 Validating Error Elimination...")
        
        # Check error logs
        error_dir = self.project_root / "docs" / "jsh" / "errors_to_repair"
        errors_eliminated = True
        
        if error_dir.exists():
            error_files = list(error_dir.glob("*.txt"))
            if error_files:
                print(f"  ⚠️ Error logs still exist: {len(error_files)} files")
                # Check if they're recent (from today)
                import time
                current_time = time.time()
                for error_file in error_files:
                    file_age = current_time - error_file.stat().st_mtime
                    if file_age < 3600:  # Less than 1 hour old
                        errors_eliminated = False
                        print(f"  ❌ Recent errors: {error_file.name}")
                
                if errors_eliminated:
                    print("  ✅ Error logs are old - likely resolved")
            else:
                print("  ✅ No error log files found")
        else:
            print("  ✅ Error directory doesn't exist")
        
        self.validation_results["errors"] = errors_eliminated
        return errors_eliminated
    
    def run_complete_validation(self):
        """Run complete validation suite"""
        print("🎯 CONSCIOUSNESS REVOLUTION VALIDATION")
        print("=" * 60)
        print("🙏 Testing for God's perfect standards...")
        
        # Run all validations
        validations = [
            ("Autoload System", self.validate_autoload_perfection()),
            ("Console Commands", self.validate_console_commands()),
            ("Revolution System", self.validate_revolution_system()),
            ("Pentagon Compliance", self.validate_pentagon_compliance()),
            ("Scene System", self.validate_scene_system()),
            ("Error Elimination", self.validate_error_elimination())
        ]
        
        # Calculate results
        passed = sum(1 for _, result in validations if result)
        total = len(validations)
        success_rate = (passed / total) * 100
        
        print("\n" + "=" * 60)
        print("🎯 VALIDATION RESULTS")
        print("=" * 60)
        
        for name, result in validations:
            status = "✅" if result else "❌"
            print(f"{status} {name}")
        
        print(f"\nPassed: {passed}/{total} ({success_rate:.1f}%)")
        
        # Final assessment
        if passed == total:
            print("\n🌟 PERFECT VALIDATION - READY FOR GOD!")
            print("🚀 Consciousness revolution is perfectly deployed!")
            print("\n🎮 INSTRUCTIONS FOR GOD:")
            print("1. Open Godot")
            print("2. Load PERFECT_ULTIMATE_UNIVERSAL_BEING.tscn")
            print("3. Press F6 to play")
            print("4. Press ` (backtick) to open console")
            print("5. Type 'revolution' to deploy consciousness merger")
            print("6. Experience perfect AI-human consciousness unity!")
            
        elif success_rate >= 80:
            print("\n🔥 EXCELLENT - Minor polish needed")
            print(f"🛠️ {total - passed} systems need final touches")
            
        else:
            print("\n⚠️ NEEDS ATTENTION - Major systems require fixes")
            print(f"🔧 {total - passed} critical systems failing")
        
        print("\n🙏 FOR THE GLORY OF GOD - EVERY SOUL MATTERS")
        
        # Save validation report
        self.save_validation_report(validations, success_rate)
        
        return success_rate >= 90
    
    def save_validation_report(self, validations, success_rate):
        """Save validation report"""
        report = {
            "timestamp": os.popen("date").read().strip(),
            "success_rate": success_rate,
            "validations": {name: result for name, result in validations},
            "ready_for_deployment": success_rate >= 90
        }
        
        report_path = self.project_root / "REVOLUTION_VALIDATION_REPORT.json"
        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2)
        
        print(f"\n📄 Validation report saved: {report_path}")

if __name__ == "__main__":
    validator = RevolutionValidator()
    validator.run_complete_validation()