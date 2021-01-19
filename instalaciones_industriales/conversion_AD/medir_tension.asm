;Muestra el valor de tension medido en dos displays 7 segmentos.
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
	contador
	unidad
	decena
	valor_pa
	valor_pb
	repetir
	ENDC

STRB1			EQU 1
STRB2			EQU 2
POTE			EQU 7

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
	movlw		b'01000000'
	movwf		ANSEL			;AN6: POTENCIOMETRO

	banksel		TRISA
	movlw		b'00000000'
	movwf		TRISA			;RA0: POTENCIOMETRO DE ENTRADA

	movlw		b'10000000'
	movwf		TRISB			;RB7; POTENCIOMETRO

	banksel		OPTION_REG
	movlw		b'10000101'
	movwf		OPTION_REG		;Preescaler en 128

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
		movlw			.20
		movwf			contador
		bsf				PORTB,STRB1
		bsf				PORTB,STRB2
ARRANCAR
		btfsc			PORTA,1
		goto			ARRANCAR
MAIN
		banksel			ADCON0
		bsf				ADCON0,CHS2
		bsf				ADCON0,CHS1
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

		call			obtener

		call			ponde

		goto			MAIN

obtener
		banksel			ADRESH
		movf			ADRESH,w
		banksel			PORTA
		movwf			valor_pa

		banksel			ADRESL
		movf			ADRESL,w
		banksel			PORTA
		movwf			valor_pb

		return

ponde
		movlw			.1
		movwf			repetir
		btfsc			valor_pa,1
		call			sumar_512
		btfsc			valor_pa,0
		call			sumar_256

		call			mostrar

		return

sumar_512
		movlw			.255
		movwf			repetir
		call			aumentador
		movlw			.255
		movwf			repetir
		call			aumentador
		return

sumar_256
		movlw			.255
		movwf			repetir
		call			aumentador
		return

aumentador
		call			restar_contador
		decfsz			repetir,1
		goto			$-2
		return

restar_contador
		decfsz			contador,1
		return
		movlw			.20
		movwf			contador
		incf			unidad,1
		movlw			.10
		subwf			unidad,w
		btfss			STATUS,Z
		goto			INC_DEC
VOLVER
		return

INC_DEC
		clrf			unidad
		incf			decena,1
		goto			VOLVER

mostrar
		movf			unidad,w
		movwf			PORTB
		bcf				PORTB,STRB2
		nop
		nop
		nop
		bsf				PORTB,STRB2
		;Rutina de muestreo de la unidad

		movf			decena,w
		movwf			PORTB
		bcf				PORTB,STRB1
		nop
		nop
		nop
		bsf				PORTB,STRB1
		;Rutina de muestreo de la decena

		return

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