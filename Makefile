# Toolchain
ASM      := nasm
CC       := rustc
LD       := ld
QEMU     := qemu-system-x86_64
OBJCOPY  := objcopy

# Directories
BOOT_DIR := boot
SRC_DIR  := src
BUILD_DIR := build

# Files
BOOT_ASM := $(BOOT_DIR)/boot.asm
KERNEL_RS := $(SRC_DIR)/main.rs
LINKER   := linker.ld

# Object files (with build directory)
BOOT_OBJ := $(BUILD_DIR)/boot.o
KERNEL_OBJ := $(BUILD_DIR)/kernel.o
KERNEL_ELF := $(BUILD_DIR)/kernel.elf
OS_IMAGE := boot.bin

# Rust flags
RUST_FLAGS := --target x86_64-unknown-none \
              --emit obj \
              -C opt-level=3 \
              -C code-model=kernel \
              -C panic=abort \
              -C lto=yes

# Linker flags
LD_FLAGS := -m elf_x86_64 -T $(LINKER) -Map $(BUILD_DIR)/kernel.map

# Colors (optional - remove if you don't want colors)
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m

.PHONY: all clean run

all: $(BUILD_DIR) $(OS_IMAGE)
	@echo "$(GREEN)✓ Build complete: $(OS_IMAGE)$(NC)"

$(BUILD_DIR):
	mkdir -p $@

$(BOOT_OBJ): $(BOOT_ASM) | $(BUILD_DIR)
	@echo "$(YELLOW)→ Assembling bootloader...$(NC)"
	$(ASM) -f elf64 $< -o $@

$(KERNEL_OBJ): $(KERNEL_RS) | $(BUILD_DIR)
	@echo "$(YELLOW)→ Compiling Rust kernel...$(NC)"
	$(CC) $(RUST_FLAGS) $< -o $@

$(KERNEL_ELF): $(BOOT_OBJ) $(KERNEL_OBJ) $(LINKER)
	@echo "$(YELLOW)→ Linking kernel...$(NC)"
	$(LD) $(LD_FLAGS) $(BOOT_OBJ) $(KERNEL_OBJ) -o $@

$(OS_IMAGE): $(KERNEL_ELF)
	@echo "$(YELLOW)→ Creating boot image...$(NC)"
	$(OBJCOPY) -O binary $< $@

run: $(OS_IMAGE)
	@echo "$(YELLOW)→ Starting QEMU...$(NC)"
	$(QEMU) -drive format=raw,file=$(OS_IMAGE)

clean:
	rm -rf $(BUILD_DIR) $(OS_IMAGE)
	@echo "$(GREEN)✓ Clean complete$(NC)"

.DEFAULT_GOAL := all