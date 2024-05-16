/mob/living
	/// True devil variables
	var/list/ownedSoullinks //soullinks we are the owner of
	var/list/sharedSoullinks //soullinks we are a/the sharer of
	var/canEnterVentWith = "/obj/item/implant=0&/obj/item/clothing/mask/facehugger=0&/obj/item/radio/borg=0&/obj/machinery/camera=0"
	var/datum/middleClickOverride/middleClickOverride = null

/mob/living/Initialize()
	. = ..()
	AddElement(/datum/element/movetype_handler)
	register_init_signals()
	var/datum/atom_hud/data/human/medical/advanced/medhud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medhud.add_to_hud(src)
	faction += "\ref[src]"
	determine_move_and_pull_forces()
	gravity_setup()
	if(ventcrawler_trait)
		var/static/list/ventcrawler_sanity = list(
			TRAIT_VENTCRAWLER_ALWAYS,
			TRAIT_VENTCRAWLER_NUDE,
			TRAIT_VENTCRAWLER_ALIEN,
		)
		if(ventcrawler_trait in ventcrawler_sanity)
			ADD_TRAIT(src, ventcrawler_trait, INNATE_TRAIT)
		else
			stack_trace("Mob [type] has improper ventcrawler_trait value.")
	GLOB.mob_living_list += src


/mob/living/Destroy()
	for(var/s in ownedSoullinks)
		var/datum/soullink/S = s
		S.ownerDies(FALSE)
		qdel(s) //If the owner is destroy()'d, the soullink is destroy()'d
	ownedSoullinks = null
	for(var/s in sharedSoullinks)
		var/datum/soullink/S = s
		S.sharerDies(FALSE)
		S.removeSoulsharer(src) //If a sharer is destroy()'d, they are simply removed
	sharedSoullinks = null
	if(ranged_ability)
		ranged_ability.remove_ranged_ability(src)
	remove_from_all_data_huds()
	if(LAZYLEN(status_effects))
		for(var/s in status_effects)
			var/datum/status_effect/S = s
			if(S.on_remove_on_mob_delete) //the status effect calls on_remove when its mob is deleted
				qdel(S)
			else
				S.be_replaced()
	GLOB.mob_living_list -= src
	return ..()

// Used to determine the forces dependend on the mob size
// Will only change the force if the force was not set in the mob type itself
/mob/living/proc/determine_move_and_pull_forces()
	var/value
	switch(mob_size)
		if(MOB_SIZE_TINY)
			value = MOVE_FORCE_EXTREMELY_WEAK
		if(MOB_SIZE_SMALL)
			value = MOVE_FORCE_WEAK
		if(MOB_SIZE_HUMAN)
			value = MOVE_FORCE_NORMAL
		if(MOB_SIZE_LARGE)
			value = MOVE_FORCE_NORMAL // For now
	if(!move_force)
		move_force = value
	if(!pull_force)
		pull_force = value
	if(!move_resist)
		move_resist = value

/mob/living/prepare_huds()
	..()
	prepare_data_huds()

/mob/living/proc/prepare_data_huds()
	med_hud_set_health()
	med_hud_set_status()


/mob/living/ghostize(can_reenter_corpse = 1)
	var/prev_client = client
	. = ..()
	if(.)
		if(ranged_ability && prev_client)
			ranged_ability.remove_mousepointer(prev_client)
	SEND_SIGNAL(src, COMSIG_LIVING_GHOSTIZED)

/mob/living/proc/OpenCraftingMenu()
	return


/mob/living/IsLying()
	return lying_angle


/mob/living/onZImpact(turf/impacted_turf, levels, impact_flags = NONE)
	if(!isopenspaceturf(impacted_turf))
		impact_flags |= ZImpactDamage(impacted_turf, levels)

	return ..()

/mob/living/proc/ZImpactDamage(turf/impacted_turf, levels)
	. = SEND_SIGNAL(src, COMSIG_LIVING_Z_IMPACT, levels, impacted_turf)
	if(. & ZIMPACT_CANCEL_DAMAGE)
		return .

	// If you are incapped, you probably can't brace yourself
	var/can_help_themselves = !incapacitated(ignore_restraints = TRUE)
	if(levels <= 1 && can_help_themselves)
		var/obj/item/organ/external/wing/bodypart_wing = get_organ(BODY_ZONE_WING)
		if(bodypart_wing && !bodypart_wing.has_fracture()) // wings can soften
			visible_message(
				span_notice("[src] makes a hard landing on [impacted_turf] but remains unharmed from the fall."),
				span_notice("You brace for the fall. You make a hard landing on [impacted_turf], but remain unharmed."),
			)
			AdjustWeakened((levels * 4 SECONDS))
			return . | ZIMPACT_NO_MESSAGE
	var/incoming_damage = (levels * 5) ** 1.5
	var/cat = iscat(src)
	var/functional_legs = TRUE
	var/skip_weaken = FALSE
	for(var/zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT))
		var/obj/item/organ/external/leg = get_organ(zone)
		if(leg.has_fracture())
			functional_legs = FALSE
			break
	if(((istajaran(src) && functional_legs) || cat) && !(lying_angle || resting) && can_help_themselves)
		. |= ZIMPACT_NO_MESSAGE|ZIMPACT_NO_SPIN
		skip_weaken = TRUE
		if(cat || (DWARF in mutations)) // lil' bounce kittens
			visible_message(
				span_notice("[src] makes a hard landing on [impacted_turf], but lands safely on [p_their()] feet!"),
				span_notice("You make a hard landing on [impacted_turf], but land safely on your feet!"),
			)
			return .
		incoming_damage *= 1.2 // at least no stuns
		visible_message(
			span_danger("[src] makes a hard landing on [impacted_turf], landing on [p_their()] feet painfully!"),
			span_userdanger("You make a hard landing on [impacted_turf], and instinctively land on your feet - still painfully!"),
		)

	if(!lying_angle && !resting)
		var/damage_for_each_leg = round(incoming_damage / 4)
		apply_damage(damage_for_each_leg, BRUTE, BODY_ZONE_L_LEG)
		apply_damage(damage_for_each_leg, BRUTE, BODY_ZONE_R_LEG)
		apply_damage(damage_for_each_leg, BRUTE, BODY_ZONE_PRECISE_L_FOOT)
		apply_damage(damage_for_each_leg, BRUTE, BODY_ZONE_PRECISE_R_FOOT)

	else
		apply_damage(incoming_damage, BRUTE)

	if(!skip_weaken)
		AdjustWeakened(levels * 5 SECONDS)
	return .


//Generic Bump(). Override MobBump() and ObjBump() instead of this.
/mob/living/Bump(atom/A, yes)
	if(..()) //we are thrown onto something
		return
	if(buckled || !yes || now_pushing)
		return
	if(ismob(A))
		if(MobBump(A))
			return
	if(isobj(A))
		if(ObjBump(A))
			return
	if(istype(A, /atom/movable))
		if(PushAM(A, move_force))
			return

