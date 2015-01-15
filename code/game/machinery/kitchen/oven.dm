/obj/machinery/oven
	name = "Oven"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "oven"
	desc = "It's a nice, clean electric oven."
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 300
	var/on = 0
	var/internal_temp = 20 //C.  Note that this does NOT use atmos temp code.
	var/target_temp = 20 //C
	var/min_temp = 20 //C
	var/max_temp = 260 //C
	var/open = 0 //Are we 'open'?

	var/obj/item/weapon/reagent_containers/kitchen/food_inside = null

/obj/machinery/oven/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/reagent_containers/kitchen))
		user.visible_message(\
			"<span class='notice'>[user] has added \the [O] to [src].</span>", \
			"<span class='notice'>You add \the [O] to [src].</span>")
		user.drop_item()
		O.loc = src.loc //Put it on top.
	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/))
		user << "You need a container for your [O]."
	else
		user << "You don't think you could make anything useful with \the [O]."

/obj/machinery/oven/attack_ai(mob/user as mob)  //Wireless ovens are the future.
	attack_hand(user)

/obj/machinery/oven/attack_hand(mob/user as mob)
	ui_interact(user)

/obj/machinery/oven/process()
	handle_heat()
	..()

	if(stat & (NOPOWER|BROKEN) || !on)
		update_use_power(0)
		on = 0
		return

	if(on)
		update_use_power(2)

	else
		update_use_power(1)



/obj/machinery/oven/proc/handle_heat()
	if(on && internal_temp < target_temp && !open) //It's on, not open, and we want to get hotter.
		internal_temp++
	else if(open && internal_temp > 20 || internal_temp > target_temp) //Open, or temperature's too high, let heat escape (to nowhere).
		internal_temp--
	else if(internal_temp > 20 && !on) //It's turned off, let the heat disappear magically.
		internal_temp--
	if(food_inside)
		apply_heat(internal_temp)

/obj/machinery/oven/proc/apply_heat(var/temperature)
	if(food_inside)
		if(istype(food_inside, /obj/item/weapon/reagent_containers/kitchen))
			switch(temperature)
				if(0 to 60) //C.  Don't bother doing anything if it's lower.
					return
				/*
				if(61 to 110) //C
					food_inside.heat++
				if(111 to 160) //C
					food_inside.heat += 2.0
				if(161 to 210) //C
					food_inside.heat += 5.0
				if(211 to 260) //C
					food_inside.heat += 10.0
				*/
				if(60 to INFINITY)
					food_inside.heat += (temperature - 60) * 0.1
			food_inside.time_to_finish -= 1.0
			if(food_inside.time_to_finish == 0)
				food_inside.finish()



/obj/machinery/oven/update_icon()
	if(on && !open)
		icon_state = "oven_on"
	else if(on && open)
		icon_state = "oven_on_open"
	else if (!on && open)
		icon_state = "oven_open"
	else
		icon_state = "oven"
	..()

/obj/machinery/oven/proc/toggle_open(mob/user as mob)
	if(open)
		open = 0
		for(var/obj/item/weapon/reagent_containers/kitchen/O in src.loc)
			if(contents.len >= 1) //Only one object can be held.
				user << "The [src] is full!"
			else
				O.loc = src
				food_inside = O
	else
		open = 1
		for(var/obj/O in contents)
			O.loc = src.loc
			food_inside = null
		user << "You open the [src]."

/obj/machinery/oven/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	// this is the data which will be sent to the ui
	var/data[0]
	data["on"] = on ? 1 : 0
	data["open"] = open ? 1 : 0
	data["internalTemp"] = internal_temp
	data["targetTemp"] = target_temp
	data["minTemp"] = min_temp
	data["maxTemp"] = max_temp
	data["contents"] = food_inside

	var/temp_class = "normal" //refering to temperature, not temporary.
	switch(internal_temp)
		if(0 to 59)
			temp_class = "normal"
		if(60 to 159)
			temp_class = "good"
		if(160 to 219)
			temp_class = "average"
		if(220 to INFINITY)
			temp_class = "bad"
	data["tempClass"] = temp_class
	var/temp_target_class = "normal" //refering to temperature, not temporary.
	switch(target_temp)
		if(0 to 59)
			temp_target_class = "normal"
		if(60 to 159)
			temp_target_class = "good"
		if(160 to 219)
			temp_target_class = "average"
		if(220 to INFINITY)
			temp_target_class = "bad"
	data["tempTargetClass"] = temp_target_class

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "oven.tmpl", "Oven", 440, 300)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/oven/Topic(href, href_list)
	if (href_list["togglePower"])
		src.on = !src.on
		update_use_power(on)
		update_icon()

	if(href_list["temp"])
		var/amount = text2num(href_list["temp"])
		if(amount > 0)
			src.target_temp = min(src.target_temp+amount, max_temp)
		else
			src.target_temp = max(src.target_temp+amount, 0)
	if(href_list["toggleOpen"])
		toggle_open()
		update_icon()

	if(href_list["inspect"])
		if(food_inside)
			world << "[food_inside.heat] HEAT"
			world << "[food_inside.time_to_finish] TIME"

	src.add_fingerprint(usr)
	return 1