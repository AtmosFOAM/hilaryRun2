#!/bin/bash -ve

# monitor funciton minimum value
minVal=1e-5

## create monitor functions for each time-step
#mkdir -p resolutionField
##ncFileIn=/home/hilary/work/pptData/X134.225.102.228.28.5.26.21.nc
#ncFileIn=/home/hilary/work/pptData/X134.225.102.228.28.11.7.47.nc
#t=0
#while [ $t -le 11 ]; do
#    mkdir -p resolutionField/$t
#    ncks -v prate --dimension time,$t,$t $ncFileIn \
#      | grep 'prate\[' | awk '{print $4}' | awk -F'=' '{print $2 + '$minVal'}' \
#      > resolutionField/$t/monitor.dat
#    let t=$t+1
#done

## create lat-lon mesh for the monitor function files
#sphPolarMesh -case resolutionField
#gedit -s resolutionField/constant/polyMesh/boundary

## create the monitor funcitons
#nCells=17666
#t=0
#while [ $t -le 11 ]; do
#    cp resolutionField/constant/monitorHeader resolutionField/$t/monitor
#    echo -e $nCells\\n'('\\n$minVal >> resolutionField/$t/monitor
#    cat resolutionField/$t/monitor.dat >> resolutionField/$t/monitor
#    echo $minVal >> resolutionField/$t/monitor
#    cat resolutionField/constant/monitorFooter >> resolutionField/$t/monitor
#    let t=$t+1
#done


# set up rMeshes for each of the monitor functions
case=.
rm -rf $case/[0-9]*
mkdir $case/0
cp $case/constant/Phi $case/0
cp $case/constant/requiredResolution ../../HR/6/constant/
VoronoiSphereMesh -case $case
polyDualPatch -case $case
meshStructure -case $case '1(originalPatch)'
meshStructure -case $case -region dualMesh '1(originalPatch)'
sed -i -e 's/empty/patch/g' -e 's/inGroups/\/\/inGroups/g' $case/0/polyMesh/boundary
sed -i -e 's/empty/patch/g' -e 's/inGroups/\/\/inGroups/g' $case/0/dualMesh/polyMesh/boundary
# create the mesh to move (copied from original)
mkdir -p $case/0/rMesh
cp -r $case/0/polyMesh $case/0/rMesh
cp $case/constant/Phi $case/0

# create rMeshes for each of the monitor functions
t=0
while [ $t -le 11 ]; do
    rm -rf [1-9]*
    # create monitor field in time directory
    mapFields -fields '(monitor)' -mapMethod cellVolumeWeight -sourceTime $t \
               resolutionField -case $case
    MongeAmpereSphere -case $case
    
    # save results for this case (final time)
    time=`ls -d [0-9]* | sort -n | tail -1`
    mv $case/$time $case/time$t
    rm -rf $case/[1-9]*
    let t=$t+1
done

# rename the results as time directories
changeAllNames time '' time*

# plot the meshes and precipitation fields
for time in [1-9]*; do
    # create plots save latest time and delete the others
    gmtFoam -time $time -case $case/resolutionField ppt
    gmtFoam -time $time -case $case -region rMesh meshOver
    pscoast -R -J -Wthick,navy -Dc -O >> $case/$time/meshOver.ps
    cat $case/resolutionField/$time/ppt.ps $case/$time/meshOver.ps \
        > $case/$time/pptMesh.ps
    pstitle $case/$time/pptMesh $case/$time/pptMesh.ps
    makebb $case/$time/pptMesh.ps
    
    epstopdf $case/$time/pptMesh.ps
    rm $case/resolutionField/$time/ppt.ps $case/$time/meshOver.ps
    gv $case/$time/pptMesh.pdf &
done

eps2gif pptMonitor.gif time?/pptMonitor.ps time??/pptMonitor.ps

# plot just the precip in the same way for time 0
time=0
gmtFoam -time $time -case $case/resolutionField ppt
pscoast -R -J -Wthick,navy -Dc -O >> $case/resolutionField/$time/ppt.ps
pstitle $case/resolutionField/$time/ppt.ps
makebb $case/resolutionField/$time/ppt.ps
eps2png $case/resolutionField/$time/ppt.ps
mv $case/resolutionField/$time/ppt.ps.png movie/pptMesh0.png
xv movie/pptMesh0.png &
rm $case/resolutionField/$time/ppt.ps

# plot just the uniform mesh
time=0
gmtFoam -time $time mesh
pscoast -R -J -Wthick,navy -Dc -O >> $time/mesh.ps
eps2png $time/mesh.ps

# plot just the monitor function
time=0
gmtFoam -time $time ppt
pscoast -R -J -Wthick,navy -Dc -O >> $time/ppt.ps
eps2png $time/ppt.ps

