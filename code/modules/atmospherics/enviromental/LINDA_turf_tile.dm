

/turf
	var/pressure_difference = 0
	var/pressure_direction = 0
	var/list/atmos_adjacent_turfs = list()
	var/atmos_supeconductivity = 0

/turf/assume_air(datum/gas_mixture/giver) //use this for machines to adjust air
	qdel(giver)
	return 0

/turf/return_air()
	//Create gas mixture to hold data for passing
	var/datum/gas_mixture/GM = new

	GM.oxygen = oxygen
	GM.carbon_dioxide = carbon_dioxide
	GM.nitrogen = nitrogen
	GM.toxins = toxins
	GM.sleeping_agent = sleeping_agent
	GM.agent_b = agent_b

	GM.temperature = temperature

	return GM

/turf/return_analyzable_air()
	return return_air()

/turf/remove_air(amount)
	var/datum/gas_mixture/GM = new

	var/sum = oxygen + carbon_dioxide + nitrogen + toxins + sleeping_agent + agent_b
	if(sum > 0)
		GM.oxygen = (oxygen / sum) * amount
		GM.carbon_dioxide = (carbon_dioxide / sum) * amount
		GM.nitrogen = (nitrogen / sum) * amount
		GM.toxins = (toxins / sum) * amount
		GM.sleeping_agent = (sleeping_agent / sum) * amount
		GM.agent_b = (agent_b / sum) * amount

	GM.temperature = temperature

	return GM


/turf/simulated
	var/datum/excited_group/excited_group
	var/excited = 0
	var/recently_active = 0
	var/datum/gas_mixture/air
	var/archived_cycle = 0
	var/current_cycle = 0
	var/icy = 0
	var/icyoverlay
	var/obj/effect/hotspot/active_hotspot
	var/planetary_atmos = FALSE //air will revert to its initial mix over time

	var/temperature_archived //USED ONLY FOR SOLIDS

	var/atmos_overlay_type = null //current active overlay

/turf/simulated/New()
	..()
	if(!blocks_air)
		air = new

		air.oxygen = oxygen
		air.carbon_dioxide = carbon_dioxide
		air.nitrogen = nitrogen
		air.toxins = toxins
		air.sleeping_agent = sleeping_agent
		air.agent_b = agent_b

		air.temperature = temperature

/turf/simulated/Destroy()
	QDEL_NULL(active_hotspot)
	QDEL_NULL(wet_overlay)
	return ..()

/turf/simulated/assume_air(datum/gas_mixture/giver)
	if(!giver)	return 0
	var/datum/gas_mixture/receiver = air
	if(istype(receiver))

		air.merge(giver)

		update_visuals()

		return 1

	else return ..()

/turf/simulated/proc/copy_air_with_tile(turf/simulated/T)
	if(istype(T) && T.air && air)
		air.copy_from(T.air)

/turf/simulated/proc/copy_air(datum/gas_mixture/copy)
	if(air && copy)
		air.copy_from(copy)

/turf/simulated/return_air()
	if(air)
		return air

	else
		return ..()

/turf/simulated/remove_air(amount)
	if(air)
		var/datum/gas_mixture/removed = null

		removed = air.remove(amount)

		update_visuals()

		return removed

	else
		return ..()

/turf/simulated/proc/mimic_temperature_solid(turf/model, conduction_coefficient)
	var/delta_temperature = (temperature_archived - model.temperature)
	if((heat_capacity > 0) && (abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER))

		var/heat = conduction_coefficient*delta_temperature* \
			(heat_capacity*model.heat_capacity/(heat_capacity+model.heat_capacity))
		temperature -= heat/heat_capacity

/turf/simulated/proc/share_temperature_mutual_solid(turf/simulated/sharer, conduction_coefficient)
	var/delta_temperature = (temperature_archived - sharer.temperature_archived)
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER && heat_capacity && sharer.heat_capacity)

		var/heat = conduction_coefficient*delta_temperature* \
			(heat_capacity*sharer.heat_capacity/(heat_capacity+sharer.heat_capacity))

		temperature -= heat/heat_capacity
		sharer.temperature += heat/sharer.heat_capacity







#define LAST_SHARE_CHECK \
	if(air.last_share > MINIMUM_AIR_TO_SUSPEND){\
		excited_group.reset_cooldowns();\
	}

