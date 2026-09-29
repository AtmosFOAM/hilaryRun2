#!/bin/bash -e

if [ "$#" -ne 1 ]; then
    echo usage: plot.sh var
    exit
fi

var=$1

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/plotFuncs.sh

cases=(Cm0033_se1p3_Pr085_C2_1p92
       Cm0033_se1p3_Pr085_C2_1p92_newBCs
       Cm009_se1p3_Pr085_C2_1p92_newBCs
       )
time=32400
inputFilesTmp=()

for CASE in ${cases[*]}; do
    plotProfile runs/$CASE $time $var
    source $SCRIPT_DIR/plot$var.gmt
    inputFilesTmp=(${inputFilesTmp[*]} runs/$CASE/$time/$var.xyz)
done
inputFiles=(${inputFilesTmp[*]})
outFile=plots/$var.eps
legends=('C@-@~m@~@-=0.033, rough wall'
         'C@-@~m@~@-=0.033, new wall'
         'C@-@~m@~@-=0.09, new wall'
)
pens=("1,black,"  "1,blue," "1,red," 
      "1,black,5_5:" "1,blue,5_5:" "1,red,5_5:")

. gmtPlot
ev $outFile
