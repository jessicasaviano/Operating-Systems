#include <cstdlib>
#include <iostream>
#include <string>
#include <cstring>
#include <sys/wait.h>
#include <bits/stdc++.h>
#include <sys/stat.h>

using namespace std;

void parse_and_run_command(const std::string &command) {
    /* TODO: Implement this. */
   
    /* Note that this is not the correct way to test for the exit command.
       For example the command "   exit  " should also exit your shell.
     */


    //get rid of whitespaces and out all content in a vector of strings
    std::istringstream ss(command);
    std::string token;
    std::vector<std::string> tokens;
    while(ss >> token){
        tokens.push_back(token);
    }
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
