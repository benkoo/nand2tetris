// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input. 
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel. When no key is pressed, the
// program clears the screen, i.e. writes "white" in every pixel.

	
// Note, in order to pass the test, one must use Assembler.sh to
// compile the edited code to Fill.hack.
// then use AutomaticTest.tst script to test the result before submission.


	@color   //Initialize color to be white
	M=0

	@8191   //What ever number is here, for example, 8192 is equal to (256*32)
	D=A   //Get the address number (8192-1) to D

	@widthTimesHeight
	M=D

(REDRAW)
	@SCREEN
	D=A
	@addr
	M=D  	//addr = 16384
	        // (screen's base address)

	@widthTimesHeight
	D=M
	
	@n
	M=D  	// n = widthTimesHeight

	@i
	M=0	// i = 0

	@DRAWLOOP
	0;JMP   //Goto DRAW LOOP


(DRAWLOOP)
	@i
	D=M
	@n
	D=D-M
	@END
	D;JGT	// if i>n goto END


	@color
	D=M
	
	@addr
	A=M
	// RAM can be 0 or -1
	M=D	//RAM[addr]=-1 or 0 makes 16 pixels black or white
	
	@i
	M=M+1	// i = i+1
	@1
	D=A
	@addr
	M=D+M	//addr = addr + 32
	@DRAWLOOP
	0;JMP	// goto DRAWLOOP


(END)
	@KBD
	D=M
	
	@NOKEYPRESSED
	D;JGT

	@color
	M=0

	@REDRAW
	0;JMP
	

(NOKEYPRESSED)
	@color
	M=-1
	@REDRAW
	0;JMP
