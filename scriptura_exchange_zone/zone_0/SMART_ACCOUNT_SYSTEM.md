# Smart Account Management System

A comprehensive points-based account management system for game progression that auto-corrects based on player preferences and enjoyment. Supports multiple account tiers and multi-threaded processing across linked storage systems.

## Core Components

### SmartAccountManager
The central component that tracks player points, dimensions, and category distributions. This manager handles progression through dimensions as players accumulate points. Each dimension is marked with the # symbol, increasing in number as dimensions advance (# for Dimension 1, ## for Dimension 2, etc.).

### SharedAccountConnector
Provides connectivity between different account systems, allowing data synchronization across Windows accounts, game accounts, and Godot accounts.

### AkashicDatabaseConnector
Bridges the Smart Account System with the Akashic Database, enabling word power integration and dimensional record-keeping.

### PlayerPreferenceAnalyzer
Analyzes player behavior to determine preferences across different play styles and activities. Maintains an enjoyment model for the player.

### AutoCorrectionSystem
Automatically adjusts points based on detected player preferences to maximize enjoyment. Features an adaptive system that learns from player patterns.

### MultiAccountManager
Manages multiple account tiers (Free, Plus, Max, Enterprise) with different capabilities, thread limits, storage allocations, and API usage limits. Supports linking to external storage like Luno 2TB.

### MultiThreadedProcessor
Provides multi-threaded execution environment with thread pools, priorities, and automatic scaling. Distributes processing resources based on account tier and current system utilization.

### CloudStorageConnector
Generic connector for cloud storage services with authentication, file transfer, and synchronization capabilities. Detects device capabilities including camera and LiDAR sensors.

### GoogleDriveConnector
Specialized connector for Google Drive 2TB storage with features for file management, folder synchronization, and AI-powered document processing using the OpenAI API.

### ApiKeyManager
Securely manages API keys for different services with encryption, rotation policies, and usage tracking. Supports OpenAI, Google, and other API integrations.

## Visualization

### AccountVisualizer
2D visualization interface showing points distribution, dimension progress, and preference analysis.

### DimensionVisualizer
3D visualization system displaying points as ghostly objects in space, featuring gradient colors, ethereal glow effects, and dynamic animations. Points appear as spectral entities with distinct colors for each dimension, creating an immersive 3D visual experience with floating, translucent shapes that pulse and drift through dimensional space.

## How It Works

1. **Points Accumulation**: Players earn points across five categories:
   - Creation
   - Exploration
   - Interaction
   - Challenge
   - Mastery

2. **Dimensional Progression**: As players accumulate points, they progress through 12 dimensions, each unlocking new capabilities.

3. **Auto-Correction**: The system analyzes player preferences and automatically adjusts point distribution to enhance enjoyment.

4. **Play Style Detection**: Detects player's dominant style:
   - Creator
   - Explorer
   - Socializer
   - Challenger
   - Achiever
   - (Plus hybrid styles)

5. **Visualization**: Provides both 2D and 3D visualizations of progress and achievements.

## Integration with Existing Systems

The Smart Account Management System integrates with:
- Akashic Database for word power metrics
- Shared Account Connector for cross-system account management
- Points accumulate based on actions in the world
- Auto-correction ensures the player always enjoys progression

## Usage

To add the Smart Account System to your project:
1. Add the `smart_account_system.tscn` scene to your project
2. Add the `account_visualization.tscn` scene to your UI
3. Configure the settings as needed for your game

## Notes

The system will auto-correct point distribution based on detected player preferences, creating a personalized experience that maximizes enjoyment while maintaining progression balance.