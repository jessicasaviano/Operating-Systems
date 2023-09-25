
_writecount:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "stat.h"
#include "user.h"

 
   int main() {
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 04             	sub    $0x4,%esp
  
      int result = writecount();
  11:	e8 cd 00 00 00       	call   e3 <writecount>
      printf(1,"Number of sys_write calls: %d\n", result);
  16:	83 ec 04             	sub    $0x4,%esp
  19:	50                   	push   %eax
  1a:	68 f8 02 00 00       	push   $0x2f8
  1f:	6a 01                	push   $0x1
  21:	e8 6a 01 00 00       	call   190 <printf>
       exit();
  26:	e8 08 00 00 00       	call   33 <exit>

0000002b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  2b:	b8 01 00 00 00       	mov    $0x1,%eax
  30:	cd 40                	int    $0x40
  32:	c3                   	ret    

00000033 <exit>:
SYSCALL(exit)
  33:	b8 02 00 00 00       	mov    $0x2,%eax
  38:	cd 40                	int    $0x40
  3a:	c3                   	ret    

0000003b <wait>:
SYSCALL(wait)
  3b:	b8 03 00 00 00       	mov    $0x3,%eax
  40:	cd 40                	int    $0x40
  42:	c3                   	ret    

00000043 <pipe>:
SYSCALL(pipe)
  43:	b8 04 00 00 00       	mov    $0x4,%eax
  48:	cd 40                	int    $0x40
  4a:	c3                   	ret    

0000004b <read>:
SYSCALL(read)
  4b:	b8 05 00 00 00       	mov    $0x5,%eax
  50:	cd 40                	int    $0x40
  52:	c3                   	ret    

00000053 <write>:
SYSCALL(write)
  53:	b8 10 00 00 00       	mov    $0x10,%eax
  58:	cd 40                	int    $0x40
  5a:	c3                   	ret    

0000005b <close>:
SYSCALL(close)
  5b:	b8 15 00 00 00       	mov    $0x15,%eax
  60:	cd 40                	int    $0x40
  62:	c3                   	ret    

00000063 <kill>:
SYSCALL(kill)
  63:	b8 06 00 00 00       	mov    $0x6,%eax
  68:	cd 40                	int    $0x40
  6a:	c3                   	ret    

0000006b <exec>:
SYSCALL(exec)
  6b:	b8 07 00 00 00       	mov    $0x7,%eax
  70:	cd 40                	int    $0x40
  72:	c3                   	ret    

00000073 <open>:
SYSCALL(open)
  73:	b8 0f 00 00 00       	mov    $0xf,%eax
  78:	cd 40                	int    $0x40
  7a:	c3                   	ret    

0000007b <mknod>:
SYSCALL(mknod)
  7b:	b8 11 00 00 00       	mov    $0x11,%eax
  80:	cd 40                	int    $0x40
  82:	c3                   	ret    

00000083 <unlink>:
SYSCALL(unlink)
  83:	b8 12 00 00 00       	mov    $0x12,%eax
  88:	cd 40                	int    $0x40
  8a:	c3                   	ret    

0000008b <fstat>:
SYSCALL(fstat)
  8b:	b8 08 00 00 00       	mov    $0x8,%eax
  90:	cd 40                	int    $0x40
  92:	c3                   	ret    

00000093 <link>:
SYSCALL(link)
  93:	b8 13 00 00 00       	mov    $0x13,%eax
  98:	cd 40                	int    $0x40
  9a:	c3                   	ret    

0000009b <mkdir>:
SYSCALL(mkdir)
  9b:	b8 14 00 00 00       	mov    $0x14,%eax
  a0:	cd 40                	int    $0x40
  a2:	c3                   	ret    

000000a3 <chdir>:
SYSCALL(chdir)
  a3:	b8 09 00 00 00       	mov    $0x9,%eax
  a8:	cd 40                	int    $0x40
  aa:	c3                   	ret    

000000ab <dup>:
SYSCALL(dup)
  ab:	b8 0a 00 00 00       	mov    $0xa,%eax
  b0:	cd 40                	int    $0x40
  b2:	c3                   	ret    

000000b3 <getpid>:
SYSCALL(getpid)
  b3:	b8 0b 00 00 00       	mov    $0xb,%eax
  b8:	cd 40                	int    $0x40
  ba:	c3                   	ret    

000000bb <sbrk>:
SYSCALL(sbrk)
  bb:	b8 0c 00 00 00       	mov    $0xc,%eax
  c0:	cd 40                	int    $0x40
  c2:	c3                   	ret    

000000c3 <sleep>:
SYSCALL(sleep)
  c3:	b8 0d 00 00 00       	mov    $0xd,%eax
  c8:	cd 40                	int    $0x40
  ca:	c3                   	ret    

000000cb <uptime>:
SYSCALL(uptime)
  cb:	b8 0e 00 00 00       	mov    $0xe,%eax
  d0:	cd 40                	int    $0x40
  d2:	c3                   	ret    

000000d3 <yield>:
SYSCALL(yield)
  d3:	b8 16 00 00 00       	mov    $0x16,%eax
  d8:	cd 40                	int    $0x40
  da:	c3                   	ret    

000000db <shutdown>:
SYSCALL(shutdown)
  db:	b8 17 00 00 00       	mov    $0x17,%eax
  e0:	cd 40                	int    $0x40
  e2:	c3                   	ret    

000000e3 <writecount>:
SYSCALL(writecount)
  e3:	b8 18 00 00 00       	mov    $0x18,%eax
  e8:	cd 40                	int    $0x40
  ea:	c3                   	ret    

000000eb <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
  eb:	55                   	push   %ebp
  ec:	89 e5                	mov    %esp,%ebp
  ee:	83 ec 1c             	sub    $0x1c,%esp
  f1:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
  f4:	6a 01                	push   $0x1
  f6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  f9:	52                   	push   %edx
  fa:	50                   	push   %eax
  fb:	e8 53 ff ff ff       	call   53 <write>
}
 100:	83 c4 10             	add    $0x10,%esp
 103:	c9                   	leave  
 104:	c3                   	ret    

