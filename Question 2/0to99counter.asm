LIST P = P16F877A
INCLUDE "P16F877A.INC"
__CONFIG H'3F31'

delay1 EQU 0x20
delay2 EQU 0x21
index  EQU 0x22
tens   EQU 0x23    ; Variable for tens digit
ones   EQU 0x24    ; Variable for ones digit

ORG 0x00

MAIN
    BANKSEL TRISD 
    CLRF    TRISD
    BANKSEL TRISC
    CLRF    TRISC
    BANKSEL PORTD
    CLRF    PORTD    ; Clear PORTD initially

    MOVLW   0x3F
    CLRF    PORTC
    BSF     PORTC, 0
    BSF     PORTC, 1
    BSF     PORTC, 2
    BSF     PORTC, 4
    MOVLW   0x00
    MOVWF   index
    CLRF    tens     ; Clear tens digit variable
    CLRF    ones     ; Clear ones digit variable

;---------------------------------------------------------------

LOOP
	
    MOVF    index, W
    CALL    table
    MOVWF   PORTD    ; Display ones digit

    MOVF    tens, W
    CALL    table
    MOVWF   PORTC    ; Display tens digit

    BTFSC   index, 3  ; Check if ones digit reached 8
    GOTO    IFEIGHT  ; If go to IFEIGHT


    CALL    DELAY    ; Delay between count updates
	INCF    index     ; Increment index
    INCF    ones     ; Increment ones digit

    GOTO    LOOP

;---------------------------------------------------------------

IFEIGHT				; Checking if its reached 10
	BTFSC index, 1 ; If bit 1 is set 0 skip / if 10
	GOTO  IFTEN
	
	CALL    DELAY    ; Delay between count updates
	INCF    index     ; Increment index
    INCF    ones     ; Increment ones digit

	GOTO LOOP
	
;---------------------------------------------------------------

IFTEN
    CLRF    ones     ; Clear ones digit
	CLRF	index
    INCF    tens     ; Increment tens digit

	;-----------------------------------------------
	MOVF    tens, W
    CALL    table
    MOVWF   PORTC    ; Display tens digit

	BTFSC   tens, 3  ; Check if tens digit reached 8
	GOTO	ITSEIGHTY

    GOTO    LOOP

;---------------------------------------------------------------

ITSEIGHTY
	BTFSC tens, 1 ; If bit 1 is set 1 tens become 10 
	GOTO  ITSONEHUNDRED

	GOTO LOOP

;---------------------------------------------------------------

ITSONEHUNDRED
	CLRF 	tens
	CLRF	ones
	CLRF	index
	CLRF	W
    CALL    table
    MOVWF   PORTC
	GOTO LOOP

;---------------------------------------------------------------

DELAY
    MOVLW   0xFF
    MOVWF   delay1

WAIT
    MOVLW   0xFF
    MOVWF   delay2

WAIT2
    DECFSZ  delay2, F
    GOTO    WAIT2

    DECFSZ  delay1, F
    GOTO    WAIT

    RETURN

table
    ADDWF   PCL, F
    RETLW   b'11111100' ; 0
    RETLW   b'01100000' ; 1
    RETLW   b'11011010' ; 2
    RETLW   b'11110010' ; 3
    RETLW   b'01100110' ; 4
    RETLW   b'10110110' ; 5
    RETLW   b'10111110' ; 6
    RETLW   b'11100000' ; 7
    RETLW   b'11111110' ; 8
    RETLW   b'11110110' ; 9

END
