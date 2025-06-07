# ==================================================
# AKASHIC LOADER - Universal Memory & Test System
# PURPOSE: Monitor, test, and optimize ZIP package loading
# LOCATION: core/akashic_loader.gd
# ==================================================

extends Node
class_name AkashicLoader

## Memory pools for efficient package management
const MEMORY_POOL_SIZE = 50 # Max packages in active memory
const CACHE_SIZE_MB = 100 # Maximum cache size in MB
const PRELOAD_RADIUS = 3 # Preload packages within N steps

## Performance targets
const TARGET_FPS = 60
const FRAME_TIME_BUDGET_MS = 16.67 # 1000/60
const LOAD_TIME_BUDGET_MS = 2.0 # Max time per frame for loading

## Package states
enum PackageState {
	UNLOADED,
	TESTING,
	VALIDATED,
	LOADED,
	ACTIVE,
	CACHED,
	FAILED
}

## Package metadata structure
class PackageMetadata:
	var path: String
	var manifest: Dictionary
	var state: PackageState = PackageState.UNLOADED
	var last_accessed: float = 0.0
	var memory_size: int = 0
	var test_results: Dictionary = {}
	var priority: int = 0
	var dependencies: Array[String] = []

## Memory management
var active_packages: Dictionary = {} # Currently loaded packages
var package_cache: Dictionary = {} # LRU cache
var loading_queue: Array[String] = [] # Async loading queue
var total_memory_used: int = 0

## Performance monitoring
var frame_time_accumulator: float = 0.0
var loading_coroutines: Array = []

signal package_loaded(package_path: String)
signal package_failed(package_path: String, error: String)
signal memory_warning(usage_percent: float)

func _ready() -> void:
	# Start monitoring system
	set_process(true)
	_initialize_memory_pools()

func _process(delta: float) -> void:
	# Monitor frame time and process loading queue
	frame_time_accumulator += delta
	
	var start_time = Time.get_ticks_msec()
	while loading_queue.size() > 0 and Time.get_ticks_msec() - start_time < LOAD_TIME_BUDGET_MS:
		_process_loading_queue()

## INTEGRATION STRATEGY ==================================================

func integrate_with_pentagon(being: UniversalBeing) -> void:
	"""Seamless Pentagon lifecycle integration"""
	# Hook into Pentagon states
	if being.has_method("pentagon_init"):
		_preload_being_packages(being)
	
	# Monitor state transitions
	being.connect("pentagon_state_changed", _on_pentagon_state_changed)

func integrate_with_connector(being: UniversalBeing) -> void:
	"""Connect with Logic DNA system"""
	var dna = Connector.extract_logic_dna(being.zip_path if being.has("zip_path") else "")
	
	# Analyze DNA for package requirements
	var required_packages = _analyze_dna_requirements(dna)
	for package in required_packages:
		queue_package_load(package, PackagePriority.HIGH)

func integrate_with_zip_manager() -> void:
	"""Enhanced ZIP loading with validation"""
	# Override ZipPackageManager load method
	ZipPackageManager.set_meta("akashic_loader", self)

## PACKAGE TESTING SYSTEM ==================================================

func test_package(package_path: String) -> Dictionary:
	"""Comprehensive package validation before loading"""
	var test_results = {
		"valid": true,
		"errors": [],
		"warnings": [],
		"performance_score": 100
	}
	
	# Test 1: Manifest validation
	var manifest_test = _test_manifest_integrity(package_path)
	if not manifest_test.valid:
		test_results.valid = false
		test_results.errors.append_array(manifest_test.errors)
	
	# Test 2: Component compatibility
	var compat_test = _test_component_compatibility(package_path)
	test_results.warnings.append_array(compat_test.warnings)
	
	# Test 3: Performance impact
	var perf_test = _test_performance_impact(package_path)
	test_results.performance_score = perf_test.score
	
	# Test 4: Memory footprint
	var memory_test = _test_memory_footprint(package_path)
	if memory_test.size > CACHE_SIZE_MB * 0.1: # >10% of cache
		test_results.warnings.append("Large package: %d MB" % memory_test.size)
	
	return test_results

func _test_manifest_integrity(package_path: String) -> Dictionary:
	"""Validate manifest structure and requirements"""
	var result = {"valid": true, "errors": []}
	
	var package = ZipPackageManager.load_package(package_path)
	if not package.valid:
		result.valid = false
		result.errors.append("Invalid package format")
		return result
	
	var manifest = package.manifest
	
	# Check required fields
	var required_fields = ["format_version", "being_type", "consciousness_level", "contents"]
	for field in required_fields:
		if not manifest.has(field):
			result.errors.append("Missing required field: " + field)
			result.valid = false
	
	# Validate consciousness level
	if manifest.has("consciousness_level"):
		var level = manifest.consciousness_level
		if level < 1 or level > 10:
			result.errors.append("Invalid consciousness level: " + str(level))
			result.valid = false
	
	return result

