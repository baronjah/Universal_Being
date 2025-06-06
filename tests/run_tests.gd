#!/usr/bin/env -S godot --headless --script
extends SceneTree

# Universal Being Test Runner
# Usage: godot --headless --script run_tests.gd

func _init():
	print("\n🚀 Universal Being Test Suite")
	print("=".repeat(60))
	
	var total_tests = 0
	var total_passed = 0
	var total_failed = 0
	var test_results = []
	
	# Test all beings
	var beings_to_test = [
		preload("res://scripts/button_universal_being.gd"),
		# Add more beings here as they're created
	]
	
	for being_script in beings_to_test:
		var results = UniversalBeingTestFramework.test_being(being_script)
		test_results.append(results)
		total_tests += results.total
		total_passed += results.passed
		total_failed += results.failed
	
	# Summary
	print("\n" + "=".repeat(60))
	print("📊 OVERALL TEST SUMMARY")
	print("=".repeat(60))
	print("Total Tests Run: %d" % total_tests)
	print("✅ Total Passed: %d" % total_passed)
	print("❌ Total Failed: %d" % total_failed)
	print("Success Rate: %.1f%%" % (float(total_passed) / float(total_tests) * 100.0))
	
	# Detailed results
	if total_failed > 0:
		print("\n❌ FAILED TESTS:")
		for result in test_results:
			for detail in result.details:
				if not detail.passed:
					print("   - %s: %s" % [detail.test, detail.assertion])
	
	# Exit with appropriate code
	quit(0 if total_failed == 0 else 1)