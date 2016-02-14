// File name: projects/04/ModularLoops.asm

// Runs an infinite loop that listens to the keyboard input. 
// When a key is pressed (any key), the program does something.

	@color   //Initialize color to be black -1
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
