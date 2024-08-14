/obj/item/organ/internal/liver/kidan
	species_type = /datum/species/kidan
	name = "kidan liver"
	icon = 'icons/obj/species_organs/kidan.dmi'
	alcohol_intensity = 0.5


#define KIDAN_LANTERN_HUNGERCOST 0.5
#define KIDAN_LANTERN_MINHUNGER 150
#define KIDAN_LANTERN_LIGHT 5

/obj/item/organ/internal/lantern
	species_type = /datum/species/kidan
	name = "Bioluminescent Lantern"
	desc = "A specialized tissue that reacts with oxygen, nutriment and blood to produce light in Kidan."
	icon = 'icons/obj/species_organs/kidan.dmi'
	icon_state = "kid_lantern"
	origin_tech = "biotech=2"
	w_class = WEIGHT_CLASS_TINY
	parent_organ_zone = BODY_ZONE_PRECISE_GROIN
	slot = INTERNAL_ORGAN_LANTERN
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	var/colour
	var/glowing = 0

/obj/item/organ/internal/lantern/ui_action_click(mob/user, datum/action/action, leftclick)
	if(toggle_biolum())
		if(glowing)
			owner.visible_message(span_notice("[owner] starts to glow!"), span_notice("You enable your bioluminescence."))
		else
			owner.visible_message(span_notice("[owner] fades to dark."), span_notice("You disable your bioluminescence."))

/obj/item/organ/internal/lantern/on_life()
	..()
	if(glowing)//i hate this but i couldnt figure out a better way
		if(owner.nutrition < KIDAN_LANTERN_MINHUNGER)
			toggle_biolum(1)
			owner.balloon_alert(owner, "слишком голодный, чтобы светиться!")
			return

		if(owner.stat)
			toggle_biolum(1)
			owner.visible_message(span_notice("[owner] fades to dark."))
			return

		owner.set_nutrition(max(owner.nutrition - KIDAN_LANTERN_HUNGERCOST, KIDAN_LANTERN_HUNGERCOST))

		var/new_light = calculate_glow(KIDAN_LANTERN_LIGHT)

		if(!colour)																		//this should never happen in theory
			colour = BlendRGB(owner.m_colours["body"], owner.m_colours["head"], 0.65)	//then again im pretty bad at theoretics

		if(new_light != glowing)
			var/obj/item/organ/external/groin/lbody = owner.get_organ(check_zone(parent_organ_zone))
			lbody.set_light_range_power_color(new_light, color = colour)
			glowing = new_light

	return

/obj/item/organ/internal/lantern/on_owner_death()
	if(glowing)
		toggle_biolum(1)

/obj/item/organ/internal/lantern/proc/toggle_biolum(statoverride)
	if(!statoverride && owner.incapacitated())
		owner.balloon_alert(owner, "не в текущем состоянии!")
		return 0

	if(!statoverride && owner.nutrition < KIDAN_LANTERN_MINHUNGER)
		owner.balloon_alert(owner, "слишком голодный, чтобы светиться!")
		return 0

	if(!colour)
		colour = BlendRGB(owner.m_colours["head"], owner.m_colours["body"], 0.65)

	if(!glowing)
		var/light = calculate_glow(KIDAN_LANTERN_LIGHT)
		var/obj/item/organ/external/groin/lbody = owner.get_organ(check_zone(parent_organ_zone))
		lbody.set_light_range_power_color(light, color = colour)
		lbody.set_light_on(TRUE)
		glowing = light
		return 1

	else
		var/obj/item/organ/external/groin/lbody = owner.get_organ(check_zone(parent_organ_zone))
		lbody.set_light_on(FALSE)
		glowing = 0
		return 1

/obj/item/organ/internal/lantern/proc/calculate_glow(light)
	if(!light)
		light = KIDAN_LANTERN_LIGHT //should never happen but just to prevent things from breaking

	var/occlusion = 0 //clothes occluding light

	if(!get_location_accessible(owner, BODY_ZONE_HEAD))
		occlusion++
	if(owner.w_uniform && copytext(owner.w_uniform.item_color,-2) != "_d") //jumpsuit not rolled down
		occlusion++
	if(owner.wear_suit)
		occlusion++

	return light - occlusion

/obj/item/organ/internal/lantern/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		if(!colour)								//if its removed before used save the color
			colour = BlendRGB(H.m_colours["body"], H.m_colours["head"], 0.65)

		if(glowing)
			toggle_biolum(1)

	. = ..()

/obj/item/organ/internal/eyes/kidan
	species_type = /datum/species/kidan
	name = "kidan eyeballs"
	icon = 'icons/obj/species_organs/kidan.dmi'

/obj/item/organ/internal/heart/kidan
	species_type = /datum/species/kidan
	name = "kidan heart"
	icon = 'icons/obj/species_organs/kidan.dmi'

/obj/item/organ/internal/brain/kidan
	species_type = /datum/species/kidan
	icon = 'icons/obj/species_organs/kidan.dmi'
	icon_state = "brain2"
	mmi_icon = 'icons/obj/species_organs/kidan.dmi'
	mmi_icon_state = "mmi_full"
	parent_organ_zone = BODY_ZONE_CHEST

/obj/item/organ/internal/brain/kidan/on_life()
	. = ..()
	var/obj/item/organ/external/organ = owner.get_organ(BODY_ZONE_HEAD)
	if(!istype(organ))
		owner.SetSlowed(40 SECONDS)
		owner.SetConfused(80 SECONDS)
		owner.SetSilence(40 SECONDS)
		owner.SetStuttering(80 SECONDS)
		owner.SetEyeBlind(10 SECONDS)
		owner.SetEyeBlurry(40 SECONDS)

/obj/item/organ/internal/lungs/kidan
	species_type = /datum/species/kidan
	name = "kidan lungs"
	icon = 'icons/obj/species_organs/kidan.dmi'

/obj/item/organ/internal/kidneys/kidan
	species_type = /datum/species/kidan
	name = "kidan kidneys"
	icon = 'icons/obj/species_organs/kidan.dmi'

/obj/item/organ/external/head/kidan
	species_type = /datum/species/kidan
	encased = "head chitin"

/obj/item/organ/external/head/kidan/remove(mob/living/user, special = ORGAN_MANIPULATION_DEFAULT, ignore_children = FALSE)
	if(iskidan(owner))
		owner.adjustBrainLoss(60)

	. = ..()

/obj/item/organ/external/head/kidan/replaced(mob/living/carbon/human/target, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	if(iskidan(target))
		target.adjustBrainLoss(30)

/obj/item/organ/external/chest/kidan
	encased = "chitin armour"
	convertable_children = list(/obj/item/organ/external/groin/kidan)

/obj/item/organ/external/groin/kidan
	encased = "groin chitin"

#undef KIDAN_LANTERN_HUNGERCOST
#undef KIDAN_LANTERN_MINHUNGER
#undef KIDAN_LANTERN_LIGHT
