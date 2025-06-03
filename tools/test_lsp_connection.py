#!/usr/bin/env python3
"""
Test connection to Godot GDScript Language Server
Language Server Protocol (LSP) communication test
"""
import socket
import json
import time

def test_lsp_connection(host="127.0.0.1", port=6005):
    """Test LSP connection to Godot GDScript Language Server"""
    print(f"🔍 Testing LSP connection to {host}:{port}")
    
    try:
        # Create socket connection
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(5.0)
        
        print(f"🔗 Attempting to connect to {host}:{port}...")
        sock.connect((host, port))
        print(f"✅ Connected to GDScript Language Server!")
        
        # Send LSP initialize request
        initialize_request = {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params": {
                "processId": None,
                "rootUri": f"file:///mnt/c/Users/Percision 15/Universal_Being",
                "capabilities": {
                    "textDocument": {
                        "synchronization": {"dynamicRegistration": True},
                        "completion": {"dynamicRegistration": True},
                        "hover": {"dynamicRegistration": True},
                        "signatureHelp": {"dynamicRegistration": True},
                        "references": {"dynamicRegistration": True},
                        "documentHighlight": {"dynamicRegistration": True},
                        "documentSymbol": {"dynamicRegistration": True},
                        "formatting": {"dynamicRegistration": True},
                        "rangeFormatting": {"dynamicRegistration": True},
                        "onTypeFormatting": {"dynamicRegistration": True},
                        "definition": {"dynamicRegistration": True},
                        "codeAction": {"dynamicRegistration": True},
                        "codeLens": {"dynamicRegistration": True},
                        "documentLink": {"dynamicRegistration": True},
                        "rename": {"dynamicRegistration": True}
                    },
                    "workspace": {
                        "applyEdit": True,
                        "workspaceEdit": {
                            "documentChanges": True
                        },
                        "didChangeConfiguration": {
                            "dynamicRegistration": True
                        },
                        "didChangeWatchedFiles": {
                            "dynamicRegistration": True
                        },
                        "symbol": {
                            "dynamicRegistration": True
                        },
                        "executeCommand": {
                            "dynamicRegistration": True
                        }
                    }
                }
            }
        }
        
        # Format as LSP message
        message = json.dumps(initialize_request)
        content_length = len(message.encode('utf-8'))
        lsp_message = f"Content-Length: {content_length}\r\n\r\n{message}"
        
        print(f"📤 Sending LSP initialize request...")
        sock.send(lsp_message.encode('utf-8'))
        
        # Try to receive response
        print(f"📥 Waiting for LSP response...")
        response = sock.recv(4096).decode('utf-8')
        
        if response:
            print(f"✅ Received LSP response:")
            print(response[:500] + "..." if len(response) > 500 else response)
            return True
        else:
            print(f"❌ No response received")
            return False
            
    except ConnectionRefusedError:
        print(f"❌ Connection refused - Language Server not accessible from WSL")
        return False
    except socket.timeout:
        print(f"❌ Connection timeout - Language Server not responding")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False
    finally:
        try:
            sock.close()
        except:
            pass

def test_debug_adapter(host="127.0.0.1", port=6006):
    """Test connection to Godot Debug Adapter"""
    print(f"\n🔍 Testing Debug Adapter connection to {host}:{port}")
    
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(5.0)
        
        print(f"🔗 Attempting to connect to {host}:{port}...")
        sock.connect((host, port))
        print(f"✅ Connected to Debug Adapter!")
        
        # Send basic debug adapter request
        da_request = {
            "seq": 1,
            "type": "request",
            "command": "initialize",
            "arguments": {
                "clientID": "claude-code",
                "clientName": "Claude Code Remote Debug",
                "adapterID": "godot",
                "pathFormat": "path",
                "linesStartAt1": True,
                "columnsStartAt1": True,
                "supportsVariableType": True,
                "supportsVariablePaging": True,
                "supportsRunInTerminalRequest": True
            }
        }
        
        message = json.dumps(da_request) + "\n"
        print(f"📤 Sending Debug Adapter initialize...")
        sock.send(message.encode('utf-8'))
        
        print(f"📥 Waiting for Debug Adapter response...")
        response = sock.recv(4096).decode('utf-8')
        
        if response:
            print(f"✅ Debug Adapter response:")
            print(response[:300] + "..." if len(response) > 300 else response)
            return True
        else:
            print(f"❌ No response from Debug Adapter")
            return False
            
    except ConnectionRefusedError:
        print(f"❌ Debug Adapter not accessible from WSL")
        return False
    except Exception as e:
        print(f"❌ Debug Adapter error: {e}")
        return False
    finally:
        try:
            sock.close()
        except:
            pass

if __name__ == "__main__":
    print("🌐 Testing Godot Remote Development Connections")
    print("=" * 50)
    
    # Test Language Server
    lsp_success = test_lsp_connection()
    
    # Test Debug Adapter
    da_success = test_debug_adapter()
    
    print(f"\n📊 Connection Test Results:")
    print(f"🔤 GDScript Language Server (6005): {'✅ Success' if lsp_success else '❌ Failed'}")
    print(f"🐛 Debug Adapter (6006): {'✅ Success' if da_success else '❌ Failed'}")
    
    if lsp_success or da_success:
        print(f"\n🎉 Remote connection to Windows Godot is possible!")
        print(f"🤖 Multi-AI development can be enabled!")
    else:
        print(f"\n⚠️  Direct connection failed - might need port forwarding or different approach")
        print(f"💡 Possible solutions:")
        print(f"   - Enable Windows port forwarding to WSL")
        print(f"   - Use Windows host IP instead of 127.0.0.1")
        print(f"   - Configure Windows firewall to allow connections")