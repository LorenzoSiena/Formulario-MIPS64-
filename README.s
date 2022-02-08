# r0 = $0 = 0
# r14 = PreCall Parametro
# r1 = $at -> usato come valore di ritorno di SYSCALL (v1 e v2 valori di ritorno) ($at è normalmente riservato al sistema)
# $sp = Stack pointer, può essere aumentato e diminuito di n*8 byte alla volta con daddi
# PC Program counter Registro che incrementato tiene conto della prossima istruzione N*4  0,4,8,12,16.... (manipolandolo permette i jump!) 

#ALLOCAZIONE STACK(ci salvo i valori di ritorno di salto per le varie funzioni annidate)

(sposto il puntatore stando attento a non sconfinare nell'altra area di memoria causando uno Stack buffer overflow) 

.data

stack: .space 32

      stack:
0 [             ] 
8 [             ] 
16[             ] 
24[          |31] <-SP 


.code
daddi $sp,r0,stack # carico l'indirizzo dello stack nel stack pointer
daddi $sp,$sp,32   # e lo sposto di 4 righe alla fine dello stack al 32 esimo byte


#allocazione e salvataggio registri (scrivo  nello stack e mi sposto indietro)
daddi $sp,$sp,-8   #sposto lo stack INDIETRO di una riga
sd $s0, 0($sp)     # $s0 VARIABILE SALVATA nello stack

$s0= [xxx]

     stack:
     0 [             ] 
     8 [             ] 
     16[          |23]<-SP   TORNO INDIETRO
     24[  SCRITTO    ]       (E SCRIVO )  


# ripristino dei registri e deallocazione della memoria (leggo dallo stack e mi sposto avanti)
ld  $s0,0($sp)     # $s0 VARIABILE CARICATA dallo stack
daddi $sp,$sp,8    #sposto lo stack AVANTI di una riga


$s0=[]  -->  $s0= [xxx]

           stack:
     0 [             ] 
     8 [             ] 
     16[             ]       (LEGGO)
     24[  LETTO   |31] <-SP  MI SPOSTO AVANTI E DIMENTICO
  
-------------------------------------------------------------------------------------
.data -> STR: .space 16

     STR:
[0    ciao     7] STR(0)->STR(7)  
[8    mamma   15] STR(8)->STR(15)


[Indirizzi/puntatore]
daddi $a0,r0,STR      #salvo indirizzo stringa in a0

[Valori]
ld $a0,STR(r0)        #salvo il primo elemento di SRT[0,1,2,3,4,5,6,7] in $a0 =[0]



----------DIVISIONE/MOLTIPLICAZIONE-------
dividere per 2,4,8,16
SHIFT ARITMETICO A DX

1_shift
dsra $t0,$t0,1   DIVISO 2

2_shift
dsra $t0,$t0,2   DIVISO 4

3_shift
dsra $t0,$t0,3   DIVISO 8


moltiplicare per 2,4,8,16


---------------------------ESERCIZI-----------------------------------------------------------
CALCOLO LA LUNGHEZZA DELLA STRINGA

.data

str1: .asciiz "inserisci una stringa di numeri"
str2: .asciiz "la somma e' %d \n"

p1_sys3: .word 0
ind_sys3: .space 8
dim_sys3: .word 16
STR: .space 16

.code

#scanf("%s",STR)->SYS3
daddi $t0,r0,STR
sd $t0,ind_sys3(r0)
daddi $14,r0,p1_sys3
syscall 3             #->r1= dimensione stringa


--------------------------------------------------------------------------------------
SYSCALL 3: READ/SCANF

.data
p1_sys3:     .word 0     #0->STDIN oppure file descriptor
ind_str:	 .space 8    #dove salvare la stringa
dim: 	       .word 16    #quanti byte scrivere (16 Byte)
??????????????????????????????????????????????????????????????????????????????????
.code
sd r0,par(r0)   # stdin
daddi $t0, r0, buffer # copia il valore buffer in $t0
sd $t0, ind(r0) # salva l’indirizzo buffer in ind
daddi r14, r0, par
syscall 3       #->r1= stringa inserita
????????????????????????????????????????????????????????????????
-----------------------------------------------------------------------------------------
SYSCALL 5: PRINTF

.data
str1: .asciiz "Stampa solo questa riga”
str2: .asciiz "Stampa il numero %d”

p1_sys5: .space 8 # primo parametro che deve contenere l’indiririzzo della stringa da visualizzare (mess)
val1: .space 8       # SE nella stringa sono presenti N %d, seguono altri N parametri

.code
sd r1,val(r0)            # salvo il ritorno di una funzione in val(r0) ->OPZIONALE PER %d

daddi $t0,r0,str2        #metto l'indirizzo della stringa2 in t0     
sd $t0,p1_sys5(r0)       #salvo t0 come prima riga nel par1
daddi r14,r0,p1_sys5     #salvo il par1
syscall 5


