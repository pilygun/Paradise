

/obj/item/clothing/head/centhat
	name = "\improper CentComm. hat"
	icon_state = "centcom"
	desc = "It's good to be emperor."
	item_state = "centhat"
	armor = list("melee" = 30, "bullet" = 15, "laser" = 30, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	strip_delay = 80

/obj/item/clothing/head/hairflower
	name = "hair flower pin"
	icon_state = "hairflower"
	desc = "Smells nice."
	item_state = "hairflower"

/obj/item/clothing/head/powdered_wig
	name = "powdered wig"
	desc = "A powdered wig."
	icon_state = "pwig"
	item_state = "pwig"

/obj/item/clothing/head/justice_wig
	name = "Justice wig"
	desc = "A fancy powdered wig given to arbitrators of the law. It looks itchy."
	icon_state = "jwig"
	item_state = "jwig"

/obj/item/clothing/head/beret/blue
	icon_state = "beret_blue"

/obj/item/clothing/head/beret/black
	icon_state = "beret_black"

/obj/item/clothing/head/beret/purple_normal
	icon_state = "beret_purple_normal"

/obj/item/clothing/head/that
	name = "top-hat"
	desc = "It's an amish looking hat."
	icon_state = "tophat"
	item_state = "that"
	dog_fashion = /datum/dog_fashion/head

/obj/item/clothing/head/redcoat
	name = "redcoat's hat"
	icon_state = "redcoat"
	desc = "<i>'I guess it's a redhead.'</i>"

/obj/item/clothing/head/mailman
	name = "mailman's hat"
	icon_state = "mailman"
	desc = "<i>'Right-on-time'</i> mail service head wear."

/obj/item/clothing/head/plaguedoctorhat
	name = "plague doctor's hat"
	desc = "These were once used by Plague doctors. They're pretty much useless."
	icon_state = "plaguedoctor"
	permeability_coefficient = 0.01

/obj/item/clothing/head/hasturhood
	name = "hastur's hood"
	desc = "It's unspeakably stylish"
	icon_state = "hasturhood"
	flags_inv = HIDEHAIR
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/nursehat
	name = "nurse's hat"
	desc = "It allows quick identification of trained medical personnel."
	icon_state = "nursehat"
	dog_fashion = /datum/dog_fashion/head/nurse

/obj/item/clothing/head/syndicatefake
	name = "black and red space-helmet replica"
	icon_state = "syndicate-helm-black-red"
	item_state = "syndicate-helm-black-red"
	desc = "A plastic replica of a syndicate agent's space helmet, you'll look just like a real murderous syndicate agent in this! This is a toy, it is not made for use in space!"
	flags_inv = HIDEMASK|HIDEHEADSETS|HIDEGLASSES|HIDENAME|HIDEHAIR

	sprite_sheets = list(
		SPECIES_GREY = 'icons/mob/clothing/species/grey/helmet.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi'
	)


/obj/item/clothing/head/cueball
	name = "cueball helmet"
	desc = "A large, featureless white orb meant to be worn on your head. How do you even see out of this thing?"
	icon_state = "cueball"
	item_state = "cueball"
	flags_inv = HIDEMASK|HIDEHEADSETS|HIDEGLASSES|HIDENAME|HIDEHAIR
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

	sprite_sheets = list(
		SPECIES_GREY = 'icons/mob/clothing/species/grey/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi'
	)

/obj/item/clothing/head/snowman
	name = "snowman head"
	desc = "A ball of white styrofoam. So festive."
	icon_state = "snowman_h"
	item_state = "snowman_h"
	flags_inv = HIDEMASK|HIDEHEADSETS|HIDEGLASSES|HIDENAME|HIDEHAIR
	flags_cover = HEADCOVERSEYES|HEADCOVERSMOUTH

	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi'
	)

/obj/item/clothing/head/that
	name = "sturdy top-hat"
	desc = "It's an amish looking armored top hat."
	icon_state = "tophat"
	item_state = "that"


