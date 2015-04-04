/mob/living/vehicle/mecha
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

//	var/obj/screen/inv1 = null
//	var/obj/screen/inv2 = null
//	var/obj/screen/inv3 = null
//	var/obj/screen/inv4 = null

//	var/list/inv_slots = new/list()
//	var/obj/screen/inv_slot = new()

	var/obj/screen/pilot_health = null
	var/obj/screen/cell_hud = null

	var/max_temperature = 25000

	var/last_dir = 2 //The dir we were facing last step.

	var/step_sound = 'sound/mecha/mechstep.ogg'
	var/turn_sound = 'sound/mecha/mechturn.ogg'

	var/step_in = 4 //How fast the mecha goes.  Higher numbers = slower
	var/step_energy_drain = 100

	var/report_damage = 0 //Determines if damage information is sent to the client piloting this.  This replaces the damage logs that old mechs had.
	var/safety_ejection = 1 //Auto-ejects the pilot if they enter crit or die.  Can be toggled off.

	var/datum/effect/effect/system/spark_spread/spark_system

	//inner atmos
	var/use_internal_tank = 0
	var/internal_tank_valve = ONE_ATMOSPHERE
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	var/datum/gas_mixture/cabin_air
	var/obj/machinery/atmospherics/portables_connector/connected_port = null

	var/list/equipment = new/list()
	var/max_equipment = 3
	var/obj/item/weapon/selected


/obj/screen/inv_slot
	name = "equipment slot"
	icon = 'icons/mob/screen1_mecha.dmi'
	icon_state = "inv"
	layer = 19 //Objects that appear on screen are on layer 20, UI should be just below it.
	var/index = 0 //Used to determine which item on the list to select when clicked.

/obj/screen/inv_slot/Click(location, control, params)
	if(!usr)
		return 1

	if(!ismecha(usr))
		return

	var/mob/living/vehicle/mecha/M = usr

	var/target_index = src.index


	if(!M.selected) //We have no equipment active.
		M.selected = M.equipment[target_index]
		src.icon_state = "inv-active"

	else if(M.selected == M.equipment[target_index]) //We are selecting a slot already active.
		M.selected = null //Unselect it.
		src.icon_state = "inv"

	else if(M.selected != M.equipment[target_index]) //We have a different slot selected.
		for(var/obj/screen/inv_slot/I in M.client.screen) //Unselect everything else.
			I.icon_state = "inv"
		M.selected = M.equipment[target_index] //Select the new slot
		src.icon_state = "inv-active"

	M.on_equipment_select()





//VERBS! and procs too i guess

/mob/living/vehicle/mecha/New()
	add_cell()
	add_airtank()
	spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

//	inv_background = new()
//	inv_background.name = "equipment"
//	inv_background.icon_state = "inv"
//	inv_background.layer = 19 //Objects that appear on screen are on layer 20, UI should be just below it.
//	inv_background.icon = 'icons/mob/screen1_mecha.dmi'



	//DEBUG
	equipment.Add(new /obj/item/weapon/bikehorn/rubberducky(src))
	equipment.Add(new /obj/item/weapon/gun/energy/gun/nuclear(src))
	equipment.Add(new /obj/item/weapon/melee/energy/sword/pirate(src))
//	inv_slots.Add(new /obj/screen/inv_slot(src))
//	inv_slots.Add(new /obj/screen/inv_slot(src))
//	inv_slots.Add(new /obj/screen/inv_slot(src))
	..()

/mob/living/vehicle/mecha/verb/toggle_report_damage()
	set name = "Toggle Report Damage"
	set desc = "Enables or disables realtime damage reporting."
	set category = "Exosuit Interface"

	report_damage = !report_damage
	src << "Realtime damage reporting is now [report_damage ? "on" : "off"]."
	return

/mob/living/vehicle/mecha/verb/toggle_safety_ejection()
	set name = "Toggle Auto-Eject"
	set desc = "Toggles an automatic mechanism which will eject you out of the exosuit, if you should suffer life-threatening harm."
	set category = "Exosuit Interface"

	report_damage = !report_damage
	src << "Auto-ejection is now [safety_ejection ? "armed" : "disarmed"]."
	return

/mob/living/vehicle/mecha/on_pilot_entry()
	//Update the HUD once.
	handle_hud_integrity()
	handle_hud_pilot_health()
	handle_hud_battery()
	hud_used.update_mecha_equipment_display()
	..()

/mob/living/vehicle/mecha/on_pilot_exit()
	selected = null
	on_equipment_select()
	..()

/mob/living/vehicle/mecha/proc/on_equipment_select()
	if(selected)
		visible_message("<span class='notice'>\The [src] raises \the [selected].</span>")
	else
		visible_message("<span class='notice'>\The [src] lowers their equipment.</span>")
	return

/mob/living/vehicle/mecha/can_act()
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

//**************
//*DAMAGE PROCS*
//**************

