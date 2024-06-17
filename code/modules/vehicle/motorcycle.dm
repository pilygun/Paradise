/obj/vehicle/motorcycle
	name = "motorcycle"
	desc = "A fast and highly maneuverable vehicle."
	icon = 'icons/obj/vehicles/motorcycle.dmi'
	icon_state = "motorcycle_4dir"
	generic_pixel_x = 0
	generic_pixel_y = 4
	vehicle_move_delay = 1
	pull_push_speed_modifier = 1
	var/mutable_appearance/bikecover

/obj/vehicle/motorcycle/Initialize(mapload)
	. = ..()
	bikecover = mutable_appearance(icon, "motorcycle_overlay_4d", ABOVE_MOB_LAYER)


/obj/vehicle/motorcycle/post_buckle_mob(mob/living/target)
	. = ..()
	add_overlay(bikecover)


/obj/vehicle/motorcycle/post_unbuckle_mob(mob/living/target)
	. = ..()
	cut_overlay(bikecover)


/obj/vehicle/motorcycle/handle_vehicle_layer()
	if(dir == SOUTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = OBJ_LAYER
