/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/items.dmi'
	amount = 6
	max_amount = 6
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	resistance_flags = FLAMMABLE
	max_integrity = 40
	var/heal_brute = 0
	var/heal_burn = 0
	var/self_delay = 20
	var/unique_handling = FALSE //some things give a special prompt, do we want to bypass some checks in parent?
	var/stop_bleeding = 0
	var/healverb = "bandage"

/obj/item/stack/medical/attack(mob/living/M, mob/user)
	if(!iscarbon(M) && !isanimal(M))
		to_chat(user, "<span class='danger'>[src] cannot be applied to [M]!</span>")
		return 1

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='danger'>You don't have the dexterity to do this!</span>")
		return 1


	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/selected_zone = user.zone_selected
		var/obj/item/organ/external/affecting = H.get_organ(selected_zone)

		if(isgolem(M))
			to_chat(user, "<span class='danger'>This can't be used on golems!</span>")
			return TRUE

		if(H.covered_with_thick_material(selected_zone))
			to_chat(user, "<span class='danger'>There is no thin material to inject into.</span>")
			return TRUE

		if(!affecting)
			to_chat(user, "<span class='danger'>That limb is missing!</span>")
			return TRUE

		if(affecting.is_robotic())
			to_chat(user, "<span class='danger'>This can't be used on a robotic limb.</span>")
			return TRUE

		if(H == user && !unique_handling)
			user.visible_message("<span class='notice'>[user] starts to apply [src] on [user.p_themselves()]...</span>")
			if(!do_after(user, self_delay, H, NONE))
				return TRUE

			var/obj/item/organ/external/affecting_rechecked = H.get_organ(selected_zone)
			if(!affecting_rechecked)
				to_chat(user, "<span class='danger'>That limb is missing!</span>")
				return TRUE

			if(H.covered_with_thick_material(selected_zone))
				to_chat(user, "<span class='danger'>There is no thin material to inject into.</span>")
				return TRUE

			if(affecting_rechecked.is_robotic())
				to_chat(user, "<span class='danger'>This can't be used on a robotic limb.</span>")
				return TRUE

		return

	if(isanimal(M))
		var/mob/living/simple_animal/critter = M
		if(!(critter.healable))
			to_chat(user, "<span class='notice'>You cannot use [src] on [critter]!</span>")
			return
		else if (critter.health == critter.maxHealth)
			to_chat(user, "<span class='notice'>[critter] is at full health.</span>")
			return
		else if(heal_brute < 1)
			to_chat(user, "<span class='notice'>[src] won't help [critter] at all.</span>")
			return

		critter.heal_organ_damage(heal_brute, heal_burn)
		user.visible_message("<span class='green'>[user] applies [src] on [critter].</span>", \
							 "<span class='green'>You apply [src] on [critter].</span>")

		use(1)

	else
		M.heal_organ_damage(heal_brute, heal_burn)
		user.visible_message("<span class='green'>[user] applies [src] on [M].</span>", \
							 "<span class='green'>You apply [src] on [M].</span>")
		use(1)

