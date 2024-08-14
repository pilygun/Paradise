/obj/item/mecha_parts/mecha_equipment/weapon
	name = "mecha weapon"
	range = MECHA_RANGED
	origin_tech = "materials=3;combat=3"
	var/projectile
	var/fire_sound
	var/size = 0
	var/projectiles_per_shot = 1
	var/variance = 0
	var/randomspread = FALSE //use random spread for machineguns, instead of shotgun scatter
	var/projectile_delay = 0
	var/projectiles
	var/projectile_energy_cost

/obj/item/mecha_parts/mecha_equipment/weapon/can_attach(obj/mecha/combat/M)
	if(..())
		if(istype(M))
			if(size > M.maxsize)
				return FALSE
			return TRUE
		else if(M.emagged == TRUE)
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/proc/get_shot_amount()
	return projectiles_per_shot

/obj/item/mecha_parts/mecha_equipment/weapon/action(target, params)
	if(!action_checks(target))
		return FALSE
	if(!is_faced_target(target))
		return FALSE

	var/turf/curloc = get_turf(chassis)
	var/turf/targloc = get_turf(target)
	if(!targloc || !istype(targloc) || !curloc)
		return FALSE
	if(targloc == curloc)
		return FALSE

	for(var/i=1 to get_shot_amount())
		spawn((i - 1) * projectile_delay)
			var/obj/item/projectile/A = new projectile(curloc)
			A.firer = chassis.occupant
			A.firer_source_atom = src
			A.original = target
			A.current = curloc

			var/spread = 0
			if(variance)
				if(randomspread)
					spread = round((rand() - 0.5) * variance)
				else
					spread = round((i / projectiles_per_shot - 0.5) * variance)
			A.preparePixelProjectile(target, targloc, chassis.occupant, params, spread)

			chassis.use_power(energy_drain)
			projectiles--
			A.fire()
			playsound(chassis, fire_sound, 50, 1)
	log_message("Fired from [name], targeting [target].")
	add_attack_logs(chassis.occupant, target, "fired a [src]")
	start_cooldown()

/obj/item/mecha_parts/mecha_equipment/weapon/energy
	name = "General Energy Weapon"
	size = 2

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	equip_cooldown = 0.4 SECONDS
	name = "CH-PS \"Firedart\" Laser"
	icon_state = "mecha_firedart"
	origin_tech = "magnets=3;combat=3;engineering=3"
	energy_drain = 40
	projectile = /obj/item/projectile/beam
	fire_sound = 'sound/weapons/gunshots/1laser4.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/disabler
	name = "CH-PD Disabler"
	icon_state = "mecha_disabler"
	origin_tech = "combat=3"
	projectile = /obj/item/projectile/beam/disabler
	fire_sound = 'sound/weapons/plasma_cutter.ogg'
	projectiles_per_shot = 2
	projectile_delay = 1
	harmful = FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	equip_cooldown = 1 SECONDS
	name = "CH-LC \"Solaris\" Laser Cannon"
	icon_state = "mecha_solaris"
	origin_tech = "magnets=4;combat=4;engineering=3"
	energy_drain = 60
	projectile = /obj/item/projectile/beam/laser/heavylaser
	fire_sound = 'sound/weapons/gunshots/1pulse.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion
	equip_cooldown = 1.5  SECONDS
	name = "mkIV Ion Heavy Cannon"
	icon_state = "mecha_ion"
	origin_tech = "materials=4;combat=5;magnets=4"
	energy_drain = 120
	projectile = /obj/item/projectile/ion
	fire_sound = 'sound/weapons/ionrifle.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/ionshotgun
	equip_cooldown = 1.5 SECONDS
	name = "G.M. Ion Shotgun"
	desc = "Having carefully studied the ion rifle, the brightest minds of the Gorlex Marauders found duct tape and stuck two more barrels! Impressive, isn't it?"
	icon_state = "mecha_ion"
	origin_tech = "materials=4;combat=5;magnets=4"
	energy_drain = 40
	projectile = /obj/item/projectile/ion/weak
	fire_sound = 'sound/weapons/ionrifle.ogg'
	projectiles_per_shot = 3
	variance = 15