/turf/proc/process_cell(fire_count)
	SSair.remove_from_active(src)

// proc being called to process all the atmos around it.
/turf/simulated/process_cell(fire_count)
	if(archived_cycle < fire_count) //archive self if not already done
		archive()
	current_cycle = fire_count

	var/remove = 1 //set by non simulated turfs who are sharing with this turf

	//cache for sanic speed
	var/list/adjacent_turfs = atmos_adjacent_turfs
	var/datum/excited_group/our_excited_group = excited_group
	var/adjacent_turfs_length = adjacent_turfs.len

	if(planetary_atmos)
		adjacent_turfs_length++

	for(var/t in adjacent_turfs)
		var/turf/enemy_tile = t

		// This is the start of where we actually simulate everything.
		// We only simulate /turf/simulated with other types of turfs(/space) will help a bit later in else-case
		if(issimulatedturf(enemy_tile))
			var/turf/simulated/enemy_simulated = enemy_tile

			if(fire_count  > enemy_simulated.current_cycle)
				enemy_simulated.archive()

		/******************* GROUP HANDLING START *****************************************************************/

			if(enemy_simulated.excited)
				//cache for sanic speed
				var/datum/excited_group/enemy_excited_group = enemy_simulated.excited_group
				if(our_excited_group)
					if(enemy_excited_group)
						if(our_excited_group != enemy_excited_group)
							//combine groups (this also handles updating the excited_group var of all involved turfs)
							our_excited_group.merge_groups(enemy_excited_group) //combine groups
							our_excited_group = excited_group //update our cache
						share_air(enemy_simulated, fire_count, adjacent_turfs_length) //share
					else
						if((recently_active == 1 && enemy_simulated.recently_active == 1) || !air.compare(enemy_simulated.air))
							our_excited_group.add_turf(enemy_simulated) //add enemy to our group
							share_air(enemy_simulated, fire_count, adjacent_turfs_length) //share
				else
					if(enemy_excited_group)
						if((recently_active == 1 && enemy_simulated.recently_active == 1) || !air.compare(enemy_simulated.air))
							enemy_excited_group.add_turf(src) //join self to enemy group
							our_excited_group = excited_group //update our cache
							share_air(enemy_simulated, fire_count, adjacent_turfs_length) //share
					else
						if((recently_active == 1 && enemy_simulated.recently_active == 1) || !air.compare(enemy_simulated.air))
							var/datum/excited_group/EG = new //generate new group
							EG.add_turf(src)
							EG.add_turf(enemy_simulated)
							our_excited_group = excited_group //update our cache
							share_air(enemy_simulated, fire_count, adjacent_turfs_length) //share
			else
				if(!air.compare(enemy_simulated.air)) //compare if
					SSair.add_to_active(enemy_simulated) //excite enemy
					if(our_excited_group)
						excited_group.add_turf(enemy_simulated) //add enemy to group
					else
						var/datum/excited_group/EG = new //generate new group
						EG.add_turf(src)
						EG.add_turf(enemy_simulated)
						our_excited_group = excited_group //update our cache
					share_air(enemy_simulated, fire_count) //share

		/******************* GROUP HANDLING FINISH *********************************************************************/

		else // Mostly it's just a /turf/space case.
			if(!air.check_turf(enemy_tile, adjacent_turfs_length))
				var/current_moles = air.total_moles()
				if (is_station_level(loc.z) && current_moles > 5 && isspaceturf(enemy_tile)) // handle decompression
					handle_space(enemy_tile)
					var/pressure_direction = get_dir(src, enemy_tile)
					for(var/atom/movable/movable in enemy_tile)
						if(!movable.anchored && !movable.pulledby)
							movable.experience_pressure_difference(current_moles, pressure_direction)
				else
					var/difference = air.mimic(enemy_tile, adjacent_turfs_length)
					if(difference)
						if(difference > 0)
							consider_pressure_difference(enemy_tile, difference)
						else
							enemy_tile.consider_pressure_difference(src, difference)
				remove = 0
				if(our_excited_group)
					LAST_SHARE_CHECK

	if(planetary_atmos) //share our air with the "atmosphere" "above" the turf
		var/datum/gas_mixture/G = new
		G.oxygen = oxygen
		G.carbon_dioxide = carbon_dioxide
		G.nitrogen = nitrogen
		G.toxins = toxins
		G.sleeping_agent = sleeping_agent
		G.agent_b = agent_b
		G.temperature = initial(temperature) // Temperature is modified at runtime; we only care about the turf's initial temperature
		G.archive()
		if(!air.compare(G))
			if(!our_excited_group)
				var/datum/excited_group/EG = new
				EG.add_turf(src)
				our_excited_group = excited_group
			air.share(G, adjacent_turfs_length)
			LAST_SHARE_CHECK
		else
			air = G //Gas difference is so small, so there is no need to process it further.

	air.react()

	update_visuals()

	if(air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		hotspot_expose(air.temperature, CELL_VOLUME)
		for(var/atom/movable/item in src)
			item.temperature_expose(air, air.temperature, CELL_VOLUME)
		temperature_expose(air, air.temperature, CELL_VOLUME)

	if(air.temperature > MINIMUM_TEMPERATURE_START_SUPERCONDUCTION)
		if(consider_superconductivity(starting = 1))
			remove = 0

	if(!our_excited_group && remove == 1)
		SSair.remove_from_active(src)

/turf/simulated/proc/handle_space(turf/space/space_turf)
	var/list/unchecked_turfs = GetAtmosAdjacentTurfs()
	var/list/checked_turfs = list()
	while (unchecked_turfs.len)
		var/turf/current_turf = unchecked_turfs[1]
		var/list/connected_turfs = current_turf.GetAtmosAdjacentTurfs()
		if (checked_turfs.len < 30)
			for (var/turf/simulated/turf in connected_turfs)
				if (!unchecked_turfs.Find(turf) && !checked_turfs.Find(turf))
					unchecked_turfs.Add(connected_turfs)
		checked_turfs.Add(current_turf)
		unchecked_turfs.Remove(current_turf)
	decompression(checked_turfs, space_turf)

/turf/simulated/proc/decompression(list/turfs, turf/space/space_turf, turn = 0)
	for (var/turf/simulated/turf in turfs)
		var/difference = turf.air.total_moles() / 2

		turf.air.oxygen /= 2
		turf.air.carbon_dioxide /= 2
		turf.air.nitrogen /= 2
		turf.air.toxins /= 2
		turf.air.sleeping_agent /= 2
		turf.air.agent_b /= 2
		turf.air.temperature /= 2
		turf.archive()

		if(difference)
			var/decompression_direction = get_dir(turf, get_step_towards(turf, space_turf))
			if (!decompression_direction)
				decompression_direction = get_dir(turf, space_turf)
			turf.consider_pressure_difference(src, difference, decompression_direction)


/turf/simulated/proc/archive()
	if(air) //For open space like floors
		air.archive()
	temperature_archived = temperature
	archived_cycle = SSair.times_fired

/turf/simulated/proc/update_visuals()
	var/new_overlay_type = tile_graphic()
	if(new_overlay_type == atmos_overlay_type)
		return
	var/atmos_overlay = get_atmos_overlay_by_name(atmos_overlay_type)
	if(atmos_overlay)
		vis_contents -= atmos_overlay

	atmos_overlay = get_atmos_overlay_by_name(new_overlay_type)
	if(atmos_overlay)
		vis_contents += atmos_overlay
		atmos_overlay_type = new_overlay_type

/turf/simulated/proc/get_atmos_overlay_by_name(name)
	switch(name)
		if("plasma")
			return GLOB.plmaster["[GET_Z_PLANE_OFFSET(z)]"]
		if("sleeping_agent")
			return GLOB.slmaster["[GET_Z_PLANE_OFFSET(z)]"]
	return null

/turf/simulated/proc/tile_graphic()
	if(!air)
		return
	if(air.toxins > MOLES_PLASMA_VISIBLE)
		return "plasma"

	if(air.sleeping_agent > 1)
		return "sleeping_agent"
	return null

/turf/simulated/proc/share_air(turf/simulated/T, fire_count, adjacent_turfs_length)
	if(T.current_cycle < fire_count)
		var/difference
		difference = air.share(T.air, adjacent_turfs_length)
		if(difference)
			if(difference > 0)
				consider_pressure_difference(T, difference)
			else
				T.consider_pressure_difference(src, difference)
		LAST_SHARE_CHECK

/turf/proc/consider_pressure_difference(var/turf/simulated/T, var/difference, var/direction = get_dir(src, T))
	SSair.high_pressure_delta |= src
	if(difference > pressure_difference)
		pressure_direction = direction
		pressure_difference = difference

/turf/proc/high_pressure_movements()
	var/atom/movable/M
	for(var/thing in src)
		M = thing
		if(!M.anchored && !M.pulledby && M.last_high_pressure_movement_air_cycle < SSair.times_fired)
			M.experience_pressure_difference(pressure_difference, pressure_direction)




/atom/movable/var/pressure_resistance = 10
/atom/movable/var/last_high_pressure_movement_air_cycle = 0

/atom/movable/proc/experience_pressure_difference(pressure_difference, direction, pressure_resistance_prob_delta = 0)
	set waitfor = FALSE
	if(SEND_SIGNAL(src, COMSIG_ATOM_PRE_PRESSURE_PUSH) & COMSIG_ATOM_BLOCKS_PRESSURE)
		return
	var/const/PROBABILITY_OFFSET = 25
	var/const/PROBABILITY_BASE_PRECENT = 75
	var/max_force = sqrt(pressure_difference) * (MOVE_FORCE_DEFAULT) // / 5)
	var/move_prob = 100
	if(pressure_resistance > 0)
		move_prob = (pressure_difference / pressure_resistance * PROBABILITY_BASE_PRECENT) - PROBABILITY_OFFSET
	move_prob += pressure_resistance_prob_delta
	if(move_prob > PROBABILITY_OFFSET && prob(move_prob) && (move_resist != INFINITY) && (!anchored && (max_force >= (move_resist * MOVE_FORCE_PUSH_RATIO))) || (anchored && (max_force >= (move_resist * MOVE_FORCE_FORCEPUSH_RATIO))))
		// Feature disabled until issue with effect stacking will be resolved
		// if (iscarbon(src) && pressure_difference > 50)
		// 	var/mob/living/carbon/carbon = src
		// 	carbon.AdjustWeakened(6 SECONDS)
		step(src, direction)
		last_high_pressure_movement_air_cycle = SSair.times_fired



/datum/excited_group
	var/list/turf_list = list()
	var/breakdown_cooldown = 0

/datum/excited_group/New()
	if(SSair)
		SSair.excited_groups += src

/datum/excited_group/proc/add_turf(var/turf/simulated/T)
	turf_list += T
	T.excited_group = src
	T.recently_active = 1
	reset_cooldowns()

/datum/excited_group/proc/merge_groups(var/datum/excited_group/E)
	if(length(turf_list) > length(E.turf_list))
		SSair.excited_groups -= E
		for(var/turf/simulated/T in E.turf_list)
			T.excited_group = src
			turf_list += T
			reset_cooldowns()
	else
		SSair.excited_groups -= src
		for(var/turf/simulated/T in turf_list)
			T.excited_group = E
			E.turf_list += T
			E.reset_cooldowns()

/datum/excited_group/proc/reset_cooldowns()
	breakdown_cooldown = 0

/datum/excited_group/proc/self_breakdown()
	var/datum/gas_mixture/A = new

	var/list/cached_turf_list = turf_list // cache for super speed

	for(var/turf/simulated/T in cached_turf_list)
		A.oxygen 			+= T.air.oxygen
		A.carbon_dioxide	+= T.air.carbon_dioxide
		A.nitrogen 			+= T.air.nitrogen
		A.toxins 			+= T.air.toxins
		A.sleeping_agent 	+= T.air.sleeping_agent
		A.agent_b 			+= T.air.agent_b

	var/turflen = length(cached_turf_list)

	for(var/turf/simulated/T in cached_turf_list)
		T.air.oxygen			= A.oxygen / turflen
		T.air.carbon_dioxide	= A.carbon_dioxide / turflen
		T.air.nitrogen			= A.nitrogen / turflen
		T.air.toxins			= A.toxins / turflen
		T.air.sleeping_agent	= A.sleeping_agent / turflen
		T.air.agent_b			= A.agent_b / turflen

		T.update_visuals()


/datum/excited_group/proc/dismantle()
	for(var/turf/simulated/T in turf_list)
		T.excited = 0
		T.recently_active = 0
		T.excited_group = null
		SSair.active_turfs -= T
	garbage_collect()

/datum/excited_group/proc/garbage_collect()
	for(var/turf/simulated/T in turf_list)
		T.excited_group = null
	turf_list.Cut()
	SSair.excited_groups -= src

/turf/simulated/proc/super_conduct()
	var/conductivity_directions = 0
	if(blocks_air)
		//Does not participate in air exchange, so will conduct heat across all four borders at this time
		conductivity_directions = NORTH|SOUTH|EAST|WEST

		if(archived_cycle < SSair.times_fired)
			archive()
	else
		//Does particate in air exchange so only consider directions not considered during process_cell()
		for(var/direction in GLOB.cardinal)
			var/turf/T = get_step(src, direction)
			if(!(T in atmos_adjacent_turfs) && !(atmos_supeconductivity & direction))
				conductivity_directions += direction

	if(conductivity_directions > 0)
		//Conduct with tiles around me
		for(var/direction in GLOB.cardinal)
			if(conductivity_directions & direction)
				var/turf/neighbor = get_step(src,direction)

				if(!neighbor?.thermal_conductivity)
					continue

				if(issimulatedturf(neighbor)) //anything under this subtype will share in the exchange
					var/turf/simulated/T = neighbor

					if(T.archived_cycle < SSair.times_fired)
						T.archive()

					if(T.air)
						if(air) //Both tiles are open
							air.temperature_share(T.air, WINDOW_HEAT_TRANSFER_COEFFICIENT)
						else //Solid but neighbor is open
							T.air.temperature_turf_share(src, T.thermal_conductivity)
						SSair.add_to_active(T, 0)
					else
						if(air) //Open but neighbor is solid
							air.temperature_turf_share(T, T.thermal_conductivity)
						else //Both tiles are solid
							share_temperature_mutual_solid(T, T.thermal_conductivity)
						T.temperature_expose(null, T.temperature, null)

					T.consider_superconductivity()

				else
					if(air) //Open
						air.temperature_mimic(neighbor, neighbor.thermal_conductivity)
					else
						mimic_temperature_solid(neighbor, neighbor.thermal_conductivity)

	radiate_to_spess()

	//Conduct with air on my tile if I have it
	if(air)
		air.temperature_turf_share(src, thermal_conductivity)

		//Make sure still hot enough to continue conducting heat
		if(air.temperature < MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION)
			SSair.active_super_conductivity -= src
			return 0

	else
		if(temperature < MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION)
			SSair.active_super_conductivity -= src
			return 0

/turf/simulated/proc/consider_superconductivity(starting)
	if(!thermal_conductivity)
		return 0

	if(air)
		if(air.temperature < (starting?MINIMUM_TEMPERATURE_START_SUPERCONDUCTION:MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION))
			return 0
		if(air.heat_capacity() < M_CELL_WITH_RATIO) // Was: MOLES_CELLSTANDARD*0.1*0.05 Since there are no variables here we can make this a constant.
			return 0
	else
		if(temperature < (starting?MINIMUM_TEMPERATURE_START_SUPERCONDUCTION:MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION))
			return 0

	SSair.active_super_conductivity |= src
	return 1

/turf/simulated/proc/radiate_to_spess() //Radiate excess tile heat to space
	if(temperature > T0C) //Considering 0 degC as te break even point for radiation in and out
		var/delta_temperature = (temperature_archived - TCMB) //hardcoded space temperature
		if((heat_capacity > 0) && (abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER))

			var/heat = thermal_conductivity*delta_temperature* \
				(heat_capacity*HEAT_CAPACITY_VACUUM/(heat_capacity+HEAT_CAPACITY_VACUUM)) //700000 is the heat_capacity from a space turf, hardcoded here
			temperature -= heat/heat_capacity

/// Initializes our adjacent turfs. If you want to avoid this, do not override it, instead set init_air to FALSE
/turf/proc/Initialize_Atmos(time)
	CalculateAdjacentTurfs()

/turf/simulated/Initialize_Atmos(time)
	update_visuals()
	current_cycle = time
	var/list/turf/simulated/passed_turfs = InitCalculateAdjacentTurfs() // will returns only simulated
	for(var/turf/simulated/T as anything in passed_turfs)
		if(!air.compare(T.air))
			excited = 1
			SSair.active_turfs |= src
			// No sense continuing to iterate
			return
		else if(!air.check_turf_total(T))
			excited = 1
			SSair.active_turfs |= src
			// No sense continuing to iterate
			return
