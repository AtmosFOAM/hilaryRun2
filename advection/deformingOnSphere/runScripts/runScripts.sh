#!/bin/bash -e

# Generate a new mesh for a new case
function meshGen {
    if [ "$#" -lt 2 ]; then
        echo usage: meshGen latLon_0_Full\|latLon_30_Full\|latLon_0_P\|latLon_30_P\|latLon_0_Skipped\|latLon_30_Skipped\|cubedSphere\|hexagonal RES [plot]
        return 1
    fi

    fullMeshType=$1
    res=$2
    plot=$3
    case=''
    read -r meshType rot subType <<<$(echo $fullMeshType \
        | awk -F'_' '{print $1, $2, $3}')
    

    if [[ $meshType  == latLon ]]; then
        let nx=2*$res
        ny=$res
        case=${fullMeshType}/${nx}x${ny}
        mkdir -p $case $case/constant
        cp -r runScripts/system $case
        if [[ ! -a $case/constant/polyMesh/points ]]; then
            nSkip=`if [[ $subType == Skipped ]]; then echo 2; else echo 0; fi`
            polarCell=`if [[ $subType == P ]]; then echo true; else echo false; fi`
            sed -e 's/NX/'$nx'/g' -e 's/NY/'$ny'/g' -e 's/SKIP/'$nSkip'/g' \
                -e 's/ROT/'$rot'/g' -e 's/PCELL/'$polarCell'/g' \
                runScripts/constant/earthProperties \
                    >$case/constant/earthProperties
            sphPolarLatLonMesh -case $case >& $case/sphPolarLatLonMesh.log
        fi
    elif [[ $meshType == cubedSphere ]]; then
        case=${fullMeshType}/${res}x${res}x6
        mkdir -p $case $case/constant
        cp -r runScripts/system $case
        if [[ ! -a $case/constant/polyMesh/points ]]; then
            sed -e "s:NX NX:$res $res:g" runScripts/system/blockMeshDict \
                 > $case/system/blockMeshDict
            blockMesh -case $case >& $case/blockMesh.log
            tanPoints -case $case >& $case/tanPoints.log
            sed -i -e 's:SOURCECASE:'$case':g' -e 's:FROM:patch:g' \
                   -e 's:FLIP:false:g' $case/system/extrudeMeshDict
            extrudeMesh -case $case >& $case/extrudeMesh.log
        fi
    elif [[ $meshType == hexagonal ]]; then
        case=$fullMeshType/hex${res}
        mkdir -p $case $case/constant
        cp -r runScripts/system $case
        if [[ ! -a $case/constant/polyMesh/points ]]; then
            cp $HOME/f77/buckyball_griddata/grid$res.out/patch.obj $case/constant
            sed -i -e 's:SOURCECASE:'$case':g' -e 's:FROM:surface:g' \
                   -e 's:FLIP:true:g' $case/system/extrudeMeshDict
            extrudeMesh -case $case >& $case/extrudeMesh.log
        fi
    fi
    
    if [[ -a $case/constant/polyMesh/points ]]; then
        ln -sf ../../../runScripts/gmtDicts $case/constant/gmtDicts
    
        if [[ $plot == plot ]]; then
            gmtFoam -case $case mesh >& $case/gmtFoam.log
            ev $case/constant/mesh.pdf
        fi
    fi
    echo $case
}

function initialise {
    if [ "$#" -lt 4 ]; then
        echo usage: initialise caseRoot smooth\|slotted \
                    noDensity\|uniDensity\|varyDensity deforming [plot]
        return 1
    fi
    caseRoot=$1
    tracerType=$2
    densityType=$3
    velocityType=$4
    plot=$5
    case=$caseRoot/${tracerType}${densityType}${velocityType}
    
    if [[ ! -e $caseRoot ]]; then
        echo initialise case $case
        echo but $caseRoot does not exist
        return 1
    fi

    if [[ ! -a $case/0/T ]]; then
        mkdir -p $case $case/constant
        cp -r $caseRoot/system $case/system
        ln -sf ../../constant/polyMesh $case/constant/polyMesh
        rm -rf $case/0
        cp -r runScripts/init0 $case/0
        cp runScripts/constant/${velocityType}VelocityDict $case/constant/velocityDict
        cp runScripts/constant/${tracerType}TracerDict $case/constant/tracerDict
        ln -sf ../../../../runScripts/gmtDicts $case/constant/gmtDicts
        cp runScripts/constant/physicalProperties \
           runScripts/constant/momentumTransport $case/constant
        setVelocityField -case $case -dict velocityDict \
            >& $case/setVelocityField.log
        setTracerField -case $case -name T -tracerDict tracerDict \
            >& $case/setTracerField.log
        if [[ $plot == plot ]]; then
            gmtFoam -case $case -time 0 UT >& $case/gmtFoam.log
            ev $case/0/UT.pdf
        fi
        if [[ $densityType == varyDensity ]]; then
            cp runScripts/system/functionsWithDensity \
                $case/system/functions
            cp runScripts/constant/rhoTracerDict $case/constant
            setTracerField -case $case -name rho -tracerDict rhoTracerDict \
                >& $case/setRhoField.log
            if [[ $plot == plot ]]; then
                gmtFoam -case $case -time 0 rhoU >& $case/gmtFoam.log
                ev $case/0/rhoU.pdf
            fi
        fi
    fi
    echo $case
}

