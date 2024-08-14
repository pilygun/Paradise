/* Pens!
 * Contains:
 *		Pens
 *		Sleepy Pens
 *		Edaggers
 */


/*
 * Pens
 */
/obj/item/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	slot_flags = ITEM_SLOT_BELT|ITEM_SLOT_EARS
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=10)
	var/colour = "black"	//what colour the ink is!
	pressure_resistance = 2
	var/fake_signing = FALSE //do we always write like [sign]?

/obj/item/pen/attack_self(mob/user)
	visible_message(span_notice("[user] fumbles with [src]."))

/obj/item/pen/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] starts scribbling numbers over [user.p_them()]self with the [name]! It looks like [user.p_theyre()] trying to commit sudoku."))
	return BRUTELOSS

/obj/item/pen/blue
	name = "blue-ink pen"
	desc = "It's a normal blue ink pen."
	icon_state = "pen_blue"
	colour = "blue"

/obj/item/pen/red
	name = "red-ink pen"
	desc = "It's a normal red ink pen."
	icon_state = "pen_red"
	colour = "red"

/obj/item/pen/gray
	name = "gray-ink pen"
	desc = "It's a normal gray ink pen."
	colour = "gray"

/obj/item/pen/invisible
	desc = "It's an invisble pen marker."
	icon_state = "pen"
	colour = "white"

/obj/item/pen/multi
	name = "multicolor pen"
	desc = "It's a cool looking pen. Lots of colors!"

	// these values are for the overlay
	var/list/colour_choices = list(
		"black" = list(0.25, 0.25, 0.25),
		"red" = list(1, 0.25, 0.25),
		"green" = list(0, 1, 0),
		"blue" = list(0.5, 0.5, 1),
		"yellow" = list(1, 1, 0))
	var/pen_color_iconstate = "pencolor"
	var/pen_color_shift = 3

/obj/item/pen/multi/Initialize(mapload)
	..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/pen/multi/proc/select_colour(mob/user)
	. = tgui_input_list(user, "Which colour would you like to use?", name, colour_choices, colour)
	if(.)
		colour = .
		playsound(loc, 'sound/effects/pop.ogg', 50, TRUE)
		update_icon(UPDATE_OVERLAYS)

/obj/item/pen/multi/attack_self(mob/living/user)
	if(select_colour(user))
		..()


/obj/item/pen/multi/update_overlays()
	. = ..()
	var/icon/color_overlay = new(icon, pen_color_iconstate)
	var/list/colors = colour_choices[colour]
	color_overlay.SetIntensity(colors[1], colors[2], colors[3])
	if(pen_color_shift)
		color_overlay.Shift(SOUTH, pen_color_shift)
	. += color_overlay


/obj/item/pen/fancy
	name = "fancy pen"
	desc = "A fancy metal pen. It uses blue ink. An inscription on one side reads,\"L.L. - L.R.\""
	icon_state = "fancypen"


/obj/item/pen/fancy/bomb
	var/clickscount = 0
	var/bomb_timer
	var/obj/item/grenade/syndieminibomb/bomb


/obj/item/pen/fancy/bomb/Initialize(mapload)
	. = ..()
	bomb = new(src)


/obj/item/pen/fancy/bomb/Destroy()
	QDEL_NULL(bomb)
	return ..()


/obj/item/pen/fancy/bomb/examine(mob/user)
	. = ..()
	if(istraitor(user))
		. += span_specialnotice("They always said the pen is mightier than the sword.")


/obj/item/pen/fancy/bomb/attack_self(mob/user)
	..()
	if(++clickscount == 3)
		clickscount = initial(clickscount)

		if(!bomb_timer)
			bomb_timer = addtimer(CALLBACK(src, PROC_REF(prime_bomb), user), bomb.det_time, TIMER_STOPPABLE|TIMER_DELETE_ME)
			if(iscarbon(user))
				var/mob/living/carbon/carbon_user = user
				carbon_user.throw_mode_on()
		else
			deltimer(bomb_timer)
			bomb_timer = null


/obj/item/pen/fancy/bomb/proc/prime_bomb(mob/user)
	log_and_message_admins("[key_name_admin(user)] has detonated a pen-bomb.")
	update_mob()
	bomb.prime()


/obj/item/pen/fancy/bomb/proc/update_mob()
	if(ismob(loc))
		var/mob/mob_loc = loc
		mob_loc.drop_item_ground(src)


/obj/item/pen/fancy/bomb/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	return bomb.hit_reaction(owner, hitby, attack_text, final_block_chance, damage, attack_type)


/obj/item/pen/fancy/bomb/tool_act(mob/living/user, obj/item/I, tool_type)
	return bomb.tool_act(user, I, tool_type) || ..()


/obj/item/pen/multi/gold
	name = "Gilded Pen"
	desc = "A golden pen that is gilded with a meager amount of gold material. The word 'Nanotrasen' is etched on the clip of the pen."
	icon_state = "goldpen"
	pen_color_shift = 0

/obj/item/pen/multi/fountain
	name = "Engraved Fountain Pen"
	desc = "An expensive looking pen."
	icon_state = "fountainpen"
	pen_color_shift = 0

/*
 * Sleepypens
 */
