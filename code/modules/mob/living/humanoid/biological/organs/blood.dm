/****************************************************
				BLOOD SYSTEM
****************************************************/
//Blood levels
var/const/BLOOD_VOLUME_SAFE = 501
var/const/BLOOD_VOLUME_OKAY = 336
var/const/BLOOD_VOLUME_BAD = 224
var/const/BLOOD_VOLUME_SURVIVE = 122

/mob/living/humanoid/biological/var/datum/reagents/vessel	//Container for blood and BLOOD ONLY. Do not transfer other chems here.
/mob/living/humanoid/biological/var/pale = 0			//Should affect how mob sprite is drawn, but currently doesn't.

//Initializes blood vessels
/mob/living/humanoid/biological/human/proc/make_blood()

	if(vessel)
		return

	vessel = new/datum/reagents(600)
	vessel.my_atom = src

	if(species && species.flags & NO_BLOOD) //We want the var for safety but we can do without the actual blood.
		return

	vessel.add_reagent("blood",560)
	spawn(1)
		fixblood()

//Resets blood data
/mob/living/humanoid/biological/proc/fixblood()
	for(var/datum/reagent/blood/B in vessel.reagent_list)
		if(B.id == "blood")
			B.data = list(	"donor"=src,"viruses"=null,"species"=species.name,"blood_DNA"=dna.unique_enzymes,"blood_colour"= species.blood_color,"blood_type"=dna.b_type,	\
							"resistances"=null,"trace_chem"=null, "virus2" = null, "antibodies" = list())
			B.color = B.data["blood_colour"]

// Takes care blood loss and regeneration
/mob/living/humanoid/biological/proc/handle_blood()

	if(species && species.flags & NO_BLOOD)
		return

	if(stat != DEAD && bodytemperature >= 170)	//Dead or cryosleep people do not pump the blood.

		var/blood_volume = round(vessel.get_reagent_amount("blood"))

		//Blood regeneration if there is some space
		if(blood_volume < 560 && blood_volume)
			var/datum/reagent/blood/B = locate() in vessel.reagent_list //Grab some blood
			if(B) // Make sure there's some blood at all
				if(B.data["donor"] != src) //If it's not theirs, then we look for theirs
					for(var/datum/reagent/blood/D in vessel.reagent_list)
						if(D.data["donor"] == src)
							B = D
							break

				B.volume += 0.1 // regenerate blood VERY slowly
				if (reagents.has_reagent("nutriment"))	//Getting food speeds it up
					B.volume += 0.4
					reagents.remove_reagent("nutriment", 0.1)
				if (reagents.has_reagent("iron"))	//Hematogen candy anyone?
					B.volume += 0.8
					reagents.remove_reagent("iron", 0.1)

		// Damaged heart virtually reduces the blood volume, as the blood isn't
		// being pumped properly anymore.
		if(species && species.has_organ["heart"])
			var/datum/organ/internal/heart/heart = internal_organs_by_name["heart"]

			if(!heart)
				blood_volume = 0
			else if(heart.damage > 1 && heart.damage < heart.min_bruised_damage)
				blood_volume *= 0.8
			else if(heart.damage >= heart.min_bruised_damage && heart.damage < heart.min_broken_damage)
				blood_volume *= 0.6
			else if(heart.damage >= heart.min_broken_damage && heart.damage < INFINITY)
				blood_volume *= 0.3

		//Effects of bloodloss
		switch(blood_volume)
			if(BLOOD_VOLUME_SAFE to 10000)
				if(pale)
					pale = 0
					update_body()
			if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
				if(!pale)
					pale = 1
					update_body()
					var/word = pick("dizzy","woosey","faint")
					src << "\red You feel [word]"
				if(prob(1))
					var/word = pick("dizzy","woosey","faint")
					src << "\red You feel [word]"
				if(oxyloss < 20)
					oxyloss += 3
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
				if(!pale)
					pale = 1
					update_body()
				eye_blurry = max(eye_blurry,6)
				if(oxyloss < 50)
					oxyloss += 10
				oxyloss += 1
				if(prob(15))
					Paralyse(rand(1,3))
					var/word = pick("dizzy","woosey","faint")
					src << "\red You feel extremely [word]"
			if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
				oxyloss += 5
				toxloss += 3
				if(prob(15))
					var/word = pick("dizzy","woosey","faint")
					src << "\red You feel extremely [word]"
			if(0 to BLOOD_VOLUME_SURVIVE)
				// There currently is a strange bug here. If the mob is not below -100 health
				// when death() is called, apparently they will be just fine, and this way it'll
				// spam deathgasp. Adjusting toxloss ensures the mob will stay dead.
				toxloss += 300 // just to be safe!
				death()

		// Without enough blood you slowly go hungry.
		if(blood_volume < BLOOD_VOLUME_SAFE)
			if(nutrition >= 300)
				nutrition -= 10
			else if(nutrition >= 200)
				nutrition -= 3

		//Bleeding out
		var/blood_max = 0
		for(var/datum/organ/external/temp in organs)
			if(!(temp.status & ORGAN_BLEEDING) || temp.status & ORGAN_ROBOT)
				continue
			for(var/datum/wound/W in temp.wounds) if(W.bleeding())
				blood_max += W.damage / 40
			if (temp.open)
				blood_max += 2  //Yer stomach is cut open
		drip(blood_max)

//Makes a blood drop, leaking amt units of blood from the mob
/mob/living/humanoid/biological/proc/drip(var/amt as num)

	if(species && species.flags & NO_BLOOD) //TODO: Make drips come from the reagents instead.
		return

	if(!amt)
		return

	vessel.remove_reagent("blood",amt)
	blood_splatter(src,src)