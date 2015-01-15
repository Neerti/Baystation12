//Cakes, which are baked in the oven with a cake pan



/* //The following is commented out because of microwaves and recipies being phased out
/obj/item/weapon/reagent_containers/food/snacks/sliceable/plaincake
	name = "Vanilla Cake"
	desc = "A plain cake, not a lie."
	icon_state = "plaincake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/plaincakeslice
	slices_num = 5
	filling_color = "#F7EDD5"
	New()
		..()
		reagents.add_reagent("nutriment", 20)

/obj/item/weapon/reagent_containers/food/snacks/plaincakeslice
	name = "Vanilla Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "plaincake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#F7EDD5"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/carrotcake
	name = "Carrot Cake"
	desc = "A favorite desert of a certain wascally wabbit. Not a lie."
	icon_state = "carrotcake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/carrotcakeslice
	slices_num = 5
	filling_color = "#FFD675"
	New()
		..()
		reagents.add_reagent("nutriment", 25)
		reagents.add_reagent("imidazoline", 10)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/carrotcakeslice
	name = "Carrot Cake slice"
	desc = "Carrotty slice of Carrot Cake, carrots are good for your eyes! Also not a lie."
	icon_state = "carrotcake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FFD675"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/braincake
	name = "Brain Cake"
	desc = "A squishy cake-thing."
	icon_state = "braincake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/braincakeslice
	slices_num = 5
	filling_color = "#E6AEDB"
	New()
		..()
		reagents.add_reagent("nutriment", 25)
		reagents.add_reagent("alkysine", 10)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/braincakeslice
	name = "Brain Cake slice"
	desc = "Lemme tell you something about prions. THEY'RE DELICIOUS."
	icon_state = "braincakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#E6AEDB"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesecake
	name = "Cheese Cake"
	desc = "DANGEROUSLY cheesy."
	icon_state = "cheesecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cheesecakeslice
	slices_num = 5
	filling_color = "#FAF7AF"
	New()
		..()
		reagents.add_reagent("nutriment", 25)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesecakeslice
	name = "Cheese Cake slice"
	desc = "Slice of pure cheestisfaction"
	icon_state = "cheesecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FAF7AF"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/orangecake
	name = "Orange Cake"
	desc = "A cake with added orange."
	icon_state = "orangecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/orangecakeslice
	slices_num = 5
	filling_color = "#FADA8E"
	New()
		..()
		reagents.add_reagent("nutriment", 20)

/obj/item/weapon/reagent_containers/food/snacks/orangecakeslice
	name = "Orange Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "orangecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FADA8E"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/limecake
	name = "Lime Cake"
	desc = "A cake with added lime."
	icon_state = "limecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/limecakeslice
	slices_num = 5
	filling_color = "#CBFA8E"
	New()
		..()
		reagents.add_reagent("nutriment", 20)

/obj/item/weapon/reagent_containers/food/snacks/limecakeslice
	name = "Lime Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "limecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#CBFA8E"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/lemoncake
	name = "Lemon Cake"
	desc = "A cake with added lemon."
	icon_state = "lemoncake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/lemoncakeslice
	slices_num = 5
	filling_color = "#FAFA8E"
	New()
		..()
		reagents.add_reagent("nutriment", 20)

/obj/item/weapon/reagent_containers/food/snacks/lemoncakeslice
	name = "Lemon Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "lemoncake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FAFA8E"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/chocolatecake
	name = "Chocolate Cake"
	desc = "A cake with added chocolate"
	icon_state = "chocolatecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/chocolatecakeslice
	slices_num = 5
	filling_color = "#805930"
	New()
		..()
		reagents.add_reagent("nutriment", 20)

/obj/item/weapon/reagent_containers/food/snacks/chocolatecakeslice
	name = "Chocolate Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "chocolatecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#805930"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/birthdaycake
	name = "Birthday Cake"
	desc = "Happy Birthday..."
	icon_state = "birthdaycake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/birthdaycakeslice
	slices_num = 5
	filling_color = "#FFD6D6"
	New()
		..()
		reagents.add_reagent("nutriment", 20)
		reagents.add_reagent("sprinkles", 10)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/birthdaycakeslice
	name = "Birthday Cake slice"
	desc = "A slice of your birthday"
	icon_state = "birthdaycakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#FFD6D6"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/applecake
	name = "Apple Cake"
	desc = "A cake centred with Apple"
	icon_state = "applecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/applecakeslice
	slices_num = 5
	filling_color = "#EBF5B8"
	New()
		..()
		reagents.add_reagent("nutriment", 15)

/obj/item/weapon/reagent_containers/food/snacks/applecakeslice
	name = "Apple Cake slice"
	desc = "A slice of heavenly cake."
	icon_state = "applecakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#EBF5B8"
	bitesize = 2
*/