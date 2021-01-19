;Activa un motor y va contando los objetos que pasan. Cuando llega a 10, frena, y espera a ser habilitado para volver a empezar.
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
	veces2
	contador
	ENDC

STROBE			EQU	1
PULSADOR		EQU 2
MOTOR			EQU	3
SENSOR			EQU 4

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
	movlw		b'00100000'
	movwf		TRISA			;Explicar por que tiene ese valor

	movlw		b'00010100'
	movwf		TRISB			;Explicar por que tiene ese valor

	banksel		OPTION_REG
	movlw		b'10000110'
	movwf		OPTION_REG		;Explicar por que tiene ese valor

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

		bcf				PORTB,MOTOR
MAIN
		btfsc			PORTB,PULSADOR
		goto			MAIN
		;Testeamos el pulsado hasta que es oprimido
		movlw			.3
		movwf			veces2
		call			ret_1segs
		;Cuando es oprimido, esperamos 3 segundos
CINTA
		bsf				PORTB,MOTOR
		;Movemos el motor

CONFIGURAR

		clrf			contador
		call			mostrar
		;Contador almacena la cantidad de objetos contados
		;Empezamos con cero

SENSADO

		btfsc			PORTB,SENSOR
		goto			SENSADO
		goto			ANTIREBOTE
		;Esperamos a que pase un objeto por el sensor

ANTIREBOTE ;Lo que ANTIREBOTE hace es evitar el rebote del sensor

		call			ret_25ms
		btfss			PORTB,SENSOR
		goto			SENSADO
		goto			CONTAR
		;Para eso, espera un tiempo chico, y vuelve a testear el sensor
		;Si sigue presionado, es producto del rebote
		;Entonces vuelve a SENSADO a leerlo de nuevo
		;Si no, sigue con el programa

CONTAR

		incf			contador,1
		;Agrega un objeto
		call			mostrar
		;Lo muestra por el display
		movlw			.5
		subwf			contador,w
		btfss			STATUS,Z ;Verifica si hay 5 objetos contados
		goto			SENSADO ;Si hay menos, vuelve a sensar
		bcf				PORTB,MOTOR
		;Si hay 5, apaga el motor
		movlw			.10
		movwf			veces2
		call			ret_1segs
		;Y espera 10 segundos
		goto			CINTA

mostrar ;Esta rutina se encarga de mostrar por el display el valor de contador

		movf			contador,w
		movwf			PORTA
		;Mueve contador al PORTA
		bcf				PORTB,STROBE
		;Habilita el 4511 (es negado, por lo que se habilita con 0)
		nop
		nop
		nop
		;Espera 3 microsegundos, para darle tiempo al 4511 a procesar el dato
		bsf				PORTB,STROBE
		;Inhabilita el 4511
		return

ret_25ms

		movlw			.61
		movwf			TMR0
		movlw			.0
		subwf			TMR0,W
		btfss			STATUS,Z
		goto			$-3
		return

retardo

		call			ret_25ms
		decfsz			veces,1
		goto			$-2
		return

ret_1seg
		movlw			.40
		movwf			veces
		;Cantidad de veces necesarias para tardar 1 segundos
		call			retardo
		return

ret_1segs ;Este retardo lo que hace es ejecutar tantas veces 1 segundo, como el valor de veces2
;De esta manera si el valor de veces2 es 10, el retardo dura 10 segundos

		call			ret_1seg
		;Ejecuta el retardo
		decfsz			veces2,1 ;Decrementa veces y testea si llego a 0
		goto			$-2
		return

		end