//Called when we bump into a mob
/mob/living/proc/MobBump(mob/M)
	//Even if we don't push/swap places, we "touched" them, so spread fire
	spreadFire(M)

	if(get_confusion() && get_disoriented())
		Weaken(1 SECONDS)
		take_organ_damage(rand(5, 10))
		var/mob/living/victim = M
		if(istype(victim))
			victim.Weaken(1 SECONDS)
			victim.take_organ_damage(rand(5, 10))
		visible_message("<span class='danger'>[name] вреза[pluralize_ru(gender,"ет","ют")]ся в [M.name], сбивая друг друга с ног!</span>", \
					 "<span class='userdanger'>Вы жестко врезаетесь в [M.name]!</span>")
		playsound(src, 'sound/weapons/punch1.ogg', 50, 1)
		return

	// No pushing if we're already pushing past something, or if the mob we're pushing into is anchored.
	if(now_pushing || M.anchored)
		return TRUE

	//Should stop you pushing a restrained person out of the way
	if(isliving(M))
		var/mob/living/L = M
		if(L.pulledby && L.pulledby != src && HAS_TRAIT(L, TRAIT_RESTRAINED))
			if(!(world.time % 5))
				to_chat(src, "<span class='warning'>[L] is restrained, you cannot push past.</span>")
			return TRUE

		if(L.pulling)
			if(ismob(L.pulling))
				var/mob/P = L.pulling
				if(HAS_TRAIT(P, TRAIT_RESTRAINED))
					if(!(world.time % 5))
						to_chat(src, "<span class='warning'>[L] is restrained, you cannot push past.</span>")
					return TRUE

	if(moving_diagonally) //no mob swap during diagonal moves.
		return TRUE

	if(a_intent == INTENT_HELP) // Help intent doesn't mob swap a mob pulling a structure
		if(isstructure(M.pulling) || isstructure(pulling))
			return TRUE

	if(!M.buckled && !M.has_buckled_mobs())
		var/mob_swap
		//the puller can always swap with it's victim if on grab intent
		if(M.pulledby == src && a_intent == INTENT_GRAB)
			mob_swap = TRUE
		//restrained people act if they were on 'help' intent to prevent a person being pulled from being seperated from their puller
		else if((HAS_TRAIT(M, TRAIT_RESTRAINED) || M.a_intent == INTENT_HELP) && (HAS_TRAIT(src, TRAIT_RESTRAINED) || a_intent == INTENT_HELP))
			mob_swap = TRUE
		if(mob_swap)
			//switch our position with M
			if(loc && !loc.Adjacent(M.loc))
				return TRUE
			now_pushing = TRUE
			var/oldloc = loc
			var/oldMloc = M.loc

			var/M_passmob = (M.pass_flags & PASSMOB) // we give PASSMOB to both mobs to avoid bumping other mobs during swap.
			var/src_passmob = (pass_flags & PASSMOB)
			M.pass_flags |= PASSMOB
			pass_flags |= PASSMOB

			M.Move(oldloc)
			Move(oldMloc)

			if(!src_passmob)
				pass_flags &= ~PASSMOB
			if(!M_passmob)
				M.pass_flags &= ~PASSMOB

			now_pushing = FALSE
			return TRUE

	if(pulledby == M && !(a_intent == INTENT_HELP && M.a_intent == INTENT_HELP)) //prevents boosting the person pulling you, but you can still move through them on help or grab intent (see above)
		return TRUE

	// okay, so we didn't switch. but should we push?
	// not if he's not CANPUSH of course
	if(!(M.status_flags & CANPUSH))
		return TRUE
	//anti-riot equipment is also anti-push
	if(M.r_hand && (prob(M.r_hand.block_chance * 2)) && !isclothing(M.r_hand))
		return TRUE
	if(M.l_hand && (prob(M.l_hand.block_chance * 2)) && !isclothing(M.l_hand))
		return TRUE

//Called when we bump into an obj
/mob/living/proc/ObjBump(obj/O)
	if(get_confusion() && get_disoriented())
		Weaken(1 SECONDS)
		take_organ_damage(rand(5, 10))
		visible_message("<span class='danger'>[name] вреза[pluralize_ru(gender,"ет","ют")]ся в [O.name]!</span>", \
						"<span class='userdanger'>Вы жестко врезаетесь в [O.name]!</span>")
		playsound(src, 'sound/weapons/punch1.ogg', 50, 1)
	return

/mob/living/get_pull_push_speed_modifier(current_delay)
	if(!canmove)
		return pull_push_speed_modifier * 1.2
	var/average_delay = (cached_multiplicative_slowdown + current_delay) / 2
	return current_delay > average_delay ? pull_push_speed_modifier : (average_delay / current_delay)

//Called when we want to push an atom/movable
/mob/living/proc/PushAM(atom/movable/AM, force = move_force)

	if(isstructure(AM) && AM.pulledby)
		if(a_intent == INTENT_HELP && AM.pulledby != src) // Help intent doesn't push other peoples pulled structures
			return FALSE
		if(get_dist(get_step(AM, get_dir(src, AM)), AM.pulledby)>1)//Release pulled structures beyond 1 distance
			AM.pulledby.stop_pulling()

	if(now_pushing)
		return TRUE
	if(moving_diagonally) // no pushing during diagonal moves
		return TRUE
	if(!client && (mob_size < MOB_SIZE_SMALL))
		return
	now_pushing = TRUE
	var/t = get_dir(src, AM)
	var/push_anchored = FALSE
	if((AM.move_resist * MOVE_FORCE_CRUSH_RATIO) <= force)
		if(move_crush(AM, move_force, t))
			push_anchored = TRUE
	if((AM.move_resist * MOVE_FORCE_FORCEPUSH_RATIO) <= force)			//trigger move_crush and/or force_push regardless of if we can push it normally
		if(force_push(AM, move_force, t, push_anchored))
			push_anchored = TRUE
	if((AM.anchored && !push_anchored) || (force < (AM.move_resist * MOVE_FORCE_PUSH_RATIO)))
		now_pushing = FALSE
		return
	if(istype(AM, /obj/structure/window))
		var/obj/structure/window/W = AM
		if(W.fulltile)
			for(var/obj/structure/window/win in get_step(W,t))
				now_pushing = FALSE
				return
	if(pulling == AM)
		stop_pulling()

	if(client)
		client.current_move_delay *= AM.get_pull_push_speed_modifier(client.current_move_delay)
		glide_for(client.current_move_delay)

	AM.glide_size = glide_size
	var/current_dir
	if(isliving(AM))
		current_dir = AM.dir
	if(step(AM, t))
		step(src, t)
	if(current_dir)
		AM.setDir(current_dir)
	now_pushing = FALSE


/mob/living/proc/can_track(mob/living/user)
	//basic fast checks go first. When overriding this proc, I recommend calling ..() at the end.
	var/turf/source_turf = get_turf(src)
	if(!source_turf)
		return FALSE

	if(!is_level_reachable(source_turf.z))
		return FALSE

	if(!isnull(user) && src == user)
		return FALSE

	if(invisibility || alpha == 0)//cloaked
		return FALSE

	if(HAS_TRAIT(src, TRAIT_AI_UNTRACKABLE))
		return FALSE

	// Now, are they viewable by a camera? (This is last because it's the most intensive check)
	if(!near_camera(src))
		return FALSE

	return TRUE


/mob/living/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return TRUE
	if(isprojectile(mover))
		return !density || lying_angle
	if(mover.throwing)
		return !density || lying_angle || (mover.throwing.thrower == src && !ismob(mover))
	if(buckled == mover)
		return TRUE
	if(ismob(mover))
		var/mob/moving_mob = mover
		if(currently_grab_pulled && moving_mob.currently_grab_pulled)
			return FALSE
		if(mover in buckled_mobs)
			return TRUE
	return !mover.density || lying_angle


/mob/living/proc/set_pull_offsets(mob/living/user, grab_state = GRAB_PASSIVE)
	/*
	if(user.buckled)
		return //don't make them change direction or offset them if they're buckled into something.
	var/offset = 0
	switch(grab_state)
		if(GRAB_PASSIVE)
			offset = GRAB_PIXEL_SHIFT_PASSIVE
		if(GRAB_AGGRESSIVE)
			offset = GRAB_PIXEL_SHIFT_AGGRESSIVE
		if(GRAB_NECK)
			offset = GRAB_PIXEL_SHIFT_NECK
		if(GRAB_KILL)
			offset = GRAB_PIXEL_SHIFT_NECK
	user.setDir(get_dir(user, src))
	var/target_pixel_x = user.base_pixel_x + M.body_position_pixel_x_offset
	var/target_pixel_y = user.base_pixel_y + M.body_position_pixel_y_offset
	switch(user.dir)
		if(NORTH)
			animate(user, pixel_x = target_pixel_x, pixel_y = target_pixel_y + offset, 3)
		if(SOUTH)
			animate(user, pixel_x = target_pixel_x, pixel_y = target_pixel_y - offset, 3)
		if(EAST)
			if(user.lying_angle == 270) //update the dragged dude's direction if we've turned
				user.set_lying_angle(90)
			animate(user, pixel_x = target_pixel_x + offset, pixel_y = target_pixel_y, 3)
		if(WEST)
			if(user.lying_angle == 90)
				user.set_lying_angle(270)
			animate(user, pixel_x = target_pixel_x - offset, pixel_y = target_pixel_y, 3)
	*/


