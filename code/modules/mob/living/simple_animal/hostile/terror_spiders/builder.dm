

// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T1 BUILDER TERROR --------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: similar to alien drona
// -------------: AI: wraps web, protects hive
// -------------: SPECIAL: wraps web realy fast
// -------------: TO FIGHT IT: shoot it from range. Kite it.

/mob/living/simple_animal/hostile/poison/terror_spider/builder
	name = "Drone of Terror"
	desc = "An ominous-looking spider, he appears to be heavy despite size."
	gender = MALE
	ai_target_method = TS_DAMAGE_BRUTE
	icon_state = "terror_drone"
	icon_living = "terror_drone"
	icon_dead = "terror_drone_dead"
	maxHealth = 100
	health = 100
	regeneration = 0
	delay_web = 10
	melee_damage_lower = 10
	melee_damage_upper = 15
	obj_damage = 50
	environment_smash = ENVIRONMENT_SMASH_WALLS
	spider_opens_doors = 2
	ranged = 1
	rapid = 2
	ranged_cooldown_time = 30
	speed = 1
	projectilesound = 'sound/creatures/terrorspiders/spit3.ogg'
	projectiletype = /obj/item/projectile/terrorspider/builder
	web_type = /obj/structure/spider/terrorweb/queen/builder
	can_wrap = FALSE
	tts_seed = "F_darkelf"
	spider_intro_text = "Будучи Дроном Ужаса, ваша задача - постройка и защита гнезда. Плетите паутину, используйте свои замедляющие плевки и замораживающие укусы для защиты яиц и гнезда. Помните, вы не регенерируете и двигаетесь медленно вне паутины!."

/mob/living/simple_animal/hostile/poison/terror_spider/builder/spider_specialattack(mob/living/carbon/human/L, poisonable)
	. = ..()

	if(!.)
		return FALSE

	L.Slowed(4 SECONDS)
	if(!poisonable)
		return TRUE
	if(L.reagents.has_reagent("frostoil", 100))
		return TRUE
	var/inject_target = pick(BODY_ZONE_CHEST, BODY_ZONE_HEAD)
	if(HAS_TRAIT(L, TRAIT_INCAPACITATED) || L.can_inject(null, FALSE, inject_target, FALSE))
		L.reagents.add_reagent("frostoil", 20)
		visible_message("<span class='danger'>[src] buries its long fangs deep into the [inject_target] of [target]!</span>")
	else
		L.reagents.add_reagent("frostoil", 10)
		visible_message("<span class='danger'>[src] buries its long fangs deep into the [inject_target] of [target]!</span>")
	return TRUE

/mob/living/simple_animal/hostile/poison/terror_spider/builder/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)  //moves slow while not in web, but fast while in. does not regenerate if not in web
	. = ..()
	var/obj/structure/spider/terrorweb/W = locate() in get_turf(src)
	if(W)
		if(speed == 1)
			set_varspeed(-0.4)
			regeneration = 3
	else if(speed != 1)
		regeneration = 0
		set_varspeed(1)

/obj/structure/spider/terrorweb/queen/builder
	max_integrity = 35
	opacity = TRUE
	name = "drone web"
	desc = "Extremely thick web."

/obj/item/projectile/terrorspider/builder
	name = "drone venom"
	icon_state = "toxin2"
	damage = 15
	stamina = 15

/obj/item/projectile/terrorspider/drone/on_hit(atom/target, blocked = 0, hit_zone)
	if((blocked != 100) && iscarbon(target))
		var/mob/living/carbon/C = target
		C.Slowed(2 SECONDS)

	return ..()
