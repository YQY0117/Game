# GdUnit4 test runner — invoked by CI and /smoke-check
# Usage: godot --headless -s tests/gdunit4_runner.gd -- -a tests/unit -a tests/integration
extends SceneTree

var _cli_runner: GdUnitTestCIRunner

func _initialize() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
	_cli_runner = GdUnitTestCIRunner.new()
	root.add_child(_cli_runner)

func _finalize() -> void:
	queue_delete(_cli_runner)
