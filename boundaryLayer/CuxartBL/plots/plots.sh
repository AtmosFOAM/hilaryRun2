#!/bin/bash -e

if [ "$#" -ne 1 ]; then
    echo usage: runOne case
    exit
fi

case=$1
if [ ! -d $case ]; then
    echo $case does not exist
    exit
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source $SCRIPT_DIR/plotFuncs.sh

# Plot graphs
$SCRIPT_DIR/plotUstar.sh $case
plotProfiles $case 0
cp $case/0/plotAll.pdf $case
evince $case/plotAll.pdf &
HERE=$PWD
cd $case
times=`ls -d [1-9]* | sort -n`
cd $HERE
for time in $times ; do
    plotProfiles $case $time
    echo $time
    pdfunite $case/$time/plotAll.pdf $case/plotAll.pdf $case/plotAll2.pdf
    mv $case/plotAll2.pdf $case/plotAll.pdf
done

