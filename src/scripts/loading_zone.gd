extends Area2D

class_name LoadingZone

# already_seen_events = []

signal player_entered(zone, player)
signal player_exited(zone)

func ready_to_show_event():
  print("Should not see this.")

func _ready():
  self.body_entered.connect(_on_body_entered)
  self.player_entered.connect(_on_player_entered)
  self.body_exited.connect(_on_body_exited)
  self.player_entered.connect(Globals.change_camera_constraints)

func _on_body_entered(body):
  if body.is_in_group("Player"):
    emit_signal("player_entered", self, body)
    
func _on_body_exited(body):
  if body.is_in_group("Player"):
    emit_signal("player_exited", self)
    
func _on_player_entered(_zone, _player):
  if Globals.clock.time < Globals.last_event_at + 180:
    return
  var event_id = ready_to_show_event()
  if event_id != null:
    await Globals.transition_queue_clear
    Globals.last_event_at = Globals.clock.time
    Globals.npc_talk_label(event_id)
    Globals.time_stopped = true
  

func overlapping_npcs():
  var result = []
  for n in get_overlapping_bodies():
    if n is NPC:
      result.append(n)
  return result

func camera_constraints():
  var xValues = []
  var yValues = []
  var polygon: PackedVector2Array = $CollisionPolygon2D.polygon
  var v = get_viewport().get_visible_rect()
  var viewport = Rect2(v.position / 4, v.size / 4)
  for vec in polygon:
    xValues.append(vec.x)
    yValues.append(vec.y)
  var minX: int = xValues.min()
  var minY: int = yValues.min()
  var maxX: int = xValues.max()
  var maxY: int = yValues.max()
  var rect = Rect2(minX, minY, (maxX - minX), (maxY - minY))
  if rect.get_area() < viewport.get_area():
    var size_offsets = Vector2(0,0)
    size_offsets.x = (viewport.size.x - rect.size.x)/2
    size_offsets.y = (viewport.size.y - rect.size.y)/2
    var new_pos = Vector2(0,0)
    new_pos.x = rect.position.x - size_offsets.x
    new_pos.y = rect.position.y - size_offsets.y + 8 # center vertically, then adjust for hotbar
    viewport.position = new_pos
    return viewport
  # adjust the positions for optimal camera alignment
  minX -= (Globals.MAP_GRID_SIZE * 3)
  minY -= (Globals.MAP_GRID_SIZE * 5)
  maxX += (Globals.MAP_GRID_SIZE * 3)
  maxY += (Globals.MAP_GRID_SIZE * 2)
  rect = Rect2(minX, minY, (maxX - minX), (maxY - minY))
  return rect
