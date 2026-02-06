#!/bin/bash -e

if [ "$#" -ne 4 ]
then
   echo usage: plotErrorNorms.sh var simType scheme dt0
   exit
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/runScripts.sh

var=$1
simType=$2
scheme=$3
dt0=$4
outFile=plots/${var}errorNorms_${simType}_${scheme}_dt${dt0}.eps

meshTypes=(latLon_0_P latLon_30_P cubedSphere hexagonal)

# Collect error norms and dx for each mesh type
inputFiles=()
for meshType in ${meshTypes[*]}; do
    ress=`ls -d $meshType/*/constant | awk -F'/' '{print $2}' | \
        awk '{ match($0, /[0-9]+/); print substr($0, RSTART, RLENGTH) }'`
    ress="$(echo "$ress" | tr ' ' '\n' | sort -nr | paste -sd' ')"
    dt=$dt0

    for res in $ress; do
        dtp=`echo $dt | sed 's/\./p/g'`
        case=$meshType/*${res}*/$simType/dt_${dtp}_${scheme}*
        case=`ls -d $case`
        echo "$case"
        # Find maximum dx if needed
        if [[ ! -a $case/constant/polyMesh/maxDx ]]; then
            cellCentreDistances -case $case | grep Distance | awk '{print $3}' \
                | sort -n | tail -1 > $case/constant/polyMesh/maxDx
        fi
        if [[ -f $case/5/${var} && ! -f $case/${var}_5errorNorms.dat ]]; then
            postOne $case
        fi
        dx=`cat $case/constant/polyMesh/maxDx`
        errs=`tail -1 $case/${var}_5errorNorms.dat | awk '{print $2, $3, $4}'`
        echo $dx $errs >> $meshType/${var}_${simType}_${scheme}_${dt0}_errorNormsTmp.dat
        dt=`echo $dt | awk '{print $1*2}'`
    done
    echo "#dx l1 l2 linf" \
        > $meshType/${var}_${simType}_${scheme}_${dt0}_errorNorms.dat
    sort -n $meshType/${var}_${simType}_${scheme}_${dt0}_errorNormsTmp.dat \
        >> $meshType/${var}_${simType}_${scheme}_${dt0}_errorNorms.dat
    rm $meshType/${var}_${simType}_${scheme}_${dt0}_errorNormsTmp.dat
    inputFiles=(${inputFiles[*]} $meshType/${var}_${simType}_${scheme}_${dt0}_errorNorms.dat)
done

mkdir -p plots
inputFiles=(${inputFiles[*]} \
            plots/3rdOrder.dat  plots/2ndOrder.dat  plots/1stOrder.dat)

echo -e "#dx error\n 0.01 1e-1 \n 0.1 1" > plots/1stOrder.dat
echo -e "#dx error\n 0.01 1e-2 \n 0.1 1" > plots/2ndOrder.dat
echo -e "#dx error\n 0.01 1e-3 \n 0.1 1" > plots/3rdOrder.dat

col=(3 3 3 3  2 2 2)
colx=1
legends=("lat-lon" "lat-lon rotated" "cubed sphere" "hexagonal" "1st/2nd/3rd" "" "")
pens=("black" "blue" "red" "1,purple"  "0.25,black,1_4:0"
      "0.25,black,1_4:0" "0.25,black,1_4:0" "0.25,black,1_4:0")
symbols=("x7p" "c7p" "+7p" "s7p"
           "" "" "" "")
#         "+10p" "t10p" "h10p"
#spens=("black" "blue" "red" "green" "cyan" "magenta" "" "" "")
xlabel='max @~D f@~'
ylabel=''
xmin=0.5
xmax=5
dx=2
#ddx=1
#dxg=10
ymin=4e-4
ymax=1
dy=10
#ddy=1
dyg=0
xscale=*57.295779513
yscale=*1
legPos=x6/0.1
nSkip=1
projection=X10cl/7.5cl
gv=0

. gmtPlot
ev $outFile
