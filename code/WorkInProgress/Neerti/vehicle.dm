/mob/vehicle
	name = "Vehicle"
	desc = "Vhroom"

	var/icon_closed = null

	var/lights = 0
	var/lights_power = 6

	var/open = 1 //Determines if someone can get in or not.
	var/sealed = 0 //Determines if the internal atmosphere is from the outside world or from the internal oxy supply.

//	var/obj/screen/pilot_health = null
	var/last_pilot_health = null

	//Interior stuff
	var/mob/living/pilot = null

	var/list/passenger_slots = null
	var/max_passengers = 2
	var/obj/item/weapon/cell/cell
	var/datum/effect/effect/system/spark_spread/spark_system = new
	var/obj/item/device/radio/radio = null

	//Defense
	var/health = 300
	var/max_health = 300
	var/deflect_chance = 10 //chance to deflect the incoming projectiles, hits, or lesser the effect of ex_act.
	//the values in this list show how much damage will pass through, not how much will be absorbed.
	var/list/damage_absorption = list("brute"=0.8,"fire"=1.2,"bullet"=0.9,"laser"=1,"energy"=1,"bomb"=1)

/mob/vehicle/New()
	if(max_passengers)
		passenger_slots = new/list()
	..()

/mob/vehicle/proc/can_act()
	if(!pilot) //This shouldn't happen.
		src << "<span class='danger'>No pilot detected.</span>"
		return 0
	if(pilot.stat)
		src << "<span class='danger'>You cannot control \the [src] because you are unconscious or dead.</span>"
		return 0
	if(open)
		src << "<span class='danger'>\The [src] must be closed first!</span>"
		return 0
	return 1

/mob/vehicle/MouseDrop()
	return

/mob/vehicle/update_icons()
	if(open)
		icon_state = initial(icon_state)
	else
		icon_state = icon_closed

/mob/vehicle/Del()
	if(pilot)
		get_out(pilot,1)
	for(var/mob/living/M in passenger_slots)
		M.loc = get_turf(src)
	..()

/mob/vehicle/proc/get_out(var/mob/user, var/forced = 0) //Since only the pilot can use this verb, no need to check for passengers.
	if(pilot)
		if(can_act() || forced == 1)
			pilot.key = user.key
			pilot.loc = get_turf(src)
			if(forced)
				pilot << "You are forced out of \the [src]."
			else
				pilot << "You climb out of \the [src]'s pilot seat."
			pilot = null
			open = 1
			sealed = 0
			update_icons()
			return
	else //This should never happen.
		user << "Your pilot mob appears to have ceased existing.  This is a bug and it's recommended to adminhelp it immediately, and make a bug report."

/mob/vehicle/proc/get_out_passenger(var/mob/user)
	user.loc = get_turf(src)
	for(user in passenger_slots)
		passenger_slots.Remove(user)
	if(passenger_slots.len == 0) //Don't lock them out if no one else is inside.
		open = 1
		sealed = 0
		update_icons()
	user << "You climb out of \the [src]'s passenger seat."

/mob/vehicle/proc/get_seat_wanted(var/mob/living/user)
	if(!pilot && !isnull(passenger_slots) && passenger_slots.len < max_passengers) //Check if both are available.
	//If both are available, let the player choose.
		var/response = alert(user,"Would you like to enter the pilot or the passenger seat?","Seat selection","Pilot","Passenger","Cancel")
		switch(response)
			if("Pilot")
				return 1
			if("Passenger")
				return 2
			if("Cancel")
				return 0
	//Assume the person wants to be the pilot if they can't decide for themselves.
	else if(!pilot)
		return 1
	//Pilot is taken, any room in the back?
	else if(!isnull(passenger_slots) && (passenger_slots.len < max_passengers))
		return 2
	//No room for you, sorry.
	else
		user << "\The [src] is full."
		return 0


