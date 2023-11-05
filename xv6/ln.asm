
_ln:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	8b 59 04             	mov    0x4(%ecx),%ebx
  if(argc != 3){
  12:	83 39 03             	cmpl   $0x3,(%ecx)
  15:	74 14                	je     2b <main+0x2b>
    printf(2, "Usage: ln old new\n");
  17:	83 ec 08             	sub    $0x8,%esp
  1a:	68 28 03 00 00       	push   $0x328
  1f:	6a 02                	push   $0x2
  21:	e8 9b 01 00 00       	call   1c1 <printf>
    exit();
  26:	e8 39 00 00 00       	call   64 <exit>
  }
  if(link(argv[1], argv[2]) < 0)
  2b:	83 ec 08             	sub    $0x8,%esp
  2e:	ff 73 08             	push   0x8(%ebx)
  31:	ff 73 04             	push   0x4(%ebx)
  34:	e8 8b 00 00 00       	call   c4 <link>
  39:	83 c4 10             	add    $0x10,%esp
  3c:	85 c0                	test   %eax,%eax
  3e:	78 05                	js     45 <main+0x45>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  exit();
  40:	e8 1f 00 00 00       	call   64 <exit>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  45:	ff 73 08             	push   0x8(%ebx)
  48:	ff 73 04             	push   0x4(%ebx)
  4b:	68 3b 03 00 00       	push   $0x33b
  50:	6a 02                	push   $0x2
  52:	e8 6a 01 00 00       	call   1c1 <printf>
  57:	83 c4 10             	add    $0x10,%esp
  5a:	eb e4                	jmp    40 <main+0x40>

0000005c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  5c:	b8 01 00 00 00       	mov    $0x1,%eax
  61:	cd 40                	int    $0x40
  63:	c3                   	ret    

00000064 <exit>:
SYSCALL(exit)
  64:	b8 02 00 00 00       	mov    $0x2,%eax
  69:	cd 40                	int    $0x40
  6b:	c3                   	ret    

0000006c <wait>:
SYSCALL(wait)
  6c:	b8 03 00 00 00       	mov    $0x3,%eax
  71:	cd 40                	int    $0x40
  73:	c3                   	ret    

00000074 <pipe>:
SYSCALL(pipe)
  74:	b8 04 00 00 00       	mov    $0x4,%eax
  79:	cd 40                	int    $0x40
  7b:	c3                   	ret    

0000007c <read>:
SYSCALL(read)
  7c:	b8 05 00 00 00       	mov    $0x5,%eax
  81:	cd 40                	int    $0x40
  83:	c3                   	ret    

00000084 <write>:
SYSCALL(write)
  84:	b8 10 00 00 00       	mov    $0x10,%eax
  89:	cd 40                	int    $0x40
  8b:	c3                   	ret    

0000008c <close>:
SYSCALL(close)
  8c:	b8 15 00 00 00       	mov    $0x15,%eax
  91:	cd 40                	int    $0x40
  93:	c3                   	ret    

00000094 <kill>:
SYSCALL(kill)
  94:	b8 06 00 00 00       	mov    $0x6,%eax
  99:	cd 40                	int    $0x40
  9b:	c3                   	ret    

0000009c <exec>:
SYSCALL(exec)
  9c:	b8 07 00 00 00       	mov    $0x7,%eax
  a1:	cd 40                	int    $0x40
  a3:	c3                   	ret    

000000a4 <open>:
SYSCALL(open)
  a4:	b8 0f 00 00 00       	mov    $0xf,%eax
  a9:	cd 40                	int    $0x40
  ab:	c3                   	ret    

000000ac <mknod>:
SYSCALL(mknod)
  ac:	b8 11 00 00 00       	mov    $0x11,%eax
  b1:	cd 40                	int    $0x40
  b3:	c3                   	ret    

000000b4 <unlink>:
SYSCALL(unlink)
  b4:	b8 12 00 00 00       	mov    $0x12,%eax
  b9:	cd 40                	int    $0x40
  bb:	c3                   	ret    

000000bc <fstat>:
SYSCALL(fstat)
  bc:	b8 08 00 00 00       	mov    $0x8,%eax
  c1:	cd 40                	int    $0x40
  c3:	c3                   	ret    

