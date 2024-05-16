/obj/item/chameleon
	name = "chameleon projector"
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	item_state = "electronic"
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "syndicate=1;magnets=4"
	var/can_use = TRUE
	var/obj/effect/dummy/chameleon/active_dummy = null
	var/saved_item = /obj/item/cigbutt
	var/saved_icon = 'icons/obj/clothing/masks.dmi'
	var/saved_icon_state = "cigbutt"
	var/saved_overlays = null
	var/saved_underlays = null

/obj/item/chameleon/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	disrupt()

/obj/item/chameleon/equipped(mob/user, slot, initial)
	. = ..()
	disrupt()

/obj/item/chameleon/attack_self()
	toggle()

/obj/item/chameleon/afterattack(atom/target, mob/user , proximity)
	if(!proximity)
		return
	if(!check_sprite(target))
		return
	if(target.alpha < 255)
		return
	if(target.invisibility)
		return
	if(!active_dummy)
		if(isitem(target) && !istype(target, /obj/item/disk/nuclear))
			playsound(get_turf(src), 'sound/weapons/flash.ogg', 100, 1, -6)
			to_chat(user, "<span class='notice'>Scanned [target].</span>")
			saved_item = target.type
			saved_icon = target.icon
			saved_icon_state = target.icon_state
			saved_overlays = target.overlays
			saved_underlays = target.underlays

/obj/item/chameleon/proc/check_sprite(atom/target)
	if(target.icon_state in icon_states(target.icon))
		return TRUE
	return FALSE

/obj/item/chameleon/proc/toggle()
	if(!can_use || !saved_item)
		return
	if(active_dummy)
		eject_all()
		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)
		QDEL_NULL(active_dummy)
		to_chat(usr, "<span class='notice'>You deactivate [src].</span>")
		var/obj/effect/overlay/T = new/obj/effect/overlay(get_turf(src))
		T.icon = 'icons/effects/effects.dmi'
		flick("emppulse",T)
		spawn(8)
			qdel(T)
	else
		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)
		var/obj/O = new saved_item(src)
		if(!O) return
		var/obj/effect/dummy/chameleon/C = new/obj/effect/dummy/chameleon(usr.loc)
		C.activate(O, usr, saved_icon, saved_icon_state, saved_overlays, saved_underlays, src)
		qdel(O)
		to_chat(usr, "<span class='notice'>You activate [src].</span>")
		var/obj/effect/overlay/T = new/obj/effect/overlay(get_turf(src))
		T.icon = 'icons/effects/effects.dmi'
		flick("emppulse",T)
		spawn(8)
			qdel(T)

/obj/item/chameleon/proc/disrupt(delete_dummy = 1)
	if(active_dummy)
		do_sparks(5, 0, src)
		eject_all()
		if(delete_dummy)
			qdel(active_dummy)
		active_dummy = null
		can_use = FALSE
		addtimer(VARSET_CALLBACK(src, can_use, TRUE), 5 SECONDS)

/obj/item/chameleon/proc/eject_all()
	for(var/atom/movable/A in active_dummy)
		A.forceMove(active_dummy.loc)

/obj/effect/dummy/chameleon
	name = ""
	desc = ""
	density = FALSE
	anchored = TRUE
	var/can_move = TRUE
	var/obj/item/chameleon/master = null

/obj/effect/dummy/chameleon/proc/activate(obj/O, mob/M, new_icon, new_iconstate, new_overlays, new_underlays, obj/item/chameleon/C)
	name = O.name
	desc = O.desc
	icon = new_icon
	icon_state = new_iconstate
	overlays = new_overlays
	underlays = new_underlays
	dir = O.dir
	M.forceMove(src)
	master = C
	master.active_dummy = src

/obj/effect/dummy/chameleon/attackby()
	for(var/mob/M in src)
		to_chat(M, "<span class='danger'>Your chameleon projector deactivates.</span>")
	master.disrupt()

