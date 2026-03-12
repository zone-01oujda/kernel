use crate::drivers::ps2_kbd;
use crate::print_info;
use crate::println;
use crate::sync::Spinlock;

pub static SHELL: Spinlock<KShell> = Spinlock::new(KShell::new());

pub struct KShell {
    buffer: [u8; 64],
    cursor: usize,
}

impl KShell {
    pub const fn new() -> Self {
        Self {
            buffer: [0; 64],
            cursor: 0,
        }
    }

    pub fn handle_char(&mut self, c: char) {
        match c {
            '\n' => {
                println!("");
                self.execute(); // This is your 'interpret'
                self.cursor = 0;
                print_info!("> ");
            }
            // Handling Backspace (AZERTY scancode 0x0E)
            '\x08' => {
                if self.cursor > 0 {
                    self.cursor -= 1;
                    // We need to actually erase the char on screen
                    crate::drivers::vga::backspace();
                }
            }
            _ => {
                if self.cursor < 64 {
                    self.buffer[self.cursor] = c as u8;
                    self.cursor += 1;
                    print_info!("{}", c);
                }
            }
        }
    }

    fn execute(&self) {
        let cmd_bytes = &self.buffer[..self.cursor];
        if cmd_bytes.is_empty() {
            return;
        }

        // Find the first space to separate command from args
        let mut split_idx = self.cursor;
        for (i, &b) in cmd_bytes.iter().enumerate() {
            if b == b' ' {
                split_idx = i;
                break;
            }
        }

        let command = &cmd_bytes[..split_idx];
        let args = if split_idx < self.cursor {
            &cmd_bytes[split_idx + 1..] // Skip the space
        } else {
            &[] // No arguments
        };

        match command {
            b"echo" => {
                self.cmd_echo(args);
            }
            b"help" => {
                println!("Commands: echo [text], help, info, clear");
            }
            b"clear" => {
                crate::drivers::vga::clear_screen();
            }
            b"reboot" => {
                println!("System rebooting...");
                ps2_kbd::reboot()
            }
            _ => {
                println!("Error: Command not found.");
            }
        }
    }

    fn cmd_echo(&self, args: &[u8]) {
        for &b in args {
            print_info!("{}", b as char);
        }
        println!("");
    }
}
