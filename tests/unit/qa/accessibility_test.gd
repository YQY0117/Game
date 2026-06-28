extends GdUnitTestSuite
class_name AccessibilityTest

var _tester: AccessibilityTester

func before_test() -> void:
	_tester = AccessibilityTester.new()

func after_test() -> void:
	_tester.free()

func test_run_accessibility_tests() -> void:
	var report := _tester.run_accessibility_tests()
	assert_bool(report.has("keyboard_navigation")).is_true()
	assert_bool(report.has("color_contrast")).is_true()
	assert_bool(report.has("font_size")).is_true()
	assert_bool(report.has("screen_reader")).is_true()

func test_keyboard_navigation_pass() -> void:
	var report := _tester.run_accessibility_tests()
	assert_str(report["keyboard_navigation"]["status"]).is_equal("pass")

func test_color_contrast_pass() -> void:
	var report := _tester.run_accessibility_tests()
	assert_str(report["color_contrast"]["status"]).is_equal("pass")

func test_font_size_pass() -> void:
	var report := _tester.run_accessibility_tests()
	assert_str(report["font_size"]["status"]).is_equal("pass")

func test_test_completed_signal() -> void:
	var completed_count := 0
	_tester.test_completed.connect(func(report): completed_count += 1)
	_tester.run_accessibility_tests()
	assert_int(completed_count).is_equal(1)