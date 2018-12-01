 ;Quentin DELIGNY - 2262655D

; A Sigma16 assembly program that implements both the recursive and dynamic
; algorithms to solve the 0-1 Knapsack Problem.

; Given a set of items, each having a positive integer weight and a positive
; integer value, and a maximum weight capacity, compute the maximum value you
; can achieve by either including or excluding items from your solution. 


; Main program
;    Sets up registers, calls knapsackRP(), knapsackDP(), prints results and terminates

; Register usage
;    R1: N / result
;    R2: W
;    R3: pointer to weights
;    R4: pointer to values
;    R5: constant 0
;    R13: return address
;    R14: stack pointer
; Structure of stack frame
;    1[R14]   origin of next stack frame
;    0[R14]   0 (no previous stack frame)

main
   lea   R14,stack[R0]    ; Initialise stack pointer
   store R0,0[R14]        ; No previous stack frame
   store R14,1[R14]       ; Pointer to beginning of current frame

   load R1,N[R0]          ; R1 := N
   load R2,W[R0]          ; R2 := W
   lea R3,weights[R0]     ; R3 := weights
   lea R4,values[R0]      ; R4 := values
   add R5,R0,R0           ; R5 := constant 0 (= i for knapsackRP)
   lea R6,1[R0]		  ; R6 := constant 1 (for incrementation)
   load R7,takeit[R0]     ; R7 := takeit
   load R8,leaveit[R0]    ; R8 := leaveit

   lea R14,1[R14]         ; Push stack pointer
   jal R13,knapsackRP[R0] ; Call the recursive knapsack solution function
   lea R14,1[R14]         ; Push stack pointer
   jal R13,println[R0]    ; Call the println() function; param in R1

   load R1,N[R0]          ; Restore N into R1 after it was overwritten by knapsackRP
   lea R14,1[R14]         ; Push stack pointer
   jal R13,knapsackDP[R0] ; Call the dynamic programming knapsack solution function
   lea R14,1[R14]         ; Push stack pointer
   jal R13,println[R0]    ; Call the println() function; param in R1

   trap R0,R0,R0          ; Terminate


; function knapsackRP(N:R1, W:R2, weights:R3, values:R4, i:R5) -> return value:R1
;
; The basic recursive algorithm is:
; int knapsackRP(int N, int W, int weights[], int values[], int i) {
;    if (W == 0 || i >= N) // If out of capacity or out of items
;       return 0;
;    if (weights[i] > W) // If weight of current item above weight limit
;       return knapsackRP(N, W, weights, values, i + 1); // Skip to next item
;
;    // Compute solution if the item is included
;    int takeit = values[i] + knapsackRP(N, W - weights[i], weights, values, i + 1);
;
;    // Compute solution if the item is excluded
;    int leaveit = knapsackRP(N, W, weights, values, i + 1);
;
;    return max(takeit, leaveit);
; }
;
; Stack frame structure:
;    1[R14]   return adress
;    2[R14]   N
;    3[R14]   W
;    4[R14]   weights
;    5[R14]   values
;    6[R14]   i (used as constant 0).
;    0[R14]   pointer to previous stack frame
;
; Register usage:
;    R1: N/result
;    R2: W
;    R3: pointer to weights
;    R4: pointer to values
;    R5: i
;    R6: 1 (incrementation)
;    R7: used for values[i]
;    R8: leaveit
;    R12: takeit
;    R9: used for weights[i]

;    R10: used as secondary N
;    R13: return address
;    R14: stack pointer

knapsackRP
	
	store R13,1[R14]	; save return adress
	store R2,2[R14]		; save W
	store R3,3[R14]		; save weights
	store R4,4[R14]		; save values
	store R5,5[R14]		; save i (used as constant 0).
	store R9,6[R14]
	store R7,7[R14]
	store R14,8[R14]	; pointer to next stack frame
	

	load R10,N[R0]		; R10 := N
	cmp R2,R0		; We compare W and 0
	jumpeq outof[R0]	; Jump if W==0
	cmp R5,R10		; We compare i and N
	jumpge outof[R0]	; Jump if i>=N

; At this point, we check for the second "if" statement.

	load R9,weights[R5]	; We load weights[i] into R9
	cmp R9,R2		; We compare weigths[i] and W 
	jumpgt tooheavy[R0]	; Jump if weights[i]>W

