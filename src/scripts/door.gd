extends StaticBody2D

@export var counterpart: NodePath

func enter(n):
	var dir = n.get_direction()
	n.global_position = get_node(counterpart).global_position
	if dir == Vector2.UP:
		n.global_position += dir * 32
