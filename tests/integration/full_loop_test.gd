extends GdUnitTestSuite
class_name FullLoopTest

var _player: PlayerController
var _camera: CameraController
var _hud: HUD
var _realm_progression: RealmProgression
var _technique_manager: TechniqueManager
var _wave_manager: WaveManager

func before_test() -> void:
	_player = PlayerController.new()
	_camera = CameraController.new()
	_hud = HUD.new()
	_realm_progression = RealmProgression.new()
	_technique_manager = TechniqueManager.new()
	_wave_manager = WaveManager.new()
	
	_camera.set_target(_player)
	_realm_progression.set_player(_player)
	_technique_manager.set_owner(_player)
	_wave_manager.set_player(_player)

func after_test() -> void:
	_player.free()
	_camera.free()
	_hud.free()
	_realm_progression.free()
	_technique_manager.free()
	_wave_manager.free()

func test_initial_state() -> void:
	assert_str(_player.get_current_state()).is_equal("idle")
	assert_int(_realm_progression.get_current_realm()).is_equal(1)
	assert_float(_hud.get_current_alpha()).is_equal(0.35)

func test_combat_flow() -> void:
	_hud.enter_combat()
	assert_float(_hud._target_alpha).is_equal(1.0)

func test_breakthrough_flow() -> void:
	_realm_progression.add_spirit(100.0)
	assert_bool(_realm_progression.is_breaking_through()).is_true()
	_realm_progression._update_breakthrough(1.21)
	assert_int(_realm_progression.get_current_realm()).is_equal(2)

func test_wave_system() -> void:
	_wave_manager.start_waves()
	assert_int(_wave_manager.get_current_wave()).is_equal(1)