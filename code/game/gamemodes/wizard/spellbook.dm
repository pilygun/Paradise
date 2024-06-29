/datum/spellbook_entry
	var/name = "Entry Name"
	var/is_ragin_restricted = FALSE // FALSE if this is buyable on ragin mages, TRUE if it's not.
	var/spell_type = null
	var/desc = ""
	var/category = "Атакующее"
	var/cost = 2
	var/refundable = TRUE
	var/obj/effect/proc_holder/spell/S = null //Since spellbooks can be used by only one person anyway we can track the actual spell
	var/buy_word = "Learn"
	var/limit //used to prevent a spellbook_entry from being bought more than X times with one wizard spellbook

/datum/spellbook_entry/proc/CanBuy(mob/living/carbon/human/user, obj/item/spellbook/book) // Specific circumstances
	if(book.uses < cost || limit == 0)
		return FALSE
	return TRUE

/datum/spellbook_entry/proc/Buy(mob/living/carbon/human/user, obj/item/spellbook/book) //return TRUE on success
	if(!S)
		S = new spell_type()

	return LearnSpell(user, book, S)

/datum/spellbook_entry/proc/LearnSpell(mob/living/carbon/human/user, obj/item/spellbook/book, obj/effect/proc_holder/spell/newspell)
	for(var/obj/effect/proc_holder/spell/aspell as anything in user.mind.spell_list)
		if(initial(newspell.name) == initial(aspell.name)) // Not using directly in case it was learned from one spellbook then upgraded in another
			if(aspell.spell_level >= aspell.level_max)
				to_chat(user, "<span class='warning'>Это заклинание не может стать ещё сильнее.</span>")
				return FALSE
			else
				aspell.name = initial(aspell.name)
				aspell.spell_level++
				aspell.cooldown_handler.recharge_duration = round(aspell.base_cooldown - aspell.spell_level * (aspell.base_cooldown - aspell.cooldown_min) / aspell.level_max)
				switch(aspell.spell_level)
					if(1)
						to_chat(user, "<span class='notice'>Вы усилили [aspell.name] до Эффективного [aspell.name].</span>")
						aspell.name = "Efficient [aspell.name]"
					if(2)
						to_chat(user, "<span class='notice'>Вы усилили [aspell.name] до Ускоренного [aspell.name].</span>")
						aspell.name = "Quickened [aspell.name]"
					if(3)
						to_chat(user, "<span class='notice'>Вы усилили [aspell.name] до Свободного [aspell.name].</span>")
						aspell.name = "Free [aspell.name]"
					if(4)
						to_chat(user, "<span class='notice'>Вы усилили [aspell.name] до Мгновенного [aspell.name].</span>")
						aspell.name = "Instant [aspell.name]"
				if(aspell.spell_level >= aspell.level_max)
					to_chat(user, "<span class='notice'>Это заклинание не можеть стать ещё сильнее.</span>")
				aspell.on_purchase_upgrade()
				return TRUE
	//No same spell found - just learn it
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	user.mind.AddSpell(newspell)
	to_chat(user, "<span class='notice'>Вы выучили [newspell.name].</span>")
	return TRUE

/datum/spellbook_entry/proc/CanRefund(mob/living/carbon/human/user, obj/item/spellbook/book)
	if(!refundable)
		return FALSE
	if(!S)
		S = new spell_type()
	for(var/obj/effect/proc_holder/spell/aspell as anything in user.mind.spell_list)
		if(initial(S.name) == initial(aspell.name))
			return TRUE
	return FALSE

/datum/spellbook_entry/proc/Refund(mob/living/carbon/human/user, obj/item/spellbook/book) //return point value or -1 for failure
	var/area/wizard_station/A = locate()
	if(!(user in A.contents))
		to_chat(user, "<span class='warning'>Возврат заклинаний возможен только в логове волшебника.</span>")
		return -1
	if(!S) //This happens when the spell's source is from another spellbook, from loadouts, or adminery, this create a new template temporary spell
		S = new spell_type()
	var/spell_levels = 0
	for(var/obj/effect/proc_holder/spell/aspell as anything in user.mind.spell_list)
		if(initial(S.name) == initial(aspell.name))
			spell_levels = aspell.spell_level
			user.mind.RemoveSpell(aspell)
			if(S) //If we created a temporary spell above, delete it now.
				QDEL_NULL(S)
			return cost * (spell_levels + 1)
	return -1

/datum/spellbook_entry/proc/GetInfo()
	if(!S)
		S = new spell_type()
	var/dat =""
	dat += "<b>[name]</b>"
	dat += " Cooldown:[S.base_cooldown/10]"
	dat += " Cost:[cost]<br>"
	dat += "<i>[S.desc][desc]</i><br>"
	dat += "[S.clothes_req?"Needs wizard garb":"Can be cast without wizard garb"]<br>"
	return dat

//Main category - Spells
//Offensive

/datum/spellbook_entry/blind
	name = "Blind"
	spell_type = /obj/effect/proc_holder/spell/trigger/blind
	category = "Атакующее"
	cost = 1

/datum/spellbook_entry/lightningbolt
	name = "Lightning Bolt"
	spell_type = /obj/effect/proc_holder/spell/charge_up/bounce/lightning
	category = "Атакующее"
	cost = 1

/datum/spellbook_entry/cluwne
	name = "Curse of the Cluwne"
	spell_type = /obj/effect/proc_holder/spell/touch/cluwne
	category = "Атакующее"

/datum/spellbook_entry/banana_touch
	name = "Banana Touch"
	spell_type = /obj/effect/proc_holder/spell/touch/banana
	cost = 1

/datum/spellbook_entry/mime_malaise
	name = "Mime Malaise"
	spell_type = /obj/effect/proc_holder/spell/touch/mime_malaise
	cost = 1

/datum/spellbook_entry/horseman
	name = "Curse of the Horseman"
	spell_type = /obj/effect/proc_holder/spell/horsemask
	category = "Атакующее"

/datum/spellbook_entry/disintegrate
	name = "Disintegrate"
	spell_type = /obj/effect/proc_holder/spell/touch/disintegrate
	category = "Атакующее"

/datum/spellbook_entry/fireball
	name = "Fireball"
	spell_type = /obj/effect/proc_holder/spell/fireball
	category = "Атакующее"

/datum/spellbook_entry/fleshtostone
	name = "Flesh to Stone"
	spell_type = /obj/effect/proc_holder/spell/touch/flesh_to_stone
	category = "Атакующее"

/datum/spellbook_entry/mutate
	name = "Mutate"
	spell_type = /obj/effect/proc_holder/spell/genetic/mutate
	category = "Атакующее"

/datum/spellbook_entry/rod_form
	name = "Rod Form"
	spell_type = /obj/effect/proc_holder/spell/rod_form
	category = "Атакующее"

/datum/spellbook_entry/infinite_guns
	name = "Lesser Summon Guns"
	spell_type = /obj/effect/proc_holder/spell/infinite_guns
	category = "Атакующее"

/datum/spellbook_entry/goliath_tentacles
	name = "Summon Tentacles"
	spell_type = /obj/effect/proc_holder/spell/goliath_tentacles
	category = "Атакующее"
	cost = 1

/datum/spellbook_entry/legion_skulls
	name = "Summon Skulls"
	spell_type = /obj/effect/proc_holder/spell/aoe/conjure/legion_skulls
	category = "Атакующее"
	cost = 1

/datum/spellbook_entry/goliath_dash
	name = "Goliath Dash"
	spell_type = /obj/effect/proc_holder/spell/goliath_dash
	category = "Атакующее"
	cost = 1

/datum/spellbook_entry/watchers_look
	name = "Watcher's Look"
	spell_type = /obj/effect/proc_holder/spell/watchers_look
	category = "Атакующее"
	cost = 1

//Defensive
/datum/spellbook_entry/disabletech
	name = "Disable Tech"
	spell_type = /obj/effect/proc_holder/spell/emplosion/disable_tech
	category = "Защитное"
	cost = 1

/datum/spellbook_entry/forcewall
	name = "Force Wall"
	spell_type = /obj/effect/proc_holder/spell/forcewall
	category = "Защитное"
	cost = 1

/datum/spellbook_entry/greaterforcewall
	name = "Greater Force Wall"
	spell_type = /obj/effect/proc_holder/spell/forcewall/greater
	category = "Защитное"
	cost = 1

/datum/spellbook_entry/rathens
	name = "Rathen's Secret"
	spell_type = /obj/effect/proc_holder/spell/rathens
	category = "Защитное"
	cost = 2

/datum/spellbook_entry/repulse
	name = "Repulse"
	spell_type = /obj/effect/proc_holder/spell/aoe/repulse
	category = "Защитное"
	cost = 1

/datum/spellbook_entry/smoke
	name = "Smoke"
	spell_type = /obj/effect/proc_holder/spell/smoke
	category = "Защитное"
	cost = 1

/datum/spellbook_entry/lichdom
	name = "Bind Soul"
	spell_type = /obj/effect/proc_holder/spell/lichdom
	category = "Защитное"
	is_ragin_restricted = TRUE

/datum/spellbook_entry/magicm
	name = "Magic Missile"
	spell_type = /obj/effect/proc_holder/spell/projectile/magic_missile
	category = "Защитное"

/datum/spellbook_entry/timestop
	name = "Time Stop"
	spell_type = /obj/effect/proc_holder/spell/aoe/conjure/timestop
	category = "Защитное"

/datum/spellbook_entry/sacred_flame
	name = "Sacred Flame and Fire Immunity"
	spell_type = /obj/effect/proc_holder/spell/sacred_flame
	cost = 1
	category = "Защитное"

/datum/spellbook_entry/sacred_flame/LearnSpell(mob/living/carbon/human/user, obj/item/spellbook/book, obj/effect/proc_holder/spell/newspell)
	to_chat(user, "<span class='notice'>Вы чувствуете себя огнеупорным.</span>")
	ADD_TRAIT(user, RESISTHOT, MAGIC_TRAIT)
	//ADD_TRAIT(user, TRAIT_RESISTHIGHPRESSURE, MAGIC_TRAIT)
	return ..()

/datum/spellbook_entry/sacred_flame/Refund(mob/living/carbon/human/user, obj/item/spellbook/book)
	to_chat(user, "<span class='warning'>Вы больше не чувствуете себя огнеупорным.</span>")
	REMOVE_TRAIT(user, RESISTHOT, MAGIC_TRAIT)
	//REMOVE_TRAIT(user, TRAIT_RESISTHIGHPRESSURE, MAGIC_TRAIT)
	return ..()

//Mobility
/datum/spellbook_entry/knock
	name = "Knock"
	spell_type = /obj/effect/proc_holder/spell/aoe/knock
	category = "Мобильное"
	cost = 1

/datum/spellbook_entry/greaterknock
	name = "Greater Knock"
	spell_type = /obj/effect/proc_holder/spell/aoe/knock/greater
	category = "Мобильное"
	refundable = 0 //global effect on cast

/datum/spellbook_entry/blink
	name = "Blink"
	spell_type = /obj/effect/proc_holder/spell/turf_teleport/blink
	category = "Мобильное"

/datum/spellbook_entry/jaunt
	name = "Ethereal Jaunt"
	spell_type = /obj/effect/proc_holder/spell/ethereal_jaunt
	category = "Мобильное"

/datum/spellbook_entry/spacetime_dist
	name = "Spacetime Distortion"
	spell_type = /obj/effect/proc_holder/spell/spacetime_dist
	cost = 1 //Better defence than greater forcewall (maybe) but good luck hitting anyone, so 1 point.
	category = "Мобильное"

/datum/spellbook_entry/mindswap
	name = "Mindswap"
	spell_type = /obj/effect/proc_holder/spell/mind_transfer
	category = "Мобильное"

/datum/spellbook_entry/teleport
	name = "Teleport"
	spell_type = /obj/effect/proc_holder/spell/area_teleport/teleport
	category = "Мобильное"

//Assistance

/datum/spellbook_entry/shapeshift
	name = "Shapechange"
	spell_type = /obj/effect/proc_holder/spell/shapeshift
	category = "Вспомогательное"
	cost = 2

/datum/spellbook_entry/charge
	name = "Charge"
	spell_type = /obj/effect/proc_holder/spell/charge
	category = "Вспомогательное"
	cost = 1

/datum/spellbook_entry/summonitem
	name = "Summon Item"
	spell_type = /obj/effect/proc_holder/spell/summonitem
	category = "Вспомогательное"
	cost = 1

/datum/spellbook_entry/noclothes
	name = "Remove Clothes Requirement"
	spell_type = /obj/effect/proc_holder/spell/noclothes
	category = "Вспомогательное"

/datum/spellbook_entry/healtouch
	name = "Healing Touch"
	spell_type = /obj/effect/proc_holder/spell/touch/healtouch/advanced
	category = "Вспомогательное"
	cost = 1

//Rituals
/datum/spellbook_entry/summon
	name = "Summon Stuff"
	category = "Ритуалы"
	refundable = FALSE
	buy_word = "Cast"
	var/active = FALSE

/datum/spellbook_entry/summon/CanBuy(mob/living/carbon/human/user, obj/item/spellbook/book)
	return ..() && !active

