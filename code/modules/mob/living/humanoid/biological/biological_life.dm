/mob/living/humanoid/biological/Life()
	..()
	world << "WOO"
	if(stat != DEAD && !in_stasis)
		if(air_master.current_cycle%4==2 || failed_last_breath || (health < config.health_threshold_crit)) 	//First, resolve location and get a breath
			breathe() 				//Only try to take a breath every 4 ticks, unless suffocating

		//Updates the number of stored chemicals for powers
//		handle_changeling() //bio?

		//Mutations and radiation
//		handle_mutations_and_radiation() //move to biological

		//Chemicals in the body
//		handle_chemicals_in_body() //move to biological

		//Disabilities
//		handle_disabilities() //move to biological

		//Organs and blood
//		handle_organs() //bio
//		handle_blood() //bio
//		stabilize_body_temperature() //Body temperature adjusts itself (self-regulation)

		//Random events (vomiting etc)
//		handle_random_events() //bio

		//stuff in the stomach
//		handle_stomach() //bio

//		handle_shock() //bio

//		handle_pain() //bio

//		handle_medical_side_effects() //bio

//		handle_heartbeat() //bio

//	handle_stasis_bag()