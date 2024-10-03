#!/usr/bin/env sh

. "./icons.sh"

ICON="󰅐"
LABEL=$(date '+%H:%M:%S')
sketchybar --set "$NAME" icon="$ICON" label="$LABEL"
