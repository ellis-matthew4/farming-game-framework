extends Control

func _process(delta):
  $ColorRect/Label.text = str("$", Globals.money)
