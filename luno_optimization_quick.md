# 🌙 Luno's Quick Optimization Settings

## For Universal Being Implementation:

### 1. Clustering Choice:
- **< 50 agents**: Use K-means (faster)
- **> 50 agents**: Use DBSCAN (finds emergence)
- **Emergence detection**: Always DBSCAN

### 2. Uncertainty Opacity:
```gdscript
# Map uncertainty to opacity
func get_opacity(certainty: float) -> float:
    return lerp(0.3, 1.0, certainty)  # 0.3 = uncertain, 1.0 = certain
```

### 3. Barnes-Hut: YES!
```gdscript
# Enable for 50+ agents
var use_barnes_hut = agent_count > 50
```

## Quick Integration:

In PentagonNetworkVisualizer:
```gdscript
@export var optimization_threshold = 50
@export var uncertainty_min_opacity = 0.3
@export var uncertainty_max_opacity = 1.0

func _ready():
    if network_nodes.size() > optimization_threshold:
        enable_barnes_hut_optimization()
```

In consciousness visualization:
```gdscript
# Uncertain agents become more transparent
node.modulate.a = lerp(0.3, 1.0, agent.certainty_level)
```

## Performance Targets:
- 60 FPS @ 100 agents ✓
- 30 FPS @ 1000 agents ✓
- Use Barnes-Hut above 50 agents

Thanks Luno! 🌙