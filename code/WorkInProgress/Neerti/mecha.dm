/mob/vehicle/mecha
	name = "Mecha"
	desc = "Exosuit"
	icon = 'icons/mecha/mecha.dmi'
	icon_state = "ripley-open"
	icon_closed = "ripley"
	density = 1
	opacity = 1
	anchored = 1
	unacidable = 1
	layer = MOB_LAYER
	infra_luminosity = 15

	var/last_dir = 2 //The dir we were facing last step.

	var/step_sound = 'sound/mecha/mechstep.ogg'
	var/turn_sound = 'sound/mecha/mechturn.ogg'

	var/step_in = 4 //How fast the mecha goes.  Higher numbers = slower
//	var/dir_in = 2//What direction will the mech face when entered/powered on? Defaults to South.
	var/step_energy_drain = 1000

//VERBS! and procs too i guess

/mob/vehicle/mecha/New()
	add_cell()
	..()

/mob/vehicle/mecha/can_act()
	if(!pilot) //This shouldn't happen.
		src << "<span class='danger'>No pilot detected.</span>"
		return 0
	if(pilot.stat)
		src << "<span class='danger'>You cannot control \the [src] because you are unconscious or dead.</span>"
		return 0
	if(!cell || cell.charge <= 0)
		src << "<span class='danger'>Your mecha's powercell is empty or nonexistent.</span>"
		return 0
	if(open)
		src << "<span class='danger'>\The [src] must be closed first!</span>"
		return 0
	return 1

/mob/vehicle/mecha/movement_delay()
	return step_in

/mob/vehicle/mecha/Move(var/newloc, var/direct)
	if(can_act()) //Are we able to move? (Our pilot is alive, we have power, etc.)
		drain_power(0, 0, step_energy_drain)
		if(direct != last_dir) //Are we turning?
			set_dir(direct)
			last_dir = dir
			playsound(src,turn_sound,40,1)
			return

		. = ..() //If not, let's try to move.
		if(.) //If successful, make big stompy noises.
			playsound(src,step_sound,40,1)
		last_dir = dir //Likely not needed, but better safe then sorry.


/mob/vehicle/mecha/drain_power(var/drain_check, var/surge, var/amount = 0)

	if(drain_check)
		return 1

	if(!cell)
		return 0
	else
//		world << "Draining [amount] from [cell]."
		cell.drain_power(drain_check, 0, amount)
		handle_hud_battery()
//		world << "[cell] now has [cell.charge] out of [cell.maxcharge]."

/mob/vehicle/mecha/Life()
	..()
	if(src.client) //HUD stuff
		handle_hud_integrity()
		handle_hud_pilot_health()
//		handle_hud_battery()
	if(pilot)
		src.stat = pilot.stat

/mob/vehicle/mecha/proc/handle_hud_pilot_health()
	if(pilot && pilot.health)
		if(pilot.health == last_pilot_health) //Don't bother computing the percentage and changing the icon if no change occured.
			return
		var/health_percentage = pilot.health / pilot.maxHealth //In decimal form
		var/output = 0
		if (pilot.stat != 2)
			switch(health_percentage)
				if(INFINITY to 1.00)//full
					output = 0
				if(0.80 to 0.99) //99%
					output = 1
				if(0.60 to 0.80) //80%
					output = 2
				if(0.40 to 0.60) //60%
					output = 3
				if(0.20 to 0.40) //40%
					output = 4
				if(0.00 to 0.20) //20%
					output = 5
				if(-2.00 to 0) //crit
					output = 6
		else //dead
			output = 7
		last_pilot_health = pilot.health
		hud_used.pilot_health.icon_state = "health[output]"

/mob/vehicle/mecha/proc/handle_hud_integrity()
	var/output = round( (health / max_health) * 100, 1)
	healths.maptext = null
	healths.maptext = "<div align='left' valign='middle'> <font color='green'>[output]%</font></div>"

/mob/vehicle/mecha/proc/handle_hud_battery()
	if(cell)
		var/output = round( (cell.charge / cell.maxcharge) * 100, 1)
		hud_used.mecha_battery.maptext = null
		hud_used.mecha_battery.maptext = "<div align='left' valign='middle'> <font color='white'>[output]%</font></div>"
	else
		hud_used.mecha_battery.maptext = null
		hud_used.mecha_battery.maptext = "<div align='left' valign='middle'> <font color='red'>NO CELL</font></div>"

/mob/vehicle/mecha/proc/add_cell(var/obj/item/weapon/cell/C=null)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new(src)
	cell.name = "high-capacity power cell"
	cell.charge = 15000
	cell.maxcharge = 15000
