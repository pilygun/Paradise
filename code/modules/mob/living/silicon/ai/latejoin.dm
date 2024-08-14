GLOBAL_LIST_EMPTY(empty_playable_ai_cores)

/mob/living/silicon/ai/verb/wipe_core()
	set name = "Wipe Core"
	set category = "OOC"
	set desc = "Wipe your core. This is functionally equivalent to cryo or robotic storage, freeing up your job slot."

	// Guard against misclicks, this isn't the sort of thing we want happening accidentally
	if(tgui_alert(usr, "WARNING: This will immediately wipe your core and ghost you, removing your character from the round permanently (similar to cryo and robotic storage). Are you entirely sure you want to do this?", "Wipe Core", list("No", "Yes")) != "Yes")
		return

	// We warned you.
	GLOB.empty_playable_ai_cores += new /obj/structure/AIcore/deactivated(loc)
	GLOB.global_announcer.autosay("[src] has been moved to intelligence storage.", "Artificial Intelligence Oversight")

	for(var/mob/living/silicon/robot/R in connected_robots)
		R.disconnect_from_ai()
		R.show_laws()

	//Handle job slot/tater cleanup.
	var/job = mind.assigned_role

	SSjobs.FreeRole(job)

	if(mind.objectives.len)
		mind.objectives.Cut()
		mind.special_role = null

	// Ghost the current player and allow or disallow them to respawn, depends on time
	if(TOO_EARLY_TO_GHOST)
		ghostize(FALSE)
	else
		ghostize(TRUE)
	// Delete the old AI shell
	qdel(src)

// TODO: Move away from the insane name-based landmark system
/mob/living/silicon/ai/proc/moveToAILandmark()
	var/obj/loc_landmark
	for(var/obj/effect/landmark/start/sloc in GLOB.landmarks_list)
		if(sloc.name != JOB_TITLE_AI)
			continue
		if(locate(/mob/living) in sloc.loc)
			continue
		loc_landmark = sloc
	if(!loc_landmark)
		for(var/obj/effect/landmark/tripai in GLOB.landmarks_list)
			if(tripai.name == "tripai")
				if(locate(/mob/living) in tripai.loc)
					continue
				loc_landmark = tripai
	if(!loc_landmark)
		to_chat(src, "Oh god sorry we can't find an unoccupied AI spawn location, so we're spawning you on top of someone.")
		for(var/obj/effect/landmark/start/sloc in GLOB.landmarks_list)
			if(sloc.name == JOB_TITLE_AI)
				loc_landmark = sloc

	forceMove(loc_landmark.loc)
	view_core()

// Before calling this, make sure an empty core exists, or this will no-op
/mob/living/silicon/ai/proc/moveToEmptyCore()
	if(!GLOB.empty_playable_ai_cores.len)
		log_runtime(EXCEPTION("moveToEmptyCore called without any available cores"), src)
		return

	// IsJobAvailable for AI checks that there is an empty core available in this list
	var/obj/structure/AIcore/deactivated/C = GLOB.empty_playable_ai_cores[1]
	GLOB.empty_playable_ai_cores -= C

	forceMove(C.loc)
	view_core()

	qdel(C)
