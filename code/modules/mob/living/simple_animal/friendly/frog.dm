/mob/living/simple_animal/frog
	name = "лягушка"
	real_name = "лягушка"
	desc = "Выглядит грустным не по средам и когда её не целуют."
	icon_state = "frog"
	icon_living = "frog"
	icon_dead = "frog_dead"
	icon_resting = "frog"
	speak = list("Квак!","КУААК!","Квуак!")
	speak_emote = list("квак","куак","квуак")
	emote_hear = list("квак","куак","квуак")
	emote_see = list("лежит расслабленная", "увлажнена", "издает гортанные звуки", "лупает глазками")
	var/scream_sound = list ('sound/creatures/frog_scream_1.ogg','sound/creatures/frog_scream_2.ogg','sound/creatures/frog_scream_3.ogg')
	talk_sound = list('sound/creatures/frog_talk1.ogg', 'sound/creatures/frog_talk2.ogg')
	damaged_sound = list('sound/creatures/frog_damaged.ogg')
	death_sound = 'sound/creatures/frog_death.ogg'
	tts_seed = "pantheon"
	speak_chance = 1
	turns_per_move = 5
	nightvision = 10
	maxHealth = 10
	health = 10
	blood_volume = BLOOD_VOLUME_SURVIVE
	butcher_results = list(/obj/item/reagent_containers/food/snacks/monstermeat/lizardmeat = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stamps on"
	density = FALSE
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	layer = MOB_LAYER
	atmos_requirements = list("min_oxy" = 16, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius
	universal_speak = 0
	can_hide = 1
	holder_type = /obj/item/holder/frog
	can_collar = 1
	gold_core_spawnable = FRIENDLY_SPAWN

/mob/living/simple_animal/frog/attack_hand(mob/living/carbon/human/M as mob)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M)
	..()

/mob/living/simple_animal/frog/Crossed(AM as mob|obj, oldloc)
	if(ishuman(AM))
		if(!stat)
			var/mob/M = AM
			to_chat(M, "<span class='notice'>[bicon(src)] квакнул!</span>")
	..()

/mob/living/simple_animal/frog/toxic
	name = "яркая лягушка"
	real_name = "яркая лягушка"
	desc = "Уникальная токсичная раскраска. Лучше не трогать голыми руками."
	icon_state = "rare_frog"
	icon_living = "rare_frog"
	icon_dead = "rare_frog_dead"
	icon_resting = "rare_frog"
	var/toxin_per_touch = 2.5
	var/toxin_type = "toxin"
	gold_core_spawnable = HOSTILE_SPAWN
	holder_type = /obj/item/holder/frog/toxic


/mob/living/simple_animal/frog/toxic/attack_hand(mob/living/carbon/human/user)
	if(!ishuman(user) || user.gloves)
		return ..()

	var/obj/item/organ/external/left_hand = get_organ(BODY_ZONE_PRECISE_L_HAND)
	var/obj/item/organ/external/right_hand = get_organ(BODY_ZONE_PRECISE_R_HAND)
	if((left_hand && !left_hand.is_robotic()) || (right_hand && !right_hand.is_robotic()))
		to_chat(user, span_warning("Дотронувшись до [src.name], ваша кожа начинает чесаться!"))
		toxin_affect(user)

	if(user.a_intent == INTENT_DISARM || user.a_intent == INTENT_HARM)
		return ..()


/mob/living/simple_animal/frog/toxic/Crossed(mob/living/carbon/human/user, oldloc)
	if(!ishuman(user) || user.gloves)
		return ..()

	var/obj/item/organ/external/left_foot = get_organ(BODY_ZONE_PRECISE_L_FOOT)
	var/obj/item/organ/external/right_foot = get_organ(BODY_ZONE_PRECISE_R_FOOT)
	if((left_foot && !left_foot.is_robotic()) || (right_foot && !right_foot.is_robotic()))
		to_chat(user, span_warning("Ваши ступни начинают чесаться!"))
		toxin_affect(user)

	return ..()


/mob/living/simple_animal/frog/toxic/proc/toxin_affect(mob/living/carbon/human/user)
	if(user.reagents && toxin_type && toxin_per_touch)
		user.reagents.add_reagent(toxin_type, toxin_per_touch)


/mob/living/simple_animal/frog/scream
	name = "орущая лягушка"
	real_name = "орущая лягушка"
	desc = "Не любит когда на неё наступают. Используется в качестве наказания за проступки"
	var/squeak_sound = list ('sound/creatures/frog_scream1.ogg','sound/creatures/frog_scream2.ogg')
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/frog/scream/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, squeak_sound, 50, extrarange = SHORT_RANGE_SOUND_EXTRARANGE) //as quiet as a frog or whatever

/mob/living/simple_animal/frog/toxic/scream
	var/squeak_sound = list ('sound/creatures/frog_scream1.ogg','sound/creatures/frog_scream2.ogg')
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/frog/toxic/scream/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, squeak_sound, 50, extrarange = SHORT_RANGE_SOUND_EXTRARANGE) //as quiet as a frog or whatever

/mob/living/simple_animal/frog/handle_automated_movement()
	. = ..()
	if(!resting && !buckled && prob(1))
		emote("warcry")

