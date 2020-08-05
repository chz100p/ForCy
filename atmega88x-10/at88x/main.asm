
;
;	ForCy-AVR Project
;
;	Osamu Tamura @ Recursion Co., Ltd.
;
;	11/27/2005
;

.include "m88def.inc"		; ATmega88 definitions file


.equ	DS_TOP		= (SRAM_START+0xa0)
.equ	SP_BOTTOM	= DS_TOP-1

.equ	CLK_PER_SEC	= 500


;	status flag
.equ	_blank	= 7			; zero blanking
.equ	_intrpt	= 6			; interrupt enable
.equ	_chgsec	= 3			; second changed
.equ	_chgclk	= 2			; clk changed
.equ	_code2	= 1			; 2byte code table
.equ	_data2	= 0			; 2byte data table

.def	status	= r3

.def	zpL	= r4
.def	zpH	= r5

.def	bpL	= r6
.def	bpH	= r7

.def	ipL	= r8
.def	ipH	= r9

.def	upL	= r10
.def	upH	= r11

.def	vpL	= r12
.def	vpH	= r13

.def	stL	= r14
.def	stH	= r15

.def	cpL	= r16
.def	cpH	= r17

.def	tL	= r18
.def	tH	= r19

.def	t2L	= r20
.def	t2H	= r21

.def	t3L	= r22
.def	t3H	= r23

.def	dtL	= r24
.def	dtH	= r25


	.dseg

.equ	RX_SIZE	= 48
.equ	TX_SIZE	= 16
;.equ	RX_MASK	= (RX_SIZE-1)
.equ	TX_MASK	= (TX_SIZE-1)

pg_buf:		.byte	(PAGESIZE<<1)

rv_buf:		.byte	RX_SIZE
tx_buf:		.byte	TX_SIZE

pg_cur:		.byte	1

tm_cnt:		.byte	2
tm_clk:		.byte	2
tm_sec:		.byte	2

irptr:		.byte	1
iwptr:		.byte	1
urptr:		.byte	1
uwptr:		.byte	1

random:		.byte	2


	.cseg

UserCode:
;	.include	"test.asm"


	.org	0x0600

Compiler:

.if 1
	.include	"fcc.asm"


;	System Word Table

ShortCutTable:
		.dw	ShortNum
		.dw	ShortVar
		.dw	ShortVar_
		.dw	ShortArray
		.dw	ShortArray_
		.dw	ShortLP
		.dw	ShortLP_

SystemTable:
		.dw	SysReturn		; 0
		.dw	SysDo_
		.dw	SysNum
		.dw	SysNum2
		.dw	SysVar
		.dw	SysVar_
		.dw	SysArray
		.dw	SysArray_
		.dw	SysString
		.dw	SysString_

		.dw	SysLP			; 10
		.dw	CodeNext
		.dw	SysDo
		.dw	SysFor
		.dw	SysBreak
		.dw	SysWhile
		.dw	SysContinue
		.dw	SysIf
		.dw	SysElse
		.dw	SysCase
		.dw	SysSwitch		; 20
		.dw	SysOf
		.dw	MainLoop
		.dw	SysRtn
		.dw	SysInterrupt

		.dw	SysDrop
		.dw	Sys2Drop
		.dw	SysNip
		.dw	SysSwap
		.dw	SysDup
		.dw	SysOver			; 30
		.dw	SysPick
		.dw	SysPoke

		.dw	SysEq
		.dw	SysNeq
		.dw	SysLt
		.dw	SysGt
		.dw	SysLe
		.dw	SysGe

		.dw	SysInc
		.dw	SysDec			; 40
		.dw	SysAdd
		.dw	SysSub
		.dw	SysMul
		.dw	SysDiv
		.dw	SysMod
		.dw	SysDivMod
		.dw	SysLShift
		.dw	SysRShift
		.dw	SysAnd
		.dw	SysOr			; 50
		.dw	SysXor
		.dw	SysCmp
		.dw	SysLAnd
		.dw	SysLOr
		.dw	SysNot
		.dw	SysMin
		.dw	SysMax
		.dw	SysRnd

		.dw	SysClock
		.dw	SysSec			; 60

		.dw	SysKey
		.dw	SysGetC
		.dw	SysPutC
		.dw	SysPutS
		.dw	SysPutN
		.dw	SysPutH

		.dw	SysSFR
		.dw	SysSFR_

		.dw	SysProgram
		.dw	SysProgram_		; 70
		.dw	SysData
		.dw	SysData_
		.dw	Sys_Exec

		.dw	Sys_StrF
		.dw	Sys_RS
		.dw	Sys_DS
TableEnd:




MainLoop:
		ldi		tL, low(Compiler<<1)
		ldi		tH, high(Compiler<<1)
		movw	zpL, tL


Interpret:
		; reset base I/O
		clr		dtL
		out		DDRB, dtL
		out		DDRC, dtL
		out		DDRD, dtL
		ser		dtL
		out		PORTB, dtL
		out		PORTC, dtL
		out		PORTD, dtL

		; init buffer page
		ser		dtL
		sts		pg_cur, dtL

		; reset system stack pointer
		ldi		tL, low(SP_BOTTOM)
		ldi		tH, high(SP_BOTTOM)
		out		SPL, tL
		out		SPH, tH

		clr		status				; parse header block
		movw	zL, zpL

		lpm		dtL, z+				; #0
		cpi		dtL, 0xfc
		brne	MainLoop

		lpm		dtL, z+				; #1
		bst		dtL, 4
		bld		status, _code2
		bst		dtL, 0
		bld		status, _data2

		lpm		xH, z+				; #2
		lpm		xL, z+				; #3
		add		xL, zpL
		adc		xH, zpH
		movw	r0, zL
		movw	zL, xL
		sbiw	zL, 1
		clr		dtH
		lpm		dtL, z
		bst		status, _data2
		brtc	d2_skip
		sbiw	zL, 1
		lpm		dtH, z
