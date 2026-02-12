[bits 16]                           ; 16-bit mode
[org 0x7c00]                        ; BIOS loads us here

KERNEL_OFFSET equ 0x1000

start:
    mov [BOOT_DRIVE], dl           
    mov bp, 0x9000                  ; Set up the stack (grows downwards from 0x9000)
    mov sp, bp

    mov al, 'L'                     ;'L' for Loading
    call print_char
    call load_kernel                ; Load the kernel from disk

                                    ; We're about to switch to protected mode
    cli                             ; 1. Disable interrupts
    lgdt [gdt_descriptor]           ; 2. Load the GDT

    mov eax, cr0
    or eax, 0x1                     ; 3. Set PE (Protection Enable) bit
    mov cr0, eax

    jmp CODE_SEG:init_pm            ; 4. Far jump to 32-bit code


print_char:
    mov ah, 0x0E
    int 0x10
    ret

load_kernel:
    mov bx, KERNEL_OFFSET           ; Destination address in RAM
    mov dh, 2                       ; Number of sectors to read (increase this as kernel grows)
    mov dl, [BOOT_DRIVE]            ; Use the drive the BIOS booted us from

    mov ah, 0x02                    ; BIOS read sector function
    mov al, dh                      ; Read DH sectors
    mov ch, 0x00                    ; Cylinder 0
    mov dh, 0x00                    ; Head 0
    mov cl, 0x02                    ; Start reading from the second sector (Sector 1 is the bootloader)
    int 0x13                        ; BIOS Disk Interrupt
    ret

BOOT_DRIVE db 0

; ================ GDT (Global Descriptor Table) ================
gdt_start:
    dq 0x0                          ; Null descriptor - required

gdt_code:                           ; The code segment descriptor
    dw 0xffff                       ; Limit
    dw 0x0                          ; Base (bits 0-15)                
    db 0x0                          ; Base bits 16-23  (middle byte)
    db 10011010b                    ; Access byte (code, readable, privileged)
    db 11001111b                    ; Flags
    db 0x0                          ; Base (bits 24-31)

gdt_data:                           ; The data segment descriptor
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b    ; Access byte (data, writable)
    db 11001111b
    db 0x0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1      ; Size
    dd gdt_start               ; Address

; contants
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start


times 510-($-$$) db 0               ; 510 - (size)
dw 0xaa55                           ; the boot Signature


[bits 32]
init_pm:
                                    ; 5. Update segment registers
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

                                    ; 6. Update stack position
    mov ebp, 0x90000
    mov esp, ebp

    call BEGIN_PM                   ; Finally jump to our 32-bit entry point

BEGIN_PM:
    ; check we are in 32bit
    mov byte [0xb8000], '3'
    mov byte [0xb8001], 0x0f

    jmp KERNEL_OFFSET               ; jmp to our Rust code

    jmp $
