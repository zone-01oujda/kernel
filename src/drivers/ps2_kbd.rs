use crate::shell;
use core::arch::asm;

pub fn handle_interrupt() {
    unsafe {
        let scancode: u8;
        core::arch::asm!("in al, 0x60", out("al") scancode);

        // Bit 7 (0x80) is set if the key was released.
        // We only want to print on the "Press" event.
        if scancode & 0x80 == 0 {
            let key = match scancode {
                // Letters (AZERTY unshifted)
                0x10 => Some('a'), // Q pos
                0x11 => Some('z'), // W pos
                0x12 => Some('e'),
                0x13 => Some('r'),
                0x14 => Some('t'),
                0x15 => Some('y'),
                0x16 => Some('u'),
                0x17 => Some('i'),
                0x18 => Some('o'),
                0x19 => Some('p'),
                0x1E => Some('q'),
                0x1F => Some('s'),
                0x20 => Some('d'),
                0x21 => Some('f'),
                0x22 => Some('g'),
                0x23 => Some('h'),
                0x24 => Some('j'),
                0x25 => Some('k'),
                0x26 => Some('l'),
                0x27 => Some('m'),
                0x2C => Some('w'),
                0x2D => Some('x'),
                0x2E => Some('c'),
                0x2F => Some('v'),
                0x30 => Some('b'),
                0x31 => Some('n'),

                // Numbers & symbols (standard)
                0x02 => Some('1'),
                0x03 => Some('2'),
                0x04 => Some('3'),
                0x05 => Some('4'),
                0x06 => Some('5'),
                0x07 => Some('6'),
                0x08 => Some('7'),
                0x09 => Some('8'),
                0x0A => Some('9'),
                0x0B => Some('0'),
                0x0C => Some('°'),
                0x0D => Some('-'),    // Often '-' not '+'; verify your KB
                0x0E => Some('\x08'), // Backspace
                0x0F => Some('^'),
                0x28 => Some('$'),
                0x29 => Some('*'),
                0x2B => Some('µ'),
                0x33 => Some('<'),
                0x34 => Some('!'),
                0x35 => Some('ç'),

                // Control
                0x1C => Some('\n'), // Enter
                0x39 => Some(' '),  // Space
                _ => None,
            };

            if let Some(c) = key {
                // print_info!("{}", c);
                shell::ordis::SHELL.lock().handle_char(c);
                // shell::p
            }
        }

        // Send End of Interrupt (EOI) to the Master PIC
        core::arch::asm!("out 0x20, al", in("al") 0x20u8);
    }
}

pub fn reboot() {
    unsafe { asm!("out 0x64, al", in("al") 0xFEu8) }
    loop {
        unsafe {
            asm!("hlt");
        }
    }
}