d2_skip:
		movw	zL, r0
		lsl		dtL
		rol		dtH
		ldi		tL, low(DS_TOP)
		ldi		tH, high(DS_TOP)
		add		dtL, tL
		adc		dtH, tH
		movw	bpL, dtL
		movw	xL, dtL

		lpm		upH, z+				; #4
		lpm		upL, z+				; #5
		add		upL, zpL
		adc		upH, zpH

		lpm		vpH, z+				; #6
		lpm		vpL, z+				; #7
		add		vpL, zpL
		adc		vpH, zpH

		movw	r0, zL
		movw	zL, vpL
		sbiw	zL, 1
		clr		dtH
		lpm		dtL, z
		bst		status, _code2
		brtc	c2_skip
		sbiw	zL, 1
		lpm		dtH, z
c2_skip:
		movw	zL, r0
		movw	cpL, zpL
		add		cpL, dtL
		adc		cpH, dtH

		ldi		yL, low(RAMEND+1)
		ldi		yH, high(RAMEND+1)
		clr		ipL
		clr		ipH
		rjmp	CodeNext


SysInterrupt:
		ld		zL, y+
		ld		zH, y+
		lpm		tL, z
		cpi		tL, 0
		brne	intr_reg
		clr		ipL
		clr		ipH
		clt
		rjmp	intr_end
intr_reg:
		movw	ipL, zL
		set
intr_end:
		bld		status, _intrpt
		rjmp	CodeNext

SysRtn:
		ld		cpL, y+
		ld		cpH, y+
		cpi		cpH, 0x80
		brcs	SysRtn
		rjmp	ret_int

SysReturn:
		ld		cpL, y+
		ld		cpH, y+
ret_int:
		andi	cpH, 0x7f
		sbrs	cpH, 6
		rjmp	CodeNext
;		cpi		cpH, 0x40
;		brcs	CodeNext
		andi	cpH, 0x3f
		pop		stL
		pop		stH
		mov		tL, ipL
		or		tL, ipH
		breq	CodeNext
		set
		bld		status, _intrpt


CodeNext:
		wdr

		bst		status, _intrpt			; interrupt
		brtc	cnxt_sys

		bst		status, _chgclk
		brtc	cnxt_sec
		clt
		bld		status, _chgclk
		movw	zL, ipL
		rjmp	cnxt_intr
cnxt_sec:
		bst		status, _chgsec
		brtc	cnxt_sys
		clt
		bld		status, _chgsec
		movw	zL, ipL
		adiw	zL, 1
cnxt_intr:
		lpm		tL, z
		cpi		tL, 0x90
		brcc	cnxt_sys
		bld		status, _intrpt
		push	stH
		push	stL
		ori		cpH, 0x40
		rjmp	user_normal

cnxt_sys:
		movw	zL, cpL
		lpm		tL, z+
		movw	cpL, zL

		cpi		tL, TableEnd-SystemTable
		brcc	cnxt_short

		mov		zL, tL			; system word
		clr		zH
		lsl		zL
		rol		zH
		subi	zL, low(-(SystemTable<<1))
		sbci	zH, high(-(SystemTable<<1))
		lpm		tL, z+
		lpm		tH, z+
		movw	zL, tL
		ijmp

cnxt_short:
		cpi		tL, 0x90
		brcs	cnxt_user

		subi	tL, 0x90		; short cut
		clr		tH
		movw	zL, tL
		lsr		zL
		lsr		zL
		lsr		zL
		andi	zL, 0xfe
		subi	zL, low(-(ShortCutTable<<1))
		sbci	zH, high(-(ShortCutTable<<1))
		lpm		t2L, z+
		lpm		t2H, z+
		movw	zL, t2L
		ijmp

cnxt_user:
		movw	zL, cpL				; user word
		lpm		tH, z+
		cpi		tH, 0
		brne	user_normal
user_clear:							; optimize
		ld		zL, y+
		ld		zH, y+
		sbrc	zH, 6			; keep interrupt return
		rjmp	user_skip
		andi	zH, 0x7f
		lpm		tH, z+
		cpi		tH, 0
		breq	user_clear
user_skip:
		sbiw	yL, 2
		rjmp	user_next
user_normal:
		ori		cpH, 0x80
		st		-y, cpH
		st		-y, cpL
user_next:
		subi	tL, TableEnd-SystemTable
		clr		tH
		movw	zL, tL
		bst		status, _code2
		brtc	user_short
		lsl		zL
		rol		zH
		add		zL, upL
		adc		zH, upH
		lpm		cpH, z+
		lpm		cpL, z+
		rjmp	user_end
user_short:
		add		zL, upL
		adc		zH, upH
		clr		cpH
		lpm		cpL, z+
user_end:
		add		cpL, zpL
		adc		cpH, zpH
		rjmp	CodeNext

DataAddr:					;	zH:zL <- tH:tL
		movw	zL, tL
		bst		status, _data2
		brtc	data_short

		lsl		zL
		rol		zH
		add		zL, vpL
		adc		zH, vpH
		lpm		tH, z+
		lpm		tL, z+
		rjmp	data_end
data_short:
		add		zL, vpL
		adc		zH, vpH
		clr		tH
		lpm		tL, z+
data_end:
		lsl		tL
		rol		tH
		movw	zL, tL
		subi	zL, low(-DS_TOP)
		sbci	zH, high(-DS_TOP)
		ret


ShortNum:
		st		x+, dtL
		st		x+, dtH
		andi	tL, 0x0f
		clr		tH
		movw	dtL, tL
		rjmp	CodeNext

