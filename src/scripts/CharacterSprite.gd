@tool
extends Node2D

@export var skin_color: Color = Color('e9c8bc')
@export var eye_color: Color = Color.BLUE

@export_enum ("up", "down", "side") var animation: String = "down"
@export var playing: bool = false 

func _process(delta):
  if $body.modulate != skin_color:
    $body.modulate = skin_color
  if $eyes.modulate != eye_color:
    $eyes.modulate = eye_color
  
  for c in get_children():
    if c.animation != animation:
      c.animation = animation
    if playing and not c.is_playing():
      c.play()
    elif not playing and c.is_playing():
      c.stop()

func play(anim):
  animation = anim
  playing = true

func serialize():
  return {
    'eye_color': eye_color,
    'skin_color': skin_color
  }
  
func deserialize(obj):
  eye_color = obj['eye_color']
  skin_color = obj['skin_color']
