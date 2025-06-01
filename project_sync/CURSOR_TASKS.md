# 📋 CURSOR TASKS - Universal Being Project
## Date: 2025-06-02
## Focus: Shaders & Visual Integration

## 🎨 Immediate Shader Tasks:

### 1. Consciousness Pulse Shader
Create `effects/shaders/consciousness_pulse.gdshader`:
```gdscript
shader_type spatial;
uniform float pulse_speed = 2.0;
uniform float consciousness_level = 1.0;
uniform vec4 consciousness_color : hint_color;
// Add pulsing glow based on consciousness level
```

### 2. Marching Cubes Glow Shader
Create `effects/shaders/marching_cubes_glow.gdshader`:
```gdscript
shader_type spatial;
uniform float glow_intensity = 1.0;
uniform float edge_softness = 0.1;
// Make marching cubes output glow with consciousness
```

### 3. AI Connection Beam Shader
Create `effects/shaders/ai_connection_beam.gdshader`:
```gdscript
shader_type spatial;
uniform float beam_width = 0.1;
uniform vec4 ai_color_1 : hint_color;
uniform vec4 ai_color_2 : hint_color;
// Animated energy beam between AI nodes
```

### 4. Evolution Morph Shader
Create `effects/shaders/evolution_morph.gdshader`:
```gdscript
shader_type spatial;
uniform float morph_progress = 0.0;
uniform sampler2D noise_texture;
// Smooth morphing between consciousness states
```

## 🔧 Code Integration Tasks:

### 1. Marching Cubes Controller
Create `systems/marching_cubes/consciousness_volume_generator.gd`

### 2. Visual Bridge
Connect particle effects with marching cubes output

### 3. Shader Parameters
Expose shader parameters to GDScript for dynamic control

## 🎯 Visual Enhancements:
- Add rim lighting to consciousness meshes
- Create energy field distortion effect
- Add particle trails to moving beings
- Implement holographic projection effect

## 📦 File Locations:
```
effects/
├── shaders/
│   ├── consciousness_pulse.gdshader
│   ├── marching_cubes_glow.gdshader
│   ├── ai_connection_beam.gdshader
│   └── evolution_morph.gdshader
└── materials/
    └── consciousness_materials/
```

**COPY THIS TO CURSOR AND START WITH TASK #1**