#!/bin/bash -e

# Clean out old data
rm -rf [0-9]* constant/polyMesh constant/h0

# Create a latitude-longitude mesh
sphPolarLatLonMesh

# Create a mountain
cp init0/h0 constant
setTracerField -tracerDict earthProperties -tracerType geodesicCone -name h0
rm constant/h0f

# Create wind field
mkdir -p 0
cp init0/U 0
setVelocityField -dict earthProperties -velocityType geodesicSolidBody
rm 0/Uf 0/phi

# Create geopotential height
# Note, this should be replaced by discretely balanced height
cp init0/h 0
setTracerField -tracerDict earthProperties -tracerType geodesicSolidRotation \
     -name h
# Correct boundary conditions
#sed -i 's/zeroGradient/fixedValue;value uniform 0/g' 0/h
rm 0/hf
mv 0/h 0/hTotal
sumFields 0 h 0 hTotal constant h0 -scale1 -1

# Plot initial conditions
./plotting/plothU.sh 0
