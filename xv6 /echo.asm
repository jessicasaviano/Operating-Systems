
_echo:     file format elf32-i386


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
   d:	57                   	push   %edi
   e:	56                   	push   %esi
   f:	53                   	push   %ebx
  10:	51                   	push   %ecx
  11:	83 ec 08             	sub    $0x8,%esp
  14:	8b 31                	mov    (%ecx),%esi
  16:	8b 79 04             	mov    0x4(%ecx),%edi
  int i;

  for(i = 1; i < argc; i++)
  19:	b8 01 00 00 00       	mov    $0x1,%eax
  1e:	eb 1a                	jmp    3a <main+0x3a>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  20:	ba 1e 03 00 00       	mov    $0x31e,%edx
  25:	52                   	push   %edx
  26:	ff 34 87             	push   (%edi,%eax,4)
  29:	68 20 03 00 00       	push   $0x320
  2e:	6a 01                	push   $0x1
  30:	e8 81 01 00 00       	call   1b6 <printf>
  35:	83 c4 10             	add    $0x10,%esp
  for(i = 1; i < argc; i++)
  38:	89 d8                	mov    %ebx,%eax
  3a:	39 f0                	cmp    %esi,%eax
  3c:	7d 0e                	jge    4c <main+0x4c>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  3e:	8d 58 01             	lea    0x1(%eax),%ebx
  41:	39 f3                	cmp    %esi,%ebx
  43:	7d db                	jge    20 <main+0x20>
  45:	ba 1c 03 00 00       	mov    $0x31c,%edx
  4a:	eb d9                	jmp    25 <main+0x25>
  exit();
  4c:	e8 08 00 00 00       	call   59 <exit>

00000051 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  51:	b8 01 00 00 00       	mov    $0x1,%eax
  56:	cd 40                	int    $0x40
  58:	c3                   	ret    

00000059 <exit>:
SYSCALL(exit)
  59:	b8 02 00 00 00       	mov    $0x2,%eax
  5e:	cd 40                	int    $0x40
  60:	c3                   	ret    

00000061 <wait>:
SYSCALL(wait)
  61:	b8 03 00 00 00       	mov    $0x3,%eax
  66:	cd 40                	int    $0x40
  68:	c3                   	ret    

00000069 <pipe>:
SYSCALL(pipe)
  69:	b8 04 00 00 00       	mov    $0x4,%eax
  6e:	cd 40                	int    $0x40
  70:	c3                   	ret    

00000071 <read>:
SYSCALL(read)
  71:	b8 05 00 00 00       	mov    $0x5,%eax
  76:	cd 40                	int    $0x40
  78:	c3                   	ret    

00000079 <write>:
SYSCALL(write)
  79:	b8 10 00 00 00       	mov    $0x10,%eax
  7e:	cd 40                	int    $0x40
  80:	c3                   	ret    

00000081 <close>:
SYSCALL(close)
  81:	b8 15 00 00 00       	mov    $0x15,%eax
  86:	cd 40                	int    $0x40
  88:	c3                   	ret    

00000089 <kill>:
SYSCALL(kill)
  89:	b8 06 00 00 00       	mov    $0x6,%eax
  8e:	cd 40                	int    $0x40
  90:	c3                   	ret    

00000091 <exec>:
SYSCALL(exec)
  91:	b8 07 00 00 00       	mov    $0x7,%eax
  96:	cd 40                	int    $0x40
  98:	c3                   	ret    

00000099 <open>:
SYSCALL(open)
  99:	b8 0f 00 00 00       	mov    $0xf,%eax
  9e:	cd 40                	int    $0x40
  a0:	c3                   	ret    

000000a1 <mknod>:
SYSCALL(mknod)
  a1:	b8 11 00 00 00       	mov    $0x11,%eax
  a6:	cd 40                	int    $0x40
  a8:	c3                   	ret    

000000a9 <unlink>:
SYSCALL(unlink)
  a9:	b8 12 00 00 00       	mov    $0x12,%eax
  ae:	cd 40                	int    $0x40
  b0:	c3                   	ret    

000000b1 <fstat>:
SYSCALL(fstat)
  b1:	b8 08 00 00 00       	mov    $0x8,%eax
  b6:	cd 40                	int    $0x40
  b8:	c3                   	ret    

