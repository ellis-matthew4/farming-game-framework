extends Node

# planned final data structure: base_stack[name][affection_level]
var base_stack = {
  'npc': [
    [
      'sample_npc_interact1',
      'sample_npc_interact2',
      'sample_npc_interact3'
    ]
  ]
}

var special = {}

# Will reduce the base stack to structure stack[name] -> []
func get_stack():
  var stack = {}
  for n in base_stack.keys():
    var level = Globals.affection_manager.get_affection_level(n)
    var result = []
    if n in special.keys():
      result.append_array(special[n])
    result.append_array(base_stack[n][level])
    stack[n] = result
  return stack
