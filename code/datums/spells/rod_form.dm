/obj/effect/proc_holder/spell/rod_form
	name = "Rod Form"
	desc = "Take on the form of an immovable rod, destroying all in your path."
	clothes_req = TRUE
	human_req = FALSE
	base_cooldown = 60 SECONDS
	cooldown_min = 20 SECONDS
	invocation = "CLANG!"
	invocation_type = "shout"
	action_icon_state = "immrod"
	centcom_cancast = FALSE

	sound = 'sound/effects/whoosh.ogg'
	var/rod_delay = 2


/obj/effect/proc_holder/spell/rod_form/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/rod_form/cast(list/targets,mob/user = usr)
	if(get_turf(user) != user.loc)
		to_chat(user, "<span class='warning'>You cannot summon a rod in the ether, the spell fizzles out!</span>")
		revert_cast()
		return FALSE

	for(var/mob/living/M in targets)
		var/turf/start = get_turf(M)
		var/obj/effect/immovablerod/wizard/W = new(start, get_ranged_target_turf(M, M.dir, (15 + spell_level * 3)), rod_delay)
		W.wizard = M
		W.spell = src
		W.max_distance += spell_level * 3 //You travel farther when you upgrade the spell
		W.start_turf = start
		M.forceMove(W)
		ADD_TRAIT(M, TRAIT_NO_TRANSFORM, UNIQUE_TRAIT_SOURCE(src))
		M.status_flags |= GODMODE


/**
 * Wizard Version of the Immovable Rod
 */
/obj/effect/immovablerod/wizard
	var/max_distance = 13
	var/mob/living/wizard
	var/turf/start_turf
	var/obj/effect/proc_holder/spell/spell
	notify = FALSE


/obj/effect/immovablerod/wizard/Move(atom/newloc, direct = NONE, movetime)
	if(get_dist(start_turf, get_turf(src)) >= max_distance)
		qdel(src)
	..()


/obj/effect/immovablerod/wizard/Destroy()
	if(wizard)
		wizard.status_flags &= ~GODMODE
		REMOVE_TRAIT(wizard, TRAIT_NO_TRANSFORM, UNIQUE_TRAIT_SOURCE(spell))
		wizard.forceMove(get_turf(src))
		wizard = null
	spell = null
	start_turf = null
	return ..()

