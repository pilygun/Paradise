// Floor painter

/obj/item/floor_painter
	name = "floor painter"
	icon = 'icons/obj/device.dmi'
	icon_state = "floor_painter"
	item_state = "floor_painter"
	usesound = 'sound/effects/spray2.ogg'

	var/floor_icon
	var/floor_state = "floor"
	var/floor_dir = SOUTH

	w_class = WEIGHT_CLASS_TINY
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT

	var/static/list/allowed_states = list("arrival", "arrivalcorner", "bar", "barber", "bcircuit", "black", "blackcorner", "blue", "bluecorner",
		"bluefull", "bluered", "blueyellow", "blueyellowfull", "bot", "brown", "browncorner", "brownfull", "browncornerold", "brownold",
		"cafeteria", "caution", "cautioncorner", "cautionfull", "chapel", "cmo", "dark", "delivery", "escape", "escapecorner", "floor", "floor4",
		"freezerfloor", "gcircuit", "green", "greenblue", "greenbluefull", "greencorner", "greenfull", "greenyellow",
		"greenyellowfull", "grimy", "loadingarea", "neutral", "neutralcorner", "neutralfull", "orange", "orangecorner",
		"orangefull", "podfloor", "podfloor_dark", "podfloor_light", "solarpanel", "podhatch", "podhatchcorner", "purple", "purplecorner", "purplefull",
		"rcircuit", "rampbottom", "ramptop", "recharge_floor", "recharge_floor_dark", "red", "redblue", "redbluefull",
		"redcorner", "redfull", "redgreen", "redgreenfull", "darkredgreen", "darkredgreenfull", "redyellow", "redyellowfull",
		"darkredyellow", "darkredyellowfull", "darkreddarkfull", "stage_bleft", "stage_left", "stage_stairs", "vault", "warning", "warningcorner",
		"warnwhite", "warnwhitecorner", "white", "whiteblue", "whitebluecorner", "whitebluefull", "whitebot", "whitecorner", "whitedelivery",
		"whitegreen", "whitegreencorner", "whitegreenfull", "whitehall", "whitepurple", "whitepurplecorner", "whitepurplefull",
		"whitered", "whiteredcorner", "whiteredfull", "whiteyellow", "whiteyellowcorner", "whiteyellowfull", "yellow",
		"yellowcorner", "yellowcornersiding", "yellowsiding", "darkpurple", "darkpurplecorners", "darkpurplefull", "darkred", "darkredcorners",
		"darkredfull", "darkblue", "darkbluecorners", "darkbluefull", "darkgreen", "darkgreencorners", "darkgreenfull", "darkyellow", "darkyellowcorners",
		"darkyellowfull", "darkbrown", "darkbrowncorners", "darkbrownfull", "stairs-l", "stairs-m", "stairs-r",
		"warnwhitecornerred", "warnwhitecornerorange", "warnwhitecornerblue", "warnwhitecornerwhite", "warnwhitecornercamo",
		"warnwhitered", "warnwhiteorange", "warnwhiteblue", "warnwhitewhite", "warnwhitecamo", "blackfull", "brownoldfull", "escapefull",
		"navyblue", "navybluecorners", "navybluefull", "darkgrey", "darkgreycamo", "darkgreynavyblue", "darkgreynavybluecorner")

/obj/item/floor_painter/afterattack(var/atom/A, var/mob/user, proximity, params)
	if(!proximity)
		return

	var/turf/simulated/floor/plasteel/F = A

	if(F.icon_state == floor_state && F.dir == floor_dir)
		to_chat(user, "<span class='notice'>This is already painted [floor_state] [dir2text(floor_dir)]!</span>")
		return

	if(!istype(F))
		to_chat(user, "<span class='warning'>\The [src] can only be used on station flooring.</span>")
		return

	playsound(loc, usesound, 30, TRUE)
	F.icon_state = floor_state
	F.icon_regular_floor = floor_state
	F.floor_regular_dir = floor_dir
	F.dir = floor_dir

/obj/item/floor_painter/attack_self(var/mob/user)
	if(!user)
		return 0
	user.set_machine(src)
	ui_interact(user)
	return 1

/obj/item/floor_painter/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/floor_painter/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FloorPainter", name)
		// Disable automatic updates, because:
		// 1) we are the only user of the item, and don't expect to observe external changes
		// 2) generating and sending the icon each tick is a bit expensive, and creates small but noticeable lag
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/item/floor_painter/ui_data(mob/user)
	var/list/data = list()
	data["availableStyles"] = allowed_states
	data["selectedStyle"] = floor_state
	data["selectedDir"] = dir2text(floor_dir)

	data["directionsPreview"] = list()
	for(var/dir in GLOB.alldirs)
		var/icon/floor_icon = icon('icons/turf/floors.dmi', floor_state, dir)
		data["directionsPreview"][dir2text(dir)] = icon2base64(floor_icon)

	return data


/obj/item/floor_painter/ui_static_data(mob/user)
	var/list/data = list()

	data["allStylesPreview"] = list()
	for (var/style in allowed_states)
		var/icon/floor_icon = icon('icons/turf/floors.dmi', style, SOUTH)
		data["allStylesPreview"][style] = icon2base64(floor_icon)

	return data

/obj/item/floor_painter/ui_act(action, params)
	if(..())
		return

	if(action == "select_style")
		var/new_style = params["style"]
		if (allowed_states.Find(new_style) != 0)
			floor_state = new_style

	if(action == "cycle_style")
		var/index = allowed_states.Find(floor_state)
		index += text2num(params["offset"])
		while(index < 1)
			index += length(allowed_states)
		while(index > length(allowed_states))
			index -= length(allowed_states)
		floor_state = allowed_states[index]

	if(action == "select_direction")
		var/dir = text2dir(params["direction"])
		if (dir != 0)
			floor_dir = dir

	SStgui.update_uis(src)