/datum/spellbook_entry/summon/GetInfo()
	var/dat =""
	dat += "<b>[name]</b>"
	if(cost>0)
		dat += " Cost:[cost]<br>"
	else
		dat += " No Cost<br>"
	dat += "<i>[desc]</i><br>"
	if(active)
		dat += "<b>Заклинание уже произнесено!</b><br>"
	return dat

/datum/spellbook_entry/summon/ghosts
	name = "Summon Ghosts"
	desc = "Испугайте экипаж, воззвав к призракам мёртвых людей. Имейте в виду, призраки капризны и иногда мстительны, и некоторые из них будут пользоваться своими незначительными способностями против вас."
	cost = 0
	is_ragin_restricted = TRUE

/datum/spellbook_entry/summon/ghosts/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	new /datum/event/wizard/ghost()
	active = TRUE
	to_chat(user, "<span class='notice'>Вы произнесли Призыв Призраков!</span>")
	playsound(get_turf(user), 'sound/effects/ghost2.ogg', 50, 1)
	return TRUE

/datum/spellbook_entry/summon/guns
	name = "Summon Guns"
	desc = "Если вооружить кучку сумашедших идиотов, которые только и ждут повода, чтобы убить тебя, что может пойти не так? Есть приличный шанс того, что они прикончат друг друга быстрее."
	is_ragin_restricted = TRUE

/datum/spellbook_entry/summon/guns/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	rightandwrong(SUMMON_GUNS, user, 10)
	active = TRUE
	playsound(get_turf(user), 'sound/magic/castsummon.ogg', 50, TRUE)
	to_chat(user, "<span class='notice'>Вы прочитали Призыв Оружия!</span>")
	return TRUE

/datum/spellbook_entry/summon/magic
	name = "Summon Magic"
	desc = "Поделитесь даром магии с экипажем и покажите им почему ей же не следует доверять."
	is_ragin_restricted = TRUE

/datum/spellbook_entry/summon/magic/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	rightandwrong(SUMMON_MAGIC, user, 10)
	active = TRUE
	playsound(get_turf(user), 'sound/magic/castsummon.ogg', 50, TRUE)
	to_chat(user, "<span class='notice'>Вы прочитали Призыв Магии!</span>")
	return TRUE

//Main category - Magical Items
/datum/spellbook_entry/item
	name = "Buy Item"
	refundable = 0
	buy_word = "Summon"
	var/spawn_on_floor = FALSE
	var/item_path = null

/datum/spellbook_entry/item/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	if(spawn_on_floor == FALSE)
		user.put_in_hands(new item_path)
	else
		new item_path(user.loc)
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	return TRUE

/datum/spellbook_entry/item/GetInfo()
	var/dat =""
	dat += "<b>[name]</b>"
	dat += " Cost:[cost]<br>"
	dat += "<i>[desc]</i><br>"
	return dat

//Artefacts
/datum/spellbook_entry/item/necrostone
	name = "A Necromantic Stone"
	desc = "Камень Некромантии позволяет вам воскресить трёх индивидов в виде скелетов-рабов, подчиняющихся вашим приказам."
	item_path = /obj/item/necromantic_stone
	category = "Артефакты"

/datum/spellbook_entry/item/scryingorb
	name = "Scrying Orb"
	desc = "Светящийся шар, время от времени потрескивающий от энергии. Его использование позволит вам стать призраком, давая возможность с лёгкостью наблюдать за станцией. Вдобавок вы получаете X-ray зрение."
	item_path = /obj/item/scrying
	category = "Артефакты"

/datum/spellbook_entry/item/scryingorb/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	if(..())
		if(!(XRAY in user.mutations))
			user.mutations.Add(XRAY)
			user.add_sight(SEE_MOBS|SEE_OBJS|SEE_TURFS)
			user.see_in_dark = 8
			user.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
			to_chat(user, "<span class='notice'>Стены неожиданно исчезли.</span>")
	return TRUE

/datum/spellbook_entry/item/soulstones
	name = "Six Soul Stone Shards and the spell Artificer"
	desc = "Осколки камня души - древние инструменты, способные захватить и обуздать души упокоенных. Заклинание Artificier позволит вам создавать магические машины, для которых захваченные души станут пилотами."
	item_path = /obj/item/storage/belt/soulstone/full
	category = "Артефакты"

/datum/spellbook_entry/item/soulstones/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	. = ..()
	if(.)
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/conjure/construct(null))
	return .

/datum/spellbook_entry/item/wands
	name = "Wand Assortment"
	desc = "Коллекция палочек в широком ассортименте. Они не перезаряжаются, так что пользуйтесь мудро. Поставляются вместе с удобным поясом."

	item_path = /obj/item/storage/belt/wands/full
	category = "Артефакты"

//Spell books

/datum/spellbook_entry/item/kit_spell_book
	name = "Kit random spell book"
	desc = "Случайные книги заклинаний! Даёт вам четыре книги по цене четырёх книг (или дороже!)"

	item_path = /obj/item/storage/box/wizard/kit_spell_book
	category = "Книги заклинаний"
	cost = 4

/datum/spellbook_entry/item/fireball_spell_book
	name = "Fireball spell book"
	desc = "Содержит знание о заклинании Огненный Шар."
	item_path = /obj/item/spellbook/oneuse/fireball
	category = "Книги заклинаний"
	cost = 2

/datum/spellbook_entry/item/smoke_spell_book
	name = "Smoke spell book"
	desc = "Содержит знание о заклинании Дымовая Завеса."
	item_path = /obj/item/spellbook/oneuse/smoke
	category = "Книги заклинаний"
	cost = 1

/datum/spellbook_entry/item/blind_spell_book
	name = "Blind spell book"
	desc = "Содержит знание о заклинании Слепота."
	item_path = /obj/item/spellbook/oneuse/blind
	category = "Книги заклинаний"
	cost = 1

/datum/spellbook_entry/item/mindswap_spell_book
	name = "Mindswap spell book"
	desc = "Содержит знание о заклинании Подмена Сознания."
	item_path = /obj/item/spellbook/oneuse/mindswap
	category = "Книги заклинаний"
	cost = 2

/datum/spellbook_entry/item/forcewall_spell_book
	name = "Forcewall spell book"
	desc = "Содержит знание о заклинании Силовая Стена."
	item_path = /obj/item/spellbook/oneuse/forcewall
	category = "Книги заклинаний"
	cost = 1

/datum/spellbook_entry/item/knock_spell_book
	name = "Knock spell book"
	desc = "Содержит знание о заклинании Стук."
	item_path = /obj/item/spellbook/oneuse/knock
	category = "Книги заклинаний"
	cost = 1

/datum/spellbook_entry/item/horsemask_spell_book
	name = "Horsemask spell book"
	desc = "Содержит знание о заклинании Проклятие Лошадиноголового."
	item_path = /obj/item/spellbook/oneuse/horsemask
	category = "Книги заклинаний"
	cost = 2

