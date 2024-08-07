
/mob/living/simple_animal/hostile/poison/terror_spider/reaper
	name = "Reaper of Terror"
	desc = "A terrible-looking spider, she appears to have sharp claws and jaws, and her body is covered with tumors. You can see agony and thirst for blood in her glowing eyes.."
	ai_target_method = TS_DAMAGE_BRUTE
	icon_state = "terror_reaper"
	icon_living = "terror_reaper"
	icon_dead = "terror_reaper_dead"
	maxHealth = 130
	health = 130
	move_resist = MOVE_FORCE_STRONG
	attack_sound = 'sound/creatures/terrorspiders/bite2.ogg'
	death_sound = 'sound/creatures/terrorspiders/death3.ogg'
	regeneration = 0
	melee_damage_lower = 25
	melee_damage_upper = 25
	armour_penetration = 15
	obj_damage = 50
	spider_opens_doors = 2
	speed = -0.3
	web_type = null
	gender = FEMALE
	tts_seed = "Myra"
	spider_intro_text = "Будучи Жнецом Ужаса, ваша задача - уничтожение живой силы противника. Вы быстры, наносите много урона, обладаете вампиризмом, и с каждым укусом высасываете у противников немного крови. Однако, платой за эту силу стало то, что вы постепенно теряете здоровье. Если прекратите убивать - погибните."

/mob/living/simple_animal/hostile/poison/terror_spider/reaper/Life(seconds)
	. = ..()
	if(stat != DEAD)
		adjustBruteLoss(1) //degenerates on life, can only get heals from other spiders, or from killing

/mob/living/simple_animal/hostile/poison/terror_spider/reaper/spider_specialattack(mob/living/carbon/human/L)
	. = ..()
	if(!.)
		return FALSE

	if(L.stat != DEAD) //no healing when biting corpses
		L.bleed(25) //bloodsucker
		adjustBruteLoss(-30)   //vampirism
