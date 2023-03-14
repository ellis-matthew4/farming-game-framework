extends Node

# Constants - Global values that never change
const WALK_SPEED = 140

# Variables - Global values that can change at any time
var can_accept_mw_input = true
var movement_blocked = false
var max_inventory_slots = 30
var unlocked_inventory_slots = 30
var keyboard = true
var seed = 0
var time_stopped = false
var day = 0
var inventory = []
var map_grid_size = 16

# Instances - Important dynamically-loaded "singletons"
var player
var menuLayer
var camera
var clock
var calendar

# Preloads - Important classes to keep a base in memory at all times

# Methods - Global functions that need to be called outside the context of the game objects
func get_state():
	return {
		'seed': seed,
		'mw input?': can_accept_mw_input,
		'can_move?': movement_blocked,
		'inventory slots': str(unlocked_inventory_slots) + "/" + str(max_inventory_slots),
		'device': 'keyboard' if keyboard else 'controller',
		'time stopped?': time_stopped,
		'in-game day': day
	}
	
func try_add_inventory(item):
	if len(inventory) >= unlocked_inventory_slots:
		return false
	inventory.append(item)
	
func increment_day():
	day += 1
	calendar.parse_day(day)

# Global processes
func _ready():
	# Generate seed. This should be moved to the game start
	randomize()
	seed = randi()
	process_mode = Node.PROCESS_MODE_ALWAYS
	try_add_inventory(ItemDatabase.get_item(0))
	try_add_inventory(ItemDatabase.get_item(1))
	try_add_inventory(ItemDatabase.get_item(2))
	try_add_inventory(ItemDatabase.get_item(3))
	try_add_inventory(ItemDatabase.get_item(4))

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
