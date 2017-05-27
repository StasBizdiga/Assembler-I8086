.MODEL SMALL
.STACK 100h 
.DATA                

;VARIABLE DECLARING
z   DB  29h
x   DB  25h
y   DB  ?

.CODE              
start:  
MOV AX,@DATA
MOV DS,AX
                
; variant 2:  Y = (Z-X)/2 + 56 if X <= 2Z
;             Y = 4X-Z         if X >  2Z 
; ---------------------------------------

xor ax,ax
mov al,z
shl al,1 ; al = 2Z       

CMP al, x
   JA ifLess     
   
;if X > 2Z
;----------- 
    mov al,x    
    shl al,2
    sub al,z
    mov y,al

   JMP skip 
   
ifLess: 
;if X <= 2Z  
;-----------
    shr al,1
    sub al,x 
    shr al,1
    add al,56
    mov y,al
   
skip:
   

;ENDING                          
MOV AX, 4C00H
INT 21H
END start                              
        
        