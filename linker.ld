ENTRY(start)
OUTPUT_FORMAT("binary")

SECTIONS
{
    . = 0x7c00;

    .boot :
    {
        *(.boot)      /* Your 16-bit asm */
        *(.text)      /* Your 32/64-bit asm */
    }

    /* Fill to the end of the first sector */
    . = 0x7c00 + 510;
    .sig :
    {
        SHORT(0xAA55);
    }

    /* Rust code starts here (Sector 2 on the disk) */
    .kernel :
    {
        kernel.o(.text)   /* Specifically pull text from kernel.o */
        *(.text.*)        /* Pull any other text sections */
        *(.rodata*)
        *(.data*)
    }

    /DISCARD/ : { *(.comment) *(.eh_frame) }
}