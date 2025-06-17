#!/bin/bash -e

if [ "$#" -ne 6 ]
then
   echo usage: initOne.sh case smooth\|slotted uniform\|deforming\|divergent \
                          withDensity\|noDensity dt nx
   exit
fi

case=$1
tracerType=$2
velocityType=$3
density=$4
dt=$5
nx=$6

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Create the case
if [[ ! -e $case ]]; then
    mkdir -p $case/constant $case/system
    sed 's/NX/'$nx'/g' $SCRIPT_DIR/system/blockMeshDict \
        > $case/system/blockMeshDict
    sed 's/DT/'$dt'/g' $SCRIPT_DIR/system/controlDict \
        > $case/system/controlDict
    cp $SCRIPT_DIR/system/fvSchemes $case/system/fvSchemes
    if [[ $density == withDensity ]]; then
        cp $SCRIPT_DIR/system/fvSolutionWith $case/system/fvSolution
        cp $SCRIPT_DIR/constant/rhoTracerDict $case/constant
        cp $SCRIPT_DIR/system/functionsWith $case/system/functions
    else
        cp $SCRIPT_DIR/system/fvSolutionWithout $case/system/fvSolution
        cp $SCRIPT_DIR/system/functionsWithout $case/system/functions
    fi
    
    ln -s $SCRIPT_DIR/constant/gmtDicts $case/constant
    ln -s $SCRIPT_DIR/constant/physicalProperties $case/constant
    ln -s $SCRIPT_DIR/constant/momentumTransport $case/constant
    cp $SCRIPT_DIR/constant/${tracerType}TracerDict \
        $case/constant/tracerDict
    cp $SCRIPT_DIR/constant/${velocityType}VelocityDict \
        $case/constant/velocityDict
fi
if [[ ! -e $case/0 ]]; then
    # Mesh generation
    blockMesh -case $case
    # Set up the initial conditions
    rm -rf $case/[0-9]*
    cp -r $SCRIPT_DIR/0 $case
    if [[ $density == withDensity ]]; then
        setTracerField -case $case -name rho -tracerDict rhoTracerDict
    fi
    setVelocityField -case $case -dict velocityDict
    setTracerField -case $case -name T -tracerDict tracerDict
    rm $case/0/*f
    gmtFoam -case $case -time 0 UT
    gmtFoam -case $case -time 0 rhoU
    ev $case/0/*.pdf
fi

