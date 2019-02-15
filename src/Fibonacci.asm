


.text  
	ori $1, $0, 1            # $1 = 1
	addi $2, $0, 10          # $2 = 10
	subu $16, $1, $1         # $16 =0, base address
	addiu $17, $0, 10        # $17=10, loop times
	ori   $18, $0, 0         # $18=0
	ori   $19, $0, 1         # $19=1
	lui   $21, 1             # $21=1<<16
	sb    $2, 0($16)         # store $2 byte to m[$16+0]
	sh    $19, 4($16)        # store $2 half word to m[$16+4]
	lw    $20, 0($16)        # load $20 from m[$16+0]
	slt   $22, $20, $21      # $22=$20<$21
	slti   $22, $20, 1       # $22=$20<1
	lb    $20, 0($16)        # $20=m[$16+0] byte signed
	lbu    $20, 0($16)       # $20=m[$16+0] byte unsigned
	lh    $20, 0($16)        # $20=m[$16+0] halfword signed
	lhu    $20, 0($16)       # $20=m[$16+0] byte unsigned
	lui   $21, 1             # $21=1<<16
	sb    $2, 0($16)         # store $2 byte to m[$16+0]
	sh    $19, 4($16)        # store $2 half word to m[$16+4]
	lw    $20, 0($16)        # load $20 from m[$16+0]
	slt   $22, $20, $21      # $22=$20<$21
	slti   $22, $20, 1       # $22=$20<1
	lb    $20, 0($16)        # $20=m[$16+0] byte signed
	lbu    $20, 0($16)       # $20=m[$16+0] byte unsigned
	lh    $20, 0($16)        # $20=m[$16+0] halfword signed
	lhu    $20, 0($16)       # $20=m[$16+0] byte unsigned
	lui   $21, 1             # $21=1<<16
	sb    $2, 0($16)         # store $2 byte to m[$16+0]
	sh    $19, 4($16)        # store $2 half word to m[$16+4]
	lw    $20, 0($16)        # load $20 from m[$16+0]
	slt   $22, $20, $21      # $22=$20<$21
	slti   $22, $20, 1       # $22=$20<1
	lb    $20, 0($16)        # $20=m[$16+0] byte signed
	lbu    $20, 0($16)       # $20=m[$16+0] byte unsigned
	lh    $20, 0($16)        # $20=m[$16+0] halfword signed
	lhu    $20, 0($16)       # $20=m[$16+0] byte unsigned
	j    Loop                # jump to Loop
Loop:   jal Fibonacci            # call fibonacci function
	subu $17, $17, $1        # $17--
	addi $16, $16, 4         # $16+=4
	beq $17, $0, Loop_End    # if($17==0) goto Loop_End

Fibonacci: sw $19, 0($16)        # m[$16+0]=$19
	   addu $20, $18, $19    # $20=$18+$19
	   addu $18, $19, $0     # $18=$19
	   addu $19, $20, $0     # $19=$20
	   jr $31                # return to the next position where we call the function
	
Loop_End:                        # Loop_End Label
