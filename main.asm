		.ORG	$300
		
		BRK
		

; 0x2000: SUB-ROUTINE AREA
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
		STA	$E000
LOOP_READ:	LDA	$E004
		CMP	#00
		BEQ	LOOP_READ
		STA	$E002			; exibe echo
		STA	CHAR, X
		INX
		CPX	#2
		BNE	LOOP_READ
		JSR	POP_X
		PLA
		RTS
		
;************************************************
; CONV: converts the ascii value accumulator in	*
; a valid hex value.				*
; Parameters:					*
;		A: the ascii representation of'	*
;		the typed digit.		*
; Return:					*
;		None.				*
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
		RTS


;************************************************
; HANDLER_ERR1: displays an error message	*
; when the terminal receives an invalid input i	*
; Invalid inputs i: i < '0', i = 40, i > 'F'	*
;************************************************

HANDLER_ERR1:
		PHA
		JSR	PUSH_X
		LDX	#$00
LOOP_ERR1:	LDA	MSG_ERROR1, X
		STA	$E001
		INX
		CMP	#00
		BNE	LOOP_ERR1
		JSR	POP_X
		PLA
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

; 3000: PSEUDO-STACK AREA
		.ORG	$3000		 
STACK:		.DB	$00			; AS YOU CAN SEE, STACK HAS THE MAXIMUM SIZE OF 256 ELEMENTS. (0x00 - 0xFF)

		.ORG	$3100
STACK_TOP:	.DB	$00			; STORES THE NEXT AVAILABLE MEMORY ADDRES OF THE STACK.


; 4000: TEMPORARY VARIABLE AREA
		.ORG	$4000
TMP_X:		.DB	00			; TEMPORARY VALUE FOR INDEX REGISTER X
TMP_Y:		.DB	00			; TEMPORARY VALUE FOR INDEX REGISTER Y

;************************************************

CHAR:		.DB	00
CHAR1:		.DB	00			; STORES THE ASCII-CHARARACTER OF THE MOST SIGNIFICANT DIGIT
CHAR2:		.DB	00			; STORES THE ASCII-CHARARACTER OF THE LEAST SIGNIFICANT DIGIT

;************************************************

MSD:		.DB	00			; STORES THE MOST SIGNIFICANT *HEX-DIGIT*
LSD:		.DB	00			; STORES THE LEAST SIGNIFICANT	*HEX-DIGIT*

;************************************************

MSG_ERROR1:	.DB	"ERROR: Invalid input!"
END1:		.DB	00