/obj/item/mecha_parts/mecha_equipment/weapon/energy/tesla
	equip_cooldown = 3.5 SECONDS
	name = "P-X Tesla Cannon"
	desc = "A weapon for combat exosuits. Fires bolts of electricity similar to the experimental tesla engine"
	icon_state = "mecha_teslacannon"
	origin_tech = "materials=4;engineering=4;combat=6;magnets=6"
	energy_drain = 500
	projectile = /obj/item/projectile/energy/shock_revolver
	fire_sound = 'sound/magic/lightningbolt.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/xray
	equip_cooldown = 1 SECONDS
	name = "S-1 X-Ray Projector"
	desc = "A weapon for combat exosuits. Fires beams of X-Rays that pass through solid matter."
	icon_state = "mecha_xray"
	origin_tech = "combat=6;materials=4;programming=6"
	energy_drain = 120
	projectile = /obj/item/projectile/beam/xray
	fire_sound = 'sound/weapons/gunshots/1xray.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/xray/triple
	name = "X-XR Triple-barrel X-Ray Stream Projector"
	projectiles_per_shot = 3
	projectile_delay = 1

/obj/item/mecha_parts/mecha_equipment/weapon/energy/immolator
	equip_cooldown = 1.2 SECONDS
	name = "ZFI Immolation Beam Gun"
	desc = "A weapon for combat exosuits. Fires beams of extreme heat that set targets on fire."
	icon_state = "mecha_immolator"
	origin_tech = "materials=4;engineering=4;combat=6;magnets=6"
	energy_drain = 80
	variance = 25
	projectiles_per_shot = 4
	projectile = /obj/item/projectile/beam/immolator/mech
	fire_sound = 'sound/weapons/gunshots/1xray.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse
	equip_cooldown = 3 SECONDS
	name = "eZ-13 mk2 Heavy pulse rifle"
	icon_state = "mecha_pulse"
	energy_drain = 120
	origin_tech = "materials=3;combat=6;powerstorage=4"
	projectile = /obj/item/projectile/beam/pulse/heavy
	fire_sound = 'sound/weapons/gunshots/1pulse.ogg'
	harmful = TRUE

/obj/item/projectile/beam/pulse/heavy
	name = "heavy pulse laser"
	icon_state = "pulse1_bl"


/obj/item/mecha_parts/mecha_equipment/weapon/energy/taser
	name = "PBT \"Pacifier\" Mounted Taser"
	icon_state = "mecha_taser"
	origin_tech = "combat=3"
	energy_drain = 20
	equip_cooldown = 0.8 SECONDS
	projectile = /obj/item/projectile/energy/electrode
	fire_sound = 'sound/weapons/gunshots/1taser.ogg'
	size = 1

/obj/item/mecha_parts/mecha_equipment/weapon/honker
	name = "HoNkER BlAsT 5000"
	icon_state = "mecha_honker"
	energy_drain = 200
	equip_cooldown = 15 SECONDS
	range = MECHA_MELEE | MECHA_RANGED

