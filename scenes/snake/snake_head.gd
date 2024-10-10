class_name SnakeHead
extends Area2D

## The head of the snake. Its direction is controlled by the player.

## Emitted when the head starts moving from [param pos].
signal moving_from(pos: Vector2)
## Emitted when the head eats and egg.
signal ate_egg
## Emitted when the head hits a wall.
signal hit_wall


## The length (in pixels) of a step.
const STEP_LENGTH := 16
## The duration of a step animation.
const MOVEMENT_DURATION := 0.3

## The direction to which the next step will be taken.
var next_step_direction := Vector2.UP
@onready var _sprite: Sprite2D = $Sprite2D
var next_body_direction := Vector2.DOWN
## Whether the head has just eaten an egg.
var has_egg := false


func _ready() -> void:
	TurnTimer.timeout.connect(self._on_turn_timer_timeout)


func _set_next_step(direction: Vector2, sprite_rotation: float) -> void:
	self.next_step_direction = direction
	self._sprite.rotation = sprite_rotation


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_up") and self.next_body_direction != Vector2.UP:
		self._set_next_step(Vector2.UP, 0)
	elif Input.is_action_just_pressed("ui_down") and self.next_body_direction != Vector2.DOWN:
		self._set_next_step(Vector2.DOWN, PI)
	elif Input.is_action_just_pressed("ui_left") and self.next_body_direction != Vector2.LEFT:
		self._set_next_step(Vector2.LEFT, -PI / 2)
	elif Input.is_action_just_pressed("ui_right") and self.next_body_direction != Vector2.RIGHT:
		self._set_next_step(Vector2.RIGHT, PI / 2)


## Moves the head one step.
func move() -> void:
	self.moving_from.emit(self.position)
	var position_delta := self.next_step_direction * STEP_LENGTH
	self.next_body_direction = -self.next_step_direction

	var tween := self.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	if self.has_egg:
		self.has_egg = false
		var scale_tween := self.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		scale_tween.tween_property(self._sprite, "scale", Vector2(1, 1), 0.3)
	tween.tween_property(self, "position", self.position + position_delta, MOVEMENT_DURATION)


func _on_turn_timer_timeout() -> void:
	self.move()


func _on_area_entered(area: Area2D) -> void:
	if area is Egg:
		self.has_egg = true
		self.ate_egg.emit()
		var tween := self.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self._sprite, "scale", Vector2(1.2, 1.2), 0.3)
	else:  # If it's not an egg, it means it's a wall.
		hit_wall.emit()
