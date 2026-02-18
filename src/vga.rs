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
    pub color: u8,
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
            self.scroll()
        }
    }

    fn scroll(&mut self) {
        unsafe {
            let count = VGA_WIDTH * (VGA_HEIGHT - 1);
            let src = self.buf.add(VGA_WIDTH);
            let dst = self.buf;

            core::ptr::copy_nonoverlapping(src, dst, count);

            let blank = (DEFAULT_COLOR as u16) << 8 | (b' ' as u16);
            let last_row_start = (VGA_HEIGHT - 1) * VGA_WIDTH;
            for x in 0..VGA_WIDTH {
                self.buf.add(last_row_start + x).write_volatile(blank);
            }
        }

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
                self.write_byte(byte, self.color);
            }
        }
        Ok(())
    }
}

pub static WRITER: Spinlock<VgaWriter> = Spinlock::new(VgaWriter {
    row: 0,
    column: 0,
    buf: 0xb8000 as *mut u16,
    color: DEFAULT_COLOR,
});

#[doc(hidden)]
pub fn _print(args: Arguments, color: u8) {
    use core::fmt::Write;
    let mut writer = WRITER.lock();
    writer.color = color;
    writer.write_fmt(args).unwrap();
}


pub enum Color {
    Success = 0x02,
    Warning = 0x0e,
    Error = 0x04,
    Info = 0x0f,
}