function testCase {
    if [ "$#" -ne 5 ]; then
        echo usage: testCase caseRoot dt cubicUpwind\|quinticUpwind RK3\|RK4 nFCT
        return 1
    fi
    caseRoot=$1
    dt=$2
    spaceScheme=$3
    timeScheme=$4
    nFCT=$5

    DT=`echo $dt | sed 's/\./p/g'`
    case=$caseRoot/dt_${DT}_${spaceScheme}_${timeScheme}_FCT${nFCT}
    if [[ ! -e $caseRoot ]]; then
        echo testCase case $case
        echo but $caseRoot does not exist
        return 1
    fi

    if [[ $spaceScheme == quinticUpwind ]]; then
        BETACOEFFS='1.7 0.45 0.39'
    elif [[ $spaceScheme == cubicUpwind ]]; then
        BETACOEFFS='1.6 0.43 0.43'
    else
        echo spaceScheme $spaceScheme not known. Known schemes are cubicUpwind and quinticUpwind
        return 1
    fi
    
    if [[ $timeScheme == RK3 ]]; then
        RK='3 3((1 0 0)\n                        (0.25 0.25 0)                        (0.16666666667 0.16666666667 0.66666666666))'
    elif [[ $timeScheme == RK4 ]]; then
        RK='4 4((0.5 0 0 0)\n          (0 0.5 0 0)\n          (0 0 1 0)\n          (0.16666666667 0.33333333333 0.33333333333 0.16666666667))'
    else
        echo timeScheme $timeScheme not known. Known schemes are RK3 and RK4
        return 1
    fi
    
    mkdir -p $case $case/system
    ln -sf ../0 $case/0
    ln -sf ../constant $case/constant
    sed 's/DT/'$dt'/g' runScripts/system/controlDictDT > $case/system/controlDict
    cp runScripts/system/fvSchemes runScripts/system/fvSolution $case/system
    sed -e 's/NFCT/'$nFCT'/g' -e "s:RKCOEFFS:$RK:g" \
        -e "s:BETACOEFFS:$BETACOEFFS:g" -e 's/CORRSCHEME/'$spaceScheme'/g' \
        $caseRoot/system/functions > $case/system/functions
    echo $case
}