00000105 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 105:	55                   	push   %ebp
 106:	89 e5                	mov    %esp,%ebp
 108:	57                   	push   %edi
 109:	56                   	push   %esi
 10a:	53                   	push   %ebx
 10b:	83 ec 2c             	sub    $0x2c,%esp
 10e:	89 45 d0             	mov    %eax,-0x30(%ebp)
 111:	89 d0                	mov    %edx,%eax
 113:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 115:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 119:	0f 95 c1             	setne  %cl
 11c:	c1 ea 1f             	shr    $0x1f,%edx
 11f:	84 d1                	test   %dl,%cl
 121:	74 44                	je     167 <printint+0x62>
    neg = 1;
    x = -xx;
 123:	f7 d8                	neg    %eax
 125:	89 c1                	mov    %eax,%ecx
    neg = 1;
 127:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 12e:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 133:	89 c8                	mov    %ecx,%eax
 135:	ba 00 00 00 00       	mov    $0x0,%edx
 13a:	f7 f6                	div    %esi
 13c:	89 df                	mov    %ebx,%edi
 13e:	83 c3 01             	add    $0x1,%ebx
 141:	0f b6 92 78 03 00 00 	movzbl 0x378(%edx),%edx
 148:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 14c:	89 ca                	mov    %ecx,%edx
 14e:	89 c1                	mov    %eax,%ecx
 150:	39 d6                	cmp    %edx,%esi
 152:	76 df                	jbe    133 <printint+0x2e>
  if(neg)
 154:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 158:	74 31                	je     18b <printint+0x86>
    buf[i++] = '-';
 15a:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 15f:	8d 5f 02             	lea    0x2(%edi),%ebx
 162:	8b 75 d0             	mov    -0x30(%ebp),%esi
 165:	eb 17                	jmp    17e <printint+0x79>
    x = xx;
 167:	89 c1                	mov    %eax,%ecx
  neg = 0;
 169:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 170:	eb bc                	jmp    12e <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 172:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 177:	89 f0                	mov    %esi,%eax
 179:	e8 6d ff ff ff       	call   eb <putc>
  while(--i >= 0)
 17e:	83 eb 01             	sub    $0x1,%ebx
 181:	79 ef                	jns    172 <printint+0x6d>
}
 183:	83 c4 2c             	add    $0x2c,%esp
 186:	5b                   	pop    %ebx
 187:	5e                   	pop    %esi
 188:	5f                   	pop    %edi
 189:	5d                   	pop    %ebp
 18a:	c3                   	ret    
 18b:	8b 75 d0             	mov    -0x30(%ebp),%esi
 18e:	eb ee                	jmp    17e <printint+0x79>

