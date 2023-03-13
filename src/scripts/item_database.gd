extends Node

var items = [
	Tool.new("Hoe", -1, "res://assets/items/hoe.png", "sample"),
	Tool.new("Sickle", -1, "res://assets/items/sickle.png", "sample"),
	Tool.new("Watering Can", -1, "res://assets/items/watering_can.png", "sample"),
	Tool.new("Hammer", -1, "res://assets/items/hammer.png", "sample"),
	Tool.new("Axe", -1, "res://assets/items/axe.png", "sample"),
]

func get_item(index):
	return items[index]

func get_idx(item):
	return items.find(item)
