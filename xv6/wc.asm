
_wc:     file format elf32-i386


Disassembly of section .text:

00000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 ec 3c             	sub    $0x3c,%esp
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
   9:	bf 00 00 00 00       	mov    $0x0,%edi
  l = w = c = 0;
   e:	be 00 00 00 00       	mov    $0x0,%esi
  13:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
  21:	eb 4b                	jmp    6e <wc+0x6e>
    for(i=0; i<n; i++){
      c++;
  23:	83 c6 01             	add    $0x1,%esi
      if(buf[i] == '\n')
  26:	0f b6 83 40 06 00 00 	movzbl 0x640(%ebx),%eax
  2d:	3c 0a                	cmp    $0xa,%al
  2f:	75 04                	jne    35 <wc+0x35>
        l++;
  31:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
      if(strchr(" \r\t\n\v", buf[i]))
  35:	0f be c0             	movsbl %al,%eax
  38:	89 44 24 04          	mov    %eax,0x4(%esp)
  3c:	c7 04 24 d5 05 00 00 	movl   $0x5d5,(%esp)
  43:	e8 a1 01 00 00       	call   1e9 <strchr>
  48:	85 c0                	test   %eax,%eax
  4a:	75 0e                	jne    5a <wc+0x5a>
        inword = 0;
      else if(!inword){
  4c:	85 ff                	test   %edi,%edi
  4e:	75 0f                	jne    5f <wc+0x5f>
        w++;
  50:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
        inword = 1;
  54:	66 bf 01 00          	mov    $0x1,%di
  58:	eb 05                	jmp    5f <wc+0x5f>
        inword = 0;
  5a:	bf 00 00 00 00       	mov    $0x0,%edi
    for(i=0; i<n; i++){
  5f:	83 c3 01             	add    $0x1,%ebx
  62:	eb 05                	jmp    69 <wc+0x69>
  64:	bb 00 00 00 00       	mov    $0x0,%ebx
  69:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
  6c:	7c b5                	jl     23 <wc+0x23>
  while((n = read(fd, buf, sizeof(buf))) > 0){
  6e:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  75:	00 
  76:	c7 44 24 04 40 06 00 	movl   $0x640,0x4(%esp)
  7d:	00 
  7e:	8b 45 08             	mov    0x8(%ebp),%eax
  81:	89 04 24             	mov    %eax,(%esp)
  84:	e8 a4 02 00 00       	call   32d <read>
  89:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8c:	85 c0                	test   %eax,%eax
  8e:	7f d4                	jg     64 <wc+0x64>
      }
    }
  }
  if(n < 0){
  90:	85 c0                	test   %eax,%eax
  92:	79 19                	jns    ad <wc+0xad>
    printf(1, "wc: read error\n");
  94:	c7 44 24 04 db 05 00 	movl   $0x5db,0x4(%esp)
  9b:	00 
  9c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a3:	e8 d4 03 00 00       	call   47c <printf>
    exit();
  a8:	e8 68 02 00 00       	call   315 <exit>
  }
  printf(1, "%d %d %d %s\n", l, w, c, name);
  ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  b0:	89 44 24 14          	mov    %eax,0x14(%esp)
  b4:	89 74 24 10          	mov    %esi,0x10(%esp)
  b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  c6:	c7 44 24 04 eb 05 00 	movl   $0x5eb,0x4(%esp)
  cd:	00 
  ce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d5:	e8 a2 03 00 00       	call   47c <printf>
}
  da:	83 c4 3c             	add    $0x3c,%esp
  dd:	5b                   	pop    %ebx
  de:	5e                   	pop    %esi
  df:	5f                   	pop    %edi
  e0:	5d                   	pop    %ebp
  e1:	c3                   	ret    

000000e2 <main>:

