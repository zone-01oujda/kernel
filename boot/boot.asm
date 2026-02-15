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

    ; --- STEP 0: LOAD RUST FROM DISK ---
    ; BIOS only loads 512 bytes. We need to load the rest!
    mov ah, 0x02    ; BIOS read sectors
    mov al, 10      ; Read 10 sectors (5KB)
    mov ch, 0x00    ; Cylinder 0
    mov dh, 0x00    ; Head 0
    mov cl, 0x02    ; Start at sector 2
    mov bx, 0x7e00  ; Load it right after the bootloader
    int 0x13
    
    ; Print 'B' 
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
gdt_code:            
    dw 0xffff, 0x0000
    db 0x00, 10011010b, 11001111b, 0x00
gdt_data:            
    dw 0xffff, 0x0000
    db 0x00, 10010010b, 11001111b, 0x00
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1 
    dq gdt_start            ; Use dq for elf64 compatibility

[BITS 32]
PModeMain:
    mov ax, 0x10 
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov [0xb8000], word 0x0f33 ; Print '3'

    ; --- Paging Setup ---
    mov edi, 0x1000
    mov ecx, 3072
    xor eax, eax
    rep stosd       

    mov dword [0x1000], 0x2003      
    mov dword [0x2000], 0x3003      
    mov dword [0x3000], 0x00000083  

    mov eax, cr4
    or eax, 1 << 5                  
    mov cr4, eax

    mov eax, 0x1000
    mov cr3, eax                    

    mov ecx, 0xC0000080             
    rdmsr
    or eax, 1 << 8                  
    wrmsr

    mov eax, cr0
    or eax, 1 << 31                 
    mov cr0, eax

    lgdt [gdt64_descriptor]         
    jmp 0x08:LongModeMain           

; ================ 64-bit GDT ================
align 16
gdt64_start:
    dq 0x0 
gdt64_code:
    dq (1<<43) | (1<<44) | (1<<47) | (1<<53) 
gdt64_data:
    dq (1<<41) | (1<<44) | (1<<47)           
gdt64_end:

gdt64_descriptor:
    dw gdt64_end - gdt64_start - 1
    dq gdt64_start

[BITS 64]
LongModeMain:
    mov rax, 0x0a340a36
    mov [0xb8004], rax  
    call kmain
    hlt