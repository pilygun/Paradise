///Footstep element. Plays footsteps at parents location when it is appropriate.
/datum/element/footstep
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY|ELEMENT_BESPOKE
	id_arg_index = 2
	///A list containing living mobs and the number of steps they have taken since the last time their footsteps were played.
	var/list/steps_for_living = list()
	///volume determines the extra volume of the footstep. This is multiplied by the base volume, should there be one.
	var/volume
	///e_range stands for extra range - aka how far the sound can be heard. This is added to the base value and ignored if there isn't a base value.
	var/e_range
	///footstep_type is a define which determines what kind of sounds should get chosen.
	var/footstep_type
	///This can be a list OR a soundfile OR null. Determines whatever sound gets played.
	var/footstep_sounds
	///Whether or not to add variation to the sounds played
	var/sound_vary = FALSE


/datum/element/footstep/Attach(datum/target, footstep_type = FOOTSTEP_MOB_BAREFOOT, volume = 0.5, e_range = -8, sound_vary = FALSE)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	src.volume = volume
	src.e_range = e_range
	src.footstep_type = footstep_type
	src.sound_vary = sound_vary
	switch(footstep_type)
		if(FOOTSTEP_MOB_HUMAN)
			if(!ishuman(target))
				return COMPONENT_INCOMPATIBLE
			RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(play_humanstep))
			steps_for_living[target] = 0
			return
		if(FOOTSTEP_MOB_CLAW)
			footstep_sounds = GLOB.clawfootstep
		if(FOOTSTEP_MOB_BAREFOOT)
			footstep_sounds = GLOB.barefootstep
		if(FOOTSTEP_MOB_HEAVY)
			footstep_sounds = GLOB.heavyfootstep
		if(FOOTSTEP_MOB_SHOE)
			footstep_sounds = GLOB.footstep
		if(FOOTSTEP_MOB_SLIME)
			footstep_sounds = 'sound/effects/footstep/slime1.ogg'
		if(FOOTSTEP_OBJ_MACHINE)
			footstep_sounds = 'sound/effects/bang.ogg'
			RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(play_simplestep_machine)) //Note that this doesn't get called for humans.
			return
		if(FOOTSTEP_OBJ_ROBOT)
			footstep_sounds = 'sound/effects/tank_treads.ogg'
			RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(play_simplestep_machine)) //Note that this doesn't get called for humans.
			return
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(play_simplestep)) //Note that this doesn't get called for humans.
	steps_for_living[target] = 0


/datum/element/footstep/Detach(atom/movable/source)
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	steps_for_living -= source
	return ..()


///Prepares a footstep. Determines if it should get played. Returns the turf it should get played on. Note that it is always a /turf/simulated/floor (eventually /turf/simulated)
/datum/element/footstep/proc/prepare_step(mob/living/source)
	var/turf/turf = get_turf(source)
	if(!turf)
		return

	if(source.buckled || source.throwing || source.movement_type & (VENTCRAWLING|FLYING) || HAS_TRAIT(source, TRAIT_IMMOBILIZED) || CHECK_MOVE_LOOP_FLAGS(source, MOVEMENT_LOOP_OUTSIDE_CONTROL))
		return

	if(source.body_position == LYING_DOWN) //play crawling sound if we're lying
		if(turf.footstep)
			playsound(turf, 'sound/effects/footstep/crawl1.ogg', 15 * volume, falloff_distance = 1, vary = sound_vary)
		return

	if(ishuman(source))
		var/mob/living/carbon/human/human_source = source
		if(!human_source.usable_legs)
			return
		if(human_source.m_intent == MOVE_INTENT_WALK)
			return	// stealth

	steps_for_living[source] += 1
	var/steps = steps_for_living[source]

	if(steps >= 6)
		steps_for_living[source] = 0
		steps = 0

	if(steps % 2)
		return

	if(steps != 0 && !source.has_gravity()) // don't need to step as often when you hop around
		return

	. = list(FOOTSTEP_MOB_SHOE = turf.footstep, FOOTSTEP_MOB_BAREFOOT = turf.barefootstep, FOOTSTEP_MOB_HEAVY = turf.heavyfootstep, FOOTSTEP_MOB_CLAW = turf.clawfootstep)


