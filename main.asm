		.ORG	$300
INIT:		
		; SEQUENCE OF INPUT AND OUTPUTS FOR THE FISRT VALUE
		JSR	PRINT_MSG1		; ASKS FOR AN HEXADECIMAL STRING INPUT
		JSR	READ_KEYBOARD		; READS A HEX_DEC VALUE
		JSR	CONV2			; CONVERTS THE VALUE READ
		JSR	NEW_LINE		; PRINTS A NEW LINE IN SCREEN
		JSR	PRINT_CURSOR
		STA	$E003			; PRINT THE HEX VALUE
		JSR	NEW_LINE
		JSR	DEC_ASCII		; CONVERTS TO A UNSIGNED INTEGER OF 1 BYTE
		JSR	PRINT_CURSOR			
		JSR	PRINT_DEC		; PRINTS THE ASCII REPRESENTATION OF THE UNSIGNED VALUE
		JSR	NEW_LINE
		JSR	DEC_SIGNED
		PHA
		LDA	TMPSVAL
		STA	SVAL1
		LDA	SIGN
		STA	SIGNAL1
		PLA
		JSR	PRINT_CURSOR
		JSR	PRINT_SIGNED
		JSR	NEW_LINE
		JSR	DEC_TO_BIN
		JSR	PRINT_CURSOR
		JSR	PRINT_BIN
		STA	VAL1
		JSR	NEW_LINE		
		; SEQUENCE OF INPUT AND OUTPUTS FOR THE SECOND VALUE
		JSR	PRINT_MSG1		; ASKS FOR AN HEXADECIMAL STRING INPUT
		JSR	READ_KEYBOARD		; READS A HEX_DEC VALUE
		JSR	CONV2			; CONVERTS THE VALUE READ
		JSR	NEW_LINE		; PRINTS A NEW LINE IN SCREEN
		JSR	PRINT_CURSOR
		STA	$E003			; PRINT THE HEX VALUE
		JSR	NEW_LINE
		JSR	DEC_ASCII		; CONVERTS TO A UNSIGNED INTEGER OF 1 BYTE
		JSR	PRINT_CURSOR			
		JSR	PRINT_DEC		; PRINTS THE ASCII REPRESENTATION OF THE UNSIGNED VALUE
		JSR	NEW_LINE
		JSR	DEC_SIGNED
		PHA
		LDA	TMPSVAL
		STA	SVAL2
		LDA	SIGN
		STA	SIGNAL2
		PLA
		JSR	PRINT_CURSOR
		JSR	PRINT_SIGNED
		JSR	NEW_LINE
		JSR	DEC_TO_BIN
		JSR	PRINT_CURSOR
		JSR	PRINT_BIN
		STA	VAL2
		; THE FINAL OUTPUT
		JSR	NEW_LINE
		JSR	SUM_16BITS
		JSR	UNSIGNED_PRINT
		BRK

;================================================
; 0x2000: SUB-ROUTINE AREA		 	=
;================================================

		.ORG	$2000
;************************************************
; READ_KEYBOARD: reads only two ascii		*
; characters from keyboard and stores in memory.*
; The first char is stored at CHAR1		*
; The second char is stored at CHAR2		*
;************************************************

READ_KEYBOARD:
		PHA
		JSR	PUSH_X
		LDA	$00
		;STA	$E000
LOOP_READ:	LDA	$E004
		CMP	#00
		BEQ	LOOP_READ
		STA	$E002			; exibe echo
		STA	CHAR1, X
		INX
		CPX	#2
		BNE	LOOP_READ
		JSR	POP_X
		PLA
		RTS
;************************************************
; PRINT_MSG1: prints the message - 		*
;       "Insira um valor" in the screen		*
;************************************************
PRINT_MSG1:
		PHA
		JSR	PUSH_X
		LDX	#$00
LOOP_MSG1:	LDA	USR_MSG1, X
		STA	$E002
		INX
		CPX	USR_MSG1_SZ
		BNE	LOOP_MSG1
		JSR	POP_X
		PLA
		RTS		

;************************************************
; PRINT_CURSOR: prints ">>>"  in the screen	*
;************************************************
PRINT_CURSOR:
		PHA
		JSR	PUSH_X
		LDX	#$00
LOOP_CURSOR:	LDA	CURSOR_OUT, X
		STA	$E002
		INX
		CPX	CURSOR_SIZE
		BNE	LOOP_CURSOR
		JSR	POP_X
		PLA
		RTS	

;************************************************
; DEC_TO_BIN: converts the value in acc to a	*
; binary string stored at TMP_STR.		*
; 						*
; Parameters: ACC, the value to be "converted"	*
;						*
; Return: TMP_STR, storing the binary string.	*
;************************************************
DEC_TO_BIN:
		STA	TMP_A
		PHA
		JSR	PUSH_X
		JSR	PUSH_Y
		LDX	#7
		LDY	#0
LOOP_DECBIN:	CPX	#0
		BCS	LABEL_DECBIN
		JMP	END_DECBIN
LABEL_DECBIN:	JSR	PUSH_Y
		JSR	X_TO_Y			; y <- x
		LDA	TMP_A			; the A value SHALL NOT be afected by various shift-left operations
		JSR	RIGHT_SHIFT		; makes A <- A  >> y (right-left the A y times)
		JSR	POP_Y
		AND	#$01			; makes A <- A AND 1
		CLC
		ADC	#$30
		STA	TMP_STR, Y
		DEX
		INY
		CPX	#$FF
		BEQ	END_DECBIN		; just a feature, if you know what i mean... ;) 
		JMP	LOOP_DECBIN
END_DECBIN:	JSR	POP_Y
		JSR	POP_X
		PLA
		RTS
;************************************************
; PRINT_BIN: prints the ascii representation of *
; the last integer value input			*
;************************************************
PRINT_BIN:
		PHA
		JSR	PUSH_X
		LDX	#0
BIN_OUT:	LDA	TMP_STR, X
		STA	$E002
		INX
		CPX	#8
		BNE	BIN_OUT	
		JSR	POP_X
		PLA
		RTS

;************************************************
; DEC_ASCII: converts an integer value to a	*
; ascii representation of this value in decimal	*
; base.						*
; Parameters: A, with the value to be converted	*
;						*
; Return: A string, where each char represents	*
; the digit of the value in decimal mode.	*
;  >TMPD2: stores the most significant digit	*
;  >TMPD1: stores the middle digit		*
;  >TMPD0: stores the least significant digit	*
;						*
; None register should be affected		*
;************************************************
DEC_ASCII:	
		; saving the registers
		PHA
		JSR	PUSH_X
		JSR	PUSH_Y
		LDY	#00
		LDX	#00
		STX	TMPD2
		STY	TMPD1
		STY	TMPD0
DIV_100:	CMP	#100
		BCC	DIV_10
		SBC	#100
		INX
		JMP	DIV_100
DIV_10:		STX	TMPD2
		CMP	#10
		BCC	DIV_1
		SBC	#10
		INY
		JMP	DIV_10
DIV_1:		STY	TMPD1
		STA	TMPD0
		; string conversion :)
		LDA	TMPD2
		ADC	#$30
		STA	TMPD2
		LDA	TMPD1
		ADC	#$30
		STA	TMPD1
		LDA	TMPD0
		ADC	#$30
		STA	TMPD0		
		JSR	POP_Y
		JSR	POP_X
		PLA
		RTS

;************************************************
; PRINT_DEC:    prints the ASCII representation	*
; of the last conversion of integer		*
;************************************************
PRINT_DEC:
		PHA
		LDA	TMPD2
		STA	$E001
		LDA	TMPD1
		STA	$E001
		LDA	TMPD0
		STA	$E001
		PLA
		RTS


;************************************************
; DEC_SIGNED: converts the binary value in acc	*
; to a signed decimal string.			*
;						*
; Parameters: ACC, storing the value to be 	*
;	      converted.			*
;						*
; Return: the string - 				*
;	  SIGN: stores the signal ('+'/'-')	*
;	  STMPD2: the MSDigit			*
;	  STMPD1: the middle digit		*
;	  STMPD0: the LSDigit			*
;************************************************
DEC_SIGNED:	
		STA	TMP_A
		PHA
		JSR	PUSH_X
		JSR	PUSH_Y
		LDY	#7
		JSR	RIGHT_SHIFT	; MAKES ACC <- ACC >> 7 (to verify the most significant bit)
		CMP	#1		; IS ACC < 0?
		BEQ	NEG