ShortVar:
		st		x+, dtL
		st		x+, dtH
		andi	tL, 0x0f
		clr		tH
		rcall	DataAddr	;	zH:zL <- tH:tL
		ld		dtL, z+
		ld		dtH, z+
		rjmp	CodeNext

ShortVar_:
		andi	tL, 0x0f
		clr		tH
		rcall	DataAddr	;	zH:zL <- tH:tL
		st		z+, dtL
		st		z+, dtH
		ld		dtH, -x
		ld		dtL, -x
		rjmp	CodeNext

ShortArray:
		andi	tL, 0x0f
		clr		tH
		rcall	DataAddr	;	zH:zL <- tH:tL
		lsl		dtL
		rol		dtH
		add		zL, dtL
		adc		zH, dtH
		ld		dtL, z+
		ld		dtH, z+
		rjmp	CodeNext

ShortArray_:
		andi	tL, 0x0f
		clr		tH
		rcall	DataAddr	;	zH:zL <- tH:tL
		lsl		dtL
		rol		dtH
		add		zL, dtL
		adc		zH, dtH
		ld		dtH, -x
		ld		dtL, -x
		st		z+, dtL
		st		z+, dtH
		ld		dtH, -x
		ld		dtL, -x
		rjmp	CodeNext

ShortLP:
ShortLP_:
		andi	tL, 0x1f
		ldi		tH, 0x10	; invert
		eor		tL, tH

		st		-y, cpH
		st		-y, cpL
		clr		tH
		add		cpL, tL
		adc		cpH, tH
		rjmp	CodeNext


SysNum:
		st		x+, dtL
		st		x+, dtH
		movw	zL, cpL
		clr		dtH
		lpm		dtL, z+
		movw	cpL, zL
		rjmp	CodeNext

SysNum2:
		st		x+, dtL
		st		x+, dtH
		movw	zL, cpL
		lpm		dtH, z+
		lpm		dtL, z+
		movw	cpL, zL
		rjmp	CodeNext

SysVar:
		st		x+, dtL
		st		x+, dtH
		movw	zL, cpL
		clr		tH
		lpm		tL, z+
		movw	cpL, zL
		rcall	DataAddr	;	zH:zL <- tH:tL
		ld		dtL, z+
		ld		dtH, z+
		rjmp	CodeNext

SysVar_:
		movw	zL, cpL
		clr		tH
		lpm		tL, z+
		movw	cpL, zL
		rcall	DataAddr	;	zH:zL <- tH:tL
		st		z+, dtL
		st		z+, dtH
		ld		dtH, -x
		ld		dtL, -x
		rjmp	CodeNext

SysArray:
		movw	zL, cpL
		clr		tH
		lpm		tL, z+
		movw	cpL, zL
		rcall	DataAddr	;	zH:zL <- tH:tL
		lsl		dtL
		rol		dtH
		add		zL, dtL
		adc		zH, dtH
		ld		dtL, z+
		ld		dtH, z+
		rjmp	CodeNext

SysArray_:
		movw	zL, cpL
		clr		tH
		lpm		tL, z+
		movw	cpL, zL
		rcall	DataAddr	;	zH:zL <- tH:tL
		lsl		dtL
		rol		dtH
		add		zL, dtL
		adc		zH, dtH
		ld		dtH, -x
		ld		dtL, -x
		st		z+, dtL
		st		z+, dtH
		ld		dtH, -x
		ld		dtL, -x
		rjmp	CodeNext

SysString:
		movw	zL, cpL
		clr		tH
		lpm		tL, z+
		movw	stL, zL
		add		zL, tL
		adc		zH, tH
		movw	cpL, zL
		rjmp	CodeNext

SysString_:
		movw	zL, stL
		add		zL, dtL
		adc		zH, dtH
		lpm		dtL, z+
		clr		dtH
		rjmp	CodeNext


SysLP:
		movw	zL, cpL
		clr		tH
		lpm		tL, z+
		st		-y, zH
		st		-y, zL
		add		zL, tL
		adc		zH, tH
		movw	cpL, zL
		rjmp	CodeNext

SysFor:
		ld		tH, -x
		ld		tL, -x
		adiw	xL, 2
		cp		tL, dtL
		cpc		tH, dtH
		brne	SysDo
		adiw	yL, 2
		rjmp	CodeNext
SysDo:
		cpi		cpL, 0
		brne	do_nc
		dec		cpH
do_nc:
		dec		cpL
		ld		tL, y
		ldd		tH, y+1
		st		-y, cpH
		st		-y, cpL
		movw	cpL, tL
		rjmp	CodeNext
SysDo_:
		ldd		cpL, y+2
		ldd		cpH, y+3
		rjmp	CodeNext

SysBreak:
		movw	tL, dtL
		ld		dtH, -x
		ld		dtL, -x
		or		tL, tH
		breq	brk_end
		ld		cpL, y+
		ld		cpH, y+
		adiw	yL, 2
		inc		cpL
		brne	brk_end
		inc		cpH
brk_end:
		rjmp	CodeNext

SysWhile:
		movw	tL, dtL
		ld		dtH, -x
		ld		dtL, -x
		or		tL, tH
		brne	whl_end
		ld		cpL, y+
		ld		cpH, y+
		adiw	yL, 2
		inc		cpL
		brne	whl_end
		inc		cpH
whl_end:
		rjmp	CodeNext

SysContinue:
		movw	tL, dtL
		ld		dtH, -x
		ld		dtL, -x
		or		tL, tH
		breq	whl_end
		ld		cpL, y+
		ld		cpH, y+
		rjmp	CodeNext

SysIf:
		movw	tL, dtL
		ld		dtH, -x
		ld		dtL, -x
		or		tL, tH
		brne	SysSwitch
		adiw	yL, 2
		rjmp	CodeNext
