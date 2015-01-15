/obj/machinery/stove
	name = "stove"
	desc = "It's a compact stove, able to cook four things at once!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "stove"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 300

	var/on = 0 //Is it on?
	var/list/slots = list()
	var/used_slots = 0
	/*
	var/obj/item/weapon/reagent_containers/kitchen/slot_1 = null
	var/obj/item/weapon/reagent_containers/kitchen/slot_2 = null
	var/obj/item/weapon/reagent_containers/kitchen/slot_3 = null
	var/obj/item/weapon/reagent_containers/kitchen/slot_4 = null
	*/

/obj/machinery/stove/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/reagent_containers/kitchen))
		user.visible_message(\
			"<span class='notice'>[user] has added \the [O] to [src].</span>", \
			"<span class='notice'>You add \the [O] to [src].</span>")
		user.drop_item()
		O.loc = src
		slots.Add(O)
		used_slots++
	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/))
		user << "You need a container for your [O]."
	else
		user << "You don't think you could make anything useful with \the [O]."

/obj/machinery/stove/attack_ai(mob/user as mob)  //Wireless stoves are the future.
	attack_hand(user)

/obj/machinery/stove/attack_hand(mob/user as mob)
	ui_interact(user)

obj/machinery/stove/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	// this is the data which will be sent to the ui
	var/data[0]
	data["on"] = on ? 1 : 0
	data["contents"] = slots[1,2,3,4]
	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "stove.tmpl", "Stove", 440, 300)
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

	src.add_fingerprint(usr)
	return 1