000000b9 <link>:
SYSCALL(link)
  b9:	b8 13 00 00 00       	mov    $0x13,%eax
  be:	cd 40                	int    $0x40
  c0:	c3                   	ret    

000000c1 <mkdir>:
SYSCALL(mkdir)
  c1:	b8 14 00 00 00       	mov    $0x14,%eax
  c6:	cd 40                	int    $0x40
  c8:	c3                   	ret    

000000c9 <chdir>:
SYSCALL(chdir)
  c9:	b8 09 00 00 00       	mov    $0x9,%eax
  ce:	cd 40                	int    $0x40
  d0:	c3                   	ret    

000000d1 <dup>:
SYSCALL(dup)
  d1:	b8 0a 00 00 00       	mov    $0xa,%eax
  d6:	cd 40                	int    $0x40
  d8:	c3                   	ret    

000000d9 <getpid>:
SYSCALL(getpid)
  d9:	b8 0b 00 00 00       	mov    $0xb,%eax
  de:	cd 40                	int    $0x40
  e0:	c3                   	ret    

000000e1 <sbrk>:
SYSCALL(sbrk)
  e1:	b8 0c 00 00 00       	mov    $0xc,%eax
  e6:	cd 40                	int    $0x40
  e8:	c3                   	ret    

000000e9 <sleep>:
SYSCALL(sleep)
  e9:	b8 0d 00 00 00       	mov    $0xd,%eax
  ee:	cd 40                	int    $0x40
  f0:	c3                   	ret    

000000f1 <uptime>:
SYSCALL(uptime)
  f1:	b8 0e 00 00 00       	mov    $0xe,%eax
  f6:	cd 40                	int    $0x40
  f8:	c3                   	ret    

000000f9 <yield>:
SYSCALL(yield)
  f9:	b8 16 00 00 00       	mov    $0x16,%eax
  fe:	cd 40                	int    $0x40
 100:	c3                   	ret    

00000101 <shutdown>:
SYSCALL(shutdown)
 101:	b8 17 00 00 00       	mov    $0x17,%eax
 106:	cd 40                	int    $0x40
 108:	c3                   	ret    

00000109 <writecount>:
SYSCALL(writecount)
 109:	b8 18 00 00 00       	mov    $0x18,%eax
 10e:	cd 40                	int    $0x40
 110:	c3                   	ret    

00000111 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 111:	55                   	push   %ebp
 112:	89 e5                	mov    %esp,%ebp
 114:	83 ec 1c             	sub    $0x1c,%esp
 117:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 11a:	6a 01                	push   $0x1
 11c:	8d 55 f4             	lea    -0xc(%ebp),%edx
 11f:	52                   	push   %edx
 120:	50                   	push   %eax
 121:	e8 53 ff ff ff       	call   79 <write>
}
 126:	83 c4 10             	add    $0x10,%esp
 129:	c9                   	leave  
 12a:	c3                   	ret    

