
_kill:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 e4 f0             	and    $0xfffffff0,%esp
   9:	83 ec 10             	sub    $0x10,%esp
   c:	8b 75 08             	mov    0x8(%ebp),%esi
   f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  if(argc < 2){
  12:	83 fe 01             	cmp    $0x1,%esi
  15:	7f 31                	jg     48 <main+0x48>
    printf(2, "usage: kill pid...\n");
  17:	c7 44 24 04 b5 04 00 	movl   $0x4b5,0x4(%esp)
  1e:	00 
  1f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  26:	e8 31 03 00 00       	call   35c <printf>
    exit();
  2b:	e8 c7 01 00 00       	call   1f7 <exit>
  }
  for(i=1; i<argc; i++)
    kill(atoi(argv[i]));
  30:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  33:	89 04 24             	mov    %eax,(%esp)
  36:	e8 5f 01 00 00       	call   19a <atoi>
  3b:	89 04 24             	mov    %eax,(%esp)
  3e:	e8 e4 01 00 00       	call   227 <kill>
  for(i=1; i<argc; i++)
  43:	83 c3 01             	add    $0x1,%ebx
  46:	eb 05                	jmp    4d <main+0x4d>
  48:	bb 01 00 00 00       	mov    $0x1,%ebx
  4d:	39 f3                	cmp    %esi,%ebx
  4f:	7c df                	jl     30 <main+0x30>
  exit();
  51:	e8 a1 01 00 00       	call   1f7 <exit>

00000056 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  56:	55                   	push   %ebp
  57:	89 e5                	mov    %esp,%ebp
  59:	53                   	push   %ebx
  5a:	8b 45 08             	mov    0x8(%ebp),%eax
  5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  60:	89 c2                	mov    %eax,%edx
  62:	0f b6 19             	movzbl (%ecx),%ebx
  65:	88 1a                	mov    %bl,(%edx)
  67:	8d 52 01             	lea    0x1(%edx),%edx
  6a:	8d 49 01             	lea    0x1(%ecx),%ecx
  6d:	84 db                	test   %bl,%bl
  6f:	75 f1                	jne    62 <strcpy+0xc>
    ;
  return os;
}
  71:	5b                   	pop    %ebx
  72:	5d                   	pop    %ebp
  73:	c3                   	ret    

00000074 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  74:	55                   	push   %ebp
  75:	89 e5                	mov    %esp,%ebp
  77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  7d:	eb 06                	jmp    85 <strcmp+0x11>
    p++, q++;
  7f:	83 c1 01             	add    $0x1,%ecx
  82:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  85:	0f b6 01             	movzbl (%ecx),%eax
  88:	84 c0                	test   %al,%al
  8a:	74 04                	je     90 <strcmp+0x1c>
  8c:	3a 02                	cmp    (%edx),%al
  8e:	74 ef                	je     7f <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  90:	0f b6 c0             	movzbl %al,%eax
  93:	0f b6 12             	movzbl (%edx),%edx
  96:	29 d0                	sub    %edx,%eax
}
  98:	5d                   	pop    %ebp
  99:	c3                   	ret    

0000009a <strlen>:

uint
strlen(const char *s)
{
  9a:	55                   	push   %ebp
  9b:	89 e5                	mov    %esp,%ebp
  9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  a0:	ba 00 00 00 00       	mov    $0x0,%edx
  a5:	eb 03                	jmp    aa <strlen+0x10>
  a7:	83 c2 01             	add    $0x1,%edx
  aa:	89 d0                	mov    %edx,%eax
  ac:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  b0:	75 f5                	jne    a7 <strlen+0xd>
    ;
  return n;
}
  b2:	5d                   	pop    %ebp
  b3:	c3                   	ret    

000000b4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  b4:	55                   	push   %ebp
  b5:	89 e5                	mov    %esp,%ebp
  b7:	57                   	push   %edi
  b8:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  bb:	89 d7                	mov    %edx,%edi
  bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  c3:	fc                   	cld    
  c4:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  c6:	89 d0                	mov    %edx,%eax
  c8:	5f                   	pop    %edi
  c9:	5d                   	pop    %ebp
  ca:	c3                   	ret    

000000cb <strchr>:

