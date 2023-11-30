
_setwritecount:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"


int
main(int argc, char **argv)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
   9:	8b 45 08             	mov    0x8(%ebp),%eax
  
  if(argc < 2 ||argc > 2 ){
   c:	83 f8 02             	cmp    $0x2,%eax
   f:	74 19                	je     2a <main+0x2a>
    printf(1, "error\n");
  11:	c7 44 24 04 a5 04 00 	movl   $0x4a5,0x4(%esp)
  18:	00 
  19:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  20:	e8 27 03 00 00       	call   34c <printf>
    exit();
  25:	e8 c1 01 00 00       	call   1eb <exit>
  }
  if(argc == 2){
  2a:	83 f8 02             	cmp    $0x2,%eax
  2d:	75 16                	jne    45 <main+0x45>
    
    setwritecount(atoi(argv[1]));
  2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  32:	8b 40 04             	mov    0x4(%eax),%eax
  35:	89 04 24             	mov    %eax,(%esp)
  38:	e8 51 01 00 00       	call   18e <atoi>
  3d:	89 04 24             	mov    %eax,(%esp)
  40:	e8 5e 02 00 00       	call   2a3 <setwritecount>

    //printf(1," Number of sys_write calls set to: %d\n", counter);
      
  }

  exit();
  45:	e8 a1 01 00 00       	call   1eb <exit>

0000004a <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  4a:	55                   	push   %ebp
  4b:	89 e5                	mov    %esp,%ebp
  4d:	53                   	push   %ebx
  4e:	8b 45 08             	mov    0x8(%ebp),%eax
  51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  54:	89 c2                	mov    %eax,%edx
  56:	0f b6 19             	movzbl (%ecx),%ebx
  59:	88 1a                	mov    %bl,(%edx)
  5b:	8d 52 01             	lea    0x1(%edx),%edx
  5e:	8d 49 01             	lea    0x1(%ecx),%ecx
  61:	84 db                	test   %bl,%bl
  63:	75 f1                	jne    56 <strcpy+0xc>
    ;
  return os;
}
  65:	5b                   	pop    %ebx
  66:	5d                   	pop    %ebp
  67:	c3                   	ret    

00000068 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  68:	55                   	push   %ebp
  69:	89 e5                	mov    %esp,%ebp
  6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  71:	eb 06                	jmp    79 <strcmp+0x11>
    p++, q++;
  73:	83 c1 01             	add    $0x1,%ecx
  76:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  79:	0f b6 01             	movzbl (%ecx),%eax
  7c:	84 c0                	test   %al,%al
  7e:	74 04                	je     84 <strcmp+0x1c>
  80:	3a 02                	cmp    (%edx),%al
  82:	74 ef                	je     73 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  84:	0f b6 c0             	movzbl %al,%eax
  87:	0f b6 12             	movzbl (%edx),%edx
  8a:	29 d0                	sub    %edx,%eax
}
  8c:	5d                   	pop    %ebp
  8d:	c3                   	ret    

0000008e <strlen>:

uint
strlen(const char *s)
{
  8e:	55                   	push   %ebp
  8f:	89 e5                	mov    %esp,%ebp
  91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  94:	ba 00 00 00 00       	mov    $0x0,%edx
  99:	eb 03                	jmp    9e <strlen+0x10>
  9b:	83 c2 01             	add    $0x1,%edx
  9e:	89 d0                	mov    %edx,%eax
  a0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  a4:	75 f5                	jne    9b <strlen+0xd>
    ;
  return n;
}
  a6:	5d                   	pop    %ebp
  a7:	c3                   	ret    

000000a8 <memset>:

