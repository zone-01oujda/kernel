#[macro_export]
macro_rules! print_info {
    ($($arg:tt)*) => {
        $crate::vga::_print(format_args!($($arg)*), $crate::vga::Color::Info as u8)
    };
}

#[macro_export]
macro_rules! print_success {
    ($($arg:tt)*) => {
        $crate::vga::_print(format_args!($($arg)*), $crate::vga::Color::Success as u8)
    };
}

#[macro_export]
macro_rules! print_warning {
    ($($arg:tt)*) => {
        $crate::vga::_print(format_args!($($arg)*), $crate::vga::Color::Warning as u8)
    };
}

#[macro_export]
macro_rules! print_error {
    ($($arg:tt)*) => {
        $crate::vga::_print(format_args!($($arg)*), $crate::vga::Color::Error as u8)
    };
}

// Similarly for println variants
#[macro_export]
macro_rules! println {
    () => {
        $crate::print_info!("\n")
    };
    ($($arg:tt)*) => {
        $crate::print_info!("{}\n", format_args!($($arg)*))
    };
}

#[macro_export]
macro_rules! println_error  {
    () => {
        $crate::print_error!("\n")
    };
    ($($arg:tt)*) => {
        $crate::print_error!("{}\n", format_args!($($arg)*))
    };
}

#[macro_export]
macro_rules! println_success {
    () => {
        $crate::print_success!("\n")
    };
    ($($arg:tt)*) => {
        $crate::print_success!("{}\n", format_args!($($arg)*))
    };
}

#[macro_export]
macro_rules! println_warning {
    () => {
        $crate::print_warning!("\n")
    };
    ($($arg:tt)*) => {  
        $crate::print_warning!("{}\n", format_args!($($arg)*))
    };
}

