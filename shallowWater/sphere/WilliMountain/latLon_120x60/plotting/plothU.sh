#!/bin/bash -e

if [ "$#" -ne 1 ]; then
   echo usage: plothU time
   exit
fi
time=$1
outFile=$time/hU
echo plotting $outFile.eps.gz

# Write out the data in lat-lon co-ordinates
sumFields $time hTotal $time h constant h0 > plotting/plothU.out
writeCellDataLatLon -constant h0 >> plotting/plothU.out
writeCellDataLatLon -time $time hTotal >> plotting/plothU.out
writeCellDataLatLon -time $time U >> plotting/plothU.out
# Sample the velocity field (can't plot every vector)
awk 'NR % 13 == 1' $time/U.latLon > $time/U.latLonS

gmt info $time/hTotal.latLon
gmt info constant/h0.latLon
gmt info $time/U.latLon

# Set up the plot
gmt psbasemap -R0/360/-90/90 -JQ0/18c -B -K > $outFile.ps

# Create colours for the total height and plot
gmt makecpt -Cjet -D -T5000/6000/50 > plotting/hcontours.cpt
gmt pscontour $time/hTotal.latLon -J -R \
    -Cplotting/hcontours.cpt -A- -I -h1 -K -O >> $outFile.ps

# Create contours for the mountain and plot
gmt makecpt -N -T100/2100/200 > plotting/h0contours.cpt
gmt pscontour constant/h0.latLon -J -R \
    -Cplotting/h0contours.cpt -A- -W -h1 -K -O >> $outFile.ps

# Plot the wind
gmt psxy $time/U.latLonS -J -R -h1 -SV1+e+n3+z0.1 -Wblack -K -O >> $outFile.ps

# Finalise the plot
gmt psbasemap -R -J -B60/60 -O >> $outFile.ps
ps2eps $outFile.ps >> plotting/plothU.out 2>&1
gzip -f $outFile.eps
evince $outFile.eps.gz &

# Tidy up
rm constant/h0.latLon $time/hTotal.latLon $time/U.latLon* $outFile.ps

