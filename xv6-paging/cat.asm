
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
   5:	83 ec 10             	sub    $0x10,%esp
   8:	8b 75 08             	mov    0x8(%ebp),%esi
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
   b:	eb 35                	jmp    42 <cat+0x42>
    if (write(1, buf, n) != n) {
   d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  11:	c7 44 24 04 40 04 00 	movl   $0x440,0x4(%esp)
  18:	00 
  19:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  20:	e8 0b 01 00 00       	call   130 <write>
  25:	39 d8                	cmp    %ebx,%eax
  27:	74 19                	je     42 <cat+0x42>
      printf(1, "cat: write error\n");
  29:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
  30:	00 
  31:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  38:	e8 3f 02 00 00       	call   27c <printf>
      exit();
  3d:	e8 ce 00 00 00       	call   110 <exit>
  while((n = read(fd, buf, sizeof(buf))) > 0) {
  42:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  49:	00 
  4a:	c7 44 24 04 40 04 00 	movl   $0x440,0x4(%esp)
  51:	00 
  52:	89 34 24             	mov    %esi,(%esp)
  55:	e8 ce 00 00 00       	call   128 <read>
  5a:	89 c3                	mov    %eax,%ebx
  5c:	85 c0                	test   %eax,%eax
  5e:	7f ad                	jg     d <cat+0xd>
    }
  }
  if(n < 0){
  60:	85 c0                	test   %eax,%eax
  62:	79 19                	jns    7d <cat+0x7d>
    printf(1, "cat: read error\n");
  64:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
  6b:	00 
  6c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  73:	e8 04 02 00 00       	call   27c <printf>
    exit();
  78:	e8 93 00 00 00       	call   110 <exit>
  }
}
  7d:	83 c4 10             	add    $0x10,%esp
  80:	5b                   	pop    %ebx
  81:	5e                   	pop    %esi
  82:	5d                   	pop    %ebp
  83:	c3                   	ret    

00000084 <main>:

