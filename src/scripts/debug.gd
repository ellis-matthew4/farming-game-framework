extends Control

func _ready():
	_refresh()

func _process_text(hash):
	var result = ""
	for key in hash.keys():
		result += key + ": " + str(hash[key]) + "\n"
	return result

func _refresh():
	$Label.text = _process_text(Globals.get_state())
	await get_tree().create_timer(1).timeout
	_refresh()
