extends Node

static func calculate_stat(apt,grw,level):
	
	#0 is WEAK, 1 is AVG, and 2 is STRONG
	if apt == 0:
		apt = 4
	elif apt == 1:
		apt = 8
	elif apt == 2:
		apt = 10
	
	#0 is V SLOW, 1 is SLOW, 2 is MEDIUM, 3 is FAST, 4 is V FAST
	if grw == 0:
		grw = 1.4
	elif grw == 1:
		grw = 1.45
	elif grw == 2:
		grw = 1.5
	elif grw == 3:
		grw = 1.525
	elif grw == 4:
		grw = 1.575
	
	return (apt + pow(level,grw) / 1.5) - 1

static func calculate_hp(apt,grw,level):
	
	#0 is WEAK, 1 is AVG, and 2 is STRONG
	if apt == 0:
		apt = 48
	elif apt == 1:
		apt = 64
	elif apt == 2:
		apt = 80
	
	#0 is V SLOW, 1 is SLOW, 2 is MEDIUM, 3 is FAST, 4 is V FAST
	if grw == 0:
		grw = 1.4
	elif grw == 1:
		grw = 1.45
	elif grw == 2:
		grw = 1.5
	elif grw == 3:
		grw = 1.525
	elif grw == 4:
		grw = 1.575
	
	return (apt + pow(level,grw) * 4) - 1

static func calculate_en(apt,grw,level):
	
	#0 is WEAK, 1 is AVG, and 2 is STRONG
	if apt == 0:
		apt = 16
	elif apt == 1:
		apt = 32
	elif apt == 2:
		apt = 48
	
	#0 is V SLOW, 1 is SLOW, 2 is MEDIUM, 3 is FAST, 4 is V FAST
	if grw == 0:
		grw = 1.4
	elif grw == 1:
		grw = 1.45
	elif grw == 2:
		grw = 1.5
	elif grw == 3:
		grw = 1.525
	elif grw == 4:
		grw = 1.575
	
	return (apt + pow(level,grw) * 1.5) - 1

static func calculate_exp(level):
	return 4 * pow(level,2) - (4 * level)