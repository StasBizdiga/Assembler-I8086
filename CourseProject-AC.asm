.MODEL SMALL 
.DATA   
  
sign db 0     ;sign of resulting mantissa
    
mod_mx dw ?   ;abs( Mx )
mod_my dw ?   ;abs( My )
mx dw ?    
my dw ?
mz1 dw ?  
mz2 dw ?
mz dw ?,?  

ex db ?             
ey db ?
ez db ?

show_mx db "mx = $"
show_my db 0Ah, 0Dh, "my = $"
show_ex db 0Ah, 0Dh, "ex = $"
show_ey db 0Ah, 0Dh, "ey = $"

output_mz db 0Ah, 0Ah, 0Dh, "mz = $"
output_ez db 0Ah, 0Dh, "ez = $"              
;------------------------------------------   
.CODE              ;INITIALIZE DATA SEGMENT
start:              

 mov ax,@data
 mov ds,ax     

;------------------------------------------
                            ;UTILITY MACROS    
;==========================================  
                                                         
mod MACRO operand                   ;macro for calc. abs(mantissa)
    local negate, exit_mod          ;local labels for avoiding ambiguity
        
    test operand, 8000h             ;check if the first bit of 16bit mantissa is 1
    jnz negate                      ;if 1, negate the mantissa and get the 2's complement
    jmp exit_mod
        
    negate:
        neg operand              
        
    exit_mod:
        nop
            
mod ENDM 

;------------------------------------------ 
mov dx, offset show_mx    ;DISPLAY MESSAGES
    mov ah, 09            ;AND INPUT CHAR'S
    int 21h 
                                          
    input_macro 16          ;input Mx
    mov mx, bx 
    
    mov dx, offset show_my 
    mov ah, 09
    int 21h
    
    input_macro 16          ;input My
    mov my, bx
    
    mov dx, offset show_ex
    mov ah, 09
    int 21h 
    
    input_macro 8           ;input Ex
    mov ex, bl
    
    mov dx, offset show_ey
    mov ah, 09
    int 21h
    
    input_macro 8           ;input Ey
    mov ey, bl
    
;    mov mx,1000000000000001b        ;used for debugging
;    mov my,0000000000000010b
;    mov ex,00000000b                
;    mov ey,00000000b

              
    xor ax, ax 
    xor bx, bx 
;------------------------------------------ 
    CALL calc_sign            ;STEP 1: Calculate sign   
    
;------------------------------------------ 
    xor ax, ax                ;STEP 2: Compute exponent (Ez)   
    mov ah, ex
    add ah, ey
    mov ez, ah 
;------------------------------------------ 
                              ;STEP 3: Determine mantissas absolute values   
    xor ax,ax
    xor bx,bx   
    mov ax,mx
    mov bx,my  
    
    mod ax
    mov mod_mx,ax
    xor ax,ax
    
    mod bx
    mov mod_my,bx
    xor bx,bx 
    
;------------------------------------------ 
                              ;STEP 4: Multiply modulo mantissas                          
    CALL add_mantissa
;------------------------------------------
                              ;STEP 5: Normalization (we normalise the modulo then we put the sign) 
    call normalization 
      
;------------------------------------------  
                      
 xor dx,dx                         ;OUTPUTS   
 
    mov dx, offset output_mz
    mov ah, 09
    int 21h
    
    call output_mantissa_32
    
    
    mov dx, offset output_ez
    mov ah, 09
    int 21h  
    
    xor bx,bx
    mov bl, ez
    call output_exponent
    
    
    jmp ENDING                             
 
;------------------------------------------                                                 
;IN/OUT-PUT MACROS & OTHER UTILITY PROC
;------------------------------------------ 

input_macro MACRO size                     ;macro for user input
    local input
    xor ax, ax                             ;clear the registers
    xor bx, bx
    xor cx, cx
    mov cx, size
    mov ah, 01h                            ;loop N times, as we input N bit registers
    input:
        int 21h                            ;input the character
        sub al, 30h                        ;al keeps the ascii code of char: 30 = 0, 31 = 1
        add bl, al                         ;subtracting 30 to obtain either 0 or 1
        shl bx, 1                          ;add that  bit to the result
        loop input                         ;shift the result left
    rcr bx,1
input_macro ENDM
;------------------------------------------

             
output_mantissa_32 proc
    mov ah, 02h
    mov bx, mz[2]
    mov cx, mz
    mov si, 32
    clc
outputLoop:
    test bx, 8000h
    jnz out1
    mov dl, 30h
    jmp outFinal    
out1:
    mov dl, 31h
outFinal:
    int 21h
    shl cx, 1
    rcl bx, 1
    dec si
    cmp si, 0
    jnz outputLoop 
    ret
output_mantissa_32 endp    
;------------------------------------------     


output_exponent proc
    mov cx, 8

    output_loop:
        shl bl, 1
        jc output_one
        mov dl, 30h
        jmp printing
        
        output_one:
            mov dl, 31h
            
        printing:
        mov ah, 2
        int 21h 
        loop output_loop
    ret
output_exponent endp  

calc_sign PROC                      ;procedure for checking the sign of mantissa
    xor ax, ax                             
    mov ax, mx                             
    xor ax, my                             
    test ax, 8000h            
    jnz sign_neg                    ;if 1,the resulting mantissa is negative
    jmp sign_exit
    
    sign_neg:
        mov sign, 1                 ;store the sign in a var
               
    sign_exit:
    RET 
calc_sign ENDP      
;------------------------------------------
                                
normalization PROC                         ;procedure for normalizing the mantissa
    mov cx, 32                             ;this will be used for the case when we have mantissa 0 to avoid infinite loop
    mov ax, mz1
    mov bx, mz2
    mov dl, ez
    clc
normLoop:    
    test ax, 8000h    
    jnz foundOne
    shl bx, 1
    rcl ax, 1
    sub dl, 1
    loop normLoop

foundOne:
    shr ax, 1                              ;we shift 1 bit to the right to put the sign
    rcr bx, 1
    mov cl, sign
    cmp cl, 1
    jne normFinish
    not ax
    not bx
    clc
    add bx, 1
    adc ax, 0

normFinish:   
    mov mz, bx
    mov mz[2], ax
    add dl, 1                              
    mov ez, dl        
    ret
normalization ENDP
;==========================================


add_mantissa PROC 
    xor ax, ax                        
    xor bx, bx
    xor cx, cx   
    
    mov ax, mod_mx
    mov bx, mod_my 
    xor dx, dx     
    mov si, 16
    
addLoop:
    clc    
    test bx, 1
    jz dontAdd
    add cx, ax
    adc dx, 0   
        
dontAdd:
    shr cx, 1
    rcr dx, 1
    shr bx, 1 
    dec si
    cmp si, 0
    jne addLoop
    
    mov mz1, cx
    mov mz2, dx    
    ret      
add_mantissa ENDP                    
;------------------------------------------
                 ;PRESS ANY KEY TO CONTINUE
ENDING:
mov  ah,7
int  21h 
                                   
MOV AX, 4C00H
INT 21H
END start  


 