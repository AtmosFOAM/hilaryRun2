#!/bin/bash -e

# Segreated runs
caseRoot=impSeg_runs
# Segregated reference solution
dt0=60
./setup.sh $caseRoot $dt0 notSplit
AdImExShallowWaterFoam -case $caseRoot/dt_$dt0 | tee $caseRoot/dt_$dt0/log
./post.sh $caseRoot/dt_$dt0

# Segretated long time step runs
for dt in 900 1800 3600; do
    ./setup.sh $caseRoot $dt notSplit
    AdImExShallowWaterFoam -case $caseRoot/dt_$dt | tee $caseRoot/dt_$dt/log
    ./post.sh $caseRoot/dt_$dt $caseRoot/dt_$dt0
done

# Operator split runs
caseRoot=impSplit_runs
# Segregated reference solution
dt0=60
./setup.sh $caseRoot $dt0 split
AdImExShallowWaterFoam -case $caseRoot/dt_$dt0 | tee $caseRoot/dt_$dt0/log
./post.sh $caseRoot/dt_$dt0

# Segretated long time step runs
for dt in 900 1800 3600; do
    ./setup.sh $caseRoot $dt notSplit
    AdImExShallowWaterFoam -case $caseRoot/dt_$dt | tee $caseRoot/dt_$dt/log
    ./post.sh $caseRoot/dt_$dt $caseRoot/dt_$dt0
done

