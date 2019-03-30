  .intel_syntax noprefix

  .globl  _main
  .p2align  4
_main:
  mov rbx, rsp                        ## save stack pointer
  lea rax, _array[rip]
  mov rcx, metatype[rax]
  sub rsp, size[rcx]                  ## allocate stack space for _Array_template
  lea rdi, _int32[rip]
  mov rdi, 010[rdi]                   ## _Integer_bits_32
  mov rsi, 5
  lea r8, main_next[rip]
  lea r9, main_end[rip]
  jmp make[rax]                       ## create an instance of Array(<itemType: Integer(<bits: 32>), size: 5>)
main_next:
  mov rax, rsp
  mov r12, rax                        ## save address of array type
  sub rsp, size[rax]                  ## allocate stack space for an array
  mov dword ptr [rsp], 19
  mov dword ptr 4[rsp], 22
  mov dword ptr 8[rsp], 56
  mov dword ptr 12[rsp], 99
  mov dword ptr 16[rsp], 107
  mov rdi, rsp
  mov rsi, 2
  sub rsp, 020                        ## allocate stack space for a 3-item array of int32
  lea r8, main_items[rip]
  lea r9, main_end[rip]
  jmp shiftLeft[rax]
main_items:
  mov rax, r12
  mov rdi, rsp
  push rsp                            ## address of array
  lea r8, main_value[rip]
  lea r9, main_end[rip]
  jmp value[rax]                      ## first item
main_value:
  mov rcx, r8
  lea r8, main_value2[rip]
  lea r9, main_end[rip]
  jmp rcx                             ## second item
main_value2:
  mov rcx, r9
  lea r9, main_end[rip]
  jmp rcx                             ## unwind generator
main_end:
  mov rsp, rbx                        ## restore stack pointer
  ret

_get:                                 ## precondition: rsi is a number in the range 1...arraySize
  cmp rsi, 0
  jle get_outofbounds
  cmp rsi, arraySize[rax]
  jg get_outofbounds
  mov rdx, itemType[rax]
  mov rdx, size[rdx]                  ## TODO: size > 8
  dec rsi
  imul rsi, rdx
  mov rcx, rsi
  and rsi, 0xfffffffffffffff8L        ## 8 bytes alignment
  mov rax, [rdi + rsi]
  and rcx, 7                          ## offset
  shl rcx, 3
  shr rax, cl                         ## shift the item to lower bits of rax
  mov rsi, 1
  mov rcx, rdx                        ## item size
  shl rcx, 3
  shl rsi, cl
  dec rsi                             ## bitmask = (1 << bitsize) - 1
  and rax, rsi
  jmp r8
get_outofbounds:
  jmp r9

_contains:
_indexOf:
indexOf_unknown:
  jmp r9

_count:
  mov rax, arraySize[rax]
  jmp r8

  ## Generator for the indices of the array that is 1...arraySize 
  last    =010
  current =0
_indices:
  sub rsp, 020
  mov rcx, arraySize[rax]
  mov last[rsp], rcx                ## save array size
  mov rax, 1
indices_loop:
  cmp rax, last[rsp]
  jg indices_end                    ## end yield if current index > array size
  mov current[rsp], rax
  mov rcx, r8
  lea r8, indices_next[rip]
  lea r9, indices_end[rip]
  jmp rcx                           ## yield current index
indices_next:
  mov rax, current[rsp]
  inc rax
  jmp indices_loop
indices_end:
  mov rsp, rdi                      ## restore stack pointer
  jmp r9


  ## copy(dest, source, times, bytes)
copy:
  mov rax, rcx
copy_loop:
  cld
  rep movsb
  cmp rdx, 1
  jle copy_end
  dec rdx
  mov rcx, rax
  sub rsi, rcx
  jmp copy_loop
copy_end:
  jmp r8

_shiftLeft:                         ## precondition: rsi is a number in the range 1...arraySize
  cmp rsi, 0
  jle shiftLeft_end
  mov r10, arraySize[rax]
  cmp rsi, r10
  jg shiftLeft_end
  mov rcx, itemType[rax]
  mov rcx, size[rcx]                ## item size
  mov rdx, rsi                      ## shift by that many items
  imul rdx, rcx                     ## amplitude of shift in bytes
  mov rsi, rdi
  add rsi, rdx                      ## source address
  mov rdi, rsp                      ## destination address
  imul rcx, r10                     ## array size in bytes
  sub rcx, rdx                      ## remaining bytes (keepers)
  mov rdx, 1                        ## no repetition
  mov r9, r8                        ## note: not used by copy
  lea r8, shiftLeft_end[rip]
  jmp copy
shiftLeft_end:
  jmp r9

_shiftRight:                        ## precondition: rsi is a number in the range 1...arraySize
  array =040
  itype =030
  event =020
  return=010
  shift =0
  cmp rsi, 0
  jle shiftRight_end
  mov r10, arraySize[rax]
  cmp rsi, r10
  jg shiftRight_end
  sub rsp, array
  mov shift[rsp], rsi
  mov return[rsp], r8
  mov event[rsp], r9
  mov rcx, itemType[rax]
  mov itype[rsp], rcx
  mov rcx, size[rcx]                ## item size
  imul rsi, rcx                     ## amplitude of shift in bytes
  imul rcx, r10                     ## number of bytes to copy
  mov rdx, 1                        ## no repetition
  xchg rsi, rdi                     ## source address -> rsi
  lea rdi, array[rsp + rdi]         ## destination address
  lea r8, shiftRight_zero[rip]
  jmp copy