/mob/living/proc/reset_pull_offsets(mob/living/user, override)
	/*
	if(!override && user.buckled)
		return
	animate(user, pixel_x = user.base_pixel_x + user.body_position_pixel_x_offset , pixel_y = user.base_pixel_y + user.body_position_pixel_y_offset, 1)
	*/


/mob/living/CanPathfindPass(obj/item/card/id/ID, to_dir, atom/movable/caller, no_id = FALSE)
	return TRUE // Unless you're a mule, something's trying to run you over.


//mob verbs are a lot faster than object verbs
//for more info on why this is not atom/pull, see examinate() in mob.dm
/mob/living/verb/pulled(atom/movable/AM as mob|obj in oview(1))
	set name = "Pull"
	set category = "Object"

	if(istype(AM) && Adjacent(AM))
		start_pulling(AM, show_message = TRUE)
	else
		stop_pulling()

/mob/living/stop_pulling()
	if(ismob(pulling))
		reset_pull_offsets(pulling)
	..()
	pullin?.update_icon(UPDATE_ICON_STATE)

/mob/living/verb/stop_pulling1()
	set name = "Stop Pulling"
	set category = "IC"
	stop_pulling()

//same as above
/mob/living/pointed(atom/A as mob|obj|turf in view())
	if(incapacitated(ignore_lying = TRUE))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_FAKEDEATH))
		return FALSE
	return ..()


/mob/living/run_pointed(atom/target)
	if(!..())
		return FALSE

	var/obj/item/hand_item = get_active_hand()
	var/pointed_object = "[target.declent_ru(ACCUSATIVE)]"

	if(target.loc in src)
		var/atom/inside = target.loc
		pointed_object += " внутри [inside.declent_ru(GENITIVE)]"

	if(isgun(hand_item) && target != hand_item)
		if(a_intent == INTENT_HELP || !ismob(target))
			visible_message("<b>[declent_ru(NOMINATIVE)]</b> указыва[pluralize_ru(gender,"ет","ют")] [hand_item.declent_ru(INSTRUMENTAL)] на [pointed_object].")
			return TRUE

		target.visible_message(
			span_danger("[declent_ru(NOMINATIVE)] направля[pluralize_ru(src.gender,"ет","ют")] [hand_item.declent_ru(INSTRUMENTAL)] на [pointed_object]!"),
			span_userdanger("[declent_ru(NOMINATIVE)] направля[pluralize_ru(src.gender,"ет","ют")] [hand_item.declent_ru(INSTRUMENTAL)] на [pluralize_ru(target.gender,"тебя","вас")]!"),
		)
		SEND_SOUND(target, 'sound/weapons/targeton.ogg')
		SEND_SOUND(src, 'sound/weapons/targeton.ogg')
		add_emote_logs(src, "point [hand_item] HARM to [key_name(target)] [COORD(target)]")
		return TRUE

	if(istype(hand_item, /obj/item/toy/russian_revolver/trick_revolver) && target != hand_item)
		var/obj/item/toy/russian_revolver/trick_revolver/trick = hand_item
		visible_message(span_danger("[declent_ru(NOMINATIVE)] направля[pluralize_ru(src.gender,"ет","ют")] [trick.declent_ru(INSTRUMENTAL)] на... и [trick.declent_ru(NOMINATIVE)] срабатывает у [genderize_ru(gender, "него","неё","него","них")] в руках!"))
		trick.shoot_gun(src)
		add_emote_logs(src, "point to [key_name(target)] [COORD(target)]")
		return TRUE

	visible_message("<b>[declent_ru(NOMINATIVE)]</b> указыва[pluralize_ru(gender,"ет","ют")] на [pointed_object].")
	add_emote_logs(src, "point to [key_name(target)] [COORD(target)]")
	return TRUE


/mob/living/verb/succumb()
	set hidden = 1
	if(InCritical())
		add_misc_logs(src, "has succumbed to death with [round(health, 0.1)] points of health")
		adjustOxyLoss(health - HEALTH_THRESHOLD_DEAD)
		// super check for weird mobs, including ones that adjust hp
		// we don't want to go overboard and gib them, though
		for(var/i = 1 to 5)
			if(health < HEALTH_THRESHOLD_DEAD)
				break
			take_overall_damage(max(5, health - HEALTH_THRESHOLD_DEAD), 0)
		death()
		to_chat(src, "<span class='notice'>You have given up life and succumbed to death.</span>")


/mob/living/proc/InCritical()
	return (health < HEALTH_THRESHOLD_CRIT && health > HEALTH_THRESHOLD_DEAD && stat == UNCONSCIOUS)


/mob/living/ex_act(severity)
	..()
	flash_eyes()

/mob/living/acid_act(acidpwr, acid_volume)
	take_organ_damage(acidpwr * min(1, acid_volume * 0.1))
	return 1

/mob/living/welder_act(mob/user, obj/item/I)
	if(!I.tool_use_check(user, 0, silent = TRUE)) //Don't need the message, just if it succeeded
		return
	if(IgniteMob())
		message_admins("[key_name_admin(user)] set [key_name_admin(src)] on fire with [I]")
		add_attack_logs(user, src, "set on fire with [I]")

/mob/living/update_stat(reason = "none given", should_log = FALSE)
	if(status_flags & GODMODE)
		if(stat != CONSCIOUS && stat != DEAD)
			WakeUp()
	med_hud_set_health()
	med_hud_set_status()
	update_health_hud()
	update_stamina_hud()
	update_damage_hud()
	if(should_log)
		log_debug("[src] update_stat([reason][status_flags & GODMODE ? ", GODMODE" : ""])")

/mob/living/proc/updatehealth(reason = "none given", should_log = FALSE)
	if(status_flags & GODMODE)
		health = maxHealth
		update_stat("updatehealth([reason])", should_log)
		return
	health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()
	update_stat("updatehealth([reason])", should_log)

//This proc is used for mobs which are affected by pressure to calculate the amount of pressure that actually
//affects them once clothing is factored in. ~Errorage
/mob/living/proc/calculate_affecting_pressure(pressure)
	return 0

/mob/living/proc/adjustBodyTemp(actual, desired, incrementboost)
	var/temperature = actual
	var/difference = abs(actual-desired)	//get difference
	var/increments = difference/10 //find how many increments apart they are
	var/change = increments*incrementboost	// Get the amount to change by (x per increment)

	// Too cold
	if(actual < desired)
		temperature += change
		if(actual > desired)
			temperature = desired
	// Too hot
	if(actual > desired)
		temperature -= change
		if(actual < desired)
			temperature = desired
//	if(ishuman(src))
//		to_chat(world, "[src] ~ [bodytemperature] ~ [temperature]")
	return temperature


/mob/proc/get_contents()


//Recursive function to find everything a mob is holding.
/mob/living/get_contents(var/obj/item/storage/Storage = null)
	var/list/L = list()

	if(Storage) //If it called itself
		L += Storage.return_inv()

		//Leave this commented out, it will cause storage items to exponentially add duplicate to the list
		//for(var/obj/item/storage/S in Storage.return_inv()) //Check for storage items
		//	L += get_contents(S)

		for(var/obj/item/gift/G in Storage.return_inv()) //Check for gift-wrapped items
			L += G.gift
			if(isstorage(G.gift))
				L += get_contents(G.gift)

		for(var/obj/item/smallDelivery/D in Storage.return_inv()) //Check for package wrapped items
			L += D.wrapped
			if(isstorage(D.wrapped)) //this should never happen
				L += get_contents(D.wrapped)
		return L

	else

		L += contents
		for(var/obj/item/storage/S in contents)	//Check for storage items
			L += get_contents(S)
		for(var/obj/item/clothing/suit/storage/S in contents)//Check for labcoats and jackets
			L += get_contents(S)
		for(var/obj/item/clothing/accessory/storage/S in contents)//Check for holsters
			L += get_contents(S)
		for(var/obj/item/implant/storage/I in contents) //Check for storage implants.
			L += I.get_contents()
		for(var/obj/item/gift/G in contents) //Check for gift-wrapped items
			L += G.gift
			if(isstorage(G.gift))
				L += get_contents(G.gift)

		for(var/obj/item/smallDelivery/D in contents) //Check for package wrapped items
			L += D.wrapped
			if(isstorage(D.wrapped)) //this should never happen
				L += get_contents(D.wrapped)
		for(var/obj/item/folder/F in contents)
			L += F.contents //Folders can't store any storage items.

		return L

