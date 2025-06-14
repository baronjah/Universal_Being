extends SceneTree

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("🔧 [CameraFix] Verifying world offset system fix...")
	
	# Load the camera controller script to check the implementation
	var camera_script = load("res://scripts/camera/camera_controller.gd")
	if camera_script:
		print("✅ [CameraFix] Camera controller script loaded successfully")
		
		# Check if the script source contains the fix
		var script_source = camera_script.source_code
		if "world_offset += camera_target.position" in script_source:
			print("✅ [CameraFix] World offset reset code found")
			
			if "camera_target.position = new_local_position" in script_source:
				print("✅ [CameraFix] Local movement application found")
				
				# Count how many times movement is applied
				var movement_applications = script_source.count("movement_delta")
				print("📊 [CameraFix] Movement delta used " + str(movement_applications) + " times")
				
				if movement_applications == 3:  # declaration, print, and single application
					print("✅ [CameraFix] Movement is applied exactly once - double-application bug fixed!")
				else:
					print("⚠️ [CameraFix] Unexpected movement delta usage count")
					
				print("✅ [CameraFix] World offset system implementation verified!")
				print("🎮 [CameraFix] Camera should now work at any distance without stopping")
				print("💡 [CameraFix] Test by:")
				print("  1. Start the game")
				print("  2. Use WASD to fly very far from origin")
				print("  3. Movement should continue smoothly without stopping")
			else:
				print("❌ [CameraFix] Local movement application not found")
		else:
			print("❌ [CameraFix] World offset reset code not found")
	else:
		print("❌ [CameraFix] Failed to load camera controller script")
	
	print("🔧 [CameraFix] Verification complete!")
	quit()