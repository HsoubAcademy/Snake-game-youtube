extends Node

@export var snake_scene: PackedScene

var score: int
var game_started: bool = false

var cells: int = 20
var cell_size: int = 50

var food_pos: Vector2
var regen_food: bool = true

var old_data: Array = []
var snake_data: Array = []
var snake: Array = []

var start_pos = Vector2(9, 9)
var up = Vector2(0, -1)
var down = Vector2(0, 1)
var left = Vector2(-1, 0)
var right = Vector2(1, 0)
var move_direction: Vector2
var can_move: bool = true

func _ready():
	new_game()

func _process(delta):
	move_snake()

func new_game():
	get_tree().paused = false
	get_tree().call_group("segments", "queue_free")
	$GameOverMenu.hide()

	score = 0
	$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score)

	move_direction = up
	can_move = true
	generate_snake()
	move_food()

func generate_snake():
	old_data.clear()
	snake_data.clear()
	snake.clear()
	for i in range(3):
		add_segment(start_pos + Vector2(0, i))

func add_segment(pos: Vector2):
	snake_data.append(pos)

	var SnakeSegment = snake_scene.instantiate()
	SnakeSegment.position = (pos * cell_size) + Vector2(0, cell_size)
	add_child(SnakeSegment)

	snake.append(SnakeSegment)

func start_game():
	game_started = true
	$MoveTimer.start()

func move_snake():
	if can_move:
		update_direction_from_input()
		if not game_started:
			start_game()

func update_direction_from_input():
	if Input.is_action_just_pressed("ui_down") and move_direction != up:
		move_direction = down
		can_move = false
	elif Input.is_action_just_pressed("ui_up") and move_direction != down:
		move_direction = up
		can_move = false
	elif Input.is_action_just_pressed("ui_left") and move_direction != right:
		move_direction = left
		can_move = false
	elif Input.is_action_just_pressed("ui_right") and move_direction != left:
		move_direction = right
		can_move = false

func _on_move_timer_timeout():
	can_move = true
	old_data = [] + snake_data
	snake_data[0] += move_direction
	for i in range(len(snake_data)):
		if i > 0:
			snake_data[i] = old_data[i - 1]
		snake[i].position = (snake_data[i] * cell_size) + Vector2(0, cell_size)
	check_out_of_bounds()
	check_food_eaten()

func check_out_of_bounds():
	var head_pos = snake_data[0]
	if head_pos.x < 0 or head_pos.x >= cells or head_pos.y < 0 or head_pos.y >= cells:
		end_game()


func check_food_eaten():
	if snake_data[0] == food_pos:
		score += 1
		$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
		add_segment(old_data[-1])
		move_food()

func move_food():
	while regen_food:
		regen_food = false
		food_pos = Vector2(randi_range(0, cells - 1), randi_range(0, cells - 1))
		for segment_pos in snake_data:
			if food_pos == segment_pos:
				regen_food = true

	$Food.position = (food_pos * cell_size) + Vector2(0, cell_size)
	regen_food = true


func end_game():
	$GameOverMenu.show()
	$MoveTimer.stop()
	game_started = false
	get_tree().paused = true

func _on_game_over_menu_restart():
	new_game()