int
main(int argc, char *argv[])
{
  84:	55                   	push   %ebp
  85:	89 e5                	mov    %esp,%ebp
  87:	57                   	push   %edi
  88:	56                   	push   %esi
  89:	53                   	push   %ebx
  8a:	83 e4 f0             	and    $0xfffffff0,%esp
  8d:	83 ec 10             	sub    $0x10,%esp
  int fd, i;

  if(argc <= 1){
  90:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  94:	7f 63                	jg     f9 <main+0x75>
    cat(0);
  96:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  9d:	e8 5e ff ff ff       	call   0 <cat>
    exit();
  a2:	e8 69 00 00 00       	call   110 <exit>
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
  a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  aa:	8d 3c 98             	lea    (%eax,%ebx,4),%edi
  ad:	8b 07                	mov    (%edi),%eax
  af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  b6:	00 
  b7:	89 04 24             	mov    %eax,(%esp)
  ba:	e8 91 00 00 00       	call   150 <open>
  bf:	89 c6                	mov    %eax,%esi
  c1:	85 c0                	test   %eax,%eax
  c3:	79 1f                	jns    e4 <main+0x60>
      printf(1, "cat: cannot open %s\n", argv[i]);
  c5:	8b 07                	mov    (%edi),%eax
  c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  cb:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
  d2:	00 
  d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  da:	e8 9d 01 00 00       	call   27c <printf>
      exit();
  df:	e8 2c 00 00 00       	call   110 <exit>
    }
    cat(fd);
  e4:	89 04 24             	mov    %eax,(%esp)
  e7:	e8 14 ff ff ff       	call   0 <cat>
    close(fd);
  ec:	89 34 24             	mov    %esi,(%esp)
  ef:	e8 44 00 00 00       	call   138 <close>
  for(i = 1; i < argc; i++){
  f4:	83 c3 01             	add    $0x1,%ebx
  f7:	eb 05                	jmp    fe <main+0x7a>
  f9:	bb 01 00 00 00       	mov    $0x1,%ebx
  fe:	3b 5d 08             	cmp    0x8(%ebp),%ebx
 101:	7c a4                	jl     a7 <main+0x23>
  }
  exit();
 103:	e8 08 00 00 00       	call   110 <exit>

00000108 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 108:	b8 01 00 00 00       	mov    $0x1,%eax
 10d:	cd 40                	int    $0x40
 10f:	c3                   	ret    

00000110 <exit>:
SYSCALL(exit)
 110:	b8 02 00 00 00       	mov    $0x2,%eax
 115:	cd 40                	int    $0x40
 117:	c3                   	ret    

00000118 <wait>:
SYSCALL(wait)
 118:	b8 03 00 00 00       	mov    $0x3,%eax
 11d:	cd 40                	int    $0x40
 11f:	c3                   	ret    

00000120 <pipe>:
SYSCALL(pipe)
 120:	b8 04 00 00 00       	mov    $0x4,%eax
 125:	cd 40                	int    $0x40
 127:	c3                   	ret    

00000128 <read>:
SYSCALL(read)
 128:	b8 05 00 00 00       	mov    $0x5,%eax
 12d:	cd 40                	int    $0x40
 12f:	c3                   	ret    

00000130 <write>:
SYSCALL(write)
 130:	b8 10 00 00 00       	mov    $0x10,%eax
 135:	cd 40                	int    $0x40
 137:	c3                   	ret    

00000138 <close>:
SYSCALL(close)
 138:	b8 15 00 00 00       	mov    $0x15,%eax
 13d:	cd 40                	int    $0x40
 13f:	c3                   	ret    

00000140 <kill>:
SYSCALL(kill)
 140:	b8 06 00 00 00       	mov    $0x6,%eax
 145:	cd 40                	int    $0x40
 147:	c3                   	ret    

00000148 <exec>:
SYSCALL(exec)
 148:	b8 07 00 00 00       	mov    $0x7,%eax
 14d:	cd 40                	int    $0x40
 14f:	c3                   	ret    

00000150 <open>:
SYSCALL(open)
 150:	b8 0f 00 00 00       	mov    $0xf,%eax
 155:	cd 40                	int    $0x40
 157:	c3                   	ret    

00000158 <mknod>:
SYSCALL(mknod)
 158:	b8 11 00 00 00       	mov    $0x11,%eax
 15d:	cd 40                	int    $0x40
 15f:	c3                   	ret    

00000160 <unlink>:
SYSCALL(unlink)
 160:	b8 12 00 00 00       	mov    $0x12,%eax
 165:	cd 40                	int    $0x40
 167:	c3                   	ret    

00000168 <fstat>:
SYSCALL(fstat)
 168:	b8 08 00 00 00       	mov    $0x8,%eax
 16d:	cd 40                	int    $0x40
 16f:	c3                   	ret    

00000170 <link>:
SYSCALL(link)
 170:	b8 13 00 00 00       	mov    $0x13,%eax
 175:	cd 40                	int    $0x40
 177:	c3                   	ret    

00000178 <mkdir>:
SYSCALL(mkdir)
 178:	b8 14 00 00 00       	mov    $0x14,%eax
 17d:	cd 40                	int    $0x40
 17f:	c3                   	ret    

00000180 <chdir>:
SYSCALL(chdir)
 180:	b8 09 00 00 00       	mov    $0x9,%eax
 185:	cd 40                	int    $0x40
 187:	c3                   	ret    

00000188 <dup>:
SYSCALL(dup)
 188:	b8 0a 00 00 00       	mov    $0xa,%eax
 18d:	cd 40                	int    $0x40
 18f:	c3                   	ret    

00000190 <getpid>:
SYSCALL(getpid)
 190:	b8 0b 00 00 00       	mov    $0xb,%eax
 195:	cd 40                	int    $0x40
 197:	c3                   	ret    

00000198 <sbrk>:
SYSCALL(sbrk)
 198:	b8 0c 00 00 00       	mov    $0xc,%eax
 19d:	cd 40                	int    $0x40
 19f:	c3                   	ret    

000001a0 <sleep>:
SYSCALL(sleep)
 1a0:	b8 0d 00 00 00       	mov    $0xd,%eax
 1a5:	cd 40                	int    $0x40
 1a7:	c3                   	ret    

000001a8 <uptime>:
SYSCALL(uptime)
 1a8:	b8 0e 00 00 00       	mov    $0xe,%eax
 1ad:	cd 40                	int    $0x40
 1af:	c3                   	ret    

000001b0 <yield>:
SYSCALL(yield)
 1b0:	b8 16 00 00 00       	mov    $0x16,%eax
 1b5:	cd 40                	int    $0x40
 1b7:	c3                   	ret    

000001b8 <getpagetableentry>:
SYSCALL(getpagetableentry)
 1b8:	b8 18 00 00 00       	mov    $0x18,%eax
 1bd:	cd 40                	int    $0x40
 1bf:	c3                   	ret    

000001c0 <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
 1c0:	b8 19 00 00 00       	mov    $0x19,%eax
 1c5:	cd 40                	int    $0x40
 1c7:	c3                   	ret    

000001c8 <dumppagetable>:
SYSCALL(dumppagetable)
 1c8:	b8 1a 00 00 00       	mov    $0x1a,%eax
 1cd:	cd 40                	int    $0x40
 1cf:	c3                   	ret    

000001d0 <shutdown>:
SYSCALL(shutdown)
 1d0:	b8 17 00 00 00       	mov    $0x17,%eax
 1d5:	cd 40                	int    $0x40
 1d7:	c3                   	ret    
 1d8:	66 90                	xchg   %ax,%ax
 1da:	66 90                	xchg   %ax,%ax
 1dc:	66 90                	xchg   %ax,%ax
 1de:	66 90                	xchg   %ax,%ax

000001e0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 1e0:	55                   	push   %ebp
 1e1:	89 e5                	mov    %esp,%ebp
 1e3:	83 ec 18             	sub    $0x18,%esp
 1e6:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 1e9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1f0:	00 
 1f1:	8d 55 f4             	lea    -0xc(%ebp),%edx
 1f4:	89 54 24 04          	mov    %edx,0x4(%esp)
 1f8:	89 04 24             	mov    %eax,(%esp)
 1fb:	e8 30 ff ff ff       	call   130 <write>
}
 200:	c9                   	leave  
 201:	c3                   	ret    

