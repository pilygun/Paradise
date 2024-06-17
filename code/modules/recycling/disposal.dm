// Disposal bin
// Holds items for disposal into pipe system
// Draws air from turf, gradually charges internal reservoir
// Once full (~1 atm), uses air resv to flush items into the pipes
// Automatically recharges air (unless off), will flush when ready if pre-set
// Can hold items and human size things, no other draggables
// Toilets are a type of disposal bin for small objects only and work on magic. By magic, I mean torque rotation
#define SEND_PRESSURE (0.05*ONE_ATMOSPHERE)
#define UNSCREWED -1
#define SCREWED 1
#define OFF 0
#define CHARGING 1
#define CHARGED 2

/obj/machinery/disposal
	name = "disposal unit"
	desc = "A pneumatic waste disposal unit."
	icon = 'icons/obj/pipes_and_stuff/not_atmos/disposal.dmi'
	icon_state = "disposal"
	anchored = TRUE
	density = TRUE
	on_blueprints = TRUE
	armor = list("melee" = 25, "bullet" = 10, "laser" = 10, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 30)
	max_integrity = 200
	resistance_flags = FIRE_PROOF
	var/datum/gas_mixture/air_contents	// internal reservoir
	var/mode = CHARGING	// item mode 0=off 1=charging 2=charged
	var/flush = FALSE	// true if flush handle is pulled
	var/obj/structure/disposalpipe/trunk/trunk = null // the attached pipe trunk
	var/flushing = FALSE	// true if flushing in progress
	var/flush_every_ticks = 30 //Every 30 ticks it will look whether it is ready to flush
	var/flush_count = 0 //this var adds 1 once per tick. When it reaches flush_every_ticks it resets and tries to flush.
	var/last_sound = 0
	var/deconstructs_to = PIPE_DISPOSALS_BIN
	var/storage_slots = 50 //The number of storage slots in this container.
	var/max_combined_w_class = 50 //The sum of the w_classes of all the items in this storage item.
	active_power_usage = 600
	idle_power_usage = 100


/obj/machinery/disposal/proc/trunk_check()
	var/obj/structure/disposalpipe/trunk/T = locate() in loc
	if(!T)
		mode = OFF
		flush = FALSE
	else
		mode = initial(mode)
		flush = initial(flush)
		T.nicely_link_to_other_stuff(src)

//When the disposalsoutlet is forcefully moved. Due to meteorshot (not the recall spell)
/obj/machinery/disposal/Moved(atom/OldLoc, Dir)
	. = ..()
	if(!loc)
		return
	eject()
	var/ptype = istype(src, /obj/machinery/disposal/deliveryChute) ? PIPE_DISPOSALS_CHUTE : PIPE_DISPOSALS_BIN //Check what disposaltype it is
	var/turf/T = OldLoc
	if(T.intact)
		var/turf/simulated/floor/F = T
		F.remove_tile(null,TRUE,TRUE)
		T.visible_message("<span class='warning'>The floortile is ripped from the floor!</span>", "<span class='warning'>You hear a loud bang!</span>")
	if(trunk)
		trunk.remove_trunk_links()
	var/obj/structure/disposalconstruct/C = new (loc)
	transfer_fingerprints_to(C)
	C.ptype = ptype
	C.update()
	C.set_anchored(FALSE)
	C.set_density(TRUE)
	if(!QDELING(src))
		qdel(src)


/obj/machinery/disposal/Destroy()
	eject()
	trunk?.remove_trunk_links()
	return ..()

/obj/machinery/disposal/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

/obj/machinery/disposal/Initialize(mapload)
	// this will get a copy of the air turf and take a SEND PRESSURE amount of air from it
	. = ..()
	var/atom/L = loc
	var/datum/gas_mixture/env = new
	env.copy_from(L.return_air())
	var/datum/gas_mixture/removed = env.remove(SEND_PRESSURE + 1)
	air_contents = new
	air_contents.merge(removed)
	trunk_check()
	update()


