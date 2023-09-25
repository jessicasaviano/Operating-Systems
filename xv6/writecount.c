#include "types.h"
#include "stat.h"
#include "user.h"

 
   int main() {
  
      int result = writecount();
      printf(1,"Number of sys_write calls: %d\n", result);
       exit();


 

}