000000c4 <link>:
SYSCALL(link)
  c4:	b8 13 00 00 00       	mov    $0x13,%eax
  c9:	cd 40                	int    $0x40
  cb:	c3                   	ret    

000000cc <mkdir>:
SYSCALL(mkdir)
  cc:	b8 14 00 00 00       	mov    $0x14,%eax
  d1:	cd 40                	int    $0x40
  d3:	c3                   	ret    

000000d4 <chdir>:
SYSCALL(chdir)
  d4:	b8 09 00 00 00       	mov    $0x9,%eax
  d9:	cd 40                	int    $0x40
  db:	c3                   	ret    

000000dc <dup>:
SYSCALL(dup)
  dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  e1:	cd 40                	int    $0x40
  e3:	c3                   	ret    

000000e4 <getpid>:
SYSCALL(getpid)
  e4:	b8 0b 00 00 00       	mov    $0xb,%eax
  e9:	cd 40                	int    $0x40
  eb:	c3                   	ret    

000000ec <sbrk>:
SYSCALL(sbrk)
  ec:	b8 0c 00 00 00       	mov    $0xc,%eax
  f1:	cd 40                	int    $0x40
  f3:	c3                   	ret    

000000f4 <sleep>:
SYSCALL(sleep)
  f4:	b8 0d 00 00 00       	mov    $0xd,%eax
  f9:	cd 40                	int    $0x40
  fb:	c3                   	ret    

000000fc <uptime>:
SYSCALL(uptime)
  fc:	b8 0e 00 00 00       	mov    $0xe,%eax
 101:	cd 40                	int    $0x40
 103:	c3                   	ret    

00000104 <yield>:
SYSCALL(yield)
 104:	b8 16 00 00 00       	mov    $0x16,%eax
 109:	cd 40                	int    $0x40
 10b:	c3                   	ret    

0000010c <shutdown>:
SYSCALL(shutdown)
 10c:	b8 17 00 00 00       	mov    $0x17,%eax
 111:	cd 40                	int    $0x40
 113:	c3                   	ret    

00000114 <writecount>:
SYSCALL(writecount)
 114:	b8 18 00 00 00       	mov    $0x18,%eax
 119:	cd 40                	int    $0x40
 11b:	c3                   	ret    

0000011c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 11c:	55                   	push   %ebp
 11d:	89 e5                	mov    %esp,%ebp
 11f:	83 ec 1c             	sub    $0x1c,%esp
 122:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 125:	6a 01                	push   $0x1
 127:	8d 55 f4             	lea    -0xc(%ebp),%edx
 12a:	52                   	push   %edx
 12b:	50                   	push   %eax
 12c:	e8 53 ff ff ff       	call   84 <write>
}
 131:	83 c4 10             	add    $0x10,%esp
 134:	c9                   	leave  
 135:	c3                   	ret    

