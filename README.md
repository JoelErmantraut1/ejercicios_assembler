# ejercicios_assembler

Colección de ejercicios sobre programación del PIC16F88 para las materias Aplicación de Electrónica Digital e Instalaciones Industriales,
de la Tecnicatura en Electrónica.

## Descripción

Estos programas fueron desarrollados partiendo de la plantilla [PLANT_16F88.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/PLANT_16F88.asm), incluida en este
repositorio. Todos fueron realizados en el software [MPLAB](https://www.microchip.com/en-us/development-tools-tools-and-software/mplab-x-ide),
y probados en el simulador [Proteus](https://www.labcenter.com/).
Ninguno fue llevado a la práctica en microcontroladores reales, aunque si se han usado algoritmos 
similares por lo que se reconoce su funcionamiento en los mismos.

## Índice

Se listan los archivos incluidos en dos carpetas, cada una correspondiente a un año distinto de la carrera.

### Aplicación de Electrónica Digital:
- [Ejemplos de configuración](https://github.com/JoelErmantraut1/ejercicios_assembler/tree/main/aplicacion_de_electronica_digital/configuraciones)
- [Trabajo Práctico 5](https://github.com/JoelErmantraut1/ejercicios_assembler/tree/main/aplicacion_de_electronica_digital/tp_5):
    - [puls_prende_led.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/aplicacion_de_electronica_digital/tp_5/puls_prende_led.asm):
    Algoritmo que prende y apaga un LED en función del estado de un pulsador.
    - [dos_puls_dos_leds.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/aplicacion_de_electronica_digital/tp_5/dos_puls_dos_leds.asm):
    Ejercicio que determina cual de los dos LEDs prender en función de la combinación del estado de los pulsadores.
    - [parpadeo_led.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/aplicacion_de_electronica_digital/tp_5/parpadeo_led.asm):
    Enciende y apaga un LED de forma intermitente.
    - [secuencia_leds.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/aplicacion_de_electronica_digital/tp_5/puls_prende_led.asm):
    Algoritmo que prende y apaga LEDs de forma secuencial.
    - [leds_secuencia_retardos.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/aplicacion_de_electronica_digital/tp_5/leds_secuencia_retardos.asm):
    Algoritmo que prende y apaga LEDs de forma secuencial empleando retardo importantes.
    - [leds_secuencia_retardos_grandes.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/aplicacion_de_electronica_digital/tp_5/leds_secuencia_retardos_grandes.asm):
    Identico al anterior, pero empleando retardo mayores.
    - [diagrama_de_tiempos.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/aplicacion_de_electronica_digital/tp_5/diagrama_de_tiempos.asm):
    Ejercicio que consiste en prender y apagar uno o varios LEDs respetando un diagrama de tiempos.
- [Trabajo Práctico 6](https://github.com/JoelErmantraut1/ejercicios_assembler/tree/main/aplicacion_de_electronica_digital/tp_6):
    - [alarma.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/aplicacion_de_electronica_digital/tp_6/alarma.asm):
    Programa que realiza las actividades de una alarma, como monitorear un conjunto de entradas y producir un sonido cuando una se activa.
    - [contador_7_segm.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/aplicacion_de_electronica_digital/tp_6/contador_7_segm.asm):
    Cuenta y muestra su valor en un display 7 segmentos.
    - [contador_puls_7_segm.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/aplicacion_de_electronica_digital/tp_6/contador_puls_7_segm.asm):
    Cuenta la cantidad de pulsaciones y las muestra en un display.
    - [dos_7_segm_pulsador.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/aplicacion_de_electronica_digital/tp_6/dos_7_segm_pulsador.asm):
    Igual que el anterior, pero con dos displays.
    - [rotacion_bits.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/aplicacion_de_electronica_digital/tp_6/rotacion_bits.asm):
    Utiliza las funciones integradas al microcontrolador para producir un desplazamiento de bits.

### Instalaciones Industriales:
- [Repaso](https://github.com/JoelErmantraut1/ejercicios_assembler/tree/main/instalaciones_industriales/repaso):
    - [barrido_bidireccional.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/repaso/barrido_bidireccional.asm):
    Realiza un barrido de LEDs en dos direcciones.
    - [barrido_bidireccional_tmr0.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/repaso/barrido_bidireccional_tmr0.asm):
    Identico al anterior, pero empleando retardos por TRM0.
    - [barrido_leds.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/repaso/barrido_leds.asm):
    Realiza un barrido de LEDs en una dirección.
    - [contador_personas.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/repaso/contador_personas.asm):
    Utiliza dos sensores para diferenciar entre un ingreso y egresos, y muestra la cantidad de personas dentro de un espacio.
    - [detector_de_objetos.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/repaso/detector_de_objetos.asm):
    Activa un motor en una cinta que hace pasar objetos y los va contando. Cuando llega a una cierta cantidad frena, y espera para volver a iniciar.
- [RB0](https://github.com/JoelErmantraut1/ejercicios_assembler/tree/main/instalaciones_industriales/RB0):
    - [contador_por_flanco.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/RB0/contador_por_flanco.asm):
    Igual que los contadores anteriores, pero diferencia entre el flanco ascendente y el descendente.
    - [detector_de_objetos.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/RB0/detector_de_objetos.asm):
    Activa un motor en una cinta que hace pasar objetos y los va contando. Cuando llega a una cierta cantidad frena, y espera para volver a iniciar.
    - [experiencia_fisica.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/RB0/experiencia_fisica.asm):
    Para realizar una experiencia de fisica se desea calcular el tiempo de salida de un objeto opaco a la luz, el cual se desliza por un tubo desde una altura de 100 metros.
    - [indicador_de_turnos.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/RB0/indicador_de_turnos.asm):
    Utiliza dos displays para mostrar el turno actual y otro display para mostrar la caja que le corresponde.
    - [segundero.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/RB0/segundero.asm):
    Muestra los minutos y segundos con dos digitos, y uso otro display para mostrar las décimas.
    - [tren_de_pulsos.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/RB0/tren_de_pulsos.asm):
    Genera un tren de una cantidad finita de pulsos. Con un pulsador determina la cantidad y con otro inicia la ráfaga.
- [Interrupciones](https://github.com/JoelErmantraut1/ejercicios_assembler/tree/main/instalaciones_industriales/interrupciones):
    - [contador_bidireccional.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/interrupciones/contador_bidireccional.asm):
    Cuenta de forma ascendente y descendente y los presenta en un display.
    - [contador_cinco_display.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/interrupciones/contador_cinco_display.asm):
    Presenta los minutos y segundos con dos digitos, y usa un tercer display para mostrar las décimas.
    - [contador_cuatro_display.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/interrupciones/contador_cuatro_display.asm):
    Presenta los minutos y segundos con dos digitos.
    - [contador_por_tmr0.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/interrupciones/contador_por_tmr0.asm):
    Realiza un conteo usando retardo por TMR0.
    - [retardo_trm0.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/interrupciones/retardo_tmr0.asm):
    Emplea retardo con interrupciones por TMR0.
- [Parte Alta](https://github.com/JoelErmantraut1/ejercicios_assembler/tree/main/instalaciones_industriales/parte_alta):
    - [alarma.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/parte_alta/alarma.asm):
    Similar al anterior, pero empleando interrupciones por parte alta de RB.
    - [barrido_configurable.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/parte_alta/barrido_configurable.asm):
    Algoritmo que permite hacer una barrido de LEDs con velocidad seleccionable con pulsadores.
    - [generador_de_señales.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/parte_alta/generador_de_se%C3%B1ales.asml):
    Programa que permite generar señales configurables con pulsadores en RB4-RB7.
    - [sistema_vigia.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/parte_alta/sistema_vigia.asm):
    Programa que emula las funciones de un sistema vigía de un vehículo.
- [Conversión AD](https://github.com/JoelErmantraut1/ejercicios_assembler/tree/main/instalaciones_industriales/conversion_AD):
    - [barrido_con_pote.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/conversion_AD/barrido_con_pote.asm):
    Realiza un barrido de LEDs y permite determinar la velocidad del barrido usando un potenciometro.
    - [control_por_temperatura.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/conversion_AD/control_por_temperatura.asm):
    Controla el encendido y apagado de una valvula, usando un sensor de temperatura.
    - [medir_tensión.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/conversion_AD/medir_tension.asm):
    Muestra el valor de tensión medido en dos displays 7 segmentos.
- [Motor paso a paso](https://github.com/JoelErmantraut1/ejercicios_assembler/tree/main/instalaciones_industriales/motor_paso_a_paso):
    - [motor_paso_a_paso.asm](https://github.com/JoelErmantraut1/ejercicios_assembler/blob/main/instalaciones_industriales/motor_paso_a_paso/motor_paso_a_paso.asm):
    Control de velocidad de un motor paso a paso.
