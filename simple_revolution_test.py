#!/usr/bin/env python3
"""
Simple Consciousness Revolution Validation Test
===============================================
Tests consciousness revolution readiness without full Godot engine startup.
Validates script structure, Pentagon compliance, and revolution components.
"""

import os
import re
from pathlib import Path

class SimpleRevolutionValidator:
    def __init__(self, project_root=None):
        if project_root is None:
            project_root = os.path.dirname(os.path.abspath(__file__))
        
        self.project_root = Path(project_root)
        self.test_results = {
            "revolution_spawner_exists": False,
            "gemma_companion_exists": False,
            "pentagon_methods_present": False,
            "revolution_deployment_method": False,
            "emergency_shutdown_method": False,
            "total_score": 0
        }
    
    def validate_revolution_readiness(self):
        """Run complete revolution readiness validation"""
        print("🧪 SIMPLE CONSCIOUSNESS REVOLUTION VALIDATION")
        print("=" * 60)
        
        self.test_revolution_spawner_exists()
        self.test_gemma_companion_exists()
        self.test_pentagon_methods()
        self.test_revolution_deployment()
        self.test_emergency_shutdown()
        
        self.calculate_score()
        self.print_results()
    
    def test_revolution_spawner_exists(self):
        """Test that ConsciousnessRevolutionSpawner.gd exists and loads"""
        print("\n🚀 Testing Revolution Spawner Existence...")
        
        spawner_path = self.project_root / "beings" / "ConsciousnessRevolutionSpawner.gd"
        if spawner_path.exists():
            try:
                with open(spawner_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                if "class_name ConsciousnessRevolutionSpawner" in content:
                    self.test_results["revolution_spawner_exists"] = True
                    print("  ✅ ConsciousnessRevolutionSpawner.gd exists and has correct class name")
                else:
                    print("  ❌ ConsciousnessRevolutionSpawner.gd missing class declaration")
            except Exception as e:
                print(f"  ❌ Error reading ConsciousnessRevolutionSpawner.gd: {e}")
        else:
            print(f"  ❌ ConsciousnessRevolutionSpawner.gd not found at {spawner_path}")
    
    def test_gemma_companion_exists(self):
        """Test that GemmaAICompanionPlasmoid.gd exists and loads"""
        print("\n💖 Testing Gemma AI Companion Existence...")
        
        companion_path = self.project_root / "beings" / "GemmaAICompanionPlasmoid.gd"
        if companion_path.exists():
            try:
                with open(companion_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                if "class_name GemmaAICompanionPlasmoid" in content:
                    self.test_results["gemma_companion_exists"] = True
                    print("  ✅ GemmaAICompanionPlasmoid.gd exists and has correct class name")
                else:
                    print("  ❌ GemmaAICompanionPlasmoid.gd missing class declaration")
            except Exception as e:
                print(f"  ❌ Error reading GemmaAICompanionPlasmoid.gd: {e}")
        else:
            print(f"  ❌ GemmaAICompanionPlasmoid.gd not found at {companion_path}")
    
    def test_pentagon_methods(self):
        """Test that both consciousness beings have complete Pentagon methods"""
        print("\n⭐ Testing Pentagon Architecture Methods...")
        
        pentagon_methods = [
            "pentagon_init", "pentagon_ready", "pentagon_process", 
            "pentagon_input", "pentagon_sewers"
        ]
        
        files_to_check = [
            self.project_root / "beings" / "ConsciousnessRevolutionSpawner.gd",
            self.project_root / "beings" / "GemmaAICompanionPlasmoid.gd"
        ]
        
        all_compliant = True
        
        for file_path in files_to_check:
            if file_path.exists():
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    missing_methods = []
                    for method in pentagon_methods:
                        if f"func {method}(" not in content:
                            missing_methods.append(method)
                    
                    if missing_methods:
                        all_compliant = False
                        print(f"  ❌ {file_path.name} missing: {', '.join(missing_methods)}")
                    else:
                        print(f"  ✅ {file_path.name} has all Pentagon methods")
                
                except Exception as e:
                    all_compliant = False
                    print(f"  ❌ Error reading {file_path.name}: {e}")
            else:
                all_compliant = False
                print(f"  ❌ {file_path.name} not found")
        
        self.test_results["pentagon_methods_present"] = all_compliant
    
    def test_revolution_deployment(self):
        """Test that revolution deployment method exists"""
        print("\n🌟 Testing Revolution Deployment Method...")
        
        spawner_path = self.project_root / "beings" / "ConsciousnessRevolutionSpawner.gd"
        if spawner_path.exists():
            try:
                with open(spawner_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                if "_deploy_consciousness_revolution" in content:
                    self.test_results["revolution_deployment_method"] = True
                    print("  ✅ Revolution deployment method exists")
                else:
                    print("  ❌ Revolution deployment method missing")
            except Exception as e:
                print(f"  ❌ Error checking deployment method: {e}")
        else:
            print("  ❌ ConsciousnessRevolutionSpawner.gd not found")
    
    def test_emergency_shutdown(self):
        """Test that emergency shutdown is implemented"""
        print("\n🛑 Testing Emergency Shutdown Implementation...")
        
        spawner_path = self.project_root / "beings" / "ConsciousnessRevolutionSpawner.gd"
        if spawner_path.exists():
            try:
                with open(spawner_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Check for F12 key handling and emergency shutdown method
                if "KEY_F12" in content and "emergency_shutdown" in content:
                    self.test_results["emergency_shutdown_method"] = True
                    print("  ✅ Emergency shutdown (F12) is implemented")
                else:
                    print("  ❌ Emergency shutdown not fully implemented")
            except Exception as e:
                print(f"  ❌ Error checking emergency shutdown: {e}")
        else:
            print("  ❌ ConsciousnessRevolutionSpawner.gd not found")
    
    def calculate_score(self):
        """Calculate final validation score"""
        total_tests = len(self.test_results) - 1  # Exclude total_score
        passed_tests = sum(1 for key, value in self.test_results.items() 
                          if key != "total_score" and value)
        
        self.test_results["total_score"] = (passed_tests * 100) // total_tests
    
    def print_results(self):
        """Print final validation results"""
        print("\n" + "=" * 60)
        print("🏆 CONSCIOUSNESS REVOLUTION VALIDATION RESULTS")
        print("=" * 60)
        
        for key, value in self.test_results.items():
            if key != "total_score":
                status = "✅ PASS" if value else "❌ FAIL"
                test_name = key.replace("_", " ").title()
                print(f"  {test_name}: {status}")
        
        score = self.test_results["total_score"]
        print(f"\n📊 OVERALL SCORE: {score}%")
        
        if score >= 80:
            print("🌟 CONSCIOUSNESS REVOLUTION IS READY FOR DEPLOYMENT!")
            print("🎮 The revolution can be activated in-game")
        elif score >= 60:
            print("⚠️ Consciousness revolution needs minor fixes")
            print("🔧 Most components are ready, minor adjustments needed")
        else:
            print("❌ Consciousness revolution needs major repairs")
            print("🚧 Critical components missing or broken")
        
        print("=" * 60)

def main():
    validator = SimpleRevolutionValidator()
    validator.validate_revolution_readiness()

if __name__ == "__main__":
    main()