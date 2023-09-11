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
typedef struct {   
  int fds[2] = {-1, -1};
  int pid = -1;
} child;



void set_fd_cloexec(int * fds){


    int flags = fcntl(*fds, F_GETFD);

    if (flags == -1) {
        cerr << "ERR: fcntl failed" << endl;
 
    }
    flags |= FD_CLOEXEC;
    if (fcntl(*fds, F_SETFD, flags) == -1) {
        cerr << "ERR: fcntl failed" << endl;
     
    }
    /*
     int flags = fcntl(fds[1], F_GETFD);
    if (flags == -1) {
        cerr << "ERR: fcntl failed" << endl;
      
    }
    flags |= FD_CLOEXEC;
    if (fcntl(fds[1], F_SETFD, flags) == -1) {
        cerr << "ERR: fcntl failed" << endl;
        
    }
    */
}



void IO(vector<string> &commands, string input, string output) {
  
    vector<char*> execute;
    for (vector<string>::iterator t = commands.begin(); t != commands.end(); ++t) {
        execute.push_back(strdup(t->c_str()));
    }

    execute.push_back(nullptr);

        // I/O redirection
        int in_re = 0;
        int out_re = 0;

         if(input != "none"){
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
       

       if (output != "none") {
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

        if (!input.empty()) {
            dup2(in_re, STDIN_FILENO);

        }

        if (!output.empty()) {
             dup2(out_re, STDOUT_FILENO);

        }

        execvp(execute[0], execute.data());
     
    

    for (char* arg : execute) {
        if (arg) {
            free(arg);
        }
    }
    execute.clear();
    execute.shrink_to_fit();
}
void run_pipes(vector<vector<string>> &commands){
   /* 
    for(size_t i = 0; i < commands.size(); i ++){
        //cout << "NEW" << endl;
        for(size_t j = 0; j < commands[i].size(); j++){
            cout << commands[i][j] << endl;

        }
    }
*/
   

    int n = commands.size();
    vector<child*> command;
    for (int i = 0; i < n; i++) {
        cout << "hi" << endl;
        int single = commands[i].size();
        string current_input_file;
        string current_output_file;
        for(int j = 0; j < single; j++){
        if (commands[i][j] == "<") {
                if(i == single-1){
                    cerr << "invalid command" << endl;
                    cout <<"invalid command:" << command[i] <<":" << " exit status: 255" << endl;
                }
                else{
                    if(commands[i][j+1] == "<" ||commands[i][j+1] == ">" ){
                        cerr << "invalid command" << endl;
                    cout <<"invalid command:"<< command[i] <<":" << " exit status: 255" << endl;

                    }
                 current_input_file = commands[i][j+1];
                 i+=1;
                }

            } else if (commands[i][j] == ">") {

                if(i == single-1){
                    cerr << "invalid command" << endl;
                    cout <<"invalid command:"<< command[i] <<":" << " exit status: 255" << endl;
                }

                else{
                    if(commands[i][j+1] == "<" ||commands[i][j+1] == ">" ){
                        cerr << "invalid command" << endl;
                    cout <<"invalid command:"<< command[i] <<":" << " exit status: 255" << endl;
                    }
   
                 current_output_file = commands[i][j+1];
                 i+=1;
                }
            }
        }
            
        child *current = new child();
        command.push_back(current);
        if (pipe(current->fds) < 0){
            cerr << "pipe error" << endl;
            exit(1);
        }
        set_fd_cloexec(current->fds);

        int pid = fork();
        if(pid == 0){
            //child
            if(i > 0){
                dup2(command[i-1]->fds[0], STDIN_FILENO);

            }

            if(i > (n-1)){
                dup2(command[i]->fds[1], STDOUT_FILENO);

            }
            IO(commands[i], current_input_file, current_output_file);
        }

        else if(pid > 0){
             if (command[i]->pid > 0) {
                int status = 0;
                waitpid(command[i]->pid, &status, 0);
                close(command[i]->fds[0]);
                cout << commands[i][0] << " exit status: " << WEXITSTATUS(status) << endl;
        }
            command[i]->pid = -1;
            close(command[i]->fds[1]);
          
        }

        else{
            cerr<< "FORK FAILED" << endl;
        }

        }







    }



void parse_and_run_command(const std::string &command) {
    map<string, string> IO_map;   

    std::istringstream ss(command);
    std::string token;
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
             

            } 
           /*

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
            }
            
            */

            else{
                    single_c.push_back(tokens[i]);
            }
                }
            }

            if (!single_c.empty()) {
            commands.push_back(single_c);
            }

            if (commands.empty()) {
            cerr << "Invalid command" << endl;
            cout << "Invalid command:" << command << ":" << " exit status: 255" << endl;
        } 
        else{
            run_pipes(commands);
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

