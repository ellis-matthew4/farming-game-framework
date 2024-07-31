extends Node

var shops = {
  "sample_shop": [
    "generic_seeds",
    "generic_sapling",
    "fertilizer"
  ]
}

func get_shop(context):
  return shops[context]
