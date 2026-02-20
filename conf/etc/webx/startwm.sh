#!/bin/bash

resize_xorg()
{
  # Set the resolution to match the WebX client request
  OUTPUT=$(xrandr --query | awk '/ connected/{print $1; exit}')
  echo "Resizing X display to ${WEBX_START_WIDTH}x${WEBX_START_HEIGHT} on output ${OUTPUT}"  

  MODE_DETAILS=$(cvt $WEBX_START_WIDTH $WEBX_START_HEIGHT 60.0 | sed -n 's/Modeline "\(.*\)_.*"\(.*\)/\1\2/p')
  xrandr --newmode $MODE_DETAILS
  xrandr --addmode $OUTPUT ${WEBX_START_WIDTH}x${WEBX_START_HEIGHT}
  xrandr --output $OUTPUT --mode ${WEBX_START_WIDTH}x${WEBX_START_HEIGHT}
}

export XCURSOR_SIZE=24

resize_xorg

dbus-launch startxfce4
