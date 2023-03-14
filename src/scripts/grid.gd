extends Node

class_name Grid

var rows
var columns
var maxv

var i = 1

func _init(r, c):
	rows = r
	columns = c
	maxv = r * c
	
func get_next():
	i += 1
	if i > maxv:
		i = i - maxv
	return i
	
func get_previous():
	i -= 1
	if i < 1:
		i = i + maxv
	return i
	
func get_current():
	return i
	
func get_next_row():
	i += columns
	if i > maxv:
		i -= maxv
	return i

func get_previous_row():
	i -= columns
	if i < 1:
		i += maxv
	return i
	
