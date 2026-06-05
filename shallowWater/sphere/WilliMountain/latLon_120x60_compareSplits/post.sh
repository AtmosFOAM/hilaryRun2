#!/bin/bash -e

refCase=""
if [[ $# -eq 1 ]]; then case=$1
elif [[ $# -eq 2 ]]; then
    case=$1
    refCase=$2
else
    echo usage: post.sh case [refCase]
    exit
fi

globalSum -case $case h

for time in 3600 7200 10800; do
    ./plotting/plothU.sh $time $case
    if [[ "$refCase" != "" ]]; then
        ln -sf ../../../$refCase/$time/h $case/$time/hRef
        ln -sf ../../../$refCase/$time/U $case/$time/URef
        foamPostProcess -case $case -time $time -func \
            "subtract(fields=(h hRef),result=h_diff)"
        foamPostProcess -case $case -time $time -func \
            "subtract(fields=(U URef),result=U_diff)"
        ./plotting/plothU_diff.sh $time $case
    fi
done

if [[ "$refCase" != "" ]]; then
    globalSum -case $case h_diff
fi


