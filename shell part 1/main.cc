#include <cstdlib>
#include <iostream>
#include <string>
#include <cstring>
#include <sys/wait.h>
#include <bits/stdc++.h>
#include <sys/stat.h>

using namespace std;
 void child_and_IO(vector<string> &commands){
        int status;

    // Convert vector of strings to a vector of char*
    vector<char*> argv;
    for (const string& command : commands) {
        argv.push_back(const_cast<char*>(command.c_str()));
    }
    argv.push_back(nullptr);

    int pid = fork();

    if (pid == 0) {
        // Child process
        // Execute the command
        execvp(argv[0], argv.data());

        // If execvp fails
        cerr << "Error: Command not found" << endl;
        exit(1);
    } else if (pid > 0) {
        // Parent process
        // Wait for the child process to complete
        wait(&status);

        // Check how the command terminated
        if (WIFEXITED(status)) {
            // The command exited normally
            cout << commands[0] << " exit status: " << WEXITSTATUS(status) << endl;
        } else if (WIFSIGNALED(status)) {
            // The command was terminated by a signal
            cout << commands[0] << " terminated by signal: " << WTERMSIG(status) << endl;
        }
    } else {
        cerr << "Error: Fork failed" << endl;
        exit(1);
    }
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
    string current_input_file;
    string current_output_file;
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
        printf("hey\n");
        return;
    }
    if(tokens[0] == "exit"){
        tokens.clear();
        tokens.shrink_to_fit();
        printf("hi\n");
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
         cout << current_input_file<< endl;
         cout << current_output_file << endl;
    }

    
    if(commands.size() == 0){
        cerr << "invalid command" << endl;
        cout << command <<":" << " exit status: 255" << endl;
    }
    else{
        //for (vector<string>::iterator t=commands.begin(); t!=commands.end(); ++t) {
        //cout<<*t<<endl;
    //}
        
        child_and_IO(commands);
    }


    }

   

    /*example shell
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



int main(void) {
    std::string command;
    std::cout << "> ";
    while (std::getline(std::cin, command)) {
        parse_and_run_command(command);
        std::cout << "> ";
    }
    return 0;
}
