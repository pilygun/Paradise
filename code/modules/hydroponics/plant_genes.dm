/datum/plant_gene
	var/name
	/// Used to determine if the trait should be logged when the holder is used
	var/dangerous = FALSE

/datum/plant_gene/proc/get_name() // Used for manipulator display and gene disk name.
	return name

/datum/plant_gene/proc/can_add(obj/item/seeds/S)
	return !istype(S, /obj/item/seeds/sample) // Samples can't accept new genes

/datum/plant_gene/proc/Copy()
	return new type

/datum/plant_gene/proc/apply_vars(obj/item/seeds/S) // currently used for fire resist, can prob. be further refactored
	return


// Core plant genes store 5 main variables: lifespan, endurance, production, yield, potency
/datum/plant_gene/core
	var/value
	var/use_max = FALSE

/datum/plant_gene/core/get_name()
	return "[name] [value]"

/datum/plant_gene/core/proc/apply_stat(obj/item/seeds/S)
	return

/datum/plant_gene/core/New(i = null)
	..()
	if(!isnull(i))
		value = i

/datum/plant_gene/core/Copy()
	var/datum/plant_gene/core/C = ..()
	C.value = value
	return C

/datum/plant_gene/core/can_add(obj/item/seeds/S)
	if(!..())
		return FALSE
	return S.get_gene(type)

/datum/plant_gene/core/proc/get_genemod_variable(obj/machinery/plantgenes/modder)
	if(!modder)
		stack_trace("A plant gene ([get_name()]) tried to get a genemod variable without being in a genemodder.")
		return
	stack_trace("A plant gene ([get_name()]) tried to get a genemod variable, but had no override.")

/datum/plant_gene/core/lifespan
	name = "Lifespan"
	value = 25

/datum/plant_gene/core/lifespan/apply_stat(obj/item/seeds/S)
	S.lifespan = value

/datum/plant_gene/core/lifespan/get_genemod_variable(obj/machinery/plantgenes/modder)
	if(!modder) // Let the parent handle it
		return ..()
	return modder.max_endurance // Yes, this is intended. It is used for both lifespan and endurance


/datum/plant_gene/core/endurance
	name = "Endurance"
	value = 15

/datum/plant_gene/core/endurance/apply_stat(obj/item/seeds/S)
	S.endurance = value

/datum/plant_gene/core/endurance/get_genemod_variable(obj/machinery/plantgenes/modder)
	if(!modder) // Let the parent handle it
		return ..()
	return modder.max_endurance


/datum/plant_gene/core/production
	name = "Production Speed"
	value = 6
	use_max = TRUE

/datum/plant_gene/core/production/apply_stat(obj/item/seeds/S)
	S.production = value

/datum/plant_gene/core/production/get_genemod_variable(obj/machinery/plantgenes/modder)
	if(!modder) // Let the parent handle it
		return ..()
	return modder.min_production

/datum/plant_gene/core/yield
	name = "Yield"
	value = 3

/datum/plant_gene/core/yield/apply_stat(obj/item/seeds/S)
	S.yield = value

/datum/plant_gene/core/yield/get_genemod_variable(obj/machinery/plantgenes/modder)
	if(!modder) // Let the parent handle it
		return ..()
	return modder.max_yield


/datum/plant_gene/core/potency
	name = "Potency"
	value = 10

/datum/plant_gene/core/potency/apply_stat(obj/item/seeds/S)
	S.potency = value

/datum/plant_gene/core/potency/get_genemod_variable(obj/machinery/plantgenes/modder)
	if(!modder) // Let the parent handle it
		return ..()
	return modder.max_potency


/datum/plant_gene/core/weed_rate
	name = "Weed Growth Rate"
	value = 1
	use_max = TRUE

/datum/plant_gene/core/weed_rate/apply_stat(obj/item/seeds/S)
	S.weed_rate = value

/datum/plant_gene/core/weed_rate/get_genemod_variable(obj/machinery/plantgenes/modder)
	if(!modder) // Let the parent handle it
		return ..()
	return modder.min_weed_rate


