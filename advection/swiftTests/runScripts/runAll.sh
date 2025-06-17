#!/bin/bash -e

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

pset0="noDensity c05 0.8 32"
pset1="noDensity c05 0.4 64"
pset2="noDensity c05 0.2 128"

pset0="noDensity c2p6 4 32"
pset1="noDensity c2p6 2 64"
pset2="noDensity c2p6 1 128"

pset0="withDensity c05 0.8 32"
pset1="withDensity c05 0.4 64"
pset2="withDensity c05 0.2 128"

pset0="withDensity c1p6 2.5 32"
pset1="withDensity c1p6 1.25 64"
pset2="withDensity c1p6 0.625 128"

pset0="withDensity c2p6 4 32"
pset1="withDensity c2p6 2 64"
pset2="withDensity c2p6 1 128"

for p in "${pset0}" "${pset1}" "${pset2}"; do
    p=($p)
    dens=${p[0]}
    c=${p[1]}
    dt=${p[2]}
    nx=${p[3]}
    case=smoothUniform${dens}/$c/nx${nx}
    echo $case
    rm -rf $case
    ./runScripts/initOne.sh $case smooth uniform $dens $dt $nx
    ./runScripts/runOne.sh $case
    ./runScripts/postOne.sh $case
done

# convergence plot
./runScripts/plotErrorNorms.sh