/mob/living/proc/check_contents_for(A)
	var/list/L = get_contents()

	for(var/obj/B in L)
		if(B.type == A)
			return 1
	return 0

// Living mobs use can_inject() to make sure that the mob is not syringe-proof in general.
/mob/living/proc/can_inject(mob/user, error_msg, target_zone, penetrate_thick, ignore_pierceimmune)
	return TRUE

/mob/living/is_injectable(mob/user, allowmobs = TRUE)
	return (allowmobs && reagents && can_inject(user))

/mob/living/is_drawable(mob/user, allowmobs = TRUE)
	return (allowmobs && reagents && can_inject(user))

/mob/living/proc/restore_all_organs()
	return

/mob/living/proc/revive()
	rejuvenate()
	if(iscarbon(src))
		var/mob/living/carbon/C = src

		if(C.handcuffed && !initial(C.handcuffed))
			C.drop_item_ground(C.handcuffed, TRUE)

		if(C.legcuffed && !initial(C.legcuffed))
			C.drop_item_ground(C.legcuffed, TRUE)

		if(C.reagents)
			C.reagents.clear_reagents()
			QDEL_LIST(C.reagents.addiction_list)
			C.reagents.addiction_threshold_accumulated.Cut()
		if(iscultist(src))
			if(SSticker.mode.cult_risen)
				SSticker.mode.rise(src)
			if(SSticker.mode.cult_ascendant)
				SSticker.mode.ascend(src)

		QDEL_LIST(C.processing_patches)

// rejuvenate: Called by `revive` to get the mob into a revivable state
// the admin "rejuvenate" command calls `revive`, not this proc.
/mob/living/proc/rejuvenate()
	var/mob/living/carbon/human/human_mob = null //Get this declared for use later.

	// shut down various types of badness
	setToxLoss(0)
	setOxyLoss(0)
	setCloneLoss(0)
	setBrainLoss(0)
	setStaminaLoss(0)
	SetSleeping(0)
	SetDisgust(0)
	SetParalysis(0, TRUE)
	SetStunned(0, TRUE)
	SetWeakened(0, TRUE)
	SetSlowed(0)
	SetImmobilized(0)
	SetLoseBreath(0)
	SetDizzy(0)
	SetJitter(0)
	SetStuttering(0)
	SetConfused(0)
	SetDrowsy(0)
	radiation = 0
	SetDruggy(0)
	SetHallucinate(0)
	set_nutrition(NUTRITION_LEVEL_FED + 50)
	set_bodytemperature(dna ? dna.species.body_temperature : BODYTEMP_NORMAL)
	CureBlind()
	CureNearsighted()
	CureMute()
	CureDeaf()
	CureTourettes()
	CureEpilepsy()
	CureCoughing()
	CureNervous()
	SetEyeBlind(0)
	SetEyeBlurry(0)
	SetDeaf(0)
	heal_overall_damage(1000, 1000)
	ExtinguishMob()
	CureAllDiseases(FALSE)
	fire_stacks = 0
	on_fire = 0
	suiciding = 0
	if(buckled) //Unbuckle the mob and clear the alerts.
		buckled.unbuckle_mob(src, force = TRUE)

	if(iscarbon(src))
		var/mob/living/carbon/C = src
		C.uncuff()

		for(var/thing in C.diseases)
			var/datum/disease/D = thing
			D.cure(need_immunity = FALSE)

		// restore all of the human's blood and reset their shock stage
		if(ishuman(src))
			human_mob = src
			human_mob.set_heartattack(FALSE)
			human_mob.restore_blood()
			human_mob.decaylevel = 0
			human_mob.remove_all_embedded_objects()
	SEND_SIGNAL(src, COMSIG_LIVING_AHEAL)
	restore_all_organs()
	surgeries.Cut() //End all surgeries.
	if(stat == DEAD)
		update_revive()
	else if(stat == UNCONSCIOUS)
		WakeUp()

	update_fire()
	regenerate_icons()
	restore_blood()
	if(human_mob)
		human_mob.update_eyes()
		human_mob.update_dna()
	return

/mob/living/proc/remove_CC(should_update_canmove = TRUE)
	SetWeakened(0)
	SetStunned(0)
	SetParalysis(0)
	SetImmobilized(0)
	SetSleeping(0)
	setStaminaLoss(0)
	SetSlowed(0)

/mob/living/proc/UpdateDamageIcon()
	return


/mob/living/proc/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()

	if(CONFIG_GET(flag/allow_metadata))
		if(client)
			to_chat(usr, "[src]'s Metainfo:<br>[client.prefs.metadata]")
		else
			to_chat(usr, "[src] does not have any stored infomation!")
	else
		to_chat(usr, "OOC Metadata is not supported by this server!")

	return

/mob/living/Move(atom/newloc, direct, movetime)
	if(buckled && buckled.loc != newloc) //not updating position
		if(!buckled.anchored)
			return buckled.Move(newloc, direct)
		else
			return FALSE

	if(pulling && get_dist(src, pulling) > 1)
		stop_pulling()
	if(pulling && !isturf(pulling.loc) && pulling.loc != loc)
		log_debug("[src]'s pull on [pulling] was broken despite [pulling] being in [pulling.loc]. Pull stopped manually.")
		stop_pulling()
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		stop_pulling()

	var/turf/old_loc = loc
	. = ..()
	if(.)
		step_count++
		pull_pulled(old_loc, pulling, movetime)
		if(!currently_grab_pulled)
			pull_grabbed(old_loc, direct, movetime)

	if(pulledby && moving_diagonally != FIRST_DIAG_STEP && get_dist(src, pulledby) > 1) //seperated from our puller and not in the middle of a diagonal move
		pulledby.stop_pulling()

	if(s_active && !(s_active in contents) && get_turf(s_active) != get_turf(src))	//check !( s_active in contents ) first so we hopefully don't have to call get_turf() so much.
		s_active.close(src)

/mob/living/proc/pull_pulled(turf/dest, atom/movable/pullee, movetime)
	if(pulling && pulling == pullee) // we were pulling a thing and didn't lose it during our move.
		if(pulling.anchored)
			stop_pulling()
			return
		if(isobj(pulling))
			var/obj/object = pulling
			if(object.obj_flags & BLOCKS_CONSTRUCTION_DIR)
				var/obj/structure/window/window = object
				var/fulltile = istype(window) ? window.fulltile : FALSE
				if(!valid_build_direction(dest, object.dir, is_fulltile = fulltile))
					stop_pulling()
					return

		var/pull_dir = get_dir(src, pulling)
		pulling.glide_size = glide_size
		if(get_dist(src, pulling) > 1 || (moving_diagonally != SECOND_DIAG_STEP && ((pull_dir - 1) & pull_dir))) // puller and pullee more than one tile away or in diagonal position
			// This sucks.
			// Pulling things up/down & into other z-levels. Conga line lives.
			if(pulling.z != z && can_z_move(null, pulling, dest))
				dest = get_step_multiz(pulling, get_dir(pulling, dest))
			if(isliving(pulling))
				var/mob/living/M = pulling
				if(M.lying_angle && !M.buckled && (prob(M.getBruteLoss() * 200 / M.maxHealth)))
					M.makeTrail(dest)
				if(ishuman(pulling))
					var/mob/living/carbon/human/H = pulling
					if(!H.lying_angle)
						if(H.get_confusion() > 0 && m_intent != MOVE_INTENT_WALK && prob(4))
							H.Weaken(4 SECONDS)
							pulling.stop_pulling()
							visible_message(span_danger("Ноги [H] путаются и [genderize_ru(H.gender,"он","она","оно","они")] с грохотом падает на пол!"))
			else
				pulling.pixel_x = initial(pulling.pixel_x)
				pulling.pixel_y = initial(pulling.pixel_y)
			var/old_dir = pulling.dir
			pulling.Move(dest, get_dir(pulling, dest), movetime) // the pullee tries to reach our previous position
			if(!pulling)
				return
			if(pulling.dir != old_dir)
				SEND_SIGNAL(pulling, COMSIG_ATOM_DIR_CHANGE, old_dir, pulling.dir)
			if(get_dist(src, pulling) > 1) // the pullee couldn't keep up
				stop_pulling()

