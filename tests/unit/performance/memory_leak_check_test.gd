extends GdUnitTestSuite
class_name MemoryLeakCheckTest

var _checker: MemoryLeakChecker

func before_test() -> void:
	_checker = MemoryLeakChecker.new()

func after_test() -> void:
	_checker.free()

func test_start_check() -> void:
	_checker.start_check(10.0)
	assert_bool(_checker.is_checking()).is_true()

func test_check_duration() -> void:
	_checker.start_check(5.0)
	assert_float(_checker._check_duration).is_equal(5.0)

func test_leak_threshold() -> void:
	assert_float(_checker._leak_threshold_mb).is_equal(10.0)

func test_report_generation() -> void:
	_checker._memory_samples = [100.0, 105.0, 110.0]
	var report := _checker._generate_report()
	assert_str(report["status"]).is_equal("stable")
	assert_float(report["growth_mb"]).is_equal(10.0)

func test_leak_detection() -> void:
	_checker._memory_samples = [100.0, 120.0]
	var report := _checker._generate_report()
	assert_str(report["status"]).is_equal("leak_detected")