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


bool invalid_command(vector<string> &command_line){
      /*
            if(command_line[0] == "<" || command_line[0] == ">" ){
                    if(command_line.size()> 1){
                        return true;
                    }
                    else{
                        return false;
                    }
            }
            */
           
            int num = command_line.size()-1;
            

            for(int i = 0; i < num; i++){
              
                //cout << "now:" << command_line[i]<< endl;
                //cout << "and:" << command_line[i+1]<< endl;
                if(command_line[i] == "<"){
                    //cout << "this:"<< num-1 << endl;
                    //cout << "that"<< i <f< endl;
                    if(num - 1 == i ){
                        if(command_line[num - 1] != "<" || command_line[num - 1] != ">") {
                        return true;
                        }
                    }
                    else if (i+2 > 0 && i+2 <= num){
                            if(command_line[i+2] == ">"){
                                return true;
                            }
                    

                    }
                }
                if(command_line[i] == ">"){
                    //cout << "this:"<< num-1 << endl;
                    //cout << "that"<< i <f< endl;
                    if(num - 1 == i ){
                        return true;
                    }
                    else if (i+2 > 0 && i+2 <= num){
                            if(command_line[i+2] == "<"){
                                return true;
                            }
                    

                    }
                }
           

            }
         
        if (std::count(command_line.begin(), command_line.end(), ">") || std::count(command_line.begin(), command_line.end(), ">")){
            return false;
                }
        else{
            cout << "hi";
            return true;
        }

        
        return false;

}




 void child_and_IO(vector<string> &commands, string input, string output){
        int status;
    // Convert vector of strings to a vector of char*
    vector<char*> execute;
    /*
    for (vector<string>::iterator t=commands.begin(); t!=commands.end(); ++t) {
        execute.push_back(strdup(t->c_str()));
    }
    */
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
        cout << "here:" <<execute[0]<<endl;
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
         if(invalid_command(tokens) != false){
            int number = tokens.size();
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
            //for (vector<string>::iterator t=commands.begin(); t!=commands.end(); ++t) {
              //      cout<<"this:"<<*t<<endl;
                //    }
            child_and_IO(commands, current_input_file, current_output_file);
  
         }
         else{
            cerr << "invalid command" << endl;
        cout << command <<":" << " exit status: 255" << endl;

         }
         //test!
         //cout << current_input_file<< endl;
         //cout << current_output_file << endl;
    }
        //for (vector<string>::iterator t=commands.begin(); t!=commands.end(); ++t) {
        //cout<<*t<<endl;
    //}
        
        
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




