  .intel_syntax noprefix

  .globl  _main
  .p2align  4
_main:
  mov rbx, rsp                        ## save stack pointer
  lea rax, _Array_template[rip]
  mov rcx, meta[rax]
  sub rsp, size[rcx]                  ## allocate stack space for _Array_template
  lea rdi, _int32[rip]
  mov rdi, 010[rdi]                   ## _Integer_bits_32
  mov rsi, 5
  lea r8, main_next[rip]
  lea r9, main_end[rip]
  jmp newArray[rax]                   ## create an instance of Array(<itemType: Integer(<bits: 32>), size: 5>)
main_next:
  mov rax, rsp
  mov r12, rax                        ## save address of array type
  sub rsp, size[rax]                  ## allocate stack space for an array
  mov dword ptr 8[rsp], 56
  mov dword ptr 12[rsp], 99
  mov dword ptr 16[rsp], 107
  sub rsp, size[rax]                  ## allocate stack space for an array
  lea rdi, 20[rsp]
  mov rsi, 2
  lea r8, main_items[rip]
  lea r9, main_end[rip]
  jmp _shiftLeft
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


  ## copy(dest, source, times, bytes)
copy:
  cld
  rep movsb
  cmp rdx, 1
  jle copy_end
  sub rdx, 1
  sub rsi, rcx
  jmp copy
copy_end:
  jmp r8

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
  mov rsi, rax                      ## default value of item type
  mov rax, base[rsp]
  mov r10, size[rax]                ## array size in bytes
  mov rax, itemType[rax]
  mov rcx, size[rax]                ## item size
  mov rdx, shift[rsp]               ## shift by that many items
  lea rdi, 040[rsp]
  mov r11, rdx
  imul r11, rcx                     ## amplitude of shift in bytes
  sub r10, r11                      ## remaining bytes (keepers)
  add rdi, r10                      ## at the end of the array
  lea r8, shiftLeft_main[rip]
  jmp copy
shiftLeft_main:
  mov rcx, r10                      ## number of bytes to copy
  mov rdx, 1                        ## no repetition
  mov rsi, array[rsp]
  add rsi, r11                      ## source address
  lea rdi, 040[rsp]                 ## destination address
  lea r8, shiftLeft_end[rip]
  jmp copy
shiftLeft_end:
  mov r9, return[rsp]
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
  jmp r9

_newArray:
  mov rdx, rdi
  mov r10, rsi
  mov rsi, rax    ##_Array_template[rip]
  mov rdi, rsp
  mov rcx, meta[rax]  ##_Array_template_meta[rip]
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
  newArray        =040
  itemType        =050
  arraySize       =060
  get             =070
  contains        =0100
  indexOf         =0110
  count           =0120
  indices         =0130
  shiftLeft       =0140
  shiftRight      =0150
  shiftRightFill  =0160
  rotateLeft      =0170
  rotateRight     =0200
  value           =0210
  constantSpace   =0220
Type:
  .quad _array                ## module
  .quad _Array_template_meta  ## metatype
  .quad _instance
  .quad 4                     ## size
Array:
  .quad _newArray
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
