
/*
	apply_damage(a,b,c)
	args
	a:damage - How much damage to take
	b:damage_type - What type of damage to take, brute, burn
	c:def_zone - Where to take the damage if its brute or burn
	Returns
	standard 0 if fail
*/
/mob/living/proc/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = 0, sharp = 0, used_weapon = null)
	blocked = (100 - blocked) / 100
	if(!damage || (blocked <= 0))
		return FALSE
	SEND_SIGNAL(src, COMSIG_MOB_APPLY_DAMAGE, damage, damagetype, def_zone)
	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(damage * blocked)
		if(BURN)
			adjustFireLoss(damage * blocked)
		if(TOX)
			adjustToxLoss(damage * blocked)
		if(OXY)
			adjustOxyLoss(damage * blocked)
		if(CLONE)
			adjustCloneLoss(damage * blocked)
		if(STAMINA)
			adjustStaminaLoss(damage * blocked)
	updatehealth("apply damage")
	return TRUE


/mob/living/proc/apply_damage_type(damage = 0, damagetype = BRUTE) //like apply damage except it always uses the damage procs
	switch(damagetype)
		if(BRUTE)
			return adjustBruteLoss(damage)
		if(BURN)
			return adjustFireLoss(damage)
		if(TOX)
			return adjustToxLoss(damage)
		if(OXY)
			return adjustOxyLoss(damage)
		if(CLONE)
			return adjustCloneLoss(damage)
		if(STAMINA)
			return adjustStaminaLoss(damage)
		if(BRAIN)
			return adjustBrainLoss(damage)


/mob/living/proc/get_damage_amount(damagetype = BRUTE)
	switch(damagetype)
		if(BRUTE)
			return getBruteLoss()
		if(BURN)
			return getFireLoss()
		if(TOX)
			return getToxLoss()
		if(OXY)
			return getOxyLoss()
		if(CLONE)
			return getCloneLoss()
		if(STAMINA)
			return getStaminaLoss()


/mob/living/proc/apply_damages(brute = 0, burn = 0,tox = 0, oxy = 0, clone = 0, def_zone = null, blocked = 0, stamina = 0)
	if(blocked >= 100)
		return FALSE
	if(brute)
		apply_damage(brute, BRUTE, def_zone, blocked)
	if(burn)
		apply_damage(burn, BURN, def_zone, blocked)
	if(tox)
		apply_damage(tox, TOX, def_zone, blocked)
	if(oxy)
		apply_damage(oxy, OXY, def_zone, blocked)
	if(clone)
		apply_damage(clone, CLONE, def_zone, blocked)
	if(stamina)
		apply_damage(stamina, STAMINA, def_zone, blocked)
	return TRUE


/mob/living/proc/apply_effect(effect = 0, effecttype = STUN, blocked = 0, negate_armor = FALSE)
	if(status_flags & GODMODE)
		return FALSE
	blocked = (100-blocked)/100
	if(!effect || (blocked <= 0))
		return FALSE
	switch(effecttype)
		if(STUN)
			Stun(effect * blocked)
		if(WEAKEN)
			Weaken(effect * blocked)
		if(PARALYZE)
			Paralyse(effect * blocked)
		if(IRRADIATE)
			var/rad_damage = effect
			if(!negate_armor) // Setting negate_armor overrides radiation armor checks, which are automatic otherwise
				rad_damage = max(effect * ((100-run_armor_check(null, "rad", "Your clothes feel warm.", "Your clothes feel warm."))/100),0)
			radiation += rad_damage
		if(SLUR)
			Slur(effect * blocked)
		if(STUTTER)
			Stuttering(effect * blocked)
		if(EYE_BLUR)
			EyeBlurry(effect * blocked)
		if(DROWSY)
			Drowsy(effect * blocked)
		if(JITTER)
			Jitter(effect * blocked)
		if(KNOCKDOWN)
			Knockdown(effect * blocked)
	updatehealth("apply effect")
	return TRUE


