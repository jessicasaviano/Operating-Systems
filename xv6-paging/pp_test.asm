
_pp_test:     file format elf32-i386


Disassembly of section .text:

00000000 <_get_guard>:
       0:	b8 ff 0f 00 00       	mov    $0xfff,%eax
       5:	f7 d0                	not    %eax
       7:	21 e0                	and    %esp,%eax
       9:	2d 00 10 00 00       	sub    $0x1000,%eax
       e:	c3                   	ret    

0000000f <clear_saved_ppns>:
static int saved_ppn_index = 0;
#ifdef ALLOC_CHECK
static volatile int kalloc_index = 0;
#endif

static void clear_saved_ppns() {
       f:	55                   	push   %ebp
      10:	89 e5                	mov    %esp,%ebp
    saved_ppn_index = 0;
      12:	c7 05 50 54 00 00 00 	movl   $0x0,0x5450
      19:	00 00 00 
    /* write all saved_ppns to prevent unexpected allocations later */
    for (int i = 0; i < SAVED_PPN_COUNT; i += 1) {
      1c:	b8 00 00 00 00       	mov    $0x0,%eax
      21:	eb 0e                	jmp    31 <clear_saved_ppns+0x22>
        saved_ppns[i] = 0;
      23:	c7 04 85 60 54 00 00 	movl   $0x0,0x5460(,%eax,4)
      2a:	00 00 00 00 
    for (int i = 0; i < SAVED_PPN_COUNT; i += 1) {
      2e:	83 c0 01             	add    $0x1,%eax
      31:	3d ff 07 00 00       	cmp    $0x7ff,%eax
      36:	7e eb                	jle    23 <clear_saved_ppns+0x14>
    }
#ifdef ALLOC_CHECK
    kalloc_index = 0;
    kalloc_index = getkallocindex();
#endif
}
      38:	5d                   	pop    %ebp
      39:	c3                   	ret    

0000003a <_heap_test_value>:

    int dump;
    int pre_fork_p;
};

static char _heap_test_value(int offset, int child_index) {
      3a:	55                   	push   %ebp
      3b:	89 e5                	mov    %esp,%ebp
    int adjusted_offset = offset + (offset >> PTXSHIFT) + (offset >> PDXSHIFT);
      3d:	89 c1                	mov    %eax,%ecx
      3f:	c1 f9 0c             	sar    $0xc,%ecx
      42:	01 c1                	add    %eax,%ecx
      44:	c1 f8 16             	sar    $0x16,%eax
      47:	01 c8                	add    %ecx,%eax
    return ('Q' + adjusted_offset + child_index);
      49:	8d 44 10 51          	lea    0x51(%eax,%edx,1),%eax
}
      4d:	5d                   	pop    %ebp
      4e:	c3                   	ret    

0000004f <_pipe_assert_broken_parent>:
int _pipe_assert_broken_parent(struct test_pipes *pipes) {
      4f:	55                   	push   %ebp
      50:	89 e5                	mov    %esp,%ebp
      52:	83 ec 28             	sub    $0x28,%esp
    char c = 'X';
      55:	c6 45 f7 58          	movb   $0x58,-0x9(%ebp)
    int result = read(pipes->from_child[0], &c, 1);
      59:	8b 40 08             	mov    0x8(%eax),%eax
      5c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
      63:	00 
      64:	8d 55 f7             	lea    -0x9(%ebp),%edx
      67:	89 54 24 04          	mov    %edx,0x4(%esp)
      6b:	89 04 24             	mov    %eax,(%esp)
      6e:	e8 df 2f 00 00       	call   3052 <read>
    return (result != 1);
      73:	83 f8 01             	cmp    $0x1,%eax
      76:	0f 95 c0             	setne  %al
      79:	0f b6 c0             	movzbl %al,%eax
}
      7c:	c9                   	leave  
      7d:	c3                   	ret    

