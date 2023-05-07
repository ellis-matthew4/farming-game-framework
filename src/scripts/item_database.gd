extends Node

@onready var items = [
	Tool.new("Hoe", -1, "res://assets/items/hoe.png", "sample", 1, "An old hoe. Used for tilling soil."),
	Tool.new("Sickle", -1, "res://assets/items/sickle.png", "sample", 2, "An old sickle. Used for harvesting crops."),
	Tool.new("Watering Can", -1, "res://assets/items/watering_can.png", "sample", 3, "An old watering can. Used for watering crops."),
	Tool.new("Hammer", -1, "res://assets/items/hammer.png", "sample", 4, "An old hammer. Used for breaking up rocks."),
	Tool.new("Axe", -1, "res://assets/items/axe.png", "sample", 5, "An old axe. Used for cutting down trees and branches."),
	Item.new("Branch", 10, "res://assets/fertilizer.png", "A branch. Not very useful."),
	Item.new("Rock", 10, "res://assets/product.png", "A rock. Not very useful."),
	Item.new("Weed", 1, "res://assets/items/sickle.png", "A weed. Not very useful."),
	Seeds.new("Sample Seeds", 20, "res://assets/crop.png", 3, 9),
	Food.new("Sample Crop", 50, "res://assets/product.png", 10, "A fruit of some kind."),
	Consumable.new("Fertilizer", 40, "res://assets/fertilizer.png", "A mix of high-grade animal manures guaranteed to make your fields more fertile."),
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