int
main(int argc, char *argv[])
{
  e2:	55                   	push   %ebp
  e3:	89 e5                	mov    %esp,%ebp
  e5:	57                   	push   %edi
  e6:	56                   	push   %esi
  e7:	53                   	push   %ebx
  e8:	83 e4 f0             	and    $0xfffffff0,%esp
  eb:	83 ec 10             	sub    $0x10,%esp
  int fd, i;

  if(argc <= 1){
  ee:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  f2:	7f 71                	jg     165 <main+0x83>
    wc(0, "");
  f4:	c7 44 24 04 ea 05 00 	movl   $0x5ea,0x4(%esp)
  fb:	00 
  fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 103:	e8 f8 fe ff ff       	call   0 <wc>
    exit();
 108:	e8 08 02 00 00       	call   315 <exit>
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
 10d:	8b 45 0c             	mov    0xc(%ebp),%eax
 110:	8d 3c 98             	lea    (%eax,%ebx,4),%edi
 113:	8b 07                	mov    (%edi),%eax
 115:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 11c:	00 
 11d:	89 04 24             	mov    %eax,(%esp)
 120:	e8 30 02 00 00       	call   355 <open>
 125:	89 c6                	mov    %eax,%esi
 127:	85 c0                	test   %eax,%eax
 129:	79 1f                	jns    14a <main+0x68>
      printf(1, "wc: cannot open %s\n", argv[i]);
 12b:	8b 07                	mov    (%edi),%eax
 12d:	89 44 24 08          	mov    %eax,0x8(%esp)
 131:	c7 44 24 04 f8 05 00 	movl   $0x5f8,0x4(%esp)
 138:	00 
 139:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 140:	e8 37 03 00 00       	call   47c <printf>
      exit();
 145:	e8 cb 01 00 00       	call   315 <exit>
    }
    wc(fd, argv[i]);
 14a:	8b 07                	mov    (%edi),%eax
 14c:	89 44 24 04          	mov    %eax,0x4(%esp)
 150:	89 34 24             	mov    %esi,(%esp)
 153:	e8 a8 fe ff ff       	call   0 <wc>
    close(fd);
 158:	89 34 24             	mov    %esi,(%esp)
 15b:	e8 dd 01 00 00       	call   33d <close>
  for(i = 1; i < argc; i++){
 160:	83 c3 01             	add    $0x1,%ebx
 163:	eb 05                	jmp    16a <main+0x88>
 165:	bb 01 00 00 00       	mov    $0x1,%ebx
 16a:	3b 5d 08             	cmp    0x8(%ebp),%ebx
 16d:	7c 9e                	jl     10d <main+0x2b>
  }
  exit();
 16f:	e8 a1 01 00 00       	call   315 <exit>

00000174 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 174:	55                   	push   %ebp
 175:	89 e5                	mov    %esp,%ebp
 177:	53                   	push   %ebx
 178:	8b 45 08             	mov    0x8(%ebp),%eax
 17b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 17e:	89 c2                	mov    %eax,%edx
 180:	0f b6 19             	movzbl (%ecx),%ebx
 183:	88 1a                	mov    %bl,(%edx)
 185:	8d 52 01             	lea    0x1(%edx),%edx
 188:	8d 49 01             	lea    0x1(%ecx),%ecx
 18b:	84 db                	test   %bl,%bl
 18d:	75 f1                	jne    180 <strcpy+0xc>
    ;
  return os;
}
 18f:	5b                   	pop    %ebx
 190:	5d                   	pop    %ebp
 191:	c3                   	ret    

00000192 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 192:	55                   	push   %ebp
 193:	89 e5                	mov    %esp,%ebp
 195:	8b 4d 08             	mov    0x8(%ebp),%ecx
 198:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 19b:	eb 06                	jmp    1a3 <strcmp+0x11>
    p++, q++;
 19d:	83 c1 01             	add    $0x1,%ecx
 1a0:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 1a3:	0f b6 01             	movzbl (%ecx),%eax
 1a6:	84 c0                	test   %al,%al
 1a8:	74 04                	je     1ae <strcmp+0x1c>
 1aa:	3a 02                	cmp    (%edx),%al
 1ac:	74 ef                	je     19d <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 1ae:	0f b6 c0             	movzbl %al,%eax
 1b1:	0f b6 12             	movzbl (%edx),%edx
 1b4:	29 d0                	sub    %edx,%eax
}
 1b6:	5d                   	pop    %ebp
 1b7:	c3                   	ret    

