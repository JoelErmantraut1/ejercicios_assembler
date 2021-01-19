;Generador de señales configurable con parte alta de RB.
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
	frecuencia
	flag
	veces
	veces2
	veces3
	carga
	orden
	ENDC

FREC			EQU 0
SALIDA			EQU 1
STROBE			EQU 2
DUTY_10			EQU 4
DUTY_90			EQU 5

TIEMPO			EQU 0
PULS_RB0		EQU 1
PARTE_ALTA		EQU 2
DUTY			EQU 3
ESTADO			EQU 4

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
	btfsc			INTCON,TMR0IF
	goto			CODIGO_TMR0
	btfsc			INTCON,INT0IF
	goto			CODIGO_RB0
	btfsc			INTCON,RBIF
	goto			CODIGO_RB
	goto			SALGO

CODIGO_TMR0
	decfsz			veces,1
	goto			SALGO_TMR0
	decfsz			veces2,1
	goto			SALGO_TMR0
	movf			carga,w
	movwf			veces
	movlw			.1
	movwf			veces2
	decfsz			veces3,1
	goto			SALGO_TMR0
	bsf				flag,TIEMPO
	goto			SALGO_TMR0

SALGO_TMR0
	movlw			.248
	movwf			TMR0
	bcf				INTCON,TMR0IF
	goto			SALGO

CODIGO_RB0
	call			ret_10ms
	movlw			.9
	subwf			frecuencia,w
	btfss			STATUS,Z
	goto			INCREMENTAR
	clrf			frecuencia
	call			mostrar
	goto			SALGO_RB0

INCREMENTAR
	incf			frecuencia,1
	clrf			orden

	movlw			.1
	subwf			frecuencia,w
	btfsc			STATUS,Z
	bsf				orden,0

	movlw			.2
	subwf			frecuencia,w
	btfsc			STATUS,Z
	bsf				orden,1

	movlw			.3
	subwf			frecuencia,w
	btfsc			STATUS,Z
	bsf				orden,2

	movlw			.4
	subwf			frecuencia,w
	btfsc			STATUS,Z
	bsf				orden,3

	movlw			.5
	subwf			frecuencia,w
	btfsc			STATUS,Z
	bsf				orden,4

	movlw			.6
	subwf			frecuencia,w
	btfsc			STATUS,Z
	bsf				orden,5

	movlw			.7
	subwf			frecuencia,w
	btfsc			STATUS,Z
	bsf				orden,6

	movlw			.8
	subwf			frecuencia,w
	btfsc			STATUS,Z
	bsf				orden,7

	movlw			.1
	subwf			frecuencia,w
	btfsc			STATUS,Z
	clrf			orden

	call			mostrar
	goto			SALGO_RB0

SALGO_RB0
	bcf				INTCON,INT0IF
	goto			SALGO

CODIGO_RB
	btfss			PORTB,DUTY_10
	goto			SEL_DUTY_10
	btfss			PORTB,DUTY_90
	goto			SEL_DUTY_90
	goto			SALGO_RB

SEL_DUTY_10
	bsf				flag,DUTY
	goto			SALGO_RB

SEL_DUTY_90
	bcf				flag,DUTY
	goto			SALGO_RB

SALGO_RB
	bcf				INTCON,RBIF
	goto			SALGO

ret_10ms
	movlw			.100
	movwf			TMR0
	movlw			.0
	subwf			TMR0,w
	btfss			STATUS,Z
	goto			$-3
	return

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
; SE ESTABILICE EL OSCILADOR INTERN2O, CUANDO PASA A 1 ARRANCA LA INICIALIZACION

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

	movlw		b'00110001'
	movwf		TRISB			;Explicar por que tiene ese valor

	banksel		OPTION_REG
	movlw		b'10000110'
	movwf		OPTION_REG		;Explicar por que tiene ese valor

	banksel		INTCON
	movlw		b'10111000'
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

	bsf					PORTB,STROBE
	movlw				.1
	movwf				frecuencia
	call				mostrar
	;Frecuencia INICIAL: 1 Hz
	movlw				.248
	movwf				TMR0
	bcf					flag,ESTADO
	bsf					orden,0
	btfsc				PORTB,4
	nop
	goto				ASCENDER
	;Utilizado para interrumpir parte alta
