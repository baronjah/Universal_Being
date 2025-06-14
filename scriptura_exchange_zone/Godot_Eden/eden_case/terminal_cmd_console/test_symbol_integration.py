#!/usr/bin/env python3
"""
Test Script for Symbol-Reason System and Auto-Repeat Connector Integration
-------------------------------------------------------------------------

This script demonstrates the integration between the symbol_reason_system.py and 
auto_repeat_connector.py modules, showing how they work together to provide:
- Symbol creation and verification
- Hashtag-based command processing
- Auto-acceptance of commands based on symbol verification
- Connection between symbols and reasons
- Visualization of symbols and connections
- Claude file monitoring with symbol hashtags
- Interaction during different turns in the twelve turns system
- Low-resource operation
"""

import os
import time
import json
import threading
from typing import Dict, List, Any, Tuple, Optional

# Import the necessary components from both systems
from symbol_reason_system import (
    Symbol, Reason, SymbolConnection, SymbolReasonSystem,
    SymbolType, ReasonType, AttentionLevel, SymbolVerificationResult,
    ProcessingMode, create_symbol_system
)

from auto_repeat_connector import (
    AutoRepeatConnector, CommandRepeat, ClaudeFileMonitor, 
    WordTracker, TodoItem, CONFIG
)

# Test configuration
TEST_CONFIG = {
    "symbol_data_file": "test_symbols.json",
    "temp_claude_file": "temp_claude_test.md",
    "test_duration": 10,  # seconds
    "run_claude_file_test": True,
    "run_low_resource_test": True,
    "demonstrate_turns": True,
    "show_visualizations": True
}

def print_section(title):
    """Print a section header for better readability"""
    print("\n" + "="*80)
    print(f" {title} ".center(80, "="))
    print("="*80)

def create_test_file(path: str, content: str) -> None:
    """Create a test file with given content"""
    with open(path, 'w') as f:
        f.write(content)
    print(f"Created test file: {path}")

def cleanup_test_files() -> None:
    """Clean up test files created during testing"""
    for file_path in [TEST_CONFIG["symbol_data_file"], TEST_CONFIG["temp_claude_file"]]:
        if os.path.exists(file_path):
            os.remove(file_path)
            print(f"Removed test file: {file_path}")

class TestOutput:
    """Helper class to capture and format test output"""
    
    def __init__(self):
        self.results = []
        
    def add_result(self, test_name: str, passed: bool, message: str = "") -> None:
        """Add a test result"""
        status = "PASSED" if passed else "FAILED"
        self.results.append({
            "test": test_name,
            "status": status,
            "message": message
        })
        
        # Print immediately for debugging
        print(f"[{status}] {test_name}")
        if message:
            print(f"  {message}")
            
    def print_summary(self) -> None:
        """Print a summary of test results"""
        print_section("Test Summary")
        
        passed = sum(1 for r in self.results if r["status"] == "PASSED")
        failed = sum(1 for r in self.results if r["status"] == "FAILED")
        
        print(f"Total tests: {len(self.results)}")
        print(f"Passed: {passed}")
        print(f"Failed: {failed}")
        
        if failed > 0:
            print("\nFailed tests:")
            for result in self.results:
                if result["status"] == "FAILED":
                    print(f"- {result['test']}: {result['message']}")

