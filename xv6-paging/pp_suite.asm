
_pp_suite:     file format elf32-i386


Disassembly of section .text:

00000000 <_get_guard>:
#include "mmu.h"
#include "fcntl.h"

//#define DEBUG
#define MAYBE_UNUSED __attribute__((unused))
#define EXEC_TEST_PTE_VALUES 16
       0:	b8 ff 0f 00 00       	mov    $0xfff,%eax
#define MAX_COW_FORKS 4
       5:	f7 d0                	not    %eax
#define NUM_COW_REGIONS 1
       7:	21 e0                	and    %esp,%eax

       9:	2d 00 10 00 00       	sub    $0x1000,%eax
// for test development: #define ALLOC_CHECK
       e:	c3                   	ret    

0000000f <clear_saved_ppns>:
#ifdef ALLOC_CHECK
static volatile int kalloc_index = 0;
#endif

static void clear_saved_ppns() {
    saved_ppn_index = 0;
       f:	c7 05 70 59 00 00 00 	movl   $0x0,0x5970
      16:	00 00 00 
    /* write all saved_ppns to prevent unexpected allocations later */
    for (int i = 0; i < SAVED_PPN_COUNT; i += 1) {
      19:	b8 00 00 00 00       	mov    $0x0,%eax
      1e:	eb 0e                	jmp    2e <clear_saved_ppns+0x1f>
        saved_ppns[i] = 0;
      20:	c7 04 85 80 59 00 00 	movl   $0x0,0x5980(,%eax,4)
      27:	00 00 00 00 
    for (int i = 0; i < SAVED_PPN_COUNT; i += 1) {
      2b:	83 c0 01             	add    $0x1,%eax
      2e:	3d ff 07 00 00       	cmp    $0x7ff,%eax
      33:	7e eb                	jle    20 <clear_saved_ppns+0x11>
    }
#ifdef ALLOC_CHECK
    kalloc_index = 0;
    kalloc_index = getkallocindex();
#endif
}
      35:	c3                   	ret    

00000036 <_heap_test_value>:

    int dump;
    int pre_fork_p;
};

static char _heap_test_value(int offset, int child_index) {
      36:	89 d1                	mov    %edx,%ecx
    int adjusted_offset = offset + (offset >> PTXSHIFT) + (offset >> PDXSHIFT);
      38:	89 c2                	mov    %eax,%edx
      3a:	c1 fa 0c             	sar    $0xc,%edx
      3d:	01 c2                	add    %eax,%edx
      3f:	c1 f8 16             	sar    $0x16,%eax
      42:	01 d0                	add    %edx,%eax
    return ('Q' + adjusted_offset + child_index);
      44:	8d 44 08 51          	lea    0x51(%eax,%ecx,1),%eax
}
      48:	c3                   	ret    

00000049 <_pipe_assert_broken_parent>:
int _pipe_assert_broken_parent(struct test_pipes *pipes) {
      49:	55                   	push   %ebp
      4a:	89 e5                	mov    %esp,%ebp
      4c:	83 ec 1c             	sub    $0x1c,%esp
    char c = 'X';
      4f:	c6 45 f7 58          	movb   $0x58,-0x9(%ebp)
    int result = read(pipes->from_child[0], &c, 1);
      53:	6a 01                	push   $0x1
      55:	8d 55 f7             	lea    -0x9(%ebp),%edx
      58:	52                   	push   %edx
      59:	ff 70 08             	push   0x8(%eax)
      5c:	e8 ad 2f 00 00       	call   300e <read>
    return (result != 1);
      61:	83 c4 10             	add    $0x10,%esp
      64:	83 f8 01             	cmp    $0x1,%eax
      67:	0f 95 c0             	setne  %al
      6a:	0f b6 c0             	movzbl %al,%eax
}
      6d:	c9                   	leave  
      6e:	c3                   	ret    

0000006f <_pipe_send_child>:
void _pipe_send_child(struct test_pipes *pipes, int *values, int value_count) {
      6f:	55                   	push   %ebp
      70:	89 e5                	mov    %esp,%ebp
      72:	56                   	push   %esi
      73:	53                   	push   %ebx
      74:	83 ec 10             	sub    $0x10,%esp
      77:	89 c3                	mov    %eax,%ebx
      79:	89 4d f4             	mov    %ecx,-0xc(%ebp)
    if (pipes->from_child[1] != -1) {
      7c:	8b 40 0c             	mov    0xc(%eax),%eax
      7f:	83 f8 ff             	cmp    $0xffffffff,%eax
      82:	75 07                	jne    8b <_pipe_send_child+0x1c>
}
      84:	8d 65 f8             	lea    -0x8(%ebp),%esp
      87:	5b                   	pop    %ebx
      88:	5e                   	pop    %esi
      89:	5d                   	pop    %ebp
      8a:	c3                   	ret    
      8b:	89 d6                	mov    %edx,%esi
        write(pipes->from_child[1], &value_count, 4);
      8d:	83 ec 04             	sub    $0x4,%esp
      90:	6a 04                	push   $0x4
      92:	8d 55 f4             	lea    -0xc(%ebp),%edx
      95:	52                   	push   %edx
      96:	50                   	push   %eax
      97:	e8 7a 2f 00 00       	call   3016 <write>
        write(pipes->from_child[1], values, 4 * value_count);
      9c:	83 c4 0c             	add    $0xc,%esp
      9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
      a2:	c1 e0 02             	shl    $0x2,%eax
      a5:	50                   	push   %eax
      a6:	56                   	push   %esi
      a7:	ff 73 0c             	push   0xc(%ebx)
      aa:	e8 67 2f 00 00       	call   3016 <write>
      af:	83 c4 10             	add    $0x10,%esp
}
      b2:	eb d0                	jmp    84 <_pipe_send_child+0x15>

