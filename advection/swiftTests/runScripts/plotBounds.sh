#!/bin/bash -e

if [ "$#" -eq 0 ]
then
   echo usage: plotBounds.sh outFileRoot CASE1 "legend1" CASE2 "legend2" \
             CASE3 "legend3" CASE4 "legend4" ...
   exit
fi

outFileRoot=$1
shift
# Cases to consider with legends
cases=()
legends=()
while (( "$#" )); do
    cases=(${cases[*]} $1)
    shift
    legends=(${legends[*]} $1)
    shift
done

# For each case, create the time series to plot
inputFiles=()
for case in ${cases[*]}; do
    grep 'T goes' $case/log | awk '{print $5, $9}' > $case/Tminmax.tmp
    echo 0 > $case/time.tmp
    grep 'Time =' $case/log | awk '{if (NF == 3) print $3}' \
        | awk -Fs '{print $1}' >> $case/time.tmp
    echo '#Time Tmin Tmax-1' > $case/Tminmax.dat
    paste $case/time.tmp $case/Tminmax.tmp >> $case/Tminmax.dat
    rm $case/time.tmp $case/Tminmax.tmp

    inputFiles=(${inputFiles[*]} $case/Tminmax.dat)
done

mkdir -p `dirname $outFileRoot`

colx=1
pens=("green" "blue" "red"  "cyan" "magenta" "grey")
xlabel='Time'
ylabel=''
xmin=0
xmax=100
dx=10
dyg=1
legPos=x6.5/0
nSkip=1
projection=X10c/7.5c
gv=0

col=2
ymin=-1e-14
ymax=1e-14
dy=5e-15
outFile=${outFileRoot}Min.eps
. gmtPlot
ev $outFile

col=3
ymin=-1e-2
ymax=1e-3
dy=2e-3
ddy=0
outFile=${outFileRoot}Max.eps
. gmtPlot
ev $outFile
