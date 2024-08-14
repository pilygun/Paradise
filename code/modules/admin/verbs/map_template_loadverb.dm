/client/proc/map_template_load()
	set category = "Event"
	set name = "Map template - Place"

	if(!check_rights(R_DEBUG | R_EVENT))
		return

	var/datum/map_template/template

	var/map = input(usr, "Choose a Map Template to place at your CURRENT LOCATION","Place Map Template") as null|anything in GLOB.map_templates
	if(!map)
		return
	template = GLOB.map_templates[map]

	var/turf/T = get_turf(mob)
	if(!T)
		return

	if(!template.fits_in_map_bounds(T, centered = TRUE))
		to_chat(usr, "Map is too large to fit in bounds. Map's dimensions: ([template.width], [template.height])")
		return

	var/list/preview = list()
	for(var/turf/place_on as anything in template.get_affected_turfs(T,centered = TRUE))
		var/image/I = image('icons/turf/overlays.dmi', place_on, "greenOverlay")
		SET_PLANE(I, ABOVE_LIGHTING_PLANE, place_on)
		preview += I
	usr.client.images += preview
	if(alert(usr,"Confirm location.","Template Confirm","Yes","No") == "Yes")
		var/timer = start_watch()
		log_and_message_admins("<span class='adminnotice'>has started to place the map template ([template.name]) at [ADMIN_COORDJMP(T)]</span>")
		if(template.load(T, centered = TRUE))
			log_and_message_admins("<span class='adminnotice'>has placed a map template ([template.name]) at [ADMIN_COORDJMP(T)]. Took [stop_watch(timer)]s.</span>")
		else
			to_chat(usr, "Failed to place map")
	usr.client.images -= preview

/client/proc/map_template_upload()
	set category = "Event"
	set name = "Map Template - Upload"

	if(!check_rights(R_DEBUG | R_EVENT))
		return

	var/map = input(usr, "Choose a Map Template to upload to template storage","Upload Map Template") as null|file
	if(!map)
		return
	if(copytext("[map]",-4) != ".dmm")
		to_chat(usr, "Bad map file: [map]")
		return

	var/timer = start_watch()
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has begun uploading a map template ([map])</span>")
	var/datum/map_template/M = new(map=map, rename="[map]")
	if(M.preload_size(map))
		to_chat(usr, "Map template '[map]' ready to place ([M.width]x[M.height])")
		GLOB.map_templates[M.name] = M
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] has uploaded a map template ([map]). Took [stop_watch(timer)]s.</span>")
	else
		to_chat(usr, "Map template '[map]' failed to load properly")
