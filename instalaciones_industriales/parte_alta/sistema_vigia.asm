;-----------------------------------------------------------------------------------------------------------------------------------
;													DEFINICION DEL PROCESADOR
;-----------------------------------------------------------------------------------------------------------------------------------

	LIST	p=16F88				;directiva que define el procesador
	#INCLUDE <P16F88.INC>		;directiva que define las variables del procesador elegido
	ERRORLEVEL-302				;directiva que ELIMINA CIERTOS ERRORES DE COMPILACION
;-----------------------------------------------------------------------------------------------------------------------------------
; palabra de configuracion
    __CONFIG    _CONFIG1, _CP_OFF & _CCP1_RB0 & _DEBUG_OFF & _WRT_PROTECT_OFF & _CPD_OFF & _LVP_OFF & _BODEN_OFF & _MCLR_ON & _PWRTE_ON & _WDT_OFF & _INTRC_IO
    __CONFIG    _CONFIG2, _IESO_OFF & _FCMEN_OFF

;-----------------------------------------------------------------------------------------------------------------------------------
	CBLOCK 0x20 ;a partir de la direccion 0x20 se colocara las variables del programa.
;lugar donde se colocara las variables del programa a partir de 0x20 en adelante y secesivamente.

; CONTADOR
; SUMA
; FLAG
; etc.
	flag
	veces
	veces2
	ENDC

TEMP_AGUA		EQU 7
TEMP_ACEITE		EQU 6
PRE_ACEITE		EQU	5
PRE_COMB		EQU	4
IND_4			EQU 3
IND_3			EQU 2
IND_2			EQU 1
MOTOR			EQU 0
IND_1			EQU 0

W_TEMP			EQU	0x7D			;variable usada para ser guardada W cuando se va a una interrupcion.
STATUS_TEMP		EQU	0x7E			;variable usada para ser guardada STATUS cuando se va a una interrupcion.
PCLATH_TEMP		EQU	0x7F			;variable usada para ser guardada PC_LATH cuando se va a una interrupcion.
;----------------------------------------------------------------------------------------------------------------------------------
;                                   					VECTOR DE RESET
;----------------------------------------------------------------------------------------------------------------------------------

	ORG  0x0000		;vector de RESET
	PAGESEL	START
	GOTO	START	;va al comienzo de la inicializacion
;---------------------------------------------------------------------------------------------------------------------------------
;													RUTINA DE INTERRUPCION
;---------------------------------------------------------------------------------------------------------------------------------
ISR	ORG	0x0004		;UBICACION DEL VECTOR DE INTERRUPCION
;	se guardan los registros
	MOVWF	W_TEMP	;se guarda W en w_temp
	MOVF	STATUS,W	;se guarda el status en W
	MOVWF	STATUS_TEMP	;W se lo guarda en STATUS_temp
	MOVF	PCLATH,W	;el registro pc_lath se lo guarda en W
	MOVWF	PCLATH_TEMP	;w se lo guarda en pclath_temp
	goto	INICIAR
;---------------------------------------------------------------------------------------------------------------------------------
;LUGAR RESERVADO PARA EL CODIGO DE LA INTERRUPCION
;---------------------------------------------------------------------------------------------------------------------------------

INICIAR
	banksel			INTCON
	btfsc			INTCON,TMR0IF
	goto			CODIGO_TMR0
	btfsc			INTCON,RBIF
	goto			CODIGO_RB
	goto			SALGO

CODIGO_TMR0
	banksel			PORTB
	decfsz			veces,1
	goto			SALGO_TMR0
	movlw			.120
	movwf			veces
	decfsz			veces2,1
	goto			SALGO_TMR0
	bsf				flag,0
	goto			SALGO_TMR0

SALGO_TMR0
	bcf				INTCON,TMR0IF
	movlw			.61
	movwf			TMR0
	goto			SALGO

CODIGO_RB
	banksel			PORTB
	btfss			flag,1
	goto			AVISAR
	goto			VERIFICAR

AVISAR
	bsf				flag,1
	btfss			PORTB,TEMP_AGUA
	goto			ENC_1
	btfss			PORTB,TEMP_ACEITE
	goto			ENC_2
	btfss			PORTB,PRE_ACEITE
	goto			ENC_3
	btfss			PORTB,PRE_COMB
	goto			ENC_4
	goto			SALGO_RB

ENC_1
	bsf				PORTB,IND_1
	goto			SALGO_RB

ENC_2
	bsf				PORTB,IND_2
	goto			SALGO_RB

ENC_3
	bsf				PORTB,IND_3
	goto			SALGO_RB

ENC_4
	bsf				PORTB,IND_4
	goto			SALGO_RB

VERIFICAR
	btfss			PORTB,TEMP_AGUA
	goto			SALGO_RB
	btfss			PORTB,TEMP_ACEITE
	goto			SALGO_RB
	btfss			PORTB,PRE_ACEITE
	goto			SALGO_RB
	btfss			PORTB,PRE_COMB
	goto			SALGO_RB
	bsf				flag,2
	goto			SALGO_RB

