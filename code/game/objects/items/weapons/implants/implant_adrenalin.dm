/obj/item/implant/adrenalin
	name = "adrenal bio-chip"
	desc = "Removes all stuns and knockdowns."
	icon_state = "adrenal_old"
	implant_state = "implant-syndicate"
	origin_tech = "materials=2;biotech=4;combat=3;syndicate=2"
	activated = BIOCHIP_ACTIVATED_ACTIVE
	implant_data = /datum/implant_fluff/adrenaline
	uses = 3


/obj/item/implant/adrenalin/activate()
	uses--
	to_chat(imp_in, span_notice("You feel a sudden surge of energy!"))
	imp_in.SetStunned(0)
	imp_in.SetWeakened(0)
	imp_in.SetKnockdown(0)
	imp_in.SetImmobilized(0)
	imp_in.SetParalysis(0)
	imp_in.adjustStaminaLoss(-100)
	imp_in.set_resting(FALSE, instant = TRUE)
	imp_in.get_up(instant = TRUE)

	imp_in.reagents.add_reagent("synaptizine", 10)
	imp_in.reagents.add_reagent("omnizine", 10)
	imp_in.reagents.add_reagent("stimulative_agent", 10)
	imp_in.reagents.add_reagent("adrenaline", 2)

	if(!uses)
		qdel(src)


/obj/item/implanter/adrenalin
	name = "bio-chip implanter (adrenalin)"
	imp = /obj/item/implant/adrenalin

/obj/item/implantcase/adrenaline
	name = "bio-chip case - 'Adrenaline'"
	desc = "A glass case containing an adrenaline bio-chip."
	imp = /obj/item/implant/adrenalin

/obj/item/implant/adrenalin/prototype
	name = "prototype adrenalin bio-chip"
	desc = "Use it to escape child support. Works only once!"
	origin_tech = "combat=5;magnets=3;biotech=3;syndicate=1"
	implant_data = /datum/implant_fluff/protoadrenaline
	uses = 1

/obj/item/implanter/adrenalin/prototype
	name = "bio-chip implanter (proto-adrenalin)"
	imp = /obj/item/implant/adrenalin/prototype

/obj/item/implantcase/adrenalin/prototype
	name = "bio-chip case - 'Proto-Adrenalin'"
	desc = "A glass case containing a prototype adrenalin bio-chip."
	imp = /obj/item/implant/adrenalin/prototype