char*
strchr(const char *s, char c)
{
  cb:	55                   	push   %ebp
  cc:	89 e5                	mov    %esp,%ebp
  ce:	8b 45 08             	mov    0x8(%ebp),%eax
  d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  d5:	eb 07                	jmp    de <strchr+0x13>
    if(*s == c)
  d7:	38 ca                	cmp    %cl,%dl
  d9:	74 0f                	je     ea <strchr+0x1f>
  for(; *s; s++)
  db:	83 c0 01             	add    $0x1,%eax
  de:	0f b6 10             	movzbl (%eax),%edx
  e1:	84 d2                	test   %dl,%dl
  e3:	75 f2                	jne    d7 <strchr+0xc>
      return (char*)s;
  return 0;
  e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  ea:	5d                   	pop    %ebp
  eb:	c3                   	ret    

000000ec <gets>:

char*
gets(char *buf, int max)
{
  ec:	55                   	push   %ebp
  ed:	89 e5                	mov    %esp,%ebp
  ef:	57                   	push   %edi
  f0:	56                   	push   %esi
  f1:	53                   	push   %ebx
  f2:	83 ec 2c             	sub    $0x2c,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  f5:	bb 00 00 00 00       	mov    $0x0,%ebx
    cc = read(0, &c, 1);
  fa:	8d 7d e7             	lea    -0x19(%ebp),%edi
  for(i=0; i+1 < max; ){
  fd:	eb 36                	jmp    135 <gets+0x49>
    cc = read(0, &c, 1);
  ff:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 106:	00 
 107:	89 7c 24 04          	mov    %edi,0x4(%esp)
 10b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 112:	e8 f8 00 00 00       	call   20f <read>
    if(cc < 1)
 117:	85 c0                	test   %eax,%eax
 119:	7e 26                	jle    141 <gets+0x55>
      break;
    buf[i++] = c;
 11b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 11f:	8b 4d 08             	mov    0x8(%ebp),%ecx
 122:	88 04 19             	mov    %al,(%ecx,%ebx,1)
    if(c == '\n' || c == '\r')
 125:	3c 0a                	cmp    $0xa,%al
 127:	0f 94 c2             	sete   %dl
 12a:	3c 0d                	cmp    $0xd,%al
 12c:	0f 94 c0             	sete   %al
    buf[i++] = c;
 12f:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 131:	08 c2                	or     %al,%dl
 133:	75 0a                	jne    13f <gets+0x53>
  for(i=0; i+1 < max; ){
 135:	8d 73 01             	lea    0x1(%ebx),%esi
 138:	3b 75 0c             	cmp    0xc(%ebp),%esi
 13b:	7c c2                	jl     ff <gets+0x13>
 13d:	eb 02                	jmp    141 <gets+0x55>
    buf[i++] = c;
 13f:	89 f3                	mov    %esi,%ebx
      break;
  }
  buf[i] = '\0';
 141:	8b 45 08             	mov    0x8(%ebp),%eax
 144:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
  return buf;
}
 148:	83 c4 2c             	add    $0x2c,%esp
 14b:	5b                   	pop    %ebx
 14c:	5e                   	pop    %esi
 14d:	5f                   	pop    %edi
 14e:	5d                   	pop    %ebp
 14f:	c3                   	ret    

00000150 <stat>:

int
stat(const char *n, struct stat *st)
{
 150:	55                   	push   %ebp
 151:	89 e5                	mov    %esp,%ebp
 153:	56                   	push   %esi
 154:	53                   	push   %ebx
 155:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 158:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 15f:	00 
 160:	8b 45 08             	mov    0x8(%ebp),%eax
 163:	89 04 24             	mov    %eax,(%esp)
 166:	e8 cc 00 00 00       	call   237 <open>
 16b:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 16d:	85 c0                	test   %eax,%eax
 16f:	78 1d                	js     18e <stat+0x3e>
    return -1;
  r = fstat(fd, st);
 171:	8b 45 0c             	mov    0xc(%ebp),%eax
 174:	89 44 24 04          	mov    %eax,0x4(%esp)
 178:	89 1c 24             	mov    %ebx,(%esp)
 17b:	e8 cf 00 00 00       	call   24f <fstat>
 180:	89 c6                	mov    %eax,%esi
  close(fd);
 182:	89 1c 24             	mov    %ebx,(%esp)
 185:	e8 95 00 00 00       	call   21f <close>
  return r;
 18a:	89 f0                	mov    %esi,%eax
 18c:	eb 05                	jmp    193 <stat+0x43>
    return -1;
 18e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
 193:	83 c4 10             	add    $0x10,%esp
 196:	5b                   	pop    %ebx
 197:	5e                   	pop    %esi
 198:	5d                   	pop    %ebp
 199:	c3                   	ret    

0000019a <atoi>:

int
atoi(const char *s)
{
 19a:	55                   	push   %ebp
 19b:	89 e5                	mov    %esp,%ebp
 19d:	53                   	push   %ebx
 19e:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  n = 0;
 1a1:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 1a6:	eb 0f                	jmp    1b7 <atoi+0x1d>
    n = n*10 + *s++ - '0';
 1a8:	8d 04 80             	lea    (%eax,%eax,4),%eax
 1ab:	01 c0                	add    %eax,%eax
 1ad:	83 c2 01             	add    $0x1,%edx
 1b0:	0f be c9             	movsbl %cl,%ecx
 1b3:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
  while('0' <= *s && *s <= '9')
 1b7:	0f b6 0a             	movzbl (%edx),%ecx
 1ba:	8d 59 d0             	lea    -0x30(%ecx),%ebx
 1bd:	80 fb 09             	cmp    $0x9,%bl
 1c0:	76 e6                	jbe    1a8 <atoi+0xe>
  return n;
}
 1c2:	5b                   	pop    %ebx
 1c3:	5d                   	pop    %ebp
 1c4:	c3                   	ret    

000001c5 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1c5:	55                   	push   %ebp
 1c6:	89 e5                	mov    %esp,%ebp
 1c8:	56                   	push   %esi
 1c9:	53                   	push   %ebx
 1ca:	8b 45 08             	mov    0x8(%ebp),%eax
 1cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1d0:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 1d3:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 1d5:	eb 0d                	jmp    1e4 <memmove+0x1f>
    *dst++ = *src++;
 1d7:	0f b6 13             	movzbl (%ebx),%edx
 1da:	88 11                	mov    %dl,(%ecx)
  while(n-- > 0)
 1dc:	89 f2                	mov    %esi,%edx
    *dst++ = *src++;
 1de:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1e1:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1e4:	8d 72 ff             	lea    -0x1(%edx),%esi
 1e7:	85 d2                	test   %edx,%edx
 1e9:	7f ec                	jg     1d7 <memmove+0x12>
  return vdst;
}
 1eb:	5b                   	pop    %ebx
 1ec:	5e                   	pop    %esi
 1ed:	5d                   	pop    %ebp
 1ee:	c3                   	ret    

000001ef <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1ef:	b8 01 00 00 00       	mov    $0x1,%eax
 1f4:	cd 40                	int    $0x40
 1f6:	c3                   	ret    

000001f7 <exit>:
SYSCALL(exit)
 1f7:	b8 02 00 00 00       	mov    $0x2,%eax
 1fc:	cd 40                	int    $0x40
 1fe:	c3                   	ret    

000001ff <wait>:
SYSCALL(wait)
 1ff:	b8 03 00 00 00       	mov    $0x3,%eax
 204:	cd 40                	int    $0x40
 206:	c3                   	ret    

00000207 <pipe>:
SYSCALL(pipe)
 207:	b8 04 00 00 00       	mov    $0x4,%eax
 20c:	cd 40                	int    $0x40
 20e:	c3                   	ret    

0000020f <read>:
SYSCALL(read)
 20f:	b8 05 00 00 00       	mov    $0x5,%eax
 214:	cd 40                	int    $0x40
 216:	c3                   	ret    

00000217 <write>:
SYSCALL(write)
 217:	b8 10 00 00 00       	mov    $0x10,%eax
 21c:	cd 40                	int    $0x40
 21e:	c3                   	ret    

0000021f <close>:
SYSCALL(close)
 21f:	b8 15 00 00 00       	mov    $0x15,%eax
 224:	cd 40                	int    $0x40
 226:	c3                   	ret    

00000227 <kill>:
SYSCALL(kill)
 227:	b8 06 00 00 00       	mov    $0x6,%eax
 22c:	cd 40                	int    $0x40
 22e:	c3                   	ret    

0000022f <exec>:
SYSCALL(exec)
 22f:	b8 07 00 00 00       	mov    $0x7,%eax
 234:	cd 40                	int    $0x40
 236:	c3                   	ret    

00000237 <open>:
SYSCALL(open)
 237:	b8 0f 00 00 00       	mov    $0xf,%eax
 23c:	cd 40                	int    $0x40
 23e:	c3                   	ret    

0000023f <mknod>:
SYSCALL(mknod)
 23f:	b8 11 00 00 00       	mov    $0x11,%eax
 244:	cd 40                	int    $0x40
 246:	c3                   	ret    

00000247 <unlink>:
SYSCALL(unlink)
 247:	b8 12 00 00 00       	mov    $0x12,%eax
 24c:	cd 40                	int    $0x40
 24e:	c3                   	ret    

0000024f <fstat>:
SYSCALL(fstat)
 24f:	b8 08 00 00 00       	mov    $0x8,%eax
 254:	cd 40                	int    $0x40
 256:	c3                   	ret    

00000257 <link>:
SYSCALL(link)
 257:	b8 13 00 00 00       	mov    $0x13,%eax
 25c:	cd 40                	int    $0x40
 25e:	c3                   	ret    

0000025f <mkdir>:
SYSCALL(mkdir)
 25f:	b8 14 00 00 00       	mov    $0x14,%eax
 264:	cd 40                	int    $0x40
 266:	c3                   	ret    

00000267 <chdir>:
SYSCALL(chdir)
 267:	b8 09 00 00 00       	mov    $0x9,%eax
 26c:	cd 40                	int    $0x40
 26e:	c3                   	ret    

0000026f <dup>:
SYSCALL(dup)
 26f:	b8 0a 00 00 00       	mov    $0xa,%eax
 274:	cd 40                	int    $0x40
 276:	c3                   	ret    

00000277 <getpid>:
SYSCALL(getpid)
 277:	b8 0b 00 00 00       	mov    $0xb,%eax
 27c:	cd 40                	int    $0x40
 27e:	c3                   	ret    

0000027f <sbrk>:
SYSCALL(sbrk)
 27f:	b8 0c 00 00 00       	mov    $0xc,%eax
 284:	cd 40                	int    $0x40
 286:	c3                   	ret    

00000287 <sleep>:
SYSCALL(sleep)
 287:	b8 0d 00 00 00       	mov    $0xd,%eax
 28c:	cd 40                	int    $0x40
 28e:	c3                   	ret    

0000028f <uptime>:
SYSCALL(uptime)
 28f:	b8 0e 00 00 00       	mov    $0xe,%eax
 294:	cd 40                	int    $0x40
 296:	c3                   	ret    

00000297 <yield>:
SYSCALL(yield)
 297:	b8 16 00 00 00       	mov    $0x16,%eax
 29c:	cd 40                	int    $0x40
 29e:	c3                   	ret    

0000029f <shutdown>:
SYSCALL(shutdown)
 29f:	b8 17 00 00 00       	mov    $0x17,%eax
 2a4:	cd 40                	int    $0x40
 2a6:	c3                   	ret    

000002a7 <writecount>:
SYSCALL(writecount)
 2a7:	b8 18 00 00 00       	mov    $0x18,%eax
 2ac:	cd 40                	int    $0x40
 2ae:	c3                   	ret    

000002af <setwritecount>:
SYSCALL(setwritecount)
 2af:	b8 19 00 00 00       	mov    $0x19,%eax
 2b4:	cd 40                	int    $0x40
 2b6:	c3                   	ret    
 2b7:	66 90                	xchg   %ax,%ax
 2b9:	66 90                	xchg   %ax,%ax
 2bb:	66 90                	xchg   %ax,%ax
 2bd:	66 90                	xchg   %ax,%ax
 2bf:	90                   	nop

000002c0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2c0:	55                   	push   %ebp
 2c1:	89 e5                	mov    %esp,%ebp
 2c3:	83 ec 18             	sub    $0x18,%esp
 2c6:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2c9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2d0:	00 
 2d1:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2d4:	89 54 24 04          	mov    %edx,0x4(%esp)
 2d8:	89 04 24             	mov    %eax,(%esp)
 2db:	e8 37 ff ff ff       	call   217 <write>
}
 2e0:	c9                   	leave  
 2e1:	c3                   	ret    

000002e2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2e2:	55                   	push   %ebp
 2e3:	89 e5                	mov    %esp,%ebp
 2e5:	57                   	push   %edi
 2e6:	56                   	push   %esi
 2e7:	53                   	push   %ebx
 2e8:	83 ec 2c             	sub    $0x2c,%esp
 2eb:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2ed:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2f1:	0f 95 c3             	setne  %bl
 2f4:	89 d0                	mov    %edx,%eax
 2f6:	c1 e8 1f             	shr    $0x1f,%eax
 2f9:	84 c3                	test   %al,%bl
 2fb:	74 0b                	je     308 <printint+0x26>
    neg = 1;
    x = -xx;
 2fd:	f7 da                	neg    %edx
    neg = 1;
 2ff:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
 306:	eb 07                	jmp    30f <printint+0x2d>
  neg = 0;
 308:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 30f:	be 00 00 00 00       	mov    $0x0,%esi
  do{
    buf[i++] = digits[x % base];
 314:	8d 5e 01             	lea    0x1(%esi),%ebx
 317:	89 d0                	mov    %edx,%eax
 319:	ba 00 00 00 00       	mov    $0x0,%edx
 31e:	f7 f1                	div    %ecx
 320:	0f b6 92 d0 04 00 00 	movzbl 0x4d0(%edx),%edx
 327:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 32b:	89 c2                	mov    %eax,%edx
    buf[i++] = digits[x % base];
 32d:	89 de                	mov    %ebx,%esi
  }while((x /= base) != 0);
 32f:	85 c0                	test   %eax,%eax
 331:	75 e1                	jne    314 <printint+0x32>
  if(neg)
 333:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 337:	74 16                	je     34f <printint+0x6d>
    buf[i++] = '-';
 339:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 33e:	8d 5b 01             	lea    0x1(%ebx),%ebx
 341:	eb 0c                	jmp    34f <printint+0x6d>

  while(--i >= 0)
    putc(fd, buf[i]);
 343:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 348:	89 f8                	mov    %edi,%eax
 34a:	e8 71 ff ff ff       	call   2c0 <putc>
  while(--i >= 0)
 34f:	83 eb 01             	sub    $0x1,%ebx
 352:	79 ef                	jns    343 <printint+0x61>
}
 354:	83 c4 2c             	add    $0x2c,%esp
 357:	5b                   	pop    %ebx
 358:	5e                   	pop    %esi
 359:	5f                   	pop    %edi
 35a:	5d                   	pop    %ebp
 35b:	c3                   	ret    

