/mob/living/humanoid/biological
	gender = MALE
//	var/datum/species/species
	var/list/stomach_contents = list()
	var/list/datum/disease2/disease/virus2 = list()
	var/list/antibodies = list()
	var/last_eating = 0 	//Not sure what this does... I found it hidden in food.dm

	var/analgesic = 0 // when this is set, the mob isn't affected by shock or pain
					  // life should decrease this by 1 every tick
	//Surgery info
	var/datum/surgery_status/op_stage = new/datum/surgery_status
	//Active emote/pose
	var/pose = null

	var/pulse = PULSE_NORM	//current pulse level