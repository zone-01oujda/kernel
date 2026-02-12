[bits 16]                           ; 16-bit mode
[org 0x7c00]                        ; BIOS loads us here

KERNEL_OFFSET equ 0x1000

start:
                        
    mov bp, 0x9000                  ; Set up the stack (grows downwards from 0x9000)
    mov sp, bp

    mov al, 'L'                     ;'L' for Loading
    call print_char

    call load_kernel                ; Load the kernel from disk




    mov ah, 0x0E
    mov al, 'B'
    int 0x10
    jmp $


print_char:
    mov ah, 0x0E
    int 0x10
    ret

load_kernel:
    mov bx, KERNEL_OFFSET           ; Destination address in RAM
    mov dh, 2                       ; Number of sectors to read (increase this as kernel grows)


times 510-($-$$) db 0               ; 510 - (size)
dw 0xaa55                           ; the boot Signature