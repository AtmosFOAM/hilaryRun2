function plotProfile {
    if [ "$#" -ne 3 ]; then
        echo usage: plotProfile case time field
        return 1
    fi
    case=$1
    time=$2
    f=$3
    writeCellDataxyz -case $case -time $time $f
    sed '1d' $case/$time/$f.xyz | sort -k3,3n | sponge $case/$time/$f.xyz
    
    if [ $f == U ]; then
         mv $case/$time/$f.xyz $case/$time/uvw.xyz
         awk '{print $1, $2, $3, sqrt($4**2 + $5**2)}' \
             $case/$time/uvw.xyz > $case/$time/$f.xyz
    fi
    
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

