; 设置段地址
DATA SEGMENT
    MSG DB 'Hello World!', '$'  ; DOS 打印函数要求以 '$' 结尾
DATA ENDS

STACK SEGMENT
    DB 100H DUP(?)            ; 定义栈空间
STACK ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:STACK

START:
    ; 初始化 DS 寄存器 (8086 必须手动设置)
    MOV AX, DATA
    MOV DS, AX

    ; 调用我们写的 PRINT 函数
    ; 按照约定，我们将字符串地址放入 DX
    LEA DX, MSG
    CALL PRINT

    ; 退出程序，返回 DOS
    MOV AX, 4C00H
    INT 21H

; -----------------------------------------
; 基础 PRINT 函数
; 输入: DX = 字符串的偏移地址
; 影响: AH (已在函数内保护或根据惯例修改)
; -----------------------------------------
PRINT PROC
    MOV AH, 09H    ; DOS 功能号 09H: 显示字符串
    INT 21H        ; 调用 DOS 中断
    RET
PRINT ENDP

CODE ENDS
    END START
