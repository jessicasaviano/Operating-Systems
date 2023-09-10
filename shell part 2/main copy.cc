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
 void child_and_IO(vector<string> &commands, string input, string output){
    int status;
    vector<char*> execute;
    for (vector<string>::iterator t=commands.begin(); t!=commands.end(); ++t) {
        execute.push_back(strdup(t->c_str()));
    }  

    
    execute.push_back(nullptr);

    int pid = fork();
    if (pid == 0) {
        // Child process
        //I/O GOES IN CHILD PROCESS, BEFORE PARENT!
        //WHERE PIPES GET ATTACHED TO INPUT/OUTPUT
        int in_re = 0;
        int out_re = 0;
        if(input != "none"){
            if(!input.empty()){
            in_re = open(input.c_str(), O_RDWR | O_CLOEXEC, 0666);
            if(in_re == -1){
                cerr<< "couldn't open file" << endl;
                exit(1);
            }
            dup2(in_re, STDIN_FILENO);
           close(in_re);
        }
        }

        if(output != "none"){
            if(!output.empty()){
            out_re = open(output.c_str(), O_RDWR | O_CREAT | O_TRUNC | O_CLOEXEC, 0666);
            if(out_re == -1){
                cerr<< "couldn't open file" << endl;
                exit(1);
            }
            dup2(out_re, STDOUT_FILENO);
            close(out_re);
        }
        }

         execv(execute[0], execute.data());
         perror(execute[0]);
    } else if (pid > 0) {
        //THIS IS PARENT AND WHERE THE PIPES GET CREATED:
        wait(&status);
            cout << commands[0] << " exit status: " << WEXITSTATUS(status) << endl;
    } 
    else {
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

void parse_and_run_command(const std::string &command) {

    std::istringstream ss(command);
    std::string token;
    vector<string> input_files;
    vector<string> output_files;
    string current_input_file = "none";
    string current_output_file = "none";
    std::vector<std::string> tokens;
    vector<string> commands = vector<string>();
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
                exit(0);
                }

            if (tokens[i] == "<") {
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
                    commands.push_back(tokens[i]);
            }
                }
            }

            if(commands.size() == 0){
                cerr << "invalid command" << endl;
                    cout <<"invalid command:"<< command <<":" << " exit status: 255" << endl;

            }
            child_and_IO(commands, current_input_file, current_output_file);

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

