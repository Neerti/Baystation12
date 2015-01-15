/*
	This system is designed to move away from the 'magical microwave' way of cooking.  Instead of putting everything into
	a microwave and turning it on, you place different food items into a 'container' (like a frying pan), heat it up,
	then take it out when done.

	Instead of half a billion different subtypes for food, there will only be one for each 'class' of food, e.g. one for cakes,
	one for pies, one for pizza, etc etc.  When finish() is called on the container, a new 'finished' food is instantiated, and
	all of the contents of the container are placed inside.  The new finished food then runs New(), which runs a proc to
	change the name, desc, reagents, and a few other variables, depending on the contents of the food, changing, say, just a cake
	to 'banana-lime cake'.

	When something is inside an oven, time_to_finish ticks down by one each time the oven processes it.  At zero, finish() is called.

	Heat as defined on the containers uses an arbitrary unit called 'heat', which is applied by the oven every tick over
	60C, at different rates depending on temperature.  For the sake of simplicity and lag avoidance, the containers do not simulate
	cooling down, and get reset to 0 when something is finished, something is added, or removed.

	Heat is appled at a rate of (temperature - 60) * 0.1 when the oven is over 60C.

	When the container runs finished(), it uses a simple formula of checking if result_ideal_heat is between two proc variables, which are
	(result_ideal_heat * result_ideal_heat_tolerance) - result_ideal_heat for min and (result_ideal_heat * result_ideal_heat_tolerance) + result_ideal_heat
	for max.

	For instance, say a cake has an ideal heat of 600 (assuming time_to_finish is 100), it will fail if heat is under 480 or above 620 when finish() occurs.

	Oven code can be found at code\game\machinery\kitchen\oven.dm
	Stove code can be found at code\game\machinery\kitchen\stove.dm

	Contains:
		Containers
		Modular Food Defines
		Procs
*/

/*
 * Containers
 */

/obj/item/weapon/reagent_containers/kitchen
	icon = 'icons/obj/kitchen.dmi'
	force = 3
	throwforce = 3
	w_class = 2

	var/heat = 0 	//How hot the container is, which is used to determine if cooking was successful.
					//At prolonged amounts of heat, the contents of the container are converted into the finished food,
					//and for simplicity's sake, the heat of the pan is reset, as processing the pan cooling down is unneccessary.
					//It is complete arbitrary.
	var/time_to_finish = 100 //ticks
					//This determines when the contents are converted into the food.
					//When it reaches zero, it calculates the current heat level, to determine success.
					//Also arbitrary.
	var/result_path = null
					//The type of food to come out when finish() is called and all conditions are met.
					//Each container is specialized to make a specific 'type' of food, such as pizza, cake, pie, etc.
					//Depending on the contents of the container, you can make different kinds of pizza/cake/whatever, with just one path
					//For example, if a majority of the contents are apple, and there's also some banana in, you'd get a pie named 'apple banana pie'.
	var/result_ideal_heat = 6 // * time_to_finish
					//The ideal heat to use when checking if you cooked it correctly.  It's multiplied by time_to_finish in New() to allow easy changing later on.
	var/result_ideal_heat_tolerance = 0.2
					//The tolerance used to see if you are successful.  For example, if the ideal heat is 600, the tolerance would be 480 to 600, if at 0.2
					//Higher numbers results in a wider tolerance.

	var/prepared = 0
					//If the pan has been prepared (e.g. dough added)
	var/preparing_path = null
					//What you need to prepare the pan.
	var/finished = 0
					//If it's done, only used for descriptive strings.
	var/preparing_string = "flat dough"

	var/max_items = 1

/obj/item/weapon/reagent_containers/kitchen/New()
	..()
	result_ideal_heat = result_ideal_heat * time_to_finish

/obj/item/weapon/reagent_containers/kitchen/proc/finish()
	world << "DING DONG FINISHED!" //debug
	world << "The heat level was [heat]." //debug
	if(!result_path)
		return
	if(prepared) //You actually were trying to make something, right?
		finished = 1
		var/max = (result_ideal_heat * result_ideal_heat_tolerance) + result_ideal_heat //Going over this will burn the food
		var/min = (result_ideal_heat * result_ideal_heat_tolerance) - result_ideal_heat //Going under this will undercook the food.
		if(heat <= max && heat >= min) //Are we within acceptable bounds?
			var/new_food = new result_path(src) //We are!

			for(var/obj/item/weapon/reagent_containers/food/snacks/food in src.contents)
				food.loc = new_food //Move everything to the new food.
		else if(heat > max) //We burned it
			for(var/obj/item/weapon/reagent_containers/food/snacks/food in src.contents)
				del(food)
			new /obj/item/weapon/reagent_containers/food/snacks/badrecipe(src)
		else if(heat < min) //We undercooked it
			//todo: add a mallus to flavor taste variables when I add them.
			world << "FINISH ME"
	reset_self(0,1)


