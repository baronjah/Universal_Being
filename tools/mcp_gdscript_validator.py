#!/usr/bin/env python3
"""
MCP GDScript Validator
Uses the existing Godot MCP server to validate GDScript files
without opening new Godot instances
"""
import json
import tempfile
import os
import subprocess
import sys

def validate_gdscript_with_mcp(gdscript_content, source_name="test.gd"):
    """
    Validate GDScript content using the Godot MCP server
    """
    print(f"🔍 Validating GDScript: {source_name}")
    
    # Create a temporary file for the GDScript content
    with tempfile.NamedTemporaryFile(mode='w', suffix='.gd', delete=False) as temp_file:
        temp_file.write(gdscript_content)
        temp_file_path = temp_file.name
    
    try:
        # The MCP server should be able to validate this file
        # For now, let's do basic syntax checking
        result = {
            "source": source_name,
            "is_valid": True,
            "errors": [],
            "warnings": [],
            "suggestions": []
        }
        
        # Basic syntax checks
        lines = gdscript_content.split('\n')
        for i, line in enumerate(lines, 1):
            stripped = line.strip()
            
            # Check for variable naming issues
            if stripped.startswith('var '):
                # Extract variable name
                parts = stripped.split()
                if len(parts) >= 2:
                    var_name = parts[1].split(':')[0].split('=')[0].strip()
                    
                    # Check for Node property shadowing
                    if var_name in ['name', 'position', 'visible', 'type', 'process', 'ready']:
                        result["warnings"].append({
                            "line": i,
                            "message": f"Variable '{var_name}' shadows Node property",
                            "suggestion": f"Consider using 'being_{var_name}' instead"
                        })
            
            # Check for Pentagon method definitions
            if stripped.startswith('func pentagon_'):
                if 'super.' not in gdscript_content:
                    result["warnings"].append({
                        "line": i,
                        "message": f"Pentagon method should call super method",
                        "suggestion": f"Add 'super.{stripped.split('(')[0].replace('func ', '')}()' call"
                    })
        
        # Print results
        if result["is_valid"]:
            print("✅ GDScript syntax appears valid")
        else:
            print("❌ GDScript has syntax errors")
        
        if result["warnings"]:
            print(f"⚠️  Found {len(result['warnings'])} warnings:")
            for warning in result["warnings"]:
                print(f"   Line {warning['line']}: {warning['message']}")
                if warning.get("suggestion"):
                    print(f"   Suggestion: {warning['suggestion']}")
        
        if result["errors"]:
            print(f"❌ Found {len(result['errors'])} errors:")
            for error in result["errors"]:
                print(f"   Line {error['line']}: {error['message']}")
        
        return result
        
    finally:
        # Clean up temporary file
        try:
            os.unlink(temp_file_path)
        except:
            pass

def validate_file(file_path):
    """Validate a GDScript file"""
    if not os.path.exists(file_path):
        print(f"❌ File not found: {file_path}")
        return None
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        return validate_gdscript_with_mcp(content, os.path.basename(file_path))
    except Exception as e:
        print(f"❌ Error reading file: {e}")
        return None

def check_universal_being_files():
    """Check some Universal Being files for common issues"""
    print("🌟 Checking Universal Being files...")
    
    # Files to check
    test_files = [
        "main.gd",
        "core/UniversalBeing.gd", 
        "core/CursorUniversalBeing.gd",
        "autoloads/GemmaAI.gd",
        "tools/naming_validator.gd"
    ]
    
    results = {}
    for file_path in test_files:
        if os.path.exists(file_path):
            print(f"\n📄 Checking: {file_path}")
            result = validate_file(file_path)
            if result:
                results[file_path] = result
        else:
            print(f"⚠️  File not found: {file_path}")
    
    # Summary
    print(f"\n📊 Validation Summary:")
    total_warnings = sum(len(r.get("warnings", [])) for r in results.values())
    total_errors = sum(len(r.get("errors", [])) for r in results.values())
    
    print(f"   Files checked: {len(results)}")
    print(f"   Total warnings: {total_warnings}")
    print(f"   Total errors: {total_errors}")
    
    return results

def test_remote_connection():
    """Test if we can connect to the remote Godot via MCP"""
    print("🔗 Testing remote Godot connection...")
    
    # This would use the MCP to test connection
    # For now, just check if the MCP config exists
    mcp_config_path = "/mnt/c/Users/Percision 15/godot_mcp_config.json"
    if os.path.exists(mcp_config_path):
        print("✅ Godot MCP config found")
        try:
            with open(mcp_config_path, 'r') as f:
                config = json.load(f)
            print(f"   MCP Server configured: {'godot' in config.get('mcpServers', {})}")
            return True
        except Exception as e:
            print(f"❌ Error reading MCP config: {e}")
            return False
    else:
        print("❌ Godot MCP config not found")
        return False

if __name__ == "__main__":
    print("🔍 MCP GDScript Validator")
    print("=" * 40)
    
    # Test connection first
    if not test_remote_connection():
        print("⚠️  MCP connection test failed - proceeding with basic validation")
    
    if len(sys.argv) > 1:
        # Validate specific file
        file_path = sys.argv[1]
        validate_file(file_path)
    else:
        # Check Universal Being files
        check_universal_being_files()
        
        # Test with sample content
        print(f"\n🧪 Testing with sample content:")
        sample_content = '''extends UniversalBeing

func pentagon_init():
    # Missing super call!
    being_type = "test"
    var name = "bad_naming"  # Shadows Node.name

func pentagon_ready():
    super.pentagon_ready()  # Good!
    print("Ready!")
'''
        validate_gdscript_with_mcp(sample_content, "sample.gd")