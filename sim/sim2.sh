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
#############################################################################
# PART 1
#############################################################################
echo "> PART 1"
echo "Simulating M/M/1//PRIO (2 classes) with rho $RHO and service mean time $SVC_MEAN_TIME" | tee -a $PATHPART_1/note
echo "Arrivals $ARRIVALS" | tee -a $PATHPART_1/note
echo "rho1 = x * rho , rho2 = (1-x) * rho " | tee -a $PATHPART_1/note
echo "Eta confidence interval $CONF" | tee -a $PATHPART_1/note
echo "Simulating:"
touch $PATHPART_1/mm1_e.csv 
echo "# x, arrivals, rho1, mu1, eta1, rho2, mu2, eta2, eta_mean, min_eta1, max_eta1, min_eta2, max_eta2, min_eta_mean, max_eta_mean" > $PATHPART_1/mm1_e.csv 
seed=1
for ((x=1;x<$SUBDIVISIONS;x++)) 
do
	echo -n "."
	X=`python -c "print $x/$SUBDIVISIONS.0"`
	RHO1=`python -c "print $RHO*($x/$SUBDIVISIONS.0)"`
	RHO2=`python -c "print $RHO*(1.0-$x/$SUBDIVISIONS.0)"`
	touch $PATHPART_1/raw/mm1_$x
	echo "# arrivals, rho1, mu1, eta1, rho2, mu2, eta2, eta_mean " | tee -a $PATHPART_1/raw/mm1_$x 1>/dev/null
 	for ((i=0;i<=$SAMPLES;i++))
	do
		seed=`expr $seed + 1`
		./mm1prio $seed $ARRIVALS 2 $RHO1 $SVC_MEAN_TIME $RHO2 $SVC_MEAN_TIME >> $PATHPART_1/raw/mm1_$x
	done
	cat - < <(echo -n "$X,";./confidence_interval.R $PATHPART_1/raw/mm1_$x eta $CONF 2>/dev/null) >> $PATHPART_1/mm1_e.csv   
done
./plot_confidence.R $PATHPART_1/mm1_e.csv $PATHPART_1/mm1_e1.pdf x eta1 min_eta1 max_eta1 2>/dev/null
./plot_confidence.R $PATHPART_1/mm1_e.csv $PATHPART_1/mm1_e2.pdf x eta2 min_eta2 max_eta2 2>/dev/null
./plot_confidence.R $PATHPART_1/mm1_e.csv $PATHPART_1/mm1_emean.pdf x eta_mean min_eta_mean max_eta_mean 2>/dev/null
echo ""
echo "Results in $PATHPART_1/mm1_e.csv"
echo "Plots in $PATHPART_1/mm1_e1.pdf $PATHPART_1/mm1_e2.pdf $PATHPART_1/mm1_emean.pdf"
#############################################################################
# PART 2
#############################################################################
echo "> PART 2"
echo "Simulating M/M/1//PRIO (3 classes) with rho $RHO and service mean time $SVC_MEAN_TIME" | tee -a $PATHPART_2/note
echo "Arrivals $ARRIVALS" | tee -a $PATHPART_2/note
echo "rho1 = x/2 * rho , rho2 = rho1 ,rho3 = (1-x) * rho " | tee -a $PATHPART_2/note
echo "Eta confidence interval $CONF" | tee -a $PATHPART_2/note
echo "Simulating:"
touch $PATHPART_2/mm1_e.csv 
echo "# x, arrivals, rho1, mu1, eta1, rho2, mu2, eta2, rho3, mu3, eta3, eta_mean, min_eta1, max_eta1, min_eta2, max_eta2, min_eta3, max_eta3, min_eta_mean, max_eta_mean" > $PATHPART_2/mm1_e.csv 
seed=1
for ((x=1;x<$SUBDIVISIONS;x++)) 
do
	echo -n "."
	X=`python -c "print $x/$SUBDIVISIONS.0"`
	RHO1=`python -c "print $RHO*($x/$SUBDIVISIONS.0)/2.0"`
	RHO2=$RHO1
	RHO3=`python -c "print $RHO*(1.0-$x/$SUBDIVISIONS.0)"`
	touch $PATHPART_2/raw/mm1_$x
	echo "# arrivals, rho1, mu1, eta1, rho2, mu2, eta2, rho3, mu3, eta3, eta_mean " | tee -a $PATHPART_2/raw/mm1_$x 1>/dev/null
 	for ((i=0;i<=$SAMPLES;i++))
	do
		seed=`expr $seed + 1`
		./mm1prio $seed $ARRIVALS 3 $RHO1 $SVC_MEAN_TIME $RHO2 $SVC_MEAN_TIME $RHO3 $SVC_MEAN_TIME >> $PATHPART_2/raw/mm1_$x
	done
	cat - < <(echo -n "$X,";./confidence_interval.R $PATHPART_2/raw/mm1_$x eta $CONF 2>/dev/null ) >> $PATHPART_2/mm1_e.csv   
