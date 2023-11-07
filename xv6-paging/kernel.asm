
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
80100028:	bc c0 b5 10 80       	mov    $0x8010b5c0,%esp

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
80100041:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100048:	e8 f6 3d 00 00       	call   80103e43 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010004d:	8b 1d 10 fd 10 80    	mov    0x8010fd10,%ebx
80100053:	eb 2c                	jmp    80100081 <bget+0x4d>
    if(b->dev == dev && b->blockno == blockno){
80100055:	39 73 04             	cmp    %esi,0x4(%ebx)
80100058:	75 24                	jne    8010007e <bget+0x4a>
8010005a:	39 7b 08             	cmp    %edi,0x8(%ebx)
8010005d:	75 1f                	jne    8010007e <bget+0x4a>
      b->refcnt++;
8010005f:	83 43 4c 01          	addl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
80100063:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
8010006a:	e8 35 3e 00 00       	call   80103ea4 <release>
      acquiresleep(&b->lock);
8010006f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100072:	89 04 24             	mov    %eax,(%esp)
80100075:	e8 c2 3b 00 00       	call   80103c3c <acquiresleep>
      return b;
8010007a:	89 d8                	mov    %ebx,%eax
8010007c:	eb 63                	jmp    801000e1 <bget+0xad>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010007e:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100081:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
80100087:	75 cc                	jne    80100055 <bget+0x21>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100089:	8b 1d 0c fd 10 80    	mov    0x8010fd0c,%ebx
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
801000af:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801000b6:	e8 e9 3d 00 00       	call   80103ea4 <release>
      acquiresleep(&b->lock);
801000bb:	8d 43 0c             	lea    0xc(%ebx),%eax
801000be:	89 04 24             	mov    %eax,(%esp)
801000c1:	e8 76 3b 00 00       	call   80103c3c <acquiresleep>
      return b;
801000c6:	89 d8                	mov    %ebx,%eax
801000c8:	eb 17                	jmp    801000e1 <bget+0xad>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801000ca:	8b 5b 50             	mov    0x50(%ebx),%ebx
801000cd:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
801000d3:	75 bc                	jne    80100091 <bget+0x5d>
    }
  }
  panic("bget: no buffers");
801000d5:	c7 04 24 c0 69 10 80 	movl   $0x801069c0,(%esp)
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
801000f0:	c7 44 24 04 d1 69 10 	movl   $0x801069d1,0x4(%esp)
801000f7:	80 
801000f8:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801000ff:	e8 07 3c 00 00       	call   80103d0b <initlock>
  bcache.head.prev = &bcache.head;
80100104:	c7 05 0c fd 10 80 bc 	movl   $0x8010fcbc,0x8010fd0c
8010010b:	fc 10 80 
  bcache.head.next = &bcache.head;
8010010e:	c7 05 10 fd 10 80 bc 	movl   $0x8010fcbc,0x8010fd10
80100115:	fc 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100118:	bb f4 b5 10 80       	mov    $0x8010b5f4,%ebx
8010011d:	eb 36                	jmp    80100155 <binit+0x6c>
    b->next = bcache.head.next;
8010011f:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
80100124:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100127:	c7 43 50 bc fc 10 80 	movl   $0x8010fcbc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
8010012e:	c7 44 24 04 d8 69 10 	movl   $0x801069d8,0x4(%esp)
80100135:	80 
80100136:	8d 43 0c             	lea    0xc(%ebx),%eax
80100139:	89 04 24             	mov    %eax,(%esp)
8010013c:	e8 c5 3a 00 00       	call   80103c06 <initsleeplock>
    bcache.head.next->prev = b;
80100141:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
80100146:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100149:	89 1d 10 fd 10 80    	mov    %ebx,0x8010fd10
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010014f:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
80100155:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
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
8010019c:	e8 1e 3b 00 00       	call   80103cbf <holdingsleep>
801001a1:	85 c0                	test   %eax,%eax
801001a3:	75 0c                	jne    801001b1 <bwrite+0x25>
    panic("bwrite");
801001a5:	c7 04 24 df 69 10 80 	movl   $0x801069df,(%esp)
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
801001d3:	e8 e7 3a 00 00       	call   80103cbf <holdingsleep>
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0c                	jne    801001e8 <brelse+0x26>
    panic("brelse");
801001dc:	c7 04 24 e6 69 10 80 	movl   $0x801069e6,(%esp)
801001e3:	e8 3d 01 00 00       	call   80100325 <panic>

  releasesleep(&b->lock);
801001e8:	89 34 24             	mov    %esi,(%esp)
801001eb:	e8 95 3a 00 00       	call   80103c85 <releasesleep>

  acquire(&bcache.lock);
801001f0:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801001f7:	e8 47 3c 00 00       	call   80103e43 <acquire>
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
8010021b:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
80100220:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100223:	c7 43 50 bc fc 10 80 	movl   $0x8010fcbc,0x50(%ebx)
    bcache.head.next->prev = b;
8010022a:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
8010022f:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100232:	89 1d 10 fd 10 80    	mov    %ebx,0x8010fd10
  }
  
  release(&bcache.lock);
80100238:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
8010023f:	e8 60 3c 00 00       	call   80103ea4 <release>
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
80100273:	e8 cb 3b 00 00       	call   80103e43 <acquire>
  while(n > 0){
80100278:	e9 81 00 00 00       	jmp    801002fe <consoleread+0xae>
    while(input.r == input.w){
      if(myproc()->killed){
8010027d:	e8 3b 30 00 00       	call   801032bd <myproc>
80100282:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80100286:	74 1e                	je     801002a6 <consoleread+0x56>
        release(&cons.lock);
80100288:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
8010028f:	e8 10 3c 00 00       	call   80103ea4 <release>
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
801002ae:	c7 04 24 a0 ff 10 80 	movl   $0x8010ffa0,(%esp)
801002b5:	e8 8b 34 00 00       	call   80103745 <sleep>
    while(input.r == input.w){
801002ba:	a1 a0 ff 10 80       	mov    0x8010ffa0,%eax
801002bf:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
801002c5:	74 b6                	je     8010027d <consoleread+0x2d>
    }
    c = input.buf[input.r++ % INPUT_BUF];
801002c7:	8d 50 01             	lea    0x1(%eax),%edx
801002ca:	89 15 a0 ff 10 80    	mov    %edx,0x8010ffa0
801002d0:	89 c2                	mov    %eax,%edx
801002d2:	83 e2 7f             	and    $0x7f,%edx
801002d5:	0f b6 8a 20 ff 10 80 	movzbl -0x7fef00e0(%edx),%ecx
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
801002e8:	a3 a0 ff 10 80       	mov    %eax,0x8010ffa0
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
80100309:	e8 96 3b 00 00       	call   80103ea4 <release>
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
80100340:	c7 04 24 ed 69 10 80 	movl   $0x801069ed,(%esp)
80100347:	e8 7b 02 00 00       	call   801005c7 <cprintf>
  cprintf(s);
8010034c:	8b 45 08             	mov    0x8(%ebp),%eax
8010034f:	89 04 24             	mov    %eax,(%esp)
80100352:	e8 70 02 00 00       	call   801005c7 <cprintf>
  cprintf("\n");
80100357:	c7 04 24 b3 70 10 80 	movl   $0x801070b3,(%esp)
8010035e:	e8 64 02 00 00       	call   801005c7 <cprintf>
  getcallerpcs(&s, pcs);
80100363:	8d 45 d0             	lea    -0x30(%ebp),%eax
80100366:	89 44 24 04          	mov    %eax,0x4(%esp)
8010036a:	8d 45 08             	lea    0x8(%ebp),%eax
8010036d:	89 04 24             	mov    %eax,(%esp)
80100370:	e8 b1 39 00 00       	call   80103d26 <getcallerpcs>
  for(i=0; i<10; i++)
80100375:	bb 00 00 00 00       	mov    $0x0,%ebx
8010037a:	eb 17                	jmp    80100393 <panic+0x6e>
    cprintf(" %p", pcs[i]);
8010037c:	8b 44 9d d0          	mov    -0x30(%ebp,%ebx,4),%eax
80100380:	89 44 24 04          	mov    %eax,0x4(%esp)
80100384:	c7 04 24 01 6a 10 80 	movl   $0x80106a01,(%esp)
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
80100421:	c7 04 24 05 6a 10 80 	movl   $0x80106a05,(%esp)
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
8010044c:	e8 1c 3b 00 00       	call   80103f6d <memmove>
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
80100473:	e8 78 3a 00 00       	call   80103ef0 <memset>
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
801004cc:	e8 e8 4f 00 00       	call   801054b9 <uartputc>
801004d1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801004d8:	e8 dc 4f 00 00       	call   801054b9 <uartputc>
801004dd:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801004e4:	e8 d0 4f 00 00       	call   801054b9 <uartputc>
801004e9:	eb 08                	jmp    801004f3 <consputc+0x4a>
    uartputc(c);
801004eb:	89 04 24             	mov    %eax,(%esp)
801004ee:	e8 c6 4f 00 00       	call   801054b9 <uartputc>
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
80100531:	0f b6 92 30 6a 10 80 	movzbl -0x7fef95d0(%edx),%edx
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
8010058a:	e8 b4 38 00 00       	call   80103e43 <acquire>
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
801005ad:	e8 f2 38 00 00       	call   80103ea4 <release>
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
801005e3:	e8 5b 38 00 00       	call   80103e43 <acquire>
  if (fmt == 0)
801005e8:	8b 7d 08             	mov    0x8(%ebp),%edi
801005eb:	85 ff                	test   %edi,%edi
801005ed:	0f 85 d5 00 00 00    	jne    801006c8 <cprintf+0x101>
    panic("null fmt");
801005f3:	c7 04 24 1f 6a 10 80 	movl   $0x80106a1f,(%esp)
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
8010068b:	be 18 6a 10 80       	mov    $0x80106a18,%esi
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
801006ec:	e8 b3 37 00 00       	call   80103ea4 <release>
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
8010070c:	e8 32 37 00 00       	call   80103e43 <acquire>
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
80100742:	a3 a8 ff 10 80       	mov    %eax,0x8010ffa8
        consputc(BACKSPACE);
80100747:	b8 00 01 00 00       	mov    $0x100,%eax
8010074c:	e8 58 fd ff ff       	call   801004a9 <consputc>
      while(input.e != input.w &&
80100751:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
80100756:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
8010075c:	0f 84 b2 00 00 00    	je     80100814 <consoleintr+0x11b>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100762:	83 e8 01             	sub    $0x1,%eax
80100765:	89 c2                	mov    %eax,%edx
80100767:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
8010076a:	80 ba 20 ff 10 80 0a 	cmpb   $0xa,-0x7fef00e0(%edx)
80100771:	75 cf                	jne    80100742 <consoleintr+0x49>
80100773:	e9 9c 00 00 00       	jmp    80100814 <consoleintr+0x11b>
      if(input.e != input.w){
80100778:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
8010077d:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
80100783:	0f 84 8b 00 00 00    	je     80100814 <consoleintr+0x11b>
        input.e--;
80100789:	83 e8 01             	sub    $0x1,%eax
8010078c:	a3 a8 ff 10 80       	mov    %eax,0x8010ffa8
        consputc(BACKSPACE);
80100791:	b8 00 01 00 00       	mov    $0x100,%eax
80100796:	e8 0e fd ff ff       	call   801004a9 <consputc>
8010079b:	eb 77                	jmp    80100814 <consoleintr+0x11b>
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010079d:	85 ff                	test   %edi,%edi
8010079f:	74 73                	je     80100814 <consoleintr+0x11b>
801007a1:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
801007a6:	89 c2                	mov    %eax,%edx
801007a8:	2b 15 a0 ff 10 80    	sub    0x8010ffa0,%edx
801007ae:	83 fa 7f             	cmp    $0x7f,%edx
801007b1:	77 61                	ja     80100814 <consoleintr+0x11b>
        c = (c == '\r') ? '\n' : c;
801007b3:	83 ff 0d             	cmp    $0xd,%edi
801007b6:	75 04                	jne    801007bc <consoleintr+0xc3>
801007b8:	66 bf 0a 00          	mov    $0xa,%di
        input.buf[input.e++ % INPUT_BUF] = c;
801007bc:	8d 50 01             	lea    0x1(%eax),%edx
801007bf:	89 15 a8 ff 10 80    	mov    %edx,0x8010ffa8
801007c5:	83 e0 7f             	and    $0x7f,%eax
801007c8:	89 f9                	mov    %edi,%ecx
801007ca:	88 88 20 ff 10 80    	mov    %cl,-0x7fef00e0(%eax)
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
801007e7:	a1 a0 ff 10 80       	mov    0x8010ffa0,%eax
801007ec:	83 e8 80             	sub    $0xffffff80,%eax
801007ef:	39 05 a8 ff 10 80    	cmp    %eax,0x8010ffa8
801007f5:	75 1d                	jne    80100814 <consoleintr+0x11b>
          input.w = input.e;
801007f7:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
801007fc:	a3 a4 ff 10 80       	mov    %eax,0x8010ffa4
          wakeup(&input.r);
80100801:	c7 04 24 a0 ff 10 80 	movl   $0x8010ffa0,(%esp)
80100808:	e8 8d 30 00 00       	call   8010389a <wakeup>
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
80100827:	e8 78 36 00 00       	call   80103ea4 <release>
  if(doprocdump) {
8010082c:	85 f6                	test   %esi,%esi
8010082e:	74 05                	je     80100835 <consoleintr+0x13c>
    procdump();  // now call procdump() wo. cons.lock held
80100830:	e8 f7 30 00 00       	call   8010392c <procdump>
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
80100843:	c7 44 24 04 28 6a 10 	movl   $0x80106a28,0x4(%esp)
8010084a:	80 
8010084b:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
80100852:	e8 b4 34 00 00       	call   80103d0b <initlock>

  devsw[CONSOLE].write = consolewrite;
80100857:	c7 05 6c 09 11 80 69 	movl   $0x80100569,0x8011096c
8010085e:	05 10 80 
  devsw[CONSOLE].read = consoleread;
80100861:	c7 05 68 09 11 80 50 	movl   $0x80100250,0x80110968
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
80100897:	e8 21 2a 00 00       	call   801032bd <myproc>
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
801008bd:	c7 04 24 41 6a 10 80 	movl   $0x80106a41,(%esp)
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
80100916:	e8 cf 5d 00 00       	call   801066ea <setupkvm>
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
801009b0:	e8 a0 5b 00 00       	call   80106555 <allocuvm>
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
801009f9:	e8 e7 59 00 00       	call   801063e5 <loaduvm>
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
80100a4f:	e8 01 5b 00 00       	call   80106555 <allocuvm>
80100a54:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
80100a5a:	85 c0                	test   %eax,%eax
80100a5c:	0f 84 6b 01 00 00    	je     80100bcd <exec+0x342>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100a62:	89 c7                	mov    %eax,%edi
80100a64:	2d 00 20 00 00       	sub    $0x2000,%eax
80100a69:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a6d:	89 34 24             	mov    %esi,(%esp)
80100a70:	e8 11 5d 00 00       	call   80106786 <clearpteu>
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
80100a92:	e8 0b 36 00 00       	call   801040a2 <strlen>
80100a97:	29 c6                	sub    %eax,%esi
80100a99:	83 ee 01             	sub    $0x1,%esi
80100a9c:	83 e6 fc             	and    $0xfffffffc,%esi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100a9f:	8b 03                	mov    (%ebx),%eax
80100aa1:	89 04 24             	mov    %eax,(%esp)
80100aa4:	e8 f9 35 00 00       	call   801040a2 <strlen>
80100aa9:	83 c0 01             	add    $0x1,%eax
80100aac:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100ab0:	8b 03                	mov    (%ebx),%eax
80100ab2:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ab6:	89 74 24 04          	mov    %esi,0x4(%esp)
80100aba:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100ac0:	89 04 24             	mov    %eax,(%esp)
80100ac3:	e8 70 5e 00 00       	call   80106938 <copyout>
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
80100b3c:	e8 f7 5d 00 00       	call   80106938 <copyout>
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
80100b7c:	e8 e6 34 00 00       	call   80104067 <safestrcpy>

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
80100ba8:	e8 9e 56 00 00       	call   8010624b <switchuvm>
  freevm(oldpgdir);
80100bad:	89 3c 24             	mov    %edi,(%esp)
80100bb0:	e8 b5 5a 00 00       	call   8010666a <freevm>
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
80100c2a:	e8 3b 5a 00 00       	call   8010666a <freevm>
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
80100c66:	c7 44 24 04 4d 6a 10 	movl   $0x80106a4d,0x4(%esp)
80100c6d:	80 
80100c6e:	c7 04 24 c0 ff 10 80 	movl   $0x8010ffc0,(%esp)
80100c75:	e8 91 30 00 00       	call   80103d0b <initlock>
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
80100c83:	c7 04 24 c0 ff 10 80 	movl   $0x8010ffc0,(%esp)
80100c8a:	e8 b4 31 00 00       	call   80103e43 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c8f:	bb f4 ff 10 80       	mov    $0x8010fff4,%ebx
80100c94:	eb 20                	jmp    80100cb6 <filealloc+0x3a>
    if(f->ref == 0){
80100c96:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80100c9a:	75 17                	jne    80100cb3 <filealloc+0x37>
      f->ref = 1;
80100c9c:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100ca3:	c7 04 24 c0 ff 10 80 	movl   $0x8010ffc0,(%esp)
80100caa:	e8 f5 31 00 00       	call   80103ea4 <release>
      return f;
80100caf:	89 d8                	mov    %ebx,%eax
80100cb1:	eb 1c                	jmp    80100ccf <filealloc+0x53>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100cb3:	83 c3 18             	add    $0x18,%ebx
80100cb6:	81 fb 54 09 11 80    	cmp    $0x80110954,%ebx
80100cbc:	72 d8                	jb     80100c96 <filealloc+0x1a>
    }
  }
  release(&ftable.lock);
80100cbe:	c7 04 24 c0 ff 10 80 	movl   $0x8010ffc0,(%esp)
80100cc5:	e8 da 31 00 00       	call   80103ea4 <release>
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
80100cdf:	c7 04 24 c0 ff 10 80 	movl   $0x8010ffc0,(%esp)
80100ce6:	e8 58 31 00 00       	call   80103e43 <acquire>
  if(f->ref < 1)
80100ceb:	8b 43 04             	mov    0x4(%ebx),%eax
80100cee:	85 c0                	test   %eax,%eax
80100cf0:	7f 0c                	jg     80100cfe <filedup+0x29>
    panic("filedup");
80100cf2:	c7 04 24 54 6a 10 80 	movl   $0x80106a54,(%esp)
80100cf9:	e8 27 f6 ff ff       	call   80100325 <panic>
  f->ref++;
80100cfe:	83 c0 01             	add    $0x1,%eax
80100d01:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100d04:	c7 04 24 c0 ff 10 80 	movl   $0x8010ffc0,(%esp)
80100d0b:	e8 94 31 00 00       	call   80103ea4 <release>
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
80100d22:	c7 04 24 c0 ff 10 80 	movl   $0x8010ffc0,(%esp)
80100d29:	e8 15 31 00 00       	call   80103e43 <acquire>
  if(f->ref < 1)
80100d2e:	8b 43 04             	mov    0x4(%ebx),%eax
80100d31:	85 c0                	test   %eax,%eax
80100d33:	7f 0c                	jg     80100d41 <fileclose+0x29>
    panic("fileclose");
80100d35:	c7 04 24 5c 6a 10 80 	movl   $0x80106a5c,(%esp)
80100d3c:	e8 e4 f5 ff ff       	call   80100325 <panic>
  if(--f->ref > 0){
80100d41:	83 e8 01             	sub    $0x1,%eax
80100d44:	89 43 04             	mov    %eax,0x4(%ebx)
80100d47:	85 c0                	test   %eax,%eax
80100d49:	7e 0e                	jle    80100d59 <fileclose+0x41>
    release(&ftable.lock);
80100d4b:	c7 04 24 c0 ff 10 80 	movl   $0x8010ffc0,(%esp)
80100d52:	e8 4d 31 00 00       	call   80103ea4 <release>
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
80100d83:	c7 04 24 c0 ff 10 80 	movl   $0x8010ffc0,(%esp)
80100d8a:	e8 15 31 00 00       	call   80103ea4 <release>

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
80100e90:	c7 04 24 66 6a 10 80 	movl   $0x80106a66,(%esp)
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
80100f62:	c7 04 24 6f 6a 10 80 	movl   $0x80106a6f,(%esp)
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
80100f91:	c7 04 24 75 6a 10 80 	movl   $0x80106a75,(%esp)
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
80100ffd:	e8 6b 2f 00 00       	call   80103f6d <memmove>
80101002:	eb 19                	jmp    8010101d <skipelem+0x6d>
  else {
    memmove(name, s, len);
80101004:	89 74 24 08          	mov    %esi,0x8(%esp)
80101008:	89 44 24 04          	mov    %eax,0x4(%esp)
8010100c:	89 3c 24             	mov    %edi,(%esp)
8010100f:	e8 59 2f 00 00       	call   80103f6d <memmove>
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
8010105e:	e8 8d 2e 00 00       	call   80103ef0 <memset>
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
80101086:	03 15 d8 09 11 80    	add    0x801109d8,%edx
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
801010bf:	c7 04 24 7f 6a 10 80 	movl   $0x80106a7f,(%esp)
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
8010110e:	03 05 d8 09 11 80    	add    0x801109d8,%eax
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
8010116f:	3b 1d c0 09 11 80    	cmp    0x801109c0,%ebx
80101175:	72 b6                	jb     8010112d <balloc+0x43>
    brelse(bp);
80101177:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010117a:	89 04 24             	mov    %eax,(%esp)
8010117d:	e8 40 f0 ff ff       	call   801001c2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
80101182:	81 c7 00 10 00 00    	add    $0x1000,%edi
80101188:	3b 3d c0 09 11 80    	cmp    0x801109c0,%edi
8010118e:	0f 82 6c ff ff ff    	jb     80101100 <balloc+0x16>
  panic("balloc: out of blocks");
80101194:	c7 04 24 92 6a 10 80 	movl   $0x80106a92,(%esp)
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
80101258:	c7 04 24 a8 6a 10 80 	movl   $0x80106aa8,(%esp)
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
8010127a:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101281:	e8 bd 2b 00 00       	call   80103e43 <acquire>
  empty = 0;
80101286:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010128b:	bb 14 0a 11 80       	mov    $0x80110a14,%ebx
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
801012ab:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801012b2:	e8 ed 2b 00 00       	call   80103ea4 <release>
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
801012cb:	81 fb 34 26 11 80    	cmp    $0x80112634,%ebx
801012d1:	72 bf                	jb     80101292 <iget+0x26>
  if(empty == 0)
801012d3:	85 f6                	test   %esi,%esi
801012d5:	75 0c                	jne    801012e3 <iget+0x77>
    panic("iget: no inodes");
801012d7:	c7 04 24 bb 6a 10 80 	movl   $0x80106abb,(%esp)
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
801012f9:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101300:	e8 9f 2b 00 00       	call   80103ea4 <release>
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
80101340:	e8 28 2c 00 00       	call   80103f6d <memmove>
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
8010135a:	c7 44 24 04 cb 6a 10 	movl   $0x80106acb,0x4(%esp)
80101361:	80 
80101362:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101369:	e8 9d 29 00 00       	call   80103d0b <initlock>
  for(i = 0; i < NINODE; i++) {
8010136e:	bb 00 00 00 00       	mov    $0x0,%ebx
80101373:	eb 1e                	jmp    80101393 <iinit+0x40>
    initsleeplock(&icache.inode[i].lock, "inode");
80101375:	c7 44 24 04 d2 6a 10 	movl   $0x80106ad2,0x4(%esp)
8010137c:	80 
8010137d:	8d 04 db             	lea    (%ebx,%ebx,8),%eax
80101380:	c1 e0 04             	shl    $0x4,%eax
80101383:	05 20 0a 11 80       	add    $0x80110a20,%eax
80101388:	89 04 24             	mov    %eax,(%esp)
8010138b:	e8 76 28 00 00       	call   80103c06 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
80101390:	83 c3 01             	add    $0x1,%ebx
80101393:	83 fb 31             	cmp    $0x31,%ebx
80101396:	7e dd                	jle    80101375 <iinit+0x22>
  readsb(dev, &sb);
80101398:	c7 44 24 04 c0 09 11 	movl   $0x801109c0,0x4(%esp)
8010139f:	80 
801013a0:	8b 45 08             	mov    0x8(%ebp),%eax
801013a3:	89 04 24             	mov    %eax,(%esp)
801013a6:	e8 64 ff ff ff       	call   8010130f <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801013ab:	a1 d8 09 11 80       	mov    0x801109d8,%eax
801013b0:	89 44 24 1c          	mov    %eax,0x1c(%esp)
801013b4:	a1 d4 09 11 80       	mov    0x801109d4,%eax
801013b9:	89 44 24 18          	mov    %eax,0x18(%esp)
801013bd:	a1 d0 09 11 80       	mov    0x801109d0,%eax
801013c2:	89 44 24 14          	mov    %eax,0x14(%esp)
801013c6:	a1 cc 09 11 80       	mov    0x801109cc,%eax
801013cb:	89 44 24 10          	mov    %eax,0x10(%esp)
801013cf:	a1 c8 09 11 80       	mov    0x801109c8,%eax
801013d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
801013d8:	a1 c4 09 11 80       	mov    0x801109c4,%eax
801013dd:	89 44 24 08          	mov    %eax,0x8(%esp)
801013e1:	a1 c0 09 11 80       	mov    0x801109c0,%eax
801013e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801013ea:	c7 04 24 38 6b 10 80 	movl   $0x80106b38,(%esp)
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
80101417:	03 05 d4 09 11 80    	add    0x801109d4,%eax
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
8010144e:	3b 1d c8 09 11 80    	cmp    0x801109c8,%ebx
80101454:	72 bc                	jb     80101412 <ialloc+0x16>
  panic("ialloc: no inodes");
80101456:	c7 04 24 d8 6a 10 80 	movl   $0x80106ad8,(%esp)
8010145d:	e8 c3 ee ff ff       	call   80100325 <panic>
      memset(dip, 0, sizeof(*dip));
80101462:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101469:	00 
8010146a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101471:	00 
80101472:	89 3c 24             	mov    %edi,(%esp)
80101475:	e8 76 2a 00 00       	call   80103ef0 <memset>
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
801014b5:	03 15 d4 09 11 80    	add    0x801109d4,%edx
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
80101512:	e8 56 2a 00 00       	call   80103f6d <memmove>
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
801015dd:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801015e4:	e8 5a 28 00 00       	call   80103e43 <acquire>
  ip->ref++;
801015e9:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
801015ed:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801015f4:	e8 ab 28 00 00       	call   80103ea4 <release>
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
80101616:	c7 04 24 ea 6a 10 80 	movl   $0x80106aea,(%esp)
8010161d:	e8 03 ed ff ff       	call   80100325 <panic>
  acquiresleep(&ip->lock);
80101622:	8d 43 0c             	lea    0xc(%ebx),%eax
80101625:	89 04 24             	mov    %eax,(%esp)
80101628:	e8 0f 26 00 00       	call   80103c3c <acquiresleep>
  if(ip->valid == 0){
8010162d:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101631:	0f 85 8a 00 00 00    	jne    801016c1 <ilock+0xc0>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101637:	8b 53 04             	mov    0x4(%ebx),%edx
8010163a:	c1 ea 03             	shr    $0x3,%edx
8010163d:	03 15 d4 09 11 80    	add    0x801109d4,%edx
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
8010169a:	e8 ce 28 00 00       	call   80103f6d <memmove>
    brelse(bp);
8010169f:	89 34 24             	mov    %esi,(%esp)
801016a2:	e8 1b eb ff ff       	call   801001c2 <brelse>
    ip->valid = 1;
801016a7:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
801016ae:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
801016b3:	75 0c                	jne    801016c1 <ilock+0xc0>
      panic("ilock: no type");
801016b5:	c7 04 24 f0 6a 10 80 	movl   $0x80106af0,(%esp)
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
801016dd:	e8 dd 25 00 00       	call   80103cbf <holdingsleep>
801016e2:	85 c0                	test   %eax,%eax
801016e4:	74 06                	je     801016ec <iunlock+0x24>
801016e6:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
801016ea:	7f 0c                	jg     801016f8 <iunlock+0x30>
    panic("iunlock");
801016ec:	c7 04 24 ff 6a 10 80 	movl   $0x80106aff,(%esp)
801016f3:	e8 2d ec ff ff       	call   80100325 <panic>
  releasesleep(&ip->lock);
801016f8:	89 34 24             	mov    %esi,(%esp)
801016fb:	e8 85 25 00 00       	call   80103c85 <releasesleep>
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
80101719:	e8 1e 25 00 00       	call   80103c3c <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010171e:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101722:	74 43                	je     80101767 <iput+0x60>
80101724:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101729:	75 3c                	jne    80101767 <iput+0x60>
    acquire(&icache.lock);
8010172b:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101732:	e8 0c 27 00 00       	call   80103e43 <acquire>
    int r = ip->ref;
80101737:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
8010173a:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101741:	e8 5e 27 00 00       	call   80103ea4 <release>
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
8010176a:	e8 16 25 00 00       	call   80103c85 <releasesleep>
  acquire(&icache.lock);
8010176f:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101776:	e8 c8 26 00 00       	call   80103e43 <acquire>
  ip->ref--;
8010177b:	83 6b 08 01          	subl   $0x1,0x8(%ebx)
  release(&icache.lock);
8010177f:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101786:	e8 19 27 00 00       	call   80103ea4 <release>
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
80101803:	8b 04 c5 60 09 11 80 	mov    -0x7feef6a0(,%eax,8),%eax
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
801018a3:	e8 c5 26 00 00       	call   80103f6d <memmove>
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
80101908:	8b 04 c5 64 09 11 80 	mov    -0x7feef69c(,%eax,8),%eax
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
801019aa:	e8 be 25 00 00       	call   80103f6d <memmove>
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
80101a31:	e8 ac 25 00 00       	call   80103fe2 <strncmp>
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
80101a4b:	c7 04 24 07 6b 10 80 	movl   $0x80106b07,(%esp)
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
80101a74:	c7 04 24 19 6b 10 80 	movl   $0x80106b19,(%esp)
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
80101afd:	e8 bb 17 00 00       	call   801032bd <myproc>
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
80101c01:	c7 04 24 28 6b 10 80 	movl   $0x80106b28,(%esp)
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
80101c40:	e8 da 23 00 00       	call   8010401f <strncpy>
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
80101c69:	c7 04 24 44 72 10 80 	movl   $0x80107244,(%esp)
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
80101cf4:	c7 04 24 8b 6b 10 80 	movl   $0x80106b8b,(%esp)
80101cfb:	e8 25 e6 ff ff       	call   80100325 <panic>
  if(b->blockno >= FSSIZE)
80101d00:	8b 58 08             	mov    0x8(%eax),%ebx
80101d03:	81 fb cf 07 00 00    	cmp    $0x7cf,%ebx
80101d09:	76 0c                	jbe    80101d17 <idestart+0x31>
    panic("incorrect blockno");
80101d0b:	c7 04 24 94 6b 10 80 	movl   $0x80106b94,(%esp)
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
80101d99:	c7 44 24 04 a6 6b 10 	movl   $0x80106ba6,0x4(%esp)
80101da0:	80 
80101da1:	c7 04 24 80 a5 10 80 	movl   $0x8010a580,(%esp)
80101da8:	e8 5e 1f 00 00       	call   80103d0b <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101dad:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
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
80101e1b:	e8 23 20 00 00       	call   80103e43 <acquire>

  if((b = idequeue) == 0){
80101e20:	8b 1d 64 a5 10 80    	mov    0x8010a564,%ebx
80101e26:	85 db                	test   %ebx,%ebx
80101e28:	75 0e                	jne    80101e38 <ideintr+0x2c>
    release(&idelock);
80101e2a:	c7 04 24 80 a5 10 80 	movl   $0x8010a580,(%esp)
80101e31:	e8 6e 20 00 00       	call   80103ea4 <release>
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
80101e70:	e8 25 1a 00 00       	call   8010389a <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101e75:	a1 64 a5 10 80       	mov    0x8010a564,%eax
80101e7a:	85 c0                	test   %eax,%eax
80101e7c:	74 05                	je     80101e83 <ideintr+0x77>
    idestart(idequeue);
80101e7e:	e8 63 fe ff ff       	call   80101ce6 <idestart>

  release(&idelock);
80101e83:	c7 04 24 80 a5 10 80 	movl   $0x8010a580,(%esp)
80101e8a:	e8 15 20 00 00       	call   80103ea4 <release>
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
80101ea6:	e8 14 1e 00 00       	call   80103cbf <holdingsleep>
80101eab:	85 c0                	test   %eax,%eax
80101ead:	75 0c                	jne    80101ebb <iderw+0x25>
    panic("iderw: buf not locked");
80101eaf:	c7 04 24 aa 6b 10 80 	movl   $0x80106baa,(%esp)
80101eb6:	e8 6a e4 ff ff       	call   80100325 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101ebb:	8b 03                	mov    (%ebx),%eax
80101ebd:	83 e0 06             	and    $0x6,%eax
80101ec0:	83 f8 02             	cmp    $0x2,%eax
80101ec3:	75 0c                	jne    80101ed1 <iderw+0x3b>
    panic("iderw: nothing to do");
80101ec5:	c7 04 24 c0 6b 10 80 	movl   $0x80106bc0,(%esp)
80101ecc:	e8 54 e4 ff ff       	call   80100325 <panic>
  if(b->dev != 0 && !havedisk1)
80101ed1:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80101ed5:	74 15                	je     80101eec <iderw+0x56>
80101ed7:	83 3d 60 a5 10 80 00 	cmpl   $0x0,0x8010a560
80101ede:	75 0c                	jne    80101eec <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80101ee0:	c7 04 24 d5 6b 10 80 	movl   $0x80106bd5,(%esp)
80101ee7:	e8 39 e4 ff ff       	call   80100325 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80101eec:	c7 04 24 80 a5 10 80 	movl   $0x8010a580,(%esp)
80101ef3:	e8 4b 1f 00 00       	call   80103e43 <acquire>

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
80101f2d:	e8 13 18 00 00       	call   80103745 <sleep>
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101f32:	8b 03                	mov    (%ebx),%eax
80101f34:	83 e0 06             	and    $0x6,%eax
80101f37:	83 f8 02             	cmp    $0x2,%eax
80101f3a:	75 e6                	jne    80101f22 <iderw+0x8c>
  }


  release(&idelock);
80101f3c:	c7 04 24 80 a5 10 80 	movl   $0x8010a580,(%esp)
80101f43:	e8 5c 1f 00 00       	call   80103ea4 <release>
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
80101f51:	8b 15 34 26 11 80    	mov    0x80112634,%edx
80101f57:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101f59:	a1 34 26 11 80       	mov    0x80112634,%eax
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
80101f66:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
80101f6c:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101f6e:	a1 34 26 11 80       	mov    0x80112634,%eax
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
80101f81:	c7 05 34 26 11 80 00 	movl   $0xfec00000,0x80112634
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
80101fa8:	0f b6 15 20 27 11 80 	movzbl 0x80112720,%edx
80101faf:	39 c2                	cmp    %eax,%edx
80101fb1:	74 0c                	je     80101fbf <ioapicinit+0x47>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101fb3:	c7 04 24 f4 6b 10 80 	movl   $0x80106bf4,(%esp)
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
8010202e:	81 fb a8 54 11 80    	cmp    $0x801154a8,%ebx
80102034:	72 21                	jb     80102057 <kfree+0x3b>

// Convert kernel virtual address to physical address
static inline uint V2P(void *a) {
    // define panic() here because memlayout.h is included before defs.h
    extern void panic(char*) __attribute__((noreturn));
    if (a < (void*) KERNBASE)
80102036:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
8010203c:	77 0c                	ja     8010204a <kfree+0x2e>
        panic("V2P on address < KERNBASE "
8010203e:	c7 04 24 28 6c 10 80 	movl   $0x80106c28,(%esp)
80102045:	e8 db e2 ff ff       	call   80100325 <panic>
              "(not a kernel virtual address; consider walking page "
              "table to determine physical address of a user virtual address)");
    return (uint)a - KERNBASE;
8010204a:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80102050:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102055:	76 0c                	jbe    80102063 <kfree+0x47>
    panic("kfree");
80102057:	c7 04 24 b6 6c 10 80 	movl   $0x80106cb6,(%esp)
8010205e:	e8 c2 e2 ff ff       	call   80100325 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102063:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010206a:	00 
8010206b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102072:	00 
80102073:	89 1c 24             	mov    %ebx,(%esp)
80102076:	e8 75 1e 00 00       	call   80103ef0 <memset>

  if(kmem.use_lock)
8010207b:	83 3d 14 2d 11 80 00 	cmpl   $0x0,0x80112d14
80102082:	74 0c                	je     80102090 <kfree+0x74>
    acquire(&kmem.lock);
80102084:	c7 04 24 e0 2c 11 80 	movl   $0x80112ce0,(%esp)
8010208b:	e8 b3 1d 00 00       	call   80103e43 <acquire>
  r = (struct run*)v;
  r->next = kmem.freelist;
80102090:	a1 18 2d 11 80       	mov    0x80112d18,%eax
80102095:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80102097:	89 1d 18 2d 11 80    	mov    %ebx,0x80112d18
  if(kmem.use_lock)
8010209d:	83 3d 14 2d 11 80 00 	cmpl   $0x0,0x80112d14
801020a4:	74 0c                	je     801020b2 <kfree+0x96>
    release(&kmem.lock);
801020a6:	c7 04 24 e0 2c 11 80 	movl   $0x80112ce0,(%esp)
801020ad:	e8 f2 1d 00 00       	call   80103ea4 <release>
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
801020ca:	c7 04 24 bc 6c 10 80 	movl   $0x80106cbc,(%esp)
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
80102103:	c7 44 24 04 c6 6c 10 	movl   $0x80106cc6,0x4(%esp)
8010210a:	80 
8010210b:	c7 04 24 e0 2c 11 80 	movl   $0x80112ce0,(%esp)
80102112:	e8 f4 1b 00 00       	call   80103d0b <initlock>
  kmem.use_lock = 0;
80102117:	c7 05 14 2d 11 80 00 	movl   $0x0,0x80112d14
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
8010214d:	c7 05 14 2d 11 80 01 	movl   $0x1,0x80112d14
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
80102160:	83 3d 14 2d 11 80 00 	cmpl   $0x0,0x80112d14
80102167:	74 0c                	je     80102175 <kalloc+0x1c>
    acquire(&kmem.lock);
80102169:	c7 04 24 e0 2c 11 80 	movl   $0x80112ce0,(%esp)
80102170:	e8 ce 1c 00 00       	call   80103e43 <acquire>
  r = kmem.freelist;
80102175:	8b 1d 18 2d 11 80    	mov    0x80112d18,%ebx
  if(r)
8010217b:	85 db                	test   %ebx,%ebx
8010217d:	74 07                	je     80102186 <kalloc+0x2d>
    kmem.freelist = r->next;
8010217f:	8b 03                	mov    (%ebx),%eax
80102181:	a3 18 2d 11 80       	mov    %eax,0x80112d18
  if(kmem.use_lock)
80102186:	83 3d 14 2d 11 80 00 	cmpl   $0x0,0x80112d14
8010218d:	74 0c                	je     8010219b <kalloc+0x42>
    release(&kmem.lock);
8010218f:	c7 04 24 e0 2c 11 80 	movl   $0x80112ce0,(%esp)
80102196:	e8 09 1d 00 00       	call   80103ea4 <release>
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
801021e7:	0f b6 81 00 6e 10 80 	movzbl -0x7fef9200(%ecx),%eax
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
8010221f:	0f b6 91 00 6e 10 80 	movzbl -0x7fef9200(%ecx),%edx
80102226:	0b 15 b4 a5 10 80    	or     0x8010a5b4,%edx
  shift ^= togglecode[data];
8010222c:	0f b6 81 00 6d 10 80 	movzbl -0x7fef9300(%ecx),%eax
80102233:	31 c2                	xor    %eax,%edx
80102235:	89 15 b4 a5 10 80    	mov    %edx,0x8010a5b4
  c = charcode[shift & (CTL | SHIFT)][data];
8010223b:	89 d0                	mov    %edx,%eax
8010223d:	83 e0 03             	and    $0x3,%eax
80102240:	8b 04 85 e0 6c 10 80 	mov    -0x7fef9320(,%eax,4),%eax
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
80102298:	8b 0d 38 26 11 80    	mov    0x80112638,%ecx
8010229e:	8d 04 81             	lea    (%ecx,%eax,4),%eax
801022a1:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
801022a3:	a1 38 26 11 80       	mov    0x80112638,%eax
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
80102314:	83 3d 38 26 11 80 00 	cmpl   $0x0,0x80112638
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
8010237e:	a1 38 26 11 80       	mov    0x80112638,%eax
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
801023f6:	a1 38 26 11 80       	mov    0x80112638,%eax
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
8010241b:	a1 38 26 11 80       	mov    0x80112638,%eax
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
80102433:	83 3d 38 26 11 80 00 	cmpl   $0x0,0x80112638
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
80102538:	e8 f9 19 00 00       	call   80103f36 <memcmp>
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
801025fe:	a1 74 26 11 80       	mov    0x80112674,%eax
80102603:	89 44 24 04          	mov    %eax,0x4(%esp)
80102607:	a1 84 26 11 80       	mov    0x80112684,%eax
8010260c:	89 04 24             	mov    %eax,(%esp)
8010260f:	e8 4f db ff ff       	call   80100163 <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
80102614:	8b 58 5c             	mov    0x5c(%eax),%ebx
80102617:	89 1d 88 26 11 80    	mov    %ebx,0x80112688
  for (i = 0; i < log.lh.n; i++) {
8010261d:	ba 00 00 00 00       	mov    $0x0,%edx
80102622:	eb 0e                	jmp    80102632 <read_head+0x3b>
    log.lh.block[i] = lh->block[i];
80102624:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102628:	89 0c 95 8c 26 11 80 	mov    %ecx,-0x7feed974(,%edx,4)
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
80102656:	03 05 74 26 11 80    	add    0x80112674,%eax
8010265c:	83 c0 01             	add    $0x1,%eax
8010265f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102663:	a1 84 26 11 80       	mov    0x80112684,%eax
80102668:	89 04 24             	mov    %eax,(%esp)
8010266b:	e8 f3 da ff ff       	call   80100163 <bread>
80102670:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102672:	8b 04 9d 8c 26 11 80 	mov    -0x7feed974(,%ebx,4),%eax
80102679:	89 44 24 04          	mov    %eax,0x4(%esp)
8010267d:	a1 84 26 11 80       	mov    0x80112684,%eax
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
801026a1:	e8 c7 18 00 00       	call   80103f6d <memmove>
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
801026c1:	39 1d 88 26 11 80    	cmp    %ebx,0x80112688
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
801026d8:	a1 74 26 11 80       	mov    0x80112674,%eax
801026dd:	89 44 24 04          	mov    %eax,0x4(%esp)
801026e1:	a1 84 26 11 80       	mov    0x80112684,%eax
801026e6:	89 04 24             	mov    %eax,(%esp)
801026e9:	e8 75 da ff ff       	call   80100163 <bread>
801026ee:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
801026f0:	a1 88 26 11 80       	mov    0x80112688,%eax
801026f5:	89 43 5c             	mov    %eax,0x5c(%ebx)
  for (i = 0; i < log.lh.n; i++) {
801026f8:	ba 00 00 00 00       	mov    $0x0,%edx
801026fd:	eb 0e                	jmp    8010270d <write_head+0x3c>
    hb->block[i] = log.lh.block[i];
801026ff:	8b 0c 95 8c 26 11 80 	mov    -0x7feed974(,%edx,4),%ecx
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
80102737:	c7 05 88 26 11 80 00 	movl   $0x0,0x80112688
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
8010275a:	03 05 74 26 11 80    	add    0x80112674,%eax
80102760:	83 c0 01             	add    $0x1,%eax
80102763:	89 44 24 04          	mov    %eax,0x4(%esp)
80102767:	a1 84 26 11 80       	mov    0x80112684,%eax
8010276c:	89 04 24             	mov    %eax,(%esp)
8010276f:	e8 ef d9 ff ff       	call   80100163 <bread>
80102774:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102776:	8b 04 9d 8c 26 11 80 	mov    -0x7feed974(,%ebx,4),%eax
8010277d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102781:	a1 84 26 11 80       	mov    0x80112684,%eax
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
801027a5:	e8 c3 17 00 00       	call   80103f6d <memmove>
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
801027c5:	39 1d 88 26 11 80    	cmp    %ebx,0x80112688
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
801027d5:	83 3d 88 26 11 80 00 	cmpl   $0x0,0x80112688
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
801027f3:	c7 05 88 26 11 80 00 	movl   $0x0,0x80112688
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
8010280f:	c7 44 24 04 00 6f 10 	movl   $0x80106f00,0x4(%esp)
80102816:	80 
80102817:	c7 04 24 40 26 11 80 	movl   $0x80112640,(%esp)
8010281e:	e8 e8 14 00 00       	call   80103d0b <initlock>
  readsb(dev, &sb);
80102823:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102826:	89 44 24 04          	mov    %eax,0x4(%esp)
8010282a:	89 1c 24             	mov    %ebx,(%esp)
8010282d:	e8 dd ea ff ff       	call   8010130f <readsb>
  log.start = sb.logstart;
80102832:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102835:	a3 74 26 11 80       	mov    %eax,0x80112674
  log.size = sb.nlog;
8010283a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010283d:	a3 78 26 11 80       	mov    %eax,0x80112678
  log.dev = dev;
80102842:	89 1d 84 26 11 80    	mov    %ebx,0x80112684
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
80102859:	c7 04 24 40 26 11 80 	movl   $0x80112640,(%esp)
80102860:	e8 de 15 00 00       	call   80103e43 <acquire>
    if(log.committing){
80102865:	83 3d 80 26 11 80 00 	cmpl   $0x0,0x80112680
8010286c:	74 16                	je     80102884 <begin_op+0x31>
      sleep(&log, &log.lock);
8010286e:	c7 44 24 04 40 26 11 	movl   $0x80112640,0x4(%esp)
80102875:	80 
80102876:	c7 04 24 40 26 11 80 	movl   $0x80112640,(%esp)
8010287d:	e8 c3 0e 00 00       	call   80103745 <sleep>
80102882:	eb e1                	jmp    80102865 <begin_op+0x12>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102884:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102889:	8d 50 01             	lea    0x1(%eax),%edx
8010288c:	8d 04 92             	lea    (%edx,%edx,4),%eax
8010288f:	01 c0                	add    %eax,%eax
80102891:	03 05 88 26 11 80    	add    0x80112688,%eax
80102897:	83 f8 1e             	cmp    $0x1e,%eax
8010289a:	7e 16                	jle    801028b2 <begin_op+0x5f>
      sleep(&log, &log.lock);
8010289c:	c7 44 24 04 40 26 11 	movl   $0x80112640,0x4(%esp)
801028a3:	80 
801028a4:	c7 04 24 40 26 11 80 	movl   $0x80112640,(%esp)
801028ab:	e8 95 0e 00 00       	call   80103745 <sleep>
801028b0:	eb b3                	jmp    80102865 <begin_op+0x12>
      log.outstanding += 1;
801028b2:	89 15 7c 26 11 80    	mov    %edx,0x8011267c
      release(&log.lock);
801028b8:	c7 04 24 40 26 11 80 	movl   $0x80112640,(%esp)
801028bf:	e8 e0 15 00 00       	call   80103ea4 <release>
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
801028cd:	c7 04 24 40 26 11 80 	movl   $0x80112640,(%esp)
801028d4:	e8 6a 15 00 00       	call   80103e43 <acquire>
  log.outstanding -= 1;
801028d9:	a1 7c 26 11 80       	mov    0x8011267c,%eax
801028de:	83 e8 01             	sub    $0x1,%eax
801028e1:	a3 7c 26 11 80       	mov    %eax,0x8011267c
  if(log.committing)
801028e6:	83 3d 80 26 11 80 00 	cmpl   $0x0,0x80112680
801028ed:	74 0c                	je     801028fb <end_op+0x35>
    panic("log.committing");
801028ef:	c7 04 24 04 6f 10 80 	movl   $0x80106f04,(%esp)
801028f6:	e8 2a da ff ff       	call   80100325 <panic>
  if(log.outstanding == 0){
801028fb:	85 c0                	test   %eax,%eax
801028fd:	75 11                	jne    80102910 <end_op+0x4a>
    log.committing = 1;
801028ff:	c7 05 80 26 11 80 01 	movl   $0x1,0x80112680
80102906:	00 00 00 
    do_commit = 1;
80102909:	bb 01 00 00 00       	mov    $0x1,%ebx
8010290e:	eb 11                	jmp    80102921 <end_op+0x5b>
    wakeup(&log);
80102910:	c7 04 24 40 26 11 80 	movl   $0x80112640,(%esp)
80102917:	e8 7e 0f 00 00       	call   8010389a <wakeup>
  int do_commit = 0;
8010291c:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&log.lock);
80102921:	c7 04 24 40 26 11 80 	movl   $0x80112640,(%esp)
80102928:	e8 77 15 00 00       	call   80103ea4 <release>
  if(do_commit){
8010292d:	85 db                	test   %ebx,%ebx
8010292f:	74 33                	je     80102964 <end_op+0x9e>
    commit();
80102931:	e8 9f fe ff ff       	call   801027d5 <commit>
    acquire(&log.lock);
80102936:	c7 04 24 40 26 11 80 	movl   $0x80112640,(%esp)
8010293d:	e8 01 15 00 00       	call   80103e43 <acquire>
    log.committing = 0;
80102942:	c7 05 80 26 11 80 00 	movl   $0x0,0x80112680
80102949:	00 00 00 
    wakeup(&log);
8010294c:	c7 04 24 40 26 11 80 	movl   $0x80112640,(%esp)
80102953:	e8 42 0f 00 00       	call   8010389a <wakeup>
    release(&log.lock);
80102958:	c7 04 24 40 26 11 80 	movl   $0x80112640,(%esp)
8010295f:	e8 40 15 00 00       	call   80103ea4 <release>
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
80102974:	a1 88 26 11 80       	mov    0x80112688,%eax
80102979:	83 f8 1d             	cmp    $0x1d,%eax
8010297c:	7f 0d                	jg     8010298b <log_write+0x21>
8010297e:	8b 0d 78 26 11 80    	mov    0x80112678,%ecx
80102984:	8d 51 ff             	lea    -0x1(%ecx),%edx
80102987:	39 d0                	cmp    %edx,%eax
80102989:	7c 0c                	jl     80102997 <log_write+0x2d>
    panic("too big a transaction");
8010298b:	c7 04 24 13 6f 10 80 	movl   $0x80106f13,(%esp)
80102992:	e8 8e d9 ff ff       	call   80100325 <panic>
  if (log.outstanding < 1)
80102997:	83 3d 7c 26 11 80 00 	cmpl   $0x0,0x8011267c
8010299e:	7f 0c                	jg     801029ac <log_write+0x42>
    panic("log_write outside of trans");
801029a0:	c7 04 24 29 6f 10 80 	movl   $0x80106f29,(%esp)
801029a7:	e8 79 d9 ff ff       	call   80100325 <panic>

  acquire(&log.lock);
801029ac:	c7 04 24 40 26 11 80 	movl   $0x80112640,(%esp)
801029b3:	e8 8b 14 00 00       	call   80103e43 <acquire>
  for (i = 0; i < log.lh.n; i++) {
801029b8:	b8 00 00 00 00       	mov    $0x0,%eax
801029bd:	eb 0f                	jmp    801029ce <log_write+0x64>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801029bf:	8b 4b 08             	mov    0x8(%ebx),%ecx
801029c2:	39 0c 85 8c 26 11 80 	cmp    %ecx,-0x7feed974(,%eax,4)
801029c9:	74 0d                	je     801029d8 <log_write+0x6e>
  for (i = 0; i < log.lh.n; i++) {
801029cb:	83 c0 01             	add    $0x1,%eax
801029ce:	8b 15 88 26 11 80    	mov    0x80112688,%edx
801029d4:	39 c2                	cmp    %eax,%edx
801029d6:	7f e7                	jg     801029bf <log_write+0x55>
      break;
  }
  log.lh.block[i] = b->blockno;
801029d8:	8b 4b 08             	mov    0x8(%ebx),%ecx
801029db:	89 0c 85 8c 26 11 80 	mov    %ecx,-0x7feed974(,%eax,4)
  if (i == log.lh.n)
801029e2:	39 d0                	cmp    %edx,%eax
801029e4:	75 09                	jne    801029ef <log_write+0x85>
    log.lh.n++;
801029e6:	83 c2 01             	add    $0x1,%edx
801029e9:	89 15 88 26 11 80    	mov    %edx,0x80112688
  b->flags |= B_DIRTY; // prevent eviction
801029ef:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
801029f2:	c7 04 24 40 26 11 80 	movl   $0x80112640,(%esp)
801029f9:	e8 a6 14 00 00       	call   80103ea4 <release>
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
80102a2f:	e8 39 15 00 00       	call   80103f6d <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102a34:	bb 40 27 11 80       	mov    $0x80112740,%ebx
    if (a < (void*) KERNBASE)
80102a39:	be 00 90 10 80       	mov    $0x80109000,%esi
80102a3e:	eb 63                	jmp    80102aa3 <startothers+0x93>
    if(c == mycpu())  // We've started already.
80102a40:	e8 03 08 00 00       	call   80103248 <mycpu>
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
80102a6a:	c7 04 24 28 6c 10 80 	movl   $0x80106c28,(%esp)
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
80102aa3:	69 05 c0 2c 11 80 b0 	imul   $0xb0,0x80112cc0,%eax
80102aaa:	00 00 00 
80102aad:	05 40 27 11 80       	add    $0x80112740,%eax
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
80102ac4:	e8 d9 07 00 00       	call   801032a2 <cpuid>
80102ac9:	89 c3                	mov    %eax,%ebx
80102acb:	e8 d2 07 00 00       	call   801032a2 <cpuid>
80102ad0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80102ad4:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ad8:	c7 04 24 44 6f 10 80 	movl   $0x80106f44,(%esp)
80102adf:	e8 e3 da ff ff       	call   801005c7 <cprintf>
  idtinit();       // load idt register
80102ae4:	e8 33 26 00 00       	call   8010511c <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102ae9:	e8 5a 07 00 00       	call   80103248 <mycpu>
80102aee:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102af0:	b8 01 00 00 00       	mov    $0x1,%eax
80102af5:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102afc:	e8 36 0a 00 00       	call   80103537 <scheduler>

80102b01 <mpenter>:
{
80102b01:	55                   	push   %ebp
80102b02:	89 e5                	mov    %esp,%ebp
80102b04:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102b07:	e8 18 37 00 00       	call   80106224 <switchkvm>
  seginit();
80102b0c:	e8 0f 35 00 00       	call   80106020 <seginit>
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
80102b2c:	c7 04 24 a8 54 11 80 	movl   $0x801154a8,(%esp)
80102b33:	e8 c5 f5 ff ff       	call   801020fd <kinit1>
  kvmalloc();      // kernel page table
80102b38:	e8 32 3c 00 00       	call   8010676f <kvmalloc>
  mpinit();        // detect other processors
80102b3d:	e8 fc 01 00 00       	call   80102d3e <mpinit>
  lapicinit();     // interrupt controller
80102b42:	e8 cd f7 ff ff       	call   80102314 <lapicinit>
  seginit();       // segment descriptors
80102b47:	e8 d4 34 00 00       	call   80106020 <seginit>
80102b4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  picinit();       // disable pic
80102b50:	e8 a8 02 00 00       	call   80102dfd <picinit>
  ioapicinit();    // another interrupt controller
80102b55:	e8 1e f4 ff ff       	call   80101f78 <ioapicinit>
  consoleinit();   // console hardware
80102b5a:	e8 de dc ff ff       	call   8010083d <consoleinit>
80102b5f:	90                   	nop
  uartinit();      // serial port
80102b60:	e8 9d 29 00 00       	call   80105502 <uartinit>
  pinit();         // process table
80102b65:	e8 c2 06 00 00       	call   8010322c <pinit>
  tvinit();        // trap vectors
80102b6a:	e8 21 25 00 00       	call   80105090 <tvinit>
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
80102b99:	e8 43 07 00 00       	call   801032e1 <userinit>
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
80102bd6:	c7 04 24 58 6f 10 80 	movl   $0x80106f58,(%esp)
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
80102bf6:	c7 44 24 04 72 6f 10 	movl   $0x80106f72,0x4(%esp)
80102bfd:	80 
80102bfe:	89 1c 24             	mov    %ebx,(%esp)
80102c01:	e8 30 13 00 00       	call   80103f36 <memcmp>
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
80102cc0:	c7 04 24 58 6f 10 80 	movl   $0x80106f58,(%esp)
80102cc7:	e8 59 d6 ff ff       	call   80100325 <panic>
    return (char*)a + KERNBASE;
80102ccc:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
  if(memcmp(conf, "PCMP", 4) != 0)
80102cd2:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80102cd9:	00 
80102cda:	c7 44 24 04 77 6f 10 	movl   $0x80106f77,0x4(%esp)
80102ce1:	80 
80102ce2:	89 1c 24             	mov    %ebx,(%esp)
80102ce5:	e8 4c 12 00 00       	call   80103f36 <memcmp>
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
80102d52:	c7 04 24 7c 6f 10 80 	movl   $0x80106f7c,(%esp)
80102d59:	e8 c7 d5 ff ff       	call   80100325 <panic>
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102d5e:	8b 50 24             	mov    0x24(%eax),%edx
80102d61:	89 15 38 26 11 80    	mov    %edx,0x80112638
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
80102d81:	ff 24 85 b4 6f 10 80 	jmp    *-0x7fef904c(,%eax,4)
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102d88:	8b 35 c0 2c 11 80    	mov    0x80112cc0,%esi
80102d8e:	83 fe 07             	cmp    $0x7,%esi
80102d91:	7f 17                	jg     80102daa <mpinit+0x6c>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102d93:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102d97:	69 f6 b0 00 00 00    	imul   $0xb0,%esi,%esi
80102d9d:	88 86 40 27 11 80    	mov    %al,-0x7feed8c0(%esi)
        ncpu++;
80102da3:	83 05 c0 2c 11 80 01 	addl   $0x1,0x80112cc0
      }
      p += sizeof(struct mpproc);
80102daa:	83 c2 14             	add    $0x14,%edx
      continue;
80102dad:	eb 18                	jmp    80102dc7 <mpinit+0x89>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102daf:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102db3:	a2 20 27 11 80       	mov    %al,0x80112720
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
80102dcf:	c7 04 24 94 6f 10 80 	movl   $0x80106f94,(%esp)
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
80102e7c:	c7 44 24 04 c8 6f 10 	movl   $0x80106fc8,0x4(%esp)
80102e83:	80 
80102e84:	89 04 24             	mov    %eax,(%esp)
80102e87:	e8 7f 0e 00 00       	call   80103d0b <initlock>
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
80102f1a:	e8 24 0f 00 00       	call   80103e43 <acquire>
  if(writable){
80102f1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102f23:	74 1a                	je     80102f3f <pipeclose+0x32>
    p->writeopen = 0;
80102f25:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102f2c:	00 00 00 
    wakeup(&p->nread);
80102f2f:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f35:	89 04 24             	mov    %eax,(%esp)
80102f38:	e8 5d 09 00 00       	call   8010389a <wakeup>
80102f3d:	eb 18                	jmp    80102f57 <pipeclose+0x4a>
  } else {
    p->readopen = 0;
80102f3f:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102f46:	00 00 00 
    wakeup(&p->nwrite);
80102f49:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f4f:	89 04 24             	mov    %eax,(%esp)
80102f52:	e8 43 09 00 00       	call   8010389a <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102f57:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102f5e:	75 1b                	jne    80102f7b <pipeclose+0x6e>
80102f60:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102f67:	75 12                	jne    80102f7b <pipeclose+0x6e>
    release(&p->lock);
80102f69:	89 1c 24             	mov    %ebx,(%esp)
80102f6c:	e8 33 0f 00 00       	call   80103ea4 <release>
    kfree((char*)p);
80102f71:	89 1c 24             	mov    %ebx,(%esp)
80102f74:	e8 a3 f0 ff ff       	call   8010201c <kfree>
80102f79:	eb 08                	jmp    80102f83 <pipeclose+0x76>
  } else
    release(&p->lock);
80102f7b:	89 1c 24             	mov    %ebx,(%esp)
80102f7e:	e8 21 0f 00 00       	call   80103ea4 <release>
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
80102f9a:	e8 a4 0e 00 00       	call   80103e43 <acquire>
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
80102fc0:	e8 f8 02 00 00       	call   801032bd <myproc>
80102fc5:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102fc9:	74 0f                	je     80102fda <pipewrite+0x51>
        release(&p->lock);
80102fcb:	89 1c 24             	mov    %ebx,(%esp)
80102fce:	e8 d1 0e 00 00       	call   80103ea4 <release>
        return -1;
80102fd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102fd8:	eb 6e                	jmp    80103048 <pipewrite+0xbf>
      wakeup(&p->nread);
80102fda:	89 34 24             	mov    %esi,(%esp)
80102fdd:	e8 b8 08 00 00       	call   8010389a <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102fe2:	89 7c 24 04          	mov    %edi,0x4(%esp)
80102fe6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102fe9:	89 04 24             	mov    %eax,(%esp)
80102fec:	e8 54 07 00 00       	call   80103745 <sleep>
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
80103038:	e8 5d 08 00 00       	call   8010389a <wakeup>
  release(&p->lock);
8010303d:	89 1c 24             	mov    %ebx,(%esp)
80103040:	e8 5f 0e 00 00       	call   80103ea4 <release>
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
80103061:	e8 dd 0d 00 00       	call   80103e43 <acquire>
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
8010306e:	e8 4a 02 00 00       	call   801032bd <myproc>
80103073:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80103077:	74 0f                	je     80103088 <piperead+0x38>
      release(&p->lock);
80103079:	89 1c 24             	mov    %ebx,(%esp)
8010307c:	e8 23 0e 00 00       	call   80103ea4 <release>
      return -1;
80103081:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103086:	eb 78                	jmp    80103100 <piperead+0xb0>
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103088:	89 7c 24 04          	mov    %edi,0x4(%esp)
8010308c:	89 34 24             	mov    %esi,(%esp)
8010308f:	e8 b1 06 00 00       	call   80103745 <sleep>
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
801030f1:	e8 a4 07 00 00       	call   8010389a <wakeup>
  release(&p->lock);
801030f6:	89 1c 24             	mov    %ebx,(%esp)
801030f9:	e8 a6 0d 00 00       	call   80103ea4 <release>
  return i;
801030fe:	89 f0                	mov    %esi,%eax
}
80103100:	83 c4 1c             	add    $0x1c,%esp
80103103:	5b                   	pop    %ebx
80103104:	5e                   	pop    %esi
80103105:	5f                   	pop    %edi
80103106:	5d                   	pop    %ebp
80103107:	c3                   	ret    

80103108 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80103108:	55                   	push   %ebp
80103109:	89 e5                	mov    %esp,%ebp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010310b:	ba 54 2d 11 80       	mov    $0x80112d54,%edx
80103110:	eb 15                	jmp    80103127 <wakeup1+0x1f>
    if(p->state == SLEEPING && p->chan == chan)
80103112:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
80103116:	75 0c                	jne    80103124 <wakeup1+0x1c>
80103118:	39 42 20             	cmp    %eax,0x20(%edx)
8010311b:	75 07                	jne    80103124 <wakeup1+0x1c>
      p->state = RUNNABLE;
8010311d:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103124:	83 c2 7c             	add    $0x7c,%edx
80103127:	81 fa 54 4c 11 80    	cmp    $0x80114c54,%edx
8010312d:	72 e3                	jb     80103112 <wakeup1+0xa>
}
8010312f:	5d                   	pop    %ebp
80103130:	c3                   	ret    

80103131 <allocproc>:
{
80103131:	55                   	push   %ebp
80103132:	89 e5                	mov    %esp,%ebp
80103134:	53                   	push   %ebx
80103135:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80103138:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010313f:	e8 ff 0c 00 00       	call   80103e43 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103144:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
80103149:	eb 09                	jmp    80103154 <allocproc+0x23>
    if(p->state == UNUSED)
8010314b:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
8010314f:	74 1e                	je     8010316f <allocproc+0x3e>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103151:	83 c3 7c             	add    $0x7c,%ebx
80103154:	81 fb 54 4c 11 80    	cmp    $0x80114c54,%ebx
8010315a:	72 ef                	jb     8010314b <allocproc+0x1a>
  release(&ptable.lock);
8010315c:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103163:	e8 3c 0d 00 00       	call   80103ea4 <release>
  return 0;
80103168:	b8 00 00 00 00       	mov    $0x0,%eax
8010316d:	eb 78                	jmp    801031e7 <allocproc+0xb6>
  p->state = EMBRYO;
8010316f:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
80103176:	a1 04 a0 10 80       	mov    0x8010a004,%eax
8010317b:	8d 50 01             	lea    0x1(%eax),%edx
8010317e:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
80103184:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
80103187:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010318e:	e8 11 0d 00 00       	call   80103ea4 <release>
  if((p->kstack = kalloc()) == 0){
80103193:	e8 c1 ef ff ff       	call   80102159 <kalloc>
80103198:	89 43 08             	mov    %eax,0x8(%ebx)
8010319b:	85 c0                	test   %eax,%eax
8010319d:	75 09                	jne    801031a8 <allocproc+0x77>
    p->state = UNUSED;
8010319f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801031a6:	eb 3f                	jmp    801031e7 <allocproc+0xb6>
  sp -= sizeof *p->tf;
801031a8:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
801031ae:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
801031b1:	c7 80 b0 0f 00 00 7c 	movl   $0x8010507c,0xfb0(%eax)
801031b8:	50 10 80 
  sp -= sizeof *p->context;
801031bb:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
801031c0:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
801031c3:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801031ca:	00 
801031cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031d2:	00 
801031d3:	89 04 24             	mov    %eax,(%esp)
801031d6:	e8 15 0d 00 00       	call   80103ef0 <memset>
  p->context->eip = (uint)forkret;
801031db:	8b 43 1c             	mov    0x1c(%ebx),%eax
801031de:	c7 40 10 ed 31 10 80 	movl   $0x801031ed,0x10(%eax)
  return p;
801031e5:	89 d8                	mov    %ebx,%eax
}
801031e7:	83 c4 14             	add    $0x14,%esp
801031ea:	5b                   	pop    %ebx
801031eb:	5d                   	pop    %ebp
801031ec:	c3                   	ret    

801031ed <forkret>:
{
801031ed:	55                   	push   %ebp
801031ee:	89 e5                	mov    %esp,%ebp
801031f0:	83 ec 18             	sub    $0x18,%esp
  release(&ptable.lock);
801031f3:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801031fa:	e8 a5 0c 00 00       	call   80103ea4 <release>
  if (first) {
801031ff:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
80103206:	74 22                	je     8010322a <forkret+0x3d>
    first = 0;
80103208:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
8010320f:	00 00 00 
    iinit(ROOTDEV);
80103212:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103219:	e8 35 e1 ff ff       	call   80101353 <iinit>
    initlog(ROOTDEV);
8010321e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103225:	e8 db f5 ff ff       	call   80102805 <initlog>
}
8010322a:	c9                   	leave  
8010322b:	c3                   	ret    

8010322c <pinit>:
{
8010322c:	55                   	push   %ebp
8010322d:	89 e5                	mov    %esp,%ebp
8010322f:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80103232:	c7 44 24 04 cd 6f 10 	movl   $0x80106fcd,0x4(%esp)
80103239:	80 
8010323a:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103241:	e8 c5 0a 00 00       	call   80103d0b <initlock>
}
80103246:	c9                   	leave  
80103247:	c3                   	ret    

80103248 <mycpu>:
{
80103248:	55                   	push   %ebp
80103249:	89 e5                	mov    %esp,%ebp
8010324b:	83 ec 18             	sub    $0x18,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010324e:	9c                   	pushf  
8010324f:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103250:	f6 c4 02             	test   $0x2,%ah
80103253:	74 0c                	je     80103261 <mycpu+0x19>
    panic("mycpu called with interrupts enabled\n");
80103255:	c7 04 24 f0 70 10 80 	movl   $0x801070f0,(%esp)
8010325c:	e8 c4 d0 ff ff       	call   80100325 <panic>
  apicid = lapicid();
80103261:	e8 b2 f1 ff ff       	call   80102418 <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103266:	ba 00 00 00 00       	mov    $0x0,%edx
8010326b:	eb 14                	jmp    80103281 <mycpu+0x39>
    if (cpus[i].apicid == apicid)
8010326d:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
80103273:	0f b6 89 40 27 11 80 	movzbl -0x7feed8c0(%ecx),%ecx
8010327a:	39 c1                	cmp    %eax,%ecx
8010327c:	74 17                	je     80103295 <mycpu+0x4d>
  for (i = 0; i < ncpu; ++i) {
8010327e:	83 c2 01             	add    $0x1,%edx
80103281:	3b 15 c0 2c 11 80    	cmp    0x80112cc0,%edx
80103287:	7c e4                	jl     8010326d <mycpu+0x25>
  panic("unknown apicid\n");
80103289:	c7 04 24 d4 6f 10 80 	movl   $0x80106fd4,(%esp)
80103290:	e8 90 d0 ff ff       	call   80100325 <panic>
      return &cpus[i];
80103295:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
8010329b:	05 40 27 11 80       	add    $0x80112740,%eax
}
801032a0:	c9                   	leave  
801032a1:	c3                   	ret    

801032a2 <cpuid>:
cpuid() {
801032a2:	55                   	push   %ebp
801032a3:	89 e5                	mov    %esp,%ebp
801032a5:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801032a8:	e8 9b ff ff ff       	call   80103248 <mycpu>
801032ad:	2d 40 27 11 80       	sub    $0x80112740,%eax
801032b2:	c1 f8 04             	sar    $0x4,%eax
801032b5:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801032bb:	c9                   	leave  
801032bc:	c3                   	ret    

801032bd <myproc>:
myproc(void) {
801032bd:	55                   	push   %ebp
801032be:	89 e5                	mov    %esp,%ebp
801032c0:	53                   	push   %ebx
801032c1:	83 ec 04             	sub    $0x4,%esp
  pushcli();
801032c4:	e8 a3 0a 00 00       	call   80103d6c <pushcli>
  c = mycpu();
801032c9:	e8 7a ff ff ff       	call   80103248 <mycpu>
  p = c->proc;
801032ce:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801032d4:	e8 ce 0a 00 00       	call   80103da7 <popcli>
}
801032d9:	89 d8                	mov    %ebx,%eax
801032db:	83 c4 04             	add    $0x4,%esp
801032de:	5b                   	pop    %ebx
801032df:	5d                   	pop    %ebp
801032e0:	c3                   	ret    

801032e1 <userinit>:
{
801032e1:	55                   	push   %ebp
801032e2:	89 e5                	mov    %esp,%ebp
801032e4:	53                   	push   %ebx
801032e5:	83 ec 14             	sub    $0x14,%esp
  p = allocproc();
801032e8:	e8 44 fe ff ff       	call   80103131 <allocproc>
801032ed:	89 c3                	mov    %eax,%ebx
  initproc = p;
801032ef:	a3 b8 a5 10 80       	mov    %eax,0x8010a5b8
  if((p->pgdir = setupkvm()) == 0)
801032f4:	e8 f1 33 00 00       	call   801066ea <setupkvm>
801032f9:	89 43 04             	mov    %eax,0x4(%ebx)
801032fc:	85 c0                	test   %eax,%eax
801032fe:	75 0c                	jne    8010330c <userinit+0x2b>
    panic("userinit: out of memory?");
80103300:	c7 04 24 e4 6f 10 80 	movl   $0x80106fe4,(%esp)
80103307:	e8 19 d0 ff ff       	call   80100325 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010330c:	c7 44 24 08 2c 00 00 	movl   $0x2c,0x8(%esp)
80103313:	00 
80103314:	c7 44 24 04 60 a4 10 	movl   $0x8010a460,0x4(%esp)
8010331b:	80 
8010331c:	89 04 24             	mov    %eax,(%esp)
8010331f:	e8 28 30 00 00       	call   8010634c <inituvm>
  p->sz = PGSIZE;
80103324:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
8010332a:	8b 43 18             	mov    0x18(%ebx),%eax
8010332d:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80103334:	00 
80103335:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010333c:	00 
8010333d:	89 04 24             	mov    %eax,(%esp)
80103340:	e8 ab 0b 00 00       	call   80103ef0 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103345:	8b 43 18             	mov    0x18(%ebx),%eax
80103348:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010334e:	8b 43 18             	mov    0x18(%ebx),%eax
80103351:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103357:	8b 43 18             	mov    0x18(%ebx),%eax
8010335a:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
8010335e:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103362:	8b 43 18             	mov    0x18(%ebx),%eax
80103365:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103369:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010336d:	8b 43 18             	mov    0x18(%ebx),%eax
80103370:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103377:	8b 43 18             	mov    0x18(%ebx),%eax
8010337a:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103381:	8b 43 18             	mov    0x18(%ebx),%eax
80103384:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
8010338b:	8d 43 6c             	lea    0x6c(%ebx),%eax
8010338e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80103395:	00 
80103396:	c7 44 24 04 fd 6f 10 	movl   $0x80106ffd,0x4(%esp)
8010339d:	80 
8010339e:	89 04 24             	mov    %eax,(%esp)
801033a1:	e8 c1 0c 00 00       	call   80104067 <safestrcpy>
  p->cwd = namei("/");
801033a6:	c7 04 24 06 70 10 80 	movl   $0x80107006,(%esp)
801033ad:	e8 d0 e8 ff ff       	call   80101c82 <namei>
801033b2:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
801033b5:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801033bc:	e8 82 0a 00 00       	call   80103e43 <acquire>
  p->state = RUNNABLE;
801033c1:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
801033c8:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801033cf:	e8 d0 0a 00 00       	call   80103ea4 <release>
}
801033d4:	83 c4 14             	add    $0x14,%esp
801033d7:	5b                   	pop    %ebx
801033d8:	5d                   	pop    %ebp
801033d9:	c3                   	ret    

801033da <growproc>:
{
801033da:	55                   	push   %ebp
801033db:	89 e5                	mov    %esp,%ebp
801033dd:	56                   	push   %esi
801033de:	53                   	push   %ebx
801033df:	83 ec 10             	sub    $0x10,%esp
801033e2:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
801033e5:	e8 d3 fe ff ff       	call   801032bd <myproc>
801033ea:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
801033ec:	8b 00                	mov    (%eax),%eax
  if(n > 0){
801033ee:	85 f6                	test   %esi,%esi
801033f0:	7e 04                	jle    801033f6 <growproc+0x1c>
      sz += n; //COMMENTED OUT THIS BC IT CAN STILL SET SZ BUT SHLDNT CREATE PAGE TABLE ENTRIES
801033f2:	01 f0                	add    %esi,%eax
801033f4:	eb 1d                	jmp    80103413 <growproc+0x39>
  } else if(n < 0){
801033f6:	85 f6                	test   %esi,%esi
801033f8:	79 19                	jns    80103413 <growproc+0x39>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801033fa:	01 c6                	add    %eax,%esi
801033fc:	89 74 24 08          	mov    %esi,0x8(%esp)
80103400:	89 44 24 04          	mov    %eax,0x4(%esp)
80103404:	8b 43 04             	mov    0x4(%ebx),%eax
80103407:	89 04 24             	mov    %eax,(%esp)
8010340a:	e8 a0 30 00 00       	call   801064af <deallocuvm>
8010340f:	85 c0                	test   %eax,%eax
80103411:	74 11                	je     80103424 <growproc+0x4a>
  curproc->sz = sz;
80103413:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103415:	89 1c 24             	mov    %ebx,(%esp)
80103418:	e8 2e 2e 00 00       	call   8010624b <switchuvm>
  return 0;
8010341d:	b8 00 00 00 00       	mov    $0x0,%eax
80103422:	eb 05                	jmp    80103429 <growproc+0x4f>
      return -1;
80103424:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103429:	83 c4 10             	add    $0x10,%esp
8010342c:	5b                   	pop    %ebx
8010342d:	5e                   	pop    %esi
8010342e:	5d                   	pop    %ebp
8010342f:	c3                   	ret    

80103430 <fork>:
{
80103430:	55                   	push   %ebp
80103431:	89 e5                	mov    %esp,%ebp
80103433:	57                   	push   %edi
80103434:	56                   	push   %esi
80103435:	53                   	push   %ebx
80103436:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
80103439:	e8 7f fe ff ff       	call   801032bd <myproc>
8010343e:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
80103440:	e8 ec fc ff ff       	call   80103131 <allocproc>
80103445:	89 c7                	mov    %eax,%edi
80103447:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010344a:	85 c0                	test   %eax,%eax
8010344c:	0f 84 d8 00 00 00    	je     8010352a <fork+0xfa>
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103452:	8b 03                	mov    (%ebx),%eax
80103454:	89 44 24 04          	mov    %eax,0x4(%esp)
80103458:	8b 43 04             	mov    0x4(%ebx),%eax
8010345b:	89 04 24             	mov    %eax,(%esp)
8010345e:	e8 58 33 00 00       	call   801067bb <copyuvm>
80103463:	89 47 04             	mov    %eax,0x4(%edi)
80103466:	85 c0                	test   %eax,%eax
80103468:	75 26                	jne    80103490 <fork+0x60>
    kfree(np->kstack);
8010346a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010346d:	8b 47 08             	mov    0x8(%edi),%eax
80103470:	89 04 24             	mov    %eax,(%esp)
80103473:	e8 a4 eb ff ff       	call   8010201c <kfree>
    np->kstack = 0;
80103478:	c7 47 08 00 00 00 00 	movl   $0x0,0x8(%edi)
    np->state = UNUSED;
8010347f:	c7 47 0c 00 00 00 00 	movl   $0x0,0xc(%edi)
    return -1;
80103486:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010348b:	e9 9f 00 00 00       	jmp    8010352f <fork+0xff>
  np->sz = curproc->sz;
80103490:	8b 03                	mov    (%ebx),%eax
80103492:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103495:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
80103497:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
8010349a:	89 c8                	mov    %ecx,%eax
8010349c:	8b 79 18             	mov    0x18(%ecx),%edi
8010349f:	8b 73 18             	mov    0x18(%ebx),%esi
801034a2:	b9 13 00 00 00       	mov    $0x13,%ecx
801034a7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
801034a9:	8b 40 18             	mov    0x18(%eax),%eax
801034ac:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
801034b3:	be 00 00 00 00       	mov    $0x0,%esi
801034b8:	eb 1a                	jmp    801034d4 <fork+0xa4>
    if(curproc->ofile[i])
801034ba:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
801034be:	85 c0                	test   %eax,%eax
801034c0:	74 0f                	je     801034d1 <fork+0xa1>
      np->ofile[i] = filedup(curproc->ofile[i]);
801034c2:	89 04 24             	mov    %eax,(%esp)
801034c5:	e8 0b d8 ff ff       	call   80100cd5 <filedup>
801034ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801034cd:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
  for(i = 0; i < NOFILE; i++)
801034d1:	83 c6 01             	add    $0x1,%esi
801034d4:	83 fe 0f             	cmp    $0xf,%esi
801034d7:	7e e1                	jle    801034ba <fork+0x8a>
  np->cwd = idup(curproc->cwd);
801034d9:	8b 43 68             	mov    0x68(%ebx),%eax
801034dc:	89 04 24             	mov    %eax,(%esp)
801034df:	e8 ef e0 ff ff       	call   801015d3 <idup>
801034e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801034e7:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801034ea:	83 c3 6c             	add    $0x6c,%ebx
801034ed:	8d 47 6c             	lea    0x6c(%edi),%eax
801034f0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801034f7:	00 
801034f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801034fc:	89 04 24             	mov    %eax,(%esp)
801034ff:	e8 63 0b 00 00       	call   80104067 <safestrcpy>
  pid = np->pid;
80103504:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
80103507:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010350e:	e8 30 09 00 00       	call   80103e43 <acquire>
  np->state = RUNNABLE;
80103513:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
8010351a:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103521:	e8 7e 09 00 00       	call   80103ea4 <release>
  return pid;
80103526:	89 d8                	mov    %ebx,%eax
80103528:	eb 05                	jmp    8010352f <fork+0xff>
    return -1;
8010352a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010352f:	83 c4 1c             	add    $0x1c,%esp
80103532:	5b                   	pop    %ebx
80103533:	5e                   	pop    %esi
80103534:	5f                   	pop    %edi
80103535:	5d                   	pop    %ebp
80103536:	c3                   	ret    

80103537 <scheduler>:
{
80103537:	55                   	push   %ebp
80103538:	89 e5                	mov    %esp,%ebp
8010353a:	57                   	push   %edi
8010353b:	56                   	push   %esi
8010353c:	53                   	push   %ebx
8010353d:	83 ec 1c             	sub    $0x1c,%esp
  struct cpu *c = mycpu();
80103540:	e8 03 fd ff ff       	call   80103248 <mycpu>
80103545:	89 c6                	mov    %eax,%esi
  c->proc = 0;
80103547:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010354e:	00 00 00 
      swtch(&(c->scheduler), p->context);
80103551:	8d 78 04             	lea    0x4(%eax),%edi
  asm volatile("sti");
80103554:	fb                   	sti    
    acquire(&ptable.lock);
80103555:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010355c:	e8 e2 08 00 00       	call   80103e43 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103561:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
80103566:	eb 3c                	jmp    801035a4 <scheduler+0x6d>
      if(p->state != RUNNABLE)
80103568:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
8010356c:	75 33                	jne    801035a1 <scheduler+0x6a>
      c->proc = p;
8010356e:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
80103574:	89 1c 24             	mov    %ebx,(%esp)
80103577:	e8 cf 2c 00 00       	call   8010624b <switchuvm>
      p->state = RUNNING;
8010357c:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
80103583:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103586:	89 44 24 04          	mov    %eax,0x4(%esp)
8010358a:	89 3c 24             	mov    %edi,(%esp)
8010358d:	e8 28 0b 00 00       	call   801040ba <swtch>
      switchkvm();
80103592:	e8 8d 2c 00 00       	call   80106224 <switchkvm>
      c->proc = 0;
80103597:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
8010359e:	00 00 00 
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801035a1:	83 c3 7c             	add    $0x7c,%ebx
801035a4:	81 fb 54 4c 11 80    	cmp    $0x80114c54,%ebx
801035aa:	72 bc                	jb     80103568 <scheduler+0x31>
    release(&ptable.lock);
801035ac:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801035b3:	e8 ec 08 00 00       	call   80103ea4 <release>
  }
801035b8:	eb 9a                	jmp    80103554 <scheduler+0x1d>

801035ba <sched>:
{
801035ba:	55                   	push   %ebp
801035bb:	89 e5                	mov    %esp,%ebp
801035bd:	56                   	push   %esi
801035be:	53                   	push   %ebx
801035bf:	83 ec 10             	sub    $0x10,%esp
  struct proc *p = myproc();
801035c2:	e8 f6 fc ff ff       	call   801032bd <myproc>
801035c7:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
801035c9:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801035d0:	e8 2e 08 00 00       	call   80103e03 <holding>
801035d5:	85 c0                	test   %eax,%eax
801035d7:	75 0c                	jne    801035e5 <sched+0x2b>
    panic("sched ptable.lock");
801035d9:	c7 04 24 08 70 10 80 	movl   $0x80107008,(%esp)
801035e0:	e8 40 cd ff ff       	call   80100325 <panic>
  if(mycpu()->ncli != 1)
801035e5:	e8 5e fc ff ff       	call   80103248 <mycpu>
801035ea:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
801035f1:	74 0c                	je     801035ff <sched+0x45>
    panic("sched locks");
801035f3:	c7 04 24 1a 70 10 80 	movl   $0x8010701a,(%esp)
801035fa:	e8 26 cd ff ff       	call   80100325 <panic>
  if(p->state == RUNNING)
801035ff:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103603:	75 0c                	jne    80103611 <sched+0x57>
    panic("sched running");
80103605:	c7 04 24 26 70 10 80 	movl   $0x80107026,(%esp)
8010360c:	e8 14 cd ff ff       	call   80100325 <panic>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103611:	9c                   	pushf  
80103612:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103613:	f6 c4 02             	test   $0x2,%ah
80103616:	74 0c                	je     80103624 <sched+0x6a>
    panic("sched interruptible");
80103618:	c7 04 24 34 70 10 80 	movl   $0x80107034,(%esp)
8010361f:	e8 01 cd ff ff       	call   80100325 <panic>
  intena = mycpu()->intena;
80103624:	e8 1f fc ff ff       	call   80103248 <mycpu>
80103629:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
8010362f:	e8 14 fc ff ff       	call   80103248 <mycpu>
80103634:	8b 40 04             	mov    0x4(%eax),%eax
80103637:	89 44 24 04          	mov    %eax,0x4(%esp)
8010363b:	83 c3 1c             	add    $0x1c,%ebx
8010363e:	89 1c 24             	mov    %ebx,(%esp)
80103641:	e8 74 0a 00 00       	call   801040ba <swtch>
  mycpu()->intena = intena;
80103646:	e8 fd fb ff ff       	call   80103248 <mycpu>
8010364b:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103651:	83 c4 10             	add    $0x10,%esp
80103654:	5b                   	pop    %ebx
80103655:	5e                   	pop    %esi
80103656:	5d                   	pop    %ebp
80103657:	c3                   	ret    

80103658 <exit>:
{
80103658:	55                   	push   %ebp
80103659:	89 e5                	mov    %esp,%ebp
8010365b:	56                   	push   %esi
8010365c:	53                   	push   %ebx
8010365d:	83 ec 10             	sub    $0x10,%esp
  struct proc *curproc = myproc();
80103660:	e8 58 fc ff ff       	call   801032bd <myproc>
80103665:	89 c6                	mov    %eax,%esi
  if(curproc == initproc)
80103667:	3b 05 b8 a5 10 80    	cmp    0x8010a5b8,%eax
8010366d:	75 29                	jne    80103698 <exit+0x40>
    panic("init exiting");
8010366f:	c7 04 24 48 70 10 80 	movl   $0x80107048,(%esp)
80103676:	e8 aa cc ff ff       	call   80100325 <panic>
    if(curproc->ofile[fd]){
8010367b:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
8010367f:	85 c0                	test   %eax,%eax
80103681:	74 10                	je     80103693 <exit+0x3b>
      fileclose(curproc->ofile[fd]);
80103683:	89 04 24             	mov    %eax,(%esp)
80103686:	e8 8d d6 ff ff       	call   80100d18 <fileclose>
      curproc->ofile[fd] = 0;
8010368b:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
80103692:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103693:	83 c3 01             	add    $0x1,%ebx
80103696:	eb 05                	jmp    8010369d <exit+0x45>
80103698:	bb 00 00 00 00       	mov    $0x0,%ebx
8010369d:	83 fb 0f             	cmp    $0xf,%ebx
801036a0:	7e d9                	jle    8010367b <exit+0x23>
  begin_op();
801036a2:	e8 ac f1 ff ff       	call   80102853 <begin_op>
  iput(curproc->cwd);
801036a7:	8b 46 68             	mov    0x68(%esi),%eax
801036aa:	89 04 24             	mov    %eax,(%esp)
801036ad:	e8 55 e0 ff ff       	call   80101707 <iput>
  end_op();
801036b2:	e8 0f f2 ff ff       	call   801028c6 <end_op>
  curproc->cwd = 0;
801036b7:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
801036be:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801036c5:	e8 79 07 00 00       	call   80103e43 <acquire>
  wakeup1(curproc->parent);
801036ca:	8b 46 14             	mov    0x14(%esi),%eax
801036cd:	e8 36 fa ff ff       	call   80103108 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801036d2:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
801036d7:	eb 1b                	jmp    801036f4 <exit+0x9c>
    if(p->parent == curproc){
801036d9:	39 73 14             	cmp    %esi,0x14(%ebx)
801036dc:	75 13                	jne    801036f1 <exit+0x99>
      p->parent = initproc;
801036de:	a1 b8 a5 10 80       	mov    0x8010a5b8,%eax
801036e3:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
801036e6:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801036ea:	75 05                	jne    801036f1 <exit+0x99>
        wakeup1(initproc);
801036ec:	e8 17 fa ff ff       	call   80103108 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801036f1:	83 c3 7c             	add    $0x7c,%ebx
801036f4:	81 fb 54 4c 11 80    	cmp    $0x80114c54,%ebx
801036fa:	72 dd                	jb     801036d9 <exit+0x81>
  curproc->state = ZOMBIE;
801036fc:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
80103703:	e8 b2 fe ff ff       	call   801035ba <sched>
  panic("zombie exit");
80103708:	c7 04 24 55 70 10 80 	movl   $0x80107055,(%esp)
8010370f:	e8 11 cc ff ff       	call   80100325 <panic>

80103714 <yield>:
{
80103714:	55                   	push   %ebp
80103715:	89 e5                	mov    %esp,%ebp
80103717:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010371a:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103721:	e8 1d 07 00 00       	call   80103e43 <acquire>
  myproc()->state = RUNNABLE;
80103726:	e8 92 fb ff ff       	call   801032bd <myproc>
8010372b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80103732:	e8 83 fe ff ff       	call   801035ba <sched>
  release(&ptable.lock);
80103737:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010373e:	e8 61 07 00 00       	call   80103ea4 <release>
}
80103743:	c9                   	leave  
80103744:	c3                   	ret    

80103745 <sleep>:
{
80103745:	55                   	push   %ebp
80103746:	89 e5                	mov    %esp,%ebp
80103748:	56                   	push   %esi
80103749:	53                   	push   %ebx
8010374a:	83 ec 10             	sub    $0x10,%esp
8010374d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
80103750:	e8 68 fb ff ff       	call   801032bd <myproc>
80103755:	89 c6                	mov    %eax,%esi
  if(p == 0)
80103757:	85 c0                	test   %eax,%eax
80103759:	75 0c                	jne    80103767 <sleep+0x22>
    panic("sleep");
8010375b:	c7 04 24 61 70 10 80 	movl   $0x80107061,(%esp)
80103762:	e8 be cb ff ff       	call   80100325 <panic>
  if(lk == 0)
80103767:	85 db                	test   %ebx,%ebx
80103769:	75 0c                	jne    80103777 <sleep+0x32>
    panic("sleep without lk");
8010376b:	c7 04 24 67 70 10 80 	movl   $0x80107067,(%esp)
80103772:	e8 ae cb ff ff       	call   80100325 <panic>
  if(lk != &ptable.lock){  //DOC: sleeplock0
80103777:	81 fb 20 2d 11 80    	cmp    $0x80112d20,%ebx
8010377d:	74 14                	je     80103793 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
8010377f:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103786:	e8 b8 06 00 00       	call   80103e43 <acquire>
    release(lk);
8010378b:	89 1c 24             	mov    %ebx,(%esp)
8010378e:	e8 11 07 00 00       	call   80103ea4 <release>
  p->chan = chan;
80103793:	8b 45 08             	mov    0x8(%ebp),%eax
80103796:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
80103799:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
801037a0:	e8 15 fe ff ff       	call   801035ba <sched>
  p->chan = 0;
801037a5:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
801037ac:	81 fb 20 2d 11 80    	cmp    $0x80112d20,%ebx
801037b2:	74 14                	je     801037c8 <sleep+0x83>
    release(&ptable.lock);
801037b4:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801037bb:	e8 e4 06 00 00       	call   80103ea4 <release>
    acquire(lk);
801037c0:	89 1c 24             	mov    %ebx,(%esp)
801037c3:	e8 7b 06 00 00       	call   80103e43 <acquire>
}
801037c8:	83 c4 10             	add    $0x10,%esp
801037cb:	5b                   	pop    %ebx
801037cc:	5e                   	pop    %esi
801037cd:	5d                   	pop    %ebp
801037ce:	c3                   	ret    

801037cf <wait>:
{
801037cf:	55                   	push   %ebp
801037d0:	89 e5                	mov    %esp,%ebp
801037d2:	56                   	push   %esi
801037d3:	53                   	push   %ebx
801037d4:	83 ec 10             	sub    $0x10,%esp
  struct proc *curproc = myproc();
801037d7:	e8 e1 fa ff ff       	call   801032bd <myproc>
801037dc:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
801037de:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801037e5:	e8 59 06 00 00       	call   80103e43 <acquire>
    havekids = 0;
801037ea:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801037ef:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
801037f4:	eb 63                	jmp    80103859 <wait+0x8a>
      if(p->parent != curproc)
801037f6:	39 73 14             	cmp    %esi,0x14(%ebx)
801037f9:	75 5b                	jne    80103856 <wait+0x87>
      if(p->state == ZOMBIE){
801037fb:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801037ff:	75 50                	jne    80103851 <wait+0x82>
        pid = p->pid;
80103801:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80103804:	8b 43 08             	mov    0x8(%ebx),%eax
80103807:	89 04 24             	mov    %eax,(%esp)
8010380a:	e8 0d e8 ff ff       	call   8010201c <kfree>
        p->kstack = 0;
8010380f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80103816:	8b 43 04             	mov    0x4(%ebx),%eax
80103819:	89 04 24             	mov    %eax,(%esp)
8010381c:	e8 49 2e 00 00       	call   8010666a <freevm>
        p->pid = 0;
80103821:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80103828:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
8010382f:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80103833:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
8010383a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
80103841:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103848:	e8 57 06 00 00       	call   80103ea4 <release>
        return pid;
8010384d:	89 f0                	mov    %esi,%eax
8010384f:	eb 42                	jmp    80103893 <wait+0xc4>
      havekids = 1;
80103851:	b8 01 00 00 00       	mov    $0x1,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103856:	83 c3 7c             	add    $0x7c,%ebx
80103859:	81 fb 54 4c 11 80    	cmp    $0x80114c54,%ebx
8010385f:	72 95                	jb     801037f6 <wait+0x27>
    if(!havekids || curproc->killed){
80103861:	85 c0                	test   %eax,%eax
80103863:	74 06                	je     8010386b <wait+0x9c>
80103865:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
80103869:	74 13                	je     8010387e <wait+0xaf>
      release(&ptable.lock);
8010386b:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103872:	e8 2d 06 00 00       	call   80103ea4 <release>
      return -1;
80103877:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010387c:	eb 15                	jmp    80103893 <wait+0xc4>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
8010387e:	c7 44 24 04 20 2d 11 	movl   $0x80112d20,0x4(%esp)
80103885:	80 
80103886:	89 34 24             	mov    %esi,(%esp)
80103889:	e8 b7 fe ff ff       	call   80103745 <sleep>
  }
8010388e:	e9 57 ff ff ff       	jmp    801037ea <wait+0x1b>
}
80103893:	83 c4 10             	add    $0x10,%esp
80103896:	5b                   	pop    %ebx
80103897:	5e                   	pop    %esi
80103898:	5d                   	pop    %ebp
80103899:	c3                   	ret    

8010389a <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010389a:	55                   	push   %ebp
8010389b:	89 e5                	mov    %esp,%ebp
8010389d:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
801038a0:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801038a7:	e8 97 05 00 00       	call   80103e43 <acquire>
  wakeup1(chan);
801038ac:	8b 45 08             	mov    0x8(%ebp),%eax
801038af:	e8 54 f8 ff ff       	call   80103108 <wakeup1>
  release(&ptable.lock);
801038b4:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801038bb:	e8 e4 05 00 00       	call   80103ea4 <release>
}
801038c0:	c9                   	leave  
801038c1:	c3                   	ret    

801038c2 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801038c2:	55                   	push   %ebp
801038c3:	89 e5                	mov    %esp,%ebp
801038c5:	53                   	push   %ebx
801038c6:	83 ec 14             	sub    $0x14,%esp
801038c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801038cc:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801038d3:	e8 6b 05 00 00       	call   80103e43 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038d8:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
801038dd:	eb 2f                	jmp    8010390e <kill+0x4c>
    if(p->pid == pid){
801038df:	39 58 10             	cmp    %ebx,0x10(%eax)
801038e2:	75 27                	jne    8010390b <kill+0x49>
      p->killed = 1;
801038e4:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801038eb:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
801038ef:	75 07                	jne    801038f8 <kill+0x36>
        p->state = RUNNABLE;
801038f1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801038f8:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801038ff:	e8 a0 05 00 00       	call   80103ea4 <release>
      return 0;
80103904:	b8 00 00 00 00       	mov    $0x0,%eax
80103909:	eb 1b                	jmp    80103926 <kill+0x64>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010390b:	83 c0 7c             	add    $0x7c,%eax
8010390e:	3d 54 4c 11 80       	cmp    $0x80114c54,%eax
80103913:	72 ca                	jb     801038df <kill+0x1d>
    }
  }
  release(&ptable.lock);
80103915:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010391c:	e8 83 05 00 00       	call   80103ea4 <release>
  return -1;
80103921:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103926:	83 c4 14             	add    $0x14,%esp
80103929:	5b                   	pop    %ebx
8010392a:	5d                   	pop    %ebp
8010392b:	c3                   	ret    

8010392c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010392c:	55                   	push   %ebp
8010392d:	89 e5                	mov    %esp,%ebp
8010392f:	57                   	push   %edi
80103930:	56                   	push   %esi
80103931:	53                   	push   %ebx
80103932:	83 ec 4c             	sub    $0x4c,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103935:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010393a:	8d 75 c0             	lea    -0x40(%ebp),%esi
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010393d:	e9 96 00 00 00       	jmp    801039d8 <procdump+0xac>
    if(p->state == UNUSED)
80103942:	8b 43 0c             	mov    0xc(%ebx),%eax
80103945:	85 c0                	test   %eax,%eax
80103947:	0f 84 88 00 00 00    	je     801039d5 <procdump+0xa9>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010394d:	83 f8 05             	cmp    $0x5,%eax
80103950:	77 12                	ja     80103964 <procdump+0x38>
80103952:	8b 04 85 18 71 10 80 	mov    -0x7fef8ee8(,%eax,4),%eax
80103959:	85 c0                	test   %eax,%eax
8010395b:	75 0c                	jne    80103969 <procdump+0x3d>
      state = "???";
8010395d:	b8 78 70 10 80       	mov    $0x80107078,%eax
80103962:	eb 05                	jmp    80103969 <procdump+0x3d>
80103964:	b8 78 70 10 80       	mov    $0x80107078,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
80103969:	8d 53 6c             	lea    0x6c(%ebx),%edx
8010396c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80103970:	89 44 24 08          	mov    %eax,0x8(%esp)
80103974:	8b 43 10             	mov    0x10(%ebx),%eax
80103977:	89 44 24 04          	mov    %eax,0x4(%esp)
8010397b:	c7 04 24 7c 70 10 80 	movl   $0x8010707c,(%esp)
80103982:	e8 40 cc ff ff       	call   801005c7 <cprintf>
    if(p->state == SLEEPING){
80103987:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
8010398b:	75 3c                	jne    801039c9 <procdump+0x9d>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010398d:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103990:	8b 40 0c             	mov    0xc(%eax),%eax
80103993:	83 c0 08             	add    $0x8,%eax
80103996:	89 74 24 04          	mov    %esi,0x4(%esp)
8010399a:	89 04 24             	mov    %eax,(%esp)
8010399d:	e8 84 03 00 00       	call   80103d26 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801039a2:	bf 00 00 00 00       	mov    $0x0,%edi
801039a7:	eb 13                	jmp    801039bc <procdump+0x90>
        cprintf(" %p", pc[i]);
801039a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801039ad:	c7 04 24 01 6a 10 80 	movl   $0x80106a01,(%esp)
801039b4:	e8 0e cc ff ff       	call   801005c7 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
801039b9:	83 c7 01             	add    $0x1,%edi
801039bc:	83 ff 09             	cmp    $0x9,%edi
801039bf:	7f 08                	jg     801039c9 <procdump+0x9d>
801039c1:	8b 44 bd c0          	mov    -0x40(%ebp,%edi,4),%eax
801039c5:	85 c0                	test   %eax,%eax
801039c7:	75 e0                	jne    801039a9 <procdump+0x7d>
    }
    cprintf("\n");
801039c9:	c7 04 24 b3 70 10 80 	movl   $0x801070b3,(%esp)
801039d0:	e8 f2 cb ff ff       	call   801005c7 <cprintf>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039d5:	83 c3 7c             	add    $0x7c,%ebx
801039d8:	81 fb 54 4c 11 80    	cmp    $0x80114c54,%ebx
801039de:	0f 82 5e ff ff ff    	jb     80103942 <procdump+0x16>
  }
}
801039e4:	83 c4 4c             	add    $0x4c,%esp
801039e7:	5b                   	pop    %ebx
801039e8:	5e                   	pop    %esi
801039e9:	5f                   	pop    %edi
801039ea:	5d                   	pop    %ebp
801039eb:	c3                   	ret    

801039ec <getpagetableentry>:

//do not use myproc(), p->pgdir gives you the page dir for a process
//walkpgdir() takes a pgdir and a VA
//return the page table entry for the VA
int 
getpagetableentry(int pid, int address){
801039ec:	55                   	push   %ebp
801039ed:	89 e5                	mov    %esp,%ebp
801039ef:	56                   	push   %esi
801039f0:	53                   	push   %ebx
801039f1:	83 ec 10             	sub    $0x10,%esp
801039f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
801039f7:	8b 75 0c             	mov    0xc(%ebp),%esi
  //have to get pid  
  struct proc *curproc;
  //curproc->pid = -1;
  acquire(&ptable.lock);
801039fa:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103a01:	e8 3d 04 00 00       	call   80103e43 <acquire>
  for(curproc = ptable.proc; curproc < &ptable.proc[NPROC]; curproc++){ 
80103a06:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
80103a0b:	eb 49                	jmp    80103a56 <getpagetableentry+0x6a>
    if(curproc->pid == pid){
80103a0d:	39 58 10             	cmp    %ebx,0x10(%eax)
80103a10:	75 41                	jne    80103a53 <getpagetableentry+0x67>
      pte_t* paget;
      pte_t* pgdir = curproc->pgdir;
80103a12:	8b 58 04             	mov    0x4(%eax),%ebx
     //from vm.c : walkpgdir(pde_t *pgdir, const void *va, int alloc)
    if(walkpgdir(pgdir, (const void *)(address), 0) == 0){
80103a15:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80103a1c:	00 
80103a1d:	89 74 24 04          	mov    %esi,0x4(%esp)
80103a21:	89 1c 24             	mov    %ebx,(%esp)
80103a24:	e8 cf 26 00 00       	call   801060f8 <walkpgdir>
80103a29:	85 c0                	test   %eax,%eax
80103a2b:	74 37                	je     80103a64 <getpagetableentry+0x78>
    return 0;
  }
  else{
     paget =  walkpgdir(pgdir, (const void *)(address), 0);
80103a2d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80103a34:	00 
80103a35:	89 74 24 04          	mov    %esi,0x4(%esp)
80103a39:	89 1c 24             	mov    %ebx,(%esp)
80103a3c:	e8 b7 26 00 00       	call   801060f8 <walkpgdir>
80103a41:	89 c3                	mov    %eax,%ebx
  }
  release(&ptable.lock);
80103a43:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103a4a:	e8 55 04 00 00       	call   80103ea4 <release>
  return *paget;  
80103a4f:	8b 03                	mov    (%ebx),%eax
80103a51:	eb 16                	jmp    80103a69 <getpagetableentry+0x7d>
  for(curproc = ptable.proc; curproc < &ptable.proc[NPROC]; curproc++){ 
80103a53:	83 c0 7c             	add    $0x7c,%eax
80103a56:	3d 54 4c 11 80       	cmp    $0x80114c54,%eax
80103a5b:	72 b0                	jb     80103a0d <getpagetableentry+0x21>

    }
  }
    return 0;
80103a5d:	b8 00 00 00 00       	mov    $0x0,%eax
80103a62:	eb 05                	jmp    80103a69 <getpagetableentry+0x7d>
    return 0;
80103a64:	b8 00 00 00 00       	mov    $0x0,%eax
     
    }
80103a69:	83 c4 10             	add    $0x10,%esp
80103a6c:	5b                   	pop    %ebx
80103a6d:	5e                   	pop    %esi
80103a6e:	5d                   	pop    %ebp
80103a6f:	c3                   	ret    

80103a70 <isphysicalpagefree>:
  
  
int
isphysicalpagefree(int ppn){
80103a70:	55                   	push   %ebp
80103a71:	89 e5                	mov    %esp,%ebp
80103a73:	56                   	push   %esi
80103a74:	53                   	push   %ebx
80103a75:	83 ec 10             	sub    $0x10,%esp
80103a78:	8b 75 08             	mov    0x8(%ebp),%esi
   // 3. Items on the linked list are kernel virtual addresses, as you might get by using P2V on a physical byte address.
   // Note that the argument to isphysicalpagefree() is a physical page number rather than a physical byte address

  
  //**the base/layout of this part is directly from kalloc function!!
  struct run *r = kmem.freelist;
80103a7b:	8b 1d 18 2d 11 80    	mov    0x80112d18,%ebx
  int physical_byte_address;
  int current_ppn_converted;
  if(kmem.use_lock)
80103a81:	83 3d 14 2d 11 80 00 	cmpl   $0x0,0x80112d14
80103a88:	74 4d                	je     80103ad7 <isphysicalpagefree+0x67>
    acquire(&kmem.lock);
80103a8a:	c7 04 24 e0 2c 11 80 	movl   $0x80112ce0,(%esp)
80103a91:	e8 ad 03 00 00       	call   80103e43 <acquire>
80103a96:	eb 3f                	jmp    80103ad7 <isphysicalpagefree+0x67>
    if (a < (void*) KERNBASE)
80103a98:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80103a9e:	77 0c                	ja     80103aac <isphysicalpagefree+0x3c>
        panic("V2P on address < KERNBASE "
80103aa0:	c7 04 24 28 6c 10 80 	movl   $0x80106c28,(%esp)
80103aa7:	e8 79 c8 ff ff       	call   80100325 <panic>
    return (uint)a - KERNBASE;
80103aac:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
  //r = ;
  while(r){
      physical_byte_address = V2P((r));
      current_ppn_converted = physical_byte_address >> 12; //12 is # of offset bits
80103ab2:	c1 f8 0c             	sar    $0xc,%eax
      if(current_ppn_converted == ppn){
80103ab5:	39 f0                	cmp    %esi,%eax
80103ab7:	75 1c                	jne    80103ad5 <isphysicalpagefree+0x65>
        if(kmem.use_lock){
80103ab9:	83 3d 14 2d 11 80 00 	cmpl   $0x0,0x80112d14
80103ac0:	74 35                	je     80103af7 <isphysicalpagefree+0x87>
      release(&kmem.lock);
80103ac2:	c7 04 24 e0 2c 11 80 	movl   $0x80112ce0,(%esp)
80103ac9:	e8 d6 03 00 00       	call   80103ea4 <release>
        }
      return 1; //1 is true value
80103ace:	b8 01 00 00 00       	mov    $0x1,%eax
80103ad3:	eb 27                	jmp    80103afc <isphysicalpagefree+0x8c>

      }
       r = r->next;
80103ad5:	8b 1b                	mov    (%ebx),%ebx
  while(r){
80103ad7:	85 db                	test   %ebx,%ebx
80103ad9:	75 bd                	jne    80103a98 <isphysicalpagefree+0x28>

  }
  if(kmem.use_lock)
80103adb:	a1 14 2d 11 80       	mov    0x80112d14,%eax
80103ae0:	85 c0                	test   %eax,%eax
80103ae2:	74 18                	je     80103afc <isphysicalpagefree+0x8c>
    release(&kmem.lock);
80103ae4:	c7 04 24 e0 2c 11 80 	movl   $0x80112ce0,(%esp)
80103aeb:	e8 b4 03 00 00       	call   80103ea4 <release>
  return 0;
80103af0:	b8 00 00 00 00       	mov    $0x0,%eax
80103af5:	eb 05                	jmp    80103afc <isphysicalpagefree+0x8c>
      return 1; //1 is true value
80103af7:	b8 01 00 00 00       	mov    $0x1,%eax
  
}
80103afc:	83 c4 10             	add    $0x10,%esp
80103aff:	5b                   	pop    %ebx
80103b00:	5e                   	pop    %esi
80103b01:	5d                   	pop    %ebp
80103b02:	c3                   	ret    

80103b03 <dumppagetable>:

// work on dumppagetable function 
// outputs page table process w pid
int
dumppagetable(int pid){
80103b03:	55                   	push   %ebp
80103b04:	89 e5                	mov    %esp,%ebp
80103b06:	56                   	push   %esi
80103b07:	53                   	push   %ebx
80103b08:	83 ec 20             	sub    $0x20,%esp
80103b0b:	8b 75 08             	mov    0x8(%ebp),%esi

  struct proc *p;
  acquire(&ptable.lock);
80103b0e:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103b15:	e8 29 03 00 00       	call   80103e43 <acquire>

  // need to loop thru through the proc in ptable - find proc
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80103b1a:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
80103b1f:	eb 08                	jmp    80103b29 <dumppagetable+0x26>
    if (p->pid == pid) {
80103b21:	39 73 10             	cmp    %esi,0x10(%ebx)
80103b24:	74 0b                	je     80103b31 <dumppagetable+0x2e>
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80103b26:	83 c3 7c             	add    $0x7c,%ebx
80103b29:	81 fb 54 4c 11 80    	cmp    $0x80114c54,%ebx
80103b2f:	72 f0                	jb     80103b21 <dumppagetable+0x1e>
      break; 
    }
  }

  release(&ptable.lock);
80103b31:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103b38:	e8 67 03 00 00       	call   80103ea4 <release>

// if not found - return error
  if (!p) {
80103b3d:	85 db                	test   %ebx,%ebx
80103b3f:	0f 84 b5 00 00 00    	je     80103bfa <dumppagetable+0xf7>
    return -1;
  }

  cprintf("START PAGE TABLE\n");
80103b45:	c7 04 24 8b 70 10 80 	movl   $0x8010708b,(%esp)
80103b4c:	e8 76 ca ff ff       	call   801005c7 <cprintf>

// looping thru the virtual addresses in proc space & getting the table entry
 for (int va = 0; va < p->sz; va += PGSIZE) {
80103b51:	be 00 00 00 00       	mov    $0x0,%esi
80103b56:	e9 84 00 00 00       	jmp    80103bdf <dumppagetable+0xdc>
  //get 12 bits and shift right
    pte_t *pte = walkpgdir(p->pgdir, (void*)va, 0);
80103b5b:	8b 43 04             	mov    0x4(%ebx),%eax
80103b5e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80103b65:	00 
80103b66:	89 74 24 04          	mov    %esi,0x4(%esp)
80103b6a:	89 04 24             	mov    %eax,(%esp)
80103b6d:	e8 86 25 00 00       	call   801060f8 <walkpgdir>

 if (pte) {
80103b72:	85 c0                	test   %eax,%eax
80103b74:	74 53                	je     80103bc9 <dumppagetable+0xc6>
     cprintf("%x P %s %s %x\n", (va / PGSIZE), (*pte & PTE_U) ? "U" : "-", (*pte & PTE_W) ? "W" : "-", PTE_ADDR(*pte) >> PTXSHIFT);
80103b76:	8b 00                	mov    (%eax),%eax
80103b78:	89 c2                	mov    %eax,%edx
80103b7a:	c1 ea 0c             	shr    $0xc,%edx
80103b7d:	a8 02                	test   $0x2,%al
80103b7f:	74 07                	je     80103b88 <dumppagetable+0x85>
80103b81:	b9 85 70 10 80       	mov    $0x80107085,%ecx
80103b86:	eb 05                	jmp    80103b8d <dumppagetable+0x8a>
80103b88:	b9 87 70 10 80       	mov    $0x80107087,%ecx
80103b8d:	a8 04                	test   $0x4,%al
80103b8f:	74 07                	je     80103b98 <dumppagetable+0x95>
80103b91:	b8 89 70 10 80       	mov    $0x80107089,%eax
80103b96:	eb 05                	jmp    80103b9d <dumppagetable+0x9a>
80103b98:	b8 87 70 10 80       	mov    $0x80107087,%eax
80103b9d:	89 54 24 10          	mov    %edx,0x10(%esp)
80103ba1:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80103ba5:	89 44 24 08          	mov    %eax,0x8(%esp)
80103ba9:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
80103baf:	85 f6                	test   %esi,%esi
80103bb1:	0f 49 c6             	cmovns %esi,%eax
80103bb4:	c1 f8 0c             	sar    $0xc,%eax
80103bb7:	89 44 24 04          	mov    %eax,0x4(%esp)
80103bbb:	c7 04 24 9d 70 10 80 	movl   $0x8010709d,(%esp)
80103bc2:	e8 00 ca ff ff       	call   801005c7 <cprintf>
80103bc7:	eb 10                	jmp    80103bd9 <dumppagetable+0xd6>

    } 
    else {
      cprintf("%x N/A \n", va);
80103bc9:	89 74 24 04          	mov    %esi,0x4(%esp)
80103bcd:	c7 04 24 ac 70 10 80 	movl   $0x801070ac,(%esp)
80103bd4:	e8 ee c9 ff ff       	call   801005c7 <cprintf>
 for (int va = 0; va < p->sz; va += PGSIZE) {
80103bd9:	81 c6 00 10 00 00    	add    $0x1000,%esi
80103bdf:	3b 33                	cmp    (%ebx),%esi
80103be1:	0f 82 74 ff ff ff    	jb     80103b5b <dumppagetable+0x58>
    }
  }

  cprintf("END PAGE TABLE\n");
80103be7:	c7 04 24 b5 70 10 80 	movl   $0x801070b5,(%esp)
80103bee:	e8 d4 c9 ff ff       	call   801005c7 <cprintf>
  
 
  return 0;
80103bf3:	b8 00 00 00 00       	mov    $0x0,%eax
80103bf8:	eb 05                	jmp    80103bff <dumppagetable+0xfc>
    return -1;
80103bfa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103bff:	83 c4 20             	add    $0x20,%esp
80103c02:	5b                   	pop    %ebx
80103c03:	5e                   	pop    %esi
80103c04:	5d                   	pop    %ebp
80103c05:	c3                   	ret    

80103c06 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103c06:	55                   	push   %ebp
80103c07:	89 e5                	mov    %esp,%ebp
80103c09:	53                   	push   %ebx
80103c0a:	83 ec 14             	sub    $0x14,%esp
80103c0d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103c10:	c7 44 24 04 30 71 10 	movl   $0x80107130,0x4(%esp)
80103c17:	80 
80103c18:	8d 43 04             	lea    0x4(%ebx),%eax
80103c1b:	89 04 24             	mov    %eax,(%esp)
80103c1e:	e8 e8 00 00 00       	call   80103d0b <initlock>
  lk->name = name;
80103c23:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c26:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103c29:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103c2f:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103c36:	83 c4 14             	add    $0x14,%esp
80103c39:	5b                   	pop    %ebx
80103c3a:	5d                   	pop    %ebp
80103c3b:	c3                   	ret    

80103c3c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103c3c:	55                   	push   %ebp
80103c3d:	89 e5                	mov    %esp,%ebp
80103c3f:	56                   	push   %esi
80103c40:	53                   	push   %ebx
80103c41:	83 ec 10             	sub    $0x10,%esp
80103c44:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103c47:	8d 73 04             	lea    0x4(%ebx),%esi
80103c4a:	89 34 24             	mov    %esi,(%esp)
80103c4d:	e8 f1 01 00 00       	call   80103e43 <acquire>
  while (lk->locked) {
80103c52:	eb 0c                	jmp    80103c60 <acquiresleep+0x24>
    sleep(lk, &lk->lk);
80103c54:	89 74 24 04          	mov    %esi,0x4(%esp)
80103c58:	89 1c 24             	mov    %ebx,(%esp)
80103c5b:	e8 e5 fa ff ff       	call   80103745 <sleep>
  while (lk->locked) {
80103c60:	83 3b 00             	cmpl   $0x0,(%ebx)
80103c63:	75 ef                	jne    80103c54 <acquiresleep+0x18>
  }
  lk->locked = 1;
80103c65:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103c6b:	e8 4d f6 ff ff       	call   801032bd <myproc>
80103c70:	8b 40 10             	mov    0x10(%eax),%eax
80103c73:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103c76:	89 34 24             	mov    %esi,(%esp)
80103c79:	e8 26 02 00 00       	call   80103ea4 <release>
}
80103c7e:	83 c4 10             	add    $0x10,%esp
80103c81:	5b                   	pop    %ebx
80103c82:	5e                   	pop    %esi
80103c83:	5d                   	pop    %ebp
80103c84:	c3                   	ret    

80103c85 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103c85:	55                   	push   %ebp
80103c86:	89 e5                	mov    %esp,%ebp
80103c88:	56                   	push   %esi
80103c89:	53                   	push   %ebx
80103c8a:	83 ec 10             	sub    $0x10,%esp
80103c8d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103c90:	8d 73 04             	lea    0x4(%ebx),%esi
80103c93:	89 34 24             	mov    %esi,(%esp)
80103c96:	e8 a8 01 00 00       	call   80103e43 <acquire>
  lk->locked = 0;
80103c9b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103ca1:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103ca8:	89 1c 24             	mov    %ebx,(%esp)
80103cab:	e8 ea fb ff ff       	call   8010389a <wakeup>
  release(&lk->lk);
80103cb0:	89 34 24             	mov    %esi,(%esp)
80103cb3:	e8 ec 01 00 00       	call   80103ea4 <release>
}
80103cb8:	83 c4 10             	add    $0x10,%esp
80103cbb:	5b                   	pop    %ebx
80103cbc:	5e                   	pop    %esi
80103cbd:	5d                   	pop    %ebp
80103cbe:	c3                   	ret    

80103cbf <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103cbf:	55                   	push   %ebp
80103cc0:	89 e5                	mov    %esp,%ebp
80103cc2:	56                   	push   %esi
80103cc3:	53                   	push   %ebx
80103cc4:	83 ec 10             	sub    $0x10,%esp
80103cc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103cca:	8d 73 04             	lea    0x4(%ebx),%esi
80103ccd:	89 34 24             	mov    %esi,(%esp)
80103cd0:	e8 6e 01 00 00       	call   80103e43 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103cd5:	83 3b 00             	cmpl   $0x0,(%ebx)
80103cd8:	74 14                	je     80103cee <holdingsleep+0x2f>
80103cda:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103cdd:	e8 db f5 ff ff       	call   801032bd <myproc>
80103ce2:	3b 58 10             	cmp    0x10(%eax),%ebx
80103ce5:	75 0e                	jne    80103cf5 <holdingsleep+0x36>
80103ce7:	bb 01 00 00 00       	mov    $0x1,%ebx
80103cec:	eb 0c                	jmp    80103cfa <holdingsleep+0x3b>
80103cee:	bb 00 00 00 00       	mov    $0x0,%ebx
80103cf3:	eb 05                	jmp    80103cfa <holdingsleep+0x3b>
80103cf5:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103cfa:	89 34 24             	mov    %esi,(%esp)
80103cfd:	e8 a2 01 00 00       	call   80103ea4 <release>
  return r;
}
80103d02:	89 d8                	mov    %ebx,%eax
80103d04:	83 c4 10             	add    $0x10,%esp
80103d07:	5b                   	pop    %ebx
80103d08:	5e                   	pop    %esi
80103d09:	5d                   	pop    %ebp
80103d0a:	c3                   	ret    

80103d0b <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103d0b:	55                   	push   %ebp
80103d0c:	89 e5                	mov    %esp,%ebp
80103d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103d11:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d14:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103d17:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103d1d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103d24:	5d                   	pop    %ebp
80103d25:	c3                   	ret    

80103d26 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103d26:	55                   	push   %ebp
80103d27:	89 e5                	mov    %esp,%ebp
80103d29:	53                   	push   %ebx
80103d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103d2d:	8b 45 08             	mov    0x8(%ebp),%eax
80103d30:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103d33:	b8 00 00 00 00       	mov    $0x0,%eax
80103d38:	eb 19                	jmp    80103d53 <getcallerpcs+0x2d>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103d3a:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103d40:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103d46:	77 1c                	ja     80103d64 <getcallerpcs+0x3e>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103d48:	8b 5a 04             	mov    0x4(%edx),%ebx
80103d4b:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103d4e:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103d50:	83 c0 01             	add    $0x1,%eax
80103d53:	83 f8 09             	cmp    $0x9,%eax
80103d56:	7e e2                	jle    80103d3a <getcallerpcs+0x14>
80103d58:	eb 0a                	jmp    80103d64 <getcallerpcs+0x3e>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103d5a:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103d61:	83 c0 01             	add    $0x1,%eax
80103d64:	83 f8 09             	cmp    $0x9,%eax
80103d67:	7e f1                	jle    80103d5a <getcallerpcs+0x34>
}
80103d69:	5b                   	pop    %ebx
80103d6a:	5d                   	pop    %ebp
80103d6b:	c3                   	ret    

80103d6c <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103d6c:	55                   	push   %ebp
80103d6d:	89 e5                	mov    %esp,%ebp
80103d6f:	53                   	push   %ebx
80103d70:	83 ec 04             	sub    $0x4,%esp
80103d73:	9c                   	pushf  
80103d74:	5b                   	pop    %ebx
  asm volatile("cli");
80103d75:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103d76:	e8 cd f4 ff ff       	call   80103248 <mycpu>
80103d7b:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103d82:	75 11                	jne    80103d95 <pushcli+0x29>
    mycpu()->intena = eflags & FL_IF;
80103d84:	e8 bf f4 ff ff       	call   80103248 <mycpu>
80103d89:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103d8f:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
  mycpu()->ncli += 1;
80103d95:	e8 ae f4 ff ff       	call   80103248 <mycpu>
80103d9a:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103da1:	83 c4 04             	add    $0x4,%esp
80103da4:	5b                   	pop    %ebx
80103da5:	5d                   	pop    %ebp
80103da6:	c3                   	ret    

80103da7 <popcli>:

void
popcli(void)
{
80103da7:	55                   	push   %ebp
80103da8:	89 e5                	mov    %esp,%ebp
80103daa:	83 ec 18             	sub    $0x18,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103dad:	9c                   	pushf  
80103dae:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103daf:	f6 c4 02             	test   $0x2,%ah
80103db2:	74 0c                	je     80103dc0 <popcli+0x19>
    panic("popcli - interruptible");
80103db4:	c7 04 24 3b 71 10 80 	movl   $0x8010713b,(%esp)
80103dbb:	e8 65 c5 ff ff       	call   80100325 <panic>
  if(--mycpu()->ncli < 0)
80103dc0:	e8 83 f4 ff ff       	call   80103248 <mycpu>
80103dc5:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103dcb:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103dce:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103dd4:	85 d2                	test   %edx,%edx
80103dd6:	79 0c                	jns    80103de4 <popcli+0x3d>
    panic("popcli");
80103dd8:	c7 04 24 52 71 10 80 	movl   $0x80107152,(%esp)
80103ddf:	e8 41 c5 ff ff       	call   80100325 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103de4:	e8 5f f4 ff ff       	call   80103248 <mycpu>
80103de9:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103df0:	75 0f                	jne    80103e01 <popcli+0x5a>
80103df2:	e8 51 f4 ff ff       	call   80103248 <mycpu>
80103df7:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103dfe:	74 01                	je     80103e01 <popcli+0x5a>
  asm volatile("sti");
80103e00:	fb                   	sti    
    sti();
}
80103e01:	c9                   	leave  
80103e02:	c3                   	ret    

80103e03 <holding>:
{
80103e03:	55                   	push   %ebp
80103e04:	89 e5                	mov    %esp,%ebp
80103e06:	53                   	push   %ebx
80103e07:	83 ec 04             	sub    $0x4,%esp
80103e0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103e0d:	e8 5a ff ff ff       	call   80103d6c <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103e12:	83 3b 00             	cmpl   $0x0,(%ebx)
80103e15:	74 13                	je     80103e2a <holding+0x27>
80103e17:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103e1a:	e8 29 f4 ff ff       	call   80103248 <mycpu>
80103e1f:	39 c3                	cmp    %eax,%ebx
80103e21:	75 0e                	jne    80103e31 <holding+0x2e>
80103e23:	bb 01 00 00 00       	mov    $0x1,%ebx
80103e28:	eb 0c                	jmp    80103e36 <holding+0x33>
80103e2a:	bb 00 00 00 00       	mov    $0x0,%ebx
80103e2f:	eb 05                	jmp    80103e36 <holding+0x33>
80103e31:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103e36:	e8 6c ff ff ff       	call   80103da7 <popcli>
}
80103e3b:	89 d8                	mov    %ebx,%eax
80103e3d:	83 c4 04             	add    $0x4,%esp
80103e40:	5b                   	pop    %ebx
80103e41:	5d                   	pop    %ebp
80103e42:	c3                   	ret    

80103e43 <acquire>:
{
80103e43:	55                   	push   %ebp
80103e44:	89 e5                	mov    %esp,%ebp
80103e46:	53                   	push   %ebx
80103e47:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103e4a:	e8 1d ff ff ff       	call   80103d6c <pushcli>
  if(holding(lk))
80103e4f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e52:	89 04 24             	mov    %eax,(%esp)
80103e55:	e8 a9 ff ff ff       	call   80103e03 <holding>
80103e5a:	85 c0                	test   %eax,%eax
80103e5c:	74 0c                	je     80103e6a <acquire+0x27>
    panic("acquire");
80103e5e:	c7 04 24 59 71 10 80 	movl   $0x80107159,(%esp)
80103e65:	e8 bb c4 ff ff       	call   80100325 <panic>
  asm volatile("lock; xchgl %0, %1" :
80103e6a:	b9 01 00 00 00       	mov    $0x1,%ecx
  while(xchg(&lk->locked, 1) != 0)
80103e6f:	8b 55 08             	mov    0x8(%ebp),%edx
80103e72:	89 c8                	mov    %ecx,%eax
80103e74:	f0 87 02             	lock xchg %eax,(%edx)
80103e77:	85 c0                	test   %eax,%eax
80103e79:	75 f4                	jne    80103e6f <acquire+0x2c>
  __sync_synchronize();
80103e7b:	0f ae f0             	mfence 
  lk->cpu = mycpu();
80103e7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103e81:	e8 c2 f3 ff ff       	call   80103248 <mycpu>
80103e86:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103e89:	8b 45 08             	mov    0x8(%ebp),%eax
80103e8c:	83 c0 0c             	add    $0xc,%eax
80103e8f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e93:	8d 45 08             	lea    0x8(%ebp),%eax
80103e96:	89 04 24             	mov    %eax,(%esp)
80103e99:	e8 88 fe ff ff       	call   80103d26 <getcallerpcs>
}
80103e9e:	83 c4 14             	add    $0x14,%esp
80103ea1:	5b                   	pop    %ebx
80103ea2:	5d                   	pop    %ebp
80103ea3:	c3                   	ret    

80103ea4 <release>:
{
80103ea4:	55                   	push   %ebp
80103ea5:	89 e5                	mov    %esp,%ebp
80103ea7:	53                   	push   %ebx
80103ea8:	83 ec 14             	sub    $0x14,%esp
80103eab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103eae:	89 1c 24             	mov    %ebx,(%esp)
80103eb1:	e8 4d ff ff ff       	call   80103e03 <holding>
80103eb6:	85 c0                	test   %eax,%eax
80103eb8:	75 0c                	jne    80103ec6 <release+0x22>
    panic("release");
80103eba:	c7 04 24 61 71 10 80 	movl   $0x80107161,(%esp)
80103ec1:	e8 5f c4 ff ff       	call   80100325 <panic>
  lk->pcs[0] = 0;
80103ec6:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103ecd:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103ed4:	0f ae f0             	mfence 
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103ed7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103edd:	e8 c5 fe ff ff       	call   80103da7 <popcli>
}
80103ee2:	83 c4 14             	add    $0x14,%esp
80103ee5:	5b                   	pop    %ebx
80103ee6:	5d                   	pop    %ebp
80103ee7:	c3                   	ret    
80103ee8:	66 90                	xchg   %ax,%ax
80103eea:	66 90                	xchg   %ax,%ax
80103eec:	66 90                	xchg   %ax,%ax
80103eee:	66 90                	xchg   %ax,%ax

80103ef0 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103ef0:	55                   	push   %ebp
80103ef1:	89 e5                	mov    %esp,%ebp
80103ef3:	57                   	push   %edi
80103ef4:	53                   	push   %ebx
80103ef5:	8b 55 08             	mov    0x8(%ebp),%edx
80103ef8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103efb:	f6 c2 03             	test   $0x3,%dl
80103efe:	75 28                	jne    80103f28 <memset+0x38>
80103f00:	f6 c1 03             	test   $0x3,%cl
80103f03:	75 23                	jne    80103f28 <memset+0x38>
    c &= 0xFF;
80103f05:	0f b6 45 0c          	movzbl 0xc(%ebp),%eax
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103f09:	c1 e9 02             	shr    $0x2,%ecx
80103f0c:	89 c7                	mov    %eax,%edi
80103f0e:	c1 e7 18             	shl    $0x18,%edi
80103f11:	89 c3                	mov    %eax,%ebx
80103f13:	c1 e3 10             	shl    $0x10,%ebx
80103f16:	09 df                	or     %ebx,%edi
80103f18:	89 c3                	mov    %eax,%ebx
80103f1a:	c1 e3 08             	shl    $0x8,%ebx
80103f1d:	09 df                	or     %ebx,%edi
80103f1f:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103f21:	89 d7                	mov    %edx,%edi
80103f23:	fc                   	cld    
80103f24:	f3 ab                	rep stos %eax,%es:(%edi)
80103f26:	eb 08                	jmp    80103f30 <memset+0x40>
  asm volatile("cld; rep stosb" :
80103f28:	89 d7                	mov    %edx,%edi
80103f2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f2d:	fc                   	cld    
80103f2e:	f3 aa                	rep stos %al,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80103f30:	89 d0                	mov    %edx,%eax
80103f32:	5b                   	pop    %ebx
80103f33:	5f                   	pop    %edi
80103f34:	5d                   	pop    %ebp
80103f35:	c3                   	ret    

80103f36 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103f36:	55                   	push   %ebp
80103f37:	89 e5                	mov    %esp,%ebp
80103f39:	56                   	push   %esi
80103f3a:	53                   	push   %ebx
80103f3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103f3e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f41:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103f44:	eb 1c                	jmp    80103f62 <memcmp+0x2c>
    if(*s1 != *s2)
80103f46:	0f b6 01             	movzbl (%ecx),%eax
80103f49:	0f b6 1a             	movzbl (%edx),%ebx
80103f4c:	38 d8                	cmp    %bl,%al
80103f4e:	74 0a                	je     80103f5a <memcmp+0x24>
      return *s1 - *s2;
80103f50:	0f b6 c0             	movzbl %al,%eax
80103f53:	0f b6 db             	movzbl %bl,%ebx
80103f56:	29 d8                	sub    %ebx,%eax
80103f58:	eb 0f                	jmp    80103f69 <memcmp+0x33>
    s1++, s2++;
80103f5a:	83 c1 01             	add    $0x1,%ecx
80103f5d:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103f60:	89 f0                	mov    %esi,%eax
80103f62:	8d 70 ff             	lea    -0x1(%eax),%esi
80103f65:	85 c0                	test   %eax,%eax
80103f67:	75 dd                	jne    80103f46 <memcmp+0x10>
  }

  return 0;
}
80103f69:	5b                   	pop    %ebx
80103f6a:	5e                   	pop    %esi
80103f6b:	5d                   	pop    %ebp
80103f6c:	c3                   	ret    

80103f6d <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103f6d:	55                   	push   %ebp
80103f6e:	89 e5                	mov    %esp,%ebp
80103f70:	56                   	push   %esi
80103f71:	53                   	push   %ebx
80103f72:	8b 45 08             	mov    0x8(%ebp),%eax
80103f75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103f78:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103f7b:	39 c1                	cmp    %eax,%ecx
80103f7d:	73 31                	jae    80103fb0 <memmove+0x43>
80103f7f:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103f82:	39 d8                	cmp    %ebx,%eax
80103f84:	73 2e                	jae    80103fb4 <memmove+0x47>
    s += n;
    d += n;
80103f86:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80103f89:	eb 0d                	jmp    80103f98 <memmove+0x2b>
      *--d = *--s;
80103f8b:	83 e9 01             	sub    $0x1,%ecx
80103f8e:	83 eb 01             	sub    $0x1,%ebx
80103f91:	0f b6 13             	movzbl (%ebx),%edx
80103f94:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80103f96:	89 f2                	mov    %esi,%edx
80103f98:	8d 72 ff             	lea    -0x1(%edx),%esi
80103f9b:	85 d2                	test   %edx,%edx
80103f9d:	75 ec                	jne    80103f8b <memmove+0x1e>
80103f9f:	eb 1c                	jmp    80103fbd <memmove+0x50>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103fa1:	0f b6 11             	movzbl (%ecx),%edx
80103fa4:	88 13                	mov    %dl,(%ebx)
    while(n-- > 0)
80103fa6:	89 f2                	mov    %esi,%edx
      *d++ = *s++;
80103fa8:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103fab:	8d 49 01             	lea    0x1(%ecx),%ecx
80103fae:	eb 06                	jmp    80103fb6 <memmove+0x49>
80103fb0:	89 c3                	mov    %eax,%ebx
80103fb2:	eb 02                	jmp    80103fb6 <memmove+0x49>
80103fb4:	89 c3                	mov    %eax,%ebx
    while(n-- > 0)
80103fb6:	8d 72 ff             	lea    -0x1(%edx),%esi
80103fb9:	85 d2                	test   %edx,%edx
80103fbb:	75 e4                	jne    80103fa1 <memmove+0x34>

  return dst;
}
80103fbd:	5b                   	pop    %ebx
80103fbe:	5e                   	pop    %esi
80103fbf:	5d                   	pop    %ebp
80103fc0:	c3                   	ret    

80103fc1 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103fc1:	55                   	push   %ebp
80103fc2:	89 e5                	mov    %esp,%ebp
80103fc4:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80103fc7:	8b 45 10             	mov    0x10(%ebp),%eax
80103fca:	89 44 24 08          	mov    %eax,0x8(%esp)
80103fce:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd1:	89 44 24 04          	mov    %eax,0x4(%esp)
80103fd5:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd8:	89 04 24             	mov    %eax,(%esp)
80103fdb:	e8 8d ff ff ff       	call   80103f6d <memmove>
}
80103fe0:	c9                   	leave  
80103fe1:	c3                   	ret    

80103fe2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103fe2:	55                   	push   %ebp
80103fe3:	89 e5                	mov    %esp,%ebp
80103fe5:	53                   	push   %ebx
80103fe6:	8b 55 08             	mov    0x8(%ebp),%edx
80103fe9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103fec:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103fef:	eb 09                	jmp    80103ffa <strncmp+0x18>
    n--, p++, q++;
80103ff1:	83 e8 01             	sub    $0x1,%eax
80103ff4:	83 c2 01             	add    $0x1,%edx
80103ff7:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103ffa:	85 c0                	test   %eax,%eax
80103ffc:	74 0b                	je     80104009 <strncmp+0x27>
80103ffe:	0f b6 1a             	movzbl (%edx),%ebx
80104001:	84 db                	test   %bl,%bl
80104003:	74 04                	je     80104009 <strncmp+0x27>
80104005:	3a 19                	cmp    (%ecx),%bl
80104007:	74 e8                	je     80103ff1 <strncmp+0xf>
  if(n == 0)
80104009:	85 c0                	test   %eax,%eax
8010400b:	74 0a                	je     80104017 <strncmp+0x35>
    return 0;
  return (uchar)*p - (uchar)*q;
8010400d:	0f b6 02             	movzbl (%edx),%eax
80104010:	0f b6 11             	movzbl (%ecx),%edx
80104013:	29 d0                	sub    %edx,%eax
80104015:	eb 05                	jmp    8010401c <strncmp+0x3a>
    return 0;
80104017:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010401c:	5b                   	pop    %ebx
8010401d:	5d                   	pop    %ebp
8010401e:	c3                   	ret    

8010401f <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010401f:	55                   	push   %ebp
80104020:	89 e5                	mov    %esp,%ebp
80104022:	57                   	push   %edi
80104023:	56                   	push   %esi
80104024:	53                   	push   %ebx
80104025:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104028:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
8010402b:	8b 45 08             	mov    0x8(%ebp),%eax
8010402e:	eb 04                	jmp    80104034 <strncpy+0x15>
80104030:	89 fb                	mov    %edi,%ebx
80104032:	89 f0                	mov    %esi,%eax
80104034:	8d 51 ff             	lea    -0x1(%ecx),%edx
80104037:	85 c9                	test   %ecx,%ecx
80104039:	7e 1d                	jle    80104058 <strncpy+0x39>
8010403b:	8d 70 01             	lea    0x1(%eax),%esi
8010403e:	8d 7b 01             	lea    0x1(%ebx),%edi
80104041:	0f b6 1b             	movzbl (%ebx),%ebx
80104044:	88 18                	mov    %bl,(%eax)
80104046:	89 d1                	mov    %edx,%ecx
80104048:	84 db                	test   %bl,%bl
8010404a:	75 e4                	jne    80104030 <strncpy+0x11>
8010404c:	89 f0                	mov    %esi,%eax
8010404e:	eb 08                	jmp    80104058 <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80104050:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104053:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80104055:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
80104058:	8d 4a ff             	lea    -0x1(%edx),%ecx
8010405b:	85 d2                	test   %edx,%edx
8010405d:	7f f1                	jg     80104050 <strncpy+0x31>
  return os;
}
8010405f:	8b 45 08             	mov    0x8(%ebp),%eax
80104062:	5b                   	pop    %ebx
80104063:	5e                   	pop    %esi
80104064:	5f                   	pop    %edi
80104065:	5d                   	pop    %ebp
80104066:	c3                   	ret    

80104067 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104067:	55                   	push   %ebp
80104068:	89 e5                	mov    %esp,%ebp
8010406a:	57                   	push   %edi
8010406b:	56                   	push   %esi
8010406c:	53                   	push   %ebx
8010406d:	8b 45 08             	mov    0x8(%ebp),%eax
80104070:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104073:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80104076:	85 d2                	test   %edx,%edx
80104078:	7e 23                	jle    8010409d <safestrcpy+0x36>
8010407a:	89 c1                	mov    %eax,%ecx
8010407c:	eb 04                	jmp    80104082 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
8010407e:	89 fb                	mov    %edi,%ebx
80104080:	89 f1                	mov    %esi,%ecx
80104082:	83 ea 01             	sub    $0x1,%edx
80104085:	85 d2                	test   %edx,%edx
80104087:	7e 11                	jle    8010409a <safestrcpy+0x33>
80104089:	8d 71 01             	lea    0x1(%ecx),%esi
8010408c:	8d 7b 01             	lea    0x1(%ebx),%edi
8010408f:	0f b6 1b             	movzbl (%ebx),%ebx
80104092:	88 19                	mov    %bl,(%ecx)
80104094:	84 db                	test   %bl,%bl
80104096:	75 e6                	jne    8010407e <safestrcpy+0x17>
80104098:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
8010409a:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
8010409d:	5b                   	pop    %ebx
8010409e:	5e                   	pop    %esi
8010409f:	5f                   	pop    %edi
801040a0:	5d                   	pop    %ebp
801040a1:	c3                   	ret    

801040a2 <strlen>:

int
strlen(const char *s)
{
801040a2:	55                   	push   %ebp
801040a3:	89 e5                	mov    %esp,%ebp
801040a5:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
801040a8:	b8 00 00 00 00       	mov    $0x0,%eax
801040ad:	eb 03                	jmp    801040b2 <strlen+0x10>
801040af:	83 c0 01             	add    $0x1,%eax
801040b2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
801040b6:	75 f7                	jne    801040af <strlen+0xd>
    ;
  return n;
}
801040b8:	5d                   	pop    %ebp
801040b9:	c3                   	ret    

801040ba <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801040ba:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801040be:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
801040c2:	55                   	push   %ebp
  pushl %ebx
801040c3:	53                   	push   %ebx
  pushl %esi
801040c4:	56                   	push   %esi
  pushl %edi
801040c5:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801040c6:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801040c8:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
801040ca:	5f                   	pop    %edi
  popl %esi
801040cb:	5e                   	pop    %esi
  popl %ebx
801040cc:	5b                   	pop    %ebx
  popl %ebp
801040cd:	5d                   	pop    %ebp
  ret
801040ce:	c3                   	ret    

801040cf <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801040cf:	55                   	push   %ebp
801040d0:	89 e5                	mov    %esp,%ebp
801040d2:	53                   	push   %ebx
801040d3:	83 ec 04             	sub    $0x4,%esp
801040d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
801040d9:	e8 df f1 ff ff       	call   801032bd <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801040de:	8b 00                	mov    (%eax),%eax
801040e0:	39 d8                	cmp    %ebx,%eax
801040e2:	76 15                	jbe    801040f9 <fetchint+0x2a>
801040e4:	8d 53 04             	lea    0x4(%ebx),%edx
801040e7:	39 d0                	cmp    %edx,%eax
801040e9:	72 15                	jb     80104100 <fetchint+0x31>
    return -1;
  *ip = *(int*)(addr);
801040eb:	8b 13                	mov    (%ebx),%edx
801040ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801040f0:	89 10                	mov    %edx,(%eax)
  return 0;
801040f2:	b8 00 00 00 00       	mov    $0x0,%eax
801040f7:	eb 0c                	jmp    80104105 <fetchint+0x36>
    return -1;
801040f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040fe:	eb 05                	jmp    80104105 <fetchint+0x36>
80104100:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104105:	83 c4 04             	add    $0x4,%esp
80104108:	5b                   	pop    %ebx
80104109:	5d                   	pop    %ebp
8010410a:	c3                   	ret    

8010410b <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010410b:	55                   	push   %ebp
8010410c:	89 e5                	mov    %esp,%ebp
8010410e:	53                   	push   %ebx
8010410f:	83 ec 04             	sub    $0x4,%esp
80104112:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80104115:	e8 a3 f1 ff ff       	call   801032bd <myproc>

  if(addr >= curproc->sz)
8010411a:	39 18                	cmp    %ebx,(%eax)
8010411c:	76 22                	jbe    80104140 <fetchstr+0x35>
    return -1;
  *pp = (char*)addr;
8010411e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104121:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104123:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104125:	89 d8                	mov    %ebx,%eax
80104127:	eb 0c                	jmp    80104135 <fetchstr+0x2a>
    if(*s == 0)
80104129:	80 38 00             	cmpb   $0x0,(%eax)
8010412c:	75 04                	jne    80104132 <fetchstr+0x27>
      return s - *pp;
8010412e:	29 d8                	sub    %ebx,%eax
80104130:	eb 13                	jmp    80104145 <fetchstr+0x3a>
  for(s = *pp; s < ep; s++){
80104132:	83 c0 01             	add    $0x1,%eax
80104135:	39 d0                	cmp    %edx,%eax
80104137:	72 f0                	jb     80104129 <fetchstr+0x1e>
  }
  return -1;
80104139:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010413e:	eb 05                	jmp    80104145 <fetchstr+0x3a>
    return -1;
80104140:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104145:	83 c4 04             	add    $0x4,%esp
80104148:	5b                   	pop    %ebx
80104149:	5d                   	pop    %ebp
8010414a:	c3                   	ret    

8010414b <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010414b:	55                   	push   %ebp
8010414c:	89 e5                	mov    %esp,%ebp
8010414e:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104151:	e8 67 f1 ff ff       	call   801032bd <myproc>
80104156:	8b 50 18             	mov    0x18(%eax),%edx
80104159:	8b 45 08             	mov    0x8(%ebp),%eax
8010415c:	c1 e0 02             	shl    $0x2,%eax
8010415f:	03 42 44             	add    0x44(%edx),%eax
80104162:	83 c0 04             	add    $0x4,%eax
80104165:	8b 55 0c             	mov    0xc(%ebp),%edx
80104168:	89 54 24 04          	mov    %edx,0x4(%esp)
8010416c:	89 04 24             	mov    %eax,(%esp)
8010416f:	e8 5b ff ff ff       	call   801040cf <fetchint>
}
80104174:	c9                   	leave  
80104175:	c3                   	ret    

80104176 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104176:	55                   	push   %ebp
80104177:	89 e5                	mov    %esp,%ebp
80104179:	56                   	push   %esi
8010417a:	53                   	push   %ebx
8010417b:	83 ec 20             	sub    $0x20,%esp
8010417e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80104181:	e8 37 f1 ff ff       	call   801032bd <myproc>
80104186:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80104188:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010418b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010418f:	8b 45 08             	mov    0x8(%ebp),%eax
80104192:	89 04 24             	mov    %eax,(%esp)
80104195:	e8 b1 ff ff ff       	call   8010414b <argint>
8010419a:	85 c0                	test   %eax,%eax
8010419c:	78 1f                	js     801041bd <argptr+0x47>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010419e:	85 db                	test   %ebx,%ebx
801041a0:	78 22                	js     801041c4 <argptr+0x4e>
801041a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041a5:	8b 06                	mov    (%esi),%eax
801041a7:	39 c2                	cmp    %eax,%edx
801041a9:	73 20                	jae    801041cb <argptr+0x55>
801041ab:	01 d3                	add    %edx,%ebx
801041ad:	39 d8                	cmp    %ebx,%eax
801041af:	72 21                	jb     801041d2 <argptr+0x5c>
    return -1;
  *pp = (char*)i;
801041b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801041b4:	89 10                	mov    %edx,(%eax)
  return 0;
801041b6:	b8 00 00 00 00       	mov    $0x0,%eax
801041bb:	eb 1a                	jmp    801041d7 <argptr+0x61>
    return -1;
801041bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041c2:	eb 13                	jmp    801041d7 <argptr+0x61>
    return -1;
801041c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041c9:	eb 0c                	jmp    801041d7 <argptr+0x61>
801041cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041d0:	eb 05                	jmp    801041d7 <argptr+0x61>
801041d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801041d7:	83 c4 20             	add    $0x20,%esp
801041da:	5b                   	pop    %ebx
801041db:	5e                   	pop    %esi
801041dc:	5d                   	pop    %ebp
801041dd:	c3                   	ret    

801041de <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801041de:	55                   	push   %ebp
801041df:	89 e5                	mov    %esp,%ebp
801041e1:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
801041e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801041e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801041eb:	8b 45 08             	mov    0x8(%ebp),%eax
801041ee:	89 04 24             	mov    %eax,(%esp)
801041f1:	e8 55 ff ff ff       	call   8010414b <argint>
801041f6:	85 c0                	test   %eax,%eax
801041f8:	78 14                	js     8010420e <argstr+0x30>
    return -1;
  return fetchstr(addr, pp);
801041fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801041fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80104201:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104204:	89 04 24             	mov    %eax,(%esp)
80104207:	e8 ff fe ff ff       	call   8010410b <fetchstr>
8010420c:	eb 05                	jmp    80104213 <argstr+0x35>
    return -1;
8010420e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104213:	c9                   	leave  
80104214:	c3                   	ret    

80104215 <syscall>:
[SYS_shutdown] sys_shutdown,
};

void
syscall(void)
{
80104215:	55                   	push   %ebp
80104216:	89 e5                	mov    %esp,%ebp
80104218:	56                   	push   %esi
80104219:	53                   	push   %ebx
8010421a:	83 ec 10             	sub    $0x10,%esp
  int num;
  struct proc *curproc = myproc();
8010421d:	e8 9b f0 ff ff       	call   801032bd <myproc>
80104222:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104224:	8b 70 18             	mov    0x18(%eax),%esi
80104227:	8b 46 1c             	mov    0x1c(%esi),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010422a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010422d:	83 fa 19             	cmp    $0x19,%edx
80104230:	77 12                	ja     80104244 <syscall+0x2f>
80104232:	8b 14 85 a0 71 10 80 	mov    -0x7fef8e60(,%eax,4),%edx
80104239:	85 d2                	test   %edx,%edx
8010423b:	74 07                	je     80104244 <syscall+0x2f>
    curproc->tf->eax = syscalls[num]();
8010423d:	ff d2                	call   *%edx
8010423f:	89 46 1c             	mov    %eax,0x1c(%esi)
80104242:	eb 28                	jmp    8010426c <syscall+0x57>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104244:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104247:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010424b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010424f:	8b 43 10             	mov    0x10(%ebx),%eax
80104252:	89 44 24 04          	mov    %eax,0x4(%esp)
80104256:	c7 04 24 69 71 10 80 	movl   $0x80107169,(%esp)
8010425d:	e8 65 c3 ff ff       	call   801005c7 <cprintf>
    curproc->tf->eax = -1;
80104262:	8b 43 18             	mov    0x18(%ebx),%eax
80104265:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010426c:	83 c4 10             	add    $0x10,%esp
8010426f:	5b                   	pop    %ebx
80104270:	5e                   	pop    %esi
80104271:	5d                   	pop    %ebp
80104272:	c3                   	ret    
80104273:	66 90                	xchg   %ax,%ax
80104275:	66 90                	xchg   %ax,%ax
80104277:	66 90                	xchg   %ax,%ax
80104279:	66 90                	xchg   %ax,%ax
8010427b:	66 90                	xchg   %ax,%ax
8010427d:	66 90                	xchg   %ax,%ax
8010427f:	90                   	nop

80104280 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104280:	55                   	push   %ebp
80104281:	89 e5                	mov    %esp,%ebp
80104283:	56                   	push   %esi
80104284:	53                   	push   %ebx
80104285:	83 ec 20             	sub    $0x20,%esp
80104288:	89 d6                	mov    %edx,%esi
8010428a:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010428c:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010428f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104293:	89 04 24             	mov    %eax,(%esp)
80104296:	e8 b0 fe ff ff       	call   8010414b <argint>
8010429b:	85 c0                	test   %eax,%eax
8010429d:	78 29                	js     801042c8 <argfd+0x48>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010429f:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801042a3:	77 2a                	ja     801042cf <argfd+0x4f>
801042a5:	e8 13 f0 ff ff       	call   801032bd <myproc>
801042aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042ad:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
801042b1:	85 c0                	test   %eax,%eax
801042b3:	74 21                	je     801042d6 <argfd+0x56>
    return -1;
  if(pfd)
801042b5:	85 f6                	test   %esi,%esi
801042b7:	74 02                	je     801042bb <argfd+0x3b>
    *pfd = fd;
801042b9:	89 16                	mov    %edx,(%esi)
  if(pf)
801042bb:	85 db                	test   %ebx,%ebx
801042bd:	74 1e                	je     801042dd <argfd+0x5d>
    *pf = f;
801042bf:	89 03                	mov    %eax,(%ebx)
  return 0;
801042c1:	b8 00 00 00 00       	mov    $0x0,%eax
801042c6:	eb 1a                	jmp    801042e2 <argfd+0x62>
    return -1;
801042c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042cd:	eb 13                	jmp    801042e2 <argfd+0x62>
    return -1;
801042cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042d4:	eb 0c                	jmp    801042e2 <argfd+0x62>
801042d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042db:	eb 05                	jmp    801042e2 <argfd+0x62>
  return 0;
801042dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801042e2:	83 c4 20             	add    $0x20,%esp
801042e5:	5b                   	pop    %ebx
801042e6:	5e                   	pop    %esi
801042e7:	5d                   	pop    %ebp
801042e8:	c3                   	ret    

801042e9 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801042e9:	55                   	push   %ebp
801042ea:	89 e5                	mov    %esp,%ebp
801042ec:	53                   	push   %ebx
801042ed:	83 ec 04             	sub    $0x4,%esp
801042f0:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
801042f2:	e8 c6 ef ff ff       	call   801032bd <myproc>

  for(fd = 0; fd < NOFILE; fd++){
801042f7:	ba 00 00 00 00       	mov    $0x0,%edx
801042fc:	eb 12                	jmp    80104310 <fdalloc+0x27>
    if(curproc->ofile[fd] == 0){
801042fe:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
80104303:	75 08                	jne    8010430d <fdalloc+0x24>
      curproc->ofile[fd] = f;
80104305:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
80104309:	89 d0                	mov    %edx,%eax
8010430b:	eb 0d                	jmp    8010431a <fdalloc+0x31>
  for(fd = 0; fd < NOFILE; fd++){
8010430d:	83 c2 01             	add    $0x1,%edx
80104310:	83 fa 0f             	cmp    $0xf,%edx
80104313:	7e e9                	jle    801042fe <fdalloc+0x15>
    }
  }
  return -1;
80104315:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010431a:	83 c4 04             	add    $0x4,%esp
8010431d:	5b                   	pop    %ebx
8010431e:	5d                   	pop    %ebp
8010431f:	c3                   	ret    

80104320 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80104320:	55                   	push   %ebp
80104321:	89 e5                	mov    %esp,%ebp
80104323:	57                   	push   %edi
80104324:	56                   	push   %esi
80104325:	53                   	push   %ebx
80104326:	83 ec 2c             	sub    $0x2c,%esp
80104329:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010432b:	b8 20 00 00 00       	mov    $0x20,%eax
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104330:	8d 7d d8             	lea    -0x28(%ebp),%edi
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104333:	eb 33                	jmp    80104368 <isdirempty+0x48>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104335:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010433c:	00 
8010433d:	89 44 24 08          	mov    %eax,0x8(%esp)
80104341:	89 7c 24 04          	mov    %edi,0x4(%esp)
80104345:	89 1c 24             	mov    %ebx,(%esp)
80104348:	e8 91 d4 ff ff       	call   801017de <readi>
8010434d:	83 f8 10             	cmp    $0x10,%eax
80104350:	74 0c                	je     8010435e <isdirempty+0x3e>
      panic("isdirempty: readi");
80104352:	c7 04 24 0c 72 10 80 	movl   $0x8010720c,(%esp)
80104359:	e8 c7 bf ff ff       	call   80100325 <panic>
    if(de.inum != 0)
8010435e:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80104363:	75 11                	jne    80104376 <isdirempty+0x56>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104365:	8d 46 10             	lea    0x10(%esi),%eax
80104368:	89 c6                	mov    %eax,%esi
8010436a:	3b 43 58             	cmp    0x58(%ebx),%eax
8010436d:	72 c6                	jb     80104335 <isdirempty+0x15>
      return 0;
  }
  return 1;
8010436f:	b8 01 00 00 00       	mov    $0x1,%eax
80104374:	eb 05                	jmp    8010437b <isdirempty+0x5b>
      return 0;
80104376:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010437b:	83 c4 2c             	add    $0x2c,%esp
8010437e:	5b                   	pop    %ebx
8010437f:	5e                   	pop    %esi
80104380:	5f                   	pop    %edi
80104381:	5d                   	pop    %ebp
80104382:	c3                   	ret    

80104383 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104383:	55                   	push   %ebp
80104384:	89 e5                	mov    %esp,%ebp
80104386:	57                   	push   %edi
80104387:	56                   	push   %esi
80104388:	53                   	push   %ebx
80104389:	83 ec 3c             	sub    $0x3c,%esp
8010438c:	89 d7                	mov    %edx,%edi
8010438e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
80104391:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104394:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104397:	8d 55 da             	lea    -0x26(%ebp),%edx
8010439a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010439e:	89 04 24             	mov    %eax,(%esp)
801043a1:	e8 f4 d8 ff ff       	call   80101c9a <nameiparent>
801043a6:	89 c3                	mov    %eax,%ebx
801043a8:	85 c0                	test   %eax,%eax
801043aa:	0f 84 28 01 00 00    	je     801044d8 <create+0x155>
    return 0;
  ilock(dp);
801043b0:	89 04 24             	mov    %eax,(%esp)
801043b3:	e8 49 d2 ff ff       	call   80101601 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
801043b8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801043bf:	00 
801043c0:	8d 45 da             	lea    -0x26(%ebp),%eax
801043c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801043c7:	89 1c 24             	mov    %ebx,(%esp)
801043ca:	e8 69 d6 ff ff       	call   80101a38 <dirlookup>
801043cf:	89 c6                	mov    %eax,%esi
801043d1:	85 c0                	test   %eax,%eax
801043d3:	74 33                	je     80104408 <create+0x85>
    iunlockput(dp);
801043d5:	89 1c 24             	mov    %ebx,(%esp)
801043d8:	e8 b6 d3 ff ff       	call   80101793 <iunlockput>
    ilock(ip);
801043dd:	89 34 24             	mov    %esi,(%esp)
801043e0:	e8 1c d2 ff ff       	call   80101601 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801043e5:	66 83 ff 02          	cmp    $0x2,%di
801043e9:	75 0b                	jne    801043f6 <create+0x73>
801043eb:	66 83 7e 50 02       	cmpw   $0x2,0x50(%esi)
801043f0:	0f 84 e9 00 00 00    	je     801044df <create+0x15c>
      return ip;
    iunlockput(ip);
801043f6:	89 34 24             	mov    %esi,(%esp)
801043f9:	e8 95 d3 ff ff       	call   80101793 <iunlockput>
    return 0;
801043fe:	b8 00 00 00 00       	mov    $0x0,%eax
80104403:	e9 d9 00 00 00       	jmp    801044e1 <create+0x15e>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80104408:	0f bf d7             	movswl %di,%edx
8010440b:	8b 03                	mov    (%ebx),%eax
8010440d:	89 54 24 04          	mov    %edx,0x4(%esp)
80104411:	89 04 24             	mov    %eax,(%esp)
80104414:	e8 e3 cf ff ff       	call   801013fc <ialloc>
80104419:	89 c6                	mov    %eax,%esi
8010441b:	85 c0                	test   %eax,%eax
8010441d:	75 0c                	jne    8010442b <create+0xa8>
    panic("create: ialloc");
8010441f:	c7 04 24 1e 72 10 80 	movl   $0x8010721e,(%esp)
80104426:	e8 fa be ff ff       	call   80100325 <panic>

  ilock(ip);
8010442b:	89 04 24             	mov    %eax,(%esp)
8010442e:	e8 ce d1 ff ff       	call   80101601 <ilock>
  ip->major = major;
80104433:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
80104437:	66 89 46 52          	mov    %ax,0x52(%esi)
  ip->minor = minor;
8010443b:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
8010443f:	66 89 46 54          	mov    %ax,0x54(%esi)
  ip->nlink = 1;
80104443:	66 c7 46 56 01 00    	movw   $0x1,0x56(%esi)
  iupdate(ip);
80104449:	89 34 24             	mov    %esi,(%esp)
8010444c:	e8 53 d0 ff ff       	call   801014a4 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80104451:	66 83 ff 01          	cmp    $0x1,%di
80104455:	75 4f                	jne    801044a6 <create+0x123>
    dp->nlink++;  // for ".."
80104457:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
    iupdate(dp);
8010445c:	89 1c 24             	mov    %ebx,(%esp)
8010445f:	e8 40 d0 ff ff       	call   801014a4 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104464:	8b 46 04             	mov    0x4(%esi),%eax
80104467:	89 44 24 08          	mov    %eax,0x8(%esp)
8010446b:	c7 44 24 04 2e 72 10 	movl   $0x8010722e,0x4(%esp)
80104472:	80 
80104473:	89 34 24             	mov    %esi,(%esp)
80104476:	e8 30 d7 ff ff       	call   80101bab <dirlink>
8010447b:	85 c0                	test   %eax,%eax
8010447d:	78 1b                	js     8010449a <create+0x117>
8010447f:	8b 43 04             	mov    0x4(%ebx),%eax
80104482:	89 44 24 08          	mov    %eax,0x8(%esp)
80104486:	c7 44 24 04 2d 72 10 	movl   $0x8010722d,0x4(%esp)
8010448d:	80 
8010448e:	89 34 24             	mov    %esi,(%esp)
80104491:	e8 15 d7 ff ff       	call   80101bab <dirlink>
80104496:	85 c0                	test   %eax,%eax
80104498:	79 0c                	jns    801044a6 <create+0x123>
      panic("create dots");
8010449a:	c7 04 24 30 72 10 80 	movl   $0x80107230,(%esp)
801044a1:	e8 7f be ff ff       	call   80100325 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801044a6:	8b 46 04             	mov    0x4(%esi),%eax
801044a9:	89 44 24 08          	mov    %eax,0x8(%esp)
801044ad:	8d 45 da             	lea    -0x26(%ebp),%eax
801044b0:	89 44 24 04          	mov    %eax,0x4(%esp)
801044b4:	89 1c 24             	mov    %ebx,(%esp)
801044b7:	e8 ef d6 ff ff       	call   80101bab <dirlink>
801044bc:	85 c0                	test   %eax,%eax
801044be:	79 0c                	jns    801044cc <create+0x149>
    panic("create: dirlink");
801044c0:	c7 04 24 3c 72 10 80 	movl   $0x8010723c,(%esp)
801044c7:	e8 59 be ff ff       	call   80100325 <panic>

  iunlockput(dp);
801044cc:	89 1c 24             	mov    %ebx,(%esp)
801044cf:	e8 bf d2 ff ff       	call   80101793 <iunlockput>

  return ip;
801044d4:	89 f0                	mov    %esi,%eax
801044d6:	eb 09                	jmp    801044e1 <create+0x15e>
    return 0;
801044d8:	b8 00 00 00 00       	mov    $0x0,%eax
801044dd:	eb 02                	jmp    801044e1 <create+0x15e>
      return ip;
801044df:	89 f0                	mov    %esi,%eax
}
801044e1:	83 c4 3c             	add    $0x3c,%esp
801044e4:	5b                   	pop    %ebx
801044e5:	5e                   	pop    %esi
801044e6:	5f                   	pop    %edi
801044e7:	5d                   	pop    %ebp
801044e8:	c3                   	ret    

801044e9 <sys_dup>:
{
801044e9:	55                   	push   %ebp
801044ea:	89 e5                	mov    %esp,%ebp
801044ec:	53                   	push   %ebx
801044ed:	83 ec 24             	sub    $0x24,%esp
  if(argfd(0, 0, &f) < 0)
801044f0:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801044f3:	ba 00 00 00 00       	mov    $0x0,%edx
801044f8:	b8 00 00 00 00       	mov    $0x0,%eax
801044fd:	e8 7e fd ff ff       	call   80104280 <argfd>
80104502:	85 c0                	test   %eax,%eax
80104504:	78 1d                	js     80104523 <sys_dup+0x3a>
  if((fd=fdalloc(f)) < 0)
80104506:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104509:	e8 db fd ff ff       	call   801042e9 <fdalloc>
8010450e:	89 c3                	mov    %eax,%ebx
80104510:	85 c0                	test   %eax,%eax
80104512:	78 16                	js     8010452a <sys_dup+0x41>
  filedup(f);
80104514:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104517:	89 04 24             	mov    %eax,(%esp)
8010451a:	e8 b6 c7 ff ff       	call   80100cd5 <filedup>
  return fd;
8010451f:	89 d8                	mov    %ebx,%eax
80104521:	eb 0c                	jmp    8010452f <sys_dup+0x46>
    return -1;
80104523:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104528:	eb 05                	jmp    8010452f <sys_dup+0x46>
    return -1;
8010452a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010452f:	83 c4 24             	add    $0x24,%esp
80104532:	5b                   	pop    %ebx
80104533:	5d                   	pop    %ebp
80104534:	c3                   	ret    

80104535 <sys_read>:
{
80104535:	55                   	push   %ebp
80104536:	89 e5                	mov    %esp,%ebp
80104538:	83 ec 28             	sub    $0x28,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010453b:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010453e:	ba 00 00 00 00       	mov    $0x0,%edx
80104543:	b8 00 00 00 00       	mov    $0x0,%eax
80104548:	e8 33 fd ff ff       	call   80104280 <argfd>
8010454d:	85 c0                	test   %eax,%eax
8010454f:	78 50                	js     801045a1 <sys_read+0x6c>
80104551:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104554:	89 44 24 04          	mov    %eax,0x4(%esp)
80104558:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010455f:	e8 e7 fb ff ff       	call   8010414b <argint>
80104564:	85 c0                	test   %eax,%eax
80104566:	78 40                	js     801045a8 <sys_read+0x73>
80104568:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010456b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010456f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104572:	89 44 24 04          	mov    %eax,0x4(%esp)
80104576:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010457d:	e8 f4 fb ff ff       	call   80104176 <argptr>
80104582:	85 c0                	test   %eax,%eax
80104584:	78 29                	js     801045af <sys_read+0x7a>
  return fileread(f, p, n);
80104586:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104589:	89 44 24 08          	mov    %eax,0x8(%esp)
8010458d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104590:	89 44 24 04          	mov    %eax,0x4(%esp)
80104594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104597:	89 04 24             	mov    %eax,(%esp)
8010459a:	e8 76 c8 ff ff       	call   80100e15 <fileread>
8010459f:	eb 13                	jmp    801045b4 <sys_read+0x7f>
    return -1;
801045a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045a6:	eb 0c                	jmp    801045b4 <sys_read+0x7f>
801045a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ad:	eb 05                	jmp    801045b4 <sys_read+0x7f>
801045af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801045b4:	c9                   	leave  
801045b5:	c3                   	ret    

801045b6 <sys_write>:
{
801045b6:	55                   	push   %ebp
801045b7:	89 e5                	mov    %esp,%ebp
801045b9:	83 ec 28             	sub    $0x28,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801045bc:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801045bf:	ba 00 00 00 00       	mov    $0x0,%edx
801045c4:	b8 00 00 00 00       	mov    $0x0,%eax
801045c9:	e8 b2 fc ff ff       	call   80104280 <argfd>
801045ce:	85 c0                	test   %eax,%eax
801045d0:	78 50                	js     80104622 <sys_write+0x6c>
801045d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801045d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801045d9:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801045e0:	e8 66 fb ff ff       	call   8010414b <argint>
801045e5:	85 c0                	test   %eax,%eax
801045e7:	78 40                	js     80104629 <sys_write+0x73>
801045e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045ec:	89 44 24 08          	mov    %eax,0x8(%esp)
801045f0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801045f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801045f7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801045fe:	e8 73 fb ff ff       	call   80104176 <argptr>
80104603:	85 c0                	test   %eax,%eax
80104605:	78 29                	js     80104630 <sys_write+0x7a>
  return filewrite(f, p, n);
80104607:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010460a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010460e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104611:	89 44 24 04          	mov    %eax,0x4(%esp)
80104615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104618:	89 04 24             	mov    %eax,(%esp)
8010461b:	e8 88 c8 ff ff       	call   80100ea8 <filewrite>
80104620:	eb 13                	jmp    80104635 <sys_write+0x7f>
    return -1;
80104622:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104627:	eb 0c                	jmp    80104635 <sys_write+0x7f>
80104629:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010462e:	eb 05                	jmp    80104635 <sys_write+0x7f>
80104630:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104635:	c9                   	leave  
80104636:	c3                   	ret    

80104637 <sys_close>:
{
80104637:	55                   	push   %ebp
80104638:	89 e5                	mov    %esp,%ebp
8010463a:	83 ec 28             	sub    $0x28,%esp
  if(argfd(0, &fd, &f) < 0)
8010463d:	8d 4d f0             	lea    -0x10(%ebp),%ecx
80104640:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104643:	b8 00 00 00 00       	mov    $0x0,%eax
80104648:	e8 33 fc ff ff       	call   80104280 <argfd>
8010464d:	85 c0                	test   %eax,%eax
8010464f:	78 22                	js     80104673 <sys_close+0x3c>
  myproc()->ofile[fd] = 0;
80104651:	e8 67 ec ff ff       	call   801032bd <myproc>
80104656:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104659:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
80104660:	00 
  fileclose(f);
80104661:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104664:	89 04 24             	mov    %eax,(%esp)
80104667:	e8 ac c6 ff ff       	call   80100d18 <fileclose>
  return 0;
8010466c:	b8 00 00 00 00       	mov    $0x0,%eax
80104671:	eb 05                	jmp    80104678 <sys_close+0x41>
    return -1;
80104673:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104678:	c9                   	leave  
80104679:	c3                   	ret    

8010467a <sys_fstat>:
{
8010467a:	55                   	push   %ebp
8010467b:	89 e5                	mov    %esp,%ebp
8010467d:	83 ec 28             	sub    $0x28,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104680:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104683:	ba 00 00 00 00       	mov    $0x0,%edx
80104688:	b8 00 00 00 00       	mov    $0x0,%eax
8010468d:	e8 ee fb ff ff       	call   80104280 <argfd>
80104692:	85 c0                	test   %eax,%eax
80104694:	78 33                	js     801046c9 <sys_fstat+0x4f>
80104696:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010469d:	00 
8010469e:	8d 45 f0             	lea    -0x10(%ebp),%eax
801046a1:	89 44 24 04          	mov    %eax,0x4(%esp)
801046a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801046ac:	e8 c5 fa ff ff       	call   80104176 <argptr>
801046b1:	85 c0                	test   %eax,%eax
801046b3:	78 1b                	js     801046d0 <sys_fstat+0x56>
  return filestat(f, st);
801046b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801046bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046bf:	89 04 24             	mov    %eax,(%esp)
801046c2:	e8 05 c7 ff ff       	call   80100dcc <filestat>
801046c7:	eb 0c                	jmp    801046d5 <sys_fstat+0x5b>
    return -1;
801046c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046ce:	eb 05                	jmp    801046d5 <sys_fstat+0x5b>
801046d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801046d5:	c9                   	leave  
801046d6:	c3                   	ret    

801046d7 <sys_link>:
{
801046d7:	55                   	push   %ebp
801046d8:	89 e5                	mov    %esp,%ebp
801046da:	56                   	push   %esi
801046db:	53                   	push   %ebx
801046dc:	83 ec 30             	sub    $0x30,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801046df:	8d 45 e0             	lea    -0x20(%ebp),%eax
801046e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801046e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801046ed:	e8 ec fa ff ff       	call   801041de <argstr>
801046f2:	85 c0                	test   %eax,%eax
801046f4:	0f 88 0d 01 00 00    	js     80104807 <sys_link+0x130>
801046fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801046fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80104701:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104708:	e8 d1 fa ff ff       	call   801041de <argstr>
8010470d:	85 c0                	test   %eax,%eax
8010470f:	0f 88 f9 00 00 00    	js     8010480e <sys_link+0x137>
  begin_op();
80104715:	e8 39 e1 ff ff       	call   80102853 <begin_op>
  if((ip = namei(old)) == 0){
8010471a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010471d:	89 04 24             	mov    %eax,(%esp)
80104720:	e8 5d d5 ff ff       	call   80101c82 <namei>
80104725:	89 c3                	mov    %eax,%ebx
80104727:	85 c0                	test   %eax,%eax
80104729:	75 0f                	jne    8010473a <sys_link+0x63>
    end_op();
8010472b:	e8 96 e1 ff ff       	call   801028c6 <end_op>
    return -1;
80104730:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104735:	e9 d9 00 00 00       	jmp    80104813 <sys_link+0x13c>
  ilock(ip);
8010473a:	89 04 24             	mov    %eax,(%esp)
8010473d:	e8 bf ce ff ff       	call   80101601 <ilock>
  if(ip->type == T_DIR){
80104742:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104747:	75 17                	jne    80104760 <sys_link+0x89>
    iunlockput(ip);
80104749:	89 1c 24             	mov    %ebx,(%esp)
8010474c:	e8 42 d0 ff ff       	call   80101793 <iunlockput>
    end_op();
80104751:	e8 70 e1 ff ff       	call   801028c6 <end_op>
    return -1;
80104756:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010475b:	e9 b3 00 00 00       	jmp    80104813 <sys_link+0x13c>
  ip->nlink++;
80104760:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
  iupdate(ip);
80104765:	89 1c 24             	mov    %ebx,(%esp)
80104768:	e8 37 cd ff ff       	call   801014a4 <iupdate>
  iunlock(ip);
8010476d:	89 1c 24             	mov    %ebx,(%esp)
80104770:	e8 53 cf ff ff       	call   801016c8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104775:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104778:	89 44 24 04          	mov    %eax,0x4(%esp)
8010477c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010477f:	89 04 24             	mov    %eax,(%esp)
80104782:	e8 13 d5 ff ff       	call   80101c9a <nameiparent>
80104787:	89 c6                	mov    %eax,%esi
80104789:	85 c0                	test   %eax,%eax
8010478b:	74 51                	je     801047de <sys_link+0x107>
  ilock(dp);
8010478d:	89 04 24             	mov    %eax,(%esp)
80104790:	e8 6c ce ff ff       	call   80101601 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104795:	8b 03                	mov    (%ebx),%eax
80104797:	39 06                	cmp    %eax,(%esi)
80104799:	75 1a                	jne    801047b5 <sys_link+0xde>
8010479b:	8b 43 04             	mov    0x4(%ebx),%eax
8010479e:	89 44 24 08          	mov    %eax,0x8(%esp)
801047a2:	8d 45 ea             	lea    -0x16(%ebp),%eax
801047a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801047a9:	89 34 24             	mov    %esi,(%esp)
801047ac:	e8 fa d3 ff ff       	call   80101bab <dirlink>
801047b1:	85 c0                	test   %eax,%eax
801047b3:	79 0d                	jns    801047c2 <sys_link+0xeb>
    iunlockput(dp);
801047b5:	89 34 24             	mov    %esi,(%esp)
801047b8:	e8 d6 cf ff ff       	call   80101793 <iunlockput>
801047bd:	8d 76 00             	lea    0x0(%esi),%esi
    goto bad;
801047c0:	eb 1c                	jmp    801047de <sys_link+0x107>
  iunlockput(dp);
801047c2:	89 34 24             	mov    %esi,(%esp)
801047c5:	e8 c9 cf ff ff       	call   80101793 <iunlockput>
  iput(ip);
801047ca:	89 1c 24             	mov    %ebx,(%esp)
801047cd:	e8 35 cf ff ff       	call   80101707 <iput>
  end_op();
801047d2:	e8 ef e0 ff ff       	call   801028c6 <end_op>
  return 0;
801047d7:	b8 00 00 00 00       	mov    $0x0,%eax
801047dc:	eb 35                	jmp    80104813 <sys_link+0x13c>
  ilock(ip);
801047de:	89 1c 24             	mov    %ebx,(%esp)
801047e1:	e8 1b ce ff ff       	call   80101601 <ilock>
  ip->nlink--;
801047e6:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
801047eb:	89 1c 24             	mov    %ebx,(%esp)
801047ee:	e8 b1 cc ff ff       	call   801014a4 <iupdate>
  iunlockput(ip);
801047f3:	89 1c 24             	mov    %ebx,(%esp)
801047f6:	e8 98 cf ff ff       	call   80101793 <iunlockput>
  end_op();
801047fb:	e8 c6 e0 ff ff       	call   801028c6 <end_op>
  return -1;
80104800:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104805:	eb 0c                	jmp    80104813 <sys_link+0x13c>
    return -1;
80104807:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010480c:	eb 05                	jmp    80104813 <sys_link+0x13c>
8010480e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104813:	83 c4 30             	add    $0x30,%esp
80104816:	5b                   	pop    %ebx
80104817:	5e                   	pop    %esi
80104818:	5d                   	pop    %ebp
80104819:	c3                   	ret    

8010481a <sys_unlink>:
{
8010481a:	55                   	push   %ebp
8010481b:	89 e5                	mov    %esp,%ebp
8010481d:	57                   	push   %edi
8010481e:	56                   	push   %esi
8010481f:	53                   	push   %ebx
80104820:	83 ec 4c             	sub    $0x4c,%esp
  if(argstr(0, &path) < 0)
80104823:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104826:	89 44 24 04          	mov    %eax,0x4(%esp)
8010482a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104831:	e8 a8 f9 ff ff       	call   801041de <argstr>
80104836:	85 c0                	test   %eax,%eax
80104838:	0f 88 5f 01 00 00    	js     8010499d <sys_unlink+0x183>
  begin_op();
8010483e:	e8 10 e0 ff ff       	call   80102853 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80104843:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104846:	89 44 24 04          	mov    %eax,0x4(%esp)
8010484a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
8010484d:	89 04 24             	mov    %eax,(%esp)
80104850:	e8 45 d4 ff ff       	call   80101c9a <nameiparent>
80104855:	89 c6                	mov    %eax,%esi
80104857:	85 c0                	test   %eax,%eax
80104859:	75 0f                	jne    8010486a <sys_unlink+0x50>
    end_op();
8010485b:	e8 66 e0 ff ff       	call   801028c6 <end_op>
    return -1;
80104860:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104865:	e9 38 01 00 00       	jmp    801049a2 <sys_unlink+0x188>
  ilock(dp);
8010486a:	89 04 24             	mov    %eax,(%esp)
8010486d:	e8 8f cd ff ff       	call   80101601 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104872:	c7 44 24 04 2e 72 10 	movl   $0x8010722e,0x4(%esp)
80104879:	80 
8010487a:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010487d:	89 04 24             	mov    %eax,(%esp)
80104880:	e8 91 d1 ff ff       	call   80101a16 <namecmp>
80104885:	85 c0                	test   %eax,%eax
80104887:	0f 84 fc 00 00 00    	je     80104989 <sys_unlink+0x16f>
8010488d:	c7 44 24 04 2d 72 10 	movl   $0x8010722d,0x4(%esp)
80104894:	80 
80104895:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104898:	89 04 24             	mov    %eax,(%esp)
8010489b:	e8 76 d1 ff ff       	call   80101a16 <namecmp>
801048a0:	85 c0                	test   %eax,%eax
801048a2:	0f 84 e1 00 00 00    	je     80104989 <sys_unlink+0x16f>
  if((ip = dirlookup(dp, name, &off)) == 0)
801048a8:	8d 45 c0             	lea    -0x40(%ebp),%eax
801048ab:	89 44 24 08          	mov    %eax,0x8(%esp)
801048af:	8d 45 ca             	lea    -0x36(%ebp),%eax
801048b2:	89 44 24 04          	mov    %eax,0x4(%esp)
801048b6:	89 34 24             	mov    %esi,(%esp)
801048b9:	e8 7a d1 ff ff       	call   80101a38 <dirlookup>
801048be:	89 c3                	mov    %eax,%ebx
801048c0:	85 c0                	test   %eax,%eax
801048c2:	0f 84 c1 00 00 00    	je     80104989 <sys_unlink+0x16f>
  ilock(ip);
801048c8:	89 04 24             	mov    %eax,(%esp)
801048cb:	e8 31 cd ff ff       	call   80101601 <ilock>
  if(ip->nlink < 1)
801048d0:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801048d5:	7f 0c                	jg     801048e3 <sys_unlink+0xc9>
    panic("unlink: nlink < 1");
801048d7:	c7 04 24 4c 72 10 80 	movl   $0x8010724c,(%esp)
801048de:	e8 42 ba ff ff       	call   80100325 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801048e3:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801048e8:	75 1b                	jne    80104905 <sys_unlink+0xeb>
801048ea:	89 d8                	mov    %ebx,%eax
801048ec:	e8 2f fa ff ff       	call   80104320 <isdirempty>
801048f1:	85 c0                	test   %eax,%eax
801048f3:	75 10                	jne    80104905 <sys_unlink+0xeb>
    iunlockput(ip);
801048f5:	89 1c 24             	mov    %ebx,(%esp)
801048f8:	e8 96 ce ff ff       	call   80101793 <iunlockput>
801048fd:	8d 76 00             	lea    0x0(%esi),%esi
    goto bad;
80104900:	e9 84 00 00 00       	jmp    80104989 <sys_unlink+0x16f>
  memset(&de, 0, sizeof(de));
80104905:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010490c:	00 
8010490d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104914:	00 
80104915:	8d 7d d8             	lea    -0x28(%ebp),%edi
80104918:	89 3c 24             	mov    %edi,(%esp)
8010491b:	e8 d0 f5 ff ff       	call   80103ef0 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104920:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80104927:	00 
80104928:	8b 45 c0             	mov    -0x40(%ebp),%eax
8010492b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010492f:	89 7c 24 04          	mov    %edi,0x4(%esp)
80104933:	89 34 24             	mov    %esi,(%esp)
80104936:	e8 ab cf ff ff       	call   801018e6 <writei>
8010493b:	83 f8 10             	cmp    $0x10,%eax
8010493e:	74 0c                	je     8010494c <sys_unlink+0x132>
    panic("unlink: writei");
80104940:	c7 04 24 5e 72 10 80 	movl   $0x8010725e,(%esp)
80104947:	e8 d9 b9 ff ff       	call   80100325 <panic>
  if(ip->type == T_DIR){
8010494c:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104951:	75 0d                	jne    80104960 <sys_unlink+0x146>
    dp->nlink--;
80104953:	66 83 6e 56 01       	subw   $0x1,0x56(%esi)
    iupdate(dp);
80104958:	89 34 24             	mov    %esi,(%esp)
8010495b:	e8 44 cb ff ff       	call   801014a4 <iupdate>
  iunlockput(dp);
80104960:	89 34 24             	mov    %esi,(%esp)
80104963:	e8 2b ce ff ff       	call   80101793 <iunlockput>
  ip->nlink--;
80104968:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
8010496d:	89 1c 24             	mov    %ebx,(%esp)
80104970:	e8 2f cb ff ff       	call   801014a4 <iupdate>
  iunlockput(ip);
80104975:	89 1c 24             	mov    %ebx,(%esp)
80104978:	e8 16 ce ff ff       	call   80101793 <iunlockput>
  end_op();
8010497d:	e8 44 df ff ff       	call   801028c6 <end_op>
  return 0;
80104982:	b8 00 00 00 00       	mov    $0x0,%eax
80104987:	eb 19                	jmp    801049a2 <sys_unlink+0x188>
  iunlockput(dp);
80104989:	89 34 24             	mov    %esi,(%esp)
8010498c:	e8 02 ce ff ff       	call   80101793 <iunlockput>
  end_op();
80104991:	e8 30 df ff ff       	call   801028c6 <end_op>
  return -1;
80104996:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010499b:	eb 05                	jmp    801049a2 <sys_unlink+0x188>
    return -1;
8010499d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801049a2:	83 c4 4c             	add    $0x4c,%esp
801049a5:	5b                   	pop    %ebx
801049a6:	5e                   	pop    %esi
801049a7:	5f                   	pop    %edi
801049a8:	5d                   	pop    %ebp
801049a9:	c3                   	ret    

801049aa <sys_open>:

int
sys_open(void)
{
801049aa:	55                   	push   %ebp
801049ab:	89 e5                	mov    %esp,%ebp
801049ad:	57                   	push   %edi
801049ae:	56                   	push   %esi
801049af:	53                   	push   %ebx
801049b0:	83 ec 2c             	sub    $0x2c,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801049b3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801049b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801049ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801049c1:	e8 18 f8 ff ff       	call   801041de <argstr>
801049c6:	85 c0                	test   %eax,%eax
801049c8:	0f 88 03 01 00 00    	js     80104ad1 <sys_open+0x127>
801049ce:	8d 45 e0             	lea    -0x20(%ebp),%eax
801049d1:	89 44 24 04          	mov    %eax,0x4(%esp)
801049d5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801049dc:	e8 6a f7 ff ff       	call   8010414b <argint>
801049e1:	85 c0                	test   %eax,%eax
801049e3:	0f 88 ef 00 00 00    	js     80104ad8 <sys_open+0x12e>
    return -1;

  begin_op();
801049e9:	e8 65 de ff ff       	call   80102853 <begin_op>

  if(omode & O_CREATE){
801049ee:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
801049f2:	74 2e                	je     80104a22 <sys_open+0x78>
    ip = create(path, T_FILE, 0, 0);
801049f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801049fb:	b9 00 00 00 00       	mov    $0x0,%ecx
80104a00:	ba 02 00 00 00       	mov    $0x2,%edx
80104a05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104a08:	e8 76 f9 ff ff       	call   80104383 <create>
80104a0d:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80104a0f:	85 c0                	test   %eax,%eax
80104a11:	75 58                	jne    80104a6b <sys_open+0xc1>
      end_op();
80104a13:	e8 ae de ff ff       	call   801028c6 <end_op>
      return -1;
80104a18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a1d:	e9 bb 00 00 00       	jmp    80104add <sys_open+0x133>
    }
  } else {
    if((ip = namei(path)) == 0){
80104a22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104a25:	89 04 24             	mov    %eax,(%esp)
80104a28:	e8 55 d2 ff ff       	call   80101c82 <namei>
80104a2d:	89 c6                	mov    %eax,%esi
80104a2f:	85 c0                	test   %eax,%eax
80104a31:	75 0f                	jne    80104a42 <sys_open+0x98>
      end_op();
80104a33:	e8 8e de ff ff       	call   801028c6 <end_op>
      return -1;
80104a38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a3d:	e9 9b 00 00 00       	jmp    80104add <sys_open+0x133>
    }
    ilock(ip);
80104a42:	89 04 24             	mov    %eax,(%esp)
80104a45:	e8 b7 cb ff ff       	call   80101601 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104a4a:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104a4f:	75 1a                	jne    80104a6b <sys_open+0xc1>
80104a51:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104a55:	74 14                	je     80104a6b <sys_open+0xc1>
      iunlockput(ip);
80104a57:	89 34 24             	mov    %esi,(%esp)
80104a5a:	e8 34 cd ff ff       	call   80101793 <iunlockput>
      end_op();
80104a5f:	e8 62 de ff ff       	call   801028c6 <end_op>
      return -1;
80104a64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a69:	eb 72                	jmp    80104add <sys_open+0x133>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80104a6b:	e8 0c c2 ff ff       	call   80100c7c <filealloc>
80104a70:	89 c3                	mov    %eax,%ebx
80104a72:	85 c0                	test   %eax,%eax
80104a74:	74 0b                	je     80104a81 <sys_open+0xd7>
80104a76:	e8 6e f8 ff ff       	call   801042e9 <fdalloc>
80104a7b:	89 c7                	mov    %eax,%edi
80104a7d:	85 c0                	test   %eax,%eax
80104a7f:	79 20                	jns    80104aa1 <sys_open+0xf7>
    if(f)
80104a81:	85 db                	test   %ebx,%ebx
80104a83:	74 08                	je     80104a8d <sys_open+0xe3>
      fileclose(f);
80104a85:	89 1c 24             	mov    %ebx,(%esp)
80104a88:	e8 8b c2 ff ff       	call   80100d18 <fileclose>
    iunlockput(ip);
80104a8d:	89 34 24             	mov    %esi,(%esp)
80104a90:	e8 fe cc ff ff       	call   80101793 <iunlockput>
    end_op();
80104a95:	e8 2c de ff ff       	call   801028c6 <end_op>
    return -1;
80104a9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a9f:	eb 3c                	jmp    80104add <sys_open+0x133>
  }
  iunlock(ip);
80104aa1:	89 34 24             	mov    %esi,(%esp)
80104aa4:	e8 1f cc ff ff       	call   801016c8 <iunlock>
  end_op();
80104aa9:	e8 18 de ff ff       	call   801028c6 <end_op>

  f->type = FD_INODE;
80104aae:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104ab4:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104ab7:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104abe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ac1:	a8 01                	test   $0x1,%al
80104ac3:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104ac7:	a8 03                	test   $0x3,%al
80104ac9:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
80104acd:	89 f8                	mov    %edi,%eax
80104acf:	eb 0c                	jmp    80104add <sys_open+0x133>
    return -1;
80104ad1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ad6:	eb 05                	jmp    80104add <sys_open+0x133>
80104ad8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104add:	83 c4 2c             	add    $0x2c,%esp
80104ae0:	5b                   	pop    %ebx
80104ae1:	5e                   	pop    %esi
80104ae2:	5f                   	pop    %edi
80104ae3:	5d                   	pop    %ebp
80104ae4:	c3                   	ret    

80104ae5 <sys_mkdir>:

int
sys_mkdir(void)
{
80104ae5:	55                   	push   %ebp
80104ae6:	89 e5                	mov    %esp,%ebp
80104ae8:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104aeb:	e8 63 dd ff ff       	call   80102853 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104af0:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104af3:	89 44 24 04          	mov    %eax,0x4(%esp)
80104af7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104afe:	e8 db f6 ff ff       	call   801041de <argstr>
80104b03:	85 c0                	test   %eax,%eax
80104b05:	78 1d                	js     80104b24 <sys_mkdir+0x3f>
80104b07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104b0e:	b9 00 00 00 00       	mov    $0x0,%ecx
80104b13:	ba 01 00 00 00       	mov    $0x1,%edx
80104b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b1b:	e8 63 f8 ff ff       	call   80104383 <create>
80104b20:	85 c0                	test   %eax,%eax
80104b22:	75 0c                	jne    80104b30 <sys_mkdir+0x4b>
    end_op();
80104b24:	e8 9d dd ff ff       	call   801028c6 <end_op>
    return -1;
80104b29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b2e:	eb 12                	jmp    80104b42 <sys_mkdir+0x5d>
  }
  iunlockput(ip);
80104b30:	89 04 24             	mov    %eax,(%esp)
80104b33:	e8 5b cc ff ff       	call   80101793 <iunlockput>
  end_op();
80104b38:	e8 89 dd ff ff       	call   801028c6 <end_op>
  return 0;
80104b3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b42:	c9                   	leave  
80104b43:	c3                   	ret    

80104b44 <sys_mknod>:

int
sys_mknod(void)
{
80104b44:	55                   	push   %ebp
80104b45:	89 e5                	mov    %esp,%ebp
80104b47:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104b4a:	e8 04 dd ff ff       	call   80102853 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104b4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b52:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b56:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104b5d:	e8 7c f6 ff ff       	call   801041de <argstr>
80104b62:	85 c0                	test   %eax,%eax
80104b64:	78 4a                	js     80104bb0 <sys_mknod+0x6c>
     argint(1, &major) < 0 ||
80104b66:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104b69:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b6d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104b74:	e8 d2 f5 ff ff       	call   8010414b <argint>
  if((argstr(0, &path)) < 0 ||
80104b79:	85 c0                	test   %eax,%eax
80104b7b:	78 33                	js     80104bb0 <sys_mknod+0x6c>
     argint(2, &minor) < 0 ||
80104b7d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104b80:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b84:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80104b8b:	e8 bb f5 ff ff       	call   8010414b <argint>
     argint(1, &major) < 0 ||
80104b90:	85 c0                	test   %eax,%eax
80104b92:	78 1c                	js     80104bb0 <sys_mknod+0x6c>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104b94:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104b98:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80104b9c:	89 04 24             	mov    %eax,(%esp)
80104b9f:	ba 03 00 00 00       	mov    $0x3,%edx
80104ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba7:	e8 d7 f7 ff ff       	call   80104383 <create>
80104bac:	85 c0                	test   %eax,%eax
80104bae:	75 0c                	jne    80104bbc <sys_mknod+0x78>
    end_op();
80104bb0:	e8 11 dd ff ff       	call   801028c6 <end_op>
    return -1;
80104bb5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bba:	eb 12                	jmp    80104bce <sys_mknod+0x8a>
  }
  iunlockput(ip);
80104bbc:	89 04 24             	mov    %eax,(%esp)
80104bbf:	e8 cf cb ff ff       	call   80101793 <iunlockput>
  end_op();
80104bc4:	e8 fd dc ff ff       	call   801028c6 <end_op>
  return 0;
80104bc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104bce:	c9                   	leave  
80104bcf:	c3                   	ret    

80104bd0 <sys_chdir>:

int
sys_chdir(void)
{
80104bd0:	55                   	push   %ebp
80104bd1:	89 e5                	mov    %esp,%ebp
80104bd3:	56                   	push   %esi
80104bd4:	53                   	push   %ebx
80104bd5:	83 ec 20             	sub    $0x20,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104bd8:	e8 e0 e6 ff ff       	call   801032bd <myproc>
80104bdd:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104bdf:	e8 6f dc ff ff       	call   80102853 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104be4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104be7:	89 44 24 04          	mov    %eax,0x4(%esp)
80104beb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104bf2:	e8 e7 f5 ff ff       	call   801041de <argstr>
80104bf7:	85 c0                	test   %eax,%eax
80104bf9:	78 11                	js     80104c0c <sys_chdir+0x3c>
80104bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bfe:	89 04 24             	mov    %eax,(%esp)
80104c01:	e8 7c d0 ff ff       	call   80101c82 <namei>
80104c06:	89 c3                	mov    %eax,%ebx
80104c08:	85 c0                	test   %eax,%eax
80104c0a:	75 0c                	jne    80104c18 <sys_chdir+0x48>
    end_op();
80104c0c:	e8 b5 dc ff ff       	call   801028c6 <end_op>
    return -1;
80104c11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c16:	eb 43                	jmp    80104c5b <sys_chdir+0x8b>
  }
  ilock(ip);
80104c18:	89 04 24             	mov    %eax,(%esp)
80104c1b:	e8 e1 c9 ff ff       	call   80101601 <ilock>
  if(ip->type != T_DIR){
80104c20:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104c25:	74 14                	je     80104c3b <sys_chdir+0x6b>
    iunlockput(ip);
80104c27:	89 1c 24             	mov    %ebx,(%esp)
80104c2a:	e8 64 cb ff ff       	call   80101793 <iunlockput>
    end_op();
80104c2f:	e8 92 dc ff ff       	call   801028c6 <end_op>
    return -1;
80104c34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c39:	eb 20                	jmp    80104c5b <sys_chdir+0x8b>
  }
  iunlock(ip);
80104c3b:	89 1c 24             	mov    %ebx,(%esp)
80104c3e:	e8 85 ca ff ff       	call   801016c8 <iunlock>
  iput(curproc->cwd);
80104c43:	8b 46 68             	mov    0x68(%esi),%eax
80104c46:	89 04 24             	mov    %eax,(%esp)
80104c49:	e8 b9 ca ff ff       	call   80101707 <iput>
  end_op();
80104c4e:	e8 73 dc ff ff       	call   801028c6 <end_op>
  curproc->cwd = ip;
80104c53:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104c56:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c5b:	83 c4 20             	add    $0x20,%esp
80104c5e:	5b                   	pop    %ebx
80104c5f:	5e                   	pop    %esi
80104c60:	5d                   	pop    %ebp
80104c61:	c3                   	ret    

80104c62 <sys_exec>:

int
sys_exec(void)
{
80104c62:	55                   	push   %ebp
80104c63:	89 e5                	mov    %esp,%ebp
80104c65:	56                   	push   %esi
80104c66:	53                   	push   %ebx
80104c67:	81 ec a0 00 00 00    	sub    $0xa0,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104c6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c70:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104c7b:	e8 5e f5 ff ff       	call   801041de <argstr>
80104c80:	85 c0                	test   %eax,%eax
80104c82:	0f 88 ad 00 00 00    	js     80104d35 <sys_exec+0xd3>
80104c88:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104c8e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c92:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104c99:	e8 ad f4 ff ff       	call   8010414b <argint>
80104c9e:	85 c0                	test   %eax,%eax
80104ca0:	0f 88 96 00 00 00    	js     80104d3c <sys_exec+0xda>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104ca6:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80104cad:	00 
80104cae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104cb5:	00 
80104cb6:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104cbc:	89 04 24             	mov    %eax,(%esp)
80104cbf:	e8 2c f2 ff ff       	call   80103ef0 <memset>
  for(i=0;; i++){
80104cc4:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104cc9:	8d b5 6c ff ff ff    	lea    -0x94(%ebp),%esi
    if(i >= NELEM(argv))
80104ccf:	83 fb 1f             	cmp    $0x1f,%ebx
80104cd2:	77 6f                	ja     80104d43 <sys_exec+0xe1>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104cd4:	89 74 24 04          	mov    %esi,0x4(%esp)
80104cd8:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104cde:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104ce1:	89 04 24             	mov    %eax,(%esp)
80104ce4:	e8 e6 f3 ff ff       	call   801040cf <fetchint>
80104ce9:	85 c0                	test   %eax,%eax
80104ceb:	78 5d                	js     80104d4a <sys_exec+0xe8>
      return -1;
    if(uarg == 0){
80104ced:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104cf3:	85 c0                	test   %eax,%eax
80104cf5:	75 22                	jne    80104d19 <sys_exec+0xb7>
      argv[i] = 0;
80104cf7:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104cfe:	00 00 00 00 
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80104d02:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104d08:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d0f:	89 04 24             	mov    %eax,(%esp)
80104d12:	e8 74 bb ff ff       	call   8010088b <exec>
80104d17:	eb 3d                	jmp    80104d56 <sys_exec+0xf4>
    if(fetchstr(uarg, &argv[i]) < 0)
80104d19:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104d20:	89 54 24 04          	mov    %edx,0x4(%esp)
80104d24:	89 04 24             	mov    %eax,(%esp)
80104d27:	e8 df f3 ff ff       	call   8010410b <fetchstr>
80104d2c:	85 c0                	test   %eax,%eax
80104d2e:	78 21                	js     80104d51 <sys_exec+0xef>
  for(i=0;; i++){
80104d30:	83 c3 01             	add    $0x1,%ebx
  }
80104d33:	eb 9a                	jmp    80104ccf <sys_exec+0x6d>
    return -1;
80104d35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d3a:	eb 1a                	jmp    80104d56 <sys_exec+0xf4>
80104d3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d41:	eb 13                	jmp    80104d56 <sys_exec+0xf4>
      return -1;
80104d43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d48:	eb 0c                	jmp    80104d56 <sys_exec+0xf4>
      return -1;
80104d4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d4f:	eb 05                	jmp    80104d56 <sys_exec+0xf4>
      return -1;
80104d51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d56:	81 c4 a0 00 00 00    	add    $0xa0,%esp
80104d5c:	5b                   	pop    %ebx
80104d5d:	5e                   	pop    %esi
80104d5e:	5d                   	pop    %ebp
80104d5f:	c3                   	ret    

80104d60 <sys_pipe>:

int
sys_pipe(void)
{
80104d60:	55                   	push   %ebp
80104d61:	89 e5                	mov    %esp,%ebp
80104d63:	53                   	push   %ebx
80104d64:	83 ec 24             	sub    $0x24,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104d67:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80104d6e:	00 
80104d6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d72:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d76:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104d7d:	e8 f4 f3 ff ff       	call   80104176 <argptr>
80104d82:	85 c0                	test   %eax,%eax
80104d84:	78 76                	js     80104dfc <sys_pipe+0x9c>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104d86:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104d89:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d8d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104d90:	89 04 24             	mov    %eax,(%esp)
80104d93:	e8 78 e0 ff ff       	call   80102e10 <pipealloc>
80104d98:	85 c0                	test   %eax,%eax
80104d9a:	78 67                	js     80104e03 <sys_pipe+0xa3>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104d9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d9f:	e8 45 f5 ff ff       	call   801042e9 <fdalloc>
80104da4:	89 c3                	mov    %eax,%ebx
80104da6:	85 c0                	test   %eax,%eax
80104da8:	78 0c                	js     80104db6 <sys_pipe+0x56>
80104daa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104dad:	e8 37 f5 ff ff       	call   801042e9 <fdalloc>
80104db2:	85 c0                	test   %eax,%eax
80104db4:	79 34                	jns    80104dea <sys_pipe+0x8a>
    if(fd0 >= 0)
80104db6:	85 db                	test   %ebx,%ebx
80104db8:	78 13                	js     80104dcd <sys_pipe+0x6d>
80104dba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      myproc()->ofile[fd0] = 0;
80104dc0:	e8 f8 e4 ff ff       	call   801032bd <myproc>
80104dc5:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104dcc:	00 
    fileclose(rf);
80104dcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dd0:	89 04 24             	mov    %eax,(%esp)
80104dd3:	e8 40 bf ff ff       	call   80100d18 <fileclose>
    fileclose(wf);
80104dd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ddb:	89 04 24             	mov    %eax,(%esp)
80104dde:	e8 35 bf ff ff       	call   80100d18 <fileclose>
    return -1;
80104de3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104de8:	eb 1e                	jmp    80104e08 <sys_pipe+0xa8>
  }
  fd[0] = fd0;
80104dea:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ded:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104def:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104df2:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104df5:	b8 00 00 00 00       	mov    $0x0,%eax
80104dfa:	eb 0c                	jmp    80104e08 <sys_pipe+0xa8>
    return -1;
80104dfc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e01:	eb 05                	jmp    80104e08 <sys_pipe+0xa8>
    return -1;
80104e03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104e08:	83 c4 24             	add    $0x24,%esp
80104e0b:	5b                   	pop    %ebx
80104e0c:	5d                   	pop    %ebp
80104e0d:	c3                   	ret    

80104e0e <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104e0e:	55                   	push   %ebp
80104e0f:	89 e5                	mov    %esp,%ebp
80104e11:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104e14:	e8 17 e6 ff ff       	call   80103430 <fork>
}
80104e19:	c9                   	leave  
80104e1a:	c3                   	ret    

80104e1b <sys_exit>:

int
sys_exit(void)
{
80104e1b:	55                   	push   %ebp
80104e1c:	89 e5                	mov    %esp,%ebp
80104e1e:	83 ec 08             	sub    $0x8,%esp
  exit();
80104e21:	e8 32 e8 ff ff       	call   80103658 <exit>
  return 0;  // not reached
}
80104e26:	b8 00 00 00 00       	mov    $0x0,%eax
80104e2b:	c9                   	leave  
80104e2c:	c3                   	ret    

80104e2d <sys_wait>:

int
sys_wait(void)
{
80104e2d:	55                   	push   %ebp
80104e2e:	89 e5                	mov    %esp,%ebp
80104e30:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104e33:	e8 97 e9 ff ff       	call   801037cf <wait>
}
80104e38:	c9                   	leave  
80104e39:	c3                   	ret    

80104e3a <sys_kill>:

int
sys_kill(void)
{
80104e3a:	55                   	push   %ebp
80104e3b:	89 e5                	mov    %esp,%ebp
80104e3d:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104e40:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e43:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e47:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104e4e:	e8 f8 f2 ff ff       	call   8010414b <argint>
80104e53:	85 c0                	test   %eax,%eax
80104e55:	78 0d                	js     80104e64 <sys_kill+0x2a>
    return -1;
  return kill(pid);
80104e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e5a:	89 04 24             	mov    %eax,(%esp)
80104e5d:	e8 60 ea ff ff       	call   801038c2 <kill>
80104e62:	eb 05                	jmp    80104e69 <sys_kill+0x2f>
    return -1;
80104e64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104e69:	c9                   	leave  
80104e6a:	c3                   	ret    

80104e6b <sys_getpid>:

int
sys_getpid(void)
{
80104e6b:	55                   	push   %ebp
80104e6c:	89 e5                	mov    %esp,%ebp
80104e6e:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104e71:	e8 47 e4 ff ff       	call   801032bd <myproc>
80104e76:	8b 40 10             	mov    0x10(%eax),%eax
}
80104e79:	c9                   	leave  
80104e7a:	c3                   	ret    

80104e7b <sys_sbrk>:

int
sys_sbrk(void)
{
80104e7b:	55                   	push   %ebp
80104e7c:	89 e5                	mov    %esp,%ebp
80104e7e:	53                   	push   %ebx
80104e7f:	83 ec 24             	sub    $0x24,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104e82:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e85:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104e90:	e8 b6 f2 ff ff       	call   8010414b <argint>
80104e95:	85 c0                	test   %eax,%eax
80104e97:	78 1d                	js     80104eb6 <sys_sbrk+0x3b>
    return -1;
  addr = myproc()->sz;
80104e99:	e8 1f e4 ff ff       	call   801032bd <myproc>
80104e9e:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104ea0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ea3:	89 14 24             	mov    %edx,(%esp)
80104ea6:	e8 2f e5 ff ff       	call   801033da <growproc>
80104eab:	85 c0                	test   %eax,%eax
80104ead:	79 0e                	jns    80104ebd <sys_sbrk+0x42>
    return -1;
80104eaf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104eb4:	eb 09                	jmp    80104ebf <sys_sbrk+0x44>
    return -1;
80104eb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ebb:	eb 02                	jmp    80104ebf <sys_sbrk+0x44>
  return addr;
80104ebd:	89 d8                	mov    %ebx,%eax
}
80104ebf:	83 c4 24             	add    $0x24,%esp
80104ec2:	5b                   	pop    %ebx
80104ec3:	5d                   	pop    %ebp
80104ec4:	c3                   	ret    

80104ec5 <sys_sleep>:

int
sys_sleep(void)
{
80104ec5:	55                   	push   %ebp
80104ec6:	89 e5                	mov    %esp,%ebp
80104ec8:	53                   	push   %ebx
80104ec9:	83 ec 24             	sub    $0x24,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104ecc:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ecf:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ed3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104eda:	e8 6c f2 ff ff       	call   8010414b <argint>
80104edf:	85 c0                	test   %eax,%eax
80104ee1:	78 65                	js     80104f48 <sys_sleep+0x83>
    return -1;
  acquire(&tickslock);
80104ee3:	c7 04 24 60 4c 11 80 	movl   $0x80114c60,(%esp)
80104eea:	e8 54 ef ff ff       	call   80103e43 <acquire>
  ticks0 = ticks;
80104eef:	8b 1d a0 54 11 80    	mov    0x801154a0,%ebx
  while(ticks - ticks0 < n){
80104ef5:	eb 32                	jmp    80104f29 <sys_sleep+0x64>
    if(myproc()->killed){
80104ef7:	e8 c1 e3 ff ff       	call   801032bd <myproc>
80104efc:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f00:	74 13                	je     80104f15 <sys_sleep+0x50>
      release(&tickslock);
80104f02:	c7 04 24 60 4c 11 80 	movl   $0x80114c60,(%esp)
80104f09:	e8 96 ef ff ff       	call   80103ea4 <release>
      return -1;
80104f0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f13:	eb 38                	jmp    80104f4d <sys_sleep+0x88>
    }
    sleep(&ticks, &tickslock);
80104f15:	c7 44 24 04 60 4c 11 	movl   $0x80114c60,0x4(%esp)
80104f1c:	80 
80104f1d:	c7 04 24 a0 54 11 80 	movl   $0x801154a0,(%esp)
80104f24:	e8 1c e8 ff ff       	call   80103745 <sleep>
  while(ticks - ticks0 < n){
80104f29:	a1 a0 54 11 80       	mov    0x801154a0,%eax
80104f2e:	29 d8                	sub    %ebx,%eax
80104f30:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104f33:	72 c2                	jb     80104ef7 <sys_sleep+0x32>
  }
  release(&tickslock);
80104f35:	c7 04 24 60 4c 11 80 	movl   $0x80114c60,(%esp)
80104f3c:	e8 63 ef ff ff       	call   80103ea4 <release>
  return 0;
80104f41:	b8 00 00 00 00       	mov    $0x0,%eax
80104f46:	eb 05                	jmp    80104f4d <sys_sleep+0x88>
    return -1;
80104f48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f4d:	83 c4 24             	add    $0x24,%esp
80104f50:	5b                   	pop    %ebx
80104f51:	5d                   	pop    %ebp
80104f52:	c3                   	ret    

80104f53 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104f53:	55                   	push   %ebp
80104f54:	89 e5                	mov    %esp,%ebp
80104f56:	53                   	push   %ebx
80104f57:	83 ec 14             	sub    $0x14,%esp
  uint xticks;

  acquire(&tickslock);
80104f5a:	c7 04 24 60 4c 11 80 	movl   $0x80114c60,(%esp)
80104f61:	e8 dd ee ff ff       	call   80103e43 <acquire>
  xticks = ticks;
80104f66:	8b 1d a0 54 11 80    	mov    0x801154a0,%ebx
  release(&tickslock);
80104f6c:	c7 04 24 60 4c 11 80 	movl   $0x80114c60,(%esp)
80104f73:	e8 2c ef ff ff       	call   80103ea4 <release>
  return xticks;
}
80104f78:	89 d8                	mov    %ebx,%eax
80104f7a:	83 c4 14             	add    $0x14,%esp
80104f7d:	5b                   	pop    %ebx
80104f7e:	5d                   	pop    %ebp
80104f7f:	c3                   	ret    

80104f80 <sys_yield>:

int
sys_yield(void)
{
80104f80:	55                   	push   %ebp
80104f81:	89 e5                	mov    %esp,%ebp
80104f83:	83 ec 08             	sub    $0x8,%esp
  yield();
80104f86:	e8 89 e7 ff ff       	call   80103714 <yield>
  return 0;
}
80104f8b:	b8 00 00 00 00       	mov    $0x0,%eax
80104f90:	c9                   	leave  
80104f91:	c3                   	ret    

80104f92 <sys_shutdown>:

int sys_shutdown(void)
{
80104f92:	55                   	push   %ebp
80104f93:	89 e5                	mov    %esp,%ebp
80104f95:	83 ec 08             	sub    $0x8,%esp
  shutdown();
80104f98:	e8 e8 d2 ff ff       	call   80102285 <shutdown>
  return 0;
}
80104f9d:	b8 00 00 00 00       	mov    $0x0,%eax
80104fa2:	c9                   	leave  
80104fa3:	c3                   	ret    

80104fa4 <sys_getpagetableentry>:


int 
sys_getpagetableentry(void){
80104fa4:	55                   	push   %ebp
80104fa5:	89 e5                	mov    %esp,%ebp
80104fa7:	83 ec 28             	sub    $0x28,%esp
  int pid;
  int address;
  if((argint(0, &pid) < 0)|| (argint(1, &address) < 0)){
80104faa:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104fad:	89 44 24 04          	mov    %eax,0x4(%esp)
80104fb1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104fb8:	e8 8e f1 ff ff       	call   8010414b <argint>
80104fbd:	85 c0                	test   %eax,%eax
80104fbf:	78 2b                	js     80104fec <sys_getpagetableentry+0x48>
80104fc1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104fc4:	89 44 24 04          	mov    %eax,0x4(%esp)
80104fc8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104fcf:	e8 77 f1 ff ff       	call   8010414b <argint>
80104fd4:	85 c0                	test   %eax,%eax
80104fd6:	78 1b                	js     80104ff3 <sys_getpagetableentry+0x4f>
    return -1;
  }
  else{
    return getpagetableentry(pid, address);
80104fd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fdb:	89 44 24 04          	mov    %eax,0x4(%esp)
80104fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fe2:	89 04 24             	mov    %eax,(%esp)
80104fe5:	e8 02 ea ff ff       	call   801039ec <getpagetableentry>
80104fea:	eb 0c                	jmp    80104ff8 <sys_getpagetableentry+0x54>
    return -1;
80104fec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ff1:	eb 05                	jmp    80104ff8 <sys_getpagetableentry+0x54>
80104ff3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80104ff8:	c9                   	leave  
80104ff9:	c3                   	ret    

80104ffa <sys_isphysicalpagefree>:


int
sys_isphysicalpagefree(void){
80104ffa:	55                   	push   %ebp
80104ffb:	89 e5                	mov    %esp,%ebp
80104ffd:	83 ec 28             	sub    $0x28,%esp
  int ppn;
  if((argint(0, &ppn) < 0)){
80105000:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105003:	89 44 24 04          	mov    %eax,0x4(%esp)
80105007:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010500e:	e8 38 f1 ff ff       	call   8010414b <argint>
80105013:	85 c0                	test   %eax,%eax
80105015:	78 0d                	js     80105024 <sys_isphysicalpagefree+0x2a>
    return -1;
  }
  else{
    return isphysicalpagefree(ppn);
80105017:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010501a:	89 04 24             	mov    %eax,(%esp)
8010501d:	e8 4e ea ff ff       	call   80103a70 <isphysicalpagefree>
80105022:	eb 05                	jmp    80105029 <sys_isphysicalpagefree+0x2f>
    return -1;
80105024:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80105029:	c9                   	leave  
8010502a:	c3                   	ret    

8010502b <sys_dumppagetable>:

int
sys_dumppagetable(void){
8010502b:	55                   	push   %ebp
8010502c:	89 e5                	mov    %esp,%ebp
8010502e:	83 ec 28             	sub    $0x28,%esp
  int pid;
  if (argptr(0, (void*)&pid, sizeof(pid)) < 0){
80105031:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80105038:	00 
80105039:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010503c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105040:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105047:	e8 2a f1 ff ff       	call   80104176 <argptr>
8010504c:	85 c0                	test   %eax,%eax
8010504e:	78 0d                	js     8010505d <sys_dumppagetable+0x32>
    return -1;
  }
  else{
    return dumppagetable(pid);
80105050:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105053:	89 04 24             	mov    %eax,(%esp)
80105056:	e8 a8 ea ff ff       	call   80103b03 <dumppagetable>
8010505b:	eb 05                	jmp    80105062 <sys_dumppagetable+0x37>
    return -1;
8010505d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
80105062:	c9                   	leave  
80105063:	c3                   	ret    

80105064 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105064:	1e                   	push   %ds
  pushl %es
80105065:	06                   	push   %es
  pushl %fs
80105066:	0f a0                	push   %fs
  pushl %gs
80105068:	0f a8                	push   %gs
  pushal
8010506a:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
8010506b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010506f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105071:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105073:	54                   	push   %esp
  call trap
80105074:	e8 c7 00 00 00       	call   80105140 <trap>
  addl $4, %esp
80105079:	83 c4 04             	add    $0x4,%esp

8010507c <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010507c:	61                   	popa   
  popl %gs
8010507d:	0f a9                	pop    %gs
  popl %fs
8010507f:	0f a1                	pop    %fs
  popl %es
80105081:	07                   	pop    %es
  popl %ds
80105082:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105083:	83 c4 08             	add    $0x8,%esp
  iret
80105086:	cf                   	iret   
80105087:	66 90                	xchg   %ax,%ax
80105089:	66 90                	xchg   %ax,%ax
8010508b:	66 90                	xchg   %ax,%ax
8010508d:	66 90                	xchg   %ax,%ax
8010508f:	90                   	nop

80105090 <tvinit>:
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80105090:	b8 00 00 00 00       	mov    $0x0,%eax
80105095:	eb 37                	jmp    801050ce <tvinit+0x3e>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105097:	8b 14 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%edx
8010509e:	66 89 14 c5 a0 4c 11 	mov    %dx,-0x7feeb360(,%eax,8)
801050a5:	80 
801050a6:	66 c7 04 c5 a2 4c 11 	movw   $0x8,-0x7feeb35e(,%eax,8)
801050ad:	80 08 00 
801050b0:	c6 04 c5 a4 4c 11 80 	movb   $0x0,-0x7feeb35c(,%eax,8)
801050b7:	00 
801050b8:	c6 04 c5 a5 4c 11 80 	movb   $0x8e,-0x7feeb35b(,%eax,8)
801050bf:	8e 
801050c0:	c1 ea 10             	shr    $0x10,%edx
801050c3:	66 89 14 c5 a6 4c 11 	mov    %dx,-0x7feeb35a(,%eax,8)
801050ca:	80 
  for(i = 0; i < 256; i++)
801050cb:	83 c0 01             	add    $0x1,%eax
801050ce:	3d ff 00 00 00       	cmp    $0xff,%eax
801050d3:	7e c2                	jle    80105097 <tvinit+0x7>
{
801050d5:	55                   	push   %ebp
801050d6:	89 e5                	mov    %esp,%ebp
801050d8:	83 ec 18             	sub    $0x18,%esp
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801050db:	a1 08 a1 10 80       	mov    0x8010a108,%eax
801050e0:	66 a3 a0 4e 11 80    	mov    %ax,0x80114ea0
801050e6:	66 c7 05 a2 4e 11 80 	movw   $0x8,0x80114ea2
801050ed:	08 00 
801050ef:	c6 05 a4 4e 11 80 00 	movb   $0x0,0x80114ea4
801050f6:	c6 05 a5 4e 11 80 ef 	movb   $0xef,0x80114ea5
801050fd:	c1 e8 10             	shr    $0x10,%eax
80105100:	66 a3 a6 4e 11 80    	mov    %ax,0x80114ea6

  initlock(&tickslock, "time");
80105106:	c7 44 24 04 6d 72 10 	movl   $0x8010726d,0x4(%esp)
8010510d:	80 
8010510e:	c7 04 24 60 4c 11 80 	movl   $0x80114c60,(%esp)
80105115:	e8 f1 eb ff ff       	call   80103d0b <initlock>
}
8010511a:	c9                   	leave  
8010511b:	c3                   	ret    

8010511c <idtinit>:

void
idtinit(void)
{
8010511c:	55                   	push   %ebp
8010511d:	89 e5                	mov    %esp,%ebp
8010511f:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105122:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80105128:	b8 a0 4c 11 80       	mov    $0x80114ca0,%eax
8010512d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105131:	c1 e8 10             	shr    $0x10,%eax
80105134:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105138:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010513b:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
8010513e:	c9                   	leave  
8010513f:	c3                   	ret    

80105140 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105140:	55                   	push   %ebp
80105141:	89 e5                	mov    %esp,%ebp
80105143:	57                   	push   %edi
80105144:	56                   	push   %esi
80105145:	53                   	push   %ebx
80105146:	83 ec 3c             	sub    $0x3c,%esp
80105149:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
8010514c:	8b 43 30             	mov    0x30(%ebx),%eax
8010514f:	83 f8 40             	cmp    $0x40,%eax
80105152:	75 36                	jne    8010518a <trap+0x4a>
    if(myproc()->killed)
80105154:	e8 64 e1 ff ff       	call   801032bd <myproc>
80105159:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010515d:	74 05                	je     80105164 <trap+0x24>
      exit();
8010515f:	e8 f4 e4 ff ff       	call   80103658 <exit>
    myproc()->tf = tf;
80105164:	e8 54 e1 ff ff       	call   801032bd <myproc>
80105169:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
8010516c:	e8 a4 f0 ff ff       	call   80104215 <syscall>
    if(myproc()->killed)
80105171:	e8 47 e1 ff ff       	call   801032bd <myproc>
80105176:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010517a:	0f 84 05 03 00 00    	je     80105485 <trap+0x345>
      exit();
80105180:	e8 d3 e4 ff ff       	call   80103658 <exit>
80105185:	e9 fb 02 00 00       	jmp    80105485 <trap+0x345>
    return;
  }

  switch(tf->trapno){
8010518a:	83 e8 0e             	sub    $0xe,%eax
8010518d:	83 f8 31             	cmp    $0x31,%eax
80105190:	0f 87 d2 01 00 00    	ja     80105368 <trap+0x228>
80105196:	ff 24 85 50 73 10 80 	jmp    *-0x7fef8cb0(,%eax,4)
8010519d:	8d 76 00             	lea    0x0(%esi),%esi
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801051a0:	e8 fd e0 ff ff       	call   801032a2 <cpuid>
801051a5:	85 c0                	test   %eax,%eax
801051a7:	75 2b                	jne    801051d4 <trap+0x94>
      acquire(&tickslock);
801051a9:	c7 04 24 60 4c 11 80 	movl   $0x80114c60,(%esp)
801051b0:	e8 8e ec ff ff       	call   80103e43 <acquire>
      ticks++;
801051b5:	83 05 a0 54 11 80 01 	addl   $0x1,0x801154a0
      wakeup(&ticks);
801051bc:	c7 04 24 a0 54 11 80 	movl   $0x801154a0,(%esp)
801051c3:	e8 d2 e6 ff ff       	call   8010389a <wakeup>
      release(&tickslock);
801051c8:	c7 04 24 60 4c 11 80 	movl   $0x80114c60,(%esp)
801051cf:	e8 d0 ec ff ff       	call   80103ea4 <release>
    }
    lapiceoi();
801051d4:	e8 5a d2 ff ff       	call   80102433 <lapiceoi>
    break;
801051d9:	e9 3c 02 00 00       	jmp    8010541a <trap+0x2da>
801051de:	66 90                	xchg   %ax,%ax
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801051e0:	e8 27 cc ff ff       	call   80101e0c <ideintr>
    lapiceoi();
801051e5:	e8 49 d2 ff ff       	call   80102433 <lapiceoi>
    break;
801051ea:	e9 2b 02 00 00       	jmp    8010541a <trap+0x2da>
801051ef:	90                   	nop
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801051f0:	e8 7c d0 ff ff       	call   80102271 <kbdintr>
    lapiceoi();
801051f5:	e8 39 d2 ff ff       	call   80102433 <lapiceoi>
    break;
801051fa:	e9 1b 02 00 00       	jmp    8010541a <trap+0x2da>
801051ff:	90                   	nop
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80105200:	e8 8d 03 00 00       	call   80105592 <uartintr>
    lapiceoi();
80105205:	e8 29 d2 ff ff       	call   80102433 <lapiceoi>
    break;
8010520a:	e9 0b 02 00 00       	jmp    8010541a <trap+0x2da>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010520f:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
80105212:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105216:	e8 87 e0 ff ff       	call   801032a2 <cpuid>
8010521b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
8010521f:	0f b7 f6             	movzwl %si,%esi
80105222:	89 74 24 08          	mov    %esi,0x8(%esp)
80105226:	89 44 24 04          	mov    %eax,0x4(%esp)
8010522a:	c7 04 24 b4 72 10 80 	movl   $0x801072b4,(%esp)
80105231:	e8 91 b3 ff ff       	call   801005c7 <cprintf>
    lapiceoi();
80105236:	e8 f8 d1 ff ff       	call   80102433 <lapiceoi>
    break;
8010523b:	e9 da 01 00 00       	jmp    8010541a <trap+0x2da>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105240:	0f 20 d6             	mov    %cr2,%esi
  
  case T_PGFLT: 
    //Get the address using rc2() \\static inline uint type
  {
     uint address = PGROUNDDOWN(rcr2());
80105243:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
     
    //now lets do PTE stuff like part 1
     pte_t *pte = walkpgdir(myproc()->pgdir, (void*)address, 0);
80105249:	e8 6f e0 ff ff       	call   801032bd <myproc>
8010524e:	8b 40 04             	mov    0x4(%eax),%eax
80105251:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105258:	00 
80105259:	89 74 24 04          	mov    %esi,0x4(%esp)
8010525d:	89 04 24             	mov    %eax,(%esp)
80105260:	e8 93 0e 00 00       	call   801060f8 <walkpgdir>
    //check if page is guard page: presetn but not usable
    if((*pte & PTE_P) && !(*pte & PTE_U)){
80105265:	8b 00                	mov    (%eax),%eax
80105267:	83 e0 05             	and    $0x5,%eax
8010526a:	83 f8 01             	cmp    $0x1,%eax
8010526d:	75 11                	jne    80105280 <trap+0x140>
      cprintf("guard page");
8010526f:	c7 04 24 72 72 10 80 	movl   $0x80107272,(%esp)
80105276:	e8 4c b3 ff ff       	call   801005c7 <cprintf>
      goto default2;
8010527b:	e9 e8 00 00 00       	jmp    80105368 <trap+0x228>
       }
    
    int vpn = address >> 12;
80105280:	89 f7                	mov    %esi,%edi
80105282:	c1 ef 0c             	shr    $0xc,%edi
    if(vpn >= myproc()->sz >> 12){
80105285:	e8 33 e0 ff ff       	call   801032bd <myproc>
8010528a:	8b 00                	mov    (%eax),%eax
8010528c:	c1 e8 0c             	shr    $0xc,%eax
8010528f:	39 c7                	cmp    %eax,%edi
80105291:	72 11                	jb     801052a4 <trap+0x164>
      cprintf("vpn access out of bounds (1)\n");
80105293:	c7 04 24 7d 72 10 80 	movl   $0x8010727d,(%esp)
8010529a:	e8 28 b3 ff ff       	call   801005c7 <cprintf>
      goto default2;
8010529f:	e9 c4 00 00 00       	jmp    80105368 <trap+0x228>
    }
  //obtain a free page: take one! use kalloc!
    char *free = kalloc();
801052a4:	e8 b0 ce ff ff       	call   80102159 <kalloc>
801052a9:	89 c7                	mov    %eax,%edi
    if(free == 0){
801052ab:	85 c0                	test   %eax,%eax
801052ad:	8d 76 00             	lea    0x0(%esi),%esi
801052b0:	75 11                	jne    801052c3 <trap+0x183>
      cprintf("free page");
801052b2:	c7 04 24 9b 72 10 80 	movl   $0x8010729b,(%esp)
801052b9:	e8 09 b3 ff ff       	call   801005c7 <cprintf>
       goto default2;
801052be:	e9 a5 00 00 00       	jmp    80105368 <trap+0x228>
    }

  //zero out the pageeee, use memset!
  memset(free,0,PGSIZE);
801052c3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801052ca:	00 
801052cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801052d2:	00 
801052d3:	89 04 24             	mov    %eax,(%esp)
801052d6:	e8 15 ec ff ff       	call   80103ef0 <memset>
    if (a < (void*) KERNBASE)
801052db:	81 ff ff ff ff 7f    	cmp    $0x7fffffff,%edi
801052e1:	77 0c                	ja     801052ef <trap+0x1af>
        panic("V2P on address < KERNBASE "
801052e3:	c7 04 24 28 6c 10 80 	movl   $0x80106c28,(%esp)
801052ea:	e8 36 b0 ff ff       	call   80100325 <panic>
    return (uint)a - KERNBASE;
801052ef:	8d 87 00 00 00 80    	lea    -0x80000000(%edi),%eax
801052f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  //update the page table, got this next line directly from vm./c
    if(mappages(myproc()->pgdir, (char*)address, PGSIZE, V2P(free), PTE_W|PTE_U) < 0){
801052f8:	e8 c0 df ff ff       	call   801032bd <myproc>
801052fd:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80105304:	00 
80105305:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80105308:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010530c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80105313:	00 
80105314:	89 74 24 04          	mov    %esi,0x4(%esp)
80105318:	8b 40 04             	mov    0x4(%eax),%eax
8010531b:	89 04 24             	mov    %eax,(%esp)
8010531e:	e8 7f 0e 00 00       	call   801061a2 <mappages>
80105323:	85 c0                	test   %eax,%eax
80105325:	79 16                	jns    8010533d <trap+0x1fd>
      cprintf("update");
80105327:	c7 04 24 a5 72 10 80 	movl   $0x801072a5,(%esp)
8010532e:	e8 94 b2 ff ff       	call   801005c7 <cprintf>
      kfree(free);
80105333:	89 3c 24             	mov    %edi,(%esp)
80105336:	e8 e1 cc ff ff       	call   8010201c <kfree>
      
      goto default2;
8010533b:	eb 2b                	jmp    80105368 <trap+0x228>
8010533d:	8d 76 00             	lea    0x0(%esi),%esi

    }

     // flush!!!
      lcr3(V2P(myproc()->pgdir));
80105340:	e8 78 df ff ff       	call   801032bd <myproc>
80105345:	8b 40 04             	mov    0x4(%eax),%eax
    if (a < (void*) KERNBASE)
80105348:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
8010534d:	77 0c                	ja     8010535b <trap+0x21b>
        panic("V2P on address < KERNBASE "
8010534f:	c7 04 24 28 6c 10 80 	movl   $0x80106c28,(%esp)
80105356:	e8 ca af ff ff       	call   80100325 <panic>
    return (uint)a - KERNBASE;
8010535b:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105360:	0f 22 d8             	mov    %eax,%cr3
80105363:	e9 b2 00 00 00       	jmp    8010541a <trap+0x2da>
  

  //PAGEBREAK: 13
  default:
  default2:
    if(myproc() == 0 || (tf->cs&3) == 0){
80105368:	e8 50 df ff ff       	call   801032bd <myproc>
8010536d:	85 c0                	test   %eax,%eax
8010536f:	74 06                	je     80105377 <trap+0x237>
80105371:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105375:	75 36                	jne    801053ad <trap+0x26d>
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105377:	0f 20 d7             	mov    %cr2,%edi
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010537a:	8b 73 38             	mov    0x38(%ebx),%esi
8010537d:	e8 20 df ff ff       	call   801032a2 <cpuid>
80105382:	89 7c 24 10          	mov    %edi,0x10(%esp)
80105386:	89 74 24 0c          	mov    %esi,0xc(%esp)
8010538a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010538e:	8b 43 30             	mov    0x30(%ebx),%eax
80105391:	89 44 24 04          	mov    %eax,0x4(%esp)
80105395:	c7 04 24 d8 72 10 80 	movl   $0x801072d8,(%esp)
8010539c:	e8 26 b2 ff ff       	call   801005c7 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801053a1:	c7 04 24 ac 72 10 80 	movl   $0x801072ac,(%esp)
801053a8:	e8 78 af ff ff       	call   80100325 <panic>
801053ad:	0f 20 d7             	mov    %cr2,%edi
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801053b0:	8b 43 38             	mov    0x38(%ebx),%eax
801053b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801053b6:	e8 e7 de ff ff       	call   801032a2 <cpuid>
801053bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
801053be:	8b 4b 34             	mov    0x34(%ebx),%ecx
801053c1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
801053c4:	8b 73 30             	mov    0x30(%ebx),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801053c7:	e8 f1 de ff ff       	call   801032bd <myproc>
801053cc:	8d 50 6c             	lea    0x6c(%eax),%edx
801053cf:	89 55 d8             	mov    %edx,-0x28(%ebp)
801053d2:	e8 e6 de ff ff       	call   801032bd <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801053d7:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
801053db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801053de:	89 54 24 18          	mov    %edx,0x18(%esp)
801053e2:	8b 7d e0             	mov    -0x20(%ebp),%edi
801053e5:	89 7c 24 14          	mov    %edi,0x14(%esp)
801053e9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
801053ec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801053f0:	89 74 24 0c          	mov    %esi,0xc(%esp)
801053f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
801053f7:	89 54 24 08          	mov    %edx,0x8(%esp)
801053fb:	8b 40 10             	mov    0x10(%eax),%eax
801053fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80105402:	c7 04 24 0c 73 10 80 	movl   $0x8010730c,(%esp)
80105409:	e8 b9 b1 ff ff       	call   801005c7 <cprintf>
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
8010540e:	e8 aa de ff ff       	call   801032bd <myproc>
80105413:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010541a:	e8 9e de ff ff       	call   801032bd <myproc>
8010541f:	85 c0                	test   %eax,%eax
80105421:	74 1d                	je     80105440 <trap+0x300>
80105423:	e8 95 de ff ff       	call   801032bd <myproc>
80105428:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010542c:	74 12                	je     80105440 <trap+0x300>
8010542e:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105432:	83 e0 03             	and    $0x3,%eax
80105435:	66 83 f8 03          	cmp    $0x3,%ax
80105439:	75 05                	jne    80105440 <trap+0x300>
    exit();
8010543b:	e8 18 e2 ff ff       	call   80103658 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80105440:	e8 78 de ff ff       	call   801032bd <myproc>
80105445:	85 c0                	test   %eax,%eax
80105447:	74 16                	je     8010545f <trap+0x31f>
80105449:	e8 6f de ff ff       	call   801032bd <myproc>
8010544e:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80105452:	75 0b                	jne    8010545f <trap+0x31f>
80105454:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105458:	75 05                	jne    8010545f <trap+0x31f>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
8010545a:	e8 b5 e2 ff ff       	call   80103714 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010545f:	e8 59 de ff ff       	call   801032bd <myproc>
80105464:	85 c0                	test   %eax,%eax
80105466:	74 1d                	je     80105485 <trap+0x345>
80105468:	e8 50 de ff ff       	call   801032bd <myproc>
8010546d:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105471:	74 12                	je     80105485 <trap+0x345>
80105473:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105477:	83 e0 03             	and    $0x3,%eax
8010547a:	66 83 f8 03          	cmp    $0x3,%ax
8010547e:	75 05                	jne    80105485 <trap+0x345>
    exit();
80105480:	e8 d3 e1 ff ff       	call   80103658 <exit>
}
80105485:	83 c4 3c             	add    $0x3c,%esp
80105488:	5b                   	pop    %ebx
80105489:	5e                   	pop    %esi
8010548a:	5f                   	pop    %edi
8010548b:	5d                   	pop    %ebp
8010548c:	c3                   	ret    

8010548d <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
8010548d:	55                   	push   %ebp
8010548e:	89 e5                	mov    %esp,%ebp
  if(!uart)
80105490:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
80105497:	74 12                	je     801054ab <uartgetc+0x1e>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105499:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010549e:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
8010549f:	a8 01                	test   $0x1,%al
801054a1:	74 0f                	je     801054b2 <uartgetc+0x25>
801054a3:	b2 f8                	mov    $0xf8,%dl
801054a5:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
801054a6:	0f b6 c0             	movzbl %al,%eax
801054a9:	eb 0c                	jmp    801054b7 <uartgetc+0x2a>
    return -1;
801054ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054b0:	eb 05                	jmp    801054b7 <uartgetc+0x2a>
    return -1;
801054b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801054b7:	5d                   	pop    %ebp
801054b8:	c3                   	ret    

801054b9 <uartputc>:
  if(!uart)
801054b9:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
801054c0:	74 3e                	je     80105500 <uartputc+0x47>
{
801054c2:	55                   	push   %ebp
801054c3:	89 e5                	mov    %esp,%ebp
801054c5:	56                   	push   %esi
801054c6:	53                   	push   %ebx
801054c7:	83 ec 10             	sub    $0x10,%esp
801054ca:	bb 00 00 00 00       	mov    $0x0,%ebx
801054cf:	be fd 03 00 00       	mov    $0x3fd,%esi
801054d4:	eb 0f                	jmp    801054e5 <uartputc+0x2c>
    microdelay(10);
801054d6:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801054dd:	e8 6f cf ff ff       	call   80102451 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801054e2:	83 c3 01             	add    $0x1,%ebx
801054e5:	83 fb 7f             	cmp    $0x7f,%ebx
801054e8:	7f 07                	jg     801054f1 <uartputc+0x38>
801054ea:	89 f2                	mov    %esi,%edx
801054ec:	ec                   	in     (%dx),%al
801054ed:	a8 20                	test   $0x20,%al
801054ef:	74 e5                	je     801054d6 <uartputc+0x1d>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801054f1:	ba f8 03 00 00       	mov    $0x3f8,%edx
801054f6:	8b 45 08             	mov    0x8(%ebp),%eax
801054f9:	ee                   	out    %al,(%dx)
}
801054fa:	83 c4 10             	add    $0x10,%esp
801054fd:	5b                   	pop    %ebx
801054fe:	5e                   	pop    %esi
801054ff:	5d                   	pop    %ebp
80105500:	f3 c3                	repz ret 

80105502 <uartinit>:
80105502:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105507:	b8 00 00 00 00       	mov    $0x0,%eax
8010550c:	ee                   	out    %al,(%dx)
8010550d:	b2 fb                	mov    $0xfb,%dl
8010550f:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105514:	ee                   	out    %al,(%dx)
80105515:	b2 f8                	mov    $0xf8,%dl
80105517:	b8 0c 00 00 00       	mov    $0xc,%eax
8010551c:	ee                   	out    %al,(%dx)
8010551d:	b2 f9                	mov    $0xf9,%dl
8010551f:	b8 00 00 00 00       	mov    $0x0,%eax
80105524:	ee                   	out    %al,(%dx)
80105525:	b2 fb                	mov    $0xfb,%dl
80105527:	b8 03 00 00 00       	mov    $0x3,%eax
8010552c:	ee                   	out    %al,(%dx)
8010552d:	b2 fc                	mov    $0xfc,%dl
8010552f:	b8 00 00 00 00       	mov    $0x0,%eax
80105534:	ee                   	out    %al,(%dx)
80105535:	b2 f9                	mov    $0xf9,%dl
80105537:	b8 01 00 00 00       	mov    $0x1,%eax
8010553c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010553d:	b2 fd                	mov    $0xfd,%dl
8010553f:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105540:	3c ff                	cmp    $0xff,%al
80105542:	74 4c                	je     80105590 <uartinit+0x8e>
{
80105544:	55                   	push   %ebp
80105545:	89 e5                	mov    %esp,%ebp
80105547:	53                   	push   %ebx
80105548:	83 ec 14             	sub    $0x14,%esp
  uart = 1;
8010554b:	c7 05 bc a5 10 80 01 	movl   $0x1,0x8010a5bc
80105552:	00 00 00 
80105555:	b2 fa                	mov    $0xfa,%dl
80105557:	ec                   	in     (%dx),%al
80105558:	b2 f8                	mov    $0xf8,%dl
8010555a:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
8010555b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105562:	00 
80105563:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010556a:	e8 87 ca ff ff       	call   80101ff6 <ioapicenable>
  for(p="xv6...\n"; *p; p++)
8010556f:	bb 18 74 10 80       	mov    $0x80107418,%ebx
80105574:	eb 0e                	jmp    80105584 <uartinit+0x82>
    uartputc(*p);
80105576:	0f be c0             	movsbl %al,%eax
80105579:	89 04 24             	mov    %eax,(%esp)
8010557c:	e8 38 ff ff ff       	call   801054b9 <uartputc>
  for(p="xv6...\n"; *p; p++)
80105581:	83 c3 01             	add    $0x1,%ebx
80105584:	0f b6 03             	movzbl (%ebx),%eax
80105587:	84 c0                	test   %al,%al
80105589:	75 eb                	jne    80105576 <uartinit+0x74>
}
8010558b:	83 c4 14             	add    $0x14,%esp
8010558e:	5b                   	pop    %ebx
8010558f:	5d                   	pop    %ebp
80105590:	f3 c3                	repz ret 

80105592 <uartintr>:

void
uartintr(void)
{
80105592:	55                   	push   %ebp
80105593:	89 e5                	mov    %esp,%ebp
80105595:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80105598:	c7 04 24 8d 54 10 80 	movl   $0x8010548d,(%esp)
8010559f:	e8 55 b1 ff ff       	call   801006f9 <consoleintr>
}
801055a4:	c9                   	leave  
801055a5:	c3                   	ret    

801055a6 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801055a6:	6a 00                	push   $0x0
  pushl $0
801055a8:	6a 00                	push   $0x0
  jmp alltraps
801055aa:	e9 b5 fa ff ff       	jmp    80105064 <alltraps>

801055af <vector1>:
.globl vector1
vector1:
  pushl $0
801055af:	6a 00                	push   $0x0
  pushl $1
801055b1:	6a 01                	push   $0x1
  jmp alltraps
801055b3:	e9 ac fa ff ff       	jmp    80105064 <alltraps>

801055b8 <vector2>:
.globl vector2
vector2:
  pushl $0
801055b8:	6a 00                	push   $0x0
  pushl $2
801055ba:	6a 02                	push   $0x2
  jmp alltraps
801055bc:	e9 a3 fa ff ff       	jmp    80105064 <alltraps>

801055c1 <vector3>:
.globl vector3
vector3:
  pushl $0
801055c1:	6a 00                	push   $0x0
  pushl $3
801055c3:	6a 03                	push   $0x3
  jmp alltraps
801055c5:	e9 9a fa ff ff       	jmp    80105064 <alltraps>

801055ca <vector4>:
.globl vector4
vector4:
  pushl $0
801055ca:	6a 00                	push   $0x0
  pushl $4
801055cc:	6a 04                	push   $0x4
  jmp alltraps
801055ce:	e9 91 fa ff ff       	jmp    80105064 <alltraps>

801055d3 <vector5>:
.globl vector5
vector5:
  pushl $0
801055d3:	6a 00                	push   $0x0
  pushl $5
801055d5:	6a 05                	push   $0x5
  jmp alltraps
801055d7:	e9 88 fa ff ff       	jmp    80105064 <alltraps>

801055dc <vector6>:
.globl vector6
vector6:
  pushl $0
801055dc:	6a 00                	push   $0x0
  pushl $6
801055de:	6a 06                	push   $0x6
  jmp alltraps
801055e0:	e9 7f fa ff ff       	jmp    80105064 <alltraps>

801055e5 <vector7>:
.globl vector7
vector7:
  pushl $0
801055e5:	6a 00                	push   $0x0
  pushl $7
801055e7:	6a 07                	push   $0x7
  jmp alltraps
801055e9:	e9 76 fa ff ff       	jmp    80105064 <alltraps>

801055ee <vector8>:
.globl vector8
vector8:
  pushl $8
801055ee:	6a 08                	push   $0x8
  jmp alltraps
801055f0:	e9 6f fa ff ff       	jmp    80105064 <alltraps>

801055f5 <vector9>:
.globl vector9
vector9:
  pushl $0
801055f5:	6a 00                	push   $0x0
  pushl $9
801055f7:	6a 09                	push   $0x9
  jmp alltraps
801055f9:	e9 66 fa ff ff       	jmp    80105064 <alltraps>

801055fe <vector10>:
.globl vector10
vector10:
  pushl $10
801055fe:	6a 0a                	push   $0xa
  jmp alltraps
80105600:	e9 5f fa ff ff       	jmp    80105064 <alltraps>

80105605 <vector11>:
.globl vector11
vector11:
  pushl $11
80105605:	6a 0b                	push   $0xb
  jmp alltraps
80105607:	e9 58 fa ff ff       	jmp    80105064 <alltraps>

8010560c <vector12>:
.globl vector12
vector12:
  pushl $12
8010560c:	6a 0c                	push   $0xc
  jmp alltraps
8010560e:	e9 51 fa ff ff       	jmp    80105064 <alltraps>

80105613 <vector13>:
.globl vector13
vector13:
  pushl $13
80105613:	6a 0d                	push   $0xd
  jmp alltraps
80105615:	e9 4a fa ff ff       	jmp    80105064 <alltraps>

8010561a <vector14>:
.globl vector14
vector14:
  pushl $14
8010561a:	6a 0e                	push   $0xe
  jmp alltraps
8010561c:	e9 43 fa ff ff       	jmp    80105064 <alltraps>

80105621 <vector15>:
.globl vector15
vector15:
  pushl $0
80105621:	6a 00                	push   $0x0
  pushl $15
80105623:	6a 0f                	push   $0xf
  jmp alltraps
80105625:	e9 3a fa ff ff       	jmp    80105064 <alltraps>

8010562a <vector16>:
.globl vector16
vector16:
  pushl $0
8010562a:	6a 00                	push   $0x0
  pushl $16
8010562c:	6a 10                	push   $0x10
  jmp alltraps
8010562e:	e9 31 fa ff ff       	jmp    80105064 <alltraps>

80105633 <vector17>:
.globl vector17
vector17:
  pushl $17
80105633:	6a 11                	push   $0x11
  jmp alltraps
80105635:	e9 2a fa ff ff       	jmp    80105064 <alltraps>

8010563a <vector18>:
.globl vector18
vector18:
  pushl $0
8010563a:	6a 00                	push   $0x0
  pushl $18
8010563c:	6a 12                	push   $0x12
  jmp alltraps
8010563e:	e9 21 fa ff ff       	jmp    80105064 <alltraps>

80105643 <vector19>:
.globl vector19
vector19:
  pushl $0
80105643:	6a 00                	push   $0x0
  pushl $19
80105645:	6a 13                	push   $0x13
  jmp alltraps
80105647:	e9 18 fa ff ff       	jmp    80105064 <alltraps>

8010564c <vector20>:
.globl vector20
vector20:
  pushl $0
8010564c:	6a 00                	push   $0x0
  pushl $20
8010564e:	6a 14                	push   $0x14
  jmp alltraps
80105650:	e9 0f fa ff ff       	jmp    80105064 <alltraps>

80105655 <vector21>:
.globl vector21
vector21:
  pushl $0
80105655:	6a 00                	push   $0x0
  pushl $21
80105657:	6a 15                	push   $0x15
  jmp alltraps
80105659:	e9 06 fa ff ff       	jmp    80105064 <alltraps>

8010565e <vector22>:
.globl vector22
vector22:
  pushl $0
8010565e:	6a 00                	push   $0x0
  pushl $22
80105660:	6a 16                	push   $0x16
  jmp alltraps
80105662:	e9 fd f9 ff ff       	jmp    80105064 <alltraps>

80105667 <vector23>:
.globl vector23
vector23:
  pushl $0
80105667:	6a 00                	push   $0x0
  pushl $23
80105669:	6a 17                	push   $0x17
  jmp alltraps
8010566b:	e9 f4 f9 ff ff       	jmp    80105064 <alltraps>

80105670 <vector24>:
.globl vector24
vector24:
  pushl $0
80105670:	6a 00                	push   $0x0
  pushl $24
80105672:	6a 18                	push   $0x18
  jmp alltraps
80105674:	e9 eb f9 ff ff       	jmp    80105064 <alltraps>

80105679 <vector25>:
.globl vector25
vector25:
  pushl $0
80105679:	6a 00                	push   $0x0
  pushl $25
8010567b:	6a 19                	push   $0x19
  jmp alltraps
8010567d:	e9 e2 f9 ff ff       	jmp    80105064 <alltraps>

80105682 <vector26>:
.globl vector26
vector26:
  pushl $0
80105682:	6a 00                	push   $0x0
  pushl $26
80105684:	6a 1a                	push   $0x1a
  jmp alltraps
80105686:	e9 d9 f9 ff ff       	jmp    80105064 <alltraps>

8010568b <vector27>:
.globl vector27
vector27:
  pushl $0
8010568b:	6a 00                	push   $0x0
  pushl $27
8010568d:	6a 1b                	push   $0x1b
  jmp alltraps
8010568f:	e9 d0 f9 ff ff       	jmp    80105064 <alltraps>

80105694 <vector28>:
.globl vector28
vector28:
  pushl $0
80105694:	6a 00                	push   $0x0
  pushl $28
80105696:	6a 1c                	push   $0x1c
  jmp alltraps
80105698:	e9 c7 f9 ff ff       	jmp    80105064 <alltraps>

8010569d <vector29>:
.globl vector29
vector29:
  pushl $0
8010569d:	6a 00                	push   $0x0
  pushl $29
8010569f:	6a 1d                	push   $0x1d
  jmp alltraps
801056a1:	e9 be f9 ff ff       	jmp    80105064 <alltraps>

801056a6 <vector30>:
.globl vector30
vector30:
  pushl $0
801056a6:	6a 00                	push   $0x0
  pushl $30
801056a8:	6a 1e                	push   $0x1e
  jmp alltraps
801056aa:	e9 b5 f9 ff ff       	jmp    80105064 <alltraps>

801056af <vector31>:
.globl vector31
vector31:
  pushl $0
801056af:	6a 00                	push   $0x0
  pushl $31
801056b1:	6a 1f                	push   $0x1f
  jmp alltraps
801056b3:	e9 ac f9 ff ff       	jmp    80105064 <alltraps>

801056b8 <vector32>:
.globl vector32
vector32:
  pushl $0
801056b8:	6a 00                	push   $0x0
  pushl $32
801056ba:	6a 20                	push   $0x20
  jmp alltraps
801056bc:	e9 a3 f9 ff ff       	jmp    80105064 <alltraps>

801056c1 <vector33>:
.globl vector33
vector33:
  pushl $0
801056c1:	6a 00                	push   $0x0
  pushl $33
801056c3:	6a 21                	push   $0x21
  jmp alltraps
801056c5:	e9 9a f9 ff ff       	jmp    80105064 <alltraps>

801056ca <vector34>:
.globl vector34
vector34:
  pushl $0
801056ca:	6a 00                	push   $0x0
  pushl $34
801056cc:	6a 22                	push   $0x22
  jmp alltraps
801056ce:	e9 91 f9 ff ff       	jmp    80105064 <alltraps>

801056d3 <vector35>:
.globl vector35
vector35:
  pushl $0
801056d3:	6a 00                	push   $0x0
  pushl $35
801056d5:	6a 23                	push   $0x23
  jmp alltraps
801056d7:	e9 88 f9 ff ff       	jmp    80105064 <alltraps>

801056dc <vector36>:
.globl vector36
vector36:
  pushl $0
801056dc:	6a 00                	push   $0x0
  pushl $36
801056de:	6a 24                	push   $0x24
  jmp alltraps
801056e0:	e9 7f f9 ff ff       	jmp    80105064 <alltraps>

801056e5 <vector37>:
.globl vector37
vector37:
  pushl $0
801056e5:	6a 00                	push   $0x0
  pushl $37
801056e7:	6a 25                	push   $0x25
  jmp alltraps
801056e9:	e9 76 f9 ff ff       	jmp    80105064 <alltraps>

801056ee <vector38>:
.globl vector38
vector38:
  pushl $0
801056ee:	6a 00                	push   $0x0
  pushl $38
801056f0:	6a 26                	push   $0x26
  jmp alltraps
801056f2:	e9 6d f9 ff ff       	jmp    80105064 <alltraps>

801056f7 <vector39>:
.globl vector39
vector39:
  pushl $0
801056f7:	6a 00                	push   $0x0
  pushl $39
801056f9:	6a 27                	push   $0x27
  jmp alltraps
801056fb:	e9 64 f9 ff ff       	jmp    80105064 <alltraps>

80105700 <vector40>:
.globl vector40
vector40:
  pushl $0
80105700:	6a 00                	push   $0x0
  pushl $40
80105702:	6a 28                	push   $0x28
  jmp alltraps
80105704:	e9 5b f9 ff ff       	jmp    80105064 <alltraps>

80105709 <vector41>:
.globl vector41
vector41:
  pushl $0
80105709:	6a 00                	push   $0x0
  pushl $41
8010570b:	6a 29                	push   $0x29
  jmp alltraps
8010570d:	e9 52 f9 ff ff       	jmp    80105064 <alltraps>

80105712 <vector42>:
.globl vector42
vector42:
  pushl $0
80105712:	6a 00                	push   $0x0
  pushl $42
80105714:	6a 2a                	push   $0x2a
  jmp alltraps
80105716:	e9 49 f9 ff ff       	jmp    80105064 <alltraps>

8010571b <vector43>:
.globl vector43
vector43:
  pushl $0
8010571b:	6a 00                	push   $0x0
  pushl $43
8010571d:	6a 2b                	push   $0x2b
  jmp alltraps
8010571f:	e9 40 f9 ff ff       	jmp    80105064 <alltraps>

80105724 <vector44>:
.globl vector44
vector44:
  pushl $0
80105724:	6a 00                	push   $0x0
  pushl $44
80105726:	6a 2c                	push   $0x2c
  jmp alltraps
80105728:	e9 37 f9 ff ff       	jmp    80105064 <alltraps>

8010572d <vector45>:
.globl vector45
vector45:
  pushl $0
8010572d:	6a 00                	push   $0x0
  pushl $45
8010572f:	6a 2d                	push   $0x2d
  jmp alltraps
80105731:	e9 2e f9 ff ff       	jmp    80105064 <alltraps>

80105736 <vector46>:
.globl vector46
vector46:
  pushl $0
80105736:	6a 00                	push   $0x0
  pushl $46
80105738:	6a 2e                	push   $0x2e
  jmp alltraps
8010573a:	e9 25 f9 ff ff       	jmp    80105064 <alltraps>

8010573f <vector47>:
.globl vector47
vector47:
  pushl $0
8010573f:	6a 00                	push   $0x0
  pushl $47
80105741:	6a 2f                	push   $0x2f
  jmp alltraps
80105743:	e9 1c f9 ff ff       	jmp    80105064 <alltraps>

80105748 <vector48>:
.globl vector48
vector48:
  pushl $0
80105748:	6a 00                	push   $0x0
  pushl $48
8010574a:	6a 30                	push   $0x30
  jmp alltraps
8010574c:	e9 13 f9 ff ff       	jmp    80105064 <alltraps>

80105751 <vector49>:
.globl vector49
vector49:
  pushl $0
80105751:	6a 00                	push   $0x0
  pushl $49
80105753:	6a 31                	push   $0x31
  jmp alltraps
80105755:	e9 0a f9 ff ff       	jmp    80105064 <alltraps>

8010575a <vector50>:
.globl vector50
vector50:
  pushl $0
8010575a:	6a 00                	push   $0x0
  pushl $50
8010575c:	6a 32                	push   $0x32
  jmp alltraps
8010575e:	e9 01 f9 ff ff       	jmp    80105064 <alltraps>

80105763 <vector51>:
.globl vector51
vector51:
  pushl $0
80105763:	6a 00                	push   $0x0
  pushl $51
80105765:	6a 33                	push   $0x33
  jmp alltraps
80105767:	e9 f8 f8 ff ff       	jmp    80105064 <alltraps>

8010576c <vector52>:
.globl vector52
vector52:
  pushl $0
8010576c:	6a 00                	push   $0x0
  pushl $52
8010576e:	6a 34                	push   $0x34
  jmp alltraps
80105770:	e9 ef f8 ff ff       	jmp    80105064 <alltraps>

80105775 <vector53>:
.globl vector53
vector53:
  pushl $0
80105775:	6a 00                	push   $0x0
  pushl $53
80105777:	6a 35                	push   $0x35
  jmp alltraps
80105779:	e9 e6 f8 ff ff       	jmp    80105064 <alltraps>

8010577e <vector54>:
.globl vector54
vector54:
  pushl $0
8010577e:	6a 00                	push   $0x0
  pushl $54
80105780:	6a 36                	push   $0x36
  jmp alltraps
80105782:	e9 dd f8 ff ff       	jmp    80105064 <alltraps>

80105787 <vector55>:
.globl vector55
vector55:
  pushl $0
80105787:	6a 00                	push   $0x0
  pushl $55
80105789:	6a 37                	push   $0x37
  jmp alltraps
8010578b:	e9 d4 f8 ff ff       	jmp    80105064 <alltraps>

80105790 <vector56>:
.globl vector56
vector56:
  pushl $0
80105790:	6a 00                	push   $0x0
  pushl $56
80105792:	6a 38                	push   $0x38
  jmp alltraps
80105794:	e9 cb f8 ff ff       	jmp    80105064 <alltraps>

80105799 <vector57>:
.globl vector57
vector57:
  pushl $0
80105799:	6a 00                	push   $0x0
  pushl $57
8010579b:	6a 39                	push   $0x39
  jmp alltraps
8010579d:	e9 c2 f8 ff ff       	jmp    80105064 <alltraps>

801057a2 <vector58>:
.globl vector58
vector58:
  pushl $0
801057a2:	6a 00                	push   $0x0
  pushl $58
801057a4:	6a 3a                	push   $0x3a
  jmp alltraps
801057a6:	e9 b9 f8 ff ff       	jmp    80105064 <alltraps>

801057ab <vector59>:
.globl vector59
vector59:
  pushl $0
801057ab:	6a 00                	push   $0x0
  pushl $59
801057ad:	6a 3b                	push   $0x3b
  jmp alltraps
801057af:	e9 b0 f8 ff ff       	jmp    80105064 <alltraps>

801057b4 <vector60>:
.globl vector60
vector60:
  pushl $0
801057b4:	6a 00                	push   $0x0
  pushl $60
801057b6:	6a 3c                	push   $0x3c
  jmp alltraps
801057b8:	e9 a7 f8 ff ff       	jmp    80105064 <alltraps>

801057bd <vector61>:
.globl vector61
vector61:
  pushl $0
801057bd:	6a 00                	push   $0x0
  pushl $61
801057bf:	6a 3d                	push   $0x3d
  jmp alltraps
801057c1:	e9 9e f8 ff ff       	jmp    80105064 <alltraps>

801057c6 <vector62>:
.globl vector62
vector62:
  pushl $0
801057c6:	6a 00                	push   $0x0
  pushl $62
801057c8:	6a 3e                	push   $0x3e
  jmp alltraps
801057ca:	e9 95 f8 ff ff       	jmp    80105064 <alltraps>

801057cf <vector63>:
.globl vector63
vector63:
  pushl $0
801057cf:	6a 00                	push   $0x0
  pushl $63
801057d1:	6a 3f                	push   $0x3f
  jmp alltraps
801057d3:	e9 8c f8 ff ff       	jmp    80105064 <alltraps>

801057d8 <vector64>:
.globl vector64
vector64:
  pushl $0
801057d8:	6a 00                	push   $0x0
  pushl $64
801057da:	6a 40                	push   $0x40
  jmp alltraps
801057dc:	e9 83 f8 ff ff       	jmp    80105064 <alltraps>

801057e1 <vector65>:
.globl vector65
vector65:
  pushl $0
801057e1:	6a 00                	push   $0x0
  pushl $65
801057e3:	6a 41                	push   $0x41
  jmp alltraps
801057e5:	e9 7a f8 ff ff       	jmp    80105064 <alltraps>

801057ea <vector66>:
.globl vector66
vector66:
  pushl $0
801057ea:	6a 00                	push   $0x0
  pushl $66
801057ec:	6a 42                	push   $0x42
  jmp alltraps
801057ee:	e9 71 f8 ff ff       	jmp    80105064 <alltraps>

801057f3 <vector67>:
.globl vector67
vector67:
  pushl $0
801057f3:	6a 00                	push   $0x0
  pushl $67
801057f5:	6a 43                	push   $0x43
  jmp alltraps
801057f7:	e9 68 f8 ff ff       	jmp    80105064 <alltraps>

801057fc <vector68>:
.globl vector68
vector68:
  pushl $0
801057fc:	6a 00                	push   $0x0
  pushl $68
801057fe:	6a 44                	push   $0x44
  jmp alltraps
80105800:	e9 5f f8 ff ff       	jmp    80105064 <alltraps>

80105805 <vector69>:
.globl vector69
vector69:
  pushl $0
80105805:	6a 00                	push   $0x0
  pushl $69
80105807:	6a 45                	push   $0x45
  jmp alltraps
80105809:	e9 56 f8 ff ff       	jmp    80105064 <alltraps>

8010580e <vector70>:
.globl vector70
vector70:
  pushl $0
8010580e:	6a 00                	push   $0x0
  pushl $70
80105810:	6a 46                	push   $0x46
  jmp alltraps
80105812:	e9 4d f8 ff ff       	jmp    80105064 <alltraps>

80105817 <vector71>:
.globl vector71
vector71:
  pushl $0
80105817:	6a 00                	push   $0x0
  pushl $71
80105819:	6a 47                	push   $0x47
  jmp alltraps
8010581b:	e9 44 f8 ff ff       	jmp    80105064 <alltraps>

80105820 <vector72>:
.globl vector72
vector72:
  pushl $0
80105820:	6a 00                	push   $0x0
  pushl $72
80105822:	6a 48                	push   $0x48
  jmp alltraps
80105824:	e9 3b f8 ff ff       	jmp    80105064 <alltraps>

80105829 <vector73>:
.globl vector73
vector73:
  pushl $0
80105829:	6a 00                	push   $0x0
  pushl $73
8010582b:	6a 49                	push   $0x49
  jmp alltraps
8010582d:	e9 32 f8 ff ff       	jmp    80105064 <alltraps>

80105832 <vector74>:
.globl vector74
vector74:
  pushl $0
80105832:	6a 00                	push   $0x0
  pushl $74
80105834:	6a 4a                	push   $0x4a
  jmp alltraps
80105836:	e9 29 f8 ff ff       	jmp    80105064 <alltraps>

8010583b <vector75>:
.globl vector75
vector75:
  pushl $0
8010583b:	6a 00                	push   $0x0
  pushl $75
8010583d:	6a 4b                	push   $0x4b
  jmp alltraps
8010583f:	e9 20 f8 ff ff       	jmp    80105064 <alltraps>

80105844 <vector76>:
.globl vector76
vector76:
  pushl $0
80105844:	6a 00                	push   $0x0
  pushl $76
80105846:	6a 4c                	push   $0x4c
  jmp alltraps
80105848:	e9 17 f8 ff ff       	jmp    80105064 <alltraps>

8010584d <vector77>:
.globl vector77
vector77:
  pushl $0
8010584d:	6a 00                	push   $0x0
  pushl $77
8010584f:	6a 4d                	push   $0x4d
  jmp alltraps
80105851:	e9 0e f8 ff ff       	jmp    80105064 <alltraps>

80105856 <vector78>:
.globl vector78
vector78:
  pushl $0
80105856:	6a 00                	push   $0x0
  pushl $78
80105858:	6a 4e                	push   $0x4e
  jmp alltraps
8010585a:	e9 05 f8 ff ff       	jmp    80105064 <alltraps>

8010585f <vector79>:
.globl vector79
vector79:
  pushl $0
8010585f:	6a 00                	push   $0x0
  pushl $79
80105861:	6a 4f                	push   $0x4f
  jmp alltraps
80105863:	e9 fc f7 ff ff       	jmp    80105064 <alltraps>

80105868 <vector80>:
.globl vector80
vector80:
  pushl $0
80105868:	6a 00                	push   $0x0
  pushl $80
8010586a:	6a 50                	push   $0x50
  jmp alltraps
8010586c:	e9 f3 f7 ff ff       	jmp    80105064 <alltraps>

80105871 <vector81>:
.globl vector81
vector81:
  pushl $0
80105871:	6a 00                	push   $0x0
  pushl $81
80105873:	6a 51                	push   $0x51
  jmp alltraps
80105875:	e9 ea f7 ff ff       	jmp    80105064 <alltraps>

8010587a <vector82>:
.globl vector82
vector82:
  pushl $0
8010587a:	6a 00                	push   $0x0
  pushl $82
8010587c:	6a 52                	push   $0x52
  jmp alltraps
8010587e:	e9 e1 f7 ff ff       	jmp    80105064 <alltraps>

80105883 <vector83>:
.globl vector83
vector83:
  pushl $0
80105883:	6a 00                	push   $0x0
  pushl $83
80105885:	6a 53                	push   $0x53
  jmp alltraps
80105887:	e9 d8 f7 ff ff       	jmp    80105064 <alltraps>

8010588c <vector84>:
.globl vector84
vector84:
  pushl $0
8010588c:	6a 00                	push   $0x0
  pushl $84
8010588e:	6a 54                	push   $0x54
  jmp alltraps
80105890:	e9 cf f7 ff ff       	jmp    80105064 <alltraps>

80105895 <vector85>:
.globl vector85
vector85:
  pushl $0
80105895:	6a 00                	push   $0x0
  pushl $85
80105897:	6a 55                	push   $0x55
  jmp alltraps
80105899:	e9 c6 f7 ff ff       	jmp    80105064 <alltraps>

8010589e <vector86>:
.globl vector86
vector86:
  pushl $0
8010589e:	6a 00                	push   $0x0
  pushl $86
801058a0:	6a 56                	push   $0x56
  jmp alltraps
801058a2:	e9 bd f7 ff ff       	jmp    80105064 <alltraps>

801058a7 <vector87>:
.globl vector87
vector87:
  pushl $0
801058a7:	6a 00                	push   $0x0
  pushl $87
801058a9:	6a 57                	push   $0x57
  jmp alltraps
801058ab:	e9 b4 f7 ff ff       	jmp    80105064 <alltraps>

801058b0 <vector88>:
.globl vector88
vector88:
  pushl $0
801058b0:	6a 00                	push   $0x0
  pushl $88
801058b2:	6a 58                	push   $0x58
  jmp alltraps
801058b4:	e9 ab f7 ff ff       	jmp    80105064 <alltraps>

801058b9 <vector89>:
.globl vector89
vector89:
  pushl $0
801058b9:	6a 00                	push   $0x0
  pushl $89
801058bb:	6a 59                	push   $0x59
  jmp alltraps
801058bd:	e9 a2 f7 ff ff       	jmp    80105064 <alltraps>

801058c2 <vector90>:
.globl vector90
vector90:
  pushl $0
801058c2:	6a 00                	push   $0x0
  pushl $90
801058c4:	6a 5a                	push   $0x5a
  jmp alltraps
801058c6:	e9 99 f7 ff ff       	jmp    80105064 <alltraps>

801058cb <vector91>:
.globl vector91
vector91:
  pushl $0
801058cb:	6a 00                	push   $0x0
  pushl $91
801058cd:	6a 5b                	push   $0x5b
  jmp alltraps
801058cf:	e9 90 f7 ff ff       	jmp    80105064 <alltraps>

801058d4 <vector92>:
.globl vector92
vector92:
  pushl $0
801058d4:	6a 00                	push   $0x0
  pushl $92
801058d6:	6a 5c                	push   $0x5c
  jmp alltraps
801058d8:	e9 87 f7 ff ff       	jmp    80105064 <alltraps>

801058dd <vector93>:
.globl vector93
vector93:
  pushl $0
801058dd:	6a 00                	push   $0x0
  pushl $93
801058df:	6a 5d                	push   $0x5d
  jmp alltraps
801058e1:	e9 7e f7 ff ff       	jmp    80105064 <alltraps>

801058e6 <vector94>:
.globl vector94
vector94:
  pushl $0
801058e6:	6a 00                	push   $0x0
  pushl $94
801058e8:	6a 5e                	push   $0x5e
  jmp alltraps
801058ea:	e9 75 f7 ff ff       	jmp    80105064 <alltraps>

801058ef <vector95>:
.globl vector95
vector95:
  pushl $0
801058ef:	6a 00                	push   $0x0
  pushl $95
801058f1:	6a 5f                	push   $0x5f
  jmp alltraps
801058f3:	e9 6c f7 ff ff       	jmp    80105064 <alltraps>

801058f8 <vector96>:
.globl vector96
vector96:
  pushl $0
801058f8:	6a 00                	push   $0x0
  pushl $96
801058fa:	6a 60                	push   $0x60
  jmp alltraps
801058fc:	e9 63 f7 ff ff       	jmp    80105064 <alltraps>

80105901 <vector97>:
.globl vector97
vector97:
  pushl $0
80105901:	6a 00                	push   $0x0
  pushl $97
80105903:	6a 61                	push   $0x61
  jmp alltraps
80105905:	e9 5a f7 ff ff       	jmp    80105064 <alltraps>

8010590a <vector98>:
.globl vector98
vector98:
  pushl $0
8010590a:	6a 00                	push   $0x0
  pushl $98
8010590c:	6a 62                	push   $0x62
  jmp alltraps
8010590e:	e9 51 f7 ff ff       	jmp    80105064 <alltraps>

80105913 <vector99>:
.globl vector99
vector99:
  pushl $0
80105913:	6a 00                	push   $0x0
  pushl $99
80105915:	6a 63                	push   $0x63
  jmp alltraps
80105917:	e9 48 f7 ff ff       	jmp    80105064 <alltraps>

8010591c <vector100>:
.globl vector100
vector100:
  pushl $0
8010591c:	6a 00                	push   $0x0
  pushl $100
8010591e:	6a 64                	push   $0x64
  jmp alltraps
80105920:	e9 3f f7 ff ff       	jmp    80105064 <alltraps>

80105925 <vector101>:
.globl vector101
vector101:
  pushl $0
80105925:	6a 00                	push   $0x0
  pushl $101
80105927:	6a 65                	push   $0x65
  jmp alltraps
80105929:	e9 36 f7 ff ff       	jmp    80105064 <alltraps>

8010592e <vector102>:
.globl vector102
vector102:
  pushl $0
8010592e:	6a 00                	push   $0x0
  pushl $102
80105930:	6a 66                	push   $0x66
  jmp alltraps
80105932:	e9 2d f7 ff ff       	jmp    80105064 <alltraps>

80105937 <vector103>:
.globl vector103
vector103:
  pushl $0
80105937:	6a 00                	push   $0x0
  pushl $103
80105939:	6a 67                	push   $0x67
  jmp alltraps
8010593b:	e9 24 f7 ff ff       	jmp    80105064 <alltraps>

80105940 <vector104>:
.globl vector104
vector104:
  pushl $0
80105940:	6a 00                	push   $0x0
  pushl $104
80105942:	6a 68                	push   $0x68
  jmp alltraps
80105944:	e9 1b f7 ff ff       	jmp    80105064 <alltraps>

80105949 <vector105>:
.globl vector105
vector105:
  pushl $0
80105949:	6a 00                	push   $0x0
  pushl $105
8010594b:	6a 69                	push   $0x69
  jmp alltraps
8010594d:	e9 12 f7 ff ff       	jmp    80105064 <alltraps>

80105952 <vector106>:
.globl vector106
vector106:
  pushl $0
80105952:	6a 00                	push   $0x0
  pushl $106
80105954:	6a 6a                	push   $0x6a
  jmp alltraps
80105956:	e9 09 f7 ff ff       	jmp    80105064 <alltraps>

8010595b <vector107>:
.globl vector107
vector107:
  pushl $0
8010595b:	6a 00                	push   $0x0
  pushl $107
8010595d:	6a 6b                	push   $0x6b
  jmp alltraps
8010595f:	e9 00 f7 ff ff       	jmp    80105064 <alltraps>

80105964 <vector108>:
.globl vector108
vector108:
  pushl $0
80105964:	6a 00                	push   $0x0
  pushl $108
80105966:	6a 6c                	push   $0x6c
  jmp alltraps
80105968:	e9 f7 f6 ff ff       	jmp    80105064 <alltraps>

8010596d <vector109>:
.globl vector109
vector109:
  pushl $0
8010596d:	6a 00                	push   $0x0
  pushl $109
8010596f:	6a 6d                	push   $0x6d
  jmp alltraps
80105971:	e9 ee f6 ff ff       	jmp    80105064 <alltraps>

80105976 <vector110>:
.globl vector110
vector110:
  pushl $0
80105976:	6a 00                	push   $0x0
  pushl $110
80105978:	6a 6e                	push   $0x6e
  jmp alltraps
8010597a:	e9 e5 f6 ff ff       	jmp    80105064 <alltraps>

8010597f <vector111>:
.globl vector111
vector111:
  pushl $0
8010597f:	6a 00                	push   $0x0
  pushl $111
80105981:	6a 6f                	push   $0x6f
  jmp alltraps
80105983:	e9 dc f6 ff ff       	jmp    80105064 <alltraps>

80105988 <vector112>:
.globl vector112
vector112:
  pushl $0
80105988:	6a 00                	push   $0x0
  pushl $112
8010598a:	6a 70                	push   $0x70
  jmp alltraps
8010598c:	e9 d3 f6 ff ff       	jmp    80105064 <alltraps>

80105991 <vector113>:
.globl vector113
vector113:
  pushl $0
80105991:	6a 00                	push   $0x0
  pushl $113
80105993:	6a 71                	push   $0x71
  jmp alltraps
80105995:	e9 ca f6 ff ff       	jmp    80105064 <alltraps>

8010599a <vector114>:
.globl vector114
vector114:
  pushl $0
8010599a:	6a 00                	push   $0x0
  pushl $114
8010599c:	6a 72                	push   $0x72
  jmp alltraps
8010599e:	e9 c1 f6 ff ff       	jmp    80105064 <alltraps>

801059a3 <vector115>:
.globl vector115
vector115:
  pushl $0
801059a3:	6a 00                	push   $0x0
  pushl $115
801059a5:	6a 73                	push   $0x73
  jmp alltraps
801059a7:	e9 b8 f6 ff ff       	jmp    80105064 <alltraps>

801059ac <vector116>:
.globl vector116
vector116:
  pushl $0
801059ac:	6a 00                	push   $0x0
  pushl $116
801059ae:	6a 74                	push   $0x74
  jmp alltraps
801059b0:	e9 af f6 ff ff       	jmp    80105064 <alltraps>

801059b5 <vector117>:
.globl vector117
vector117:
  pushl $0
801059b5:	6a 00                	push   $0x0
  pushl $117
801059b7:	6a 75                	push   $0x75
  jmp alltraps
801059b9:	e9 a6 f6 ff ff       	jmp    80105064 <alltraps>

801059be <vector118>:
.globl vector118
vector118:
  pushl $0
801059be:	6a 00                	push   $0x0
  pushl $118
801059c0:	6a 76                	push   $0x76
  jmp alltraps
801059c2:	e9 9d f6 ff ff       	jmp    80105064 <alltraps>

801059c7 <vector119>:
.globl vector119
vector119:
  pushl $0
801059c7:	6a 00                	push   $0x0
  pushl $119
801059c9:	6a 77                	push   $0x77
  jmp alltraps
801059cb:	e9 94 f6 ff ff       	jmp    80105064 <alltraps>

801059d0 <vector120>:
.globl vector120
vector120:
  pushl $0
801059d0:	6a 00                	push   $0x0
  pushl $120
801059d2:	6a 78                	push   $0x78
  jmp alltraps
801059d4:	e9 8b f6 ff ff       	jmp    80105064 <alltraps>

801059d9 <vector121>:
.globl vector121
vector121:
  pushl $0
801059d9:	6a 00                	push   $0x0
  pushl $121
801059db:	6a 79                	push   $0x79
  jmp alltraps
801059dd:	e9 82 f6 ff ff       	jmp    80105064 <alltraps>

801059e2 <vector122>:
.globl vector122
vector122:
  pushl $0
801059e2:	6a 00                	push   $0x0
  pushl $122
801059e4:	6a 7a                	push   $0x7a
  jmp alltraps
801059e6:	e9 79 f6 ff ff       	jmp    80105064 <alltraps>

801059eb <vector123>:
.globl vector123
vector123:
  pushl $0
801059eb:	6a 00                	push   $0x0
  pushl $123
801059ed:	6a 7b                	push   $0x7b
  jmp alltraps
801059ef:	e9 70 f6 ff ff       	jmp    80105064 <alltraps>

801059f4 <vector124>:
.globl vector124
vector124:
  pushl $0
801059f4:	6a 00                	push   $0x0
  pushl $124
801059f6:	6a 7c                	push   $0x7c
  jmp alltraps
801059f8:	e9 67 f6 ff ff       	jmp    80105064 <alltraps>

801059fd <vector125>:
.globl vector125
vector125:
  pushl $0
801059fd:	6a 00                	push   $0x0
  pushl $125
801059ff:	6a 7d                	push   $0x7d
  jmp alltraps
80105a01:	e9 5e f6 ff ff       	jmp    80105064 <alltraps>

80105a06 <vector126>:
.globl vector126
vector126:
  pushl $0
80105a06:	6a 00                	push   $0x0
  pushl $126
80105a08:	6a 7e                	push   $0x7e
  jmp alltraps
80105a0a:	e9 55 f6 ff ff       	jmp    80105064 <alltraps>

80105a0f <vector127>:
.globl vector127
vector127:
  pushl $0
80105a0f:	6a 00                	push   $0x0
  pushl $127
80105a11:	6a 7f                	push   $0x7f
  jmp alltraps
80105a13:	e9 4c f6 ff ff       	jmp    80105064 <alltraps>

80105a18 <vector128>:
.globl vector128
vector128:
  pushl $0
80105a18:	6a 00                	push   $0x0
  pushl $128
80105a1a:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80105a1f:	e9 40 f6 ff ff       	jmp    80105064 <alltraps>

80105a24 <vector129>:
.globl vector129
vector129:
  pushl $0
80105a24:	6a 00                	push   $0x0
  pushl $129
80105a26:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105a2b:	e9 34 f6 ff ff       	jmp    80105064 <alltraps>

80105a30 <vector130>:
.globl vector130
vector130:
  pushl $0
80105a30:	6a 00                	push   $0x0
  pushl $130
80105a32:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105a37:	e9 28 f6 ff ff       	jmp    80105064 <alltraps>

80105a3c <vector131>:
.globl vector131
vector131:
  pushl $0
80105a3c:	6a 00                	push   $0x0
  pushl $131
80105a3e:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80105a43:	e9 1c f6 ff ff       	jmp    80105064 <alltraps>

80105a48 <vector132>:
.globl vector132
vector132:
  pushl $0
80105a48:	6a 00                	push   $0x0
  pushl $132
80105a4a:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80105a4f:	e9 10 f6 ff ff       	jmp    80105064 <alltraps>

80105a54 <vector133>:
.globl vector133
vector133:
  pushl $0
80105a54:	6a 00                	push   $0x0
  pushl $133
80105a56:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80105a5b:	e9 04 f6 ff ff       	jmp    80105064 <alltraps>

80105a60 <vector134>:
.globl vector134
vector134:
  pushl $0
80105a60:	6a 00                	push   $0x0
  pushl $134
80105a62:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80105a67:	e9 f8 f5 ff ff       	jmp    80105064 <alltraps>

80105a6c <vector135>:
.globl vector135
vector135:
  pushl $0
80105a6c:	6a 00                	push   $0x0
  pushl $135
80105a6e:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80105a73:	e9 ec f5 ff ff       	jmp    80105064 <alltraps>

80105a78 <vector136>:
.globl vector136
vector136:
  pushl $0
80105a78:	6a 00                	push   $0x0
  pushl $136
80105a7a:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80105a7f:	e9 e0 f5 ff ff       	jmp    80105064 <alltraps>

80105a84 <vector137>:
.globl vector137
vector137:
  pushl $0
80105a84:	6a 00                	push   $0x0
  pushl $137
80105a86:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80105a8b:	e9 d4 f5 ff ff       	jmp    80105064 <alltraps>

80105a90 <vector138>:
.globl vector138
vector138:
  pushl $0
80105a90:	6a 00                	push   $0x0
  pushl $138
80105a92:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80105a97:	e9 c8 f5 ff ff       	jmp    80105064 <alltraps>

80105a9c <vector139>:
.globl vector139
vector139:
  pushl $0
80105a9c:	6a 00                	push   $0x0
  pushl $139
80105a9e:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80105aa3:	e9 bc f5 ff ff       	jmp    80105064 <alltraps>

80105aa8 <vector140>:
.globl vector140
vector140:
  pushl $0
80105aa8:	6a 00                	push   $0x0
  pushl $140
80105aaa:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80105aaf:	e9 b0 f5 ff ff       	jmp    80105064 <alltraps>

80105ab4 <vector141>:
.globl vector141
vector141:
  pushl $0
80105ab4:	6a 00                	push   $0x0
  pushl $141
80105ab6:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80105abb:	e9 a4 f5 ff ff       	jmp    80105064 <alltraps>

80105ac0 <vector142>:
.globl vector142
vector142:
  pushl $0
80105ac0:	6a 00                	push   $0x0
  pushl $142
80105ac2:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105ac7:	e9 98 f5 ff ff       	jmp    80105064 <alltraps>

80105acc <vector143>:
.globl vector143
vector143:
  pushl $0
80105acc:	6a 00                	push   $0x0
  pushl $143
80105ace:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105ad3:	e9 8c f5 ff ff       	jmp    80105064 <alltraps>

80105ad8 <vector144>:
.globl vector144
vector144:
  pushl $0
80105ad8:	6a 00                	push   $0x0
  pushl $144
80105ada:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80105adf:	e9 80 f5 ff ff       	jmp    80105064 <alltraps>

80105ae4 <vector145>:
.globl vector145
vector145:
  pushl $0
80105ae4:	6a 00                	push   $0x0
  pushl $145
80105ae6:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105aeb:	e9 74 f5 ff ff       	jmp    80105064 <alltraps>

80105af0 <vector146>:
.globl vector146
vector146:
  pushl $0
80105af0:	6a 00                	push   $0x0
  pushl $146
80105af2:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105af7:	e9 68 f5 ff ff       	jmp    80105064 <alltraps>

80105afc <vector147>:
.globl vector147
vector147:
  pushl $0
80105afc:	6a 00                	push   $0x0
  pushl $147
80105afe:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105b03:	e9 5c f5 ff ff       	jmp    80105064 <alltraps>

80105b08 <vector148>:
.globl vector148
vector148:
  pushl $0
80105b08:	6a 00                	push   $0x0
  pushl $148
80105b0a:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105b0f:	e9 50 f5 ff ff       	jmp    80105064 <alltraps>

80105b14 <vector149>:
.globl vector149
vector149:
  pushl $0
80105b14:	6a 00                	push   $0x0
  pushl $149
80105b16:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105b1b:	e9 44 f5 ff ff       	jmp    80105064 <alltraps>

80105b20 <vector150>:
.globl vector150
vector150:
  pushl $0
80105b20:	6a 00                	push   $0x0
  pushl $150
80105b22:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105b27:	e9 38 f5 ff ff       	jmp    80105064 <alltraps>

80105b2c <vector151>:
.globl vector151
vector151:
  pushl $0
80105b2c:	6a 00                	push   $0x0
  pushl $151
80105b2e:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105b33:	e9 2c f5 ff ff       	jmp    80105064 <alltraps>

80105b38 <vector152>:
.globl vector152
vector152:
  pushl $0
80105b38:	6a 00                	push   $0x0
  pushl $152
80105b3a:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80105b3f:	e9 20 f5 ff ff       	jmp    80105064 <alltraps>

80105b44 <vector153>:
.globl vector153
vector153:
  pushl $0
80105b44:	6a 00                	push   $0x0
  pushl $153
80105b46:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80105b4b:	e9 14 f5 ff ff       	jmp    80105064 <alltraps>

80105b50 <vector154>:
.globl vector154
vector154:
  pushl $0
80105b50:	6a 00                	push   $0x0
  pushl $154
80105b52:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105b57:	e9 08 f5 ff ff       	jmp    80105064 <alltraps>

80105b5c <vector155>:
.globl vector155
vector155:
  pushl $0
80105b5c:	6a 00                	push   $0x0
  pushl $155
80105b5e:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80105b63:	e9 fc f4 ff ff       	jmp    80105064 <alltraps>

80105b68 <vector156>:
.globl vector156
vector156:
  pushl $0
80105b68:	6a 00                	push   $0x0
  pushl $156
80105b6a:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80105b6f:	e9 f0 f4 ff ff       	jmp    80105064 <alltraps>

80105b74 <vector157>:
.globl vector157
vector157:
  pushl $0
80105b74:	6a 00                	push   $0x0
  pushl $157
80105b76:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80105b7b:	e9 e4 f4 ff ff       	jmp    80105064 <alltraps>

80105b80 <vector158>:
.globl vector158
vector158:
  pushl $0
80105b80:	6a 00                	push   $0x0
  pushl $158
80105b82:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80105b87:	e9 d8 f4 ff ff       	jmp    80105064 <alltraps>

80105b8c <vector159>:
.globl vector159
vector159:
  pushl $0
80105b8c:	6a 00                	push   $0x0
  pushl $159
80105b8e:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80105b93:	e9 cc f4 ff ff       	jmp    80105064 <alltraps>

80105b98 <vector160>:
.globl vector160
vector160:
  pushl $0
80105b98:	6a 00                	push   $0x0
  pushl $160
80105b9a:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80105b9f:	e9 c0 f4 ff ff       	jmp    80105064 <alltraps>

80105ba4 <vector161>:
.globl vector161
vector161:
  pushl $0
80105ba4:	6a 00                	push   $0x0
  pushl $161
80105ba6:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105bab:	e9 b4 f4 ff ff       	jmp    80105064 <alltraps>

80105bb0 <vector162>:
.globl vector162
vector162:
  pushl $0
80105bb0:	6a 00                	push   $0x0
  pushl $162
80105bb2:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105bb7:	e9 a8 f4 ff ff       	jmp    80105064 <alltraps>

80105bbc <vector163>:
.globl vector163
vector163:
  pushl $0
80105bbc:	6a 00                	push   $0x0
  pushl $163
80105bbe:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105bc3:	e9 9c f4 ff ff       	jmp    80105064 <alltraps>

80105bc8 <vector164>:
.globl vector164
vector164:
  pushl $0
80105bc8:	6a 00                	push   $0x0
  pushl $164
80105bca:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105bcf:	e9 90 f4 ff ff       	jmp    80105064 <alltraps>

80105bd4 <vector165>:
.globl vector165
vector165:
  pushl $0
80105bd4:	6a 00                	push   $0x0
  pushl $165
80105bd6:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105bdb:	e9 84 f4 ff ff       	jmp    80105064 <alltraps>

80105be0 <vector166>:
.globl vector166
vector166:
  pushl $0
80105be0:	6a 00                	push   $0x0
  pushl $166
80105be2:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105be7:	e9 78 f4 ff ff       	jmp    80105064 <alltraps>

80105bec <vector167>:
.globl vector167
vector167:
  pushl $0
80105bec:	6a 00                	push   $0x0
  pushl $167
80105bee:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105bf3:	e9 6c f4 ff ff       	jmp    80105064 <alltraps>

80105bf8 <vector168>:
.globl vector168
vector168:
  pushl $0
80105bf8:	6a 00                	push   $0x0
  pushl $168
80105bfa:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105bff:	e9 60 f4 ff ff       	jmp    80105064 <alltraps>

80105c04 <vector169>:
.globl vector169
vector169:
  pushl $0
80105c04:	6a 00                	push   $0x0
  pushl $169
80105c06:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105c0b:	e9 54 f4 ff ff       	jmp    80105064 <alltraps>

80105c10 <vector170>:
.globl vector170
vector170:
  pushl $0
80105c10:	6a 00                	push   $0x0
  pushl $170
80105c12:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105c17:	e9 48 f4 ff ff       	jmp    80105064 <alltraps>

80105c1c <vector171>:
.globl vector171
vector171:
  pushl $0
80105c1c:	6a 00                	push   $0x0
  pushl $171
80105c1e:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105c23:	e9 3c f4 ff ff       	jmp    80105064 <alltraps>

80105c28 <vector172>:
.globl vector172
vector172:
  pushl $0
80105c28:	6a 00                	push   $0x0
  pushl $172
80105c2a:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80105c2f:	e9 30 f4 ff ff       	jmp    80105064 <alltraps>

80105c34 <vector173>:
.globl vector173
vector173:
  pushl $0
80105c34:	6a 00                	push   $0x0
  pushl $173
80105c36:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105c3b:	e9 24 f4 ff ff       	jmp    80105064 <alltraps>

80105c40 <vector174>:
.globl vector174
vector174:
  pushl $0
80105c40:	6a 00                	push   $0x0
  pushl $174
80105c42:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105c47:	e9 18 f4 ff ff       	jmp    80105064 <alltraps>

80105c4c <vector175>:
.globl vector175
vector175:
  pushl $0
80105c4c:	6a 00                	push   $0x0
  pushl $175
80105c4e:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105c53:	e9 0c f4 ff ff       	jmp    80105064 <alltraps>

80105c58 <vector176>:
.globl vector176
vector176:
  pushl $0
80105c58:	6a 00                	push   $0x0
  pushl $176
80105c5a:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105c5f:	e9 00 f4 ff ff       	jmp    80105064 <alltraps>

80105c64 <vector177>:
.globl vector177
vector177:
  pushl $0
80105c64:	6a 00                	push   $0x0
  pushl $177
80105c66:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105c6b:	e9 f4 f3 ff ff       	jmp    80105064 <alltraps>

80105c70 <vector178>:
.globl vector178
vector178:
  pushl $0
80105c70:	6a 00                	push   $0x0
  pushl $178
80105c72:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105c77:	e9 e8 f3 ff ff       	jmp    80105064 <alltraps>

80105c7c <vector179>:
.globl vector179
vector179:
  pushl $0
80105c7c:	6a 00                	push   $0x0
  pushl $179
80105c7e:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80105c83:	e9 dc f3 ff ff       	jmp    80105064 <alltraps>

80105c88 <vector180>:
.globl vector180
vector180:
  pushl $0
80105c88:	6a 00                	push   $0x0
  pushl $180
80105c8a:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105c8f:	e9 d0 f3 ff ff       	jmp    80105064 <alltraps>

80105c94 <vector181>:
.globl vector181
vector181:
  pushl $0
80105c94:	6a 00                	push   $0x0
  pushl $181
80105c96:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105c9b:	e9 c4 f3 ff ff       	jmp    80105064 <alltraps>

80105ca0 <vector182>:
.globl vector182
vector182:
  pushl $0
80105ca0:	6a 00                	push   $0x0
  pushl $182
80105ca2:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105ca7:	e9 b8 f3 ff ff       	jmp    80105064 <alltraps>

80105cac <vector183>:
.globl vector183
vector183:
  pushl $0
80105cac:	6a 00                	push   $0x0
  pushl $183
80105cae:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105cb3:	e9 ac f3 ff ff       	jmp    80105064 <alltraps>

80105cb8 <vector184>:
.globl vector184
vector184:
  pushl $0
80105cb8:	6a 00                	push   $0x0
  pushl $184
80105cba:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105cbf:	e9 a0 f3 ff ff       	jmp    80105064 <alltraps>

80105cc4 <vector185>:
.globl vector185
vector185:
  pushl $0
80105cc4:	6a 00                	push   $0x0
  pushl $185
80105cc6:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105ccb:	e9 94 f3 ff ff       	jmp    80105064 <alltraps>

80105cd0 <vector186>:
.globl vector186
vector186:
  pushl $0
80105cd0:	6a 00                	push   $0x0
  pushl $186
80105cd2:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105cd7:	e9 88 f3 ff ff       	jmp    80105064 <alltraps>

80105cdc <vector187>:
.globl vector187
vector187:
  pushl $0
80105cdc:	6a 00                	push   $0x0
  pushl $187
80105cde:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105ce3:	e9 7c f3 ff ff       	jmp    80105064 <alltraps>

80105ce8 <vector188>:
.globl vector188
vector188:
  pushl $0
80105ce8:	6a 00                	push   $0x0
  pushl $188
80105cea:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105cef:	e9 70 f3 ff ff       	jmp    80105064 <alltraps>

80105cf4 <vector189>:
.globl vector189
vector189:
  pushl $0
80105cf4:	6a 00                	push   $0x0
  pushl $189
80105cf6:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105cfb:	e9 64 f3 ff ff       	jmp    80105064 <alltraps>

80105d00 <vector190>:
.globl vector190
vector190:
  pushl $0
80105d00:	6a 00                	push   $0x0
  pushl $190
80105d02:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105d07:	e9 58 f3 ff ff       	jmp    80105064 <alltraps>

80105d0c <vector191>:
.globl vector191
vector191:
  pushl $0
80105d0c:	6a 00                	push   $0x0
  pushl $191
80105d0e:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105d13:	e9 4c f3 ff ff       	jmp    80105064 <alltraps>

80105d18 <vector192>:
.globl vector192
vector192:
  pushl $0
80105d18:	6a 00                	push   $0x0
  pushl $192
80105d1a:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105d1f:	e9 40 f3 ff ff       	jmp    80105064 <alltraps>

80105d24 <vector193>:
.globl vector193
vector193:
  pushl $0
80105d24:	6a 00                	push   $0x0
  pushl $193
80105d26:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105d2b:	e9 34 f3 ff ff       	jmp    80105064 <alltraps>

80105d30 <vector194>:
.globl vector194
vector194:
  pushl $0
80105d30:	6a 00                	push   $0x0
  pushl $194
80105d32:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105d37:	e9 28 f3 ff ff       	jmp    80105064 <alltraps>

80105d3c <vector195>:
.globl vector195
vector195:
  pushl $0
80105d3c:	6a 00                	push   $0x0
  pushl $195
80105d3e:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105d43:	e9 1c f3 ff ff       	jmp    80105064 <alltraps>

80105d48 <vector196>:
.globl vector196
vector196:
  pushl $0
80105d48:	6a 00                	push   $0x0
  pushl $196
80105d4a:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105d4f:	e9 10 f3 ff ff       	jmp    80105064 <alltraps>

80105d54 <vector197>:
.globl vector197
vector197:
  pushl $0
80105d54:	6a 00                	push   $0x0
  pushl $197
80105d56:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105d5b:	e9 04 f3 ff ff       	jmp    80105064 <alltraps>

80105d60 <vector198>:
.globl vector198
vector198:
  pushl $0
80105d60:	6a 00                	push   $0x0
  pushl $198
80105d62:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105d67:	e9 f8 f2 ff ff       	jmp    80105064 <alltraps>

80105d6c <vector199>:
.globl vector199
vector199:
  pushl $0
80105d6c:	6a 00                	push   $0x0
  pushl $199
80105d6e:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105d73:	e9 ec f2 ff ff       	jmp    80105064 <alltraps>

80105d78 <vector200>:
.globl vector200
vector200:
  pushl $0
80105d78:	6a 00                	push   $0x0
  pushl $200
80105d7a:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105d7f:	e9 e0 f2 ff ff       	jmp    80105064 <alltraps>

80105d84 <vector201>:
.globl vector201
vector201:
  pushl $0
80105d84:	6a 00                	push   $0x0
  pushl $201
80105d86:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105d8b:	e9 d4 f2 ff ff       	jmp    80105064 <alltraps>

80105d90 <vector202>:
.globl vector202
vector202:
  pushl $0
80105d90:	6a 00                	push   $0x0
  pushl $202
80105d92:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105d97:	e9 c8 f2 ff ff       	jmp    80105064 <alltraps>

80105d9c <vector203>:
.globl vector203
vector203:
  pushl $0
80105d9c:	6a 00                	push   $0x0
  pushl $203
80105d9e:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105da3:	e9 bc f2 ff ff       	jmp    80105064 <alltraps>

80105da8 <vector204>:
.globl vector204
vector204:
  pushl $0
80105da8:	6a 00                	push   $0x0
  pushl $204
80105daa:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105daf:	e9 b0 f2 ff ff       	jmp    80105064 <alltraps>

80105db4 <vector205>:
.globl vector205
vector205:
  pushl $0
80105db4:	6a 00                	push   $0x0
  pushl $205
80105db6:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105dbb:	e9 a4 f2 ff ff       	jmp    80105064 <alltraps>

80105dc0 <vector206>:
.globl vector206
vector206:
  pushl $0
80105dc0:	6a 00                	push   $0x0
  pushl $206
80105dc2:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105dc7:	e9 98 f2 ff ff       	jmp    80105064 <alltraps>

80105dcc <vector207>:
.globl vector207
vector207:
  pushl $0
80105dcc:	6a 00                	push   $0x0
  pushl $207
80105dce:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105dd3:	e9 8c f2 ff ff       	jmp    80105064 <alltraps>

80105dd8 <vector208>:
.globl vector208
vector208:
  pushl $0
80105dd8:	6a 00                	push   $0x0
  pushl $208
80105dda:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105ddf:	e9 80 f2 ff ff       	jmp    80105064 <alltraps>

80105de4 <vector209>:
.globl vector209
vector209:
  pushl $0
80105de4:	6a 00                	push   $0x0
  pushl $209
80105de6:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105deb:	e9 74 f2 ff ff       	jmp    80105064 <alltraps>

80105df0 <vector210>:
.globl vector210
vector210:
  pushl $0
80105df0:	6a 00                	push   $0x0
  pushl $210
80105df2:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105df7:	e9 68 f2 ff ff       	jmp    80105064 <alltraps>

80105dfc <vector211>:
.globl vector211
vector211:
  pushl $0
80105dfc:	6a 00                	push   $0x0
  pushl $211
80105dfe:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105e03:	e9 5c f2 ff ff       	jmp    80105064 <alltraps>

80105e08 <vector212>:
.globl vector212
vector212:
  pushl $0
80105e08:	6a 00                	push   $0x0
  pushl $212
80105e0a:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105e0f:	e9 50 f2 ff ff       	jmp    80105064 <alltraps>

80105e14 <vector213>:
.globl vector213
vector213:
  pushl $0
80105e14:	6a 00                	push   $0x0
  pushl $213
80105e16:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105e1b:	e9 44 f2 ff ff       	jmp    80105064 <alltraps>

80105e20 <vector214>:
.globl vector214
vector214:
  pushl $0
80105e20:	6a 00                	push   $0x0
  pushl $214
80105e22:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105e27:	e9 38 f2 ff ff       	jmp    80105064 <alltraps>

80105e2c <vector215>:
.globl vector215
vector215:
  pushl $0
80105e2c:	6a 00                	push   $0x0
  pushl $215
80105e2e:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105e33:	e9 2c f2 ff ff       	jmp    80105064 <alltraps>

80105e38 <vector216>:
.globl vector216
vector216:
  pushl $0
80105e38:	6a 00                	push   $0x0
  pushl $216
80105e3a:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105e3f:	e9 20 f2 ff ff       	jmp    80105064 <alltraps>

80105e44 <vector217>:
.globl vector217
vector217:
  pushl $0
80105e44:	6a 00                	push   $0x0
  pushl $217
80105e46:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105e4b:	e9 14 f2 ff ff       	jmp    80105064 <alltraps>

80105e50 <vector218>:
.globl vector218
vector218:
  pushl $0
80105e50:	6a 00                	push   $0x0
  pushl $218
80105e52:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105e57:	e9 08 f2 ff ff       	jmp    80105064 <alltraps>

80105e5c <vector219>:
.globl vector219
vector219:
  pushl $0
80105e5c:	6a 00                	push   $0x0
  pushl $219
80105e5e:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105e63:	e9 fc f1 ff ff       	jmp    80105064 <alltraps>

80105e68 <vector220>:
.globl vector220
vector220:
  pushl $0
80105e68:	6a 00                	push   $0x0
  pushl $220
80105e6a:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105e6f:	e9 f0 f1 ff ff       	jmp    80105064 <alltraps>

80105e74 <vector221>:
.globl vector221
vector221:
  pushl $0
80105e74:	6a 00                	push   $0x0
  pushl $221
80105e76:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105e7b:	e9 e4 f1 ff ff       	jmp    80105064 <alltraps>

80105e80 <vector222>:
.globl vector222
vector222:
  pushl $0
80105e80:	6a 00                	push   $0x0
  pushl $222
80105e82:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105e87:	e9 d8 f1 ff ff       	jmp    80105064 <alltraps>

80105e8c <vector223>:
.globl vector223
vector223:
  pushl $0
80105e8c:	6a 00                	push   $0x0
  pushl $223
80105e8e:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105e93:	e9 cc f1 ff ff       	jmp    80105064 <alltraps>

80105e98 <vector224>:
.globl vector224
vector224:
  pushl $0
80105e98:	6a 00                	push   $0x0
  pushl $224
80105e9a:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105e9f:	e9 c0 f1 ff ff       	jmp    80105064 <alltraps>

80105ea4 <vector225>:
.globl vector225
vector225:
  pushl $0
80105ea4:	6a 00                	push   $0x0
  pushl $225
80105ea6:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105eab:	e9 b4 f1 ff ff       	jmp    80105064 <alltraps>

80105eb0 <vector226>:
.globl vector226
vector226:
  pushl $0
80105eb0:	6a 00                	push   $0x0
  pushl $226
80105eb2:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105eb7:	e9 a8 f1 ff ff       	jmp    80105064 <alltraps>

80105ebc <vector227>:
.globl vector227
vector227:
  pushl $0
80105ebc:	6a 00                	push   $0x0
  pushl $227
80105ebe:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105ec3:	e9 9c f1 ff ff       	jmp    80105064 <alltraps>

80105ec8 <vector228>:
.globl vector228
vector228:
  pushl $0
80105ec8:	6a 00                	push   $0x0
  pushl $228
80105eca:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105ecf:	e9 90 f1 ff ff       	jmp    80105064 <alltraps>

80105ed4 <vector229>:
.globl vector229
vector229:
  pushl $0
80105ed4:	6a 00                	push   $0x0
  pushl $229
80105ed6:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105edb:	e9 84 f1 ff ff       	jmp    80105064 <alltraps>

80105ee0 <vector230>:
.globl vector230
vector230:
  pushl $0
80105ee0:	6a 00                	push   $0x0
  pushl $230
80105ee2:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105ee7:	e9 78 f1 ff ff       	jmp    80105064 <alltraps>

80105eec <vector231>:
.globl vector231
vector231:
  pushl $0
80105eec:	6a 00                	push   $0x0
  pushl $231
80105eee:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105ef3:	e9 6c f1 ff ff       	jmp    80105064 <alltraps>

80105ef8 <vector232>:
.globl vector232
vector232:
  pushl $0
80105ef8:	6a 00                	push   $0x0
  pushl $232
80105efa:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105eff:	e9 60 f1 ff ff       	jmp    80105064 <alltraps>

80105f04 <vector233>:
.globl vector233
vector233:
  pushl $0
80105f04:	6a 00                	push   $0x0
  pushl $233
80105f06:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105f0b:	e9 54 f1 ff ff       	jmp    80105064 <alltraps>

80105f10 <vector234>:
.globl vector234
vector234:
  pushl $0
80105f10:	6a 00                	push   $0x0
  pushl $234
80105f12:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105f17:	e9 48 f1 ff ff       	jmp    80105064 <alltraps>

80105f1c <vector235>:
.globl vector235
vector235:
  pushl $0
80105f1c:	6a 00                	push   $0x0
  pushl $235
80105f1e:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105f23:	e9 3c f1 ff ff       	jmp    80105064 <alltraps>

80105f28 <vector236>:
.globl vector236
vector236:
  pushl $0
80105f28:	6a 00                	push   $0x0
  pushl $236
80105f2a:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105f2f:	e9 30 f1 ff ff       	jmp    80105064 <alltraps>

80105f34 <vector237>:
.globl vector237
vector237:
  pushl $0
80105f34:	6a 00                	push   $0x0
  pushl $237
80105f36:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105f3b:	e9 24 f1 ff ff       	jmp    80105064 <alltraps>

80105f40 <vector238>:
.globl vector238
vector238:
  pushl $0
80105f40:	6a 00                	push   $0x0
  pushl $238
80105f42:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105f47:	e9 18 f1 ff ff       	jmp    80105064 <alltraps>

80105f4c <vector239>:
.globl vector239
vector239:
  pushl $0
80105f4c:	6a 00                	push   $0x0
  pushl $239
80105f4e:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105f53:	e9 0c f1 ff ff       	jmp    80105064 <alltraps>

80105f58 <vector240>:
.globl vector240
vector240:
  pushl $0
80105f58:	6a 00                	push   $0x0
  pushl $240
80105f5a:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105f5f:	e9 00 f1 ff ff       	jmp    80105064 <alltraps>

80105f64 <vector241>:
.globl vector241
vector241:
  pushl $0
80105f64:	6a 00                	push   $0x0
  pushl $241
80105f66:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105f6b:	e9 f4 f0 ff ff       	jmp    80105064 <alltraps>

80105f70 <vector242>:
.globl vector242
vector242:
  pushl $0
80105f70:	6a 00                	push   $0x0
  pushl $242
80105f72:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105f77:	e9 e8 f0 ff ff       	jmp    80105064 <alltraps>

80105f7c <vector243>:
.globl vector243
vector243:
  pushl $0
80105f7c:	6a 00                	push   $0x0
  pushl $243
80105f7e:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105f83:	e9 dc f0 ff ff       	jmp    80105064 <alltraps>

80105f88 <vector244>:
.globl vector244
vector244:
  pushl $0
80105f88:	6a 00                	push   $0x0
  pushl $244
80105f8a:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105f8f:	e9 d0 f0 ff ff       	jmp    80105064 <alltraps>

80105f94 <vector245>:
.globl vector245
vector245:
  pushl $0
80105f94:	6a 00                	push   $0x0
  pushl $245
80105f96:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105f9b:	e9 c4 f0 ff ff       	jmp    80105064 <alltraps>

80105fa0 <vector246>:
.globl vector246
vector246:
  pushl $0
80105fa0:	6a 00                	push   $0x0
  pushl $246
80105fa2:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105fa7:	e9 b8 f0 ff ff       	jmp    80105064 <alltraps>

80105fac <vector247>:
.globl vector247
vector247:
  pushl $0
80105fac:	6a 00                	push   $0x0
  pushl $247
80105fae:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105fb3:	e9 ac f0 ff ff       	jmp    80105064 <alltraps>

80105fb8 <vector248>:
.globl vector248
vector248:
  pushl $0
80105fb8:	6a 00                	push   $0x0
  pushl $248
80105fba:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105fbf:	e9 a0 f0 ff ff       	jmp    80105064 <alltraps>

80105fc4 <vector249>:
.globl vector249
vector249:
  pushl $0
80105fc4:	6a 00                	push   $0x0
  pushl $249
80105fc6:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105fcb:	e9 94 f0 ff ff       	jmp    80105064 <alltraps>

80105fd0 <vector250>:
.globl vector250
vector250:
  pushl $0
80105fd0:	6a 00                	push   $0x0
  pushl $250
80105fd2:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105fd7:	e9 88 f0 ff ff       	jmp    80105064 <alltraps>

80105fdc <vector251>:
.globl vector251
vector251:
  pushl $0
80105fdc:	6a 00                	push   $0x0
  pushl $251
80105fde:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105fe3:	e9 7c f0 ff ff       	jmp    80105064 <alltraps>

80105fe8 <vector252>:
.globl vector252
vector252:
  pushl $0
80105fe8:	6a 00                	push   $0x0
  pushl $252
80105fea:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105fef:	e9 70 f0 ff ff       	jmp    80105064 <alltraps>

80105ff4 <vector253>:
.globl vector253
vector253:
  pushl $0
80105ff4:	6a 00                	push   $0x0
  pushl $253
80105ff6:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105ffb:	e9 64 f0 ff ff       	jmp    80105064 <alltraps>

80106000 <vector254>:
.globl vector254
vector254:
  pushl $0
80106000:	6a 00                	push   $0x0
  pushl $254
80106002:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106007:	e9 58 f0 ff ff       	jmp    80105064 <alltraps>

8010600c <vector255>:
.globl vector255
vector255:
  pushl $0
8010600c:	6a 00                	push   $0x0
  pushl $255
8010600e:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106013:	e9 4c f0 ff ff       	jmp    80105064 <alltraps>
80106018:	66 90                	xchg   %ax,%ax
8010601a:	66 90                	xchg   %ax,%ax
8010601c:	66 90                	xchg   %ax,%ax
8010601e:	66 90                	xchg   %ax,%ax

80106020 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80106020:	55                   	push   %ebp
80106021:	89 e5                	mov    %esp,%ebp
80106023:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80106026:	e8 77 d2 ff ff       	call   801032a2 <cpuid>
8010602b:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106031:	05 40 27 11 80       	add    $0x80112740,%eax
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106036:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010603c:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80106042:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80106046:	c6 40 7d 9a          	movb   $0x9a,0x7d(%eax)
8010604a:	c6 40 7e cf          	movb   $0xcf,0x7e(%eax)
8010604e:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106052:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80106059:	ff ff 
8010605b:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80106062:	00 00 
80106064:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010606b:	c6 80 85 00 00 00 92 	movb   $0x92,0x85(%eax)
80106072:	c6 80 86 00 00 00 cf 	movb   $0xcf,0x86(%eax)
80106079:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80106080:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80106087:	ff ff 
80106089:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80106090:	00 00 
80106092:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80106099:	c6 80 8d 00 00 00 fa 	movb   $0xfa,0x8d(%eax)
801060a0:	c6 80 8e 00 00 00 cf 	movb   $0xcf,0x8e(%eax)
801060a7:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801060ae:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801060b5:	ff ff 
801060b7:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801060be:	00 00 
801060c0:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801060c7:	c6 80 95 00 00 00 f2 	movb   $0xf2,0x95(%eax)
801060ce:	c6 80 96 00 00 00 cf 	movb   $0xcf,0x96(%eax)
801060d5:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801060dc:	83 c0 70             	add    $0x70,%eax
  pd[0] = size-1;
801060df:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
801060e5:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
801060e9:	c1 e8 10             	shr    $0x10,%eax
801060ec:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801060f0:	8d 45 f2             	lea    -0xe(%ebp),%eax
801060f3:	0f 01 10             	lgdtl  (%eax)
}
801060f6:	c9                   	leave  
801060f7:	c3                   	ret    

801060f8 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
 pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801060f8:	55                   	push   %ebp
801060f9:	89 e5                	mov    %esp,%ebp
801060fb:	57                   	push   %edi
801060fc:	56                   	push   %esi
801060fd:	53                   	push   %ebx
801060fe:	83 ec 1c             	sub    $0x1c,%esp
80106101:	8b 75 0c             	mov    0xc(%ebp),%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80106104:	89 f7                	mov    %esi,%edi
80106106:	c1 ef 16             	shr    $0x16,%edi
80106109:	c1 e7 02             	shl    $0x2,%edi
8010610c:	03 7d 08             	add    0x8(%ebp),%edi
  if(*pde & PTE_P){
8010610f:	8b 1f                	mov    (%edi),%ebx
80106111:	f6 c3 01             	test   $0x1,%bl
80106114:	74 22                	je     80106138 <walkpgdir+0x40>

#ifndef __ASSEMBLER__
// Address in page table or page directory entry
//   I changes these from macros into inline functions to make sure we
//   consistently get an error if a pointer is erroneously passed to them.
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
80106116:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    if (a > KERNBASE)
8010611c:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80106122:	76 0c                	jbe    80106130 <walkpgdir+0x38>
        panic("P2V on address > KERNBASE");
80106124:	c7 04 24 58 6f 10 80 	movl   $0x80106f58,(%esp)
8010612b:	e8 f5 a1 ff ff       	call   80100325 <panic>
    return (char*)a + KERNBASE;
80106130:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
80106136:	eb 48                	jmp    80106180 <walkpgdir+0x88>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106138:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010613c:	74 50                	je     8010618e <walkpgdir+0x96>
8010613e:	e8 16 c0 ff ff       	call   80102159 <kalloc>
80106143:	89 c3                	mov    %eax,%ebx
80106145:	85 c0                	test   %eax,%eax
80106147:	74 4c                	je     80106195 <walkpgdir+0x9d>
      return 0;
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80106149:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80106150:	00 
80106151:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106158:	00 
80106159:	89 04 24             	mov    %eax,(%esp)
8010615c:	e8 8f dd ff ff       	call   80103ef0 <memset>
    if (a < (void*) KERNBASE)
80106161:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80106167:	77 0c                	ja     80106175 <walkpgdir+0x7d>
        panic("V2P on address < KERNBASE "
80106169:	c7 04 24 28 6c 10 80 	movl   $0x80106c28,(%esp)
80106170:	e8 b0 a1 ff ff       	call   80100325 <panic>
    return (uint)a - KERNBASE;
80106175:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010617b:	83 c8 07             	or     $0x7,%eax
8010617e:	89 07                	mov    %eax,(%edi)
  }
  return &pgtab[PTX(va)];
80106180:	c1 ee 0a             	shr    $0xa,%esi
80106183:	89 f0                	mov    %esi,%eax
80106185:	25 fc 0f 00 00       	and    $0xffc,%eax
8010618a:	01 d8                	add    %ebx,%eax
8010618c:	eb 0c                	jmp    8010619a <walkpgdir+0xa2>
      return 0;
8010618e:	b8 00 00 00 00       	mov    $0x0,%eax
80106193:	eb 05                	jmp    8010619a <walkpgdir+0xa2>
80106195:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010619a:	83 c4 1c             	add    $0x1c,%esp
8010619d:	5b                   	pop    %ebx
8010619e:	5e                   	pop    %esi
8010619f:	5f                   	pop    %edi
801061a0:	5d                   	pop    %ebp
801061a1:	c3                   	ret    

801061a2 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801061a2:	55                   	push   %ebp
801061a3:	89 e5                	mov    %esp,%ebp
801061a5:	57                   	push   %edi
801061a6:	56                   	push   %esi
801061a7:	53                   	push   %ebx
801061a8:	83 ec 1c             	sub    $0x1c,%esp
801061ab:	8b 7d 08             	mov    0x8(%ebp),%edi
801061ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801061b1:	8b 75 14             	mov    0x14(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801061b4:	89 c3                	mov    %eax,%ebx
801061b6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801061bc:	03 45 10             	add    0x10(%ebp),%eax
801061bf:	83 e8 01             	sub    $0x1,%eax
801061c2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801061c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801061ca:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801061d1:	00 
801061d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801061d6:	89 3c 24             	mov    %edi,(%esp)
801061d9:	e8 1a ff ff ff       	call   801060f8 <walkpgdir>
801061de:	85 c0                	test   %eax,%eax
801061e0:	74 2e                	je     80106210 <mappages+0x6e>
      return -1;
    if(*pte & PTE_P)
801061e2:	f6 00 01             	testb  $0x1,(%eax)
801061e5:	74 0c                	je     801061f3 <mappages+0x51>
      panic("remap");
801061e7:	c7 04 24 20 74 10 80 	movl   $0x80107420,(%esp)
801061ee:	e8 32 a1 ff ff       	call   80100325 <panic>
    *pte = pa | perm | PTE_P;
801061f3:	89 f2                	mov    %esi,%edx
801061f5:	0b 55 18             	or     0x18(%ebp),%edx
801061f8:	83 ca 01             	or     $0x1,%edx
801061fb:	89 10                	mov    %edx,(%eax)
    if(a == last)
801061fd:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
80106200:	74 15                	je     80106217 <mappages+0x75>
      break;
    a += PGSIZE;
80106202:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80106208:	81 c6 00 10 00 00    	add    $0x1000,%esi
  }
8010620e:	eb ba                	jmp    801061ca <mappages+0x28>
      return -1;
80106210:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106215:	eb 05                	jmp    8010621c <mappages+0x7a>
  return 0;
80106217:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010621c:	83 c4 1c             	add    $0x1c,%esp
8010621f:	5b                   	pop    %ebx
80106220:	5e                   	pop    %esi
80106221:	5f                   	pop    %edi
80106222:	5d                   	pop    %ebp
80106223:	c3                   	ret    

80106224 <switchkvm>:
// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106224:	a1 a4 54 11 80       	mov    0x801154a4,%eax
    if (a < (void*) KERNBASE)
80106229:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
8010622e:	77 12                	ja     80106242 <switchkvm+0x1e>
{
80106230:	55                   	push   %ebp
80106231:	89 e5                	mov    %esp,%ebp
80106233:	83 ec 18             	sub    $0x18,%esp
        panic("V2P on address < KERNBASE "
80106236:	c7 04 24 28 6c 10 80 	movl   $0x80106c28,(%esp)
8010623d:	e8 e3 a0 ff ff       	call   80100325 <panic>
    return (uint)a - KERNBASE;
80106242:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106247:	0f 22 d8             	mov    %eax,%cr3
8010624a:	c3                   	ret    

8010624b <switchuvm>:
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010624b:	55                   	push   %ebp
8010624c:	89 e5                	mov    %esp,%ebp
8010624e:	57                   	push   %edi
8010624f:	56                   	push   %esi
80106250:	53                   	push   %ebx
80106251:	83 ec 1c             	sub    $0x1c,%esp
80106254:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80106257:	85 f6                	test   %esi,%esi
80106259:	75 0c                	jne    80106267 <switchuvm+0x1c>
    panic("switchuvm: no process");
8010625b:	c7 04 24 26 74 10 80 	movl   $0x80107426,(%esp)
80106262:	e8 be a0 ff ff       	call   80100325 <panic>
  if(p->kstack == 0)
80106267:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
8010626b:	75 0c                	jne    80106279 <switchuvm+0x2e>
    panic("switchuvm: no kstack");
8010626d:	c7 04 24 3c 74 10 80 	movl   $0x8010743c,(%esp)
80106274:	e8 ac a0 ff ff       	call   80100325 <panic>
  if(p->pgdir == 0)
80106279:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
8010627d:	75 0c                	jne    8010628b <switchuvm+0x40>
    panic("switchuvm: no pgdir");
8010627f:	c7 04 24 51 74 10 80 	movl   $0x80107451,(%esp)
80106286:	e8 9a a0 ff ff       	call   80100325 <panic>

  pushcli();
8010628b:	e8 dc da ff ff       	call   80103d6c <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80106290:	e8 b3 cf ff ff       	call   80103248 <mycpu>
80106295:	89 c3                	mov    %eax,%ebx
80106297:	e8 ac cf ff ff       	call   80103248 <mycpu>
8010629c:	8d 78 08             	lea    0x8(%eax),%edi
8010629f:	e8 a4 cf ff ff       	call   80103248 <mycpu>
801062a4:	83 c0 08             	add    $0x8,%eax
801062a7:	c1 e8 10             	shr    $0x10,%eax
801062aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801062ad:	e8 96 cf ff ff       	call   80103248 <mycpu>
801062b2:	83 c0 08             	add    $0x8,%eax
801062b5:	c1 e8 18             	shr    $0x18,%eax
801062b8:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801062bf:	67 00 
801062c1:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
801062c8:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
801062cc:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
801062d2:	c6 83 9d 00 00 00 99 	movb   $0x99,0x9d(%ebx)
801062d9:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
801062e0:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801062e6:	e8 5d cf ff ff       	call   80103248 <mycpu>
801062eb:	80 a0 9d 00 00 00 ef 	andb   $0xef,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801062f2:	e8 51 cf ff ff       	call   80103248 <mycpu>
801062f7:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801062fd:	e8 46 cf ff ff       	call   80103248 <mycpu>
80106302:	8b 56 08             	mov    0x8(%esi),%edx
80106305:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010630b:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010630e:	e8 35 cf ff ff       	call   80103248 <mycpu>
80106313:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80106319:	b8 28 00 00 00       	mov    $0x28,%eax
8010631e:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
80106321:	8b 46 04             	mov    0x4(%esi),%eax
    if (a < (void*) KERNBASE)
80106324:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
80106329:	77 0c                	ja     80106337 <switchuvm+0xec>
        panic("V2P on address < KERNBASE "
8010632b:	c7 04 24 28 6c 10 80 	movl   $0x80106c28,(%esp)
80106332:	e8 ee 9f ff ff       	call   80100325 <panic>
    return (uint)a - KERNBASE;
80106337:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010633c:	0f 22 d8             	mov    %eax,%cr3
  popcli();
8010633f:	e8 63 da ff ff       	call   80103da7 <popcli>
}
80106344:	83 c4 1c             	add    $0x1c,%esp
80106347:	5b                   	pop    %ebx
80106348:	5e                   	pop    %esi
80106349:	5f                   	pop    %edi
8010634a:	5d                   	pop    %ebp
8010634b:	c3                   	ret    

8010634c <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010634c:	55                   	push   %ebp
8010634d:	89 e5                	mov    %esp,%ebp
8010634f:	56                   	push   %esi
80106350:	53                   	push   %ebx
80106351:	83 ec 20             	sub    $0x20,%esp
80106354:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
80106357:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
8010635d:	76 0c                	jbe    8010636b <inituvm+0x1f>
    panic("inituvm: more than a page");
8010635f:	c7 04 24 65 74 10 80 	movl   $0x80107465,(%esp)
80106366:	e8 ba 9f ff ff       	call   80100325 <panic>
  mem = kalloc();
8010636b:	e8 e9 bd ff ff       	call   80102159 <kalloc>
80106370:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80106372:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80106379:	00 
8010637a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106381:	00 
80106382:	89 04 24             	mov    %eax,(%esp)
80106385:	e8 66 db ff ff       	call   80103ef0 <memset>
    if (a < (void*) KERNBASE)
8010638a:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80106390:	77 0c                	ja     8010639e <inituvm+0x52>
        panic("V2P on address < KERNBASE "
80106392:	c7 04 24 28 6c 10 80 	movl   $0x80106c28,(%esp)
80106399:	e8 87 9f ff ff       	call   80100325 <panic>
    return (uint)a - KERNBASE;
8010639e:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801063a4:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801063ab:	00 
801063ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
801063b0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801063b7:	00 
801063b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801063bf:	00 
801063c0:	8b 45 08             	mov    0x8(%ebp),%eax
801063c3:	89 04 24             	mov    %eax,(%esp)
801063c6:	e8 d7 fd ff ff       	call   801061a2 <mappages>
  memmove(mem, init, sz);
801063cb:	89 74 24 08          	mov    %esi,0x8(%esp)
801063cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801063d2:	89 44 24 04          	mov    %eax,0x4(%esp)
801063d6:	89 1c 24             	mov    %ebx,(%esp)
801063d9:	e8 8f db ff ff       	call   80103f6d <memmove>
}
801063de:	83 c4 20             	add    $0x20,%esp
801063e1:	5b                   	pop    %ebx
801063e2:	5e                   	pop    %esi
801063e3:	5d                   	pop    %ebp
801063e4:	c3                   	ret    

801063e5 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801063e5:	55                   	push   %ebp
801063e6:	89 e5                	mov    %esp,%ebp
801063e8:	57                   	push   %edi
801063e9:	56                   	push   %esi
801063ea:	53                   	push   %ebx
801063eb:	83 ec 1c             	sub    $0x1c,%esp
801063ee:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801063f1:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
801063f8:	0f 84 90 00 00 00    	je     8010648e <loaduvm+0xa9>
    panic("loaduvm: addr must be page aligned");
801063fe:	c7 04 24 20 75 10 80 	movl   $0x80107520,(%esp)
80106405:	e8 1b 9f ff ff       	call   80100325 <panic>
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010640a:	89 d8                	mov    %ebx,%eax
8010640c:	03 45 0c             	add    0xc(%ebp),%eax
8010640f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106416:	00 
80106417:	89 44 24 04          	mov    %eax,0x4(%esp)
8010641b:	8b 45 08             	mov    0x8(%ebp),%eax
8010641e:	89 04 24             	mov    %eax,(%esp)
80106421:	e8 d2 fc ff ff       	call   801060f8 <walkpgdir>
80106426:	85 c0                	test   %eax,%eax
80106428:	75 0c                	jne    80106436 <loaduvm+0x51>
      panic("loaduvm: address should exist");
8010642a:	c7 04 24 7f 74 10 80 	movl   $0x8010747f,(%esp)
80106431:	e8 ef 9e ff ff       	call   80100325 <panic>
    pa = PTE_ADDR(*pte);
80106436:	8b 00                	mov    (%eax),%eax
80106438:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
8010643d:	89 fe                	mov    %edi,%esi
8010643f:	29 de                	sub    %ebx,%esi
80106441:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106447:	76 05                	jbe    8010644e <loaduvm+0x69>
      n = sz - i;
    else
      n = PGSIZE;
80106449:	be 00 10 00 00       	mov    $0x1000,%esi
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010644e:	89 da                	mov    %ebx,%edx
80106450:	03 55 14             	add    0x14(%ebp),%edx
    if (a > KERNBASE)
80106453:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106458:	76 0c                	jbe    80106466 <loaduvm+0x81>
        panic("P2V on address > KERNBASE");
8010645a:	c7 04 24 58 6f 10 80 	movl   $0x80106f58,(%esp)
80106461:	e8 bf 9e ff ff       	call   80100325 <panic>
    return (char*)a + KERNBASE;
80106466:	05 00 00 00 80       	add    $0x80000000,%eax
8010646b:	89 74 24 0c          	mov    %esi,0xc(%esp)
8010646f:	89 54 24 08          	mov    %edx,0x8(%esp)
80106473:	89 44 24 04          	mov    %eax,0x4(%esp)
80106477:	8b 45 10             	mov    0x10(%ebp),%eax
8010647a:	89 04 24             	mov    %eax,(%esp)
8010647d:	e8 5c b3 ff ff       	call   801017de <readi>
80106482:	39 f0                	cmp    %esi,%eax
80106484:	75 1c                	jne    801064a2 <loaduvm+0xbd>
  for(i = 0; i < sz; i += PGSIZE){
80106486:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010648c:	eb 05                	jmp    80106493 <loaduvm+0xae>
8010648e:	bb 00 00 00 00       	mov    $0x0,%ebx
80106493:	39 fb                	cmp    %edi,%ebx
80106495:	0f 82 6f ff ff ff    	jb     8010640a <loaduvm+0x25>
      return -1;
  }
  return 0;
8010649b:	b8 00 00 00 00       	mov    $0x0,%eax
801064a0:	eb 05                	jmp    801064a7 <loaduvm+0xc2>
      return -1;
801064a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801064a7:	83 c4 1c             	add    $0x1c,%esp
801064aa:	5b                   	pop    %ebx
801064ab:	5e                   	pop    %esi
801064ac:	5f                   	pop    %edi
801064ad:	5d                   	pop    %ebp
801064ae:	c3                   	ret    

801064af <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801064af:	55                   	push   %ebp
801064b0:	89 e5                	mov    %esp,%ebp
801064b2:	57                   	push   %edi
801064b3:	56                   	push   %esi
801064b4:	53                   	push   %ebx
801064b5:	83 ec 1c             	sub    $0x1c,%esp
801064b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801064bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801064be:	39 45 10             	cmp    %eax,0x10(%ebp)
801064c1:	0f 83 86 00 00 00    	jae    8010654d <deallocuvm+0x9e>
    return oldsz;

  a = PGROUNDUP(newsz);
801064c7:	8b 45 10             	mov    0x10(%ebp),%eax
801064ca:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801064d0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801064d6:	eb 6d                	jmp    80106545 <deallocuvm+0x96>
    pte = walkpgdir(pgdir, (char*)a, 0);
801064d8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801064df:	00 
801064e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801064e4:	89 3c 24             	mov    %edi,(%esp)
801064e7:	e8 0c fc ff ff       	call   801060f8 <walkpgdir>
801064ec:	89 c6                	mov    %eax,%esi
    if(!pte)
801064ee:	85 c0                	test   %eax,%eax
801064f0:	75 0e                	jne    80106500 <deallocuvm+0x51>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801064f2:	81 e3 00 00 c0 ff    	and    $0xffc00000,%ebx
801064f8:	81 c3 00 f0 3f 00    	add    $0x3ff000,%ebx
801064fe:	eb 3f                	jmp    8010653f <deallocuvm+0x90>
    else if((*pte & PTE_P) != 0){
80106500:	8b 00                	mov    (%eax),%eax
80106502:	a8 01                	test   $0x1,%al
80106504:	74 39                	je     8010653f <deallocuvm+0x90>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106506:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010650b:	75 0c                	jne    80106519 <deallocuvm+0x6a>
        panic("kfree");
8010650d:	c7 04 24 b6 6c 10 80 	movl   $0x80106cb6,(%esp)
80106514:	e8 0c 9e ff ff       	call   80100325 <panic>
    if (a > KERNBASE)
80106519:	3d 00 00 00 80       	cmp    $0x80000000,%eax
8010651e:	76 0c                	jbe    8010652c <deallocuvm+0x7d>
        panic("P2V on address > KERNBASE");
80106520:	c7 04 24 58 6f 10 80 	movl   $0x80106f58,(%esp)
80106527:	e8 f9 9d ff ff       	call   80100325 <panic>
    return (char*)a + KERNBASE;
8010652c:	05 00 00 00 80       	add    $0x80000000,%eax
      char *v = P2V(pa);
      kfree(v);
80106531:	89 04 24             	mov    %eax,(%esp)
80106534:	e8 e3 ba ff ff       	call   8010201c <kfree>
      *pte = 0;
80106539:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  for(; a  < oldsz; a += PGSIZE){
8010653f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106545:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
80106548:	72 8e                	jb     801064d8 <deallocuvm+0x29>
    }
  }
  return newsz;
8010654a:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010654d:	83 c4 1c             	add    $0x1c,%esp
80106550:	5b                   	pop    %ebx
80106551:	5e                   	pop    %esi
80106552:	5f                   	pop    %edi
80106553:	5d                   	pop    %ebp
80106554:	c3                   	ret    

80106555 <allocuvm>:
{
80106555:	55                   	push   %ebp
80106556:	89 e5                	mov    %esp,%ebp
80106558:	57                   	push   %edi
80106559:	56                   	push   %esi
8010655a:	53                   	push   %ebx
8010655b:	83 ec 2c             	sub    $0x2c,%esp
8010655e:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
80106561:	85 ff                	test   %edi,%edi
80106563:	0f 88 f4 00 00 00    	js     8010665d <allocuvm+0x108>
  if(newsz < oldsz)
80106569:	3b 7d 0c             	cmp    0xc(%ebp),%edi
8010656c:	73 08                	jae    80106576 <allocuvm+0x21>
    return oldsz;
8010656e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106571:	e9 ec 00 00 00       	jmp    80106662 <allocuvm+0x10d>
  a = PGROUNDUP(oldsz);
80106576:	8b 45 0c             	mov    0xc(%ebp),%eax
80106579:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
8010657f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
80106585:	e9 c7 00 00 00       	jmp    80106651 <allocuvm+0xfc>
    mem = kalloc();
8010658a:	e8 ca bb ff ff       	call   80102159 <kalloc>
8010658f:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
80106591:	85 c0                	test   %eax,%eax
80106593:	75 2c                	jne    801065c1 <allocuvm+0x6c>
      cprintf("allocuvm out of memory\n");
80106595:	c7 04 24 9d 74 10 80 	movl   $0x8010749d,(%esp)
8010659c:	e8 26 a0 ff ff       	call   801005c7 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801065a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801065a4:	89 44 24 08          	mov    %eax,0x8(%esp)
801065a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
801065ac:	8b 45 08             	mov    0x8(%ebp),%eax
801065af:	89 04 24             	mov    %eax,(%esp)
801065b2:	e8 f8 fe ff ff       	call   801064af <deallocuvm>
      return 0;
801065b7:	b8 00 00 00 00       	mov    $0x0,%eax
801065bc:	e9 a1 00 00 00       	jmp    80106662 <allocuvm+0x10d>
    memset(mem, 0, PGSIZE);
801065c1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801065c8:	00 
801065c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801065d0:	00 
801065d1:	89 04 24             	mov    %eax,(%esp)
801065d4:	e8 17 d9 ff ff       	call   80103ef0 <memset>
    if (a < (void*) KERNBASE)
801065d9:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
801065df:	77 0c                	ja     801065ed <allocuvm+0x98>
        panic("V2P on address < KERNBASE "
801065e1:	c7 04 24 28 6c 10 80 	movl   $0x80106c28,(%esp)
801065e8:	e8 38 9d ff ff       	call   80100325 <panic>
    return (uint)a - KERNBASE;
801065ed:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801065f3:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801065fa:	00 
801065fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
801065ff:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80106606:	00 
80106607:	89 74 24 04          	mov    %esi,0x4(%esp)
8010660b:	8b 45 08             	mov    0x8(%ebp),%eax
8010660e:	89 04 24             	mov    %eax,(%esp)
80106611:	e8 8c fb ff ff       	call   801061a2 <mappages>
80106616:	85 c0                	test   %eax,%eax
80106618:	79 31                	jns    8010664b <allocuvm+0xf6>
      cprintf("allocuvm out of memory (2)\n");
8010661a:	c7 04 24 b5 74 10 80 	movl   $0x801074b5,(%esp)
80106621:	e8 a1 9f ff ff       	call   801005c7 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106626:	8b 45 0c             	mov    0xc(%ebp),%eax
80106629:	89 44 24 08          	mov    %eax,0x8(%esp)
8010662d:	89 7c 24 04          	mov    %edi,0x4(%esp)
80106631:	8b 45 08             	mov    0x8(%ebp),%eax
80106634:	89 04 24             	mov    %eax,(%esp)
80106637:	e8 73 fe ff ff       	call   801064af <deallocuvm>
      kfree(mem);
8010663c:	89 1c 24             	mov    %ebx,(%esp)
8010663f:	e8 d8 b9 ff ff       	call   8010201c <kfree>
      return 0;
80106644:	b8 00 00 00 00       	mov    $0x0,%eax
80106649:	eb 17                	jmp    80106662 <allocuvm+0x10d>
  for(; a < newsz; a += PGSIZE){
8010664b:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106651:	39 fe                	cmp    %edi,%esi
80106653:	0f 82 31 ff ff ff    	jb     8010658a <allocuvm+0x35>
  return newsz;
80106659:	89 f8                	mov    %edi,%eax
8010665b:	eb 05                	jmp    80106662 <allocuvm+0x10d>
    return 0;
8010665d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106662:	83 c4 2c             	add    $0x2c,%esp
80106665:	5b                   	pop    %ebx
80106666:	5e                   	pop    %esi
80106667:	5f                   	pop    %edi
80106668:	5d                   	pop    %ebp
80106669:	c3                   	ret    

8010666a <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010666a:	55                   	push   %ebp
8010666b:	89 e5                	mov    %esp,%ebp
8010666d:	56                   	push   %esi
8010666e:	53                   	push   %ebx
8010666f:	83 ec 10             	sub    $0x10,%esp
80106672:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106675:	85 f6                	test   %esi,%esi
80106677:	75 0c                	jne    80106685 <freevm+0x1b>
    panic("freevm: no pgdir");
80106679:	c7 04 24 d1 74 10 80 	movl   $0x801074d1,(%esp)
80106680:	e8 a0 9c ff ff       	call   80100325 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80106685:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010668c:	00 
8010668d:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80106694:	80 
80106695:	89 34 24             	mov    %esi,(%esp)
80106698:	e8 12 fe ff ff       	call   801064af <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010669d:	bb 00 00 00 00       	mov    $0x0,%ebx
801066a2:	eb 2f                	jmp    801066d3 <freevm+0x69>
    if(pgdir[i] & PTE_P){
801066a4:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
801066a7:	a8 01                	test   $0x1,%al
801066a9:	74 25                	je     801066d0 <freevm+0x66>
801066ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
801066b0:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801066b5:	76 0c                	jbe    801066c3 <freevm+0x59>
        panic("P2V on address > KERNBASE");
801066b7:	c7 04 24 58 6f 10 80 	movl   $0x80106f58,(%esp)
801066be:	e8 62 9c ff ff       	call   80100325 <panic>
    return (char*)a + KERNBASE;
801066c3:	05 00 00 00 80       	add    $0x80000000,%eax
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
801066c8:	89 04 24             	mov    %eax,(%esp)
801066cb:	e8 4c b9 ff ff       	call   8010201c <kfree>
  for(i = 0; i < NPDENTRIES; i++){
801066d0:	83 c3 01             	add    $0x1,%ebx
801066d3:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
801066d9:	76 c9                	jbe    801066a4 <freevm+0x3a>
    }
  }
  kfree((char*)pgdir);
801066db:	89 34 24             	mov    %esi,(%esp)
801066de:	e8 39 b9 ff ff       	call   8010201c <kfree>
}
801066e3:	83 c4 10             	add    $0x10,%esp
801066e6:	5b                   	pop    %ebx
801066e7:	5e                   	pop    %esi
801066e8:	5d                   	pop    %ebp
801066e9:	c3                   	ret    

801066ea <setupkvm>:
{
801066ea:	55                   	push   %ebp
801066eb:	89 e5                	mov    %esp,%ebp
801066ed:	56                   	push   %esi
801066ee:	53                   	push   %ebx
801066ef:	83 ec 20             	sub    $0x20,%esp
  if((pgdir = (pde_t*)kalloc()) == 0)
801066f2:	e8 62 ba ff ff       	call   80102159 <kalloc>
801066f7:	89 c6                	mov    %eax,%esi
801066f9:	85 c0                	test   %eax,%eax
801066fb:	74 66                	je     80106763 <setupkvm+0x79>
  memset(pgdir, 0, PGSIZE);
801066fd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80106704:	00 
80106705:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010670c:	00 
8010670d:	89 04 24             	mov    %eax,(%esp)
80106710:	e8 db d7 ff ff       	call   80103ef0 <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106715:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
8010671a:	eb 3b                	jmp    80106757 <setupkvm+0x6d>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010671c:	8b 53 04             	mov    0x4(%ebx),%edx
8010671f:	8b 43 0c             	mov    0xc(%ebx),%eax
80106722:	89 44 24 10          	mov    %eax,0x10(%esp)
80106726:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010672a:	8b 43 08             	mov    0x8(%ebx),%eax
8010672d:	29 d0                	sub    %edx,%eax
8010672f:	89 44 24 08          	mov    %eax,0x8(%esp)
80106733:	8b 03                	mov    (%ebx),%eax
80106735:	89 44 24 04          	mov    %eax,0x4(%esp)
80106739:	89 34 24             	mov    %esi,(%esp)
8010673c:	e8 61 fa ff ff       	call   801061a2 <mappages>
80106741:	85 c0                	test   %eax,%eax
80106743:	79 0f                	jns    80106754 <setupkvm+0x6a>
      freevm(pgdir);
80106745:	89 34 24             	mov    %esi,(%esp)
80106748:	e8 1d ff ff ff       	call   8010666a <freevm>
      return 0;
8010674d:	b8 00 00 00 00       	mov    $0x0,%eax
80106752:	eb 14                	jmp    80106768 <setupkvm+0x7e>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106754:	83 c3 10             	add    $0x10,%ebx
80106757:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
8010675d:	72 bd                	jb     8010671c <setupkvm+0x32>
  return pgdir;
8010675f:	89 f0                	mov    %esi,%eax
80106761:	eb 05                	jmp    80106768 <setupkvm+0x7e>
    return 0;
80106763:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106768:	83 c4 20             	add    $0x20,%esp
8010676b:	5b                   	pop    %ebx
8010676c:	5e                   	pop    %esi
8010676d:	5d                   	pop    %ebp
8010676e:	c3                   	ret    

8010676f <kvmalloc>:
{
8010676f:	55                   	push   %ebp
80106770:	89 e5                	mov    %esp,%ebp
80106772:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106775:	e8 70 ff ff ff       	call   801066ea <setupkvm>
8010677a:	a3 a4 54 11 80       	mov    %eax,0x801154a4
  switchkvm();
8010677f:	e8 a0 fa ff ff       	call   80106224 <switchkvm>
}
80106784:	c9                   	leave  
80106785:	c3                   	ret    

80106786 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106786:	55                   	push   %ebp
80106787:	89 e5                	mov    %esp,%ebp
80106789:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010678c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106793:	00 
80106794:	8b 45 0c             	mov    0xc(%ebp),%eax
80106797:	89 44 24 04          	mov    %eax,0x4(%esp)
8010679b:	8b 45 08             	mov    0x8(%ebp),%eax
8010679e:	89 04 24             	mov    %eax,(%esp)
801067a1:	e8 52 f9 ff ff       	call   801060f8 <walkpgdir>
  if(pte == 0)
801067a6:	85 c0                	test   %eax,%eax
801067a8:	75 0c                	jne    801067b6 <clearpteu+0x30>
    panic("clearpteu");
801067aa:	c7 04 24 e2 74 10 80 	movl   $0x801074e2,(%esp)
801067b1:	e8 6f 9b ff ff       	call   80100325 <panic>
  *pte &= ~PTE_U;
801067b6:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
801067b9:	c9                   	leave  
801067ba:	c3                   	ret    

801067bb <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801067bb:	55                   	push   %ebp
801067bc:	89 e5                	mov    %esp,%ebp
801067be:	57                   	push   %edi
801067bf:	56                   	push   %esi
801067c0:	53                   	push   %ebx
801067c1:	83 ec 2c             	sub    $0x2c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801067c4:	e8 21 ff ff ff       	call   801066ea <setupkvm>
801067c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
801067cc:	85 c0                	test   %eax,%eax
801067ce:	0f 84 00 01 00 00    	je     801068d4 <copyuvm+0x119>
801067d4:	be 00 00 00 00       	mov    $0x0,%esi
801067d9:	e9 d6 00 00 00       	jmp    801068b4 <copyuvm+0xf9>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801067de:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801067e5:	00 
801067e6:	89 74 24 04          	mov    %esi,0x4(%esp)
801067ea:	8b 45 08             	mov    0x8(%ebp),%eax
801067ed:	89 04 24             	mov    %eax,(%esp)
801067f0:	e8 03 f9 ff ff       	call   801060f8 <walkpgdir>
801067f5:	85 c0                	test   %eax,%eax
801067f7:	75 0c                	jne    80106805 <copyuvm+0x4a>
      panic("copyuvm: pte should exist");
801067f9:	c7 04 24 ec 74 10 80 	movl   $0x801074ec,(%esp)
80106800:	e8 20 9b ff ff       	call   80100325 <panic>
    if(!(*pte & PTE_P))
80106805:	8b 00                	mov    (%eax),%eax
80106807:	a8 01                	test   $0x1,%al
80106809:	75 0c                	jne    80106817 <copyuvm+0x5c>
      panic("copyuvm: page not present");
8010680b:	c7 04 24 06 75 10 80 	movl   $0x80107506,(%esp)
80106812:	e8 0e 9b ff ff       	call   80100325 <panic>
80106817:	89 c7                	mov    %eax,%edi
80106819:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
static inline uint PTE_FLAGS(uint pte) { return pte & 0xFFF; }
8010681f:	25 ff 0f 00 00       	and    $0xfff,%eax
80106824:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
80106827:	e8 2d b9 ff ff       	call   80102159 <kalloc>
8010682c:	89 c3                	mov    %eax,%ebx
8010682e:	85 c0                	test   %eax,%eax
80106830:	0f 84 8c 00 00 00    	je     801068c2 <copyuvm+0x107>
    if (a > KERNBASE)
80106836:	81 ff 00 00 00 80    	cmp    $0x80000000,%edi
8010683c:	76 0c                	jbe    8010684a <copyuvm+0x8f>
        panic("P2V on address > KERNBASE");
8010683e:	c7 04 24 58 6f 10 80 	movl   $0x80106f58,(%esp)
80106845:	e8 db 9a ff ff       	call   80100325 <panic>
    return (char*)a + KERNBASE;
8010684a:	81 c7 00 00 00 80    	add    $0x80000000,%edi
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106850:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80106857:	00 
80106858:	89 7c 24 04          	mov    %edi,0x4(%esp)
8010685c:	89 04 24             	mov    %eax,(%esp)
8010685f:	e8 09 d7 ff ff       	call   80103f6d <memmove>
    if (a < (void*) KERNBASE)
80106864:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
8010686a:	77 0c                	ja     80106878 <copyuvm+0xbd>
        panic("V2P on address < KERNBASE "
8010686c:	c7 04 24 28 6c 10 80 	movl   $0x80106c28,(%esp)
80106873:	e8 ad 9a ff ff       	call   80100325 <panic>
    return (uint)a - KERNBASE;
80106878:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
8010687e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106881:	89 54 24 10          	mov    %edx,0x10(%esp)
80106885:	89 44 24 0c          	mov    %eax,0xc(%esp)
80106889:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80106890:	00 
80106891:	89 74 24 04          	mov    %esi,0x4(%esp)
80106895:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106898:	89 04 24             	mov    %eax,(%esp)
8010689b:	e8 02 f9 ff ff       	call   801061a2 <mappages>
801068a0:	85 c0                	test   %eax,%eax
801068a2:	79 0a                	jns    801068ae <copyuvm+0xf3>
      kfree(mem);
801068a4:	89 1c 24             	mov    %ebx,(%esp)
801068a7:	e8 70 b7 ff ff       	call   8010201c <kfree>
      goto bad;
801068ac:	eb 14                	jmp    801068c2 <copyuvm+0x107>
  for(i = 0; i < sz; i += PGSIZE){
801068ae:	81 c6 00 10 00 00    	add    $0x1000,%esi
801068b4:	3b 75 0c             	cmp    0xc(%ebp),%esi
801068b7:	0f 82 21 ff ff ff    	jb     801067de <copyuvm+0x23>
    }
  }
  return d;
801068bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801068c0:	eb 17                	jmp    801068d9 <copyuvm+0x11e>

bad:
  freevm(d);
801068c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801068c5:	89 04 24             	mov    %eax,(%esp)
801068c8:	e8 9d fd ff ff       	call   8010666a <freevm>
  return 0;
801068cd:	b8 00 00 00 00       	mov    $0x0,%eax
801068d2:	eb 05                	jmp    801068d9 <copyuvm+0x11e>
    return 0;
801068d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801068d9:	83 c4 2c             	add    $0x2c,%esp
801068dc:	5b                   	pop    %ebx
801068dd:	5e                   	pop    %esi
801068de:	5f                   	pop    %edi
801068df:	5d                   	pop    %ebp
801068e0:	c3                   	ret    

801068e1 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801068e1:	55                   	push   %ebp
801068e2:	89 e5                	mov    %esp,%ebp
801068e4:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801068e7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801068ee:	00 
801068ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801068f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801068f6:	8b 45 08             	mov    0x8(%ebp),%eax
801068f9:	89 04 24             	mov    %eax,(%esp)
801068fc:	e8 f7 f7 ff ff       	call   801060f8 <walkpgdir>
  if((*pte & PTE_P) == 0)
80106901:	8b 00                	mov    (%eax),%eax
80106903:	a8 01                	test   $0x1,%al
80106905:	74 23                	je     8010692a <uva2ka+0x49>
    return 0;
  if((*pte & PTE_U) == 0)
80106907:	a8 04                	test   $0x4,%al
80106909:	74 26                	je     80106931 <uva2ka+0x50>
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
8010690b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
80106910:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106915:	76 0c                	jbe    80106923 <uva2ka+0x42>
        panic("P2V on address > KERNBASE");
80106917:	c7 04 24 58 6f 10 80 	movl   $0x80106f58,(%esp)
8010691e:	e8 02 9a ff ff       	call   80100325 <panic>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
80106923:	05 00 00 00 80       	add    $0x80000000,%eax
80106928:	eb 0c                	jmp    80106936 <uva2ka+0x55>
    return 0;
8010692a:	b8 00 00 00 00       	mov    $0x0,%eax
8010692f:	eb 05                	jmp    80106936 <uva2ka+0x55>
    return 0;
80106931:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106936:	c9                   	leave  
80106937:	c3                   	ret    

80106938 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106938:	55                   	push   %ebp
80106939:	89 e5                	mov    %esp,%ebp
8010693b:	57                   	push   %edi
8010693c:	56                   	push   %esi
8010693d:	53                   	push   %ebx
8010693e:	83 ec 1c             	sub    $0x1c,%esp
80106941:	8b 7d 0c             	mov    0xc(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106944:	eb 50                	jmp    80106996 <copyout+0x5e>
    va0 = (uint)PGROUNDDOWN(va);
80106946:	89 fe                	mov    %edi,%esi
80106948:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
8010694e:	89 74 24 04          	mov    %esi,0x4(%esp)
80106952:	8b 45 08             	mov    0x8(%ebp),%eax
80106955:	89 04 24             	mov    %eax,(%esp)
80106958:	e8 84 ff ff ff       	call   801068e1 <uva2ka>
    if(pa0 == 0)
8010695d:	85 c0                	test   %eax,%eax
8010695f:	74 42                	je     801069a3 <copyout+0x6b>
      return -1;
    n = PGSIZE - (va - va0);
80106961:	89 f3                	mov    %esi,%ebx
80106963:	29 fb                	sub    %edi,%ebx
80106965:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
8010696b:	3b 5d 14             	cmp    0x14(%ebp),%ebx
8010696e:	76 03                	jbe    80106973 <copyout+0x3b>
      n = len;
80106970:	8b 5d 14             	mov    0x14(%ebp),%ebx
    memmove(pa0 + (va - va0), buf, n);
80106973:	29 f7                	sub    %esi,%edi
80106975:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80106979:	8b 55 10             	mov    0x10(%ebp),%edx
8010697c:	89 54 24 04          	mov    %edx,0x4(%esp)
80106980:	01 f8                	add    %edi,%eax
80106982:	89 04 24             	mov    %eax,(%esp)
80106985:	e8 e3 d5 ff ff       	call   80103f6d <memmove>
    len -= n;
8010698a:	29 5d 14             	sub    %ebx,0x14(%ebp)
    buf += n;
8010698d:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
80106990:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
  while(len > 0){
80106996:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010699a:	75 aa                	jne    80106946 <copyout+0xe>
  }
  return 0;
8010699c:	b8 00 00 00 00       	mov    $0x0,%eax
801069a1:	eb 05                	jmp    801069a8 <copyout+0x70>
      return -1;
801069a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801069a8:	83 c4 1c             	add    $0x1c,%esp
801069ab:	5b                   	pop    %ebx
801069ac:	5e                   	pop    %esi
801069ad:	5f                   	pop    %edi
801069ae:	5d                   	pop    %ebp
801069af:	c3                   	ret    