//This proc returns TRUE if the item can be picked up and FALSE if it can't.
//Set the stop_messages to stop it from printing messages
/obj/machinery/disposal/proc/can_be_inserted(obj/item/W, stop_messages = FALSE)
	if(!istype(W) || (W.item_flags & ABSTRACT)) //Not an item
		return

	if(loc == W)
		return FALSE //Means the item is already in the storage item
	if(contents.len >= storage_slots)
		if(!stop_messages)
			to_chat(usr, "<span class='warning'>[W] won't fit in [src], make some space!</span>")
		return FALSE //Storage item is full

	var/sum_w_class = W.w_class
	for(var/obj/item/I in contents)
		sum_w_class += I.w_class //Adds up the combined w_classes which will be in the storage item if the item is added to it.

	if(sum_w_class > max_combined_w_class)
		if(!stop_messages)
			to_chat(usr, "<span class='notice'>[src] is full, make some space.</span>")
		return FALSE

	if(HAS_TRAIT(W, TRAIT_NODROP)) //SHOULD be handled in unEquip, but better safe than sorry.
		to_chat(usr, "<span class='notice'>\the [W] is stuck to your hand, you can't put it in \the [src]</span>")
		return FALSE

	return TRUE

// attack by item places it in to disposal
/obj/machinery/disposal/attackby(obj/item/I, mob/user, params)
	if(stat & BROKEN || !I || !user)
		return

	if(istype(I, /obj/item/melee/energy/blade))
		to_chat(user, "You can't place that item inside the disposal unit.")
		return

	if(isstorage(I))
		var/obj/item/storage/storage = I
		if((storage.allow_quick_empty || storage.allow_quick_gather) && length(storage.contents))
			add_fingerprint(user)
			storage.hide_from(user)
			for(var/obj/item/item in storage.contents)
				if(!can_be_inserted(item))
					break
				storage.remove_from_storage(item, src)
				item.add_hiddenprint(user)
			if(!length(storage))
				user.visible_message("[user] empties \the [storage] into \the [src].", "You empty \the [storage] into \the [src].")
			else
				user.visible_message("[user] dumped some items from \the [storage] into \the [src].", "You dumped some items \the [storage] into \the [src].")
			storage.update_icon() // For content-sensitive icons
			update()
			return

	var/obj/item/grab/grab = I
	if(istype(grab))	// handle grabbed mob
		if(grab.affecting && !isliving(grab.affecting))
			return

		var/mob/living/target = grab.affecting

		for(var/mob/viewer in (viewers(user) - user))
			viewer.show_message("[user] starts putting [target.name] into the disposal.", 3)

		if(!do_after(user, 2 SECONDS, target, NONE))
			return

		add_fingerprint(user)
		target.forceMove(src)
		for(var/mob/viewer in viewers(src))
			viewer.show_message("<span class='warning'>[target.name] has been placed in the [src] by [user].</span>", 3)

		qdel(grab)
		add_attack_logs(user, target, "Disposal'ed")
		return

	if(!I || !can_be_inserted(I) || !user.drop_transfer_item_to_loc(I, src))
		return

	add_fingerprint(user)
	to_chat(user, "You place \the [I] into the [src].")
	for(var/mob/viewer in (viewers(src) - user))
		viewer.show_message("[user.name] places \the [I] into the [src].", 3)

	update()


/obj/machinery/disposal/screwdriver_act(mob/user, obj/item/I)
	if(mode > OFF) // It's on
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(contents.len > 0)
		to_chat(user, "Eject the items first!")
		return
	if(mode == OFF) // It's off but still not unscrewed
		mode = UNSCREWED // Set it to doubleoff l0l
	else if(mode == UNSCREWED)
		mode = OFF
	to_chat(user, "You [mode ? "unfasten": "fasten"] the screws around the power connection.")
	update()


/obj/machinery/disposal/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(mode != UNSCREWED)
		return .
	if(length(contents))
		to_chat(user, "Eject the items first!")
		return .
	if(!I.tool_use_check(user, 0))
		return .
	WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume))
		return .

	WELDER_FLOOR_SLICE_SUCCESS_MESSAGE
	var/obj/structure/disposalconstruct/C = new(loc)
	C.ptype = deconstructs_to
	C.update()
	C.set_anchored(TRUE)
	C.set_density(TRUE)
	qdel(src)

// mouse drop another mob or self
//
/obj/machinery/disposal/MouseDrop_T(mob/living/target, mob/living/user, params)
	if(!istype(target) || target.buckled || target.has_buckled_mobs() || !in_range(user, src) || !in_range(user, target) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || isAI(user))
		return
	if(isanimal(user) && target != user)
		return //animals cannot put mobs other than themselves into disposal
	if(target != user && target.anchored)
		return
	add_fingerprint(user)
	for(var/mob/viewer in viewers(user))
		if(target == user)
			viewer.show_message("[user] starts climbing into the disposal.", 3)
		else
			viewer.show_message("[user] starts stuffing [target.name] into the disposal.", 3)
	INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/machinery/disposal, put_in), target, user)
	return TRUE


