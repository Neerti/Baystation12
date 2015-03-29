/datum/hud/proc/mecha_hud()

	src.adding = list()
	src.other = list()

//Health (of the pilot)
	pilot_health = new /obj/screen()
	pilot_health.icon = 'icons/mob/screen1_mecha.dmi'
	pilot_health.icon_state = "health0"
	pilot_health.name = "pilot health"
	pilot_health.screen_loc = ui_health

//Health (of the mech)
	mymob.healths = new /obj/screen()
	mymob.healths.icon = 'icons/mob/screen1_mecha.dmi'
	mymob.healths.icon_state = "integrity"
	mymob.healths.name = "integrity"
	mymob.healths.screen_loc = ui_internal

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