/obj/item/stack/medical/proc/heal(mob/living/M, mob/user)
	var/mob/living/carbon/human/H = M
	var/obj/item/organ/external/affecting = H.get_organ(user.zone_selected)
	user.visible_message("<span class='green'>[user] [healverb]s the wounds on [H]'s [affecting.name].</span>", \
						 "<span class='green'>You [healverb] the wounds on [H]'s [affecting.name].</span>" )

	var/rembrute = max(0, heal_brute - affecting.brute_dam) // Maxed with 0 since heal_damage let you pass in a negative value
	var/remburn = max(0, heal_burn - affecting.burn_dam) // And deduct it from their health (aka deal damage)
	var/nrembrute = rembrute
	var/nremburn = remburn
	var/should_update_health = FALSE
	var/update_damage_icon = NONE
	var/affecting_brute_was = affecting.brute_dam
	var/affecting_burn_was = affecting.burn_dam
	update_damage_icon |= affecting.heal_damage(heal_brute, heal_burn, updating_health = FALSE)
	if(affecting.brute_dam != affecting_brute_was || affecting.burn_dam != affecting_burn_was)
		should_update_health = TRUE
	var/list/achildlist
	if(LAZYLEN(affecting.children))
		achildlist = affecting.children.Copy()
	var/parenthealed = FALSE
	while(rembrute + remburn > 0) // Don't bother if there's not enough leftover heal
		var/obj/item/organ/external/E
		if(LAZYLEN(achildlist))
			E = pick_n_take(achildlist) // Pick a random children and then remove it from the list
		else if(affecting.parent && !parenthealed) // If there's a parent and no healing attempt was made on it
			E = affecting.parent
			parenthealed = TRUE
		else
			break // If the organ have no child left and no parent / parent healed, break
		if(E.is_robotic() || E.open) // Ignore robotic or open limb
			continue
		else if(!E.brute_dam && !E.burn_dam) // Ignore undamaged limb
			continue
		nrembrute = max(0, rembrute - E.brute_dam) // Deduct the healed damage from the remain
		nremburn = max(0, remburn - E.burn_dam)
		var/brute_was = E.brute_dam
		var/burn_was = E.burn_dam
		update_damage_icon |= E.heal_damage(rembrute, remburn, updating_health = FALSE)
		if(E.brute_dam != brute_was || E.burn_dam != burn_was)
			should_update_health = TRUE
		rembrute = nrembrute
		remburn = nremburn
		user.visible_message("<span class='green'>[user] [healverb]s the wounds on [H]'s [E.name] with the remaining medication.</span>", \
							 "<span class='green'>You [healverb] the wounds on [H]'s [E.name] with the remaining medication.</span>" )
	if(should_update_health)
		H.updatehealth("[name] heal")
	if(update_damage_icon)
		H.UpdateDamageIcon()


//Bruise Packs//

/obj/item/stack/medical/bruise_pack
	name = "roll of gauze"
	singular_name = "gauze length"
	desc = "Some sterile gauze to wrap around bloody stumps."
	icon_state = "gauze"
	item_state = "gauze"
	origin_tech = "biotech=2"
	heal_brute = 10
	stop_bleeding = 1800

/obj/item/stack/medical/bruise_pack/attackby(obj/item/I, mob/user, params)
	if(I.sharp)
		if(get_amount() < 2)
			to_chat(user, "<span class='warning'>You need at least two gauzes to do this!</span>")
			return
		new /obj/item/stack/sheet/cloth(user.drop_location())
		user.visible_message("[user] cuts [src] into pieces of cloth with [I].", \
					 "<span class='notice'>You cut [src] into pieces of cloth with [I].</span>", \
					 "<span class='italics'>You hear cutting.</span>")
		use(2)
	else
		return ..()

/obj/item/stack/medical/bruise_pack/attack(mob/living/M, mob/user)
	if(..())
		return TRUE

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_selected)

		if(affecting.open == ORGAN_CLOSED)
			affecting.germ_level = 0

			if(stop_bleeding)
				if(!H.bleedsuppress) //so you can't stack bleed suppression
					H.suppress_bloodloss(stop_bleeding)

			heal(H, user)

			H.UpdateDamageIcon()
			use(1)
		else
			to_chat(user, "<span class='warning'>[affecting] is cut open, you'll need more than a bandage!</span>")

/obj/item/stack/medical/bruise_pack/improvised
	name = "improvised gauze"
	singular_name = "improvised gauze"
	desc = "A roll of cloth roughly cut from something that can stop bleeding, but does not heal wounds."
	stop_bleeding = 900

/obj/item/stack/medical/bruise_pack/advanced
	name = "advanced trauma kit"
	singular_name = "advanced trauma kit"
	desc = "An advanced trauma kit for severe injuries."
	icon_state = "traumakit"
	item_state = "traumakit"
	belt_icon = "advanced_trauma_kit"
	heal_brute = 25
	stop_bleeding = 0

/obj/item/stack/medical/bruise_pack/advanced/cyborg
	is_cyborg = 1

/obj/item/stack/medical/bruise_pack/advanced/cyborg/attack(mob/living/M, mob/user)
	if(!get_amount())
		to_chat(user, "<span class='danger'>Not enough medical supplies!</span>")
		return 1
	else
		.=..()


//Ointment//


/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burns."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	origin_tech = "biotech=2"
	healverb = "salve"
	heal_burn = 10

/obj/item/stack/medical/ointment/attack(mob/living/M, mob/user)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_selected)

		if(affecting.open == ORGAN_CLOSED)
			affecting.germ_level = 0

			heal(H, user)

			H.UpdateDamageIcon()
			use(1)
		else
			to_chat(user, "<span class='warning'>[affecting] is cut open, you'll need more than some ointment!</span>")


