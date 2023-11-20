#!/bin/sh

nasm -f elf64 calcasm.asm -o calcasm.o
ld calcasm.o -o calcasm
