#!/usr/bin/gnuplot

theta_mean=3.0
mu=1/theta_mean
ni_mm1(rho)=((rho*(2*theta_mean**2)/mu)/2.0) / (1.0-rho) 
ni_md1(rho)=(((rho*theta_mean**2)   /mu)/2.0) / (1.0-rho) 

set terminal postscript eps size 3.5,2.62 enhanced color font 'Helvetica,20' linewidth 2
set output 'mm1_md1_theorical.eps'

set title 'M/M/1 and M/D/1 analytic results'
set xrange [0:2]
set yrange [0:100]
set xlabel '{/Symbol r}'
set ylabel '{/Symbol h}'

plot [0:1] ni_mm1(x) t "{/Symbol h} mm1, {/Symbol q}=3" , \
	   ni_md1(x) t "{/Symbol h} md1, {/Symbol q}=3"


