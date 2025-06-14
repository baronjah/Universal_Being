#!/usr/bin/env python3
"""
Sample Python code for testing Claude's code analysis tools
"""

def hello_world():
    """Simple function to test code reading - UPDATED"""
    print("Hello, World! - MultiEdit Test")
    return "success"

def calculate_sum(a, b):
    """Function to test grep functionality"""
    result = a + b
    return result

class TestClass:
    """Test class for structure analysis"""
    
    def __init__(self, name):
        self.name = name
    
    def get_name(self):
        return self.name

# Added comment via MultiEdit
if __name__ == "__main__":
    test = TestClass("Claude Testing")
    print(f"Class name: {test.get_name()}")
    hello_world()
    print(f"Sum: {calculate_sum(10, 20)}")