00000202 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 202:	55                   	push   %ebp
 203:	89 e5                	mov    %esp,%ebp
 205:	57                   	push   %edi
 206:	56                   	push   %esi
 207:	53                   	push   %ebx
 208:	83 ec 2c             	sub    $0x2c,%esp
 20b:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 20d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 211:	0f 95 c3             	setne  %bl
 214:	89 d0                	mov    %edx,%eax
 216:	c1 e8 1f             	shr    $0x1f,%eax
 219:	84 c3                	test   %al,%bl
 21b:	74 0b                	je     228 <printint+0x26>
    neg = 1;
    x = -xx;
 21d:	f7 da                	neg    %edx
    neg = 1;
 21f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
 226:	eb 07                	jmp    22f <printint+0x2d>
  neg = 0;
 228:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 22f:	be 00 00 00 00       	mov    $0x0,%esi
  do{
    buf[i++] = digits[x % base];
 234:	8d 5e 01             	lea    0x1(%esi),%ebx
 237:	89 d0                	mov    %edx,%eax
 239:	ba 00 00 00 00       	mov    $0x0,%edx
 23e:	f7 f1                	div    %ecx
 240:	0f b6 92 14 04 00 00 	movzbl 0x414(%edx),%edx
 247:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 24b:	89 c2                	mov    %eax,%edx
    buf[i++] = digits[x % base];
 24d:	89 de                	mov    %ebx,%esi
  }while((x /= base) != 0);
 24f:	85 c0                	test   %eax,%eax
 251:	75 e1                	jne    234 <printint+0x32>
  if(neg)
 253:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 257:	74 16                	je     26f <printint+0x6d>
    buf[i++] = '-';
 259:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 25e:	8d 5b 01             	lea    0x1(%ebx),%ebx
 261:	eb 0c                	jmp    26f <printint+0x6d>

  while(--i >= 0)
    putc(fd, buf[i]);
 263:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 268:	89 f8                	mov    %edi,%eax
 26a:	e8 71 ff ff ff       	call   1e0 <putc>
  while(--i >= 0)
 26f:	83 eb 01             	sub    $0x1,%ebx
 272:	79 ef                	jns    263 <printint+0x61>
}
 274:	83 c4 2c             	add    $0x2c,%esp
 277:	5b                   	pop    %ebx
 278:	5e                   	pop    %esi
 279:	5f                   	pop    %edi
 27a:	5d                   	pop    %ebp
 27b:	c3                   	ret    