/datum/spellbook_entry/item/charge_spell_book
	name = "Charge spell book"
	desc = "Содержит знание о заклинании Заряд."
	item_path = /obj/item/spellbook/oneuse/charge
	category = "Книги заклинаний"
	cost = 1

/datum/spellbook_entry/item/summonitem_spell_book
	name = "Summon item spell book"
	desc = "Содержит знание о заклинании Призыв Предмета."
	item_path = /obj/item/spellbook/oneuse/summonitem
	category = "Книги заклинаний"
	cost = 1

/datum/spellbook_entry/item/sacredflame_spell_book
	name = "Sacred flame spell book"
	desc = "Содержит знание о заклинании Священное Пламя."
	item_path = /obj/item/spellbook/oneuse/sacredflame
	category = "Книги заклинаний"
	cost = 1

/datum/spellbook_entry/item/goliath_dash_spell_book
	name = "Goliath dash spell book"
	desc = "Содержит знание о заклинании Рывок Голиафа."
	item_path = /obj/item/spellbook/oneuse/goliath_dash
	category = "Книги заклинаний"
	cost = 1

/datum/spellbook_entry/item/watchers_look_spell_book
	name = "Watchers look spell book"
	desc = "Содержит знание о заклинании Взгляд Наблюдателя."
	item_path = /obj/item/spellbook/oneuse/watchers_look
	category = "Книги заклинаний"
	cost = 1

//Weapons and Armors
/datum/spellbook_entry/item/battlemage
	name = "Battlemage Armour"
	desc = "Околдованный комплект брони. Имеет магический щит, что может полностью поглотить шестнадцать атак прежде чем распадётся. Несмотря на внешний вид, комплект брони НЕ герметичен."

	item_path = /obj/item/storage/box/wizard/hardsuit
	limit = 1
	category = "Броня и Оружие"

/datum/spellbook_entry/item/battlemage_charge
	name = "Battlemage Armour Charges"
	desc = "Мощная защитная руна, она даст боевой броне мага восемь дополнительных зарядов щита."
	item_path = /obj/item/storage/box/wizard/recharge
	category = "Броня и Оружие"
	cost = 1

/datum/spellbook_entry/item/mjolnir
	name = "Mjolnir"
	desc = "Могучий молот, одолженный у Тора, бога грома. Он искрит едва сдерживаемой силой."
	item_path = /obj/item/twohanded/mjollnir
	category = "Броня и Оружие"

/datum/spellbook_entry/item/singularity_hammer
	name = "Singularity Hammer"
	desc = "Молот, создающий интенсивное гравитационное поле в месте удара, позволяя затягивать предметы и людей."
	item_path = /obj/item/twohanded/singularityhammer
	category = "Броня и Оружие"

/datum/spellbook_entry/item/spellblade
	name = "Spellblade"
	desc = "Будучи смертельной комбинацией лени и жажды крови, данный клинок позволяет носителю расчленять своих врагов без необходимости взмахивать мечом."
	item_path = /obj/item/gun/magic/staff/spellblade
	category = "Броня и Оружие"

//Staves
/datum/spellbook_entry/item/staffdoor
	name = "Staff of Door Creation"
	desc = "Посох, позволяющий превращать литой металл в деревянные двери. Полезен для перемещения в отсутствие других инструментов мобиильности. Не работает на стекле."
	item_path = /obj/item/gun/magic/staff/door
	category = "Посохи"
	cost = 1

/datum/spellbook_entry/item/staffhealing
	name = "Staff of Healing"
	desc = "Альтруистичный посох, позволяющий лечить живых и поднимать усопших."
	item_path = /obj/item/gun/magic/staff/healing
	category = "Посохи"
	cost = 1

/datum/spellbook_entry/item/staffslipping
	name = "Staff of Slipping"
	desc = "Посох, позволяющий стрелять магическими бананами. Эти бананы либо поскользнут, либо оглушат цель при попадании. Поражающая надёжность!"
	item_path = /obj/item/gun/magic/staff/slipping
	category = "Посохи"
	cost = 1

/datum/spellbook_entry/item/staffanimation
	name = "Staff of Animation"
	desc = 	"Магический посох, снаряды которого способны оживлять материальные предметы. Не работает на машин."
	item_path = /obj/item/gun/magic/staff/animate
	category = "Посохи"

/datum/spellbook_entry/item/staffchange
	name = "Staff of Change"
	desc = 	"Артефакт, плюющийся снарядами сверкающей энергии, что изменяют физическую форму цели."

	item_path = /obj/item/gun/magic/staff/change
	category = "Посохи"
	is_ragin_restricted = TRUE

/datum/spellbook_entry/item/staffchaos
	name = "Staff of Chaos"
	desc = "Капризный инструмент, результат использования которого не подчинён какому-либо порядку или логике. Использование этого посоха на дорогих вам людях не рекомендуется."
	item_path = /obj/item/gun/magic/staff/chaos
	category = "Посохи"

//Summons
/datum/spellbook_entry/item/oozebottle
	name = "Bottle of Ooze"
	desc = 	"Пузырёк с магически зачарованной грязью, что пробудит всепоглощающего Морфа, способного хитро маскировать себя под любые предметы, которых сможет прикоснуться, и даже сможет читать самые простые заклинания. Однако будьте аккуратны, так как диета Морфа не исключает Магов."
	item_path = /obj/item/antag_spawner/morph
	category = "Призыв"
	limit = 3
	cost = 1

/datum/spellbook_entry/item/hugbottle
	name = "Bottle of Tickles"






	desc = "Пузырёк магически зачарованного веселья, запах которого \
		привлечет милых внепространственных существ после разрушения. \
		Эти существа похожи на Демонов Резни, но немного слабее и не \
		убивают своих жертв, вместо этого помещая их в внепространственное \
		измерение обнимашек, из которого их можно выпустить после смерти демона. \
		Хаотичные, но не всесильные. Реакция экипажа, тем не менее, \
		может быть очень негативной и разрушительной."
	item_path = /obj/item/antag_spawner/slaughter_demon/laughter
	category = "Призыв"
	limit = 3
	cost = 1 // Non-destructive; it's just a jape, sibling!

/datum/spellbook_entry/item/bloodbottle
	name = "Bottle of Blood"
	desc = "Пузырёк магически зачарованной крови, запах которого привлечёт внепространственных существ при разбитии. Будьте аккуратны, так как существа призванные магией крови не являются вашими союзниками, и вы можете стать их жертвой."
	item_path = /obj/item/antag_spawner/slaughter_demon
	category = "Призыв"
	limit = 3

