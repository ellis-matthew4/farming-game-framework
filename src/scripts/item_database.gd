extends Node

var items = {}

func _ready():
  items = {
    "hoe": Tool.new("Hoe", -1, "res://assets/items/hoe.png", "sample", 1, "An old hoe. Used for tilling soil."),
    "sickle": Tool.new("Sickle", -1, "res://assets/items/sickle.png", "sample", 2, "An old sickle. Used for harvesting crops."),
    "watering_can": Tool.new("Watering Can", -1, "res://assets/items/watering_can.png", "sample", 3, "An old watering can. Used for watering crops."),
    "hammer": Tool.new("Hammer", -1, "res://assets/items/hammer.png", "sample", 4, "An old hammer. Used for breaking up rocks."),
    "axe": Tool.new("Axe", -1, "res://assets/items/axe.png", "sample", 5, "An old axe. Used for cutting down trees and branches."),
    'branch': Item.new("Branch", 10, "res://assets/items/branch.png", "A branch. Not very useful."),
    'lumber': Item.new("Lumber", 10, "res://assets/items/lumber.png", "A piece of processed lumber. Used for lots of things."),
    'rock': Item.new("Rock", 10, "res://assets/items/rock.png", "A rock. Not very useful."),
    'stone': Item.new("Stone", 10, "res://assets/items/stone.png", "A piece of refined stone. Used for lots of things."),
    'weed': Item.new("Weed", 1, "res://assets/items/weed.png", "A weed. Not very useful."),
    'thatch': Item.new("Thatch", 1, "res://assets/items/thatch.png", "A bundle of thatch. Used for lots of things."),
    'generic_crop': Food.new("Sample Crop", 50, "res://assets/items/product.png", 10, "A fruit of some kind."),
    'generic_seeds': Seeds.new("Sample Seeds", 20, "res://assets/items/crop.png", 3, "generic_crop"),
    'fertilizer': Consumable.new("Fertilizer", 40, "res://assets/items/fertilizer.png", "A mix of high-grade animal manure guaranteed to make your fields more fertile."),
    'generic_sapling': Sapling.new("Sample Sapling", 100, "res://assets/items/sapling.png", 30, "generic_crop", 1, 28),
  }
  for k in items.keys():
    items[k].key = k
    if items[k] is Sapling or items[k] is Seeds:
      items[k].prepare_rendered_data()

func get_item(id) -> Item:
  return items[id] if id != null else null

func get_id(item: Item):
  return items.find_key(item)
