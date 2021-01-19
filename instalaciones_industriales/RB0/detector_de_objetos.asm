;Detector de objetos con interrupciones.
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
	ENDC

PULSADOR		EQU 0
STROBE			EQU	1
SENSOR			EQU 2
MOTOR			EQU	5

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
	btfsc				INTCON,TMR0IF
	goto				CODIGO_TMR0
	btfsc				INTCON,INT0IF
	goto				CODIGO_RB0
	goto				SALGO

CODIGO_TMR0
	decfsz				veces,1
	goto				SALGO_TMR0
	bsf					flag,0
SALGO_TMR0
	bcf					INTCON,TMR0IF
	movlw				.61
	movwf				TMR0
	goto				SALGO

CODIGO_RB0
	call				ret_20ms
	banksel				PORTB
	btfsc				PORTB,PULSADOR
	goto				SALGO_RB0
	bsf					flag,1
SALGO_RB0
	bcf					INTCON,INT0IF
	goto				SALGO

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

	movlw		b'00000101'
	movwf		TRISB			;Explicar por que tiene ese valor

	banksel		OPTION_REG
	movlw		b'10000111'
	movwf		OPTION_REG		;Explicar por que tiene ese valor

	banksel		INTCON
	movlw		b'10010000'
	movwf		INTCON			;GIE, TMR0IE, INT0IE

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

		bcf					PORTB,MOTOR

		movlw				.61
		movwf				TMR0

		clrf				veces
		clrf				flag
		clrf				contador
		call				mostrar

MAIN
		btfss				flag,1
		goto				MAIN
		goto				CORRER

CORRER
		movlw				.60
		movwf				veces
		call				retardo

		bsf					PORTB,MOTOR
		bcf					flag,1
TESTEAR
		btfsc				PORTB,SENSOR
		goto				TESTEAR
		goto				ANTIREBOTE

ANTIREBOTE
		call				ret_20ms
		
		btfss				PORTB,SENSOR
		goto				TESTEAR
		goto				CONTAR

CONTAR
		incf				contador,1
		call				mostrar
		movlw				.5
		subwf				contador,w
		btfss				STATUS,Z
		goto				TESTEAR
		goto				FRENAR

FRENAR
		bcf					PORTB,5
		clrf				contador
		call				mostrar

		movlw				.200
		movwf				veces
		call				retardo
		goto				CORRER

mostrar
		movf				contador,w
		movwf				PORTA
		bcf					PORTB,STROBE
		nop
		nop
		nop
		bsf					PORTB,STROBE
		return

retardo
		bsf					INTCON,TMR0IE
		btfss				flag,0
		goto				$-1
		bcf					INTCON,TMR0IE
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