/mob/living/proc/pull_grabbed(turf/old_turf, direct, movetime)
	if(!Adjacent(old_turf))
		return
	// yes, this is four distinct `for` loops. No, they can't be merged.
	var/list/grabbing = list()
	for(var/mob/M in ret_grab())
		if(src != M)
			grabbing |= M
	for(var/mob/M in grabbing)
		M.currently_grab_pulled = TRUE
		M.animate_movement = SYNC_STEPS
	for(var/i in 1 to length(grabbing))
		var/mob/M = grabbing[i]
		if(QDELETED(M))  // old code warned me that M could go missing during a move, so I'm cargo-culting it here
			continue
		if(!isturf(M.loc))
			continue
		// compile a list of turfs we can maybe move them towards
		// importantly, this should happen before actually trying to move them to either of those
		// otherwise they can be moved twice (since `Move` returns TRUE only if it managed to
		// *fully* move where you wanted it to; it can still move partially and return FALSE)
		var/possible_dest = list()
		for(var/turf/dest in orange(src, 1))
			if(dest.Adjacent(M))
				possible_dest |= dest
		if(i == 1) // at least one of them should try to trail behind us, for aesthetics purposes
			if(M.Move(old_turf, get_dir(M, old_turf), movetime))
				continue
		// By this time the `old_turf` is definitely occupied by something immovable.
		// So try to move them into some other adjacent turf, in a believable way
		if(Adjacent(M))
			continue // they are already adjacent
		for(var/turf/dest in possible_dest)
			if(M.Move(dest, get_dir(M, dest), movetime))
				break
	for(var/mob/M in grabbing)
		M.currently_grab_pulled = null
		M.animate_movement = SLIDE_STEPS

	for(var/obj/item/grab/G in src)
		if(G.state == GRAB_NECK)
			setDir(angle2dir((dir2angle(direct) + 202.5) % 365))
		G.adjust_position()
	for(var/obj/item/grab/G in grabbed_by)
		G.adjust_position()

/mob/living/proc/makeTrail(turf/T)
	if(!has_gravity())
		return
	var/blood_exists = 0

	for(var/obj/effect/decal/cleanable/trail_holder/C in loc) //checks for blood splatter already on the floor
		blood_exists = 1
	if(isturf(loc))
		var/trail_type = getTrail()
		if(trail_type)
			var/brute_ratio = round(getBruteLoss()/maxHealth, 0.1)
			if(blood_volume && blood_volume > max(BLOOD_VOLUME_NORMAL*(1 - brute_ratio * 0.25), 0))//don't leave trail if blood volume below a threshold
				blood_volume = max(blood_volume - max(1, brute_ratio * 2), 0) 					//that depends on our brute damage.
				var/newdir = get_dir(T, loc)
				if(newdir != src.dir)
					newdir = newdir | dir
					if(newdir == 3) //N + S
						newdir = NORTH
					else if(newdir == 12) //E + W
						newdir = EAST
				if((newdir in GLOB.cardinal) && (prob(50)))
					newdir = turn(get_dir(T, loc), 180)
				if(!blood_exists)
					new /obj/effect/decal/cleanable/trail_holder(loc)
				for(var/obj/effect/decal/cleanable/trail_holder/TH in loc)
					if((!(newdir in TH.existing_dirs) || trail_type == "trails_1" || trail_type == "trails_2") && TH.existing_dirs.len <= 16) //maximum amount of overlays is 16 (all light & heavy directions filled)
						TH.existing_dirs += newdir
						TH.overlays.Add(image('icons/effects/blood.dmi', trail_type, dir = newdir))
						TH.transfer_mob_blood_dna(src)
						if(ishuman(src))
							var/mob/living/carbon/human/H = src
							if(H.dna.species.blood_color)
								TH.color = H.dna.species.blood_color
						else
							TH.color = "#A10808"

/mob/living/carbon/human/makeTrail(turf/T)

	if((NO_BLOOD in dna.species.species_traits) || dna.species.exotic_blood || !bleed_rate || bleedsuppress)
		return
	..()

/mob/living/proc/getTrail()
	if(getBruteLoss() < 300)
		return pick("ltrails_1", "ltrails_2")
	else
		return pick("trails_1", "trails_2")

/mob/living/experience_pressure_difference(pressure_difference, direction, pressure_resistance_prob_delta = 0)
	playsound(src, 'sound/effects/space_wind.ogg', 50, TRUE)
	if(buckled || mob_negates_gravity())
		return FALSE
	if(client && client.move_delay >= world.time + world.tick_lag * 2)
		pressure_resistance_prob_delta -= 30

	var/list/turfs_to_check = list()

	if(has_limbs)
		var/turf/T = get_step(src, angle2dir(dir2angle(direction) + 90))
		if (T)
			turfs_to_check += T

		T = get_step(src, angle2dir(dir2angle(direction) - 90))
		if(T)
			turfs_to_check += T

		for(var/t in turfs_to_check)
			T = t
			if(T.density)
				pressure_resistance_prob_delta -= 20
				continue
			for(var/atom/movable/AM in T)
				if(AM.density && AM.anchored)
					pressure_resistance_prob_delta -= 20
					break

	..(pressure_difference, direction, pressure_resistance_prob_delta)

/*//////////////////////
	START RESIST PROCS
*///////////////////////

/mob/living/can_resist()
	return !((next_move > world.time) || incapacitated(ignore_restraints = TRUE, ignore_lying = TRUE))

/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	DEFAULT_QUEUE_OR_CALL_VERB(VERB_CALLBACK(src, PROC_REF(run_resist)))

///proc extender of [/mob/living/verb/resist] meant to make the process queable if the server is overloaded when the verb is called
/mob/living/proc/run_resist()
	if(!can_resist())
		return
	changeNext_move(CLICK_CD_RESIST)

	SEND_SIGNAL(src, COMSIG_LIVING_RESIST, src)

	if(!HAS_TRAIT(src, TRAIT_RESTRAINED) && resist_grab())
		return

	//unbuckling yourself
	if(buckled && last_special <= world.time)
		resist_buckle()

	//Breaking out of a container (Locker, sleeper, cryo...)
	else if(isobj(loc))
		var/obj/C = loc
		C.container_resist(src)

	else if(canmove)
		if(on_fire)
			resist_fire() //stop, drop, and roll
		else if(last_special <= world.time)
			resist_restraints() //trying to remove cuffs.

/*////////////////////
	RESIST SUBPROCS
*/////////////////////
/mob/living/proc/resist_grab()
	var/resisting = 0
	for(var/X in grabbed_by)
		var/obj/item/grab/G = X
		resisting++
		switch(G.state)
			if(GRAB_PASSIVE)
				if(prob(100 / get_grab_strength(G, src)))
					qdel(G)

			if(GRAB_AGGRESSIVE)
				if(prob(60 / get_grab_strength(G, src)))
					visible_message("<span class='danger'>[src] has broken free of [G.assailant]'s grip!</span>")
					qdel(G)

			if(GRAB_NECK)
				if(prob(5 / get_grab_strength(G, src)))
					visible_message("<span class='danger'>[src] has broken free of [G.assailant]'s headlock!</span>")
					qdel(G)

	if(resisting)
		visible_message("<span class='danger'>[src] resists!</span>")
		return 1

/mob/living/proc/get_grab_strength(obj/item/grab/G, mob/living/M)
	var/modifier = 0
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		modifier = G.strength / H.dna.species.strength_modifier
	else
		modifier = G.strength
	return modifier

