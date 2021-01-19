;Cuenta la cantidad de persona que entran y salen usando dos sensores y las muestra en un display 7-segmentos.
;Si hay mas de 5 personas, hace sonar un buzzer.
;en
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
	maximo
	personas
	ENDC

STROBE			EQU 1
BUZZER			EQU 2
ENTRADA			EQU 3
SALIDA			EQU 4

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

	movlw		b'00011000'
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

		call			mostrar

MAIN
		btfsc			PORTB,ENTRADA ;Testea el sensor de entrada
		goto			TEST2 ;Si no esta activado, va a testear el sensor de salida
		goto			ANTISUM ;Si esta activado, va al antirebote de este sensor

TEST2
		btfsc			PORTB,SALIDA ;Testear el sensor de salida
		goto			MAIN ;Si no esta activado, va a testear el pulsador de entrada
		goto			ANTIREST ;Si esta activado, va al antirebote de este sensor

ANTISUM
		call			ret_25ms
		btfss			PORTB,ENTRADA
		goto			MAIN
		goto			SUMAR
		;Lo mismo que el antirebote del ejercicio anterior

ANTIREST
		call			ret_25ms
		btfss			PORTB,SALIDA
		goto			MAIN
		goto			RESTAR
		;Lo mismo que el antirebote del ejercicio anterior

SUMAR ;Esta rutina se encarga de sumar una persona
		movlw			.9
		subwf			personas,w
		btfss			STATUS,Z
		;Para que no se pase de 9
		incf			personas,1 ;Agrega una persona
		call			mostrar ;Lo muestra por el display
		movlw			.5
		movwf			maximo
		goto			TESTEAR
		;Y testea si hay mas de 5 personas

RESTAR ;Esta rutina se encarga de restar una persona
		movlw			.0
		subwf			personas,w
		btfss			STATUS,Z
		;Para que no se pase de 0
		decf			personas,1 ;Resta una persona
		call			mostrar ;Lo muestra en el display
		movlw			.5
		movwf			maximo
		goto			TESTEAR
		;Y testea si hay mas de 5 personas

TESTEAR ;Esta rutina verifica si hay mas de 5 personas
		;Para eso usa un registro que aumenta su valor ciclicamente hasta llegar a 9, que es el maximo numero que muestra un display
		;Estonces empieza con 5
		incf			maximo,1
		;Aumenta en 1
		movf			maximo,w
		subwf			personas,w
		btfss			STATUS,Z ;Verifica si personas es igual al valor de maximo
		goto			APAGAR ;Si no lo es apaga el parlante
		goto			PRENDER ;Si es igual, lo prende

APAGAR
		bcf				PORTB,BUZZER ;Apaga el parlante
		movlw			.9
		subwf			maximo,w
		btfss			STATUS,Z ;Testea si maximo llego a 9
		goto			TESTEAR ;Si no llego, vuelve a TESTEAR, donde maximo va a aumentar su valor
		goto			MAIN ;Si llego vuelve a testear los sensores

PRENDER
		bsf				PORTB,BUZZER ;Prende el parlante
		goto			MAIN ;Vuelve a testear los sensores

mostrar
		movfw			personas
		movwf			PORTA
		bcf				PORTB,STROBE
		nop
		nop
		nop
		bsf				PORTB,STROBE
		return

ret_25ms
		movlw			.61
		movwf			TMR0
		movlw			.0
		subwf			TMR0,W
		btfss			STATUS,Z    
		goto			$-3
		return

		end