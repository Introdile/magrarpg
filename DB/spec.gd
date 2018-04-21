extends Node

#needs: name, stat growths, skill list, equipment types, spec upgrade
export(int) var id = -1
export(String) var name = ""
export(String) var type = "" #Damage, Tank, Support
export(String) var desc = "A specialization."

export(int, "VERY SLOW", "SLOW", "MEDIUM", "FAST", "VERY FAST") var _HP_grw = 0
export(int, "VERY SLOW", "SLOW", "MEDIUM", "FAST", "VERY FAST") var _EN_grw = 0

export(int, "VERY SLOW", "SLOW", "MEDIUM", "FAST", "VERY FAST") var _MG_grw = 0
export(int, "VERY SLOW", "SLOW", "MEDIUM", "FAST", "VERY FAST") var _AM_grw = 0

export(int, "VERY SLOW", "SLOW", "MEDIUM", "FAST", "VERY FAST") var _PT_grw = 0
export(int, "VERY SLOW", "SLOW", "MEDIUM", "FAST", "VERY FAST") var _EC_grw = 0

export(int, "VERY SLOW", "SLOW", "MEDIUM", "FAST", "VERY FAST") var _DG_grw = 0
export(int, "VERY SLOW", "SLOW", "MEDIUM", "FAST", "VERY FAST") var _SD_grw = 0

var p_stats = [_HP_grw,_EN_grw,_MG_grw,_AM_grw,_PT_grw,_EC_grw,_DG_grw,_SD_grw]

export(Array) var skill_list = []
export(Array) var skill_learn_level = []

export(Array) var upgrade_levels = []
export(Array) var upgrade_specs = []

export(int) var equip_type = 0
