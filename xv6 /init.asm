
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   f:	83 ec 08             	sub    $0x8,%esp
  12:	6a 02                	push   $0x2
  14:	68 a8 03 00 00       	push   $0x3a8
  19:	e8 07 01 00 00       	call   125 <open>
  1e:	83 c4 10             	add    $0x10,%esp
  21:	85 c0                	test   %eax,%eax
  23:	78 1b                	js     40 <main+0x40>
    mknod("console", 1, 1);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  25:	83 ec 0c             	sub    $0xc,%esp
  28:	6a 00                	push   $0x0
  2a:	e8 2e 01 00 00       	call   15d <dup>
  dup(0);  // stderr
  2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  36:	e8 22 01 00 00       	call   15d <dup>
  3b:	83 c4 10             	add    $0x10,%esp
  3e:	eb 58                	jmp    98 <main+0x98>
    mknod("console", 1, 1);
  40:	83 ec 04             	sub    $0x4,%esp
  43:	6a 01                	push   $0x1
  45:	6a 01                	push   $0x1
  47:	68 a8 03 00 00       	push   $0x3a8
  4c:	e8 dc 00 00 00       	call   12d <mknod>
    open("console", O_RDWR);
  51:	83 c4 08             	add    $0x8,%esp
  54:	6a 02                	push   $0x2
  56:	68 a8 03 00 00       	push   $0x3a8
  5b:	e8 c5 00 00 00       	call   125 <open>
  60:	83 c4 10             	add    $0x10,%esp
  63:	eb c0                	jmp    25 <main+0x25>

  for(;;){
    printf(1, "init: starting sh\n");
    pid = fork();
    if(pid < 0){
      printf(1, "init: fork failed\n");
  65:	83 ec 08             	sub    $0x8,%esp
  68:	68 c3 03 00 00       	push   $0x3c3
  6d:	6a 01                	push   $0x1
  6f:	e8 ce 01 00 00       	call   242 <printf>
      exit();
  74:	e8 6c 00 00 00       	call   e5 <exit>
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
  79:	83 ec 08             	sub    $0x8,%esp
  7c:	68 ef 03 00 00       	push   $0x3ef
  81:	6a 01                	push   $0x1
  83:	e8 ba 01 00 00       	call   242 <printf>
  88:	83 c4 10             	add    $0x10,%esp
    while((wpid=wait()) >= 0 && wpid != pid)
  8b:	e8 5d 00 00 00       	call   ed <wait>
  90:	85 c0                	test   %eax,%eax
  92:	78 04                	js     98 <main+0x98>
  94:	39 c3                	cmp    %eax,%ebx
  96:	75 e1                	jne    79 <main+0x79>
    printf(1, "init: starting sh\n");
  98:	83 ec 08             	sub    $0x8,%esp
  9b:	68 b0 03 00 00       	push   $0x3b0
  a0:	6a 01                	push   $0x1
  a2:	e8 9b 01 00 00       	call   242 <printf>
    pid = fork();
  a7:	e8 31 00 00 00       	call   dd <fork>
  ac:	89 c3                	mov    %eax,%ebx
    if(pid < 0){
  ae:	83 c4 10             	add    $0x10,%esp
  b1:	85 c0                	test   %eax,%eax
  b3:	78 b0                	js     65 <main+0x65>
    if(pid == 0){
  b5:	75 d4                	jne    8b <main+0x8b>
      exec("sh", argv);
  b7:	83 ec 08             	sub    $0x8,%esp
  ba:	68 6c 04 00 00       	push   $0x46c
  bf:	68 d6 03 00 00       	push   $0x3d6
  c4:	e8 54 00 00 00       	call   11d <exec>
      printf(1, "init: exec sh failed\n");
  c9:	83 c4 08             	add    $0x8,%esp
  cc:	68 d9 03 00 00       	push   $0x3d9
  d1:	6a 01                	push   $0x1
  d3:	e8 6a 01 00 00       	call   242 <printf>
      exit();
  d8:	e8 08 00 00 00       	call   e5 <exit>

000000dd <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  dd:	b8 01 00 00 00       	mov    $0x1,%eax
  e2:	cd 40                	int    $0x40
  e4:	c3                   	ret    

000000e5 <exit>:
SYSCALL(exit)
  e5:	b8 02 00 00 00       	mov    $0x2,%eax
  ea:	cd 40                	int    $0x40
  ec:	c3                   	ret    

000000ed <wait>:
SYSCALL(wait)
  ed:	b8 03 00 00 00       	mov    $0x3,%eax
  f2:	cd 40                	int    $0x40
  f4:	c3                   	ret    

000000f5 <pipe>:
SYSCALL(pipe)
  f5:	b8 04 00 00 00       	mov    $0x4,%eax
  fa:	cd 40                	int    $0x40
  fc:	c3                   	ret    

000000fd <read>:
SYSCALL(read)
  fd:	b8 05 00 00 00       	mov    $0x5,%eax
 102:	cd 40                	int    $0x40
 104:	c3                   	ret    

00000105 <write>:
SYSCALL(write)
 105:	b8 10 00 00 00       	mov    $0x10,%eax
 10a:	cd 40                	int    $0x40
 10c:	c3                   	ret    

0000010d <close>:
SYSCALL(close)
 10d:	b8 15 00 00 00       	mov    $0x15,%eax
 112:	cd 40                	int    $0x40
 114:	c3                   	ret    

00000115 <kill>:
SYSCALL(kill)
 115:	b8 06 00 00 00       	mov    $0x6,%eax
 11a:	cd 40                	int    $0x40
 11c:	c3                   	ret    

0000011d <exec>:
SYSCALL(exec)
 11d:	b8 07 00 00 00       	mov    $0x7,%eax
 122:	cd 40                	int    $0x40
 124:	c3                   	ret    

00000125 <open>:
SYSCALL(open)
 125:	b8 0f 00 00 00       	mov    $0xf,%eax
 12a:	cd 40                	int    $0x40
 12c:	c3                   	ret    

0000012d <mknod>:
SYSCALL(mknod)
 12d:	b8 11 00 00 00       	mov    $0x11,%eax
 132:	cd 40                	int    $0x40
 134:	c3                   	ret    

00000135 <unlink>:
SYSCALL(unlink)
 135:	b8 12 00 00 00       	mov    $0x12,%eax
 13a:	cd 40                	int    $0x40
 13c:	c3                   	ret    

0000013d <fstat>:
SYSCALL(fstat)
 13d:	b8 08 00 00 00       	mov    $0x8,%eax
 142:	cd 40                	int    $0x40
 144:	c3                   	ret    

00000145 <link>:
SYSCALL(link)
 145:	b8 13 00 00 00       	mov    $0x13,%eax
 14a:	cd 40                	int    $0x40
 14c:	c3                   	ret    

0000014d <mkdir>:
SYSCALL(mkdir)
 14d:	b8 14 00 00 00       	mov    $0x14,%eax
 152:	cd 40                	int    $0x40
 154:	c3                   	ret    

00000155 <chdir>:
SYSCALL(chdir)
 155:	b8 09 00 00 00       	mov    $0x9,%eax
 15a:	cd 40                	int    $0x40
 15c:	c3                   	ret    

0000015d <dup>:
SYSCALL(dup)
 15d:	b8 0a 00 00 00       	mov    $0xa,%eax
 162:	cd 40                	int    $0x40
 164:	c3                   	ret    

00000165 <getpid>:
SYSCALL(getpid)
 165:	b8 0b 00 00 00       	mov    $0xb,%eax
 16a:	cd 40                	int    $0x40
 16c:	c3                   	ret    

0000016d <sbrk>:
SYSCALL(sbrk)
 16d:	b8 0c 00 00 00       	mov    $0xc,%eax
 172:	cd 40                	int    $0x40
 174:	c3                   	ret    

00000175 <sleep>:
SYSCALL(sleep)
 175:	b8 0d 00 00 00       	mov    $0xd,%eax
 17a:	cd 40                	int    $0x40
 17c:	c3                   	ret    

0000017d <uptime>:
SYSCALL(uptime)
 17d:	b8 0e 00 00 00       	mov    $0xe,%eax
 182:	cd 40                	int    $0x40
 184:	c3                   	ret    

00000185 <yield>:
SYSCALL(yield)
 185:	b8 16 00 00 00       	mov    $0x16,%eax
 18a:	cd 40                	int    $0x40
 18c:	c3                   	ret    

0000018d <shutdown>:
SYSCALL(shutdown)
 18d:	b8 17 00 00 00       	mov    $0x17,%eax
 192:	cd 40                	int    $0x40
 194:	c3                   	ret    

00000195 <writecount>:
SYSCALL(writecount)
 195:	b8 18 00 00 00       	mov    $0x18,%eax
 19a:	cd 40                	int    $0x40
 19c:	c3                   	ret    

0000019d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 19d:	55                   	push   %ebp
 19e:	89 e5                	mov    %esp,%ebp
 1a0:	83 ec 1c             	sub    $0x1c,%esp
 1a3:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 1a6:	6a 01                	push   $0x1
 1a8:	8d 55 f4             	lea    -0xc(%ebp),%edx
 1ab:	52                   	push   %edx
 1ac:	50                   	push   %eax
 1ad:	e8 53 ff ff ff       	call   105 <write>
}
 1b2:	83 c4 10             	add    $0x10,%esp
 1b5:	c9                   	leave  
 1b6:	c3                   	ret    

000001b7 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 1b7:	55                   	push   %ebp
 1b8:	89 e5                	mov    %esp,%ebp
 1ba:	57                   	push   %edi
 1bb:	56                   	push   %esi
 1bc:	53                   	push   %ebx
 1bd:	83 ec 2c             	sub    $0x2c,%esp
 1c0:	89 45 d0             	mov    %eax,-0x30(%ebp)
 1c3:	89 d0                	mov    %edx,%eax
 1c5:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 1c7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 1cb:	0f 95 c1             	setne  %cl
 1ce:	c1 ea 1f             	shr    $0x1f,%edx
 1d1:	84 d1                	test   %dl,%cl
 1d3:	74 44                	je     219 <printint+0x62>
    neg = 1;
    x = -xx;
 1d5:	f7 d8                	neg    %eax
 1d7:	89 c1                	mov    %eax,%ecx
    neg = 1;
 1d9:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 1e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 1e5:	89 c8                	mov    %ecx,%eax
 1e7:	ba 00 00 00 00       	mov    $0x0,%edx
 1ec:	f7 f6                	div    %esi
 1ee:	89 df                	mov    %ebx,%edi
 1f0:	83 c3 01             	add    $0x1,%ebx
 1f3:	0f b6 92 58 04 00 00 	movzbl 0x458(%edx),%edx
 1fa:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 1fe:	89 ca                	mov    %ecx,%edx
 200:	89 c1                	mov    %eax,%ecx
 202:	39 d6                	cmp    %edx,%esi
 204:	76 df                	jbe    1e5 <printint+0x2e>
  if(neg)
 206:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 20a:	74 31                	je     23d <printint+0x86>
    buf[i++] = '-';
 20c:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 211:	8d 5f 02             	lea    0x2(%edi),%ebx
 214:	8b 75 d0             	mov    -0x30(%ebp),%esi
 217:	eb 17                	jmp    230 <printint+0x79>
    x = xx;
 219:	89 c1                	mov    %eax,%ecx
  neg = 0;
 21b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 222:	eb bc                	jmp    1e0 <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 224:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 229:	89 f0                	mov    %esi,%eax
 22b:	e8 6d ff ff ff       	call   19d <putc>
  while(--i >= 0)
 230:	83 eb 01             	sub    $0x1,%ebx
 233:	79 ef                	jns    224 <printint+0x6d>
}
 235:	83 c4 2c             	add    $0x2c,%esp
 238:	5b                   	pop    %ebx
 239:	5e                   	pop    %esi
 23a:	5f                   	pop    %edi
 23b:	5d                   	pop    %ebp
 23c:	c3                   	ret    
 23d:	8b 75 d0             	mov    -0x30(%ebp),%esi
 240:	eb ee                	jmp    230 <printint+0x79>

00000242 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 242:	55                   	push   %ebp
 243:	89 e5                	mov    %esp,%ebp
 245:	57                   	push   %edi
 246:	56                   	push   %esi
 247:	53                   	push   %ebx
 248:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 24b:	8d 45 10             	lea    0x10(%ebp),%eax
 24e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 251:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 256:	bb 00 00 00 00       	mov    $0x0,%ebx
 25b:	eb 14                	jmp    271 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 25d:	89 fa                	mov    %edi,%edx
 25f:	8b 45 08             	mov    0x8(%ebp),%eax
 262:	e8 36 ff ff ff       	call   19d <putc>
 267:	eb 05                	jmp    26e <printf+0x2c>
      }
    } else if(state == '%'){
 269:	83 fe 25             	cmp    $0x25,%esi
 26c:	74 25                	je     293 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 26e:	83 c3 01             	add    $0x1,%ebx
 271:	8b 45 0c             	mov    0xc(%ebp),%eax
 274:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 278:	84 c0                	test   %al,%al
 27a:	0f 84 20 01 00 00    	je     3a0 <printf+0x15e>
    c = fmt[i] & 0xff;
 280:	0f be f8             	movsbl %al,%edi
 283:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 286:	85 f6                	test   %esi,%esi
 288:	75 df                	jne    269 <printf+0x27>
      if(c == '%'){
 28a:	83 f8 25             	cmp    $0x25,%eax
 28d:	75 ce                	jne    25d <printf+0x1b>
        state = '%';
 28f:	89 c6                	mov    %eax,%esi
 291:	eb db                	jmp    26e <printf+0x2c>
      if(c == 'd'){
 293:	83 f8 25             	cmp    $0x25,%eax
 296:	0f 84 cf 00 00 00    	je     36b <printf+0x129>
 29c:	0f 8c dd 00 00 00    	jl     37f <printf+0x13d>
 2a2:	83 f8 78             	cmp    $0x78,%eax
 2a5:	0f 8f d4 00 00 00    	jg     37f <printf+0x13d>
 2ab:	83 f8 63             	cmp    $0x63,%eax
 2ae:	0f 8c cb 00 00 00    	jl     37f <printf+0x13d>
 2b4:	83 e8 63             	sub    $0x63,%eax
 2b7:	83 f8 15             	cmp    $0x15,%eax
 2ba:	0f 87 bf 00 00 00    	ja     37f <printf+0x13d>
 2c0:	ff 24 85 00 04 00 00 	jmp    *0x400(,%eax,4)
        printint(fd, *ap, 10, 1);
 2c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2ca:	8b 17                	mov    (%edi),%edx
 2cc:	83 ec 0c             	sub    $0xc,%esp
 2cf:	6a 01                	push   $0x1
 2d1:	b9 0a 00 00 00       	mov    $0xa,%ecx
 2d6:	8b 45 08             	mov    0x8(%ebp),%eax
 2d9:	e8 d9 fe ff ff       	call   1b7 <printint>
        ap++;
 2de:	83 c7 04             	add    $0x4,%edi
 2e1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2e4:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 2e7:	be 00 00 00 00       	mov    $0x0,%esi
 2ec:	eb 80                	jmp    26e <printf+0x2c>
        printint(fd, *ap, 16, 0);
 2ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2f1:	8b 17                	mov    (%edi),%edx
 2f3:	83 ec 0c             	sub    $0xc,%esp
 2f6:	6a 00                	push   $0x0
 2f8:	b9 10 00 00 00       	mov    $0x10,%ecx
 2fd:	8b 45 08             	mov    0x8(%ebp),%eax
 300:	e8 b2 fe ff ff       	call   1b7 <printint>
        ap++;
 305:	83 c7 04             	add    $0x4,%edi
 308:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 30b:	83 c4 10             	add    $0x10,%esp
      state = 0;
 30e:	be 00 00 00 00       	mov    $0x0,%esi
 313:	e9 56 ff ff ff       	jmp    26e <printf+0x2c>
        s = (char*)*ap;
 318:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 31b:	8b 30                	mov    (%eax),%esi
        ap++;
 31d:	83 c0 04             	add    $0x4,%eax
 320:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 323:	85 f6                	test   %esi,%esi
 325:	75 15                	jne    33c <printf+0xfa>
          s = "(null)";
 327:	be f8 03 00 00       	mov    $0x3f8,%esi
 32c:	eb 0e                	jmp    33c <printf+0xfa>
          putc(fd, *s);
 32e:	0f be d2             	movsbl %dl,%edx
 331:	8b 45 08             	mov    0x8(%ebp),%eax
 334:	e8 64 fe ff ff       	call   19d <putc>
          s++;
 339:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 33c:	0f b6 16             	movzbl (%esi),%edx
 33f:	84 d2                	test   %dl,%dl
 341:	75 eb                	jne    32e <printf+0xec>
      state = 0;
 343:	be 00 00 00 00       	mov    $0x0,%esi
 348:	e9 21 ff ff ff       	jmp    26e <printf+0x2c>
        putc(fd, *ap);
 34d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 350:	0f be 17             	movsbl (%edi),%edx
 353:	8b 45 08             	mov    0x8(%ebp),%eax
 356:	e8 42 fe ff ff       	call   19d <putc>
        ap++;
 35b:	83 c7 04             	add    $0x4,%edi
 35e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 361:	be 00 00 00 00       	mov    $0x0,%esi
 366:	e9 03 ff ff ff       	jmp    26e <printf+0x2c>
        putc(fd, c);
 36b:	89 fa                	mov    %edi,%edx
 36d:	8b 45 08             	mov    0x8(%ebp),%eax
 370:	e8 28 fe ff ff       	call   19d <putc>
      state = 0;
 375:	be 00 00 00 00       	mov    $0x0,%esi
 37a:	e9 ef fe ff ff       	jmp    26e <printf+0x2c>
        putc(fd, '%');
 37f:	ba 25 00 00 00       	mov    $0x25,%edx
 384:	8b 45 08             	mov    0x8(%ebp),%eax
 387:	e8 11 fe ff ff       	call   19d <putc>
        putc(fd, c);
 38c:	89 fa                	mov    %edi,%edx
 38e:	8b 45 08             	mov    0x8(%ebp),%eax
 391:	e8 07 fe ff ff       	call   19d <putc>
      state = 0;
 396:	be 00 00 00 00       	mov    $0x0,%esi
 39b:	e9 ce fe ff ff       	jmp    26e <printf+0x2c>
    }
  }
}
 3a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
 3a3:	5b                   	pop    %ebx
 3a4:	5e                   	pop    %esi
 3a5:	5f                   	pop    %edi
 3a6:	5d                   	pop    %ebp
 3a7:	c3                   	ret    