/mob/living/proc/apply_effects(blocked = 0, stun = 0, weaken = 0, paralyze = 0, irradiate = 0, slur = 0,stutter = 0, eyeblur = 0, drowsy = 0, stamina = 0, jitter = 0, knockdown = 0)
	if(blocked >= 100)
		return FALSE
	if(stun)
		apply_effect(stun, STUN, blocked)
	if(weaken)
		apply_effect(weaken, WEAKEN, blocked)
	if(paralyze)
		apply_effect(paralyze, PARALYZE, blocked)
	if(irradiate)
		apply_effect(irradiate, IRRADIATE, blocked)
	if(slur)
		apply_effect(slur, SLUR, blocked)
	if(stutter)
		apply_effect(stutter, STUTTER, blocked)
	if(eyeblur)
		apply_effect(eyeblur, EYE_BLUR, blocked)
	if(drowsy)
		apply_effect(drowsy, DROWSY, blocked)
	if(stamina)
		apply_damage(stamina, STAMINA, null, blocked)
	if(jitter)
		apply_effect(jitter, JITTER, blocked)
	if(knockdown)
		apply_effect(knockdown, KNOCKDOWN, blocked)
	return TRUE


/mob/living/proc/getBruteLoss()
	return bruteloss


/mob/living/proc/adjustBruteLoss(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		bruteloss = 0
		updatehealth("adjustBruteLoss")
		return FALSE	//godmode
	var/old_bruteloss = bruteloss
	bruteloss = max(bruteloss + amount, 0)
	if(old_bruteloss == bruteloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("adjustBruteLoss")


/mob/living/proc/getOxyLoss()
	return oxyloss


/mob/living/proc/adjustOxyLoss(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		oxyloss = 0
		updatehealth("adjustOxyLoss")
		return FALSE	//godmode
	if(BREATHLESS in mutations)
		oxyloss = 0
		return FALSE
	var/old_oxyloss = oxyloss
	oxyloss = max(oxyloss + amount, 0)
	if(old_oxyloss == oxyloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("adjustOxyLoss")


/mob/living/proc/setOxyLoss(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		oxyloss = 0
		updatehealth("setOxyLoss")
		return FALSE	//godmode
	if(BREATHLESS in mutations)
		oxyloss = 0
		return FALSE
	var/old_oxyloss = oxyloss
	oxyloss = amount
	if(old_oxyloss == oxyloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("setOxyLoss")


/mob/living/proc/getToxLoss()
	return toxloss


/mob/living/proc/adjustToxLoss(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		toxloss = 0
		updatehealth("adjustToxLoss")
		return FALSE	//godmode
	var/old_toxloss = toxloss
	toxloss = max(toxloss + amount, 0)
	if(old_toxloss == toxloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("adjustToxLoss")


/mob/living/proc/setToxLoss(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		toxloss = 0
		updatehealth("setToxLoss")
		return FALSE	//godmode
	var/old_toxloss = toxloss
	toxloss = amount
	if(old_toxloss == toxloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("setToxLoss")


/mob/living/proc/getFireLoss()
	return fireloss


/mob/living/proc/adjustFireLoss(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		fireloss = 0
		updatehealth("adjustFireLoss")
		return FALSE	//godmode
	var/old_fireloss = fireloss
	fireloss = max(fireloss + amount, 0)
	if(old_fireloss == fireloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("adjustFireLoss")


/mob/living/proc/getCloneLoss()
	return cloneloss


/mob/living/proc/adjustCloneLoss(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		cloneloss = 0
		updatehealth("adjustCloneLoss")
		return FALSE	//godmode
	var/old_cloneloss = cloneloss
	cloneloss = max(cloneloss + amount, 0)
	if(old_cloneloss == cloneloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("adjustCloneLoss")


/mob/living/proc/setCloneLoss(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		cloneloss = 0
		updatehealth("setCloneLoss")
		return FALSE	//godmode
	var/old_cloneloss = cloneloss
	cloneloss = amount
	if(old_cloneloss == cloneloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth("setCloneLoss")


/mob/living/proc/getBrainLoss()
	return 0


/mob/living/proc/adjustBrainLoss(amount, updating_health = TRUE)
	return STATUS_UPDATE_NONE


/mob/living/proc/setBrainLoss(amount, updating_health = TRUE)
	return STATUS_UPDATE_NONE


/mob/living/proc/getHeartLoss()
	return 0


/mob/living/proc/adjustHeartLoss(amount, updating_health = TRUE)
	return STATUS_UPDATE_NONE


/mob/living/proc/setHeartLoss(amount, updating_health = TRUE)
	return STATUS_UPDATE_NONE


/mob/living/proc/getStaminaLoss()
	return staminaloss


/mob/living/proc/adjustStaminaLoss(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		staminaloss = 0
		updatehealth()
		return FALSE
	var/old_stamloss = staminaloss
	staminaloss = min(max(staminaloss + amount, 0), 120)
	if(old_stamloss == staminaloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_STAMINA
	if(amount > 0)
		stam_regen_start_time = world.time + (STAMINA_REGEN_BLOCK_TIME * stam_regen_start_modifier)
	if(updating_health)
		updatehealth()


/mob/living/proc/setStaminaLoss(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		staminaloss = 0
		updatehealth()
		return FALSE
	var/old_stamloss = staminaloss
	staminaloss = min(max(amount, 0), 120)
	if(old_stamloss == staminaloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_STAMINA
	if(amount > 0)
		stam_regen_start_time = world.time + (STAMINA_REGEN_BLOCK_TIME * stam_regen_start_modifier)
	if(updating_health)
		updatehealth()


/mob/living/proc/getMaxHealth()
	return maxHealth


/mob/living/proc/setMaxHealth(var/newMaxHealth)
	maxHealth = newMaxHealth


// heal ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/heal_organ_damage(brute, burn, updating_health = TRUE)
	adjustBruteLoss(-brute, FALSE)
	adjustFireLoss(-burn, FALSE)
	if(updating_health)
		updatehealth("heal organ damage")


// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/take_organ_damage(brute, burn, updating_health = TRUE)
	if(status_flags & GODMODE)
		bruteloss = 0
		fireloss = 0
		updatehealth("take organ damage")
		return FALSE	//godmode
	adjustBruteLoss(brute, FALSE)
	adjustFireLoss(burn, FALSE)
	if(updating_health)
		updatehealth("take organ damage")


// heal MANY external organs, in random order
/mob/living/proc/heal_overall_damage(brute, burn, updating_health = TRUE)
	adjustBruteLoss(-brute, FALSE)
	adjustFireLoss(-burn, FALSE)
	if(updating_health)
		updatehealth("heal overall damage")


// damage MANY external organs, in random order
/mob/living/proc/take_overall_damage(brute, burn, updating_health = TRUE, used_weapon = null)
	if(status_flags & GODMODE)
		bruteloss = 0
		fireloss = 0
		updatehealth("take overall damage")
		return FALSE	//godmode
	adjustBruteLoss(brute, FALSE)
	adjustFireLoss(burn, FALSE)
	if(updating_health)
		updatehealth("take overall damage")


/mob/living/proc/has_organic_damage()
	return (maxHealth - health)


//heal up to amount damage, in a given order
/mob/living/proc/heal_ordered_damage(amount, list/damage_types)
	. = amount //we'll return the amount of damage healed
	for(var/i in damage_types)
		var/amount_to_heal = min(amount, get_damage_amount(i)) //heal only up to the amount of damage we have
		if(amount_to_heal)
			apply_damage_type(-amount_to_heal, i)
			amount -= amount_to_heal //remove what we healed from our current amount
		if(!amount)
			break
	. -= amount //if there's leftover healing, remove it from what we return

