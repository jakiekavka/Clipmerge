#!/bin/bash
while true; do
    if [ -f /tmp/clipmerge_sound ]; then
        rm -f /tmp/clipmerge_sound
        afplay /System/Library/Sounds/Pop.aiff
    fi
    sleep 0.2
done