func _test_component_compatibility(package_path: String) -> Dictionary:
	"""Test if components work with current system"""
	var result = {"warnings": []}
	
	var package = ZipPackageManager.load_package(package_path)
	var manifest = package.manifest
	
	# Check Godot version compatibility
	if manifest.has("godot_version"):
		var required_version = manifest.godot_version
		var current_version = Engine.get_version_info()
		if not _is_version_compatible(required_version, current_version):
			result.warnings.append("Version mismatch: requires Godot " + required_version)
	
	# Check dependencies
	if manifest.has("dependencies"):
		for dep in manifest.dependencies:
			if not _is_package_available(dep):
				result.warnings.append("Missing dependency: " + dep)
	
	return result

func _test_performance_impact(package_path: String) -> Dictionary:
	"""Measure performance impact of package"""
	var result = {"score": 100}
	
	# Simulate loading
	var start_time = Time.get_ticks_usec()
	var package = ZipPackageManager.load_package(package_path)
	var load_time = Time.get_ticks_usec() - start_time
	
	# Score based on load time (ms)
	if load_time > 100000: # >100ms
		result.score -= 20
	elif load_time > 50000: # >50ms
		result.score -= 10
	
	# Check script complexity
	if package.files.size() > 50:
		result.score -= 10
	
	return result

func _test_memory_footprint(package_path: String) -> Dictionary:
	"""Calculate memory usage of package"""
	var result = {"size": 0}
	
	var file = FileAccess.open(package_path, FileAccess.READ)
	if file:
		result.size = file.get_length() / 1048576 # Convert to MB
		file.close()
	
	return result

## MEMORY OPTIMIZATION ==================================================

func queue_package_load(package_path: String, priority: int = 0) -> void:
	"""Queue package for optimized loading"""
	if package_path in active_packages:
		return # Already loaded
	
	# Add to queue with priority
	loading_queue.append({
		"path": package_path,
		"priority": priority,
		"queued_at": Time.get_ticks_msec()
	})
	
	# Sort by priority
	loading_queue.sort_custom(_sort_by_priority)

func _process_loading_queue() -> void:
	"""Process one item from loading queue"""
	if loading_queue.is_empty():
		return
	
	var item = loading_queue.pop_front()
	_load_package_async(item.path, item.priority)

func _load_package_async(package_path: String, priority: int) -> void:
	"""Asynchronously load package with memory management"""
	# Check memory before loading
	if not _ensure_memory_available(package_path):
		package_failed.emit(package_path, "Insufficient memory")
		return
	
	# Test package first
	var test_results = test_package(package_path)
	if not test_results.valid:
		package_failed.emit(package_path, "Validation failed: " + str(test_results.errors))
		return
	
	# Load package
	var package = ZipPackageManager.load_package(package_path)
	if package.valid:
		_register_package(package_path, package, priority)
		package_loaded.emit(package_path)

func _ensure_memory_available(package_path: String) -> bool:
	"""Ensure enough memory for new package"""
	var required_size = _estimate_package_size(package_path)
	
	# Check if we need to free memory
	while total_memory_used + required_size > CACHE_SIZE_MB * 1048576:
		if not _evict_least_used_package():
			return false # Can't free enough memory
	
	return true

func _evict_least_used_package() -> bool:
	"""Remove least recently used package from cache"""
	var oldest_time = INF
	var oldest_path = ""
	
	for path in package_cache:
		var metadata = package_cache[path]
		if metadata.last_accessed < oldest_time and metadata.state == PackageState.CACHED:
			oldest_time = metadata.last_accessed
			oldest_path = path
	
	if oldest_path != "":
		_unload_package(oldest_path)
		return true
	
	return false

func _register_package(path: String, package: Dictionary, priority: int) -> void:
	"""Register loaded package in memory system"""
	var metadata = PackageMetadata.new()
	metadata.path = path
	metadata.manifest = package.manifest
	metadata.state = PackageState.LOADED
	metadata.last_accessed = Time.get_ticks_msec()
	metadata.priority = priority
	metadata.memory_size = _calculate_package_memory(package)
	
	active_packages[path] = metadata
	total_memory_used += metadata.memory_size
	
	# Check memory warning threshold
	var usage_percent = float(total_memory_used) / (CACHE_SIZE_MB * 1048576) * 100
	if usage_percent > 80:
		memory_warning.emit(usage_percent)

## PERFORMANCE OPTIMIZATION ==================================================

