%   Albi Alessandro 817769
%   Gallorini Lorenzo 816390


%% Little Man Computer
%%   PROGETTO DEL CORSO DI LINGUAGGI DI PROGRAMMAZIONE
%%   ANNO ACCADEMICO 2018–2019. APPELLO DI GENNAIO 2019.
%%   Il progetto è suddiviso in due Macro-sezioni il parser
%%  e il simulatore.
%%   PARSER
%%  Il parser si occupa di codificare le istruzioni assembly
%%  in un codice numerico interpretabile dal simulatore.




%   PARSER ASSEMBLY 

%   lmc_load(+SrcDest, -List)
%   lmc_load serve per richiamare i metodi che andranno a creare la
%   memoria

lmc_load(Filename, Mem) :-
    process(Filename, L1),
    elimina(L1, L2),
    length(L2, Lun),
    Lun < 101, !,
    parser(L2, L2, Mem1),
    riempi(Mem1, 0, Mem).

%   process(+SrcDest, -List)
%   process si occupa di aprire il file di testo contenente il programma
%   Assembly e crea una lista di stringhe, le quali sono istruzioni

process(Filename, [ String2 | X ]) :-
    open(Filename, read, In),
    read_line_to_string(In, String ),
    process_stream(String, In, X ),
    string_upper(String, String2 ),
    close(In ).

%   process_stream(+String, +Stream, -List)
%   process_stream legge le istruzioni riga per riga dal input e ne crea
%   una lista inserendole come stringhe una alla volta

process_stream(end_of_file, _, []) :- !.

process_stream(_, In, [ String3 | L ]) :-
    read_line_to_string(In, String2),
    string_upper(String2, String3),
    process_stream(String2, In, L).

%   elimina(+List, -List)
%   elimina apllica ricorsivamente il metodo accept/3 ad ogni elemento
%   della prima lista creandone una nuova

elimina([_], []) :- !.

elimina([ X | L ], L1) :-
    string_chars(X, Charlist),
    accept(Charlist, Nospace, q0),
    string_chars(X1, Nospace),
    X1= "", !,
    elimina(L, L1).

elimina([X | L], [X1 | L1]) :-
    string_chars(X, Charlist),
    accept(Charlist, Nospace, q0),
    string_chars(X1, Nospace),
    elimina(L, L1).

%   accept(+List, -List, +Atom)
%   accept è un automa che elimina gli spazi, i commenti e le righe
%   vuote dalle stringhe che contengono le istruzioni

accept([], [], _) :- !.

accept([X | Xs], Y, _) :-
    X= '/', !,
    elimina_commento(Xs, Y).

accept([X | Xs], [' ', X | Y], Q) :-
    delta(Q, X, NewQ),
    Q = q2,
    NewQ = q3,!,
    accept(Xs, Y, NewQ).

accept([X | Xs], [X | Y], Q) :-
    delta(Q, X, NewQ),
    NewQ = q1, !,
    accept(Xs, Y, NewQ).

accept([X | Xs], [X | Y], Q) :-
    delta(Q, X, NewQ),
    Q = q3,
    NewQ = q3, !,
    accept(Xs, Y, NewQ).

accept([X | Xs], Y, Q) :-
    delta(Q, X, NewQ),
    accept(Xs, Y, NewQ).

%   delta(+Atom, +Char, -Atom)
%   delta gestisce le transizioni dell'automa

delta(q0, ' ', q0) :- !.
delta(q0, _, q1).
delta(q1, ' ', q2) :- !.
delta(q1, _, q1).
delta(q2, ' ', q2) :- !.
delta(q2, _, q3).
delta(q3, ' ', q2) :- !.
delta(q3, _, q3).

%   elimina_commento(+List, List)
%   consuma i caratteri della lista fino alla nuova istruzione

elimina_commento([], []).

elimina_commento([_ | Xs], Y) :-
    elimina_commento(Xs, Y).

%   parser(+List, +List, -List)
%   parser chiama ricorsivamente codifica tenendo fissa la memoria
%   scorrendo

parser([], _, []).

parser([H | T], Mem, [H1 | T1]) :-
    codifica(H, Mem, H1),
    parser(T, Mem, T1).

%  codifica(+String, +List, -Numero)
%  codifica si occupa di riconoscere l'istruzione e tradurla in un
%  numero da dare in pasto al LMC

codifica("OUT", _, 902) :- !.

codifica("INP", _, 901) :- !.

codifica("HLT", _, 0) :- !.

codifica("DAT", _, 0) :- !.

codifica(String, _, Num) :-
    to_chars(String, L1, L2),
    L1 = ['D', 'A', 'T'], !,
    append([], L2, Numlist),
    number_codes(Num, Numlist).

codifica(String, Mem, Num) :-
    to_chars(String, L1, L2),
    is_istr(L1), !,
    string_codes(String1, L1),
    codice(String1, Num1),
    eti_o_num(L2, Mem, Num2),
    append([ Num1 ], Num2, Numlist),
    number_codes(Num, Numlist).