SysSwitch:
		ld		tL, y+
		ld		tH, y+
		st		-y, cpH
		st		-y, cpL
		movw	cpL, tL
		rjmp	CodeNext

SysElse:
		movw	tL, dtL
		ld		dtH, -x
		ld		dtL, -x
		or		tL, tH
		breq	else_false
		adiw	yL, 2
		ld		tL, y+
		ld		tH, y+
		rjmp	else_end
else_false:
		ld		tL, y+
		ld		tH, y+
		adiw	yL, 2
else_end:
		st		-y, cpH
		st		-y, cpL
		movw	cpL, tL
		rjmp	CodeNext

SysCase:
		movw	tL, dtL
		ld		dtH, -x
		ld		dtL, -x
		sub		tL, dtL
		sbc		tH, dtH
		brne	case_skip
		ld		cpL, y+
		ld		cpH, y+
		rjmp	CodeNext
case_skip:
		adiw	yL, 2
		rjmp	CodeNext

SysOf:
		ld		zL, y+
		ld		zH, y+
		add		zL, dtL
		adc		zH, dtH
		lpm		tL, z
		ld		dtH, -x
		ld		dtL, -x
		ori		cpH, 0x80
		st		-y, cpH
		st		-y, cpL
		rjmp	user_next


Sys2Drop:
		ld		dtH, -x
		ld		dtL, -x
SysDrop:
		ld		dtH, -x
		ld		dtL, -x
		rjmp	CodeNext

SysNip:
		ld		tH, -x
		ld		tL, -x
		rjmp	CodeNext

SysSwap:
		movw	tL, dtL
		ld		dtH, -x
		ld		dtL, -x
		st		x+, tL
		st		x+, tH
		rjmp	CodeNext

SysDup:
		st		x+, dtL
		st		x+, dtH
		rjmp	CodeNext

SysOver:
		ld		tH, -x
		ld		tL, -x
		adiw	xl, 2
		st		x+, dtL
		st		x+, dtH
		movw	dtL, tL
		rjmp	CodeNext

SysPick:
		lsl		dtL
		rol		dtH
		sub		xL, dtL
		sbc		xH, dtH
		ld		tH, -x
		ld		tL, -x
		adiw	xL, 2
		add		xL, dtL
		adc		xH, dtH
		movw	dtL, tL
		rjmp	CodeNext

SysPoke:
		ld		tH, -x
		ld		tL, -x
		lsl		dtL
		rol		dtH
		sub		xL, dtL
		sbc		xH, dtH
		st		x+, tL
		st		x+, tH
		sbiw	xL, 2
		add		xL, dtL
		adc		xH, dtH
		ld		dtH, -x
		ld		dtL, -x
		rjmp	CodeNext


SysEq:
		ld		tH, -x
		ld		tL, -x
		adiw	xL, 2
		cp		tL, dtL
		cpc		tH, dtH
		ser		dtL
		breq	eq_true
		clr		dtL
eq_true:
		mov		dtH, dtL
		rjmp	CodeNext

SysNeq:
		ld		tH, -x
		ld		tL, -x
		adiw	xL, 2
		cp		tL, dtL
		cpc		tH, dtH
		ser		dtL
		brne	neq_true
		clr		dtL
neq_true:
		mov		dtH, dtL
		rjmp	CodeNext

SysLt:
		ld		tH, -x
		ld		tL, -x
		adiw	xL, 2
		cp		tL, dtL
		cpc		tH, dtH
		ser		dtL
		brlo	lt_true
		clr		dtL
lt_true:
		mov		dtH, dtL
		rjmp	CodeNext

SysGt:
		movw	tL, dtL
		ld		dtH, -x
		ld		dtL, -x
		adiw	xL, 2
		cp		tL, dtL
		cpc		tH, dtH
		ser		dtL
		brcs	gt_true
		clr		dtL
gt_true:
		mov		dtH, dtL
		rjmp	CodeNext

SysLe:
		ld		tH, -x
		ld		tL, -x
		adiw	xL, 2
		cp		tL, dtL
		cpc		tH, dtH
		ser		dtL
		brcs	le_true
		breq	le_true
		clr		dtL
le_true:
		mov		dtH, dtL
		rjmp	CodeNext

SysGe:
		ld		tH, -x
		ld		tL, -x
		adiw	xL, 2
		ld		tH, -x
		ld		tL, -x
		adiw	xL, 2
		cp		tL, dtL
		cpc		tH, dtH
		ser		dtL
		brsh	ge_true
		clr		dtL
ge_true:
		mov		dtH, dtL
		rjmp	CodeNext



SysInc:
		adiw	dtH:dtL, 1
		rjmp	CodeNext

SysDec:
		sbiw	dtH:dtL, 1
		rjmp	CodeNext

SysAdd:
		ld		tH, -x
		ld		tL, -x
		add		dtL, tL
		adc		dtH, tH
		rjmp	CodeNext

SysSub:
		movw	tL, dtL
		ld		dtH, -x
		ld		dtL, -x
		sub		dtL, tL
		sbc		dtH, tH
		rjmp	CodeNext

SysMul:
		ld		tH, -x
		ld		tL, -x
		mul		tL, dtL
		movw	t2L, r0
		mul		tH, dtL
		add		t2H, r0
		mul		dtH, tL
		add		t2H, r0
		movw	dtL, t2L
		rjmp	CodeNext

SysDiv:
		rcall	divmod
		movw	dtL, tL
		rjmp	CodeNext

SysMod:
		rcall	divmod
		movw	dtL, r0
		rjmp	CodeNext

SysDivMod:
		rcall	divmod
		st		x+, tL
		st		x+, tH
		movw	dtL, r0
		rjmp	CodeNext

divmod:
		ld		tH, -x
		ld		tL, -x
