#!/usr/bin/env python3
"""
Data Receiver - Listens for data from multiple terminals
"""
import socket
import threading
import json
import os
import time
from datetime import datetime

# Configuration
HOST = '127.0.0.1'  # Listen on localhost
PORT = 5555        # Port to listen on
DATA_DIR = 'received_data'  # Directory to store received data

def ensure_data_dir():
    """Create data directory if it doesn't exist"""
    if not os.path.exists(DATA_DIR):
        os.makedirs(DATA_DIR)
        print(f"Created directory: {DATA_DIR}")

def handle_client(client_socket, addr):
    """Handle a client connection"""
    print(f"Connection from {addr}")
    
    try:
        # Receive data
        buffer = b""
        while True:
            data = client_socket.recv(4096)
            if not data:
                break
            buffer += data
            
            # Try to decode as we go (for debugging)
            try:
                message = buffer.decode('utf-8')
                print(f"Received data: {message[:50]}...")
            except UnicodeDecodeError:
                print(f"Received {len(buffer)} bytes of binary data")
        
        # Process the received data
        if buffer:
            # Check if it's JSON
            try:
                data_json = json.loads(buffer.decode('utf-8'))
                # It's valid JSON, so save with timestamp
                timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                filename = f"{DATA_DIR}/data_{timestamp}.json"
                
                with open(filename, 'w', encoding='utf-8') as f:
                    json.dump(data_json, f, indent=2)
                
                print(f"Saved JSON data to {filename}")
                client_socket.send(f"SUCCESS: Data saved to {filename}".encode('utf-8'))
                
            except json.JSONDecodeError:
                # Not JSON, save as raw text or binary
                timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                
                try:
                    # Try to decode as text
                    text_data = buffer.decode('utf-8')
                    filename = f"{DATA_DIR}/text_{timestamp}.txt"
                    
                    with open(filename, 'w', encoding='utf-8') as f:
                        f.write(text_data)
                    
                    print(f"Saved text data to {filename}")
                    client_socket.send(f"SUCCESS: Text data saved to {filename}".encode('utf-8'))
                    
                except UnicodeDecodeError:
                    # Save as binary if text decode fails
                    filename = f"{DATA_DIR}/binary_{timestamp}.bin"
                    
                    with open(filename, 'wb') as f:
                        f.write(buffer)
                    
                    print(f"Saved binary data to {filename}")
                    client_socket.send(f"SUCCESS: Binary data saved to {filename}".encode('utf-8'))
        else:
            client_socket.send(b"ERROR: No data received")
    
    except Exception as e:
        print(f"Error handling client: {e}")
        try:
            client_socket.send(f"ERROR: {str(e)}".encode('utf-8'))
        except:
            pass
    
    finally:
        client_socket.close()
        print(f"Connection closed: {addr}")

def start_server():
    """Start the server to listen for connections"""
    ensure_data_dir()
    
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    
    try:
        server.bind((HOST, PORT))
        server.listen(5)
        print(f"Server listening on {HOST}:{PORT}")
        print(f"Waiting for data... Press Ctrl+C to exit")
        
        while True:
            client, addr = server.accept()
            client_handler = threading.Thread(target=handle_client, args=(client, addr))
            client_handler.daemon = True
            client_handler.start()
            
    except KeyboardInterrupt:
        print("Server shutting down")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        server.close()

if __name__ == "__main__":
    start_server()