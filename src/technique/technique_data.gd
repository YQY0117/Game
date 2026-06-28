class_name TechniqueData
extends Resource

enum Element {
	FIRE,
	ICE,
	WIND,
	LIGHTNING,
	SWORD,
	FIST
}

@export var id: String = ""
@export var display_name: String = ""
@export var element: Element = Element.FIRE
@export var cooldown: float = 1.0
@export var base_damage: float = 5.0
@export var projectile_type: String = "default"
@export var projectile_speed: float = 300.0
@export var projectile_count: int = 1
@export var spread_angle: float = 0.0

func get_element_name() -> String:
	match element:
		Element.FIRE:
			return "fire"
		Element.ICE:
			return "ice"
		Element.WIND:
			return "wind"
		Element.LIGHTNING:
			return "lightning"
		Element.SWORD:
			return "sword"
		Element.FIST:
			return "fist"
	return "fire"