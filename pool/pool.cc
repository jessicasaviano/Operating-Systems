#include "pool.h"

Task::Task() {
}

Task::~Task() {
}


void* ThreadPool::threadhelp(void *arg) {
    ThreadPool* p = (ThreadPool*)arg;
    while(true){
        pthread_mutex_lock(&(p->mutexs));
        while( !(p->stoprequested) && (p->tasks11).empty()){
            pthread_cond_wait(&(p->taskavailable), &(p->mutexs));
        }

        if(p->stoprequested){
            pthread_mutex_unlock(&(p->mutexs));
           return nullptr;
        }
    
    Task *t3 = (p->tasks11).front();
    (p->tasks11).pop();
    pthread_mutex_unlock(&(p->mutexs));
    t3->Run();
    pthread_mutex_lock(&(t3->lockit));
    t3->complete = true;
    pthread_cond_broadcast(&(t3->finished));
    pthread_mutex_unlock(&(t3->lockit)); 

    }
    return nullptr;
}

ThreadPool::ThreadPool(int num_threads) : stoprequested(false) {
    threads.resize(num_threads);
    pthread_cond_init(&taskavailable, nullptr);
    pthread_mutex_init(&mutexs, nullptr);
    for(int i = 0; i < num_threads; i ++){
        pthread_create(&threads[i], NULL, threadhelp, this);        
    }
}


void ThreadPool::SubmitTask(const std::string &name, Task* task) {
    
    pthread_cond_init(&(task->finished), nullptr);
    pthread_mutex_init(&(task->lockit), nullptr);
    pthread_mutex_lock(&(task->lockit));
    task->complete = false;
    pthread_mutex_unlock(&(task->lockit));
    pthread_mutex_lock(&mutexs);
    tasks11.push(task);
    TaskS.push_back(make_tuple(name,task));
    pthread_cond_broadcast(&taskavailable);
    pthread_mutex_unlock(&mutexs);


}

void ThreadPool::WaitForTask(const std::string &name) {
    pthread_mutex_lock(&mutexs);
       Task *t4 = nullptr;
      for (const auto& el : TaskS) {

        if (get<0>(el) == name){
            t4 = get<1>(el);
            break;
        }
      }   
      //cout << "going.."<< name << endl;
    pthread_mutex_unlock(&mutexs); 
    pthread_mutex_lock(&(t4->lockit));
    while(!(t4->complete)){
        pthread_cond_wait(&(t4->finished), &(t4->lockit));

    }
    pthread_mutex_unlock(&(t4->lockit));
    delete t4;
}

void ThreadPool::Stop() {

    pthread_mutex_lock(&mutexs);
    stoprequested = true;
    pthread_cond_broadcast(&taskavailable);
    pthread_mutex_unlock(&mutexs);

    for(pthread_t &thread: threads){
        pthread_join(thread, nullptr);
    }
    pthread_cond_destroy(&taskavailable);
    pthread_mutex_destroy(&mutexs);
}
