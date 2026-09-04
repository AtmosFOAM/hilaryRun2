#!/bin/bash -e

if [ "$#" -ne 1 ]; then
    echo usage: plotUstar case
fi

case=$1

echo '#Time(s) uStar(m/s)' > $case/uStar.dat
grep uStar $case/log | grep ground | awk '{print $2, $11}' >> $case/uStar.dat

inputFiles=($case/uStar.dat)
outFile=$case/uStar.eps
col=(2)
colx=(1)
#legends=('u' 'v')
#pens=(psxy pen types in double quotes)
#symbols=(psxy symbol types in double quotes) (optional)
#spens=(psxy pen types in double quotes for the symbols) (optional)
xlabel='Time (min)'
ylabel='u* (m/s)'
xmin=0
xmax=540
dx=60
ddx=30
dxg=60
ymin=0.2
ymax=0.5
dy=0.05
ddy=0.025
dyg=0.05
xscale=/60
#yscale=*1
#legPos=x10/10
nSkip=1
projection=X15c/10c
gv=0

. gmtPlot
ev $outFile