/obj/item/clothing/head/greenbandana
	name = "green bandana"
	desc = "It's a green bandana with some fine nanotech lining."
	icon_state = "greenbandana"
	item_state = "greenbandana"


/obj/item/clothing/head/justice
	name = "justice hat"
	desc = "Fight for what's righteous!"
	icon_state = "justicered"
	item_state = "justicered"
	flags_inv = HIDEHAIR
	flags_cover = HEADCOVERSEYES|HEADCOVERSMOUTH

/obj/item/clothing/head/justice/blue
	icon_state = "justiceblue"
	item_state = "justiceblue"

/obj/item/clothing/head/justice/yellow
	icon_state = "justiceyellow"
	item_state = "justiceyellow"

/obj/item/clothing/head/justice/green
	icon_state = "justicegreen"
	item_state = "justicegreen"

/obj/item/clothing/head/justice/pink
	icon_state = "justicepink"
	item_state = "justicepink"

/obj/item/clothing/head/rabbitears
	name = "rabbit ears"
	desc = "Wearing these makes you look useless, and only good for your sex appeal."
	icon_state = "bunny"
	dog_fashion = /datum/dog_fashion/head/rabbit

/obj/item/clothing/head/flatcap
	name = "flat cap"
	desc = "A working man's cap."
	icon_state = "flat_cap"
	item_state = "detective"

/obj/item/clothing/head/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	dog_fashion = /datum/dog_fashion/head/pirate

/obj/item/clothing/head/hgpiratecap
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "hgpiratecap"
	item_state = "hgpiratecap"

/obj/item/clothing/head/bandana
	name = "pirate bandana"
	desc = "Yarr."
	icon_state = "bandana"
	item_state = "bandana"

//stylish bs12 hats

/obj/item/clothing/head/bowlerhat
	name = "bowler hat"
	icon_state = "bowler_hat"
	item_state = "bowler_hat"
	desc = "For that industrial age look."

/obj/item/clothing/head/beaverhat
	name = "beaver hat"
	icon_state = "beaver_hat"
	item_state = "beaver_hat"
	desc = "Like a top hat, but made of beavers."

/obj/item/clothing/head/boaterhat
	name = "boater hat"
	icon_state = "boater_hat"
	item_state = "boater_hat"
	desc = "Goes well with celery."

/obj/item/clothing/head/cowboyhat
	name = "cowboy hat"
	icon_state = "cowboyhat"
	item_state = "cowboyhat"
	desc = "For the Rancher in us all."

/obj/item/clothing/head/cowboyhat/tan
	name = "tan cowboy hat"
	icon_state = "cowboyhat_tan"
	item_state = "cowboyhat_tan"
	desc = "There's a new sheriff in town. Pass the whiskey."

/obj/item/clothing/head/cowboyhat/black
	name = "black cowboy hat"
	icon_state = "cowboyhat_black"
	item_state = "cowboyhat_black"
	desc = "This station ain't big enough for the two ah' us."

/obj/item/clothing/head/cowboyhat/white
	name = "white cowboy hat"
	icon_state = "cowboyhat_white"
	item_state = "cowboyhat_white"
	desc = "Authentic Marshall hair case. Now ya can protect this here homestead. Navy Model not included."

/obj/item/clothing/head/cowboyhat/pink
	name = "cowgirl hat"
	icon_state = "cowboyhat_pink"
	item_state = "cowboyhat_pink"
	desc = "For those buckle bunnies wanta' become a real buckaroo."

/obj/item/clothing/head/fedora
	name = "fedora"
	icon_state = "fedora"
	item_state = "fedora"
	desc = "A great hat ruined by being within fifty yards of you."
	actions_types = list(/datum/action/item_action/tip_fedora)

/obj/item/clothing/head/fedora/attack_self(mob/user)
	tip_fedora(user)

/obj/item/clothing/head/fedora/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_HEAD)
		return TRUE

/obj/item/clothing/head/fedora/proc/tip_fedora(mob/user)
	user.custom_emote(EMOTE_VISIBLE, "приподнима[pluralize_ru(user.gender,"ет","ют")] федору.")