shiftRight_zero:
  mov rax, itype[rsp]
  lea r8, shiftRight_fill[rip]
  lea r9, shiftRight_badItem[rip]
  jmp instance[rax]
shiftRight_fill:
  mov rsi, rax                      ## default value of item type
  lea rdi, array[rsp]               ## destination address
  mov rdx, shift[rsp]
  mov rcx, itype[rsp]
  mov rcx, size[rcx]
  mov r9, return[rsp]               ## note: not used by copy
  add rsp, array                    ## restore stack pointer
  lea r8, shiftRight_end[rip]
  jmp copy                          ## fill first items with default value
shiftRight_badItem:
  mov r9, event[rsp]
  add rsp, array                    ## restore stack pointer
shiftRight_end:
  jmp r9

_shiftRightFill:                    ## precondition: rsi is a number in the range 1...arraySize
  cmp rsi, 0
  jle shiftRightFill_end
  mov r10, arraySize[rax]
  cmp rsi, r10
  jg shiftRightFill_end
  mov rdx, rsi                      ## shift by that many items
  inc rdx                           ## copy first item one time extra
  mov rsi, rdi                      ## first item of the array
  mov rdi, rsp                      ## destination address
  mov rcx, itemType[rax]
  mov rcx, size[rcx]                ## item size
  dec r10                           ## take out first item
  imul r10, rcx
  mov r9, r8                        ## note: not used by copy
  lea r8, shiftRightFill_main[rip]
  jmp copy
shiftRightFill_main:
  mov rdx, 1                        ## no repetition
  mov rcx, r10                      ## number of bytes to copy
  lea r8, shiftRightFill_end[rip]
  jmp copy
shiftRightFill_end:
  jmp r9

_rotateLeft:
  jmp r9

_rotateRight:
  jmp r9

  ## Generator yielding the value of the items in the array
  array =020
  atype =010
  index =0
_value:
  sub rsp, 020
  mov atype[rsp], rax
  mov rcx, 0
value_loop:
  cmp rcx, arraySize[rax]
  jge value_end
  mov index[rsp], rcx
  mov rdx, itemType[rax]
  imul rcx, size[rdx]
  mov rax, array[rsp]
  add rax, rcx
  mov rax, [rax]
  mov rcx, r8
  lea r8, value_next[rip]
  lea r9, value_end[rip]
  jmp rcx
value_next:
  mov rax, atype[rsp]
  mov rcx, index[rsp]
  inc rcx
  jmp value_loop
value_end:
  mov rsp, rdi
  jmp r9

_instance:
  jmp r9

_type:
  jmp r9

_new_Array_itemType_size:
  mov rdx, rdi
  mov r10, rsi
  lea rsi, _Array_template[rip]
  mov rdi, rsp
  mov rcx, metatype[rax]
  mov rcx, size[rcx]
  shr rcx, 3
  cld
  rep movsq
  mov itemType[rsp], rdx
  mov rdx, size[rdx]
  mov arraySize[rsp], r10
  imul r10, rdx
  dec r10
  and r10, 0xfffffffffffffff8L
  add r10, 8
  mov size[rsp], r10
  jmp r8

  .data
  .globl _array
_array:
  make      =0
  metatype  =010
  .quad _new_Array_itemType_size
  .quad _Array_template_meta

_Array_template:
  module          =0
  meta            =010
  instance        =020
  size            =030
  itemType        =040
  arraySize       =050
  get             =060
  contains        =070
  indexOf         =0100
  count           =0110
  indices         =0120
  shiftLeft       =0130
  shiftRight      =0140
  shiftRightFill  =0150
  rotateLeft      =0160
  rotateRight     =0170
  value           =0200
  constantSpace   =0210
Type:
  .quad _array                ## module
  .quad _Array_template_meta  ## metatype
  .quad _instance
  .quad 0                     ## size
Array:
  .quad 0
  .quad 0
Indexed:
  .quad _get
  .quad _contains
  .quad _indexOf
  .quad _count
  .quad _indices
Iterable:
  .quad _shiftLeft
  .quad _shiftRight
  .quad _shiftRightFill
  .quad _rotateLeft
  .quad _rotateRight
  .quad _value
  .byte 0
  .zero 7                     ## 7 bytes padding
Array_template_end:

_Array_template_meta:
  .quad _array                ## module
  .quad 0                     ## metatype (TODO)
  .quad _type                 ## instance
  .quad (Array_template_end - _Array_template)  ## size
Type_offset:
  .quad 0
Array_offset:
  .quad (Array - _Array_template)
Indexed_offset:
  .quad (Indexed - _Array_template)
Iterable_offset:
  .quad (Iterable - _Array_template)
Array_template_meta_end:
