#!/bin/bash -e

if [ "$#" -ne 2 ]; then
    echo usage: plotFluxes case time
fi

case=$1
t=$2

# Calculate heat and momentum fluxes
foamPostProcess -case $case -func "grad(T)" -time $t
foamPostProcess -case $case -func "components(grad(T))" -time $t
foamPostProcess -case $case -func "multiply(alphat,grad(T)z)" -time $t
foamPostProcess -case $case -func "divide(multiply(alphat,grad(T)z),rho)" -time $t

foamPostProcess -case $case -func "grad(U)" -time $t
foamPostProcess -case $case -func "mag(grad(U))" -time $t
foamPostProcess -case $case -func "multiply(nut,mag(grad(U)))" -time $t

for f in 'divide(multiply(alphat,grad(T)z),rho)' \
         'multiply(nut,mag(grad(U)))'; do
    writeCellDataxyz $f -case $case -time $t
    sed '1d' $case/$time/$f.xyz | sort -k3,3n | sponge $case/$time/$f.xyz
done


# Plots
inputFiles=($case/$t/'divide(multiply(alphat,grad(T)z),rho)'.xyz)
outFile=$case/$t/heatFlux.eps
col=(3)
colx=(4)
xlabel='Heat Flux (K m s@+-1@+)'
ylabel='z (m)'
xmin=-0.03
xmax=0
dx=0.005
ddx=0.0025
dxg=0
ymin=0
ymax=400
dy=50
ddy=25
dyg=0
xscale='*(-1)'
nSkip=1
projection=X15c/10c
gv=0

. gmtPlot

inputFiles=($case/$t/'multiply(nut,mag(grad(U)))'.xyz)
outFile=$case/$t/momFlux.eps
col=(3)
colx=(4)
xlabel='Momentum Flux m@+2@+ s@+-2@+)'
xmin=0
xmax=0.14
dx=0.02
ddx=0
dxg=0
xscale='*1'
nSkip=1
projection=X15c/10c
gv=0

. gmtPlot

rm $case/$t/*grad*
