/datum/component/squeak
	/// Default sounds
	var/static/list/default_squeak_sounds = list(
		'sound/items/toysqueak1.ogg',
		'sound/items/toysqueak2.ogg',
		'sound/items/toysqueak3.ogg'
	)
	/// Default sounds override
	var/list/override_squeak_sounds
	/// Squeak probability
	var/squeak_chance = 100
	/// If parent is a mob we will not play squeek sounds if its dead
	var/dead_check = FALSE

	/// Mob, currently holding parent
	var/mob/holder
	/// This is so shoes don't squeak every step
	var/steps = 0
	/// Amount of steps skipped before next squeak
	var/step_delay = 1
	/// Delay for inhand squeak usage
	var/use_delay = 2 SECONDS
	/// Timestamp for the var/use_delay
	COOLDOWN_DECLARE(last_use)

	/// Squeak volume
	var/volume = 30
	/// Extra-range for this component's sound
	var/sound_extra_range = -1
	/// When sounds start falling off for the squeak
	var/sound_falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE
	/// Sound exponent for squeak. Defaults to 10 as squeaking is loud and annoying enough.
	var/sound_falloff_exponent = 10

	/// What we set connect_loc to if parent is an item
	var/static/list/item_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(play_squeak_crossed),
	)


/datum/component/squeak/Initialize(custom_sounds, volume_override, chance_override, step_delay_override, use_delay_override, squeak_on_move, extrarange, falloff_exponent, falloff_distance, dead_check = FALSE)
	if(!isatom(parent) || isarea(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_BLOB_ACT, COMSIG_ATOM_HULK_ATTACK, COMSIG_PARENT_ATTACKBY), PROC_REF(play_squeak))
	if(ismovable(parent))
		RegisterSignal(parent, list(COMSIG_MOVABLE_BUMP, COMSIG_MOVABLE_IMPACT), PROC_REF(play_squeak))
		AddComponent(/datum/component/connect_loc_behalf, parent, item_connections)
		RegisterSignal(parent, COMSIG_MOVABLE_DISPOSING, PROC_REF(disposing_react))
		if(squeak_on_move)
			RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(play_squeak))
		if(isitem(parent))
			RegisterSignal(parent, list(COMSIG_ITEM_ATTACK, COMSIG_ITEM_ATTACK_OBJ, COMSIG_ITEM_HIT_REACT), PROC_REF(play_squeak))
			RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(use_squeak))
			RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
			RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
			if(istype(parent, /obj/item/clothing/shoes))
				RegisterSignal(parent, COMSIG_SHOES_STEP_ACTION, PROC_REF(step_squeak))

	src.dead_check = dead_check
	override_squeak_sounds = custom_sounds
	if(chance_override)
		squeak_chance = chance_override
	if(volume_override)
		volume = volume_override
	if(isnum(step_delay_override))
		step_delay = step_delay_override
	if(isnum(use_delay_override))
		use_delay = use_delay_override
	if(isnum(extrarange))
		sound_extra_range = extrarange
	if(isnum(falloff_exponent))
		sound_falloff_exponent = falloff_exponent
	if(isnum(falloff_distance))
		sound_falloff_distance = falloff_distance


/datum/component/squeak/UnregisterFromParent()
	if(ismovable(parent))
		qdel(GetComponent(/datum/component/connect_loc_behalf))


/datum/component/squeak/proc/play_squeak()
	SIGNAL_HANDLER

	if(dead_check && ismob(parent))
		var/mob/mob_parent = parent
		if(mob_parent.stat == DEAD)
			return

	if(prob(squeak_chance))
		if(!override_squeak_sounds)
			playsound(parent, pickweight(default_squeak_sounds), volume, TRUE, sound_extra_range, sound_falloff_exponent, falloff_distance = sound_falloff_distance)
		else
			playsound(parent, pickweight(override_squeak_sounds), volume, TRUE, sound_extra_range, sound_falloff_exponent, falloff_distance = sound_falloff_distance)


/datum/component/squeak/proc/step_squeak(obj/item/clothing/shoes/source)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/owner = source.loc
	if(CHECK_MOVE_LOOP_FLAGS(owner, MOVEMENT_LOOP_OUTSIDE_CONTROL))
		return

	if(steps > step_delay)
		play_squeak()
		steps = 0
	else
		steps++


/datum/component/squeak/proc/play_squeak_crossed(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(isitem(arrived))
		var/obj/item/I = arrived
		if(I.item_flags & ABSTRACT)
			return

	if((arrived.movement_type & MOVETYPES_NOT_TOUCHING_GROUND) || !arrived.has_gravity())
		return

	if(ismob(arrived) && !arrived.density) // Prevents 10 overlapping mice from making an unholy sound while moving
		return

	var/atom/current_parent = parent
	if(isturf(current_parent?.loc))
		play_squeak()


/datum/component/squeak/proc/use_squeak()
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, last_use))
		return

	COOLDOWN_START(src, last_use, use_delay)
	play_squeak()


/datum/component/squeak/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	holder = equipper
	RegisterSignal(holder, COMSIG_MOVABLE_DISPOSING, PROC_REF(disposing_react), override = TRUE)
	RegisterSignal(holder, COMSIG_QDELETING, PROC_REF(holder_deleted), override = TRUE)
	//override for the preqdeleted is necessary because putting parent in hands sends the signal that this proc is registered towards,
	//so putting an object in hands and then equipping the item on a clothing slot (without dropping it first)
	//will always runtime without override = TRUE


/datum/component/squeak/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(user, COMSIG_MOVABLE_DISPOSING)
	UnregisterSignal(user, COMSIG_QDELETING)
	holder = null


///just gets rid of the reference to holder in the case that theyre qdeleted
/datum/component/squeak/proc/holder_deleted(datum/source, datum/possible_holder)
	SIGNAL_HANDLER
	if(possible_holder == holder)
		holder = null


// Disposal pipes related shit
/datum/component/squeak/proc/disposing_react(datum/source, obj/structure/disposalholder/disposal_holder, obj/machinery/disposal/disposal_source)
	SIGNAL_HANDLER

	//We don't need to worry about unregistering this signal as it will happen for us automaticaly when the holder is qdeleted
	RegisterSignal(disposal_holder, COMSIG_ATOM_DIR_CHANGE, PROC_REF(holder_dir_change))


/datum/component/squeak/proc/holder_dir_change(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER

	//If the dir changes it means we're going through a bend in the pipes, let's pretend we bumped the wall
	if(old_dir != new_dir)
		play_squeak()

