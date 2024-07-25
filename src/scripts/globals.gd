extends Node

# Constants - Global values that never change
const WALK_SPEED = 200
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
var just_entered_door = false
var transitioning = false:
  set(value):
    transitioning = value
    if value == false:
      emit_signal('transition_queue_clear')
var last_event_at = 0

# Instances - Important dynamically-loaded "singletons"
@onready var menuLayer = ml_scene.instantiate()
var camera
var clock
var calendar
var dynamicLayer
var dialog_stack
var affection_manager

# Preloads - Important classes to keep a base in memory at all times
var map = preload("res://scenes/map.tscn")
var ml_scene = preload("res://scenes/Menus/menu_layer.tscn")

# Variables for cheats
var player_position

# Signals
signal transition_queue_clear

# Methods - Global functions that need to be called outside the context of the game objects
func get_state():
  return {
    'seed': game_seed,
    'mw input?': can_accept_mw_input,
    'can_move?': movement_blocked,
    'player_moving?': player().moving,
    'inventory slots': str(unlocked_inventory_slots) + "/" + str(max_inventory_slots),
    'device': 'keyboard' if keyboard else 'controller',
    'time stopped?': time_stopped,
    'in-game day': day,
    'stamina': str("Max: ", max_stamina, " Current: ", stamina),
    'money': money,
    'shipping_cache': shipping_cache,
    'inventory': inventory
  }
  
func player():
  return get_tree().get_nodes_in_group("Player").front()
  
func get_held_item():
  var index = menuLayer.get_node("quick_inventory").focused_index() - 1
  if index < len(inventory):
    return inventory[index]
    
func try_add_inventory(item, quantity = 1):
  var idx = lookup_inventory(item)
  if idx != null:
    var existing = inventory[idx]
    existing[1] += quantity
    return true
  var empty_slot = first_empty_inventory_slot()
  if empty_slot >= unlocked_inventory_slots:
    return false
  inventory[empty_slot] = [item, quantity]
  return true
  
func remove_from_inventory(item, quantity = 1):
  var idx = lookup_inventory(item)
  if idx != null:
    inventory[idx][1] -= 1
    if inventory[idx][1] <= 0:
      inventory[idx] = null
  
func lookup_inventory(item):
  for k in range(len(inventory)):
    if inventory[k] == null:
      continue
    if inventory[k][0] == item:
      return k
  return null
  
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
  
func sleep():
  affection_manager.increment_day()
  menuLayer.transition("fade_out")
  await menuLayer.get_node("AnimationPlayer").animation_finished
  get_tree().change_scene_to_packed(map)
  if clock.time >= 360:
    increment_day()
  menuLayer.transition("fade_in")
  
func increment_day():
  money += shipping_cache
  shipping_cache = 0
  var new_weather = randi() % 100
  if new_weather < 60:
    weather = 'sunny'
  elif new_weather < 95:
    weather = 'snow' if calendar.season < 3 else 'rain'
  else:
    weather = 'severe' if calendar.season in [1,3] else 'rain'
  day += 1
  clock.time = 360
  #weather = 'rain' # debug
  print("Setting weather to ", weather)
  calendar.parse_day(day)
  dialog_stack = DialogDatabase.get_dialog_stack()
  last_event_at = 0
  
func repopulate_quick_inventory():
  if is_instance_valid(menuLayer):
    menuLayer.emit_signal("repopulate_qi")
    
func add_to_dynamic_layer(node: Node, pos: Vector2):
  dynamicLayer.add_child(node)
  node.global_position = pos
  
func ship(item: String, quantity: int):
  var inv_idx = lookup_inventory(item)
  if not inv_idx == null:
    var inst_item: Item = ItemDatabase.get_item(item)
    shipping_cache += inst_item.value * quantity
    remove_from_inventory(item, quantity)
  
