
_writecount:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "stat.h"
#include "user.h"

 
   int main() {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
  
      int result = writecount();
   9:	e8 d5 00 00 00       	call   e3 <writecount>
      printf(1,"Number of sys_write calls: %d\n", result);
   e:	89 44 24 08          	mov    %eax,0x8(%esp)
  12:	c7 44 24 04 f8 02 00 	movl   $0x2f8,0x4(%esp)
  19:	00 
  1a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  21:	e8 76 01 00 00       	call   19c <printf>
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

000000eb <setwritecount>:
SYSCALL(setwritecount)
  eb:	b8 19 00 00 00       	mov    $0x19,%eax
  f0:	cd 40                	int    $0x40
  f2:	c3                   	ret    
  f3:	66 90                	xchg   %ax,%ax
  f5:	66 90                	xchg   %ax,%ax
  f7:	66 90                	xchg   %ax,%ax
  f9:	66 90                	xchg   %ax,%ax
  fb:	66 90                	xchg   %ax,%ax
  fd:	66 90                	xchg   %ax,%ax
  ff:	90                   	nop

00000100 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 100:	55                   	push   %ebp
 101:	89 e5                	mov    %esp,%ebp
 103:	83 ec 18             	sub    $0x18,%esp
 106:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 109:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 110:	00 
 111:	8d 55 f4             	lea    -0xc(%ebp),%edx
 114:	89 54 24 04          	mov    %edx,0x4(%esp)
 118:	89 04 24             	mov    %eax,(%esp)
 11b:	e8 33 ff ff ff       	call   53 <write>
}
 120:	c9                   	leave  
 121:	c3                   	ret    

00000122 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 122:	55                   	push   %ebp
 123:	89 e5                	mov    %esp,%ebp
 125:	57                   	push   %edi
 126:	56                   	push   %esi
 127:	53                   	push   %ebx
 128:	83 ec 2c             	sub    $0x2c,%esp
 12b:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 12d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 131:	0f 95 c3             	setne  %bl
 134:	89 d0                	mov    %edx,%eax
 136:	c1 e8 1f             	shr    $0x1f,%eax
 139:	84 c3                	test   %al,%bl
 13b:	74 0b                	je     148 <printint+0x26>
    neg = 1;
    x = -xx;
 13d:	f7 da                	neg    %edx
    neg = 1;
 13f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
 146:	eb 07                	jmp    14f <printint+0x2d>
  neg = 0;
 148:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 14f:	be 00 00 00 00       	mov    $0x0,%esi
  do{
    buf[i++] = digits[x % base];
 154:	8d 5e 01             	lea    0x1(%esi),%ebx
 157:	89 d0                	mov    %edx,%eax
 159:	ba 00 00 00 00       	mov    $0x0,%edx
 15e:	f7 f1                	div    %ecx
 160:	0f b6 92 1f 03 00 00 	movzbl 0x31f(%edx),%edx
 167:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 16b:	89 c2                	mov    %eax,%edx
    buf[i++] = digits[x % base];
 16d:	89 de                	mov    %ebx,%esi
  }while((x /= base) != 0);
 16f:	85 c0                	test   %eax,%eax
 171:	75 e1                	jne    154 <printint+0x32>
  if(neg)
 173:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 177:	74 16                	je     18f <printint+0x6d>
    buf[i++] = '-';
 179:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 17e:	8d 5b 01             	lea    0x1(%ebx),%ebx
 181:	eb 0c                	jmp    18f <printint+0x6d>

  while(--i >= 0)
    putc(fd, buf[i]);
 183:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 188:	89 f8                	mov    %edi,%eax
 18a:	e8 71 ff ff ff       	call   100 <putc>
  while(--i >= 0)
 18f:	83 eb 01             	sub    $0x1,%ebx
 192:	79 ef                	jns    183 <printint+0x61>
}
 194:	83 c4 2c             	add    $0x2c,%esp
 197:	5b                   	pop    %ebx
 198:	5e                   	pop    %esi
 199:	5f                   	pop    %edi
 19a:	5d                   	pop    %ebp
 19b:	c3                   	ret    

