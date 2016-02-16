; vim: ft=dasm
; stack.asm    --   Stack operation function written in 6502-assembler
;
; Copyright (C) 2016 Marcel Dümmel <marcel.duemmel@aquasign.net>
; All rights reserved.
;
; This program is licensed unter the terms of the BSD license as following:
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
;
;   o Redistributions of source code must retain the above copyright notice,
;     this list of conditions and the following disclaimer.
;
;   o Redistributions in binary form must reproduce the above copyright notice,
;     this list of conditions and the following disclaimer in the documentation
;     and/or other materials provided with the distribution.
;
;   o Neither the name of my organizations nor the names of its contributors
;     may be used to endorse or promote products derived from this software
;     without specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
; POSSIBILITY OF SUCH DAMAGE.
;
;
;
; The purpose of this code is the implementation of basic stack manipulation
; functions in 6502-assembler, as a basis for a HP-like rpn-calculator project.
; 
; As with most retro computing projects, this calculator will hardly newer 
; exist, but I'll start nevertheless and hopefully will have much fun with
; it :-)
;
; My target-platform is the py65-environment, a featureful 6502-emulator, ;
; written in python. But my goal is to capsule every platform-dependent
; functionality in replaceable code. So it will be easy to port the programm to
; other 6502-platforms.  
;
; In the following descriptions '_X' referse to the topmost element of the 
; stack, following the HP-Calculator-terminology. Don't confuse it with the
; 6502-x-register.
;
; Memory-Layout:
; --------------
;
;  Load-Address:            $2000
;  8-bit-integer-stack:     $1000 - $10ff
;  Future stacks:           $1100 - $1fff
;  Stackpointer (_X):       $ce/cf
;
;
; ACME-Assembler

	!cpu  6502

	int8_stack = $1000
	int8_X     = $ce
	tmp0       = $cc
	tmp1       = $cd
      	         * = $2000



	jmp MAIN
	!source "aqlib.asm"

MAIN
	jsr int8_init 


	;Beispieldaten
	lda #$42
	jsr int8_push
	lda #$19
	jsr int8_push
	lda #$99
	jsr int8_push



	rts




; ------------------------------------------------
; --
; -- int8_init
; -- 
int8_init
	; clean the stack memory
	lda #<int8_stack
	sta AQ_START_OF_RANGE
	lda #>int8_stack
	sta AQ_START_OF_RANGE + 1
	lda #$00
	ldy #$FF
	jsr AQfill

	; set the initial value for _X
	lda #$00 
	sta int8_X
	rts



; ------------------------------------------------
; --
; -- int8_push 
; -- 
; Push a 8bit-value on the stack. The value must be in the A-register.
int8_push
	stx tmp0
		
	ldx #$ff
	cpx int8_X
	beq err_stackoverflow
	inc int8_X	       ; increment _x
	ldx int8_X             ; and get _x into x ...
	sta int8_stack,X       ; so that we can store the value on top 
                               ; of the stack	
	ldx tmp0

	rts





; ------------------------------------------------
; --
; -- int8_pull
; -- 
int8_pull
	stx tmp0
	
	ldx #$00                   ; _X muss min.
	cpx int8_X                 ; 1 sein.
	bcs err_stackunderflow     ; A < int8_X ?

	ldx int8_X
	lda int8_stack,X
	pha

	lda #$00		
	sta int8_stack,X
	dec int8_X

	pla
	ldx tmp0
	

	rts



; ------------------------------------------------
; --
; -- int8_swap
; --
int8_swap
	pha
	txa 
	pha
	tya
	pha	

	ldx #$01                   ; _X muss min.
	cpx int8_X                 ; 2 sein.
	bcs err_stackunderflow     ; A < int8_X ?
	jsr int8_pull
	tax
	jsr int8_pull
	tay
	txa
	jsr int8_push
	tya
	jsr int8_push

	pla
	tay
	pla
	tax
	pla

	rts	




; ------------------------------------------------
; --
; -- int8_drop
; --
int8_drop
	pha
	jsr int8_pull
	pla

	rts	






; ------------------------------------------------
; --
; -- ERROR-HANDLING 
; -- 
; ------------------------------------------------
!warn "error-handling not implemented yet!"
; -- 
; -- stackoverflow
err_stackoverflow
	rts


err_stackunderflow
	rts