codifica(String, Mem, Num) :-
    to_chars(String, _, L2),
    string_chars(String1, L2),
    codifica(String1, Mem, Num).

%   eti_o_num(+List, +List, -List)
%   metodo per riconoscere se si tratta di un etichetta o un numero
eti_o_num([ X ], _, ['0', X]) :-
    char_type(X, digit), !.

eti_o_num([X | Listchar], _, [X | Listchar]) :-
    length(Listchar, 1),
    char_type(X, digit), !,
    char_type(Listchar, digit).

eti_o_num(Listchar, Mem, Num) :-
    trova_eti(Listchar, Mem, 0, Indice),
    number_chars(Indice, Numlist),
    eti_o_num(Numlist, _, Num).

%   trova_eti(+List, +List, +Num, -Num)
%   trova l'indice in cui si trova l'etichetta

trova_eti(Listchar, [X | _], Con, Indice) :-
    to_chars(X, L1, _),
    Listchar = L1, !,
    Indice = Con.

trova_eti(Listchar, [_ | Mem], Con, Indice) :-
    Con1 is Con + 1,
    trova_eti(Listchar, Mem, Con1, Indice).

%   codice(+string, -Num)
%   restituisce il codice dell'struzione

codice("ADD", '1') :- !.

codice("SUB", '2') :- !.

codice("STA", '3') :- !.

codice("LDA", '5') :- !.

codice("BRA", '6') :- !.

codice("BRZ", '7') :- !.

codice("BRP", '8') :- !.

%   is_istr(+List)
%   controlla che la lista di caratteri sia un'istruzione riconosciuta

is_istr(X) :-
    X = ['A', 'D', 'D'], !.
is_istr(X) :-
    X = ['S', 'U', 'B'], !.
is_istr(X) :-
    X = ['S', 'T', 'A'], !.
is_istr(X) :-
    X = ['L', 'D', 'A'], !.
is_istr(X) :-
    X = ['B', 'R', 'A'], !.
is_istr(X) :-
    X = ['B', 'R', 'Z'], !.
is_istr(X) :-
    X = ['B', 'R', 'P'], !.
is_istr(X) :-
    X = ['D', 'A', 'T'].

%   to_chars(+String, -List, -List)
%   trasforma la stringa in due liste di caratteri

to_chars(String, L1, L2) :-
    string_chars(String, X),
    append(L1, [' ' | L2], X),!.

%   riempi(+List, +Num, -List)
%   se le istruzioni sono meno di cento riempe la lista di 0 fino ad
%   arrivare a lunghezza 100

riempi([X | L], Con, [X | L2]) :-
    Con < 100, !,
    Con1 is Con + 1,
    riempi(L, Con1, L2).

riempi([], Con, [0 | L2]) :-
    Con < 100, !,
    Con1 is Con + 1,
    riempi([], Con1, L2).

riempi([], _, []) :- !.

%%  Simulatore

%   Il simulatore si occupa di interpretare il codice macchina ed
%   eseguire le istruzioni

%   lmc_run(+Stream, +List, -List)
%   Questa funzione serve per avviare il programma, per far si che
%   funzioni bisogna dare il path di un file ASSEMBLY valido e
%   una coda di input

lmc_run(Filename, In, Output) :-
    lmc_load(Filename, Mem),
    execution_loop(state(0, 0, Mem, In, [], "noflag"), Output).

%   execution_loop(+State, -State)
%   richiama ricorsivamente one_instruction/2 fermandosi quando
%   riconosce uno halted_state

execution_loop(state(Acc, Pc, Mem, In, Out, Flag), Out1) :- !,
    one_instruction(state(Acc, Pc, Mem, In, Out, Flag), Newstate),
    execution_loop(Newstate, Out1).

execution_loop(halted_state(_Acc, _Pc, _Mem, _In, Out, _Flag), Out) :- !.

%   one_instruction(+State, -State)
%   scorre ricorsivamente la memoria eseguendo le istruzioni

one_instruction(state(Acc, Pc, Mem, In, Out, Flag), Newstate) :- !,
    scorri_mem(Pc, Mem, Op),
    riconosci(Op, Istr),
    switch_case(state(Acc, Pc, Mem, In, Out, Flag), Istr, Newstate).

one_instruction(halted_state(_Acc, _Pc, _Mem, _In, _Out, _Flag), _Newstate) :-
    fail.

%   sccorri_mem(+Num, +List, -Num)
%   estrae l'istruzione che si trova alla posizione indicata dal
%   Program Counter

scorri_mem(Pc, [X | _], X) :-
    Pc = 0, !.
scorri_mem(Pc, [_ | Mem], Op) :-
    Pc1 is Pc - 1,
    scorri_mem(Pc1, Mem, Op).

%   riconosci(+Num, -CharList)
%   controlla che l'istruzione sia corretta e richiama il metodo
%   trasforma/2

riconosci(X, Y) :-
    X >= 0,
    X < 400,
    X < 903,
    X \= 900, !,
    trasforma(X, Y).

