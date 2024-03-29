#!/usr/bin/env sh

sketchybar --add item clock right \
	--set clock update_freq=1 \
	icon.padding_left=10 \
	icon.color="$LOVE" \
	label.color="$LOVE" \
	label.padding_right=5 \
	label.width=78 \
	align=center \
	script="$PLUGIN_DIR/clock.sh" \
	background.height=24 \
	background.color="$SURFACE" \
	background.corner_radius="$CORNER_RADIUS" \
	background.padding_right=10
