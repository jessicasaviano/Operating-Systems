#include "life.h"
#include <pthread.h>
#include <unistd.h>
#include <math.h>
#include <iostream>
using namespace std;



struct ThreadD {
    int start_r;
    int start_c;
    int end_r;
    int end_c;
    LifeBoard *state;
    LifeBoard *next_state;
    int steps;
    int width;
    pthread_barrier_t *barrier;
    
};

void* life(void* args) {
   struct  ThreadD *thread_data = (struct ThreadD *)(args);

    for (int step = 0; step < thread_data->steps; ++step) {
        if (step % 2) {
            for (int y = thread_data->start_r; y <= thread_data->end_r; ++y) {
        int col_start = (y ==thread_data->start_r) ? thread_data->start_c : 1;
        int col_end = (y == thread_data->end_r) ? thread_data->end_c : ((*(thread_data->next_state)).width() - 2);

        for (int x = col_start; x <= col_end; ++x) {
            int live_in_window = 0;

            for (int y_offset = -1; y_offset <= 1; ++y_offset) {
                for (int x_offset = -1; x_offset <= 1; ++x_offset) {
                    if ((*(thread_data->next_state)).at(x + x_offset, y + y_offset)) {
                        ++live_in_window;
                    }
                }
            }

            (*(thread_data->state)).at(x, y) = (live_in_window == 3 || (live_in_window == 4 && (*(thread_data->next_state)).at(x, y)));
        }
        }


        } else {
            
            for (int y = thread_data->start_r; y <= thread_data->end_r; ++y) {
                int col_start = (y ==thread_data->start_r) ? thread_data->start_c : 1;
                int col_end = (y == thread_data->end_r) ? thread_data->end_c : ((*(thread_data->state)).width() - 2);

                for (int x = col_start; x <= col_end; ++x) {
                    int live_in_window = 0;

                    for (int y_offset = -1; y_offset <= 1; ++y_offset) {
                        for (int x_offset = -1; x_offset <= 1; ++x_offset) {
                            if ((*(thread_data->state)).at(x + x_offset, y + y_offset)) {
                            ++live_in_window;
                    }
                }
            }

            (*(thread_data->next_state)).at(x, y) = (live_in_window == 3 || (live_in_window == 4 && (*(thread_data->state)).at(x, y)));
        }
        }
        }
        
        pthread_barrier_wait(thread_data->barrier);
    }

    delete thread_data;
    return nullptr;
}


void simulate_life_parallel(int threads, LifeBoard &state, int steps) {
    vector<pthread_t> thread_handles(threads);
    LifeBoard next_state{state.width(), state.height()};
    vector<vector<int>> board;
     
int cells = (state.width() - 2) * (state.height() - 2);
int sec = cells / threads;
int extra_cells = cells % threads;

int start_cell = 0;

for (int i = 0; i < threads; ++i) {
    int extra = (i < extra_cells) ? 1 : 0;
    int end_cell = start_cell + sec + extra - 1;

    ThreadD data;
    vector<int> items;
    data.start_r = (start_cell / (state.width() - 2)) + 1;
     items.push_back(data.start_r);
    data.end_r = (end_cell / (state.width() - 2)) + 1;
     items.push_back(data.end_r);
   
    data.start_c = start_cell % (state.width() - 2) + 1;
     items.push_back(data.start_c);
   
    data.end_c = end_cell % (state.width() - 2) + 1;

    items.push_back(data.end_c);
   
    board.push_back(items);
    items.clear();
    start_cell = end_cell + 1;
}
    
 
    pthread_barrier_t barrier;
     // Initialize barrier count
     pthread_barrier_init(&barrier, nullptr, threads);

    // Initialize thread data
    for (int i = 0; i < threads; ++i) {
        ThreadD* t = new ThreadD();
        t->steps = steps;
        t->width = state.width();
        t->barrier = &barrier;
        t->state = &state;
        t->next_state = &next_state;
        t->start_r = board[i][0];
        t->end_r = board[i][1];
        t->start_c = board[i][2];
        t->end_c = board[i][3];
         // Create threads
         pthread_create(&thread_handles[i], NULL, life, (void*)t);
       
       
    }

    // Wait for threads to finish
    for (int i = 0; i < threads; ++i) {
        pthread_join(thread_handles[i], nullptr);
    }

    // Destroy barrier
    pthread_barrier_destroy(&barrier);


    if (steps % 2) {
        swap(state, next_state);
    }
}