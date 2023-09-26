
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
  26:	e8 45 01 00 00       	call   170 <getprocessesinfo>
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
  40:	68 fa 03 00 00       	push   $0x3fa
  45:	6a 01                	push   $0x1
  47:	e8 d1 01 00 00       	call   21d <printf>
    printf(1, "PID\tTICKETS\tTIMES-SCHEDULED\n");
  4c:	83 c4 08             	add    $0x8,%esp
  4f:	68 10 04 00 00       	push   $0x410
  54:	6a 01                	push   $0x1
  56:	e8 c2 01 00 00       	call   21d <printf>
    for (int i = 0; i < info.num_processes; ++i) {
  5b:	83 c4 10             	add    $0x10,%esp
  5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  63:	eb 3e                	jmp    a3 <main+0xa3>
        printf(1, "ERROR: negative number of processes!\n"
  65:	83 ec 08             	sub    $0x8,%esp
  68:	68 84 03 00 00       	push   $0x384
  6d:	6a 01                	push   $0x1
  6f:	e8 a9 01 00 00       	call   21d <printf>
  74:	83 c4 10             	add    $0x10,%esp
  77:	eb be                	jmp    37 <main+0x37>
        printf(1, "%d\t%d\t%d\n", info.pids[i], info.tickets[i], info.times_scheduled[i]);
  79:	83 ec 0c             	sub    $0xc,%esp
  7c:	ff b4 9d f8 fd ff ff 	push   -0x208(%ebp,%ebx,4)
  83:	ff b4 9d f8 fe ff ff 	push   -0x108(%ebp,%ebx,4)
  8a:	ff b4 9d f8 fc ff ff 	push   -0x308(%ebp,%ebx,4)
  91:	68 2d 04 00 00       	push   $0x42d
  96:	6a 01                	push   $0x1
  98:	e8 80 01 00 00       	call   21d <printf>
    for (int i = 0; i < info.num_processes; ++i) {
  9d:	83 c3 01             	add    $0x1,%ebx
  a0:	83 c4 20             	add    $0x20,%esp
  a3:	39 9d f4 fc ff ff    	cmp    %ebx,-0x30c(%ebp)
  a9:	7f ce                	jg     79 <main+0x79>
    }
    exit();
  ab:	e8 08 00 00 00       	call   b8 <exit>

000000b0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  b0:	b8 01 00 00 00       	mov    $0x1,%eax
  b5:	cd 40                	int    $0x40
  b7:	c3                   	ret    

000000b8 <exit>:
SYSCALL(exit)
  b8:	b8 02 00 00 00       	mov    $0x2,%eax
  bd:	cd 40                	int    $0x40
  bf:	c3                   	ret    

000000c0 <wait>:
SYSCALL(wait)
  c0:	b8 03 00 00 00       	mov    $0x3,%eax
  c5:	cd 40                	int    $0x40
  c7:	c3                   	ret    

000000c8 <pipe>:
SYSCALL(pipe)
  c8:	b8 04 00 00 00       	mov    $0x4,%eax
  cd:	cd 40                	int    $0x40
  cf:	c3                   	ret    

000000d0 <read>:
SYSCALL(read)
  d0:	b8 05 00 00 00       	mov    $0x5,%eax
  d5:	cd 40                	int    $0x40
  d7:	c3                   	ret    

000000d8 <write>:
SYSCALL(write)
  d8:	b8 10 00 00 00       	mov    $0x10,%eax
  dd:	cd 40                	int    $0x40
  df:	c3                   	ret    

000000e0 <close>:
SYSCALL(close)
  e0:	b8 15 00 00 00       	mov    $0x15,%eax
  e5:	cd 40                	int    $0x40
  e7:	c3                   	ret    

000000e8 <kill>:
SYSCALL(kill)
  e8:	b8 06 00 00 00       	mov    $0x6,%eax
  ed:	cd 40                	int    $0x40
  ef:	c3                   	ret    

000000f0 <exec>:
SYSCALL(exec)
  f0:	b8 07 00 00 00       	mov    $0x7,%eax
  f5:	cd 40                	int    $0x40
  f7:	c3                   	ret    

000000f8 <open>:
SYSCALL(open)
  f8:	b8 0f 00 00 00       	mov    $0xf,%eax
  fd:	cd 40                	int    $0x40
  ff:	c3                   	ret    

00000100 <mknod>:
SYSCALL(mknod)
 100:	b8 11 00 00 00       	mov    $0x11,%eax
 105:	cd 40                	int    $0x40
 107:	c3                   	ret    

00000108 <unlink>:
SYSCALL(unlink)
 108:	b8 12 00 00 00       	mov    $0x12,%eax
 10d:	cd 40                	int    $0x40
 10f:	c3                   	ret    

00000110 <fstat>:
SYSCALL(fstat)
 110:	b8 08 00 00 00       	mov    $0x8,%eax
 115:	cd 40                	int    $0x40
 117:	c3                   	ret    

00000118 <link>:
SYSCALL(link)
 118:	b8 13 00 00 00       	mov    $0x13,%eax
 11d:	cd 40                	int    $0x40
 11f:	c3                   	ret    

00000120 <mkdir>:
SYSCALL(mkdir)
 120:	b8 14 00 00 00       	mov    $0x14,%eax
 125:	cd 40                	int    $0x40
 127:	c3                   	ret    

00000128 <chdir>:
SYSCALL(chdir)
 128:	b8 09 00 00 00       	mov    $0x9,%eax
 12d:	cd 40                	int    $0x40
 12f:	c3                   	ret    

00000130 <dup>:
SYSCALL(dup)
 130:	b8 0a 00 00 00       	mov    $0xa,%eax
 135:	cd 40                	int    $0x40
 137:	c3                   	ret    

00000138 <getpid>:
SYSCALL(getpid)
 138:	b8 0b 00 00 00       	mov    $0xb,%eax
 13d:	cd 40                	int    $0x40
 13f:	c3                   	ret    

00000140 <sbrk>:
SYSCALL(sbrk)
 140:	b8 0c 00 00 00       	mov    $0xc,%eax
 145:	cd 40                	int    $0x40
 147:	c3                   	ret    

00000148 <sleep>:
SYSCALL(sleep)
 148:	b8 0d 00 00 00       	mov    $0xd,%eax
 14d:	cd 40                	int    $0x40
 14f:	c3                   	ret    

00000150 <uptime>:
SYSCALL(uptime)
 150:	b8 0e 00 00 00       	mov    $0xe,%eax
 155:	cd 40                	int    $0x40
 157:	c3                   	ret    

00000158 <yield>:
SYSCALL(yield)
 158:	b8 16 00 00 00       	mov    $0x16,%eax
 15d:	cd 40                	int    $0x40
 15f:	c3                   	ret    

00000160 <shutdown>:
SYSCALL(shutdown)
 160:	b8 17 00 00 00       	mov    $0x17,%eax
 165:	cd 40                	int    $0x40
 167:	c3                   	ret    

00000168 <settickets>:
SYSCALL(settickets)
 168:	b8 18 00 00 00       	mov    $0x18,%eax
 16d:	cd 40                	int    $0x40
 16f:	c3                   	ret    

00000170 <getprocessesinfo>:
SYSCALL(getprocessesinfo)
 170:	b8 19 00 00 00       	mov    $0x19,%eax
 175:	cd 40                	int    $0x40
 177:	c3                   	ret    

00000178 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 178:	55                   	push   %ebp
 179:	89 e5                	mov    %esp,%ebp
 17b:	83 ec 1c             	sub    $0x1c,%esp
 17e:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 181:	6a 01                	push   $0x1
 183:	8d 55 f4             	lea    -0xc(%ebp),%edx
 186:	52                   	push   %edx
 187:	50                   	push   %eax
 188:	e8 4b ff ff ff       	call   d8 <write>
}
 18d:	83 c4 10             	add    $0x10,%esp
 190:	c9                   	leave  
 191:	c3                   	ret    

00000192 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 192:	55                   	push   %ebp
 193:	89 e5                	mov    %esp,%ebp
 195:	57                   	push   %edi
 196:	56                   	push   %esi
 197:	53                   	push   %ebx
 198:	83 ec 2c             	sub    $0x2c,%esp
 19b:	89 45 d0             	mov    %eax,-0x30(%ebp)
 19e:	89 d0                	mov    %edx,%eax
 1a0:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 1a2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 1a6:	0f 95 c1             	setne  %cl
 1a9:	c1 ea 1f             	shr    $0x1f,%edx
 1ac:	84 d1                	test   %dl,%cl
 1ae:	74 44                	je     1f4 <printint+0x62>
    neg = 1;
    x = -xx;
 1b0:	f7 d8                	neg    %eax
 1b2:	89 c1                	mov    %eax,%ecx
    neg = 1;
 1b4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 1bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 1c0:	89 c8                	mov    %ecx,%eax
 1c2:	ba 00 00 00 00       	mov    $0x0,%edx
 1c7:	f7 f6                	div    %esi
 1c9:	89 df                	mov    %ebx,%edi
 1cb:	83 c3 01             	add    $0x1,%ebx
 1ce:	0f b6 92 98 04 00 00 	movzbl 0x498(%edx),%edx
 1d5:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 1d9:	89 ca                	mov    %ecx,%edx
 1db:	89 c1                	mov    %eax,%ecx
 1dd:	39 d6                	cmp    %edx,%esi
 1df:	76 df                	jbe    1c0 <printint+0x2e>
  if(neg)
 1e1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 1e5:	74 31                	je     218 <printint+0x86>
    buf[i++] = '-';
 1e7:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 1ec:	8d 5f 02             	lea    0x2(%edi),%ebx
 1ef:	8b 75 d0             	mov    -0x30(%ebp),%esi
 1f2:	eb 17                	jmp    20b <printint+0x79>
    x = xx;
 1f4:	89 c1                	mov    %eax,%ecx
  neg = 0;
 1f6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 1fd:	eb bc                	jmp    1bb <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 1ff:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 204:	89 f0                	mov    %esi,%eax
 206:	e8 6d ff ff ff       	call   178 <putc>
  while(--i >= 0)
 20b:	83 eb 01             	sub    $0x1,%ebx
 20e:	79 ef                	jns    1ff <printint+0x6d>
}
 210:	83 c4 2c             	add    $0x2c,%esp
 213:	5b                   	pop    %ebx
 214:	5e                   	pop    %esi
 215:	5f                   	pop    %edi
 216:	5d                   	pop    %ebp
 217:	c3                   	ret    
 218:	8b 75 d0             	mov    -0x30(%ebp),%esi
 21b:	eb ee                	jmp    20b <printint+0x79>

