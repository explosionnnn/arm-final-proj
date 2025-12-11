.data

.text
FRAME_WIDTH equ 640
FRAME_HEIGHT equ 480
.global drawJuliaSet

drawJuliaSet:
    @initialize
    sub sp, sp, #32 @color:int16
    mov r4, #255
    str r4, [sp, #32]
    mov r4, #0
    str r4, [sp, #8]
    str r4, [sp, #4]
    mov r4, #255
    str r4, [sp, #12]

    @into loop
first_loop:
sec_loop:
    @cal zx
    ldr r4, [sp, #8]
    sub r4, r4, r2, asr, #1
    mov r6, r2, asr, #1
    sdiv r4, r4, r6
    mov r6, #1500
    mul r4, r4, r6
    str r4, [sp, #24]

    @cal zy
    ldr r4, [sp, #4]
    sub r4, r4, r3, asr, #1
    mov r6, r3, asr, #1
    sdiv r4, r4, r6
    mov r6, #1000
    mul r4, r4, r6
    str r4, [sp, #20]

    @rec i
    ldr r4, [sp, #32]
    str r4, [sp, #12]

    @prepare r4
    ldr r4, [sp, #24]
    ldr r5, [sp, #20]
    mul r4, r4, r4
    mul r5, r5, r5
    add r4, r4, r5

    @prepare r5:4000000
    mov r5, #4000000

    while_loop:
    cmp r4, r5
    bge after_while
    ldr r6, [sp, #12]
    cmp r6, #0
    ble after_while

    @cal tmp
    ldr r4, [sp, #24]
    ldr r5, [sp, #20]
    mul r4, r4, r4
    mul r5, r5, r5
    sub r4, r4, r5
    mov r6, #1000
    sdiv r4, r4, r6
    add r4, r4, r0
    str r4, [sp, #16]

    @cal zy
    ldr r4, [sp, #24]
    ldr r5, [sp, #20]
    lsl r5, r5, #1
    mul r4, r4, r5
    mov r6, #1000
    sdiv r4, r4, r6
    add r4, r4, r1
    str r4, [sp, #20]

    @cal zx
    ldr r4, [sp, #16]
    str r4, [sp, #24]

    @cal i
    ldr r4, [sp, #12]
    sub r4, r4, #1
    str r4, [sp, #12]

    @prepare r4
    ldr r4, [sp, #24]
    ldr r5, [sp, #20]
    mul r4, r4, r4
    mul r5, r5, r5
    add r4, r4, r5

    @prepare r5:4000000
    mov r5, #4000000

    b while_loop


    after_while:
