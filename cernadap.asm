TITLE String Primitives & Macros    (cernadap.asm)

; Author: Paola Cernada
; Description: This programs asks the user to input 10 signed numbers (not > 32-bit registers).
;			   Once it has been confirmed that all inputs are valid. The user will be displayed a list
;			   of the properly inputted numbers, as well as their total sum and truncated average.


INCLUDE Irvine32.INC

; Macro definitions below:

; --------------------------------------------------------------------------------------------------------------------------
; Name: mGetString
;
; Displays an input prompt to collect input from the user.
;
; Preconditions: All parameters must be set to their default values.
;
; Receives:
; user_input_prompt = address OFFSET of a string to request input from the user.
; string_input		= address OFFSET at which input data must be saved.
; max_length		= amount of bytes that must be collected when a user enters data.
; str_length		= address OFFSET in which the length of the user input must be saved.
; str_output		= WriteVal's address OFFSET for output string.
; num_input_num		= present value of the input.
;
; returns: string_input, str_length
; --------------------------------------------------------------------------------------------------------------------------
mGetString MACRO user_input_prompt:REQ, string_input:REQ, max_length:REQ, str_length:REQ, str_output:REQ, num_input_num:REQ
; ...

	PUSH				EAX
	PUSH				ECX
	PUSH				EDX

	; display user input prompt
	mDisplayString		user_input_prompt
	PUSH				str_output
	PUSH				num_input_num
	CALL				WriteVal
	MOV					AL, separator
	CALL				WriteChar
	MOV					AL, space
	CALL				WriteChar

	; obtain and store the user's input
	MOV					EDX, string_input
	MOV					ECX, max_length
	CALL				ReadString				
	MOV					str_length, EAX

	; reset registers
	POP					EDX
	POP					ECX
	POP					EAX

ENDM

; --------------------------------------------------------------------------------------------------------------------------
; Name: mDisplayString
;
; Displays parameter string to console.
;
; Preconditions: String parameter must be set to its default value.
;
; Receives:
; str_output		= address OFFSET for output string.
;
; returns: string displayed on console
; --------------------------------------------------------------------------------------------------------------------------
mDisplayString MACRO str_output:REQ
; ...

	PUSH				EDX
	MOV					EDX, str_output
	CALL				WriteString
	POP					EDX

ENDM

; --------------------------------------------------------------------------------------------------------------------------
; Name: mDisplayTotal
;
; Displays a running subtotal of the user’s valid numbers.
;
; Preconditions: All parameters must be set to their default values.
;
; Receives:
; str_output		= WriteVal's address OFFSET for output string.
; total_msg			= address OFFSET of a string to indicate to the user that we are showing the total.
; running_subtotal	= entire amount as a signed integer.
;
; returns: total_msg, running_subtotal
; --------------------------------------------------------------------------------------------------------------------------
mDisplayTotal MACRO str_output:REQ, total_msg:REQ, running_subtotal:REQ
; ...

	; display total msg and val
	CALL				CrLf
	mDisplayString		total_msg
	PUSH				str_output
	PUSH				running_subtotal
	CALL				WriteVal
	CALL				CrLf

ENDM

; Constant definitions below:

NUM_COUNT			= 10
MAX_INPUT_LEN		= 15

.data

intro_msg_1				BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 13,10,0
intro_msg_2				BYTE	"Written by: Paola Cernada", 13,10,13,10,0

valid_numbers			BYTE	"Number each line of user input and display a running subtotal of the user's valid numbers.", 13,10,13,10,0
running_subtotal		BYTE	"The running subtotal of the valid numbers entered is: ", 0

user_instr				BYTE	"Please provide 10 signed decimal integers.", 13,10
						BYTE	"Each number needs to be small enough to fit inside a 32 bit register. After you have finished", 13,10
						BYTE	"inputting the raw numbers I will display a list of the integers, their sum, and their average value.", 13,10,13,10,0
user_input				BYTE	"Please enter a signed number: ", 0
user_input_2			BYTE	MAX_INPUT_LEN DUP(?)
invalid_input_msg		BYTE	"ERROR: You did not enter an signed number or your number was too big.", 13,10,0
entered_nums_msg		BYTE	"You entered the following numbers: ", 13,10,0
total_nums_sum_msg		BYTE	"The sum of these numbers is: ", 0
truncated_avg_msg		BYTE	"The truncated average is: ", 0
str_output				BYTE	MAX_INPUT_LEN DUP(?)
farewell_msg			BYTE	"Thanks for playing!", 13,10,0
separator				BYTE	")", 0
comma					BYTE	",", 0
space					BYTE	" ", 0

