
_lotterytest:     file format elf32-i386


Disassembly of section .text:

00000000 <run_forever>:
    }
}

__attribute__((noreturn))
void run_forever() {
    while (1) {
   0:	eb fe                	jmp    0 <run_forever>

00000002 <yield_forever>:
void yield_forever() {
   2:	55                   	push   %ebp
   3:	89 e5                	mov    %esp,%ebp
   5:	83 ec 08             	sub    $0x8,%esp
        yield();
   8:	e8 ba 0a 00 00       	call   ac7 <yield>
    while (1) {
   d:	eb f9                	jmp    8 <yield_forever+0x6>

0000000f <iowait_forever>:
        __asm__("");
    }
}

__attribute__((noreturn))
void iowait_forever() {
   f:	55                   	push   %ebp
  10:	89 e5                	mov    %esp,%ebp
  12:	83 ec 24             	sub    $0x24,%esp
    int fds[2];
    pipe(fds);
  15:	8d 45 f0             	lea    -0x10(%ebp),%eax
  18:	50                   	push   %eax
  19:	e8 19 0a 00 00       	call   a37 <pipe>
  1e:	83 c4 10             	add    $0x10,%esp
    while (1) {
        char temp[1];
        read(fds[0], temp, 0);
  21:	83 ec 04             	sub    $0x4,%esp
  24:	6a 00                	push   $0x0
  26:	8d 45 ef             	lea    -0x11(%ebp),%eax
  29:	50                   	push   %eax
  2a:	ff 75 f0             	push   -0x10(%ebp)
  2d:	e8 0d 0a 00 00       	call   a3f <read>
    while (1) {
  32:	83 c4 10             	add    $0x10,%esp
  35:	eb ea                	jmp    21 <iowait_forever+0x12>

00000037 <exit_fast>:
    }
}

__attribute__((noreturn))
void exit_fast() {
  37:	55                   	push   %ebp
  38:	89 e5                	mov    %esp,%ebp
  3a:	83 ec 08             	sub    $0x8,%esp
    exit();
  3d:	e8 e5 09 00 00       	call   a27 <exit>

00000042 <spawn>:
}


int spawn(int tickets, function_type function) {
  42:	55                   	push   %ebp
  43:	89 e5                	mov    %esp,%ebp
  45:	53                   	push   %ebx
  46:	83 ec 04             	sub    $0x4,%esp
    int pid = fork();
  49:	e8 d1 09 00 00       	call   a1f <fork>
    if (pid == 0) {
  4e:	85 c0                	test   %eax,%eax
  50:	74 0e                	je     60 <spawn+0x1e>
  52:	89 c3                	mov    %eax,%ebx
        settickets(tickets);
        yield();
        (*function)();
        exit();
    } else if (pid != -1) {
  54:	83 f8 ff             	cmp    $0xffffffff,%eax
  57:	74 1f                	je     78 <spawn+0x36>
        return pid;
    } else {
        printf(2, "error in fork\n");
        return -1;
    }
}
  59:	89 d8                	mov    %ebx,%eax
  5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  5e:	c9                   	leave  
  5f:	c3                   	ret    
        settickets(tickets);
  60:	83 ec 0c             	sub    $0xc,%esp
  63:	ff 75 08             	push   0x8(%ebp)
  66:	e8 6c 0a 00 00       	call   ad7 <settickets>
        yield();
  6b:	e8 57 0a 00 00       	call   ac7 <yield>
        (*function)();
  70:	ff 55 0c             	call   *0xc(%ebp)
        exit();
  73:	e8 af 09 00 00       	call   a27 <exit>
        printf(2, "error in fork\n");
  78:	83 ec 08             	sub    $0x8,%esp
  7b:	68 40 0e 00 00       	push   $0xe40
  80:	6a 02                	push   $0x2
  82:	e8 05 0b 00 00       	call   b8c <printf>
        return -1;
  87:	83 c4 10             	add    $0x10,%esp
  8a:	eb cd                	jmp    59 <spawn+0x17>

0000008c <find_index_of_pid>:

int find_index_of_pid(int *list, int list_size, int pid) {
  8c:	55                   	push   %ebp
  8d:	89 e5                	mov    %esp,%ebp
  8f:	53                   	push   %ebx
  90:	8b 5d 08             	mov    0x8(%ebp),%ebx
  93:	8b 55 0c             	mov    0xc(%ebp),%edx
  96:	8b 4d 10             	mov    0x10(%ebp),%ecx
    for (int i = 0; i < list_size; ++i) {
  99:	b8 00 00 00 00       	mov    $0x0,%eax
  9e:	eb 03                	jmp    a3 <find_index_of_pid+0x17>
  a0:	83 c0 01             	add    $0x1,%eax
  a3:	39 d0                	cmp    %edx,%eax
  a5:	7d 07                	jge    ae <find_index_of_pid+0x22>
        if (list[i] == pid)
  a7:	39 0c 83             	cmp    %ecx,(%ebx,%eax,4)
  aa:	75 f4                	jne    a0 <find_index_of_pid+0x14>
  ac:	eb 05                	jmp    b3 <find_index_of_pid+0x27>
            return i;
    }
    return -1;
  ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  b6:	c9                   	leave  
  b7:	c3                   	ret    

000000b8 <wait_for_ticket_counts>:

void wait_for_ticket_counts(int num_children, int *pids, int *tickets) {
  b8:	55                   	push   %ebp
  b9:	89 e5                	mov    %esp,%ebp
  bb:	57                   	push   %edi
  bc:	56                   	push   %esi
  bd:	53                   	push   %ebx
  be:	81 ec 38 03 00 00    	sub    $0x338,%esp
  c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  c7:	8b 7d 10             	mov    0x10(%ebp),%edi
    /* temporarily lower our share to give other processes more of a chance to run
     * their settickets() call */
    settickets(NOT_AS_LARGE_TICKET_COUNT);
  ca:	68 10 27 00 00       	push   $0x2710
  cf:	e8 03 0a 00 00       	call   ad7 <settickets>
    for (int yield_count = 0; yield_count < MAX_YIELDS_FOR_SETUP; ++yield_count) {
  d4:	83 c4 10             	add    $0x10,%esp
  d7:	c7 85 d0 fc ff ff 00 	movl   $0x0,-0x330(%ebp)
  de:	00 00 00 
  e1:	83 bd d0 fc ff ff 63 	cmpl   $0x63,-0x330(%ebp)
  e8:	7f 6c                	jg     156 <wait_for_ticket_counts+0x9e>
        yield();
  ea:	e8 d8 09 00 00       	call   ac7 <yield>
        int done = 1;
        struct processes_info info;
        getprocessesinfo(&info);
  ef:	83 ec 0c             	sub    $0xc,%esp
  f2:	8d 85 e4 fc ff ff    	lea    -0x31c(%ebp),%eax
  f8:	50                   	push   %eax
  f9:	e8 e1 09 00 00       	call   adf <getprocessesinfo>
        for (int i = 0; i < num_children; ++i) {
  fe:	83 c4 10             	add    $0x10,%esp
 101:	bb 00 00 00 00       	mov    $0x0,%ebx
        int done = 1;
 106:	c7 85 d4 fc ff ff 01 	movl   $0x1,-0x32c(%ebp)
 10d:	00 00 00 
        for (int i = 0; i < num_children; ++i) {
 110:	eb 03                	jmp    115 <wait_for_ticket_counts+0x5d>
 112:	83 c3 01             	add    $0x1,%ebx
 115:	3b 5d 08             	cmp    0x8(%ebp),%ebx
 118:	7d 33                	jge    14d <wait_for_ticket_counts+0x95>
            int index = find_index_of_pid(info.pids, info.num_processes, pids[i]);
 11a:	83 ec 04             	sub    $0x4,%esp
 11d:	ff 34 9e             	push   (%esi,%ebx,4)
 120:	ff b5 e4 fc ff ff    	push   -0x31c(%ebp)
 126:	8d 85 e8 fc ff ff    	lea    -0x318(%ebp),%eax
 12c:	50                   	push   %eax
 12d:	e8 5a ff ff ff       	call   8c <find_index_of_pid>
 132:	83 c4 10             	add    $0x10,%esp
            if (info.tickets[index] != tickets[i]) done = 0;
 135:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
 138:	39 94 85 e8 fe ff ff 	cmp    %edx,-0x118(%ebp,%eax,4)
 13f:	74 d1                	je     112 <wait_for_ticket_counts+0x5a>
 141:	c7 85 d4 fc ff ff 00 	movl   $0x0,-0x32c(%ebp)
 148:	00 00 00 
 14b:	eb c5                	jmp    112 <wait_for_ticket_counts+0x5a>
        }
        if (done)
 14d:	83 bd d4 fc ff ff 00 	cmpl   $0x0,-0x32c(%ebp)
 154:	74 18                	je     16e <wait_for_ticket_counts+0xb6>
            break;
    }
    settickets(LARGE_TICKET_COUNT);
 156:	83 ec 0c             	sub    $0xc,%esp
 159:	68 a0 86 01 00       	push   $0x186a0
 15e:	e8 74 09 00 00       	call   ad7 <settickets>
}
 163:	83 c4 10             	add    $0x10,%esp
 166:	8d 65 f4             	lea    -0xc(%ebp),%esp
 169:	5b                   	pop    %ebx
 16a:	5e                   	pop    %esi
 16b:	5f                   	pop    %edi
 16c:	5d                   	pop    %ebp
 16d:	c3                   	ret    
    for (int yield_count = 0; yield_count < MAX_YIELDS_FOR_SETUP; ++yield_count) {
 16e:	83 85 d0 fc ff ff 01 	addl   $0x1,-0x330(%ebp)
 175:	e9 67 ff ff ff       	jmp    e1 <wait_for_ticket_counts+0x29>

0000017a <check>:

void check(struct test_case* test, int passed_p, const char *description) {
 17a:	55                   	push   %ebp
 17b:	89 e5                	mov    %esp,%ebp
 17d:	83 ec 08             	sub    $0x8,%esp
 180:	8b 55 08             	mov    0x8(%ebp),%edx
    test->total_tests++;
 183:	8b 42 04             	mov    0x4(%edx),%eax
 186:	83 c0 01             	add    $0x1,%eax
 189:	89 42 04             	mov    %eax,0x4(%edx)
    if (!passed_p) {
 18c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 190:	74 02                	je     194 <check+0x1a>
        test->errors++;
        printf(1, "*** TEST FAILURE: for scenario '%s': %s\n", test->name, description);
    }
}
 192:	c9                   	leave  
 193:	c3                   	ret    
        test->errors++;
 194:	8b 42 08             	mov    0x8(%edx),%eax
 197:	83 c0 01             	add    $0x1,%eax
 19a:	89 42 08             	mov    %eax,0x8(%edx)
        printf(1, "*** TEST FAILURE: for scenario '%s': %s\n", test->name, description);
 19d:	ff 75 10             	push   0x10(%ebp)
 1a0:	ff 32                	push   (%edx)
 1a2:	68 08 0f 00 00       	push   $0xf08
 1a7:	6a 01                	push   $0x1
 1a9:	e8 de 09 00 00       	call   b8c <printf>
 1ae:	83 c4 10             	add    $0x10,%esp
}
 1b1:	eb df                	jmp    192 <check+0x18>

000001b3 <execute_and_get_info>:

void execute_and_get_info(
        struct test_case* test, int *pids,
        struct processes_info *before,
        struct processes_info *after) {
 1b3:	55                   	push   %ebp
 1b4:	89 e5                	mov    %esp,%ebp
 1b6:	57                   	push   %edi
 1b7:	56                   	push   %esi
 1b8:	53                   	push   %ebx
 1b9:	83 ec 18             	sub    $0x18,%esp
 1bc:	8b 75 08             	mov    0x8(%ebp),%esi
    settickets(LARGE_TICKET_COUNT);
 1bf:	68 a0 86 01 00       	push   $0x186a0
 1c4:	e8 0e 09 00 00       	call   ad7 <settickets>
    for (int i = 0; i < test->num_children; ++i) {
 1c9:	83 c4 10             	add    $0x10,%esp
 1cc:	bb 00 00 00 00       	mov    $0x0,%ebx
 1d1:	eb 21                	jmp    1f4 <execute_and_get_info+0x41>
        pids[i] = spawn(test->tickets[i], test->functions[i]);
 1d3:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d6:	8d 3c 98             	lea    (%eax,%ebx,4),%edi
 1d9:	83 ec 08             	sub    $0x8,%esp
 1dc:	ff b4 9e 94 01 00 00 	push   0x194(%esi,%ebx,4)
 1e3:	ff 74 9e 10          	push   0x10(%esi,%ebx,4)
 1e7:	e8 56 fe ff ff       	call   42 <spawn>
 1ec:	89 07                	mov    %eax,(%edi)
    for (int i = 0; i < test->num_children; ++i) {
 1ee:	83 c3 01             	add    $0x1,%ebx
 1f1:	83 c4 10             	add    $0x10,%esp
 1f4:	8b 46 0c             	mov    0xc(%esi),%eax
 1f7:	39 d8                	cmp    %ebx,%eax
 1f9:	7f d8                	jg     1d3 <execute_and_get_info+0x20>
    }
    wait_for_ticket_counts(test->num_children, pids, test->tickets);
 1fb:	8d 56 10             	lea    0x10(%esi),%edx
 1fe:	83 ec 04             	sub    $0x4,%esp
 201:	52                   	push   %edx
 202:	ff 75 0c             	push   0xc(%ebp)
 205:	50                   	push   %eax
 206:	e8 ad fe ff ff       	call   b8 <wait_for_ticket_counts>
    before->num_processes = after->num_processes = -1;
 20b:	8b 45 14             	mov    0x14(%ebp),%eax
 20e:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
 214:	8b 45 10             	mov    0x10(%ebp),%eax
 217:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
    sleep(WARMUP_TIME);
 21d:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
 224:	e8 8e 08 00 00       	call   ab7 <sleep>
    getprocessesinfo(before);
 229:	83 c4 04             	add    $0x4,%esp
 22c:	ff 75 10             	push   0x10(%ebp)
 22f:	e8 ab 08 00 00       	call   adf <getprocessesinfo>
    sleep(SLEEP_TIME);
 234:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
 23b:	e8 77 08 00 00       	call   ab7 <sleep>
    getprocessesinfo(after);
 240:	83 c4 04             	add    $0x4,%esp
 243:	ff 75 14             	push   0x14(%ebp)
 246:	e8 94 08 00 00       	call   adf <getprocessesinfo>
    for (int i = 0; i < test->num_children; ++i) {
 24b:	83 c4 10             	add    $0x10,%esp
 24e:	bb 00 00 00 00       	mov    $0x0,%ebx
 253:	8b 7d 0c             	mov    0xc(%ebp),%edi
 256:	eb 11                	jmp    269 <execute_and_get_info+0xb6>
        kill(pids[i]);
 258:	83 ec 0c             	sub    $0xc,%esp
 25b:	ff 34 9f             	push   (%edi,%ebx,4)
 25e:	e8 f4 07 00 00       	call   a57 <kill>
    for (int i = 0; i < test->num_children; ++i) {
 263:	83 c3 01             	add    $0x1,%ebx
 266:	83 c4 10             	add    $0x10,%esp
 269:	39 5e 0c             	cmp    %ebx,0xc(%esi)
 26c:	7f ea                	jg     258 <execute_and_get_info+0xa5>
    }
    for (int i = 0; i < test->num_children; ++i) {
 26e:	bb 00 00 00 00       	mov    $0x0,%ebx
 273:	eb 08                	jmp    27d <execute_and_get_info+0xca>
        wait();
 275:	e8 b5 07 00 00       	call   a2f <wait>
    for (int i = 0; i < test->num_children; ++i) {
 27a:	83 c3 01             	add    $0x1,%ebx
 27d:	39 5e 0c             	cmp    %ebx,0xc(%esi)
 280:	7f f3                	jg     275 <execute_and_get_info+0xc2>
    }
}
 282:	8d 65 f4             	lea    -0xc(%ebp),%esp
 285:	5b                   	pop    %ebx
 286:	5e                   	pop    %esi
 287:	5f                   	pop    %edi
 288:	5d                   	pop    %ebp
 289:	c3                   	ret    

0000028a <count_schedules>:

void count_schedules(
        struct test_case *test, int *pids,
        struct processes_info *before,
        struct processes_info *after) {
 28a:	55                   	push   %ebp
 28b:	89 e5                	mov    %esp,%ebp
 28d:	57                   	push   %edi
 28e:	56                   	push   %esi
 28f:	53                   	push   %ebx
 290:	83 ec 1c             	sub    $0x1c,%esp
 293:	8b 5d 08             	mov    0x8(%ebp),%ebx
    test->total_actual_schedules = 0;
 296:	c7 83 90 01 00 00 00 	movl   $0x0,0x190(%ebx)
 29d:	00 00 00 
    for (int i = 0; i < test->num_children; ++i) {
 2a0:	bf 00 00 00 00       	mov    $0x0,%edi
 2a5:	eb 4e                	jmp    2f5 <count_schedules+0x6b>
        int after_index = find_index_of_pid(after->pids, after->num_processes, pids[i]);
        check(test,
              before_index >= 0 && after_index >= 0,
              "subprocess's pid appeared in getprocessesinfo output");
        if (before_index >= 0 && after_index >= 0) {
            check(test,
 2a7:	8b 55 14             	mov    0x14(%ebp),%edx
 2aa:	3b 84 b2 04 02 00 00 	cmp    0x204(%edx,%esi,4),%eax
 2b1:	0f 84 c8 00 00 00    	je     37f <count_schedules+0xf5>
 2b7:	b8 00 00 00 00       	mov    $0x0,%eax
 2bc:	83 ec 04             	sub    $0x4,%esp
 2bf:	68 6c 0f 00 00       	push   $0xf6c
 2c4:	50                   	push   %eax
 2c5:	53                   	push   %ebx
 2c6:	e8 af fe ff ff       	call   17a <check>
                  test->tickets[i] == before->tickets[before_index] &&
                  test->tickets[i] == after->tickets[after_index],
                  "subprocess assigned correct number of tickets");
            test->actual_schedules[i] = after->times_scheduled[after_index] - before->times_scheduled[before_index];
 2cb:	8b 45 14             	mov    0x14(%ebp),%eax
 2ce:	8b 84 b0 04 01 00 00 	mov    0x104(%eax,%esi,4),%eax
 2d5:	8b 75 10             	mov    0x10(%ebp),%esi
 2d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 2db:	2b 84 96 04 01 00 00 	sub    0x104(%esi,%edx,4),%eax
 2e2:	89 84 bb 10 01 00 00 	mov    %eax,0x110(%ebx,%edi,4)
            test->total_actual_schedules += test->actual_schedules[i];
 2e9:	01 83 90 01 00 00    	add    %eax,0x190(%ebx)
 2ef:	83 c4 10             	add    $0x10,%esp
    for (int i = 0; i < test->num_children; ++i) {
 2f2:	83 c7 01             	add    $0x1,%edi
 2f5:	39 7b 0c             	cmp    %edi,0xc(%ebx)
 2f8:	0f 8e 9b 00 00 00    	jle    399 <count_schedules+0x10f>
        int before_index = find_index_of_pid(before->pids, before->num_processes, pids[i]);
 2fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 301:	8b 34 b8             	mov    (%eax,%edi,4),%esi
 304:	8b 45 10             	mov    0x10(%ebp),%eax
 307:	83 c0 04             	add    $0x4,%eax
 30a:	83 ec 04             	sub    $0x4,%esp
 30d:	56                   	push   %esi
 30e:	8b 4d 10             	mov    0x10(%ebp),%ecx
 311:	ff 31                	push   (%ecx)
 313:	50                   	push   %eax
 314:	e8 73 fd ff ff       	call   8c <find_index_of_pid>
 319:	83 c4 0c             	add    $0xc,%esp
 31c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        int after_index = find_index_of_pid(after->pids, after->num_processes, pids[i]);
 31f:	8b 4d 14             	mov    0x14(%ebp),%ecx
 322:	8d 41 04             	lea    0x4(%ecx),%eax
 325:	56                   	push   %esi
 326:	ff 31                	push   (%ecx)
 328:	50                   	push   %eax
 329:	e8 5e fd ff ff       	call   8c <find_index_of_pid>
 32e:	83 c4 0c             	add    $0xc,%esp
 331:	89 c6                	mov    %eax,%esi
              before_index >= 0 && after_index >= 0,
 333:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 336:	f7 d2                	not    %edx
 338:	c1 ea 1f             	shr    $0x1f,%edx
 33b:	f7 d0                	not    %eax
 33d:	c1 e8 1f             	shr    $0x1f,%eax
        check(test,
 340:	89 c1                	mov    %eax,%ecx
 342:	21 d1                	and    %edx,%ecx
 344:	88 4d e3             	mov    %cl,-0x1d(%ebp)
 347:	68 34 0f 00 00       	push   $0xf34
 34c:	21 d0                	and    %edx,%eax
 34e:	50                   	push   %eax
 34f:	53                   	push   %ebx
 350:	e8 25 fe ff ff       	call   17a <check>
        if (before_index >= 0 && after_index >= 0) {
 355:	83 c4 10             	add    $0x10,%esp
 358:	80 7d e3 00          	cmpb   $0x0,-0x1d(%ebp)
 35c:	74 2b                	je     389 <count_schedules+0xff>
                  test->tickets[i] == before->tickets[before_index] &&
 35e:	8b 44 bb 10          	mov    0x10(%ebx,%edi,4),%eax
            check(test,
 362:	8b 4d 10             	mov    0x10(%ebp),%ecx
 365:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 368:	3b 84 91 04 02 00 00 	cmp    0x204(%ecx,%edx,4),%eax
 36f:	0f 84 32 ff ff ff    	je     2a7 <count_schedules+0x1d>
 375:	b8 00 00 00 00       	mov    $0x0,%eax
 37a:	e9 3d ff ff ff       	jmp    2bc <count_schedules+0x32>
 37f:	b8 01 00 00 00       	mov    $0x1,%eax
 384:	e9 33 ff ff ff       	jmp    2bc <count_schedules+0x32>
        } else {
            test->actual_schedules[i] = -99999; // obviously bogus count that will fail checks later
 389:	c7 84 bb 10 01 00 00 	movl   $0xfffe7961,0x110(%ebx,%edi,4)
 390:	61 79 fe ff 
 394:	e9 59 ff ff ff       	jmp    2f2 <count_schedules+0x68>
        }
    }
}
 399:	8d 65 f4             	lea    -0xc(%ebp),%esp
 39c:	5b                   	pop    %ebx
 39d:	5e                   	pop    %esi
 39e:	5f                   	pop    %edi
 39f:	5d                   	pop    %ebp
 3a0:	c3                   	ret    

000003a1 <dump_test_timings>:

void dump_test_timings(struct test_case *test) {
 3a1:	55                   	push   %ebp
 3a2:	89 e5                	mov    %esp,%ebp
 3a4:	56                   	push   %esi
 3a5:	53                   	push   %ebx
 3a6:	8b 75 08             	mov    0x8(%ebp),%esi
    printf(1, "-----------------------------------------\n");
 3a9:	83 ec 08             	sub    $0x8,%esp
 3ac:	68 9c 0f 00 00       	push   $0xf9c
 3b1:	6a 01                	push   $0x1
 3b3:	e8 d4 07 00 00       	call   b8c <printf>
    printf(1, "%s expected schedules ratios and observations\n", test->name);
 3b8:	83 c4 0c             	add    $0xc,%esp
 3bb:	ff 36                	push   (%esi)
 3bd:	68 c8 0f 00 00       	push   $0xfc8
 3c2:	6a 01                	push   $0x1
 3c4:	e8 c3 07 00 00       	call   b8c <printf>
    printf(1, "#\texpect\tobserve\t(description)\n");
 3c9:	83 c4 08             	add    $0x8,%esp
 3cc:	68 f8 0f 00 00       	push   $0xff8
 3d1:	6a 01                	push   $0x1
 3d3:	e8 b4 07 00 00       	call   b8c <printf>
    for (int i = 0; i < test->num_children; ++i) {
 3d8:	83 c4 10             	add    $0x10,%esp
 3db:	bb 00 00 00 00       	mov    $0x0,%ebx
 3e0:	eb 2e                	jmp    410 <dump_test_timings+0x6f>
        const char *assigned_function = "(unknown)";
        if (test->functions[i] == yield_forever) {
            assigned_function = "yield_forever";
 3e2:	b8 4f 0e 00 00       	mov    $0xe4f,%eax
        } else if (test->functions[i] == iowait_forever) {
            assigned_function = "iowait_forever";
        } else if (test->functions[i] == exit_fast) {
            assigned_function = "exit_fast";
        }
        printf(1, "%d\t%d\t%d\t(assigned %d tickets; running %s)\n",
 3e7:	83 ec 04             	sub    $0x4,%esp
 3ea:	50                   	push   %eax
 3eb:	ff 74 9e 10          	push   0x10(%esi,%ebx,4)
 3ef:	ff b4 9e 10 01 00 00 	push   0x110(%esi,%ebx,4)
 3f6:	ff b4 9e 90 00 00 00 	push   0x90(%esi,%ebx,4)
 3fd:	53                   	push   %ebx
 3fe:	68 18 10 00 00       	push   $0x1018
 403:	6a 01                	push   $0x1
 405:	e8 82 07 00 00       	call   b8c <printf>
    for (int i = 0; i < test->num_children; ++i) {
 40a:	83 c3 01             	add    $0x1,%ebx
 40d:	83 c4 20             	add    $0x20,%esp
 410:	39 5e 0c             	cmp    %ebx,0xc(%esi)
 413:	7e 3f                	jle    454 <dump_test_timings+0xb3>
        if (test->functions[i] == yield_forever) {
 415:	8b 84 9e 94 01 00 00 	mov    0x194(%esi,%ebx,4),%eax
 41c:	3d 02 00 00 00       	cmp    $0x2,%eax
 421:	74 bf                	je     3e2 <dump_test_timings+0x41>
        } else if (test->functions[i] == run_forever) {
 423:	3d 00 00 00 00       	cmp    $0x0,%eax
 428:	74 15                	je     43f <dump_test_timings+0x9e>
        } else if (test->functions[i] == iowait_forever) {
 42a:	3d 0f 00 00 00       	cmp    $0xf,%eax
 42f:	74 15                	je     446 <dump_test_timings+0xa5>
        } else if (test->functions[i] == exit_fast) {
 431:	3d 37 00 00 00       	cmp    $0x37,%eax
 436:	74 15                	je     44d <dump_test_timings+0xac>
        const char *assigned_function = "(unknown)";
 438:	b8 78 0e 00 00       	mov    $0xe78,%eax
 43d:	eb a8                	jmp    3e7 <dump_test_timings+0x46>
            assigned_function = "run_forever";
 43f:	b8 5d 0e 00 00       	mov    $0xe5d,%eax
 444:	eb a1                	jmp    3e7 <dump_test_timings+0x46>
            assigned_function = "iowait_forever";
 446:	b8 69 0e 00 00       	mov    $0xe69,%eax
 44b:	eb 9a                	jmp    3e7 <dump_test_timings+0x46>
            assigned_function = "exit_fast";
 44d:	b8 82 0e 00 00       	mov    $0xe82,%eax
 452:	eb 93                	jmp    3e7 <dump_test_timings+0x46>
            test->expect_schedules_unscaled[i],
            test->actual_schedules[i],
            test->tickets[i],
            assigned_function);
    }
    printf(1, "\nNOTE: the 'expect' values above represent the expected\n"
 454:	83 ec 08             	sub    $0x8,%esp
 457:	68 44 10 00 00       	push   $0x1044
 45c:	6a 01                	push   $0x1
 45e:	e8 29 07 00 00       	call   b8c <printf>
              "      ratio of schedules between the processes. So, to compare\n"
              "      them to the observations by hand, multiply each expected\n"
              "      value by (sum of observed)/(sum of expected)\n");
    printf(1, "-----------------------------------------\n");
 463:	83 c4 08             	add    $0x8,%esp
 466:	68 9c 0f 00 00       	push   $0xf9c
 46b:	6a 01                	push   $0x1
 46d:	e8 1a 07 00 00       	call   b8c <printf>
}
 472:	83 c4 10             	add    $0x10,%esp
 475:	8d 65 f8             	lea    -0x8(%ebp),%esp
 478:	5b                   	pop    %ebx
 479:	5e                   	pop    %esi
 47a:	5d                   	pop    %ebp
 47b:	c3                   	ret    

0000047c <compare_schedules_chi_squared>:
    FIXED_POINT_BASE / 100 * 2612,
    FIXED_POINT_BASE / 100 * 2788,
    FIXED_POINT_BASE / 100 * 2959,
};

int compare_schedules_chi_squared(struct test_case *test) {
 47c:	55                   	push   %ebp
 47d:	89 e5                	mov    %esp,%ebp
 47f:	57                   	push   %edi
 480:	56                   	push   %esi
 481:	53                   	push   %ebx
 482:	83 ec 3c             	sub    $0x3c,%esp
 485:	8b 7d 08             	mov    0x8(%ebp),%edi
    if (test->num_children < 2) {
 488:	8b 47 0c             	mov    0xc(%edi),%eax
 48b:	89 45 dc             	mov    %eax,-0x24(%ebp)
 48e:	83 f8 01             	cmp    $0x1,%eax
 491:	0f 8e ab 01 00 00    	jle    642 <compare_schedules_chi_squared+0x1c6>
        return 1;
    }
    long long expect_schedules_total = 0;
    for (int i = 0; i < test->num_children; ++i) {
 497:	b9 00 00 00 00       	mov    $0x0,%ecx
    long long expect_schedules_total = 0;
 49c:	bb 00 00 00 00       	mov    $0x0,%ebx
 4a1:	be 00 00 00 00       	mov    $0x0,%esi
 4a6:	eb 0f                	jmp    4b7 <compare_schedules_chi_squared+0x3b>
        expect_schedules_total += test->expect_schedules_unscaled[i];
 4a8:	8b 84 8f 90 00 00 00 	mov    0x90(%edi,%ecx,4),%eax
 4af:	99                   	cltd   
 4b0:	01 c3                	add    %eax,%ebx
 4b2:	11 d6                	adc    %edx,%esi
    for (int i = 0; i < test->num_children; ++i) {
 4b4:	83 c1 01             	add    $0x1,%ecx
 4b7:	39 4d dc             	cmp    %ecx,-0x24(%ebp)
 4ba:	7f ec                	jg     4a8 <compare_schedules_chi_squared+0x2c>
       a better solution would be to use a statistical test that can handle this case,
       like Fisher's exact test.
    */
    long long delta = 0;
    int skipped = 0;
    for (int i = 0; i < test->num_children; ++i) {
 4bc:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 4bf:	89 75 d4             	mov    %esi,-0x2c(%ebp)
 4c2:	be 00 00 00 00       	mov    $0x0,%esi
    int skipped = 0;
 4c7:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
    long long delta = 0;
 4ce:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
 4d5:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
 4dc:	eb 19                	jmp    4f7 <compare_schedules_chi_squared+0x7b>
            (int)(scaled_expected >> FIXED_POINT_COUNT),
            (int) expect_schedules_total,
            test->total_actual_schedules);
#endif
        if (scaled_expected == 0) {
            ++skipped;
 4de:	83 45 c4 01          	addl   $0x1,-0x3c(%ebp)
            continue;
 4e2:	eb 10                	jmp    4f4 <compare_schedules_chi_squared+0x78>
        if (scaled_expected > 0) {
            // cur_delta <<= FIXED_POINT_COUNT;
            cur_delta /= scaled_expected;
        } else {
            /* a huge number to make sure statistical test fails */
            cur_delta = FIXED_POINT_BASE * 100000LL;
 4e4:	b8 00 80 1a 06       	mov    $0x61a8000,%eax
 4e9:	ba 00 00 00 00       	mov    $0x0,%edx
        }
#ifdef DEBUG
        printf(1, "cur_delta = %x/%x\n", (int) cur_delta, (int) (cur_delta >> 32));
#endif
        delta += cur_delta;
 4ee:	01 45 c8             	add    %eax,-0x38(%ebp)
 4f1:	11 55 cc             	adc    %edx,-0x34(%ebp)
    for (int i = 0; i < test->num_children; ++i) {
 4f4:	83 c6 01             	add    $0x1,%esi
 4f7:	39 75 dc             	cmp    %esi,-0x24(%ebp)
 4fa:	0f 8e 9e 00 00 00    	jle    59e <compare_schedules_chi_squared+0x122>
        long long scaled_expected = (test->expect_schedules_unscaled[i] << FIXED_POINT_COUNT) / expect_schedules_total
 500:	8b 84 b7 90 00 00 00 	mov    0x90(%edi,%esi,4),%eax
 507:	c1 e0 0a             	shl    $0xa,%eax
 50a:	99                   	cltd   
 50b:	ff 75 d4             	push   -0x2c(%ebp)
 50e:	ff 75 d0             	push   -0x30(%ebp)
 511:	52                   	push   %edx
 512:	50                   	push   %eax
 513:	e8 e8 07 00 00       	call   d00 <__divdi3>
 518:	83 c4 10             	add    $0x10,%esp
 51b:	89 45 d8             	mov    %eax,-0x28(%ebp)
                             * test->total_actual_schedules;
 51e:	8b 9f 90 01 00 00    	mov    0x190(%edi),%ebx
 524:	89 5d e0             	mov    %ebx,-0x20(%ebp)
 527:	c1 fb 1f             	sar    $0x1f,%ebx
        long long scaled_expected = (test->expect_schedules_unscaled[i] << FIXED_POINT_COUNT) / expect_schedules_total
 52a:	89 d0                	mov    %edx,%eax
 52c:	0f af 45 e0          	imul   -0x20(%ebp),%eax
 530:	89 d9                	mov    %ebx,%ecx
 532:	8b 5d d8             	mov    -0x28(%ebp),%ebx
 535:	0f af cb             	imul   %ebx,%ecx
 538:	01 c1                	add    %eax,%ecx
 53a:	89 d8                	mov    %ebx,%eax
 53c:	f7 65 e0             	mull   -0x20(%ebp)
 53f:	89 45 e0             	mov    %eax,-0x20(%ebp)
 542:	89 55 e4             	mov    %edx,-0x1c(%ebp)
 545:	01 4d e4             	add    %ecx,-0x1c(%ebp)
        if (scaled_expected == 0) {
 548:	8b 45 e0             	mov    -0x20(%ebp),%eax
 54b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 54e:	89 d3                	mov    %edx,%ebx
 550:	09 c3                	or     %eax,%ebx
 552:	74 8a                	je     4de <compare_schedules_chi_squared+0x62>
        long long cur_delta = scaled_expected - (test->actual_schedules[i] << FIXED_POINT_COUNT);
 554:	8b 84 b7 10 01 00 00 	mov    0x110(%edi,%esi,4),%eax
 55b:	c1 e0 0a             	shl    $0xa,%eax
 55e:	99                   	cltd   
 55f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 562:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
 565:	29 c1                	sub    %eax,%ecx
 567:	19 d3                	sbb    %edx,%ebx
 569:	89 c8                	mov    %ecx,%eax
        cur_delta *= cur_delta;
 56b:	0f af d9             	imul   %ecx,%ebx
 56e:	01 db                	add    %ebx,%ebx
 570:	f7 e1                	mul    %ecx
 572:	89 d1                	mov    %edx,%ecx
 574:	89 c2                	mov    %eax,%edx
 576:	01 d9                	add    %ebx,%ecx
        if (scaled_expected > 0) {
 578:	b8 00 00 00 00       	mov    $0x0,%eax
 57d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
 580:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
 583:	0f 8d 5b ff ff ff    	jge    4e4 <compare_schedules_chi_squared+0x68>
            cur_delta /= scaled_expected;
 589:	ff 75 e4             	push   -0x1c(%ebp)
 58c:	ff 75 e0             	push   -0x20(%ebp)
 58f:	51                   	push   %ecx
 590:	52                   	push   %edx
 591:	e8 6a 07 00 00       	call   d00 <__divdi3>
 596:	83 c4 10             	add    $0x10,%esp
 599:	e9 50 ff ff ff       	jmp    4ee <compare_schedules_chi_squared+0x72>
    }
#ifdef DEBUG
    printf(1, "%s test statistic %d (rounded)\n", test->name, (int) ((delta + FIXED_POINT_BASE / 2) >> FIXED_POINT_COUNT));
#endif
    int degrees_of_freedom = test->num_children - 1 - skipped;
 59e:	8b 45 dc             	mov    -0x24(%ebp),%eax
 5a1:	83 e8 01             	sub    $0x1,%eax
 5a4:	2b 45 c4             	sub    -0x3c(%ebp),%eax
    long long expected_value = chi_squared_thresholds[degrees_of_freedom - 1];
 5a7:	83 e8 01             	sub    $0x1,%eax
 5aa:	8b 14 c5 c0 14 00 00 	mov    0x14c0(,%eax,8),%edx
 5b1:	89 55 e0             	mov    %edx,-0x20(%ebp)
 5b4:	8b 34 c5 c4 14 00 00 	mov    0x14c4(,%eax,8),%esi
    int passed_threshold = delta < expected_value;
 5bb:	bb 01 00 00 00       	mov    $0x1,%ebx
 5c0:	89 d1                	mov    %edx,%ecx
 5c2:	8b 45 c8             	mov    -0x38(%ebp),%eax
 5c5:	8b 55 cc             	mov    -0x34(%ebp),%edx
 5c8:	39 c8                	cmp    %ecx,%eax
 5ca:	89 d0                	mov    %edx,%eax
 5cc:	19 f0                	sbb    %esi,%eax
 5ce:	7c 05                	jl     5d5 <compare_schedules_chi_squared+0x159>
 5d0:	bb 00 00 00 00       	mov    $0x0,%ebx
 5d5:	0f b6 db             	movzbl %bl,%ebx
    check(test, passed_threshold,
 5d8:	83 ec 04             	sub    $0x4,%esp
 5db:	68 30 11 00 00       	push   $0x1130
 5e0:	53                   	push   %ebx
 5e1:	57                   	push   %edi
 5e2:	e8 93 fb ff ff       	call   17a <check>
          "distribution of schedules run passed chi-squared test "
          "for being same as expected");
    if (!passed_threshold) {
 5e7:	83 c4 10             	add    $0x10,%esp
 5ea:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 5ed:	8b 45 c8             	mov    -0x38(%ebp),%eax
 5f0:	8b 55 cc             	mov    -0x34(%ebp),%edx
 5f3:	39 c8                	cmp    %ecx,%eax
 5f5:	89 d0                	mov    %edx,%eax
 5f7:	19 f0                	sbb    %esi,%eax
 5f9:	7d 39                	jge    634 <compare_schedules_chi_squared+0x1b8>
        dump_test_timings(test);
    }
    check(test, test->total_actual_schedules >
 5fb:	8b 97 90 01 00 00    	mov    0x190(%edi),%edx
                (test->override_min_schedules == 0 ? MIN_SCHEDULES : test->override_min_schedules),
 601:	8b 87 14 02 00 00    	mov    0x214(%edi),%eax
 607:	85 c0                	test   %eax,%eax
 609:	75 05                	jne    610 <compare_schedules_chi_squared+0x194>
 60b:	b8 d0 07 00 00       	mov    $0x7d0,%eax
    check(test, test->total_actual_schedules >
 610:	83 ec 04             	sub    $0x4,%esp
 613:	68 84 11 00 00       	push   $0x1184
 618:	39 c2                	cmp    %eax,%edx
 61a:	0f 9f c0             	setg   %al
 61d:	0f b6 c0             	movzbl %al,%eax
 620:	50                   	push   %eax
 621:	57                   	push   %edi
 622:	e8 53 fb ff ff       	call   17a <check>
          "threads scheduled enough times to get significant sample\n"
          "if you are properly recording times_scheduled, then this might\n"
          "just mean that SLEEP_TIME in lotterytest.c should be increased\n"
          "to get a larger sample");
    return passed_threshold;
 627:	83 c4 10             	add    $0x10,%esp
}
 62a:	89 d8                	mov    %ebx,%eax
 62c:	8d 65 f4             	lea    -0xc(%ebp),%esp
 62f:	5b                   	pop    %ebx
 630:	5e                   	pop    %esi
 631:	5f                   	pop    %edi
 632:	5d                   	pop    %ebp
 633:	c3                   	ret    
        dump_test_timings(test);
 634:	83 ec 0c             	sub    $0xc,%esp
 637:	57                   	push   %edi
 638:	e8 64 fd ff ff       	call   3a1 <dump_test_timings>
 63d:	83 c4 10             	add    $0x10,%esp
 640:	eb b9                	jmp    5fb <compare_schedules_chi_squared+0x17f>
        return 1;
 642:	bb 01 00 00 00       	mov    $0x1,%ebx
 647:	eb e1                	jmp    62a <compare_schedules_chi_squared+0x1ae>

00000649 <compare_schedules_naive>:

   This hopefully will detect cases where a biased random
   number generator is in use but otherwise the implementation
   is generally okay.
 */
void compare_schedules_naive(struct test_case *test) {
 649:	55                   	push   %ebp
 64a:	89 e5                	mov    %esp,%ebp
 64c:	57                   	push   %edi
 64d:	56                   	push   %esi
 64e:	53                   	push   %ebx
 64f:	83 ec 2c             	sub    $0x2c,%esp
    if (test->num_children < 2) {
 652:	8b 45 08             	mov    0x8(%ebp),%eax
 655:	8b 48 0c             	mov    0xc(%eax),%ecx
 658:	89 4d d0             	mov    %ecx,-0x30(%ebp)
 65b:	83 f9 01             	cmp    $0x1,%ecx
 65e:	0f 8e 17 02 00 00    	jle    87b <compare_schedules_naive+0x232>
        return;
    }
    int expect_schedules_total = 0;
    for (int i = 0; i < test->num_children; ++i) {
 664:	b8 00 00 00 00       	mov    $0x0,%eax
    int expect_schedules_total = 0;
 669:	ba 00 00 00 00       	mov    $0x0,%edx
 66e:	8b 5d 08             	mov    0x8(%ebp),%ebx
 671:	eb 0a                	jmp    67d <compare_schedules_naive+0x34>
        expect_schedules_total += test->expect_schedules_unscaled[i];
 673:	03 94 83 90 00 00 00 	add    0x90(%ebx,%eax,4),%edx
    for (int i = 0; i < test->num_children; ++i) {
 67a:	83 c0 01             	add    $0x1,%eax
 67d:	39 c1                	cmp    %eax,%ecx
 67f:	7f f2                	jg     673 <compare_schedules_naive+0x2a>
    }
    int failed_any = 0;
    for (int i = 0; i < test->num_children; ++i) {
 681:	89 55 cc             	mov    %edx,-0x34(%ebp)
 684:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    int failed_any = 0;
 68b:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
 692:	eb 0b                	jmp    69f <compare_schedules_naive+0x56>
        long long scaled_expected = ((long long) test->expect_schedules_unscaled[i] * test->total_actual_schedules) / expect_schedules_total;
        int max_expected = scaled_expected * 11 / 10 + 10;
        int min_expected = scaled_expected * 9 / 10 - 10;
        int in_range = (test->actual_schedules[i] >= min_expected && test->actual_schedules[i] <= max_expected);
        if (!in_range) {
            failed_any = 1;
 694:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
    for (int i = 0; i < test->num_children; ++i) {
 69b:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 69f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 6a2:	39 7d d0             	cmp    %edi,-0x30(%ebp)
 6a5:	0f 8e b0 01 00 00    	jle    85b <compare_schedules_naive+0x212>
        long long scaled_expected = ((long long) test->expect_schedules_unscaled[i] * test->total_actual_schedules) / expect_schedules_total;
 6ab:	8b 7d 08             	mov    0x8(%ebp),%edi
 6ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6b1:	8b 94 87 90 00 00 00 	mov    0x90(%edi,%eax,4),%edx
 6b8:	89 d3                	mov    %edx,%ebx
 6ba:	c1 fb 1f             	sar    $0x1f,%ebx
 6bd:	8b 87 90 01 00 00    	mov    0x190(%edi),%eax
 6c3:	89 c7                	mov    %eax,%edi
 6c5:	c1 ff 1f             	sar    $0x1f,%edi
 6c8:	89 d9                	mov    %ebx,%ecx
 6ca:	0f af c8             	imul   %eax,%ecx
 6cd:	89 fb                	mov    %edi,%ebx
 6cf:	0f af da             	imul   %edx,%ebx
 6d2:	01 d9                	add    %ebx,%ecx
 6d4:	f7 e2                	mul    %edx
 6d6:	01 ca                	add    %ecx,%edx
 6d8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
 6db:	89 cb                	mov    %ecx,%ebx
 6dd:	c1 fb 1f             	sar    $0x1f,%ebx
 6e0:	53                   	push   %ebx
 6e1:	51                   	push   %ecx
 6e2:	52                   	push   %edx
 6e3:	50                   	push   %eax
 6e4:	e8 17 06 00 00       	call   d00 <__divdi3>
 6e9:	83 c4 10             	add    $0x10,%esp
 6ec:	89 c6                	mov    %eax,%esi
        int max_expected = scaled_expected * 11 / 10 + 10;
 6ee:	89 55 d8             	mov    %edx,-0x28(%ebp)
 6f1:	6b ca 0b             	imul   $0xb,%edx,%ecx
 6f4:	bb 0b 00 00 00       	mov    $0xb,%ebx
 6f9:	89 d8                	mov    %ebx,%eax
 6fb:	89 75 dc             	mov    %esi,-0x24(%ebp)
 6fe:	f7 e6                	mul    %esi
 700:	89 c6                	mov    %eax,%esi
 702:	89 d7                	mov    %edx,%edi
 704:	01 cf                	add    %ecx,%edi
 706:	89 f8                	mov    %edi,%eax
 708:	c1 f8 1f             	sar    $0x1f,%eax
 70b:	89 45 e0             	mov    %eax,-0x20(%ebp)
 70e:	83 e0 03             	and    $0x3,%eax
 711:	89 f2                	mov    %esi,%edx
 713:	81 e2 ff ff ff 0f    	and    $0xfffffff,%edx
 719:	89 f1                	mov    %esi,%ecx
 71b:	89 fb                	mov    %edi,%ebx
 71d:	0f ac d9 1c          	shrd   $0x1c,%ebx,%ecx
 721:	c1 eb 1c             	shr    $0x1c,%ebx
 724:	81 e1 ff ff ff 0f    	and    $0xfffffff,%ecx
 72a:	01 d1                	add    %edx,%ecx
 72c:	89 fa                	mov    %edi,%edx
 72e:	c1 ea 18             	shr    $0x18,%edx
 731:	01 d1                	add    %edx,%ecx
 733:	01 c1                	add    %eax,%ecx
 735:	b8 cd cc cc cc       	mov    $0xcccccccd,%eax
 73a:	f7 e1                	mul    %ecx
 73c:	89 d3                	mov    %edx,%ebx
 73e:	c1 eb 02             	shr    $0x2,%ebx
 741:	81 e2 fc ff ff 7f    	and    $0x7ffffffc,%edx
 747:	01 da                	add    %ebx,%edx
 749:	29 d1                	sub    %edx,%ecx
 74b:	8b 45 e0             	mov    -0x20(%ebp),%eax
 74e:	83 e0 fc             	and    $0xfffffffc,%eax
 751:	01 c8                	add    %ecx,%eax
 753:	89 c1                	mov    %eax,%ecx
 755:	89 c3                	mov    %eax,%ebx
 757:	c1 fb 1f             	sar    $0x1f,%ebx
 75a:	89 f0                	mov    %esi,%eax
 75c:	89 fa                	mov    %edi,%edx
 75e:	29 c8                	sub    %ecx,%eax
 760:	19 da                	sbb    %ebx,%edx
 762:	69 ca cd cc cc cc    	imul   $0xcccccccd,%edx,%ecx
 768:	69 d0 cc cc cc cc    	imul   $0xcccccccc,%eax,%edx
 76e:	01 d1                	add    %edx,%ecx
 770:	bb cd cc cc cc       	mov    $0xcccccccd,%ebx
 775:	f7 e3                	mul    %ebx
 777:	01 ca                	add    %ecx,%edx
 779:	89 d1                	mov    %edx,%ecx
 77b:	c1 e9 1f             	shr    $0x1f,%ecx
 77e:	bb 00 00 00 00       	mov    $0x0,%ebx
 783:	01 c1                	add    %eax,%ecx
 785:	11 d3                	adc    %edx,%ebx
 787:	0f ac d9 01          	shrd   $0x1,%ebx,%ecx
 78b:	d1 fb                	sar    %ebx
 78d:	8d 51 0a             	lea    0xa(%ecx),%edx
 790:	89 55 d4             	mov    %edx,-0x2c(%ebp)
        int min_expected = scaled_expected * 9 / 10 - 10;
 793:	6b 4d d8 09          	imul   $0x9,-0x28(%ebp),%ecx
 797:	bf 09 00 00 00       	mov    $0x9,%edi
 79c:	89 f8                	mov    %edi,%eax
 79e:	f7 65 dc             	mull   -0x24(%ebp)
 7a1:	89 c6                	mov    %eax,%esi
 7a3:	89 d7                	mov    %edx,%edi
 7a5:	01 cf                	add    %ecx,%edi
 7a7:	89 f8                	mov    %edi,%eax
 7a9:	c1 f8 1f             	sar    $0x1f,%eax
 7ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
 7af:	83 e0 03             	and    $0x3,%eax
 7b2:	89 f2                	mov    %esi,%edx
 7b4:	81 e2 ff ff ff 0f    	and    $0xfffffff,%edx
 7ba:	89 f1                	mov    %esi,%ecx
 7bc:	89 fb                	mov    %edi,%ebx
 7be:	0f ac d9 1c          	shrd   $0x1c,%ebx,%ecx
 7c2:	c1 eb 1c             	shr    $0x1c,%ebx
 7c5:	81 e1 ff ff ff 0f    	and    $0xfffffff,%ecx
 7cb:	01 d1                	add    %edx,%ecx
 7cd:	89 fa                	mov    %edi,%edx
 7cf:	c1 ea 18             	shr    $0x18,%edx
 7d2:	01 d1                	add    %edx,%ecx
 7d4:	01 c1                	add    %eax,%ecx
 7d6:	b8 cd cc cc cc       	mov    $0xcccccccd,%eax
 7db:	f7 e1                	mul    %ecx
 7dd:	89 d3                	mov    %edx,%ebx
 7df:	c1 eb 02             	shr    $0x2,%ebx
 7e2:	81 e2 fc ff ff 7f    	and    $0x7ffffffc,%edx
 7e8:	01 da                	add    %ebx,%edx
 7ea:	29 d1                	sub    %edx,%ecx
 7ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
 7ef:	83 e0 fc             	and    $0xfffffffc,%eax
 7f2:	01 c8                	add    %ecx,%eax
 7f4:	89 c1                	mov    %eax,%ecx
 7f6:	89 c3                	mov    %eax,%ebx
 7f8:	c1 fb 1f             	sar    $0x1f,%ebx
 7fb:	89 f0                	mov    %esi,%eax
 7fd:	89 fa                	mov    %edi,%edx
 7ff:	29 c8                	sub    %ecx,%eax
 801:	19 da                	sbb    %ebx,%edx
 803:	69 ca cd cc cc cc    	imul   $0xcccccccd,%edx,%ecx
 809:	69 d0 cc cc cc cc    	imul   $0xcccccccc,%eax,%edx
 80f:	01 d1                	add    %edx,%ecx
 811:	bb cd cc cc cc       	mov    $0xcccccccd,%ebx
 816:	f7 e3                	mul    %ebx
 818:	01 ca                	add    %ecx,%edx
 81a:	89 d1                	mov    %edx,%ecx
 81c:	c1 e9 1f             	shr    $0x1f,%ecx
 81f:	bb 00 00 00 00       	mov    $0x0,%ebx
 824:	01 c1                	add    %eax,%ecx
 826:	11 d3                	adc    %edx,%ebx
 828:	0f ac d9 01          	shrd   $0x1,%ebx,%ecx
 82c:	d1 fb                	sar    %ebx
 82e:	83 e9 0a             	sub    $0xa,%ecx
        int in_range = (test->actual_schedules[i] >= min_expected && test->actual_schedules[i] <= max_expected);
 831:	8b 7d 08             	mov    0x8(%ebp),%edi
 834:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 837:	8b 84 87 10 01 00 00 	mov    0x110(%edi,%eax,4),%eax
 83e:	39 c8                	cmp    %ecx,%eax
 840:	0f 8c 4e fe ff ff    	jl     694 <compare_schedules_naive+0x4b>
 846:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
 849:	0f 8e 4c fe ff ff    	jle    69b <compare_schedules_naive+0x52>
            failed_any = 1;
 84f:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
 856:	e9 40 fe ff ff       	jmp    69b <compare_schedules_naive+0x52>
        }
    }
    check(test, !failed_any, "schedule counts within +/- 10% or +/- 10 of expected");
 85b:	83 ec 04             	sub    $0x4,%esp
 85e:	68 54 12 00 00       	push   $0x1254
 863:	8b 7d c8             	mov    -0x38(%ebp),%edi
 866:	89 f8                	mov    %edi,%eax
 868:	83 f0 01             	xor    $0x1,%eax
 86b:	50                   	push   %eax
 86c:	ff 75 08             	push   0x8(%ebp)
 86f:	e8 06 f9 ff ff       	call   17a <check>
    if (!failed_any) {
 874:	83 c4 10             	add    $0x10,%esp
 877:	85 ff                	test   %edi,%edi
 879:	74 08                	je     883 <compare_schedules_naive+0x23a>
        printf(1, "*** %s failed chi-squared test, but was w/in 10% of expected\n", test->name);
        printf(1, "*** a likely cause is bias in random number generation\n");
    }
}
 87b:	8d 65 f4             	lea    -0xc(%ebp),%esp
 87e:	5b                   	pop    %ebx
 87f:	5e                   	pop    %esi
 880:	5f                   	pop    %edi
 881:	5d                   	pop    %ebp
 882:	c3                   	ret    
        printf(1, "*** %s failed chi-squared test, but was w/in 10% of expected\n", test->name);
 883:	83 ec 04             	sub    $0x4,%esp
 886:	8b 45 08             	mov    0x8(%ebp),%eax
 889:	ff 30                	push   (%eax)
 88b:	68 8c 12 00 00       	push   $0x128c
 890:	6a 01                	push   $0x1
 892:	e8 f5 02 00 00       	call   b8c <printf>
        printf(1, "*** a likely cause is bias in random number generation\n");
 897:	83 c4 08             	add    $0x8,%esp
 89a:	68 cc 12 00 00       	push   $0x12cc
 89f:	6a 01                	push   $0x1
 8a1:	e8 e6 02 00 00       	call   b8c <printf>
 8a6:	83 c4 10             	add    $0x10,%esp
 8a9:	eb d0                	jmp    87b <compare_schedules_naive+0x232>

000008ab <run_test_case>:

void run_test_case(struct test_case* test) {
 8ab:	55                   	push   %ebp
 8ac:	89 e5                	mov    %esp,%ebp
 8ae:	53                   	push   %ebx
 8af:	81 ec 94 06 00 00    	sub    $0x694,%esp
 8b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
    int pids[MAX_CHILDREN];
    test->total_tests = test->errors = 0;
 8b8:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
 8bf:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
    struct processes_info before, after;
    execute_and_get_info(test, pids, &before, &after);
 8c6:	8d 85 70 f9 ff ff    	lea    -0x690(%ebp),%eax
 8cc:	50                   	push   %eax
 8cd:	8d 85 74 fc ff ff    	lea    -0x38c(%ebp),%eax
 8d3:	50                   	push   %eax
 8d4:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
 8da:	50                   	push   %eax
 8db:	53                   	push   %ebx
 8dc:	e8 d2 f8 ff ff       	call   1b3 <execute_and_get_info>
    check(test, 
          before.num_processes < NPROC && after.num_processes < NPROC &&
 8e1:	8b 85 74 fc ff ff    	mov    -0x38c(%ebp),%eax
    check(test, 
 8e7:	83 c4 10             	add    $0x10,%esp
 8ea:	83 f8 3f             	cmp    $0x3f,%eax
 8ed:	7f 29                	jg     918 <run_test_case+0x6d>
          before.num_processes < NPROC && after.num_processes < NPROC &&
 8ef:	8b 95 70 f9 ff ff    	mov    -0x690(%ebp),%edx
 8f5:	83 fa 3f             	cmp    $0x3f,%edx
 8f8:	0f 8f 86 00 00 00    	jg     984 <run_test_case+0xd9>
          before.num_processes > test->num_children && after.num_processes > test->num_children,
 8fe:	8b 4b 0c             	mov    0xc(%ebx),%ecx
          before.num_processes < NPROC && after.num_processes < NPROC &&
 901:	39 c8                	cmp    %ecx,%eax
 903:	0f 8e 82 00 00 00    	jle    98b <run_test_case+0xe0>
    check(test, 
 909:	39 ca                	cmp    %ecx,%edx
 90b:	0f 8f 81 00 00 00    	jg     992 <run_test_case+0xe7>
 911:	b8 00 00 00 00       	mov    $0x0,%eax
 916:	eb 05                	jmp    91d <run_test_case+0x72>
 918:	b8 00 00 00 00       	mov    $0x0,%eax
 91d:	83 ec 04             	sub    $0x4,%esp
 920:	68 04 13 00 00       	push   $0x1304
 925:	50                   	push   %eax
 926:	53                   	push   %ebx
 927:	e8 4e f8 ff ff       	call   17a <check>
          "getprocessesinfo returned a reasonable number of processes");
    count_schedules(test, pids, &before, &after);
 92c:	8d 85 70 f9 ff ff    	lea    -0x690(%ebp),%eax
 932:	50                   	push   %eax
 933:	8d 85 74 fc ff ff    	lea    -0x38c(%ebp),%eax
 939:	50                   	push   %eax
 93a:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
 940:	50                   	push   %eax
 941:	53                   	push   %ebx
 942:	e8 43 f9 ff ff       	call   28a <count_schedules>
    if (!compare_schedules_chi_squared(test)) {
 947:	83 c4 14             	add    $0x14,%esp
 94a:	53                   	push   %ebx
 94b:	e8 2c fb ff ff       	call   47c <compare_schedules_chi_squared>
 950:	83 c4 10             	add    $0x10,%esp
 953:	85 c0                	test   %eax,%eax
 955:	75 42                	jne    999 <run_test_case+0xee>
        compare_schedules_naive(test);
 957:	83 ec 0c             	sub    $0xc,%esp
 95a:	53                   	push   %ebx
 95b:	e8 e9 fc ff ff       	call   649 <compare_schedules_naive>
 960:	83 c4 10             	add    $0x10,%esp
    } else {
        check(test, 1, "assuming schedule counts approximately right given chi-squared test");
    }
    printf(1, "%s: passed %d of %d\n", test->name, test->total_tests - test->errors, test->total_tests);
 963:	8b 43 04             	mov    0x4(%ebx),%eax
 966:	83 ec 0c             	sub    $0xc,%esp
 969:	50                   	push   %eax
 96a:	2b 43 08             	sub    0x8(%ebx),%eax
 96d:	50                   	push   %eax
 96e:	ff 33                	push   (%ebx)
 970:	68 8c 0e 00 00       	push   $0xe8c
 975:	6a 01                	push   $0x1
 977:	e8 10 02 00 00       	call   b8c <printf>
}
 97c:	83 c4 20             	add    $0x20,%esp
 97f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 982:	c9                   	leave  
 983:	c3                   	ret    
    check(test, 
 984:	b8 00 00 00 00       	mov    $0x0,%eax
 989:	eb 92                	jmp    91d <run_test_case+0x72>
 98b:	b8 00 00 00 00       	mov    $0x0,%eax
 990:	eb 8b                	jmp    91d <run_test_case+0x72>
 992:	b8 01 00 00 00       	mov    $0x1,%eax
 997:	eb 84                	jmp    91d <run_test_case+0x72>
        check(test, 1, "assuming schedule counts approximately right given chi-squared test");
 999:	83 ec 04             	sub    $0x4,%esp
 99c:	68 40 13 00 00       	push   $0x1340
 9a1:	6a 01                	push   $0x1
 9a3:	53                   	push   %ebx
 9a4:	e8 d1 f7 ff ff       	call   17a <check>
 9a9:	83 c4 10             	add    $0x10,%esp
 9ac:	eb b5                	jmp    963 <run_test_case+0xb8>

000009ae <main>:

int main(int argc, char *argv[])
{
 9ae:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 9b2:	83 e4 f0             	and    $0xfffffff0,%esp
 9b5:	ff 71 fc             	push   -0x4(%ecx)
 9b8:	55                   	push   %ebp
 9b9:	89 e5                	mov    %esp,%ebp
 9bb:	57                   	push   %edi
 9bc:	56                   	push   %esi
 9bd:	53                   	push   %ebx
 9be:	51                   	push   %ecx
 9bf:	83 ec 18             	sub    $0x18,%esp
    int total_tests = 0;
    int passed_tests = 0;
    for (int i = 0; tests[i].name; ++i) {
 9c2:	be 00 00 00 00       	mov    $0x0,%esi
    int passed_tests = 0;
 9c7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    int total_tests = 0;
 9ce:	bf 00 00 00 00       	mov    $0x0,%edi
    for (int i = 0; tests[i].name; ++i) {
 9d3:	eb 26                	jmp    9fb <main+0x4d>
        struct test_case *test = &tests[i];
 9d5:	69 de 18 02 00 00    	imul   $0x218,%esi,%ebx
 9db:	81 c3 a0 15 00 00    	add    $0x15a0,%ebx
        run_test_case(test);
 9e1:	83 ec 0c             	sub    $0xc,%esp
 9e4:	53                   	push   %ebx
 9e5:	e8 c1 fe ff ff       	call   8ab <run_test_case>
        total_tests += test->total_tests;
 9ea:	8b 43 04             	mov    0x4(%ebx),%eax
 9ed:	01 c7                	add    %eax,%edi
        passed_tests += test->total_tests - test->errors;
 9ef:	2b 43 08             	sub    0x8(%ebx),%eax
 9f2:	01 45 e4             	add    %eax,-0x1c(%ebp)
    for (int i = 0; tests[i].name; ++i) {
 9f5:	83 c6 01             	add    $0x1,%esi
 9f8:	83 c4 10             	add    $0x10,%esp
 9fb:	69 c6 18 02 00 00    	imul   $0x218,%esi,%eax
 a01:	83 b8 a0 15 00 00 00 	cmpl   $0x0,0x15a0(%eax)
 a08:	75 cb                	jne    9d5 <main+0x27>
    }
    printf(1, "overall: passed %d of %d tests attempted\n", passed_tests, total_tests);
 a0a:	57                   	push   %edi
 a0b:	ff 75 e4             	push   -0x1c(%ebp)
 a0e:	68 84 13 00 00       	push   $0x1384
 a13:	6a 01                	push   $0x1
 a15:	e8 72 01 00 00       	call   b8c <printf>
    exit();
 a1a:	e8 08 00 00 00       	call   a27 <exit>

00000a1f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 a1f:	b8 01 00 00 00       	mov    $0x1,%eax
 a24:	cd 40                	int    $0x40
 a26:	c3                   	ret    

00000a27 <exit>:
SYSCALL(exit)
 a27:	b8 02 00 00 00       	mov    $0x2,%eax
 a2c:	cd 40                	int    $0x40
 a2e:	c3                   	ret    

00000a2f <wait>:
SYSCALL(wait)
 a2f:	b8 03 00 00 00       	mov    $0x3,%eax
 a34:	cd 40                	int    $0x40
 a36:	c3                   	ret    

00000a37 <pipe>:
SYSCALL(pipe)
 a37:	b8 04 00 00 00       	mov    $0x4,%eax
 a3c:	cd 40                	int    $0x40
 a3e:	c3                   	ret    

00000a3f <read>:
SYSCALL(read)
 a3f:	b8 05 00 00 00       	mov    $0x5,%eax
 a44:	cd 40                	int    $0x40
 a46:	c3                   	ret    

00000a47 <write>:
SYSCALL(write)
 a47:	b8 10 00 00 00       	mov    $0x10,%eax
 a4c:	cd 40                	int    $0x40
 a4e:	c3                   	ret    

00000a4f <close>:
SYSCALL(close)
 a4f:	b8 15 00 00 00       	mov    $0x15,%eax
 a54:	cd 40                	int    $0x40
 a56:	c3                   	ret    

00000a57 <kill>:
SYSCALL(kill)
 a57:	b8 06 00 00 00       	mov    $0x6,%eax
 a5c:	cd 40                	int    $0x40
 a5e:	c3                   	ret    

00000a5f <exec>:
SYSCALL(exec)
 a5f:	b8 07 00 00 00       	mov    $0x7,%eax
 a64:	cd 40                	int    $0x40
 a66:	c3                   	ret    

00000a67 <open>:
SYSCALL(open)
 a67:	b8 0f 00 00 00       	mov    $0xf,%eax
 a6c:	cd 40                	int    $0x40
 a6e:	c3                   	ret    

00000a6f <mknod>:
SYSCALL(mknod)
 a6f:	b8 11 00 00 00       	mov    $0x11,%eax
 a74:	cd 40                	int    $0x40
 a76:	c3                   	ret    

00000a77 <unlink>:
SYSCALL(unlink)
 a77:	b8 12 00 00 00       	mov    $0x12,%eax
 a7c:	cd 40                	int    $0x40
 a7e:	c3                   	ret    

00000a7f <fstat>:
SYSCALL(fstat)
 a7f:	b8 08 00 00 00       	mov    $0x8,%eax
 a84:	cd 40                	int    $0x40
 a86:	c3                   	ret    

00000a87 <link>:
SYSCALL(link)
 a87:	b8 13 00 00 00       	mov    $0x13,%eax
 a8c:	cd 40                	int    $0x40
 a8e:	c3                   	ret    

00000a8f <mkdir>:
SYSCALL(mkdir)
 a8f:	b8 14 00 00 00       	mov    $0x14,%eax
 a94:	cd 40                	int    $0x40
 a96:	c3                   	ret    

00000a97 <chdir>:
SYSCALL(chdir)
 a97:	b8 09 00 00 00       	mov    $0x9,%eax
 a9c:	cd 40                	int    $0x40
 a9e:	c3                   	ret    

00000a9f <dup>:
SYSCALL(dup)
 a9f:	b8 0a 00 00 00       	mov    $0xa,%eax
 aa4:	cd 40                	int    $0x40
 aa6:	c3                   	ret    

00000aa7 <getpid>:
SYSCALL(getpid)
 aa7:	b8 0b 00 00 00       	mov    $0xb,%eax
 aac:	cd 40                	int    $0x40
 aae:	c3                   	ret    

00000aaf <sbrk>:
SYSCALL(sbrk)
 aaf:	b8 0c 00 00 00       	mov    $0xc,%eax
 ab4:	cd 40                	int    $0x40
 ab6:	c3                   	ret    

00000ab7 <sleep>:
SYSCALL(sleep)
 ab7:	b8 0d 00 00 00       	mov    $0xd,%eax
 abc:	cd 40                	int    $0x40
 abe:	c3                   	ret    

00000abf <uptime>:
SYSCALL(uptime)
 abf:	b8 0e 00 00 00       	mov    $0xe,%eax
 ac4:	cd 40                	int    $0x40
 ac6:	c3                   	ret    

00000ac7 <yield>:
SYSCALL(yield)
 ac7:	b8 16 00 00 00       	mov    $0x16,%eax
 acc:	cd 40                	int    $0x40
 ace:	c3                   	ret    

00000acf <shutdown>:
SYSCALL(shutdown)
 acf:	b8 17 00 00 00       	mov    $0x17,%eax
 ad4:	cd 40                	int    $0x40
 ad6:	c3                   	ret    

00000ad7 <settickets>:
SYSCALL(settickets)
 ad7:	b8 18 00 00 00       	mov    $0x18,%eax
 adc:	cd 40                	int    $0x40
 ade:	c3                   	ret    

00000adf <getprocessesinfo>:
SYSCALL(getprocessesinfo)
 adf:	b8 19 00 00 00       	mov    $0x19,%eax
 ae4:	cd 40                	int    $0x40
 ae6:	c3                   	ret    

00000ae7 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 ae7:	55                   	push   %ebp
 ae8:	89 e5                	mov    %esp,%ebp
 aea:	83 ec 1c             	sub    $0x1c,%esp
 aed:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 af0:	6a 01                	push   $0x1
 af2:	8d 55 f4             	lea    -0xc(%ebp),%edx
 af5:	52                   	push   %edx
 af6:	50                   	push   %eax
 af7:	e8 4b ff ff ff       	call   a47 <write>
}
 afc:	83 c4 10             	add    $0x10,%esp
 aff:	c9                   	leave  
 b00:	c3                   	ret    

00000b01 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 b01:	55                   	push   %ebp
 b02:	89 e5                	mov    %esp,%ebp
 b04:	57                   	push   %edi
 b05:	56                   	push   %esi
 b06:	53                   	push   %ebx
 b07:	83 ec 2c             	sub    $0x2c,%esp
 b0a:	89 45 d0             	mov    %eax,-0x30(%ebp)
 b0d:	89 d0                	mov    %edx,%eax
 b0f:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 b11:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 b15:	0f 95 c1             	setne  %cl
 b18:	c1 ea 1f             	shr    $0x1f,%edx
 b1b:	84 d1                	test   %dl,%cl
 b1d:	74 44                	je     b63 <printint+0x62>
    neg = 1;
    x = -xx;
 b1f:	f7 d8                	neg    %eax
 b21:	89 c1                	mov    %eax,%ecx
    neg = 1;
 b23:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 b2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 b2f:	89 c8                	mov    %ecx,%eax
 b31:	ba 00 00 00 00       	mov    $0x0,%edx
 b36:	f7 f6                	div    %esi
 b38:	89 df                	mov    %ebx,%edi
 b3a:	83 c3 01             	add    $0x1,%ebx
 b3d:	0f b6 92 70 15 00 00 	movzbl 0x1570(%edx),%edx
 b44:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 b48:	89 ca                	mov    %ecx,%edx
 b4a:	89 c1                	mov    %eax,%ecx
 b4c:	39 d6                	cmp    %edx,%esi
 b4e:	76 df                	jbe    b2f <printint+0x2e>
  if(neg)
 b50:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 b54:	74 31                	je     b87 <printint+0x86>
    buf[i++] = '-';
 b56:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 b5b:	8d 5f 02             	lea    0x2(%edi),%ebx
 b5e:	8b 75 d0             	mov    -0x30(%ebp),%esi
 b61:	eb 17                	jmp    b7a <printint+0x79>
    x = xx;
 b63:	89 c1                	mov    %eax,%ecx
  neg = 0;
 b65:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 b6c:	eb bc                	jmp    b2a <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 b6e:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 b73:	89 f0                	mov    %esi,%eax
 b75:	e8 6d ff ff ff       	call   ae7 <putc>
  while(--i >= 0)
 b7a:	83 eb 01             	sub    $0x1,%ebx
 b7d:	79 ef                	jns    b6e <printint+0x6d>
}
 b7f:	83 c4 2c             	add    $0x2c,%esp
 b82:	5b                   	pop    %ebx
 b83:	5e                   	pop    %esi
 b84:	5f                   	pop    %edi
 b85:	5d                   	pop    %ebp
 b86:	c3                   	ret    
 b87:	8b 75 d0             	mov    -0x30(%ebp),%esi
 b8a:	eb ee                	jmp    b7a <printint+0x79>

00000b8c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 b8c:	55                   	push   %ebp
 b8d:	89 e5                	mov    %esp,%ebp
 b8f:	57                   	push   %edi
 b90:	56                   	push   %esi
 b91:	53                   	push   %ebx
 b92:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 b95:	8d 45 10             	lea    0x10(%ebp),%eax
 b98:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 b9b:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 ba0:	bb 00 00 00 00       	mov    $0x0,%ebx
 ba5:	eb 14                	jmp    bbb <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 ba7:	89 fa                	mov    %edi,%edx
 ba9:	8b 45 08             	mov    0x8(%ebp),%eax
 bac:	e8 36 ff ff ff       	call   ae7 <putc>
 bb1:	eb 05                	jmp    bb8 <printf+0x2c>
      }
    } else if(state == '%'){
 bb3:	83 fe 25             	cmp    $0x25,%esi
 bb6:	74 25                	je     bdd <printf+0x51>
  for(i = 0; fmt[i]; i++){
 bb8:	83 c3 01             	add    $0x1,%ebx
 bbb:	8b 45 0c             	mov    0xc(%ebp),%eax
 bbe:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 bc2:	84 c0                	test   %al,%al
 bc4:	0f 84 20 01 00 00    	je     cea <printf+0x15e>
    c = fmt[i] & 0xff;
 bca:	0f be f8             	movsbl %al,%edi
 bcd:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 bd0:	85 f6                	test   %esi,%esi
 bd2:	75 df                	jne    bb3 <printf+0x27>
      if(c == '%'){
 bd4:	83 f8 25             	cmp    $0x25,%eax
 bd7:	75 ce                	jne    ba7 <printf+0x1b>
        state = '%';
 bd9:	89 c6                	mov    %eax,%esi
 bdb:	eb db                	jmp    bb8 <printf+0x2c>
      if(c == 'd'){
 bdd:	83 f8 25             	cmp    $0x25,%eax
 be0:	0f 84 cf 00 00 00    	je     cb5 <printf+0x129>
 be6:	0f 8c dd 00 00 00    	jl     cc9 <printf+0x13d>
 bec:	83 f8 78             	cmp    $0x78,%eax
 bef:	0f 8f d4 00 00 00    	jg     cc9 <printf+0x13d>
 bf5:	83 f8 63             	cmp    $0x63,%eax
 bf8:	0f 8c cb 00 00 00    	jl     cc9 <printf+0x13d>
 bfe:	83 e8 63             	sub    $0x63,%eax
 c01:	83 f8 15             	cmp    $0x15,%eax
 c04:	0f 87 bf 00 00 00    	ja     cc9 <printf+0x13d>
 c0a:	ff 24 85 18 15 00 00 	jmp    *0x1518(,%eax,4)
        printint(fd, *ap, 10, 1);
 c11:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 c14:	8b 17                	mov    (%edi),%edx
 c16:	83 ec 0c             	sub    $0xc,%esp
 c19:	6a 01                	push   $0x1
 c1b:	b9 0a 00 00 00       	mov    $0xa,%ecx
 c20:	8b 45 08             	mov    0x8(%ebp),%eax
 c23:	e8 d9 fe ff ff       	call   b01 <printint>
        ap++;
 c28:	83 c7 04             	add    $0x4,%edi
 c2b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 c2e:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 c31:	be 00 00 00 00       	mov    $0x0,%esi
 c36:	eb 80                	jmp    bb8 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 c38:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 c3b:	8b 17                	mov    (%edi),%edx
 c3d:	83 ec 0c             	sub    $0xc,%esp
 c40:	6a 00                	push   $0x0
 c42:	b9 10 00 00 00       	mov    $0x10,%ecx
 c47:	8b 45 08             	mov    0x8(%ebp),%eax
 c4a:	e8 b2 fe ff ff       	call   b01 <printint>
        ap++;
 c4f:	83 c7 04             	add    $0x4,%edi
 c52:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 c55:	83 c4 10             	add    $0x10,%esp
      state = 0;
 c58:	be 00 00 00 00       	mov    $0x0,%esi
 c5d:	e9 56 ff ff ff       	jmp    bb8 <printf+0x2c>
        s = (char*)*ap;
 c62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 c65:	8b 30                	mov    (%eax),%esi
        ap++;
 c67:	83 c0 04             	add    $0x4,%eax
 c6a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 c6d:	85 f6                	test   %esi,%esi
 c6f:	75 15                	jne    c86 <printf+0xfa>
          s = "(null)";
 c71:	be 10 15 00 00       	mov    $0x1510,%esi
 c76:	eb 0e                	jmp    c86 <printf+0xfa>
          putc(fd, *s);
 c78:	0f be d2             	movsbl %dl,%edx
 c7b:	8b 45 08             	mov    0x8(%ebp),%eax
 c7e:	e8 64 fe ff ff       	call   ae7 <putc>
          s++;
 c83:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 c86:	0f b6 16             	movzbl (%esi),%edx
 c89:	84 d2                	test   %dl,%dl
 c8b:	75 eb                	jne    c78 <printf+0xec>
      state = 0;
 c8d:	be 00 00 00 00       	mov    $0x0,%esi
 c92:	e9 21 ff ff ff       	jmp    bb8 <printf+0x2c>
        putc(fd, *ap);
 c97:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 c9a:	0f be 17             	movsbl (%edi),%edx
 c9d:	8b 45 08             	mov    0x8(%ebp),%eax
 ca0:	e8 42 fe ff ff       	call   ae7 <putc>
        ap++;
 ca5:	83 c7 04             	add    $0x4,%edi
 ca8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 cab:	be 00 00 00 00       	mov    $0x0,%esi
 cb0:	e9 03 ff ff ff       	jmp    bb8 <printf+0x2c>
        putc(fd, c);
 cb5:	89 fa                	mov    %edi,%edx
 cb7:	8b 45 08             	mov    0x8(%ebp),%eax
 cba:	e8 28 fe ff ff       	call   ae7 <putc>
      state = 0;
 cbf:	be 00 00 00 00       	mov    $0x0,%esi
 cc4:	e9 ef fe ff ff       	jmp    bb8 <printf+0x2c>
        putc(fd, '%');
 cc9:	ba 25 00 00 00       	mov    $0x25,%edx
 cce:	8b 45 08             	mov    0x8(%ebp),%eax
 cd1:	e8 11 fe ff ff       	call   ae7 <putc>
        putc(fd, c);
 cd6:	89 fa                	mov    %edi,%edx
 cd8:	8b 45 08             	mov    0x8(%ebp),%eax
 cdb:	e8 07 fe ff ff       	call   ae7 <putc>
      state = 0;
 ce0:	be 00 00 00 00       	mov    $0x0,%esi
 ce5:	e9 ce fe ff ff       	jmp    bb8 <printf+0x2c>
    }
  }
}
 cea:	8d 65 f4             	lea    -0xc(%ebp),%esp
 ced:	5b                   	pop    %ebx
 cee:	5e                   	pop    %esi
 cef:	5f                   	pop    %edi
 cf0:	5d                   	pop    %ebp
 cf1:	c3                   	ret    
 cf2:	66 90                	xchg   %ax,%ax
 cf4:	66 90                	xchg   %ax,%ax
 cf6:	66 90                	xchg   %ax,%ax
 cf8:	66 90                	xchg   %ax,%ax
 cfa:	66 90                	xchg   %ax,%ax
 cfc:	66 90                	xchg   %ax,%ax
 cfe:	66 90                	xchg   %ax,%ax

00000d00 <__divdi3>:
 d00:	f3 0f 1e fb          	endbr32 
 d04:	55                   	push   %ebp
 d05:	57                   	push   %edi
 d06:	56                   	push   %esi
 d07:	53                   	push   %ebx
 d08:	83 ec 1c             	sub    $0x1c,%esp
 d0b:	8b 5c 24 34          	mov    0x34(%esp),%ebx
 d0f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
 d13:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
 d1a:	00 
 d1b:	8b 44 24 38          	mov    0x38(%esp),%eax
 d1f:	8b 54 24 3c          	mov    0x3c(%esp),%edx
 d23:	89 0c 24             	mov    %ecx,(%esp)
 d26:	89 dd                	mov    %ebx,%ebp
 d28:	89 5c 24 04          	mov    %ebx,0x4(%esp)
 d2c:	85 db                	test   %ebx,%ebx
 d2e:	79 18                	jns    d48 <__divdi3+0x48>
 d30:	f7 d9                	neg    %ecx
 d32:	c7 44 24 08 ff ff ff 	movl   $0xffffffff,0x8(%esp)
 d39:	ff 
 d3a:	83 d3 00             	adc    $0x0,%ebx
 d3d:	89 0c 24             	mov    %ecx,(%esp)
 d40:	f7 db                	neg    %ebx
 d42:	89 5c 24 04          	mov    %ebx,0x4(%esp)
 d46:	89 dd                	mov    %ebx,%ebp
 d48:	89 d3                	mov    %edx,%ebx
 d4a:	85 d2                	test   %edx,%edx
 d4c:	79 0d                	jns    d5b <__divdi3+0x5b>
 d4e:	f7 d8                	neg    %eax
 d50:	f7 54 24 08          	notl   0x8(%esp)
 d54:	83 d2 00             	adc    $0x0,%edx
 d57:	f7 da                	neg    %edx
 d59:	89 d3                	mov    %edx,%ebx
 d5b:	89 c7                	mov    %eax,%edi
 d5d:	8b 04 24             	mov    (%esp),%eax
 d60:	85 db                	test   %ebx,%ebx
 d62:	75 14                	jne    d78 <__divdi3+0x78>
 d64:	39 ef                	cmp    %ebp,%edi
 d66:	76 58                	jbe    dc0 <__divdi3+0xc0>
 d68:	89 ea                	mov    %ebp,%edx
 d6a:	31 f6                	xor    %esi,%esi
 d6c:	f7 f7                	div    %edi
 d6e:	89 c5                	mov    %eax,%ebp
 d70:	eb 0e                	jmp    d80 <__divdi3+0x80>
 d72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 d78:	39 eb                	cmp    %ebp,%ebx
 d7a:	76 24                	jbe    da0 <__divdi3+0xa0>
 d7c:	31 f6                	xor    %esi,%esi
 d7e:	31 ed                	xor    %ebp,%ebp
 d80:	8b 4c 24 08          	mov    0x8(%esp),%ecx
 d84:	89 e8                	mov    %ebp,%eax
 d86:	89 f2                	mov    %esi,%edx
 d88:	85 c9                	test   %ecx,%ecx
 d8a:	74 07                	je     d93 <__divdi3+0x93>
 d8c:	f7 d8                	neg    %eax
 d8e:	83 d2 00             	adc    $0x0,%edx
 d91:	f7 da                	neg    %edx
 d93:	83 c4 1c             	add    $0x1c,%esp
 d96:	5b                   	pop    %ebx
 d97:	5e                   	pop    %esi
 d98:	5f                   	pop    %edi
 d99:	5d                   	pop    %ebp
 d9a:	c3                   	ret    
 d9b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 d9f:	90                   	nop
 da0:	0f bd f3             	bsr    %ebx,%esi
 da3:	83 f6 1f             	xor    $0x1f,%esi
 da6:	75 38                	jne    de0 <__divdi3+0xe0>
 da8:	39 eb                	cmp    %ebp,%ebx
 daa:	72 07                	jb     db3 <__divdi3+0xb3>
 dac:	31 ed                	xor    %ebp,%ebp
 dae:	3b 3c 24             	cmp    (%esp),%edi
 db1:	77 cd                	ja     d80 <__divdi3+0x80>
 db3:	bd 01 00 00 00       	mov    $0x1,%ebp
 db8:	eb c6                	jmp    d80 <__divdi3+0x80>
 dba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 dc0:	85 ff                	test   %edi,%edi
 dc2:	75 0b                	jne    dcf <__divdi3+0xcf>
 dc4:	b8 01 00 00 00       	mov    $0x1,%eax
 dc9:	31 d2                	xor    %edx,%edx
 dcb:	f7 f3                	div    %ebx
 dcd:	89 c7                	mov    %eax,%edi
 dcf:	89 e8                	mov    %ebp,%eax
 dd1:	31 d2                	xor    %edx,%edx
 dd3:	f7 f7                	div    %edi
 dd5:	89 c6                	mov    %eax,%esi
 dd7:	8b 04 24             	mov    (%esp),%eax
 dda:	f7 f7                	div    %edi
 ddc:	89 c5                	mov    %eax,%ebp
 dde:	eb a0                	jmp    d80 <__divdi3+0x80>
 de0:	b8 20 00 00 00       	mov    $0x20,%eax
 de5:	89 f1                	mov    %esi,%ecx
 de7:	89 fa                	mov    %edi,%edx
 de9:	29 f0                	sub    %esi,%eax
 deb:	d3 e3                	shl    %cl,%ebx
 ded:	89 c1                	mov    %eax,%ecx
 def:	d3 ea                	shr    %cl,%edx
 df1:	89 f1                	mov    %esi,%ecx
 df3:	09 da                	or     %ebx,%edx
 df5:	d3 e7                	shl    %cl,%edi
 df7:	89 eb                	mov    %ebp,%ebx
 df9:	89 c1                	mov    %eax,%ecx
 dfb:	d3 eb                	shr    %cl,%ebx
 dfd:	89 54 24 0c          	mov    %edx,0xc(%esp)
 e01:	89 f1                	mov    %esi,%ecx
 e03:	8b 14 24             	mov    (%esp),%edx
 e06:	d3 e5                	shl    %cl,%ebp
 e08:	89 c1                	mov    %eax,%ecx
 e0a:	d3 ea                	shr    %cl,%edx
 e0c:	09 d5                	or     %edx,%ebp
 e0e:	89 da                	mov    %ebx,%edx
 e10:	89 e8                	mov    %ebp,%eax
 e12:	f7 74 24 0c          	divl   0xc(%esp)
 e16:	89 d3                	mov    %edx,%ebx
 e18:	89 c5                	mov    %eax,%ebp
 e1a:	f7 e7                	mul    %edi
 e1c:	39 d3                	cmp    %edx,%ebx
 e1e:	72 0f                	jb     e2f <__divdi3+0x12f>
 e20:	8b 3c 24             	mov    (%esp),%edi
 e23:	89 f1                	mov    %esi,%ecx
 e25:	d3 e7                	shl    %cl,%edi
 e27:	39 c7                	cmp    %eax,%edi
 e29:	73 07                	jae    e32 <__divdi3+0x132>
 e2b:	39 d3                	cmp    %edx,%ebx
 e2d:	75 03                	jne    e32 <__divdi3+0x132>
 e2f:	83 ed 01             	sub    $0x1,%ebp
 e32:	31 f6                	xor    %esi,%esi
 e34:	e9 47 ff ff ff       	jmp    d80 <__divdi3+0x80>
