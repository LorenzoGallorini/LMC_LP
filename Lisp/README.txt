Componenti Gruppo:

- Gallorini Lorenzo 816390
- Albi Alessandro 817769

Questo file README si riferisce al programma Lisp LMC.lisp.

Il progetto è suddiviso in due Macro-sezioni: il parser e il simulatore.
Il parser si occupa di codificare le istruzioni assembly in un codice numerico
interpretabile dal simulatore.
Il simulatore si occupa di interpretare il codice macchina ed eseguire le
istruzioni.

Per esesuire il programma bisogna lanciare la funzione lmc_run/2 => Output
dal listener di LispWorks, passandogli come argomenti il path del file
Assembly e una coda di input, che restituirà nel nome della funzione la
coda di output.

Esempio:
cl-prompt> (lmc-run ”my/common-lisp/code/lmc/test-assembly-42.lmc”, ‘(9))
;;; Output


