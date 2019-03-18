# The dodo programming language

## The dodo calling convention

A function call is implemented as a jump to a label rather than a CALL instruction. The caller provides the address of a continuation to call when the function ends.

The following description applies to the Intel 64 bit platform.

### Standalone function call

Parameters are passed in RDI, RSI, RDX and RCX. Extra parameters or parameters too large for a register are passed on the stack.

Continuations are passed in R8, R9, R10 and R11. Extra continuations are passed on the stack.

Most functions have two continuations: the return continuation and the event continuation.

The module in which the function is defined, which is called function context, is passed in the RAX register.

The return value is stored in RDX:RAX. If the return value is too large for a pair of registers it is stored on the stack *before* the function parameters.

This means the caller must reserve enough space on stack for the largest possible return value (according to function signature) before the parameters.

The stack is truncated by the function to leave just the return value on stack before calling the return continuation.

The function output may be memoised if the function does not take a capability as argument, reducing the number of calculations.

### Generator (yielding function) call

For a generator there are two stack pointers to consider: the calling function stack (noted SP1) and the generator stack (noted SP2).

The calling function sets the stack pointer to SP2 before calling the generator and passes SP1 as first argument.

Spilled function parameters and continuations are stored on SP2.

In general, a generator has three continuations: the yield continuation, the end continuation (which returns nothing) and the event continuation.

When yielding a value, if the returned value is too large for DX:AX it is stored in a reserved space on SP1.

The stack pointer is not reset by the generator when yielding a value. The generator passes SP1 in register RDI.

The generator also passes the resume continuation in R8 and the unwind continuation in R9.

When the generator ends or an event is raised, the generator sets the stack pointer back to SP1 and returns like a normal function without arguments.

### Associative function calls

Associative functions always take two arguments of same type. The arguments are passed in RDX:RAX and RSI:RDI if they fit in a pair of registers, or on stack otherwise.

They are otherwise similar to standalone functions.

If an associative function is called with more than two arguments in the source file, then the function is called multiple times with the result of a function call used as argument until all parameters are consumed. The order of calls is not defined, but the order of arguments is preserved.
