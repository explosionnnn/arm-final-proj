.data

.text
.global drawJuliaSet
.type drawJuliaSet, %function

drawJuliaSet:
    @ Save registers
    stmfd sp!, {r4-r11, lr}

    @ Register mapping:
    @ r4: x
    @ r5: y
    @ r6: width
    @ r7: height
    @ r8: cX
    @ r9: cY
    @ r10: frame pointer
    @ r11: maxIter (255)

    mov r7, lr
    mrs r6, cpsr
    @the fourth instruction
    adds lr, sp, pc
    msr cpsr_f, r6
    mov lr, r7


    @ Stack layout:
    @ [sp, #36] -> frame pointer (arg5)

    @ Load frame pointer before modifying sp for locals
    ldr r10, [sp, #36]

    @ Allocate local variables on stack
    @ [sp]: zx
    @ [sp, #4]: zy
    @ [sp, #8]: i
    @ [sp, #12]: tmp
    sub sp, sp, #16
    @ Move arguments to preserved registers
    mov r8, r0
    mov r9, r1
    mov r6, r2
    mov r7, r3
    mov r11, #255

    @three condition execution
    mov r0, #5
    cmp r0, #6
    addlt r1, r1, r2, asr #5
    cmp r0, #5
    cmpeq r0, #4
    subgt r2, r2, r3, lsl r0

    @ Outer loop: x = 0 to width-1
    mov r4, #0
loop_x:
    cmp r4, r6
    bge end_draw

    @ Inner loop: y = 0 to height-1
    mov r5, #0
loop_y:
    cmp r5, r7
    bge next_x

    @ Calculate zx = 1500 * (x - width/2) / (width/2)
    mov r0, r6, asr #1      @ denominator = width >> 1
    sub r1, r4, r0          @ x - width/2
    ldr r2, =1500
    mul r1, r1, r2          @ numerator = 1500 * ...

    @ Division: r0 = num, r1 = den -> __aeabi_idiv -> r0
    mov r2, r0              @ move den to r2
    mov r0, r1              @ move num to r0
    mov r1, r2              @ move den to r1
    bl __aeabi_idiv
    str r0, [sp]            @ save zx

    @ Calculate zy = 1000 * (y - height/2) / (height/2)
    mov r0, r7, asr #1      @ denominator = height >> 1
    sub r1, r5, r0          @ y - height/2
    mov r2, #1000
    mul r1, r1, r2          @ numerator

    mov r2, r0              @ move den to r2
    mov r0, r1              @ move num to r0
    mov r1, r2              @ move den to r1
    bl __aeabi_idiv
    str r0, [sp, #4]        @ save zy

    @ i = maxIter
    str r11, [sp, #8]

while_loop:
    @ Check i > 0
    ldr r2, [sp, #8]
    cmp r2, #0
    ble end_while

    @ Check zx*zx + zy*zy < 4000000
    ldr r0, [sp]            @ zx
    ldr r1, [sp, #4]        @ zy
    mul r0, r0, r0          @ zx^2
    mul r1, r1, r1          @ zy^2
    add r0, r0, r1          @ sum
    ldr r1, =4000000
    cmp r0, r1
    bge end_while

    @ Loop body
    @ tmp = (zx*zx - zy*zy)/1000 + cX
    ldr r0, [sp]            @ zx
    mul r0, r0, r0          @ zx^2
    ldr r1, [sp, #4]        @ zy
    mul r1, r1, r1          @ zy^2
    sub r0, r0, r1          @ zx^2 - zy^2

    mov r1, #1000           @ denominator
    bl __aeabi_idiv
    add r0, r0, r8          @ + cX
    str r0, [sp, #12]       @ save tmp

    @ zy = (2*zx*zy)/1000 + cY
    ldr r0, [sp]            @ zx
    ldr r1, [sp, #4]        @ zy
    mul r0, r0, r1          @ zx*zy
    lsl r0, r0, #1          @ 2*zx*zy

    mov r1, #1000           @ denominator
    bl __aeabi_idiv
    add r0, r0, r9          @ + cY
    str r0, [sp, #4]        @ update zy

    @ zx = tmp
    ldr r0, [sp, #12]
    str r0, [sp]

    @ i--
    ldr r2, [sp, #8]
    sub r2, r2, #1
    str r2, [sp, #8]

    b while_loop

end_while:
    @ color = ((i & 0xff) << 8) | (i & 0xff)
    ldr r2, [sp, #8]        @ i
    and r2, r2, #0xff
    lsl r3, r2, #8
    orr r3, r3, r2

    @ color = (~color) & 0xffff
    mvn r3, r3
    ldr r2, =0xffff
    and r3, r3, r2

    @ frame[y][x] = color
    @ offset = (y * width + x) * 2
    mul r0, r5, r6          @ y * width
    add r0, r0, r4          @ + x
    lsl r0, r0, #1          @ * 2
    strh r3, [r10, r0]      @ store halfword at frame + offset

    @ Next y
    add r5, r5, #1
    b loop_y

next_x:
    add r4, r4, #1
    b loop_x

end_draw:
    add sp, sp, #16
    ldmfd sp!, {r4-r11, pc}
