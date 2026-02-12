#!/bin/bash

nasm -f bin boot.nasm -o boot.bin
cargo rustc --target x86_64-unknown-none -- -C link-arg=-Tlinker.ld
objcopy -O binary target/x86_64-unknown-none/debug/kernel kernel.bin
cat boot.bin kernel.bin > os-image.bin

qemu-system-x86_64 -drive format=raw,file=os-image.bin