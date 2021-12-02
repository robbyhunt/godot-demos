# Using `class_name` allows us to access the constants from any other file.
extends Reference
class_name Types

# This is the same enum we wrote in the ActionData classes.
enum Elements { NONE, CODE, DESIGN, ART, BUG }

# Mapping between an element and the element against which it's strong.
const WEAKNESS_MAPPING = {
	# A value of -1 makes the element strong or weak against nothing.
	Elements.NONE: -1,
	# For example, the line below means that code is strong against art.
	Elements.CODE: Elements.ART,
	Elements.ART: Elements.DESIGN,
	Elements.DESIGN: Elements.CODE,
	Elements.BUG: -1,
}