sign_input				SDWORD	1
nums_input				SDWORD	NUM_COUNT DUP(?)
error_flag				DWORD	0
input_len				DWORD	0

.code

main PROC

	;Color changed to yellow. 
	MOV					EAX, 14
	CALL				SetTextColor

	; Display the program's title and the programmer’s name.
	mDisplayString		OFFSET intro_msg_1
	mDisplayString		OFFSET intro_msg_2

	; Display instructions for user valid numbers.
	mDisplayString		OFFSET valid_numbers

	; Provide the user with the program's instructions.
	mDisplayString		OFFSET user_instr

; --------------------------------------------------------------------------------------------------------------------------
;	Section Comments:
;
;	Here, we'll ask the user to provide an integer.
;		Then, ensure that the user input number is valid.
;		If the user inputs an erroneous number/entry, an error notice 
;		is presented and the user is requested to re-enter a number 
;		until NUM_COUNT numbers are entered.
; --------------------------------------------------------------------------------------------------------------------------
	MOV					ECX, NUM_COUNT
	MOV					EDI, OFFSET nums_input

_userInput:

	PUSH				OFFSET running_subtotal
	PUSH				OFFSET nums_input
	PUSH				ECX
	PUSH				OFFSET str_output
	PUSH				OFFSET invalid_input_msg
	PUSH				EDI
	PUSH				OFFSET sign_input
	PUSH				OFFSET error_flag
	PUSH				OFFSET input_len
	PUSH				OFFSET user_input_2
	PUSH				OFFSET user_input
	CALL				ReadVal
	ADD					EDI, TYPE SDWORD
	LOOP				_userInput
; ...

; --------------------------------------------------------------------------------------------------------------------------
;	Section Comments:
;
;	Here, we'll display each of the numbers inputted by the user.
;		Then, calculate and display the total of the numbers inputted.
;		Calculate and display the truncated average of the numbers inputted.
; --------------------------------------------------------------------------------------------------------------------------
	PUSH				OFFSET str_output
	PUSH				OFFSET nums_input
	PUSH				OFFSET truncated_avg_msg
	PUSH				OFFSET total_nums_sum_msg
	PUSH				OFFSET entered_nums_msg
	CALL				displayOutput
; ...

; --------------------------------------------------------------------------------------------------------------------------
;	Section Comments:
;
;	Here, we'll display a farewell message.
; --------------------------------------------------------------------------------------------------------------------------
	CALL				CrLf
	CALL				CrLf
	mDisplayString		OFFSET farewell_msg
; ...

	exit
main ENDP

; --------------------------------------------------------------------------------------------------------------------------
; Name: ReadVal 
;
; Valid integers are converted from strings to SDWORDs before being put in an addr. location.
;
; Preconditions: addr. data must be initialized.
;
; Postconditions: Reset registers following procedure call.
;
; Receives:
;	[EBP+32]		= user_input_prompt								[EBP+52]		= addr. to save converted SDWORD val
;	[EBP+36]		= string_input									[EBP+56]		= invalid_input_msg
;	[EBP+40]		= str_length									[EBP+60]		= str_output
;	[EBP+44]		= error_flag									[EBP+64]		= ECX
;	[EBP+48]		= sign_input									[EBP+68]		= nums_input
;																	[EBP+72]		= running_subtotal
;
; returns:
;	[EBP+36]		= addr. string_input
;	[EBP+40]		= addr. str_length
;	[EBP+44]		= addr. error_flag
;	[EBP+48]		= addr. sign_input
;	[EBP+52]		= addr. converted SDWORD val
; --------------------------------------------------------------------------------------------------------------------------
ReadVal PROC USES EAX EBX ECX EDX EDI ESI
; ...

	PUSH				EBP
	MOV					EBP, ESP

_numInput:
	; number each line of user input
	MOV					EAX, NUM_COUNT
	SUB					EAX, [EBP+64]
	INC					EAX
	PUSH				EAX

	; running subtotal of the user's valid numbers
	MOV					ECX, EAX
	MOV					ESI, [EBP+68]
	MOV					EBX, 0								

