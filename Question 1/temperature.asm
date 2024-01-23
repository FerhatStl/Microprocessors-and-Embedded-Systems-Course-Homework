LIST P=PIC16F877A
#include <P16F877A.INC>
__CONFIG H'3F31'

#define RS PORTC,0         ; LCD Data/Command Bit
#define RW PORTC,1         ; Read/Write Data Bit
#define EN PORTC,2         ; LCD Enable Bit

sayac1 EQU 20h            ; Delay Variables...
sayac2 EQU 21h            
sayac3 EQU 22h            
sayac4 EQU 23h

TEMP   	EQU 24h
LSD		EQU	25h
MSD		EQU	26h


;--------------------------------------------------
ORG 0x00
GOTO START
;--------------------------------------------------

START
    MOVLW	0XFF			
    BANKSEL	TRISA
    MOVWF	TRISA
    CLRF	TRISA

    BANKSEL	PORTA			
    CLRF	PORTA
    CLRF	PORTB

    BANKSEL	TRISB			
    CLRF	TRISB

    BANKSEL	TRISD			
    CLRF	TRISD
    CLRF	TRISC

    BANKSEL PORTD			
    CLRF	PORTD
    CLRF	PORTC

    CALL	LCD_INIT

    MOVLW 	B'01001001'   ;0X41    ADC Clock Fosc*1/8 ADON=1    
    MOVWF 	ADCON0
    BANKSEL ADCON1
    MOVLW 	B'10000000'   ;0X80
    MOVWF 	ADCON1

LOOP
    MOVLW 0x80
    CALL LCD_COMMAND
	BANKSEL	PORTD
    MOVWF	PORTD
	CALL 	PRINT_TEMP			
    CALL	DELAY

    MOVLW 0x01
    CALL LCD_COMMAND
    GOTO LOOP

;--------------------------------------------------
PRINT_TEMP
    MOVLW 'T'    ; Display "TEMPERATURE: "
    CALL LCD_DATA
    MOVLW 'E'
    CALL LCD_DATA
    MOVLW 'M'
    CALL LCD_DATA
    MOVLW 'P'
    CALL LCD_DATA
    MOVLW 'E'
    CALL LCD_DATA
    MOVLW 'R'
    CALL LCD_DATA
    MOVLW 'A'
    CALL LCD_DATA
    MOVLW 'T'
    CALL LCD_DATA
    MOVLW 'U'
    CALL LCD_DATA
    MOVLW 'R'
    CALL LCD_DATA
    MOVLW 'E'
    CALL LCD_DATA
    MOVLW ':'
    CALL LCD_DATA
    MOVLW ' '
    CALL LCD_DATA

	CALL	ReadADC
    BANKSEL	PORTD
    MOVFW	MSD
    BANKSEL	PORTB
    MOVWF	PORTB
    ADDLW	0X30			
    CALL	LCD_DATA

	MOVFW	LSD
    ANDLW	0X0F			
    ADDLW	0X30			
    CALL	LCD_DATA

    MOVLW 'C'
    CALL LCD_DATA
	RETURN
;------------------------------------------------------
ReadADC             
    BANKSEL ADCON0
    BSF ADCON0,GO
    BTFSC ADCON0,GO
    GOTO $-1
    BANKSEL ADRESH
    RRF ADRESH,F
    BANKSEL ADRESL
    RRF ADRESL,W

	BANKSEL PORTD
	CALL HEXTODEC
    RETURN
;--------------------------------------------------
HEXTODEC:
    CLRF	MSD					
    MOVWF	LSD

    gtenth
        MOVLW	.10
        SUBWF	LSD, W
        BTFSS	STATUS, C
        GOTO	ENDING
        MOVWF	LSD
        INCF	MSD, F
        GOTO	gtenth

    ENDING
        retlw	0

    RETURN
;--------------------------------------------------
LCD_DATA
    BSF RS     ; RS = 1
    BCF RW     ; RW = 0
    BSF EN     ; EN = 1
	CALL DELAY
    MOVWF PORTD
	CALL DELAY
    BCF EN     ; EN = 0
    RETURN

;--------------------------------------------------
LCD_COMMAND
    BCF RS     ; RS = 0
    BCF RW     ; RW = 0
    BSF EN     ; EN = 1
    CALL DELAY
    MOVWF PORTD ; PORTD = W
	CALL DELAY
    BCF EN     ; EN = 0
    RETURN

;--------------------------------------------------
LCD_INIT
    MOVLW 0x38   ; 2 lines and 5x7 Char Set
    CALL LCD_COMMAND
    MOVLW 0x06
    CALL LCD_COMMAND
    MOVLW 0x0F
    CALL LCD_COMMAND
    MOVLW 0x01   ; Clear Screen
    CALL LCD_COMMAND
    RETURN

;--------------------------------------------------
DELAY
	MOVWF TEMP
	MOVLW 0x7F
    MOVWF sayac1
L1
    MOVLW 0x55
    MOVWF sayac2
L2
    DECFSZ sayac2
    GOTO L2
    DECFSZ sayac1
    GOTO L1

	MOVFW TEMP
 	RETURN

;--------------------------------------------------
END
