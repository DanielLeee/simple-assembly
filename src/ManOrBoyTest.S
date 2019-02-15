start:
 li $29, 0x2ffc
 addi $29, $29, -4
 li $30, 0xad720067
 j main
 nop

main:
 jal test_0
 jal test_1
 jal test_2
 jal test_3
 jal test_4
 jal test_5
 jal test_6
 jal test_7
 j success



test_0:
 addi $16, $0, -1
 addiu $16, $16, 2
 bne $16, $0, load_store
 nop
 j err
 nop
 load_store:
  sw $16, 4($29)
  sw $16, 0($29)
  lw $17, 4($29)
  lw $18, 0($29)
 addi $17, $18, -1
 beq $17, $0, initialized
 nop
 j err
 nop
 initialized:
  lui $3, 0x1991
  ori $3, $3, 0x1014
 j ret
 nop
 j err
 nop

test_1:
 li $16, 0x4ec192cd
 add $30, $30, $16
 jal test_add
 jal test_and
 jal test_or

test_2:
 li $16, 0x6c168cf8
 add $30, $30, $16
 jal test_addi
 jal test_andi
 jal test_ori

test_3:
 li $16, 0xd012f762
 add $30, $30, $16
 jal test_slt
 jal test_slti
 jal test_sltu
 jal test_sltiu
 jal test_sll
 jal test_srl
 jal test_sra
 jal test_srlv
 jal test_srav
 jal test_sllv

test_4:
 li $16, 0x33f1c867
 add $30, $30, $16
 jal test_nor
 jal test_addu
 jal test_addiu
 jal test_sub
 jal test_subu
 jal test_xor
 jal test_xori
test_5:
 li $16, 0x8d5e762c
 add $30, $30, $16
 jal test_bgez
 jal test_bgtz
 jal test_blez
 jal test_bltz
 jal test_bne
 jal test_jalr
test_6:
 li $16, 0x90fcfb6e
 add $30, $30, $16
 jal test_lbu
 jal test_lhu
 jal test_lb
 jal test_lh
 jal test_sb
 jal test_sh

test_7:
 li $16, 0xeb0fbe6
 add $30, $30, $16
 jal test_hi
 jal test_lo
 jal test_mult
 jal test_multu
 jal test_div
 jal test_divu



success:
 li $8, 0x19921004
 add $30, $30, $16
 j end
 nop

end:
 j end
 nop

test_add:
 li $2, 1
 li $16, 1
 li $17, 2
 add $16, $16, $17
 li $17, 3
 bne $16, $17, err
 nop
 j ret
 nop

test_addi:
 li $2, 2
 li $16, 2
 addi $16, $16, 3
 li $17, 5
 bne $16, $17, err
 nop
 j ret
 nop

test_addu:
 li $2, 3
 li $16, 3
 li $17, 4
 addu $16, $16, $17
 li $17, 7
 bne $16, $17, err
 nop
 j ret
 nop

test_addiu:
 li $2, 4
 li $16, 2
 addiu $16, $16, 3
 li $17, 5
 bne $16, $17, err
 nop
 j ret
 nop

test_and:
 li $2, 5
 li $16, 5
 li $17, 4
 and $16, $16, $17
 li $17, 4
 bne $16, $17, err
 nop
 j ret
 nop

test_andi:
 li $2, 6
 li $16, 5
 andi $16, $16, 3
 li $17, 1
 bne $16, $17, err
 nop
 j ret
 nop

test_div:
 li $2, 7
 li $16, -8
 li $17, -3
 div $16, $17
 mfhi $16
 li $17, -2
 bne $16, $17, err
 mflo $16
 li $17, 2
 bne $16, $17, err
 nop
 j ret
 nop

test_divu:
 li $2, 8
 li $16, 11
 li $17, 7
 divu $16, $17
 mfhi $16
 li $17, 4
 bne $16, $17, err
 mflo $16
 li $17, 1
 bne $16, $17, err
 nop
 j ret
 nop

test_mult:
 li $2, 9
 li $16, 65538
 li $17, -65537
 mult $16, $17
 mfhi $16
 li $17, 0xfffffffe
 bne $16, $17, err
 mflo $16
 li $17, 0xfffcfffe
 bne $16, $17, err
 nop
 j ret
 nop

test_multu:
 li $2, 10
 li $16, 65539
 li $17, 65541
 multu $16, $17
 mfhi $16
 li $17, 1
 bne $16, $17, err
 mflo $16
 li $17, 0x0008000f
 bne $16, $17, err
 nop
 j ret
 nop

test_nor:
 li $2, 11
 li $16, 1
 li $17, 5
 nor $16, $16, $17
 li $17, 0xfffffffa
 bne $16, $17, err
 nop
 j ret
 nop

test_or:
 li $2, 12
 li $16, 3
 li $17, 5
 or $16, $16, $17
 li $17, 7
 bne $16, $17, err
 nop
 j ret
 nop

test_ori:
 li $2, 13
 li $16, 3
 ori $16, $16, 1
 li $17, 3
 bne $16, $17, err
 nop
 j ret
 nop

test_sll:
 li $2, 14
 li $16, 0x0fffff00
 sll $16, $16, 4
 li $17, 0xfffff000
 bne $16, $17, err
 nop
 j ret
 nop

test_srl:
 li $2, 15
 li $16, 0xffffff00
 srl $16, $16, 4
 li $17, 0x0ffffff0
 bne $16, $17, err
 nop
 j ret
 nop

test_sra:
 li $2, 16
 li $16, 0xffffff00
 sra $16, $16, 4
 li $17, 0xfffffff0
 bne $16, $17, err
 nop
 j ret
 nop

