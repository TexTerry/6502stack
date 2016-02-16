all: stack.hex

stack.hex: stack.asm stack.lst
	acme -l stack.lst -o stack.hex stack.asm

