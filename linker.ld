ENTRY(start)
OUTPUT_FORMAT("binary") /* We want a flat binary for the final disk image */

SECTIONS
{
    /* The BIOS loads us at 0x7c00 */
    . = 0x7c00;

    .boot :
    {
        *(.boot)
    }

    /* Your 32-bit and 64-bit code */
    .text :
    {
        *(.text)
    }

    /* Move to the end of the boot sector */
    . = 0x7c00 + 510;
    .sig :
    {
        SHORT(0xAA55);
    }

    /* Rust kernel code starts right after the boot sector (0x7e00) */
    .kernel :
    {
        *(.rodata .data .bss)
    }
}