/obj/item/clothing/head/fez
	name = "fez"
	icon_state = "fez"
	item_state = "fez"
	desc = "Put it on your monkey, make lots of cash money."

//end bs12 hats

/obj/item/clothing/head/witchwig
	name = "witch costume wig"
	desc = "Eeeee~heheheheheheh!"
	icon_state = "witch"
	item_state = "witch"
	flags_inv = HIDEHAIR

/obj/item/clothing/head/chicken
	name = "chicken suit head"
	desc = "Bkaw!"
	icon_state = "chickenhead"
	item_state = "chickensuit"
	flags_inv = HIDEHAIR
	flags_cover = HEADCOVERSMOUTH|HEADCOVERSEYES

	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi'
	)

/obj/item/clothing/head/corgi
	name = "corgi suit head"
	desc = "Woof!"
	icon_state = "corgihead"
	item_state = "chickensuit"
	flags_inv = HIDEHAIR
	flags_cover = HEADCOVERSMOUTH|HEADCOVERSEYES

/obj/item/clothing/head/corgi/super_hero
	name = "super-hero corgi suit head"
	desc = "Woof! This one seems to pulse with a strange power"


/obj/item/clothing/head/corgi/super_hero/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


/obj/item/clothing/head/corgi/super_hero/en
	name = "E-N suit head"
	icon_state = "enhead"

/obj/item/clothing/head/bearpelt
	name = "bear pelt hat"
	desc = "Fuzzy."
	icon_state = "bearpelt"
	item_state = "bearpelt"
	flags_inv = HIDEHAIR

/obj/item/clothing/head/corgipelt
	name = "corgi pelt hat"
	desc = "What have i done."
	icon_state = "corgipelt"
	item_state = "corgipelt"
	flags_inv = HIDEHAIR

/obj/item/clothing/head/xenos
	name = "xenos helmet"
	icon_state = "xenos"
	item_state = "xenos_helm"
	desc = "A helmet made out of chitinous alien hide."
	flags_inv = HIDEMASK|HIDEHEADSETS|HIDEGLASSES|HIDENAME|HIDEHAIR
	flags_cover = HEADCOVERSMOUTH|HEADCOVERSEYES

/obj/item/clothing/head/fedora
	name = "fedora"
	desc = "Someone wearing this definitely makes them cool"
	icon_state = "fedora"

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi'
	)

/obj/item/clothing/head/fedora/whitefedora
	name = "white fedora"
	icon_state = "wfedora"

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi'
	)

/obj/item/clothing/head/fedora/brownfedora
	name = "brown fedora"
	icon_state = "bfedora"

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi'
	)

/obj/item/clothing/head/stalhelm
	name = "Clown Stalhelm"
	desc = "The typical clown soldier's helmet."
	icon_state = "stalhelm"
	item_state = "stalhelm"
	flags_inv = HIDEHEADSETS|HIDEHAIR

/obj/item/clothing/head/panzer
	name = "Clown HONKMech Cap"
	desc = "The softcap worn by HONK Mech pilots."
	icon_state = "panzercap"
	item_state = "panzercap"
	flags_inv = HIDEHAIR

/obj/item/clothing/head/naziofficer
	name = "Clown Officer Cap"
	desc = "The peaked clown officer's cap, disturbingly similar to the warden's."
	icon_state = "officercap"
	item_state = "officercap"
	flags_inv = HIDEHEADSETS|HIDEHAIR

/obj/item/clothing/head/beret/centcom/officer
	name = "officers beret"
	desc = "A black beret adorned with the shield—a silver kite shield with an engraved sword—of the Nanotrasen security forces, announcing to the world that the wearer is a defender of Nanotrasen."
	icon_state = "beret_centcom_officer"
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30,"energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 50)
	strip_delay = 60

