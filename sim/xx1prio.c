
#include "xx1prio.h"


/*
    Global variables
*/

Event *event_list;                  // Event list
Customer *q[MAX_CLASSES];           // List of waiting customers

int seed;                           // Random seed
int N;                              // Number of arrivals to be simulated
int C;                              // Number of traffic classes
int k;                              // State of the system = number of customers in the system
int tot_arrivals, tot_departures;   // Counters for the total number of arrivals/departures
int arrivals[MAX_CLASSES];          // Array of counters for the number of arrivals of each class
double tfree;                       // Time when the server has become or will become idle
double now;                         // Current time
double tot_w;                       // Overall mean waiting time
double w[MAX_CLASSES];              // Array of mean waiting times for each class
double lambda[MAX_CLASSES];         // Arrays of arrival and service rates for each class
double mu[MAX_CLASSES];


/*
  This function inserts a new event in the event list ordered by time
  Arguments:
        time = occurrence time of the new event
        type = type of the new event
        pclass = class of the customer involved in the new event
        service = service time of the arriving customer, in case the event is an arrival, 0 otherwise
*/
void insert_new_event(double time, char type, char pclass, double service) {
    // Declare some useful pointers
    struct event *w1, *w2, *w3;
    // Create the new event using the provided arguments
    w3 = (struct event *) malloc(sizeof(struct event));
    w3->time = time;
    w3->type = type;
    w3->pclass = pclass;
    w3->service = service;
    if (DEBUG) {
        fprintf(stderr, "DEBUG 12: New event object created: %p\n", w3);
    }
    // Insert the new event in the event list keeping the correct order
    if (event_list == NULL) { // The event list is empty: set it to point to the new event
        w3->next = NULL;
        event_list = w3;
        if (DEBUG) {
            fprintf(stderr, "DEBUG 13: Event list was empty, new event added to list head: %p\n", event_list);
        }
    } else if (event_list->time > w3->time) { // The new event must be inserted at the head of the list
        w3->next = event_list;
        event_list = w3;
        if (DEBUG) {
            fprintf(stderr, "DEBUG 14: Event list was not empty, new event added to list head: %p\n", event_list);
        }
    } else {
        // In all the other cases, move pointers w1 and w2 along the list until the correct point is found,
        // then insert the new event
        w1 = event_list;
        w2 = event_list->next;
        while ((w2 != NULL) && (w2->time <= w3->time)) {
            w1 = w2;
            w2 = w2->next;
        }
        w1->next = w3;
        w3->next = w2;
        if (DEBUG) {
            fprintf(stderr, "DEBUG 15: Event list (%p) was not empty, new event added to list\n", event_list);
        }
    }
    if (DEBUG) {
        fprintf(stderr, "DEBUG 01: New event inserted: time = %1.6f, type = %s, class = %d, service = %1.6f, next = %p\n", w3->time, (w3->type == 1 ? "ARRIVAL" : "DEPARTURE"), w3->pclass, w3->service, w3->next);
    }
}
/*
    This function extracts the first event from the event list
*/
Event *get_event() {
    // Declare some useful pointers
    struct event *w3;
    // The list is empty and it should not be: generate an error
    if (event_list == NULL) {
        fprintf(stderr, "ERROR: event list is empty when it should not be\n");
        exit(-1);
    }
    // Return the first event from the list and update the list pointer
    w3 = event_list;
    event_list = w3->next;
    if (DEBUG) {
        fprintf(stderr, "DEBUG 02: Next event extracted: time = %1.6f, type = %s, class = %d, service = %1.6f, next = %p\n", w3->time, (w3->type == 1 ? "ARRIVAL" : "DEPARTURE"), w3->pclass, w3->service, w3->next);
    }
    return w3;
}
/*
    This function appends a new customer to the list of waiting customers according to the class
    Arguments:
        pclass = class of the customer
        time = arrival time of the customer
        service = service time of the customer
*/
void append(unsigned char pclass, double time, double service) {
    // Declare some useful pointers
    struct customer *w1, *w2, *w3;
    // Create the customer using the provided arguments
    w3 = (struct customer *) malloc(sizeof(struct customer));
    w3->t_arr = time;
    w3->service = service;
    // Append the customer to the relevant class waiting list
    if (q[pclass] == NULL) {
        // The list is empty
        w3->next = NULL;
        q[pclass] = w3;
    } else {
        // Append it to the end of the list
        w1 = q[pclass];
        w2 = q[pclass]->next;
        while (w2 != NULL) {
            w1 = w2;
            w2 = w2->next;
        }
        w1->next = w3;
        w3->next = w2;
    }
    if (DEBUG) {
        fprintf(stderr, "DEBUG 03: New customer added to queue %d: time = %1.6f, service = %1.6f, next = %p\n", pclass, w3->t_arr, w3->service, w3->next);
    }
}
/*
    This function extracts the first customer from the customer list
    Arguments:
        pclass = class of the customer
*/
Customer *get_customer(unsigned char pclass) {
    // Declare some useful pointers
    Customer *w3;
    // The list is empty and it should not be: generate an error
    if (q[pclass] == NULL) {
        w3->t_arr;
        fprintf(stderr, "ERROR: customer list of class %d is empty when it should not be\n", pclass);
        exit(-1);
    }
    // Return the first customer from the list and update the list pointer
    w3 = q[pclass];
    q[pclass] = w3->next;
    if (DEBUG) {
        fprintf(stderr, "DEBUG 04: Next customer extracted from queue %d: time = %1.6f, service = %1.6f, next = %p\n", pclass, w3->t_arr, w3->service, w3->next);
    }
    return w3;
}
/*
    Initialize the simulation environment
*/
void initialize( double (*arrival_distr)(double), double (*service_time_distr)(double) ) {
    int j;

    for (j = 0; j < C; j++) {
        arrivals[j] = 0;
        w[j] = 0.0;
        // Initialize the list of events by inserting the first arrival for each class
        insert_new_event(arrival_distr(lambda[j]), ARRIVAL, j, service_time_distr(mu[j]) );
        q[j] = NULL;
    }
}
/*
    Start the simulation
*/
void simulate( double (*arrival_distr)(double), double (*service_time_distr)(double) ) {
    int j;
    struct event *e, *aux;
    struct customer *c, *caux;

    while (tot_departures < N) {  // Loop until all the generated customers have left the system

        if (DEBUG) {  // Print lots of information about the lists if DEBUG is true
            fprintf(stderr, "DEBUG 17: Cycling...\n");
            fprintf(stderr, "          Current event list:\n");
            fprintf(stderr, "          ");
            aux = event_list;
            while (aux != NULL) {
                fprintf(stderr, "[ addr = %p, time = %1.6f, next = %p ]----->", aux, aux->time, aux->next);
                aux = aux->next;
            }
            fprintf(stderr, "\n");
        }
        if (DEBUG) {
            fprintf(stderr, "          Current customer list:\n");
            for (j = 0; j < C; j++) {
                fprintf(stderr, "          q[%d]----->", j);
                caux = q[j];
                while (caux != NULL) {
                    fprintf(stderr, "[ addr = %p, time = %1.6f, next = %p ]----->", caux, caux->t_arr, caux->next);
                    caux = caux->next;
                }
                fprintf(stderr, "\n");
            }
        }

        // Start processing the first event in the list and set the current time
        e = get_event();
        now = e->time;
        if (DEBUG) {
            fprintf(stderr, "DEBUG 10: Current time = %1.6f\n", now);
        }

        if (e->type == ARRIVAL) {
            // The event is an arrival: increment the counters and the state
            k++;
            tot_arrivals++;
            arrivals[e->pclass]++;
            if (DEBUG) {
                fprintf(stderr, "DEBUG 06: Arrival: time = %1.6f, class = %d, service = %1.6f\n", e->time, e->pclass, e->service);
            }
            if (k == 1) {
                // The system was empty: the customer goes directly into service
                // and a departure event is created and inserted into the list
                tfree = now + e->service;
                insert_new_event(tfree, DEPARTURE, e->pclass, 0);
            } else {
                // The system was not empty: the customer is queued to the relevant waiting list
                tfree = tfree + e->service;
                append(e->pclass, now, e->service);
            }
            if (tot_arrivals < N) {
                // There are more arrivals to be generated: create a new one
                // and insert it in the event list
                insert_new_event(now + arrival_distr(lambda[e->pclass]), ARRIVAL, e->pclass, service_time_distr( mu[e->pclass] ) );
            }
        } else if (e->type == DEPARTURE) {
            // The event is a departure: increment the counters and decrement the state
            k--;
            tot_departures++;
            if (DEBUG) {
                fprintf(stderr, "DEBUG 16: Departure: time = %1.6f, class = %d, service = %1.6f\n", e->time, e->pclass, e->service);
            }
            if (k > 0) {
                // The system has not been left empty: put the next queued customer in service
                // taking it from the highest priority waiting list
                j = 0;
                while (q[j] == NULL) {
                    j++;    // Find the first non-empty waiting list
                }
                c = get_customer(j);
                w[j] = w[j] + (now - c->t_arr);  // Update the sum of the waiting time for class j
                insert_new_event(now + c->service, DEPARTURE, j, 0); // Create a departure event and insert it into the list
                if (DEBUG) {
                    fprintf(stderr, "DEBUG 07: Removing customer object\n");
                }
                if (c == NULL) {
                    fprintf(stderr, "ERROR: customer object is NULL when it should not be\n");
                    exit(-1);
                }
                free(c);  // Remove the customer object and free memory space
            }
        }
        if (DEBUG) {
            fprintf(stderr, "DEBUG 08: Removing event object\n");
        }
        if (e == NULL) {
            fprintf(stderr, "ERROR: event object is NULL when it should not be\n");
            exit(-1);
        }
        free(e);  // Remove the event object and free memory space

        if (DEBUG) {
            fprintf(stderr, "DEBUG 09: Current state = %d\n", k);
        }
        if (DEBUG) {
            fprintf(stderr, "DEBUG 11: Total arrivals = %d, Total departures = %d\n", tot_arrivals, tot_departures);
        }
        if (DEBUG) {
            fprintf(stderr, "----------------------------------------------------------------------------------\n\n");
        }

    }  // End of the main loop
}
/*
    Do final computation on measured data
*/
void prepare_results() {
    int j;
    // Update and print some variables
    for (j = 0; j < C; j++) {
        tot_w = tot_w + w[j];       // Update the sum of the overall waiting time
        w[j] = w[j] / arrivals[j];  // Compute the mean waiting time for class j
    }
    if (DEBUG) {
        fprintf(stderr, "DEBUG 19: tot_w = %f\n", tot_w);
        fprintf(stderr, "DEBUG 19: N = %d\n", N);
    }
    tot_w = tot_w / (float)N; // Compute the mean overall waiting time
    if (DEBUG) {
        fprintf(stderr, "DEBUG 19: tot_w = %f\n", tot_w);
    }

}
/*
    Print result
*/
void print_results() {
    int j;
    if (DEBUG) {
        // Print header
        printf("#NArrivals, ");
        for (j = 0; j < C; j++) {
            printf("rho_%d, mu_%d, eta_%d, ", j, j, j);
        }
        printf("eta_mean\n");
    }
    // Print values
    printf("%d ,",N);
    for (j = 0; j < C; j++) {
        printf("%f, %f, %f, ",lambda[j] / mu[j], mu[j], w[j]);
    }
    printf("%f\n",tot_w);
}

