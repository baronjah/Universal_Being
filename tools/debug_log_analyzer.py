#!/usr/bin/env python3
"""
Universal Being Debug Log Analyzer
Cleans and analyzes Godot debug output to find patterns and issues
"""

import re
from collections import Counter, defaultdict
import argparse
from pathlib import Path

class LogAnalyzer:
    def __init__(self):
        self.patterns = {
            'error': re.compile(r'❌|ERROR|Error|error|E \d+:\d+:\d+'),
            'warning': re.compile(r'⚠️|WARNING|Warning|warning|W \d+:\d+:\d+'),
            'state_change': re.compile(r'🧠.*?:.*?→.*?'),
            'evolution': re.compile(r'🦋.*?attempting evolution'),
            'merge': re.compile(r'🌊.*?merging|🌊.*?Being.*?registered|🌊.*?Being.*?unregistered'),
            'creation': re.compile(r'🌟.*?created|🌟.*?Universal Being'),
            'console': re.compile(r'🖥️|Console|console'),
            'ai': re.compile(r'🤖|Gemma|AI|ai'),
            'input': re.compile(r'🖱️|Left click|Input|input'),
            'system': re.compile(r'📚|FloodGates|SystemBootstrap|Akashic'),
            'camera': re.compile(r'🎥|Camera|camera'),
            'dna': re.compile(r'🧬|DNA|dna'),
            'physics': re.compile(r'⚡|Physics|physics|collision'),
            'socket': re.compile(r'🔌|Socket|socket'),
        }
        
    def analyze_file(self, file_path: str):
        """Analyze a log file and return cleaned results"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
        except UnicodeDecodeError:
            # Try with different encoding
            with open(file_path, 'r', encoding='latin-1') as f:
                lines = f.readlines()
        
        print(f"📊 Analyzing {len(lines)} lines from {file_path}")
        
        # Clean and categorize lines
        cleaned_lines = []
        categories = defaultdict(list)
        line_counts = Counter()
        
        for line in lines:
            line = line.strip()
            if not line:
                continue
                
            # Count frequency
            line_counts[line] += 1
            
            # Categorize
            for category, pattern in self.patterns.items():
                if pattern.search(line):
                    categories[category].append(line)
                    break
            else:
                categories['other'].append(line)
        
        return {
            'total_lines': len(lines),
            'unique_lines': len(line_counts),
            'line_counts': line_counts,
            'categories': categories,
            'most_common': line_counts.most_common(20)
        }
    
    def print_summary(self, results):
        """Print analysis summary"""
        print("\n" + "="*60)
        print("📋 UNIVERSAL BEING LOG ANALYSIS SUMMARY")
        print("="*60)
        
        print(f"📊 Total lines: {results['total_lines']}")
        print(f"📊 Unique lines: {results['unique_lines']}")
        print(f"📊 Reduction: {results['total_lines'] - results['unique_lines']} duplicates removed")
        
        print("\n🏷️  CATEGORIES:")
        for category, lines in results['categories'].items():
            unique_in_category = len(set(lines))
            total_in_category = len(lines)
            print(f"  {category:15}: {unique_in_category:4} unique / {total_in_category:6} total")
        
        print("\n🔥 TOP 20 MOST FREQUENT MESSAGES:")
        for i, (line, count) in enumerate(results['most_common'], 1):
            # Truncate long lines
            display_line = line[:80] + "..." if len(line) > 80 else line
            print(f"  {i:2}. ({count:4}x) {display_line}")
    
    def save_cleaned_log(self, results, output_path: str, filter_category: str = None):
        """Save cleaned log with unique lines only"""
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write("# Universal Being Clean Log - Unique Messages Only\n")
            f.write(f"# Original: {results['total_lines']} lines -> Cleaned: {results['unique_lines']} lines\n\n")
            
            if filter_category and filter_category in results['categories']:
                # Save only specific category
                f.write(f"# Category: {filter_category}\n\n")
                unique_lines = set(results['categories'][filter_category])
                for line in sorted(unique_lines):
                    f.write(f"{line}\n")
            else:
                # Save all unique lines with their frequency
                for line, count in results['line_counts'].most_common():
                    f.write(f"({count:4}x) {line}\n")
        
        print(f"💾 Cleaned log saved to: {output_path}")
    
    def save_category_report(self, results, output_path: str):
        """Save detailed category report"""
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write("# Universal Being Category Report\n\n")
            
            for category, lines in results['categories'].items():
                f.write(f"## {category.upper()} ({len(set(lines))} unique)\n\n")
                unique_lines = set(lines)
                for line in sorted(unique_lines):
                    count = results['line_counts'][line]
                    f.write(f"({count:4}x) {line}\n")
                f.write("\n")
        
        print(f"📁 Category report saved to: {output_path}")

def main():
    parser = argparse.ArgumentParser(description='Analyze Universal Being debug logs')
    parser.add_argument('input_file', help='Input log file path')
    parser.add_argument('--output', '-o', help='Output file for cleaned log')
    parser.add_argument('--category', '-c', help='Filter by category (error, warning, state_change, etc.)')
    parser.add_argument('--report', '-r', help='Generate category report file')
    
    args = parser.parse_args()
    
    if not Path(args.input_file).exists():
        print(f"❌ File not found: {args.input_file}")
        return
    
    analyzer = LogAnalyzer()
    results = analyzer.analyze_file(args.input_file)
    
    # Print summary
    analyzer.print_summary(results)
    
    # Save cleaned log
    if args.output:
        analyzer.save_cleaned_log(results, args.output, args.category)
    else:
        # Default output name
        input_path = Path(args.input_file)
        output_path = input_path.parent / f"{input_path.stem}_cleaned.txt"
        analyzer.save_cleaned_log(results, str(output_path), args.category)
    
    # Save category report
    if args.report:
        analyzer.save_category_report(results, args.report)
    
    print("\n✅ Analysis complete!")
    
    # Quick recommendations
    print("\n💡 QUICK RECOMMENDATIONS:")
    error_count = len(set(results['categories']['error']))
    state_count = len(set(results['categories']['state_change']))
    evolution_count = len(set(results['categories']['evolution']))
    
    if error_count > 0:
        print(f"   🚨 {error_count} unique error messages found - check these first!")
    if state_count > 10:
        print(f"   🧠 {state_count} state changes - beings may be too active")
    if evolution_count > 5:
        print(f"   🦋 {evolution_count} evolution attempts - may need further reduction")

if __name__ == "__main__":
    main()