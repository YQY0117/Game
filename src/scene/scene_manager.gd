class_name SceneManager
extends Node

signal transition_started()
signal transition_completed()

const COVER_DURATION := 0.3
const DISSIPATE_DURATION := 0.2

var _transition_layer: CanvasLayer
var _cover_rect: ColorRect
var _is_transitioning: bool = false

func _ready() -> void:
	_setup_transition_layer()

func _setup_transition_layer() -> void:
	_transition_layer = CanvasLayer.new()
	_transition_layer.layer = 100
	add_child(_transition_layer)
	
	_cover_rect = ColorRect.new()
	_cover_rect.color = Color.BLACK
	_cover_rect.anchor_right = 1.0
	_cover_rect.anchor_bottom = 1.0
	_cover_rect.offset_right = 0.0
	_cover_rect.offset_bottom = 0.0
	_cover_rect.visible = false
	_transition_layer.add_child(_cover_rect)

func change_scene(scene_path: String) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	transition_started.emit()
	await _play_cover_animation()
	get_tree().change_scene_to_file(scene_path)
	await _play_dissipate_animation()
	_is_transitioning = false
	transition_completed.emit()

func _play_cover_animation() -> void:
	_cover_rect.visible = true
	_cover_rect.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(_cover_rect, "modulate:a", 1.0, COVER_DURATION)
	await tween.finished

func _play_dissipate_animation() -> void:
	var tween := create_tween()
	tween.tween_property(_cover_rect, "modulate:a", 0.0, DISSIPATE_DURATION)
	await tween.finished
	_cover_rect.visible = false

func start_new_run() -> void:
	await change_scene("res://src/battle.tscn")

func return_to_menu() -> void:
	await change_scene("res://src/menu.tscn")