;Prende LEDs en secuencia usando retardos muy grandes.
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
;				movlw  b'01100001'	;4MHZ
;									;BIT 0 SCS EN 1 PARA LA SELECCION DEL OSCILADOR INTERNO
;								_IRCF2 IRCF1 IRCF0 OSTS HTS LTS SCS
;							HTS DEBE ESTAR EN UNO PARA QUE LA CONFIGURACION DE LA FRECUENCIA SE HAGA DESDE
;							EL REGISTRO OSCCON SI ESTA EN CERO SE HACE DESDE LA CONFIGURACION
;					
;		BANKSEL		OSCCON
;		movwf		OSCCON
;		btfss		OSCCON,IOFS		;INTOSC Frecuency Stable Bit
;		goto		$-1				;PREGUNTO POR EL BIT IOFS DEL OSCCON ESPERANDO QUE PASE A UNO Y
; SE ESTABILICE EL OSCILADOR INTERN2O, CUANDO PASA A 1 ARRANCA LA INICIALIZACION

	banksel		PORTA
	CLRF		PORTA			;limpio PORTA para empezar

	banksel		PORTB
	CLRF		PORTB			;limpio PORTB para empezar

	banksel		ANSEL
	movlw		b'00000000'
	movwf		ANSEL			;Todas digitales

	banksel		TRISA
	movlw		b'00010000'
	movwf		TRISA			;Entrada del clock en RA4

	movlw		b'00000001'
	movwf		TRISB			;Entrada del pulsador que inicia la secuencia

	banksel		OPTION_REG
	movlw		b'10100100'
	movwf		OPTION_REG		;Fuente de TMR0 en RA4
								;Preescaler 1:32

	banksel		INTCON
	movlw		b'00000000'
	movwf		INTCON			;No se utilizan interrupciones

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

		BTFSC	PORTB,0		;Lee el pulsador en RB0
		goto	MAIN		;Si no esta oprimido, vuelve al principio
		goto	MOTOR		;Si esta oprimido, va a la siguiente etiqueta

MOTOR
		BCF	 	PORTB,1		;Apaga el motor
		movlw	.7			;Carga W con 7
		movwf	veces		;Carga veces con W
		call	retardo		;Ejecuta el retardo, 7 veces medio segundo, son 3,5 segundos
		BSF		PORTB,1		;Prende el led
		movlw	.5			;Carga W con 5
		movwf	veces		;Carga veces con W
		call 	retardo		;Ejecuta el retardo, 5 veces medio segundo, son 2.5 segundos
		BCF		PORTB,1		;Apaga el led
		movlw	.3			;Carga W con 3
		movwf	veces		;Carga veces con W
		call	retardo		;Ejecuta el retardo, 3 veces medio segundo, son 1.5 segundos
		BSF		PORTB,1		;Prende el led
		movlw	.1			;Carga W con 1
		movwf	veces		;Carga veces con W
		call	retardo		;Ejecuta el retardo, 1 vez medio segundo es medio segundo
		goto 	MOTOR		;Repite el ciclo

ret_0.5_seg

		movlw	.100		;Carga W con 100
		movwf	TMR0		;Carga TMR0 con W
		movlw	.0			;Carga W ocn 0
		subwf	TMR0,W		;Resta W de TMR0
		btfss	STATUS,Z	;Revisa el bit Z de STATUS
		goto	$-3			;Si es igual a 0, repite las ultimas tres instrucciones
		return				;Si es igual a 1, retorna a donde fue llamado

retardo

		call	ret_0.5_seg		;Llama al retardo de medio segundo
		decfsz	veces,1			;Decrementa veces en 1 y lo guarda en veces
		goto	retardo			;Repite el ciclo
		return					;Retorna al donde lo llamaron

		END