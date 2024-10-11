class_name SnakeBody
extends Area2D

## The body part of a snake.

## Emitted when the body part starts moving from [param pos].
signal moving_from(pos: Vector2)
## Emitted when the current body part is a tail (i.e. the last bit) and 
## transformed an egg into a [param new_tail].
signal spawning_tail(new_tail, old_tail)

## The previous body part of the snake.
@export var following: Area2D
## Whether this part is the last bit of the snake.
@export var is_tail := false
## The position to which the snake will get to on the next step.
var next_step_position: Vector2
## Whether the body part is currently digesting an egg.
var has_egg := false
## The duration of a step animation.
var movement_duration: float


func _ready() -> void:
	self.following.moving_from.connect(self._on_following_leaving_place)


## Animates the spawning of the body part.
func animate_spawn() -> void:
	$Sprite2D.scale = Vector2.ZERO
	var scale_tween := self.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	scale_tween.tween_property($Sprite2D, "scale", Vector2(1, 1), 0.5)


## Moves the body part one step.
func move() -> void:
	self.moving_from.emit(self.position)
	
	if self.following.has_egg:
		self.has_egg = true
		var scale_tween := self.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		scale_tween.tween_property($Sprite2D, "scale", Vector2(1.2, 1.2), movement_duration)
	elif self.has_egg:
		self.has_egg = false
		var scale_tween := self.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		scale_tween.tween_property($Sprite2D, "scale", Vector2(1, 1), movement_duration)
		if self.is_tail:
			self.spawn_new_tail()
	
	var tween := self.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", self.next_step_position, movement_duration)


## Spawns a new tail that will follow this body part.
func spawn_new_tail() -> void:
	var new_tail = preload("res://scenes/snake/snake_body.tscn").instantiate()
	new_tail.position = self.position
	new_tail.is_tail = true
	new_tail.following = self
	new_tail.movement_duration = movement_duration
	self.spawning_tail.emit(new_tail, self)



func _on_following_leaving_place(pos: Vector2) -> void:
	self.next_step_position = pos
	self.move()
