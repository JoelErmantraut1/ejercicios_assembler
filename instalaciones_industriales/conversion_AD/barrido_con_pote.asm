;Barrido de LEDs con velocidad ajustable con un potenciometro.
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
	valor_pa
	valor_pb
	val1
	val2
	ENDC

POTE			EQU 0

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
;---------------------------------------------------------------------------------------------------------------------------------
;LUGAR RESERVADO PARA EL CODIGO DE LA INTERRUPCION
;---------------------------------------------------------------------------------------------------------------------------------

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
		movlw		b'01100001'	;4MHZ
;									;BIT 0 SCS EN 1 PARA LA SELECCION DEL OSCILADOR INTERNO
;								_IRCF2 IRCF1 IRCF0 OSTS HTS LTS SCS
;							HTS DEBE ESTAR EN UNO PARA QUE LA CONFIGURACION DE LA FRECUENCIA SE HAGA DESDE
;							EL REGISTRO OSCCON SI ESTA EN CERO SE HACE DESDE LA CONFIGURACION
;					
		BANKSEL		OSCCON
		movwf		OSCCON
;		btfss		OSCCON,IOFS		;INTOSC Frecuency Stable Bit
;		goto		$-1				;PREGUNTO POR EL BIT IOFS DEL OSCCON ESPERANDO QUE PASE A UNO Y
; SE ESTABILICE EL OSCILADOR INTERN2O, CUANDO PASA A 1 ARRANCA LA INICIALIZACION

	banksel		PORTA
	CLRF		PORTA			;limpio PORTA para empezar

	banksel		PORTB
	CLRF		PORTB			;limpio PORTB para empezar

	banksel		ANSEL
	movlw		b'00000001'
	movwf		ANSEL			;AN1: POTENCIOMETRO

	banksel		TRISA
	movlw		b'00000011'
	movwf		TRISA			;RA1: POTENCIOMETRO DE ENTRADA

	movlw		b'00000000'
	movwf		TRISB			;8 LEDS, TODAS SALIDAS

	banksel		OPTION_REG
	movlw		b'10000101'
	movwf		OPTION_REG		;Preescaler en 256

	banksel		INTCON
	movlw		b'00000000'
	movwf		INTCON			;Explicar por que tiene ese valor

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
	movlw		b'11000000'
	movwf		ADCON0			;Explicar por que tiene ese valor

	banksel		ADCON1
	movlw		b'10000000'
	movwf		ADCON1			;5V = 00000011 11111111

;----------------------------------------------------------------------------------------------------------------------------------
;													COMIENZO DEL PROGRAMA
;----------------------------------------------------------------------------------------------------------------------------------
COMIENZA
;----------------------------------------------------------------------------------------------------------------------------------

		banksel			PORTA
ARRANCAR
		btfsc			PORTA,1
		goto			ARRANCAR
MAIN
		banksel			ADCON0
		bcf				ADCON0,CHS2
		bcf				ADCON0,CHS1
		bcf				ADCON0,CHS0
		;Selecciono canal 0 de conversion

		bsf				ADCON0,ADON
		;Habilito la conversion
		call			ret_10ms

		bsf				ADCON0,GO
		;Inicio la conversion
		call			ret_10ms

		btfsc			ADCON0,GO
		goto			$-1
		;Espera hasta que la conversion se termine

		;call			directo
		;Muestra el registro ADRESL directamente en PORTB

		goto			INDIRECTO
		;Prende una cantidad de LEDs directamente
		;proporcional a la tensión de entrada

RET
		call			ret_100ms
		goto			MAIN

directo
		banksel			ADRESL
		movf			ADRESL,w
		banksel			PORTB
		movwf			PORTB
		return

obtener_pa
		banksel			ADRESH
		movf			ADRESH,w
		banksel			PORTA
		movwf			valor_pa
		return

obtener_pb
		banksel			ADRESL
		movf			ADRESL,w
		banksel			PORTA
		movwf			valor_pb
		return

