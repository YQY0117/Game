extends GdUnitTestSuite
class_name RunSessionStateTest

var _session: RunSession
var _state_changes: Array[Array]

func before_test() -> void:
	_session = RunSession.new()
	_state_changes = []
	_session.run_state_changed.connect(_on_state_changed)

func after_test() -> void:
	_session.run_state_changed.disconnect(_on_state_changed)
	_session.free()

func _on_state_changed(old_state: String, new_state: String) -> void:
	_state_changes.append([old_state, new_state])

func test_initial_state_is_menu() -> void:
	assert_int(_session.get_current_state()).is_equal(RunSession.RunState.MENU)

func test_start_new_run_transitions_to_loading_then_playing() -> void:
	_session.start_new_run()
	assert_int(_session.get_current_state()).is_equal(RunSession.RunState.LOADING)
	await get_tree().create_timer(0.2).timeout
	assert_int(_session.get_current_state()).is_equal(RunSession.RunState.PLAYING)
	assert_int(_state_changes.size()).is_equal(2)
	assert_str(_state_changes[0][0]).is_equal("MENU")
	assert_str(_state_changes[0][1]).is_equal("LOADING")
	assert_str(_state_changes[1][0]).is_equal("LOADING")
	assert_str(_state_changes[1][1]).is_equal("PLAYING")

func test_pause_game_from_playing() -> void:
	_session.set_run_state(RunSession.RunState.PLAYING)
	_session.pause_game()
	assert_int(_session.get_current_state()).is_equal(RunSession.RunState.PAUSED)

func test_resume_game_from_paused() -> void:
	_session.set_run_state(RunSession.RunState.PAUSED)
	_session.resume_game()
	assert_int(_session.get_current_state()).is_equal(RunSession.RunState.PLAYING)

func test_pause_not_allowed_from_non_playing() -> void:
	_session.set_run_state(RunSession.RunState.MENU)
	_session.pause_game()
	assert_int(_session.get_current_state()).is_equal(RunSession.RunState.MENU)

func test_resume_not_allowed_from_non_paused() -> void:
	_session.set_run_state(RunSession.RunState.PLAYING)
	_session.resume_game()
	assert_int(_session.get_current_state()).is_equal(RunSession.RunState.PLAYING)

func test_trigger_death_from_playing() -> void:
	_session.set_run_state(RunSession.RunState.PLAYING)
	_session.trigger_death()
	assert_int(_session.get_current_state()).is_equal(RunSession.RunState.DYING)

func test_trigger_death_not_allowed_from_non_playing() -> void:
	_session.set_run_state(RunSession.RunState.MENU)
	_session.trigger_death()
	assert_int(_session.get_current_state()).is_equal(RunSession.RunState.MENU)

func test_death_transitions_to_dead_after_timer() -> void:
	_session.set_run_state(RunSession.RunState.PLAYING)
	_session.trigger_death()
	assert_int(_session.get_current_state()).is_equal(RunSession.RunState.DYING)
	await get_tree().create_timer(2.1).timeout
	assert_int(_session.get_current_state()).is_equal(RunSession.RunState.DEAD)

func test_trigger_victory_from_playing() -> void:
	_session.set_run_state(RunSession.RunState.PLAYING)
	_session.trigger_victory()
	assert_int(_session.get_current_state()).is_equal(RunSession.RunState.VICTORY)

func test_trigger_breakthrough_from_playing() -> void:
	_session.set_run_state(RunSession.RunState.PLAYING)
	_session.trigger_breakthrough()
	assert_int(_session.get_current_state()).is_equal(RunSession.RunState.BREAKTHROUGH)

func test_return_to_menu() -> void:
	_session.set_run_state(RunSession.RunState.PLAYING)
	_session.return_to_menu()
	assert_int(_session.get_current_state()).is_equal(RunSession.RunState.MENU)

func test_state_change_signal_emitted() -> void:
	_session.set_run_state(RunSession.RunState.LOADING)
	assert_int(_state_changes.size()).is_equal(1)
	assert_str(_state_changes[0][0]).is_equal("MENU")
	assert_str(_state_changes[0][1]).is_equal("LOADING")