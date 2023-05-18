extends Item

class_name Consumable

func _init(n: String, v: int, tx_path: String, d: String):
	item_name = n
	value = v
	texture = load(tx_path)
	description = d

func consume():
	quantity -= 1