test_srlv:
 li $2, 17
 li $16, 0xffffff00
 li $17, 8
 srlv $16, $16, $17
 li $17, 0x00ffffff
 bne $16, $17, err
 nop
 j ret
 nop

test_srav:
 li $2, 18
 li $16, 0xffffff00
 li $17, 8
 srav $16, $16, $17
 li $17, 0xffffffff
 bne $16, $17, err
 nop
 j ret
 nop

test_sllv:
 li $2, 19
 li $16, 0xffffff00
 li $17, 8
 sllv $16, $16, $17
 li $17, 0xffff0000
 bne $16, $17, err
 nop
 j ret
 nop

test_sub:
 li $2, 20
 li $16, 1
 li $17, 2
 sub $16, $16, $17
 li $17, -1
 bne $16, $17, err
 nop
 j ret
 nop

test_subu:
 li $2, 21
 li $16, 3
 li $17, 1
 subu $16, $16, $17
 li $17, 2
 bne $16, $17, err
 nop
 j ret
 nop

test_xor:
 li $2, 22
 li $16, 3
 li $17, 5
 xor $16, $16, $17
 li $17, 6
 bne $16, $17, err
 nop
 j ret
 nop

test_xori:
 li $2, 23
 li $16, 3
 xori $16, $16, 1
 li $17, 2
 bne $16, $17, err
 nop
 j ret
 nop

test_slt:
 li $2, 25
 li $16, 1
 li $17, -2
 slt $16, $16, $17
 li $17, 0
 bne $16, $17, err
 nop
 j ret
 nop

test_slti:
 li $2, 26
 li $16, -4
 slti $16, $16, -3
 li $17, 1
 bne $16, $17, err
 nop
 j ret
 nop

test_sltu:
 li $2, 27
 li $16, 3
 li $17, -2
 sltu $16, $16, $17
 li $17, 1
 bne $16, $17, err
 nop
 j ret
 nop

test_sltiu:
 li $2, 28
 li $16, 2
 sltiu $16, $16, -3
 li $17, 1
 bne $16, $17, err
 nop
 j ret
 nop

test_bgez:
 li $2, 30
 li $16, -1
 bgez $16, err
 nop
 li $16, 0
 bgez $16, ret
 nop

test_bgtz:
 li $2, 31
 li $16, 0
 bgtz $16, err
 nop
 li $16, 1
 bgtz $16, ret
 nop

test_blez:
 li $2, 32
 li $16, 1
 blez $16, err
 nop
 li $16, 0
 blez $16, ret
 nop

test_bltz:
 li $2, 33
 li $16, 0
 bltz $16, err
 nop
 li $16, -1
 bltz $16, ret
 nop

test_bne:
 li $2, 34
 li $16, 0
 li $17, 0
 bne $16, $17, err
 nop
 li $17, 1
 bne $16, $17, ret
 nop

test_jalr:
 li $2, 38
 add $16, $31, $0
 la $17, ret
 jalr $17
 nop
 add $31, $16, $0
 j ret
 nop

test_lbu:
 li $2, 39
 li $16, 0x778899aa
 sw $16, 0($29)
 lbu $16, 0($29)
 li $17, 0x000000aa
 bne $16, $17, err
 nop
 lbu $16, 1($29)
 li $17, 0x00000099
 bne $16, $17, err
 nop
 lbu $16, 2($29)
 li $17, 0x00000088
 bne $16, $17, err
 nop
 lbu $16, 3($29)
 li $17, 0x00000077
 bne $16, $17, err
 nop
 j ret
 nop

test_lhu:
 li $2, 40
 li $16, 0x77778888
 sw $16, 0($29)
 lhu $16, 0($29)
 li $17, 0x00008888
 bne $16, $17, err
 nop
 lhu $16, 2($29)
 li $17, 0x00007777
 bne $16, $17, err
 nop
 j ret
 nop

test_lb:
 li $2, 41
 li $16, 0x778899aa
 sw $16, 0($29)
 lb $16, 0($29)
 li $17, 0xffffffaa
 bne $16, $17, err
 nop
 lb $16, 1($29)
 li $17, 0xffffff99
 bne $16, $17, err
 nop
 lb $16, 2($29)
 li $17, 0xffffff88
 bne $16, $17, err
 nop
 lb $16, 3($29)
 li $17, 0x00000077
 bne $16, $17, err
 nop
 j ret
 nop

test_lh:
 li $2, 42
 li $16, 0x77778888
 sw $16, 0($29)
 lh $16, 0($29)
 li $17, 0xffff8888
 bne $16, $17, err
 nop
 lh $16, 2($29)
 li $17, 0x00007777
 bne $16, $17, err
 nop
 j ret
 nop

test_sh:
 li $2, 45
 li $16, 0xffff7788
 sh $16, 0($29)
 lw $16, 0($29)
 li $17, 0x00007788
 bne $16, $17, err
 nop
 j ret
 nop

test_sb:
 li $2, 44
 li $16, 0xffff7788
 sw $0, 0($29)
 sb $16, 0($29)
 lw $16, 0($29)
 li $17, 0x00000088
 bne $16, $17, err
 nop
 j ret
 nop

test_hi:
 li $2, 50
 li $16, 9
 mthi $16
 mfhi $17
 bne $16, $17, err
 nop
 j ret

test_lo:
 li $2, 53
 li $16, 7
 mtlo $16
 mflo $17
 bne $16, $17, err
 nop
 j ret

ret:
 jr $31
 nop

err:
 j err
 nop
