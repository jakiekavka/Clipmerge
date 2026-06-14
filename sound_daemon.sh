#!/bin/bash
while true; do
    if [ -f /tmp/clipmerge_sound ]; then
        rm -f /tmp/clipmerge_sound
        say -v Tingting 叮
    fi
    sleep 0.2
done
