extends Item

class_name Tool

var animation_key
var level

func _init(n: String, v: int, tx_path: String, key: String, lv: int, d: String):
	item_name = n
	value = v
	texture = load(tx_path)
	animation_key = key
	level = lv
	description = d
