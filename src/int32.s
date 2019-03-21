  .intel_syntax noprefix

  .globl  _main                   ## -- Begin function main
  .p2align  4
_main:
  lea rax, _int32[rip]            ## module (_int32)
  mov rax, int32_type[rax]        ## int32.Integer(<bits: 32>)
  mov edi, 6
  mov esi, 3
  lea r8, main_end [rip]
  lea r9, zero [rip]
  jmp toPower[rax]
zero:
  mov al, -1
main_end:
  ret
                                  ## -- End function

_add:                               ## associative function
  add eax, edi
  jo add_overflow
  jmp r8
add_overflow:
  jmp r9

_null:
  cmp edi, 0
  jne null_is_not
  jmp r8
null_is_not:
  jmp r9

_successor:
  mov eax, edi
  add eax, 1
  jo successor_overflow
  jmp r8
successor_overflow:
  jmp r9

_predecessor:
  mov eax, edi
  sub eax, 1
  jo predecessor_underflow
  jmp r8
predecessor_underflow:
  jmp r9

_magnitude:
  mov eax, edi
  cdq                             ## sign extend into edx
  xor eax, edx                    ## complement if negative
  sub eax, edx                    ## 2's complement by adding one if negative
  jmp r8

_multiply:                        ## associative function
  imul eax, edi
  jo times_overflow
  jmp r8
times_overflow:
  jmp r9

_minus:
  mov eax, edi
  sub eax, esi
  jo minus_overflow
  jmp r8
minus_overflow:
  jmp r9
  
_over:
  cmp esi, 0
  je over_dividebyzero
  mov eax, edi
  cdq                                   ## expand eax to edx:eax
  idiv esi                              ## result in eax, remainder in edx
  jmp r8
over_dividebyzero:
  jmp r9

_modulo:
  mov rcx, r8
  lea r8, modulo_end [rip]
  jmp _over                             ## note: assumes rcx is preserved
modulo_end:
  mov eax, edx
  jmp rcx

_opposite:
  mov esi, edi
  mov edi, 0
  jmp _minus

_greaterThan:
  cmp edi, esi
  jle greaterThan_not
  jmp r8
greaterThan_not:
  jmp r9

_greaterOrEqual:
  cmp edi, esi
  jl greaterOrEqual_not
  jmp r8
greaterOrEqual_not:
  jmp r9

_lessThan:
  cmp edi, esi
  jge lessThan_not
  jmp r8
lessThan_not:
  jmp r9

_lessOrEqual:
  cmp edi, esi
  jg lessOrEqual_not
  jmp r8
lessOrEqual_not:
  jmp r9


  ## toPower algorithm:
  ## 0 ** n = 0
  ## 1 ** n = 1
  ## x ** 0 = 1
  ## decompose the exponent n in powers of two
  ## for each factor k, x ** n = product( x ** k )
  ## so we can square x until we get the answer 
  ## example: 3 ** 5 = (3 ** 1) * (3 ** 4)
  ##                 = 3 * ((3 * 3) * (3 * 3))
  ##                 = 243
  r =0
_toPower:
  mov eax, 0
  cmp edi, 0
  je toPower_success                ## shortcut if arg1 = 0
  mov eax, 1
  cmp edi, 1
  je toPower_success                ## shortcut if arg1 = 1
  cmp esi, 0
  je toPower_success                ## shortcut if arg2 = 0
  jl toPower_failed                 ## cannot do negative numbers
  push r8                           ## save return continuation
  push r9                           ## save event continuation
  sub rsp, 010
  mov dword ptr r[rsp], 1           ## calculation results
  lea rcx, produceSquares [rip]     ## generator -> rcx
  mov rdx, rsp                      ## stack pointer -> rdx
  push rdi                          ## pass x to generator
  push rsi                          ## pass n to generator
toPower_loop:
  mov rdi, rdx                      ## stack pointer -> rdi
  lea r8, toPower_next [rip]
  lea r9, toPower_done [rip]
  lea r10, toPower_overflow [rip]
  jmp rcx                           ## generate next value
toPower_next:
  mov rcx, r8                       ## generator -> rcx
  mov rdx, rdi                      ## stack pointer -> rdx
  mov edi, dword ptr r[rdx]         ## r -> edi
  lea r8, toPower2 [rip]
  jmp _multiply                     ## r * generated value -- note: assumes rcx and rdx are preserved
