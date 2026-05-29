#!/bin/bash -e

caseRoot=.

if [[ $# -eq 2 ]]; then
    caseRoot=$2
fi; if [[ $# -ge 1 ]]; then
    dt=$1
elif [[ $# -lt 1 ]]; then
    echo usage: setup.sh dt [case]
    exit
fi

case=${caseRoot}/dt_${dt}
echo Creating $case with dt=$dt
rm -rf $case/0 $case/constant $case/system; mkdir -p $case
cp -r system constant $case
cp -r init0 $case/0
foamDictionary -case $case system/controlDict -entry deltaT -set $dt

# Clean out old data
rm -rf $case/[0-9]* $case/constant/polyMesh $case/constant/h0

# Create a latitude-longitude mesh
sphPolarLatLonMesh -case $case

# Create a mountain
cp init0/h0 $case/constant
setTracerField -case $case -tracerDict earthProperties -tracerType \
    geodesicCone -name h0
rm $case/constant/h0f

# Create wind field
mkdir -p $case/0
cp init0/U init0/Uf $case/0
setVelocityField -case $case -dict earthProperties -velocityType geodesicSolidBody
rm $case/0/phi*

# Create geopotential height
cp init0/h $case/0
setTracerField -case $case -tracerDict earthProperties -tracerType \
      geodesicSolidRotation -name h
# setBalancedHeight #makes the initial conditions discretely divergence free
# But it is not working yet
rm $case/0/hf
mv $case/0/h $case/0/hTotal
sumFields -case $case 0 h 0 hTotal constant h0 -scale1 -1

# Plot initial conditions
./plotting/plothU.sh 0 $case

echo $case
