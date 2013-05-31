#!/bin/bash
#
#

if [ "$1" == "clean" ]
then 
	echo "Cleaning previos simulation data"
	rm -r data/sim2/
fi


mkdir data 2>/dev/null
mkdir data/sim2 2>/dev/null
mkdir data/sim2/part1 2>/dev/null
mkdir data/sim2/part2 2>/dev/null
mkdir data/sim2/part3 2>/dev/null
mkdir data/sim2/part4 2>/dev/null
mkdir data/sim2/part1/raw 2>/dev/null
mkdir data/sim2/part2/raw 2>/dev/null
mkdir data/sim2/part3/raw 2>/dev/null
mkdir data/sim2/part4/raw 2>/dev/null

PATHPART_1=data/sim2/part1
PATHPART_2=data/sim2/part2
PATHPART_3=data/sim2/part3
PATHPART_4=data/sim2/part4

SVC_MEAN_TIME=3   # MU = 1/SVC_MEAN_TIME
ARRIVALS=500
SUBDIVISIONS=100
SAMPLES=50
CONF=0.95
FIELDNAME='eta_mean'
RHO=0.8

echo "> PART 1"
echo "Simulating M/M/1//PRIO (2 classes) with rho $RHO and service mean time $SVC_MEAN_TIME" | tee -a $PATHPART_1/note
echo "Arrivals $ARRIVALS" | tee -a $PATHPART_1/note
echo "rho1 = x * rho , rho2 = (1-x) * rho " | tee -a $PATHPART_1/note
echo "Eta confidence interval $CONF" | tee -a $PATHPART_1/note
echo "Simulating:"
touch $PATHPART_1/mm1_e.csv 
echo "# arrivals, rho1, mu1, eta1, rho2, mu2, eta2, eta_mean, min_eta1, max_eta1, min_eta2, max_eta2, min_eta_mean, max_eta_mean" > $PATHPART_1/mm1_e.csv 

seed=1
for ((x=1;x<$SUBDIVISIONS;x++)) 
do
	echo -n "."
	RHO1=`python -c "print $RHO*($x/$SUBDIVISIONS.0)"`
	RHO2=`python -c "print $RHO*(1.0-$x/$SUBDIVISIONS.0)"`
	touch $PATHPART_1/raw/mm1_$x
	echo "# arrivals, rho1, mu1, eta1, rho2, mu2, eta2, eta_mean " | tee -a $PATHPART_1/raw/mm1_$x 1>/dev/null
 	for ((i=0;i<=$SAMPLES;i++))
	do
		seed=`expr $seed + 1`
		./mm1prio $seed $ARRIVALS 2 $RHO1 $SVC_MEAN_TIME $RHO2 $SVC_MEAN_TIME >> $PATHPART_1/raw/mm1_$x
	done
	./confidence_interval.R $PATHPART_1/raw/mm1_$x eta $CONF 2>/dev/null >> $PATHPART_1/mm1_e.csv   
done
./plot_confidence.R $PATHPART_1/mm1_e.csv $PATHPART_1/mm1_e1.pdf rho1 eta1 min_eta1 max_eta1 2>/dev/null
./plot_confidence.R $PATHPART_1/mm1_e.csv $PATHPART_1/mm1_e2.pdf rho2 eta2 min_eta2 max_eta2 2>/dev/null
./plot_confidence.R $PATHPART_1/mm1_e.csv $PATHPART_1/mm1_emean.pdf rho1 eta_mean min_eta_mean max_eta_mean 2>/dev/null
echo ""
echo -e "Results in $PATHPART_1/mm1_e1.csv  $PATHPART_1/mm1_e2.csv $PATHPART_1/mm1_emean.csv\nPlots in $PATHPART_1/mm1_e1.pdf $PATHPART_1/mm1_e2.pdf PATHPART_1/mm1_emean.pdf"