/obj/item/weapon/reagent_containers/kitchen/proc/reset_self(var/unfinish = 0, var/unprepare = 0) //To prevent heating something up to 95% then changing the contents.
	time_to_finish = initial(time_to_finish)
	heat = initial(heat)
	if(unfinish)
		finished = 0
	if(unprepare)
		prepared = 0
	return

/obj/item/weapon/reagent_containers/kitchen/examine(var/user as mob)
	..()
	user << "You can see [english_list(src.contents, nothing_text = "nothing", and_text = " and ", comma_text = ", ", final_comma_text = "" )] inside."

/obj/item/weapon/reagent_containers/kitchen/proc/update_overlays()
	if(prepared && contents.len >= 1)
		for(var/obj/item/weapon/reagent_containers/food/snacks/O in contents)
			var/image/I = new(src.icon, "[initial(icon_state)]-overlay")
			I.color = O.filling_color
			overlays += I
	else
		overlays.Cut()


/obj/item/weapon/reagent_containers/kitchen/attackby(var/obj/item/O as obj, var/mob/user as mob) //Put things inside
	if(contents.len >= max_items)
		user << "<span class='notice'>The [src] can't fit anymore!</span>"
		return
	else
		if(istype(O, preparing_path))
			if(prepared == 0)
				user << "<span class='notice'>You add \the [O] to the bottom of the [src].<br>Anything you add next will determine what you make.</span>"
				prepared = 1
				icon_state = initial(icon_state) + "-prepared"
				user.drop_item()
				del(O) //It is better if the dough is not included in the contents, later on down the line.  This saves us from doing a loop to remove it later.
				return
			else
				user << "<span class='notice'>You don't need anymore [O].</span>"
				return
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/custom) || (istype(O, /obj/item/weapon/reagent_containers/food/snacks/sliceable/custom)))
			spawn(0)
				user << "<span class='notice'>'You halt in your work, suddenly struck by the philosophical complexity of fitting a [O.name] into \
				a [src.name] of equal or smaller volume.</span>"
				sleep(50)
				user << "<span class='notice'>A little bit of drool falls from your slack lips.</span>"
				sleep(100)
				user << "<span class='notice'>You now just came to the revelation that you are, in fact, a complete dumbass.</span>"
			return
					//This is to stop meat cake cake cake cake cake cake pizza.

		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks))
			if(!prepared)
				user << "<span class='notice'>You need some [preparing_string] first.</span>"
			else
				user.visible_message(\
					"<span class='notice'>[user] has added \the [O] to [src].</span>", \
					"<span class='notice'>You add \the [O] to [src].</span>")
				user.drop_item()
				O.loc = src //Put it in
				if(contents.len >= 1)
					update_overlays()
				reset_self(0,0)
		else
			//user << "You don't think you could make anything useful with \the [O]."
			..()

/obj/item/weapon/reagent_containers/kitchen/attack_self(var/mob/user as mob) //Take things out
	for(var/obj/O in contents)
		O.loc = user.loc
	reagents.clear_reagents()
	user << "<span class='notice'>You tip the [src] upside-down.</span>"
	icon_state = initial(icon_state)
	if(prepared)
		new preparing_path(user.loc)
	reset_self(1,1)
	update_overlays()
	..()

/obj/item/weapon/reagent_containers/kitchen/cakepan
	name = "cake pan"
	desc = "It's a pan used for baking cakes."
	icon_state = "cakepan"
	result_path = /obj/item/weapon/reagent_containers/food/snacks/sliceable/custom/cake
	preparing_path = /obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough
	preparing_string = "flat dough"
	result_ideal_heat = 6 //120C is ideal
	result_ideal_heat_tolerance = 0.2
	max_items = 8

/obj/item/weapon/reagent_containers/kitchen/piepan
	name = "pie pan"
	desc = "A pan used for making delicious pie.  Baking of pi not recommended."
	icon_state = "piepan"
	result_path = /obj/item/weapon/reagent_containers/food/snacks/sliceable/custom/pie
	preparing_path = /obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough
	preparing_string = "flat dough"
	max_items = 8

/obj/item/weapon/reagent_containers/kitchen/souppan
	name = "soup pan"
	desc = "Used for boiling stews and soups."
	icon_state = "souppan"

