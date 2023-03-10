extends Node

# Constants - Global values that never change
const WALK_SPEED = 300

# Variables - Global values that can change at any time
var can_accept_mw_input = true
var movement_blocked = false
var max_inventory_slots = 30
var unlocked_inventory_slots = 30

# Instances - Important dynamically-loaded "singletons"
var player
var menuLayer
var camera

# Preloads - Important classes to keep a base in memory at all times

# Methods - Global functions that need to be called outside the context of the game objects
func pause():
	pass

func open_menu():
	menuLayer.menu()

func close_menu(menu):
	menuLayer.menu_hide(menu)
