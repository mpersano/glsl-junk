#!/bin/bash

NUM_FRAMES=40

./demo -n $NUM_FRAMES $@

for i in $( seq 1 $NUM_FRAMES ); do
	convert frame-$( printf "%03d" $i ).ppm -flip frame-$( printf "%03d" $i ).gif
done

gifsicle --colors=256 --delay=5 --loop frame-*gif > clip.gif
