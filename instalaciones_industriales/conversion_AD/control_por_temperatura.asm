;Controla el encendido y apagado de una valvula mediante un sensor de temperatura (potenciometro).
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
	poteH
	poteL
	tempH
	tempL
	ENDC

POTE			EQU 0
TEMP			EQU 1
VALV			EQU 1
IND				EQU 6
PULS			EQU 7

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
		movlw		b'01100001'	;4MHZ
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
	movlw		b'00000011'
	movwf		ANSEL			;AN1: POTENCIOMETRO

	banksel		TRISA
	movlw		b'00000011'
	movwf		TRISA			;RA1: POTENCIOMETRO DE ENTRADA

	movlw		b'10000000'
	movwf		TRISB			;PULS_DE_INICIO: 7

	banksel		OPTION_REG
	movlw		b'10000110'
	movwf		OPTION_REG		;Preescaler en 256

	banksel		INTCON
	movlw		b'00000000'
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
	movlw		b'11000000'
	movwf		ADCON0			;Explicar por que tiene ese valor

	banksel		ADCON1
	movlw		b'10000000'
	movwf		ADCON1			;5V = 00000011 11111111

;----------------------------------------------------------------------------------------------------------------------------------
;													COMIENZO DEL PROGRAMA
;----------------------------------------------------------------------------------------------------------------------------------
COMIENZA
;----------------------------------------------------------------------------------------------------------------------------------

		banksel				PORTA
MAIN
		btfsc				PORTB,PULS
		goto				MAIN
		bsf					PORTB,IND
		goto				EMPEZAR

EMPEZAR
		call				obtener_pote
		call				obtener_temp
		goto				COMPARAR

obtener_pote
		banksel			ADCON0
		bcf				ADCON0,CHS2
		bcf				ADCON0,CHS1
		bcf				ADCON0,CHS0
		;Selecciono canal 0 de conversion

		bsf				ADCON0,ADON
		;Habilito la conversion
		call			ret_10ms

		bsf				ADCON0,GO
		;Inicio la conversion
		call			ret_10ms

		banksel			ADRESL
		movf			ADRESL,w
		banksel			PORTA
		movwf			poteL

		banksel			ADRESH
		movf			ADRESH,w
		banksel			PORTA
		movwf			poteH

		return

obtener_temp
		banksel			ADCON0
		bcf				ADCON0,CHS2
		bcf				ADCON0,CHS1
		bsf				ADCON0,CHS0
		;Selecciono canal 1 de conversion

		bsf				ADCON0,ADON
		;Habilito la conversion
		call			ret_10ms

		bsf				ADCON0,GO
		;Inicio la conversion
		call			ret_10ms

		banksel			ADRESL
		movf			ADRESL,w
		banksel			PORTA
		movwf			tempL

		banksel			ADRESH
		movf			ADRESH,w
		banksel			PORTA
		movwf			tempH

		return

COMPARAR
		bcf				STATUS,Z
		bcf				STATUS,C

		movf			poteH,w
		subwf			tempH,w
		btfsc			STATUS,Z
		goto			SON_IGUALES			;La temperatura y el pote tienen el mismo valor
		btfsc			STATUS,C
		goto			PRENDER_VALV			;La temperatura es menor
		goto			APAGAR_VALV			;La temperatura es mayor

SON_IGUALES
		movf			poteL,w
		subwf			tempL,w
		btfsc			STATUS,Z
		goto			PRENDER_VALV
		btfsc			STATUS,C
		goto			PRENDER_VALV
		goto			APAGAR_VALV

ES_MENOR
		goto			PRENDER_VALV

ES_MAYOR
		goto			APAGAR_VALV

APAGAR_VALV
		bcf				PORTB,VALV
		goto			EMPEZAR

PRENDER_VALV
		bsf				PORTB,VALV
		goto			EMPEZAR

ret_10ms
		movlw			.178
		movwf			TMR0
		movlw			.0
		subwf			TMR0,w
		btfss			STATUS,Z
		goto			$-3
		return

		end