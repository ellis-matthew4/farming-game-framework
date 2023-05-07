extends Node2D

class_name Item

var item_name
var value
var texture
var quantity = 1:
	set = set_quantity
var description

func _init(n: String, v: int, tx_path: String, d: String):
	item_name = n
	value = v
	texture = load(tx_path)
	description = d

func set_quantity(new):
	quantity = new
	if quantity <= 0:
		Globals.remove_from_inventory(self)
	Globals.repopulate_quick_inventory()