function initRun {
    if [ "$#" -lt 9 ]; then
        echo usage: initRunPost meshType nx tracerType densityType velocityType\
                    dt cubicUpwind\|quinticUpwind RK3\|RK4 nFCT [plot]
        return 1
    fi
    meshType=$1
    nx=$2
    tracerType=$3
    densityType=$4
    velocityType=$5
    dt=$6
    spaceScheme=$7
    timeScheme=$8
    nFCT=$9
    plot=${10}
    case=`meshGen $meshType $nx $plot`
    echo $case
    ls $case/*.log
    case=`initialise $case $tracerType $densityType $velocityType $plot`
    echo $case
    ls $case/*.log
    case=`testCase $case $dt $spaceScheme $timeScheme $nFCT`
    echo $case
    foamRun -case $case >& $case/log &
    echo Running with output in $case/log
}

function postOne {
    if [ "$#" -lt 1 ]; then
        echo usage: postOne case [plot]
        return 1
    fi
    
    case=$1
    T=5
    errorNorms $case 0 T $T T
    logStats.sh $case T
    rm $case/c.dat
    times=(`grep ^Time $case/log | awk -F'=' '{print $2}' | awk -F's' '{print $1}'`)
    cs=(`grep  "^Co goes from" $case/log | awk '{print $6}'`)
    Tmins=(`grep "^T goes from" $case/log | awk '{print $5}'`)
    Tmaxs=(`grep "^T goes from" $case/log | awk '{print $9}'`)
    
    echo "#Time maxC Tmin Tmax-1" > $case/cTminmax.dat
    echo -e ${times[*]}\\n${cs[*]}\\n${Tmins[*]}\\n${Tmaxs[*]} | \
        awk '{ for (i=1; i<=NF; i++) a[i]= (a[i]? a[i] FS $i: $i) } END{ for (i in a) print a[i] }' >> $case/cTminmax.dat

    withRho=1
    if [[ ! -a $case/$T/rho ]]; then
        withRho=0
    else
        uni=`grep -a uniform $case/0/rho | awk '{print $2}'`
        if [[ $uni == uniform ]]; then
            withRho=0
        fi
    fi
        
    if [[ $2 == plot ]]; then
        foamPostProcess -case $case -time 2.5 -func CourantNoU
        gmtFoam -case $case -time 2.5 Tslot
        foamPostProcess -case $case -time $T -func CourantNoU
        gmtFoam -case $case -time $T Tslot
        ev $case/*/Tslot.pdf
        
        if [[ $withRho == 1 ]]; then
            gmtFoam -case $case -time 2.5 rho
            gmtFoam -case $case -time 5 rho
            ev $case/*/rho.pdf
        fi
    fi
}

function plotStats {
    cases=("latLon_0_Full/480x240/slotteddeforming/dt_0p0025_quinticUpwind_RK4_FCT1"
           "latLon_30_Full/480x240/slotteddeforming/dt_0p0025_quinticUpwind_RK4_FCT1"
           "cubedSphere/120x120x6/slotteddeforming/dt_0p0025_quinticUpwind_RK4_FCT1"
           "hexagonal/hex8/slotteddeforming/dt_0p0025_quinticUpwind_RK4_FCT1")
    legends=('Lat-lon' 'Lat-lon rotated' 'Cubed sphere' 'Hexagonal')
    pens=("0.5,black" "0.5,blue" "0.5,red" "0.5,green")
    gv=0; nSkip=1; legPos=x1/0.5
    xlabel="Time"; xmin=0; xmax=5; dx=1; ddx=0.5; 
    
    inputFiles=`makeInputFiles cTminmax.dat ${cases[*]}`;inputFiles=($inputFiles)
    echo ${inputFiles[*]}

    outFile=plots/TMin.eps; col=3;
    ylabel="min @~y@~ - 0.1"; ymin=-1e-6; ymax=1e-6; dy=1e-6; ddy=1e-6
    projection=X15c/5c; yscale="-0.1"
    source gmtPlot
    makebb $outFile > /dev/null
    ev $outFile
    
    outFile=plots/TMax.eps; col=4; xlabel=""
    ylabel="max @~y@~ - 1"; ymin=-4e-4; ymax=1e-4; dy=1e-4; ddy=1e-4
    projection=X15c/5c; yscale=""
    source gmtPlot
    makebb $outFile > /dev/null
    ev $outFile

    echo -e "\n0 1\n5 1" > plots/c1.dat
    echo -e "\n0 1.7\n5 1.7" > plots/c1p7.dat
    inputFiles=(${inputFiles[*]} plots/c1.dat plots/c1p7.dat)
    legends+=('c = 1' 'c = 1.7')
    pens=(${pens[*]} "0.25,black,1-1" "0.25,black,1-1")
    outFile=plots/cMax.eps; col=2; 
    ylabel="Courant number"; ymin=0.1; ymax=100; dy=10; ddy=10
    projection=X15c/10cl; legPos=x1/4.5
    source gmtPlot
    ev $outFile
}

function plotStats2 {
    cases=("latLon_0_P/480x240/slottedvaryDensitydeforming/dt_0p0025_quinticUpwind_RK4_FCT1"
           "latLon_30_P/480x240/slottedvaryDensitydeforming/dt_0p0025_quinticUpwind_RK4_FCT1"
           "cubedSphere/120x120x6/slottedvaryDensitydeforming/dt_0p0025_quinticUpwind_RK4_FCT1"
           "hexagonal/hex8/slottedvaryDensitydeforming/dt_0p0025_quinticUpwind_RK4_FCT1")
    legends=('Lat-lon' 'Lat-lon rotated' 'Cubed sphere' 'Hexagonal')
    pens=("0.5,black" "0.5,blue" "0.5,red" "0.5,green")
    gv=0; nSkip=1; legPos=x1/0.5; colx=1
    xlabel="Time"; xmin=0; xmax=5; dx=1; ddx=0.5; 
    
    inputFiles=`makeInputFiles cTminmax.dat ${cases[*]}`;inputFiles=($inputFiles)
    echo ${inputFiles[*]}

    outFile=plots/varyDensityTMin.eps; col=3;
    ylabel="min @~y@~ - 0.1"; ymin=-1e-6; ymax=1e-6; dy=1e-6; ddy=1e-6
    projection=X15c/5c; yscale="-0.1"
    source gmtPlot
    makebb $outFile > /dev/null
    ev $outFile
    
    outFile=plots/varyDensityTMax.eps; col=4; xlabel=""
    ylabel="max @~y@~ - 1"; ymin=-4e-4; ymax=1e-4; dy=1e-4; ddy=1e-4
    projection=X15c/5c; yscale=""
    source gmtPlot
    makebb $outFile > /dev/null
    ev $outFile

    echo -e "\n0 1\n5 1" > plots/c1.dat
    echo -e "\n0 1.7\n5 1.7" > plots/c1p7.dat
    inputFiles=(${inputFiles[*]} plots/c1.dat plots/c1p7.dat)
    legends+=('c = 1' 'c = 1.7')
    pens=(${pens[*]} "0.25,black,1-1" "0.25,black,1-1")
    outFile=plots/varyDensitycMax.eps; col=2; 
    ylabel="Courant number"; ymin=0.1; ymax=100; dy=10; ddy=10
    projection=X15c/10cl; legPos=x1/4.5
    source gmtPlot
    ev $outFile
}

function makeInputFiles {
    file=$1
    shift
    files=()
    for dir in ${*}; do
        files=(${files[*]} $dir/$file)
    done
    echo ${files[*]}
}