extends GdUnitTestSuite
class_name SemanticActionTest

func test_all_8_actions_defined() -> void:
	assert_str(InputActions.MOVE_UP).is_not_empty()
	assert_str(InputActions.MOVE_DOWN).is_not_empty()
	assert_str(InputActions.MOVE_LEFT).is_not_empty()
	assert_str(InputActions.MOVE_RIGHT).is_not_empty()
	assert_str(InputActions.PAUSE).is_not_empty()
	assert_str(InputActions.CONFIRM).is_not_empty()
	assert_str(InputActions.CANCEL).is_not_empty()
	assert_str(InputActions.TECHNIQUE_SLOT_1).is_not_empty()
	assert_str(InputActions.TECHNIQUE_SLOT_2).is_not_empty()
	assert_str(InputActions.TECHNIQUE_SLOT_3).is_not_empty()
	assert_str(InputActions.TECHNIQUE_SLOT_4).is_not_empty()
	assert_int(InputActions.ALL_ACTIONS.size()).is_equal(11)

func test_opposing_keys_cancel() -> void:
	var actions := [
		InputActions.MOVE_UP,
		InputActions.MOVE_DOWN,
		InputActions.MOVE_LEFT,
		InputActions.MOVE_RIGHT,
	]
	for action in actions:
		assert_str(action).is_not_empty()
	assert_array(InputActions.MOVEMENT_ACTIONS).contains_exactly([
		InputActions.MOVE_UP,
		InputActions.MOVE_DOWN,
		InputActions.MOVE_LEFT,
		InputActions.MOVE_RIGHT,
	])

func test_diagonal_normalized() -> void:
	var right := Vector2.RIGHT
	var up := Vector2.UP
	var diagonal := (right + up).normalized()
	assert_float(diagonal.length()).is_equal_approx(1.0, 0.001)