/mob/living/proc/resist_buckle()
	buckled.user_unbuckle_mob(src, src)

/mob/living/proc/resist_muzzle()
	return

/mob/living/proc/resist_fire()
	return

/mob/living/proc/resist_restraints()
	return


/*//////////////////////
	END RESIST PROCS
*///////////////////////

/mob/living/proc/Exhaust()
	to_chat(src, "<span class='notice'>You're too exhausted to keep going...</span>")
	Weaken(10 SECONDS)

/mob/living/proc/get_visible_name()
	return name

/mob/living/proc/is_facehugged()
	return FALSE


/mob/living/proc/update_gravity(gravity)
	// Handle movespeed stuff
	var/speed_change = max(0, gravity - STANDARD_GRAVITY)
	if(speed_change)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/gravity, multiplicative_slowdown = speed_change)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/gravity)

	// Time to add/remove gravity alerts. sorry for the mess it's gotta be fast
	var/obj/screen/alert/gravity_alert = LAZYACCESS(alerts, ALERT_GRAVITY)
	switch(gravity)
		if(-INFINITY to NEGATIVE_GRAVITY)
			if(!istype(gravity_alert, /obj/screen/alert/negative))
				throw_alert(ALERT_GRAVITY, /obj/screen/alert/negative)
				ADD_TRAIT(src, TRAIT_MOVE_UPSIDE_DOWN, NEGATIVE_GRAVITY_TRAIT)
				var/matrix/flipped_matrix = transform
				flipped_matrix.b = -flipped_matrix.b
				flipped_matrix.e = -flipped_matrix.e
				animate(src, transform = flipped_matrix, pixel_y = pixel_y+4, time = 0.5 SECONDS, easing = EASE_OUT)
				base_pixel_y += 4
		if(NEGATIVE_GRAVITY + 0.01 to 0)
			if(!istype(gravity_alert, /obj/screen/alert/weightless))
				throw_alert(ALERT_GRAVITY, /obj/screen/alert/weightless)
				ADD_TRAIT(src, TRAIT_MOVE_FLOATING, NO_GRAVITY_TRAIT)
		if(0.01 to STANDARD_GRAVITY)
			if(gravity_alert)
				clear_alert(ALERT_GRAVITY)
		if(STANDARD_GRAVITY + 0.01 to GRAVITY_DAMAGE_THRESHOLD - 0.01)
			throw_alert(ALERT_GRAVITY, /obj/screen/alert/highgravity)
		if(GRAVITY_DAMAGE_THRESHOLD to INFINITY)
			throw_alert(ALERT_GRAVITY, /obj/screen/alert/veryhighgravity)

	// If we had no gravity alert, or the same alert as before, go home
	if(!gravity_alert || LAZYACCESS(alerts, ALERT_GRAVITY) == gravity_alert)
		return

	// By this point we know that we do not have the same alert as we used to
	if(istype(gravity_alert, /obj/screen/alert/weightless))
		REMOVE_TRAIT(src, TRAIT_MOVE_FLOATING, NO_GRAVITY_TRAIT)

	else if(istype(gravity_alert, /obj/screen/alert/negative))
		REMOVE_TRAIT(src, TRAIT_MOVE_UPSIDE_DOWN, NEGATIVE_GRAVITY_TRAIT)
		var/matrix/flipped_matrix = transform
		flipped_matrix.b = -flipped_matrix.b
		flipped_matrix.e = -flipped_matrix.e
		animate(src, transform = flipped_matrix, pixel_y = pixel_y-4, time = 0.5 SECONDS, easing = EASE_OUT)
		base_pixel_y -= 4


///Proc to modify the value of num_legs and hook behavior associated to this event.
/mob/living/proc/set_num_legs(new_value)
	if(num_legs == new_value)
		return
	. = num_legs
	num_legs = new_value


///Proc to modify the value of usable_legs and hook behavior associated to this event.
/mob/living/proc/set_usable_legs(new_value)
	if(usable_legs == new_value)
		return
	if(new_value < 0) // Sanity check
		stack_trace("[src] had set_usable_legs() called on them with a negative value!")
		new_value = 0

	. = usable_legs
	usable_legs = new_value

	update_limbless_slowdown()

	/*
	if(new_value > .) // Gained leg usage.
		REMOVE_TRAIT(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
	else if(!(movement_type & (FLYING|FLOATING))) //Lost leg usage, not flying.
		if(!usable_legs)
			ADD_TRAIT(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
			if(!usable_hands)
				ADD_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
	*/


///Proc to modify the value of num_hands and hook behavior associated to this event.
/mob/living/proc/set_num_hands(new_value)
	if(num_hands == new_value)
		return
	. = num_hands
	num_hands = new_value


///Proc to modify the value of usable_hands and hook behavior associated to this event.
/mob/living/proc/set_usable_hands(new_value)
	if(usable_hands == new_value)
		return
	. = usable_hands
	usable_hands = new_value

	if(!usable_legs)
		update_limbless_slowdown()	// in case we got new hand but have no legs

	/*
	if(new_value > .) // Gained hand usage.
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
	else if(!(movement_type & (FLYING|FLOATING)) && !usable_hands && !usable_legs) //Lost a hand, not flying, no hands left, no legs.
		ADD_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
	*/


/mob/living/proc/update_limbless_slowdown()
	if(usable_legs < default_num_legs)
		var/limbless_slowdown = (default_num_legs - usable_legs) * 4 - get_crutches()
		if(!usable_legs && usable_hands < default_num_hands)
			limbless_slowdown += (default_num_hands - usable_hands) * 4
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/limbless, multiplicative_slowdown = limbless_slowdown)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/limbless)


/mob/living/proc/can_use_vents()
	return "You can't fit into that vent."

//called when the mob receives a bright flash
/mob/living/proc/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /obj/screen/fullscreen/flash)
	if(status_flags & GODMODE)
		return FALSE
	if(check_eye_prot() < intensity && (override_blindness_check || !(BLINDNESS in mutations)))
		overlay_fullscreen("flash", type)
		addtimer(CALLBACK(src, PROC_REF(clear_fullscreen), "flash", 25), 25)
		return TRUE


/mob/living/proc/check_eye_prot()
	var/number = 0
	var/datum/antagonist/vampire/vampire = mind?.has_antag_datum(/datum/antagonist/vampire)
	if(vampire?.get_ability(/datum/vampire_passive/eyes_flash_protection))
		number++
	if(vampire?.get_ability(/datum/vampire_passive/eyes_welding_protection))
		number++
	return number


/mob/living/proc/check_ear_prot()
	var/datum/antagonist/vampire/vampire = mind?.has_antag_datum(/datum/antagonist/vampire)
	if(vampire?.get_ability(/datum/vampire_passive/ears_bang_protection))
		return HEARING_PROTECTION_TOTAL
	return HEARING_PROTECTION_NONE


// The src mob is trying to strip an item from someone
// Override if a certain type of mob should be behave differently when stripping items (can't, for example)
/mob/living/stripPanelUnequip(obj/item/what, mob/who, where, silent = FALSE)
	if(HAS_TRAIT(what, TRAIT_NODROP))
		to_chat(src, "<span class='warning'>You can't remove \the [what.name], it appears to be stuck!</span>")
		return
	if(!silent)
		who.visible_message("<span class='danger'>[src] tries to remove [who]'s [what.name].</span>", \
						"<span class='userdanger'>[src] tries to remove [who]'s [what.name].</span>")
	what.add_fingerprint(src)
	if(do_after(src, what.strip_delay, who, NONE))
		if(what && what == who.get_item_by_slot(where) && Adjacent(who))
			if(!who.drop_item_ground(what, silent = silent))
				return
			if(silent && !QDELETED(what) && isturf(what.loc))
				put_in_hands(what, silent = TRUE)
			add_attack_logs(src, who, "Stripped of [what]")

