extends Area2D

@onready var bounds = $CollisionShape2D.shape.size
@onready var soil_scene = preload("res://scenes/soil.tscn")
var origin = Vector2()
var xrange = []
var yrange = []

var soils = []
var tilled = []
var stages = []
var crops = []
var watered = []


func _ready():
  origin.x = $CollisionShape2D.position.x - bounds.x / 2
  origin.y = $CollisionShape2D.position.y - bounds.y / 2
  xrange = range(0, bounds.x, Globals.MAP_GRID_SIZE)
  yrange = range(0, bounds.y, Globals.MAP_GRID_SIZE)
  if Globals.farmland_state.has(name):
    render(Globals.farmland_state[name])
  else:
    for i in range(len(xrange) * len(yrange)):
      var soil = soil_scene.instantiate()
      add_child(soil)
      soil.position = _get_coordinates(i)
      soil.quality = randi() % 3
  tree_exiting.connect(_on_destroy)
  
func _get_coordinates(index):
  var x = xrange[index % len(xrange)]
  var y = yrange[index / len(xrange)]
  return Vector2(x, y) + origin

func get_state():
  var state = []
  for c in get_children():
    if c is Soil:
      var encoded = str(c.quality, "1" if c.tilled else "0", '.', c.stage, '.', c.crop_idx())
      state.append(encoded)
  return state

func render(state): # draw from freshly loaded state
  var i = 0
  for encoded in state:
    var k = encoded.split('.')
    var soil = soil_scene.instantiate()
    add_child(soil)
    soil.position = _get_coordinates(i)
    soil.quality = int(k[0].substr(0, 1))
    if k[0].substr(1, 1) == '1':
      soil.hoe()
    if Globals.weather in ['rain', 'severe']:
      soil.water()
    var stage = int(k[1])
    var crop_id = k[2]
    if crop_id != '':
      var crop = ItemDatabase.get_item(crop_id)
      soil.sow(crop, stage)
    i += 1

func increment():
  for c in get_children():
    if c is Soil:
      if c.watered:
        c.increment_stage()
      if c.crop == null:
        var r = randi() % 100
        if r < 20:
          c.tilled = false
          match(r % 3):
            # This needs to be reworked to add collision shapes to these objects.
            # Potentially spawn an object in the DynamicLayer instead of using the crops array
            # In any case, this will be done inside render()
            0:
              c.spawn_weed()
            1:
              c.spawn_weed()
            2:
              c.spawn_weed()

func _on_destroy():
  increment()
  Globals.farmland_state[name] = get_state()