_addNextNum:
	MOV					EAX, 0
	CLD
	LODSD
	ADD					EBX, EAX
	LOOP				_addNextNum
	POP					EAX

	; display running subtotal and prompt user for input
	mDisplayTotal		[EBP+60], [EBP+72], EBX
	mGetString			[EBP+32], [EBP+36], MAX_INPUT_LEN, [EBP+40], [EBP+60], EAX

	; sign_input
	PUSH				[EBP+48]
	
	; error_flag
	PUSH				[EBP+44]
	
	; str_length
	PUSH				[EBP+40]
	
	; string_input
	PUSH				[EBP+36]
	
	CALL				confirmString

	; if input not valid, an error msg is displayed and user asked to re-enter a number
	MOV					EAX, [EBP+44]
	MOV					EAX, [EAX]
	CMP					EAX, 0
	JNE					_invalidInputMsg

	; addr. to save converted SDWORD val
	PUSH				[EBP+52]	
	
	; addr. sign_input
	PUSH				[EBP+48]		
	
	; addr. error_flag
	PUSH				[EBP+44]					

	; addr. str_length
	PUSH				[EBP+40]
	
	; addr. string_input
	PUSH				[EBP+36]	
	
	CALL				convertString

	; ensure that there's no overflow error.
	MOV					EAX, [EBP+44]
	MOV					EAX, [EAX]
	CMP					EAX, 0
	JE					_invalidInputMsgEnd

_invalidInputMsg:
	; display invalid_input_msg
	mDisplayString		[EBP+56]

	; error flag reset
	MOV					EAX, [EBP+44]
	MOV					DWORD PTR [EAX], 0
	JMP					_numInput

_invalidInputMsgEnd:
	POP					EBP
	RET					44

ReadVal ENDP

; --------------------------------------------------------------------------------------------------------------------------
; Name: confirmString
;
; Verify the validity of each character in the input string, if not valid, error flag is set.
;
; Preconditions: addr. data must be initialized.
;
; Postconditions: Reset registers following procedure call.
;
; Receives:
;	[EBP+24]		= string_input
;	[EBP+28]		= str_length
;	[EBP+32]		= error_flag
;	[EBP+36]		= sign_input
;
; returns:
;	[EBP+32]		= addr. error_flag
;	[EBP+36]		= addr. sign_input
; --------------------------------------------------------------------------------------------------------------------------
confirmString PROC USES EAX ECX EDX ESI
; ...
	PUSH				EBP
	MOV					EBP, ESP

	; string_input
	MOV					ESI, [EBP+24]	
	
	; str_length
	MOV					ECX, [EBP+28]						

	; display error if input invalid
	CMP					ECX, 0
	JLE					_stringInvalid
	CMP					ECX, 12
	JGE					_stringInvalid

	; eax reset, the first ascii char loaded
	MOV					EAX, 0
	CLD
	LODSB

	; sign_input
	PUSH				[EBP+36]	
	
	; error_flag
	PUSH				[EBP+32]
	PUSH				EAX
	CALL				confirm1stChar
	DEC					ECX
	CMP					ECX, 0
	JLE					_stringValid

_nextASCIIchar:
	; eax is reset and the next ascii char read
	MOV					EAX, 0
	CLD
	LODSB											

	; confirm char validity, if char is not valid end loop
	PUSH				[EBP+32]							
	PUSH				EAX
	CALL				confirmChar
	MOV					EAX, 0
	MOV					EDX, [EBP+32]
	CMP					EAX, [EDX]
	JNE					_stringValid
	LOOP				_nextASCIIchar
	JMP					_stringValid

_stringInvalid:
	MOV					EAX, [EBP+32]
	MOV					DWORD PTR [EAX], 1

_stringValid:
	POP					EBP
	RET					16

confirmString ENDP

; --------------------------------------------------------------------------------------------------------------------------
; Name: confirm1stChar
;
; Verify the validity of the first character in the input string, if not valid, error flag is set.
; The sign flag is set to -1 if a negative sign is identified.
; It accepts +, -, and numerical input characters in ASCII.
;
; Preconditions: addr. data must be initialized.
;
; Postconditions: Reset registers following procedure call.
;
; Receives:
;	[EBP+16]		= char byte
;	[EBP+20]		= error_flag
;	[EBP+24]		= sign_input
;
; returns:
;	[EBP+20]		= addr. error_flag
;	[EBP+24]		= addr. sign_input
; --------------------------------------------------------------------------------------------------------------------------
confirm1stChar PROC USES EAX EDX
; ...

	PUSH				EBP
	MOV					EBP, ESP
	MOV					EAX, [EBP+16]

	; confirm sign_input, confirm char in specified range
	CMP					EAX, 2Bh		
	JE					_1stCharValid
	CMP					EAX, 2Dh		
	JE					_negativeSign
	CMP					EAX, 30h
	JB					_1stCharInvalid
	CMP					EAX, 39h
	JA					_1stCharInvalid
	JMP					_1stCharValid

