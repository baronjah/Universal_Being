#!/usr/bin/env python3
"""
Data Sender - Sends data to the receiver from any terminal
"""
import socket
import sys
import json
import os

# Configuration - must match receiver
HOST = '127.0.0.1'  # The server's hostname or IP address
PORT = 5555        # The port used by the server

def send_text_data(text):
    """Send text data to the receiver"""
    try:
        # Create a socket
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            # Connect to server
            s.connect((HOST, PORT))
            
            # Send data
            s.sendall(text.encode('utf-8'))
            
            # Shutdown send to signal we're done sending
            s.shutdown(socket.SHUT_WR)
            
            # Wait for response
            response = s.recv(1024).decode('utf-8')
            print(f"Server response: {response}")
            
            return True
    except Exception as e:
        print(f"Error sending data: {e}")
        return False

def send_json_data(data_dict):
    """Send JSON data to the receiver"""
    try:
        # Convert to JSON string
        json_str = json.dumps(data_dict)
        
        # Create a socket
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            # Connect to server
            s.connect((HOST, PORT))
            
            # Send data
            s.sendall(json_str.encode('utf-8'))
            
            # Shutdown send to signal we're done sending
            s.shutdown(socket.SHUT_WR)
            
            # Wait for response
            response = s.recv(1024).decode('utf-8')
            print(f"Server response: {response}")
            
            return True
    except Exception as e:
        print(f"Error sending data: {e}")
        return False

def send_file_data(file_path):
    """Send file contents to the receiver"""
    if not os.path.exists(file_path):
        print(f"Error: File not found: {file_path}")
        return False
    
    try:
        # Determine if it's a text or binary file
        is_binary = False
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except UnicodeDecodeError:
            is_binary = True
        
        # Create a socket
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            # Connect to server
            s.connect((HOST, PORT))
            
            # Send data
            if is_binary:
                with open(file_path, 'rb') as f:
                    content = f.read()
                s.sendall(content)
            else:
                s.sendall(content.encode('utf-8'))
            
            # Shutdown send to signal we're done sending
            s.shutdown(socket.SHUT_WR)
            
            # Wait for response
            response = s.recv(1024).decode('utf-8')
            print(f"Server response: {response}")
            
            return True
    except Exception as e:
        print(f"Error sending file: {e}")
        return False

def print_help():
    """Print help information"""
    print("""
Data Sender - Send data to the receiver

Usage:
  python send_data.py text "Your text message here"
  python send_data.py json '{"key": "value", "numbers": [1, 2, 3]}'
  python send_data.py file /path/to/your/file.txt

Options:
  text   - Send a text message
  json   - Send a JSON object (must be valid JSON)
  file   - Send contents of a file
  help   - Show this help message
""")

def main():
    """Main function to parse arguments and send data"""
    if len(sys.argv) < 2:
        print_help()
        return
    
    command = sys.argv[1].lower()
    
    if command == "help":
        print_help()
    
    elif command == "text":
        if len(sys.argv) < 3:
            print("Error: No text provided")
            print("Usage: python send_data.py text \"Your text message here\"")
            return
        
        text = sys.argv[2]
        print(f"Sending text: {text[:50]}..." if len(text) > 50 else f"Sending text: {text}")
        send_text_data(text)
    
    elif command == "json":
        if len(sys.argv) < 3:
            print("Error: No JSON provided")
            print("Usage: python send_data.py json '{\"key\": \"value\"}'")
            return
        
        try:
            data = json.loads(sys.argv[2])
            print(f"Sending JSON data: {str(data)[:50]}..." if len(str(data)) > 50 else f"Sending JSON data: {str(data)}")
            send_json_data(data)
        except json.JSONDecodeError as e:
            print(f"Error: Invalid JSON: {e}")
    
    elif command == "file":
        if len(sys.argv) < 3:
            print("Error: No file path provided")
            print("Usage: python send_data.py file /path/to/your/file.txt")
            return
        
        file_path = sys.argv[2]
        print(f"Sending file: {file_path}")
        send_file_data(file_path)
    
    else:
        print(f"Unknown command: {command}")
        print_help()

if __name__ == "__main__":
    main()