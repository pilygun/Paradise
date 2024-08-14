/obj/effect/proc_holder/spell/aoe/conjure/build/mime_wall
	name = "Invisible Wall"
	desc = "The mime's performance transmutates into physical reality."
	school = "mime"
	summon_type = list(/obj/effect/forcefield/mime)
	invocation_type = "emote"
	invocation_emote_self = "<span class='notice'>You form a wall in front of yourself.</span>"
	summon_lifespan = 30 SECONDS
	base_cooldown = 30 SECONDS
	clothes_req = FALSE
	cast_sound = null
	human_req = TRUE

	action_icon_state = "mime"
	action_background_icon_state = "bg_mime"


/obj/effect/proc_holder/spell/aoe/conjure/build/mime_wall/Click()
	if(usr && usr.mind)
		if(!usr.mind.miming)
			to_chat(usr, "<span class='notice'>You must dedicate yourself to silence first.</span>")
			return
		invocation = "<B>[usr.name]</B> looks as if a wall is in front of [usr.p_them()]."
	else
		invocation_type ="none"
	..()


/obj/effect/proc_holder/spell/mime/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/mime/speak
	name = "Speech"
	desc = "Make or break a vow of silence."
	school = "mime"
	clothes_req = FALSE
	base_cooldown = 5 MINUTES
	human_req = TRUE

	action_icon_state = "mime_silence"
	action_background_icon_state = "bg_mime"


/obj/effect/proc_holder/spell/mime/speak/Click()
	if(!usr)
		return
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr
	if(user.mind.miming)
		still_recharging_msg = "<span class='warning'>You can't break your vow of silence that fast!</span>"
	else
		still_recharging_msg = "<span class='warning'>You'll have to wait before you can give your vow of silence again!</span>"
	..()


/obj/effect/proc_holder/spell/mime/speak/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/target = targets[1]

	if(!target.mind)
		return

	target.mind.miming = !target.mind.miming

	if(target.mind.miming)
		to_chat(target, "<span class='notice'>You make a vow of silence.</span>")
	else
		to_chat(target, "<span class='notice'>You break your vow of silence.</span>")


/obj/effect/proc_holder/spell/mime/speak/mask
/obj/effect/proc_holder/spell/mime/speak/mask/on_cooldown_tick()
	var/mob/living/carbon/human/user = action.owner
	if(user && cooldown_handler.should_end_cooldown() && !istype(user.wear_mask, /obj/item/clothing/mask/gas/mime))
		if(user.mind?.miming)
			cast(list(user))
		user.mind?.RemoveSpell(src)


//Advanced Mimery traitor item spells

/obj/effect/proc_holder/spell/forcewall/mime
	name = "Invisible Greater Wall"
	desc = "Form an invisible three tile wide blockade."
	school = "mime"
	wall_type = /obj/effect/forcefield/mime/advanced
	invocation_type = "emote"
	invocation_emote_self = "<span class='notice'>You form a blockade in front of yourself.</span>"
	base_cooldown = 60 SECONDS
	sound =  null
	clothes_req = FALSE

	action_icon_state = "mime_bigwall"
	action_background_icon_state = "bg_mime"
	large = TRUE


/obj/effect/proc_holder/spell/forcewall/mime/Click()
	if(usr && usr.mind)
		if(!usr.mind.miming)
			to_chat(usr, "<span class='notice'>You must dedicate yourself to silence first.</span>")
			return
		invocation = "<B>[usr.name]</B> looks as if a blockade is in front of [usr.p_them()]."
	else
		invocation_type ="none"
	..()


/obj/effect/proc_holder/spell/mime/fingergun
	name = "Finger Gun"
	desc = "Shoot lethal, silencing bullets out of your fingers! 3 bullets available per cast. Use your fingers to holster them manually."
	school = "mime"
	clothes_req = FALSE
	base_cooldown = 1 MINUTES
	human_req = TRUE

	action_icon_state = "fingergun"
	action_background_icon_state = "bg_mime"
	var/gun = /obj/item/gun/projectile/revolver/fingergun
	var/obj/item/gun/projectile/revolver/fingergun/current_gun


/obj/effect/proc_holder/spell/mime/fingergun/fake
	desc = "Pretend you're shooting bullets out of your fingers! 6 bullets available per cast. Use your fingers to holster them manually."
	gun = /obj/item/gun/projectile/revolver/fingergun/fake


/obj/effect/proc_holder/spell/mime/fingergun/Destroy()
	current_gun = null
	return ..()


/obj/effect/proc_holder/spell/mime/fingergun/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/human/target in targets)
		if(!current_gun)
			to_chat(user, span_notice("You draw your fingers!"))
			current_gun = new gun(get_turf(user), src)
			target.drop_from_active_hand()
			target.put_in_hands(current_gun)
			RegisterSignal(target, COMSIG_MOB_KEY_DROP_ITEM_DOWN, PROC_REF(holster_hand))
		else
			holster_hand(user)
			revert_cast(user)


/obj/effect/proc_holder/spell/mime/fingergun/proc/holster_hand(atom/target)
	SIGNAL_HANDLER
	if(!current_gun || action.owner.get_active_hand() != current_gun)
		return
	to_chat(action.owner, span_notice("You holster your fingers. Another time perhaps..."))
	QDEL_NULL(current_gun)
	return COMPONENT_CANCEL_DROP


// Mime Spellbooks

/obj/item/spellbook/oneuse/mime
	spell = /obj/effect/proc_holder/spell/aoe/conjure/build/mime_wall
	spellname = "Invisible Wall"
	name = "Miming Manual : "
	desc = "It contains various pictures of mimes mid-performance, aswell as some illustrated tutorials."
	icon_state = "bookmime"


/obj/item/spellbook/oneuse/mime/attack_self(mob/user)
	if(!user.mind)
		return
	for(var/obj/effect/proc_holder/spell/knownspell as anything in user.mind.spell_list)
		if(knownspell.type == spell)
			to_chat(user, "<span class='notice'>You've already read this one.</span>")
			return
	if(used)
		recoil(user)
	else
		user.mind.AddSpell(new spell)
		to_chat(user, "<span class='notice'>You flip through the pages. Your understanding of the boundaries of reality increases. You can cast [spellname]!</span>")
		user.create_log(MISC_LOG, "learned the spell [spellname]")
		user.create_attack_log("<font color='orange'>[key_name(user)] learned the spell [spellname].</font>")
		onlearned(user)


/obj/item/spellbook/oneuse/mime/recoil(mob/user)
	to_chat(user, "<span class='notice'>You flip through the pages. Nothing of interest to you.</span>")


/obj/item/spellbook/oneuse/mime/onlearned(mob/user)
	used = TRUE
	if(!locate(/obj/effect/proc_holder/spell/mime/speak) in user.mind.spell_list) //add vow of silence if not known by user
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/mime/speak)
		to_chat(user, "<span class='notice'>You have learned how to use silence to improve your performance.</span>")


/obj/item/spellbook/oneuse/mime/fingergun
	spell = /obj/effect/proc_holder/spell/mime/fingergun
	spellname = "Finger Gun"
	desc = "It contains illustrations of guns and how to mime them."


/obj/item/spellbook/oneuse/mime/fingergun/fake
	spell = /obj/effect/proc_holder/spell/mime/fingergun/fake


/obj/item/spellbook/oneuse/mime/greaterwall
	spell = /obj/effect/proc_holder/spell/forcewall/mime
	spellname = "Invisible Greater Wall"
	desc = "It contains illustrations of the great walls of human history."

