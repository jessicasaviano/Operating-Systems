#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"
#include "traps.h"
#include "spinlock.h"


extern pte_t * walkpgdir(pde_t *pgdir, const void *va, int alloc);
extern int mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm);

// Interrupt descriptor table (shared by all CPUs).
struct gatedesc idt[256];
extern uint vectors[];  // in vectors.S: array of 256 entry pointers
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);

  initlock(&tickslock, "time");
}

void
idtinit(void)
{
  lidt(idt, sizeof(idt));
}

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(myproc()->killed)
      exit();
    myproc()->tf = tf;
    syscall();
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
    break;
  
  case T_PGFLT: 
    //Get the address using rc2() \\static inline uint type
        {
     uint address = PGROUNDDOWN(rcr2());
     //case w/ trap frame, before u accept the address
      /*
       if((tf->cs & 3) == 0){
         cprintf(" kernel mode exception, address");
        goto default2;
        
       }
       */
     
     if(myproc()->sz  <= address || address >= KERNBASE){
         cprintf("oob\n");
        goto default2;
     }
     ///wether its outside the size of the process or outside KERNBASE
    
    //now lets do PTE stuff like part 1
     pte_t *pte = walkpgdir(myproc()->pgdir, (void*)address, 1);
    //check if page is guard page: presetn but not usable
    
    if(((*pte & PTE_P) && !(*pte & PTE_U))&& pte != 0){
      cprintf("guard page");
      goto default2;
       }
    
    
  //obtain a free page: take one! use kalloc!
 
    char *free = kalloc();
    if(free == 0){
      cprintf("free page");
       goto default2;
    }

  //zero out the pageeee, use memset!
  memset(free,0,PGSIZE);

  //update the page table, got this next line directly from vm./c
    if(mappages(myproc()->pgdir, (char*)address, PGSIZE, V2P(free), PTE_W|PTE_U) < 0){
      cprintf("update");
  
      freevm(myproc()->pgdir);
      
      goto default2;

    }

     // flush!!!
     //switchuvm
      switchuvm(myproc());
      break;
      

        }




  

  //PAGEBREAK: 13
  default:
  default2:
    if(myproc() == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
}
