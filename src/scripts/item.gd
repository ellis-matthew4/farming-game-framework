extends Node2D

class_name Item

var item_name
var value
var texture

func _init(n: String, v: int, tx_path: String):
	item_name = n
	value = v
	texture = load(tx_path)
