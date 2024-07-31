extends PanelContainer

signal pressed(n)

@onready var textureRect = $HBoxContainer/ItemRectPanel/TextureRect
@onready var nameLabel = $HBoxContainer/PanelContainer/HBoxContainer/NameLabel
@onready var priceLabel = $HBoxContainer/PanelContainer/HBoxContainer/HBoxContainer/PriceLabel

var item: Item:
  set(new):
    item = new
    textureRect.texture = item.texture
    nameLabel.text = item.item_name
    priceLabel.text = str(item.retail_value())

func _on_button_pressed():
  emit_signal("pressed", item)

func _ready():
  item = ItemDatabase.get_item("fertilizer")
