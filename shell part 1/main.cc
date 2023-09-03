#include <cstdlib>
#include <iostream>
#include <string>
#include <cstring>
#include <sys/wait.h>
#include <bits/stdc++.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "unistd.h"

using namespace std;
 void child_and_IO(vector<string> &commands, string input, string output){
        int status;

    // Convert vector of strings to a vector of char*
    vector<char*> execute;
    for (vector<string>::iterator t=commands.begin(); t!=commands.end(); ++t) {
        execute.push_back(strdup(t->c_str()));
    }
    execute.push_back(nullptr);
    int pid = fork();
    if (pid == 0) {
        // Child process
        //I/O GOES IN CHILD PROCESS, BEFORE PARENT!
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
            out_re = open(output.c_str(), O_RDWR | O_CLOEXEC, 0666);
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
        // Parent process
        // Wait for the child process to complete
        wait(&status);
       if (WIFEXITED(status)) {
            // exited normally
            cout << commands[0] << " exit status: " << WEXITSTATUS(status) << endl;
        } 
       
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
    exit(1);
}

    
void parse_and_run_command(const std::string &command) {
    /* TODO: Implement this. */
    /* Note that this is not the correct way to test for the exit command.
       For example the command "   exit  " should also exit your shell.
     */
    //get rid of whitespaces and out all content in a vector of strings
    std::istringstream ss(command);
    std::string token;
    vector<string> input_files;
    vector<string> output_files;
    string current_input_file = "none";
    string current_output_file = "none";
    bool redirect_input = false;
    bool redirect_output = false;

    std::vector<std::string> tokens;
    vector<string> commands = vector<string>();
    while(ss >> token){
        tokens.push_back(token);
    }
    int number = tokens.size();
    //start parsing thru
    if(tokens.size() == 0){
        return;
    }
    if(tokens[0] == "exit"){
        tokens.clear();
        tokens.shrink_to_fit();
        exit(0);
    }
    else{

         for(int i = 0; i < number; i++){
            if(tokens[i] == "|"){
                exit(0);
            }
            
        if (tokens[i] == "<") {
           
            redirect_input = true;
        } else if (tokens[i] == ">") {
            // Output redirection detected
            redirect_output = true;
        } else if (redirect_input) {
            current_input_file = tokens[i];
            //cout << tokens[i];
            redirect_input = false;
        } else if (redirect_output) {
            // Store the output file
            current_output_file = tokens[i];
            redirect_output = false;
        } else {
            // Regular command or argument
            commands.push_back(tokens[i]);
        }
         }
         //test!
         //cout << current_input_file<< endl;
         //cout << current_output_file << endl;
    }

    if(commands.size() == 0){
        cerr << "invalid command" << endl;
        cout << command <<":" << " exit status: 255" << endl;
    }
    else{
        //for (vector<string>::iterator t=commands.begin(); t!=commands.end(); ++t) {
        //cout<<*t<<endl;
    //}
        
        child_and_IO(commands, current_input_file, current_output_file);
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

    /*example shell, helped me do it all!
    while((s = Getline())! = EOF) {
        if((pid=fork) == 0){      //child
            //I/O redirection
            close(stdout);
            fd = open(file);
            r = execlp("...");
            if(r<0)
                //handle error
        }
        else if(pid >0){    //parent
            //if no & in command line
            wait(&status);

    }else
        exit(0);

    }
    
    if (command == "exit") {
        exit(0);
    }
    std::cerr << "Not implemented.\n";
}

*/




