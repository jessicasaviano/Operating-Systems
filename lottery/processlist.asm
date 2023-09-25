
_processlist:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "param.h"
#include "processesinfo.h"
#include "user.h"

int main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	81 ec 1c 03 00 00    	sub    $0x31c,%esp
   
    struct processes_info info;
    info.num_processes = -9999;  // to make sure getprocessesinfo() doesn't
  15:	c7 85 f4 fc ff ff f1 	movl   $0xffffd8f1,-0x30c(%ebp)
  1c:	d8 ff ff 
                                 // depend on its initial value
    getprocessesinfo(&info);
  1f:	8d 85 f4 fc ff ff    	lea    -0x30c(%ebp),%eax
  25:	50                   	push   %eax
  26:	e8 54 01 00 00       	call   17f <getprocessesinfo>
    if (info.num_processes < 0) {
  2b:	83 c4 10             	add    $0x10,%esp
  2e:	83 bd f4 fc ff ff 00 	cmpl   $0x0,-0x30c(%ebp)
  35:	78 2e                	js     65 <main+0x65>
        printf(1, "ERROR: negative number of processes!\n"
                  "Myabe getprocessesinfo() assumes that num_processes is\n"
                  "always initialized to 0?\n");
    }
    printf(1, "%d running processes\n", info.num_processes);
  37:	83 ec 04             	sub    $0x4,%esp
  3a:	ff b5 f4 fc ff ff    	push   -0x30c(%ebp)
  40:	68 32 04 00 00       	push   $0x432
  45:	6a 01                	push   $0x1
  47:	e8 e0 01 00 00       	call   22c <printf>
    printf(1, "PID\tTICKETS\tTIMES-SCHEDULED\n");
  4c:	83 c4 08             	add    $0x8,%esp
  4f:	68 48 04 00 00       	push   $0x448
  54:	6a 01                	push   $0x1
  56:	e8 d1 01 00 00       	call   22c <printf>
    for (int i = 0; i < info.num_processes; ++i) {
  5b:	83 c4 10             	add    $0x10,%esp
  5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  63:	eb 3e                	jmp    a3 <main+0xa3>
        printf(1, "ERROR: negative number of processes!\n"
  65:	83 ec 08             	sub    $0x8,%esp
  68:	68 94 03 00 00       	push   $0x394
  6d:	6a 01                	push   $0x1
  6f:	e8 b8 01 00 00       	call   22c <printf>
  74:	83 c4 10             	add    $0x10,%esp
  77:	eb be                	jmp    37 <main+0x37>
        printf(1, " PIDDD: %d\t%d\t%d\n", info.pids[i], info.tickets[i], info.times_scheduled[i]);
  79:	83 ec 0c             	sub    $0xc,%esp
  7c:	ff b4 9d f8 fd ff ff 	push   -0x208(%ebp,%ebx,4)
  83:	ff b4 9d f8 fe ff ff 	push   -0x108(%ebp,%ebx,4)
  8a:	ff b4 9d f8 fc ff ff 	push   -0x308(%ebp,%ebx,4)
  91:	68 65 04 00 00       	push   $0x465
  96:	6a 01                	push   $0x1
  98:	e8 8f 01 00 00       	call   22c <printf>
    for (int i = 0; i < info.num_processes; ++i) {
  9d:	83 c3 01             	add    $0x1,%ebx
  a0:	83 c4 20             	add    $0x20,%esp
  a3:	39 9d f4 fc ff ff    	cmp    %ebx,-0x30c(%ebp)
  a9:	7f ce                	jg     79 <main+0x79>
    }
     printf(1, "ERROR: negative number of processes!\n");
  ab:	83 ec 08             	sub    $0x8,%esp
  ae:	68 0c 04 00 00       	push   $0x40c
  b3:	6a 01                	push   $0x1
  b5:	e8 72 01 00 00       	call   22c <printf>
    exit();
  ba:	e8 08 00 00 00       	call   c7 <exit>

000000bf <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  bf:	b8 01 00 00 00       	mov    $0x1,%eax
  c4:	cd 40                	int    $0x40
  c6:	c3                   	ret    

000000c7 <exit>:
SYSCALL(exit)
  c7:	b8 02 00 00 00       	mov    $0x2,%eax
  cc:	cd 40                	int    $0x40
  ce:	c3                   	ret    

000000cf <wait>:
SYSCALL(wait)
  cf:	b8 03 00 00 00       	mov    $0x3,%eax
  d4:	cd 40                	int    $0x40
  d6:	c3                   	ret    

000000d7 <pipe>:
SYSCALL(pipe)
  d7:	b8 04 00 00 00       	mov    $0x4,%eax
  dc:	cd 40                	int    $0x40
  de:	c3                   	ret    

000000df <read>:
SYSCALL(read)
  df:	b8 05 00 00 00       	mov    $0x5,%eax
  e4:	cd 40                	int    $0x40
  e6:	c3                   	ret    

000000e7 <write>:
SYSCALL(write)
  e7:	b8 10 00 00 00       	mov    $0x10,%eax
  ec:	cd 40                	int    $0x40
  ee:	c3                   	ret    

000000ef <close>:
SYSCALL(close)
  ef:	b8 15 00 00 00       	mov    $0x15,%eax
  f4:	cd 40                	int    $0x40
  f6:	c3                   	ret    

000000f7 <kill>:
SYSCALL(kill)
  f7:	b8 06 00 00 00       	mov    $0x6,%eax
  fc:	cd 40                	int    $0x40
  fe:	c3                   	ret    

000000ff <exec>:
SYSCALL(exec)
  ff:	b8 07 00 00 00       	mov    $0x7,%eax
 104:	cd 40                	int    $0x40
 106:	c3                   	ret    

00000107 <open>:
SYSCALL(open)
 107:	b8 0f 00 00 00       	mov    $0xf,%eax
 10c:	cd 40                	int    $0x40
 10e:	c3                   	ret    

0000010f <mknod>:
SYSCALL(mknod)
 10f:	b8 11 00 00 00       	mov    $0x11,%eax
 114:	cd 40                	int    $0x40
 116:	c3                   	ret    

00000117 <unlink>:
SYSCALL(unlink)
 117:	b8 12 00 00 00       	mov    $0x12,%eax
 11c:	cd 40                	int    $0x40
 11e:	c3                   	ret    

0000011f <fstat>:
SYSCALL(fstat)
 11f:	b8 08 00 00 00       	mov    $0x8,%eax
 124:	cd 40                	int    $0x40
 126:	c3                   	ret    

00000127 <link>:
SYSCALL(link)
 127:	b8 13 00 00 00       	mov    $0x13,%eax
 12c:	cd 40                	int    $0x40
 12e:	c3                   	ret    

0000012f <mkdir>:
SYSCALL(mkdir)
 12f:	b8 14 00 00 00       	mov    $0x14,%eax
 134:	cd 40                	int    $0x40
 136:	c3                   	ret    

00000137 <chdir>:
SYSCALL(chdir)
 137:	b8 09 00 00 00       	mov    $0x9,%eax
 13c:	cd 40                	int    $0x40
 13e:	c3                   	ret    

0000013f <dup>:
SYSCALL(dup)
 13f:	b8 0a 00 00 00       	mov    $0xa,%eax
 144:	cd 40                	int    $0x40
 146:	c3                   	ret    

00000147 <getpid>:
SYSCALL(getpid)
 147:	b8 0b 00 00 00       	mov    $0xb,%eax
 14c:	cd 40                	int    $0x40
 14e:	c3                   	ret    

0000014f <sbrk>:
SYSCALL(sbrk)
 14f:	b8 0c 00 00 00       	mov    $0xc,%eax
 154:	cd 40                	int    $0x40
 156:	c3                   	ret    

00000157 <sleep>:
SYSCALL(sleep)
 157:	b8 0d 00 00 00       	mov    $0xd,%eax
 15c:	cd 40                	int    $0x40
 15e:	c3                   	ret    

0000015f <uptime>:
SYSCALL(uptime)
 15f:	b8 0e 00 00 00       	mov    $0xe,%eax
 164:	cd 40                	int    $0x40
 166:	c3                   	ret    

00000167 <yield>:
SYSCALL(yield)
 167:	b8 16 00 00 00       	mov    $0x16,%eax
 16c:	cd 40                	int    $0x40
 16e:	c3                   	ret    

0000016f <shutdown>:
SYSCALL(shutdown)
 16f:	b8 17 00 00 00       	mov    $0x17,%eax
 174:	cd 40                	int    $0x40
 176:	c3                   	ret    

00000177 <settickets>:
SYSCALL(settickets)
 177:	b8 18 00 00 00       	mov    $0x18,%eax
 17c:	cd 40                	int    $0x40
 17e:	c3                   	ret    

0000017f <getprocessesinfo>:
SYSCALL(getprocessesinfo)
 17f:	b8 19 00 00 00       	mov    $0x19,%eax
 184:	cd 40                	int    $0x40
 186:	c3                   	ret    

00000187 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 187:	55                   	push   %ebp
 188:	89 e5                	mov    %esp,%ebp
 18a:	83 ec 1c             	sub    $0x1c,%esp
 18d:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 190:	6a 01                	push   $0x1
 192:	8d 55 f4             	lea    -0xc(%ebp),%edx
 195:	52                   	push   %edx
 196:	50                   	push   %eax
 197:	e8 4b ff ff ff       	call   e7 <write>
}
 19c:	83 c4 10             	add    $0x10,%esp
 19f:	c9                   	leave  
 1a0:	c3                   	ret    

000001a1 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 1a1:	55                   	push   %ebp
 1a2:	89 e5                	mov    %esp,%ebp
 1a4:	57                   	push   %edi
 1a5:	56                   	push   %esi
 1a6:	53                   	push   %ebx
 1a7:	83 ec 2c             	sub    $0x2c,%esp
 1aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
 1ad:	89 d0                	mov    %edx,%eax
 1af:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 1b1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 1b5:	0f 95 c1             	setne  %cl
 1b8:	c1 ea 1f             	shr    $0x1f,%edx
 1bb:	84 d1                	test   %dl,%cl
 1bd:	74 44                	je     203 <printint+0x62>
    neg = 1;
    x = -xx;
 1bf:	f7 d8                	neg    %eax
 1c1:	89 c1                	mov    %eax,%ecx
    neg = 1;
 1c3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 1ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 1cf:	89 c8                	mov    %ecx,%eax
 1d1:	ba 00 00 00 00       	mov    $0x0,%edx
 1d6:	f7 f6                	div    %esi
 1d8:	89 df                	mov    %ebx,%edi
 1da:	83 c3 01             	add    $0x1,%ebx
 1dd:	0f b6 92 d8 04 00 00 	movzbl 0x4d8(%edx),%edx
 1e4:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 1e8:	89 ca                	mov    %ecx,%edx
 1ea:	89 c1                	mov    %eax,%ecx
 1ec:	39 d6                	cmp    %edx,%esi
 1ee:	76 df                	jbe    1cf <printint+0x2e>
  if(neg)
 1f0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 1f4:	74 31                	je     227 <printint+0x86>
    buf[i++] = '-';
 1f6:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 1fb:	8d 5f 02             	lea    0x2(%edi),%ebx
 1fe:	8b 75 d0             	mov    -0x30(%ebp),%esi
 201:	eb 17                	jmp    21a <printint+0x79>
    x = xx;
 203:	89 c1                	mov    %eax,%ecx
  neg = 0;
 205:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 20c:	eb bc                	jmp    1ca <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 20e:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 213:	89 f0                	mov    %esi,%eax
 215:	e8 6d ff ff ff       	call   187 <putc>
  while(--i >= 0)
 21a:	83 eb 01             	sub    $0x1,%ebx
 21d:	79 ef                	jns    20e <printint+0x6d>
}
 21f:	83 c4 2c             	add    $0x2c,%esp
 222:	5b                   	pop    %ebx
 223:	5e                   	pop    %esi
 224:	5f                   	pop    %edi
 225:	5d                   	pop    %ebp
 226:	c3                   	ret    
 227:	8b 75 d0             	mov    -0x30(%ebp),%esi
 22a:	eb ee                	jmp    21a <printint+0x79>

