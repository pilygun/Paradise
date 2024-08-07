///////////////////////////////////////////////////////////////////////////////////
/datum/chemical_reaction
	var/name = null
	var/id = null
	var/result = null
	var/list/required_reagents = list()
	var/list/required_catalysts = list()
	/// Count of required catalysts. -1 if required all catalysts
	var/count_of_catalysts = -1
	var/list/required_blood_group  = null //requested blood groups, for example, "A+"
	var/list/required_blood_species = null //requested blood's species name, for example, "Vox"

	// Both of these variables are mostly going to be used with slime cores - but if you want to, you can use them for other things
	var/atom/required_container = null // the container required for the reaction to happen
	var/required_other = 0 // an integer required for the reaction to happen

	var/result_amount = 0
	var/list/secondary_results = list()		//additional reagents produced by the reaction
	var/min_temp = 0		//Minimum temperature required for the reaction to occur (heat to/above this). min_temp = 0 means no requirement
	var/max_temp = 9999		//Maximum temperature allowed for the reaction to occur (cool to/below this).
	var/mix_message = "The solution begins to bubble."
	var/mix_sound = 'sound/effects/bubbles.ogg'

/datum/chemical_reaction/proc/on_reaction(datum/reagents/holder, created_volume)
	return

/datum/chemical_reaction/proc/make_vaporation(list/reagents, datum/reagents/holder, amount, radius)
	if(!holder || !holder.my_atom)
		return
	var/turf/T = get_turf(holder.my_atom)
	if(!T)
		return
	
	var/color = mix_color_from_reagents(holder.reagent_list)

	T.visible_message(span_warning("The solution generates a strong vapor!"))
	new /obj/effect/particle_effect/chem_smoke/small(T, color)
	playsound(T, 'sound/effects/smoke.ogg', 50, TRUE, -3)

	for(var/mob/living/carbon/carbon in view(radius, T))
		if(!carbon.can_breathe_gas())
			continue
		carbon.emote("gasp")
		if(amount >= 60)
			carbon.AdjustLoseBreath(2 SECONDS)
		for(var/local_reagent in reagents)
			carbon.reagents.add_reagent(local_reagent, REAGENT_EVAPORATION(amount))

/datum/chemical_reaction/proc/chemical_mob_spawn(datum/reagents/holder, amount_to_spawn, reaction_name, mob_class = HOSTILE_SPAWN, mob_faction = "chemicalsummon", random = TRUE, gold_core_spawn = FALSE)
	if(holder && holder.my_atom)
		var/atom/A = holder.my_atom
		var/turf/T = get_turf(A)
		var/message = "A [reaction_name] reaction has occurred in [ADMIN_VERBOSEJMP(T)]"
		message += " ([ADMIN_VV(A,"VV")])"

		var/mob/M = get(A, /mob)
		if(M)
			message += " - Carried By: [ADMIN_LOOKUPFLW(M)]"
		else
			message += " - Last Fingerprint: [(A.fingerprintslast ? A.fingerprintslast : "N/A")]"

		message_admins(message)
		add_game_logs("[reaction_name] chemical mob spawn reaction occuring at [AREACOORD(T)] carried by [key_name_log(M)] with last fingerprint [A.fingerprintslast? A.fingerprintslast : "N/A"]", M)

		playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, TRUE)

		for(var/mob/living/carbon/C in viewers(get_turf(holder.my_atom), null))
			C.flash_eyes()

		for(var/i in 1 to amount_to_spawn)
			var/mob/living/simple_animal/S
			if(random)
				S = create_random_mob(get_turf(holder.my_atom), mob_class)
			else
				S = new mob_class(get_turf(holder.my_atom))//Spawn our specific mob_class
			if(gold_core_spawn) //For tracking xenobiology mobs
				S.xenobiology_spawned = TRUE
			S.faction |= mob_faction
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(S, pick(NORTH, SOUTH, EAST, WEST))

/proc/goonchem_vortex(turf/T, setting_type, volume)
	if(setting_type)
		new /obj/effect/temp_visual/implosion(T)
		playsound(T, 'sound/effects/whoosh.ogg', 25, 1) //credit to Robinhood76 of Freesound.org for this.
	else
		new /obj/effect/temp_visual/shockwave(T)
		playsound(T, 'sound/effects/bang.ogg', 25, 1)
	for(var/atom/movable/X in view(2 + setting_type  + (volume > 30 ? 1 : 0), T))
		if(iseffect(X))
			continue  //stop pulling smoke and hotspots please
		if(X && !X.anchored && X.move_resist <= MOVE_FORCE_DEFAULT)
			if(setting_type)
				X.throw_at(T, 4 + round(volume / 10), 10 + round(volume / 10))
			else
				var/throwdir
				if(get_turf(X) == T)
					throwdir = pick(GLOB.alldirs)
				else
					throwdir = get_dir(T, X)
				X.throw_at(get_edge_target_turf(T, throwdir), 4 + round(volume / 10), 10 + round(volume / 10))

/proc/goonchem_vortex_weak(turf/T, setting_type, volume)
	if(setting_type)
		new /obj/effect/temp_visual/implosion(T)
		playsound(T, 'sound/effects/whoosh.ogg', 25, 1) //credit to Robinhood76 of Freesound.org for this.
	else
		new /obj/effect/temp_visual/shockwave(T)
		playsound(T, 'sound/effects/bang.ogg', 25, 1)
	for(var/atom/movable/X in view(2 + setting_type  + (volume > 30 ? 1 : 0), T))
		if(iseffect(X))
			continue  //stop pulling smoke and hotspots please
		if(X && !X.anchored && X.move_resist <= MOVE_FORCE_DEFAULT)
			if(setting_type)
				X.throw_at(T, 1 + round(volume / 20), 1 + round(volume / 10))
			else
				X.throw_at(get_edge_target_turf(T, get_dir(T, X)), 1 + round(volume / 20), 1 + round(volume / 10))
