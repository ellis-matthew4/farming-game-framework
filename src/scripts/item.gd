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
