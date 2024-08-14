SUBSYSTEM_DEF(assets)
	name = "Assets"
	init_order = INIT_ORDER_ASSETS
	flags = SS_NO_FIRE
	ss_id = "assets"
	/// Contains /datum/asset_cache_item
	var/list/cache = list()
	var/list/preload = list()
	var/datum/asset_transport/transport = new()

/datum/controller/subsystem/assets/Initialize(timeofday)
	apply_configuration()
	load_assets()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/assets/Recover()
	cache = SSassets.cache
	preload = SSassets.preload

/datum/controller/subsystem/assets/proc/apply_configuration()
	var/newtransporttype = /datum/asset_transport
	switch (CONFIG_GET(string/asset_transport))
		if ("webroot")
			newtransporttype = /datum/asset_transport/webroot

	if (newtransporttype == transport.type)
		return

	var/datum/asset_transport/newtransport = new newtransporttype ()
	if (newtransport.validate_config())
		transport = newtransport
	transport.Load()

/datum/controller/subsystem/assets/proc/load_assets()
	for(var/type in typesof(/datum/asset))
		var/datum/asset/A = type
		if (type != initial(A._abstract))
			load_asset_datum(type)

	transport.Initialize(cache)