// The src mob is trying to place an item on someone
// Override if a certain mob should be behave differently when placing items (can't, for example)
/mob/living/stripPanelEquip(obj/item/what, mob/who, where, silent = FALSE)
	what = get_active_hand()
	if(what && HAS_TRAIT(what, TRAIT_NODROP))
		to_chat(src, "<span class='warning'>You can't put \the [what.name] on [who], it's stuck to your hand!</span>")
		return
	if(what)
		if(!what.mob_can_equip(who, where, TRUE, TRUE))
			to_chat(src, "<span class='warning'>\The [what.name] doesn't fit in that place!</span>")
			return
		if(!silent)
			visible_message("<span class='notice'>[src] tries to put [what] on [who].</span>")
		if(do_after(src, what.put_on_delay, who, NONE))
			if(what && Adjacent(who) && !HAS_TRAIT(what, TRAIT_NODROP))
				drop_item_ground(what, silent = silent)
				who.equip_to_slot_if_possible(what, where, disable_warning = TRUE, initial = silent)
				add_attack_logs(src, who, "Equipped [what]")

/mob/living/singularity_act()
	investigate_log("([key_name_log(src)]) has been consumed by the singularity.", INVESTIGATE_ENGINE) //Oh that's where the clown ended up!
	gib()
	return 20

/mob/living/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_SIX) //your puny magboots/wings/whatever will not save you against supermatter singularity
		throw_at(S, 14, 3, src, TRUE)
	else if(!mob_negates_gravity())
		step_towards(src,S)

/mob/living/narsie_act()
	if(client)
		make_new_construct(/mob/living/simple_animal/hostile/construct/harvester, src, cult_override = TRUE)
	spawn_dust()
	gib()

/mob/living/ratvar_act(weak = FALSE)
	if(weak)
		return //It's too weak to break a flesh!
	if(client)
		switch(rand(1,3))
			if(1)
				var/mob/living/simple_animal/hostile/clockwork/marauder/cog = new (get_turf(src))
				if(mind)
					SSticker.mode.add_clocker(mind)
					mind.transfer_to(cog)
				else
					cog.key = client.key
			if(2)
				var/mob/living/silicon/robot/cogscarab/cog = new (get_turf(src))
				if(mind)
					SSticker.mode.add_clocker(mind)
					mind.transfer_to(cog)
				else
					cog.key = client.key
			if(3)
				var/mob/living/silicon/robot/cog = new (get_turf(src))
				if(mind)
					SSticker.mode.add_clocker(mind)
					mind.transfer_to(cog)
				else
					cog.key = client.key
				cog.ratvar_act()
	spawn_dust()
	gib()

/mob/living/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!used_item)
		used_item = get_active_hand()
		if(!visual_effect_icon && used_item?.attack_effect_override)
			visual_effect_icon = used_item.attack_effect_override
	..()


/// Helper proc that causes the mob to do a jittering animation by jitter_amount.
/// `jitteriness` will only apply up to 300 (maximum jitter effect).
/mob/living/proc/do_jitter_animation(jitteriness, loop_amount = 6)
	var/amplitude = min(4, (jitteriness / 100) + 1)
	var/pixel_x_diff = rand(-amplitude, amplitude)
	var/pixel_y_diff = rand(-amplitude / 3, amplitude / 3)
	animate(src, pixel_x = pixel_x_diff, pixel_y = pixel_y_diff, time = 0.2 SECONDS, loop = loop_amount, flags = (ANIMATION_RELATIVE|ANIMATION_PARALLEL))
	animate(pixel_x = -pixel_x_diff, pixel_y = -pixel_y_diff, time = 0.2 SECONDS, flags = ANIMATION_RELATIVE)


/mob/living/proc/get_temperature(datum/gas_mixture/environment)
	if(istype(loc, /obj/structure/closet/critter))
		return environment.temperature
	if(ismecha(loc))
		var/obj/mecha/M = loc
		return  M.return_temperature()
	if(isvampirecoffin(loc))
		var/obj/structure/closet/coffin/vampire/coffin = loc
		return coffin.return_temperature()
	if(isspacepod(loc))
		var/obj/spacepod/S = loc
		return S.return_temperature()
	if(istype(loc, /obj/structure/transit_tube_pod))
		return environment.temperature
	if(istype(get_turf(src), /turf/space))
		var/turf/heat_turf = get_turf(src)
		return heat_turf.temperature
	if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		var/obj/machinery/atmospherics/unary/cryo_cell/C = loc
		if(C.air_contents.total_moles() < 10)
			return environment.temperature
		else
			return C.air_contents.temperature
	if(environment)
		return environment.temperature
	return T0C

/mob/living/proc/get_standard_pixel_x_offset(lying = 0)
	return initial(pixel_x)

/mob/living/proc/get_standard_pixel_y_offset(lying = 0)
	return initial(pixel_y)

/mob/living/proc/spawn_dust()
	new /obj/effect/decal/cleanable/ash(loc)

//used in datum/reagents/reaction() proc
/mob/living/proc/get_permeability_protection()
	return 0

/mob/living/proc/attempt_harvest(obj/item/I, mob/user)
	if(user.a_intent == INTENT_HARM && stat == DEAD && (butcher_results || issmall(src))) //can we butcher it?
		var/sharpness = is_sharp(I)
		if(sharpness)
			to_chat(user, "<span class='notice'>You begin to butcher [src]...</span>")
			playsound(loc, 'sound/weapons/slice.ogg', 50, 1, -1)
			if(do_after(user, 8 SECONDS / sharpness, src, NONE) && Adjacent(I))
				harvest(user)
			return 1

/mob/living/proc/harvest(mob/living/user)
	if(QDELETED(src))
		return
	if(butcher_results)
		for(var/path in butcher_results)
			for(var/i = 1, i <= butcher_results[path], i++)
				new path(loc)
			butcher_results.Remove(path) //In case you want to have things like simple_animals drop their butcher results on gib, so it won't double up below.
		visible_message("<span class='notice'>[user] butchers [src].</span>")
		gib()


/mob/living/proc/can_use_guns(var/obj/item/gun/G)
	if(G.trigger_guard != TRIGGER_GUARD_ALLOW_ALL && !IsAdvancedToolUser() && !issmall(src))
		to_chat(src, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 0
	return 1


/mob/living/start_pulling(atom/movable/AM, force = pull_force, show_message = FALSE)
	if(incapacitated())
		return FALSE

	. = ..()

	if(pullin)
		pullin.update_icon(UPDATE_ICON_STATE)


/mob/living/proc/check_pull()
	if(pulling && !(pulling in orange(1)))
		stop_pulling()

/mob/living/proc/update_z(new_z) // 1+ to register, null to unregister
	if(registered_z != new_z)
		if(registered_z)
			SSmobs.clients_by_zlevel[registered_z] -= src
		if(client)
			if(new_z)
				SSmobs.clients_by_zlevel[new_z] += src
				for (var/I in length(SSidlenpcpool.idle_mobs_by_zlevel[new_z]) to 1 step -1) //Backwards loop because we're removing (guarantees optimal rather than worst-case performance), it's fine to use .len here but doesn't compile on 511
					var/mob/living/simple_animal/SA = SSidlenpcpool.idle_mobs_by_zlevel[new_z][I]
					if (SA)
						SA.toggle_ai(AI_ON) // Guarantees responsiveness for when appearing right next to mobs
					else
						SSidlenpcpool.idle_mobs_by_zlevel[new_z] -= SA
			registered_z = new_z
		else
			registered_z = null

/mob/living/onTransitZ(old_z,new_z)
	..()
	update_z(new_z)

/mob/living/proc/owns_soul()
	if(mind)
		return mind.soulOwner == mind
	return 1

/mob/living/proc/return_soul()
	if(mind)
		if(mind.soulOwner.devilinfo)//Not sure how this could happen, but whatever.
			mind.soulOwner.devilinfo.remove_soul(mind)
		mind.soulOwner = mind
		mind.damnation_type = 0

/mob/living/proc/has_bane(banetype)
	if(mind)
		if(mind.devilinfo)
			return mind.devilinfo.bane == banetype
	return 0

/mob/living/proc/check_weakness(obj/item/weapon, mob/living/attacker)
	if(mind && mind.devilinfo)
		return check_devil_bane_multiplier(weapon, attacker)
	return 1

/mob/living/proc/check_acedia()
	if(src.mind && src.mind.objectives)
		for(var/datum/objective/sintouched/acedia/A in src.mind.objectives)
			return 1
	return 0

/mob/living/proc/fakefireextinguish()
	return

/mob/living/proc/fakefire()
	return

/mob/living/extinguish_light(force = FALSE)
	for(var/atom/A in src)
		if(A.light_range > 0)
			A.extinguish_light(force)

/mob/living/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("stat")
			if((stat == DEAD) && (var_value < DEAD))//Bringing the dead back to life
				GLOB.dead_mob_list -= src
				GLOB.alive_mob_list += src
			if((stat < DEAD) && (var_value == DEAD))//Kill he
				GLOB.alive_mob_list -= src
				GLOB.dead_mob_list += src
	. = ..()
	switch(var_name)
		if("maxHealth")
			updatehealth()
		if("resize")
			update_transform()
		if("lighting_alpha")
			sync_lighting_plane_alpha()


/mob/living/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, dodgeable)
	stop_pulling()
	return ..()


