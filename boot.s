/*
    Copyright (C) Fabrizio Perria <fabrizio.perria@gmail.com> 
                                  <fabrizio.perria@hotmail.it>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

.code16					#create 16bit binaries

.section .bss
    stack_bottom:
    .skip 2048
    stack_top:

.section .text
.globl _start				#_start is global so can be seen by the linker as an entry point
##########################################################################################
_start: 
    cli					#disable interrupts
    movw $stack_top,%ax  		#and set the stack
    movw %ax,%ss
    sti					#then enable the interrupts again
    jmp main
###########################################################################################
#   FUNCTIONS
###########################################################################################
    print: 				#print a message given its address and its size
	addw $2,%sp
	popw %si			#si <-- address(string)
        popw %cx                	#cx <-- length of the string (used for the print)
        subw $6,%sp
        movb $0xe,%ah			#ah <-- 0xe command (see int 10h for details)
        
        printLoop:
            lodsb			#al <-- string[si+1]
            int $0x10			#call bios interrupt to print a text on the screen
            loop printLoop		#until cx == 0
        ret
###########################################################################################
    drawPixel:				#draw a pixel on the screen
        pushw %ax			#save endX value for next comparisons on drawLine function
        pushw %bx			#save endY value for next comparisons on drawLine function
        movw (color),%ax         	#set color and 10h function(ah/al)
        movw $0,%bx
        int $0x10
        popw %bx			#restore endY value before returning
        popw %ax			#restore endX value before returning
        ret
###########################################################################################
    drawLine:                   	#draw an horizontal or vertical line on the screen
        addw $2,%sp			#save return address
        popw %bx			#endY
        popw %dx			#startY
        popw %ax			#endX 
        popw %cx			#startX
        subw $10,%sp			#restore stack pointer position to the return address
				
        cmp %bx,%dx
        je Horizontal
        cmp %ax,%cx
        je Vertical
        
        jmp drawLineDone

        Vertical:			#draw Vertical line
            call drawPixel
            inc %dx
            cmp %bx,%dx
            jg drawLineDone
            jmp Vertical
            
        Horizontal:			#draw Horizontal line
            call drawPixel
            inc %cx
            cmp %ax,%cx
            jg drawLineDone
            jmp Horizontal

        drawLineDone:
            ret
###############################################################################################
    drawRect:				#draw a Rectangle on the screen (line by line)
        pushw (aX)			#start X
        pushw (bX)              	#end X
        pushw (aY)			#start Y
        pushw (aY)              	#end Y
        call drawLine
        addw $8,%sp			#fix the stack pointer to avoid stack overflow
        pushw (bX)
        pushw (bX) 
        pushw (aY)
        pushw (bY)
        call drawLine
        addw $8,%sp
        pushw (aX)
        pushw (aX)                
        pushw (aY)
        pushw (bY)
        call drawLine
        addw $8,%sp
        pushw (aX)
        pushw (bX)
        pushw (bY)
        pushw (bY)  
        call drawLine
        addw $8,%sp
        ret

main:
    pushw $helloSize
    pushw $hello
    call print
    addw $6,%sp    			#fix stack pointer to avoid stack overlow

#########################################################################################################################    
getMemory:
    int $0x12				#ax <-- memory size(seen in real mode)
    movw $memory+10 + 4,%di		#di points on the location for the first digit of the string "memory"
    movw $10,%bx			#to transform on string we need to divide the ax content by 10 so we use bx to store 10
    
toStringMemory:
    movw $0,%dx                 	#as we do a word division we need to clean up dx which will keep the remainder
    div %bx
    addb $0x30,%dl			#remainder value to ascii number
    movb %dl,(%di)              	#move the ascii number in the string
    dec %di                     	#decrease the index 
    cmp $0,%ax                  	#if result != 0
    jne toStringMemory          	#    continue the loop
    
    pushw $memStrSize
    pushw $memory
    call print
    addw $6,%sp
###########################################################################################################################
    pushw $pressBtnSize
    pushw $pressBtn
    call print
    addw $6,%sp
    
    movb $0,%ah
    int $0x16
###########################################################################################################################
    movb $0,%ah					#change video mode
    movb $0xd,%al				#to EGA 320 x 200 16 colors
    int $0x10
    
    movb $0xc,%ah				#pixel write function (the color variable will store this value too only for simplicity 
    movb $0xc,%al				#starting color (light red)
    movw %ax,(color)    
    loopRect:
        movw $10,(aX)
        movw $10,(aY)
        movw $310,(bX)
        movw $190,(bY)
            
        call drawRect				#draw red rectangle (depending on the loop can be dark or light)
        addw $20,(aX)
        addw $20,(aY) 
        subw $20,(bX)
        subw $20,(bY)
        subw $1,(color)				#change the color to cyan(see BIOS color attributes for details)
        call drawRect				#draw cyan rectangle (depending on the loop can be dark or light)
        addw $20,(aX)         
        addw $20,(aY)
        subw $20,(bX)
        subw $20,(bY)
        subw $1,(color)				#change the color to green(see BIOS color attributes for details)
        call drawRect				#draw green rectangle (depending on the loop can be dark or light)
        addw $20,(aX)
        addw $20,(aY)
        subw $20,(bX)
        subw $20,(bY)
        subw $1,(color)				#change the color to blue(see BIOS color attributes for details)
        call drawRect				#draw blue rectangle (depending on the loop can be dark or light)

        movb $0x86,%ah				#bios wait function
        movw $0x3,%cx				#200 ms of wait == 0x30d40 to load as cx:dx
        movw $0x0d40,%dx
        int $0x15

        cmpw $0xc01,(color)			#if the colors used were not dark
        jne toDark				#    switch to dark colors
        movw $0xc0c,(color)			#else switch to light colors
        jmp loopRect
    toDark:
        movw $0xc04,(color)
        jmp loopRect
	
    
hello:           
    .asciz "Hello Guys!"
    .set helloSize, .-hello

buffer:         
    .asciz "\r\nMSW=xxxxxxxxxxxxxxxx"
    .set mswSize, .-buffer

memory:           
    .asciz "\r\nMemory:       KB"
    .set memStrSize, .-memory

pressBtn:             
    .asciz "\r\nPress a button to start"
    .set pressBtnSize, .-pressBtn
    
aX:
    .hword 0
bX:
    .hword 0
aY:
    .hword 0
bY:
    .hword 0
color:  
    .hword 0

    .org 510			#at byte 510 write the boot signature 0x55aa
    .byte 0x55
    .byte 0xaa
