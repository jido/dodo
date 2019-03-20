# The dodo programming language

## The dodo calling convention

A function call is implemented as a jump to a label rather than a CALL instruction. The caller provides the address of a continuation to call when the function ends.

The following description applies to the Intel 64 bit platform.

### Standalone function call

Parameters are passed in registers RDI, RSI, RDX and RCX. Extra parameters or parameters too large for a register are passed on the stack.

Continuations are passed in registers R8, R9, R10 and R11. Extra continuations are passed on the stack.

Most functions have two continuations: the return continuation and the event continuation.

The module in which the function is defined, which is called function context, is passed in the RAX register.

The return value is stored in RDX:RAX. If the return value is too large for a pair of registers it is stored on the stack *before* the function parameters.

~~~
| stack
|
| [ return  ]
| [ value   ]
| -----------
| [ params  ]
| -----------
| [ contins ]
|
v
~~~

This means the caller must reserve enough space on stack for the largest possible return value (according to function signature) before the parameters.

The stack is truncated by the function to leave just the return value on stack before calling the return continuation.

Unless capabilities are involved, the function output may be memoised, reducing the number of calculations.

### Associative function calls

Associative functions always take two arguments of same type. The parameters are passed in RDX:RAX and RSI:RDI if they fit in a pair of registers, or on stack otherwise. The context is passed in the RBX register.

They are otherwise similar to standalone functions.

If an associative function is called with more than two parameters in the source file, then the function is called multiple times with the result of a function call used as argument until all parameters are consumed. The order of calls is not defined but the order of arguments is preserved.

### Generator (yielding function) call

For a generator there are two stack pointers to consider: the calling function stack (noted SP1) and the generator stack (noted SP2).

The calling function allocates the generator stack. Function parameters are stored on SP2 before the first call.

The return value is stored in RDX:RAX. If the return value is too large for a pair of registers it is stored in a reserved space on SP1.

~~~
    caller                      generator
|                            |
|                            | 
| [ return ]                 | [ params ]
| [ value  ]                 |
|                            |
v    SP1                     v    SP2
~~~

Continuations are passed in registers R8, R9, R10 and R11. Extra continuations are stored on SP2 each time the generator is called.

In general, a generator has three continuations: the yield continuation, the end continuation and the event continuation.

The calling function needs to set the stack pointer to SP2 before calling the generator. It passes SP1 in register RDI.

The stack pointer is not reset by the generator when yielding a value. The generator passes SP1 back to the calling function in register RDI.

The yielded value is stored in RDX:RAX or on SP1 as described above. The resume continuation is stored in register R8 and the unwind continuation in register R9.

When the generator ends or an event is raised, the generator sets the stack pointer back to SP1 and returns like a normal function.

### Member function calls

Member functions need access to the object which they are applied to.

The object without type information is passed as hidden first parameter in register RDI.

The object type is passed as function context. A function context holds a reference to its parent context in first position. The parent context is the scope where the object type is defined, which can be a module or another type.

~~~
 context
 
[ &scope ]
[--------]
[  type  ]
~~~

### Constructor and method calls

Constructors and member methods receive the master capability as implicit first argument via the RDI register.

A method receives the object it is applied to in register RSI as a hidden second parameter.

The function context is the method type in case of a method and the type by same name in case of a constructor.

A method parent context is the type where the method is defined.

~~~
   context

[   &type   ]
[-----------]
[ meth.type ]
~~~

Unless the method defines attributes, a method return value is empty except for a private reference to the object it was applied to.

## Memory layout of objects

### Polymorphic objects

The object is comprised of a reference to its class, and the object value or object reference depending on size. If the object value is no larger than a pointer then it is stored directly.

~~~
  object                       object

[ &class  ]        or       [  &class  ]
[---------]                 [----------]
[ obj.val ]                 [ &obj.val ]
~~~
