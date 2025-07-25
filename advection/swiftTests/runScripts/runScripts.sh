#!/bin/bash -e

export SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" \
    &> /dev/null && pwd )

# Function to initialise a case
function initOne {
    if [ "$#" -ne 10 ]; then
        echo usage: initOne case dt nx \
                            smooth\|slotted\|uniT uniform\|deforming\|divergent \
                            withDensity\|noDensity\|uniDensity  \
                            CORRSCHEME RK3\|RK4 nFCT plot\|noPlot
        return 0
    fi

    case=$1
    dt=$2
    nx=$3
    tracerType=$4
    velocityType=$5
    density=$6
    corrScheme=$7
    RK=$8
    nFCT=$9
    plot=${10}
    
    if [[ $RK == RK3 ]]; then
        RK='3 3((1 0 0)\n                        (0.25 0.25 0)                        (0.16666666667 0.16666666667 0.66666666666))'
    elif [[ $RK == RK4 ]]; then
        RK='4 4((0.5 0 0 0)\n          (0 0.5 0 0)\n          (0 0 1 0)\n          (0.16666666667 0.33333333333 0.33333333333 0.16666666667))'
    else
        echo RK scheme $RK not known. Known schemes are RK3 and RK4
        return 0
    fi
    echo $RK
    
    # Create the case (if needed)
    if [[ ! -e $case ]]; then
        mkdir -p $case/constant $case/system
        sed 's/NX/'$nx'/g' $SCRIPT_DIR/system/blockMeshDict \
            > $case/system/blockMeshDict
        sed 's/DT/'$dt'/g' $SCRIPT_DIR/system/controlDict \
            > $case/system/controlDict
        cp $SCRIPT_DIR/system/fvSchemes  $case/system/fvSchemes
        cp $SCRIPT_DIR/system/fvSolution $case/system/fvSolution
        cp $SCRIPT_DIR/system/functionsWith $case/system/functions
        if [[ $density == withDensity ]]; then
            cp $SCRIPT_DIR/constant/rhoTracerDict $case/constant
        fi
        if [[ $density == noDensity ]]; then
            cp $SCRIPT_DIR/system/functionsWithout $case/system/functions
        fi
        sed -i -e 's/NFCT/'$nFCT'/g' -e 's/CORRSCHEME/'$corrScheme'/g' \
               -e "s:RKCOEFFS:$RK:g" $case/system/functions

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
        echo usage: initRunPost case dt nx \
                            smooth\|slotted\|uniT uniform\|deforming\|divergent \
                            withDensity\|noDensity\|uniDensity  \
                            CORRSCHEME RK3\|RK4 nFCT plot\|noPlot
        return 0
    fi

    case=$1
    plot=${10}

    initOne $*

    if [[ -e $case/0 && ! -e $case/1 ]]; then
        foamRun -case $case |& tee $case/log
    fi

    postOne $case $plot
}