done
./plot_confidence.R $PATHPART_2/mm1_e.csv $PATHPART_2/mm1_e1.pdf x eta1 min_eta1 max_eta1 2>/dev/null
./plot_confidence.R $PATHPART_2/mm1_e.csv $PATHPART_2/mm1_e2.pdf x eta2 min_eta2 max_eta2 2>/dev/null
./plot_confidence.R $PATHPART_2/mm1_e.csv $PATHPART_2/mm1_e3.pdf x eta3 min_eta3 max_eta3 2>/dev/null
./plot_confidence.R $PATHPART_2/mm1_e.csv $PATHPART_2/mm1_emean.pdf x eta_mean min_eta_mean max_eta_mean 2>/dev/null
echo ""
echo "Results in $PATHPART_2/mm1_e.csv"
echo "Plots in $PATHPART_2/mm1_e1.pdf $PATHPART_2/mm1_e2.pdf $PATHPART_2/mm1_emean.pdf"
#############################################################################
# PART 3
#############################################################################
echo "> PART 3"
echo "Simulating M/M/1//PRIO (3 classes) with rho $RHO and service mean time $SVC_MEAN_TIME" | tee -a $PATHPART_3/note
echo "Arrivals $ARRIVALS" | tee -a $PATHPART_3/note
echo "rho1 = x/10 * rho , rho2 = 9*x/10 * rho , rho3 = (1-x) * rho" | tee -a $PATHPART_3/note
echo "Eta confidence interval $CONF" | tee -a $PATHPART_3/note
echo "Simulating:"
touch $PATHPART_3/mm1_e.csv 
echo "# x, arrivals, rho1, mu1, eta1, rho2, mu2, eta2, rho3, mu3, eta3, eta_mean, min_eta1, max_eta1, min_eta2, max_eta2, min_eta3, max_eta3, min_eta_mean, max_eta_mean" > $PATHPART_3/mm1_e.csv 
seed=1
for ((x=1;x<$SUBDIVISIONS;x++)) 
do
	echo -n "."
	X=`python -c "print $x/$SUBDIVISIONS.0"`
	RHO1=`python -c "print $RHO*($x/$SUBDIVISIONS.0)/10.0"`
	RHO2=`python -c "print $RHO*9*($x/$SUBDIVISIONS.0)/10.0"`
	RHO3=`python -c "print $RHO*(1.0-$x/$SUBDIVISIONS.0)"`
	touch $PATHPART_3/raw/mm1_$x
	echo "# arrivals, rho1, mu1, eta1, rho2, mu2, eta2, rho3, mu3, eta3, eta_mean " | tee -a $PATHPART_3/raw/mm1_$x 1>/dev/null
 	for ((i=0;i<=$SAMPLES;i++))
	do
		seed=`expr $seed + 1`
		./mm1prio $seed $ARRIVALS 3 $RHO1 $SVC_MEAN_TIME $RHO2 $SVC_MEAN_TIME $RHO3 $SVC_MEAN_TIME >> $PATHPART_3/raw/mm1_$x
	done
	cat - < <(echo -n "$X,";./confidence_interval.R $PATHPART_3/raw/mm1_$x eta $CONF 2>/dev/null ) >> $PATHPART_3/mm1_e.csv   