/obj/item/mecha_parts/mecha_equipment/weapon/honker/can_attach(obj/mecha/combat/M)
	if(..())
		if(istype(M, /obj/mecha/combat/honker) || istype(M, /obj/mecha/combat/lockersyndie))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/honker/action(target, params)
	if(!chassis)
		return FALSE
	if(energy_drain && chassis.get_charge() < energy_drain)
		return FALSE
	if(!equip_ready)
		return FALSE

	playsound(chassis, 'sound/items/airhorn.ogg', 100, 1)
	chassis.occupant_message("<font color='red' size='5'>HONK</font>")
	for(var/mob/living/carbon/M in ohearers(6, chassis))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.check_ear_prot() >= HEARING_PROTECTION_TOTAL)
				continue
		to_chat(M, "<font color='red' size='7'>HONK</font>")
		M.SetSleeping(0)
		M.Stuttering(40 SECONDS)
		M.Deaf(60 SECONDS)
		M.Weaken(6 SECONDS)
		if(prob(30))
			M.Stun(20 SECONDS)
			M.Paralyse(8 SECONDS)
		else
			M.Jitter(1000 SECONDS)
		///else the mousetraps are useless
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(isobj(H.shoes) && !HAS_TRAIT(H.shoes, TRAIT_NODROP))
				var/thingy = H.shoes
				H.drop_item_ground(H.shoes)
				SSmove_manager.move_away(thingy, chassis, 15, 2)
				spawn(20)
					if(thingy)
						SSmove_manager.stop_looping(thingy)
	for(var/obj/mecha/combat/reticence/R in oview(6, chassis))
		R.occupant_message("\The [R] has protected you from [chassis]'s HONK at the cost of some power.")
		R.use_power(R.get_charge() / 4)

	chassis.use_power(energy_drain)
	log_message("Honked from [name]. HONK!")
	var/turf/T = get_turf(src)
	add_attack_logs(chassis.occupant, target, "used a Mecha Honker", ATKLOG_MOST)
	add_game_logs("used a Mecha Honker in [COORD(T)]", chassis.occupant)
	start_cooldown()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic
	name = "General Ballisic Weapon"
	size = 2

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/action_checks(atom/target)
	if(..())
		if(projectiles > 0)
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/get_module_equip_info()
	return "\[[projectiles]\][(projectiles < initial(projectiles))?" - <a href='?src=[UID()];rearm=1'>Rearm</a>":null]"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/rearm()
	if(projectiles < initial(projectiles))
		var/projectiles_to_add = initial(projectiles) - projectiles
		while(chassis.get_charge() >= projectile_energy_cost && projectiles_to_add)
			projectiles++
			projectiles_to_add--
			chassis.use_power(projectile_energy_cost)
	send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",get_equip_info())
	log_message("Rearmed [name].")
	playsound(src, 'sound/weapons/gun_interactions/rearm.ogg', 50, 1)
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/Topic(href, href_list)
	..()
	if(href_list["rearm"])
		rearm()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	name = "FNX-99 \"Hades\" Carbine"
	icon_state = "mecha_carbine"
	origin_tech = "materials=4;combat=4"
	equip_cooldown = 0.8 SECONDS
	projectile = /obj/item/projectile/bullet/incendiary/shell/dragonsbreath/mecha
	fire_sound = 'sound/weapons/gunshots/1m90.ogg'
	projectiles = 24
	projectile_energy_cost = 15
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/silenced
	name = "\improper S.H.H. \"Quietus\" Carbine"
	fire_sound = 'sound/weapons/gunshots/1suppres.ogg'
	icon_state = "mecha_mime"
	equip_cooldown = 1.5 SECONDS
	projectile = /obj/item/projectile/bullet/mime
	projectiles = 20
	projectile_energy_cost = 50

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/silenced/can_attach(obj/mecha/combat/M)
	if(..())
		if(istype(M, /obj/mecha/combat/reticence) || istype(M, /obj/mecha/combat/lockersyndie))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	name = "LBX AC 10 \"Scattershot\""
	icon_state = "mecha_scatter"
	origin_tech = "combat=4"
	equip_cooldown = 2 SECONDS
	projectile = /obj/item/projectile/bullet/midbullet
	fire_sound = 'sound/weapons/gunshots/1shotgun_auto.ogg'
	projectiles = 40
	projectile_energy_cost = 25
	projectiles_per_shot = 4
	variance = 25
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot/syndi
	name = "LBX AC 11 \"Ram\""
	desc = "Minotaur go brr right into your face!"
	icon_state = "mecha_scatter"
	origin_tech = "combat=4"
	equip_cooldown = 0.8 SECONDS
	projectile = /obj/item/projectile/bullet/pellet/flechette
	fire_sound = 'sound/weapons/gunshots/1shotgun_auto.ogg'
	projectiles = 50
	projectile_energy_cost = 10 // сохраняется то же энергопотребление при увеличенном дпс
	projectiles_per_shot = 5
	variance = 15
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	name = "Ultra AC 2"
	icon_state = "mecha_uac2"
	origin_tech = "combat=4"
	equip_cooldown = 1.2 SECONDS
	projectile = /obj/item/projectile/bullet/weakbullet3
	fire_sound = 'sound/weapons/gunshots/1mg2.ogg'
	projectiles = 300
	projectile_energy_cost = 20
	projectiles_per_shot = 3
	variance = 6
	projectile_delay = 2
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg/syndi
	name = "AC 2 \"Special\""
	desc = "Cr20c inside!"
	icon_state = "mecha_uac2"
	origin_tech = "combat=4"
	equip_cooldown = 0.8 SECONDS
	projectile = /obj/item/projectile/bullet/midbullet_AC2S
	fire_sound = 'sound/weapons/gunshots/1mg2.ogg'
	projectiles = 300
	projectile_energy_cost = 14
	projectiles_per_shot = 3
	variance = 6
	projectile_delay = 2
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg/dual
	name = "XMG-9 Autocannon"
	projectiles_per_shot = 6

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/amlg
	name = "AMLG-90"
	icon_state = "mecha_amlg90"
	origin_tech = "combat=4"
	equip_cooldown = 1.2 SECONDS
	projectile = /obj/item/projectile/beam/laser
	fire_sound = 'sound/weapons/gunshots/gunshot_lascarbine.ogg'
	projectiles = 150
	projectile_energy_cost = 40
	projectiles_per_shot = 3
	variance = 6
	projectile_delay = 2
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	name = "SRM-8 Light Missile Rack"
	icon_state = "mecha_missilerack_six"
	origin_tech = "combat=5;materials=4;engineering=4"
	projectile = /obj/item/missile/light
	fire_sound = 'sound/weapons/gunshots/1launcher.ogg'
	projectiles = 8
	projectile_energy_cost = 1000
	equip_cooldown = 6 SECONDS
	var/missile_speed = 2
	var/missile_range = 30
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/action(target, params)
	if(!action_checks(target))
		return FALSE
	if(!is_faced_target(target))
		return FALSE
	var/obj/item/missile/M = new projectile(chassis.loc)
	M.primed = 1
	playsound(chassis, fire_sound, 50, 1)
	M.throw_at(target, missile_range, missile_speed, spin = FALSE)
	projectiles--
	log_message("Fired from [name], targeting [target].")
	var/turf/T = get_turf(src)
	add_attack_logs(chassis.occupant, target, "fired a [src]", ATKLOG_FEW)
	add_game_logs("Fired a [src] in [COORD(T)]", chassis.occupant)
	start_cooldown()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/heavy
	name = "SRX-13 Heavy Missile Launcher"
	icon_state = "mecha_missilerack"
	projectile = /obj/item/missile/heavy

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/medium
	name = "SRM-8 Missile Rack"
	icon_state = "mecha_missilerack"
	projectile = /obj/item/missile