0000012b <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 12b:	55                   	push   %ebp
 12c:	89 e5                	mov    %esp,%ebp
 12e:	57                   	push   %edi
 12f:	56                   	push   %esi
 130:	53                   	push   %ebx
 131:	83 ec 2c             	sub    $0x2c,%esp
 134:	89 45 d0             	mov    %eax,-0x30(%ebp)
 137:	89 d0                	mov    %edx,%eax
 139:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 13b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 13f:	0f 95 c1             	setne  %cl
 142:	c1 ea 1f             	shr    $0x1f,%edx
 145:	84 d1                	test   %dl,%cl
 147:	74 44                	je     18d <printint+0x62>
    neg = 1;
    x = -xx;
 149:	f7 d8                	neg    %eax
 14b:	89 c1                	mov    %eax,%ecx
    neg = 1;
 14d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 154:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 159:	89 c8                	mov    %ecx,%eax
 15b:	ba 00 00 00 00       	mov    $0x0,%edx
 160:	f7 f6                	div    %esi
 162:	89 df                	mov    %ebx,%edi
 164:	83 c3 01             	add    $0x1,%ebx
 167:	0f b6 92 84 03 00 00 	movzbl 0x384(%edx),%edx
 16e:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 172:	89 ca                	mov    %ecx,%edx
 174:	89 c1                	mov    %eax,%ecx
 176:	39 d6                	cmp    %edx,%esi
 178:	76 df                	jbe    159 <printint+0x2e>
  if(neg)
 17a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 17e:	74 31                	je     1b1 <printint+0x86>
    buf[i++] = '-';
 180:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 185:	8d 5f 02             	lea    0x2(%edi),%ebx
 188:	8b 75 d0             	mov    -0x30(%ebp),%esi
 18b:	eb 17                	jmp    1a4 <printint+0x79>
    x = xx;
 18d:	89 c1                	mov    %eax,%ecx
  neg = 0;
 18f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 196:	eb bc                	jmp    154 <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 198:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 19d:	89 f0                	mov    %esi,%eax
 19f:	e8 6d ff ff ff       	call   111 <putc>
  while(--i >= 0)
 1a4:	83 eb 01             	sub    $0x1,%ebx
 1a7:	79 ef                	jns    198 <printint+0x6d>
}
 1a9:	83 c4 2c             	add    $0x2c,%esp
 1ac:	5b                   	pop    %ebx
 1ad:	5e                   	pop    %esi
 1ae:	5f                   	pop    %edi
 1af:	5d                   	pop    %ebp
 1b0:	c3                   	ret    
 1b1:	8b 75 d0             	mov    -0x30(%ebp),%esi
 1b4:	eb ee                	jmp    1a4 <printint+0x79>

