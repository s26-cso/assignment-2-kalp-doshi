# q1.s — Binary Search Tree in RISC-V Assembly
# Struct Node { int val; struct Node* left; struct Node* right; }
# Memory layout (64-bit):
#   offset  0 : val   (4 bytes, int)
#   offset  4 : padding (4 bytes)
#   offset  8 : left  (8 bytes, pointer)
#   offset 16 : right (8 bytes, pointer)
#   total      : 24 bytes
 
    .text
 
# ─────────────────────────────────────────────────────────────
# struct Node* make_node(int val)
#   a0 = val (input), returns pointer to new node in a0
# ─────────────────────────────────────────────────────────────
    .globl make_node
make_node:
    #clearing space in stack
    addi  sp, sp, -16
    sd  ra, 8(sp)       #because we will call malloc
    sd  s0, 0(sp)
    
    mv  s0, a0       #saving values

    li  a0, 24      #giving arg for malloc
    call  malloc     #a0 = pointer to the new space (the node)

    sw  s0, 0(a0)    #node->val = val
    sd  zero, 8(a0)     #node->left = null
    sd  zero, 16(a0)    #node->right = null

    ld  ra, 8(sp)
    ld  s0, 0(sp)
    addi  sp, sp, 16    #restioring stack
    ret

    .globl insert
insert:
    addi  sp, sp, -32
    sd  ra, 24(sp)
    sd  s0, 16(sp)  #s0 = current root
    sd  s1, 8(sp)   #s1 = value

    mv  s0, a0
    mv  s1, a1

    #base case:
    bne  s0, zero, insert_normal    #doesnt branch if root == null
    mv  a0, s1          
    call  make_node     #creating the newnode
    j   insert_done

insert_normal:
    lw  t0, 0(s0)   #t0 = root->val
    bge s1, t0, insert_right    #if val >= root->val, go rright

insert_left:
    ld  a0, 0(s0) #a0 = root->left
    mv  a1, s1
    call  insert    #insert in left subtree
    sd  a0, 8(s0)   #root->left = result
    mv  a0, s0
    j   insert_done

insert_right:
    beq  s1, t0, insert_equal     # if val == rot->val
    ld  a0, 16(sp)          #a0 = root->right
    call  insert          #insert into right subtree
    sd  a0, 16(s0)      #root->right = result
    mv  a0, s0
    j   insert_done

insert_equal:
    mv  a0, s0

insert_done:
    ld  ra, 24(sp)
    ld  s0, 16(sp)
    ld  s1, 8(sp)
    addi    sp, sp, 32
    ret

    .global get
get:
    #base case
    beq  a0, zero, get_done

    lw      t0, 0(a0)           # t0 = root->val
    beq     a1, t0, get_done    # found it — return current node (a0)
 
    blt     a1, t0, get_left    # val < root->val → go left
 
get_right:
    ld      a0, 16(a0)        # a0 = root->right
    j       get                 # tail call
 
get_left:
    ld      a0, 8(a0)            # a0 = root->left
    j       get                 # tail call
 
get_done:
    ret

globl getAtMost
getAtMost:
    addi    sp, sp, -32
    sd      ra, 24(sp)
    sd      s0, 16(sp)        # s0 = val (the query)
    sd      s1, 8(sp)           # s1 = root
    sd      s2, 0(sp)         # s2 = best answer so far
 
    mv      s0, a0
    mv      s1, a1
    li      s2, -1              # default answer = -1
 
    call    getAtMost_helper    # result in a0
 
    ld      ra, 24(sp)
    ld      s0, 16(sp)
    ld      s1, 8(sp)
    ld      s2, 0(sp)
    addi    sp, sp, 32
    ret

getAtMost_helper:
    addi    sp, sp, -16
    sd      ra, 8(sp)
    sd      s1, 0(sp)
 
    # Base case: if we've reached a null node, return the best value found so far
    beq     s1, zero, getAtMost_return_best
 
    lw      t0, 0(s1)           # Load the current node's value
 
    # If current node's value exceeds query, search only the left subtree
    bgt     t0, s0, getAtMost_go_left
 
    # Current node's value is within range, consider it as a candidate answer
    # Update best only if this value is better than what we have
    bgt     t0, s2, getAtMost_update
    j       getAtMost_after_update
 
getAtMost_update:
    # Found a better answer, update best
    mv      s2, t0
 
getAtMost_after_update:
    # Now search the right subtree for larger values that still meet the query
    ld      s1, 16(s1)          # Move to right child
    call    getAtMost_helper
    j       getAtMost_helper_done
 
getAtMost_go_left:
    # Search the left subtree for values within range
    ld      s1, 8(s1)           # Move to left child
    call    getAtMost_helper
    j       getAtMost_helper_done
 
getAtMost_return_best:
    mv      a0, s2
 
getAtMost_helper_done:
    mv      a0, s2
    ld      ra, 8(sp)
    ld      s1, 0(sp)
    addi    sp, sp, 16
    ret