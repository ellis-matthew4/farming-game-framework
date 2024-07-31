extends Node2D

class_name Item

var key : String

var item_name
var value
var texture
var description

func _init(n: String, v: int, tx_path: String, d: String):
  item_name = n
  value = v
  texture = load(tx_path)
  description = d

func get_texture_as_sprite2D(_stage):
  var tx = Sprite2D.new()
  tx.texture = texture
  tx.centered = false
  return tx

func retail_value():
  return snappedi(value * 1.5, 10)