000001b6 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1b6:	55                   	push   %ebp
 1b7:	89 e5                	mov    %esp,%ebp
 1b9:	57                   	push   %edi
 1ba:	56                   	push   %esi
 1bb:	53                   	push   %ebx
 1bc:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1bf:	8d 45 10             	lea    0x10(%ebp),%eax
 1c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1c5:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 1ca:	bb 00 00 00 00       	mov    $0x0,%ebx
 1cf:	eb 14                	jmp    1e5 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 1d1:	89 fa                	mov    %edi,%edx
 1d3:	8b 45 08             	mov    0x8(%ebp),%eax
 1d6:	e8 36 ff ff ff       	call   111 <putc>
 1db:	eb 05                	jmp    1e2 <printf+0x2c>
      }
    } else if(state == '%'){
 1dd:	83 fe 25             	cmp    $0x25,%esi
 1e0:	74 25                	je     207 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 1e2:	83 c3 01             	add    $0x1,%ebx
 1e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e8:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 1ec:	84 c0                	test   %al,%al
 1ee:	0f 84 20 01 00 00    	je     314 <printf+0x15e>
    c = fmt[i] & 0xff;
 1f4:	0f be f8             	movsbl %al,%edi
 1f7:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 1fa:	85 f6                	test   %esi,%esi
 1fc:	75 df                	jne    1dd <printf+0x27>
      if(c == '%'){
 1fe:	83 f8 25             	cmp    $0x25,%eax
 201:	75 ce                	jne    1d1 <printf+0x1b>
        state = '%';
 203:	89 c6                	mov    %eax,%esi
 205:	eb db                	jmp    1e2 <printf+0x2c>
      if(c == 'd'){
 207:	83 f8 25             	cmp    $0x25,%eax
 20a:	0f 84 cf 00 00 00    	je     2df <printf+0x129>
 210:	0f 8c dd 00 00 00    	jl     2f3 <printf+0x13d>
 216:	83 f8 78             	cmp    $0x78,%eax
 219:	0f 8f d4 00 00 00    	jg     2f3 <printf+0x13d>
 21f:	83 f8 63             	cmp    $0x63,%eax
 222:	0f 8c cb 00 00 00    	jl     2f3 <printf+0x13d>
 228:	83 e8 63             	sub    $0x63,%eax
 22b:	83 f8 15             	cmp    $0x15,%eax
 22e:	0f 87 bf 00 00 00    	ja     2f3 <printf+0x13d>
 234:	ff 24 85 2c 03 00 00 	jmp    *0x32c(,%eax,4)
        printint(fd, *ap, 10, 1);
 23b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 23e:	8b 17                	mov    (%edi),%edx
 240:	83 ec 0c             	sub    $0xc,%esp
 243:	6a 01                	push   $0x1
 245:	b9 0a 00 00 00       	mov    $0xa,%ecx
 24a:	8b 45 08             	mov    0x8(%ebp),%eax
 24d:	e8 d9 fe ff ff       	call   12b <printint>
        ap++;
 252:	83 c7 04             	add    $0x4,%edi
 255:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 258:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 25b:	be 00 00 00 00       	mov    $0x0,%esi
 260:	eb 80                	jmp    1e2 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 262:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 265:	8b 17                	mov    (%edi),%edx
 267:	83 ec 0c             	sub    $0xc,%esp
 26a:	6a 00                	push   $0x0
 26c:	b9 10 00 00 00       	mov    $0x10,%ecx
 271:	8b 45 08             	mov    0x8(%ebp),%eax
 274:	e8 b2 fe ff ff       	call   12b <printint>
        ap++;
 279:	83 c7 04             	add    $0x4,%edi
 27c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 27f:	83 c4 10             	add    $0x10,%esp
      state = 0;
 282:	be 00 00 00 00       	mov    $0x0,%esi
 287:	e9 56 ff ff ff       	jmp    1e2 <printf+0x2c>
        s = (char*)*ap;
 28c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 28f:	8b 30                	mov    (%eax),%esi
        ap++;
 291:	83 c0 04             	add    $0x4,%eax
 294:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 297:	85 f6                	test   %esi,%esi
 299:	75 15                	jne    2b0 <printf+0xfa>
          s = "(null)";
 29b:	be 25 03 00 00       	mov    $0x325,%esi
 2a0:	eb 0e                	jmp    2b0 <printf+0xfa>
          putc(fd, *s);
 2a2:	0f be d2             	movsbl %dl,%edx
 2a5:	8b 45 08             	mov    0x8(%ebp),%eax
 2a8:	e8 64 fe ff ff       	call   111 <putc>
          s++;
 2ad:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 2b0:	0f b6 16             	movzbl (%esi),%edx
 2b3:	84 d2                	test   %dl,%dl
 2b5:	75 eb                	jne    2a2 <printf+0xec>
      state = 0;
 2b7:	be 00 00 00 00       	mov    $0x0,%esi
 2bc:	e9 21 ff ff ff       	jmp    1e2 <printf+0x2c>
        putc(fd, *ap);
 2c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2c4:	0f be 17             	movsbl (%edi),%edx
 2c7:	8b 45 08             	mov    0x8(%ebp),%eax
 2ca:	e8 42 fe ff ff       	call   111 <putc>
        ap++;
 2cf:	83 c7 04             	add    $0x4,%edi
 2d2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 2d5:	be 00 00 00 00       	mov    $0x0,%esi
 2da:	e9 03 ff ff ff       	jmp    1e2 <printf+0x2c>
        putc(fd, c);
 2df:	89 fa                	mov    %edi,%edx
 2e1:	8b 45 08             	mov    0x8(%ebp),%eax
 2e4:	e8 28 fe ff ff       	call   111 <putc>
      state = 0;
 2e9:	be 00 00 00 00       	mov    $0x0,%esi
 2ee:	e9 ef fe ff ff       	jmp    1e2 <printf+0x2c>
        putc(fd, '%');
 2f3:	ba 25 00 00 00       	mov    $0x25,%edx
 2f8:	8b 45 08             	mov    0x8(%ebp),%eax
 2fb:	e8 11 fe ff ff       	call   111 <putc>
        putc(fd, c);
 300:	89 fa                	mov    %edi,%edx
 302:	8b 45 08             	mov    0x8(%ebp),%eax
 305:	e8 07 fe ff ff       	call   111 <putc>
      state = 0;
 30a:	be 00 00 00 00       	mov    $0x0,%esi
 30f:	e9 ce fe ff ff       	jmp    1e2 <printf+0x2c>
    }
  }
}
 314:	8d 65 f4             	lea    -0xc(%ebp),%esp
 317:	5b                   	pop    %ebx
 318:	5e                   	pop    %esi
 319:	5f                   	pop    %edi
 31a:	5d                   	pop    %ebp
 31b:	c3                   	ret    
