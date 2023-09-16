extends Node
class_name DiceCombo

enum {
	HIGHEST,
	PAIR,
	TWO_PAIRS,
	TRIPLE,
	STRAIGHT_SMALL,
	STRAIGHT_BIG,
	FULLHOUSE,
	POKER_SMALL,
	POKER_BIG
}

var combo: int
var combo_dice: int = -1
var combo_dice_lower: int = -1
var counts: Array[int]

func _init(counts: Array[int]):
	self.counts = counts
	
	combo = HIGHEST
	
	#highest
	for i in range(counts.size()):
		if counts[i] == 1:
			combo_dice = i+1
	
	#pair and two pairs
	for i in range(counts.size()):
		if counts[i] == 2:
			if combo == PAIR:
				combo = TWO_PAIRS
				combo_dice_lower = combo_dice
			else:
				combo = PAIR
			combo_dice = i+1
	
	#triple and fullhouse
	for i in range(counts.size()):
		if counts[i] == 3:
			if combo == PAIR:
				combo = FULLHOUSE
				combo_dice_lower = combo_dice
			else:
				combo = TRIPLE
			combo_dice = i+1
	
	#straights
	if counts.count(0) == 1:
		if [counts[0], counts[1], counts[2], counts[3], counts[4]].count(1) == 5:
			combo = STRAIGHT_SMALL
		elif [counts[1], counts[2], counts[3], counts[4], counts[5]].count(1) == 5:
			combo = STRAIGHT_BIG
	
	#pokers
	for i in range(counts.size()):
		if counts[i] > 3:
			combo_dice = i+1
			if counts[i] == 4:
				combo = POKER_SMALL
			else:
				combo = POKER_BIG
	
	var combo_text = ''
	match(combo):
		PAIR:
			combo_text = 'pair of '+str(combo_dice)
		TRIPLE:
			combo_text = 'triple of '+str(combo_dice)
		TWO_PAIRS:
			combo_text = 'two pairs: '+str(combo_dice)+' and '+str(combo_dice_lower)
		FULLHOUSE:
			combo_text = 'fullhouse: '+str(combo_dice)+' and '+str(combo_dice_lower)
		STRAIGHT_BIG:
			combo_text = 'big straight'
		STRAIGHT_SMALL:
			combo_text = 'small straight'
		HIGHEST:
			combo_text = 'no combo, highest dice: '+str(combo_dice)
		POKER_BIG:
			combo_text = 'big poker of '+str(combo_dice)
		POKER_SMALL:
			combo_text = 'small poker of '+str(combo_dice)
	print(str(combo) +' '+ combo_text)

func compare(another: DiceCombo) -> int:
	if combo == another.combo:
		if combo_dice == another.combo_dice:
			if combo_dice_lower == another.combo_dice_lower:
				return 0
			elif combo_dice_lower > another.combo_dice_lower:
				return 1
			else:
				return -1
		elif combo_dice > another.combo_dice:
			return 1
		else:
			return -1
	elif combo > another.combo:
		return 1
	else:
		return -1