00000136 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 136:	55                   	push   %ebp
 137:	89 e5                	mov    %esp,%ebp
 139:	57                   	push   %edi
 13a:	56                   	push   %esi
 13b:	53                   	push   %ebx
 13c:	83 ec 2c             	sub    $0x2c,%esp
 13f:	89 45 d0             	mov    %eax,-0x30(%ebp)
 142:	89 d0                	mov    %edx,%eax
 144:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 146:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 14a:	0f 95 c1             	setne  %cl
 14d:	c1 ea 1f             	shr    $0x1f,%edx
 150:	84 d1                	test   %dl,%cl
 152:	74 44                	je     198 <printint+0x62>
    neg = 1;
    x = -xx;
 154:	f7 d8                	neg    %eax
 156:	89 c1                	mov    %eax,%ecx
    neg = 1;
 158:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 15f:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 164:	89 c8                	mov    %ecx,%eax
 166:	ba 00 00 00 00       	mov    $0x0,%edx
 16b:	f7 f6                	div    %esi
 16d:	89 df                	mov    %ebx,%edi
 16f:	83 c3 01             	add    $0x1,%ebx
 172:	0f b6 92 b0 03 00 00 	movzbl 0x3b0(%edx),%edx
 179:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 17d:	89 ca                	mov    %ecx,%edx
 17f:	89 c1                	mov    %eax,%ecx
 181:	39 d6                	cmp    %edx,%esi
 183:	76 df                	jbe    164 <printint+0x2e>
  if(neg)
 185:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 189:	74 31                	je     1bc <printint+0x86>
    buf[i++] = '-';
 18b:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 190:	8d 5f 02             	lea    0x2(%edi),%ebx
 193:	8b 75 d0             	mov    -0x30(%ebp),%esi
 196:	eb 17                	jmp    1af <printint+0x79>
    x = xx;
 198:	89 c1                	mov    %eax,%ecx
  neg = 0;
 19a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 1a1:	eb bc                	jmp    15f <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 1a3:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 1a8:	89 f0                	mov    %esi,%eax
 1aa:	e8 6d ff ff ff       	call   11c <putc>
  while(--i >= 0)
 1af:	83 eb 01             	sub    $0x1,%ebx
 1b2:	79 ef                	jns    1a3 <printint+0x6d>
}
 1b4:	83 c4 2c             	add    $0x2c,%esp
 1b7:	5b                   	pop    %ebx
 1b8:	5e                   	pop    %esi
 1b9:	5f                   	pop    %edi
 1ba:	5d                   	pop    %ebp
 1bb:	c3                   	ret    
 1bc:	8b 75 d0             	mov    -0x30(%ebp),%esi
 1bf:	eb ee                	jmp    1af <printint+0x79>

