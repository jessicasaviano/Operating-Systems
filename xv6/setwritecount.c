#include "types.h"
#include "stat.h"
#include "user.h"


int
main(int argc, char **argv)
{
  
  if(argc < 2 ||argc > 2 ){
    printf(1, "error\n");
    exit();
  }
  if(argc == 2){
    
    setwritecount(atoi(argv[1]));
    //int counter = writecount();

    //printf(1," Number of sys_write calls set to: %d\n", counter);
      
  }

  exit();
}
