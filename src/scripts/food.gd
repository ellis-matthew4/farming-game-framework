extends Consumable

class_name Food

var stamina

func _init(n: String, v: int, tx_path: String, stam: int):
	item_name = n
	value = v
	texture = load(tx_path)
	stamina = stam
	
func consume():
	stamina = stamina # fix this later
	quantity -= 1
	if quantity <= 0:
		queue_free()

