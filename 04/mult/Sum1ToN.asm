// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Sum1ToN.asm

//Compute RAM[1]=1+2+...+RAM[0]

//**
//	n=R0
//	i=1
//	sum=0

//LOOP:	 if i >-n goto STOP
//	sum=sum+i
//	i= i+1
//	goto LOOP
//STOP:
//	R1=sum

	@R0
	D=M
	@n
	M=D
	@i
	M=1
	@sum
	M=0
	
(LOOP)
	@i
	D=M
	@n
	D=D-M
	@STOP
	D;JGT

	@sum
	D=M
	@i
	D=D+M
	@sum
	M=D      // sum = sum + i
	
	@i
	M=M+1    // i=i+1
	@LOOP
	0;JMP
	
(STOP)
	@sum
	D=M
	@R1
	M=D     //RAM[1] =sum
(END)
	@END
	0;JMP
	