riconosci(X, Y) :-
    X >= 0,
    X > 499,
    X < 903,
    X \= 900, !,
    trasforma(X, Y).

%   trasforma(+Num, -CharList)
%   trasforma il numero in una lista di caratteri

trasforma(X, ['0', '0' | Y]) :-
    X < 10, !,
    number_chars(X, Y).

trasforma(X, ['0' | Y]) :-
    X < 100, !,
    number_chars(X, Y).

trasforma(X, Y) :-
    number_chars(X, Y).

%   switch_case(+State, +CharList, -State)
%   La funzione capisce quale operazione effettuare in base al carattere
%   presente nella lista di caratteri

switch_case(state(Acc, Pc, Mem, In, Out, _Flag), ['1' | Cell],
            state( Acc1, Pc1, Mem, In, Out, "flag")) :-
    number_chars(I, Cell),
    scorri_mem(I, Mem, Add),
    Ris is Add + Acc,
    Ris > 999, !,
    Acc1 is Ris mod 1000,
    incrementa_pc(Pc, Pc1).

switch_case(state(Acc, Pc, Mem, In, Out, _Flag), ['1' | Cell],
            state(Acc1, Pc1, Mem, In, Out, "noflag")) :-
    number_chars(I, Cell),
    scorri_mem(I, Mem, Add),
    Acc1 is Add + Acc,
    incrementa_pc(Pc, Pc1), !.

switch_case(state(Acc, Pc, Mem, In, Out, _Flag), ['2' | Cell],
            state(Acc1, Pc1, Mem, In, Out, "flag")) :-
    number_chars(I, Cell),
    scorri_mem(I, Mem, Sott),
    Ris is Acc - Sott,
    Ris < 0, !,
    Acc1 is Ris mod 1000,
    incrementa_pc(Pc, Pc1).

switch_case(state(Acc, Pc, Mem, In, Out, _Flag), ['2' | Cell],
            state(Acc1, Pc1, Mem, In, Out, "noflag")) :-
    number_chars(I, Cell),
    scorri_mem(I, Mem, Sott),
    Acc1 is Acc - Sott,
    incrementa_pc(Pc,Pc1),!.

switch_case(state(Acc, Pc, Mem, In, Out, Flag), ['3' | Cell],
            state(Acc, Pc1, Mem1, In, Out, Flag)) :- !,
    number_chars(I, Cell),
    nth0(I, Mem, _, R),
    nth0(I, Mem1, Acc, R),
    incrementa_pc(Pc, Pc1).

switch_case(state(_Acc, Pc, Mem, In, Out, Flag), ['5' | Cell],
            state(Acc1, Pc1, Mem, In, Out, Flag)) :- !,
    number_chars(I, Cell),
    scorri_mem(I, Mem, Acc1),
    incrementa_pc(Pc, Pc1).

switch_case(state(Acc, _Pc, Mem, In, Out, Flag), ['6' | Cell],
            state(Acc, Pc1, Mem, In, Out, Flag)) :- !,
    number_chars(Pc1, Cell).

switch_case(state(Acc, _Pc, Mem, In, Out, Flag), ['7' | Cell],
            state(Acc, Pc1, Mem, In, Out, Flag)) :-
    Acc = 0, !,
    Flag = "noflag", !,
    number_chars(Pc1, Cell).

switch_case(state(Acc, Pc, Mem, In, Out, Flag), ['7' | _Cell],
            state(Acc, Pc1, Mem, In, Out, Flag)) :- !,
    incrementa_pc(Pc, Pc1).

switch_case(state(Acc, _Pc, Mem, In, Out, Flag), ['8' | Cell],
            state(Acc, Pc1, Mem, In, Out, Flag)) :-
    Flag = "noflag", !,
    number_chars(Pc1, Cell).

switch_case(state(Acc, Pc, Mem, In, Out, Flag), ['8' | _Cell],
            state(Acc, Pc1, Mem, In, Out, Flag)) :- !,
    incrementa_pc(Pc, Pc1).

switch_case(state(_Acc, Pc, Mem, [H | In], Out, Flag), ['9', '0', '1'],
            state(H, Pc1, Mem, In, Out, Flag)) :- !,
    incrementa_pc(Pc, Pc1).

switch_case(state(Acc, Pc, Mem, In, Out, Flag), ['9', '0', '2'],
            state(Acc, Pc1, Mem, In, Out1, Flag)) :- !,
    append(Out, [Acc], Out1),
    incrementa_pc(Pc, Pc1).

switch_case(state(Acc, Pc, Mem, In, Out, Flag), ['0' | _],
            halted_state(Acc, Pc, Mem, In, Out, Flag)) :- !.

%   incrementa_pc(+Num, -Num)
%   incementa il Program Counter ripartendo da zero quando si supera il
%   numero 99

incrementa_pc(X, Y) :-
    X < 99, !,
    Y is X + 1.

incrementa_pc(_, Y) :-
    Y is 0.










