_negativeSign:
	; set sign flag -1
	MOV					EAX, [EBP+24]
	MOV					EDX, -1
	MOV					[EAX], EDX
	JMP					_1stCharValid

_1stCharInvalid:
	; set error flag
	MOV					EAX, [EBP+20]
	MOV					DWORD PTR [EAX], 1

_1stCharValid:
	POP					EBP
	RET					12

confirm1stChar ENDP

; --------------------------------------------------------------------------------------------------------------------------
; Name: confirmChar
;
; Verify the validity of a character in the input string, if not valid, error flag is set.
; It accepts numerical input characters in ASCII.
;
; Preconditions: addr. data must be initialized.
;
; Postconditions: Reset registers following procedure call.
;
; Receives:
;	[EBP+12]		= char byte
;	[EBP+16]		= error_flag
;
; returns:
;	[EBP+16]		= addr. error_flag
; --------------------------------------------------------------------------------------------------------------------------
confirmChar PROC USES EAX
; ...

	; move ascii to eax, confirm char in specified range
	PUSH				EBP
	MOV					EBP, ESP
	MOV					EAX, [EBP+12]
	CMP					EAX, 30h
	JB					_invalidChar
	CMP					EAX, 39h
	JA					_invalidChar
	JMP					_validChar

_invalidChar:
	; set error flag
	MOV					EAX, [EBP+16]
	MOV					DWORD PTR [EAX], 1		

_validChar:
	POP					EBP
	RET					8

confirmChar ENDP

; --------------------------------------------------------------------------------------------------------------------------
; Name: convertString
;
; Valid strings are converted to SDWORD val.
; If the value is too big, error flag is set.
;
; Preconditions: addr. data must be initialized.
;
; Postconditions: Reset registers following procedure call.
;
; Receives:
;	[EBP+32]		= string_input
;	[EBP+36]		= str_length
;	[EBP+40]		= error_flag
;	[EBP+44]		= sign_input
;	[EBP+48]		= addr. to save converted SDWORD val
;
; returns:
;	[EBP+40]		= addr. error_flag
;	[EBP+48]		= addr. converted SDWORD val
; --------------------------------------------------------------------------------------------------------------------------
convertString PROC USES EAX EBX ECX EDX EDI ESI
; ...

	PUSH				EBP
	MOV					EBP, ESP
	MOV					ESI, [EBP+32]						
	MOV					EDI, [EBP+48]						
	MOV					ECX, [EBP+36]						
	MOV					EBX, 0								
	MOV					EDX, 1								

	; point esi to last char
	MOV					EAX, ECX
	DEC					EAX
	ADD					ESI, EAX

_addInt:
	; eax is reset and the next ascii char read
	; at the end of the string if character is a sign
	MOV					EAX, 0
	STD
	LODSB
	CMP					EAX, 2Bh	
	JE					_multiplySF
	CMP					EAX, 2Dh	
	JE					_multiplySF
	SUB					EAX, 30h
	PUSH				EDX
	IMUL				EDX									
	ADD					EBX, EAX

	; jump if overflow error
	JO				_overflowError

	; set next cycle
	POP					EDX
	MOV					EAX, EDX
	MOV					EDX, 10
	IMUL				EDX
	MOV					EDX, EAX
	LOOP				_addInt

_multiplySF:

	; multiply last int by its SF
	MOV					EAX, EBX
	MOV					EBX, [EBP+44]						
	MOV					EBX, [EBX]
	IMUL				EBX									

	; SF reset
	MOV					EBX, [EBP+44]	
	MOV					SDWORD PTR [EBX], 1
	MOV					[EDI], EAX
	JMP					_convertStringEnd

_overflowError:
	POP					EDX
	MOV					EAX, [EBP+40]
	MOV					DWORD PTR [EAX], 1

_convertStringEnd:
	POP					EBP
	RET					20

convertString ENDP

; --------------------------------------------------------------------------------------------------------------------------
; Name: WriteVal 
;
; Valid integers are converted from SDWORDs to strings and displayed on the console.
;
; Preconditions: addr. data must be initialized.
;
; Postconditions: Reset registers following procedure call.
;
; Receives: 
;	[EBP+28], [EBP+32]		
;
; returns: 
;	[EBP+32]		= str_output
; --------------------------------------------------------------------------------------------------------------------------
WriteVal PROC USES EAX EBX ECX EDX EDI
; ...

	PUSH				EBP
	MOV					EBP, ESP

	; int val to convert to str
	MOV					EDX, [EBP+28]		
	
	; output
	MOV					EDI, [EBP+32]			
	
	; number of loop's needed
	MOV					ECX, 10					
	
	; greatest divisor
	MOV					EBX, 1000000000						

	; check if SDWORD is negative num
	CMP					EDX, 0
	JL					_negativeNum
	JMP					_getChar

