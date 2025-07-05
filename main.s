;START OF STARTER CODE
	EXPORT Reset_Handler
	EXPORT __Vectors
	;----------------
	;The vector tables
	;----------------
	AREA RESET, DATA, READONLY
__Vectors
	DCD stack_init ;init loc. 0 to 3 with stack bottom
	DCD Reset_Handler ;store Reset_Handler into loc. 4 to 7
	; reserving 400 bytes of RAM for stack
	AREA STACK, DATA, READWRITE
	SPACE 400
stack_init
	AREA MY_STARTUP, CODE, READONLY
Reset_Handler PROC
	LDR R5,=__main
	BX R5 ; go to __main
	ENDP

;END OF STARTER CODE

;Setup Clocks & Delay
;EEN2270
;Starter Code 


RCC_CR EQU 0x40021000
RCC_BASE EQU 0x40021000
RCC_CFGR EQU 0x40021004
RCC_TEST EQU 0x00021183
FLASH_ACR EQU 0x40022000
	
	
PORTC_BASE_ADDR EQU 0x40011000
GPIOC_CRH		EQU 0x40011004
GPIOC_ODR		EQU 0x4001100C

RCC_BASE_ADDR 	EQU	0x40021000
RCC_APB2ENR		EQU 0x40021018
RCC_APB1ENR		EQU 0x4002101C
	
;My Addresses
PORTA_BASE_ADDR EQU	0x40010800
GPIOA_CRH		EQU	0x40010804
GPIOA_ODR		EQU 0x4001080C 

PORTB_BASE_ADDR EQU 0x40010C00
GPIOB_CRH		EQU 0x40010C04
GPIOB_ODR		EQU 0x40010C0C
	
	
;TIMER SETUP

TIM2_CR1 EQU 0x40000000
TIM2_PSC EQU 0x40000028    ; Address of TIM2 prescaler register
TIM2_ARR EQU 0x4000002C    ; Address of TIM2 auto-reload register
TIM2_SR EQU  0x40000010    ; Address of TIM2 status register
TIM2_SR_UIF EQU (1 << 0)   ; Update interrupt flag for TIM2

	EXPORT delay
	AREA MAIN, CODE, READONLY
delay

	;Set the prescaler for 1ms ticks
    LDR R0, =TIM2_PSC
    MOV R1, #32000             ; Assuming APB1 clock (32MHz) / 32000 = 1kHz
    STR R1, [R0]
	
	;Set the auto-reload value for 1ms interrupts
    LDR R0, =TIM2_ARR
    MOV R1, #255              ; 999 For 1ms interrupt
    STR R1, [R0]
	
	;Enable TIM2
    LDR R0, =TIM2_CR1
    MOV R1, #0x01             	; Enable TIM2 
    STR R1, [R0]
	
	;TEST FOR Flag
	MOV  R2, #1             ; Load 1 into R2
    LSL  R2, R2, #0
	
