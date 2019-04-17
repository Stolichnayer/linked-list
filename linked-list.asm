#s0 (x8) register = head
#s1 (x9) register = tail;
.data
	line_str:     .asciz "-------------------------------\n"
	nline_str:    .asciz "\n-------------------------------\n"
	space_str:    .asciz " "
.text

	main:
		# Sbrk - Create new dummy node
		addi a7, x0, 9		# a7 (x17) = syscall number 9 "Sbrk" set break - allocate heap memory to x17 (a7) register
		addi a0, x0, 8		# a0 (x10) = amount of memory in bytes	- output: address of memory saved at a0
		ecall
		# -----------------------------
		# Initialize dummy node
		sw x0, 0(a0)		# data = 0	
		sw x0, 4(a0)		# nxtPtr = 0	
		# Initialize head and tail
		add s0, x0, a0		# head = dummy;
		add s1, x0, a0		# tail = dummy;
			
		create:
			# (F) Read integer
			jal ra, read_int	# Saving return address to ra register and calling function read_int
			# ------------
			bge x0, a0, end		# branch to end if int in a0 <= 0 ( 0 >= a0)	
			add x13, x0, a0		# save integer to x13 register
			# (F) Sbrk - Create new node
			jal ra, node_alloc	# Saving return address to ra register and calling function node_alloc			
			# ----------------------
			sw x13, 0(a0)		# data = int of a0			
			sw  s0, 4(a0)		# connect nxtPtr to head
			addi s0, s0, 8		# move head 1 node down ( head now points to the node we just inserted ) 					
						
			j create		# jump unconditionally to create loop 
		end:	

			# Print a prompt
			addi    x17, x0, 4      # environment call code for print_string
			la      a0, line_str 	# pseudo-instruction: address of string
			ecall 

		search:
			# (F) Read integer
			jal ra, read_int	# Saving return address to ra register and calling function read_int				
			add s1, x0, a0		# Saving our integer to s1 register
			# ------------
			
			# Check if integer < 0
			bgt x0, s1, exit	# branch to exit if 0 > int of s1 
			
			add s2, x0, s0		# temp = head;		
			
			# (F) Search List
			# Arguments				
			add a0, x0, s2		# a0: temp
			add a1, x0, s1		# a1: our integer
			# Call
			jal ra, search_list	# Saving return address to ra register and calling function search_list

			j search
		exit:
			# Print a prompt
			addi    x17, x0, 4      # environment call code for print_string
			la      x10, nline_str 	# pseudo-instruction: address of string
			ecall   
				
			### EXIT ###
			addi a7, x0, 10		# a7 (x17) = syscall number 10 EXIT
			ecall	

########################## FUNCTIONS ##############################	

	search_list:
		# called with arguments:	# a0: temp (pointing at head of the list)
						# a1: our integer
		# Push to Stack Pointer	(Callee saved s registers)	
		addi sp, sp, -8			# reserve space on stack
		sw   s1, 0(sp)			# save value of s1 register
		sw   s2, 4(sp)			# save value of s2 register
		
		add  s2, x0, a0			# Saving temp to s2
		add  s1, x0, a1			# Saving our integer to s1 register
		
		# loop through list		
		ins_loop:	
			# (F) Check and print
			# Arguments		
			add a0, x0, s2		# a0: address of node (temp)
			add a1, x0, s1		# a1: our integer to compare
			
			# Push ra to Stack Pointer
			addi sp, sp, -4		# reserve space on stack
 			sw   ra, 0(sp)		# save return address
			# Call
			jal  ra, print_node	# Saving return address to ra register and calling function print_node	
			
			# Pop ra from Stack Pointer
			lw   ra, 0(sp) 		# get ret addr
 			addi sp, sp, 4 		# restore stack	
 						
			# check if there is a node next
			lw   x13, -4(s2)
			beq  x13, x0, fin 	# if nxtPtr == 0, exit
			addi  s2, s2, -8	# temp = temp  - 8 (next node)
			j ins_loop
			
		fin:
			# Print a prompt
			addi    x17, x0, 4      # environment call code for print_string
			la      x10, nline_str 	# pseudo-instruction: address of string
			ecall 
			
			# Pop from Stack Pointer
			lw  s1, 0(sp)			# restore value of s1 register
			lw  s2, 4(sp)			# restore value of s2 register
			addi sp, sp, 8			# restore stack
				
			jr ra, 0
		
	
	print_node:		
		# arguements: a0 address of node
		#	      a1: our integer
		
		add t0, x0, a0
		add t1, x0, a1
		# t0: temp address of  node
		# t1: our integer
		
		# x13 = integer of NODE's data
		lw  x13, 0(t0)		# load word ( int) of s2 address to x13 register 
		bgt x13, t1, cont
		beq x13, t1, cont	# branch to cont if x13 >= s1 ( if current int > our int in s1 )
		
		# Print integer
		addi a7, x0, 1		
		add  a0, x0, x13
		ecall	
			
		# Print a prompt
		addi    x17, x0, 4      # environment call code for print_string
		la      a0, space_str 	# pseudo-instruction: address of string
		ecall 
		
		cont:
			jr ra, 0
		
		
	read_int:
		addi a7, x0, 5		# a7 (x17) = syscall number 5 read int
		ecall
		jr ra, 0		# return value is already in a0
		
	node_alloc:
		addi a7, x0, 9		# a7 (x17) = syscall number 9 "Sbrk" set break - allocate heap memory to x17 (a7) register
		addi a0, x0, 8		# a0 (x10) = amount of memory in bytes	- output: address of memory saved at a0
		ecall
		jr ra, 0		# return value is already in a0
