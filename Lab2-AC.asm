.MODEL SMALL
.STACK 100h 
.DATA                

;VARIABLE DECLARING
a   DW  291h
b   DW  132h
x   DW  5 dup(?)

.CODE              
start:  
MOV AX,@DATA
MOV DS,AX
                
; variant 2:  Xi = Xi-1  + a + 3b + 12 
; ------------------------------------

; const = a + 3b +12
mov ax,b
shl ax,2 ; b*2*2=4b
sub ax,b ; 4b-b=3b
add ax,a ; a+3b
add ax,12; a+3b+12 DONE!
mov bx,ax; storing the constant

mov cx,5
xor ax,ax    ;clearing ax for first iteration
L1:   
add x[si],ax ;adding Xi-1(skip on first iter)
add x[si],bx ;adding the constant       
push x[si]
                      
xor ax,ax   
mov ax,x[si] ;storing Xi-1 in ax        
add si,2
loop L1        


;ENDING                          
MOV AX, 4C00H
INT 21H
END start                              
        
        