;Contador con pulsador, que distingue entre flanco ascendente y descendente.
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
	contador
	ENDC

PULSADOR		EQU 0
STROBE			EQU	1
INDICADOR		EQU 7

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
;se guardan los registros
		MOVWF			W_TEMP	;se guarda W en w_temp
		MOVF			STATUS,W	;se guarda el status en W
		MOVWF			STATUS_TEMP	;W se lo guarda en STATUS_temp
		MOVF			PCLATH,W	;el registro pc_lath se lo guarda en W
		MOVWF			PCLATH_TEMP	;w se lo guarda en pclath_temp
		goto			INICIAR
;---------------------------------------------------------------------------------------------------------------------------------
;LUGAR RESERVADO PARA EL CODIGO DE LA INTERRUPCION
;---------------------------------------------------------------------------------------------------------------------------------

INICIAR
		btfsc				INTCON,INT0IF		;Si la interrupcion fue por RB0
		goto				FLANCO
		goto				SALGO

FLANCO
		call				ret_10ms
		btfss				PORTB,0			;Retardo para antirebote
		goto				SALGO
		banksel				OPTION_REG
		btfss				OPTION_REG,INTEDG
		goto				DESCENDIO
		goto				ASCENDIO

DESCENDIO										
		banksel				PORTB
		btfsc				PORTB,PULSADOR		;Testeo del antirebote
		goto				SALGO
		banksel				OPTION_REG
		bsf					OPTION_REG,INTEDG	;Cambio el bit para que la proxima se interrumpa en ascendente
		banksel				PORTB
		bsf					PORTB,INDICADOR
		goto				SALGO

ASCENDIO
		banksel				PORTB
		btfss				PORTB,PULSADOR		;Testeo del antirebote
		goto				SALGO
		banksel				OPTION_REG
		bcf					OPTION_REG,INTEDG	;Cambio el bit para que la proxima se interrumpa en descendente
		banksel				PORTB
		bcf					PORTB,INDICADOR
		bsf					flag,0				;Se setea el flag para avisar al main
		goto				SALGO

ret_10ms
		movlw				.176
		movwf				TMR0
		movlw				.0
		subwf				TMR0,w
		btfss				STATUS,Z
		goto				$-3
		return

SALGO
		bcf					INTCON,INT0IF		;Clarea el flag de interrupcion por RB0
;se recuperan los registros
		MOVF			PCLATH_TEMP,W		;W se carga con el registro pc_lath_temp
		MOVWF			PCLATH				;W se lo guarda en PCLATH
		MOVF			STATUS_TEMP,W		;STATUS_TEMP se guarda en W
		MOVWF			STATUS				;W se guarda en STATUS
		SWAPF			W_TEMP,F
		SWAPF			W_TEMP,W			;SE RECUPERA W
		RETFIE								;instruccion que SIRVE PARA VOLVER de la interrupcion
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
	movwf		TRISA			;Pulsador de MCLR

	movlw		b'00000001'
	movwf		TRISB			;Pulsador en RB0

	banksel		OPTION_REG
	movlw		b'10000110'
	movwf		OPTION_REG		;Resistencias internas, preescaler

	banksel		INTCON
	movlw		b'10010000'
	movwf		INTCON			;GIE, INT0IE

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
		banksel				PORTA ;SE ELIGE PARA MANEJARSE PARA EMPEZAR CON LOS REGISTROS CORRECTOS
			
			;LUGAR DONDE IRA EL CODIGO DEL PROGRAMA
;----------------------------------------------------------------------------------------------------------------------------------

MAIN
		btfss				flag,0			;Espera el aviso de la interrupcion
		goto				MAIN
		goto				DISPLAY

DISPLAY
		bcf					flag,0			;Lo clarea para no volver hasta el flanco ascendente
		movlw				.9
		subwf				contador,w
		btfsc				STATUS,Z
		goto				RESETEAR
		incf				contador,1
		call				mostrar
		goto				MAIN

RESETEAR
		clrf				contador
		call				mostrar
		goto				MAIN

mostrar
		movf				contador,w
		movwf				PORTA
		bsf					PORTB,STROBE
		nop
		nop
		nop
		bcf					PORTB,STROBE
		return	

		end