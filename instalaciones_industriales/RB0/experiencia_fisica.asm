;Para realizar una experiencia de fisica se desea calcular el tiempo de salida de un objeto opaco a la luz, el cual se desliza por un
;tubo desde una altura de 100 metros. La indicacion debe tener el siguiente formato SEG-DEC_SEG-CENT_SEG (precision 1 centesima de
;segundo). El sistema se pone en marcha luego de pulsar RB2 apareciendo 0.00 en el display. Cuando el objeto cruza el sensor superior
;comienza la medida de tiempo hasta que el sensor inferior lo detiene. La cuenta se mantendra durante 10 segundos, luego de lo cual la
;programa debe comenzar de nuevo. Utilizar interrupciones por RB0 para el sensor superior e interrupciones por TMR0 para los
;temporizados. Realizar el circuito completo, la configuracion, el main y el programa de interrupcion. Usar un cristal de 4 MHz.
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
	seg
	dec_seg
	cent_seg
	ENDC

SS				EQU 0
SI				EQU	1
PULSADOR		EQU	2
STROBE_1		EQU 3
STROBE_2		EQU 4
STROBE_3		EQU 5
BLANK			EQU 6

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
	btfsc				INTCON,TMR0IF
	goto				CODIGO_TMR0
	goto				SALGO

CODIGO_RB0
	call				ret_10ms
	btfss				PORTB,SS
	goto				SALGO_RB0
	bsf					flag,0
	goto				SALGO_RB0

SALGO_RB0
	bcf					INTCON,INT0IF
	goto				SALGO

CODIGO_TMR0
	decfsz				veces,1
	goto				SALGO_TMR0
	movlw				.10
	movwf				veces
	bsf					flag,1
	goto				SALGO_TMR0

SALGO_TMR0
	bcf					INTCON,TMR0IF
	movlw				.241
	movwf				TMR0

ret_10ms

	movlw				.100
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

	movlw		b'00000111'
	movwf		TRISB			;Explicar por que tiene ese valor

	banksel		OPTION_REG
	movlw		b'10000101'
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
		banksel				PORTA ;SE ELIGE PARA MANEJARSE PARA EMPEZAR CON LOS REGISTROS CORRECTOS
			
			;LUGAR DONDE IRA EL CODIGO DEL PROGRAMA
;----------------------------------------------------------------------------------------------------------------------------------

		bcf					PORTB,BLANK
		bsf					PORTB,STROBE_1
		bsf					PORTB,STROBE_2
		bsf					PORTB,STROBE_3
		movlw				.10
		movwf				veces
MAIN
		btfsc				PORTB,PULSADOR
		goto				MAIN
		clrf				seg
		clrf				dec_seg
		clrf				cent_seg
		bsf					PORTB,BLANK
		call				mostrar

		banksel				INTCON
		bsf					INTCON,INT0IE
		banksel				PORTA

		btfss				flag,0
		goto				$-1
		bcf					flag,0
		goto				CONTAR

CONTAR
		movlw				.241
		movwf				TMR0
		banksel				INTCON
		bsf					INTCON,TMR0IE
		bcf					INTCON,INT0IE
		banksel				PORTA
CONTEO
		btfss				PORTB,SI
		goto				ESPERAR
		btfss				flag,1
		goto				CONTEO
		bcf					flag,1
		movlw				.9
		subwf				cent_seg,w
		btfsc				STATUS,Z
		goto				INC_DEC
		incf				cent_seg,1
		call				mostrar
		goto				CONTEO
		
INC_DEC
		clrf				cent_seg
		movlw				.9
		subwf				dec_seg,w
		btfsc				STATUS,Z
		goto				INC_SEG
		incf				dec_seg,1
		call				mostrar
		goto				CONTAR

INC_SEG
		clrf				dec_seg
		movlw				.9
		subwf				seg,w
		btfsc				STATUS,Z
		goto				PARAR
		incf				seg,1
		call				mostrar
		goto				CONTAR

PARAR
		banksel				INTCON
		bcf					INTCON,TMR0IE
		banksel				PORTA
		goto				MAIN

ESPERAR
		btfss				flag,1
		goto				ESPERAR
		bcf					flag,1
		movlw				.99
		subwf				contador,w
		btfsc				STATUS,Z
		goto				SEGUNDO
		incf				contador,1
		goto				ESPERAR

SEGUNDO
		clrf				contador
		movlw				.9
		subwf				veces2,w
		btfsc				STATUS,Z
		goto				TERMINO
		incf				veces2,1
		goto				ESPERAR

TERMINO
		clrf				seg
		clrf				dec_seg
		clrf				cent_seg
		clrf				contador
		clrf				veces2
		bcf					PORTB,BLANK
		banksel				INTCON
		bcf					INTCON,TMR0IE
		banksel				PORTA
		goto				MAIN

mostrar
		call				mostrar_cent
		call				mostrar_dec
		call				mostrar_seg
		return

mostrar_cent
		movf				cent_seg,w
		movwf				PORTA
		bcf					PORTB,STROBE_3
		nop
		nop
		nop
		bsf					PORTB,STROBE_3
		return

mostrar_dec
		movf				dec_seg,w
		movwf				PORTA
		bcf					PORTB,STROBE_2
		nop
		nop
		nop
		bsf					PORTB,STROBE_2
		return

mostrar_seg
		movf				seg,w
		movwf				PORTA
		bcf					PORTB,STROBE_1
		nop
		nop
		nop
		bsf					PORTB,STROBE_1
		return

		end