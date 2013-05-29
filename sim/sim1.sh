#!/bin/bash
#
#

if [ "$1" == "clean" ]
then 
	echo "Cleaning previos simulation data"
	rm -r data/
fi


mkdir data 2>/dev/null
mkdir data/sim1 2>/dev/null
mkdir data/sim1/part1 2>/dev/null
mkdir data/sim1/part2 2>/dev/null
mkdir data/sim1/part1/raw 2>/dev/null
mkdir data/sim1/part2/raw 2>/dev/null

PATHPART_1=data/sim1/part1
PATHPART_2=data/sim1/part2


echo "> PART 1"

RHO=0.7
MU=0.3
ARRIVALS=500
SAMPLES=50
CONF=0.95
FIELDNAME='eta_mean'
seed=1

echo "Comparison between MM1 and MD1 with same RHO and MU"
echo "Field $FIELDNAME confidence interval $CONF" 
echo "Simulating:"

echo "Comparison between MM1 and MD1 with same RHO and MU" > $PATHPART_1/note
echo "Eta mean confidence interval $CONF" >> $PATHPART_1/note
touch $PATHPART_1/mm1.csv
touch $PATHPART_1/md1.csv
echo "# arrivals, rho, mu, eta, eta_mean, min_$FIELDNAME, max_$FIELDNAME" > $PATHPART_1/mm1.csv
echo "# arrivals, rho, mu, eta, eta_mean, min_$FIELDNAME, max_$FIELDNAME" > $PATHPART_1/md1.csv

for ((n=0;n<=$ARRIVALS;n++)) 
do
	echo -n "."
	touch $PATHPART_1/raw/mm1_$n
	touch $PATHPART_1/raw/md1_$n
	echo "# arrivals, rho, mu, eta, eta_mean" > $PATHPART_1/raw/mm1_$n
	echo "# arrivals, rho, mu, eta, eta_mean" > $PATHPART_1/raw/md1_$n
	for ((i=0;i<=$SAMPLES;i++))
	do
		seed=`expr $seed + 9`
		./mm1prio $seed $n 1 $RHO $MU >> $PATHPART_1/raw/mm1_$n
		./md1prio $seed $n 1 $RHO $MU >> $PATHPART_1/raw/md1_$n
	done

	./confidence_interval.R $PATHPART_1/raw/mm1_$n $FIELDNAME $CONF 2>/dev/null >> $PATHPART_1/mm1.csv
	./confidence_interval.R $PATHPART_1/raw/md1_$n $FIELDNAME $CONF 2>/dev/null >> $PATHPART_1/md1.csv
done 
echo ""
echo "Results in $PATHPART_1/mm1.csv and $PATHPART_1/md1.csv "

# PART 2

# mean eta with rho in [0,1]
#echo "Comparison between MM1 and MD1 with same RHO and MU" > $PATHPART_2/note
#for rho in 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 ;
#do
#	touch $PATHPART_1/mm1_$n
#	touch $PATHPART_1/md1_$n
#	for i in {0..$SAMPLES};
#	do
#		./mm1prio 0 $ARRIVALS 1 $rho $MU >> $PATHPART_2/mm1_$rho
#		./md1prio 0 $ARRIVALS 1 $rho $MU >> $PATHPART_2/md1_$rho
#	done
#done 

#Intervallo di confidenza al 95%

#Confronto con i risultati teorici M/D/1 e M/M/1