0000027c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 27c:	55                   	push   %ebp
 27d:	89 e5                	mov    %esp,%ebp
 27f:	57                   	push   %edi
 280:	56                   	push   %esi
 281:	53                   	push   %ebx
 282:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 285:	8d 45 10             	lea    0x10(%ebp),%eax
 288:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 28b:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i = 0; fmt[i]; i++){
 290:	be 00 00 00 00       	mov    $0x0,%esi
 295:	e9 23 01 00 00       	jmp    3bd <printf+0x141>
    c = fmt[i] & 0xff;
 29a:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 29d:	85 ff                	test   %edi,%edi
 29f:	75 19                	jne    2ba <printf+0x3e>
      if(c == '%'){
 2a1:	83 f8 25             	cmp    $0x25,%eax
 2a4:	0f 84 0b 01 00 00    	je     3b5 <printf+0x139>
        state = '%';
      } else {
        putc(fd, c);
 2aa:	0f be d3             	movsbl %bl,%edx
 2ad:	8b 45 08             	mov    0x8(%ebp),%eax
 2b0:	e8 2b ff ff ff       	call   1e0 <putc>
 2b5:	e9 00 01 00 00       	jmp    3ba <printf+0x13e>
      }
    } else if(state == '%'){
 2ba:	83 ff 25             	cmp    $0x25,%edi
 2bd:	0f 85 f7 00 00 00    	jne    3ba <printf+0x13e>
      if(c == 'd'){
 2c3:	83 f8 64             	cmp    $0x64,%eax
 2c6:	75 26                	jne    2ee <printf+0x72>
        printint(fd, *ap, 10, 1);
 2c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2cb:	8b 10                	mov    (%eax),%edx
 2cd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2d4:	b9 0a 00 00 00       	mov    $0xa,%ecx
 2d9:	8b 45 08             	mov    0x8(%ebp),%eax
 2dc:	e8 21 ff ff ff       	call   202 <printint>
        ap++;
 2e1:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 2e5:	66 bf 00 00          	mov    $0x0,%di
 2e9:	e9 cc 00 00 00       	jmp    3ba <printf+0x13e>
      } else if(c == 'x' || c == 'p'){
 2ee:	83 f8 78             	cmp    $0x78,%eax
 2f1:	0f 94 c1             	sete   %cl
 2f4:	83 f8 70             	cmp    $0x70,%eax
 2f7:	0f 94 c2             	sete   %dl
 2fa:	08 d1                	or     %dl,%cl
 2fc:	74 27                	je     325 <printf+0xa9>
        printint(fd, *ap, 16, 0);
 2fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 301:	8b 10                	mov    (%eax),%edx
 303:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 30a:	b9 10 00 00 00       	mov    $0x10,%ecx
 30f:	8b 45 08             	mov    0x8(%ebp),%eax
 312:	e8 eb fe ff ff       	call   202 <printint>
        ap++;
 317:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 31b:	bf 00 00 00 00       	mov    $0x0,%edi
 320:	e9 95 00 00 00       	jmp    3ba <printf+0x13e>
      } else if(c == 's'){
 325:	83 f8 73             	cmp    $0x73,%eax
 328:	75 37                	jne    361 <printf+0xe5>
        s = (char*)*ap;
 32a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 32d:	8b 18                	mov    (%eax),%ebx
        ap++;
 32f:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
        if(s == 0)
 333:	85 db                	test   %ebx,%ebx
 335:	75 19                	jne    350 <printf+0xd4>
          s = "(null)";
 337:	bb 0d 04 00 00       	mov    $0x40d,%ebx
 33c:	8b 7d 08             	mov    0x8(%ebp),%edi
 33f:	eb 12                	jmp    353 <printf+0xd7>
          putc(fd, *s);
 341:	0f be d2             	movsbl %dl,%edx
 344:	89 f8                	mov    %edi,%eax
 346:	e8 95 fe ff ff       	call   1e0 <putc>
          s++;
 34b:	83 c3 01             	add    $0x1,%ebx
 34e:	eb 03                	jmp    353 <printf+0xd7>
 350:	8b 7d 08             	mov    0x8(%ebp),%edi
        while(*s != 0){
 353:	0f b6 13             	movzbl (%ebx),%edx
 356:	84 d2                	test   %dl,%dl
 358:	75 e7                	jne    341 <printf+0xc5>
      state = 0;
 35a:	bf 00 00 00 00       	mov    $0x0,%edi
 35f:	eb 59                	jmp    3ba <printf+0x13e>
      } else if(c == 'c'){
 361:	83 f8 63             	cmp    $0x63,%eax
 364:	75 19                	jne    37f <printf+0x103>
        putc(fd, *ap);
 366:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 369:	0f be 10             	movsbl (%eax),%edx
 36c:	8b 45 08             	mov    0x8(%ebp),%eax
 36f:	e8 6c fe ff ff       	call   1e0 <putc>
        ap++;
 374:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 378:	bf 00 00 00 00       	mov    $0x0,%edi
 37d:	eb 3b                	jmp    3ba <printf+0x13e>
      } else if(c == '%'){
 37f:	83 f8 25             	cmp    $0x25,%eax
 382:	75 12                	jne    396 <printf+0x11a>
        putc(fd, c);
 384:	0f be d3             	movsbl %bl,%edx
 387:	8b 45 08             	mov    0x8(%ebp),%eax
 38a:	e8 51 fe ff ff       	call   1e0 <putc>
      state = 0;
 38f:	bf 00 00 00 00       	mov    $0x0,%edi
 394:	eb 24                	jmp    3ba <printf+0x13e>
        putc(fd, '%');
 396:	ba 25 00 00 00       	mov    $0x25,%edx
 39b:	8b 45 08             	mov    0x8(%ebp),%eax
 39e:	e8 3d fe ff ff       	call   1e0 <putc>
        putc(fd, c);
 3a3:	0f be d3             	movsbl %bl,%edx
 3a6:	8b 45 08             	mov    0x8(%ebp),%eax
 3a9:	e8 32 fe ff ff       	call   1e0 <putc>
      state = 0;
 3ae:	bf 00 00 00 00       	mov    $0x0,%edi
 3b3:	eb 05                	jmp    3ba <printf+0x13e>
        state = '%';
 3b5:	bf 25 00 00 00       	mov    $0x25,%edi
  for(i = 0; fmt[i]; i++){
 3ba:	83 c6 01             	add    $0x1,%esi
 3bd:	89 f0                	mov    %esi,%eax
 3bf:	03 45 0c             	add    0xc(%ebp),%eax
 3c2:	0f b6 18             	movzbl (%eax),%ebx
 3c5:	84 db                	test   %bl,%bl
 3c7:	0f 85 cd fe ff ff    	jne    29a <printf+0x1e>
    }
  }
}
 3cd:	83 c4 1c             	add    $0x1c,%esp
 3d0:	5b                   	pop    %ebx
 3d1:	5e                   	pop    %esi
 3d2:	5f                   	pop    %edi
 3d3:	5d                   	pop    %ebp
 3d4:	c3                   	ret    
