#!/bin/bash -e

if [ "$#" -lt 1 ]; then
   echo usage: plothDiff.sh time [case] [refTime]
   exit
fi
time=$1
case=.
refTime=0
if [ "$#" -ge 2 ]; then case=$2; fi
if [ "$#" -ge 3 ]; then refTime=$3; fi

outFile=$case/$time/hDiff
errFile=plotting/plothDiff.out
echo plotting $outFile.eps.gz. Errors going to $errFile
mkdir -p plotting
rm -f  $errFile

# Differences from the reference time
ln -sf ../$refTime/h $case/$time/hRef
foamPostProcess -case $case -time $time -func \
            'subtract(fields=(h hRef),result=hDiff)' >> $errFile

# Total height
ln -sf ../constant/h0 $case/$time/h0
foamPostProcess -case $case -time $time -func \
            'add(fields=(h h0),result=hTotal)'  >> $errFile

# Write out the data in lat-lon co-ordinates
writeCellDataLatLon -case $case -constant h0 >> $errFile
writeCellDataLatLon -case $case -time $time hTotal >> $errFile
writeCellDataLatLon -case $case -time $time hDiff >> $errFile

gmt info $case/$time/hDiff.latLon
gmt info $case/$time/hTotal.latLon
gmt info $case/constant/h0.latLon

# Set up the plot
gmt set MAP_FRAME_TYPE plain
gmt psbasemap -R0/360/-90/90 -JQ0/18c -B60/60 -K > $outFile.ps

# Create colours for the height differences and plot
gmt makecpt -Cpolar -D -T-105/105/10 > plotting/hDiffcontours.cpt
gmt pscontour $case/$time/hDiff.latLon -R0/360/-90/90 -JQ0/18c \
    -Cplotting/hDiffcontours.cpt -A- -I -h1 -K -O >> $outFile.ps

# Create contours for the height and plot
gmt makecpt -N -T3000/7000/250 > plotting/h.cpt
gmt pscontour $case/$time/hTotal.latLon -R0/360/-90/90 -JQ0/18c \
    -Cplotting/h.cpt -A- -W -h1 -K -O >> $outFile.ps

# Create contours for the mountain and plot
gmt makecpt -N -T100/2100/200 > plotting/h0contours.cpt
gmt pscontour $case/constant/h0.latLon -R0/360/-90/90 -JQ0/18c \
    -Cplotting/h0contours.cpt -A- -W -h1 -K -O >> $outFile.ps

# Add scale to plot
gmt psclip -C -O -K >> $outFile.ps
gmt psscale -Cplotting/hDiffcontours.cpt -DJBC+w18c/0.5c+h+o0c/1c \
    -R0/360/-90/90 -JQ0/18c -Bxaf -O >> $outFile.ps

rm $case/constant/*.latLon* $case/$time/*.latLon*
rm $case/$time/hRef $case/$time/h0 $case/$time/hTotal

# Finalise the plot
#gmt psbasemap -R -J -B60/60 -O >> $outFile.ps
ps2eps -O $outFile.ps >> $errFile 2>&1
convert -flatten -density 300  $outFile.eps $outFile.jpg
gzip -f $outFile.eps
echo created $outFile.eps.gz and $outFile.jpg

# Tidy up
rm $outFile.ps