/obj/item/clothing/head/beret/centcom/officer/navy
	name = "navy blue officers beret"
	desc = "A navy blue beret adorned with the shield—a silver kite shield with an engraved sword—of the Nanotrasen security forces, announcing to the world that the wearer is a defender of Nanotrasen."
	icon_state = "beret_centcom_officer_navy"
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30,"energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 50)
	strip_delay = 60

/obj/item/clothing/head/beret/centcom/officer/sparkyninja_beret
	name = "royal marines commando beret"
	desc = "Dark Green beret with an old insignia on it."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "sparkyninja_beret"

/obj/item/clothing/head/beret/centcom/officer/sigholt
	name = "marine lieutenant beret"
	desc = "This beret bears insignia of the SOLGOV Marine Corps 417th Regiment, 2nd Battalion, Bravo Company. It looks meticulously maintained."
	icon_state = "beret_hos"
	item_state = "beret_hos"

/obj/item/clothing/head/beret/centcom/captain
	name = "captains beret"
	desc = "A white beret adorned with the shield—a cobalt kite shield with an engraved sword—of the Nanotrasen security forces, worn only by those captaining a vessel of the Nanotrasen Navy."
	icon_state = "beret_centcom_captain"

/obj/item/clothing/head/sombrero
	name = "sombrero"
	icon_state = "sombrero"
	item_state = "sombrero"
	desc = "You can practically taste the fiesta."
	dog_fashion = /datum/dog_fashion/head/sombrero

/obj/item/clothing/head/sombrero/green
	name = "green sombrero"
	icon_state = "greensombrero"
	item_state = "greensombrero"
	desc = "As elegant as a dancing cactus."
	dog_fashion = null

/obj/item/clothing/head/sombrero/shamebrero
	name = "shamebrero"
	icon_state = "shamebrero"
	item_state = "shamebrero"
	desc = "Once it's on, it never comes off."
	dog_fashion = null


/obj/item/clothing/head/sombrero/shamebrero/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


/obj/item/clothing/head/cone
	desc = "This cone is trying to warn you of something!"
	name = "warning cone"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cone"
	item_state = "cone"
	force = 1.0
	throwforce = 3.0
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("warned", "cautioned", "smashed")
	resistance_flags = NONE
	dog_fashion = /datum/dog_fashion/head/cone

/obj/item/clothing/head/jester
	name = "jester hat"
	desc = "A hat with bells, to add some merryness to the suit."
	icon_state = "jester_hat"

/obj/item/clothing/head/rockso
	name = "Rockso Hat"
	desc = "I'M B-B-B-B-B-B-B-B-BACK, BABY!"
	icon_state = "rocksohat"
	item_state = "rocksohat"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/head.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/head.dmi',
		SPECIES_KIDAN = 'icons/mob/clothing/species/kidan/head.dmi',
		SPECIES_WRYN = 'icons/mob/clothing/species/wryn/head.dmi'
	)

/obj/item/clothing/head/rice_hat
	name = "rice hat"
	desc = "Welcome to the rice fields, motherfucker."
	icon_state = "rice_hat"

/obj/item/clothing/head/griffin
	name = "griffon head"
	desc = "Why not 'eagle head'? Who knows."
	icon_state = "griffinhat"
	item_state = "griffinhat"
	flags_inv = HIDEMASK|HIDEHEADSETS|HIDEGLASSES|HIDENAME|HIDEHAIR
	flags_cover = HEADCOVERSMOUTH|HEADCOVERSEYES

	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi'
	)
	actions_types = list(/datum/action/item_action/caw)

/obj/item/clothing/head/griffin/attack_self()
	caw()

/obj/item/clothing/head/griffin/proc/caw()
	if(cooldown < world.time - 20) // A cooldown, to stop people being jerks
		playsound(src.loc, 'sound/creatures/caw.ogg', 50, 1)
		cooldown = world.time


/obj/item/clothing/head/lordadmiralhat
	name = "Lord Admiral's Hat"
	desc = "A hat suitable for any man of high and exalted rank."
	icon_state = "lordadmiralhat"
	item_state = "lordadmiralhat"

