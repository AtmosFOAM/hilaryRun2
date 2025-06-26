#!/bin/bash -e

# Test cases described in Bendall and Kent 2024 (SWIFT)

# u=10, L=1000, c = 2u dt/dx = 2u dt nx/L = dt nx 2/100

# Check for consistency (T==1 or uniT) yes
# Check using rho==1  yes
# Check order of convergence in space and time
# Mass conservation?

# noDensity is 3rd order for c~0.5
# withDensity is 3rd order for c~0.5, but a bit less accurate

# withDensity with rho==0.8 has identical error to noDensity
# with rho varying like T, is it the same as noRho?
# withDensity with rho varying and T==1, does T stay 1? yes

# For c~1.6, noDensity is better than 2nd order. withDensity is same order
# noDensity c2p6 1st order (alpha=0.609375, gamma=0.990854). Same as withDensit

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/runScripts.sh

# Slotted cylinder cases with density
cRoot=slottedUniformDensity
params="slotted uniform withDensity"

initRunPost ${cRoot}_FCT1_gamma2_2/c05/nx128 $params 0.2 128 plot 1 2 0.5

#initRunPost ${cRoot}_FCT0_gamma2_2/c2p5/nx208 $params 0.5 208 plot 0 2 0.5
initRunPost ${cRoot}_FCT1_gamma2_2/c2p5/nx208 $params 0.5 208 plot 1 2 0.5
initRunPost ${cRoot}_FCT2_gamma2_2/c2p5/nx208 $params 0.5 208 plot 2 2 0.5
initRunPost ${cRoot}_FCT3_gamma2_2/c2p5/nx208 $params 0.5 208 plot 3 2 0.5

./runScripts/plotBounds.sh plots/c2p5_nx208_T \
    ${cRoot}_FCT1_gamma2_2/c2p5/nx208 1-FCT \
    ${cRoot}_FCT2_gamma2_2/c2p5/nx208 2-FCT \
    ${cRoot}_FCT3_gamma2_2/c2p5/nx208 3-FCT

initRunPost ${cRoot}_FCT1_gamma2_2/c05/nx200 $params 0.125 200 plot 1 2 0.5
initRunPost ${cRoot}_FCT1_gamma2_2/c2/nx200  $params 0.5   200 plot 1 2 0.5
initRunPost ${cRoot}_FCT1_gamma2_2/c5/nx200  $params 1.25  200 plot 1 2 0.5
initRunPost ${cRoot}_FCT1_gamma2_2/c10/nx200 $params 2.5   200 plot 1 2 0.5

./runScripts/plotBounds.sh plots/nx200_FCT1_T \
    ${cRoot}_FCT1_gamma2_2/c05/nx200 c-0.5 \
    ${cRoot}_FCT1_gamma2_2/c2/nx200  c-2 \
    ${cRoot}_FCT1_gamma2_2/c5/nx200  c-5 \
    ${cRoot}_FCT1_gamma2_2/c10/nx200 c-10

# Slotted cylinder cases without density
cRoot=slottedUniformNoDensity
params="slotted uniform noDensity"
initRunPost ${cRoot}_FCT3_gamma2_2/c2p5/nx208 $params 0.5 208 plot 3 2 0.5


# Convergence runs (of density)
cRoot=slottedUniformDensity_FCT0_gamma2_2
params="slotted uniform withDensity"
params2="noPlot 0 2 0.5"

initRunPost ${cRoot}/c05/nx032 $params 0.8 32 $params2
initRunPost ${cRoot}/c05/nx064 $params 0.4 64 $params2
initRunPost ${cRoot}/c05/nx128 $params 0.2 128 $params2

initRunPost ${cRoot}/c1p6/nx032 $params 2.5 32 $params2
initRunPost ${cRoot}/c1p6/nx064 $params 1.25 64 $params2
initRunPost ${cRoot}/c1p6/nx128 $params 0.625 128 $params2

initRunPost ${cRoot}/c2/nx025 $params 4 25 $params2
initRunPost ${cRoot}/c2/nx050 $params 2 50 $params2
initRunPost ${cRoot}/c2/nx100 $params 1 100 $params2

initRunPost ${cRoot}/c2p1/nx026 $params 4 26 $params2
initRunPost ${cRoot}/c2p1/nx052 $params 2 52 $params2
initRunPost ${cRoot}/c2p1/nx104 $params 1 104 $params2

initRunPost ${cRoot}/c2p6/nx032 $params 4 32 $params2
initRunPost ${cRoot}/c2p6/nx064 $params 2 64 $params2
initRunPost ${cRoot}/c2p6/nx128 $params 1 128 $params2

initRunPost ${cRoot}/c5p1/nx026 $params 10 26 $params2
initRunPost ${cRoot}/c5p1/nx064 $params 4  64 $params2
initRunPost ${cRoot}/c5p1/nx128 $params 2  128 $params2

initRunPost ${cRoot}/c10/nx050 $params 10  50 $params2
initRunPost ${cRoot}/c10/nx100 $params 5   100 $params2
initRunPost ${cRoot}/c10/nx200 $params 2.5 200 $params2

# convergence plot
./runScripts/plotErrorNorms.sh rho