; If the item is included
	
	load R9,weights[R5]	; We load weights[i] into R9
	load R7,values[R5]	; We load values[i] into R7
	sub R2,R2,R9		; W = W - weights[i]
	
	add R5,R5,R6		; R5 (or i) is incremented by 1

	store R14,8[R14]	; we store R14 at pointer for current frame
	lea R14,8[R14]		; push stack frame

	jal R13,knapsackRP[R0]	; R1 := knapsackRP(N, W - weights[i], weights, values, i + 1)
	add R12,R7,R1		; R12 (takeit) := values[i] + knapsackRP(N, W - weights[i], weights, values, i + 1)

; If the item is excluded
	
	load R2,2[R14]		; restore W
	store R14,8[R14]	; we store R14 at pointer for current frame
	lea R14,8[R14]		; push stack frame

	;add R5,R5,R6		; R5 (or i) is incremented by 1 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	jal R13,knapsackRP[R0]	; R1 := knapsackRP(N, W, weights, values, i + 1)
	add R8,R1,R0		; R8 := R1 (:= leaveit)

; return max(takeit,leaveit)

	cmp R12,R8		; compare takeit and leaveit
	jumpgt takeitwins[R0]	; takeit is greater
	jump leaveitwins[R0]	; leaveit is greater or equal (does not matter as returning the value of leaveit is correct in both cases)

	

outof				; If out of capacity or out of items
	lea R1,0[R0]		; We set the result to 0
	jump return[R0]		; We go to return

tooheavy			; If weight of current item above weight limit
	add R5,R5,R6		; R5 (or i) is incremented by 1
	store R14,8[R14]	; we store R14 at pointer for current frame
	lea R14,8[R14]		; push stack frame
	jal R13,knapsackRP[R0]	; We move on to the next item
	jump return[R0]

takeitwins
	add R1,R12,R0 		; R1 := R12 (or takeit)
	jump return[R0]		; go to return

leaveitwins
	add R1,R8,R0		; R1 := R8 (or takeit)
	jump return[R0]		; go to return

return
	load R13,1[R14]		; restore return adress
	load R2,2[R14]		; restore W
	load R3,3[R14]		; restore weights
	load R4,4[R14]		; restore values
	load R5,5[R14]		; restore i (used as constant 0).
	load R9,6[R14]
	load R7,7[R14]
	load R14,0[R14]		; pop stack
	
	jump 0[R13]		; return
	

;
; function knapsackDP(N:R1, W:R2, weights:R3, values:R4) -> return value:R1
;
; The dynamic programming algorithm is:
; int knapsackDP(int N, int W, int weights[], int values[]) {
;    int S[N+1][W+1]; // Allocate array as local variable
;
;    for (i = 0; i <= W; i++)
;       S[0][i] = 0; // Solution for 0 items is 0
;
;    for (i = 1; i <= N; i++) // Loop over all items...
;       for (w = 0; w <= W; w++) // and over all intermediate weight limits
;          if (weights[i-1] > w) // If the current item doesn't fit...
;             S[i][w] = S[i-1][w]; // then skip it...
;          else
;             // otherwise, compute the maximum of taking it or leaving it
;             S[i][w] = max(S[i-1][w], S[i-1][w-weights[i-1]] + values[i-1]);
;    return S[N][W];
; }
;
; Stack frame structure:
;    <fill in your stack frame's structure...>
;    1[R14]   return address (R13)
;    0[R14]   pointer to previous stack frame
;
; Register usage:
;    R1: N/result
;    R2: W
;    R3: pointer to weights
;    R4: pointer to values
;    <fill in your register usage...>
;    R13: return address
;    R14: stack pointer
knapsackDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; <fill in your code...> ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;



; Function println(num:R1)
;    Converts the value in R1 to printable decimal digits and prints it on screen
;
; Stack frame structure:
;    0[R14]   origin of the next frame
;    0[R14]   pointer to previous stack frame
;    1[R14]   return adress
;    2[R14]   stack pointer
;    3[R14]   W
;    4[R14]   weights
;    5[R14]   values
;    6[R14]   constant 0 (i)
;    7[R14]   constant 1
;    8[R14]   R7
;    9[R14]   R8
;    10[R14]  R9
;
; Register usage:
;    R1: input number
;    R2: amount of units/ tens/ hundreds/ thousands
;    R3: 2 (code for write)
;    R4: length of string
;    R5: 48 used to translate to ASCII
;    R6: 1 incrementation.
;    R7: 10 (and ASCII for newline)
;    R8: 100
;    R9: 1000
;    R13: return address
;    R14: stack pointer

