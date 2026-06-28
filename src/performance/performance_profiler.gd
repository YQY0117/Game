class_name PerformanceProfiler
extends Node

signal profiling_started()
signal profiling_completed(report: Dictionary)

var _is_profiling: bool = false
var _start_time: float = 0.0
var _frame_times: Array[float] = []
var _memory_samples: Array[float] = []
var _sample_interval: float = 1.0
var _sample_timer: float = 0.0

func _process(delta: float) -> void:
	if not _is_profiling:
		return
	_frame_times.append(delta)
	_sample_timer += delta
	if _sample_timer >= _sample_interval:
		_sample_timer = 0.0
		_memory_samples.append(OS.get_memory_info().physical)

func start_profiling() -> void:
	_is_profiling = true
	_start_time = Time.get_ticks_msec()
	_frame_times.clear()
	_memory_samples.clear()
	profiling_started.emit()

func stop_profiling() -> Dictionary:
	_is_profiling = false
	var report := _generate_report()
	profiling_completed.emit(report)
	return report

func _generate_report() -> Dictionary:
	var total_time := (Time.get_ticks_msec() - _start_time) / 1000.0
	var avg_fps := 0.0
	var min_fps := 999.0
	var max_fps := 0.0
	
	if _frame_times.size() > 0:
		for ft in _frame_times:
			var fps := 1.0 / ft if ft > 0 else 0.0
			avg_fps += fps
			min_fps = min(min_fps, fps)
			max_fps = max(max_fps, fps)
		avg_fps /= _frame_times.size()
	
	var avg_memory := 0.0
	if _memory_samples.size() > 0:
		for mem in _memory_samples:
			avg_memory += mem
		avg_memory /= _memory_samples.size()
	
	return {
		"total_time": total_time,
		"frame_count": _frame_times.size(),
		"avg_fps": avg_fps,
		"min_fps": min_fps,
		"max_fps": max_fps,
		"avg_memory_mb": avg_memory / 1024.0 / 1024.0,
		"sample_count": _memory_samples.size()
	}

func is_profiling() -> bool:
	return _is_profiling