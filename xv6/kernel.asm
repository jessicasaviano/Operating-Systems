
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 90 10 00       	mov    $0x109000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc d0 b5 10 80       	mov    $0x8010b5d0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 1b 2b 10 80       	mov    $0x80102b1b,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	57                   	push   %edi
80100038:	56                   	push   %esi
80100039:	53                   	push   %ebx
8010003a:	83 ec 1c             	sub    $0x1c,%esp
8010003d:	89 c6                	mov    %eax,%esi
8010003f:	89 d7                	mov    %edx,%edi
  struct buf *b;

  acquire(&bcache.lock);
80100041:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100048:	e8 0f 3c 00 00       	call   80103c5c <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010004d:	8b 1d 30 fd 10 80    	mov    0x8010fd30,%ebx
80100053:	eb 2c                	jmp    80100081 <bget+0x4d>
    if(b->dev == dev && b->blockno == blockno){
80100055:	39 73 04             	cmp    %esi,0x4(%ebx)
80100058:	75 24                	jne    8010007e <bget+0x4a>
8010005a:	39 7b 08             	cmp    %edi,0x8(%ebx)
8010005d:	75 1f                	jne    8010007e <bget+0x4a>
      b->refcnt++;
8010005f:	83 43 4c 01          	addl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
80100063:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
8010006a:	e8 4e 3c 00 00       	call   80103cbd <release>
      acquiresleep(&b->lock);
8010006f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100072:	89 04 24             	mov    %eax,(%esp)
80100075:	e8 db 39 00 00       	call   80103a55 <acquiresleep>
      return b;
8010007a:	89 d8                	mov    %ebx,%eax
8010007c:	eb 63                	jmp    801000e1 <bget+0xad>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010007e:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100081:	81 fb dc fc 10 80    	cmp    $0x8010fcdc,%ebx
80100087:	75 cc                	jne    80100055 <bget+0x21>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100089:	8b 1d 2c fd 10 80    	mov    0x8010fd2c,%ebx
8010008f:	eb 3c                	jmp    801000cd <bget+0x99>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
80100091:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80100095:	75 33                	jne    801000ca <bget+0x96>
80100097:	f6 03 04             	testb  $0x4,(%ebx)
8010009a:	75 2e                	jne    801000ca <bget+0x96>
      b->dev = dev;
8010009c:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
8010009f:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
801000a2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
801000a8:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
801000af:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801000b6:	e8 02 3c 00 00       	call   80103cbd <release>
      acquiresleep(&b->lock);
801000bb:	8d 43 0c             	lea    0xc(%ebx),%eax
801000be:	89 04 24             	mov    %eax,(%esp)
801000c1:	e8 8f 39 00 00       	call   80103a55 <acquiresleep>
      return b;
801000c6:	89 d8                	mov    %ebx,%eax
801000c8:	eb 17                	jmp    801000e1 <bget+0xad>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801000ca:	8b 5b 50             	mov    0x50(%ebx),%ebx
801000cd:	81 fb dc fc 10 80    	cmp    $0x8010fcdc,%ebx
801000d3:	75 bc                	jne    80100091 <bget+0x5d>
    }
  }
  panic("bget: no buffers");
801000d5:	c7 04 24 e0 65 10 80 	movl   $0x801065e0,(%esp)
801000dc:	e8 44 02 00 00       	call   80100325 <panic>
}
801000e1:	83 c4 1c             	add    $0x1c,%esp
801000e4:	5b                   	pop    %ebx
801000e5:	5e                   	pop    %esi
801000e6:	5f                   	pop    %edi
801000e7:	5d                   	pop    %ebp
801000e8:	c3                   	ret    

801000e9 <binit>:
{
801000e9:	55                   	push   %ebp
801000ea:	89 e5                	mov    %esp,%ebp
801000ec:	53                   	push   %ebx
801000ed:	83 ec 14             	sub    $0x14,%esp
  initlock(&bcache.lock, "bcache");
801000f0:	c7 44 24 04 f1 65 10 	movl   $0x801065f1,0x4(%esp)
801000f7:	80 
801000f8:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801000ff:	e8 20 3a 00 00       	call   80103b24 <initlock>
  bcache.head.prev = &bcache.head;
80100104:	c7 05 2c fd 10 80 dc 	movl   $0x8010fcdc,0x8010fd2c
8010010b:	fc 10 80 
  bcache.head.next = &bcache.head;
8010010e:	c7 05 30 fd 10 80 dc 	movl   $0x8010fcdc,0x8010fd30
80100115:	fc 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100118:	bb 14 b6 10 80       	mov    $0x8010b614,%ebx
8010011d:	eb 36                	jmp    80100155 <binit+0x6c>
    b->next = bcache.head.next;
8010011f:	a1 30 fd 10 80       	mov    0x8010fd30,%eax
80100124:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100127:	c7 43 50 dc fc 10 80 	movl   $0x8010fcdc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
8010012e:	c7 44 24 04 f8 65 10 	movl   $0x801065f8,0x4(%esp)
80100135:	80 
80100136:	8d 43 0c             	lea    0xc(%ebx),%eax
80100139:	89 04 24             	mov    %eax,(%esp)
8010013c:	e8 de 38 00 00       	call   80103a1f <initsleeplock>
    bcache.head.next->prev = b;
80100141:	a1 30 fd 10 80       	mov    0x8010fd30,%eax
80100146:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100149:	89 1d 30 fd 10 80    	mov    %ebx,0x8010fd30
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010014f:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
80100155:	81 fb dc fc 10 80    	cmp    $0x8010fcdc,%ebx
8010015b:	72 c2                	jb     8010011f <binit+0x36>
}
8010015d:	83 c4 14             	add    $0x14,%esp
80100160:	5b                   	pop    %ebx
80100161:	5d                   	pop    %ebp
80100162:	c3                   	ret    

80100163 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100163:	55                   	push   %ebp
80100164:	89 e5                	mov    %esp,%ebp
80100166:	53                   	push   %ebx
80100167:	83 ec 14             	sub    $0x14,%esp
  struct buf *b;

  b = bget(dev, blockno);
8010016a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010016d:	8b 45 08             	mov    0x8(%ebp),%eax
80100170:	e8 bf fe ff ff       	call   80100034 <bget>
80100175:	89 c3                	mov    %eax,%ebx
  if((b->flags & B_VALID) == 0) {
80100177:	f6 00 02             	testb  $0x2,(%eax)
8010017a:	75 08                	jne    80100184 <bread+0x21>
    iderw(b);
8010017c:	89 04 24             	mov    %eax,(%esp)
8010017f:	e8 12 1d 00 00       	call   80101e96 <iderw>
  }
  return b;
}
80100184:	89 d8                	mov    %ebx,%eax
80100186:	83 c4 14             	add    $0x14,%esp
80100189:	5b                   	pop    %ebx
8010018a:	5d                   	pop    %ebp
8010018b:	c3                   	ret    

8010018c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010018c:	55                   	push   %ebp
8010018d:	89 e5                	mov    %esp,%ebp
8010018f:	53                   	push   %ebx
80100190:	83 ec 14             	sub    $0x14,%esp
80100193:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
80100196:	8d 43 0c             	lea    0xc(%ebx),%eax
80100199:	89 04 24             	mov    %eax,(%esp)
8010019c:	e8 37 39 00 00       	call   80103ad8 <holdingsleep>
801001a1:	85 c0                	test   %eax,%eax
801001a3:	75 0c                	jne    801001b1 <bwrite+0x25>
    panic("bwrite");
801001a5:	c7 04 24 ff 65 10 80 	movl   $0x801065ff,(%esp)
801001ac:	e8 74 01 00 00       	call   80100325 <panic>
  b->flags |= B_DIRTY;
801001b1:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001b4:	89 1c 24             	mov    %ebx,(%esp)
801001b7:	e8 da 1c 00 00       	call   80101e96 <iderw>
}
801001bc:	83 c4 14             	add    $0x14,%esp
801001bf:	5b                   	pop    %ebx
801001c0:	5d                   	pop    %ebp
801001c1:	c3                   	ret    

801001c2 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001c2:	55                   	push   %ebp
801001c3:	89 e5                	mov    %esp,%ebp
801001c5:	56                   	push   %esi
801001c6:	53                   	push   %ebx
801001c7:	83 ec 10             	sub    $0x10,%esp
801001ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001cd:	8d 73 0c             	lea    0xc(%ebx),%esi
801001d0:	89 34 24             	mov    %esi,(%esp)
801001d3:	e8 00 39 00 00       	call   80103ad8 <holdingsleep>
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0c                	jne    801001e8 <brelse+0x26>
    panic("brelse");
801001dc:	c7 04 24 06 66 10 80 	movl   $0x80106606,(%esp)
801001e3:	e8 3d 01 00 00       	call   80100325 <panic>

  releasesleep(&b->lock);
801001e8:	89 34 24             	mov    %esi,(%esp)
801001eb:	e8 ae 38 00 00       	call   80103a9e <releasesleep>

  acquire(&bcache.lock);
801001f0:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801001f7:	e8 60 3a 00 00       	call   80103c5c <acquire>
  b->refcnt--;
801001fc:	8b 43 4c             	mov    0x4c(%ebx),%eax
801001ff:	83 e8 01             	sub    $0x1,%eax
80100202:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
80100205:	85 c0                	test   %eax,%eax
80100207:	75 2f                	jne    80100238 <brelse+0x76>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100209:	8b 43 54             	mov    0x54(%ebx),%eax
8010020c:	8b 53 50             	mov    0x50(%ebx),%edx
8010020f:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
80100212:	8b 43 50             	mov    0x50(%ebx),%eax
80100215:	8b 53 54             	mov    0x54(%ebx),%edx
80100218:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
8010021b:	a1 30 fd 10 80       	mov    0x8010fd30,%eax
80100220:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100223:	c7 43 50 dc fc 10 80 	movl   $0x8010fcdc,0x50(%ebx)
    bcache.head.next->prev = b;
8010022a:	a1 30 fd 10 80       	mov    0x8010fd30,%eax
8010022f:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100232:	89 1d 30 fd 10 80    	mov    %ebx,0x8010fd30
  }
  
  release(&bcache.lock);
80100238:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
8010023f:	e8 79 3a 00 00       	call   80103cbd <release>
}
80100244:	83 c4 10             	add    $0x10,%esp
80100247:	5b                   	pop    %ebx
80100248:	5e                   	pop    %esi
80100249:	5d                   	pop    %ebp
8010024a:	c3                   	ret    
8010024b:	66 90                	xchg   %ax,%ax
8010024d:	66 90                	xchg   %ax,%ax
8010024f:	90                   	nop

80100250 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100250:	55                   	push   %ebp
80100251:	89 e5                	mov    %esp,%ebp
80100253:	57                   	push   %edi
80100254:	56                   	push   %esi
80100255:	53                   	push   %ebx
80100256:	83 ec 1c             	sub    $0x1c,%esp
80100259:	8b 75 0c             	mov    0xc(%ebp),%esi
8010025c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  uint target;
  int c;

  iunlock(ip);
8010025f:	8b 45 08             	mov    0x8(%ebp),%eax
80100262:	89 04 24             	mov    %eax,(%esp)
80100265:	e8 5e 14 00 00       	call   801016c8 <iunlock>
  target = n;
8010026a:	89 df                	mov    %ebx,%edi
  acquire(&cons.lock);
8010026c:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
80100273:	e8 e4 39 00 00       	call   80103c5c <acquire>
  while(n > 0){
80100278:	e9 81 00 00 00       	jmp    801002fe <consoleread+0xae>
    while(input.r == input.w){
      if(myproc()->killed){
8010027d:	e8 43 30 00 00       	call   801032c5 <myproc>
80100282:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80100286:	74 1e                	je     801002a6 <consoleread+0x56>
        release(&cons.lock);
80100288:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
8010028f:	e8 29 3a 00 00       	call   80103cbd <release>
        ilock(ip);
80100294:	8b 45 08             	mov    0x8(%ebp),%eax
80100297:	89 04 24             	mov    %eax,(%esp)
8010029a:	e8 62 13 00 00       	call   80101601 <ilock>
        return -1;
8010029f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801002a4:	eb 77                	jmp    8010031d <consoleread+0xcd>
      }
      sleep(&input.r, &cons.lock);
801002a6:	c7 44 24 04 20 a5 10 	movl   $0x8010a520,0x4(%esp)
801002ad:	80 
801002ae:	c7 04 24 c0 ff 10 80 	movl   $0x8010ffc0,(%esp)
801002b5:	e8 b1 34 00 00       	call   8010376b <sleep>
    while(input.r == input.w){
801002ba:	a1 c0 ff 10 80       	mov    0x8010ffc0,%eax
801002bf:	3b 05 c4 ff 10 80    	cmp    0x8010ffc4,%eax
801002c5:	74 b6                	je     8010027d <consoleread+0x2d>
    }
    c = input.buf[input.r++ % INPUT_BUF];
801002c7:	8d 50 01             	lea    0x1(%eax),%edx
801002ca:	89 15 c0 ff 10 80    	mov    %edx,0x8010ffc0
801002d0:	89 c2                	mov    %eax,%edx
801002d2:	83 e2 7f             	and    $0x7f,%edx
801002d5:	0f b6 8a 40 ff 10 80 	movzbl -0x7fef00c0(%edx),%ecx
801002dc:	0f be d1             	movsbl %cl,%edx
    if(c == C('D')){  // EOF
801002df:	83 fa 04             	cmp    $0x4,%edx
801002e2:	75 0b                	jne    801002ef <consoleread+0x9f>
      if(n < target){
801002e4:	39 fb                	cmp    %edi,%ebx
801002e6:	73 1a                	jae    80100302 <consoleread+0xb2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801002e8:	a3 c0 ff 10 80       	mov    %eax,0x8010ffc0
801002ed:	eb 13                	jmp    80100302 <consoleread+0xb2>
      }
      break;
    }
    *dst++ = c;
801002ef:	8d 46 01             	lea    0x1(%esi),%eax
801002f2:	88 0e                	mov    %cl,(%esi)
    --n;
801002f4:	83 eb 01             	sub    $0x1,%ebx
    if(c == '\n')
801002f7:	83 fa 0a             	cmp    $0xa,%edx
801002fa:	74 06                	je     80100302 <consoleread+0xb2>
    *dst++ = c;
801002fc:	89 c6                	mov    %eax,%esi
  while(n > 0){
801002fe:	85 db                	test   %ebx,%ebx
80100300:	7f b8                	jg     801002ba <consoleread+0x6a>
      break;
  }
  release(&cons.lock);
80100302:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
80100309:	e8 af 39 00 00       	call   80103cbd <release>
  ilock(ip);
8010030e:	8b 45 08             	mov    0x8(%ebp),%eax
80100311:	89 04 24             	mov    %eax,(%esp)
80100314:	e8 e8 12 00 00       	call   80101601 <ilock>

  return target - n;
80100319:	89 f8                	mov    %edi,%eax
8010031b:	29 d8                	sub    %ebx,%eax
}
8010031d:	83 c4 1c             	add    $0x1c,%esp
80100320:	5b                   	pop    %ebx
80100321:	5e                   	pop    %esi
80100322:	5f                   	pop    %edi
80100323:	5d                   	pop    %ebp
80100324:	c3                   	ret    

80100325 <panic>:
{
80100325:	55                   	push   %ebp
80100326:	89 e5                	mov    %esp,%ebp
80100328:	53                   	push   %ebx
80100329:	83 ec 44             	sub    $0x44,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
8010032c:	fa                   	cli    
  cons.locking = 0;
8010032d:	c7 05 54 a5 10 80 00 	movl   $0x0,0x8010a554
80100334:	00 00 00 
  cprintf("lapicid %d: panic: ", lapicid());
80100337:	e8 dc 20 00 00       	call   80102418 <lapicid>
8010033c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100340:	c7 04 24 0d 66 10 80 	movl   $0x8010660d,(%esp)
80100347:	e8 7b 02 00 00       	call   801005c7 <cprintf>
  cprintf(s);
8010034c:	8b 45 08             	mov    0x8(%ebp),%eax
8010034f:	89 04 24             	mov    %eax,(%esp)
80100352:	e8 70 02 00 00       	call   801005c7 <cprintf>
  cprintf("\n");
80100357:	c7 04 24 27 70 10 80 	movl   $0x80107027,(%esp)
8010035e:	e8 64 02 00 00       	call   801005c7 <cprintf>
  getcallerpcs(&s, pcs);
80100363:	8d 45 d0             	lea    -0x30(%ebp),%eax
80100366:	89 44 24 04          	mov    %eax,0x4(%esp)
8010036a:	8d 45 08             	lea    0x8(%ebp),%eax
8010036d:	89 04 24             	mov    %eax,(%esp)
80100370:	e8 ca 37 00 00       	call   80103b3f <getcallerpcs>
  for(i=0; i<10; i++)
80100375:	bb 00 00 00 00       	mov    $0x0,%ebx
8010037a:	eb 17                	jmp    80100393 <panic+0x6e>
    cprintf(" %p", pcs[i]);
8010037c:	8b 44 9d d0          	mov    -0x30(%ebp,%ebx,4),%eax
80100380:	89 44 24 04          	mov    %eax,0x4(%esp)
80100384:	c7 04 24 21 66 10 80 	movl   $0x80106621,(%esp)
8010038b:	e8 37 02 00 00       	call   801005c7 <cprintf>
  for(i=0; i<10; i++)
80100390:	83 c3 01             	add    $0x1,%ebx
80100393:	83 fb 09             	cmp    $0x9,%ebx
80100396:	7e e4                	jle    8010037c <panic+0x57>
  panicked = 1; // freeze other CPU
80100398:	c7 05 58 a5 10 80 01 	movl   $0x1,0x8010a558
8010039f:	00 00 00 
801003a2:	eb fe                	jmp    801003a2 <panic+0x7d>

801003a4 <cgaputc>:
{
801003a4:	55                   	push   %ebp
801003a5:	89 e5                	mov    %esp,%ebp
801003a7:	56                   	push   %esi
801003a8:	53                   	push   %ebx
801003a9:	83 ec 10             	sub    $0x10,%esp
801003ac:	89 c1                	mov    %eax,%ecx
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003ae:	ba d4 03 00 00       	mov    $0x3d4,%edx
801003b3:	b8 0e 00 00 00       	mov    $0xe,%eax
801003b8:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003b9:	bb d5 03 00 00       	mov    $0x3d5,%ebx
801003be:	89 da                	mov    %ebx,%edx
801003c0:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
801003c1:	0f b6 f0             	movzbl %al,%esi
801003c4:	c1 e6 08             	shl    $0x8,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003c7:	b2 d4                	mov    $0xd4,%dl
801003c9:	b8 0f 00 00 00       	mov    $0xf,%eax
801003ce:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003cf:	89 da                	mov    %ebx,%edx
801003d1:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
801003d2:	0f b6 c0             	movzbl %al,%eax
801003d5:	09 f0                	or     %esi,%eax
  if(c == '\n')
801003d7:	83 f9 0a             	cmp    $0xa,%ecx
801003da:	75 17                	jne    801003f3 <cgaputc+0x4f>
    pos += 80 - pos%80;
801003dc:	ba 67 66 66 66       	mov    $0x66666667,%edx
801003e1:	f7 ea                	imul   %edx
801003e3:	89 d0                	mov    %edx,%eax
801003e5:	c1 f8 05             	sar    $0x5,%eax
801003e8:	8d 04 80             	lea    (%eax,%eax,4),%eax
801003eb:	c1 e0 04             	shl    $0x4,%eax
801003ee:	8d 58 50             	lea    0x50(%eax),%ebx
801003f1:	eb 26                	jmp    80100419 <cgaputc+0x75>
  else if(c == BACKSPACE){
801003f3:	81 f9 00 01 00 00    	cmp    $0x100,%ecx
801003f9:	75 09                	jne    80100404 <cgaputc+0x60>
    if(pos > 0) --pos;
801003fb:	85 c0                	test   %eax,%eax
801003fd:	7e 18                	jle    80100417 <cgaputc+0x73>
801003ff:	8d 58 ff             	lea    -0x1(%eax),%ebx
80100402:	eb 15                	jmp    80100419 <cgaputc+0x75>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100404:	8d 58 01             	lea    0x1(%eax),%ebx
80100407:	0f b6 c9             	movzbl %cl,%ecx
8010040a:	80 cd 07             	or     $0x7,%ch
8010040d:	66 89 8c 00 00 80 0b 	mov    %cx,-0x7ff48000(%eax,%eax,1)
80100414:	80 
80100415:	eb 02                	jmp    80100419 <cgaputc+0x75>
  pos |= inb(CRTPORT+1);
80100417:	89 c3                	mov    %eax,%ebx
  if(pos < 0 || pos > 25*80)
80100419:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
8010041f:	76 0c                	jbe    8010042d <cgaputc+0x89>
    panic("pos under/overflow");
80100421:	c7 04 24 25 66 10 80 	movl   $0x80106625,(%esp)
80100428:	e8 f8 fe ff ff       	call   80100325 <panic>
  if((pos/80) >= 24){  // Scroll up.
8010042d:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
80100433:	7e 45                	jle    8010047a <cgaputc+0xd6>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100435:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
8010043c:	00 
8010043d:	c7 44 24 04 a0 80 0b 	movl   $0x800b80a0,0x4(%esp)
80100444:	80 
80100445:	c7 04 24 00 80 0b 80 	movl   $0x800b8000,(%esp)
8010044c:	e8 3c 39 00 00       	call   80103d8d <memmove>
    pos -= 80;
80100451:	8d 73 b0             	lea    -0x50(%ebx),%esi
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100454:	b8 d0 07 00 00       	mov    $0x7d0,%eax
80100459:	29 d8                	sub    %ebx,%eax
8010045b:	01 c0                	add    %eax,%eax
8010045d:	89 44 24 08          	mov    %eax,0x8(%esp)
80100461:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100468:	00 
80100469:	8d 84 36 00 80 0b 80 	lea    -0x7ff48000(%esi,%esi,1),%eax
80100470:	89 04 24             	mov    %eax,(%esp)
80100473:	e8 98 38 00 00       	call   80103d10 <memset>
    pos -= 80;
80100478:	89 f3                	mov    %esi,%ebx
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010047a:	ba d4 03 00 00       	mov    $0x3d4,%edx
8010047f:	b8 0e 00 00 00       	mov    $0xe,%eax
80100484:	ee                   	out    %al,(%dx)
  outb(CRTPORT+1, pos>>8);
80100485:	0f b6 c7             	movzbl %bh,%eax
80100488:	b2 d5                	mov    $0xd5,%dl
8010048a:	ee                   	out    %al,(%dx)
8010048b:	b2 d4                	mov    $0xd4,%dl
8010048d:	b8 0f 00 00 00       	mov    $0xf,%eax
80100492:	ee                   	out    %al,(%dx)
80100493:	b2 d5                	mov    $0xd5,%dl
80100495:	89 d8                	mov    %ebx,%eax
80100497:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
80100498:	66 c7 84 1b 00 80 0b 	movw   $0x720,-0x7ff48000(%ebx,%ebx,1)
8010049f:	80 20 07 
}
801004a2:	83 c4 10             	add    $0x10,%esp
801004a5:	5b                   	pop    %ebx
801004a6:	5e                   	pop    %esi
801004a7:	5d                   	pop    %ebp
801004a8:	c3                   	ret    

801004a9 <consputc>:
  if(panicked){
801004a9:	83 3d 58 a5 10 80 00 	cmpl   $0x0,0x8010a558
801004b0:	74 03                	je     801004b5 <consputc+0xc>
  asm volatile("cli");
801004b2:	fa                   	cli    
801004b3:	eb fe                	jmp    801004b3 <consputc+0xa>
{
801004b5:	55                   	push   %ebp
801004b6:	89 e5                	mov    %esp,%ebp
801004b8:	53                   	push   %ebx
801004b9:	83 ec 14             	sub    $0x14,%esp
801004bc:	89 c3                	mov    %eax,%ebx
  if(c == BACKSPACE){
801004be:	3d 00 01 00 00       	cmp    $0x100,%eax
801004c3:	75 26                	jne    801004eb <consputc+0x42>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801004c5:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801004cc:	e8 62 4c 00 00       	call   80105133 <uartputc>
801004d1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801004d8:	e8 56 4c 00 00       	call   80105133 <uartputc>
801004dd:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801004e4:	e8 4a 4c 00 00       	call   80105133 <uartputc>
801004e9:	eb 08                	jmp    801004f3 <consputc+0x4a>
    uartputc(c);
801004eb:	89 04 24             	mov    %eax,(%esp)
801004ee:	e8 40 4c 00 00       	call   80105133 <uartputc>
  cgaputc(c);
801004f3:	89 d8                	mov    %ebx,%eax
801004f5:	e8 aa fe ff ff       	call   801003a4 <cgaputc>
}
801004fa:	83 c4 14             	add    $0x14,%esp
801004fd:	5b                   	pop    %ebx
801004fe:	5d                   	pop    %ebp
801004ff:	c3                   	ret    

80100500 <printint>:
{
80100500:	55                   	push   %ebp
80100501:	89 e5                	mov    %esp,%ebp
80100503:	57                   	push   %edi
80100504:	56                   	push   %esi
80100505:	53                   	push   %ebx
80100506:	83 ec 1c             	sub    $0x1c,%esp
80100509:	89 d7                	mov    %edx,%edi
  if(sign && (sign = xx < 0))
8010050b:	85 c9                	test   %ecx,%ecx
8010050d:	74 0f                	je     8010051e <printint+0x1e>
8010050f:	89 c1                	mov    %eax,%ecx
80100511:	c1 e9 1f             	shr    $0x1f,%ecx
80100514:	85 c9                	test   %ecx,%ecx
80100516:	74 06                	je     8010051e <printint+0x1e>
    x = -xx;
80100518:	f7 d8                	neg    %eax
8010051a:	89 c2                	mov    %eax,%edx
8010051c:	eb 02                	jmp    80100520 <printint+0x20>
    x = xx;
8010051e:	89 c2                	mov    %eax,%edx
  i = 0;
80100520:	be 00 00 00 00       	mov    $0x0,%esi
    buf[i++] = digits[x % base];
80100525:	8d 5e 01             	lea    0x1(%esi),%ebx
80100528:	89 d0                	mov    %edx,%eax
8010052a:	ba 00 00 00 00       	mov    $0x0,%edx
8010052f:	f7 f7                	div    %edi
80100531:	0f b6 92 50 66 10 80 	movzbl -0x7fef99b0(%edx),%edx
80100538:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
8010053c:	89 c2                	mov    %eax,%edx
    buf[i++] = digits[x % base];
8010053e:	89 de                	mov    %ebx,%esi
  }while((x /= base) != 0);
80100540:	85 c0                	test   %eax,%eax
80100542:	75 e1                	jne    80100525 <printint+0x25>
  if(sign)
80100544:	85 c9                	test   %ecx,%ecx
80100546:	74 14                	je     8010055c <printint+0x5c>
    buf[i++] = '-';
80100548:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
8010054d:	8d 5b 01             	lea    0x1(%ebx),%ebx
80100550:	eb 0a                	jmp    8010055c <printint+0x5c>
    consputc(buf[i]);
80100552:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
80100557:	e8 4d ff ff ff       	call   801004a9 <consputc>
  while(--i >= 0)
8010055c:	83 eb 01             	sub    $0x1,%ebx
8010055f:	79 f1                	jns    80100552 <printint+0x52>
}
80100561:	83 c4 1c             	add    $0x1c,%esp
80100564:	5b                   	pop    %ebx
80100565:	5e                   	pop    %esi
80100566:	5f                   	pop    %edi
80100567:	5d                   	pop    %ebp
80100568:	c3                   	ret    

80100569 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100569:	55                   	push   %ebp
8010056a:	89 e5                	mov    %esp,%ebp
8010056c:	57                   	push   %edi
8010056d:	56                   	push   %esi
8010056e:	53                   	push   %ebx
8010056f:	83 ec 1c             	sub    $0x1c,%esp
80100572:	8b 7d 0c             	mov    0xc(%ebp),%edi
80100575:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  iunlock(ip);
80100578:	8b 45 08             	mov    0x8(%ebp),%eax
8010057b:	89 04 24             	mov    %eax,(%esp)
8010057e:	e8 45 11 00 00       	call   801016c8 <iunlock>
  acquire(&cons.lock);
80100583:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
8010058a:	e8 cd 36 00 00       	call   80103c5c <acquire>
  for(i = 0; i < n; i++)
8010058f:	bb 00 00 00 00       	mov    $0x0,%ebx
80100594:	eb 0c                	jmp    801005a2 <consolewrite+0x39>
    consputc(buf[i] & 0xff);
80100596:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
8010059a:	e8 0a ff ff ff       	call   801004a9 <consputc>
  for(i = 0; i < n; i++)
8010059f:	83 c3 01             	add    $0x1,%ebx
801005a2:	39 f3                	cmp    %esi,%ebx
801005a4:	7c f0                	jl     80100596 <consolewrite+0x2d>
  release(&cons.lock);
801005a6:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
801005ad:	e8 0b 37 00 00       	call   80103cbd <release>
  ilock(ip);
801005b2:	8b 45 08             	mov    0x8(%ebp),%eax
801005b5:	89 04 24             	mov    %eax,(%esp)
801005b8:	e8 44 10 00 00       	call   80101601 <ilock>

  return n;
}
801005bd:	89 f0                	mov    %esi,%eax
801005bf:	83 c4 1c             	add    $0x1c,%esp
801005c2:	5b                   	pop    %ebx
801005c3:	5e                   	pop    %esi
801005c4:	5f                   	pop    %edi
801005c5:	5d                   	pop    %ebp
801005c6:	c3                   	ret    

801005c7 <cprintf>:
{
801005c7:	55                   	push   %ebp
801005c8:	89 e5                	mov    %esp,%ebp
801005ca:	57                   	push   %edi
801005cb:	56                   	push   %esi
801005cc:	53                   	push   %ebx
801005cd:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
801005d0:	a1 54 a5 10 80       	mov    0x8010a554,%eax
801005d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(locking)
801005d8:	85 c0                	test   %eax,%eax
801005da:	74 0c                	je     801005e8 <cprintf+0x21>
    acquire(&cons.lock);
801005dc:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
801005e3:	e8 74 36 00 00       	call   80103c5c <acquire>
  if (fmt == 0)
801005e8:	8b 7d 08             	mov    0x8(%ebp),%edi
801005eb:	85 ff                	test   %edi,%edi
801005ed:	0f 85 d5 00 00 00    	jne    801006c8 <cprintf+0x101>
    panic("null fmt");
801005f3:	c7 04 24 3f 66 10 80 	movl   $0x8010663f,(%esp)
801005fa:	e8 26 fd ff ff       	call   80100325 <panic>
    if(c != '%'){
801005ff:	83 f8 25             	cmp    $0x25,%eax
80100602:	74 0a                	je     8010060e <cprintf+0x47>
      consputc(c);
80100604:	e8 a0 fe ff ff       	call   801004a9 <consputc>
      continue;
80100609:	e9 b5 00 00 00       	jmp    801006c3 <cprintf+0xfc>
    c = fmt[++i] & 0xff;
8010060e:	83 c3 01             	add    $0x1,%ebx
80100611:	0f b6 34 1f          	movzbl (%edi,%ebx,1),%esi
    if(c == 0)
80100615:	85 f6                	test   %esi,%esi
80100617:	0f 84 c2 00 00 00    	je     801006df <cprintf+0x118>
    switch(c){
8010061d:	83 fe 70             	cmp    $0x70,%esi
80100620:	74 3e                	je     80100660 <cprintf+0x99>
80100622:	83 fe 70             	cmp    $0x70,%esi
80100625:	7f 0d                	jg     80100634 <cprintf+0x6d>
80100627:	83 fe 25             	cmp    $0x25,%esi
8010062a:	74 7a                	je     801006a6 <cprintf+0xdf>
8010062c:	83 fe 64             	cmp    $0x64,%esi
8010062f:	90                   	nop
80100630:	74 12                	je     80100644 <cprintf+0x7d>
80100632:	eb 7e                	jmp    801006b2 <cprintf+0xeb>
80100634:	83 fe 73             	cmp    $0x73,%esi
80100637:	74 43                	je     8010067c <cprintf+0xb5>
80100639:	83 fe 78             	cmp    $0x78,%esi
8010063c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100640:	74 1e                	je     80100660 <cprintf+0x99>
80100642:	eb 6e                	jmp    801006b2 <cprintf+0xeb>
      printint(*argp++, 10, 1);
80100644:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100647:	8d 70 04             	lea    0x4(%eax),%esi
8010064a:	8b 00                	mov    (%eax),%eax
8010064c:	b9 01 00 00 00       	mov    $0x1,%ecx
80100651:	ba 0a 00 00 00       	mov    $0xa,%edx
80100656:	e8 a5 fe ff ff       	call   80100500 <printint>
8010065b:	89 75 e4             	mov    %esi,-0x1c(%ebp)
      break;
8010065e:	eb 63                	jmp    801006c3 <cprintf+0xfc>
      printint(*argp++, 16, 0);
80100660:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100663:	8d 70 04             	lea    0x4(%eax),%esi
80100666:	8b 00                	mov    (%eax),%eax
80100668:	b9 00 00 00 00       	mov    $0x0,%ecx
8010066d:	ba 10 00 00 00       	mov    $0x10,%edx
80100672:	e8 89 fe ff ff       	call   80100500 <printint>
80100677:	89 75 e4             	mov    %esi,-0x1c(%ebp)
      break;
8010067a:	eb 47                	jmp    801006c3 <cprintf+0xfc>
      if((s = (char*)*argp++) == 0)
8010067c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010067f:	8d 50 04             	lea    0x4(%eax),%edx
80100682:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80100685:	8b 30                	mov    (%eax),%esi
80100687:	85 f6                	test   %esi,%esi
80100689:	75 12                	jne    8010069d <cprintf+0xd6>
        s = "(null)";
8010068b:	be 38 66 10 80       	mov    $0x80106638,%esi
80100690:	eb 0b                	jmp    8010069d <cprintf+0xd6>
        consputc(*s);
80100692:	0f be c0             	movsbl %al,%eax
80100695:	e8 0f fe ff ff       	call   801004a9 <consputc>
      for(; *s; s++)
8010069a:	83 c6 01             	add    $0x1,%esi
8010069d:	0f b6 06             	movzbl (%esi),%eax
801006a0:	84 c0                	test   %al,%al
801006a2:	75 ee                	jne    80100692 <cprintf+0xcb>
801006a4:	eb 1d                	jmp    801006c3 <cprintf+0xfc>
      consputc('%');
801006a6:	b8 25 00 00 00       	mov    $0x25,%eax
801006ab:	e8 f9 fd ff ff       	call   801004a9 <consputc>
      break;
801006b0:	eb 11                	jmp    801006c3 <cprintf+0xfc>
      consputc('%');
801006b2:	b8 25 00 00 00       	mov    $0x25,%eax
801006b7:	e8 ed fd ff ff       	call   801004a9 <consputc>
      consputc(c);
801006bc:	89 f0                	mov    %esi,%eax
801006be:	e8 e6 fd ff ff       	call   801004a9 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801006c3:	83 c3 01             	add    $0x1,%ebx
801006c6:	eb 0b                	jmp    801006d3 <cprintf+0x10c>
801006c8:	8d 45 0c             	lea    0xc(%ebp),%eax
801006cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801006ce:	bb 00 00 00 00       	mov    $0x0,%ebx
801006d3:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
801006d7:	85 c0                	test   %eax,%eax
801006d9:	0f 85 20 ff ff ff    	jne    801005ff <cprintf+0x38>
  if(locking)
801006df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801006e3:	74 0c                	je     801006f1 <cprintf+0x12a>
    release(&cons.lock);
801006e5:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
801006ec:	e8 cc 35 00 00       	call   80103cbd <release>
}
801006f1:	83 c4 1c             	add    $0x1c,%esp
801006f4:	5b                   	pop    %ebx
801006f5:	5e                   	pop    %esi
801006f6:	5f                   	pop    %edi
801006f7:	5d                   	pop    %ebp
801006f8:	c3                   	ret    

801006f9 <consoleintr>:
{
801006f9:	55                   	push   %ebp
801006fa:	89 e5                	mov    %esp,%ebp
801006fc:	57                   	push   %edi
801006fd:	56                   	push   %esi
801006fe:	53                   	push   %ebx
801006ff:	83 ec 1c             	sub    $0x1c,%esp
80100702:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&cons.lock);
80100705:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
8010070c:	e8 4b 35 00 00       	call   80103c5c <acquire>
  int c, doprocdump = 0;
80100711:	be 00 00 00 00       	mov    $0x0,%esi
  while((c = getc()) >= 0){
80100716:	e9 f9 00 00 00       	jmp    80100814 <consoleintr+0x11b>
    switch(c){
8010071b:	83 ff 10             	cmp    $0x10,%edi
8010071e:	0f 84 eb 00 00 00    	je     8010080f <consoleintr+0x116>
80100724:	83 ff 10             	cmp    $0x10,%edi
80100727:	7f 09                	jg     80100732 <consoleintr+0x39>
80100729:	83 ff 08             	cmp    $0x8,%edi
8010072c:	74 4a                	je     80100778 <consoleintr+0x7f>
8010072e:	66 90                	xchg   %ax,%ax
80100730:	eb 6b                	jmp    8010079d <consoleintr+0xa4>
80100732:	83 ff 15             	cmp    $0x15,%edi
80100735:	74 1a                	je     80100751 <consoleintr+0x58>
80100737:	83 ff 7f             	cmp    $0x7f,%edi
8010073a:	74 3c                	je     80100778 <consoleintr+0x7f>
8010073c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100740:	eb 5b                	jmp    8010079d <consoleintr+0xa4>
        input.e--;
80100742:	a3 c8 ff 10 80       	mov    %eax,0x8010ffc8
        consputc(BACKSPACE);
80100747:	b8 00 01 00 00       	mov    $0x100,%eax
8010074c:	e8 58 fd ff ff       	call   801004a9 <consputc>
      while(input.e != input.w &&
80100751:	a1 c8 ff 10 80       	mov    0x8010ffc8,%eax
80100756:	3b 05 c4 ff 10 80    	cmp    0x8010ffc4,%eax
8010075c:	0f 84 b2 00 00 00    	je     80100814 <consoleintr+0x11b>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100762:	83 e8 01             	sub    $0x1,%eax
80100765:	89 c2                	mov    %eax,%edx
80100767:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
8010076a:	80 ba 40 ff 10 80 0a 	cmpb   $0xa,-0x7fef00c0(%edx)
80100771:	75 cf                	jne    80100742 <consoleintr+0x49>
80100773:	e9 9c 00 00 00       	jmp    80100814 <consoleintr+0x11b>
      if(input.e != input.w){
80100778:	a1 c8 ff 10 80       	mov    0x8010ffc8,%eax
8010077d:	3b 05 c4 ff 10 80    	cmp    0x8010ffc4,%eax
80100783:	0f 84 8b 00 00 00    	je     80100814 <consoleintr+0x11b>
        input.e--;
80100789:	83 e8 01             	sub    $0x1,%eax
8010078c:	a3 c8 ff 10 80       	mov    %eax,0x8010ffc8
        consputc(BACKSPACE);
80100791:	b8 00 01 00 00       	mov    $0x100,%eax
80100796:	e8 0e fd ff ff       	call   801004a9 <consputc>
8010079b:	eb 77                	jmp    80100814 <consoleintr+0x11b>
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010079d:	85 ff                	test   %edi,%edi
8010079f:	74 73                	je     80100814 <consoleintr+0x11b>
801007a1:	a1 c8 ff 10 80       	mov    0x8010ffc8,%eax
801007a6:	89 c2                	mov    %eax,%edx
801007a8:	2b 15 c0 ff 10 80    	sub    0x8010ffc0,%edx
801007ae:	83 fa 7f             	cmp    $0x7f,%edx
801007b1:	77 61                	ja     80100814 <consoleintr+0x11b>
        c = (c == '\r') ? '\n' : c;
801007b3:	83 ff 0d             	cmp    $0xd,%edi
801007b6:	75 04                	jne    801007bc <consoleintr+0xc3>
801007b8:	66 bf 0a 00          	mov    $0xa,%di
        input.buf[input.e++ % INPUT_BUF] = c;
801007bc:	8d 50 01             	lea    0x1(%eax),%edx
801007bf:	89 15 c8 ff 10 80    	mov    %edx,0x8010ffc8
801007c5:	83 e0 7f             	and    $0x7f,%eax
801007c8:	89 f9                	mov    %edi,%ecx
801007ca:	88 88 40 ff 10 80    	mov    %cl,-0x7fef00c0(%eax)
        consputc(c);
801007d0:	89 f8                	mov    %edi,%eax
801007d2:	e8 d2 fc ff ff       	call   801004a9 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801007d7:	83 ff 0a             	cmp    $0xa,%edi
801007da:	0f 94 c2             	sete   %dl
801007dd:	83 ff 04             	cmp    $0x4,%edi
801007e0:	0f 94 c0             	sete   %al
801007e3:	08 c2                	or     %al,%dl
801007e5:	75 10                	jne    801007f7 <consoleintr+0xfe>
801007e7:	a1 c0 ff 10 80       	mov    0x8010ffc0,%eax
801007ec:	83 e8 80             	sub    $0xffffff80,%eax
801007ef:	39 05 c8 ff 10 80    	cmp    %eax,0x8010ffc8
801007f5:	75 1d                	jne    80100814 <consoleintr+0x11b>
          input.w = input.e;
801007f7:	a1 c8 ff 10 80       	mov    0x8010ffc8,%eax
801007fc:	a3 c4 ff 10 80       	mov    %eax,0x8010ffc4
          wakeup(&input.r);
80100801:	c7 04 24 c0 ff 10 80 	movl   $0x8010ffc0,(%esp)
80100808:	e8 b3 30 00 00       	call   801038c0 <wakeup>
8010080d:	eb 05                	jmp    80100814 <consoleintr+0x11b>
      doprocdump = 1;
8010080f:	be 01 00 00 00       	mov    $0x1,%esi
  while((c = getc()) >= 0){
80100814:	ff d3                	call   *%ebx
80100816:	89 c7                	mov    %eax,%edi
80100818:	85 c0                	test   %eax,%eax
8010081a:	0f 89 fb fe ff ff    	jns    8010071b <consoleintr+0x22>
  release(&cons.lock);
80100820:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
80100827:	e8 91 34 00 00       	call   80103cbd <release>
  if(doprocdump) {
8010082c:	85 f6                	test   %esi,%esi
8010082e:	74 05                	je     80100835 <consoleintr+0x13c>
    procdump();  // now call procdump() wo. cons.lock held
80100830:	e8 1d 31 00 00       	call   80103952 <procdump>
}
80100835:	83 c4 1c             	add    $0x1c,%esp
80100838:	5b                   	pop    %ebx
80100839:	5e                   	pop    %esi
8010083a:	5f                   	pop    %edi
8010083b:	5d                   	pop    %ebp
8010083c:	c3                   	ret    

8010083d <consoleinit>:

void
consoleinit(void)
{
8010083d:	55                   	push   %ebp
8010083e:	89 e5                	mov    %esp,%ebp
80100840:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100843:	c7 44 24 04 48 66 10 	movl   $0x80106648,0x4(%esp)
8010084a:	80 
8010084b:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
80100852:	e8 cd 32 00 00       	call   80103b24 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100857:	c7 05 8c 09 11 80 69 	movl   $0x80100569,0x8011098c
8010085e:	05 10 80 
  devsw[CONSOLE].read = consoleread;
80100861:	c7 05 88 09 11 80 50 	movl   $0x80100250,0x80110988
80100868:	02 10 80 
  cons.locking = 1;
8010086b:	c7 05 54 a5 10 80 01 	movl   $0x1,0x8010a554
80100872:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100875:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010087c:	00 
8010087d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100884:	e8 6d 17 00 00       	call   80101ff6 <ioapicenable>
}
80100889:	c9                   	leave  
8010088a:	c3                   	ret    

8010088b <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
8010088b:	55                   	push   %ebp
8010088c:	89 e5                	mov    %esp,%ebp
8010088e:	57                   	push   %edi
8010088f:	56                   	push   %esi
80100890:	53                   	push   %ebx
80100891:	81 ec 1c 01 00 00    	sub    $0x11c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100897:	e8 29 2a 00 00       	call   801032c5 <myproc>
8010089c:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008a2:	e8 ac 1f 00 00       	call   80102853 <begin_op>

  if((ip = namei(path)) == 0){
801008a7:	8b 45 08             	mov    0x8(%ebp),%eax
801008aa:	89 04 24             	mov    %eax,(%esp)
801008ad:	e8 d0 13 00 00       	call   80101c82 <namei>
801008b2:	89 c3                	mov    %eax,%ebx
801008b4:	85 c0                	test   %eax,%eax
801008b6:	75 1b                	jne    801008d3 <exec+0x48>
    end_op();
801008b8:	e8 09 20 00 00       	call   801028c6 <end_op>
    cprintf("exec: fail\n");
801008bd:	c7 04 24 61 66 10 80 	movl   $0x80106661,(%esp)
801008c4:	e8 fe fc ff ff       	call   801005c7 <cprintf>
    return -1;
801008c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801008ce:	e9 79 03 00 00       	jmp    80100c4c <exec+0x3c1>
  }
  ilock(ip);
801008d3:	89 04 24             	mov    %eax,(%esp)
801008d6:	e8 26 0d 00 00       	call   80101601 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
801008db:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
801008e2:	00 
801008e3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801008ea:	00 
801008eb:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
801008f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801008f5:	89 1c 24             	mov    %ebx,(%esp)
801008f8:	e8 e1 0e 00 00       	call   801017de <readi>
801008fd:	83 f8 34             	cmp    $0x34,%eax
80100900:	0f 85 b9 02 00 00    	jne    80100bbf <exec+0x334>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100906:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
8010090d:	45 4c 46 
80100910:	0f 85 b0 02 00 00    	jne    80100bc6 <exec+0x33b>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100916:	e8 18 5a 00 00       	call   80106333 <setupkvm>
8010091b:	89 c6                	mov    %eax,%esi
8010091d:	85 c0                	test   %eax,%eax
8010091f:	0f 84 fe 02 00 00    	je     80100c23 <exec+0x398>
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100925:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  sz = 0;
8010092b:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
80100932:	00 00 00 
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100935:	bf 00 00 00 00       	mov    $0x0,%edi
8010093a:	89 b5 f0 fe ff ff    	mov    %esi,-0x110(%ebp)
80100940:	e9 c7 00 00 00       	jmp    80100a0c <exec+0x181>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100945:	89 c6                	mov    %eax,%esi
80100947:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
8010094e:	00 
8010094f:	89 44 24 08          	mov    %eax,0x8(%esp)
80100953:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100959:	89 44 24 04          	mov    %eax,0x4(%esp)
8010095d:	89 1c 24             	mov    %ebx,(%esp)
80100960:	e8 79 0e 00 00       	call   801017de <readi>
80100965:	83 f8 20             	cmp    $0x20,%eax
80100968:	0f 85 87 02 00 00    	jne    80100bf5 <exec+0x36a>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
8010096e:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
80100975:	0f 85 8b 00 00 00    	jne    80100a06 <exec+0x17b>
      continue;
    if(ph.memsz < ph.filesz)
8010097b:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
80100981:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
80100987:	0f 82 70 02 00 00    	jb     80100bfd <exec+0x372>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
8010098d:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
80100993:	0f 82 6c 02 00 00    	jb     80100c05 <exec+0x37a>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100999:	89 44 24 08          	mov    %eax,0x8(%esp)
8010099d:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
801009a3:	89 44 24 04          	mov    %eax,0x4(%esp)
801009a7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
801009ad:	89 04 24             	mov    %eax,(%esp)
801009b0:	e8 f2 57 00 00       	call   801061a7 <allocuvm>
801009b5:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
801009bb:	85 c0                	test   %eax,%eax
801009bd:	0f 84 4a 02 00 00    	je     80100c0d <exec+0x382>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
801009c3:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
801009c9:	a9 ff 0f 00 00       	test   $0xfff,%eax
801009ce:	0f 85 41 02 00 00    	jne    80100c15 <exec+0x38a>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
801009d4:	8b 95 14 ff ff ff    	mov    -0xec(%ebp),%edx
801009da:	89 54 24 10          	mov    %edx,0x10(%esp)
801009de:	8b 95 08 ff ff ff    	mov    -0xf8(%ebp),%edx
801009e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
801009e8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801009ec:	89 44 24 04          	mov    %eax,0x4(%esp)
801009f0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
801009f6:	89 04 24             	mov    %eax,(%esp)
801009f9:	e8 49 56 00 00       	call   80106047 <loaduvm>
801009fe:	85 c0                	test   %eax,%eax
80100a00:	0f 88 17 02 00 00    	js     80100c1d <exec+0x392>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100a06:	83 c7 01             	add    $0x1,%edi
80100a09:	8d 46 20             	lea    0x20(%esi),%eax
80100a0c:	0f b7 95 50 ff ff ff 	movzwl -0xb0(%ebp),%edx
80100a13:	39 fa                	cmp    %edi,%edx
80100a15:	0f 8f 2a ff ff ff    	jg     80100945 <exec+0xba>
80100a1b:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
      goto bad;
  }
  iunlockput(ip);
80100a21:	89 1c 24             	mov    %ebx,(%esp)
80100a24:	e8 6a 0d 00 00       	call   80101793 <iunlockput>
  end_op();
80100a29:	e8 98 1e 00 00       	call   801028c6 <end_op>
  ip = 0;

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100a2e:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100a34:	05 ff 0f 00 00       	add    $0xfff,%eax
80100a39:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a3e:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a44:	89 54 24 08          	mov    %edx,0x8(%esp)
80100a48:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a4c:	89 34 24             	mov    %esi,(%esp)
80100a4f:	e8 53 57 00 00       	call   801061a7 <allocuvm>
80100a54:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
80100a5a:	85 c0                	test   %eax,%eax
80100a5c:	0f 84 6b 01 00 00    	je     80100bcd <exec+0x342>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100a62:	89 c7                	mov    %eax,%edi
80100a64:	2d 00 20 00 00       	sub    $0x2000,%eax
80100a69:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a6d:	89 34 24             	mov    %esi,(%esp)
80100a70:	e8 50 59 00 00       	call   801063c5 <clearpteu>
  sp = sz;
80100a75:	89 f8                	mov    %edi,%eax

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100a77:	bf 00 00 00 00       	mov    $0x0,%edi
80100a7c:	89 b5 f0 fe ff ff    	mov    %esi,-0x110(%ebp)
80100a82:	89 c6                	mov    %eax,%esi
80100a84:	eb 54                	jmp    80100ada <exec+0x24f>
    if(argc >= MAXARG)
80100a86:	83 ff 1f             	cmp    $0x1f,%edi
80100a89:	0f 87 45 01 00 00    	ja     80100bd4 <exec+0x349>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100a8f:	89 04 24             	mov    %eax,(%esp)
80100a92:	e8 2b 34 00 00       	call   80103ec2 <strlen>
80100a97:	29 c6                	sub    %eax,%esi
80100a99:	83 ee 01             	sub    $0x1,%esi
80100a9c:	83 e6 fc             	and    $0xfffffffc,%esi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100a9f:	8b 03                	mov    (%ebx),%eax
80100aa1:	89 04 24             	mov    %eax,(%esp)
80100aa4:	e8 19 34 00 00       	call   80103ec2 <strlen>
80100aa9:	83 c0 01             	add    $0x1,%eax
80100aac:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100ab0:	8b 03                	mov    (%ebx),%eax
80100ab2:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ab6:	89 74 24 04          	mov    %esi,0x4(%esp)
80100aba:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100ac0:	89 04 24             	mov    %eax,(%esp)
80100ac3:	e8 8a 5a 00 00       	call   80106552 <copyout>
80100ac8:	85 c0                	test   %eax,%eax
80100aca:	0f 88 11 01 00 00    	js     80100be1 <exec+0x356>
      goto bad;
    ustack[3+argc] = sp;
80100ad0:	89 b4 bd 64 ff ff ff 	mov    %esi,-0x9c(%ebp,%edi,4)
  for(argc = 0; argv[argc]; argc++) {
80100ad7:	83 c7 01             	add    $0x1,%edi
80100ada:	8b 45 0c             	mov    0xc(%ebp),%eax
80100add:	8d 1c b8             	lea    (%eax,%edi,4),%ebx
80100ae0:	8b 03                	mov    (%ebx),%eax
80100ae2:	85 c0                	test   %eax,%eax
80100ae4:	75 a0                	jne    80100a86 <exec+0x1fb>
80100ae6:	89 f2                	mov    %esi,%edx
80100ae8:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
  }
  ustack[3+argc] = 0;
80100aee:	c7 84 bd 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%edi,4)
80100af5:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100af9:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100b00:	ff ff ff 
  ustack[1] = argc;
80100b03:	89 bd 5c ff ff ff    	mov    %edi,-0xa4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100b09:	8d 04 bd 04 00 00 00 	lea    0x4(,%edi,4),%eax
80100b10:	89 d1                	mov    %edx,%ecx
80100b12:	29 c1                	sub    %eax,%ecx
80100b14:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)

  sp -= (3+argc+1) * 4;
80100b1a:	8d 04 bd 10 00 00 00 	lea    0x10(,%edi,4),%eax
80100b21:	89 d1                	mov    %edx,%ecx
80100b23:	29 c1                	sub    %eax,%ecx
80100b25:	89 cb                	mov    %ecx,%ebx
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100b27:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100b2b:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80100b31:	89 44 24 08          	mov    %eax,0x8(%esp)
80100b35:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80100b39:	89 34 24             	mov    %esi,(%esp)
80100b3c:	e8 11 5a 00 00       	call   80106552 <copyout>
80100b41:	85 c0                	test   %eax,%eax
80100b43:	0f 88 a5 00 00 00    	js     80100bee <exec+0x363>
80100b49:	8b 55 08             	mov    0x8(%ebp),%edx
80100b4c:	89 d0                	mov    %edx,%eax
80100b4e:	eb 0b                	jmp    80100b5b <exec+0x2d0>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
    if(*s == '/')
80100b50:	80 f9 2f             	cmp    $0x2f,%cl
80100b53:	75 03                	jne    80100b58 <exec+0x2cd>
      last = s+1;
80100b55:	8d 50 01             	lea    0x1(%eax),%edx
  for(last=s=path; *s; s++)
80100b58:	83 c0 01             	add    $0x1,%eax
80100b5b:	0f b6 08             	movzbl (%eax),%ecx
80100b5e:	84 c9                	test   %cl,%cl
80100b60:	75 ee                	jne    80100b50 <exec+0x2c5>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100b62:	8b bd f4 fe ff ff    	mov    -0x10c(%ebp),%edi
80100b68:	89 f8                	mov    %edi,%eax
80100b6a:	83 c0 6c             	add    $0x6c,%eax
80100b6d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100b74:	00 
80100b75:	89 54 24 04          	mov    %edx,0x4(%esp)
80100b79:	89 04 24             	mov    %eax,(%esp)
80100b7c:	e8 06 33 00 00       	call   80103e87 <safestrcpy>

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100b81:	89 f8                	mov    %edi,%eax
80100b83:	8b 7f 04             	mov    0x4(%edi),%edi
  curproc->pgdir = pgdir;
80100b86:	89 70 04             	mov    %esi,0x4(%eax)
  curproc->sz = sz;
80100b89:	8b 8d ec fe ff ff    	mov    -0x114(%ebp),%ecx
80100b8f:	89 08                	mov    %ecx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100b91:	89 c1                	mov    %eax,%ecx
80100b93:	8b 40 18             	mov    0x18(%eax),%eax
80100b96:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100b9c:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100b9f:	8b 41 18             	mov    0x18(%ecx),%eax
80100ba2:	89 58 44             	mov    %ebx,0x44(%eax)
  switchuvm(curproc);
80100ba5:	89 0c 24             	mov    %ecx,(%esp)
80100ba8:	e8 0a 53 00 00       	call   80105eb7 <switchuvm>
  freevm(oldpgdir);
80100bad:	89 3c 24             	mov    %edi,(%esp)
80100bb0:	e8 fe 56 00 00       	call   801062b3 <freevm>
  return 0;
80100bb5:	b8 00 00 00 00       	mov    $0x0,%eax
80100bba:	e9 8d 00 00 00       	jmp    80100c4c <exec+0x3c1>
  pgdir = 0;
80100bbf:	be 00 00 00 00       	mov    $0x0,%esi
80100bc4:	eb 5d                	jmp    80100c23 <exec+0x398>
80100bc6:	be 00 00 00 00       	mov    $0x0,%esi
80100bcb:	eb 56                	jmp    80100c23 <exec+0x398>
  ip = 0;
80100bcd:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bd2:	eb 4f                	jmp    80100c23 <exec+0x398>
80100bd4:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
80100bda:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bdf:	eb 42                	jmp    80100c23 <exec+0x398>
80100be1:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
80100be7:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bec:	eb 35                	jmp    80100c23 <exec+0x398>
80100bee:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bf3:	eb 2e                	jmp    80100c23 <exec+0x398>
80100bf5:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
80100bfb:	eb 26                	jmp    80100c23 <exec+0x398>
80100bfd:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
80100c03:	eb 1e                	jmp    80100c23 <exec+0x398>
80100c05:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
80100c0b:	eb 16                	jmp    80100c23 <exec+0x398>
80100c0d:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
80100c13:	eb 0e                	jmp    80100c23 <exec+0x398>
80100c15:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
80100c1b:	eb 06                	jmp    80100c23 <exec+0x398>
80100c1d:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi

 bad:
  if(pgdir)
80100c23:	85 f6                	test   %esi,%esi
80100c25:	74 08                	je     80100c2f <exec+0x3a4>
    freevm(pgdir);
80100c27:	89 34 24             	mov    %esi,(%esp)
80100c2a:	e8 84 56 00 00       	call   801062b3 <freevm>
  if(ip){
80100c2f:	85 db                	test   %ebx,%ebx
80100c31:	74 14                	je     80100c47 <exec+0x3bc>
    iunlockput(ip);
80100c33:	89 1c 24             	mov    %ebx,(%esp)
80100c36:	e8 58 0b 00 00       	call   80101793 <iunlockput>
    end_op();
80100c3b:	e8 86 1c 00 00       	call   801028c6 <end_op>
  }
  return -1;
80100c40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c45:	eb 05                	jmp    80100c4c <exec+0x3c1>
80100c47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100c4c:	81 c4 1c 01 00 00    	add    $0x11c,%esp
80100c52:	5b                   	pop    %ebx
80100c53:	5e                   	pop    %esi
80100c54:	5f                   	pop    %edi
80100c55:	5d                   	pop    %ebp
80100c56:	c3                   	ret    
80100c57:	66 90                	xchg   %ax,%ax
80100c59:	66 90                	xchg   %ax,%ax
80100c5b:	66 90                	xchg   %ax,%ax
80100c5d:	66 90                	xchg   %ax,%ax
80100c5f:	90                   	nop

80100c60 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100c60:	55                   	push   %ebp
80100c61:	89 e5                	mov    %esp,%ebp
80100c63:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100c66:	c7 44 24 04 6d 66 10 	movl   $0x8010666d,0x4(%esp)
80100c6d:	80 
80100c6e:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80100c75:	e8 aa 2e 00 00       	call   80103b24 <initlock>
}
80100c7a:	c9                   	leave  
80100c7b:	c3                   	ret    

80100c7c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100c7c:	55                   	push   %ebp
80100c7d:	89 e5                	mov    %esp,%ebp
80100c7f:	53                   	push   %ebx
80100c80:	83 ec 14             	sub    $0x14,%esp
  struct file *f;

  acquire(&ftable.lock);
80100c83:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80100c8a:	e8 cd 2f 00 00       	call   80103c5c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c8f:	bb 14 00 11 80       	mov    $0x80110014,%ebx
80100c94:	eb 20                	jmp    80100cb6 <filealloc+0x3a>
    if(f->ref == 0){
80100c96:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80100c9a:	75 17                	jne    80100cb3 <filealloc+0x37>
      f->ref = 1;
80100c9c:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100ca3:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80100caa:	e8 0e 30 00 00       	call   80103cbd <release>
      return f;
80100caf:	89 d8                	mov    %ebx,%eax
80100cb1:	eb 1c                	jmp    80100ccf <filealloc+0x53>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100cb3:	83 c3 18             	add    $0x18,%ebx
80100cb6:	81 fb 74 09 11 80    	cmp    $0x80110974,%ebx
80100cbc:	72 d8                	jb     80100c96 <filealloc+0x1a>
    }
  }
  release(&ftable.lock);
80100cbe:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80100cc5:	e8 f3 2f 00 00       	call   80103cbd <release>
  return 0;
80100cca:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100ccf:	83 c4 14             	add    $0x14,%esp
80100cd2:	5b                   	pop    %ebx
80100cd3:	5d                   	pop    %ebp
80100cd4:	c3                   	ret    

80100cd5 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100cd5:	55                   	push   %ebp
80100cd6:	89 e5                	mov    %esp,%ebp
80100cd8:	53                   	push   %ebx
80100cd9:	83 ec 14             	sub    $0x14,%esp
80100cdc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100cdf:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80100ce6:	e8 71 2f 00 00       	call   80103c5c <acquire>
  if(f->ref < 1)
80100ceb:	8b 43 04             	mov    0x4(%ebx),%eax
80100cee:	85 c0                	test   %eax,%eax
80100cf0:	7f 0c                	jg     80100cfe <filedup+0x29>
    panic("filedup");
80100cf2:	c7 04 24 74 66 10 80 	movl   $0x80106674,(%esp)
80100cf9:	e8 27 f6 ff ff       	call   80100325 <panic>
  f->ref++;
80100cfe:	83 c0 01             	add    $0x1,%eax
80100d01:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100d04:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80100d0b:	e8 ad 2f 00 00       	call   80103cbd <release>
  return f;
}
80100d10:	89 d8                	mov    %ebx,%eax
80100d12:	83 c4 14             	add    $0x14,%esp
80100d15:	5b                   	pop    %ebx
80100d16:	5d                   	pop    %ebp
80100d17:	c3                   	ret    

80100d18 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100d18:	55                   	push   %ebp
80100d19:	89 e5                	mov    %esp,%ebp
80100d1b:	53                   	push   %ebx
80100d1c:	83 ec 34             	sub    $0x34,%esp
80100d1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100d22:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80100d29:	e8 2e 2f 00 00       	call   80103c5c <acquire>
  if(f->ref < 1)
80100d2e:	8b 43 04             	mov    0x4(%ebx),%eax
80100d31:	85 c0                	test   %eax,%eax
80100d33:	7f 0c                	jg     80100d41 <fileclose+0x29>
    panic("fileclose");
80100d35:	c7 04 24 7c 66 10 80 	movl   $0x8010667c,(%esp)
80100d3c:	e8 e4 f5 ff ff       	call   80100325 <panic>
  if(--f->ref > 0){
80100d41:	83 e8 01             	sub    $0x1,%eax
80100d44:	89 43 04             	mov    %eax,0x4(%ebx)
80100d47:	85 c0                	test   %eax,%eax
80100d49:	7e 0e                	jle    80100d59 <fileclose+0x41>
    release(&ftable.lock);
80100d4b:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80100d52:	e8 66 2f 00 00       	call   80103cbd <release>
80100d57:	eb 6d                	jmp    80100dc6 <fileclose+0xae>
    return;
  }
  ff = *f;
80100d59:	8b 03                	mov    (%ebx),%eax
80100d5b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d5e:	8b 43 04             	mov    0x4(%ebx),%eax
80100d61:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100d64:	8b 43 08             	mov    0x8(%ebx),%eax
80100d67:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d6a:	8b 43 0c             	mov    0xc(%ebx),%eax
80100d6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100d70:	8b 43 10             	mov    0x10(%ebx),%eax
80100d73:	89 45 f0             	mov    %eax,-0x10(%ebp)
  f->ref = 0;
80100d76:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
80100d7d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
80100d83:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80100d8a:	e8 2e 2f 00 00       	call   80103cbd <release>

  if(ff.type == FD_PIPE)
80100d8f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d92:	83 f8 01             	cmp    $0x1,%eax
80100d95:	75 15                	jne    80100dac <fileclose+0x94>
    pipeclose(ff.pipe, ff.writable);
80100d97:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d9b:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100da2:	89 04 24             	mov    %eax,(%esp)
80100da5:	e8 63 21 00 00       	call   80102f0d <pipeclose>
80100daa:	eb 1a                	jmp    80100dc6 <fileclose+0xae>
  else if(ff.type == FD_INODE){
80100dac:	83 f8 02             	cmp    $0x2,%eax
80100daf:	75 15                	jne    80100dc6 <fileclose+0xae>
    begin_op();
80100db1:	e8 9d 1a 00 00       	call   80102853 <begin_op>
    iput(ff.ip);
80100db6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100db9:	89 04 24             	mov    %eax,(%esp)
80100dbc:	e8 46 09 00 00       	call   80101707 <iput>
    end_op();
80100dc1:	e8 00 1b 00 00       	call   801028c6 <end_op>
  }
}
80100dc6:	83 c4 34             	add    $0x34,%esp
80100dc9:	5b                   	pop    %ebx
80100dca:	5d                   	pop    %ebp
80100dcb:	c3                   	ret    

80100dcc <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100dcc:	55                   	push   %ebp
80100dcd:	89 e5                	mov    %esp,%ebp
80100dcf:	53                   	push   %ebx
80100dd0:	83 ec 14             	sub    $0x14,%esp
80100dd3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100dd6:	83 3b 02             	cmpl   $0x2,(%ebx)
80100dd9:	75 2f                	jne    80100e0a <filestat+0x3e>
    ilock(f->ip);
80100ddb:	8b 43 10             	mov    0x10(%ebx),%eax
80100dde:	89 04 24             	mov    %eax,(%esp)
80100de1:	e8 1b 08 00 00       	call   80101601 <ilock>
    stati(f->ip, st);
80100de6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100de9:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ded:	8b 43 10             	mov    0x10(%ebx),%eax
80100df0:	89 04 24             	mov    %eax,(%esp)
80100df3:	e8 bb 09 00 00       	call   801017b3 <stati>
    iunlock(f->ip);
80100df8:	8b 43 10             	mov    0x10(%ebx),%eax
80100dfb:	89 04 24             	mov    %eax,(%esp)
80100dfe:	e8 c5 08 00 00       	call   801016c8 <iunlock>
    return 0;
80100e03:	b8 00 00 00 00       	mov    $0x0,%eax
80100e08:	eb 05                	jmp    80100e0f <filestat+0x43>
  }
  return -1;
80100e0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100e0f:	83 c4 14             	add    $0x14,%esp
80100e12:	5b                   	pop    %ebx
80100e13:	5d                   	pop    %ebp
80100e14:	c3                   	ret    

80100e15 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100e15:	55                   	push   %ebp
80100e16:	89 e5                	mov    %esp,%ebp
80100e18:	56                   	push   %esi
80100e19:	53                   	push   %ebx
80100e1a:	83 ec 10             	sub    $0x10,%esp
80100e1d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->readable == 0)
80100e20:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100e24:	74 76                	je     80100e9c <fileread+0x87>
    return -1;
  if(f->type == FD_PIPE)
80100e26:	8b 03                	mov    (%ebx),%eax
80100e28:	83 f8 01             	cmp    $0x1,%eax
80100e2b:	75 1b                	jne    80100e48 <fileread+0x33>
    return piperead(f->pipe, addr, n);
80100e2d:	8b 43 0c             	mov    0xc(%ebx),%eax
80100e30:	8b 4d 10             	mov    0x10(%ebp),%ecx
80100e33:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80100e37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100e3a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80100e3e:	89 04 24             	mov    %eax,(%esp)
80100e41:	e8 0a 22 00 00       	call   80103050 <piperead>
80100e46:	eb 59                	jmp    80100ea1 <fileread+0x8c>
  if(f->type == FD_INODE){
80100e48:	83 f8 02             	cmp    $0x2,%eax
80100e4b:	75 43                	jne    80100e90 <fileread+0x7b>
    ilock(f->ip);
80100e4d:	8b 43 10             	mov    0x10(%ebx),%eax
80100e50:	89 04 24             	mov    %eax,(%esp)
80100e53:	e8 a9 07 00 00       	call   80101601 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100e58:	8b 53 14             	mov    0x14(%ebx),%edx
80100e5b:	8b 43 10             	mov    0x10(%ebx),%eax
80100e5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
80100e61:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80100e65:	89 54 24 08          	mov    %edx,0x8(%esp)
80100e69:	8b 55 0c             	mov    0xc(%ebp),%edx
80100e6c:	89 54 24 04          	mov    %edx,0x4(%esp)
80100e70:	89 04 24             	mov    %eax,(%esp)
80100e73:	e8 66 09 00 00       	call   801017de <readi>
80100e78:	89 c6                	mov    %eax,%esi
80100e7a:	85 c0                	test   %eax,%eax
80100e7c:	7e 03                	jle    80100e81 <fileread+0x6c>
      f->off += r;
80100e7e:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100e81:	8b 43 10             	mov    0x10(%ebx),%eax
80100e84:	89 04 24             	mov    %eax,(%esp)
80100e87:	e8 3c 08 00 00       	call   801016c8 <iunlock>
    return r;
80100e8c:	89 f0                	mov    %esi,%eax
80100e8e:	eb 11                	jmp    80100ea1 <fileread+0x8c>
  }
  panic("fileread");
80100e90:	c7 04 24 86 66 10 80 	movl   $0x80106686,(%esp)
80100e97:	e8 89 f4 ff ff       	call   80100325 <panic>
    return -1;
80100e9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100ea1:	83 c4 10             	add    $0x10,%esp
80100ea4:	5b                   	pop    %ebx
80100ea5:	5e                   	pop    %esi
80100ea6:	5d                   	pop    %ebp
80100ea7:	c3                   	ret    

80100ea8 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100ea8:	55                   	push   %ebp
80100ea9:	89 e5                	mov    %esp,%ebp
80100eab:	57                   	push   %edi
80100eac:	56                   	push   %esi
80100ead:	53                   	push   %ebx
80100eae:	83 ec 2c             	sub    $0x2c,%esp
80100eb1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->writable == 0)
80100eb4:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
80100eb8:	0f 84 df 00 00 00    	je     80100f9d <filewrite+0xf5>
    return -1;
  if(f->type == FD_PIPE)
80100ebe:	8b 03                	mov    (%ebx),%eax
80100ec0:	83 f8 01             	cmp    $0x1,%eax
80100ec3:	75 1e                	jne    80100ee3 <filewrite+0x3b>
    return pipewrite(f->pipe, addr, n);
80100ec5:	8b 43 0c             	mov    0xc(%ebx),%eax
80100ec8:	8b 4d 10             	mov    0x10(%ebp),%ecx
80100ecb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80100ecf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100ed2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80100ed6:	89 04 24             	mov    %eax,(%esp)
80100ed9:	e8 ab 20 00 00       	call   80102f89 <pipewrite>
80100ede:	e9 bf 00 00 00       	jmp    80100fa2 <filewrite+0xfa>
  if(f->type == FD_INODE){
80100ee3:	83 f8 02             	cmp    $0x2,%eax
80100ee6:	0f 84 86 00 00 00    	je     80100f72 <filewrite+0xca>
80100eec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100ef0:	e9 9c 00 00 00       	jmp    80100f91 <filewrite+0xe9>
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
      int n1 = n - i;
80100ef5:	8b 45 10             	mov    0x10(%ebp),%eax
80100ef8:	29 f8                	sub    %edi,%eax
80100efa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(n1 > max)
80100efd:	3d 00 06 00 00       	cmp    $0x600,%eax
80100f02:	7e 07                	jle    80100f0b <filewrite+0x63>
        n1 = max;
80100f04:	c7 45 e4 00 06 00 00 	movl   $0x600,-0x1c(%ebp)

      begin_op();
80100f0b:	e8 43 19 00 00       	call   80102853 <begin_op>
      ilock(f->ip);
80100f10:	8b 43 10             	mov    0x10(%ebx),%eax
80100f13:	89 04 24             	mov    %eax,(%esp)
80100f16:	e8 e6 06 00 00       	call   80101601 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100f1b:	8b 4b 14             	mov    0x14(%ebx),%ecx
80100f1e:	89 fa                	mov    %edi,%edx
80100f20:	03 55 0c             	add    0xc(%ebp),%edx
80100f23:	8b 43 10             	mov    0x10(%ebx),%eax
80100f26:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80100f29:	89 74 24 0c          	mov    %esi,0xc(%esp)
80100f2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80100f31:	89 54 24 04          	mov    %edx,0x4(%esp)
80100f35:	89 04 24             	mov    %eax,(%esp)
80100f38:	e8 a9 09 00 00       	call   801018e6 <writei>
80100f3d:	89 c6                	mov    %eax,%esi
80100f3f:	85 c0                	test   %eax,%eax
80100f41:	7e 03                	jle    80100f46 <filewrite+0x9e>
        f->off += r;
80100f43:	01 43 14             	add    %eax,0x14(%ebx)
      iunlock(f->ip);
80100f46:	8b 43 10             	mov    0x10(%ebx),%eax
80100f49:	89 04 24             	mov    %eax,(%esp)
80100f4c:	e8 77 07 00 00       	call   801016c8 <iunlock>
      end_op();
80100f51:	e8 70 19 00 00       	call   801028c6 <end_op>

      if(r < 0)
80100f56:	85 f6                	test   %esi,%esi
80100f58:	78 26                	js     80100f80 <filewrite+0xd8>
        break;
      if(r != n1)
80100f5a:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
80100f5d:	8d 76 00             	lea    0x0(%esi),%esi
80100f60:	74 0c                	je     80100f6e <filewrite+0xc6>
        panic("short filewrite");
80100f62:	c7 04 24 8f 66 10 80 	movl   $0x8010668f,(%esp)
80100f69:	e8 b7 f3 ff ff       	call   80100325 <panic>
      i += r;
80100f6e:	01 f7                	add    %esi,%edi
80100f70:	eb 05                	jmp    80100f77 <filewrite+0xcf>
80100f72:	bf 00 00 00 00       	mov    $0x0,%edi
    while(i < n){
80100f77:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100f7a:	0f 8c 75 ff ff ff    	jl     80100ef5 <filewrite+0x4d>
    }
    return i == n ? n : -1;
80100f80:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100f83:	74 07                	je     80100f8c <filewrite+0xe4>
80100f85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f8a:	eb 16                	jmp    80100fa2 <filewrite+0xfa>
80100f8c:	8b 45 10             	mov    0x10(%ebp),%eax
80100f8f:	eb 11                	jmp    80100fa2 <filewrite+0xfa>
  }
  panic("filewrite");
80100f91:	c7 04 24 95 66 10 80 	movl   $0x80106695,(%esp)
80100f98:	e8 88 f3 ff ff       	call   80100325 <panic>
    return -1;
80100f9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fa2:	83 c4 2c             	add    $0x2c,%esp
80100fa5:	5b                   	pop    %ebx
80100fa6:	5e                   	pop    %esi
80100fa7:	5f                   	pop    %edi
80100fa8:	5d                   	pop    %ebp
80100fa9:	c3                   	ret    
80100faa:	66 90                	xchg   %ax,%ax
80100fac:	66 90                	xchg   %ax,%ax
80100fae:	66 90                	xchg   %ax,%ax

80100fb0 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80100fb0:	55                   	push   %ebp
80100fb1:	89 e5                	mov    %esp,%ebp
80100fb3:	57                   	push   %edi
80100fb4:	56                   	push   %esi
80100fb5:	53                   	push   %ebx
80100fb6:	83 ec 1c             	sub    $0x1c,%esp
80100fb9:	89 d7                	mov    %edx,%edi
  char *s;
  int len;

  while(*path == '/')
80100fbb:	eb 03                	jmp    80100fc0 <skipelem+0x10>
    path++;
80100fbd:	83 c0 01             	add    $0x1,%eax
  while(*path == '/')
80100fc0:	0f b6 10             	movzbl (%eax),%edx
80100fc3:	80 fa 2f             	cmp    $0x2f,%dl
80100fc6:	74 f5                	je     80100fbd <skipelem+0xd>
  if(*path == 0)
80100fc8:	84 d2                	test   %dl,%dl
80100fca:	74 5a                	je     80101026 <skipelem+0x76>
80100fcc:	89 c3                	mov    %eax,%ebx
80100fce:	eb 03                	jmp    80100fd3 <skipelem+0x23>
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
    path++;
80100fd0:	83 c3 01             	add    $0x1,%ebx
  while(*path != '/' && *path != 0)
80100fd3:	0f b6 13             	movzbl (%ebx),%edx
80100fd6:	80 fa 2f             	cmp    $0x2f,%dl
80100fd9:	0f 95 c1             	setne  %cl
80100fdc:	84 d2                	test   %dl,%dl
80100fde:	0f 95 c2             	setne  %dl
80100fe1:	84 d1                	test   %dl,%cl
80100fe3:	75 eb                	jne    80100fd0 <skipelem+0x20>
  len = path - s;
80100fe5:	89 de                	mov    %ebx,%esi
80100fe7:	29 c6                	sub    %eax,%esi
  if(len >= DIRSIZ)
80100fe9:	83 fe 0d             	cmp    $0xd,%esi
80100fec:	7e 16                	jle    80101004 <skipelem+0x54>
    memmove(name, s, DIRSIZ);
80100fee:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80100ff5:	00 
80100ff6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ffa:	89 3c 24             	mov    %edi,(%esp)
80100ffd:	e8 8b 2d 00 00       	call   80103d8d <memmove>
80101002:	eb 19                	jmp    8010101d <skipelem+0x6d>
  else {
    memmove(name, s, len);
80101004:	89 74 24 08          	mov    %esi,0x8(%esp)
80101008:	89 44 24 04          	mov    %eax,0x4(%esp)
8010100c:	89 3c 24             	mov    %edi,(%esp)
8010100f:	e8 79 2d 00 00       	call   80103d8d <memmove>
    name[len] = 0;
80101014:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
80101018:	eb 03                	jmp    8010101d <skipelem+0x6d>
  }
  while(*path == '/')
    path++;
8010101a:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
8010101d:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80101020:	74 f8                	je     8010101a <skipelem+0x6a>
  return path;
80101022:	89 d8                	mov    %ebx,%eax
80101024:	eb 05                	jmp    8010102b <skipelem+0x7b>
    return 0;
80101026:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010102b:	83 c4 1c             	add    $0x1c,%esp
8010102e:	5b                   	pop    %ebx
8010102f:	5e                   	pop    %esi
80101030:	5f                   	pop    %edi
80101031:	5d                   	pop    %ebp
80101032:	c3                   	ret    

80101033 <bzero>:
{
80101033:	55                   	push   %ebp
80101034:	89 e5                	mov    %esp,%ebp
80101036:	53                   	push   %ebx
80101037:	83 ec 14             	sub    $0x14,%esp
  bp = bread(dev, bno);
8010103a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010103e:	89 04 24             	mov    %eax,(%esp)
80101041:	e8 1d f1 ff ff       	call   80100163 <bread>
80101046:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
80101048:	8d 40 5c             	lea    0x5c(%eax),%eax
8010104b:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80101052:	00 
80101053:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010105a:	00 
8010105b:	89 04 24             	mov    %eax,(%esp)
8010105e:	e8 ad 2c 00 00       	call   80103d10 <memset>
  log_write(bp);
80101063:	89 1c 24             	mov    %ebx,(%esp)
80101066:	e8 ff 18 00 00       	call   8010296a <log_write>
  brelse(bp);
8010106b:	89 1c 24             	mov    %ebx,(%esp)
8010106e:	e8 4f f1 ff ff       	call   801001c2 <brelse>
}
80101073:	83 c4 14             	add    $0x14,%esp
80101076:	5b                   	pop    %ebx
80101077:	5d                   	pop    %ebp
80101078:	c3                   	ret    

80101079 <bfree>:
{
80101079:	55                   	push   %ebp
8010107a:	89 e5                	mov    %esp,%ebp
8010107c:	56                   	push   %esi
8010107d:	53                   	push   %ebx
8010107e:	83 ec 10             	sub    $0x10,%esp
80101081:	89 d6                	mov    %edx,%esi
  bp = bread(dev, BBLOCK(b, sb));
80101083:	c1 ea 0c             	shr    $0xc,%edx
80101086:	03 15 f8 09 11 80    	add    0x801109f8,%edx
8010108c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101090:	89 04 24             	mov    %eax,(%esp)
80101093:	e8 cb f0 ff ff       	call   80100163 <bread>
80101098:	89 c3                	mov    %eax,%ebx
  bi = b % BPB;
8010109a:	81 e6 ff 0f 00 00    	and    $0xfff,%esi
801010a0:	89 f2                	mov    %esi,%edx
  m = 1 << (bi % 8);
801010a2:	89 f1                	mov    %esi,%ecx
801010a4:	83 e1 07             	and    $0x7,%ecx
801010a7:	b8 01 00 00 00       	mov    $0x1,%eax
801010ac:	d3 e0                	shl    %cl,%eax
801010ae:	89 c1                	mov    %eax,%ecx
  if((bp->data[bi/8] & m) == 0)
801010b0:	c1 fa 03             	sar    $0x3,%edx
801010b3:	0f b6 44 13 5c       	movzbl 0x5c(%ebx,%edx,1),%eax
801010b8:	0f b6 f0             	movzbl %al,%esi
801010bb:	85 ce                	test   %ecx,%esi
801010bd:	75 0c                	jne    801010cb <bfree+0x52>
    panic("freeing free block");
801010bf:	c7 04 24 9f 66 10 80 	movl   $0x8010669f,(%esp)
801010c6:	e8 5a f2 ff ff       	call   80100325 <panic>
  bp->data[bi/8] &= ~m;
801010cb:	f7 d1                	not    %ecx
801010cd:	21 c8                	and    %ecx,%eax
801010cf:	88 44 13 5c          	mov    %al,0x5c(%ebx,%edx,1)
  log_write(bp);
801010d3:	89 1c 24             	mov    %ebx,(%esp)
801010d6:	e8 8f 18 00 00       	call   8010296a <log_write>
  brelse(bp);
801010db:	89 1c 24             	mov    %ebx,(%esp)
801010de:	e8 df f0 ff ff       	call   801001c2 <brelse>
}
801010e3:	83 c4 10             	add    $0x10,%esp
801010e6:	5b                   	pop    %ebx
801010e7:	5e                   	pop    %esi
801010e8:	5d                   	pop    %ebp
801010e9:	c3                   	ret    

801010ea <balloc>:
{
801010ea:	55                   	push   %ebp
801010eb:	89 e5                	mov    %esp,%ebp
801010ed:	57                   	push   %edi
801010ee:	56                   	push   %esi
801010ef:	53                   	push   %ebx
801010f0:	83 ec 2c             	sub    $0x2c,%esp
801010f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801010f6:	bf 00 00 00 00       	mov    $0x0,%edi
801010fb:	e9 88 00 00 00       	jmp    80101188 <balloc+0x9e>
    bp = bread(dev, BBLOCK(b, sb));
80101100:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80101106:	85 ff                	test   %edi,%edi
80101108:	0f 49 c7             	cmovns %edi,%eax
8010110b:	c1 f8 0c             	sar    $0xc,%eax
8010110e:	03 05 f8 09 11 80    	add    0x801109f8,%eax
80101114:	89 44 24 04          	mov    %eax,0x4(%esp)
80101118:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010111b:	89 04 24             	mov    %eax,(%esp)
8010111e:	e8 40 f0 ff ff       	call   80100163 <bread>
80101123:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101126:	b8 00 00 00 00       	mov    $0x0,%eax
8010112b:	eb 35                	jmp    80101162 <balloc+0x78>
      m = 1 << (bi % 8);
8010112d:	99                   	cltd   
8010112e:	c1 ea 1d             	shr    $0x1d,%edx
80101131:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
80101134:	83 e1 07             	and    $0x7,%ecx
80101137:	29 d1                	sub    %edx,%ecx
80101139:	be 01 00 00 00       	mov    $0x1,%esi
8010113e:	d3 e6                	shl    %cl,%esi
80101140:	89 f1                	mov    %esi,%ecx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101142:	8d 50 07             	lea    0x7(%eax),%edx
80101145:	85 c0                	test   %eax,%eax
80101147:	0f 49 d0             	cmovns %eax,%edx
8010114a:	c1 fa 03             	sar    $0x3,%edx
8010114d:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101150:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80101153:	0f b6 54 16 5c       	movzbl 0x5c(%esi,%edx,1),%edx
80101158:	0f b6 f2             	movzbl %dl,%esi
8010115b:	85 ce                	test   %ecx,%esi
8010115d:	74 41                	je     801011a0 <balloc+0xb6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010115f:	83 c0 01             	add    $0x1,%eax
80101162:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80101167:	7f 0e                	jg     80101177 <balloc+0x8d>
80101169:	8d 1c 07             	lea    (%edi,%eax,1),%ebx
8010116c:	89 5d e0             	mov    %ebx,-0x20(%ebp)
8010116f:	3b 1d e0 09 11 80    	cmp    0x801109e0,%ebx
80101175:	72 b6                	jb     8010112d <balloc+0x43>
    brelse(bp);
80101177:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010117a:	89 04 24             	mov    %eax,(%esp)
8010117d:	e8 40 f0 ff ff       	call   801001c2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
80101182:	81 c7 00 10 00 00    	add    $0x1000,%edi
80101188:	3b 3d e0 09 11 80    	cmp    0x801109e0,%edi
8010118e:	0f 82 6c ff ff ff    	jb     80101100 <balloc+0x16>
  panic("balloc: out of blocks");
80101194:	c7 04 24 b2 66 10 80 	movl   $0x801066b2,(%esp)
8010119b:	e8 85 f1 ff ff       	call   80100325 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
801011a0:	09 d1                	or     %edx,%ecx
801011a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801011a5:	8b 7d dc             	mov    -0x24(%ebp),%edi
801011a8:	88 4c 38 5c          	mov    %cl,0x5c(%eax,%edi,1)
        log_write(bp);
801011ac:	89 c7                	mov    %eax,%edi
801011ae:	89 04 24             	mov    %eax,(%esp)
801011b1:	e8 b4 17 00 00       	call   8010296a <log_write>
        brelse(bp);
801011b6:	89 3c 24             	mov    %edi,(%esp)
801011b9:	e8 04 f0 ff ff       	call   801001c2 <brelse>
        bzero(dev, b + bi);
801011be:	89 da                	mov    %ebx,%edx
801011c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
801011c3:	e8 6b fe ff ff       	call   80101033 <bzero>
}
801011c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011cb:	83 c4 2c             	add    $0x2c,%esp
801011ce:	5b                   	pop    %ebx
801011cf:	5e                   	pop    %esi
801011d0:	5f                   	pop    %edi
801011d1:	5d                   	pop    %ebp
801011d2:	c3                   	ret    

801011d3 <bmap>:
{
801011d3:	55                   	push   %ebp
801011d4:	89 e5                	mov    %esp,%ebp
801011d6:	57                   	push   %edi
801011d7:	56                   	push   %esi
801011d8:	53                   	push   %ebx
801011d9:	83 ec 1c             	sub    $0x1c,%esp
801011dc:	89 c3                	mov    %eax,%ebx
801011de:	89 d7                	mov    %edx,%edi
  if(bn < NDIRECT){
801011e0:	83 fa 0b             	cmp    $0xb,%edx
801011e3:	77 15                	ja     801011fa <bmap+0x27>
    if((addr = ip->addrs[bn]) == 0)
801011e5:	8b 44 90 5c          	mov    0x5c(%eax,%edx,4),%eax
801011e9:	85 c0                	test   %eax,%eax
801011eb:	75 77                	jne    80101264 <bmap+0x91>
      ip->addrs[bn] = addr = balloc(ip->dev);
801011ed:	8b 03                	mov    (%ebx),%eax
801011ef:	e8 f6 fe ff ff       	call   801010ea <balloc>
801011f4:	89 44 bb 5c          	mov    %eax,0x5c(%ebx,%edi,4)
    return addr;
801011f8:	eb 6a                	jmp    80101264 <bmap+0x91>
  bn -= NDIRECT;
801011fa:	8d 72 f4             	lea    -0xc(%edx),%esi
  if(bn < NINDIRECT){
801011fd:	83 fe 7f             	cmp    $0x7f,%esi
80101200:	77 56                	ja     80101258 <bmap+0x85>
    if((addr = ip->addrs[NDIRECT]) == 0)
80101202:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101208:	85 c0                	test   %eax,%eax
8010120a:	75 0d                	jne    80101219 <bmap+0x46>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
8010120c:	8b 03                	mov    (%ebx),%eax
8010120e:	e8 d7 fe ff ff       	call   801010ea <balloc>
80101213:	89 83 8c 00 00 00    	mov    %eax,0x8c(%ebx)
    bp = bread(ip->dev, addr);
80101219:	8b 13                	mov    (%ebx),%edx
8010121b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010121f:	89 14 24             	mov    %edx,(%esp)
80101222:	e8 3c ef ff ff       	call   80100163 <bread>
80101227:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
80101229:	8d 44 b0 5c          	lea    0x5c(%eax,%esi,4),%eax
8010122d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101230:	8b 30                	mov    (%eax),%esi
80101232:	85 f6                	test   %esi,%esi
80101234:	75 16                	jne    8010124c <bmap+0x79>
      a[bn] = addr = balloc(ip->dev);
80101236:	8b 03                	mov    (%ebx),%eax
80101238:	e8 ad fe ff ff       	call   801010ea <balloc>
8010123d:	89 c6                	mov    %eax,%esi
8010123f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101242:	89 30                	mov    %esi,(%eax)
      log_write(bp);
80101244:	89 3c 24             	mov    %edi,(%esp)
80101247:	e8 1e 17 00 00       	call   8010296a <log_write>
    brelse(bp);
8010124c:	89 3c 24             	mov    %edi,(%esp)
8010124f:	e8 6e ef ff ff       	call   801001c2 <brelse>
    return addr;
80101254:	89 f0                	mov    %esi,%eax
80101256:	eb 0c                	jmp    80101264 <bmap+0x91>
  panic("bmap: out of range");
80101258:	c7 04 24 c8 66 10 80 	movl   $0x801066c8,(%esp)
8010125f:	e8 c1 f0 ff ff       	call   80100325 <panic>
}
80101264:	83 c4 1c             	add    $0x1c,%esp
80101267:	5b                   	pop    %ebx
80101268:	5e                   	pop    %esi
80101269:	5f                   	pop    %edi
8010126a:	5d                   	pop    %ebp
8010126b:	c3                   	ret    

8010126c <iget>:
{
8010126c:	55                   	push   %ebp
8010126d:	89 e5                	mov    %esp,%ebp
8010126f:	57                   	push   %edi
80101270:	56                   	push   %esi
80101271:	53                   	push   %ebx
80101272:	83 ec 1c             	sub    $0x1c,%esp
80101275:	89 c7                	mov    %eax,%edi
80101277:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
8010127a:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
80101281:	e8 d6 29 00 00       	call   80103c5c <acquire>
  empty = 0;
80101286:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010128b:	bb 34 0a 11 80       	mov    $0x80110a34,%ebx
80101290:	eb 39                	jmp    801012cb <iget+0x5f>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101292:	8b 43 08             	mov    0x8(%ebx),%eax
80101295:	85 c0                	test   %eax,%eax
80101297:	7e 22                	jle    801012bb <iget+0x4f>
80101299:	39 3b                	cmp    %edi,(%ebx)
8010129b:	75 1e                	jne    801012bb <iget+0x4f>
8010129d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801012a0:	39 4b 04             	cmp    %ecx,0x4(%ebx)
801012a3:	75 16                	jne    801012bb <iget+0x4f>
      ip->ref++;
801012a5:	83 c0 01             	add    $0x1,%eax
801012a8:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
801012ab:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
801012b2:	e8 06 2a 00 00       	call   80103cbd <release>
      return ip;
801012b7:	89 de                	mov    %ebx,%esi
801012b9:	eb 4a                	jmp    80101305 <iget+0x99>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801012bb:	85 f6                	test   %esi,%esi
801012bd:	75 06                	jne    801012c5 <iget+0x59>
801012bf:	85 c0                	test   %eax,%eax
801012c1:	75 02                	jne    801012c5 <iget+0x59>
      empty = ip;
801012c3:	89 de                	mov    %ebx,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801012c5:	81 c3 90 00 00 00    	add    $0x90,%ebx
801012cb:	81 fb 54 26 11 80    	cmp    $0x80112654,%ebx
801012d1:	72 bf                	jb     80101292 <iget+0x26>
  if(empty == 0)
801012d3:	85 f6                	test   %esi,%esi
801012d5:	75 0c                	jne    801012e3 <iget+0x77>
    panic("iget: no inodes");
801012d7:	c7 04 24 db 66 10 80 	movl   $0x801066db,(%esp)
801012de:	e8 42 f0 ff ff       	call   80100325 <panic>
  ip->dev = dev;
801012e3:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
801012e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801012e8:	89 46 04             	mov    %eax,0x4(%esi)
  ip->ref = 1;
801012eb:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
801012f2:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
801012f9:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
80101300:	e8 b8 29 00 00       	call   80103cbd <release>
}
80101305:	89 f0                	mov    %esi,%eax
80101307:	83 c4 1c             	add    $0x1c,%esp
8010130a:	5b                   	pop    %ebx
8010130b:	5e                   	pop    %esi
8010130c:	5f                   	pop    %edi
8010130d:	5d                   	pop    %ebp
8010130e:	c3                   	ret    

8010130f <readsb>:
{
8010130f:	55                   	push   %ebp
80101310:	89 e5                	mov    %esp,%ebp
80101312:	53                   	push   %ebx
80101313:	83 ec 14             	sub    $0x14,%esp
  bp = bread(dev, 1);
80101316:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010131d:	00 
8010131e:	8b 45 08             	mov    0x8(%ebp),%eax
80101321:	89 04 24             	mov    %eax,(%esp)
80101324:	e8 3a ee ff ff       	call   80100163 <bread>
80101329:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
8010132b:	8d 40 5c             	lea    0x5c(%eax),%eax
8010132e:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
80101335:	00 
80101336:	89 44 24 04          	mov    %eax,0x4(%esp)
8010133a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010133d:	89 04 24             	mov    %eax,(%esp)
80101340:	e8 48 2a 00 00       	call   80103d8d <memmove>
  brelse(bp);
80101345:	89 1c 24             	mov    %ebx,(%esp)
80101348:	e8 75 ee ff ff       	call   801001c2 <brelse>
}
8010134d:	83 c4 14             	add    $0x14,%esp
80101350:	5b                   	pop    %ebx
80101351:	5d                   	pop    %ebp
80101352:	c3                   	ret    

80101353 <iinit>:
{
80101353:	55                   	push   %ebp
80101354:	89 e5                	mov    %esp,%ebp
80101356:	53                   	push   %ebx
80101357:	83 ec 24             	sub    $0x24,%esp
  initlock(&icache.lock, "icache");
8010135a:	c7 44 24 04 eb 66 10 	movl   $0x801066eb,0x4(%esp)
80101361:	80 
80101362:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
80101369:	e8 b6 27 00 00       	call   80103b24 <initlock>
  for(i = 0; i < NINODE; i++) {
8010136e:	bb 00 00 00 00       	mov    $0x0,%ebx
80101373:	eb 1e                	jmp    80101393 <iinit+0x40>
    initsleeplock(&icache.inode[i].lock, "inode");
80101375:	c7 44 24 04 f2 66 10 	movl   $0x801066f2,0x4(%esp)
8010137c:	80 
8010137d:	8d 04 db             	lea    (%ebx,%ebx,8),%eax
80101380:	c1 e0 04             	shl    $0x4,%eax
80101383:	05 40 0a 11 80       	add    $0x80110a40,%eax
80101388:	89 04 24             	mov    %eax,(%esp)
8010138b:	e8 8f 26 00 00       	call   80103a1f <initsleeplock>
  for(i = 0; i < NINODE; i++) {
80101390:	83 c3 01             	add    $0x1,%ebx
80101393:	83 fb 31             	cmp    $0x31,%ebx
80101396:	7e dd                	jle    80101375 <iinit+0x22>
  readsb(dev, &sb);
80101398:	c7 44 24 04 e0 09 11 	movl   $0x801109e0,0x4(%esp)
8010139f:	80 
801013a0:	8b 45 08             	mov    0x8(%ebp),%eax
801013a3:	89 04 24             	mov    %eax,(%esp)
801013a6:	e8 64 ff ff ff       	call   8010130f <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801013ab:	a1 f8 09 11 80       	mov    0x801109f8,%eax
801013b0:	89 44 24 1c          	mov    %eax,0x1c(%esp)
801013b4:	a1 f4 09 11 80       	mov    0x801109f4,%eax
801013b9:	89 44 24 18          	mov    %eax,0x18(%esp)
801013bd:	a1 f0 09 11 80       	mov    0x801109f0,%eax
801013c2:	89 44 24 14          	mov    %eax,0x14(%esp)
801013c6:	a1 ec 09 11 80       	mov    0x801109ec,%eax
801013cb:	89 44 24 10          	mov    %eax,0x10(%esp)
801013cf:	a1 e8 09 11 80       	mov    0x801109e8,%eax
801013d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
801013d8:	a1 e4 09 11 80       	mov    0x801109e4,%eax
801013dd:	89 44 24 08          	mov    %eax,0x8(%esp)
801013e1:	a1 e0 09 11 80       	mov    0x801109e0,%eax
801013e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801013ea:	c7 04 24 58 67 10 80 	movl   $0x80106758,(%esp)
801013f1:	e8 d1 f1 ff ff       	call   801005c7 <cprintf>
}
801013f6:	83 c4 24             	add    $0x24,%esp
801013f9:	5b                   	pop    %ebx
801013fa:	5d                   	pop    %ebp
801013fb:	c3                   	ret    

801013fc <ialloc>:
{
801013fc:	55                   	push   %ebp
801013fd:	89 e5                	mov    %esp,%ebp
801013ff:	57                   	push   %edi
80101400:	56                   	push   %esi
80101401:	53                   	push   %ebx
80101402:	83 ec 2c             	sub    $0x2c,%esp
80101405:	8b 45 0c             	mov    0xc(%ebp),%eax
80101408:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
8010140b:	bb 01 00 00 00       	mov    $0x1,%ebx
80101410:	eb 39                	jmp    8010144b <ialloc+0x4f>
    bp = bread(dev, IBLOCK(inum, sb));
80101412:	89 d8                	mov    %ebx,%eax
80101414:	c1 e8 03             	shr    $0x3,%eax
80101417:	03 05 f4 09 11 80    	add    0x801109f4,%eax
8010141d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101421:	8b 45 08             	mov    0x8(%ebp),%eax
80101424:	89 04 24             	mov    %eax,(%esp)
80101427:	e8 37 ed ff ff       	call   80100163 <bread>
8010142c:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + inum%IPB;
8010142e:	89 d8                	mov    %ebx,%eax
80101430:	83 e0 07             	and    $0x7,%eax
80101433:	c1 e0 06             	shl    $0x6,%eax
80101436:	8d 7c 06 5c          	lea    0x5c(%esi,%eax,1),%edi
    if(dip->type == 0){  // a free inode
8010143a:	66 83 3f 00          	cmpw   $0x0,(%edi)
8010143e:	74 22                	je     80101462 <ialloc+0x66>
    brelse(bp);
80101440:	89 34 24             	mov    %esi,(%esp)
80101443:	e8 7a ed ff ff       	call   801001c2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
80101448:	83 c3 01             	add    $0x1,%ebx
8010144b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
8010144e:	3b 1d e8 09 11 80    	cmp    0x801109e8,%ebx
80101454:	72 bc                	jb     80101412 <ialloc+0x16>
  panic("ialloc: no inodes");
80101456:	c7 04 24 f8 66 10 80 	movl   $0x801066f8,(%esp)
8010145d:	e8 c3 ee ff ff       	call   80100325 <panic>
      memset(dip, 0, sizeof(*dip));
80101462:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101469:	00 
8010146a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101471:	00 
80101472:	89 3c 24             	mov    %edi,(%esp)
80101475:	e8 96 28 00 00       	call   80103d10 <memset>
      dip->type = type;
8010147a:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010147e:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
80101481:	89 34 24             	mov    %esi,(%esp)
80101484:	e8 e1 14 00 00       	call   8010296a <log_write>
      brelse(bp);
80101489:	89 34 24             	mov    %esi,(%esp)
8010148c:	e8 31 ed ff ff       	call   801001c2 <brelse>
      return iget(dev, inum);
80101491:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101494:	8b 45 08             	mov    0x8(%ebp),%eax
80101497:	e8 d0 fd ff ff       	call   8010126c <iget>
}
8010149c:	83 c4 2c             	add    $0x2c,%esp
8010149f:	5b                   	pop    %ebx
801014a0:	5e                   	pop    %esi
801014a1:	5f                   	pop    %edi
801014a2:	5d                   	pop    %ebp
801014a3:	c3                   	ret    

801014a4 <iupdate>:
{
801014a4:	55                   	push   %ebp
801014a5:	89 e5                	mov    %esp,%ebp
801014a7:	56                   	push   %esi
801014a8:	53                   	push   %ebx
801014a9:	83 ec 10             	sub    $0x10,%esp
801014ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801014af:	8b 53 04             	mov    0x4(%ebx),%edx
801014b2:	c1 ea 03             	shr    $0x3,%edx
801014b5:	03 15 f4 09 11 80    	add    0x801109f4,%edx
801014bb:	8b 03                	mov    (%ebx),%eax
801014bd:	89 54 24 04          	mov    %edx,0x4(%esp)
801014c1:	89 04 24             	mov    %eax,(%esp)
801014c4:	e8 9a ec ff ff       	call   80100163 <bread>
801014c9:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801014cb:	8b 43 04             	mov    0x4(%ebx),%eax
801014ce:	83 e0 07             	and    $0x7,%eax
801014d1:	c1 e0 06             	shl    $0x6,%eax
801014d4:	8d 54 06 5c          	lea    0x5c(%esi,%eax,1),%edx
  dip->type = ip->type;
801014d8:	0f b7 43 50          	movzwl 0x50(%ebx),%eax
801014dc:	66 89 02             	mov    %ax,(%edx)
  dip->major = ip->major;
801014df:	0f b7 43 52          	movzwl 0x52(%ebx),%eax
801014e3:	66 89 42 02          	mov    %ax,0x2(%edx)
  dip->minor = ip->minor;
801014e7:	0f b7 43 54          	movzwl 0x54(%ebx),%eax
801014eb:	66 89 42 04          	mov    %ax,0x4(%edx)
  dip->nlink = ip->nlink;
801014ef:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801014f3:	66 89 42 06          	mov    %ax,0x6(%edx)
  dip->size = ip->size;
801014f7:	8b 43 58             	mov    0x58(%ebx),%eax
801014fa:	89 42 08             	mov    %eax,0x8(%edx)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801014fd:	83 c3 5c             	add    $0x5c,%ebx
80101500:	83 c2 0c             	add    $0xc,%edx
80101503:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
8010150a:	00 
8010150b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
8010150f:	89 14 24             	mov    %edx,(%esp)
80101512:	e8 76 28 00 00       	call   80103d8d <memmove>
  log_write(bp);
80101517:	89 34 24             	mov    %esi,(%esp)
8010151a:	e8 4b 14 00 00       	call   8010296a <log_write>
  brelse(bp);
8010151f:	89 34 24             	mov    %esi,(%esp)
80101522:	e8 9b ec ff ff       	call   801001c2 <brelse>
}
80101527:	83 c4 10             	add    $0x10,%esp
8010152a:	5b                   	pop    %ebx
8010152b:	5e                   	pop    %esi
8010152c:	5d                   	pop    %ebp
8010152d:	c3                   	ret    

8010152e <itrunc>:
{
8010152e:	55                   	push   %ebp
8010152f:	89 e5                	mov    %esp,%ebp
80101531:	57                   	push   %edi
80101532:	56                   	push   %esi
80101533:	53                   	push   %ebx
80101534:	83 ec 1c             	sub    $0x1c,%esp
80101537:	89 c7                	mov    %eax,%edi
  for(i = 0; i < NDIRECT; i++){
80101539:	bb 00 00 00 00       	mov    $0x0,%ebx
8010153e:	eb 1a                	jmp    8010155a <itrunc+0x2c>
    if(ip->addrs[i]){
80101540:	8b 54 9f 5c          	mov    0x5c(%edi,%ebx,4),%edx
80101544:	85 d2                	test   %edx,%edx
80101546:	74 0f                	je     80101557 <itrunc+0x29>
      bfree(ip->dev, ip->addrs[i]);
80101548:	8b 07                	mov    (%edi),%eax
8010154a:	e8 2a fb ff ff       	call   80101079 <bfree>
      ip->addrs[i] = 0;
8010154f:	c7 44 9f 5c 00 00 00 	movl   $0x0,0x5c(%edi,%ebx,4)
80101556:	00 
  for(i = 0; i < NDIRECT; i++){
80101557:	83 c3 01             	add    $0x1,%ebx
8010155a:	83 fb 0b             	cmp    $0xb,%ebx
8010155d:	7e e1                	jle    80101540 <itrunc+0x12>
  if(ip->addrs[NDIRECT]){
8010155f:	8b 87 8c 00 00 00    	mov    0x8c(%edi),%eax
80101565:	85 c0                	test   %eax,%eax
80101567:	74 53                	je     801015bc <itrunc+0x8e>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101569:	8b 17                	mov    (%edi),%edx
8010156b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010156f:	89 14 24             	mov    %edx,(%esp)
80101572:	e8 ec eb ff ff       	call   80100163 <bread>
80101577:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
8010157a:	8d 70 5c             	lea    0x5c(%eax),%esi
    for(j = 0; j < NINDIRECT; j++){
8010157d:	bb 00 00 00 00       	mov    $0x0,%ebx
80101582:	eb 11                	jmp    80101595 <itrunc+0x67>
      if(a[j])
80101584:	8b 14 9e             	mov    (%esi,%ebx,4),%edx
80101587:	85 d2                	test   %edx,%edx
80101589:	74 07                	je     80101592 <itrunc+0x64>
        bfree(ip->dev, a[j]);
8010158b:	8b 07                	mov    (%edi),%eax
8010158d:	e8 e7 fa ff ff       	call   80101079 <bfree>
    for(j = 0; j < NINDIRECT; j++){
80101592:	83 c3 01             	add    $0x1,%ebx
80101595:	83 fb 7f             	cmp    $0x7f,%ebx
80101598:	76 ea                	jbe    80101584 <itrunc+0x56>
    brelse(bp);
8010159a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010159d:	89 04 24             	mov    %eax,(%esp)
801015a0:	e8 1d ec ff ff       	call   801001c2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
801015a5:	8b 07                	mov    (%edi),%eax
801015a7:	8b 97 8c 00 00 00    	mov    0x8c(%edi),%edx
801015ad:	e8 c7 fa ff ff       	call   80101079 <bfree>
    ip->addrs[NDIRECT] = 0;
801015b2:	c7 87 8c 00 00 00 00 	movl   $0x0,0x8c(%edi)
801015b9:	00 00 00 
  ip->size = 0;
801015bc:	c7 47 58 00 00 00 00 	movl   $0x0,0x58(%edi)
  iupdate(ip);
801015c3:	89 3c 24             	mov    %edi,(%esp)
801015c6:	e8 d9 fe ff ff       	call   801014a4 <iupdate>
}
801015cb:	83 c4 1c             	add    $0x1c,%esp
801015ce:	5b                   	pop    %ebx
801015cf:	5e                   	pop    %esi
801015d0:	5f                   	pop    %edi
801015d1:	5d                   	pop    %ebp
801015d2:	c3                   	ret    

801015d3 <idup>:
{
801015d3:	55                   	push   %ebp
801015d4:	89 e5                	mov    %esp,%ebp
801015d6:	53                   	push   %ebx
801015d7:	83 ec 14             	sub    $0x14,%esp
801015da:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
801015dd:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
801015e4:	e8 73 26 00 00       	call   80103c5c <acquire>
  ip->ref++;
801015e9:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
801015ed:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
801015f4:	e8 c4 26 00 00       	call   80103cbd <release>
}
801015f9:	89 d8                	mov    %ebx,%eax
801015fb:	83 c4 14             	add    $0x14,%esp
801015fe:	5b                   	pop    %ebx
801015ff:	5d                   	pop    %ebp
80101600:	c3                   	ret    

80101601 <ilock>:
{
80101601:	55                   	push   %ebp
80101602:	89 e5                	mov    %esp,%ebp
80101604:	56                   	push   %esi
80101605:	53                   	push   %ebx
80101606:	83 ec 10             	sub    $0x10,%esp
80101609:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
8010160c:	85 db                	test   %ebx,%ebx
8010160e:	74 06                	je     80101616 <ilock+0x15>
80101610:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101614:	7f 0c                	jg     80101622 <ilock+0x21>
    panic("ilock");
80101616:	c7 04 24 0a 67 10 80 	movl   $0x8010670a,(%esp)
8010161d:	e8 03 ed ff ff       	call   80100325 <panic>
  acquiresleep(&ip->lock);
80101622:	8d 43 0c             	lea    0xc(%ebx),%eax
80101625:	89 04 24             	mov    %eax,(%esp)
80101628:	e8 28 24 00 00       	call   80103a55 <acquiresleep>
  if(ip->valid == 0){
8010162d:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101631:	0f 85 8a 00 00 00    	jne    801016c1 <ilock+0xc0>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101637:	8b 53 04             	mov    0x4(%ebx),%edx
8010163a:	c1 ea 03             	shr    $0x3,%edx
8010163d:	03 15 f4 09 11 80    	add    0x801109f4,%edx
80101643:	8b 03                	mov    (%ebx),%eax
80101645:	89 54 24 04          	mov    %edx,0x4(%esp)
80101649:	89 04 24             	mov    %eax,(%esp)
8010164c:	e8 12 eb ff ff       	call   80100163 <bread>
80101651:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101653:	8b 43 04             	mov    0x4(%ebx),%eax
80101656:	83 e0 07             	and    $0x7,%eax
80101659:	c1 e0 06             	shl    $0x6,%eax
8010165c:	8d 54 06 5c          	lea    0x5c(%esi,%eax,1),%edx
    ip->type = dip->type;
80101660:	0f b7 02             	movzwl (%edx),%eax
80101663:	66 89 43 50          	mov    %ax,0x50(%ebx)
    ip->major = dip->major;
80101667:	0f b7 42 02          	movzwl 0x2(%edx),%eax
8010166b:	66 89 43 52          	mov    %ax,0x52(%ebx)
    ip->minor = dip->minor;
8010166f:	0f b7 42 04          	movzwl 0x4(%edx),%eax
80101673:	66 89 43 54          	mov    %ax,0x54(%ebx)
    ip->nlink = dip->nlink;
80101677:	0f b7 42 06          	movzwl 0x6(%edx),%eax
8010167b:	66 89 43 56          	mov    %ax,0x56(%ebx)
    ip->size = dip->size;
8010167f:	8b 42 08             	mov    0x8(%edx),%eax
80101682:	89 43 58             	mov    %eax,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101685:	83 c2 0c             	add    $0xc,%edx
80101688:	8d 43 5c             	lea    0x5c(%ebx),%eax
8010168b:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101692:	00 
80101693:	89 54 24 04          	mov    %edx,0x4(%esp)
80101697:	89 04 24             	mov    %eax,(%esp)
8010169a:	e8 ee 26 00 00       	call   80103d8d <memmove>
    brelse(bp);
8010169f:	89 34 24             	mov    %esi,(%esp)
801016a2:	e8 1b eb ff ff       	call   801001c2 <brelse>
    ip->valid = 1;
801016a7:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
801016ae:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
801016b3:	75 0c                	jne    801016c1 <ilock+0xc0>
      panic("ilock: no type");
801016b5:	c7 04 24 10 67 10 80 	movl   $0x80106710,(%esp)
801016bc:	e8 64 ec ff ff       	call   80100325 <panic>
}
801016c1:	83 c4 10             	add    $0x10,%esp
801016c4:	5b                   	pop    %ebx
801016c5:	5e                   	pop    %esi
801016c6:	5d                   	pop    %ebp
801016c7:	c3                   	ret    

801016c8 <iunlock>:
{
801016c8:	55                   	push   %ebp
801016c9:	89 e5                	mov    %esp,%ebp
801016cb:	56                   	push   %esi
801016cc:	53                   	push   %ebx
801016cd:	83 ec 10             	sub    $0x10,%esp
801016d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801016d3:	85 db                	test   %ebx,%ebx
801016d5:	74 15                	je     801016ec <iunlock+0x24>
801016d7:	8d 73 0c             	lea    0xc(%ebx),%esi
801016da:	89 34 24             	mov    %esi,(%esp)
801016dd:	e8 f6 23 00 00       	call   80103ad8 <holdingsleep>
801016e2:	85 c0                	test   %eax,%eax
801016e4:	74 06                	je     801016ec <iunlock+0x24>
801016e6:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
801016ea:	7f 0c                	jg     801016f8 <iunlock+0x30>
    panic("iunlock");
801016ec:	c7 04 24 1f 67 10 80 	movl   $0x8010671f,(%esp)
801016f3:	e8 2d ec ff ff       	call   80100325 <panic>
  releasesleep(&ip->lock);
801016f8:	89 34 24             	mov    %esi,(%esp)
801016fb:	e8 9e 23 00 00       	call   80103a9e <releasesleep>
}
80101700:	83 c4 10             	add    $0x10,%esp
80101703:	5b                   	pop    %ebx
80101704:	5e                   	pop    %esi
80101705:	5d                   	pop    %ebp
80101706:	c3                   	ret    

80101707 <iput>:
{
80101707:	55                   	push   %ebp
80101708:	89 e5                	mov    %esp,%ebp
8010170a:	57                   	push   %edi
8010170b:	56                   	push   %esi
8010170c:	53                   	push   %ebx
8010170d:	83 ec 1c             	sub    $0x1c,%esp
80101710:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
80101713:	8d 73 0c             	lea    0xc(%ebx),%esi
80101716:	89 34 24             	mov    %esi,(%esp)
80101719:	e8 37 23 00 00       	call   80103a55 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010171e:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101722:	74 43                	je     80101767 <iput+0x60>
80101724:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101729:	75 3c                	jne    80101767 <iput+0x60>
    acquire(&icache.lock);
8010172b:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
80101732:	e8 25 25 00 00       	call   80103c5c <acquire>
    int r = ip->ref;
80101737:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
8010173a:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
80101741:	e8 77 25 00 00       	call   80103cbd <release>
    if(r == 1){
80101746:	83 ff 01             	cmp    $0x1,%edi
80101749:	75 1c                	jne    80101767 <iput+0x60>
      itrunc(ip);
8010174b:	89 d8                	mov    %ebx,%eax
8010174d:	e8 dc fd ff ff       	call   8010152e <itrunc>
      ip->type = 0;
80101752:	66 c7 43 50 00 00    	movw   $0x0,0x50(%ebx)
      iupdate(ip);
80101758:	89 1c 24             	mov    %ebx,(%esp)
8010175b:	e8 44 fd ff ff       	call   801014a4 <iupdate>
      ip->valid = 0;
80101760:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
  releasesleep(&ip->lock);
80101767:	89 34 24             	mov    %esi,(%esp)
8010176a:	e8 2f 23 00 00       	call   80103a9e <releasesleep>
  acquire(&icache.lock);
8010176f:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
80101776:	e8 e1 24 00 00       	call   80103c5c <acquire>
  ip->ref--;
8010177b:	83 6b 08 01          	subl   $0x1,0x8(%ebx)
  release(&icache.lock);
8010177f:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
80101786:	e8 32 25 00 00       	call   80103cbd <release>
}
8010178b:	83 c4 1c             	add    $0x1c,%esp
8010178e:	5b                   	pop    %ebx
8010178f:	5e                   	pop    %esi
80101790:	5f                   	pop    %edi
80101791:	5d                   	pop    %ebp
80101792:	c3                   	ret    

80101793 <iunlockput>:
{
80101793:	55                   	push   %ebp
80101794:	89 e5                	mov    %esp,%ebp
80101796:	53                   	push   %ebx
80101797:	83 ec 14             	sub    $0x14,%esp
8010179a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
8010179d:	89 1c 24             	mov    %ebx,(%esp)
801017a0:	e8 23 ff ff ff       	call   801016c8 <iunlock>
  iput(ip);
801017a5:	89 1c 24             	mov    %ebx,(%esp)
801017a8:	e8 5a ff ff ff       	call   80101707 <iput>
}
801017ad:	83 c4 14             	add    $0x14,%esp
801017b0:	5b                   	pop    %ebx
801017b1:	5d                   	pop    %ebp
801017b2:	c3                   	ret    

801017b3 <stati>:
{
801017b3:	55                   	push   %ebp
801017b4:	89 e5                	mov    %esp,%ebp
801017b6:	8b 55 08             	mov    0x8(%ebp),%edx
801017b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
801017bc:	8b 0a                	mov    (%edx),%ecx
801017be:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
801017c1:	8b 4a 04             	mov    0x4(%edx),%ecx
801017c4:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
801017c7:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
801017cb:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
801017ce:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
801017d2:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
801017d6:	8b 52 58             	mov    0x58(%edx),%edx
801017d9:	89 50 10             	mov    %edx,0x10(%eax)
}
801017dc:	5d                   	pop    %ebp
801017dd:	c3                   	ret    

801017de <readi>:
{
801017de:	55                   	push   %ebp
801017df:	89 e5                	mov    %esp,%ebp
801017e1:	57                   	push   %edi
801017e2:	56                   	push   %esi
801017e3:	53                   	push   %ebx
801017e4:	83 ec 1c             	sub    $0x1c,%esp
801017e7:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(ip->type == T_DEV){
801017ea:	8b 45 08             	mov    0x8(%ebp),%eax
801017ed:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
801017f2:	75 39                	jne    8010182d <readi+0x4f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801017f4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801017f8:	66 83 f8 09          	cmp    $0x9,%ax
801017fc:	0f 87 c2 00 00 00    	ja     801018c4 <readi+0xe6>
80101802:	98                   	cwtl   
80101803:	8b 04 c5 80 09 11 80 	mov    -0x7feef680(,%eax,8),%eax
8010180a:	85 c0                	test   %eax,%eax
8010180c:	0f 84 b9 00 00 00    	je     801018cb <readi+0xed>
    return devsw[ip->major].read(ip, dst, n);
80101812:	8b 75 14             	mov    0x14(%ebp),%esi
80101815:	89 74 24 08          	mov    %esi,0x8(%esp)
80101819:	8b 75 0c             	mov    0xc(%ebp),%esi
8010181c:	89 74 24 04          	mov    %esi,0x4(%esp)
80101820:	8b 75 08             	mov    0x8(%ebp),%esi
80101823:	89 34 24             	mov    %esi,(%esp)
80101826:	ff d0                	call   *%eax
80101828:	e9 b1 00 00 00       	jmp    801018de <readi+0x100>
  if(off > ip->size || off + n < off)
8010182d:	8b 45 08             	mov    0x8(%ebp),%eax
80101830:	8b 40 58             	mov    0x58(%eax),%eax
80101833:	39 f8                	cmp    %edi,%eax
80101835:	0f 82 97 00 00 00    	jb     801018d2 <readi+0xf4>
8010183b:	89 fa                	mov    %edi,%edx
8010183d:	03 55 14             	add    0x14(%ebp),%edx
80101840:	0f 82 93 00 00 00    	jb     801018d9 <readi+0xfb>
  if(off + n > ip->size)
80101846:	39 d0                	cmp    %edx,%eax
80101848:	73 05                	jae    8010184f <readi+0x71>
    n = ip->size - off;
8010184a:	29 f8                	sub    %edi,%eax
8010184c:	89 45 14             	mov    %eax,0x14(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010184f:	be 00 00 00 00       	mov    $0x0,%esi
80101854:	eb 64                	jmp    801018ba <readi+0xdc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101856:	89 fa                	mov    %edi,%edx
80101858:	c1 ea 09             	shr    $0x9,%edx
8010185b:	8b 45 08             	mov    0x8(%ebp),%eax
8010185e:	e8 70 f9 ff ff       	call   801011d3 <bmap>
80101863:	8b 4d 08             	mov    0x8(%ebp),%ecx
80101866:	8b 11                	mov    (%ecx),%edx
80101868:	89 44 24 04          	mov    %eax,0x4(%esp)
8010186c:	89 14 24             	mov    %edx,(%esp)
8010186f:	e8 ef e8 ff ff       	call   80100163 <bread>
80101874:	89 c1                	mov    %eax,%ecx
    m = min(n - tot, BSIZE - off%BSIZE);
80101876:	89 f8                	mov    %edi,%eax
80101878:	25 ff 01 00 00       	and    $0x1ff,%eax
8010187d:	bb 00 02 00 00       	mov    $0x200,%ebx
80101882:	29 c3                	sub    %eax,%ebx
80101884:	8b 55 14             	mov    0x14(%ebp),%edx
80101887:	29 f2                	sub    %esi,%edx
80101889:	39 d3                	cmp    %edx,%ebx
8010188b:	0f 47 da             	cmova  %edx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
8010188e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80101891:	8d 44 01 5c          	lea    0x5c(%ecx,%eax,1),%eax
80101895:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80101899:	89 44 24 04          	mov    %eax,0x4(%esp)
8010189d:	8b 45 0c             	mov    0xc(%ebp),%eax
801018a0:	89 04 24             	mov    %eax,(%esp)
801018a3:	e8 e5 24 00 00       	call   80103d8d <memmove>
    brelse(bp);
801018a8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801018ab:	89 0c 24             	mov    %ecx,(%esp)
801018ae:	e8 0f e9 ff ff       	call   801001c2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801018b3:	01 de                	add    %ebx,%esi
801018b5:	01 df                	add    %ebx,%edi
801018b7:	01 5d 0c             	add    %ebx,0xc(%ebp)
801018ba:	3b 75 14             	cmp    0x14(%ebp),%esi
801018bd:	72 97                	jb     80101856 <readi+0x78>
  return n;
801018bf:	8b 45 14             	mov    0x14(%ebp),%eax
801018c2:	eb 1a                	jmp    801018de <readi+0x100>
      return -1;
801018c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801018c9:	eb 13                	jmp    801018de <readi+0x100>
801018cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801018d0:	eb 0c                	jmp    801018de <readi+0x100>
    return -1;
801018d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801018d7:	eb 05                	jmp    801018de <readi+0x100>
801018d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801018de:	83 c4 1c             	add    $0x1c,%esp
801018e1:	5b                   	pop    %ebx
801018e2:	5e                   	pop    %esi
801018e3:	5f                   	pop    %edi
801018e4:	5d                   	pop    %ebp
801018e5:	c3                   	ret    

801018e6 <writei>:
{
801018e6:	55                   	push   %ebp
801018e7:	89 e5                	mov    %esp,%ebp
801018e9:	57                   	push   %edi
801018ea:	56                   	push   %esi
801018eb:	53                   	push   %ebx
801018ec:	83 ec 1c             	sub    $0x1c,%esp
  if(ip->type == T_DEV){
801018ef:	8b 45 08             	mov    0x8(%ebp),%eax
801018f2:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
801018f7:	75 39                	jne    80101932 <writei+0x4c>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801018f9:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801018fd:	66 83 f8 09          	cmp    $0x9,%ax
80101901:	0f 87 e6 00 00 00    	ja     801019ed <writei+0x107>
80101907:	98                   	cwtl   
80101908:	8b 04 c5 84 09 11 80 	mov    -0x7feef67c(,%eax,8),%eax
8010190f:	85 c0                	test   %eax,%eax
80101911:	0f 84 dd 00 00 00    	je     801019f4 <writei+0x10e>
    return devsw[ip->major].write(ip, src, n);
80101917:	8b 75 14             	mov    0x14(%ebp),%esi
8010191a:	89 74 24 08          	mov    %esi,0x8(%esp)
8010191e:	8b 75 0c             	mov    0xc(%ebp),%esi
80101921:	89 74 24 04          	mov    %esi,0x4(%esp)
80101925:	8b 75 08             	mov    0x8(%ebp),%esi
80101928:	89 34 24             	mov    %esi,(%esp)
8010192b:	ff d0                	call   *%eax
8010192d:	e9 dc 00 00 00       	jmp    80101a0e <writei+0x128>
  if(off > ip->size || off + n < off)
80101932:	8b 45 08             	mov    0x8(%ebp),%eax
80101935:	8b 75 10             	mov    0x10(%ebp),%esi
80101938:	39 70 58             	cmp    %esi,0x58(%eax)
8010193b:	0f 82 ba 00 00 00    	jb     801019fb <writei+0x115>
80101941:	89 f0                	mov    %esi,%eax
80101943:	03 45 14             	add    0x14(%ebp),%eax
80101946:	0f 82 b6 00 00 00    	jb     80101a02 <writei+0x11c>
  if(off + n > MAXFILE*BSIZE)
8010194c:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101951:	0f 87 b2 00 00 00    	ja     80101a09 <writei+0x123>
80101957:	be 00 00 00 00       	mov    $0x0,%esi
8010195c:	eb 69                	jmp    801019c7 <writei+0xe1>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010195e:	8b 55 10             	mov    0x10(%ebp),%edx
80101961:	c1 ea 09             	shr    $0x9,%edx
80101964:	8b 45 08             	mov    0x8(%ebp),%eax
80101967:	e8 67 f8 ff ff       	call   801011d3 <bmap>
8010196c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010196f:	8b 11                	mov    (%ecx),%edx
80101971:	89 44 24 04          	mov    %eax,0x4(%esp)
80101975:	89 14 24             	mov    %edx,(%esp)
80101978:	e8 e6 e7 ff ff       	call   80100163 <bread>
8010197d:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
8010197f:	8b 45 10             	mov    0x10(%ebp),%eax
80101982:	25 ff 01 00 00       	and    $0x1ff,%eax
80101987:	bb 00 02 00 00       	mov    $0x200,%ebx
8010198c:	29 c3                	sub    %eax,%ebx
8010198e:	8b 55 14             	mov    0x14(%ebp),%edx
80101991:	29 f2                	sub    %esi,%edx
80101993:	39 d3                	cmp    %edx,%ebx
80101995:	0f 47 da             	cmova  %edx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101998:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
8010199c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801019a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801019a3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
801019a7:	89 04 24             	mov    %eax,(%esp)
801019aa:	e8 de 23 00 00       	call   80103d8d <memmove>
    log_write(bp);
801019af:	89 3c 24             	mov    %edi,(%esp)
801019b2:	e8 b3 0f 00 00       	call   8010296a <log_write>
    brelse(bp);
801019b7:	89 3c 24             	mov    %edi,(%esp)
801019ba:	e8 03 e8 ff ff       	call   801001c2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801019bf:	01 de                	add    %ebx,%esi
801019c1:	01 5d 10             	add    %ebx,0x10(%ebp)
801019c4:	01 5d 0c             	add    %ebx,0xc(%ebp)
801019c7:	3b 75 14             	cmp    0x14(%ebp),%esi
801019ca:	72 92                	jb     8010195e <writei+0x78>
  if(n > 0 && off > ip->size){
801019cc:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801019d0:	74 16                	je     801019e8 <writei+0x102>
801019d2:	8b 45 08             	mov    0x8(%ebp),%eax
801019d5:	8b 75 10             	mov    0x10(%ebp),%esi
801019d8:	39 70 58             	cmp    %esi,0x58(%eax)
801019db:	73 0b                	jae    801019e8 <writei+0x102>
    ip->size = off;
801019dd:	89 70 58             	mov    %esi,0x58(%eax)
    iupdate(ip);
801019e0:	89 04 24             	mov    %eax,(%esp)
801019e3:	e8 bc fa ff ff       	call   801014a4 <iupdate>
  return n;
801019e8:	8b 45 14             	mov    0x14(%ebp),%eax
801019eb:	eb 21                	jmp    80101a0e <writei+0x128>
      return -1;
801019ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801019f2:	eb 1a                	jmp    80101a0e <writei+0x128>
801019f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801019f9:	eb 13                	jmp    80101a0e <writei+0x128>
    return -1;
801019fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101a00:	eb 0c                	jmp    80101a0e <writei+0x128>
80101a02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101a07:	eb 05                	jmp    80101a0e <writei+0x128>
    return -1;
80101a09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101a0e:	83 c4 1c             	add    $0x1c,%esp
80101a11:	5b                   	pop    %ebx
80101a12:	5e                   	pop    %esi
80101a13:	5f                   	pop    %edi
80101a14:	5d                   	pop    %ebp
80101a15:	c3                   	ret    

80101a16 <namecmp>:
{
80101a16:	55                   	push   %ebp
80101a17:	89 e5                	mov    %esp,%ebp
80101a19:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80101a1c:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80101a23:	00 
80101a24:	8b 45 0c             	mov    0xc(%ebp),%eax
80101a27:	89 44 24 04          	mov    %eax,0x4(%esp)
80101a2b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2e:	89 04 24             	mov    %eax,(%esp)
80101a31:	e8 cc 23 00 00       	call   80103e02 <strncmp>
}
80101a36:	c9                   	leave  
80101a37:	c3                   	ret    

80101a38 <dirlookup>:
{
80101a38:	55                   	push   %ebp
80101a39:	89 e5                	mov    %esp,%ebp
80101a3b:	57                   	push   %edi
80101a3c:	56                   	push   %esi
80101a3d:	53                   	push   %ebx
80101a3e:	83 ec 2c             	sub    $0x2c,%esp
80101a41:	8b 75 08             	mov    0x8(%ebp),%esi
  if(dp->type != T_DIR)
80101a44:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101a49:	74 6f                	je     80101aba <dirlookup+0x82>
    panic("dirlookup not DIR");
80101a4b:	c7 04 24 27 67 10 80 	movl   $0x80106727,(%esp)
80101a52:	e8 ce e8 ff ff       	call   80100325 <panic>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101a57:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80101a5e:	00 
80101a5f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80101a63:	89 7c 24 04          	mov    %edi,0x4(%esp)
80101a67:	89 34 24             	mov    %esi,(%esp)
80101a6a:	e8 6f fd ff ff       	call   801017de <readi>
80101a6f:	83 f8 10             	cmp    $0x10,%eax
80101a72:	74 0c                	je     80101a80 <dirlookup+0x48>
      panic("dirlookup read");
80101a74:	c7 04 24 39 67 10 80 	movl   $0x80106739,(%esp)
80101a7b:	e8 a5 e8 ff ff       	call   80100325 <panic>
    if(de.inum == 0)
80101a80:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101a85:	74 2e                	je     80101ab5 <dirlookup+0x7d>
    if(namecmp(name, de.name) == 0){
80101a87:	8d 45 da             	lea    -0x26(%ebp),%eax
80101a8a:	89 44 24 04          	mov    %eax,0x4(%esp)
80101a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101a91:	89 04 24             	mov    %eax,(%esp)
80101a94:	e8 7d ff ff ff       	call   80101a16 <namecmp>
80101a99:	85 c0                	test   %eax,%eax
80101a9b:	75 18                	jne    80101ab5 <dirlookup+0x7d>
      if(poff)
80101a9d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80101aa1:	74 05                	je     80101aa8 <dirlookup+0x70>
        *poff = off;
80101aa3:	8b 45 10             	mov    0x10(%ebp),%eax
80101aa6:	89 18                	mov    %ebx,(%eax)
      inum = de.inum;
80101aa8:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101aac:	8b 06                	mov    (%esi),%eax
80101aae:	e8 b9 f7 ff ff       	call   8010126c <iget>
80101ab3:	eb 17                	jmp    80101acc <dirlookup+0x94>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101ab5:	83 c3 10             	add    $0x10,%ebx
80101ab8:	eb 08                	jmp    80101ac2 <dirlookup+0x8a>
80101aba:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101abf:	8d 7d d8             	lea    -0x28(%ebp),%edi
  for(off = 0; off < dp->size; off += sizeof(de)){
80101ac2:	39 5e 58             	cmp    %ebx,0x58(%esi)
80101ac5:	77 90                	ja     80101a57 <dirlookup+0x1f>
  return 0;
80101ac7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101acc:	83 c4 2c             	add    $0x2c,%esp
80101acf:	5b                   	pop    %ebx
80101ad0:	5e                   	pop    %esi
80101ad1:	5f                   	pop    %edi
80101ad2:	5d                   	pop    %ebp
80101ad3:	c3                   	ret    

80101ad4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101ad4:	55                   	push   %ebp
80101ad5:	89 e5                	mov    %esp,%ebp
80101ad7:	57                   	push   %edi
80101ad8:	56                   	push   %esi
80101ad9:	53                   	push   %ebx
80101ada:	83 ec 2c             	sub    $0x2c,%esp
80101add:	89 c6                	mov    %eax,%esi
80101adf:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101ae2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
80101ae5:	80 38 2f             	cmpb   $0x2f,(%eax)
80101ae8:	75 13                	jne    80101afd <namex+0x29>
    ip = iget(ROOTDEV, ROOTINO);
80101aea:	ba 01 00 00 00       	mov    $0x1,%edx
80101aef:	b8 01 00 00 00       	mov    $0x1,%eax
80101af4:	e8 73 f7 ff ff       	call   8010126c <iget>
80101af9:	89 c3                	mov    %eax,%ebx
80101afb:	eb 7f                	jmp    80101b7c <namex+0xa8>
  else
    ip = idup(myproc()->cwd);
80101afd:	e8 c3 17 00 00       	call   801032c5 <myproc>
80101b02:	8b 40 68             	mov    0x68(%eax),%eax
80101b05:	89 04 24             	mov    %eax,(%esp)
80101b08:	e8 c6 fa ff ff       	call   801015d3 <idup>
80101b0d:	89 c3                	mov    %eax,%ebx
80101b0f:	eb 6b                	jmp    80101b7c <namex+0xa8>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
80101b11:	89 1c 24             	mov    %ebx,(%esp)
80101b14:	e8 e8 fa ff ff       	call   80101601 <ilock>
    if(ip->type != T_DIR){
80101b19:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101b1e:	74 0f                	je     80101b2f <namex+0x5b>
      iunlockput(ip);
80101b20:	89 1c 24             	mov    %ebx,(%esp)
80101b23:	e8 6b fc ff ff       	call   80101793 <iunlockput>
      return 0;
80101b28:	b8 00 00 00 00       	mov    $0x0,%eax
80101b2d:	eb 74                	jmp    80101ba3 <namex+0xcf>
    }
    if(nameiparent && *path == '\0'){
80101b2f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101b33:	74 11                	je     80101b46 <namex+0x72>
80101b35:	80 3e 00             	cmpb   $0x0,(%esi)
80101b38:	75 0c                	jne    80101b46 <namex+0x72>
      // Stop one level early.
      iunlock(ip);
80101b3a:	89 1c 24             	mov    %ebx,(%esp)
80101b3d:	e8 86 fb ff ff       	call   801016c8 <iunlock>
      return ip;
80101b42:	89 d8                	mov    %ebx,%eax
80101b44:	eb 5d                	jmp    80101ba3 <namex+0xcf>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80101b46:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80101b4d:	00 
80101b4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101b51:	89 44 24 04          	mov    %eax,0x4(%esp)
80101b55:	89 1c 24             	mov    %ebx,(%esp)
80101b58:	e8 db fe ff ff       	call   80101a38 <dirlookup>
80101b5d:	89 c7                	mov    %eax,%edi
80101b5f:	85 c0                	test   %eax,%eax
80101b61:	75 0f                	jne    80101b72 <namex+0x9e>
      iunlockput(ip);
80101b63:	89 1c 24             	mov    %ebx,(%esp)
80101b66:	e8 28 fc ff ff       	call   80101793 <iunlockput>
      return 0;
80101b6b:	b8 00 00 00 00       	mov    $0x0,%eax
80101b70:	eb 31                	jmp    80101ba3 <namex+0xcf>
    }
    iunlockput(ip);
80101b72:	89 1c 24             	mov    %ebx,(%esp)
80101b75:	e8 19 fc ff ff       	call   80101793 <iunlockput>
    ip = next;
80101b7a:	89 fb                	mov    %edi,%ebx
  while((path = skipelem(path, name)) != 0){
80101b7c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101b7f:	89 f0                	mov    %esi,%eax
80101b81:	e8 2a f4 ff ff       	call   80100fb0 <skipelem>
80101b86:	89 c6                	mov    %eax,%esi
80101b88:	85 c0                	test   %eax,%eax
80101b8a:	75 85                	jne    80101b11 <namex+0x3d>
  }
  if(nameiparent){
80101b8c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101b90:	74 0f                	je     80101ba1 <namex+0xcd>
    iput(ip);
80101b92:	89 1c 24             	mov    %ebx,(%esp)
80101b95:	e8 6d fb ff ff       	call   80101707 <iput>
    return 0;
80101b9a:	b8 00 00 00 00       	mov    $0x0,%eax
80101b9f:	eb 02                	jmp    80101ba3 <namex+0xcf>
  }
  return ip;
80101ba1:	89 d8                	mov    %ebx,%eax
}
80101ba3:	83 c4 2c             	add    $0x2c,%esp
80101ba6:	5b                   	pop    %ebx
80101ba7:	5e                   	pop    %esi
80101ba8:	5f                   	pop    %edi
80101ba9:	5d                   	pop    %ebp
80101baa:	c3                   	ret    

80101bab <dirlink>:
{
80101bab:	55                   	push   %ebp
80101bac:	89 e5                	mov    %esp,%ebp
80101bae:	57                   	push   %edi
80101baf:	56                   	push   %esi
80101bb0:	53                   	push   %ebx
80101bb1:	83 ec 2c             	sub    $0x2c,%esp
80101bb4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((ip = dirlookup(dp, name, 0)) != 0){
80101bb7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80101bbe:	00 
80101bbf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bc2:	89 44 24 04          	mov    %eax,0x4(%esp)
80101bc6:	89 1c 24             	mov    %ebx,(%esp)
80101bc9:	e8 6a fe ff ff       	call   80101a38 <dirlookup>
80101bce:	85 c0                	test   %eax,%eax
80101bd0:	74 47                	je     80101c19 <dirlink+0x6e>
    iput(ip);
80101bd2:	89 04 24             	mov    %eax,(%esp)
80101bd5:	e8 2d fb ff ff       	call   80101707 <iput>
    return -1;
80101bda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101bdf:	e9 96 00 00 00       	jmp    80101c7a <dirlink+0xcf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101be4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80101beb:	00 
80101bec:	89 44 24 08          	mov    %eax,0x8(%esp)
80101bf0:	89 7c 24 04          	mov    %edi,0x4(%esp)
80101bf4:	89 1c 24             	mov    %ebx,(%esp)
80101bf7:	e8 e2 fb ff ff       	call   801017de <readi>
80101bfc:	83 f8 10             	cmp    $0x10,%eax
80101bff:	74 0c                	je     80101c0d <dirlink+0x62>
      panic("dirlink read");
80101c01:	c7 04 24 48 67 10 80 	movl   $0x80106748,(%esp)
80101c08:	e8 18 e7 ff ff       	call   80100325 <panic>
    if(de.inum == 0)
80101c0d:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101c12:	74 14                	je     80101c28 <dirlink+0x7d>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101c14:	8d 46 10             	lea    0x10(%esi),%eax
80101c17:	eb 08                	jmp    80101c21 <dirlink+0x76>
80101c19:	b8 00 00 00 00       	mov    $0x0,%eax
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101c1e:	8d 7d d8             	lea    -0x28(%ebp),%edi
  for(off = 0; off < dp->size; off += sizeof(de)){
80101c21:	89 c6                	mov    %eax,%esi
80101c23:	3b 43 58             	cmp    0x58(%ebx),%eax
80101c26:	72 bc                	jb     80101be4 <dirlink+0x39>
  strncpy(de.name, name, DIRSIZ);
80101c28:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80101c2f:	00 
80101c30:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c33:	89 44 24 04          	mov    %eax,0x4(%esp)
80101c37:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101c3a:	8d 45 da             	lea    -0x26(%ebp),%eax
80101c3d:	89 04 24             	mov    %eax,(%esp)
80101c40:	e8 fa 21 00 00       	call   80103e3f <strncpy>
  de.inum = inum;
80101c45:	8b 45 10             	mov    0x10(%ebp),%eax
80101c48:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101c4c:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80101c53:	00 
80101c54:	89 74 24 08          	mov    %esi,0x8(%esp)
80101c58:	89 7c 24 04          	mov    %edi,0x4(%esp)
80101c5c:	89 1c 24             	mov    %ebx,(%esp)
80101c5f:	e8 82 fc ff ff       	call   801018e6 <writei>
80101c64:	83 f8 10             	cmp    $0x10,%eax
80101c67:	74 0c                	je     80101c75 <dirlink+0xca>
    panic("dirlink");
80101c69:	c7 04 24 20 6e 10 80 	movl   $0x80106e20,(%esp)
80101c70:	e8 b0 e6 ff ff       	call   80100325 <panic>
  return 0;
80101c75:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101c7a:	83 c4 2c             	add    $0x2c,%esp
80101c7d:	5b                   	pop    %ebx
80101c7e:	5e                   	pop    %esi
80101c7f:	5f                   	pop    %edi
80101c80:	5d                   	pop    %ebp
80101c81:	c3                   	ret    

80101c82 <namei>:

struct inode*
namei(char *path)
{
80101c82:	55                   	push   %ebp
80101c83:	89 e5                	mov    %esp,%ebp
80101c85:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101c88:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101c8b:	ba 00 00 00 00       	mov    $0x0,%edx
80101c90:	8b 45 08             	mov    0x8(%ebp),%eax
80101c93:	e8 3c fe ff ff       	call   80101ad4 <namex>
}
80101c98:	c9                   	leave  
80101c99:	c3                   	ret    

80101c9a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101c9a:	55                   	push   %ebp
80101c9b:	89 e5                	mov    %esp,%ebp
80101c9d:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80101ca0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101ca3:	ba 01 00 00 00       	mov    $0x1,%edx
80101ca8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cab:	e8 24 fe ff ff       	call   80101ad4 <namex>
}
80101cb0:	c9                   	leave  
80101cb1:	c3                   	ret    

80101cb2 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80101cb2:	55                   	push   %ebp
80101cb3:	89 e5                	mov    %esp,%ebp
80101cb5:	53                   	push   %ebx
80101cb6:	89 c1                	mov    %eax,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101cb8:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101cbd:	ec                   	in     (%dx),%al
80101cbe:	89 c3                	mov    %eax,%ebx
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101cc0:	83 e0 c0             	and    $0xffffffc0,%eax
80101cc3:	3c 40                	cmp    $0x40,%al
80101cc5:	75 f6                	jne    80101cbd <idewait+0xb>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101cc7:	85 c9                	test   %ecx,%ecx
80101cc9:	74 0c                	je     80101cd7 <idewait+0x25>
80101ccb:	f6 c3 21             	test   $0x21,%bl
80101cce:	75 0e                	jne    80101cde <idewait+0x2c>
    return -1;
  return 0;
80101cd0:	b8 00 00 00 00       	mov    $0x0,%eax
80101cd5:	eb 0c                	jmp    80101ce3 <idewait+0x31>
80101cd7:	b8 00 00 00 00       	mov    $0x0,%eax
80101cdc:	eb 05                	jmp    80101ce3 <idewait+0x31>
    return -1;
80101cde:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101ce3:	5b                   	pop    %ebx
80101ce4:	5d                   	pop    %ebp
80101ce5:	c3                   	ret    

80101ce6 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101ce6:	55                   	push   %ebp
80101ce7:	89 e5                	mov    %esp,%ebp
80101ce9:	56                   	push   %esi
80101cea:	53                   	push   %ebx
80101ceb:	83 ec 10             	sub    $0x10,%esp
80101cee:	89 c6                	mov    %eax,%esi
  if(b == 0)
80101cf0:	85 c0                	test   %eax,%eax
80101cf2:	75 0c                	jne    80101d00 <idestart+0x1a>
    panic("idestart");
80101cf4:	c7 04 24 ab 67 10 80 	movl   $0x801067ab,(%esp)
80101cfb:	e8 25 e6 ff ff       	call   80100325 <panic>
  if(b->blockno >= FSSIZE)
80101d00:	8b 58 08             	mov    0x8(%eax),%ebx
80101d03:	81 fb cf 07 00 00    	cmp    $0x7cf,%ebx
80101d09:	76 0c                	jbe    80101d17 <idestart+0x31>
    panic("incorrect blockno");
80101d0b:	c7 04 24 b4 67 10 80 	movl   $0x801067b4,(%esp)
80101d12:	e8 0e e6 ff ff       	call   80100325 <panic>
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;

  if (sector_per_block > 7) panic("idestart");

  idewait(0);
80101d17:	b8 00 00 00 00       	mov    $0x0,%eax
80101d1c:	e8 91 ff ff ff       	call   80101cb2 <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d21:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101d26:	b8 00 00 00 00       	mov    $0x0,%eax
80101d2b:	ee                   	out    %al,(%dx)
80101d2c:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101d31:	b8 01 00 00 00       	mov    $0x1,%eax
80101d36:	ee                   	out    %al,(%dx)
80101d37:	b2 f3                	mov    $0xf3,%dl
80101d39:	89 d8                	mov    %ebx,%eax
80101d3b:	ee                   	out    %al,(%dx)
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101d3c:	0f b6 c7             	movzbl %bh,%eax
80101d3f:	b2 f4                	mov    $0xf4,%dl
80101d41:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
80101d42:	89 d8                	mov    %ebx,%eax
80101d44:	c1 f8 10             	sar    $0x10,%eax
80101d47:	b2 f5                	mov    $0xf5,%dl
80101d49:	ee                   	out    %al,(%dx)
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101d4a:	c1 fb 18             	sar    $0x18,%ebx
80101d4d:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80101d51:	83 e0 01             	and    $0x1,%eax
80101d54:	c1 e0 04             	shl    $0x4,%eax
80101d57:	83 e3 0f             	and    $0xf,%ebx
80101d5a:	09 d8                	or     %ebx,%eax
80101d5c:	83 c8 e0             	or     $0xffffffe0,%eax
80101d5f:	b2 f6                	mov    $0xf6,%dl
80101d61:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101d62:	f6 06 04             	testb  $0x4,(%esi)
80101d65:	74 1a                	je     80101d81 <idestart+0x9b>
80101d67:	b2 f7                	mov    $0xf7,%dl
80101d69:	b8 30 00 00 00       	mov    $0x30,%eax
80101d6e:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
80101d6f:	83 c6 5c             	add    $0x5c,%esi
  asm volatile("cld; rep outsl" :
80101d72:	b9 80 00 00 00       	mov    $0x80,%ecx
80101d77:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101d7c:	fc                   	cld    
80101d7d:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80101d7f:	eb 0b                	jmp    80101d8c <idestart+0xa6>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d81:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d86:	b8 20 00 00 00       	mov    $0x20,%eax
80101d8b:	ee                   	out    %al,(%dx)
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101d8c:	83 c4 10             	add    $0x10,%esp
80101d8f:	5b                   	pop    %ebx
80101d90:	5e                   	pop    %esi
80101d91:	5d                   	pop    %ebp
80101d92:	c3                   	ret    

80101d93 <ideinit>:
{
80101d93:	55                   	push   %ebp
80101d94:	89 e5                	mov    %esp,%ebp
80101d96:	83 ec 18             	sub    $0x18,%esp
  initlock(&idelock, "ide");
80101d99:	c7 44 24 04 c6 67 10 	movl   $0x801067c6,0x4(%esp)
80101da0:	80 
80101da1:	c7 04 24 80 a5 10 80 	movl   $0x8010a580,(%esp)
80101da8:	e8 77 1d 00 00       	call   80103b24 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101dad:	a1 20 2d 11 80       	mov    0x80112d20,%eax
80101db2:	83 e8 01             	sub    $0x1,%eax
80101db5:	89 44 24 04          	mov    %eax,0x4(%esp)
80101db9:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80101dc0:	e8 31 02 00 00       	call   80101ff6 <ioapicenable>
  idewait(0);
80101dc5:	b8 00 00 00 00       	mov    $0x0,%eax
80101dca:	e8 e3 fe ff ff       	call   80101cb2 <idewait>
80101dcf:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101dd4:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
80101dd9:	ee                   	out    %al,(%dx)
  for(i=0; i<1000; i++){
80101dda:	b9 00 00 00 00       	mov    $0x0,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101ddf:	b2 f7                	mov    $0xf7,%dl
80101de1:	eb 14                	jmp    80101df7 <ideinit+0x64>
80101de3:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101de4:	84 c0                	test   %al,%al
80101de6:	74 0c                	je     80101df4 <ideinit+0x61>
      havedisk1 = 1;
80101de8:	c7 05 60 a5 10 80 01 	movl   $0x1,0x8010a560
80101def:	00 00 00 
      break;
80101df2:	eb 0b                	jmp    80101dff <ideinit+0x6c>
  for(i=0; i<1000; i++){
80101df4:	83 c1 01             	add    $0x1,%ecx
80101df7:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101dfd:	7e e4                	jle    80101de3 <ideinit+0x50>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101dff:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101e04:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80101e09:	ee                   	out    %al,(%dx)
}
80101e0a:	c9                   	leave  
80101e0b:	c3                   	ret    

80101e0c <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80101e0c:	55                   	push   %ebp
80101e0d:	89 e5                	mov    %esp,%ebp
80101e0f:	57                   	push   %edi
80101e10:	53                   	push   %ebx
80101e11:	83 ec 10             	sub    $0x10,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101e14:	c7 04 24 80 a5 10 80 	movl   $0x8010a580,(%esp)
80101e1b:	e8 3c 1e 00 00       	call   80103c5c <acquire>

  if((b = idequeue) == 0){
80101e20:	8b 1d 64 a5 10 80    	mov    0x8010a564,%ebx
80101e26:	85 db                	test   %ebx,%ebx
80101e28:	75 0e                	jne    80101e38 <ideintr+0x2c>
    release(&idelock);
80101e2a:	c7 04 24 80 a5 10 80 	movl   $0x8010a580,(%esp)
80101e31:	e8 87 1e 00 00       	call   80103cbd <release>
    return;
80101e36:	eb 57                	jmp    80101e8f <ideintr+0x83>
  }
  idequeue = b->qnext;
80101e38:	8b 43 58             	mov    0x58(%ebx),%eax
80101e3b:	a3 64 a5 10 80       	mov    %eax,0x8010a564

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101e40:	f6 03 04             	testb  $0x4,(%ebx)
80101e43:	75 1e                	jne    80101e63 <ideintr+0x57>
80101e45:	b8 01 00 00 00       	mov    $0x1,%eax
80101e4a:	e8 63 fe ff ff       	call   80101cb2 <idewait>
80101e4f:	85 c0                	test   %eax,%eax
80101e51:	78 10                	js     80101e63 <ideintr+0x57>
    insl(0x1f0, b->data, BSIZE/4);
80101e53:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80101e56:	b9 80 00 00 00       	mov    $0x80,%ecx
80101e5b:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101e60:	fc                   	cld    
80101e61:	f3 6d                	rep insl (%dx),%es:(%edi)

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80101e63:	8b 03                	mov    (%ebx),%eax
80101e65:	83 c8 02             	or     $0x2,%eax
  b->flags &= ~B_DIRTY;
80101e68:	83 e0 fb             	and    $0xfffffffb,%eax
80101e6b:	89 03                	mov    %eax,(%ebx)
  wakeup(b);
80101e6d:	89 1c 24             	mov    %ebx,(%esp)
80101e70:	e8 4b 1a 00 00       	call   801038c0 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101e75:	a1 64 a5 10 80       	mov    0x8010a564,%eax
80101e7a:	85 c0                	test   %eax,%eax
80101e7c:	74 05                	je     80101e83 <ideintr+0x77>
    idestart(idequeue);
80101e7e:	e8 63 fe ff ff       	call   80101ce6 <idestart>

  release(&idelock);
80101e83:	c7 04 24 80 a5 10 80 	movl   $0x8010a580,(%esp)
80101e8a:	e8 2e 1e 00 00       	call   80103cbd <release>
}
80101e8f:	83 c4 10             	add    $0x10,%esp
80101e92:	5b                   	pop    %ebx
80101e93:	5f                   	pop    %edi
80101e94:	5d                   	pop    %ebp
80101e95:	c3                   	ret    

80101e96 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101e96:	55                   	push   %ebp
80101e97:	89 e5                	mov    %esp,%ebp
80101e99:	53                   	push   %ebx
80101e9a:	83 ec 14             	sub    $0x14,%esp
80101e9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101ea0:	8d 43 0c             	lea    0xc(%ebx),%eax
80101ea3:	89 04 24             	mov    %eax,(%esp)
80101ea6:	e8 2d 1c 00 00       	call   80103ad8 <holdingsleep>
80101eab:	85 c0                	test   %eax,%eax
80101ead:	75 0c                	jne    80101ebb <iderw+0x25>
    panic("iderw: buf not locked");
80101eaf:	c7 04 24 ca 67 10 80 	movl   $0x801067ca,(%esp)
80101eb6:	e8 6a e4 ff ff       	call   80100325 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101ebb:	8b 03                	mov    (%ebx),%eax
80101ebd:	83 e0 06             	and    $0x6,%eax
80101ec0:	83 f8 02             	cmp    $0x2,%eax
80101ec3:	75 0c                	jne    80101ed1 <iderw+0x3b>
    panic("iderw: nothing to do");
80101ec5:	c7 04 24 e0 67 10 80 	movl   $0x801067e0,(%esp)
80101ecc:	e8 54 e4 ff ff       	call   80100325 <panic>
  if(b->dev != 0 && !havedisk1)
80101ed1:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80101ed5:	74 15                	je     80101eec <iderw+0x56>
80101ed7:	83 3d 60 a5 10 80 00 	cmpl   $0x0,0x8010a560
80101ede:	75 0c                	jne    80101eec <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80101ee0:	c7 04 24 f5 67 10 80 	movl   $0x801067f5,(%esp)
80101ee7:	e8 39 e4 ff ff       	call   80100325 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80101eec:	c7 04 24 80 a5 10 80 	movl   $0x8010a580,(%esp)
80101ef3:	e8 64 1d 00 00       	call   80103c5c <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101ef8:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101eff:	b8 64 a5 10 80       	mov    $0x8010a564,%eax
80101f04:	eb 03                	jmp    80101f09 <iderw+0x73>
80101f06:	8d 42 58             	lea    0x58(%edx),%eax
80101f09:	8b 10                	mov    (%eax),%edx
80101f0b:	85 d2                	test   %edx,%edx
80101f0d:	75 f7                	jne    80101f06 <iderw+0x70>
    ;
  *pp = b;
80101f0f:	89 18                	mov    %ebx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80101f11:	39 1d 64 a5 10 80    	cmp    %ebx,0x8010a564
80101f17:	75 19                	jne    80101f32 <iderw+0x9c>
    idestart(b);
80101f19:	89 d8                	mov    %ebx,%eax
80101f1b:	e8 c6 fd ff ff       	call   80101ce6 <idestart>
80101f20:	eb 10                	jmp    80101f32 <iderw+0x9c>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101f22:	c7 44 24 04 80 a5 10 	movl   $0x8010a580,0x4(%esp)
80101f29:	80 
80101f2a:	89 1c 24             	mov    %ebx,(%esp)
80101f2d:	e8 39 18 00 00       	call   8010376b <sleep>
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101f32:	8b 03                	mov    (%ebx),%eax
80101f34:	83 e0 06             	and    $0x6,%eax
80101f37:	83 f8 02             	cmp    $0x2,%eax
80101f3a:	75 e6                	jne    80101f22 <iderw+0x8c>
  }


  release(&idelock);
80101f3c:	c7 04 24 80 a5 10 80 	movl   $0x8010a580,(%esp)
80101f43:	e8 75 1d 00 00       	call   80103cbd <release>
}
80101f48:	83 c4 14             	add    $0x14,%esp
80101f4b:	5b                   	pop    %ebx
80101f4c:	5d                   	pop    %ebp
80101f4d:	c3                   	ret    

80101f4e <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80101f4e:	55                   	push   %ebp
80101f4f:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101f51:	8b 15 54 26 11 80    	mov    0x80112654,%edx
80101f57:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101f59:	a1 54 26 11 80       	mov    0x80112654,%eax
80101f5e:	8b 40 10             	mov    0x10(%eax),%eax
}
80101f61:	5d                   	pop    %ebp
80101f62:	c3                   	ret    

80101f63 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80101f63:	55                   	push   %ebp
80101f64:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101f66:	8b 0d 54 26 11 80    	mov    0x80112654,%ecx
80101f6c:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101f6e:	a1 54 26 11 80       	mov    0x80112654,%eax
80101f73:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f76:	5d                   	pop    %ebp
80101f77:	c3                   	ret    

80101f78 <ioapicinit>:

void
ioapicinit(void)
{
80101f78:	55                   	push   %ebp
80101f79:	89 e5                	mov    %esp,%ebp
80101f7b:	57                   	push   %edi
80101f7c:	56                   	push   %esi
80101f7d:	53                   	push   %ebx
80101f7e:	83 ec 1c             	sub    $0x1c,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80101f81:	c7 05 54 26 11 80 00 	movl   $0xfec00000,0x80112654
80101f88:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101f8b:	b8 01 00 00 00       	mov    $0x1,%eax
80101f90:	e8 b9 ff ff ff       	call   80101f4e <ioapicread>
80101f95:	c1 e8 10             	shr    $0x10,%eax
80101f98:	0f b6 f8             	movzbl %al,%edi
  id = ioapicread(REG_ID) >> 24;
80101f9b:	b8 00 00 00 00       	mov    $0x0,%eax
80101fa0:	e8 a9 ff ff ff       	call   80101f4e <ioapicread>
80101fa5:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80101fa8:	0f b6 15 80 27 11 80 	movzbl 0x80112780,%edx
80101faf:	39 c2                	cmp    %eax,%edx
80101fb1:	74 0c                	je     80101fbf <ioapicinit+0x47>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101fb3:	c7 04 24 14 68 10 80 	movl   $0x80106814,(%esp)
80101fba:	e8 08 e6 ff ff       	call   801005c7 <cprintf>
{
80101fbf:	bb 00 00 00 00       	mov    $0x0,%ebx
80101fc4:	eb 24                	jmp    80101fea <ioapicinit+0x72>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80101fc6:	8d 53 20             	lea    0x20(%ebx),%edx
80101fc9:	81 ca 00 00 01 00    	or     $0x10000,%edx
80101fcf:	8d 74 1b 10          	lea    0x10(%ebx,%ebx,1),%esi
80101fd3:	89 f0                	mov    %esi,%eax
80101fd5:	e8 89 ff ff ff       	call   80101f63 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80101fda:	8d 46 01             	lea    0x1(%esi),%eax
80101fdd:	ba 00 00 00 00       	mov    $0x0,%edx
80101fe2:	e8 7c ff ff ff       	call   80101f63 <ioapicwrite>
  for(i = 0; i <= maxintr; i++){
80101fe7:	83 c3 01             	add    $0x1,%ebx
80101fea:	39 fb                	cmp    %edi,%ebx
80101fec:	7e d8                	jle    80101fc6 <ioapicinit+0x4e>
  }
}
80101fee:	83 c4 1c             	add    $0x1c,%esp
80101ff1:	5b                   	pop    %ebx
80101ff2:	5e                   	pop    %esi
80101ff3:	5f                   	pop    %edi
80101ff4:	5d                   	pop    %ebp
80101ff5:	c3                   	ret    

80101ff6 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80101ff6:	55                   	push   %ebp
80101ff7:	89 e5                	mov    %esp,%ebp
80101ff9:	53                   	push   %ebx
80101ffa:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80101ffd:	8d 50 20             	lea    0x20(%eax),%edx
80102000:	8d 5c 00 10          	lea    0x10(%eax,%eax,1),%ebx
80102004:	89 d8                	mov    %ebx,%eax
80102006:	e8 58 ff ff ff       	call   80101f63 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010200b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010200e:	c1 e2 18             	shl    $0x18,%edx
80102011:	8d 43 01             	lea    0x1(%ebx),%eax
80102014:	e8 4a ff ff ff       	call   80101f63 <ioapicwrite>
}
80102019:	5b                   	pop    %ebx
8010201a:	5d                   	pop    %ebp
8010201b:	c3                   	ret    

8010201c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
8010201c:	55                   	push   %ebp
8010201d:	89 e5                	mov    %esp,%ebp
8010201f:	53                   	push   %ebx
80102020:	83 ec 14             	sub    $0x14,%esp
80102023:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102026:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
8010202c:	75 29                	jne    80102057 <kfree+0x3b>
8010202e:	81 fb c8 54 11 80    	cmp    $0x801154c8,%ebx
80102034:	72 21                	jb     80102057 <kfree+0x3b>

// Convert kernel virtual address to physical address
static inline uint V2P(void *a) {
    // define panic() here because memlayout.h is included before defs.h
    extern void panic(char*) __attribute__((noreturn));
    if (a < (void*) KERNBASE)
80102036:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
8010203c:	77 0c                	ja     8010204a <kfree+0x2e>
        panic("V2P on address < KERNBASE "
8010203e:	c7 04 24 48 68 10 80 	movl   $0x80106848,(%esp)
80102045:	e8 db e2 ff ff       	call   80100325 <panic>
              "(not a kernel virtual address; consider walking page "
              "table to determine physical address of a user virtual address)");
    return (uint)a - KERNBASE;
8010204a:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80102050:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102055:	76 0c                	jbe    80102063 <kfree+0x47>
    panic("kfree");
80102057:	c7 04 24 d6 68 10 80 	movl   $0x801068d6,(%esp)
8010205e:	e8 c2 e2 ff ff       	call   80100325 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102063:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010206a:	00 
8010206b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102072:	00 
80102073:	89 1c 24             	mov    %ebx,(%esp)
80102076:	e8 95 1c 00 00       	call   80103d10 <memset>

  if(kmem.use_lock)
8010207b:	83 3d 94 26 11 80 00 	cmpl   $0x0,0x80112694
80102082:	74 0c                	je     80102090 <kfree+0x74>
    acquire(&kmem.lock);
80102084:	c7 04 24 60 26 11 80 	movl   $0x80112660,(%esp)
8010208b:	e8 cc 1b 00 00       	call   80103c5c <acquire>
  r = (struct run*)v;
  r->next = kmem.freelist;
80102090:	a1 98 26 11 80       	mov    0x80112698,%eax
80102095:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80102097:	89 1d 98 26 11 80    	mov    %ebx,0x80112698
  if(kmem.use_lock)
8010209d:	83 3d 94 26 11 80 00 	cmpl   $0x0,0x80112694
801020a4:	74 0c                	je     801020b2 <kfree+0x96>
    release(&kmem.lock);
801020a6:	c7 04 24 60 26 11 80 	movl   $0x80112660,(%esp)
801020ad:	e8 0b 1c 00 00       	call   80103cbd <release>
}
801020b2:	83 c4 14             	add    $0x14,%esp
801020b5:	5b                   	pop    %ebx
801020b6:	5d                   	pop    %ebp
801020b7:	c3                   	ret    

801020b8 <freerange>:
{
801020b8:	55                   	push   %ebp
801020b9:	89 e5                	mov    %esp,%ebp
801020bb:	56                   	push   %esi
801020bc:	53                   	push   %ebx
801020bd:	83 ec 10             	sub    $0x10,%esp
801020c0:	8b 45 08             	mov    0x8(%ebp),%eax
801020c3:	8b 75 0c             	mov    0xc(%ebp),%esi
  if (vend < vstart) panic("freerange");
801020c6:	39 c6                	cmp    %eax,%esi
801020c8:	73 0c                	jae    801020d6 <freerange+0x1e>
801020ca:	c7 04 24 dc 68 10 80 	movl   $0x801068dc,(%esp)
801020d1:	e8 4f e2 ff ff       	call   80100325 <panic>
  p = (char*)PGROUNDUP((uint)vstart);
801020d6:	05 ff 0f 00 00       	add    $0xfff,%eax
801020db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801020e0:	eb 0a                	jmp    801020ec <freerange+0x34>
    kfree(p);
801020e2:	89 04 24             	mov    %eax,(%esp)
801020e5:	e8 32 ff ff ff       	call   8010201c <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801020ea:	89 d8                	mov    %ebx,%eax
801020ec:	8d 98 00 10 00 00    	lea    0x1000(%eax),%ebx
801020f2:	39 f3                	cmp    %esi,%ebx
801020f4:	76 ec                	jbe    801020e2 <freerange+0x2a>
}
801020f6:	83 c4 10             	add    $0x10,%esp
801020f9:	5b                   	pop    %ebx
801020fa:	5e                   	pop    %esi
801020fb:	5d                   	pop    %ebp
801020fc:	c3                   	ret    

801020fd <kinit1>:
{
801020fd:	55                   	push   %ebp
801020fe:	89 e5                	mov    %esp,%ebp
80102100:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102103:	c7 44 24 04 e6 68 10 	movl   $0x801068e6,0x4(%esp)
8010210a:	80 
8010210b:	c7 04 24 60 26 11 80 	movl   $0x80112660,(%esp)
80102112:	e8 0d 1a 00 00       	call   80103b24 <initlock>
  kmem.use_lock = 0;
80102117:	c7 05 94 26 11 80 00 	movl   $0x0,0x80112694
8010211e:	00 00 00 
  freerange(vstart, vend);
80102121:	8b 45 0c             	mov    0xc(%ebp),%eax
80102124:	89 44 24 04          	mov    %eax,0x4(%esp)
80102128:	8b 45 08             	mov    0x8(%ebp),%eax
8010212b:	89 04 24             	mov    %eax,(%esp)
8010212e:	e8 85 ff ff ff       	call   801020b8 <freerange>
}
80102133:	c9                   	leave  
80102134:	c3                   	ret    

80102135 <kinit2>:
{
80102135:	55                   	push   %ebp
80102136:	89 e5                	mov    %esp,%ebp
80102138:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
8010213b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010213e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102142:	8b 45 08             	mov    0x8(%ebp),%eax
80102145:	89 04 24             	mov    %eax,(%esp)
80102148:	e8 6b ff ff ff       	call   801020b8 <freerange>
  kmem.use_lock = 1;
8010214d:	c7 05 94 26 11 80 01 	movl   $0x1,0x80112694
80102154:	00 00 00 
}
80102157:	c9                   	leave  
80102158:	c3                   	ret    

80102159 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102159:	55                   	push   %ebp
8010215a:	89 e5                	mov    %esp,%ebp
8010215c:	53                   	push   %ebx
8010215d:	83 ec 14             	sub    $0x14,%esp
  struct run *r;

  if(kmem.use_lock)
80102160:	83 3d 94 26 11 80 00 	cmpl   $0x0,0x80112694
80102167:	74 0c                	je     80102175 <kalloc+0x1c>
    acquire(&kmem.lock);
80102169:	c7 04 24 60 26 11 80 	movl   $0x80112660,(%esp)
80102170:	e8 e7 1a 00 00       	call   80103c5c <acquire>
  r = kmem.freelist;
80102175:	8b 1d 98 26 11 80    	mov    0x80112698,%ebx
  if(r)
8010217b:	85 db                	test   %ebx,%ebx
8010217d:	74 07                	je     80102186 <kalloc+0x2d>
    kmem.freelist = r->next;
8010217f:	8b 03                	mov    (%ebx),%eax
80102181:	a3 98 26 11 80       	mov    %eax,0x80112698
  if(kmem.use_lock)
80102186:	83 3d 94 26 11 80 00 	cmpl   $0x0,0x80112694
8010218d:	74 0c                	je     8010219b <kalloc+0x42>
    release(&kmem.lock);
8010218f:	c7 04 24 60 26 11 80 	movl   $0x80112660,(%esp)
80102196:	e8 22 1b 00 00       	call   80103cbd <release>
  return (char*)r;
}
8010219b:	89 d8                	mov    %ebx,%eax
8010219d:	83 c4 14             	add    $0x14,%esp
801021a0:	5b                   	pop    %ebx
801021a1:	5d                   	pop    %ebp
801021a2:	c3                   	ret    

801021a3 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801021a3:	55                   	push   %ebp
801021a4:	89 e5                	mov    %esp,%ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801021a6:	ba 64 00 00 00       	mov    $0x64,%edx
801021ab:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
801021ac:	a8 01                	test   $0x1,%al
801021ae:	0f 84 b6 00 00 00    	je     8010226a <kbdgetc+0xc7>
801021b4:	b2 60                	mov    $0x60,%dl
801021b6:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
801021b7:	0f b6 c8             	movzbl %al,%ecx

  if(data == 0xE0){
801021ba:	81 f9 e0 00 00 00    	cmp    $0xe0,%ecx
801021c0:	75 11                	jne    801021d3 <kbdgetc+0x30>
    shift |= E0ESC;
801021c2:	83 0d b4 a5 10 80 40 	orl    $0x40,0x8010a5b4
    return 0;
801021c9:	b8 00 00 00 00       	mov    $0x0,%eax
801021ce:	e9 9c 00 00 00       	jmp    8010226f <kbdgetc+0xcc>
  } else if(data & 0x80){
801021d3:	84 c0                	test   %al,%al
801021d5:	79 2e                	jns    80102205 <kbdgetc+0x62>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801021d7:	8b 15 b4 a5 10 80    	mov    0x8010a5b4,%edx
801021dd:	f6 c2 40             	test   $0x40,%dl
801021e0:	75 05                	jne    801021e7 <kbdgetc+0x44>
801021e2:	89 c1                	mov    %eax,%ecx
801021e4:	83 e1 7f             	and    $0x7f,%ecx
    shift &= ~(shiftcode[data] | E0ESC);
801021e7:	0f b6 81 20 6a 10 80 	movzbl -0x7fef95e0(%ecx),%eax
801021ee:	83 c8 40             	or     $0x40,%eax
801021f1:	0f b6 c0             	movzbl %al,%eax
801021f4:	f7 d0                	not    %eax
801021f6:	21 c2                	and    %eax,%edx
801021f8:	89 15 b4 a5 10 80    	mov    %edx,0x8010a5b4
    return 0;
801021fe:	b8 00 00 00 00       	mov    $0x0,%eax
80102203:	eb 6a                	jmp    8010226f <kbdgetc+0xcc>
  } else if(shift & E0ESC){
80102205:	8b 15 b4 a5 10 80    	mov    0x8010a5b4,%edx
8010220b:	f6 c2 40             	test   $0x40,%dl
8010220e:	74 0f                	je     8010221f <kbdgetc+0x7c>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102210:	83 c8 80             	or     $0xffffff80,%eax
80102213:	0f b6 c8             	movzbl %al,%ecx
    shift &= ~E0ESC;
80102216:	83 e2 bf             	and    $0xffffffbf,%edx
80102219:	89 15 b4 a5 10 80    	mov    %edx,0x8010a5b4
  }

  shift |= shiftcode[data];
8010221f:	0f b6 91 20 6a 10 80 	movzbl -0x7fef95e0(%ecx),%edx
80102226:	0b 15 b4 a5 10 80    	or     0x8010a5b4,%edx
  shift ^= togglecode[data];
8010222c:	0f b6 81 20 69 10 80 	movzbl -0x7fef96e0(%ecx),%eax
80102233:	31 c2                	xor    %eax,%edx
80102235:	89 15 b4 a5 10 80    	mov    %edx,0x8010a5b4
  c = charcode[shift & (CTL | SHIFT)][data];
8010223b:	89 d0                	mov    %edx,%eax
8010223d:	83 e0 03             	and    $0x3,%eax
80102240:	8b 04 85 00 69 10 80 	mov    -0x7fef9700(,%eax,4),%eax
80102247:	0f b6 04 08          	movzbl (%eax,%ecx,1),%eax
  if(shift & CAPSLOCK){
8010224b:	f6 c2 08             	test   $0x8,%dl
8010224e:	74 1f                	je     8010226f <kbdgetc+0xcc>
    if('a' <= c && c <= 'z')
80102250:	8d 50 9f             	lea    -0x61(%eax),%edx
80102253:	83 fa 19             	cmp    $0x19,%edx
80102256:	77 05                	ja     8010225d <kbdgetc+0xba>
      c += 'A' - 'a';
80102258:	83 e8 20             	sub    $0x20,%eax
8010225b:	eb 12                	jmp    8010226f <kbdgetc+0xcc>
    else if('A' <= c && c <= 'Z')
8010225d:	8d 50 bf             	lea    -0x41(%eax),%edx
80102260:	83 fa 19             	cmp    $0x19,%edx
80102263:	77 0a                	ja     8010226f <kbdgetc+0xcc>
      c += 'a' - 'A';
80102265:	83 c0 20             	add    $0x20,%eax
  }
  return c;
80102268:	eb 05                	jmp    8010226f <kbdgetc+0xcc>
    return -1;
8010226a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010226f:	5d                   	pop    %ebp
80102270:	c3                   	ret    

80102271 <kbdintr>:

void
kbdintr(void)
{
80102271:	55                   	push   %ebp
80102272:	89 e5                	mov    %esp,%ebp
80102274:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102277:	c7 04 24 a3 21 10 80 	movl   $0x801021a3,(%esp)
8010227e:	e8 76 e4 ff ff       	call   801006f9 <consoleintr>
}
80102283:	c9                   	leave  
80102284:	c3                   	ret    

80102285 <shutdown>:
#include "types.h"
#include "x86.h"

void
shutdown(void)
{
80102285:	55                   	push   %ebp
80102286:	89 e5                	mov    %esp,%ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102288:	ba 01 05 00 00       	mov    $0x501,%edx
8010228d:	b8 00 00 00 00       	mov    $0x0,%eax
80102292:	ee                   	out    %al,(%dx)
  /*
     This only works in QEMU and assumes QEMU was run 
     with -device isa-debug-exit
   */
  outb(0x501, 0x0);
}
80102293:	5d                   	pop    %ebp
80102294:	c3                   	ret    

80102295 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102295:	55                   	push   %ebp
80102296:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102298:	8b 0d 9c 26 11 80    	mov    0x8011269c,%ecx
8010229e:	8d 04 81             	lea    (%ecx,%eax,4),%eax
801022a1:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
801022a3:	a1 9c 26 11 80       	mov    0x8011269c,%eax
801022a8:	8b 40 20             	mov    0x20(%eax),%eax
}
801022ab:	5d                   	pop    %ebp
801022ac:	c3                   	ret    

801022ad <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
801022ad:	55                   	push   %ebp
801022ae:	89 e5                	mov    %esp,%ebp
801022b0:	ba 70 00 00 00       	mov    $0x70,%edx
801022b5:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801022b6:	b2 71                	mov    $0x71,%dl
801022b8:	ec                   	in     (%dx),%al
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
801022b9:	0f b6 c0             	movzbl %al,%eax
}
801022bc:	5d                   	pop    %ebp
801022bd:	c3                   	ret    

801022be <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
801022be:	55                   	push   %ebp
801022bf:	89 e5                	mov    %esp,%ebp
801022c1:	53                   	push   %ebx
801022c2:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
801022c4:	b8 00 00 00 00       	mov    $0x0,%eax
801022c9:	e8 df ff ff ff       	call   801022ad <cmos_read>
801022ce:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
801022d0:	b8 02 00 00 00       	mov    $0x2,%eax
801022d5:	e8 d3 ff ff ff       	call   801022ad <cmos_read>
801022da:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
801022dd:	b8 04 00 00 00       	mov    $0x4,%eax
801022e2:	e8 c6 ff ff ff       	call   801022ad <cmos_read>
801022e7:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
801022ea:	b8 07 00 00 00       	mov    $0x7,%eax
801022ef:	e8 b9 ff ff ff       	call   801022ad <cmos_read>
801022f4:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
801022f7:	b8 08 00 00 00       	mov    $0x8,%eax
801022fc:	e8 ac ff ff ff       	call   801022ad <cmos_read>
80102301:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
80102304:	b8 09 00 00 00       	mov    $0x9,%eax
80102309:	e8 9f ff ff ff       	call   801022ad <cmos_read>
8010230e:	89 43 14             	mov    %eax,0x14(%ebx)
}
80102311:	5b                   	pop    %ebx
80102312:	5d                   	pop    %ebp
80102313:	c3                   	ret    

80102314 <lapicinit>:
  if(!lapic)
80102314:	83 3d 9c 26 11 80 00 	cmpl   $0x0,0x8011269c
8010231b:	0f 84 f5 00 00 00    	je     80102416 <lapicinit+0x102>
{
80102321:	55                   	push   %ebp
80102322:	89 e5                	mov    %esp,%ebp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102324:	ba 3f 01 00 00       	mov    $0x13f,%edx
80102329:	b8 3c 00 00 00       	mov    $0x3c,%eax
8010232e:	e8 62 ff ff ff       	call   80102295 <lapicw>
  lapicw(TDCR, X1);
80102333:	ba 0b 00 00 00       	mov    $0xb,%edx
80102338:	b8 f8 00 00 00       	mov    $0xf8,%eax
8010233d:	e8 53 ff ff ff       	call   80102295 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102342:	ba 20 00 02 00       	mov    $0x20020,%edx
80102347:	b8 c8 00 00 00       	mov    $0xc8,%eax
8010234c:	e8 44 ff ff ff       	call   80102295 <lapicw>
  lapicw(TICR, 10000000);
80102351:	ba 80 96 98 00       	mov    $0x989680,%edx
80102356:	b8 e0 00 00 00       	mov    $0xe0,%eax
8010235b:	e8 35 ff ff ff       	call   80102295 <lapicw>
  lapicw(LINT0, MASKED);
80102360:	ba 00 00 01 00       	mov    $0x10000,%edx
80102365:	b8 d4 00 00 00       	mov    $0xd4,%eax
8010236a:	e8 26 ff ff ff       	call   80102295 <lapicw>
  lapicw(LINT1, MASKED);
8010236f:	ba 00 00 01 00       	mov    $0x10000,%edx
80102374:	b8 d8 00 00 00       	mov    $0xd8,%eax
80102379:	e8 17 ff ff ff       	call   80102295 <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010237e:	a1 9c 26 11 80       	mov    0x8011269c,%eax
80102383:	8b 40 30             	mov    0x30(%eax),%eax
80102386:	c1 e8 10             	shr    $0x10,%eax
80102389:	3c 03                	cmp    $0x3,%al
8010238b:	76 0f                	jbe    8010239c <lapicinit+0x88>
    lapicw(PCINT, MASKED);
8010238d:	ba 00 00 01 00       	mov    $0x10000,%edx
80102392:	b8 d0 00 00 00       	mov    $0xd0,%eax
80102397:	e8 f9 fe ff ff       	call   80102295 <lapicw>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010239c:	ba 33 00 00 00       	mov    $0x33,%edx
801023a1:	b8 dc 00 00 00       	mov    $0xdc,%eax
801023a6:	e8 ea fe ff ff       	call   80102295 <lapicw>
  lapicw(ESR, 0);
801023ab:	ba 00 00 00 00       	mov    $0x0,%edx
801023b0:	b8 a0 00 00 00       	mov    $0xa0,%eax
801023b5:	e8 db fe ff ff       	call   80102295 <lapicw>
  lapicw(ESR, 0);
801023ba:	ba 00 00 00 00       	mov    $0x0,%edx
801023bf:	b8 a0 00 00 00       	mov    $0xa0,%eax
801023c4:	e8 cc fe ff ff       	call   80102295 <lapicw>
  lapicw(EOI, 0);
801023c9:	ba 00 00 00 00       	mov    $0x0,%edx
801023ce:	b8 2c 00 00 00       	mov    $0x2c,%eax
801023d3:	e8 bd fe ff ff       	call   80102295 <lapicw>
  lapicw(ICRHI, 0);
801023d8:	ba 00 00 00 00       	mov    $0x0,%edx
801023dd:	b8 c4 00 00 00       	mov    $0xc4,%eax
801023e2:	e8 ae fe ff ff       	call   80102295 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801023e7:	ba 00 85 08 00       	mov    $0x88500,%edx
801023ec:	b8 c0 00 00 00       	mov    $0xc0,%eax
801023f1:	e8 9f fe ff ff       	call   80102295 <lapicw>
  while(lapic[ICRLO] & DELIVS)
801023f6:	a1 9c 26 11 80       	mov    0x8011269c,%eax
801023fb:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
80102401:	f6 c4 10             	test   $0x10,%ah
80102404:	75 f0                	jne    801023f6 <lapicinit+0xe2>
  lapicw(TPR, 0);
80102406:	ba 00 00 00 00       	mov    $0x0,%edx
8010240b:	b8 20 00 00 00       	mov    $0x20,%eax
80102410:	e8 80 fe ff ff       	call   80102295 <lapicw>
}
80102415:	5d                   	pop    %ebp
80102416:	f3 c3                	repz ret 

80102418 <lapicid>:
{
80102418:	55                   	push   %ebp
80102419:	89 e5                	mov    %esp,%ebp
  if (!lapic)
8010241b:	a1 9c 26 11 80       	mov    0x8011269c,%eax
80102420:	85 c0                	test   %eax,%eax
80102422:	74 08                	je     8010242c <lapicid+0x14>
  return lapic[ID] >> 24;
80102424:	8b 40 20             	mov    0x20(%eax),%eax
80102427:	c1 e8 18             	shr    $0x18,%eax
8010242a:	eb 05                	jmp    80102431 <lapicid+0x19>
    return 0;
8010242c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102431:	5d                   	pop    %ebp
80102432:	c3                   	ret    

80102433 <lapiceoi>:
  if(lapic)
80102433:	83 3d 9c 26 11 80 00 	cmpl   $0x0,0x8011269c
8010243a:	74 13                	je     8010244f <lapiceoi+0x1c>
{
8010243c:	55                   	push   %ebp
8010243d:	89 e5                	mov    %esp,%ebp
    lapicw(EOI, 0);
8010243f:	ba 00 00 00 00       	mov    $0x0,%edx
80102444:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102449:	e8 47 fe ff ff       	call   80102295 <lapicw>
}
8010244e:	5d                   	pop    %ebp
8010244f:	f3 c3                	repz ret 

80102451 <microdelay>:
{
80102451:	55                   	push   %ebp
80102452:	89 e5                	mov    %esp,%ebp
}
80102454:	5d                   	pop    %ebp
80102455:	c3                   	ret    

80102456 <lapicstartap>:
{
80102456:	55                   	push   %ebp
80102457:	89 e5                	mov    %esp,%ebp
80102459:	57                   	push   %edi
8010245a:	56                   	push   %esi
8010245b:	53                   	push   %ebx
8010245c:	8b 75 08             	mov    0x8(%ebp),%esi
8010245f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102462:	ba 70 00 00 00       	mov    $0x70,%edx
80102467:	b8 0f 00 00 00       	mov    $0xf,%eax
8010246c:	ee                   	out    %al,(%dx)
8010246d:	b2 71                	mov    $0x71,%dl
8010246f:	b8 0a 00 00 00       	mov    $0xa,%eax
80102474:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
80102475:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
8010247c:	00 00 
  wrv[1] = addr >> 4;
8010247e:	89 f8                	mov    %edi,%eax
80102480:	c1 e8 04             	shr    $0x4,%eax
80102483:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
80102489:	c1 e6 18             	shl    $0x18,%esi
8010248c:	89 f2                	mov    %esi,%edx
8010248e:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102493:	e8 fd fd ff ff       	call   80102295 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102498:	ba 00 c5 00 00       	mov    $0xc500,%edx
8010249d:	b8 c0 00 00 00       	mov    $0xc0,%eax
801024a2:	e8 ee fd ff ff       	call   80102295 <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
801024a7:	ba 00 85 00 00       	mov    $0x8500,%edx
801024ac:	b8 c0 00 00 00       	mov    $0xc0,%eax
801024b1:	e8 df fd ff ff       	call   80102295 <lapicw>
  for(i = 0; i < 2; i++){
801024b6:	bb 00 00 00 00       	mov    $0x0,%ebx
    lapicw(ICRLO, STARTUP | (addr>>12));
801024bb:	c1 ef 0c             	shr    $0xc,%edi
801024be:	81 cf 00 06 00 00    	or     $0x600,%edi
  for(i = 0; i < 2; i++){
801024c4:	eb 1b                	jmp    801024e1 <lapicstartap+0x8b>
    lapicw(ICRHI, apicid<<24);
801024c6:	89 f2                	mov    %esi,%edx
801024c8:	b8 c4 00 00 00       	mov    $0xc4,%eax
801024cd:	e8 c3 fd ff ff       	call   80102295 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801024d2:	89 fa                	mov    %edi,%edx
801024d4:	b8 c0 00 00 00       	mov    $0xc0,%eax
801024d9:	e8 b7 fd ff ff       	call   80102295 <lapicw>
  for(i = 0; i < 2; i++){
801024de:	83 c3 01             	add    $0x1,%ebx
801024e1:	83 fb 01             	cmp    $0x1,%ebx
801024e4:	7e e0                	jle    801024c6 <lapicstartap+0x70>
}
801024e6:	5b                   	pop    %ebx
801024e7:	5e                   	pop    %esi
801024e8:	5f                   	pop    %edi
801024e9:	5d                   	pop    %ebp
801024ea:	c3                   	ret    

801024eb <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801024eb:	55                   	push   %ebp
801024ec:	89 e5                	mov    %esp,%ebp
801024ee:	57                   	push   %edi
801024ef:	56                   	push   %esi
801024f0:	53                   	push   %ebx
801024f1:	83 ec 4c             	sub    $0x4c,%esp
801024f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801024f7:	b8 0b 00 00 00       	mov    $0xb,%eax
801024fc:	e8 ac fd ff ff       	call   801022ad <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
80102501:	83 e0 04             	and    $0x4,%eax
80102504:	89 45 b4             	mov    %eax,-0x4c(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102507:	8d 5d d0             	lea    -0x30(%ebp),%ebx
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
8010250a:	8d 75 b8             	lea    -0x48(%ebp),%esi
    fill_rtcdate(&t1);
8010250d:	89 d8                	mov    %ebx,%eax
8010250f:	e8 aa fd ff ff       	call   801022be <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102514:	b8 0a 00 00 00       	mov    $0xa,%eax
80102519:	e8 8f fd ff ff       	call   801022ad <cmos_read>
8010251e:	a8 80                	test   $0x80,%al
80102520:	75 eb                	jne    8010250d <cmostime+0x22>
    fill_rtcdate(&t2);
80102522:	89 f0                	mov    %esi,%eax
80102524:	e8 95 fd ff ff       	call   801022be <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102529:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80102530:	00 
80102531:	89 74 24 04          	mov    %esi,0x4(%esp)
80102535:	89 1c 24             	mov    %ebx,(%esp)
80102538:	e8 19 18 00 00       	call   80103d56 <memcmp>
8010253d:	85 c0                	test   %eax,%eax
8010253f:	75 cc                	jne    8010250d <cmostime+0x22>
      break;
  }

  // convert
  if(bcd) {
80102541:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
80102545:	75 7e                	jne    801025c5 <cmostime+0xda>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102547:	8b 55 d0             	mov    -0x30(%ebp),%edx
8010254a:	89 d0                	mov    %edx,%eax
8010254c:	c1 e8 04             	shr    $0x4,%eax
8010254f:	8d 04 80             	lea    (%eax,%eax,4),%eax
80102552:	01 c0                	add    %eax,%eax
80102554:	83 e2 0f             	and    $0xf,%edx
80102557:	01 d0                	add    %edx,%eax
80102559:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
8010255c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010255f:	89 d0                	mov    %edx,%eax
80102561:	c1 e8 04             	shr    $0x4,%eax
80102564:	8d 04 80             	lea    (%eax,%eax,4),%eax
80102567:	01 c0                	add    %eax,%eax
80102569:	83 e2 0f             	and    $0xf,%edx
8010256c:	01 d0                	add    %edx,%eax
8010256e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
80102571:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102574:	89 d0                	mov    %edx,%eax
80102576:	c1 e8 04             	shr    $0x4,%eax
80102579:	8d 04 80             	lea    (%eax,%eax,4),%eax
8010257c:	01 c0                	add    %eax,%eax
8010257e:	83 e2 0f             	and    $0xf,%edx
80102581:	01 d0                	add    %edx,%eax
80102583:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
80102586:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102589:	89 d0                	mov    %edx,%eax
8010258b:	c1 e8 04             	shr    $0x4,%eax
8010258e:	8d 04 80             	lea    (%eax,%eax,4),%eax
80102591:	01 c0                	add    %eax,%eax
80102593:	83 e2 0f             	and    $0xf,%edx
80102596:	01 d0                	add    %edx,%eax
80102598:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
8010259b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010259e:	89 d0                	mov    %edx,%eax
801025a0:	c1 e8 04             	shr    $0x4,%eax
801025a3:	8d 04 80             	lea    (%eax,%eax,4),%eax
801025a6:	01 c0                	add    %eax,%eax
801025a8:	83 e2 0f             	and    $0xf,%edx
801025ab:	01 d0                	add    %edx,%eax
801025ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
801025b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801025b3:	89 d0                	mov    %edx,%eax
801025b5:	c1 e8 04             	shr    $0x4,%eax
801025b8:	8d 04 80             	lea    (%eax,%eax,4),%eax
801025bb:	01 c0                	add    %eax,%eax
801025bd:	83 e2 0f             	and    $0xf,%edx
801025c0:	01 d0                	add    %edx,%eax
801025c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
801025c5:	8b 45 d0             	mov    -0x30(%ebp),%eax
801025c8:	89 07                	mov    %eax,(%edi)
801025ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801025cd:	89 47 04             	mov    %eax,0x4(%edi)
801025d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
801025d3:	89 47 08             	mov    %eax,0x8(%edi)
801025d6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801025d9:	89 47 0c             	mov    %eax,0xc(%edi)
801025dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801025df:	89 47 10             	mov    %eax,0x10(%edi)
801025e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801025e5:	89 47 14             	mov    %eax,0x14(%edi)
  r->year += 2000;
801025e8:	81 47 14 d0 07 00 00 	addl   $0x7d0,0x14(%edi)
}
801025ef:	83 c4 4c             	add    $0x4c,%esp
801025f2:	5b                   	pop    %ebx
801025f3:	5e                   	pop    %esi
801025f4:	5f                   	pop    %edi
801025f5:	5d                   	pop    %ebp
801025f6:	c3                   	ret    

801025f7 <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801025f7:	55                   	push   %ebp
801025f8:	89 e5                	mov    %esp,%ebp
801025fa:	53                   	push   %ebx
801025fb:	83 ec 14             	sub    $0x14,%esp
  struct buf *buf = bread(log.dev, log.start);
801025fe:	a1 d4 26 11 80       	mov    0x801126d4,%eax
80102603:	89 44 24 04          	mov    %eax,0x4(%esp)
80102607:	a1 e4 26 11 80       	mov    0x801126e4,%eax
8010260c:	89 04 24             	mov    %eax,(%esp)
8010260f:	e8 4f db ff ff       	call   80100163 <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
80102614:	8b 58 5c             	mov    0x5c(%eax),%ebx
80102617:	89 1d e8 26 11 80    	mov    %ebx,0x801126e8
  for (i = 0; i < log.lh.n; i++) {
8010261d:	ba 00 00 00 00       	mov    $0x0,%edx
80102622:	eb 0e                	jmp    80102632 <read_head+0x3b>
    log.lh.block[i] = lh->block[i];
80102624:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102628:	89 0c 95 ec 26 11 80 	mov    %ecx,-0x7feed914(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010262f:	83 c2 01             	add    $0x1,%edx
80102632:	39 da                	cmp    %ebx,%edx
80102634:	7c ee                	jl     80102624 <read_head+0x2d>
  }
  brelse(buf);
80102636:	89 04 24             	mov    %eax,(%esp)
80102639:	e8 84 db ff ff       	call   801001c2 <brelse>
}
8010263e:	83 c4 14             	add    $0x14,%esp
80102641:	5b                   	pop    %ebx
80102642:	5d                   	pop    %ebp
80102643:	c3                   	ret    

80102644 <install_trans>:
{
80102644:	55                   	push   %ebp
80102645:	89 e5                	mov    %esp,%ebp
80102647:	57                   	push   %edi
80102648:	56                   	push   %esi
80102649:	53                   	push   %ebx
8010264a:	83 ec 1c             	sub    $0x1c,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010264d:	bb 00 00 00 00       	mov    $0x0,%ebx
80102652:	eb 6d                	jmp    801026c1 <install_trans+0x7d>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102654:	89 d8                	mov    %ebx,%eax
80102656:	03 05 d4 26 11 80    	add    0x801126d4,%eax
8010265c:	83 c0 01             	add    $0x1,%eax
8010265f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102663:	a1 e4 26 11 80       	mov    0x801126e4,%eax
80102668:	89 04 24             	mov    %eax,(%esp)
8010266b:	e8 f3 da ff ff       	call   80100163 <bread>
80102670:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102672:	8b 04 9d ec 26 11 80 	mov    -0x7feed914(,%ebx,4),%eax
80102679:	89 44 24 04          	mov    %eax,0x4(%esp)
8010267d:	a1 e4 26 11 80       	mov    0x801126e4,%eax
80102682:	89 04 24             	mov    %eax,(%esp)
80102685:	e8 d9 da ff ff       	call   80100163 <bread>
8010268a:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010268c:	8d 57 5c             	lea    0x5c(%edi),%edx
8010268f:	8d 40 5c             	lea    0x5c(%eax),%eax
80102692:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80102699:	00 
8010269a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010269e:	89 04 24             	mov    %eax,(%esp)
801026a1:	e8 e7 16 00 00       	call   80103d8d <memmove>
    bwrite(dbuf);  // write dst to disk
801026a6:	89 34 24             	mov    %esi,(%esp)
801026a9:	e8 de da ff ff       	call   8010018c <bwrite>
    brelse(lbuf);
801026ae:	89 3c 24             	mov    %edi,(%esp)
801026b1:	e8 0c db ff ff       	call   801001c2 <brelse>
    brelse(dbuf);
801026b6:	89 34 24             	mov    %esi,(%esp)
801026b9:	e8 04 db ff ff       	call   801001c2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801026be:	83 c3 01             	add    $0x1,%ebx
801026c1:	39 1d e8 26 11 80    	cmp    %ebx,0x801126e8
801026c7:	7f 8b                	jg     80102654 <install_trans+0x10>
}
801026c9:	83 c4 1c             	add    $0x1c,%esp
801026cc:	5b                   	pop    %ebx
801026cd:	5e                   	pop    %esi
801026ce:	5f                   	pop    %edi
801026cf:	5d                   	pop    %ebp
801026d0:	c3                   	ret    

801026d1 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801026d1:	55                   	push   %ebp
801026d2:	89 e5                	mov    %esp,%ebp
801026d4:	53                   	push   %ebx
801026d5:	83 ec 14             	sub    $0x14,%esp
  struct buf *buf = bread(log.dev, log.start);
801026d8:	a1 d4 26 11 80       	mov    0x801126d4,%eax
801026dd:	89 44 24 04          	mov    %eax,0x4(%esp)
801026e1:	a1 e4 26 11 80       	mov    0x801126e4,%eax
801026e6:	89 04 24             	mov    %eax,(%esp)
801026e9:	e8 75 da ff ff       	call   80100163 <bread>
801026ee:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
801026f0:	a1 e8 26 11 80       	mov    0x801126e8,%eax
801026f5:	89 43 5c             	mov    %eax,0x5c(%ebx)
  for (i = 0; i < log.lh.n; i++) {
801026f8:	ba 00 00 00 00       	mov    $0x0,%edx
801026fd:	eb 0e                	jmp    8010270d <write_head+0x3c>
    hb->block[i] = log.lh.block[i];
801026ff:	8b 0c 95 ec 26 11 80 	mov    -0x7feed914(,%edx,4),%ecx
80102706:	89 4c 93 60          	mov    %ecx,0x60(%ebx,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010270a:	83 c2 01             	add    $0x1,%edx
8010270d:	39 c2                	cmp    %eax,%edx
8010270f:	7c ee                	jl     801026ff <write_head+0x2e>
  }
  bwrite(buf);
80102711:	89 1c 24             	mov    %ebx,(%esp)
80102714:	e8 73 da ff ff       	call   8010018c <bwrite>
  brelse(buf);
80102719:	89 1c 24             	mov    %ebx,(%esp)
8010271c:	e8 a1 da ff ff       	call   801001c2 <brelse>
}
80102721:	83 c4 14             	add    $0x14,%esp
80102724:	5b                   	pop    %ebx
80102725:	5d                   	pop    %ebp
80102726:	c3                   	ret    

80102727 <recover_from_log>:

static void
recover_from_log(void)
{
80102727:	55                   	push   %ebp
80102728:	89 e5                	mov    %esp,%ebp
8010272a:	83 ec 08             	sub    $0x8,%esp
  read_head();
8010272d:	e8 c5 fe ff ff       	call   801025f7 <read_head>
  install_trans(); // if committed, copy from log to disk
80102732:	e8 0d ff ff ff       	call   80102644 <install_trans>
  log.lh.n = 0;
80102737:	c7 05 e8 26 11 80 00 	movl   $0x0,0x801126e8
8010273e:	00 00 00 
  write_head(); // clear the log
80102741:	e8 8b ff ff ff       	call   801026d1 <write_head>
}
80102746:	c9                   	leave  
80102747:	c3                   	ret    

80102748 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80102748:	55                   	push   %ebp
80102749:	89 e5                	mov    %esp,%ebp
8010274b:	57                   	push   %edi
8010274c:	56                   	push   %esi
8010274d:	53                   	push   %ebx
8010274e:	83 ec 1c             	sub    $0x1c,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102751:	bb 00 00 00 00       	mov    $0x0,%ebx
80102756:	eb 6d                	jmp    801027c5 <write_log+0x7d>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102758:	89 d8                	mov    %ebx,%eax
8010275a:	03 05 d4 26 11 80    	add    0x801126d4,%eax
80102760:	83 c0 01             	add    $0x1,%eax
80102763:	89 44 24 04          	mov    %eax,0x4(%esp)
80102767:	a1 e4 26 11 80       	mov    0x801126e4,%eax
8010276c:	89 04 24             	mov    %eax,(%esp)
8010276f:	e8 ef d9 ff ff       	call   80100163 <bread>
80102774:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102776:	8b 04 9d ec 26 11 80 	mov    -0x7feed914(,%ebx,4),%eax
8010277d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102781:	a1 e4 26 11 80       	mov    0x801126e4,%eax
80102786:	89 04 24             	mov    %eax,(%esp)
80102789:	e8 d5 d9 ff ff       	call   80100163 <bread>
8010278e:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102790:	8d 50 5c             	lea    0x5c(%eax),%edx
80102793:	8d 46 5c             	lea    0x5c(%esi),%eax
80102796:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010279d:	00 
8010279e:	89 54 24 04          	mov    %edx,0x4(%esp)
801027a2:	89 04 24             	mov    %eax,(%esp)
801027a5:	e8 e3 15 00 00       	call   80103d8d <memmove>
    bwrite(to);  // write the log
801027aa:	89 34 24             	mov    %esi,(%esp)
801027ad:	e8 da d9 ff ff       	call   8010018c <bwrite>
    brelse(from);
801027b2:	89 3c 24             	mov    %edi,(%esp)
801027b5:	e8 08 da ff ff       	call   801001c2 <brelse>
    brelse(to);
801027ba:	89 34 24             	mov    %esi,(%esp)
801027bd:	e8 00 da ff ff       	call   801001c2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801027c2:	83 c3 01             	add    $0x1,%ebx
801027c5:	39 1d e8 26 11 80    	cmp    %ebx,0x801126e8
801027cb:	7f 8b                	jg     80102758 <write_log+0x10>
  }
}
801027cd:	83 c4 1c             	add    $0x1c,%esp
801027d0:	5b                   	pop    %ebx
801027d1:	5e                   	pop    %esi
801027d2:	5f                   	pop    %edi
801027d3:	5d                   	pop    %ebp
801027d4:	c3                   	ret    

801027d5 <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
801027d5:	83 3d e8 26 11 80 00 	cmpl   $0x0,0x801126e8
801027dc:	7e 25                	jle    80102803 <commit+0x2e>
{
801027de:	55                   	push   %ebp
801027df:	89 e5                	mov    %esp,%ebp
801027e1:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
801027e4:	e8 5f ff ff ff       	call   80102748 <write_log>
    write_head();    // Write header to disk -- the real commit
801027e9:	e8 e3 fe ff ff       	call   801026d1 <write_head>
    install_trans(); // Now install writes to home locations
801027ee:	e8 51 fe ff ff       	call   80102644 <install_trans>
    log.lh.n = 0;
801027f3:	c7 05 e8 26 11 80 00 	movl   $0x0,0x801126e8
801027fa:	00 00 00 
    write_head();    // Erase the transaction from the log
801027fd:	e8 cf fe ff ff       	call   801026d1 <write_head>
  }
}
80102802:	c9                   	leave  
80102803:	f3 c3                	repz ret 

80102805 <initlog>:
{
80102805:	55                   	push   %ebp
80102806:	89 e5                	mov    %esp,%ebp
80102808:	53                   	push   %ebx
80102809:	83 ec 34             	sub    $0x34,%esp
8010280c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
8010280f:	c7 44 24 04 20 6b 10 	movl   $0x80106b20,0x4(%esp)
80102816:	80 
80102817:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
8010281e:	e8 01 13 00 00       	call   80103b24 <initlock>
  readsb(dev, &sb);
80102823:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102826:	89 44 24 04          	mov    %eax,0x4(%esp)
8010282a:	89 1c 24             	mov    %ebx,(%esp)
8010282d:	e8 dd ea ff ff       	call   8010130f <readsb>
  log.start = sb.logstart;
80102832:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102835:	a3 d4 26 11 80       	mov    %eax,0x801126d4
  log.size = sb.nlog;
8010283a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010283d:	a3 d8 26 11 80       	mov    %eax,0x801126d8
  log.dev = dev;
80102842:	89 1d e4 26 11 80    	mov    %ebx,0x801126e4
  recover_from_log();
80102848:	e8 da fe ff ff       	call   80102727 <recover_from_log>
}
8010284d:	83 c4 34             	add    $0x34,%esp
80102850:	5b                   	pop    %ebx
80102851:	5d                   	pop    %ebp
80102852:	c3                   	ret    

80102853 <begin_op>:
{
80102853:	55                   	push   %ebp
80102854:	89 e5                	mov    %esp,%ebp
80102856:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80102859:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
80102860:	e8 f7 13 00 00       	call   80103c5c <acquire>
    if(log.committing){
80102865:	83 3d e0 26 11 80 00 	cmpl   $0x0,0x801126e0
8010286c:	74 16                	je     80102884 <begin_op+0x31>
      sleep(&log, &log.lock);
8010286e:	c7 44 24 04 a0 26 11 	movl   $0x801126a0,0x4(%esp)
80102875:	80 
80102876:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
8010287d:	e8 e9 0e 00 00       	call   8010376b <sleep>
80102882:	eb e1                	jmp    80102865 <begin_op+0x12>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102884:	a1 dc 26 11 80       	mov    0x801126dc,%eax
80102889:	8d 50 01             	lea    0x1(%eax),%edx
8010288c:	8d 04 92             	lea    (%edx,%edx,4),%eax
8010288f:	01 c0                	add    %eax,%eax
80102891:	03 05 e8 26 11 80    	add    0x801126e8,%eax
80102897:	83 f8 1e             	cmp    $0x1e,%eax
8010289a:	7e 16                	jle    801028b2 <begin_op+0x5f>
      sleep(&log, &log.lock);
8010289c:	c7 44 24 04 a0 26 11 	movl   $0x801126a0,0x4(%esp)
801028a3:	80 
801028a4:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
801028ab:	e8 bb 0e 00 00       	call   8010376b <sleep>
801028b0:	eb b3                	jmp    80102865 <begin_op+0x12>
      log.outstanding += 1;
801028b2:	89 15 dc 26 11 80    	mov    %edx,0x801126dc
      release(&log.lock);
801028b8:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
801028bf:	e8 f9 13 00 00       	call   80103cbd <release>
}
801028c4:	c9                   	leave  
801028c5:	c3                   	ret    

801028c6 <end_op>:
{
801028c6:	55                   	push   %ebp
801028c7:	89 e5                	mov    %esp,%ebp
801028c9:	53                   	push   %ebx
801028ca:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
801028cd:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
801028d4:	e8 83 13 00 00       	call   80103c5c <acquire>
  log.outstanding -= 1;
801028d9:	a1 dc 26 11 80       	mov    0x801126dc,%eax
801028de:	83 e8 01             	sub    $0x1,%eax
801028e1:	a3 dc 26 11 80       	mov    %eax,0x801126dc
  if(log.committing)
801028e6:	83 3d e0 26 11 80 00 	cmpl   $0x0,0x801126e0
801028ed:	74 0c                	je     801028fb <end_op+0x35>
    panic("log.committing");
801028ef:	c7 04 24 24 6b 10 80 	movl   $0x80106b24,(%esp)
801028f6:	e8 2a da ff ff       	call   80100325 <panic>
  if(log.outstanding == 0){
801028fb:	85 c0                	test   %eax,%eax
801028fd:	75 11                	jne    80102910 <end_op+0x4a>
    log.committing = 1;
801028ff:	c7 05 e0 26 11 80 01 	movl   $0x1,0x801126e0
80102906:	00 00 00 
    do_commit = 1;
80102909:	bb 01 00 00 00       	mov    $0x1,%ebx
8010290e:	eb 11                	jmp    80102921 <end_op+0x5b>
    wakeup(&log);
80102910:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
80102917:	e8 a4 0f 00 00       	call   801038c0 <wakeup>
  int do_commit = 0;
8010291c:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&log.lock);
80102921:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
80102928:	e8 90 13 00 00       	call   80103cbd <release>
  if(do_commit){
8010292d:	85 db                	test   %ebx,%ebx
8010292f:	74 33                	je     80102964 <end_op+0x9e>
    commit();
80102931:	e8 9f fe ff ff       	call   801027d5 <commit>
    acquire(&log.lock);
80102936:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
8010293d:	e8 1a 13 00 00       	call   80103c5c <acquire>
    log.committing = 0;
80102942:	c7 05 e0 26 11 80 00 	movl   $0x0,0x801126e0
80102949:	00 00 00 
    wakeup(&log);
8010294c:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
80102953:	e8 68 0f 00 00       	call   801038c0 <wakeup>
    release(&log.lock);
80102958:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
8010295f:	e8 59 13 00 00       	call   80103cbd <release>
}
80102964:	83 c4 14             	add    $0x14,%esp
80102967:	5b                   	pop    %ebx
80102968:	5d                   	pop    %ebp
80102969:	c3                   	ret    

8010296a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010296a:	55                   	push   %ebp
8010296b:	89 e5                	mov    %esp,%ebp
8010296d:	53                   	push   %ebx
8010296e:	83 ec 14             	sub    $0x14,%esp
80102971:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102974:	a1 e8 26 11 80       	mov    0x801126e8,%eax
80102979:	83 f8 1d             	cmp    $0x1d,%eax
8010297c:	7f 0d                	jg     8010298b <log_write+0x21>
8010297e:	8b 0d d8 26 11 80    	mov    0x801126d8,%ecx
80102984:	8d 51 ff             	lea    -0x1(%ecx),%edx
80102987:	39 d0                	cmp    %edx,%eax
80102989:	7c 0c                	jl     80102997 <log_write+0x2d>
    panic("too big a transaction");
8010298b:	c7 04 24 33 6b 10 80 	movl   $0x80106b33,(%esp)
80102992:	e8 8e d9 ff ff       	call   80100325 <panic>
  if (log.outstanding < 1)
80102997:	83 3d dc 26 11 80 00 	cmpl   $0x0,0x801126dc
8010299e:	7f 0c                	jg     801029ac <log_write+0x42>
    panic("log_write outside of trans");
801029a0:	c7 04 24 49 6b 10 80 	movl   $0x80106b49,(%esp)
801029a7:	e8 79 d9 ff ff       	call   80100325 <panic>

  acquire(&log.lock);
801029ac:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
801029b3:	e8 a4 12 00 00       	call   80103c5c <acquire>
  for (i = 0; i < log.lh.n; i++) {
801029b8:	b8 00 00 00 00       	mov    $0x0,%eax
801029bd:	eb 0f                	jmp    801029ce <log_write+0x64>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801029bf:	8b 4b 08             	mov    0x8(%ebx),%ecx
801029c2:	39 0c 85 ec 26 11 80 	cmp    %ecx,-0x7feed914(,%eax,4)
801029c9:	74 0d                	je     801029d8 <log_write+0x6e>
  for (i = 0; i < log.lh.n; i++) {
801029cb:	83 c0 01             	add    $0x1,%eax
801029ce:	8b 15 e8 26 11 80    	mov    0x801126e8,%edx
801029d4:	39 c2                	cmp    %eax,%edx
801029d6:	7f e7                	jg     801029bf <log_write+0x55>
      break;
  }
  log.lh.block[i] = b->blockno;
801029d8:	8b 4b 08             	mov    0x8(%ebx),%ecx
801029db:	89 0c 85 ec 26 11 80 	mov    %ecx,-0x7feed914(,%eax,4)
  if (i == log.lh.n)
801029e2:	39 d0                	cmp    %edx,%eax
801029e4:	75 09                	jne    801029ef <log_write+0x85>
    log.lh.n++;
801029e6:	83 c2 01             	add    $0x1,%edx
801029e9:	89 15 e8 26 11 80    	mov    %edx,0x801126e8
  b->flags |= B_DIRTY; // prevent eviction
801029ef:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
801029f2:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
801029f9:	e8 bf 12 00 00       	call   80103cbd <release>
}
801029fe:	83 c4 14             	add    $0x14,%esp
80102a01:	5b                   	pop    %ebx
80102a02:	5d                   	pop    %ebp
80102a03:	c3                   	ret    
80102a04:	66 90                	xchg   %ax,%ax
80102a06:	66 90                	xchg   %ax,%ax
80102a08:	66 90                	xchg   %ax,%ax
80102a0a:	66 90                	xchg   %ax,%ax
80102a0c:	66 90                	xchg   %ax,%ax
80102a0e:	66 90                	xchg   %ax,%ax

80102a10 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80102a10:	55                   	push   %ebp
80102a11:	89 e5                	mov    %esp,%ebp
80102a13:	56                   	push   %esi
80102a14:	53                   	push   %ebx
80102a15:	83 ec 10             	sub    $0x10,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102a18:	c7 44 24 08 8a 00 00 	movl   $0x8a,0x8(%esp)
80102a1f:	00 
80102a20:	c7 44 24 04 8c a4 10 	movl   $0x8010a48c,0x4(%esp)
80102a27:	80 
80102a28:	c7 04 24 00 70 00 80 	movl   $0x80007000,(%esp)
80102a2f:	e8 59 13 00 00       	call   80103d8d <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102a34:	bb a0 27 11 80       	mov    $0x801127a0,%ebx
    if (a < (void*) KERNBASE)
80102a39:	be 00 90 10 80       	mov    $0x80109000,%esi
80102a3e:	eb 63                	jmp    80102aa3 <startothers+0x93>
    if(c == mycpu())  // We've started already.
80102a40:	e8 0b 08 00 00       	call   80103250 <mycpu>
80102a45:	39 d8                	cmp    %ebx,%eax
80102a47:	74 54                	je     80102a9d <startothers+0x8d>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102a49:	e8 0b f7 ff ff       	call   80102159 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102a4e:	05 00 10 00 00       	add    $0x1000,%eax
80102a53:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102a58:	c7 05 f8 6f 00 80 01 	movl   $0x80102b01,0x80006ff8
80102a5f:	2b 10 80 
80102a62:	81 fe ff ff ff 7f    	cmp    $0x7fffffff,%esi
80102a68:	77 0c                	ja     80102a76 <startothers+0x66>
        panic("V2P on address < KERNBASE "
80102a6a:	c7 04 24 48 68 10 80 	movl   $0x80106848,(%esp)
80102a71:	e8 af d8 ff ff       	call   80100325 <panic>
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102a76:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102a7d:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
80102a80:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
80102a87:	00 
80102a88:	0f b6 03             	movzbl (%ebx),%eax
80102a8b:	89 04 24             	mov    %eax,(%esp)
80102a8e:	e8 c3 f9 ff ff       	call   80102456 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102a93:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102a99:	85 c0                	test   %eax,%eax
80102a9b:	74 f6                	je     80102a93 <startothers+0x83>
  for(c = cpus; c < cpus+ncpu; c++){
80102a9d:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102aa3:	69 05 20 2d 11 80 b0 	imul   $0xb0,0x80112d20,%eax
80102aaa:	00 00 00 
80102aad:	05 a0 27 11 80       	add    $0x801127a0,%eax
80102ab2:	39 d8                	cmp    %ebx,%eax
80102ab4:	77 8a                	ja     80102a40 <startothers+0x30>
      ;
  }
}
80102ab6:	83 c4 10             	add    $0x10,%esp
80102ab9:	5b                   	pop    %ebx
80102aba:	5e                   	pop    %esi
80102abb:	5d                   	pop    %ebp
80102abc:	c3                   	ret    

80102abd <mpmain>:
{
80102abd:	55                   	push   %ebp
80102abe:	89 e5                	mov    %esp,%ebp
80102ac0:	53                   	push   %ebx
80102ac1:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102ac4:	e8 e1 07 00 00       	call   801032aa <cpuid>
80102ac9:	89 c3                	mov    %eax,%ebx
80102acb:	e8 da 07 00 00       	call   801032aa <cpuid>
80102ad0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80102ad4:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ad8:	c7 04 24 64 6b 10 80 	movl   $0x80106b64,(%esp)
80102adf:	e8 e3 da ff ff       	call   801005c7 <cprintf>
  idtinit();       // load idt register
80102ae4:	e8 d3 23 00 00       	call   80104ebc <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102ae9:	e8 62 07 00 00       	call   80103250 <mycpu>
80102aee:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102af0:	b8 01 00 00 00       	mov    $0x1,%eax
80102af5:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102afc:	e8 5c 0a 00 00       	call   8010355d <scheduler>

80102b01 <mpenter>:
{
80102b01:	55                   	push   %ebp
80102b02:	89 e5                	mov    %esp,%ebp
80102b04:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102b07:	e8 84 33 00 00       	call   80105e90 <switchkvm>
  seginit();
80102b0c:	e8 a7 32 00 00       	call   80105db8 <seginit>
  lapicinit();
80102b11:	e8 fe f7 ff ff       	call   80102314 <lapicinit>
  mpmain();
80102b16:	e8 a2 ff ff ff       	call   80102abd <mpmain>

80102b1b <main>:
{
80102b1b:	55                   	push   %ebp
80102b1c:	89 e5                	mov    %esp,%ebp
80102b1e:	83 e4 f0             	and    $0xfffffff0,%esp
80102b21:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102b24:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80102b2b:	80 
80102b2c:	c7 04 24 c8 54 11 80 	movl   $0x801154c8,(%esp)
80102b33:	e8 c5 f5 ff ff       	call   801020fd <kinit1>
  kvmalloc();      // kernel page table
80102b38:	e8 71 38 00 00       	call   801063ae <kvmalloc>
  mpinit();        // detect other processors
80102b3d:	e8 fc 01 00 00       	call   80102d3e <mpinit>
  lapicinit();     // interrupt controller
80102b42:	e8 cd f7 ff ff       	call   80102314 <lapicinit>
  seginit();       // segment descriptors
80102b47:	e8 6c 32 00 00       	call   80105db8 <seginit>
80102b4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  picinit();       // disable pic
80102b50:	e8 a8 02 00 00       	call   80102dfd <picinit>
  ioapicinit();    // another interrupt controller
80102b55:	e8 1e f4 ff ff       	call   80101f78 <ioapicinit>
  consoleinit();   // console hardware
80102b5a:	e8 de dc ff ff       	call   8010083d <consoleinit>
80102b5f:	90                   	nop
  uartinit();      // serial port
80102b60:	e8 17 26 00 00       	call   8010517c <uartinit>
  pinit();         // process table
80102b65:	e8 ca 06 00 00       	call   80103234 <pinit>
  tvinit();        // trap vectors
80102b6a:	e8 c1 22 00 00       	call   80104e30 <tvinit>
80102b6f:	90                   	nop
  binit();         // buffer cache
80102b70:	e8 74 d5 ff ff       	call   801000e9 <binit>
  fileinit();      // file table
80102b75:	e8 e6 e0 ff ff       	call   80100c60 <fileinit>
  ideinit();       // disk 
80102b7a:	e8 14 f2 ff ff       	call   80101d93 <ideinit>
80102b7f:	90                   	nop
  startothers();   // start other processors
80102b80:	e8 8b fe ff ff       	call   80102a10 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102b85:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80102b8c:	8e 
80102b8d:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80102b94:	e8 9c f5 ff ff       	call   80102135 <kinit2>
  userinit();      // first user process
80102b99:	e8 4b 07 00 00       	call   801032e9 <userinit>
  mpmain();        // finish this processor's setup
80102b9e:	e8 1a ff ff ff       	call   80102abd <mpmain>

80102ba3 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102ba3:	55                   	push   %ebp
80102ba4:	89 e5                	mov    %esp,%ebp
80102ba6:	56                   	push   %esi
80102ba7:	53                   	push   %ebx
  int i, sum;

  sum = 0;
80102ba8:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(i=0; i<len; i++)
80102bad:	b9 00 00 00 00       	mov    $0x0,%ecx
80102bb2:	eb 09                	jmp    80102bbd <sum+0x1a>
    sum += addr[i];
80102bb4:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102bb8:	01 f3                	add    %esi,%ebx
  for(i=0; i<len; i++)
80102bba:	83 c1 01             	add    $0x1,%ecx
80102bbd:	39 d1                	cmp    %edx,%ecx
80102bbf:	7c f3                	jl     80102bb4 <sum+0x11>
  return sum;
}
80102bc1:	89 d8                	mov    %ebx,%eax
80102bc3:	5b                   	pop    %ebx
80102bc4:	5e                   	pop    %esi
80102bc5:	5d                   	pop    %ebp
80102bc6:	c3                   	ret    

80102bc7 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102bc7:	55                   	push   %ebp
80102bc8:	89 e5                	mov    %esp,%ebp
80102bca:	56                   	push   %esi
80102bcb:	53                   	push   %ebx
80102bcc:	83 ec 10             	sub    $0x10,%esp
}

// Convert physical address to kernel virtual address
static inline void *P2V(uint a) {
    extern void panic(char*) __attribute__((noreturn));
    if (a > KERNBASE)
80102bcf:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80102bd4:	76 0c                	jbe    80102be2 <mpsearch1+0x1b>
        panic("P2V on address > KERNBASE");
80102bd6:	c7 04 24 78 6b 10 80 	movl   $0x80106b78,(%esp)
80102bdd:	e8 43 d7 ff ff       	call   80100325 <panic>
    return (char*)a + KERNBASE;
80102be2:	05 00 00 00 80       	add    $0x80000000,%eax
80102be7:	89 c3                	mov    %eax,%ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
80102be9:	8d 34 10             	lea    (%eax,%edx,1),%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102bec:	eb 2f                	jmp    80102c1d <mpsearch1+0x56>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102bee:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80102bf5:	00 
80102bf6:	c7 44 24 04 92 6b 10 	movl   $0x80106b92,0x4(%esp)
80102bfd:	80 
80102bfe:	89 1c 24             	mov    %ebx,(%esp)
80102c01:	e8 50 11 00 00       	call   80103d56 <memcmp>
80102c06:	85 c0                	test   %eax,%eax
80102c08:	75 10                	jne    80102c1a <mpsearch1+0x53>
80102c0a:	ba 10 00 00 00       	mov    $0x10,%edx
80102c0f:	89 d8                	mov    %ebx,%eax
80102c11:	e8 8d ff ff ff       	call   80102ba3 <sum>
80102c16:	84 c0                	test   %al,%al
80102c18:	74 0e                	je     80102c28 <mpsearch1+0x61>
  for(p = addr; p < e; p += sizeof(struct mp))
80102c1a:	83 c3 10             	add    $0x10,%ebx
80102c1d:	39 f3                	cmp    %esi,%ebx
80102c1f:	72 cd                	jb     80102bee <mpsearch1+0x27>
      return (struct mp*)p;
  return 0;
80102c21:	b8 00 00 00 00       	mov    $0x0,%eax
80102c26:	eb 02                	jmp    80102c2a <mpsearch1+0x63>
      return (struct mp*)p;
80102c28:	89 d8                	mov    %ebx,%eax
}
80102c2a:	83 c4 10             	add    $0x10,%esp
80102c2d:	5b                   	pop    %ebx
80102c2e:	5e                   	pop    %esi
80102c2f:	5d                   	pop    %ebp
80102c30:	c3                   	ret    

80102c31 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102c31:	55                   	push   %ebp
80102c32:	89 e5                	mov    %esp,%ebp
80102c34:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102c37:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102c3e:	c1 e0 08             	shl    $0x8,%eax
80102c41:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102c48:	09 d0                	or     %edx,%eax
80102c4a:	c1 e0 04             	shl    $0x4,%eax
80102c4d:	85 c0                	test   %eax,%eax
80102c4f:	74 10                	je     80102c61 <mpsearch+0x30>
    if((mp = mpsearch1(p, 1024)))
80102c51:	ba 00 04 00 00       	mov    $0x400,%edx
80102c56:	e8 6c ff ff ff       	call   80102bc7 <mpsearch1>
80102c5b:	85 c0                	test   %eax,%eax
80102c5d:	75 3a                	jne    80102c99 <mpsearch+0x68>
80102c5f:	eb 29                	jmp    80102c8a <mpsearch+0x59>
      return mp;
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102c61:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102c68:	c1 e0 08             	shl    $0x8,%eax
80102c6b:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102c72:	09 d0                	or     %edx,%eax
80102c74:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102c77:	2d 00 04 00 00       	sub    $0x400,%eax
80102c7c:	ba 00 04 00 00       	mov    $0x400,%edx
80102c81:	e8 41 ff ff ff       	call   80102bc7 <mpsearch1>
80102c86:	85 c0                	test   %eax,%eax
80102c88:	75 0f                	jne    80102c99 <mpsearch+0x68>
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102c8a:	ba 00 00 01 00       	mov    $0x10000,%edx
80102c8f:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102c94:	e8 2e ff ff ff       	call   80102bc7 <mpsearch1>
}
80102c99:	c9                   	leave  
80102c9a:	c3                   	ret    

80102c9b <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102c9b:	55                   	push   %ebp
80102c9c:	89 e5                	mov    %esp,%ebp
80102c9e:	57                   	push   %edi
80102c9f:	56                   	push   %esi
80102ca0:	53                   	push   %ebx
80102ca1:	83 ec 1c             	sub    $0x1c,%esp
80102ca4:	89 c7                	mov    %eax,%edi
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102ca6:	e8 86 ff ff ff       	call   80102c31 <mpsearch>
80102cab:	89 c6                	mov    %eax,%esi
80102cad:	85 c0                	test   %eax,%eax
80102caf:	74 64                	je     80102d15 <mpconfig+0x7a>
80102cb1:	8b 58 04             	mov    0x4(%eax),%ebx
80102cb4:	85 db                	test   %ebx,%ebx
80102cb6:	74 64                	je     80102d1c <mpconfig+0x81>
    if (a > KERNBASE)
80102cb8:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80102cbe:	76 0c                	jbe    80102ccc <mpconfig+0x31>
        panic("P2V on address > KERNBASE");
80102cc0:	c7 04 24 78 6b 10 80 	movl   $0x80106b78,(%esp)
80102cc7:	e8 59 d6 ff ff       	call   80100325 <panic>
    return (char*)a + KERNBASE;
80102ccc:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
  if(memcmp(conf, "PCMP", 4) != 0)
80102cd2:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80102cd9:	00 
80102cda:	c7 44 24 04 97 6b 10 	movl   $0x80106b97,0x4(%esp)
80102ce1:	80 
80102ce2:	89 1c 24             	mov    %ebx,(%esp)
80102ce5:	e8 6c 10 00 00       	call   80103d56 <memcmp>
80102cea:	85 c0                	test   %eax,%eax
80102cec:	75 35                	jne    80102d23 <mpconfig+0x88>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102cee:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
80102cf2:	3c 01                	cmp    $0x1,%al
80102cf4:	0f 95 c2             	setne  %dl
80102cf7:	3c 04                	cmp    $0x4,%al
80102cf9:	0f 95 c0             	setne  %al
80102cfc:	84 c2                	test   %al,%dl
80102cfe:	75 2a                	jne    80102d2a <mpconfig+0x8f>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102d00:	0f b7 53 04          	movzwl 0x4(%ebx),%edx
80102d04:	89 d8                	mov    %ebx,%eax
80102d06:	e8 98 fe ff ff       	call   80102ba3 <sum>
80102d0b:	84 c0                	test   %al,%al
80102d0d:	75 22                	jne    80102d31 <mpconfig+0x96>
    return 0;
  *pmp = mp;
80102d0f:	89 37                	mov    %esi,(%edi)
  return conf;
80102d11:	89 d8                	mov    %ebx,%eax
80102d13:	eb 21                	jmp    80102d36 <mpconfig+0x9b>
    return 0;
80102d15:	b8 00 00 00 00       	mov    $0x0,%eax
80102d1a:	eb 1a                	jmp    80102d36 <mpconfig+0x9b>
80102d1c:	b8 00 00 00 00       	mov    $0x0,%eax
80102d21:	eb 13                	jmp    80102d36 <mpconfig+0x9b>
    return 0;
80102d23:	b8 00 00 00 00       	mov    $0x0,%eax
80102d28:	eb 0c                	jmp    80102d36 <mpconfig+0x9b>
    return 0;
80102d2a:	b8 00 00 00 00       	mov    $0x0,%eax
80102d2f:	eb 05                	jmp    80102d36 <mpconfig+0x9b>
    return 0;
80102d31:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102d36:	83 c4 1c             	add    $0x1c,%esp
80102d39:	5b                   	pop    %ebx
80102d3a:	5e                   	pop    %esi
80102d3b:	5f                   	pop    %edi
80102d3c:	5d                   	pop    %ebp
80102d3d:	c3                   	ret    

80102d3e <mpinit>:

void
mpinit(void)
{
80102d3e:	55                   	push   %ebp
80102d3f:	89 e5                	mov    %esp,%ebp
80102d41:	56                   	push   %esi
80102d42:	53                   	push   %ebx
80102d43:	83 ec 20             	sub    $0x20,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102d46:	8d 45 f4             	lea    -0xc(%ebp),%eax
80102d49:	e8 4d ff ff ff       	call   80102c9b <mpconfig>
80102d4e:	85 c0                	test   %eax,%eax
80102d50:	75 0c                	jne    80102d5e <mpinit+0x20>
    panic("Expect to run on an SMP");
80102d52:	c7 04 24 9c 6b 10 80 	movl   $0x80106b9c,(%esp)
80102d59:	e8 c7 d5 ff ff       	call   80100325 <panic>
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102d5e:	8b 50 24             	mov    0x24(%eax),%edx
80102d61:	89 15 9c 26 11 80    	mov    %edx,0x8011269c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102d67:	8d 50 2c             	lea    0x2c(%eax),%edx
80102d6a:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102d6e:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102d70:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102d75:	eb 50                	jmp    80102dc7 <mpinit+0x89>
    switch(*p){
80102d77:	0f b6 02             	movzbl (%edx),%eax
80102d7a:	3c 04                	cmp    $0x4,%al
80102d7c:	77 44                	ja     80102dc2 <mpinit+0x84>
80102d7e:	0f b6 c0             	movzbl %al,%eax
80102d81:	ff 24 85 d4 6b 10 80 	jmp    *-0x7fef942c(,%eax,4)
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102d88:	8b 35 20 2d 11 80    	mov    0x80112d20,%esi
80102d8e:	83 fe 07             	cmp    $0x7,%esi
80102d91:	7f 17                	jg     80102daa <mpinit+0x6c>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102d93:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102d97:	69 f6 b0 00 00 00    	imul   $0xb0,%esi,%esi
80102d9d:	88 86 a0 27 11 80    	mov    %al,-0x7feed860(%esi)
        ncpu++;
80102da3:	83 05 20 2d 11 80 01 	addl   $0x1,0x80112d20
      }
      p += sizeof(struct mpproc);
80102daa:	83 c2 14             	add    $0x14,%edx
      continue;
80102dad:	eb 18                	jmp    80102dc7 <mpinit+0x89>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102daf:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102db3:	a2 80 27 11 80       	mov    %al,0x80112780
      p += sizeof(struct mpioapic);
80102db8:	83 c2 08             	add    $0x8,%edx
      continue;
80102dbb:	eb 0a                	jmp    80102dc7 <mpinit+0x89>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102dbd:	83 c2 08             	add    $0x8,%edx
      continue;
80102dc0:	eb 05                	jmp    80102dc7 <mpinit+0x89>
    default:
      ismp = 0;
80102dc2:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102dc7:	39 ca                	cmp    %ecx,%edx
80102dc9:	72 ac                	jb     80102d77 <mpinit+0x39>
      break;
    }
  }
  if(!ismp)
80102dcb:	85 db                	test   %ebx,%ebx
80102dcd:	75 0c                	jne    80102ddb <mpinit+0x9d>
    panic("Didn't find a suitable machine");
80102dcf:	c7 04 24 b4 6b 10 80 	movl   $0x80106bb4,(%esp)
80102dd6:	e8 4a d5 ff ff       	call   80100325 <panic>

  if(mp->imcrp){
80102ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dde:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102de2:	74 12                	je     80102df6 <mpinit+0xb8>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102de4:	ba 22 00 00 00       	mov    $0x22,%edx
80102de9:	b8 70 00 00 00       	mov    $0x70,%eax
80102dee:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102def:	b2 23                	mov    $0x23,%dl
80102df1:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102df2:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102df5:	ee                   	out    %al,(%dx)
  }
}
80102df6:	83 c4 20             	add    $0x20,%esp
80102df9:	5b                   	pop    %ebx
80102dfa:	5e                   	pop    %esi
80102dfb:	5d                   	pop    %ebp
80102dfc:	c3                   	ret    

80102dfd <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102dfd:	55                   	push   %ebp
80102dfe:	89 e5                	mov    %esp,%ebp
80102e00:	ba 21 00 00 00       	mov    $0x21,%edx
80102e05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e0a:	ee                   	out    %al,(%dx)
80102e0b:	b2 a1                	mov    $0xa1,%dl
80102e0d:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102e0e:	5d                   	pop    %ebp
80102e0f:	c3                   	ret    

80102e10 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102e10:	55                   	push   %ebp
80102e11:	89 e5                	mov    %esp,%ebp
80102e13:	57                   	push   %edi
80102e14:	56                   	push   %esi
80102e15:	53                   	push   %ebx
80102e16:	83 ec 1c             	sub    $0x1c,%esp
80102e19:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102e1c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102e1f:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
80102e25:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102e2b:	e8 4c de ff ff       	call   80100c7c <filealloc>
80102e30:	89 03                	mov    %eax,(%ebx)
80102e32:	85 c0                	test   %eax,%eax
80102e34:	0f 84 8b 00 00 00    	je     80102ec5 <pipealloc+0xb5>
80102e3a:	e8 3d de ff ff       	call   80100c7c <filealloc>
80102e3f:	89 07                	mov    %eax,(%edi)
80102e41:	85 c0                	test   %eax,%eax
80102e43:	0f 84 83 00 00 00    	je     80102ecc <pipealloc+0xbc>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102e49:	e8 0b f3 ff ff       	call   80102159 <kalloc>
80102e4e:	89 c6                	mov    %eax,%esi
80102e50:	85 c0                	test   %eax,%eax
80102e52:	74 7d                	je     80102ed1 <pipealloc+0xc1>
    goto bad;
  p->readopen = 1;
80102e54:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102e5b:	00 00 00 
  p->writeopen = 1;
80102e5e:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102e65:	00 00 00 
  p->nwrite = 0;
80102e68:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102e6f:	00 00 00 
  p->nread = 0;
80102e72:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102e79:	00 00 00 
  initlock(&p->lock, "pipe");
80102e7c:	c7 44 24 04 e8 6b 10 	movl   $0x80106be8,0x4(%esp)
80102e83:	80 
80102e84:	89 04 24             	mov    %eax,(%esp)
80102e87:	e8 98 0c 00 00       	call   80103b24 <initlock>
  (*f0)->type = FD_PIPE;
80102e8c:	8b 03                	mov    (%ebx),%eax
80102e8e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102e94:	8b 03                	mov    (%ebx),%eax
80102e96:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102e9a:	8b 03                	mov    (%ebx),%eax
80102e9c:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102ea0:	8b 03                	mov    (%ebx),%eax
80102ea2:	89 70 0c             	mov    %esi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102ea5:	8b 07                	mov    (%edi),%eax
80102ea7:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102ead:	8b 07                	mov    (%edi),%eax
80102eaf:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102eb3:	8b 07                	mov    (%edi),%eax
80102eb5:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102eb9:	8b 07                	mov    (%edi),%eax
80102ebb:	89 70 0c             	mov    %esi,0xc(%eax)
  return 0;
80102ebe:	b8 00 00 00 00       	mov    $0x0,%eax
80102ec3:	eb 40                	jmp    80102f05 <pipealloc+0xf5>
  p = 0;
80102ec5:	be 00 00 00 00       	mov    $0x0,%esi
80102eca:	eb 05                	jmp    80102ed1 <pipealloc+0xc1>
80102ecc:	be 00 00 00 00       	mov    $0x0,%esi

//PAGEBREAK: 20
 bad:
  if(p)
80102ed1:	85 f6                	test   %esi,%esi
80102ed3:	74 08                	je     80102edd <pipealloc+0xcd>
    kfree((char*)p);
80102ed5:	89 34 24             	mov    %esi,(%esp)
80102ed8:	e8 3f f1 ff ff       	call   8010201c <kfree>
  if(*f0)
80102edd:	8b 03                	mov    (%ebx),%eax
80102edf:	85 c0                	test   %eax,%eax
80102ee1:	74 08                	je     80102eeb <pipealloc+0xdb>
    fileclose(*f0);
80102ee3:	89 04 24             	mov    %eax,(%esp)
80102ee6:	e8 2d de ff ff       	call   80100d18 <fileclose>
  if(*f1)
80102eeb:	8b 07                	mov    (%edi),%eax
80102eed:	85 c0                	test   %eax,%eax
80102eef:	74 0f                	je     80102f00 <pipealloc+0xf0>
    fileclose(*f1);
80102ef1:	89 04 24             	mov    %eax,(%esp)
80102ef4:	e8 1f de ff ff       	call   80100d18 <fileclose>
  return -1;
80102ef9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102efe:	eb 05                	jmp    80102f05 <pipealloc+0xf5>
80102f00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102f05:	83 c4 1c             	add    $0x1c,%esp
80102f08:	5b                   	pop    %ebx
80102f09:	5e                   	pop    %esi
80102f0a:	5f                   	pop    %edi
80102f0b:	5d                   	pop    %ebp
80102f0c:	c3                   	ret    

80102f0d <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102f0d:	55                   	push   %ebp
80102f0e:	89 e5                	mov    %esp,%ebp
80102f10:	53                   	push   %ebx
80102f11:	83 ec 14             	sub    $0x14,%esp
80102f14:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102f17:	89 1c 24             	mov    %ebx,(%esp)
80102f1a:	e8 3d 0d 00 00       	call   80103c5c <acquire>
  if(writable){
80102f1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102f23:	74 1a                	je     80102f3f <pipeclose+0x32>
    p->writeopen = 0;
80102f25:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102f2c:	00 00 00 
    wakeup(&p->nread);
80102f2f:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f35:	89 04 24             	mov    %eax,(%esp)
80102f38:	e8 83 09 00 00       	call   801038c0 <wakeup>
80102f3d:	eb 18                	jmp    80102f57 <pipeclose+0x4a>
  } else {
    p->readopen = 0;
80102f3f:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102f46:	00 00 00 
    wakeup(&p->nwrite);
80102f49:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f4f:	89 04 24             	mov    %eax,(%esp)
80102f52:	e8 69 09 00 00       	call   801038c0 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102f57:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102f5e:	75 1b                	jne    80102f7b <pipeclose+0x6e>
80102f60:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102f67:	75 12                	jne    80102f7b <pipeclose+0x6e>
    release(&p->lock);
80102f69:	89 1c 24             	mov    %ebx,(%esp)
80102f6c:	e8 4c 0d 00 00       	call   80103cbd <release>
    kfree((char*)p);
80102f71:	89 1c 24             	mov    %ebx,(%esp)
80102f74:	e8 a3 f0 ff ff       	call   8010201c <kfree>
80102f79:	eb 08                	jmp    80102f83 <pipeclose+0x76>
  } else
    release(&p->lock);
80102f7b:	89 1c 24             	mov    %ebx,(%esp)
80102f7e:	e8 3a 0d 00 00       	call   80103cbd <release>
}
80102f83:	83 c4 14             	add    $0x14,%esp
80102f86:	5b                   	pop    %ebx
80102f87:	5d                   	pop    %ebp
80102f88:	c3                   	ret    

80102f89 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80102f89:	55                   	push   %ebp
80102f8a:	89 e5                	mov    %esp,%ebp
80102f8c:	57                   	push   %edi
80102f8d:	56                   	push   %esi
80102f8e:	53                   	push   %ebx
80102f8f:	83 ec 1c             	sub    $0x1c,%esp
80102f92:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102f95:	89 df                	mov    %ebx,%edi
80102f97:	89 1c 24             	mov    %ebx,(%esp)
80102f9a:	e8 bd 0c 00 00       	call   80103c5c <acquire>
  for(i = 0; i < n; i++){
80102f9f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80102fa6:	8d b3 34 02 00 00    	lea    0x234(%ebx),%esi
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102fac:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102fb2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(i = 0; i < n; i++){
80102fb5:	eb 70                	jmp    80103027 <pipewrite+0x9e>
      if(p->readopen == 0 || myproc()->killed){
80102fb7:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102fbe:	74 0b                	je     80102fcb <pipewrite+0x42>
80102fc0:	e8 00 03 00 00       	call   801032c5 <myproc>
80102fc5:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102fc9:	74 0f                	je     80102fda <pipewrite+0x51>
        release(&p->lock);
80102fcb:	89 1c 24             	mov    %ebx,(%esp)
80102fce:	e8 ea 0c 00 00       	call   80103cbd <release>
        return -1;
80102fd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102fd8:	eb 6e                	jmp    80103048 <pipewrite+0xbf>
      wakeup(&p->nread);
80102fda:	89 34 24             	mov    %esi,(%esp)
80102fdd:	e8 de 08 00 00       	call   801038c0 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102fe2:	89 7c 24 04          	mov    %edi,0x4(%esp)
80102fe6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102fe9:	89 04 24             	mov    %eax,(%esp)
80102fec:	e8 7a 07 00 00       	call   8010376b <sleep>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80102ff1:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80102ff7:	8b 8b 34 02 00 00    	mov    0x234(%ebx),%ecx
80102ffd:	8d 91 00 02 00 00    	lea    0x200(%ecx),%edx
80103003:	39 d0                	cmp    %edx,%eax
80103005:	74 b0                	je     80102fb7 <pipewrite+0x2e>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103007:	8d 50 01             	lea    0x1(%eax),%edx
8010300a:	89 93 38 02 00 00    	mov    %edx,0x238(%ebx)
80103010:	25 ff 01 00 00       	and    $0x1ff,%eax
80103015:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103018:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010301b:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
8010301f:	88 54 03 34          	mov    %dl,0x34(%ebx,%eax,1)
  for(i = 0; i < n; i++){
80103023:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80103027:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010302a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010302d:	7c c2                	jl     80102ff1 <pipewrite+0x68>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010302f:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103035:	89 04 24             	mov    %eax,(%esp)
80103038:	e8 83 08 00 00       	call   801038c0 <wakeup>
  release(&p->lock);
8010303d:	89 1c 24             	mov    %ebx,(%esp)
80103040:	e8 78 0c 00 00       	call   80103cbd <release>
  return n;
80103045:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103048:	83 c4 1c             	add    $0x1c,%esp
8010304b:	5b                   	pop    %ebx
8010304c:	5e                   	pop    %esi
8010304d:	5f                   	pop    %edi
8010304e:	5d                   	pop    %ebp
8010304f:	c3                   	ret    

80103050 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103050:	55                   	push   %ebp
80103051:	89 e5                	mov    %esp,%ebp
80103053:	57                   	push   %edi
80103054:	56                   	push   %esi
80103055:	53                   	push   %ebx
80103056:	83 ec 1c             	sub    $0x1c,%esp
80103059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
8010305c:	89 df                	mov    %ebx,%edi
8010305e:	89 1c 24             	mov    %ebx,(%esp)
80103061:	e8 f6 0b 00 00       	call   80103c5c <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
    if(myproc()->killed){
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103066:	8d b3 34 02 00 00    	lea    0x234(%ebx),%esi
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010306c:	eb 26                	jmp    80103094 <piperead+0x44>
    if(myproc()->killed){
8010306e:	e8 52 02 00 00       	call   801032c5 <myproc>
80103073:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80103077:	74 0f                	je     80103088 <piperead+0x38>
      release(&p->lock);
80103079:	89 1c 24             	mov    %ebx,(%esp)
8010307c:	e8 3c 0c 00 00       	call   80103cbd <release>
      return -1;
80103081:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103086:	eb 78                	jmp    80103100 <piperead+0xb0>
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103088:	89 7c 24 04          	mov    %edi,0x4(%esp)
8010308c:	89 34 24             	mov    %esi,(%esp)
8010308f:	e8 d7 06 00 00       	call   8010376b <sleep>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103094:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
8010309a:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
801030a0:	75 3c                	jne    801030de <piperead+0x8e>
801030a2:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
801030a9:	75 c3                	jne    8010306e <piperead+0x1e>
801030ab:	be 00 00 00 00       	mov    $0x0,%esi
801030b0:	eb 31                	jmp    801030e3 <piperead+0x93>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(p->nread == p->nwrite)
801030b2:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
801030b8:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
801030be:	74 28                	je     801030e8 <piperead+0x98>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801030c0:	8d 50 01             	lea    0x1(%eax),%edx
801030c3:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
801030c9:	25 ff 01 00 00       	and    $0x1ff,%eax
801030ce:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
801030d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801030d6:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801030d9:	83 c6 01             	add    $0x1,%esi
801030dc:	eb 05                	jmp    801030e3 <piperead+0x93>
801030de:	be 00 00 00 00       	mov    $0x0,%esi
801030e3:	3b 75 10             	cmp    0x10(%ebp),%esi
801030e6:	7c ca                	jl     801030b2 <piperead+0x62>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801030e8:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
801030ee:	89 04 24             	mov    %eax,(%esp)
801030f1:	e8 ca 07 00 00       	call   801038c0 <wakeup>
  release(&p->lock);
801030f6:	89 1c 24             	mov    %ebx,(%esp)
801030f9:	e8 bf 0b 00 00       	call   80103cbd <release>
  return i;
801030fe:	89 f0                	mov    %esi,%eax
}
80103100:	83 c4 1c             	add    $0x1c,%esp
80103103:	5b                   	pop    %ebx
80103104:	5e                   	pop    %esi
80103105:	5f                   	pop    %edi
80103106:	5d                   	pop    %ebp
80103107:	c3                   	ret    
80103108:	66 90                	xchg   %ax,%ax
8010310a:	66 90                	xchg   %ax,%ax
8010310c:	66 90                	xchg   %ax,%ax
8010310e:	66 90                	xchg   %ax,%ax

80103110 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80103110:	55                   	push   %ebp
80103111:	89 e5                	mov    %esp,%ebp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103113:	ba 74 2d 11 80       	mov    $0x80112d74,%edx
80103118:	eb 15                	jmp    8010312f <wakeup1+0x1f>
    if(p->state == SLEEPING && p->chan == chan)
8010311a:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
8010311e:	75 0c                	jne    8010312c <wakeup1+0x1c>
80103120:	39 42 20             	cmp    %eax,0x20(%edx)
80103123:	75 07                	jne    8010312c <wakeup1+0x1c>
      p->state = RUNNABLE;
80103125:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010312c:	83 c2 7c             	add    $0x7c,%edx
8010312f:	81 fa 74 4c 11 80    	cmp    $0x80114c74,%edx
80103135:	72 e3                	jb     8010311a <wakeup1+0xa>
}
80103137:	5d                   	pop    %ebp
80103138:	c3                   	ret    

80103139 <allocproc>:
{
80103139:	55                   	push   %ebp
8010313a:	89 e5                	mov    %esp,%ebp
8010313c:	53                   	push   %ebx
8010313d:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80103140:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103147:	e8 10 0b 00 00       	call   80103c5c <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010314c:	bb 74 2d 11 80       	mov    $0x80112d74,%ebx
80103151:	eb 09                	jmp    8010315c <allocproc+0x23>
    if(p->state == UNUSED)
80103153:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
80103157:	74 1e                	je     80103177 <allocproc+0x3e>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103159:	83 c3 7c             	add    $0x7c,%ebx
8010315c:	81 fb 74 4c 11 80    	cmp    $0x80114c74,%ebx
80103162:	72 ef                	jb     80103153 <allocproc+0x1a>
  release(&ptable.lock);
80103164:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
8010316b:	e8 4d 0b 00 00       	call   80103cbd <release>
  return 0;
80103170:	b8 00 00 00 00       	mov    $0x0,%eax
80103175:	eb 78                	jmp    801031ef <allocproc+0xb6>
  p->state = EMBRYO;
80103177:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
8010317e:	a1 04 a0 10 80       	mov    0x8010a004,%eax
80103183:	8d 50 01             	lea    0x1(%eax),%edx
80103186:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
8010318c:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
8010318f:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103196:	e8 22 0b 00 00       	call   80103cbd <release>
  if((p->kstack = kalloc()) == 0){
8010319b:	e8 b9 ef ff ff       	call   80102159 <kalloc>
801031a0:	89 43 08             	mov    %eax,0x8(%ebx)
801031a3:	85 c0                	test   %eax,%eax
801031a5:	75 09                	jne    801031b0 <allocproc+0x77>
    p->state = UNUSED;
801031a7:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801031ae:	eb 3f                	jmp    801031ef <allocproc+0xb6>
  sp -= sizeof *p->tf;
801031b0:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
801031b6:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
801031b9:	c7 80 b0 0f 00 00 1d 	movl   $0x80104e1d,0xfb0(%eax)
801031c0:	4e 10 80 
  sp -= sizeof *p->context;
801031c3:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
801031c8:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
801031cb:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801031d2:	00 
801031d3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031da:	00 
801031db:	89 04 24             	mov    %eax,(%esp)
801031de:	e8 2d 0b 00 00       	call   80103d10 <memset>
  p->context->eip = (uint)forkret;
801031e3:	8b 43 1c             	mov    0x1c(%ebx),%eax
801031e6:	c7 40 10 f5 31 10 80 	movl   $0x801031f5,0x10(%eax)
  return p;
801031ed:	89 d8                	mov    %ebx,%eax
}
801031ef:	83 c4 14             	add    $0x14,%esp
801031f2:	5b                   	pop    %ebx
801031f3:	5d                   	pop    %ebp
801031f4:	c3                   	ret    

801031f5 <forkret>:
{
801031f5:	55                   	push   %ebp
801031f6:	89 e5                	mov    %esp,%ebp
801031f8:	83 ec 18             	sub    $0x18,%esp
  release(&ptable.lock);
801031fb:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103202:	e8 b6 0a 00 00       	call   80103cbd <release>
  if (first) {
80103207:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
8010320e:	74 22                	je     80103232 <forkret+0x3d>
    first = 0;
80103210:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
80103217:	00 00 00 
    iinit(ROOTDEV);
8010321a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103221:	e8 2d e1 ff ff       	call   80101353 <iinit>
    initlog(ROOTDEV);
80103226:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010322d:	e8 d3 f5 ff ff       	call   80102805 <initlog>
}
80103232:	c9                   	leave  
80103233:	c3                   	ret    

80103234 <pinit>:
{
80103234:	55                   	push   %ebp
80103235:	89 e5                	mov    %esp,%ebp
80103237:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
8010323a:	c7 44 24 04 ed 6b 10 	movl   $0x80106bed,0x4(%esp)
80103241:	80 
80103242:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103249:	e8 d6 08 00 00       	call   80103b24 <initlock>
}
8010324e:	c9                   	leave  
8010324f:	c3                   	ret    

80103250 <mycpu>:
{
80103250:	55                   	push   %ebp
80103251:	89 e5                	mov    %esp,%ebp
80103253:	83 ec 18             	sub    $0x18,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103256:	9c                   	pushf  
80103257:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103258:	f6 c4 02             	test   $0x2,%ah
8010325b:	74 0c                	je     80103269 <mycpu+0x19>
    panic("mycpu called with interrupts enabled\n");
8010325d:	c7 04 24 d0 6c 10 80 	movl   $0x80106cd0,(%esp)
80103264:	e8 bc d0 ff ff       	call   80100325 <panic>
  apicid = lapicid();
80103269:	e8 aa f1 ff ff       	call   80102418 <lapicid>
  for (i = 0; i < ncpu; ++i) {
8010326e:	ba 00 00 00 00       	mov    $0x0,%edx
80103273:	eb 14                	jmp    80103289 <mycpu+0x39>
    if (cpus[i].apicid == apicid)
80103275:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
8010327b:	0f b6 89 a0 27 11 80 	movzbl -0x7feed860(%ecx),%ecx
80103282:	39 c1                	cmp    %eax,%ecx
80103284:	74 17                	je     8010329d <mycpu+0x4d>
  for (i = 0; i < ncpu; ++i) {
80103286:	83 c2 01             	add    $0x1,%edx
80103289:	3b 15 20 2d 11 80    	cmp    0x80112d20,%edx
8010328f:	7c e4                	jl     80103275 <mycpu+0x25>
  panic("unknown apicid\n");
80103291:	c7 04 24 f4 6b 10 80 	movl   $0x80106bf4,(%esp)
80103298:	e8 88 d0 ff ff       	call   80100325 <panic>
      return &cpus[i];
8010329d:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
801032a3:	05 a0 27 11 80       	add    $0x801127a0,%eax
}
801032a8:	c9                   	leave  
801032a9:	c3                   	ret    

801032aa <cpuid>:
cpuid() {
801032aa:	55                   	push   %ebp
801032ab:	89 e5                	mov    %esp,%ebp
801032ad:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801032b0:	e8 9b ff ff ff       	call   80103250 <mycpu>
801032b5:	2d a0 27 11 80       	sub    $0x801127a0,%eax
801032ba:	c1 f8 04             	sar    $0x4,%eax
801032bd:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801032c3:	c9                   	leave  
801032c4:	c3                   	ret    

801032c5 <myproc>:
myproc(void) {
801032c5:	55                   	push   %ebp
801032c6:	89 e5                	mov    %esp,%ebp
801032c8:	53                   	push   %ebx
801032c9:	83 ec 04             	sub    $0x4,%esp
  pushcli();
801032cc:	e8 b4 08 00 00       	call   80103b85 <pushcli>
  c = mycpu();
801032d1:	e8 7a ff ff ff       	call   80103250 <mycpu>
  p = c->proc;
801032d6:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801032dc:	e8 df 08 00 00       	call   80103bc0 <popcli>
}
801032e1:	89 d8                	mov    %ebx,%eax
801032e3:	83 c4 04             	add    $0x4,%esp
801032e6:	5b                   	pop    %ebx
801032e7:	5d                   	pop    %ebp
801032e8:	c3                   	ret    

801032e9 <userinit>:
{
801032e9:	55                   	push   %ebp
801032ea:	89 e5                	mov    %esp,%ebp
801032ec:	53                   	push   %ebx
801032ed:	83 ec 14             	sub    $0x14,%esp
  p = allocproc();
801032f0:	e8 44 fe ff ff       	call   80103139 <allocproc>
801032f5:	89 c3                	mov    %eax,%ebx
  initproc = p;
801032f7:	a3 b8 a5 10 80       	mov    %eax,0x8010a5b8
  if((p->pgdir = setupkvm()) == 0)
801032fc:	e8 32 30 00 00       	call   80106333 <setupkvm>
80103301:	89 43 04             	mov    %eax,0x4(%ebx)
80103304:	85 c0                	test   %eax,%eax
80103306:	75 0c                	jne    80103314 <userinit+0x2b>
    panic("userinit: out of memory?");
80103308:	c7 04 24 04 6c 10 80 	movl   $0x80106c04,(%esp)
8010330f:	e8 11 d0 ff ff       	call   80100325 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103314:	c7 44 24 08 2c 00 00 	movl   $0x2c,0x8(%esp)
8010331b:	00 
8010331c:	c7 44 24 04 60 a4 10 	movl   $0x8010a460,0x4(%esp)
80103323:	80 
80103324:	89 04 24             	mov    %eax,(%esp)
80103327:	e8 8c 2c 00 00       	call   80105fb8 <inituvm>
  p->sz = PGSIZE;
8010332c:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103332:	8b 43 18             	mov    0x18(%ebx),%eax
80103335:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
8010333c:	00 
8010333d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103344:	00 
80103345:	89 04 24             	mov    %eax,(%esp)
80103348:	e8 c3 09 00 00       	call   80103d10 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010334d:	8b 43 18             	mov    0x18(%ebx),%eax
80103350:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103356:	8b 43 18             	mov    0x18(%ebx),%eax
80103359:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010335f:	8b 43 18             	mov    0x18(%ebx),%eax
80103362:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103366:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010336a:	8b 43 18             	mov    0x18(%ebx),%eax
8010336d:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103371:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103375:	8b 43 18             	mov    0x18(%ebx),%eax
80103378:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010337f:	8b 43 18             	mov    0x18(%ebx),%eax
80103382:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103389:	8b 43 18             	mov    0x18(%ebx),%eax
8010338c:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103393:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103396:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010339d:	00 
8010339e:	c7 44 24 04 1d 6c 10 	movl   $0x80106c1d,0x4(%esp)
801033a5:	80 
801033a6:	89 04 24             	mov    %eax,(%esp)
801033a9:	e8 d9 0a 00 00       	call   80103e87 <safestrcpy>
  p->cwd = namei("/");
801033ae:	c7 04 24 26 6c 10 80 	movl   $0x80106c26,(%esp)
801033b5:	e8 c8 e8 ff ff       	call   80101c82 <namei>
801033ba:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
801033bd:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
801033c4:	e8 93 08 00 00       	call   80103c5c <acquire>
  p->state = RUNNABLE;
801033c9:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
801033d0:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
801033d7:	e8 e1 08 00 00       	call   80103cbd <release>
}
801033dc:	83 c4 14             	add    $0x14,%esp
801033df:	5b                   	pop    %ebx
801033e0:	5d                   	pop    %ebp
801033e1:	c3                   	ret    

801033e2 <growproc>:
{
801033e2:	55                   	push   %ebp
801033e3:	89 e5                	mov    %esp,%ebp
801033e5:	56                   	push   %esi
801033e6:	53                   	push   %ebx
801033e7:	83 ec 10             	sub    $0x10,%esp
801033ea:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
801033ed:	e8 d3 fe ff ff       	call   801032c5 <myproc>
801033f2:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
801033f4:	8b 00                	mov    (%eax),%eax
  if(n > 0){
801033f6:	85 f6                	test   %esi,%esi
801033f8:	7e 1b                	jle    80103415 <growproc+0x33>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801033fa:	01 c6                	add    %eax,%esi
801033fc:	89 74 24 08          	mov    %esi,0x8(%esp)
80103400:	89 44 24 04          	mov    %eax,0x4(%esp)
80103404:	8b 43 04             	mov    0x4(%ebx),%eax
80103407:	89 04 24             	mov    %eax,(%esp)
8010340a:	e8 98 2d 00 00       	call   801061a7 <allocuvm>
8010340f:	85 c0                	test   %eax,%eax
80103411:	75 1f                	jne    80103432 <growproc+0x50>
80103413:	eb 2e                	jmp    80103443 <growproc+0x61>
  } else if(n < 0){
80103415:	85 f6                	test   %esi,%esi
80103417:	79 19                	jns    80103432 <growproc+0x50>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103419:	01 c6                	add    %eax,%esi
8010341b:	89 74 24 08          	mov    %esi,0x8(%esp)
8010341f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103423:	8b 43 04             	mov    0x4(%ebx),%eax
80103426:	89 04 24             	mov    %eax,(%esp)
80103429:	e8 d9 2c 00 00       	call   80106107 <deallocuvm>
8010342e:	85 c0                	test   %eax,%eax
80103430:	74 18                	je     8010344a <growproc+0x68>
  curproc->sz = sz;
80103432:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103434:	89 1c 24             	mov    %ebx,(%esp)
80103437:	e8 7b 2a 00 00       	call   80105eb7 <switchuvm>
  return 0;
8010343c:	b8 00 00 00 00       	mov    $0x0,%eax
80103441:	eb 0c                	jmp    8010344f <growproc+0x6d>
      return -1;
80103443:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103448:	eb 05                	jmp    8010344f <growproc+0x6d>
      return -1;
8010344a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010344f:	83 c4 10             	add    $0x10,%esp
80103452:	5b                   	pop    %ebx
80103453:	5e                   	pop    %esi
80103454:	5d                   	pop    %ebp
80103455:	c3                   	ret    

80103456 <fork>:
{
80103456:	55                   	push   %ebp
80103457:	89 e5                	mov    %esp,%ebp
80103459:	57                   	push   %edi
8010345a:	56                   	push   %esi
8010345b:	53                   	push   %ebx
8010345c:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
8010345f:	e8 61 fe ff ff       	call   801032c5 <myproc>
80103464:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
80103466:	e8 ce fc ff ff       	call   80103139 <allocproc>
8010346b:	89 c7                	mov    %eax,%edi
8010346d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103470:	85 c0                	test   %eax,%eax
80103472:	0f 84 d8 00 00 00    	je     80103550 <fork+0xfa>
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103478:	8b 03                	mov    (%ebx),%eax
8010347a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010347e:	8b 43 04             	mov    0x4(%ebx),%eax
80103481:	89 04 24             	mov    %eax,(%esp)
80103484:	e8 67 2f 00 00       	call   801063f0 <copyuvm>
80103489:	89 47 04             	mov    %eax,0x4(%edi)
8010348c:	85 c0                	test   %eax,%eax
8010348e:	75 26                	jne    801034b6 <fork+0x60>
    kfree(np->kstack);
80103490:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80103493:	8b 47 08             	mov    0x8(%edi),%eax
80103496:	89 04 24             	mov    %eax,(%esp)
80103499:	e8 7e eb ff ff       	call   8010201c <kfree>
    np->kstack = 0;
8010349e:	c7 47 08 00 00 00 00 	movl   $0x0,0x8(%edi)
    np->state = UNUSED;
801034a5:	c7 47 0c 00 00 00 00 	movl   $0x0,0xc(%edi)
    return -1;
801034ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801034b1:	e9 9f 00 00 00       	jmp    80103555 <fork+0xff>
  np->sz = curproc->sz;
801034b6:	8b 03                	mov    (%ebx),%eax
801034b8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801034bb:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
801034bd:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
801034c0:	89 c8                	mov    %ecx,%eax
801034c2:	8b 79 18             	mov    0x18(%ecx),%edi
801034c5:	8b 73 18             	mov    0x18(%ebx),%esi
801034c8:	b9 13 00 00 00       	mov    $0x13,%ecx
801034cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
801034cf:	8b 40 18             	mov    0x18(%eax),%eax
801034d2:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
801034d9:	be 00 00 00 00       	mov    $0x0,%esi
801034de:	eb 1a                	jmp    801034fa <fork+0xa4>
    if(curproc->ofile[i])
801034e0:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
801034e4:	85 c0                	test   %eax,%eax
801034e6:	74 0f                	je     801034f7 <fork+0xa1>
      np->ofile[i] = filedup(curproc->ofile[i]);
801034e8:	89 04 24             	mov    %eax,(%esp)
801034eb:	e8 e5 d7 ff ff       	call   80100cd5 <filedup>
801034f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801034f3:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
  for(i = 0; i < NOFILE; i++)
801034f7:	83 c6 01             	add    $0x1,%esi
801034fa:	83 fe 0f             	cmp    $0xf,%esi
801034fd:	7e e1                	jle    801034e0 <fork+0x8a>
  np->cwd = idup(curproc->cwd);
801034ff:	8b 43 68             	mov    0x68(%ebx),%eax
80103502:	89 04 24             	mov    %eax,(%esp)
80103505:	e8 c9 e0 ff ff       	call   801015d3 <idup>
8010350a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010350d:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103510:	83 c3 6c             	add    $0x6c,%ebx
80103513:	8d 47 6c             	lea    0x6c(%edi),%eax
80103516:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010351d:	00 
8010351e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80103522:	89 04 24             	mov    %eax,(%esp)
80103525:	e8 5d 09 00 00       	call   80103e87 <safestrcpy>
  pid = np->pid;
8010352a:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
8010352d:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103534:	e8 23 07 00 00       	call   80103c5c <acquire>
  np->state = RUNNABLE;
80103539:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
80103540:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103547:	e8 71 07 00 00       	call   80103cbd <release>
  return pid;
8010354c:	89 d8                	mov    %ebx,%eax
8010354e:	eb 05                	jmp    80103555 <fork+0xff>
    return -1;
80103550:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103555:	83 c4 1c             	add    $0x1c,%esp
80103558:	5b                   	pop    %ebx
80103559:	5e                   	pop    %esi
8010355a:	5f                   	pop    %edi
8010355b:	5d                   	pop    %ebp
8010355c:	c3                   	ret    

8010355d <scheduler>:
{
8010355d:	55                   	push   %ebp
8010355e:	89 e5                	mov    %esp,%ebp
80103560:	57                   	push   %edi
80103561:	56                   	push   %esi
80103562:	53                   	push   %ebx
80103563:	83 ec 1c             	sub    $0x1c,%esp
  struct cpu *c = mycpu();
80103566:	e8 e5 fc ff ff       	call   80103250 <mycpu>
8010356b:	89 c6                	mov    %eax,%esi
  c->proc = 0;
8010356d:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103574:	00 00 00 
      swtch(&(c->scheduler), p->context);
80103577:	8d 78 04             	lea    0x4(%eax),%edi
  asm volatile("sti");
8010357a:	fb                   	sti    
    acquire(&ptable.lock);
8010357b:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103582:	e8 d5 06 00 00       	call   80103c5c <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103587:	bb 74 2d 11 80       	mov    $0x80112d74,%ebx
8010358c:	eb 3c                	jmp    801035ca <scheduler+0x6d>
      if(p->state != RUNNABLE)
8010358e:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103592:	75 33                	jne    801035c7 <scheduler+0x6a>
      c->proc = p;
80103594:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
8010359a:	89 1c 24             	mov    %ebx,(%esp)
8010359d:	e8 15 29 00 00       	call   80105eb7 <switchuvm>
      p->state = RUNNING;
801035a2:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
801035a9:	8b 43 1c             	mov    0x1c(%ebx),%eax
801035ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801035b0:	89 3c 24             	mov    %edi,(%esp)
801035b3:	e8 22 09 00 00       	call   80103eda <swtch>
      switchkvm();
801035b8:	e8 d3 28 00 00       	call   80105e90 <switchkvm>
      c->proc = 0;
801035bd:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
801035c4:	00 00 00 
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801035c7:	83 c3 7c             	add    $0x7c,%ebx
801035ca:	81 fb 74 4c 11 80    	cmp    $0x80114c74,%ebx
801035d0:	72 bc                	jb     8010358e <scheduler+0x31>
    release(&ptable.lock);
801035d2:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
801035d9:	e8 df 06 00 00       	call   80103cbd <release>
  }
801035de:	eb 9a                	jmp    8010357a <scheduler+0x1d>

801035e0 <sched>:
{
801035e0:	55                   	push   %ebp
801035e1:	89 e5                	mov    %esp,%ebp
801035e3:	56                   	push   %esi
801035e4:	53                   	push   %ebx
801035e5:	83 ec 10             	sub    $0x10,%esp
  struct proc *p = myproc();
801035e8:	e8 d8 fc ff ff       	call   801032c5 <myproc>
801035ed:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
801035ef:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
801035f6:	e8 21 06 00 00       	call   80103c1c <holding>
801035fb:	85 c0                	test   %eax,%eax
801035fd:	75 0c                	jne    8010360b <sched+0x2b>
    panic("sched ptable.lock");
801035ff:	c7 04 24 28 6c 10 80 	movl   $0x80106c28,(%esp)
80103606:	e8 1a cd ff ff       	call   80100325 <panic>
  if(mycpu()->ncli != 1)
8010360b:	e8 40 fc ff ff       	call   80103250 <mycpu>
80103610:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103617:	74 0c                	je     80103625 <sched+0x45>
    panic("sched locks");
80103619:	c7 04 24 3a 6c 10 80 	movl   $0x80106c3a,(%esp)
80103620:	e8 00 cd ff ff       	call   80100325 <panic>
  if(p->state == RUNNING)
80103625:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103629:	75 0c                	jne    80103637 <sched+0x57>
    panic("sched running");
8010362b:	c7 04 24 46 6c 10 80 	movl   $0x80106c46,(%esp)
80103632:	e8 ee cc ff ff       	call   80100325 <panic>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103637:	9c                   	pushf  
80103638:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103639:	f6 c4 02             	test   $0x2,%ah
8010363c:	74 0c                	je     8010364a <sched+0x6a>
    panic("sched interruptible");
8010363e:	c7 04 24 54 6c 10 80 	movl   $0x80106c54,(%esp)
80103645:	e8 db cc ff ff       	call   80100325 <panic>
  intena = mycpu()->intena;
8010364a:	e8 01 fc ff ff       	call   80103250 <mycpu>
8010364f:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103655:	e8 f6 fb ff ff       	call   80103250 <mycpu>
8010365a:	8b 40 04             	mov    0x4(%eax),%eax
8010365d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103661:	83 c3 1c             	add    $0x1c,%ebx
80103664:	89 1c 24             	mov    %ebx,(%esp)
80103667:	e8 6e 08 00 00       	call   80103eda <swtch>
  mycpu()->intena = intena;
8010366c:	e8 df fb ff ff       	call   80103250 <mycpu>
80103671:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103677:	83 c4 10             	add    $0x10,%esp
8010367a:	5b                   	pop    %ebx
8010367b:	5e                   	pop    %esi
8010367c:	5d                   	pop    %ebp
8010367d:	c3                   	ret    

8010367e <exit>:
{
8010367e:	55                   	push   %ebp
8010367f:	89 e5                	mov    %esp,%ebp
80103681:	56                   	push   %esi
80103682:	53                   	push   %ebx
80103683:	83 ec 10             	sub    $0x10,%esp
  struct proc *curproc = myproc();
80103686:	e8 3a fc ff ff       	call   801032c5 <myproc>
8010368b:	89 c6                	mov    %eax,%esi
  if(curproc == initproc)
8010368d:	3b 05 b8 a5 10 80    	cmp    0x8010a5b8,%eax
80103693:	75 29                	jne    801036be <exit+0x40>
    panic("init exiting");
80103695:	c7 04 24 68 6c 10 80 	movl   $0x80106c68,(%esp)
8010369c:	e8 84 cc ff ff       	call   80100325 <panic>
    if(curproc->ofile[fd]){
801036a1:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
801036a5:	85 c0                	test   %eax,%eax
801036a7:	74 10                	je     801036b9 <exit+0x3b>
      fileclose(curproc->ofile[fd]);
801036a9:	89 04 24             	mov    %eax,(%esp)
801036ac:	e8 67 d6 ff ff       	call   80100d18 <fileclose>
      curproc->ofile[fd] = 0;
801036b1:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
801036b8:	00 
  for(fd = 0; fd < NOFILE; fd++){
801036b9:	83 c3 01             	add    $0x1,%ebx
801036bc:	eb 05                	jmp    801036c3 <exit+0x45>
801036be:	bb 00 00 00 00       	mov    $0x0,%ebx
801036c3:	83 fb 0f             	cmp    $0xf,%ebx
801036c6:	7e d9                	jle    801036a1 <exit+0x23>
  begin_op();
801036c8:	e8 86 f1 ff ff       	call   80102853 <begin_op>
  iput(curproc->cwd);
801036cd:	8b 46 68             	mov    0x68(%esi),%eax
801036d0:	89 04 24             	mov    %eax,(%esp)
801036d3:	e8 2f e0 ff ff       	call   80101707 <iput>
  end_op();
801036d8:	e8 e9 f1 ff ff       	call   801028c6 <end_op>
  curproc->cwd = 0;
801036dd:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
801036e4:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
801036eb:	e8 6c 05 00 00       	call   80103c5c <acquire>
  wakeup1(curproc->parent);
801036f0:	8b 46 14             	mov    0x14(%esi),%eax
801036f3:	e8 18 fa ff ff       	call   80103110 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801036f8:	bb 74 2d 11 80       	mov    $0x80112d74,%ebx
801036fd:	eb 1b                	jmp    8010371a <exit+0x9c>
    if(p->parent == curproc){
801036ff:	39 73 14             	cmp    %esi,0x14(%ebx)
80103702:	75 13                	jne    80103717 <exit+0x99>
      p->parent = initproc;
80103704:	a1 b8 a5 10 80       	mov    0x8010a5b8,%eax
80103709:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
8010370c:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103710:	75 05                	jne    80103717 <exit+0x99>
        wakeup1(initproc);
80103712:	e8 f9 f9 ff ff       	call   80103110 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103717:	83 c3 7c             	add    $0x7c,%ebx
8010371a:	81 fb 74 4c 11 80    	cmp    $0x80114c74,%ebx
80103720:	72 dd                	jb     801036ff <exit+0x81>
  curproc->state = ZOMBIE;
80103722:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
80103729:	e8 b2 fe ff ff       	call   801035e0 <sched>
  panic("zombie exit");
8010372e:	c7 04 24 75 6c 10 80 	movl   $0x80106c75,(%esp)
80103735:	e8 eb cb ff ff       	call   80100325 <panic>

8010373a <yield>:
{
8010373a:	55                   	push   %ebp
8010373b:	89 e5                	mov    %esp,%ebp
8010373d:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80103740:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103747:	e8 10 05 00 00       	call   80103c5c <acquire>
  myproc()->state = RUNNABLE;
8010374c:	e8 74 fb ff ff       	call   801032c5 <myproc>
80103751:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80103758:	e8 83 fe ff ff       	call   801035e0 <sched>
  release(&ptable.lock);
8010375d:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103764:	e8 54 05 00 00       	call   80103cbd <release>
}
80103769:	c9                   	leave  
8010376a:	c3                   	ret    

8010376b <sleep>:
{
8010376b:	55                   	push   %ebp
8010376c:	89 e5                	mov    %esp,%ebp
8010376e:	56                   	push   %esi
8010376f:	53                   	push   %ebx
80103770:	83 ec 10             	sub    $0x10,%esp
80103773:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
80103776:	e8 4a fb ff ff       	call   801032c5 <myproc>
8010377b:	89 c6                	mov    %eax,%esi
  if(p == 0)
8010377d:	85 c0                	test   %eax,%eax
8010377f:	75 0c                	jne    8010378d <sleep+0x22>
    panic("sleep");
80103781:	c7 04 24 81 6c 10 80 	movl   $0x80106c81,(%esp)
80103788:	e8 98 cb ff ff       	call   80100325 <panic>
  if(lk == 0)
8010378d:	85 db                	test   %ebx,%ebx
8010378f:	75 0c                	jne    8010379d <sleep+0x32>
    panic("sleep without lk");
80103791:	c7 04 24 87 6c 10 80 	movl   $0x80106c87,(%esp)
80103798:	e8 88 cb ff ff       	call   80100325 <panic>
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010379d:	81 fb 40 2d 11 80    	cmp    $0x80112d40,%ebx
801037a3:	74 14                	je     801037b9 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
801037a5:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
801037ac:	e8 ab 04 00 00       	call   80103c5c <acquire>
    release(lk);
801037b1:	89 1c 24             	mov    %ebx,(%esp)
801037b4:	e8 04 05 00 00       	call   80103cbd <release>
  p->chan = chan;
801037b9:	8b 45 08             	mov    0x8(%ebp),%eax
801037bc:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
801037bf:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
801037c6:	e8 15 fe ff ff       	call   801035e0 <sched>
  p->chan = 0;
801037cb:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
801037d2:	81 fb 40 2d 11 80    	cmp    $0x80112d40,%ebx
801037d8:	74 14                	je     801037ee <sleep+0x83>
    release(&ptable.lock);
801037da:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
801037e1:	e8 d7 04 00 00       	call   80103cbd <release>
    acquire(lk);
801037e6:	89 1c 24             	mov    %ebx,(%esp)
801037e9:	e8 6e 04 00 00       	call   80103c5c <acquire>
}
801037ee:	83 c4 10             	add    $0x10,%esp
801037f1:	5b                   	pop    %ebx
801037f2:	5e                   	pop    %esi
801037f3:	5d                   	pop    %ebp
801037f4:	c3                   	ret    

801037f5 <wait>:
{
801037f5:	55                   	push   %ebp
801037f6:	89 e5                	mov    %esp,%ebp
801037f8:	56                   	push   %esi
801037f9:	53                   	push   %ebx
801037fa:	83 ec 10             	sub    $0x10,%esp
  struct proc *curproc = myproc();
801037fd:	e8 c3 fa ff ff       	call   801032c5 <myproc>
80103802:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80103804:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
8010380b:	e8 4c 04 00 00       	call   80103c5c <acquire>
    havekids = 0;
80103810:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103815:	bb 74 2d 11 80       	mov    $0x80112d74,%ebx
8010381a:	eb 63                	jmp    8010387f <wait+0x8a>
      if(p->parent != curproc)
8010381c:	39 73 14             	cmp    %esi,0x14(%ebx)
8010381f:	75 5b                	jne    8010387c <wait+0x87>
      if(p->state == ZOMBIE){
80103821:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103825:	75 50                	jne    80103877 <wait+0x82>
        pid = p->pid;
80103827:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
8010382a:	8b 43 08             	mov    0x8(%ebx),%eax
8010382d:	89 04 24             	mov    %eax,(%esp)
80103830:	e8 e7 e7 ff ff       	call   8010201c <kfree>
        p->kstack = 0;
80103835:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
8010383c:	8b 43 04             	mov    0x4(%ebx),%eax
8010383f:	89 04 24             	mov    %eax,(%esp)
80103842:	e8 6c 2a 00 00       	call   801062b3 <freevm>
        p->pid = 0;
80103847:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
8010384e:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
80103855:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80103859:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103860:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
80103867:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
8010386e:	e8 4a 04 00 00       	call   80103cbd <release>
        return pid;
80103873:	89 f0                	mov    %esi,%eax
80103875:	eb 42                	jmp    801038b9 <wait+0xc4>
      havekids = 1;
80103877:	b8 01 00 00 00       	mov    $0x1,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010387c:	83 c3 7c             	add    $0x7c,%ebx
8010387f:	81 fb 74 4c 11 80    	cmp    $0x80114c74,%ebx
80103885:	72 95                	jb     8010381c <wait+0x27>
    if(!havekids || curproc->killed){
80103887:	85 c0                	test   %eax,%eax
80103889:	74 06                	je     80103891 <wait+0x9c>
8010388b:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
8010388f:	74 13                	je     801038a4 <wait+0xaf>
      release(&ptable.lock);
80103891:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103898:	e8 20 04 00 00       	call   80103cbd <release>
      return -1;
8010389d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038a2:	eb 15                	jmp    801038b9 <wait+0xc4>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801038a4:	c7 44 24 04 40 2d 11 	movl   $0x80112d40,0x4(%esp)
801038ab:	80 
801038ac:	89 34 24             	mov    %esi,(%esp)
801038af:	e8 b7 fe ff ff       	call   8010376b <sleep>
  }
801038b4:	e9 57 ff ff ff       	jmp    80103810 <wait+0x1b>
}
801038b9:	83 c4 10             	add    $0x10,%esp
801038bc:	5b                   	pop    %ebx
801038bd:	5e                   	pop    %esi
801038be:	5d                   	pop    %ebp
801038bf:	c3                   	ret    

801038c0 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801038c0:	55                   	push   %ebp
801038c1:	89 e5                	mov    %esp,%ebp
801038c3:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
801038c6:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
801038cd:	e8 8a 03 00 00       	call   80103c5c <acquire>
  wakeup1(chan);
801038d2:	8b 45 08             	mov    0x8(%ebp),%eax
801038d5:	e8 36 f8 ff ff       	call   80103110 <wakeup1>
  release(&ptable.lock);
801038da:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
801038e1:	e8 d7 03 00 00       	call   80103cbd <release>
}
801038e6:	c9                   	leave  
801038e7:	c3                   	ret    

801038e8 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801038e8:	55                   	push   %ebp
801038e9:	89 e5                	mov    %esp,%ebp
801038eb:	53                   	push   %ebx
801038ec:	83 ec 14             	sub    $0x14,%esp
801038ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801038f2:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
801038f9:	e8 5e 03 00 00       	call   80103c5c <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038fe:	b8 74 2d 11 80       	mov    $0x80112d74,%eax
80103903:	eb 2f                	jmp    80103934 <kill+0x4c>
    if(p->pid == pid){
80103905:	39 58 10             	cmp    %ebx,0x10(%eax)
80103908:	75 27                	jne    80103931 <kill+0x49>
      p->killed = 1;
8010390a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80103911:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103915:	75 07                	jne    8010391e <kill+0x36>
        p->state = RUNNABLE;
80103917:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010391e:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103925:	e8 93 03 00 00       	call   80103cbd <release>
      return 0;
8010392a:	b8 00 00 00 00       	mov    $0x0,%eax
8010392f:	eb 1b                	jmp    8010394c <kill+0x64>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103931:	83 c0 7c             	add    $0x7c,%eax
80103934:	3d 74 4c 11 80       	cmp    $0x80114c74,%eax
80103939:	72 ca                	jb     80103905 <kill+0x1d>
    }
  }
  release(&ptable.lock);
8010393b:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103942:	e8 76 03 00 00       	call   80103cbd <release>
  return -1;
80103947:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010394c:	83 c4 14             	add    $0x14,%esp
8010394f:	5b                   	pop    %ebx
80103950:	5d                   	pop    %ebp
80103951:	c3                   	ret    

80103952 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103952:	55                   	push   %ebp
80103953:	89 e5                	mov    %esp,%ebp
80103955:	57                   	push   %edi
80103956:	56                   	push   %esi
80103957:	53                   	push   %ebx
80103958:	83 ec 4c             	sub    $0x4c,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010395b:	bb 74 2d 11 80       	mov    $0x80112d74,%ebx
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103960:	8d 75 c0             	lea    -0x40(%ebp),%esi
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103963:	e9 96 00 00 00       	jmp    801039fe <procdump+0xac>
    if(p->state == UNUSED)
80103968:	8b 43 0c             	mov    0xc(%ebx),%eax
8010396b:	85 c0                	test   %eax,%eax
8010396d:	0f 84 88 00 00 00    	je     801039fb <procdump+0xa9>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103973:	83 f8 05             	cmp    $0x5,%eax
80103976:	77 12                	ja     8010398a <procdump+0x38>
80103978:	8b 04 85 f8 6c 10 80 	mov    -0x7fef9308(,%eax,4),%eax
8010397f:	85 c0                	test   %eax,%eax
80103981:	75 0c                	jne    8010398f <procdump+0x3d>
      state = "???";
80103983:	b8 98 6c 10 80       	mov    $0x80106c98,%eax
80103988:	eb 05                	jmp    8010398f <procdump+0x3d>
8010398a:	b8 98 6c 10 80       	mov    $0x80106c98,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
8010398f:	8d 53 6c             	lea    0x6c(%ebx),%edx
80103992:	89 54 24 0c          	mov    %edx,0xc(%esp)
80103996:	89 44 24 08          	mov    %eax,0x8(%esp)
8010399a:	8b 43 10             	mov    0x10(%ebx),%eax
8010399d:	89 44 24 04          	mov    %eax,0x4(%esp)
801039a1:	c7 04 24 9c 6c 10 80 	movl   $0x80106c9c,(%esp)
801039a8:	e8 1a cc ff ff       	call   801005c7 <cprintf>
    if(p->state == SLEEPING){
801039ad:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
801039b1:	75 3c                	jne    801039ef <procdump+0x9d>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801039b3:	8b 43 1c             	mov    0x1c(%ebx),%eax
801039b6:	8b 40 0c             	mov    0xc(%eax),%eax
801039b9:	83 c0 08             	add    $0x8,%eax
801039bc:	89 74 24 04          	mov    %esi,0x4(%esp)
801039c0:	89 04 24             	mov    %eax,(%esp)
801039c3:	e8 77 01 00 00       	call   80103b3f <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801039c8:	bf 00 00 00 00       	mov    $0x0,%edi
801039cd:	eb 13                	jmp    801039e2 <procdump+0x90>
        cprintf(" %p", pc[i]);
801039cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801039d3:	c7 04 24 21 66 10 80 	movl   $0x80106621,(%esp)
801039da:	e8 e8 cb ff ff       	call   801005c7 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
801039df:	83 c7 01             	add    $0x1,%edi
801039e2:	83 ff 09             	cmp    $0x9,%edi
801039e5:	7f 08                	jg     801039ef <procdump+0x9d>
801039e7:	8b 44 bd c0          	mov    -0x40(%ebp,%edi,4),%eax
801039eb:	85 c0                	test   %eax,%eax
801039ed:	75 e0                	jne    801039cf <procdump+0x7d>
    }
    cprintf("\n");
801039ef:	c7 04 24 27 70 10 80 	movl   $0x80107027,(%esp)
801039f6:	e8 cc cb ff ff       	call   801005c7 <cprintf>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039fb:	83 c3 7c             	add    $0x7c,%ebx
801039fe:	81 fb 74 4c 11 80    	cmp    $0x80114c74,%ebx
80103a04:	0f 82 5e ff ff ff    	jb     80103968 <procdump+0x16>
  }
}
80103a0a:	83 c4 4c             	add    $0x4c,%esp
80103a0d:	5b                   	pop    %ebx
80103a0e:	5e                   	pop    %esi
80103a0f:	5f                   	pop    %edi
80103a10:	5d                   	pop    %ebp
80103a11:	c3                   	ret    

80103a12 <setwritecount>:

int
setwritecount(int newnum)
{
80103a12:	55                   	push   %ebp
80103a13:	89 e5                	mov    %esp,%ebp
80103a15:	8b 45 08             	mov    0x8(%ebp),%eax
    counter = newnum;
80103a18:	a3 bc a5 10 80       	mov    %eax,0x8010a5bc
    return counter;

80103a1d:	5d                   	pop    %ebp
80103a1e:	c3                   	ret    

80103a1f <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103a1f:	55                   	push   %ebp
80103a20:	89 e5                	mov    %esp,%ebp
80103a22:	53                   	push   %ebx
80103a23:	83 ec 14             	sub    $0x14,%esp
80103a26:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103a29:	c7 44 24 04 10 6d 10 	movl   $0x80106d10,0x4(%esp)
80103a30:	80 
80103a31:	8d 43 04             	lea    0x4(%ebx),%eax
80103a34:	89 04 24             	mov    %eax,(%esp)
80103a37:	e8 e8 00 00 00       	call   80103b24 <initlock>
  lk->name = name;
80103a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a3f:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103a42:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103a48:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103a4f:	83 c4 14             	add    $0x14,%esp
80103a52:	5b                   	pop    %ebx
80103a53:	5d                   	pop    %ebp
80103a54:	c3                   	ret    

80103a55 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103a55:	55                   	push   %ebp
80103a56:	89 e5                	mov    %esp,%ebp
80103a58:	56                   	push   %esi
80103a59:	53                   	push   %ebx
80103a5a:	83 ec 10             	sub    $0x10,%esp
80103a5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103a60:	8d 73 04             	lea    0x4(%ebx),%esi
80103a63:	89 34 24             	mov    %esi,(%esp)
80103a66:	e8 f1 01 00 00       	call   80103c5c <acquire>
  while (lk->locked) {
80103a6b:	eb 0c                	jmp    80103a79 <acquiresleep+0x24>
    sleep(lk, &lk->lk);
80103a6d:	89 74 24 04          	mov    %esi,0x4(%esp)
80103a71:	89 1c 24             	mov    %ebx,(%esp)
80103a74:	e8 f2 fc ff ff       	call   8010376b <sleep>
  while (lk->locked) {
80103a79:	83 3b 00             	cmpl   $0x0,(%ebx)
80103a7c:	75 ef                	jne    80103a6d <acquiresleep+0x18>
  }
  lk->locked = 1;
80103a7e:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103a84:	e8 3c f8 ff ff       	call   801032c5 <myproc>
80103a89:	8b 40 10             	mov    0x10(%eax),%eax
80103a8c:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103a8f:	89 34 24             	mov    %esi,(%esp)
80103a92:	e8 26 02 00 00       	call   80103cbd <release>
}
80103a97:	83 c4 10             	add    $0x10,%esp
80103a9a:	5b                   	pop    %ebx
80103a9b:	5e                   	pop    %esi
80103a9c:	5d                   	pop    %ebp
80103a9d:	c3                   	ret    

80103a9e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103a9e:	55                   	push   %ebp
80103a9f:	89 e5                	mov    %esp,%ebp
80103aa1:	56                   	push   %esi
80103aa2:	53                   	push   %ebx
80103aa3:	83 ec 10             	sub    $0x10,%esp
80103aa6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103aa9:	8d 73 04             	lea    0x4(%ebx),%esi
80103aac:	89 34 24             	mov    %esi,(%esp)
80103aaf:	e8 a8 01 00 00       	call   80103c5c <acquire>
  lk->locked = 0;
80103ab4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103aba:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103ac1:	89 1c 24             	mov    %ebx,(%esp)
80103ac4:	e8 f7 fd ff ff       	call   801038c0 <wakeup>
  release(&lk->lk);
80103ac9:	89 34 24             	mov    %esi,(%esp)
80103acc:	e8 ec 01 00 00       	call   80103cbd <release>
}
80103ad1:	83 c4 10             	add    $0x10,%esp
80103ad4:	5b                   	pop    %ebx
80103ad5:	5e                   	pop    %esi
80103ad6:	5d                   	pop    %ebp
80103ad7:	c3                   	ret    

80103ad8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103ad8:	55                   	push   %ebp
80103ad9:	89 e5                	mov    %esp,%ebp
80103adb:	56                   	push   %esi
80103adc:	53                   	push   %ebx
80103add:	83 ec 10             	sub    $0x10,%esp
80103ae0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103ae3:	8d 73 04             	lea    0x4(%ebx),%esi
80103ae6:	89 34 24             	mov    %esi,(%esp)
80103ae9:	e8 6e 01 00 00       	call   80103c5c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103aee:	83 3b 00             	cmpl   $0x0,(%ebx)
80103af1:	74 14                	je     80103b07 <holdingsleep+0x2f>
80103af3:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103af6:	e8 ca f7 ff ff       	call   801032c5 <myproc>
80103afb:	3b 58 10             	cmp    0x10(%eax),%ebx
80103afe:	75 0e                	jne    80103b0e <holdingsleep+0x36>
80103b00:	bb 01 00 00 00       	mov    $0x1,%ebx
80103b05:	eb 0c                	jmp    80103b13 <holdingsleep+0x3b>
80103b07:	bb 00 00 00 00       	mov    $0x0,%ebx
80103b0c:	eb 05                	jmp    80103b13 <holdingsleep+0x3b>
80103b0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103b13:	89 34 24             	mov    %esi,(%esp)
80103b16:	e8 a2 01 00 00       	call   80103cbd <release>
  return r;
}
80103b1b:	89 d8                	mov    %ebx,%eax
80103b1d:	83 c4 10             	add    $0x10,%esp
80103b20:	5b                   	pop    %ebx
80103b21:	5e                   	pop    %esi
80103b22:	5d                   	pop    %ebp
80103b23:	c3                   	ret    

80103b24 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103b24:	55                   	push   %ebp
80103b25:	89 e5                	mov    %esp,%ebp
80103b27:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103b2a:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b2d:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103b30:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103b36:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103b3d:	5d                   	pop    %ebp
80103b3e:	c3                   	ret    

80103b3f <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103b3f:	55                   	push   %ebp
80103b40:	89 e5                	mov    %esp,%ebp
80103b42:	53                   	push   %ebx
80103b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103b46:	8b 45 08             	mov    0x8(%ebp),%eax
80103b49:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103b4c:	b8 00 00 00 00       	mov    $0x0,%eax
80103b51:	eb 19                	jmp    80103b6c <getcallerpcs+0x2d>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103b53:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103b59:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103b5f:	77 1c                	ja     80103b7d <getcallerpcs+0x3e>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103b61:	8b 5a 04             	mov    0x4(%edx),%ebx
80103b64:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103b67:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103b69:	83 c0 01             	add    $0x1,%eax
80103b6c:	83 f8 09             	cmp    $0x9,%eax
80103b6f:	7e e2                	jle    80103b53 <getcallerpcs+0x14>
80103b71:	eb 0a                	jmp    80103b7d <getcallerpcs+0x3e>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103b73:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103b7a:	83 c0 01             	add    $0x1,%eax
80103b7d:	83 f8 09             	cmp    $0x9,%eax
80103b80:	7e f1                	jle    80103b73 <getcallerpcs+0x34>
}
80103b82:	5b                   	pop    %ebx
80103b83:	5d                   	pop    %ebp
80103b84:	c3                   	ret    

80103b85 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103b85:	55                   	push   %ebp
80103b86:	89 e5                	mov    %esp,%ebp
80103b88:	53                   	push   %ebx
80103b89:	83 ec 04             	sub    $0x4,%esp
80103b8c:	9c                   	pushf  
80103b8d:	5b                   	pop    %ebx
  asm volatile("cli");
80103b8e:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103b8f:	e8 bc f6 ff ff       	call   80103250 <mycpu>
80103b94:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103b9b:	75 11                	jne    80103bae <pushcli+0x29>
    mycpu()->intena = eflags & FL_IF;
80103b9d:	e8 ae f6 ff ff       	call   80103250 <mycpu>
80103ba2:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103ba8:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
  mycpu()->ncli += 1;
80103bae:	e8 9d f6 ff ff       	call   80103250 <mycpu>
80103bb3:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103bba:	83 c4 04             	add    $0x4,%esp
80103bbd:	5b                   	pop    %ebx
80103bbe:	5d                   	pop    %ebp
80103bbf:	c3                   	ret    

80103bc0 <popcli>:

void
popcli(void)
{
80103bc0:	55                   	push   %ebp
80103bc1:	89 e5                	mov    %esp,%ebp
80103bc3:	83 ec 18             	sub    $0x18,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103bc6:	9c                   	pushf  
80103bc7:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103bc8:	f6 c4 02             	test   $0x2,%ah
80103bcb:	74 0c                	je     80103bd9 <popcli+0x19>
    panic("popcli - interruptible");
80103bcd:	c7 04 24 1b 6d 10 80 	movl   $0x80106d1b,(%esp)
80103bd4:	e8 4c c7 ff ff       	call   80100325 <panic>
  if(--mycpu()->ncli < 0)
80103bd9:	e8 72 f6 ff ff       	call   80103250 <mycpu>
80103bde:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103be4:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103be7:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103bed:	85 d2                	test   %edx,%edx
80103bef:	79 0c                	jns    80103bfd <popcli+0x3d>
    panic("popcli");
80103bf1:	c7 04 24 32 6d 10 80 	movl   $0x80106d32,(%esp)
80103bf8:	e8 28 c7 ff ff       	call   80100325 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103bfd:	e8 4e f6 ff ff       	call   80103250 <mycpu>
80103c02:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103c09:	75 0f                	jne    80103c1a <popcli+0x5a>
80103c0b:	e8 40 f6 ff ff       	call   80103250 <mycpu>
80103c10:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103c17:	74 01                	je     80103c1a <popcli+0x5a>
  asm volatile("sti");
80103c19:	fb                   	sti    
    sti();
}
80103c1a:	c9                   	leave  
80103c1b:	c3                   	ret    

80103c1c <holding>:
{
80103c1c:	55                   	push   %ebp
80103c1d:	89 e5                	mov    %esp,%ebp
80103c1f:	53                   	push   %ebx
80103c20:	83 ec 04             	sub    $0x4,%esp
80103c23:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103c26:	e8 5a ff ff ff       	call   80103b85 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103c2b:	83 3b 00             	cmpl   $0x0,(%ebx)
80103c2e:	74 13                	je     80103c43 <holding+0x27>
80103c30:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103c33:	e8 18 f6 ff ff       	call   80103250 <mycpu>
80103c38:	39 c3                	cmp    %eax,%ebx
80103c3a:	75 0e                	jne    80103c4a <holding+0x2e>
80103c3c:	bb 01 00 00 00       	mov    $0x1,%ebx
80103c41:	eb 0c                	jmp    80103c4f <holding+0x33>
80103c43:	bb 00 00 00 00       	mov    $0x0,%ebx
80103c48:	eb 05                	jmp    80103c4f <holding+0x33>
80103c4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103c4f:	e8 6c ff ff ff       	call   80103bc0 <popcli>
}
80103c54:	89 d8                	mov    %ebx,%eax
80103c56:	83 c4 04             	add    $0x4,%esp
80103c59:	5b                   	pop    %ebx
80103c5a:	5d                   	pop    %ebp
80103c5b:	c3                   	ret    

80103c5c <acquire>:
{
80103c5c:	55                   	push   %ebp
80103c5d:	89 e5                	mov    %esp,%ebp
80103c5f:	53                   	push   %ebx
80103c60:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103c63:	e8 1d ff ff ff       	call   80103b85 <pushcli>
  if(holding(lk))
80103c68:	8b 45 08             	mov    0x8(%ebp),%eax
80103c6b:	89 04 24             	mov    %eax,(%esp)
80103c6e:	e8 a9 ff ff ff       	call   80103c1c <holding>
80103c73:	85 c0                	test   %eax,%eax
80103c75:	74 0c                	je     80103c83 <acquire+0x27>
    panic("acquire");
80103c77:	c7 04 24 39 6d 10 80 	movl   $0x80106d39,(%esp)
80103c7e:	e8 a2 c6 ff ff       	call   80100325 <panic>
  asm volatile("lock; xchgl %0, %1" :
80103c83:	b9 01 00 00 00       	mov    $0x1,%ecx
  while(xchg(&lk->locked, 1) != 0)
80103c88:	8b 55 08             	mov    0x8(%ebp),%edx
80103c8b:	89 c8                	mov    %ecx,%eax
80103c8d:	f0 87 02             	lock xchg %eax,(%edx)
80103c90:	85 c0                	test   %eax,%eax
80103c92:	75 f4                	jne    80103c88 <acquire+0x2c>
  __sync_synchronize();
80103c94:	0f ae f0             	mfence 
  lk->cpu = mycpu();
80103c97:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103c9a:	e8 b1 f5 ff ff       	call   80103250 <mycpu>
80103c9f:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103ca2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ca5:	83 c0 0c             	add    $0xc,%eax
80103ca8:	89 44 24 04          	mov    %eax,0x4(%esp)
80103cac:	8d 45 08             	lea    0x8(%ebp),%eax
80103caf:	89 04 24             	mov    %eax,(%esp)
80103cb2:	e8 88 fe ff ff       	call   80103b3f <getcallerpcs>
}
80103cb7:	83 c4 14             	add    $0x14,%esp
80103cba:	5b                   	pop    %ebx
80103cbb:	5d                   	pop    %ebp
80103cbc:	c3                   	ret    

80103cbd <release>:
{
80103cbd:	55                   	push   %ebp
80103cbe:	89 e5                	mov    %esp,%ebp
80103cc0:	53                   	push   %ebx
80103cc1:	83 ec 14             	sub    $0x14,%esp
80103cc4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103cc7:	89 1c 24             	mov    %ebx,(%esp)
80103cca:	e8 4d ff ff ff       	call   80103c1c <holding>
80103ccf:	85 c0                	test   %eax,%eax
80103cd1:	75 0c                	jne    80103cdf <release+0x22>
    panic("release");
80103cd3:	c7 04 24 41 6d 10 80 	movl   $0x80106d41,(%esp)
80103cda:	e8 46 c6 ff ff       	call   80100325 <panic>
  lk->pcs[0] = 0;
80103cdf:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103ce6:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103ced:	0f ae f0             	mfence 
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103cf0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103cf6:	e8 c5 fe ff ff       	call   80103bc0 <popcli>
}
80103cfb:	83 c4 14             	add    $0x14,%esp
80103cfe:	5b                   	pop    %ebx
80103cff:	5d                   	pop    %ebp
80103d00:	c3                   	ret    
80103d01:	66 90                	xchg   %ax,%ax
80103d03:	66 90                	xchg   %ax,%ax
80103d05:	66 90                	xchg   %ax,%ax
80103d07:	66 90                	xchg   %ax,%ax
80103d09:	66 90                	xchg   %ax,%ax
80103d0b:	66 90                	xchg   %ax,%ax
80103d0d:	66 90                	xchg   %ax,%ax
80103d0f:	90                   	nop

80103d10 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103d10:	55                   	push   %ebp
80103d11:	89 e5                	mov    %esp,%ebp
80103d13:	57                   	push   %edi
80103d14:	53                   	push   %ebx
80103d15:	8b 55 08             	mov    0x8(%ebp),%edx
80103d18:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103d1b:	f6 c2 03             	test   $0x3,%dl
80103d1e:	75 28                	jne    80103d48 <memset+0x38>
80103d20:	f6 c1 03             	test   $0x3,%cl
80103d23:	75 23                	jne    80103d48 <memset+0x38>
    c &= 0xFF;
80103d25:	0f b6 45 0c          	movzbl 0xc(%ebp),%eax
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103d29:	c1 e9 02             	shr    $0x2,%ecx
80103d2c:	89 c7                	mov    %eax,%edi
80103d2e:	c1 e7 18             	shl    $0x18,%edi
80103d31:	89 c3                	mov    %eax,%ebx
80103d33:	c1 e3 10             	shl    $0x10,%ebx
80103d36:	09 df                	or     %ebx,%edi
80103d38:	89 c3                	mov    %eax,%ebx
80103d3a:	c1 e3 08             	shl    $0x8,%ebx
80103d3d:	09 df                	or     %ebx,%edi
80103d3f:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103d41:	89 d7                	mov    %edx,%edi
80103d43:	fc                   	cld    
80103d44:	f3 ab                	rep stos %eax,%es:(%edi)
80103d46:	eb 08                	jmp    80103d50 <memset+0x40>
  asm volatile("cld; rep stosb" :
80103d48:	89 d7                	mov    %edx,%edi
80103d4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d4d:	fc                   	cld    
80103d4e:	f3 aa                	rep stos %al,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80103d50:	89 d0                	mov    %edx,%eax
80103d52:	5b                   	pop    %ebx
80103d53:	5f                   	pop    %edi
80103d54:	5d                   	pop    %ebp
80103d55:	c3                   	ret    

80103d56 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103d56:	55                   	push   %ebp
80103d57:	89 e5                	mov    %esp,%ebp
80103d59:	56                   	push   %esi
80103d5a:	53                   	push   %ebx
80103d5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103d5e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d61:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103d64:	eb 1c                	jmp    80103d82 <memcmp+0x2c>
    if(*s1 != *s2)
80103d66:	0f b6 01             	movzbl (%ecx),%eax
80103d69:	0f b6 1a             	movzbl (%edx),%ebx
80103d6c:	38 d8                	cmp    %bl,%al
80103d6e:	74 0a                	je     80103d7a <memcmp+0x24>
      return *s1 - *s2;
80103d70:	0f b6 c0             	movzbl %al,%eax
80103d73:	0f b6 db             	movzbl %bl,%ebx
80103d76:	29 d8                	sub    %ebx,%eax
80103d78:	eb 0f                	jmp    80103d89 <memcmp+0x33>
    s1++, s2++;
80103d7a:	83 c1 01             	add    $0x1,%ecx
80103d7d:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103d80:	89 f0                	mov    %esi,%eax
80103d82:	8d 70 ff             	lea    -0x1(%eax),%esi
80103d85:	85 c0                	test   %eax,%eax
80103d87:	75 dd                	jne    80103d66 <memcmp+0x10>
  }

  return 0;
}
80103d89:	5b                   	pop    %ebx
80103d8a:	5e                   	pop    %esi
80103d8b:	5d                   	pop    %ebp
80103d8c:	c3                   	ret    

80103d8d <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103d8d:	55                   	push   %ebp
80103d8e:	89 e5                	mov    %esp,%ebp
80103d90:	56                   	push   %esi
80103d91:	53                   	push   %ebx
80103d92:	8b 45 08             	mov    0x8(%ebp),%eax
80103d95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103d98:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103d9b:	39 c1                	cmp    %eax,%ecx
80103d9d:	73 31                	jae    80103dd0 <memmove+0x43>
80103d9f:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103da2:	39 d8                	cmp    %ebx,%eax
80103da4:	73 2e                	jae    80103dd4 <memmove+0x47>
    s += n;
    d += n;
80103da6:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80103da9:	eb 0d                	jmp    80103db8 <memmove+0x2b>
      *--d = *--s;
80103dab:	83 e9 01             	sub    $0x1,%ecx
80103dae:	83 eb 01             	sub    $0x1,%ebx
80103db1:	0f b6 13             	movzbl (%ebx),%edx
80103db4:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80103db6:	89 f2                	mov    %esi,%edx
80103db8:	8d 72 ff             	lea    -0x1(%edx),%esi
80103dbb:	85 d2                	test   %edx,%edx
80103dbd:	75 ec                	jne    80103dab <memmove+0x1e>
80103dbf:	eb 1c                	jmp    80103ddd <memmove+0x50>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103dc1:	0f b6 11             	movzbl (%ecx),%edx
80103dc4:	88 13                	mov    %dl,(%ebx)
    while(n-- > 0)
80103dc6:	89 f2                	mov    %esi,%edx
      *d++ = *s++;
80103dc8:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103dcb:	8d 49 01             	lea    0x1(%ecx),%ecx
80103dce:	eb 06                	jmp    80103dd6 <memmove+0x49>
80103dd0:	89 c3                	mov    %eax,%ebx
80103dd2:	eb 02                	jmp    80103dd6 <memmove+0x49>
80103dd4:	89 c3                	mov    %eax,%ebx
    while(n-- > 0)
80103dd6:	8d 72 ff             	lea    -0x1(%edx),%esi
80103dd9:	85 d2                	test   %edx,%edx
80103ddb:	75 e4                	jne    80103dc1 <memmove+0x34>

  return dst;
}
80103ddd:	5b                   	pop    %ebx
80103dde:	5e                   	pop    %esi
80103ddf:	5d                   	pop    %ebp
80103de0:	c3                   	ret    

80103de1 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103de1:	55                   	push   %ebp
80103de2:	89 e5                	mov    %esp,%ebp
80103de4:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80103de7:	8b 45 10             	mov    0x10(%ebp),%eax
80103dea:	89 44 24 08          	mov    %eax,0x8(%esp)
80103dee:	8b 45 0c             	mov    0xc(%ebp),%eax
80103df1:	89 44 24 04          	mov    %eax,0x4(%esp)
80103df5:	8b 45 08             	mov    0x8(%ebp),%eax
80103df8:	89 04 24             	mov    %eax,(%esp)
80103dfb:	e8 8d ff ff ff       	call   80103d8d <memmove>
}
80103e00:	c9                   	leave  
80103e01:	c3                   	ret    

80103e02 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103e02:	55                   	push   %ebp
80103e03:	89 e5                	mov    %esp,%ebp
80103e05:	53                   	push   %ebx
80103e06:	8b 55 08             	mov    0x8(%ebp),%edx
80103e09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103e0c:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103e0f:	eb 09                	jmp    80103e1a <strncmp+0x18>
    n--, p++, q++;
80103e11:	83 e8 01             	sub    $0x1,%eax
80103e14:	83 c2 01             	add    $0x1,%edx
80103e17:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103e1a:	85 c0                	test   %eax,%eax
80103e1c:	74 0b                	je     80103e29 <strncmp+0x27>
80103e1e:	0f b6 1a             	movzbl (%edx),%ebx
80103e21:	84 db                	test   %bl,%bl
80103e23:	74 04                	je     80103e29 <strncmp+0x27>
80103e25:	3a 19                	cmp    (%ecx),%bl
80103e27:	74 e8                	je     80103e11 <strncmp+0xf>
  if(n == 0)
80103e29:	85 c0                	test   %eax,%eax
80103e2b:	74 0a                	je     80103e37 <strncmp+0x35>
    return 0;
  return (uchar)*p - (uchar)*q;
80103e2d:	0f b6 02             	movzbl (%edx),%eax
80103e30:	0f b6 11             	movzbl (%ecx),%edx
80103e33:	29 d0                	sub    %edx,%eax
80103e35:	eb 05                	jmp    80103e3c <strncmp+0x3a>
    return 0;
80103e37:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103e3c:	5b                   	pop    %ebx
80103e3d:	5d                   	pop    %ebp
80103e3e:	c3                   	ret    

80103e3f <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103e3f:	55                   	push   %ebp
80103e40:	89 e5                	mov    %esp,%ebp
80103e42:	57                   	push   %edi
80103e43:	56                   	push   %esi
80103e44:	53                   	push   %ebx
80103e45:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103e48:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103e4b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e4e:	eb 04                	jmp    80103e54 <strncpy+0x15>
80103e50:	89 fb                	mov    %edi,%ebx
80103e52:	89 f0                	mov    %esi,%eax
80103e54:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103e57:	85 c9                	test   %ecx,%ecx
80103e59:	7e 1d                	jle    80103e78 <strncpy+0x39>
80103e5b:	8d 70 01             	lea    0x1(%eax),%esi
80103e5e:	8d 7b 01             	lea    0x1(%ebx),%edi
80103e61:	0f b6 1b             	movzbl (%ebx),%ebx
80103e64:	88 18                	mov    %bl,(%eax)
80103e66:	89 d1                	mov    %edx,%ecx
80103e68:	84 db                	test   %bl,%bl
80103e6a:	75 e4                	jne    80103e50 <strncpy+0x11>
80103e6c:	89 f0                	mov    %esi,%eax
80103e6e:	eb 08                	jmp    80103e78 <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80103e70:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80103e73:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80103e75:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
80103e78:	8d 4a ff             	lea    -0x1(%edx),%ecx
80103e7b:	85 d2                	test   %edx,%edx
80103e7d:	7f f1                	jg     80103e70 <strncpy+0x31>
  return os;
}
80103e7f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e82:	5b                   	pop    %ebx
80103e83:	5e                   	pop    %esi
80103e84:	5f                   	pop    %edi
80103e85:	5d                   	pop    %ebp
80103e86:	c3                   	ret    

80103e87 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103e87:	55                   	push   %ebp
80103e88:	89 e5                	mov    %esp,%ebp
80103e8a:	57                   	push   %edi
80103e8b:	56                   	push   %esi
80103e8c:	53                   	push   %ebx
80103e8d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103e93:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80103e96:	85 d2                	test   %edx,%edx
80103e98:	7e 23                	jle    80103ebd <safestrcpy+0x36>
80103e9a:	89 c1                	mov    %eax,%ecx
80103e9c:	eb 04                	jmp    80103ea2 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103e9e:	89 fb                	mov    %edi,%ebx
80103ea0:	89 f1                	mov    %esi,%ecx
80103ea2:	83 ea 01             	sub    $0x1,%edx
80103ea5:	85 d2                	test   %edx,%edx
80103ea7:	7e 11                	jle    80103eba <safestrcpy+0x33>
80103ea9:	8d 71 01             	lea    0x1(%ecx),%esi
80103eac:	8d 7b 01             	lea    0x1(%ebx),%edi
80103eaf:	0f b6 1b             	movzbl (%ebx),%ebx
80103eb2:	88 19                	mov    %bl,(%ecx)
80103eb4:	84 db                	test   %bl,%bl
80103eb6:	75 e6                	jne    80103e9e <safestrcpy+0x17>
80103eb8:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
80103eba:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80103ebd:	5b                   	pop    %ebx
80103ebe:	5e                   	pop    %esi
80103ebf:	5f                   	pop    %edi
80103ec0:	5d                   	pop    %ebp
80103ec1:	c3                   	ret    

80103ec2 <strlen>:

int
strlen(const char *s)
{
80103ec2:	55                   	push   %ebp
80103ec3:	89 e5                	mov    %esp,%ebp
80103ec5:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103ec8:	b8 00 00 00 00       	mov    $0x0,%eax
80103ecd:	eb 03                	jmp    80103ed2 <strlen+0x10>
80103ecf:	83 c0 01             	add    $0x1,%eax
80103ed2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103ed6:	75 f7                	jne    80103ecf <strlen+0xd>
    ;
  return n;
}
80103ed8:	5d                   	pop    %ebp
80103ed9:	c3                   	ret    

80103eda <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103eda:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103ede:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103ee2:	55                   	push   %ebp
  pushl %ebx
80103ee3:	53                   	push   %ebx
  pushl %esi
80103ee4:	56                   	push   %esi
  pushl %edi
80103ee5:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103ee6:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103ee8:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103eea:	5f                   	pop    %edi
  popl %esi
80103eeb:	5e                   	pop    %esi
  popl %ebx
80103eec:	5b                   	pop    %ebx
  popl %ebp
80103eed:	5d                   	pop    %ebp
  ret
80103eee:	c3                   	ret    

80103eef <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103eef:	55                   	push   %ebp
80103ef0:	89 e5                	mov    %esp,%ebp
80103ef2:	53                   	push   %ebx
80103ef3:	83 ec 04             	sub    $0x4,%esp
80103ef6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103ef9:	e8 c7 f3 ff ff       	call   801032c5 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103efe:	8b 00                	mov    (%eax),%eax
80103f00:	39 d8                	cmp    %ebx,%eax
80103f02:	76 15                	jbe    80103f19 <fetchint+0x2a>
80103f04:	8d 53 04             	lea    0x4(%ebx),%edx
80103f07:	39 d0                	cmp    %edx,%eax
80103f09:	72 15                	jb     80103f20 <fetchint+0x31>
    return -1;
  *ip = *(int*)(addr);
80103f0b:	8b 13                	mov    (%ebx),%edx
80103f0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f10:	89 10                	mov    %edx,(%eax)
  return 0;
80103f12:	b8 00 00 00 00       	mov    $0x0,%eax
80103f17:	eb 0c                	jmp    80103f25 <fetchint+0x36>
    return -1;
80103f19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f1e:	eb 05                	jmp    80103f25 <fetchint+0x36>
80103f20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103f25:	83 c4 04             	add    $0x4,%esp
80103f28:	5b                   	pop    %ebx
80103f29:	5d                   	pop    %ebp
80103f2a:	c3                   	ret    

80103f2b <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80103f2b:	55                   	push   %ebp
80103f2c:	89 e5                	mov    %esp,%ebp
80103f2e:	53                   	push   %ebx
80103f2f:	83 ec 04             	sub    $0x4,%esp
80103f32:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80103f35:	e8 8b f3 ff ff       	call   801032c5 <myproc>

  if(addr >= curproc->sz)
80103f3a:	39 18                	cmp    %ebx,(%eax)
80103f3c:	76 22                	jbe    80103f60 <fetchstr+0x35>
    return -1;
  *pp = (char*)addr;
80103f3e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f41:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80103f43:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80103f45:	89 d8                	mov    %ebx,%eax
80103f47:	eb 0c                	jmp    80103f55 <fetchstr+0x2a>
    if(*s == 0)
80103f49:	80 38 00             	cmpb   $0x0,(%eax)
80103f4c:	75 04                	jne    80103f52 <fetchstr+0x27>
      return s - *pp;
80103f4e:	29 d8                	sub    %ebx,%eax
80103f50:	eb 13                	jmp    80103f65 <fetchstr+0x3a>
  for(s = *pp; s < ep; s++){
80103f52:	83 c0 01             	add    $0x1,%eax
80103f55:	39 d0                	cmp    %edx,%eax
80103f57:	72 f0                	jb     80103f49 <fetchstr+0x1e>
  }
  return -1;
80103f59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f5e:	eb 05                	jmp    80103f65 <fetchstr+0x3a>
    return -1;
80103f60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103f65:	83 c4 04             	add    $0x4,%esp
80103f68:	5b                   	pop    %ebx
80103f69:	5d                   	pop    %ebp
80103f6a:	c3                   	ret    

80103f6b <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80103f6b:	55                   	push   %ebp
80103f6c:	89 e5                	mov    %esp,%ebp
80103f6e:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80103f71:	e8 4f f3 ff ff       	call   801032c5 <myproc>
80103f76:	8b 50 18             	mov    0x18(%eax),%edx
80103f79:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7c:	c1 e0 02             	shl    $0x2,%eax
80103f7f:	03 42 44             	add    0x44(%edx),%eax
80103f82:	83 c0 04             	add    $0x4,%eax
80103f85:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f88:	89 54 24 04          	mov    %edx,0x4(%esp)
80103f8c:	89 04 24             	mov    %eax,(%esp)
80103f8f:	e8 5b ff ff ff       	call   80103eef <fetchint>
}
80103f94:	c9                   	leave  
80103f95:	c3                   	ret    

80103f96 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80103f96:	55                   	push   %ebp
80103f97:	89 e5                	mov    %esp,%ebp
80103f99:	56                   	push   %esi
80103f9a:	53                   	push   %ebx
80103f9b:	83 ec 20             	sub    $0x20,%esp
80103f9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80103fa1:	e8 1f f3 ff ff       	call   801032c5 <myproc>
80103fa6:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80103fa8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103fab:	89 44 24 04          	mov    %eax,0x4(%esp)
80103faf:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb2:	89 04 24             	mov    %eax,(%esp)
80103fb5:	e8 b1 ff ff ff       	call   80103f6b <argint>
80103fba:	85 c0                	test   %eax,%eax
80103fbc:	78 1f                	js     80103fdd <argptr+0x47>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80103fbe:	85 db                	test   %ebx,%ebx
80103fc0:	78 22                	js     80103fe4 <argptr+0x4e>
80103fc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fc5:	8b 06                	mov    (%esi),%eax
80103fc7:	39 c2                	cmp    %eax,%edx
80103fc9:	73 20                	jae    80103feb <argptr+0x55>
80103fcb:	01 d3                	add    %edx,%ebx
80103fcd:	39 d8                	cmp    %ebx,%eax
80103fcf:	72 21                	jb     80103ff2 <argptr+0x5c>
    return -1;
  *pp = (char*)i;
80103fd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd4:	89 10                	mov    %edx,(%eax)
  return 0;
80103fd6:	b8 00 00 00 00       	mov    $0x0,%eax
80103fdb:	eb 1a                	jmp    80103ff7 <argptr+0x61>
    return -1;
80103fdd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fe2:	eb 13                	jmp    80103ff7 <argptr+0x61>
    return -1;
80103fe4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fe9:	eb 0c                	jmp    80103ff7 <argptr+0x61>
80103feb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ff0:	eb 05                	jmp    80103ff7 <argptr+0x61>
80103ff2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103ff7:	83 c4 20             	add    $0x20,%esp
80103ffa:	5b                   	pop    %ebx
80103ffb:	5e                   	pop    %esi
80103ffc:	5d                   	pop    %ebp
80103ffd:	c3                   	ret    

80103ffe <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80103ffe:	55                   	push   %ebp
80103fff:	89 e5                	mov    %esp,%ebp
80104001:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104004:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104007:	89 44 24 04          	mov    %eax,0x4(%esp)
8010400b:	8b 45 08             	mov    0x8(%ebp),%eax
8010400e:	89 04 24             	mov    %eax,(%esp)
80104011:	e8 55 ff ff ff       	call   80103f6b <argint>
80104016:	85 c0                	test   %eax,%eax
80104018:	78 14                	js     8010402e <argstr+0x30>
    return -1;
  return fetchstr(addr, pp);
8010401a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010401d:	89 44 24 04          	mov    %eax,0x4(%esp)
80104021:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104024:	89 04 24             	mov    %eax,(%esp)
80104027:	e8 ff fe ff ff       	call   80103f2b <fetchstr>
8010402c:	eb 05                	jmp    80104033 <argstr+0x35>
    return -1;
8010402e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104033:	c9                   	leave  
80104034:	c3                   	ret    

80104035 <syscall>:
[SYS_setwritecount] sys_setwritecount,
};

void
syscall(void)
{
80104035:	55                   	push   %ebp
80104036:	89 e5                	mov    %esp,%ebp
80104038:	56                   	push   %esi
80104039:	53                   	push   %ebx
8010403a:	83 ec 10             	sub    $0x10,%esp
  int num;
  struct proc *curproc = myproc();
8010403d:	e8 83 f2 ff ff       	call   801032c5 <myproc>
80104042:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104044:	8b 70 18             	mov    0x18(%eax),%esi
80104047:	8b 46 1c             	mov    0x1c(%esi),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010404a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010404d:	83 fa 18             	cmp    $0x18,%edx
80104050:	77 12                	ja     80104064 <syscall+0x2f>
80104052:	8b 14 85 80 6d 10 80 	mov    -0x7fef9280(,%eax,4),%edx
80104059:	85 d2                	test   %edx,%edx
8010405b:	74 07                	je     80104064 <syscall+0x2f>
    curproc->tf->eax = syscalls[num]();
8010405d:	ff d2                	call   *%edx
8010405f:	89 46 1c             	mov    %eax,0x1c(%esi)
80104062:	eb 28                	jmp    8010408c <syscall+0x57>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104064:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104067:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010406b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010406f:	8b 43 10             	mov    0x10(%ebx),%eax
80104072:	89 44 24 04          	mov    %eax,0x4(%esp)
80104076:	c7 04 24 49 6d 10 80 	movl   $0x80106d49,(%esp)
8010407d:	e8 45 c5 ff ff       	call   801005c7 <cprintf>
    curproc->tf->eax = -1;
80104082:	8b 43 18             	mov    0x18(%ebx),%eax
80104085:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010408c:	83 c4 10             	add    $0x10,%esp
8010408f:	5b                   	pop    %ebx
80104090:	5e                   	pop    %esi
80104091:	5d                   	pop    %ebp
80104092:	c3                   	ret    
80104093:	66 90                	xchg   %ax,%ax
80104095:	66 90                	xchg   %ax,%ax
80104097:	66 90                	xchg   %ax,%ax
80104099:	66 90                	xchg   %ax,%ax
8010409b:	66 90                	xchg   %ax,%ax
8010409d:	66 90                	xchg   %ax,%ax
8010409f:	90                   	nop

801040a0 <argfd>:
 //initialize counter
// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801040a0:	55                   	push   %ebp
801040a1:	89 e5                	mov    %esp,%ebp
801040a3:	56                   	push   %esi
801040a4:	53                   	push   %ebx
801040a5:	83 ec 20             	sub    $0x20,%esp
801040a8:	89 d6                	mov    %edx,%esi
801040aa:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801040ac:	8d 55 f4             	lea    -0xc(%ebp),%edx
801040af:	89 54 24 04          	mov    %edx,0x4(%esp)
801040b3:	89 04 24             	mov    %eax,(%esp)
801040b6:	e8 b0 fe ff ff       	call   80103f6b <argint>
801040bb:	85 c0                	test   %eax,%eax
801040bd:	78 29                	js     801040e8 <argfd+0x48>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801040bf:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801040c3:	77 2a                	ja     801040ef <argfd+0x4f>
801040c5:	e8 fb f1 ff ff       	call   801032c5 <myproc>
801040ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040cd:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
801040d1:	85 c0                	test   %eax,%eax
801040d3:	74 21                	je     801040f6 <argfd+0x56>
    return -1;
  if(pfd)
801040d5:	85 f6                	test   %esi,%esi
801040d7:	74 02                	je     801040db <argfd+0x3b>
    *pfd = fd;
801040d9:	89 16                	mov    %edx,(%esi)
  if(pf)
801040db:	85 db                	test   %ebx,%ebx
801040dd:	74 1e                	je     801040fd <argfd+0x5d>
    *pf = f;
801040df:	89 03                	mov    %eax,(%ebx)
  return 0;
801040e1:	b8 00 00 00 00       	mov    $0x0,%eax
801040e6:	eb 1a                	jmp    80104102 <argfd+0x62>
    return -1;
801040e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040ed:	eb 13                	jmp    80104102 <argfd+0x62>
    return -1;
801040ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040f4:	eb 0c                	jmp    80104102 <argfd+0x62>
801040f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040fb:	eb 05                	jmp    80104102 <argfd+0x62>
  return 0;
801040fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104102:	83 c4 20             	add    $0x20,%esp
80104105:	5b                   	pop    %ebx
80104106:	5e                   	pop    %esi
80104107:	5d                   	pop    %ebp
80104108:	c3                   	ret    

80104109 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104109:	55                   	push   %ebp
8010410a:	89 e5                	mov    %esp,%ebp
8010410c:	53                   	push   %ebx
8010410d:	83 ec 04             	sub    $0x4,%esp
80104110:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
80104112:	e8 ae f1 ff ff       	call   801032c5 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
80104117:	ba 00 00 00 00       	mov    $0x0,%edx
8010411c:	eb 12                	jmp    80104130 <fdalloc+0x27>
    if(curproc->ofile[fd] == 0){
8010411e:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
80104123:	75 08                	jne    8010412d <fdalloc+0x24>
      curproc->ofile[fd] = f;
80104125:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
80104129:	89 d0                	mov    %edx,%eax
8010412b:	eb 0d                	jmp    8010413a <fdalloc+0x31>
  for(fd = 0; fd < NOFILE; fd++){
8010412d:	83 c2 01             	add    $0x1,%edx
80104130:	83 fa 0f             	cmp    $0xf,%edx
80104133:	7e e9                	jle    8010411e <fdalloc+0x15>
    }
  }
  return -1;
80104135:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010413a:	83 c4 04             	add    $0x4,%esp
8010413d:	5b                   	pop    %ebx
8010413e:	5d                   	pop    %ebp
8010413f:	c3                   	ret    

80104140 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80104140:	55                   	push   %ebp
80104141:	89 e5                	mov    %esp,%ebp
80104143:	57                   	push   %edi
80104144:	56                   	push   %esi
80104145:	53                   	push   %ebx
80104146:	83 ec 2c             	sub    $0x2c,%esp
80104149:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010414b:	b8 20 00 00 00       	mov    $0x20,%eax
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104150:	8d 7d d8             	lea    -0x28(%ebp),%edi
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104153:	eb 33                	jmp    80104188 <isdirempty+0x48>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104155:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010415c:	00 
8010415d:	89 44 24 08          	mov    %eax,0x8(%esp)
80104161:	89 7c 24 04          	mov    %edi,0x4(%esp)
80104165:	89 1c 24             	mov    %ebx,(%esp)
80104168:	e8 71 d6 ff ff       	call   801017de <readi>
8010416d:	83 f8 10             	cmp    $0x10,%eax
80104170:	74 0c                	je     8010417e <isdirempty+0x3e>
      panic("isdirempty: readi");
80104172:	c7 04 24 e8 6d 10 80 	movl   $0x80106de8,(%esp)
80104179:	e8 a7 c1 ff ff       	call   80100325 <panic>
    if(de.inum != 0)
8010417e:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80104183:	75 11                	jne    80104196 <isdirempty+0x56>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104185:	8d 46 10             	lea    0x10(%esi),%eax
80104188:	89 c6                	mov    %eax,%esi
8010418a:	3b 43 58             	cmp    0x58(%ebx),%eax
8010418d:	72 c6                	jb     80104155 <isdirempty+0x15>
      return 0;
  }
  return 1;
8010418f:	b8 01 00 00 00       	mov    $0x1,%eax
80104194:	eb 05                	jmp    8010419b <isdirempty+0x5b>
      return 0;
80104196:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010419b:	83 c4 2c             	add    $0x2c,%esp
8010419e:	5b                   	pop    %ebx
8010419f:	5e                   	pop    %esi
801041a0:	5f                   	pop    %edi
801041a1:	5d                   	pop    %ebp
801041a2:	c3                   	ret    

801041a3 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
801041a3:	55                   	push   %ebp
801041a4:	89 e5                	mov    %esp,%ebp
801041a6:	57                   	push   %edi
801041a7:	56                   	push   %esi
801041a8:	53                   	push   %ebx
801041a9:	83 ec 3c             	sub    $0x3c,%esp
801041ac:	89 d7                	mov    %edx,%edi
801041ae:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
801041b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
801041b4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801041b7:	8d 55 da             	lea    -0x26(%ebp),%edx
801041ba:	89 54 24 04          	mov    %edx,0x4(%esp)
801041be:	89 04 24             	mov    %eax,(%esp)
801041c1:	e8 d4 da ff ff       	call   80101c9a <nameiparent>
801041c6:	89 c3                	mov    %eax,%ebx
801041c8:	85 c0                	test   %eax,%eax
801041ca:	0f 84 28 01 00 00    	je     801042f8 <create+0x155>
    return 0;
  ilock(dp);
801041d0:	89 04 24             	mov    %eax,(%esp)
801041d3:	e8 29 d4 ff ff       	call   80101601 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
801041d8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801041df:	00 
801041e0:	8d 45 da             	lea    -0x26(%ebp),%eax
801041e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801041e7:	89 1c 24             	mov    %ebx,(%esp)
801041ea:	e8 49 d8 ff ff       	call   80101a38 <dirlookup>
801041ef:	89 c6                	mov    %eax,%esi
801041f1:	85 c0                	test   %eax,%eax
801041f3:	74 33                	je     80104228 <create+0x85>
    iunlockput(dp);
801041f5:	89 1c 24             	mov    %ebx,(%esp)
801041f8:	e8 96 d5 ff ff       	call   80101793 <iunlockput>
    ilock(ip);
801041fd:	89 34 24             	mov    %esi,(%esp)
80104200:	e8 fc d3 ff ff       	call   80101601 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104205:	66 83 ff 02          	cmp    $0x2,%di
80104209:	75 0b                	jne    80104216 <create+0x73>
8010420b:	66 83 7e 50 02       	cmpw   $0x2,0x50(%esi)
80104210:	0f 84 e9 00 00 00    	je     801042ff <create+0x15c>
      return ip;
    iunlockput(ip);
80104216:	89 34 24             	mov    %esi,(%esp)
80104219:	e8 75 d5 ff ff       	call   80101793 <iunlockput>
    return 0;
8010421e:	b8 00 00 00 00       	mov    $0x0,%eax
80104223:	e9 d9 00 00 00       	jmp    80104301 <create+0x15e>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80104228:	0f bf d7             	movswl %di,%edx
8010422b:	8b 03                	mov    (%ebx),%eax
8010422d:	89 54 24 04          	mov    %edx,0x4(%esp)
80104231:	89 04 24             	mov    %eax,(%esp)
80104234:	e8 c3 d1 ff ff       	call   801013fc <ialloc>
80104239:	89 c6                	mov    %eax,%esi
8010423b:	85 c0                	test   %eax,%eax
8010423d:	75 0c                	jne    8010424b <create+0xa8>
    panic("create: ialloc");
8010423f:	c7 04 24 fa 6d 10 80 	movl   $0x80106dfa,(%esp)
80104246:	e8 da c0 ff ff       	call   80100325 <panic>

  ilock(ip);
8010424b:	89 04 24             	mov    %eax,(%esp)
8010424e:	e8 ae d3 ff ff       	call   80101601 <ilock>
  ip->major = major;
80104253:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
80104257:	66 89 46 52          	mov    %ax,0x52(%esi)
  ip->minor = minor;
8010425b:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
8010425f:	66 89 46 54          	mov    %ax,0x54(%esi)
  ip->nlink = 1;
80104263:	66 c7 46 56 01 00    	movw   $0x1,0x56(%esi)
  iupdate(ip);
80104269:	89 34 24             	mov    %esi,(%esp)
8010426c:	e8 33 d2 ff ff       	call   801014a4 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80104271:	66 83 ff 01          	cmp    $0x1,%di
80104275:	75 4f                	jne    801042c6 <create+0x123>
    dp->nlink++;  // for ".."
80104277:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
    iupdate(dp);
8010427c:	89 1c 24             	mov    %ebx,(%esp)
8010427f:	e8 20 d2 ff ff       	call   801014a4 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104284:	8b 46 04             	mov    0x4(%esi),%eax
80104287:	89 44 24 08          	mov    %eax,0x8(%esp)
8010428b:	c7 44 24 04 0a 6e 10 	movl   $0x80106e0a,0x4(%esp)
80104292:	80 
80104293:	89 34 24             	mov    %esi,(%esp)
80104296:	e8 10 d9 ff ff       	call   80101bab <dirlink>
8010429b:	85 c0                	test   %eax,%eax
8010429d:	78 1b                	js     801042ba <create+0x117>
8010429f:	8b 43 04             	mov    0x4(%ebx),%eax
801042a2:	89 44 24 08          	mov    %eax,0x8(%esp)
801042a6:	c7 44 24 04 09 6e 10 	movl   $0x80106e09,0x4(%esp)
801042ad:	80 
801042ae:	89 34 24             	mov    %esi,(%esp)
801042b1:	e8 f5 d8 ff ff       	call   80101bab <dirlink>
801042b6:	85 c0                	test   %eax,%eax
801042b8:	79 0c                	jns    801042c6 <create+0x123>
      panic("create dots");
801042ba:	c7 04 24 0c 6e 10 80 	movl   $0x80106e0c,(%esp)
801042c1:	e8 5f c0 ff ff       	call   80100325 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801042c6:	8b 46 04             	mov    0x4(%esi),%eax
801042c9:	89 44 24 08          	mov    %eax,0x8(%esp)
801042cd:	8d 45 da             	lea    -0x26(%ebp),%eax
801042d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801042d4:	89 1c 24             	mov    %ebx,(%esp)
801042d7:	e8 cf d8 ff ff       	call   80101bab <dirlink>
801042dc:	85 c0                	test   %eax,%eax
801042de:	79 0c                	jns    801042ec <create+0x149>
    panic("create: dirlink");
801042e0:	c7 04 24 18 6e 10 80 	movl   $0x80106e18,(%esp)
801042e7:	e8 39 c0 ff ff       	call   80100325 <panic>

  iunlockput(dp);
801042ec:	89 1c 24             	mov    %ebx,(%esp)
801042ef:	e8 9f d4 ff ff       	call   80101793 <iunlockput>

  return ip;
801042f4:	89 f0                	mov    %esi,%eax
801042f6:	eb 09                	jmp    80104301 <create+0x15e>
    return 0;
801042f8:	b8 00 00 00 00       	mov    $0x0,%eax
801042fd:	eb 02                	jmp    80104301 <create+0x15e>
      return ip;
801042ff:	89 f0                	mov    %esi,%eax
}
80104301:	83 c4 3c             	add    $0x3c,%esp
80104304:	5b                   	pop    %ebx
80104305:	5e                   	pop    %esi
80104306:	5f                   	pop    %edi
80104307:	5d                   	pop    %ebp
80104308:	c3                   	ret    

80104309 <sys_dup>:
{
80104309:	55                   	push   %ebp
8010430a:	89 e5                	mov    %esp,%ebp
8010430c:	53                   	push   %ebx
8010430d:	83 ec 24             	sub    $0x24,%esp
  if(argfd(0, 0, &f) < 0)
80104310:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104313:	ba 00 00 00 00       	mov    $0x0,%edx
80104318:	b8 00 00 00 00       	mov    $0x0,%eax
8010431d:	e8 7e fd ff ff       	call   801040a0 <argfd>
80104322:	85 c0                	test   %eax,%eax
80104324:	78 1d                	js     80104343 <sys_dup+0x3a>
  if((fd=fdalloc(f)) < 0)
80104326:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104329:	e8 db fd ff ff       	call   80104109 <fdalloc>
8010432e:	89 c3                	mov    %eax,%ebx
80104330:	85 c0                	test   %eax,%eax
80104332:	78 16                	js     8010434a <sys_dup+0x41>
  filedup(f);
80104334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104337:	89 04 24             	mov    %eax,(%esp)
8010433a:	e8 96 c9 ff ff       	call   80100cd5 <filedup>
  return fd;
8010433f:	89 d8                	mov    %ebx,%eax
80104341:	eb 0c                	jmp    8010434f <sys_dup+0x46>
    return -1;
80104343:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104348:	eb 05                	jmp    8010434f <sys_dup+0x46>
    return -1;
8010434a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010434f:	83 c4 24             	add    $0x24,%esp
80104352:	5b                   	pop    %ebx
80104353:	5d                   	pop    %ebp
80104354:	c3                   	ret    

80104355 <sys_read>:
{
80104355:	55                   	push   %ebp
80104356:	89 e5                	mov    %esp,%ebp
80104358:	83 ec 28             	sub    $0x28,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010435b:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010435e:	ba 00 00 00 00       	mov    $0x0,%edx
80104363:	b8 00 00 00 00       	mov    $0x0,%eax
80104368:	e8 33 fd ff ff       	call   801040a0 <argfd>
8010436d:	85 c0                	test   %eax,%eax
8010436f:	78 50                	js     801043c1 <sys_read+0x6c>
80104371:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104374:	89 44 24 04          	mov    %eax,0x4(%esp)
80104378:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010437f:	e8 e7 fb ff ff       	call   80103f6b <argint>
80104384:	85 c0                	test   %eax,%eax
80104386:	78 40                	js     801043c8 <sys_read+0x73>
80104388:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010438b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010438f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104392:	89 44 24 04          	mov    %eax,0x4(%esp)
80104396:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010439d:	e8 f4 fb ff ff       	call   80103f96 <argptr>
801043a2:	85 c0                	test   %eax,%eax
801043a4:	78 29                	js     801043cf <sys_read+0x7a>
  return fileread(f, p, n);
801043a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043a9:	89 44 24 08          	mov    %eax,0x8(%esp)
801043ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043b0:	89 44 24 04          	mov    %eax,0x4(%esp)
801043b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b7:	89 04 24             	mov    %eax,(%esp)
801043ba:	e8 56 ca ff ff       	call   80100e15 <fileread>
801043bf:	eb 13                	jmp    801043d4 <sys_read+0x7f>
    return -1;
801043c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043c6:	eb 0c                	jmp    801043d4 <sys_read+0x7f>
801043c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043cd:	eb 05                	jmp    801043d4 <sys_read+0x7f>
801043cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801043d4:	c9                   	leave  
801043d5:	c3                   	ret    

801043d6 <sys_write>:
{
801043d6:	55                   	push   %ebp
801043d7:	89 e5                	mov    %esp,%ebp
801043d9:	83 ec 28             	sub    $0x28,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0){
801043dc:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801043df:	ba 00 00 00 00       	mov    $0x0,%edx
801043e4:	b8 00 00 00 00       	mov    $0x0,%eax
801043e9:	e8 b2 fc ff ff       	call   801040a0 <argfd>
801043ee:	85 c0                	test   %eax,%eax
801043f0:	78 5d                	js     8010444f <sys_write+0x79>
801043f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801043f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801043f9:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80104400:	e8 66 fb ff ff       	call   80103f6b <argint>
80104405:	85 c0                	test   %eax,%eax
80104407:	78 4d                	js     80104456 <sys_write+0x80>
80104409:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010440c:	89 44 24 08          	mov    %eax,0x8(%esp)
80104410:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104413:	89 44 24 04          	mov    %eax,0x4(%esp)
80104417:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010441e:	e8 73 fb ff ff       	call   80103f96 <argptr>
80104423:	85 c0                	test   %eax,%eax
80104425:	78 36                	js     8010445d <sys_write+0x87>
    filewrite(f, p, n);
80104427:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010442a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010442e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104431:	89 44 24 04          	mov    %eax,0x4(%esp)
80104435:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104438:	89 04 24             	mov    %eax,(%esp)
8010443b:	e8 68 ca ff ff       	call   80100ea8 <filewrite>
    counter+= 1;  // Increment the write counter for writes
80104440:	a1 bc a5 10 80       	mov    0x8010a5bc,%eax
80104445:	83 c0 01             	add    $0x1,%eax
80104448:	a3 bc a5 10 80       	mov    %eax,0x8010a5bc
    return counter ;
8010444d:	eb 13                	jmp    80104462 <sys_write+0x8c>
        return -1;
8010444f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104454:	eb 0c                	jmp    80104462 <sys_write+0x8c>
80104456:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010445b:	eb 05                	jmp    80104462 <sys_write+0x8c>
8010445d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104462:	c9                   	leave  
80104463:	c3                   	ret    

80104464 <sys_close>:
{
80104464:	55                   	push   %ebp
80104465:	89 e5                	mov    %esp,%ebp
80104467:	83 ec 28             	sub    $0x28,%esp
  if(argfd(0, &fd, &f) < 0)
8010446a:	8d 4d f0             	lea    -0x10(%ebp),%ecx
8010446d:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104470:	b8 00 00 00 00       	mov    $0x0,%eax
80104475:	e8 26 fc ff ff       	call   801040a0 <argfd>
8010447a:	85 c0                	test   %eax,%eax
8010447c:	78 22                	js     801044a0 <sys_close+0x3c>
  myproc()->ofile[fd] = 0;
8010447e:	e8 42 ee ff ff       	call   801032c5 <myproc>
80104483:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104486:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
8010448d:	00 
  fileclose(f);
8010448e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104491:	89 04 24             	mov    %eax,(%esp)
80104494:	e8 7f c8 ff ff       	call   80100d18 <fileclose>
  return 0;
80104499:	b8 00 00 00 00       	mov    $0x0,%eax
8010449e:	eb 05                	jmp    801044a5 <sys_close+0x41>
    return -1;
801044a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801044a5:	c9                   	leave  
801044a6:	c3                   	ret    

801044a7 <sys_fstat>:
{
801044a7:	55                   	push   %ebp
801044a8:	89 e5                	mov    %esp,%ebp
801044aa:	83 ec 28             	sub    $0x28,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801044ad:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801044b0:	ba 00 00 00 00       	mov    $0x0,%edx
801044b5:	b8 00 00 00 00       	mov    $0x0,%eax
801044ba:	e8 e1 fb ff ff       	call   801040a0 <argfd>
801044bf:	85 c0                	test   %eax,%eax
801044c1:	78 33                	js     801044f6 <sys_fstat+0x4f>
801044c3:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801044ca:	00 
801044cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801044ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801044d2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801044d9:	e8 b8 fa ff ff       	call   80103f96 <argptr>
801044de:	85 c0                	test   %eax,%eax
801044e0:	78 1b                	js     801044fd <sys_fstat+0x56>
  return filestat(f, st);
801044e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044e5:	89 44 24 04          	mov    %eax,0x4(%esp)
801044e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ec:	89 04 24             	mov    %eax,(%esp)
801044ef:	e8 d8 c8 ff ff       	call   80100dcc <filestat>
801044f4:	eb 0c                	jmp    80104502 <sys_fstat+0x5b>
    return -1;
801044f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044fb:	eb 05                	jmp    80104502 <sys_fstat+0x5b>
801044fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104502:	c9                   	leave  
80104503:	c3                   	ret    

80104504 <sys_link>:
{
80104504:	55                   	push   %ebp
80104505:	89 e5                	mov    %esp,%ebp
80104507:	56                   	push   %esi
80104508:	53                   	push   %ebx
80104509:	83 ec 30             	sub    $0x30,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010450c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010450f:	89 44 24 04          	mov    %eax,0x4(%esp)
80104513:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010451a:	e8 df fa ff ff       	call   80103ffe <argstr>
8010451f:	85 c0                	test   %eax,%eax
80104521:	0f 88 0a 01 00 00    	js     80104631 <sys_link+0x12d>
80104527:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010452a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010452e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104535:	e8 c4 fa ff ff       	call   80103ffe <argstr>
8010453a:	85 c0                	test   %eax,%eax
8010453c:	0f 88 f6 00 00 00    	js     80104638 <sys_link+0x134>
  begin_op();
80104542:	e8 0c e3 ff ff       	call   80102853 <begin_op>
  if((ip = namei(old)) == 0){
80104547:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010454a:	89 04 24             	mov    %eax,(%esp)
8010454d:	e8 30 d7 ff ff       	call   80101c82 <namei>
80104552:	89 c3                	mov    %eax,%ebx
80104554:	85 c0                	test   %eax,%eax
80104556:	75 0f                	jne    80104567 <sys_link+0x63>
    end_op();
80104558:	e8 69 e3 ff ff       	call   801028c6 <end_op>
    return -1;
8010455d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104562:	e9 d6 00 00 00       	jmp    8010463d <sys_link+0x139>
  ilock(ip);
80104567:	89 04 24             	mov    %eax,(%esp)
8010456a:	e8 92 d0 ff ff       	call   80101601 <ilock>
  if(ip->type == T_DIR){
8010456f:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104574:	75 17                	jne    8010458d <sys_link+0x89>
    iunlockput(ip);
80104576:	89 1c 24             	mov    %ebx,(%esp)
80104579:	e8 15 d2 ff ff       	call   80101793 <iunlockput>
    end_op();
8010457e:	e8 43 e3 ff ff       	call   801028c6 <end_op>
    return -1;
80104583:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104588:	e9 b0 00 00 00       	jmp    8010463d <sys_link+0x139>
  ip->nlink++;
8010458d:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
  iupdate(ip);
80104592:	89 1c 24             	mov    %ebx,(%esp)
80104595:	e8 0a cf ff ff       	call   801014a4 <iupdate>
  iunlock(ip);
8010459a:	89 1c 24             	mov    %ebx,(%esp)
8010459d:	e8 26 d1 ff ff       	call   801016c8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801045a2:	8d 45 ea             	lea    -0x16(%ebp),%eax
801045a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801045a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801045ac:	89 04 24             	mov    %eax,(%esp)
801045af:	e8 e6 d6 ff ff       	call   80101c9a <nameiparent>
801045b4:	89 c6                	mov    %eax,%esi
801045b6:	85 c0                	test   %eax,%eax
801045b8:	74 4e                	je     80104608 <sys_link+0x104>
  ilock(dp);
801045ba:	89 04 24             	mov    %eax,(%esp)
801045bd:	e8 3f d0 ff ff       	call   80101601 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801045c2:	8b 03                	mov    (%ebx),%eax
801045c4:	39 06                	cmp    %eax,(%esi)
801045c6:	75 1a                	jne    801045e2 <sys_link+0xde>
801045c8:	8b 43 04             	mov    0x4(%ebx),%eax
801045cb:	89 44 24 08          	mov    %eax,0x8(%esp)
801045cf:	8d 45 ea             	lea    -0x16(%ebp),%eax
801045d2:	89 44 24 04          	mov    %eax,0x4(%esp)
801045d6:	89 34 24             	mov    %esi,(%esp)
801045d9:	e8 cd d5 ff ff       	call   80101bab <dirlink>
801045de:	85 c0                	test   %eax,%eax
801045e0:	79 0a                	jns    801045ec <sys_link+0xe8>
    iunlockput(dp);
801045e2:	89 34 24             	mov    %esi,(%esp)
801045e5:	e8 a9 d1 ff ff       	call   80101793 <iunlockput>
    goto bad;
801045ea:	eb 1c                	jmp    80104608 <sys_link+0x104>
  iunlockput(dp);
801045ec:	89 34 24             	mov    %esi,(%esp)
801045ef:	e8 9f d1 ff ff       	call   80101793 <iunlockput>
  iput(ip);
801045f4:	89 1c 24             	mov    %ebx,(%esp)
801045f7:	e8 0b d1 ff ff       	call   80101707 <iput>
  end_op();
801045fc:	e8 c5 e2 ff ff       	call   801028c6 <end_op>
  return 0;
80104601:	b8 00 00 00 00       	mov    $0x0,%eax
80104606:	eb 35                	jmp    8010463d <sys_link+0x139>
  ilock(ip);
80104608:	89 1c 24             	mov    %ebx,(%esp)
8010460b:	e8 f1 cf ff ff       	call   80101601 <ilock>
  ip->nlink--;
80104610:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
80104615:	89 1c 24             	mov    %ebx,(%esp)
80104618:	e8 87 ce ff ff       	call   801014a4 <iupdate>
  iunlockput(ip);
8010461d:	89 1c 24             	mov    %ebx,(%esp)
80104620:	e8 6e d1 ff ff       	call   80101793 <iunlockput>
  end_op();
80104625:	e8 9c e2 ff ff       	call   801028c6 <end_op>
  return -1;
8010462a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010462f:	eb 0c                	jmp    8010463d <sys_link+0x139>
    return -1;
80104631:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104636:	eb 05                	jmp    8010463d <sys_link+0x139>
80104638:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010463d:	83 c4 30             	add    $0x30,%esp
80104640:	5b                   	pop    %ebx
80104641:	5e                   	pop    %esi
80104642:	5d                   	pop    %ebp
80104643:	c3                   	ret    

80104644 <sys_unlink>:
{
80104644:	55                   	push   %ebp
80104645:	89 e5                	mov    %esp,%ebp
80104647:	57                   	push   %edi
80104648:	56                   	push   %esi
80104649:	53                   	push   %ebx
8010464a:	83 ec 4c             	sub    $0x4c,%esp
  if(argstr(0, &path) < 0)
8010464d:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104650:	89 44 24 04          	mov    %eax,0x4(%esp)
80104654:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010465b:	e8 9e f9 ff ff       	call   80103ffe <argstr>
80104660:	85 c0                	test   %eax,%eax
80104662:	0f 88 5c 01 00 00    	js     801047c4 <sys_unlink+0x180>
  begin_op();
80104668:	e8 e6 e1 ff ff       	call   80102853 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010466d:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104670:	89 44 24 04          	mov    %eax,0x4(%esp)
80104674:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80104677:	89 04 24             	mov    %eax,(%esp)
8010467a:	e8 1b d6 ff ff       	call   80101c9a <nameiparent>
8010467f:	89 c6                	mov    %eax,%esi
80104681:	85 c0                	test   %eax,%eax
80104683:	75 0f                	jne    80104694 <sys_unlink+0x50>
    end_op();
80104685:	e8 3c e2 ff ff       	call   801028c6 <end_op>
    return -1;
8010468a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010468f:	e9 35 01 00 00       	jmp    801047c9 <sys_unlink+0x185>
  ilock(dp);
80104694:	89 04 24             	mov    %eax,(%esp)
80104697:	e8 65 cf ff ff       	call   80101601 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010469c:	c7 44 24 04 0a 6e 10 	movl   $0x80106e0a,0x4(%esp)
801046a3:	80 
801046a4:	8d 45 ca             	lea    -0x36(%ebp),%eax
801046a7:	89 04 24             	mov    %eax,(%esp)
801046aa:	e8 67 d3 ff ff       	call   80101a16 <namecmp>
801046af:	85 c0                	test   %eax,%eax
801046b1:	0f 84 f9 00 00 00    	je     801047b0 <sys_unlink+0x16c>
801046b7:	c7 44 24 04 09 6e 10 	movl   $0x80106e09,0x4(%esp)
801046be:	80 
801046bf:	8d 45 ca             	lea    -0x36(%ebp),%eax
801046c2:	89 04 24             	mov    %eax,(%esp)
801046c5:	e8 4c d3 ff ff       	call   80101a16 <namecmp>
801046ca:	85 c0                	test   %eax,%eax
801046cc:	0f 84 de 00 00 00    	je     801047b0 <sys_unlink+0x16c>
  if((ip = dirlookup(dp, name, &off)) == 0)
801046d2:	8d 45 c0             	lea    -0x40(%ebp),%eax
801046d5:	89 44 24 08          	mov    %eax,0x8(%esp)
801046d9:	8d 45 ca             	lea    -0x36(%ebp),%eax
801046dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801046e0:	89 34 24             	mov    %esi,(%esp)
801046e3:	e8 50 d3 ff ff       	call   80101a38 <dirlookup>
801046e8:	89 c3                	mov    %eax,%ebx
801046ea:	85 c0                	test   %eax,%eax
801046ec:	0f 84 be 00 00 00    	je     801047b0 <sys_unlink+0x16c>
  ilock(ip);
801046f2:	89 04 24             	mov    %eax,(%esp)
801046f5:	e8 07 cf ff ff       	call   80101601 <ilock>
  if(ip->nlink < 1)
801046fa:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801046ff:	7f 0c                	jg     8010470d <sys_unlink+0xc9>
    panic("unlink: nlink < 1");
80104701:	c7 04 24 28 6e 10 80 	movl   $0x80106e28,(%esp)
80104708:	e8 18 bc ff ff       	call   80100325 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010470d:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104712:	75 18                	jne    8010472c <sys_unlink+0xe8>
80104714:	89 d8                	mov    %ebx,%eax
80104716:	e8 25 fa ff ff       	call   80104140 <isdirempty>
8010471b:	85 c0                	test   %eax,%eax
8010471d:	75 0d                	jne    8010472c <sys_unlink+0xe8>
    iunlockput(ip);
8010471f:	89 1c 24             	mov    %ebx,(%esp)
80104722:	e8 6c d0 ff ff       	call   80101793 <iunlockput>
    goto bad;
80104727:	e9 84 00 00 00       	jmp    801047b0 <sys_unlink+0x16c>
  memset(&de, 0, sizeof(de));
8010472c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104733:	00 
80104734:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010473b:	00 
8010473c:	8d 7d d8             	lea    -0x28(%ebp),%edi
8010473f:	89 3c 24             	mov    %edi,(%esp)
80104742:	e8 c9 f5 ff ff       	call   80103d10 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104747:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010474e:	00 
8010474f:	8b 45 c0             	mov    -0x40(%ebp),%eax
80104752:	89 44 24 08          	mov    %eax,0x8(%esp)
80104756:	89 7c 24 04          	mov    %edi,0x4(%esp)
8010475a:	89 34 24             	mov    %esi,(%esp)
8010475d:	e8 84 d1 ff ff       	call   801018e6 <writei>
80104762:	83 f8 10             	cmp    $0x10,%eax
80104765:	74 0c                	je     80104773 <sys_unlink+0x12f>
    panic("unlink: writei");
80104767:	c7 04 24 3a 6e 10 80 	movl   $0x80106e3a,(%esp)
8010476e:	e8 b2 bb ff ff       	call   80100325 <panic>
  if(ip->type == T_DIR){
80104773:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104778:	75 0d                	jne    80104787 <sys_unlink+0x143>
    dp->nlink--;
8010477a:	66 83 6e 56 01       	subw   $0x1,0x56(%esi)
    iupdate(dp);
8010477f:	89 34 24             	mov    %esi,(%esp)
80104782:	e8 1d cd ff ff       	call   801014a4 <iupdate>
  iunlockput(dp);
80104787:	89 34 24             	mov    %esi,(%esp)
8010478a:	e8 04 d0 ff ff       	call   80101793 <iunlockput>
  ip->nlink--;
8010478f:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
80104794:	89 1c 24             	mov    %ebx,(%esp)
80104797:	e8 08 cd ff ff       	call   801014a4 <iupdate>
  iunlockput(ip);
8010479c:	89 1c 24             	mov    %ebx,(%esp)
8010479f:	e8 ef cf ff ff       	call   80101793 <iunlockput>
  end_op();
801047a4:	e8 1d e1 ff ff       	call   801028c6 <end_op>
  return 0;
801047a9:	b8 00 00 00 00       	mov    $0x0,%eax
801047ae:	eb 19                	jmp    801047c9 <sys_unlink+0x185>
  iunlockput(dp);
801047b0:	89 34 24             	mov    %esi,(%esp)
801047b3:	e8 db cf ff ff       	call   80101793 <iunlockput>
  end_op();
801047b8:	e8 09 e1 ff ff       	call   801028c6 <end_op>
  return -1;
801047bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047c2:	eb 05                	jmp    801047c9 <sys_unlink+0x185>
    return -1;
801047c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801047c9:	83 c4 4c             	add    $0x4c,%esp
801047cc:	5b                   	pop    %ebx
801047cd:	5e                   	pop    %esi
801047ce:	5f                   	pop    %edi
801047cf:	5d                   	pop    %ebp
801047d0:	c3                   	ret    

801047d1 <sys_open>:

int
sys_open(void)
{
801047d1:	55                   	push   %ebp
801047d2:	89 e5                	mov    %esp,%ebp
801047d4:	57                   	push   %edi
801047d5:	56                   	push   %esi
801047d6:	53                   	push   %ebx
801047d7:	83 ec 2c             	sub    $0x2c,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801047da:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801047dd:	89 44 24 04          	mov    %eax,0x4(%esp)
801047e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801047e8:	e8 11 f8 ff ff       	call   80103ffe <argstr>
801047ed:	85 c0                	test   %eax,%eax
801047ef:	0f 88 03 01 00 00    	js     801048f8 <sys_open+0x127>
801047f5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801047f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801047fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104803:	e8 63 f7 ff ff       	call   80103f6b <argint>
80104808:	85 c0                	test   %eax,%eax
8010480a:	0f 88 ef 00 00 00    	js     801048ff <sys_open+0x12e>
    return -1;

  begin_op();
80104810:	e8 3e e0 ff ff       	call   80102853 <begin_op>

  if(omode & O_CREATE){
80104815:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
80104819:	74 2e                	je     80104849 <sys_open+0x78>
    ip = create(path, T_FILE, 0, 0);
8010481b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104822:	b9 00 00 00 00       	mov    $0x0,%ecx
80104827:	ba 02 00 00 00       	mov    $0x2,%edx
8010482c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010482f:	e8 6f f9 ff ff       	call   801041a3 <create>
80104834:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80104836:	85 c0                	test   %eax,%eax
80104838:	75 58                	jne    80104892 <sys_open+0xc1>
      end_op();
8010483a:	e8 87 e0 ff ff       	call   801028c6 <end_op>
      return -1;
8010483f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104844:	e9 bb 00 00 00       	jmp    80104904 <sys_open+0x133>
    }
  } else {
    if((ip = namei(path)) == 0){
80104849:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010484c:	89 04 24             	mov    %eax,(%esp)
8010484f:	e8 2e d4 ff ff       	call   80101c82 <namei>
80104854:	89 c6                	mov    %eax,%esi
80104856:	85 c0                	test   %eax,%eax
80104858:	75 0f                	jne    80104869 <sys_open+0x98>
      end_op();
8010485a:	e8 67 e0 ff ff       	call   801028c6 <end_op>
      return -1;
8010485f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104864:	e9 9b 00 00 00       	jmp    80104904 <sys_open+0x133>
    }
    ilock(ip);
80104869:	89 04 24             	mov    %eax,(%esp)
8010486c:	e8 90 cd ff ff       	call   80101601 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104871:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104876:	75 1a                	jne    80104892 <sys_open+0xc1>
80104878:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010487c:	74 14                	je     80104892 <sys_open+0xc1>
      iunlockput(ip);
8010487e:	89 34 24             	mov    %esi,(%esp)
80104881:	e8 0d cf ff ff       	call   80101793 <iunlockput>
      end_op();
80104886:	e8 3b e0 ff ff       	call   801028c6 <end_op>
      return -1;
8010488b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104890:	eb 72                	jmp    80104904 <sys_open+0x133>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80104892:	e8 e5 c3 ff ff       	call   80100c7c <filealloc>
80104897:	89 c3                	mov    %eax,%ebx
80104899:	85 c0                	test   %eax,%eax
8010489b:	74 0b                	je     801048a8 <sys_open+0xd7>
8010489d:	e8 67 f8 ff ff       	call   80104109 <fdalloc>
801048a2:	89 c7                	mov    %eax,%edi
801048a4:	85 c0                	test   %eax,%eax
801048a6:	79 20                	jns    801048c8 <sys_open+0xf7>
    if(f)
801048a8:	85 db                	test   %ebx,%ebx
801048aa:	74 08                	je     801048b4 <sys_open+0xe3>
      fileclose(f);
801048ac:	89 1c 24             	mov    %ebx,(%esp)
801048af:	e8 64 c4 ff ff       	call   80100d18 <fileclose>
    iunlockput(ip);
801048b4:	89 34 24             	mov    %esi,(%esp)
801048b7:	e8 d7 ce ff ff       	call   80101793 <iunlockput>
    end_op();
801048bc:	e8 05 e0 ff ff       	call   801028c6 <end_op>
    return -1;
801048c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048c6:	eb 3c                	jmp    80104904 <sys_open+0x133>
  }
  iunlock(ip);
801048c8:	89 34 24             	mov    %esi,(%esp)
801048cb:	e8 f8 cd ff ff       	call   801016c8 <iunlock>
  end_op();
801048d0:	e8 f1 df ff ff       	call   801028c6 <end_op>

  f->type = FD_INODE;
801048d5:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
801048db:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
801048de:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
801048e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048e8:	a8 01                	test   $0x1,%al
801048ea:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801048ee:	a8 03                	test   $0x3,%al
801048f0:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
801048f4:	89 f8                	mov    %edi,%eax
801048f6:	eb 0c                	jmp    80104904 <sys_open+0x133>
    return -1;
801048f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048fd:	eb 05                	jmp    80104904 <sys_open+0x133>
801048ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104904:	83 c4 2c             	add    $0x2c,%esp
80104907:	5b                   	pop    %ebx
80104908:	5e                   	pop    %esi
80104909:	5f                   	pop    %edi
8010490a:	5d                   	pop    %ebp
8010490b:	c3                   	ret    

8010490c <sys_mkdir>:

int
sys_mkdir(void)
{
8010490c:	55                   	push   %ebp
8010490d:	89 e5                	mov    %esp,%ebp
8010490f:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104912:	e8 3c df ff ff       	call   80102853 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104917:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010491a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010491e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104925:	e8 d4 f6 ff ff       	call   80103ffe <argstr>
8010492a:	85 c0                	test   %eax,%eax
8010492c:	78 1d                	js     8010494b <sys_mkdir+0x3f>
8010492e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104935:	b9 00 00 00 00       	mov    $0x0,%ecx
8010493a:	ba 01 00 00 00       	mov    $0x1,%edx
8010493f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104942:	e8 5c f8 ff ff       	call   801041a3 <create>
80104947:	85 c0                	test   %eax,%eax
80104949:	75 0c                	jne    80104957 <sys_mkdir+0x4b>
    end_op();
8010494b:	e8 76 df ff ff       	call   801028c6 <end_op>
    return -1;
80104950:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104955:	eb 12                	jmp    80104969 <sys_mkdir+0x5d>
  }
  iunlockput(ip);
80104957:	89 04 24             	mov    %eax,(%esp)
8010495a:	e8 34 ce ff ff       	call   80101793 <iunlockput>
  end_op();
8010495f:	e8 62 df ff ff       	call   801028c6 <end_op>
  return 0;
80104964:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104969:	c9                   	leave  
8010496a:	c3                   	ret    

8010496b <sys_mknod>:

int
sys_mknod(void)
{
8010496b:	55                   	push   %ebp
8010496c:	89 e5                	mov    %esp,%ebp
8010496e:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104971:	e8 dd de ff ff       	call   80102853 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104976:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104979:	89 44 24 04          	mov    %eax,0x4(%esp)
8010497d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104984:	e8 75 f6 ff ff       	call   80103ffe <argstr>
80104989:	85 c0                	test   %eax,%eax
8010498b:	78 4a                	js     801049d7 <sys_mknod+0x6c>
     argint(1, &major) < 0 ||
8010498d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104990:	89 44 24 04          	mov    %eax,0x4(%esp)
80104994:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010499b:	e8 cb f5 ff ff       	call   80103f6b <argint>
  if((argstr(0, &path)) < 0 ||
801049a0:	85 c0                	test   %eax,%eax
801049a2:	78 33                	js     801049d7 <sys_mknod+0x6c>
     argint(2, &minor) < 0 ||
801049a4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801049a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801049ab:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801049b2:	e8 b4 f5 ff ff       	call   80103f6b <argint>
     argint(1, &major) < 0 ||
801049b7:	85 c0                	test   %eax,%eax
801049b9:	78 1c                	js     801049d7 <sys_mknod+0x6c>
     (ip = create(path, T_DEV, major, minor)) == 0){
801049bb:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
801049bf:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
801049c3:	89 04 24             	mov    %eax,(%esp)
801049c6:	ba 03 00 00 00       	mov    $0x3,%edx
801049cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ce:	e8 d0 f7 ff ff       	call   801041a3 <create>
801049d3:	85 c0                	test   %eax,%eax
801049d5:	75 0c                	jne    801049e3 <sys_mknod+0x78>
    end_op();
801049d7:	e8 ea de ff ff       	call   801028c6 <end_op>
    return -1;
801049dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049e1:	eb 12                	jmp    801049f5 <sys_mknod+0x8a>
  }
  iunlockput(ip);
801049e3:	89 04 24             	mov    %eax,(%esp)
801049e6:	e8 a8 cd ff ff       	call   80101793 <iunlockput>
  end_op();
801049eb:	e8 d6 de ff ff       	call   801028c6 <end_op>
  return 0;
801049f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801049f5:	c9                   	leave  
801049f6:	c3                   	ret    

801049f7 <sys_chdir>:

int
sys_chdir(void)
{
801049f7:	55                   	push   %ebp
801049f8:	89 e5                	mov    %esp,%ebp
801049fa:	56                   	push   %esi
801049fb:	53                   	push   %ebx
801049fc:	83 ec 20             	sub    $0x20,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801049ff:	e8 c1 e8 ff ff       	call   801032c5 <myproc>
80104a04:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104a06:	e8 48 de ff ff       	call   80102853 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104a0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a0e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104a19:	e8 e0 f5 ff ff       	call   80103ffe <argstr>
80104a1e:	85 c0                	test   %eax,%eax
80104a20:	78 11                	js     80104a33 <sys_chdir+0x3c>
80104a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a25:	89 04 24             	mov    %eax,(%esp)
80104a28:	e8 55 d2 ff ff       	call   80101c82 <namei>
80104a2d:	89 c3                	mov    %eax,%ebx
80104a2f:	85 c0                	test   %eax,%eax
80104a31:	75 0c                	jne    80104a3f <sys_chdir+0x48>
    end_op();
80104a33:	e8 8e de ff ff       	call   801028c6 <end_op>
    return -1;
80104a38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a3d:	eb 43                	jmp    80104a82 <sys_chdir+0x8b>
  }
  ilock(ip);
80104a3f:	89 04 24             	mov    %eax,(%esp)
80104a42:	e8 ba cb ff ff       	call   80101601 <ilock>
  if(ip->type != T_DIR){
80104a47:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104a4c:	74 14                	je     80104a62 <sys_chdir+0x6b>
    iunlockput(ip);
80104a4e:	89 1c 24             	mov    %ebx,(%esp)
80104a51:	e8 3d cd ff ff       	call   80101793 <iunlockput>
    end_op();
80104a56:	e8 6b de ff ff       	call   801028c6 <end_op>
    return -1;
80104a5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a60:	eb 20                	jmp    80104a82 <sys_chdir+0x8b>
  }
  iunlock(ip);
80104a62:	89 1c 24             	mov    %ebx,(%esp)
80104a65:	e8 5e cc ff ff       	call   801016c8 <iunlock>
  iput(curproc->cwd);
80104a6a:	8b 46 68             	mov    0x68(%esi),%eax
80104a6d:	89 04 24             	mov    %eax,(%esp)
80104a70:	e8 92 cc ff ff       	call   80101707 <iput>
  end_op();
80104a75:	e8 4c de ff ff       	call   801028c6 <end_op>
  curproc->cwd = ip;
80104a7a:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104a7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a82:	83 c4 20             	add    $0x20,%esp
80104a85:	5b                   	pop    %ebx
80104a86:	5e                   	pop    %esi
80104a87:	5d                   	pop    %ebp
80104a88:	c3                   	ret    

80104a89 <sys_exec>:

int
sys_exec(void)
{
80104a89:	55                   	push   %ebp
80104a8a:	89 e5                	mov    %esp,%ebp
80104a8c:	56                   	push   %esi
80104a8d:	53                   	push   %ebx
80104a8e:	81 ec a0 00 00 00    	sub    $0xa0,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104a94:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a97:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104aa2:	e8 57 f5 ff ff       	call   80103ffe <argstr>
80104aa7:	85 c0                	test   %eax,%eax
80104aa9:	0f 88 ad 00 00 00    	js     80104b5c <sys_exec+0xd3>
80104aaf:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104ab5:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ab9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104ac0:	e8 a6 f4 ff ff       	call   80103f6b <argint>
80104ac5:	85 c0                	test   %eax,%eax
80104ac7:	0f 88 96 00 00 00    	js     80104b63 <sys_exec+0xda>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104acd:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80104ad4:	00 
80104ad5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104adc:	00 
80104add:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104ae3:	89 04 24             	mov    %eax,(%esp)
80104ae6:	e8 25 f2 ff ff       	call   80103d10 <memset>
  for(i=0;; i++){
80104aeb:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104af0:	8d b5 6c ff ff ff    	lea    -0x94(%ebp),%esi
    if(i >= NELEM(argv))
80104af6:	83 fb 1f             	cmp    $0x1f,%ebx
80104af9:	77 6f                	ja     80104b6a <sys_exec+0xe1>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104afb:	89 74 24 04          	mov    %esi,0x4(%esp)
80104aff:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104b05:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104b08:	89 04 24             	mov    %eax,(%esp)
80104b0b:	e8 df f3 ff ff       	call   80103eef <fetchint>
80104b10:	85 c0                	test   %eax,%eax
80104b12:	78 5d                	js     80104b71 <sys_exec+0xe8>
      return -1;
    if(uarg == 0){
80104b14:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104b1a:	85 c0                	test   %eax,%eax
80104b1c:	75 22                	jne    80104b40 <sys_exec+0xb7>
      argv[i] = 0;
80104b1e:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104b25:	00 00 00 00 
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80104b29:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b36:	89 04 24             	mov    %eax,(%esp)
80104b39:	e8 4d bd ff ff       	call   8010088b <exec>
80104b3e:	eb 3d                	jmp    80104b7d <sys_exec+0xf4>
    if(fetchstr(uarg, &argv[i]) < 0)
80104b40:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104b47:	89 54 24 04          	mov    %edx,0x4(%esp)
80104b4b:	89 04 24             	mov    %eax,(%esp)
80104b4e:	e8 d8 f3 ff ff       	call   80103f2b <fetchstr>
80104b53:	85 c0                	test   %eax,%eax
80104b55:	78 21                	js     80104b78 <sys_exec+0xef>
  for(i=0;; i++){
80104b57:	83 c3 01             	add    $0x1,%ebx
  }
80104b5a:	eb 9a                	jmp    80104af6 <sys_exec+0x6d>
    return -1;
80104b5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b61:	eb 1a                	jmp    80104b7d <sys_exec+0xf4>
80104b63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b68:	eb 13                	jmp    80104b7d <sys_exec+0xf4>
      return -1;
80104b6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b6f:	eb 0c                	jmp    80104b7d <sys_exec+0xf4>
      return -1;
80104b71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b76:	eb 05                	jmp    80104b7d <sys_exec+0xf4>
      return -1;
80104b78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104b7d:	81 c4 a0 00 00 00    	add    $0xa0,%esp
80104b83:	5b                   	pop    %ebx
80104b84:	5e                   	pop    %esi
80104b85:	5d                   	pop    %ebp
80104b86:	c3                   	ret    

80104b87 <sys_pipe>:

int
sys_pipe(void)
{
80104b87:	55                   	push   %ebp
80104b88:	89 e5                	mov    %esp,%ebp
80104b8a:	53                   	push   %ebx
80104b8b:	83 ec 24             	sub    $0x24,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104b8e:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80104b95:	00 
80104b96:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b99:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104ba4:	e8 ed f3 ff ff       	call   80103f96 <argptr>
80104ba9:	85 c0                	test   %eax,%eax
80104bab:	78 70                	js     80104c1d <sys_pipe+0x96>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104bad:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104bb0:	89 44 24 04          	mov    %eax,0x4(%esp)
80104bb4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104bb7:	89 04 24             	mov    %eax,(%esp)
80104bba:	e8 51 e2 ff ff       	call   80102e10 <pipealloc>
80104bbf:	85 c0                	test   %eax,%eax
80104bc1:	78 61                	js     80104c24 <sys_pipe+0x9d>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104bc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bc6:	e8 3e f5 ff ff       	call   80104109 <fdalloc>
80104bcb:	89 c3                	mov    %eax,%ebx
80104bcd:	85 c0                	test   %eax,%eax
80104bcf:	78 0c                	js     80104bdd <sys_pipe+0x56>
80104bd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104bd4:	e8 30 f5 ff ff       	call   80104109 <fdalloc>
80104bd9:	85 c0                	test   %eax,%eax
80104bdb:	79 2e                	jns    80104c0b <sys_pipe+0x84>
    if(fd0 >= 0)
80104bdd:	85 db                	test   %ebx,%ebx
80104bdf:	78 0d                	js     80104bee <sys_pipe+0x67>
      myproc()->ofile[fd0] = 0;
80104be1:	e8 df e6 ff ff       	call   801032c5 <myproc>
80104be6:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104bed:	00 
    fileclose(rf);
80104bee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bf1:	89 04 24             	mov    %eax,(%esp)
80104bf4:	e8 1f c1 ff ff       	call   80100d18 <fileclose>
    fileclose(wf);
80104bf9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104bfc:	89 04 24             	mov    %eax,(%esp)
80104bff:	e8 14 c1 ff ff       	call   80100d18 <fileclose>
    return -1;
80104c04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c09:	eb 1e                	jmp    80104c29 <sys_pipe+0xa2>
  }
  fd[0] = fd0;
80104c0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c0e:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104c10:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c13:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104c16:	b8 00 00 00 00       	mov    $0x0,%eax
80104c1b:	eb 0c                	jmp    80104c29 <sys_pipe+0xa2>
    return -1;
80104c1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c22:	eb 05                	jmp    80104c29 <sys_pipe+0xa2>
    return -1;
80104c24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c29:	83 c4 24             	add    $0x24,%esp
80104c2c:	5b                   	pop    %ebx
80104c2d:	5d                   	pop    %ebp
80104c2e:	c3                   	ret    

80104c2f <sys_writecount>:

int
sys_writecount(void){
80104c2f:	55                   	push   %ebp
80104c30:	89 e5                	mov    %esp,%ebp

  return counter;
}
80104c32:	a1 bc a5 10 80       	mov    0x8010a5bc,%eax
80104c37:	5d                   	pop    %ebp
80104c38:	c3                   	ret    

80104c39 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104c39:	55                   	push   %ebp
80104c3a:	89 e5                	mov    %esp,%ebp
80104c3c:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104c3f:	e8 12 e8 ff ff       	call   80103456 <fork>
}
80104c44:	c9                   	leave  
80104c45:	c3                   	ret    

80104c46 <sys_exit>:

int
sys_exit(void)
{
80104c46:	55                   	push   %ebp
80104c47:	89 e5                	mov    %esp,%ebp
80104c49:	83 ec 08             	sub    $0x8,%esp
  exit();
80104c4c:	e8 2d ea ff ff       	call   8010367e <exit>
  return 0;  // not reached
}
80104c51:	b8 00 00 00 00       	mov    $0x0,%eax
80104c56:	c9                   	leave  
80104c57:	c3                   	ret    

80104c58 <sys_wait>:

int
sys_wait(void)
{
80104c58:	55                   	push   %ebp
80104c59:	89 e5                	mov    %esp,%ebp
80104c5b:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104c5e:	e8 92 eb ff ff       	call   801037f5 <wait>
}
80104c63:	c9                   	leave  
80104c64:	c3                   	ret    

80104c65 <sys_kill>:

int
sys_kill(void)
{
80104c65:	55                   	push   %ebp
80104c66:	89 e5                	mov    %esp,%ebp
80104c68:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104c6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c6e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c72:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104c79:	e8 ed f2 ff ff       	call   80103f6b <argint>
80104c7e:	85 c0                	test   %eax,%eax
80104c80:	78 0d                	js     80104c8f <sys_kill+0x2a>
    return -1;
  return kill(pid);
80104c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c85:	89 04 24             	mov    %eax,(%esp)
80104c88:	e8 5b ec ff ff       	call   801038e8 <kill>
80104c8d:	eb 05                	jmp    80104c94 <sys_kill+0x2f>
    return -1;
80104c8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c94:	c9                   	leave  
80104c95:	c3                   	ret    

80104c96 <sys_getpid>:

int
sys_getpid(void)
{
80104c96:	55                   	push   %ebp
80104c97:	89 e5                	mov    %esp,%ebp
80104c99:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104c9c:	e8 24 e6 ff ff       	call   801032c5 <myproc>
80104ca1:	8b 40 10             	mov    0x10(%eax),%eax
}
80104ca4:	c9                   	leave  
80104ca5:	c3                   	ret    

80104ca6 <sys_sbrk>:

int
sys_sbrk(void)
{
80104ca6:	55                   	push   %ebp
80104ca7:	89 e5                	mov    %esp,%ebp
80104ca9:	53                   	push   %ebx
80104caa:	83 ec 24             	sub    $0x24,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104cad:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104cb0:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cb4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104cbb:	e8 ab f2 ff ff       	call   80103f6b <argint>
80104cc0:	85 c0                	test   %eax,%eax
80104cc2:	78 1d                	js     80104ce1 <sys_sbrk+0x3b>
    return -1;
  addr = myproc()->sz;
80104cc4:	e8 fc e5 ff ff       	call   801032c5 <myproc>
80104cc9:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104ccb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cce:	89 14 24             	mov    %edx,(%esp)
80104cd1:	e8 0c e7 ff ff       	call   801033e2 <growproc>
80104cd6:	85 c0                	test   %eax,%eax
80104cd8:	79 0e                	jns    80104ce8 <sys_sbrk+0x42>
    return -1;
80104cda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cdf:	eb 09                	jmp    80104cea <sys_sbrk+0x44>
    return -1;
80104ce1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ce6:	eb 02                	jmp    80104cea <sys_sbrk+0x44>
  return addr;
80104ce8:	89 d8                	mov    %ebx,%eax
}
80104cea:	83 c4 24             	add    $0x24,%esp
80104ced:	5b                   	pop    %ebx
80104cee:	5d                   	pop    %ebp
80104cef:	c3                   	ret    

80104cf0 <sys_sleep>:

int
sys_sleep(void)
{
80104cf0:	55                   	push   %ebp
80104cf1:	89 e5                	mov    %esp,%ebp
80104cf3:	53                   	push   %ebx
80104cf4:	83 ec 24             	sub    $0x24,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104cf7:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104cfa:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cfe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104d05:	e8 61 f2 ff ff       	call   80103f6b <argint>
80104d0a:	85 c0                	test   %eax,%eax
80104d0c:	78 65                	js     80104d73 <sys_sleep+0x83>
    return -1;
  acquire(&tickslock);
80104d0e:	c7 04 24 80 4c 11 80 	movl   $0x80114c80,(%esp)
80104d15:	e8 42 ef ff ff       	call   80103c5c <acquire>
  ticks0 = ticks;
80104d1a:	8b 1d c0 54 11 80    	mov    0x801154c0,%ebx
  while(ticks - ticks0 < n){
80104d20:	eb 32                	jmp    80104d54 <sys_sleep+0x64>
    if(myproc()->killed){
80104d22:	e8 9e e5 ff ff       	call   801032c5 <myproc>
80104d27:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104d2b:	74 13                	je     80104d40 <sys_sleep+0x50>
      release(&tickslock);
80104d2d:	c7 04 24 80 4c 11 80 	movl   $0x80114c80,(%esp)
80104d34:	e8 84 ef ff ff       	call   80103cbd <release>
      return -1;
80104d39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d3e:	eb 38                	jmp    80104d78 <sys_sleep+0x88>
    }
    sleep(&ticks, &tickslock);
80104d40:	c7 44 24 04 80 4c 11 	movl   $0x80114c80,0x4(%esp)
80104d47:	80 
80104d48:	c7 04 24 c0 54 11 80 	movl   $0x801154c0,(%esp)
80104d4f:	e8 17 ea ff ff       	call   8010376b <sleep>
  while(ticks - ticks0 < n){
80104d54:	a1 c0 54 11 80       	mov    0x801154c0,%eax
80104d59:	29 d8                	sub    %ebx,%eax
80104d5b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104d5e:	72 c2                	jb     80104d22 <sys_sleep+0x32>
  }
  release(&tickslock);
80104d60:	c7 04 24 80 4c 11 80 	movl   $0x80114c80,(%esp)
80104d67:	e8 51 ef ff ff       	call   80103cbd <release>
  return 0;
80104d6c:	b8 00 00 00 00       	mov    $0x0,%eax
80104d71:	eb 05                	jmp    80104d78 <sys_sleep+0x88>
    return -1;
80104d73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d78:	83 c4 24             	add    $0x24,%esp
80104d7b:	5b                   	pop    %ebx
80104d7c:	5d                   	pop    %ebp
80104d7d:	c3                   	ret    

80104d7e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104d7e:	55                   	push   %ebp
80104d7f:	89 e5                	mov    %esp,%ebp
80104d81:	53                   	push   %ebx
80104d82:	83 ec 14             	sub    $0x14,%esp
  uint xticks;

  acquire(&tickslock);
80104d85:	c7 04 24 80 4c 11 80 	movl   $0x80114c80,(%esp)
80104d8c:	e8 cb ee ff ff       	call   80103c5c <acquire>
  xticks = ticks;
80104d91:	8b 1d c0 54 11 80    	mov    0x801154c0,%ebx
  release(&tickslock);
80104d97:	c7 04 24 80 4c 11 80 	movl   $0x80114c80,(%esp)
80104d9e:	e8 1a ef ff ff       	call   80103cbd <release>
  return xticks;
}
80104da3:	89 d8                	mov    %ebx,%eax
80104da5:	83 c4 14             	add    $0x14,%esp
80104da8:	5b                   	pop    %ebx
80104da9:	5d                   	pop    %ebp
80104daa:	c3                   	ret    

80104dab <sys_yield>:

int
sys_yield(void)
{
80104dab:	55                   	push   %ebp
80104dac:	89 e5                	mov    %esp,%ebp
80104dae:	83 ec 08             	sub    $0x8,%esp
  yield();
80104db1:	e8 84 e9 ff ff       	call   8010373a <yield>
  return 0;
}
80104db6:	b8 00 00 00 00       	mov    $0x0,%eax
80104dbb:	c9                   	leave  
80104dbc:	c3                   	ret    

80104dbd <sys_shutdown>:

int sys_shutdown(void)
{
80104dbd:	55                   	push   %ebp
80104dbe:	89 e5                	mov    %esp,%ebp
80104dc0:	83 ec 08             	sub    $0x8,%esp
  shutdown();
80104dc3:	e8 bd d4 ff ff       	call   80102285 <shutdown>
  return 0;
}
80104dc8:	b8 00 00 00 00       	mov    $0x0,%eax
80104dcd:	c9                   	leave  
80104dce:	c3                   	ret    

80104dcf <sys_setwritecount>:


int
sys_setwritecount(void)
{
80104dcf:	55                   	push   %ebp
80104dd0:	89 e5                	mov    %esp,%ebp
80104dd2:	83 ec 28             	sub    $0x28,%esp
  int newnum;
  
  if(argint(0, &newnum) < 0)
80104dd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104dd8:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ddc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104de3:	e8 83 f1 ff ff       	call   80103f6b <argint>
80104de8:	85 c0                	test   %eax,%eax
80104dea:	78 12                	js     80104dfe <sys_setwritecount+0x2f>
    return -1;
  setwritecount(newnum);
80104dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104def:	89 04 24             	mov    %eax,(%esp)
80104df2:	e8 1b ec ff ff       	call   80103a12 <setwritecount>
  return 0;
80104df7:	b8 00 00 00 00       	mov    $0x0,%eax
80104dfc:	eb 05                	jmp    80104e03 <sys_setwritecount+0x34>
    return -1;
80104dfe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e03:	c9                   	leave  
80104e04:	c3                   	ret    

80104e05 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104e05:	1e                   	push   %ds
  pushl %es
80104e06:	06                   	push   %es
  pushl %fs
80104e07:	0f a0                	push   %fs
  pushl %gs
80104e09:	0f a8                	push   %gs
  pushal
80104e0b:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104e0c:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104e10:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104e12:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104e14:	54                   	push   %esp
  call trap
80104e15:	e8 c6 00 00 00       	call   80104ee0 <trap>
  addl $4, %esp
80104e1a:	83 c4 04             	add    $0x4,%esp

80104e1d <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104e1d:	61                   	popa   
  popl %gs
80104e1e:	0f a9                	pop    %gs
  popl %fs
80104e20:	0f a1                	pop    %fs
  popl %es
80104e22:	07                   	pop    %es
  popl %ds
80104e23:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104e24:	83 c4 08             	add    $0x8,%esp
  iret
80104e27:	cf                   	iret   
80104e28:	66 90                	xchg   %ax,%ax
80104e2a:	66 90                	xchg   %ax,%ax
80104e2c:	66 90                	xchg   %ax,%ax
80104e2e:	66 90                	xchg   %ax,%ax

80104e30 <tvinit>:
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80104e30:	b8 00 00 00 00       	mov    $0x0,%eax
80104e35:	eb 37                	jmp    80104e6e <tvinit+0x3e>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104e37:	8b 14 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%edx
80104e3e:	66 89 14 c5 c0 4c 11 	mov    %dx,-0x7feeb340(,%eax,8)
80104e45:	80 
80104e46:	66 c7 04 c5 c2 4c 11 	movw   $0x8,-0x7feeb33e(,%eax,8)
80104e4d:	80 08 00 
80104e50:	c6 04 c5 c4 4c 11 80 	movb   $0x0,-0x7feeb33c(,%eax,8)
80104e57:	00 
80104e58:	c6 04 c5 c5 4c 11 80 	movb   $0x8e,-0x7feeb33b(,%eax,8)
80104e5f:	8e 
80104e60:	c1 ea 10             	shr    $0x10,%edx
80104e63:	66 89 14 c5 c6 4c 11 	mov    %dx,-0x7feeb33a(,%eax,8)
80104e6a:	80 
  for(i = 0; i < 256; i++)
80104e6b:	83 c0 01             	add    $0x1,%eax
80104e6e:	3d ff 00 00 00       	cmp    $0xff,%eax
80104e73:	7e c2                	jle    80104e37 <tvinit+0x7>
{
80104e75:	55                   	push   %ebp
80104e76:	89 e5                	mov    %esp,%ebp
80104e78:	83 ec 18             	sub    $0x18,%esp
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104e7b:	a1 08 a1 10 80       	mov    0x8010a108,%eax
80104e80:	66 a3 c0 4e 11 80    	mov    %ax,0x80114ec0
80104e86:	66 c7 05 c2 4e 11 80 	movw   $0x8,0x80114ec2
80104e8d:	08 00 
80104e8f:	c6 05 c4 4e 11 80 00 	movb   $0x0,0x80114ec4
80104e96:	c6 05 c5 4e 11 80 ef 	movb   $0xef,0x80114ec5
80104e9d:	c1 e8 10             	shr    $0x10,%eax
80104ea0:	66 a3 c6 4e 11 80    	mov    %ax,0x80114ec6

  initlock(&tickslock, "time");
80104ea6:	c7 44 24 04 49 6e 10 	movl   $0x80106e49,0x4(%esp)
80104ead:	80 
80104eae:	c7 04 24 80 4c 11 80 	movl   $0x80114c80,(%esp)
80104eb5:	e8 6a ec ff ff       	call   80103b24 <initlock>
}
80104eba:	c9                   	leave  
80104ebb:	c3                   	ret    

80104ebc <idtinit>:

void
idtinit(void)
{
80104ebc:	55                   	push   %ebp
80104ebd:	89 e5                	mov    %esp,%ebp
80104ebf:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80104ec2:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80104ec8:	b8 c0 4c 11 80       	mov    $0x80114cc0,%eax
80104ecd:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80104ed1:	c1 e8 10             	shr    $0x10,%eax
80104ed4:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80104ed8:	8d 45 fa             	lea    -0x6(%ebp),%eax
80104edb:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80104ede:	c9                   	leave  
80104edf:	c3                   	ret    

80104ee0 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80104ee0:	55                   	push   %ebp
80104ee1:	89 e5                	mov    %esp,%ebp
80104ee3:	57                   	push   %edi
80104ee4:	56                   	push   %esi
80104ee5:	53                   	push   %ebx
80104ee6:	83 ec 3c             	sub    $0x3c,%esp
80104ee9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80104eec:	8b 43 30             	mov    0x30(%ebx),%eax
80104eef:	83 f8 40             	cmp    $0x40,%eax
80104ef2:	75 36                	jne    80104f2a <trap+0x4a>
    if(myproc()->killed)
80104ef4:	e8 cc e3 ff ff       	call   801032c5 <myproc>
80104ef9:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104efd:	74 05                	je     80104f04 <trap+0x24>
      exit();
80104eff:	e8 7a e7 ff ff       	call   8010367e <exit>
    myproc()->tf = tf;
80104f04:	e8 bc e3 ff ff       	call   801032c5 <myproc>
80104f09:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80104f0c:	e8 24 f1 ff ff       	call   80104035 <syscall>
    if(myproc()->killed)
80104f11:	e8 af e3 ff ff       	call   801032c5 <myproc>
80104f16:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f1a:	0f 84 df 01 00 00    	je     801050ff <trap+0x21f>
      exit();
80104f20:	e8 59 e7 ff ff       	call   8010367e <exit>
80104f25:	e9 d5 01 00 00       	jmp    801050ff <trap+0x21f>
    return;
  }

  switch(tf->trapno){
80104f2a:	83 e8 20             	sub    $0x20,%eax
80104f2d:	83 f8 1f             	cmp    $0x1f,%eax
80104f30:	0f 87 aa 00 00 00    	ja     80104fe0 <trap+0x100>
80104f36:	ff 24 85 f0 6e 10 80 	jmp    *-0x7fef9110(,%eax,4)
80104f3d:	8d 76 00             	lea    0x0(%esi),%esi
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80104f40:	e8 65 e3 ff ff       	call   801032aa <cpuid>
80104f45:	85 c0                	test   %eax,%eax
80104f47:	75 2b                	jne    80104f74 <trap+0x94>
      acquire(&tickslock);
80104f49:	c7 04 24 80 4c 11 80 	movl   $0x80114c80,(%esp)
80104f50:	e8 07 ed ff ff       	call   80103c5c <acquire>
      ticks++;
80104f55:	83 05 c0 54 11 80 01 	addl   $0x1,0x801154c0
      wakeup(&ticks);
80104f5c:	c7 04 24 c0 54 11 80 	movl   $0x801154c0,(%esp)
80104f63:	e8 58 e9 ff ff       	call   801038c0 <wakeup>
      release(&tickslock);
80104f68:	c7 04 24 80 4c 11 80 	movl   $0x80114c80,(%esp)
80104f6f:	e8 49 ed ff ff       	call   80103cbd <release>
    }
    lapiceoi();
80104f74:	e8 ba d4 ff ff       	call   80102433 <lapiceoi>
    break;
80104f79:	e9 14 01 00 00       	jmp    80105092 <trap+0x1b2>
80104f7e:	66 90                	xchg   %ax,%ax
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80104f80:	e8 87 ce ff ff       	call   80101e0c <ideintr>
    lapiceoi();
80104f85:	e8 a9 d4 ff ff       	call   80102433 <lapiceoi>
    break;
80104f8a:	e9 03 01 00 00       	jmp    80105092 <trap+0x1b2>
80104f8f:	90                   	nop
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80104f90:	e8 dc d2 ff ff       	call   80102271 <kbdintr>
    lapiceoi();
80104f95:	e8 99 d4 ff ff       	call   80102433 <lapiceoi>
    break;
80104f9a:	e9 f3 00 00 00       	jmp    80105092 <trap+0x1b2>
80104f9f:	90                   	nop
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80104fa0:	e8 67 02 00 00       	call   8010520c <uartintr>
    lapiceoi();
80104fa5:	e8 89 d4 ff ff       	call   80102433 <lapiceoi>
    break;
80104faa:	e9 e3 00 00 00       	jmp    80105092 <trap+0x1b2>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80104faf:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
80104fb2:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80104fb6:	e8 ef e2 ff ff       	call   801032aa <cpuid>
80104fbb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
80104fbf:	0f b7 f6             	movzwl %si,%esi
80104fc2:	89 74 24 08          	mov    %esi,0x8(%esp)
80104fc6:	89 44 24 04          	mov    %eax,0x4(%esp)
80104fca:	c7 04 24 54 6e 10 80 	movl   $0x80106e54,(%esp)
80104fd1:	e8 f1 b5 ff ff       	call   801005c7 <cprintf>
    lapiceoi();
80104fd6:	e8 58 d4 ff ff       	call   80102433 <lapiceoi>
    break;
80104fdb:	e9 b2 00 00 00       	jmp    80105092 <trap+0x1b2>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80104fe0:	e8 e0 e2 ff ff       	call   801032c5 <myproc>
80104fe5:	85 c0                	test   %eax,%eax
80104fe7:	74 06                	je     80104fef <trap+0x10f>
80104fe9:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80104fed:	75 36                	jne    80105025 <trap+0x145>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80104fef:	0f 20 d7             	mov    %cr2,%edi
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80104ff2:	8b 73 38             	mov    0x38(%ebx),%esi
80104ff5:	e8 b0 e2 ff ff       	call   801032aa <cpuid>
80104ffa:	89 7c 24 10          	mov    %edi,0x10(%esp)
80104ffe:	89 74 24 0c          	mov    %esi,0xc(%esp)
80105002:	89 44 24 08          	mov    %eax,0x8(%esp)
80105006:	8b 43 30             	mov    0x30(%ebx),%eax
80105009:	89 44 24 04          	mov    %eax,0x4(%esp)
8010500d:	c7 04 24 78 6e 10 80 	movl   $0x80106e78,(%esp)
80105014:	e8 ae b5 ff ff       	call   801005c7 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80105019:	c7 04 24 4e 6e 10 80 	movl   $0x80106e4e,(%esp)
80105020:	e8 00 b3 ff ff       	call   80100325 <panic>
80105025:	0f 20 d7             	mov    %cr2,%edi
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105028:	8b 43 38             	mov    0x38(%ebx),%eax
8010502b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010502e:	e8 77 e2 ff ff       	call   801032aa <cpuid>
80105033:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105036:	8b 4b 34             	mov    0x34(%ebx),%ecx
80105039:	89 4d dc             	mov    %ecx,-0x24(%ebp)
8010503c:	8b 73 30             	mov    0x30(%ebx),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
8010503f:	e8 81 e2 ff ff       	call   801032c5 <myproc>
80105044:	8d 50 6c             	lea    0x6c(%eax),%edx
80105047:	89 55 d8             	mov    %edx,-0x28(%ebp)
8010504a:	e8 76 e2 ff ff       	call   801032c5 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010504f:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
80105053:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105056:	89 54 24 18          	mov    %edx,0x18(%esp)
8010505a:	8b 7d e0             	mov    -0x20(%ebp),%edi
8010505d:	89 7c 24 14          	mov    %edi,0x14(%esp)
80105061:	8b 4d dc             	mov    -0x24(%ebp),%ecx
80105064:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80105068:	89 74 24 0c          	mov    %esi,0xc(%esp)
8010506c:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010506f:	89 54 24 08          	mov    %edx,0x8(%esp)
80105073:	8b 40 10             	mov    0x10(%eax),%eax
80105076:	89 44 24 04          	mov    %eax,0x4(%esp)
8010507a:	c7 04 24 ac 6e 10 80 	movl   $0x80106eac,(%esp)
80105081:	e8 41 b5 ff ff       	call   801005c7 <cprintf>
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80105086:	e8 3a e2 ff ff       	call   801032c5 <myproc>
8010508b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105092:	e8 2e e2 ff ff       	call   801032c5 <myproc>
80105097:	85 c0                	test   %eax,%eax
80105099:	74 1d                	je     801050b8 <trap+0x1d8>
8010509b:	e8 25 e2 ff ff       	call   801032c5 <myproc>
801050a0:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801050a4:	74 12                	je     801050b8 <trap+0x1d8>
801050a6:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801050aa:	83 e0 03             	and    $0x3,%eax
801050ad:	66 83 f8 03          	cmp    $0x3,%ax
801050b1:	75 05                	jne    801050b8 <trap+0x1d8>
    exit();
801050b3:	e8 c6 e5 ff ff       	call   8010367e <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801050b8:	e8 08 e2 ff ff       	call   801032c5 <myproc>
801050bd:	85 c0                	test   %eax,%eax
801050bf:	90                   	nop
801050c0:	74 16                	je     801050d8 <trap+0x1f8>
801050c2:	e8 fe e1 ff ff       	call   801032c5 <myproc>
801050c7:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
801050cb:	75 0b                	jne    801050d8 <trap+0x1f8>
801050cd:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
801050d1:	75 05                	jne    801050d8 <trap+0x1f8>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
801050d3:	e8 62 e6 ff ff       	call   8010373a <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801050d8:	e8 e8 e1 ff ff       	call   801032c5 <myproc>
801050dd:	85 c0                	test   %eax,%eax
801050df:	90                   	nop
801050e0:	74 1d                	je     801050ff <trap+0x21f>
801050e2:	e8 de e1 ff ff       	call   801032c5 <myproc>
801050e7:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801050eb:	74 12                	je     801050ff <trap+0x21f>
801050ed:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801050f1:	83 e0 03             	and    $0x3,%eax
801050f4:	66 83 f8 03          	cmp    $0x3,%ax
801050f8:	75 05                	jne    801050ff <trap+0x21f>
    exit();
801050fa:	e8 7f e5 ff ff       	call   8010367e <exit>
}
801050ff:	83 c4 3c             	add    $0x3c,%esp
80105102:	5b                   	pop    %ebx
80105103:	5e                   	pop    %esi
80105104:	5f                   	pop    %edi
80105105:	5d                   	pop    %ebp
80105106:	c3                   	ret    

80105107 <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
80105107:	55                   	push   %ebp
80105108:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010510a:	83 3d c0 a5 10 80 00 	cmpl   $0x0,0x8010a5c0
80105111:	74 12                	je     80105125 <uartgetc+0x1e>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105113:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105118:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105119:	a8 01                	test   $0x1,%al
8010511b:	74 0f                	je     8010512c <uartgetc+0x25>
8010511d:	b2 f8                	mov    $0xf8,%dl
8010511f:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105120:	0f b6 c0             	movzbl %al,%eax
80105123:	eb 0c                	jmp    80105131 <uartgetc+0x2a>
    return -1;
80105125:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010512a:	eb 05                	jmp    80105131 <uartgetc+0x2a>
    return -1;
8010512c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105131:	5d                   	pop    %ebp
80105132:	c3                   	ret    

80105133 <uartputc>:
  if(!uart)
80105133:	83 3d c0 a5 10 80 00 	cmpl   $0x0,0x8010a5c0
8010513a:	74 3e                	je     8010517a <uartputc+0x47>
{
8010513c:	55                   	push   %ebp
8010513d:	89 e5                	mov    %esp,%ebp
8010513f:	56                   	push   %esi
80105140:	53                   	push   %ebx
80105141:	83 ec 10             	sub    $0x10,%esp
80105144:	bb 00 00 00 00       	mov    $0x0,%ebx
80105149:	be fd 03 00 00       	mov    $0x3fd,%esi
8010514e:	eb 0f                	jmp    8010515f <uartputc+0x2c>
    microdelay(10);
80105150:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80105157:	e8 f5 d2 ff ff       	call   80102451 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010515c:	83 c3 01             	add    $0x1,%ebx
8010515f:	83 fb 7f             	cmp    $0x7f,%ebx
80105162:	7f 07                	jg     8010516b <uartputc+0x38>
80105164:	89 f2                	mov    %esi,%edx
80105166:	ec                   	in     (%dx),%al
80105167:	a8 20                	test   $0x20,%al
80105169:	74 e5                	je     80105150 <uartputc+0x1d>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010516b:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105170:	8b 45 08             	mov    0x8(%ebp),%eax
80105173:	ee                   	out    %al,(%dx)
}
80105174:	83 c4 10             	add    $0x10,%esp
80105177:	5b                   	pop    %ebx
80105178:	5e                   	pop    %esi
80105179:	5d                   	pop    %ebp
8010517a:	f3 c3                	repz ret 

8010517c <uartinit>:
8010517c:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105181:	b8 00 00 00 00       	mov    $0x0,%eax
80105186:	ee                   	out    %al,(%dx)
80105187:	b2 fb                	mov    $0xfb,%dl
80105189:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
8010518e:	ee                   	out    %al,(%dx)
8010518f:	b2 f8                	mov    $0xf8,%dl
80105191:	b8 0c 00 00 00       	mov    $0xc,%eax
80105196:	ee                   	out    %al,(%dx)
80105197:	b2 f9                	mov    $0xf9,%dl
80105199:	b8 00 00 00 00       	mov    $0x0,%eax
8010519e:	ee                   	out    %al,(%dx)
8010519f:	b2 fb                	mov    $0xfb,%dl
801051a1:	b8 03 00 00 00       	mov    $0x3,%eax
801051a6:	ee                   	out    %al,(%dx)
801051a7:	b2 fc                	mov    $0xfc,%dl
801051a9:	b8 00 00 00 00       	mov    $0x0,%eax
801051ae:	ee                   	out    %al,(%dx)
801051af:	b2 f9                	mov    $0xf9,%dl
801051b1:	b8 01 00 00 00       	mov    $0x1,%eax
801051b6:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801051b7:	b2 fd                	mov    $0xfd,%dl
801051b9:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
801051ba:	3c ff                	cmp    $0xff,%al
801051bc:	74 4c                	je     8010520a <uartinit+0x8e>
{
801051be:	55                   	push   %ebp
801051bf:	89 e5                	mov    %esp,%ebp
801051c1:	53                   	push   %ebx
801051c2:	83 ec 14             	sub    $0x14,%esp
  uart = 1;
801051c5:	c7 05 c0 a5 10 80 01 	movl   $0x1,0x8010a5c0
801051cc:	00 00 00 
801051cf:	b2 fa                	mov    $0xfa,%dl
801051d1:	ec                   	in     (%dx),%al
801051d2:	b2 f8                	mov    $0xf8,%dl
801051d4:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
801051d5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801051dc:	00 
801051dd:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801051e4:	e8 0d ce ff ff       	call   80101ff6 <ioapicenable>
  for(p="xv6...\n"; *p; p++)
801051e9:	bb 70 6f 10 80       	mov    $0x80106f70,%ebx
801051ee:	eb 0e                	jmp    801051fe <uartinit+0x82>
    uartputc(*p);
801051f0:	0f be c0             	movsbl %al,%eax
801051f3:	89 04 24             	mov    %eax,(%esp)
801051f6:	e8 38 ff ff ff       	call   80105133 <uartputc>
  for(p="xv6...\n"; *p; p++)
801051fb:	83 c3 01             	add    $0x1,%ebx
801051fe:	0f b6 03             	movzbl (%ebx),%eax
80105201:	84 c0                	test   %al,%al
80105203:	75 eb                	jne    801051f0 <uartinit+0x74>
}
80105205:	83 c4 14             	add    $0x14,%esp
80105208:	5b                   	pop    %ebx
80105209:	5d                   	pop    %ebp
8010520a:	f3 c3                	repz ret 

8010520c <uartintr>:

void
uartintr(void)
{
8010520c:	55                   	push   %ebp
8010520d:	89 e5                	mov    %esp,%ebp
8010520f:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80105212:	c7 04 24 07 51 10 80 	movl   $0x80105107,(%esp)
80105219:	e8 db b4 ff ff       	call   801006f9 <consoleintr>
}
8010521e:	c9                   	leave  
8010521f:	c3                   	ret    

80105220 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105220:	6a 00                	push   $0x0
  pushl $0
80105222:	6a 00                	push   $0x0
  jmp alltraps
80105224:	e9 dc fb ff ff       	jmp    80104e05 <alltraps>

80105229 <vector1>:
.globl vector1
vector1:
  pushl $0
80105229:	6a 00                	push   $0x0
  pushl $1
8010522b:	6a 01                	push   $0x1
  jmp alltraps
8010522d:	e9 d3 fb ff ff       	jmp    80104e05 <alltraps>

80105232 <vector2>:
.globl vector2
vector2:
  pushl $0
80105232:	6a 00                	push   $0x0
  pushl $2
80105234:	6a 02                	push   $0x2
  jmp alltraps
80105236:	e9 ca fb ff ff       	jmp    80104e05 <alltraps>

8010523b <vector3>:
.globl vector3
vector3:
  pushl $0
8010523b:	6a 00                	push   $0x0
  pushl $3
8010523d:	6a 03                	push   $0x3
  jmp alltraps
8010523f:	e9 c1 fb ff ff       	jmp    80104e05 <alltraps>

80105244 <vector4>:
.globl vector4
vector4:
  pushl $0
80105244:	6a 00                	push   $0x0
  pushl $4
80105246:	6a 04                	push   $0x4
  jmp alltraps
80105248:	e9 b8 fb ff ff       	jmp    80104e05 <alltraps>

8010524d <vector5>:
.globl vector5
vector5:
  pushl $0
8010524d:	6a 00                	push   $0x0
  pushl $5
8010524f:	6a 05                	push   $0x5
  jmp alltraps
80105251:	e9 af fb ff ff       	jmp    80104e05 <alltraps>

80105256 <vector6>:
.globl vector6
vector6:
  pushl $0
80105256:	6a 00                	push   $0x0
  pushl $6
80105258:	6a 06                	push   $0x6
  jmp alltraps
8010525a:	e9 a6 fb ff ff       	jmp    80104e05 <alltraps>

8010525f <vector7>:
.globl vector7
vector7:
  pushl $0
8010525f:	6a 00                	push   $0x0
  pushl $7
80105261:	6a 07                	push   $0x7
  jmp alltraps
80105263:	e9 9d fb ff ff       	jmp    80104e05 <alltraps>

80105268 <vector8>:
.globl vector8
vector8:
  pushl $8
80105268:	6a 08                	push   $0x8
  jmp alltraps
8010526a:	e9 96 fb ff ff       	jmp    80104e05 <alltraps>

8010526f <vector9>:
.globl vector9
vector9:
  pushl $0
8010526f:	6a 00                	push   $0x0
  pushl $9
80105271:	6a 09                	push   $0x9
  jmp alltraps
80105273:	e9 8d fb ff ff       	jmp    80104e05 <alltraps>

80105278 <vector10>:
.globl vector10
vector10:
  pushl $10
80105278:	6a 0a                	push   $0xa
  jmp alltraps
8010527a:	e9 86 fb ff ff       	jmp    80104e05 <alltraps>

8010527f <vector11>:
.globl vector11
vector11:
  pushl $11
8010527f:	6a 0b                	push   $0xb
  jmp alltraps
80105281:	e9 7f fb ff ff       	jmp    80104e05 <alltraps>

80105286 <vector12>:
.globl vector12
vector12:
  pushl $12
80105286:	6a 0c                	push   $0xc
  jmp alltraps
80105288:	e9 78 fb ff ff       	jmp    80104e05 <alltraps>

8010528d <vector13>:
.globl vector13
vector13:
  pushl $13
8010528d:	6a 0d                	push   $0xd
  jmp alltraps
8010528f:	e9 71 fb ff ff       	jmp    80104e05 <alltraps>

80105294 <vector14>:
.globl vector14
vector14:
  pushl $14
80105294:	6a 0e                	push   $0xe
  jmp alltraps
80105296:	e9 6a fb ff ff       	jmp    80104e05 <alltraps>

8010529b <vector15>:
.globl vector15
vector15:
  pushl $0
8010529b:	6a 00                	push   $0x0
  pushl $15
8010529d:	6a 0f                	push   $0xf
  jmp alltraps
8010529f:	e9 61 fb ff ff       	jmp    80104e05 <alltraps>

801052a4 <vector16>:
.globl vector16
vector16:
  pushl $0
801052a4:	6a 00                	push   $0x0
  pushl $16
801052a6:	6a 10                	push   $0x10
  jmp alltraps
801052a8:	e9 58 fb ff ff       	jmp    80104e05 <alltraps>

801052ad <vector17>:
.globl vector17
vector17:
  pushl $17
801052ad:	6a 11                	push   $0x11
  jmp alltraps
801052af:	e9 51 fb ff ff       	jmp    80104e05 <alltraps>

801052b4 <vector18>:
.globl vector18
vector18:
  pushl $0
801052b4:	6a 00                	push   $0x0
  pushl $18
801052b6:	6a 12                	push   $0x12
  jmp alltraps
801052b8:	e9 48 fb ff ff       	jmp    80104e05 <alltraps>

801052bd <vector19>:
.globl vector19
vector19:
  pushl $0
801052bd:	6a 00                	push   $0x0
  pushl $19
801052bf:	6a 13                	push   $0x13
  jmp alltraps
801052c1:	e9 3f fb ff ff       	jmp    80104e05 <alltraps>

801052c6 <vector20>:
.globl vector20
vector20:
  pushl $0
801052c6:	6a 00                	push   $0x0
  pushl $20
801052c8:	6a 14                	push   $0x14
  jmp alltraps
801052ca:	e9 36 fb ff ff       	jmp    80104e05 <alltraps>

801052cf <vector21>:
.globl vector21
vector21:
  pushl $0
801052cf:	6a 00                	push   $0x0
  pushl $21
801052d1:	6a 15                	push   $0x15
  jmp alltraps
801052d3:	e9 2d fb ff ff       	jmp    80104e05 <alltraps>

801052d8 <vector22>:
.globl vector22
vector22:
  pushl $0
801052d8:	6a 00                	push   $0x0
  pushl $22
801052da:	6a 16                	push   $0x16
  jmp alltraps
801052dc:	e9 24 fb ff ff       	jmp    80104e05 <alltraps>

801052e1 <vector23>:
.globl vector23
vector23:
  pushl $0
801052e1:	6a 00                	push   $0x0
  pushl $23
801052e3:	6a 17                	push   $0x17
  jmp alltraps
801052e5:	e9 1b fb ff ff       	jmp    80104e05 <alltraps>

801052ea <vector24>:
.globl vector24
vector24:
  pushl $0
801052ea:	6a 00                	push   $0x0
  pushl $24
801052ec:	6a 18                	push   $0x18
  jmp alltraps
801052ee:	e9 12 fb ff ff       	jmp    80104e05 <alltraps>

801052f3 <vector25>:
.globl vector25
vector25:
  pushl $0
801052f3:	6a 00                	push   $0x0
  pushl $25
801052f5:	6a 19                	push   $0x19
  jmp alltraps
801052f7:	e9 09 fb ff ff       	jmp    80104e05 <alltraps>

801052fc <vector26>:
.globl vector26
vector26:
  pushl $0
801052fc:	6a 00                	push   $0x0
  pushl $26
801052fe:	6a 1a                	push   $0x1a
  jmp alltraps
80105300:	e9 00 fb ff ff       	jmp    80104e05 <alltraps>

80105305 <vector27>:
.globl vector27
vector27:
  pushl $0
80105305:	6a 00                	push   $0x0
  pushl $27
80105307:	6a 1b                	push   $0x1b
  jmp alltraps
80105309:	e9 f7 fa ff ff       	jmp    80104e05 <alltraps>

8010530e <vector28>:
.globl vector28
vector28:
  pushl $0
8010530e:	6a 00                	push   $0x0
  pushl $28
80105310:	6a 1c                	push   $0x1c
  jmp alltraps
80105312:	e9 ee fa ff ff       	jmp    80104e05 <alltraps>

80105317 <vector29>:
.globl vector29
vector29:
  pushl $0
80105317:	6a 00                	push   $0x0
  pushl $29
80105319:	6a 1d                	push   $0x1d
  jmp alltraps
8010531b:	e9 e5 fa ff ff       	jmp    80104e05 <alltraps>

80105320 <vector30>:
.globl vector30
vector30:
  pushl $0
80105320:	6a 00                	push   $0x0
  pushl $30
80105322:	6a 1e                	push   $0x1e
  jmp alltraps
80105324:	e9 dc fa ff ff       	jmp    80104e05 <alltraps>

80105329 <vector31>:
.globl vector31
vector31:
  pushl $0
80105329:	6a 00                	push   $0x0
  pushl $31
8010532b:	6a 1f                	push   $0x1f
  jmp alltraps
8010532d:	e9 d3 fa ff ff       	jmp    80104e05 <alltraps>

80105332 <vector32>:
.globl vector32
vector32:
  pushl $0
80105332:	6a 00                	push   $0x0
  pushl $32
80105334:	6a 20                	push   $0x20
  jmp alltraps
80105336:	e9 ca fa ff ff       	jmp    80104e05 <alltraps>

8010533b <vector33>:
.globl vector33
vector33:
  pushl $0
8010533b:	6a 00                	push   $0x0
  pushl $33
8010533d:	6a 21                	push   $0x21
  jmp alltraps
8010533f:	e9 c1 fa ff ff       	jmp    80104e05 <alltraps>

80105344 <vector34>:
.globl vector34
vector34:
  pushl $0
80105344:	6a 00                	push   $0x0
  pushl $34
80105346:	6a 22                	push   $0x22
  jmp alltraps
80105348:	e9 b8 fa ff ff       	jmp    80104e05 <alltraps>

8010534d <vector35>:
.globl vector35
vector35:
  pushl $0
8010534d:	6a 00                	push   $0x0
  pushl $35
8010534f:	6a 23                	push   $0x23
  jmp alltraps
80105351:	e9 af fa ff ff       	jmp    80104e05 <alltraps>

80105356 <vector36>:
.globl vector36
vector36:
  pushl $0
80105356:	6a 00                	push   $0x0
  pushl $36
80105358:	6a 24                	push   $0x24
  jmp alltraps
8010535a:	e9 a6 fa ff ff       	jmp    80104e05 <alltraps>

8010535f <vector37>:
.globl vector37
vector37:
  pushl $0
8010535f:	6a 00                	push   $0x0
  pushl $37
80105361:	6a 25                	push   $0x25
  jmp alltraps
80105363:	e9 9d fa ff ff       	jmp    80104e05 <alltraps>

80105368 <vector38>:
.globl vector38
vector38:
  pushl $0
80105368:	6a 00                	push   $0x0
  pushl $38
8010536a:	6a 26                	push   $0x26
  jmp alltraps
8010536c:	e9 94 fa ff ff       	jmp    80104e05 <alltraps>

80105371 <vector39>:
.globl vector39
vector39:
  pushl $0
80105371:	6a 00                	push   $0x0
  pushl $39
80105373:	6a 27                	push   $0x27
  jmp alltraps
80105375:	e9 8b fa ff ff       	jmp    80104e05 <alltraps>

8010537a <vector40>:
.globl vector40
vector40:
  pushl $0
8010537a:	6a 00                	push   $0x0
  pushl $40
8010537c:	6a 28                	push   $0x28
  jmp alltraps
8010537e:	e9 82 fa ff ff       	jmp    80104e05 <alltraps>

80105383 <vector41>:
.globl vector41
vector41:
  pushl $0
80105383:	6a 00                	push   $0x0
  pushl $41
80105385:	6a 29                	push   $0x29
  jmp alltraps
80105387:	e9 79 fa ff ff       	jmp    80104e05 <alltraps>

8010538c <vector42>:
.globl vector42
vector42:
  pushl $0
8010538c:	6a 00                	push   $0x0
  pushl $42
8010538e:	6a 2a                	push   $0x2a
  jmp alltraps
80105390:	e9 70 fa ff ff       	jmp    80104e05 <alltraps>

80105395 <vector43>:
.globl vector43
vector43:
  pushl $0
80105395:	6a 00                	push   $0x0
  pushl $43
80105397:	6a 2b                	push   $0x2b
  jmp alltraps
80105399:	e9 67 fa ff ff       	jmp    80104e05 <alltraps>

8010539e <vector44>:
.globl vector44
vector44:
  pushl $0
8010539e:	6a 00                	push   $0x0
  pushl $44
801053a0:	6a 2c                	push   $0x2c
  jmp alltraps
801053a2:	e9 5e fa ff ff       	jmp    80104e05 <alltraps>

801053a7 <vector45>:
.globl vector45
vector45:
  pushl $0
801053a7:	6a 00                	push   $0x0
  pushl $45
801053a9:	6a 2d                	push   $0x2d
  jmp alltraps
801053ab:	e9 55 fa ff ff       	jmp    80104e05 <alltraps>

801053b0 <vector46>:
.globl vector46
vector46:
  pushl $0
801053b0:	6a 00                	push   $0x0
  pushl $46
801053b2:	6a 2e                	push   $0x2e
  jmp alltraps
801053b4:	e9 4c fa ff ff       	jmp    80104e05 <alltraps>

801053b9 <vector47>:
.globl vector47
vector47:
  pushl $0
801053b9:	6a 00                	push   $0x0
  pushl $47
801053bb:	6a 2f                	push   $0x2f
  jmp alltraps
801053bd:	e9 43 fa ff ff       	jmp    80104e05 <alltraps>

801053c2 <vector48>:
.globl vector48
vector48:
  pushl $0
801053c2:	6a 00                	push   $0x0
  pushl $48
801053c4:	6a 30                	push   $0x30
  jmp alltraps
801053c6:	e9 3a fa ff ff       	jmp    80104e05 <alltraps>

801053cb <vector49>:
.globl vector49
vector49:
  pushl $0
801053cb:	6a 00                	push   $0x0
  pushl $49
801053cd:	6a 31                	push   $0x31
  jmp alltraps
801053cf:	e9 31 fa ff ff       	jmp    80104e05 <alltraps>

801053d4 <vector50>:
.globl vector50
vector50:
  pushl $0
801053d4:	6a 00                	push   $0x0
  pushl $50
801053d6:	6a 32                	push   $0x32
  jmp alltraps
801053d8:	e9 28 fa ff ff       	jmp    80104e05 <alltraps>

801053dd <vector51>:
.globl vector51
vector51:
  pushl $0
801053dd:	6a 00                	push   $0x0
  pushl $51
801053df:	6a 33                	push   $0x33
  jmp alltraps
801053e1:	e9 1f fa ff ff       	jmp    80104e05 <alltraps>

801053e6 <vector52>:
.globl vector52
vector52:
  pushl $0
801053e6:	6a 00                	push   $0x0
  pushl $52
801053e8:	6a 34                	push   $0x34
  jmp alltraps
801053ea:	e9 16 fa ff ff       	jmp    80104e05 <alltraps>

801053ef <vector53>:
.globl vector53
vector53:
  pushl $0
801053ef:	6a 00                	push   $0x0
  pushl $53
801053f1:	6a 35                	push   $0x35
  jmp alltraps
801053f3:	e9 0d fa ff ff       	jmp    80104e05 <alltraps>

801053f8 <vector54>:
.globl vector54
vector54:
  pushl $0
801053f8:	6a 00                	push   $0x0
  pushl $54
801053fa:	6a 36                	push   $0x36
  jmp alltraps
801053fc:	e9 04 fa ff ff       	jmp    80104e05 <alltraps>

80105401 <vector55>:
.globl vector55
vector55:
  pushl $0
80105401:	6a 00                	push   $0x0
  pushl $55
80105403:	6a 37                	push   $0x37
  jmp alltraps
80105405:	e9 fb f9 ff ff       	jmp    80104e05 <alltraps>

8010540a <vector56>:
.globl vector56
vector56:
  pushl $0
8010540a:	6a 00                	push   $0x0
  pushl $56
8010540c:	6a 38                	push   $0x38
  jmp alltraps
8010540e:	e9 f2 f9 ff ff       	jmp    80104e05 <alltraps>

80105413 <vector57>:
.globl vector57
vector57:
  pushl $0
80105413:	6a 00                	push   $0x0
  pushl $57
80105415:	6a 39                	push   $0x39
  jmp alltraps
80105417:	e9 e9 f9 ff ff       	jmp    80104e05 <alltraps>

8010541c <vector58>:
.globl vector58
vector58:
  pushl $0
8010541c:	6a 00                	push   $0x0
  pushl $58
8010541e:	6a 3a                	push   $0x3a
  jmp alltraps
80105420:	e9 e0 f9 ff ff       	jmp    80104e05 <alltraps>

80105425 <vector59>:
.globl vector59
vector59:
  pushl $0
80105425:	6a 00                	push   $0x0
  pushl $59
80105427:	6a 3b                	push   $0x3b
  jmp alltraps
80105429:	e9 d7 f9 ff ff       	jmp    80104e05 <alltraps>

8010542e <vector60>:
.globl vector60
vector60:
  pushl $0
8010542e:	6a 00                	push   $0x0
  pushl $60
80105430:	6a 3c                	push   $0x3c
  jmp alltraps
80105432:	e9 ce f9 ff ff       	jmp    80104e05 <alltraps>

80105437 <vector61>:
.globl vector61
vector61:
  pushl $0
80105437:	6a 00                	push   $0x0
  pushl $61
80105439:	6a 3d                	push   $0x3d
  jmp alltraps
8010543b:	e9 c5 f9 ff ff       	jmp    80104e05 <alltraps>

80105440 <vector62>:
.globl vector62
vector62:
  pushl $0
80105440:	6a 00                	push   $0x0
  pushl $62
80105442:	6a 3e                	push   $0x3e
  jmp alltraps
80105444:	e9 bc f9 ff ff       	jmp    80104e05 <alltraps>

80105449 <vector63>:
.globl vector63
vector63:
  pushl $0
80105449:	6a 00                	push   $0x0
  pushl $63
8010544b:	6a 3f                	push   $0x3f
  jmp alltraps
8010544d:	e9 b3 f9 ff ff       	jmp    80104e05 <alltraps>

80105452 <vector64>:
.globl vector64
vector64:
  pushl $0
80105452:	6a 00                	push   $0x0
  pushl $64
80105454:	6a 40                	push   $0x40
  jmp alltraps
80105456:	e9 aa f9 ff ff       	jmp    80104e05 <alltraps>

8010545b <vector65>:
.globl vector65
vector65:
  pushl $0
8010545b:	6a 00                	push   $0x0
  pushl $65
8010545d:	6a 41                	push   $0x41
  jmp alltraps
8010545f:	e9 a1 f9 ff ff       	jmp    80104e05 <alltraps>

80105464 <vector66>:
.globl vector66
vector66:
  pushl $0
80105464:	6a 00                	push   $0x0
  pushl $66
80105466:	6a 42                	push   $0x42
  jmp alltraps
80105468:	e9 98 f9 ff ff       	jmp    80104e05 <alltraps>

8010546d <vector67>:
.globl vector67
vector67:
  pushl $0
8010546d:	6a 00                	push   $0x0
  pushl $67
8010546f:	6a 43                	push   $0x43
  jmp alltraps
80105471:	e9 8f f9 ff ff       	jmp    80104e05 <alltraps>

80105476 <vector68>:
.globl vector68
vector68:
  pushl $0
80105476:	6a 00                	push   $0x0
  pushl $68
80105478:	6a 44                	push   $0x44
  jmp alltraps
8010547a:	e9 86 f9 ff ff       	jmp    80104e05 <alltraps>

8010547f <vector69>:
.globl vector69
vector69:
  pushl $0
8010547f:	6a 00                	push   $0x0
  pushl $69
80105481:	6a 45                	push   $0x45
  jmp alltraps
80105483:	e9 7d f9 ff ff       	jmp    80104e05 <alltraps>

80105488 <vector70>:
.globl vector70
vector70:
  pushl $0
80105488:	6a 00                	push   $0x0
  pushl $70
8010548a:	6a 46                	push   $0x46
  jmp alltraps
8010548c:	e9 74 f9 ff ff       	jmp    80104e05 <alltraps>

80105491 <vector71>:
.globl vector71
vector71:
  pushl $0
80105491:	6a 00                	push   $0x0
  pushl $71
80105493:	6a 47                	push   $0x47
  jmp alltraps
80105495:	e9 6b f9 ff ff       	jmp    80104e05 <alltraps>

8010549a <vector72>:
.globl vector72
vector72:
  pushl $0
8010549a:	6a 00                	push   $0x0
  pushl $72
8010549c:	6a 48                	push   $0x48
  jmp alltraps
8010549e:	e9 62 f9 ff ff       	jmp    80104e05 <alltraps>

801054a3 <vector73>:
.globl vector73
vector73:
  pushl $0
801054a3:	6a 00                	push   $0x0
  pushl $73
801054a5:	6a 49                	push   $0x49
  jmp alltraps
801054a7:	e9 59 f9 ff ff       	jmp    80104e05 <alltraps>

801054ac <vector74>:
.globl vector74
vector74:
  pushl $0
801054ac:	6a 00                	push   $0x0
  pushl $74
801054ae:	6a 4a                	push   $0x4a
  jmp alltraps
801054b0:	e9 50 f9 ff ff       	jmp    80104e05 <alltraps>

801054b5 <vector75>:
.globl vector75
vector75:
  pushl $0
801054b5:	6a 00                	push   $0x0
  pushl $75
801054b7:	6a 4b                	push   $0x4b
  jmp alltraps
801054b9:	e9 47 f9 ff ff       	jmp    80104e05 <alltraps>

801054be <vector76>:
.globl vector76
vector76:
  pushl $0
801054be:	6a 00                	push   $0x0
  pushl $76
801054c0:	6a 4c                	push   $0x4c
  jmp alltraps
801054c2:	e9 3e f9 ff ff       	jmp    80104e05 <alltraps>

801054c7 <vector77>:
.globl vector77
vector77:
  pushl $0
801054c7:	6a 00                	push   $0x0
  pushl $77
801054c9:	6a 4d                	push   $0x4d
  jmp alltraps
801054cb:	e9 35 f9 ff ff       	jmp    80104e05 <alltraps>

801054d0 <vector78>:
.globl vector78
vector78:
  pushl $0
801054d0:	6a 00                	push   $0x0
  pushl $78
801054d2:	6a 4e                	push   $0x4e
  jmp alltraps
801054d4:	e9 2c f9 ff ff       	jmp    80104e05 <alltraps>

801054d9 <vector79>:
.globl vector79
vector79:
  pushl $0
801054d9:	6a 00                	push   $0x0
  pushl $79
801054db:	6a 4f                	push   $0x4f
  jmp alltraps
801054dd:	e9 23 f9 ff ff       	jmp    80104e05 <alltraps>

801054e2 <vector80>:
.globl vector80
vector80:
  pushl $0
801054e2:	6a 00                	push   $0x0
  pushl $80
801054e4:	6a 50                	push   $0x50
  jmp alltraps
801054e6:	e9 1a f9 ff ff       	jmp    80104e05 <alltraps>

801054eb <vector81>:
.globl vector81
vector81:
  pushl $0
801054eb:	6a 00                	push   $0x0
  pushl $81
801054ed:	6a 51                	push   $0x51
  jmp alltraps
801054ef:	e9 11 f9 ff ff       	jmp    80104e05 <alltraps>

801054f4 <vector82>:
.globl vector82
vector82:
  pushl $0
801054f4:	6a 00                	push   $0x0
  pushl $82
801054f6:	6a 52                	push   $0x52
  jmp alltraps
801054f8:	e9 08 f9 ff ff       	jmp    80104e05 <alltraps>

801054fd <vector83>:
.globl vector83
vector83:
  pushl $0
801054fd:	6a 00                	push   $0x0
  pushl $83
801054ff:	6a 53                	push   $0x53
  jmp alltraps
80105501:	e9 ff f8 ff ff       	jmp    80104e05 <alltraps>

80105506 <vector84>:
.globl vector84
vector84:
  pushl $0
80105506:	6a 00                	push   $0x0
  pushl $84
80105508:	6a 54                	push   $0x54
  jmp alltraps
8010550a:	e9 f6 f8 ff ff       	jmp    80104e05 <alltraps>

8010550f <vector85>:
.globl vector85
vector85:
  pushl $0
8010550f:	6a 00                	push   $0x0
  pushl $85
80105511:	6a 55                	push   $0x55
  jmp alltraps
80105513:	e9 ed f8 ff ff       	jmp    80104e05 <alltraps>

80105518 <vector86>:
.globl vector86
vector86:
  pushl $0
80105518:	6a 00                	push   $0x0
  pushl $86
8010551a:	6a 56                	push   $0x56
  jmp alltraps
8010551c:	e9 e4 f8 ff ff       	jmp    80104e05 <alltraps>

80105521 <vector87>:
.globl vector87
vector87:
  pushl $0
80105521:	6a 00                	push   $0x0
  pushl $87
80105523:	6a 57                	push   $0x57
  jmp alltraps
80105525:	e9 db f8 ff ff       	jmp    80104e05 <alltraps>

8010552a <vector88>:
.globl vector88
vector88:
  pushl $0
8010552a:	6a 00                	push   $0x0
  pushl $88
8010552c:	6a 58                	push   $0x58
  jmp alltraps
8010552e:	e9 d2 f8 ff ff       	jmp    80104e05 <alltraps>

80105533 <vector89>:
.globl vector89
vector89:
  pushl $0
80105533:	6a 00                	push   $0x0
  pushl $89
80105535:	6a 59                	push   $0x59
  jmp alltraps
80105537:	e9 c9 f8 ff ff       	jmp    80104e05 <alltraps>

8010553c <vector90>:
.globl vector90
vector90:
  pushl $0
8010553c:	6a 00                	push   $0x0
  pushl $90
8010553e:	6a 5a                	push   $0x5a
  jmp alltraps
80105540:	e9 c0 f8 ff ff       	jmp    80104e05 <alltraps>

80105545 <vector91>:
.globl vector91
vector91:
  pushl $0
80105545:	6a 00                	push   $0x0
  pushl $91
80105547:	6a 5b                	push   $0x5b
  jmp alltraps
80105549:	e9 b7 f8 ff ff       	jmp    80104e05 <alltraps>

8010554e <vector92>:
.globl vector92
vector92:
  pushl $0
8010554e:	6a 00                	push   $0x0
  pushl $92
80105550:	6a 5c                	push   $0x5c
  jmp alltraps
80105552:	e9 ae f8 ff ff       	jmp    80104e05 <alltraps>

80105557 <vector93>:
.globl vector93
vector93:
  pushl $0
80105557:	6a 00                	push   $0x0
  pushl $93
80105559:	6a 5d                	push   $0x5d
  jmp alltraps
8010555b:	e9 a5 f8 ff ff       	jmp    80104e05 <alltraps>

80105560 <vector94>:
.globl vector94
vector94:
  pushl $0
80105560:	6a 00                	push   $0x0
  pushl $94
80105562:	6a 5e                	push   $0x5e
  jmp alltraps
80105564:	e9 9c f8 ff ff       	jmp    80104e05 <alltraps>

80105569 <vector95>:
.globl vector95
vector95:
  pushl $0
80105569:	6a 00                	push   $0x0
  pushl $95
8010556b:	6a 5f                	push   $0x5f
  jmp alltraps
8010556d:	e9 93 f8 ff ff       	jmp    80104e05 <alltraps>

80105572 <vector96>:
.globl vector96
vector96:
  pushl $0
80105572:	6a 00                	push   $0x0
  pushl $96
80105574:	6a 60                	push   $0x60
  jmp alltraps
80105576:	e9 8a f8 ff ff       	jmp    80104e05 <alltraps>

8010557b <vector97>:
.globl vector97
vector97:
  pushl $0
8010557b:	6a 00                	push   $0x0
  pushl $97
8010557d:	6a 61                	push   $0x61
  jmp alltraps
8010557f:	e9 81 f8 ff ff       	jmp    80104e05 <alltraps>

80105584 <vector98>:
.globl vector98
vector98:
  pushl $0
80105584:	6a 00                	push   $0x0
  pushl $98
80105586:	6a 62                	push   $0x62
  jmp alltraps
80105588:	e9 78 f8 ff ff       	jmp    80104e05 <alltraps>

8010558d <vector99>:
.globl vector99
vector99:
  pushl $0
8010558d:	6a 00                	push   $0x0
  pushl $99
8010558f:	6a 63                	push   $0x63
  jmp alltraps
80105591:	e9 6f f8 ff ff       	jmp    80104e05 <alltraps>

80105596 <vector100>:
.globl vector100
vector100:
  pushl $0
80105596:	6a 00                	push   $0x0
  pushl $100
80105598:	6a 64                	push   $0x64
  jmp alltraps
8010559a:	e9 66 f8 ff ff       	jmp    80104e05 <alltraps>

8010559f <vector101>:
.globl vector101
vector101:
  pushl $0
8010559f:	6a 00                	push   $0x0
  pushl $101
801055a1:	6a 65                	push   $0x65
  jmp alltraps
801055a3:	e9 5d f8 ff ff       	jmp    80104e05 <alltraps>

801055a8 <vector102>:
.globl vector102
vector102:
  pushl $0
801055a8:	6a 00                	push   $0x0
  pushl $102
801055aa:	6a 66                	push   $0x66
  jmp alltraps
801055ac:	e9 54 f8 ff ff       	jmp    80104e05 <alltraps>

801055b1 <vector103>:
.globl vector103
vector103:
  pushl $0
801055b1:	6a 00                	push   $0x0
  pushl $103
801055b3:	6a 67                	push   $0x67
  jmp alltraps
801055b5:	e9 4b f8 ff ff       	jmp    80104e05 <alltraps>

801055ba <vector104>:
.globl vector104
vector104:
  pushl $0
801055ba:	6a 00                	push   $0x0
  pushl $104
801055bc:	6a 68                	push   $0x68
  jmp alltraps
801055be:	e9 42 f8 ff ff       	jmp    80104e05 <alltraps>

801055c3 <vector105>:
.globl vector105
vector105:
  pushl $0
801055c3:	6a 00                	push   $0x0
  pushl $105
801055c5:	6a 69                	push   $0x69
  jmp alltraps
801055c7:	e9 39 f8 ff ff       	jmp    80104e05 <alltraps>

801055cc <vector106>:
.globl vector106
vector106:
  pushl $0
801055cc:	6a 00                	push   $0x0
  pushl $106
801055ce:	6a 6a                	push   $0x6a
  jmp alltraps
801055d0:	e9 30 f8 ff ff       	jmp    80104e05 <alltraps>

801055d5 <vector107>:
.globl vector107
vector107:
  pushl $0
801055d5:	6a 00                	push   $0x0
  pushl $107
801055d7:	6a 6b                	push   $0x6b
  jmp alltraps
801055d9:	e9 27 f8 ff ff       	jmp    80104e05 <alltraps>

801055de <vector108>:
.globl vector108
vector108:
  pushl $0
801055de:	6a 00                	push   $0x0
  pushl $108
801055e0:	6a 6c                	push   $0x6c
  jmp alltraps
801055e2:	e9 1e f8 ff ff       	jmp    80104e05 <alltraps>

801055e7 <vector109>:
.globl vector109
vector109:
  pushl $0
801055e7:	6a 00                	push   $0x0
  pushl $109
801055e9:	6a 6d                	push   $0x6d
  jmp alltraps
801055eb:	e9 15 f8 ff ff       	jmp    80104e05 <alltraps>

801055f0 <vector110>:
.globl vector110
vector110:
  pushl $0
801055f0:	6a 00                	push   $0x0
  pushl $110
801055f2:	6a 6e                	push   $0x6e
  jmp alltraps
801055f4:	e9 0c f8 ff ff       	jmp    80104e05 <alltraps>

801055f9 <vector111>:
.globl vector111
vector111:
  pushl $0
801055f9:	6a 00                	push   $0x0
  pushl $111
801055fb:	6a 6f                	push   $0x6f
  jmp alltraps
801055fd:	e9 03 f8 ff ff       	jmp    80104e05 <alltraps>

80105602 <vector112>:
.globl vector112
vector112:
  pushl $0
80105602:	6a 00                	push   $0x0
  pushl $112
80105604:	6a 70                	push   $0x70
  jmp alltraps
80105606:	e9 fa f7 ff ff       	jmp    80104e05 <alltraps>

8010560b <vector113>:
.globl vector113
vector113:
  pushl $0
8010560b:	6a 00                	push   $0x0
  pushl $113
8010560d:	6a 71                	push   $0x71
  jmp alltraps
8010560f:	e9 f1 f7 ff ff       	jmp    80104e05 <alltraps>

80105614 <vector114>:
.globl vector114
vector114:
  pushl $0
80105614:	6a 00                	push   $0x0
  pushl $114
80105616:	6a 72                	push   $0x72
  jmp alltraps
80105618:	e9 e8 f7 ff ff       	jmp    80104e05 <alltraps>

8010561d <vector115>:
.globl vector115
vector115:
  pushl $0
8010561d:	6a 00                	push   $0x0
  pushl $115
8010561f:	6a 73                	push   $0x73
  jmp alltraps
80105621:	e9 df f7 ff ff       	jmp    80104e05 <alltraps>

80105626 <vector116>:
.globl vector116
vector116:
  pushl $0
80105626:	6a 00                	push   $0x0
  pushl $116
80105628:	6a 74                	push   $0x74
  jmp alltraps
8010562a:	e9 d6 f7 ff ff       	jmp    80104e05 <alltraps>

8010562f <vector117>:
.globl vector117
vector117:
  pushl $0
8010562f:	6a 00                	push   $0x0
  pushl $117
80105631:	6a 75                	push   $0x75
  jmp alltraps
80105633:	e9 cd f7 ff ff       	jmp    80104e05 <alltraps>

80105638 <vector118>:
.globl vector118
vector118:
  pushl $0
80105638:	6a 00                	push   $0x0
  pushl $118
8010563a:	6a 76                	push   $0x76
  jmp alltraps
8010563c:	e9 c4 f7 ff ff       	jmp    80104e05 <alltraps>

80105641 <vector119>:
.globl vector119
vector119:
  pushl $0
80105641:	6a 00                	push   $0x0
  pushl $119
80105643:	6a 77                	push   $0x77
  jmp alltraps
80105645:	e9 bb f7 ff ff       	jmp    80104e05 <alltraps>

8010564a <vector120>:
.globl vector120
vector120:
  pushl $0
8010564a:	6a 00                	push   $0x0
  pushl $120
8010564c:	6a 78                	push   $0x78
  jmp alltraps
8010564e:	e9 b2 f7 ff ff       	jmp    80104e05 <alltraps>

80105653 <vector121>:
.globl vector121
vector121:
  pushl $0
80105653:	6a 00                	push   $0x0
  pushl $121
80105655:	6a 79                	push   $0x79
  jmp alltraps
80105657:	e9 a9 f7 ff ff       	jmp    80104e05 <alltraps>

8010565c <vector122>:
.globl vector122
vector122:
  pushl $0
8010565c:	6a 00                	push   $0x0
  pushl $122
8010565e:	6a 7a                	push   $0x7a
  jmp alltraps
80105660:	e9 a0 f7 ff ff       	jmp    80104e05 <alltraps>

80105665 <vector123>:
.globl vector123
vector123:
  pushl $0
80105665:	6a 00                	push   $0x0
  pushl $123
80105667:	6a 7b                	push   $0x7b
  jmp alltraps
80105669:	e9 97 f7 ff ff       	jmp    80104e05 <alltraps>

8010566e <vector124>:
.globl vector124
vector124:
  pushl $0
8010566e:	6a 00                	push   $0x0
  pushl $124
80105670:	6a 7c                	push   $0x7c
  jmp alltraps
80105672:	e9 8e f7 ff ff       	jmp    80104e05 <alltraps>

80105677 <vector125>:
.globl vector125
vector125:
  pushl $0
80105677:	6a 00                	push   $0x0
  pushl $125
80105679:	6a 7d                	push   $0x7d
  jmp alltraps
8010567b:	e9 85 f7 ff ff       	jmp    80104e05 <alltraps>

80105680 <vector126>:
.globl vector126
vector126:
  pushl $0
80105680:	6a 00                	push   $0x0
  pushl $126
80105682:	6a 7e                	push   $0x7e
  jmp alltraps
80105684:	e9 7c f7 ff ff       	jmp    80104e05 <alltraps>

80105689 <vector127>:
.globl vector127
vector127:
  pushl $0
80105689:	6a 00                	push   $0x0
  pushl $127
8010568b:	6a 7f                	push   $0x7f
  jmp alltraps
8010568d:	e9 73 f7 ff ff       	jmp    80104e05 <alltraps>

80105692 <vector128>:
.globl vector128
vector128:
  pushl $0
80105692:	6a 00                	push   $0x0
  pushl $128
80105694:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80105699:	e9 67 f7 ff ff       	jmp    80104e05 <alltraps>

8010569e <vector129>:
.globl vector129
vector129:
  pushl $0
8010569e:	6a 00                	push   $0x0
  pushl $129
801056a0:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801056a5:	e9 5b f7 ff ff       	jmp    80104e05 <alltraps>

801056aa <vector130>:
.globl vector130
vector130:
  pushl $0
801056aa:	6a 00                	push   $0x0
  pushl $130
801056ac:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801056b1:	e9 4f f7 ff ff       	jmp    80104e05 <alltraps>

801056b6 <vector131>:
.globl vector131
vector131:
  pushl $0
801056b6:	6a 00                	push   $0x0
  pushl $131
801056b8:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801056bd:	e9 43 f7 ff ff       	jmp    80104e05 <alltraps>

801056c2 <vector132>:
.globl vector132
vector132:
  pushl $0
801056c2:	6a 00                	push   $0x0
  pushl $132
801056c4:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801056c9:	e9 37 f7 ff ff       	jmp    80104e05 <alltraps>

801056ce <vector133>:
.globl vector133
vector133:
  pushl $0
801056ce:	6a 00                	push   $0x0
  pushl $133
801056d0:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801056d5:	e9 2b f7 ff ff       	jmp    80104e05 <alltraps>

801056da <vector134>:
.globl vector134
vector134:
  pushl $0
801056da:	6a 00                	push   $0x0
  pushl $134
801056dc:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801056e1:	e9 1f f7 ff ff       	jmp    80104e05 <alltraps>

801056e6 <vector135>:
.globl vector135
vector135:
  pushl $0
801056e6:	6a 00                	push   $0x0
  pushl $135
801056e8:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801056ed:	e9 13 f7 ff ff       	jmp    80104e05 <alltraps>

801056f2 <vector136>:
.globl vector136
vector136:
  pushl $0
801056f2:	6a 00                	push   $0x0
  pushl $136
801056f4:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801056f9:	e9 07 f7 ff ff       	jmp    80104e05 <alltraps>

801056fe <vector137>:
.globl vector137
vector137:
  pushl $0
801056fe:	6a 00                	push   $0x0
  pushl $137
80105700:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80105705:	e9 fb f6 ff ff       	jmp    80104e05 <alltraps>

8010570a <vector138>:
.globl vector138
vector138:
  pushl $0
8010570a:	6a 00                	push   $0x0
  pushl $138
8010570c:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80105711:	e9 ef f6 ff ff       	jmp    80104e05 <alltraps>

80105716 <vector139>:
.globl vector139
vector139:
  pushl $0
80105716:	6a 00                	push   $0x0
  pushl $139
80105718:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010571d:	e9 e3 f6 ff ff       	jmp    80104e05 <alltraps>

80105722 <vector140>:
.globl vector140
vector140:
  pushl $0
80105722:	6a 00                	push   $0x0
  pushl $140
80105724:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80105729:	e9 d7 f6 ff ff       	jmp    80104e05 <alltraps>

8010572e <vector141>:
.globl vector141
vector141:
  pushl $0
8010572e:	6a 00                	push   $0x0
  pushl $141
80105730:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80105735:	e9 cb f6 ff ff       	jmp    80104e05 <alltraps>

8010573a <vector142>:
.globl vector142
vector142:
  pushl $0
8010573a:	6a 00                	push   $0x0
  pushl $142
8010573c:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105741:	e9 bf f6 ff ff       	jmp    80104e05 <alltraps>

80105746 <vector143>:
.globl vector143
vector143:
  pushl $0
80105746:	6a 00                	push   $0x0
  pushl $143
80105748:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010574d:	e9 b3 f6 ff ff       	jmp    80104e05 <alltraps>

80105752 <vector144>:
.globl vector144
vector144:
  pushl $0
80105752:	6a 00                	push   $0x0
  pushl $144
80105754:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80105759:	e9 a7 f6 ff ff       	jmp    80104e05 <alltraps>

8010575e <vector145>:
.globl vector145
vector145:
  pushl $0
8010575e:	6a 00                	push   $0x0
  pushl $145
80105760:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105765:	e9 9b f6 ff ff       	jmp    80104e05 <alltraps>

8010576a <vector146>:
.globl vector146
vector146:
  pushl $0
8010576a:	6a 00                	push   $0x0
  pushl $146
8010576c:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105771:	e9 8f f6 ff ff       	jmp    80104e05 <alltraps>

80105776 <vector147>:
.globl vector147
vector147:
  pushl $0
80105776:	6a 00                	push   $0x0
  pushl $147
80105778:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010577d:	e9 83 f6 ff ff       	jmp    80104e05 <alltraps>

80105782 <vector148>:
.globl vector148
vector148:
  pushl $0
80105782:	6a 00                	push   $0x0
  pushl $148
80105784:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105789:	e9 77 f6 ff ff       	jmp    80104e05 <alltraps>

8010578e <vector149>:
.globl vector149
vector149:
  pushl $0
8010578e:	6a 00                	push   $0x0
  pushl $149
80105790:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105795:	e9 6b f6 ff ff       	jmp    80104e05 <alltraps>

8010579a <vector150>:
.globl vector150
vector150:
  pushl $0
8010579a:	6a 00                	push   $0x0
  pushl $150
8010579c:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801057a1:	e9 5f f6 ff ff       	jmp    80104e05 <alltraps>

801057a6 <vector151>:
.globl vector151
vector151:
  pushl $0
801057a6:	6a 00                	push   $0x0
  pushl $151
801057a8:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801057ad:	e9 53 f6 ff ff       	jmp    80104e05 <alltraps>

801057b2 <vector152>:
.globl vector152
vector152:
  pushl $0
801057b2:	6a 00                	push   $0x0
  pushl $152
801057b4:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801057b9:	e9 47 f6 ff ff       	jmp    80104e05 <alltraps>

801057be <vector153>:
.globl vector153
vector153:
  pushl $0
801057be:	6a 00                	push   $0x0
  pushl $153
801057c0:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801057c5:	e9 3b f6 ff ff       	jmp    80104e05 <alltraps>

801057ca <vector154>:
.globl vector154
vector154:
  pushl $0
801057ca:	6a 00                	push   $0x0
  pushl $154
801057cc:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801057d1:	e9 2f f6 ff ff       	jmp    80104e05 <alltraps>

801057d6 <vector155>:
.globl vector155
vector155:
  pushl $0
801057d6:	6a 00                	push   $0x0
  pushl $155
801057d8:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801057dd:	e9 23 f6 ff ff       	jmp    80104e05 <alltraps>

801057e2 <vector156>:
.globl vector156
vector156:
  pushl $0
801057e2:	6a 00                	push   $0x0
  pushl $156
801057e4:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801057e9:	e9 17 f6 ff ff       	jmp    80104e05 <alltraps>

801057ee <vector157>:
.globl vector157
vector157:
  pushl $0
801057ee:	6a 00                	push   $0x0
  pushl $157
801057f0:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801057f5:	e9 0b f6 ff ff       	jmp    80104e05 <alltraps>

801057fa <vector158>:
.globl vector158
vector158:
  pushl $0
801057fa:	6a 00                	push   $0x0
  pushl $158
801057fc:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80105801:	e9 ff f5 ff ff       	jmp    80104e05 <alltraps>

80105806 <vector159>:
.globl vector159
vector159:
  pushl $0
80105806:	6a 00                	push   $0x0
  pushl $159
80105808:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010580d:	e9 f3 f5 ff ff       	jmp    80104e05 <alltraps>

80105812 <vector160>:
.globl vector160
vector160:
  pushl $0
80105812:	6a 00                	push   $0x0
  pushl $160
80105814:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80105819:	e9 e7 f5 ff ff       	jmp    80104e05 <alltraps>

8010581e <vector161>:
.globl vector161
vector161:
  pushl $0
8010581e:	6a 00                	push   $0x0
  pushl $161
80105820:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105825:	e9 db f5 ff ff       	jmp    80104e05 <alltraps>

8010582a <vector162>:
.globl vector162
vector162:
  pushl $0
8010582a:	6a 00                	push   $0x0
  pushl $162
8010582c:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105831:	e9 cf f5 ff ff       	jmp    80104e05 <alltraps>

80105836 <vector163>:
.globl vector163
vector163:
  pushl $0
80105836:	6a 00                	push   $0x0
  pushl $163
80105838:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010583d:	e9 c3 f5 ff ff       	jmp    80104e05 <alltraps>

80105842 <vector164>:
.globl vector164
vector164:
  pushl $0
80105842:	6a 00                	push   $0x0
  pushl $164
80105844:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105849:	e9 b7 f5 ff ff       	jmp    80104e05 <alltraps>

8010584e <vector165>:
.globl vector165
vector165:
  pushl $0
8010584e:	6a 00                	push   $0x0
  pushl $165
80105850:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105855:	e9 ab f5 ff ff       	jmp    80104e05 <alltraps>

8010585a <vector166>:
.globl vector166
vector166:
  pushl $0
8010585a:	6a 00                	push   $0x0
  pushl $166
8010585c:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105861:	e9 9f f5 ff ff       	jmp    80104e05 <alltraps>

80105866 <vector167>:
.globl vector167
vector167:
  pushl $0
80105866:	6a 00                	push   $0x0
  pushl $167
80105868:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010586d:	e9 93 f5 ff ff       	jmp    80104e05 <alltraps>

80105872 <vector168>:
.globl vector168
vector168:
  pushl $0
80105872:	6a 00                	push   $0x0
  pushl $168
80105874:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105879:	e9 87 f5 ff ff       	jmp    80104e05 <alltraps>

8010587e <vector169>:
.globl vector169
vector169:
  pushl $0
8010587e:	6a 00                	push   $0x0
  pushl $169
80105880:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105885:	e9 7b f5 ff ff       	jmp    80104e05 <alltraps>

8010588a <vector170>:
.globl vector170
vector170:
  pushl $0
8010588a:	6a 00                	push   $0x0
  pushl $170
8010588c:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105891:	e9 6f f5 ff ff       	jmp    80104e05 <alltraps>

80105896 <vector171>:
.globl vector171
vector171:
  pushl $0
80105896:	6a 00                	push   $0x0
  pushl $171
80105898:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010589d:	e9 63 f5 ff ff       	jmp    80104e05 <alltraps>

801058a2 <vector172>:
.globl vector172
vector172:
  pushl $0
801058a2:	6a 00                	push   $0x0
  pushl $172
801058a4:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801058a9:	e9 57 f5 ff ff       	jmp    80104e05 <alltraps>

801058ae <vector173>:
.globl vector173
vector173:
  pushl $0
801058ae:	6a 00                	push   $0x0
  pushl $173
801058b0:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801058b5:	e9 4b f5 ff ff       	jmp    80104e05 <alltraps>

801058ba <vector174>:
.globl vector174
vector174:
  pushl $0
801058ba:	6a 00                	push   $0x0
  pushl $174
801058bc:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801058c1:	e9 3f f5 ff ff       	jmp    80104e05 <alltraps>

801058c6 <vector175>:
.globl vector175
vector175:
  pushl $0
801058c6:	6a 00                	push   $0x0
  pushl $175
801058c8:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801058cd:	e9 33 f5 ff ff       	jmp    80104e05 <alltraps>

801058d2 <vector176>:
.globl vector176
vector176:
  pushl $0
801058d2:	6a 00                	push   $0x0
  pushl $176
801058d4:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801058d9:	e9 27 f5 ff ff       	jmp    80104e05 <alltraps>

801058de <vector177>:
.globl vector177
vector177:
  pushl $0
801058de:	6a 00                	push   $0x0
  pushl $177
801058e0:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801058e5:	e9 1b f5 ff ff       	jmp    80104e05 <alltraps>

801058ea <vector178>:
.globl vector178
vector178:
  pushl $0
801058ea:	6a 00                	push   $0x0
  pushl $178
801058ec:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801058f1:	e9 0f f5 ff ff       	jmp    80104e05 <alltraps>

801058f6 <vector179>:
.globl vector179
vector179:
  pushl $0
801058f6:	6a 00                	push   $0x0
  pushl $179
801058f8:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801058fd:	e9 03 f5 ff ff       	jmp    80104e05 <alltraps>

80105902 <vector180>:
.globl vector180
vector180:
  pushl $0
80105902:	6a 00                	push   $0x0
  pushl $180
80105904:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105909:	e9 f7 f4 ff ff       	jmp    80104e05 <alltraps>

8010590e <vector181>:
.globl vector181
vector181:
  pushl $0
8010590e:	6a 00                	push   $0x0
  pushl $181
80105910:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105915:	e9 eb f4 ff ff       	jmp    80104e05 <alltraps>

8010591a <vector182>:
.globl vector182
vector182:
  pushl $0
8010591a:	6a 00                	push   $0x0
  pushl $182
8010591c:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105921:	e9 df f4 ff ff       	jmp    80104e05 <alltraps>

80105926 <vector183>:
.globl vector183
vector183:
  pushl $0
80105926:	6a 00                	push   $0x0
  pushl $183
80105928:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010592d:	e9 d3 f4 ff ff       	jmp    80104e05 <alltraps>

80105932 <vector184>:
.globl vector184
vector184:
  pushl $0
80105932:	6a 00                	push   $0x0
  pushl $184
80105934:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105939:	e9 c7 f4 ff ff       	jmp    80104e05 <alltraps>

8010593e <vector185>:
.globl vector185
vector185:
  pushl $0
8010593e:	6a 00                	push   $0x0
  pushl $185
80105940:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105945:	e9 bb f4 ff ff       	jmp    80104e05 <alltraps>

8010594a <vector186>:
.globl vector186
vector186:
  pushl $0
8010594a:	6a 00                	push   $0x0
  pushl $186
8010594c:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105951:	e9 af f4 ff ff       	jmp    80104e05 <alltraps>

80105956 <vector187>:
.globl vector187
vector187:
  pushl $0
80105956:	6a 00                	push   $0x0
  pushl $187
80105958:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010595d:	e9 a3 f4 ff ff       	jmp    80104e05 <alltraps>

80105962 <vector188>:
.globl vector188
vector188:
  pushl $0
80105962:	6a 00                	push   $0x0
  pushl $188
80105964:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105969:	e9 97 f4 ff ff       	jmp    80104e05 <alltraps>

8010596e <vector189>:
.globl vector189
vector189:
  pushl $0
8010596e:	6a 00                	push   $0x0
  pushl $189
80105970:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105975:	e9 8b f4 ff ff       	jmp    80104e05 <alltraps>

8010597a <vector190>:
.globl vector190
vector190:
  pushl $0
8010597a:	6a 00                	push   $0x0
  pushl $190
8010597c:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105981:	e9 7f f4 ff ff       	jmp    80104e05 <alltraps>

80105986 <vector191>:
.globl vector191
vector191:
  pushl $0
80105986:	6a 00                	push   $0x0
  pushl $191
80105988:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010598d:	e9 73 f4 ff ff       	jmp    80104e05 <alltraps>

80105992 <vector192>:
.globl vector192
vector192:
  pushl $0
80105992:	6a 00                	push   $0x0
  pushl $192
80105994:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105999:	e9 67 f4 ff ff       	jmp    80104e05 <alltraps>

8010599e <vector193>:
.globl vector193
vector193:
  pushl $0
8010599e:	6a 00                	push   $0x0
  pushl $193
801059a0:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801059a5:	e9 5b f4 ff ff       	jmp    80104e05 <alltraps>

801059aa <vector194>:
.globl vector194
vector194:
  pushl $0
801059aa:	6a 00                	push   $0x0
  pushl $194
801059ac:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801059b1:	e9 4f f4 ff ff       	jmp    80104e05 <alltraps>

801059b6 <vector195>:
.globl vector195
vector195:
  pushl $0
801059b6:	6a 00                	push   $0x0
  pushl $195
801059b8:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801059bd:	e9 43 f4 ff ff       	jmp    80104e05 <alltraps>

801059c2 <vector196>:
.globl vector196
vector196:
  pushl $0
801059c2:	6a 00                	push   $0x0
  pushl $196
801059c4:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801059c9:	e9 37 f4 ff ff       	jmp    80104e05 <alltraps>

801059ce <vector197>:
.globl vector197
vector197:
  pushl $0
801059ce:	6a 00                	push   $0x0
  pushl $197
801059d0:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801059d5:	e9 2b f4 ff ff       	jmp    80104e05 <alltraps>

801059da <vector198>:
.globl vector198
vector198:
  pushl $0
801059da:	6a 00                	push   $0x0
  pushl $198
801059dc:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801059e1:	e9 1f f4 ff ff       	jmp    80104e05 <alltraps>

801059e6 <vector199>:
.globl vector199
vector199:
  pushl $0
801059e6:	6a 00                	push   $0x0
  pushl $199
801059e8:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801059ed:	e9 13 f4 ff ff       	jmp    80104e05 <alltraps>

801059f2 <vector200>:
.globl vector200
vector200:
  pushl $0
801059f2:	6a 00                	push   $0x0
  pushl $200
801059f4:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801059f9:	e9 07 f4 ff ff       	jmp    80104e05 <alltraps>

801059fe <vector201>:
.globl vector201
vector201:
  pushl $0
801059fe:	6a 00                	push   $0x0
  pushl $201
80105a00:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105a05:	e9 fb f3 ff ff       	jmp    80104e05 <alltraps>

80105a0a <vector202>:
.globl vector202
vector202:
  pushl $0
80105a0a:	6a 00                	push   $0x0
  pushl $202
80105a0c:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105a11:	e9 ef f3 ff ff       	jmp    80104e05 <alltraps>

80105a16 <vector203>:
.globl vector203
vector203:
  pushl $0
80105a16:	6a 00                	push   $0x0
  pushl $203
80105a18:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105a1d:	e9 e3 f3 ff ff       	jmp    80104e05 <alltraps>

80105a22 <vector204>:
.globl vector204
vector204:
  pushl $0
80105a22:	6a 00                	push   $0x0
  pushl $204
80105a24:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105a29:	e9 d7 f3 ff ff       	jmp    80104e05 <alltraps>

80105a2e <vector205>:
.globl vector205
vector205:
  pushl $0
80105a2e:	6a 00                	push   $0x0
  pushl $205
80105a30:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105a35:	e9 cb f3 ff ff       	jmp    80104e05 <alltraps>

80105a3a <vector206>:
.globl vector206
vector206:
  pushl $0
80105a3a:	6a 00                	push   $0x0
  pushl $206
80105a3c:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105a41:	e9 bf f3 ff ff       	jmp    80104e05 <alltraps>

80105a46 <vector207>:
.globl vector207
vector207:
  pushl $0
80105a46:	6a 00                	push   $0x0
  pushl $207
80105a48:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105a4d:	e9 b3 f3 ff ff       	jmp    80104e05 <alltraps>

80105a52 <vector208>:
.globl vector208
vector208:
  pushl $0
80105a52:	6a 00                	push   $0x0
  pushl $208
80105a54:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105a59:	e9 a7 f3 ff ff       	jmp    80104e05 <alltraps>

80105a5e <vector209>:
.globl vector209
vector209:
  pushl $0
80105a5e:	6a 00                	push   $0x0
  pushl $209
80105a60:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105a65:	e9 9b f3 ff ff       	jmp    80104e05 <alltraps>

80105a6a <vector210>:
.globl vector210
vector210:
  pushl $0
80105a6a:	6a 00                	push   $0x0
  pushl $210
80105a6c:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105a71:	e9 8f f3 ff ff       	jmp    80104e05 <alltraps>

80105a76 <vector211>:
.globl vector211
vector211:
  pushl $0
80105a76:	6a 00                	push   $0x0
  pushl $211
80105a78:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105a7d:	e9 83 f3 ff ff       	jmp    80104e05 <alltraps>

80105a82 <vector212>:
.globl vector212
vector212:
  pushl $0
80105a82:	6a 00                	push   $0x0
  pushl $212
80105a84:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105a89:	e9 77 f3 ff ff       	jmp    80104e05 <alltraps>

80105a8e <vector213>:
.globl vector213
vector213:
  pushl $0
80105a8e:	6a 00                	push   $0x0
  pushl $213
80105a90:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105a95:	e9 6b f3 ff ff       	jmp    80104e05 <alltraps>

80105a9a <vector214>:
.globl vector214
vector214:
  pushl $0
80105a9a:	6a 00                	push   $0x0
  pushl $214
80105a9c:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105aa1:	e9 5f f3 ff ff       	jmp    80104e05 <alltraps>

80105aa6 <vector215>:
.globl vector215
vector215:
  pushl $0
80105aa6:	6a 00                	push   $0x0
  pushl $215
80105aa8:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105aad:	e9 53 f3 ff ff       	jmp    80104e05 <alltraps>

80105ab2 <vector216>:
.globl vector216
vector216:
  pushl $0
80105ab2:	6a 00                	push   $0x0
  pushl $216
80105ab4:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105ab9:	e9 47 f3 ff ff       	jmp    80104e05 <alltraps>

80105abe <vector217>:
.globl vector217
vector217:
  pushl $0
80105abe:	6a 00                	push   $0x0
  pushl $217
80105ac0:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105ac5:	e9 3b f3 ff ff       	jmp    80104e05 <alltraps>

80105aca <vector218>:
.globl vector218
vector218:
  pushl $0
80105aca:	6a 00                	push   $0x0
  pushl $218
80105acc:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105ad1:	e9 2f f3 ff ff       	jmp    80104e05 <alltraps>

80105ad6 <vector219>:
.globl vector219
vector219:
  pushl $0
80105ad6:	6a 00                	push   $0x0
  pushl $219
80105ad8:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105add:	e9 23 f3 ff ff       	jmp    80104e05 <alltraps>

80105ae2 <vector220>:
.globl vector220
vector220:
  pushl $0
80105ae2:	6a 00                	push   $0x0
  pushl $220
80105ae4:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105ae9:	e9 17 f3 ff ff       	jmp    80104e05 <alltraps>

80105aee <vector221>:
.globl vector221
vector221:
  pushl $0
80105aee:	6a 00                	push   $0x0
  pushl $221
80105af0:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105af5:	e9 0b f3 ff ff       	jmp    80104e05 <alltraps>

80105afa <vector222>:
.globl vector222
vector222:
  pushl $0
80105afa:	6a 00                	push   $0x0
  pushl $222
80105afc:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105b01:	e9 ff f2 ff ff       	jmp    80104e05 <alltraps>

80105b06 <vector223>:
.globl vector223
vector223:
  pushl $0
80105b06:	6a 00                	push   $0x0
  pushl $223
80105b08:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105b0d:	e9 f3 f2 ff ff       	jmp    80104e05 <alltraps>

80105b12 <vector224>:
.globl vector224
vector224:
  pushl $0
80105b12:	6a 00                	push   $0x0
  pushl $224
80105b14:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105b19:	e9 e7 f2 ff ff       	jmp    80104e05 <alltraps>

80105b1e <vector225>:
.globl vector225
vector225:
  pushl $0
80105b1e:	6a 00                	push   $0x0
  pushl $225
80105b20:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105b25:	e9 db f2 ff ff       	jmp    80104e05 <alltraps>

80105b2a <vector226>:
.globl vector226
vector226:
  pushl $0
80105b2a:	6a 00                	push   $0x0
  pushl $226
80105b2c:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105b31:	e9 cf f2 ff ff       	jmp    80104e05 <alltraps>

80105b36 <vector227>:
.globl vector227
vector227:
  pushl $0
80105b36:	6a 00                	push   $0x0
  pushl $227
80105b38:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105b3d:	e9 c3 f2 ff ff       	jmp    80104e05 <alltraps>

80105b42 <vector228>:
.globl vector228
vector228:
  pushl $0
80105b42:	6a 00                	push   $0x0
  pushl $228
80105b44:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105b49:	e9 b7 f2 ff ff       	jmp    80104e05 <alltraps>

80105b4e <vector229>:
.globl vector229
vector229:
  pushl $0
80105b4e:	6a 00                	push   $0x0
  pushl $229
80105b50:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105b55:	e9 ab f2 ff ff       	jmp    80104e05 <alltraps>

80105b5a <vector230>:
.globl vector230
vector230:
  pushl $0
80105b5a:	6a 00                	push   $0x0
  pushl $230
80105b5c:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105b61:	e9 9f f2 ff ff       	jmp    80104e05 <alltraps>

80105b66 <vector231>:
.globl vector231
vector231:
  pushl $0
80105b66:	6a 00                	push   $0x0
  pushl $231
80105b68:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105b6d:	e9 93 f2 ff ff       	jmp    80104e05 <alltraps>

80105b72 <vector232>:
.globl vector232
vector232:
  pushl $0
80105b72:	6a 00                	push   $0x0
  pushl $232
80105b74:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105b79:	e9 87 f2 ff ff       	jmp    80104e05 <alltraps>

80105b7e <vector233>:
.globl vector233
vector233:
  pushl $0
80105b7e:	6a 00                	push   $0x0
  pushl $233
80105b80:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105b85:	e9 7b f2 ff ff       	jmp    80104e05 <alltraps>

80105b8a <vector234>:
.globl vector234
vector234:
  pushl $0
80105b8a:	6a 00                	push   $0x0
  pushl $234
80105b8c:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105b91:	e9 6f f2 ff ff       	jmp    80104e05 <alltraps>

80105b96 <vector235>:
.globl vector235
vector235:
  pushl $0
80105b96:	6a 00                	push   $0x0
  pushl $235
80105b98:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105b9d:	e9 63 f2 ff ff       	jmp    80104e05 <alltraps>

80105ba2 <vector236>:
.globl vector236
vector236:
  pushl $0
80105ba2:	6a 00                	push   $0x0
  pushl $236
80105ba4:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105ba9:	e9 57 f2 ff ff       	jmp    80104e05 <alltraps>

80105bae <vector237>:
.globl vector237
vector237:
  pushl $0
80105bae:	6a 00                	push   $0x0
  pushl $237
80105bb0:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105bb5:	e9 4b f2 ff ff       	jmp    80104e05 <alltraps>

80105bba <vector238>:
.globl vector238
vector238:
  pushl $0
80105bba:	6a 00                	push   $0x0
  pushl $238
80105bbc:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105bc1:	e9 3f f2 ff ff       	jmp    80104e05 <alltraps>

80105bc6 <vector239>:
.globl vector239
vector239:
  pushl $0
80105bc6:	6a 00                	push   $0x0
  pushl $239
80105bc8:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105bcd:	e9 33 f2 ff ff       	jmp    80104e05 <alltraps>

80105bd2 <vector240>:
.globl vector240
vector240:
  pushl $0
80105bd2:	6a 00                	push   $0x0
  pushl $240
80105bd4:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105bd9:	e9 27 f2 ff ff       	jmp    80104e05 <alltraps>

80105bde <vector241>:
.globl vector241
vector241:
  pushl $0
80105bde:	6a 00                	push   $0x0
  pushl $241
80105be0:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105be5:	e9 1b f2 ff ff       	jmp    80104e05 <alltraps>

80105bea <vector242>:
.globl vector242
vector242:
  pushl $0
80105bea:	6a 00                	push   $0x0
  pushl $242
80105bec:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105bf1:	e9 0f f2 ff ff       	jmp    80104e05 <alltraps>

80105bf6 <vector243>:
.globl vector243
vector243:
  pushl $0
80105bf6:	6a 00                	push   $0x0
  pushl $243
80105bf8:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105bfd:	e9 03 f2 ff ff       	jmp    80104e05 <alltraps>

80105c02 <vector244>:
.globl vector244
vector244:
  pushl $0
80105c02:	6a 00                	push   $0x0
  pushl $244
80105c04:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105c09:	e9 f7 f1 ff ff       	jmp    80104e05 <alltraps>

80105c0e <vector245>:
.globl vector245
vector245:
  pushl $0
80105c0e:	6a 00                	push   $0x0
  pushl $245
80105c10:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105c15:	e9 eb f1 ff ff       	jmp    80104e05 <alltraps>

80105c1a <vector246>:
.globl vector246
vector246:
  pushl $0
80105c1a:	6a 00                	push   $0x0
  pushl $246
80105c1c:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105c21:	e9 df f1 ff ff       	jmp    80104e05 <alltraps>

80105c26 <vector247>:
.globl vector247
vector247:
  pushl $0
80105c26:	6a 00                	push   $0x0
  pushl $247
80105c28:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105c2d:	e9 d3 f1 ff ff       	jmp    80104e05 <alltraps>

80105c32 <vector248>:
.globl vector248
vector248:
  pushl $0
80105c32:	6a 00                	push   $0x0
  pushl $248
80105c34:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105c39:	e9 c7 f1 ff ff       	jmp    80104e05 <alltraps>

80105c3e <vector249>:
.globl vector249
vector249:
  pushl $0
80105c3e:	6a 00                	push   $0x0
  pushl $249
80105c40:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105c45:	e9 bb f1 ff ff       	jmp    80104e05 <alltraps>

80105c4a <vector250>:
.globl vector250
vector250:
  pushl $0
80105c4a:	6a 00                	push   $0x0
  pushl $250
80105c4c:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105c51:	e9 af f1 ff ff       	jmp    80104e05 <alltraps>

80105c56 <vector251>:
.globl vector251
vector251:
  pushl $0
80105c56:	6a 00                	push   $0x0
  pushl $251
80105c58:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105c5d:	e9 a3 f1 ff ff       	jmp    80104e05 <alltraps>

80105c62 <vector252>:
.globl vector252
vector252:
  pushl $0
80105c62:	6a 00                	push   $0x0
  pushl $252
80105c64:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105c69:	e9 97 f1 ff ff       	jmp    80104e05 <alltraps>

80105c6e <vector253>:
.globl vector253
vector253:
  pushl $0
80105c6e:	6a 00                	push   $0x0
  pushl $253
80105c70:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105c75:	e9 8b f1 ff ff       	jmp    80104e05 <alltraps>

80105c7a <vector254>:
.globl vector254
vector254:
  pushl $0
80105c7a:	6a 00                	push   $0x0
  pushl $254
80105c7c:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105c81:	e9 7f f1 ff ff       	jmp    80104e05 <alltraps>

80105c86 <vector255>:
.globl vector255
vector255:
  pushl $0
80105c86:	6a 00                	push   $0x0
  pushl $255
80105c88:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105c8d:	e9 73 f1 ff ff       	jmp    80104e05 <alltraps>
80105c92:	66 90                	xchg   %ax,%ax
80105c94:	66 90                	xchg   %ax,%ax
80105c96:	66 90                	xchg   %ax,%ax
80105c98:	66 90                	xchg   %ax,%ax
80105c9a:	66 90                	xchg   %ax,%ax
80105c9c:	66 90                	xchg   %ax,%ax
80105c9e:	66 90                	xchg   %ax,%ax

80105ca0 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105ca0:	55                   	push   %ebp
80105ca1:	89 e5                	mov    %esp,%ebp
80105ca3:	57                   	push   %edi
80105ca4:	56                   	push   %esi
80105ca5:	53                   	push   %ebx
80105ca6:	83 ec 1c             	sub    $0x1c,%esp
80105ca9:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105cab:	c1 ea 16             	shr    $0x16,%edx
80105cae:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105cb1:	8b 1f                	mov    (%edi),%ebx
80105cb3:	f6 c3 01             	test   $0x1,%bl
80105cb6:	74 22                	je     80105cda <walkpgdir+0x3a>

#ifndef __ASSEMBLER__
// Address in page table or page directory entry
//   I changes these from macros into inline functions to make sure we
//   consistently get an error if a pointer is erroneously passed to them.
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
80105cb8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    if (a > KERNBASE)
80105cbe:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80105cc4:	76 0c                	jbe    80105cd2 <walkpgdir+0x32>
        panic("P2V on address > KERNBASE");
80105cc6:	c7 04 24 78 6b 10 80 	movl   $0x80106b78,(%esp)
80105ccd:	e8 53 a6 ff ff       	call   80100325 <panic>
    return (char*)a + KERNBASE;
80105cd2:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
80105cd8:	eb 46                	jmp    80105d20 <walkpgdir+0x80>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105cda:	85 c9                	test   %ecx,%ecx
80105cdc:	74 50                	je     80105d2e <walkpgdir+0x8e>
80105cde:	e8 76 c4 ff ff       	call   80102159 <kalloc>
80105ce3:	89 c3                	mov    %eax,%ebx
80105ce5:	85 c0                	test   %eax,%eax
80105ce7:	74 4c                	je     80105d35 <walkpgdir+0x95>
      return 0;
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80105ce9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80105cf0:	00 
80105cf1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105cf8:	00 
80105cf9:	89 04 24             	mov    %eax,(%esp)
80105cfc:	e8 0f e0 ff ff       	call   80103d10 <memset>
    if (a < (void*) KERNBASE)
80105d01:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80105d07:	77 0c                	ja     80105d15 <walkpgdir+0x75>
        panic("V2P on address < KERNBASE "
80105d09:	c7 04 24 48 68 10 80 	movl   $0x80106848,(%esp)
80105d10:	e8 10 a6 ff ff       	call   80100325 <panic>
    return (uint)a - KERNBASE;
80105d15:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105d1b:	83 c8 07             	or     $0x7,%eax
80105d1e:	89 07                	mov    %eax,(%edi)
  }
  return &pgtab[PTX(va)];
80105d20:	c1 ee 0a             	shr    $0xa,%esi
80105d23:	89 f0                	mov    %esi,%eax
80105d25:	25 fc 0f 00 00       	and    $0xffc,%eax
80105d2a:	01 d8                	add    %ebx,%eax
80105d2c:	eb 0c                	jmp    80105d3a <walkpgdir+0x9a>
      return 0;
80105d2e:	b8 00 00 00 00       	mov    $0x0,%eax
80105d33:	eb 05                	jmp    80105d3a <walkpgdir+0x9a>
80105d35:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d3a:	83 c4 1c             	add    $0x1c,%esp
80105d3d:	5b                   	pop    %ebx
80105d3e:	5e                   	pop    %esi
80105d3f:	5f                   	pop    %edi
80105d40:	5d                   	pop    %ebp
80105d41:	c3                   	ret    

80105d42 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105d42:	55                   	push   %ebp
80105d43:	89 e5                	mov    %esp,%ebp
80105d45:	57                   	push   %edi
80105d46:	56                   	push   %esi
80105d47:	53                   	push   %ebx
80105d48:	83 ec 1c             	sub    $0x1c,%esp
80105d4b:	89 c7                	mov    %eax,%edi
80105d4d:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105d50:	89 d3                	mov    %edx,%ebx
80105d52:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105d58:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
80105d5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80105d61:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105d64:	b9 01 00 00 00       	mov    $0x1,%ecx
80105d69:	89 da                	mov    %ebx,%edx
80105d6b:	89 f8                	mov    %edi,%eax
80105d6d:	e8 2e ff ff ff       	call   80105ca0 <walkpgdir>
80105d72:	85 c0                	test   %eax,%eax
80105d74:	74 2e                	je     80105da4 <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105d76:	f6 00 01             	testb  $0x1,(%eax)
80105d79:	74 0c                	je     80105d87 <mappages+0x45>
      panic("remap");
80105d7b:	c7 04 24 78 6f 10 80 	movl   $0x80106f78,(%esp)
80105d82:	e8 9e a5 ff ff       	call   80100325 <panic>
    *pte = pa | perm | PTE_P;
80105d87:	89 f2                	mov    %esi,%edx
80105d89:	0b 55 0c             	or     0xc(%ebp),%edx
80105d8c:	83 ca 01             	or     $0x1,%edx
80105d8f:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105d91:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
80105d94:	74 15                	je     80105dab <mappages+0x69>
      break;
    a += PGSIZE;
80105d96:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105d9c:	81 c6 00 10 00 00    	add    $0x1000,%esi
  }
80105da2:	eb c0                	jmp    80105d64 <mappages+0x22>
      return -1;
80105da4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105da9:	eb 05                	jmp    80105db0 <mappages+0x6e>
  return 0;
80105dab:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105db0:	83 c4 1c             	add    $0x1c,%esp
80105db3:	5b                   	pop    %ebx
80105db4:	5e                   	pop    %esi
80105db5:	5f                   	pop    %edi
80105db6:	5d                   	pop    %ebp
80105db7:	c3                   	ret    

80105db8 <seginit>:
{
80105db8:	55                   	push   %ebp
80105db9:	89 e5                	mov    %esp,%ebp
80105dbb:	83 ec 18             	sub    $0x18,%esp
  c = &cpus[cpuid()];
80105dbe:	e8 e7 d4 ff ff       	call   801032aa <cpuid>
80105dc3:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105dc9:	05 a0 27 11 80       	add    $0x801127a0,%eax
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105dce:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80105dd4:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80105dda:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80105dde:	c6 40 7d 9a          	movb   $0x9a,0x7d(%eax)
80105de2:	c6 40 7e cf          	movb   $0xcf,0x7e(%eax)
80105de6:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105dea:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80105df1:	ff ff 
80105df3:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80105dfa:	00 00 
80105dfc:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80105e03:	c6 80 85 00 00 00 92 	movb   $0x92,0x85(%eax)
80105e0a:	c6 80 86 00 00 00 cf 	movb   $0xcf,0x86(%eax)
80105e11:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105e18:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80105e1f:	ff ff 
80105e21:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80105e28:	00 00 
80105e2a:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80105e31:	c6 80 8d 00 00 00 fa 	movb   $0xfa,0x8d(%eax)
80105e38:	c6 80 8e 00 00 00 cf 	movb   $0xcf,0x8e(%eax)
80105e3f:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105e46:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80105e4d:	ff ff 
80105e4f:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80105e56:	00 00 
80105e58:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80105e5f:	c6 80 95 00 00 00 f2 	movb   $0xf2,0x95(%eax)
80105e66:	c6 80 96 00 00 00 cf 	movb   $0xcf,0x96(%eax)
80105e6d:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80105e74:	83 c0 70             	add    $0x70,%eax
  pd[0] = size-1;
80105e77:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80105e7d:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80105e81:	c1 e8 10             	shr    $0x10,%eax
80105e84:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80105e88:	8d 45 f2             	lea    -0xe(%ebp),%eax
80105e8b:	0f 01 10             	lgdtl  (%eax)
}
80105e8e:	c9                   	leave  
80105e8f:	c3                   	ret    

80105e90 <switchkvm>:
// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80105e90:	a1 c4 54 11 80       	mov    0x801154c4,%eax
    if (a < (void*) KERNBASE)
80105e95:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
80105e9a:	77 12                	ja     80105eae <switchkvm+0x1e>
{
80105e9c:	55                   	push   %ebp
80105e9d:	89 e5                	mov    %esp,%ebp
80105e9f:	83 ec 18             	sub    $0x18,%esp
        panic("V2P on address < KERNBASE "
80105ea2:	c7 04 24 48 68 10 80 	movl   $0x80106848,(%esp)
80105ea9:	e8 77 a4 ff ff       	call   80100325 <panic>
    return (uint)a - KERNBASE;
80105eae:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105eb3:	0f 22 d8             	mov    %eax,%cr3
80105eb6:	c3                   	ret    

80105eb7 <switchuvm>:
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80105eb7:	55                   	push   %ebp
80105eb8:	89 e5                	mov    %esp,%ebp
80105eba:	57                   	push   %edi
80105ebb:	56                   	push   %esi
80105ebc:	53                   	push   %ebx
80105ebd:	83 ec 1c             	sub    $0x1c,%esp
80105ec0:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80105ec3:	85 f6                	test   %esi,%esi
80105ec5:	75 0c                	jne    80105ed3 <switchuvm+0x1c>
    panic("switchuvm: no process");
80105ec7:	c7 04 24 7e 6f 10 80 	movl   $0x80106f7e,(%esp)
80105ece:	e8 52 a4 ff ff       	call   80100325 <panic>
  if(p->kstack == 0)
80105ed3:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80105ed7:	75 0c                	jne    80105ee5 <switchuvm+0x2e>
    panic("switchuvm: no kstack");
80105ed9:	c7 04 24 94 6f 10 80 	movl   $0x80106f94,(%esp)
80105ee0:	e8 40 a4 ff ff       	call   80100325 <panic>
  if(p->pgdir == 0)
80105ee5:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
80105ee9:	75 0c                	jne    80105ef7 <switchuvm+0x40>
    panic("switchuvm: no pgdir");
80105eeb:	c7 04 24 a9 6f 10 80 	movl   $0x80106fa9,(%esp)
80105ef2:	e8 2e a4 ff ff       	call   80100325 <panic>

  pushcli();
80105ef7:	e8 89 dc ff ff       	call   80103b85 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80105efc:	e8 4f d3 ff ff       	call   80103250 <mycpu>
80105f01:	89 c3                	mov    %eax,%ebx
80105f03:	e8 48 d3 ff ff       	call   80103250 <mycpu>
80105f08:	8d 78 08             	lea    0x8(%eax),%edi
80105f0b:	e8 40 d3 ff ff       	call   80103250 <mycpu>
80105f10:	83 c0 08             	add    $0x8,%eax
80105f13:	c1 e8 10             	shr    $0x10,%eax
80105f16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105f19:	e8 32 d3 ff ff       	call   80103250 <mycpu>
80105f1e:	83 c0 08             	add    $0x8,%eax
80105f21:	c1 e8 18             	shr    $0x18,%eax
80105f24:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80105f2b:	67 00 
80105f2d:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80105f34:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
80105f38:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80105f3e:	c6 83 9d 00 00 00 99 	movb   $0x99,0x9d(%ebx)
80105f45:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80105f4c:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80105f52:	e8 f9 d2 ff ff       	call   80103250 <mycpu>
80105f57:	80 a0 9d 00 00 00 ef 	andb   $0xef,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80105f5e:	e8 ed d2 ff ff       	call   80103250 <mycpu>
80105f63:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80105f69:	e8 e2 d2 ff ff       	call   80103250 <mycpu>
80105f6e:	8b 56 08             	mov    0x8(%esi),%edx
80105f71:	81 c2 00 10 00 00    	add    $0x1000,%edx
80105f77:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80105f7a:	e8 d1 d2 ff ff       	call   80103250 <mycpu>
80105f7f:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80105f85:	b8 28 00 00 00       	mov    $0x28,%eax
80105f8a:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
80105f8d:	8b 46 04             	mov    0x4(%esi),%eax
    if (a < (void*) KERNBASE)
80105f90:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
80105f95:	77 0c                	ja     80105fa3 <switchuvm+0xec>
        panic("V2P on address < KERNBASE "
80105f97:	c7 04 24 48 68 10 80 	movl   $0x80106848,(%esp)
80105f9e:	e8 82 a3 ff ff       	call   80100325 <panic>
    return (uint)a - KERNBASE;
80105fa3:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105fa8:	0f 22 d8             	mov    %eax,%cr3
  popcli();
80105fab:	e8 10 dc ff ff       	call   80103bc0 <popcli>
}
80105fb0:	83 c4 1c             	add    $0x1c,%esp
80105fb3:	5b                   	pop    %ebx
80105fb4:	5e                   	pop    %esi
80105fb5:	5f                   	pop    %edi
80105fb6:	5d                   	pop    %ebp
80105fb7:	c3                   	ret    

80105fb8 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80105fb8:	55                   	push   %ebp
80105fb9:	89 e5                	mov    %esp,%ebp
80105fbb:	56                   	push   %esi
80105fbc:	53                   	push   %ebx
80105fbd:	83 ec 10             	sub    $0x10,%esp
80105fc0:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
80105fc3:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80105fc9:	76 0c                	jbe    80105fd7 <inituvm+0x1f>
    panic("inituvm: more than a page");
80105fcb:	c7 04 24 bd 6f 10 80 	movl   $0x80106fbd,(%esp)
80105fd2:	e8 4e a3 ff ff       	call   80100325 <panic>
  mem = kalloc();
80105fd7:	e8 7d c1 ff ff       	call   80102159 <kalloc>
80105fdc:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80105fde:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80105fe5:	00 
80105fe6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105fed:	00 
80105fee:	89 04 24             	mov    %eax,(%esp)
80105ff1:	e8 1a dd ff ff       	call   80103d10 <memset>
    if (a < (void*) KERNBASE)
80105ff6:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80105ffc:	77 0c                	ja     8010600a <inituvm+0x52>
        panic("V2P on address < KERNBASE "
80105ffe:	c7 04 24 48 68 10 80 	movl   $0x80106848,(%esp)
80106005:	e8 1b a3 ff ff       	call   80100325 <panic>
    return (uint)a - KERNBASE;
8010600a:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106010:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
80106017:	00 
80106018:	89 04 24             	mov    %eax,(%esp)
8010601b:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106020:	ba 00 00 00 00       	mov    $0x0,%edx
80106025:	8b 45 08             	mov    0x8(%ebp),%eax
80106028:	e8 15 fd ff ff       	call   80105d42 <mappages>
  memmove(mem, init, sz);
8010602d:	89 74 24 08          	mov    %esi,0x8(%esp)
80106031:	8b 45 0c             	mov    0xc(%ebp),%eax
80106034:	89 44 24 04          	mov    %eax,0x4(%esp)
80106038:	89 1c 24             	mov    %ebx,(%esp)
8010603b:	e8 4d dd ff ff       	call   80103d8d <memmove>
}
80106040:	83 c4 10             	add    $0x10,%esp
80106043:	5b                   	pop    %ebx
80106044:	5e                   	pop    %esi
80106045:	5d                   	pop    %ebp
80106046:	c3                   	ret    

80106047 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80106047:	55                   	push   %ebp
80106048:	89 e5                	mov    %esp,%ebp
8010604a:	57                   	push   %edi
8010604b:	56                   	push   %esi
8010604c:	53                   	push   %ebx
8010604d:	83 ec 1c             	sub    $0x1c,%esp
80106050:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106053:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
8010605a:	0f 84 86 00 00 00    	je     801060e6 <loaduvm+0x9f>
    panic("loaduvm: addr must be page aligned");
80106060:	c7 04 24 78 70 10 80 	movl   $0x80107078,(%esp)
80106067:	e8 b9 a2 ff ff       	call   80100325 <panic>
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010606c:	89 da                	mov    %ebx,%edx
8010606e:	03 55 0c             	add    0xc(%ebp),%edx
80106071:	b9 00 00 00 00       	mov    $0x0,%ecx
80106076:	8b 45 08             	mov    0x8(%ebp),%eax
80106079:	e8 22 fc ff ff       	call   80105ca0 <walkpgdir>
8010607e:	85 c0                	test   %eax,%eax
80106080:	75 0c                	jne    8010608e <loaduvm+0x47>
      panic("loaduvm: address should exist");
80106082:	c7 04 24 d7 6f 10 80 	movl   $0x80106fd7,(%esp)
80106089:	e8 97 a2 ff ff       	call   80100325 <panic>
    pa = PTE_ADDR(*pte);
8010608e:	8b 00                	mov    (%eax),%eax
80106090:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106095:	89 fe                	mov    %edi,%esi
80106097:	29 de                	sub    %ebx,%esi
80106099:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
8010609f:	76 05                	jbe    801060a6 <loaduvm+0x5f>
      n = sz - i;
    else
      n = PGSIZE;
801060a1:	be 00 10 00 00       	mov    $0x1000,%esi
    if(readi(ip, P2V(pa), offset+i, n) != n)
801060a6:	89 da                	mov    %ebx,%edx
801060a8:	03 55 14             	add    0x14(%ebp),%edx
    if (a > KERNBASE)
801060ab:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801060b0:	76 0c                	jbe    801060be <loaduvm+0x77>
        panic("P2V on address > KERNBASE");
801060b2:	c7 04 24 78 6b 10 80 	movl   $0x80106b78,(%esp)
801060b9:	e8 67 a2 ff ff       	call   80100325 <panic>
    return (char*)a + KERNBASE;
801060be:	05 00 00 00 80       	add    $0x80000000,%eax
801060c3:	89 74 24 0c          	mov    %esi,0xc(%esp)
801060c7:	89 54 24 08          	mov    %edx,0x8(%esp)
801060cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801060cf:	8b 45 10             	mov    0x10(%ebp),%eax
801060d2:	89 04 24             	mov    %eax,(%esp)
801060d5:	e8 04 b7 ff ff       	call   801017de <readi>
801060da:	39 f0                	cmp    %esi,%eax
801060dc:	75 1c                	jne    801060fa <loaduvm+0xb3>
  for(i = 0; i < sz; i += PGSIZE){
801060de:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801060e4:	eb 05                	jmp    801060eb <loaduvm+0xa4>
801060e6:	bb 00 00 00 00       	mov    $0x0,%ebx
801060eb:	39 fb                	cmp    %edi,%ebx
801060ed:	0f 82 79 ff ff ff    	jb     8010606c <loaduvm+0x25>
      return -1;
  }
  return 0;
801060f3:	b8 00 00 00 00       	mov    $0x0,%eax
801060f8:	eb 05                	jmp    801060ff <loaduvm+0xb8>
      return -1;
801060fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801060ff:	83 c4 1c             	add    $0x1c,%esp
80106102:	5b                   	pop    %ebx
80106103:	5e                   	pop    %esi
80106104:	5f                   	pop    %edi
80106105:	5d                   	pop    %ebp
80106106:	c3                   	ret    

80106107 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106107:	55                   	push   %ebp
80106108:	89 e5                	mov    %esp,%ebp
8010610a:	57                   	push   %edi
8010610b:	56                   	push   %esi
8010610c:	53                   	push   %ebx
8010610d:	83 ec 1c             	sub    $0x1c,%esp
80106110:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106113:	39 7d 10             	cmp    %edi,0x10(%ebp)
80106116:	72 07                	jb     8010611f <deallocuvm+0x18>
    return oldsz;
80106118:	89 f8                	mov    %edi,%eax
8010611a:	e9 80 00 00 00       	jmp    8010619f <deallocuvm+0x98>

  a = PGROUNDUP(newsz);
8010611f:	8b 45 10             	mov    0x10(%ebp),%eax
80106122:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106128:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010612e:	eb 68                	jmp    80106198 <deallocuvm+0x91>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106130:	b9 00 00 00 00       	mov    $0x0,%ecx
80106135:	89 da                	mov    %ebx,%edx
80106137:	8b 45 08             	mov    0x8(%ebp),%eax
8010613a:	e8 61 fb ff ff       	call   80105ca0 <walkpgdir>
8010613f:	89 c6                	mov    %eax,%esi
    if(!pte)
80106141:	85 c0                	test   %eax,%eax
80106143:	75 0e                	jne    80106153 <deallocuvm+0x4c>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106145:	81 e3 00 00 c0 ff    	and    $0xffc00000,%ebx
8010614b:	81 c3 00 f0 3f 00    	add    $0x3ff000,%ebx
80106151:	eb 3f                	jmp    80106192 <deallocuvm+0x8b>
    else if((*pte & PTE_P) != 0){
80106153:	8b 00                	mov    (%eax),%eax
80106155:	a8 01                	test   $0x1,%al
80106157:	74 39                	je     80106192 <deallocuvm+0x8b>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106159:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010615e:	75 0c                	jne    8010616c <deallocuvm+0x65>
        panic("kfree");
80106160:	c7 04 24 d6 68 10 80 	movl   $0x801068d6,(%esp)
80106167:	e8 b9 a1 ff ff       	call   80100325 <panic>
    if (a > KERNBASE)
8010616c:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106171:	76 0c                	jbe    8010617f <deallocuvm+0x78>
        panic("P2V on address > KERNBASE");
80106173:	c7 04 24 78 6b 10 80 	movl   $0x80106b78,(%esp)
8010617a:	e8 a6 a1 ff ff       	call   80100325 <panic>
    return (char*)a + KERNBASE;
8010617f:	05 00 00 00 80       	add    $0x80000000,%eax
      char *v = P2V(pa);
      kfree(v);
80106184:	89 04 24             	mov    %eax,(%esp)
80106187:	e8 90 be ff ff       	call   8010201c <kfree>
      *pte = 0;
8010618c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  for(; a  < oldsz; a += PGSIZE){
80106192:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106198:	39 fb                	cmp    %edi,%ebx
8010619a:	72 94                	jb     80106130 <deallocuvm+0x29>
    }
  }
  return newsz;
8010619c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010619f:	83 c4 1c             	add    $0x1c,%esp
801061a2:	5b                   	pop    %ebx
801061a3:	5e                   	pop    %esi
801061a4:	5f                   	pop    %edi
801061a5:	5d                   	pop    %ebp
801061a6:	c3                   	ret    

801061a7 <allocuvm>:
{
801061a7:	55                   	push   %ebp
801061a8:	89 e5                	mov    %esp,%ebp
801061aa:	57                   	push   %edi
801061ab:	56                   	push   %esi
801061ac:	53                   	push   %ebx
801061ad:	83 ec 1c             	sub    $0x1c,%esp
801061b0:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
801061b3:	85 ff                	test   %edi,%edi
801061b5:	0f 88 eb 00 00 00    	js     801062a6 <allocuvm+0xff>
  if(newsz < oldsz)
801061bb:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801061be:	73 08                	jae    801061c8 <allocuvm+0x21>
    return oldsz;
801061c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801061c3:	e9 e3 00 00 00       	jmp    801062ab <allocuvm+0x104>
  a = PGROUNDUP(oldsz);
801061c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801061cb:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
801061d1:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
801061d7:	e9 be 00 00 00       	jmp    8010629a <allocuvm+0xf3>
    mem = kalloc();
801061dc:	e8 78 bf ff ff       	call   80102159 <kalloc>
801061e1:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
801061e3:	85 c0                	test   %eax,%eax
801061e5:	75 2c                	jne    80106213 <allocuvm+0x6c>
      cprintf("allocuvm out of memory\n");
801061e7:	c7 04 24 f5 6f 10 80 	movl   $0x80106ff5,(%esp)
801061ee:	e8 d4 a3 ff ff       	call   801005c7 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801061f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801061f6:	89 44 24 08          	mov    %eax,0x8(%esp)
801061fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
801061fe:	8b 45 08             	mov    0x8(%ebp),%eax
80106201:	89 04 24             	mov    %eax,(%esp)
80106204:	e8 fe fe ff ff       	call   80106107 <deallocuvm>
      return 0;
80106209:	b8 00 00 00 00       	mov    $0x0,%eax
8010620e:	e9 98 00 00 00       	jmp    801062ab <allocuvm+0x104>
    memset(mem, 0, PGSIZE);
80106213:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010621a:	00 
8010621b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106222:	00 
80106223:	89 04 24             	mov    %eax,(%esp)
80106226:	e8 e5 da ff ff       	call   80103d10 <memset>
    if (a < (void*) KERNBASE)
8010622b:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80106231:	77 0c                	ja     8010623f <allocuvm+0x98>
        panic("V2P on address < KERNBASE "
80106233:	c7 04 24 48 68 10 80 	movl   $0x80106848,(%esp)
8010623a:	e8 e6 a0 ff ff       	call   80100325 <panic>
    return (uint)a - KERNBASE;
8010623f:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80106245:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
8010624c:	00 
8010624d:	89 04 24             	mov    %eax,(%esp)
80106250:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106255:	89 f2                	mov    %esi,%edx
80106257:	8b 45 08             	mov    0x8(%ebp),%eax
8010625a:	e8 e3 fa ff ff       	call   80105d42 <mappages>
8010625f:	85 c0                	test   %eax,%eax
80106261:	79 31                	jns    80106294 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80106263:	c7 04 24 0d 70 10 80 	movl   $0x8010700d,(%esp)
8010626a:	e8 58 a3 ff ff       	call   801005c7 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010626f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106272:	89 44 24 08          	mov    %eax,0x8(%esp)
80106276:	89 7c 24 04          	mov    %edi,0x4(%esp)
8010627a:	8b 45 08             	mov    0x8(%ebp),%eax
8010627d:	89 04 24             	mov    %eax,(%esp)
80106280:	e8 82 fe ff ff       	call   80106107 <deallocuvm>
      kfree(mem);
80106285:	89 1c 24             	mov    %ebx,(%esp)
80106288:	e8 8f bd ff ff       	call   8010201c <kfree>
      return 0;
8010628d:	b8 00 00 00 00       	mov    $0x0,%eax
80106292:	eb 17                	jmp    801062ab <allocuvm+0x104>
  for(; a < newsz; a += PGSIZE){
80106294:	81 c6 00 10 00 00    	add    $0x1000,%esi
8010629a:	39 fe                	cmp    %edi,%esi
8010629c:	0f 82 3a ff ff ff    	jb     801061dc <allocuvm+0x35>
  return newsz;
801062a2:	89 f8                	mov    %edi,%eax
801062a4:	eb 05                	jmp    801062ab <allocuvm+0x104>
    return 0;
801062a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062ab:	83 c4 1c             	add    $0x1c,%esp
801062ae:	5b                   	pop    %ebx
801062af:	5e                   	pop    %esi
801062b0:	5f                   	pop    %edi
801062b1:	5d                   	pop    %ebp
801062b2:	c3                   	ret    

801062b3 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801062b3:	55                   	push   %ebp
801062b4:	89 e5                	mov    %esp,%ebp
801062b6:	56                   	push   %esi
801062b7:	53                   	push   %ebx
801062b8:	83 ec 10             	sub    $0x10,%esp
801062bb:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
801062be:	85 f6                	test   %esi,%esi
801062c0:	75 0c                	jne    801062ce <freevm+0x1b>
    panic("freevm: no pgdir");
801062c2:	c7 04 24 29 70 10 80 	movl   $0x80107029,(%esp)
801062c9:	e8 57 a0 ff ff       	call   80100325 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801062ce:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801062d5:	00 
801062d6:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
801062dd:	80 
801062de:	89 34 24             	mov    %esi,(%esp)
801062e1:	e8 21 fe ff ff       	call   80106107 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801062e6:	bb 00 00 00 00       	mov    $0x0,%ebx
801062eb:	eb 2f                	jmp    8010631c <freevm+0x69>
    if(pgdir[i] & PTE_P){
801062ed:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
801062f0:	a8 01                	test   $0x1,%al
801062f2:	74 25                	je     80106319 <freevm+0x66>
801062f4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
801062f9:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801062fe:	76 0c                	jbe    8010630c <freevm+0x59>
        panic("P2V on address > KERNBASE");
80106300:	c7 04 24 78 6b 10 80 	movl   $0x80106b78,(%esp)
80106307:	e8 19 a0 ff ff       	call   80100325 <panic>
    return (char*)a + KERNBASE;
8010630c:	05 00 00 00 80       	add    $0x80000000,%eax
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
80106311:	89 04 24             	mov    %eax,(%esp)
80106314:	e8 03 bd ff ff       	call   8010201c <kfree>
  for(i = 0; i < NPDENTRIES; i++){
80106319:	83 c3 01             	add    $0x1,%ebx
8010631c:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
80106322:	76 c9                	jbe    801062ed <freevm+0x3a>
    }
  }
  kfree((char*)pgdir);
80106324:	89 34 24             	mov    %esi,(%esp)
80106327:	e8 f0 bc ff ff       	call   8010201c <kfree>
}
8010632c:	83 c4 10             	add    $0x10,%esp
8010632f:	5b                   	pop    %ebx
80106330:	5e                   	pop    %esi
80106331:	5d                   	pop    %ebp
80106332:	c3                   	ret    

80106333 <setupkvm>:
{
80106333:	55                   	push   %ebp
80106334:	89 e5                	mov    %esp,%ebp
80106336:	56                   	push   %esi
80106337:	53                   	push   %ebx
80106338:	83 ec 10             	sub    $0x10,%esp
  if((pgdir = (pde_t*)kalloc()) == 0)
8010633b:	e8 19 be ff ff       	call   80102159 <kalloc>
80106340:	89 c6                	mov    %eax,%esi
80106342:	85 c0                	test   %eax,%eax
80106344:	74 5c                	je     801063a2 <setupkvm+0x6f>
  memset(pgdir, 0, PGSIZE);
80106346:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010634d:	00 
8010634e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106355:	00 
80106356:	89 04 24             	mov    %eax,(%esp)
80106359:	e8 b2 d9 ff ff       	call   80103d10 <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010635e:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
80106363:	eb 31                	jmp    80106396 <setupkvm+0x63>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80106365:	8b 53 04             	mov    0x4(%ebx),%edx
80106368:	8b 4b 08             	mov    0x8(%ebx),%ecx
8010636b:	29 d1                	sub    %edx,%ecx
8010636d:	8b 43 0c             	mov    0xc(%ebx),%eax
80106370:	89 44 24 04          	mov    %eax,0x4(%esp)
80106374:	89 14 24             	mov    %edx,(%esp)
80106377:	8b 13                	mov    (%ebx),%edx
80106379:	89 f0                	mov    %esi,%eax
8010637b:	e8 c2 f9 ff ff       	call   80105d42 <mappages>
80106380:	85 c0                	test   %eax,%eax
80106382:	79 0f                	jns    80106393 <setupkvm+0x60>
      freevm(pgdir);
80106384:	89 34 24             	mov    %esi,(%esp)
80106387:	e8 27 ff ff ff       	call   801062b3 <freevm>
      return 0;
8010638c:	b8 00 00 00 00       	mov    $0x0,%eax
80106391:	eb 14                	jmp    801063a7 <setupkvm+0x74>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106393:	83 c3 10             	add    $0x10,%ebx
80106396:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
8010639c:	72 c7                	jb     80106365 <setupkvm+0x32>
  return pgdir;
8010639e:	89 f0                	mov    %esi,%eax
801063a0:	eb 05                	jmp    801063a7 <setupkvm+0x74>
    return 0;
801063a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063a7:	83 c4 10             	add    $0x10,%esp
801063aa:	5b                   	pop    %ebx
801063ab:	5e                   	pop    %esi
801063ac:	5d                   	pop    %ebp
801063ad:	c3                   	ret    

801063ae <kvmalloc>:
{
801063ae:	55                   	push   %ebp
801063af:	89 e5                	mov    %esp,%ebp
801063b1:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801063b4:	e8 7a ff ff ff       	call   80106333 <setupkvm>
801063b9:	a3 c4 54 11 80       	mov    %eax,0x801154c4
  switchkvm();
801063be:	e8 cd fa ff ff       	call   80105e90 <switchkvm>
}
801063c3:	c9                   	leave  
801063c4:	c3                   	ret    

801063c5 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801063c5:	55                   	push   %ebp
801063c6:	89 e5                	mov    %esp,%ebp
801063c8:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801063cb:	b9 00 00 00 00       	mov    $0x0,%ecx
801063d0:	8b 55 0c             	mov    0xc(%ebp),%edx
801063d3:	8b 45 08             	mov    0x8(%ebp),%eax
801063d6:	e8 c5 f8 ff ff       	call   80105ca0 <walkpgdir>
  if(pte == 0)
801063db:	85 c0                	test   %eax,%eax
801063dd:	75 0c                	jne    801063eb <clearpteu+0x26>
    panic("clearpteu");
801063df:	c7 04 24 3a 70 10 80 	movl   $0x8010703a,(%esp)
801063e6:	e8 3a 9f ff ff       	call   80100325 <panic>
  *pte &= ~PTE_U;
801063eb:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
801063ee:	c9                   	leave  
801063ef:	c3                   	ret    

801063f0 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801063f0:	55                   	push   %ebp
801063f1:	89 e5                	mov    %esp,%ebp
801063f3:	57                   	push   %edi
801063f4:	56                   	push   %esi
801063f5:	53                   	push   %ebx
801063f6:	83 ec 2c             	sub    $0x2c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801063f9:	e8 35 ff ff ff       	call   80106333 <setupkvm>
801063fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
80106401:	85 c0                	test   %eax,%eax
80106403:	0f 84 ef 00 00 00    	je     801064f8 <copyuvm+0x108>
80106409:	be 00 00 00 00       	mov    $0x0,%esi
8010640e:	e9 c5 00 00 00       	jmp    801064d8 <copyuvm+0xe8>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80106413:	b9 00 00 00 00       	mov    $0x0,%ecx
80106418:	89 f2                	mov    %esi,%edx
8010641a:	8b 45 08             	mov    0x8(%ebp),%eax
8010641d:	e8 7e f8 ff ff       	call   80105ca0 <walkpgdir>
80106422:	85 c0                	test   %eax,%eax
80106424:	75 0c                	jne    80106432 <copyuvm+0x42>
      panic("copyuvm: pte should exist");
80106426:	c7 04 24 44 70 10 80 	movl   $0x80107044,(%esp)
8010642d:	e8 f3 9e ff ff       	call   80100325 <panic>
    if(!(*pte & PTE_P))
80106432:	8b 00                	mov    (%eax),%eax
80106434:	a8 01                	test   $0x1,%al
80106436:	75 0c                	jne    80106444 <copyuvm+0x54>
      panic("copyuvm: page not present");
80106438:	c7 04 24 5e 70 10 80 	movl   $0x8010705e,(%esp)
8010643f:	e8 e1 9e ff ff       	call   80100325 <panic>
80106444:	89 c7                	mov    %eax,%edi
80106446:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
static inline uint PTE_FLAGS(uint pte) { return pte & 0xFFF; }
8010644c:	25 ff 0f 00 00       	and    $0xfff,%eax
80106451:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
80106454:	e8 00 bd ff ff       	call   80102159 <kalloc>
80106459:	89 c3                	mov    %eax,%ebx
8010645b:	85 c0                	test   %eax,%eax
8010645d:	0f 84 83 00 00 00    	je     801064e6 <copyuvm+0xf6>
    if (a > KERNBASE)
80106463:	81 ff 00 00 00 80    	cmp    $0x80000000,%edi
80106469:	76 0c                	jbe    80106477 <copyuvm+0x87>
        panic("P2V on address > KERNBASE");
8010646b:	c7 04 24 78 6b 10 80 	movl   $0x80106b78,(%esp)
80106472:	e8 ae 9e ff ff       	call   80100325 <panic>
    return (char*)a + KERNBASE;
80106477:	81 c7 00 00 00 80    	add    $0x80000000,%edi
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010647d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80106484:	00 
80106485:	89 7c 24 04          	mov    %edi,0x4(%esp)
80106489:	89 04 24             	mov    %eax,(%esp)
8010648c:	e8 fc d8 ff ff       	call   80103d8d <memmove>
    if (a < (void*) KERNBASE)
80106491:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80106497:	77 0c                	ja     801064a5 <copyuvm+0xb5>
        panic("V2P on address < KERNBASE "
80106499:	c7 04 24 48 68 10 80 	movl   $0x80106848,(%esp)
801064a0:	e8 80 9e ff ff       	call   80100325 <panic>
    return (uint)a - KERNBASE;
801064a5:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801064ab:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801064ae:	89 54 24 04          	mov    %edx,0x4(%esp)
801064b2:	89 04 24             	mov    %eax,(%esp)
801064b5:	b9 00 10 00 00       	mov    $0x1000,%ecx
801064ba:	89 f2                	mov    %esi,%edx
801064bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801064bf:	e8 7e f8 ff ff       	call   80105d42 <mappages>
801064c4:	85 c0                	test   %eax,%eax
801064c6:	79 0a                	jns    801064d2 <copyuvm+0xe2>
      kfree(mem);
801064c8:	89 1c 24             	mov    %ebx,(%esp)
801064cb:	e8 4c bb ff ff       	call   8010201c <kfree>
      goto bad;
801064d0:	eb 14                	jmp    801064e6 <copyuvm+0xf6>
  for(i = 0; i < sz; i += PGSIZE){
801064d2:	81 c6 00 10 00 00    	add    $0x1000,%esi
801064d8:	3b 75 0c             	cmp    0xc(%ebp),%esi
801064db:	0f 82 32 ff ff ff    	jb     80106413 <copyuvm+0x23>
    }
  }
  return d;
801064e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801064e4:	eb 17                	jmp    801064fd <copyuvm+0x10d>

bad:
  freevm(d);
801064e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801064e9:	89 04 24             	mov    %eax,(%esp)
801064ec:	e8 c2 fd ff ff       	call   801062b3 <freevm>
  return 0;
801064f1:	b8 00 00 00 00       	mov    $0x0,%eax
801064f6:	eb 05                	jmp    801064fd <copyuvm+0x10d>
    return 0;
801064f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064fd:	83 c4 2c             	add    $0x2c,%esp
80106500:	5b                   	pop    %ebx
80106501:	5e                   	pop    %esi
80106502:	5f                   	pop    %edi
80106503:	5d                   	pop    %ebp
80106504:	c3                   	ret    

80106505 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106505:	55                   	push   %ebp
80106506:	89 e5                	mov    %esp,%ebp
80106508:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010650b:	b9 00 00 00 00       	mov    $0x0,%ecx
80106510:	8b 55 0c             	mov    0xc(%ebp),%edx
80106513:	8b 45 08             	mov    0x8(%ebp),%eax
80106516:	e8 85 f7 ff ff       	call   80105ca0 <walkpgdir>
  if((*pte & PTE_P) == 0)
8010651b:	8b 00                	mov    (%eax),%eax
8010651d:	a8 01                	test   $0x1,%al
8010651f:	74 23                	je     80106544 <uva2ka+0x3f>
    return 0;
  if((*pte & PTE_U) == 0)
80106521:	a8 04                	test   $0x4,%al
80106523:	74 26                	je     8010654b <uva2ka+0x46>
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
80106525:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
8010652a:	3d 00 00 00 80       	cmp    $0x80000000,%eax
8010652f:	76 0c                	jbe    8010653d <uva2ka+0x38>
        panic("P2V on address > KERNBASE");
80106531:	c7 04 24 78 6b 10 80 	movl   $0x80106b78,(%esp)
80106538:	e8 e8 9d ff ff       	call   80100325 <panic>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
8010653d:	05 00 00 00 80       	add    $0x80000000,%eax
80106542:	eb 0c                	jmp    80106550 <uva2ka+0x4b>
    return 0;
80106544:	b8 00 00 00 00       	mov    $0x0,%eax
80106549:	eb 05                	jmp    80106550 <uva2ka+0x4b>
    return 0;
8010654b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106550:	c9                   	leave  
80106551:	c3                   	ret    

80106552 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106552:	55                   	push   %ebp
80106553:	89 e5                	mov    %esp,%ebp
80106555:	57                   	push   %edi
80106556:	56                   	push   %esi
80106557:	53                   	push   %ebx
80106558:	83 ec 1c             	sub    $0x1c,%esp
8010655b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010655e:	eb 50                	jmp    801065b0 <copyout+0x5e>
    va0 = (uint)PGROUNDDOWN(va);
80106560:	89 fe                	mov    %edi,%esi
80106562:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80106568:	89 74 24 04          	mov    %esi,0x4(%esp)
8010656c:	8b 45 08             	mov    0x8(%ebp),%eax
8010656f:	89 04 24             	mov    %eax,(%esp)
80106572:	e8 8e ff ff ff       	call   80106505 <uva2ka>
    if(pa0 == 0)
80106577:	85 c0                	test   %eax,%eax
80106579:	74 42                	je     801065bd <copyout+0x6b>
      return -1;
    n = PGSIZE - (va - va0);
8010657b:	89 f3                	mov    %esi,%ebx
8010657d:	29 fb                	sub    %edi,%ebx
8010657f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80106585:	3b 5d 14             	cmp    0x14(%ebp),%ebx
80106588:	76 03                	jbe    8010658d <copyout+0x3b>
      n = len;
8010658a:	8b 5d 14             	mov    0x14(%ebp),%ebx
    memmove(pa0 + (va - va0), buf, n);
8010658d:	29 f7                	sub    %esi,%edi
8010658f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80106593:	8b 55 10             	mov    0x10(%ebp),%edx
80106596:	89 54 24 04          	mov    %edx,0x4(%esp)
8010659a:	01 f8                	add    %edi,%eax
8010659c:	89 04 24             	mov    %eax,(%esp)
8010659f:	e8 e9 d7 ff ff       	call   80103d8d <memmove>
    len -= n;
801065a4:	29 5d 14             	sub    %ebx,0x14(%ebp)
    buf += n;
801065a7:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
801065aa:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
  while(len > 0){
801065b0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801065b4:	75 aa                	jne    80106560 <copyout+0xe>
  }
  return 0;
801065b6:	b8 00 00 00 00       	mov    $0x0,%eax
801065bb:	eb 05                	jmp    801065c2 <copyout+0x70>
      return -1;
801065bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801065c2:	83 c4 1c             	add    $0x1c,%esp
801065c5:	5b                   	pop    %ebx
801065c6:	5e                   	pop    %esi
801065c7:	5f                   	pop    %edi
801065c8:	5d                   	pop    %ebp
801065c9:	c3                   	ret    
