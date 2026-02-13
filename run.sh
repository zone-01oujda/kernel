# 1. Compile Assembly to an object file
nasm -f elf64 boot.asm -o boot.o

# 2. Compile Rust (pointing to main.rs)
rustc --target x86_64-unknown-none \
      --emit obj \
      -C opt-level=3 \
      -C code-model=kernel \
      src/main.rs -o kernel.o

# 3. Link them together
ld -m elf_x86_64 -T linker.ld boot.o kernel.o -o boot.bin

# 4. Run it
qemu-system-x86_64 -drive format=raw,file=boot.bin