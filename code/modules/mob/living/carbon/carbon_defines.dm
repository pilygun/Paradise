/mob/living/carbon
	gender = MALE
	pressure_resistance = 15
	mobility_flags = MOBILITY_FLAGS_CARBON_DEFAULT
	blood_volume = BLOOD_VOLUME_NORMAL
	rotate_on_lying = TRUE
	pull_hand = null
	var/list/stomach_contents
	var/list/processing_patches
	var/list/internal_organs	= list()
	var/list/internal_organs_slot	= list()	//Same as above, but stores "slot ID" - "organ" pairs for easy access.

	var/life_tick = 0      // The amount of life ticks that have processed on this mob.

	var/obj/item/handcuffed = null //Whether or not the mob is handcuffed
	var/obj/item/legcuffed = null  //Same as handcuffs but for legs. Bear traps use this.

	var/obj/item/head = null
	var/obj/item/clothing/suit/wear_suit = null		//TODO: necessary? Are they even used? ~Carn

	var/mob/living/simple_animal/borer/borer = null

	//Active emote/pose
	var/pose = null

	var/pulse = PULSE_NORM	//current pulse level

	var/wetlevel = 0 //how wet the mob is

	var/co2overloadtime = null
	var/dreaming = 0 //How many dream images we have left to send
	var/nightmare = 0
	///Made to slide properly. When we are done with the movement, we should remove it.
	var/slide_distance = 0

	/// Used for wishgranter see wildwest.dm
	var/revival_in_progress = FALSE
	/// Just a timer stamp for [/mob/living/carbon/relaymove]
	var/last_stomach_attack

