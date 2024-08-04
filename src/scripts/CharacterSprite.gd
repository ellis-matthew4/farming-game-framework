@tool
extends Node2D

@export var process: bool = false

@export var skin_color: Color = Color('e9c8bc')
@export var eye_color: Color = Color.BLUE
@export var shirt_color: Color = Color.AQUAMARINE
@export var pants_color: Color = Color.BURLYWOOD
@export var shoes_color: Color = Color.BURLYWOOD

@export_enum ("up", "down", "side") var animation: String = "down"
@export var playing: bool = false 
@export var frame: int = 0

func _process(delta):
  if $body.modulate != skin_color:
    $body.modulate = skin_color
  if $eyes.modulate != eye_color:
    $eyes.modulate = eye_color
  if $shirt.modulate != shirt_color:
    $shirt.modulate = shirt_color
  if $pants.modulate != pants_color:
    $pants.modulate = pants_color
  if $shoes.modulate != shoes_color:
    $shoes.modulate = shoes_color
  
  for c in get_children():
    if not process:
      return
    if not c is AnimatedSprite2D:
      return
    if c.animation != animation:
      c.animation = animation
    if not playing and c.frame != frame:
      c.frame = frame
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
