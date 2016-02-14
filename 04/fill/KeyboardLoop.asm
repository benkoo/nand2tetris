// File name: projects/04/KeyboardLoop.asm

// Runs an infinite loop that listens to the keyboard input. 
// When a key is pressed (any key), the program does something.


	@color   //Initialize color to be black -1
	M=-1
	
(REDRAW)
	@SCREEN
	D=A
	@addr
	M=D  	//addr = 16384
	        // (screen's base address)

	@8192     //This is the number to be loaded to widthTimesHeight (256*32)
	D=A


	@widthTimesHeight
	M=D

	@n
	M=D  	// n = widthTimesHeight

	@i
	M=0	// i = 0

	@DRAWLOOP
	0;JMP

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
	@CHANGETOWHITE
	D;JGT
	@color
	M=-1
	@REDRAW
	0;JMP	// goto LOOP

(CHANGETOWHITE)
	@color
	M=0
	@REDRAW
	0;JMP

	
