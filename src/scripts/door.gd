extends StaticBody2D

@export var counterpart: NodePath
@export var weather_restricted = false
@export var exterior = false

func enter(n):
  if Globals.weather != 'severe':
    var dir = n.get_direction()
    n.global_position = get_node(counterpart).global_position
    if dir == Vector2.UP:
      n.global_position += dir * 32
    if exterior:
      Globals.menuLayer.hide_weather()
    else:
      Globals.menuLayer.set_weather()
  else:
    print("SEVERE WEATHER PLACEHOLDER")