/obj/item/missile
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "missile"
	var/primed = null
	throwforce = 15

/obj/item/missile/proc/primed_explosion(atom/hit_atom)
	explosion(hit_atom, 0, 2, 3, 4, 0)

/obj/item/missile/heavy/primed_explosion(atom/hit_atom)
	explosion(hit_atom, 2, 3, 4, 6, 0)

/obj/item/missile/light/primed_explosion(atom/hit_atom)
	explosion(hit_atom, 0, 0, 2, 4, 0)

/obj/item/missile/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(primed)
		primed_explosion(hit_atom)
		qdel(src)
	else
		..()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang
	name = "SGL-6 Flashbang Launcher"
	icon_state = "mecha_grenadelnchr"
	origin_tech = "combat=4;engineering=4"
	projectile = /obj/item/grenade/flashbang
	fire_sound = 'sound/weapons/gunshots/1grenlauncher.ogg'
	projectiles = 6
	missile_speed = 1.5
	projectile_energy_cost = 800
	equip_cooldown = 6 SECONDS
	var/det_time = 20
	harmful = TRUE
	size = 1

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/action(target, params)
	if(!action_checks(target))
		return FALSE
	if(!is_faced_target(target))
		return FALSE
	var/obj/item/grenade/flashbang/F = new projectile(chassis.loc)
	playsound(chassis, fire_sound, 50, 1)
	F.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Fired from [name], targeting [target].")
	spawn(det_time)
		F.prime()
	start_cooldown()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang//Because I am a heartless bastard -Sieve
	name = "SOB-3 Clusterbang Launcher"
	desc = "A weapon for combat exosuits. Launches primed clusterbangs. You monster."
	origin_tech = "combat=4;materials=4"
	projectiles = 3
	projectile = /obj/item/grenade/clusterbuster
	projectile_energy_cost = 1600 //getting off cheap seeing as this is 3 times the flashbangs held in the grenade launcher.
	equip_cooldown = 9 SECONDS
	size = 1

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang/limited/get_module_equip_info()//Limited version of the clusterbang launcher that can't reload
	return " \[[projectiles]\]"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang/limited/rearm()
	return//Extra bit of security

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar
	name = "Banana Mortar"
	icon_state = "mecha_bananamrtr"
	projectile = /obj/item/grown/bananapeel
	fire_sound = 'sound/items/bikehorn.ogg'
	projectiles = 15
	missile_speed = 1.5
	projectile_energy_cost = 100
	equip_cooldown = 2 SECONDS
	harmful = FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar/can_attach(obj/mecha/combat/M)
	if(..())
		if(istype(M, /obj/mecha/combat/honker) || istype(M, /obj/mecha/combat/lockersyndie))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar/action(target, params)
	if(!action_checks(target))
		return FALSE
	if(!is_faced_target(target))
		return FALSE
	var/obj/item/grown/bananapeel/B = new projectile(chassis.loc)
	playsound(chassis, fire_sound, 60, 1)
	B.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Bananed from [name], targeting [target]. HONK!")
	start_cooldown()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar
	name = "Mousetrap Mortar"
	icon_state = "mecha_mousetrapmrtr"
	projectile = /obj/item/assembly/mousetrap
	fire_sound = 'sound/items/bikehorn.ogg'
	projectiles = 15
	missile_speed = 1.5
	projectile_energy_cost = 100
	equip_cooldown = 1 SECONDS
	harmful = FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar/can_attach(obj/mecha/combat/M)
	if(..())
		if(istype(M, /obj/mecha/combat/honker) || istype(M, /obj/mecha/combat/lockersyndie))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar/action(target, params)
	if(!action_checks(target))
		return FALSE
	if(!is_faced_target(target))
		return FALSE
	var/obj/item/assembly/mousetrap/M = new projectile(chassis.loc)
	M.secured = 1
	playsound(chassis, fire_sound, 60, 1)
	M.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Launched a mouse-trap from [name], targeting [target]. HONK!")
	start_cooldown()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bola
	name = "PCMK-6 Bola Launcher"
	icon_state = "mecha_bola"
	origin_tech = "combat=4;engineering=4"
	projectile = /obj/item/restraints/legcuffs/bola
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	projectiles = 10
	missile_speed = 1
	missile_range = 30
	projectile_energy_cost = 50
	equip_cooldown = 1 SECONDS
	harmful = FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bola/can_attach(obj/mecha/combat/M)
	if(..())
		if(istype(M, /obj/mecha/combat/gygax) || istype(M, /obj/mecha/combat/lockersyndie))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bola/action(target, params)
	if(!action_checks(target))
		return FALSE
	if(!is_faced_target(target))
		return FALSE
	var/obj/item/restraints/legcuffs/bola/M = new projectile(chassis.loc)
	playsound(chassis, fire_sound, 50, 1)
	M.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Fired from [name], targeting [target].")
	start_cooldown()

