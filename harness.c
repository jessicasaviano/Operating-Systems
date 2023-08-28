#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

int main(int argc, char *argv[]){

    FILE *f = fopen(argv[1], "r");
    char str[41];
    int c;
    int count = 0;    
            if(argv[2] == "echo"){ 
                while((c = fgetc(f)) != EOF){
                   if (c == '\n') {
                    str[count] = '\0'; 
                    printf("%s\n", str);
                    count = 0;
        } else {
            str[count] = c;
            count++;
        }
                 
            } 
                           
    
            //if(argv[2] == "tail"){
                //do something ("the inconjunction with functionanlity specified below")
   // }
          //  if(argv[2] == "tail-remove"){
        
                //do something
   // }
            }
    
return 0;

}