/obj/machinery/disposal/proc/put_in(mob/living/target, mob/living/user) // need this proc to use INVOKE_ASYNC in other proc. You're not recommended to use that one
	var/msg
	var/target_loc = target.loc
	if(!do_after(usr, 2 SECONDS, target))
		return
	if(QDELETED(src) || target_loc != target.loc)
		return
	if(target == user && !user.incapacitated())	// if drop self, then climbed in
											// must be awake, not stunned or whatever
		msg = "[user.name] climbs into [src]."
		to_chat(user, "You climb into [src].")
	else if(target != user && !user.incapacitated() && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		msg = "[user.name] stuffs [target.name] into [src]!"
		to_chat(user, "You stuff [target.name] into [src]!")
		if(!iscarbon(user))
			target.LAssailant = null
		else
			target.LAssailant = user
		add_attack_logs(user, target, "Disposal'ed")
	else
		return
	target.forceMove(src)

	for(var/mob/viewer in (viewers(src) - user))
		viewer.show_message(msg, 3)

	update()


// attempt to move while inside
/obj/machinery/disposal/relaymove(mob/user as mob)
	if(user.stat || src.flushing)
		return
	go_out(user)
	return

// leave the disposal
/obj/machinery/disposal/proc/go_out(mob/user)
	if(user)
		user.forceMove(loc)
	update()

// ai as human but can't flush
/obj/machinery/disposal/attack_ai(mob/user as mob)
	add_hiddenprint(user)
	ui_interact(user)

/obj/machinery/disposal/attack_ghost(mob/user as mob)
	ui_interact(user)


// human interact with machine
/obj/machinery/disposal/attack_hand(mob/user)
	if(..())
		return TRUE

	if(stat & BROKEN)
		return

	if(user && user.loc == src)
		to_chat(usr, "<span class='warning'>You cannot reach the controls from inside.</span>")
		return

	// Clumsy folks can only flush it.
	if(user.IsAdvancedToolUser())
		ui_interact(user)
	else
		flush = !flush
		update()


/obj/machinery/disposal/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "DisposalBin", name, 300, 250, master_ui, state)
		ui.open()


/obj/machinery/disposal/ui_data(mob/user)
	var/list/data = list()

	data["isAI"] = isAI(user)
	data["flushing"] = flush
	data["mode"] = mode
	data["pressure"] = round(clamp(100* air_contents.return_pressure() / (SEND_PRESSURE), 0, 100),1)

	return data

/obj/machinery/disposal/ui_act(action, params)
	if(..())
		return
	if(usr.loc == src)
		to_chat(usr, "<span class='warning'>You cannot reach the controls from inside.</span>")
		return

	if(mode == UNSCREWED && action != "eject") // If the mode is -1, only allow ejection
		to_chat(usr, "<span class='warning'>The disposal units power is disabled.</span>")
		return

	if(stat & BROKEN)
		return

	add_fingerprint(usr)

	if(flushing)
		return

	if(isturf(loc))
		if(action == "pumpOn")
			mode = CHARGING
			update()
		if(action == "pumpOff")
			mode = OFF
			update()

		if(!issilicon(usr))
			if(action == "engageHandle")
				flush = TRUE
				update()
			if(action == "disengageHandle")
				flush = FALSE
				update()

			if(action == "eject")
				eject()
	return TRUE


// eject the contents of the disposal unit
/obj/machinery/disposal/proc/eject()
	for(var/atom/movable/AM in src)
		AM.forceMove(loc)
		AM.pipe_eject(0)
	update()