000000b4 <CRASH>:
static void CRASH(const char *message) {
      b4:	55                   	push   %ebp
      b5:	89 e5                	mov    %esp,%ebp
      b7:	83 ec 0c             	sub    $0xc,%esp
    printf(2, "%s\n", message);
      ba:	50                   	push   %eax
      bb:	68 74 33 00 00       	push   $0x3374
      c0:	6a 02                	push   $0x2
      c2:	e8 9c 30 00 00       	call   3163 <printf>
    exit();
      c7:	e8 2a 2f 00 00       	call   2ff6 <exit>

000000cc <_pipe_sync_parent>:
int _pipe_sync_parent(struct test_pipes *pipes) {
      cc:	55                   	push   %ebp
      cd:	89 e5                	mov    %esp,%ebp
      cf:	53                   	push   %ebx
      d0:	83 ec 14             	sub    $0x14,%esp
      d3:	89 c3                	mov    %eax,%ebx
    if (pipes->from_child[0] != -1) {
      d5:	8b 40 08             	mov    0x8(%eax),%eax
      d8:	83 f8 ff             	cmp    $0xffffffff,%eax
      db:	75 0a                	jne    e7 <_pipe_sync_parent+0x1b>
}
      dd:	b8 01 00 00 00       	mov    $0x1,%eax
      e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      e5:	c9                   	leave  
      e6:	c3                   	ret    
        char c = 'X';
      e7:	c6 45 f7 58          	movb   $0x58,-0x9(%ebp)
        read(pipes->from_child[0], &c, 1);
      eb:	83 ec 04             	sub    $0x4,%esp
      ee:	6a 01                	push   $0x1
      f0:	8d 55 f7             	lea    -0x9(%ebp),%edx
      f3:	52                   	push   %edx
      f4:	50                   	push   %eax
      f5:	e8 14 2f 00 00       	call   300e <read>
        if (c != 'S') CRASH("problem communicating with child process via pipe");
      fa:	83 c4 10             	add    $0x10,%esp
      fd:	80 7d f7 53          	cmpb   $0x53,-0x9(%ebp)
     101:	75 17                	jne    11a <_pipe_sync_parent+0x4e>
        write(pipes->to_child[1], "S", 1);
     103:	83 ec 04             	sub    $0x4,%esp
     106:	6a 01                	push   $0x1
     108:	68 cc 32 00 00       	push   $0x32cc
     10d:	ff 73 04             	push   0x4(%ebx)
     110:	e8 01 2f 00 00       	call   3016 <write>
     115:	83 c4 10             	add    $0x10,%esp
     118:	eb c3                	jmp    dd <_pipe_sync_parent+0x11>
        if (c != 'S') CRASH("problem communicating with child process via pipe");
     11a:	b8 48 39 00 00       	mov    $0x3948,%eax
     11f:	e8 90 ff ff ff       	call   b4 <CRASH>

00000124 <_pipe_recv_parent>:
void _pipe_recv_parent(struct test_pipes *pipes, int *values, int *value_count) {
     124:	55                   	push   %ebp
     125:	89 e5                	mov    %esp,%ebp
     127:	57                   	push   %edi
     128:	56                   	push   %esi
     129:	53                   	push   %ebx
     12a:	83 ec 1c             	sub    $0x1c,%esp
     12d:	89 c6                	mov    %eax,%esi
    if (pipes->from_child[0] != -1) {
     12f:	8b 40 08             	mov    0x8(%eax),%eax
     132:	83 f8 ff             	cmp    $0xffffffff,%eax
     135:	75 08                	jne    13f <_pipe_recv_parent+0x1b>
}
     137:	8d 65 f4             	lea    -0xc(%ebp),%esp
     13a:	5b                   	pop    %ebx
     13b:	5e                   	pop    %esi
     13c:	5f                   	pop    %edi
     13d:	5d                   	pop    %ebp
     13e:	c3                   	ret    
     13f:	89 d7                	mov    %edx,%edi
     141:	89 cb                	mov    %ecx,%ebx
        int actual_value_count = 0;
     143:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        int result = read(pipes->from_child[0], &actual_value_count, 4);
     14a:	83 ec 04             	sub    $0x4,%esp
     14d:	6a 04                	push   $0x4
     14f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
     152:	52                   	push   %edx
     153:	50                   	push   %eax
     154:	e8 b5 2e 00 00       	call   300e <read>
        if (result != 4) CRASH("problem communicating with child process via pipe (recv_parent 1)");
     159:	83 c4 10             	add    $0x10,%esp
     15c:	83 f8 04             	cmp    $0x4,%eax
     15f:	75 42                	jne    1a3 <_pipe_recv_parent+0x7f>
        if (*value_count > actual_value_count) {
     161:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     164:	39 03                	cmp    %eax,(%ebx)
     166:	7f 45                	jg     1ad <_pipe_recv_parent+0x89>
        *value_count = actual_value_count;
     168:	89 03                	mov    %eax,(%ebx)
        values[0] = 0; // write to ensure read() does not trigger copy-on-write
     16a:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
        int offset = 0;
     170:	bb 00 00 00 00       	mov    $0x0,%ebx
                actual_value_count * 4 - offset);
     175:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     178:	c1 e0 02             	shl    $0x2,%eax
            result = read(
     17b:	83 ec 04             	sub    $0x4,%esp
     17e:	29 d8                	sub    %ebx,%eax
     180:	50                   	push   %eax
     181:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
     184:	50                   	push   %eax
     185:	ff 76 08             	push   0x8(%esi)
     188:	e8 81 2e 00 00       	call   300e <read>
            if (result == -1) {
     18d:	83 c4 10             	add    $0x10,%esp
     190:	83 f8 ff             	cmp    $0xffffffff,%eax
     193:	74 22                	je     1b7 <_pipe_recv_parent+0x93>
            offset += result;
     195:	01 c3                	add    %eax,%ebx
        } while (offset != actual_value_count * 4);
     197:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     19a:	c1 e0 02             	shl    $0x2,%eax
     19d:	39 d8                	cmp    %ebx,%eax
     19f:	75 d4                	jne    175 <_pipe_recv_parent+0x51>
     1a1:	eb 94                	jmp    137 <_pipe_recv_parent+0x13>
        if (result != 4) CRASH("problem communicating with child process via pipe (recv_parent 1)");
     1a3:	b8 7c 39 00 00       	mov    $0x397c,%eax
     1a8:	e8 07 ff ff ff       	call   b4 <CRASH>
            CRASH("too many values being sent from child");
     1ad:	b8 c0 39 00 00       	mov    $0x39c0,%eax
     1b2:	e8 fd fe ff ff       	call   b4 <CRASH>
                CRASH("problem communicating with child process via pipe (recv_parent 2)");
     1b7:	b8 e8 39 00 00       	mov    $0x39e8,%eax
     1bc:	e8 f3 fe ff ff       	call   b4 <CRASH>

000001c1 <_pipe_sync_child>:
void _pipe_sync_child(struct test_pipes *pipes) {
     1c1:	55                   	push   %ebp
     1c2:	89 e5                	mov    %esp,%ebp
     1c4:	53                   	push   %ebx
     1c5:	83 ec 14             	sub    $0x14,%esp
     1c8:	89 c3                	mov    %eax,%ebx
    if (pipes->from_child[1] != -1) {
     1ca:	8b 40 0c             	mov    0xc(%eax),%eax
     1cd:	83 f8 ff             	cmp    $0xffffffff,%eax
     1d0:	75 05                	jne    1d7 <_pipe_sync_child+0x16>
}
     1d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     1d5:	c9                   	leave  
     1d6:	c3                   	ret    
        write(pipes->from_child[1], "S", 1);
     1d7:	83 ec 04             	sub    $0x4,%esp
     1da:	6a 01                	push   $0x1
     1dc:	68 cc 32 00 00       	push   $0x32cc
     1e1:	50                   	push   %eax
     1e2:	e8 2f 2e 00 00       	call   3016 <write>
        char c = 'X';
     1e7:	c6 45 f7 58          	movb   $0x58,-0x9(%ebp)
        read(pipes->to_child[0], &c, 1);
     1eb:	83 c4 0c             	add    $0xc,%esp
     1ee:	6a 01                	push   $0x1
     1f0:	8d 45 f7             	lea    -0x9(%ebp),%eax
     1f3:	50                   	push   %eax
     1f4:	ff 33                	push   (%ebx)
     1f6:	e8 13 2e 00 00       	call   300e <read>
        if (c != 'S') CRASH("problem communicating with parent process via pipe");
     1fb:	83 c4 10             	add    $0x10,%esp
     1fe:	80 7d f7 53          	cmpb   $0x53,-0x9(%ebp)
     202:	74 ce                	je     1d2 <_pipe_sync_child+0x11>
     204:	b8 2c 3a 00 00       	mov    $0x3a2c,%eax
     209:	e8 a6 fe ff ff       	call   b4 <CRASH>

0000020e <save_ppns>:
static int save_ppns(int pid, int start_address, int end_address, int allow_missing) {
     20e:	55                   	push   %ebp
     20f:	89 e5                	mov    %esp,%ebp
     211:	57                   	push   %edi
     212:	56                   	push   %esi
     213:	53                   	push   %ebx
     214:	83 ec 1c             	sub    $0x1c,%esp
     217:	89 c7                	mov    %eax,%edi
     219:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (int i = start_address; i < end_address; i += PGSIZE) {
     21c:	89 d6                	mov    %edx,%esi
     21e:	89 cb                	mov    %ecx,%ebx
     220:	eb 23                	jmp    245 <save_ppns+0x37>
                printf(2, "ERROR: invalid physical page 0 allocated for virtual page 0x%x\n",
     222:	89 c3                	mov    %eax,%ebx
     224:	83 ec 04             	sub    $0x4,%esp
     227:	56                   	push   %esi
     228:	68 60 3a 00 00       	push   $0x3a60
     22d:	6a 02                	push   $0x2
     22f:	e8 2f 2f 00 00       	call   3163 <printf>
                return 0;
     234:	83 c4 10             	add    $0x10,%esp
     237:	eb 76                	jmp    2af <save_ppns+0xa1>
        } else if (!allow_missing) {
     239:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     23d:	74 51                	je     290 <save_ppns+0x82>
    for (int i = start_address; i < end_address; i += PGSIZE) {
     23f:	81 c6 00 10 00 00    	add    $0x1000,%esi
     245:	39 de                	cmp    %ebx,%esi
     247:	7d 61                	jge    2aa <save_ppns+0x9c>
        uint pte = getpagetableentry(pid, i);
     249:	83 ec 08             	sub    $0x8,%esp
     24c:	56                   	push   %esi
     24d:	57                   	push   %edi
     24e:	e8 4b 2e 00 00       	call   309e <getpagetableentry>
        if (pte & PTE_P) {
     253:	83 c4 10             	add    $0x10,%esp
     256:	a8 01                	test   $0x1,%al
     258:	74 df                	je     239 <save_ppns+0x2b>
            if (saved_ppn_index >= SAVED_PPN_COUNT / 2 && ((start_address >> PTXSHIFT) & 0xF) != 0) {
     25a:	8b 15 70 59 00 00    	mov    0x5970,%edx
     260:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
     266:	7e 09                	jle    271 <save_ppns+0x63>
     268:	f7 45 e4 00 f0 00 00 	testl  $0xf000,-0x1c(%ebp)
     26f:	75 ce                	jne    23f <save_ppns+0x31>
            if (saved_ppn_index >= SAVED_PPN_COUNT) {
     271:	81 fa ff 07 00 00    	cmp    $0x7ff,%edx
     277:	7f c6                	jg     23f <save_ppns+0x31>
            saved_ppns[saved_ppn_index] = PTE_ADDR(pte) >> PTXSHIFT;
     279:	c1 e8 0c             	shr    $0xc,%eax
     27c:	89 04 95 80 59 00 00 	mov    %eax,0x5980(,%edx,4)
            if (saved_ppns[saved_ppn_index] == 0) {
     283:	74 9d                	je     222 <save_ppns+0x14>
            saved_ppn_index += 1;
     285:	83 c2 01             	add    $0x1,%edx
     288:	89 15 70 59 00 00    	mov    %edx,0x5970
     28e:	eb af                	jmp    23f <save_ppns+0x31>
            printf(2, "ERROR: expected pid %d to have address %x allocated,\n"
     290:	83 ec 0c             	sub    $0xc,%esp
     293:	50                   	push   %eax
     294:	56                   	push   %esi
     295:	57                   	push   %edi
     296:	68 a0 3a 00 00       	push   $0x3aa0
     29b:	6a 02                	push   $0x2
     29d:	e8 c1 2e 00 00       	call   3163 <printf>
            return 0;
     2a2:	83 c4 20             	add    $0x20,%esp
     2a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
     2a8:	eb 05                	jmp    2af <save_ppns+0xa1>
    return 1;
     2aa:	bb 01 00 00 00       	mov    $0x1,%ebx
}
     2af:	89 d8                	mov    %ebx,%eax
     2b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
     2b4:	5b                   	pop    %ebx
     2b5:	5e                   	pop    %esi
     2b6:	5f                   	pop    %edi
     2b7:	5d                   	pop    %ebp
     2b8:	c3                   	ret    

000002b9 <_same_pte_range>:
int _same_pte_range(int pid_one, int pid_two, int start_va, int end_va, char *explain) {
     2b9:	55                   	push   %ebp
     2ba:	89 e5                	mov    %esp,%ebp
     2bc:	57                   	push   %edi
     2bd:	56                   	push   %esi
     2be:	53                   	push   %ebx
     2bf:	83 ec 1c             	sub    $0x1c,%esp
     2c2:	89 c6                	mov    %eax,%esi
     2c4:	89 d7                	mov    %edx,%edi
     2c6:	89 cb                	mov    %ecx,%ebx
    for (int addr = start_va; addr < end_va; addr += PGSIZE) {
     2c8:	eb 06                	jmp    2d0 <_same_pte_range+0x17>
     2ca:	81 c3 00 10 00 00    	add    $0x1000,%ebx
     2d0:	3b 5d 08             	cmp    0x8(%ebp),%ebx
     2d3:	7d 43                	jge    318 <_same_pte_range+0x5f>
        uint pte_one = getpagetableentry(pid_one, addr);
     2d5:	83 ec 08             	sub    $0x8,%esp
     2d8:	53                   	push   %ebx
     2d9:	56                   	push   %esi
     2da:	e8 bf 2d 00 00       	call   309e <getpagetableentry>
     2df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        uint pte_two = getpagetableentry(pid_two, addr);
     2e2:	83 c4 08             	add    $0x8,%esp
     2e5:	53                   	push   %ebx
     2e6:	57                   	push   %edi
     2e7:	e8 b2 2d 00 00       	call   309e <getpagetableentry>
        if (PTE_ADDR(pte_one) != PTE_ADDR(pte_two)) {
     2ec:	33 45 e4             	xor    -0x1c(%ebp),%eax
     2ef:	83 c4 10             	add    $0x10,%esp
     2f2:	a9 00 f0 ff ff       	test   $0xfffff000,%eax
     2f7:	74 d1                	je     2ca <_same_pte_range+0x11>
            printf(2, "ERROR: virtual address 0x%x%s assigned to different physical addresses in pids %d and %d\n",
     2f9:	83 ec 08             	sub    $0x8,%esp
     2fc:	57                   	push   %edi
     2fd:	56                   	push   %esi
     2fe:	ff 75 0c             	push   0xc(%ebp)
     301:	53                   	push   %ebx
     302:	68 28 3b 00 00       	push   $0x3b28
     307:	6a 02                	push   $0x2
     309:	e8 55 2e 00 00       	call   3163 <printf>
            return 0;
     30e:	83 c4 20             	add    $0x20,%esp
     311:	b8 00 00 00 00       	mov    $0x0,%eax
     316:	eb 05                	jmp    31d <_same_pte_range+0x64>
    return 1;
     318:	b8 01 00 00 00       	mov    $0x1,%eax
}
     31d:	8d 65 f4             	lea    -0xc(%ebp),%esp
     320:	5b                   	pop    %ebx
     321:	5e                   	pop    %esi
     322:	5f                   	pop    %edi
     323:	5d                   	pop    %ebp
     324:	c3                   	ret    

00000325 <_different_pte_range>:
int _different_pte_range(int pid_one, int pid_two, int start_va, int end_va, char *explain) {
     325:	55                   	push   %ebp
     326:	89 e5                	mov    %esp,%ebp
     328:	57                   	push   %edi
     329:	56                   	push   %esi
     32a:	53                   	push   %ebx
     32b:	83 ec 1c             	sub    $0x1c,%esp
     32e:	89 c6                	mov    %eax,%esi
     330:	89 d7                	mov    %edx,%edi
     332:	89 cb                	mov    %ecx,%ebx
    for (int addr = start_va; addr < end_va; addr += PGSIZE) {
     334:	eb 06                	jmp    33c <_different_pte_range+0x17>
     336:	81 c3 00 10 00 00    	add    $0x1000,%ebx
     33c:	3b 5d 08             	cmp    0x8(%ebp),%ebx
     33f:	7d 43                	jge    384 <_different_pte_range+0x5f>
        uint pte_one = getpagetableentry(pid_one, addr);
     341:	83 ec 08             	sub    $0x8,%esp
     344:	53                   	push   %ebx
     345:	56                   	push   %esi
     346:	e8 53 2d 00 00       	call   309e <getpagetableentry>
     34b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        uint pte_two = getpagetableentry(pid_two, addr);
     34e:	83 c4 08             	add    $0x8,%esp
     351:	53                   	push   %ebx
     352:	57                   	push   %edi
     353:	e8 46 2d 00 00       	call   309e <getpagetableentry>
        if (PTE_ADDR(pte_one) == PTE_ADDR(pte_two)) {
     358:	33 45 e4             	xor    -0x1c(%ebp),%eax
     35b:	83 c4 10             	add    $0x10,%esp
     35e:	a9 00 f0 ff ff       	test   $0xfffff000,%eax
     363:	75 d1                	jne    336 <_different_pte_range+0x11>
            printf(2, "ERROR: virtual address 0x%x%s assigned same physical addresses in pids %d and %d\n",
     365:	83 ec 08             	sub    $0x8,%esp
     368:	57                   	push   %edi
     369:	56                   	push   %esi
     36a:	ff 75 0c             	push   0xc(%ebp)
     36d:	53                   	push   %ebx
     36e:	68 84 3b 00 00       	push   $0x3b84
     373:	6a 02                	push   $0x2
     375:	e8 e9 2d 00 00       	call   3163 <printf>
            return 0;
     37a:	83 c4 20             	add    $0x20,%esp
     37d:	b8 00 00 00 00       	mov    $0x0,%eax
     382:	eb 05                	jmp    389 <_different_pte_range+0x64>
    return 1;
     384:	b8 01 00 00 00       	mov    $0x1,%eax
}
     389:	8d 65 f4             	lea    -0xc(%ebp),%esp
     38c:	5b                   	pop    %ebx
     38d:	5e                   	pop    %esi
     38e:	5f                   	pop    %edi
     38f:	5d                   	pop    %ebp
     390:	c3                   	ret    

00000391 <verify_ppns_freed>:
static int verify_ppns_freed(const char *descr) {
     391:	55                   	push   %ebp
     392:	89 e5                	mov    %esp,%ebp
     394:	57                   	push   %edi
     395:	56                   	push   %esi
     396:	53                   	push   %ebx
     397:	83 ec 0c             	sub    $0xc,%esp
     39a:	89 c7                	mov    %eax,%edi
    for (int i = 0; i < saved_ppn_index; i += 1) {
     39c:	be 00 00 00 00       	mov    $0x0,%esi
     3a1:	eb 03                	jmp    3a6 <verify_ppns_freed+0x15>
     3a3:	83 c6 01             	add    $0x1,%esi
     3a6:	39 35 70 59 00 00    	cmp    %esi,0x5970
     3ac:	7e 35                	jle    3e3 <verify_ppns_freed+0x52>
        if (!isphysicalpagefree(saved_ppns[i])) {
     3ae:	83 ec 0c             	sub    $0xc,%esp
     3b1:	ff 34 b5 80 59 00 00 	push   0x5980(,%esi,4)
     3b8:	e8 e9 2c 00 00       	call   30a6 <isphysicalpagefree>
     3bd:	89 c3                	mov    %eax,%ebx
     3bf:	83 c4 10             	add    $0x10,%esp
     3c2:	85 c0                	test   %eax,%eax
     3c4:	75 dd                	jne    3a3 <verify_ppns_freed+0x12>
            printf(2, "ERROR: physical page 0x%x (%s) not freed\n",
     3c6:	83 ec 0c             	sub    $0xc,%esp
     3c9:	56                   	push   %esi
     3ca:	57                   	push   %edi
     3cb:	ff 34 b5 80 59 00 00 	push   0x5980(,%esi,4)
     3d2:	68 d8 3b 00 00       	push   $0x3bd8
     3d7:	6a 02                	push   $0x2
     3d9:	e8 85 2d 00 00       	call   3163 <printf>
            return 0;
     3de:	83 c4 20             	add    $0x20,%esp
     3e1:	eb 05                	jmp    3e8 <verify_ppns_freed+0x57>
    return 1;
     3e3:	bb 01 00 00 00       	mov    $0x1,%ebx
}
     3e8:	89 d8                	mov    %ebx,%eax
     3ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
     3ed:	5b                   	pop    %ebx
     3ee:	5e                   	pop    %esi
     3ef:	5f                   	pop    %edi
     3f0:	5d                   	pop    %ebp
     3f1:	c3                   	ret    

000003f2 <_sanity_check_range>:
                        const char *explain) {
     3f2:	55                   	push   %ebp
     3f3:	89 e5                	mov    %esp,%ebp
     3f5:	57                   	push   %edi
     3f6:	56                   	push   %esi
     3f7:	53                   	push   %ebx
     3f8:	83 ec 1c             	sub    $0x1c,%esp
     3fb:	89 c7                	mov    %eax,%edi
     3fd:	89 d6                	mov    %edx,%esi
     3ff:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
    for (int addr = start_va; addr < end_va; addr += PGSIZE) {
     402:	eb 64                	jmp    468 <_sanity_check_range+0x76>
        } else if (allocate_flag == NOT_ALLOCATED) {
     404:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
     408:	0f 84 9d 00 00 00    	je     4ab <_sanity_check_range+0xb9>

#ifndef __ASSEMBLER__
// Address in page table or page directory entry
//   I changes these from macros into inline functions to make sure we
//   consistently get an error if a pointer is erroneously passed to them.
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
     40e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
     413:	89 45 e0             	mov    %eax,-0x20(%ebp)
     416:	89 d8                	mov    %ebx,%eax
     418:	c1 e8 0c             	shr    $0xc,%eax
     41b:	89 45 dc             	mov    %eax,-0x24(%ebp)
            if (isphysicalpagefree(PTE_ADDR(pte) >> PTXSHIFT)) {
     41e:	83 ec 0c             	sub    $0xc,%esp
     421:	50                   	push   %eax
     422:	e8 7f 2c 00 00       	call   30a6 <isphysicalpagefree>
     427:	83 c4 10             	add    $0x10,%esp
     42a:	85 c0                	test   %eax,%eax
     42c:	0f 85 9a 00 00 00    	jne    4cc <_sanity_check_range+0xda>
            if (PTE_ADDR(pte) == 0) {
     432:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     436:	0f 84 af 00 00 00    	je     4eb <_sanity_check_range+0xf9>
            if (pte & PTE_U) {
     43c:	f6 c3 04             	test   $0x4,%bl
     43f:	0f 84 e0 00 00 00    	je     525 <_sanity_check_range+0x133>
                if (prot_flag == IS_GUARD) {
     445:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
     449:	0f 84 b8 00 00 00    	je     507 <_sanity_check_range+0x115>
            if (pte & PTE_W) {
     44f:	f6 c3 02             	test   $0x2,%bl
     452:	0f 84 13 01 00 00    	je     56b <_sanity_check_range+0x179>
                if (prot_flag == IS_SHARED) {
     458:	83 7d 0c 02          	cmpl   $0x2,0xc(%ebp)
     45c:	0f 84 eb 00 00 00    	je     54d <_sanity_check_range+0x15b>
    for (int addr = start_va; addr < end_va; addr += PGSIZE) {
     462:	81 c6 00 10 00 00    	add    $0x1000,%esi
     468:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
     46b:	0f 8d 22 01 00 00    	jge    593 <_sanity_check_range+0x1a1>
        uint pte = getpagetableentry(pid, addr);
     471:	83 ec 08             	sub    $0x8,%esp
     474:	56                   	push   %esi
     475:	57                   	push   %edi
     476:	e8 23 2c 00 00       	call   309e <getpagetableentry>
     47b:	89 c3                	mov    %eax,%ebx
        if (!(pte & PTE_P)) {
     47d:	83 c4 10             	add    $0x10,%esp
     480:	a8 01                	test   $0x1,%al
     482:	75 80                	jne    404 <_sanity_check_range+0x12>
            if (allocate_flag == IS_ALLOCATED) {
     484:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
     488:	75 d8                	jne    462 <_sanity_check_range+0x70>
                printf(2, "ERROR: pid %d, address 0x%x%s not allocated (expected allocated)\n"
     48a:	83 ec 0c             	sub    $0xc,%esp
     48d:	ff 75 14             	push   0x14(%ebp)
     490:	56                   	push   %esi
     491:	57                   	push   %edi
     492:	68 04 3c 00 00       	push   $0x3c04
     497:	6a 02                	push   $0x2
     499:	e8 c5 2c 00 00       	call   3163 <printf>
                return 0;
     49e:	83 c4 20             	add    $0x20,%esp
     4a1:	b8 00 00 00 00       	mov    $0x0,%eax
     4a6:	e9 ed 00 00 00       	jmp    598 <_sanity_check_range+0x1a6>
            printf(2, "ERROR: pid %d, address 0x%x%s is allocated (expected not allocated)\n"
     4ab:	83 ec 0c             	sub    $0xc,%esp
     4ae:	ff 75 14             	push   0x14(%ebp)
     4b1:	56                   	push   %esi
     4b2:	57                   	push   %edi
     4b3:	68 70 3c 00 00       	push   $0x3c70
     4b8:	6a 02                	push   $0x2
     4ba:	e8 a4 2c 00 00       	call   3163 <printf>
            return 0;
     4bf:	83 c4 20             	add    $0x20,%esp
     4c2:	b8 00 00 00 00       	mov    $0x0,%eax
     4c7:	e9 cc 00 00 00       	jmp    598 <_sanity_check_range+0x1a6>
                printf(2, "ERROR: pid %d address 0x%x%s allocated freed physical page 0x%x\n"
     4cc:	83 ec 08             	sub    $0x8,%esp
     4cf:	ff 75 dc             	push   -0x24(%ebp)
     4d2:	ff 75 14             	push   0x14(%ebp)
     4d5:	56                   	push   %esi
     4d6:	57                   	push   %edi
     4d7:	68 e0 3c 00 00       	push   $0x3ce0
     4dc:	6a 02                	push   $0x2
     4de:	e8 80 2c 00 00       	call   3163 <printf>
     4e3:	83 c4 20             	add    $0x20,%esp
     4e6:	e9 47 ff ff ff       	jmp    432 <_sanity_check_range+0x40>
                printf(2, "ERROR: pid %d address 0x%x%s allocated invalid physical page 0\n"
     4eb:	83 ec 0c             	sub    $0xc,%esp
     4ee:	ff 75 14             	push   0x14(%ebp)
     4f1:	56                   	push   %esi
     4f2:	57                   	push   %edi
     4f3:	68 64 3d 00 00       	push   $0x3d64
     4f8:	6a 02                	push   $0x2
     4fa:	e8 64 2c 00 00       	call   3163 <printf>
     4ff:	83 c4 20             	add    $0x20,%esp
     502:	e9 35 ff ff ff       	jmp    43c <_sanity_check_range+0x4a>
                    printf(2, "ERROR: pid %d, address 0x%x%s is user-accessible (expected not)\n"
     507:	83 ec 0c             	sub    $0xc,%esp
     50a:	ff 75 14             	push   0x14(%ebp)
     50d:	56                   	push   %esi
     50e:	57                   	push   %edi
     50f:	68 e4 3d 00 00       	push   $0x3de4
     514:	6a 02                	push   $0x2
     516:	e8 48 2c 00 00       	call   3163 <printf>
                    return 0;
     51b:	83 c4 20             	add    $0x20,%esp
     51e:	b8 00 00 00 00       	mov    $0x0,%eax
     523:	eb 73                	jmp    598 <_sanity_check_range+0x1a6>
                if (prot_flag != IS_GUARD) {
     525:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
     529:	0f 84 20 ff ff ff    	je     44f <_sanity_check_range+0x5d>
                    printf(2, "ERROR: pid %d, address 0x%x%s not user-accessible (expected to be)\n"
     52f:	83 ec 0c             	sub    $0xc,%esp
     532:	ff 75 14             	push   0x14(%ebp)
     535:	56                   	push   %esi
     536:	57                   	push   %edi
     537:	68 50 3e 00 00       	push   $0x3e50
     53c:	6a 02                	push   $0x2
     53e:	e8 20 2c 00 00       	call   3163 <printf>
                    return 0;
     543:	83 c4 20             	add    $0x20,%esp
     546:	b8 00 00 00 00       	mov    $0x0,%eax
     54b:	eb 4b                	jmp    598 <_sanity_check_range+0x1a6>
                    printf(2, "ERROR: pid %d, address 0x%x%s is writable (expected not be)\n"
     54d:	83 ec 0c             	sub    $0xc,%esp
     550:	ff 75 14             	push   0x14(%ebp)
     553:	56                   	push   %esi
     554:	57                   	push   %edi
     555:	68 c0 3e 00 00       	push   $0x3ec0
     55a:	6a 02                	push   $0x2
     55c:	e8 02 2c 00 00       	call   3163 <printf>
                    return 0;
     561:	83 c4 20             	add    $0x20,%esp
     564:	b8 00 00 00 00       	mov    $0x0,%eax
     569:	eb 2d                	jmp    598 <_sanity_check_range+0x1a6>
                if (prot_flag == NOT_SHARED) {
     56b:	83 7d 0c 04          	cmpl   $0x4,0xc(%ebp)
     56f:	0f 85 ed fe ff ff    	jne    462 <_sanity_check_range+0x70>
                    printf(2, "ERROR: pid %d, address 0x%x%s is not writable (expected to be)\n"
     575:	83 ec 0c             	sub    $0xc,%esp
     578:	ff 75 14             	push   0x14(%ebp)
     57b:	56                   	push   %esi
     57c:	57                   	push   %edi
     57d:	68 28 3f 00 00       	push   $0x3f28
     582:	6a 02                	push   $0x2
     584:	e8 da 2b 00 00       	call   3163 <printf>
                    return 0;
     589:	83 c4 20             	add    $0x20,%esp
     58c:	b8 00 00 00 00       	mov    $0x0,%eax
     591:	eb 05                	jmp    598 <_sanity_check_range+0x1a6>
    return 1;
     593:	b8 01 00 00 00       	mov    $0x1,%eax
}
     598:	8d 65 f4             	lea    -0xc(%ebp),%esp
     59b:	5b                   	pop    %ebx
     59c:	5e                   	pop    %esi
     59d:	5f                   	pop    %edi
     59e:	5d                   	pop    %ebp
     59f:	c3                   	ret    

000005a0 <_sanity_check_range_self>:
        const char *explain) {
     5a0:	55                   	push   %ebp
     5a1:	89 e5                	mov    %esp,%ebp
     5a3:	57                   	push   %edi
     5a4:	56                   	push   %esi
     5a5:	53                   	push   %ebx
     5a6:	83 ec 0c             	sub    $0xc,%esp
     5a9:	89 c3                	mov    %eax,%ebx
     5ab:	89 d6                	mov    %edx,%esi
     5ad:	89 cf                	mov    %ecx,%edi
    return _sanity_check_range(getpid(), start_va, end_va, allocate_flag, guard_flag, free_check, explain);
     5af:	e8 c2 2a 00 00       	call   3076 <getpid>
     5b4:	ff 75 10             	push   0x10(%ebp)
     5b7:	ff 75 0c             	push   0xc(%ebp)
     5ba:	ff 75 08             	push   0x8(%ebp)
     5bd:	57                   	push   %edi
     5be:	89 f1                	mov    %esi,%ecx
     5c0:	89 da                	mov    %ebx,%edx
     5c2:	e8 2b fe ff ff       	call   3f2 <_sanity_check_range>
}
     5c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
     5ca:	5b                   	pop    %ebx
     5cb:	5e                   	pop    %esi
     5cc:	5f                   	pop    %edi
     5cd:	5d                   	pop    %ebp
     5ce:	c3                   	ret    

000005cf <_sanity_check_self_nonheap>:
MAYBE_UNUSED static TestResult _sanity_check_self_nonheap(int free_check) {
     5cf:	55                   	push   %ebp
     5d0:	89 e5                	mov    %esp,%ebp
     5d2:	56                   	push   %esi
     5d3:	53                   	push   %ebx
     5d4:	89 c6                	mov    %eax,%esi
    uint guard = _get_guard();
     5d6:	e8 25 fa ff ff       	call   0 <_get_guard>
     5db:	89 c3                	mov    %eax,%ebx
    if (!_sanity_check_range_self(0, guard, IS_ALLOCATED, NOT_GUARD, free_check, " (memory before guard page, before new allocation)")) {
     5dd:	83 ec 04             	sub    $0x4,%esp
     5e0:	68 94 3f 00 00       	push   $0x3f94
     5e5:	56                   	push   %esi
     5e6:	6a 00                	push   $0x0
     5e8:	b9 01 00 00 00       	mov    $0x1,%ecx
     5ed:	89 c2                	mov    %eax,%edx
     5ef:	b8 00 00 00 00       	mov    $0x0,%eax
     5f4:	e8 a7 ff ff ff       	call   5a0 <_sanity_check_range_self>
     5f9:	83 c4 10             	add    $0x10,%esp
     5fc:	85 c0                	test   %eax,%eax
     5fe:	74 30                	je     630 <_sanity_check_self_nonheap+0x61>
    if (!_sanity_check_range_self(guard, guard + PGSIZE, IS_ALLOCATED, IS_GUARD, free_check, " (guard page)")) {
     600:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
     606:	83 ec 04             	sub    $0x4,%esp
     609:	68 ce 32 00 00       	push   $0x32ce
     60e:	56                   	push   %esi
     60f:	6a 01                	push   $0x1
     611:	b9 01 00 00 00       	mov    $0x1,%ecx
     616:	89 d8                	mov    %ebx,%eax
     618:	e8 83 ff ff ff       	call   5a0 <_sanity_check_range_self>
     61d:	83 c4 10             	add    $0x10,%esp
     620:	85 c0                	test   %eax,%eax
     622:	74 13                	je     637 <_sanity_check_self_nonheap+0x68>
    return TR_SUCCESS;
     624:	b8 00 00 00 00       	mov    $0x0,%eax
}
     629:	8d 65 f8             	lea    -0x8(%ebp),%esp
     62c:	5b                   	pop    %ebx
     62d:	5e                   	pop    %esi
     62e:	5d                   	pop    %ebp
     62f:	c3                   	ret    
        return TR_FAIL_PTE;
     630:	b8 02 00 00 00       	mov    $0x2,%eax
     635:	eb f2                	jmp    629 <_sanity_check_self_nonheap+0x5a>
        return TR_FAIL_PTE;
     637:	b8 02 00 00 00       	mov    $0x2,%eax
     63c:	eb eb                	jmp    629 <_sanity_check_self_nonheap+0x5a>

0000063e <_init_pipes>:
int _init_pipes(struct test_pipes *pipes) {
     63e:	55                   	push   %ebp
     63f:	89 e5                	mov    %esp,%ebp
     641:	53                   	push   %ebx
     642:	83 ec 10             	sub    $0x10,%esp
     645:	89 c3                	mov    %eax,%ebx
    pipes->from_child[0] = -1;
     647:	c7 40 08 ff ff ff ff 	movl   $0xffffffff,0x8(%eax)
    pipes->from_child[1] = -1;
     64e:	c7 40 0c ff ff ff ff 	movl   $0xffffffff,0xc(%eax)
    if (pipe(pipes->from_child) < 0)
     655:	8d 40 08             	lea    0x8(%eax),%eax
     658:	50                   	push   %eax
     659:	e8 a8 29 00 00       	call   3006 <pipe>
     65e:	83 c4 10             	add    $0x10,%esp
     661:	85 c0                	test   %eax,%eax
     663:	78 27                	js     68c <_init_pipes+0x4e>
    pipes->to_child[0] = -1;
     665:	c7 03 ff ff ff ff    	movl   $0xffffffff,(%ebx)
    pipes->to_child[1] = -1;
     66b:	c7 43 04 ff ff ff ff 	movl   $0xffffffff,0x4(%ebx)
    if (pipe(pipes->to_child) < 0)
     672:	83 ec 0c             	sub    $0xc,%esp
     675:	53                   	push   %ebx
     676:	e8 8b 29 00 00       	call   3006 <pipe>
     67b:	83 c4 10             	add    $0x10,%esp
     67e:	85 c0                	test   %eax,%eax
     680:	78 14                	js     696 <_init_pipes+0x58>
}
     682:	b8 00 00 00 00       	mov    $0x0,%eax
     687:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     68a:	c9                   	leave  
     68b:	c3                   	ret    
        CRASH("error creating pipes");
     68c:	b8 dc 32 00 00       	mov    $0x32dc,%eax
     691:	e8 1e fa ff ff       	call   b4 <CRASH>
        CRASH("error creating pipes");
     696:	b8 dc 32 00 00       	mov    $0x32dc,%eax
     69b:	e8 14 fa ff ff       	call   b4 <CRASH>

000006a0 <_pipe_sync_cleanup>:
void _pipe_sync_cleanup(struct test_pipes *pipes) {
     6a0:	55                   	push   %ebp
     6a1:	89 e5                	mov    %esp,%ebp
     6a3:	53                   	push   %ebx
     6a4:	83 ec 04             	sub    $0x4,%esp
     6a7:	89 c3                	mov    %eax,%ebx
    if (pipes->from_child[0] != -1)
     6a9:	8b 40 08             	mov    0x8(%eax),%eax
     6ac:	83 f8 ff             	cmp    $0xffffffff,%eax
     6af:	75 1c                	jne    6cd <_pipe_sync_cleanup+0x2d>
    if (pipes->from_child[1] != -1)
     6b1:	8b 43 0c             	mov    0xc(%ebx),%eax
     6b4:	83 f8 ff             	cmp    $0xffffffff,%eax
     6b7:	75 22                	jne    6db <_pipe_sync_cleanup+0x3b>
    if (pipes->to_child[0] != -1)
     6b9:	8b 03                	mov    (%ebx),%eax
     6bb:	83 f8 ff             	cmp    $0xffffffff,%eax
     6be:	75 29                	jne    6e9 <_pipe_sync_cleanup+0x49>
    if (pipes->to_child[1] != -1)
     6c0:	8b 43 04             	mov    0x4(%ebx),%eax
     6c3:	83 f8 ff             	cmp    $0xffffffff,%eax
     6c6:	75 2f                	jne    6f7 <_pipe_sync_cleanup+0x57>
}
     6c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     6cb:	c9                   	leave  
     6cc:	c3                   	ret    
        close(pipes->from_child[0]);
     6cd:	83 ec 0c             	sub    $0xc,%esp
     6d0:	50                   	push   %eax
     6d1:	e8 48 29 00 00       	call   301e <close>
     6d6:	83 c4 10             	add    $0x10,%esp
     6d9:	eb d6                	jmp    6b1 <_pipe_sync_cleanup+0x11>
        close(pipes->from_child[1]);
     6db:	83 ec 0c             	sub    $0xc,%esp
     6de:	50                   	push   %eax
     6df:	e8 3a 29 00 00       	call   301e <close>
     6e4:	83 c4 10             	add    $0x10,%esp
     6e7:	eb d0                	jmp    6b9 <_pipe_sync_cleanup+0x19>
        close(pipes->to_child[0]);
     6e9:	83 ec 0c             	sub    $0xc,%esp
     6ec:	50                   	push   %eax
     6ed:	e8 2c 29 00 00       	call   301e <close>
     6f2:	83 c4 10             	add    $0x10,%esp
     6f5:	eb c9                	jmp    6c0 <_pipe_sync_cleanup+0x20>
        close(pipes->to_child[1]);
     6f7:	83 ec 0c             	sub    $0xc,%esp
     6fa:	50                   	push   %eax
     6fb:	e8 1e 29 00 00       	call   301e <close>
     700:	83 c4 10             	add    $0x10,%esp
}
     703:	eb c3                	jmp    6c8 <_pipe_sync_cleanup+0x28>

00000705 <_pipe_sync_setup_child>:
void _pipe_sync_setup_child(struct test_pipes *pipes) {
     705:	55                   	push   %ebp
     706:	89 e5                	mov    %esp,%ebp
     708:	53                   	push   %ebx
     709:	83 ec 10             	sub    $0x10,%esp
     70c:	89 c3                	mov    %eax,%ebx
    close(pipes->from_child[0]);
     70e:	ff 70 08             	push   0x8(%eax)
     711:	e8 08 29 00 00       	call   301e <close>
    pipes->from_child[0] = -1;
     716:	c7 43 08 ff ff ff ff 	movl   $0xffffffff,0x8(%ebx)
    close(pipes->to_child[1]);
     71d:	83 c4 04             	add    $0x4,%esp
     720:	ff 73 04             	push   0x4(%ebx)
     723:	e8 f6 28 00 00       	call   301e <close>
    pipes->to_child[1] = -1;
     728:	c7 43 04 ff ff ff ff 	movl   $0xffffffff,0x4(%ebx)
}
     72f:	83 c4 10             	add    $0x10,%esp
     732:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     735:	c9                   	leave  
     736:	c3                   	ret    

00000737 <_test_exec_child>:
MAYBE_UNUSED static TestResult _test_exec_child(char **argv) {
     737:	55                   	push   %ebp
     738:	89 e5                	mov    %esp,%ebp
     73a:	57                   	push   %edi
     73b:	56                   	push   %esi
     73c:	53                   	push   %ebx
     73d:	83 ec 5c             	sub    $0x5c,%esp
    struct test_pipes pipes = {
     740:	c7 45 d8 03 00 00 00 	movl   $0x3,-0x28(%ebp)
     747:	c7 45 dc 04 00 00 00 	movl   $0x4,-0x24(%ebp)
     74e:	c7 45 e0 05 00 00 00 	movl   $0x5,-0x20(%ebp)
     755:	c7 45 e4 06 00 00 00 	movl   $0x6,-0x1c(%ebp)
    _pipe_sync_setup_child(&pipes);
     75c:	8d 45 d8             	lea    -0x28(%ebp),%eax
     75f:	e8 a1 ff ff ff       	call   705 <_pipe_sync_setup_child>
    _pipe_sync_child(&pipes);
     764:	8d 45 d8             	lea    -0x28(%ebp),%eax
     767:	e8 55 fa ff ff       	call   1c1 <_pipe_sync_child>
    int result = _sanity_check_self_nonheap(WITH_FREE_CHECK);
     76c:	b8 00 00 00 00       	mov    $0x0,%eax
     771:	e8 59 fe ff ff       	call   5cf <_sanity_check_self_nonheap>
     776:	89 c6                	mov    %eax,%esi
    if (result != TR_SUCCESS)
     778:	85 c0                	test   %eax,%eax
     77a:	74 0a                	je     786 <_test_exec_child+0x4f>
}
     77c:	89 f0                	mov    %esi,%eax
     77e:	8d 65 f4             	lea    -0xc(%ebp),%esp
     781:	5b                   	pop    %ebx
     782:	5e                   	pop    %esi
     783:	5f                   	pop    %edi
     784:	5d                   	pop    %ebp
     785:	c3                   	ret    
    _pipe_sync_child(&pipes);
     786:	8d 45 d8             	lea    -0x28(%ebp),%eax
     789:	e8 33 fa ff ff       	call   1c1 <_pipe_sync_child>
    int pte_values[EXEC_TEST_PTE_VALUES] = {0};
     78e:	8d 7d 98             	lea    -0x68(%ebp),%edi
     791:	b9 10 00 00 00       	mov    $0x10,%ecx
     796:	b8 00 00 00 00       	mov    $0x0,%eax
     79b:	f3 ab                	rep stos %eax,%es:(%edi)
    for (int i = 0; i < EXEC_TEST_PTE_VALUES; ++i) {
     79d:	89 f3                	mov    %esi,%ebx
     79f:	eb 1e                	jmp    7bf <_test_exec_child+0x88>
        pte_values[i] = getpagetableentry(getpid(), i << PTXSHIFT);
     7a1:	e8 d0 28 00 00       	call   3076 <getpid>
     7a6:	83 ec 08             	sub    $0x8,%esp
     7a9:	89 da                	mov    %ebx,%edx
     7ab:	c1 e2 0c             	shl    $0xc,%edx
     7ae:	52                   	push   %edx
     7af:	50                   	push   %eax
     7b0:	e8 e9 28 00 00       	call   309e <getpagetableentry>
     7b5:	89 44 9d 98          	mov    %eax,-0x68(%ebp,%ebx,4)
    for (int i = 0; i < EXEC_TEST_PTE_VALUES; ++i) {
     7b9:	83 c3 01             	add    $0x1,%ebx
     7bc:	83 c4 10             	add    $0x10,%esp
     7bf:	83 fb 0f             	cmp    $0xf,%ebx
     7c2:	7e dd                	jle    7a1 <_test_exec_child+0x6a>
    _pipe_send_child(&pipes, pte_values, EXEC_TEST_PTE_VALUES);
     7c4:	b9 10 00 00 00       	mov    $0x10,%ecx
     7c9:	8d 55 98             	lea    -0x68(%ebp),%edx
     7cc:	8d 45 d8             	lea    -0x28(%ebp),%eax
     7cf:	e8 9b f8 ff ff       	call   6f <_pipe_send_child>
    _pipe_sync_child(&pipes);
     7d4:	8d 45 d8             	lea    -0x28(%ebp),%eax
     7d7:	e8 e5 f9 ff ff       	call   1c1 <_pipe_sync_child>
    return TR_SUCCESS;
     7dc:	eb 9e                	jmp    77c <_test_exec_child+0x45>

000007de <_pipe_sync_setup_parent>:
void _pipe_sync_setup_parent(struct test_pipes *pipes) {
     7de:	55                   	push   %ebp
     7df:	89 e5                	mov    %esp,%ebp
     7e1:	53                   	push   %ebx
     7e2:	83 ec 10             	sub    $0x10,%esp
     7e5:	89 c3                	mov    %eax,%ebx
    close(pipes->from_child[1]);
     7e7:	ff 70 0c             	push   0xc(%eax)
     7ea:	e8 2f 28 00 00       	call   301e <close>
    pipes->from_child[1] = -1;
     7ef:	c7 43 0c ff ff ff ff 	movl   $0xffffffff,0xc(%ebx)
    close(pipes->to_child[0]);
     7f6:	83 c4 04             	add    $0x4,%esp
     7f9:	ff 33                	push   (%ebx)
     7fb:	e8 1e 28 00 00       	call   301e <close>
    pipes->to_child[0] = -1;
     800:	c7 03 ff ff ff ff    	movl   $0xffffffff,(%ebx)
}
     806:	83 c4 10             	add    $0x10,%esp
     809:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     80c:	c9                   	leave  
     80d:	c3                   	ret    

0000080e <test_oob>:
        return result;
    }
}

MAYBE_UNUSED
static TestResult test_oob(uint heap_offset, int fork_p, int write_p, int guard_p) {
     80e:	55                   	push   %ebp
     80f:	89 e5                	mov    %esp,%ebp
     811:	57                   	push   %edi
     812:	56                   	push   %esi
     813:	53                   	push   %ebx
     814:	83 ec 1c             	sub    $0x1c,%esp
     817:	89 c3                	mov    %eax,%ebx
     819:	89 d6                	mov    %edx,%esi
     81b:	89 cf                	mov    %ecx,%edi
    if (guard_p) {
     81d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     821:	0f 84 a9 00 00 00    	je     8d0 <test_oob+0xc2>
        if (heap_offset >= 4096) {
     827:	3d ff 0f 00 00       	cmp    $0xfff,%eax
     82c:	76 05                	jbe    833 <test_oob+0x25>
            heap_offset = 4095;
     82e:	bb ff 0f 00 00       	mov    $0xfff,%ebx
        }
        printf(1,
     833:	85 ff                	test   %edi,%edi
     835:	0f 84 8b 00 00 00    	je     8c6 <test_oob+0xb8>
     83b:	b8 f1 32 00 00       	mov    $0x32f1,%eax
     840:	53                   	push   %ebx
     841:	50                   	push   %eax
     842:	68 c8 3f 00 00       	push   $0x3fc8
     847:	6a 01                	push   $0x1
     849:	e8 15 29 00 00       	call   3163 <printf>
     84e:	83 c4 10             	add    $0x10,%esp
    } else {
      printf(1,
          "Testing out of bounds access %s 0x%x bytes after end of heap\n",
          write_p ? "writing" : "reading", heap_offset);
    }
    if (fork_p) {
     851:	85 f6                	test   %esi,%esi
     853:	0f 85 9d 00 00 00    	jne    8f6 <test_oob+0xe8>
        printf(1, "  doing access in child process\n");
    }
    struct test_pipes pipes = NO_PIPES;
     859:	a1 28 58 00 00       	mov    0x5828,%eax
     85e:	89 45 d8             	mov    %eax,-0x28(%ebp)
     861:	a1 2c 58 00 00       	mov    0x582c,%eax
     866:	89 45 dc             	mov    %eax,-0x24(%ebp)
     869:	a1 30 58 00 00       	mov    0x5830,%eax
     86e:	89 45 e0             	mov    %eax,-0x20(%ebp)
     871:	a1 34 58 00 00       	mov    0x5834,%eax
     876:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    int pid = -1;
    int result = TR_FAIL_UNKNOWN;
    if (fork_p) {
     879:	85 f6                	test   %esi,%esi
     87b:	0f 85 8c 00 00 00    	jne    90d <test_oob+0xff>
            _pipe_sync_setup_child(&pipes);
            _pipe_sync_child(&pipes);
        }
    }
    char *p;
    if (guard_p) {
     881:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     885:	0f 84 1e 01 00 00    	je     9a9 <test_oob+0x19b>
      p = (char*) _get_guard() + heap_offset;
     88b:	e8 70 f7 ff ff       	call   0 <_get_guard>
     890:	01 c3                	add    %eax,%ebx
    } else {
      p = sbrk(0) + heap_offset;
    }
    if (write_p) {
     892:	85 ff                	test   %edi,%edi
     894:	0f 84 23 01 00 00    	je     9bd <test_oob+0x1af>
        __asm__ volatile(
     89a:	c6 03 2a             	movb   $0x2a,(%ebx)
            : /* output */
            :"m"(*p) /* input */
            :"%eax" /* clobber */
        );
    }
    if (fork_p) {
     89d:	85 f6                	test   %esi,%esi
     89f:	0f 85 1f 01 00 00    	jne    9c4 <test_oob+0x1b6>
        exit();
    }
    if (result == TR_SUCCESS) {
        printf(1, "Test successful.\n");
    } else {
        printf(1, "Test failed.\n");
     8a5:	83 ec 08             	sub    $0x8,%esp
     8a8:	68 21 33 00 00       	push   $0x3321
     8ad:	6a 01                	push   $0x1
     8af:	e8 af 28 00 00       	call   3163 <printf>
    }
    return result;
     8b4:	83 c4 10             	add    $0x10,%esp
     8b7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
     8bc:	89 d8                	mov    %ebx,%eax
     8be:	8d 65 f4             	lea    -0xc(%ebp),%esp
     8c1:	5b                   	pop    %ebx
     8c2:	5e                   	pop    %esi
     8c3:	5f                   	pop    %edi
     8c4:	5d                   	pop    %ebp
     8c5:	c3                   	ret    
        printf(1,
     8c6:	b8 f9 32 00 00       	mov    $0x32f9,%eax
     8cb:	e9 70 ff ff ff       	jmp    840 <test_oob+0x32>
      printf(1,
     8d0:	85 c9                	test   %ecx,%ecx
     8d2:	74 1b                	je     8ef <test_oob+0xe1>
     8d4:	b8 f1 32 00 00       	mov    $0x32f1,%eax
     8d9:	53                   	push   %ebx
     8da:	50                   	push   %eax
     8db:	68 14 40 00 00       	push   $0x4014
     8e0:	6a 01                	push   $0x1
     8e2:	e8 7c 28 00 00       	call   3163 <printf>
     8e7:	83 c4 10             	add    $0x10,%esp
     8ea:	e9 62 ff ff ff       	jmp    851 <test_oob+0x43>
     8ef:	b8 f9 32 00 00       	mov    $0x32f9,%eax
     8f4:	eb e3                	jmp    8d9 <test_oob+0xcb>
        printf(1, "  doing access in child process\n");
     8f6:	83 ec 08             	sub    $0x8,%esp
     8f9:	68 54 40 00 00       	push   $0x4054
     8fe:	6a 01                	push   $0x1
     900:	e8 5e 28 00 00       	call   3163 <printf>
     905:	83 c4 10             	add    $0x10,%esp
     908:	e9 4c ff ff ff       	jmp    859 <test_oob+0x4b>
        _init_pipes(&pipes);
     90d:	8d 45 d8             	lea    -0x28(%ebp),%eax
     910:	e8 29 fd ff ff       	call   63e <_init_pipes>
        pid = fork();
     915:	e8 d4 26 00 00       	call   2fee <fork>
        if (pid == -1) {
     91a:	83 f8 ff             	cmp    $0xffffffff,%eax
     91d:	74 19                	je     938 <test_oob+0x12a>
        } else if (pid != 0) {
     91f:	85 c0                	test   %eax,%eax
     921:	75 1f                	jne    942 <test_oob+0x134>
            _pipe_sync_setup_child(&pipes);
     923:	8d 45 d8             	lea    -0x28(%ebp),%eax
     926:	e8 da fd ff ff       	call   705 <_pipe_sync_setup_child>
            _pipe_sync_child(&pipes);
     92b:	8d 45 d8             	lea    -0x28(%ebp),%eax
     92e:	e8 8e f8 ff ff       	call   1c1 <_pipe_sync_child>
     933:	e9 49 ff ff ff       	jmp    881 <test_oob+0x73>
            CRASH("fork() failed");
     938:	b8 01 33 00 00       	mov    $0x3301,%eax
     93d:	e8 72 f7 ff ff       	call   b4 <CRASH>
            _pipe_sync_setup_parent(&pipes);
     942:	8d 45 d8             	lea    -0x28(%ebp),%eax
     945:	e8 94 fe ff ff       	call   7de <_pipe_sync_setup_parent>
            if (!_pipe_sync_parent(&pipes)) {
     94a:	8d 45 d8             	lea    -0x28(%ebp),%eax
     94d:	e8 7a f7 ff ff       	call   cc <_pipe_sync_parent>
            if (!_pipe_assert_broken_parent(&pipes)) {
     952:	8d 45 d8             	lea    -0x28(%ebp),%eax
     955:	e8 ef f6 ff ff       	call   49 <_pipe_assert_broken_parent>
     95a:	85 c0                	test   %eax,%eax
     95c:	75 2d                	jne    98b <test_oob+0x17d>
                result = TR_FAIL_UNKNOWN;
     95e:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
            _pipe_sync_cleanup(&pipes);
     963:	8d 45 d8             	lea    -0x28(%ebp),%eax
     966:	e8 35 fd ff ff       	call   6a0 <_pipe_sync_cleanup>
            wait();
     96b:	e8 8e 26 00 00       	call   2ffe <wait>
            if (result == TR_SUCCESS) {
     970:	85 db                	test   %ebx,%ebx
     972:	75 1e                	jne    992 <test_oob+0x184>
                printf(1, "Test successful.\n");
     974:	83 ec 08             	sub    $0x8,%esp
     977:	68 0f 33 00 00       	push   $0x330f
     97c:	6a 01                	push   $0x1
     97e:	e8 e0 27 00 00       	call   3163 <printf>
     983:	83 c4 10             	add    $0x10,%esp
     986:	e9 31 ff ff ff       	jmp    8bc <test_oob+0xae>
                result = TR_SUCCESS;
     98b:	bb 00 00 00 00       	mov    $0x0,%ebx
     990:	eb d1                	jmp    963 <test_oob+0x155>
                printf(1, "Test failed.\n");
     992:	83 ec 08             	sub    $0x8,%esp
     995:	68 21 33 00 00       	push   $0x3321
     99a:	6a 01                	push   $0x1
     99c:	e8 c2 27 00 00       	call   3163 <printf>
     9a1:	83 c4 10             	add    $0x10,%esp
            return result;
     9a4:	e9 13 ff ff ff       	jmp    8bc <test_oob+0xae>
      p = sbrk(0) + heap_offset;
     9a9:	83 ec 0c             	sub    $0xc,%esp
     9ac:	6a 00                	push   $0x0
     9ae:	e8 cb 26 00 00       	call   307e <sbrk>
     9b3:	01 c3                	add    %eax,%ebx
     9b5:	83 c4 10             	add    $0x10,%esp
     9b8:	e9 d5 fe ff ff       	jmp    892 <test_oob+0x84>
        __asm__ volatile(
     9bd:	8a 03                	mov    (%ebx),%al
     9bf:	e9 d9 fe ff ff       	jmp    89d <test_oob+0x8f>
        _pipe_sync_child(&pipes);
     9c4:	8d 45 d8             	lea    -0x28(%ebp),%eax
     9c7:	e8 f5 f7 ff ff       	call   1c1 <_pipe_sync_child>
        _pipe_sync_cleanup(&pipes);
     9cc:	8d 45 d8             	lea    -0x28(%ebp),%eax
     9cf:	e8 cc fc ff ff       	call   6a0 <_pipe_sync_cleanup>
        exit();
     9d4:	e8 1d 26 00 00       	call   2ff6 <exit>

000009d9 <_test_exec_parent>:
MAYBE_UNUSED static TestResult _test_exec_parent(struct test_pipes *pipes, int child_pid) {
     9d9:	55                   	push   %ebp
     9da:	89 e5                	mov    %esp,%ebp
     9dc:	57                   	push   %edi
     9dd:	56                   	push   %esi
     9de:	53                   	push   %ebx
     9df:	83 ec 6c             	sub    $0x6c,%esp
     9e2:	89 c7                	mov    %eax,%edi
     9e4:	89 45 90             	mov    %eax,-0x70(%ebp)
     9e7:	89 d3                	mov    %edx,%ebx
     9e9:	89 55 94             	mov    %edx,-0x6c(%ebp)
    _pipe_sync_setup_parent(pipes);
     9ec:	e8 ed fd ff ff       	call   7de <_pipe_sync_setup_parent>
    _pipe_sync_parent(pipes);
     9f1:	89 f8                	mov    %edi,%eax
     9f3:	e8 d4 f6 ff ff       	call   cc <_pipe_sync_parent>
    clear_saved_ppns();
     9f8:	e8 12 f6 ff ff       	call   f <clear_saved_ppns>
    if (!save_ppns(child_pid, 0, 16 * PGSIZE, 1))
     9fd:	83 ec 0c             	sub    $0xc,%esp
     a00:	6a 01                	push   $0x1
     a02:	b9 00 00 01 00       	mov    $0x10000,%ecx
     a07:	ba 00 00 00 00       	mov    $0x0,%edx
     a0c:	89 d8                	mov    %ebx,%eax
     a0e:	e8 fb f7 ff ff       	call   20e <save_ppns>
     a13:	89 c3                	mov    %eax,%ebx
     a15:	83 c4 10             	add    $0x10,%esp
     a18:	85 c0                	test   %eax,%eax
     a1a:	75 25                	jne    a41 <_test_exec_parent+0x68>
    _pipe_sync_cleanup(pipes);
     a1c:	8b 45 90             	mov    -0x70(%ebp),%eax
     a1f:	e8 7c fc ff ff       	call   6a0 <_pipe_sync_cleanup>
    kill(child_pid);
     a24:	83 ec 0c             	sub    $0xc,%esp
     a27:	ff 75 94             	push   -0x6c(%ebp)
     a2a:	e8 f7 25 00 00       	call   3026 <kill>
    wait();
     a2f:	e8 ca 25 00 00       	call   2ffe <wait>
    return result;
     a34:	83 c4 10             	add    $0x10,%esp
}
     a37:	89 d8                	mov    %ebx,%eax
     a39:	8d 65 f4             	lea    -0xc(%ebp),%esp
     a3c:	5b                   	pop    %ebx
     a3d:	5e                   	pop    %esi
     a3e:	5f                   	pop    %edi
     a3f:	5d                   	pop    %ebp
     a40:	c3                   	ret    
    _pipe_sync_parent(pipes);
     a41:	89 f8                	mov    %edi,%eax
     a43:	e8 84 f6 ff ff       	call   cc <_pipe_sync_parent>
    int num_pte_values = EXEC_TEST_PTE_VALUES;
     a48:	c7 45 a4 10 00 00 00 	movl   $0x10,-0x5c(%ebp)
    _pipe_recv_parent(pipes, pte_values_from_child, &num_pte_values);
     a4f:	8d 4d a4             	lea    -0x5c(%ebp),%ecx
     a52:	8d 55 a8             	lea    -0x58(%ebp),%edx
     a55:	89 f8                	mov    %edi,%eax
     a57:	e8 c8 f6 ff ff       	call   124 <_pipe_recv_parent>
    for (int i = 0; i < num_pte_values; i += 1) {
     a5c:	bb 00 00 00 00       	mov    $0x0,%ebx
     a61:	39 5d a4             	cmp    %ebx,-0x5c(%ebp)
     a64:	7e 49                	jle    aaf <_test_exec_parent+0xd6>
        if (pte_values_from_child[i] != getpagetableentry(child_pid, i << PTXSHIFT)) {
     a66:	8b 7c 9d a8          	mov    -0x58(%ebp,%ebx,4),%edi
     a6a:	89 de                	mov    %ebx,%esi
     a6c:	c1 e6 0c             	shl    $0xc,%esi
     a6f:	83 ec 08             	sub    $0x8,%esp
     a72:	56                   	push   %esi
     a73:	ff 75 94             	push   -0x6c(%ebp)
     a76:	e8 23 26 00 00       	call   309e <getpagetableentry>
     a7b:	83 c4 10             	add    $0x10,%esp
     a7e:	39 c7                	cmp    %eax,%edi
     a80:	75 05                	jne    a87 <_test_exec_parent+0xae>
    for (int i = 0; i < num_pte_values; i += 1) {
     a82:	83 c3 01             	add    $0x1,%ebx
     a85:	eb da                	jmp    a61 <_test_exec_parent+0x88>
            printf(2, "ERROR: result of getpagetableentry(%d, 0x%x) in pid %d disagreed with pid %d\n",
     a87:	e8 ea 25 00 00       	call   3076 <getpid>
     a8c:	83 ec 08             	sub    $0x8,%esp
     a8f:	8b 4d 94             	mov    -0x6c(%ebp),%ecx
     a92:	51                   	push   %ecx
     a93:	50                   	push   %eax
     a94:	56                   	push   %esi
     a95:	51                   	push   %ecx
     a96:	68 78 40 00 00       	push   $0x4078
     a9b:	6a 02                	push   $0x2
     a9d:	e8 c1 26 00 00       	call   3163 <printf>
            goto early_exit_child;
     aa2:	83 c4 20             	add    $0x20,%esp
            result = TR_FAIL_PTE;
     aa5:	bb 02 00 00 00       	mov    $0x2,%ebx
            goto early_exit_child;
     aaa:	e9 6d ff ff ff       	jmp    a1c <_test_exec_parent+0x43>
    _pipe_sync_parent(pipes);
     aaf:	8b 7d 90             	mov    -0x70(%ebp),%edi
     ab2:	89 f8                	mov    %edi,%eax
     ab4:	e8 13 f6 ff ff       	call   cc <_pipe_sync_parent>
    wait();
     ab9:	e8 40 25 00 00       	call   2ffe <wait>
    _pipe_sync_cleanup(pipes);
     abe:	89 f8                	mov    %edi,%eax
     ac0:	e8 db fb ff ff       	call   6a0 <_pipe_sync_cleanup>
    if (!verify_ppns_freed("allocated to now-exited exec()'d process")) {
     ac5:	b8 c8 40 00 00       	mov    $0x40c8,%eax
     aca:	e8 c2 f8 ff ff       	call   391 <verify_ppns_freed>
     acf:	85 c0                	test   %eax,%eax
     ad1:	74 0a                	je     add <_test_exec_parent+0x104>
    return result;
     ad3:	bb 00 00 00 00       	mov    $0x0,%ebx
     ad8:	e9 5a ff ff ff       	jmp    a37 <_test_exec_parent+0x5e>
        return TR_FAIL_NO_FREE;
     add:	bb 08 00 00 00       	mov    $0x8,%ebx
     ae2:	e9 50 ff ff ff       	jmp    a37 <_test_exec_parent+0x5e>

00000ae7 <_cow_test_child>:
static TestResult _cow_test_child(struct cow_test_info *info, char *heap_base, int child_index) {
     ae7:	55                   	push   %ebp
     ae8:	89 e5                	mov    %esp,%ebp
     aea:	57                   	push   %edi
     aeb:	56                   	push   %esi
     aec:	53                   	push   %ebx
     aed:	83 ec 3c             	sub    $0x3c,%esp
     af0:	89 c6                	mov    %eax,%esi
     af2:	89 55 cc             	mov    %edx,-0x34(%ebp)
     af5:	89 c8                	mov    %ecx,%eax
     af7:	89 4d c8             	mov    %ecx,-0x38(%ebp)
    struct test_pipes *pipes = &info->all_pipes[child_index];
     afa:	c1 e0 04             	shl    $0x4,%eax
     afd:	01 f0                	add    %esi,%eax
     aff:	89 c3                	mov    %eax,%ebx
     b01:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    _pipe_sync_setup_child(pipes);
     b04:	e8 fc fb ff ff       	call   705 <_pipe_sync_setup_child>
    _pipe_sync_child(pipes);
     b09:	89 d8                	mov    %ebx,%eax
     b0b:	e8 b1 f6 ff ff       	call   1c1 <_pipe_sync_child>
    for (int region = 0; region < NUM_COW_REGIONS; region += 1) {
     b10:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
     b17:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
     b1b:	7e 15                	jle    b32 <_cow_test_child+0x4b>
    _pipe_sync_child(pipes);
     b1d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
     b20:	e8 9c f6 ff ff       	call   1c1 <_pipe_sync_child>
    return TR_SUCCESS;
     b25:	b8 00 00 00 00       	mov    $0x0,%eax
}
     b2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
     b2d:	5b                   	pop    %ebx
     b2e:	5e                   	pop    %esi
     b2f:	5f                   	pop    %edi
     b30:	5d                   	pop    %ebp
     b31:	c3                   	ret    
        char do_write = info->child_write[region][child_index];
     b32:	8b 45 d0             	mov    -0x30(%ebp),%eax
     b35:	8d 04 86             	lea    (%esi,%eax,4),%eax
     b38:	8b 55 c8             	mov    -0x38(%ebp),%edx
     b3b:	0f b6 44 02 50       	movzbl 0x50(%edx,%eax,1),%eax
     b40:	89 c3                	mov    %eax,%ebx
     b42:	88 45 d6             	mov    %al,-0x2a(%ebp)
        _pipe_sync_child(pipes);
     b45:	8b 45 c4             	mov    -0x3c(%ebp),%eax
     b48:	e8 74 f6 ff ff       	call   1c1 <_pipe_sync_child>
        if (do_write && info->use_sys_read_child) {
     b4d:	84 db                	test   %bl,%bl
     b4f:	74 06                	je     b57 <_cow_test_child+0x70>
     b51:	83 7e 5c 00          	cmpl   $0x0,0x5c(%esi)
     b55:	75 09                	jne    b60 <_cow_test_child+0x79>
        for (int j = info->starts[region]; j < info->ends[region]; j += 1) {
     b57:	8b 45 d0             	mov    -0x30(%ebp),%eax
     b5a:	8b 7c 86 54          	mov    0x54(%esi,%eax,4),%edi
     b5e:	eb 50                	jmp    bb0 <_cow_test_child+0xc9>
            if (pipe(dummy_pipe_fds) < 0)
     b60:	83 ec 0c             	sub    $0xc,%esp
     b63:	8d 45 e0             	lea    -0x20(%ebp),%eax
     b66:	50                   	push   %eax
     b67:	e8 9a 24 00 00       	call   3006 <pipe>
     b6c:	83 c4 10             	add    $0x10,%esp
     b6f:	85 c0                	test   %eax,%eax
     b71:	79 e4                	jns    b57 <_cow_test_child+0x70>
                CRASH("error creating pipes");
     b73:	b8 dc 32 00 00       	mov    $0x32dc,%eax
     b78:	e8 37 f5 ff ff       	call   b4 <CRASH>
                printf(2, "ERROR: wrong value read from child %d at offset 0x%x\n",
     b7d:	57                   	push   %edi
     b7e:	ff 75 c8             	push   -0x38(%ebp)
     b81:	68 f4 40 00 00       	push   $0x40f4
     b86:	6a 02                	push   $0x2
     b88:	e8 d6 25 00 00       	call   3163 <printf>
                return TR_FAIL_READBACK;
     b8d:	83 c4 10             	add    $0x10,%esp
     b90:	b8 06 00 00 00       	mov    $0x6,%eax
     b95:	eb 93                	jmp    b2a <_cow_test_child+0x43>
                        CRASH("error writing to temporary pipe");
     b97:	b8 2c 41 00 00       	mov    $0x412c,%eax
     b9c:	e8 13 f5 ff ff       	call   b4 <CRASH>
                    heap_base[j] = _heap_test_value(j, child_index);
     ba1:	8b 55 c8             	mov    -0x38(%ebp),%edx
     ba4:	89 f8                	mov    %edi,%eax
     ba6:	e8 8b f4 ff ff       	call   36 <_heap_test_value>
     bab:	88 03                	mov    %al,(%ebx)
        for (int j = info->starts[region]; j < info->ends[region]; j += 1) {
     bad:	83 c7 01             	add    $0x1,%edi
     bb0:	8b 45 d0             	mov    -0x30(%ebp),%eax
     bb3:	39 7c 86 58          	cmp    %edi,0x58(%esi,%eax,4)
     bb7:	7e 6f                	jle    c28 <_cow_test_child+0x141>
            if (heap_base[j] != _heap_test_value(j, -1)) {
     bb9:	8b 45 cc             	mov    -0x34(%ebp),%eax
     bbc:	8d 1c 38             	lea    (%eax,%edi,1),%ebx
     bbf:	0f b6 03             	movzbl (%ebx),%eax
     bc2:	88 45 d7             	mov    %al,-0x29(%ebp)
     bc5:	ba ff ff ff ff       	mov    $0xffffffff,%edx
     bca:	89 f8                	mov    %edi,%eax
     bcc:	e8 65 f4 ff ff       	call   36 <_heap_test_value>
     bd1:	38 45 d7             	cmp    %al,-0x29(%ebp)
     bd4:	75 a7                	jne    b7d <_cow_test_child+0x96>
            if (do_write) {
     bd6:	80 7d d6 00          	cmpb   $0x0,-0x2a(%ebp)
     bda:	74 d1                	je     bad <_cow_test_child+0xc6>
                if (info->use_sys_read_child) {
     bdc:	83 7e 5c 00          	cmpl   $0x0,0x5c(%esi)
     be0:	74 bf                	je     ba1 <_cow_test_child+0xba>
                    char tmp = _heap_test_value(j, child_index);
     be2:	8b 55 c8             	mov    -0x38(%ebp),%edx
     be5:	89 f8                	mov    %edi,%eax
     be7:	e8 4a f4 ff ff       	call   36 <_heap_test_value>
     bec:	88 45 df             	mov    %al,-0x21(%ebp)
                    if (write(dummy_pipe_fds[1], &tmp, 1) != 1)
     bef:	83 ec 04             	sub    $0x4,%esp
     bf2:	6a 01                	push   $0x1
     bf4:	8d 45 df             	lea    -0x21(%ebp),%eax
     bf7:	50                   	push   %eax
     bf8:	ff 75 e4             	push   -0x1c(%ebp)
     bfb:	e8 16 24 00 00       	call   3016 <write>
     c00:	83 c4 10             	add    $0x10,%esp
     c03:	83 f8 01             	cmp    $0x1,%eax
     c06:	75 8f                	jne    b97 <_cow_test_child+0xb0>
                    if (read(dummy_pipe_fds[0], &heap_base[j], 1) != 1)
     c08:	83 ec 04             	sub    $0x4,%esp
     c0b:	6a 01                	push   $0x1
     c0d:	53                   	push   %ebx
     c0e:	ff 75 e0             	push   -0x20(%ebp)
     c11:	e8 f8 23 00 00       	call   300e <read>
     c16:	83 c4 10             	add    $0x10,%esp
     c19:	83 f8 01             	cmp    $0x1,%eax
     c1c:	74 8f                	je     bad <_cow_test_child+0xc6>
                        CRASH("error reading from pipe onto COW region");
     c1e:	b8 4c 41 00 00       	mov    $0x414c,%eax
     c23:	e8 8c f4 ff ff       	call   b4 <CRASH>
        if (do_write && info->use_sys_read_child) {
     c28:	80 7d d6 00          	cmpb   $0x0,-0x2a(%ebp)
     c2c:	74 06                	je     c34 <_cow_test_child+0x14d>
     c2e:	83 7e 5c 00          	cmpl   $0x0,0x5c(%esi)
     c32:	75 11                	jne    c45 <_cow_test_child+0x15e>
        _pipe_sync_child(pipes);
     c34:	8b 45 c4             	mov    -0x3c(%ebp),%eax
     c37:	e8 85 f5 ff ff       	call   1c1 <_pipe_sync_child>
        for (int j = info->starts[region]; j < info->ends[region]; j += 1) {
     c3c:	8b 7d d0             	mov    -0x30(%ebp),%edi
     c3f:	8b 5c be 54          	mov    0x54(%esi,%edi,4),%ebx
     c43:	eb 32                	jmp    c77 <_cow_test_child+0x190>
            close(dummy_pipe_fds[0]);
     c45:	83 ec 0c             	sub    $0xc,%esp
     c48:	ff 75 e0             	push   -0x20(%ebp)
     c4b:	e8 ce 23 00 00       	call   301e <close>
            close(dummy_pipe_fds[1]);
     c50:	83 c4 04             	add    $0x4,%esp
     c53:	ff 75 e4             	push   -0x1c(%ebp)
     c56:	e8 c3 23 00 00       	call   301e <close>
     c5b:	83 c4 10             	add    $0x10,%esp
     c5e:	eb d4                	jmp    c34 <_cow_test_child+0x14d>
            char expect = _heap_test_value(j, do_write ? child_index : -1);
     c60:	ba ff ff ff ff       	mov    $0xffffffff,%edx
     c65:	89 d8                	mov    %ebx,%eax
     c67:	e8 ca f3 ff ff       	call   36 <_heap_test_value>
            if (heap_base[j] != expect) {
     c6c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
     c6f:	38 04 19             	cmp    %al,(%ecx,%ebx,1)
     c72:	75 14                	jne    c88 <_cow_test_child+0x1a1>
        for (int j = info->starts[region]; j < info->ends[region]; j += 1) {
     c74:	83 c3 01             	add    $0x1,%ebx
     c77:	39 5c be 58          	cmp    %ebx,0x58(%esi,%edi,4)
     c7b:	7e 23                	jle    ca0 <_cow_test_child+0x1b9>
            char expect = _heap_test_value(j, do_write ? child_index : -1);
     c7d:	80 7d d6 00          	cmpb   $0x0,-0x2a(%ebp)
     c81:	74 dd                	je     c60 <_cow_test_child+0x179>
     c83:	8b 55 c8             	mov    -0x38(%ebp),%edx
     c86:	eb dd                	jmp    c65 <_cow_test_child+0x17e>
                printf(2, "ERROR: wrong value read from child %d at offset 0x%x\n",
     c88:	53                   	push   %ebx
     c89:	ff 75 c8             	push   -0x38(%ebp)
     c8c:	68 f4 40 00 00       	push   $0x40f4
     c91:	6a 02                	push   $0x2
     c93:	e8 cb 24 00 00       	call   3163 <printf>
                return TR_FAIL_READBACK;
     c98:	83 c4 10             	add    $0x10,%esp
     c9b:	e9 f0 fe ff ff       	jmp    b90 <_cow_test_child+0xa9>
    for (int region = 0; region < NUM_COW_REGIONS; region += 1) {
     ca0:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
     ca4:	e9 6e fe ff ff       	jmp    b17 <_cow_test_child+0x30>

00000ca9 <getopt_usage>:
void getopt_usage(char *argv0, struct option *options) {
     ca9:	55                   	push   %ebp
     caa:	89 e5                	mov    %esp,%ebp
     cac:	56                   	push   %esi
     cad:	53                   	push   %ebx
     cae:	89 c6                	mov    %eax,%esi
     cb0:	89 d3                	mov    %edx,%ebx
   if (0 == strcmp(argv0, "AS-INIT")) {
     cb2:	83 ec 08             	sub    $0x8,%esp
     cb5:	68 2f 33 00 00       	push   $0x332f
     cba:	50                   	push   %eax
     cbb:	e8 bd 21 00 00       	call   2e7d <strcmp>
     cc0:	83 c4 10             	add    $0x10,%esp
     cc3:	85 c0                	test   %eax,%eax
     cc5:	75 14                	jne    cdb <getopt_usage+0x32>
       printf(2, "Options:\n");
     cc7:	83 ec 08             	sub    $0x8,%esp
     cca:	68 37 33 00 00       	push   $0x3337
     ccf:	6a 02                	push   $0x2
     cd1:	e8 8d 24 00 00       	call   3163 <printf>
     cd6:	83 c4 10             	add    $0x10,%esp
     cd9:	eb 44                	jmp    d1f <getopt_usage+0x76>
       printf(2, "Usage: %s ... \n", argv0);
     cdb:	83 ec 04             	sub    $0x4,%esp
     cde:	56                   	push   %esi
     cdf:	68 41 33 00 00       	push   $0x3341
     ce4:	6a 02                	push   $0x2
     ce6:	e8 78 24 00 00       	call   3163 <printf>
     ceb:	83 c4 10             	add    $0x10,%esp
     cee:	eb 2f                	jmp    d1f <getopt_usage+0x76>
           printf(2, "=NUMBER (default: 0x%x)\n", *option->value);
     cf0:	8b 43 08             	mov    0x8(%ebx),%eax
     cf3:	83 ec 04             	sub    $0x4,%esp
     cf6:	ff 30                	push   (%eax)
     cf8:	68 57 33 00 00       	push   $0x3357
     cfd:	6a 02                	push   $0x2
     cff:	e8 5f 24 00 00       	call   3163 <printf>
     d04:	83 c4 10             	add    $0x10,%esp
       printf(2, "    %s\n", option->description);
     d07:	83 ec 04             	sub    $0x4,%esp
     d0a:	ff 73 04             	push   0x4(%ebx)
     d0d:	68 70 33 00 00       	push   $0x3370
     d12:	6a 02                	push   $0x2
     d14:	e8 4a 24 00 00       	call   3163 <printf>
   for (struct option *option = options; option->name; option += 1) {
     d19:	83 c3 10             	add    $0x10,%ebx
     d1c:	83 c4 10             	add    $0x10,%esp
     d1f:	8b 03                	mov    (%ebx),%eax
     d21:	85 c0                	test   %eax,%eax
     d23:	74 2d                	je     d52 <getopt_usage+0xa9>
       printf(2, "  -%s", option->name);
     d25:	83 ec 04             	sub    $0x4,%esp
     d28:	50                   	push   %eax
     d29:	68 51 33 00 00       	push   $0x3351
     d2e:	6a 02                	push   $0x2
     d30:	e8 2e 24 00 00       	call   3163 <printf>
       if (option->boolean) {
     d35:	83 c4 10             	add    $0x10,%esp
     d38:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
     d3c:	74 b2                	je     cf0 <getopt_usage+0x47>
           printf(2, "\n");
     d3e:	83 ec 08             	sub    $0x8,%esp
     d41:	68 4f 33 00 00       	push   $0x334f
     d46:	6a 02                	push   $0x2
     d48:	e8 16 24 00 00       	call   3163 <printf>
     d4d:	83 c4 10             	add    $0x10,%esp
     d50:	eb b5                	jmp    d07 <getopt_usage+0x5e>
   printf(2, "NUMBER can be a base-10 number or a base-16 number prefixed with '0x'\n");
     d52:	83 ec 08             	sub    $0x8,%esp
     d55:	68 74 41 00 00       	push   $0x4174
     d5a:	6a 02                	push   $0x2
     d5c:	e8 02 24 00 00       	call   3163 <printf>
}
     d61:	83 c4 10             	add    $0x10,%esp
     d64:	8d 65 f8             	lea    -0x8(%ebp),%esp
     d67:	5b                   	pop    %ebx
     d68:	5e                   	pop    %esi
     d69:	5d                   	pop    %ebp
     d6a:	c3                   	ret    

00000d6b <_test_exec>:
MAYBE_UNUSED static TestResult _test_exec() {
     d6b:	55                   	push   %ebp
     d6c:	89 e5                	mov    %esp,%ebp
     d6e:	57                   	push   %edi
     d6f:	56                   	push   %esi
     d70:	53                   	push   %ebx
     d71:	83 ec 44             	sub    $0x44,%esp
    printf(1, 
     d74:	68 bc 41 00 00       	push   $0x41bc
     d79:	6a 01                	push   $0x1
     d7b:	e8 e3 23 00 00       	call   3163 <printf>
    _init_pipes(&pipes);
     d80:	8d 45 d8             	lea    -0x28(%ebp),%eax
     d83:	e8 b6 f8 ff ff       	call   63e <_init_pipes>
    int pid = fork();
     d88:	e8 61 22 00 00       	call   2fee <fork>
    if (pid == -1) return TR_FAIL_FORK;
     d8d:	83 c4 10             	add    $0x10,%esp
     d90:	83 f8 ff             	cmp    $0xffffffff,%eax
     d93:	0f 84 66 01 00 00    	je     eff <_test_exec+0x194>
    if (pid == 0) {
     d99:	85 c0                	test   %eax,%eax
     d9b:	0f 85 16 01 00 00    	jne    eb7 <_test_exec+0x14c>
        int to_child0 = dup(pipes.to_child[0]);
     da1:	83 ec 0c             	sub    $0xc,%esp
     da4:	ff 75 d8             	push   -0x28(%ebp)
     da7:	e8 c2 22 00 00       	call   306e <dup>
     dac:	89 c7                	mov    %eax,%edi
        int to_child1 = dup(pipes.to_child[1]);
     dae:	83 c4 04             	add    $0x4,%esp
     db1:	ff 75 dc             	push   -0x24(%ebp)
     db4:	e8 b5 22 00 00       	call   306e <dup>
     db9:	89 c6                	mov    %eax,%esi
        int from_child0 = dup(pipes.from_child[0]);
     dbb:	83 c4 04             	add    $0x4,%esp
     dbe:	ff 75 e0             	push   -0x20(%ebp)
     dc1:	e8 a8 22 00 00       	call   306e <dup>
     dc6:	89 c3                	mov    %eax,%ebx
        int from_child1 = dup(pipes.from_child[1]);
     dc8:	83 c4 04             	add    $0x4,%esp
     dcb:	ff 75 e4             	push   -0x1c(%ebp)
     dce:	e8 9b 22 00 00       	call   306e <dup>
     dd3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        close(3);
     dd6:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
     ddd:	e8 3c 22 00 00       	call   301e <close>
        if (3 != dup(to_child0)) CRASH("could not assign fd 3");
     de2:	89 3c 24             	mov    %edi,(%esp)
     de5:	e8 84 22 00 00       	call   306e <dup>
     dea:	83 c4 10             	add    $0x10,%esp
     ded:	83 f8 03             	cmp    $0x3,%eax
     df0:	75 5b                	jne    e4d <_test_exec+0xe2>
        close(4);
     df2:	83 ec 0c             	sub    $0xc,%esp
     df5:	6a 04                	push   $0x4
     df7:	e8 22 22 00 00       	call   301e <close>
        if (4 != dup(to_child1)) CRASH("could not assign fd 4");
     dfc:	89 34 24             	mov    %esi,(%esp)
     dff:	e8 6a 22 00 00       	call   306e <dup>
     e04:	83 c4 10             	add    $0x10,%esp
     e07:	83 f8 04             	cmp    $0x4,%eax
     e0a:	75 4b                	jne    e57 <_test_exec+0xec>
        close(5);
     e0c:	83 ec 0c             	sub    $0xc,%esp
     e0f:	6a 05                	push   $0x5
     e11:	e8 08 22 00 00       	call   301e <close>
        if (5 != dup(from_child0)) CRASH("could not assign fd 5");
     e16:	89 1c 24             	mov    %ebx,(%esp)
     e19:	e8 50 22 00 00       	call   306e <dup>
     e1e:	83 c4 10             	add    $0x10,%esp
     e21:	83 f8 05             	cmp    $0x5,%eax
     e24:	75 3b                	jne    e61 <_test_exec+0xf6>
        close(6);
     e26:	83 ec 0c             	sub    $0xc,%esp
     e29:	6a 06                	push   $0x6
     e2b:	e8 ee 21 00 00       	call   301e <close>
        if (6 != dup(from_child1)) CRASH("could not assign fd 6");
     e30:	83 c4 04             	add    $0x4,%esp
     e33:	ff 75 c4             	push   -0x3c(%ebp)
     e36:	e8 33 22 00 00       	call   306e <dup>
     e3b:	83 c4 10             	add    $0x10,%esp
     e3e:	83 f8 06             	cmp    $0x6,%eax
     e41:	74 28                	je     e6b <_test_exec+0x100>
     e43:	b8 ba 33 00 00       	mov    $0x33ba,%eax
     e48:	e8 67 f2 ff ff       	call   b4 <CRASH>
        if (3 != dup(to_child0)) CRASH("could not assign fd 3");
     e4d:	b8 78 33 00 00       	mov    $0x3378,%eax
     e52:	e8 5d f2 ff ff       	call   b4 <CRASH>
        if (4 != dup(to_child1)) CRASH("could not assign fd 4");
     e57:	b8 8e 33 00 00       	mov    $0x338e,%eax
     e5c:	e8 53 f2 ff ff       	call   b4 <CRASH>
        if (5 != dup(from_child0)) CRASH("could not assign fd 5");
     e61:	b8 a4 33 00 00       	mov    $0x33a4,%eax
     e66:	e8 49 f2 ff ff       	call   b4 <CRASH>
        close(to_child0);
     e6b:	83 ec 0c             	sub    $0xc,%esp
     e6e:	57                   	push   %edi
     e6f:	e8 aa 21 00 00       	call   301e <close>
        close(to_child1);
     e74:	89 34 24             	mov    %esi,(%esp)
     e77:	e8 a2 21 00 00       	call   301e <close>
        close(from_child0);
     e7c:	89 1c 24             	mov    %ebx,(%esp)
     e7f:	e8 9a 21 00 00       	call   301e <close>
        close(from_child1);
     e84:	83 c4 04             	add    $0x4,%esp
     e87:	ff 75 c4             	push   -0x3c(%ebp)
     e8a:	e8 8f 21 00 00       	call   301e <close>
        const char *args[] = {
     e8f:	a1 80 79 00 00       	mov    0x7980,%eax
     e94:	89 45 cc             	mov    %eax,-0x34(%ebp)
     e97:	c7 45 d0 d0 33 00 00 	movl   $0x33d0,-0x30(%ebp)
     e9e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
        exec((char*) real_argv0, (char**) args);
     ea5:	83 c4 08             	add    $0x8,%esp
     ea8:	8d 55 cc             	lea    -0x34(%ebp),%edx
     eab:	52                   	push   %edx
     eac:	50                   	push   %eax
     ead:	e8 7c 21 00 00       	call   302e <exec>
        exit();
     eb2:	e8 3f 21 00 00       	call   2ff6 <exit>
        int result = _test_exec_parent(&pipes, pid);
     eb7:	89 c2                	mov    %eax,%edx
     eb9:	8d 45 d8             	lea    -0x28(%ebp),%eax
     ebc:	e8 18 fb ff ff       	call   9d9 <_test_exec_parent>
     ec1:	89 c3                	mov    %eax,%ebx
        _pipe_sync_cleanup(&pipes);
     ec3:	8d 45 d8             	lea    -0x28(%ebp),%eax
     ec6:	e8 d5 f7 ff ff       	call   6a0 <_pipe_sync_cleanup>
        if (result == TR_SUCCESS) {
     ecb:	85 db                	test   %ebx,%ebx
     ecd:	75 1c                	jne    eeb <_test_exec+0x180>
            printf(1, "Test successful.\n");
     ecf:	83 ec 08             	sub    $0x8,%esp
     ed2:	68 0f 33 00 00       	push   $0x330f
     ed7:	6a 01                	push   $0x1
     ed9:	e8 85 22 00 00       	call   3163 <printf>
     ede:	83 c4 10             	add    $0x10,%esp
}
     ee1:	89 d8                	mov    %ebx,%eax
     ee3:	8d 65 f4             	lea    -0xc(%ebp),%esp
     ee6:	5b                   	pop    %ebx
     ee7:	5e                   	pop    %esi
     ee8:	5f                   	pop    %edi
     ee9:	5d                   	pop    %ebp
     eea:	c3                   	ret    
            printf(1, "Test failed.\n");
     eeb:	83 ec 08             	sub    $0x8,%esp
     eee:	68 21 33 00 00       	push   $0x3321
     ef3:	6a 01                	push   $0x1
     ef5:	e8 69 22 00 00       	call   3163 <printf>
     efa:	83 c4 10             	add    $0x10,%esp
        return result;
     efd:	eb e2                	jmp    ee1 <_test_exec+0x176>
    if (pid == -1) return TR_FAIL_FORK;
     eff:	bb 07 00 00 00       	mov    $0x7,%ebx
     f04:	eb db                	jmp    ee1 <_test_exec+0x176>

00000f06 <hextoi>:
uint hextoi(const char *value) {
     f06:	55                   	push   %ebp
     f07:	89 e5                	mov    %esp,%ebp
     f09:	56                   	push   %esi
     f0a:	53                   	push   %ebx
     f0b:	8b 75 08             	mov    0x8(%ebp),%esi
    p = value;
     f0e:	89 f1                	mov    %esi,%ecx
    while (p[0] == ' ') {
     f10:	eb 03                	jmp    f15 <hextoi+0xf>
        p += 1;
     f12:	83 c1 01             	add    $0x1,%ecx
    while (p[0] == ' ') {
     f15:	0f b6 01             	movzbl (%ecx),%eax
     f18:	3c 20                	cmp    $0x20,%al
     f1a:	74 f6                	je     f12 <hextoi+0xc>
    if (p[0] == '0' && (p[1] == 'x' || p[1] == 'X')) {
     f1c:	3c 30                	cmp    $0x30,%al
     f1e:	74 07                	je     f27 <hextoi+0x21>
    p = value;
     f20:	b8 00 00 00 00       	mov    $0x0,%eax
     f25:	eb 2b                	jmp    f52 <hextoi+0x4c>
    if (p[0] == '0' && (p[1] == 'x' || p[1] == 'X')) {
     f27:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
     f2b:	80 fa 78             	cmp    $0x78,%dl
     f2e:	0f 94 c0             	sete   %al
     f31:	80 fa 58             	cmp    $0x58,%dl
     f34:	0f 94 c2             	sete   %dl
     f37:	08 d0                	or     %dl,%al
     f39:	74 e5                	je     f20 <hextoi+0x1a>
        p += 2;
     f3b:	83 c1 02             	add    $0x2,%ecx
     f3e:	eb e0                	jmp    f20 <hextoi+0x1a>
        } else if (*p >= 'a' && *p <= 'f') {
     f40:	8d 5a 9f             	lea    -0x61(%edx),%ebx
     f43:	80 fb 05             	cmp    $0x5,%bl
     f46:	77 25                	ja     f6d <hextoi+0x67>
            result += 10 + *p - 'a';
     f48:	0f be d2             	movsbl %dl,%edx
     f4b:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
        p += 1;
     f4f:	83 c1 01             	add    $0x1,%ecx
    while (*p) {
     f52:	0f b6 11             	movzbl (%ecx),%edx
     f55:	84 d2                	test   %dl,%dl
     f57:	74 3d                	je     f96 <hextoi+0x90>
        result = result << 4;
     f59:	c1 e0 04             	shl    $0x4,%eax
        if (*p >= '0' && *p <= '9') {
     f5c:	8d 5a d0             	lea    -0x30(%edx),%ebx
     f5f:	80 fb 09             	cmp    $0x9,%bl
     f62:	77 dc                	ja     f40 <hextoi+0x3a>
            result += *p - '0';
     f64:	0f be d2             	movsbl %dl,%edx
     f67:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
     f6b:	eb e2                	jmp    f4f <hextoi+0x49>
        } else if (*p >= 'A' && *p <= 'F') {
     f6d:	8d 5a bf             	lea    -0x41(%edx),%ebx
     f70:	80 fb 05             	cmp    $0x5,%bl
     f73:	77 09                	ja     f7e <hextoi+0x78>
            result += 10 + *p - 'A';
     f75:	0f be d2             	movsbl %dl,%edx
     f78:	8d 44 10 c9          	lea    -0x37(%eax,%edx,1),%eax
     f7c:	eb d1                	jmp    f4f <hextoi+0x49>
            printf(2, "malformed hexadecimal number '%s'\n", value);
     f7e:	83 ec 04             	sub    $0x4,%esp
     f81:	56                   	push   %esi
     f82:	68 9c 42 00 00       	push   $0x429c
     f87:	6a 02                	push   $0x2
     f89:	e8 d5 21 00 00       	call   3163 <printf>
            return 0;
     f8e:	83 c4 10             	add    $0x10,%esp
     f91:	b8 00 00 00 00       	mov    $0x0,%eax
}
     f96:	8d 65 f8             	lea    -0x8(%ebp),%esp
     f99:	5b                   	pop    %ebx
     f9a:	5e                   	pop    %esi
     f9b:	5d                   	pop    %ebp
     f9c:	c3                   	ret    

00000f9d <decorhextoi>:
uint decorhextoi(const char *value) {
     f9d:	55                   	push   %ebp
     f9e:	89 e5                	mov    %esp,%ebp
     fa0:	83 ec 08             	sub    $0x8,%esp
     fa3:	8b 45 08             	mov    0x8(%ebp),%eax
    if (value[0] == '0' && (value[1] == 'x' || value[1] == 'X')) {
     fa6:	80 38 30             	cmpb   $0x30,(%eax)
     fa9:	75 14                	jne    fbf <decorhextoi+0x22>
     fab:	0f b6 48 01          	movzbl 0x1(%eax),%ecx
     faf:	80 f9 78             	cmp    $0x78,%cl
     fb2:	0f 94 c2             	sete   %dl
     fb5:	80 f9 58             	cmp    $0x58,%cl
     fb8:	0f 94 c1             	sete   %cl
     fbb:	08 ca                	or     %cl,%dl
     fbd:	75 0e                	jne    fcd <decorhextoi+0x30>
        return atoi(value);
     fbf:	83 ec 0c             	sub    $0xc,%esp
     fc2:	50                   	push   %eax
     fc3:	e8 ca 1f 00 00       	call   2f92 <atoi>
     fc8:	83 c4 10             	add    $0x10,%esp
}
     fcb:	c9                   	leave  
     fcc:	c3                   	ret    
        return hextoi(value);
     fcd:	83 ec 0c             	sub    $0xc,%esp
     fd0:	50                   	push   %eax
     fd1:	e8 30 ff ff ff       	call   f06 <hextoi>
     fd6:	83 c4 10             	add    $0x10,%esp
     fd9:	eb f0                	jmp    fcb <decorhextoi+0x2e>

00000fdb <dump_for>:
void dump_for(const char *reason, int pid) {
     fdb:	55                   	push   %ebp
     fdc:	89 e5                	mov    %esp,%ebp
     fde:	53                   	push   %ebx
     fdf:	83 ec 08             	sub    $0x8,%esp
     fe2:	8b 5d 08             	mov    0x8(%ebp),%ebx
    printf(1, STARTDUMP "%s\n", reason);
     fe5:	53                   	push   %ebx
     fe6:	68 c0 42 00 00       	push   $0x42c0
     feb:	6a 01                	push   $0x1
     fed:	e8 71 21 00 00       	call   3163 <printf>
    dumppagetable(pid);
     ff2:	83 c4 04             	add    $0x4,%esp
     ff5:	ff 75 0c             	push   0xc(%ebp)
     ff8:	e8 b1 20 00 00       	call   30ae <dumppagetable>
    printf(1, ENDDUMP "%s\n", reason);
     ffd:	83 c4 0c             	add    $0xc,%esp
    1000:	53                   	push   %ebx
    1001:	68 ec 42 00 00       	push   $0x42ec
    1006:	6a 01                	push   $0x1
    1008:	e8 56 21 00 00       	call   3163 <printf>
}
    100d:	83 c4 10             	add    $0x10,%esp
    1010:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1013:	c9                   	leave  
    1014:	c3                   	ret    

00001015 <strprefix>:
int strprefix(const char *prefix, const char *target) {
    1015:	55                   	push   %ebp
    1016:	89 e5                	mov    %esp,%ebp
    1018:	53                   	push   %ebx
    1019:	8b 5d 08             	mov    0x8(%ebp),%ebx
    101c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    while (*prefix == *target && *prefix != '\0' && *target != '\0') {
    101f:	eb 06                	jmp    1027 <strprefix+0x12>
        prefix += 1;
    1021:	83 c3 01             	add    $0x1,%ebx
        target += 1;
    1024:	83 c1 01             	add    $0x1,%ecx
    while (*prefix == *target && *prefix != '\0' && *target != '\0') {
    1027:	0f b6 03             	movzbl (%ebx),%eax
    102a:	0f b6 11             	movzbl (%ecx),%edx
    102d:	38 d0                	cmp    %dl,%al
    102f:	75 08                	jne    1039 <strprefix+0x24>
    1031:	84 c0                	test   %al,%al
    1033:	74 04                	je     1039 <strprefix+0x24>
    1035:	84 d2                	test   %dl,%dl
    1037:	75 e8                	jne    1021 <strprefix+0xc>
    if (*prefix == '\0')
    1039:	84 c0                	test   %al,%al
    103b:	75 0a                	jne    1047 <strprefix+0x32>
        return 1;
    103d:	b8 01 00 00 00       	mov    $0x1,%eax
}
    1042:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1045:	c9                   	leave  
    1046:	c3                   	ret    
        return 0;
    1047:	b8 00 00 00 00       	mov    $0x0,%eax
    104c:	eb f4                	jmp    1042 <strprefix+0x2d>

0000104e <max>:
int max(int a, int b) {
    104e:	55                   	push   %ebp
    104f:	89 e5                	mov    %esp,%ebp
    1051:	8b 55 08             	mov    0x8(%ebp),%edx
    1054:	8b 45 0c             	mov    0xc(%ebp),%eax
    if (a > b) {
    1057:	39 c2                	cmp    %eax,%edx
    1059:	7e 02                	jle    105d <max+0xf>
        return a;
    105b:	89 d0                	mov    %edx,%eax
}
    105d:	5d                   	pop    %ebp
    105e:	c3                   	ret    

0000105f <_test_allocation_child>:
MAYBE_UNUSED static TestResult _test_allocation_child(struct alloc_test_info *info) {
    105f:	55                   	push   %ebp
    1060:	89 e5                	mov    %esp,%ebp
    1062:	57                   	push   %edi
    1063:	56                   	push   %esi
    1064:	53                   	push   %ebx
    1065:	83 ec 3c             	sub    $0x3c,%esp
    1068:	89 c3                	mov    %eax,%ebx
    int result = TR_SUCCESS;
    106a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    _pipe_sync_child(&info->pipes);
    1071:	e8 4b f1 ff ff       	call   1c1 <_pipe_sync_child>
    int free_check = info->skip_free_check ? NO_FREE_CHECK : WITH_FREE_CHECK;
    1076:	83 7b 30 00          	cmpl   $0x0,0x30(%ebx)
    107a:	0f 95 c0             	setne  %al
    107d:	0f b6 c0             	movzbl %al,%eax
    1080:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    uint guard = _get_guard();
    1083:	e8 78 ef ff ff       	call   0 <_get_guard>
    1088:	89 c6                	mov    %eax,%esi
    if (!_sanity_check_range_self(0, guard, IS_ALLOCATED, NOT_GUARD, free_check, " (memory before guard page, before new allocation)")) {
    108a:	83 ec 04             	sub    $0x4,%esp
    108d:	68 94 3f 00 00       	push   $0x3f94
    1092:	ff 75 d4             	push   -0x2c(%ebp)
    1095:	6a 00                	push   $0x0
    1097:	b9 01 00 00 00       	mov    $0x1,%ecx
    109c:	89 c2                	mov    %eax,%edx
    109e:	b8 00 00 00 00       	mov    $0x0,%eax
    10a3:	e8 f8 f4 ff ff       	call   5a0 <_sanity_check_range_self>
    10a8:	83 c4 10             	add    $0x10,%esp
    10ab:	85 c0                	test   %eax,%eax
    10ad:	75 13                	jne    10c2 <_test_allocation_child+0x63>
        result = max(result, TR_FAIL_PTE);
    10af:	83 ec 08             	sub    $0x8,%esp
    10b2:	6a 02                	push   $0x2
    10b4:	ff 75 e4             	push   -0x1c(%ebp)
    10b7:	e8 92 ff ff ff       	call   104e <max>
    10bc:	83 c4 10             	add    $0x10,%esp
    10bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (!_sanity_check_range_self(guard, guard + PGSIZE, IS_ALLOCATED, IS_GUARD, free_check, " (guard page)")) {
    10c2:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
    10c8:	83 ec 04             	sub    $0x4,%esp
    10cb:	68 ce 32 00 00       	push   $0x32ce
    10d0:	ff 75 d4             	push   -0x2c(%ebp)
    10d3:	6a 01                	push   $0x1
    10d5:	b9 01 00 00 00       	mov    $0x1,%ecx
    10da:	89 fa                	mov    %edi,%edx
    10dc:	89 f0                	mov    %esi,%eax
    10de:	e8 bd f4 ff ff       	call   5a0 <_sanity_check_range_self>
    10e3:	83 c4 10             	add    $0x10,%esp
    10e6:	85 c0                	test   %eax,%eax
    10e8:	75 13                	jne    10fd <_test_allocation_child+0x9e>
        result = max(result, TR_FAIL_PTE);
    10ea:	83 ec 08             	sub    $0x8,%esp
    10ed:	6a 02                	push   $0x2
    10ef:	ff 75 e4             	push   -0x1c(%ebp)
    10f2:	e8 57 ff ff ff       	call   104e <max>
    10f7:	83 c4 10             	add    $0x10,%esp
    10fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (!_sanity_check_range_self(guard + PGSIZE, guard + PGSIZE * 2, IS_ALLOCATED, NOT_GUARD, free_check, " (stack page)")) {
    10fd:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
    1103:	83 ec 04             	sub    $0x4,%esp
    1106:	68 df 33 00 00       	push   $0x33df
    110b:	ff 75 d4             	push   -0x2c(%ebp)
    110e:	6a 00                	push   $0x0
    1110:	b9 01 00 00 00       	mov    $0x1,%ecx
    1115:	89 f8                	mov    %edi,%eax
    1117:	e8 84 f4 ff ff       	call   5a0 <_sanity_check_range_self>
    111c:	83 c4 10             	add    $0x10,%esp
    111f:	85 c0                	test   %eax,%eax
    1121:	75 13                	jne    1136 <_test_allocation_child+0xd7>
        result = max(result, TR_FAIL_PTE);
    1123:	83 ec 08             	sub    $0x8,%esp
    1126:	6a 02                	push   $0x2
    1128:	ff 75 e4             	push   -0x1c(%ebp)
    112b:	e8 1e ff ff ff       	call   104e <max>
    1130:	83 c4 10             	add    $0x10,%esp
    1133:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    char *old_brk = sbrk(0);
    1136:	83 ec 0c             	sub    $0xc,%esp
    1139:	6a 00                	push   $0x0
    113b:	e8 3e 1f 00 00       	call   307e <sbrk>
    1140:	89 c6                	mov    %eax,%esi
    if (!info->skip_pte_check) {
    1142:	83 c4 10             	add    $0x10,%esp
    1145:	83 7b 34 00          	cmpl   $0x0,0x34(%ebx)
    1149:	74 6e                	je     11b9 <_test_allocation_child+0x15a>
    _pipe_sync_child(&info->pipes);
    114b:	89 d8                	mov    %ebx,%eax
    114d:	e8 6f f0 ff ff       	call   1c1 <_pipe_sync_child>
    if (info->dump)
    1152:	83 7b 2c 00          	cmpl   $0x0,0x2c(%ebx)
    1156:	0f 85 9b 00 00 00    	jne    11f7 <_test_allocation_child+0x198>
    sbrk(info->alloc_size);
    115c:	83 ec 0c             	sub    $0xc,%esp
    115f:	ff 73 10             	push   0x10(%ebx)
    1162:	e8 17 1f 00 00       	call   307e <sbrk>
    char *new_brk = sbrk(0);
    1167:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    116e:	e8 0b 1f 00 00       	call   307e <sbrk>
    1173:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    if (new_brk - old_brk < info->alloc_size) {
    1176:	89 c2                	mov    %eax,%edx
    1178:	29 f2                	sub    %esi,%edx
    117a:	8b 43 10             	mov    0x10(%ebx),%eax
    117d:	83 c4 10             	add    $0x10,%esp
    1180:	39 c2                	cmp    %eax,%edx
    1182:	0f 8c 8a 00 00 00    	jl     1212 <_test_allocation_child+0x1b3>
    if (!info->skip_pte_check) {
    1188:	83 7b 34 00          	cmpl   $0x0,0x34(%ebx)
    118c:	0f 84 9b 00 00 00    	je     122d <_test_allocation_child+0x1ce>
    _pipe_sync_child(&info->pipes);
    1192:	89 d8                	mov    %ebx,%eax
    1194:	e8 28 f0 ff ff       	call   1c1 <_pipe_sync_child>
    if (info->dump)
    1199:	83 7b 2c 00          	cmpl   $0x0,0x2c(%ebx)
    119d:	0f 85 d2 00 00 00    	jne    1275 <_test_allocation_child+0x216>
    int read_start = info->read_start; int read_end = info->read_end;
    11a3:	8b 7b 1c             	mov    0x1c(%ebx),%edi
    11a6:	89 7d cc             	mov    %edi,-0x34(%ebp)
    11a9:	8b 43 20             	mov    0x20(%ebx),%eax
    11ac:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (int i = read_start; i < read_end; ++i) {
    11af:	89 5d d0             	mov    %ebx,-0x30(%ebp)
    11b2:	89 c3                	mov    %eax,%ebx
    11b4:	e9 da 00 00 00       	jmp    1293 <_test_allocation_child+0x234>
        if (!_sanity_check_range_self(guard + PGSIZE, (uint) old_brk, MAYBE_ALLOCATED, NOT_GUARD, free_check, " (heap before new allocation)")) {
    11b9:	83 ec 04             	sub    $0x4,%esp
    11bc:	68 ed 33 00 00       	push   $0x33ed
    11c1:	ff 75 d4             	push   -0x2c(%ebp)
    11c4:	6a 00                	push   $0x0
    11c6:	b9 00 00 00 00       	mov    $0x0,%ecx
    11cb:	89 c2                	mov    %eax,%edx
    11cd:	89 f8                	mov    %edi,%eax
    11cf:	e8 cc f3 ff ff       	call   5a0 <_sanity_check_range_self>
    11d4:	83 c4 10             	add    $0x10,%esp
    11d7:	85 c0                	test   %eax,%eax
    11d9:	0f 85 6c ff ff ff    	jne    114b <_test_allocation_child+0xec>
            result = max(result, TR_FAIL_PTE);
    11df:	83 ec 08             	sub    $0x8,%esp
    11e2:	6a 02                	push   $0x2
    11e4:	ff 75 e4             	push   -0x1c(%ebp)
    11e7:	e8 62 fe ff ff       	call   104e <max>
    11ec:	83 c4 10             	add    $0x10,%esp
    11ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    11f2:	e9 54 ff ff ff       	jmp    114b <_test_allocation_child+0xec>
        dump_for("allocation-pre-allocate", getpid());
    11f7:	e8 7a 1e 00 00       	call   3076 <getpid>
    11fc:	83 ec 08             	sub    $0x8,%esp
    11ff:	50                   	push   %eax
    1200:	68 0b 34 00 00       	push   $0x340b
    1205:	e8 d1 fd ff ff       	call   fdb <dump_for>
    120a:	83 c4 10             	add    $0x10,%esp
    120d:	e9 4a ff ff ff       	jmp    115c <_test_allocation_child+0xfd>
        printf(2, "ERROR: sbrk() allocated too little (requested 0x%x bytes; break changed by 0x%x bytes)\n", info->alloc_size, new_brk - old_brk);
    1212:	52                   	push   %edx
    1213:	50                   	push   %eax
    1214:	68 18 43 00 00       	push   $0x4318
    1219:	6a 02                	push   $0x2
    121b:	e8 43 1f 00 00       	call   3163 <printf>
        return TR_FAIL_SBRK; // FIXME: should this not stop test?
    1220:	83 c4 10             	add    $0x10,%esp
    1223:	b8 03 00 00 00       	mov    $0x3,%eax
    1228:	e9 77 03 00 00       	jmp    15a4 <_test_allocation_child+0x545>
        if (! _sanity_check_range_self(PGROUNDUP((uint) old_brk), (uint) new_brk, NOT_ALLOCATED, NOT_GUARD, free_check,
    122d:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
    1233:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    1238:	83 ec 04             	sub    $0x4,%esp
    123b:	68 70 43 00 00       	push   $0x4370
    1240:	ff 75 d4             	push   -0x2c(%ebp)
    1243:	6a 00                	push   $0x0
    1245:	b9 02 00 00 00       	mov    $0x2,%ecx
    124a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
    124d:	e8 4e f3 ff ff       	call   5a0 <_sanity_check_range_self>
    1252:	83 c4 10             	add    $0x10,%esp
    1255:	85 c0                	test   %eax,%eax
    1257:	0f 85 35 ff ff ff    	jne    1192 <_test_allocation_child+0x133>
            result = max(result, TR_FAIL_NONDEMAND);
    125d:	83 ec 08             	sub    $0x8,%esp
    1260:	6a 04                	push   $0x4
    1262:	ff 75 e4             	push   -0x1c(%ebp)
    1265:	e8 e4 fd ff ff       	call   104e <max>
    126a:	83 c4 10             	add    $0x10,%esp
    126d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    1270:	e9 1d ff ff ff       	jmp    1192 <_test_allocation_child+0x133>
        dump_for("allocation-pre-access", getpid());
    1275:	e8 fc 1d 00 00       	call   3076 <getpid>
    127a:	83 ec 08             	sub    $0x8,%esp
    127d:	50                   	push   %eax
    127e:	68 23 34 00 00       	push   $0x3423
    1283:	e8 53 fd ff ff       	call   fdb <dump_for>
    1288:	83 c4 10             	add    $0x10,%esp
    128b:	e9 13 ff ff ff       	jmp    11a3 <_test_allocation_child+0x144>
    for (int i = read_start; i < read_end; ++i) {
    1290:	83 c7 01             	add    $0x1,%edi
    1293:	39 df                	cmp    %ebx,%edi
    1295:	7d 1e                	jge    12b5 <_test_allocation_child+0x256>
       if (old_brk[i] != 0) {
    1297:	80 3c 3e 00          	cmpb   $0x0,(%esi,%edi,1)
    129b:	74 f3                	je     1290 <_test_allocation_child+0x231>
           printf(2, "ERROR: non-zero value read 0x%x bytes into 0x%x byte allocation\n",
    129d:	8b 45 d0             	mov    -0x30(%ebp),%eax
    12a0:	ff 70 10             	push   0x10(%eax)
    12a3:	57                   	push   %edi
    12a4:	68 98 43 00 00       	push   $0x4398
    12a9:	6a 02                	push   $0x2
    12ab:	e8 b3 1e 00 00       	call   3163 <printf>
    12b0:	83 c4 10             	add    $0x10,%esp
    12b3:	eb db                	jmp    1290 <_test_allocation_child+0x231>
    if (!info->skip_pte_check) {
    12b5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
    12b8:	83 7b 34 00          	cmpl   $0x0,0x34(%ebx)
    12bc:	0f 85 a4 00 00 00    	jne    1366 <_test_allocation_child+0x307>
        if (read_end > read_start) {
    12c2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
    12c5:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
    12c8:	0f 8c b4 00 00 00    	jl     1382 <_test_allocation_child+0x323>
            PGROUNDDOWN((uint) old_brk + read_start - 1), 
    12ce:	8b 45 cc             	mov    -0x34(%ebp),%eax
    12d1:	8d 54 06 ff          	lea    -0x1(%esi,%eax,1),%edx
            PGROUNDUP((uint) old_brk), 
    12d5:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
        if (! _sanity_check_range_self(
    12db:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
    12e1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    12e6:	83 ec 04             	sub    $0x4,%esp
    12e9:	68 08 44 00 00       	push   $0x4408
    12ee:	ff 75 d4             	push   -0x2c(%ebp)
    12f1:	6a 00                	push   $0x0
    12f3:	b9 02 00 00 00       	mov    $0x2,%ecx
    12f8:	e8 a3 f2 ff ff       	call   5a0 <_sanity_check_range_self>
    12fd:	83 c4 10             	add    $0x10,%esp
    1300:	85 c0                	test   %eax,%eax
    1302:	75 13                	jne    1317 <_test_allocation_child+0x2b8>
            result = max(result, TR_FAIL_PTE);
    1304:	83 ec 08             	sub    $0x8,%esp
    1307:	6a 02                	push   $0x2
    1309:	ff 75 e4             	push   -0x1c(%ebp)
    130c:	e8 3d fd ff ff       	call   104e <max>
    1311:	83 c4 10             	add    $0x10,%esp
    1314:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            PGROUNDUP((uint) new_brk),
    1317:	8b 55 c4             	mov    -0x3c(%ebp),%edx
    131a:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
            PGROUNDUP((uint) old_brk + read_end),
    1320:	8b 45 c8             	mov    -0x38(%ebp),%eax
    1323:	8d 84 06 ff 0f 00 00 	lea    0xfff(%esi,%eax,1),%eax
        if (! _sanity_check_range_self(
    132a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
    1330:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    1335:	83 ec 04             	sub    $0x4,%esp
    1338:	68 34 44 00 00       	push   $0x4434
    133d:	ff 75 d4             	push   -0x2c(%ebp)
    1340:	6a 00                	push   $0x0
    1342:	b9 02 00 00 00       	mov    $0x2,%ecx
    1347:	e8 54 f2 ff ff       	call   5a0 <_sanity_check_range_self>
    134c:	83 c4 10             	add    $0x10,%esp
    134f:	85 c0                	test   %eax,%eax
    1351:	75 13                	jne    1366 <_test_allocation_child+0x307>
            result = max(result, TR_FAIL_PTE);
    1353:	83 ec 08             	sub    $0x8,%esp
    1356:	6a 02                	push   $0x2
    1358:	ff 75 e4             	push   -0x1c(%ebp)
    135b:	e8 ee fc ff ff       	call   104e <max>
    1360:	83 c4 10             	add    $0x10,%esp
    1363:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    _pipe_sync_child(&info->pipes);
    1366:	89 d8                	mov    %ebx,%eax
    1368:	e8 54 ee ff ff       	call   1c1 <_pipe_sync_child>
    _pipe_sync_child(&info->pipes);
    136d:	89 d8                	mov    %ebx,%eax
    136f:	e8 4d ee ff ff       	call   1c1 <_pipe_sync_child>
    if (info->use_sys_read) {
    1374:	83 7b 24 00          	cmpl   $0x0,0x24(%ebx)
    1378:	75 59                	jne    13d3 <_test_allocation_child+0x374>
        for (int i = info->write_start; i < info->write_end; i += 1) {
    137a:	8b 53 14             	mov    0x14(%ebx),%edx
    137d:	e9 05 01 00 00       	jmp    1487 <_test_allocation_child+0x428>
                PGROUNDUP((uint) old_brk + read_end - 1),
    1382:	8d 94 0e fe 0f 00 00 	lea    0xffe(%esi,%ecx,1),%edx
                PGROUNDDOWN((uint) old_brk + read_start), 
    1389:	8b 45 cc             	mov    -0x34(%ebp),%eax
    138c:	01 f0                	add    %esi,%eax
            if (! _sanity_check_range_self(
    138e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
    1394:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    1399:	83 ec 04             	sub    $0x4,%esp
    139c:	68 dc 43 00 00       	push   $0x43dc
    13a1:	ff 75 d4             	push   -0x2c(%ebp)
    13a4:	6a 00                	push   $0x0
    13a6:	b9 01 00 00 00       	mov    $0x1,%ecx
    13ab:	e8 f0 f1 ff ff       	call   5a0 <_sanity_check_range_self>
    13b0:	83 c4 10             	add    $0x10,%esp
    13b3:	85 c0                	test   %eax,%eax
    13b5:	0f 85 13 ff ff ff    	jne    12ce <_test_allocation_child+0x26f>
                result = max(result, TR_FAIL_PTE);
    13bb:	83 ec 08             	sub    $0x8,%esp
    13be:	6a 02                	push   $0x2
    13c0:	ff 75 e4             	push   -0x1c(%ebp)
    13c3:	e8 86 fc ff ff       	call   104e <max>
    13c8:	83 c4 10             	add    $0x10,%esp
    13cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    13ce:	e9 fb fe ff ff       	jmp    12ce <_test_allocation_child+0x26f>
        if (pipe(fds) < 0)
    13d3:	83 ec 0c             	sub    $0xc,%esp
    13d6:	8d 45 dc             	lea    -0x24(%ebp),%eax
    13d9:	50                   	push   %eax
    13da:	e8 27 1c 00 00       	call   3006 <pipe>
    13df:	83 c4 10             	add    $0x10,%esp
    13e2:	85 c0                	test   %eax,%eax
    13e4:	78 50                	js     1436 <_test_allocation_child+0x3d7>
        for (int i = info->write_start; i < info->write_end; i += 1) {
    13e6:	8b 7b 14             	mov    0x14(%ebx),%edi
    13e9:	39 7b 18             	cmp    %edi,0x18(%ebx)
    13ec:	7e 66                	jle    1454 <_test_allocation_child+0x3f5>
            char tmp = ('Q' + i) % 128;
    13ee:	8d 47 51             	lea    0x51(%edi),%eax
    13f1:	99                   	cltd   
    13f2:	c1 ea 19             	shr    $0x19,%edx
    13f5:	01 d0                	add    %edx,%eax
    13f7:	83 e0 7f             	and    $0x7f,%eax
    13fa:	29 d0                	sub    %edx,%eax
    13fc:	88 45 db             	mov    %al,-0x25(%ebp)
            if (write(fds[1], &tmp, 1) != 1)
    13ff:	83 ec 04             	sub    $0x4,%esp
    1402:	6a 01                	push   $0x1
    1404:	8d 45 db             	lea    -0x25(%ebp),%eax
    1407:	50                   	push   %eax
    1408:	ff 75 e0             	push   -0x20(%ebp)
    140b:	e8 06 1c 00 00       	call   3016 <write>
    1410:	83 c4 10             	add    $0x10,%esp
    1413:	83 f8 01             	cmp    $0x1,%eax
    1416:	75 28                	jne    1440 <_test_allocation_child+0x3e1>
            if (read(fds[0], &old_brk[i], 1) != 1)
    1418:	8d 04 3e             	lea    (%esi,%edi,1),%eax
    141b:	83 ec 04             	sub    $0x4,%esp
    141e:	6a 01                	push   $0x1
    1420:	50                   	push   %eax
    1421:	ff 75 dc             	push   -0x24(%ebp)
    1424:	e8 e5 1b 00 00       	call   300e <read>
    1429:	83 c4 10             	add    $0x10,%esp
    142c:	83 f8 01             	cmp    $0x1,%eax
    142f:	75 19                	jne    144a <_test_allocation_child+0x3eb>
        for (int i = info->write_start; i < info->write_end; i += 1) {
    1431:	83 c7 01             	add    $0x1,%edi
    1434:	eb b3                	jmp    13e9 <_test_allocation_child+0x38a>
            CRASH("error creating pipes");
    1436:	b8 dc 32 00 00       	mov    $0x32dc,%eax
    143b:	e8 74 ec ff ff       	call   b4 <CRASH>
                CRASH("error writing to pipe");
    1440:	b8 39 34 00 00       	mov    $0x3439,%eax
    1445:	e8 6a ec ff ff       	call   b4 <CRASH>
                CRASH("error reading from pipe");
    144a:	b8 4f 34 00 00       	mov    $0x344f,%eax
    144f:	e8 60 ec ff ff       	call   b4 <CRASH>
        close(fds[0]);
    1454:	83 ec 0c             	sub    $0xc,%esp
    1457:	ff 75 dc             	push   -0x24(%ebp)
    145a:	e8 bf 1b 00 00       	call   301e <close>
        close(fds[1]);
    145f:	83 c4 04             	add    $0x4,%esp
    1462:	ff 75 e0             	push   -0x20(%ebp)
    1465:	e8 b4 1b 00 00       	call   301e <close>
    146a:	83 c4 10             	add    $0x10,%esp
    146d:	eb 1d                	jmp    148c <_test_allocation_child+0x42d>
            old_brk[i] = ('Q' + i) % 128;
    146f:	8d 42 51             	lea    0x51(%edx),%eax
    1472:	89 c1                	mov    %eax,%ecx
    1474:	c1 f9 1f             	sar    $0x1f,%ecx
    1477:	c1 e9 19             	shr    $0x19,%ecx
    147a:	01 c8                	add    %ecx,%eax
    147c:	83 e0 7f             	and    $0x7f,%eax
    147f:	29 c8                	sub    %ecx,%eax
    1481:	88 04 16             	mov    %al,(%esi,%edx,1)
        for (int i = info->write_start; i < info->write_end; i += 1) {
    1484:	83 c2 01             	add    $0x1,%edx
    1487:	39 53 18             	cmp    %edx,0x18(%ebx)
    148a:	7f e3                	jg     146f <_test_allocation_child+0x410>
    for (int i = info->read_start; i < info->read_end; i += 1) {
    148c:	8b 7b 1c             	mov    0x1c(%ebx),%edi
    148f:	eb 09                	jmp    149a <_test_allocation_child+0x43b>
            if (old_brk[i] != 0) {
    1491:	80 3c 3e 00          	cmpb   $0x0,(%esi,%edi,1)
    1495:	75 4d                	jne    14e4 <_test_allocation_child+0x485>
    for (int i = info->read_start; i < info->read_end; i += 1) {
    1497:	83 c7 01             	add    $0x1,%edi
    149a:	39 7b 20             	cmp    %edi,0x20(%ebx)
    149d:	7e 6a                	jle    1509 <_test_allocation_child+0x4aa>
        if (i >= info->write_start && i < info->write_end) {
    149f:	39 7b 14             	cmp    %edi,0x14(%ebx)
    14a2:	7f ed                	jg     1491 <_test_allocation_child+0x432>
    14a4:	39 7b 18             	cmp    %edi,0x18(%ebx)
    14a7:	7e e8                	jle    1491 <_test_allocation_child+0x432>
            if (old_brk[i] != ('Q' + i) % 128) {
    14a9:	0f be 0c 3e          	movsbl (%esi,%edi,1),%ecx
    14ad:	8d 47 51             	lea    0x51(%edi),%eax
    14b0:	99                   	cltd   
    14b1:	c1 ea 19             	shr    $0x19,%edx
    14b4:	01 d0                	add    %edx,%eax
    14b6:	83 e0 7f             	and    $0x7f,%eax
    14b9:	29 d0                	sub    %edx,%eax
    14bb:	39 c1                	cmp    %eax,%ecx
    14bd:	74 d8                	je     1497 <_test_allocation_child+0x438>
                printf(2, "ERROR: could not read back written value from "
    14bf:	ff 73 10             	push   0x10(%ebx)
    14c2:	57                   	push   %edi
    14c3:	68 5c 44 00 00       	push   $0x445c
    14c8:	6a 02                	push   $0x2
    14ca:	e8 94 1c 00 00       	call   3163 <printf>
                result = max(result, TR_FAIL_READBACK);
    14cf:	83 c4 08             	add    $0x8,%esp
    14d2:	6a 06                	push   $0x6
    14d4:	ff 75 e4             	push   -0x1c(%ebp)
    14d7:	e8 72 fb ff ff       	call   104e <max>
    14dc:	83 c4 10             	add    $0x10,%esp
    14df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    14e2:	eb b3                	jmp    1497 <_test_allocation_child+0x438>
                printf(2, "ERROR: non-zero value read 0x%x bytes into 0x%x byte allocation"
    14e4:	ff 73 10             	push   0x10(%ebx)
    14e7:	57                   	push   %edi
    14e8:	68 b0 44 00 00       	push   $0x44b0
    14ed:	6a 02                	push   $0x2
    14ef:	e8 6f 1c 00 00       	call   3163 <printf>
                result = max(result, TR_FAIL_READBACK);
    14f4:	83 c4 08             	add    $0x8,%esp
    14f7:	6a 06                	push   $0x6
    14f9:	ff 75 e4             	push   -0x1c(%ebp)
    14fc:	e8 4d fb ff ff       	call   104e <max>
    1501:	83 c4 10             	add    $0x10,%esp
    1504:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    1507:	eb 8e                	jmp    1497 <_test_allocation_child+0x438>
    for (int i = info->write_start; i < info->write_end; i += 1) {
    1509:	8b 7b 14             	mov    0x14(%ebx),%edi
    150c:	eb 03                	jmp    1511 <_test_allocation_child+0x4b2>
    150e:	83 c7 01             	add    $0x1,%edi
    1511:	8b 43 18             	mov    0x18(%ebx),%eax
    1514:	39 f8                	cmp    %edi,%eax
    1516:	7e 3b                	jle    1553 <_test_allocation_child+0x4f4>
        if (old_brk[i] != ('Q' + i) % 128) {
    1518:	0f be 0c 3e          	movsbl (%esi,%edi,1),%ecx
    151c:	8d 47 51             	lea    0x51(%edi),%eax
    151f:	99                   	cltd   
    1520:	c1 ea 19             	shr    $0x19,%edx
    1523:	01 d0                	add    %edx,%eax
    1525:	83 e0 7f             	and    $0x7f,%eax
    1528:	29 d0                	sub    %edx,%eax
    152a:	39 c1                	cmp    %eax,%ecx
    152c:	74 e0                	je     150e <_test_allocation_child+0x4af>
            printf(2, "ERROR: could not read back written value from "
    152e:	ff 73 10             	push   0x10(%ebx)
    1531:	57                   	push   %edi
    1532:	68 5c 44 00 00       	push   $0x445c
    1537:	6a 02                	push   $0x2
    1539:	e8 25 1c 00 00       	call   3163 <printf>
            result = max(result, TR_FAIL_READBACK);
    153e:	83 c4 08             	add    $0x8,%esp
    1541:	6a 06                	push   $0x6
    1543:	ff 75 e4             	push   -0x1c(%ebp)
    1546:	e8 03 fb ff ff       	call   104e <max>
    154b:	83 c4 10             	add    $0x10,%esp
    154e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    1551:	eb bb                	jmp    150e <_test_allocation_child+0x4af>
    if (!info->skip_pte_check) {
    1553:	83 7b 34 00          	cmpl   $0x0,0x34(%ebx)
    1557:	75 07                	jne    1560 <_test_allocation_child+0x501>
        if (info->write_end > info->write_start) {
    1559:	8b 4b 14             	mov    0x14(%ebx),%ecx
    155c:	39 c8                	cmp    %ecx,%eax
    155e:	7f 4c                	jg     15ac <_test_allocation_child+0x54d>
    if (info->dump)
    1560:	83 7b 2c 00          	cmpl   $0x0,0x2c(%ebx)
    1564:	0f 85 95 00 00 00    	jne    15ff <_test_allocation_child+0x5a0>
    _pipe_sync_child(&info->pipes);
    156a:	89 d8                	mov    %ebx,%eax
    156c:	e8 50 ec ff ff       	call   1c1 <_pipe_sync_child>
    if (info->fork_after_alloc) {
    1571:	83 7b 28 00          	cmpl   $0x0,0x28(%ebx)
    1575:	74 1b                	je     1592 <_test_allocation_child+0x533>
        int pid = fork();
    1577:	e8 72 1a 00 00       	call   2fee <fork>
        if (pid == -1) {
    157c:	83 f8 ff             	cmp    $0xffffffff,%eax
    157f:	0f 84 95 00 00 00    	je     161a <_test_allocation_child+0x5bb>
        } else if (pid == 0) {
    1585:	85 c0                	test   %eax,%eax
    1587:	0f 84 97 00 00 00    	je     1624 <_test_allocation_child+0x5c5>
            wait();
    158d:	e8 6c 1a 00 00       	call   2ffe <wait>
    _pipe_send_child(&info->pipes, &result, 1);
    1592:	b9 01 00 00 00       	mov    $0x1,%ecx
    1597:	8d 55 e4             	lea    -0x1c(%ebp),%edx
    159a:	89 d8                	mov    %ebx,%eax
    159c:	e8 ce ea ff ff       	call   6f <_pipe_send_child>
    return result;
    15a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
    15a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
    15a7:	5b                   	pop    %ebx
    15a8:	5e                   	pop    %esi
    15a9:	5f                   	pop    %edi
    15aa:	5d                   	pop    %ebp
    15ab:	c3                   	ret    
                PGROUNDUP((uint) old_brk + info->write_end),
    15ac:	8d 94 06 ff 0f 00 00 	lea    0xfff(%esi,%eax,1),%edx
                PGROUNDUP((uint) old_brk + info->write_start),
    15b3:	8d 84 0e ff 0f 00 00 	lea    0xfff(%esi,%ecx,1),%eax
            if (! _sanity_check_range_self(
    15ba:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
    15c0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    15c5:	83 ec 04             	sub    $0x4,%esp
    15c8:	68 30 45 00 00       	push   $0x4530
    15cd:	ff 75 d4             	push   -0x2c(%ebp)
    15d0:	6a 00                	push   $0x0
    15d2:	b9 01 00 00 00       	mov    $0x1,%ecx
    15d7:	e8 c4 ef ff ff       	call   5a0 <_sanity_check_range_self>
    15dc:	83 c4 10             	add    $0x10,%esp
    15df:	85 c0                	test   %eax,%eax
    15e1:	0f 85 79 ff ff ff    	jne    1560 <_test_allocation_child+0x501>
                result = max(result, TR_FAIL_PTE);
    15e7:	83 ec 08             	sub    $0x8,%esp
    15ea:	6a 02                	push   $0x2
    15ec:	ff 75 e4             	push   -0x1c(%ebp)
    15ef:	e8 5a fa ff ff       	call   104e <max>
    15f4:	83 c4 10             	add    $0x10,%esp
    15f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    15fa:	e9 61 ff ff ff       	jmp    1560 <_test_allocation_child+0x501>
        dump_for("allocation-post-access", getpid());
    15ff:	e8 72 1a 00 00       	call   3076 <getpid>
    1604:	83 ec 08             	sub    $0x8,%esp
    1607:	50                   	push   %eax
    1608:	68 67 34 00 00       	push   $0x3467
    160d:	e8 c9 f9 ff ff       	call   fdb <dump_for>
    1612:	83 c4 10             	add    $0x10,%esp
    1615:	e9 50 ff ff ff       	jmp    156a <_test_allocation_child+0x50b>
            CRASH("error from fork()");
    161a:	b8 7e 34 00 00       	mov    $0x347e,%eax
    161f:	e8 90 ea ff ff       	call   b4 <CRASH>
            exit();
    1624:	e8 cd 19 00 00       	call   2ff6 <exit>

00001629 <_cow_test_parent>:
static TestResult _cow_test_parent(struct cow_test_info *info) {
    1629:	55                   	push   %ebp
    162a:	89 e5                	mov    %esp,%ebp
    162c:	57                   	push   %edi
    162d:	56                   	push   %esi
    162e:	53                   	push   %ebx
    162f:	83 ec 3c             	sub    $0x3c,%esp
    1632:	89 c7                	mov    %eax,%edi
    int pids[MAX_COW_FORKS] = {0};
    1634:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
    163b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    1642:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
    1649:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    int free_check = info->skip_free_check ? NO_FREE_CHECK : WITH_FREE_CHECK;
    1650:	83 78 60 00          	cmpl   $0x0,0x60(%eax)
    1654:	0f 95 c0             	setne  %al
    1657:	0f b6 c0             	movzbl %al,%eax
    165a:	89 45 cc             	mov    %eax,-0x34(%ebp)
    clear_saved_ppns();
    165d:	e8 ad e9 ff ff       	call   f <clear_saved_ppns>
    char *heap_base = sbrk(info->pre_alloc_size);
    1662:	83 ec 0c             	sub    $0xc,%esp
    1665:	ff 77 44             	push   0x44(%edi)
    1668:	e8 11 1a 00 00       	call   307e <sbrk>
    166d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    if (heap_base == (char*) -1)
    1670:	83 c4 10             	add    $0x10,%esp
    1673:	83 f8 ff             	cmp    $0xffffffff,%eax
    1676:	75 12                	jne    168a <_cow_test_parent+0x61>
        return TR_FAIL_SBRK;
    1678:	c7 45 d4 03 00 00 00 	movl   $0x3,-0x2c(%ebp)
}
    167f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    1682:	8d 65 f4             	lea    -0xc(%ebp),%esp
    1685:	5b                   	pop    %ebx
    1686:	5e                   	pop    %esi
    1687:	5f                   	pop    %edi
    1688:	5d                   	pop    %ebp
    1689:	c3                   	ret    
    if (!info->skip_pte_check) {
    168a:	83 7f 64 00          	cmpl   $0x0,0x64(%edi)
    168e:	75 5e                	jne    16ee <_cow_test_parent+0xc5>
                (uint) heap_base + info->pre_alloc_size,
    1690:	89 c2                	mov    %eax,%edx
    1692:	03 57 44             	add    0x44(%edi),%edx
                PGROUNDUP((uint) heap_base),
    1695:	05 ff 0f 00 00       	add    $0xfff,%eax
        if (!_sanity_check_range_self(
    169a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    169f:	83 ec 04             	sub    $0x4,%esp
    16a2:	68 58 45 00 00       	push   $0x4558
    16a7:	ff 75 cc             	push   -0x34(%ebp)
    16aa:	6a 04                	push   $0x4
    16ac:	b9 02 00 00 00       	mov    $0x2,%ecx
    16b1:	e8 ea ee ff ff       	call   5a0 <_sanity_check_range_self>
    16b6:	83 c4 10             	add    $0x10,%esp
    16b9:	85 c0                	test   %eax,%eax
    16bb:	74 3a                	je     16f7 <_cow_test_parent+0xce>
    int result = TR_FAIL_UNKNOWN;
    16bd:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
    for (int region = 0; region < NUM_COW_REGIONS; ++region) {
    16c4:	be 00 00 00 00       	mov    $0x0,%esi
    16c9:	89 7d d0             	mov    %edi,-0x30(%ebp)
    16cc:	85 f6                	test   %esi,%esi
    16ce:	7e 30                	jle    1700 <_cow_test_parent+0xd7>
    if (!info->skip_pte_check) {
    16d0:	8b 7d d0             	mov    -0x30(%ebp),%edi
    16d3:	8b 5f 64             	mov    0x64(%edi),%ebx
    16d6:	85 db                	test   %ebx,%ebx
    16d8:	74 57                	je     1731 <_cow_test_parent+0x108>
    if (info->dump)
    16da:	83 7f 68 00          	cmpl   $0x0,0x68(%edi)
    16de:	0f 85 aa 00 00 00    	jne    178e <_cow_test_parent+0x165>
    for (int region = 0; region < NUM_COW_REGIONS; ++region) {
    16e4:	bb 00 00 00 00       	mov    $0x0,%ebx
    16e9:	e9 f8 00 00 00       	jmp    17e6 <_cow_test_parent+0x1bd>
    int result = TR_FAIL_UNKNOWN;
    16ee:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
    16f5:	eb cd                	jmp    16c4 <_cow_test_parent+0x9b>
            result = TR_FAIL_PTE;
    16f7:	c7 45 c8 02 00 00 00 	movl   $0x2,-0x38(%ebp)
    16fe:	eb c4                	jmp    16c4 <_cow_test_parent+0x9b>
        for (int j = info->starts[region]; j < info->ends[region]; j += 1) {
    1700:	8b 45 d0             	mov    -0x30(%ebp),%eax
    1703:	8b 7c b0 54          	mov    0x54(%eax,%esi,4),%edi
    1707:	eb 17                	jmp    1720 <_cow_test_parent+0xf7>
            heap_base[j] = _heap_test_value(j, -1);
    1709:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    170c:	8d 1c 38             	lea    (%eax,%edi,1),%ebx
    170f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
    1714:	89 f8                	mov    %edi,%eax
    1716:	e8 1b e9 ff ff       	call   36 <_heap_test_value>
    171b:	88 03                	mov    %al,(%ebx)
        for (int j = info->starts[region]; j < info->ends[region]; j += 1) {
    171d:	83 c7 01             	add    $0x1,%edi
    1720:	8b 45 d0             	mov    -0x30(%ebp),%eax
    1723:	39 7c b0 58          	cmp    %edi,0x58(%eax,%esi,4)
    1727:	7f e0                	jg     1709 <_cow_test_parent+0xe0>
    for (int region = 0; region < NUM_COW_REGIONS; ++region) {
    1729:	83 c6 01             	add    $0x1,%esi
    172c:	eb 9e                	jmp    16cc <_cow_test_parent+0xa3>
        for (int region = 0; region < NUM_COW_REGIONS; ++region) {
    172e:	83 c3 01             	add    $0x1,%ebx
    1731:	85 db                	test   %ebx,%ebx
    1733:	7f a5                	jg     16da <_cow_test_parent+0xb1>
            if (info->starts[region] < info->ends[region]) {
    1735:	8d 53 14             	lea    0x14(%ebx),%edx
    1738:	8b 44 97 04          	mov    0x4(%edi,%edx,4),%eax
    173c:	8b 54 97 08          	mov    0x8(%edi,%edx,4),%edx
    1740:	39 d0                	cmp    %edx,%eax
    1742:	7d ea                	jge    172e <_cow_test_parent+0x105>
                        PGROUNDUP((uint) heap_base + info->ends[region]),
    1744:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
    1747:	8d 94 11 ff 0f 00 00 	lea    0xfff(%ecx,%edx,1),%edx
                        PGROUNDDOWN((uint) heap_base + info->starts[region]),
    174e:	01 c8                	add    %ecx,%eax
                if (!_sanity_check_range_self(
    1750:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
    1756:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    175b:	83 ec 04             	sub    $0x4,%esp
    175e:	68 7c 45 00 00       	push   $0x457c
    1763:	ff 75 cc             	push   -0x34(%ebp)
    1766:	6a 04                	push   $0x4
    1768:	b9 01 00 00 00       	mov    $0x1,%ecx
    176d:	e8 2e ee ff ff       	call   5a0 <_sanity_check_range_self>
    1772:	83 c4 10             	add    $0x10,%esp
    1775:	85 c0                	test   %eax,%eax
    1777:	75 b5                	jne    172e <_cow_test_parent+0x105>
                    result = max(result, TR_FAIL_PTE);
    1779:	83 ec 08             	sub    $0x8,%esp
    177c:	6a 02                	push   $0x2
    177e:	ff 75 c8             	push   -0x38(%ebp)
    1781:	e8 c8 f8 ff ff       	call   104e <max>
    1786:	83 c4 10             	add    $0x10,%esp
    1789:	89 45 c8             	mov    %eax,-0x38(%ebp)
    178c:	eb a0                	jmp    172e <_cow_test_parent+0x105>
        dump_for("copy-on-write-parent-before", getpid());
    178e:	e8 e3 18 00 00       	call   3076 <getpid>
    1793:	83 ec 08             	sub    $0x8,%esp
    1796:	50                   	push   %eax
    1797:	68 90 34 00 00       	push   $0x3490
    179c:	e8 3a f8 ff ff       	call   fdb <dump_for>
    17a1:	83 c4 10             	add    $0x10,%esp
    17a4:	e9 3b ff ff ff       	jmp    16e4 <_cow_test_parent+0xbb>
            _pipe_sync_cleanup(&info->all_pipes[i]);
    17a9:	89 f0                	mov    %esi,%eax
    17ab:	e8 f0 ee ff ff       	call   6a0 <_pipe_sync_cleanup>
            printf(2, "ERROR: fork() failed\n");
    17b0:	83 ec 08             	sub    $0x8,%esp
    17b3:	68 ac 34 00 00       	push   $0x34ac
    17b8:	6a 02                	push   $0x2
    17ba:	e8 a4 19 00 00       	call   3163 <printf>
            result = max(result, TR_FAIL_FORK);
    17bf:	83 c4 08             	add    $0x8,%esp
    17c2:	6a 07                	push   $0x7
    17c4:	ff 75 c8             	push   -0x38(%ebp)
    17c7:	e8 82 f8 ff ff       	call   104e <max>
    17cc:	83 c4 10             	add    $0x10,%esp
    17cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    for (int i = 0; i < info->num_forks; i += 1) {
    17d2:	bb 00 00 00 00       	mov    $0x0,%ebx
    17d7:	e9 f0 04 00 00       	jmp    1ccc <_cow_test_parent+0x6a3>
        _pipe_sync_setup_parent(&info->all_pipes[i]);
    17dc:	89 f0                	mov    %esi,%eax
    17de:	e8 fb ef ff ff       	call   7de <_pipe_sync_setup_parent>
    for (int i = 0; i < info->num_forks; ++i) {
    17e3:	83 c3 01             	add    $0x1,%ebx
    17e6:	8b 47 40             	mov    0x40(%edi),%eax
    17e9:	39 d8                	cmp    %ebx,%eax
    17eb:	7e 38                	jle    1825 <_cow_test_parent+0x1fc>
        _init_pipes(&info->all_pipes[i]);
    17ed:	89 de                	mov    %ebx,%esi
    17ef:	c1 e6 04             	shl    $0x4,%esi
    17f2:	01 fe                	add    %edi,%esi
    17f4:	89 f0                	mov    %esi,%eax
    17f6:	e8 43 ee ff ff       	call   63e <_init_pipes>
        pids[i] = fork();
    17fb:	e8 ee 17 00 00       	call   2fee <fork>
    1800:	89 44 9d d8          	mov    %eax,-0x28(%ebp,%ebx,4)
        if (pids[i] == -1) {
    1804:	83 f8 ff             	cmp    $0xffffffff,%eax
    1807:	74 a0                	je     17a9 <_cow_test_parent+0x180>
        } else if (pids[i] == 0) {
    1809:	85 c0                	test   %eax,%eax
    180b:	75 cf                	jne    17dc <_cow_test_parent+0x1b3>
            _pipe_sync_setup_child(&info->all_pipes[i]);
    180d:	89 f0                	mov    %esi,%eax
    180f:	e8 f1 ee ff ff       	call   705 <_pipe_sync_setup_child>
            _cow_test_child(info, heap_base, i);
    1814:	89 d9                	mov    %ebx,%ecx
    1816:	8b 55 d4             	mov    -0x2c(%ebp),%edx
    1819:	89 f8                	mov    %edi,%eax
    181b:	e8 c7 f2 ff ff       	call   ae7 <_cow_test_child>
            exit();
    1820:	e8 d1 17 00 00       	call   2ff6 <exit>
    if (info->dump && info->num_forks > 0)
    1825:	83 7f 68 00          	cmpl   $0x0,0x68(%edi)
    1829:	74 04                	je     182f <_cow_test_parent+0x206>
    182b:	85 c0                	test   %eax,%eax
    182d:	7f 38                	jg     1867 <_cow_test_parent+0x23e>
    for (int region = 0; region < NUM_COW_REGIONS; ++region) {
    182f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
    1836:	89 fe                	mov    %edi,%esi
    for (int region = 0; region < NUM_COW_REGIONS; ++region) {
    1838:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
    183c:	7e 3e                	jle    187c <_cow_test_parent+0x253>
    for (int i = 0; i < info->num_forks; ++i) {
    183e:	89 f7                	mov    %esi,%edi
    1840:	bb 00 00 00 00       	mov    $0x0,%ebx
    1845:	39 5f 40             	cmp    %ebx,0x40(%edi)
    1848:	0f 8e 61 01 00 00    	jle    19af <_cow_test_parent+0x386>
        if (!_pipe_sync_parent(&info->all_pipes[i])) {
    184e:	89 d8                	mov    %ebx,%eax
    1850:	c1 e0 04             	shl    $0x4,%eax
    1853:	01 f8                	add    %edi,%eax
    1855:	e8 72 e8 ff ff       	call   cc <_pipe_sync_parent>
    185a:	85 c0                	test   %eax,%eax
    185c:	0f 84 1a 04 00 00    	je     1c7c <_cow_test_parent+0x653>
    for (int i = 0; i < info->num_forks; ++i) {
    1862:	83 c3 01             	add    $0x1,%ebx
    1865:	eb de                	jmp    1845 <_cow_test_parent+0x21c>
        dump_for("copy-on-write-child-before-writes", pids[0]);
    1867:	83 ec 08             	sub    $0x8,%esp
    186a:	ff 75 d8             	push   -0x28(%ebp)
    186d:	68 a8 45 00 00       	push   $0x45a8
    1872:	e8 64 f7 ff ff       	call   fdb <dump_for>
    1877:	83 c4 10             	add    $0x10,%esp
    187a:	eb b3                	jmp    182f <_cow_test_parent+0x206>
        if (info->starts[region] < info->ends[region]) {
    187c:	8b 45 d0             	mov    -0x30(%ebp),%eax
    187f:	83 c0 14             	add    $0x14,%eax
    1882:	8b 54 86 04          	mov    0x4(%esi,%eax,4),%edx
    1886:	8b 44 86 08          	mov    0x8(%esi,%eax,4),%eax
    188a:	39 c2                	cmp    %eax,%edx
    188c:	0f 8d 14 01 00 00    	jge    19a6 <_cow_test_parent+0x37d>
            if (!info->skip_pte_check && !_sanity_check_range_self(
    1892:	83 7e 64 00          	cmpl   $0x0,0x64(%esi)
    1896:	74 0d                	je     18a5 <_cow_test_parent+0x27c>
    for (int region = 0; region < NUM_COW_REGIONS; ++region) {
    1898:	bf 00 00 00 00       	mov    $0x0,%edi
    189d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
    18a0:	e9 94 00 00 00       	jmp    1939 <_cow_test_parent+0x310>
                    PGROUNDUP((uint) heap_base + info->ends[region]),
    18a5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
    18a8:	8d 8c 03 ff 0f 00 00 	lea    0xfff(%ebx,%eax,1),%ecx
                    PGROUNDDOWN((uint) heap_base + info->starts[region]),
    18af:	8d 04 13             	lea    (%ebx,%edx,1),%eax
            if (!info->skip_pte_check && !_sanity_check_range_self(
    18b2:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
    18b8:	89 ca                	mov    %ecx,%edx
    18ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    18bf:	83 ec 04             	sub    $0x4,%esp
    18c2:	68 cc 45 00 00       	push   $0x45cc
    18c7:	ff 75 cc             	push   -0x34(%ebp)
    18ca:	6a 02                	push   $0x2
    18cc:	b9 01 00 00 00       	mov    $0x1,%ecx
    18d1:	e8 ca ec ff ff       	call   5a0 <_sanity_check_range_self>
    18d6:	83 c4 10             	add    $0x10,%esp
    18d9:	85 c0                	test   %eax,%eax
    18db:	75 bb                	jne    1898 <_cow_test_parent+0x26f>
                result = TR_FAIL_PTE;
    18dd:	89 f7                	mov    %esi,%edi
    18df:	c7 45 d4 02 00 00 00 	movl   $0x2,-0x2c(%ebp)
    18e6:	e9 e7 fe ff ff       	jmp    17d2 <_cow_test_parent+0x1a9>
                        PGROUNDUP((uint) heap_base + info->ends[region]),
    18eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    18ee:	89 c1                	mov    %eax,%ecx
    18f0:	03 4c 9e 58          	add    0x58(%esi,%ebx,4),%ecx
    18f4:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
                        PGROUNDDOWN((uint) heap_base + info->starts[region]),
    18fa:	03 44 9e 54          	add    0x54(%esi,%ebx,4),%eax
    18fe:	89 c2                	mov    %eax,%edx
                if (!info->skip_pte_check && !_sanity_check_range(
    1900:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
    1906:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
    190c:	8b 44 bd d8          	mov    -0x28(%ebp,%edi,4),%eax
    1910:	68 1c 46 00 00       	push   $0x461c
    1915:	ff 75 cc             	push   -0x34(%ebp)
    1918:	6a 02                	push   $0x2
    191a:	6a 01                	push   $0x1
    191c:	e8 d1 ea ff ff       	call   3f2 <_sanity_check_range>
    1921:	83 c4 10             	add    $0x10,%esp
    1924:	85 c0                	test   %eax,%eax
    1926:	75 1c                	jne    1944 <_cow_test_parent+0x31b>
                    result = TR_FAIL_PTE;
    1928:	89 f7                	mov    %esi,%edi
    192a:	c7 45 d4 02 00 00 00 	movl   $0x2,-0x2c(%ebp)
    1931:	e9 9c fe ff ff       	jmp    17d2 <_cow_test_parent+0x1a9>
            for (int i = 0; i < info->num_forks; i += 1) {
    1936:	83 c7 01             	add    $0x1,%edi
    1939:	39 7e 40             	cmp    %edi,0x40(%esi)
    193c:	7e 68                	jle    19a6 <_cow_test_parent+0x37d>
                if (!info->skip_pte_check && !_sanity_check_range(
    193e:	83 7e 64 00          	cmpl   $0x0,0x64(%esi)
    1942:	74 a7                	je     18eb <_cow_test_parent+0x2c2>
                if (!info->skip_pte_check && !_same_pte_range(getpid(), pids[i],
    1944:	83 7e 64 00          	cmpl   $0x0,0x64(%esi)
    1948:	75 ec                	jne    1936 <_cow_test_parent+0x30d>
                        PGROUNDUP((uint) heap_base + info->ends[region]),
    194a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
    194d:	89 c8                	mov    %ecx,%eax
    194f:	03 44 9e 58          	add    0x58(%esi,%ebx,4),%eax
    1953:	05 ff 0f 00 00       	add    $0xfff,%eax
    1958:	89 45 c8             	mov    %eax,-0x38(%ebp)
                        PGROUNDDOWN((uint) heap_base + info->starts[region]),
    195b:	03 4c 9e 54          	add    0x54(%esi,%ebx,4),%ecx
    195f:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
                if (!info->skip_pte_check && !_same_pte_range(getpid(), pids[i],
    1962:	8b 44 bd d8          	mov    -0x28(%ebp,%edi,4),%eax
    1966:	89 45 c0             	mov    %eax,-0x40(%ebp)
    1969:	e8 08 17 00 00       	call   3076 <getpid>
    196e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
    1971:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
    1977:	83 ec 08             	sub    $0x8,%esp
    197a:	68 1c 46 00 00       	push   $0x461c
    197f:	8b 55 c8             	mov    -0x38(%ebp),%edx
    1982:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
    1988:	52                   	push   %edx
    1989:	8b 55 c0             	mov    -0x40(%ebp),%edx
    198c:	e8 28 e9 ff ff       	call   2b9 <_same_pte_range>
    1991:	83 c4 10             	add    $0x10,%esp
    1994:	85 c0                	test   %eax,%eax
    1996:	75 9e                	jne    1936 <_cow_test_parent+0x30d>
                    result = TR_FAIL_PTE;
    1998:	89 f7                	mov    %esi,%edi
    199a:	c7 45 d4 02 00 00 00 	movl   $0x2,-0x2c(%ebp)
    19a1:	e9 2c fe ff ff       	jmp    17d2 <_cow_test_parent+0x1a9>
    for (int region = 0; region < NUM_COW_REGIONS; ++region) {
    19a6:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
    19aa:	e9 89 fe ff ff       	jmp    1838 <_cow_test_parent+0x20f>
    for (int region = 0; region < NUM_COW_REGIONS; ++region) {
    19af:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
    19b6:	89 fe                	mov    %edi,%esi
    19b8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
    19bc:	0f 8e 00 02 00 00    	jle    1bc2 <_cow_test_parent+0x599>
    if (info->dump) {
    19c2:	89 f7                	mov    %esi,%edi
    19c4:	83 7e 68 00          	cmpl   $0x0,0x68(%esi)
    19c8:	0f 85 3d 02 00 00    	jne    1c0b <_cow_test_parent+0x5e2>
    for (int region = 0; region < NUM_COW_REGIONS; ++region) {
    19ce:	be 00 00 00 00       	mov    $0x0,%esi
    19d3:	e9 6b 02 00 00       	jmp    1c43 <_cow_test_parent+0x61a>
                if (!_pipe_sync_parent(&info->all_pipes[i])) { /* start write */
    19d8:	89 fb                	mov    %edi,%ebx
    19da:	c1 e3 04             	shl    $0x4,%ebx
    19dd:	01 f3                	add    %esi,%ebx
    19df:	89 d8                	mov    %ebx,%eax
    19e1:	e8 e6 e6 ff ff       	call   cc <_pipe_sync_parent>
    19e6:	85 c0                	test   %eax,%eax
    19e8:	0f 84 9a 02 00 00    	je     1c88 <_cow_test_parent+0x65f>
                if (!_pipe_sync_parent(&info->all_pipes[i])) { /* finish write */
    19ee:	89 d8                	mov    %ebx,%eax
    19f0:	e8 d7 e6 ff ff       	call   cc <_pipe_sync_parent>
    19f5:	85 c0                	test   %eax,%eax
    19f7:	0f 84 99 02 00 00    	je     1c96 <_cow_test_parent+0x66d>
                if (info->child_write[region][i]) {
    19fd:	8b 45 cc             	mov    -0x34(%ebp),%eax
    1a00:	8d 04 86             	lea    (%esi,%eax,4),%eax
    1a03:	80 7c 07 50 00       	cmpb   $0x0,0x50(%edi,%eax,1)
    1a08:	74 14                	je     1a1e <_cow_test_parent+0x3f5>
                    if (info->dump && i == 0) {
    1a0a:	83 7e 68 00          	cmpl   $0x0,0x68(%esi)
    1a0e:	74 04                	je     1a14 <_cow_test_parent+0x3eb>
    1a10:	85 ff                	test   %edi,%edi
    1a12:	74 7b                	je     1a8f <_cow_test_parent+0x466>
                    if (!info->skip_free_check) {
    1a14:	83 7e 60 00          	cmpl   $0x0,0x60(%esi)
    1a18:	0f 84 8d 00 00 00    	je     1aab <_cow_test_parent+0x482>
                if (!info->child_write[region][i] && !have_written) {
    1a1e:	8b 45 cc             	mov    -0x34(%ebp),%eax
    1a21:	8d 04 86             	lea    (%esi,%eax,4),%eax
    1a24:	8b 4d c0             	mov    -0x40(%ebp),%ecx
    1a27:	80 7c 01 50 00       	cmpb   $0x0,0x50(%ecx,%eax,1)
    1a2c:	0f 85 a4 00 00 00    	jne    1ad6 <_cow_test_parent+0x4ad>
    1a32:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
    1a36:	0f 85 9a 00 00 00    	jne    1ad6 <_cow_test_parent+0x4ad>
                    if (!info->skip_pte_check && !_same_pte_range(pids[i], getpid(),
    1a3c:	83 7e 64 00          	cmpl   $0x0,0x64(%esi)
    1a40:	0f 85 9d 01 00 00    	jne    1be3 <_cow_test_parent+0x5ba>
                            (uint) heap_base + info->ends[region],
    1a46:	8b 4d cc             	mov    -0x34(%ebp),%ecx
    1a49:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    1a4c:	89 c3                	mov    %eax,%ebx
    1a4e:	03 5c 8e 58          	add    0x58(%esi,%ecx,4),%ebx
                            (uint) heap_base + info->starts[region],
    1a52:	03 44 8e 54          	add    0x54(%esi,%ecx,4),%eax
    1a56:	89 c7                	mov    %eax,%edi
                    if (!info->skip_pte_check && !_same_pte_range(pids[i], getpid(),
    1a58:	e8 19 16 00 00       	call   3076 <getpid>
    1a5d:	89 c2                	mov    %eax,%edx
    1a5f:	8b 45 c0             	mov    -0x40(%ebp),%eax
    1a62:	8b 44 85 d8          	mov    -0x28(%ebp,%eax,4),%eax
    1a66:	83 ec 08             	sub    $0x8,%esp
    1a69:	68 8c 46 00 00       	push   $0x468c
    1a6e:	53                   	push   %ebx
    1a6f:	89 f9                	mov    %edi,%ecx
    1a71:	e8 43 e8 ff ff       	call   2b9 <_same_pte_range>
    1a76:	83 c4 10             	add    $0x10,%esp
    1a79:	85 c0                	test   %eax,%eax
    1a7b:	0f 85 62 01 00 00    	jne    1be3 <_cow_test_parent+0x5ba>
    1a81:	89 f7                	mov    %esi,%edi
                        result = TR_FAIL_PTE;
    1a83:	c7 45 d4 02 00 00 00 	movl   $0x2,-0x2c(%ebp)
    1a8a:	e9 43 fd ff ff       	jmp    17d2 <_cow_test_parent+0x1a9>
                        dump_for("copy-on-write-child-after-write", pids[i]);
    1a8f:	83 ec 08             	sub    $0x8,%esp
    1a92:	8b 45 c0             	mov    -0x40(%ebp),%eax
    1a95:	ff 74 85 d8          	push   -0x28(%ebp,%eax,4)
    1a99:	68 6c 46 00 00       	push   $0x466c
    1a9e:	e8 38 f5 ff ff       	call   fdb <dump_for>
    1aa3:	83 c4 10             	add    $0x10,%esp
    1aa6:	e9 69 ff ff ff       	jmp    1a14 <_cow_test_parent+0x3eb>
                                  (uint) heap_base + info->ends[region],
    1aab:	8b 55 cc             	mov    -0x34(%ebp),%edx
    1aae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    1ab1:	89 c1                	mov    %eax,%ecx
    1ab3:	03 4c 96 58          	add    0x58(%esi,%edx,4),%ecx
                                  (uint) heap_base + info->starts[region],
    1ab7:	03 44 96 54          	add    0x54(%esi,%edx,4),%eax
    1abb:	89 c2                	mov    %eax,%edx
                        save_ppns(pids[i],
    1abd:	8b 45 c0             	mov    -0x40(%ebp),%eax
    1ac0:	8b 44 85 d8          	mov    -0x28(%ebp,%eax,4),%eax
    1ac4:	83 ec 0c             	sub    $0xc,%esp
    1ac7:	6a 00                	push   $0x0
    1ac9:	e8 40 e7 ff ff       	call   20e <save_ppns>
    1ace:	83 c4 10             	add    $0x10,%esp
    1ad1:	e9 48 ff ff ff       	jmp    1a1e <_cow_test_parent+0x3f5>
                            (uint) heap_base + info->ends[region],
    1ad6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
    1ad9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    1adc:	89 c3                	mov    %eax,%ebx
    1ade:	03 5c 8e 58          	add    0x58(%esi,%ecx,4),%ebx
                            (uint) heap_base + info->starts[region],
    1ae2:	03 44 8e 54          	add    0x54(%esi,%ecx,4),%eax
    1ae6:	89 c7                	mov    %eax,%edi
                    if (!_different_pte_range(pids[i], getpid(),
    1ae8:	e8 89 15 00 00       	call   3076 <getpid>
    1aed:	89 c2                	mov    %eax,%edx
    1aef:	8b 45 c0             	mov    -0x40(%ebp),%eax
    1af2:	8b 44 85 d8          	mov    -0x28(%ebp,%eax,4),%eax
    1af6:	83 ec 08             	sub    $0x8,%esp
    1af9:	68 d0 46 00 00       	push   $0x46d0
    1afe:	53                   	push   %ebx
    1aff:	89 f9                	mov    %edi,%ecx
    1b01:	e8 1f e8 ff ff       	call   325 <_different_pte_range>
    1b06:	83 c4 10             	add    $0x10,%esp
    1b09:	85 c0                	test   %eax,%eax
    1b0b:	0f 85 d2 00 00 00    	jne    1be3 <_cow_test_parent+0x5ba>
                        result = TR_FAIL_PTE;
    1b11:	89 f7                	mov    %esi,%edi
    1b13:	c7 45 d4 02 00 00 00 	movl   $0x2,-0x2c(%ebp)
    1b1a:	e9 b3 fc ff ff       	jmp    17d2 <_cow_test_parent+0x1a9>
            int do_write = (i == info->parent_write_index && info->parent_write[region]);
    1b1f:	8b 45 cc             	mov    -0x34(%ebp),%eax
    1b22:	80 7c 06 48 00       	cmpb   $0x0,0x48(%esi,%eax,1)
    1b27:	75 0c                	jne    1b35 <_cow_test_parent+0x50c>
    1b29:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
    1b30:	e9 c1 00 00 00       	jmp    1bf6 <_cow_test_parent+0x5cd>
    1b35:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
    1b3c:	e9 b5 00 00 00       	jmp    1bf6 <_cow_test_parent+0x5cd>
                if (heap_base[j] != _heap_test_value(j, have_written ? -2 : -1)) {
    1b41:	ba ff ff ff ff       	mov    $0xffffffff,%edx
    1b46:	eb 48                	jmp    1b90 <_cow_test_parent+0x567>
                    printf(2, "ERROR: wrong value read from parent at offset 0x%x\n", j);
    1b48:	89 f0                	mov    %esi,%eax
    1b4a:	89 fe                	mov    %edi,%esi
    1b4c:	89 c7                	mov    %eax,%edi
    1b4e:	83 ec 04             	sub    $0x4,%esp
    1b51:	56                   	push   %esi
    1b52:	68 10 47 00 00       	push   $0x4710
    1b57:	6a 02                	push   $0x2
    1b59:	e8 05 16 00 00       	call   3163 <printf>
                    goto cleanup_children;
    1b5e:	83 c4 10             	add    $0x10,%esp
                    result = TR_FAIL_READBACK;
    1b61:	c7 45 d4 06 00 00 00 	movl   $0x6,-0x2c(%ebp)
                    goto cleanup_children;
    1b68:	e9 65 fc ff ff       	jmp    17d2 <_cow_test_parent+0x1a9>
            for (int j = info->starts[region]; j < info->ends[region]; j += 1) {
    1b6d:	83 c7 01             	add    $0x1,%edi
    1b70:	8b 45 cc             	mov    -0x34(%ebp),%eax
    1b73:	39 7c 86 58          	cmp    %edi,0x58(%esi,%eax,4)
    1b77:	7e 39                	jle    1bb2 <_cow_test_parent+0x589>
                if (heap_base[j] != _heap_test_value(j, have_written ? -2 : -1)) {
    1b79:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    1b7c:	8d 1c 38             	lea    (%eax,%edi,1),%ebx
    1b7f:	0f b6 03             	movzbl (%ebx),%eax
    1b82:	88 45 d0             	mov    %al,-0x30(%ebp)
    1b85:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
    1b89:	74 b6                	je     1b41 <_cow_test_parent+0x518>
    1b8b:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
    1b90:	89 f8                	mov    %edi,%eax
    1b92:	e8 9f e4 ff ff       	call   36 <_heap_test_value>
    1b97:	38 45 d0             	cmp    %al,-0x30(%ebp)
    1b9a:	75 ac                	jne    1b48 <_cow_test_parent+0x51f>
                if (do_write) {
    1b9c:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
    1ba0:	74 cb                	je     1b6d <_cow_test_parent+0x544>
                    heap_base[j] = _heap_test_value(j, -2);
    1ba2:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
    1ba7:	89 f8                	mov    %edi,%eax
    1ba9:	e8 88 e4 ff ff       	call   36 <_heap_test_value>
    1bae:	88 03                	mov    %al,(%ebx)
    1bb0:	eb bb                	jmp    1b6d <_cow_test_parent+0x544>
            if (do_write) {
    1bb2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
    1bb5:	85 c0                	test   %eax,%eax
    1bb7:	74 03                	je     1bbc <_cow_test_parent+0x593>
                have_written = 1;
    1bb9:	89 45 c8             	mov    %eax,-0x38(%ebp)
        for (int i  = -1; i < info->num_forks; ++i) {
    1bbc:	83 45 c0 01          	addl   $0x1,-0x40(%ebp)
    1bc0:	eb 0e                	jmp    1bd0 <_cow_test_parent+0x5a7>
    1bc2:	c7 45 c0 ff ff ff ff 	movl   $0xffffffff,-0x40(%ebp)
        int have_written = 0;
    1bc9:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
        for (int i  = -1; i < info->num_forks; ++i) {
    1bd0:	8b 45 c0             	mov    -0x40(%ebp),%eax
    1bd3:	39 46 40             	cmp    %eax,0x40(%esi)
    1bd6:	7e 2a                	jle    1c02 <_cow_test_parent+0x5d9>
            if (i >= 0) {
    1bd8:	8b 7d c0             	mov    -0x40(%ebp),%edi
    1bdb:	85 ff                	test   %edi,%edi
    1bdd:	0f 89 f5 fd ff ff    	jns    19d8 <_cow_test_parent+0x3af>
            int do_write = (i == info->parent_write_index && info->parent_write[region]);
    1be3:	8b 45 c0             	mov    -0x40(%ebp),%eax
    1be6:	39 46 4c             	cmp    %eax,0x4c(%esi)
    1be9:	0f 84 30 ff ff ff    	je     1b1f <_cow_test_parent+0x4f6>
    1bef:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
            for (int j = info->starts[region]; j < info->ends[region]; j += 1) {
    1bf6:	8b 45 cc             	mov    -0x34(%ebp),%eax
    1bf9:	8b 7c 86 54          	mov    0x54(%esi,%eax,4),%edi
    1bfd:	e9 6e ff ff ff       	jmp    1b70 <_cow_test_parent+0x547>
    for (int region = 0; region < NUM_COW_REGIONS; ++region) {
    1c02:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
    1c06:	e9 ad fd ff ff       	jmp    19b8 <_cow_test_parent+0x38f>
        dump_for("copy-on-write-parent-after", getpid());
    1c0b:	e8 66 14 00 00       	call   3076 <getpid>
    1c10:	83 ec 08             	sub    $0x8,%esp
    1c13:	50                   	push   %eax
    1c14:	68 c2 34 00 00       	push   $0x34c2
    1c19:	e8 bd f3 ff ff       	call   fdb <dump_for>
    1c1e:	83 c4 10             	add    $0x10,%esp
    1c21:	e9 a8 fd ff ff       	jmp    19ce <_cow_test_parent+0x3a5>
        _pipe_sync_parent(&info->all_pipes[i]);
    1c26:	89 f3                	mov    %esi,%ebx
    1c28:	c1 e3 04             	shl    $0x4,%ebx
    1c2b:	01 fb                	add    %edi,%ebx
    1c2d:	89 d8                	mov    %ebx,%eax
    1c2f:	e8 98 e4 ff ff       	call   cc <_pipe_sync_parent>
        _pipe_sync_cleanup(&info->all_pipes[i]);
    1c34:	89 d8                	mov    %ebx,%eax
    1c36:	e8 65 ea ff ff       	call   6a0 <_pipe_sync_cleanup>
        wait();
    1c3b:	e8 be 13 00 00       	call   2ffe <wait>
    for (int i = 0; i <info->num_forks; ++i) {
    1c40:	83 c6 01             	add    $0x1,%esi
    1c43:	39 77 40             	cmp    %esi,0x40(%edi)
    1c46:	7f de                	jg     1c26 <_cow_test_parent+0x5fd>
    if (!info->skip_free_check) {
    1c48:	8b 47 60             	mov    0x60(%edi),%eax
    1c4b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    1c4e:	85 c0                	test   %eax,%eax
    1c50:	74 0c                	je     1c5e <_cow_test_parent+0x635>
    result = TR_SUCCESS;
    1c52:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
    1c59:	e9 21 fa ff ff       	jmp    167f <_cow_test_parent+0x56>
        if (!verify_ppns_freed("page that should have been a copy for a child process")) {
    1c5e:	b8 44 47 00 00       	mov    $0x4744,%eax
    1c63:	e8 29 e7 ff ff       	call   391 <verify_ppns_freed>
    1c68:	85 c0                	test   %eax,%eax
    1c6a:	0f 85 0f fa ff ff    	jne    167f <_cow_test_parent+0x56>
            result = TR_FAIL_NO_FREE;
    1c70:	c7 45 d4 08 00 00 00 	movl   $0x8,-0x2c(%ebp)
    1c77:	e9 03 fa ff ff       	jmp    167f <_cow_test_parent+0x56>
            result = TR_FAIL_SYNC;
    1c7c:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
    1c83:	e9 4a fb ff ff       	jmp    17d2 <_cow_test_parent+0x1a9>
                    result = TR_FAIL_SYNC;
    1c88:	89 f7                	mov    %esi,%edi
    1c8a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
    1c91:	e9 3c fb ff ff       	jmp    17d2 <_cow_test_parent+0x1a9>
                    result = TR_FAIL_SYNC;
    1c96:	89 f7                	mov    %esi,%edi
    1c98:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
    1c9f:	e9 2e fb ff ff       	jmp    17d2 <_cow_test_parent+0x1a9>
            _pipe_sync_cleanup(&info->all_pipes[i]);
    1ca4:	89 d8                	mov    %ebx,%eax
    1ca6:	c1 e0 04             	shl    $0x4,%eax
    1ca9:	01 f8                	add    %edi,%eax
    1cab:	e8 f0 e9 ff ff       	call   6a0 <_pipe_sync_cleanup>
            kill(pids[i]);
    1cb0:	83 ec 0c             	sub    $0xc,%esp
    1cb3:	56                   	push   %esi
    1cb4:	e8 6d 13 00 00       	call   3026 <kill>
            pids[i] = -1;
    1cb9:	c7 44 9d d8 ff ff ff 	movl   $0xffffffff,-0x28(%ebp,%ebx,4)
    1cc0:	ff 
            wait();
    1cc1:	e8 38 13 00 00       	call   2ffe <wait>
    1cc6:	83 c4 10             	add    $0x10,%esp
    for (int i = 0; i < info->num_forks; i += 1) {
    1cc9:	83 c3 01             	add    $0x1,%ebx
    1ccc:	39 5f 40             	cmp    %ebx,0x40(%edi)
    1ccf:	0f 8e aa f9 ff ff    	jle    167f <_cow_test_parent+0x56>
        if (pids[i]) {
    1cd5:	8b 74 9d d8          	mov    -0x28(%ebp,%ebx,4),%esi
    1cd9:	85 f6                	test   %esi,%esi
    1cdb:	74 ec                	je     1cc9 <_cow_test_parent+0x6a0>
    1cdd:	eb c5                	jmp    1ca4 <_cow_test_parent+0x67b>

00001cdf <test_cow>:
static TestResult test_cow(struct cow_test_info *info) {
    1cdf:	55                   	push   %ebp
    1ce0:	89 e5                	mov    %esp,%ebp
    1ce2:	57                   	push   %edi
    1ce3:	56                   	push   %esi
    1ce4:	53                   	push   %ebx
    1ce5:	83 ec 0c             	sub    $0xc,%esp
    1ce8:	89 c3                	mov    %eax,%ebx
    printf(1, "Running copy-on-write test%s:\n"
    1cea:	8b 78 40             	mov    0x40(%eax),%edi
    1ced:	8b 70 58             	mov    0x58(%eax),%esi
    1cf0:	8b 48 54             	mov    0x54(%eax),%ecx
    1cf3:	8b 50 44             	mov    0x44(%eax),%edx
    1cf6:	83 78 6c 00          	cmpl   $0x0,0x6c(%eax)
    1cfa:	74 2f                	je     1d2b <test_cow+0x4c>
    1cfc:	b8 dd 34 00 00       	mov    $0x34dd,%eax
    1d01:	83 ec 04             	sub    $0x4,%esp
    1d04:	57                   	push   %edi
    1d05:	56                   	push   %esi
    1d06:	51                   	push   %ecx
    1d07:	52                   	push   %edx
    1d08:	50                   	push   %eax
    1d09:	68 7c 47 00 00       	push   $0x477c
    1d0e:	6a 01                	push   $0x1
    1d10:	e8 4e 14 00 00       	call   3163 <printf>
    if (!info->skip_free_check)
    1d15:	83 c4 20             	add    $0x20,%esp
    1d18:	83 7b 60 00          	cmpl   $0x0,0x60(%ebx)
    1d1c:	74 14                	je     1d32 <test_cow+0x53>
    if (info->parent_write_index == -1)
    1d1e:	83 7b 4c ff          	cmpl   $0xffffffff,0x4c(%ebx)
    1d22:	74 22                	je     1d46 <test_cow+0x67>
            printf(1, "  writing to byte range from child process %d%s\n", i,
    1d24:	be 00 00 00 00       	mov    $0x0,%esi
    1d29:	eb 53                	jmp    1d7e <test_cow+0x9f>
    printf(1, "Running copy-on-write test%s:\n"
    1d2b:	b8 50 33 00 00       	mov    $0x3350,%eax
    1d30:	eb cf                	jmp    1d01 <test_cow+0x22>
        printf(1, "  checking that physical pages allocated seem not free\n"
    1d32:	83 ec 08             	sub    $0x8,%esp
    1d35:	68 34 48 00 00       	push   $0x4834
    1d3a:	6a 01                	push   $0x1
    1d3c:	e8 22 14 00 00       	call   3163 <printf>
    1d41:	83 c4 10             	add    $0x10,%esp
    1d44:	eb d8                	jmp    1d1e <test_cow+0x3f>
        printf(1, "  writing to byte range from parent process\n");
    1d46:	83 ec 08             	sub    $0x8,%esp
    1d49:	68 98 48 00 00       	push   $0x4898
    1d4e:	6a 01                	push   $0x1
    1d50:	e8 0e 14 00 00       	call   3163 <printf>
    1d55:	83 c4 10             	add    $0x10,%esp
    1d58:	eb ca                	jmp    1d24 <test_cow+0x45>
            printf(1, "  writing to byte range from child process %d%s\n", i,
    1d5a:	b8 50 33 00 00       	mov    $0x3350,%eax
    1d5f:	50                   	push   %eax
    1d60:	56                   	push   %esi
    1d61:	68 c8 48 00 00       	push   $0x48c8
    1d66:	6a 01                	push   $0x1
    1d68:	e8 f6 13 00 00       	call   3163 <printf>
    1d6d:	83 c4 10             	add    $0x10,%esp
        if (info->parent_write[0] && info->parent_write_index == i) {
    1d70:	80 7b 48 00          	cmpb   $0x0,0x48(%ebx)
    1d74:	74 05                	je     1d7b <test_cow+0x9c>
    1d76:	39 73 4c             	cmp    %esi,0x4c(%ebx)
    1d79:	74 1c                	je     1d97 <test_cow+0xb8>
    for (int i = 0; i < info->num_forks; i += 1) {
    1d7b:	83 c6 01             	add    $0x1,%esi
    1d7e:	39 73 40             	cmp    %esi,0x40(%ebx)
    1d81:	7e 28                	jle    1dab <test_cow+0xcc>
        if (info->child_write[0][i]) {
    1d83:	80 7c 33 50 00       	cmpb   $0x0,0x50(%ebx,%esi,1)
    1d88:	74 e6                	je     1d70 <test_cow+0x91>
            printf(1, "  writing to byte range from child process %d%s\n", i,
    1d8a:	83 7b 5c 00          	cmpl   $0x0,0x5c(%ebx)
    1d8e:	74 ca                	je     1d5a <test_cow+0x7b>
    1d90:	b8 f1 34 00 00       	mov    $0x34f1,%eax
    1d95:	eb c8                	jmp    1d5f <test_cow+0x80>
            printf(1, "  writing to byte range from parent process\n");
    1d97:	83 ec 08             	sub    $0x8,%esp
    1d9a:	68 98 48 00 00       	push   $0x4898
    1d9f:	6a 01                	push   $0x1
    1da1:	e8 bd 13 00 00       	call   3163 <printf>
    1da6:	83 c4 10             	add    $0x10,%esp
    1da9:	eb d0                	jmp    1d7b <test_cow+0x9c>
    printf(1, "  and checking that appropriate pages are shared/not shared\n");
    1dab:	83 ec 08             	sub    $0x8,%esp
    1dae:	68 fc 48 00 00       	push   $0x48fc
    1db3:	6a 01                	push   $0x1
    1db5:	e8 a9 13 00 00       	call   3163 <printf>
    if (!info->skip_free_check)
    1dba:	83 c4 10             	add    $0x10,%esp
    1dbd:	83 7b 60 00          	cmpl   $0x0,0x60(%ebx)
    1dc1:	74 17                	je     1dda <test_cow+0xfb>
    int result = _cow_test_parent(info);
    1dc3:	89 d8                	mov    %ebx,%eax
    1dc5:	e8 5f f8 ff ff       	call   1629 <_cow_test_parent>
    1dca:	89 c3                	mov    %eax,%ebx
    if (result == TR_SUCCESS)
    1dcc:	85 c0                	test   %eax,%eax
    1dce:	74 1e                	je     1dee <test_cow+0x10f>
}
    1dd0:	89 d8                	mov    %ebx,%eax
    1dd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
    1dd5:	5b                   	pop    %ebx
    1dd6:	5e                   	pop    %esi
    1dd7:	5f                   	pop    %edi
    1dd8:	5d                   	pop    %ebp
    1dd9:	c3                   	ret    
        printf(1, "  and checking that pages in child which should not be shared are freed\n");
    1dda:	83 ec 08             	sub    $0x8,%esp
    1ddd:	68 3c 49 00 00       	push   $0x493c
    1de2:	6a 01                	push   $0x1
    1de4:	e8 7a 13 00 00       	call   3163 <printf>
    1de9:	83 c4 10             	add    $0x10,%esp
    1dec:	eb d5                	jmp    1dc3 <test_cow+0xe4>
        printf(1, "Test successful.\n");
    1dee:	83 ec 08             	sub    $0x8,%esp
    1df1:	68 0f 33 00 00       	push   $0x330f
    1df6:	6a 01                	push   $0x1
    1df8:	e8 66 13 00 00       	call   3163 <printf>
    1dfd:	83 c4 10             	add    $0x10,%esp
    return result;
    1e00:	eb ce                	jmp    1dd0 <test_cow+0xf1>

00001e02 <test_cow_in_child>:
static TestResult test_cow_in_child(struct cow_test_info *info) {
    1e02:	55                   	push   %ebp
    1e03:	89 e5                	mov    %esp,%ebp
    1e05:	53                   	push   %ebx
    1e06:	83 ec 24             	sub    $0x24,%esp
    1e09:	89 c3                	mov    %eax,%ebx
    info->pre_fork_p = 1;
    1e0b:	c7 40 6c 01 00 00 00 	movl   $0x1,0x6c(%eax)
    _init_pipes(&pipes);
    1e12:	8d 45 e8             	lea    -0x18(%ebp),%eax
    1e15:	e8 24 e8 ff ff       	call   63e <_init_pipes>
    int pid = fork();
    1e1a:	e8 cf 11 00 00       	call   2fee <fork>
    if (pid == -1) {
    1e1f:	83 f8 ff             	cmp    $0xffffffff,%eax
    1e22:	74 3d                	je     1e61 <test_cow_in_child+0x5f>
    } else if (pid == 0) {
    1e24:	85 c0                	test   %eax,%eax
    1e26:	74 43                	je     1e6b <test_cow_in_child+0x69>
        int count = 1;
    1e28:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
        int result = TR_FAIL_UNKNOWN;
    1e2f:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
        _pipe_sync_setup_parent(&pipes);
    1e36:	8d 45 e8             	lea    -0x18(%ebp),%eax
    1e39:	e8 a0 e9 ff ff       	call   7de <_pipe_sync_setup_parent>
        _pipe_recv_parent(&pipes, &result, &count);
    1e3e:	8d 4d e0             	lea    -0x20(%ebp),%ecx
    1e41:	8d 55 e4             	lea    -0x1c(%ebp),%edx
    1e44:	8d 45 e8             	lea    -0x18(%ebp),%eax
    1e47:	e8 d8 e2 ff ff       	call   124 <_pipe_recv_parent>
        _pipe_sync_cleanup(&pipes);
    1e4c:	8d 45 e8             	lea    -0x18(%ebp),%eax
    1e4f:	e8 4c e8 ff ff       	call   6a0 <_pipe_sync_cleanup>
        wait();
    1e54:	e8 a5 11 00 00       	call   2ffe <wait>
}
    1e59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1e5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1e5f:	c9                   	leave  
    1e60:	c3                   	ret    
        CRASH("error from fork()");
    1e61:	b8 7e 34 00 00       	mov    $0x347e,%eax
    1e66:	e8 49 e2 ff ff       	call   b4 <CRASH>
        _pipe_sync_setup_child(&pipes);
    1e6b:	8d 45 e8             	lea    -0x18(%ebp),%eax
    1e6e:	e8 92 e8 ff ff       	call   705 <_pipe_sync_setup_child>
        int result = test_cow(info);
    1e73:	89 d8                	mov    %ebx,%eax
    1e75:	e8 65 fe ff ff       	call   1cdf <test_cow>
    1e7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        _pipe_send_child(&pipes, &result, 1);
    1e7d:	b9 01 00 00 00       	mov    $0x1,%ecx
    1e82:	8d 55 e4             	lea    -0x1c(%ebp),%edx
    1e85:	8d 45 e8             	lea    -0x18(%ebp),%eax
    1e88:	e8 e2 e1 ff ff       	call   6f <_pipe_send_child>
        _pipe_sync_cleanup(&pipes);
    1e8d:	8d 45 e8             	lea    -0x18(%ebp),%eax
    1e90:	e8 0b e8 ff ff       	call   6a0 <_pipe_sync_cleanup>
        exit();
    1e95:	e8 5c 11 00 00       	call   2ff6 <exit>

00001e9a <_test_allocation_parent>:
int _test_allocation_parent(int child_pid, struct alloc_test_info *info) {
    1e9a:	55                   	push   %ebp
    1e9b:	89 e5                	mov    %esp,%ebp
    1e9d:	56                   	push   %esi
    1e9e:	53                   	push   %ebx
    1e9f:	83 ec 1c             	sub    $0x1c,%esp
    1ea2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    uint orig_heap_end = (uint) sbrk(0);
    1ea5:	6a 00                	push   $0x0
    1ea7:	e8 d2 11 00 00       	call   307e <sbrk>
    1eac:	89 c6                	mov    %eax,%esi
    if (!_pipe_sync_parent(&info->pipes)) return TR_FAIL_SYNC;
    1eae:	89 d8                	mov    %ebx,%eax
    1eb0:	e8 17 e2 ff ff       	call   cc <_pipe_sync_parent>
    1eb5:	83 c4 10             	add    $0x10,%esp
    1eb8:	85 c0                	test   %eax,%eax
    1eba:	75 0c                	jne    1ec8 <_test_allocation_parent+0x2e>
    1ebc:	b8 01 00 00 00       	mov    $0x1,%eax
}
    1ec1:	8d 65 f8             	lea    -0x8(%ebp),%esp
    1ec4:	5b                   	pop    %ebx
    1ec5:	5e                   	pop    %esi
    1ec6:	5d                   	pop    %ebp
    1ec7:	c3                   	ret    
    if (!_pipe_sync_parent(&info->pipes)) return TR_FAIL_SYNC;
    1ec8:	89 d8                	mov    %ebx,%eax
    1eca:	e8 fd e1 ff ff       	call   cc <_pipe_sync_parent>
    1ecf:	85 c0                	test   %eax,%eax
    1ed1:	75 07                	jne    1eda <_test_allocation_parent+0x40>
    1ed3:	b8 01 00 00 00       	mov    $0x1,%eax
    1ed8:	eb e7                	jmp    1ec1 <_test_allocation_parent+0x27>
    if (!_pipe_sync_parent(&info->pipes)) return TR_FAIL_SYNC;
    1eda:	89 d8                	mov    %ebx,%eax
    1edc:	e8 eb e1 ff ff       	call   cc <_pipe_sync_parent>
    1ee1:	85 c0                	test   %eax,%eax
    1ee3:	75 07                	jne    1eec <_test_allocation_parent+0x52>
    1ee5:	b8 01 00 00 00       	mov    $0x1,%eax
    1eea:	eb d5                	jmp    1ec1 <_test_allocation_parent+0x27>
    if (!_pipe_sync_parent(&info->pipes)) return TR_FAIL_SYNC;
    1eec:	89 d8                	mov    %ebx,%eax
    1eee:	e8 d9 e1 ff ff       	call   cc <_pipe_sync_parent>
    1ef3:	85 c0                	test   %eax,%eax
    1ef5:	75 07                	jne    1efe <_test_allocation_parent+0x64>
    1ef7:	b8 01 00 00 00       	mov    $0x1,%eax
    1efc:	eb c3                	jmp    1ec1 <_test_allocation_parent+0x27>
    clear_saved_ppns();
    1efe:	e8 0c e1 ff ff       	call   f <clear_saved_ppns>
    if (!info->skip_free_check) {
    1f03:	83 7b 30 00          	cmpl   $0x0,0x30(%ebx)
    1f07:	74 12                	je     1f1b <_test_allocation_parent+0x81>
    if (!_pipe_sync_parent(&info->pipes)) return TR_FAIL_SYNC;
    1f09:	89 d8                	mov    %ebx,%eax
    1f0b:	e8 bc e1 ff ff       	call   cc <_pipe_sync_parent>
    1f10:	85 c0                	test   %eax,%eax
    1f12:	75 23                	jne    1f37 <_test_allocation_parent+0x9d>
    1f14:	b8 01 00 00 00       	mov    $0x1,%eax
    1f19:	eb a6                	jmp    1ec1 <_test_allocation_parent+0x27>
        save_ppns(child_pid, orig_heap_end + info->read_start, orig_heap_end + info->read_end, 0);
    1f1b:	89 f1                	mov    %esi,%ecx
    1f1d:	03 4b 20             	add    0x20(%ebx),%ecx
    1f20:	89 f2                	mov    %esi,%edx
    1f22:	03 53 1c             	add    0x1c(%ebx),%edx
    1f25:	83 ec 0c             	sub    $0xc,%esp
    1f28:	6a 00                	push   $0x0
    1f2a:	8b 45 08             	mov    0x8(%ebp),%eax
    1f2d:	e8 dc e2 ff ff       	call   20e <save_ppns>
    1f32:	83 c4 10             	add    $0x10,%esp
    1f35:	eb d2                	jmp    1f09 <_test_allocation_parent+0x6f>
    if (!_pipe_sync_parent(&info->pipes)) return TR_FAIL_SYNC;
    1f37:	89 d8                	mov    %ebx,%eax
    1f39:	e8 8e e1 ff ff       	call   cc <_pipe_sync_parent>
    1f3e:	85 c0                	test   %eax,%eax
    1f40:	0f 84 91 00 00 00    	je     1fd7 <_test_allocation_parent+0x13d>
    if (!info->skip_free_check) {
    1f46:	83 7b 30 00          	cmpl   $0x0,0x30(%ebx)
    1f4a:	74 34                	je     1f80 <_test_allocation_parent+0xe6>
    int result = TR_FAIL_SYNC;
    1f4c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    int count = 1;
    1f53:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    _pipe_recv_parent(&info->pipes, &result, &count);
    1f5a:	8d 4d f0             	lea    -0x10(%ebp),%ecx
    1f5d:	8d 55 f4             	lea    -0xc(%ebp),%edx
    1f60:	89 d8                	mov    %ebx,%eax
    1f62:	e8 bd e1 ff ff       	call   124 <_pipe_recv_parent>
    wait();
    1f67:	e8 92 10 00 00       	call   2ffe <wait>
    if (!info->skip_free_check) {
    1f6c:	83 7b 30 00          	cmpl   $0x0,0x30(%ebx)
    1f70:	74 2a                	je     1f9c <_test_allocation_parent+0x102>
    if (!info->skip_pte_check) {
    1f72:	83 7b 34 00          	cmpl   $0x0,0x34(%ebx)
    1f76:	74 3c                	je     1fb4 <_test_allocation_parent+0x11a>
    return result;
    1f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1f7b:	e9 41 ff ff ff       	jmp    1ec1 <_test_allocation_parent+0x27>
        save_ppns(child_pid, orig_heap_end + info->write_start, orig_heap_end + info->write_end, 0);
    1f80:	89 f1                	mov    %esi,%ecx
    1f82:	03 4b 18             	add    0x18(%ebx),%ecx
    1f85:	89 f2                	mov    %esi,%edx
    1f87:	03 53 14             	add    0x14(%ebx),%edx
    1f8a:	83 ec 0c             	sub    $0xc,%esp
    1f8d:	6a 00                	push   $0x0
    1f8f:	8b 45 08             	mov    0x8(%ebp),%eax
    1f92:	e8 77 e2 ff ff       	call   20e <save_ppns>
    1f97:	83 c4 10             	add    $0x10,%esp
    1f9a:	eb b0                	jmp    1f4c <_test_allocation_parent+0xb2>
        if (!verify_ppns_freed("page that should have been allocated because of heap read/write in now-exited child process")) {
    1f9c:	b8 88 49 00 00       	mov    $0x4988,%eax
    1fa1:	e8 eb e3 ff ff       	call   391 <verify_ppns_freed>
    1fa6:	85 c0                	test   %eax,%eax
    1fa8:	75 c8                	jne    1f72 <_test_allocation_parent+0xd8>
            return TR_FAIL_NO_FREE;
    1faa:	b8 08 00 00 00       	mov    $0x8,%eax
    1faf:	e9 0d ff ff ff       	jmp    1ec1 <_test_allocation_parent+0x27>
            _sanity_check_self_nonheap(info->skip_free_check ? NO_FREE_CHECK : WITH_FREE_CHECK)
    1fb4:	83 7b 30 00          	cmpl   $0x0,0x30(%ebx)
    1fb8:	0f 95 c0             	setne  %al
    1fbb:	0f b6 c0             	movzbl %al,%eax
    1fbe:	e8 0c e6 ff ff       	call   5cf <_sanity_check_self_nonheap>
        result = max(
    1fc3:	83 ec 08             	sub    $0x8,%esp
    1fc6:	50                   	push   %eax
    1fc7:	ff 75 f4             	push   -0xc(%ebp)
    1fca:	e8 7f f0 ff ff       	call   104e <max>
    1fcf:	83 c4 10             	add    $0x10,%esp
    1fd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1fd5:	eb a1                	jmp    1f78 <_test_allocation_parent+0xde>
    if (!_pipe_sync_parent(&info->pipes)) return TR_FAIL_SYNC;
    1fd7:	b8 01 00 00 00       	mov    $0x1,%eax
    1fdc:	e9 e0 fe ff ff       	jmp    1ec1 <_test_allocation_parent+0x27>

00001fe1 <zero_if_negative>:
int zero_if_negative(int x) {
    1fe1:	55                   	push   %ebp
    1fe2:	89 e5                	mov    %esp,%ebp
    1fe4:	8b 45 08             	mov    0x8(%ebp),%eax
    if (x < 0)
    1fe7:	85 c0                	test   %eax,%eax
    1fe9:	78 02                	js     1fed <zero_if_negative+0xc>
}
    1feb:	5d                   	pop    %ebp
    1fec:	c3                   	ret    
        return 0;
    1fed:	b8 00 00 00 00       	mov    $0x0,%eax
    1ff2:	eb f7                	jmp    1feb <zero_if_negative+0xa>

00001ff4 <test_allocation>:
TestResult test_allocation(int fork_p, struct alloc_test_info *info) {
    1ff4:	55                   	push   %ebp
    1ff5:	89 e5                	mov    %esp,%ebp
    1ff7:	57                   	push   %edi
    1ff8:	56                   	push   %esi
    1ff9:	53                   	push   %ebx
    1ffa:	83 ec 1c             	sub    $0x1c,%esp
    1ffd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (info->skip_pte_check)
    2000:	83 7b 34 00          	cmpl   $0x0,0x34(%ebx)
    2004:	74 07                	je     200d <test_allocation+0x19>
        info->skip_free_check = 1;
    2006:	c7 43 30 01 00 00 00 	movl   $0x1,0x30(%ebx)
    if (info->write_end > info->alloc_size) {
    200d:	8b 43 10             	mov    0x10(%ebx),%eax
    2010:	39 43 18             	cmp    %eax,0x18(%ebx)
    2013:	0f 8f 39 01 00 00    	jg     2152 <test_allocation+0x15e>
    if (info->read_end > info->alloc_size) {
    2019:	3b 43 20             	cmp    0x20(%ebx),%eax
    201c:	0f 8c 49 01 00 00    	jl     216b <test_allocation+0x177>
    if (info->read_start < 0 || info->write_start < 0) {
    2022:	83 7b 1c 00          	cmpl   $0x0,0x1c(%ebx)
    2026:	0f 88 58 01 00 00    	js     2184 <test_allocation+0x190>
    202c:	83 7b 14 00          	cmpl   $0x0,0x14(%ebx)
    2030:	0f 88 4e 01 00 00    	js     2184 <test_allocation+0x190>
    printf(1, "Testing allocating 0x%x bytes of memory%s\n",
    2036:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
    203a:	0f 84 5d 01 00 00    	je     219d <test_allocation+0x1a9>
    2040:	ba 07 35 00 00       	mov    $0x3507,%edx
    2045:	52                   	push   %edx
    2046:	50                   	push   %eax
    2047:	68 9c 4a 00 00       	push   $0x4a9c
    204c:	6a 01                	push   $0x1
    204e:	e8 10 11 00 00       	call   3163 <printf>
    if (!info->skip_pte_check) {
    2053:	83 c4 10             	add    $0x10,%esp
    2056:	83 7b 34 00          	cmpl   $0x0,0x34(%ebx)
    205a:	75 22                	jne    207e <test_allocation+0x8a>
        printf(1, "  checking page table entry flags%s\n"
    205c:	83 7b 30 00          	cmpl   $0x0,0x30(%ebx)
    2060:	0f 84 41 01 00 00    	je     21a7 <test_allocation+0x1b3>
    2066:	b8 50 33 00 00       	mov    $0x3350,%eax
    206b:	83 ec 04             	sub    $0x4,%esp
    206e:	50                   	push   %eax
    206f:	68 c8 4a 00 00       	push   $0x4ac8
    2074:	6a 01                	push   $0x1
    2076:	e8 e8 10 00 00       	call   3163 <printf>
    207b:	83 c4 10             	add    $0x10,%esp
    printf(1, "  reading 0x%x bytes from offsets 0x%x through 0x%x\n"
    207e:	83 7b 24 00          	cmpl   $0x0,0x24(%ebx)
    2082:	0f 84 29 01 00 00    	je     21b1 <test_allocation+0x1bd>
    2088:	c7 45 d8 1b 35 00 00 	movl   $0x351b,-0x28(%ebp)
    208f:	8b 7b 18             	mov    0x18(%ebx),%edi
    2092:	8b 43 14             	mov    0x14(%ebx),%eax
    2095:	83 ec 0c             	sub    $0xc,%esp
    2098:	89 f9                	mov    %edi,%ecx
    209a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    209d:	29 c1                	sub    %eax,%ecx
    209f:	51                   	push   %ecx
    20a0:	e8 3c ff ff ff       	call   1fe1 <zero_if_negative>
    20a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
    20a8:	8b 73 20             	mov    0x20(%ebx),%esi
    20ab:	8b 53 1c             	mov    0x1c(%ebx),%edx
    20ae:	89 f1                	mov    %esi,%ecx
    20b0:	89 55 e0             	mov    %edx,-0x20(%ebp)
    20b3:	29 d1                	sub    %edx,%ecx
    20b5:	89 0c 24             	mov    %ecx,(%esp)
    20b8:	e8 24 ff ff ff       	call   1fe1 <zero_if_negative>
    20bd:	83 c4 04             	add    $0x4,%esp
    20c0:	ff 75 d8             	push   -0x28(%ebp)
    20c3:	57                   	push   %edi
    20c4:	ff 75 e4             	push   -0x1c(%ebp)
    20c7:	ff 75 dc             	push   -0x24(%ebp)
    20ca:	56                   	push   %esi
    20cb:	ff 75 e0             	push   -0x20(%ebp)
    20ce:	50                   	push   %eax
    20cf:	68 24 4b 00 00       	push   $0x4b24
    20d4:	6a 01                	push   $0x1
    20d6:	e8 88 10 00 00       	call   3163 <printf>
    if (info->fork_after_alloc) {
    20db:	83 c4 30             	add    $0x30,%esp
    20de:	83 7b 28 00          	cmpl   $0x0,0x28(%ebx)
    20e2:	0f 85 d5 00 00 00    	jne    21bd <test_allocation+0x1c9>
    if (fork_p && !info->skip_free_check) {
    20e8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
    20ec:	74 0a                	je     20f8 <test_allocation+0x104>
    20ee:	83 7b 30 00          	cmpl   $0x0,0x30(%ebx)
    20f2:	0f 84 dc 00 00 00    	je     21d4 <test_allocation+0x1e0>
    if (fork_p) {
    20f8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
    20fc:	0f 84 22 01 00 00    	je     2224 <test_allocation+0x230>
        _init_pipes(&info->pipes);
    2102:	89 d8                	mov    %ebx,%eax
    2104:	e8 35 e5 ff ff       	call   63e <_init_pipes>
        int child_pid = fork();
    2109:	e8 e0 0e 00 00       	call   2fee <fork>
    210e:	89 c7                	mov    %eax,%edi
        if (child_pid == -1) {
    2110:	83 f8 ff             	cmp    $0xffffffff,%eax
    2113:	0f 84 52 01 00 00    	je     226b <test_allocation+0x277>
        } else if (child_pid == 0) {
    2119:	85 c0                	test   %eax,%eax
    211b:	0f 84 ca 00 00 00    	je     21eb <test_allocation+0x1f7>
            int result = _test_allocation_parent(child_pid, info);
    2121:	83 ec 08             	sub    $0x8,%esp
    2124:	53                   	push   %ebx
    2125:	50                   	push   %eax
    2126:	e8 6f fd ff ff       	call   1e9a <_test_allocation_parent>
    212b:	89 c6                	mov    %eax,%esi
            _pipe_sync_cleanup(&info->pipes);
    212d:	89 d8                	mov    %ebx,%eax
    212f:	e8 6c e5 ff ff       	call   6a0 <_pipe_sync_cleanup>
            if (result == TR_FAIL_SYNC) {
    2134:	83 c4 10             	add    $0x10,%esp
    2137:	83 fe 01             	cmp    $0x1,%esi
    213a:	0f 84 b7 00 00 00    	je     21f7 <test_allocation+0x203>
            if (result == TR_SUCCESS) {
    2140:	85 f6                	test   %esi,%esi
    2142:	0f 84 c5 00 00 00    	je     220d <test_allocation+0x219>
}
    2148:	89 f0                	mov    %esi,%eax
    214a:	8d 65 f4             	lea    -0xc(%ebp),%esp
    214d:	5b                   	pop    %ebx
    214e:	5e                   	pop    %esi
    214f:	5f                   	pop    %edi
    2150:	5d                   	pop    %ebp
    2151:	c3                   	ret    
        printf(1, "ERROR: write_end after end of allocation\n");
    2152:	83 ec 08             	sub    $0x8,%esp
    2155:	68 44 4a 00 00       	push   $0x4a44
    215a:	6a 01                	push   $0x1
    215c:	e8 02 10 00 00       	call   3163 <printf>
        return TR_FAIL_PARAM;
    2161:	83 c4 10             	add    $0x10,%esp
    2164:	be 09 00 00 00       	mov    $0x9,%esi
    2169:	eb dd                	jmp    2148 <test_allocation+0x154>
        printf(1, "ERROR: read_end after end of allocation\n");
    216b:	83 ec 08             	sub    $0x8,%esp
    216e:	68 70 4a 00 00       	push   $0x4a70
    2173:	6a 01                	push   $0x1
    2175:	e8 e9 0f 00 00       	call   3163 <printf>
        return TR_FAIL_PARAM;
    217a:	83 c4 10             	add    $0x10,%esp
    217d:	be 09 00 00 00       	mov    $0x9,%esi
    2182:	eb c4                	jmp    2148 <test_allocation+0x154>
        printf(1, "ERROR: negative offset\n");
    2184:	83 ec 08             	sub    $0x8,%esp
    2187:	68 2f 35 00 00       	push   $0x352f
    218c:	6a 01                	push   $0x1
    218e:	e8 d0 0f 00 00       	call   3163 <printf>
        return TR_FAIL_PARAM;
    2193:	83 c4 10             	add    $0x10,%esp
    2196:	be 09 00 00 00       	mov    $0x9,%esi
    219b:	eb ab                	jmp    2148 <test_allocation+0x154>
    printf(1, "Testing allocating 0x%x bytes of memory%s\n",
    219d:	ba 50 33 00 00       	mov    $0x3350,%edx
    21a2:	e9 9e fe ff ff       	jmp    2045 <test_allocation+0x51>
        printf(1, "  checking page table entry flags%s\n"
    21a7:	b8 e4 49 00 00       	mov    $0x49e4,%eax
    21ac:	e9 ba fe ff ff       	jmp    206b <test_allocation+0x77>
    printf(1, "  reading 0x%x bytes from offsets 0x%x through 0x%x\n"
    21b1:	c7 45 d8 50 33 00 00 	movl   $0x3350,-0x28(%ebp)
    21b8:	e9 d2 fe ff ff       	jmp    208f <test_allocation+0x9b>
        printf(1, "  forking a grandchild process to make sure fork()\n"
    21bd:	83 ec 08             	sub    $0x8,%esp
    21c0:	68 90 4b 00 00       	push   $0x4b90
    21c5:	6a 01                	push   $0x1
    21c7:	e8 97 0f 00 00       	call   3163 <printf>
    21cc:	83 c4 10             	add    $0x10,%esp
    21cf:	e9 14 ff ff ff       	jmp    20e8 <test_allocation+0xf4>
        printf(1, "  checking that sample of allocated pages are free after\n"
    21d4:	83 ec 08             	sub    $0x8,%esp
    21d7:	68 f0 4b 00 00       	push   $0x4bf0
    21dc:	6a 01                	push   $0x1
    21de:	e8 80 0f 00 00       	call   3163 <printf>
    21e3:	83 c4 10             	add    $0x10,%esp
    21e6:	e9 0d ff ff ff       	jmp    20f8 <test_allocation+0x104>
            _test_allocation_child(info);
    21eb:	89 d8                	mov    %ebx,%eax
    21ed:	e8 6d ee ff ff       	call   105f <_test_allocation_child>
            exit();
    21f2:	e8 ff 0d 00 00       	call   2ff6 <exit>
                kill(child_pid);
    21f7:	83 ec 0c             	sub    $0xc,%esp
    21fa:	57                   	push   %edi
    21fb:	e8 26 0e 00 00       	call   3026 <kill>
                wait();
    2200:	e8 f9 0d 00 00       	call   2ffe <wait>
    2205:	83 c4 10             	add    $0x10,%esp
    2208:	e9 33 ff ff ff       	jmp    2140 <test_allocation+0x14c>
                printf(1, "Test successful.\n");
    220d:	83 ec 08             	sub    $0x8,%esp
    2210:	68 0f 33 00 00       	push   $0x330f
    2215:	6a 01                	push   $0x1
    2217:	e8 47 0f 00 00       	call   3163 <printf>
    221c:	83 c4 10             	add    $0x10,%esp
            return result;
    221f:	e9 24 ff ff ff       	jmp    2148 <test_allocation+0x154>
        info->pipes = NO_PIPES;
    2224:	a1 28 58 00 00       	mov    0x5828,%eax
    2229:	89 03                	mov    %eax,(%ebx)
    222b:	a1 2c 58 00 00       	mov    0x582c,%eax
    2230:	89 43 04             	mov    %eax,0x4(%ebx)
    2233:	a1 30 58 00 00       	mov    0x5830,%eax
    2238:	89 43 08             	mov    %eax,0x8(%ebx)
    223b:	a1 34 58 00 00       	mov    0x5834,%eax
    2240:	89 43 0c             	mov    %eax,0xc(%ebx)
        int result = _test_allocation_child(info);
    2243:	89 d8                	mov    %ebx,%eax
    2245:	e8 15 ee ff ff       	call   105f <_test_allocation_child>
    224a:	89 c6                	mov    %eax,%esi
        if (result == TR_SUCCESS) {
    224c:	85 c0                	test   %eax,%eax
    224e:	0f 85 f4 fe ff ff    	jne    2148 <test_allocation+0x154>
            printf(1, "Test successful.\n");
    2254:	83 ec 08             	sub    $0x8,%esp
    2257:	68 0f 33 00 00       	push   $0x330f
    225c:	6a 01                	push   $0x1
    225e:	e8 00 0f 00 00       	call   3163 <printf>
    2263:	83 c4 10             	add    $0x10,%esp
        return result;
    2266:	e9 dd fe ff ff       	jmp    2148 <test_allocation+0x154>
            return TR_FAIL_FORK;
    226b:	be 07 00 00 00       	mov    $0x7,%esi
    2270:	e9 d3 fe ff ff       	jmp    2148 <test_allocation+0x154>

00002275 <setup>:

static char *new_args[20];
static char input_buffer[200];

MAYBE_UNUSED
void setup(int *pargc, char ***pargv) {
    2275:	55                   	push   %ebp
    2276:	89 e5                	mov    %esp,%ebp
    2278:	56                   	push   %esi
    2279:	53                   	push   %ebx
    227a:	8b 5d 08             	mov    0x8(%ebp),%ebx
    227d:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (pargc) {
    2280:	85 db                	test   %ebx,%ebx
    2282:	74 09                	je     228d <setup+0x18>
        real_argv0 = (*pargv)[0];
    2284:	8b 06                	mov    (%esi),%eax
    2286:	8b 00                	mov    (%eax),%eax
    2288:	a3 80 79 00 00       	mov    %eax,0x7980
    }
    if (pargc && *pargc > 1 && 0 == strcmp((*pargv)[1], "__TEST_CHILD__")) {
    228d:	85 db                	test   %ebx,%ebx
    228f:	74 05                	je     2296 <setup+0x21>
    2291:	83 3b 01             	cmpl   $0x1,(%ebx)
    2294:	7f 11                	jg     22a7 <setup+0x32>
        _test_exec_child(*pargv);
        exit();
    }
    if (getpid() == 1) {
    2296:	e8 db 0d 00 00       	call   3076 <getpid>
    229b:	83 f8 01             	cmp    $0x1,%eax
    229e:	74 2c                	je     22cc <setup+0x57>
            } while (p != 0 && *pargc + 1 < sizeof(new_args)/sizeof(new_args[0]));
            new_args[*pargc] = 0;
            *pargv = new_args;
        }
    }
}
    22a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
    22a3:	5b                   	pop    %ebx
    22a4:	5e                   	pop    %esi
    22a5:	5d                   	pop    %ebp
    22a6:	c3                   	ret    
    if (pargc && *pargc > 1 && 0 == strcmp((*pargv)[1], "__TEST_CHILD__")) {
    22a7:	8b 06                	mov    (%esi),%eax
    22a9:	83 ec 08             	sub    $0x8,%esp
    22ac:	68 d0 33 00 00       	push   $0x33d0
    22b1:	ff 70 04             	push   0x4(%eax)
    22b4:	e8 c4 0b 00 00       	call   2e7d <strcmp>
    22b9:	83 c4 10             	add    $0x10,%esp
    22bc:	85 c0                	test   %eax,%eax
    22be:	75 d6                	jne    2296 <setup+0x21>
        _test_exec_child(*pargv);
    22c0:	8b 06                	mov    (%esi),%eax
    22c2:	e8 70 e4 ff ff       	call   737 <_test_exec_child>
        exit();
    22c7:	e8 2a 0d 00 00       	call   2ff6 <exit>
        mknod("console", 1, 1);
    22cc:	83 ec 04             	sub    $0x4,%esp
    22cf:	6a 01                	push   $0x1
    22d1:	6a 01                	push   $0x1
    22d3:	68 47 35 00 00       	push   $0x3547
    22d8:	e8 61 0d 00 00       	call   303e <mknod>
        open("console", O_RDWR);
    22dd:	83 c4 08             	add    $0x8,%esp
    22e0:	6a 02                	push   $0x2
    22e2:	68 47 35 00 00       	push   $0x3547
    22e7:	e8 4a 0d 00 00       	call   3036 <open>
        dup(0);
    22ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    22f3:	e8 76 0d 00 00       	call   306e <dup>
        dup(0);
    22f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    22ff:	e8 6a 0d 00 00       	call   306e <dup>
        if (want_args && pargc != 0) {
    2304:	83 c4 10             	add    $0x10,%esp
    2307:	83 3d 38 58 00 00 00 	cmpl   $0x0,0x5838
    230e:	74 90                	je     22a0 <setup+0x2b>
    2310:	85 db                	test   %ebx,%ebx
    2312:	74 8c                	je     22a0 <setup+0x2b>
            printf(1, "Enter arguments (-help for usage info): ");
    2314:	83 ec 08             	sub    $0x8,%esp
    2317:	68 88 4c 00 00       	push   $0x4c88
    231c:	6a 01                	push   $0x1
    231e:	e8 40 0e 00 00       	call   3163 <printf>
            gets(input_buffer, sizeof input_buffer - 1);
    2323:	83 c4 08             	add    $0x8,%esp
    2326:	68 c7 00 00 00       	push   $0xc7
    232b:	68 40 58 00 00       	push   $0x5840
    2330:	e8 c2 0b 00 00       	call   2ef7 <gets>
            input_buffer[strlen(input_buffer) - 1] = '\0';
    2335:	c7 04 24 40 58 00 00 	movl   $0x5840,(%esp)
    233c:	e8 62 0b 00 00       	call   2ea3 <strlen>
    2341:	c6 80 3f 58 00 00 00 	movb   $0x0,0x583f(%eax)
            new_args[0] = "AS-INIT";
    2348:	c7 05 20 59 00 00 2f 	movl   $0x332f,0x5920
    234f:	33 00 00 
            *pargc = 1;
    2352:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
    2358:	83 c4 10             	add    $0x10,%esp
            char *p = input_buffer;
    235b:	b8 40 58 00 00       	mov    $0x5840,%eax
    2360:	eb 11                	jmp    2373 <setup+0xfe>
                    *pargc += 1;
    2362:	83 03 01             	addl   $0x1,(%ebx)
            } while (p != 0 && *pargc + 1 < sizeof(new_args)/sizeof(new_args[0]));
    2365:	85 c0                	test   %eax,%eax
    2367:	74 30                	je     2399 <setup+0x124>
    2369:	8b 0b                	mov    (%ebx),%ecx
    236b:	8d 51 01             	lea    0x1(%ecx),%edx
    236e:	83 fa 13             	cmp    $0x13,%edx
    2371:	77 26                	ja     2399 <setup+0x124>
                new_args[*pargc] = p;
    2373:	8b 13                	mov    (%ebx),%edx
    2375:	89 04 95 20 59 00 00 	mov    %eax,0x5920(,%edx,4)
                p = strchr(p, ' ');
    237c:	83 ec 08             	sub    $0x8,%esp
    237f:	6a 20                	push   $0x20
    2381:	50                   	push   %eax
    2382:	e8 4d 0b 00 00       	call   2ed4 <strchr>
                if (p) {
    2387:	83 c4 10             	add    $0x10,%esp
    238a:	85 c0                	test   %eax,%eax
    238c:	74 d4                	je     2362 <setup+0xed>
                    *p = '\0';
    238e:	c6 00 00             	movb   $0x0,(%eax)
                    p += 1;
    2391:	83 c0 01             	add    $0x1,%eax
                    *pargc += 1;
    2394:	83 03 01             	addl   $0x1,(%ebx)
    2397:	eb cc                	jmp    2365 <setup+0xf0>
            new_args[*pargc] = 0;
    2399:	8b 03                	mov    (%ebx),%eax
    239b:	c7 04 85 20 59 00 00 	movl   $0x0,0x5920(,%eax,4)
    23a2:	00 00 00 00 
            *pargv = new_args;
    23a6:	c7 06 20 59 00 00    	movl   $0x5920,(%esi)
}
    23ac:	e9 ef fe ff ff       	jmp    22a0 <setup+0x2b>

000023b1 <cleanup>:

MAYBE_UNUSED
void cleanup() {
    23b1:	55                   	push   %ebp
    23b2:	89 e5                	mov    %esp,%ebp
    23b4:	83 ec 08             	sub    $0x8,%esp
    if (getpid() == 1) {
    23b7:	e8 ba 0c 00 00       	call   3076 <getpid>
    23bc:	83 f8 01             	cmp    $0x1,%eax
    23bf:	75 07                	jne    23c8 <cleanup+0x17>
        shutdown();
    23c1:	e8 f0 0c 00 00       	call   30b6 <shutdown>
    } else {
        exit();
    }
}
    23c6:	c9                   	leave  
    23c7:	c3                   	ret    
        exit();
    23c8:	e8 29 0c 00 00       	call   2ff6 <exit>

000023cd <getopt>:
void getopt(int argc, char **argv, struct option *options) {
    23cd:	55                   	push   %ebp
    23ce:	89 e5                	mov    %esp,%ebp
    23d0:	57                   	push   %edi
    23d1:	56                   	push   %esi
    23d2:	53                   	push   %ebx
    23d3:	83 ec 2c             	sub    $0x2c,%esp
    23d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    23d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    23dc:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
    for (int i = 1; i < argc; i += 1) {
    23df:	bb 01 00 00 00       	mov    $0x1,%ebx
    23e4:	e9 c9 00 00 00       	jmp    24b2 <getopt+0xe5>
            p += 1;
    23e9:	8d 48 01             	lea    0x1(%eax),%ecx
    23ec:	89 4d dc             	mov    %ecx,-0x24(%ebp)
            if (*p == '-') {
    23ef:	80 78 01 2d          	cmpb   $0x2d,0x1(%eax)
    23f3:	74 22                	je     2417 <getopt+0x4a>
            if (0 == strcmp("help", p)) {
    23f5:	83 ec 08             	sub    $0x8,%esp
    23f8:	ff 75 dc             	push   -0x24(%ebp)
    23fb:	68 b1 36 00 00       	push   $0x36b1
    2400:	e8 78 0a 00 00       	call   2e7d <strcmp>
    2405:	83 c4 10             	add    $0x10,%esp
    2408:	85 c0                	test   %eax,%eax
    240a:	74 13                	je     241f <getopt+0x52>
void getopt(int argc, char **argv, struct option *options) {
    240c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
    240f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
    2412:	8b 5d dc             	mov    -0x24(%ebp),%ebx
    2415:	eb 5d                	jmp    2474 <getopt+0xa7>
                p += 1;
    2417:	83 c0 02             	add    $0x2,%eax
    241a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    241d:	eb d6                	jmp    23f5 <getopt+0x28>
                getopt_usage(argv[0], options);
    241f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
    2422:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    2425:	8b 00                	mov    (%eax),%eax
    2427:	e8 7d e8 ff ff       	call   ca9 <getopt_usage>
                cleanup();
    242c:	e8 80 ff ff ff       	call   23b1 <cleanup>
    2431:	eb d9                	jmp    240c <getopt+0x3f>
                        if (p[option_len] != '=') {
    2433:	8b 5d d8             	mov    -0x28(%ebp),%ebx
    2436:	8b 55 dc             	mov    -0x24(%ebp),%edx
    2439:	80 3c 02 3d          	cmpb   $0x3d,(%edx,%eax,1)
    243d:	75 1c                	jne    245b <getopt+0x8e>
                        *option->value = decorhextoi(p + option_len + 1);
    243f:	83 ec 0c             	sub    $0xc,%esp
    2442:	8b 55 dc             	mov    -0x24(%ebp),%edx
    2445:	8d 44 02 01          	lea    0x1(%edx,%eax,1),%eax
    2449:	50                   	push   %eax
    244a:	e8 4e eb ff ff       	call   f9d <decorhextoi>
    244f:	89 c2                	mov    %eax,%edx
    2451:	8b 47 08             	mov    0x8(%edi),%eax
    2454:	89 10                	mov    %edx,(%eax)
    2456:	83 c4 10             	add    $0x10,%esp
    2459:	eb 54                	jmp    24af <getopt+0xe2>
                            printf(2, "expected '=' after '-%s'\n", option->name);
    245b:	83 ec 04             	sub    $0x4,%esp
    245e:	ff 37                	push   (%edi)
    2460:	68 4f 35 00 00       	push   $0x354f
    2465:	6a 02                	push   $0x2
    2467:	e8 f7 0c 00 00       	call   3163 <printf>
                            exit();
    246c:	e8 85 0b 00 00       	call   2ff6 <exit>
            for (struct option *option = options; option->name; option += 1) {
    2471:	83 c7 10             	add    $0x10,%edi
    2474:	8b 37                	mov    (%edi),%esi
    2476:	85 f6                	test   %esi,%esi
    2478:	74 66                	je     24e0 <getopt+0x113>
                if (strprefix(option->name, p)) {
    247a:	83 ec 08             	sub    $0x8,%esp
    247d:	53                   	push   %ebx
    247e:	56                   	push   %esi
    247f:	e8 91 eb ff ff       	call   1015 <strprefix>
    2484:	83 c4 10             	add    $0x10,%esp
    2487:	85 c0                	test   %eax,%eax
    2489:	74 e6                	je     2471 <getopt+0xa4>
                    int option_len = strlen(option->name);
    248b:	83 ec 0c             	sub    $0xc,%esp
    248e:	56                   	push   %esi
    248f:	e8 0f 0a 00 00       	call   2ea3 <strlen>
                    if (option->boolean) {
    2494:	83 c4 10             	add    $0x10,%esp
    2497:	83 7f 0c 00          	cmpl   $0x0,0xc(%edi)
    249b:	74 96                	je     2433 <getopt+0x66>
                        if (p[option_len] != '\0')
    249d:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
    24a1:	75 ce                	jne    2471 <getopt+0xa4>
                        *option->value = 1;
    24a3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
    24a6:	8b 47 08             	mov    0x8(%edi),%eax
    24a9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
    for (int i = 1; i < argc; i += 1) {
    24af:	83 c3 01             	add    $0x1,%ebx
    24b2:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
    24b5:	7d 48                	jge    24ff <getopt+0x132>
        const char *p = argv[i];
    24b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    24ba:	8b 04 98             	mov    (%eax,%ebx,4),%eax
        if (*p == '-') {
    24bd:	80 38 2d             	cmpb   $0x2d,(%eax)
    24c0:	0f 84 23 ff ff ff    	je     23e9 <getopt+0x1c>
            printf(2, "unrecogonized argument '%s'\n", p);
    24c6:	83 ec 04             	sub    $0x4,%esp
    24c9:	50                   	push   %eax
    24ca:	68 84 35 00 00       	push   $0x3584
    24cf:	6a 02                	push   $0x2
    24d1:	e8 8d 0c 00 00       	call   3163 <printf>
            cleanup();
    24d6:	e8 d6 fe ff ff       	call   23b1 <cleanup>
    24db:	83 c4 10             	add    $0x10,%esp
    24de:	eb cf                	jmp    24af <getopt+0xe2>
                printf(2, "unrecognized option '-%s'\n", p);
    24e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
    24e3:	83 ec 04             	sub    $0x4,%esp
    24e6:	ff 75 dc             	push   -0x24(%ebp)
    24e9:	68 69 35 00 00       	push   $0x3569
    24ee:	6a 02                	push   $0x2
    24f0:	e8 6e 0c 00 00       	call   3163 <printf>
                cleanup();
    24f5:	e8 b7 fe ff ff       	call   23b1 <cleanup>
    24fa:	83 c4 10             	add    $0x10,%esp
    24fd:	eb b0                	jmp    24af <getopt+0xe2>
}
    24ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
    2502:	5b                   	pop    %ebx
    2503:	5e                   	pop    %esi
    2504:	5f                   	pop    %edi
    2505:	5d                   	pop    %ebp
    2506:	c3                   	ret    

00002507 <run_cow_test_from_args>:

MAYBE_UNUSED
int run_cow_test_from_args(int argc, char **argv) {
    2507:	55                   	push   %ebp
    2508:	89 e5                	mov    %esp,%ebp
    250a:	57                   	push   %edi
    250b:	81 ec a4 01 00 00    	sub    $0x1a4,%esp
    struct cow_test_info info = {
    2511:	8d 7d 88             	lea    -0x78(%ebp),%edi
    2514:	b8 00 00 00 00       	mov    $0x0,%eax
    2519:	b9 1c 00 00 00       	mov    $0x1c,%ecx
    251e:	f3 ab                	rep stos %eax,%es:(%edi)
    2520:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
    2527:	c7 45 cc 00 10 00 00 	movl   $0x1000,-0x34(%ebp)
    252e:	c6 45 d0 01          	movb   $0x1,-0x30(%ebp)
    2532:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
    2539:	c7 45 dc 00 02 00 00 	movl   $0x200,-0x24(%ebp)
    2540:	c7 45 e0 00 04 00 00 	movl   $0x400,-0x20(%ebp)
        .parent_write_index = -1,

        .starts[0] = 512,
        .ends[0] = 1024,
    };
    int pre_fork_p = 0;
    2547:	c7 45 84 00 00 00 00 	movl   $0x0,-0x7c(%ebp)
    int parent_first = 0, parent_middle = 0, parent_last = 0, parent_never = 0;
    254e:	c7 45 80 00 00 00 00 	movl   $0x0,-0x80(%ebp)
    2555:	c7 85 7c ff ff ff 00 	movl   $0x0,-0x84(%ebp)
    255c:	00 00 00 
    255f:	c7 85 78 ff ff ff 00 	movl   $0x0,-0x88(%ebp)
    2566:	00 00 00 
    2569:	c7 85 74 ff ff ff 00 	movl   $0x0,-0x8c(%ebp)
    2570:	00 00 00 
    int no_child_write = 0, child_write_except = -1, child_write_only = -1;
    2573:	c7 85 70 ff ff ff 00 	movl   $0x0,-0x90(%ebp)
    257a:	00 00 00 
    257d:	c7 85 6c ff ff ff ff 	movl   $0xffffffff,-0x94(%ebp)
    2584:	ff ff ff 
    2587:	c7 85 68 ff ff ff ff 	movl   $0xffffffff,-0x98(%ebp)
    258e:	ff ff ff 
    struct option options[] = {
    2591:	8d bd 58 fe ff ff    	lea    -0x1a8(%ebp),%edi
    2597:	b9 44 00 00 00       	mov    $0x44,%ecx
    259c:	f3 ab                	rep stos %eax,%es:(%edi)
    259e:	c7 85 58 fe ff ff a1 	movl   $0x35a1,-0x1a8(%ebp)
    25a5:	35 00 00 
    25a8:	c7 85 5c fe ff ff b4 	movl   $0x4cb4,-0x1a4(%ebp)
    25af:	4c 00 00 
    25b2:	8d 45 c8             	lea    -0x38(%ebp),%eax
    25b5:	89 85 60 fe ff ff    	mov    %eax,-0x1a0(%ebp)
    25bb:	c7 85 68 fe ff ff a7 	movl   $0x35a7,-0x198(%ebp)
    25c2:	35 00 00 
    25c5:	c7 85 6c fe ff ff d8 	movl   $0x4cd8,-0x194(%ebp)
    25cc:	4c 00 00 
    25cf:	8d 45 cc             	lea    -0x34(%ebp),%eax
    25d2:	89 85 70 fe ff ff    	mov    %eax,-0x190(%ebp)
    25d8:	c7 85 78 fe ff ff 73 	movl   $0x3673,-0x188(%ebp)
    25df:	36 00 00 
    25e2:	c7 85 7c fe ff ff 04 	movl   $0x4d04,-0x184(%ebp)
    25e9:	4d 00 00 
    25ec:	8d 45 dc             	lea    -0x24(%ebp),%eax
    25ef:	89 85 80 fe ff ff    	mov    %eax,-0x180(%ebp)
    25f5:	c7 85 88 fe ff ff 7e 	movl   $0x367e,-0x178(%ebp)
    25fc:	36 00 00 
    25ff:	c7 85 8c fe ff ff 30 	movl   $0x4d30,-0x174(%ebp)
    2606:	4d 00 00 
    2609:	8d 45 e0             	lea    -0x20(%ebp),%eax
    260c:	89 85 90 fe ff ff    	mov    %eax,-0x170(%ebp)
    2612:	c7 85 98 fe ff ff ac 	movl   $0x35ac,-0x168(%ebp)
    2619:	35 00 00 
    261c:	c7 85 9c fe ff ff 64 	movl   $0x4d64,-0x164(%ebp)
    2623:	4d 00 00 
    2626:	8d 45 80             	lea    -0x80(%ebp),%eax
    2629:	89 85 a0 fe ff ff    	mov    %eax,-0x160(%ebp)
    262f:	c7 85 a4 fe ff ff 01 	movl   $0x1,-0x15c(%ebp)
    2636:	00 00 00 
    2639:	c7 85 a8 fe ff ff b9 	movl   $0x35b9,-0x158(%ebp)
    2640:	35 00 00 
    2643:	c7 85 ac fe ff ff c5 	movl   $0x35c5,-0x154(%ebp)
    264a:	35 00 00 
    264d:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
    2653:	89 85 b0 fe ff ff    	mov    %eax,-0x150(%ebp)
    2659:	c7 85 b4 fe ff ff 01 	movl   $0x1,-0x14c(%ebp)
    2660:	00 00 00 
    2663:	c7 85 b8 fe ff ff dc 	movl   $0x35dc,-0x148(%ebp)
    266a:	35 00 00 
    266d:	c7 85 bc fe ff ff 88 	movl   $0x4d88,-0x144(%ebp)
    2674:	4d 00 00 
    2677:	8d 85 7c ff ff ff    	lea    -0x84(%ebp),%eax
    267d:	89 85 c0 fe ff ff    	mov    %eax,-0x140(%ebp)
    2683:	c7 85 c4 fe ff ff 01 	movl   $0x1,-0x13c(%ebp)
    268a:	00 00 00 
    268d:	c7 85 c8 fe ff ff ea 	movl   $0x35ea,-0x138(%ebp)
    2694:	35 00 00 
    2697:	c7 85 cc fe ff ff f7 	movl   $0x35f7,-0x134(%ebp)
    269e:	35 00 00 
    26a1:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
    26a7:	89 85 d0 fe ff ff    	mov    %eax,-0x130(%ebp)
    26ad:	c7 85 d4 fe ff ff 01 	movl   $0x1,-0x12c(%ebp)
    26b4:	00 00 00 
    26b7:	c7 85 d8 fe ff ff 09 	movl   $0x3609,-0x128(%ebp)
    26be:	36 00 00 
    26c1:	c7 85 dc fe ff ff bc 	movl   $0x4dbc,-0x124(%ebp)
    26c8:	4d 00 00 
    26cb:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
    26d1:	89 85 e0 fe ff ff    	mov    %eax,-0x120(%ebp)
    26d7:	c7 85 e4 fe ff ff 01 	movl   $0x1,-0x11c(%ebp)
    26de:	00 00 00 
    26e1:	c7 85 e8 fe ff ff 18 	movl   $0x3618,-0x118(%ebp)
    26e8:	36 00 00 
    26eb:	c7 85 ec fe ff ff f4 	movl   $0x4df4,-0x114(%ebp)
    26f2:	4d 00 00 
    26f5:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
    26fb:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
    2701:	c7 85 f8 fe ff ff 2b 	movl   $0x362b,-0x108(%ebp)
    2708:	36 00 00 
    270b:	c7 85 fc fe ff ff 50 	movl   $0x4e50,-0x104(%ebp)
    2712:	4e 00 00 
    2715:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
    271b:	89 85 00 ff ff ff    	mov    %eax,-0x100(%ebp)
    2721:	c7 85 08 ff ff ff 3c 	movl   $0x363c,-0xf8(%ebp)
    2728:	36 00 00 
    272b:	c7 85 0c ff ff ff 9c 	movl   $0x4e9c,-0xf4(%ebp)
    2732:	4e 00 00 
    2735:	8d 45 e4             	lea    -0x1c(%ebp),%eax
    2738:	89 85 10 ff ff ff    	mov    %eax,-0xf0(%ebp)
    273e:	c7 85 14 ff ff ff 01 	movl   $0x1,-0xec(%ebp)
    2745:	00 00 00 
    2748:	c7 85 18 ff ff ff 18 	movl   $0x3918,-0xe8(%ebp)
    274f:	39 00 00 
    2752:	c7 85 1c ff ff ff e0 	movl   $0x4ee0,-0xe4(%ebp)
    2759:	4e 00 00 
    275c:	8d 45 ec             	lea    -0x14(%ebp),%eax
    275f:	89 85 20 ff ff ff    	mov    %eax,-0xe0(%ebp)
    2765:	c7 85 24 ff ff ff 01 	movl   $0x1,-0xdc(%ebp)
    276c:	00 00 00 
    276f:	c7 85 28 ff ff ff 07 	movl   $0x3907,-0xd8(%ebp)
    2776:	39 00 00 
    2779:	c7 85 2c ff ff ff 64 	movl   $0x4f64,-0xd4(%ebp)
    2780:	4f 00 00 
    2783:	8d 45 e8             	lea    -0x18(%ebp),%eax
    2786:	89 85 30 ff ff ff    	mov    %eax,-0xd0(%ebp)
    278c:	c7 85 34 ff ff ff 01 	movl   $0x1,-0xcc(%ebp)
    2793:	00 00 00 
    2796:	c7 85 38 ff ff ff 4f 	movl   $0x364f,-0xc8(%ebp)
    279d:	36 00 00 
    27a0:	c7 85 3c ff ff ff c4 	movl   $0x4fc4,-0xc4(%ebp)
    27a7:	4f 00 00 
    27aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
    27ad:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
    27b3:	c7 85 44 ff ff ff 01 	movl   $0x1,-0xbc(%ebp)
    27ba:	00 00 00 
    27bd:	c7 85 48 ff ff ff 54 	movl   $0x3654,-0xb8(%ebp)
    27c4:	36 00 00 
    27c7:	c7 85 4c ff ff ff f8 	movl   $0x4ff8,-0xb4(%ebp)
    27ce:	4f 00 00 
    27d1:	8d 45 84             	lea    -0x7c(%ebp),%eax
    27d4:	89 85 50 ff ff ff    	mov    %eax,-0xb0(%ebp)
    27da:	c7 85 54 ff ff ff 01 	movl   $0x1,-0xac(%ebp)
    27e1:	00 00 00 
            .description = "run entire test in a child process",
            .boolean = 1,
        },
        {   .name = (char*) 0  },
    };
    getopt(argc, argv, options);
    27e4:	8d 8d 58 fe ff ff    	lea    -0x1a8(%ebp),%ecx
    27ea:	8b 55 0c             	mov    0xc(%ebp),%edx
    27ed:	8b 45 08             	mov    0x8(%ebp),%eax
    27f0:	e8 d8 fb ff ff       	call   23cd <getopt>
    if (parent_first + parent_middle + parent_last + parent_never > 1) {
    27f5:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
    27fb:	03 45 80             	add    -0x80(%ebp),%eax
    27fe:	03 85 78 ff ff ff    	add    -0x88(%ebp),%eax
    2804:	03 85 74 ff ff ff    	add    -0x8c(%ebp),%eax
    280a:	83 f8 01             	cmp    $0x1,%eax
    280d:	7f 3e                	jg     284d <run_cow_test_from_args+0x346>
        printf(2, "ERROR: specify at most one of -parent-first, parent-last, -parent-middle, -parent-never\n");
    }
    if (parent_first) {
    280f:	83 7d 80 00          	cmpl   $0x0,-0x80(%ebp)
    2813:	74 4c                	je     2861 <run_cow_test_from_args+0x35a>
        info.parent_write_index = -1;
    2815:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
    } else if (parent_last) {
        info.parent_write_index = info.num_forks - 1;
    } else if (parent_never) {
        info.parent_write[0] = 0;
    }
    if (no_child_write) {
    281c:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
    2822:	85 c0                	test   %eax,%eax
    2824:	0f 85 93 00 00 00    	jne    28bd <run_cow_test_from_args+0x3b6>
        for (int i = 0; i < info.num_forks; i += 1) {
            info.child_write[0][i] = 0;
        }
    } else if (child_write_only != -1) {
    282a:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
    2830:	83 fa ff             	cmp    $0xffffffff,%edx
    2833:	0f 85 93 00 00 00    	jne    28cc <run_cow_test_from_args+0x3c5>
                info.child_write[0][i] = 1;
            } else {
                info.child_write[0][i] = 0;
            }
        }
    } else if (child_write_except != -1) {
    2839:	8b 95 6c ff ff ff    	mov    -0x94(%ebp),%edx
    283f:	83 fa ff             	cmp    $0xffffffff,%edx
    2842:	0f 85 9c 00 00 00    	jne    28e4 <run_cow_test_from_args+0x3dd>
    2848:	e9 af 00 00 00       	jmp    28fc <run_cow_test_from_args+0x3f5>
        printf(2, "ERROR: specify at most one of -parent-first, parent-last, -parent-middle, -parent-never\n");
    284d:	83 ec 08             	sub    $0x8,%esp
    2850:	68 1c 50 00 00       	push   $0x501c
    2855:	6a 02                	push   $0x2
    2857:	e8 07 09 00 00       	call   3163 <printf>
    285c:	83 c4 10             	add    $0x10,%esp
    285f:	eb ae                	jmp    280f <run_cow_test_from_args+0x308>
    } else if (parent_middle) {
    2861:	83 bd 7c ff ff ff 00 	cmpl   $0x0,-0x84(%ebp)
    2868:	74 09                	je     2873 <run_cow_test_from_args+0x36c>
        info.parent_write_index = 0;
    286a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
    2871:	eb a9                	jmp    281c <run_cow_test_from_args+0x315>
    } else if (parent_last) {
    2873:	83 bd 78 ff ff ff 00 	cmpl   $0x0,-0x88(%ebp)
    287a:	74 0b                	je     2887 <run_cow_test_from_args+0x380>
        info.parent_write_index = info.num_forks - 1;
    287c:	8b 45 c8             	mov    -0x38(%ebp),%eax
    287f:	83 e8 01             	sub    $0x1,%eax
    2882:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    2885:	eb 95                	jmp    281c <run_cow_test_from_args+0x315>
    } else if (parent_never) {
    2887:	83 bd 74 ff ff ff 00 	cmpl   $0x0,-0x8c(%ebp)
    288e:	74 8c                	je     281c <run_cow_test_from_args+0x315>
        info.parent_write[0] = 0;
    2890:	c6 45 d0 00          	movb   $0x0,-0x30(%ebp)
    2894:	eb 86                	jmp    281c <run_cow_test_from_args+0x315>
            info.child_write[0][i] = 0;
    2896:	c6 44 05 d8 00       	movb   $0x0,-0x28(%ebp,%eax,1)
        for (int i = 0; i < info.num_forks; i += 1) {
    289b:	83 c0 01             	add    $0x1,%eax
    289e:	39 45 c8             	cmp    %eax,-0x38(%ebp)
    28a1:	7f f3                	jg     2896 <run_cow_test_from_args+0x38f>
    } else {
        for (int i = 0; i < info.num_forks; i += 1) {
            info.child_write[0][i] = 1;
        }
    }
    if (pre_fork_p) {
    28a3:	83 7d 84 00          	cmpl   $0x0,-0x7c(%ebp)
    28a7:	74 5a                	je     2903 <run_cow_test_from_args+0x3fc>
        info.pre_fork_p = 1;
    28a9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        return test_cow_in_child(&info);
    28b0:	8d 45 88             	lea    -0x78(%ebp),%eax
    28b3:	e8 4a f5 ff ff       	call   1e02 <test_cow_in_child>
    } else {
        return test_cow(&info);
    }
}
    28b8:	8b 7d fc             	mov    -0x4(%ebp),%edi
    28bb:	c9                   	leave  
    28bc:	c3                   	ret    
        for (int i = 0; i < info.num_forks; i += 1) {
    28bd:	b8 00 00 00 00       	mov    $0x0,%eax
    28c2:	eb da                	jmp    289e <run_cow_test_from_args+0x397>
                info.child_write[0][i] = 1;
    28c4:	c6 44 05 d8 01       	movb   $0x1,-0x28(%ebp,%eax,1)
        for (int i = 0; i < info.num_forks; i += 1) {
    28c9:	83 c0 01             	add    $0x1,%eax
    28cc:	39 45 c8             	cmp    %eax,-0x38(%ebp)
    28cf:	7e d2                	jle    28a3 <run_cow_test_from_args+0x39c>
            if (i == child_write_only) {
    28d1:	39 c2                	cmp    %eax,%edx
    28d3:	74 ef                	je     28c4 <run_cow_test_from_args+0x3bd>
                info.child_write[0][i] = 0;
    28d5:	c6 44 05 d8 00       	movb   $0x0,-0x28(%ebp,%eax,1)
    28da:	eb ed                	jmp    28c9 <run_cow_test_from_args+0x3c2>
                info.child_write[0][i] = 0;
    28dc:	c6 44 05 d8 00       	movb   $0x0,-0x28(%ebp,%eax,1)
        for (int i = 0; i < info.num_forks; i += 1) {
    28e1:	83 c0 01             	add    $0x1,%eax
    28e4:	39 45 c8             	cmp    %eax,-0x38(%ebp)
    28e7:	7e ba                	jle    28a3 <run_cow_test_from_args+0x39c>
            if (i != child_write_except) {
    28e9:	39 c2                	cmp    %eax,%edx
    28eb:	74 ef                	je     28dc <run_cow_test_from_args+0x3d5>
                info.child_write[0][i] = 1;
    28ed:	c6 44 05 d8 01       	movb   $0x1,-0x28(%ebp,%eax,1)
    28f2:	eb ed                	jmp    28e1 <run_cow_test_from_args+0x3da>
            info.child_write[0][i] = 1;
    28f4:	c6 44 05 d8 01       	movb   $0x1,-0x28(%ebp,%eax,1)
        for (int i = 0; i < info.num_forks; i += 1) {
    28f9:	83 c0 01             	add    $0x1,%eax
    28fc:	39 45 c8             	cmp    %eax,-0x38(%ebp)
    28ff:	7f f3                	jg     28f4 <run_cow_test_from_args+0x3ed>
    2901:	eb a0                	jmp    28a3 <run_cow_test_from_args+0x39c>
        return test_cow(&info);
    2903:	8d 45 88             	lea    -0x78(%ebp),%eax
    2906:	e8 d4 f3 ff ff       	call   1cdf <test_cow>
    290b:	eb ab                	jmp    28b8 <run_cow_test_from_args+0x3b1>

0000290d <run_alloc_test_from_args>:

MAYBE_UNUSED
int run_alloc_test_from_args(int argc, char **argv) {
    290d:	55                   	push   %ebp
    290e:	89 e5                	mov    %esp,%ebp
    2910:	57                   	push   %edi
    2911:	81 ec 04 01 00 00    	sub    $0x104,%esp
    struct alloc_test_info info = {
    2917:	8d 7d c0             	lea    -0x40(%ebp),%edi
    291a:	b8 00 00 00 00       	mov    $0x0,%eax
    291f:	b9 0e 00 00 00       	mov    $0xe,%ecx
    2924:	f3 ab                	rep stos %eax,%es:(%edi)
    2926:	c7 45 d0 00 10 00 00 	movl   $0x1000,-0x30(%ebp)
    292d:	c7 45 d4 00 02 00 00 	movl   $0x200,-0x2c(%ebp)
    2934:	c7 45 d8 00 03 00 00 	movl   $0x300,-0x28(%ebp)
    293b:	c7 45 dc 80 00 00 00 	movl   $0x80,-0x24(%ebp)
    2942:	c7 45 e0 00 01 00 00 	movl   $0x100,-0x20(%ebp)
        .use_sys_read = 0,
        .fork_after_alloc = 0,
        .dump = 0,
        .skip_free_check = 0,
    };
    int fork_p = 0;
    2949:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%ebp)
    struct option options[] = {
    2950:	8d bd fc fe ff ff    	lea    -0x104(%ebp),%edi
    2956:	b9 30 00 00 00       	mov    $0x30,%ecx
    295b:	f3 ab                	rep stos %eax,%es:(%edi)
    295d:	c7 85 fc fe ff ff 58 	movl   $0x3658,-0x104(%ebp)
    2964:	36 00 00 
    2967:	c7 85 00 ff ff ff 78 	movl   $0x5078,-0x100(%ebp)
    296e:	50 00 00 
    2971:	8d 45 bc             	lea    -0x44(%ebp),%eax
    2974:	89 85 04 ff ff ff    	mov    %eax,-0xfc(%ebp)
    297a:	c7 85 08 ff ff ff 01 	movl   $0x1,-0xf8(%ebp)
    2981:	00 00 00 
    2984:	c7 85 0c ff ff ff a7 	movl   $0x35a7,-0xf4(%ebp)
    298b:	35 00 00 
    298e:	c7 85 10 ff ff ff 5d 	movl   $0x365d,-0xf0(%ebp)
    2995:	36 00 00 
    2998:	8d 7d c0             	lea    -0x40(%ebp),%edi
    299b:	8d 45 d0             	lea    -0x30(%ebp),%eax
    299e:	89 85 14 ff ff ff    	mov    %eax,-0xec(%ebp)
    29a4:	c7 85 1c ff ff ff 6e 	movl   $0x366e,-0xe4(%ebp)
    29ab:	36 00 00 
    29ae:	c7 85 20 ff ff ff c0 	movl   $0x50c0,-0xe0(%ebp)
    29b5:	50 00 00 
    29b8:	8d 45 dc             	lea    -0x24(%ebp),%eax
    29bb:	89 85 24 ff ff ff    	mov    %eax,-0xdc(%ebp)
    29c1:	c7 85 2c ff ff ff 79 	movl   $0x3679,-0xd4(%ebp)
    29c8:	36 00 00 
    29cb:	c7 85 30 ff ff ff ec 	movl   $0x50ec,-0xd0(%ebp)
    29d2:	50 00 00 
    29d5:	8d 45 e0             	lea    -0x20(%ebp),%eax
    29d8:	89 85 34 ff ff ff    	mov    %eax,-0xcc(%ebp)
    29de:	c7 85 3c ff ff ff 82 	movl   $0x3682,-0xc4(%ebp)
    29e5:	36 00 00 
    29e8:	c7 85 40 ff ff ff 18 	movl   $0x5118,-0xc0(%ebp)
    29ef:	51 00 00 
    29f2:	8d 45 d4             	lea    -0x2c(%ebp),%eax
    29f5:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
    29fb:	c7 85 4c ff ff ff 8e 	movl   $0x368e,-0xb4(%ebp)
    2a02:	36 00 00 
    2a05:	c7 85 50 ff ff ff 44 	movl   $0x5144,-0xb0(%ebp)
    2a0c:	51 00 00 
    2a0f:	8d 45 d8             	lea    -0x28(%ebp),%eax
    2a12:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
    2a18:	c7 85 5c ff ff ff 38 	movl   $0x3938,-0xa4(%ebp)
    2a1f:	39 00 00 
    2a22:	c7 85 60 ff ff ff 70 	movl   $0x5170,-0xa0(%ebp)
    2a29:	51 00 00 
    2a2c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
    2a2f:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
    2a35:	c7 85 68 ff ff ff 01 	movl   $0x1,-0x98(%ebp)
    2a3c:	00 00 00 
    2a3f:	c7 85 6c ff ff ff bd 	movl   $0x37bd,-0x94(%ebp)
    2a46:	37 00 00 
    2a49:	c7 85 70 ff ff ff a8 	movl   $0x51a8,-0x90(%ebp)
    2a50:	51 00 00 
    2a53:	8d 45 e8             	lea    -0x18(%ebp),%eax
    2a56:	89 85 74 ff ff ff    	mov    %eax,-0x8c(%ebp)
    2a5c:	c7 85 78 ff ff ff 01 	movl   $0x1,-0x88(%ebp)
    2a63:	00 00 00 
    2a66:	c7 85 7c ff ff ff 18 	movl   $0x3918,-0x84(%ebp)
    2a6d:	39 00 00 
    2a70:	c7 45 80 e0 4e 00 00 	movl   $0x4ee0,-0x80(%ebp)
    2a77:	8d 45 f4             	lea    -0xc(%ebp),%eax
    2a7a:	89 45 84             	mov    %eax,-0x7c(%ebp)
    2a7d:	c7 45 88 01 00 00 00 	movl   $0x1,-0x78(%ebp)
    2a84:	c7 45 8c 07 39 00 00 	movl   $0x3907,-0x74(%ebp)
    2a8b:	c7 45 90 64 4f 00 00 	movl   $0x4f64,-0x70(%ebp)
    2a92:	8d 45 f0             	lea    -0x10(%ebp),%eax
    2a95:	89 45 94             	mov    %eax,-0x6c(%ebp)
    2a98:	c7 45 98 01 00 00 00 	movl   $0x1,-0x68(%ebp)
    2a9f:	c7 45 9c 4f 36 00 00 	movl   $0x364f,-0x64(%ebp)
    2aa6:	c7 45 a0 08 52 00 00 	movl   $0x5208,-0x60(%ebp)
    2aad:	8d 45 ec             	lea    -0x14(%ebp),%eax
    2ab0:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    2ab3:	c7 45 a8 01 00 00 00 	movl   $0x1,-0x58(%ebp)
        },
        {
            .name = (char*) 0,
        },
    };
    getopt(argc, argv, options);
    2aba:	8d 8d fc fe ff ff    	lea    -0x104(%ebp),%ecx
    2ac0:	8b 55 0c             	mov    0xc(%ebp),%edx
    2ac3:	8b 45 08             	mov    0x8(%ebp),%eax
    2ac6:	e8 02 f9 ff ff       	call   23cd <getopt>
    return test_allocation(fork_p, &info);
    2acb:	83 ec 08             	sub    $0x8,%esp
    2ace:	57                   	push   %edi
    2acf:	ff 75 bc             	push   -0x44(%ebp)
    2ad2:	e8 1d f5 ff ff       	call   1ff4 <test_allocation>
}
    2ad7:	8b 7d fc             	mov    -0x4(%ebp),%edi
    2ada:	c9                   	leave  
    2adb:	c3                   	ret    

00002adc <run_oob_from_args>:

MAYBE_UNUSED
int run_oob_from_args(int argc, char **argv) {
    2adc:	55                   	push   %ebp
    2add:	89 e5                	mov    %esp,%ebp
    2adf:	57                   	push   %edi
    2ae0:	83 ec 64             	sub    $0x64,%esp
    int no_fork_p = 0;
    2ae3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    int guard_p = 0;
    2aea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    int write_p = 0;
    2af1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    int heap_offset = 0x1000;
    2af8:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
    struct option options[] = {
    2aff:	8d 7d 98             	lea    -0x68(%ebp),%edi
    2b02:	b9 14 00 00 00       	mov    $0x14,%ecx
    2b07:	b8 00 00 00 00       	mov    $0x0,%eax
    2b0c:	f3 ab                	rep stos %eax,%es:(%edi)
    2b0e:	c7 45 98 98 36 00 00 	movl   $0x3698,-0x68(%ebp)
    2b15:	c7 45 9c 38 52 00 00 	movl   $0x5238,-0x64(%ebp)
    2b1c:	8d 45 e8             	lea    -0x18(%ebp),%eax
    2b1f:	89 45 a0             	mov    %eax,-0x60(%ebp)
    2b22:	c7 45 a8 03 36 00 00 	movl   $0x3603,-0x58(%ebp)
    2b29:	c7 45 ac 6c 52 00 00 	movl   $0x526c,-0x54(%ebp)
    2b30:	8d 45 ec             	lea    -0x14(%ebp),%eax
    2b33:	89 45 b0             	mov    %eax,-0x50(%ebp)
    2b36:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
    2b3d:	c7 45 b8 4d 37 00 00 	movl   $0x374d,-0x48(%ebp)
    2b44:	c7 45 bc 9c 52 00 00 	movl   $0x529c,-0x44(%ebp)
    2b4b:	8d 45 f0             	lea    -0x10(%ebp),%eax
    2b4e:	89 45 c0             	mov    %eax,-0x40(%ebp)
    2b51:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
    2b58:	c7 45 c8 9f 36 00 00 	movl   $0x369f,-0x38(%ebp)
    2b5f:	c7 45 cc e0 52 00 00 	movl   $0x52e0,-0x34(%ebp)
    2b66:	8d 45 f4             	lea    -0xc(%ebp),%eax
    2b69:	89 45 d0             	mov    %eax,-0x30(%ebp)
    2b6c:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
        },
        {
            .name = (char*) 0,
        }
    };
    getopt(argc, argv, options);
    2b73:	8d 4d 98             	lea    -0x68(%ebp),%ecx
    2b76:	8b 55 0c             	mov    0xc(%ebp),%edx
    2b79:	8b 45 08             	mov    0x8(%ebp),%eax
    2b7c:	e8 4c f8 ff ff       	call   23cd <getopt>
    int fork_p = !no_fork_p;
    2b81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2b85:	0f 94 c2             	sete   %dl
    2b88:	0f b6 d2             	movzbl %dl,%edx
    return test_oob(heap_offset, fork_p, write_p, guard_p);
    2b8b:	83 ec 0c             	sub    $0xc,%esp
    2b8e:	ff 75 f0             	push   -0x10(%ebp)
    2b91:	8b 4d ec             	mov    -0x14(%ebp),%ecx
    2b94:	8b 45 e8             	mov    -0x18(%ebp),%eax
    2b97:	e8 72 dc ff ff       	call   80e <test_oob>
}
    2b9c:	8b 7d fc             	mov    -0x4(%ebp),%edi
    2b9f:	c9                   	leave  
    2ba0:	c3                   	ret    

00002ba1 <run_test_from_args>:

MAYBE_UNUSED
int run_test_from_args(int argc, char **argv) {
    2ba1:	55                   	push   %ebp
    2ba2:	89 e5                	mov    %esp,%ebp
    2ba4:	56                   	push   %esi
    2ba5:	53                   	push   %ebx
    2ba6:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (0 == strcmp(argv[0], "cow")) {
    2ba9:	83 ec 08             	sub    $0x8,%esp
    2bac:	68 a7 36 00 00       	push   $0x36a7
    2bb1:	ff 36                	push   (%esi)
    2bb3:	e8 c5 02 00 00       	call   2e7d <strcmp>
    2bb8:	83 c4 10             	add    $0x10,%esp
    2bbb:	85 c0                	test   %eax,%eax
    2bbd:	74 56                	je     2c15 <run_test_from_args+0x74>
        return run_cow_test_from_args(argc, argv);
    } else if (0 == strcmp(argv[0], "alloc")) {
    2bbf:	83 ec 08             	sub    $0x8,%esp
    2bc2:	68 c8 37 00 00       	push   $0x37c8
    2bc7:	ff 36                	push   (%esi)
    2bc9:	e8 af 02 00 00       	call   2e7d <strcmp>
    2bce:	83 c4 10             	add    $0x10,%esp
    2bd1:	85 c0                	test   %eax,%eax
    2bd3:	74 5a                	je     2c2f <run_test_from_args+0x8e>
        return run_alloc_test_from_args(argc, argv);
    } else if (0 == strcmp(argv[0], "exec")) {
    2bd5:	83 ec 08             	sub    $0x8,%esp
    2bd8:	68 ab 36 00 00       	push   $0x36ab
    2bdd:	ff 36                	push   (%esi)
    2bdf:	e8 99 02 00 00       	call   2e7d <strcmp>
    2be4:	83 c4 10             	add    $0x10,%esp
    2be7:	85 c0                	test   %eax,%eax
    2be9:	75 6b                	jne    2c56 <run_test_from_args+0xb5>
        if (argc > 1 && 0 == strcmp(argv[1], "-help")) {
    2beb:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
    2bef:	7e 19                	jle    2c0a <run_test_from_args+0x69>
    2bf1:	83 ec 08             	sub    $0x8,%esp
    2bf4:	68 b0 36 00 00       	push   $0x36b0
    2bf9:	ff 76 04             	push   0x4(%esi)
    2bfc:	e8 7c 02 00 00       	call   2e7d <strcmp>
    2c01:	89 c3                	mov    %eax,%ebx
    2c03:	83 c4 10             	add    $0x10,%esp
    2c06:	85 c0                	test   %eax,%eax
    2c08:	74 38                	je     2c42 <run_test_from_args+0xa1>
            printf(2, "The exec test type takes no options.\n");
            return TR_SUCCESS;
        } else {
            return _test_exec(argv[0]);
    2c0a:	8b 06                	mov    (%esi),%eax
    2c0c:	e8 5a e1 ff ff       	call   d6b <_test_exec>
    2c11:	89 c3                	mov    %eax,%ebx
    2c13:	eb 11                	jmp    2c26 <run_test_from_args+0x85>
        return run_cow_test_from_args(argc, argv);
    2c15:	83 ec 08             	sub    $0x8,%esp
    2c18:	56                   	push   %esi
    2c19:	ff 75 08             	push   0x8(%ebp)
    2c1c:	e8 e6 f8 ff ff       	call   2507 <run_cow_test_from_args>
    2c21:	89 c3                	mov    %eax,%ebx
    2c23:	83 c4 10             	add    $0x10,%esp
                  "    use OPTIONS of '-help' for a list\n"
                  "    of a test type's options\n"
                );
        return -1;
    }
}
    2c26:	89 d8                	mov    %ebx,%eax
    2c28:	8d 65 f8             	lea    -0x8(%ebp),%esp
    2c2b:	5b                   	pop    %ebx
    2c2c:	5e                   	pop    %esi
    2c2d:	5d                   	pop    %ebp
    2c2e:	c3                   	ret    
        return run_alloc_test_from_args(argc, argv);
    2c2f:	83 ec 08             	sub    $0x8,%esp
    2c32:	56                   	push   %esi
    2c33:	ff 75 08             	push   0x8(%ebp)
    2c36:	e8 d2 fc ff ff       	call   290d <run_alloc_test_from_args>
    2c3b:	89 c3                	mov    %eax,%ebx
    2c3d:	83 c4 10             	add    $0x10,%esp
    2c40:	eb e4                	jmp    2c26 <run_test_from_args+0x85>
            printf(2, "The exec test type takes no options.\n");
    2c42:	83 ec 08             	sub    $0x8,%esp
    2c45:	68 2c 53 00 00       	push   $0x532c
    2c4a:	6a 02                	push   $0x2
    2c4c:	e8 12 05 00 00       	call   3163 <printf>
            return TR_SUCCESS;
    2c51:	83 c4 10             	add    $0x10,%esp
    2c54:	eb d0                	jmp    2c26 <run_test_from_args+0x85>
    } else if (0 == strcmp(argv[0], "oob")) {
    2c56:	83 ec 08             	sub    $0x8,%esp
    2c59:	68 b6 36 00 00       	push   $0x36b6
    2c5e:	ff 36                	push   (%esi)
    2c60:	e8 18 02 00 00       	call   2e7d <strcmp>
    2c65:	83 c4 10             	add    $0x10,%esp
    2c68:	85 c0                	test   %eax,%eax
    2c6a:	75 13                	jne    2c7f <run_test_from_args+0xde>
        return run_oob_from_args(argc, argv);
    2c6c:	83 ec 08             	sub    $0x8,%esp
    2c6f:	56                   	push   %esi
    2c70:	ff 75 08             	push   0x8(%ebp)
    2c73:	e8 64 fe ff ff       	call   2adc <run_oob_from_args>
    2c78:	89 c3                	mov    %eax,%ebx
    2c7a:	83 c4 10             	add    $0x10,%esp
    2c7d:	eb a7                	jmp    2c26 <run_test_from_args+0x85>
            real_argv0 ? "" : real_argv0);
    2c7f:	a1 80 79 00 00       	mov    0x7980,%eax
        printf(2, "Usage: %s TEST-TYPE OPTIONS\n",
    2c84:	85 c0                	test   %eax,%eax
    2c86:	74 05                	je     2c8d <run_test_from_args+0xec>
    2c88:	b8 50 33 00 00       	mov    $0x3350,%eax
    2c8d:	83 ec 04             	sub    $0x4,%esp
    2c90:	50                   	push   %eax
    2c91:	68 ba 36 00 00       	push   $0x36ba
    2c96:	6a 02                	push   $0x2
    2c98:	e8 c6 04 00 00       	call   3163 <printf>
        printf(2, "  TEST-TYPE is one of:\n"
    2c9d:	83 c4 08             	add    $0x8,%esp
    2ca0:	68 54 53 00 00       	push   $0x5354
    2ca5:	6a 02                	push   $0x2
    2ca7:	e8 b7 04 00 00       	call   3163 <printf>
        return -1;
    2cac:	83 c4 10             	add    $0x10,%esp
    2caf:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
    2cb4:	e9 6d ff ff ff       	jmp    2c26 <run_test_from_args+0x85>

00002cb9 <list_tests>:
    {
        (char*) 0,
    }
};

void list_tests() {
    2cb9:	55                   	push   %ebp
    2cba:	89 e5                	mov    %esp,%ebp
    2cbc:	57                   	push   %edi
    2cbd:	56                   	push   %esi
    2cbe:	53                   	push   %ebx
    2cbf:	83 ec 0c             	sub    $0xc,%esp
    for (int i = 0; tests[i][0]; i += 1) {
    2cc2:	bf 00 00 00 00       	mov    $0x0,%edi
    2cc7:	eb 32                	jmp    2cfb <list_tests+0x42>
        char **cur_test = tests[i];
        int cur_test_argc = 0;
        printf(1, "pp_test ");
        while (cur_test[cur_test_argc]) {
            printf(1, "%s ",cur_test[cur_test_argc]);
    2cc9:	83 ec 04             	sub    $0x4,%esp
    2ccc:	50                   	push   %eax
    2ccd:	68 e0 36 00 00       	push   $0x36e0
    2cd2:	6a 01                	push   $0x1
    2cd4:	e8 8a 04 00 00       	call   3163 <printf>
            cur_test_argc += 1;
    2cd9:	83 c3 01             	add    $0x1,%ebx
    2cdc:	83 c4 10             	add    $0x10,%esp
        while (cur_test[cur_test_argc]) {
    2cdf:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
    2ce2:	85 c0                	test   %eax,%eax
    2ce4:	75 e3                	jne    2cc9 <list_tests+0x10>
        }
        printf(1, "\n");
    2ce6:	83 ec 08             	sub    $0x8,%esp
    2ce9:	68 4f 33 00 00       	push   $0x334f
    2cee:	6a 01                	push   $0x1
    2cf0:	e8 6e 04 00 00       	call   3163 <printf>
    for (int i = 0; tests[i][0]; i += 1) {
    2cf5:	83 c7 01             	add    $0x1,%edi
    2cf8:	83 c4 10             	add    $0x10,%esp
    2cfb:	6b c7 2c             	imul   $0x2c,%edi,%eax
    2cfe:	83 b8 c0 55 00 00 00 	cmpl   $0x0,0x55c0(%eax)
    2d05:	74 22                	je     2d29 <list_tests+0x70>
        char **cur_test = tests[i];
    2d07:	6b f7 2c             	imul   $0x2c,%edi,%esi
    2d0a:	81 c6 c0 55 00 00    	add    $0x55c0,%esi
        printf(1, "pp_test ");
    2d10:	83 ec 08             	sub    $0x8,%esp
    2d13:	68 d7 36 00 00       	push   $0x36d7
    2d18:	6a 01                	push   $0x1
    2d1a:	e8 44 04 00 00       	call   3163 <printf>
        while (cur_test[cur_test_argc]) {
    2d1f:	83 c4 10             	add    $0x10,%esp
        int cur_test_argc = 0;
    2d22:	bb 00 00 00 00       	mov    $0x0,%ebx
        while (cur_test[cur_test_argc]) {
    2d27:	eb b6                	jmp    2cdf <list_tests+0x26>
    }
}
    2d29:	8d 65 f4             	lea    -0xc(%ebp),%esp
    2d2c:	5b                   	pop    %ebx
    2d2d:	5e                   	pop    %esi
    2d2e:	5f                   	pop    %edi
    2d2f:	5d                   	pop    %ebp
    2d30:	c3                   	ret    

00002d31 <main>:

int
main(int argc, char **argv)
{
    2d31:	8d 4c 24 04          	lea    0x4(%esp),%ecx
    2d35:	83 e4 f0             	and    $0xfffffff0,%esp
    2d38:	ff 71 fc             	push   -0x4(%ecx)
    2d3b:	55                   	push   %ebp
    2d3c:	89 e5                	mov    %esp,%ebp
    2d3e:	56                   	push   %esi
    2d3f:	53                   	push   %ebx
    2d40:	51                   	push   %ecx
    2d41:	83 ec 0c             	sub    $0xc,%esp
    2d44:	89 cb                	mov    %ecx,%ebx
    if (argc > 1 && 0 == strcmp(argv[1], "-list")) {
    2d46:	83 39 01             	cmpl   $0x1,(%ecx)
    2d49:	7f 45                	jg     2d90 <main+0x5f>
        list_tests();
        exit();
    } else if (argc > 1 && 0 == strcmp(argv[1], "-help")) {
    2d4b:	83 3b 01             	cmpl   $0x1,(%ebx)
    2d4e:	7e 1a                	jle    2d6a <main+0x39>
    2d50:	8b 43 04             	mov    0x4(%ebx),%eax
    2d53:	83 ec 08             	sub    $0x8,%esp
    2d56:	68 b0 36 00 00       	push   $0x36b0
    2d5b:	ff 70 04             	push   0x4(%eax)
    2d5e:	e8 1a 01 00 00       	call   2e7d <strcmp>
    2d63:	83 c4 10             	add    $0x10,%esp
    2d66:	85 c0                	test   %eax,%eax
    2d68:	74 4a                	je     2db4 <main+0x83>
                  "    List tests in test suite.\n"
                  "  %s -help\n"
                  "    This message.\n");
        exit();
    }
    want_args = 0;
    2d6a:	c7 05 38 58 00 00 00 	movl   $0x0,0x5838
    2d71:	00 00 00 
    setup(&argc, &argv);
    2d74:	83 ec 08             	sub    $0x8,%esp
    2d77:	8d 43 04             	lea    0x4(%ebx),%eax
    2d7a:	50                   	push   %eax
    2d7b:	53                   	push   %ebx
    2d7c:	e8 f4 f4 ff ff       	call   2275 <setup>
    int passed = 0, failed = 0;
    for (int i = 0; tests[i][0]; i += 1) {
    2d81:	83 c4 10             	add    $0x10,%esp
    2d84:	bb 00 00 00 00       	mov    $0x0,%ebx
    int passed = 0, failed = 0;
    2d89:	be 00 00 00 00       	mov    $0x0,%esi
    for (int i = 0; tests[i][0]; i += 1) {
    2d8e:	eb 55                	jmp    2de5 <main+0xb4>
    if (argc > 1 && 0 == strcmp(argv[1], "-list")) {
    2d90:	8b 41 04             	mov    0x4(%ecx),%eax
    2d93:	83 ec 08             	sub    $0x8,%esp
    2d96:	68 e4 36 00 00       	push   $0x36e4
    2d9b:	ff 70 04             	push   0x4(%eax)
    2d9e:	e8 da 00 00 00       	call   2e7d <strcmp>
    2da3:	83 c4 10             	add    $0x10,%esp
    2da6:	85 c0                	test   %eax,%eax
    2da8:	75 a1                	jne    2d4b <main+0x1a>
        list_tests();
    2daa:	e8 0a ff ff ff       	call   2cb9 <list_tests>
        exit();
    2daf:	e8 42 02 00 00       	call   2ff6 <exit>
        printf(2, "Usage:\n"
    2db4:	83 ec 08             	sub    $0x8,%esp
    2db7:	68 cc 54 00 00       	push   $0x54cc
    2dbc:	6a 02                	push   $0x2
    2dbe:	e8 a0 03 00 00       	call   3163 <printf>
        exit();
    2dc3:	e8 2e 02 00 00       	call   2ff6 <exit>
        char **cur_test = tests[i];
        int cur_test_argc = 0;
        while (cur_test[cur_test_argc]) cur_test_argc += 1;
    2dc8:	83 c0 01             	add    $0x1,%eax
    2dcb:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
    2dcf:	75 f7                	jne    2dc8 <main+0x97>
        if (run_test_from_args(cur_test_argc, cur_test) == TR_SUCCESS) {
    2dd1:	83 ec 08             	sub    $0x8,%esp
    2dd4:	52                   	push   %edx
    2dd5:	50                   	push   %eax
    2dd6:	e8 c6 fd ff ff       	call   2ba1 <run_test_from_args>
    2ddb:	83 c4 10             	add    $0x10,%esp
    2dde:	85 c0                	test   %eax,%eax
    2de0:	75 1f                	jne    2e01 <main+0xd0>
    for (int i = 0; tests[i][0]; i += 1) {
    2de2:	83 c3 01             	add    $0x1,%ebx
    2de5:	6b c3 2c             	imul   $0x2c,%ebx,%eax
    2de8:	83 b8 c0 55 00 00 00 	cmpl   $0x0,0x55c0(%eax)
    2def:	74 27                	je     2e18 <main+0xe7>
        char **cur_test = tests[i];
    2df1:	6b d3 2c             	imul   $0x2c,%ebx,%edx
    2df4:	81 c2 c0 55 00 00    	add    $0x55c0,%edx
        int cur_test_argc = 0;
    2dfa:	b8 00 00 00 00       	mov    $0x0,%eax
        while (cur_test[cur_test_argc]) cur_test_argc += 1;
    2dff:	eb ca                	jmp    2dcb <main+0x9a>
            passed += 1;
        } else {
            printf(1, "*** TEST FAILURE ***\n");
    2e01:	83 ec 08             	sub    $0x8,%esp
    2e04:	68 ea 36 00 00       	push   $0x36ea
    2e09:	6a 01                	push   $0x1
    2e0b:	e8 53 03 00 00       	call   3163 <printf>
            failed += 1;
    2e10:	83 c6 01             	add    $0x1,%esi
    2e13:	83 c4 10             	add    $0x10,%esp
    2e16:	eb ca                	jmp    2de2 <main+0xb1>
        }
    }
    if (failed == 0) {
    2e18:	85 f6                	test   %esi,%esi
    2e1a:	75 27                	jne    2e43 <main+0x112>
        printf(1, "All tests passed.\n");
    2e1c:	83 ec 08             	sub    $0x8,%esp
    2e1f:	68 00 37 00 00       	push   $0x3700
    2e24:	6a 01                	push   $0x1
    2e26:	e8 38 03 00 00       	call   3163 <printf>
    2e2b:	83 c4 10             	add    $0x10,%esp
    } else {
        printf(1, "Not all tests passed.\n");
    }
    cleanup();
    2e2e:	e8 7e f5 ff ff       	call   23b1 <cleanup>
}
    2e33:	b8 00 00 00 00       	mov    $0x0,%eax
    2e38:	8d 65 f4             	lea    -0xc(%ebp),%esp
    2e3b:	59                   	pop    %ecx
    2e3c:	5b                   	pop    %ebx
    2e3d:	5e                   	pop    %esi
    2e3e:	5d                   	pop    %ebp
    2e3f:	8d 61 fc             	lea    -0x4(%ecx),%esp
    2e42:	c3                   	ret    
        printf(1, "Not all tests passed.\n");
    2e43:	83 ec 08             	sub    $0x8,%esp
    2e46:	68 13 37 00 00       	push   $0x3713
    2e4b:	6a 01                	push   $0x1
    2e4d:	e8 11 03 00 00       	call   3163 <printf>
    2e52:	83 c4 10             	add    $0x10,%esp
    2e55:	eb d7                	jmp    2e2e <main+0xfd>

00002e57 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
    2e57:	55                   	push   %ebp
    2e58:	89 e5                	mov    %esp,%ebp
    2e5a:	56                   	push   %esi
    2e5b:	53                   	push   %ebx
    2e5c:	8b 75 08             	mov    0x8(%ebp),%esi
    2e5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    2e62:	89 f0                	mov    %esi,%eax
    2e64:	89 d1                	mov    %edx,%ecx
    2e66:	83 c2 01             	add    $0x1,%edx
    2e69:	89 c3                	mov    %eax,%ebx
    2e6b:	83 c0 01             	add    $0x1,%eax
    2e6e:	0f b6 09             	movzbl (%ecx),%ecx
    2e71:	88 0b                	mov    %cl,(%ebx)
    2e73:	84 c9                	test   %cl,%cl
    2e75:	75 ed                	jne    2e64 <strcpy+0xd>
    ;
  return os;
}
    2e77:	89 f0                	mov    %esi,%eax
    2e79:	5b                   	pop    %ebx
    2e7a:	5e                   	pop    %esi
    2e7b:	5d                   	pop    %ebp
    2e7c:	c3                   	ret    

00002e7d <strcmp>:

int
strcmp(const char *p, const char *q)
{
    2e7d:	55                   	push   %ebp
    2e7e:	89 e5                	mov    %esp,%ebp
    2e80:	8b 4d 08             	mov    0x8(%ebp),%ecx
    2e83:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
    2e86:	eb 06                	jmp    2e8e <strcmp+0x11>
    p++, q++;
    2e88:	83 c1 01             	add    $0x1,%ecx
    2e8b:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
    2e8e:	0f b6 01             	movzbl (%ecx),%eax
    2e91:	84 c0                	test   %al,%al
    2e93:	74 04                	je     2e99 <strcmp+0x1c>
    2e95:	3a 02                	cmp    (%edx),%al
    2e97:	74 ef                	je     2e88 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
    2e99:	0f b6 c0             	movzbl %al,%eax
    2e9c:	0f b6 12             	movzbl (%edx),%edx
    2e9f:	29 d0                	sub    %edx,%eax
}
    2ea1:	5d                   	pop    %ebp
    2ea2:	c3                   	ret    

00002ea3 <strlen>:

uint
strlen(const char *s)
{
    2ea3:	55                   	push   %ebp
    2ea4:	89 e5                	mov    %esp,%ebp
    2ea6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
    2ea9:	b8 00 00 00 00       	mov    $0x0,%eax
    2eae:	eb 03                	jmp    2eb3 <strlen+0x10>
    2eb0:	83 c0 01             	add    $0x1,%eax
    2eb3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
    2eb7:	75 f7                	jne    2eb0 <strlen+0xd>
    ;
  return n;
}
    2eb9:	5d                   	pop    %ebp
    2eba:	c3                   	ret    

00002ebb <memset>:

void*
memset(void *dst, int c, uint n)
{
    2ebb:	55                   	push   %ebp
    2ebc:	89 e5                	mov    %esp,%ebp
    2ebe:	57                   	push   %edi
    2ebf:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
    2ec2:	89 d7                	mov    %edx,%edi
    2ec4:	8b 4d 10             	mov    0x10(%ebp),%ecx
    2ec7:	8b 45 0c             	mov    0xc(%ebp),%eax
    2eca:	fc                   	cld    
    2ecb:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
    2ecd:	89 d0                	mov    %edx,%eax
    2ecf:	8b 7d fc             	mov    -0x4(%ebp),%edi
    2ed2:	c9                   	leave  
    2ed3:	c3                   	ret    

00002ed4 <strchr>:

char*
strchr(const char *s, char c)
{
    2ed4:	55                   	push   %ebp
    2ed5:	89 e5                	mov    %esp,%ebp
    2ed7:	8b 45 08             	mov    0x8(%ebp),%eax
    2eda:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
    2ede:	eb 03                	jmp    2ee3 <strchr+0xf>
    2ee0:	83 c0 01             	add    $0x1,%eax
    2ee3:	0f b6 10             	movzbl (%eax),%edx
    2ee6:	84 d2                	test   %dl,%dl
    2ee8:	74 06                	je     2ef0 <strchr+0x1c>
    if(*s == c)
    2eea:	38 ca                	cmp    %cl,%dl
    2eec:	75 f2                	jne    2ee0 <strchr+0xc>
    2eee:	eb 05                	jmp    2ef5 <strchr+0x21>
      return (char*)s;
  return 0;
    2ef0:	b8 00 00 00 00       	mov    $0x0,%eax
}
    2ef5:	5d                   	pop    %ebp
    2ef6:	c3                   	ret    

00002ef7 <gets>:

char*
gets(char *buf, int max)
{
    2ef7:	55                   	push   %ebp
    2ef8:	89 e5                	mov    %esp,%ebp
    2efa:	57                   	push   %edi
    2efb:	56                   	push   %esi
    2efc:	53                   	push   %ebx
    2efd:	83 ec 1c             	sub    $0x1c,%esp
    2f00:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    2f03:	bb 00 00 00 00       	mov    $0x0,%ebx
    2f08:	89 de                	mov    %ebx,%esi
    2f0a:	83 c3 01             	add    $0x1,%ebx
    2f0d:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
    2f10:	7d 2e                	jge    2f40 <gets+0x49>
    cc = read(0, &c, 1);
    2f12:	83 ec 04             	sub    $0x4,%esp
    2f15:	6a 01                	push   $0x1
    2f17:	8d 45 e7             	lea    -0x19(%ebp),%eax
    2f1a:	50                   	push   %eax
    2f1b:	6a 00                	push   $0x0
    2f1d:	e8 ec 00 00 00       	call   300e <read>
    if(cc < 1)
    2f22:	83 c4 10             	add    $0x10,%esp
    2f25:	85 c0                	test   %eax,%eax
    2f27:	7e 17                	jle    2f40 <gets+0x49>
      break;
    buf[i++] = c;
    2f29:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
    2f2d:	88 04 37             	mov    %al,(%edi,%esi,1)
    if(c == '\n' || c == '\r')
    2f30:	3c 0a                	cmp    $0xa,%al
    2f32:	0f 94 c2             	sete   %dl
    2f35:	3c 0d                	cmp    $0xd,%al
    2f37:	0f 94 c0             	sete   %al
    2f3a:	08 c2                	or     %al,%dl
    2f3c:	74 ca                	je     2f08 <gets+0x11>
    buf[i++] = c;
    2f3e:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
    2f40:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
    2f44:	89 f8                	mov    %edi,%eax
    2f46:	8d 65 f4             	lea    -0xc(%ebp),%esp
    2f49:	5b                   	pop    %ebx
    2f4a:	5e                   	pop    %esi
    2f4b:	5f                   	pop    %edi
    2f4c:	5d                   	pop    %ebp
    2f4d:	c3                   	ret    

00002f4e <stat>:

int
stat(const char *n, struct stat *st)
{
    2f4e:	55                   	push   %ebp
    2f4f:	89 e5                	mov    %esp,%ebp
    2f51:	56                   	push   %esi
    2f52:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    2f53:	83 ec 08             	sub    $0x8,%esp
    2f56:	6a 00                	push   $0x0
    2f58:	ff 75 08             	push   0x8(%ebp)
    2f5b:	e8 d6 00 00 00       	call   3036 <open>
  if(fd < 0)
    2f60:	83 c4 10             	add    $0x10,%esp
    2f63:	85 c0                	test   %eax,%eax
    2f65:	78 24                	js     2f8b <stat+0x3d>
    2f67:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
    2f69:	83 ec 08             	sub    $0x8,%esp
    2f6c:	ff 75 0c             	push   0xc(%ebp)
    2f6f:	50                   	push   %eax
    2f70:	e8 d9 00 00 00       	call   304e <fstat>
    2f75:	89 c6                	mov    %eax,%esi
  close(fd);
    2f77:	89 1c 24             	mov    %ebx,(%esp)
    2f7a:	e8 9f 00 00 00       	call   301e <close>
  return r;
    2f7f:	83 c4 10             	add    $0x10,%esp
}
    2f82:	89 f0                	mov    %esi,%eax
    2f84:	8d 65 f8             	lea    -0x8(%ebp),%esp
    2f87:	5b                   	pop    %ebx
    2f88:	5e                   	pop    %esi
    2f89:	5d                   	pop    %ebp
    2f8a:	c3                   	ret    
    return -1;
    2f8b:	be ff ff ff ff       	mov    $0xffffffff,%esi
    2f90:	eb f0                	jmp    2f82 <stat+0x34>

00002f92 <atoi>:

int
atoi(const char *s)
{
    2f92:	55                   	push   %ebp
    2f93:	89 e5                	mov    %esp,%ebp
    2f95:	53                   	push   %ebx
    2f96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
    2f99:	ba 00 00 00 00       	mov    $0x0,%edx
  while('0' <= *s && *s <= '9')
    2f9e:	eb 10                	jmp    2fb0 <atoi+0x1e>
    n = n*10 + *s++ - '0';
    2fa0:	8d 1c 92             	lea    (%edx,%edx,4),%ebx
    2fa3:	8d 14 1b             	lea    (%ebx,%ebx,1),%edx
    2fa6:	83 c1 01             	add    $0x1,%ecx
    2fa9:	0f be c0             	movsbl %al,%eax
    2fac:	8d 54 10 d0          	lea    -0x30(%eax,%edx,1),%edx
  while('0' <= *s && *s <= '9')
    2fb0:	0f b6 01             	movzbl (%ecx),%eax
    2fb3:	8d 58 d0             	lea    -0x30(%eax),%ebx
    2fb6:	80 fb 09             	cmp    $0x9,%bl
    2fb9:	76 e5                	jbe    2fa0 <atoi+0xe>
  return n;
}
    2fbb:	89 d0                	mov    %edx,%eax
    2fbd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    2fc0:	c9                   	leave  
    2fc1:	c3                   	ret    

00002fc2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    2fc2:	55                   	push   %ebp
    2fc3:	89 e5                	mov    %esp,%ebp
    2fc5:	56                   	push   %esi
    2fc6:	53                   	push   %ebx
    2fc7:	8b 75 08             	mov    0x8(%ebp),%esi
    2fca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    2fcd:	8b 45 10             	mov    0x10(%ebp),%eax
  char *dst;
  const char *src;

  dst = vdst;
    2fd0:	89 f2                	mov    %esi,%edx
  src = vsrc;
  while(n-- > 0)
    2fd2:	eb 0d                	jmp    2fe1 <memmove+0x1f>
    *dst++ = *src++;
    2fd4:	0f b6 01             	movzbl (%ecx),%eax
    2fd7:	88 02                	mov    %al,(%edx)
    2fd9:	8d 49 01             	lea    0x1(%ecx),%ecx
    2fdc:	8d 52 01             	lea    0x1(%edx),%edx
  while(n-- > 0)
    2fdf:	89 d8                	mov    %ebx,%eax
    2fe1:	8d 58 ff             	lea    -0x1(%eax),%ebx
    2fe4:	85 c0                	test   %eax,%eax
    2fe6:	7f ec                	jg     2fd4 <memmove+0x12>
  return vdst;
}
    2fe8:	89 f0                	mov    %esi,%eax
    2fea:	5b                   	pop    %ebx
    2feb:	5e                   	pop    %esi
    2fec:	5d                   	pop    %ebp
    2fed:	c3                   	ret    

00002fee <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    2fee:	b8 01 00 00 00       	mov    $0x1,%eax
    2ff3:	cd 40                	int    $0x40
    2ff5:	c3                   	ret    

00002ff6 <exit>:
SYSCALL(exit)
    2ff6:	b8 02 00 00 00       	mov    $0x2,%eax
    2ffb:	cd 40                	int    $0x40
    2ffd:	c3                   	ret    

00002ffe <wait>:
SYSCALL(wait)
    2ffe:	b8 03 00 00 00       	mov    $0x3,%eax
    3003:	cd 40                	int    $0x40
    3005:	c3                   	ret    

00003006 <pipe>:
SYSCALL(pipe)
    3006:	b8 04 00 00 00       	mov    $0x4,%eax
    300b:	cd 40                	int    $0x40
    300d:	c3                   	ret    

0000300e <read>:
SYSCALL(read)
    300e:	b8 05 00 00 00       	mov    $0x5,%eax
    3013:	cd 40                	int    $0x40
    3015:	c3                   	ret    

00003016 <write>:
SYSCALL(write)
    3016:	b8 10 00 00 00       	mov    $0x10,%eax
    301b:	cd 40                	int    $0x40
    301d:	c3                   	ret    

0000301e <close>:
SYSCALL(close)
    301e:	b8 15 00 00 00       	mov    $0x15,%eax
    3023:	cd 40                	int    $0x40
    3025:	c3                   	ret    

00003026 <kill>:
SYSCALL(kill)
    3026:	b8 06 00 00 00       	mov    $0x6,%eax
    302b:	cd 40                	int    $0x40
    302d:	c3                   	ret    

0000302e <exec>:
SYSCALL(exec)
    302e:	b8 07 00 00 00       	mov    $0x7,%eax
    3033:	cd 40                	int    $0x40
    3035:	c3                   	ret    

00003036 <open>:
SYSCALL(open)
    3036:	b8 0f 00 00 00       	mov    $0xf,%eax
    303b:	cd 40                	int    $0x40
    303d:	c3                   	ret    

0000303e <mknod>:
SYSCALL(mknod)
    303e:	b8 11 00 00 00       	mov    $0x11,%eax
    3043:	cd 40                	int    $0x40
    3045:	c3                   	ret    

00003046 <unlink>:
SYSCALL(unlink)
    3046:	b8 12 00 00 00       	mov    $0x12,%eax
    304b:	cd 40                	int    $0x40
    304d:	c3                   	ret    

0000304e <fstat>:
SYSCALL(fstat)
    304e:	b8 08 00 00 00       	mov    $0x8,%eax
    3053:	cd 40                	int    $0x40
    3055:	c3                   	ret    

00003056 <link>:
SYSCALL(link)
    3056:	b8 13 00 00 00       	mov    $0x13,%eax
    305b:	cd 40                	int    $0x40
    305d:	c3                   	ret    

0000305e <mkdir>:
SYSCALL(mkdir)
    305e:	b8 14 00 00 00       	mov    $0x14,%eax
    3063:	cd 40                	int    $0x40
    3065:	c3                   	ret    

00003066 <chdir>:
SYSCALL(chdir)
    3066:	b8 09 00 00 00       	mov    $0x9,%eax
    306b:	cd 40                	int    $0x40
    306d:	c3                   	ret    

0000306e <dup>:
SYSCALL(dup)
    306e:	b8 0a 00 00 00       	mov    $0xa,%eax
    3073:	cd 40                	int    $0x40
    3075:	c3                   	ret    

00003076 <getpid>:
SYSCALL(getpid)
    3076:	b8 0b 00 00 00       	mov    $0xb,%eax
    307b:	cd 40                	int    $0x40
    307d:	c3                   	ret    

0000307e <sbrk>:
SYSCALL(sbrk)
    307e:	b8 0c 00 00 00       	mov    $0xc,%eax
    3083:	cd 40                	int    $0x40
    3085:	c3                   	ret    

00003086 <sleep>:
SYSCALL(sleep)
    3086:	b8 0d 00 00 00       	mov    $0xd,%eax
    308b:	cd 40                	int    $0x40
    308d:	c3                   	ret    

0000308e <uptime>:
SYSCALL(uptime)
    308e:	b8 0e 00 00 00       	mov    $0xe,%eax
    3093:	cd 40                	int    $0x40
    3095:	c3                   	ret    

00003096 <yield>:
SYSCALL(yield)
    3096:	b8 16 00 00 00       	mov    $0x16,%eax
    309b:	cd 40                	int    $0x40
    309d:	c3                   	ret    

0000309e <getpagetableentry>:
SYSCALL(getpagetableentry)
    309e:	b8 18 00 00 00       	mov    $0x18,%eax
    30a3:	cd 40                	int    $0x40
    30a5:	c3                   	ret    

000030a6 <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
    30a6:	b8 19 00 00 00       	mov    $0x19,%eax
    30ab:	cd 40                	int    $0x40
    30ad:	c3                   	ret    

000030ae <dumppagetable>:
SYSCALL(dumppagetable)
    30ae:	b8 1a 00 00 00       	mov    $0x1a,%eax
    30b3:	cd 40                	int    $0x40
    30b5:	c3                   	ret    

000030b6 <shutdown>:
SYSCALL(shutdown)
    30b6:	b8 17 00 00 00       	mov    $0x17,%eax
    30bb:	cd 40                	int    $0x40
    30bd:	c3                   	ret    

000030be <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    30be:	55                   	push   %ebp
    30bf:	89 e5                	mov    %esp,%ebp
    30c1:	83 ec 1c             	sub    $0x1c,%esp
    30c4:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
    30c7:	6a 01                	push   $0x1
    30c9:	8d 55 f4             	lea    -0xc(%ebp),%edx
    30cc:	52                   	push   %edx
    30cd:	50                   	push   %eax
    30ce:	e8 43 ff ff ff       	call   3016 <write>
}
    30d3:	83 c4 10             	add    $0x10,%esp
    30d6:	c9                   	leave  
    30d7:	c3                   	ret    

000030d8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    30d8:	55                   	push   %ebp
    30d9:	89 e5                	mov    %esp,%ebp
    30db:	57                   	push   %edi
    30dc:	56                   	push   %esi
    30dd:	53                   	push   %ebx
    30de:	83 ec 2c             	sub    $0x2c,%esp
    30e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
    30e4:	89 d0                	mov    %edx,%eax
    30e6:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    30e8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
    30ec:	0f 95 c1             	setne  %cl
    30ef:	c1 ea 1f             	shr    $0x1f,%edx
    30f2:	84 d1                	test   %dl,%cl
    30f4:	74 44                	je     313a <printint+0x62>
    neg = 1;
    x = -xx;
    30f6:	f7 d8                	neg    %eax
    30f8:	89 c1                	mov    %eax,%ecx
    neg = 1;
    30fa:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
    3101:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
    3106:	89 c8                	mov    %ecx,%eax
    3108:	ba 00 00 00 00       	mov    $0x0,%edx
    310d:	f7 f6                	div    %esi
    310f:	89 df                	mov    %ebx,%edi
    3111:	83 c3 01             	add    $0x1,%ebx
    3114:	0f b6 92 94 55 00 00 	movzbl 0x5594(%edx),%edx
    311b:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
    311f:	89 ca                	mov    %ecx,%edx
    3121:	89 c1                	mov    %eax,%ecx
    3123:	39 d6                	cmp    %edx,%esi
    3125:	76 df                	jbe    3106 <printint+0x2e>
  if(neg)
    3127:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
    312b:	74 31                	je     315e <printint+0x86>
    buf[i++] = '-';
    312d:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
    3132:	8d 5f 02             	lea    0x2(%edi),%ebx
    3135:	8b 75 d0             	mov    -0x30(%ebp),%esi
    3138:	eb 17                	jmp    3151 <printint+0x79>
    x = xx;
    313a:	89 c1                	mov    %eax,%ecx
  neg = 0;
    313c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
    3143:	eb bc                	jmp    3101 <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
    3145:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
    314a:	89 f0                	mov    %esi,%eax
    314c:	e8 6d ff ff ff       	call   30be <putc>
  while(--i >= 0)
    3151:	83 eb 01             	sub    $0x1,%ebx
    3154:	79 ef                	jns    3145 <printint+0x6d>
}
    3156:	83 c4 2c             	add    $0x2c,%esp
    3159:	5b                   	pop    %ebx
    315a:	5e                   	pop    %esi
    315b:	5f                   	pop    %edi
    315c:	5d                   	pop    %ebp
    315d:	c3                   	ret    
    315e:	8b 75 d0             	mov    -0x30(%ebp),%esi
    3161:	eb ee                	jmp    3151 <printint+0x79>

00003163 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
    3163:	55                   	push   %ebp
    3164:	89 e5                	mov    %esp,%ebp
    3166:	57                   	push   %edi
    3167:	56                   	push   %esi
    3168:	53                   	push   %ebx
    3169:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
    316c:	8d 45 10             	lea    0x10(%ebp),%eax
    316f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
    3172:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
    3177:	bb 00 00 00 00       	mov    $0x0,%ebx
    317c:	eb 14                	jmp    3192 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
    317e:	89 fa                	mov    %edi,%edx
    3180:	8b 45 08             	mov    0x8(%ebp),%eax
    3183:	e8 36 ff ff ff       	call   30be <putc>
    3188:	eb 05                	jmp    318f <printf+0x2c>
      }
    } else if(state == '%'){
    318a:	83 fe 25             	cmp    $0x25,%esi
    318d:	74 25                	je     31b4 <printf+0x51>
  for(i = 0; fmt[i]; i++){
    318f:	83 c3 01             	add    $0x1,%ebx
    3192:	8b 45 0c             	mov    0xc(%ebp),%eax
    3195:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
    3199:	84 c0                	test   %al,%al
    319b:	0f 84 20 01 00 00    	je     32c1 <printf+0x15e>
    c = fmt[i] & 0xff;
    31a1:	0f be f8             	movsbl %al,%edi
    31a4:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
    31a7:	85 f6                	test   %esi,%esi
    31a9:	75 df                	jne    318a <printf+0x27>
      if(c == '%'){
    31ab:	83 f8 25             	cmp    $0x25,%eax
    31ae:	75 ce                	jne    317e <printf+0x1b>
        state = '%';
    31b0:	89 c6                	mov    %eax,%esi
    31b2:	eb db                	jmp    318f <printf+0x2c>
      if(c == 'd'){
    31b4:	83 f8 25             	cmp    $0x25,%eax
    31b7:	0f 84 cf 00 00 00    	je     328c <printf+0x129>
    31bd:	0f 8c dd 00 00 00    	jl     32a0 <printf+0x13d>
    31c3:	83 f8 78             	cmp    $0x78,%eax
    31c6:	0f 8f d4 00 00 00    	jg     32a0 <printf+0x13d>
    31cc:	83 f8 63             	cmp    $0x63,%eax
    31cf:	0f 8c cb 00 00 00    	jl     32a0 <printf+0x13d>
    31d5:	83 e8 63             	sub    $0x63,%eax
    31d8:	83 f8 15             	cmp    $0x15,%eax
    31db:	0f 87 bf 00 00 00    	ja     32a0 <printf+0x13d>
    31e1:	ff 24 85 3c 55 00 00 	jmp    *0x553c(,%eax,4)
        printint(fd, *ap, 10, 1);
    31e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
    31eb:	8b 17                	mov    (%edi),%edx
    31ed:	83 ec 0c             	sub    $0xc,%esp
    31f0:	6a 01                	push   $0x1
    31f2:	b9 0a 00 00 00       	mov    $0xa,%ecx
    31f7:	8b 45 08             	mov    0x8(%ebp),%eax
    31fa:	e8 d9 fe ff ff       	call   30d8 <printint>
        ap++;
    31ff:	83 c7 04             	add    $0x4,%edi
    3202:	89 7d e4             	mov    %edi,-0x1c(%ebp)
    3205:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    3208:	be 00 00 00 00       	mov    $0x0,%esi
    320d:	eb 80                	jmp    318f <printf+0x2c>
        printint(fd, *ap, 16, 0);
    320f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
    3212:	8b 17                	mov    (%edi),%edx
    3214:	83 ec 0c             	sub    $0xc,%esp
    3217:	6a 00                	push   $0x0
    3219:	b9 10 00 00 00       	mov    $0x10,%ecx
    321e:	8b 45 08             	mov    0x8(%ebp),%eax
    3221:	e8 b2 fe ff ff       	call   30d8 <printint>
        ap++;
    3226:	83 c7 04             	add    $0x4,%edi
    3229:	89 7d e4             	mov    %edi,-0x1c(%ebp)
    322c:	83 c4 10             	add    $0x10,%esp
      state = 0;
    322f:	be 00 00 00 00       	mov    $0x0,%esi
    3234:	e9 56 ff ff ff       	jmp    318f <printf+0x2c>
        s = (char*)*ap;
    3239:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    323c:	8b 30                	mov    (%eax),%esi
        ap++;
    323e:	83 c0 04             	add    $0x4,%eax
    3241:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
    3244:	85 f6                	test   %esi,%esi
    3246:	75 15                	jne    325d <printf+0xfa>
          s = "(null)";
    3248:	be 33 55 00 00       	mov    $0x5533,%esi
    324d:	eb 0e                	jmp    325d <printf+0xfa>
          putc(fd, *s);
    324f:	0f be d2             	movsbl %dl,%edx
    3252:	8b 45 08             	mov    0x8(%ebp),%eax
    3255:	e8 64 fe ff ff       	call   30be <putc>
          s++;
    325a:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
    325d:	0f b6 16             	movzbl (%esi),%edx
    3260:	84 d2                	test   %dl,%dl
    3262:	75 eb                	jne    324f <printf+0xec>
      state = 0;
    3264:	be 00 00 00 00       	mov    $0x0,%esi
    3269:	e9 21 ff ff ff       	jmp    318f <printf+0x2c>
        putc(fd, *ap);
    326e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
    3271:	0f be 17             	movsbl (%edi),%edx
    3274:	8b 45 08             	mov    0x8(%ebp),%eax
    3277:	e8 42 fe ff ff       	call   30be <putc>
        ap++;
    327c:	83 c7 04             	add    $0x4,%edi
    327f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
    3282:	be 00 00 00 00       	mov    $0x0,%esi
    3287:	e9 03 ff ff ff       	jmp    318f <printf+0x2c>
        putc(fd, c);
    328c:	89 fa                	mov    %edi,%edx
    328e:	8b 45 08             	mov    0x8(%ebp),%eax
    3291:	e8 28 fe ff ff       	call   30be <putc>
      state = 0;
    3296:	be 00 00 00 00       	mov    $0x0,%esi
    329b:	e9 ef fe ff ff       	jmp    318f <printf+0x2c>
        putc(fd, '%');
    32a0:	ba 25 00 00 00       	mov    $0x25,%edx
    32a5:	8b 45 08             	mov    0x8(%ebp),%eax
    32a8:	e8 11 fe ff ff       	call   30be <putc>
        putc(fd, c);
    32ad:	89 fa                	mov    %edi,%edx
    32af:	8b 45 08             	mov    0x8(%ebp),%eax
    32b2:	e8 07 fe ff ff       	call   30be <putc>
      state = 0;
    32b7:	be 00 00 00 00       	mov    $0x0,%esi
    32bc:	e9 ce fe ff ff       	jmp    318f <printf+0x2c>
    }
  }
}
    32c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
    32c4:	5b                   	pop    %ebx
    32c5:	5e                   	pop    %esi
    32c6:	5f                   	pop    %edi
    32c7:	5d                   	pop    %ebp
    32c8:	c3                   	ret    
