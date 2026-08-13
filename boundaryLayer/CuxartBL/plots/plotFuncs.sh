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
    SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
    source $SCRIPT_DIR/plot${f}.gmt
    . gmtPlot
}

function plotProfiles {
    if [ "$#" -ne 2 ]; then
        echo usage: plotProfiles case time
        return 1
    fi
    export case=$1
    export time=$2
    SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
    for f in U T nut alphat k epsilon; do
        plotProfile $case $time $f
    done
    $SCRIPT_DIR/plotFluxes.sh $case $time
    sed 's/TIME/'$time'/g' $SCRIPT_DIR/plotAll.lyx \
        > $case/$time/plotAll.lyx
    lyx --export pdf $case/$time/plotAll.lyx
    pdfCrop $case/$time/plotAll.pdf
}

