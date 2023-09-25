
#include "param.h"

struct processes_info {
    int num_processes;
    int pids[NPROC];
    int times_scheduled[NPROC]; // times_scheduled = number of times process has been scheduled
    int tickets[NPROC]; // tickets = number of tickets set by settickets();
} processes_info;
