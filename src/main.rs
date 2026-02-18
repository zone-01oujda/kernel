#![no_std]
#![no_main]

pub mod spin;
pub use spin::*;
pub mod vga;
pub use vga::*;
pub mod macros;
use core::panic::PanicInfo;

static HELLO: &[u8] = b"Hello Worldddd\n";

#[unsafe(no_mangle)]
pub extern "C" fn kmain() -> ! {
    println!("System Booting...");
    println!("VGA Buffer: 0x{:x}", 0xb8000);
    
    for i in 0..30 {
        println!("This is line number {}", i);
    }

    loop {}
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
