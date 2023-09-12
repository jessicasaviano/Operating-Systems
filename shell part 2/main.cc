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
#include <map>
using namespace std;
typedef struct {   
  int fds[2] = {-1, -1};
  int pid = -1;
  vector<string> c;
} child;

typedef struct {
    string input_name;
    string output_name;
    vector<string> commandz;
} each_command;

void set_fd_cloexec(int * fds){
    int flags = fcntl(*fds, F_GETFD);
    if (flags == -1) {
        cerr << "ERR: fcntl failed" << endl;
        exit(1);
    }
    flags |= FD_CLOEXEC;
    if (fcntl(*fds, F_SETFD, flags) == -1) {
        cerr << "ERR: fcntl failed" << endl;
        exit(1);
    }

    
}

// /bin/cat Makefile > output2.txt  | grep msh: then pipe is done

void run_pipes(vector<vector<string>> &commands){
    
    int n = commands.size();
    string inp;
    string outp;
    vector<child*> command;
    for (int i = 0; i < n; i++) {
        child *current = new child();
        command.push_back(current);

        if (pipe(current->fds) < 0){
            cerr << "pipe error" << endl;
            exit(1);
        }
        set_fd_cloexec(current->fds);
       
    
       
    // pip ein of first is false, pipe out is false for lat, everything else true
        int pid = fork();
        if(pid == 0){
     
            //child
            if(i > 0){
                close(STDIN_FILENO);
                dup2(command[i-1]->fds[0], STDIN_FILENO);
                

              
            }

            if(i < (n-1)){
                close(STDOUT_FILENO);
                dup2(command[i]->fds[1], STDOUT_FILENO);
               
            }

            
        
           // I/O redirection
           
           string in;
           string out;
           int numb = commands[i].size();
            bool com = false;
            for (int j = 0; j < numb; j++) {
                if (commands[i][j] == "<") {
                    in = commands[i][j + 1];
                    j++; // Skip the input file name
                } else if (commands[i][j] == ">") {
                     out = commands[i][j + 1];
                    j++; // Skip the output file name
                }
                else{
                    com = true;
                }
                }
                if(com == false){
                     cerr << "invalid command" << endl;
                    cout <<"invalid command:"<< commands[i][0] <<":" << " exit status: 255" << endl;
                    exit(1);
                }
            

                
      
         

            vector<string> real;
            int num1 = commands[i].size();

            for(int j = 0; j < num1; j++){
                if(commands[i][j] != "<" && commands[i][j] != ">" && commands[i][j] != in && commands[i][j] != out ){
                    real.push_back(commands[i][j]);
            }

        }

            vector<char*> execute;
            for (vector<string>::iterator t = real.begin(); t != real.end(); ++t) {
                execute.push_back(strdup(t->c_str()));
            }
            execute.push_back(nullptr);

            

            int in_re = 0;
            int out_re = 0;

     
    if (!in.empty()) {
        in_re = open(in.c_str(), O_RDWR | O_CLOEXEC, 0666);
        if (in_re == -1) {
            cerr << "couldn't open file" << endl;
            exit(1);
                }

            dup2(in_re, STDIN_FILENO);
            close(in_re);
                }
            
  
        if (!out.empty()) {
            out_re = open(out.c_str(), O_RDWR | O_CREAT | O_TRUNC | O_CLOEXEC, 0666);
            if (out_re == -1) {
                cerr << "couldn't open file" << endl;
                exit(1);
                }
                //cout << "happens" << endl;
                dup2(out_re, STDOUT_FILENO);
                close(out_re);
            }
    
      
         execv(execute[0], execute.data());
         
         perror(execute[0]);
    
    for(char* arg : execute) {
        if (arg) {
            free(arg);
        }
    }

    execute.clear();
    execute.shrink_to_fit();
}
        

        else if(pid > 0){
            command[i]->pid = pid;
            close(command[i]->fds[1]);
            
        }

        else{
            cerr << "ERR: fork failed" << endl;
            return;
        }

        }
        
    for (int i = 0; i < n; i++) {
        if (command[i]->pid > 0) {
            int status = 0;
            waitpid(command[i]->pid, &status, 0);
            close(command[i]->fds[0]);
            cout << commands[i][0] << " exit status: " << WEXITSTATUS(status) << endl;
        }
        
        }

    commands.clear();
    commands.shrink_to_fit();
    for (child* ch : command) {
        delete ch;
    }
    command.clear();
    command.shrink_to_fit();

    }

void parse_and_run_command(const std::string &command) {

    std::istringstream ss(command);
    std::string token;
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
        
            else if (tokens[i] == "<") {
                if(i == number-1 || tokens[number-1] == "|"){
                    cerr <<"invalid command" << endl;
                    cout << command <<":" << " exit status: 255" << endl;
                    exit(1);
                   
                }
                else{
                    if(tokens[i+1] == "<" ||tokens[i+1] == ">" ){
                        cerr << "invalid command" << endl;
                        cout <<"invalid command:"<< command <<":" << " exit status: 255" << endl;
                        exit(1);
                        
                    }
                 
                single_c.push_back(tokens[i]);
                } 

            } else if (tokens[i] == ">") {

                if(i == number-1 || tokens[number-1] == "|"){
                    
                    cerr << "invalid command" << endl;
                    cout <<"invalid command:"<< command <<":" << " exit status: 255" << endl;
                    
                }

                else{
                    if(tokens[i+1] == "<" ||tokens[i+1] == ">" ){
                        
                        cerr << "invalid command" << endl;
                        cout <<"invalid command:"<< command <<":" << " exit status: 255" << endl;
                        
                    }

                    single_c.push_back(tokens[i]);
                }
               
            }
            

            else{
                    single_c.push_back(tokens[i]);
                }

                if(tokens[i] == "|"){
                    if(i == number - 1){
                        
                        cerr << "invalid command" << endl;
                        cout <<"invalid command:"<< command <<":" << " exit status: 255" << endl;
                        exit(0);
                        
                    }

                }
                
                }
                }

            if(!single_c.empty()) {
                commands.push_back(single_c);
            }

            if (commands.empty()) {
                
                cerr << "Invalid command" << endl;
                cout << "Invalid command:" << command << ":" << " exit status: 255" << endl;
                exit(1);
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