//mob/living/proc/apply_damage(var/damage = 0,var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0, var/used_weapon = null, var/sharp = 0, var/edge = 0)

/mob/living/vehicle/mecha/apply_damage(amount, type = BRUTE)
	if(amount)
		var/damage = absorb_damage(amount,type) //Reduce the damage somewhat, depending on our armor.
		health -= damage //After the reduction, remove some health.
		updatehealth() //Make sparks and update the HUD, also check if we should be dead.
		if(report_damage) //If the pilot wants, tell them how bad the hurt was.
			src << "Took [damage] points of damage.  Type of damage: \"[type]\""
	return

/*
/mob/living/vehicle/mecha/proc/take_damage(amount, type = "brute")
	if(amount)
		var/damage = absorb_damage(amount,type) //Reduce the damage somewhat, depending on our armor.
		health -= damage //After the reduction, remove some health.
		updatehealth() //Make sparks and update the HUD, also check if we should be dead.
		if(report_damage) //If the pilot wants, tell them how bad the hurt was.
			src << "Took [damage] points of damage.  Type of damage: \"[type]\""
	return
*/
/mob/living/vehicle/mecha/proc/absorb_damage(amount, type)
	var/damage = amount * (listgetindex (damage_absorption,type) || 1)
	return damage

/mob/living/vehicle/mecha/updatehealth()
	if(src.health > 0)
		src.spark_system.start()
		if(client)
			handle_hud_integrity() //Update the health indicator.  This is done here, so it only updates when needed, instead of inside Life()
	else
		src.visible_message("<span class='danger'>\The [src] falls apart.</span>")
		src.Del() //This is overriden, so it's safe to call it.
	return

/mob/living/vehicle/mecha/bullet_act(var/obj/item/projectile/Proj)
	if(prob(src.deflect_chance))
		src.visible_message("<span class='notice'>The [src] armor deflects \the [Proj].</span>")
		if(report_damage)
			src << "Armor saved."
		return

	if(Proj.damage_type == HALLOSS)
		drain_power(Proj.agony * 5)

	if(!(Proj.nodamage))
//		var/ignore_threshold
//		if(istype(Proj, /obj/item/projectile/beam/pulse))
//			ignore_threshold = 1
		src.apply_damage(Proj.damage, Proj.check_armour)
		src.visible_message("<span class='danger'>[src] was hit by \the [Proj]!</span>")
		if(prob(25))
			spark_system.start()
//		src.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),ignore_threshold)

		//AP projectiles have a chance to cause additional damage
		if(Proj.penetrating)
			var/distance = get_dist(Proj.starting, get_turf(loc))
			var/hit_pilot = 1 //only allow the pilot to be hit once
			for(var/i in 1 to min(Proj.penetrating, round(Proj.damage/15)))
				if(src.pilot && hit_pilot && prob(20))
					Proj.attack_mob(src.pilot, distance)
					hit_pilot = 0
//				else
//					src.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT), 1)

				Proj.penetrating--

				if(prob(15))
					break //give a chance to exit early

	Proj.on_hit(src)
	return

/mob/living/vehicle/mecha/ex_act(severity)
	if(report_damage)
		src << "Affected by explosion of severity: [severity]."
	if(prob(src.deflect_chance))
		severity++ //Higher is less severe.
		if(report_damage)
			src << "Armor saved, changing severity to [severity]."
	switch(severity)
		if(1.0)
			src.Del()
		if(2.0)
			if (prob(30))
				src.Del()
			else
				src.apply_damage(initial(src.health)/2)
//				src.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
		if(3.0)
			if (prob(5))
				src.Del()
			else
				src.apply_damage(initial(src.health)/5)
//				src.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
	return

/mob/living/vehicle/mecha/emp_act(severity)
//	if(get_charge())
	if(cell)
		drain_power((cell.charge/2)/severity)
		apply_damage(50 / severity,"energy")
	if(report_damage)
		src << "EMP detected!"
//	check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
	return

/mob/living/vehicle/mecha/Weaken()
	return
/*
/mob/living/vehicle/mecha/attack_generic(var/mob/user, var/damage, var/attack_message)

	if(!damage)
		return

	apply_damage(damage, "brute")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
	src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [user.name] ([user.ckey])</font>")
	src.visible_message("<span class='danger'>[user] has [attack_message] [src]!</span>")
	spawn(1)
		updatehealth()
	return 1
*/
/mob/living/vehicle/mecha/attack_generic(var/mob/user, var/damage, var/attack_message)

	if(!damage)
		return 0


	if(!prob(src.deflect_chance))
		src.apply_damage(damage, BRUTE)
//		src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
		visible_message("<span class='danger>[user] [attack_message] [src]!</span>")
	else
		if(report_damage)
			src << "Armor saved."
		playsound(src.loc, 'sound/weapons/slash.ogg', 50, 1, -1)
		visible_message("<span class='notice'>\The [user] rebounds off [src.name]'s armor!</span>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name]</font>")
	src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [user.name] ([user.ckey])</font>")
	return 1

//************
//*ATTACKBY()*
//************
/mob/living/vehicle/mecha/attackby(obj/item/weapon/W as obj, mob/user as mob) //TODO: ADD ALL OTHER ATTACKBY STUFF
//	src.log_message("Attacked by [W]. Attacker - [user]")
	if(prob(src.deflect_chance)) //Check if we can outright deflect the attack.
		user << "<span class='danger'> \The [W] bounces off [src.name].</span>"
		if(report_damage)
			src << "Armor saved."
			return
	else //If we fail the check, actually hit the mech.
//		src.occupant_message("<span class='danger'>[user] hits [src] with [W].</span>")
		if(W.attack_verb.len)
			user.visible_message("<span class='danger'>[src] has been [pick(W.attack_verb)] with [W] by [user]!</span>")
		else
			user.visible_message("<span class='danger'>[src] has been attacked with [W] by [user]!</span>")
//		user.visible_message("<span class='danger'>[user] hits [src] with [W].</span>")
		src.apply_damage(W.force,W.damtype)
		if(W.hitsound)
			playsound(loc, W.hitsound, 50, 1, -1)
//		src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
//	..()
	return


//****************
//*MOVEMENT PROCS*
//****************

/mob/living/vehicle/mecha/Move(var/newloc, var/direct)
	if(can_act()) //Are we able to move? (Our pilot is alive, we have power, etc.)
		drain_power(step_energy_drain * 100)
		if(direct != last_dir) //Are we turning?
			set_dir(direct)
			last_dir = dir
			playsound(src,turn_sound,40,1)
			return

		. = ..() //If not, let's try to move.
		if(.) //If successful, make big stompy noises.
			playsound(src,step_sound,40,1)
		last_dir = dir //Likely not needed, but better safe then sorry.

/mob/living/vehicle/mecha/movement_delay()
	return step_in

/mob/living/vehicle/mecha/drain_power(var/amount = 0)

	if(!cell)
		return 0
	else
//		world << "Draining [amount] from [cell]."
		cell.drain_power(1, 0, amount)
		handle_hud_battery()
//		world << "[cell] now has [cell.charge] out of [cell.maxcharge]."

//********
//*LIFE()*
//********


/mob/living/vehicle/mecha/Life()
	..()
	if(src.client) //HUD stuff
//		handle_hud_integrity()
		handle_hud_pilot_health()
//		handle_hud_battery()
	if(pilot)
		src.stat = pilot.stat
		if(safety_ejection)
			safety_ejection_check()
	return 1

/mob/living/vehicle/mecha/proc/safety_ejection_check()
	if(pilot && safety_ejection) //just incase
		if(pilot.stat)
			src << "Auto-ejection triggered."
			get_out(src,1)


//***********
//*HUD STUFF*
//***********

/mob/living/vehicle/mecha/proc/handle_hud_pilot_health()
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

/mob/living/vehicle/mecha/proc/handle_hud_integrity()
	var/integrity_percentage = health / maxHealth
	var/output = 0
	switch(integrity_percentage)
		if(1.00)//full
			output = 100
		if(0.90 to 0.99)
			output = 90
		if(0.80 to 0.90)
			output = 80
		if(0.70 to 0.80)
			output = 70
		if(0.60 to 0.70)
			output = 60
		if(0.50 to 0.60)
			output = 50
		if(0.40 to 0.50)
			output = 40
		if(0.30 to 0.40)
			output = 30
		if(0.20 to 0.30)
			output = 20
		if(0.10 to 0.20)
			output = 10
		if(-1.0 to 0.10)
			output = 0
	healths.icon_state = "integrity[output]"
	return

/mob/living/vehicle/mecha/proc/handle_hud_battery()
	if(cell)
		var/charge_percentage = cell.charge / cell.maxcharge
		var/output = 0
		switch(charge_percentage)
			if(1.00)//full
				output = 100
			if(0.90 to 0.99)
				output = 90
			if(0.80 to 0.90)
				output = 80
			if(0.70 to 0.80)
				output = 70
			if(0.60 to 0.70)
				output = 60
			if(0.50 to 0.60)
				output = 50
			if(0.40 to 0.50)
				output = 40
			if(0.30 to 0.40)
				output = 30
			if(0.20 to 0.30)
				output = 20
			if(0.10 to 0.20)
				output = 10
			if(-1.0 to 0.10)
				output = 0
			else
				output = 100
		hud_used.mecha_battery.icon_state = "charge[output]"
	else
		hud_used.mecha_battery.icon_state = "charge0"
	return

/mob/living/vehicle/mecha/proc/add_cell(var/obj/item/weapon/cell/C=null)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new(src)
	cell.name = "high-capacity power cell"
	cell.charge = 15000
	cell.maxcharge = 15000

/mob/living/vehicle/mecha/proc/add_airtank()
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)
	return
