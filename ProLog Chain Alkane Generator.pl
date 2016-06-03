% Author: Youssuf Radi, Mostafa El-assar, Zyad Zakaria , T12
% Date: 3/24/2015

straight_chain_alkane(1,carb(h,h,h,h)).

straight_chain_alkane(N,A):-
                                N > 1,
                                N2 is N-1,
                                straight_chain_helper(N2,[crab(h,h,h,c)],A).

straight_chain_helper(1,A,T):-
                            append(A,[carb(c,h,h,h)],T).

straight_chain_helper(N,A,T):-
                                N>1,
                                append(A,[carb(c,h,h,c)],T1),
                                N1 is N-1,
                                straight_chain_helper(N1,T1,T).
branch_name(0,h).

branch_name(S,N):-
                  S>0,
                  HS is S*2+1,
                  atomic_list_concat([c,S,h,HS],N).


add_branch_to_carbon(InC, BSize, ResC):-
                                        InC = carb(c,h,h,c),
                                        branch_name(BSize,Z),
                                        ResC =   carb(c,Z,h,c).

add_branch_to_carbon(InC, BSize, ResC):-
                                        InC = carb(c,X,h,c),
                                        X \= h,
                                        branch_name(BSize,Z),
                                        ResC =   carb(c,X,Z,c).

generate(S,_,S).

generate(S,E,X):-
                S < E,
                I1 is S + 1,
                generate(I1,E,X).

break_down(1,[1]).

break_down(0,[]) .

break_down(N,L):-
                 N>1,
                 break_down(N,1,L).
                 
break_down(N,X,L):-
                   N>0,
                   generate(X,N,L2),
                   L = [L2|T],
                   N1 is N-L2,
                   break_down(N1,L2,T).
                   
break_down(0,_,[]).

edit_list(Pos,Val,List,R):-
                    length(List,B),
                    B \=Pos-1,
                    nth0(Pos,List,L1,R1),
                    Pos >= Val,
                    F is B-Pos-1,
                    F >= Val,
                    add_branch_to_carbon(L1,Val,Edit),
                    nth0(Pos,R,Edit,R1).
                    
permutate(Val,List,R):-
                         length(List,N1),
                         generate(1,N1,Pos),
                         edit_list(Pos,Val,List,R).

permutate_list([],X,X).

permutate_list([0],X,X).
                         
permutate_list([H|T],List,R):-
                              H>0,
                              permutate(H,List,R1),
                              permutate_list(T,R1,R).

permutate_list_remove(A,L,X):-
                            setof(B,permutate_list(A,L,B),X1),
                            member(X,X1).

length_chain(N,X,Y):-
                     generate(1,N,K),
                     length_chain(N,K,X,Y).

length_chain(N,K,X,Y):-
                       X is N-K,
                       X>2,
                       Y is K.

branched_alkane(N,BA):-
                       N>3,
                       length_chain(N,X,Y),
                       branched_alkane(X,Y,BA).

branched_alkane(X,Y,BA):-
                         straight_chain_alkane(X,List),
                         break_down(Y,L1),
                         permutate_list_remove(L1,List,BA).

reverse_middle(List,R):-
                        length(List,B),
                        nth1(B,List,L1,R1),
                        nth1(1,R1,L2,R2),
                        reverse(R2,R3),
                        append([L2],R3,R4),
                        nth1(B,R,L1,R4) .

isomers(N,[A]):-
                N < 4,
                straight_chain_alkane(N,A).
                        
isomers(N,[A2|A]):-
              N > 3,
              setof(R,branched_alkane(N,R),A1),
              straight_chain_alkane(N,A2),
              duplicate_remove(A1,A).

duplicate_remove([],[]).

duplicate_remove([H|T],[H|A]):-
                               reverse_middle(H,R),
                               \+member(R,T),
                               duplicate_remove(T,A).

duplicate_remove([H|T],A):-
                               reverse_middle(H,R),
                               member(R,T),
                               duplicate_remove(T,A).