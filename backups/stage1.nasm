[bits 16]       ; 16-bit mode
[org 0x7c00]    ; BIOS loads us here

start:
    mov ah, 0x0e ; BIOS "Teletype" function
    mov al, 'B'  ; The character to print
    int 0x10     ; Call BIOS interrupt

    jmp $        ; Infinite loop (Stay here for now)

; Fill the rest of the 512 bytes with zeros
times 510-($-$$) db 0
; The Boot Signature (Required)
dw 0xaa55