#!/bin/bash -e

export SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" \
    &> /dev/null && pwd )

# Function to initialise a case
function initOne {
    if [ "$#" -ne 10 ]; then
        echo usage: initOne case smooth\|slotted uniform\|deforming\|divergent \
                            withDensity\|noDensity dt nx plot|noPlot nFCT \
                            CCRIT CGRAD
        return 0
    fi

    case=$1
    tracerType=$2
    velocityType=$3
    density=$4
    dt=$5
    nx=$6
    plot=$7
    nFCT=$8
    cCrit=$9
    cGrad=${10}

    # Create the case (if needed)
    if [[ ! -e $case ]]; then
        mkdir -p $case/constant $case/system
        sed 's/NX/'$nx'/g' $SCRIPT_DIR/system/blockMeshDict \
            > $case/system/blockMeshDict
        sed 's/DT/'$dt'/g' $SCRIPT_DIR/system/controlDict \
            > $case/system/controlDict
        cp $SCRIPT_DIR/system/fvSchemes  $case/system/fvSchemes
        cp $SCRIPT_DIR/system/fvSolution $case/system/fvSolution
        if [[ $density == withDensity ]]; then
            cp $SCRIPT_DIR/constant/rhoTracerDict $case/constant
            cp $SCRIPT_DIR/system/functionsWith $case/system/functions
        else
            cp $SCRIPT_DIR/system/functionsWithout $case/system/functions
            sed
        fi
        sed -i -e 's/NFCT/'$nFCT'/g' -e 's/CCRIT/'$cCrit'/g' \
               -e 's/CGRAD/'$cGrad'/g' $case/system/functions

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
        if [[ $plot == plot ]]; then
            gmtFoam -case $case -time 0 UT
            gmtFoam -case $case -time 0 rhoU
            ev $case/0/*.pdf
        fi
    fi
}

# Function to plot and calculate some error diagnositcs
function postOne {
    if [ "$#" -ne 2 ]; then
        echo usage: postOne case plot\|noPlot
        return 0
    fi

    case=$1
    plot=$2

    time=100
    for var in T rho; do
        if [[ -e $case/$time/$var ]]; then
            # Plot and calculate error norms
            sumFields -case $case $time ${var}error $time $var 0 $var -scale1 -1
            if [[ $plot == plot ]]; then
                gmtFoam -case $case -time $time $var
                ev $case/$time/$var.pdf
            fi
            globalSum -case $case -time $time $var
            globalSum -case $case -time $time ${var}error
            echo "#Time l1 l2 linf normMass normVar" > $case/${var}errorNorms.dat
            paste $case/globalSum${var}error.dat $case/globalSum${var}.dat | tail -1 | \
                awk '{print $1, $2/$10, $3/$11, $4/$12, $5/$13, $6/$11}' \
                >> $case/${var}errorNorms.dat
            cat $case/${var}errorNorms.dat
        else
            echo no $case/$time/$var
        fi
    done
}

function initRunPost {
    if [ "$#" -ne 10 ]; then
        echo usage: runOne case smooth\|slotted uniform\|deforming\|divergent \
                     withDensity\|noDensity dt nx plot\|noPlot nFCT CCRIT CGRAD
        return 0
    fi

    case=$1
    plot=$7

    initOne $*

    if [[ -e $case/0 && ! -e $case/1 ]]; then
        foamRun -case $case |& tee $case/log
    fi

    postOne $case $plot
}
