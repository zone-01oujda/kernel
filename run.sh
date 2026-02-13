# 1. Compile your Assembly
nasm -f elf64 boot.asm -o boot.o

# 2. Build the Rust library
# Cargo will now create: target/x86_64-unknown-none/debug/libkernel.a
cargo build --target x86_64-unknown-none

# 3. Use the Linker to merge Assembly + Rust into a raw bootable file
ld -m elf_x86_64 -T linker.ld boot.o target/x86_64-unknown-none/debug/libkernel.a -o boot.bin

# 4. Run it!
qemu-system-x86_64 -drive format=raw,file=boot.bin