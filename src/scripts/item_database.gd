extends Node

@onready var items = [
	Tool.new("Hoe", -1, "res://assets/items/hoe.png", "sample"),
	Tool.new("Sickle", -1, "res://assets/items/sickle.png", "sample"),
	Tool.new("Watering Can", -1, "res://assets/items/watering_can.png", "sample"),
	Tool.new("Hammer", -1, "res://assets/items/hammer.png", "sample"),
	Tool.new("Axe", -1, "res://assets/items/axe.png", "sample"),
	Item.new("Branch", 10, "res://assets/fertilizer.png"),
	Item.new("Rock", 10, "res://assets/product.png"),
	Item.new("Weed", 1, "res://assets/items/sickle.png"),
	Seeds.new("Sample Seeds", 20, "res://assets/crop.png", 3, 9),
	Food.new("Sample Crop", 50, "res://assets/product.png", 10),
	Consumable.new("Fertilizer", 40, "res://assets/fertilizer.png"),
]

func get_item(index) -> Item:
	return items[index]

func get_idx(item):
	return items.find(item)

func get_index_by_name(n):
	for k in len(items):
		var i = items[k]
		if i.item_name == n:
			return k
	return null # This will throw an error if reached, indicating a missing item