000001b8 <strlen>:

uint
strlen(const char *s)
{
 1b8:	55                   	push   %ebp
 1b9:	89 e5                	mov    %esp,%ebp
 1bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 1be:	ba 00 00 00 00       	mov    $0x0,%edx
 1c3:	eb 03                	jmp    1c8 <strlen+0x10>
 1c5:	83 c2 01             	add    $0x1,%edx
 1c8:	89 d0                	mov    %edx,%eax
 1ca:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 1ce:	75 f5                	jne    1c5 <strlen+0xd>
    ;
  return n;
}
 1d0:	5d                   	pop    %ebp
 1d1:	c3                   	ret    

000001d2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d2:	55                   	push   %ebp
 1d3:	89 e5                	mov    %esp,%ebp
 1d5:	57                   	push   %edi
 1d6:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 1d9:	89 d7                	mov    %edx,%edi
 1db:	8b 4d 10             	mov    0x10(%ebp),%ecx
 1de:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e1:	fc                   	cld    
 1e2:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 1e4:	89 d0                	mov    %edx,%eax
 1e6:	5f                   	pop    %edi
 1e7:	5d                   	pop    %ebp
 1e8:	c3                   	ret    

000001e9 <strchr>:

char*
strchr(const char *s, char c)
{
 1e9:	55                   	push   %ebp
 1ea:	89 e5                	mov    %esp,%ebp
 1ec:	8b 45 08             	mov    0x8(%ebp),%eax
 1ef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 1f3:	eb 07                	jmp    1fc <strchr+0x13>
    if(*s == c)
 1f5:	38 ca                	cmp    %cl,%dl
 1f7:	74 0f                	je     208 <strchr+0x1f>
  for(; *s; s++)
 1f9:	83 c0 01             	add    $0x1,%eax
 1fc:	0f b6 10             	movzbl (%eax),%edx
 1ff:	84 d2                	test   %dl,%dl
 201:	75 f2                	jne    1f5 <strchr+0xc>
      return (char*)s;
  return 0;
 203:	b8 00 00 00 00       	mov    $0x0,%eax
}
 208:	5d                   	pop    %ebp
 209:	c3                   	ret    

0000020a <gets>:

char*
gets(char *buf, int max)
{
 20a:	55                   	push   %ebp
 20b:	89 e5                	mov    %esp,%ebp
 20d:	57                   	push   %edi
 20e:	56                   	push   %esi
 20f:	53                   	push   %ebx
 210:	83 ec 2c             	sub    $0x2c,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 213:	bb 00 00 00 00       	mov    $0x0,%ebx
    cc = read(0, &c, 1);
 218:	8d 7d e7             	lea    -0x19(%ebp),%edi
  for(i=0; i+1 < max; ){
 21b:	eb 36                	jmp    253 <gets+0x49>
    cc = read(0, &c, 1);
 21d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 224:	00 
 225:	89 7c 24 04          	mov    %edi,0x4(%esp)
 229:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 230:	e8 f8 00 00 00       	call   32d <read>
    if(cc < 1)
 235:	85 c0                	test   %eax,%eax
 237:	7e 26                	jle    25f <gets+0x55>
      break;
    buf[i++] = c;
 239:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 23d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 240:	88 04 19             	mov    %al,(%ecx,%ebx,1)
    if(c == '\n' || c == '\r')
 243:	3c 0a                	cmp    $0xa,%al
 245:	0f 94 c2             	sete   %dl
 248:	3c 0d                	cmp    $0xd,%al
 24a:	0f 94 c0             	sete   %al
    buf[i++] = c;
 24d:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 24f:	08 c2                	or     %al,%dl
 251:	75 0a                	jne    25d <gets+0x53>
  for(i=0; i+1 < max; ){
 253:	8d 73 01             	lea    0x1(%ebx),%esi
 256:	3b 75 0c             	cmp    0xc(%ebp),%esi
 259:	7c c2                	jl     21d <gets+0x13>
 25b:	eb 02                	jmp    25f <gets+0x55>
    buf[i++] = c;
 25d:	89 f3                	mov    %esi,%ebx
      break;
  }
  buf[i] = '\0';
 25f:	8b 45 08             	mov    0x8(%ebp),%eax
 262:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
  return buf;
}
 266:	83 c4 2c             	add    $0x2c,%esp
 269:	5b                   	pop    %ebx
 26a:	5e                   	pop    %esi
 26b:	5f                   	pop    %edi
 26c:	5d                   	pop    %ebp
 26d:	c3                   	ret    

0000026e <stat>:

int
stat(const char *n, struct stat *st)
{
 26e:	55                   	push   %ebp
 26f:	89 e5                	mov    %esp,%ebp
 271:	56                   	push   %esi
 272:	53                   	push   %ebx
 273:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 276:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 27d:	00 
 27e:	8b 45 08             	mov    0x8(%ebp),%eax
 281:	89 04 24             	mov    %eax,(%esp)
 284:	e8 cc 00 00 00       	call   355 <open>
 289:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 28b:	85 c0                	test   %eax,%eax
 28d:	78 1d                	js     2ac <stat+0x3e>
    return -1;
  r = fstat(fd, st);
 28f:	8b 45 0c             	mov    0xc(%ebp),%eax
 292:	89 44 24 04          	mov    %eax,0x4(%esp)
 296:	89 1c 24             	mov    %ebx,(%esp)
 299:	e8 cf 00 00 00       	call   36d <fstat>
 29e:	89 c6                	mov    %eax,%esi
  close(fd);
 2a0:	89 1c 24             	mov    %ebx,(%esp)
 2a3:	e8 95 00 00 00       	call   33d <close>
  return r;
 2a8:	89 f0                	mov    %esi,%eax
 2aa:	eb 05                	jmp    2b1 <stat+0x43>
    return -1;
 2ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
 2b1:	83 c4 10             	add    $0x10,%esp
 2b4:	5b                   	pop    %ebx
 2b5:	5e                   	pop    %esi
 2b6:	5d                   	pop    %ebp
 2b7:	c3                   	ret    

000002b8 <atoi>:

int
atoi(const char *s)
{
 2b8:	55                   	push   %ebp
 2b9:	89 e5                	mov    %esp,%ebp
 2bb:	53                   	push   %ebx
 2bc:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  n = 0;
 2bf:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 2c4:	eb 0f                	jmp    2d5 <atoi+0x1d>
    n = n*10 + *s++ - '0';
 2c6:	8d 04 80             	lea    (%eax,%eax,4),%eax
 2c9:	01 c0                	add    %eax,%eax
 2cb:	83 c2 01             	add    $0x1,%edx
 2ce:	0f be c9             	movsbl %cl,%ecx
 2d1:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
  while('0' <= *s && *s <= '9')
 2d5:	0f b6 0a             	movzbl (%edx),%ecx
 2d8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
 2db:	80 fb 09             	cmp    $0x9,%bl
 2de:	76 e6                	jbe    2c6 <atoi+0xe>
  return n;
}
 2e0:	5b                   	pop    %ebx
 2e1:	5d                   	pop    %ebp
 2e2:	c3                   	ret    

000002e3 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2e3:	55                   	push   %ebp
 2e4:	89 e5                	mov    %esp,%ebp
 2e6:	56                   	push   %esi
 2e7:	53                   	push   %ebx
 2e8:	8b 45 08             	mov    0x8(%ebp),%eax
 2eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 2ee:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 2f1:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 2f3:	eb 0d                	jmp    302 <memmove+0x1f>
    *dst++ = *src++;
 2f5:	0f b6 13             	movzbl (%ebx),%edx
 2f8:	88 11                	mov    %dl,(%ecx)
  while(n-- > 0)
 2fa:	89 f2                	mov    %esi,%edx
    *dst++ = *src++;
 2fc:	8d 5b 01             	lea    0x1(%ebx),%ebx
 2ff:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 302:	8d 72 ff             	lea    -0x1(%edx),%esi
 305:	85 d2                	test   %edx,%edx
 307:	7f ec                	jg     2f5 <memmove+0x12>
  return vdst;
}
 309:	5b                   	pop    %ebx
 30a:	5e                   	pop    %esi
 30b:	5d                   	pop    %ebp
 30c:	c3                   	ret    

0000030d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 30d:	b8 01 00 00 00       	mov    $0x1,%eax
 312:	cd 40                	int    $0x40
 314:	c3                   	ret    

00000315 <exit>:
SYSCALL(exit)
 315:	b8 02 00 00 00       	mov    $0x2,%eax
 31a:	cd 40                	int    $0x40
 31c:	c3                   	ret    

0000031d <wait>:
SYSCALL(wait)
 31d:	b8 03 00 00 00       	mov    $0x3,%eax
 322:	cd 40                	int    $0x40
 324:	c3                   	ret    

00000325 <pipe>:
SYSCALL(pipe)
 325:	b8 04 00 00 00       	mov    $0x4,%eax
 32a:	cd 40                	int    $0x40
 32c:	c3                   	ret    

0000032d <read>:
SYSCALL(read)
 32d:	b8 05 00 00 00       	mov    $0x5,%eax
 332:	cd 40                	int    $0x40
 334:	c3                   	ret    

00000335 <write>:
SYSCALL(write)
 335:	b8 10 00 00 00       	mov    $0x10,%eax
 33a:	cd 40                	int    $0x40
 33c:	c3                   	ret    

0000033d <close>:
SYSCALL(close)
 33d:	b8 15 00 00 00       	mov    $0x15,%eax
 342:	cd 40                	int    $0x40
 344:	c3                   	ret    

00000345 <kill>:
SYSCALL(kill)
 345:	b8 06 00 00 00       	mov    $0x6,%eax
 34a:	cd 40                	int    $0x40
 34c:	c3                   	ret    

0000034d <exec>:
SYSCALL(exec)
 34d:	b8 07 00 00 00       	mov    $0x7,%eax
 352:	cd 40                	int    $0x40
 354:	c3                   	ret    

00000355 <open>:
SYSCALL(open)
 355:	b8 0f 00 00 00       	mov    $0xf,%eax
 35a:	cd 40                	int    $0x40
 35c:	c3                   	ret    

0000035d <mknod>:
SYSCALL(mknod)
 35d:	b8 11 00 00 00       	mov    $0x11,%eax
 362:	cd 40                	int    $0x40
 364:	c3                   	ret    

00000365 <unlink>:
SYSCALL(unlink)
 365:	b8 12 00 00 00       	mov    $0x12,%eax
 36a:	cd 40                	int    $0x40
 36c:	c3                   	ret    

0000036d <fstat>:
SYSCALL(fstat)
 36d:	b8 08 00 00 00       	mov    $0x8,%eax
 372:	cd 40                	int    $0x40
 374:	c3                   	ret    

00000375 <link>:
SYSCALL(link)
 375:	b8 13 00 00 00       	mov    $0x13,%eax
 37a:	cd 40                	int    $0x40
 37c:	c3                   	ret    

0000037d <mkdir>:
SYSCALL(mkdir)
 37d:	b8 14 00 00 00       	mov    $0x14,%eax
 382:	cd 40                	int    $0x40
 384:	c3                   	ret    

00000385 <chdir>:
SYSCALL(chdir)
 385:	b8 09 00 00 00       	mov    $0x9,%eax
 38a:	cd 40                	int    $0x40
 38c:	c3                   	ret    

0000038d <dup>:
SYSCALL(dup)
 38d:	b8 0a 00 00 00       	mov    $0xa,%eax
 392:	cd 40                	int    $0x40
 394:	c3                   	ret    

00000395 <getpid>:
SYSCALL(getpid)
 395:	b8 0b 00 00 00       	mov    $0xb,%eax
 39a:	cd 40                	int    $0x40
 39c:	c3                   	ret    

0000039d <sbrk>:
SYSCALL(sbrk)
 39d:	b8 0c 00 00 00       	mov    $0xc,%eax
 3a2:	cd 40                	int    $0x40
 3a4:	c3                   	ret    

000003a5 <sleep>:
SYSCALL(sleep)
 3a5:	b8 0d 00 00 00       	mov    $0xd,%eax
 3aa:	cd 40                	int    $0x40
 3ac:	c3                   	ret    

000003ad <uptime>:
SYSCALL(uptime)
 3ad:	b8 0e 00 00 00       	mov    $0xe,%eax
 3b2:	cd 40                	int    $0x40
 3b4:	c3                   	ret    

000003b5 <yield>:
SYSCALL(yield)
 3b5:	b8 16 00 00 00       	mov    $0x16,%eax
 3ba:	cd 40                	int    $0x40
 3bc:	c3                   	ret    

000003bd <shutdown>:
SYSCALL(shutdown)
 3bd:	b8 17 00 00 00       	mov    $0x17,%eax
 3c2:	cd 40                	int    $0x40
 3c4:	c3                   	ret    

000003c5 <writecount>:
SYSCALL(writecount)
 3c5:	b8 18 00 00 00       	mov    $0x18,%eax
 3ca:	cd 40                	int    $0x40
 3cc:	c3                   	ret    

000003cd <setwritecount>:
SYSCALL(setwritecount)
 3cd:	b8 19 00 00 00       	mov    $0x19,%eax
 3d2:	cd 40                	int    $0x40
 3d4:	c3                   	ret    
 3d5:	66 90                	xchg   %ax,%ax
 3d7:	66 90                	xchg   %ax,%ax
 3d9:	66 90                	xchg   %ax,%ax
 3db:	66 90                	xchg   %ax,%ax
 3dd:	66 90                	xchg   %ax,%ax
 3df:	90                   	nop

000003e0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3e0:	55                   	push   %ebp
 3e1:	89 e5                	mov    %esp,%ebp
 3e3:	83 ec 18             	sub    $0x18,%esp
 3e6:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 3e9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3f0:	00 
 3f1:	8d 55 f4             	lea    -0xc(%ebp),%edx
 3f4:	89 54 24 04          	mov    %edx,0x4(%esp)
 3f8:	89 04 24             	mov    %eax,(%esp)
 3fb:	e8 35 ff ff ff       	call   335 <write>
}
 400:	c9                   	leave  
 401:	c3                   	ret    

