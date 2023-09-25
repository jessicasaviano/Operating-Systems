
_cat:     file format elf32-i386


Disassembly of section .text:

00000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	56                   	push   %esi
   4:	53                   	push   %ebx
   5:	8b 75 08             	mov    0x8(%ebp),%esi
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
   8:	83 ec 04             	sub    $0x4,%esp
   b:	68 00 02 00 00       	push   $0x200
  10:	68 80 04 00 00       	push   $0x480
  15:	56                   	push   %esi
  16:	e8 fd 00 00 00       	call   118 <read>
  1b:	89 c3                	mov    %eax,%ebx
  1d:	83 c4 10             	add    $0x10,%esp
  20:	85 c0                	test   %eax,%eax
  22:	7e 2b                	jle    4f <cat+0x4f>
    if (write(1, buf, n) != n) {
  24:	83 ec 04             	sub    $0x4,%esp
  27:	53                   	push   %ebx
  28:	68 80 04 00 00       	push   $0x480
  2d:	6a 01                	push   $0x1
  2f:	e8 ec 00 00 00       	call   120 <write>
  34:	83 c4 10             	add    $0x10,%esp
  37:	39 d8                	cmp    %ebx,%eax
  39:	74 cd                	je     8 <cat+0x8>
      printf(1, "cat: write error\n");
  3b:	83 ec 08             	sub    $0x8,%esp
  3e:	68 c4 03 00 00       	push   $0x3c4
  43:	6a 01                	push   $0x1
  45:	e8 13 02 00 00       	call   25d <printf>
      exit();
  4a:	e8 b1 00 00 00       	call   100 <exit>
    }
  }
  if(n < 0){
  4f:	78 07                	js     58 <cat+0x58>
    printf(1, "cat: read error\n");
    exit();
  }
}
  51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  54:	5b                   	pop    %ebx
  55:	5e                   	pop    %esi
  56:	5d                   	pop    %ebp
  57:	c3                   	ret    
    printf(1, "cat: read error\n");
  58:	83 ec 08             	sub    $0x8,%esp
  5b:	68 d6 03 00 00       	push   $0x3d6
  60:	6a 01                	push   $0x1
  62:	e8 f6 01 00 00       	call   25d <printf>
    exit();
  67:	e8 94 00 00 00       	call   100 <exit>

0000006c <main>:

int
main(int argc, char *argv[])
{
  6c:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  70:	83 e4 f0             	and    $0xfffffff0,%esp
  73:	ff 71 fc             	push   -0x4(%ecx)
  76:	55                   	push   %ebp
  77:	89 e5                	mov    %esp,%ebp
  79:	57                   	push   %edi
  7a:	56                   	push   %esi
  7b:	53                   	push   %ebx
  7c:	51                   	push   %ecx
  7d:	83 ec 18             	sub    $0x18,%esp
  80:	8b 01                	mov    (%ecx),%eax
  82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  85:	8b 51 04             	mov    0x4(%ecx),%edx
  88:	89 55 e0             	mov    %edx,-0x20(%ebp)
  int fd, i;

  if(argc <= 1){
  8b:	83 f8 01             	cmp    $0x1,%eax
  8e:	7e 07                	jle    97 <main+0x2b>
    cat(0);
    exit();
  }

  for(i = 1; i < argc; i++){
  90:	be 01 00 00 00       	mov    $0x1,%esi
  95:	eb 26                	jmp    bd <main+0x51>
    cat(0);
  97:	83 ec 0c             	sub    $0xc,%esp
  9a:	6a 00                	push   $0x0
  9c:	e8 5f ff ff ff       	call   0 <cat>
    exit();
  a1:	e8 5a 00 00 00       	call   100 <exit>
    if((fd = open(argv[i], 0)) < 0){
      printf(1, "cat: cannot open %s\n", argv[i]);
      exit();
    }
    cat(fd);
  a6:	83 ec 0c             	sub    $0xc,%esp
  a9:	50                   	push   %eax
  aa:	e8 51 ff ff ff       	call   0 <cat>
    close(fd);
  af:	89 1c 24             	mov    %ebx,(%esp)
  b2:	e8 71 00 00 00       	call   128 <close>
  for(i = 1; i < argc; i++){
  b7:	83 c6 01             	add    $0x1,%esi
  ba:	83 c4 10             	add    $0x10,%esp
  bd:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
  c0:	7d 31                	jge    f3 <main+0x87>
    if((fd = open(argv[i], 0)) < 0){
  c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  c5:	8d 3c b0             	lea    (%eax,%esi,4),%edi
  c8:	83 ec 08             	sub    $0x8,%esp
  cb:	6a 00                	push   $0x0
  cd:	ff 37                	push   (%edi)
  cf:	e8 6c 00 00 00       	call   140 <open>
  d4:	89 c3                	mov    %eax,%ebx
  d6:	83 c4 10             	add    $0x10,%esp
  d9:	85 c0                	test   %eax,%eax
  db:	79 c9                	jns    a6 <main+0x3a>
      printf(1, "cat: cannot open %s\n", argv[i]);
  dd:	83 ec 04             	sub    $0x4,%esp
  e0:	ff 37                	push   (%edi)
  e2:	68 e7 03 00 00       	push   $0x3e7
  e7:	6a 01                	push   $0x1
  e9:	e8 6f 01 00 00       	call   25d <printf>
      exit();
  ee:	e8 0d 00 00 00       	call   100 <exit>
  }
  exit();
  f3:	e8 08 00 00 00       	call   100 <exit>

000000f8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  f8:	b8 01 00 00 00       	mov    $0x1,%eax
  fd:	cd 40                	int    $0x40
  ff:	c3                   	ret    

00000100 <exit>:
SYSCALL(exit)
 100:	b8 02 00 00 00       	mov    $0x2,%eax
 105:	cd 40                	int    $0x40
 107:	c3                   	ret    

00000108 <wait>:
SYSCALL(wait)
 108:	b8 03 00 00 00       	mov    $0x3,%eax
 10d:	cd 40                	int    $0x40
 10f:	c3                   	ret    

00000110 <pipe>:
SYSCALL(pipe)
 110:	b8 04 00 00 00       	mov    $0x4,%eax
 115:	cd 40                	int    $0x40
 117:	c3                   	ret    

00000118 <read>:
SYSCALL(read)
 118:	b8 05 00 00 00       	mov    $0x5,%eax
 11d:	cd 40                	int    $0x40
 11f:	c3                   	ret    

00000120 <write>:
SYSCALL(write)
 120:	b8 10 00 00 00       	mov    $0x10,%eax
 125:	cd 40                	int    $0x40
 127:	c3                   	ret    

00000128 <close>:
SYSCALL(close)
 128:	b8 15 00 00 00       	mov    $0x15,%eax
 12d:	cd 40                	int    $0x40
 12f:	c3                   	ret    

00000130 <kill>:
SYSCALL(kill)
 130:	b8 06 00 00 00       	mov    $0x6,%eax
 135:	cd 40                	int    $0x40
 137:	c3                   	ret    

00000138 <exec>:
SYSCALL(exec)
 138:	b8 07 00 00 00       	mov    $0x7,%eax
 13d:	cd 40                	int    $0x40
 13f:	c3                   	ret    

00000140 <open>:
SYSCALL(open)
 140:	b8 0f 00 00 00       	mov    $0xf,%eax
 145:	cd 40                	int    $0x40
 147:	c3                   	ret    

00000148 <mknod>:
SYSCALL(mknod)
 148:	b8 11 00 00 00       	mov    $0x11,%eax
 14d:	cd 40                	int    $0x40
 14f:	c3                   	ret    

00000150 <unlink>:
SYSCALL(unlink)
 150:	b8 12 00 00 00       	mov    $0x12,%eax
 155:	cd 40                	int    $0x40
 157:	c3                   	ret    

00000158 <fstat>:
SYSCALL(fstat)
 158:	b8 08 00 00 00       	mov    $0x8,%eax
 15d:	cd 40                	int    $0x40
 15f:	c3                   	ret    

00000160 <link>:
SYSCALL(link)
 160:	b8 13 00 00 00       	mov    $0x13,%eax
 165:	cd 40                	int    $0x40
 167:	c3                   	ret    

00000168 <mkdir>:
SYSCALL(mkdir)
 168:	b8 14 00 00 00       	mov    $0x14,%eax
 16d:	cd 40                	int    $0x40
 16f:	c3                   	ret    

00000170 <chdir>:
SYSCALL(chdir)
 170:	b8 09 00 00 00       	mov    $0x9,%eax
 175:	cd 40                	int    $0x40
 177:	c3                   	ret    

00000178 <dup>:
SYSCALL(dup)
 178:	b8 0a 00 00 00       	mov    $0xa,%eax
 17d:	cd 40                	int    $0x40
 17f:	c3                   	ret    

00000180 <getpid>:
SYSCALL(getpid)
 180:	b8 0b 00 00 00       	mov    $0xb,%eax
 185:	cd 40                	int    $0x40
 187:	c3                   	ret    

00000188 <sbrk>:
SYSCALL(sbrk)
 188:	b8 0c 00 00 00       	mov    $0xc,%eax
 18d:	cd 40                	int    $0x40
 18f:	c3                   	ret    

00000190 <sleep>:
SYSCALL(sleep)
 190:	b8 0d 00 00 00       	mov    $0xd,%eax
 195:	cd 40                	int    $0x40
 197:	c3                   	ret    

00000198 <uptime>:
SYSCALL(uptime)
 198:	b8 0e 00 00 00       	mov    $0xe,%eax
 19d:	cd 40                	int    $0x40
 19f:	c3                   	ret    

000001a0 <yield>:
SYSCALL(yield)
 1a0:	b8 16 00 00 00       	mov    $0x16,%eax
 1a5:	cd 40                	int    $0x40
 1a7:	c3                   	ret    

000001a8 <shutdown>:
SYSCALL(shutdown)
 1a8:	b8 17 00 00 00       	mov    $0x17,%eax
 1ad:	cd 40                	int    $0x40
 1af:	c3                   	ret    

000001b0 <writecount>:
SYSCALL(writecount)
 1b0:	b8 18 00 00 00       	mov    $0x18,%eax
 1b5:	cd 40                	int    $0x40
 1b7:	c3                   	ret    

000001b8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 1b8:	55                   	push   %ebp
 1b9:	89 e5                	mov    %esp,%ebp
 1bb:	83 ec 1c             	sub    $0x1c,%esp
 1be:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 1c1:	6a 01                	push   $0x1
 1c3:	8d 55 f4             	lea    -0xc(%ebp),%edx
 1c6:	52                   	push   %edx
 1c7:	50                   	push   %eax
 1c8:	e8 53 ff ff ff       	call   120 <write>
}
 1cd:	83 c4 10             	add    $0x10,%esp
 1d0:	c9                   	leave  
 1d1:	c3                   	ret    

000001d2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 1d2:	55                   	push   %ebp
 1d3:	89 e5                	mov    %esp,%ebp
 1d5:	57                   	push   %edi
 1d6:	56                   	push   %esi
 1d7:	53                   	push   %ebx
 1d8:	83 ec 2c             	sub    $0x2c,%esp
 1db:	89 45 d0             	mov    %eax,-0x30(%ebp)
 1de:	89 d0                	mov    %edx,%eax
 1e0:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 1e2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 1e6:	0f 95 c1             	setne  %cl
 1e9:	c1 ea 1f             	shr    $0x1f,%edx
 1ec:	84 d1                	test   %dl,%cl
 1ee:	74 44                	je     234 <printint+0x62>
    neg = 1;
    x = -xx;
 1f0:	f7 d8                	neg    %eax
 1f2:	89 c1                	mov    %eax,%ecx
    neg = 1;
 1f4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 1fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 200:	89 c8                	mov    %ecx,%eax
 202:	ba 00 00 00 00       	mov    $0x0,%edx
 207:	f7 f6                	div    %esi
 209:	89 df                	mov    %ebx,%edi
 20b:	83 c3 01             	add    $0x1,%ebx
 20e:	0f b6 92 5c 04 00 00 	movzbl 0x45c(%edx),%edx
 215:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 219:	89 ca                	mov    %ecx,%edx
 21b:	89 c1                	mov    %eax,%ecx
 21d:	39 d6                	cmp    %edx,%esi
 21f:	76 df                	jbe    200 <printint+0x2e>
  if(neg)
 221:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 225:	74 31                	je     258 <printint+0x86>
    buf[i++] = '-';
 227:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 22c:	8d 5f 02             	lea    0x2(%edi),%ebx
 22f:	8b 75 d0             	mov    -0x30(%ebp),%esi
 232:	eb 17                	jmp    24b <printint+0x79>
    x = xx;
 234:	89 c1                	mov    %eax,%ecx
  neg = 0;
 236:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 23d:	eb bc                	jmp    1fb <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 23f:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 244:	89 f0                	mov    %esi,%eax
 246:	e8 6d ff ff ff       	call   1b8 <putc>
  while(--i >= 0)
 24b:	83 eb 01             	sub    $0x1,%ebx
 24e:	79 ef                	jns    23f <printint+0x6d>
}
 250:	83 c4 2c             	add    $0x2c,%esp
 253:	5b                   	pop    %ebx
 254:	5e                   	pop    %esi
 255:	5f                   	pop    %edi
 256:	5d                   	pop    %ebp
 257:	c3                   	ret    
 258:	8b 75 d0             	mov    -0x30(%ebp),%esi
 25b:	eb ee                	jmp    24b <printint+0x79>

0000025d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 25d:	55                   	push   %ebp
 25e:	89 e5                	mov    %esp,%ebp
 260:	57                   	push   %edi
 261:	56                   	push   %esi
 262:	53                   	push   %ebx
 263:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 266:	8d 45 10             	lea    0x10(%ebp),%eax
 269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 26c:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 271:	bb 00 00 00 00       	mov    $0x0,%ebx
 276:	eb 14                	jmp    28c <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 278:	89 fa                	mov    %edi,%edx
 27a:	8b 45 08             	mov    0x8(%ebp),%eax
 27d:	e8 36 ff ff ff       	call   1b8 <putc>
 282:	eb 05                	jmp    289 <printf+0x2c>
      }
    } else if(state == '%'){
 284:	83 fe 25             	cmp    $0x25,%esi
 287:	74 25                	je     2ae <printf+0x51>
  for(i = 0; fmt[i]; i++){
 289:	83 c3 01             	add    $0x1,%ebx
 28c:	8b 45 0c             	mov    0xc(%ebp),%eax
 28f:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 293:	84 c0                	test   %al,%al
 295:	0f 84 20 01 00 00    	je     3bb <printf+0x15e>
    c = fmt[i] & 0xff;
 29b:	0f be f8             	movsbl %al,%edi
 29e:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 2a1:	85 f6                	test   %esi,%esi
 2a3:	75 df                	jne    284 <printf+0x27>
      if(c == '%'){
 2a5:	83 f8 25             	cmp    $0x25,%eax
 2a8:	75 ce                	jne    278 <printf+0x1b>
        state = '%';
 2aa:	89 c6                	mov    %eax,%esi
 2ac:	eb db                	jmp    289 <printf+0x2c>
      if(c == 'd'){
 2ae:	83 f8 25             	cmp    $0x25,%eax
 2b1:	0f 84 cf 00 00 00    	je     386 <printf+0x129>
 2b7:	0f 8c dd 00 00 00    	jl     39a <printf+0x13d>
 2bd:	83 f8 78             	cmp    $0x78,%eax
 2c0:	0f 8f d4 00 00 00    	jg     39a <printf+0x13d>
 2c6:	83 f8 63             	cmp    $0x63,%eax
 2c9:	0f 8c cb 00 00 00    	jl     39a <printf+0x13d>
 2cf:	83 e8 63             	sub    $0x63,%eax
 2d2:	83 f8 15             	cmp    $0x15,%eax
 2d5:	0f 87 bf 00 00 00    	ja     39a <printf+0x13d>
 2db:	ff 24 85 04 04 00 00 	jmp    *0x404(,%eax,4)
        printint(fd, *ap, 10, 1);
 2e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2e5:	8b 17                	mov    (%edi),%edx
 2e7:	83 ec 0c             	sub    $0xc,%esp
 2ea:	6a 01                	push   $0x1
 2ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
 2f1:	8b 45 08             	mov    0x8(%ebp),%eax
 2f4:	e8 d9 fe ff ff       	call   1d2 <printint>
        ap++;
 2f9:	83 c7 04             	add    $0x4,%edi
 2fc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2ff:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 302:	be 00 00 00 00       	mov    $0x0,%esi
 307:	eb 80                	jmp    289 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 309:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 30c:	8b 17                	mov    (%edi),%edx
 30e:	83 ec 0c             	sub    $0xc,%esp
 311:	6a 00                	push   $0x0
 313:	b9 10 00 00 00       	mov    $0x10,%ecx
 318:	8b 45 08             	mov    0x8(%ebp),%eax
 31b:	e8 b2 fe ff ff       	call   1d2 <printint>
        ap++;
 320:	83 c7 04             	add    $0x4,%edi
 323:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 326:	83 c4 10             	add    $0x10,%esp
      state = 0;
 329:	be 00 00 00 00       	mov    $0x0,%esi
 32e:	e9 56 ff ff ff       	jmp    289 <printf+0x2c>
        s = (char*)*ap;
 333:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 336:	8b 30                	mov    (%eax),%esi
        ap++;
 338:	83 c0 04             	add    $0x4,%eax
 33b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 33e:	85 f6                	test   %esi,%esi
 340:	75 15                	jne    357 <printf+0xfa>
          s = "(null)";
 342:	be fc 03 00 00       	mov    $0x3fc,%esi
 347:	eb 0e                	jmp    357 <printf+0xfa>
          putc(fd, *s);
 349:	0f be d2             	movsbl %dl,%edx
 34c:	8b 45 08             	mov    0x8(%ebp),%eax
 34f:	e8 64 fe ff ff       	call   1b8 <putc>
          s++;
 354:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 357:	0f b6 16             	movzbl (%esi),%edx
 35a:	84 d2                	test   %dl,%dl
 35c:	75 eb                	jne    349 <printf+0xec>
      state = 0;
 35e:	be 00 00 00 00       	mov    $0x0,%esi
 363:	e9 21 ff ff ff       	jmp    289 <printf+0x2c>
        putc(fd, *ap);
 368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 36b:	0f be 17             	movsbl (%edi),%edx
 36e:	8b 45 08             	mov    0x8(%ebp),%eax
 371:	e8 42 fe ff ff       	call   1b8 <putc>
        ap++;
 376:	83 c7 04             	add    $0x4,%edi
 379:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 37c:	be 00 00 00 00       	mov    $0x0,%esi
 381:	e9 03 ff ff ff       	jmp    289 <printf+0x2c>
        putc(fd, c);
 386:	89 fa                	mov    %edi,%edx
 388:	8b 45 08             	mov    0x8(%ebp),%eax
 38b:	e8 28 fe ff ff       	call   1b8 <putc>
      state = 0;
 390:	be 00 00 00 00       	mov    $0x0,%esi
 395:	e9 ef fe ff ff       	jmp    289 <printf+0x2c>
        putc(fd, '%');
 39a:	ba 25 00 00 00       	mov    $0x25,%edx
 39f:	8b 45 08             	mov    0x8(%ebp),%eax
 3a2:	e8 11 fe ff ff       	call   1b8 <putc>
        putc(fd, c);
 3a7:	89 fa                	mov    %edi,%edx
 3a9:	8b 45 08             	mov    0x8(%ebp),%eax
 3ac:	e8 07 fe ff ff       	call   1b8 <putc>
      state = 0;
 3b1:	be 00 00 00 00       	mov    $0x0,%esi
 3b6:	e9 ce fe ff ff       	jmp    289 <printf+0x2c>
    }
  }
}
 3bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
 3be:	5b                   	pop    %ebx
 3bf:	5e                   	pop    %esi
 3c0:	5f                   	pop    %edi
 3c1:	5d                   	pop    %ebp
 3c2:	c3                   	ret    