/datum/spellbook_entry/item/shadowbottle
	name = "Bottle of Shadows"
	desc = "Пузырёк чернильно тёмной тьмы, запах которого привлечёт внепространственных существ при разбитии. Будьте аккуратны, так как существа призванные из теней не являются вашими союзниками, и вы можете стать их жертвой."
	item_path = /obj/item/antag_spawner/slaughter_demon/shadow
	category = "Призыв"
	limit = 3
	cost = 1 //Unless you blackout the station this ain't going to do much, wizard doesn't get NV, still dies easily to a group of 2 and it doesn't eat bodies.

/datum/spellbook_entry/item/pulsedemonbottle
	name = "Living Lightbulb"
	desc = "Магически опечатанная лампа содержащая какого-то рода существо, состоящее из электричества. Будьте аккуратны, так как это существо не являются вашими союзником, и вы можете стать его жертвой."
	item_path = /obj/item/antag_spawner/pulse_demon
	category = "Призыв"
	limit = 3
	cost = 1 //Needs station power to live. Also can kill the wizard trivially in maints (get shock protection).

/datum/spellbook_entry/item/mayhembottle
	name = "Mayhem in a Bottle"

	desc = "Магически зачарованный пузырёк крови, запах которого сводит всех поблизости с ума, заставляя их впасть в убийственную ярость."
	item_path = /obj/item/mayhem
	category = "Артефакты"
	limit = 1
	cost = 2

/datum/spellbook_entry/item/contract
	name = "Contract of Apprenticeship"

	desc = 	"Магический контракт, призывающий ученика к вам на службу."
	item_path = /obj/item/contract/apprentice
	category = "Призыв"

/datum/spellbook_entry/item/tarotdeck
	name = "Guardian Deck"
	"Колода таро карт хранителя, способных привязать к вам личного телохранителя. Существует нескольок типов хранителей, но каждый из них будет делиться с вами каким-то количеством урона. \

	desc = "A deck of guardian tarot cards, capable of binding a personal guardian to your body. There are multiple types of guardian available, but all of them will transfer some amount of damage to you. \
	Было бы разумно НЕ покупать их вместе с чем-либо, что могло бы заставить вас поменяться телами с другими людьми."
	item_path = /obj/item/guardiancreator
	category = "Призыв"
	limit = 1

//Spell loadouts datum, list of loadouts is in wizloadouts.dm
/datum/spellbook_entry/loadout
	name = "Standard Loadout"
	cost = 10
	category = "Стандартные"
	refundable = FALSE
	buy_word = "Summon"
	var/list/items_path = list()
	var/list/spells_path = list()
	var/destroy_spellbook = FALSE //Destroy the spellbook when bought, for loadouts containing non-standard items/spells, otherwise wiz can refund spells

/datum/spellbook_entry/loadout/GetInfo()
	var/dat = ""
	dat += "<b>[name]</b>"
	if(cost > 0)
		dat += " Cost:[cost]<br>"
	else
		dat += " No Cost<br>"
	dat += "<i>[desc]</i><br>"
	return dat

/datum/spellbook_entry/loadout/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	if(destroy_spellbook)
		var/response = alert(user, "Набор [src] нельзя будет вернуть после покупки. Вы уверены?", "Никаких возвратов!", "Нет", "Да")
		if(response == "No")
			return FALSE
		to_chat(user, "<span class='notice'>[book] рассыпается в прах после того, как вы постигаете её мудрость.</span>")
		qdel(book)
	else if(items_path.len)
		var/response = alert(user, "Набор [src] содержит предметы, которые нельзя вернуть после покупки. Вы уверены?", "Никаких возвратов!", "Нет", "Да")
		if(response == "No")
			return FALSE
	if(items_path.len)
		var/obj/item/storage/box/wizard/B = new(src)
		for(var/path in items_path)
			new path(B)
		user.put_in_hands(B)
	for(var/path in spells_path)
		var/obj/effect/proc_holder/spell/S = new path()
		LearnSpell(user, book, S)
	return TRUE

/obj/item/spellbook
	name = "spell book"
	desc = "Легендарная книга заклинаний Мага."
	icon = 'icons/obj/library.dmi'
	icon_state = "spellbook"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/uses = 10
	var/temp = null
	var/op = 1
	var/tab = null
	var/main_tab = null
	var/mob/living/carbon/human/owner
	var/list/datum/spellbook_entry/entries = list()
	var/list/categories = list()
	var/list/main_categories = list("Заклинания", "Магические предметы", "Наборы")
	var/list/spell_categories = list("Атакующее", "Защитное", "Мобильное", "Вспомогательное", "Ритуалы")
	var/list/item_categories = list("Артефакты", "Книги заклинаний", "Броня и Оружие", "Посохи", "Призыв")
	var/list/loadout_categories = list("Стандартные", "Уникальные")

/obj/item/spellbook/proc/initialize()
	var/entry_types = subtypesof(/datum/spellbook_entry) - /datum/spellbook_entry/item - /datum/spellbook_entry/summon - /datum/spellbook_entry/loadout
	for(var/T in entry_types)
		var/datum/spellbook_entry/E = new T
		if(GAMEMODE_IS_RAGIN_MAGES && E.is_ragin_restricted)
			qdel(E)
			continue
		entries |= E
		categories |= E.category

	main_tab = main_categories[1]
	tab = categories[1]

/obj/item/spellbook/New()
	..()
	initialize()

/obj/item/spellbook/attackby(obj/item/O as obj, mob/user as mob, params)
	if(istype(O, /obj/item/contract/apprentice))
		var/obj/item/contract/apprentice/contract = O
		if(contract.used)
			to_chat(user, "<span class='warning'>Вы не можете оформить возврат после использования контракта!</span>")
		else
			to_chat(user, "<span class='notice'>Вы успешно вернули контракт в книгу заклинаний. Очки возвращены.</span>")
			uses+=2
			qdel(O)
		return

	if(istype(O, /obj/item/guardiancreator))
		var/obj/item/guardiancreator/guardian = O
		if(guardian.used)
			to_chat(user, "<span class='warning'>Вы не можете оформить возврат после использования колоды!</span>")
		else
			to_chat(user, "<span class='notice'>Вы успешно вернули колоду в книгу заклинаний. Очки возвращены.</span>")
			uses+=2
			for(var/datum/spellbook_entry/item/tarotdeck/deck in entries)
				if(!isnull(deck.limit))
					deck.limit++
			qdel(O)
		return

	if(istype(O, /obj/item/antag_spawner/slaughter_demon))
		to_chat(user, "<span class='notice'>Если так подумать, то, возможно, вызывать демона - плохая идея. Очки возвращены.</span>")
		if(istype(O, /obj/item/antag_spawner/slaughter_demon/laughter))
			uses += 1
			for(var/datum/spellbook_entry/item/hugbottle/HB in entries)
				if(!isnull(HB.limit))
					HB.limit++
		else if(istype(O, /obj/item/antag_spawner/slaughter_demon/shadow))
			uses += 1
			for(var/datum/spellbook_entry/item/shadowbottle/SB in entries)
				if(!isnull(SB.limit))
					SB.limit++
		else
			uses += 2
			for(var/datum/spellbook_entry/item/bloodbottle/BB in entries)
				if(!isnull(BB.limit))
					BB.limit++
		qdel(O)
		return

	if(istype(O, /obj/item/antag_spawner/morph))
		to_chat(user, "<span class='notice'>Если так подумать, то, возможно, вызывать морфа - плохая идея. Очки возвращены.</span>")
		uses += 1
		for(var/datum/spellbook_entry/item/oozebottle/OB in entries)
			if(!isnull(OB.limit))
				OB.limit++
		qdel(O)
		return
	return ..()