div16u:
		clr		r0			;clear remainder Low byte
		sub		r1, r1		;clear remainder High byte and carry
		ldi		r20, 17		;init loop counter
d16u_1:
		rol		tL			;shift left dividend
		rol		tH
		dec		r20			;decrement counter
		brne	d16u_2		;if done
		ret					;    return
d16u_2:
		rol		r0			;shift dividend into remainder
		rol		r1
		sub		r0, dtL		;remainder = remainder - divisor
		sbc		r1, dtH		;
		brcc	d16u_3		;if result negative
		add		r0, dtL		;    restore remainder
		adc		r1, dtH
		clc					;    clear carry to be shifted into result
		rjmp	d16u_1		;else
d16u_3:
		sec					;    set carry to be shifted into result
		rjmp	d16u_1



SysLShift:					; 0-shift bug fixed		05/12/30
		ld		tH, -x
		ld		tL, -x
		cpi		dtH, 0
		brne	sft_zero
		cpi		dtL, 0
		breq	lsft_skip
lsft_loop:
		lsl		tL
		rol		tH
		dec		dtL
		brne	lsft_loop
lsft_skip:
		movw	dtL, tL	
		rjmp	CodeNext

SysRShift:
		ld		tH, -x
		ld		tL, -x
		cpi		dtH, 0
		brne	sft_zero
		cpi		dtL, 0
		breq	rsft_skip
rsft_loop:
		lsr		tH
		ror		tL
		dec		dtL
		brne	rsft_loop
rsft_skip:
		movw	dtL, tL	
		rjmp	CodeNext

sft_zero:
		clr		dtH
		clr		dtL
		rjmp	CodeNext

SysAnd:
		ld		tH, -x
		ld		tL, -x
		and		dtL, tL
		and		dtH, tH
		rjmp	CodeNext

SysOr:
SysLOr:
		ld		tH, -x
		ld		tL, -x
		or		dtL, tL
		or		dtH, tH
		rjmp	CodeNext

SysXor:
		ld		tH, -x
		ld		tL, -x
		eor		dtL, tL
		eor		dtH, tH
		rjmp	CodeNext

SysCmp:
		com		dtL
		com		dtH
		rjmp	CodeNext

SysLAnd:
		ld		tH, -x
		ld		tL, -x
		or		tL, tH
		or		dtL, dtH
		mul		tL, dtL
		movw	dtL, r0
		rjmp	CodeNext

SysNot:
		or		dtL, dtH
		ser		dtL
		breq	not_true
		clr		dtL
not_true:
		mov		dtH, dtL
		rjmp	CodeNext

SysMin:
		ld		tH, -x
		ld		tL, -x
		cp		tL, dtL
		cpc		tH, dtH
		brcc	min_end
		movw	dtL, tL
min_end:
		rjmp	CodeNext

SysMax:
		ld		tH, -x
		ld		tL, -x
		cp		dtL, tL
		cpc		dtH, tH
		brcc	max_end
		movw	dtL, tL
max_end:
		rjmp	CodeNext

SysRnd:
		st		x+, dtL
		st		x+, dtH
		lds		dtL, random
		lds		dtH, random+1
		mov		tH, dtH
		lsl		dtL
		rol		dtH
		eor		tH, dtH
		rol		dtH
		rol		dtH
		eor		tH, dtH
		bst		dtL, 4
		bld		tL, 7
		eor		tH, tL
		bst		tH, 7
		bld		dtL, 0
		sts		random, dtL
		sts		random+1, dtH
		rjmp	CodeNext


SysClock:
		st		x+, dtL
		st		x+, dtH
		lds		dtL, tm_clk
		lds		dtH, tm_clk+1
		rjmp	CodeNext

SysSec:
		st		x+, dtL
		st		x+, dtH
		lds		dtL, tm_sec
		lds		dtH, tm_sec+1
		rjmp	CodeNext



SysKey:
		st		x+, dtL
		st		x+, dtH
		rcall	_kbhit
		ser		dtL
		brne	key_true
		clr		dtL
key_true:
		mov		dtH, dtL
		rjmp	CodeNext

SysGetC:					; modified for interrupt	- 05/12/30
		rcall	_kbhit
		brne	getc_do
		subi	cpL, 1
		sbci	cpH, 0
		rjmp	CodeNext
getc_do:
		st		x+, dtL
		st		x+, dtH
		rcall	getchar
		rjmp	CodeNext

SysPutC:
		cpi		dtH, 0
		breq	putc_L
		push	dtL
		mov		dtL, dtH
		rcall	putchar
		pop		dtL
putc_L:
		rcall	putchar
		ld		dtH, -x
		ld		dtL, -x
		rjmp	CodeNext

SysPutS:
		movw	tL, dtL
		movw	zL, stL
puts_loop:
		lpm		dtL, z+
		cpi		dtL, 0
		breq	puts_end
		rcall	putchar
		rjmp	puts_loop
puts_end:
		movw	dtL, tL
		rjmp	CodeNext

SysPutN:
		set
		bld		status, _blank
		rcall	bin2bcd16
		movw	tL, r0
		mov		dtL, r2
		rcall	putnumL
		rjmp	puthex4

SysPutH:
		movw	tL, dtL
		set
		bld		status, _blank
puthex4:
		mov		dtL, tH
		rcall	putnumH
		mov		dtL, tH
		rcall	putnumL
		mov		dtL, tL
		rcall	putnumH
		clt
		bld		status, _blank
		mov		dtL, tL
		rcall	putnumL
		ld		dtH, -x
		ld		dtL, -x
		rjmp	CodeNext

putnumH:
		swap	dtL
putnumL:
		andi	dtL, 0x0f
		brne	putnum_do
		sbrc	status, _blank
		ret
putnum_do:
		cpi		dtL, 0x0a
		brcs	putnum_digit
		subi	dtL, 0x0a-'a'+'0'
