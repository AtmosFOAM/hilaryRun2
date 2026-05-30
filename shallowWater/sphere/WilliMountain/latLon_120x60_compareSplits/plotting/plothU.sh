#!/bin/bash -e

if [ "$#" -lt 1 ]; then
   echo usage: plothU time [case]
   exit
fi
time=$1
case=.
if [ "$#" -eq 2 ]; then case=$2; fi

outFile=$case/$time/hU
echo plotting $outFile.eps.gz. Errors going to plotting/plothU.out
mkdir -p plotting

# Write out the data in lat-lon co-ordinates
sumFields -case $case $time hTotal $time h constant h0 > plotting/plothU.out
writeCellDataLatLon -case $case -constant h0 >> plotting/plothU.out
writeCellDataLatLon -case $case -time $time hTotal >> plotting/plothU.out
writeCellDataLatLon -case $case -time $time U >> plotting/plothU.out
# Sample the velocity field (can't plot every vector)
awk 'NR % 13 == 1' $case/$time/U.latLon > $case/$time/U.latLonS

gmt info $case/$time/hTotal.latLon
gmt info $case/constant/h0.latLon
gmt info $case/$time/U.latLon

# Set up the plot
gmt set MAP_FRAME_TYPE plain
gmt psbasemap -R0/360/-90/90 -JQ0/18c -B60/60 -K > $outFile.ps

# Create colours for the total height and plot
gmt makecpt -Cjet -D -T5000/6000/50 > plotting/hcontours.cpt
#gmt makecpt -Cjet -D -T-2050/2050/100 > plotting/hcontours.cpt
gmt pscontour $case/$time/hTotal.latLon -R0/360/-90/90 -JQ0/18c \
    -Cplotting/hcontours.cpt -A- -I -h1 -K -O >> $outFile.ps

# Create contours for the mountain and plot
gmt makecpt -N -T100/2100/200 > plotting/h0contours.cpt
gmt pscontour $case/constant/h0.latLon -R0/360/-90/90 -JQ0/18c \
    -Cplotting/h0contours.cpt -A- -W -h1 -K -O >> $outFile.ps

# Plot the wind
gmt psxy $case/$time/U.latLonS -R0/360/-90/90 -JQ0/18c -h1 -SV1+e+n3+z0.1 -Wblack -K -O >> $outFile.ps

# Add scale to plot
gmt psclip -C -O -K >> $outFile.ps
gmt psscale -Cplotting/hcontours.cpt -DJBC+w18c/0.5c+h+o0c/1c -R0/360/-90/90 -JQ0/18c -Bxaf -O >> $outFile.ps

rm $case/constant/*.latLon* $case/$time/*.latLon*

# Finalise the plot
#gmt psbasemap -R -J -B60/60 -O >> $outFile.ps
ps2eps -O $outFile.ps >> plotting/plothU.out 2>&1
convert -flatten -density 300 -rotate 90 $outFile.eps $case/$time/hUplot.jpg
gzip -f $outFile.eps
evince $outFile.eps.gz &

# Tidy up
rm $outFile.ps