00000402 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 402:	55                   	push   %ebp
 403:	89 e5                	mov    %esp,%ebp
 405:	57                   	push   %edi
 406:	56                   	push   %esi
 407:	53                   	push   %ebx
 408:	83 ec 2c             	sub    $0x2c,%esp
 40b:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 40d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 411:	0f 95 c3             	setne  %bl
 414:	89 d0                	mov    %edx,%eax
 416:	c1 e8 1f             	shr    $0x1f,%eax
 419:	84 c3                	test   %al,%bl
 41b:	74 0b                	je     428 <printint+0x26>
    neg = 1;
    x = -xx;
 41d:	f7 da                	neg    %edx
    neg = 1;
 41f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
 426:	eb 07                	jmp    42f <printint+0x2d>
  neg = 0;
 428:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 42f:	be 00 00 00 00       	mov    $0x0,%esi
  do{
    buf[i++] = digits[x % base];
 434:	8d 5e 01             	lea    0x1(%esi),%ebx
 437:	89 d0                	mov    %edx,%eax
 439:	ba 00 00 00 00       	mov    $0x0,%edx
 43e:	f7 f1                	div    %ecx
 440:	0f b6 92 13 06 00 00 	movzbl 0x613(%edx),%edx
 447:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 44b:	89 c2                	mov    %eax,%edx
    buf[i++] = digits[x % base];
 44d:	89 de                	mov    %ebx,%esi
  }while((x /= base) != 0);
 44f:	85 c0                	test   %eax,%eax
 451:	75 e1                	jne    434 <printint+0x32>
  if(neg)
 453:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 457:	74 16                	je     46f <printint+0x6d>
    buf[i++] = '-';
 459:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 45e:	8d 5b 01             	lea    0x1(%ebx),%ebx
 461:	eb 0c                	jmp    46f <printint+0x6d>

  while(--i >= 0)
    putc(fd, buf[i]);
 463:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 468:	89 f8                	mov    %edi,%eax
 46a:	e8 71 ff ff ff       	call   3e0 <putc>
  while(--i >= 0)
 46f:	83 eb 01             	sub    $0x1,%ebx
 472:	79 ef                	jns    463 <printint+0x61>
}
 474:	83 c4 2c             	add    $0x2c,%esp
 477:	5b                   	pop    %ebx
 478:	5e                   	pop    %esi
 479:	5f                   	pop    %edi
 47a:	5d                   	pop    %ebp
 47b:	c3                   	ret    

