#!/bin/bash -e

if [[ $# -ne 3 ]]; then
    echo usage: setup.sh caseRoot dt split\|notSplit
    exit
fi

caseRoot=$1
dt=$2
split=""
if [[ $3 == "split" ]]; then split=on; else split=off; fi
case=${caseRoot}/dt_${dt}
echo Creating $case with dt=$dt

rm -rf $case/[0-9]* $case/constant $case/system; mkdir -p $case
cp -r system constant $case
foamDictionary -case $case system/controlDict -entry deltaT -set $dt
foamDictionary -case $case system/fvSolution -entry operatorSplit -set $split

# Create a latitude-longitude mesh
sphPolarLatLonMesh -case $case

# Create a mountain
cp init0/h0 $case/constant
setTracerField -case $case -tracerDict earthProperties -tracerType \
    geodesicCone -name h0
rm $case/*/h0f

# Create wind field
cp -r init0 $case/0
setVelocityField -case $case -dict earthProperties -velocityType geodesicSolidBody
rm $case/0/phi*

# Create geopotential height
setTracerField -case $case -tracerDict earthProperties -tracerType \
      geodesicSolidRotation -name h
# setBalancedHeight #makes the initial conditions discretely divergence free
# But it is not working yet
rm $case/0/hf
mv $case/0/h $case/0/hTotal
sumFields -case $case 0 h 0 hTotal constant h0 -scale1 -1

# Plot initial conditions
./plotting/plothU.sh 0 $case

echo Created $case
