// #![no_std]
// #![no_main]

// use core::panic::PanicInfo;

// static HELLO: &[u8] = b"Hello World\n";

// #[panic_handler]
// fn panic(_info: &PanicInfo) -> ! {
//     loop {}
// }

// #[unsafe(no_mangle)]
// pub extern "C" fn kmain() -> ! {
//     let vga_buffer = 0xb8000 as *mut u8;
//     for (i,&byte) in HELLO.iter().enumerate() {
//         unsafe {
//             *vga_buffer.offset(i as isize * 2) = byte;
//             *vga_buffer.offset(i as isize * 2 + 1) = 0xf;
//         }
//     }
//     loop {}
// }


#![no_std]
#![no_main]

use core::panic::PanicInfo;

#[unsafe(no_mangle)]
pub extern "C" fn kmain() -> ! {
    let vga_buffer = 0xb8000 as *mut u16;
    unsafe {
        // Print a Cyan 'R' for Rust!
        *vga_buffer.offset(5) = 0x0b52; 
    }
    loop {}
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}