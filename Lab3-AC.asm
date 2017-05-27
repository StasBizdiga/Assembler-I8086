.MODEL SMALL
.STACK 100h 
.DATA                

;VARIABLE DECLARING
;x   DW  21,22,20,34,25,16,27,31,18,17 ; sum =  231
x dw     15h,16h,14h,22h,19h,10h,1Bh,1Fh,12h,10h ; sum =  E7h

.CODE    

PROC SortAscending 
    
MOV CH,0AH
U2: MOV CL,12H
LEA SI,x
 
U1: MOV AL,[SI]
MOV BL,[SI+2]
CMP AL,BL
JC D1           ; jmp if CF=1
MOV DL,[SI+2]
XCHG [SI],DL
MOV [SI+2],DL
 
D1: INC SI
DEC CL
JNZ U1          ; jmp if ZF=0
DEC CH
JNZ U2          ; jmp if ZF=0
ret
ENDP SortAscending     
;---------------------           
PROC SortDescending 
            
MOV CH,0AH
UP2: MOV CL,12H
LEA SI,x
 
UP1:MOV AL,[SI]
MOV BL,[SI+2]
CMP AL,BL
JNC DOWN        ; jmp if CF=0
MOV DL,[SI+2]
XCHG [SI],DL
MOV [SI+2],DL
 
DOWN: INC SI
DEC CL
JNZ UP1         ; jmp if ZF=0
DEC CH
JNZ UP2         ; jmp if ZF=0
ret
ENDP SortDescending         
;---------------------
          
start:  
MOV AX,@DATA
MOV DS,AX  

; 1.Calculate Sum of elements of array x              
; 2.Use procedures according to condition:
; variant 2 |-  if Sum is even -> arrange in decreasing order 
; ----------|
;           |-  if Sum is odd -> arrange in increasing order

mov cx,10
xor ax,ax    ;clearing ax, for storing the Sum in it

L1:   
add ax,x[si]                          
push ax   
add si,2
loop L1   
         
mov bl, 2
div bl        ; divide ax by 2     
    
cmp ah, 1     ; if remainder is 1
je odd        ; it's odd

jmp even      ; else it's even
         
even:    
call SortDescending
jmp skip            
       
odd:         
call SortAscending
 
skip:                    

;ENDING                          
MOV AX, 4C00H
INT 21H
END start          