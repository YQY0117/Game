class_name ObjectPool
extends Node

var _pool: Array[Node] = []
var _scene: PackedScene
var _initial_size: int
var _max_size: int

func _init(scene: PackedScene, initial_size: int, max_size: int) -> void:
	_scene = scene
	_initial_size = initial_size
	_max_size = max_size
	_preallocate()

func _preallocate() -> void:
	for i in _initial_size:
		var instance := _scene.instantiate()
		instance.visible = false
		instance.set_process(false)
		instance.set_physics_process(false)
		add_child(instance)
		_pool.append(instance)

func get_instance() -> Node:
	if _pool.is_empty():
		if get_child_count() < _max_size:
			var instance := _scene.instantiate()
			add_child(instance)
			return instance
		else:
			return null
	
	var instance := _pool.pop_back()
	instance.visible = true
	instance.set_process(true)
	instance.set_physics_process(true)
	return instance

func return_instance(instance: Node) -> void:
	if instance == null:
		return
	instance.visible = false
	instance.set_process(false)
	instance.set_physics_process(false)
	instance.position = Vector2(-1000, -1000)
	_disconnect_signals(instance)
	_pool.append(instance)

func return_all() -> void:
	for child in get_children():
		if child.visible:
			return_instance(child)

func _disconnect_signals(instance: Node) -> void:
	if instance.has_signal("damage_dealt"):
		for connection in instance.get_signal_connection_list("damage_dealt"):
			instance.damage_dealt.disconnect(connection["callable"])
	if instance.has_signal("entity_died"):
		for connection in instance.get_signal_connection_list("entity_died"):
			instance.entity_died.disconnect(connection["callable"])

func get_available_count() -> int:
	return _pool.size()

func get_total_count() -> int:
	return get_child_count()

func monitor() -> void:
	var available := get_available_count()
	var total := get_total_count()
	print("[Pool] Available: %d/%d" % [available, total])