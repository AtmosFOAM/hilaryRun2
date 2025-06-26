#!/bin/bash -e

if [ "$#" -ne 1 ]
then
   echo usage: plotErrorNorms.sh var
   exit
fi

var=$1

# Collect error norms in one file for each Courant number to plot
inputFiles=()
for case in slottedUniformDensity_FCT0_gamma2_2/c05 slottedUniformDensity_FCT0_gamma2_2/c1p6 \
            slottedUniformDensity_FCT0_gamma2_2/c2 slottedUniformDensity_FCT0_gamma2_2/c2p1 \
            slottedUniformDensity_FCT0_gamma2_2/c2p6 slottedUniformDensity_FCT0_gamma2_2/c5p1 \
            slottedUniformDensity_FCT0_gamma2_2/c10; do
    mkdir -p $case/plots
    c=`filename $case`
    echo "#dx l1 l2 linf normMass normVar" > $case/plots/${var}errorNorms.dat
    for dir in $case/nx*; do
        res=`echo $dir | awk -F"$case/nx" '{print $2}'`
        echo $case $res
        tail -1 $case/nx$res/${var}errorNorms.dat \
                | awk '{print 1/'$((10#$res))', $2, $3, $4, $5, $6}' \
                >> $case/plots/${var}errorNorms.dat
    done
    inputFiles=(${inputFiles[*]} $case/plots/${var}errorNorms.dat)
done

mkdir -p plots
echo -e "#dx error\n0.01 1e-5\n0.1 .01" > plots/3rdOrder.dat
echo -e "#dx error\n0.01 1e-4\n0.1 .01" > plots/2ndOrder.dat
echo -e "#dx error\n0.01 1e-3\n0.1 .01" > plots/1stOrder.dat

inputFiles=(${inputFiles[*]} \
            plots/3rdOrder.dat  plots/2ndOrder.dat  plots/1stOrder.dat)
outFile=plots/${var}errorNorms.eps
col=(3 3 3 3 3 3 3 2 2 2)
colx=1
legends=("c = 0.5" "c = 1.6" "c = 2" "c = 2.1" "c = 2.6" "c = 5.1" "c = 10"
         "1st/2nd/3rd" "" "")
pens=("black" "blue" "red" "green" "cyan" "magenta" "grey"
      "0.25,black,1_4:0" "0.25,black,1_4:0" "0.25,black,1_4:0")
symbols=("x10p" "c10p" "a10p"
         "+10p" "t10p" "h10p" "s10p"  "" "" "")
#spens=("black" "blue" "red" "green" "cyan" "magenta" "" "" "")
xlabel='@~D@~x'
ylabel=''
xmin=0.004
xmax=0.1
dx=10
ddx=2
dxg=10
ymin=1e-5
ymax=0.2
dy=10
ddy=1
dyg=10
xscale=*1
yscale=*1
legPos=x6.5/0
nSkip=1
projection=X10cl/7.5cl
gv=0

. gmtPlot
ev $outFile