00000190 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 190:	55                   	push   %ebp
 191:	89 e5                	mov    %esp,%ebp
 193:	57                   	push   %edi
 194:	56                   	push   %esi
 195:	53                   	push   %ebx
 196:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 199:	8d 45 10             	lea    0x10(%ebp),%eax
 19c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 19f:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 1a4:	bb 00 00 00 00       	mov    $0x0,%ebx
 1a9:	eb 14                	jmp    1bf <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 1ab:	89 fa                	mov    %edi,%edx
 1ad:	8b 45 08             	mov    0x8(%ebp),%eax
 1b0:	e8 36 ff ff ff       	call   eb <putc>
 1b5:	eb 05                	jmp    1bc <printf+0x2c>
      }
    } else if(state == '%'){
 1b7:	83 fe 25             	cmp    $0x25,%esi
 1ba:	74 25                	je     1e1 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 1bc:	83 c3 01             	add    $0x1,%ebx
 1bf:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c2:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 1c6:	84 c0                	test   %al,%al
 1c8:	0f 84 20 01 00 00    	je     2ee <printf+0x15e>
    c = fmt[i] & 0xff;
 1ce:	0f be f8             	movsbl %al,%edi
 1d1:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 1d4:	85 f6                	test   %esi,%esi
 1d6:	75 df                	jne    1b7 <printf+0x27>
      if(c == '%'){
 1d8:	83 f8 25             	cmp    $0x25,%eax
 1db:	75 ce                	jne    1ab <printf+0x1b>
        state = '%';
 1dd:	89 c6                	mov    %eax,%esi
 1df:	eb db                	jmp    1bc <printf+0x2c>
      if(c == 'd'){
 1e1:	83 f8 25             	cmp    $0x25,%eax
 1e4:	0f 84 cf 00 00 00    	je     2b9 <printf+0x129>
 1ea:	0f 8c dd 00 00 00    	jl     2cd <printf+0x13d>
 1f0:	83 f8 78             	cmp    $0x78,%eax
 1f3:	0f 8f d4 00 00 00    	jg     2cd <printf+0x13d>
 1f9:	83 f8 63             	cmp    $0x63,%eax
 1fc:	0f 8c cb 00 00 00    	jl     2cd <printf+0x13d>
 202:	83 e8 63             	sub    $0x63,%eax
 205:	83 f8 15             	cmp    $0x15,%eax
 208:	0f 87 bf 00 00 00    	ja     2cd <printf+0x13d>
 20e:	ff 24 85 20 03 00 00 	jmp    *0x320(,%eax,4)
        printint(fd, *ap, 10, 1);
 215:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 218:	8b 17                	mov    (%edi),%edx
 21a:	83 ec 0c             	sub    $0xc,%esp
 21d:	6a 01                	push   $0x1
 21f:	b9 0a 00 00 00       	mov    $0xa,%ecx
 224:	8b 45 08             	mov    0x8(%ebp),%eax
 227:	e8 d9 fe ff ff       	call   105 <printint>
        ap++;
 22c:	83 c7 04             	add    $0x4,%edi
 22f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 232:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 235:	be 00 00 00 00       	mov    $0x0,%esi
 23a:	eb 80                	jmp    1bc <printf+0x2c>
        printint(fd, *ap, 16, 0);
 23c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 23f:	8b 17                	mov    (%edi),%edx
 241:	83 ec 0c             	sub    $0xc,%esp
 244:	6a 00                	push   $0x0
 246:	b9 10 00 00 00       	mov    $0x10,%ecx
 24b:	8b 45 08             	mov    0x8(%ebp),%eax
 24e:	e8 b2 fe ff ff       	call   105 <printint>
        ap++;
 253:	83 c7 04             	add    $0x4,%edi
 256:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 259:	83 c4 10             	add    $0x10,%esp
      state = 0;
 25c:	be 00 00 00 00       	mov    $0x0,%esi
 261:	e9 56 ff ff ff       	jmp    1bc <printf+0x2c>
        s = (char*)*ap;
 266:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 269:	8b 30                	mov    (%eax),%esi
        ap++;
 26b:	83 c0 04             	add    $0x4,%eax
 26e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 271:	85 f6                	test   %esi,%esi
 273:	75 15                	jne    28a <printf+0xfa>
          s = "(null)";
 275:	be 17 03 00 00       	mov    $0x317,%esi
 27a:	eb 0e                	jmp    28a <printf+0xfa>
          putc(fd, *s);
 27c:	0f be d2             	movsbl %dl,%edx
 27f:	8b 45 08             	mov    0x8(%ebp),%eax
 282:	e8 64 fe ff ff       	call   eb <putc>
          s++;
 287:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 28a:	0f b6 16             	movzbl (%esi),%edx
 28d:	84 d2                	test   %dl,%dl
 28f:	75 eb                	jne    27c <printf+0xec>
      state = 0;
 291:	be 00 00 00 00       	mov    $0x0,%esi
 296:	e9 21 ff ff ff       	jmp    1bc <printf+0x2c>
        putc(fd, *ap);
 29b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 29e:	0f be 17             	movsbl (%edi),%edx
 2a1:	8b 45 08             	mov    0x8(%ebp),%eax
 2a4:	e8 42 fe ff ff       	call   eb <putc>
        ap++;
 2a9:	83 c7 04             	add    $0x4,%edi
 2ac:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 2af:	be 00 00 00 00       	mov    $0x0,%esi
 2b4:	e9 03 ff ff ff       	jmp    1bc <printf+0x2c>
        putc(fd, c);
 2b9:	89 fa                	mov    %edi,%edx
 2bb:	8b 45 08             	mov    0x8(%ebp),%eax
 2be:	e8 28 fe ff ff       	call   eb <putc>
      state = 0;
 2c3:	be 00 00 00 00       	mov    $0x0,%esi
 2c8:	e9 ef fe ff ff       	jmp    1bc <printf+0x2c>
        putc(fd, '%');
 2cd:	ba 25 00 00 00       	mov    $0x25,%edx
 2d2:	8b 45 08             	mov    0x8(%ebp),%eax
 2d5:	e8 11 fe ff ff       	call   eb <putc>
        putc(fd, c);
 2da:	89 fa                	mov    %edi,%edx
 2dc:	8b 45 08             	mov    0x8(%ebp),%eax
 2df:	e8 07 fe ff ff       	call   eb <putc>
      state = 0;
 2e4:	be 00 00 00 00       	mov    $0x0,%esi
 2e9:	e9 ce fe ff ff       	jmp    1bc <printf+0x2c>
    }
  }
}
 2ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
 2f1:	5b                   	pop    %ebx
 2f2:	5e                   	pop    %esi
 2f3:	5f                   	pop    %edi
 2f4:	5d                   	pop    %ebp
 2f5:	c3                   	ret    
