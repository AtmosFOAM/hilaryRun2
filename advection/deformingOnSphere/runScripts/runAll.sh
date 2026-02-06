;#!/bin/bash -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/runScripts.sh

initRun latLon_30_Full 120 slotted deforming 0.005 cubicUpwind RK3 1 #plot
postOne latLon_30_Full/240x120/slotteddeforming/dt_0p005_cubicUpwind_RK3_FCT1 plot
initRun latLon_30_Full 120 slotted deforming 0.005 quinticUpwind RK4 1 #plot
postOne latLon_30_Full/240x120/slotteddeforming/dt_0p005_quinticUpwind_RK4_FCT1 plot

initRun latLon_30_Full 240 slotted deforming 0.0025 quinticUpwind RK4 1 #plot
postOne latLon_30_Full/480x240/slotteddeforming/dt_0p0025_quinticUpwind_RK4_FCT1 plot

initRun latLon_0_Full 240 slotted deforming 0.0025 quinticUpwind RK4 1 #plot
postOne latLon_0_Full/480x240/slotteddeforming/dt_0p0025_quinticUpwind_RK4_FCT1 plot

initRun latLon_0_Skip 240 slotted deforming 0.0025 quinticUpwind RK4 1 #plot
postOne latLon_0_Skip/480x240/slotteddeforming/dt_0p0025_quinticUpwind_RK4_FCT1 plot

initRun cubedSphere 30 slotted deforming 0.01 quinticUpwind RK4 1 #plot
postOne cubedSphere/30x30x6/slotteddeforming/dt_0p01_quinticUpwind_RK4_FCT1 plot

initRun cubedSphere 120 slotted deforming 0.0025 quinticUpwind RK4 1 #plot
postOne cubedSphere/120x120x6/slotteddeforming/dt_0p0025_quinticUpwind_RK4_FCT1 plot

initRun hexagonal 5 slotted deforming 0.02 quinticUpwind RK4 1 plot
postOne  hexagonal/hex5/slotteddeforming/dt_0p02_quinticUpwind_RK4_FCT1 plot

initRun hexagonal 8 slotted deforming 0.0025 quinticUpwind RK4 1 plot
postOne  hexagonal/hex8/slotteddeforming/dt_0p0025_quinticUpwind_RK4_FCT1 plot

plotStats

# HeteroSphere Transport - re-running everything with a larger timestep
###############################################
# Convergence with Resolution
initRun latLon_30_P 240 smooth varyDensity deforming 0.005 quinticUpwind RK4 0
initRun latLon_30_P 120 smooth varyDensity deforming 0.01 quinticUpwind RK4 0
initRun latLon_30_P 60 smooth varyDensity deforming 0.02 quinticUpwind RK4 0

initRun latLon_0_P 240 smooth varyDensity deforming 0.005 quinticUpwind RK4 0
initRun latLon_0_P 120 smooth varyDensity deforming 0.01 quinticUpwind RK4 0
initRun latLon_0_P 60 smooth varyDensity deforming 0.02 quinticUpwind RK4 0

initRun cubedSphere 120 smooth varyDensity deforming 0.005 quinticUpwind RK4 0
initRun cubedSphere 60 smooth varyDensity deforming 0.01 quinticUpwind RK4 0
initRun cubedSphere 30 smooth varyDensity deforming 0.02 quinticUpwind RK4 0

initRun hexagonal 8 smooth varyDensity deforming 0.005 quinticUpwind RK4 0
initRun hexagonal 7 smooth varyDensity deforming 0.01 quinticUpwind RK4 0
initRun hexagonal 6 smooth varyDensity deforming 0.02 quinticUpwind RK4 0
initRun hexagonal 5 smooth varyDensity deforming 0.04 quinticUpwind RK4 0

./runScripts/plotErrorNorms.sh T smoothvaryDensitydeforming quinticUpwind_RK4_FCT0 0.005

initRun latLon_30_P 240 smooth varyDensity deforming 0.005 cubicUpwind RK3 0
initRun latLon_30_P 120 smooth varyDensity deforming 0.01 cubicUpwind RK3 0
initRun latLon_30_P 60 smooth varyDensity deforming 0.02 cubicUpwind RK3 0

initRun latLon_0_P 240 smooth varyDensity deforming 0.005 cubicUpwind RK3 0
initRun latLon_0_P 120 smooth varyDensity deforming 0.01 cubicUpwind RK3 0
initRun latLon_0_P 60 smooth varyDensity deforming 0.02 cubicUpwind RK3 0