/obj/effect/dummy/chameleon/attack_hand()
	for(var/mob/M in src)
		to_chat(M, "<span class='danger'>Your chameleon projector deactivates.</span>")
	master.disrupt()

/obj/effect/dummy/chameleon/attack_animal()
	master.disrupt()

/obj/effect/dummy/chameleon/attack_slime()
	master.disrupt()

/obj/effect/dummy/chameleon/attack_alien()
	master.disrupt()

/obj/effect/dummy/chameleon/ex_act(severity) //no longer bomb-proof
	for(var/mob/M in src)
		to_chat(M, "<span class='danger'>Your chameleon projector deactivates.</span>")
		spawn()
			M.ex_act(severity)
	master.disrupt()

/obj/effect/dummy/chameleon/bullet_act()
	for(var/mob/M in src)
		to_chat(M, "<span class='danger'>Your chameleon projector deactivates.</span>")
	..()
	master.disrupt()

/obj/effect/dummy/chameleon/relaymove(mob/user, direction)
	if(!isturf(loc) || isspaceturf(loc) || !direction)
		return // No magical movement!

	if(can_move)
		can_move = FALSE
		switch(user.bodytemperature)
			if(300 to INFINITY)
				addtimer(VARSET_CALLBACK(src, can_move, TRUE), 1 SECONDS)
			if(295 to 300)
				addtimer(VARSET_CALLBACK(src, can_move, TRUE), 1.3 SECONDS)
			if(280 to 295)
				addtimer(VARSET_CALLBACK(src, can_move, TRUE), 1.6 SECONDS)
			if(260 to 280)
				addtimer(VARSET_CALLBACK(src, can_move, TRUE), 2 SECONDS)
			else
				addtimer(VARSET_CALLBACK(src, can_move, TRUE), 2.5 SECONDS)
		step(src, direction)
	return

/obj/effect/dummy/chameleon/Destroy()
	master.disrupt(0)
	return ..()

/obj/item/borg_chameleon
	name = "cyborg chameleon projector"
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL
	var/active = FALSE
	var/activationCost = 300
	var/activationUpkeep = 50
	var/last_disguise = ""
	var/disguise = "landmate"
	var/loaded_name_disguise = "Standard"
	var/mob/living/silicon/robot/syndicate/saboteur/S
	var/list/possible_disguises = list("Last One",
										"Standard" = list("Robot-STD", "droid", "Standard", "Noble-STD"),
										"Medical" = list("Standard-Medi", "Robot-MED", "surgeon", "chiefbot", "droid-medical", "Robot-SRG", "Noble-MED", "Cricket-MEDI"),
										"Engineering" = list("Robot-ENG", "Robot-ENG2", "landmate", "chiefmate", "Standard-Engi", "Noble-ENG", "Cricket-ENGI"),
										"Security" = list("Robot-SEC", "Security", "securityrobot", "bloodhound", "Standard-Secy", "Noble-SEC", "Cricket-SEC"),
										"Service" = list("Robot-LDY", "toiletbot", "Robot-RLX", "maximillion", "Robot-MAN", "Standard-Serv", "Noble-SRV", "Cricket-SERV"),
										"Miner" = list("Robot-MNR", "droid-miner", "Miner", "Standard-Mine", "Noble-DIG", "Cricket-MINE", "lavaland"),
										"Syndicate" = list("syndie_bloodhound", "syndi-medi"))

/obj/item/borg_chameleon/Destroy()
	if(S)
		S.cham_proj = null
	return ..()

/obj/item/borg_chameleon/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	disrupt(user)

/obj/item/borg_chameleon/equipped(mob/user, slot, initial)
	. = ..()
	disrupt(user)

/obj/item/borg_chameleon/attack_self(mob/living/silicon/robot/syndicate/saboteur/user)
	if(user && user.cell && user.cell.charge >  activationCost)
		if(isturf(user.loc))
			toggle(user)
		else
			to_chat(user, "<span class='warning'>You can't use [src] while inside something!</span>")
	else
		to_chat(user, "<span class='warning'>You need at least [activationCost] charge in your cell to use [src]!</span>")