POS:		LDX	#'+'
		STX	SIGN
		LDA	TMP_A
		JSR	DEC_ASCII	; PERFORMS A CONVERSION
		STA	TMPSVAL
		LDA	TMPD2
		STA	STMPD2
		LDA	TMPD1
		STA	STMPD1
		LDA	TMPD0
		STA	STMPD0
		JMP	END_SIGNED
NEG:		LDX	#'-'
		STX	SIGN
		LDA	TMP_A
		AND	#$7F		; EXTRACT ONLY THE 7-TH LEAST SIGNIFICANT BITS
		TAX
		STX	TMP_A
		LDA	#$80
		SBC	TMP_A		; ACC <- 128 - 7-TH LEAST SIGNIFICANT BITS
		STA	TMPSVAL
		JSR	DEC_ASCII
		LDA	TMPD2
		STA	STMPD2
		LDA	TMPD1
		STA	STMPD1
		LDA	TMPD0
		STA	STMPD0
END_SIGNED:	JSR	POP_Y
		JSR	POP_X
		PLA
		RTS


;************************************************
; PRINT_SIGNED: prints the ASCII string of	*
; an integer signed byte			*
;************************************************
PRINT_SIGNED:
		PHA
		LDA	SIGN
		STA	$E001
		LDA	STMPD2
		STA	$E001
		LDA	STMPD1
		STA	$E001
		LDA	STMPD0
		STA	$E001
		PLA		
		RTS

;************************************************
; CONV2: Converts the ascii-representationf of	*
; 2 characters into a single valid hex value.	*
; The ascii-representations is stored at	*
; CHAR1 and CHAR2				*
; 						*
; Parameters: none.				*
;						*
; Return: ACC, storing the hex-value.		*
;	  0x00 <= A <= 0xFF			*
;						*
; Affected registers: Acc			*
;************************************************
CONV2:
		; converts the CHAR1 into MSD
		LDA	CHAR1
		JSR	CONV
		STA	MSD
		; converts the CHAR2 into LSD
		LDA	CHAR2
		JSR	CONV
		STA	LSD
		LDA	MSD
		JSR	MULT_16
		CLC
		ADC	LSD
		RTS

;************************************************
; CONV: converts the ascii value accumulator in	*
; a valid hex value.				*
; Parameters:					*
;		A: the ascii representation of'	*
;		the typed digit.		*
; Return:					*
;		A, storing the hex-value	*
;************************************************
		
CONV:
		CMP	#$30
		BCC	CONV_ERR
		CMP	#$3A			; is the digit between 0 - 9 ascii? 
		BCC	IS_NUM			; yes, jump to numeric treatment
		JMP	IS_ALPHA
IS_NUM:		CLC				;the digit is in numeric interval (0-9)
		SBC	#$30			; A <- A - 30H
		CLC
		ADC	#$1
		RTS
IS_ALPHA:	CMP	#$41			; the digit is in alphabetic interval (A-F)			
		BCC	CONV_ERR
		CMP	#$47
		BCC	CONTINUE
		JMP	CONV_ERR
CONTINUE:	CLC
		SBC	#$37			; A <- A - 37H
		CLC
		ADC	#$1
		RTS
CONV_ERR:	JSR	HANDLER_ERR1		; handles with error exception code 1 - invalid input.
		LDA	#00
		STA	$E000
		JMP	INIT
		RTS


;************************************************
; MULT_16: multiply the acc per 16.		*
; Parameters: A, storing the value which will	*
;             be multiplied per 16.		*
;						*
; Return:     16*A				*
;						*
; Affected registers: A, only.			*
;************************************************

MULT_16:
		JSR	PUSH_X
		STA	TMP_A
		LDA	#0
		LDX	#16
LOOP_MULT:	CPX	#$0
		BEQ	END_MULT_16
		BCS	CONTINUE_MULT
CONTINUE_MULT:	CLC
		ADC	TMP_A
		DEX
		JMP	LOOP_MULT
END_MULT_16:	JSR	POP_X
		RTS


;************************************************
; NEW_LINE: prints a '\n' in the screen		*
; No register should be affected		*
;************************************************
NEW_LINE:
		PHA
		LDA	#$0A
		STA	$E001
		LDA	#$00D
		STA	$E001
		PLA
		RTS
;************************************************
; SUM_16BITS: sum the 2 unsigned values and	*
; then stores the unsigned result and print on	*
; screen					*
;************************************************ 
SUM_16BITS:
		LDA	VAL1
		CLC
		ADC	VAL2
		STA	SUM_LOW
		BCS	HIGH_SUM
		JMP	END_16BITS	
