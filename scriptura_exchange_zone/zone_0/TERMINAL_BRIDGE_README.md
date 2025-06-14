# Data Splitter Terminal Bridge

This system provides a terminal-based interface for interacting with the Data Splitter system. It allows for creating, managing, and visualizing data streams, chunks, and operations through a terminal interface.

## Components

### 1. Data Splitter Terminal Bridge (GDScript)

The `data_splitter_terminal_bridge.gd` script serves as the core integration layer between the terminal and the Data Splitter system. It handles:

- Bi-directional communication with terminal files
- Processing of terminal commands
- Data operation management
- Visualization generation
- Signal handling

### 2. Terminal Visualizer (GDScript)

The `data_splitter_terminal_visualizer.gd` script provides enhanced visualization capabilities for data entities in the terminal. Features include:

- Dimension-aware visualization (1D, 2D, 3D, and higher)
- ASCII art representation
- Color-coded output
- Detailed/compact visualization modes
- Split/merge operation visualization

### 3. Terminal Interface Shell Script

The `data_splitter_terminal.sh` script provides a user-friendly terminal interface that:

- Simulates a terminal environment for interacting with the Data Splitter
- Processes user commands
- Displays visualizations
- Provides a command history
- Supports multiple terminal instances

## Command Reference

The terminal bridge supports the following commands:

- `/split [chunk_id] [split_factor]` - Split a data chunk
- `/stream [stream_id] [data_type] [size]` - Create a new data stream
- `/chunk [chunk_id] [parent_stream] [content]` - Create a new data chunk
- `/merge [chunk_id1,chunk_id2,...] [merge_type]` - Merge multiple chunks
- `/list [streams|chunks|splits|all]` - List data elements
- `/analyze [text]` - Analyze text for data splitting
- `/visualize [chunk_id|stream_id] [dimension]` - Visualize data in terminal
- `/help` - Display help information

## Setup

1. Ensure the Data Splitter system is properly initialized
2. Add the Terminal Bridge to your scene
3. Connect the Terminal Bridge to the Data Splitter Controller
4. Launch the terminal interface using the shell script

```bash
# Launch terminal interface with terminal ID 0
./data_splitter_terminal.sh 0

# Launch multiple terminals with different IDs (0-5)
./data_splitter_terminal.sh 1
./data_splitter_terminal.sh 2
```

## Integration with Different Dimensions and Realities

The Terminal Bridge automatically detects and adapts to dimension and reality changes in the Notepad3D/Pitopia system. Visualizations will reflect the current dimension and reality context, providing appropriate representations for each setting.

### Dimension Visualization

- **1D**: Simple line representation
- **2D**: Box representation
- **3D**: 3D box with depth
- **4D+**: Higher dimension properties displayed (Time, Consciousness, etc.)

### Reality Integration

Connects with various realities:
- Physical
- Digital
- Astral
- Quantum
- Memory
- Dream

## Architecture

```
┌───────────────────────┐      ┌───────────────────────┐
│                       │      │                       │
│  Data Splitter System │◄────►│ Terminal Bridge (GD)  │
│                       │      │                       │
└───────────────────────┘      └──────────┬────────────┘
                                          │
                                          ▼
┌───────────────────────┐      ┌───────────────────────┐
│                       │      │                       │
│  Terminal Shell       │◄────►│ Terminal Files        │
│                       │      │                       │
└───────────────────────┘      └───────────────────────┘
```

## Development

To extend the Terminal Bridge:

1. Add new commands to `_process_command` in the Terminal Bridge
2. Create handler methods for new commands
3. Update the Visualizer for new data types
4. Update the shell script to display new visualizations

## Example Usage

```
Terminal 0> /stream my_stream text 32
Creating data stream 'my_stream' of type text with size 32...
Operation queued. Results will appear in the terminal.

Stream created: my_stream
- Type: text
- Size: 32 bytes
- Initial chunk: my_stream_chunk_0

Terminal 0> /chunk my_chunk my_stream This is test content
Creating data chunk 'my_chunk' in stream 'my_stream'...
Operation queued. Results will appear in the terminal.

Chunk created: my_chunk
- Parent stream: my_stream
- Content length: 19 chars
- Content preview: This is test content

Terminal 0> /visualize my_chunk 3
Visualizing 'my_chunk' in 3D:

    ______________________________
   /|                            |
  / |       my_chunk             |
 /__|____________________________|
|   |                            |
|   |  Stream: my_stream         |
|   |  Size: 24 bytes            |
|   |  Created: 2025-05-20 10:15:22 |
|___|____________________________|

Properties:
  entropy: 0.3
  complexity: 0.7
  coherence: 0.5
  stability: 0.8
```

## Notes

- The Terminal Bridge supports multiple terminal instances (0-5)
- Terminal files are stored in the user data directory
- Data operations are processed asynchronously
- Color support depends on terminal capabilities
- Higher dimension visualizations require more terminal space