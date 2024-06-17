// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T5 EMPRESS OF TERROR -------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: ruling over planets of uncountable spiders, like Xenomorph Empresses.
// -------------: AI: none - this is strictly adminspawn-only and intended for RP events, coder testing, and teaching people 'how to queen'
// -------------: SPECIAL: Lay Eggs ability that allows laying queen-level eggs.
// -------------: TO FIGHT IT: run away screaming?
// -------------: SPRITES FROM: FoS, https://www.paradisestation.org/forum/profile/335-fos

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress
	name = "Empress of Terror"
	desc = "The unholy offspring of spiders, nightmares, and lovecraft fiction."
	ai_target_method = TS_DAMAGE_SIMPLE
	maxHealth = 1000
	health = 1000
	melee_damage_lower = 30
	melee_damage_upper = 60
	idle_ventcrawl_chance = 0
	ai_playercontrol_allowtype = 0
	canlay = 1000
	spider_tier = TS_TIER_5
	projectiletype = /obj/item/projectile/terrorspider/empress
	icon = 'icons/mob/terrorspider64.dmi'
	pixel_x = -16
	move_resist = MOVE_FORCE_STRONG // no more pushing a several hundred if not thousand pound spider
	mob_size = MOB_SIZE_LARGE
	icon_state = "terror_empress"
	icon_living = "terror_empress"
	icon_dead = "terror_empress_dead"
	var/datum/action/innate/terrorspider/queen/empress/empresslings/empresslings_action
	var/datum/action/innate/terrorspider/queen/empress/empresserase/empresserase_action
	tts_seed = "Queen"

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/New()
	..()
	empresslings_action = new()
	empresslings_action.Grant(src)
	empresserase_action = new()
	empresserase_action.Grant(src)

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/spider_special_action()
	return

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/NestMode()
	..()
	queeneggs_action.button.name = "Empress Eggs"

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/LayQueenEggs()
	var/eggtype = input("What kind of eggs?") as null|anything in list(TS_DESC_QUEEN, TS_DESC_MOTHER, TS_DESC_PRINCE, TS_DESC_PRINCESS, TS_DESC_KNIGHT, TS_DESC_LURKER, TS_DESC_HEALER, TS_DESC_WIDOW, TS_DESC_GUARDIAN, TS_DESC_DEFILER, TS_DESC_DESTROYER)
	var/numlings = input("How many in the batch?") as null|anything in list(1, 2, 3, 4, 5, 10, 15, 20, 30, 40, 50)
	if(eggtype == null || numlings == null)
		to_chat(src, "<span class='danger'>Cancelled.</span>")
		return
	switch(eggtype)
		if(TS_DESC_KNIGHT)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/knight, numlings)
		if(TS_DESC_LURKER)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/lurker, numlings)
		if(TS_DESC_HEALER)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/healer, numlings)
		if(TS_DESC_WIDOW)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/widow, numlings)
		if(TS_DESC_GUARDIAN)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/guardian, numlings)
		if(TS_DESC_DEFILER)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/defiler, numlings)
		if(TS_DESC_DESTROYER)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/destroyer, numlings)
		if(TS_DESC_PRINCE)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/prince, numlings)
		if(TS_DESC_PRINCESS)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/queen/princess, numlings)
		if(TS_DESC_MOTHER)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/mother, numlings)
		if(TS_DESC_QUEEN)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/queen, numlings)
		else
			to_chat(src, "<span class='danger'>Unrecognized egg type.</span>")

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/proc/EmpressLings()
	var/numlings = input("How many?") as null|anything in list(10, 20, 30, 40, 50)
	var/sbpc = input("%chance to be stillborn?") as null|anything in list(0, 25, 50, 75, 100)
	for(var/i=0, i<numlings, i++)
		var/obj/structure/spider/spiderling/terror_spiderling/S = new /obj/structure/spider/spiderling/terror_spiderling(get_turf(src))
		S.grow_as = pick(/mob/living/simple_animal/hostile/poison/terror_spider/knight, \
		/mob/living/simple_animal/hostile/poison/terror_spider/lurker, \
		/mob/living/simple_animal/hostile/poison/terror_spider/healer, \
		/mob/living/simple_animal/hostile/poison/terror_spider/defiler, \
		/mob/living/simple_animal/hostile/poison/terror_spider/widow)
		S.spider_myqueen = spider_myqueen
		S.spider_mymother = src
		if(prob(sbpc))
			S.stillborn = TRUE
		if(spider_growinstantly)
			S.amount_grown = 250

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/proc/EraseBrood()
	for(var/thing in GLOB.ts_spiderlist)
		var/mob/living/simple_animal/hostile/poison/terror_spider/T = thing
		if(T.spider_tier < spider_tier)
			T.degenerate = TRUE
			to_chat(T, "<span class='userdanger'>Through the hivemind, the raw power of [src] floods into your body, burning it from the inside out!</span>")
	for(var/obj/structure/spider/eggcluster/terror_eggcluster/T in GLOB.ts_egg_list)
		qdel(T)
	for(var/obj/structure/spider/spiderling/terror_spiderling/T in GLOB.ts_spiderling_list)
		qdel(T)
	to_chat(src, "<span class='userdanger'>All Terror Spiders, except yourself, will die off shortly.</span>")


/obj/item/projectile/terrorspider/empress
	name = "empress venom"
	icon_state = "toxin5"
	damage = 90
	damage_type = BRUTE
