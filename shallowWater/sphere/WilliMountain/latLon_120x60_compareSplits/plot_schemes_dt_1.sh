intervals=(1200 2400 3600)

for i in {1,2,3} 
do
    cp -r plotting/ run_scheme_$i/dt_1
    for time in ${intervals[@]};
    do
        (cd run_scheme_$i/dt_1 ; ./plotting/plothU.sh $time)
    done
done
