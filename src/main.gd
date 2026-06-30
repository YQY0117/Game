extends Node2D

var player: CharacterBody2D
var camera: Camera2D
var speed: float = 200.0
var enemy_spawn_timer: float = 0.0
var enemy_spawn_interval: float = 2.0

func _ready() -> void:
	print("Game Started!")
	_setup_scene()

func _setup_scene() -> void:
	# 创建玩家
	player = CharacterBody2D.new()
	player.name = "Player"
	player.position = Vector2(640, 360)
	player.add_to_group("player")
	add_child(player)
	
	# 玩家外观
	var sprite := ColorRect.new()
	sprite.size = Vector2(32, 32)
	sprite.color = Color.BLACK
	sprite.position = Vector2(-16, -16)
	player.add_child(sprite)
	
	# 玩家碰撞
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(32, 32)
	collision.shape = shape
	player.add_child(collision)
	
	# 摄像机
	camera = Camera2D.new()
	camera.zoom = Vector2(2, 2)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	player.add_child(camera)
	
	# 标签
	var label := Label.new()
	label.text = "WASD移动，空格攻击"
	label.position = Vector2(20, 20)
	label.add_theme_font_size_override("font_size", 16)
	add_child(label)

func _physics_process(delta: float) -> void:
	_handle_player_input()
	_spawn_enemies(delta)

func _handle_player_input() -> void:
	var input_vector := Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
	
	player.velocity = input_vector * speed
	player.move_and_slide()
	
	if Input.is_action_just_pressed("technique_slot_1"):
		_fire_attack()

func _fire_attack() -> void:
	var attack := Area2D.new()
	attack.position = player.position
	attack.script = load("res://src/attack.gd")
	
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 8.0
	collision.shape = shape
	attack.add_child(collision)
	
	var sprite := ColorRect.new()
	sprite.size = Vector2(16, 16)
	sprite.color = Color.RED
	sprite.position = Vector2(-8, -8)
	attack.add_child(sprite)
	
	attack.direction = Vector2.RIGHT
	add_child(attack)

func _spawn_enemies(delta: float) -> void:
	enemy_spawn_timer += delta
	if enemy_spawn_timer >= enemy_spawn_interval:
		enemy_spawn_timer = 0.0
		_spawn_enemy()

func _spawn_enemy() -> void:
	var enemy := CharacterBody2D.new()
	var spawn_angle := randf() * TAU
	var spawn_distance := randf_range(300, 500)
	enemy.position = player.position + Vector2(cos(spawn_angle), sin(spawn_angle)) * spawn_distance
	enemy.script = load("res://src/enemy.gd")
	
	var sprite := ColorRect.new()
	sprite.size = Vector2(24, 24)
	sprite.color = Color.GREEN
	sprite.position = Vector2(-12, -12)
	enemy.add_child(sprite)
	
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(24, 24)
	collision.shape = shape
	enemy.add_child(collision)
	
	add_child(enemy)