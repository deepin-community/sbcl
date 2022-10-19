#ifndef _PPC_LINUX_OS_H
#define _PPC_LINUX_OS_H

typedef ucontext_t os_context_t;
typedef unsigned long os_context_register_t;

#include "arch-os-generic.inc"

unsigned long os_context_fp_control(os_context_t *context);
#define RESTORE_FP_CONTROL_FROM_CONTEXT
void os_restore_fp_control(os_context_t *context);

#endif /* _PPC_LINUX_OS_H */