/datum/plant_gene/core/weed_chance
	name = "Weed Vulnerability"
	value = 5
	use_max = TRUE

/datum/plant_gene/core/weed_chance/apply_stat(obj/item/seeds/S)
	S.weed_chance = value

/datum/plant_gene/core/weed_chance/get_genemod_variable(obj/machinery/plantgenes/modder)
	if(!modder) // Let the parent handle it
		return ..()
	return modder.min_weed_chance


// Reagent genes store reagent ID and reagent ratio. Amount of reagent in the plant = 1 + (potency * rate)
/datum/plant_gene/reagent
	name = "Nutriment"
	var/reagent_id = "nutriment"
	var/rate = 0.04

/datum/plant_gene/reagent/get_name()
	return "[name] production [rate*100]%"

/datum/plant_gene/reagent/proc/set_reagent(reag_id)
	reagent_id = reag_id
	name = "UNKNOWN"

	var/datum/reagent/R = GLOB.chemical_reagents_list[reag_id]
	if(R && R.id == reagent_id)
		name = R.name

/datum/plant_gene/reagent/New(reag_id = null, reag_rate = 0)
	..()
	if(reag_id && reag_rate)
		set_reagent(reag_id)
		rate = reag_rate

/datum/plant_gene/reagent/Copy()
	var/datum/plant_gene/reagent/G = ..()
	G.name = name
	G.reagent_id = reagent_id
	G.rate = rate
	return G

/datum/plant_gene/reagent/can_add(obj/item/seeds/S)
	if(!..())
		return FALSE
	for(var/datum/plant_gene/reagent/R in S.genes)
		if(R.reagent_id == reagent_id)
			return FALSE
	return TRUE


// Various traits affecting the product. Each must be somehow useful.
/datum/plant_gene/trait
	var/rate = 0.05
	var/examine_line = ""
	var/list/origin_tech = null
	var/trait_id // must be set and equal for any two traits of the same type

/datum/plant_gene/trait/Copy()
	var/datum/plant_gene/trait/G = ..()
	G.rate = rate
	return G

/datum/plant_gene/trait/can_add(obj/item/seeds/S)
	if(!..())
		return FALSE

	for(var/datum/plant_gene/trait/R in S.genes)
		if(trait_id && R.trait_id == trait_id)
			return FALSE
		if(type == R.type)
			return FALSE
	return TRUE

/datum/plant_gene/trait/proc/on_new(obj/item/reagent_containers/food/snacks/grown/G)
	if(!origin_tech) // This ugly code segment adds RnD tech levels to resulting plants.
		return

	if(G.origin_tech)
		var/list/tech = params2list(G.origin_tech)
		for(var/t in origin_tech)
			if(t in tech)
				tech[t] = max(text2num(tech[t]), origin_tech[t])
			else
				tech[t] = origin_tech[t]
		G.origin_tech = list2params(tech)
	else
		G.origin_tech = list2params(origin_tech)

/datum/plant_gene/trait/proc/on_consume(obj/item/reagent_containers/food/snacks/grown/G, mob/living/carbon/target)
	return

/datum/plant_gene/trait/proc/on_squash(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	return

/datum/plant_gene/trait/proc/on_attackby(obj/item/reagent_containers/food/snacks/grown/G, obj/item/I, mob/user)
	return

/datum/plant_gene/trait/proc/on_throw_impact(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	return

/datum/plant_gene/trait/squash
	// Allows the plant to be squashed when thrown or slipped on, leaving a colored mess and trash type item behind.
	// Also splashes everything in target turf with reagents and applies other trait effects (teleporting, etc) to the target by on_squash.
	// For code, see grown.dm
	name = "Liquid Contents"
	examine_line = "<span class='info'>It has a lot of liquid contents inside.</span>"
	origin_tech = list("biotech" = 5)
	dangerous = TRUE

/datum/plant_gene/trait/slip
	// Makes plant slippery, unless it has a grown-type trash. Then the trash gets slippery.
	// Applies other trait effects (teleporting, etc) to the target by on_slip.
	name = "Slippery Skin"
	rate = 0.1
	examine_line = "<span class='info'>It has a very slippery skin.</span>"
	dangerous = TRUE

/datum/plant_gene/trait/slip/on_new(obj/item/reagent_containers/food/snacks/grown/our_plant)
	. = ..()
	if(istype(our_plant) && ispath(our_plant.trash, /obj/item/grown))
		return

	var/stun_len = our_plant.seed.potency * rate * 0.8 SECONDS

	if(!istype(our_plant, /obj/item/grown/bananapeel) && (!our_plant.reagents || !our_plant.reagents.has_reagent("lube")))
		stun_len /= 3

	stun_len = min(stun_len, 14 SECONDS)// No fun allowed

	our_plant.AddComponent(/datum/component/slippery, stun_len, 0, NONE, CALLBACK(src, PROC_REF(handle_slip), our_plant))

/// On slip, sends a signal that our plant was slipped on out.
/datum/plant_gene/trait/slip/proc/handle_slip(obj/item/reagent_containers/food/snacks/grown/our_plant, mob/slipped_target)
	SEND_SIGNAL(our_plant, COMSIG_PLANT_ON_SLIP, slipped_target)

/datum/plant_gene/trait/cell_charge
	// Cell recharging trait. Charges all mob's power cells to (potency*rate)% mark when eaten.
	// Generates sparks on squash.
	// Small (potency*rate*5) chance to shock squish or slip target for (potency*rate*5) damage.
	// Multiplies max charge by (rate*1000) when used in potato power cells.
	name = "Electrical Activity"
	rate = 0.2
	origin_tech = list("powerstorage" = 5)
	dangerous = TRUE

/datum/plant_gene/trait/cell_charge/on_new(obj/item/reagent_containers/food/snacks/grown/our_plant)
	. = ..()

	if(istype(our_plant) && ispath(our_plant.trash, /obj/item/grown))
		return

	RegisterSignal(our_plant, COMSIG_PLANT_ON_SLIP, PROC_REF(on_sliped_carbon))

/datum/plant_gene/trait/cell_charge/proc/on_sliped_carbon(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	SIGNAL_HANDLER
	if(!iscarbon(target))
		return
	var/mob/living/carbon/carbon_target = target
	var/power = G.seed.potency*rate
	if(prob(power))
		add_attack_logs(G, carbon_target, "shocked for [round(power)] for slipping on")
		carbon_target.investigate_log("got shocked for [round(power)] while slipped on [carbon_target](last touched: [carbon_target.fingerprintslast])", INVESTIGATE_BOTANY)
		carbon_target.electrocute_act(round(power), "подскальзывания", flags = SHOCK_NOGLOVES)

/datum/plant_gene/trait/cell_charge/on_squash(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	if(isliving(target))
		var/mob/living/carbon/C = target
		var/power = G.seed.potency*rate
		if(prob(power))
			add_attack_logs(G, C, "shocked for [round(power)], squashing [G]")
			C.investigate_log("got shocked for [round(power)], squashing [G]", INVESTIGATE_BOTANY)
			C.electrocute_act(round(power), "раздавленного плода", flags = SHOCK_NOGLOVES)

/datum/plant_gene/trait/cell_charge/on_consume(obj/item/reagent_containers/food/snacks/grown/G, mob/living/carbon/target)
	if(!G.reagents.total_volume)
		var/batteries_recharged = 0
		for(var/obj/item/stock_parts/cell/C in target.GetAllContents())
			var/newcharge = min(G.seed.potency*0.01*C.maxcharge, C.maxcharge)
			if(C.charge < newcharge)
				C.charge = newcharge
				if(isobj(C.loc))
					var/obj/O = C.loc
					O.update_icon() //update power meters and such
				C.update_icon()
				batteries_recharged = 1
		if(batteries_recharged)
			to_chat(target, "<span class='notice'>Your batteries are recharged!</span>")



/datum/plant_gene/trait/glow
	// Makes plant glow. Makes plant in tray glow too.
	// Adds (20+potency)*rate light range and potency*rate light_power to products.
	name = "Bioluminescence"
	rate = 0.02
	examine_line = "<span class='info'>It emits a soft glow.</span>"
	trait_id = "glow"
	var/glow_color = "#C3E381"

/datum/plant_gene/trait/glow/proc/glow_range(obj/item/seeds/S)
	return (20+S.potency)*rate

/datum/plant_gene/trait/glow/proc/glow_power(obj/item/seeds/S)
	return max(S.potency*rate, 0.1)

/datum/plant_gene/trait/glow/on_new(obj/item/reagent_containers/food/snacks/grown/G)
	..()
	G.set_light_range_power_color(glow_range(G.seed), glow_power(G.seed), glow_color)
	G.set_light_on(TRUE)

/datum/plant_gene/trait/glow/blue
	name = "Blue Bioluminescence"
	glow_color = "#6699FF"

/datum/plant_gene/trait/glow/purple
	name = "Purple Bioluminescence"
	glow_color = "#b434df"

/datum/plant_gene/trait/glow/yellow
	name = "Yellow Bioluminescence"
	glow_color = "#FFFF66"

/datum/plant_gene/trait/glow/shadow
	//makes plant emit slightly purple shadows
	//adds -potency*rate light power to products
	name = "Shadow Emission"
	glow_color = "#AAD84B"

/datum/plant_gene/trait/glow/shadow/glow_power(obj/item/seeds/S)
	return -max(S.potency*rate, 0.1)

/datum/plant_gene/trait/glow/red
	name = "Red Electrical Glow"
	glow_color = LIGHT_COLOR_RED

/datum/plant_gene/trait/glow/berry
	name = "Strong Bioluminescence"
	rate = 0.04
	glow_color = null

/datum/plant_gene/trait/teleport
	// Makes plant teleport people when squashed or slipped on.
	// Teleport radius is calculated as max(round(potency*rate), 1)
	name = "Bluespace Activity"
	rate = 0.1
	origin_tech = list("bluespace" = 5)
	dangerous = TRUE

/datum/plant_gene/trait/teleport/on_squash(obj/item/reagent_containers/food/snacks/grown/G, atom/target, mob/thrower)
	if(isliving(target))
		var/mob/living/living_target = target
		//squash_trait already has "do_after", no need to double it here
		var/teleport_radius = max(round(G.seed.potency / 10), 1)
		var/turf/T = get_turf(living_target)
		new /obj/effect/decal/cleanable/molten_object(T) //Leave a pile of goo behind for dramatic effect...
		add_attack_logs(target, T, "teleport squash [G](max radius: [teleport_radius])")
		do_teleport(target, T, teleport_radius)
		if(thrower == living_target)
			living_target.adjustStaminaLoss(33)
		living_target.investigate_log("teleported from [COORD(T)] to [COORD(living_target)], squashing [G](max radius: [teleport_radius])", INVESTIGATE_BOTANY)

/datum/plant_gene/trait/teleport/on_new(obj/item/reagent_containers/food/snacks/grown/grown_plant)
	. = ..()

	if(istype(grown_plant) && ispath(grown_plant.trash, /obj/item/grown))
		return

	RegisterSignal(grown_plant, COMSIG_PLANT_ON_SLIP, PROC_REF(on_sliped_carbon))


/datum/plant_gene/trait/teleport/proc/on_sliped_carbon(obj/item/reagent_containers/food/snacks/grown/G, mob/living/carbon/C)
	SIGNAL_HANDLER
	var/teleport_radius = max(round(G.seed.potency / 10), 1)
	var/turf/T = get_turf(C)
	if(do_teleport(C, T, teleport_radius))
		add_attack_logs(C, T, "tele-slipped on [G](max radius: [teleport_radius])")
		C.investigate_log("teleported from [COORD(T)] to [COORD(C)], slipping on [G](max radius: [teleport_radius])", INVESTIGATE_BOTANY)
		to_chat(C, "<span class='warning'>You slip through spacetime!</span>")
		if(prob(50))
			do_teleport(G, T, teleport_radius)
		else
			new /obj/effect/decal/cleanable/molten_object(T) //Leave a pile of goo behind for dramatic effect...
			qdel(G)
	else
		to_chat(C, "<span class='warning'>[src] sparks, and burns up!</span>")
		new /obj/effect/decal/cleanable/molten_object(T)
		qdel(G)


/datum/plant_gene/trait/noreact
	// Makes plant reagents not react until squashed.
	name = "Separated Chemicals"

/datum/plant_gene/trait/noreact/on_new(obj/item/reagent_containers/food/snacks/grown/G)
	..()
	G.reagents.set_reacting(FALSE)

/datum/plant_gene/trait/noreact/on_squash(obj/item/reagent_containers/food/snacks/grown/G, atom/target, mob/thrower)
	if(G && G.reagents)
		var/reglist = ""
		for(var/datum/reagent/R in G.reagents.reagent_list)
			reglist += "[R.name] [R.volume], "
		if(thrower)
			thrower.investigate_log("thrown [G] and started reaction on squash. [reglist]", INVESTIGATE_BOTANY)
		else
			target.investigate_log("squashed [G] starting a reaction. [reglist]", INVESTIGATE_BOTANY)
		G.reagents.set_reacting(TRUE)
		G.reagents.handle_reactions()


/datum/plant_gene/trait/maxchem
	// 2x to max reagents volume.
	name = "Densified Chemicals"
	rate = 2

/datum/plant_gene/trait/maxchem/on_new(obj/item/reagent_containers/food/snacks/grown/G)
	..()
	G.reagents.maximum_volume *= rate

/datum/plant_gene/trait/repeated_harvest
	name = "Perennial Growth"

/datum/plant_gene/trait/repeated_harvest/can_add(obj/item/seeds/S)
	if(!..())
		return FALSE
	if(istype(S, /obj/item/seeds/replicapod))
		return FALSE
	return TRUE

/datum/plant_gene/trait/battery
	name = "Capacitive Cell Production"

/datum/plant_gene/trait/battery/on_attackby(obj/item/reagent_containers/food/snacks/grown/G, obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = I
		if(C.use(5))
			to_chat(user, "<span class='notice'>You add some cable to [G] and slide it inside the battery encasing.</span>")
			var/obj/item/stock_parts/cell/potato/pocell = new /obj/item/stock_parts/cell/potato(user.loc)
			pocell.icon_state = G.icon_state
			pocell.maxcharge = G.seed.potency * 4

			// The secret of potato supercells!
			var/datum/plant_gene/trait/cell_charge/CG = G.seed.get_gene(/datum/plant_gene/trait/cell_charge)
			if(CG) // 10x charge for deafult cell charge gene - 20 000 with 100 potency.
				pocell.maxcharge *= CG.rate*1000
			pocell.charge = pocell.maxcharge
			pocell.name = "[G] battery"
			pocell.desc = "A rechargable plant based power cell. This one has a power rating of [pocell.maxcharge], and you should not swallow it."

			if(G.reagents.has_reagent("plasma", 2))
				pocell.rigged = 1

			qdel(G)
		else
			to_chat(user, "<span class='warning'>You need five lengths of cable to make a [G] battery!</span>")


/datum/plant_gene/trait/stinging
	name = "Hypodermic Prickles"
	dangerous = TRUE

/datum/plant_gene/trait/stinging/on_throw_impact(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	if(isliving(target) && G.reagents && G.reagents.total_volume)
		var/mob/living/L = target
		// It would be nice to inject the body part the original thrower aimed at,
		// but we don't have this kind of information here. So pick something at random.
		var/target_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_CHEST, BODY_ZONE_CHEST, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_HEAD)
		if(L.reagents && L.can_inject(null, FALSE, target_zone))
			var/injecting_amount = max(1, G.seed.potency*0.2) // Minimum of 1, max of 20
			var/fraction = min(injecting_amount/G.reagents.total_volume, 1)
			G.reagents.reaction(L, REAGENT_INGEST, fraction)
			G.reagents.trans_to(L, injecting_amount)
			to_chat(target, "<span class='danger'>You are pricked by [G]!</span>")
			var/reglist = ""
			for(var/datum/reagent/R in G.reagents.reagent_list)
				reglist += "[R.name] [R.volume], "
			target.investigate_log("got throw-pricked with [G]. [reglist]")

/datum/plant_gene/trait/smoke
	name = "Gaseous Decomposition"
	dangerous = TRUE

/datum/plant_gene/trait/smoke/on_squash(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	var/datum/effect_system/smoke_spread/chem/S = new
	var/splat_location = get_turf(target)
	var/smoke_amount = round(sqrt(G.seed.potency * 0.1), 1)
	S.set_up(G.reagents, splat_location)
	var/reglist = ""
	for(var/datum/reagent/R in G.reagents.reagent_list)
		reglist += "[R.name] [R.volume], "
	target.investigate_log("started a chemical smoke, squashing [G]. [reglist]")
	addtimer(CALLBACK(S, TYPE_PROC_REF(/datum/effect_system/smoke_spread/chem, start), smoke_amount), 1 * rand(1, 8), TIMER_STOPPABLE | TIMER_DELETE_ME)

/datum/plant_gene/trait/fire_resistance // Lavaland
	name = "Fire Resistance"

/datum/plant_gene/trait/fire_resistance/apply_vars(obj/item/seeds/S)
	if(!(S.resistance_flags & FIRE_PROOF))
		S.resistance_flags |= FIRE_PROOF

/datum/plant_gene/trait/fire_resistance/on_new(obj/item/reagent_containers/food/snacks/grown/G)
	if(!(G.resistance_flags & FIRE_PROOF))
		G.resistance_flags |= FIRE_PROOF

/datum/plant_gene/trait/plant_type // Parent type
	name = "you shouldn't see this"
	trait_id = "plant_type"

/datum/plant_gene/trait/plant_type/weed_hardy
	name = "Weed Adaptation"

/datum/plant_gene/trait/plant_type/fungal_metabolism
	name = "Fungal Vitality"

/datum/plant_gene/trait/plant_type/alien_properties
	name ="?????"

//laughter gene

/**
 * Plays a laughter sound when someone slips on it.
 * Like the sitcom component but for plants.
 * Just like slippery skin, if we have a trash type this only functions on that. (Banana peels)
 */
/datum/plant_gene/trait/plant_laughter
	name = "Hallucinatory Feedback"
	//description = "Makes sounds when people slip on it."
	/// Sounds that play when this trait triggers
	var/list/sounds = list('sound/items/SitcomLaugh1.ogg', 'sound/items/SitcomLaugh2.ogg', 'sound/items/SitcomLaugh3.ogg')

/datum/plant_gene/trait/plant_laughter/on_new(obj/item/reagent_containers/food/snacks/grown/grown_plant)
	. = ..()

	if(istype(grown_plant) && ispath(grown_plant.trash, /obj/item/grown))
		return

	RegisterSignal(grown_plant, COMSIG_PLANT_ON_SLIP, PROC_REF(laughter))

/*
 * Play a sound effect from our plant.
 *
 * our_plant - the source plant that was slipped on
 * target - the atom that slipped on the plant
 */
/datum/plant_gene/trait/plant_laughter/proc/laughter(obj/item/our_plant, atom/target)
	SIGNAL_HANDLER

	target.audible_message(span_notice("[our_plant] lets out burst of laughter."))
	playsound(our_plant, pick(sounds), 100, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