def test_symbol_creation_and_verification(symbol_system: SymbolReasonSystem, test_output: TestOutput) -> None:
    """Test the creation and verification of symbols"""
    print_section("1. Symbol Creation and Verification")
    
    # Create a test visual symbol
    visual_symbol = symbol_system.create_symbol(
        symbol_id="test_visual",
        symbol_type=SymbolType.VISUAL,
        value="Test Visual Symbol",
        attention_level=AttentionLevel.HIGH,
        hashtags=["#visual", "#test"]
    )
    print(f"Created visual symbol: {visual_symbol.id} = {visual_symbol.value}")
    
    # Create a test textual symbol
    textual_symbol = symbol_system.create_symbol(
        symbol_id="test_textual",
        symbol_type=SymbolType.TEXTUAL,
        value="Test Textual Symbol",
        attention_level=AttentionLevel.MEDIUM,
        hashtags=["#textual", "#test"]
    )
    print(f"Created textual symbol: {textual_symbol.id} = {textual_symbol.value}")
    
    # Create a test conceptual symbol
    conceptual_symbol = symbol_system.create_symbol(
        symbol_id="test_conceptual",
        symbol_type=SymbolType.CONCEPTUAL,
        value="Test Conceptual Symbol",
        attention_level=AttentionLevel.LOW,
        hashtags=["#conceptual", "#test"]
    )
    print(f"Created conceptual symbol: {conceptual_symbol.id} = {conceptual_symbol.value}")
    
    # Verify symbols
    all_verified = all([
        visual_symbol.verify(),
        textual_symbol.verify(),
        conceptual_symbol.verify()
    ])
    
    message = "All symbols verified successfully" if all_verified else "Symbol verification failed"
    test_output.add_result("Symbol Creation and Verification", all_verified, message)
    
    # Add reasons to symbols
    reason1 = symbol_system.add_reason_to_symbol(
        symbol_id="test_visual",
        reason_id="reason1",
        reason_type=ReasonType.FUNCTIONAL,
        description="This symbol represents visual perception"
    )
    
    reason2 = symbol_system.add_reason_to_symbol(
        symbol_id="test_textual",
        reason_id="reason2",
        reason_type=ReasonType.SEMANTIC,
        description="This symbol represents textual meaning"
    )
    
    reason3 = symbol_system.add_reason_to_symbol(
        symbol_id="test_conceptual",
        reason_id="reason3",
        reason_type=ReasonType.RELATIONAL,
        description="This symbol represents conceptual relationships"
    )
    
    # Connect symbols
    connection1 = symbol_system.connect_symbols(
        source_id="test_visual",
        target_id="test_textual",
        connection_id="conn1",
        relationship_type="visualizes"
    )
    
    connection2 = symbol_system.connect_symbols(
        source_id="test_textual",
        target_id="test_conceptual",
        connection_id="conn2",
        relationship_type="describes"
    )
    
    connection3 = symbol_system.connect_symbols(
        source_id="test_conceptual",
        target_id="test_visual",
        connection_id="conn3",
        relationship_type="manifests"
    )
    
    # Check if reasons and connections are created
    reasons_created = reason1 is not None and reason2 is not None and reason3 is not None
    connections_created = connection1 is not None and connection2 is not None and connection3 is not None
    
    message = "All reasons and connections created successfully" if reasons_created and connections_created else "Failed to create reasons or connections"
    test_output.add_result("Reason and Connection Creation", reasons_created and connections_created, message)

def test_hashtag_command_processing(symbol_system: SymbolReasonSystem, test_output: TestOutput) -> None:
    """Test hashtag-based command processing with symbols"""
    print_section("2. Hashtag Command Processing")
    
    # Test different hashtag commands
    commands = [
        "#symbol get test_visual",
        "#symbol list visual",
        "#reason list test_visual",
        "#connect test_visual test_conceptual direct",
        "#visualize text"
    ]
    
    # Process each command and check results
    results = []
    for command in commands:
        print(f"\nExecuting command: {command}")
        success, response = symbol_system.process_command(command)
        print(f"Response: {response}")
        results.append(success)
    
    all_processed = all(results)
    message = "All hashtag commands processed successfully" if all_processed else "Some hashtag commands failed"
    test_output.add_result("Hashtag Command Processing", all_processed, message)
    
    # Test finding symbols by hashtag
    visual_symbols = symbol_system.find_symbols_by_hashtag("#visual")
    test_symbols = symbol_system.find_symbols_by_hashtag("#test")
    
    hashtag_search_works = len(visual_symbols) > 0 and len(test_symbols) > 0
    message = f"Found {len(visual_symbols)} symbols with #visual hashtag and {len(test_symbols)} with #test hashtag"
    test_output.add_result("Symbol Hashtag Search", hashtag_search_works, message)

def test_auto_acceptance(symbol_system: SymbolReasonSystem, connector: AutoRepeatConnector, test_output: TestOutput) -> None:
    """Test auto-acceptance of commands based on symbol verification"""
    print_section("3. Auto-Acceptance of Commands")
    
    # Test command verification with symbols
    command = "Execute test command with #visual"
    symbols = ["test_visual", "test_textual"]
    
    verification_result = symbol_system.verify_command(command, symbols)
    print(f"Command: '{command}'")
    print(f"Verified with symbols: {', '.join(symbols)}")
    print(f"Verification result: {verification_result.value}")
    
    verification_works = verification_result == SymbolVerificationResult.VERIFIED
    test_output.add_result("Command Verification", verification_works, f"Result: {verification_result.value}")
    
    # Add a repeat command with auto-acceptance
    cmd_id = connector.add_repeat_command(command, repeat_count=1, interval=1.0)
    print(f"Added repeat command with ID: {cmd_id}")
    
    # Check if command was added with correct verification status
    if cmd_id in connector.commands:
        cmd = connector.commands[cmd_id]
        cmd_verified = cmd.verification_status == SymbolVerificationResult.VERIFIED
        message = f"Command verification status: {cmd.verification_status.value if cmd.verification_status else 'None'}"
        test_output.add_result("Auto-Repeat Command Verification", cmd_verified, message)
    else:
        test_output.add_result("Auto-Repeat Command Addition", False, "Command was not added to connector")

