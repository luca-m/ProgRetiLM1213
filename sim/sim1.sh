#!/bin/bash
#
#
if [ "$1" == "clean" ]
then 
	echo "Cleaning previos simulation data"
	rm -r data/sim1/
fi

mkdir data 2>/dev/null
mkdir data/sim1 2>/dev/null
mkdir data/sim1/part1 2>/dev/null
mkdir data/sim1/part2 2>/dev/null
mkdir data/sim1/part1/raw 2>/dev/null
mkdir data/sim1/part2/raw 2>/dev/null

PATHPART_1=data/sim1/part1
PATHPART_2=data/sim1/part2

SVC_MEAN_TIME=3   # MU = 1/SVC_MEAN_TIME
ARRIVALS=500
SAMPLES=50
CONF=0.95
RHO=0.7
FIELDNAME='eta_mean'
#############################################################################
# PART 1 
#############################################################################
echo "> PART 1"
echo "Comparison between MM1 and MD1 with same RHO and MU" | tee -a $PATHPART_1/note
echo "Service mean time $SVC_MEAN_TIME and rho $RHO" | tee -a $PATHPART_1/note
echo "$FIELDNAME confidence interval $CONF" | tee -a $PATHPART_1/note
echo "Simulating:"
touch $PATHPART_1/mm1.csv
touch $PATHPART_1/md1.csv
echo "# arrivals, rho, mu, eta, eta_mean, min_$FIELDNAME, max_$FIELDNAME " | tee -a $PATHPART_1/mm1.csv $PATHPART_1/md1.csv 1>/dev/null
seed=1
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
./plot_confidence.R $PATHPART_1/mm1.csv $PATHPART_1/mm1.pdf X..arrivals $FIELDNAME min_$FIELDNAME max_$FIELDNAME 2>/dev/null
./plot_confidence.R $PATHPART_1/md1.csv $PATHPART_1/md1.pdf X..arrivals $FIELDNAME min_$FIELDNAME max_$FIELDNAME 2>/dev/null
echo ""
echo "Results in $PATHPART_1/mm1.csv and $PATHPART_1/md1.csv"
echo "Plots in $PATHPART_1/mm1.pdf and $PATHPART_1/md1.pdf"
#############################################################################
# PART 2
#############################################################################
echo "> PART 2"
echo "Eta mean for rho in (0,1) for MM1 and MD1 with $ARRIVALS arrivals and service mean time $SVC_MEAN_TIME" | tee -a $PATHPART_2/note
echo "Field $FIELDNAME confidence interval $CONF" | tee -a $PATHPART_2/note
echo "Simulating:"
touch $PATHPART_2/mm1.csv
touch $PATHPART_2/md1.csv
echo "# arrivals, rho, mu, eta, eta_mean, min_$FIELDNAME, max_$FIELDNAME " | tee -a $PATHPART_2/mm1.csv $PATHPART_2/md1.csv 1>/dev/null
seed=1
for rho in 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 0.99 ;
do
	echo -n "."
	touch $PATHPART_2/raw/mm1_$rho
	touch $PATHPART_2/raw/md1_$rho
	echo "# arrivals, rho, mu, eta, eta_mean" | tee -a $PATHPART_2/raw/mm1_$rho $PATHPART_2/raw/md1_$rho 1>/dev/null
	for ((i=0;i<=$SAMPLES;i++))
	do
		seed=`expr $seed + 9`
		./mm1prio $seed $ARRIVALS 1 $rho $SVC_MEAN_TIME >> $PATHPART_2/raw/mm1_$rho &
		PID1=$!
		./md1prio $seed $ARRIVALS 1 $rho $SVC_MEAN_TIME >> $PATHPART_2/raw/md1_$rho &
		PID2=$!
		wait $PID1
		wait $PID2
	done
	./confidence_interval.R $PATHPART_2/raw/mm1_$rho $FIELDNAME $CONF 2>/dev/null >> $PATHPART_2/mm1.csv &
	PID1=$!
	./confidence_interval.R $PATHPART_2/raw/md1_$rho $FIELDNAME $CONF 2>/dev/null >> $PATHPART_2/md1.csv &
	PID2=$!
	wait $PID1
	wait $PID2
done 
./plot_confidence.R $PATHPART_2/mm1.csv $PATHPART_2/mm1.pdf rho $FIELDNAME min_$FIELDNAME max_$FIELDNAME 2>/dev/null
./plot_confidence.R $PATHPART_2/md1.csv $PATHPART_2/md1.pdf rho $FIELDNAME min_$FIELDNAME max_$FIELDNAME 2>/dev/null
echo ""
echo "Results in $PATHPART_2/mm1.csv and $PATHPART_2/md1.csv"
echo "Plots in $PATHPART_2/mm1.pdf and $PATHPART_2/md1.pdf"

#Confronto con i risultati teorici M/D/1 e M/M/1