putnum_digit:
		subi	dtL, -'0'
		rcall	putchar
		clt
		bld		status, _blank
		ret


SysSFR:
		movw	zL, dtL
		ld		dtL, z
		clr		dtH 
		rjmp	CodeNext

SysSFR_:
		movw	zL, dtL
		ld		dtH, -x
		ld		dtL, -x
		st		z, dtL
		ld		dtH, -x
		ld		dtL, -x
		rjmp	CodeNext


SysProgram:
		movw	zL, dtL
		lpm		dtL, z
		clr		dtH
		rjmp	CodeNext

SysProgram_:
		cpi		dtH, high(Compiler<<1)
		brcs	sysprog_do
		cpi		dtH, 0xff
		breq	sysprog_do	
		sbiw	xL, 2			; abort data
		rjmp	sysprog_end
sysprog_do:
		push	yH
		push	yL
		rcall	self_program
		pop		yL
		pop		yH
sysprog_end:
		ld		dtH, -x
		ld		dtL, -x
		rjmp	CodeNext


SysData:
		sbic	EECR, EEPE
		rjmp	SysData
		out		EEARH, dtH
		out		EEARL, dtL
		sbi		EECR, EERE
		in		dtL, EEDR
		clr		dtH
		rjmp	CodeNext

SysData_:
		sbic	EECR, EEPE
		rjmp	SysData_
		out		EEARH, dtH
		out		EEARL, dtL
		ld		dtH, -x
		ld		dtL, -x
		out		EEDR, dtL
		sbi		EECR, EEMPE
		sbi		EECR, EEPE
		ld		dtH, -x
		ld		dtL, -x
		rjmp	CodeNext


Sys_Exec:
		movw	zpL, dtL
		rjmp	Interpret


Sys_StrF:
		movw	r0, xL
		movw	zL, stL				; ptr = sysdic

		lsl		dtL					; key = &token[n]
		rol		dtH
		subi	dtL, low(-DS_TOP-2)
		sbci	dtH, high(-DS_TOP-2)
		movw	t2L, dtL
		clr		dtL					; cnt = 0
		rjmp	_strf_start
_strf_loop:
		movw	xL, t2L				; kptr = key
		rjmp	_strf_st1
_strf_lp1:
		adiw	xL, 2				; kptr++
		lpm		tL, z+				; ptr++
_strf_st1:
		ld		tH, x
		cp		tH, tL				; *kptr==*ptr?
		breq	_strf_lp1
		cpi		tL, ' '				; *ptr==' '?
		breq	_strf_lp3
_strf_lp2:
		lpm		tL, z+				; ptr++
		cpi		tL, ' '
		brne	_strf_lp2
		rjmp	_strf_next
_strf_lp3:
		cpi		tH, 0				; *kptr==0?
		breq	_strf_end
_strf_next:
		inc		dtL					; cnt++
_strf_start:
		lpm		tL, z+
		cpi		tL, 0				; *ptr?
		brne	_strf_loop
		ser		dtL
_strf_end:
		clr		dtH
		movw	xL, r0
		rjmp	CodeNext


Sys_RS:
		st		x+, dtL
		st		x+, dtH
		ldi		dtL, low(RAMEND+1)
		ldi		dtH, high(RAMEND+1)
		sub		dtL, xL
		sbc		dtH, xH
		rjmp	CodeNext

Sys_DS:
		st		x+, dtL
		st		x+, dtH
		movw	dtL, xL
		sub		dtL, bpL
		sbc		dtH, bpH
		lsr		dtH
		ror		dtL
		sbiw	dtL, 1
		rjmp	CodeNext



;-----------------------------------------------------------
	.org	THIRDBOOTSTART-1

		.dw		MainLoop
;-----------------------------------------------------------
.endif

	.org	THIRDBOOTSTART

		rjmp	Reset
		reti
		reti
		reti
		reti
		reti
		reti
		reti
		reti
		reti
		reti
		reti
		reti
		reti
		rjmp	TIM0_COMPA
		reti
		reti
		reti
		rjmp	USART_RXC
		rjmp	USART_UDRE
		reti
		reti
		reti

Reset:
		; initialize I/O
		clr		dtL
		out		DDRB, dtL
		out		DDRC, dtL
		out		DDRD, dtL

		ser		dtL
		out		PORTB, dtL
		out		PORTC, dtL
		out		PORTD, dtL

		; clear EEPROM last byte
		out		EEARH, dtL
		out		EEARL, dtL
		sbi		EECR, EERE
		in		dtL, EEDR
		andi	dtL, 0xfe
		out		EEDR, dtL
		sbi		EECR, EEMPE
		sbi		EECR, EEPE

		; clear ram
		ldi		zH, high(SRAM_START)
		ldi		zL, low(SRAM_START)
		ldi		xH, high(SRAM_SIZE)
		ldi		xL, low(SRAM_SIZE)
		clr		r0
ram_clear:
		st		z+, r0
		sbiw	xL, 1
		brne	ram_clear

		; set random seed
		ldi		dtL, 0x45
		ldi		dtH, 0x30
		sts		random, dtL
		sts		random+1, dtH


