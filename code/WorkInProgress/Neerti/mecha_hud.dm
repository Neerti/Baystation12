/datum/hud/proc/mecha_hud()

	src.adding = list()
	src.other = list()

	var/obj/screen/using

//Radio
	using = new /obj/screen()
	using.name = "radio"
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_mecha.dmi'
	using.icon_state = "radio"
	using.screen_loc = ui_movi
	using.layer = 20
	src.adding += using

//Equipment select
/*
	using = new /obj/screen()
	using.name = "slot 1"
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_mecha.dmi'
	using.icon_state = "inv1"
	using.screen_loc = ui_mecha_slot1
	using.layer = 20
	src.adding += using
	mymob:inv1 = using

	using = new /obj/screen()
	using.name = "slot 2"
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_mecha.dmi'
	using.icon_state = "inv2"
	using.screen_loc = ui_mecha_slot2
	using.layer = 20
	src.adding += using
	mymob:inv2 = using

	using = new /obj/screen()
	using.name = "slot 3"
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_mecha.dmi'
	using.icon_state = "inv3"
	using.screen_loc = ui_mecha_slot3
	using.layer = 20
	src.adding += using
	mymob:inv3 = using

	using = new /obj/screen()
	using.name = "slot 4"
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_mecha.dmi'
	using.icon_state = "inv4"
	using.screen_loc = ui_mecha_slot4
	using.layer = 20
	src.adding += using
	mymob:inv4 = using
*/
//End of module select

//Intent
	using = new /obj/screen()
	using.name = "act_intent"
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_mecha.dmi'
	using.icon_state = (mymob.a_intent == "hurt" ? "harm" : mymob.a_intent)
	using.screen_loc = ui_acti
	using.layer = 20
	src.adding += using
	action_intent = using


//Health (of the pilot)
	pilot_health = new /obj/screen()
	pilot_health.icon = 'icons/mob/screen1_mecha.dmi'
	pilot_health.icon_state = "health0"
	pilot_health.name = "pilot health"
	pilot_health.screen_loc = ui_internal

//Health (of the mech)
	mymob.healths = new /obj/screen()
	mymob.healths.icon = 'icons/mob/screen1_mecha.dmi'
	mymob.healths.icon_state = "integrity"
	mymob.healths.name = "integrity"
	mymob.healths.screen_loc = ui_health

//Battery
	mecha_battery = new /obj/screen()
	mecha_battery.icon = 'icons/mob/screen1_mecha.dmi'
	mecha_battery.icon_state = "charge"
	mecha_battery.name = "battery charge"
	mecha_battery.screen_loc = ui_mecha_battery

/*
	mymob.internals = new /obj/screen()
	mymob.internals.icon = 'icons/mob/screen1_mecha.dmi'
	mymob.internals.icon_state = "internal0"
	mymob.internals.name = "internal"
	mymob.internals.screen_loc = ui_internal
*/
	mymob.client.screen = null

	mymob.client.screen += list(pilot_health, mymob.healths, mecha_battery)

	mymob.client.screen += src.adding + src.other


/datum/hud/proc/update_mecha_equipment_display()
	if(!ismecha(mymob))
		return

	var/mob/living/vehicle/mecha/M = mymob

//	var/display_rows
//	world << "[M.equipment.len] is how many equipment is on [mymob]."
//	if(M.equipment.len <= 3)
//		display_rows = 0
//		world << "I forced zero row."
//	else
//	display_rows = Ceiling(M.equipment.len / 3)
//	display_rows = round(round((M.equipment.len) / 3) +0.25) //+0.25 because round() returns floor of number
//	world << "display_rows equals [display_rows], since M.equipment.len ([M.equipment.len]) / 3 = [M.equipment.len / 3], plus 0.25."

//	M.inv_background.screen_loc = "CENTER-1:0,SOUTH+0:7 to CENTER+1:0,SOUTH-1+[display_rows]:7"
	//"CENTER-1:16,SOUTH+0:7 to CENTER+1:16,SOUTH+[display_rows]:7"
//	M.client.screen += M.inv_background

	var/x = -1	//Start at CENTER-4,SOUTH+1
	var/y = 0

	var/last_index = 1

	for(var/atom/movable/A in M.equipment)
//		if( (A != r.module_state_1) && (A != r.module_state_2) && (A != r.module_state_3) )
			//Module is not currently active
		var/obj/screen/inv_slot/S = new()
		M.client.screen += S
		S.index = last_index
		last_index++
		M.client.screen += A
		if(x < 0)
			A.screen_loc = "CENTER[x]:0,SOUTH+[y]:7"
			S.screen_loc = "CENTER[x]:0,SOUTH+[y]:7"
						//"CENTER[x]:16,SOUTH+[y]:7"
		else
			A.screen_loc = "CENTER+[x]:0,SOUTH+[y]:7"
			S.screen_loc = "CENTER+[x]:0,SOUTH+[y]:7"
						//"CENTER+[x]:16,SOUTH+[y]:7"
		A.layer = 20

		x++
		if(x == 2)
			x = -1
			y++