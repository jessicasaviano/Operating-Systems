#include <cstdlib>
#include <iostream>
#include <string>
#include <cstring>
#include <sys/wait.h>
#include <bits/stdc++.h>
#include <sys/stat.h>

using namespace std;
 void child_and_IO(vector<string> &stuff){
       
        printf("hi!!");

    }



void parse_and_run_command(const std::string &command) {
    /* TODO: Implement this. */
    /* Note that this is not the correct way to test for the exit command.
       For example the command "   exit  " should also exit your shell.
     */
    //get rid of whitespaces and out all content in a vector of strings
    std::istringstream ss(command);
    std::string token;
    std::vector<std::string> tokens;
    std::vector<std::string> commands;
    while(ss >> token){
        tokens.push_back(token);
    }
    int number = tokens.size() - 1;
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
        //cout << tokens[i] << "," << endl;
        //cout << number << "," << endl;
            if(tokens[i] == "<" ){
                if(tokens.size() > 3){
                    cout << tokens[i+2];
                    if(tokens[i+2] == ">"){
                        commands.push_back(tokens[i]);

                }
                 }
                else{
                    if( i == number - 1){
                    commands.push_back(tokens[i]);
                 }
               
            }
            }
           else if(tokens[i] == ">" ){
               if(tokens.size() > 3){
                    cout << tokens[i+2];
                    if(tokens[i+2] == "<"){
                        commands.push_back(tokens[i]);

                }
                 }
                else{
                    if( i == number - 1){
                    commands.push_back(tokens[i]);
                 }
               
            }
            }

    }


}
    
    if(commands.size() == 0){
        cerr << "invalid command" << endl;
        cout << command <<":" << " exit status: 255" << endl;
    }
    else{
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