InitInterrupt:
		cli

		wdr
		lds		dtL, WDTCSR
		ori		dtL, (1<<WDCE)|(1<<WDE)
		sts		WDTCSR, dtL
		ldi		dtL, (1<<WDE)		; 16mS
		sts		WDTCSR, dtL

		ldi		dtL, (1<<IVCE)
		out		MCUCR, dtL
		ldi		dtL, (1<<IVSEL)
		out		MCUCR, dtL

		ldi		dtL, 249			; 2mS
		out		OCR0A, dtL
		ldi		dtL, 2
		out		TCCR0A, dtL
		ldi		dtL, 3				; 1/64
		out		TCCR0B, dtL
		lds		dtL, TIMSK0
		ori		dtL, (1<<OCIE0A)
		sts		TIMSK0, dtL

		ldi		dtL, 103			; 4800bps
		ldi		dtH, 0
		sts		UBRR0L, dtL
		sts		UBRR0H, dtH
		ldi		dtL, (1<<RXCIE0)|(1<<RXEN0)|(1<<TXEN0)
		sts		UCSR0B, dtL
		ldi		dtL, (3<<UCSZ00)
		sts		UCSR0C, dtL

		ldi		dtL, low(CLK_PER_SEC)
		ldi		dtH, high(CLK_PER_SEC)
		sts		tm_cnt, dtL
		sts		tm_cnt+1, dtH

		sei


		in		dtL, PINC
		andi	dtL, 0x30
		cpi		dtL, 0
		brne	main
		rjmp	boot_loader

main:
		ldi		zL, low((THIRDBOOTSTART-1)<<1)
		ldi		zH, high((THIRDBOOTSTART-1)<<1)
		lpm		tL, z+
		lpm		tH, z+
		movw	zL, tL
		ijmp


;-----------------------------------------------------------

TIM0_COMPA:
		push	r0
		in		r0, SREG
		push	dtH
		push	dtL
		lds		dtL, tm_clk
		lds		dtH, tm_clk+1
		adiw	dtL, 1
		sts		tm_clk, dtL
		sts		tm_clk+1, dtH
		set
		bld		status, _chgclk
		lds		dtL, tm_cnt
		lds		dtH, tm_cnt+1
		sbiw	dtL, 1
		brne	timer0_skip

		lds		dtL, tm_sec
		lds		dtH, tm_sec+1
		adiw	dtL, 1
		sts		tm_sec, dtL
		sts		tm_sec+1, dtH
		ldi		dtL, low(CLK_PER_SEC)
		ldi		dtH, high(CLK_PER_SEC)
		bld		status, _chgsec
timer0_skip:
		sts		tm_cnt, dtL
		sts		tm_cnt+1, dtH
		pop		dtL
		pop		dtH
		out		SREG, r0
		pop		r0
		reti


USART_RXC:
		push	r0
		in		r0, SREG
		push	tH
		push	tL
		push	zH
		push	zL
rcv_next:
		lds		tL, UCSR0A
		andi	tL, (1<<FE0)|(1<<DOR0)|(1<<UPE0)
		breq	rcv_ok
		lds		tH, UDR0		; error
		rjmp	rcv_end
rcv_ok:
		lds		tL, iwptr
		inc		tL
;		andi	tL, RX_MASK
		cpi		tL, RX_SIZE
		brne	rcv_skip
		clr		tL
rcv_skip:
		lds		tH, urptr
		cp		tL, tH


		breq	rcv_end

		ldi		zL, low(rv_buf)
		ldi		zH, high(rv_buf)
		lds		tH, iwptr
		add		zL, tH
		lds		tH, UDR0
		st		z, tH
		sts		iwptr, tL

		lds		tL, UCSR0A
		andi	tL, (1<<RXC0)
		brne	rcv_next
rcv_end:
		pop		zL
		pop		zH		
		pop		tL
		pop		tH		
		out		SREG, r0
		pop		r0
		reti


USART_UDRE:
		push	r0
		in		r0, SREG
		push	tH
		push	tL

		lds		tL, uwptr
		lds		tH, irptr
		cp		tL, tH
		brne	txmt_ok

		lds		tL, UCSR0B
		andi	tL, ~(1<<UDRIE0)
		sts		UCSR0B, tL
		rjmp	txmt_end
txmt_ok:
		push	zH
		push	zL

		ldi		zL, low(tx_buf)
		ldi		zH, high(tx_buf)
		add		zL, tH
		ld		tL, z
		sts		UDR0, tL

		inc		tH
		andi	tH, TX_MASK
		sts		irptr, tH

		pop		zL
		pop		zH		
txmt_end:
		pop		tL
		pop		tH		
		out		SREG, r0
		pop		r0
		reti


;-----------------------------------------------------------


_kbhit:
		lds		tL, urptr
		lds		tH, iwptr
		cp		tL, tH
		ret

getchar:
		wdr
		rcall	_kbhit
		breq	getchar

		ldi		zL, low(rv_buf)
		ldi		zH, high(rv_buf)
		add		zL, tL
		ld		dtL, z
		clr		dtH
		inc		tL
;		andi	tL, RX_MASK
		cpi		tL, RX_SIZE
		brne	getchar_skip
		clr		tL
getchar_skip:
		sts		urptr, tL
		ret

gethex:
		rcall	getchar
		subi	dtL, '0'
		cpi		dtL, 10
		brcs	gethex_end
		subi	dtL, 7
gethex_end:
		ret

getbyte:
		rcall	gethex
		swap	dtL
		mov		vpL, dtL
		rcall	gethex
		or		dtL, vpL
		clr		dtH
		ret



putchar:
		push	tH
		push	tL

putchar_wait:
		wdr

		lds		tL, uwptr
		inc		tL
		andi	tL, TX_MASK
		lds		tH, irptr
		cp		tL, tH
		breq	putchar_wait

		push	zH
		push	zL
		ldi		zL, low(tx_buf)
		ldi		zH, high(tx_buf)
		lds		tH, uwptr
		add		zL, tH
		st		z, dtL
		pop		zL
		pop		zH		

		cli
		lds		tH, UCSR0A
		andi	tH, (1<<UDRE0)
		brne	putchar_now
		sts		uwptr, tL
		rjmp	putchar_end
putchar_now:
		sts		UDR0, dtL
		lds		tL, UCSR0B
		ori		tL, (1<<UDRIE0)
		sts		UCSR0B, tL