/obj/machinery/disposal/AltClick(mob/user)
	if(!Adjacent(user) || !ishuman(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return ..()
	user.visible_message(
		"<span class='notice'>[user] tries to eject the contents of [src] manually.</span>",
		"<span class='notice'>You operate the manual ejection lever on [src].</span>"
	)
	if(!do_after(user, 5 SECONDS, src))
		return ..()

	user.visible_message(
		"<span class='notice'>[user] ejects the contents of [src].</span>",
		"<span class='notice'>You eject the contents of [src].</span>",
	)
	eject()


// update the icon & overlays to reflect mode & status
/obj/machinery/disposal/proc/update()
	if(stat & BROKEN)
		mode = OFF
		flush = FALSE

	update_icon()


/obj/machinery/disposal/update_icon_state()
	if(stat & BROKEN)
		icon_state = "disposal-broken"
		return
	icon_state = initial(icon_state)


/obj/machinery/disposal/update_overlays()
	. = ..()
	underlays.Cut()

	// flush handle
	if(flush)
		. += "dispover-handle"

	// only handle is shown if no power
	if((stat & (NOPOWER|BROKEN)) || mode == UNSCREWED)
		return

	// 	check for items in disposal - occupied light
	if(length(contents))
		. += "dispover-full"
		underlays += emissive_appearance(icon, "dispover-full", src)
		return

	// charging and ready light
	switch(mode)
		if(CHARGING)
			. += "dispover-charge"
			underlays += emissive_appearance(icon, "dispover-lightmask", src)
		if(CHARGED)
			. += "dispover-ready"
			underlays += emissive_appearance(icon, "dispover-lightmask", src)


// timed process
// charge the gas reservoir and perform flush if ready
/obj/machinery/disposal/process()
	use_power = NO_POWER_USE
	if(stat & BROKEN)			// nothing can happen if broken
		return

	flush_count++
	if(flush_count >= flush_every_ticks)
		if(length(contents) && mode == CHARGED)
			INVOKE_ASYNC(src, PROC_REF(flush))
		flush_count = 0

	updateDialog()

	if(flush && air_contents.return_pressure() >= SEND_PRESSURE)	// flush can happen even without power
		flush()

	if(stat & NOPOWER)			// won't charge if no power
		return

	use_power = IDLE_POWER_USE

	if(mode != CHARGING)		// if off or ready, no need to charge
		return

	// otherwise charge
	use_power = ACTIVE_POWER_USE

	var/atom/L = loc						// recharging from loc turf

	var/datum/gas_mixture/env = L.return_air()
	var/pressure_delta = (SEND_PRESSURE*1.01) - air_contents.return_pressure()

	if(env.temperature > 0)
		var/transfer_moles = 0.1 * pressure_delta*air_contents.volume/(env.temperature * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		var/datum/gas_mixture/removed = env.remove(transfer_moles)
		air_contents.merge(removed)
		air_update_turf()

	// if full enough, switch to ready mode
	if(air_contents.return_pressure() >= SEND_PRESSURE)
		mode = CHARGED
		update()


// perform a flush
/obj/machinery/disposal/proc/flush()
	flushing = TRUE
	flush_animation()
	sleep(10)
	if(last_sound + DISPOSAL_SOUND_COOLDOWN < world.time)
		playsound(src, 'sound/machines/disposalflush.ogg', 50, 0, 0)
		last_sound = world.time
	sleep(5) // wait for animation to finish
	var/obj/structure/disposalholder/H = new(src)	// virtual holder object which actually
												// travels through the pipes.
	manage_wrapping(H)
	H.init(src)	// copy the contents of disposer to holder
	air_contents = new() // The holder just took our gas; replace it
	H.start(src) // start the holder processing movement
	flushing = FALSE
	// now reset disposal state
	flush = FALSE
	if(mode == CHARGED)	// if was ready,
		mode = CHARGING	// switch to charging
	update()


/obj/machinery/disposal/proc/flush_animation()
	flick("[icon_state]-flush", src)


/obj/machinery/disposal/proc/manage_wrapping(obj/structure/disposalholder/H)
	var/wrap_check = FALSE
	//Hacky test to get drones to mail themselves through disposals.
	for(var/mob/living/silicon/robot/drone/D in src)
		wrap_check = TRUE
	for(var/mob/living/silicon/robot/syndicate/saboteur/R in src)
		wrap_check = TRUE
	for(var/obj/item/smallDelivery/O in src)
		wrap_check = TRUE
	if(wrap_check == TRUE)
		H.tomail = TRUE


// called when area power changes
/obj/machinery/disposal/power_change(forced = FALSE)
	. = ..()
	if(.)
		update()	// do default setting/reset of stat NOPOWER bit


// called when holder is expelled from a disposal
// should usually only occur if the pipe network is modified
/obj/machinery/disposal/proc/expel(obj/structure/disposalholder/H)

	var/turf/target
	if(last_sound + DISPOSAL_SOUND_COOLDOWN < world.time)
		playsound(src, 'sound/machines/hiss.ogg', 50, 0, FALSE)
		last_sound = world.time

	if(H) // Somehow, someone managed to flush a window which broke mid-transit and caused the disposal to go in an infinite loop trying to expel null, hopefully this fixes it
		for(var/atom/movable/AM in H)
			target = get_offset_target_turf(loc, rand(5)-rand(5), rand(5)-rand(5))

			AM.forceMove(loc)
			AM.pipe_eject(0)
			if(!isdrone(AM) && !istype(AM, /mob/living/silicon/robot/syndicate/saboteur)) //Poor drones kept smashing windows and taking system damage being fired out of disposals. ~Z
				addtimer(CALLBACK(AM, TYPE_PROC_REF(/atom/movable, throw_at), target, 5, 1), 0.1 SECONDS, TIMER_DELETE_ME)

		H.vent_gas(loc)
		qdel(H)


/obj/machinery/disposal/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if((isitem(mover) && !isprojectile(mover)) && mover.throwing && mover.pass_flags != PASSEVERYTHING)
		if(prob(75) && can_be_inserted(mover, TRUE))
			mover.forceMove(src)
			visible_message("[mover] lands in [src].")
			update()
		else
			visible_message("[mover] bounces off of [src]'s rim!")
		return FALSE


/obj/machinery/disposal/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		qdel(src)

/obj/machinery/disposal/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, 2)

/obj/machinery/disposal/force_eject_occupant(mob/target)
	target.forceMove(get_turf(src))


/obj/machinery/disposal/deliveryChute
	name = "Delivery chute"
	desc = "A chute for big and small packages alike!"
	density = TRUE
	icon_state = "intake"
	deconstructs_to = PIPE_DISPOSALS_CHUTE
	var/to_waste = TRUE


/obj/machinery/disposal/deliveryChute/New()
	..()
	addtimer(CALLBACK(src, PROC_REF(update_trunk)), 0.5 SECONDS, TIMER_DELETE_ME)


/obj/machinery/disposal/deliveryChute/proc/update_trunk()
	trunk = locate() in loc
	if(trunk)
		trunk.linked = src	// link the pipe trunk to self


/obj/machinery/disposal/deliveryChute/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/destTagger))
		add_fingerprint(user)
		to_waste = !to_waste
		to_chat(user, "<span class='notice'>The chute is now set to [to_waste ? "waste" : "cargo"] disposals.</span>")
		if(last_sound + DISPOSAL_SOUND_COOLDOWN < world.time)
			playsound(src.loc, 'sound/machines/twobeep.ogg', 100, TRUE)
			last_sound = world.time
		return
	. = ..()


