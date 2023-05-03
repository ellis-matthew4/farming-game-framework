extends Area2D

@onready var bounds = $CollisionShape2D.shape.size
@onready var soil_scene = preload("res://scenes/soil.tscn")
@onready var soil_txt = preload("res://assets/soil.png")
@onready var soil_txt_w = preload("res://assets/soil_watered.png")
var origin = Vector2()
var xrange = []
var yrange = []

var soils = []
var tilled = []
var stages = []
var crops = []
var watered = []

var player_inside = false

func _ready():
	origin.x = $CollisionShape2D.position.x - bounds.x / 2
	origin.y = $CollisionShape2D.position.y - bounds.y / 2
	xrange = range(0, bounds.x, Globals.map_grid_size)
	yrange = range(0, bounds.y, Globals.map_grid_size)
	if Globals.farmland_state.has(name):
		from_state(Globals.farmland_state[name])
		render()
	else:
		for i in range(len(xrange) * len(yrange)):
			soils.append(randi() % 3)
			tilled.append(false)
			stages.append(0)
			crops.append(0)
			watered.append(false)
			var soil = soil_scene.instantiate()
			add_child(soil)
			soil.position = _get_coordinates(i)
	body_entered.connect(_player_entered)
	body_exited.connect(_player_exited)
	tree_exiting.connect(_on_destroy)

func _process(delta):
	if Input.is_action_just_pressed("player_interact"):
		if player_inside:
			var p = Globals.player
			var coords = global_to_local_coords(p.get_real_position() + (p.get_direction() * Globals.map_grid_size))
			if coords.x == -1:
				return
			else:
				var held = Globals.get_held_item()
				if not is_instance_valid(held):
					return
				var i = _get_index(coords.x, coords.y)
				match(held.item_name):
					"Hoe":
						get_children()[i+1].set_soil_texture(soil_txt)
						tilled[i] = true
					"Hammer":
						get_children()[i+1].set_soil_texture(null)
						tilled[i] = false
					"Watering Can":
						if tilled[i]:
							get_children()[i+1].set_soil_texture(soil_txt_w)
							watered[i] = true
					"Sickle":
						if crops[i] > 7:
							var product = ItemDatabase.get_item(crops[i])
							if product.reharvestable:
								if stages[i] > product.reharvest_stage:
									get_children()[i+1].set_crop_texture(product.get_texture_as_sprite2D(product.reharvest_stage))
									stages[i] = product.reharvest_stage
								else:
									get_children()[i+1].set_crop_texture(null)
									crops[i] = 0
							else:
								get_children()[i+1].set_crop_texture(null)
								crops[i] = 0
							if stages[i] == product.max_stages:
								var item_to_drop = product.get_product()
								Globals.try_add_inventory(item_to_drop) # replace with ground item
						elif crops[i] == 7:
							get_children()[i+1].set_crop_texture(null)
							crops[i] = 0
					"Fertilizer":
						if tilled[i]:
							soils[i] = soils[i] + 1 if soils[i] < 4 else 4
							held.quantity -= 1
					_:
						if held is Seeds:
							if tilled[i] and crops[i] == 0:
								get_children()[i+1].set_crop_texture(held.get_texture_as_sprite2D(0))
								crops[i] = ItemDatabase.get_idx(held)
								stages[i] = 1
								held.quantity -= 1
	
func _get_index(x, y):
	var result = Vector2()
	result.x = x / Globals.map_grid_size
	result.y = y / Globals.map_grid_size
	return result.y * len(xrange) + result.x
	
func _get_coordinates(index):
	var x = xrange[index % len(xrange)]
	var y = yrange[index / len(xrange)]
	return Vector2(x, y) + origin
	
func global_to_local_coords(coords):
	var local_coords = coords - origin
	if local_coords.x < xrange.front() || local_coords.x > xrange.back():
		return Vector2(-1,-1)
	if local_coords.y < yrange.front() || local_coords.y > yrange.back():
		return Vector2(-1,-1)
	return Vector2(nearest_neighbor(local_coords.x, xrange), nearest_neighbor(local_coords.y, yrange))
	
func nearest_neighbor(k, list):
	var delta = 999999
	var item
	for i in list:
		if abs(i - k) < delta:
			delta = abs(i - k)
			item = i
			if delta == 0:
				return i
	return item

func get_state():
	var state = []
	for i in range(len(soils)):
		var encoded = str(soils[i], "1" if tilled[i] else "0", str(stages[i], str(crops[i])))
		state.append(encoded)
	return state
	
func from_state(state):
	var new_soils = []
	var new_tilled = []
	var new_stages = []
	var new_crops = []
	for encoded in state:
		new_soils.append(int(encoded.substr(0, 1)))
		new_tilled.append(encoded.substr(1, 1) == "1")
		new_stages.append(int(encoded.substr(2,1)))
		new_crops.append(int(encoded.substr(3,-1)))
		watered.append(false)
	soils = new_soils
	tilled = new_tilled
	stages = new_stages
	crops = new_crops

func render(): # draw from freshly loaded state
	for i in len(tilled):
		var soil = soil_scene.instantiate()
		add_child(soil)
		soil.position = _get_coordinates(i)
		if tilled[i]:
			soil.set_soil_texture(soil_txt)
		if crops[i] > 7:
			var crop = ItemDatabase.get_item(crops[i])
			soil.set_crop_texture(crop.get_texture_as_sprite2D(stages[i]))
			

func _player_entered(p):
	player_inside = true
	
func _player_exited(p):
	player_inside = false

func increment():
	for i in range(len(tilled)):
		if watered[i] and crops[i] > 7:
			if stages[i] < ItemDatabase.get_item(crops[i]).max_stages:
				stages[i] += 1
		var r = randi() % 100
		if crops[i] == 0:
			if r < 20:
				tilled[i] = false
				match(r % 3):
					0:
						crops[i] = 1 # spawn weed
					1:
						crops[i] = 2 # spawn rock
					2:
						crops[i] = 3 # spawn branch
				continue

func _on_destroy():
	increment()
	var state = get_state()
	Globals.farmland_state[name] = state
