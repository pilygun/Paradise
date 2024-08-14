#ifdef UNIT_TESTS
GLOBAL_VAR_INIT(mob_suspension, FALSE)
#else
GLOBAL_VAR_INIT(mob_suspension, TRUE)
#endif

SUBSYSTEM_DEF(mobs)
	name = "Mobs"
	priority = FIRE_PRIORITY_MOBS
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	init_order = INIT_ORDER_MOBS
	offline_implications = "Mobs will no longer process. Immediate server restart recommended."
	cpu_display = SS_CPUDISPLAY_HIGH
	ss_id = "mobs"

	var/list/currentrun = list()
	var/static/list/clients_by_zlevel[][]
	var/static/list/dead_players_by_zlevel[][] = list(list()) // Needs to support zlevel 1 here, MaxZChanged only happens when CC is created and new_players can login before that.
	var/static/list/cubemonkeys = list()
	/// The amount of Xenobiology mobs (and their offspring) that exist in the world. Used for mob capping. Excludes Slimes
	var/xenobiology_mobs = 0


/datum/controller/subsystem/mobs/get_stat_details()
	return "P:[length(GLOB.mob_living_list)]"


/datum/controller/subsystem/mobs/Initialize()
	clients_by_zlevel = new /list(world.maxz, 0)
	dead_players_by_zlevel = new /list(world.maxz, 0)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/mobs/proc/MaxZChanged()
	if (!islist(clients_by_zlevel))
		clients_by_zlevel = new /list(world.maxz,0)
		dead_players_by_zlevel = new /list(world.maxz,0)
	while(length(clients_by_zlevel) < world.maxz)
		clients_by_zlevel.len++
		clients_by_zlevel[length(clients_by_zlevel)] = list()
		dead_players_by_zlevel.len++
		dead_players_by_zlevel[length(dead_players_by_zlevel)] = list()

/datum/controller/subsystem/mobs/fire(resumed = 0)
	var/seconds = wait * 0.1
	if(!resumed)
		src.currentrun = GLOB.mob_living_list.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	var/times_fired = src.times_fired
	var/suspension = GLOB.mob_suspension

	while(currentrun.len)
		var/mob/living/L = currentrun[currentrun.len]
		currentrun.len--

		if(L)
			var/turf/T = get_turf(L)
			if(suspension && T && !length(clients_by_zlevel[T.z]))
				continue

			L.Life(seconds, times_fired)
		else
			GLOB.mob_living_list.Remove(L)

		if(MC_TICK_CHECK)
			return
