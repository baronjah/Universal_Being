#!/usr/bin/env python3
"""
Header Timeline Analyzer - 4D Programming Timeline Discovery
Analyzes all .gd files to understand development phases through header patterns
"""

import os
import re
import json
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple

class HeaderTimelineAnalyzer:
    def __init__(self, project_path: str):
        self.project_path = Path(project_path)
        self.files_with_headers = []
        self.files_without_headers = []
        self.header_patterns = []
        self.development_phases = {}
        
    def analyze_all_files(self) -> Dict:
        """Analyze all .gd files for header patterns and timeline"""
        print("🕰️ Header Timeline Analyzer - 4D Programming History")
        print("=" * 60)
        
        gd_files = list(self.project_path.rglob("*.gd"))
        print(f"📊 Analyzing {len(gd_files)} GDScript files for header patterns...")
        print()
        
        for file_path in gd_files:
            self._analyze_file_header(file_path)
        
        self._categorize_development_phases()
        self._print_timeline_analysis()
        
        return self._generate_report()
    
    def _analyze_file_header(self, file_path: Path) -> None:
        """Analyze individual file for header pattern"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"❌ Could not read {file_path}: {e}")
            return
        
        relative_path = str(file_path.relative_to(self.project_path))
        
        # Check for standardized header pattern
        header_info = self._extract_header_info(content, relative_path)
        
        if header_info['has_standard_header']:
            self.files_with_headers.append(header_info)
            print(f"✅ {relative_path} - {header_info['created_date']}")
        else:
            self.files_without_headers.append(header_info)
            print(f"📝 {relative_path} - {header_info['header_type']}")
    
    def _extract_header_info(self, content: str, file_path: str) -> Dict:
        """Extract header information from file content"""
        lines = content.split('\n')[:20]  # Check first 20 lines
        
        # Look for standard header pattern
        standard_header_pattern = r'# SCRIPT NAME:|# DESCRIPTION:|# PURPOSE:|# CREATED:'
        has_standard_header = bool(re.search(standard_header_pattern, content[:1000]))
        
        header_info = {
            'file_path': file_path,
            'has_standard_header': has_standard_header,
            'created_date': 'Unknown',
            'script_name': '',
            'description': '',
            'purpose': '',
            'header_type': 'none',
            'first_lines': lines[:5]
        }
        
        if has_standard_header:
            # Extract standard header fields
            script_name_match = re.search(r'# SCRIPT NAME:\s*(.+)', content)
            description_match = re.search(r'# DESCRIPTION:\s*(.+)', content)
            purpose_match = re.search(r'# PURPOSE:\s*(.+)', content)
            created_match = re.search(r'# CREATED:\s*(.+)', content)
            
            if script_name_match:
                header_info['script_name'] = script_name_match.group(1).strip()
            if description_match:
                header_info['description'] = description_match.group(1).strip()
            if purpose_match:
                header_info['purpose'] = purpose_match.group(1).strip()
            if created_match:
                header_info['created_date'] = created_match.group(1).strip()
                
            header_info['header_type'] = 'standard'
        else:
            # Analyze non-standard header types
            header_info['header_type'] = self._classify_header_type(lines)
        
        return header_info
    
    def _classify_header_type(self, lines: List[str]) -> str:
        """Classify the type of header (if any)"""
        header_text = '\n'.join(lines).lower()
        
        if '################################################################' in header_text:
            return 'hash_border'
        elif '====' in header_text or '----' in header_text:
            return 'simple_border'
        elif any(line.strip().startswith('#') and len(line.strip()) > 10 for line in lines[:3]):
            return 'basic_comment'
        elif any('controller' in line.lower() or 'system' in line.lower() for line in lines[:3]):
            return 'descriptive_comment'
        else:
            return 'minimal_or_none'
    
    def _categorize_development_phases(self) -> None:
        """Categorize files into development phases based on headers"""
        
        # Phase 1: Pre-header era (no standard headers)
        phase_1 = [f for f in self.files_without_headers 
                  if f['header_type'] in ['minimal_or_none', 'basic_comment']]
        
        # Phase 2: Early organization (simple headers)
        phase_2 = [f for f in self.files_without_headers 
                  if f['header_type'] in ['simple_border', 'descriptive_comment']]
        
        # Phase 3: Structured documentation (hash borders)
        phase_3 = [f for f in self.files_without_headers 
                  if f['header_type'] == 'hash_border']
        
        # Phase 4: Standardized headers (current era)
        phase_4 = self.files_with_headers
        
        self.development_phases = {
            'phase_1_prehistoric': {
                'name': 'Prehistoric Era (Pre-Header)',
                'files': phase_1,
                'characteristics': 'Minimal documentation, rapid prototyping',
                'file_count': len(phase_1)
            },
            'phase_2_early': {
                'name': 'Early Organization Era',
                'files': phase_2,
                'characteristics': 'Basic comments, growing structure',
                'file_count': len(phase_2)
            },
            'phase_3_structured': {
                'name': 'Structured Documentation Era',
                'files': phase_3,
                'characteristics': 'Hash borders, formal structure',
                'file_count': len(phase_3)
            },
            'phase_4_standardized': {
                'name': 'Standardized Header Era (Current)',
                'files': phase_4,
                'characteristics': 'Full header metadata, professional organization',
                'file_count': len(phase_4)
            }
        }
    
    def _print_timeline_analysis(self) -> None:
        """Print comprehensive timeline analysis"""
        print("\n" + "=" * 60)
        print("🕰️ 4D PROGRAMMING TIMELINE ANALYSIS")
        print("=" * 60)
        
        total_files = len(self.files_with_headers) + len(self.files_without_headers)
        
        for phase_key, phase_data in self.development_phases.items():
            percentage = (phase_data['file_count'] / total_files) * 100
            print(f"\n📅 {phase_data['name']}")
            print(f"   Files: {phase_data['file_count']} ({percentage:.1f}%)")
            print(f"   📝 {phase_data['characteristics']}")
            
            # Show sample files
            if phase_data['files']:
                print("   📂 Sample files:")
                for i, file_info in enumerate(phase_data['files'][:3]):
                    print(f"      • {file_info['file_path']}")
                if len(phase_data['files']) > 3:
                    print(f"      ... and {len(phase_data['files']) - 3} more")
        
        print(f"\n📊 SUMMARY:")
        print(f"   Total files analyzed: {total_files}")
        print(f"   ✅ With standard headers: {len(self.files_with_headers)}")
        print(f"   📝 Without standard headers: {len(self.files_without_headers)}")
        
        # Evolution insights
        print(f"\n🧬 EVOLUTION INSIGHTS:")
        if len(self.files_with_headers) > 0:
            print(f"   🎯 You started using standardized headers consistently")
            print(f"   📈 Code quality evolution visible through documentation")
            print(f"   🔄 {len(self.files_without_headers)} files need header updates")
        
        # Temporal recommendations
        print(f"\n💡 TEMPORAL INTEGRATION STRATEGY:")
        print(f"   1. Files from same phase likely share architectural patterns")
        print(f"   2. Phase 1 files may need modernization")
        print(f"   3. Phase 4 files represent current best practices")
        print(f"   4. Use temporal grouping for migration planning")
    
    def _generate_report(self) -> Dict:
        """Generate comprehensive report"""
        return {
            'analysis_timestamp': datetime.now().isoformat(),
            'project_path': str(self.project_path),
            'total_files': len(self.files_with_headers) + len(self.files_without_headers),
            'development_phases': self.development_phases,
            'files_with_headers': self.files_with_headers,
            'files_without_headers': self.files_without_headers,
            'recommendations': self._generate_recommendations()
        }
    
    def _generate_recommendations(self) -> Dict:
        """Generate recommendations based on timeline analysis"""
        return {
            'header_standardization': {
                'priority': 'high',
                'description': f'Add standard headers to {len(self.files_without_headers)} files',
                'benefits': 'Improved code organization and temporal tracking'
            },
            'phase_based_refactoring': {
                'priority': 'medium', 
                'description': 'Group files by development phase for targeted refactoring',
                'benefits': 'Modernize older code while preserving newer architecture'
            },
            'temporal_documentation': {
                'priority': 'low',
                'description': 'Document the evolution story of the codebase',
                'benefits': 'Historical context for future development'
            }
        }
    
    def save_report(self, output_file: str = "header_timeline_report.json") -> None:
        """Save detailed report to JSON"""
        report = self._generate_report()
        
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2)
        
        print(f"\n📄 Detailed report saved to: {output_file}")

def main():
    """Main analysis function"""
    project_path = "/mnt/c/Users/Percision 15/talking_ragdoll_game"
    
    analyzer = HeaderTimelineAnalyzer(project_path)
    analyzer.analyze_all_files()
    analyzer.save_report()
    
    print("\n🕰️ Header Timeline Analysis Complete!")
    print("💡 Use this temporal data to guide file organization and modernization!")

if __name__ == "__main__":
    main()