;Utiliza dos pulsadores:
; - Con uno, se setea la cantidad de pulsos que genera.
; - Con el otro, se envian todos esos pulsos.
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
	contador
	muestreo
	ENDC

PRINCIPAL		EQU	0
PULSADOR		EQU	1
CUANTOS			EQU	2
STROBE			EQU 3
INDICADOR		EQU	7

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
	btfsc				INTCON,INT0IF
	goto				CODIGO_RB0
	goto				SALGO

CODIGO_RB0
	call				ret_20ms
	banksel				OPTION_REG
	btfss				OPTION_REG,INTEDG
	goto				DESCENDIO
	goto				ASCENDIO

DESCENDIO
	bsf					OPTION_REG,INTEDG
	banksel				PORTA
	bsf					flag,1
	goto				SALGO_RB0

ASCENDIO
	bcf					OPTION_REG,INTEDG
	banksel				PORTA
	bsf					flag,0
	goto				SALGO_RB0

SALGO_RB0
	bcf					INTCON,INT0IF

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
	movlw		b'00000000'
	movwf		TRISA			;Explicar por que tiene ese valor

	movlw		b'00000111'
	movwf		TRISB			;Explicar por que tiene ese valor

	banksel		OPTION_REG
	movlw		b'11000111'
	movwf		OPTION_REG		;Explicar por que tiene ese valor

	banksel		INTCON
	movlw		b'10000000'
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

		clrf				contador
MAIN

		btfss				PORTB,CUANTOS
		goto				CONTAR
		btfss				PORTB,PULSADOR
		goto				PRESENTAR
		goto				MAIN

CONTAR
		call				ret_20ms
		btfss				PORTB,CUANTOS
		goto				MAIN
		movlw				.9
		subwf				contador,w
		btfsc				STATUS,Z
		goto				MAIN
		incf				contador,1
		call				mostrar
		goto				MAIN

PRESENTAR
		banksel				INTCON
		bsf					INTCON,INT0IE
		banksel				PORTA
PRENDER
		btfss				flag,0
		goto				PRENDER
		bcf					flag,0
		bsf					PORTB,INDICADOR
		goto				APAGAR

APAGAR
		btfss				flag,1
		goto				APAGAR
		bcf					flag,1
		bcf					PORTB,INDICADOR
		decfsz				contador,1
		goto				CONTINUAR
		goto				REINICIAR

CONTINUAR
		call				mostrar
		goto				PRENDER

REINICIAR
		clrf				contador
		bcf					PORTB,INDICADOR
		banksel				INTCON
		bsf					INTCON,INT0IE
		banksel				PORTA
		call				mostrar
		goto				MAIN

mostrar
		movf				contador,w
		movwf				PORTA
		bcf					PORTB,STROBE
		nop
		nop
		nop
		bsf					PORTB,STROBE
		return

ret_20ms

		movlw				.178
		movwf				TMR0
		movlw				.0
		subwf				TMR0,w
		btfss				STATUS,Z
		goto				$-3
		return

		end