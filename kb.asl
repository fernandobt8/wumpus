
/* rules for theoretical reasoning */

/* auxiliary rules */
adjacent(X,Y,X+1,Y).
adjacent(X,Y,X-1,Y).
adjacent(X,Y,X,Y+1).
adjacent(X,Y,X,Y-1).

next_orientation(north,east).
next_orientation(east,south).
next_orientation(south,west).
next_orientation(west,north).

next_position(north, X, Y).

visited(X,Y) :- ~breeze(X,Y) | breeze(X,Y).

/* safe place */
safe(X,Y) :- ~pit(X,Y) & (~wumpus(X,Y) | killed).

/* pit inference */
~pit(X,Y) :- ~breeze(X,Y).
~pit(X,Y) :- adjacent(X,Y,X2,Y2) & ~breeze(X2,Y2).
~pit(X,Y) :- wall(X,Y).

//     p1
// p2  b   p4
//     p3
// p1 <- b & ~p2 & ~p3 & ~p4
// ...
// p4 <- b & ~p1 & ~p3 & ~p4
pit(X,Y) :- breeze(X,Y-1) & ~pit(X-1,Y-1) & ~pit(X,Y-2) & ~pit(X+1,Y-1). // p1
pit(X,Y) :- breeze(X+1,Y) & ~pit(X+2,Y) & ~pit(X+1,Y-1) & ~pit(X+1,Y+1). // p2
pit(X,Y) :- breeze(X,Y+1) & ~pit(X-1,Y+1) & ~pit(X,Y+2) & ~pit(X+1,Y+1). // p3
pit(X,Y) :- breeze(X-1,Y) & ~pit(X-2,Y) & ~pit(X-1,Y-1) & ~pit(X-1,Y+1). // p4

might_be_pit(X,Y) :-  adjacent(X,Y,X2,Y2) & breeze(X2,Y2). // might have a pit, could be useful to select an action if no ok location is available

   
/* wumpus inference */
~wumpus(X,Y) :- ~stench(X,Y).
~wumpus(X,Y) :- adjacent(X,Y,X2,Y2) & ~stench(X2,Y2).
~wumpus(X,Y) :- wall(X,Y).

wumpus_north(X,Y) :- stench(X,Y-1) & ~wumpus(X-1,Y-1) & ~wumpus(X,Y-2) & ~wumpus(X+1,Y-1). // p1
wumpus_west(X,Y) :- stench(X+1,Y) & ~wumpus(X+2,Y) & ~wumpus(X+1,Y-1) & ~wumpus(X+1,Y+1). // p2
wumpus_east(X,Y) :- stench(X,Y+1) & ~wumpus(X-1,Y+1) & ~wumpus(X,Y+2) & ~wumpus(X+1,Y+1). // p3
wumpus_south(X,Y) :- stench(X-1,Y) & ~wumpus(X-2,Y) & ~wumpus(X-1,Y-1) & ~wumpus(X-1,Y+1). // p4