SALGO_RB
	bcf				INTCON,RBIF
	goto			SALGO

SALGO
;se recuperan los registros
	MOVF	PCLATH_TEMP,W		;W se carga con el registro pc_lath_temp
	MOVWF	PCLATH				;W se lo guarda en PCLATH
	MOVF	STATUS_TEMP,W		;STATUS_TEMP se guarda en W
	MOVWF	STATUS				;W se guarda en STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W			;SE RECUPERA W
	RETFIE						;instruccion que SIRVE PARA VOLVER de la interrupci?
;---------------------------------------------------------------------------------------------------------------------------------
;													PROGRAMA (MAIN)
;---------------------------------------------------------------------------------------------------------------------------------
START
;---------------------------------------------------------------------------------------------------------------------------------
;											INICIALIZACION DEL MICROCONTROLADOR
;---------------------------------------------------------------------------------------------------------------------------------

;RUTINA QUE ESPERA QUE SE ESTABILICE EL OSCILADOR INTERNO ANTES DE EMPEZAR
				movlw  b'01100001'	;4MHZ
;									;BIT 0 SCS EN 1 PARA LA SELECCION DEL OSCILADOR INTERNO
;								_IRCF2 IRCF1 IRCF0 OSTS HTS LTS SCS
;							HTS DEBE ESTAR EN UNO PARA QUE LA CONFIGURACION DE LA FRECUENCIA SE HAGA DESDE
;							EL REGISTRO OSCCON SI ESTA EN CERO SE HACE DESDE LA CONFIGURACION
;					
		BANKSEL		OSCCON
		movwf		OSCCON
;		btfss		OSCCON,IOFS		;INTOSC Frecuency Stable Bit
;		goto		$-1				;PREGUNTO POR EL BIT IOFS DEL OSCCON ESPERANDO QUE PASE A UNO Y
; SE ESTABILICE EL OSCILADOR INTERNO, CUANDO PASA A 1 ARRANCA LA INICIALIZACION

	banksel		PORTA
	CLRF		PORTA			;limpio PORTA para empezar

	banksel		PORTB
	CLRF		PORTB			;limpio PORTB para empezar

	banksel		ANSEL
	movlw		b'00000000'
	movwf		ANSEL			;Explicar por que tiene ese valor

	banksel		TRISA
	movlw		b'00100000'
	movwf		TRISA			;Explicar por que tiene ese valor

	movlw		b'11110000'
	movwf		TRISB			;Explicar por que tiene ese valor

	banksel		OPTION_REG
	movlw		b'10000111'
	movwf		OPTION_REG		;Explicar por que tiene ese valor

	banksel		INTCON
	movlw		b'10001000'
	movwf		INTCON		;Explicar por que tiene ese valor

	banksel		PIR1
	movlw		b'00000000'
	movwf		PIR1			;Explicar por que tiene ese valor

	banksel		PIE1
	movlw		b'00000000'
	movwf		PIE1			;Explicar por que tiene ese valor

	banksel		PIR2
	movlw		b'00000000'
	movwf		PIR2			;Explicar por que tiene ese valor

	banksel		PIE2
	movlw		b'00000000'
	movwf		PIE2			;Explicar por que tiene ese valor

	banksel		PCON
	movlw		b'00000000'
	movwf		PCON			;Explicar por que tiene ese valor

	banksel		ADCON0
	movlw		b'00000000'
	movwf		ADCON0			;Explicar por que tiene ese valor

	banksel		ADCON1
	movlw		b'00000000'
	movwf		ADCON1			;Explicar por que tiene ese valor

;----------------------------------------------------------------------------------------------------------------------------------
;													COMIENZO DEL PROGRAMA
;----------------------------------------------------------------------------------------------------------------------------------
COMIENZA
			banksel		PORTA ;SE ELIGE PARA MANEJARSE PARA EMPEZAR CON LOS REGISTROS CORRECTOS
			
			;LUGAR DONDE IRA EL CODIGO DEL PROGRAMA
;----------------------------------------------------------------------------------------------------------------------------------

	bsf				PORTA,MOTOR
	btfss			PORTB,7
	goto			MAIN
MAIN
	btfss			flag,1
	goto			MAIN
	movlw			.61
	movwf			TMR0
	movlw			.120
	movwf			veces
	movlw			.10
	movwf			veces2
	banksel			INTCON
	bsf				INTCON,TMR0IE
	banksel			PORTA
	goto			CORRECCION

CORRECCION
	btfsc			flag,0
	goto			TERMINO
	btfsc			flag,2
	goto			CORREGIDO
	goto			CORRECCION

CORREGIDO
	bcf				PORTB,IND_1
	bcf				PORTB,IND_2
	bcf				PORTB,IND_3
	bcf				PORTB,IND_4
	bcf				flag,1
	bcf				flag,2
	banksel			INTCON
	bcf				INTCON,TMR0IE
	banksel			PORTA
	goto			MAIN

TERMINO
	bcf				PORTA,MOTOR
	goto			TERMINO

	END