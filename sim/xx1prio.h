#ifndef __XX1PRIO__
#define __XX1PRIO__

#ifndef DEBUG
#define DEBUG 0
#else
#define DEBUG 1
#endif

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

// Define the event types
#define ARRIVAL 1
#define DEPARTURE 2

// Define the maximum number of traffic classes allowed by the simulator
#define MAX_CLASSES 10

/*
    Structure representing an event
*/
struct event {
    double time;                // Event occurrence time
    char type;                  // Event type
    unsigned char pclass;       // Class of the customer involved in the event
    double service;             // Service time, in case the event is an arrival
    struct event *next;         // Pointer to the next event in the list
};
/*
    Structure representing a customer waiting in the queue
*/
struct customer {
    double t_arr;               // Time of arrival
    double service;             // Service time
    struct customer *next;      // Pointer to the next customer in the list
};

typedef struct event Event;
typedef struct customer Customer;

/*
  This function inserts a new event in the event list ordered by time
  Arguments:
        time = occurrence time of the new event
        type = type of the new event
        pclass = class of the customer involved in the new event
        service = service time of the arriving customer, in case the event is an arrival, 0 otherwise
*/
void insert_new_event(double time, char type, char pclass, double service);
/*
    This function extracts the first event from the event list
*/
struct event * get_event();
/*
    This function appends a new customer to the list of waiting customers according to the class
    Arguments:
        pclass = class of the customer
        time = arrival time of the customer
        service = service time of the customer
*/
void append(unsigned char pclass, double time, double service);
/*
    This function extracts the first customer from the customer list
    Arguments:
        pclass = class of the customer
*/
struct customer * get_customer(unsigned char pclass);
/*
    This function generates an instance of the service time random variable
    Arguments:
          pclass = class of the customer
*/
double serv(unsigned char pclass);
/*
    Initialize the simulation environment
*/
void initialize(double (*arrival_distr)(double), double (*service_time_distr)(double));
/*
	Start the simulation
*/
void simulate(double (*arrival_distr)(double), double (*service_time_distr)(double));
/*
	Do final computation on measured data
*/
void prepare_results();
/*
	Print result
*/
void print_results();
/*
	Parse input arguments and pre-configure simulation environment
*/
int parse_args(int argc, char *argv[]);

#endif