0000047c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 47c:	55                   	push   %ebp
 47d:	89 e5                	mov    %esp,%ebp
 47f:	57                   	push   %edi
 480:	56                   	push   %esi
 481:	53                   	push   %ebx
 482:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 485:	8d 45 10             	lea    0x10(%ebp),%eax
 488:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 48b:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i = 0; fmt[i]; i++){
 490:	be 00 00 00 00       	mov    $0x0,%esi
 495:	e9 23 01 00 00       	jmp    5bd <printf+0x141>
    c = fmt[i] & 0xff;
 49a:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 49d:	85 ff                	test   %edi,%edi
 49f:	75 19                	jne    4ba <printf+0x3e>
      if(c == '%'){
 4a1:	83 f8 25             	cmp    $0x25,%eax
 4a4:	0f 84 0b 01 00 00    	je     5b5 <printf+0x139>
        state = '%';
      } else {
        putc(fd, c);
 4aa:	0f be d3             	movsbl %bl,%edx
 4ad:	8b 45 08             	mov    0x8(%ebp),%eax
 4b0:	e8 2b ff ff ff       	call   3e0 <putc>
 4b5:	e9 00 01 00 00       	jmp    5ba <printf+0x13e>
      }
    } else if(state == '%'){
 4ba:	83 ff 25             	cmp    $0x25,%edi
 4bd:	0f 85 f7 00 00 00    	jne    5ba <printf+0x13e>
      if(c == 'd'){
 4c3:	83 f8 64             	cmp    $0x64,%eax
 4c6:	75 26                	jne    4ee <printf+0x72>
        printint(fd, *ap, 10, 1);
 4c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4cb:	8b 10                	mov    (%eax),%edx
 4cd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 4d4:	b9 0a 00 00 00       	mov    $0xa,%ecx
 4d9:	8b 45 08             	mov    0x8(%ebp),%eax
 4dc:	e8 21 ff ff ff       	call   402 <printint>
        ap++;
 4e1:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4e5:	66 bf 00 00          	mov    $0x0,%di
 4e9:	e9 cc 00 00 00       	jmp    5ba <printf+0x13e>
      } else if(c == 'x' || c == 'p'){
 4ee:	83 f8 78             	cmp    $0x78,%eax
 4f1:	0f 94 c1             	sete   %cl
 4f4:	83 f8 70             	cmp    $0x70,%eax
 4f7:	0f 94 c2             	sete   %dl
 4fa:	08 d1                	or     %dl,%cl
 4fc:	74 27                	je     525 <printf+0xa9>
        printint(fd, *ap, 16, 0);
 4fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 501:	8b 10                	mov    (%eax),%edx
 503:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 50a:	b9 10 00 00 00       	mov    $0x10,%ecx
 50f:	8b 45 08             	mov    0x8(%ebp),%eax
 512:	e8 eb fe ff ff       	call   402 <printint>
        ap++;
 517:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 51b:	bf 00 00 00 00       	mov    $0x0,%edi
 520:	e9 95 00 00 00       	jmp    5ba <printf+0x13e>
      } else if(c == 's'){
 525:	83 f8 73             	cmp    $0x73,%eax
 528:	75 37                	jne    561 <printf+0xe5>
        s = (char*)*ap;
 52a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 52d:	8b 18                	mov    (%eax),%ebx
        ap++;
 52f:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
        if(s == 0)
 533:	85 db                	test   %ebx,%ebx
 535:	75 19                	jne    550 <printf+0xd4>
          s = "(null)";
 537:	bb 0c 06 00 00       	mov    $0x60c,%ebx
 53c:	8b 7d 08             	mov    0x8(%ebp),%edi
 53f:	eb 12                	jmp    553 <printf+0xd7>
          putc(fd, *s);
 541:	0f be d2             	movsbl %dl,%edx
 544:	89 f8                	mov    %edi,%eax
 546:	e8 95 fe ff ff       	call   3e0 <putc>
          s++;
 54b:	83 c3 01             	add    $0x1,%ebx
 54e:	eb 03                	jmp    553 <printf+0xd7>
 550:	8b 7d 08             	mov    0x8(%ebp),%edi
        while(*s != 0){
 553:	0f b6 13             	movzbl (%ebx),%edx
 556:	84 d2                	test   %dl,%dl
 558:	75 e7                	jne    541 <printf+0xc5>
      state = 0;
 55a:	bf 00 00 00 00       	mov    $0x0,%edi
 55f:	eb 59                	jmp    5ba <printf+0x13e>
      } else if(c == 'c'){
 561:	83 f8 63             	cmp    $0x63,%eax
 564:	75 19                	jne    57f <printf+0x103>
        putc(fd, *ap);
 566:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 569:	0f be 10             	movsbl (%eax),%edx
 56c:	8b 45 08             	mov    0x8(%ebp),%eax
 56f:	e8 6c fe ff ff       	call   3e0 <putc>
        ap++;
 574:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 578:	bf 00 00 00 00       	mov    $0x0,%edi
 57d:	eb 3b                	jmp    5ba <printf+0x13e>
      } else if(c == '%'){
 57f:	83 f8 25             	cmp    $0x25,%eax
 582:	75 12                	jne    596 <printf+0x11a>
        putc(fd, c);
 584:	0f be d3             	movsbl %bl,%edx
 587:	8b 45 08             	mov    0x8(%ebp),%eax
 58a:	e8 51 fe ff ff       	call   3e0 <putc>
      state = 0;
 58f:	bf 00 00 00 00       	mov    $0x0,%edi
 594:	eb 24                	jmp    5ba <printf+0x13e>
        putc(fd, '%');
 596:	ba 25 00 00 00       	mov    $0x25,%edx
 59b:	8b 45 08             	mov    0x8(%ebp),%eax
 59e:	e8 3d fe ff ff       	call   3e0 <putc>
        putc(fd, c);
 5a3:	0f be d3             	movsbl %bl,%edx
 5a6:	8b 45 08             	mov    0x8(%ebp),%eax
 5a9:	e8 32 fe ff ff       	call   3e0 <putc>
      state = 0;
 5ae:	bf 00 00 00 00       	mov    $0x0,%edi
 5b3:	eb 05                	jmp    5ba <printf+0x13e>
        state = '%';
 5b5:	bf 25 00 00 00       	mov    $0x25,%edi
  for(i = 0; fmt[i]; i++){
 5ba:	83 c6 01             	add    $0x1,%esi
 5bd:	89 f0                	mov    %esi,%eax
 5bf:	03 45 0c             	add    0xc(%ebp),%eax
 5c2:	0f b6 18             	movzbl (%eax),%ebx
 5c5:	84 db                	test   %bl,%bl
 5c7:	0f 85 cd fe ff ff    	jne    49a <printf+0x1e>
    }
  }
}
 5cd:	83 c4 1c             	add    $0x1c,%esp
 5d0:	5b                   	pop    %ebx
 5d1:	5e                   	pop    %esi
 5d2:	5f                   	pop    %edi
 5d3:	5d                   	pop    %ebp
 5d4:	c3                   	ret    