putchar_end:
		sei
		pop		tL
		pop		tH		
		ret

;-----------------------------------------------------------


boot_loader:
		; init buffer page
		ser		dtL
		sts		pg_cur, dtL

		ldi		dtL, '='
		rcall	putchar

boot_line:
		rcall	getchar
		cpi		dtL, ':'
		brne	boot_line
			
		rcall	getbyte			; record length = cpH
		mov		cpH, dtL
		rcall	getbyte			; offset H	= zpH
		mov		zpH, dtL
		rcall	getbyte			; offset L	= zpL
		mov		zpL, dtL
		rcall	getbyte			; record type	= cpL
		mov		cpL, dtL

boot_data:
		cpi		cpH, 0
		breq	boot_end

		rcall	getbyte			; data

		cpi		cpL, 0
		brne	boot_skip

		ldi		xL, low(DS_TOP+4)
		ldi		xH, high(DS_TOP+4)
		st		x+, dtL
		st		x+, dtH
		movw	dtL, zpL
		rcall	self_program

boot_skip:
		dec		cpH
		inc		zpL
		brne	boot_data
		inc		zpH
		rjmp	boot_data

boot_end:
		rcall	getbyte			; checksum (ignore)
		ldi		dtL, 'o'
		rcall	putchar

		cpi		cpL, 1			; type==1 ?
		brne	boot_line

;		flush buffer page
		ser		dtL
		rcall	self_program

		ldi		dtL, '/'
		rcall	putchar

boot_halt:
;		wdr
		rjmp	boot_halt

;-----------------------------------------------------------


self_program:
		movw	t2L, dtL
		lsl		t2L
		rol		t2H
		lsl		t2L
		rol		t2H				; t2H = NewPage
		lds		t2L, pg_cur
		cp		t2H, t2L		; NewPage==CurPage?
		breq	do_write
		cpi		t2L, 0x80		; CurPage in use?
		brcc	do_update
		; flush current page buffer
		clr		yL
		ldi		yH, high(pg_buf)
		mov		zH, t2L
		clr		zL
		lsr		zH
		ror		zL
		lsr		zH
		ror		zL
		; erase page
		ldi		tH, (1<<PGERS) | (1<<SELFPRGEN)
		rcall	do_spm
		; erase temporary buffer
		ldi		tH, (1<<RWWSRE) | (1<<SELFPRGEN)
		rcall	do_spm
		; transfer page buffer to temporary buffer
		movw	t3L, zL
		ldi		tH, (1<<SELFPRGEN)
		ldi		t2L, PAGESIZE
do_flush:
		ld		r0, y+
		ld		r1, y+
		rcall	do_spm
		adiw	zL, 2
		dec		t2L
		brne	do_flush
		movw	zL, t3L
		; write page
		ldi		tH, (1<<PGWRT) | (1<<SELFPRGEN)
		rcall	do_spm
		; re-enable rww section
		ldi		tH, (1<<RWWSRE) | (1<<SELFPRGEN)
		rcall	do_spm
		; verify rww is safe
do_busy:
		in		t2L, SPMCSR
		sbrs	t2L, RWWSB
		rjmp	do_update
		ldi		tH, (1<<RWWSRE) | (1<<SELFPRGEN)
		rcall	do_spm
		rjmp	do_busy
do_update:
		sts		pg_cur, t2H
;		cpi		t2H, high(Compiler<<3)		; NewPage is valid?
		cpi		t2H, high(THIRDBOOTSTART<<3)	; NewPage is valid?
		brcs	do_restore
		sbiw	xL, 2			; abort data
		ret
do_restore:
		movw	zL, dtL
		andi	zL, 0xc0
		clr		yL
		ldi		yH, high(pg_buf)
		ldi		t2L, (PAGESIZE<<1)
do_read:						; resotre current page to buffer
		lpm		r0, z+
		st		y+, r0
		dec		t2L
		brne	do_read

do_write:
		mov		zL, dtL
		andi	zL, 0x3f
		ldi		zH, high(pg_buf)
		ld		dtH, -x
		ld		dtL, -x
		st		z, dtL
		ret

do_spm:
		in		tL, SPMCSR
		sbrc	tL, SELFPRGEN
		rjmp	do_spm
		cli
do_wait:
		sbic	EECR, EEPE
		rjmp	do_wait
		out		SPMCSR, tH
		spm
		sei
		ret


;-----------------------------------------------------------


.equ	AtBCD0	=0		;address of tBCD0
.equ	AtBCD2	=2		;address of tBCD1

.def	tBCD0	=r0		;BCD value digits 1 and 0
.def	tBCD1	=r1		;BCD value digits 3 and 2
.def	tBCD2	=r2		;BCD value digit 4


bin2bcd16:
		ldi		tL, 16		;Init loop counter	
		clr		tBCD2		;clear result (3 bytes)
		clr		tBCD1		
		clr		tBCD0		
		clr		zH	
bBCDx_1:
		lsl		dtL			;shift input value
		rol		dtH			;through all bytes
		rol		tBCD0
		rol		tBCD1
		rol		tBCD2
		dec		tL			;decrement loop counter
		brne	bBCDx_2		;if counter not zero
		ret

bBCDx_2:
		ldi		zL, AtBCD2+1	;Z points to result MSB + 1
bBCDx_3:
		ld		tH, -z		;get (Z) with pre-decrement
		subi	tH, -0x03	;add 0x03
		sbrc	tH, 3		;if bit 3 not clear
		st		z, tH		;	store back
		ld		tH, z		;get (Z)
		subi	tH, -0x30	;add 0x30
		sbrc	tH, 7		;if bit 7 not clear
		st		z, tH		;	store back
		cpi		zL, AtBCD0	;done all three?
		brne	bBCDx_3		;loop again if not
		rjmp	bBCDx_1		

