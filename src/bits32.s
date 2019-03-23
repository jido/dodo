  .intel_syntax noprefix

  .globl  _main
  .p2align  4
_main:
  mov rdi, rsp
  mov eax, 0x8
  push rax
  lea r8, main_next [rip]
  lea r9, main_end [rip]
  jmp _value
main_next:
  mov rcx, r8
  lea r8, main_next2 [rip]
  lea r9, main_end [rip]
  jmp rcx
main_next2:
  mov rcx, r9
  lea r9, main_end [rip]
  jmp rcx
main_end:
  ret


_union:                               ## associative function
	or eax, edi
  jmp r8

_intersection:                        ## associative function
  and eax, edi
  jmp r8

_complement:
  mov eax, edi
  not eax
  jmp r8

_delta:                               ## associative function
  xor eax, edi
  jmp r8

_get:                                 ## precondition: esi is a bit value in the range 1...2**31
  mov eax, esi
  and eax, edi
  jmp r8
  
_contains:                            ## precondition: esi is a bit value in the range 1...2**31
  test edi, esi
  jz contains_not
  jmp r8
contains_not:
  jmp r9

_indexOf:                             ## precondition: esi is a bit value in the range 1...2**31
  test edi, esi
  jz indexOf_unknown
  mov eax, esi
  jmp r8
indexOf_unknown:
  jmp r9
 
_indices:
  mov eax, 0xffffffff
  push rax
  jmp _value
   
_strictSubsetOf:                      ## true if all bits of b1 belong to b2, but not the other way around
  cmp edi, esi
  je strictSubsetOf_not
  jmp _subsetOf
strictSubsetOf_not:
  jmp r9

_subsetOf:                            ## true if all bits of b1 belong to b2
  mov eax, edi
  and eax, esi
  cmp eax, edi
  jne subsetOf_not
  jmp r8
subsetOf_not:
  jmp r9

_strictSupersetOf:                    ## true if all bits of b2 belong to b1, but not the other way around
  cmp edi, esi
  je strictSupersetOf_not
  jmp _supersetOf
strictSupersetOf_not:
  jmp r9
  
_supersetOf:                          ## true if all bits of b2 belong to b1
  mov eax, edi
  or eax, esi
  cmp eax, edi
  jne supersetOf_not
  jmp r8
supersetOf_not:
  jmp r9

_disjoint:                            ## true if there are no bits in common between b1 and b2
  test edi, esi
  jnz disjoint_not
  jmp r8
disjoint_not:
  jmp r9

_void:
  cmp edi, 0
  jne void_not
  jmp r8
void_not:
  jmp r9

_shiftLeft:
  mov eax, edi
  mov cl, sil
  shl eax, cl
  jmp r8

_shiftRight:
  mov eax, edi
  mov cl, sil
  shr eax, cl
  jmp r8

_shiftRightFill:
  mov eax, edi
  mov cl, sil
  sar eax, cl
  jmp r9

_rotateLeft:
  mov eax, edi
  mov cl, sil
  rol esi, cl
  jmp r8

_rotateRight:
  mov eax, edi
  mov cl, sil
  ror eax, cl
  jmp r8

_value:                                 ## yields the value of the bits in the input
  sub rsp, 010
  mov rcx, 010[rsp]
  mov eax, 1
  jmp value_test
value_loop:
  shl eax, 1
  jz value_end
value_test:
  test ecx, eax
  jz value_loop
  mov [rsp], rax
  mov rcx, r8
  lea r8, value_next [rip]
  lea r9, value_end [rip]
  jmp rcx
value_next:
  mov rax, [rsp]
  mov rcx, 010[rsp]
  jmp value_loop
value_end:
  mov rsp, rdi
  jmp r9
  