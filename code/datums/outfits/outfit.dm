/datum/outfit
	var/name = "SOMEBODY FORGOT TO SET A NAME, NOTIFY A CODER"
	var/collect_not_del = FALSE

	var/uniform = null
	var/suit = null
	var/back = null
	var/belt = null
	var/gloves = null
	var/shoes = null
	var/head = null
	var/mask = null
	var/neck = null
	var/l_ear = null
	var/r_ear = null
	var/glasses = null
	var/id = null
	var/l_pocket = null
	var/r_pocket = null
	var/suit_store = null
	var/l_hand = null
	var/r_hand = null
	/// Should the toggle helmet proc be called on the helmet during equip
	var/toggle_helmet = FALSE
	var/pda = null
	var/internals_slot = null //ID of slot containing a gas tank
	var/list/backpack_contents = list() // In the list(path=count,otherpath=count) format
	var/box // Internals box. Will be inserted at the start of backpack_contents
	var/list/implants = list()
	var/list/cybernetic_implants = list()
	var/list/accessories = list()

	var/list/chameleon_extras //extra types for chameleon outfit changes, mostly guns

	var/can_be_admin_equipped = TRUE // Set to FALSE if your outfit requires runtime parameters

/datum/outfit/naked
	name = "Naked"

/datum/outfit/proc/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	//to be overriden for customization depending on client prefs,species etc
	return

// Used to equip an item to the mob. Mainly to prevent copypasta for collect_not_del.
/datum/outfit/proc/equip_item(mob/living/carbon/human/H, path, slot)
	var/obj/item/I = new path(H)
	if(QDELETED(I))
		return
	if(collect_not_del)
		H.equip_or_collect(I, slot)
	else
		H.equip_to_slot_or_del(I, slot)

/datum/outfit/proc/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	//to be overriden for toggling internals, id binding, access etc
	return

/datum/outfit/proc/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	pre_equip(H, visualsOnly)

	//Start with backpack,suit,uniform for additional slots
	if(back)
		equip_item(H, back, ITEM_SLOT_BACK)
	if(uniform)
		equip_item(H, uniform, ITEM_SLOT_CLOTH_INNER)
	if(suit)
		equip_item(H, suit, ITEM_SLOT_CLOTH_OUTER)
	if(belt)
		equip_item(H, belt, ITEM_SLOT_BELT)
	if(gloves)
		equip_item(H, gloves, ITEM_SLOT_GLOVES)
	if(shoes)
		equip_item(H, shoes, ITEM_SLOT_FEET)
	if(head)
		equip_item(H, head, ITEM_SLOT_HEAD)
	if(mask)
		equip_item(H, mask, ITEM_SLOT_MASK)
	if(neck)
		equip_item(H, neck, ITEM_SLOT_NECK)
	if(l_ear)
		equip_item(H, l_ear, ITEM_SLOT_EAR_LEFT)
	if(r_ear)
		equip_item(H, r_ear, ITEM_SLOT_EAR_RIGHT)
	if(glasses)
		equip_item(H, glasses, ITEM_SLOT_EYES)
	if(id)
		equip_item(H, id, ITEM_SLOT_ID)
	if(suit_store)
		equip_item(H, suit_store, ITEM_SLOT_SUITSTORE)

	if(l_hand)
		H.equip_to_slot_if_possible(new l_hand(H.loc), ITEM_SLOT_HAND_LEFT, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE)
	if(r_hand)
		H.equip_to_slot_if_possible(new r_hand(H.loc), ITEM_SLOT_HAND_RIGHT, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE)

	if(pda)
		equip_item(H, pda, ITEM_SLOT_PDA)

	if(uniform)
		for(var/path in accessories)
			var/obj/item/clothing/accessory/accessory = new path(H.w_uniform)
			if(!H.w_uniform.attach_accessory(accessory))
				stack_trace("Accessory ([accessory.type]) was not able to attach on jumpsuit ([H.w_uniform.type])")
				qdel(accessory)

	if(!visualsOnly) // Items in pockets or backpack don't show up on mob's icon.
		if(l_pocket)
			equip_item(H, l_pocket, ITEM_SLOT_POCKET_LEFT)
		if(r_pocket)
			equip_item(H, r_pocket, ITEM_SLOT_POCKET_RIGHT)

		if(box)
			if(!backpack_contents)
				backpack_contents = list()
			backpack_contents.Insert(1, box)
			backpack_contents[box] = 1
			box = null	// if it's added to backpack_contents ... we don't need it anymore.

		for(var/path in backpack_contents)
			var/number = backpack_contents[path]
			for(var/i in 1 to number)
				H.equip_or_collect(new path(H), ITEM_SLOT_BACKPACK)

		for(var/path in cybernetic_implants)
			new path(H)	// Just creating internal organ inside a human forcing it to call insert() proc.

	post_equip(H, visualsOnly)

	if(!visualsOnly)
		apply_fingerprints(H)
		if(internals_slot)
			H.internal = H.get_item_by_slot(internals_slot)
			H.update_action_buttons_icon()

	if(implants)
		for(var/path in implants)	// Implantation is required here, bcs below we have a ToggleHelmet() hardsuit proc that is based on the isertmindshielded() proc.
			var/obj/item/implant/I = new path(H)
			I.implant(H, null)

	if(!H.head && toggle_helmet)
		if(istype(H.wear_suit, /obj/item/clothing/suit/space/hardsuit))
			var/obj/item/clothing/suit/space/hardsuit/hardsuit = H.wear_suit
			hardsuit.ToggleHelmet()
		else if(istype(H.wear_suit, /obj/item/clothing/suit/hooded))
			var/obj/item/clothing/suit/hooded/S = H.wear_suit
			S.ToggleHood()

	H.regenerate_icons()
	return TRUE


