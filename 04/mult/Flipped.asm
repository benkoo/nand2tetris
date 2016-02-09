// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Flipped.asm

	//temp=R0
	//R0=R1
	//R1=temp

	@R0
	D=M
	@temp
	M=D

	@R1
	D=M
	@R0
	M=D

	@temp
	D=M
	@R1
	M=D
(END)
	@END
	0;JMP
	