/obj/machinery/disposal/deliveryChute/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The chute is set to [to_waste ? "waste" : "cargo"] disposals.</span>"
	. += "<span class='info'>Use a destination tagger to change the disposal destination.</span>"


/obj/machinery/disposal/deliveryChute/interact()
	return

/obj/machinery/disposal/deliveryChute/update()
	return

/obj/machinery/disposal/deliveryChute/Bumped(atom/movable/moving_atom) //Go straight into the chute
	..()
	if(ismecha(moving_atom) || isspacepod(moving_atom)) return

	if(isprojectile(moving_atom) || iseffect(moving_atom))
		return

	switch(dir)
		if(NORTH)
			if(moving_atom.loc.y != src.loc.y+1) return
		if(EAST)
			if(moving_atom.loc.x != src.loc.x+1) return
		if(SOUTH)
			if(moving_atom.loc.y != src.loc.y-1) return
		if(WEST)
			if(moving_atom.loc.x != src.loc.x-1) return

	if(isobj(moving_atom) || isliving(moving_atom))
		moving_atom.loc = src

	if(mode != OFF)
		flush()


/obj/machinery/disposal/deliveryChute/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isprojectile(AM))
		return ..() //chutes won't eat bullets
	if(dir == reverse_direction(throwingdatum.init_dir))
		return
	..()

/obj/machinery/disposal/deliveryChute/flush_animation()
	flick("intake-closing", src)

/obj/machinery/disposal/deliveryChute/manage_wrapping(obj/structure/disposalholder/H)
	var/wrap_check = FALSE
	for(var/obj/structure/bigDelivery/O in src)
		wrap_check = TRUE
		if(O.sortTag == 0)
			O.sortTag = 1
	for(var/obj/item/smallDelivery/O in src)
		wrap_check = TRUE
		if(O.sortTag == 0)
			O.sortTag = 1
	for(var/obj/item/shippingPackage/O in src)
		wrap_check = TRUE
		if(!O.sealed || O.sortTag == 0)		//unsealed or untagged shipping packages will default to disposals
			O.sortTag = 1
	if(wrap_check == TRUE)
		H.tomail = TRUE
	if(wrap_check == FALSE && to_waste)
		H.destinationTag = 1

#undef SEND_PRESSURE
#undef UNSCREWED
#undef OFF
#undef SCREWED
#undef CHARGING
#undef CHARGED

