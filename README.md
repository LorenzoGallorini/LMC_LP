# LMC - Little Man Computer

## Descrizione del Progetto

Il Little Man Computer (LMC) è un semplice modello di computer progettato per scopi didattici. Questo progetto simula il comportamento di un LMC utilizzando due linguaggi: Prolog e Common Lisp. Il progetto è suddiviso in due componenti principali:
1. **Parser**: converte il codice assembly in istruzioni numeriche interpretabili dal simulatore.
2. **Simulatore**: esegue le istruzioni e simula il comportamento del LMC.

### Architettura del LMC
- **Memoria**: 100 celle, ognuna contenente un numero tra 0 e 999.
- **Accumulatore**: registro principale del LMC.
- **Program Counter**: tiene traccia dell'istruzione corrente.
- **Code di Input e Output**: liste che gestiscono i valori in ingresso e uscita.
- **Flag**: indica se l'ultima operazione aritmetica ha superato i limiti.

## Requisiti del Progetto
Il progetto richiede:
- Un **simulatore** che, dato uno stato iniziale della memoria e una sequenza di input, simuli il comportamento del LMC e restituisca l'output.
- Un **assembler** che converta il codice assembly LMC in codice macchina eseguibile dal simulatore.

## Implementazioni

### Prolog
L'implementazione in Prolog include i seguenti predicati principali:

- **`lmc_load/2`**: carica il contenuto di un file assembly in memoria.
  ```prolog
  lmc_load(Filename, Mem).
