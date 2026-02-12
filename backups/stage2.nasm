[bits 16]
[org 0x7c00]

; Where we want to load our Rust kernel in memory
KERNEL_OFFSET equ 0x1000 

start:
    ; 1. Set up the stack (grows downwards from 0x9000)
    mov bp, 0x9000
    mov sp, bp

    mov al, 'L' ; 'L' for Loading
    call print_char

    ; 2. Load the kernel from disk
    call load_kernel

    ; 3. Prepare to jump
    mov al, 'J' ; 'J' for Jumping
    call print_char

    ; For now, we stay in 16-bit. 
    ; In the next step, we will add the code to switch to 32-bit mode.
    jmp $

load_kernel:
    mov bx, KERNEL_OFFSET ; Destination address in RAM
    mov dh, 2             ; Number of sectors to read (increase this as kernel grows)
    mov dl, [BOOT_DRIVE]  ; Use the drive the BIOS booted us from
    
    mov ah, 0x02 ; BIOS read sector function
    mov al, dh   ; Read DH sectors
    mov ch, 0x00 ; Cylinder 0
    mov dh, 0x00 ; Head 0
    mov cl, 0x02 ; Start reading from the second sector (Sector 1 is the bootloader)
    int 0x13     ; BIOS Disk Interrupt
    ret

print_char:
    mov ah, 0x0e
    int 0x10
    ret

BOOT_DRIVE db 0

times 510-($-$$) db 0
dw 0xaa55