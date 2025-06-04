# Godot Classes Collection Overview
*Progress: 80/220 classes documented*

## Categories Collected So Far

### 🎯 Core Nodes
- **Node** - Base class for all scene objects
- **CanvasItem** - Base for all 2D nodes
- **Control** - Base for all UI elements
- **Container** - Base for UI containers

### 📦 UI Containers (Complete Set!)
- **BoxContainer** - Arranges children in a row/column
- **CenterContainer** ⭐ - Centers children (our console fix!)
- **AspectRatioContainer** - Maintains aspect ratio
- **CanvasGroup** - Groups CanvasItems
- **ColorRect** - Simple colored rectangle

### 🎮 UI Controls
- **BaseButton** - Base for all buttons
- **Button** - Standard push button
- **CheckBox** - Checkbox with label
- **CheckButton** - Toggle button
- **CodeEdit** - Code editor with syntax highlighting
- **ColorPicker** - Color selection widget
- **ColorPickerButton** - Button that opens color picker

### 🏃 Physics Bodies
#### 2D Physics
- **CharacterBody2D** - For player characters
- **AnimatableBody2D** - Animated physics body
- **Area2D** - Detects overlaps
- **CollisionObject2D** - Base for physics objects
- **CollisionShape2D** - Defines collision area
- **CollisionPolygon2D** - Polygon collision shape

#### 3D Physics
- **CharacterBody3D** ⭐ - Our ragdoll base!
- **AnimatableBody3D** - Animated 3D physics
- **Area3D** - 3D overlap detection
- **CollisionObject3D** - Base for 3D physics
- **CollisionShape3D** - 3D collision shape
- **CollisionPolygon3D** - 3D polygon collision

### 🎨 Graphics & Rendering
#### 2D Graphics
- **AnimatedSprite2D** - Animated 2D sprite
- **CanvasLayer** - Independent 2D layer
- **CanvasModulate** - Modulates canvas colors
- **BackBufferCopy** - Copies screen buffer
- **DirectionalLight2D** - 2D directional light

#### 3D Graphics  
- **AnimatedSprite3D** - Billboard animated sprite
- **DirectionalLight3D** - Sun-like light
- **Decal** - Projects textures on surfaces
- **Camera3D** - 3D camera view
- **BoneAttachment3D** - Attaches to skeleton

### 🎭 Animation
- **AnimationPlayer** - Plays animations
- **AnimationTree** - Complex animation blending
- **AnimationMixer** - Mixes multiple animations

### 🔊 Audio
- **AudioStreamPlayer** - Non-positional audio
- **AudioStreamPlayer2D** - 2D positional audio
- **AudioStreamPlayer3D** - 3D positional audio
- **AudioListener2D** - 2D audio receiver
- **AudioListener3D** - 3D audio receiver

### 🏗️ CSG (Constructive Solid Geometry)
- **CSGShape3D** - Base CSG class
- **CSGCombiner3D** - Combines CSG shapes
- **CSGPrimitive3D** - Base primitive
- **CSGBox3D** - Box primitive
- **CSGCylinder3D** - Cylinder primitive
- **CSGSphere3D** - Sphere primitive
- **CSGTorus3D** - Torus primitive
- **CSGPolygon3D** - Extruded polygon
- **CSGMesh3D** - CSG from mesh

### 🎪 Particles
- **CPUParticles2D** - CPU-based 2D particles
- **CPUParticles3D** - CPU-based 3D particles

### ⚙️ Joints
- **DampedSpringJoint2D** - 2D spring joint
- **ConeTwistJoint3D** - 3D cone twist joint

### 📝 Dialogs
- **AcceptDialog** - OK dialog
- **ConfirmationDialog** - OK/Cancel dialog

### 🛠️ Editor Classes
- **EditorPlugin** - Extends editor
- **EditorProperty** - Custom inspector property
- **EditorInspector** - Inspector panel
- **EditorFileDialog** - Editor file picker
- **EditorFileSystem** - Editor file management
- **EditorCommandPalette** - Command palette

### 📸 Cameras
- **Camera2D** - 2D camera
- **Camera3D** - 3D camera

### 🦴 Skeleton
- **Bone2D** - 2D bone for animation

## 🌟 Key Classes for Our Project

1. **CenterContainer** - Already using for console!
2. **CharacterBody3D** - Base for our ragdoll
3. **AnimationTree** - Could enhance ragdoll movement
4. **Area3D** - For detecting nearby objects
5. **CSG shapes** - Could replace simple meshes
6. **Decal** - For ground effects

## 📊 Collection Analysis

### Well Covered Areas:
- ✅ UI Containers (all major ones)
- ✅ Physics bodies (2D & 3D)
- ✅ CSG (complete set)
- ✅ Audio (all players)
- ✅ Basic controls

### Still Need:
- ❌ Mesh instances
- ❌ Lights (only directional)
- ❌ Viewports
- ❌ Resources
- ❌ Shaders
- ❌ Networking
- ❌ File I/O

## 🎯 Most Useful for Talking Ragdoll Game

1. **CharacterBody3D** - Essential for ragdoll
2. **AnimationTree** - Advanced ragdoll animation
3. **Area3D** - Object detection
4. **AudioStreamPlayer3D** - Positional speech
5. **CenterContainer** - UI positioning
6. **CodeEdit** - Enhanced console?
7. **CSGBox3D** - Simple level building
8. **Decal** - Footprints, shadows

## 💡 Discoveries from Your Collection

- **AnimatableBody3D** - Could make moving platforms!
- **CanvasGroup** - Group UI elements for effects
- **BackBufferCopy** - Screen effects possibilities
- **ConeTwistJoint3D** - Better ragdoll joints!

Keep going! You're building an excellent reference that will help us understand all of Godot's capabilities!