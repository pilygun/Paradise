/mob/living/simple_animal/snail
	name = "space snail"
	desc = "Маленькая космо-улиточка со своим космо-домиком. Прочная, тихая и медленная."
	icon_state = "snail"
	icon_living = "snail"
	icon_dead = "snail_dead"
	speak = list("Uhh.", "Hurrr.")
	tts_seed = "Ladyvashj"
	health = 100
	maxHealth = 100
	speed = 10
	attacktext = "толкает"
	death_sound = 'sound/creatures/crack_death1.ogg'
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	gender = NEUTER
	can_hide = 1
	butcher_results = list(/obj/item/reagent_containers/food/snacks/salmonmeat/snailmeat = 1, /obj/item/stack/ore/tranquillite = 1)
	can_collar = 1
	gold_core_spawnable = FRIENDLY_SPAWN
	stop_automated_movement_when_pulled = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	faction = list("slime", "neutral")
	reagents = new()
	holder_type = /obj/item/holder/snail

/mob/living/simple_animal/snail/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE	// why???

/mob/living/simple_animal/snail/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	var/oldLoc = src.loc
	. = ..()
	if(.)
		if(stat != DEAD)
			make_wet_floor(oldLoc)

/mob/living/simple_animal/snail/proc/make_wet_floor(atom/oldLoc)
	if(oldLoc != src.loc)
		reagents.add_reagent("water",10)
		reagents.reaction(oldLoc, REAGENT_TOUCH, 10)	//10 is the multiplier for the reaction effect. probably needed to wet the floor properly.
		reagents.remove_any(10)

/mob/living/simple_animal/snail/lube
	name = "space snail"
	desc = "Маленькая космо-улиточка со своим космо-домиком. Прочная, тихая и медленная. И очень склизкая."
	gold_core_spawnable = HOSTILE_SPAWN
	faction = list("slime", "hostile")

/mob/living/simple_animal/snail/lube/make_wet_floor(atom/oldLoc)
	if(oldLoc != src.loc)
		reagents.add_reagent("lube",10)
		reagents.reaction(oldLoc, REAGENT_TOUCH, 10)
		reagents.remove_any(10)

/mob/living/simple_animal/turtle
	name = "черепаха"
	desc = "Большая космочерепаха. Прочная, тихая и медленная."
	icon = 'icons/mob/animal.dmi'
	icon_state = "yeeslow"
	icon_living = "yeeslow"
	icon_dead = "yeeslow_dead"
	icon_resting = "yeeslow_scared"
	speak = list("Uhh.", "Hurrr.")
	tts_seed = "Ladyvashj"
	health = 500
	maxHealth = 500
	speed = 20
	attacktext = "толкает"
	death_sound = 'sound/creatures/crack_death1.ogg'
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	density = TRUE
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	pass_flags = PASSTABLE | PASSGRILLE
	status_flags = CANPARALYSE | CANPUSH
	mob_size = MOB_SIZE_SMALL
	butcher_results = list(/obj/item/reagent_containers/food/snacks/salmonmeat/turtlemeat = 10, /obj/item/stack/ore/tranquillite = 5)
	footstep_type = FOOTSTEP_MOB_SLIME
	holder_type = /obj/item/holder/turtle
