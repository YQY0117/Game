extends GdUnitTestSuite
class_name PerformanceProfilingTest

var _profiler: PerformanceProfiler

func before_test() -> void:
	_profiler = PerformanceProfiler.new()

func after_test() -> void:
	_profiler.free()

func test_start_profiling() -> void:
	_profiler.start_profiling()
	assert_bool(_profiler.is_profiling()).is_true()

func test_stop_profiling() -> void:
	_profiler.start_profiling()
	var report := _profiler.stop_profiling()
	assert_bool(_profiler.is_profiling()).is_false()
	assert_bool(report.has("total_time")).is_true()

func test_report_structure() -> void:
	_profiler.start_profiling()
	var report := _profiler.stop_profiling()
	assert_bool(report.has("avg_fps")).is_true()
	assert_bool(report.has("min_fps")).is_true()
	assert_bool(report.has("max_fps")).is_true()
	assert_bool(report.has("avg_memory_mb")).is_true()

func test_profiling_signal() -> void:
	var started_count := 0
	_profiler.profiling_started.connect(func(): started_count += 1)
	_profiler.start_profiling()
	assert_int(started_count).is_equal(1)