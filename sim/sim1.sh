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
SVC_MEAN_TIME=3   # MU = 1/SVC_MEAN_TIME
ARRIVALS=500
SAMPLES=50
CONF=0.95
FIELDNAME='eta_mean'
seed=1

echo "Comparison between MM1 and MD1 with same RHO and MU"
echo "Field $FIELDNAME confidence interval $CONF" 
echo "Simulating:"
echo "Comparison between MM1 and MD1 with same RHO and MU\n$FIELDNAME confidence interval $CONF" > $PATHPART_1/note
touch $PATHPART_1/mm1.csv
touch $PATHPART_1/md1.csv
echo "# arrivals, rho, mu, eta, eta_mean, min_$FIELDNAME, max_$FIELDNAME " | tee -a $PATHPART_1/mm1.csv $PATHPART_1/md1.csv 1>/dev/null

for ((n=1;n<=$ARRIVALS;n++)) 
do
	echo -n "."
	touch $PATHPART_1/raw/mm1_$n
	touch $PATHPART_1/raw/md1_$n
	echo "# arrivals, rho, mu, eta, eta_mean" | tee -a $PATHPART_1/raw/mm1_$n $PATHPART_1/raw/md1_$n 1>/dev/null
 	for ((i=0;i<=$SAMPLES;i++))
	do
		seed=`expr $seed + 9`
		./mm1prio $seed $n 1 $RHO $SVC_MEAN_TIME >> $PATHPART_1/raw/mm1_$n &
		PID1=$!
		./md1prio $seed $n 1 $RHO $SVC_MEAN_TIME >> $PATHPART_1/raw/md1_$n &
		PID2=$!
		wait $PID1
		wait $PID2
	done
	./confidence_interval.R $PATHPART_1/raw/mm1_$n $FIELDNAME $CONF 2>/dev/null >> $PATHPART_1/mm1.csv &
	PID1=$!
	./confidence_interval.R $PATHPART_1/raw/md1_$n $FIELDNAME $CONF 2>/dev/null >> $PATHPART_1/md1.csv &
	PID2=$!
	wait $PID1
	wait $PID2
done
./plot_confidence.R $PATHPART_1/mm1.csv  $PATHPART_1/mm1.pdf $FIELDNAME min_$FIELDNAME max_$FIELDNAME 2>/dev/null
./plot_confidence.R data/sim1/part1/md1.csv $PATHPART_1/md1.pdf $FIELDNAME min_$FIELDNAME max_$FIELDNAME 2>/dev/null
echo ""
echo -e "Results in $PATHPART_1/mm1.csv and $PATHPART_1/md1.csv\nPlots in $PATHPART_1/mm1.pdf and $PATHPART_1/md1.pdf"


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
