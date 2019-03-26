  .intel_syntax noprefix

  .globl  _main
  .p2align  4
_main:
  lea rax, _Array_template[rip]
  mov rax, meta[rax]
  mov rbx, rsp                        ## save stack pointer
  sub rsp, size[rax]                  ## allocate stack space for _Array_template
  lea rdi, _int32[rip]
  mov rdi, 010[rdi]                   ## _Integer_bits_32
  mov rsi, 5
  lea r8, main_next[rip]
  lea r9, main_end[rip]
  jmp instance[rax]                   ## create an instance of Array(<itemType: Integer(<bits: 32>), size: 5>)
main_next:
  mov rax, rsp                        ## save address of array type
  sub rsp, size[rax]                  ## allocate stack space for an array
  mov dword ptr [rsp], 56
  mov dword ptr 4[rsp], 99
  mov rdi, rsp
  push rsp                            ## address of array
  lea r8, main_value[rip]
  jmp value[rax]                      ## first item
main_value:
  mov rcx, r8
  lea r8, main_value2[rip]
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
  mov rcx, itemType[rax]
  mov rcx, size[rcx]
  sub rsi, 1
  imul rsi, rcx
  mov rax, [rdi + rsi]
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
  add rax, 1
  jmp indices_loop
indices_end:
  mov rsp, rdi                      ## restore stack pointer
  jmp r9

  base  =030
  array =020
  shift =010
  return=0
_shiftLeft:                         ## precondition: rsi is a number in the range 1...arraySize
  cmp rsi, 0
  jle shiftLeft_invalid
  cmp rsi, arraySize[rax]
  jg shiftLeft_invalid
  sub rsp, 040
  mov base[rsp], rax
  mov array[rsp], rdi
  mov shift[rsp], rsi
  mov return[rsp], r8
  mov rax, itemType[rax]
  mov rdx, size[rax]
  cmp rdx, 16                       ## max item size 128 bits
  jg shiftLeft_badItem
  lea r8, shiftLeft_start[rip]
  lea r9, shiftLeft_badItem[rip]
  jmp instance[rax]                 ## get instance of item type
shiftLeft_start:
  mov rcx, shift[rsp]               ## shift by that many items
  mov r8, return[rsp]
  mov [rsp], rax                    ## save default value of item type
  mov 010[rsp], rdx
  mov rax, base[rsp]
  mov rdx, itemType[rax]
  mov rdx, size[rdx]                ## item size
  imul rcx, rdx                     ## number of bytes
  mov rsi, array[rsp]
  add rsi, rcx                      ## source address
  lea r10, 040[rsp]
  mov rdi, r10                      ## destination address
  cld
  rep movsb                         ## shift items
  mov rcx, rdx
  imul rcx, arraySize[rax]
  add r10, rcx                      ## end marker
shiftLeft_loop:
  mov rcx, rdx
  mov rsi, rsp
  rep movsb                         ## copy default item value to free slot in array
  cmp rdi, r10                      ## note: destination address is auto incremented
  jl shiftLeft_loop
  add rsp, 040
  jmp r8
shiftLeft_badItem:
  add rsp, 040
shiftLeft_invalid:
  jmp r9

_shiftRight:
  jmp r9

_shiftRightFill:
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
  add rcx, 1
  jmp value_loop
value_end:
  mov rsp, rdi
  jmp r9

_instance:
  jmp r9

_type:
  mov rdx, rdi
  mov r10, rsi
  lea rsi, _Array_template[rip]
  mov rdi, rsp
  lea rcx, _Array_template_meta[rip]
  mov rcx, size[rcx]
  shr rcx, 3
  cld
  rep movsq
  mov itemType[rsp], rdx
  mov rdx, size[rdx]
  mov arraySize[rsp], r10
  imul r10, rdx
  mov size[rsp], r10
  jmp r8

  .data
  .globl _array
_array:
  type =0
  .quad _Array_template

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
  .quad 4                     ## size
Array:
  .quad _int32 + 010
  .quad 5
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
  .byte 1
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
