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
	var/step_energy_drain = 100

	var/report_damage = 0 //Determines if damage information is sent to the client piloting this.  This replaces the damage logs that old mechs had.

//VERBS! and procs too i guess

/mob/vehicle/mecha/New()
	add_cell()
	..()

/mob/vehicle/mecha/proc/toggle_report_damage()
	set name = "Toggle Report Damage"
	set desc = "Enables or disables real-time damage reporting."
	set category = "Exosuit Interface"

	report_damage = !report_damage
	return

/mob/vehicle/mecha/on_pilot_entry()
	//Update the HUD once.
	handle_hud_integrity()
	handle_hud_pilot_health()
	handle_hud_battery()
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

//**************
//*DAMAGE PROCS*
//**************

/mob/vehicle/mecha/proc/take_damage(amount, type = "brute")
	if(amount)
		var/damage = absorb_damage(amount,type) //Reduce the damage somewhat, depending on our armor.
		health -= damage //After the reduction, remove some health.
		update_health() //Make sparks and update the HUD, also check if we should be dead.
		if(report_damage) //If the pilot wants, tell them how bad the hurt was.
			src << "Took [damage] points of damage.  Type of damage: \"[type]\""
	return

/mob/vehicle/mecha/proc/absorb_damage(amount, type)
	var/damage = amount * (listgetindex (damage_absorption,type) || 1)
	return damage

/mob/vehicle/mecha/proc/update_health()
	if(src.health > 0)
		src.spark_system.start()
		if(client)
			handle_hud_integrity() //Update the health indicator.  This is done here, so it only updates when needed, instead of inside Life()
	else
		src.visible_message("<span class='danger'>\The [src] falls apart.</span>")
		src.Del() //This is overriden, so it's safe to call it.
	return

/mob/vehicle/mecha/bullet_act(var/obj/item/projectile/Proj)
	if(prob(src.deflect_chance))
		src.visible_message("<span class='notice'>The [src] armor deflects the [Proj].</span>")
		if(report_damage)
			src << "Armor saved."
		return

	if(Proj.damage_type == HALLOSS)
		drain_power(Proj.agony * 5)

	if(!(Proj.nodamage))
//		var/ignore_threshold
//		if(istype(Proj, /obj/item/projectile/beam/pulse))
//			ignore_threshold = 1
		src.take_damage(Proj.damage, Proj.check_armour)
		src.visible_message("<span class='danger'>[src] was hit by the [Proj]!</span>")
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

/mob/vehicle/mecha/ex_act(severity)
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
				src.take_damage(initial(src.health)/2)
//				src.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
		if(3.0)
			if (prob(5))
				src.Del()
			else
				src.take_damage(initial(src.health)/5)
//				src.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
	return

/mob/vehicle/mecha/emp_act(severity)
//	if(get_charge())
	if(cell)
		drain_power((cell.charge/2)/severity)
		take_damage(50 / severity,"energy")
	if(report_damage)
		src << "EMP detected!"
//	check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
	return

//************
//*ATTACKBY()*
//************
/mob/vehicle/mecha/attackby(obj/item/weapon/W as obj, mob/user as mob) //TODO: ADD ALL OTHER ATTACKBY STUFF
//	src.log_message("Attacked by [W]. Attacker - [user]")
	if(prob(src.deflect_chance)) //Check if we can outright deflect the attack.
		user << "<span class='danger'> \The [W] bounces off [src.name].</span>"
		if(report_damage)
			src << "Armor saved."
	else //If we fail the check, actually hit the mech.
//		src.occupant_message("<span class='danger'>[user] hits [src] with [W].</span>")
		user.visible_message("<span class='danger'>[user] hits [src] with [W].</span>")
		src.take_damage(W.force,W.damtype)
//		src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
	..()
	return


//****************
//*MOVEMENT PROCS*
//****************

/mob/vehicle/mecha/Move(var/newloc, var/direct)
	if(can_act()) //Are we able to move? (Our pilot is alive, we have power, etc.)
		drain_power(0, 0, step_energy_drain * 100)
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
//	var/output = round( (health / max_health) * 100, 1)
//	healths.maptext = null
//	healths.maptext = "<div align='left' valign='middle'> <font color='green'>[output]%</font></div>"
	var/integrity_percentage = health / max_health
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

/mob/vehicle/mecha/proc/handle_hud_battery()
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

/mob/vehicle/mecha/proc/add_cell(var/obj/item/weapon/cell/C=null)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new(src)
	cell.name = "high-capacity power cell"
	cell.charge = 15000
	cell.maxcharge = 15000
