extends Node

export(String) var name = ""
export(int) var id = 0
export(String) var desc = ""

export(int, "Melee", "Ranged", "Magic") var type
export(int, "Foes", "All Foes", "Allies", "All Allies", "Field", "All") var targetType = 0
export(int) var power = 0
export(int) var cost = 0
export(int) var cooldown = 0
export(int) var threat = 5