# GdUnit4 test runner — invoked by CI and /smoke-check
# Usage: godot --headless --script tests/gdunit4_runner.gd -- -a tests/unit -a tests/integration --ignoreHeadlessMode
extends SceneTree

func _init() -> void:
    var runner_script = load("res://addons/gdUnit4/src/core/runners/GdUnitTestCIRunner.gd")
    if runner_script == null:
        push_error("GdUnit4 not found. Install via AssetLib or addons/.")
        quit(1)
        return
    var runner = runner_script.new()
    runner.add_test_suite("res://tests/unit")
    runner.add_test_suite("res://tests/integration")
    runner.check_headless_mode()
    runner.init_runner()
