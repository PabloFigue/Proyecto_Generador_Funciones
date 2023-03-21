;   Archivo:    Proyecto.s
;   Dispositivo: PIC16F887
;   Autor:  Pablo Figueroa
;   Copilador: pic-as (v2.40),MPLABX v6.05
;
;   Progra: Generador de funciones Cuadrada, Triangular y Senoidal
;   Hardware: Pushbuttons en el puerto B, Displays de 7 segmentos en el puertoC, DAC R2R en el puerto A, Transistores en el puerto D, Leds en el puerto E
; 
;   Creado: feb, 2023
;   Ultima modificacion: 03 marzo, 2023
    
PROCESSOR 16F887
#include <xc.inc>
    
;--------Palabras de Configuraci?n---------
    
; configuration word 1
  CONFIG  FOSC = INTRC_NOCLKOUT   ; Oscillator Selection bits (INTOSC oscillator: CLKOUT function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; configuration word 2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

;--------------- VARIABLES -------------------

PSECT udata_shr ;common memory
 PUNTERO: DS 1		;Variable puntero que indica la posición de offset de las tablas.
 PRESCALER_TEMP: DS 1	;Variable para cambiar el Prescaler del TMR0.
 val_display: DS 4	;Variable para guardar los valores que se van a mostrar en cada uno de los display.
 
PSECT udata_bank0 ;common memory
  W_TEMP:   DS 1	;Variable reservada para guardar el W Temporal.
  STATUS_TEMP: DS 1	;Variable reservada para guardar el STATUS Temporal.
  TMR0_TEMP: DS 1	;Variable del valor del TMR0 para incrementar el tiempo de reinicio del TMR0
  S_DIENTE: DS 1	;Variable contador que graficamente es la señal diente de cierra.
  S_CUADRADA: DS 1	;Variable contador que graficamente es la señal cuadrada.
  S_TRIANGULAR: DS 1	;Variable contador que graficamente es la señal cuadrada.
  S_SENOIDAL: DS 1	;Variable contador que graficamente es la señal senoidal.
  S_TRI_SEL: DS 1	;Variable que me indica si debo incrementar o decrementar en la  señal triangular.
  S_CUAD_SEL: DS 1	;Variable que establece si limpia o mueve 255 al registro S_CUADRADA.
  SELEC_SIG: DS 1	;Variable que va a indicar que Señal es la que se quiere en la salida del DAC.
  
  bandera: DS 1		;Variable para verificar que display se debe mostrar.
  display: DS 4		;Variable que guarda el valor mostrado en el display pero traducido a binario.
  
         
  UP1 EQU 0	; Button para incrementar Frecuencia
  DOWN1 EQU 1	; Button para decrementar Frecuencia
  UP2 EQU 2	; Button para Hz
  DOWN2 EQU 3	; Button para KHz
  BT EQU 4	; Button para cambiar de señal cuadrada a triangular
    
 
;-------------- VECTOR RESET -------------   
PSECT VectorReset, class=CODE, abs, delta=2

ORG 0x0000		;Posicion 0000h para el reset
    
VectorReset:
    PAGESEL main 
    goto main

;----------------TABLAS---------------------
    
ORG 0x0100			;Origen de la tabla
tabla_sig_triangular_subida:	;Tabla para mapear valores del diente de sierra a la triangular (0-128)
    clrf PCLATH			;0 al PCLATH
    bsf PCLATH,0		;Bit mas significativo de la direccion
    addwf PCL, F		;W es el offset de la tabla
    retlw	0
    retlw	2
    retlw	4
    retlw	6
    retlw	8
    retlw	10
    retlw	12
    retlw	14
    retlw	16
    retlw	18
    retlw	20
    retlw	22
    retlw	24
    retlw	26
    retlw	28
    retlw	30
    retlw	32
    retlw	34
    retlw	36
    retlw	38
    retlw	40
    retlw	42
    retlw	44
    retlw	46
    retlw	48
    retlw	50
    retlw	52
    retlw	54
    retlw	56
    retlw	58
    retlw	60
    retlw	62
    retlw	64
    retlw	66
    retlw	68
    retlw	70
    retlw	72
    retlw	74
    retlw	76
    retlw	78
    retlw	80
    retlw	82
    retlw	84
    retlw	86
    retlw	88
    retlw	90
    retlw	92
    retlw	94
    retlw	96
    retlw	98
    retlw	100
    retlw	102
    retlw	104
    retlw	106
    retlw	108
    retlw	110
    retlw	112
    retlw	114
    retlw	116
    retlw	118
    retlw	120
    retlw	122
    retlw	124
    retlw	126
    retlw	128
    retlw	130
    retlw	132
    retlw	134
    retlw	136
    retlw	138
    retlw	140
    retlw	142
    retlw	144
    retlw	146
    retlw	148
    retlw	150
    retlw	152
    retlw	154
    retlw	156
    retlw	158
    retlw	160
    retlw	162
    retlw	164
    retlw	166
    retlw	168
    retlw	170
    retlw	172
    retlw	174
    retlw	176
    retlw	178
    retlw	180
    retlw	182
    retlw	184
    retlw	186
    retlw	188
    retlw	190
    retlw	192
    retlw	194
    retlw	196
    retlw	198
    retlw	200
    retlw	202
    retlw	204
    retlw	206
    retlw	208
    retlw	210
    retlw	212
    retlw	214
    retlw	216
    retlw	218
    retlw	220
    retlw	222
    retlw	224
    retlw	226
    retlw	228
    retlw	230
    retlw	232
    retlw	234
    retlw	236
    retlw	238
    retlw	240
    retlw	242
    retlw	244
    retlw	246
    retlw	248
    retlw	250
    retlw	252
    retlw	254
    retlw	255 ;
    
    ORG 0x018C		    ;Origen de la tabla
frecuencias_disp01_CUAD:    ;Tabla de frecuencias para la señal cuadrada para el display 0 y 1
    clrf PCLATH		    ;0 al PCLATH
    bsf PCLATH,0	    ;Bit mas significativo de la direccion de la tabla.
    movf PUNTERO,W	    ;El valor PUNTERO sera el offset de la tabla 
    addwf PCL,F		    ;W es el offset de la tabla
    retlw	0x25
    retlw	0x50
    retlw	0x74
    retlw	0x99
    retlw	0x23
    retlw	0x47
    retlw	0x71
    retlw	0x95
    retlw	0x17
    retlw	0x41
    retlw	0x66
    retlw	0x88
    retlw	0x10
    retlw	0x34
    retlw	0x65
    retlw	0x88
    retlw	0x11
    retlw	0x34
    retlw	0x59
    retlw	0x80
    retlw	0x03
    retlw	0x27
    retlw	0x50
    retlw	0x72
    retlw	0x94
    retlw	0x18
    retlw	0x40
    retlw	0x63
    retlw	0x85
    retlw	0x08
    retlw	0x29
    retlw	0x51
    retlw	0x74
    retlw	0x94
    retlw	0x14
    retlw	0x36
    retlw	0x60
    retlw	0x84
    retlw	0x02
    retlw	0x22
    retlw	0x65
    retlw	0x08
    retlw	0x13
    retlw	0x18
    retlw	0x22
    retlw	0x27
    retlw	0x32
    retlw	0x37
    retlw	0x42
    retlw	0x46
    retlw	0x51
    retlw	0x56
    retlw	0x61
    retlw	0x65
    retlw	0x69
    retlw	0x75
    retlw	0x79
    retlw	0x85
    retlw	0x89
    retlw	0x94
    retlw	0x98
    retlw	0x03
    retlw	0x08
    retlw	0x12
    retlw	0x17
    retlw	0x40
    retlw	0x85
    retlw	0x30
    retlw	0x75
    retlw	0x19
    retlw	0x61
    retlw	0x56
    retlw	0x06
    retlw	0x95
    retlw	0x55
    retlw	0x42
    retlw	0x83
    retlw	0x83
    retlw	0x83
    retlw	0x84
    retlw	0x85
    retlw	0x86
    retlw	0x87



    ORG 0x0200			;Origen de la tabla
tabla_sig_triangular_bajada:	;Tabla que mapea los valores de decremento de la señal diente de sierra a una señal triangular
    clrf PCLATH			;0 al PCLATH
    bsf PCLATH,1		;Bit mas significativo donde se encuentra la tabla
    addwf PCL,F			;W es el offset de la tabla. 
    retlw	255
    retlw	253
    retlw	251
    retlw	249
    retlw	247
    retlw	245
    retlw	243
    retlw	241
    retlw	239
    retlw	237
    retlw	235
    retlw	233
    retlw	231
    retlw	229
    retlw	227
    retlw	225
    retlw	223
    retlw	221
    retlw	219
    retlw	217
    retlw	215
    retlw	213
    retlw	211
    retlw	209
    retlw	207
    retlw	205
    retlw	203
    retlw	201
    retlw	199
    retlw	197
    retlw	195
    retlw	193
    retlw	191
    retlw	189
    retlw	187
    retlw	185
    retlw	183
    retlw	181
    retlw	179
    retlw	177
    retlw	175
    retlw	173
    retlw	171
    retlw	169
    retlw	167
    retlw	165
    retlw	163
    retlw	161
    retlw	159
    retlw	157
    retlw	155
    retlw	153
    retlw	151
    retlw	149
    retlw	147
    retlw	145
    retlw	143
    retlw	141
    retlw	139
    retlw	137
    retlw	135
    retlw	133
    retlw	131
    retlw	129
    retlw	127
    retlw	125
    retlw	123
    retlw	121
    retlw	119
    retlw	117
    retlw	115
    retlw	113
    retlw	111
    retlw	109
    retlw	107
    retlw	105
    retlw	103
    retlw	101
    retlw	99
    retlw	97
    retlw	95
    retlw	93
    retlw	91
    retlw	89
    retlw	87
    retlw	85
    retlw	83
    retlw	81
    retlw	79
    retlw	77
    retlw	75
    retlw	73
    retlw	71
    retlw	69
    retlw	67
    retlw	65
    retlw	63
    retlw	61
    retlw	59
    retlw	57
    retlw	55
    retlw	53
    retlw	51
    retlw	49
    retlw	47
    retlw	45
    retlw	43
    retlw	41
    retlw	39
    retlw	37
    retlw	35
    retlw	33
    retlw	31
    retlw	29
    retlw	27
    retlw	25
    retlw	23
    retlw	21
    retlw	19
    retlw	17
    retlw	15
    retlw	13
    retlw	11
    retlw	9
    retlw	7
    retlw	5
    retlw	3
    retlw	1   ;
    
     ORG 0x028C		    ;Origen de la tabla
frecuencias_disp23_CUAD:    ;Tabla de frecuencias para la señal cuadrada para los display 2 y 3
    clrf PCLATH		    ;0 al PCLATH
    bsf PCLATH,1	    ;Bit mas significativo de la direccion de la tabla
    movf PUNTERO,W	    ;El valor PUNTERO sera el offset de la tabla 
    addwf PCL,F		    
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x01
    retlw	0x01
    retlw	0x01
    retlw	0x01
    retlw	0x02
    retlw	0x02
    retlw	0x02
    retlw	0x02
    retlw	0x03
    retlw	0x03
    retlw	0x03
    retlw	0x03
    retlw	0x04
    retlw	0x04
    retlw	0x04
    retlw	0x04
    retlw	0x05
    retlw	0x05
    retlw	0x05
    retlw	0x05
    retlw	0x05
    retlw	0x06
    retlw	0x06
    retlw	0x06
    retlw	0x06
    retlw	0x07
    retlw	0x07
    retlw	0x07
    retlw	0x07
    retlw	0x07
    retlw	0x08
    retlw	0x08
    retlw	0x08
    retlw	0x08
    retlw	0x09
    retlw	0x09
    retlw	0x09
    retlw	0x01
    retlw	0x01
    retlw	0x01
    retlw	0x01
    retlw	0x01
    retlw	0x01
    retlw	0x01
    retlw	0x01
    retlw	0x01
    retlw	0x01
    retlw	0x01
    retlw	0x01
    retlw	0x01
    retlw	0x01
    retlw	0x01
    retlw	0x01
    retlw	0x01
    retlw	0x01
    retlw	0x01
    retlw	0x01
    retlw	0x02
    retlw	0x02
    retlw	0x02
    retlw	0x02
    retlw	0x02
    retlw	0x02
    retlw	0x03
    retlw	0x03
    retlw	0x04
    retlw	0x04
    retlw	0x08
    retlw	0x12
    retlw	0x14
    retlw	0x17
    retlw	0x20
    retlw	0x20
    retlw	0x20
    retlw	0x20
    retlw	0x20
    retlw	0x20
    retlw	0x20
    retlw	0x20


    
     ORG 0x0300		;Origen de la tabla
tabla_seno_positivo:	;Tabla de los valores mapeados de una señal diente de sierra a una señal senoidal
    clrf PCLATH		;0 al PCLATH
    bsf PCLATH,1	;Bits mas significativo donde se encuentra la tabla
    bsf PCLATH,0    
    addwf PCL,F		;W es el offset de la tabla
    retlw	128
    retlw	131
    retlw	134
    retlw	137
    retlw	141
    retlw	144
    retlw	147
    retlw	150
    retlw	153
    retlw	156
    retlw	159
    retlw	162
    retlw	165
    retlw	168
    retlw	171
    retlw	174
    retlw	177
    retlw	180
    retlw	183
    retlw	186
    retlw	189
    retlw	191
    retlw	194
    retlw	197
    retlw	199
    retlw	202
    retlw	205
    retlw	207
    retlw	209
    retlw	212
    retlw	214
    retlw	217
    retlw	219
    retlw	221
    retlw	223
    retlw	225
    retlw	227
    retlw	229
    retlw	231
    retlw	233
    retlw	235
    retlw	236
    retlw	238
    retlw	240
    retlw	241
    retlw	243
    retlw	244
    retlw	245
    retlw	246
    retlw	248
    retlw	249
    retlw	250
    retlw	251
    retlw	252
    retlw	252
    retlw	253
    retlw	254
    retlw	254
    retlw	255
    retlw	255
    retlw	255
    retlw	255
    retlw	255
    retlw	255
    retlw	255
    retlw	255
    retlw	255
    retlw	255
    retlw	255
    retlw	255
    retlw	254
    retlw	254
    retlw	253
    retlw	253
    retlw	252
    retlw	251
    retlw	250
    retlw	249
    retlw	248
    retlw	247
    retlw	246
    retlw	245
    retlw	243
    retlw	242
    retlw	240
    retlw	239
    retlw	237
    retlw	236
    retlw	234
    retlw	232
    retlw	230
    retlw	228
    retlw	226
    retlw	224
    retlw	222
    retlw	220
    retlw	218
    retlw	215
    retlw	213
    retlw	211
    retlw	208
    retlw	206
    retlw	203
    retlw	201
    retlw	198
    retlw	195
    retlw	193
    retlw	190
    retlw	187
    retlw	184
    retlw	181
    retlw	179
    retlw	176
    retlw	173
    retlw	170
    retlw	167
    retlw	164
    retlw	161
    retlw	158
    retlw	155
    retlw	152
    retlw	148
    retlw	145
    retlw	142
    retlw	139
    retlw	136
    retlw	133
    retlw	130
    retlw	126 ;

    ORG 0x038C		    ;Origen de la tabla
frecuencias_disp01_OTRA:    ;Tabla de frecuencias para la señal triangular o senoidal en los display 0 y 1
    clrf PCLATH		    ;0 al PCLATH
    movlw 0x03		    ;valor del byte mas significativo de la direccion de la tabla
    movwf PCLATH	    ;Movemos el valor anterior al PCLATH
    movf PUNTERO,W	    ;El valor PUNTERO sera el offset de la tabla 
    addwf PCL,F
    retlw	0x00
    retlw	0x01
    retlw	0x01
    retlw	0x02
    retlw	0x02
    retlw	0x02
    retlw	0x03
    retlw	0x03
    retlw	0x03
    retlw	0x04
    retlw	0x04
    retlw	0x04
    retlw	0x05
    retlw	0x05
    retlw	0x06
    retlw	0x06
    retlw	0x06
    retlw	0x07
    retlw	0x07
    retlw	0x07
    retlw	0x08
    retlw	0x08
    retlw	0x09
    retlw	0x09
    retlw	0x09
    retlw	0x10
    retlw	0x10
    retlw	0x11
    retlw	0x11
    retlw	0x11
    retlw	0x12
    retlw	0x12
    retlw	0x12
    retlw	0x13
    retlw	0x13
    retlw	0x14
    retlw	0x14
    retlw	0x14
    retlw	0x15
    retlw	0x15
    retlw	0x16
    retlw	0x16
    retlw	0x17
    retlw	0x18
    retlw	0x18
    retlw	0x19
    retlw	0x20
    retlw	0x20
    retlw	0x21
    retlw	0x22
    retlw	0x23
    retlw	0x24
    retlw	0x24
    retlw	0x25
    retlw	0x25
    retlw	0x26
    retlw	0x27
    retlw	0x27
    retlw	0x28
    retlw	0x29
    retlw	0x30
    retlw	0x31
    retlw	0x31
    retlw	0x32
    retlw	0x32
    retlw	0x36
    retlw	0x42
    retlw	0x50
    retlw	0x55
    retlw	0x63
    retlw	0x68
    retlw	0x25
    retlw	0x78
    retlw	0x20
    retlw	0x50
    retlw	0x50
    retlw	0x50
    retlw	0x50
    retlw	0x50
    retlw	0x50
    retlw	0x50
    retlw	0x50
    retlw	0x51


    
    ORG 0x0400		;Origen de la tabla
 tabla_seno_negativo:	;Tabla de valores mapeados de una señal diente de sierra para mostrar una señal senoidal
    clrf PCLATH		;0 al PCLATH
    bsf PCLATH,2	;Bit mas significativo donde se encuentra la tabla
    addwf PCL,F		;W es el offset de la tabla
    retlw	126
    retlw	123
    retlw	120
    retlw	117
    retlw	114
    retlw	111
    retlw	108
    retlw	104
    retlw	101
    retlw	98
    retlw	95
    retlw	92
    retlw	89
    retlw	86
    retlw	83
    retlw	80
    retlw	77
    retlw	75
    retlw	72
    retlw	69
    retlw	66
    retlw	63
    retlw	61
    retlw	58
    retlw	55
    retlw	53
    retlw	50
    retlw	48
    retlw	45
    retlw	43
    retlw	41
    retlw	38
    retlw	36
    retlw	34
    retlw	32
    retlw	30
    retlw	28
    retlw	26
    retlw	24
    retlw	22
    retlw	20
    retlw	19
    retlw	17
    retlw	16
    retlw	14
    retlw	13
    retlw	11
    retlw	10
    retlw	9
    retlw	8
    retlw	7
    retlw	6
    retlw	5
    retlw	4
    retlw	3
    retlw	3
    retlw	2
    retlw	2
    retlw	1
    retlw	1
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	1
    retlw	1
    retlw	1
    retlw	2
    retlw	2
    retlw	3
    retlw	4
    retlw	4
    retlw	5
    retlw	6
    retlw	7
    retlw	8
    retlw	10
    retlw	11
    retlw	12
    retlw	13
    retlw	15
    retlw	16
    retlw	18
    retlw	20
    retlw	21
    retlw	23
    retlw	25
    retlw	27
    retlw	29
    retlw	31
    retlw	33
    retlw	35
    retlw	37
    retlw	39
    retlw	42
    retlw	44
    retlw	47
    retlw	49
    retlw	51
    retlw	54
    retlw	57
    retlw	59
    retlw	62
    retlw	65
    retlw	67
    retlw	70
    retlw	73
    retlw	76
    retlw	79
    retlw	82
    retlw	85
    retlw	88
    retlw	91
    retlw	94
    retlw	97
    retlw	100
    retlw	103
    retlw	106
    retlw	109
    retlw	112
    retlw	115
    retlw	119
    retlw	122
    retlw	125
    retlw	128 ;
    
    ORG 0x048C		    ;Origen de la  tabla
frecuencias_disp23_OTRA:    ;Tabla de frecuencias para la señal triangular o senoidal para los display 2 y 3
    clrf PCLATH		    ;0 al PCLATH
    movlw 0x04		    ;Valor del byte mas significativo de la direccion de la tabla
    movwf PCLATH	    ;Movemos el valor anterior al PCLATH
    movf PUNTERO,W	    ;El valor PUNTERO sera el offset de la tabla 
    addwf PCL,F
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x00
    retlw	0x01
    retlw	0x01
    retlw	0x02
    retlw	0x02
    retlw	0x02
    retlw	0x02
    retlw	0x02
    retlw	0x02
    retlw	0x02
    retlw	0x02
    retlw	0x02
    retlw	0x02

    
    ORG 0x0700		    ;Origen de la tabla
tabla_conversion_display:   ;tabla donde se retorna el valor de la suma. PARA CATODO
    clrf PCLATH		    ;0 al PCLATH
    bsf PCLATH,2	    ;Bit mas significativo donde se encuentra la tabla
    bsf PCLATH,1
    bsf PCLATH,0
    addwf PCL,F		    ;W es el offset de la tabla
    retlw 00111111B ;0
    retlw 00000110B ;1
    retlw 01011011B ;2
    retlw 01001111B ;3
    retlw 01100110B ;4
    retlw 01101101B ;5
    retlw 01111101B ;6
    retlw 00000111B ;7
    retlw 01111111B ;8
    retlw 01101111B ;9
    
    ORG 0x0800		    ;Origen de la tabla (pagina 1)
tabla_PRESCALER:	    ;Tabla de los valores correspondientes al prescaler para cada uno de los valores del puntero.
    clrf PCLATH		    ;0 al PCLATH
    movlw 0x08		    ;Byte mas significativo de la direccion de la tabla
    movwf PCLATH	    ;movemos el valor anterior al PCLATH
    movf PUNTERO,W	    ;El valor PUNTERO sera el offset de la tabla 
    addwf PCL,F
    retlw	7
    retlw	7
    retlw	7
    retlw	7
    retlw	4
    retlw	4
    retlw	4
    retlw	4
    retlw	4
    retlw	4
    retlw	4
    retlw	4
    retlw	4
    retlw	4
    retlw	4
    retlw	4
    retlw	3
    retlw	3
    retlw	3
    retlw	2
    retlw	2
    retlw	2
    retlw	2
    retlw	2
    retlw	2
    retlw	2
    retlw	2
    retlw	2
    retlw	2
    retlw	2
    retlw	2
    retlw	2
    retlw	2
    retlw	2
    retlw	2
    retlw	2
    retlw	2
    retlw	2
    retlw	2
    retlw	1
    retlw	1
    retlw	1
    retlw	1
    retlw	1
    retlw	1
    retlw	1
    retlw	1
    retlw	1
    retlw	1
    retlw	1
    retlw	1
    retlw	1
    retlw	1
    retlw	1
    retlw	1
    retlw	1
    retlw	1
    retlw	1
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
    retlw	0
         

    ORG 0x0900		;Origen de la tabla
tabla_TMR0:		;Tabla con los valores del N del TMR0 que es el valor inicial del temporizador correspondientes a cada uno de los valores del PUNTERO.
    clrf PCLATH		;0 al PCLATH
    movlw 0x09		;Valor del Byte de direccion mas significativo de la tabla 
    movwf PCLATH	;Movemos el valor anterior al PCLATH
    movf PUNTERO,W	;El valor PUNTERO sera el offset de la tabla 
    addwf PCL,F
    retlw	100
    retlw	178
    retlw	204
    retlw	217
    retlw	6
    retlw	48
    retlw	78
    retlw	100
    retlw	117
    retlw	131
    retlw	143
    retlw	152
    retlw	160
    retlw	167
    retlw	173
    retlw	178
    retlw	109
    retlw	117
    retlw	125
    retlw	6
    retlw	18
    retlw	29
    retlw	39
    retlw	48
    retlw	56
    retlw	64
    retlw	71
    retlw	78
    retlw	84
    retlw	90
    retlw	95
    retlw	100
    retlw	105
    retlw	109
    retlw	113
    retlw	117
    retlw	121
    retlw	125
    retlw	128
    retlw	6
    retlw	18
    retlw	29
    retlw	39
    retlw	48
    retlw	56
    retlw	64
    retlw	71
    retlw	78
    retlw	84
    retlw	89
    retlw	95
    retlw	100
    retlw	105
    retlw	109
    retlw	113
    retlw	117
    retlw	121
    retlw	125
    retlw	0
    retlw	6
    retlw	12
    retlw	18
    retlw	24
    retlw	29
    retlw	34
    retlw	56
    retlw	89
    retlw	113
    retlw	131
    retlw	145
    retlw	156
    retlw	206
    retlw	223
    retlw	231
    retlw	236
    retlw	240
    retlw	242
    retlw	244
    retlw	245
    retlw	246
    retlw	252
    retlw	254
    retlw	255
     
    
   ;---------------- MACROS -------------------  

restart_tmr0 macro TMR0_REG	;Macro de Reinicio del conteo del TMR0
    banksel PORTA		;banco 00
    movf TMR0_REG,W		;Se mueve el valor variable del TMR0
    movwf TMR0			;valor inicial del TMR0
    bcf T0IF			;Se apaga la bandera de interrupci?n por Overflow del TMR0
    endm    
  
set_tmr0 macro PRESCALER_REG	;Macro para configurar el PRESCALER del TMR0
    Banksel TRISA
    MOVLW    0b11111000		;Mask prescaler
    ANDWF    OPTION_REG,W	;bits
    IORWF    PRESCALER_REG,W    ;Set  prescaler
    MOVWF    OPTION_REG    
    endm
    

 ;-------------Vector de Interrupcion---------
    
ORG 0x0004			;posicionamiento para las interrupciones.
push:
    clrf PCLATH
    movwf W_TEMP	    ;guardado temporal de STATUS y W
    swapf STATUS, W 
    movwf STATUS_TEMP
isr:			    ;instrucciones de la interrupcion
    btfsc TMR2IF	    ;Verificacion de la bandera de interrupcion del Timer2
    call inte_TMR2
    btfsc T0IF		    ;Verificacion de la bandera de interrupcion del Timer0
    call inte_TMR0
    btfsc RBIF		    ;Verificacion de la bandera de interrupcion del PUERTOB
    call inte_portb
pop:			    ;Retorno de los valores previos de W y STATUS
    swapf STATUS_TEMP, W
    movwf STATUS
    swapf W_TEMP, F
    swapf W_TEMP, W
    retfie   
    
           
    ORG 0x0500	; posicion para el c?digo
 
 ;------configuracion-------
main:   
    banksel PORTA
    call config_io	;Configuracion de los puertos ENTRADAS/SALIDAS
    call config_reloj	;Configuracion del oscilador Interno
    call config_push	;Configuracion de los pull-ups
    call config_inte	;Configuracion y habilitacion de las interrupciones
    call config_tmr2	;Configuracion del TMR2 como temporizador
    call config_tmr0	;Configuracion del TMR0 como temporizador
    
    banksel PORTA
    bsf PORTE,0
    
    clrf PRESCALER_TEMP	;Inicialización en 0 de las variables
    clrf TMR0_TEMP
    clrf S_DIENTE
    clrf S_CUAD_SEL
    clrf SELEC_SIG
    movlw 2
    movwf SELEC_SIG
    clrf PUNTERO
    clrf bandera
    clrf display
    clrf display+1
    clrf display+2
    clrf display+3

 
    ;------loop principal-------
loop:
    goto loop
    
    
    ;---------- SubRutinas de INTERRUPCION -----------    
    
inte_TMR2:		    ;Subrutina de interrupcion del TMR2
    banksel TMR2
    clrf TMR2		    ;Reinicio del TMR2
    call display_var	    ;Cambio de display
    bcf TMR2IF		    ;Apagado de la bandera de interrupcion del TMR2
   
    clrf val_display
    clrf val_display+1
    clrf val_display+2
    clrf val_display+3
    call obtener_valores
    call preparar_displays
    return  
    
inte_TMR0:
    restart_tmr0 TMR0_TEMP  ;Reinicio TMR0 con el macro
    incf S_DIENTE	    ;Incremento del contador el cual gráficamente se visualiza como una señal diente de sierra por medio del DAC.
    incf S_DIENTE	    ;Incremento doble para duplicar la frecuencia
    movlw 0x01		    ;Se mueve el valor 1 a W
    xorwf   S_CUAD_SEL, F    ;Dependiendo del valor de SELEC_SIG el resultado del XOR va a ser 1 o 0 y se guarda en el mismo registro
    call    mapear_salidas
    return    
    
mapear_salidas:
    banksel PORTA
    btfss SELEC_SIG,1	    ;Revision del estado de elección de la onda de salida 
    goto $+5		    ;Si Bit=0, entonces lee esta linea
    call map_sig_cuadrada   ;Subrutina para el mapeo de valores para visualizar una señal Cuadrada
    movf S_CUADRADA, W	    ;Se manda el valor mapeado para la señal cuadrada al puerto de salida al DAC.
    movwf PORTA
    return
    btfsc SELEC_SIG,0	    ;Revision del estado de elección de la onda de salida 
    goto $+5		    ;Si Z=1, entonces lee esta linea
    call map_sig_triangular ;Subrutina para el mapeo de valores para visualizar una señal Triangular
    movf S_TRIANGULAR, W    ;Se manda el valor mapeado para la señal triangular al puerto de salida al DAC
    movwf PORTA
    return
    call map_sig_senoidal   ;Subrutina para el mapeo de valores para visualizar una señal Senoidal
    movf S_SENOIDAL, W	    ;Se manda el valor mapeado para la señal senoidal al puerto de salida al DAC
    movwf PORTA
    return
    
map_sig_cuadrada:
    btfsc S_CUAD_SEL,0	    ;Verifiacion del bit 0 del registro S_CUAD_SEL
    goto $+3		    
    clrf S_CUADRADA	    ;Si esta en 0 el bit 0 del registro S_CUAD_SEL, entonces hago un clrf del registro S_CUADRADA
    return
    movlw 255		    ;Si esta en 1 el bit 0 del registro S_CUAD_SEL, entonces muevo el valor de 255 al registro S_CUADRADA
    movwf S_CUADRADA
    return
    
    /*
     ;Mapeo de la cuadrada teniendo la misma frecuencia
    btfss   S_DIENTE, 7
    goto    $+3
    clrf    S_CUADRADA
    RETURN
    MOVLW   255
    MOVWF   S_CUADRADA
    return
    */
       
map_sig_triangular:
    btfsc   S_DIENTE, 7			;Verificacion del bit 7 del registro S_DIENTE, este se prende desde el valor 128
    goto    $+5
    movf S_DIENTE, W			;Si esta en 0, entonces mapeamos con los valores de incremento para la señal triangular.
    call tabla_sig_triangular_subida
    movwf S_TRIANGULAR
    RETURN
    movf S_DIENTE, W			;Si esta en 1, entonces mapeamos los valores de dcremento para la señal triangular.
    addlw 128				;Sumamos 128 para que empiece desde 0
    call tabla_sig_triangular_bajada	 
    movwf S_TRIANGULAR
    return    
    
map_sig_senoidal:
    btfsc   S_DIENTE, 7		;Verificacion del bit 7 del registro s_DIENTE, este se presende desde el valor 128
    goto    $+5
    movf S_DIENTE, W		;Si esta en 0, entonces mapeamos los valores de la tabla seno positivo 
    call tabla_seno_positivo
    movwf S_SENOIDAL
    RETURN
    movf S_DIENTE, W		;Si esta en 1, entonces mapeamos los valores de la tabla seno negativo.
    addlw 128			;Sumamos 128 para que empiece desde 0
    call tabla_seno_negativo
    movwf S_SENOIDAL
    return
           
inte_portb:		    ;interrupcion en el puertoB
    banksel PORTA
    
    btfss PORTB,BT	    ;Si el bit 4 cambio, entonces se llama la subrutina
    call cambio_sig
    
    btfss PORTB, UP1	    ;Si el bit 0 cambio, entonces se llama la subrutina
    incf PUNTERO,F
    btfss PORTB, DOWN1	    ;Si el bit 1 cambio, entonces se llama la subrutina
    decf PUNTERO,F
    
    ;btfss PORTB, 0	    ;ANTIRREBOTE NO FUNCIONAL
    ;goto $-1
    ;btfss PORTB, 1
    ;goto $-1
    
    btfss PORTB, UP2	    ;Si el bit 2 cambio, entonces se llama la subrutina
    clrf PUNTERO
    btfss PORTB, DOWN2	    ;Si el bit 3 cambio, entonces se llama la subrutina
    call set_kHz_prescaler
    call limit_puntero
    
    pagesel tabla_PRESCALER	;Seleccion de la pagina 1
    call tabla_PRESCALER	
    pagesel main
    movwf PRESCALER_TEMP
    pagesel tabla_PRESCALER
    call tabla_TMR0
    pagesel main		;Seleccion de la pagina 0
    movwf TMR0_TEMP
   
    set_tmr0 PRESCALER_TEMP ;macro que establece la configuracion del prescaler del tmr0
    
    banksel PORTA
    bcf RBIF		    ;Se limpia la bandera de interrupcion del PORTB
    
    btfss SELEC_SIG,1	    ;Verificacion de la señal cuadrada
    goto $+8
    movf PUNTERO, W	    ;Si se esta en la señal cuadrada, revision del valor 40 del puntero para setear el led de kHz
    sublw 40
    btfsc STATUS,0
    goto $+4
    clrf PORTE
    bsf PORTE,1
    goto $+3
    clrf PORTE		    ;Sino siempre se mantiene encendido el led de Hz
    bsf PORTE,0
    return
              
cambio_sig:		    ;Subrutina que establece el bit que hace el cambio entre una señal cuadrada y triangular.
    clrf S_DIENTE
    clrf S_TRIANGULAR
    clrf S_CUADRADA
    clrf S_SENOIDAL
    
    incf SELEC_SIG	    ;Incremento del contador de 0 a 2
    movlw 3		    ;Verificacion del contador para setearlo en 0 si se pasa a 3.
    subwf SELEC_SIG,W
    btfsc STATUS,2 
    clrf SELEC_SIG
    return    
    
limit_puntero:		; subrutina que limita el registro del PUNTERO a no ser mayor de 82
    btfss PUNTERO, 7	; Verificacion del bit 7 del PUNTERO, esto quiere decir que se decremento y se coloco en 255
    goto $+4		
    movlw 82		; Si el bit 7 se encendio, se mueve el valor de 82 que es el maximo del PUNTERO utilizado en las tablas de este proyecto.
    movwf PUNTERO
    return
    movlw 83		;Por el contrario verificamos si incrementamos de mas, de 82 a 83 y por lo tanto seteamos en 0 por que se alcanzo el maximo.
    subwf PUNTERO, W
    btfsc STATUS, 2
    clrf PUNTERO
    return    

set_kHz_prescaler:	;Subrutina que mueve el valor de 41 al PUNTERO que es donde comienzan los valor en kHz para la señal cuadrada
    movlw 41		
    movwf PUNTERO
    return
    
    ;------- SUBRUTINAS LOOP ------

  obtener_valores:
    banksel PORTA
    btfss SELEC_SIG,1		    ;Si el bit 1 del registro SELEC_SIG esta en 1, entonces hace un salto de linea para obtener los valores de frecuencia correspondientes a la señal cuadrada
    goto $+16
    call frecuencias_disp01_CUAD
    andlw 0b00001111
    movwf val_display		    ;Valor del nibble bajo guardado para el display 0
    call frecuencias_disp01_CUAD
    andlw 0b11110000
    movwf val_display+1
    swapf val_display+1,F	    ;Valor del nibble alto guardado para el display 1
    call frecuencias_disp23_CUAD
    andlw 0b00001111
    movwf val_display+2		    ;Valor del nibble bajo guardado para el display 2
    call frecuencias_disp23_CUAD
    andlw 0b11110000
    movwf val_display+3
    swapf val_display+3,F	    ;Valor del nibble alto guardado para el display 3
    return
    call frecuencias_disp01_OTRA    ;Si el bit 1 del registro SELEC_SIG esta en 0, entonces obtiene los valores de frecuencias para las señales triangular y senoidal
    andlw 0b00001111
    movwf val_display		    ;Valor del nibble bajo guardado para el display 0
    call frecuencias_disp01_OTRA
    andlw 0b11110000
    movwf val_display+1
    swapf val_display+1,F	    ;Valor del nibble alto guardado para el display 1
    call frecuencias_disp23_OTRA
    andlw 0b00001111
    movwf val_display+2		    ;Valor del nibble bajo guardado para el display 2
    call frecuencias_disp23_OTRA
    andlw 0b11110000
    movwf val_display+3
    swapf val_display+3,F	    ;Valor del nibble alto guardado para el display 3
    return
    
display_var:
    banksel PORTD
    clrf    PORTD
    btfss bandera, 1	;Se revisa si el bit 1 del registro bandera está en 1, si es 1 entonces salta la linea para revisar display 2 y 3. 
    goto $+7		;Salto a revisar display 0 o 1
    btfsc bandera, 0	;Se revisa si el bit 0 del registro bandera está en 0, si es 0 entonces salta la línea para ir al display 2.
    goto $+3
    call display_2
    return
    call display_3	;Si el bit 0 del registro bandera está en 1, entonces va al display 3
    return   
    btfsc bandera, 0	;Si el bit 1 del registro bandera está en 0, entonces revisa display 0 y 1
    goto $+3
    call display_0	;Si el bit 0 del registro bandera está en 0, va al display 0
    return
    call display_1	;Si el bit 0 del registro bandera esta en 1, va al display 1
    return   
     
    ;RESUMEN TABLA DISPLAYS
    ; 00 = display_0
    ; 01 = display_1
    ; 10 = display_2
    ; 11 = display_3
    
display_0:
    movf    display, W	;Se mueve el valor en binario codificado para el display para visualizar el valor guardado para el display0
    movwf   PORTC
    clrf    PORTD
    bsf     PORTD,  0
    bcf	    bandera,1	;Se setea la bandera para mostrar el display1 en la siguiente interrupción
    bsf	    bandera,0
    return
    
display_1:
    movf    display+1, W ;Se mueve el valor en binario codificado para el display para visualizar el valor guardado para el display1
    movwf   PORTC
    clrf    PORTD
    bsf     PORTD,  1
    bsf	    bandera,1	;Se setea la bandera para mostrar el display2 en la siguiente interrupción.
    bcf	    bandera,0
    return
    
display_2:
    movf    display+2, W ;Se mueve el valor en binario codificado para el display para visualizar el valor guardado para el display2
    movwf   PORTC
    clrf    PORTD
    bsf     PORTD,  2
    bsf	    bandera,0	;Se setea la bandera para mostrar el display 3 en la siguiente interrupción
    bsf	    bandera,1
    return    
    
display_3:
    movf    display+3, W ;Se mueve el valor en binario codificado para el display para visualizar el valor guardado para el display3
    movwf   PORTC
    clrf    PORTD
    bsf     PORTD,  3
    bcf	    bandera,0	;Se setea para volver a iniciar en el display 0 en la siguiente interrupción
    bcf	    bandera,1
    return      
    
preparar_displays:	    ;Subrutina que setea el valor binario de cada display y lo guarda en el registro respectivo.
    movf    val_display, W
    call    tabla_conversion_display
    movwf   display
    
    movf    val_display+1, W
    call    tabla_conversion_display
    movwf   display+1
    
    movf    val_display+2, W
    call    tabla_conversion_display
    movwf   display+2
    
    btfss SELEC_SIG,1	;Si la señal es la cuadrada, entonces reviso lo siguiente:
    goto $+6
    movf PUNTERO, W	;Si el puntero esta en los kHz
    sublw 40
    btfsc STATUS,0
    goto $+2
    bsf display+2,7	;Activo el punto para mostrar los kHz con dos decimales

    movf    val_display+3, W
    call    tabla_conversion_display
    movwf   display+3
    return

    ;-------- SUBRUTINAS DE CONFIGURACIÓN ---------  

config_tmr2:
    Banksel PIE1 ;Banco 1
    bsf TMR2IE ; (TMR2IE) 1 = Enables the Timer2 to PR2 match interrupt
    movlw 0
    movwf PR2	;Valor de comparacion del TMR2
    
    Banksel T2CON ;Banco 0
    bsf TOUTPS3	;Postcaler default 10 (1111)
    bsf TOUTPS2
    bsf TOUTPS1
    bsf TOUTPS0
    
    bsf T2CKPS1	   ;Prescaler 16 (1X)
    bsf T2CKPS0
    
    bcf TMR2IF
     
    bsf TMR2ON	;Encendido del conteo del TMR2
    return
    
    
config_tmr0:
    Banksel TRISA
    bcf T0CS	;TMR0 como temporizador
    bcf PSA	;Asignación del Preescaler en el TMR0 = 0
    bsf PS2	    
    bsf PS1
    bsf PS0	;Prescaler de 1:256 por DEFAULT(111)
    restart_tmr0 TMR0_TEMP  
    return           
    
config_push:
    banksel TRISA
    bsf IOCB,0	    ; Interrupcion ON-CHANGE habilitada para el bit 0 del PORTB
    bsf IOCB,1	    ; Interrupcion ON-CHANGE habilitada para el bit 1 del PORTB
    bsf IOCB,2
    bsf IOCB,3
    bsf IOCB,4
    
    banksel PORTA
    movf PORTB, W   ;lectura del PORTB
    bcf RBIF	    ;Se limpia la bandera RBIF
    return
    
config_io:    
    Banksel ANSEL
    clrf ANSEL	    ; 0 = pines digitales, ANS<4:0> = PORTA,  ANS<7:5> = PORTE // Clear Register ANSEL
    clrf ANSELH	    ; 0 = pines digitales, ANS<13:8>, estos corresponden al PORTB
    
    Banksel TRISA
    clrf TRISA ; 0 = Puertos como salida
    clrf TRISC 
    clrf TRISD
    clrf TRISE

    ; los primeros bits del registro PORTB se colocan como entrada digital
    bsf TRISB, UP1	; Bit set (1), BIT 1 del registro TRISB
    bsf TRISB, DOWN1	; Bit set (1), BIT 0 del registro TRISB
    bsf WPUB, UP1	; Habilitación pull-up
    bsf WPUB, DOWN1	; Habilitación pull-up
    
    bsf TRISB, UP2	; Bit set (1), BIT 2 del registro TRISB
    bsf TRISB, DOWN2	; Bit set (1), BIT 3 del registro TRISB
    bsf WPUB, UP2	; Habilitación pull-up
    bsf WPUB, DOWN2	; Habilitación pull-up
    
    bsf TRISB, BT	; Bit set (1), BIT 2 del registro TRISB
    bsf WPUB, BT	; Habilitación pull-up
    
    bcf OPTION_REG,7	;0 = Los pull-ups de PORTB están habilitados por valores individuales
    
    Banksel PORTA
    clrf PORTA ; 0 = Apagados, todos los bits del puerto.
    clrf PORTC
    clrf PORTD
    clrf PORTE
    return
    
config_reloj:
    banksel OSCCON
    ; frecuencia de 8MHz
    bsf IRCF2 ; OSCCON, 6
    bsf IRCF1 ; OSCCON, 5
    bsf IRCF0 ; OSCCON, 4
    bsf SCS ; reloj interno
    return
    
config_inte: ;configuracion de las interrupciones
    banksel PORTA
    bsf GIE	;Habilitacion de las interrupciones globales INTCON REGISTER
    
    bsf RBIE	;Habilitacion de interrupcion por cambio en el PORTB 
    bcf RBIF	;Apagar bandera de cambio en el PORTB.
    bsf T0IE	;Habilitacion de la interrupcion por overflow del TMR0
    bcf T0IF	;Apagar bandera de overflow del TMR0
    return
    
END ; Finalizacion del codigo  
     