/obj/item/clothing/head/human_head
	name = "bloated human head"
	desc = "A horribly bloated and mismatched human head."
	icon_state = "lingspacehelmet"
	item_state = "lingspacehelmet"
	flags_cover = MASKCOVERSEYES|MASKCOVERSMOUTH

/obj/item/clothing/head/papersack
	name = "paper sack hat"
	desc = "A paper sack with crude holes cut out for eyes. Useful for hiding one's identity or ugliness."
	icon_state = "papersack"
	flags_inv = HIDENAME|HIDEHEADSETS|HIDEHAIR

	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi'
	)

/obj/item/clothing/head/papersack/smiley
	name = "paper sack hat"
	desc = "A paper sack with crude holes cut out for eyes and a sketchy smile drawn on the front. Not creepy at all."
	icon_state = "papersack_smile"

	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi'
	)

/obj/item/clothing/head/crown
	name = "crown"
	desc = "A crown fit for a king, a petty king maybe."
	icon_state = "crown"
	armor = list("melee" = 15, "bullet" = 0, "laser" = 0,"energy" = 15, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50)
	resistance_flags = FIRE_PROOF

/obj/item/clothing/head/crown/fancy
	name = "magnificent crown"
	desc = "A crown worn by only the highest emperors of the land."
	icon_state = "fancycrown"

/obj/item/clothing/head/zepelli
	name = "chequered diamond hat"
	desc = "Wearing this makes you feel like a real mozzarella cheeseball. "
	icon_state = "zepelli"
	item_state = "zepelli"

/obj/item/clothing/head/cuban_hat
	name = "rhumba hat"
	desc = "Now just to find some maracas!"
	icon_state = "cuban_hat"
	item_state = "cuban_hat"

/obj/item/clothing/head/shamanash
	name = "shaman skull"
	desc = "The skull of a long dead animal bolted to the front of a repurposed pan."
	icon_state = "shamskull"
	species_restricted = list(SPECIES_UNATHI, SPECIES_ASHWALKER_BASIC, SPECIES_ASHWALKER_SHAMAN, SPECIES_DRACONOID)

/obj/item/clothing/head/mr_chang_band
	name = "Tight headband"
	desc = "It is a safety tool, designed to prevent all marketing and selling techniques from escaping the wearers skull. Handle with care."
	w_class = WEIGHT_CLASS_TINY
	icon_state = "mr_chang_band"
	item_state = "mr_chang_band"

/obj/item/clothing/head/commando
	name = "Red headband"
	desc = "Simple red headband. Is that blood stains on it?"
	w_class = WEIGHT_CLASS_TINY
	icon_state = "commandos_band"
	item_state = "commandos_band"

/obj/item/clothing/head/flower_crown
	name = "flower crown"
	desc = "A colorful flower crown made out of lilies, sunflowers and poppies."
	icon_state = "flower_crown"
	item_state = "flower_crown"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/head.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/head.dmi'
		)

/obj/item/clothing/head/sunflower_crown
	name = "sunflower crown"
	desc = "A bright flower crown made out sunflowers that is sure to brighten up anyone's day!"
	icon_state = "sunflower_crown"
	item_state = "sunflower_crown"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/head.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/head.dmi'
		)

/obj/item/clothing/head/poppy_crown
	name = "poppy crown"
	desc = "A flower crown made out of a string of bright red poppies."
	icon_state = "poppy_crown"
	item_state = "poppy_crown"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/head.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/head.dmi'
		)

/obj/item/clothing/head/lily_crown
	name = "lily crown"
	desc = "A leafy flower crown with a cluster of large white lilies at the front."
	icon_state = "lily_crown"
	item_state = "lily_crown"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/head.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/head.dmi'
		)

/obj/item/clothing/head/geranium_crown
	name = "geranium crown"
	desc = "A flower crown made out of an array of rich purple geraniums."
	icon_state = "geranium_crown"
	item_state = "geranium_crown"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/head.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/head.dmi'
		)
