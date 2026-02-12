ENTRY(_start)

SECTIONS {
    /* Our bootloader loads the kernel at 0x10000 */
    . = 0x10000;
    .text : {
        *(.text._start)
        *(.text*)
    }

    .rodata : {
        *(.rodata*)
    }

    .data :
    {
        *(.data*)
    }

    /DISCARD/ : {
        *(.comment)
        *(.eh_frame)
        *(.rel.eh_frame)
    }

}