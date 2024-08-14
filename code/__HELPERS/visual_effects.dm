/// Use this to set the base and ACTUAL pixel offsets of an object at the same time
/// You should always use this for pixel setting in typepaths, unless you want the map display to look different from in game
#define SET_BASE_PIXEL(x, y) \
	pixel_x = x; \
	base_pixel_x = x; \
	pixel_y = y; \
	base_pixel_y = y;


/**
 * Causes the passed atom / image to appear floating,
 * playing a simple animation where they move up and down by 2 pixels (looping)
 *
 * In most cases you should NOT call this manually, instead use [/datum/element/movetype_handler]!
 * This is just so you can apply the animation to things which can be animated but are not movables (like images)
 */
#define DO_FLOATING_ANIM(target) \
	animate(target, pixel_y = 2, time = 1 SECONDS, loop = -1, flags = ANIMATION_RELATIVE); \
	animate(pixel_y = -2, time = 1 SECONDS, flags = ANIMATION_RELATIVE)


/**
 * Stops the passed atom / image from appearing floating
 * (Living mobs also have a 'body_position_pixel_y_offset' variable that has to be taken into account here)
 *
 * In most cases you should NOT call this manually, instead use [/datum/element/movetype_handler]!
 * This is just so you can apply the animation to things which can be animated but are not movables (like images)
 */
#define STOP_FLOATING_ANIM(target) \
	var/final_pixel_y = 0; \
	if(ismovable(target)) { \
		var/atom/movable/movable_target = target; \
		final_pixel_y = movable_target.base_pixel_y; \
	}; \
	if(isliving(target)) { \
		var/mob/living/living_target = target; \
		final_pixel_y += living_target.body_position_pixel_y_offset; \
	}; \
	animate(target, pixel_y = final_pixel_y, time = 0.2 SECONDS)


/// The duration of the animate call in mob/living/update_transform
#define UPDATE_TRANSFORM_ANIMATION_TIME (0.2 SECONDS)

