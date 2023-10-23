
#ifndef POOL_H_
#include <pthread.h>
#include <queue>
#include <iostream>
#include <unistd.h>
#include <string>
#include <tuple>

using namespace std;

 

class Task {
public:
    pthread_cond_t finished;
    pthread_mutex_t lockit;
    bool complete;
   
    Task();
    virtual ~Task();

    virtual void Run() = 0;  // implemented by subclass
};

class ThreadPool {
public:


        pthread_mutex_t mutexs;
        pthread_cond_t taskavailable;
        bool stoprequested;
        vector<tuple<string,Task*>> TaskS;
        vector<pthread_t> threads;
        queue<Task*> tasks11;
        
        


    static void *threadhelp(void *arg);
   
    ThreadPool(int num_threads);

    // Submit a task with a particular name.
    void SubmitTask(const std::string &name, Task *task);
 
    // Wait for a task by name, if it hasn't been waited for yet. Only returns after the task is completed.
    void WaitForTask(const std::string &name);

    // Stop all threads. All tasks must have been waited for before calling this.
    // You may assume that SubmitTask() is not caled after this is called.
    void Stop();
};
#endif