0000019c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 19c:	55                   	push   %ebp
 19d:	89 e5                	mov    %esp,%ebp
 19f:	57                   	push   %edi
 1a0:	56                   	push   %esi
 1a1:	53                   	push   %ebx
 1a2:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1a5:	8d 45 10             	lea    0x10(%ebp),%eax
 1a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1ab:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i = 0; fmt[i]; i++){
 1b0:	be 00 00 00 00       	mov    $0x0,%esi
 1b5:	e9 23 01 00 00       	jmp    2dd <printf+0x141>
    c = fmt[i] & 0xff;
 1ba:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 1bd:	85 ff                	test   %edi,%edi
 1bf:	75 19                	jne    1da <printf+0x3e>
      if(c == '%'){
 1c1:	83 f8 25             	cmp    $0x25,%eax
 1c4:	0f 84 0b 01 00 00    	je     2d5 <printf+0x139>
        state = '%';
      } else {
        putc(fd, c);
 1ca:	0f be d3             	movsbl %bl,%edx
 1cd:	8b 45 08             	mov    0x8(%ebp),%eax
 1d0:	e8 2b ff ff ff       	call   100 <putc>
 1d5:	e9 00 01 00 00       	jmp    2da <printf+0x13e>
      }
    } else if(state == '%'){
 1da:	83 ff 25             	cmp    $0x25,%edi
 1dd:	0f 85 f7 00 00 00    	jne    2da <printf+0x13e>
      if(c == 'd'){
 1e3:	83 f8 64             	cmp    $0x64,%eax
 1e6:	75 26                	jne    20e <printf+0x72>
        printint(fd, *ap, 10, 1);
 1e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1eb:	8b 10                	mov    (%eax),%edx
 1ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
 1f9:	8b 45 08             	mov    0x8(%ebp),%eax
 1fc:	e8 21 ff ff ff       	call   122 <printint>
        ap++;
 201:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 205:	66 bf 00 00          	mov    $0x0,%di
 209:	e9 cc 00 00 00       	jmp    2da <printf+0x13e>
      } else if(c == 'x' || c == 'p'){
 20e:	83 f8 78             	cmp    $0x78,%eax
 211:	0f 94 c1             	sete   %cl
 214:	83 f8 70             	cmp    $0x70,%eax
 217:	0f 94 c2             	sete   %dl
 21a:	08 d1                	or     %dl,%cl
 21c:	74 27                	je     245 <printf+0xa9>
        printint(fd, *ap, 16, 0);
 21e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 221:	8b 10                	mov    (%eax),%edx
 223:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 22a:	b9 10 00 00 00       	mov    $0x10,%ecx
 22f:	8b 45 08             	mov    0x8(%ebp),%eax
 232:	e8 eb fe ff ff       	call   122 <printint>
        ap++;
 237:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 23b:	bf 00 00 00 00       	mov    $0x0,%edi
 240:	e9 95 00 00 00       	jmp    2da <printf+0x13e>
      } else if(c == 's'){
 245:	83 f8 73             	cmp    $0x73,%eax
 248:	75 37                	jne    281 <printf+0xe5>
        s = (char*)*ap;
 24a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 24d:	8b 18                	mov    (%eax),%ebx
        ap++;
 24f:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
        if(s == 0)
 253:	85 db                	test   %ebx,%ebx
 255:	75 19                	jne    270 <printf+0xd4>
          s = "(null)";
 257:	bb 18 03 00 00       	mov    $0x318,%ebx
 25c:	8b 7d 08             	mov    0x8(%ebp),%edi
 25f:	eb 12                	jmp    273 <printf+0xd7>
          putc(fd, *s);
 261:	0f be d2             	movsbl %dl,%edx
 264:	89 f8                	mov    %edi,%eax
 266:	e8 95 fe ff ff       	call   100 <putc>
          s++;
 26b:	83 c3 01             	add    $0x1,%ebx
 26e:	eb 03                	jmp    273 <printf+0xd7>
 270:	8b 7d 08             	mov    0x8(%ebp),%edi
        while(*s != 0){
 273:	0f b6 13             	movzbl (%ebx),%edx
 276:	84 d2                	test   %dl,%dl
 278:	75 e7                	jne    261 <printf+0xc5>
      state = 0;
 27a:	bf 00 00 00 00       	mov    $0x0,%edi
 27f:	eb 59                	jmp    2da <printf+0x13e>
      } else if(c == 'c'){
 281:	83 f8 63             	cmp    $0x63,%eax
 284:	75 19                	jne    29f <printf+0x103>
        putc(fd, *ap);
 286:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 289:	0f be 10             	movsbl (%eax),%edx
 28c:	8b 45 08             	mov    0x8(%ebp),%eax
 28f:	e8 6c fe ff ff       	call   100 <putc>
        ap++;
 294:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 298:	bf 00 00 00 00       	mov    $0x0,%edi
 29d:	eb 3b                	jmp    2da <printf+0x13e>
      } else if(c == '%'){
 29f:	83 f8 25             	cmp    $0x25,%eax
 2a2:	75 12                	jne    2b6 <printf+0x11a>
        putc(fd, c);
 2a4:	0f be d3             	movsbl %bl,%edx
 2a7:	8b 45 08             	mov    0x8(%ebp),%eax
 2aa:	e8 51 fe ff ff       	call   100 <putc>
      state = 0;
 2af:	bf 00 00 00 00       	mov    $0x0,%edi
 2b4:	eb 24                	jmp    2da <printf+0x13e>
        putc(fd, '%');
 2b6:	ba 25 00 00 00       	mov    $0x25,%edx
 2bb:	8b 45 08             	mov    0x8(%ebp),%eax
 2be:	e8 3d fe ff ff       	call   100 <putc>
        putc(fd, c);
 2c3:	0f be d3             	movsbl %bl,%edx
 2c6:	8b 45 08             	mov    0x8(%ebp),%eax
 2c9:	e8 32 fe ff ff       	call   100 <putc>
      state = 0;
 2ce:	bf 00 00 00 00       	mov    $0x0,%edi
 2d3:	eb 05                	jmp    2da <printf+0x13e>
        state = '%';
 2d5:	bf 25 00 00 00       	mov    $0x25,%edi
  for(i = 0; fmt[i]; i++){
 2da:	83 c6 01             	add    $0x1,%esi
 2dd:	89 f0                	mov    %esi,%eax
 2df:	03 45 0c             	add    0xc(%ebp),%eax
 2e2:	0f b6 18             	movzbl (%eax),%ebx
 2e5:	84 db                	test   %bl,%bl
 2e7:	0f 85 cd fe ff ff    	jne    1ba <printf+0x1e>
    }
  }
}
 2ed:	83 c4 1c             	add    $0x1c,%esp
 2f0:	5b                   	pop    %ebx
 2f1:	5e                   	pop    %esi
 2f2:	5f                   	pop    %edi
 2f3:	5d                   	pop    %ebp
 2f4:	c3                   	ret    
