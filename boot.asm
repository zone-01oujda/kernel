[BITS 16]
section .boot
global start

extern kmain

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    ; Print 'B' via BIOS
    mov ah, 0x0e
    mov al, 'B'
    int 0x10

    lgdt [gdt_descriptor] 
    mov eax, cr0     
    or al, 1         
    mov cr0, eax     
    
    jmp 0x08:PModeMain 

; ================ 32-bit GDT ================
align 16
gdt_start:
    dq 0x0
gdt_code:            ; 0x08
    dw 0xffff, 0x0000
    db 0x00, 10011010b, 11001111b, 0x00
gdt_data:            ; 0x10
    dw 0xffff, 0x0000
    db 0x00, 10010010b, 11001111b, 0x00
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1 
    dd gdt_start            

; ================ 32-BIT MODE ================
[BITS 32]
PModeMain:
    mov ax, 0x10 
    mov ds, ax
    mov es, ax
    mov ss, ax

    ; Print "3" to show we are in Protected Mode
    mov [0xb8000], word 0x0f33

    ; --- STEP 1: Build Page Tables ---
    ; We use memory at 0x1000 for tables
    mov edi, 0x1000
    mov ecx, 3072
    xor eax, eax
    rep stosd       ; Zero out 12KB

    ; Link PML4 -> PDPT -> PD
    mov dword [0x1000], 0x2003      ; PML4[0] points to PDPT at 0x2000
    mov dword [0x2000], 0x3003      ; PDPT[0] points to PD at 0x3000
    mov dword [0x3000], 0x00000083  ; PD[0]: 2MB Huge Page (0x83 = Present, Read/Write, Huge)

    ; --- STEP 2: Enable PAE & Paging ---
    mov eax, cr4
    or eax, 1 << 5                  ; Set PAE bit
    mov cr4, eax

    mov eax, 0x1000
    mov cr3, eax                    ; Load PML4 address into CR3

    ; --- STEP 3: Enable Long Mode ---
    mov ecx, 0xC0000080             ; EFER MSR
    rdmsr
    or eax, 1 << 8                  ; Set LME bit
    wrmsr

    ; --- STEP 4: Activate Paging ---
    mov eax, cr0
    or eax, 1 << 31                 ; Set PG bit
    mov cr0, eax

    lgdt [gdt64_descriptor]         ; Load 64-bit GDT
    jmp 0x08:LongModeMain           ; Jump to 64-bit!

; ================ 64-bit GDT ================
align 16
gdt64_start:
    dq 0x0 
gdt64_code:
    dq (1<<43) | (1<<44) | (1<<47) | (1<<53) ; 64-bit code, present, long mode
gdt64_data:
    dq (1<<41) | (1<<44) | (1<<47)           ; 64-bit data, present
gdt64_end:

gdt64_descriptor:
    dw gdt64_end - gdt64_start - 1
    dd gdt64_start

; ================ 64-BIT MODE ================
[BITS 64]
LongModeMain:
    ; Print "64" in Green (0x0A)
    mov rax, 0x0a340a36
    mov [0xb8004], rax  
    call kmain
    hlt

; Move the signature to the VERY END of the code
times 510 - ($ - $$) db 0
dw 0xAA55