;;;;   Little Man Computer

;;   PROGETTO DEL CORSO DI LINGUAGGI DI PROGRAMMAZIONE
;;   ANNO ACCADEMICO 2018–2019. APPELLO DI GENNAIO 2019.
;;   Il progetto è suddiviso in due Macro-sezioni il parser
;;   e il simulatore.

;;;   PARSER

;;   Il parser si occupa di codificare le istruzioni assembly
;;   in un codice numerico interpretabile dal simulatore.

;;;   Definzioni delle funzioni

;;   lmc-load\1 (string) => list
;;   lmc-load serve per richiamare i metodi che andranno a creare
;;   la memoria e la restituirà nel nome della funzione

(defun lmc-load (filename)
	(riempi-mem (start (leggi-file filename))))

;;   leggi-file\1 (string) => list
;;   leggi-file serve per richiamare i metodi che andranno a leggere
;;   il file dato come input e restituirà una lista

(defun leggi-file (filename)
	(trasforma (mapcar 'convert-string (read-all-lines filename))))

;;   read-all-lines\1 (string) => list
;;   questa funzione va ad aprire il file e passa l'oggetto stream a
;;   read-all-lines-helper

(defun read-all-lines (filename)
	(with-open-file (f filename :direction :input)
		(read-all-lines-helper f)))

;;   read-all-lines-helper\1 (stream) => list
;;   questa funzione va a leggere riga per riga il file

(defun read-all-lines-helper (stream)
	(let ((line (read-line stream nil nil)))
		(when line (cons line (read-all-lines-helper stream)))))

;;   convert-string\1 (string) => list
;;   Parsing di un valore salvato in una stringa

(defun convert-string (str)
	(when (string/= str "")
		(multiple-value-bind (value num-chars) (read-from-string str nil)
			(when (not (equal value '//))
				(cons value (convert-string (subseq str num-chars)))))))

;;   trasforma\1 (list) => list
;;   Questa funzione la utilizziamo per eliminare gli eventuali elementi
;;   "sporchi" che si potrebbero trovare nella lista

(defun trasforma (l1)
	(cond
		((null l1) nil)
		((eq (car l1) 'nil) (trasforma (cdr l1)))
		((eq (caar l1) 'nil) (trasforma (cdr l1)))
		(t (cons (car l1) (trasforma (cdr l1))))))

;;   start\1 (list) => list
;;   start serve per richiamare i metodi che andranno a a codificare la
;;   memoria

(defun start (input)
  (digit-to-num (crea-mem input 0) 0))

;;   crea-mem\1 (list number) => list
;;   Questa funzione va a passare elemento per elemento (della lista)
;;   al parser viene restituita la lista con le memorica, codificata con
;;   il codice mnemonico

(defun crea-mem (input counter)
	(if (not (eq (nth counter input) 'NIL))
		(cons
			(parse (nth counter input) input)
			(crea-mem input (+ counter 1)))))

;;   crea-mem\2 (list list) => list
;;   La funzione parse serve per codificare le istruzioni da codice mnemonico
;;   a codice numerico.In caso ci sia un etichetta dopo l'istruzione viene
;;   viene richiamata la funzione eti, se è posta prima dell'istrione invece
;;   viene semplicemente ignorata

(defun parse (istr input)
    (cond
		((eq (car istr) 'ADD)
			(append '(1) (if (numberp (cdr istr))
							(cdr istr)
						(eti input (cdr istr) 0))))

		((eq (car istr) 'SUB)
			(append '(2) (if (numberp (cdr istr))
							(cdr istr)
						(eti input (cdr istr) 0))))

		((eq (car istr) 'STA)
			(append '(3) (if (numberp (cdr istr))
							(cdr istr)
						(eti input (cdr istr) 0))))

		((eq (car istr) 'LDA)
			(append '(5) (if (numberp (cdr istr))
							(cdr istr)
						(eti input (cdr istr) 0))))

		((eq (car istr) 'BRA)
			(append '(6) (if (numberp (cdr istr))
							(cdr istr)
						 (eti input (cdr istr) 0))))

		((eq (car istr) 'BRZ)
			(append '(7) (if (numberp (cdr istr))
				(cdr istr)
				(eti input (cdr istr) 0))))

		((eq (car istr) 'BRP)
			(append '(8) (eti input (cdr istr) 0)))

		((eq (car istr) 'HLT) '(0))

		((eq (car istr) 'INP) '(901))

		((eq (car istr) 'OUT) '(902))

		((eq (car istr) 'DAT)
			(cond ((eq (cadr istr) 'nil) (list '0))
				((numberp (cadr istr)) (cdr istr))
				(T (error "l'istruzione DAT non accetta ~S" (cadr istr)))))

		(t (parse (cdr istr) input))))

;;   eti\3 (list list number) => number
;;   Eti serve per identificare la posizione di una etichetta nella memoria

(defun eti (input istr counter)
		(cond
			((eq 'NIL (nth counter input))  (error "~S non esiste" (car istr)))
			((eq (car istr) (car (nth counter input))) (list counter))
			(t (eti input istr (+ counter 1)))))

;;   digit-to-num\2 (list number) => list
;;   serve per unificare il codice dell'operazione con la cella e restituire
;;   il numero corrispondente ((4 56) (2 50)) => (456 250)

(defun digit-to-num (input counter)
	(when (not (eq (nth counter input) 'NIL))
		(cons
      (if (not(eq (cadr (nth counter input)) 'NIL))
        (+ (* (car (nth counter input)) 100) (cadr (nth counter input)))
        (car (nth counter input)))
      (digit-to-num input (+ counter 1)))))

;;   riempi-mem\1 (mem) => list
;;   La funzione va a riempire quella parte di memoria che non è stata
;;   istanziata con gli 0

(defun riempi-mem (mem)
	(if (<= (length mem) 100)
		(append mem (make-list (- 100 (length mem)) :initial-element 0))
 (error "Il file contiene più di cento istruzioni" )))

;;;   Simulatore

;;   Il simulatore si occupa di interpretare il codice macchina ed
;;   eseguire le istruzioni

;;   lmc-run\2 (string list) => list
;;   Questa funzione serve per avviare il programma, per far si che
;;   funzioni bisogna dare il path di un file ASSEMBLY valido e
;;   una coda di input

(defun lmc-run (filename in)
	(execution-loop
		(first-state :acc 0 :pc 0 :mem
			(lmc-load filename) :in in :out () :flag 'noflag)))

;;   first-state (&key acc pc mem in out flag) => list
;;   La funzione genera la lista stato

(defun first-state (&key acc pc mem in out flag)
	(list 'state :acc acc :pc pc :mem mem :in in :out out :flag flag))

;;   execution_loop\1 (list) => list
;;   La funzione va a richiamare ricorsivamente one-instruction finchè non
;;   troviamo halted_state, in quel caso restituiamo la coda di output

(defun execution-loop (lstate)
	(cond (  (and (>= (get-acc lstate) 0)  (eq (car lstate) 'state))
							(execution-loop(one-instruction lstate)) )
		  (t (get-out lstate))))

;;   one_instruction\1 (list) => list
;;   La funzione capisce quale operazione effettuare in base al codice numerico
;;   e richiama la funzione adibita a quella determinata operazione

(defun one-instruction (lstate)
	(cond	((< (get-istr lstate) 100)
					(setf (car lstate) 'halted-state ) lstate)

			((and (>= (get-istr lstate) 100) (< (get-istr lstate) 200))
				(add-lstate lstate))

			((and (>= (get-istr lstate) 200) (< (get-istr lstate) 300))
				(sott-lstate lstate))

			((and (>= (get-istr lstate) 300) (< (get-istr lstate) 400))
				(store lstate))

			((and (>= (get-istr lstate) 500) (< (get-istr lstate) 600))
				(lda lstate))

			((and (>= (get-istr lstate) 600) (< (get-istr lstate) 700))
				(bra lstate))

			((and (>= (get-istr lstate) 700) (< (get-istr lstate) 800))
				(branch-if-zero lstate))

			((and (>= (get-istr lstate) 800) (< (get-istr lstate) 900))
				(branch-if-pos lstate))

			((eq (get-istr lstate) 901)
				(in lstate))

			((eq (get-istr lstate) 902)
				(out lstate))

			(t (error "l'istruzione DAT non può accettare ~S" lstate))))

;;   get-istr\1 (list) => number
;;   La funzione va a trovare l'istruzione che stiamo eseguendo in base al PC

(defun get-istr (lstate)
	(nth (get-pc lstate) (get-mem lstate)))

;;   add-lstate\1 (list) => list
;;   La funzione controlla se l'operazione assembly di somma
;;   ha generato un overflow

(defun add-lstate (lstate)
	(when (> (somma lstate) 999)
			(set-flag lstate 'flag))
	(set-acc lstate (mod (somma lstate) 1000))
	(set-pc lstate (+ (get-pc lstate) 1))
	lstate)

;;   somma\1 (list) => list
;;   Effettua la somma tra l'accumulatore e la cella di memoria

(defun somma (lstate)
	(+ (get-acc lstate) (nth (- (get-istr lstate) 100) (get-mem lstate))))

;;   sott-lstate\1 (list) => list
;;   La funzione controlla se l'operazione di sottrazione genera un overflow

(defun sott-lstate (lstate)
	(when (< (diff lstate) 0)
			(set-flag lstate 'flag))
	(set-acc lstate (mod (diff lstate) 1000))
	(set-pc lstate (+ (get-pc lstate) 1))
	lstate)

;;   diff\1 (list) => list
;;   Effettua la differenza tra l'accumulatore e la cella di memoria

(defun diff (lstate)
	(- (get-acc lstate) (nth (- (get-istr lstate) 200) (get-mem lstate))))

;;  store\1 (list) => list
;;  Effettua una operazione di store sulla lista data in input

(defun store (lstate)
	(set-mem lstate (- (get-istr lstate) 300) (get-acc lstate))
	(set-pc lstate (+ (get-pc lstate) 1))
	lstate)

;;  lda\1 (list) => list
;;  effettua una operazione di load sulla lista data in input

(defun lda (lstate)
	(set-acc lstate (get-cella lstate (- (get-istr lstate) 500)))
	(set-pc lstate (+ (get-pc lstate) 1))
	lstate)

;;  bra\1 (list) => list
;;  effettua una operazione di branch sulla lista data in input

(defun bra (lstate)
	(set-pc lstate (- (get-istr lstate) 600))
	lstate)

;;  branch-if-zero\1 (list) => list
;;  effettua una operazione di branch-if-zero sulla lista data in input

(defun branch-if-zero (lstate)
	(if (and (zerop (get-acc lstate)) (eq (get-flag lstate) 'noflag))
			(set-pc lstate (- (get-istr lstate) 700))
		(set-pc lstate (+ (get-pc lstate) 1)))
	lstate)

;;  branch-if-pos\1 (list) => list
;;  effettua una operazione di branch-if-pos sulla lista data in input

(defun branch-if-pos (lstate)
	(if (eq (get-flag lstate) 'noflag)
			(set-pc lstate (- (get-istr lstate) 800))
		(set-pc lstate (+ (get-pc lstate) 1)))
	lstate)

;;  in\1 (list) => list
;;  effettua una operazione di input sulla lista data in input

(defun in (lstate)
	(set-acc lstate (car (get-in lstate)))
	(set-in lstate (cdr (get-in lstate)))
	(set-pc lstate (+ (get-pc lstate) 1))
	lstate)

;;  out\1 (list) => list
;;  effettua una operazione di output sulla lista data in input

(defun out (lstate)
	(set-out lstate (get-acc lstate))
	(set-pc lstate (+ (get-pc lstate) 1))
	lstate)

;;;   Getter and Setter
;;   Se richiamati correttamente restituiscono o reimpostano
;;   l'elelemento della lista scelta

(defun get-acc (lstate)
	(getf (cdr lstate) :acc))

(defun set-acc (lstate x)
	(setf (getf (cdr lstate) :acc) x))

(defun get-pc (lstate)
	(getf (cdr lstate) :pc))

(defun set-pc (lstate x)
	(setf (getf (cdr lstate) :pc) x))

(defun get-mem (lstate)
	(getf (cdr lstate) :mem))

(defun get-cella (lstate cella)
	(nth cella (get-mem lstate)))

(defun set-mem (lstate cella x)
		(setf (nth cella (get-mem lstate)) x))

(defun get-in (lstate)
	(getf (cdr lstate) :in))

(defun set-in (lstate lista)
	(setf (getf (cdr lstate) :in) lista))

(defun get-out (lstate)
	(getf (cdr lstate) :out))

(defun set-out (lstate x)
	(setf (getf (cdr lstate) :out) (append (get-out lstate) (list x))))

(defun get-flag (lstate)
	(getf (cdr lstate) :flag))

(defun set-flag (lstate x)
	(setf (getf (cdr lstate) :flag) x))
