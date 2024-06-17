//craftable jewelry

/obj/item/clothing/accessory/necklace/gem
	name = "gem necklace"
	desc = "A simple necklace with a slot for gem."
	icon = 'icons/obj/clothing/jewelry.dmi'
	icon_state = "gem_necklace"
	item_state = "gem_necklace"
	slot_flags = ITEM_SLOT_NECK|ITEM_SLOT_ACCESSORY //trust me, I am 100% triplechecked this
	allow_duplicates = FALSE
	var/gem = null
	onmob_sheets = list(
		ITEM_SLOT_ACCESSORY_STRING = 'icons/mob/clothing/jewelry.dmi'
	)
	var/dragon_power = FALSE //user get additional bonuses for using draconic amber
	var/necklace_light = FALSE //some lighting stuff
	light_on = FALSE
	light_system = MOVABLE_LIGHT


/obj/item/clothing/accessory/necklace/gem/examine(mob/user)
	. = ..()
	if(!gem)
		. += "<span class='notice'>It looks like there is no gem inside!</span>"
	if(dragon_power)
		. += "<span class='notice'>The necklace feels warm to touch.</span>"

/obj/item/clothing/accessory/necklace/gem/attackby(obj/item/gem/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/gem) && !I.insertable)
		to_chat(user, span_notice("You have no idea how to insert [I] into necklace."))
		return
	if(istype(I, /obj/item/gem) && I.insertable && !gem)
		I.light_range = 0
		I.light_power = 0
		I.light_color = null
		user.drop_transfer_item_to_loc(I, src)
		//generic gems
		if(istype(I, /obj/item/gem/ruby))
			name = "ruby necklace"
			icon_state = "ruby_necklace"
		if(istype(I, /obj/item/gem/sapphire))
			name = "sapphire necklace"
			icon_state = "sapphire_necklace"
		if(istype(I, /obj/item/gem/emerald))
			name = "emerald necklace"
			icon_state = "emerald_necklace"
		if(istype(I, /obj/item/gem/topaz))
			name = "topaz necklace"
			icon_state = "topaz_necklace"
		//fauna gems
		if(istype(I, /obj/item/gem/rupee))
			name = "ruperium necklace"
			icon_state = "rupee_necklace"
		if(istype(I, /obj/item/gem/magma))
			name = "auric necklace"
			icon_state = "magma_necklace"
			light_range = 3
			light_power = 2
			light_color = "#ff7b00"
		if(istype(I, /obj/item/gem/fdiamond))
			name = "diamond necklace"
			icon_state = "diamond_necklace"
			light_range = 3
			light_power = 2
			light_color = "#62cad5"
		//megafauna gems
		if(istype(I, /obj/item/gem/void))
			name = "null necklace"
			icon_state = "void_necklace"
			light_range = 3
			light_power = 2
			light_color = "#4785a4"
		if(istype(I, /obj/item/gem/bloodstone))
			name = "ichorium necklace"
			icon_state = "red_necklace"
			light_range = 4
			light_power = 2
			light_color = "#800000"
		if(istype(I, /obj/item/gem/purple))
			name = "dilithium necklace"
			icon_state = "purple_necklace"
			light_range = 3
			light_power = 2
			light_color = "#b90586"
			resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
		if(istype(I, /obj/item/gem/phoron))
			name = "baroxuldium necklace"
			icon_state = "phoron_necklace"
			light_range = 3
			light_power = 2
			light_color = "#7d0692"
		if(istype(I, /obj/item/gem/amber))
			name = "draconic necklace"
			icon_state = "amber_necklace"
			light_range = 3
			light_power = 2
			light_color = "#FFBF00"
			dragon_power = TRUE
		gem = I
		to_chat(user, span_notice("You carefully insert [I] into necklace."))
		if(light_range)
			set_light_on(TRUE)
			set_light_range_power_color(light_range, light_power, light_color)


/obj/item/clothing/accessory/necklace/gem/on_attached(obj/item/clothing/under/new_suit, mob/attacher)
	. = ..()
	if(. && dragon_power && isliving(has_suit.loc))
		var/mob/living/wearer = has_suit.loc
		wearer.apply_status_effect(STATUS_EFFECT_DRAGON_STRENGTH)


/obj/item/clothing/accessory/necklace/gem/on_removed(mob/detacher)
	. = ..()
	if(.)
		var/obj/item/clothing/under/old_suit = .
		if(isliving(old_suit.loc))
			var/mob/living/wearer = old_suit.loc
			wearer.remove_status_effect(STATUS_EFFECT_DRAGON_STRENGTH)


/obj/item/clothing/accessory/necklace/gem/attached_equip(mob/living/user)
	if(dragon_power && isliving(user))
		user.apply_status_effect(STATUS_EFFECT_DRAGON_STRENGTH)


/obj/item/clothing/accessory/necklace/gem/attached_unequip(mob/living/user)
	if(dragon_power && isliving(user))
		user.remove_status_effect(STATUS_EFFECT_DRAGON_STRENGTH)


/obj/item/clothing/accessory/necklace/gem/equipped(mob/living/user, slot, initial = FALSE)
	. = ..()
	if(dragon_power && isliving(user) && slot == ITEM_SLOT_NECK)
		user.apply_status_effect(STATUS_EFFECT_DRAGON_STRENGTH)


/obj/item/clothing/accessory/necklace/gem/dropped(mob/living/user, slot, silent = FALSE)
	. = ..()
	if(dragon_power && isliving(user))
		user.remove_status_effect(STATUS_EFFECT_DRAGON_STRENGTH)

//bracers
/obj/item/clothing/gloves/jewelry_bracers
	name = "gem bracers"
	desc = "A simple golden bracers with a slot for gems."
	icon = 'icons/obj/clothing/jewelry.dmi'
	icon_state = "gem_bracers"
	item_state = "gem_bracers"
	onmob_sheets = list(
		ITEM_SLOT_GLOVES_STRING = 'icons/mob/clothing/jewelry.dmi'
	)
	var/gem = null
	transfer_prints = TRUE
	cold_protection = HANDS

/obj/item/clothing/gloves/jewelry_bracers/examine(mob/user)
	. = ..()
	if(!gem)
		. += "<span class='notice'>It looks like there is no gem inside!</span>"

/obj/item/clothing/gloves/jewelry_bracers/attackby(obj/item/gem/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/gem) && !I.simple)
		to_chat(user, span_notice("You have no idea how to insert [I] into bracers."))
		return
	if(istype(I, /obj/item/gem) && I.simple && !gem)
		user.drop_transfer_item_to_loc(I, src)
		if(istype(I, /obj/item/gem/ruby))
			name = "ruby bracers"
			icon_state = "ruby_bracers"
			item_state = "ruby_bracers"
		if(istype(I, /obj/item/gem/sapphire))
			name = "sapphire bracers"
			icon_state = "sapphire_bracers"
			item_state = "sapphire_bracers"
		if(istype(I, /obj/item/gem/emerald))
			name = "emerald bracers"
			icon_state = "emerald_bracers"
			item_state = "emerald_bracers"
		if(istype(I, /obj/item/gem/topaz))
			name = "topaz bracers"
			icon_state = "topaz_bracers"
			item_state = "topaz_bracers"
	gem = I
	to_chat(user, span_notice("You carefully insert [I] into necklace."))
	user.update_inv_gloves()
