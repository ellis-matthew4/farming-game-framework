extends Control

func _process(_delta):
  $ColorRect/Label.text = str("$", Globals.money)
