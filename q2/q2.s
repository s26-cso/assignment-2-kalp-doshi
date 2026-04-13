.text
    .globl main
 
main:
    addi    sp, sp, -48
    sd      ra, 40(sp)
    sd      s0, 32(sp)
    sd      s1, 24(sp)
    sd      s2, 16(sp)
    sd      s3, 8(sp)
    sd      s4, 0(sp)
 
    
    addi    s0, a0, -1        # s0 = n = argc - 1
    mv      s1, a1              # s1 = argv
 
    #allocate arr[n], result[n], stack[n] 
    # each element is 8 bytes 
    slli    t0, s0, 3         # t0 = n * 8
 
    mv      a0, t0
    call    malloc
    mv      s2, a0              # s2 = arr[]
 
    mv      a0, t0
    call    malloc
    mv      s3, a0               # s3 = result[]
 
    mv      a0, t0
    call    malloc
    mv      s4, a0              # s4 = stack[]
 
    #parse 
    li      s6, 0                # i = 0
parse_loop:
    bge     s6, s0, parse_done
 
    slli    t0, s6, 3            # offset = i * 8
    addi    t1, s6, 1               # argv index = i + 1
    slli    t1, t1, 3           # byte offset into argv
    add     t1, s1, t1
    ld      a0, 0(t1)           # a0 = argv[i+1] (char*)
    call    atoi                # a0 = integer
    add     t0, s2, t0
    sd      a0, 0(t0)           # arr[i] = atoi(argv[i+1])
 
    addi    s6, s6, 1
    j       parse_loop
parse_done:
 
    #initialize result[] to -1
    li      s6, 0
init_result_loop:
    bge     s6, s0, init_result_done
    slli    t0, s6, 3
    add     t0, s3, t0
    li      t1, -1
    sd      t1, 0(t0)           # result[i] = -1
    addi    s6, s6, 1
    j       init_result_loop
init_result_done:
 
    #stack pointer s5 = -1
    li      s5, -1
 
    #main algorithm, i from n-1 down to 0
    addi    s6, s0, -1          # i = n - 1
algo_loop:
    blt     s6, zero, algo_done
 
    #while stack not empty and arr[stack.top()] <= arr[i], pop
while_loop:
    blt     s5, zero, while_done        # stack empty -> exit while
 
    # load arr[i]
    slli    t0, s6, 3
    add     t0, s2, t0
    ld      t0, 0(t0)                   # t0 = arr[i]
 
    # load arr[stack.top()]
    slli    t1, s5, 3
    add     t1, s4, t1
    ld      t1, 0(t1)                   #t1 = index stored at top of stack
    slli    t1, t1, 3
    add     t1, s2, t1
    ld      t1, 0(t1)                 # t1 = arr[stack.top()]
 
    bgt     t1, t0, while_done          # arr[top] > arr[i] -> stop popping
    addi    s5, s5, -1                  # pop: decrement stack top
    j       while_loop
while_done:
 
    #if stack not empty: result[i] = stack.top()
    blt     s5, zero, skip_update       # stack empty -> result[i] stays -1
 
    slli    t1, s5, 3
    add     t1, s4, t1
    ld      t1, 0(t1)                   # t1 = stack.top() 
 
    slli    t0, s6, 3
    add     t0, s3, t0
    sd      t1, 0(t0)                   # result[i] = stack.top()
skip_update:
 
    #push(i): increment top, store i
    addi    s5, s5, 1
    slli    t0, s5, 3
    add     t0, s4, t0
    sd      s6, 0(t0)                   # stack[s5] = i
 
    addi    s6, s6, -1                  # i--
    j       algo_loop
algo_done:
 
    #print result[]
    addi    sp, sp, -16
    sd      s5, 8(sp)
    sd      s6, 0(sp)
 
    li      s6, 0                       # i = 0
print_loop:
    bge     s6, s0, print_done
 
    slli    t0, s6, 3
    add     t0, s3, t0
    ld      a0, 0(t0)                   a0 = result[i]
    call    print_int
 
    #print space after every element except the last
    addi    t0, s6, 1
    bge     t0, s0, no_space
    li      a0, ' '
    call    putchar
no_space:
    addi    s6, s6, 1
    j       print_loop
print_done:
 
    li      a0, '\n'
    call    putchar
 
    ld      s5, 8(sp)
    ld      s6, 0(sp)
    addi    sp, sp, 16
 
    li      a0, 0                       # return 0
    ld      ra, 40(sp)
    ld      s0, 32(sp)
    ld      s1, 24(sp)
    ld      s2, 16(sp)
    ld      s3, 8(sp)
    ld      s4, 0(sp)
    addi    sp, sp, 48
    ret
 

print_int:
    addi    sp, sp, -48
    sd      ra, 40(sp)
    sd      s0, 32(sp)
    sd      s1, 24(sp)
    sd      s2, 16(sp)
 
    mv      s0, a0              # s0 = n
 
    # handle -1 and negative numbers
    bge     s0, zero, print_int_pos
    li      a0, '-'
    call    putchar
    neg     s0, s0
 
print_int_pos:
    # special case zero
    bne     s0, zero, digit_loop
    li      a0, '0'
    call    putchar
    j       print_int_done
 
    # build digits in reverse into buffer starting at sp+0
digit_loop:
    addi    s1, sp, 0           # buffer base
    li      s2, 0               # digit count
digit_loop_inner:
    beq     s0, zero, print_digits
    li      t0, 10
    rem     t1, s0, t0          # t1 = n % 10
    div     s0, s0, t0          # n  = n / 10
    addi    t1, t1, '0'
    add     t0, s1, s2
    sb      t1, 0(t0)           # buf[count] = digit
    addi    s2, s2, 1
    j       digit_loop_inner
 
print_digits:
    addi    s2, s2, -1          # point to last digit
print_digit_loop:
    blt     s2, zero, print_int_done
    add     t0, s1, s2
    lbu     a0, 0(t0)
    call    putchar
    addi    s2, s2, -1
    j       print_digit_loop
 
print_int_done:
    ld      ra, 40(sp)
    ld      s0, 32(sp)
    ld      s1, 24(sp)
    ld      s2, 16(sp)
    addi    sp, sp, 48
    ret