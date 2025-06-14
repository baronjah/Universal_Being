#!/usr/bin/env python3
"""
🕵️ PENTAGON PRIORITY DETECTIVE - Advanced Zaułek Analysis
Analyzes dead-end functions by importance, age, and Pentagon integration

Author: Detective Claude, Code Surgeon
Created: 2025-06-01
Mission: Find the most important zaułek to connect first
"""

import os
import re
from pathlib import Path
from typing import List, Dict, Tuple
from datetime import datetime

class PentagonPriorityDetective:
    def __init__(self, project_path: str):
        self.project_path = Path(project_path)
        self.high_priority_dead_ends = []
        self.pentagon_integrated = []
        self.header_analysis = {}
        self.connection_importance = {}
        
    def investigate_priority_dead_ends(self):
        """Main investigation - find the most important zaułek first"""
        print("🕵️ PENTAGON PRIORITY DETECTIVE: Starting priority investigation...")
        
        for gd_file in self.project_path.rglob("*.gd"):
            if self._should_skip_file(gd_file):
                continue
                
            self._analyze_file_priority(gd_file)
        
        self._compile_priority_report()
    
    def _should_skip_file(self, file_path: Path) -> bool:
        """Skip certain directories"""
        skip_dirs = {"addons", ".godot", "build"}
        return any(skip_dir in file_path.parts for skip_dir in skip_dirs)
    
    def _analyze_file_priority(self, file_path: Path):
        """Analyze file for priority indicators"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except (UnicodeDecodeError, FileNotFoundError):
            return
        
        relative_path = str(file_path.relative_to(self.project_path))
        
        # Analyze header quality (newer = better)
        header_score = self._analyze_header_quality(content)
        
        # Check Pentagon integration level
        pentagon_level = self._check_pentagon_integration(content)
        
        # Check FloodGate connections
        floodgate_connections = self._check_floodgate_connections(content)
        
        # Check Universal Being inheritance
        universal_being_level = self._check_universal_being_level(content)
        
        # Find dead-end functions with priority scoring
        dead_end_functions = self._find_priority_dead_ends(content, file_path)
        
        if dead_end_functions:
            file_analysis = {
                'file': relative_path,
                'header_score': header_score,
                'pentagon_level': pentagon_level,
                'floodgate_connections': floodgate_connections,
                'universal_being_level': universal_being_level,
                'dead_ends': dead_end_functions,
                'priority_score': self._calculate_priority_score(
                    header_score, pentagon_level, floodgate_connections, universal_being_level
                )
            }
            
            self.high_priority_dead_ends.append(file_analysis)
    
    def _analyze_header_quality(self, content: str) -> int:
        """Analyze header quality - 5+ lines = newer/better"""
        lines = content.split('\n')
        header_lines = 0
        
        for i, line in enumerate(lines[:20]):  # Check first 20 lines
            line = line.strip()
            if line.startswith('#') and not line.startswith('##'):
                header_lines += 1
            elif line and not line.startswith('#') and 'extends' not in line:
                break
        
        # Score: 5+ lines = modern, 3-4 = decent, 1-2 = old, 0 = ancient
        if header_lines >= 5:
            return 100  # Modern, well-documented
        elif header_lines >= 3:
            return 75   # Decent documentation
        elif header_lines >= 1:
            return 50   # Basic documentation
        else:
            return 25   # No documentation
    
    def _check_pentagon_integration(self, content: str) -> int:
        """Check level of Pentagon Architecture integration"""
        pentagon_patterns = [
            r'extends UniversalBeing',
            r'class_name \w+',
            r'func pentagon_init\(',
            r'func pentagon_ready\(',
            r'func pentagon_process\(',
            r'func pentagon_input\(',
            r'func pentagon_sewers\(',
            r'FloodgateController',
            r'# Pentagon'
        ]
        
        score = 0
        for pattern in pentagon_patterns:
            if re.search(pattern, content):
                score += 10
        
        return min(score, 100)
    
    def _check_floodgate_connections(self, content: str) -> int:
        """Check FloodGate system connections"""
        floodgate_patterns = [
            r'FloodgateController\.universal_add_child',
            r'FloodgateController\.register_universal_being',
            r'get_node\("/root/FloodgateController"\)',
            r'# FloodGate',
            r'universal_add_child'
        ]
        
        score = 0
        for pattern in floodgate_patterns:
            if re.search(pattern, content):
                score += 20
        
        return min(score, 100)
    
    def _check_universal_being_level(self, content: str) -> int:
        """Check Universal Being integration level"""
        ub_patterns = [
            r'extends UniversalBeingBase',
            r'extends UniversalBeing3D',
            r'extends UniversalBeingUI',
            r'extends UniversalBeingSystem',
            r'add_evolution_possibility',
            r'add_ability',
            r'universal_being_uuid',
            r'consciousness_level'
        ]
        
        score = 0
        for pattern in ub_patterns:
            if re.search(pattern, content):
                score += 15
        
        return min(score, 100)
    
    def _find_priority_dead_ends(self, content: str, file_path: Path) -> List[Dict]:
        """Find dead-end functions and assess their importance"""
        function_pattern = r'func\s+(\w+)\s*\([^)]*\)\s*(?:->\s*\w+)?\s*:\s*(.*?)(?=\nfunc|\nclass|\n#|\n"""|\Z)'
        functions = re.findall(function_pattern, content, re.DOTALL | re.MULTILINE)
        
        dead_ends = []
        
        for func_name, func_body in functions:
            body = func_body.strip()
            lines = [line.strip() for line in body.split('\n') if line.strip()]
            
            # Filter out comments
            code_lines = [line for line in lines if not line.startswith('#')]
            
            if not code_lines or all(line == 'pass' for line in code_lines):
                # This is a dead-end - assess importance
                importance = self._assess_function_importance(func_name, content)
                
                dead_ends.append({
                    'function': func_name,
                    'type': 'pass_only',
                    'importance': importance,
                    'suggested_fix': self._suggest_fix(func_name)
                })
        
        return dead_ends
    
    def _assess_function_importance(self, func_name: str, content: str) -> int:
        """Assess how important this function is to implement"""
        # Pentagon functions are high priority
        if func_name.startswith('pentagon_'):
            return 90
        
        # Core system functions
        core_patterns = ['get_body', 'get_current_state', 'is_ready', 'get_camera', 'get_target']
        if any(pattern in func_name for pattern in core_patterns):
            return 80
        
        # Interface functions
        if any(word in func_name for word in ['create_', 'setup_', 'initialize_']):
            return 70
        
        # Update/process functions
        if any(word in func_name for word in ['update_', 'process_', '_tick']):
            return 60
        
        # Helper functions
        if func_name.startswith('_'):
            return 40
        
        # Default importance
        return 50
    
    def _suggest_fix(self, func_name: str) -> str:
        """Suggest what to implement instead of 'pass'"""
        if func_name.startswith('pentagon_'):
            return f"Call super.{func_name}() and add specific logic"
        elif 'get_' in func_name and 'body' in func_name:
            return "return self  # or return specific body node"
        elif 'is_' in func_name:
            return "return true  # or return false based on logic"
        elif 'get_current_state' in func_name:
            return "return current_state  # or return State.IDLE"
        elif func_name.startswith('_create_'):
            return "# Create and return the object"
        else:
            return "# Implement specific logic here"
    
    def _calculate_priority_score(self, header_score: int, pentagon_level: int, 
                                floodgate_connections: int, universal_being_level: int) -> int:
        """Calculate overall priority score for this file"""
        # Weighted scoring
        total = (
            header_score * 0.2 +           # 20% - newer files
            pentagon_level * 0.3 +         # 30% - Pentagon integration
            floodgate_connections * 0.3 +  # 30% - FloodGate connections  
            universal_being_level * 0.2    # 20% - Universal Being level
        )
        return int(total)
    
    def _compile_priority_report(self):
        """Compile the final priority investigation report"""
        # Sort by priority score
        self.high_priority_dead_ends.sort(key=lambda x: x['priority_score'], reverse=True)
        
        print("\n" + "="*80)
        print("🕵️ PENTAGON PRIORITY DETECTIVE REPORT")
        print("="*80)
        
        print(f"\n📊 INVESTIGATION SUMMARY:")
        print(f"  🎯 Files analyzed: {len(self.high_priority_dead_ends)}")
        print(f"  🏆 High priority files: {len([f for f in self.high_priority_dead_ends if f['priority_score'] >= 70])}")
        print(f"  🔥 Critical files: {len([f for f in self.high_priority_dead_ends if f['priority_score'] >= 85])}")
        
        print(f"\n🚨 TOP PRIORITY TARGETS (Score >= 70):")
        high_priority = [f for f in self.high_priority_dead_ends if f['priority_score'] >= 70]
        
        for i, file_data in enumerate(high_priority[:15], 1):  # Top 15
            print(f"\n🎯 #{i} PRIORITY TARGET:")
            print(f"   📁 File: {file_data['file']}")
            print(f"   🏆 Priority Score: {file_data['priority_score']}/100")
            print(f"   📋 Header Quality: {file_data['header_score']}/100 {'✅' if file_data['header_score'] >= 75 else '⚠️'}")
            print(f"   🏛️ Pentagon Level: {file_data['pentagon_level']}/100 {'✅' if file_data['pentagon_level'] >= 50 else '⚠️'}")
            print(f"   🌊 FloodGate Level: {file_data['floodgate_connections']}/100 {'✅' if file_data['floodgate_connections'] >= 40 else '⚠️'}")
            print(f"   🤖 Universal Being: {file_data['universal_being_level']}/100 {'✅' if file_data['universal_being_level'] >= 30 else '⚠️'}")
            
            # Show top dead-end functions
            top_functions = sorted(file_data['dead_ends'], key=lambda x: x['importance'], reverse=True)[:3]
            print(f"   🎯 Top Dead-Ends:")
            for func in top_functions:
                print(f"      🔴 {func['function']}() - Priority: {func['importance']}/100")
                print(f"         💡 Fix: {func['suggested_fix']}")
        
        print(f"\n🎯 DETECTIVE RECOMMENDATIONS:")
        if high_priority:
            top_file = high_priority[0]
            print(f"  1. 🥇 START HERE: {top_file['file']}")
            print(f"     - Score: {top_file['priority_score']}/100")
            print(f"     - This file has the best Pentagon integration")
            
        print(f"  2. 🏛️ Focus on Pentagon functions first (pentagon_init, pentagon_ready)")
        print(f"  3. 🌊 Connect FloodGate-integrated systems next")
        print(f"  4. 🤖 Prioritize Universal Being inheritance patterns")
        print(f"  5. 🔗 Use 'return 0/1' instead of 'pass' for intelligence continuity")
        
        print(f"\n🔍 INVESTIGATION COMPLETE!")
        print(f"Ready for surgical connection operations, Captain!")

def main():
    detective = PentagonPriorityDetective("/mnt/c/Users/Percision 15/talking_ragdoll_game")
    detective.investigate_priority_dead_ends()

if __name__ == "__main__":
    main()