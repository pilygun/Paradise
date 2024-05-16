
///multilayer cable to connect different layers
/obj/structure/cable/multiz
	name = "multi z cable hub"
	desc = "A flexible, superconducting insulated multi Z hub for heavy-duty multi Z power transfer."
	icon = 'icons/obj/engines_and_power/power.dmi'
	icon_state = "cable_bridge"
	layer = WIRE_LAYER + 0.02 //Above all cables
	color = "white"

/obj/structure/cable/multiz/update_icon_state()
	return

/obj/structure/cable/multiz/Initialize(mapload)
	. = ..()
	mergeConnectedNetworksOnTurf(get_turf(src))

/obj/structure/cable/multiz/deconstruct(disassembled = TRUE)
	if(usr)
		investigate_log("deconstructed by [key_name_log(usr)]", INVESTIGATE_WIRES)
	if(!(obj_flags & NODECONSTRUCT))
		new/obj/item/stack/cable_coil(get_turf(src), 10, TRUE, color)
	qdel(src)

/obj/structure/cable/multiz/attackby(obj/item/W, mob/user)
	var/turf/T = get_turf(src)
	if((T.transparent_floor == TURF_TRANSPARENT) || T.intact)
		to_chat(user, span_warning("You can't interact with something that's under the floor!"))
		return
	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = W
		if(coil.get_amount() < 1)
			to_chat(user, "<span class='warning'>Not enough cable!</span>")
			return
		coil.place_turf(get_turf(src), user)
	else
		if(W.flags & CONDUCT)
			shock(user, 50, 0.7)

	add_fingerprint(user)

/obj/structure/cable/multiz/wirecutter_act(mob/user, obj/item/I)
	. = ..()


/obj/structure/cable/multiz/mergeDiagonalsNetworks(direction)
	return

/obj/structure/cable/multiz/mergeConnectedNetworks(direction)
	return

// merge with the powernets of power objects in the source turf and multi z
/obj/structure/cable/multiz/mergeConnectedNetworksOnTurf()
	if(!powernet) //if we somehow have no powernet, make one (it may happen one time, when being built)
		var/datum/powernet/newPN = new()
		newPN.add_cable(src)

	//connect to cables that points to center (d1 or d2 to 0)
	for(var/obj/structure/cable/C in loc)
		if(C.d1 == 0)
			if(C.powernet == powernet)
				continue
			if(C.powernet)
				merge_powernets(powernet, C.powernet)
			else
				powernet.add_cable(C) //the cable was powernetless, let's just add it to our powernet

	var/obj/structure/cable/multiz/above = locate(/obj/structure/cable/multiz) in (GET_TURF_ABOVE(loc))
	if(above && above?.powernet != powernet)
		if(!above.powernet)
			powernet.add_cable(above)
		else
			merge_powernets(powernet, above.powernet)
	var/obj/structure/cable/multiz/below = locate(/obj/structure/cable/multiz) in (GET_TURF_BELOW(loc))
	if(below && below?.powernet != powernet)
		if(!below.powernet)
			powernet.add_cable(below)
		else
			merge_powernets(powernet, below.powernet)

// Regular cables already doing the job at gathering all power machines and other cable on our turf
// We just collecting what cables won't collect, other multiZ cables.
/obj/structure/cable/multiz/get_connections(powernetless_only)
	. = list()
	var/turf/our_turf = loc
	if(!our_turf)
		return
	var/obj/structure/cable/multiz/above = locate(/obj/structure/cable/multiz) in (GET_TURF_ABOVE(our_turf))
	var/obj/structure/cable/multiz/below = locate(/obj/structure/cable/multiz) in (GET_TURF_BELOW(our_turf))
	if(above && (!powernetless_only || !above.powernet))
		. += above
	if(below && (!powernetless_only || !below.powernet))
		. += below

	. += power_list(our_turf, src, 0, powernetless_only)

	return .

// cut the cable's powernet at this cable and updates the powergrid
/obj/structure/cable/multiz/cut_cable_from_powernet(remove=TRUE)
	var/turf/our_turf = loc
	var/list/P_list = list()
	if(!our_turf)
		return

	var/obj/structure/cable/multiz/above = locate(/obj/structure/cable/multiz) in (GET_TURF_ABOVE(our_turf))
	if(above)
		P_list += above	// get that which were connected above
	var/obj/structure/cable/multiz/below = locate(/obj/structure/cable/multiz) in (GET_TURF_BELOW(our_turf))
	if(below)
		P_list += below	// and below...
	P_list += power_list(loc, src, 0, 0, cable_only = 1)//... and on turf ourselves

	if(P_list.len == 0 && !above && !below)//If we so happened to be alone cable, not connected to anything, including above and below.
		powernet.remove_cable(src) // So we gonna just delete ourself
		return
	var/obj/O = P_list[1]
	// remove the cut cable from its turf and powernet, so that it doesn't get count in propagate_network worklist
	if(remove)
		loc = null
	powernet.remove_cable(src) //remove the cut cable from its powernet

	// queue it to rebuild
	SSmachines.deferred_powernet_rebuilds += O