HIGH_SUM:	LDX	#$01
		STX	SUM_HIGH
END_16BITS:	RTS


;************************************************
; UNSIGNED_PRINT: prints the value in hex	*
; and decimal representation, ignoritng the	*
; the bit signal (msb)				*
;************************************************
UNSIGNED_PRINT:
		STA	TMP_A
		LDA	#'S'
		STA	$E001
		LDA	#'O'
		STA	$E001
		LDA	#'M'
		STA	$E001
		LDA	#'A'
		STA	$E001
		LDA	#':'
		STA	$E001
		LDA	#' '
		LDA	TMP_A
		PHA
		JSR	PUSH_Y
		LDA	SUM_HIGH
		STA	$E003
		LDA	SUM_LOW
		STA	$E003
		JSR	POP_Y
		PLA
		RTS
		
;************************************************
; HANDLER_ERR1: displays an error message	*
; when the terminal receives an invalid input i	*
; Invalid inputs i: i < '0', i = 40, i > 'F'	*
;************************************************

HANDLER_ERR1:
		PHA
		JSR	PUSH_X
		JSR	PUSH_Y
		LDX	#$00
		JSR	NEW_LINE
LOOP_ERR1:	LDA	MSG_ERROR1, X
		STA	$E001
		INX
		CMP	#00
		BNE	LOOP_ERR1
		LDY	#25
CALL_DELAY:	JSR	DELAY
		CPY	#1
		DEY
		BNE	CALL_DELAY
		JSR	POP_Y
		JSR	POP_X
		PLA
		RTS

;************************************************
; DELAY: generates a delay in the program to	*
; show the error message and then clean the	*
; screen					*
;************************************************
DELAY:
		JSR	PUSH_Y
		JSR	PUSH_X
		LDY	#$FF
DELAY1:		LDX	#$FF
DLY1:		DEX
		BNE	DLY1
		DEY
		BNE	DELAY1
		JSR	POP_X
		JSR	POP_Y
		RTS

;************************************************	
; PUSH_X: stores x register IN the stack.	*
;						*
; No other register is affected.		*
;************************************************
PUSH_X:
		PHP
		PHA
		STY	TMP_Y
		; Y <- index of the next available address on stack
		LDY	STACK_TOP
		; A <- X (relative address mode NOT ALLOWED for index register!)
		TXA
		STA	$3000, Y
		; increment by one the next available address on stack
		INY
		STY	STACK_TOP
		LDY	TMP_Y
		PLA
		PLP
		RTS

;************************************************
; POP_X: pull x register FROM the stack.	*
;						*
; No other register is affected.		*
;************************************************
POP_X:
		PHP
		PHA
		STY	TMP_Y
		; Y <- index of the next available address on stack
		LDY	STACK_TOP
		DEY
		LDA	$3000, Y
		TAX
		STY	STACK_TOP
		LDY	TMP_Y
		PLA
		PLP
		RTS


;************************************************	
; PUSH_Y: stores y register IN the stack.	*
;						*
; No other register is affected.		*
;************************************************
PUSH_Y:
		PHP
		PHA
		STX	TMP_X
		; x <- index of the next available address on stack
		LDX	STACK_TOP
		; A <- Y (relative address mode NOT ALLOWED for index register!)
		TYA
		STA	$3000, X
		; increment by one the next available address on stack
		INX
		STX	STACK_TOP
		LDX	TMP_X
		PLA
		PLP
		RTS

;************************************************
; POP_Y: pull y register FROM the stack.	*
;						*
; No other register is affected.		*
;************************************************
POP_Y:
		PHP
		PHA
		STX	TMP_X
		; x <- index of the next available address on stack
		LDX	STACK_TOP
		DEX
		LDA	$3000, X
		TAY
		STX	STACK_TOP
		LDX	TMP_X
		PLA
		PLP
		RTS

;************************************************
; X_TO_Y: transfer the contents of reg X to Y	*
;************************************************
X_TO_Y:
		PHA
		TXA
		TAY
		PLA
		RTS

;************************************************
; X_TO_Y: transfer the contents of reg X to Y	*
;************************************************

Y_TO_X:
		PHA
		TYA
		TAX
		PLA
		RTS

