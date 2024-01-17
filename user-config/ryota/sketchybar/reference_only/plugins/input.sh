#!/usr/bin/env sh

SOURCE=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleCurrentKeyboardLayoutInputSourceID)

case ${SOURCE} in
'com.apple.keylayout.US') LABEL='あ' ;;
'com.apple.keylayout.ABC') LABEL='US' ;;
'com.apple.keylayout.DVORAK-QWERTYCMD') LABEL='DV' ;;
esac

sketchybar --set "$NAME" label="$LABEL"
