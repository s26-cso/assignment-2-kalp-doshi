.text
    .globl main
 
main:
    addi    sp, sp, -32
    sd      ra, 24(sp)
    sd      s0, 16(sp)
    sd      s1, 8(sp)
    sd      s2, 0(sp)
 
    # fopen("input.txt", "r")
    la      a0, filename        # first arg:  "input.txt"
    la      a1, mode_r          # second arg: "r"
    call    fopen
    mv      s0, a0              # s0 = FILE*
 
    #find file size via fseek + ftell this will gie us N
    
    mv      a0, s0                # FILE*
    li      a1, 0               # offset = 0
    li      a2, 2               # SEEK_END = 2
    call    fseek
 
    # ftell
    mv      a0, s0
    call    ftell
    mv      s2, a0          # s2 = file size = right pointer
 
    # empty file? palindrome by convention, print Yes
    beq     s2, zero, print_yes
 
    addi    s2, s2, -1               # right = N-1
    li      s1, 0               # left  = 0
 
#two-pointer loop
check_loop:
    # if left >= right, done
    bge     s1, s2, print_yes
 
    # read char at left
    #fseek(fp, left, SEEK_SET) then fgetc(fp)
    mv      a0, s0
    mv      a1, s1               # offset = left
    li      a2, 0               # SEEK_SET = 0 (from the beginning)
    call    fseek
    mv      a0, s0
    call    fgetc
    mv      t0, a0               # t0 = left character
 
    # read char at right:
    #fseek(fp, right, SEEK_SET) then fgetc(fp)
    mv      a0, s0
    mv      a1, s2             # offset = right
    li      a2, 0               # SEEK_SET = 0
    call    fseek
    mv      a0, s0
    call    fgetc
    mv      t1, a0              # t1 = right character
 
    # mismatch? not a palindrome. Greyas was lying (liar).
    bne     t0, t1, print_no
 
    #squeeze the pointers inward
    addi    s1, s1, 1           # left++
    addi    s2, s2, -1          # right--
    j       check_loop
 
#Yes
print_yes:
    la      a0, msg_yes
    call    puts                
    j       done
 
#No
print_no:
    la      a0, msg_no
    call    puts
 
#close file and return
done:
    mv      a0, s0
    call    fclose
 
    li      a0, 0               # return 0
    ld      ra, 24(sp)
    ld      s0, 16(sp)
    ld      s1, 8(sp)
    ld      s2, 0(sp)
    addi    sp, sp, 32
    ret
 
#read-only strings
    .section .rodata
filename:
    .string "input.txt"
mode_r:
    .string "r"
msg_yes:
    .string "Yes"              
msg_no:
    .string "No"
 