/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma
	equip_cooldown = 1 SECONDS
	name = "217-D Heavy Plasma Cutter"
	desc = "A device that shoots resonant plasma bursts at extreme velocity. The blasts are capable of crushing rock and demloishing solid obstacles."
	icon_state = "mecha_plasmacutter"
	item_state = "plasmacutter"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	energy_drain = 30
	origin_tech = "materials=3;plasmatech=4;engineering=3"
	projectile = /obj/item/projectile/plasma/adv/mech
	fire_sound = 'sound/weapons/gunshots/1laser5.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma/can_attach(obj/mecha/M)
	if(istype(M, /obj/mecha/working) || istype(M, /obj/mecha/combat/lockersyndie))
		if(M.equipment.len<M.max_equip)
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/mecha_kineticgun
	equip_cooldown = 1 SECONDS
	name = "Exosuit Proto-kinetic Accelerator"
	desc = "An exosuit-mounted mining tool that does increased damage in low pressure. Drawing from an onboard power source allows it to project further than the handheld version."
	icon_state = "mecha_kineticgun"
	energy_drain = 50
	size = 1
	projectile = /obj/item/projectile/kinetic/mech
	fire_sound = 'sound/weapons/kenetic_accel.ogg'
	harmful = FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/mecha_kineticgun/can_attach(obj/mecha/M)
	if(istype(M))
		if(length(M.equipment) < M.max_equip)
			return TRUE
	return FALSE
