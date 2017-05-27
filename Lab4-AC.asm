.MODEL SMALL
.DATA                

;VARIABLE DECLARING
randomString  db 'kbtoberidts$' ; random chars 
targetString db 'bizdigastas$'  ; student name
success  db  10,13,'Success! Word found!$'
error   db  10,13,'Impossible to write the name!',10,13,'Missing characters: $'


.CODE              
start:  
MOV AX,@DATA
MOV DS,AX   

lea di, targetString ; move EA of targetString in di
lea si, randomString ; move EA of randomString in si
mov bp,0   ; missing characters counter
mov ah,02  ; set cursor position
mov dh,1   ; row
mov dl,2   ; column
int 10h

L1:         cmp [di],'$'  ; check if the end is not reached for targetString
            je the_end      
            
L2:         cmp [si],'$'  ; check if the end is not reached for randomString
            je not_found    
            
            mov bl,[di]   ; mov in bl the current character from targetString
            cmp bl,[si]   ; compare with the current character from randomString
            jne jump      ; prepare for printing if the characters coincide
            mov al,[di]
            
            mov ah,09h
            xor bx,bx
            mov bl,01h     
            mov cx,1         
            int 10h       ; print the character from al                           
            ;diagonal outpupt [addon]
            mov ah, 2h    ; character output subprogram   
            mov dl,10     ; cursor down
            int 21h       ; call ms-dos output character
            mov dl,32    ; cursor right
            int 21h     ; call ms-dos output character 
             
            
            jmp continue  
            
jump:       inc si        ; go to the next character of message
            jmp L2         
            
not_found:  mov al, '*'
            
           
            mov ah,09h
            xor bx,bx
            mov bl,01h    ;blue    
            mov cx,1
              
            int 10h
            mov ah, 2h    ; character output subprogram   
            mov dl,10    ; cursor down
            int 21h     ; call ms-dos output character
            mov dl,32   ; cursor right
            int 21h     ; call ms-dos output character 
            
            push [di]  ; remember in stack the character that was not found
            inc bp     ; increase the number of missing characters  
            
continue:   inc di     ; go to the next character of targetString 
            xor si,si  ; reset si to go through the randomString from beginning
            jmp L1     ; repeat the search

the_end:    cmp bp,0   ; check the number of not found characters
            je ending  ; if all characters were found go to the success message 
            
            mov dx,offset error  ; if not, print the corresponding message
            mov ah,09
            int 21h
            mov cx,0   ; clear cx
            
            mov cx,bp  ; prepare the count to pop all missing characters from stack 
            
loop1:      pop dx     ; print dl which has each necessary character
            mov ah,06
            int 21h
            loop loop1
            jmp finish ; end the program when finish 
            
ending:     mov dx, offset success
            mov ah,09
            int 21h   
            
finish:     nop           

;ENDING                          
MOV AX, 4C00H
INT 21H
END start 
   