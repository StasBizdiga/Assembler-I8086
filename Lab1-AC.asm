.MODEL SMALL
.STACK 100h 
.DATA                

;VARIABLE DECLARING
X   DB  19H, 42H
Y   DW  2042H, 2142H
Z   DD  88888888H

.CODE              
start:  
MOV AX,@DATA
MOV DS,AX
         
        ;DIRECT ADDRESSING MODE                                        
        MOV BL,X
        MOV BH,[X+1]
        
        MOV CX,Y
        MOV DX,[Y+2]
        
        MOV SI,Z
        MOV DI,[Z+2]               
        
        ;ALTERNATIVES TO RESET TO 0 
        XOR BX,BX
        AND CX,0
        MOV DX,0   
        
        MOV SI,0
        MOV DI,0
        
        ;PUSH DATA ON STACK (WORKS ONLY WITH 4BIT)
        PUSH BX  ;2+2 BIT -> 4 (BL+BH=BX) 
        PUSH CX  
        PUSH DX
        PUSH SI  ;8BIT -> 4+4
        PUSH DI 
        
              
        MOV SI,4  
        XOR CX,CX   ;CLEANUP
        
        ;INDIRECT ADDRESSING MODE 
        MOV CX,[SI] ;accesses to the memory 
        ;location whose address appears in SI. 
        
        XOR CX,CX
        ;BASE plus INDEX - ADDRESSING MODE 
        MOV CX,[SI+BX] 
              
              
        ;CHANGING ADDRESS
        
        XOR AX,AX   
        MOV AX,0A234H 
        
        MOV DS,AX   ;HERE 
        
        MOV Y,CX
         
        
        ;GET DATA FROM STACK
        POP DI
        POP SI
        POP DX
        POP CX
        POP BX   
        


;ENDING                          
MOV AX, 4C00H
INT 21H
END start                              
        
        