def test_symbol_reason_connection(symbol_system: SymbolReasonSystem, test_output: TestOutput) -> None:
    """Test the connection between symbols and reasons"""
    print_section("4. Symbol-Reason Connection")
    
    # Check if symbols have associated reasons
    visual_symbol = symbol_system.symbols.get("test_visual")
    textual_symbol = symbol_system.symbols.get("test_textual")
    conceptual_symbol = symbol_system.symbols.get("test_conceptual")
    
    if not all([visual_symbol, textual_symbol, conceptual_symbol]):
        test_output.add_result("Symbol-Reason Access", False, "Could not access one or more symbols")
        return
    
    # Print the reasons associated with each symbol
    print("Visual Symbol Reasons:")
    for reason in visual_symbol.reasons:
        print(f"- {reason.type.value}: {reason.description}")
    
    print("\nTextual Symbol Reasons:")
    for reason in textual_symbol.reasons:
        print(f"- {reason.type.value}: {reason.description}")
    
    print("\nConceptual Symbol Reasons:")
    for reason in conceptual_symbol.reasons:
        print(f"- {reason.type.value}: {reason.description}")
    
    # Check if reasons are correctly associated
    reasons_connected = (
        len(visual_symbol.reasons) > 0 and
        len(textual_symbol.reasons) > 0 and
        len(conceptual_symbol.reasons) > 0
    )
    
    message = "All symbols have associated reasons" if reasons_connected else "Some symbols are missing reasons"
    test_output.add_result("Symbol-Reason Connection", reasons_connected, message)
    
    # Test symbol connections
    print("\nSymbol Connections:")
    for conn_id, connection in symbol_system.connections.items():
        print(f"- {connection.source.id} --{connection.relationship_type}--> {connection.target.id}")
    
    connections_exist = len(symbol_system.connections) > 0
    test_output.add_result("Symbol Connections", connections_exist, f"Found {len(symbol_system.connections)} connections")

def test_symbol_visualization(symbol_system: SymbolReasonSystem, test_output: TestOutput) -> None:
    """Test visualization of symbols and connections"""
    if not TEST_CONFIG["show_visualizations"]:
        print("Symbol visualization test skipped due to configuration")
        return
        
    print_section("5. Symbol and Connection Visualization")
    
    # Generate text visualization
    text_viz = symbol_system.visualize_symbols("text")
    print("Text Visualization:")
    print(text_viz)
    
    # Generate HTML visualization and save to file
    html_viz = symbol_system.visualize_symbols("html")
    html_file = "symbol_visualization.html"
    
    with open(html_file, "w") as f:
        f.write(html_viz)
    
    print(f"\nHTML visualization saved to: {html_file}")
    
    # Generate JSON visualization and save to file
    json_viz = symbol_system.visualize_symbols("json")
    json_file = "symbol_visualization.json"
    
    with open(json_file, "w") as f:
        f.write(json_viz)
    
    print(f"JSON visualization saved to: {json_file}")
    
    # Check if visualizations were generated successfully
    visualizations_work = len(text_viz) > 0 and len(html_viz) > 0 and len(json_viz) > 0
    message = "All visualization formats generated successfully"
    test_output.add_result("Symbol Visualization", visualizations_work, message)

