#!/bin/bash -e

# Test cases described in Bendall and Kent 2024 (SWIFT)

# u=10, L=1000, c = 2u dt/dx = 2u dt nx/L = dt nx 2/100

# Check for consistency (T==1 or uniT)
# with varying velocity
# Check using rho==1   yes
# with varying velocity yes
# Check order of convergence in space and time
# Mass conservation?

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/runScripts.sh

cRoot=smoothUniformNoDensityCubicRK3FCT0
params="smooth uniform noDensity cubicUpwind RK3 0 plot"
#initRunPost ${cRoot}/c05/nx128 0.2 128 $params
#initRunPost ${cRoot}/c5/nx128 2 128 $params

cRoot=smoothUniformUniDensityCubicRK3FCT0
params="smooth uniform uniDensity cubicUpwind RK3 0 plot"
#initRunPost ${cRoot}/c05/nx128 0.2 128 $params
#initRunPost ${cRoot}/c5/nx128 2 128 $params

cRoot=slottedDeformingUniDensityCubicRK3FCT0
params="slotted deforming uniDensity cubicUpwind RK3 0 plot"
#initRunPost ${cRoot}/c05/nx128 0.2 128 $params
#initRunPost ${cRoot}/c5/nx128 2 128 $params

cRoot=uniTDeformingDensityCubicRK3FCT0
params="uniT deforming withDensity cubicUpwind RK3 0 plot"
#initRunPost ${cRoot}/c05/nx128 0.2 128 $params
initRunPost ${cRoot}/c5/nx128 2 128 $params


# convergence plot
./runScripts/plotErrorNorms.sh rho slottedUniformDensity_FCT0_quint