/mob/vehicle/proc/get_in(var/mob/living/user, var/explicit = 0)
	if(user.stat || user.restrained() || !isliving(user))
		return

	var/response
	if(!explicit) //The desired seat wasn't passed, so let's find one.
		response = get_seat_wanted(user)
	else
		response = explicit //We know what we want, don't need to ask twice.
	switch(response)
		if(0) //Full or they declined.
			return
		if(1) //Pilot
			user.visible_message("<span class='notice'>[user] starts to climb into \the [src]'s pilot seat.</span>")
			if(!do_after(user,40))
				user.visible_message("<span class='notice'>[user] decides to not enter \the [src].</span>")
				return
			if(pilot) //Check to ensure two or more people trying to get the same seat doesn't occur.
				user << "<span class='notice'>[pilot] was faster then you.</span>"
				return
			user.visible_message("<span class='notice'>[user] climbs into \the [src]</span>")
			pilot = user
			key = user.key
		if(2) //Passenger
			user.visible_message("<span class='notice'>[user] starts to climb into \the [src]'s passenger seat.</span>")
			if(!do_after(user,40))
				user.visible_message("<span class='notice'>[user] decides to not enter \the [src].</span>")
				return
			if(passenger_slots.len >= max_passengers)
				user << "<span class='notice'>\The [src] had a seat, but someone took it, and there's no more room.</span>"
				return
			user.visible_message("<span class='notice'>[user] climbs into \the [src]</span>")
			passenger_slots.Add(user)
	user.loc = src

/mob/vehicle/MouseDrop_T(mob/target, mob/user)
	var/mob/living/M = user
	if(user.stat || user.restrained())
		return
	if(istype(M))
		get_in(user)
	else
		return ..()

/mob/vehicle/attack_hand(var/mob/user)
	if(isliving(user))
		if(user.loc == src) //are we inside already?
			if(!pilot) //if there's no pilot, ask if they want to take control or to exit.
				var/response = alert(user,"There is no pilot.  Would you like to take control or exit?",,"Pilot","Exit","Cancel")
				switch(response)
					if("Pilot")
						get_in(user,1)
					if("Exit")
						get_out_passenger(user)
					else
						return
			else
				get_out_passenger(user)
		else
			if(open)
				get_in(user)
			else
				user << "There's no way to get inside \the [src]."

/mob/vehicle/Process_Spaceslipping()
	return

/mob/vehicle/verb/eject()
	set name = "Eject Exosuit"
	set category = "Exosuit Interface"
//	set src = usr.loc
	set popup_menu = 0
//	if(usr!=src.occupant)
//		return
	src.get_out(usr)
	add_fingerprint(usr)
	return

/mob/vehicle/verb/swap_to_pilot()
	set name = "Release Controls"
	set desc = "Relinquish controls to the vehicle, so you can adjust yourself or have someone else take control."
	set category = "Exosuit Interface"
	if(pilot)
		if(pilot.stat)
			pilot << "You let go of the controls and sit back."
		else
			pilot << "Your limp body falls out of the pilot seat." //We want them to still be able to switch back to their old mob, for any reason.
		pilot.key = usr.key
		pilot = null

/mob/vehicle/verb/toggle_open()
	set name = "Toggle Open/Close"
	set desc = "Controls exterior entry port status.  The vehicle must be closed to function."
	set category = "Exosuit Interface"
	if(pilot)
		open = !open
		update_icons()
		src << "Toggled doors [open ? "open" : "closed"]."
		if(open)
			if(sealed)
				sealed = 0
				src << "Disengaging seals."

/mob/vehicle/verb/toggle_seals()
	set name = "Toggle Seals"
	set desc = "Determines if the vehicle is sealed from external gases or not..  The vehicle must be closed to seal."
	set category = "Exosuit Interface"
	if(pilot)
		if(open)
			src << "\The [src] must be closed first."
			return
		sealed = !sealed
		src << "Toggled seals [sealed ? "on" : "off"]."

/mob/vehicle/verb/toggle_lights()
	set name = "Toggle Lights"
	set category = "Exosuit Interface"
//	set src = usr.loc
	set popup_menu = 0
	if(usr!=pilot)
		return
	lights = !lights
	if(lights)
		SetLuminosity(luminosity + lights_power)
	else
		SetLuminosity(luminosity - lights_power)
	src << ("Toggled lights [lights?"on":"off"].")
	return

/mob/vehicle/verb/enter()
	set name = "Enter Exosuit"
	set category = "Exosuit Interface"
	set src = usr.loc
	src.get_in(usr)
	return