def test_claude_file_monitoring(connector: AutoRepeatConnector, test_output: TestOutput) -> None:
    """Test Claude file monitoring with symbol hashtags"""
    if not TEST_CONFIG["run_claude_file_test"]:
        print("Claude file monitoring test skipped due to configuration")
        return
        
    print_section("6. Claude File Monitoring with Symbol Hashtags")
    
    # Create a temporary test file
    test_content = """
    # Test Claude File for Symbol Integration
    
    This is a test file for monitoring with symbol hashtags.
    
    - Test with #visual hashtag
    - Test with #textual hashtag
    - Test with #conceptual hashtag
    - Test with #test hashtag
    
    ## Symbol Commands
    
    #symbol create test_monitor:visual "Symbol from monitored file"
    #reason add test_monitor functional "Created from monitored file"
    
    ## Todo Items
    
    TODO: Implement more symbol monitoring tests #visual
    TODO: Test symbol verification in real-time #test
    """
    
    create_test_file(TEST_CONFIG["temp_claude_file"], test_content)
    
    # Add the test file to the monitored files
    original_files = connector.file_monitor.file_paths
    connector.file_monitor.file_paths = original_files + [TEST_CONFIG["temp_claude_file"]]
    
    # Wait a moment for the file monitor to initialize
    time.sleep(1)
    
    # Check for changes
    changed_files = connector.file_monitor.check_for_changes()
    print(f"Changed files detected: {changed_files}")
    
    # Get hashtags found in monitored files
    hashtags = connector.file_monitor.get_symbol_hashtags()
    print("Hashtags found in monitored files:")
    for tag in hashtags:
        print(f"- {tag}")
    
    # Check if hashtags were detected
    hashtags_found = len(hashtags) > 0
    message = f"Found {len(hashtags)} hashtags in monitored files"
    test_output.add_result("Claude File Hashtag Detection", hashtags_found, message)
    
    # Modify the test file to trigger a change
    modified_content = test_content + "\n\n#symbol create new_test:conceptual 'New test symbol' #new"
    create_test_file(TEST_CONFIG["temp_claude_file"], modified_content)
    
    # Check for changes again
    changed_files = connector.file_monitor.check_for_changes()
    print(f"Changed files after modification: {changed_files}")
    
    # Check if modified hashtags were detected
    hashtags_after = connector.file_monitor.get_symbol_hashtags()
    new_hashtags = hashtags_after - hashtags if isinstance(hashtags, set) else set(hashtags_after) - set(hashtags)
    
    print("New hashtags found after modification:")
    for tag in new_hashtags:
        print(f"- {tag}")
    
    changes_detected = TEST_CONFIG["temp_claude_file"] in changed_files
    message = "File changes detected successfully" if changes_detected else "Failed to detect file changes"
    test_output.add_result("Claude File Change Detection", changes_detected, message)
    
    # Restore original monitored files
    connector.file_monitor.file_paths = original_files

def test_turn_system_interaction(symbol_system: SymbolReasonSystem, connector: AutoRepeatConnector, test_output: TestOutput) -> None:
    """Test interaction during different turns in the twelve turns system"""
    if not TEST_CONFIG["demonstrate_turns"]:
        print("Turn system interaction test skipped due to configuration")
        return
        
    print_section("7. Twelve Turns System Interaction")
    
    # Get initial turn and dimension
    initial_turn = symbol_system.turn_count
    initial_dimension = symbol_system.current_dimension
    
    print(f"Initial state: Turn {initial_turn}, Dimension {initial_dimension}")
    
    # Test advancing turns
    for i in range(3):
        # Process turn command
        success, response = symbol_system.process_command("#turn advance")
        print(f"Turn {symbol_system.turn_count}, Dimension {symbol_system.current_dimension}: {response}")
        
        # Create a turn-specific symbol
        symbol_id = f"turn_{symbol_system.turn_count}_symbol"
        symbol = symbol_system.create_symbol(
            symbol_id=symbol_id,
            symbol_type=SymbolType.CONCEPTUAL,
            value=f"Symbol for Turn {symbol_system.turn_count}",
            metadata={"turn": symbol_system.turn_count, "dimension": symbol_system.current_dimension},
            hashtags=[f"#turn{symbol_system.turn_count}"]
        )
        
        print(f"Created symbol for current turn: {symbol.id} = {symbol.value}")
    
    # Test dimension change (advance through all 12 turns)
    dimension_changed = False
    while not dimension_changed and symbol_system.turn_count <= 12:
        success, response = symbol_system.process_command("#turn advance")
        if symbol_system.current_dimension > initial_dimension:
            dimension_changed = True
            break
    
    print(f"Final state: Turn {symbol_system.turn_count}, Dimension {symbol_system.current_dimension}")
    
    # Get symbols for the current dimension
    dimension_symbols = symbol_system.get_dimension_symbols()
    print(f"Found {len(dimension_symbols)} symbols for dimension {symbol_system.current_dimension}")
    
    # Check if turn system interaction works
    turns_advanced = symbol_system.turn_count != initial_turn
    message = f"Turn advanced from {initial_turn} to {symbol_system.turn_count}"
    test_output.add_result("Turn System Advancement", turns_advanced, message)
    
    dimension_test = symbol_system.current_dimension != initial_dimension
    message = f"Dimension changed from {initial_dimension} to {symbol_system.current_dimension}"
    test_output.add_result("Dimension Transition", dimension_test, message)

