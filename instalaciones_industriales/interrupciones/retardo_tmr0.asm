;Genera un retardo usando interrupciones por TMR0.
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
	flag
	ENDC

PULSADOR		EQU	1
INDICADOR		EQU	2

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
;---------------------------------------------------------------------------------------------------------------------------------
;LUGAR RESERVADO PARA EL CODIGO DE LA INTERRUPCION
;---------------------------------------------------------------------------------------------------------------------------------

		btfss			PIR1,0
		goto			SALGO
		;Si la interrupcion fue por TMR1

CONTAR
		decfsz			veces,1
		goto			SALGO
		bsf				flag,0
		;Cuando veces llega a 0

SALGO
		movlw			b'00001011'
		movwf			TMR1H
		movlw			b'11011100'
		movwf			TMR1L
		;Cargamos los registros de TMR1 con BDC - 3036
		bcf				PIR1,0
		;Cleareamos el flag del TMR1
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
	movwf		ANSEL			;No necesario

	banksel		TRISA
	movlw		b'00100000'
	movwf		TRISA			;RA5: MCLR

	movlw		b'00000010'
	movwf		TRISB			;RB1: Pulsador

	banksel		OPTION_REG
	movlw		b'10000000'
	movwf		OPTION_REG		;RB7: Resistencias PULL-UP

	banksel		INTCON
	movlw		b'10000000'
	movwf		INTCON			;RB7: Habilita Interrupciones
								;RB6: Habilita PEIE

	banksel		PIR1
	movlw		b'00000000'
	movwf		PIR1			;Explicar por que tiene ese valor

	banksel		PIE1
	movlw		b'00000001'
	movwf		PIE1			;RB0: TMR1 Inhabilitado

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

	banksel		T1CON
	movlw		b'00100001'
	movwf		T1CON			;RB0: Habilita TMR1
								;RB5-4: Preescaler 1:4

;----------------------------------------------------------------------------------------------------------------------------------
;													COMIENZO DEL PROGRAMA
;----------------------------------------------------------------------------------------------------------------------------------
COMIENZA
		banksel				PORTA ;SE ELIGE PARA MANEJARSE PARA EMPEZAR CON LOS REGISTROS CORRECTOS
			
			;LUGAR DONDE IRA EL CODIGO DEL PROGRAMA
;----------------------------------------------------------------------------------------------------------------------------------
		movlw				b'00001011'
		movwf				TMR1H
		movlw				b'11011100'
		movwf				TMR1L
		;Cargamos los registros con BDC - 3036

MAIN
		btfsc				PORTB,PULSADOR
		goto				MAIN
		goto				HABILITAR
		;Cuando se oprime el pulsador

HABILITAR
		bsf					INTCON,PEIE				;Habilita el TMR1
		movlw				.32
		movwf				veces
		;Con retardos de 250ms, 32 veces son 8 segundos
		goto				ESPERAR

ESPERAR
		btfss				flag,0
		goto				ESPERAR
		;Espera que cambie el flag
		bcf					flag,0
		bsf					PORTB,INDICADOR
		;Prende el LED
		movlw				.16
		movwf				veces
		;Con retardos de 250ms, 16 veces son 4 segundos
		goto				APAGAR

APAGAR
		btfss				flag,0
		goto				APAGAR
		;Espera que cambie el flag
		bcf					INTCON,PEIE
		;Desactiva la interrupcion
		bcf					flag,0
		bcf					PORTB,INDICADOR
		;Apaga el LED
		goto				MAIN

		end