initRun cubedSphere 120 smooth varyDensity deforming 0.005 cubicUpwind RK3 0
initRun cubedSphere 60 smooth varyDensity deforming 0.01 cubicUpwind RK3 0
initRun cubedSphere 30 smooth varyDensity deforming 0.02 cubicUpwind RK3 0

initRun hexagonal 8 smooth varyDensity deforming 0.005 cubicUpwind RK3 0
initRun hexagonal 7 smooth varyDensity deforming 0.01 cubicUpwind RK3 0
initRun hexagonal 6 smooth varyDensity deforming 0.02 cubicUpwind RK3 0
initRun hexagonal 5 smooth varyDensity deforming 0.04 cubicUpwind RK3 0

./runScripts/plotErrorNorms.sh T smoothvaryDensitydeforming cubicUpwind_RK3_FCT0 0.005

initRun latLon_30_P 240 smooth noDensity deforming 0.005 quinticUpwind RK4 0
initRun latLon_30_P 120 smooth noDensity deforming 0.01 quinticUpwind RK4 0
initRun latLon_30_P 60 smooth noDensity deforming 0.02 quinticUpwind RK4 0

initRun latLon_0_P 240 smooth noDensity deforming 0.005 quinticUpwind RK4 0
initRun latLon_0_P 120 smooth noDensity deforming 0.01 quinticUpwind RK4 0
initRun latLon_0_P 60 smooth noDensity deforming 0.02 quinticUpwind RK4 0

initRun cubedSphere 120 smooth noDensity deforming 0.005 quinticUpwind RK4 0
initRun cubedSphere 60 smooth noDensity deforming 0.01 quinticUpwind RK4 0
initRun cubedSphere 30 smooth noDensity deforming 0.02 quinticUpwind RK4 0

initRun hexagonal 8 smooth noDensity deforming 0.005 quinticUpwind RK4 0
initRun hexagonal 7 smooth noDensity deforming 0.01 quinticUpwind RK4 0
initRun hexagonal 6 smooth noDensity deforming 0.02 quinticUpwind RK4 0
initRun hexagonal 5 smooth noDensity deforming 0.04 quinticUpwind RK4 0

./runScripts/plotErrorNorms.sh T smoothnoDensitydeforming quinticUpwind_RK4_FCT0 0.005

plotStats2

# High resolution plots
for case in */*/smoothvaryDensitydeforming/dt_0p01_quinticUpwind_RK4_FCT0 \
            */*/smoothvaryDensitydeforming/dt_0p005_quinticUpwind_RK4_FCT0; do
    postOne $case plot
done

