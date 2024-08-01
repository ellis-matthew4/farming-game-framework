extends Control

@onready var shopItemsContainer = $Panel/VBoxContainer/ScrollContainer/ShopItemsContainer
@onready var shop_item_scn = preload("res://scenes/Menus/shop_item.tscn")

var working = false

signal empty
signal populated

func populate(context):
  working = true
  var items = ShopDatabase.get_shop(context)
  for id in items:
    var item = ItemDatabase.get_item(id)
    var listing = shop_item_scn.instantiate()
    shopItemsContainer.add_child(listing)
    listing.item = item
    listing.connect("pressed", _on_listing_pressed)
  emit_signal("populated")
  working = false
    
func depopulate():
  working = true
  for c in shopItemsContainer.get_children():
    shopItemsContainer.remove_child(c)
    c.queue_free()
  emit_signal("empty")
  working = false

func _on_listing_pressed(item):
  var success = Globals.try_purchase(item)
  if not success:
    pass # handle bad purchase

func _on_close_button_pressed():
  Globals.menuLayer.close_shop()
