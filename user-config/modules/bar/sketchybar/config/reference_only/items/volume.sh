#!/usr/bin/env sh

sketchybar \
	--add item sound right \
	--set sound \
	update_freq=5 \
	icon.color="$LOVE" \
	icon.padding_left=10 \
	label.color="$LOVE" \
	label.padding_right=10 \
	background.color="$SURFACE" \
	background.height=26 \
	background.corner_radius="$CORNER_RADIUS" \
	background.padding_right=5 \
	script="$PLUGIN_DIR/sound.sh"
