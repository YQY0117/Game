class_name MemoryLeakChecker
extends Node

signal leak_detected(leak_info: Dictionary)
signal check_completed(report: Dictionary)

var _is_checking: bool = false
var _check_duration: float = 1800.0
var _check_timer: float = 0.0
var _memory_samples: Array[float] = []
var _sample_interval: float = 10.0
var _sample_timer: float = 0.0
var _leak_threshold_mb: float = 10.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if not _is_checking:
		return
	_check_timer += delta
	_sample_timer += delta
	if _sample_timer >= _sample_interval:
		_sample_timer = 0.0
		var memory_mb := OS.get_memory_info().physical / 1024.0 / 1024.0
		_memory_samples.append(memory_mb)
		_check_for_leaks()
	if _check_timer >= _check_duration:
		_complete_check()

func start_check(duration: float = 1800.0) -> void:
	_is_checking = true
	_check_duration = duration
	_check_timer = 0.0
	_sample_timer = 0.0
	_memory_samples.clear()

func _check_for_leaks() -> void:
	if _memory_samples.size() < 2:
		return
	var first_sample := _memory_samples[0]
	var last_sample := _memory_samples[_memory_samples.size() - 1]
	var growth := last_sample - first_sample
	if growth > _leak_threshold_mb:
		leak_detected.emit({
			"growth_mb": growth,
			"first_sample": first_sample,
			"last_sample": last_sample,
			"sample_count": _memory_samples.size()
		})

func _complete_check() -> void:
	_is_checking = false
	var report := _generate_report()
	check_completed.emit(report)

func _generate_report() -> Dictionary:
	if _memory_samples.is_empty():
		return {"status": "no_data"}
	
	var first_sample := _memory_samples[0]
	var last_sample := _memory_samples[_memory_samples.size() - 1]
	var growth := last_sample - first_sample
	var max_memory := 0.0
	var min_memory := 999999.0
	for mem in _memory_samples:
		max_memory = max(max_memory, mem)
		min_memory = min(min_memory, mem)
	
	return {
		"status": "leak_detected" if growth > _leak_threshold_mb else "stable",
		"growth_mb": growth,
		"first_sample_mb": first_sample,
		"last_sample_mb": last_sample,
		"max_memory_mb": max_memory,
		"min_memory_mb": min_memory,
		"sample_count": _memory_samples.size(),
		"check_duration": _check_duration
	}

func is_checking() -> bool:
	return _is_checking