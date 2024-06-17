/mob/living/silicon/ai/update_stat(reason = "none given", should_log = FALSE)
	if(status_flags & GODMODE)
		return ..()
	if(stat != DEAD)
		if(health <= HEALTH_THRESHOLD_DEAD && check_death_method())
			death()
			return
		if(stat == UNCONSCIOUS)
			set_stat(CONSCIOUS)
	..()

/mob/living/silicon/ai/has_vision(information_only = FALSE)
	return ..() && !lacks_power()
