extends GdUnitTestSuite
class_name AutoBreakthroughTest

var _progression: RealmProgression

func before_test() -> void:
	_progression = RealmProgression.new()

func after_test() -> void:
	_progression.free()

func test_auto_breakthrough_at_100() -> void:
	_progression.add_spirit(99.0)
	assert_bool(_progression.is_breaking_through()).is_false()
	_progression.add_spirit(1.0)
	assert_bool(_progression.is_breaking_through()).is_true()

func test_no_absorption_during_breakthrough() -> void:
	_progression.add_spirit(100.0)
	assert_bool(_progression.is_breaking_through()).is_true()
	_progression.add_spirit(50.0)
	assert_float(_progression.get_spirit_progress()).is_equal(0.0)

func test_spirit_resets_after_breakthrough() -> void:
	_progression.add_spirit(100.0)
	_progression._update_breakthrough(1.21)
	assert_float(_progression.get_spirit_progress()).is_equal(0.0)
	assert_bool(_progression.is_breaking_through()).is_false()

func test_multiple_breakthroughs() -> void:
	_progression.add_spirit(100.0)
	_progression._update_breakthrough(1.21)
	assert_int(_progression.get_current_realm()).is_equal(2)
	_progression.add_spirit(100.0)
	_progression._update_breakthrough(1.21)
	assert_int(_progression.get_current_realm()).is_equal(3)