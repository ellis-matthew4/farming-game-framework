extends Node2D

class_name Item

var item_name
var value
var texture
var quantity = 1:
	set = set_quantity

func _init(n: String, v: int, tx_path: String):
	item_name = n
	value = v
	texture = load(tx_path)

func set_quantity(new):
	quantity = new
	Globals.repopulate_quick_inventory()
