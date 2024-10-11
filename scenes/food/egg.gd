class_name Egg
extends Area2D

## The main food that the snake eats. When digested, the snake extends its size
## by one.

## Emitted when the egg is eaten by the snake.
signal eaten


func _ready() -> void:
	self.scale = Vector2(0, 0)
	var tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.3)


func _on_area_entered(_area: Area2D) -> void:
	set_deferred("monitoring", false)
	self.eaten.emit()
	var tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	await tween.finished
	self.queue_free()