/datum/outfit/proc/get_chameleon_disguise_info()
	var/list/types = list(uniform, suit, back, belt, gloves, shoes, head, mask, neck, l_ear, r_ear, glasses, id, l_pocket, r_pocket, suit_store, r_hand, l_hand, pda)
	types += chameleon_extras
	listclearnulls(types)
	return types


/datum/outfit/proc/apply_fingerprints(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(H.back)
		H.back.add_fingerprint(H, 1)	//The 1 sets a flag to ignore gloves
		for(var/obj/item/I in H.back.contents)
			I.add_fingerprint(H, 1)
	if(H.wear_id)
		H.wear_id.add_fingerprint(H, 1)
	if(H.w_uniform)
		H.w_uniform.add_fingerprint(H, 1)
	if(H.wear_suit)
		H.wear_suit.add_fingerprint(H, 1)
	if(H.wear_mask)
		H.wear_mask.add_fingerprint(H, 1)
	if(H.neck)
		H.neck.add_fingerprint(H, 1)
	if(H.head)
		H.head.add_fingerprint(H, 1)
	if(H.shoes)
		H.shoes.add_fingerprint(H, 1)
	if(H.gloves)
		H.gloves.add_fingerprint(H, 1)
	if(H.l_ear)
		H.l_ear.add_fingerprint(H, 1)
	if(H.r_ear)
		H.r_ear.add_fingerprint(H, 1)
	if(H.glasses)
		H.glasses.add_fingerprint(H, 1)
	if(H.belt)
		H.belt.add_fingerprint(H, 1)
		for(var/obj/item/I in H.belt.contents)
			I.add_fingerprint(H, 1)
	if(H.s_store)
		H.s_store.add_fingerprint(H, 1)
	if(H.l_store)
		H.l_store.add_fingerprint(H, 1)
	if(H.r_store)
		H.r_store.add_fingerprint(H, 1)
	if(H.wear_pda)
		H.wear_pda.add_fingerprint(H, 1)
	return 1

/datum/outfit/proc/save_to_file(mob/admin)
	var/stored_data = get_json_data()
	var/json = json_encode(stored_data)
	// Kinda annoying but as far as I can tell you need to make actual file.
	var/f = file("data/TempOutfitUpload")
	fdel(f)
	WRITE_FILE(f, json)
	admin << ftp(f, "[name].json")

/datum/outfit/proc/load_from(list/outfit_data)
	// This could probably use more strict validation.
	name = outfit_data["name"]
	uniform = text2path(outfit_data["uniform"])
	suit = text2path(outfit_data["suit"])
	toggle_helmet = text2path(outfit_data["toggle_helmet"])
	back = text2path(outfit_data["back"])
	belt = text2path(outfit_data["belt"])
	gloves = text2path(outfit_data["gloves"])
	shoes = text2path(outfit_data["shoes"])
	head = text2path(outfit_data["head"])
	mask = text2path(outfit_data["mask"])
	neck = text2path(outfit_data["neck"])
	l_ear = text2path(outfit_data["l_ear"])
	r_ear = text2path(outfit_data["r_ear"])
	glasses = text2path(outfit_data["glasses"])
	id = text2path(outfit_data["id"])
	pda = text2path(outfit_data["pda"])
	l_pocket = text2path(outfit_data["l_pocket"])
	r_pocket = text2path(outfit_data["r_pocket"])
	suit_store = text2path(outfit_data["suit_store"])
	r_hand = text2path(outfit_data["r_hand"])
	l_hand = text2path(outfit_data["l_hand"])
	internals_slot = text2path(outfit_data["internals_slot"])

	var/list/backpack = outfit_data["backpack_contents"]
	backpack_contents = list()
	for(var/item in backpack)
		var/itype = text2path(item)
		if(itype)
			backpack_contents[itype] = backpack[item]
	box = text2path(outfit_data["box"])

	var/list/impl = outfit_data["implants"]
	implants = list()
	for(var/I in impl)
		var/imptype = text2path(I)
		if(imptype)
			implants += imptype

	var/list/cybernetic_impl = outfit_data["cybernetic_implants"]
	cybernetic_implants = list()
	for(var/I in cybernetic_impl)
		var/cybtype = text2path(I)
		if(cybtype)
			cybernetic_implants += cybtype

	var/list/attachments = outfit_data["accessories"]
	accessories = list()
	for(var/A in attachments)
		var/accessorytype = text2path(A)
		if(accessorytype)
			accessories += accessorytype

	return TRUE

/datum/outfit/proc/get_json_data()
	. = list()
	.["outfit_type"] = type
	.["name"] = name
	.["uniform"] = uniform
	.["suit"] = suit
	.["toggle_helmet"] = toggle_helmet
	.["back"] = back
	.["belt"] = belt
	.["gloves"] = gloves
	.["shoes"] = shoes
	.["head"] = head
	.["mask"] = mask
	.["neck"] = neck
	.["l_ear"] = l_ear
	.["r_ear"] = r_ear
	.["glasses"] = glasses
	.["id"] = id
	.["pda"] = pda
	.["l_pocket"] = l_pocket
	.["r_pocket"] = r_pocket
	.["suit_store"] = suit_store
	.["r_hand"] = r_hand
	.["l_hand"] = l_hand
	.["internals_slot"] = internals_slot
	.["backpack_contents"] = backpack_contents
	.["box"] = box
	.["implants"] = implants
	.["cybernetic_implants"] = cybernetic_implants
	.["accessories"] = accessories