/mob/living/hit_by_thrown_carbon(mob/living/carbon/human/C, datum/thrownthing/throwingdatum, damage, mob_hurt, self_hurt)
	if(C == src || (movement_type & MOVETYPES_NOT_TOUCHING_GROUND) || !density)
		return
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)
	if(mob_hurt)
		return
	if(!self_hurt)
		take_organ_damage(damage)
	C.take_organ_damage(damage)
	C.Weaken(3 SECONDS)
	C.visible_message(span_danger("[C.name] вреза[pluralize_ru(src.gender,"ет","ют")]ся в [name], сбивая друг друга с ног!"),
					span_userdanger("Вы жестко врезаетесь в [name]!"))


/mob/living/proc/get_visible_species()	// Used only in /mob/living/carbon/human and /mob/living/simple_animal/hostile/morph
	return "Unknown"


/**
 * Can this mob see in the dark
 *
 * Cursed version of checking lighting_cutoffs, just making orientation on nightvision see_in_dark analog
 *
**/
/mob/proc/has_nightvision()
	return nightvision >= 4

/mob/living/run_examinate(atom/target)
	var/datum/status_effect/staring/user_staring_effect = has_status_effect(STATUS_EFFECT_STARING)

	if(user_staring_effect || hindered_inspection(target))
		return

	if(isturf(target) && !(sight & SEE_TURFS) && !(target in view(client ? client.view : world.view, src)))
		// shift-click catcher may issue examinate() calls for out-of-sight turfs
		return

	var/turf/examine_turf = get_turf(target)

	if(examine_turf && !(examine_turf.luminosity || examine_turf.dynamic_lumcount) && \
		get_dist(src, examine_turf) > 1 && \
		!has_nightvision()) // If you aren't blind, it's in darkness (that you can't see) and farther then next to you
		return

	var/examine_time = target.get_examine_time()
	if(examine_time && target != src)
		var/visible_gender = target.get_visible_gender()
		var/visible_species = "Unknown"

		// If we did not see the target with our own eyes when starting the examine, then there is no need to check whether it is close.
		var/near_target = examine_distance_check(target)

		if(isliving(target))
			var/mob/living/target_living = target
			visible_species = target_living.get_visible_species()

			if(ishuman(target))	// Yep. Only humans affected by catched looks.
				var/datum/status_effect/staring/target_staring_effect = target_living.has_status_effect(STATUS_EFFECT_STARING)
				if(target_staring_effect)
					target_staring_effect.catch_look(src)

		user_staring_effect = apply_status_effect(STATUS_EFFECT_STARING, examine_time, target, visible_gender, visible_species)
		if(do_after(src, examine_time, src, ALL))
			if(hindered_inspection(target) || (near_target && !examine_distance_check(target)))
				return
			..()
	else
		..()


/mob/living/proc/examine_distance_check(atom/target)
	if(target in view(client.maxview(), client.eye))
		return TRUE


/mob/living/proc/hindered_inspection(atom/target)
	if(QDELETED(src) || QDELETED(target))
		return TRUE
	face_atom(target)
	if(!has_vision(information_only = TRUE))
		to_chat(src, span_notice("Здесь что-то есть, но вы не видите — что именно."))
		return TRUE
	return FALSE

/**
  * Sets the mob's direction lock towards a given atom.
  *
  * Arguments:
  * * a - The atom to face towards.
  * * track - If TRUE, updates our direction relative to the atom when moving.
  */
/mob/living/proc/set_forced_look(atom/A, track = FALSE)
	forced_look = track ? A.UID() : get_cardinal_dir(src, A)
	add_movespeed_modifier(/datum/movespeed_modifier/forced_look)
	to_chat(src, span_userdanger("You are now facing [track ? A : dir2text(forced_look)]. To cancel this, shift-middleclick yourself."))
	throw_alert("direction_lock", /obj/screen/alert/direction_lock)

/**
  * Clears the mob's direction lock if enabled.
  *
  * Arguments:
  * * quiet - Whether to display a chat message.
  */
/mob/living/proc/clear_forced_look(quiet = FALSE)
	if(!forced_look)
		return
	forced_look = null
	remove_movespeed_modifier(/datum/movespeed_modifier/forced_look)
	if(!quiet)
		to_chat(src, span_notice("Cancelled direction lock."))
	clear_alert("direction_lock")

/mob/living/setDir(new_dir)
	var/old_dir = dir
	if(forced_look)
		if(isnum(forced_look))
			dir = forced_look
		else
			var/atom/A = locateUID(forced_look)
			if(istype(A))
				dir = get_cardinal_dir(src, A)
		SEND_SIGNAL(src, COMSIG_ATOM_DIR_CHANGE, old_dir, dir)
		return
	return ..()


///Reports the event of the change in value of the buckled variable.
/mob/living/proc/set_buckled(new_buckled)
	if(new_buckled == buckled)
		return
	SEND_SIGNAL(src, COMSIG_LIVING_SET_BUCKLED, new_buckled)
	. = buckled
	buckled = new_buckled

	update_canmove()

	/*
	if(buckled)
		if(!HAS_TRAIT(buckled, TRAIT_NO_IMMOBILIZE))
			ADD_TRAIT(src, TRAIT_IMMOBILIZED, BUCKLED_TRAIT)
		switch(buckled.buckle_lying)
			if(NO_BUCKLE_LYING) // The buckle doesn't force a lying angle.
				REMOVE_TRAIT(src, TRAIT_FLOORED, BUCKLED_TRAIT)
			if(0) // Forcing to a standing position.
				REMOVE_TRAIT(src, TRAIT_FLOORED, BUCKLED_TRAIT)
				set_body_position(STANDING_UP)
				set_lying_angle(0)
			else // Forcing to a lying position.
				ADD_TRAIT(src, TRAIT_FLOORED, BUCKLED_TRAIT)
				set_body_position(LYING_DOWN)
				set_lying_angle(buckled.buckle_lying)
	else
		remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_FLOORED), BUCKLED_TRAIT)
		if(.) // We unbuckled from something.
			var/atom/movable/old_buckled = .
			if(old_buckled.buckle_lying == 0 && (resting || HAS_TRAIT(src, TRAIT_FLOORED))) // The buckle forced us to stay up (like a chair)
				set_lying_down() // We want to rest or are otherwise floored, so let's drop on the ground.
	*/


/mob/living/proc/update_density()
	if(HAS_TRAIT(src, TRAIT_UNDENSE))
		set_density(FALSE)
	else
		set_density(TRUE)


/// Proc to append behavior to the condition of being handsblocked. Called when the condition starts.
/mob/living/proc/on_handsblocked_start()
	drop_from_hands()
	stop_pulling()
	add_traits(list(TRAIT_UI_BLOCKED, TRAIT_PULL_BLOCKED), TRAIT_HANDS_BLOCKED)


/// Proc to append behavior to the condition of being handsblocked. Called when the condition ends.
/mob/living/proc/on_handsblocked_end()
	remove_traits(list(TRAIT_UI_BLOCKED, TRAIT_PULL_BLOCKED), TRAIT_HANDS_BLOCKED)