/datum/element/footstep/proc/play_simplestep(mob/living/source, atom/oldloc, direction, forced, list/old_locs, momentum_change)
	SIGNAL_HANDLER

	if(forced || HAS_TRAIT(source, SILENT_FOOTSTEPS) || !momentum_change)
		return

	var/list/prepared_steps = prepare_step(source)
	if(isnull(prepared_steps))
		return

	if(isfile(footstep_sounds) || istext(footstep_sounds))
		playsound(source.loc, footstep_sounds, 100 * volume, falloff_distance = 1, vary = sound_vary)
		return

	var/turf_footstep = prepared_steps[footstep_type]
	if(isnull(turf_footstep) || !footstep_sounds[turf_footstep])
		return

	playsound(source.loc, pick(footstep_sounds[turf_footstep][1]), footstep_sounds[turf_footstep][2] * volume, TRUE, footstep_sounds[turf_footstep][3] + e_range, falloff_distance = 1, vary = sound_vary)


/datum/element/footstep/proc/play_humanstep(mob/living/carbon/human/source, atom/oldloc, direction, forced, list/old_locs, momentum_change)
	SIGNAL_HANDLER

	if(forced || !momentum_change || HAS_TRAIT(source, SILENT_FOOTSTEPS) || source.dna.species.silent_steps)
		return

	var/list/prepared_steps = prepare_step(source)
	if(isnull(prepared_steps))
		return

	//cache for sanic speed (lists are references anyways)
	var/list/footstep_sounds = GLOB.footstep

	if((source.wear_suit?.body_parts_covered | source.w_uniform?.body_parts_covered | source.shoes?.body_parts_covered) & FEET)
		// we are wearing shoes

		var/obj/item/clothing/shoes/shoes = source.shoes
		if(istype(shoes) && shoes.silence_steps)
			return

		var/shoestep_type = prepared_steps[FOOTSTEP_MOB_SHOE]
		if(!isnull(shoestep_type) && footstep_sounds[shoestep_type]) // shoestep type can be null
			playsound(source.loc, pick(footstep_sounds[shoestep_type][1]),
				footstep_sounds[shoestep_type][2] * volume,
				TRUE,
				footstep_sounds[shoestep_type][3] + e_range, falloff_distance = 1, vary = sound_vary)

	else
		// we are barefoot

		if(source.dna.species.special_step_sounds)
			playsound(source.loc, pick(source.dna.species.special_step_sounds), 50, TRUE, falloff_distance = 1, vary = sound_vary)
		else
			var/barefoot_type = prepared_steps[FOOTSTEP_MOB_BAREFOOT]
			var/bare_footstep_sounds = GLOB.barefootstep
			if(!isnull(barefoot_type) && bare_footstep_sounds[barefoot_type]) // barefoot_type can be null
				playsound(source.loc, pick(bare_footstep_sounds[barefoot_type][1]),
					bare_footstep_sounds[barefoot_type][2] * volume,
					TRUE,
					bare_footstep_sounds[barefoot_type][3] + e_range, falloff_distance = 1, vary = sound_vary)


///Prepares a footstep for machine walking
/datum/element/footstep/proc/play_simplestep_machine(atom/movable/source, atom/oldloc, direction, forced, list/old_locs, momentum_change)
	SIGNAL_HANDLER

	if(forced || HAS_TRAIT(source, SILENT_FOOTSTEPS))
		return

	var/turf/source_loc = get_turf(source)
	if(!istype(source_loc))
		return

	if(CHECK_MOVE_LOOP_FLAGS(source, MOVEMENT_LOOP_OUTSIDE_CONTROL))
		return

	playsound(source_loc, footstep_sounds, 50, falloff_distance = 1, vary = sound_vary)

