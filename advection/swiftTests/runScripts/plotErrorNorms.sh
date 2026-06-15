#!/bin/bash -e

if [ "$#" -ne 2 ]
then
   echo usage: plotErrorNorms.sh var rootDir
   exit
fi

var=$1
root=$2
outFile=$root/plots/${var}errorNorms.eps

mkdir -p $root/plots

# Collect error norms in one file for each Courant number to plot
inputFiles=()
for case in $root/c05 \
            $root/c1 \
            $root/c2 \
            $root/c5 ; do
    mkdir -p $case/plots
    c=`filename $case`
    echo "#dx l1 l2 linf normMass normVar" > $case/plots/${var}errorNorms.dat
    for dir in $case/nx*; do
        res=`echo $dir | awk -F"$case/nx" '{print $2}'`
        echo $case $res
        tail -1 $case/nx$res/${var}errorNorms.dat \
                | awk '{print 1000/'$((10#$res))', $2, $3, $4, $5, $6}' \
                >> $case/plots/${var}errorNorms.dat
    done
    inputFiles=(${inputFiles[*]} $case/plots/${var}errorNorms.dat)
done

mkdir -p plots
echo -e "#dx error\n50 1\n5 .1" > plots/1stOrder.dat
echo -e "#dx error\n50 0.1\n5 .001" > plots/2ndOrder.dat
echo -e "#dx error\n50 1e-3\n5 1e-6" > plots/3rdOrder.dat
echo -e "#dx error\n50 1e-4\n5 1e-8" > plots/4thOrder.dat

inputFiles=(${inputFiles[*]} plots/4thOrder.dat\
            plots/3rdOrder.dat  plots/2ndOrder.dat  plots/1stOrder.dat)
col=(3 3 3 3  2 2 2 2)
colx=1
legends=("c = 0.5" "c = 1" "c = 2" "c = 5.1" "1st/2nd/3rd/4th" "" "")
pens=("black" "blue" "red" "1,purple"  "0.25,black,1_4:0"
      "0.25,black,1_4:0" "0.25,black,1_4:0" "0.25,black,1_4:0")
symbols=("x7p" "c7p" "+7p" "s7p"
           "" "" "" "")
#         "+10p" "t10p" "h10p"
#spens=("black" "blue" "red" "green" "cyan" "magenta" "" "" "")
xlabel='@~D@~x'
ylabel=''
xmin=3
xmax=50
dx=2
ddx=1
dxg=10
ymin=1e-8
ymax=1
dy=10
ddy=1
dyg=10
xscale=*1
yscale=*1
legPos=x0.1/1.7
nSkip=1
projection=X10cl/7.5cl
gv=0

. gmtPlot
ev $outFile
