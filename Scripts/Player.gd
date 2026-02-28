extends RefCounted
class_name PlayerData

var name: String = "Bot"
var is_bot: bool = true
var hand: Array = []       
var draft_hand: Array = [] 
var score: int = 50
var tricks_won: int = 0
var position_index: int = 0

func _init(_name: String, _is_bot: bool, _index: int):
	name = _name
	is_bot = _is_bot
	position_index = _index
