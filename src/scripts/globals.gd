extends Node

# Constants - Global values that never change
const WALK_SPEED = 140
const MAP_GRID_SIZE = 16

# Variables - Global values that can change at any time
var can_accept_mw_input = true
var movement_blocked = false
var max_inventory_slots = 30
var unlocked_inventory_slots = 10
var keyboard = true
var game_seed = 0
var time_stopped = false
var day = 0
var inventory = []
var farmland_state = {}
var shipping_cache = 0
var max_stamina = 100
var stamina = 100
var money = 0
var weather = 'sunny'

# Instances - Important dynamically-loaded "singletons"
var player
@onready var menuLayer = ml_scene.instantiate()
var camera
var clock
var calendar
var dynamicLayer

# Preloads - Important classes to keep a base in memory at all times
var map = preload("res://scenes/map.tscn")
var ml_scene = preload("res://scenes/Menus/menu_layer.tscn")

# Variables for cheats
var player_position

# Methods - Global functions that need to be called outside the context of the game objects
func get_state():
  return {
    'seed': game_seed,
    'mw input?': can_accept_mw_input,
    'can_move?': movement_blocked,
    'player_moving?': player.moving,
    'inventory slots': str(unlocked_inventory_slots) + "/" + str(max_inventory_slots),
    'device': 'keyboard' if keyboard else 'controller',
    'time stopped?': time_stopped,
    'in-game day': day,
    'stamina': str("Max: ", max_stamina, " Current: ", stamina),
    'money': money,
    'shipping_cache': shipping_cache,
    'inventory': get_serialized_inventory()
  }
  
func get_serialized_inventory():
  var result = ""
  for i in range(0, unlocked_inventory_slots):
    if inventory[i] != null:
      result += str(inventory[i].key, ",")
    else:
      result += str(-1, ",")
  return result
  
func try_add_inventory(item, quantity = 1):
  var idx = lookup_inventory(item)
  if idx != null:
    var existing = inventory[idx]
    existing.quantity += quantity
    return true
  if first_empty_inventory_slot() >= unlocked_inventory_slots:
    return false
  item.quantity = quantity
  inventory[first_empty_inventory_slot()] = item
  return true
  
func swap(i, j):
  var item1 = inventory[i]
  var item2 = inventory[j]
  var temp = item1
  inventory[i] = item2
  inventory[j] = temp
  print("swapped")
  
func first_empty_inventory_slot():
  for i in range(len(inventory)):
    if inventory[i] == null:
      return i
  return max_inventory_slots + 1

func remove_from_inventory(item):
  var idx = lookup_inventory(item)
  if idx != null:
    inventory[idx] = null
    
func try_purchase(amount):
  if amount > money:
    return false
  money -= amount
  return true
  
func try_decrease_stamina(amount):
  stamina = max(0, stamina - amount)
  return stamina > 0
  
func increase_stamina(amount):
  stamina = min(max_stamina, stamina + amount)
  
func lookup_inventory(item):
  for k in range(len(inventory)):
    if inventory[k] == null:
      continue
    if inventory[k].item_name == item.item_name:
      return k
  return null
  
func get_held_item():
  var index = menuLayer.get_node("quick_inventory").focused_index() - 1
  if index < len(inventory):
    return inventory[index]
  
func sleep():
  menuLayer.transition("fade_out")
  await menuLayer.get_node("AnimationPlayer").animation_finished
  get_tree().change_scene_to_packed(map)
  if clock.time >= 360:
    increment_day()
  menuLayer.transition("fade_in")
  
func increment_day():
  money += shipping_cache
  shipping_cache = 0
  if weather == 'sunny':
    weather = 'rain'
  elif weather == 'rain':
    weather = 'snow'
  elif weather == 'snow':
    weather = 'severe'
  elif weather == 'severe':
    weather = 'sunny'
  day += 1
  clock.time = 360
  weather = 'rain' # debug
  print("Setting weather to ", weather)
  calendar.parse_day(day)
  
func repopulate_quick_inventory():
  if is_instance_valid(menuLayer):
    menuLayer.emit_signal("repopulate_qi")
    
func add_to_dynamic_layer(node: Node, pos: Vector2):
  dynamicLayer.add_child(node)
  node.global_position = pos
  
func ship(item: Item):
  shipping_cache += item.value
  item.quantity -= 1

# Global processes
func _ready():
  process_mode = Node.PROCESS_MODE_ALWAYS
  _game_start()
  add_child(menuLayer)
  
func _game_start():
  # Generate seed
  randomize()
  game_seed = randi()
  
  # Pre-populate inventory
  for i in range(max_inventory_slots):
    inventory.append(null)
  try_add_inventory(ItemDatabase.get_item('hoe'))
  try_add_inventory(ItemDatabase.get_item('sickle'))
  try_add_inventory(ItemDatabase.get_item('watering_can'))
  try_add_inventory(ItemDatabase.get_item('hammer'))
  try_add_inventory(ItemDatabase.get_item('axe'))
  try_add_inventory(ItemDatabase.get_item('generic_crop'))
  try_add_inventory(ItemDatabase.get_item('generic_seeds'), 9)
  try_add_inventory(ItemDatabase.get_item('fertilizer'))
  try_add_inventory(ItemDatabase.get_item('generic_sapling'))

func _input(event):
  if (event is InputEventKey):
    keyboard = true
  elif (event is InputEventMouseButton):
    keyboard = true
  elif (event is InputEventMouseMotion):
    keyboard = true
  elif (event is InputEventJoypadButton):
    keyboard = false
  elif (event is InputEventJoypadMotion):
    keyboard = false
