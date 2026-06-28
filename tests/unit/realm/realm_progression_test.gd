extends GdUnitTestSuite
class_name RealmProgressionTest

var _progression: RealmProgression

func before_test() -> void:
	_progression = RealmProgression.new()

func after_test() -> void:
	_progression.free()

func test_initial_realm() -> void:
	assert_int(_progression.get_current_realm()).is_equal(1)
	assert_str(_progression.get_realm_name()).is_equal("炼气")

func test_add_spirit() -> void:
	_progression.add_spirit(50.0)
	assert_float(_progression.get_spirit_progress()).is_equal(50.0)

func test_breakthrough_triggers_at_100() -> void:
	var started_count := 0
	_progression.breakthrough_started.connect(func(): started_count += 1)
	_progression.add_spirit(100.0)
	assert_int(started_count).is_equal(1)
	assert_bool(_progression.is_breaking_through()).is_true()

func test_breakthrough_completes_after_duration() -> void:
	_progression.add_spirit(100.0)
	_progression._update_breakthrough(1.21)
	assert_int(_progression.get_current_realm()).is_equal(2)
	assert_str(_progression.get_realm_name()).is_equal("筑基")

func test_realm_changed_signal() -> void:
	var realm_changes: Array[int] = []
	_progression.realm_changed.connect(func(realm): realm_changes.append(realm))
	_progression.add_spirit(100.0)
	_progression._update_breakthrough(1.21)
	assert_int(realm_changes.size()).is_equal(1)
	assert_int(realm_changes[0]).is_equal(2)

func test_spirit_resets_after_breakthrough() -> void:
	_progression.add_spirit(100.0)
	_progression._update_breakthrough(1.21)
	assert_float(_progression.get_spirit_progress()).is_equal(0.0)

func test_max_realm_is_6() -> void:
	_progression._current_realm = 6
	_progression.add_spirit(100.0)
	assert_int(_progression.get_current_realm()).is_equal(6)

func test_realm_colors() -> void:
	assert_color(RealmProgression.REALM_COLORS[1]).is_equal(Color("#4A7C59"))
	assert_color(RealmProgression.REALM_COLORS[6]).is_equal(Color("#FFFFFF"))