INDIRECTO
		call			obtener_pa
		call			obtener_pb

		movf			valor_pa,w
		movwf			val1
		movlw			.3
		movwf			val2

		call			comparar
		btfsc			flag,5
		goto			ES_3
		goto			ES_MENOR_A_3

ES_3
		movf			valor_pb,w
		movwf			val1
		movlw			.255
		movwf			val2

		call			comparar
		btfsc			flag,5
		goto			P_7
		
		movlw			.128
		movwf			val2

		call			comparar
		btfsc			flag,5
		goto			P_7
		btfsc			flag,6
		goto			P_6

		movlw			.0
		movwf			val2

		call			comparar
		btfsc			flag,5
		goto			P_6
		btfsc			flag,6
		goto			P_5
		goto			APAGAR_TODO

ES_MENOR_A_3
		movlw			.2
		movwf			val2

		call			comparar
		btfsc			flag,5
		goto			ES_2
		goto			ES_MENOR_A_2

ES_2
		movf			valor_pb,w
		movwf			val1
		movlw			.128
		movwf			val2

		call			comparar
		btfsc			flag,5
		goto			P_5
		btfsc			flag,6
		goto			P_4

		movlw			.0
		movwf			val2

		call			comparar
		btfsc			flag,5
		goto			P_4
		btfsc			flag,6
		goto			P_4
		goto			APAGAR_TODO

ES_MENOR_A_2
		movlw			.1
		movwf			val2

		call			comparar
		btfsc			flag,5
		goto			ES_1
		goto			ES_0

ES_1
		movf			valor_pb,w
		movwf			val1
		movlw			.128
		movwf			val2

		call			comparar
		btfsc			flag,5
		goto			P_3
		btfsc			flag,6
		goto			P_3

		movlw			.0
		movwf			val2

		call			comparar
		btfsc			flag,5
		goto			P_3
		btfsc			flag,6
		goto			P_2
		goto			APAGAR_TODO

ES_0
		movf			valor_pb,w
		movwf			val1
		movlw			.128
		movwf			val2

		call			comparar
		btfsc			flag,5
		goto			P_1
		btfsc			flag,6
		goto			P_1

		movlw			.0
		movwf			val2

		call			comparar
		btfsc			flag,5
		goto			APAGAR_TODO
		btfsc			flag,6
		goto			P_0

comparar
		bcf				STATUS,Z
		bcf				STATUS,C
		bcf				flag,5
		bcf				flag,6
		bcf				flag,7

		movf			val1,w
		subwf			val2,w
		btfsc			STATUS,Z
		bsf				flag,5
		btfss			STATUS,C
		goto			ES_MAYOR
		bsf				flag,7

VOLVER
		return

ES_MAYOR
		bsf				flag,6
		goto			VOLVER

P_7
		movlw			.255
		movwf			PORTB
		goto			RET

P_6
		movlw			.127
		movwf			PORTB
		goto			RET

P_5
		movlw			.63
		movwf			PORTB
		goto			RET

P_4
		movlw			.31
		movwf			PORTB
		goto			RET

P_3
		movlw			.15
		movwf			PORTB
		goto			RET

P_2
		movlw			.7
		movwf			PORTB
		goto			RET

P_1
		movlw			.3
		movwf			PORTB
		goto			RET

P_0
		movlw			.1
		movwf			PORTB
		goto			RET

APAGAR_TODO
		clrf			PORTB
		goto			RET

ret_10ms
		movlw			.10
		movlw			TMR0
		movlw			.0
		subwf			TMR0,w
		btfss			STATUS,Z
		goto			$-3
		return

ret_50ms
		movlw			.5
		movwf			veces2
		call			ret_10ms
		decfsz			veces2,1
		goto			$-2
		return

ret_100ms
		movlw			.2
		movwf			veces
		call			ret_50ms
		decfsz			veces,1
		goto			$-2
		return

		end