func npc_talk(npc_name):
  if menuLayer.xdl_able():
    movement_blocked = true
    var label = dialog_stack[npc_name].pop_front() if len(dialog_stack[npc_name]) > 1 else dialog_stack[npc_name][0]
    menuLayer.xdl_call(label)
    await menuLayer.xdl_done
    movement_blocked = false
    time_stopped = false
  get_tree().call_group('NPC', 'end_dialog')
  
func npc_talk_label(label):
  if not menuLayer.xdl_able():
    return
  movement_blocked = true
  menuLayer.xdl_call(label)
  await menuLayer.xdl_done
  movement_blocked = false
  time_stopped = false
  
func find_npc(id):
  for n in get_tree().get_nodes_in_group('NPC'):
    if n.npc_name == id:
      return n

# Global processes
func _ready():
  process_mode = Node.PROCESS_MODE_ALWAYS
  time_stopped = true
  for i in range(max_inventory_slots):
    inventory.append(null)
  add_child(menuLayer)
  menuLayer.hide_hud()
  
func start_game(save_name):
  menuLayer.transition('fade_out')
  await menuLayer.fadeout
  movement_blocked = true
  get_tree().change_scene_to_file('res://scenes/map.tscn')
  print('faded')
  if save_name == null:
    _game_start()
  else:
    pass
  menuLayer.emit_signal('repopulate_qi')
  menuLayer.transition('fade_in')
  menuLayer.show_hud()
  await menuLayer.fadein
  movement_blocked = false
  time_stopped = false
  
func _game_start():
  # Generate seed
  randomize()
  game_seed = randi()
  
  # Pre-populate inventory
  try_add_inventory('hoe')
  try_add_inventory('sickle')
  try_add_inventory('watering_can')
  try_add_inventory('hammer')
  try_add_inventory('axe')
  try_add_inventory('generic_crop')
  try_add_inventory('generic_seeds', 9)
  try_add_inventory('fertilizer')
  try_add_inventory('generic_sapling')
  affection_manager = AffectionManager.new()
  dialog_stack = DialogDatabase.get_dialog_stack()
  print('started')

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

func change_camera_constraints(zone: LoadingZone, player: Actor):
  var rect: Rect2 = zone.camera_constraints()
  var cam: Camera2D = player.get_node("Camera2D")
  var minimum = rect.position
  var maximum = rect.position + rect.size
  cam.limit_left = minimum.x
  cam.limit_right = maximum.x
  cam.limit_top = minimum.y
  cam.limit_bottom = maximum.y

func _serialize_game_state():
  var save = {
    'seed': game_seed,
    'day': day,
    'farmland_state': farmland_state,
    'max_stam': max_stamina,
    'money': money,
    'inventory': inventory
  }
  save['lz'] = {}
  for zone in get_tree().get_nodes_in_group('LZ'):
    save['lz'][zone.get_name()] = zone.already_seen_events
  # TODO: serialize inventory
  return save
  
func _deserialize_save(data):
  game_seed = data['seed']
  day = data['day']
  farmland_state = data['farmland_state']
  max_stamina = data['max_stam']
  money = data['money']
  inventory = data['inventory']
  for zone in get_tree().get_nodes_in_group('LZ'):
    if data['lz'].has(zone.get_name()):
      zone.already_seen_events = data['lz'][zone.get_name()]

func save_game(save_name):
  var save = _serialize_game_state()
  var path = str("res://saves/", save_name, ".sav")
  var file = FileAccess.open(path, FileAccess.WRITE)
  if file != null:
    file.store_string(save)
    file.close()

func load_game(save_name):
  var path = str("res://saves/", save_name, ".sav")
  var file = FileAccess.open(path, FileAccess.READ)
  if file != null:
    var data = file.get_as_text()
    file.close()
    var json = JSON.new()
    var error = json.parse(data)
    if error != OK:
      print("FAILED TO READ FILE " + path)
      return
    data = json.data
    _deserialize_save(data)