000001c1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1c1:	55                   	push   %ebp
 1c2:	89 e5                	mov    %esp,%ebp
 1c4:	57                   	push   %edi
 1c5:	56                   	push   %esi
 1c6:	53                   	push   %ebx
 1c7:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1ca:	8d 45 10             	lea    0x10(%ebp),%eax
 1cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1d0:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 1d5:	bb 00 00 00 00       	mov    $0x0,%ebx
 1da:	eb 14                	jmp    1f0 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 1dc:	89 fa                	mov    %edi,%edx
 1de:	8b 45 08             	mov    0x8(%ebp),%eax
 1e1:	e8 36 ff ff ff       	call   11c <putc>
 1e6:	eb 05                	jmp    1ed <printf+0x2c>
      }
    } else if(state == '%'){
 1e8:	83 fe 25             	cmp    $0x25,%esi
 1eb:	74 25                	je     212 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 1ed:	83 c3 01             	add    $0x1,%ebx
 1f0:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f3:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 1f7:	84 c0                	test   %al,%al
 1f9:	0f 84 20 01 00 00    	je     31f <printf+0x15e>
    c = fmt[i] & 0xff;
 1ff:	0f be f8             	movsbl %al,%edi
 202:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 205:	85 f6                	test   %esi,%esi
 207:	75 df                	jne    1e8 <printf+0x27>
      if(c == '%'){
 209:	83 f8 25             	cmp    $0x25,%eax
 20c:	75 ce                	jne    1dc <printf+0x1b>
        state = '%';
 20e:	89 c6                	mov    %eax,%esi
 210:	eb db                	jmp    1ed <printf+0x2c>
      if(c == 'd'){
 212:	83 f8 25             	cmp    $0x25,%eax
 215:	0f 84 cf 00 00 00    	je     2ea <printf+0x129>
 21b:	0f 8c dd 00 00 00    	jl     2fe <printf+0x13d>
 221:	83 f8 78             	cmp    $0x78,%eax
 224:	0f 8f d4 00 00 00    	jg     2fe <printf+0x13d>
 22a:	83 f8 63             	cmp    $0x63,%eax
 22d:	0f 8c cb 00 00 00    	jl     2fe <printf+0x13d>
 233:	83 e8 63             	sub    $0x63,%eax
 236:	83 f8 15             	cmp    $0x15,%eax
 239:	0f 87 bf 00 00 00    	ja     2fe <printf+0x13d>
 23f:	ff 24 85 58 03 00 00 	jmp    *0x358(,%eax,4)
        printint(fd, *ap, 10, 1);
 246:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 249:	8b 17                	mov    (%edi),%edx
 24b:	83 ec 0c             	sub    $0xc,%esp
 24e:	6a 01                	push   $0x1
 250:	b9 0a 00 00 00       	mov    $0xa,%ecx
 255:	8b 45 08             	mov    0x8(%ebp),%eax
 258:	e8 d9 fe ff ff       	call   136 <printint>
        ap++;
 25d:	83 c7 04             	add    $0x4,%edi
 260:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 263:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 266:	be 00 00 00 00       	mov    $0x0,%esi
 26b:	eb 80                	jmp    1ed <printf+0x2c>
        printint(fd, *ap, 16, 0);
 26d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 270:	8b 17                	mov    (%edi),%edx
 272:	83 ec 0c             	sub    $0xc,%esp
 275:	6a 00                	push   $0x0
 277:	b9 10 00 00 00       	mov    $0x10,%ecx
 27c:	8b 45 08             	mov    0x8(%ebp),%eax
 27f:	e8 b2 fe ff ff       	call   136 <printint>
        ap++;
 284:	83 c7 04             	add    $0x4,%edi
 287:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 28a:	83 c4 10             	add    $0x10,%esp
      state = 0;
 28d:	be 00 00 00 00       	mov    $0x0,%esi
 292:	e9 56 ff ff ff       	jmp    1ed <printf+0x2c>
        s = (char*)*ap;
 297:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 29a:	8b 30                	mov    (%eax),%esi
        ap++;
 29c:	83 c0 04             	add    $0x4,%eax
 29f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 2a2:	85 f6                	test   %esi,%esi
 2a4:	75 15                	jne    2bb <printf+0xfa>
          s = "(null)";
 2a6:	be 4f 03 00 00       	mov    $0x34f,%esi
 2ab:	eb 0e                	jmp    2bb <printf+0xfa>
          putc(fd, *s);
 2ad:	0f be d2             	movsbl %dl,%edx
 2b0:	8b 45 08             	mov    0x8(%ebp),%eax
 2b3:	e8 64 fe ff ff       	call   11c <putc>
          s++;
 2b8:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 2bb:	0f b6 16             	movzbl (%esi),%edx
 2be:	84 d2                	test   %dl,%dl
 2c0:	75 eb                	jne    2ad <printf+0xec>
      state = 0;
 2c2:	be 00 00 00 00       	mov    $0x0,%esi
 2c7:	e9 21 ff ff ff       	jmp    1ed <printf+0x2c>
        putc(fd, *ap);
 2cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2cf:	0f be 17             	movsbl (%edi),%edx
 2d2:	8b 45 08             	mov    0x8(%ebp),%eax
 2d5:	e8 42 fe ff ff       	call   11c <putc>
        ap++;
 2da:	83 c7 04             	add    $0x4,%edi
 2dd:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 2e0:	be 00 00 00 00       	mov    $0x0,%esi
 2e5:	e9 03 ff ff ff       	jmp    1ed <printf+0x2c>
        putc(fd, c);
 2ea:	89 fa                	mov    %edi,%edx
 2ec:	8b 45 08             	mov    0x8(%ebp),%eax
 2ef:	e8 28 fe ff ff       	call   11c <putc>
      state = 0;
 2f4:	be 00 00 00 00       	mov    $0x0,%esi
 2f9:	e9 ef fe ff ff       	jmp    1ed <printf+0x2c>
        putc(fd, '%');
 2fe:	ba 25 00 00 00       	mov    $0x25,%edx
 303:	8b 45 08             	mov    0x8(%ebp),%eax
 306:	e8 11 fe ff ff       	call   11c <putc>
        putc(fd, c);
 30b:	89 fa                	mov    %edi,%edx
 30d:	8b 45 08             	mov    0x8(%ebp),%eax
 310:	e8 07 fe ff ff       	call   11c <putc>
      state = 0;
 315:	be 00 00 00 00       	mov    $0x0,%esi
 31a:	e9 ce fe ff ff       	jmp    1ed <printf+0x2c>
    }
  }
}
 31f:	8d 65 f4             	lea    -0xc(%ebp),%esp
 322:	5b                   	pop    %ebx
 323:	5e                   	pop    %esi
 324:	5f                   	pop    %edi
 325:	5d                   	pop    %ebp
 326:	c3                   	ret    
