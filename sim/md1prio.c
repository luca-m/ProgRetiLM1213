#include "xx1prio.h"
#include "mt.h"

/*
    This function generates an instance of an exponential random variable
    Arguments:
            param = parameter of the exponential distribution, i.e., inverse of the mean value
*/
double expon(double param) {
    // Declare some useful variables
    int rnd_num;
    double unif, val;
    // Generate a uniform random number between 0 and 1
    rnd_num = mt_random(); //rand();
    if (rnd_num == RAND_MAX) {
        rnd_num--;
    }
    unif = (double) rnd_num / RAND_MAX;
    // Transform the uniform random variable into an exponential one using the inverse function rule
    val = -log(1.0 - unif) / param;
    if (DEBUG) {
        fprintf(stderr, "DEBUG 05: New exponential random variable with parameter %1.6f: generated value = %1.6f\n", param, val);
    }
    return val;
}


/*
    Service time is exactly what is specified in input of the program (1/mu)
*/
double deterministic(double param){
    double val;
    val=1.0/param;
    if (DEBUG) {
        fprintf(stderr, "DEBUG 05: New deterministic parameter %1.6f: generated value = %1.6f\n", param, val);
    }
    return val;
}
/*
    Main program
*/
int main(int argc, char *argv[]) {
    int ret = 0;
    ret = parse_args(argc, argv);
    if (ret != 0) {
        exit(ret);
    }

    mt_init(); // Mersenne Twist initialization

    initialize(&expon, &deterministic);

    simulate(&expon, &deterministic);

    prepare_results();

    print_results();
}