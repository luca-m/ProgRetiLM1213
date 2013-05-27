#include "xx1prio.h"


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
    rnd_num = rand();
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
    Main program
*/
int main(int argc, char *argv[]) {
    int ret = 0;
    ret = parse_args(argc, argv);
    if (ret != 0) {
        exit(ret);
    }

    initialize(&expon, &expon);

    simulate(&expon, &expon);

    prepare_results();

    print_results();
}