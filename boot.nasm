[bits 16]
[org 0x7c00]

KERNEL_OFFSET equ 0x10000

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov [BOOT_DRIVE], dl           
    mov bp, 0x9000
    mov sp, bp

    mov al, 'L'
    call print_char
    call load_kernel

    cli
    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    jmp CODE_SEG:init_pm

print_char:
    mov ah, 0x0E
    int 0x10
    ret

load_kernel:
    mov bx, 0x1000
    mov es, bx
    mov bx, 0x0000
    
    mov dh, 2
    mov dl, [BOOT_DRIVE]
    mov ah, 0x02
    mov al, dh
    mov ch, 0x00
    mov dh, 0x00
    mov cl, 0x02
    int 0x13
    jc disk_error
    ret

disk_error:
    mov al, 'E'
    call print_char
    jmp $

BOOT_DRIVE db 0

; ================ GDT ================
gdt_start:
    dq 0x0

gdt_code:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0

gdt_data:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

gdt_code_64:
    dw 0x0000
    dw 0x0
    db 0x0
    db 10011010b
    db 00100000b
    db 0x0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG    equ gdt_code - gdt_start
DATA_SEG    equ gdt_data - gdt_start
CODE_SEG_64 equ gdt_code_64 - gdt_start

times 510-($-$$) db 0
dw 0xaa55

[bits 32]
init_pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000
    mov esp, ebp

    ; DEBUG: Print '32' to show we're in 32-bit mode
    mov dword [0xb8000], 0x0f330f32  ; '2' '3' at top

    call BEGIN_PM

BEGIN_PM:
    ; DEBUG: Print 'P' for Page table setup start
    mov word [0xb8004], 0x0f50       ; 'P'
    
    ; Clear page tables
    mov edi, 0x10000
    mov cr3, edi
    xor eax, eax
    mov ecx, 4096
    rep stosd
    mov edi, cr3
    
    ; DEBUG: Print 'C' for Cleared
    mov word [0xb8006], 0x0f43       ; 'C'
    
    ; PML4 entry
    mov eax, 0x11000
    or eax, 3
    mov [edi], eax
    mov dword [edi+4], 0
    
    ; DEBUG: Print '4' for PML4
    mov word [0xb8008], 0x0f34       ; '4'
    
    ; PDPT entry
    mov eax, 0x12000
    or eax, 3
    mov [edi+0x1000], eax
    mov dword [edi+0x1004], 0
    
    ; DEBUG: Print '3' for PDPT
    mov word [0xb800a], 0x0f33       ; '3'
    
    ; PD entry - 2MB huge page
    mov eax, 0x00000000
    or eax, 0x83
    mov [edi+0x2000], eax
    mov dword [edi+0x2004], 0
    
    ; DEBUG: Print '2' for PD
    mov word [0xb800c], 0x0f32       ; '2'
    
    ; Enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax
    
    ; DEBUG: Print 'A' for PAE
    mov word [0xb800e], 0x0f41       ; 'A'
    
    ; Enable Long Mode
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr
    
    ; DEBUG: Print 'L' for Long Mode enabled
    mov word [0xb8010], 0x0f4c       ; 'L'
    
    ; Enable Paging
    mov eax, cr0
    or eax, 1 << 31 | 1
    mov cr0, eax
    
    ; DEBUG: Print 'G' for Paging enabled
    mov word [0xb8012], 0x0f47       ; 'G'
    
    ; Jump to 64-bit
    jmp CODE_SEG_64:long_mode_start

[bits 64]
long_mode_start:
    ; If we get here, print '64' in red
    mov word [0xb8014], 0x4f36       ; '6' red on white
    mov word [0xb8016], 0x4f34       ; '4' red on white
    
    hlt
    jmp $