ENTRY(_start)

SECTIONS {
    /* Our bootloader loads the kernel at 0x1000 */
    . = 0x1000;
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