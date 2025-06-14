#!/usr/bin/env python3
"""
Akashic Records Server - Two-way communication with Talking Ragdoll Game
Provides HTML interface, tutorial system, and file synchronization
"""

import asyncio
import json
import os
import time
import threading
from pathlib import Path
from datetime import datetime
from http.server import HTTPServer, SimpleHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import websockets
import hashlib

class AkashicServer:
    def __init__(self, http_port=8888, ws_port=8889):
        self.http_port = http_port
        self.ws_port = ws_port
        self.connected_games = {}
        self.tutorial_steps = []
        self.monitored_files = {}
        self.project_states = {}
        
        # Setup directories
        self.data_dir = Path("akashic_data")
        self.data_dir.mkdir(exist_ok=True)
        
        # Load initial data
        self.load_tutorial_steps()
        self.load_monitored_files()
    
    def load_tutorial_steps(self):
        """Load tutorial steps configuration"""
        self.tutorial_steps = [
            {
                "type": "check_system",
                "title": "Check Console System",
                "data": {"system": "ConsoleManager", "check": "autoload"},
                "message": "Verifying console system is loaded..."
            },
            {
                "type": "use_command", 
                "title": "Test Console",
                "data": {"command": "help", "message": "Type 'help' in console (press Tab to open)"},
                "validation": "command_executed"
            },
            {
                "type": "spawn_object",
                "title": "Spawn Test Object", 
                "data": {"object": "box", "x": 2, "y": 1, "z": 0},
                "message": "Spawning test box..."
            },
            {
                "type": "use_command",
                "title": "Test Object Clicking",
                "data": {"command": "list_inspectable", "message": "Type 'list_inspectable' to see clickable objects"},
                "validation": "objects_listed"
            },
            {
                "type": "spawn_object",
                "title": "Create Universal Being",
                "data": {"object": "universal_being", "x": 0, "y": 3, "z": 0},
                "message": "Manifesting Universal Being..."
            },
            {
                "type": "use_command",
                "title": "Transform Universal Being", 
                "data": {"command": "being_transform tree", "message": "Transform the Universal Being into a tree"},
                "validation": "transformation_completed"
            },
            {
                "type": "check_system",
                "title": "Verify Self-Repair System",
                "data": {"system": "SelfRepairSystem", "check": "exists"},
                "message": "Checking self-repair consciousness..."
            },
            {
                "type": "use_command",
                "title": "Complete Tutorial",
                "data": {"command": "repair_status", "message": "Check self-repair system status"},
                "validation": "tutorial_complete"
            }
        ]
    
    def load_monitored_files(self):
        """Load file monitoring configuration"""
        self.monitored_files = {
            "game_rules.txt": {"category": "rules", "auto_sync": True},
            "scene_forest.txt": {"category": "scenes", "auto_sync": True}, 
            "tutorial_steps.txt": {"category": "tutorial", "auto_sync": False},
            "player_progress.txt": {"category": "progress", "auto_sync": True}
        }
    
    async def start_server(self):
        """Start both HTTP and WebSocket servers"""
        print("🌌 Starting Akashic Records Server...")
        
        # Start HTTP server in thread
        http_thread = threading.Thread(target=self.start_http_server, daemon=True)
        http_thread.start()
        
        # Start WebSocket server
        print(f"🔗 WebSocket server starting on port {self.ws_port}")
        await websockets.serve(self.handle_websocket, "localhost", self.ws_port)
        
        print("✅ Akashic Server fully operational!")
        print(f"🌐 HTML Interface: http://localhost:{self.http_port}")
        print(f"🔌 Game Connection: ws://localhost:{self.ws_port}")
        
        # Keep server running
        await asyncio.Future()  # Run forever
    
    def start_http_server(self):
        """Start HTTP server for HTML interface"""
        class AkashicHTTPHandler(SimpleHTTPRequestHandler):
            def __init__(self, *args, server_instance=None, **kwargs):
                self.server_instance = server_instance
                super().__init__(*args, **kwargs)
            
            def do_GET(self):
                parsed_path = urlparse(self.path)
                
                if parsed_path.path == "/":
                    self.serve_main_interface()
                elif parsed_path.path == "/ping":
                    self.serve_ping()
                elif parsed_path.path == "/api/status":
                    self.serve_api_status()
                elif parsed_path.path == "/api/games":
                    self.serve_api_games()
                elif parsed_path.path == "/api/files":
                    self.serve_api_files()
                else:
                    super().do_GET()
            
            def do_POST(self):
                parsed_path = urlparse(self.path)
                
                if parsed_path.path == "/register":
                    self.handle_registration()
                elif parsed_path.path == "/api/tutorial/start":
                    self.handle_tutorial_start()
                elif parsed_path.path == "/api/command":
                    self.handle_command()
                elif parsed_path.path == "/api/file/update":
                    self.handle_file_update()
                else:
                    self.send_error(404, "API endpoint not found")
            
            def serve_main_interface(self):
                """Serve main HTML interface"""
                html_content = self.server_instance.generate_html_interface()
                self.send_response(200)
                self.send_header('Content-type', 'text/html')
                self.end_headers()
                self.wfile.write(html_content.encode())
            
            def serve_ping(self):
                """Serve ping response for connection test"""
                print("🏓 Ping request received - sending pong")
                self.send_response(200)
                self.send_header('Content-type', 'text/plain')
                self.send_header('Content-Length', '4')
                self.end_headers()
                self.wfile.write(b"pong")
                print("✅ Pong sent")
            
            def serve_api_status(self):
                """Serve server status as JSON"""
                status = {
                    "server": "Akashic Records",
                    "connected_games": len(self.server_instance.connected_games),
                    "monitored_files": len(self.server_instance.monitored_files),
                    "tutorial_steps": len(self.server_instance.tutorial_steps),
                    "uptime": time.time() - self.server_instance.start_time if hasattr(self.server_instance, 'start_time') else 0
                }
                self.send_json_response(status)
            
            def serve_api_games(self):
                """Serve connected games info"""
                games_info = []
                for game_id, game_data in self.server_instance.connected_games.items():
                    games_info.append({
                        "id": game_id,
                        "connected_at": game_data.get("connected_at", "unknown"),
                        "project_path": game_data.get("project_path", "unknown"),
                        "last_state": game_data.get("last_state", {})
                    })
                self.send_json_response(games_info)
            
            def serve_api_files(self):
                """Serve monitored files status"""
                files_status = {}
                for filename, config in self.server_instance.monitored_files.items():
                    files_status[filename] = {
                        "category": config["category"],
                        "auto_sync": config["auto_sync"],
                        "exists": os.path.exists(filename),
                        "size": os.path.getsize(filename) if os.path.exists(filename) else 0
                    }
                self.send_json_response(files_status)
            
            def send_json_response(self, data):
                """Send JSON response"""
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps(data, indent=2).encode())
            
            def handle_registration(self):
                """Handle game registration"""
                print("📝 Registration request received")
                content_length = int(self.headers.get('Content-Length', 0))
                post_data = self.rfile.read(content_length)
                print(f"📦 Registration data: {post_data.decode('utf-8')}")
                
                try:
                    data = json.loads(post_data.decode('utf-8'))
                    game_id = data.get('game_id', f'game_{int(time.time())}')
                    
                    # Store game data
                    self.server_instance.connected_games[game_id] = {
                        'registered_at': datetime.now().isoformat(),
                        'project_path': data.get('project_path', 'unknown'),
                        'capabilities': data.get('capabilities', [])
                    }
                    
                    print(f"🎮 Game registered: {game_id}")
                    
                    response = {
                        'status': 'success',
                        'game_id': game_id,
                        'message': 'Successfully registered with Akashic server'
                    }
                    print(f"📤 Sending response: {json.dumps(response)}")
                    self.send_json_response(response)
                except Exception as e:
                    print(f"❌ Registration failed: {e}")
                    self.send_json_response({
                        'status': 'error',
                        'message': str(e)
                    })
            
            def handle_command(self):
                """Handle command to relay to games"""
                print("🎮 Command relay request received")
                content_length = int(self.headers.get('Content-Length', 0))
                post_data = self.rfile.read(content_length)
                
                try:
                    data = json.loads(post_data.decode('utf-8'))
                    command = data.get('command', '')
                    target = data.get('target', 'all_games')
                    
                    print(f"📡 Relaying command to games: {command}")
                    
                    # Send to all connected games via WebSocket
                    import asyncio
                    loop = asyncio.new_event_loop()
                    asyncio.set_event_loop(loop)
                    
                    sent_count = 0
                    for game_id, game_data in self.server_instance.connected_games.items():
                        if 'websocket' in game_data:
                            ws = game_data['websocket']
                            message = {
                                "command": "execute_console_command",
                                "console_command": command
                            }
                            try:
                                loop.run_until_complete(ws.send(json.dumps(message)))
                                sent_count += 1
                                print(f"✅ Sent command to {game_id}")
                            except Exception as e:
                                print(f"❌ Failed to send to {game_id}: {e}")
                    
                    self.send_json_response({
                        'success': True,
                        'sent_to': sent_count,
                        'message': f'Command sent to {sent_count} game(s)'
                    })
                    
                except Exception as e:
                    print(f"❌ Command relay failed: {e}")
                    self.send_json_response({
                        'success': False,
                        'message': str(e)
                    })
            
            def handle_tutorial_start(self):
                """Handle tutorial start request"""
                # Placeholder for tutorial start
                self.send_json_response({'status': 'not_implemented'})
            
            def handle_file_update(self):
                """Handle file update request"""
                # Placeholder for file update
                self.send_json_response({'status': 'not_implemented'})
        
        def handler(*args, **kwargs):
            return AkashicHTTPHandler(*args, server_instance=self, **kwargs)
        
        httpd = HTTPServer(("localhost", self.http_port), handler)
        print(f"🌐 HTTP server starting on port {self.http_port}")
        httpd.serve_forever()
    
    async def handle_websocket(self, websocket):
        """Handle WebSocket connections from game"""
        game_id = f"game_{int(time.time())}"
        self.connected_games[game_id] = {
            "websocket": websocket,
            "connected_at": datetime.now().isoformat(),
            "last_state": {}
        }
        
        print(f"🎮 Game connected via WebSocket: {game_id}")
        
        try:
            async for message in websocket:
                await self.handle_game_message(game_id, message)
        except websockets.exceptions.ConnectionClosed:
            print(f"🎮 Game disconnected: {game_id}")
        finally:
            if game_id in self.connected_games:
                del self.connected_games[game_id]
    
    async def handle_game_message(self, game_id, message):
        """Handle message from game"""
        try:
            data = json.loads(message)
            command = data.get("command", "")
            
            print(f"📨 From {game_id}: {command}")
            
            if command == "project_state_update":
                self.connected_games[game_id]["last_state"] = data.get("state", {})
            
            elif command == "request_tutorial":
                await self.send_tutorial_to_game(game_id)
            
            elif command == "tutorial_step_completed":
                await self.handle_tutorial_step_completed(game_id, data)
            
            elif command == "file_changed":
                await self.handle_file_change_from_game(game_id, data)
            
        except json.JSONDecodeError:
            print(f"❌ Invalid JSON from {game_id}")
        except Exception as e:
            print(f"❌ Error handling message from {game_id}: {e}")
    
    async def send_tutorial_to_game(self, game_id):
        """Send tutorial steps to game"""
        if game_id in self.connected_games:
            message = {
                "command": "tutorial_start",
                "steps": self.tutorial_steps
            }
            await self.connected_games[game_id]["websocket"].send(json.dumps(message))
            print(f"📚 Sent tutorial to {game_id}")
    
    async def handle_tutorial_step_completed(self, game_id, data):
        """Handle tutorial step completion"""
        step = data.get("step", 0)
        print(f"✅ {game_id} completed tutorial step {step + 1}")
        
        # Log progress
        progress_file = self.data_dir / f"{game_id}_progress.json"
        progress = {"completed_steps": step + 1, "timestamp": datetime.now().isoformat()}
        with open(progress_file, 'w') as f:
            json.dump(progress, f, indent=2)
    
    async def handle_file_change_from_game(self, game_id, data):
        """Handle file change notification from game"""
        file_path = data.get("file_path", "")
        content = data.get("content", "")
        
        print(f"📁 {game_id} reports file change: {file_path}")
        
        # Save file locally for analysis
        local_path = self.data_dir / f"{game_id}_{Path(file_path).name}"
        with open(local_path, 'w') as f:
            f.write(content)
    
    def generate_html_interface(self):
        """Generate HTML interface for Akashic Records"""
        return f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🌌 Akashic Records - Talking Ragdoll Game</title>
    <style>
        body {{
            background: linear-gradient(135deg, #0c0c1e 0%, #1a1a3a 100%);
            color: #e0e0f0;
            font-family: 'Courier New', monospace;
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }}
        .container {{
            max-width: 1200px;
            margin: 0 auto;
        }}
        .header {{
            text-align: center;
            margin-bottom: 30px;
            padding: 20px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
        }}
        .header h1 {{
            margin: 0;
            font-size: 2.5em;
            background: linear-gradient(45deg, #FFD700, #FFA500);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
        }}
        .panel {{
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }}
        .panel h2 {{
            color: #FFD700;
            margin-top: 0;
        }}
        .status-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }}
        .status-item {{
            padding: 15px;
            background: rgba(0, 255, 100, 0.1);
            border-radius: 8px;
            border-left: 4px solid #00ff64;
        }}
        .status-item.warning {{
            background: rgba(255, 165, 0, 0.1);
            border-left-color: #FFA500;
        }}
        .status-item.error {{
            background: rgba(255, 0, 0, 0.1);
            border-left-color: #ff0000;
        }}
        .console {{
            background: #000;
            color: #00ff00;
            padding: 15px;
            border-radius: 8px;
            font-family: 'Courier New', monospace;
            height: 200px;
            overflow-y: auto;
            margin: 10px 0;
            border: 2px solid #00ff00;
        }}
        .button {{
            background: linear-gradient(45deg, #4a90e2, #357abd);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            margin: 5px;
            font-family: inherit;
            transition: all 0.3s ease;
        }}
        .button:hover {{
            background: linear-gradient(45deg, #357abd, #2968a3);
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
        }}
        .button.primary {{
            background: linear-gradient(45deg, #FFD700, #FFA500);
            color: #000;
        }}
        .button.danger {{
            background: linear-gradient(45deg, #ff4757, #c44569);
        }}
        .input-group {{
            margin: 10px 0;
        }}
        .input-group input {{
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.3);
            padding: 8px 12px;
            border-radius: 4px;
            color: #e0e0f0;
            width: 200px;
        }}
        .file-list {{
            max-height: 300px;
            overflow-y: auto;
        }}
        .file-item {{
            padding: 8px;
            margin: 4px 0;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 4px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }}
        .connection-indicator {{
            display: inline-block;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            margin-right: 8px;
        }}
        .connected {{ background: #00ff64; }}
        .disconnected {{ background: #ff4757; }}
        .tutorial-step {{
            padding: 10px;
            margin: 8px 0;
            background: rgba(255, 215, 0, 0.1);
            border-left: 4px solid #FFD700;
            border-radius: 4px;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🌌 Akashic Records</h1>
            <p>Two-way communication bridge for Talking Ragdoll Game</p>
            <div>
                <span class="connection-indicator" id="connection-status"></span>
                <span id="connection-text">Checking connection...</span>
            </div>
        </div>

        <div class="status-grid">
            <div class="panel">
                <h2>🎮 Connected Games</h2>
                <div id="games-list">Loading...</div>
            </div>

            <div class="panel">
                <h2>📊 Server Status</h2>
                <div id="server-status">Loading...</div>
            </div>
        </div>

        <div class="panel">
            <h2>📚 Tutorial System</h2>
            <p>Interactive tutorial with {len(self.tutorial_steps)} steps</p>
            <button class="button primary" onclick="startTutorial()">🚀 Start Tutorial</button>
            <button class="button" onclick="resetTutorial()">🔄 Reset Progress</button>
            
            <div id="tutorial-steps">
                <h3>Tutorial Steps:</h3>
                <div class="tutorial-step">1. ✅ Check Console System</div>
                <div class="tutorial-step">2. 🎮 Test Console Commands</div>
                <div class="tutorial-step">3. 📦 Spawn Test Objects</div>
                <div class="tutorial-step">4. 🔍 Test Object Interaction</div>
                <div class="tutorial-step">5. ⭐ Create Universal Being</div>
                <div class="tutorial-step">6. 🌳 Transform Universal Being</div>
                <div class="tutorial-step">7. 🔧 Verify Self-Repair System</div>
                <div class="tutorial-step">8. 🎉 Complete Tutorial</div>
            </div>
        </div>

        <div class="panel">
            <h2>📁 File Synchronization</h2>
            <div id="files-list">Loading...</div>
            <div class="input-group">
                <input type="text" id="new-file-name" placeholder="filename.txt">
                <button class="button" onclick="createFile()">📝 Create File</button>
            </div>
        </div>

        <div class="panel">
            <h2>💻 Console</h2>
            <div class="console" id="console">
                <div>🌌 Akashic Records Console Ready</div>
                <div>📡 WebSocket: ws://localhost:{self.ws_port}</div>
                <div>🌐 HTTP API: http://localhost:{self.http_port}</div>
                <div>✅ Server operational</div>
            </div>
            <div class="input-group">
                <input type="text" id="console-input" placeholder="Enter command...">
                <button class="button" onclick="sendCommand()">📤 Send</button>
                <button class="button primary" onclick="sendToGame('spawn_universal_being')">⭐ Spawn Universal Being</button>
                <button class="button" onclick="sendToGame('repair_scan')">🔧 Scan Systems</button>
            </div>
        </div>
    </div>

    <script>
        let gameWebSocket = null;
        
        // Initialize interface
        document.addEventListener('DOMContentLoaded', function() {{
            updateStatus();
            connectToGames();
            setInterval(updateStatus, 5000); // Update every 5 seconds
        }});
        
        async function updateStatus() {{
            try {{
                const response = await fetch('/api/status');
                const status = await response.json();
                
                document.getElementById('server-status').innerHTML = `
                    <div class="status-item">
                        <strong>Connected Games:</strong> ${{status.connected_games}}
                    </div>
                    <div class="status-item">
                        <strong>Monitored Files:</strong> ${{status.monitored_files}}
                    </div>
                    <div class="status-item">
                        <strong>Tutorial Steps:</strong> ${{status.tutorial_steps}}
                    </div>
                    <div class="status-item">
                        <strong>Uptime:</strong> ${{Math.floor(status.uptime)}}s
                    </div>
                `;
                
                const gamesResponse = await fetch('/api/games');
                const games = await gamesResponse.json();
                
                const gamesHtml = games.length > 0 ? 
                    games.map(game => `
                        <div class="status-item">
                            <strong>${{game.id}}</strong><br>
                            Connected: ${{game.connected_at}}<br>
                            FPS: ${{game.last_state.fps || 'Unknown'}}
                        </div>
                    `).join('') : 
                    '<div class="status-item warning">No games connected</div>';
                    
                document.getElementById('games-list').innerHTML = gamesHtml;
                
                // Update connection indicator
                const indicator = document.getElementById('connection-status');
                const text = document.getElementById('connection-text');
                if (games.length > 0) {{
                    indicator.className = 'connection-indicator connected';
                    text.textContent = `Connected to ${{games.length}} game(s)`;
                }} else {{
                    indicator.className = 'connection-indicator disconnected';
                    text.textContent = 'No games connected';
                }}
                
            }} catch (error) {{
                console.error('Failed to update status:', error);
            }}
        }}
        
        function connectToGames() {{
            // This would establish WebSocket connection to relay commands
            console.log('Game connection system ready');
        }}
        
        function startTutorial() {{
            addToConsole('🚀 Starting tutorial...');
            // Send tutorial start command to connected games
            sendToGame('tutorial_start');
        }}
        
        function resetTutorial() {{
            addToConsole('🔄 Resetting tutorial progress...');
            sendToGame('tutorial_reset');
        }}
        
        function sendCommand() {{
            const input = document.getElementById('console-input');
            const command = input.value.trim();
            if (command) {{
                addToConsole(`> ${{command}}`);
                sendToGame(command);
                input.value = '';
            }}
        }}
        
        async function sendToGame(command) {{
            addToConsole(`📤 Sending to game: ${{command}}`);
            
            // Send command to server to relay to games
            try {{
                console.log('Sending POST to /api/command with:', {{command, target: 'all_games'}});
                const response = await fetch('/api/command', {{
                    method: 'POST',
                    headers: {{
                        'Content-Type': 'application/json'
                    }},
                    body: JSON.stringify({{
                        command: command,
                        target: 'all_games'
                    }})
                }});
                
                console.log('Response status:', response.status);
                const result = await response.json();
                console.log('Response data:', result);
                
                if (result.success) {{
                    addToConsole(`✅ Command sent to ${{result.sent_to}} game(s)`);
                }} else {{
                    addToConsole(`❌ Failed to send command: ${{result.message || 'Unknown error'}}`);
                }}
            }} catch (error) {{
                console.error('Error sending command:', error);
                addToConsole(`❌ Error sending command: ${{error.message}}`);
            }}
        }}
        
        function createFile() {{
            const filename = document.getElementById('new-file-name').value.trim();
            if (filename) {{
                addToConsole(`📝 Creating file: ${{filename}}`);
                document.getElementById('new-file-name').value = '';
            }}
        }}
        
        function addToConsole(message) {{
            const console = document.getElementById('console');
            const div = document.createElement('div');
            div.textContent = `[${{new Date().toLocaleTimeString()}}] ${{message}}`;
            console.appendChild(div);
            console.scrollTop = console.scrollHeight;
        }}
        
        // Handle console input with Enter key
        document.getElementById('console-input').addEventListener('keypress', function(e) {{
            if (e.key === 'Enter') {{
                sendCommand();
            }}
        }});
    </script>
</body>
</html>
        """

# Main server entry point
async def main():
    server = AkashicServer()
    server.start_time = time.time()
    await server.start_server()

if __name__ == "__main__":
    print("🌌 Akashic Records Server - Starting...")
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n🛑 Server shutdown requested")
    except Exception as e:
        print(f"❌ Server error: {e}")