/obj/item/spellbook/proc/GetCategoryHeader(category)
	var/dat = ""
	switch(category)
		if("Атакующее")
			dat += "Заклинания, направленные на ослабление и разрушение.<BR><BR>"
			dat += "Для заклинаний: число после названия заклинания - это время отката.<BR>"
			dat += "Это число можно уменьшить, инвестировав больше поинтов в заклинание.<BR>"
		if("Защитное")
			dat += "Заклинания, направленные на повышение вашей живучести или снижение способности противника атаковать.<BR><BR>"
			dat += "Для заклинаний: число после названия заклинания - это время отката.<BR>"
			dat += "Это число можно уменьшить, инвестировав больше поинтов в заклинание.<BR>"
		if("Мобильное")
			dat += "Spells geared towards improving your ability to move. It is a good idea to take at least one.<BR><BR>"
			dat += "Для заклинаний: число после названия заклинания - это время отката.<BR>"
			dat += "Это число можно уменьшить, инвестировав больше поинтов в заклинание.<BR>"
		if("Вспомогательное")
			dat += "Spells geared towards improving your other items and abilities.<BR><BR>"
			dat += "Для заклинаний: число после названия заклинания - это время отката.<BR>"
			dat += "Это число можно уменьшить, инвестировав больше поинтов в заклинание.<BR>"
		if("Ритуалы")
			dat += "Эти могущественные заклинания способны изменить саму структуру реальности. Не всегда в вашу пользу.<BR>"
		if("Броня и Оружие")
			dat += "Различное оружие и доспехи, которые сокрушат ваших врагов и защитят вас от вреда.<BR><BR>"
			dat += "Товары не привязаны к вам и могут быть украдены. Кроме того, после покупки их, как правило, нельзя вернуть.<BR>"
		if("Посохи")
			dat += "Various staves granting you their power, which they slowly recharge over time.<BR><BR>"
			dat += "Товары не привязаны к вам и могут быть украдены. Кроме того, после покупки их, как правило, нельзя вернуть.<BR>"
		if("Артефакты")
			dat += "Различные магические артефакты.<BR><BR>"
			dat += "Товары не привязаны к вам и могут быть украдены. Кроме того, после покупки их, как правило, нельзя вернуть.<BR>"
		if("Книги заклинаний")
			dat += "Книги заклинаний для обучения ваших спутников.<BR><BR>"
			dat += "Различные наборы книг заклинаний, которые помогут вам и вашему партнеру в создании хаоса.<BR>"
		if("Призыв")
			dat += "Магические предметы, предназначенные для призыва внешних сил вам на помощь.<BR><BR>"
			dat += "Товары не привязаны к вам и могут быть украдены. Кроме того, после покупки их, как правило, нельзя вернуть.<BR>"
		if("Стандартные")
			dat += "Эти проверенные в боях наборы заклинаний просты в использовании и обеспечивают хороший баланс между нападением и защитой.<BR><BR>"
			dat += "Все они стоят 10 поинтов. Вы можете вернуть их любое из включенных заклинаний, пока остаетесь в логове волшебника.<BR>"
		if("Уникальные")
			dat += "Эти эзотерические предметы обычно содержат заклинания или предметы, которые нельзя купить в другом разделе этой книге заклинаний.<BR><BR>"
			dat += "Рекомендуется ТОЛЬКО опытным магам! Возврат поинтов не предусмотрен!<BR>"
	return dat