toPower2:
  mov dword ptr r[rdx], eax         ## save r
  jmp toPower_loop
toPower_done:
  pop rax
  pop r9
  pop r8
toPower_success:
  jmp r8 
toPower_overflow:
  pop rax
  pop r9
  pop r8
toPower_failed:
  jmp r9

  ## Generator for the squares used in _toPower
  x             =050
  n             =040
  yield         =030
  end           =020
  overflow      =010
  stackp        =0
produceSquares:
  sub rsp, 040                    ## allocate stack for 4 values
  mov yield[rsp],   r8
  mov end[rsp],     r9
  mov overflow[rsp],r10
  mov stackp[rsp],  rdi
  mov rax, x[rsp]
  mov rdx, n[rsp]
prodSquares_loop:
  test edx, 1                     ## n & 1
  jz prodSquares_next
  mov x[rsp], rax
  mov n[rsp], rdx
  mov rdi, stackp[rsp]
  mov esi, eax                    ## x -> esi
  lea r8, prodSquares1 [rip]
  lea r9, prodSquares_end [rip]
  jmp yield[rsp]                  ## yield x
prodSquares1:
  mov yield[rsp], r8
  mov end[rsp], r9
  mov overflow[rsp], r10
  mov stackp[rsp], rdi
  mov rax, x[rsp]
  mov rdx, n[rsp]
prodSquares_next:
  shr edx, 1                      ## n >>= 1
  jz prodSquares_end
  mov edi, eax                    ## copy x -> edi
  lea r8, prodSquares_loop [rip]
  lea r9, prodSquares_overflow [rip]
  jmp _multiply                   ## square x -- note: assumes edx is preserved
prodSquares_end:
  mov r9, end[rsp]
  mov rsp, stackp[rsp]            ## restore caller stack pointer
  jmp r9
prodSquares_overflow:
  mov r10, overflow[rsp]
  mov rsp, stackp[rsp]            ## restore caller stack pointer
  jmp r10
  
_instance:
  mov eax, int32_proto[eax]
  jmp r8

_type:
  mov eax, int32_type[eax]
  jmp r8

  .data
  .globl _int32
_int32:
  int32_proto   =0
  int32_type    =010
  .long 0
  .zero 4
  .quad _Integer_bits_32
  
_Integer_bits_32:
  module        =0
  meta          =010
  instance      =020
  size          =030
  add           =040
  null          =050
  nil           =060
  multiply      =070
  minus         =0100
  over          =0110
  toPower       =0120
  opposite      =0130
  magnitude     =0140
  unit          =0150
  successor     =0160
  predecessor   =0170
  modulo        =0200
  greaterThan   =0210
  greaterOrEqual=0220
  lessThan      =0230
  lessOrEqual   =0240
Type:
  .quad _int32                ## module
  .quad _Integer_bits_32_meta ## metatype
  .quad _instance
  .quad 4                     ## size
Integer:
Augmentable:
  .quad _add
  .quad _null
  .long 0                     ## nil
  .zero 4                     ## 4 bytes padding
Arithmetic:
  .quad _multiply
  .quad _minus
  .quad _over
  .quad _toPower
  .quad _opposite
  .quad _magnitude
  .long 1                     ## unit
  .zero 4                     ## 4 bytes padding
Enumerable:
  .quad _successor
  .quad _predecessor
  .quad _modulo
Ordered:
  .quad _greaterThan
  .quad _greaterOrEqual
  .quad _lessThan
  .quad _lessOrEqual
Integer_bits_32_end:

_Integer_bits_32_meta:
  .quad _int32                ## module
  .quad 0                     ## metatype (TODO)
  .quad _type                 ## instance
  .quad (Integer_bits_32_end - _Integer_bits_32)  ## size
Type_offset:
  .quad 0
Integer_offset:
  .quad (Integer - _Integer_bits_32)
Augmentable_offset:
  .quad (Augmentable - _Integer_bits_32)
Arithmetic_offset:
  .quad (Arithmetic - _Integer_bits_32)
Enumerable_offset:
  .quad (Enumerable - _Integer_bits_32)
Ordered_offset:
  .quad (Ordered - _Integer_bits_32)

