Componenti Gruppo:

- Gallorini Lorenzo 816390
- Albi Alessandro 817769

Questo file README si riferisce al programma Prolog LMC.pl.

Il progetto è suddiviso in due Macro-sezioni: il parser e il simulatore.
Il parser si occupa di codificare le istruzioni assembly in un codice numerico interpretabile dal simulatore.

Il simulatore si occupa di interpretare il codice macchina ed eseguire le istruzioni.

Per esesuire il programma bisogna lanciare il predicato lmc_run/3 dal prompt di Prolog, passandogli come argomenti 
il path del file Assembly, una coda di input e una variabile per l'output.

Esempio:
?- lmc_run(”my/prolog/code/lmc/test-assembly-42.lmc”, [42], Output).



