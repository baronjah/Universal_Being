# AKASHIC LOADER QUICK START GUIDE

## Integration with Existing System

### 1. Update Pentagon.gd to support Akashic
```gdscript
# Add to Pentagon.gd
static func orchestrate_with_akashic(being: UniversalBeing, akashic: AkashicLoader) -> void:
    # Let Akashic preload packages before pentagon_init
    akashic.preload_being_dependencies(being)
    
    # Normal Pentagon flow continues
    orchestrate_process(being, 0.0)
```

### 2. Update Connector.gd for Akashic integration
```gdscript
# Add to Connector.gd
static func bind_with_akashic(being: UniversalBeing, components: Array, akashic: AkashicLoader) -> bool:
    # Test components before binding
    for component in components:
        if component.has("package_path"):
            var test_result = akashic.test_package(component.package_path)
            if not test_result.valid:
                push_warning("Component failed validation: " + component.name)
                continue
        
        _bind_single_component(being, component)
    
    return true
```

### 3. Create a BeingManager that uses all systems
```gdscript
# beings/BeingManager.gd
extends Node

var akashic_loader: AkashicLoader
var zip_manager = ZipPackageManager

func _ready():
    # Initialize Akashic Loader
    akashic_loader = AkashicLoader.new()
    add_child(akashic_loader)
    
    # Connect performance monitoring
    akashic_loader.memory_warning.connect(_on_memory_warning)
    
    # Integrate with ZIP Manager
    akashic_loader.integrate_with_zip_manager()

func create_being(being_type: String, zip_path: String) -> UniversalBeing:
    var being = UniversalBeing.new()
    being.being_type = being_type
    
    # 1. Pentagon Integration
    akashic_loader.integrate_with_pentagon(being)
    
    # 2. Load and test ZIP package
    akashic_loader.queue_package_load(zip_path, AkashicLoader.PackagePriority.HIGH)
    await akashic_loader.package_loaded
    
    # 3. Install package with validation
    if zip_manager.install_package_to_being(being, zip_path):
        # 4. Connector Integration
        akashic_loader.integrate_with_connector(being)
        
        # 5. Bind components
        var package_data = zip_manager.load_package(zip_path)
        if package_data.manifest.has("components"):
            Connector.bind_with_akashic(being, package_data.manifest.components, akashic_loader)
    
    return being

func _on_memory_warning(usage_percent: float):
    print("⚠️ Memory at %d%% - Consider reducing active beings" % usage_percent)
```

### 4. Monitor Performance in Game Loop
```gdscript
# Main.gd
extends Node

@onready var being_manager = $BeingManager
@onready var performance_label = $UI/PerformanceLabel

func _process(_delta):
    # Update performance metrics
    var metrics = being_manager.akashic_loader.get_performance_metrics()
    performance_label.text = "FPS: %d | Memory: %d%% | Queue: %d" % [
        metrics.current_fps,
        metrics.memory_percent,
        metrics.loading_queue_size
    ]
    
    # Optimize loading based on FPS
    being_manager.akashic_loader.optimize_for_60fps()
```

## Key Points to Remember:

1. **Always test packages before loading** - The validation system prevents crashes
2. **Use priority levels** - Critical packages load first
3. **Monitor memory usage** - React to warnings before hitting limits
4. **Respect the frame budget** - 2ms max for loading per frame
5. **Preload evolution paths** - Smooth transitions between forms

## Performance Tips:

- Start with small cache (50MB) and increase based on needs
- Use BACKGROUND priority for non-essential packages
- Batch similar package loads together
- Clean up beings properly in SEWERS phase
- Profile your specific use case and adjust budgets

The Akashic Loader makes your Universal Being system production-ready!