class_name StoreMetadataGenerator
extends Node

signal metadata_generated(metadata: Dictionary)

var _game_title: String = "墨境修仙"
var _game_description: String = "一款水墨风格的修仙幸存者游戏"
var _tags: Array[String] = ["roguelike", "survivor", "cultivation", "ink-painting"]
var _screenshots: Array[String] = []

func generate_metadata() -> Dictionary:
	var metadata := {
		"title": _game_title,
		"description": _game_description,
		"tags": _tags,
		"screenshots": _screenshots,
		"version": "1.0.0",
		"platform": "web",
		"genre": "action roguelike",
		"features": [
			"水墨风格画面",
			"修仙题材",
			"幸存者玩法",
			"功法系统",
			"境界突破"
		]
	}
	metadata_generated.emit(metadata)
	return metadata

func set_title(title: String) -> void:
	_game_title = title

func set_description(description: String) -> void:
	_game_description = description

func add_tag(tag: String) -> void:
	if not _tags.has(tag):
		_tags.append(tag)

func add_screenshot(path: String) -> void:
	if not _screenshots.has(path):
		_screenshots.append(path)

func get_metadata() -> Dictionary:
	return {
		"title": _game_title,
		"description": _game_description,
		"tags": _tags,
		"screenshots": _screenshots
	}