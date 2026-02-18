# Toolchain
ASM      := nasm
LD       := ld
QEMU     := qemu-system-x86_64
OBJCOPY  := objcopy

# Target Triple
TARGET   := x86_64-unknown-none

# Directories
BOOT_DIR := boot
SRC_DIR  := src
BUILD_DIR := build

# Files
BOOT_ASM := $(BOOT_DIR)/boot.asm
LINKER   := linker.ld

# Object and Library files
BOOT_OBJ := $(BUILD_DIR)/boot.o
KERNEL_ELF := $(BUILD_DIR)/kernel.elf
# This is the static library produced by Cargo (crate-type = ["staticlib"])
KERNEL_LIB_CARGO := target/$(TARGET)/release/libkernel.a
OS_IMAGE := boot.bin

# Linker flags
# We link the bootloader object and the Rust static library together
LD_FLAGS := -m elf_x86_64 -T $(LINKER) -Map $(BUILD_DIR)/kernel.map

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m

.PHONY: all clean run

all: $(BUILD_DIR) $(OS_IMAGE)
	@echo "$(GREEN)✓ Build complete: $(OS_IMAGE)$(NC)"

$(BUILD_DIR):
	mkdir -p $@

# Rule to assemble the bootloader
$(BOOT_OBJ): $(BOOT_ASM) | $(BUILD_DIR)
	@echo "$(YELLOW)→ Assembling bootloader...$(NC)"
	$(ASM) -f elf64 $< -o $@

# Rule to compile the Rust kernel into a static library
$(KERNEL_LIB_CARGO):
	@echo "$(YELLOW)→ Compiling Rust kernel with Cargo...$(NC)"
	cargo build --release --target $(TARGET)

# Rule to link bootloader and Rust library into an ELF file
$(KERNEL_ELF): $(BOOT_OBJ) $(KERNEL_LIB_CARGO) $(LINKER)
	@echo "$(YELLOW)→ Linking kernel with bootloader...$(NC)"
	$(LD) $(LD_FLAGS) $(BOOT_OBJ) $(KERNEL_LIB_CARGO) -o $@

# Rule to create the final bootable binary image
$(OS_IMAGE): $(KERNEL_ELF)
	@echo "$(YELLOW)→ Creating boot image...$(NC)"
	$(OBJCOPY) -O binary $< $@

run: $(OS_IMAGE)
	@echo "$(YELLOW)→ Starting QEMU...$(NC)"
	$(QEMU) -drive format=raw,file=$(OS_IMAGE)

clean:
	@echo "$(YELLOW)→ Cleaning project...$(NC)"
	rm -rf $(BUILD_DIR) $(OS_IMAGE)
	cargo clean
	@echo "$(GREEN)✓ Clean complete$(NC)"

.DEFAULT_GOAL := all