/obj/item/weapon/reagent_containers/kitchen/bakingtray //distinct from the tray used to carry food.
	name = "baking tray"
	desc = "A tray used to bake things from bread to pizza, and everything inbetween."
	icon_state = "bakingtray"
	max_items = 8

/obj/item/weapon/reagent_containers/kitchen/fryingpan
	name = "frying pan"
	desc = "Used to cook on the stove.  Also used to chase people out of your kitchen."
	icon_state = "fryingpan"
	force = 10
	max_items = 1

/obj/item/weapon/reagent_containers/kitchen/mixingbowl
	name = "mixing bowl"
	desc = "A valuable aid in mixing things."
	icon_state = "mixingbowl"
	max_items = 4

/obj/item/weapon/reagent_containers/kitchen/debug
	name = "master chef's cake pan"
	desc = "Made of ultra-rare minerals, it is capable of breaking thermodynamics and bakes a cake in five seconds using magic!"
	icon_state = "cakepan"
	result_path = /obj/item/weapon/reagent_containers/food/snacks/sliceable/custom/cake
	preparing_path = /obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough
	preparing_string = "flat dough"
	time_to_finish = 5
	result_ideal_heat = 60
	result_ideal_heat_tolerance = 0.2
	max_items = 50

/obj/item/weapon/reagent_containers/kitchen/debug/attack_self() //instant cooking
	heat = result_ideal_heat
	finish()
	..()

/*
 * Food
 */

/obj/item/weapon/reagent_containers/food/snacks/custom
	icon = 'icons/obj/food_custom.dmi'

/obj/item/weapon/reagent_containers/food/snacks/custom/New()
	..()
	spawn(1) //Needed so contents of the food gets filled first.
		make_aesthetics()

/obj/item/weapon/reagent_containers/food/snacks/sliceable/custom
	icon = 'icons/obj/food_custom.dmi'

/obj/item/weapon/reagent_containers/food/snacks/sliceable/custom/New()
	..()
	spawn(1)
		make_aesthetics()

//Cakes
/obj/item/weapon/reagent_containers/food/snacks/sliceable/custom/cake
	name = "\a cake"
	desc = "A delicious cake, not a lie."
	icon_state = "cake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/custom/cakeslice
	slices_num = 5
	filling_color = "#F7EDD5"
	New()
		..()
		reagents.add_reagent("nutriment", 20)

/obj/item/weapon/reagent_containers/food/snacks/custom/cakeslice
	name = "\a cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "plaincake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#F7EDD5"
	bitesize = 2

//Pies

/obj/item/weapon/reagent_containers/food/snacks/sliceable/custom/pie
	name = "\a pie"
	icon_state = "pie"
	desc = "Much better then pi!"
	trash = /obj/item/trash/plate
	filling_color = "#948051"

	New()
		..()
		reagents.add_reagent("nutriment", 10)
		bitesize = 2
/*
 * Food Procs
 */

/obj/item/weapon/reagent_containers/food/snacks/proc/make_aesthetics() //Guesses what kind of pie/cake/whatever to be based on contents used.
	var/list/ingredients = list() //Tally for all things inside
	var/list/ingredient_colors = list() //A hack, since the other list must contain strings.
	for(var/obj/item/weapon/reagent_containers/food/snacks/item in src.contents) //Get all the contents, and put it into a list that we're gonna mess with later.
		ingredients[item.name]++ //Count how many of something is inside.
		ingredient_colors[item.filling_color]++ //Get the colors too.
	var/majority_color = get_max_index(ingredient_colors) //Pick the color most used often, to be used for the overlay.
	world << "majority color was [majority_color]"
	var/list/main_ingredients = list() //The top three ingredients.  Anything below is not important to us yet.
	var/i = 2 //actually three
	while(i >= 0 && ingredients.len > 0) //Stop after three iterations or if ingredients is empty.
		var/to_be_moved = null
		to_be_moved = get_max_index(ingredients) //Find the largest number
		main_ingredients.Add(to_be_moved)
		ingredients.Remove(to_be_moved) //Don't count twice
		i--
	var/old_name = name
	name = "[english_list(main_ingredients, nothing_text = "plain", and_text = " and ", comma_text = ", ", final_comma_text = "" )] [old_name]"

	//Overlays
	if(!isemptylist(main_ingredients)) //Don't add overlays for nonexistant additions.
		var/image/I = new(src.icon, "[initial(icon_state)]-overlay")
		I.color = majority_color
		overlays += I
		world << "Overlays were applied."
	else
		world << "main_ingredients was empty.  Most likely, something broke"