# Slotted cylinder with larger time step
initRun latLon_30_P 240 slotted varyDensity deforming 0.005 quinticUpwind RK4 1
initRun latLon_0_P  240 slotted varyDensity deforming 0.005 quinticUpwind RK4 1
initRun cubedSphere 120 slotted varyDensity deforming 0.005 quinticUpwind RK4 1
initRun hexagonal   8   slotted varyDensity deforming 0.005 quinticUpwind RK4 1
for case in */*/slottedvaryDensitydeforming/dt_0p005_quinticUpwind_RK4_FCT1; do \
    postOne $case plot; done

plotStats2


# HeteroSphere Transport - old simulations
###############################################

initRun latLon_30_Full 120 slotted varyDensity deforming 0.005 cubicUpwind RK3 1 plot
postOne latLon_30_Full/240x120/slottedvaryDensitydeforming/dt_0p005_cubicUpwind_RK3_FCT1 plot

# Convergence with Resolution
initRun latLon_30_P 240 smooth varyDensity deforming 0.0025 quinticUpwind RK4 0
initRun latLon_30_P 120 smooth varyDensity deforming 0.005 quinticUpwind RK4 0
initRun latLon_30_P 60 smooth varyDensity deforming 0.01 quinticUpwind RK4 0

initRun latLon_0_P 240 smooth varyDensity deforming 0.0025 quinticUpwind RK4 0
initRun latLon_0_P 120 smooth varyDensity deforming 0.005 quinticUpwind RK4 0
initRun latLon_0_P 60 smooth varyDensity deforming 0.01 quinticUpwind RK4 0

initRun cubedSphere 120 smooth varyDensity deforming 0.0025 quinticUpwind RK4 0
initRun cubedSphere 60 smooth varyDensity deforming 0.005 quinticUpwind RK4 0
initRun cubedSphere 30 smooth varyDensity deforming 0.01 quinticUpwind RK4 0

initRun hexagonal 8 smooth varyDensity deforming 0.0025 quinticUpwind RK4 0
initRun hexagonal 7 smooth varyDensity deforming 0.005 quinticUpwind RK4 0
initRun hexagonal 6 smooth varyDensity deforming 0.01 quinticUpwind RK4 0
initRun hexagonal 5 smooth varyDensity deforming 0.02 quinticUpwind RK4 0

./runScripts/plotErrorNorms.sh T smoothvaryDensitydeforming quinticUpwind_RK4_FCT0

initRun latLon_30_P 240 smooth varyDensity deforming 0.0025 cubicUpwind RK3 0
initRun latLon_30_P 120 smooth varyDensity deforming 0.005 cubicUpwind RK3 0
initRun latLon_30_P 60 smooth varyDensity deforming 0.01 cubicUpwind RK3 0

initRun latLon_0_P 240 smooth varyDensity deforming 0.0025 cubicUpwind RK3 0
initRun latLon_0_P 120 smooth varyDensity deforming 0.005 cubicUpwind RK3 0
initRun latLon_0_P 60 smooth varyDensity deforming 0.01 cubicUpwind RK3 0

initRun cubedSphere 120 smooth varyDensity deforming 0.0025 cubicUpwind RK3 0
initRun cubedSphere 60 smooth varyDensity deforming 0.005 cubicUpwind RK3 0
initRun cubedSphere 30 smooth varyDensity deforming 0.01 cubicUpwind RK3 0

initRun hexagonal 8 smooth varyDensity deforming 0.0025 cubicUpwind RK3 0
initRun hexagonal 7 smooth varyDensity deforming 0.005 cubicUpwind RK3 0
initRun hexagonal 6 smooth varyDensity deforming 0.01 cubicUpwind RK3 0
initRun hexagonal 5 smooth varyDensity deforming 0.02 cubicUpwind RK3 0

./runScripts/plotErrorNorms.sh T smoothvaryDensitydeforming cubicUpwind_RK3_FCT0

initRun latLon_30_P 240 smooth noDensity deforming 0.0025 quinticUpwind RK4 0
initRun latLon_30_P 120 smooth noDensity deforming 0.005 quinticUpwind RK4 0
initRun latLon_30_P 60 smooth noDensity deforming 0.01 quinticUpwind RK4 0

initRun latLon_0_P 240 smooth noDensity deforming 0.0025 quinticUpwind RK4 0
initRun latLon_0_P 120 smooth noDensity deforming 0.005 quinticUpwind RK4 0
initRun latLon_0_P 60 smooth noDensity deforming 0.01 quinticUpwind RK4 0

initRun cubedSphere 120 smooth noDensity deforming 0.0025 quinticUpwind RK4 0
initRun cubedSphere 60 smooth noDensity deforming 0.005 quinticUpwind RK4 0
initRun cubedSphere 30 smooth noDensity deforming 0.01 quinticUpwind RK4 0

initRun hexagonal 8 smooth noDensity deforming 0.0025 quinticUpwind RK4 0
initRun hexagonal 7 smooth noDensity deforming 0.005 quinticUpwind RK4 0
initRun hexagonal 6 smooth noDensity deforming 0.01 quinticUpwind RK4 0
initRun hexagonal 5 smooth noDensity deforming 0.02 quinticUpwind RK4 0

./runScripts/plotErrorNorms.sh T smoothnoDensitydeforming quinticUpwind_RK4_FCT0

# HeteroSphere Transport Slotted cylinder
initRun latLon_30_P 240 slotted varyDensity deforming 0.0025 quinticUpwind RK4 1
initRun latLon_0_P  240 slotted varyDensity deforming 0.0025 quinticUpwind RK4 1
initRun cubedSphere 120 slotted varyDensity deforming 0.0025 quinticUpwind RK4 1
initRun hexagonal   8   slotted varyDensity deforming 0.0025 quinticUpwind RK4 1
for case in */*/slottedvaryDensitydeforming/dt_0p0025_quinticUpwind_RK4_FCT1; do \
    postOne $case plot; done

plotStats2