0000022c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 22c:	55                   	push   %ebp
 22d:	89 e5                	mov    %esp,%ebp
 22f:	57                   	push   %edi
 230:	56                   	push   %esi
 231:	53                   	push   %ebx
 232:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 235:	8d 45 10             	lea    0x10(%ebp),%eax
 238:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 23b:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 240:	bb 00 00 00 00       	mov    $0x0,%ebx
 245:	eb 14                	jmp    25b <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 247:	89 fa                	mov    %edi,%edx
 249:	8b 45 08             	mov    0x8(%ebp),%eax
 24c:	e8 36 ff ff ff       	call   187 <putc>
 251:	eb 05                	jmp    258 <printf+0x2c>
      }
    } else if(state == '%'){
 253:	83 fe 25             	cmp    $0x25,%esi
 256:	74 25                	je     27d <printf+0x51>
  for(i = 0; fmt[i]; i++){
 258:	83 c3 01             	add    $0x1,%ebx
 25b:	8b 45 0c             	mov    0xc(%ebp),%eax
 25e:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 262:	84 c0                	test   %al,%al
 264:	0f 84 20 01 00 00    	je     38a <printf+0x15e>
    c = fmt[i] & 0xff;
 26a:	0f be f8             	movsbl %al,%edi
 26d:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 270:	85 f6                	test   %esi,%esi
 272:	75 df                	jne    253 <printf+0x27>
      if(c == '%'){
 274:	83 f8 25             	cmp    $0x25,%eax
 277:	75 ce                	jne    247 <printf+0x1b>
        state = '%';
 279:	89 c6                	mov    %eax,%esi
 27b:	eb db                	jmp    258 <printf+0x2c>
      if(c == 'd'){
 27d:	83 f8 25             	cmp    $0x25,%eax
 280:	0f 84 cf 00 00 00    	je     355 <printf+0x129>
 286:	0f 8c dd 00 00 00    	jl     369 <printf+0x13d>
 28c:	83 f8 78             	cmp    $0x78,%eax
 28f:	0f 8f d4 00 00 00    	jg     369 <printf+0x13d>
 295:	83 f8 63             	cmp    $0x63,%eax
 298:	0f 8c cb 00 00 00    	jl     369 <printf+0x13d>
 29e:	83 e8 63             	sub    $0x63,%eax
 2a1:	83 f8 15             	cmp    $0x15,%eax
 2a4:	0f 87 bf 00 00 00    	ja     369 <printf+0x13d>
 2aa:	ff 24 85 80 04 00 00 	jmp    *0x480(,%eax,4)
        printint(fd, *ap, 10, 1);
 2b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2b4:	8b 17                	mov    (%edi),%edx
 2b6:	83 ec 0c             	sub    $0xc,%esp
 2b9:	6a 01                	push   $0x1
 2bb:	b9 0a 00 00 00       	mov    $0xa,%ecx
 2c0:	8b 45 08             	mov    0x8(%ebp),%eax
 2c3:	e8 d9 fe ff ff       	call   1a1 <printint>
        ap++;
 2c8:	83 c7 04             	add    $0x4,%edi
 2cb:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2ce:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 2d1:	be 00 00 00 00       	mov    $0x0,%esi
 2d6:	eb 80                	jmp    258 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 2d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2db:	8b 17                	mov    (%edi),%edx
 2dd:	83 ec 0c             	sub    $0xc,%esp
 2e0:	6a 00                	push   $0x0
 2e2:	b9 10 00 00 00       	mov    $0x10,%ecx
 2e7:	8b 45 08             	mov    0x8(%ebp),%eax
 2ea:	e8 b2 fe ff ff       	call   1a1 <printint>
        ap++;
 2ef:	83 c7 04             	add    $0x4,%edi
 2f2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2f5:	83 c4 10             	add    $0x10,%esp
      state = 0;
 2f8:	be 00 00 00 00       	mov    $0x0,%esi
 2fd:	e9 56 ff ff ff       	jmp    258 <printf+0x2c>
        s = (char*)*ap;
 302:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 305:	8b 30                	mov    (%eax),%esi
        ap++;
 307:	83 c0 04             	add    $0x4,%eax
 30a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 30d:	85 f6                	test   %esi,%esi
 30f:	75 15                	jne    326 <printf+0xfa>
          s = "(null)";
 311:	be 77 04 00 00       	mov    $0x477,%esi
 316:	eb 0e                	jmp    326 <printf+0xfa>
          putc(fd, *s);
 318:	0f be d2             	movsbl %dl,%edx
 31b:	8b 45 08             	mov    0x8(%ebp),%eax
 31e:	e8 64 fe ff ff       	call   187 <putc>
          s++;
 323:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 326:	0f b6 16             	movzbl (%esi),%edx
 329:	84 d2                	test   %dl,%dl
 32b:	75 eb                	jne    318 <printf+0xec>
      state = 0;
 32d:	be 00 00 00 00       	mov    $0x0,%esi
 332:	e9 21 ff ff ff       	jmp    258 <printf+0x2c>
        putc(fd, *ap);
 337:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 33a:	0f be 17             	movsbl (%edi),%edx
 33d:	8b 45 08             	mov    0x8(%ebp),%eax
 340:	e8 42 fe ff ff       	call   187 <putc>
        ap++;
 345:	83 c7 04             	add    $0x4,%edi
 348:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 34b:	be 00 00 00 00       	mov    $0x0,%esi
 350:	e9 03 ff ff ff       	jmp    258 <printf+0x2c>
        putc(fd, c);
 355:	89 fa                	mov    %edi,%edx
 357:	8b 45 08             	mov    0x8(%ebp),%eax
 35a:	e8 28 fe ff ff       	call   187 <putc>
      state = 0;
 35f:	be 00 00 00 00       	mov    $0x0,%esi
 364:	e9 ef fe ff ff       	jmp    258 <printf+0x2c>
        putc(fd, '%');
 369:	ba 25 00 00 00       	mov    $0x25,%edx
 36e:	8b 45 08             	mov    0x8(%ebp),%eax
 371:	e8 11 fe ff ff       	call   187 <putc>
        putc(fd, c);
 376:	89 fa                	mov    %edi,%edx
 378:	8b 45 08             	mov    0x8(%ebp),%eax
 37b:	e8 07 fe ff ff       	call   187 <putc>
      state = 0;
 380:	be 00 00 00 00       	mov    $0x0,%esi
 385:	e9 ce fe ff ff       	jmp    258 <printf+0x2c>
    }
  }
}
 38a:	8d 65 f4             	lea    -0xc(%ebp),%esp
 38d:	5b                   	pop    %ebx
 38e:	5e                   	pop    %esi
 38f:	5f                   	pop    %edi
 390:	5d                   	pop    %ebp
 391:	c3                   	ret    