/obj/item/borg_chameleon/proc/toggle(mob/living/silicon/robot/syndicate/saboteur/user)
	if(active)
		playsound(src, 'sound/effects/pop.ogg', 100, 1, -6)
		to_chat(user, "<span class='notice'>You deactivate [src].</span>")
		deactivate(user)
	else
		var/choice
		var/new_disguise = input("Please, select a disguise!", "Robot", null, null) as null|anything in possible_disguises
		var/list/module_disguises
		if(!new_disguise)
			choice = disguise
		else if(new_disguise == "Last One")
			if(!last_disguise)
				choice = disguise
			choice = last_disguise
		else
			var/list/choices = list()
			module_disguises = possible_disguises[new_disguise]
			if(length(module_disguises) > 1)
				for(var/skin in module_disguises)
					var/image/skin_image = image(icon = user.icon, icon_state = skin)
					skin_image.add_overlay("eyes-[skin]")
					choices[skin] = skin_image
			choice = show_radial_menu(user, user, choices, require_near = TRUE)
			last_disguise = choice
			loaded_name_disguise = new_disguise
		if(!choice)
			if(!last_disguise)
				choice = disguise
			else
				choice = last_disguise
		to_chat(user, "<span class='notice'>You activate [src].</span>")
		var/start = user.filters.len
		var/X
		var/Y
		var/rsq
		var/i
		var/f
		for(i in 1 to 7)
			do
				X = 60 * rand() - 30
				Y = 60 * rand() - 30
				rsq = X * X + Y * Y
			while(rsq < 100 || rsq > 900)
			user.filters += filter(type = "wave", x = X, y = Y, size = rand() * 2.5 + 0.5, offset = rand())
		for(i in 1 to 7)
			f = user.filters[start+i]
			animate(f, offset = f:offset, time = 0, loop = 3, flags = ANIMATION_PARALLEL)
			animate(offset = f:offset - 1, time = rand() * 20 + 10)
		if(do_after(user, 5 SECONDS, user) && user.cell.use(activationCost))
			playsound(src, 'sound/effects/bamf.ogg', 100, 1, -6)
			to_chat(user, "<span class='notice'>You are now disguised as a Nanotrasen cyborg.</span>")
			activate(user, choice)
		else
			to_chat(user, "<span class='warning'>The chameleon field fizzles.</span>")
			do_sparks(3, FALSE, user)
			for(i in 1 to min(7, user.filters.len)) // removing filters that are animating does nothing, we gotta stop the animations first
				f = user.filters[start + i]
				animate(f)
		user.filters = null

/obj/item/borg_chameleon/process()
	if(S)
		if(!S.cell || !S.cell.use(activationUpkeep))
			disrupt(S)
	else
		return PROCESS_KILL

/obj/item/borg_chameleon/proc/activate(mob/living/silicon/robot/syndicate/saboteur/user, new_disguise)
	START_PROCESSING(SSobj, src)
	S = user
	user.base_icon = new_disguise
	user.icon_state = new_disguise
	user.module.name_disguise = loaded_name_disguise
	user.cham_proj = src
	user.bubble_icon = "robot"
	var/list/names = splittext(user.icon_state, "-")
	user.custom_panel = trim(names[1])
	active = TRUE
	user.update_icons()

/obj/item/borg_chameleon/proc/deactivate(mob/living/silicon/robot/syndicate/saboteur/user)
	STOP_PROCESSING(SSobj, src)
	S = user
	user.base_icon = initial(user.base_icon)
	user.icon_state = initial(user.icon_state)
	user.bubble_icon = "syndibot"
	user.module.name_disguise = initial(user.module.name_disguise)
	user.custom_panel = initial(user.custom_panel)
	active = FALSE
	user.update_icons()

/obj/item/borg_chameleon/proc/disrupt(mob/living/silicon/robot/syndicate/saboteur/user)
	if(active)
		to_chat(user, "<span class='danger'>Your chameleon field deactivates.</span>")
		deactivate(user)
