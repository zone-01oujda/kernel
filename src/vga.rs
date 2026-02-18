use core::fmt::{Arguments, Write};

use crate::spin::Spinlock;

pub const VGA_WIDTH: usize = 80;
pub const VGA_HEIGHT: usize = 25;
pub const VGA_BUFFER_ADDR: usize = 0xb8000;

pub const DEFAULT_COLOR: u8 = 0x0f;

pub struct VgaWriter {
    pub row: usize,
    pub column: usize,
    pub buf: *mut u16,
}

impl VgaWriter {
    pub fn write_byte(&mut self, byte: u8, color: u8) {
        let index = self.row * VGA_WIDTH + self.column;

        if index < VGA_WIDTH * VGA_HEIGHT {
            let ch = (color as u16) << 8 | (byte as u16);
            unsafe {
                self.buf.add(index).write_volatile(ch);
            }
            self.column += 1;
            if self.column >= VGA_WIDTH {
                self.new_line();
            }
        }
    }

    pub fn new_line(&mut self) {
        self.column = 0;
        if self.row < VGA_HEIGHT - 1 {
            self.row += 1;
        } else {
            // self.scroll()
        }
    }

    fn scroll(&mut self) {
        unsafe {
            for y in 1..VGA_HEIGHT {
                for x in 0..VGA_WIDTH {
                    let src_idx = y * VGA_WIDTH + x;
                    let dst_idx = (y - 1) * VGA_WIDTH + x;

                    let character = self.buf.add(src_idx).read_volatile();
                    self.buf.add(dst_idx).write_volatile(character);
                }
            }

            // 2. Clear the last row.
            let blank = (DEFAULT_COLOR as u16) << 8 | (b' ' as u16);
            let last_row_start = (VGA_HEIGHT - 1) * VGA_WIDTH;

            for x in 0..VGA_WIDTH {
                self.buf.add(last_row_start + x).write_volatile(blank);
            }
        }

        // 3. Reset position to the start of the last line
        self.row = VGA_HEIGHT - 1;
        self.column = 0;
    }
}

impl Write for VgaWriter {
    fn write_str(&mut self, s: &str) -> core::fmt::Result {
        for byte in s.bytes() {
            if byte == b'\n' {
                self.new_line()
            } else {
                self.write_byte(byte, 0xf);
            }
        }
        Ok(())
    }
}

pub static WRITER: Spinlock<VgaWriter> = Spinlock::new(VgaWriter {
    row: 0,
    column: 0,
    buf: 0xb8000 as *mut u16,
});

#[doc(hidden)]
pub fn _print(args: Arguments) {
    use core::fmt::Write;
    WRITER.lock().write_fmt(args).unwrap();
}
