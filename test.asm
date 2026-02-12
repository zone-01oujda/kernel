[bits 64]
    mov word [0xb8000], 0x0f4b
    mov word [0xb8002], 0x0f21
    hlt
    jmp $