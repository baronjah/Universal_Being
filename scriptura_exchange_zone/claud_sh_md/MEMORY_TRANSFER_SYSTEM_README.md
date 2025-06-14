# Memory Transfer System

A cross-device memory transfer system for seamlessly synchronizing memory fragments between different devices. This system enables the transfer of memory investments, fragments, and patterns across desktop, browser, phone, tablet, and Claude devices.

## Features

- **Multiple Transfer Types**:
  - Full Sync: Complete synchronization of all memory fragments
  - Differential: Only transfer changes since the last sync
  - Snapshot: Transfer current state without history
  - Streaming: Continuous real-time transfer
  - Ethereal: Non-physical transfer through dimensional tunnels

- **Device Support**:
  - Desktop applications
  - Browser-based interfaces
  - Mobile devices (phones and tablets)
  - Claude AI integration

- **Data Handling**:
  - Compression and encryption for secure transfers
  - Batch processing for efficient handling of large fragment collections
  - Prioritization of critical memory fragments
  - Support for both physical and ethereal memory fragments

- **Memory Management**:
  - Memory fragment organization and tracking
  - Automatic memory optimization
  - Snapshot creation and restoration
  - Memory quality analysis

## Components

The memory transfer system integrates with several existing components:

1. **Cross Device Connector**: Manages device connections and tunnels between devices
2. **Drive Memory Connector**: Handles local storage and retrieval of memory fragments
3. **Cloud Storage Connector**: Provides access to cloud storage options
4. **Akashic Record Connector**: Integrates with the akashic record system (if available)

## Usage

### Basic Setup

```gdscript
# Create memory transfer system
var memory_transfer_system = MemoryTransferSystem.new()
add_child(memory_transfer_system)

# Connect signals
memory_transfer_system.transfer_started.connect(_on_transfer_started)
memory_transfer_system.transfer_progress.connect(_on_transfer_progress)
memory_transfer_system.transfer_completed.connect(_on_transfer_completed)
```

### Starting a Memory Transfer

```gdscript
# Basic transfer with default settings
var transfer_id = memory_transfer_system.start_memory_transfer("target_device_id")

# Advanced transfer with options
var options = {
  "transfer_type": MemoryTransferSystem.TransferType.DIFFERENTIAL,
  "priority": MemoryTransferSystem.Priority.HIGH,
  "include_ethereal": true,
  "encryption_enabled": true,
  "compression_level": 7
}
var transfer_id = memory_transfer_system.start_memory_transfer("target_device_id", options)
```

### Managing Transfers

```gdscript
# Check transfer status
var status = memory_transfer_system.get_transfer_status(transfer_id)

# Cancel an active transfer
memory_transfer_system.cancel_transfer(transfer_id)

# Get all transfers
var all_transfers = memory_transfer_system.get_all_transfers()
```

### Memory Management

```gdscript
# Create a memory snapshot
var snapshot = memory_transfer_system.create_memory_snapshot("snapshot_name")

# Load a memory snapshot
memory_transfer_system.load_memory_snapshot("snapshot_name")

# Optimize device memory
var optimization_result = memory_transfer_system.optimize_device_memory()

# Get current memory state
var state = memory_transfer_system.get_memory_state()
```

## Events

The memory transfer system provides several signals to track operations:

- `transfer_started(source_device, target_device, transfer_id)`: Emitted when a transfer begins
- `transfer_progress(transfer_id, progress, bytes_transferred)`: Emitted during transfer progress
- `transfer_completed(transfer_id, success, stats)`: Emitted when a transfer completes
- `device_memory_updated(device_id, stats)`: Emitted when device memory stats change
- `error_occurred(error_code, message)`: Emitted when an error occurs

## Ethereal Transfers

Ethereal transfers use dimensional tunnels to move memory between devices in a non-physical way. This is especially useful for Claude integration and transferring conceptual memory fragments.

```gdscript
var options = {
  "transfer_type": MemoryTransferSystem.TransferType.ETHEREAL,
  "priority": MemoryTransferSystem.Priority.NORMAL
}
var transfer_id = memory_transfer_system.start_memory_transfer("claude_device_id", options)
```

## Integration with 12 Turns System

The memory transfer system integrates with the 12 turns system by allowing memory fragments to be synchronized between turns and across different device sessions. Each turn can create memory investments that are then transferred to other devices.

## Example: Test Script

See `memory_transfer_test.gd` for a complete example of using the memory transfer system with all features.