;************************************************
; RIGHT_SHIFT: performs a right shift Y times	*
; Parameters: Y, storing the number of shifts	*
;	    A, storing the value to be shifted	*
; Return:  A, storing the shifted value		*
;************************************************ 
RIGHT_SHIFT:   	CPY	#0
		BEQ	END_RGHT_SHIFT
		LSR
		DEY
		JMP	RIGHT_SHIFT
END_RGHT_SHIFT:	RTS


;================================================
; 3000: PSEUDO-STACK AREA.			=
; Yeah... I implemented my own stack		=
;================================================
		.ORG	$3000		 
STACK:		.DB	$00			; AS YOU CAN SEE, STACK HAS THE MAXIMUM SIZE OF 256 ELEMENTS. (0x00 - 0xFF)

		.ORG	$3100
STACK_TOP:	.DB	$00			; STORES THE NEXT AVAILABLE MEMORY ADDRES OF THE STACK.


;================================================
; 4000: TEMPORARY VARIABLE AREA			=
; Every memory variable is here... :)		=
;================================================

		.ORG	$4000
TMP_X:		.DB	00			; TEMPORARY VALUE FOR INDEX REGISTER X
TMP_Y:		.DB	00			; TEMPORARY VALUE FOR INDEX REGISTER Y
TMP_A:		.DB	00			; TEMPORARY VALUE FOR ACC

;************************************************
		.ORG	$4100
CHAR:		.DB	00
CHAR1:		.DB	00			; STORES THE ASCII-CHARARACTER OF THE MOST SIGNIFICANT DIGIT
CHAR2:		.DB	00			; STORES THE ASCII-CHARARACTER OF THE LEAST SIGNIFICANT DIGIT

;************************************************

MSD:		.DB	00			; STORES THE MOST SIGNIFICANT *HEX-DIGIT*
LSD:		.DB	00			; STORES THE LEAST SIGNIFICANT	*HEX-DIGIT*

;************************************************
		
VAL1:		.DB	00			; STORES THE FIRST HEX TYPED VALUE
VAL2:		.DB	00			; STORES THE SECOND HEX TYPED VALUE

TMPSVAL:	.DB	00
SIGNAL1:	.DB	00
SVAL1:		.DB	00

SIGNAL2:	.DB	00
SVAL2:		.DB	00

;************************************************

MSG_ERROR1:	.DB	"ERROR: Invalid input!"
END1:		.DB	00
;************************************************
		.ORG	$4200
TMP_ACC:	.DB	00
BIN1:		.DB	00
BIN1_END:	.DB	00
;************************************************
		.ORG	$4300
STR_BIN1:	.DB	00			; stores the first ascii representation of a binary value
		.ORG	$4308
STR_BIN2:	.DB	00			; stores the second ascii representation of a binary value
		.ORG	$4316
TMP_STR:	.DB	00			; stores a temporary ascii representation of a binary value (in REVERSE order)
		.ORG	$4340
TMP_STR2:	.DB	00
;************************************************
		.ORG	$4400
TMPD2:		.DB	00			; stores the most significant digit from last conversion dec-ascii
TMPD1:		.DB	00			; stores the second most significant digit from last conversion dec-ascii
TMPD0:		.DB	00			; stores the least significant digit from last conversion dec-ascii
;************************************************
		.ORG	$4500
SIGN:		.DB	00			; STORES THE CHAR '-' IF VALUE < 0, STORES '+', OTHERWISE
STMPD2:		.DB	00			; SIGNED TMP2
STMPD1:		.DB	00			; SIGNED TMP1
STMPD0:		.DB	00			; SIGNED TMP0
;************************************************
		.ORG	$4700
MSG_SIZE:	.DB	00			; DEFINES THE MESSAGE SIZE TO BE PRINTED
USR_MSG1:	.DB	"Insira um valor:"	; USER MESSAGE 1: Enter with a value
USR_MSG1_SZ:	.DB	16			; SIZE OF MESAGE 1
CURSOR_OUT:	.DB	"   >>> "
CURSOR_SIZE:	.DB	7
;************************************************
		.ORG	$4900
SUM_HIGH:	.DB	00
SUM_LOW:	.DB	00
HEX_DIGIT2:	.DB	00
HEX_DIGIT1:	.DB	00
HEX_DIGIT0:	.DB	00

		.ORG	$5000
SIGNED_SUM:	.DB	00