0000035c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 35c:	55                   	push   %ebp
 35d:	89 e5                	mov    %esp,%ebp
 35f:	57                   	push   %edi
 360:	56                   	push   %esi
 361:	53                   	push   %ebx
 362:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 365:	8d 45 10             	lea    0x10(%ebp),%eax
 368:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 36b:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i = 0; fmt[i]; i++){
 370:	be 00 00 00 00       	mov    $0x0,%esi
 375:	e9 23 01 00 00       	jmp    49d <printf+0x141>
    c = fmt[i] & 0xff;
 37a:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 37d:	85 ff                	test   %edi,%edi
 37f:	75 19                	jne    39a <printf+0x3e>
      if(c == '%'){
 381:	83 f8 25             	cmp    $0x25,%eax
 384:	0f 84 0b 01 00 00    	je     495 <printf+0x139>
        state = '%';
      } else {
        putc(fd, c);
 38a:	0f be d3             	movsbl %bl,%edx
 38d:	8b 45 08             	mov    0x8(%ebp),%eax
 390:	e8 2b ff ff ff       	call   2c0 <putc>
 395:	e9 00 01 00 00       	jmp    49a <printf+0x13e>
      }
    } else if(state == '%'){
 39a:	83 ff 25             	cmp    $0x25,%edi
 39d:	0f 85 f7 00 00 00    	jne    49a <printf+0x13e>
      if(c == 'd'){
 3a3:	83 f8 64             	cmp    $0x64,%eax
 3a6:	75 26                	jne    3ce <printf+0x72>
        printint(fd, *ap, 10, 1);
 3a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 3ab:	8b 10                	mov    (%eax),%edx
 3ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3b4:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3b9:	8b 45 08             	mov    0x8(%ebp),%eax
 3bc:	e8 21 ff ff ff       	call   2e2 <printint>
        ap++;
 3c1:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 3c5:	66 bf 00 00          	mov    $0x0,%di
 3c9:	e9 cc 00 00 00       	jmp    49a <printf+0x13e>
      } else if(c == 'x' || c == 'p'){
 3ce:	83 f8 78             	cmp    $0x78,%eax
 3d1:	0f 94 c1             	sete   %cl
 3d4:	83 f8 70             	cmp    $0x70,%eax
 3d7:	0f 94 c2             	sete   %dl
 3da:	08 d1                	or     %dl,%cl
 3dc:	74 27                	je     405 <printf+0xa9>
        printint(fd, *ap, 16, 0);
 3de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 3e1:	8b 10                	mov    (%eax),%edx
 3e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 3ea:	b9 10 00 00 00       	mov    $0x10,%ecx
 3ef:	8b 45 08             	mov    0x8(%ebp),%eax
 3f2:	e8 eb fe ff ff       	call   2e2 <printint>
        ap++;
 3f7:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 3fb:	bf 00 00 00 00       	mov    $0x0,%edi
 400:	e9 95 00 00 00       	jmp    49a <printf+0x13e>
      } else if(c == 's'){
 405:	83 f8 73             	cmp    $0x73,%eax
 408:	75 37                	jne    441 <printf+0xe5>
        s = (char*)*ap;
 40a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 40d:	8b 18                	mov    (%eax),%ebx
        ap++;
 40f:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
        if(s == 0)
 413:	85 db                	test   %ebx,%ebx
 415:	75 19                	jne    430 <printf+0xd4>
          s = "(null)";
 417:	bb c9 04 00 00       	mov    $0x4c9,%ebx
 41c:	8b 7d 08             	mov    0x8(%ebp),%edi
 41f:	eb 12                	jmp    433 <printf+0xd7>
          putc(fd, *s);
 421:	0f be d2             	movsbl %dl,%edx
 424:	89 f8                	mov    %edi,%eax
 426:	e8 95 fe ff ff       	call   2c0 <putc>
          s++;
 42b:	83 c3 01             	add    $0x1,%ebx
 42e:	eb 03                	jmp    433 <printf+0xd7>
 430:	8b 7d 08             	mov    0x8(%ebp),%edi
        while(*s != 0){
 433:	0f b6 13             	movzbl (%ebx),%edx
 436:	84 d2                	test   %dl,%dl
 438:	75 e7                	jne    421 <printf+0xc5>
      state = 0;
 43a:	bf 00 00 00 00       	mov    $0x0,%edi
 43f:	eb 59                	jmp    49a <printf+0x13e>
      } else if(c == 'c'){
 441:	83 f8 63             	cmp    $0x63,%eax
 444:	75 19                	jne    45f <printf+0x103>
        putc(fd, *ap);
 446:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 449:	0f be 10             	movsbl (%eax),%edx
 44c:	8b 45 08             	mov    0x8(%ebp),%eax
 44f:	e8 6c fe ff ff       	call   2c0 <putc>
        ap++;
 454:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 458:	bf 00 00 00 00       	mov    $0x0,%edi
 45d:	eb 3b                	jmp    49a <printf+0x13e>
      } else if(c == '%'){
 45f:	83 f8 25             	cmp    $0x25,%eax
 462:	75 12                	jne    476 <printf+0x11a>
        putc(fd, c);
 464:	0f be d3             	movsbl %bl,%edx
 467:	8b 45 08             	mov    0x8(%ebp),%eax
 46a:	e8 51 fe ff ff       	call   2c0 <putc>
      state = 0;
 46f:	bf 00 00 00 00       	mov    $0x0,%edi
 474:	eb 24                	jmp    49a <printf+0x13e>
        putc(fd, '%');
 476:	ba 25 00 00 00       	mov    $0x25,%edx
 47b:	8b 45 08             	mov    0x8(%ebp),%eax
 47e:	e8 3d fe ff ff       	call   2c0 <putc>
        putc(fd, c);
 483:	0f be d3             	movsbl %bl,%edx
 486:	8b 45 08             	mov    0x8(%ebp),%eax
 489:	e8 32 fe ff ff       	call   2c0 <putc>
      state = 0;
 48e:	bf 00 00 00 00       	mov    $0x0,%edi
 493:	eb 05                	jmp    49a <printf+0x13e>
        state = '%';
 495:	bf 25 00 00 00       	mov    $0x25,%edi
  for(i = 0; fmt[i]; i++){
 49a:	83 c6 01             	add    $0x1,%esi
 49d:	89 f0                	mov    %esi,%eax
 49f:	03 45 0c             	add    0xc(%ebp),%eax
 4a2:	0f b6 18             	movzbl (%eax),%ebx
 4a5:	84 db                	test   %bl,%bl
 4a7:	0f 85 cd fe ff ff    	jne    37a <printf+0x1e>
    }
  }
}
 4ad:	83 c4 1c             	add    $0x1c,%esp
 4b0:	5b                   	pop    %ebx
 4b1:	5e                   	pop    %esi
 4b2:	5f                   	pop    %edi
 4b3:	5d                   	pop    %ebp
 4b4:	c3                   	ret    
