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
        
    test operand, 1000000000000000b ;check if the first bit of 16bit mantissa is 1
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
    
;    mov mx,0000000000000011b        ;used for debugging
;    mov my,0000000000001010b
;              
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
                              ;STEP 5: Normalization 
    cmp sign, 1                                      ;if sign 1, mantissa is negative
    je inv_mantissa                                  ;thus jump to neg it back
    jmp do_normalization_now                         ;else: skip this step
    
    inv_mantissa:
    
    neg [mz2]              ;Not sure it works right YET  =====================================
    jnc skip_adding
    not [mz1] 
    jmp skeep:
    skip_adding:
    neg [mz1]
    skeep:
    
    do_normalization_now:
;    CALL normalization     ;not implemented   YET      ======================================
   
;------------------------------------------  
                      
 xor dx,dx                         ;OUTPUTS   
 
    mov dx, offset output_mz
    mov ah, 09
    int 21h
    
    mov ax,mz1
    mov [mz+2],ax
    mov ax,mz2
    mov mz,ax
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
    mov cx, size                           ;loop N times, as we input N bit registers
    input:
        mov ah, 01h
        int 21h
        xor ah,ah                          ;input the character
        sub al, 30h                        ;al keeps the ascii code of char: 30 = 0, 31 = 1
        add bl, al                         ;subtracting 30 to obtain either 0 or 1
        shl bx, 1                          ;add that  bit to the result
        loop input                         ;shift the result left
    rcr bx,1
input_macro ENDM
;------------------------------------------

             
output_mantissa_32 proc
    xor bp,bp
    mov bp,2
    LoopTwice:
    dec bp
    mov cx, 16
    output_loop_1:  
        cmp bp,1
        jne leap1:
        test mz1,1b
        shr mz1, 1  
        jnz output_1
        leap1:
        
        cmp bp,0
        jne leap2:
        test mz2,1b
        shr mz2, 1
        jnz output_1
        leap2:
        
        mov dl, 30h        ;print 0
        jmp print
        output_1:
            mov dl, 31h    ;print 1        
        print:
        mov ah, 2          ;write char
        int 21h        
        loop output_loop_1
    cmp bp,1
    je LoopTwice 
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
    test ax, 1000000000000000b            
    jnz sign_neg                    ;if 1,the resulting mantissa is negative
    jmp sign_exit
    
    sign_neg:
        mov sign, 1                 ;store the sign in a var
               
    sign_exit:
    RET 
calc_sign ENDP      
;------------------------------------------

 ;    NOT WORKING YET :<                                 
;normalization PROC                         ;procedure for normalizing the mantissa
;    xor ax, ax                             ;clear the registers
;    xor bx, bx
;    xor cx, cx
;    xor dx, dx
;                                           ;move to ax the binary 1000000000000000b mask
;    mov ax, 1000000000000000b              ;move to bx the binary 0100000000000000b
;    mov bx, 0100000000000000b              ;move the mantissa to cx
;    mov cx, mz                             ;move the exponent to dl
;    mov dl, ez
;    
;    start_comparing:                       ;start by comparing the first 2 bits of mantissa
;        test mz, ax                        ;test if first bit is 1
;        jnz test_one                       ;if so, jump to test_one to test the second bit
;        jmp test_two                       ;if it is 0, then jump to test_two
;        test_one:
;            test mz, bx                    ;test the second bit of mantissa
;            jnz need_shift                 ;if it is 1, then go to shifting label
;            jmp exit_normalization         ;else exit the loop
;        
;        test_two:                          ;test the second bit
;            test mz, bx                    ;if it is 0, then shift
;            jz need_shift                  ;exit otherwise
;            jmp exit_normalization
;        
;        need_shift:
;            shl cx, 1                      ;shift the mantissa one time left
;            sub dl, 1                      ;subtract 1 from exponent 
;            shr ax, 1                      ;shift the masks one time left
;            shr bx, 1
;            
;            jmp start_comparing            ;continue looping
;    exit_normalization:
;   
;    mov mz, cx                             ;store the new values in memory
;    mov ez, dl
;    
;    RET
;normalization ENDP
;==========================================


add_mantissa PROC 
    xor ax, ax                        
    xor bx, bx   
    
    mov ax, mod_mx
    mov bx, mod_my 
    xor dx, dx     
      
    mov bp,2       ; loop "Multiply" twice because we need two pushes(16+16=32bit)  
    
    Multiply:
     mov cx, 8    
     
    L1:
     test al,1     ; checks if the first bit in Mx is 1 or not
     jz short CONT  ; if 0, don't add BX to result
     
     add mz1,bx 
     adc mz2,dx
    CONT:       
     shl dx,1
     test bx,1000000000000000b
     jz wwp
     inc dx
     wwp:                            
     shl bx,1
 
     
     
     shr ax,1      ; shift right the Mx
     dec cx
     jnz short L1  
            
     dec bp
     jnz Multiply 
     
     
     RET      
add_mantissa ENDP                    
;------------------------------------------
                 ;PRESS ANY KEY TO CONTINUE
ENDING:
mov  ah,7
int  21h 
                                   
MOV AX, 4C00H
INT 21H
END start  


 