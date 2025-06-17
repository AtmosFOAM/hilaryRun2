#!/bin/bash -e

# Collect error norms in one file for each Courant number to plot
inputFiles=()
for case in smoothUniformnoDensity/c05 smoothUniformnoDensity/c1p6 \
            smoothUniformnoDensity/c2p6 \
            smoothUniformwithDensity/c05 smoothUniformwithDensity/c1p6 \
            smoothUniformwithDensity/c2p6; do
    mkdir -p $case/plots
    c=`filename $case`
    echo "#dx l1 l2 linf normMass normVar" > $case/plots/errorNorms.dat
    for res in 32 64 128; do
        tail -1 $case/nx$res/errorNorms.dat \
                | awk '{print 1/'$res', $2, $3, $4, $5, $6}' \
                >> $case/plots/errorNorms.dat
    done
    inputFiles=(${inputFiles[*]} $case/plots/errorNorms.dat)
done

mkdir -p plots
echo -e "#dx error\n0.01 1e-4\n0.1 .1" > plots/3rdOrder.dat
echo -e "#dx error\n0.01 1e-3\n0.1 .1" > plots/2ndOrder.dat
echo -e "#dx error\n0.01 1e-2\n0.1 .1" > plots/1stOrder.dat

inputFiles=(${inputFiles[*]} \
            plots/3rdOrder.dat  plots/2ndOrder.dat  plots/1stOrder.dat)
outFile=plots/errorNorms.eps
col=(3 3 3 3 3 3 2 2 2)
colx=1
legends=("c = 0.5, no @~r@~" "c = 1.6, no @~r@~" "c = 2.6, no @~r@~"
         "c = 0.5, with @~r@~" "c = 1.6, with @~r@~" "c = 2.6, with @~r@~"
         "1st/2nd/3rd" "" "")
pens=("black" "blue" "red"
      "0.5,black,8_8:0" "0.5,blue,8_8:0" "0.5,redk,8_8:0"
      "0.25,black,1_4:0" "0.25,black,1_4:0" "0.25,black,1_4:0")
symbols=("x10p" "c10p" "a10p"
         "+10p" "t10p" "h10p" "" "" "")
spens=("black" "blue" "red"
       "black" "blue" "red" "" "" "")
xlabel='@~D@~x'
ylabel=''
xmin=0.005
xmax=0.1
dx=10
ddx=2
dxg=10
ymin=1e-5
ymax=2.1
dy=10
ddy=1
dyg=10
xscale=*1
yscale=*1
legPos=x6.1/0
nSkip=1
projection=X10cl/7.5cl
gv=0

. gmtPlot
ev $outFile