done
./plot_confidence.R $PATHPART_3/mm1_e.csv $PATHPART_3/mm1_e1.pdf x eta1 min_eta1 max_eta1 2>/dev/null
./plot_confidence.R $PATHPART_3/mm1_e.csv $PATHPART_3/mm1_e2.pdf x eta2 min_eta2 max_eta2 2>/dev/null
./plot_confidence.R $PATHPART_3/mm1_e.csv $PATHPART_3/mm1_e3.pdf x eta3 min_eta3 max_eta3 2>/dev/null
./plot_confidence.R $PATHPART_3/mm1_e.csv $PATHPART_3/mm1_emean.pdf x eta_mean min_eta_mean max_eta_mean 2>/dev/null
echo ""
echo "Results in $PATHPART_3/mm1_e.csv "
echo "Plots in $PATHPART_3/mm1_e2.pdf $PATHPART_3/mm1_e2.pdf $PATHPART_3/mm1_emean.pdf"
#############################################################################
# PART 4
#############################################################################
echo "> PART 4"
echo "Simulating M/M/1//PRIO (3 classes) with rho $RHO and service mean time $SVC_MEAN_TIME" | tee -a $PATHPART_4/note
echo "Arrivals $ARRIVALS" | tee -a $PATHPART_4/note
echo "rho1 = x * rho , rho2 = (1-x)/2 * rho , rho3 = rho2" | tee -a $PATHPART_4/note
echo "Eta confidence interval $CONF" | tee -a $PATHPART_4/note
echo "Simulating:"
touch $PATHPART_4/mm1_e.csv 
echo "# x, arrivals, rho1, mu1, eta1, rho2, mu2, eta2, rho3, mu3, eta3, eta_mean, min_eta1, max_eta1, min_eta2, max_eta2, min_eta3, max_eta3, min_eta_mean, max_eta_mean" > $PATHPART_4/mm1_e.csv 
seed=1
for ((x=1;x<$SUBDIVISIONS;x++)) 
do
	echo -n "."
	X=`python -c "print $x/$SUBDIVISIONS.0"`
	RHO1=`python -c "print $RHO*($x/$SUBDIVISIONS.0)"`
	RHO2=`python -c "print $RHO*(1.0-$x/$SUBDIVISIONS.0)/2.0"`
	RHO3=$RHO2
	touch $PATHPART_4/raw/mm1_$x
	echo "# arrivals, rho1, mu1, eta1, rho2, mu2, eta2, rho3, mu3, eta3, eta_mean " | tee -a $PATHPART_4/raw/mm1_$x 1>/dev/null
 	for ((i=0;i<=$SAMPLES;i++))
	do
		seed=`expr $seed + 1`
		./mm1prio $seed $ARRIVALS 3 $RHO1 $SVC_MEAN_TIME $RHO2 $SVC_MEAN_TIME $RHO3 $SVC_MEAN_TIME >> $PATHPART_4/raw/mm1_$x
	done
	cat - < <(echo -n "$X,";./confidence_interval.R $PATHPART_4/raw/mm1_$x eta $CONF 2>/dev/null ) >> $PATHPART_4/mm1_e.csv   
done
./plot_confidence.R $PATHPART_4/mm1_e.csv $PATHPART_4/mm1_e1.pdf x eta1 min_eta1 max_eta1 2>/dev/null
./plot_confidence.R $PATHPART_4/mm1_e.csv $PATHPART_4/mm1_e2.pdf x eta2 min_eta2 max_eta2 2>/dev/null
./plot_confidence.R $PATHPART_4/mm1_e.csv $PATHPART_4/mm1_e3.pdf x eta3 min_eta3 max_eta3 2>/dev/null
./plot_confidence.R $PATHPART_4/mm1_e.csv $PATHPART_4/mm1_emean.pdf x eta_mean min_eta_mean max_eta_mean 2>/dev/null
echo ""
echo "Results in $PATHPART_4/mm1_e.csv"
echo "Plots in $PATHPART_4/mm1_e1.pdf $PATHPART_4/mm1_e2.pdf $PATHPART_4/mm1_emean.pdf"
