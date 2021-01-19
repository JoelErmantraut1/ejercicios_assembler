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
	cambio
	repeat
	ENDC

FRENO			EQU 1
SIRENA			EQU 2
ENCENDIDO		EQU 3

TEMPO			EQU 0
ESTADO			EQU 1
SONANDO			EQU 2
ZONAS			EQU 3
TITILAR			EQU 4

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
	btfsc				INTCON,RBIF
	goto				CODIGO_RB

CODIGO_TMR0
	decfsz				veces,1
	goto				SALGO_TMR0
	movlw				.20
	movwf				veces
	decfsz				veces2,1
	goto				SALGO_TMR0
	bsf					flag,TEMPO
	goto				SALGO_TMR0

SALGO_TMR0
	movlw				.61
	movwf				TMR0
	bcf					INTCON,TMR0IF
	goto				SALGO

CODIGO_RB0
	call				ret_10ms
	btfss				flag,ESTADO
	goto				PRENDER
	goto				APAGAR

PRENDER
	bsf					flag,ESTADO
	goto				SALGO_RB0

APAGAR
	bcf					flag,ESTADO
	goto				SALGO_RB0

SALGO_RB0
	bcf					INTCON,INT0IF
	goto				SALGO

CODIGO_RB
	clrf				PORTA
	movlw				.240
	subwf				PORTB,w
	btfss				STATUS,Z
	goto				AVISAR
	goto				SALGO_RB

AVISAR
	bsf					flag,ZONAS
	btfss				PORTB,4
	bsf					PORTA,0
	btfss				PORTB,5
	bsf					PORTA,1
	btfss				PORTB,6
	bsf					PORTA,2
	btfss				PORTB,7
	bsf					PORTA,3
	goto				SALGO_RB

SALGO_RB
	bcf					INTCON,RBIF
	goto				SALGO

ret_10ms
	movlw				.216
	movwf				TMR0
	movlw				.0
	subwf				TMR0,w
	btfss				STATUS,Z
	goto				$-3
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

	movlw		b'11110011'
	movwf		TRISB			;Explicar por que tiene ese valor

	banksel		OPTION_REG
	movlw		b'10000111'
	movwf		OPTION_REG		;Explicar por que tiene ese valor

	banksel		INTCON
	movlw		b'10010000'
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

	movlw				.61
	movwf				TMR0
	btfss				PORTB,4
	goto				MAIN
MAIN
	btfss				flag,ESTADO
	goto				MAIN
	goto				INICIO

INICIO
	bsf					PORTB,ENCENDIDO
	movlw				.20
	movwf				veces
	movlw				.10
	movwf				veces2
	banksel				INTCON
	bsf					INTCON,TMR0IE
	banksel				PORTA
	goto				ESPERAR

ESPERAR
	btfss				flag,TEMPO
	goto				ESPERAR
	bcf					flag,TEMPO
	movlw				.10
	movwf				veces
	movlw				.1
	movwf				veces2
	clrf				PORTB
	banksel				INTCON
	bsf					INTCON,RBIE
	banksel				PORTA
	bcf					flag,ZONAS
	goto				TESTEAR

TESTEAR
	btfsc				flag,ZONAS
	goto				AL_SUENA
	btfss				flag,ESTADO
	goto				TERMINAR
	btfss				flag,TEMPO
	goto				TESTEAR
	bcf					flag,TEMPO
	movlw				.10
	movwf				veces
	movlw				.1
	movwf				veces2
	goto				CAMBIO_LED

CAMBIO_LED
	btfss				flag,TITILAR
	goto				PRENDER_LED
	goto				APAGAR_LED

PRENDER_LED
	bsf					PORTB,ENCENDIDO
	bsf					flag,TITILAR
	goto				TESTEAR

APAGAR_LED
	bcf					PORTB,ENCENDIDO
	bcf					flag,TITILAR
	goto				TESTEAR

SONAR
	btfss				PORTB,FRENO
	goto				REINICIAR
	btfss				flag,ESTADO
	goto				TERMINAR
	btfsc				flag,TEMPO
	goto				INDICADOR
	goto				SONAR

INDICADOR
	bcf					flag,TEMPO
	movlw				.10
	movwf				veces
	movlw				.1
	movwf				veces2
	btfss				flag,TITILAR
	goto				SONAR_ALARMA_PRENDER_LED
	goto				SONAR_ALARMA_APAGAR_LED

SONAR_ALARMA_PRENDER_LED
	bsf					PORTB,ENCENDIDO
	bsf					flag,TITILAR
	goto				SONAR_ALARMA

SONAR_ALARMA_APAGAR_LED
	bcf					PORTB,ENCENDIDO
	bcf					flag,TITILAR
	goto				SONAR_ALARMA

SONAR_ALARMA
	incf				repeat,1
	movlw				.4
	subwf				repeat,w
	btfss				STATUS,Z
	goto				SONAR
	clrf				repeat
	goto				ALARMA

ALARMA
	btfss				flag,SONANDO
	goto				AL_SUENA
	goto				AL_NO_SUENA

AL_SUENA
	bcf					flag,ZONAS
	bsf					flag,SONANDO
	bsf					PORTB,SIRENA
	movlw				.10				;10
	movwf				veces
	movlw				.1
	movwf				veces2
	goto				SONAR

AL_NO_SUENA
	bcf					flag,SONANDO
	bcf					PORTB,SIRENA
	movlw				.10				;20
	movwf				veces
	movlw				.1
	movwf				veces2
	goto				SONAR	

REINICIAR
	clrf				PORTA
	bcf					flag,ESTADO
	bcf					PORTB,SIRENA
	bsf					PORTB,ENCENDIDO
	banksel				INTCON
	bcf					INTCON,TMR0IE
	bcf					INTCON,RBIE
	banksel				PORTA
	goto				MAIN

TERMINAR
	bsf					PORTB,ENCENDIDO
	movlw				.20
	movwf				veces
	movlw				.10
	movwf				veces2
	btfss				flag,TEMPO
	goto				$-1
	clrf				PORTA
	bcf					PORTB,SIRENA
	bcf					PORTB,ENCENDIDO
	banksel				INTCON
	bcf					INTCON,TMR0IE
	bcf					INTCON,RBIE
	banksel				PORTA
	goto				MAIN

	end