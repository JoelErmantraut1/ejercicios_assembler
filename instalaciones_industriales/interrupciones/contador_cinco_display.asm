;Cuenta tiempo y lo muestra en 5 displays, 2 para los segundos, 2 para los minutos y uno mas para las decimas.
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
	seg_uni
	seg_dec
	min_uni
	min_dec
	decimas
	veces
	flag
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
		btfsc			INTCON,TMR0IF
		goto			RETARDO
		goto			SALGO

RETARDO
		decfsz			veces,1
		goto			SALGO
		movlw			.2
		movwf			veces
		;Cargo veces con 2 para el proximo retardo
		movlw			.9
		subwf			decimas,w
		btfss			STATUS,Z
		goto			INC_DEC
		goto			INC_SU

INC_DEC
		incf			decimas,1
		call			mostrar
		goto			SALGO

INC_SU
		clrf			decimas
		movlw			.9
		subwf			seg_uni,w
		btfsc			STATUS,Z
		goto			INC_SD
		incf			seg_uni,1
		call			mostrar
		goto			SALGO

INC_SD
		clrf			seg_uni
		movlw			.5
		subwf			seg_dec,w
		btfsc			STATUS,Z
		goto			INC_MU
		incf			seg_dec,1
		call			mostrar
		goto			SALGO

INC_MU
		clrf			seg_dec
		movlw			.9
		subwf			min_uni,w
		btfsc			STATUS,Z
		goto			INC_MD
		incf			min_uni,1
		call			mostrar
		goto			SALGO

INC_MD
		clrf			min_uni
		movlw			.5
		subwf			min_dec,w
		btfsc			STATUS,Z
		goto			RESETEAR
		incf			min_dec,1
		call			mostrar
		goto			SALGO

RESETEAR
		clrf			decimas
		clrf			min_uni
		clrf			min_dec
		clrf			seg_uni
		clrf			min_dec
		call			mostrar
		goto			SALGO

SALGO
		movlw			.61
		movwf			TMR0
		bcf				INTCON,TMR0IF
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
		btfss		OSCCON,IOFS		;INTOSC Frecuency Stable Bit
		goto		$-1				;PREGUNTO POR EL BIT IOFS DEL OSCCON ESPERANDO QUE PASE A UNO Y
; SE ESTABILICE EL OSCILADOR INTERNO, CUANDO PASA A 1 ARRANCA LA INICIALIZACION

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

	movlw		b'00000000'
	movwf		TRISB			;Explicar por que tiene ese valor

	banksel		OPTION_REG
	movlw		b'10000111'
	movwf		OPTION_REG		;Explicar por que tiene ese valor

	banksel		INTCON
	movlw		b'10100000'
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
		;Adelantamos el TMR0
		movlw				.2
		movwf				veces
		bsf					PORTB,.4
		bsf					PORTB,.3
		bsf					PORTB,.2
		bsf					PORTB,.1
		bsf					PORTB,.0

;---------------------------------------------------------

		movlw				.9
		movwf				min_uni
		movlw				.5
		movwf				min_dec
		movlw				.5
		movwf				seg_dec
		movlw				.5
		movwf				seg_uni

;----------------------------------------------------------

MAIN
		btfss				flag,0
		goto				MAIN
		goto				MOSTRAR	

MOSTRAR
		call			mostrar_dec
		call			mostrar_su
		call			mostrar_sd
		call			mostrar_mu
		call			mostrar_md
		goto			MAIN

mostrar_dec
		movf			decimas,w
		movwf			PORTA
		bcf				PORTB,.4
		nop
		nop
		nop
		bsf				PORTB,.4
		return

mostrar_su
		movf			seg_uni,w
		movwf			PORTA
		bcf				PORTB,.3
		nop
		nop
		nop
		bsf				PORTB,.3
		return

mostrar_sd
		movf			seg_dec,w
		movwf			PORTA
		bcf				PORTB,.2
		nop
		nop
		nop
		bsf				PORTB,.2
		return

mostrar_mu
		movf			min_uni,w
		movwf			PORTA
		bcf				PORTB,.1
		nop
		nop
		nop
		bsf				PORTB,.1
		return

mostrar_md
		movf			min_dec,w
		movwf			PORTA
		bcf				PORTB,.0
		nop
		nop
		nop
		bsf				PORTB,.0
		return

		end