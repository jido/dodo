# The dodo programming language

## The dodo calling convention

A function call is implemented as a jump to a label rather than a CALL instruction. The caller provides the address of a continuation to call when the function ends.

### Standalone function call

Parameters are passed in RDI, RSI, RDX and RCX. Extra parameters or parameters too large for a register are passed on the stack.

Continuations are passed in R8, R9, R10 and R11. Extra continuations are passed on the stack.

The module in which the function is defined, which is called function context, is passed in the RAX register.

The return value is stored in RDX:RAX. If the return value is too large for a pair of registers it is stored on the stack *before* the function parameters.

This means the caller must reserve enough space on stack for the largest possible return value (according to function signature) before the parameters.

The stack is truncated by the function before calling the return continuation.
