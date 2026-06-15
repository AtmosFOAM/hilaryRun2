#!/bin/bash -e

export SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" \
    &> /dev/null && pwd )

# Function to initialise a case
function initOne {
    if [ "$#" -ne 13 ]; then
        echo usage: initOne case dt nx \
                            smooth\|slotted\|uniT uniform\|deforming\|divergent \
                            withDensity\|noDensity\|uniDensity  \
                            CORRSCHEME RK3\|RK4 nFCT B1 B2 B3 plot\|noPlot
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
    b1=${10}
    b2=${11}
    b3=${12}
    plot=${13}
    
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
        if [[ $density == withDensity ]]; then
            cp $SCRIPT_DIR/constant/rhoTracerDict $case/constant
        fi
        ln -s $SCRIPT_DIR/constant/gmtDicts $case/constant
        ln -s $SCRIPT_DIR/constant/physicalProperties $case/constant
        ln -s $SCRIPT_DIR/constant/momentumTransport $case/constant
        cp $SCRIPT_DIR/constant/${tracerType}TracerDict \
            $case/constant/tracerDict
        cp $SCRIPT_DIR/constant/${velocityType}VelocityDict \
            $case/constant/velocityDict
    fi
    # Update some scheme parameters
    if [[ $density == withDensity ]]; then
        cp $SCRIPT_DIR/system/functionsWith $case/system/functions
    else
        cp $SCRIPT_DIR/system/functionsWithout $case/system/functions
    fi
    sed -i -e 's/NFCT/'$nFCT'/g' -e 's/CORRSCHEME/'$corrScheme'/g' \
           -e "s:RKCOEFFS:$RK:g" -e "s:CCRIT:$b1:g" -e "s:BMAX:$b2:g"\
           -e "s:CGRAD:$b3:g" $case/system/functions
    
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
    
        for time in 50 100; do
            if [[ -e $case/$time/$var ]]; then
                if [[ $plot == plot ]]; then
                    gmtFoam -case $case -time $time $var
                    ev $case/$time/$var.pdf
                fi
            else
                echo no $case/$time/$var
            fi
        done
    done
}

function initRunPost {
    if [ "$#" -ne 13 ]; then
        echo usage: initRunPost case dt nx \
                            smooth\|slotted\|uniT uniform\|deforming\|divergent \
                            withDensity\|noDensity\|uniDensity  \
                            CORRSCHEME RK3\|RK4 nFCT B1 B2 B3 plot\|noPlot
        return 0
    fi

    case=$1
    plot=${13}

    initOne $*

    if [[ -e $case/0 && ! -e $case/1 ]]; then
        foamRun -case $case |& tee $case/log
    fi

    postOne $case $plot
}

function convergenceTest {
    if [ "$#" -ne 10]; then
        echo usage: convergenceTest case smooth\|slotted\|uniT \
                            uniform\|deforming\|divergent \
                            withDensity\|noDensity\|uniDensity  \
                            CORRSCHEME RK3\|RK4 nFCT B1 B2 B3
        return 0
    fi
    
    cRoot=$1
    
#    initRunPost ${cRoot}/c05/nx128 0.2 128 $2 $3 $4 $5 $6 $7 $8 $9 ${10} 0
#    initRunPost ${cRoot}/c05/nx064 0.4 64 $2 $3 $4 $5 $6 $7 $8 $9 ${10} 0
#    initRunPost ${cRoot}/c05/nx032 0.8 32 $2 $3 $4 $5 $6 $7 $8 $9 ${10} 0

#    initRunPost ${cRoot}/c1/nx200 0.25 200 $2 $3 $4 $5 $6 $7 $8 $9 ${10} 0
#    initRunPost ${cRoot}/c1/nx100 0.5 100 $2 $3 $4 $5 $6 $7 $8 $9 ${10} 0
#    initRunPost ${cRoot}/c1/nx050 1 50 $2 $3 $4 $5 $6 $7 $8 $9 ${10} 0
#    initRunPost ${cRoot}/c1/nx025 2 25 $2 $3 $4 $5 $6 $7 $8 $9 ${10} 0

#    initRunPost ${cRoot}/c2/nx200 0.5 200 $2 $3 $4 $5 $6 $7 $8 $9 ${10} 0
#    initRunPost ${cRoot}/c2/nx100 1 100 $2 $3 $4 $5 $6 $7 $8 $9 ${10} 0
#    initRunPost ${cRoot}/c2/nx050 2 50 $2 $3 $4 $5 $6 $7 $8 $9 ${10} 0
#    initRunPost ${cRoot}/c2/nx025 4 25 $2 $3 $4 $5 $6 $7 $8 $9 ${10} 0

#    initRunPost ${cRoot}/c5/nx256 1 256 $2 $3 $4 $5 $6 $7 $8 $9 ${10} 0
#    initRunPost ${cRoot}/c5/nx128 2 128 $2 $3 $4 $5 $6 $7 $8 $9 ${10} 0
#    initRunPost ${cRoot}/c5/nx064 4 64 $2 $3 $4 $5 $6 $7 $8 $9 ${10} 0

    # convergence plot
    ./runScripts/plotErrorNorms.sh T $cRoot
}
