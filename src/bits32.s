  .intel_syntax noprefix

  .globl  _main
  .p2align  4
_main:
  mov rdi, rsp
  lea r8, main_next[rip]
  lea r9, main_end[rip]
  jmp _indices                        ## first value
main_next:
  mov rcx, r8
  lea r8, main_next2[rip]
  lea r9, main_end[rip]
  jmp rcx                             ## second value
main_next2:
  mov rcx, r8
  lea r8, main_next3[rip]
  lea r9, main_end[rip]
  jmp rcx                             ## third value
main_next3:
  mov rcx, r9
  lea r9, main_end[rip]
  jmp rcx                             ## unwind generator
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
 
_count:
  popcnt eax, edi
  jmp r8
 
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

  ## Generator yielding the value of the bits in the input
  input =010
  bit =0
_value:
  sub rsp, 010
  mov rcx, input[rsp]
  mov eax, 1
  jmp value_test
value_loop:
  shl eax, 1
  jz value_end
value_test:
  test ecx, eax
  jz value_loop
  mov bit[rsp], rax
  mov rcx, r8
  lea r8, value_next[rip]
  lea r9, value_end[rip]
  jmp rcx
value_next:
  mov rax, bit[rsp]
  mov rcx, input[rsp]
  jmp value_loop
value_end:
  mov rsp, rdi
  jmp r9

_instance:
  lea rax, _int32[rip]                ## pull prototype value from _int32
  jmp r8

_type:
  lea rax, _bits32[rip]
  jmp r8

  .data
  .globl _bits32
_bits32:
  .quad _Bitset_size_32
  
_Bitset_size_32:
  module          =0
  meta            =010
  instance        =020
  size            =030
  union           =040
  intersection    =050
  complement      =060
  delta           =070
  get             =0100
  contains        =0110
  indexOf         =0120
  count           =0130
  indices         =0140
  strictSubsetOf  =0150
  subsetOf        =0160
  strictSupersetOf=0170
  supersetOf      =0200
  disjoint        =0210
  void            =0220
  nothing         =0230
  universe        =0234
  shiftLeft       =0240
  shiftRight      =0250
  shiftRightFill  =0260
  rotateLeft      =0270
  rotateRight     =0300
  value           =0310
  constantSpace   =0320
Type:
  .quad _bits32               ## module
  .quad _Bitset_size_32_meta  ## metatype
  .quad _instance
  .quad 4                     ## size
Bitset:
Logical:
  .quad _union
  .quad _intersection
  .quad _complement
  .quad _delta
Indexed:
  .quad _get
  .quad _contains
  .quad _indexOf
  .quad _count
  .quad _indices
Countable:
  .quad _strictSubsetOf
  .quad _subsetOf
  .quad _strictSupersetOf
  .quad _supersetOf
  .quad _disjoint
  .quad _void
  .long 0                     ## nothing
  .long 0xffffffff            ## universe
Iterable:
  .quad _shiftLeft
  .quad _shiftRight
  .quad _shiftRightFill
  .quad _rotateLeft
  .quad _rotateRight
  .quad _value
  .byte 1                     ## constantSpace
  .zero 7
Bitset_size_32_end:

_Bitset_size_32_meta:
  .quad _bits32               ## module
  .quad 0                     ## metatype (TODO)
  .quad _type                 ## instance
  .quad (Bitset_size_32_end - _Bitset_size_32)  ## size
Type_offset:
  .quad 0
Bitset_offset:
  .quad (Bitset - _Bitset_size_32)
Logical_offset:
  .quad (Logical - _Bitset_size_32)
Indexed_offset:
  .quad (Indexed - _Bitset_size_32)
Countable_offset:
  .quad (Countable - _Bitset_size_32)
Iterable_offset:
  .quad (Iterable - _Bitset_size_32)
Bitset_bits_32_meta_end:
