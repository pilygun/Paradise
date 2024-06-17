
/obj/item/clothing/head/hardhat
	name = "hard hat"
	desc = "A piece of headgear used in dangerous working conditions to protect the head. Comes with a built-in flashlight."
	icon_state = "hardhat0_yellow"
	item_state = "hardhat0_yellow"
	var/on = FALSE
	light_on = FALSE
	light_power = 1
	light_range = 4
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	item_color = "yellow" //Determines used sprites: hardhat[on]_[color] and hardhat[on]_[color]2 (lying down sprite)
	armor = list("melee" = 15, "bullet" = 5, "laser" = 20, "energy" = 10, "bomb" = 20, "bio" = 10, "rad" = 20, "fire" = 100, "acid" = 50)
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	resistance_flags = FIRE_PROOF
	dog_fashion = /datum/dog_fashion/head/hardhat
	sprite_sheets = list(
		SPECIES_GREY = 'icons/mob/clothing/species/grey/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi'
	)

/obj/item/clothing/head/hardhat/attack_self()
	toggle_helmet_light()


/obj/item/clothing/head/hardhat/proc/toggle_helmet_light()
	on = !on
	if(on)
		turn_on()
	else
		turn_off()
	update_icon(UPDATE_ICON_STATE)


/obj/item/clothing/head/hardhat/update_icon_state()
	icon_state = "hardhat[on]_[item_color]"
	item_state = "hardhat[on]_[item_color]"
	update_equipped_item(update_speedmods = FALSE)


/obj/item/clothing/head/hardhat/proc/turn_on()
	set_light_on(TRUE)

/obj/item/clothing/head/hardhat/proc/turn_off()
	set_light_on(FALSE)

/obj/item/clothing/head/hardhat/emp_act(severity)
	. = ..()
	extinguish_light()

/obj/item/clothing/head/hardhat/extinguish_light(force = FALSE)
	if(on)
		on = FALSE
		turn_off()
		update_icon()
		visible_message(span_danger("[src]'s light fades and turns off."))

/obj/item/clothing/head/hardhat/orange
	icon_state = "hardhat0_orange"
	item_state = "hardhat0_orange"
	item_color = "orange"
	dog_fashion = null

/obj/item/clothing/head/hardhat/red
	icon_state = "hardhat0_red"
	item_state = "hardhat0_red"
	item_color = "red"
	dog_fashion = null
	name = "firefighter helmet"
	clothing_flags = STOPSPRESSUREDMAGE
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT

/obj/item/clothing/head/hardhat/white
	icon_state = "hardhat0_white"
	item_state = "hardhat0_white"
	item_color = "white"
	clothing_flags = STOPSPRESSUREDMAGE
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	dog_fashion = /datum/dog_fashion/head/hardhat

/obj/item/clothing/head/hardhat/dblue
	icon_state = "hardhat0_dblue"
	item_state = "hardhat0_dblue"
	item_color = "dblue"
	dog_fashion = null

/obj/item/clothing/head/hardhat/atmos
	icon_state = "hardhat0_atmos"
	item_state = "hardhat0_atmos"
	item_color = "atmos"
	name = "atmospheric technician's firefighting helmet"
	desc = "A firefighter's helmet, able to keep the user cool in any situation."
	clothing_flags = STOPSPRESSUREDMAGE
	flags_inv = HIDEMASK|HIDEHEADSETS|HIDEGLASSES|HIDENAME
	flags_cover = HEADCOVERSMOUTH|HEADCOVERSEYES
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	dog_fashion = null
	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/helmet.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/helmet.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi'
	)