_negativeNum:
	NEG					EDX
	MOV					EAX, '-'
	STOSB			

_getChar:
	; get leading num of the int input
	MOV					EAX, EDX
	CDQ

	; quot in eax, rem in edx
	DIV					EBX									
	PUSH				EDX

	; save leading num if != 0 or it's the last num
	CMP					EAX, 0
	JNE					_storeChar
	CMP					ECX, 1
	JE					_storeChar
	PUSH				EAX
	PUSH				EBX
	MOV					EAX, [EBP+32]

_validateNextChar:

	; check output srt for non zero digits, else, check next character
	MOV				BL, BYTE PTR [EAX]
	CMP				BL, 31h
	JGE				_noLeadingZero
	INC				EAX
	CMP				EDI, EAX
	JLE				_yesLeadingZero
	JMP				_validateNextChar

_yesLeadingZero:
	; if quot == leading 0, registers reset and no storeChar
	POP					EBX
	POP					EAX
	JMP					_storeCharFinish

_noLeadingZero:
	; if quot != leading 0, registers reset and storeChar
	POP					EBX
	POP					EAX

_storeChar:
	ADD					EAX, 30h
	STOSB

_storeCharFinish:
	; ebx divided by 10
	MOV					EAX, EBX
	CDQ
	MOV					EBX, 10
	DIV					EBX
	MOV					EBX, EAX
	POP					EDX
	LOOP				_getChar
	MOV					EAX, 0
	STOSB

	; display str_output
	mDisplayString		[EBP+32]

	; remove str_output
	MOV					ECX, MAX_INPUT_LEN
	MOV					EDI, [EBP+32]
	MOV					EAX, 0
	REP					STOSB
	POP					EBP
	RET					8

WriteVal ENDP

; --------------------------------------------------------------------------------------------------------------------------
; Name: displayOutput 
;
; Display each of the numbers inputted by the user.
; Calculate and display the total sum of these numbers inputted and their truncated average.
;
; Preconditions: addr. data must be valid.
;
; Postconditions: Reset registers following procedure call.
;
; Receives:
;	entered_nums_msg, total_nums_sum_msg, truncated_avg_msg
;	[EBP+40]		= addr. array
;   [EBP+44]		= addr. to save str_output
;
; returns: 
;	[EBP+44]		= str_output
; --------------------------------------------------------------------------------------------------------------------------
displayOutput PROC USES EAX EBX ECX EDX ESI
; ...

	PUSH				EBP
	MOV					EBP, ESP
	MOV					ECX, NUM_COUNT
	MOV					ESI, [EBP+40]

	; entered_nums_msg
	CALL				CrLf
	mDisplayString		[EBP+28]

_displayNum:
	; next index moved to eax
	LODSD

	; str_output
	PUSH				[EBP+44]							

	; num to convert
	PUSH				EAX									
	CALL				WriteVal

	; check if last num, else insert comma and space
	CMP					ECX, 1
	JE					_totalSum
	MOV					AL, comma
	CALL				WriteChar
	MOV					AL, space
	CALL				WriteChar
	LOOP				_displayNum

_totalSum:
	MOV					ECX, NUM_COUNT
	MOV					ESI, [EBP+40]
	MOV					EBX, 0								

_addNextNum:
	; next val to EAX
	LODSD
	ADD					EBX, EAX
	LOOP				_addNextNum

	; total_nums_sum_msg, str_output
	CALL				CrLf
	CALL				CrLf
	mDisplayString		[EBP+32]
	MOV					EAX, EBX
	PUSH				[EBP+44]							
	PUSH				EAX									
	CALL				WriteVal

_truncatedAvg:
	; total nums sum / total entered nums
	MOV					EBX, NUM_COUNT
	CDQ
	IDIV				EBX									

	; truncated_avg_msg, str_output
	CALL				CrLf
	CALL				CrLf
	mDisplayString		[EBP+36]
	PUSH				[EBP+44]							
	PUSH				EAX									
	CALL				WriteVal
	POP					EBP
	RET					16

	Invoke ExitProcess,0
displayOutput ENDP

END main