MAIN
	btfss				flag,TIEMPO
	goto				MAIN
	bcf					flag,TIEMPO
	btfss				flag,ESTADO
	goto				ASCENDER
	goto				DESCENDER

ASCENDER
	bsf					flag,ESTADO
	bsf					PORTB,SALIDA
	btfss				flag,DUTY
	goto				SET_DUTY_10
	goto				SET_DUTY_90

DESCENDER
	bcf					flag,ESTADO
	bcf					PORTB,SALIDA
	btfss				flag,DUTY
	goto				SET_DUTY_90
	goto				SET_DUTY_10

SET_DUTY_10
	movlw				.1
	movwf				veces
	movlw				.1
	movwf				veces2
	movlw				.1
	movwf				veces3
	btfsc				orden,0
	goto				FREC_1HZ_10
	btfsc				orden,1
	goto				FREC_2HZ_10
	btfsc				orden,2
	goto				FREC_3HZ_10
	btfsc				orden,4
	goto				FREC_5HZ_10
	btfsc				orden,5
	goto				FREC_6HZ_10
	btfsc				orden,6
	goto				FREC_7HZ_10
	btfsc				orden,7
	goto				FREC_8HZ_10
	goto				FREC_9HZ_10

FREC_1HZ_10
	movlw				.100
	movwf				veces
	goto				MAIN
FREC_2HZ_10
	movlw				.50
	movwf				veces
	goto				MAIN
FREC_3HZ_10
	movlw				.33
	movwf				veces
	goto				MAIN
FREC_4HZ_10
	movlw				.25
	movwf				veces
	goto				MAIN
FREC_5HZ_10
	movlw				.20
	movwf				veces
	goto				MAIN
FREC_6HZ_10
	movlw				.16
	movwf				veces
	goto				MAIN
FREC_7HZ_10
	movlw				.14
	movwf				veces
	goto				MAIN
FREC_8HZ_10
	movlw				.12
	movwf				veces
	goto				MAIN
FREC_9HZ_10
	movlw				.11
	movwf				veces
	goto				MAIN

SET_DUTY_90
	movlw				.1
	movwf				veces
	movlw				.1
	movwf				veces2
	movlw				.1
	movwf				veces3
	btfsc				orden,0
	goto				FREC_1HZ_90
	btfsc				orden,1
	goto				FREC_2HZ_90
	btfsc				orden,2
	goto				FREC_3HZ_90
	btfsc				orden,4
	goto				FREC_5HZ_90
	btfsc				orden,5
	goto				FREC_6HZ_90
	btfsc				orden,6
	goto				FREC_7HZ_90
	btfsc				orden,7
	goto				FREC_8HZ_90
	goto				FREC_9HZ_90

FREC_1HZ_90
	movlw				.225
	movwf				veces
	movlw				.4
	movwf				veces3
	goto				MAIN
FREC_2HZ_90
	movlw				.225
	movwf				veces
	movlw				.2
	movwf				veces3
	goto				MAIN
FREC_3HZ_90
	movlw				.255
	movwf				veces
	movlw				.45
	movwf				veces2
	goto				MAIN
FREC_4HZ_90
	movlw				.225
	movwf				veces
	goto				MAIN
FREC_5HZ_90
	movlw				.180
	movwf				veces
	goto				MAIN
FREC_6HZ_90
	movlw				.150
	movwf				veces
	goto				MAIN
FREC_7HZ_90
	movlw				.128
	movwf				veces
	goto				MAIN
FREC_8HZ_90
	movlw				.112
	movwf				veces
	goto				MAIN
FREC_9HZ_90
	movlw				.100
	movwf				veces
	goto				MAIN

mostrar
	movf			frecuencia,w
	movwf			PORTA
	bcf				PORTB,STROBE
	nop
	nop
	nop
	bsf				PORTB,STROBE
	return

	END