#!/bin/bash -e

createRef=false
runs=false
analysis=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -createRef)
            echo "Creating reference solution"
            createRef=true
            ;;
        -runs)
            echo "Runs with different time steps"
            runs=true
            ;;
        -analysis)
            echo "Analysing by comparing with reference solution"
            analysis=true
            ;;
        -help)
            echo "usage: run_AdImEx.sh -createRef -runs -analysis -help"
            ;;
        *)
            echo "Unknown option: $1"
            ;;
    esac
    shift
done

caseRoot=run_AdImEx
dt0=100     # Referene time step
timeSteps=(900 1800 3600)
refTimes=(3600 7200 10800)

if [[ "$createRef" == "true" ]]; then
    echo "Creating reference solution"
    case=`./setup.sh $dt0 $caseRoot | tail -1`; echo Created $case
    AdImExShallowWaterFoam -case $case | tee $case/log
fi

if [[ "$runs" == "true" ]]; then
    echo "Runs with different time steps"
    for dt in ${timeSteps[@]}; do
        case=`./setup.sh $dt $caseRoot | tail -1`; echo Created $case
        AdImExShallowWaterFoam -case $case | tee $case/log
    done
fi

if [[ "$analysis" == "true" ]]; then
    echo "Analysing by comparing with reference solution"
    caseRef=$caseRoot/dt_$dt0
    for dt in ${timeSteps[@]}; do
        case=$caseRoot/dt_$dt
        echo analysing $case
        for time in ${refTimes[@]}; do
            ./plotting/plothU.sh $time $case
            ln -sf ../../dt_$dt0/$time/h $case/$time/hRef
            ln -sf ../../dt_$dt0/$time/U $case/$time/URef
            foamPostProcess -case $case -time $time -func \
                "subtract(fields=(h hRef),result=h_diff)"
            foamPostProcess -case $case -time $time -func \
                "subtract(fields=(U URef),result=U_diff)"
            ./plotting/plothU_diff.sh $time $case
        done
        globalSum -case $case h_diff
    done
fi

exit


mkdir -p run_AdImEx plotting
cp -r init0/ constant/ plotting/ system/ setup.sh run_AdImEx
for dt in ${time_steps_1[@]};
do
    sed -i 's/\(deltaT[[:space:]]*\)[0-9.]\+;/\1'$dt';/' run_AdImEx/system/controlDict
    (cd run_AdImEx ; ./setup.sh)
    (cd run_AdImEx ; AdImExShallowWaterFoam >& log)
    mkdir run_AdImEx/dt_$dt
    cp -r run_AdImEx/0 run_AdImEx/3600 run_AdImEx/7200 run_AdImEx/10800 run_AdImEx/dt_$dt
    cp -r run_AdImEx/constant run_AdImEx/system run_AdImEx/dt_$dt
done



for i in {1,2,3} 
do
    for time in {3600,7200,10800}
    do
        rm run_AdImEx/dt_$time/*
        for dt in ${time_steps_1[@]};
        do
            cp run_AdImEx/dt_$dt/$time/h run_AdImEx/$time/h_$dt
        done
    done
done


(cd run_AdImEx ; globalSum h_1)
for dt in ${time_steps_1[@]};
do
    (cd run_AdImEx ; postProcess -func "subtract(fields=(h_"$dt"  h_1),result=h_"$dt"_diff)")
    (cd run_AdImEx ; globalSum h_"$dt"_diff)
done
(cd run_AdImEx ; echo "Scheme $i" >> errors)
for hrs in {1,2,3}
do
    for j in {0,1,2,3,4,5,6,7}
    do
        j1=$((j + 1))
        echo $j $j1
        dt_1=$(cd run_AdImEx ; awk -v hrs="$hrs" 'NR==hrs+1 {print $3}' globalSumh_${time_steps[$j1]}_diff.dat)
        dt_2=$(cd run_AdImEx ; awk -v hrs="$hrs" 'NR==hrs+1 {print $3}' globalSumh_${time_steps[$j]}_diff.dat)
        result=$(python3 - <<EOF
from math import log
E1=float($dt_1)
E2=float($dt_2)
print(log(E1/E2)/log(${time_steps[$j1]}/${time_steps[$j]}))
EOF
)
        (cd run_AdImEx ; echo $hrs $j $result >> errors)
        echo "scheme = AdImEx and j = " $j " at " $hrs " hours has order " $result 
    done
    
    dt_1800=$(cd run_AdImEx ; awk -v hrs="$hrs" 'NR==hrs+1 {print $3}' globalSumh_1800_diff.dat)

    dt_900=$(cd run_AdImEx ; awk -v hrs="$hrs" 'NR==hrs+1 {print $3}' globalSumh_900_diff.dat)

    result_1=$(python3 - <<EOF
from math import log
E1800=float($dt_1800)
E900=float($dt_900)
print(log(E1800/E900)/log(2.0))
EOF
)
    
    (cd run_AdImEx ; echo $hrs $result_1 >> errors)
    echo "scheme = AdImEx at " $hrs " hours has order " $result_1  
done

