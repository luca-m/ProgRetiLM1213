#!/bin/bash
#
#


mkdir data
mkdir data/sim1
mkdir data/sim1/part1
mkdir data/sim1/part2

PATHPART_1=data/sim1/part1
PATHPART_2=data/sim1/part2

# PART 1
# Comparison with same rho and mu
RHO=0.7
MU=0.3
ARRIVALS=1000
SAMPLES=100

echo "Comparison between MM1 and MD1 with same RHO and MU" > $PATHPART_1/note

for n in {0..$ARRIVALS};
do
	touch $PATHPART_1/mm1_$n
	touch $PATHPART_1/md1_$n
	for i in {0..$SAMPLES};
	do
		./mm1prio 0 $n 1 $RHO $MU >> $PATHPART_1/mm1_$n
		./md1prio 0 $n 1 $RHO $MU >> $PATHPART_1/md1_$n
	done
done 

# PART 2

# mean eta with rho in [0,1]
echo "Comparison between MM1 and MD1 with same RHO and MU" > $PATHPART_2/note
for rho in 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 ;
do
	touch $PATHPART_1/mm1_$n
	touch $PATHPART_1/md1_$n
	for i in {0..$SAMPLES};
	do
		./mm1prio 0 $ARRIVALS 1 $rho $MU >> $PATHPART_2/mm1_$rho
		./md1prio 0 $ARRIVALS 1 $rho $MU >> $PATHPART_2/md1_$rho
	done
done 

#Intervallo di confidenza al 95%

#Confronto con i risultati teorici M/D/1 e M/M/1
