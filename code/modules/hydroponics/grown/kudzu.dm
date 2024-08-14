// A very special plant, deserving it's own file.

/obj/item/seeds/kudzu
	name = "pack of kudzu seeds"
	desc = "These seeds grow into a weed that grows incredibly fast."
	icon_state = "seed-kudzu"
	species = "kudzu"
	plantname = "Kudzu"
	product = /obj/item/reagent_containers/food/snacks/grown/kudzupod
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/plant_type/weed_hardy)
	lifespan = 20
	endurance = 10
	yield = 4
	growthstages = 4
	rarity = 30
	var/list/mutations = list()
	reagents_add = list("charcoal" = 0.04, "plantmatter" = 0.02)

/obj/item/seeds/kudzu/Copy()
	var/obj/item/seeds/kudzu/S = ..()
	S.mutations = mutations.Copy()
	return S

/obj/item/seeds/kudzu/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] swallows the pack of kudzu seeds! It looks like [user.p_theyre()] trying to commit suicide..</span>")
	plant(user)
	return BRUTELOSS

/obj/item/seeds/kudzu/proc/plant(mob/user)
	var/turf/user_turf = user.loc
	if(!isturf(user_turf) || isspaceturf(user_turf) || !is_location_within_transition_boundaries(user_turf))
		return FALSE
	message_admins("Kudzu planted by [ADMIN_LOOKUPFLW(user)] at [ADMIN_COORDJMP(user_turf)]")
	investigate_log("was planted by [key_name_log(user)] at [COORD(user_turf)]", INVESTIGATE_BOTANY)
	new /obj/structure/spacevine_controller(user_turf, mutations, potency, production)
	user.temporarily_remove_item_from_inventory(src)
	qdel(src)
	return TRUE

/obj/item/seeds/kudzu/attack_self(mob/user)
	if(plant(user))
		to_chat(user, "<span class='notice'>You plant the kudzu. You monster.</span>")

/obj/item/seeds/kudzu/get_analyzer_text()
	var/text = ..()
	var/text_string = ""
	for(var/datum/spacevine_mutation/SM in mutations)
		text_string += "[(text_string == "") ? "" : ", "][SM.name]"
	text += "\n- Plant Mutations: [(text_string == "") ? "None" : text_string]"
	return text

/obj/item/seeds/kudzu/on_chem_reaction(datum/reagents/S)
	var/list/temp_mut_list = list()

	if(S.has_reagent("sterilizine", 5))
		for(var/datum/spacevine_mutation/SM in mutations)
			if(SM.quality == NEGATIVE)
				temp_mut_list += SM
		if(prob(20) && temp_mut_list.len)
			mutations.Remove(pick(temp_mut_list))
		temp_mut_list.Cut()

	if(S.has_reagent("fuel", 5))
		for(var/datum/spacevine_mutation/SM in mutations)
			if(SM.quality == POSITIVE)
				temp_mut_list += SM
		if(prob(20) && temp_mut_list.len)
			mutations.Remove(pick(temp_mut_list))
		temp_mut_list.Cut()

	if(S.has_reagent("phenol", 5))
		for(var/datum/spacevine_mutation/SM in mutations)
			if(SM.quality == MINOR_NEGATIVE)
				temp_mut_list += SM
		if(prob(20) && temp_mut_list.len)
			mutations.Remove(pick(temp_mut_list))
		temp_mut_list.Cut()

	if(S.has_reagent("blood", 15))
		adjust_production(rand(15, -5))

	if(S.has_reagent("amanitin", 5))
		adjust_production(rand(5, -15))

	if(S.has_reagent("plasma", 5))
		adjust_potency(rand(5, -15))

	if(S.has_reagent("holywater", 10))
		adjust_potency(rand(15, -5))


/obj/item/reagent_containers/food/snacks/grown/kudzupod
	seed = /obj/item/seeds/kudzu
	name = "kudzu pod"
	desc = "<I>Pueraria Virallis</I>: An invasive species with vines that rapidly creep and wrap around whatever they contact."
	icon_state = "kudzupod"
	filling_color = "#6B8E23"
	bitesize_mod = 2
	tastes = list("kudzu" = 1)
	wine_power = 0.2
