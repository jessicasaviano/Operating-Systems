#include <cstdlib>
#include <iostream>
#include <string>
#include <cstring>
#include <sys/wait.h>
#include <bits/stdc++.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "unistd.h"
#include <vector>
#include <algorithm>

using namespace std;

void child_and_IO(vector<string> &commands, string input, string output, int pipe_in = -1, int pipe_out = -1) {
    int status;
    vector<char*> execute;
    for (vector<string>::iterator t = commands.begin(); t != commands.end(); ++t) {
        execute.push_back(strdup(t->c_str()));
    }

    execute.push_back(nullptr);

    int pid = fork();
    if (pid == 0) { 
        // Child process
        // I/O redirection
        int in_re = 0;
        int out_re = 0;

        if (pipe_in != -1) {
            dup2(pipe_in, STDIN_FILENO);
            close(pipe_in);
        } else if (input != "none") {
            if (!input.empty()) {
                in_re = open(input.c_str(), O_RDWR | O_CLOEXEC, 0666);
                if (in_re == -1) {
                    cerr << "couldn't open file" << endl;
                    exit(1);
                }
                dup2(in_re, STDIN_FILENO);
                close(in_re);
            }
        }

        if (pipe_out != -1) {
            dup2(pipe_out, STDOUT_FILENO);
            close(pipe_out);
        } else if (output != "none") {
            if (!output.empty()) {
                out_re = open(output.c_str(), O_RDWR | O_CREAT | O_TRUNC | O_CLOEXEC, 0666);
                if (out_re == -1) {
                    cerr << "couldn't open file" << endl;
                    exit(1);
                }
                dup2(out_re, STDOUT_FILENO);
                close(out_re);
            }
        }

        execvp(execute[0], execute.data());
     
    } else if (pid > 0) {
        // Parent process
        wait(&status);
        cout << commands[0] << " exit status: " << WEXITSTATUS(status) << endl;
    } else {
        cerr << "ERR: fork failed" << endl;
        return;
    }

    for (char* arg : execute) {
        if (arg) {
            free(arg);
        }
    }
    execute.clear();
    execute.shrink_to_fit();
}



void set_fd_cloexec(int fd) {
    int flags = fcntl(fd, F_GETFD);
    if (flags == -1) {
        cerr << "ERR: fcntl failed" << endl;
        exit(1);
    }
    flags |= FD_CLOEXEC;
    if (fcntl(fd, F_SETFD, flags) == -1) {
        cerr << "ERR: fcntl failed" << endl;
        exit(1);
    }
}


void parse_and_run_command(const std::string &command) {

    std::istringstream ss(command);
    std::string token;
    int pipe_in = -1;
    int pipe_out = -1;
    vector<string> input_files;
    vector<string> output_files;
    string current_input_file = "none";
    string current_output_file = "none";
    std::vector<std::string> tokens;
    vector<vector<string>> commands;
    vector<string> single_c = vector<string>();
    
    while(ss >> token){
        tokens.push_back(token);
    }
    if(tokens.size() == 0){
        return;
    }
    if(tokens[0] == "exit"){
        tokens.clear();
        tokens.shrink_to_fit();
        exit(0);
    }
    else{
        
        int number = tokens.size();
        for(int i = 0; i < number; i++){
            if(tokens[i] == "|"){
                if (!single_c.empty()) {
                    commands.push_back(single_c);
                    single_c.clear();
                }
                int pipe_fds[2];
            if (pipe(pipe_fds) == -1) {
                cerr << "ERR: pipe failed" << endl;
                exit(1);
            }
            pipe_in = pipe_fds[0];
            pipe_out = pipe_fds[1];
            set_fd_cloexec(pipe_in);
            set_fd_cloexec(pipe_out);
            } 
           
            else if (tokens[i] == "<") {
                if(i == number-1){
                    cerr << "invalid command" << endl;
                    cout <<"invalid command:"<< command <<":" << " exit status: 255" << endl;
                }
                else{
                    if(tokens[i+1] == "<" ||tokens[i+1] == ">" ){
                        cerr << "invalid command" << endl;
                    cout <<"invalid command:"<< command <<":" << " exit status: 255" << endl;

                    }
                 current_input_file = tokens[i+1];
                 i+=1;
                }

            } else if (tokens[i] == ">") {

                if(i == number-1){
                    cerr << "invalid command" << endl;
                    cout <<"invalid command:"<< command <<":" << " exit status: 255" << endl;
                }

                else{
                    if(tokens[i+1] == "<" ||tokens[i+1] == ">" ){
                        cerr << "invalid command" << endl;
                    cout <<"invalid command:"<< command <<":" << " exit status: 255" << endl;
                    }
   
                 current_output_file = tokens[i+1];
                 i+=1;
                }
            } else{
                    single_c.push_back(tokens[i]);
            }
                }
            }

            if (!single_c.empty()) {
            commands.push_back(single_c);
            }
            if(commands.size() == 0){
                cerr << "invalid command" << endl;
                    cout <<"invalid command:"<< command <<":" << " exit status: 255" << endl;

            }
           
           for (size_t i = 0; i < commands.size(); i++) {
                cout << "NEW COMMAND" << endl;
            for(size_t j = 0; j < commands[i].size(); j ++){
                    cout << commands[i][j] << endl;
            }
        // Execute the commands in the pipeline
        int prev_pipe_out = -1;
        if (i == commands.size() - 1) {
            cout << "hi" << endl;
            // Last command in the pipeline
            child_and_IO(commands[i], current_input_file, current_output_file, prev_pipe_out, -1);
        } else if (i == 0) {
            cout << "hi1" << endl;
            // First command in the pipeline
            child_and_IO(commands[i], current_input_file, current_output_file, -1, pipe_out);
        } else {
            cout << "hi2" << endl;
            // Intermediate commands in the pipeline
            child_and_IO(commands[i], current_input_file, current_output_file, prev_pipe_out, pipe_out);
        }
          prev_pipe_out = pipe_out; // Update prev_pipe_out for the next iteration
    }


    tokens.clear();
    tokens.shrink_to_fit();
    }
    int main(void) {
    std::string command;
    std::cout << "> ";
    while (std::getline(std::cin, command)) {
        parse_and_run_command(command);
        std::cout << "> ";
    }
    return 0;
}