/*
    Parse input arguments and pre-configure simulation environment
*/
int parse_args(int argc, char *argv[]) {
    int j;
    // Check the command line arguments: must be at least 6, including the simulator executable
    // Otherwise generate an error
    if (argc < 6) {
        fprintf(stderr, "X/Y//1/PRIO Simulator\n");
        fprintf(stderr, "Usage:\n\t%s <RNDSEED> <N_SAMPLES> <N_CLASSES> <RHO_CLASS0> <SERV_CLASS0> <RHO_CLASS1> <SERV_CLASS1> .. \n", argv[0]);
        fprintf(stderr, "\n");
        return -1;
    }
    // Get the random generator seed from the first argument
    seed = atoi(argv[1]);
    // If the provided seed is zero, use the current timestamp
    if (seed == 0) {
        seed = time(NULL);
    }

    // Get the number of customers to be simulated from the second argument
    N = atoi(argv[2]);
    // Get the number of classes from the third argument (no more than MAX_CLASSES)
    C = atoi(argv[3]);
    if (C > MAX_CLASSES) {
        C = MAX_CLASSES;
    }
    // Check if there are enough arguments for each class (load + average service time for each class)
    // Otherwise generate an error
    if (argc < 2 * C + 4) {
        fprintf(stderr, "Missing load and service time for classes %d to %d\n", (argc - 4) / 2, C - 1);
        return -1;
    }
    // Get the load and average service time for each class from the following arguments
    // and set mu = 1/service and lambda = rho*mu
    for (j = 0; j < C; j++) {
        mu[j] = 1.0 / atof(argv[4 + 2 * j + 1]);
        lambda[j] = atof(argv[4 + 2 * j]) * mu[j];
    }

   // Initialize all the global variables and counters
    k = 0;
    tfree = 0.0;
    now = 0.0;
    tot_arrivals = 0;
    tot_departures = 0;
    tot_w = 0.0;

    srand(seed);
    
    
    return 0;
}
