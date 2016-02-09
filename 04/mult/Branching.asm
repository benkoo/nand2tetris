// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/BranchingOriginal.asm

// Put your code here.

// Adds 1+...+100.
	@R0
	D=M

	@POSITIVE
	D;JGT

	@R1
	M=0    //RAM[1]=0
	@END
	0;JMP

	(POSITIVE)
	@R1
	M=1    // R1=1

	(END)
	@10
	0;JMP
