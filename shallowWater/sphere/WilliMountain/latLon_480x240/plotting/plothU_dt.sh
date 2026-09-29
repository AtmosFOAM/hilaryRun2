#!/bin/bash -e

if [ "$#" -ne 2 ]; then
   echo usage: plothU_dt time dt
   exit
fi
time=$1
dt=$2
outFile=$time/hU_$dt
echo plotting $outFile.eps.gz. Errors going to plotting/plothU.out

# Write out the data in lat-lon co-ordinates
sumFields $time hTotal_$dt $time h_$dt constant h0 > plotting/plothU.out
writeCellDataLatLon -constant h0 >> plotting/plothU.out
writeCellDataLatLon -time $time hTotal_$dt >> plotting/plothU.out
writeCellDataLatLon -time $time U_$dt >> plotting/plothU.out
# Sample the velocity field (can't plot every vector)
awk 'NR % 13 == 1' $time/U_$dt.latLon > $time/U_$dt.latLonS

gmt info $time/hTotal_$dt.latLon
gmt info constant/h0.latLon
gmt info $time/U_$dt.latLon

# Set up the plot
gmt psbasemap -R0/360/-90/90 -JQ0/18c -B60/60 -K > $outFile.ps

# Create colours for the total height and plot
gmt makecpt -Cjet -D -T5000/6000/50 > plotting/hcontours.cpt
#gmt makecpt -Cjet -D -T-2050/2050/100 > plotting/hcontours.cpt
gmt pscontour $time/hTotal_$dt.latLon -R0/360/-90/90 -JQ0/18c \
    -Cplotting/hcontours.cpt -A- -I -h1 -K -O >> $outFile.ps

# Create contours for the mountain and plot
gmt makecpt -N -T100/2100/200 > plotting/h0contours.cpt
gmt pscontour constant/h0.latLon -R0/360/-90/90 -JQ0/18c \
    -Cplotting/h0contours.cpt -A- -W -h1 -K -O >> $outFile.ps

# Plot the wind
gmt psxy $time/U_$dt.latLonS -R0/360/-90/90 -JQ0/18c -h1 -SV1+e+n3+z0.1 -Wblack -K -O >> $outFile.ps

# Add scale to plot
gmt psclip -C -O -K >> $outFile.ps
gmt psscale -Cplotting/hcontours.cpt -DJTC+w5c/0.1c+h+o0c/1c -R0/360/-90/90 -JQ0/18c -Bxaf+l"total height, h" -O >> $outFile.ps

rm constant/*.latLon* $time/*.latLon*

# Finalise the plot
#gmt psbasemap -R -J -B60/60 -O >> $outFile.ps
ps2eps -O $outFile.ps >> plotting/plothU.out 2>&1
convert -flatten -density 300 -rotate 90 $outFile.eps $time"_$dt".jpg
gzip -f $outFile.eps
evince $outFile.eps.gz &

# Tidy up
rm $outFile.ps