TIM_loop
    LDR  R0, =TIM2_SR         ; Load FLASH_ACR base address
    LDR  R1, [R0, #0x00]       ; Load Flash_ACR Value into R1
    TST  R1, R2                ; Test PRFTBS bit bitwise AND
    BEQ  TIM_loop

	LDR R0, =TIM2_SR
    MOV R1, #0x00             	; Clear SR Flag 
    STR R1, [R0]

	;Disable TIM2
    LDR R0, =TIM2_CR1
    MOV R1, #0x00             	; Disable TIM2 
    STR R1, [R0]

	BX LR
	

	EXPORT __main	
	AREA   MAIN, CODE, READONLY
__main
	
	;Turn on HSE 
	LDR R0, =RCC_CR
	LDR R1, [R0]
	ORR R1, R1, #0x10000
	STR R1, [R0]
	
	MOV  R2, #1             ; Load 1 into R2
    LSL  R2, R2, #16        ; Left-shift R2 by 16 bits
	
	;Check if HSE is Ready
loop
    LDR  R0, =RCC_CR         ; Load RCC base address
    LDR  R1, [R0, #0x00]       ; Load RCC->CR into R1
    TST  R1, R2                ; Test HSERDY bit bitwise AND
    BEQ  loop                  ; Branch if HSERDY is not set

	;Enable the Prefetch
	LDR R0, =FLASH_ACR
	LDR R1, [R0]
	ORR R1, R1, #0x10
	STR R1, [R0]
	
	MOV  R2, #1             ; Load 1 into R2
    LSL  R2, R2, #4
	
	;Check if Prefetch is enabled
PRE_loop
    LDR  R0, =FLASH_ACR         ; Load FLASH_ACR base address
    LDR  R1, [R0, #0x00]       ; Load Flash_ACR Value into R1
    TST  R1, R2                ; Test PRFTBS bit bitwise AND
    BEQ  PRE_loop 

	;Clear Flash Latency Bits
	;THOUGHT EXCERCISE

	
	;Set Flash Latency Bits
	LDR R0, =FLASH_ACR
	LDR R1, [R0]
	ORR R1, R1, #0x01
	STR R1, [R0]
	
	
	;Reset MUL, XTPRE, SRC
	;THOUGHT EXERCISE
	
	;SET EVERYTHING
	LDR R0, =RCC_BASE
	LDR R1, [R0, #0x04]
	ORR R1, R1, #0x90000 ;Does not include the other scalers
	STR R1, [R0, #0x04]
	
	;Set System Clock Switch
	LDR R0, =RCC_BASE
	LDR R1, [R0, #0x04]
	ORR R1, R1, #0x1
	STR R1, [R0, #0x04]
	
	MOV  R2, #0x4             ; Load 1 into R2
	
	;Check if Prefetch is enabled
SWS_loop
    LDR  R0, =RCC_BASE         ; Load FLASH_ACR base address
    LDR  R1, [R0, #0x04]       ; Load Flash_ACR Value into R1
    TST  R1, R2                ; Test PRFTBS bit bitwise AND
    BEQ  SWS_loop


	LDR R1,=RCC_APB2ENR	; Load register Addresss
	LDR R0,[R1]			; Load data from register
	ORR R0,R0,#0xFC		;enable the clocks for GPIOs
	STR R0,[R1]
	
	LDR R0, =0x22322222	; Config for GPIOC P13 Output
	LDR R1, =GPIOC_CRH
	STR R0, [R1]
	
	;TIMER2 SETUP
	LDR R0, =RCC_BASE
	LDR  R1, [R0, #0x1C] ; Offset for RCC_APB1ENR
	ORR R1, R1, #0x1
	STR R1, [R0, #0x1C]
	
	;TIMER2 DISABLE
	LDR R0, =TIM2_CR1
	MOV R1, #0x00              ; Disable TIM2 during setup
	STR R1, [R0]
	
	;Ryan Dacy
	
CrosswalkSTOP
	MOV R6, #0
	
	;GREEN OFF
	LDR R1, =GPIOA_ODR
	LDR R0, [R1]
	BIC R0,R0, #0x8
	STR R0, [R1]
	
	;RED ON
	LDR R1, =GPIOA_ODR
	LDR R0, [R1]
	ORR R0,R0, #0x10
	STR R0, [R1]
	
	BL delay

StopLight1Red
	
	;My Code for PA0
	LDR R1,=RCC_APB2ENR	; Load register Addresss
	LDR R0,[R1]			; Load data from register
	ORR R0,R0,#0xFC		; Enable the clock 
	STR R0,[R1]
	
	LDR R0, =0x00022222; Config for GPIOA Outputs
	LDR R1, =PORTA_BASE_ADDR
	STR R0, [R1]
	
	;YELLOW OFF
	LDR R1, =GPIOA_ODR
	LDR R0, [R1]
	BIC R0,R0, #0x2
	STR R0, [R1]
	
	
	;RED ON
	LDR R1, =GPIOA_ODR
	LDR R0, [R1]
	ORR R0,R0, #0x1
	STR R0, [R1]
	
	;BL delay
	
	;Counter for the CrossWalk
	ADD R8, R8, #1
	CMP R8, #2
	BEQ CrosswalkGO
	BNE StopLight2Green
	
StopLight1Yellow
	
	
	;GREEN OFF
	LDR R1, =GPIOA_ODR
	LDR R0, [R1]
	BIC R0,R0, #0x4
	STR R0, [R1]
	
	;YELLOW ON
	LDR R1, =GPIOA_ODR
	LDR R0, [R1]
	ORR R0,R0, #0x2
	STR R0, [R1]
	
	BL delay
	B StopLight1Red
	
StopLight1Green	
	
	;RED1 OFF
	LDR R1, =GPIOA_ODR
	LDR R0, [R1]
	BIC R0,R0, #0x1
	STR R0, [R1]
	
	;GREEN ON
	LDR R1, =GPIOA_ODR
	LDR R0, [R1]
	ORR R0,R0, #0x4
	STR R0, [R1]
	BL delay
	BL delay
	B StopLight1Yellow

	;B RED2OFF
	
StopLight2Green
	
	;Code for GPIOB CRL pin
	LDR R0, =0x00000020; Config for GPIOB PA0 Output
	LDR R1, =PORTB_BASE_ADDR
	STR R0, [R1]
	
	;Code for GPIOB CRH pin
	LDR R0, =0x00002200; Config for GPIOB PA0 Output
	LDR R1, =GPIOB_CRH
	STR R0, [R1]
	
	;RED OFF
	LDR R1, =GPIOB_ODR
	LDR R0, [R1]
	BIC R0,R0, #0x2
	STR R0, [R1]
	
	;GREEN ON
	LDR R1, =GPIOB_ODR
	LDR R0, [R1]
	ORR R0,R0, #0x800
	STR R0, [R1]
	
	BL delay
	B StopLight2Yellow
	
StopLight2Yellow
	
	
	;GREEN OFF
	LDR R1, =GPIOB_ODR
	LDR R0, [R1]
	BIC R0,R0, #0x800
	STR R0, [R1]
	
	;YELLOW ON
	LDR R1, =GPIOB_ODR
	LDR R0, [R1]
	ORR R0,R0, #0x400
	STR R0, [R1]
	
	BL delay
	B StopLight2Red
	
StopLight2Red
	BL delay
	
	;YELLOW OFF
	LDR R1, =GPIOB_ODR
	LDR R0, [R1]
	BIC R0,R0, #0x400
	STR R0, [R1]
	
	;RED ON
	LDR R1, =GPIOB_ODR
	LDR R0, [R1]
	ORR R0,R0, #0x2
	STR R0, [R1]
	
	BL delay
	B StopLight1Green
	
;RED2OFF
	
	;BL delay
	
	;RED OFF
	;LDR R1, =GPIOB_ODR
	;LDR R0, [R1]
	;BIC R0,R0, #0x2
	;STR R0, [R1]
	;B GREEN1OFF
	

CrosswalkGO
	MOV R8, #0 ;Reset the Counter
	B CrosswalkGO3
	;Need a branch here for the normal stoplights to turn red while the crosswalk light is green 
FLASHRED
	
	BL delay
	
	;RED OFF
	LDR R1, =GPIOA_ODR
	LDR R0, [R1]
	BIC R0,R0, #0x10
	STR R0, [R1]
	
	BL delay
	
	;RED ON
	LDR R1, =GPIOA_ODR
	LDR R0, [R1]
	ORR R0,R0, #0x10
	STR R0, [R1]
	
	BL delay
	
	;RED OFF
	LDR R1, =GPIOA_ODR
	LDR R0, [R1]
	BIC R0,R0, #0x10
	STR R0, [R1]
	
	BL delay
	
	;RED ON
	LDR R1, =GPIOA_ODR
	LDR R0, [R1]
	ORR R0,R0, #0x10
	STR R0, [R1]
	
	BL delay
	
	B CrosswalkGO4
	
CrosswalkGO3
	
	BL delay
	BL delay
	;RED OFF
	LDR R1, =GPIOA_ODR
	LDR R0, [R1]
	BIC R0,R0, #0x10
	STR R0, [R1]
	
	
	;GREEN ON
	MOV R7, #0
	LDR R1, =GPIOA_ODR
	LDR R0, [R1]
	ORR R0,R0, #0x8
	STR R0, [R1]
	BL delay
	
	B FLASHRED
	
CrosswalkGO4	
	ADD R6, R6, #1
	CMP R6, #2
	BNE CrosswalkGO3
	BEQ CrosswalkSTOP



	
	
L1	
	LDR R1,=GPIOC_ODR
	LDR R0,[R1]			;R0 = ODR
	EOR R0,R0,#0x2000	;toggle bit 13
	;LDR R0, =0x00002000
	STR R0,[R1]			;ODR = R0


	;Start the delay
    ;MOV R2, #500			; Load delay duration
	BL delay
	B L1
	END
		
		