class_name Controller
extends Node2D

## Controller for the game's general rules.

## The size of each tile (height and width) in pixels.
const TILE_SIZE := 16
## The position in pixels of the cell (0, 0)'s center.
const GRID_OFFSET := Vector2(8, 8)
## The horizontal amount of tiles in the grid.
const GRID_TILE_WIDTH := 16
## The vertical amount of tiles in the grid.
const GRID_TILE_HEIGHT := 12

@onready var score_label: Label = $UILayer/Control/Label
@onready var game_over_menu: Control = $UILayer/Control/GameOverMenu
@onready var game_over_score_label: Label = $UILayer/Control/GameOverMenu/VBoxContainer/ScoreLabel
var score := 0


func _ready() -> void:
	_start_game()
	self.spawn_egg()


## Spawns an egg onto the world.
func spawn_egg() -> void:
	var free_positions := self.get_free_positions()
	if len(free_positions) == 0:
		return
	randomize()
	var picked: Vector2i = (free_positions.pick_random() as Vector2i)
	
	var new_egg: Egg = preload("res://scenes/food/egg.tscn").instantiate()
	new_egg.position.x = GRID_OFFSET.x + TILE_SIZE * picked.x
	new_egg.position.y = GRID_OFFSET.y + TILE_SIZE * picked.y
	new_egg.eaten.connect(self.spawn_egg)
	self.call_deferred("add_child", new_egg)
	#self.add_child(new_egg)


## Places the [param new_tail] on the map behind [param old tail].
func spawn_new_snake_tail(new_tail: SnakeBody, old_tail: SnakeBody) -> void:
	old_tail.spawning_tail.disconnect(self.spawn_new_snake_tail)
	new_tail.spawning_tail.connect(self.spawn_new_snake_tail)
	$SnakeHolder.add_child(new_tail)


## Gets the grid position of the given snake [param part].
func get_snake_part_grid_position(part: Area2D) -> Vector2i:
	return Vector2i(int(part.position.x) / TILE_SIZE, int(part.position.y) / TILE_SIZE)


## Retrieves the positions where an egg can be spawn i.e. the ones not occupied
## by the snake.
func get_free_positions() -> Array[Vector2i]:
	var occupied_positions: Array[Vector2i] = []
	for snake_part in $SnakeHolder.get_children():
		occupied_positions.append(self.get_snake_part_grid_position(snake_part))
	
	var free_positions: Array[Vector2i] = []
	for y in range(GRID_TILE_HEIGHT):
		for x in range(GRID_TILE_WIDTH):
			var candidate_position := Vector2i(x, y)
			if not (candidate_position in occupied_positions):
				free_positions.append(candidate_position)
	
	return free_positions


func _start_game() -> void:
	get_tree().paused = false


func _on_snake_head_ate_egg() -> void:
	score += 1
	score_label.text = str(score)


func _on_snake_head_hit_wall() -> void:
	get_tree().paused = true
	game_over_menu.visible = true
	game_over_score_label.text = "Your score: %s" % score


func _on_retry_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level/level.tscn")
