# JSH Ethereal Engine - Multi-Reality Integration

This module enables your JSH Ethereal Engine to synchronize across multiple devices, including:
- Laptop (primary processing)
- VR Headset (immersive visualization)
- iPhone with LiDAR (world scanning)

## Overview

The Multi-Reality Integration system creates a unified reality experience where all devices share:
- Entity states (words manifested into reality)
- Reality types (physical, digital, astral)
- World scale settings
- LiDAR scan data
- User interactions

## Setup Guide

### 1. Prerequisites

- Godot 4.x or higher
- iPhone with LiDAR (iPhone 12 Pro or newer)
- VR headset compatible with OpenXR
- All devices connected to the same local network

### 2. Installation

1. Ensure the JSH Ethereal Engine core is already installed
2. Make sure the ThreadPool addon is installed and running as an autoload
3. Add the integration scripts to your project's autoload list:
   - MultiDeviceController (`res://code/gdscript/scripts/integration/multi_device_controller.gd`)
   - iPhoneLiDARBridge (`res://code/gdscript/scripts/integration/iphone_lidar_bridge.gd`)
   - VRRealityBridge (`res://code/gdscript/scripts/integration/vr_reality_bridge.gd`)

### 3. Configuration

Edit the `res://config/multi_reality_config.json` file to configure:
- Device roles and capabilities
- Networking settings
- Reality transition effects
- Scale settings
- Performance parameters

### 4. Device Setup

#### Laptop (Primary)
1. Run the main JSH Ethereal Engine application
2. Initialize integration with:
   ```gdscript
   var integration = JSHMultiRealityIntegration.new()
   add_child(integration)
   integration.initialize()
   ```

#### VR Headset
1. Connect your VR headset
2. VR should be automatically detected and integrated

#### iPhone with LiDAR
1. Install the JSH LiDAR Scanner app on your iPhone
2. Connect to the laptop using:
   ```gdscript
   integration.connect_to_iphone("192.168.1.x")  # iPhone's IP address
   ```

## Usage Examples

### 1. Create Entity Across All Devices

```gdscript
var integration = JSHMultiRealityIntegration.get_instance()
var position = Vector3(0, 1, -3)  # Position in world space
var entity_id = integration.create_entity_everywhere("crystal", position)
```

### 2. Change Reality Type

```gdscript
# Switch to digital reality on all connected devices
integration.change_reality("digital")
```

### 3. Request LiDAR Scan

```gdscript
# Request a room scan from iPhone
var scan_id = integration.request_lidar_scan()

# Track scan progress
print("Scan started: " + scan_id)

# The scan will automatically be processed and visualized in VR when complete
```

### 4. Check System Status

```gdscript
var status = integration.get_status()
print("VR Active: " + str(status.vr_active))
print("iPhone Connected: " + str(status.mobile_connected))
print("Current Reality: " + status.current_reality)
```

## Technical Architecture

The integration consists of three main systems:

1. **MultiDeviceController**
   - Manages connections between devices
   - Coordinates entity and reality synchronization
   - Handles scan data distribution

2. **iPhoneLiDARBridge**
   - Communicates with the iPhone app
   - Receives and processes LiDAR scan data
   - Handles object recognition from real-world scans

3. **VRRealityBridge**
   - Manages VR visualization and interaction
   - Implements reality transition effects in VR
   - Provides gesture recognition for reality manipulation

All systems are tied together by **JSHMultiRealityIntegration**, which provides a unified API for the entire multi-device experience.

## Threading Model

The multi-device integration uses multiple threads to ensure smooth performance:

- **Main Thread**: UI updates and user interaction
- **Sync Thread**: Entity state synchronization
- **Scan Processing Thread**: LiDAR data processing
- **Entity Processing Thread**: Entity behavior updates
- **Physics Thread**: Physics simulation

Thread allocation can be configured in the `multi_reality_config.json` file.

## Troubleshooting

### iPhone Connection Issues

1. Ensure both devices are on the same network
2. Check firewall settings (ports 45678-45681 must be open)
3. Verify iPhone has the latest JSH LiDAR Scanner app
4. Try manual IP configuration if auto-discovery fails

### VR Integration Issues

1. Ensure your VR runtime is properly installed (OpenXR)
2. Check if the headset is recognized in Godot's XR settings
3. Verify the VRManager is properly initialized
4. Try restarting the VR runtime before launching the app

### Reality Synchronization Issues

1. Check network connectivity between devices
2. Verify that all devices are running compatible versions
3. Restart the integration with:
   ```gdscript
   integration.initialize()
   ```

## Extended Usage

### Custom Reality Transitions

You can define custom reality transition effects by modifying the transition settings:

```gdscript
integration.reality_transitions["physical_to_digital"] = {
    "duration": 2.0,
    "effect": "my_custom_effect"
}

# Implement the effect in your shader or post-processing chain
```

### Advanced Scan Processing

For custom scan data processing:

```gdscript
# Connect to the scan completed signal
iphone_lidar_bridge.connect("scan_completed", Callable(self, "_on_my_scan_completed"))

# Process the scan data your way
func _on_my_scan_completed(scan_id, scan_data):
    # Custom processing...
    var my_processed_data = process_my_way(scan_data)
    
    # Add to the world
    add_to_world(my_processed_data)
```

## Building for iPhone

To build the companion iPhone app:

1. Use the provided iOS project in the `mobile` folder
2. Open in Xcode 13+
3. Configure app signing
4. Build and deploy to iPhone 12 Pro or newer