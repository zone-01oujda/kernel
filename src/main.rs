#![no_std]
#![no_main]

use core::panic::PanicInfo;

use kernel::spin::Spinlock;

pub struct VgaWriter {
    column: usize,
    buf: &'static mut [u16; 80 * 25],
}

impl VgaWriter {
    pub fn write_byte(&mut self, byte: u8, color: u8) {
        let index = self.column;
        if index < 80 * 25 {
            self.buf[index] = (color as u16) << 8 | (byte as u16);
            self.column += 1;
        }
    }
}

pub static WRITER: Spinlock<VgaWriter> = Spinlock::new(VgaWriter {
    column: 0,
    buf: unsafe { &mut *(0xb8000 as *mut [u16; 80 * 25]) },
});

static HELLO: &[u8] = b"Hello World\n";

#[unsafe(no_mangle)]
pub extern "C" fn kmain() -> ! {
    let vga_buffer = 0xb8000 as *mut u8;
    for (i, &byte) in HELLO.iter().enumerate() {
        unsafe {
            *vga_buffer.offset(i as isize * 2) = byte;
            *vga_buffer.offset(i as isize * 2 + 1) = 0xf;
        }
    }
    loop {}
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