/obj/item/stack/medical/ointment/advanced
	name = "advanced burn kit"
	singular_name = "advanced burn kit"
	desc = "An advanced treatment kit for severe burns."
	icon_state = "burnkit"
	item_state = "burnkit"
	belt_icon = "advanced_burn_kit"
	heal_burn = 25

/obj/item/stack/medical/ointment/advanced/cyborg
	is_cyborg = 1

/obj/item/stack/medical/ointment/advanced/cyborg/attack(mob/living/M, mob/user)
	if(!get_amount())
		to_chat(user, "<span class='danger'>Not enough medical supplies!</span>")
		return 1
	else
		.=..()

//Medical Herbs//
/obj/item/stack/medical/bruise_pack/comfrey
	name = "\improper Comfrey leaf"
	singular_name = "Comfrey leaf"
	desc = "A soft leaf that is rubbed on bruises."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "tea_aspera_leaves"
	color = "#378C61"
	stop_bleeding = 0
	heal_brute = 12
	drop_sound = 'sound/misc/moist_impact.ogg'
	mob_throw_hit_sound = 'sound/misc/moist_impact.ogg'
	hitsound = 'sound/misc/moist_impact.ogg'


/obj/item/stack/medical/ointment/aloe
	name = "\improper Aloe Vera leaf"
	singular_name = "Aloe Vera leaf"
	desc = "A cold leaf that is rubbed on burns."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "aloe"
	color = "#4CC5C7"
	heal_burn = 12

// Splints
/obj/item/stack/medical/splint
	name = "medical splints"
	singular_name = "medical splint"
	icon_state = "splint"
	item_state = "splint"
	unique_handling = TRUE
	self_delay = 10 SECONDS
	var/other_delay = 0
	var/static/list/available_splint_zones = list(
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_PRECISE_R_FOOT,
	)

/obj/item/stack/medical/splint/cyborg
	is_cyborg = TRUE


/obj/item/stack/medical/splint/cyborg/attack(mob/living/M, mob/user)
	if(!get_amount())
		to_chat(user, span_danger("No splints left!"))
		return TRUE
	return ..()


/obj/item/stack/medical/splint/attack(mob/living/carbon/human/target, mob/user)
	. = ..()
	if(. || !ishuman(target))
		return .

	var/obj/item/organ/external/bodypart = target.get_organ(user.zone_selected)
	var/bodypart_name = bodypart.name

	if(!(bodypart.limb_zone in available_splint_zones))
		to_chat(user, span_danger("You can't apply a splint there!"))
		return TRUE

	if(bodypart.is_splinted())
		to_chat(user, span_danger("[target]'s [bodypart_name] is already splinted!"))
		if(tgui_alert(user, "Would you like to remove the splint from [target]'s [bodypart_name]?", "Splint removal", list("Yes", "No")) == "Yes")
			bodypart.remove_splint()
			to_chat(user, span_notice("You remove the splint from [target]'s [bodypart_name]."))
		return TRUE

	if((target == user && self_delay > 0) || (target != user && other_delay > 0))
		user.visible_message(
			span_notice("[user] starts to apply [src] to [target == user ? "[user.p_their()]" : "[target]'s"] [bodypart_name]."),
			span_notice("You start to apply [src] to [target == user ? "your" : "[target]'s"] [bodypart_name]."),
			span_italics("You hear something being wrapped."),
		)

	if(target == user && !do_after(user, self_delay, target, NONE))
		return TRUE
	else if(!do_after(user, other_delay, target, NONE))
		return TRUE

	user.visible_message(
		span_notice("[user] applies [src] to [target == user ? "[user.p_their()]" : "[target]'s"] [bodypart_name]."),
		span_notice("You apply [src] to [target == user ? "your" : "[target]'s"] [bodypart_name]."),
	)

	bodypart.apply_splint()
	use(1)


/obj/item/stack/medical/splint/tribal
	name = "tribal splints"
	icon_state = "tribal_splint"
	other_delay = 5 SECONDS


/obj/item/stack/medical/splint/makeshift
	name = "makeshift splints"
	desc = "Makeshift splint for fixing bones. Better than nothing and more based than others."
	icon_state = "makeshift_splint"
	other_delay = 3 SECONDS
	self_delay = 15 SECONDS

