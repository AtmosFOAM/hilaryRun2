function plotProfile {
    if [ "$#" -ne 3 ]; then
        echo usage: plotProfile case time field
        return 1
    fi
    export case=$1
    export time=$2
    f=$3
    writeCellDataxyz -case $case -time $time $f
    sed '1d' $case/$time/$f.xyz | sort -k3,3n | sponge $case/$time/$f.xyz
    source plots/plot${f}.gmt
    . gmtPlot
}

function plotProfiles {
    if [ "$#" -ne 2 ]; then
        echo usage: plotProfiles case time
        return 1
    fi
    export case=$1
    export time=$2
    for f in U T nut alphat k epsilon; do
        plotProfile $case $time $f
    done
    ./plots/plotFluxes.sh $case $time
    sed 's/TIME/'$time'/g' plots/plotAll.lyx > $case/$time/plotAll.lyx
    lyx --export pdf $case/$time/plotAll.lyx
    pdfCrop $case/$time/plotAll.pdf

}