/obj/item/spellbook/proc/wrap(content)
	var/dat = ""
	dat += {"<html><meta charset="UTF-8"><head><title>Spellbook</title></head>"}
	dat += {"
	<head>
		<style type="text/css">
      		body { font-size: 80%; font-family: 'Lucida Grande', Verdana, Arial, Sans-Serif; }
      		ul#tabs { list-style-type: none; margin: 10px 0 0 0; padding: 0 0 0.6em 0; }
      		ul#tabs li { display: inline; }
      		ul#tabs li a { color: #42454a; background-color: #dedbde; border: 1px solid #c9c3ba; border-bottom: none; padding: 0.6em; text-decoration: none; }
      		ul#tabs li a:hover { background-color: #f1f0ee; }
      		ul#tabs li a.selected { color: #000; background-color: #f1f0ee; border-bottom: 1px solid #f1f0ee; font-weight: bold; padding: 0.6em 0.6em 0.6em 0.6em; }
			ul#maintabs { list-style-type: none; margin: 30px 0 0 0; padding: 0 0 1em 0; font-size: 14px; }
			ul#maintabs li { display: inline; }
      		ul#maintabs li a { color: #42454a; background-color: #dedbde; border: 1px solid #c9c3ba; padding: 1em; text-decoration: none; }
      		ul#maintabs li a:hover { background-color: #f1f0ee; }
      		ul#maintabs li a.selected { color: #000; background-color: #f1f0ee; font-weight: bold; padding: 1.4em 1.2em 1em 1.2em; }
      		div.tabContent { border: 1px solid #c9c3ba; padding: 0.5em; background-color: #f1f0ee; }
      		div.tabContent.hide { display: none; }
    	</style>
  	</head>
	"}
	dat += {"[content]</body></html>"}
	return dat

/obj/item/spellbook/attack_self(mob/user as mob)
	if(!owner)
		to_chat(user, "<span class='notice'>Вы привязываете книгу заклинаний к себе.</span>")
		owner = user
		return
	if(user != owner)
		to_chat(user, "<span class='warning'>[name] не признаёт вас как хозяина и отказывается открываться!</span>")
		return
	user.set_machine(src)
	var/dat = ""

	dat += "<ul id=\"maintabs\">"
	var/list/cat_dat = list()
	for(var/main_category in main_categories)
		cat_dat[main_category] = "<hr>"
		dat += "<li><a [main_tab==main_category?"class=selected":""] href='byond://?src=[UID()];mainpage=[main_category]'>[main_category]</a></li>"
	dat += "</ul>"
	dat += "<ul id=\"tabs\">"
	switch(main_tab)
		if("Spells")
			for(var/category in categories)
				if(category in spell_categories)
					cat_dat[category] = "<hr>"
					dat += "<li><a [tab==category?"class=selected":""] href='byond://?src=[UID()];page=[category]'>[category]</a></li>"
		if("Magical Items")
			for(var/category in categories)
				if(category in item_categories)
					cat_dat[category] = "<hr>"
					dat += "<li><a [tab==category?"class=selected":""] href='byond://?src=[UID()];page=[category]'>[category]</a></li>"
		if("Loadouts")
			for(var/category in categories)
				if(category in loadout_categories)
					cat_dat[category] = "<hr>"
					dat += "<li><a [tab==category?"class=selected":""] href='byond://?src=[UID()];page=[category]'>[category]</a></li>"
	dat += "<li><a><b>Points remaining : [uses]</b></a></li>"
	dat += "</ul>"

	var/datum/spellbook_entry/E
	for(var/i=1,i<=entries.len,i++)
		var/spell_info = ""
		E = entries[i]
		spell_info += E.GetInfo()
		if(E.CanBuy(user,src))
			spell_info+= "<a href='byond://?src=[UID()];buy=[i]'>[E.buy_word]</A><br>"
		else
			spell_info+= "<span>Can't [E.buy_word]</span><br>"
		if(E.CanRefund(user,src))
			spell_info+= "<a href='byond://?src=[UID()];refund=[i]'>Refund</A><br>"
		spell_info += "<hr>"
		if(cat_dat[E.category])
			cat_dat[E.category] += spell_info

	for(var/category in categories)
		dat += "<div class=\"[tab==category?"tabContent":"tabContent hide"]\" id=\"[category]\">"
		dat += GetCategoryHeader(category)
		dat += cat_dat[category]
		dat += "</div>"

	user << browse(wrap(dat), "window=spellbook;size=800x600")
	onclose(user, "spellbook")
	return

/obj/item/spellbook/Topic(href, href_list)
	if(..())
		return 1
	var/mob/living/carbon/human/H = usr

	if(!ishuman(H))
		return 1

	if(H.mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE)
		temp = "Если учитель узнает, что ты сунул свой нос в его книгу заклинаний, тебя, скорее всего, исключат из Академии волшебников. Лучше не стоит."
		return 1

	var/datum/spellbook_entry/E = null
	if(loc == H || (in_range(src, H) && istype(loc, /turf)))
		H.set_machine(src)
		if(href_list["buy"])
			E = entries[text2num(href_list["buy"])]
			if(E && E.CanBuy(H,src))
				if(E.Buy(H,src))
					if(E.limit)
						E.limit--
					uses -= E.cost
		else if(href_list["refund"])
			E = entries[text2num(href_list["refund"])]
			if(E && E.refundable)
				var/result = E.Refund(H,src)
				if(result > 0)
					if(!isnull(E.limit))
						E.limit += result
					uses += result
		else if(href_list["mainpage"])
			main_tab = sanitize(href_list["mainpage"])
			tab = sanitize(href_list["page"])
			if(main_tab == "Spells")
				tab = spell_categories[1]
			else if(main_tab == "Magical Items")
				tab = item_categories[1]
			else if(main_tab == "Loadouts")
				tab = loadout_categories[1]
		else if(href_list["page"])
			tab = sanitize(href_list["page"])
	attack_self(H)
	return 1

//Single Use Spellbooks
/obj/item/spellbook/oneuse
	var/spell = /obj/effect/proc_holder/spell/projectile/magic_missile //just a placeholder to avoid runtimes if someone spawned the generic
	var/spellname = "sandbox"
	var/used = 0
	name = "книга заклинаний "
	uses = 1
	desc = "Эта книга заклинаний никогда не предназначалась для глаз человека..."

/obj/item/spellbook/oneuse/New()
	..()
	name += spellname

/obj/item/spellbook/oneuse/initialize() //No need to init
	return

/obj/item/spellbook/oneuse/attack_self(mob/user)
	var/obj/effect/proc_holder/spell/S = new spell
	for(var/obj/effect/proc_holder/spell/knownspell as anything in user.mind.spell_list)
		if(knownspell.type == S.type)
			if(user.mind)
				if(user.mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE || user.mind.special_role == SPECIAL_ROLE_WIZARD)
					to_chat(user, "<span class='notice'>Вы гораздо лучше разбираетесь в этом заклинании, чем эта жалкая бумажка.</span>")
				else
					to_chat(user, "<span class='notice'>Эту книгу вы уже читали.</span>")
			return
	if(used)
		recoil(user)
	else
		user.mind.AddSpell(S)
		to_chat(user, "<span class='notice'>вы быстро пролистываете книгу заклинаний. Неожиданно вы осознаёте, что понимаете [spellname]!</span>")
		add_misc_logs(user, "learned the spell [spellname] ([S])")
		onlearned(user)

/obj/item/spellbook/oneuse/proc/recoil(mob/user)
	user.visible_message("<span class='warning'>[src] светится чёрным светом!</span>")

/obj/item/spellbook/oneuse/proc/onlearned(mob/user)
	used = 1
	user.visible_message("<span class='caution'>[src] на мгновение сверкнул чёрным светом!</span>")

/obj/item/spellbook/oneuse/attackby()
	return

/obj/item/spellbook/oneuse/fireball
	spell = /obj/effect/proc_holder/spell/fireball
	spellname = "fireball"
	icon_state = "bookfireball"
	desc = "Эта книга кажется тёплой на ощупь."

/obj/item/spellbook/oneuse/fireball/recoil(mob/user as mob)
	..()
	explosion(user.loc, -1, 0, 2, 3, 0, flame_range = 2, cause = "Recoiled fireball book")
	qdel(src)

/obj/item/spellbook/oneuse/smoke
	spell = /obj/effect/proc_holder/spell/smoke
	spellname = "smoke"
	icon_state = "booksmoke"
	desc = "Эта книга переполнена темными искусствами."

/obj/item/spellbook/oneuse/smoke/recoil(mob/user as mob)
	..()
	to_chat(user, "<span class='caution'>Ваш желудок урчит...</span>")
	user.adjust_nutrition(-200)

/obj/item/spellbook/oneuse/blind
	spell = /obj/effect/proc_holder/spell/trigger/blind
	spellname = "blind"
	icon_state = "bookblind"
	desc = "Эта книга кажется размытой в пространстве, как бы вы не пытались сосредоточить взгляд."

/obj/item/spellbook/oneuse/blind/recoil(mob/user)
	..()
	if(isliving(user))
		var/mob/living/L = user
		to_chat(user, "<span class='warning'>Вы слепнете!</span>")
		L.EyeBlind(20 SECONDS)

/obj/item/spellbook/oneuse/mindswap
	spell = /obj/effect/proc_holder/spell/mind_transfer
	spellname = "mindswap"
	icon_state = "bookmindswap"
	desc = "Обложка этой книги нетронута, хотя ее страницы выглядят потрепанными."
	var/mob/stored_swap = null //Used in used book recoils to store an identity for mindswaps

/obj/item/spellbook/oneuse/mindswap/onlearned()
	spellname = pick("fireball","smoke","blind","forcewall","knock","horses","charge")
	icon_state = "book[spellname]"
	name = "spellbook of [spellname]" //Note, desc doesn't change by design
	..()

/obj/item/spellbook/oneuse/mindswap/recoil(mob/user)
	..()
	if(stored_swap in GLOB.dead_mob_list)
		stored_swap = null
	if(!stored_swap)
		stored_swap = user
		to_chat(user, "<span class='warning'>На мгновение тебе кажется, что ты даже не знаешь, кто ты такой.</span>")
		return
	if(stored_swap == user)
		to_chat(user, "<span class='notice'>Ты пытаешься вглядеться в книгу, но, похоже, там больше нечего изучать...</span>")
		return

	var/obj/effect/proc_holder/spell/mind_transfer/swapper = new
	swapper.cast(user, stored_swap)

	to_chat(stored_swap, "<span class='warning'>Ты внезапно оказываешься в другом месте... и в другом теле?!</span>")
	to_chat(user, "<span class='warning'>Внезапно ты снова смотришь на [src]... где ты, кто ты?!</span>")
	stored_swap = null

/obj/item/spellbook/oneuse/forcewall
	spell = /obj/effect/proc_holder/spell/forcewall
	spellname = "forcewall"
	icon_state = "bookforcewall"
	desc = "На обложке этой книги всё кричит о любви к мимам."

/obj/item/spellbook/oneuse/forcewall/recoil(mob/user as mob)
	..()
	to_chat(user, "<span class='warning'>Ты вдруг чувствуешь себя очень твердым!</span>")
	var/obj/structure/closet/statue/S = new /obj/structure/closet/statue(user.loc, user)
	S.timer = 30
	user.drop_from_active_hand()

/obj/item/spellbook/oneuse/knock
	spell = /obj/effect/proc_holder/spell/aoe/knock
	spellname = "knock"
	icon_state = "bookknock"
	desc = "Эту книгу сложно нормально закрыть."

/obj/item/spellbook/oneuse/knock/recoil(mob/living/user)
	..()
	to_chat(user, "<span class='warning'>You're knocked down!</span>")
	user.Weaken(40 SECONDS)

/obj/item/spellbook/oneuse/horsemask
	spell = /obj/effect/proc_holder/spell/horsemask
	spellname = "horses"
	icon_state = "bookhorses"
	desc = "В этой книге больше лошадиного, чем может вместить ваш разум."

/obj/item/spellbook/oneuse/horsemask/recoil(mob/living/carbon/user)
	if(ishuman(user))
		to_chat(user, "<font size='15' color='red'><b>ХОР-СИ ВОССТАЛ</b></font>")
		var/obj/item/clothing/mask/horsehead/magichead = new /obj/item/clothing/mask/horsehead
		ADD_TRAIT(magichead, TRAIT_NODROP, CURSED_ITEM_TRAIT(magichead.type))
		magichead.item_flags |= DROPDEL	//curses!
		magichead.flags_inv &= ~HIDENAME	//so you can still see their face
		magichead.voicechange = TRUE	//NEEEEIIGHH
		if(!user.drop_item_ground(user.wear_mask))
			qdel(user.wear_mask)
		user.equip_to_slot_or_del(magichead, ITEM_SLOT_MASK)
		qdel(src)
	else
		to_chat(user, "<span class='notice'>I say thee neigh</span>")

/obj/item/spellbook/oneuse/charge
	spell = /obj/effect/proc_holder/spell/charge
	spellname = "charging"
	icon_state = "bookcharge"
	desc = "Эта книга на 100% сделана из постпотребительского Мага."

/obj/item/spellbook/oneuse/charge/recoil(mob/user)
	..()
	to_chat(user, "<span class='warning'>[src] внезапно кажется очень тёплым!</span>")
	empulse(src, 1, 1)

/obj/item/spellbook/oneuse/summonitem
	spell = /obj/effect/proc_holder/spell/summonitem
	spellname = "instant summons"
	icon_state = "booksummons"
	desc = "Эта книга яркая и броская, её трудно не заметить."

/obj/item/spellbook/oneuse/summonitem/recoil(mob/user)
	..()
	to_chat(user, "<span class='warning'>[src] неожиданно исчезает!</span>")
	qdel(src)

/obj/item/spellbook/oneuse/fake_gib
	spell = /obj/effect/proc_holder/spell/touch/fake_disintegrate
	spellname = "disintegrate"
	icon_state = "bookfireball"
	desc = "Эта книга выглядит так, будто её прочтение уничтожит всё вокруг."

/obj/item/spellbook/oneuse/sacredflame
	spell = /obj/effect/proc_holder/spell/sacred_flame
	spellname = "sacred flame"
	icon_state = "booksacredflame"
	desc = "Станьте единым с пламенем, что выжигает вас изнутри... и не забудьте порекомендовать то же остальным."

/obj/item/spellbook/oneuse/goliath_dash
	spell = /obj/effect/proc_holder/spell/goliath_dash
	spellname = "goliath dash"
	icon_state = "bookgoliathdash"
	desc = "Мчись, как голиаф!"

/obj/item/spellbook/oneuse/watchers_look
	spell = /obj/effect/proc_holder/spell/watchers_look
	spellname = "watcher's look"
	icon_state = "bookwatcherlook"
	desc = "Стреляй из глаз как Наблюдатель!"

/obj/item/spellbook/oneuse/random
	icon_state = "random_book"

/obj/item/spellbook/oneuse/random/Initialize()
	. = ..()
	var/static/banned_spells = list(/obj/item/spellbook/oneuse/mime, /obj/item/spellbook/oneuse/mime/fingergun, /obj/item/spellbook/oneuse/mime/fingergun/fake, /obj/item/spellbook/oneuse/mime/greaterwall, /obj/item/spellbook/oneuse/fake_gib, /obj/item/spellbook/oneuse/emp/used)
	var/real_type = pick(subtypesof(/obj/item/spellbook/oneuse) - banned_spells)
	new real_type(loc)
	qdel(src)