println

	store R13,1[R14]	; save return adress
	store R14,2[R14]	; save stack pointer
	store R2,3[R14]		; save W
	store R3,4[R14]		; save weights
	store R4,5[R14]		; save values
	store R5,6[R14]		; save constant 0 (i)
	store R6,7[R14]		; save constant 1
	store R7,8[R14]		; save R7
	store R8,9[R14]		; save R8
	store R9,10[R14]	; save R9

	lea R2,0[R0]		; R2 := 0
	lea R4,0[R0]		; R4 := 0
	lea R3,2[R0]		; R3 := 2
	lea R5,48[R0]		; R5 := 48
	lea R6,1[R0]		; R6 := 1
	lea R7,10[R0]		; R7 := 10
	lea R8,100[R0]		; R8 := 100
	lea R9,1000[R0]		; R9 := 1000
	jump start[R0]		; start of loops

start
	cmp R1,R7
	
	div R1,R1,R7






	cmp R1,R9		; compare R1 and 1000
	jumpge thousands[R0]	; If R1 >= 1000

; R1 is now less than 1000

	cmp R2,R0		; Compare R2 and 0
	jumpgt addchar[R0]	; If R2 is not null we add it to the stack

	cmp R1,R8		; compare R1 and 100
	jumpge hundreds[R0]	; If R1 >= 100

; R1 is now less than 100

	cmp R2,R0		; Compare R2 and 0
	jumpgt addchar[R0]	; If R2 is not null we add it to the stack

	cmp R1,R7		; compare R1 and 10
	jumpge tens[R0]		; If R1 >= 10

; R1 is now less than 10

	cmp R2,R0		; Compare R2 and 0
	jumpgt addchar[R0]	; If R2 is not null we add it to the stack

	cmp R1,R6		; compare R1 and 1
	jumpge units[R0]	; If R1 >= 1

; R1 is now 0 and we have stored all characters of R1 into the array stacks

	store R7,stack[R14]	; We add 10 to the array (ASCII for newline)
	lea R14,stack[R0]	; We reset R14 to the adress of stack[0]
	trap R3,R14,R4		; We write the number stored in the array with a newline

	load R13,1[R14]		; restore return adress
	load R14,2[R14]		; restore stack pointer
	load R2,3[R14]		; restore W
	load R3,4[R14]		; restore weights
	load R4,5[R14]		; restore values
	load R5,6[R14]		; restore constant 0 (i)
	load R6,7[R14]		; restore constant 1
	load R7,8[R14]		; restore R7
	load R8,9[R14]		; restore R8
	load R9,10[R14]		; restore R9

	jump 0[R13]		; return

thousands
	sub R1,R1,R9		; R1 := R1 - 1000
	add R2,R2,R6		; R2 := R2 + 1
	jump start[R0]		; we go back to start

hundreds
	sub R1,R1,R8		; R1 := R1 - 100
	add R2,R2,R6		; R2 := R2 + 1
	jump start[R0]		; we go back to start

tens
	sub R1,R1,R7		; R1 := R1 - 10
	add R2,R2,R6		; R2 := R2 + 1
	jump start[R0]		; we go back to start

units
	sub R1,R1,R6		; R1 := R1 - 1
	add R2,R2,R6		; R2 := R2 + 1
	jump start[R0]		; we go back to start

addchar
	add R2,R2,R5		; add 48 to R2 to translate it to ASCII
	store R2,stack[R14]	; we store R2 in the stack
	add R4,R4,R6		; we increment the length of the string by 1
	add R14,R14,R6		; we increment R14
	lea R2,0[R2]		; we reinitialise R2
	jump start[R0]		; we go back to the start

	

; Data segment

K 	data 0
takeit  data 0
leaveit data 0
N       data 3
W       data 5
weights data 1
        data 2
        data 3
values  data 4
        data 3
        data 5
stack   data 0