0000021d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 21d:	55                   	push   %ebp
 21e:	89 e5                	mov    %esp,%ebp
 220:	57                   	push   %edi
 221:	56                   	push   %esi
 222:	53                   	push   %ebx
 223:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 226:	8d 45 10             	lea    0x10(%ebp),%eax
 229:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 22c:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 231:	bb 00 00 00 00       	mov    $0x0,%ebx
 236:	eb 14                	jmp    24c <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 238:	89 fa                	mov    %edi,%edx
 23a:	8b 45 08             	mov    0x8(%ebp),%eax
 23d:	e8 36 ff ff ff       	call   178 <putc>
 242:	eb 05                	jmp    249 <printf+0x2c>
      }
    } else if(state == '%'){
 244:	83 fe 25             	cmp    $0x25,%esi
 247:	74 25                	je     26e <printf+0x51>
  for(i = 0; fmt[i]; i++){
 249:	83 c3 01             	add    $0x1,%ebx
 24c:	8b 45 0c             	mov    0xc(%ebp),%eax
 24f:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 253:	84 c0                	test   %al,%al
 255:	0f 84 20 01 00 00    	je     37b <printf+0x15e>
    c = fmt[i] & 0xff;
 25b:	0f be f8             	movsbl %al,%edi
 25e:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 261:	85 f6                	test   %esi,%esi
 263:	75 df                	jne    244 <printf+0x27>
      if(c == '%'){
 265:	83 f8 25             	cmp    $0x25,%eax
 268:	75 ce                	jne    238 <printf+0x1b>
        state = '%';
 26a:	89 c6                	mov    %eax,%esi
 26c:	eb db                	jmp    249 <printf+0x2c>
      if(c == 'd'){
 26e:	83 f8 25             	cmp    $0x25,%eax
 271:	0f 84 cf 00 00 00    	je     346 <printf+0x129>
 277:	0f 8c dd 00 00 00    	jl     35a <printf+0x13d>
 27d:	83 f8 78             	cmp    $0x78,%eax
 280:	0f 8f d4 00 00 00    	jg     35a <printf+0x13d>
 286:	83 f8 63             	cmp    $0x63,%eax
 289:	0f 8c cb 00 00 00    	jl     35a <printf+0x13d>
 28f:	83 e8 63             	sub    $0x63,%eax
 292:	83 f8 15             	cmp    $0x15,%eax
 295:	0f 87 bf 00 00 00    	ja     35a <printf+0x13d>
 29b:	ff 24 85 40 04 00 00 	jmp    *0x440(,%eax,4)
        printint(fd, *ap, 10, 1);
 2a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2a5:	8b 17                	mov    (%edi),%edx
 2a7:	83 ec 0c             	sub    $0xc,%esp
 2aa:	6a 01                	push   $0x1
 2ac:	b9 0a 00 00 00       	mov    $0xa,%ecx
 2b1:	8b 45 08             	mov    0x8(%ebp),%eax
 2b4:	e8 d9 fe ff ff       	call   192 <printint>
        ap++;
 2b9:	83 c7 04             	add    $0x4,%edi
 2bc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2bf:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 2c2:	be 00 00 00 00       	mov    $0x0,%esi
 2c7:	eb 80                	jmp    249 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 2c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2cc:	8b 17                	mov    (%edi),%edx
 2ce:	83 ec 0c             	sub    $0xc,%esp
 2d1:	6a 00                	push   $0x0
 2d3:	b9 10 00 00 00       	mov    $0x10,%ecx
 2d8:	8b 45 08             	mov    0x8(%ebp),%eax
 2db:	e8 b2 fe ff ff       	call   192 <printint>
        ap++;
 2e0:	83 c7 04             	add    $0x4,%edi
 2e3:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2e6:	83 c4 10             	add    $0x10,%esp
      state = 0;
 2e9:	be 00 00 00 00       	mov    $0x0,%esi
 2ee:	e9 56 ff ff ff       	jmp    249 <printf+0x2c>
        s = (char*)*ap;
 2f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2f6:	8b 30                	mov    (%eax),%esi
        ap++;
 2f8:	83 c0 04             	add    $0x4,%eax
 2fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 2fe:	85 f6                	test   %esi,%esi
 300:	75 15                	jne    317 <printf+0xfa>
          s = "(null)";
 302:	be 37 04 00 00       	mov    $0x437,%esi
 307:	eb 0e                	jmp    317 <printf+0xfa>
          putc(fd, *s);
 309:	0f be d2             	movsbl %dl,%edx
 30c:	8b 45 08             	mov    0x8(%ebp),%eax
 30f:	e8 64 fe ff ff       	call   178 <putc>
          s++;
 314:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 317:	0f b6 16             	movzbl (%esi),%edx
 31a:	84 d2                	test   %dl,%dl
 31c:	75 eb                	jne    309 <printf+0xec>
      state = 0;
 31e:	be 00 00 00 00       	mov    $0x0,%esi
 323:	e9 21 ff ff ff       	jmp    249 <printf+0x2c>
        putc(fd, *ap);
 328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 32b:	0f be 17             	movsbl (%edi),%edx
 32e:	8b 45 08             	mov    0x8(%ebp),%eax
 331:	e8 42 fe ff ff       	call   178 <putc>
        ap++;
 336:	83 c7 04             	add    $0x4,%edi
 339:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 33c:	be 00 00 00 00       	mov    $0x0,%esi
 341:	e9 03 ff ff ff       	jmp    249 <printf+0x2c>
        putc(fd, c);
 346:	89 fa                	mov    %edi,%edx
 348:	8b 45 08             	mov    0x8(%ebp),%eax
 34b:	e8 28 fe ff ff       	call   178 <putc>
      state = 0;
 350:	be 00 00 00 00       	mov    $0x0,%esi
 355:	e9 ef fe ff ff       	jmp    249 <printf+0x2c>
        putc(fd, '%');
 35a:	ba 25 00 00 00       	mov    $0x25,%edx
 35f:	8b 45 08             	mov    0x8(%ebp),%eax
 362:	e8 11 fe ff ff       	call   178 <putc>
        putc(fd, c);
 367:	89 fa                	mov    %edi,%edx
 369:	8b 45 08             	mov    0x8(%ebp),%eax
 36c:	e8 07 fe ff ff       	call   178 <putc>
      state = 0;
 371:	be 00 00 00 00       	mov    $0x0,%esi
 376:	e9 ce fe ff ff       	jmp    249 <printf+0x2c>
    }
  }
}
 37b:	8d 65 f4             	lea    -0xc(%ebp),%esp
 37e:	5b                   	pop    %ebx
 37f:	5e                   	pop    %esi
 380:	5f                   	pop    %edi
 381:	5d                   	pop    %ebp
 382:	c3                   	ret    
