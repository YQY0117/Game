class_name RealmProgression
extends Node

signal realm_changed(new_realm: int)
signal breakthrough_started()
signal breakthrough_completed()

enum Realm {
	REFINING_QI = 1,
	BUILDING_FOUNDATION = 2,
	GOLDEN_CORE = 3,
	NASCENT_SOUL = 4,
	MAHAYANA = 5,
	ASCENSION = 6
}

const REALM_COLORS := {
	Realm.REFINING_QI: Color("#4A7C59"),
	Realm.BUILDING_FOUNDATION: Color("#6B8E9B"),
	Realm.GOLDEN_CORE: Color("#C8A055"),
	Realm.NASCENT_SOUL: Color("#8B5CF6"),
	Realm.MAHAYANA: Color("#F59E0B"),
	Realm.ASCENSION: Color("#FFFFFF")
}

const REALM_NAMES := {
	Realm.REFINING_QI: "炼气",
	Realm.BUILDING_FOUNDATION: "筑基",
	Realm.GOLDEN_CORE: "金丹",
	Realm.NASCENT_SOUL: "元婴",
	Realm.MAHAYANA: "大乘",
	Realm.ASCENSION: "飞升"
}

const BREAKTHROUGH_DURATION := 1.2
const MAX_REALM := 6

var _current_realm: Realm = Realm.REFINING_QI
var _spirit_progress: float = 0.0
var _spirit_required: float = 100.0
var _is_breaking_through: bool = false
var _breakthrough_timer: float = 0.0
var _player: PlayerController
var _technique_manager: TechniqueManager
var _canvas_modulate: CanvasModulate

func _ready() -> void:
	_setup_connections()

func _setup_connections() -> void:
	pass

func set_player(player: PlayerController) -> void:
	_player = player

func set_technique_manager(manager: TechniqueManager) -> void:
	_technique_manager = manager

func set_canvas_modulate(modulate: CanvasModulate) -> void:
	_canvas_modulate = modulate
	_apply_realm_color()

func _physics_process(delta: float) -> void:
	if _is_breaking_through:
		_update_breakthrough(delta)

func add_spirit(amount: float) -> void:
	if _is_breaking_through:
		return
	_spirit_progress += amount
	if _spirit_progress >= _spirit_required:
		_start_breakthrough()

func _start_breakthrough() -> void:
	if _current_realm >= MAX_REALM:
		return
	_is_breaking_through = true
	_breakthrough_timer = 0.0
	breakthrough_started.emit()
	if _player:
		_player.set_immobile(true)

func _update_breakthrough(delta: float) -> void:
	_breakthrough_timer += delta
	if _breakthrough_timer >= BREAKTHROUGH_DURATION:
		_complete_breakthrough()

func _complete_breakthrough() -> void:
	_is_breaking_through = false
	_spirit_progress = 0.0
	_current_realm = clampi(_current_realm + 1, 1, MAX_REALM) as Realm
	_apply_realm_color()
	realm_changed.emit(_current_realm)
	breakthrough_completed.emit()
	if _player:
		_player.set_realm(_current_realm)
		_player.set_immobile(false)
	if _technique_manager:
		_technique_manager.equip_technique(_current_realm - 1, null)

func _apply_realm_color() -> void:
	if _canvas_modulate:
		_canvas_modulate.color = REALM_COLORS.get(_current_realm, Color.WHITE)

func get_current_realm() -> int:
	return _current_realm

func get_realm_name() -> String:
	return REALM_NAMES.get(_current_realm, "炼气")

func get_spirit_progress() -> float:
	return _spirit_progress

func get_spirit_required() -> float:
	return _spirit_required

func is_breaking_through() -> bool:
	return _is_breaking_through