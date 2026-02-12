#!/bin/bash

nasm -f bin boot.nasm -o boot.bin
qemu-system-x86_64 -drive format=raw,file=boot.bin