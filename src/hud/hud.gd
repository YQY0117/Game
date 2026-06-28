class_name HUD
extends CanvasLayer

const IDLE_ALPHA := 0.35
const COMBAT_ALPHA := 1.0
const FADE_DURATION := 0.2
const POST_COMBAT_DELAY := 3.0
const HP_RING_RADIUS := 80.0
const HP_RING_CRITICAL_THRESHOLD := 0.15
const HP_RING_PULSE_INTERVAL := 1.2

var _realm_label: Label
var _spirit_bar: ProgressBar
var _technique_slots: HBoxContainer
var _boss_hp_bar: ProgressBar
var _hp_ring: Control
var _current_alpha: float = IDLE_ALPHA
var _target_alpha: float = IDLE_ALPHA
var _fade_timer: float = 0.0
var _is_fading: bool = false
var _post_combat_timer: float = 0.0
var _is_post_combat: bool = false
var _hp_ring_alpha: float = 0.0
var _hp_ring_pulse_timer: float = 0.0
var _is_hp_critical: bool = false

func _ready() -> void:
	_setup_hud_elements()
	_setup_connections()

func _setup_hud_elements() -> void:
	layer = 5
	
	var control := Control.new()
	control.name = "HUDControl"
	add_child(control)
	
	_realm_label = Label.new()
	_realm_label.name = "RealmLabel"
	_realm_label.text = "炼气"
	_realm_label.position = Vector2(20, 20)
	control.add_child(_realm_label)
	
	_spirit_bar = ProgressBar.new()
	_spirit_bar.name = "SpiritBar"
	_spirit_bar.position = Vector2(20, 60)
	_spirit_bar.size = Vector2(200, 20)
	control.add_child(_spirit_bar)
	
	_technique_slots = HBoxContainer.new()
	_technique_slots.name = "TechniqueSlots"
	_technique_slots.position = Vector2(20, 100)
	control.add_child(_technique_slots)
	
	_boss_hp_bar = ProgressBar.new()
	_boss_hp_bar.name = "BossHPBar"
	_boss_hp_bar.position = Vector2(20, 140)
	_boss_hp_bar.size = Vector2(200, 20)
	_boss_hp_bar.visible = false
	control.add_child(_boss_hp_bar)
	
	_hp_ring = Control.new()
	_hp_ring.name = "HPRing"
	control.add_child(_hp_ring)

func _setup_connections() -> void:
	pass

func _process(delta: float) -> void:
	if _is_fading:
		_update_fade(delta)
	if _is_post_combat:
		_update_post_combat(delta)
	if _is_hp_critical:
		_update_hp_ring_pulse(delta)

func _update_fade(delta: float) -> void:
	_fade_timer += delta
	var progress := clampf(_fade_timer / FADE_DURATION, 0.0, 1.0)
	_current_alpha = lerp(_current_alpha, _target_alpha, progress)
	modulate.a = _current_alpha
	if progress >= 1.0:
		_is_fading = false

func _update_post_combat(delta: float) -> void:
	_post_combat_timer -= delta
	if _post_combat_timer <= 0.0:
		_is_post_combat = false
		fade_to_idle()

func enter_combat() -> void:
	_is_post_combat = false
	_target_alpha = COMBAT_ALPHA
	_is_fading = true
	_fade_timer = 0.0

func exit_combat() -> void:
	_is_post_combat = true
	_post_combat_timer = POST_COMBAT_DELAY

func fade_to_idle() -> void:
	_target_alpha = IDLE_ALPHA
	_is_fading = true
	_fade_timer = 0.0

func update_realm(realm_name: String) -> void:
	if _realm_label:
		_realm_label.text = realm_name

func update_spirit(current: float, maximum: float) -> void:
	if _spirit_bar:
		_spirit_bar.max_value = maximum
		_spirit_bar.value = current

func update_boss_hp(current: float, maximum: float) -> void:
	if _boss_hp_bar:
		_boss_hp_bar.max_value = maximum
		_boss_hp_bar.value = current
		_boss_hp_bar.visible = true

func hide_boss_hp() -> void:
	if _boss_hp_bar:
		_boss_hp_bar.visible = false

func get_current_alpha() -> float:
	return _current_alpha

func update_player_hp(current: float, maximum: float) -> void:
	var ratio := current / maximum
	if ratio <= HP_RING_CRITICAL_THRESHOLD:
		if not _is_hp_critical:
			_is_hp_critical = true
			_hp_ring_alpha = 0.85
			_hp_ring_pulse_timer = 0.0
	else:
		_is_hp_critical = false
		_hp_ring_alpha = 0.0
	if _hp_ring:
		_hp_ring.modulate.a = _hp_ring_alpha

func _update_hp_ring_pulse(delta: float) -> void:
	_hp_ring_pulse_timer += delta
	var pulse := sin(_hp_ring_pulse_timer * TAU / HP_RING_PULSE_INTERVAL)
	_hp_ring_alpha = 0.85 + pulse * 0.15
	if _hp_ring:
		_hp_ring.modulate.a = clampf(_hp_ring_alpha, 0.0, 1.0)