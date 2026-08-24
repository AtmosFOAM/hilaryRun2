#!/bin/bash -e

if [ "$#" -ne 1 ]; then
    echo usage: plot.sh var
    exit
fi

var=$1

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/plotFuncs.sh

cases=(Cm009_se1p3_Pr07_C2_1p85 Cm0033_se1p3_Pr07_C2_1p85
       Cm0033_se1p3_Pr07_C2_1p85_stdWall)
time=32400
inputFilesTmp=()

for CASE in ${cases[*]}; do
    plotProfile runs/$CASE $time $var
    source $SCRIPT_DIR/plot$var.gmt
    inputFilesTmp=(${inputFilesTmp[*]} runs/$CASE/$time/$var.xyz)
done
inputFiles=(${inputFilesTmp[*]})
outFile=plots/$var.eps
legends=('C@-@~m@~@-=0.090, Pr@-t@-=0.85, c@-1@-=1.44, c@-2@-=1.92, @~s@~@-@~e@~@-=1.3'
         'C@-@~m@~@-=0.033, Pr@-t@-=0.85, c@-1@-=1.44, c@-2@-=1.92, @~s@~@-@~e@~@-=1.3'
         'C@-@~m@~@-=0.033, and same but std wall funcs')
pens=("1,black,"  "1,blue," "1,red," 
      "1,black,5_5:" "1,blue,5_5:" "1,red,5_5:")

. gmtPlot
ev $outFile
