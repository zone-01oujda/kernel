#![no_std]
#![no_main]
#![feature(abi_x86_interrupt)]

pub mod drivers;
pub mod shell;
pub mod sync;
pub use drivers::vga::*;
pub mod arch;
pub mod macros;
use core::panic::PanicInfo;

use crate::drivers::vga;

#[unsafe(no_mangle)]
pub extern "C" fn kmain() -> ! {
    arch::gdt::init();
    arch::idt::init();
    arch::idt::remap_pic();
    vga::clear_screen();
    println!("Welcome to your Linux-style Kernel!");
    print_info!("> ");
    fn over() -> u32 {
        if 1 != 1 {
            return 5;
        }
            println!("2");
        over()
    }
    over();
    loop {}
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
