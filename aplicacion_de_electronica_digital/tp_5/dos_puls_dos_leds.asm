;Se utilizan 2 pulsadores con dos LEDs de salida.
;Segun la combinacion de pulsadores oprimidos, se ejecutan combinaciones con los LEDs
;0 | 0 : Rojo ON  | Verde 1seg ON , 1seg OFF
;0 | 1 : Verde ON | Rojo 500ms ON , 500ms OFF
;1 | 0 : Rojo ON  | Verde 250ms ON, 250ms OFF
;1 | 1 : Verde ON | Rojo 125ms ON , 125ms OFF 
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
	veces
	ENDC

VERDE			EQU 6
ROJO			EQU 7
PULSADOR1		EQU	1
PULSADOR2		EQU 2
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
				movlw  b'01100001'	;4MHZ
;									;BIT 0 SCS EN 1 PARA LA SELECCION DEL OSCILADOR INTERNO
;								_IRCF2 IRCF1 IRCF0 OSTS HTS LTS SCS
;							HTS DEBE ESTAR EN UNO PARA QUE LA CONFIGURACION DE LA FRECUENCIA SE HAGA DESDE
;							EL REGISTRO OSCCON SI ESTA EN CERO SE HACE DESDE LA CONFIGURACION
;					
		BANKSEL		OSCCON
		movwf		OSCCON
		btfss		OSCCON,IOFS		;INTOSC Frecuency Stable Bit
		goto		$-1				;PREGUNTO POR EL BIT IOFS DEL OSCCON ESPERANDO QUE PASE A UNO Y
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

	movlw		b'00000110'
	movwf		TRISB			;Explicar por que tiene ese valor

	banksel		OPTION_REG
	movlw		b'10000110'
	movwf		OPTION_REG		;Explicar por que tiene ese valor

	banksel		INTCON
	movlw		b'00000000'
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

MAIN

			btfsc		PORTB,PULSADOR1		;Comienza leyendo el primer pulsador
			goto		PULSADOR1_CERO		;Si no esta oprimido
			goto		PULSADOR1_UNO		;Si esta oprimido

PULSADOR1_CERO

			btfsc		PORTB,PULSADOR2		;Lee el pulsador 2
			goto		CERO_CERO			;Si no esta oprimido
			goto		CERO_UNO			;Si esta oprimido

PULSADOR1_UNO
			
			btfsc		PORTB,PULSADOR2		;Lee el pulsador 2
			goto		UNO_CERO			;Si no esta oprimido
			goto		UNO_UNO				;Si esta oprimido

CERO_CERO
			
			BSF			PORTB,ROJO			;Prende el LED rojo
			BSF			PORTB,VERDE			;Prende el LED verde
			movlw		.40
			movwf		veces				;Durante 1s
			call		retardo
			BCF			PORTB,VERDE			;Y lo apaga
			movlw		.40
			movwf		veces				;Durante otro segundo
			call		retardo
			goto		MAIN				;Vuelve al principio

CERO_UNO

			BSF			PORTB,VERDE
			BSF			PORTB,ROJO
			movlw		.20
			movwf		veces				;Durante 500ms
			call		retardo
			BCF			PORTB,ROJO
			movlw		.20
			movwf		veces				;Durante 500ms
			call		retardo
			goto		MAIN

UNO_CERO
			
			BSF			PORTB,ROJO
			BSF			PORTB,VERDE
			movlw		.10
			movwf		veces				;Durante 250ms
			call		retardo
			BCF			PORTB,VERDE
			movlw		.10
			movwf		veces				;Durante 250ms
			call		retardo
			goto		MAIN

UNO_UNO

			BSF			PORTB,VERDE
			BSF			PORTB,ROJO
			movlw		.5
			movwf		veces				;Durante 125ms
			call		retardo
			BCF			PORTB,ROJO
			movlw		.5
			movwf		veces				;Durante 125ms
			call		retardo
			goto		MAIN

ret_25ms

			movlw		.60
			movwf		TMR0
			movlw		.0
			SUBWF		TMR0,W
			BTFSS		STATUS,Z
			goto		$-3
			return

retardo
		
			call		ret_25ms
			decfsz		veces,1
			goto		retardo
			return

			END