func preload_being_dependencies(being: UniversalBeing) -> void:
	"""Intelligent preloading based on being type and evolution paths"""
	var current_type = being.being_type
	var evolution_paths = being.evolution_state.can_become if being.has("evolution_state") else []
	
	# Preload current type packages
	var type_packages = _get_packages_for_type(current_type)
	for package in type_packages:
		queue_package_load(package, PackagePriority.HIGH)
	
	# Preload potential evolution packages
	for evolution_type in evolution_paths:
		var evo_packages = _get_packages_for_type(evolution_type)
		for package in evo_packages:
			queue_package_load(package, PackagePriority.MEDIUM)

func optimize_for_60fps() -> void:
	"""Ensure loading doesn't impact frame rate"""
	# Dynamic load budget based on frame time
	var current_fps = Engine.get_frames_per_second()
	if current_fps < 55:
		LOAD_TIME_BUDGET_MS = 1.0 # Reduce loading time
	elif current_fps > 58:
		LOAD_TIME_BUDGET_MS = 3.0 # Can afford more loading

func get_performance_metrics() -> Dictionary:
	"""Real-time performance data for monitoring"""
	return {
		"active_packages": active_packages.size(),
		"cached_packages": package_cache.size(),
		"memory_used_mb": total_memory_used / 1048576,
		"memory_percent": float(total_memory_used) / (CACHE_SIZE_MB * 1048576) * 100,
		"loading_queue_size": loading_queue.size(),
		"current_fps": Engine.get_frames_per_second()
	}

## HELPER FUNCTIONS ==================================================

func _initialize_memory_pools() -> void:
	"""Setup memory management systems"""
	# Reserve memory pools
	active_packages.clear()
	package_cache.clear()
	loading_queue.clear()
	total_memory_used = 0

func _sort_by_priority(a: Dictionary, b: Dictionary) -> bool:
	return a.priority > b.priority

func _estimate_package_size(path: String) -> int:
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var size = file.get_length()
		file.close()
		return size * 2 # Estimate 2x for loaded state
	return 0

func _calculate_package_memory(package: Dictionary) -> int:
	# Rough estimation based on content
	var size = 0
	size += str(package.manifest).length()
	for file in package.files.values():
		size += str(file).length()
	return size * 2 # Account for overhead

func _is_version_compatible(required: String, current: Dictionary) -> bool:
	# Simple version check
	return true # TODO: Implement proper version comparison

func _is_package_available(package_name: String) -> bool:
	return package_name in active_packages or package_name in package_cache

func _get_packages_for_type(being_type: String) -> Array[String]:
	# Scan libraries for type-specific packages
	var packages: Array[String] = []
	var libraries = ZipPackageManager.scan_libraries()
	
	for lib_name in libraries:
		for package_path in libraries[lib_name]:
			if package_path.contains(being_type.to_lower()):
				packages.append(package_path)
	
	return packages

func _analyze_dna_requirements(dna: Dictionary) -> Array[String]:
	"""Extract package requirements from Logic DNA"""
	var required: Array[String] = []
	
	# Check components
	if dna.has("components"):
		for comp_name in dna.components:
			var comp = dna.components[comp_name]
			if comp.has("package"):
				required.append(comp.package)
	
	# Check evolution paths
	if dna.has("evolution_paths"):
		for evo_type in dna.evolution_paths:
			required.append_array(_get_packages_for_type(evo_type))
	
	return required

func _on_pentagon_state_changed(being: UniversalBeing, new_state: int) -> void:
	"""React to Pentagon state changes"""
	match new_state:
		Pentagon.ProcessState.INIT:
			preload_being_dependencies(being)
		Pentagon.ProcessState.SEWERS:
			# Clean up being's packages
			_cleanup_being_packages(being)

func _cleanup_being_packages(being: UniversalBeing) -> void:
	"""Clean up packages when being enters SEWERS state"""
	if being.has_meta("loaded_packages"):
		var packages = being.get_meta("loaded_packages", [])
		for package_path in packages:
			if package_path in active_packages:
				var metadata = active_packages[package_path]
				metadata.priority -= 1 # Reduce priority
				if metadata.priority <= 0:
					_move_to_cache(package_path)

func _move_to_cache(package_path: String) -> void:
	"""Move package from active to cache"""
	if package_path in active_packages:
		var metadata = active_packages[package_path]
		metadata.state = PackageState.CACHED
		package_cache[package_path] = metadata
		active_packages.erase(package_path)

func _unload_package(package_path: String) -> void:
	"""Completely unload package from memory"""
	if package_path in package_cache:
		var metadata = package_cache[package_path]
		total_memory_used -= metadata.memory_size
		package_cache.erase(package_path)
	elif package_path in active_packages:
		var metadata = active_packages[package_path]
		total_memory_used -= metadata.memory_size
		active_packages.erase(package_path)

## Priority levels for package loading
class PackagePriority:
	const CRITICAL = 100
	const HIGH = 75
	const MEDIUM = 50
	const LOW = 25
	const BACKGROUND = 0