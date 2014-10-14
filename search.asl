/* A* implementation to find paths */

{ register_function("search.h",2,"h") }

search( [p(F,[GoalState|Path],Actions) | _], GoalState, Solution) :-
   .reverse(Actions,Solution).

search( [p(F,[State|Path],PrevActions)|Open], GoalState, Solution) :-
   State \== GoalState & //.print("  ** ",State," ",PrevActions) & 
   .findall(
        p(NewF,[NewState,State|Path],[Action|PrevActions]), // new paths 
        ( next_state(State,Action,NewState) & 
          not .member(NewState, [State|Path]) & 
          NewF = search.h(NewState,GoalState) + .length(PrevActions) + 1
        ), 
        Sucs) &
   .concat(Open,Sucs,LT) & 
   .sort(LT,NewOpen) &  // sort by F (H+G), so A*
   //.print("open nodes #",.length(NewOpen)) & //.print(" new open = ",NewOpen) & 
   search( NewOpen, GoalState, Solution).

// heuristic (distance to target + orientation towards the target)
h( s(X,Y,O,G), s(TargetX,TargetY,_,_), H ) :-
   dist(X,Y,TargetX,TargetY,D) & 
   orientation_to_target(h,X,TargetX,O,CostOX) &
   orientation_to_target(v,Y,TargetY,O,CostOY) &
   H = D + CostOX + CostOY.

dist(X1,Y1,X2,Y2,D) :- D = math.abs(X1-X2) + math.abs(Y1-Y2).

orientation_to_target(_,X,X,_,0). // I am in the target
orientation_to_target(h,X,Target,east,0)  :- Target > X. // I am turned to the target
orientation_to_target(h,X,Target,west,0)  :- Target < X.
orientation_to_target(v,Y,Target,north,0) :- Target < Y.
orientation_to_target(v,Y,Target,south,0) :- Target > Y.
orientation_to_target(_,_,_,_,1).


// simulation of what will be the next state in case of any possible action
next_state( s(X,Y,east,G),   forward, s(X+1,Y,east,G))  :- not wall(X+1,Y) & safe(X+1,Y).
next_state( s(X,Y,west,G),   forward, s(X-1,Y,west,G))  :- not wall(X-1,Y) & safe(X-1,Y).
next_state( s(X,Y,north,G),  forward, s(X,Y+1,north,G)) :- not wall(X,Y+1) & safe(X,Y+1).
next_state( s(X,Y,south,G),  forward, s(X,Y-1,south,G)) :- not wall(X,Y-1) & safe(X,Y-1).

next_state( s(X,Y,east,G),  turn(left), s(X,Y,north,G)).
next_state( s(X,Y,north,G), turn(left), s(X,Y,west,G)).
next_state( s(X,Y,west,G),  turn(left), s(X,Y,south,G)).
next_state( s(X,Y,south,G), turn(left), s(X,Y,east,G)).

next_state( s(X,Y,OldOr,G),  turn(right), s(X,Y,NewOr,G)) :- next_state( s(X,Y,NewOr,G), turn(left), s(X,Y,OldOr,G)).