void*
memset(void *dst, int c, uint n)
{
  a8:	55                   	push   %ebp
  a9:	89 e5                	mov    %esp,%ebp
  ab:	57                   	push   %edi
  ac:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  af:	89 d7                	mov    %edx,%edi
  b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  b7:	fc                   	cld    
  b8:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  ba:	89 d0                	mov    %edx,%eax
  bc:	5f                   	pop    %edi
  bd:	5d                   	pop    %ebp
  be:	c3                   	ret    

000000bf <strchr>:

char*
strchr(const char *s, char c)
{
  bf:	55                   	push   %ebp
  c0:	89 e5                	mov    %esp,%ebp
  c2:	8b 45 08             	mov    0x8(%ebp),%eax
  c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  c9:	eb 07                	jmp    d2 <strchr+0x13>
    if(*s == c)
  cb:	38 ca                	cmp    %cl,%dl
  cd:	74 0f                	je     de <strchr+0x1f>
  for(; *s; s++)
  cf:	83 c0 01             	add    $0x1,%eax
  d2:	0f b6 10             	movzbl (%eax),%edx
  d5:	84 d2                	test   %dl,%dl
  d7:	75 f2                	jne    cb <strchr+0xc>
      return (char*)s;
  return 0;
  d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  de:	5d                   	pop    %ebp
  df:	c3                   	ret    

000000e0 <gets>:

char*
gets(char *buf, int max)
{
  e0:	55                   	push   %ebp
  e1:	89 e5                	mov    %esp,%ebp
  e3:	57                   	push   %edi
  e4:	56                   	push   %esi
  e5:	53                   	push   %ebx
  e6:	83 ec 2c             	sub    $0x2c,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  e9:	bb 00 00 00 00       	mov    $0x0,%ebx
    cc = read(0, &c, 1);
  ee:	8d 7d e7             	lea    -0x19(%ebp),%edi
  for(i=0; i+1 < max; ){
  f1:	eb 36                	jmp    129 <gets+0x49>
    cc = read(0, &c, 1);
  f3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  fa:	00 
  fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 106:	e8 f8 00 00 00       	call   203 <read>
    if(cc < 1)
 10b:	85 c0                	test   %eax,%eax
 10d:	7e 26                	jle    135 <gets+0x55>
      break;
    buf[i++] = c;
 10f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 113:	8b 4d 08             	mov    0x8(%ebp),%ecx
 116:	88 04 19             	mov    %al,(%ecx,%ebx,1)
    if(c == '\n' || c == '\r')
 119:	3c 0a                	cmp    $0xa,%al
 11b:	0f 94 c2             	sete   %dl
 11e:	3c 0d                	cmp    $0xd,%al
 120:	0f 94 c0             	sete   %al
    buf[i++] = c;
 123:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 125:	08 c2                	or     %al,%dl
 127:	75 0a                	jne    133 <gets+0x53>
  for(i=0; i+1 < max; ){
 129:	8d 73 01             	lea    0x1(%ebx),%esi
 12c:	3b 75 0c             	cmp    0xc(%ebp),%esi
 12f:	7c c2                	jl     f3 <gets+0x13>
 131:	eb 02                	jmp    135 <gets+0x55>
    buf[i++] = c;
 133:	89 f3                	mov    %esi,%ebx
      break;
  }
  buf[i] = '\0';
 135:	8b 45 08             	mov    0x8(%ebp),%eax
 138:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
  return buf;
}
 13c:	83 c4 2c             	add    $0x2c,%esp
 13f:	5b                   	pop    %ebx
 140:	5e                   	pop    %esi
 141:	5f                   	pop    %edi
 142:	5d                   	pop    %ebp
 143:	c3                   	ret    

00000144 <stat>:

int
stat(const char *n, struct stat *st)
{
 144:	55                   	push   %ebp
 145:	89 e5                	mov    %esp,%ebp
 147:	56                   	push   %esi
 148:	53                   	push   %ebx
 149:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 14c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 153:	00 
 154:	8b 45 08             	mov    0x8(%ebp),%eax
 157:	89 04 24             	mov    %eax,(%esp)
 15a:	e8 cc 00 00 00       	call   22b <open>
 15f:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 161:	85 c0                	test   %eax,%eax
 163:	78 1d                	js     182 <stat+0x3e>
    return -1;
  r = fstat(fd, st);
 165:	8b 45 0c             	mov    0xc(%ebp),%eax
 168:	89 44 24 04          	mov    %eax,0x4(%esp)
 16c:	89 1c 24             	mov    %ebx,(%esp)
 16f:	e8 cf 00 00 00       	call   243 <fstat>
 174:	89 c6                	mov    %eax,%esi
  close(fd);
 176:	89 1c 24             	mov    %ebx,(%esp)
 179:	e8 95 00 00 00       	call   213 <close>
  return r;
 17e:	89 f0                	mov    %esi,%eax
 180:	eb 05                	jmp    187 <stat+0x43>
    return -1;
 182:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
 187:	83 c4 10             	add    $0x10,%esp
 18a:	5b                   	pop    %ebx
 18b:	5e                   	pop    %esi
 18c:	5d                   	pop    %ebp
 18d:	c3                   	ret    

0000018e <atoi>:

int
atoi(const char *s)
{
 18e:	55                   	push   %ebp
 18f:	89 e5                	mov    %esp,%ebp
 191:	53                   	push   %ebx
 192:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  n = 0;
 195:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 19a:	eb 0f                	jmp    1ab <atoi+0x1d>
    n = n*10 + *s++ - '0';
 19c:	8d 04 80             	lea    (%eax,%eax,4),%eax
 19f:	01 c0                	add    %eax,%eax
 1a1:	83 c2 01             	add    $0x1,%edx
 1a4:	0f be c9             	movsbl %cl,%ecx
 1a7:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
  while('0' <= *s && *s <= '9')
 1ab:	0f b6 0a             	movzbl (%edx),%ecx
 1ae:	8d 59 d0             	lea    -0x30(%ecx),%ebx
 1b1:	80 fb 09             	cmp    $0x9,%bl
 1b4:	76 e6                	jbe    19c <atoi+0xe>
  return n;
}
 1b6:	5b                   	pop    %ebx
 1b7:	5d                   	pop    %ebp
 1b8:	c3                   	ret    

000001b9 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1b9:	55                   	push   %ebp
 1ba:	89 e5                	mov    %esp,%ebp
 1bc:	56                   	push   %esi
 1bd:	53                   	push   %ebx
 1be:	8b 45 08             	mov    0x8(%ebp),%eax
 1c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1c4:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 1c7:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 1c9:	eb 0d                	jmp    1d8 <memmove+0x1f>
    *dst++ = *src++;
 1cb:	0f b6 13             	movzbl (%ebx),%edx
 1ce:	88 11                	mov    %dl,(%ecx)
  while(n-- > 0)
 1d0:	89 f2                	mov    %esi,%edx
    *dst++ = *src++;
 1d2:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1d5:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1d8:	8d 72 ff             	lea    -0x1(%edx),%esi
 1db:	85 d2                	test   %edx,%edx
 1dd:	7f ec                	jg     1cb <memmove+0x12>
  return vdst;
}
 1df:	5b                   	pop    %ebx
 1e0:	5e                   	pop    %esi
 1e1:	5d                   	pop    %ebp
 1e2:	c3                   	ret    

000001e3 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1e3:	b8 01 00 00 00       	mov    $0x1,%eax
 1e8:	cd 40                	int    $0x40
 1ea:	c3                   	ret    

000001eb <exit>:
SYSCALL(exit)
 1eb:	b8 02 00 00 00       	mov    $0x2,%eax
 1f0:	cd 40                	int    $0x40
 1f2:	c3                   	ret    

000001f3 <wait>:
SYSCALL(wait)
 1f3:	b8 03 00 00 00       	mov    $0x3,%eax
 1f8:	cd 40                	int    $0x40
 1fa:	c3                   	ret    

000001fb <pipe>:
SYSCALL(pipe)
 1fb:	b8 04 00 00 00       	mov    $0x4,%eax
 200:	cd 40                	int    $0x40
 202:	c3                   	ret    

00000203 <read>:
SYSCALL(read)
 203:	b8 05 00 00 00       	mov    $0x5,%eax
 208:	cd 40                	int    $0x40
 20a:	c3                   	ret    

0000020b <write>:
SYSCALL(write)
 20b:	b8 10 00 00 00       	mov    $0x10,%eax
 210:	cd 40                	int    $0x40
 212:	c3                   	ret    

00000213 <close>:
SYSCALL(close)
 213:	b8 15 00 00 00       	mov    $0x15,%eax
 218:	cd 40                	int    $0x40
 21a:	c3                   	ret    

0000021b <kill>:
SYSCALL(kill)
 21b:	b8 06 00 00 00       	mov    $0x6,%eax
 220:	cd 40                	int    $0x40
 222:	c3                   	ret    

00000223 <exec>:
SYSCALL(exec)
 223:	b8 07 00 00 00       	mov    $0x7,%eax
 228:	cd 40                	int    $0x40
 22a:	c3                   	ret    

0000022b <open>:
SYSCALL(open)
 22b:	b8 0f 00 00 00       	mov    $0xf,%eax
 230:	cd 40                	int    $0x40
 232:	c3                   	ret    

00000233 <mknod>:
SYSCALL(mknod)
 233:	b8 11 00 00 00       	mov    $0x11,%eax
 238:	cd 40                	int    $0x40
 23a:	c3                   	ret    

0000023b <unlink>:
SYSCALL(unlink)
 23b:	b8 12 00 00 00       	mov    $0x12,%eax
 240:	cd 40                	int    $0x40
 242:	c3                   	ret    

00000243 <fstat>:
SYSCALL(fstat)
 243:	b8 08 00 00 00       	mov    $0x8,%eax
 248:	cd 40                	int    $0x40
 24a:	c3                   	ret    

0000024b <link>:
SYSCALL(link)
 24b:	b8 13 00 00 00       	mov    $0x13,%eax
 250:	cd 40                	int    $0x40
 252:	c3                   	ret    

00000253 <mkdir>:
SYSCALL(mkdir)
 253:	b8 14 00 00 00       	mov    $0x14,%eax
 258:	cd 40                	int    $0x40
 25a:	c3                   	ret    

0000025b <chdir>:
SYSCALL(chdir)
 25b:	b8 09 00 00 00       	mov    $0x9,%eax
 260:	cd 40                	int    $0x40
 262:	c3                   	ret    

00000263 <dup>:
SYSCALL(dup)
 263:	b8 0a 00 00 00       	mov    $0xa,%eax
 268:	cd 40                	int    $0x40
 26a:	c3                   	ret    

0000026b <getpid>:
SYSCALL(getpid)
 26b:	b8 0b 00 00 00       	mov    $0xb,%eax
 270:	cd 40                	int    $0x40
 272:	c3                   	ret    

00000273 <sbrk>:
SYSCALL(sbrk)
 273:	b8 0c 00 00 00       	mov    $0xc,%eax
 278:	cd 40                	int    $0x40
 27a:	c3                   	ret    

0000027b <sleep>:
SYSCALL(sleep)
 27b:	b8 0d 00 00 00       	mov    $0xd,%eax
 280:	cd 40                	int    $0x40
 282:	c3                   	ret    

00000283 <uptime>:
SYSCALL(uptime)
 283:	b8 0e 00 00 00       	mov    $0xe,%eax
 288:	cd 40                	int    $0x40
 28a:	c3                   	ret    

0000028b <yield>:
SYSCALL(yield)
 28b:	b8 16 00 00 00       	mov    $0x16,%eax
 290:	cd 40                	int    $0x40
 292:	c3                   	ret    

00000293 <shutdown>:
SYSCALL(shutdown)
 293:	b8 17 00 00 00       	mov    $0x17,%eax
 298:	cd 40                	int    $0x40
 29a:	c3                   	ret    

0000029b <writecount>:
SYSCALL(writecount)
 29b:	b8 18 00 00 00       	mov    $0x18,%eax
 2a0:	cd 40                	int    $0x40
 2a2:	c3                   	ret    

000002a3 <setwritecount>:
SYSCALL(setwritecount)
 2a3:	b8 19 00 00 00       	mov    $0x19,%eax
 2a8:	cd 40                	int    $0x40
 2aa:	c3                   	ret    
 2ab:	66 90                	xchg   %ax,%ax
 2ad:	66 90                	xchg   %ax,%ax
 2af:	90                   	nop

000002b0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2b0:	55                   	push   %ebp
 2b1:	89 e5                	mov    %esp,%ebp
 2b3:	83 ec 18             	sub    $0x18,%esp
 2b6:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2b9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2c0:	00 
 2c1:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2c4:	89 54 24 04          	mov    %edx,0x4(%esp)
 2c8:	89 04 24             	mov    %eax,(%esp)
 2cb:	e8 3b ff ff ff       	call   20b <write>
}
 2d0:	c9                   	leave  
 2d1:	c3                   	ret    

000002d2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2d2:	55                   	push   %ebp
 2d3:	89 e5                	mov    %esp,%ebp
 2d5:	57                   	push   %edi
 2d6:	56                   	push   %esi
 2d7:	53                   	push   %ebx
 2d8:	83 ec 2c             	sub    $0x2c,%esp
 2db:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2dd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2e1:	0f 95 c3             	setne  %bl
 2e4:	89 d0                	mov    %edx,%eax
 2e6:	c1 e8 1f             	shr    $0x1f,%eax
 2e9:	84 c3                	test   %al,%bl
 2eb:	74 0b                	je     2f8 <printint+0x26>
    neg = 1;
    x = -xx;
 2ed:	f7 da                	neg    %edx
    neg = 1;
 2ef:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
 2f6:	eb 07                	jmp    2ff <printint+0x2d>
  neg = 0;
 2f8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2ff:	be 00 00 00 00       	mov    $0x0,%esi
  do{
    buf[i++] = digits[x % base];
 304:	8d 5e 01             	lea    0x1(%esi),%ebx
 307:	89 d0                	mov    %edx,%eax
 309:	ba 00 00 00 00       	mov    $0x0,%edx
 30e:	f7 f1                	div    %ecx
 310:	0f b6 92 b3 04 00 00 	movzbl 0x4b3(%edx),%edx
 317:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 31b:	89 c2                	mov    %eax,%edx
    buf[i++] = digits[x % base];
 31d:	89 de                	mov    %ebx,%esi
  }while((x /= base) != 0);
 31f:	85 c0                	test   %eax,%eax
 321:	75 e1                	jne    304 <printint+0x32>
  if(neg)
 323:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 327:	74 16                	je     33f <printint+0x6d>
    buf[i++] = '-';
 329:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 32e:	8d 5b 01             	lea    0x1(%ebx),%ebx
 331:	eb 0c                	jmp    33f <printint+0x6d>

  while(--i >= 0)
    putc(fd, buf[i]);
 333:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 338:	89 f8                	mov    %edi,%eax
 33a:	e8 71 ff ff ff       	call   2b0 <putc>
  while(--i >= 0)
 33f:	83 eb 01             	sub    $0x1,%ebx
 342:	79 ef                	jns    333 <printint+0x61>
}
 344:	83 c4 2c             	add    $0x2c,%esp
 347:	5b                   	pop    %ebx
 348:	5e                   	pop    %esi
 349:	5f                   	pop    %edi
 34a:	5d                   	pop    %ebp
 34b:	c3                   	ret    

0000034c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 34c:	55                   	push   %ebp
 34d:	89 e5                	mov    %esp,%ebp
 34f:	57                   	push   %edi
 350:	56                   	push   %esi
 351:	53                   	push   %ebx
 352:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 355:	8d 45 10             	lea    0x10(%ebp),%eax
 358:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 35b:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i = 0; fmt[i]; i++){
 360:	be 00 00 00 00       	mov    $0x0,%esi
 365:	e9 23 01 00 00       	jmp    48d <printf+0x141>
    c = fmt[i] & 0xff;
 36a:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 36d:	85 ff                	test   %edi,%edi
 36f:	75 19                	jne    38a <printf+0x3e>
      if(c == '%'){
 371:	83 f8 25             	cmp    $0x25,%eax
 374:	0f 84 0b 01 00 00    	je     485 <printf+0x139>
        state = '%';
      } else {
        putc(fd, c);
 37a:	0f be d3             	movsbl %bl,%edx
 37d:	8b 45 08             	mov    0x8(%ebp),%eax
 380:	e8 2b ff ff ff       	call   2b0 <putc>
 385:	e9 00 01 00 00       	jmp    48a <printf+0x13e>
      }
    } else if(state == '%'){
 38a:	83 ff 25             	cmp    $0x25,%edi
 38d:	0f 85 f7 00 00 00    	jne    48a <printf+0x13e>
      if(c == 'd'){
 393:	83 f8 64             	cmp    $0x64,%eax
 396:	75 26                	jne    3be <printf+0x72>
        printint(fd, *ap, 10, 1);
 398:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 39b:	8b 10                	mov    (%eax),%edx
 39d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3a9:	8b 45 08             	mov    0x8(%ebp),%eax
 3ac:	e8 21 ff ff ff       	call   2d2 <printint>
        ap++;
 3b1:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 3b5:	66 bf 00 00          	mov    $0x0,%di
 3b9:	e9 cc 00 00 00       	jmp    48a <printf+0x13e>
      } else if(c == 'x' || c == 'p'){
 3be:	83 f8 78             	cmp    $0x78,%eax
 3c1:	0f 94 c1             	sete   %cl
 3c4:	83 f8 70             	cmp    $0x70,%eax
 3c7:	0f 94 c2             	sete   %dl
 3ca:	08 d1                	or     %dl,%cl
 3cc:	74 27                	je     3f5 <printf+0xa9>
        printint(fd, *ap, 16, 0);
 3ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 3d1:	8b 10                	mov    (%eax),%edx
 3d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 3da:	b9 10 00 00 00       	mov    $0x10,%ecx
 3df:	8b 45 08             	mov    0x8(%ebp),%eax
 3e2:	e8 eb fe ff ff       	call   2d2 <printint>
        ap++;
 3e7:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 3eb:	bf 00 00 00 00       	mov    $0x0,%edi
 3f0:	e9 95 00 00 00       	jmp    48a <printf+0x13e>
      } else if(c == 's'){
 3f5:	83 f8 73             	cmp    $0x73,%eax
 3f8:	75 37                	jne    431 <printf+0xe5>
        s = (char*)*ap;
 3fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 3fd:	8b 18                	mov    (%eax),%ebx
        ap++;
 3ff:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
        if(s == 0)
 403:	85 db                	test   %ebx,%ebx
 405:	75 19                	jne    420 <printf+0xd4>
          s = "(null)";
 407:	bb ac 04 00 00       	mov    $0x4ac,%ebx
 40c:	8b 7d 08             	mov    0x8(%ebp),%edi
 40f:	eb 12                	jmp    423 <printf+0xd7>
          putc(fd, *s);
 411:	0f be d2             	movsbl %dl,%edx
 414:	89 f8                	mov    %edi,%eax
 416:	e8 95 fe ff ff       	call   2b0 <putc>
          s++;
 41b:	83 c3 01             	add    $0x1,%ebx
 41e:	eb 03                	jmp    423 <printf+0xd7>
 420:	8b 7d 08             	mov    0x8(%ebp),%edi
        while(*s != 0){
 423:	0f b6 13             	movzbl (%ebx),%edx
 426:	84 d2                	test   %dl,%dl
 428:	75 e7                	jne    411 <printf+0xc5>
      state = 0;
 42a:	bf 00 00 00 00       	mov    $0x0,%edi
 42f:	eb 59                	jmp    48a <printf+0x13e>
      } else if(c == 'c'){
 431:	83 f8 63             	cmp    $0x63,%eax
 434:	75 19                	jne    44f <printf+0x103>
        putc(fd, *ap);
 436:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 439:	0f be 10             	movsbl (%eax),%edx
 43c:	8b 45 08             	mov    0x8(%ebp),%eax
 43f:	e8 6c fe ff ff       	call   2b0 <putc>
        ap++;
 444:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 448:	bf 00 00 00 00       	mov    $0x0,%edi
 44d:	eb 3b                	jmp    48a <printf+0x13e>
      } else if(c == '%'){
 44f:	83 f8 25             	cmp    $0x25,%eax
 452:	75 12                	jne    466 <printf+0x11a>
        putc(fd, c);
 454:	0f be d3             	movsbl %bl,%edx
 457:	8b 45 08             	mov    0x8(%ebp),%eax
 45a:	e8 51 fe ff ff       	call   2b0 <putc>
      state = 0;
 45f:	bf 00 00 00 00       	mov    $0x0,%edi
 464:	eb 24                	jmp    48a <printf+0x13e>
        putc(fd, '%');
 466:	ba 25 00 00 00       	mov    $0x25,%edx
 46b:	8b 45 08             	mov    0x8(%ebp),%eax
 46e:	e8 3d fe ff ff       	call   2b0 <putc>
        putc(fd, c);
 473:	0f be d3             	movsbl %bl,%edx
 476:	8b 45 08             	mov    0x8(%ebp),%eax
 479:	e8 32 fe ff ff       	call   2b0 <putc>
      state = 0;
 47e:	bf 00 00 00 00       	mov    $0x0,%edi
 483:	eb 05                	jmp    48a <printf+0x13e>
        state = '%';
 485:	bf 25 00 00 00       	mov    $0x25,%edi
  for(i = 0; fmt[i]; i++){
 48a:	83 c6 01             	add    $0x1,%esi
 48d:	89 f0                	mov    %esi,%eax
 48f:	03 45 0c             	add    0xc(%ebp),%eax
 492:	0f b6 18             	movzbl (%eax),%ebx
 495:	84 db                	test   %bl,%bl
 497:	0f 85 cd fe ff ff    	jne    36a <printf+0x1e>
    }
  }
}
 49d:	83 c4 1c             	add    $0x1c,%esp
 4a0:	5b                   	pop    %ebx
 4a1:	5e                   	pop    %esi
 4a2:	5f                   	pop    %edi
 4a3:	5d                   	pop    %ebp
 4a4:	c3                   	ret    
