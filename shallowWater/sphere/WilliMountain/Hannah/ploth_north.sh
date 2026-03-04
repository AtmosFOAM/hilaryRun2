#!/bin/bash -e

if [ "$#" -ne 1 ]; then
   echo usage: plothU time
   exit
fi
time=$1
outFile=$time/hU
echo plotting $outFile.eps.gz. Errors going to plotting/ploth_north.out

# Write out the data in lat-lon co-ordinates
sumFields $time hTotal $time h constant h0 > plotting/ploth_north.out
writeCellDataLatLon -constant h0 >> plotting/ploth_north.out
writeCellDataLatLon -time $time hTotal >> plotting/ploth_north.out

gmt info $time/hTotal.latLon
gmt info constant/h0.latLon

# Set up the plot: options

#gmt psbasemap -R0/360/0/90 -JG180/90/18c -B30g30 -P -K > $outFile.ps # Bug Report Advice for Watson ACORD External Code: The Watson algorithm can fail if there are duplicate (x,y) records. We found 2746 duplicate records in your data set.

#gmt psbasemap -R0/360/60/90 -JS180/90/18c -B30g30 -P -K > $outFile.ps # takes ages and output contours do not look right

#gmt psbasemap -R0/360/-90/90 -JN0/18c -B30g30 -P -K > $outFile.ps # looks fine but similar to before and not the plot wanted

gmt psbasemap -R0/360/0/90 -JA180/90/18c -B30g30 -P -K > $outFile.ps

# Create colours for the total height and plot (make sure R and J agree)
gmt makecpt -Cjet -D -T5000/6000/10 > plotting/hcontours.cpt
gmt pscontour $time/hTotal.latLon -R -J -Cplotting/hcontours.cpt -I -h1 -A- -K -O >> $outFile.ps

# Finalise the plot
gmt psbasemap -R -J -B30g30 -O >> $outFile.ps
ps2eps -O $outFile.ps >> plotting/plothUNorth.out 2>&1
convert -flatten -density 300 -rotate 90 $outFile.eps $time.jpg
gzip -f $outFile.eps
evince $outFile.eps.gz &

# Tidy up
rm $outFile.ps constant/*.latLon* $time/*.latLon*