def test_low_resource_operation(test_output: TestOutput) -> None:
    """Test low-resource operation of both systems"""
    if not TEST_CONFIG["run_low_resource_test"]:
        print("Low-resource operation test skipped due to configuration")
        return
        
    print_section("8. Low-Resource Operation")
    
    # Create a new symbol system in low-resource mode
    lr_symbol_system, lr_connector = create_symbol_system(
        config_path=None, 
        processing_mode="low_resource"
    )
    
    print(f"Created low-resource symbol system with mode: {lr_symbol_system.processing_mode.value}")
    
    # Create some symbols in low-resource mode
    start_time = time.time()
    for i in range(20):
        symbol_id = f"lr_symbol_{i}"
        lr_symbol_system.create_symbol(
            symbol_id=symbol_id,
            symbol_type=SymbolType.TEXTUAL,
            value=f"Low-resource symbol {i}",
            attention_level=AttentionLevel.LOW
        )
    
    # Add some connections
    for i in range(10):
        source_id = f"lr_symbol_{i}"
        target_id = f"lr_symbol_{i+10}"
        lr_symbol_system.connect_symbols(
            source_id=source_id,
            target_id=target_id,
            connection_id=f"lr_conn_{i}",
            relationship_type="follows"
        )
    
    end_time = time.time()
    operation_time = end_time - start_time
    
    print(f"Created 20 symbols and 10 connections in {operation_time:.4f} seconds")
    
    # Test connector initialization in low-resource mode
    CONFIG["low_resource_mode"] = True
    lr_connector = AutoRepeatConnector()
    
    # Test word tracking with minimal memory
    sample_text = "This is a sample text for low-resource word tracking test"
    words = lr_connector.word_tracker.track_words(sample_text)
    
    print(f"Tracked {len(words)} words in low-resource mode")
    
    # Check memory usage if possible
    try:
        import psutil
        process = psutil.Process(os.getpid())
        memory_usage = process.memory_info().rss / (1024 * 1024)  # MB
        print(f"Current memory usage: {memory_usage:.2f} MB")
        memory_test = memory_usage < 100  # Arbitrary threshold for a simple test
    except ImportError:
        print("psutil not available, skipping memory usage check")
        memory_test = True
    
    low_resource_works = lr_symbol_system.processing_mode == ProcessingMode.LOW_RESOURCE
    message = f"Created system in {lr_symbol_system.processing_mode.value} mode"
    test_output.add_result("Low-Resource Mode Initialization", low_resource_works, message)
    
    # Test memory usage if checked
    if 'memory_test' in locals():
        message = f"Memory usage: {memory_usage:.2f} MB"
        test_output.add_result("Low Memory Usage", memory_test, message)

def demonstrate_complete_integration():
    """Demonstrate complete integration between systems"""
    print_section("SYMBOL INTEGRATION TEST")
    print("This test script demonstrates the integration between symbol_reason_system.py")
    print("and auto_repeat_connector.py, showing how they work together.")
    
    # Initialize test output tracker
    test_output = TestOutput()
    
    try:
        # Create the symbol system and connector
        symbol_system, _ = create_symbol_system()
        connector = AutoRepeatConnector()
        
        # Connect the systems
        connector.connect_symbol_system(symbol_system)
        
        # Run the individual tests
        test_symbol_creation_and_verification(symbol_system, test_output)
        test_hashtag_command_processing(symbol_system, test_output)
        test_auto_acceptance(symbol_system, connector, test_output)
        test_symbol_reason_connection(symbol_system, test_output)
        test_symbol_visualization(symbol_system, test_output)
        test_claude_file_monitoring(connector, test_output)
        test_turn_system_interaction(symbol_system, connector, test_output)
        test_low_resource_operation(test_output)
        
        # Save the symbol data for future reference
        symbol_system.save_symbols(TEST_CONFIG["symbol_data_file"])
        print(f"\nSaved symbol data to {TEST_CONFIG['symbol_data_file']}")
        
        # Print overall test summary
        test_output.print_summary()
        
    except Exception as e:
        print(f"Error during test execution: {str(e)}")
        import traceback
        traceback.print_exc()
    finally:
        # Clean up test files
        cleanup_test_files()

if __name__ == "__main__":
    demonstrate_complete_integration()