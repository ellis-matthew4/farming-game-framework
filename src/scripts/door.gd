extends StaticBody2D

@export var counterpart: NodePath
@export var weather_restricted = false
@export var exterior = false
@export var walkable = false

@onready var menu_layer = Globals.menuLayer

func enter(n):
  if Globals.weather != 'severe':
    Globals.just_entered_door = true
    Globals.movement_blocked = true
    n.moving = false
    n.velocity = Vector2(0,0)
    menu_layer.transition("fade_out")
    await menu_layer.fadeout
    var dir = n.get_direction()
    n.global_position = get_node(counterpart).global_position
    if dir == Vector2.UP:
      n.global_position += dir * 32
    if exterior:
      menu_layer.hide_weather()
    else:
      menu_layer.set_weather()
    menu_layer.transition("fade_in")
    await menu_layer.fadein
    Globals.movement_blocked = false
    await get_tree().create_timer(0.5).timeout
    Globals.just_entered_door = false
  else:
    Globals.npc_talk_label('severe_weather')


func _on_area_2d_body_entered(body):
  if walkable and not Globals.just_entered_door:
    enter(body)
