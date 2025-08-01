#!/bin/bash -e

# Test cases described in Bendall and Kent 2024 (SWIFT)

# u=10, L=1000, c = 2u dt/dx = 2u dt nx/L = dt nx 2/100

# Check for consistency (T==1 or uniT) yes
# with varying velocity yes
# Check using rho==1   
# with varying velocity 
# Check order of convergence in space and time
# Mass conservation?

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/runScripts.sh

cRoot=smoothUniformNoDensityCubicRK3FCT0
params="smooth uniform noDensity cubicUpwind RK3 0 1.6 0.43 0.43 plot"
#initRunPost ${cRoot}/c05/nx128 0.2 128 $params
#initRunPost ${cRoot}/c5/nx128 2 128 $params

cRoot=smoothUniformUniDensityCubicRK3FCT0
params="smooth uniform uniDensity cubicUpwind RK3 0 1.6 0.43 0.43 plot"
#initRunPost ${cRoot}/c05/nx128 0.2 128 $params
#initRunPost ${cRoot}/c5/nx128 2 128 $params

cRoot=uniTDeformingWithDensityCubicRK3FCT0
params="uniT deforming withDensity cubicUpwind RK3 0 1.6 0.43 0.43 plot"
#initRunPost ${cRoot}/c05/nx128 0.2 128 $params
#initRunPost ${cRoot}/c5/nx128 2 128 $params

cRoot=slottedDeformingUniDensityCubicRK3FCT0
params="slotted deforming uniDensity cubicUpwind RK3 0 1.6 0.43 0.43 plot"
#initRunPost ${cRoot}/c05/nx128 0.2 128 $params
#initRunPost ${cRoot}/c5/nx128 2 128 $params

cRoot=slottedDeformingWithDensityCubicRK3FCT0
params="slotted deforming withDensity cubicUpwind RK3 0 1.6 0.43 0.43 plot"
#initRunPost ${cRoot}/c05/nx128 0.2 128 $params
#initRunPost ${cRoot}/c5/nx128 2 128 $params

cRoot=slottedUniformNoDensityCubicRK3FCT1
params="slotted uniform noDensity cubicUpwind RK3 1 1.6 0.43 0.43 plot"
#initRunPost ${cRoot}/c05/nx128 0.2 128 $params
#initRunPost ${cRoot}/c5/nx128 2 128 $params

cRoot=slottedDeformingNoDensityCubicRK3FCT1
params="slotted deforming noDensity cubicUpwind RK3 1 1.6 0.43 0.43 plot"
#initRunPost ${cRoot}/c05/nx128 0.2 128 $params
#initRunPost ${cRoot}/c5/nx128 2 128 $params

cRoot=slottedUniformWithDensityCubicRK3FCT1
params="slotted uniform withDensity cubicUpwind RK3 1 1.6 0.43 0.43 plot"
#initRunPost ${cRoot}/c05/nx128 0.2 128 $params
#initRunPost ${cRoot}/c5/nx128 2 128 $params

cRoot=slottedDeformingWithDensityCubicRK3FCT0
params="slotted deforming withDensity cubicUpwind RK3 0 1.6 0.43 0.43 plot"
#initRunPost ${cRoot}/c05/nx128 0.2 128 $params
#initRunPost ${cRoot}/c5/nx128 2 128 $params

cRoot=slottedDeformingWithDensityQuinticRK4FCT1
params="slotted deforming withDensity quinticUpwind RK4 1 1.7 0.45 0.39 plot"
#initRunPost ${cRoot}/c05/nx128 0.2 128 $params
#initRunPost ${cRoot}/c5/nx128 2 128 $params

cRoot=slottedDeformingWithDensityQuinticRK4FCT0
params="slotted deforming withDensity quinticUpwind RK4 0 1.7 0.45 0.39 plot"
#initRunPost ${cRoot}/c05/nx128 0.2 128 $params
#initRunPost ${cRoot}/c5/nx128 2 128 $params

cRoot=slottedDeformingNoDensityQuinticRK4FCT0
params="slotted deforming noDensity quinticUpwind RK4 0 1.7 0.45 0.39 plot"
#initRunPost ${cRoot}/c05/nx128 0.2 128 $params
#initRunPost ${cRoot}/c5/nx128 2 128 $params

cRoot=slottedDeformingNoDensityQuinticRK4FCT1
params="slotted deforming noDensity quinticUpwind RK4 1 1.7 0.45 0.39 plot"
#initRunPost ${cRoot}/c05/nx128 0.2 128 $params
#initRunPost ${cRoot}/c5/nx128 2 128 $params

cRoot=slottedUniformUniDensityCubicRK3FCT1
params="slotted uniform uniDensity cubicUpwind RK3 1 plot"
#initRunPost ${cRoot}/c05/nx128 0.2 128 $params

cRoot=slottedUniformUniDensityCubicRK3FCT0
params="slotted uniform uniDensity cubicUpwind RK3 0 plot"
#initRunPost ${cRoot}/c05/nx128 0.2 128 $params

cRoot=slottedUniformWithDensityCubicRK3FCT0
params="slotted uniform withDensity cubicUpwind RK3 0 plot"
#initRunPost ${cRoot}/c05/nx128 0.2 128 $params

# Convergence runs
cRoot=smoothUniformNoDensityQuinticRK4FCT0
params="smooth uniform noDensity quinticUpwind RK4 0 1.7 0.45 0.39"
#convergenceTest $cRoot $params

cRoot=smoothUniformNoDensityQuinticRK4FCT1
params="smooth uniform noDensity quinticUpwind RK4 1 1.7 0.45 0.39"
#convergenceTest $cRoot $params

cRoot=smoothUniformWithDensityQuinticRK4FCT0
params="smooth uniform withDensity quinticUpwind RK4 0 1.7 0.45 0.39"
#convergenceTest $cRoot $params

cRoot=smoothUniformWithDensityQuinticRK4FCT1
params="smooth uniform withDensity quinticUpwind RK4 1 1.7 0.45 0.39"
#convergenceTest $cRoot $params

cRoot=smoothDeformingWithDensityQuinticRK4FCT0
params="smooth deforming withDensity quinticUpwind RK4 0 1.7 0.45 0.39"
#convergenceTest $cRoot $params

cRoot=smoothDeformingWithDensityQuinticRK4FCT1
params="smooth deforming withDensity quinticUpwind RK4 1 1.7 0.45 0.39"
#convergenceTest $cRoot $params

cRoot=smoothDeformingWithDensityCubicRK3FCT0
params="smooth deforming withDensity cubicUpwind RK3 0 1.6 0.43 0.43"
#convergenceTest $cRoot $params

cRoot=smoothDeformingWithDensityCubicRK3FCT1
params="smooth deforming withDensity cubicUpwind RK3 1 1.6 0.43 0.43"
#convergenceTest $cRoot $params

cRoot=smoothUniformWithDensityCubicRK3FCT0
params="smooth uniform withDensity cubicUpwind RK3 0 1.6 0.43 0.43"
#convergenceTest $cRoot $params

cRoot=smoothUniformNoDensityCubicRK3FCT0
params="smooth uniform noDensity cubicUpwind RK3 0 1.6 0.43 0.43"
#convergenceTest $cRoot $params
