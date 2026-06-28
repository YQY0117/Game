class_name RunSession
extends Node

signal run_state_changed(old_state: String, new_state: String)

enum RunState {
	MENU,
	LOADING,
	PLAYING,
	PAUSED,
	DYING,
	DEAD,
	VICTORY,
	TRANSITION,
	BREAKTHROUGH
}

var _current_state: RunState = RunState.MENU
var _death_timer: Timer

func _ready() -> void:
	_death_timer = Timer.new()
	_death_timer.one_shot = true
	_death_timer.timeout.connect(_on_death_timer_timeout)
	add_child(_death_timer)

func get_current_state() -> RunState:
	return _current_state

func get_current_state_name() -> String:
	return RunState.keys()[_current_state]

func set_run_state(new_state: RunState) -> void:
	if _current_state == new_state:
		return
	
	var old_state := _current_state
	_current_state = new_state
	
	match new_state:
		RunState.PAUSED:
			get_tree().paused = true
		RunState.PLAYING:
			get_tree().paused = false
	
	run_state_changed.emit(RunState.keys()[old_state], RunState.keys()[new_state])

func start_new_run() -> void:
	set_run_state(RunState.LOADING)
	await get_tree().create_timer(0.1).timeout
	set_run_state(RunState.PLAYING)

func pause_game() -> void:
	if _current_state == RunState.PLAYING:
		set_run_state(RunState.PAUSED)

func resume_game() -> void:
	if _current_state == RunState.PAUSED:
		set_run_state(RunState.PLAYING)

func trigger_death() -> void:
	if _current_state != RunState.PLAYING:
		return
	set_run_state(RunState.DYING)
	_death_timer.start(2.0)

func _on_death_timer_timeout() -> void:
	set_run_state(RunState.DEAD)

func trigger_victory() -> void:
	if _current_state == RunState.PLAYING:
		set_run_state(RunState.VICTORY)

func trigger_breakthrough() -> void:
	if _current_state == RunState.PLAYING:
		set_run_state(RunState.BREAKTHROUGH)

func return_to_menu() -> void:
	set_run_state(RunState.MENU)