/obj/item/pen/sleepy
	container_type = OPENCONTAINER
	origin_tech = "engineering=4;syndicate=2"


/obj/item/pen/sleepy/attack(mob/living/M, mob/user)
	if(!istype(M))
		return

	if(!M.can_inject(user, TRUE, ignore_pierceimmune = TRUE))
		return
	var/transfered = 0
	if(reagents.total_volume && M.reagents)
		transfered = reagents.trans_to(M, 50)
	to_chat(user, span_warning("You sneakily stab [M] with the pen."))
	add_attack_logs(user, M, "Stabbed with (sleepy) [src]. [transfered]u of reagents transfered.")
	return TRUE


/obj/item/pen/sleepy/Initialize(mapload)
	. = ..()
	create_reagents(100)
	reagents.add_reagent("ketamine", 100)


/*
 * (Alan) Edaggers
 */
/obj/item/pen/edagger
	origin_tech = "combat=3;syndicate=1"
	var/on = FALSE
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_RED
	armour_penetration = 20
	var/backstab_sound = 'sound/items/unsheath.ogg'
	var/backstab_cooldown = 0
	var/backstab_damage = 12

/obj/item/pen/edagger/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	user.changeNext_move(CLICK_CD_MELEE * 1.3) //attack speed is 1.3 times slower

/obj/item/pen/edagger/attack(mob/living/M, mob/living/user, def_zone)
	var/extra_force_applied = FALSE
	if(on && user.dir == M.dir && !M.incapacitated(INC_IGNORE_RESTRAINED) && user != M && backstab_cooldown <= world.time)
		backstab_cooldown = (world.time + 10 SECONDS)
		force += backstab_damage
		extra_force_applied = TRUE
		M.Weaken(2 SECONDS)
		M.apply_damage(40, STAMINA)
		add_attack_logs(user, M, "Backstabbed with [src]", ATKLOG_ALL)
		M.visible_message(span_warning("[user] stabs [M] in the back!"), span_userdanger("[user] stabs you in the back! The energy blade makes you collapse in pain!"))
		playsound(loc, backstab_sound, 5, TRUE, ignore_walls = FALSE, falloff_distance = 0)
	else
		playsound(loc, hitsound, 5, TRUE, ignore_walls = FALSE, falloff_distance = 0)
	. = ..()
	if(extra_force_applied)
		force -= backstab_damage

/obj/item/pen/edagger/get_clamped_volume() //So the parent proc of attack isn't the loudest sound known to man
	return FALSE

/obj/item/pen/edagger/attack_self(mob/living/user)
	if(on)
		on = FALSE
		force = initial(force)
		w_class = initial(w_class)
		name = initial(name)
		attack_verb = list()
		hitsound = initial(hitsound)
		embed_chance = initial(embed_chance)
		throwforce = initial(throwforce)
		playsound(user, 'sound/weapons/saberoff.ogg', 3, TRUE)
		to_chat(user, span_warning("[src] can now be concealed."))
		set_light_on(FALSE)
	else
		on = TRUE
		force = 18
		w_class = WEIGHT_CLASS_NORMAL
		name = "energy dagger"
		attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
		hitsound = 'sound/weapons/blade1.ogg'
		embed_chance = 100 //rule of cool
		throwforce = 35
		playsound(user, 'sound/weapons/saberon.ogg', 3, TRUE)
		to_chat(user, span_warning("[src] is now active."))
		set_light_on(TRUE)
	set_sharpness(on)
	update_icon(UPDATE_ICON_STATE)


/obj/item/pen/edagger/update_icon_state()
	icon_state = on ? "edagger" : initial(icon_state) //looks like a normal pen when off.
	item_state = on ? "edagger" : initial(item_state)


/obj/item/pen/edagger/comms
	icon_state = "ofcommpen"
	item_state = "ofcommpen"
	light_color = LIGHT_COLOR_BLUE


/obj/item/pen/edagger/comms/update_icon_state()
	icon_state = on ? "ofcommpen_active" : initial(icon_state)
	item_state = on ? "ofcommpen_active" : initial(item_state)


/obj/item/proc/on_write(obj/item/paper/P, mob/user)
	return

/obj/item/pen/poison
	var/uses_left = 3

/obj/item/pen/poison/on_write(obj/item/paper/P, mob/user)
	if(P.contact_poison_volume)
		to_chat(user, span_warning("[P] is already coated."))
	else if(uses_left)
		uses_left--
		P.contact_poison = "amanitin"
		P.contact_poison_volume = 15
		P.contact_poison_poisoner = user.name
		add_attack_logs(user, P, "Poison pen'ed")
		to_chat(user, span_warning("You apply the poison to [P]."))
	else
		to_chat(user, span_warning("[src] clicks. It seems to be depleted."))

/obj/item/pen/fakesign
	fake_signing = TRUE
	//desc = "It's a normal black ink pen with constantly moving tip. Wait what?" //documented bcs its should be stealthy item, like edagger and poison

/obj/item/pen/survival
	name = "survival pen"
	desc = "The latest in portable survival technology, this pen was designed as a miniature diamond pickaxe."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "digging_pen"
	toolspeed = 10 //You will never willingly choose to use one of these over a shovel.
	colour = COLOR_BLUE