0000007e <_pipe_send_child>:
void _pipe_send_child(struct test_pipes *pipes, int *values, int value_count) {
      7e:	55                   	push   %ebp
      7f:	89 e5                	mov    %esp,%ebp
      81:	56                   	push   %esi
      82:	53                   	push   %ebx
      83:	83 ec 10             	sub    $0x10,%esp
      86:	89 c3                	mov    %eax,%ebx
      88:	89 4d f4             	mov    %ecx,-0xc(%ebp)
    if (pipes->from_child[1] != -1) {
      8b:	8b 40 0c             	mov    0xc(%eax),%eax
      8e:	83 f8 ff             	cmp    $0xffffffff,%eax
      91:	74 32                	je     c5 <_pipe_send_child+0x47>
      93:	89 d6                	mov    %edx,%esi
        write(pipes->from_child[1], &value_count, 4);
      95:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
      9c:	00 
      9d:	8d 55 f4             	lea    -0xc(%ebp),%edx
      a0:	89 54 24 04          	mov    %edx,0x4(%esp)
      a4:	89 04 24             	mov    %eax,(%esp)
      a7:	e8 ae 2f 00 00       	call   305a <write>
        write(pipes->from_child[1], values, 4 * value_count);
      ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
      af:	c1 e0 02             	shl    $0x2,%eax
      b2:	89 44 24 08          	mov    %eax,0x8(%esp)
      b6:	89 74 24 04          	mov    %esi,0x4(%esp)
      ba:	8b 43 0c             	mov    0xc(%ebx),%eax
      bd:	89 04 24             	mov    %eax,(%esp)
      c0:	e8 95 2f 00 00       	call   305a <write>
}
      c5:	83 c4 10             	add    $0x10,%esp
      c8:	5b                   	pop    %ebx
      c9:	5e                   	pop    %esi
      ca:	5d                   	pop    %ebp
      cb:	c3                   	ret    

000000cc <CRASH>:
static void CRASH(const char *message) {
      cc:	55                   	push   %ebp
      cd:	89 e5                	mov    %esp,%ebp
      cf:	83 ec 18             	sub    $0x18,%esp
    printf(2, "%s\n", message);
      d2:	89 44 24 08          	mov    %eax,0x8(%esp)
      d6:	c7 44 24 04 b0 33 00 	movl   $0x33b0,0x4(%esp)
      dd:	00 
      de:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      e5:	e8 c2 30 00 00       	call   31ac <printf>
    exit();
      ea:	e8 4b 2f 00 00       	call   303a <exit>

000000ef <_pipe_sync_parent>:
int _pipe_sync_parent(struct test_pipes *pipes) {
      ef:	55                   	push   %ebp
      f0:	89 e5                	mov    %esp,%ebp
      f2:	53                   	push   %ebx
      f3:	83 ec 24             	sub    $0x24,%esp
      f6:	89 c3                	mov    %eax,%ebx
    if (pipes->from_child[0] != -1) {
      f8:	8b 40 08             	mov    0x8(%eax),%eax
      fb:	83 f8 ff             	cmp    $0xffffffff,%eax
      fe:	74 46                	je     146 <_pipe_sync_parent+0x57>
        char c = 'X';
     100:	c6 45 f7 58          	movb   $0x58,-0x9(%ebp)
        read(pipes->from_child[0], &c, 1);
     104:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     10b:	00 
     10c:	8d 55 f7             	lea    -0x9(%ebp),%edx
     10f:	89 54 24 04          	mov    %edx,0x4(%esp)
     113:	89 04 24             	mov    %eax,(%esp)
     116:	e8 37 2f 00 00       	call   3052 <read>
        if (c != 'S') CRASH("problem communicating with child process via pipe");
     11b:	80 7d f7 53          	cmpb   $0x53,-0x9(%ebp)
     11f:	74 0a                	je     12b <_pipe_sync_parent+0x3c>
     121:	b8 58 37 00 00       	mov    $0x3758,%eax
     126:	e8 a1 ff ff ff       	call   cc <CRASH>
        write(pipes->to_child[1], "S", 1);
     12b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     132:	00 
     133:	c7 44 24 04 08 33 00 	movl   $0x3308,0x4(%esp)
     13a:	00 
     13b:	8b 43 04             	mov    0x4(%ebx),%eax
     13e:	89 04 24             	mov    %eax,(%esp)
     141:	e8 14 2f 00 00       	call   305a <write>
}
     146:	b8 01 00 00 00       	mov    $0x1,%eax
     14b:	83 c4 24             	add    $0x24,%esp
     14e:	5b                   	pop    %ebx
     14f:	5d                   	pop    %ebp
     150:	c3                   	ret    

00000151 <_pipe_recv_parent>:
void _pipe_recv_parent(struct test_pipes *pipes, int *values, int *value_count) {
     151:	55                   	push   %ebp
     152:	89 e5                	mov    %esp,%ebp
     154:	57                   	push   %edi
     155:	56                   	push   %esi
     156:	53                   	push   %ebx
     157:	83 ec 2c             	sub    $0x2c,%esp
     15a:	89 c6                	mov    %eax,%esi
    if (pipes->from_child[0] != -1) {
     15c:	8b 40 08             	mov    0x8(%eax),%eax
     15f:	83 f8 ff             	cmp    $0xffffffff,%eax
     162:	0f 84 8c 00 00 00    	je     1f4 <_pipe_recv_parent+0xa3>
     168:	89 d7                	mov    %edx,%edi
     16a:	89 cb                	mov    %ecx,%ebx
        int actual_value_count = 0;
     16c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        int result = read(pipes->from_child[0], &actual_value_count, 4);
     173:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
     17a:	00 
     17b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
     17e:	89 54 24 04          	mov    %edx,0x4(%esp)
     182:	89 04 24             	mov    %eax,(%esp)
     185:	e8 c8 2e 00 00       	call   3052 <read>
        if (result != 4) CRASH("problem communicating with child process via pipe (recv_parent 1)");
     18a:	83 f8 04             	cmp    $0x4,%eax
     18d:	74 0a                	je     199 <_pipe_recv_parent+0x48>
     18f:	b8 8c 37 00 00       	mov    $0x378c,%eax
     194:	e8 33 ff ff ff       	call   cc <CRASH>
        if (*value_count > actual_value_count) {
     199:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     19c:	39 03                	cmp    %eax,(%ebx)
     19e:	7e 0a                	jle    1aa <_pipe_recv_parent+0x59>
            CRASH("too many values being sent from child");
     1a0:	b8 d0 37 00 00       	mov    $0x37d0,%eax
     1a5:	e8 22 ff ff ff       	call   cc <CRASH>
        *value_count = actual_value_count;
     1aa:	89 03                	mov    %eax,(%ebx)
        values[0] = 0; // write to ensure read() does not trigger copy-on-write
     1ac:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
        int offset = 0;
     1b2:	bb 00 00 00 00       	mov    $0x0,%ebx
                actual_value_count * 4 - offset);
     1b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     1ba:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
            result = read(
     1c1:	29 d9                	sub    %ebx,%ecx
     1c3:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
     1c6:	8b 46 08             	mov    0x8(%esi),%eax
     1c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
     1cd:	89 54 24 04          	mov    %edx,0x4(%esp)
     1d1:	89 04 24             	mov    %eax,(%esp)
     1d4:	e8 79 2e 00 00       	call   3052 <read>
            if (result == -1) {
     1d9:	83 f8 ff             	cmp    $0xffffffff,%eax
     1dc:	75 0a                	jne    1e8 <_pipe_recv_parent+0x97>
                CRASH("problem communicating with child process via pipe (recv_parent 2)");
     1de:	b8 f8 37 00 00       	mov    $0x37f8,%eax
     1e3:	e8 e4 fe ff ff       	call   cc <CRASH>
            offset += result;
     1e8:	01 c3                	add    %eax,%ebx
        } while (offset != actual_value_count * 4);
     1ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     1ed:	c1 e0 02             	shl    $0x2,%eax
     1f0:	39 d8                	cmp    %ebx,%eax
     1f2:	75 c3                	jne    1b7 <_pipe_recv_parent+0x66>
}
     1f4:	83 c4 2c             	add    $0x2c,%esp
     1f7:	5b                   	pop    %ebx
     1f8:	5e                   	pop    %esi
     1f9:	5f                   	pop    %edi
     1fa:	5d                   	pop    %ebp
     1fb:	c3                   	ret    

000001fc <_pipe_sync_child>:
void _pipe_sync_child(struct test_pipes *pipes) {
     1fc:	55                   	push   %ebp
     1fd:	89 e5                	mov    %esp,%ebp
     1ff:	53                   	push   %ebx
     200:	83 ec 24             	sub    $0x24,%esp
     203:	89 c3                	mov    %eax,%ebx
    if (pipes->from_child[1] != -1) {
     205:	8b 40 0c             	mov    0xc(%eax),%eax
     208:	83 f8 ff             	cmp    $0xffffffff,%eax
     20b:	74 45                	je     252 <_pipe_sync_child+0x56>
        write(pipes->from_child[1], "S", 1);
     20d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     214:	00 
     215:	c7 44 24 04 08 33 00 	movl   $0x3308,0x4(%esp)
     21c:	00 
     21d:	89 04 24             	mov    %eax,(%esp)
     220:	e8 35 2e 00 00       	call   305a <write>
        char c = 'X';
     225:	c6 45 f7 58          	movb   $0x58,-0x9(%ebp)
        read(pipes->to_child[0], &c, 1);
     229:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     230:	00 
     231:	8d 45 f7             	lea    -0x9(%ebp),%eax
     234:	89 44 24 04          	mov    %eax,0x4(%esp)
     238:	8b 03                	mov    (%ebx),%eax
     23a:	89 04 24             	mov    %eax,(%esp)
     23d:	e8 10 2e 00 00       	call   3052 <read>
        if (c != 'S') CRASH("problem communicating with parent process via pipe");
     242:	80 7d f7 53          	cmpb   $0x53,-0x9(%ebp)
     246:	74 0a                	je     252 <_pipe_sync_child+0x56>
     248:	b8 3c 38 00 00       	mov    $0x383c,%eax
     24d:	e8 7a fe ff ff       	call   cc <CRASH>
}
     252:	83 c4 24             	add    $0x24,%esp
     255:	5b                   	pop    %ebx
     256:	5d                   	pop    %ebp
     257:	c3                   	ret    

00000258 <save_ppns>:
static int save_ppns(int pid, int start_address, int end_address, int allow_missing) {
     258:	55                   	push   %ebp
     259:	89 e5                	mov    %esp,%ebp
     25b:	57                   	push   %edi
     25c:	56                   	push   %esi
     25d:	53                   	push   %ebx
     25e:	83 ec 2c             	sub    $0x2c,%esp
     261:	89 c6                	mov    %eax,%esi
     263:	89 cf                	mov    %ecx,%edi
    for (int i = start_address; i < end_address; i += PGSIZE) {
     265:	89 d3                	mov    %edx,%ebx
            if (saved_ppn_index >= SAVED_PPN_COUNT / 2 && ((start_address >> PTXSHIFT) & 0xF) != 0) {
     267:	c1 fa 0c             	sar    $0xc,%edx
     26a:	83 e2 0f             	and    $0xf,%edx
     26d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (int i = start_address; i < end_address; i += PGSIZE) {
     270:	e9 94 00 00 00       	jmp    309 <save_ppns+0xb1>
        uint pte = getpagetableentry(pid, i);
     275:	89 5c 24 04          	mov    %ebx,0x4(%esp)
     279:	89 34 24             	mov    %esi,(%esp)
     27c:	e8 61 2e 00 00       	call   30e2 <getpagetableentry>
        if (pte & PTE_P) {
     281:	a8 01                	test   $0x1,%al
     283:	74 51                	je     2d6 <save_ppns+0x7e>
            if (saved_ppn_index >= SAVED_PPN_COUNT / 2 && ((start_address >> PTXSHIFT) & 0xF) != 0) {
     285:	8b 15 50 54 00 00    	mov    0x5450,%edx
     28b:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
     291:	7e 06                	jle    299 <save_ppns+0x41>
     293:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
     297:	75 6a                	jne    303 <save_ppns+0xab>
            if (saved_ppn_index >= SAVED_PPN_COUNT) {
     299:	81 fa ff 07 00 00    	cmp    $0x7ff,%edx
     29f:	7f 62                	jg     303 <save_ppns+0xab>
            saved_ppns[saved_ppn_index] = PTE_ADDR(pte) >> PTXSHIFT;
     2a1:	c1 e8 0c             	shr    $0xc,%eax
     2a4:	89 04 95 60 54 00 00 	mov    %eax,0x5460(,%edx,4)
            if (saved_ppns[saved_ppn_index] == 0) {
     2ab:	85 c0                	test   %eax,%eax
     2ad:	75 1c                	jne    2cb <save_ppns+0x73>
     2af:	89 c7                	mov    %eax,%edi
                printf(2, "ERROR: invalid physical page 0 allocated for virtual page 0x%x\n",
     2b1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
     2b5:	c7 44 24 04 70 38 00 	movl   $0x3870,0x4(%esp)
     2bc:	00 
     2bd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     2c4:	e8 e3 2e 00 00       	call   31ac <printf>
                return 0;
     2c9:	eb 4b                	jmp    316 <save_ppns+0xbe>
            saved_ppn_index += 1;
     2cb:	83 c2 01             	add    $0x1,%edx
     2ce:	89 15 50 54 00 00    	mov    %edx,0x5450
     2d4:	eb 2d                	jmp    303 <save_ppns+0xab>
        } else if (!allow_missing) {
     2d6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     2da:	75 27                	jne    303 <save_ppns+0xab>
            printf(2, "ERROR: expected pid %d to have address %x allocated,\n"
     2dc:	89 44 24 10          	mov    %eax,0x10(%esp)
     2e0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
     2e4:	89 74 24 08          	mov    %esi,0x8(%esp)
     2e8:	c7 44 24 04 b0 38 00 	movl   $0x38b0,0x4(%esp)
     2ef:	00 
     2f0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     2f7:	e8 b0 2e 00 00       	call   31ac <printf>
            return 0;
     2fc:	bf 00 00 00 00       	mov    $0x0,%edi
     301:	eb 13                	jmp    316 <save_ppns+0xbe>
    for (int i = start_address; i < end_address; i += PGSIZE) {
     303:	81 c3 00 10 00 00    	add    $0x1000,%ebx
     309:	39 fb                	cmp    %edi,%ebx
     30b:	0f 8c 64 ff ff ff    	jl     275 <save_ppns+0x1d>
    return 1;
     311:	bf 01 00 00 00       	mov    $0x1,%edi
}
     316:	89 f8                	mov    %edi,%eax
     318:	83 c4 2c             	add    $0x2c,%esp
     31b:	5b                   	pop    %ebx
     31c:	5e                   	pop    %esi
     31d:	5f                   	pop    %edi
     31e:	5d                   	pop    %ebp
     31f:	c3                   	ret    

00000320 <_same_pte_range>:
int _same_pte_range(int pid_one, int pid_two, int start_va, int end_va, char *explain) {
     320:	55                   	push   %ebp
     321:	89 e5                	mov    %esp,%ebp
     323:	57                   	push   %edi
     324:	56                   	push   %esi
     325:	53                   	push   %ebx
     326:	83 ec 2c             	sub    $0x2c,%esp
     329:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     32c:	89 d7                	mov    %edx,%edi
     32e:	89 cb                	mov    %ecx,%ebx
    for (int addr = start_va; addr < end_va; addr += PGSIZE) {
     330:	eb 63                	jmp    395 <_same_pte_range+0x75>
        uint pte_one = getpagetableentry(pid_one, addr);
     332:	89 5c 24 04          	mov    %ebx,0x4(%esp)
     336:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     339:	89 04 24             	mov    %eax,(%esp)
     33c:	e8 a1 2d 00 00       	call   30e2 <getpagetableentry>
     341:	89 c6                	mov    %eax,%esi
        uint pte_two = getpagetableentry(pid_two, addr);
     343:	89 5c 24 04          	mov    %ebx,0x4(%esp)
     347:	89 3c 24             	mov    %edi,(%esp)
     34a:	e8 93 2d 00 00       	call   30e2 <getpagetableentry>

#ifndef __ASSEMBLER__
// Address in page table or page directory entry
//   I changes these from macros into inline functions to make sure we
//   consistently get an error if a pointer is erroneously passed to them.
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
     34f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
     355:	25 00 f0 ff ff       	and    $0xfffff000,%eax
        if (PTE_ADDR(pte_one) != PTE_ADDR(pte_two)) {
     35a:	39 c6                	cmp    %eax,%esi
     35c:	74 31                	je     38f <_same_pte_range+0x6f>
            printf(2, "ERROR: virtual address 0x%x%s assigned to different physical addresses in pids %d and %d\n",
     35e:	89 7c 24 14          	mov    %edi,0x14(%esp)
     362:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     365:	89 44 24 10          	mov    %eax,0x10(%esp)
     369:	8b 45 0c             	mov    0xc(%ebp),%eax
     36c:	89 44 24 0c          	mov    %eax,0xc(%esp)
     370:	89 5c 24 08          	mov    %ebx,0x8(%esp)
     374:	c7 44 24 04 38 39 00 	movl   $0x3938,0x4(%esp)
     37b:	00 
     37c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     383:	e8 24 2e 00 00       	call   31ac <printf>
            return 0;
     388:	b8 00 00 00 00       	mov    $0x0,%eax
     38d:	eb 10                	jmp    39f <_same_pte_range+0x7f>
    for (int addr = start_va; addr < end_va; addr += PGSIZE) {
     38f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
     395:	3b 5d 08             	cmp    0x8(%ebp),%ebx
     398:	7c 98                	jl     332 <_same_pte_range+0x12>
    return 1;
     39a:	b8 01 00 00 00       	mov    $0x1,%eax
}
     39f:	83 c4 2c             	add    $0x2c,%esp
     3a2:	5b                   	pop    %ebx
     3a3:	5e                   	pop    %esi
     3a4:	5f                   	pop    %edi
     3a5:	5d                   	pop    %ebp
     3a6:	c3                   	ret    

000003a7 <_different_pte_range>:
int _different_pte_range(int pid_one, int pid_two, int start_va, int end_va, char *explain) {
     3a7:	55                   	push   %ebp
     3a8:	89 e5                	mov    %esp,%ebp
     3aa:	57                   	push   %edi
     3ab:	56                   	push   %esi
     3ac:	53                   	push   %ebx
     3ad:	83 ec 2c             	sub    $0x2c,%esp
     3b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     3b3:	89 d7                	mov    %edx,%edi
     3b5:	89 cb                	mov    %ecx,%ebx
    for (int addr = start_va; addr < end_va; addr += PGSIZE) {
     3b7:	eb 63                	jmp    41c <_different_pte_range+0x75>
        uint pte_one = getpagetableentry(pid_one, addr);
     3b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
     3bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     3c0:	89 04 24             	mov    %eax,(%esp)
     3c3:	e8 1a 2d 00 00       	call   30e2 <getpagetableentry>
     3c8:	89 c6                	mov    %eax,%esi
        uint pte_two = getpagetableentry(pid_two, addr);
     3ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
     3ce:	89 3c 24             	mov    %edi,(%esp)
     3d1:	e8 0c 2d 00 00       	call   30e2 <getpagetableentry>
     3d6:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
     3dc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
        if (PTE_ADDR(pte_one) == PTE_ADDR(pte_two)) {
     3e1:	39 c6                	cmp    %eax,%esi
     3e3:	75 31                	jne    416 <_different_pte_range+0x6f>
            printf(2, "ERROR: virtual address 0x%x%s assigned same physical addresses in pids %d and %d\n",
     3e5:	89 7c 24 14          	mov    %edi,0x14(%esp)
     3e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     3ec:	89 44 24 10          	mov    %eax,0x10(%esp)
     3f0:	8b 45 0c             	mov    0xc(%ebp),%eax
     3f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
     3f7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
     3fb:	c7 44 24 04 94 39 00 	movl   $0x3994,0x4(%esp)
     402:	00 
     403:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     40a:	e8 9d 2d 00 00       	call   31ac <printf>
            return 0;
     40f:	b8 00 00 00 00       	mov    $0x0,%eax
     414:	eb 10                	jmp    426 <_different_pte_range+0x7f>
    for (int addr = start_va; addr < end_va; addr += PGSIZE) {
     416:	81 c3 00 10 00 00    	add    $0x1000,%ebx
     41c:	3b 5d 08             	cmp    0x8(%ebp),%ebx
     41f:	7c 98                	jl     3b9 <_different_pte_range+0x12>
    return 1;
     421:	b8 01 00 00 00       	mov    $0x1,%eax
}
     426:	83 c4 2c             	add    $0x2c,%esp
     429:	5b                   	pop    %ebx
     42a:	5e                   	pop    %esi
     42b:	5f                   	pop    %edi
     42c:	5d                   	pop    %ebp
     42d:	c3                   	ret    

0000042e <verify_ppns_freed>:
static int verify_ppns_freed(const char *descr) {
     42e:	55                   	push   %ebp
     42f:	89 e5                	mov    %esp,%ebp
     431:	57                   	push   %edi
     432:	56                   	push   %esi
     433:	53                   	push   %ebx
     434:	83 ec 2c             	sub    $0x2c,%esp
     437:	89 c7                	mov    %eax,%edi
    for (int i = 0; i < saved_ppn_index; i += 1) {
     439:	bb 00 00 00 00       	mov    $0x0,%ebx
     43e:	eb 41                	jmp    481 <verify_ppns_freed+0x53>
        if (!isphysicalpagefree(saved_ppns[i])) {
     440:	8b 04 9d 60 54 00 00 	mov    0x5460(,%ebx,4),%eax
     447:	89 04 24             	mov    %eax,(%esp)
     44a:	e8 9b 2c 00 00       	call   30ea <isphysicalpagefree>
     44f:	89 c6                	mov    %eax,%esi
     451:	85 c0                	test   %eax,%eax
     453:	75 29                	jne    47e <verify_ppns_freed+0x50>
            printf(2, "ERROR: physical page 0x%x (%s) not freed\n",
     455:	89 5c 24 10          	mov    %ebx,0x10(%esp)
     459:	89 7c 24 0c          	mov    %edi,0xc(%esp)
     45d:	8b 04 9d 60 54 00 00 	mov    0x5460(,%ebx,4),%eax
     464:	89 44 24 08          	mov    %eax,0x8(%esp)
     468:	c7 44 24 04 e8 39 00 	movl   $0x39e8,0x4(%esp)
     46f:	00 
     470:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     477:	e8 30 2d 00 00       	call   31ac <printf>
            return 0;
     47c:	eb 10                	jmp    48e <verify_ppns_freed+0x60>
    for (int i = 0; i < saved_ppn_index; i += 1) {
     47e:	83 c3 01             	add    $0x1,%ebx
     481:	3b 1d 50 54 00 00    	cmp    0x5450,%ebx
     487:	7c b7                	jl     440 <verify_ppns_freed+0x12>
    return 1;
     489:	be 01 00 00 00       	mov    $0x1,%esi
}
     48e:	89 f0                	mov    %esi,%eax
     490:	83 c4 2c             	add    $0x2c,%esp
     493:	5b                   	pop    %ebx
     494:	5e                   	pop    %esi
     495:	5f                   	pop    %edi
     496:	5d                   	pop    %ebp
     497:	c3                   	ret    

00000498 <_sanity_check_range>:
                        const char *explain) {
     498:	55                   	push   %ebp
     499:	89 e5                	mov    %esp,%ebp
     49b:	57                   	push   %edi
     49c:	56                   	push   %esi
     49d:	53                   	push   %ebx
     49e:	83 ec 3c             	sub    $0x3c,%esp
     4a1:	89 c7                	mov    %eax,%edi
     4a3:	89 d6                	mov    %edx,%esi
     4a5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
    for (int addr = start_va; addr < end_va; addr += PGSIZE) {
     4a8:	e9 bc 01 00 00       	jmp    669 <_sanity_check_range+0x1d1>
        uint pte = getpagetableentry(pid, addr);
     4ad:	89 74 24 04          	mov    %esi,0x4(%esp)
     4b1:	89 3c 24             	mov    %edi,(%esp)
     4b4:	e8 29 2c 00 00       	call   30e2 <getpagetableentry>
     4b9:	89 c3                	mov    %eax,%ebx
        if (!(pte & PTE_P)) {
     4bb:	a8 01                	test   $0x1,%al
     4bd:	75 37                	jne    4f6 <_sanity_check_range+0x5e>
            if (allocate_flag == IS_ALLOCATED) {
     4bf:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
     4c3:	0f 85 9a 01 00 00    	jne    663 <_sanity_check_range+0x1cb>
                printf(2, "ERROR: pid %d, address 0x%x%s not allocated (expected allocated)\n"
     4c9:	8b 45 14             	mov    0x14(%ebp),%eax
     4cc:	89 44 24 10          	mov    %eax,0x10(%esp)
     4d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
     4d4:	89 7c 24 08          	mov    %edi,0x8(%esp)
     4d8:	c7 44 24 04 14 3a 00 	movl   $0x3a14,0x4(%esp)
     4df:	00 
     4e0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     4e7:	e8 c0 2c 00 00       	call   31ac <printf>
                return 0;
     4ec:	b8 00 00 00 00       	mov    $0x0,%eax
     4f1:	e9 81 01 00 00       	jmp    677 <_sanity_check_range+0x1df>
        } else if (allocate_flag == NOT_ALLOCATED) {
     4f6:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
     4fa:	75 2d                	jne    529 <_sanity_check_range+0x91>
            printf(2, "ERROR: pid %d, address 0x%x%s is allocated (expected not allocated)\n"
     4fc:	8b 45 14             	mov    0x14(%ebp),%eax
     4ff:	89 44 24 10          	mov    %eax,0x10(%esp)
     503:	89 74 24 0c          	mov    %esi,0xc(%esp)
     507:	89 7c 24 08          	mov    %edi,0x8(%esp)
     50b:	c7 44 24 04 80 3a 00 	movl   $0x3a80,0x4(%esp)
     512:	00 
     513:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     51a:	e8 8d 2c 00 00       	call   31ac <printf>
            return 0;
     51f:	b8 00 00 00 00       	mov    $0x0,%eax
     524:	e9 4e 01 00 00       	jmp    677 <_sanity_check_range+0x1df>
     529:	25 00 f0 ff ff       	and    $0xfffff000,%eax
     52e:	89 45 e0             	mov    %eax,-0x20(%ebp)
            if (isphysicalpagefree(PTE_ADDR(pte) >> PTXSHIFT)) {
     531:	c1 e8 0c             	shr    $0xc,%eax
     534:	89 45 dc             	mov    %eax,-0x24(%ebp)
     537:	89 04 24             	mov    %eax,(%esp)
     53a:	e8 ab 2b 00 00       	call   30ea <isphysicalpagefree>
     53f:	85 c0                	test   %eax,%eax
     541:	74 2a                	je     56d <_sanity_check_range+0xd5>
                printf(2, "ERROR: pid %d address 0x%x%s allocated freed physical page 0x%x\n"
     543:	8b 45 dc             	mov    -0x24(%ebp),%eax
     546:	89 44 24 14          	mov    %eax,0x14(%esp)
     54a:	8b 45 14             	mov    0x14(%ebp),%eax
     54d:	89 44 24 10          	mov    %eax,0x10(%esp)
     551:	89 74 24 0c          	mov    %esi,0xc(%esp)
     555:	89 7c 24 08          	mov    %edi,0x8(%esp)
     559:	c7 44 24 04 f0 3a 00 	movl   $0x3af0,0x4(%esp)
     560:	00 
     561:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     568:	e8 3f 2c 00 00       	call   31ac <printf>
            if (PTE_ADDR(pte) == 0) {
     56d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     571:	75 23                	jne    596 <_sanity_check_range+0xfe>
                printf(2, "ERROR: pid %d address 0x%x%s allocated invalid physical page 0\n"
     573:	8b 45 14             	mov    0x14(%ebp),%eax
     576:	89 44 24 10          	mov    %eax,0x10(%esp)
     57a:	89 74 24 0c          	mov    %esi,0xc(%esp)
     57e:	89 7c 24 08          	mov    %edi,0x8(%esp)
     582:	c7 44 24 04 74 3b 00 	movl   $0x3b74,0x4(%esp)
     589:	00 
     58a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     591:	e8 16 2c 00 00       	call   31ac <printf>
            if (pte & PTE_U) {
     596:	f6 c3 04             	test   $0x4,%bl
     599:	74 33                	je     5ce <_sanity_check_range+0x136>
                if (prot_flag == IS_GUARD) {
     59b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
     59f:	75 5d                	jne    5fe <_sanity_check_range+0x166>
                    printf(2, "ERROR: pid %d, address 0x%x%s is user-accessible (expected not)\n"
     5a1:	8b 45 14             	mov    0x14(%ebp),%eax
     5a4:	89 44 24 10          	mov    %eax,0x10(%esp)
     5a8:	89 74 24 0c          	mov    %esi,0xc(%esp)
     5ac:	89 7c 24 08          	mov    %edi,0x8(%esp)
     5b0:	c7 44 24 04 f4 3b 00 	movl   $0x3bf4,0x4(%esp)
     5b7:	00 
     5b8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     5bf:	e8 e8 2b 00 00       	call   31ac <printf>
                    return 0;
     5c4:	b8 00 00 00 00       	mov    $0x0,%eax
     5c9:	e9 a9 00 00 00       	jmp    677 <_sanity_check_range+0x1df>
                if (prot_flag != IS_GUARD) {
     5ce:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
     5d2:	74 2a                	je     5fe <_sanity_check_range+0x166>
                    printf(2, "ERROR: pid %d, address 0x%x%s not user-accessible (expected to be)\n"
     5d4:	8b 45 14             	mov    0x14(%ebp),%eax
     5d7:	89 44 24 10          	mov    %eax,0x10(%esp)
     5db:	89 74 24 0c          	mov    %esi,0xc(%esp)
     5df:	89 7c 24 08          	mov    %edi,0x8(%esp)
     5e3:	c7 44 24 04 60 3c 00 	movl   $0x3c60,0x4(%esp)
     5ea:	00 
     5eb:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     5f2:	e8 b5 2b 00 00       	call   31ac <printf>
                    return 0;
     5f7:	b8 00 00 00 00       	mov    $0x0,%eax
     5fc:	eb 79                	jmp    677 <_sanity_check_range+0x1df>
            if (pte & PTE_W) {
     5fe:	f6 c3 02             	test   $0x2,%bl
     601:	74 30                	je     633 <_sanity_check_range+0x19b>
                if (prot_flag == IS_SHARED) {
     603:	83 7d 0c 02          	cmpl   $0x2,0xc(%ebp)
     607:	75 5a                	jne    663 <_sanity_check_range+0x1cb>
                    printf(2, "ERROR: pid %d, address 0x%x%s is writable (expected not be)\n"
     609:	8b 45 14             	mov    0x14(%ebp),%eax
     60c:	89 44 24 10          	mov    %eax,0x10(%esp)
     610:	89 74 24 0c          	mov    %esi,0xc(%esp)
     614:	89 7c 24 08          	mov    %edi,0x8(%esp)
     618:	c7 44 24 04 d0 3c 00 	movl   $0x3cd0,0x4(%esp)
     61f:	00 
     620:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     627:	e8 80 2b 00 00       	call   31ac <printf>
                    return 0;
     62c:	b8 00 00 00 00       	mov    $0x0,%eax
     631:	eb 44                	jmp    677 <_sanity_check_range+0x1df>
                if (prot_flag == NOT_SHARED) {
     633:	83 7d 0c 04          	cmpl   $0x4,0xc(%ebp)
     637:	75 2a                	jne    663 <_sanity_check_range+0x1cb>
                    printf(2, "ERROR: pid %d, address 0x%x%s is not writable (expected to be)\n"
     639:	8b 45 14             	mov    0x14(%ebp),%eax
     63c:	89 44 24 10          	mov    %eax,0x10(%esp)
     640:	89 74 24 0c          	mov    %esi,0xc(%esp)
     644:	89 7c 24 08          	mov    %edi,0x8(%esp)
     648:	c7 44 24 04 38 3d 00 	movl   $0x3d38,0x4(%esp)
     64f:	00 
     650:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     657:	e8 50 2b 00 00       	call   31ac <printf>
                    return 0;
     65c:	b8 00 00 00 00       	mov    $0x0,%eax
     661:	eb 14                	jmp    677 <_sanity_check_range+0x1df>
    for (int addr = start_va; addr < end_va; addr += PGSIZE) {
     663:	81 c6 00 10 00 00    	add    $0x1000,%esi
     669:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
     66c:	0f 8c 3b fe ff ff    	jl     4ad <_sanity_check_range+0x15>
    return 1;
     672:	b8 01 00 00 00       	mov    $0x1,%eax
}
     677:	83 c4 3c             	add    $0x3c,%esp
     67a:	5b                   	pop    %ebx
     67b:	5e                   	pop    %esi
     67c:	5f                   	pop    %edi
     67d:	5d                   	pop    %ebp
     67e:	c3                   	ret    

0000067f <_sanity_check_range_self>:
        const char *explain) {
     67f:	55                   	push   %ebp
     680:	89 e5                	mov    %esp,%ebp
     682:	57                   	push   %edi
     683:	56                   	push   %esi
     684:	53                   	push   %ebx
     685:	83 ec 1c             	sub    $0x1c,%esp
     688:	89 c3                	mov    %eax,%ebx
     68a:	89 d6                	mov    %edx,%esi
     68c:	89 cf                	mov    %ecx,%edi
    return _sanity_check_range(getpid(), start_va, end_va, allocate_flag, guard_flag, free_check, explain);
     68e:	e8 27 2a 00 00       	call   30ba <getpid>
     693:	8b 55 10             	mov    0x10(%ebp),%edx
     696:	89 54 24 0c          	mov    %edx,0xc(%esp)
     69a:	8b 55 0c             	mov    0xc(%ebp),%edx
     69d:	89 54 24 08          	mov    %edx,0x8(%esp)
     6a1:	8b 55 08             	mov    0x8(%ebp),%edx
     6a4:	89 54 24 04          	mov    %edx,0x4(%esp)
     6a8:	89 3c 24             	mov    %edi,(%esp)
     6ab:	89 f1                	mov    %esi,%ecx
     6ad:	89 da                	mov    %ebx,%edx
     6af:	e8 e4 fd ff ff       	call   498 <_sanity_check_range>
}
     6b4:	83 c4 1c             	add    $0x1c,%esp
     6b7:	5b                   	pop    %ebx
     6b8:	5e                   	pop    %esi
     6b9:	5f                   	pop    %edi
     6ba:	5d                   	pop    %ebp
     6bb:	c3                   	ret    

000006bc <_sanity_check_self_nonheap>:
MAYBE_UNUSED static TestResult _sanity_check_self_nonheap(int free_check) {
     6bc:	55                   	push   %ebp
     6bd:	89 e5                	mov    %esp,%ebp
     6bf:	56                   	push   %esi
     6c0:	53                   	push   %ebx
     6c1:	83 ec 10             	sub    $0x10,%esp
     6c4:	89 c6                	mov    %eax,%esi
    uint guard = _get_guard();
     6c6:	e8 35 f9 ff ff       	call   0 <_get_guard>
     6cb:	89 c3                	mov    %eax,%ebx
    if (!_sanity_check_range_self(0, guard, IS_ALLOCATED, NOT_GUARD, free_check, " (memory before guard page, before new allocation)")) {
     6cd:	c7 44 24 08 a4 3d 00 	movl   $0x3da4,0x8(%esp)
     6d4:	00 
     6d5:	89 74 24 04          	mov    %esi,0x4(%esp)
     6d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     6e0:	b9 01 00 00 00       	mov    $0x1,%ecx
     6e5:	89 c2                	mov    %eax,%edx
     6e7:	b8 00 00 00 00       	mov    $0x0,%eax
     6ec:	e8 8e ff ff ff       	call   67f <_sanity_check_range_self>
     6f1:	85 c0                	test   %eax,%eax
     6f3:	74 2d                	je     722 <_sanity_check_self_nonheap+0x66>
    if (!_sanity_check_range_self(guard, guard + PGSIZE, IS_ALLOCATED, IS_GUARD, free_check, " (guard page)")) {
     6f5:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
     6fb:	c7 44 24 08 0a 33 00 	movl   $0x330a,0x8(%esp)
     702:	00 
     703:	89 74 24 04          	mov    %esi,0x4(%esp)
     707:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     70e:	b9 01 00 00 00       	mov    $0x1,%ecx
     713:	89 d8                	mov    %ebx,%eax
     715:	e8 65 ff ff ff       	call   67f <_sanity_check_range_self>
     71a:	85 c0                	test   %eax,%eax
     71c:	75 0b                	jne    729 <_sanity_check_self_nonheap+0x6d>
        return TR_FAIL_PTE;
     71e:	b0 02                	mov    $0x2,%al
     720:	eb 0c                	jmp    72e <_sanity_check_self_nonheap+0x72>
        return TR_FAIL_PTE;
     722:	b8 02 00 00 00       	mov    $0x2,%eax
     727:	eb 05                	jmp    72e <_sanity_check_self_nonheap+0x72>
    return TR_SUCCESS;
     729:	b8 00 00 00 00       	mov    $0x0,%eax
}
     72e:	83 c4 10             	add    $0x10,%esp
     731:	5b                   	pop    %ebx
     732:	5e                   	pop    %esi
     733:	5d                   	pop    %ebp
     734:	c3                   	ret    

00000735 <_init_pipes>:
int _init_pipes(struct test_pipes *pipes) {
     735:	55                   	push   %ebp
     736:	89 e5                	mov    %esp,%ebp
     738:	53                   	push   %ebx
     739:	83 ec 14             	sub    $0x14,%esp
     73c:	89 c3                	mov    %eax,%ebx
    pipes->from_child[0] = -1;
     73e:	c7 40 08 ff ff ff ff 	movl   $0xffffffff,0x8(%eax)
    pipes->from_child[1] = -1;
     745:	c7 40 0c ff ff ff ff 	movl   $0xffffffff,0xc(%eax)
    if (pipe(pipes->from_child) < 0)
     74c:	8d 40 08             	lea    0x8(%eax),%eax
     74f:	89 04 24             	mov    %eax,(%esp)
     752:	e8 f3 28 00 00       	call   304a <pipe>
     757:	85 c0                	test   %eax,%eax
     759:	79 0a                	jns    765 <_init_pipes+0x30>
        CRASH("error creating pipes");
     75b:	b8 18 33 00 00       	mov    $0x3318,%eax
     760:	e8 67 f9 ff ff       	call   cc <CRASH>
    pipes->to_child[0] = -1;
     765:	c7 03 ff ff ff ff    	movl   $0xffffffff,(%ebx)
    pipes->to_child[1] = -1;
     76b:	c7 43 04 ff ff ff ff 	movl   $0xffffffff,0x4(%ebx)
    if (pipe(pipes->to_child) < 0)
     772:	89 1c 24             	mov    %ebx,(%esp)
     775:	e8 d0 28 00 00       	call   304a <pipe>
     77a:	85 c0                	test   %eax,%eax
     77c:	79 0a                	jns    788 <_init_pipes+0x53>
        CRASH("error creating pipes");
     77e:	b8 18 33 00 00       	mov    $0x3318,%eax
     783:	e8 44 f9 ff ff       	call   cc <CRASH>
}
     788:	b8 00 00 00 00       	mov    $0x0,%eax
     78d:	83 c4 14             	add    $0x14,%esp
     790:	5b                   	pop    %ebx
     791:	5d                   	pop    %ebp
     792:	c3                   	ret    

00000793 <_pipe_sync_cleanup>:
void _pipe_sync_cleanup(struct test_pipes *pipes) {
     793:	55                   	push   %ebp
     794:	89 e5                	mov    %esp,%ebp
     796:	53                   	push   %ebx
     797:	83 ec 14             	sub    $0x14,%esp
     79a:	89 c3                	mov    %eax,%ebx
    if (pipes->from_child[0] != -1)
     79c:	8b 40 08             	mov    0x8(%eax),%eax
     79f:	83 f8 ff             	cmp    $0xffffffff,%eax
     7a2:	74 08                	je     7ac <_pipe_sync_cleanup+0x19>
        close(pipes->from_child[0]);
     7a4:	89 04 24             	mov    %eax,(%esp)
     7a7:	e8 b6 28 00 00       	call   3062 <close>
    if (pipes->from_child[1] != -1)
     7ac:	8b 43 0c             	mov    0xc(%ebx),%eax
     7af:	83 f8 ff             	cmp    $0xffffffff,%eax
     7b2:	74 08                	je     7bc <_pipe_sync_cleanup+0x29>
        close(pipes->from_child[1]);
     7b4:	89 04 24             	mov    %eax,(%esp)
     7b7:	e8 a6 28 00 00       	call   3062 <close>
    if (pipes->to_child[0] != -1)
     7bc:	8b 03                	mov    (%ebx),%eax
     7be:	83 f8 ff             	cmp    $0xffffffff,%eax
     7c1:	74 08                	je     7cb <_pipe_sync_cleanup+0x38>
        close(pipes->to_child[0]);
     7c3:	89 04 24             	mov    %eax,(%esp)
     7c6:	e8 97 28 00 00       	call   3062 <close>
    if (pipes->to_child[1] != -1)
     7cb:	8b 43 04             	mov    0x4(%ebx),%eax
     7ce:	83 f8 ff             	cmp    $0xffffffff,%eax
     7d1:	74 08                	je     7db <_pipe_sync_cleanup+0x48>
        close(pipes->to_child[1]);
     7d3:	89 04 24             	mov    %eax,(%esp)
     7d6:	e8 87 28 00 00       	call   3062 <close>
}
     7db:	83 c4 14             	add    $0x14,%esp
     7de:	5b                   	pop    %ebx
     7df:	5d                   	pop    %ebp
     7e0:	c3                   	ret    

000007e1 <_pipe_sync_setup_child>:
void _pipe_sync_setup_child(struct test_pipes *pipes) {
     7e1:	55                   	push   %ebp
     7e2:	89 e5                	mov    %esp,%ebp
     7e4:	53                   	push   %ebx
     7e5:	83 ec 14             	sub    $0x14,%esp
     7e8:	89 c3                	mov    %eax,%ebx
    close(pipes->from_child[0]);
     7ea:	8b 40 08             	mov    0x8(%eax),%eax
     7ed:	89 04 24             	mov    %eax,(%esp)
     7f0:	e8 6d 28 00 00       	call   3062 <close>
    pipes->from_child[0] = -1;
     7f5:	c7 43 08 ff ff ff ff 	movl   $0xffffffff,0x8(%ebx)
    close(pipes->to_child[1]);
     7fc:	8b 43 04             	mov    0x4(%ebx),%eax
     7ff:	89 04 24             	mov    %eax,(%esp)
     802:	e8 5b 28 00 00       	call   3062 <close>
    pipes->to_child[1] = -1;
     807:	c7 43 04 ff ff ff ff 	movl   $0xffffffff,0x4(%ebx)
}
     80e:	83 c4 14             	add    $0x14,%esp
     811:	5b                   	pop    %ebx
     812:	5d                   	pop    %ebp
     813:	c3                   	ret    

00000814 <_test_exec_child>:
MAYBE_UNUSED static TestResult _test_exec_child(char **argv) {
     814:	55                   	push   %ebp
     815:	89 e5                	mov    %esp,%ebp
     817:	57                   	push   %edi
     818:	53                   	push   %ebx
     819:	83 ec 60             	sub    $0x60,%esp
    struct test_pipes pipes = {
     81c:	c7 45 e8 03 00 00 00 	movl   $0x3,-0x18(%ebp)
     823:	c7 45 ec 04 00 00 00 	movl   $0x4,-0x14(%ebp)
     82a:	c7 45 f0 05 00 00 00 	movl   $0x5,-0x10(%ebp)
     831:	c7 45 f4 06 00 00 00 	movl   $0x6,-0xc(%ebp)
    _pipe_sync_setup_child(&pipes);
     838:	8d 45 e8             	lea    -0x18(%ebp),%eax
     83b:	e8 a1 ff ff ff       	call   7e1 <_pipe_sync_setup_child>
    _pipe_sync_child(&pipes);
     840:	8d 45 e8             	lea    -0x18(%ebp),%eax
     843:	e8 b4 f9 ff ff       	call   1fc <_pipe_sync_child>
    int result = _sanity_check_self_nonheap(WITH_FREE_CHECK);
     848:	b8 00 00 00 00       	mov    $0x0,%eax
     84d:	e8 6a fe ff ff       	call   6bc <_sanity_check_self_nonheap>
    if (result != TR_SUCCESS)
     852:	85 c0                	test   %eax,%eax
     854:	75 5b                	jne    8b1 <_test_exec_child+0x9d>
    _pipe_sync_child(&pipes);
     856:	8d 45 e8             	lea    -0x18(%ebp),%eax
     859:	e8 9e f9 ff ff       	call   1fc <_pipe_sync_child>
    int pte_values[EXEC_TEST_PTE_VALUES] = {0};
     85e:	8d 7d a8             	lea    -0x58(%ebp),%edi
     861:	b9 10 00 00 00       	mov    $0x10,%ecx
     866:	b8 00 00 00 00       	mov    $0x0,%eax
     86b:	f3 ab                	rep stos %eax,%es:(%edi)
    for (int i = 0; i < EXEC_TEST_PTE_VALUES; ++i) {
     86d:	bb 00 00 00 00       	mov    $0x0,%ebx
     872:	eb 1b                	jmp    88f <_test_exec_child+0x7b>
        pte_values[i] = getpagetableentry(getpid(), i << PTXSHIFT);
     874:	e8 41 28 00 00       	call   30ba <getpid>
     879:	89 da                	mov    %ebx,%edx
     87b:	c1 e2 0c             	shl    $0xc,%edx
     87e:	89 54 24 04          	mov    %edx,0x4(%esp)
     882:	89 04 24             	mov    %eax,(%esp)
     885:	e8 58 28 00 00       	call   30e2 <getpagetableentry>
     88a:	89 44 9d a8          	mov    %eax,-0x58(%ebp,%ebx,4)
    for (int i = 0; i < EXEC_TEST_PTE_VALUES; ++i) {
     88e:	43                   	inc    %ebx
     88f:	83 fb 0f             	cmp    $0xf,%ebx
     892:	7e e0                	jle    874 <_test_exec_child+0x60>
    _pipe_send_child(&pipes, pte_values, EXEC_TEST_PTE_VALUES);
     894:	b9 10 00 00 00       	mov    $0x10,%ecx
     899:	8d 55 a8             	lea    -0x58(%ebp),%edx
     89c:	8d 45 e8             	lea    -0x18(%ebp),%eax
     89f:	e8 da f7 ff ff       	call   7e <_pipe_send_child>
    _pipe_sync_child(&pipes);
     8a4:	8d 45 e8             	lea    -0x18(%ebp),%eax
     8a7:	e8 50 f9 ff ff       	call   1fc <_pipe_sync_child>
    return TR_SUCCESS;
     8ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
     8b1:	83 c4 60             	add    $0x60,%esp
     8b4:	5b                   	pop    %ebx
     8b5:	5f                   	pop    %edi
     8b6:	5d                   	pop    %ebp
     8b7:	c3                   	ret    

000008b8 <_pipe_sync_setup_parent>:
void _pipe_sync_setup_parent(struct test_pipes *pipes) {
     8b8:	55                   	push   %ebp
     8b9:	89 e5                	mov    %esp,%ebp
     8bb:	53                   	push   %ebx
     8bc:	83 ec 14             	sub    $0x14,%esp
     8bf:	89 c3                	mov    %eax,%ebx
    close(pipes->from_child[1]);
     8c1:	8b 40 0c             	mov    0xc(%eax),%eax
     8c4:	89 04 24             	mov    %eax,(%esp)
     8c7:	e8 96 27 00 00       	call   3062 <close>
    pipes->from_child[1] = -1;
     8cc:	c7 43 0c ff ff ff ff 	movl   $0xffffffff,0xc(%ebx)
    close(pipes->to_child[0]);
     8d3:	8b 03                	mov    (%ebx),%eax
     8d5:	89 04 24             	mov    %eax,(%esp)
     8d8:	e8 85 27 00 00       	call   3062 <close>
    pipes->to_child[0] = -1;
     8dd:	c7 03 ff ff ff ff    	movl   $0xffffffff,(%ebx)
}
     8e3:	83 c4 14             	add    $0x14,%esp
     8e6:	5b                   	pop    %ebx
     8e7:	5d                   	pop    %ebp
     8e8:	c3                   	ret    

000008e9 <test_oob>:
        return result;
    }
}

MAYBE_UNUSED
static TestResult test_oob(uint heap_offset, int fork_p, int write_p, int guard_p) {
     8e9:	55                   	push   %ebp
     8ea:	89 e5                	mov    %esp,%ebp
     8ec:	57                   	push   %edi
     8ed:	56                   	push   %esi
     8ee:	53                   	push   %ebx
     8ef:	83 ec 2c             	sub    $0x2c,%esp
     8f2:	89 c6                	mov    %eax,%esi
     8f4:	89 d3                	mov    %edx,%ebx
     8f6:	89 cf                	mov    %ecx,%edi
    if (guard_p) {
     8f8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     8fc:	74 3a                	je     938 <test_oob+0x4f>
        if (heap_offset >= 4096) {
     8fe:	3d ff 0f 00 00       	cmp    $0xfff,%eax
     903:	76 05                	jbe    90a <test_oob+0x21>
            heap_offset = 4095;
     905:	be ff 0f 00 00       	mov    $0xfff,%esi
        }
        printf(1,
     90a:	85 ff                	test   %edi,%edi
     90c:	74 07                	je     915 <test_oob+0x2c>
     90e:	b8 2d 33 00 00       	mov    $0x332d,%eax
     913:	eb 05                	jmp    91a <test_oob+0x31>
     915:	b8 35 33 00 00       	mov    $0x3335,%eax
     91a:	89 74 24 0c          	mov    %esi,0xc(%esp)
     91e:	89 44 24 08          	mov    %eax,0x8(%esp)
     922:	c7 44 24 04 d8 3d 00 	movl   $0x3dd8,0x4(%esp)
     929:	00 
     92a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     931:	e8 76 28 00 00       	call   31ac <printf>
     936:	eb 2c                	jmp    964 <test_oob+0x7b>
            "Testing out of bounds access %s 0x%x bytes after beginning of guard page\n",
            write_p ? "writing" : "reading", heap_offset);
    } else {
      printf(1,
     938:	85 c9                	test   %ecx,%ecx
     93a:	74 07                	je     943 <test_oob+0x5a>
     93c:	b8 2d 33 00 00       	mov    $0x332d,%eax
     941:	eb 05                	jmp    948 <test_oob+0x5f>
     943:	b8 35 33 00 00       	mov    $0x3335,%eax
     948:	89 74 24 0c          	mov    %esi,0xc(%esp)
     94c:	89 44 24 08          	mov    %eax,0x8(%esp)
     950:	c7 44 24 04 24 3e 00 	movl   $0x3e24,0x4(%esp)
     957:	00 
     958:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     95f:	e8 48 28 00 00       	call   31ac <printf>
          "Testing out of bounds access %s 0x%x bytes after end of heap\n",
          write_p ? "writing" : "reading", heap_offset);
    }
    if (fork_p) {
     964:	85 db                	test   %ebx,%ebx
     966:	74 14                	je     97c <test_oob+0x93>
        printf(1, "  doing access in child process\n");
     968:	c7 44 24 04 64 3e 00 	movl   $0x3e64,0x4(%esp)
     96f:	00 
     970:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     977:	e8 30 28 00 00       	call   31ac <printf>
    }
    struct test_pipes pipes = NO_PIPES;
     97c:	a1 f4 52 00 00       	mov    0x52f4,%eax
     981:	89 45 d8             	mov    %eax,-0x28(%ebp)
     984:	a1 f8 52 00 00       	mov    0x52f8,%eax
     989:	89 45 dc             	mov    %eax,-0x24(%ebp)
     98c:	a1 fc 52 00 00       	mov    0x52fc,%eax
     991:	89 45 e0             	mov    %eax,-0x20(%ebp)
     994:	a1 00 53 00 00       	mov    0x5300,%eax
     999:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    int pid = -1;
    int result = TR_FAIL_UNKNOWN;
    if (fork_p) {
     99c:	85 db                	test   %ebx,%ebx
     99e:	0f 84 97 00 00 00    	je     a3b <test_oob+0x152>
        _init_pipes(&pipes);
     9a4:	8d 45 d8             	lea    -0x28(%ebp),%eax
     9a7:	e8 89 fd ff ff       	call   735 <_init_pipes>
        pid = fork();
     9ac:	e8 81 26 00 00       	call   3032 <fork>
        if (pid == -1) {
     9b1:	83 f8 ff             	cmp    $0xffffffff,%eax
     9b4:	75 0a                	jne    9c0 <test_oob+0xd7>
            CRASH("fork() failed");
     9b6:	b8 3d 33 00 00       	mov    $0x333d,%eax
     9bb:	e8 0c f7 ff ff       	call   cc <CRASH>
        } else if (pid != 0) {
     9c0:	85 c0                	test   %eax,%eax
     9c2:	74 67                	je     a2b <test_oob+0x142>
            _pipe_sync_setup_parent(&pipes);
     9c4:	8d 45 d8             	lea    -0x28(%ebp),%eax
     9c7:	e8 ec fe ff ff       	call   8b8 <_pipe_sync_setup_parent>
            if (!_pipe_sync_parent(&pipes)) {
     9cc:	8d 45 d8             	lea    -0x28(%ebp),%eax
     9cf:	e8 1b f7 ff ff       	call   ef <_pipe_sync_parent>
                result = TR_FAIL_SYNC;
            }
            if (!_pipe_assert_broken_parent(&pipes)) {
     9d4:	8d 45 d8             	lea    -0x28(%ebp),%eax
     9d7:	e8 73 f6 ff ff       	call   4f <_pipe_assert_broken_parent>
     9dc:	85 c0                	test   %eax,%eax
     9de:	75 07                	jne    9e7 <test_oob+0xfe>
                result = TR_FAIL_UNKNOWN;
     9e0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
     9e5:	eb 05                	jmp    9ec <test_oob+0x103>
            } else {
                result = TR_SUCCESS;
     9e7:	bb 00 00 00 00       	mov    $0x0,%ebx
            }
            _pipe_sync_cleanup(&pipes);
     9ec:	8d 45 d8             	lea    -0x28(%ebp),%eax
     9ef:	e8 9f fd ff ff       	call   793 <_pipe_sync_cleanup>
            wait();
     9f4:	e8 49 26 00 00       	call   3042 <wait>
            if (result == TR_SUCCESS) {
     9f9:	85 db                	test   %ebx,%ebx
     9fb:	75 16                	jne    a13 <test_oob+0x12a>
                printf(1, "Test successful.\n");
     9fd:	c7 44 24 04 4b 33 00 	movl   $0x334b,0x4(%esp)
     a04:	00 
     a05:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a0c:	e8 9b 27 00 00       	call   31ac <printf>
     a11:	eb 14                	jmp    a27 <test_oob+0x13e>
            } else {
                printf(1, "Test failed.\n");
     a13:	c7 44 24 04 5d 33 00 	movl   $0x335d,0x4(%esp)
     a1a:	00 
     a1b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a22:	e8 85 27 00 00       	call   31ac <printf>
            }
            return result;
     a27:	89 d8                	mov    %ebx,%eax
     a29:	eb 70                	jmp    a9b <test_oob+0x1b2>
        } else {
            _pipe_sync_setup_child(&pipes);
     a2b:	8d 45 d8             	lea    -0x28(%ebp),%eax
     a2e:	e8 ae fd ff ff       	call   7e1 <_pipe_sync_setup_child>
            _pipe_sync_child(&pipes);
     a33:	8d 45 d8             	lea    -0x28(%ebp),%eax
     a36:	e8 c1 f7 ff ff       	call   1fc <_pipe_sync_child>
        }
    }
    char *p;
    if (guard_p) {
     a3b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     a3f:	74 09                	je     a4a <test_oob+0x161>
      p = (char*) _get_guard() + heap_offset;
     a41:	e8 ba f5 ff ff       	call   0 <_get_guard>
     a46:	01 c6                	add    %eax,%esi
     a48:	eb 0e                	jmp    a58 <test_oob+0x16f>
    } else {
      p = sbrk(0) + heap_offset;
     a4a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     a51:	e8 6c 26 00 00       	call   30c2 <sbrk>
     a56:	01 c6                	add    %eax,%esi
    }
    if (write_p) {
     a58:	85 ff                	test   %edi,%edi
     a5a:	74 05                	je     a61 <test_oob+0x178>
        __asm__ volatile(
     a5c:	c6 06 2a             	movb   $0x2a,(%esi)
     a5f:	eb 02                	jmp    a63 <test_oob+0x17a>
            :"=m"(*p) /* output */
            : /* input */
            :"memory" /* clobber */
        );
    } else {
        __asm__ volatile(
     a61:	8a 06                	mov    (%esi),%al
            : /* output */
            :"m"(*p) /* input */
            :"%eax" /* clobber */
        );
    }
    if (fork_p) {
     a63:	85 db                	test   %ebx,%ebx
     a65:	74 1b                	je     a82 <test_oob+0x199>
        _pipe_sync_child(&pipes);
     a67:	8d 45 d8             	lea    -0x28(%ebp),%eax
     a6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
     a70:	e8 87 f7 ff ff       	call   1fc <_pipe_sync_child>
        _pipe_sync_cleanup(&pipes);
     a75:	8d 45 d8             	lea    -0x28(%ebp),%eax
     a78:	e8 16 fd ff ff       	call   793 <_pipe_sync_cleanup>
        exit();
     a7d:	e8 b8 25 00 00       	call   303a <exit>
    }
    if (result == TR_SUCCESS) {
        printf(1, "Test successful.\n");
    } else {
        printf(1, "Test failed.\n");
     a82:	c7 44 24 04 5d 33 00 	movl   $0x335d,0x4(%esp)
     a89:	00 
     a8a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a91:	e8 16 27 00 00       	call   31ac <printf>
    }
    return result;
     a96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
     a9b:	83 c4 2c             	add    $0x2c,%esp
     a9e:	5b                   	pop    %ebx
     a9f:	5e                   	pop    %esi
     aa0:	5f                   	pop    %edi
     aa1:	5d                   	pop    %ebp
     aa2:	c3                   	ret    

00000aa3 <_test_exec_parent>:
MAYBE_UNUSED static TestResult _test_exec_parent(struct test_pipes *pipes, int child_pid) {
     aa3:	55                   	push   %ebp
     aa4:	89 e5                	mov    %esp,%ebp
     aa6:	57                   	push   %edi
     aa7:	56                   	push   %esi
     aa8:	53                   	push   %ebx
     aa9:	83 ec 7c             	sub    $0x7c,%esp
     aac:	89 c7                	mov    %eax,%edi
     aae:	89 45 90             	mov    %eax,-0x70(%ebp)
     ab1:	89 d3                	mov    %edx,%ebx
     ab3:	89 55 94             	mov    %edx,-0x6c(%ebp)
    _pipe_sync_setup_parent(pipes);
     ab6:	e8 fd fd ff ff       	call   8b8 <_pipe_sync_setup_parent>
    _pipe_sync_parent(pipes);
     abb:	89 f8                	mov    %edi,%eax
     abd:	e8 2d f6 ff ff       	call   ef <_pipe_sync_parent>
    clear_saved_ppns();
     ac2:	e8 48 f5 ff ff       	call   f <clear_saved_ppns>
    if (!save_ppns(child_pid, 0, 16 * PGSIZE, 1))
     ac7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ace:	b9 00 00 01 00       	mov    $0x10000,%ecx
     ad3:	ba 00 00 00 00       	mov    $0x0,%edx
     ad8:	89 d8                	mov    %ebx,%eax
     ada:	e8 79 f7 ff ff       	call   258 <save_ppns>
     adf:	85 c0                	test   %eax,%eax
     ae1:	0f 84 a4 00 00 00    	je     b8b <_test_exec_parent+0xe8>
    _pipe_sync_parent(pipes);
     ae7:	8b 7d 90             	mov    -0x70(%ebp),%edi
     aea:	89 f8                	mov    %edi,%eax
     aec:	e8 fe f5 ff ff       	call   ef <_pipe_sync_parent>
    int num_pte_values = EXEC_TEST_PTE_VALUES;
     af1:	c7 45 a4 10 00 00 00 	movl   $0x10,-0x5c(%ebp)
    _pipe_recv_parent(pipes, pte_values_from_child, &num_pte_values);
     af8:	8d 4d a4             	lea    -0x5c(%ebp),%ecx
     afb:	8d 55 a8             	lea    -0x58(%ebp),%edx
     afe:	89 f8                	mov    %edi,%eax
     b00:	e8 4c f6 ff ff       	call   151 <_pipe_recv_parent>
    for (int i = 0; i < num_pte_values; i += 1) {
     b05:	bb 00 00 00 00       	mov    $0x0,%ebx
     b0a:	eb 52                	jmp    b5e <_test_exec_parent+0xbb>
        if (pte_values_from_child[i] != getpagetableentry(child_pid, i << PTXSHIFT)) {
     b0c:	8b 7c 9d a8          	mov    -0x58(%ebp,%ebx,4),%edi
     b10:	89 de                	mov    %ebx,%esi
     b12:	c1 e6 0c             	shl    $0xc,%esi
     b15:	89 74 24 04          	mov    %esi,0x4(%esp)
     b19:	8b 45 94             	mov    -0x6c(%ebp),%eax
     b1c:	89 04 24             	mov    %eax,(%esp)
     b1f:	e8 be 25 00 00       	call   30e2 <getpagetableentry>
     b24:	39 c7                	cmp    %eax,%edi
     b26:	74 33                	je     b5b <_test_exec_parent+0xb8>
            printf(2, "ERROR: result of getpagetableentry(%d, 0x%x) in pid %d disagreed with pid %d\n",
     b28:	e8 8d 25 00 00       	call   30ba <getpid>
     b2d:	8b 4d 94             	mov    -0x6c(%ebp),%ecx
     b30:	89 4c 24 14          	mov    %ecx,0x14(%esp)
     b34:	89 44 24 10          	mov    %eax,0x10(%esp)
     b38:	89 74 24 0c          	mov    %esi,0xc(%esp)
     b3c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
     b40:	c7 44 24 04 88 3e 00 	movl   $0x3e88,0x4(%esp)
     b47:	00 
     b48:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     b4f:	e8 58 26 00 00       	call   31ac <printf>
            result = TR_FAIL_PTE;
     b54:	bb 02 00 00 00       	mov    $0x2,%ebx
            goto early_exit_child;
     b59:	eb 35                	jmp    b90 <_test_exec_parent+0xed>
    for (int i = 0; i < num_pte_values; i += 1) {
     b5b:	83 c3 01             	add    $0x1,%ebx
     b5e:	3b 5d a4             	cmp    -0x5c(%ebp),%ebx
     b61:	7c a9                	jl     b0c <_test_exec_parent+0x69>
    _pipe_sync_parent(pipes);
     b63:	8b 7d 90             	mov    -0x70(%ebp),%edi
     b66:	89 f8                	mov    %edi,%eax
     b68:	e8 82 f5 ff ff       	call   ef <_pipe_sync_parent>
    wait();
     b6d:	e8 d0 24 00 00       	call   3042 <wait>
    _pipe_sync_cleanup(pipes);
     b72:	89 f8                	mov    %edi,%eax
     b74:	e8 1a fc ff ff       	call   793 <_pipe_sync_cleanup>
    if (!verify_ppns_freed("allocated to now-exited exec()'d process")) {
     b79:	b8 d8 3e 00 00       	mov    $0x3ed8,%eax
     b7e:	e8 ab f8 ff ff       	call   42e <verify_ppns_freed>
     b83:	85 c0                	test   %eax,%eax
     b85:	75 25                	jne    bac <_test_exec_parent+0x109>
        return TR_FAIL_NO_FREE;
     b87:	b0 08                	mov    $0x8,%al
     b89:	eb 26                	jmp    bb1 <_test_exec_parent+0x10e>
    int result = TR_SUCCESS;
     b8b:	bb 00 00 00 00       	mov    $0x0,%ebx
    _pipe_sync_cleanup(pipes);
     b90:	8b 45 90             	mov    -0x70(%ebp),%eax
     b93:	e8 fb fb ff ff       	call   793 <_pipe_sync_cleanup>
    kill(child_pid);
     b98:	8b 45 94             	mov    -0x6c(%ebp),%eax
     b9b:	89 04 24             	mov    %eax,(%esp)
     b9e:	e8 c7 24 00 00       	call   306a <kill>
    wait();
     ba3:	e8 9a 24 00 00       	call   3042 <wait>
    return result;
     ba8:	89 d8                	mov    %ebx,%eax
     baa:	eb 05                	jmp    bb1 <_test_exec_parent+0x10e>
    return result;
     bac:	b8 00 00 00 00       	mov    $0x0,%eax
}
     bb1:	83 c4 7c             	add    $0x7c,%esp
     bb4:	5b                   	pop    %ebx
     bb5:	5e                   	pop    %esi
     bb6:	5f                   	pop    %edi
     bb7:	5d                   	pop    %ebp
     bb8:	c3                   	ret    

00000bb9 <_cow_test_child>:
static TestResult _cow_test_child(struct cow_test_info *info, char *heap_base, int child_index) {
     bb9:	55                   	push   %ebp
     bba:	89 e5                	mov    %esp,%ebp
     bbc:	57                   	push   %edi
     bbd:	56                   	push   %esi
     bbe:	53                   	push   %ebx
     bbf:	83 ec 4c             	sub    $0x4c,%esp
     bc2:	89 c6                	mov    %eax,%esi
     bc4:	89 55 d0             	mov    %edx,-0x30(%ebp)
     bc7:	89 c8                	mov    %ecx,%eax
     bc9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
    struct test_pipes *pipes = &info->all_pipes[child_index];
     bcc:	c1 e0 04             	shl    $0x4,%eax
     bcf:	01 f0                	add    %esi,%eax
     bd1:	89 c3                	mov    %eax,%ebx
     bd3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    _pipe_sync_setup_child(pipes);
     bd6:	e8 06 fc ff ff       	call   7e1 <_pipe_sync_setup_child>
    _pipe_sync_child(pipes);
     bdb:	89 d8                	mov    %ebx,%eax
     bdd:	e8 1a f6 ff ff       	call   1fc <_pipe_sync_child>
    for (int region = 0; region < NUM_COW_REGIONS; region += 1) {
     be2:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
     be9:	e9 9a 01 00 00       	jmp    d88 <_cow_test_child+0x1cf>
        char do_write = info->child_write[region][child_index];
     bee:	8b 45 cc             	mov    -0x34(%ebp),%eax
     bf1:	8d 04 86             	lea    (%esi,%eax,4),%eax
     bf4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
     bf7:	0f b6 44 01 50       	movzbl 0x50(%ecx,%eax,1),%eax
     bfc:	89 c3                	mov    %eax,%ebx
     bfe:	88 45 d6             	mov    %al,-0x2a(%ebp)
        _pipe_sync_child(pipes);
     c01:	8b 45 c4             	mov    -0x3c(%ebp),%eax
     c04:	e8 f3 f5 ff ff       	call   1fc <_pipe_sync_child>
        if (do_write && info->use_sys_read_child) {
     c09:	84 db                	test   %bl,%bl
     c0b:	74 1f                	je     c2c <_cow_test_child+0x73>
     c0d:	83 7e 5c 00          	cmpl   $0x0,0x5c(%esi)
     c11:	74 19                	je     c2c <_cow_test_child+0x73>
            if (pipe(dummy_pipe_fds) < 0)
     c13:	8d 45 e0             	lea    -0x20(%ebp),%eax
     c16:	89 04 24             	mov    %eax,(%esp)
     c19:	e8 2c 24 00 00       	call   304a <pipe>
     c1e:	85 c0                	test   %eax,%eax
     c20:	79 0a                	jns    c2c <_cow_test_child+0x73>
                CRASH("error creating pipes");
     c22:	b8 18 33 00 00       	mov    $0x3318,%eax
     c27:	e8 a0 f4 ff ff       	call   cc <CRASH>
        for (int j = info->starts[region]; j < info->ends[region]; j += 1) {
     c2c:	8b 45 cc             	mov    -0x34(%ebp),%eax
     c2f:	8b 7c 86 54          	mov    0x54(%esi,%eax,4),%edi
     c33:	e9 b8 00 00 00       	jmp    cf0 <_cow_test_child+0x137>
            if (heap_base[j] != _heap_test_value(j, -1)) {
     c38:	8b 45 d0             	mov    -0x30(%ebp),%eax
     c3b:	8d 1c 38             	lea    (%eax,%edi,1),%ebx
     c3e:	0f b6 03             	movzbl (%ebx),%eax
     c41:	88 45 d7             	mov    %al,-0x29(%ebp)
     c44:	ba ff ff ff ff       	mov    $0xffffffff,%edx
     c49:	89 f8                	mov    %edi,%eax
     c4b:	e8 ea f3 ff ff       	call   3a <_heap_test_value>
     c50:	38 45 d7             	cmp    %al,-0x29(%ebp)
     c53:	74 24                	je     c79 <_cow_test_child+0xc0>
                printf(2, "ERROR: wrong value read from child %d at offset 0x%x\n",
     c55:	89 7c 24 0c          	mov    %edi,0xc(%esp)
     c59:	8b 45 c8             	mov    -0x38(%ebp),%eax
     c5c:	89 44 24 08          	mov    %eax,0x8(%esp)
     c60:	c7 44 24 04 04 3f 00 	movl   $0x3f04,0x4(%esp)
     c67:	00 
     c68:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     c6f:	e8 38 25 00 00       	call   31ac <printf>
                return TR_FAIL_READBACK;
     c74:	e9 08 01 00 00       	jmp    d81 <_cow_test_child+0x1c8>
            if (do_write) {
     c79:	80 7d d6 00          	cmpb   $0x0,-0x2a(%ebp)
     c7d:	74 6e                	je     ced <_cow_test_child+0x134>
                if (info->use_sys_read_child) {
     c7f:	83 7e 5c 00          	cmpl   $0x0,0x5c(%esi)
     c83:	74 5c                	je     ce1 <_cow_test_child+0x128>
                    char tmp = _heap_test_value(j, child_index);
     c85:	8b 55 c8             	mov    -0x38(%ebp),%edx
     c88:	89 f8                	mov    %edi,%eax
     c8a:	e8 ab f3 ff ff       	call   3a <_heap_test_value>
     c8f:	88 45 df             	mov    %al,-0x21(%ebp)
                    if (write(dummy_pipe_fds[1], &tmp, 1) != 1)
     c92:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     c99:	00 
     c9a:	8d 45 df             	lea    -0x21(%ebp),%eax
     c9d:	89 44 24 04          	mov    %eax,0x4(%esp)
     ca1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     ca4:	89 04 24             	mov    %eax,(%esp)
     ca7:	e8 ae 23 00 00       	call   305a <write>
     cac:	83 f8 01             	cmp    $0x1,%eax
     caf:	74 0a                	je     cbb <_cow_test_child+0x102>
                        CRASH("error writing to temporary pipe");
     cb1:	b8 3c 3f 00 00       	mov    $0x3f3c,%eax
     cb6:	e8 11 f4 ff ff       	call   cc <CRASH>
                    if (read(dummy_pipe_fds[0], &heap_base[j], 1) != 1)
     cbb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     cc2:	00 
     cc3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
     cc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
     cca:	89 04 24             	mov    %eax,(%esp)
     ccd:	e8 80 23 00 00       	call   3052 <read>
     cd2:	83 f8 01             	cmp    $0x1,%eax
     cd5:	74 16                	je     ced <_cow_test_child+0x134>
                        CRASH("error reading from pipe onto COW region");
     cd7:	b8 5c 3f 00 00       	mov    $0x3f5c,%eax
     cdc:	e8 eb f3 ff ff       	call   cc <CRASH>
                    heap_base[j] = _heap_test_value(j, child_index);
     ce1:	8b 55 c8             	mov    -0x38(%ebp),%edx
     ce4:	89 f8                	mov    %edi,%eax
     ce6:	e8 4f f3 ff ff       	call   3a <_heap_test_value>
     ceb:	88 03                	mov    %al,(%ebx)
        for (int j = info->starts[region]; j < info->ends[region]; j += 1) {
     ced:	83 c7 01             	add    $0x1,%edi
     cf0:	8b 45 cc             	mov    -0x34(%ebp),%eax
     cf3:	39 7c 86 58          	cmp    %edi,0x58(%esi,%eax,4)
     cf7:	0f 8f 3b ff ff ff    	jg     c38 <_cow_test_child+0x7f>
        if (do_write && info->use_sys_read_child) {
     cfd:	80 7d d6 00          	cmpb   $0x0,-0x2a(%ebp)
     d01:	74 1c                	je     d1f <_cow_test_child+0x166>
     d03:	83 7e 5c 00          	cmpl   $0x0,0x5c(%esi)
     d07:	74 16                	je     d1f <_cow_test_child+0x166>
            close(dummy_pipe_fds[0]);
     d09:	8b 45 e0             	mov    -0x20(%ebp),%eax
     d0c:	89 04 24             	mov    %eax,(%esp)
     d0f:	e8 4e 23 00 00       	call   3062 <close>
            close(dummy_pipe_fds[1]);
     d14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     d17:	89 04 24             	mov    %eax,(%esp)
     d1a:	e8 43 23 00 00       	call   3062 <close>
        _pipe_sync_child(pipes);
     d1f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
     d22:	e8 d5 f4 ff ff       	call   1fc <_pipe_sync_child>
        for (int j = info->starts[region]; j < info->ends[region]; j += 1) {
     d27:	8b 45 cc             	mov    -0x34(%ebp),%eax
     d2a:	8b 5c 86 54          	mov    0x54(%esi,%eax,4),%ebx
     d2e:	89 c7                	mov    %eax,%edi
     d30:	eb 43                	jmp    d75 <_cow_test_child+0x1bc>
            char expect = _heap_test_value(j, do_write ? child_index : -1);
     d32:	80 7d d6 00          	cmpb   $0x0,-0x2a(%ebp)
     d36:	75 07                	jne    d3f <_cow_test_child+0x186>
     d38:	ba ff ff ff ff       	mov    $0xffffffff,%edx
     d3d:	eb 03                	jmp    d42 <_cow_test_child+0x189>
     d3f:	8b 55 c8             	mov    -0x38(%ebp),%edx
     d42:	89 d8                	mov    %ebx,%eax
     d44:	e8 f1 f2 ff ff       	call   3a <_heap_test_value>
            if (heap_base[j] != expect) {
     d49:	8b 4d d0             	mov    -0x30(%ebp),%ecx
     d4c:	38 04 19             	cmp    %al,(%ecx,%ebx,1)
     d4f:	74 21                	je     d72 <_cow_test_child+0x1b9>
                printf(2, "ERROR: wrong value read from child %d at offset 0x%x\n",
     d51:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
     d55:	8b 45 c8             	mov    -0x38(%ebp),%eax
     d58:	89 44 24 08          	mov    %eax,0x8(%esp)
     d5c:	c7 44 24 04 04 3f 00 	movl   $0x3f04,0x4(%esp)
     d63:	00 
     d64:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     d6b:	e8 3c 24 00 00       	call   31ac <printf>
                return TR_FAIL_READBACK;
     d70:	eb 0f                	jmp    d81 <_cow_test_child+0x1c8>
        for (int j = info->starts[region]; j < info->ends[region]; j += 1) {
     d72:	83 c3 01             	add    $0x1,%ebx
     d75:	39 5c be 58          	cmp    %ebx,0x58(%esi,%edi,4)
     d79:	7f b7                	jg     d32 <_cow_test_child+0x179>
    for (int region = 0; region < NUM_COW_REGIONS; region += 1) {
     d7b:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
     d7f:	eb 07                	jmp    d88 <_cow_test_child+0x1cf>
                return TR_FAIL_READBACK;
     d81:	b8 06 00 00 00       	mov    $0x6,%eax
     d86:	eb 17                	jmp    d9f <_cow_test_child+0x1e6>
    for (int region = 0; region < NUM_COW_REGIONS; region += 1) {
     d88:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
     d8c:	0f 8e 5c fe ff ff    	jle    bee <_cow_test_child+0x35>
    _pipe_sync_child(pipes);
     d92:	8b 45 c4             	mov    -0x3c(%ebp),%eax
     d95:	e8 62 f4 ff ff       	call   1fc <_pipe_sync_child>
    return TR_SUCCESS;
     d9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
     d9f:	83 c4 4c             	add    $0x4c,%esp
     da2:	5b                   	pop    %ebx
     da3:	5e                   	pop    %esi
     da4:	5f                   	pop    %edi
     da5:	5d                   	pop    %ebp
     da6:	c3                   	ret    

00000da7 <getopt_usage>:
void getopt_usage(char *argv0, struct option *options) {
     da7:	55                   	push   %ebp
     da8:	89 e5                	mov    %esp,%ebp
     daa:	56                   	push   %esi
     dab:	53                   	push   %ebx
     dac:	83 ec 10             	sub    $0x10,%esp
     daf:	89 c6                	mov    %eax,%esi
     db1:	89 d3                	mov    %edx,%ebx
   if (0 == strcmp(argv0, "AS-INIT")) {
     db3:	c7 44 24 04 6b 33 00 	movl   $0x336b,0x4(%esp)
     dba:	00 
     dbb:	89 04 24             	mov    %eax,(%esp)
     dbe:	e8 f4 20 00 00       	call   2eb7 <strcmp>
     dc3:	85 c0                	test   %eax,%eax
     dc5:	75 19                	jne    de0 <getopt_usage+0x39>
       printf(2, "Options:\n");
     dc7:	c7 44 24 04 73 33 00 	movl   $0x3373,0x4(%esp)
     dce:	00 
     dcf:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     dd6:	e8 d1 23 00 00       	call   31ac <printf>
     ddb:	e9 89 00 00 00       	jmp    e69 <getopt_usage+0xc2>
       printf(2, "Usage: %s ... \n", argv0);
     de0:	89 74 24 08          	mov    %esi,0x8(%esp)
     de4:	c7 44 24 04 7d 33 00 	movl   $0x337d,0x4(%esp)
     deb:	00 
     dec:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     df3:	e8 b4 23 00 00       	call   31ac <printf>
   for (struct option *option = options; option->name; option += 1) {
     df8:	eb 6f                	jmp    e69 <getopt_usage+0xc2>
       printf(2, "  -%s", option->name);
     dfa:	89 44 24 08          	mov    %eax,0x8(%esp)
     dfe:	c7 44 24 04 8d 33 00 	movl   $0x338d,0x4(%esp)
     e05:	00 
     e06:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     e0d:	e8 9a 23 00 00       	call   31ac <printf>
       if (option->boolean) {
     e12:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
     e16:	74 16                	je     e2e <getopt_usage+0x87>
           printf(2, "\n");
     e18:	c7 44 24 04 8b 33 00 	movl   $0x338b,0x4(%esp)
     e1f:	00 
     e20:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     e27:	e8 80 23 00 00       	call   31ac <printf>
     e2c:	eb 1d                	jmp    e4b <getopt_usage+0xa4>
           printf(2, "=NUMBER (default: 0x%x)\n", *option->value);
     e2e:	8b 43 08             	mov    0x8(%ebx),%eax
     e31:	8b 00                	mov    (%eax),%eax
     e33:	89 44 24 08          	mov    %eax,0x8(%esp)
     e37:	c7 44 24 04 93 33 00 	movl   $0x3393,0x4(%esp)
     e3e:	00 
     e3f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     e46:	e8 61 23 00 00       	call   31ac <printf>
       printf(2, "    %s\n", option->description);
     e4b:	8b 43 04             	mov    0x4(%ebx),%eax
     e4e:	89 44 24 08          	mov    %eax,0x8(%esp)
     e52:	c7 44 24 04 ac 33 00 	movl   $0x33ac,0x4(%esp)
     e59:	00 
     e5a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     e61:	e8 46 23 00 00       	call   31ac <printf>
   for (struct option *option = options; option->name; option += 1) {
     e66:	83 c3 10             	add    $0x10,%ebx
     e69:	8b 03                	mov    (%ebx),%eax
     e6b:	85 c0                	test   %eax,%eax
     e6d:	75 8b                	jne    dfa <getopt_usage+0x53>
   printf(2, "NUMBER can be a base-10 number or a base-16 number prefixed with '0x'\n");
     e6f:	c7 44 24 04 84 3f 00 	movl   $0x3f84,0x4(%esp)
     e76:	00 
     e77:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     e7e:	e8 29 23 00 00       	call   31ac <printf>
}
     e83:	83 c4 10             	add    $0x10,%esp
     e86:	5b                   	pop    %ebx
     e87:	5e                   	pop    %esi
     e88:	5d                   	pop    %ebp
     e89:	c3                   	ret    

00000e8a <_test_exec>:
MAYBE_UNUSED static TestResult _test_exec() {
     e8a:	55                   	push   %ebp
     e8b:	89 e5                	mov    %esp,%ebp
     e8d:	57                   	push   %edi
     e8e:	56                   	push   %esi
     e8f:	53                   	push   %ebx
     e90:	83 ec 3c             	sub    $0x3c,%esp
    printf(1, 
     e93:	c7 44 24 04 cc 3f 00 	movl   $0x3fcc,0x4(%esp)
     e9a:	00 
     e9b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ea2:	e8 05 23 00 00       	call   31ac <printf>
    _init_pipes(&pipes);
     ea7:	8d 45 d8             	lea    -0x28(%ebp),%eax
     eaa:	e8 86 f8 ff ff       	call   735 <_init_pipes>
    int pid = fork();
     eaf:	e8 7e 21 00 00       	call   3032 <fork>
    if (pid == -1) return TR_FAIL_FORK;
     eb4:	83 f8 ff             	cmp    $0xffffffff,%eax
     eb7:	0f 84 60 01 00 00    	je     101d <_test_exec+0x193>
    if (pid == 0) {
     ebd:	85 c0                	test   %eax,%eax
     ebf:	90                   	nop
     ec0:	0f 85 11 01 00 00    	jne    fd7 <_test_exec+0x14d>
        int to_child0 = dup(pipes.to_child[0]);
     ec6:	8b 45 d8             	mov    -0x28(%ebp),%eax
     ec9:	89 04 24             	mov    %eax,(%esp)
     ecc:	e8 e1 21 00 00       	call   30b2 <dup>
     ed1:	89 c7                	mov    %eax,%edi
        int to_child1 = dup(pipes.to_child[1]);
     ed3:	8b 45 dc             	mov    -0x24(%ebp),%eax
     ed6:	89 04 24             	mov    %eax,(%esp)
     ed9:	e8 d4 21 00 00       	call   30b2 <dup>
     ede:	89 c6                	mov    %eax,%esi
        int from_child0 = dup(pipes.from_child[0]);
     ee0:	8b 45 e0             	mov    -0x20(%ebp),%eax
     ee3:	89 04 24             	mov    %eax,(%esp)
     ee6:	e8 c7 21 00 00       	call   30b2 <dup>
     eeb:	89 c3                	mov    %eax,%ebx
        int from_child1 = dup(pipes.from_child[1]);
     eed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     ef0:	89 04 24             	mov    %eax,(%esp)
     ef3:	e8 ba 21 00 00       	call   30b2 <dup>
     ef8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        close(3);
     efb:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
     f02:	e8 5b 21 00 00       	call   3062 <close>
        if (3 != dup(to_child0)) CRASH("could not assign fd 3");
     f07:	89 3c 24             	mov    %edi,(%esp)
     f0a:	e8 a3 21 00 00       	call   30b2 <dup>
     f0f:	83 f8 03             	cmp    $0x3,%eax
     f12:	74 0a                	je     f1e <_test_exec+0x94>
     f14:	b8 b4 33 00 00       	mov    $0x33b4,%eax
     f19:	e8 ae f1 ff ff       	call   cc <CRASH>
        close(4);
     f1e:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
     f25:	e8 38 21 00 00       	call   3062 <close>
        if (4 != dup(to_child1)) CRASH("could not assign fd 4");
     f2a:	89 34 24             	mov    %esi,(%esp)
     f2d:	e8 80 21 00 00       	call   30b2 <dup>
     f32:	83 f8 04             	cmp    $0x4,%eax
     f35:	74 0a                	je     f41 <_test_exec+0xb7>
     f37:	b8 ca 33 00 00       	mov    $0x33ca,%eax
     f3c:	e8 8b f1 ff ff       	call   cc <CRASH>
        close(5);
     f41:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
     f48:	e8 15 21 00 00       	call   3062 <close>
        if (5 != dup(from_child0)) CRASH("could not assign fd 5");
     f4d:	89 1c 24             	mov    %ebx,(%esp)
     f50:	e8 5d 21 00 00       	call   30b2 <dup>
     f55:	83 f8 05             	cmp    $0x5,%eax
     f58:	74 0a                	je     f64 <_test_exec+0xda>
     f5a:	b8 e0 33 00 00       	mov    $0x33e0,%eax
     f5f:	e8 68 f1 ff ff       	call   cc <CRASH>
        close(6);
     f64:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
     f6b:	e8 f2 20 00 00       	call   3062 <close>
        if (6 != dup(from_child1)) CRASH("could not assign fd 6");
     f70:	8b 45 c4             	mov    -0x3c(%ebp),%eax
     f73:	89 04 24             	mov    %eax,(%esp)
     f76:	e8 37 21 00 00       	call   30b2 <dup>
     f7b:	83 f8 06             	cmp    $0x6,%eax
     f7e:	74 0a                	je     f8a <_test_exec+0x100>
     f80:	b8 f6 33 00 00       	mov    $0x33f6,%eax
     f85:	e8 42 f1 ff ff       	call   cc <CRASH>
        close(to_child0);
     f8a:	89 3c 24             	mov    %edi,(%esp)
     f8d:	e8 d0 20 00 00       	call   3062 <close>
        close(to_child1);
     f92:	89 34 24             	mov    %esi,(%esp)
     f95:	e8 c8 20 00 00       	call   3062 <close>
        close(from_child0);
     f9a:	89 1c 24             	mov    %ebx,(%esp)
     f9d:	e8 c0 20 00 00       	call   3062 <close>
        close(from_child1);
     fa2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
     fa5:	89 04 24             	mov    %eax,(%esp)
     fa8:	e8 b5 20 00 00       	call   3062 <close>
        const char *args[] = {
     fad:	a1 60 74 00 00       	mov    0x7460,%eax
     fb2:	89 45 cc             	mov    %eax,-0x34(%ebp)
     fb5:	c7 45 d0 0c 34 00 00 	movl   $0x340c,-0x30(%ebp)
     fbc:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
        exec((char*) real_argv0, (char**) args);
     fc3:	8d 55 cc             	lea    -0x34(%ebp),%edx
     fc6:	89 54 24 04          	mov    %edx,0x4(%esp)
     fca:	89 04 24             	mov    %eax,(%esp)
     fcd:	e8 a0 20 00 00       	call   3072 <exec>
        exit();
     fd2:	e8 63 20 00 00       	call   303a <exit>
        int result = _test_exec_parent(&pipes, pid);
     fd7:	89 c2                	mov    %eax,%edx
     fd9:	8d 45 d8             	lea    -0x28(%ebp),%eax
     fdc:	e8 c2 fa ff ff       	call   aa3 <_test_exec_parent>
     fe1:	89 c3                	mov    %eax,%ebx
        _pipe_sync_cleanup(&pipes);
     fe3:	8d 45 d8             	lea    -0x28(%ebp),%eax
     fe6:	e8 a8 f7 ff ff       	call   793 <_pipe_sync_cleanup>
        if (result == TR_SUCCESS) {
     feb:	85 db                	test   %ebx,%ebx
     fed:	75 16                	jne    1005 <_test_exec+0x17b>
            printf(1, "Test successful.\n");
     fef:	c7 44 24 04 4b 33 00 	movl   $0x334b,0x4(%esp)
     ff6:	00 
     ff7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ffe:	e8 a9 21 00 00       	call   31ac <printf>
    1003:	eb 14                	jmp    1019 <_test_exec+0x18f>
            printf(1, "Test failed.\n");
    1005:	c7 44 24 04 5d 33 00 	movl   $0x335d,0x4(%esp)
    100c:	00 
    100d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1014:	e8 93 21 00 00       	call   31ac <printf>
        return result;
    1019:	89 d8                	mov    %ebx,%eax
    101b:	eb 05                	jmp    1022 <_test_exec+0x198>
    if (pid == -1) return TR_FAIL_FORK;
    101d:	b8 07 00 00 00       	mov    $0x7,%eax
}
    1022:	83 c4 3c             	add    $0x3c,%esp
    1025:	5b                   	pop    %ebx
    1026:	5e                   	pop    %esi
    1027:	5f                   	pop    %edi
    1028:	5d                   	pop    %ebp
    1029:	c3                   	ret    

0000102a <hextoi>:
uint hextoi(const char *value) {
    102a:	55                   	push   %ebp
    102b:	89 e5                	mov    %esp,%ebp
    102d:	53                   	push   %ebx
    102e:	83 ec 14             	sub    $0x14,%esp
    p = value;
    1031:	8b 55 08             	mov    0x8(%ebp),%edx
    while (p[0] == ' ') {
    1034:	eb 03                	jmp    1039 <hextoi+0xf>
        p += 1;
    1036:	83 c2 01             	add    $0x1,%edx
    while (p[0] == ' ') {
    1039:	0f b6 02             	movzbl (%edx),%eax
    103c:	3c 20                	cmp    $0x20,%al
    103e:	74 f6                	je     1036 <hextoi+0xc>
    if (p[0] == '0' && (p[1] == 'x' || p[1] == 'X')) {
    1040:	3c 30                	cmp    $0x30,%al
    1042:	75 15                	jne    1059 <hextoi+0x2f>
    1044:	0f b6 42 01          	movzbl 0x1(%edx),%eax
    1048:	3c 78                	cmp    $0x78,%al
    104a:	0f 94 c1             	sete   %cl
    104d:	3c 58                	cmp    $0x58,%al
    104f:	0f 94 c0             	sete   %al
    1052:	08 c1                	or     %al,%cl
    1054:	74 03                	je     1059 <hextoi+0x2f>
        p += 2;
    1056:	83 c2 02             	add    $0x2,%edx
    p = value;
    1059:	b8 00 00 00 00       	mov    $0x0,%eax
    105e:	eb 5b                	jmp    10bb <hextoi+0x91>
        result = result << 4;
    1060:	c1 e0 04             	shl    $0x4,%eax
        if (*p >= '0' && *p <= '9') {
    1063:	8d 59 d0             	lea    -0x30(%ecx),%ebx
    1066:	80 fb 09             	cmp    $0x9,%bl
    1069:	77 09                	ja     1074 <hextoi+0x4a>
            result += *p - '0';
    106b:	0f be c9             	movsbl %cl,%ecx
    106e:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
    1072:	eb 44                	jmp    10b8 <hextoi+0x8e>
        } else if (*p >= 'a' && *p <= 'f') {
    1074:	8d 59 9f             	lea    -0x61(%ecx),%ebx
    1077:	80 fb 05             	cmp    $0x5,%bl
    107a:	77 09                	ja     1085 <hextoi+0x5b>
            result += 10 + *p - 'a';
    107c:	0f be c9             	movsbl %cl,%ecx
    107f:	8d 44 08 a9          	lea    -0x57(%eax,%ecx,1),%eax
    1083:	eb 33                	jmp    10b8 <hextoi+0x8e>
        } else if (*p >= 'A' && *p <= 'F') {
    1085:	8d 59 bf             	lea    -0x41(%ecx),%ebx
    1088:	80 fb 05             	cmp    $0x5,%bl
    108b:	77 09                	ja     1096 <hextoi+0x6c>
            result += 10 + *p - 'A';
    108d:	0f be c9             	movsbl %cl,%ecx
    1090:	8d 44 08 c9          	lea    -0x37(%eax,%ecx,1),%eax
    1094:	eb 22                	jmp    10b8 <hextoi+0x8e>
            printf(2, "malformed hexadecimal number '%s'\n", value);
    1096:	8b 45 08             	mov    0x8(%ebp),%eax
    1099:	89 44 24 08          	mov    %eax,0x8(%esp)
    109d:	c7 44 24 04 ac 40 00 	movl   $0x40ac,0x4(%esp)
    10a4:	00 
    10a5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    10ac:	e8 fb 20 00 00       	call   31ac <printf>
            return 0;
    10b1:	b8 00 00 00 00       	mov    $0x0,%eax
    10b6:	eb 0a                	jmp    10c2 <hextoi+0x98>
        p += 1;
    10b8:	83 c2 01             	add    $0x1,%edx
    while (*p) {
    10bb:	0f b6 0a             	movzbl (%edx),%ecx
    10be:	84 c9                	test   %cl,%cl
    10c0:	75 9e                	jne    1060 <hextoi+0x36>
}
    10c2:	83 c4 14             	add    $0x14,%esp
    10c5:	5b                   	pop    %ebx
    10c6:	5d                   	pop    %ebp
    10c7:	c3                   	ret    

000010c8 <decorhextoi>:
uint decorhextoi(const char *value) {
    10c8:	55                   	push   %ebp
    10c9:	89 e5                	mov    %esp,%ebp
    10cb:	83 ec 18             	sub    $0x18,%esp
    10ce:	8b 45 08             	mov    0x8(%ebp),%eax
    if (value[0] == '0' && (value[1] == 'x' || value[1] == 'X')) {
    10d1:	80 38 30             	cmpb   $0x30,(%eax)
    10d4:	75 1e                	jne    10f4 <decorhextoi+0x2c>
    10d6:	0f b6 50 01          	movzbl 0x1(%eax),%edx
    10da:	80 fa 78             	cmp    $0x78,%dl
    10dd:	0f 94 c1             	sete   %cl
    10e0:	80 fa 58             	cmp    $0x58,%dl
    10e3:	0f 94 c2             	sete   %dl
    10e6:	08 d1                	or     %dl,%cl
    10e8:	74 0a                	je     10f4 <decorhextoi+0x2c>
        return hextoi(value);
    10ea:	89 04 24             	mov    %eax,(%esp)
    10ed:	e8 38 ff ff ff       	call   102a <hextoi>
    10f2:	eb 08                	jmp    10fc <decorhextoi+0x34>
        return atoi(value);
    10f4:	89 04 24             	mov    %eax,(%esp)
    10f7:	e8 e1 1e 00 00       	call   2fdd <atoi>
}
    10fc:	c9                   	leave  
    10fd:	8d 76 00             	lea    0x0(%esi),%esi
    1100:	c3                   	ret    

00001101 <dump_for>:
void dump_for(const char *reason, int pid) {
    1101:	55                   	push   %ebp
    1102:	89 e5                	mov    %esp,%ebp
    1104:	53                   	push   %ebx
    1105:	83 ec 14             	sub    $0x14,%esp
    1108:	8b 5d 08             	mov    0x8(%ebp),%ebx
    printf(1, STARTDUMP "%s\n", reason);
    110b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
    110f:	c7 44 24 04 d0 40 00 	movl   $0x40d0,0x4(%esp)
    1116:	00 
    1117:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    111e:	e8 89 20 00 00       	call   31ac <printf>
    dumppagetable(pid);
    1123:	8b 45 0c             	mov    0xc(%ebp),%eax
    1126:	89 04 24             	mov    %eax,(%esp)
    1129:	e8 c4 1f 00 00       	call   30f2 <dumppagetable>
    printf(1, ENDDUMP "%s\n", reason);
    112e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
    1132:	c7 44 24 04 fc 40 00 	movl   $0x40fc,0x4(%esp)
    1139:	00 
    113a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1141:	e8 66 20 00 00       	call   31ac <printf>
}
    1146:	83 c4 14             	add    $0x14,%esp
    1149:	5b                   	pop    %ebx
    114a:	5d                   	pop    %ebp
    114b:	c3                   	ret    

0000114c <strprefix>:
int strprefix(const char *prefix, const char *target) {
    114c:	55                   	push   %ebp
    114d:	89 e5                	mov    %esp,%ebp
    114f:	53                   	push   %ebx
    1150:	8b 5d 08             	mov    0x8(%ebp),%ebx
    1153:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    while (*prefix == *target && *prefix != '\0' && *target != '\0') {
    1156:	eb 06                	jmp    115e <strprefix+0x12>
        prefix += 1;
    1158:	83 c3 01             	add    $0x1,%ebx
        target += 1;
    115b:	83 c1 01             	add    $0x1,%ecx
    while (*prefix == *target && *prefix != '\0' && *target != '\0') {
    115e:	0f b6 03             	movzbl (%ebx),%eax
    1161:	0f b6 11             	movzbl (%ecx),%edx
    1164:	38 d0                	cmp    %dl,%al
    1166:	75 08                	jne    1170 <strprefix+0x24>
    1168:	84 c0                	test   %al,%al
    116a:	74 04                	je     1170 <strprefix+0x24>
    116c:	84 d2                	test   %dl,%dl
    116e:	75 e8                	jne    1158 <strprefix+0xc>
    if (*prefix == '\0')
    1170:	84 c0                	test   %al,%al
    1172:	75 07                	jne    117b <strprefix+0x2f>
        return 1;
    1174:	b8 01 00 00 00       	mov    $0x1,%eax
    1179:	eb 05                	jmp    1180 <strprefix+0x34>
        return 0;
    117b:	b8 00 00 00 00       	mov    $0x0,%eax
}
    1180:	5b                   	pop    %ebx
    1181:	5d                   	pop    %ebp
    1182:	c3                   	ret    

00001183 <max>:
int max(int a, int b) {
    1183:	55                   	push   %ebp
    1184:	89 e5                	mov    %esp,%ebp
    1186:	8b 55 08             	mov    0x8(%ebp),%edx
    1189:	8b 45 0c             	mov    0xc(%ebp),%eax
    if (a > b) {
    118c:	39 c2                	cmp    %eax,%edx
    118e:	7e 02                	jle    1192 <max+0xf>
        return a;
    1190:	89 d0                	mov    %edx,%eax
}
    1192:	5d                   	pop    %ebp
    1193:	c3                   	ret    

00001194 <_test_allocation_child>:
MAYBE_UNUSED static TestResult _test_allocation_child(struct alloc_test_info *info) {
    1194:	55                   	push   %ebp
    1195:	89 e5                	mov    %esp,%ebp
    1197:	57                   	push   %edi
    1198:	56                   	push   %esi
    1199:	53                   	push   %ebx
    119a:	83 ec 3c             	sub    $0x3c,%esp
    119d:	89 c3                	mov    %eax,%ebx
    int result = TR_SUCCESS;
    119f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    _pipe_sync_child(&info->pipes);
    11a6:	e8 51 f0 ff ff       	call   1fc <_pipe_sync_child>
    int free_check = info->skip_free_check ? NO_FREE_CHECK : WITH_FREE_CHECK;
    11ab:	83 7b 30 00          	cmpl   $0x0,0x30(%ebx)
    11af:	0f 95 c0             	setne  %al
    11b2:	0f b6 c0             	movzbl %al,%eax
    11b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
    uint guard = _get_guard();
    11b8:	e8 43 ee ff ff       	call   0 <_get_guard>
    11bd:	89 c7                	mov    %eax,%edi
    if (!_sanity_check_range_self(0, guard, IS_ALLOCATED, NOT_GUARD, free_check, " (memory before guard page, before new allocation)")) {
    11bf:	c7 44 24 08 a4 3d 00 	movl   $0x3da4,0x8(%esp)
    11c6:	00 
    11c7:	8b 45 d0             	mov    -0x30(%ebp),%eax
    11ca:	89 44 24 04          	mov    %eax,0x4(%esp)
    11ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    11d5:	b9 01 00 00 00       	mov    $0x1,%ecx
    11da:	89 fa                	mov    %edi,%edx
    11dc:	b8 00 00 00 00       	mov    $0x0,%eax
    11e1:	e8 99 f4 ff ff       	call   67f <_sanity_check_range_self>
    11e6:	85 c0                	test   %eax,%eax
    11e8:	75 16                	jne    1200 <_test_allocation_child+0x6c>
        result = max(result, TR_FAIL_PTE);
    11ea:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    11f1:	00 
    11f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    11f5:	89 04 24             	mov    %eax,(%esp)
    11f8:	e8 86 ff ff ff       	call   1183 <max>
    11fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (!_sanity_check_range_self(guard, guard + PGSIZE, IS_ALLOCATED, IS_GUARD, free_check, " (guard page)")) {
    1200:	8d b7 00 10 00 00    	lea    0x1000(%edi),%esi
    1206:	c7 44 24 08 0a 33 00 	movl   $0x330a,0x8(%esp)
    120d:	00 
    120e:	8b 45 d0             	mov    -0x30(%ebp),%eax
    1211:	89 44 24 04          	mov    %eax,0x4(%esp)
    1215:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    121c:	b9 01 00 00 00       	mov    $0x1,%ecx
    1221:	89 f2                	mov    %esi,%edx
    1223:	89 f8                	mov    %edi,%eax
    1225:	e8 55 f4 ff ff       	call   67f <_sanity_check_range_self>
    122a:	85 c0                	test   %eax,%eax
    122c:	75 16                	jne    1244 <_test_allocation_child+0xb0>
        result = max(result, TR_FAIL_PTE);
    122e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    1235:	00 
    1236:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1239:	89 04 24             	mov    %eax,(%esp)
    123c:	e8 42 ff ff ff       	call   1183 <max>
    1241:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (!_sanity_check_range_self(guard + PGSIZE, guard + PGSIZE * 2, IS_ALLOCATED, NOT_GUARD, free_check, " (stack page)")) {
    1244:	8d 97 00 20 00 00    	lea    0x2000(%edi),%edx
    124a:	c7 44 24 08 1b 34 00 	movl   $0x341b,0x8(%esp)
    1251:	00 
    1252:	8b 45 d0             	mov    -0x30(%ebp),%eax
    1255:	89 44 24 04          	mov    %eax,0x4(%esp)
    1259:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    1260:	b9 01 00 00 00       	mov    $0x1,%ecx
    1265:	89 f0                	mov    %esi,%eax
    1267:	e8 13 f4 ff ff       	call   67f <_sanity_check_range_self>
    126c:	85 c0                	test   %eax,%eax
    126e:	75 16                	jne    1286 <_test_allocation_child+0xf2>
        result = max(result, TR_FAIL_PTE);
    1270:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    1277:	00 
    1278:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    127b:	89 04 24             	mov    %eax,(%esp)
    127e:	e8 00 ff ff ff       	call   1183 <max>
    1283:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    char *old_brk = sbrk(0);
    1286:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    128d:	e8 30 1e 00 00       	call   30c2 <sbrk>
    1292:	89 c7                	mov    %eax,%edi
    if (!info->skip_pte_check) {
    1294:	83 7b 34 00          	cmpl   $0x0,0x34(%ebx)
    1298:	75 3e                	jne    12d8 <_test_allocation_child+0x144>
        if (!_sanity_check_range_self(guard + PGSIZE, (uint) old_brk, MAYBE_ALLOCATED, NOT_GUARD, free_check, " (heap before new allocation)")) {
    129a:	c7 44 24 08 29 34 00 	movl   $0x3429,0x8(%esp)
    12a1:	00 
    12a2:	8b 45 d0             	mov    -0x30(%ebp),%eax
    12a5:	89 44 24 04          	mov    %eax,0x4(%esp)
    12a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    12b0:	b9 00 00 00 00       	mov    $0x0,%ecx
    12b5:	89 fa                	mov    %edi,%edx
    12b7:	89 f0                	mov    %esi,%eax
    12b9:	e8 c1 f3 ff ff       	call   67f <_sanity_check_range_self>
    12be:	85 c0                	test   %eax,%eax
    12c0:	75 16                	jne    12d8 <_test_allocation_child+0x144>
            result = max(result, TR_FAIL_PTE);
    12c2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    12c9:	00 
    12ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    12cd:	89 04 24             	mov    %eax,(%esp)
    12d0:	e8 ae fe ff ff       	call   1183 <max>
    12d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    _pipe_sync_child(&info->pipes);
    12d8:	89 d8                	mov    %ebx,%eax
    12da:	e8 1d ef ff ff       	call   1fc <_pipe_sync_child>
    if (info->dump)
    12df:	83 7b 2c 00          	cmpl   $0x0,0x2c(%ebx)
    12e3:	74 15                	je     12fa <_test_allocation_child+0x166>
        dump_for("allocation-pre-allocate", getpid());
    12e5:	e8 d0 1d 00 00       	call   30ba <getpid>
    12ea:	89 44 24 04          	mov    %eax,0x4(%esp)
    12ee:	c7 04 24 47 34 00 00 	movl   $0x3447,(%esp)
    12f5:	e8 07 fe ff ff       	call   1101 <dump_for>
    sbrk(info->alloc_size);
    12fa:	8b 43 10             	mov    0x10(%ebx),%eax
    12fd:	89 04 24             	mov    %eax,(%esp)
    1300:	e8 bd 1d 00 00       	call   30c2 <sbrk>
    char *new_brk = sbrk(0);
    1305:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    130c:	e8 b1 1d 00 00       	call   30c2 <sbrk>
    1311:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if (new_brk - old_brk < info->alloc_size) {
    1314:	89 c2                	mov    %eax,%edx
    1316:	29 fa                	sub    %edi,%edx
    1318:	8b 43 10             	mov    0x10(%ebx),%eax
    131b:	39 c2                	cmp    %eax,%edx
    131d:	7d 26                	jge    1345 <_test_allocation_child+0x1b1>
        printf(2, "ERROR: sbrk() allocated too little (requested 0x%x bytes; break changed by 0x%x bytes)\n", info->alloc_size, new_brk - old_brk);
    131f:	89 54 24 0c          	mov    %edx,0xc(%esp)
    1323:	89 44 24 08          	mov    %eax,0x8(%esp)
    1327:	c7 44 24 04 28 41 00 	movl   $0x4128,0x4(%esp)
    132e:	00 
    132f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1336:	e8 71 1e 00 00       	call   31ac <printf>
        return TR_FAIL_SBRK; // FIXME: should this not stop test?
    133b:	b8 03 00 00 00       	mov    $0x3,%eax
    1340:	e9 62 04 00 00       	jmp    17a7 <_test_allocation_child+0x613>
    if (!info->skip_pte_check) {
    1345:	83 7b 34 00          	cmpl   $0x0,0x34(%ebx)
    1349:	75 48                	jne    1393 <_test_allocation_child+0x1ff>
        if (! _sanity_check_range_self(PGROUNDUP((uint) old_brk), (uint) new_brk, NOT_ALLOCATED, NOT_GUARD, free_check,
    134b:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
    1351:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    1356:	c7 44 24 08 80 41 00 	movl   $0x4180,0x8(%esp)
    135d:	00 
    135e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
    1361:	89 4c 24 04          	mov    %ecx,0x4(%esp)
    1365:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    136c:	b9 02 00 00 00       	mov    $0x2,%ecx
    1371:	8b 55 cc             	mov    -0x34(%ebp),%edx
    1374:	e8 06 f3 ff ff       	call   67f <_sanity_check_range_self>
    1379:	85 c0                	test   %eax,%eax
    137b:	75 16                	jne    1393 <_test_allocation_child+0x1ff>
            result = max(result, TR_FAIL_NONDEMAND);
    137d:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
    1384:	00 
    1385:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1388:	89 04 24             	mov    %eax,(%esp)
    138b:	e8 f3 fd ff ff       	call   1183 <max>
    1390:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    _pipe_sync_child(&info->pipes);
    1393:	89 d8                	mov    %ebx,%eax
    1395:	e8 62 ee ff ff       	call   1fc <_pipe_sync_child>
    if (info->dump)
    139a:	83 7b 2c 00          	cmpl   $0x0,0x2c(%ebx)
    139e:	74 15                	je     13b5 <_test_allocation_child+0x221>
        dump_for("allocation-pre-access", getpid());
    13a0:	e8 15 1d 00 00       	call   30ba <getpid>
    13a5:	89 44 24 04          	mov    %eax,0x4(%esp)
    13a9:	c7 04 24 5f 34 00 00 	movl   $0x345f,(%esp)
    13b0:	e8 4c fd ff ff       	call   1101 <dump_for>
    int read_start = info->read_start; int read_end = info->read_end;
    13b5:	8b 43 1c             	mov    0x1c(%ebx),%eax
    13b8:	89 45 c8             	mov    %eax,-0x38(%ebp)
    13bb:	8b 4b 20             	mov    0x20(%ebx),%ecx
    13be:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
    for (int i = read_start; i < read_end; ++i) {
    13c1:	89 c6                	mov    %eax,%esi
    13c3:	eb 28                	jmp    13ed <_test_allocation_child+0x259>
       if (old_brk[i] != 0) {
    13c5:	80 3c 37 00          	cmpb   $0x0,(%edi,%esi,1)
    13c9:	74 1f                	je     13ea <_test_allocation_child+0x256>
           printf(2, "ERROR: non-zero value read 0x%x bytes into 0x%x byte allocation\n",
    13cb:	8b 43 10             	mov    0x10(%ebx),%eax
    13ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
    13d2:	89 74 24 08          	mov    %esi,0x8(%esp)
    13d6:	c7 44 24 04 a8 41 00 	movl   $0x41a8,0x4(%esp)
    13dd:	00 
    13de:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    13e5:	e8 c2 1d 00 00       	call   31ac <printf>
    for (int i = read_start; i < read_end; ++i) {
    13ea:	83 c6 01             	add    $0x1,%esi
    13ed:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
    13f0:	7c d3                	jl     13c5 <_test_allocation_child+0x231>
    if (!info->skip_pte_check) {
    13f2:	83 7b 34 00          	cmpl   $0x0,0x34(%ebx)
    13f6:	0f 85 06 01 00 00    	jne    1502 <_test_allocation_child+0x36e>
        if (read_end > read_start) {
    13fc:	8b 45 c8             	mov    -0x38(%ebp),%eax
    13ff:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
    1402:	7e 54                	jle    1458 <_test_allocation_child+0x2c4>
                PGROUNDUP((uint) old_brk + read_end - 1),
    1404:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    1407:	8d 94 07 fe 0f 00 00 	lea    0xffe(%edi,%eax,1),%edx
                PGROUNDDOWN((uint) old_brk + read_start), 
    140e:	8b 45 c8             	mov    -0x38(%ebp),%eax
    1411:	01 f8                	add    %edi,%eax
            if (! _sanity_check_range_self(
    1413:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
    1419:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    141e:	c7 44 24 08 ec 41 00 	movl   $0x41ec,0x8(%esp)
    1425:	00 
    1426:	8b 4d d0             	mov    -0x30(%ebp),%ecx
    1429:	89 4c 24 04          	mov    %ecx,0x4(%esp)
    142d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    1434:	b9 01 00 00 00       	mov    $0x1,%ecx
    1439:	e8 41 f2 ff ff       	call   67f <_sanity_check_range_self>
    143e:	85 c0                	test   %eax,%eax
    1440:	75 16                	jne    1458 <_test_allocation_child+0x2c4>
                result = max(result, TR_FAIL_PTE);
    1442:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    1449:	00 
    144a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    144d:	89 04 24             	mov    %eax,(%esp)
    1450:	e8 2e fd ff ff       	call   1183 <max>
    1455:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            PGROUNDDOWN((uint) old_brk + read_start - 1), 
    1458:	8b 45 c8             	mov    -0x38(%ebp),%eax
    145b:	8d 54 07 ff          	lea    -0x1(%edi,%eax,1),%edx
            PGROUNDUP((uint) old_brk), 
    145f:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
        if (! _sanity_check_range_self(
    1465:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
    146b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    1470:	c7 44 24 08 18 42 00 	movl   $0x4218,0x8(%esp)
    1477:	00 
    1478:	8b 4d d0             	mov    -0x30(%ebp),%ecx
    147b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
    147f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    1486:	b9 02 00 00 00       	mov    $0x2,%ecx
    148b:	e8 ef f1 ff ff       	call   67f <_sanity_check_range_self>
    1490:	85 c0                	test   %eax,%eax
    1492:	75 16                	jne    14aa <_test_allocation_child+0x316>
            result = max(result, TR_FAIL_PTE);
    1494:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    149b:	00 
    149c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    149f:	89 04 24             	mov    %eax,(%esp)
    14a2:	e8 dc fc ff ff       	call   1183 <max>
    14a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            PGROUNDUP((uint) new_brk),
    14aa:	8b 55 cc             	mov    -0x34(%ebp),%edx
    14ad:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
            PGROUNDUP((uint) old_brk + read_end),
    14b3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    14b6:	8d 84 07 ff 0f 00 00 	lea    0xfff(%edi,%eax,1),%eax
        if (! _sanity_check_range_self(
    14bd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
    14c3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    14c8:	c7 44 24 08 44 42 00 	movl   $0x4244,0x8(%esp)
    14cf:	00 
    14d0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
    14d3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
    14d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    14de:	b9 02 00 00 00       	mov    $0x2,%ecx
    14e3:	e8 97 f1 ff ff       	call   67f <_sanity_check_range_self>
    14e8:	85 c0                	test   %eax,%eax
    14ea:	75 16                	jne    1502 <_test_allocation_child+0x36e>
            result = max(result, TR_FAIL_PTE);
    14ec:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    14f3:	00 
    14f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    14f7:	89 04 24             	mov    %eax,(%esp)
    14fa:	e8 84 fc ff ff       	call   1183 <max>
    14ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    _pipe_sync_child(&info->pipes);
    1502:	89 d8                	mov    %ebx,%eax
    1504:	e8 f3 ec ff ff       	call   1fc <_pipe_sync_child>
    _pipe_sync_child(&info->pipes);
    1509:	89 d8                	mov    %ebx,%eax
    150b:	e8 ec ec ff ff       	call   1fc <_pipe_sync_child>
    if (info->use_sys_read) {
    1510:	83 7b 24 00          	cmpl   $0x0,0x24(%ebx)
    1514:	0f 84 a5 00 00 00    	je     15bf <_test_allocation_child+0x42b>
        if (pipe(fds) < 0)
    151a:	8d 45 dc             	lea    -0x24(%ebp),%eax
    151d:	89 04 24             	mov    %eax,(%esp)
    1520:	e8 25 1b 00 00       	call   304a <pipe>
    1525:	85 c0                	test   %eax,%eax
    1527:	79 0a                	jns    1533 <_test_allocation_child+0x39f>
            CRASH("error creating pipes");
    1529:	b8 18 33 00 00       	mov    $0x3318,%eax
    152e:	e8 99 eb ff ff       	call   cc <CRASH>
        for (int i = info->write_start; i < info->write_end; i += 1) {
    1533:	8b 73 14             	mov    0x14(%ebx),%esi
    1536:	eb 6a                	jmp    15a2 <_test_allocation_child+0x40e>
            char tmp = ('Q' + i) % 128;
    1538:	8d 56 51             	lea    0x51(%esi),%edx
    153b:	89 d0                	mov    %edx,%eax
    153d:	c1 f8 1f             	sar    $0x1f,%eax
    1540:	c1 e8 19             	shr    $0x19,%eax
    1543:	01 c2                	add    %eax,%edx
    1545:	83 e2 7f             	and    $0x7f,%edx
    1548:	29 c2                	sub    %eax,%edx
    154a:	88 55 db             	mov    %dl,-0x25(%ebp)
            if (write(fds[1], &tmp, 1) != 1)
    154d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1554:	00 
    1555:	8d 45 db             	lea    -0x25(%ebp),%eax
    1558:	89 44 24 04          	mov    %eax,0x4(%esp)
    155c:	8b 45 e0             	mov    -0x20(%ebp),%eax
    155f:	89 04 24             	mov    %eax,(%esp)
    1562:	e8 f3 1a 00 00       	call   305a <write>
    1567:	83 f8 01             	cmp    $0x1,%eax
    156a:	74 0a                	je     1576 <_test_allocation_child+0x3e2>
                CRASH("error writing to pipe");
    156c:	b8 75 34 00 00       	mov    $0x3475,%eax
    1571:	e8 56 eb ff ff       	call   cc <CRASH>
            if (read(fds[0], &old_brk[i], 1) != 1)
    1576:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    157d:	00 
    157e:	8d 04 37             	lea    (%edi,%esi,1),%eax
    1581:	89 44 24 04          	mov    %eax,0x4(%esp)
    1585:	8b 45 dc             	mov    -0x24(%ebp),%eax
    1588:	89 04 24             	mov    %eax,(%esp)
    158b:	e8 c2 1a 00 00       	call   3052 <read>
    1590:	83 f8 01             	cmp    $0x1,%eax
    1593:	74 0a                	je     159f <_test_allocation_child+0x40b>
                CRASH("error reading from pipe");
    1595:	b8 8b 34 00 00       	mov    $0x348b,%eax
    159a:	e8 2d eb ff ff       	call   cc <CRASH>
        for (int i = info->write_start; i < info->write_end; i += 1) {
    159f:	83 c6 01             	add    $0x1,%esi
    15a2:	39 73 18             	cmp    %esi,0x18(%ebx)
    15a5:	7f 91                	jg     1538 <_test_allocation_child+0x3a4>
        close(fds[0]);
    15a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
    15aa:	89 04 24             	mov    %eax,(%esp)
    15ad:	e8 b0 1a 00 00       	call   3062 <close>
        close(fds[1]);
    15b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
    15b5:	89 04 24             	mov    %eax,(%esp)
    15b8:	e8 a5 1a 00 00       	call   3062 <close>
    15bd:	eb 22                	jmp    15e1 <_test_allocation_child+0x44d>
        for (int i = info->write_start; i < info->write_end; i += 1) {
    15bf:	8b 43 14             	mov    0x14(%ebx),%eax
    15c2:	eb 18                	jmp    15dc <_test_allocation_child+0x448>
            old_brk[i] = ('Q' + i) % 128;
    15c4:	8d 48 51             	lea    0x51(%eax),%ecx
    15c7:	89 ca                	mov    %ecx,%edx
    15c9:	c1 fa 1f             	sar    $0x1f,%edx
    15cc:	c1 ea 19             	shr    $0x19,%edx
    15cf:	01 d1                	add    %edx,%ecx
    15d1:	83 e1 7f             	and    $0x7f,%ecx
    15d4:	29 d1                	sub    %edx,%ecx
    15d6:	88 0c 07             	mov    %cl,(%edi,%eax,1)
        for (int i = info->write_start; i < info->write_end; i += 1) {
    15d9:	83 c0 01             	add    $0x1,%eax
    15dc:	39 43 18             	cmp    %eax,0x18(%ebx)
    15df:	7f e3                	jg     15c4 <_test_allocation_child+0x430>
    for (int i = info->read_start; i < info->read_end; i += 1) {
    15e1:	8b 73 1c             	mov    0x1c(%ebx),%esi
    15e4:	e9 99 00 00 00       	jmp    1682 <_test_allocation_child+0x4ee>
        if (i >= info->write_start && i < info->write_end) {
    15e9:	39 73 14             	cmp    %esi,0x14(%ebx)
    15ec:	7f 56                	jg     1644 <_test_allocation_child+0x4b0>
    15ee:	39 73 18             	cmp    %esi,0x18(%ebx)
    15f1:	7e 51                	jle    1644 <_test_allocation_child+0x4b0>
            if (old_brk[i] != ('Q' + i) % 128) {
    15f3:	0f be 0c 37          	movsbl (%edi,%esi,1),%ecx
    15f7:	8d 56 51             	lea    0x51(%esi),%edx
    15fa:	89 d0                	mov    %edx,%eax
    15fc:	c1 f8 1f             	sar    $0x1f,%eax
    15ff:	c1 e8 19             	shr    $0x19,%eax
    1602:	01 c2                	add    %eax,%edx
    1604:	83 e2 7f             	and    $0x7f,%edx
    1607:	29 c2                	sub    %eax,%edx
    1609:	39 d1                	cmp    %edx,%ecx
    160b:	74 72                	je     167f <_test_allocation_child+0x4eb>
                printf(2, "ERROR: could not read back written value from "
    160d:	8b 43 10             	mov    0x10(%ebx),%eax
    1610:	89 44 24 0c          	mov    %eax,0xc(%esp)
    1614:	89 74 24 08          	mov    %esi,0x8(%esp)
    1618:	c7 44 24 04 6c 42 00 	movl   $0x426c,0x4(%esp)
    161f:	00 
    1620:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1627:	e8 80 1b 00 00       	call   31ac <printf>
                result = max(result, TR_FAIL_READBACK);
    162c:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
    1633:	00 
    1634:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1637:	89 04 24             	mov    %eax,(%esp)
    163a:	e8 44 fb ff ff       	call   1183 <max>
    163f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    1642:	eb 3b                	jmp    167f <_test_allocation_child+0x4eb>
            if (old_brk[i] != 0) {
    1644:	80 3c 37 00          	cmpb   $0x0,(%edi,%esi,1)
    1648:	74 35                	je     167f <_test_allocation_child+0x4eb>
                printf(2, "ERROR: non-zero value read 0x%x bytes into 0x%x byte allocation"
    164a:	8b 43 10             	mov    0x10(%ebx),%eax
    164d:	89 44 24 0c          	mov    %eax,0xc(%esp)
    1651:	89 74 24 08          	mov    %esi,0x8(%esp)
    1655:	c7 44 24 04 c0 42 00 	movl   $0x42c0,0x4(%esp)
    165c:	00 
    165d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1664:	e8 43 1b 00 00       	call   31ac <printf>
                result = max(result, TR_FAIL_READBACK);
    1669:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
    1670:	00 
    1671:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1674:	89 04 24             	mov    %eax,(%esp)
    1677:	e8 07 fb ff ff       	call   1183 <max>
    167c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for (int i = info->read_start; i < info->read_end; i += 1) {
    167f:	83 c6 01             	add    $0x1,%esi
    1682:	39 73 20             	cmp    %esi,0x20(%ebx)
    1685:	0f 8f 5e ff ff ff    	jg     15e9 <_test_allocation_child+0x455>
    for (int i = info->write_start; i < info->write_end; i += 1) {
    168b:	8b 73 14             	mov    0x14(%ebx),%esi
    168e:	eb 52                	jmp    16e2 <_test_allocation_child+0x54e>
        if (old_brk[i] != ('Q' + i) % 128) {
    1690:	0f be 0c 37          	movsbl (%edi,%esi,1),%ecx
    1694:	8d 56 51             	lea    0x51(%esi),%edx
    1697:	89 d0                	mov    %edx,%eax
    1699:	c1 f8 1f             	sar    $0x1f,%eax
    169c:	c1 e8 19             	shr    $0x19,%eax
    169f:	01 c2                	add    %eax,%edx
    16a1:	83 e2 7f             	and    $0x7f,%edx
    16a4:	29 c2                	sub    %eax,%edx
    16a6:	39 d1                	cmp    %edx,%ecx
    16a8:	74 35                	je     16df <_test_allocation_child+0x54b>
            printf(2, "ERROR: could not read back written value from "
    16aa:	8b 43 10             	mov    0x10(%ebx),%eax
    16ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
    16b1:	89 74 24 08          	mov    %esi,0x8(%esp)
    16b5:	c7 44 24 04 6c 42 00 	movl   $0x426c,0x4(%esp)
    16bc:	00 
    16bd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    16c4:	e8 e3 1a 00 00       	call   31ac <printf>
            result = max(result, TR_FAIL_READBACK);
    16c9:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
    16d0:	00 
    16d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    16d4:	89 04 24             	mov    %eax,(%esp)
    16d7:	e8 a7 fa ff ff       	call   1183 <max>
    16dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for (int i = info->write_start; i < info->write_end; i += 1) {
    16df:	83 c6 01             	add    $0x1,%esi
    16e2:	8b 43 18             	mov    0x18(%ebx),%eax
    16e5:	39 f0                	cmp    %esi,%eax
    16e7:	7f a7                	jg     1690 <_test_allocation_child+0x4fc>
    if (!info->skip_pte_check) {
    16e9:	83 7b 34 00          	cmpl   $0x0,0x34(%ebx)
    16ed:	75 5c                	jne    174b <_test_allocation_child+0x5b7>
        if (info->write_end > info->write_start) {
    16ef:	8b 53 14             	mov    0x14(%ebx),%edx
    16f2:	39 d0                	cmp    %edx,%eax
    16f4:	7e 55                	jle    174b <_test_allocation_child+0x5b7>
                PGROUNDUP((uint) old_brk + info->write_end),
    16f6:	8d 8c 07 ff 0f 00 00 	lea    0xfff(%edi,%eax,1),%ecx
                PGROUNDUP((uint) old_brk + info->write_start),
    16fd:	8d 84 17 ff 0f 00 00 	lea    0xfff(%edi,%edx,1),%eax
            if (! _sanity_check_range_self(
    1704:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
    170a:	89 ca                	mov    %ecx,%edx
    170c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    1711:	c7 44 24 08 40 43 00 	movl   $0x4340,0x8(%esp)
    1718:	00 
    1719:	8b 7d d0             	mov    -0x30(%ebp),%edi
    171c:	89 7c 24 04          	mov    %edi,0x4(%esp)
    1720:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    1727:	b9 01 00 00 00       	mov    $0x1,%ecx
    172c:	e8 4e ef ff ff       	call   67f <_sanity_check_range_self>
    1731:	85 c0                	test   %eax,%eax
    1733:	75 16                	jne    174b <_test_allocation_child+0x5b7>
                result = max(result, TR_FAIL_PTE);
    1735:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    173c:	00 
    173d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1740:	89 04 24             	mov    %eax,(%esp)
    1743:	e8 3b fa ff ff       	call   1183 <max>
    1748:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (info->dump)
    174b:	83 7b 2c 00          	cmpl   $0x0,0x2c(%ebx)
    174f:	74 15                	je     1766 <_test_allocation_child+0x5d2>
        dump_for("allocation-post-access", getpid());
    1751:	e8 64 19 00 00       	call   30ba <getpid>
    1756:	89 44 24 04          	mov    %eax,0x4(%esp)
    175a:	c7 04 24 a3 34 00 00 	movl   $0x34a3,(%esp)
    1761:	e8 9b f9 ff ff       	call   1101 <dump_for>
    _pipe_sync_child(&info->pipes);
    1766:	89 d8                	mov    %ebx,%eax
    1768:	e8 8f ea ff ff       	call   1fc <_pipe_sync_child>
    if (info->fork_after_alloc) {
    176d:	83 7b 28 00          	cmpl   $0x0,0x28(%ebx)
    1771:	74 22                	je     1795 <_test_allocation_child+0x601>
        int pid = fork();
    1773:	e8 ba 18 00 00       	call   3032 <fork>
        if (pid == -1) {
    1778:	83 f8 ff             	cmp    $0xffffffff,%eax
    177b:	75 0a                	jne    1787 <_test_allocation_child+0x5f3>
            CRASH("error from fork()");
    177d:	b8 ba 34 00 00       	mov    $0x34ba,%eax
    1782:	e8 45 e9 ff ff       	call   cc <CRASH>
        } else if (pid == 0) {
    1787:	85 c0                	test   %eax,%eax
    1789:	75 05                	jne    1790 <_test_allocation_child+0x5fc>
            exit();
    178b:	e8 aa 18 00 00       	call   303a <exit>
            wait();
    1790:	e8 ad 18 00 00       	call   3042 <wait>
    _pipe_send_child(&info->pipes, &result, 1);
    1795:	b9 01 00 00 00       	mov    $0x1,%ecx
    179a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
    179d:	89 d8                	mov    %ebx,%eax
    179f:	e8 da e8 ff ff       	call   7e <_pipe_send_child>
    return result;
    17a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
    17a7:	83 c4 3c             	add    $0x3c,%esp
    17aa:	5b                   	pop    %ebx
    17ab:	5e                   	pop    %esi
    17ac:	5f                   	pop    %edi
    17ad:	5d                   	pop    %ebp
    17ae:	c3                   	ret    

000017af <_cow_test_parent>:
static TestResult _cow_test_parent(struct cow_test_info *info) {
    17af:	55                   	push   %ebp
    17b0:	89 e5                	mov    %esp,%ebp
    17b2:	57                   	push   %edi
    17b3:	56                   	push   %esi
    17b4:	53                   	push   %ebx
    17b5:	83 ec 4c             	sub    $0x4c,%esp
    17b8:	89 c7                	mov    %eax,%edi
    int pids[MAX_COW_FORKS] = {0};
    17ba:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
    17c1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    17c8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
    17cf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    int free_check = info->skip_free_check ? NO_FREE_CHECK : WITH_FREE_CHECK;
    17d6:	83 78 60 00          	cmpl   $0x0,0x60(%eax)
    17da:	0f 95 c0             	setne  %al
    17dd:	0f b6 c0             	movzbl %al,%eax
    17e0:	89 c3                	mov    %eax,%ebx
    17e2:	89 45 cc             	mov    %eax,-0x34(%ebp)
    clear_saved_ppns();
    17e5:	e8 25 e8 ff ff       	call   f <clear_saved_ppns>
    char *heap_base = sbrk(info->pre_alloc_size);
    17ea:	8b 47 44             	mov    0x44(%edi),%eax
    17ed:	89 04 24             	mov    %eax,(%esp)
    17f0:	e8 cd 18 00 00       	call   30c2 <sbrk>
    17f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    if (heap_base == (char*) -1)
    17f8:	83 f8 ff             	cmp    $0xffffffff,%eax
    17fb:	0f 84 31 06 00 00    	je     1e32 <_cow_test_parent+0x683>
    if (!info->skip_pte_check) {
    1801:	83 7f 64 00          	cmpl   $0x0,0x64(%edi)
    1805:	75 39                	jne    1840 <_cow_test_parent+0x91>
                (uint) heap_base + info->pre_alloc_size,
    1807:	89 c2                	mov    %eax,%edx
    1809:	03 57 44             	add    0x44(%edi),%edx
                PGROUNDUP((uint) heap_base),
    180c:	05 ff 0f 00 00       	add    $0xfff,%eax
        if (!_sanity_check_range_self(
    1811:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    1816:	c7 44 24 08 68 43 00 	movl   $0x4368,0x8(%esp)
    181d:	00 
    181e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
    1822:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
    1829:	b9 02 00 00 00       	mov    $0x2,%ecx
    182e:	e8 4c ee ff ff       	call   67f <_sanity_check_range_self>
    1833:	85 c0                	test   %eax,%eax
    1835:	74 12                	je     1849 <_cow_test_parent+0x9a>
    int result = TR_FAIL_UNKNOWN;
    1837:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
    183e:	eb 10                	jmp    1850 <_cow_test_parent+0xa1>
    1840:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
    1847:	eb 07                	jmp    1850 <_cow_test_parent+0xa1>
            result = TR_FAIL_PTE;
    1849:	c7 45 c8 02 00 00 00 	movl   $0x2,-0x38(%ebp)
    for (int region = 0; region < NUM_COW_REGIONS; ++region) {
    1850:	be 00 00 00 00       	mov    $0x0,%esi
    1855:	89 7d d0             	mov    %edi,-0x30(%ebp)
    1858:	eb 2c                	jmp    1886 <_cow_test_parent+0xd7>
        for (int j = info->starts[region]; j < info->ends[region]; j += 1) {
    185a:	8b 45 d0             	mov    -0x30(%ebp),%eax
    185d:	8b 7c b0 54          	mov    0x54(%eax,%esi,4),%edi
    1861:	eb 17                	jmp    187a <_cow_test_parent+0xcb>
            heap_base[j] = _heap_test_value(j, -1);
    1863:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    1866:	8d 1c 38             	lea    (%eax,%edi,1),%ebx
    1869:	ba ff ff ff ff       	mov    $0xffffffff,%edx
    186e:	89 f8                	mov    %edi,%eax
    1870:	e8 c5 e7 ff ff       	call   3a <_heap_test_value>
    1875:	88 03                	mov    %al,(%ebx)
        for (int j = info->starts[region]; j < info->ends[region]; j += 1) {
    1877:	83 c7 01             	add    $0x1,%edi
    187a:	8b 45 d0             	mov    -0x30(%ebp),%eax
    187d:	39 7c b0 58          	cmp    %edi,0x58(%eax,%esi,4)
    1881:	7f e0                	jg     1863 <_cow_test_parent+0xb4>
    for (int region = 0; region < NUM_COW_REGIONS; ++region) {
    1883:	83 c6 01             	add    $0x1,%esi
    1886:	85 f6                	test   %esi,%esi
    1888:	7e d0                	jle    185a <_cow_test_parent+0xab>
    188a:	8b 7d d0             	mov    -0x30(%ebp),%edi
    if (!info->skip_pte_check) {
    188d:	83 7f 64 00          	cmpl   $0x0,0x64(%edi)
    1891:	74 6b                	je     18fe <_cow_test_parent+0x14f>
    1893:	eb 72                	jmp    1907 <_cow_test_parent+0x158>
            if (info->starts[region] < info->ends[region]) {
    1895:	8d 43 14             	lea    0x14(%ebx),%eax
    1898:	8b 54 87 04          	mov    0x4(%edi,%eax,4),%edx
    189c:	8b 44 87 08          	mov    0x8(%edi,%eax,4),%eax
    18a0:	39 c2                	cmp    %eax,%edx
    18a2:	7d 55                	jge    18f9 <_cow_test_parent+0x14a>
                        PGROUNDUP((uint) heap_base + info->ends[region]),
    18a4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
    18a7:	8d 8c 06 ff 0f 00 00 	lea    0xfff(%esi,%eax,1),%ecx
                        PGROUNDDOWN((uint) heap_base + info->starts[region]),
    18ae:	89 f0                	mov    %esi,%eax
    18b0:	01 d0                	add    %edx,%eax
                if (!_sanity_check_range_self(
    18b2:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
    18b8:	89 ca                	mov    %ecx,%edx
    18ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    18bf:	c7 44 24 08 8c 43 00 	movl   $0x438c,0x8(%esp)
    18c6:	00 
    18c7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
    18ca:	89 4c 24 04          	mov    %ecx,0x4(%esp)
    18ce:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
    18d5:	b9 01 00 00 00       	mov    $0x1,%ecx
    18da:	e8 a0 ed ff ff       	call   67f <_sanity_check_range_self>
    18df:	85 c0                	test   %eax,%eax
    18e1:	75 16                	jne    18f9 <_cow_test_parent+0x14a>
                    result = max(result, TR_FAIL_PTE);
    18e3:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    18ea:	00 
    18eb:	8b 45 c8             	mov    -0x38(%ebp),%eax
    18ee:	89 04 24             	mov    %eax,(%esp)
    18f1:	e8 8d f8 ff ff       	call   1183 <max>
    18f6:	89 45 c8             	mov    %eax,-0x38(%ebp)
        for (int region = 0; region < NUM_COW_REGIONS; ++region) {
    18f9:	83 c3 01             	add    $0x1,%ebx
    18fc:	eb 05                	jmp    1903 <_cow_test_parent+0x154>
    18fe:	bb 00 00 00 00       	mov    $0x0,%ebx
    1903:	85 db                	test   %ebx,%ebx
    1905:	7e 8e                	jle    1895 <_cow_test_parent+0xe6>
    if (info->dump)
    1907:	83 7f 68 00          	cmpl   $0x0,0x68(%edi)
    190b:	74 15                	je     1922 <_cow_test_parent+0x173>
        dump_for("copy-on-write-parent-before", getpid());
    190d:	e8 a8 17 00 00       	call   30ba <getpid>
    1912:	89 44 24 04          	mov    %eax,0x4(%esp)
    1916:	c7 04 24 cc 34 00 00 	movl   $0x34cc,(%esp)
    191d:	e8 df f7 ff ff       	call   1101 <dump_for>
    1922:	bb 00 00 00 00       	mov    $0x0,%ebx
    1927:	eb 78                	jmp    19a1 <_cow_test_parent+0x1f2>
        _init_pipes(&info->all_pipes[i]);
    1929:	89 de                	mov    %ebx,%esi
    192b:	c1 e6 04             	shl    $0x4,%esi
    192e:	01 fe                	add    %edi,%esi
    1930:	89 f0                	mov    %esi,%eax
    1932:	e8 fe ed ff ff       	call   735 <_init_pipes>
        pids[i] = fork();
    1937:	e8 f6 16 00 00       	call   3032 <fork>
    193c:	89 44 9d d8          	mov    %eax,-0x28(%ebp,%ebx,4)
        if (pids[i] == -1) {
    1940:	83 f8 ff             	cmp    $0xffffffff,%eax
    1943:	75 36                	jne    197b <_cow_test_parent+0x1cc>
            _pipe_sync_cleanup(&info->all_pipes[i]);
    1945:	89 f0                	mov    %esi,%eax
    1947:	e8 47 ee ff ff       	call   793 <_pipe_sync_cleanup>
            printf(2, "ERROR: fork() failed\n");
    194c:	c7 44 24 04 e8 34 00 	movl   $0x34e8,0x4(%esp)
    1953:	00 
    1954:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    195b:	e8 4c 18 00 00       	call   31ac <printf>
            result = max(result, TR_FAIL_FORK);
    1960:	c7 44 24 04 07 00 00 	movl   $0x7,0x4(%esp)
    1967:	00 
    1968:	8b 45 c8             	mov    -0x38(%ebp),%eax
    196b:	89 04 24             	mov    %eax,(%esp)
    196e:	e8 10 f8 ff ff       	call   1183 <max>
    1973:	89 45 d4             	mov    %eax,-0x2c(%ebp)
            goto cleanup_children;
    1976:	e9 7a 04 00 00       	jmp    1df5 <_cow_test_parent+0x646>
        } else if (pids[i] == 0) {
    197b:	85 c0                	test   %eax,%eax
    197d:	75 18                	jne    1997 <_cow_test_parent+0x1e8>
            _pipe_sync_setup_child(&info->all_pipes[i]);
    197f:	89 f0                	mov    %esi,%eax
    1981:	e8 5b ee ff ff       	call   7e1 <_pipe_sync_setup_child>
            _cow_test_child(info, heap_base, i);
    1986:	89 d9                	mov    %ebx,%ecx
    1988:	8b 55 d4             	mov    -0x2c(%ebp),%edx
    198b:	89 f8                	mov    %edi,%eax
    198d:	e8 27 f2 ff ff       	call   bb9 <_cow_test_child>
            exit();
    1992:	e8 a3 16 00 00       	call   303a <exit>
        _pipe_sync_setup_parent(&info->all_pipes[i]);
    1997:	89 f0                	mov    %esi,%eax
    1999:	e8 1a ef ff ff       	call   8b8 <_pipe_sync_setup_parent>
    for (int i = 0; i < info->num_forks; ++i) {
    199e:	83 c3 01             	add    $0x1,%ebx
    19a1:	8b 47 40             	mov    0x40(%edi),%eax
    19a4:	39 d8                	cmp    %ebx,%eax
    19a6:	7f 81                	jg     1929 <_cow_test_parent+0x17a>
    if (info->dump && info->num_forks > 0)
    19a8:	83 7f 68 00          	cmpl   $0x0,0x68(%edi)
    19ac:	74 17                	je     19c5 <_cow_test_parent+0x216>
    19ae:	85 c0                	test   %eax,%eax
    19b0:	7e 13                	jle    19c5 <_cow_test_parent+0x216>
        dump_for("copy-on-write-child-before-writes", pids[0]);
    19b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
    19b5:	89 44 24 04          	mov    %eax,0x4(%esp)
    19b9:	c7 04 24 b8 43 00 00 	movl   $0x43b8,(%esp)
    19c0:	e8 3c f7 ff ff       	call   1101 <dump_for>
    19c5:	be 00 00 00 00       	mov    $0x0,%esi
    19ca:	89 75 d0             	mov    %esi,-0x30(%ebp)
    19cd:	e9 38 01 00 00       	jmp    1b0a <_cow_test_parent+0x35b>
        if (info->starts[region] < info->ends[region]) {
    19d2:	8b 45 d0             	mov    -0x30(%ebp),%eax
    19d5:	83 c0 14             	add    $0x14,%eax
    19d8:	8b 54 87 04          	mov    0x4(%edi,%eax,4),%edx
    19dc:	8b 44 87 08          	mov    0x8(%edi,%eax,4),%eax
    19e0:	39 c2                	cmp    %eax,%edx
    19e2:	0f 8d 1e 01 00 00    	jge    1b06 <_cow_test_parent+0x357>
            if (!info->skip_pte_check && !_sanity_check_range_self(
    19e8:	83 7f 64 00          	cmpl   $0x0,0x64(%edi)
    19ec:	75 43                	jne    1a31 <_cow_test_parent+0x282>
                    PGROUNDUP((uint) heap_base + info->ends[region]),
    19ee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
    19f1:	8d 8c 03 ff 0f 00 00 	lea    0xfff(%ebx,%eax,1),%ecx
                    PGROUNDDOWN((uint) heap_base + info->starts[region]),
    19f8:	89 d8                	mov    %ebx,%eax
    19fa:	01 d0                	add    %edx,%eax
            if (!info->skip_pte_check && !_sanity_check_range_self(
    19fc:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
    1a02:	89 ca                	mov    %ecx,%edx
    1a04:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    1a09:	c7 44 24 08 dc 43 00 	movl   $0x43dc,0x8(%esp)
    1a10:	00 
    1a11:	8b 4d cc             	mov    -0x34(%ebp),%ecx
    1a14:	89 4c 24 04          	mov    %ecx,0x4(%esp)
    1a18:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1a1f:	b9 01 00 00 00       	mov    $0x1,%ecx
    1a24:	e8 56 ec ff ff       	call   67f <_sanity_check_range_self>
    1a29:	85 c0                	test   %eax,%eax
    1a2b:	0f 84 87 03 00 00    	je     1db8 <_cow_test_parent+0x609>
    1a31:	bb 00 00 00 00       	mov    $0x0,%ebx
    1a36:	8b 75 d4             	mov    -0x2c(%ebp),%esi
    1a39:	e9 bf 00 00 00       	jmp    1afd <_cow_test_parent+0x34e>
                if (!info->skip_pte_check && !_sanity_check_range(
    1a3e:	83 7f 64 00          	cmpl   $0x0,0x64(%edi)
    1a42:	75 59                	jne    1a9d <_cow_test_parent+0x2ee>
                        PGROUNDUP((uint) heap_base + info->ends[region]),
    1a44:	8b 45 d0             	mov    -0x30(%ebp),%eax
    1a47:	83 c0 14             	add    $0x14,%eax
    1a4a:	89 f1                	mov    %esi,%ecx
    1a4c:	03 4c 87 08          	add    0x8(%edi,%eax,4),%ecx
    1a50:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
                        PGROUNDDOWN((uint) heap_base + info->starts[region]),
    1a56:	89 f2                	mov    %esi,%edx
    1a58:	03 54 87 04          	add    0x4(%edi,%eax,4),%edx
                if (!info->skip_pte_check && !_sanity_check_range(
    1a5c:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
    1a62:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
    1a68:	8b 44 9d d8          	mov    -0x28(%ebp,%ebx,4),%eax
    1a6c:	89 45 c8             	mov    %eax,-0x38(%ebp)
    1a6f:	c7 44 24 0c 2c 44 00 	movl   $0x442c,0xc(%esp)
    1a76:	00 
    1a77:	8b 45 cc             	mov    -0x34(%ebp),%eax
    1a7a:	89 44 24 08          	mov    %eax,0x8(%esp)
    1a7e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    1a85:	00 
    1a86:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1a8d:	8b 45 c8             	mov    -0x38(%ebp),%eax
    1a90:	e8 03 ea ff ff       	call   498 <_sanity_check_range>
    1a95:	85 c0                	test   %eax,%eax
    1a97:	0f 84 24 03 00 00    	je     1dc1 <_cow_test_parent+0x612>
                if (!info->skip_pte_check && !_same_pte_range(getpid(), pids[i],
    1a9d:	83 7f 64 00          	cmpl   $0x0,0x64(%edi)
    1aa1:	75 57                	jne    1afa <_cow_test_parent+0x34b>
                        PGROUNDUP((uint) heap_base + info->ends[region]),
    1aa3:	8b 45 d0             	mov    -0x30(%ebp),%eax
    1aa6:	83 c0 14             	add    $0x14,%eax
    1aa9:	89 f2                	mov    %esi,%edx
    1aab:	03 54 87 08          	add    0x8(%edi,%eax,4),%edx
    1aaf:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
    1ab5:	89 4d c8             	mov    %ecx,-0x38(%ebp)
                        PGROUNDDOWN((uint) heap_base + info->starts[region]),
    1ab8:	89 f1                	mov    %esi,%ecx
    1aba:	03 4c 87 04          	add    0x4(%edi,%eax,4),%ecx
    1abe:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
                if (!info->skip_pte_check && !_same_pte_range(getpid(), pids[i],
    1ac1:	8b 44 9d d8          	mov    -0x28(%ebp,%ebx,4),%eax
    1ac5:	89 45 c0             	mov    %eax,-0x40(%ebp)
    1ac8:	e8 ed 15 00 00       	call   30ba <getpid>
    1acd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
    1ad0:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
    1ad6:	c7 44 24 04 2c 44 00 	movl   $0x442c,0x4(%esp)
    1add:	00 
    1ade:	8b 55 c8             	mov    -0x38(%ebp),%edx
    1ae1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
    1ae7:	89 14 24             	mov    %edx,(%esp)
    1aea:	8b 55 c0             	mov    -0x40(%ebp),%edx
    1aed:	e8 2e e8 ff ff       	call   320 <_same_pte_range>
    1af2:	85 c0                	test   %eax,%eax
    1af4:	0f 84 d0 02 00 00    	je     1dca <_cow_test_parent+0x61b>
            for (int i = 0; i < info->num_forks; i += 1) {
    1afa:	83 c3 01             	add    $0x1,%ebx
    1afd:	39 5f 40             	cmp    %ebx,0x40(%edi)
    1b00:	0f 8f 38 ff ff ff    	jg     1a3e <_cow_test_parent+0x28f>
    for (int region = 0; region < NUM_COW_REGIONS; ++region) {
    1b06:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
    1b0a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
    1b0e:	0f 8e be fe ff ff    	jle    19d2 <_cow_test_parent+0x223>
    1b14:	bb 00 00 00 00       	mov    $0x0,%ebx
    1b19:	eb 17                	jmp    1b32 <_cow_test_parent+0x383>
        if (!_pipe_sync_parent(&info->all_pipes[i])) {
    1b1b:	89 d8                	mov    %ebx,%eax
    1b1d:	c1 e0 04             	shl    $0x4,%eax
    1b20:	01 f8                	add    %edi,%eax
    1b22:	e8 c8 e5 ff ff       	call   ef <_pipe_sync_parent>
    1b27:	85 c0                	test   %eax,%eax
    1b29:	0f 84 a4 02 00 00    	je     1dd3 <_cow_test_parent+0x624>
    for (int i = 0; i < info->num_forks; ++i) {
    1b2f:	83 c3 01             	add    $0x1,%ebx
    1b32:	39 5f 40             	cmp    %ebx,0x40(%edi)
    1b35:	7f e4                	jg     1b1b <_cow_test_parent+0x36c>
    1b37:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
    1b3e:	e9 fc 01 00 00       	jmp    1d3f <_cow_test_parent+0x590>
            if (i >= 0) {
    1b43:	8b 75 c0             	mov    -0x40(%ebp),%esi
    1b46:	85 f6                	test   %esi,%esi
    1b48:	0f 88 15 01 00 00    	js     1c63 <_cow_test_parent+0x4b4>
                if (!_pipe_sync_parent(&info->all_pipes[i])) { /* start write */
    1b4e:	89 f3                	mov    %esi,%ebx
    1b50:	c1 e3 04             	shl    $0x4,%ebx
    1b53:	01 fb                	add    %edi,%ebx
    1b55:	89 d8                	mov    %ebx,%eax
    1b57:	e8 93 e5 ff ff       	call   ef <_pipe_sync_parent>
    1b5c:	85 c0                	test   %eax,%eax
    1b5e:	0f 84 78 02 00 00    	je     1ddc <_cow_test_parent+0x62d>
                if (!_pipe_sync_parent(&info->all_pipes[i])) { /* finish write */
    1b64:	89 d8                	mov    %ebx,%eax
    1b66:	e8 84 e5 ff ff       	call   ef <_pipe_sync_parent>
    1b6b:	85 c0                	test   %eax,%eax
    1b6d:	0f 84 72 02 00 00    	je     1de5 <_cow_test_parent+0x636>
                if (info->child_write[region][i]) {
    1b73:	8b 45 bc             	mov    -0x44(%ebp),%eax
    1b76:	80 7c 06 50 00       	cmpb   $0x0,0x50(%esi,%eax,1)
    1b7b:	74 4f                	je     1bcc <_cow_test_parent+0x41d>
                    if (info->dump && i == 0) {
    1b7d:	83 7f 68 00          	cmpl   $0x0,0x68(%edi)
    1b81:	74 1d                	je     1ba0 <_cow_test_parent+0x3f1>
    1b83:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
    1b87:	75 17                	jne    1ba0 <_cow_test_parent+0x3f1>
                        dump_for("copy-on-write-child-after-write", pids[i]);
    1b89:	8b 45 c0             	mov    -0x40(%ebp),%eax
    1b8c:	8b 44 85 d8          	mov    -0x28(%ebp,%eax,4),%eax
    1b90:	89 44 24 04          	mov    %eax,0x4(%esp)
    1b94:	c7 04 24 7c 44 00 00 	movl   $0x447c,(%esp)
    1b9b:	e8 61 f5 ff ff       	call   1101 <dump_for>
                    if (!info->skip_free_check) {
    1ba0:	83 7f 60 00          	cmpl   $0x0,0x60(%edi)
    1ba4:	75 26                	jne    1bcc <_cow_test_parent+0x41d>
                                  (uint) heap_base + info->ends[region],
    1ba6:	8b 45 cc             	mov    -0x34(%ebp),%eax
    1ba9:	83 c0 14             	add    $0x14,%eax
    1bac:	8b 55 d4             	mov    -0x2c(%ebp),%edx
    1baf:	89 d1                	mov    %edx,%ecx
    1bb1:	03 4c 87 08          	add    0x8(%edi,%eax,4),%ecx
                                  (uint) heap_base + info->starts[region],
    1bb5:	03 54 87 04          	add    0x4(%edi,%eax,4),%edx
                        save_ppns(pids[i],
    1bb9:	8b 45 c0             	mov    -0x40(%ebp),%eax
    1bbc:	8b 44 85 d8          	mov    -0x28(%ebp,%eax,4),%eax
    1bc0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    1bc7:	e8 8c e6 ff ff       	call   258 <save_ppns>
                if (!info->child_write[region][i] && !have_written) {
    1bcc:	8b 45 c0             	mov    -0x40(%ebp),%eax
    1bcf:	8b 4d bc             	mov    -0x44(%ebp),%ecx
    1bd2:	80 7c 08 50 00       	cmpb   $0x0,0x50(%eax,%ecx,1)
    1bd7:	75 4f                	jne    1c28 <_cow_test_parent+0x479>
    1bd9:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
    1bdd:	75 49                	jne    1c28 <_cow_test_parent+0x479>
                    if (!info->skip_pte_check && !_same_pte_range(pids[i], getpid(),
    1bdf:	83 7f 64 00          	cmpl   $0x0,0x64(%edi)
    1be3:	75 7e                	jne    1c63 <_cow_test_parent+0x4b4>
                            (uint) heap_base + info->ends[region],
    1be5:	8b 45 cc             	mov    -0x34(%ebp),%eax
    1be8:	83 c0 14             	add    $0x14,%eax
    1beb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
    1bee:	89 f3                	mov    %esi,%ebx
    1bf0:	03 5c 87 08          	add    0x8(%edi,%eax,4),%ebx
                            (uint) heap_base + info->starts[region],
    1bf4:	03 74 87 04          	add    0x4(%edi,%eax,4),%esi
                    if (!info->skip_pte_check && !_same_pte_range(pids[i], getpid(),
    1bf8:	e8 bd 14 00 00       	call   30ba <getpid>
    1bfd:	89 c2                	mov    %eax,%edx
    1bff:	8b 45 c0             	mov    -0x40(%ebp),%eax
    1c02:	8b 44 85 d8          	mov    -0x28(%ebp,%eax,4),%eax
    1c06:	c7 44 24 04 9c 44 00 	movl   $0x449c,0x4(%esp)
    1c0d:	00 
    1c0e:	89 1c 24             	mov    %ebx,(%esp)
    1c11:	89 f1                	mov    %esi,%ecx
    1c13:	e8 08 e7 ff ff       	call   320 <_same_pte_range>
    1c18:	85 c0                	test   %eax,%eax
    1c1a:	75 47                	jne    1c63 <_cow_test_parent+0x4b4>
                        result = TR_FAIL_PTE;
    1c1c:	c7 45 d4 02 00 00 00 	movl   $0x2,-0x2c(%ebp)
    1c23:	e9 cd 01 00 00       	jmp    1df5 <_cow_test_parent+0x646>
                            (uint) heap_base + info->ends[region],
    1c28:	8b 45 cc             	mov    -0x34(%ebp),%eax
    1c2b:	83 c0 14             	add    $0x14,%eax
    1c2e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
    1c31:	89 f3                	mov    %esi,%ebx
    1c33:	03 5c 87 08          	add    0x8(%edi,%eax,4),%ebx
                            (uint) heap_base + info->starts[region],
    1c37:	03 74 87 04          	add    0x4(%edi,%eax,4),%esi
                    if (!_different_pte_range(pids[i], getpid(),
    1c3b:	e8 7a 14 00 00       	call   30ba <getpid>
    1c40:	89 c2                	mov    %eax,%edx
    1c42:	8b 45 c0             	mov    -0x40(%ebp),%eax
    1c45:	8b 44 85 d8          	mov    -0x28(%ebp,%eax,4),%eax
    1c49:	c7 44 24 04 e0 44 00 	movl   $0x44e0,0x4(%esp)
    1c50:	00 
    1c51:	89 1c 24             	mov    %ebx,(%esp)
    1c54:	89 f1                	mov    %esi,%ecx
    1c56:	e8 4c e7 ff ff       	call   3a7 <_different_pte_range>
    1c5b:	85 c0                	test   %eax,%eax
    1c5d:	0f 84 8b 01 00 00    	je     1dee <_cow_test_parent+0x63f>
            int do_write = (i == info->parent_write_index && info->parent_write[region]);
    1c63:	8b 45 c0             	mov    -0x40(%ebp),%eax
    1c66:	39 47 4c             	cmp    %eax,0x4c(%edi)
    1c69:	75 13                	jne    1c7e <_cow_test_parent+0x4cf>
    1c6b:	8b 45 cc             	mov    -0x34(%ebp),%eax
    1c6e:	80 7c 07 48 00       	cmpb   $0x0,0x48(%edi,%eax,1)
    1c73:	75 12                	jne    1c87 <_cow_test_parent+0x4d8>
    1c75:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
    1c7c:	eb 10                	jmp    1c8e <_cow_test_parent+0x4df>
    1c7e:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
    1c85:	eb 07                	jmp    1c8e <_cow_test_parent+0x4df>
    1c87:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
            for (int j = info->starts[region]; j < info->ends[region]; j += 1) {
    1c8e:	8b 45 cc             	mov    -0x34(%ebp),%eax
    1c91:	8b 74 87 54          	mov    0x54(%edi,%eax,4),%esi
    1c95:	eb 65                	jmp    1cfc <_cow_test_parent+0x54d>
                if (heap_base[j] != _heap_test_value(j, have_written ? -2 : -1)) {
    1c97:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    1c9a:	8d 1c 30             	lea    (%eax,%esi,1),%ebx
    1c9d:	0f b6 03             	movzbl (%ebx),%eax
    1ca0:	88 45 d0             	mov    %al,-0x30(%ebp)
    1ca3:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
    1ca7:	74 07                	je     1cb0 <_cow_test_parent+0x501>
    1ca9:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
    1cae:	eb 05                	jmp    1cb5 <_cow_test_parent+0x506>
    1cb0:	ba ff ff ff ff       	mov    $0xffffffff,%edx
    1cb5:	89 f0                	mov    %esi,%eax
    1cb7:	e8 7e e3 ff ff       	call   3a <_heap_test_value>
    1cbc:	38 45 d0             	cmp    %al,-0x30(%ebp)
    1cbf:	74 24                	je     1ce5 <_cow_test_parent+0x536>
                    printf(2, "ERROR: wrong value read from parent at offset 0x%x\n", j);
    1cc1:	89 74 24 08          	mov    %esi,0x8(%esp)
    1cc5:	c7 44 24 04 20 45 00 	movl   $0x4520,0x4(%esp)
    1ccc:	00 
    1ccd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1cd4:	e8 d3 14 00 00       	call   31ac <printf>
                    result = TR_FAIL_READBACK;
    1cd9:	c7 45 d4 06 00 00 00 	movl   $0x6,-0x2c(%ebp)
                    goto cleanup_children;
    1ce0:	e9 10 01 00 00       	jmp    1df5 <_cow_test_parent+0x646>
                if (do_write) {
    1ce5:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
    1ce9:	74 0e                	je     1cf9 <_cow_test_parent+0x54a>
                    heap_base[j] = _heap_test_value(j, -2);
    1ceb:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
    1cf0:	89 f0                	mov    %esi,%eax
    1cf2:	e8 43 e3 ff ff       	call   3a <_heap_test_value>
    1cf7:	88 03                	mov    %al,(%ebx)
            for (int j = info->starts[region]; j < info->ends[region]; j += 1) {
    1cf9:	83 c6 01             	add    $0x1,%esi
    1cfc:	8b 45 cc             	mov    -0x34(%ebp),%eax
    1cff:	39 74 87 58          	cmp    %esi,0x58(%edi,%eax,4)
    1d03:	7f 92                	jg     1c97 <_cow_test_parent+0x4e8>
            if (do_write) {
    1d05:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
    1d09:	74 07                	je     1d12 <_cow_test_parent+0x563>
                have_written = 1;
    1d0b:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
        for (int i  = -1; i < info->num_forks; ++i) {
    1d12:	83 45 c0 01          	addl   $0x1,-0x40(%ebp)
    1d16:	eb 17                	jmp    1d2f <_cow_test_parent+0x580>
    1d18:	c7 45 c0 ff ff ff ff 	movl   $0xffffffff,-0x40(%ebp)
    1d1f:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
                if (info->child_write[region][i]) {
    1d26:	8b 45 cc             	mov    -0x34(%ebp),%eax
    1d29:	8d 04 87             	lea    (%edi,%eax,4),%eax
    1d2c:	89 45 bc             	mov    %eax,-0x44(%ebp)
        for (int i  = -1; i < info->num_forks; ++i) {
    1d2f:	8b 45 c0             	mov    -0x40(%ebp),%eax
    1d32:	39 47 40             	cmp    %eax,0x40(%edi)
    1d35:	0f 8f 08 fe ff ff    	jg     1b43 <_cow_test_parent+0x394>
    for (int region = 0; region < NUM_COW_REGIONS; ++region) {
    1d3b:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
    1d3f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
    1d43:	7e d3                	jle    1d18 <_cow_test_parent+0x569>
    if (info->dump) {
    1d45:	83 7f 68 00          	cmpl   $0x0,0x68(%edi)
    1d49:	74 15                	je     1d60 <_cow_test_parent+0x5b1>
        dump_for("copy-on-write-parent-after", getpid());
    1d4b:	e8 6a 13 00 00       	call   30ba <getpid>
    1d50:	89 44 24 04          	mov    %eax,0x4(%esp)
    1d54:	c7 04 24 fe 34 00 00 	movl   $0x34fe,(%esp)
    1d5b:	e8 a1 f3 ff ff       	call   1101 <dump_for>
    1d60:	bb 00 00 00 00       	mov    $0x0,%ebx
    1d65:	eb 1d                	jmp    1d84 <_cow_test_parent+0x5d5>
        _pipe_sync_parent(&info->all_pipes[i]);
    1d67:	89 de                	mov    %ebx,%esi
    1d69:	c1 e6 04             	shl    $0x4,%esi
    1d6c:	01 fe                	add    %edi,%esi
    1d6e:	89 f0                	mov    %esi,%eax
    1d70:	e8 7a e3 ff ff       	call   ef <_pipe_sync_parent>
        _pipe_sync_cleanup(&info->all_pipes[i]);
    1d75:	89 f0                	mov    %esi,%eax
    1d77:	e8 17 ea ff ff       	call   793 <_pipe_sync_cleanup>
        wait();
    1d7c:	e8 c1 12 00 00       	call   3042 <wait>
    for (int i = 0; i <info->num_forks; ++i) {
    1d81:	83 c3 01             	add    $0x1,%ebx
    1d84:	39 5f 40             	cmp    %ebx,0x40(%edi)
    1d87:	7f de                	jg     1d67 <_cow_test_parent+0x5b8>
    if (!info->skip_free_check) {
    1d89:	83 7f 60 00          	cmpl   $0x0,0x60(%edi)
    1d8d:	75 18                	jne    1da7 <_cow_test_parent+0x5f8>
        if (!verify_ppns_freed("page that should have been a copy for a child process")) {
    1d8f:	b8 54 45 00 00       	mov    $0x4554,%eax
    1d94:	e8 95 e6 ff ff       	call   42e <verify_ppns_freed>
    1d99:	85 c0                	test   %eax,%eax
    1d9b:	74 14                	je     1db1 <_cow_test_parent+0x602>
    result = TR_SUCCESS;
    1d9d:	b8 00 00 00 00       	mov    $0x0,%eax
    1da2:	e9 90 00 00 00       	jmp    1e37 <_cow_test_parent+0x688>
    1da7:	b8 00 00 00 00       	mov    $0x0,%eax
    1dac:	e9 86 00 00 00       	jmp    1e37 <_cow_test_parent+0x688>
            result = TR_FAIL_NO_FREE;
    1db1:	b8 08 00 00 00       	mov    $0x8,%eax
    return result;
    1db6:	eb 7f                	jmp    1e37 <_cow_test_parent+0x688>
                result = TR_FAIL_PTE;
    1db8:	c7 45 d4 02 00 00 00 	movl   $0x2,-0x2c(%ebp)
    1dbf:	eb 34                	jmp    1df5 <_cow_test_parent+0x646>
                    result = TR_FAIL_PTE;
    1dc1:	c7 45 d4 02 00 00 00 	movl   $0x2,-0x2c(%ebp)
    1dc8:	eb 2b                	jmp    1df5 <_cow_test_parent+0x646>
                    result = TR_FAIL_PTE;
    1dca:	c7 45 d4 02 00 00 00 	movl   $0x2,-0x2c(%ebp)
    1dd1:	eb 22                	jmp    1df5 <_cow_test_parent+0x646>
            result = TR_FAIL_SYNC;
    1dd3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
    1dda:	eb 19                	jmp    1df5 <_cow_test_parent+0x646>
                    result = TR_FAIL_SYNC;
    1ddc:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
    1de3:	eb 10                	jmp    1df5 <_cow_test_parent+0x646>
                    result = TR_FAIL_SYNC;
    1de5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
    1dec:	eb 07                	jmp    1df5 <_cow_test_parent+0x646>
                        result = TR_FAIL_PTE;
    1dee:	c7 45 d4 02 00 00 00 	movl   $0x2,-0x2c(%ebp)
    for (int i = 0; i < info->num_forks; i += 1) {
    1df5:	bb 00 00 00 00       	mov    $0x0,%ebx
    1dfa:	eb 2c                	jmp    1e28 <_cow_test_parent+0x679>
        if (pids[i]) {
    1dfc:	8b 74 9d d8          	mov    -0x28(%ebp,%ebx,4),%esi
    1e00:	85 f6                	test   %esi,%esi
    1e02:	74 21                	je     1e25 <_cow_test_parent+0x676>
            _pipe_sync_cleanup(&info->all_pipes[i]);
    1e04:	89 d8                	mov    %ebx,%eax
    1e06:	c1 e0 04             	shl    $0x4,%eax
    1e09:	01 f8                	add    %edi,%eax
    1e0b:	e8 83 e9 ff ff       	call   793 <_pipe_sync_cleanup>
            kill(pids[i]);
    1e10:	89 34 24             	mov    %esi,(%esp)
    1e13:	e8 52 12 00 00       	call   306a <kill>
            pids[i] = -1;
    1e18:	c7 44 9d d8 ff ff ff 	movl   $0xffffffff,-0x28(%ebp,%ebx,4)
    1e1f:	ff 
            wait();
    1e20:	e8 1d 12 00 00       	call   3042 <wait>
    for (int i = 0; i < info->num_forks; i += 1) {
    1e25:	83 c3 01             	add    $0x1,%ebx
    1e28:	39 5f 40             	cmp    %ebx,0x40(%edi)
    1e2b:	7f cf                	jg     1dfc <_cow_test_parent+0x64d>
    return result;
    1e2d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    1e30:	eb 05                	jmp    1e37 <_cow_test_parent+0x688>
        return TR_FAIL_SBRK;
    1e32:	b8 03 00 00 00       	mov    $0x3,%eax
}
    1e37:	83 c4 4c             	add    $0x4c,%esp
    1e3a:	5b                   	pop    %ebx
    1e3b:	5e                   	pop    %esi
    1e3c:	5f                   	pop    %edi
    1e3d:	5d                   	pop    %ebp
    1e3e:	c3                   	ret    

00001e3f <test_cow>:
static TestResult test_cow(struct cow_test_info *info) {
    1e3f:	55                   	push   %ebp
    1e40:	89 e5                	mov    %esp,%ebp
    1e42:	57                   	push   %edi
    1e43:	56                   	push   %esi
    1e44:	53                   	push   %ebx
    1e45:	83 ec 2c             	sub    $0x2c,%esp
    1e48:	89 c3                	mov    %eax,%ebx
    printf(1, "Running copy-on-write test%s:\n"
    1e4a:	8b 78 40             	mov    0x40(%eax),%edi
    1e4d:	8b 70 58             	mov    0x58(%eax),%esi
    1e50:	8b 48 54             	mov    0x54(%eax),%ecx
    1e53:	8b 50 44             	mov    0x44(%eax),%edx
    1e56:	83 78 6c 00          	cmpl   $0x0,0x6c(%eax)
    1e5a:	74 07                	je     1e63 <test_cow+0x24>
    1e5c:	b8 19 35 00 00       	mov    $0x3519,%eax
    1e61:	eb 05                	jmp    1e68 <test_cow+0x29>
    1e63:	b8 8c 33 00 00       	mov    $0x338c,%eax
    1e68:	89 7c 24 18          	mov    %edi,0x18(%esp)
    1e6c:	89 74 24 14          	mov    %esi,0x14(%esp)
    1e70:	89 4c 24 10          	mov    %ecx,0x10(%esp)
    1e74:	89 54 24 0c          	mov    %edx,0xc(%esp)
    1e78:	89 44 24 08          	mov    %eax,0x8(%esp)
    1e7c:	c7 44 24 04 8c 45 00 	movl   $0x458c,0x4(%esp)
    1e83:	00 
    1e84:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1e8b:	e8 1c 13 00 00       	call   31ac <printf>
    if (!info->skip_free_check)
    1e90:	83 7b 60 00          	cmpl   $0x0,0x60(%ebx)
    1e94:	75 14                	jne    1eaa <test_cow+0x6b>
        printf(1, "  checking that physical pages allocated seem not free\n"
    1e96:	c7 44 24 04 44 46 00 	movl   $0x4644,0x4(%esp)
    1e9d:	00 
    1e9e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ea5:	e8 02 13 00 00       	call   31ac <printf>
    if (info->parent_write_index == -1)
    1eaa:	83 7b 4c ff          	cmpl   $0xffffffff,0x4c(%ebx)
    1eae:	75 14                	jne    1ec4 <test_cow+0x85>
        printf(1, "  writing to byte range from parent process\n");
    1eb0:	c7 44 24 04 a8 46 00 	movl   $0x46a8,0x4(%esp)
    1eb7:	00 
    1eb8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ebf:	e8 e8 12 00 00       	call   31ac <printf>
            printf(1, "  writing to byte range from child process %d%s\n", i,
    1ec4:	be 00 00 00 00       	mov    $0x0,%esi
    1ec9:	eb 57                	jmp    1f22 <test_cow+0xe3>
        if (info->child_write[0][i]) {
    1ecb:	80 7c 33 50 00       	cmpb   $0x0,0x50(%ebx,%esi,1)
    1ed0:	74 2e                	je     1f00 <test_cow+0xc1>
            printf(1, "  writing to byte range from child process %d%s\n", i,
    1ed2:	83 7b 5c 00          	cmpl   $0x0,0x5c(%ebx)
    1ed6:	74 07                	je     1edf <test_cow+0xa0>
    1ed8:	b8 2d 35 00 00       	mov    $0x352d,%eax
    1edd:	eb 05                	jmp    1ee4 <test_cow+0xa5>
    1edf:	b8 8c 33 00 00       	mov    $0x338c,%eax
    1ee4:	89 44 24 0c          	mov    %eax,0xc(%esp)
    1ee8:	89 74 24 08          	mov    %esi,0x8(%esp)
    1eec:	c7 44 24 04 d8 46 00 	movl   $0x46d8,0x4(%esp)
    1ef3:	00 
    1ef4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1efb:	e8 ac 12 00 00       	call   31ac <printf>
        if (info->parent_write[0] && info->parent_write_index == i) {
    1f00:	80 7b 48 00          	cmpb   $0x0,0x48(%ebx)
    1f04:	74 19                	je     1f1f <test_cow+0xe0>
    1f06:	39 73 4c             	cmp    %esi,0x4c(%ebx)
    1f09:	75 14                	jne    1f1f <test_cow+0xe0>
            printf(1, "  writing to byte range from parent process\n");
    1f0b:	c7 44 24 04 a8 46 00 	movl   $0x46a8,0x4(%esp)
    1f12:	00 
    1f13:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f1a:	e8 8d 12 00 00       	call   31ac <printf>
    for (int i = 0; i < info->num_forks; i += 1) {
    1f1f:	83 c6 01             	add    $0x1,%esi
    1f22:	39 73 40             	cmp    %esi,0x40(%ebx)
    1f25:	7f a4                	jg     1ecb <test_cow+0x8c>
    printf(1, "  and checking that appropriate pages are shared/not shared\n");
    1f27:	c7 44 24 04 0c 47 00 	movl   $0x470c,0x4(%esp)
    1f2e:	00 
    1f2f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f36:	e8 71 12 00 00       	call   31ac <printf>
    if (!info->skip_free_check)
    1f3b:	83 7b 60 00          	cmpl   $0x0,0x60(%ebx)
    1f3f:	75 14                	jne    1f55 <test_cow+0x116>
        printf(1, "  and checking that pages in child which should not be shared are freed\n");
    1f41:	c7 44 24 04 4c 47 00 	movl   $0x474c,0x4(%esp)
    1f48:	00 
    1f49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f50:	e8 57 12 00 00       	call   31ac <printf>
    int result = _cow_test_parent(info);
    1f55:	89 d8                	mov    %ebx,%eax
    1f57:	e8 53 f8 ff ff       	call   17af <_cow_test_parent>
    1f5c:	89 c3                	mov    %eax,%ebx
    if (result == TR_SUCCESS)
    1f5e:	85 c0                	test   %eax,%eax
    1f60:	75 14                	jne    1f76 <test_cow+0x137>
        printf(1, "Test successful.\n");
    1f62:	c7 44 24 04 4b 33 00 	movl   $0x334b,0x4(%esp)
    1f69:	00 
    1f6a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f71:	e8 36 12 00 00       	call   31ac <printf>
}
    1f76:	89 d8                	mov    %ebx,%eax
    1f78:	83 c4 2c             	add    $0x2c,%esp
    1f7b:	5b                   	pop    %ebx
    1f7c:	5e                   	pop    %esi
    1f7d:	5f                   	pop    %edi
    1f7e:	5d                   	pop    %ebp
    1f7f:	c3                   	ret    

00001f80 <test_cow_in_child>:
static TestResult test_cow_in_child(struct cow_test_info *info) {
    1f80:	55                   	push   %ebp
    1f81:	89 e5                	mov    %esp,%ebp
    1f83:	53                   	push   %ebx
    1f84:	83 ec 24             	sub    $0x24,%esp
    1f87:	89 c3                	mov    %eax,%ebx
    info->pre_fork_p = 1;
    1f89:	c7 40 6c 01 00 00 00 	movl   $0x1,0x6c(%eax)
    _init_pipes(&pipes);
    1f90:	8d 45 e8             	lea    -0x18(%ebp),%eax
    1f93:	e8 9d e7 ff ff       	call   735 <_init_pipes>
    int pid = fork();
    1f98:	e8 95 10 00 00       	call   3032 <fork>
    if (pid == -1) {
    1f9d:	83 f8 ff             	cmp    $0xffffffff,%eax
    1fa0:	75 0a                	jne    1fac <test_cow_in_child+0x2c>
        CRASH("error from fork()");
    1fa2:	b8 ba 34 00 00       	mov    $0x34ba,%eax
    1fa7:	e8 20 e1 ff ff       	call   cc <CRASH>
    } else if (pid == 0) {
    1fac:	85 c0                	test   %eax,%eax
    1fae:	75 2f                	jne    1fdf <test_cow_in_child+0x5f>
        _pipe_sync_setup_child(&pipes);
    1fb0:	8d 45 e8             	lea    -0x18(%ebp),%eax
    1fb3:	e8 29 e8 ff ff       	call   7e1 <_pipe_sync_setup_child>
        int result = test_cow(info);
    1fb8:	89 d8                	mov    %ebx,%eax
    1fba:	e8 80 fe ff ff       	call   1e3f <test_cow>
    1fbf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        _pipe_send_child(&pipes, &result, 1);
    1fc2:	b9 01 00 00 00       	mov    $0x1,%ecx
    1fc7:	8d 55 e4             	lea    -0x1c(%ebp),%edx
    1fca:	8d 45 e8             	lea    -0x18(%ebp),%eax
    1fcd:	e8 ac e0 ff ff       	call   7e <_pipe_send_child>
        _pipe_sync_cleanup(&pipes);
    1fd2:	8d 45 e8             	lea    -0x18(%ebp),%eax
    1fd5:	e8 b9 e7 ff ff       	call   793 <_pipe_sync_cleanup>
        exit();
    1fda:	e8 5b 10 00 00       	call   303a <exit>
        int count = 1;
    1fdf:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
        int result = TR_FAIL_UNKNOWN;
    1fe6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
        _pipe_sync_setup_parent(&pipes);
    1fed:	8d 45 e8             	lea    -0x18(%ebp),%eax
    1ff0:	e8 c3 e8 ff ff       	call   8b8 <_pipe_sync_setup_parent>
        _pipe_recv_parent(&pipes, &result, &count);
    1ff5:	8d 4d e0             	lea    -0x20(%ebp),%ecx
    1ff8:	8d 55 e4             	lea    -0x1c(%ebp),%edx
    1ffb:	8d 45 e8             	lea    -0x18(%ebp),%eax
    1ffe:	e8 4e e1 ff ff       	call   151 <_pipe_recv_parent>
        _pipe_sync_cleanup(&pipes);
    2003:	8d 45 e8             	lea    -0x18(%ebp),%eax
    2006:	e8 88 e7 ff ff       	call   793 <_pipe_sync_cleanup>
        wait();
    200b:	e8 32 10 00 00       	call   3042 <wait>
}
    2010:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    2013:	83 c4 24             	add    $0x24,%esp
    2016:	5b                   	pop    %ebx
    2017:	5d                   	pop    %ebp
    2018:	c3                   	ret    

00002019 <_test_allocation_parent>:
int _test_allocation_parent(int child_pid, struct alloc_test_info *info) {
    2019:	55                   	push   %ebp
    201a:	89 e5                	mov    %esp,%ebp
    201c:	56                   	push   %esi
    201d:	53                   	push   %ebx
    201e:	83 ec 20             	sub    $0x20,%esp
    2021:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    uint orig_heap_end = (uint) sbrk(0);
    2024:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    202b:	e8 92 10 00 00       	call   30c2 <sbrk>
    2030:	89 c6                	mov    %eax,%esi
    if (!_pipe_sync_parent(&info->pipes)) return TR_FAIL_SYNC;
    2032:	89 d8                	mov    %ebx,%eax
    2034:	e8 b6 e0 ff ff       	call   ef <_pipe_sync_parent>
    2039:	85 c0                	test   %eax,%eax
    203b:	0f 84 ee 00 00 00    	je     212f <_test_allocation_parent+0x116>
    if (!_pipe_sync_parent(&info->pipes)) return TR_FAIL_SYNC;
    2041:	89 d8                	mov    %ebx,%eax
    2043:	e8 a7 e0 ff ff       	call   ef <_pipe_sync_parent>
    2048:	85 c0                	test   %eax,%eax
    204a:	0f 84 e6 00 00 00    	je     2136 <_test_allocation_parent+0x11d>
    if (!_pipe_sync_parent(&info->pipes)) return TR_FAIL_SYNC;
    2050:	89 d8                	mov    %ebx,%eax
    2052:	e8 98 e0 ff ff       	call   ef <_pipe_sync_parent>
    2057:	85 c0                	test   %eax,%eax
    2059:	0f 84 de 00 00 00    	je     213d <_test_allocation_parent+0x124>
    if (!_pipe_sync_parent(&info->pipes)) return TR_FAIL_SYNC;
    205f:	89 d8                	mov    %ebx,%eax
    2061:	e8 89 e0 ff ff       	call   ef <_pipe_sync_parent>
    2066:	85 c0                	test   %eax,%eax
    2068:	0f 84 d6 00 00 00    	je     2144 <_test_allocation_parent+0x12b>
    clear_saved_ppns();
    206e:	e8 9c df ff ff       	call   f <clear_saved_ppns>
    if (!info->skip_free_check) {
    2073:	83 7b 30 00          	cmpl   $0x0,0x30(%ebx)
    2077:	75 19                	jne    2092 <_test_allocation_parent+0x79>
        save_ppns(child_pid, orig_heap_end + info->read_start, orig_heap_end + info->read_end, 0);
    2079:	89 f1                	mov    %esi,%ecx
    207b:	03 4b 20             	add    0x20(%ebx),%ecx
    207e:	89 f2                	mov    %esi,%edx
    2080:	03 53 1c             	add    0x1c(%ebx),%edx
    2083:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    208a:	8b 45 08             	mov    0x8(%ebp),%eax
    208d:	e8 c6 e1 ff ff       	call   258 <save_ppns>
    if (!_pipe_sync_parent(&info->pipes)) return TR_FAIL_SYNC;
    2092:	89 d8                	mov    %ebx,%eax
    2094:	e8 56 e0 ff ff       	call   ef <_pipe_sync_parent>
    2099:	85 c0                	test   %eax,%eax
    209b:	0f 84 aa 00 00 00    	je     214b <_test_allocation_parent+0x132>
    if (!_pipe_sync_parent(&info->pipes)) return TR_FAIL_SYNC;
    20a1:	89 d8                	mov    %ebx,%eax
    20a3:	e8 47 e0 ff ff       	call   ef <_pipe_sync_parent>
    20a8:	85 c0                	test   %eax,%eax
    20aa:	0f 84 a2 00 00 00    	je     2152 <_test_allocation_parent+0x139>
    if (!info->skip_free_check) {
    20b0:	83 7b 30 00          	cmpl   $0x0,0x30(%ebx)
    20b4:	75 19                	jne    20cf <_test_allocation_parent+0xb6>
        save_ppns(child_pid, orig_heap_end + info->write_start, orig_heap_end + info->write_end, 0);
    20b6:	89 f1                	mov    %esi,%ecx
    20b8:	03 4b 18             	add    0x18(%ebx),%ecx
    20bb:	89 f2                	mov    %esi,%edx
    20bd:	03 53 14             	add    0x14(%ebx),%edx
    20c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    20c7:	8b 45 08             	mov    0x8(%ebp),%eax
    20ca:	e8 89 e1 ff ff       	call   258 <save_ppns>
    int result = TR_FAIL_SYNC;
    20cf:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    int count = 1;
    20d6:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    _pipe_recv_parent(&info->pipes, &result, &count);
    20dd:	8d 4d f0             	lea    -0x10(%ebp),%ecx
    20e0:	8d 55 f4             	lea    -0xc(%ebp),%edx
    20e3:	89 d8                	mov    %ebx,%eax
    20e5:	e8 67 e0 ff ff       	call   151 <_pipe_recv_parent>
    wait();
    20ea:	e8 53 0f 00 00       	call   3042 <wait>
    if (!info->skip_free_check) {
    20ef:	83 7b 30 00          	cmpl   $0x0,0x30(%ebx)
    20f3:	75 0e                	jne    2103 <_test_allocation_parent+0xea>
        if (!verify_ppns_freed("page that should have been allocated because of heap read/write in now-exited child process")) {
    20f5:	b8 98 47 00 00       	mov    $0x4798,%eax
    20fa:	e8 2f e3 ff ff       	call   42e <verify_ppns_freed>
    20ff:	85 c0                	test   %eax,%eax
    2101:	74 56                	je     2159 <_test_allocation_parent+0x140>
    if (!info->skip_pte_check) {
    2103:	83 7b 34 00          	cmpl   $0x0,0x34(%ebx)
    2107:	75 21                	jne    212a <_test_allocation_parent+0x111>
            _sanity_check_self_nonheap(info->skip_free_check ? NO_FREE_CHECK : WITH_FREE_CHECK)
    2109:	83 7b 30 00          	cmpl   $0x0,0x30(%ebx)
    210d:	0f 95 c0             	setne  %al
    2110:	0f b6 c0             	movzbl %al,%eax
    2113:	e8 a4 e5 ff ff       	call   6bc <_sanity_check_self_nonheap>
        result = max(
    2118:	89 44 24 04          	mov    %eax,0x4(%esp)
    211c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    211f:	89 04 24             	mov    %eax,(%esp)
    2122:	e8 5c f0 ff ff       	call   1183 <max>
    2127:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return result;
    212a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    212d:	eb 2f                	jmp    215e <_test_allocation_parent+0x145>
    if (!_pipe_sync_parent(&info->pipes)) return TR_FAIL_SYNC;
    212f:	b8 01 00 00 00       	mov    $0x1,%eax
    2134:	eb 28                	jmp    215e <_test_allocation_parent+0x145>
    if (!_pipe_sync_parent(&info->pipes)) return TR_FAIL_SYNC;
    2136:	b8 01 00 00 00       	mov    $0x1,%eax
    213b:	eb 21                	jmp    215e <_test_allocation_parent+0x145>
    if (!_pipe_sync_parent(&info->pipes)) return TR_FAIL_SYNC;
    213d:	b8 01 00 00 00       	mov    $0x1,%eax
    2142:	eb 1a                	jmp    215e <_test_allocation_parent+0x145>
    if (!_pipe_sync_parent(&info->pipes)) return TR_FAIL_SYNC;
    2144:	b8 01 00 00 00       	mov    $0x1,%eax
    2149:	eb 13                	jmp    215e <_test_allocation_parent+0x145>
    if (!_pipe_sync_parent(&info->pipes)) return TR_FAIL_SYNC;
    214b:	b8 01 00 00 00       	mov    $0x1,%eax
    2150:	eb 0c                	jmp    215e <_test_allocation_parent+0x145>
    if (!_pipe_sync_parent(&info->pipes)) return TR_FAIL_SYNC;
    2152:	b8 01 00 00 00       	mov    $0x1,%eax
    2157:	eb 05                	jmp    215e <_test_allocation_parent+0x145>
            return TR_FAIL_NO_FREE;
    2159:	b8 08 00 00 00       	mov    $0x8,%eax
}
    215e:	83 c4 20             	add    $0x20,%esp
    2161:	5b                   	pop    %ebx
    2162:	5e                   	pop    %esi
    2163:	5d                   	pop    %ebp
    2164:	c3                   	ret    

00002165 <zero_if_negative>:
int zero_if_negative(int x) {
    2165:	55                   	push   %ebp
    2166:	89 e5                	mov    %esp,%ebp
    2168:	8b 45 08             	mov    0x8(%ebp),%eax
    if (x < 0)
    216b:	85 c0                	test   %eax,%eax
    216d:	79 05                	jns    2174 <zero_if_negative+0xf>
        return 0;
    216f:	b8 00 00 00 00       	mov    $0x0,%eax
}
    2174:	5d                   	pop    %ebp
    2175:	c3                   	ret    

00002176 <test_allocation>:
TestResult test_allocation(int fork_p, struct alloc_test_info *info) {
    2176:	55                   	push   %ebp
    2177:	89 e5                	mov    %esp,%ebp
    2179:	57                   	push   %edi
    217a:	56                   	push   %esi
    217b:	53                   	push   %ebx
    217c:	83 ec 4c             	sub    $0x4c,%esp
    217f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (info->skip_pte_check)
    2182:	83 7b 34 00          	cmpl   $0x0,0x34(%ebx)
    2186:	74 07                	je     218f <test_allocation+0x19>
        info->skip_free_check = 1;
    2188:	c7 43 30 01 00 00 00 	movl   $0x1,0x30(%ebx)
    if (info->write_end > info->alloc_size) {
    218f:	8b 43 10             	mov    0x10(%ebx),%eax
    2192:	39 43 18             	cmp    %eax,0x18(%ebx)
    2195:	7e 1e                	jle    21b5 <test_allocation+0x3f>
        printf(1, "ERROR: write_end after end of allocation\n");
    2197:	c7 44 24 04 54 48 00 	movl   $0x4854,0x4(%esp)
    219e:	00 
    219f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21a6:	e8 01 10 00 00       	call   31ac <printf>
        return TR_FAIL_PARAM;
    21ab:	b8 09 00 00 00       	mov    $0x9,%eax
    21b0:	e9 1d 02 00 00       	jmp    23d2 <test_allocation+0x25c>
    if (info->read_end > info->alloc_size) {
    21b5:	3b 43 20             	cmp    0x20(%ebx),%eax
    21b8:	7d 1e                	jge    21d8 <test_allocation+0x62>
        printf(1, "ERROR: read_end after end of allocation\n");
    21ba:	c7 44 24 04 80 48 00 	movl   $0x4880,0x4(%esp)
    21c1:	00 
    21c2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21c9:	e8 de 0f 00 00       	call   31ac <printf>
        return TR_FAIL_PARAM;
    21ce:	b8 09 00 00 00       	mov    $0x9,%eax
    21d3:	e9 fa 01 00 00       	jmp    23d2 <test_allocation+0x25c>
    if (info->read_start < 0 || info->write_start < 0) {
    21d8:	83 7b 1c 00          	cmpl   $0x0,0x1c(%ebx)
    21dc:	78 06                	js     21e4 <test_allocation+0x6e>
    21de:	83 7b 14 00          	cmpl   $0x0,0x14(%ebx)
    21e2:	79 1e                	jns    2202 <test_allocation+0x8c>
        printf(1, "ERROR: negative offset\n");
    21e4:	c7 44 24 04 6b 35 00 	movl   $0x356b,0x4(%esp)
    21eb:	00 
    21ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21f3:	e8 b4 0f 00 00       	call   31ac <printf>
        return TR_FAIL_PARAM;
    21f8:	b8 09 00 00 00       	mov    $0x9,%eax
    21fd:	e9 d0 01 00 00       	jmp    23d2 <test_allocation+0x25c>
    printf(1, "Testing allocating 0x%x bytes of memory%s\n",
    2202:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
    2206:	74 07                	je     220f <test_allocation+0x99>
    2208:	ba 43 35 00 00       	mov    $0x3543,%edx
    220d:	eb 05                	jmp    2214 <test_allocation+0x9e>
    220f:	ba 8c 33 00 00       	mov    $0x338c,%edx
    2214:	89 54 24 0c          	mov    %edx,0xc(%esp)
    2218:	89 44 24 08          	mov    %eax,0x8(%esp)
    221c:	c7 44 24 04 ac 48 00 	movl   $0x48ac,0x4(%esp)
    2223:	00 
    2224:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    222b:	e8 7c 0f 00 00       	call   31ac <printf>
    if (!info->skip_pte_check) {
    2230:	83 7b 34 00          	cmpl   $0x0,0x34(%ebx)
    2234:	75 2a                	jne    2260 <test_allocation+0xea>
        printf(1, "  checking page table entry flags%s\n"
    2236:	83 7b 30 00          	cmpl   $0x0,0x30(%ebx)
    223a:	74 07                	je     2243 <test_allocation+0xcd>
    223c:	b8 8c 33 00 00       	mov    $0x338c,%eax
    2241:	eb 05                	jmp    2248 <test_allocation+0xd2>
    2243:	b8 f4 47 00 00       	mov    $0x47f4,%eax
    2248:	89 44 24 08          	mov    %eax,0x8(%esp)
    224c:	c7 44 24 04 d8 48 00 	movl   $0x48d8,0x4(%esp)
    2253:	00 
    2254:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    225b:	e8 4c 0f 00 00       	call   31ac <printf>
    printf(1, "  reading 0x%x bytes from offsets 0x%x through 0x%x\n"
    2260:	83 7b 24 00          	cmpl   $0x0,0x24(%ebx)
    2264:	74 09                	je     226f <test_allocation+0xf9>
    2266:	c7 45 e0 57 35 00 00 	movl   $0x3557,-0x20(%ebp)
    226d:	eb 07                	jmp    2276 <test_allocation+0x100>
    226f:	c7 45 e0 8c 33 00 00 	movl   $0x338c,-0x20(%ebp)
              zero_if_negative(info->write_end - info->write_start),
    2276:	8b 7b 18             	mov    0x18(%ebx),%edi
    2279:	8b 73 14             	mov    0x14(%ebx),%esi
    printf(1, "  reading 0x%x bytes from offsets 0x%x through 0x%x\n"
    227c:	89 f8                	mov    %edi,%eax
    227e:	29 f0                	sub    %esi,%eax
    2280:	89 04 24             	mov    %eax,(%esp)
    2283:	e8 dd fe ff ff       	call   2165 <zero_if_negative>
    2288:	89 45 dc             	mov    %eax,-0x24(%ebp)
              zero_if_negative(info->read_end - info->read_start),
    228b:	8b 4b 20             	mov    0x20(%ebx),%ecx
    228e:	8b 53 1c             	mov    0x1c(%ebx),%edx
    printf(1, "  reading 0x%x bytes from offsets 0x%x through 0x%x\n"
    2291:	89 4d d8             	mov    %ecx,-0x28(%ebp)
    2294:	89 c8                	mov    %ecx,%eax
    2296:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    2299:	29 d0                	sub    %edx,%eax
    229b:	89 04 24             	mov    %eax,(%esp)
    229e:	e8 c2 fe ff ff       	call   2165 <zero_if_negative>
    22a3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
    22a6:	89 4c 24 20          	mov    %ecx,0x20(%esp)
    22aa:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
    22ae:	89 74 24 18          	mov    %esi,0x18(%esp)
    22b2:	8b 7d dc             	mov    -0x24(%ebp),%edi
    22b5:	89 7c 24 14          	mov    %edi,0x14(%esp)
    22b9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
    22bc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
    22c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
    22c3:	89 54 24 0c          	mov    %edx,0xc(%esp)
    22c7:	89 44 24 08          	mov    %eax,0x8(%esp)
    22cb:	c7 44 24 04 34 49 00 	movl   $0x4934,0x4(%esp)
    22d2:	00 
    22d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    22da:	e8 cd 0e 00 00       	call   31ac <printf>
    if (info->fork_after_alloc) {
    22df:	83 7b 28 00          	cmpl   $0x0,0x28(%ebx)
    22e3:	74 14                	je     22f9 <test_allocation+0x183>
        printf(1, "  forking a grandchild process to make sure fork()\n"
    22e5:	c7 44 24 04 a0 49 00 	movl   $0x49a0,0x4(%esp)
    22ec:	00 
    22ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    22f4:	e8 b3 0e 00 00       	call   31ac <printf>
    if (fork_p && !info->skip_free_check) {
    22f9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
    22fd:	74 1a                	je     2319 <test_allocation+0x1a3>
    22ff:	83 7b 30 00          	cmpl   $0x0,0x30(%ebx)
    2303:	75 14                	jne    2319 <test_allocation+0x1a3>
        printf(1, "  checking that sample of allocated pages are free after\n"
    2305:	c7 44 24 04 00 4a 00 	movl   $0x4a00,0x4(%esp)
    230c:	00 
    230d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2314:	e8 93 0e 00 00       	call   31ac <printf>
    if (fork_p) {
    2319:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
    231d:	74 6a                	je     2389 <test_allocation+0x213>
        _init_pipes(&info->pipes);
    231f:	89 d8                	mov    %ebx,%eax
    2321:	e8 0f e4 ff ff       	call   735 <_init_pipes>
        int child_pid = fork();
    2326:	e8 07 0d 00 00       	call   3032 <fork>
    232b:	89 c6                	mov    %eax,%esi
        if (child_pid == -1) {
    232d:	83 f8 ff             	cmp    $0xffffffff,%eax
    2330:	0f 84 97 00 00 00    	je     23cd <test_allocation+0x257>
        } else if (child_pid == 0) {
    2336:	85 c0                	test   %eax,%eax
    2338:	75 0c                	jne    2346 <test_allocation+0x1d0>
            _test_allocation_child(info);
    233a:	89 d8                	mov    %ebx,%eax
    233c:	e8 53 ee ff ff       	call   1194 <_test_allocation_child>
            exit();
    2341:	e8 f4 0c 00 00       	call   303a <exit>
            int result = _test_allocation_parent(child_pid, info);
    2346:	89 5c 24 04          	mov    %ebx,0x4(%esp)
    234a:	89 04 24             	mov    %eax,(%esp)
    234d:	e8 c7 fc ff ff       	call   2019 <_test_allocation_parent>
    2352:	89 c7                	mov    %eax,%edi
            _pipe_sync_cleanup(&info->pipes);
    2354:	89 d8                	mov    %ebx,%eax
    2356:	e8 38 e4 ff ff       	call   793 <_pipe_sync_cleanup>
            if (result == TR_FAIL_SYNC) {
    235b:	83 ff 01             	cmp    $0x1,%edi
    235e:	75 0d                	jne    236d <test_allocation+0x1f7>
                kill(child_pid);
    2360:	89 34 24             	mov    %esi,(%esp)
    2363:	e8 02 0d 00 00       	call   306a <kill>
                wait();
    2368:	e8 d5 0c 00 00       	call   3042 <wait>
            if (result == TR_SUCCESS) {
    236d:	85 ff                	test   %edi,%edi
    236f:	75 14                	jne    2385 <test_allocation+0x20f>
                printf(1, "Test successful.\n");
    2371:	c7 44 24 04 4b 33 00 	movl   $0x334b,0x4(%esp)
    2378:	00 
    2379:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2380:	e8 27 0e 00 00       	call   31ac <printf>
            return result;
    2385:	89 f8                	mov    %edi,%eax
    2387:	eb 49                	jmp    23d2 <test_allocation+0x25c>
        info->pipes = NO_PIPES;
    2389:	a1 f4 52 00 00       	mov    0x52f4,%eax
    238e:	89 03                	mov    %eax,(%ebx)
    2390:	a1 f8 52 00 00       	mov    0x52f8,%eax
    2395:	89 43 04             	mov    %eax,0x4(%ebx)
    2398:	a1 fc 52 00 00       	mov    0x52fc,%eax
    239d:	89 43 08             	mov    %eax,0x8(%ebx)
    23a0:	a1 00 53 00 00       	mov    0x5300,%eax
    23a5:	89 43 0c             	mov    %eax,0xc(%ebx)
        int result = _test_allocation_child(info);
    23a8:	89 d8                	mov    %ebx,%eax
    23aa:	e8 e5 ed ff ff       	call   1194 <_test_allocation_child>
    23af:	89 c3                	mov    %eax,%ebx
        if (result == TR_SUCCESS) {
    23b1:	85 c0                	test   %eax,%eax
    23b3:	75 14                	jne    23c9 <test_allocation+0x253>
            printf(1, "Test successful.\n");
    23b5:	c7 44 24 04 4b 33 00 	movl   $0x334b,0x4(%esp)
    23bc:	00 
    23bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    23c4:	e8 e3 0d 00 00       	call   31ac <printf>
        return result;
    23c9:	89 d8                	mov    %ebx,%eax
    23cb:	eb 05                	jmp    23d2 <test_allocation+0x25c>
            return TR_FAIL_FORK;
    23cd:	b8 07 00 00 00       	mov    $0x7,%eax
}
    23d2:	83 c4 4c             	add    $0x4c,%esp
    23d5:	5b                   	pop    %ebx
    23d6:	5e                   	pop    %esi
    23d7:	5f                   	pop    %edi
    23d8:	5d                   	pop    %ebp
    23d9:	c3                   	ret    

000023da <setup>:

static char *new_args[20];
static char input_buffer[200];

MAYBE_UNUSED
void setup(int *pargc, char ***pargv) {
    23da:	55                   	push   %ebp
    23db:	89 e5                	mov    %esp,%ebp
    23dd:	56                   	push   %esi
    23de:	53                   	push   %ebx
    23df:	83 ec 10             	sub    $0x10,%esp
    23e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
    23e5:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (pargc) {
    23e8:	85 db                	test   %ebx,%ebx
    23ea:	74 09                	je     23f5 <setup+0x1b>
        real_argv0 = (*pargv)[0];
    23ec:	8b 06                	mov    (%esi),%eax
    23ee:	8b 00                	mov    (%eax),%eax
    23f0:	a3 60 74 00 00       	mov    %eax,0x7460
    }
    if (pargc && *pargc > 1 && 0 == strcmp((*pargv)[1], "__TEST_CHILD__")) {
    23f5:	85 db                	test   %ebx,%ebx
    23f7:	74 2a                	je     2423 <setup+0x49>
    23f9:	83 3b 01             	cmpl   $0x1,(%ebx)
    23fc:	7e 25                	jle    2423 <setup+0x49>
    23fe:	8b 06                	mov    (%esi),%eax
    2400:	c7 44 24 04 0c 34 00 	movl   $0x340c,0x4(%esp)
    2407:	00 
    2408:	8b 40 04             	mov    0x4(%eax),%eax
    240b:	89 04 24             	mov    %eax,(%esp)
    240e:	e8 a4 0a 00 00       	call   2eb7 <strcmp>
    2413:	85 c0                	test   %eax,%eax
    2415:	75 0c                	jne    2423 <setup+0x49>
        _test_exec_child(*pargv);
    2417:	8b 06                	mov    (%esi),%eax
    2419:	e8 f6 e3 ff ff       	call   814 <_test_exec_child>
        exit();
    241e:	e8 17 0c 00 00       	call   303a <exit>
    }
    if (getpid() == 1) {
    2423:	e8 92 0c 00 00       	call   30ba <getpid>
    2428:	83 f8 01             	cmp    $0x1,%eax
    242b:	0f 85 ec 00 00 00    	jne    251d <setup+0x143>
        mknod("console", 1, 1);
    2431:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    2438:	00 
    2439:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
    2440:	00 
    2441:	c7 04 24 83 35 00 00 	movl   $0x3583,(%esp)
    2448:	e8 35 0c 00 00       	call   3082 <mknod>
        open("console", O_RDWR);
    244d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    2454:	00 
    2455:	c7 04 24 83 35 00 00 	movl   $0x3583,(%esp)
    245c:	e8 19 0c 00 00       	call   307a <open>
        dup(0);
    2461:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2468:	e8 45 0c 00 00       	call   30b2 <dup>
        dup(0);
    246d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2474:	e8 39 0c 00 00       	call   30b2 <dup>
        if (want_args && pargc != 0) {
    2479:	85 db                	test   %ebx,%ebx
    247b:	0f 84 9c 00 00 00    	je     251d <setup+0x143>
            printf(1, "Enter arguments (-help for usage info): ");
    2481:	c7 44 24 04 98 4a 00 	movl   $0x4a98,0x4(%esp)
    2488:	00 
    2489:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2490:	e8 17 0d 00 00       	call   31ac <printf>
            gets(input_buffer, sizeof input_buffer - 1);
    2495:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
    249c:	00 
    249d:	c7 04 24 20 53 00 00 	movl   $0x5320,(%esp)
    24a4:	e8 86 0a 00 00       	call   2f2f <gets>
            input_buffer[strlen(input_buffer) - 1] = '\0';
    24a9:	c7 04 24 20 53 00 00 	movl   $0x5320,(%esp)
    24b0:	e8 28 0a 00 00       	call   2edd <strlen>
    24b5:	c6 80 1f 53 00 00 00 	movb   $0x0,0x531f(%eax)
            char *p = input_buffer;
            new_args[0] = "AS-INIT";
    24bc:	c7 05 00 54 00 00 6b 	movl   $0x336b,0x5400
    24c3:	33 00 00 
            *pargc = 1;
    24c6:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
            char *p = input_buffer;
    24cc:	b8 20 53 00 00       	mov    $0x5320,%eax
            do {
                new_args[*pargc] = p;
    24d1:	8b 13                	mov    (%ebx),%edx
    24d3:	89 04 95 00 54 00 00 	mov    %eax,0x5400(,%edx,4)
                p = strchr(p, ' ');
    24da:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
    24e1:	00 
    24e2:	89 04 24             	mov    %eax,(%esp)
    24e5:	e8 24 0a 00 00       	call   2f0e <strchr>
                if (p) {
    24ea:	85 c0                	test   %eax,%eax
    24ec:	74 0b                	je     24f9 <setup+0x11f>
                    *p = '\0';
    24ee:	c6 00 00             	movb   $0x0,(%eax)
                    p += 1;
    24f1:	83 c0 01             	add    $0x1,%eax
                    *pargc += 1;
    24f4:	83 03 01             	addl   $0x1,(%ebx)
    24f7:	eb 03                	jmp    24fc <setup+0x122>
                } else {
                    *pargc += 1;
    24f9:	83 03 01             	addl   $0x1,(%ebx)
                }
            } while (p != 0 && *pargc + 1 < sizeof(new_args)/sizeof(new_args[0]));
    24fc:	85 c0                	test   %eax,%eax
    24fe:	74 0a                	je     250a <setup+0x130>
    2500:	8b 0b                	mov    (%ebx),%ecx
    2502:	8d 51 01             	lea    0x1(%ecx),%edx
    2505:	83 fa 13             	cmp    $0x13,%edx
    2508:	76 c7                	jbe    24d1 <setup+0xf7>
            new_args[*pargc] = 0;
    250a:	8b 03                	mov    (%ebx),%eax
    250c:	c7 04 85 00 54 00 00 	movl   $0x0,0x5400(,%eax,4)
    2513:	00 00 00 00 
            *pargv = new_args;
    2517:	c7 06 00 54 00 00    	movl   $0x5400,(%esi)
        }
    }
}
    251d:	83 c4 10             	add    $0x10,%esp
    2520:	5b                   	pop    %ebx
    2521:	5e                   	pop    %esi
    2522:	5d                   	pop    %ebp
    2523:	c3                   	ret    

00002524 <cleanup>:

MAYBE_UNUSED
void cleanup() {
    2524:	55                   	push   %ebp
    2525:	89 e5                	mov    %esp,%ebp
    2527:	83 ec 08             	sub    $0x8,%esp
    if (getpid() == 1) {
    252a:	e8 8b 0b 00 00       	call   30ba <getpid>
    252f:	83 f8 01             	cmp    $0x1,%eax
    2532:	75 07                	jne    253b <cleanup+0x17>
        shutdown();
    2534:	e8 c1 0b 00 00       	call   30fa <shutdown>
    2539:	eb 0a                	jmp    2545 <cleanup+0x21>
    253b:	90                   	nop
    253c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    } else {
        exit();
    2540:	e8 f5 0a 00 00       	call   303a <exit>
    }
}
    2545:	c9                   	leave  
    2546:	c3                   	ret    

00002547 <getopt>:
void getopt(int argc, char **argv, struct option *options) {
    2547:	55                   	push   %ebp
    2548:	89 e5                	mov    %esp,%ebp
    254a:	57                   	push   %edi
    254b:	56                   	push   %esi
    254c:	53                   	push   %ebx
    254d:	83 ec 2c             	sub    $0x2c,%esp
    2550:	89 45 dc             	mov    %eax,-0x24(%ebp)
    2553:	89 55 e0             	mov    %edx,-0x20(%ebp)
    2556:	89 4d d8             	mov    %ecx,-0x28(%ebp)
    for (int i = 1; i < argc; i += 1) {
    2559:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
    2560:	e9 0c 01 00 00       	jmp    2671 <getopt+0x12a>
        const char *p = argv[i];
    2565:	8b 45 e0             	mov    -0x20(%ebp),%eax
    2568:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
    256b:	8b 04 88             	mov    (%eax,%ecx,4),%eax
        if (*p == '-') {
    256e:	80 38 2d             	cmpb   $0x2d,(%eax)
    2571:	0f 85 d9 00 00 00    	jne    2650 <getopt+0x109>
            p += 1;
    2577:	8d 78 01             	lea    0x1(%eax),%edi
            if (*p == '-') {
    257a:	80 78 01 2d          	cmpb   $0x2d,0x1(%eax)
    257e:	75 03                	jne    2583 <getopt+0x3c>
                p += 1;
    2580:	8d 78 02             	lea    0x2(%eax),%edi
            if (0 == strcmp("help", p)) {
    2583:	89 7c 24 04          	mov    %edi,0x4(%esp)
    2587:	c7 04 24 30 37 00 00 	movl   $0x3730,(%esp)
    258e:	e8 24 09 00 00       	call   2eb7 <strcmp>
    2593:	85 c0                	test   %eax,%eax
    2595:	75 12                	jne    25a9 <getopt+0x62>
                getopt_usage(argv[0], options);
    2597:	8b 55 d8             	mov    -0x28(%ebp),%edx
    259a:	8b 45 e0             	mov    -0x20(%ebp),%eax
    259d:	8b 00                	mov    (%eax),%eax
    259f:	e8 03 e8 ff ff       	call   da7 <getopt_usage>
                cleanup();
    25a4:	e8 7b ff ff ff       	call   2524 <cleanup>
            for (struct option *option = options; option->name; option += 1) {
    25a9:	8b 75 d8             	mov    -0x28(%ebp),%esi
    25ac:	eb 74                	jmp    2622 <getopt+0xdb>
                if (strprefix(option->name, p)) {
    25ae:	89 7c 24 04          	mov    %edi,0x4(%esp)
    25b2:	89 1c 24             	mov    %ebx,(%esp)
    25b5:	e8 92 eb ff ff       	call   114c <strprefix>
    25ba:	85 c0                	test   %eax,%eax
    25bc:	74 61                	je     261f <getopt+0xd8>
                    int option_len = strlen(option->name);
    25be:	89 1c 24             	mov    %ebx,(%esp)
    25c1:	e8 17 09 00 00       	call   2edd <strlen>
                    if (option->boolean) {
    25c6:	83 7e 0c 00          	cmpl   $0x0,0xc(%esi)
    25ca:	74 16                	je     25e2 <getopt+0x9b>
                        if (p[option_len] != '\0')
    25cc:	80 3c 07 00          	cmpb   $0x0,(%edi,%eax,1)
    25d0:	75 4d                	jne    261f <getopt+0xd8>
                        *option->value = 1;
    25d2:	8b 46 08             	mov    0x8(%esi),%eax
    25d5:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
                    found = 1;
    25db:	b8 01 00 00 00       	mov    $0x1,%eax
    25e0:	eb 4b                	jmp    262d <getopt+0xe6>
                        if (p[option_len] != '=') {
    25e2:	80 3c 07 3d          	cmpb   $0x3d,(%edi,%eax,1)
    25e6:	74 1f                	je     2607 <getopt+0xc0>
                            printf(2, "expected '=' after '-%s'\n", option->name);
    25e8:	8b 06                	mov    (%esi),%eax
    25ea:	89 44 24 08          	mov    %eax,0x8(%esp)
    25ee:	c7 44 24 04 8b 35 00 	movl   $0x358b,0x4(%esp)
    25f5:	00 
    25f6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    25fd:	e8 aa 0b 00 00       	call   31ac <printf>
                            exit();
    2602:	e8 33 0a 00 00       	call   303a <exit>
                        *option->value = decorhextoi(p + option_len + 1);
    2607:	8b 5e 08             	mov    0x8(%esi),%ebx
    260a:	8d 44 07 01          	lea    0x1(%edi,%eax,1),%eax
    260e:	89 04 24             	mov    %eax,(%esp)
    2611:	e8 b2 ea ff ff       	call   10c8 <decorhextoi>
    2616:	89 03                	mov    %eax,(%ebx)
                    found = 1;
    2618:	b8 01 00 00 00       	mov    $0x1,%eax
    261d:	eb 0e                	jmp    262d <getopt+0xe6>
            for (struct option *option = options; option->name; option += 1) {
    261f:	83 c6 10             	add    $0x10,%esi
    2622:	8b 1e                	mov    (%esi),%ebx
    2624:	85 db                	test   %ebx,%ebx
    2626:	75 86                	jne    25ae <getopt+0x67>
            int found = 0;
    2628:	b8 00 00 00 00       	mov    $0x0,%eax
            if (!found) {
    262d:	85 c0                	test   %eax,%eax
    262f:	75 3c                	jne    266d <getopt+0x126>
                printf(2, "unrecognized option '-%s'\n", p);
    2631:	89 7c 24 08          	mov    %edi,0x8(%esp)
    2635:	c7 44 24 04 a5 35 00 	movl   $0x35a5,0x4(%esp)
    263c:	00 
    263d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2644:	e8 63 0b 00 00       	call   31ac <printf>
                cleanup();
    2649:	e8 d6 fe ff ff       	call   2524 <cleanup>
    264e:	eb 1d                	jmp    266d <getopt+0x126>
            printf(2, "unrecogonized argument '%s'\n", p);
    2650:	89 44 24 08          	mov    %eax,0x8(%esp)
    2654:	c7 44 24 04 c0 35 00 	movl   $0x35c0,0x4(%esp)
    265b:	00 
    265c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2663:	e8 44 0b 00 00       	call   31ac <printf>
            cleanup();
    2668:	e8 b7 fe ff ff       	call   2524 <cleanup>
    for (int i = 1; i < argc; i += 1) {
    266d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
    2671:	8b 45 dc             	mov    -0x24(%ebp),%eax
    2674:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
    2677:	0f 8c e8 fe ff ff    	jl     2565 <getopt+0x1e>
}
    267d:	83 c4 2c             	add    $0x2c,%esp
    2680:	5b                   	pop    %ebx
    2681:	5e                   	pop    %esi
    2682:	5f                   	pop    %edi
    2683:	5d                   	pop    %ebp
    2684:	c3                   	ret    

00002685 <run_cow_test_from_args>:

MAYBE_UNUSED
int run_cow_test_from_args(int argc, char **argv) {
    2685:	55                   	push   %ebp
    2686:	89 e5                	mov    %esp,%ebp
    2688:	57                   	push   %edi
    2689:	81 ec b4 01 00 00    	sub    $0x1b4,%esp
    struct cow_test_info info = {
    268f:	8d 7d 88             	lea    -0x78(%ebp),%edi
    2692:	b8 00 00 00 00       	mov    $0x0,%eax
    2697:	b9 1c 00 00 00       	mov    $0x1c,%ecx
    269c:	f3 ab                	rep stos %eax,%es:(%edi)
    269e:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
    26a5:	c7 45 cc 00 10 00 00 	movl   $0x1000,-0x34(%ebp)
    26ac:	c6 45 d0 01          	movb   $0x1,-0x30(%ebp)
    26b0:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
    26b7:	c7 45 dc 00 02 00 00 	movl   $0x200,-0x24(%ebp)
    26be:	c7 45 e0 00 04 00 00 	movl   $0x400,-0x20(%ebp)
        .parent_write_index = -1,

        .starts[0] = 512,
        .ends[0] = 1024,
    };
    int pre_fork_p = 0;
    26c5:	c7 45 84 00 00 00 00 	movl   $0x0,-0x7c(%ebp)
    int parent_first = 0, parent_middle = 0, parent_last = 0, parent_never = 0;
    26cc:	c7 45 80 00 00 00 00 	movl   $0x0,-0x80(%ebp)
    26d3:	c7 85 7c ff ff ff 00 	movl   $0x0,-0x84(%ebp)
    26da:	00 00 00 
    26dd:	c7 85 78 ff ff ff 00 	movl   $0x0,-0x88(%ebp)
    26e4:	00 00 00 
    26e7:	c7 85 74 ff ff ff 00 	movl   $0x0,-0x8c(%ebp)
    26ee:	00 00 00 
    int no_child_write = 0, child_write_except = -1, child_write_only = -1;
    26f1:	c7 85 70 ff ff ff 00 	movl   $0x0,-0x90(%ebp)
    26f8:	00 00 00 
    26fb:	c7 85 6c ff ff ff ff 	movl   $0xffffffff,-0x94(%ebp)
    2702:	ff ff ff 
    2705:	c7 85 68 ff ff ff ff 	movl   $0xffffffff,-0x98(%ebp)
    270c:	ff ff ff 
    struct option options[] = {
    270f:	8d bd 58 fe ff ff    	lea    -0x1a8(%ebp),%edi
    2715:	b1 44                	mov    $0x44,%cl
    2717:	f3 ab                	rep stos %eax,%es:(%edi)
    2719:	c7 85 58 fe ff ff dd 	movl   $0x35dd,-0x1a8(%ebp)
    2720:	35 00 00 
    2723:	c7 85 5c fe ff ff c4 	movl   $0x4ac4,-0x1a4(%ebp)
    272a:	4a 00 00 
    272d:	8d 45 c8             	lea    -0x38(%ebp),%eax
    2730:	89 85 60 fe ff ff    	mov    %eax,-0x1a0(%ebp)
    2736:	c7 85 68 fe ff ff e3 	movl   $0x35e3,-0x198(%ebp)
    273d:	35 00 00 
    2740:	c7 85 6c fe ff ff e8 	movl   $0x4ae8,-0x194(%ebp)
    2747:	4a 00 00 
    274a:	8d 45 cc             	lea    -0x34(%ebp),%eax
    274d:	89 85 70 fe ff ff    	mov    %eax,-0x190(%ebp)
    2753:	c7 85 78 fe ff ff ce 	movl   $0x36ce,-0x188(%ebp)
    275a:	36 00 00 
    275d:	c7 85 7c fe ff ff 14 	movl   $0x4b14,-0x184(%ebp)
    2764:	4b 00 00 
    2767:	8d 45 dc             	lea    -0x24(%ebp),%eax
    276a:	89 85 80 fe ff ff    	mov    %eax,-0x180(%ebp)
    2770:	c7 85 88 fe ff ff d9 	movl   $0x36d9,-0x178(%ebp)
    2777:	36 00 00 
    277a:	c7 85 8c fe ff ff 40 	movl   $0x4b40,-0x174(%ebp)
    2781:	4b 00 00 
    2784:	8d 45 e0             	lea    -0x20(%ebp),%eax
    2787:	89 85 90 fe ff ff    	mov    %eax,-0x170(%ebp)
    278d:	c7 85 98 fe ff ff e8 	movl   $0x35e8,-0x168(%ebp)
    2794:	35 00 00 
    2797:	c7 85 9c fe ff ff 74 	movl   $0x4b74,-0x164(%ebp)
    279e:	4b 00 00 
    27a1:	8d 45 80             	lea    -0x80(%ebp),%eax
    27a4:	89 85 a0 fe ff ff    	mov    %eax,-0x160(%ebp)
    27aa:	c7 85 a4 fe ff ff 01 	movl   $0x1,-0x15c(%ebp)
    27b1:	00 00 00 
    27b4:	c7 85 a8 fe ff ff f5 	movl   $0x35f5,-0x158(%ebp)
    27bb:	35 00 00 
    27be:	c7 85 ac fe ff ff 01 	movl   $0x3601,-0x154(%ebp)
    27c5:	36 00 00 
    27c8:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
    27ce:	89 85 b0 fe ff ff    	mov    %eax,-0x150(%ebp)
    27d4:	c7 85 b4 fe ff ff 01 	movl   $0x1,-0x14c(%ebp)
    27db:	00 00 00 
    27de:	c7 85 b8 fe ff ff 18 	movl   $0x3618,-0x148(%ebp)
    27e5:	36 00 00 
    27e8:	c7 85 bc fe ff ff 98 	movl   $0x4b98,-0x144(%ebp)
    27ef:	4b 00 00 
    27f2:	8d 85 7c ff ff ff    	lea    -0x84(%ebp),%eax
    27f8:	89 85 c0 fe ff ff    	mov    %eax,-0x140(%ebp)
    27fe:	c7 85 c4 fe ff ff 01 	movl   $0x1,-0x13c(%ebp)
    2805:	00 00 00 
    2808:	c7 85 c8 fe ff ff 26 	movl   $0x3626,-0x138(%ebp)
    280f:	36 00 00 
    2812:	c7 85 cc fe ff ff 33 	movl   $0x3633,-0x134(%ebp)
    2819:	36 00 00 
    281c:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
    2822:	89 85 d0 fe ff ff    	mov    %eax,-0x130(%ebp)
    2828:	c7 85 d4 fe ff ff 01 	movl   $0x1,-0x12c(%ebp)
    282f:	00 00 00 
    2832:	c7 85 d8 fe ff ff 45 	movl   $0x3645,-0x128(%ebp)
    2839:	36 00 00 
    283c:	c7 85 dc fe ff ff cc 	movl   $0x4bcc,-0x124(%ebp)
    2843:	4b 00 00 
    2846:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
    284c:	89 85 e0 fe ff ff    	mov    %eax,-0x120(%ebp)
    2852:	c7 85 e4 fe ff ff 01 	movl   $0x1,-0x11c(%ebp)
    2859:	00 00 00 
    285c:	c7 85 e8 fe ff ff 54 	movl   $0x3654,-0x118(%ebp)
    2863:	36 00 00 
    2866:	c7 85 ec fe ff ff 04 	movl   $0x4c04,-0x114(%ebp)
    286d:	4c 00 00 
    2870:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
    2876:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
    287c:	c7 85 f8 fe ff ff 67 	movl   $0x3667,-0x108(%ebp)
    2883:	36 00 00 
    2886:	c7 85 fc fe ff ff 60 	movl   $0x4c60,-0x104(%ebp)
    288d:	4c 00 00 
    2890:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
    2896:	89 85 00 ff ff ff    	mov    %eax,-0x100(%ebp)
    289c:	c7 85 08 ff ff ff 78 	movl   $0x3678,-0xf8(%ebp)
    28a3:	36 00 00 
    28a6:	c7 85 0c ff ff ff ac 	movl   $0x4cac,-0xf4(%ebp)
    28ad:	4c 00 00 
    28b0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
    28b3:	89 85 10 ff ff ff    	mov    %eax,-0xf0(%ebp)
    28b9:	c7 85 14 ff ff ff 01 	movl   $0x1,-0xec(%ebp)
    28c0:	00 00 00 
    28c3:	c7 85 18 ff ff ff 8b 	movl   $0x368b,-0xe8(%ebp)
    28ca:	36 00 00 
    28cd:	c7 85 1c ff ff ff f0 	movl   $0x4cf0,-0xe4(%ebp)
    28d4:	4c 00 00 
    28d7:	8d 45 ec             	lea    -0x14(%ebp),%eax
    28da:	89 85 20 ff ff ff    	mov    %eax,-0xe0(%ebp)
    28e0:	c7 85 24 ff ff ff 01 	movl   $0x1,-0xdc(%ebp)
    28e7:	00 00 00 
    28ea:	c7 85 28 ff ff ff 9a 	movl   $0x369a,-0xd8(%ebp)
    28f1:	36 00 00 
    28f4:	c7 85 2c ff ff ff 74 	movl   $0x4d74,-0xd4(%ebp)
    28fb:	4d 00 00 
    28fe:	8d 45 e8             	lea    -0x18(%ebp),%eax
    2901:	89 85 30 ff ff ff    	mov    %eax,-0xd0(%ebp)
    2907:	c7 85 34 ff ff ff 01 	movl   $0x1,-0xcc(%ebp)
    290e:	00 00 00 
    2911:	c7 85 38 ff ff ff aa 	movl   $0x36aa,-0xc8(%ebp)
    2918:	36 00 00 
    291b:	c7 85 3c ff ff ff d4 	movl   $0x4dd4,-0xc4(%ebp)
    2922:	4d 00 00 
    2925:	8d 45 f0             	lea    -0x10(%ebp),%eax
    2928:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
    292e:	c7 85 44 ff ff ff 01 	movl   $0x1,-0xbc(%ebp)
    2935:	00 00 00 
    2938:	c7 85 48 ff ff ff af 	movl   $0x36af,-0xb8(%ebp)
    293f:	36 00 00 
    2942:	c7 85 4c ff ff ff 08 	movl   $0x4e08,-0xb4(%ebp)
    2949:	4e 00 00 
    294c:	8d 45 84             	lea    -0x7c(%ebp),%eax
    294f:	89 85 50 ff ff ff    	mov    %eax,-0xb0(%ebp)
    2955:	c7 85 54 ff ff ff 01 	movl   $0x1,-0xac(%ebp)
    295c:	00 00 00 
            .description = "run entire test in a child process",
            .boolean = 1,
        },
        {   .name = (char*) 0  },
    };
    getopt(argc, argv, options);
    295f:	8d 8d 58 fe ff ff    	lea    -0x1a8(%ebp),%ecx
    2965:	8b 55 0c             	mov    0xc(%ebp),%edx
    2968:	8b 45 08             	mov    0x8(%ebp),%eax
    296b:	e8 d7 fb ff ff       	call   2547 <getopt>
    if (parent_first + parent_middle + parent_last + parent_never > 1) {
    2970:	8b 45 80             	mov    -0x80(%ebp),%eax
    2973:	03 85 7c ff ff ff    	add    -0x84(%ebp),%eax
    2979:	03 85 78 ff ff ff    	add    -0x88(%ebp),%eax
    297f:	03 85 74 ff ff ff    	add    -0x8c(%ebp),%eax
    2985:	83 f8 01             	cmp    $0x1,%eax
    2988:	7e 14                	jle    299e <run_cow_test_from_args+0x319>
        printf(2, "ERROR: specify at most one of -parent-first, parent-last, -parent-middle, -parent-never\n");
    298a:	c7 44 24 04 2c 4e 00 	movl   $0x4e2c,0x4(%esp)
    2991:	00 
    2992:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2999:	e8 0e 08 00 00       	call   31ac <printf>
    }
    if (parent_first) {
    299e:	83 7d 80 00          	cmpl   $0x0,-0x80(%ebp)
    29a2:	74 09                	je     29ad <run_cow_test_from_args+0x328>
        info.parent_write_index = -1;
    29a4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
    29ab:	eb 33                	jmp    29e0 <run_cow_test_from_args+0x35b>
    } else if (parent_middle) {
    29ad:	83 bd 7c ff ff ff 00 	cmpl   $0x0,-0x84(%ebp)
    29b4:	74 09                	je     29bf <run_cow_test_from_args+0x33a>
        info.parent_write_index = 0;
    29b6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
    29bd:	eb 21                	jmp    29e0 <run_cow_test_from_args+0x35b>
    } else if (parent_last) {
    29bf:	83 bd 78 ff ff ff 00 	cmpl   $0x0,-0x88(%ebp)
    29c6:	74 0b                	je     29d3 <run_cow_test_from_args+0x34e>
        info.parent_write_index = info.num_forks - 1;
    29c8:	8b 45 c8             	mov    -0x38(%ebp),%eax
    29cb:	83 e8 01             	sub    $0x1,%eax
    29ce:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    29d1:	eb 0d                	jmp    29e0 <run_cow_test_from_args+0x35b>
    } else if (parent_never) {
    29d3:	83 bd 74 ff ff ff 00 	cmpl   $0x0,-0x8c(%ebp)
    29da:	74 04                	je     29e0 <run_cow_test_from_args+0x35b>
        info.parent_write[0] = 0;
    29dc:	c6 45 d0 00          	movb   $0x0,-0x30(%ebp)
    }
    if (no_child_write) {
    29e0:	83 bd 70 ff ff ff 00 	cmpl   $0x0,-0x90(%ebp)
    29e7:	75 0c                	jne    29f5 <run_cow_test_from_args+0x370>
    29e9:	eb 16                	jmp    2a01 <run_cow_test_from_args+0x37c>
        for (int i = 0; i < info.num_forks; i += 1) {
            info.child_write[0][i] = 0;
    29eb:	c6 44 05 d8 00       	movb   $0x0,-0x28(%ebp,%eax,1)
        for (int i = 0; i < info.num_forks; i += 1) {
    29f0:	83 c0 01             	add    $0x1,%eax
    29f3:	eb 05                	jmp    29fa <run_cow_test_from_args+0x375>
    29f5:	b8 00 00 00 00       	mov    $0x0,%eax
    29fa:	39 45 c8             	cmp    %eax,-0x38(%ebp)
    29fd:	7f ec                	jg     29eb <run_cow_test_from_args+0x366>
    29ff:	eb 6e                	jmp    2a6f <run_cow_test_from_args+0x3ea>
        }
    } else if (child_write_only != -1) {
    2a01:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
    2a07:	83 fa ff             	cmp    $0xffffffff,%edx
    2a0a:	75 17                	jne    2a23 <run_cow_test_from_args+0x39e>
    2a0c:	eb 21                	jmp    2a2f <run_cow_test_from_args+0x3aa>
        for (int i = 0; i < info.num_forks; i += 1) {
            if (i == child_write_only) {
    2a0e:	39 d0                	cmp    %edx,%eax
    2a10:	75 07                	jne    2a19 <run_cow_test_from_args+0x394>
                info.child_write[0][i] = 1;
    2a12:	c6 44 05 d8 01       	movb   $0x1,-0x28(%ebp,%eax,1)
    2a17:	eb 05                	jmp    2a1e <run_cow_test_from_args+0x399>
            } else {
                info.child_write[0][i] = 0;
    2a19:	c6 44 05 d8 00       	movb   $0x0,-0x28(%ebp,%eax,1)
        for (int i = 0; i < info.num_forks; i += 1) {
    2a1e:	83 c0 01             	add    $0x1,%eax
    2a21:	eb 05                	jmp    2a28 <run_cow_test_from_args+0x3a3>
    2a23:	b8 00 00 00 00       	mov    $0x0,%eax
    2a28:	39 45 c8             	cmp    %eax,-0x38(%ebp)
    2a2b:	7f e1                	jg     2a0e <run_cow_test_from_args+0x389>
    2a2d:	eb 40                	jmp    2a6f <run_cow_test_from_args+0x3ea>
            }
        }
    } else if (child_write_except != -1) {
    2a2f:	8b 95 6c ff ff ff    	mov    -0x94(%ebp),%edx
    2a35:	83 fa ff             	cmp    $0xffffffff,%edx
    2a38:	75 1c                	jne    2a56 <run_cow_test_from_args+0x3d1>
    2a3a:	b8 00 00 00 00       	mov    $0x0,%eax
    2a3f:	eb 29                	jmp    2a6a <run_cow_test_from_args+0x3e5>
        for (int i = 0; i < info.num_forks; i += 1) {
            if (i != child_write_except) {
    2a41:	39 d0                	cmp    %edx,%eax
    2a43:	74 07                	je     2a4c <run_cow_test_from_args+0x3c7>
                info.child_write[0][i] = 1;
    2a45:	c6 44 05 d8 01       	movb   $0x1,-0x28(%ebp,%eax,1)
    2a4a:	eb 05                	jmp    2a51 <run_cow_test_from_args+0x3cc>
            } else {
                info.child_write[0][i] = 0;
    2a4c:	c6 44 05 d8 00       	movb   $0x0,-0x28(%ebp,%eax,1)
        for (int i = 0; i < info.num_forks; i += 1) {
    2a51:	83 c0 01             	add    $0x1,%eax
    2a54:	eb 05                	jmp    2a5b <run_cow_test_from_args+0x3d6>
    2a56:	b8 00 00 00 00       	mov    $0x0,%eax
    2a5b:	39 45 c8             	cmp    %eax,-0x38(%ebp)
    2a5e:	7f e1                	jg     2a41 <run_cow_test_from_args+0x3bc>
    2a60:	eb 0d                	jmp    2a6f <run_cow_test_from_args+0x3ea>
            }
        }
    } else {
        for (int i = 0; i < info.num_forks; i += 1) {
            info.child_write[0][i] = 1;
    2a62:	c6 44 05 d8 01       	movb   $0x1,-0x28(%ebp,%eax,1)
        for (int i = 0; i < info.num_forks; i += 1) {
    2a67:	83 c0 01             	add    $0x1,%eax
    2a6a:	39 45 c8             	cmp    %eax,-0x38(%ebp)
    2a6d:	7f f3                	jg     2a62 <run_cow_test_from_args+0x3dd>
        }
    }
    if (pre_fork_p) {
    2a6f:	83 7d 84 00          	cmpl   $0x0,-0x7c(%ebp)
    2a73:	74 11                	je     2a86 <run_cow_test_from_args+0x401>
        info.pre_fork_p = 1;
    2a75:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        return test_cow_in_child(&info);
    2a7c:	8d 45 88             	lea    -0x78(%ebp),%eax
    2a7f:	e8 fc f4 ff ff       	call   1f80 <test_cow_in_child>
    2a84:	eb 08                	jmp    2a8e <run_cow_test_from_args+0x409>
    } else {
        return test_cow(&info);
    2a86:	8d 45 88             	lea    -0x78(%ebp),%eax
    2a89:	e8 b1 f3 ff ff       	call   1e3f <test_cow>
    }
}
    2a8e:	81 c4 b4 01 00 00    	add    $0x1b4,%esp
    2a94:	5f                   	pop    %edi
    2a95:	5d                   	pop    %ebp
    2a96:	c3                   	ret    

00002a97 <run_alloc_test_from_args>:

MAYBE_UNUSED
int run_alloc_test_from_args(int argc, char **argv) {
    2a97:	55                   	push   %ebp
    2a98:	89 e5                	mov    %esp,%ebp
    2a9a:	57                   	push   %edi
    2a9b:	81 ec 14 01 00 00    	sub    $0x114,%esp
    struct alloc_test_info info = {
    2aa1:	8d 7d c0             	lea    -0x40(%ebp),%edi
    2aa4:	b8 00 00 00 00       	mov    $0x0,%eax
    2aa9:	b9 0e 00 00 00       	mov    $0xe,%ecx
    2aae:	f3 ab                	rep stos %eax,%es:(%edi)
    2ab0:	c7 45 d0 00 10 00 00 	movl   $0x1000,-0x30(%ebp)
    2ab7:	c7 45 d4 00 02 00 00 	movl   $0x200,-0x2c(%ebp)
    2abe:	c7 45 d8 00 03 00 00 	movl   $0x300,-0x28(%ebp)
    2ac5:	c7 45 dc 80 00 00 00 	movl   $0x80,-0x24(%ebp)
    2acc:	c7 45 e0 00 01 00 00 	movl   $0x100,-0x20(%ebp)
        .use_sys_read = 0,
        .fork_after_alloc = 0,
        .dump = 0,
        .skip_free_check = 0,
    };
    int fork_p = 0;
    2ad3:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%ebp)
    struct option options[] = {
    2ada:	8d bd fc fe ff ff    	lea    -0x104(%ebp),%edi
    2ae0:	b1 30                	mov    $0x30,%cl
    2ae2:	f3 ab                	rep stos %eax,%es:(%edi)
    2ae4:	c7 85 fc fe ff ff b3 	movl   $0x36b3,-0x104(%ebp)
    2aeb:	36 00 00 
    2aee:	c7 85 00 ff ff ff 88 	movl   $0x4e88,-0x100(%ebp)
    2af5:	4e 00 00 
    2af8:	8d 45 bc             	lea    -0x44(%ebp),%eax
    2afb:	89 85 04 ff ff ff    	mov    %eax,-0xfc(%ebp)
    2b01:	c7 85 08 ff ff ff 01 	movl   $0x1,-0xf8(%ebp)
    2b08:	00 00 00 
    2b0b:	c7 85 0c ff ff ff e3 	movl   $0x35e3,-0xf4(%ebp)
    2b12:	35 00 00 
    2b15:	c7 85 10 ff ff ff b8 	movl   $0x36b8,-0xf0(%ebp)
    2b1c:	36 00 00 
    2b1f:	8d 7d c0             	lea    -0x40(%ebp),%edi
    2b22:	8d 45 d0             	lea    -0x30(%ebp),%eax
    2b25:	89 85 14 ff ff ff    	mov    %eax,-0xec(%ebp)
    2b2b:	c7 85 1c ff ff ff c9 	movl   $0x36c9,-0xe4(%ebp)
    2b32:	36 00 00 
    2b35:	c7 85 20 ff ff ff d0 	movl   $0x4ed0,-0xe0(%ebp)
    2b3c:	4e 00 00 
    2b3f:	8d 45 dc             	lea    -0x24(%ebp),%eax
    2b42:	89 85 24 ff ff ff    	mov    %eax,-0xdc(%ebp)
    2b48:	c7 85 2c ff ff ff d4 	movl   $0x36d4,-0xd4(%ebp)
    2b4f:	36 00 00 
    2b52:	c7 85 30 ff ff ff fc 	movl   $0x4efc,-0xd0(%ebp)
    2b59:	4e 00 00 
    2b5c:	8d 45 e0             	lea    -0x20(%ebp),%eax
    2b5f:	89 85 34 ff ff ff    	mov    %eax,-0xcc(%ebp)
    2b65:	c7 85 3c ff ff ff dd 	movl   $0x36dd,-0xc4(%ebp)
    2b6c:	36 00 00 
    2b6f:	c7 85 40 ff ff ff 28 	movl   $0x4f28,-0xc0(%ebp)
    2b76:	4f 00 00 
    2b79:	8d 45 d4             	lea    -0x2c(%ebp),%eax
    2b7c:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
    2b82:	c7 85 4c ff ff ff e9 	movl   $0x36e9,-0xb4(%ebp)
    2b89:	36 00 00 
    2b8c:	c7 85 50 ff ff ff 54 	movl   $0x4f54,-0xb0(%ebp)
    2b93:	4f 00 00 
    2b96:	8d 45 d8             	lea    -0x28(%ebp),%eax
    2b99:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
    2b9f:	c7 85 5c ff ff ff f3 	movl   $0x36f3,-0xa4(%ebp)
    2ba6:	36 00 00 
    2ba9:	c7 85 60 ff ff ff 80 	movl   $0x4f80,-0xa0(%ebp)
    2bb0:	4f 00 00 
    2bb3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
    2bb6:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
    2bbc:	c7 85 68 ff ff ff 01 	movl   $0x1,-0x98(%ebp)
    2bc3:	00 00 00 
    2bc6:	c7 85 6c ff ff ff 00 	movl   $0x3700,-0x94(%ebp)
    2bcd:	37 00 00 
    2bd0:	c7 85 70 ff ff ff b8 	movl   $0x4fb8,-0x90(%ebp)
    2bd7:	4f 00 00 
    2bda:	8d 45 e8             	lea    -0x18(%ebp),%eax
    2bdd:	89 85 74 ff ff ff    	mov    %eax,-0x8c(%ebp)
    2be3:	c7 85 78 ff ff ff 01 	movl   $0x1,-0x88(%ebp)
    2bea:	00 00 00 
    2bed:	c7 85 7c ff ff ff 8b 	movl   $0x368b,-0x84(%ebp)
    2bf4:	36 00 00 
    2bf7:	c7 45 80 f0 4c 00 00 	movl   $0x4cf0,-0x80(%ebp)
    2bfe:	8d 45 f4             	lea    -0xc(%ebp),%eax
    2c01:	89 45 84             	mov    %eax,-0x7c(%ebp)
    2c04:	c7 45 88 01 00 00 00 	movl   $0x1,-0x78(%ebp)
    2c0b:	c7 45 8c 9a 36 00 00 	movl   $0x369a,-0x74(%ebp)
    2c12:	c7 45 90 74 4d 00 00 	movl   $0x4d74,-0x70(%ebp)
    2c19:	8d 45 f0             	lea    -0x10(%ebp),%eax
    2c1c:	89 45 94             	mov    %eax,-0x6c(%ebp)
    2c1f:	c7 45 98 01 00 00 00 	movl   $0x1,-0x68(%ebp)
    2c26:	c7 45 9c aa 36 00 00 	movl   $0x36aa,-0x64(%ebp)
    2c2d:	c7 45 a0 18 50 00 00 	movl   $0x5018,-0x60(%ebp)
    2c34:	8d 45 ec             	lea    -0x14(%ebp),%eax
    2c37:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    2c3a:	c7 45 a8 01 00 00 00 	movl   $0x1,-0x58(%ebp)
        },
        {
            .name = (char*) 0,
        },
    };
    getopt(argc, argv, options);
    2c41:	8d 8d fc fe ff ff    	lea    -0x104(%ebp),%ecx
    2c47:	8b 55 0c             	mov    0xc(%ebp),%edx
    2c4a:	8b 45 08             	mov    0x8(%ebp),%eax
    2c4d:	e8 f5 f8 ff ff       	call   2547 <getopt>
    return test_allocation(fork_p, &info);
    2c52:	89 7c 24 04          	mov    %edi,0x4(%esp)
    2c56:	8b 45 bc             	mov    -0x44(%ebp),%eax
    2c59:	89 04 24             	mov    %eax,(%esp)
    2c5c:	e8 15 f5 ff ff       	call   2176 <test_allocation>
}
    2c61:	81 c4 14 01 00 00    	add    $0x114,%esp
    2c67:	5f                   	pop    %edi
    2c68:	5d                   	pop    %ebp
    2c69:	c3                   	ret    

00002c6a <run_oob_from_args>:

MAYBE_UNUSED
int run_oob_from_args(int argc, char **argv) {
    2c6a:	55                   	push   %ebp
    2c6b:	89 e5                	mov    %esp,%ebp
    2c6d:	57                   	push   %edi
    2c6e:	83 ec 74             	sub    $0x74,%esp
    int no_fork_p = 0;
    2c71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    int guard_p = 0;
    2c78:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    int write_p = 0;
    2c7f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    int heap_offset = 0x1000;
    2c86:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
    struct option options[] = {
    2c8d:	8d 7d 98             	lea    -0x68(%ebp),%edi
    2c90:	b9 14 00 00 00       	mov    $0x14,%ecx
    2c95:	b8 00 00 00 00       	mov    $0x0,%eax
    2c9a:	f3 ab                	rep stos %eax,%es:(%edi)
    2c9c:	c7 45 98 11 37 00 00 	movl   $0x3711,-0x68(%ebp)
    2ca3:	c7 45 9c 48 50 00 00 	movl   $0x5048,-0x64(%ebp)
    2caa:	8d 45 e8             	lea    -0x18(%ebp),%eax
    2cad:	89 45 a0             	mov    %eax,-0x60(%ebp)
    2cb0:	c7 45 a8 3f 36 00 00 	movl   $0x363f,-0x58(%ebp)
    2cb7:	c7 45 ac 7c 50 00 00 	movl   $0x507c,-0x54(%ebp)
    2cbe:	8d 45 ec             	lea    -0x14(%ebp),%eax
    2cc1:	89 45 b0             	mov    %eax,-0x50(%ebp)
    2cc4:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
    2ccb:	c7 45 b8 18 37 00 00 	movl   $0x3718,-0x48(%ebp)
    2cd2:	c7 45 bc ac 50 00 00 	movl   $0x50ac,-0x44(%ebp)
    2cd9:	8d 45 f0             	lea    -0x10(%ebp),%eax
    2cdc:	89 45 c0             	mov    %eax,-0x40(%ebp)
    2cdf:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
    2ce6:	c7 45 c8 1e 37 00 00 	movl   $0x371e,-0x38(%ebp)
    2ced:	c7 45 cc f0 50 00 00 	movl   $0x50f0,-0x34(%ebp)
    2cf4:	8d 45 f4             	lea    -0xc(%ebp),%eax
    2cf7:	89 45 d0             	mov    %eax,-0x30(%ebp)
    2cfa:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
        },
        {
            .name = (char*) 0,
        }
    };
    getopt(argc, argv, options);
    2d01:	8d 4d 98             	lea    -0x68(%ebp),%ecx
    2d04:	8b 55 0c             	mov    0xc(%ebp),%edx
    2d07:	8b 45 08             	mov    0x8(%ebp),%eax
    2d0a:	e8 38 f8 ff ff       	call   2547 <getopt>
    int fork_p = !no_fork_p;
    2d0f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2d13:	0f 94 c2             	sete   %dl
    2d16:	0f b6 d2             	movzbl %dl,%edx
    return test_oob(heap_offset, fork_p, write_p, guard_p);
    2d19:	8b 45 f0             	mov    -0x10(%ebp),%eax
    2d1c:	89 04 24             	mov    %eax,(%esp)
    2d1f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
    2d22:	8b 45 e8             	mov    -0x18(%ebp),%eax
    2d25:	e8 bf db ff ff       	call   8e9 <test_oob>
}
    2d2a:	83 c4 74             	add    $0x74,%esp
    2d2d:	5f                   	pop    %edi
    2d2e:	5d                   	pop    %ebp
    2d2f:	c3                   	ret    

00002d30 <run_test_from_args>:

MAYBE_UNUSED
int run_test_from_args(int argc, char **argv) {
    2d30:	55                   	push   %ebp
    2d31:	89 e5                	mov    %esp,%ebp
    2d33:	56                   	push   %esi
    2d34:	53                   	push   %ebx
    2d35:	83 ec 10             	sub    $0x10,%esp
    2d38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (0 == strcmp(argv[0], "cow")) {
    2d3b:	c7 44 24 04 26 37 00 	movl   $0x3726,0x4(%esp)
    2d42:	00 
    2d43:	8b 03                	mov    (%ebx),%eax
    2d45:	89 04 24             	mov    %eax,(%esp)
    2d48:	e8 6a 01 00 00       	call   2eb7 <strcmp>
    2d4d:	85 c0                	test   %eax,%eax
    2d4f:	75 16                	jne    2d67 <run_test_from_args+0x37>
        return run_cow_test_from_args(argc, argv);
    2d51:	89 5c 24 04          	mov    %ebx,0x4(%esp)
    2d55:	8b 45 08             	mov    0x8(%ebp),%eax
    2d58:	89 04 24             	mov    %eax,(%esp)
    2d5b:	e8 25 f9 ff ff       	call   2685 <run_cow_test_from_args>
    2d60:	89 c6                	mov    %eax,%esi
    2d62:	e9 ea 00 00 00       	jmp    2e51 <run_test_from_args+0x121>
    } else if (0 == strcmp(argv[0], "alloc")) {
    2d67:	c7 44 24 04 0b 37 00 	movl   $0x370b,0x4(%esp)
    2d6e:	00 
    2d6f:	8b 03                	mov    (%ebx),%eax
    2d71:	89 04 24             	mov    %eax,(%esp)
    2d74:	e8 3e 01 00 00       	call   2eb7 <strcmp>
    2d79:	85 c0                	test   %eax,%eax
    2d7b:	75 16                	jne    2d93 <run_test_from_args+0x63>
        return run_alloc_test_from_args(argc, argv);
    2d7d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
    2d81:	8b 45 08             	mov    0x8(%ebp),%eax
    2d84:	89 04 24             	mov    %eax,(%esp)
    2d87:	e8 0b fd ff ff       	call   2a97 <run_alloc_test_from_args>
    2d8c:	89 c6                	mov    %eax,%esi
    2d8e:	e9 be 00 00 00       	jmp    2e51 <run_test_from_args+0x121>
    } else if (0 == strcmp(argv[0], "exec")) {
    2d93:	c7 44 24 04 2a 37 00 	movl   $0x372a,0x4(%esp)
    2d9a:	00 
    2d9b:	8b 03                	mov    (%ebx),%eax
    2d9d:	89 04 24             	mov    %eax,(%esp)
    2da0:	e8 12 01 00 00       	call   2eb7 <strcmp>
    2da5:	85 c0                	test   %eax,%eax
    2da7:	75 40                	jne    2de9 <run_test_from_args+0xb9>
        if (argc > 1 && 0 == strcmp(argv[1], "-help")) {
    2da9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
    2dad:	7e 2f                	jle    2dde <run_test_from_args+0xae>
    2daf:	c7 44 24 04 2f 37 00 	movl   $0x372f,0x4(%esp)
    2db6:	00 
    2db7:	8b 43 04             	mov    0x4(%ebx),%eax
    2dba:	89 04 24             	mov    %eax,(%esp)
    2dbd:	e8 f5 00 00 00       	call   2eb7 <strcmp>
    2dc2:	89 c6                	mov    %eax,%esi
    2dc4:	85 c0                	test   %eax,%eax
    2dc6:	75 16                	jne    2dde <run_test_from_args+0xae>
            printf(2, "The exec test type takes no options.\n");
    2dc8:	c7 44 24 04 3c 51 00 	movl   $0x513c,0x4(%esp)
    2dcf:	00 
    2dd0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2dd7:	e8 d0 03 00 00       	call   31ac <printf>
            return TR_SUCCESS;
    2ddc:	eb 73                	jmp    2e51 <run_test_from_args+0x121>
        } else {
            return _test_exec(argv[0]);
    2dde:	8b 03                	mov    (%ebx),%eax
    2de0:	e8 a5 e0 ff ff       	call   e8a <_test_exec>
    2de5:	89 c6                	mov    %eax,%esi
    2de7:	eb 68                	jmp    2e51 <run_test_from_args+0x121>
        }
    } else if (0 == strcmp(argv[0], "oob")) {
    2de9:	c7 44 24 04 35 37 00 	movl   $0x3735,0x4(%esp)
    2df0:	00 
    2df1:	8b 03                	mov    (%ebx),%eax
    2df3:	89 04 24             	mov    %eax,(%esp)
    2df6:	e8 bc 00 00 00       	call   2eb7 <strcmp>
    2dfb:	85 c0                	test   %eax,%eax
    2dfd:	75 13                	jne    2e12 <run_test_from_args+0xe2>
        return run_oob_from_args(argc, argv);
    2dff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
    2e03:	8b 45 08             	mov    0x8(%ebp),%eax
    2e06:	89 04 24             	mov    %eax,(%esp)
    2e09:	e8 5c fe ff ff       	call   2c6a <run_oob_from_args>
    2e0e:	89 c6                	mov    %eax,%esi
    2e10:	eb 3f                	jmp    2e51 <run_test_from_args+0x121>
    } else {
        printf(2, "Usage: %s TEST-TYPE OPTIONS\n",
            real_argv0 ? "" : real_argv0);
    2e12:	a1 60 74 00 00       	mov    0x7460,%eax
        printf(2, "Usage: %s TEST-TYPE OPTIONS\n",
    2e17:	85 c0                	test   %eax,%eax
    2e19:	74 05                	je     2e20 <run_test_from_args+0xf0>
    2e1b:	b8 8c 33 00 00       	mov    $0x338c,%eax
    2e20:	89 44 24 08          	mov    %eax,0x8(%esp)
    2e24:	c7 44 24 04 39 37 00 	movl   $0x3739,0x4(%esp)
    2e2b:	00 
    2e2c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2e33:	e8 74 03 00 00       	call   31ac <printf>
        printf(2, "  TEST-TYPE is one of:\n"
    2e38:	c7 44 24 04 64 51 00 	movl   $0x5164,0x4(%esp)
    2e3f:	00 
    2e40:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2e47:	e8 60 03 00 00       	call   31ac <printf>
                  "  OPTIONS varies by test\n"
                  "    you can always supply no options for a default test\n"
                  "    use OPTIONS of '-help' for a list\n"
                  "    of a test type's options\n"
                );
        return -1;
    2e4c:	be ff ff ff ff       	mov    $0xffffffff,%esi
    }
}
    2e51:	89 f0                	mov    %esi,%eax
    2e53:	83 c4 10             	add    $0x10,%esp
    2e56:	5b                   	pop    %ebx
    2e57:	5e                   	pop    %esi
    2e58:	5d                   	pop    %ebp
    2e59:	c3                   	ret    

00002e5a <main>:
#include "pagingtestlib.h"

int main(int argc, char **argv) {
    2e5a:	55                   	push   %ebp
    2e5b:	89 e5                	mov    %esp,%ebp
    2e5d:	83 e4 f0             	and    $0xfffffff0,%esp
    2e60:	83 ec 10             	sub    $0x10,%esp
    setup(&argc, &argv);
    2e63:	8d 45 0c             	lea    0xc(%ebp),%eax
    2e66:	89 44 24 04          	mov    %eax,0x4(%esp)
    2e6a:	8d 45 08             	lea    0x8(%ebp),%eax
    2e6d:	89 04 24             	mov    %eax,(%esp)
    2e70:	e8 65 f5 ff ff       	call   23da <setup>
    run_test_from_args(argc - 1, argv + 1);
    2e75:	8b 45 0c             	mov    0xc(%ebp),%eax
    2e78:	83 c0 04             	add    $0x4,%eax
    2e7b:	89 44 24 04          	mov    %eax,0x4(%esp)
    2e7f:	8b 45 08             	mov    0x8(%ebp),%eax
    2e82:	83 e8 01             	sub    $0x1,%eax
    2e85:	89 04 24             	mov    %eax,(%esp)
    2e88:	e8 a3 fe ff ff       	call   2d30 <run_test_from_args>
    cleanup();
    2e8d:	e8 92 f6 ff ff       	call   2524 <cleanup>
}
    2e92:	b8 00 00 00 00       	mov    $0x0,%eax
    2e97:	c9                   	leave  
    2e98:	c3                   	ret    

00002e99 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
    2e99:	55                   	push   %ebp
    2e9a:	89 e5                	mov    %esp,%ebp
    2e9c:	53                   	push   %ebx
    2e9d:	8b 45 08             	mov    0x8(%ebp),%eax
    2ea0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    2ea3:	89 c2                	mov    %eax,%edx
    2ea5:	0f b6 19             	movzbl (%ecx),%ebx
    2ea8:	88 1a                	mov    %bl,(%edx)
    2eaa:	8d 52 01             	lea    0x1(%edx),%edx
    2ead:	8d 49 01             	lea    0x1(%ecx),%ecx
    2eb0:	84 db                	test   %bl,%bl
    2eb2:	75 f1                	jne    2ea5 <strcpy+0xc>
    ;
  return os;
}
    2eb4:	5b                   	pop    %ebx
    2eb5:	5d                   	pop    %ebp
    2eb6:	c3                   	ret    

00002eb7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    2eb7:	55                   	push   %ebp
    2eb8:	89 e5                	mov    %esp,%ebp
    2eba:	8b 4d 08             	mov    0x8(%ebp),%ecx
    2ebd:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
    2ec0:	eb 06                	jmp    2ec8 <strcmp+0x11>
    p++, q++;
    2ec2:	83 c1 01             	add    $0x1,%ecx
    2ec5:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
    2ec8:	0f b6 01             	movzbl (%ecx),%eax
    2ecb:	84 c0                	test   %al,%al
    2ecd:	74 04                	je     2ed3 <strcmp+0x1c>
    2ecf:	3a 02                	cmp    (%edx),%al
    2ed1:	74 ef                	je     2ec2 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
    2ed3:	0f b6 c0             	movzbl %al,%eax
    2ed6:	0f b6 12             	movzbl (%edx),%edx
    2ed9:	29 d0                	sub    %edx,%eax
}
    2edb:	5d                   	pop    %ebp
    2edc:	c3                   	ret    

00002edd <strlen>:

uint
strlen(const char *s)
{
    2edd:	55                   	push   %ebp
    2ede:	89 e5                	mov    %esp,%ebp
    2ee0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
    2ee3:	ba 00 00 00 00       	mov    $0x0,%edx
    2ee8:	eb 03                	jmp    2eed <strlen+0x10>
    2eea:	83 c2 01             	add    $0x1,%edx
    2eed:	89 d0                	mov    %edx,%eax
    2eef:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
    2ef3:	75 f5                	jne    2eea <strlen+0xd>
    ;
  return n;
}
    2ef5:	5d                   	pop    %ebp
    2ef6:	c3                   	ret    

00002ef7 <memset>:

void*
memset(void *dst, int c, uint n)
{
    2ef7:	55                   	push   %ebp
    2ef8:	89 e5                	mov    %esp,%ebp
    2efa:	57                   	push   %edi
    2efb:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
    2efe:	89 d7                	mov    %edx,%edi
    2f00:	8b 4d 10             	mov    0x10(%ebp),%ecx
    2f03:	8b 45 0c             	mov    0xc(%ebp),%eax
    2f06:	fc                   	cld    
    2f07:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
    2f09:	89 d0                	mov    %edx,%eax
    2f0b:	5f                   	pop    %edi
    2f0c:	5d                   	pop    %ebp
    2f0d:	c3                   	ret    

00002f0e <strchr>:

char*
strchr(const char *s, char c)
{
    2f0e:	55                   	push   %ebp
    2f0f:	89 e5                	mov    %esp,%ebp
    2f11:	8b 45 08             	mov    0x8(%ebp),%eax
    2f14:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
    2f18:	eb 07                	jmp    2f21 <strchr+0x13>
    if(*s == c)
    2f1a:	38 ca                	cmp    %cl,%dl
    2f1c:	74 0f                	je     2f2d <strchr+0x1f>
  for(; *s; s++)
    2f1e:	83 c0 01             	add    $0x1,%eax
    2f21:	0f b6 10             	movzbl (%eax),%edx
    2f24:	84 d2                	test   %dl,%dl
    2f26:	75 f2                	jne    2f1a <strchr+0xc>
      return (char*)s;
  return 0;
    2f28:	b8 00 00 00 00       	mov    $0x0,%eax
}
    2f2d:	5d                   	pop    %ebp
    2f2e:	c3                   	ret    

00002f2f <gets>:

char*
gets(char *buf, int max)
{
    2f2f:	55                   	push   %ebp
    2f30:	89 e5                	mov    %esp,%ebp
    2f32:	57                   	push   %edi
    2f33:	56                   	push   %esi
    2f34:	53                   	push   %ebx
    2f35:	83 ec 2c             	sub    $0x2c,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    2f38:	bb 00 00 00 00       	mov    $0x0,%ebx
    cc = read(0, &c, 1);
    2f3d:	8d 7d e7             	lea    -0x19(%ebp),%edi
  for(i=0; i+1 < max; ){
    2f40:	eb 36                	jmp    2f78 <gets+0x49>
    cc = read(0, &c, 1);
    2f42:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    2f49:	00 
    2f4a:	89 7c 24 04          	mov    %edi,0x4(%esp)
    2f4e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2f55:	e8 f8 00 00 00       	call   3052 <read>
    if(cc < 1)
    2f5a:	85 c0                	test   %eax,%eax
    2f5c:	7e 26                	jle    2f84 <gets+0x55>
      break;
    buf[i++] = c;
    2f5e:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
    2f62:	8b 4d 08             	mov    0x8(%ebp),%ecx
    2f65:	88 04 19             	mov    %al,(%ecx,%ebx,1)
    if(c == '\n' || c == '\r')
    2f68:	3c 0a                	cmp    $0xa,%al
    2f6a:	0f 94 c2             	sete   %dl
    2f6d:	3c 0d                	cmp    $0xd,%al
    2f6f:	0f 94 c0             	sete   %al
    buf[i++] = c;
    2f72:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
    2f74:	08 c2                	or     %al,%dl
    2f76:	75 0a                	jne    2f82 <gets+0x53>
  for(i=0; i+1 < max; ){
    2f78:	8d 73 01             	lea    0x1(%ebx),%esi
    2f7b:	3b 75 0c             	cmp    0xc(%ebp),%esi
    2f7e:	7c c2                	jl     2f42 <gets+0x13>
    2f80:	eb 02                	jmp    2f84 <gets+0x55>
    buf[i++] = c;
    2f82:	89 f3                	mov    %esi,%ebx
      break;
  }
  buf[i] = '\0';
    2f84:	8b 45 08             	mov    0x8(%ebp),%eax
    2f87:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
  return buf;
}
    2f8b:	83 c4 2c             	add    $0x2c,%esp
    2f8e:	5b                   	pop    %ebx
    2f8f:	5e                   	pop    %esi
    2f90:	5f                   	pop    %edi
    2f91:	5d                   	pop    %ebp
    2f92:	c3                   	ret    

00002f93 <stat>:

int
stat(const char *n, struct stat *st)
{
    2f93:	55                   	push   %ebp
    2f94:	89 e5                	mov    %esp,%ebp
    2f96:	56                   	push   %esi
    2f97:	53                   	push   %ebx
    2f98:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    2f9b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2fa2:	00 
    2fa3:	8b 45 08             	mov    0x8(%ebp),%eax
    2fa6:	89 04 24             	mov    %eax,(%esp)
    2fa9:	e8 cc 00 00 00       	call   307a <open>
    2fae:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
    2fb0:	85 c0                	test   %eax,%eax
    2fb2:	78 1d                	js     2fd1 <stat+0x3e>
    return -1;
  r = fstat(fd, st);
    2fb4:	8b 45 0c             	mov    0xc(%ebp),%eax
    2fb7:	89 44 24 04          	mov    %eax,0x4(%esp)
    2fbb:	89 1c 24             	mov    %ebx,(%esp)
    2fbe:	e8 cf 00 00 00       	call   3092 <fstat>
    2fc3:	89 c6                	mov    %eax,%esi
  close(fd);
    2fc5:	89 1c 24             	mov    %ebx,(%esp)
    2fc8:	e8 95 00 00 00       	call   3062 <close>
  return r;
    2fcd:	89 f0                	mov    %esi,%eax
    2fcf:	eb 05                	jmp    2fd6 <stat+0x43>
    return -1;
    2fd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
    2fd6:	83 c4 10             	add    $0x10,%esp
    2fd9:	5b                   	pop    %ebx
    2fda:	5e                   	pop    %esi
    2fdb:	5d                   	pop    %ebp
    2fdc:	c3                   	ret    

00002fdd <atoi>:

int
atoi(const char *s)
{
    2fdd:	55                   	push   %ebp
    2fde:	89 e5                	mov    %esp,%ebp
    2fe0:	53                   	push   %ebx
    2fe1:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  n = 0;
    2fe4:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
    2fe9:	eb 0f                	jmp    2ffa <atoi+0x1d>
    n = n*10 + *s++ - '0';
    2feb:	8d 04 80             	lea    (%eax,%eax,4),%eax
    2fee:	01 c0                	add    %eax,%eax
    2ff0:	83 c2 01             	add    $0x1,%edx
    2ff3:	0f be c9             	movsbl %cl,%ecx
    2ff6:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
  while('0' <= *s && *s <= '9')
    2ffa:	0f b6 0a             	movzbl (%edx),%ecx
    2ffd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
    3000:	80 fb 09             	cmp    $0x9,%bl
    3003:	76 e6                	jbe    2feb <atoi+0xe>
  return n;
}
    3005:	5b                   	pop    %ebx
    3006:	5d                   	pop    %ebp
    3007:	c3                   	ret    

00003008 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    3008:	55                   	push   %ebp
    3009:	89 e5                	mov    %esp,%ebp
    300b:	56                   	push   %esi
    300c:	53                   	push   %ebx
    300d:	8b 45 08             	mov    0x8(%ebp),%eax
    3010:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    3013:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
    3016:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
    3018:	eb 0d                	jmp    3027 <memmove+0x1f>
    *dst++ = *src++;
    301a:	0f b6 13             	movzbl (%ebx),%edx
    301d:	88 11                	mov    %dl,(%ecx)
  while(n-- > 0)
    301f:	89 f2                	mov    %esi,%edx
    *dst++ = *src++;
    3021:	8d 5b 01             	lea    0x1(%ebx),%ebx
    3024:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
    3027:	8d 72 ff             	lea    -0x1(%edx),%esi
    302a:	85 d2                	test   %edx,%edx
    302c:	7f ec                	jg     301a <memmove+0x12>
  return vdst;
}
    302e:	5b                   	pop    %ebx
    302f:	5e                   	pop    %esi
    3030:	5d                   	pop    %ebp
    3031:	c3                   	ret    

00003032 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    3032:	b8 01 00 00 00       	mov    $0x1,%eax
    3037:	cd 40                	int    $0x40
    3039:	c3                   	ret    

0000303a <exit>:
SYSCALL(exit)
    303a:	b8 02 00 00 00       	mov    $0x2,%eax
    303f:	cd 40                	int    $0x40
    3041:	c3                   	ret    

00003042 <wait>:
SYSCALL(wait)
    3042:	b8 03 00 00 00       	mov    $0x3,%eax
    3047:	cd 40                	int    $0x40
    3049:	c3                   	ret    

0000304a <pipe>:
SYSCALL(pipe)
    304a:	b8 04 00 00 00       	mov    $0x4,%eax
    304f:	cd 40                	int    $0x40
    3051:	c3                   	ret    

00003052 <read>:
SYSCALL(read)
    3052:	b8 05 00 00 00       	mov    $0x5,%eax
    3057:	cd 40                	int    $0x40
    3059:	c3                   	ret    

0000305a <write>:
SYSCALL(write)
    305a:	b8 10 00 00 00       	mov    $0x10,%eax
    305f:	cd 40                	int    $0x40
    3061:	c3                   	ret    

00003062 <close>:
SYSCALL(close)
    3062:	b8 15 00 00 00       	mov    $0x15,%eax
    3067:	cd 40                	int    $0x40
    3069:	c3                   	ret    

0000306a <kill>:
SYSCALL(kill)
    306a:	b8 06 00 00 00       	mov    $0x6,%eax
    306f:	cd 40                	int    $0x40
    3071:	c3                   	ret    

00003072 <exec>:
SYSCALL(exec)
    3072:	b8 07 00 00 00       	mov    $0x7,%eax
    3077:	cd 40                	int    $0x40
    3079:	c3                   	ret    

0000307a <open>:
SYSCALL(open)
    307a:	b8 0f 00 00 00       	mov    $0xf,%eax
    307f:	cd 40                	int    $0x40
    3081:	c3                   	ret    

00003082 <mknod>:
SYSCALL(mknod)
    3082:	b8 11 00 00 00       	mov    $0x11,%eax
    3087:	cd 40                	int    $0x40
    3089:	c3                   	ret    

0000308a <unlink>:
SYSCALL(unlink)
    308a:	b8 12 00 00 00       	mov    $0x12,%eax
    308f:	cd 40                	int    $0x40
    3091:	c3                   	ret    

00003092 <fstat>:
SYSCALL(fstat)
    3092:	b8 08 00 00 00       	mov    $0x8,%eax
    3097:	cd 40                	int    $0x40
    3099:	c3                   	ret    

0000309a <link>:
SYSCALL(link)
    309a:	b8 13 00 00 00       	mov    $0x13,%eax
    309f:	cd 40                	int    $0x40
    30a1:	c3                   	ret    

000030a2 <mkdir>:
SYSCALL(mkdir)
    30a2:	b8 14 00 00 00       	mov    $0x14,%eax
    30a7:	cd 40                	int    $0x40
    30a9:	c3                   	ret    

000030aa <chdir>:
SYSCALL(chdir)
    30aa:	b8 09 00 00 00       	mov    $0x9,%eax
    30af:	cd 40                	int    $0x40
    30b1:	c3                   	ret    

000030b2 <dup>:
SYSCALL(dup)
    30b2:	b8 0a 00 00 00       	mov    $0xa,%eax
    30b7:	cd 40                	int    $0x40
    30b9:	c3                   	ret    

000030ba <getpid>:
SYSCALL(getpid)
    30ba:	b8 0b 00 00 00       	mov    $0xb,%eax
    30bf:	cd 40                	int    $0x40
    30c1:	c3                   	ret    

000030c2 <sbrk>:
SYSCALL(sbrk)
    30c2:	b8 0c 00 00 00       	mov    $0xc,%eax
    30c7:	cd 40                	int    $0x40
    30c9:	c3                   	ret    

000030ca <sleep>:
SYSCALL(sleep)
    30ca:	b8 0d 00 00 00       	mov    $0xd,%eax
    30cf:	cd 40                	int    $0x40
    30d1:	c3                   	ret    

000030d2 <uptime>:
SYSCALL(uptime)
    30d2:	b8 0e 00 00 00       	mov    $0xe,%eax
    30d7:	cd 40                	int    $0x40
    30d9:	c3                   	ret    

000030da <yield>:
SYSCALL(yield)
    30da:	b8 16 00 00 00       	mov    $0x16,%eax
    30df:	cd 40                	int    $0x40
    30e1:	c3                   	ret    

000030e2 <getpagetableentry>:
SYSCALL(getpagetableentry)
    30e2:	b8 18 00 00 00       	mov    $0x18,%eax
    30e7:	cd 40                	int    $0x40
    30e9:	c3                   	ret    

000030ea <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
    30ea:	b8 19 00 00 00       	mov    $0x19,%eax
    30ef:	cd 40                	int    $0x40
    30f1:	c3                   	ret    

000030f2 <dumppagetable>:
SYSCALL(dumppagetable)
    30f2:	b8 1a 00 00 00       	mov    $0x1a,%eax
    30f7:	cd 40                	int    $0x40
    30f9:	c3                   	ret    

000030fa <shutdown>:
SYSCALL(shutdown)
    30fa:	b8 17 00 00 00       	mov    $0x17,%eax
    30ff:	cd 40                	int    $0x40
    3101:	c3                   	ret    
    3102:	66 90                	xchg   %ax,%ax
    3104:	66 90                	xchg   %ax,%ax
    3106:	66 90                	xchg   %ax,%ax
    3108:	66 90                	xchg   %ax,%ax
    310a:	66 90                	xchg   %ax,%ax
    310c:	66 90                	xchg   %ax,%ax
    310e:	66 90                	xchg   %ax,%ax

00003110 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    3110:	55                   	push   %ebp
    3111:	89 e5                	mov    %esp,%ebp
    3113:	83 ec 18             	sub    $0x18,%esp
    3116:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
    3119:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3120:	00 
    3121:	8d 55 f4             	lea    -0xc(%ebp),%edx
    3124:	89 54 24 04          	mov    %edx,0x4(%esp)
    3128:	89 04 24             	mov    %eax,(%esp)
    312b:	e8 2a ff ff ff       	call   305a <write>
}
    3130:	c9                   	leave  
    3131:	c3                   	ret    

00003132 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    3132:	55                   	push   %ebp
    3133:	89 e5                	mov    %esp,%ebp
    3135:	57                   	push   %edi
    3136:	56                   	push   %esi
    3137:	53                   	push   %ebx
    3138:	83 ec 2c             	sub    $0x2c,%esp
    313b:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    313d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
    3141:	0f 95 c3             	setne  %bl
    3144:	89 d0                	mov    %edx,%eax
    3146:	c1 e8 1f             	shr    $0x1f,%eax
    3149:	84 c3                	test   %al,%bl
    314b:	74 0b                	je     3158 <printint+0x26>
    neg = 1;
    x = -xx;
    314d:	f7 da                	neg    %edx
    neg = 1;
    314f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
    3156:	eb 07                	jmp    315f <printint+0x2d>
  neg = 0;
    3158:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
    315f:	be 00 00 00 00       	mov    $0x0,%esi
  do{
    buf[i++] = digits[x % base];
    3164:	8d 5e 01             	lea    0x1(%esi),%ebx
    3167:	89 d0                	mov    %edx,%eax
    3169:	ba 00 00 00 00       	mov    $0x0,%edx
    316e:	f7 f1                	div    %ecx
    3170:	0f b6 92 e3 52 00 00 	movzbl 0x52e3(%edx),%edx
    3177:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
    317b:	89 c2                	mov    %eax,%edx
    buf[i++] = digits[x % base];
    317d:	89 de                	mov    %ebx,%esi
  }while((x /= base) != 0);
    317f:	85 c0                	test   %eax,%eax
    3181:	75 e1                	jne    3164 <printint+0x32>
  if(neg)
    3183:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
    3187:	74 16                	je     319f <printint+0x6d>
    buf[i++] = '-';
    3189:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
    318e:	8d 5b 01             	lea    0x1(%ebx),%ebx
    3191:	eb 0c                	jmp    319f <printint+0x6d>

  while(--i >= 0)
    putc(fd, buf[i]);
    3193:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
    3198:	89 f8                	mov    %edi,%eax
    319a:	e8 71 ff ff ff       	call   3110 <putc>
  while(--i >= 0)
    319f:	83 eb 01             	sub    $0x1,%ebx
    31a2:	79 ef                	jns    3193 <printint+0x61>
}
    31a4:	83 c4 2c             	add    $0x2c,%esp
    31a7:	5b                   	pop    %ebx
    31a8:	5e                   	pop    %esi
    31a9:	5f                   	pop    %edi
    31aa:	5d                   	pop    %ebp
    31ab:	c3                   	ret    

000031ac <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
    31ac:	55                   	push   %ebp
    31ad:	89 e5                	mov    %esp,%ebp
    31af:	57                   	push   %edi
    31b0:	56                   	push   %esi
    31b1:	53                   	push   %ebx
    31b2:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
    31b5:	8d 45 10             	lea    0x10(%ebp),%eax
    31b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
    31bb:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i = 0; fmt[i]; i++){
    31c0:	be 00 00 00 00       	mov    $0x0,%esi
    31c5:	e9 23 01 00 00       	jmp    32ed <printf+0x141>
    c = fmt[i] & 0xff;
    31ca:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
    31cd:	85 ff                	test   %edi,%edi
    31cf:	75 19                	jne    31ea <printf+0x3e>
      if(c == '%'){
    31d1:	83 f8 25             	cmp    $0x25,%eax
    31d4:	0f 84 0b 01 00 00    	je     32e5 <printf+0x139>
        state = '%';
      } else {
        putc(fd, c);
    31da:	0f be d3             	movsbl %bl,%edx
    31dd:	8b 45 08             	mov    0x8(%ebp),%eax
    31e0:	e8 2b ff ff ff       	call   3110 <putc>
    31e5:	e9 00 01 00 00       	jmp    32ea <printf+0x13e>
      }
    } else if(state == '%'){
    31ea:	83 ff 25             	cmp    $0x25,%edi
    31ed:	0f 85 f7 00 00 00    	jne    32ea <printf+0x13e>
      if(c == 'd'){
    31f3:	83 f8 64             	cmp    $0x64,%eax
    31f6:	75 26                	jne    321e <printf+0x72>
        printint(fd, *ap, 10, 1);
    31f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    31fb:	8b 10                	mov    (%eax),%edx
    31fd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3204:	b9 0a 00 00 00       	mov    $0xa,%ecx
    3209:	8b 45 08             	mov    0x8(%ebp),%eax
    320c:	e8 21 ff ff ff       	call   3132 <printint>
        ap++;
    3211:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    3215:	66 bf 00 00          	mov    $0x0,%di
    3219:	e9 cc 00 00 00       	jmp    32ea <printf+0x13e>
      } else if(c == 'x' || c == 'p'){
    321e:	83 f8 78             	cmp    $0x78,%eax
    3221:	0f 94 c1             	sete   %cl
    3224:	83 f8 70             	cmp    $0x70,%eax
    3227:	0f 94 c2             	sete   %dl
    322a:	08 d1                	or     %dl,%cl
    322c:	74 27                	je     3255 <printf+0xa9>
        printint(fd, *ap, 16, 0);
    322e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    3231:	8b 10                	mov    (%eax),%edx
    3233:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    323a:	b9 10 00 00 00       	mov    $0x10,%ecx
    323f:	8b 45 08             	mov    0x8(%ebp),%eax
    3242:	e8 eb fe ff ff       	call   3132 <printint>
        ap++;
    3247:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
    324b:	bf 00 00 00 00       	mov    $0x0,%edi
    3250:	e9 95 00 00 00       	jmp    32ea <printf+0x13e>
      } else if(c == 's'){
    3255:	83 f8 73             	cmp    $0x73,%eax
    3258:	75 37                	jne    3291 <printf+0xe5>
        s = (char*)*ap;
    325a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    325d:	8b 18                	mov    (%eax),%ebx
        ap++;
    325f:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
        if(s == 0)
    3263:	85 db                	test   %ebx,%ebx
    3265:	75 19                	jne    3280 <printf+0xd4>
          s = "(null)";
    3267:	bb dc 52 00 00       	mov    $0x52dc,%ebx
    326c:	8b 7d 08             	mov    0x8(%ebp),%edi
    326f:	eb 12                	jmp    3283 <printf+0xd7>
          putc(fd, *s);
    3271:	0f be d2             	movsbl %dl,%edx
    3274:	89 f8                	mov    %edi,%eax
    3276:	e8 95 fe ff ff       	call   3110 <putc>
          s++;
    327b:	83 c3 01             	add    $0x1,%ebx
    327e:	eb 03                	jmp    3283 <printf+0xd7>
    3280:	8b 7d 08             	mov    0x8(%ebp),%edi
        while(*s != 0){
    3283:	0f b6 13             	movzbl (%ebx),%edx
    3286:	84 d2                	test   %dl,%dl
    3288:	75 e7                	jne    3271 <printf+0xc5>
      state = 0;
    328a:	bf 00 00 00 00       	mov    $0x0,%edi
    328f:	eb 59                	jmp    32ea <printf+0x13e>
      } else if(c == 'c'){
    3291:	83 f8 63             	cmp    $0x63,%eax
    3294:	75 19                	jne    32af <printf+0x103>
        putc(fd, *ap);
    3296:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    3299:	0f be 10             	movsbl (%eax),%edx
    329c:	8b 45 08             	mov    0x8(%ebp),%eax
    329f:	e8 6c fe ff ff       	call   3110 <putc>
        ap++;
    32a4:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
    32a8:	bf 00 00 00 00       	mov    $0x0,%edi
    32ad:	eb 3b                	jmp    32ea <printf+0x13e>
      } else if(c == '%'){
    32af:	83 f8 25             	cmp    $0x25,%eax
    32b2:	75 12                	jne    32c6 <printf+0x11a>
        putc(fd, c);
    32b4:	0f be d3             	movsbl %bl,%edx
    32b7:	8b 45 08             	mov    0x8(%ebp),%eax
    32ba:	e8 51 fe ff ff       	call   3110 <putc>
      state = 0;
    32bf:	bf 00 00 00 00       	mov    $0x0,%edi
    32c4:	eb 24                	jmp    32ea <printf+0x13e>
        putc(fd, '%');
    32c6:	ba 25 00 00 00       	mov    $0x25,%edx
    32cb:	8b 45 08             	mov    0x8(%ebp),%eax
    32ce:	e8 3d fe ff ff       	call   3110 <putc>
        putc(fd, c);
    32d3:	0f be d3             	movsbl %bl,%edx
    32d6:	8b 45 08             	mov    0x8(%ebp),%eax
    32d9:	e8 32 fe ff ff       	call   3110 <putc>
      state = 0;
    32de:	bf 00 00 00 00       	mov    $0x0,%edi
    32e3:	eb 05                	jmp    32ea <printf+0x13e>
        state = '%';
    32e5:	bf 25 00 00 00       	mov    $0x25,%edi
  for(i = 0; fmt[i]; i++){
    32ea:	83 c6 01             	add    $0x1,%esi
    32ed:	89 f0                	mov    %esi,%eax
    32ef:	03 45 0c             	add    0xc(%ebp),%eax
    32f2:	0f b6 18             	movzbl (%eax),%ebx
    32f5:	84 db                	test   %bl,%bl
    32f7:	0f 85 cd fe ff ff    	jne    31ca <printf+0x1e>
    }
  }
}
    32fd:	83 c4 1c             	add    $0x1c,%esp
    3300:	5b                   	pop    %ebx
    3301:	5e                   	pop    %esi
    3302:	5f                   	pop    %edi
    3303:	5d                   	pop    %ebp
    3304:	c3                   	ret    
