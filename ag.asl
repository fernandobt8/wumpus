// Agent ag in project wumpus.mas2j

{ include("kb.asl") } 
{ include("search.asl") } 


/* Initial beliefs and rules */

pos(1,1).            // my initial location
orientation(east).   // and orientation 
visited(pos(1, 1), 1).
desire(orientation(east)).   
// scenario borders
// borders(BottomLeftX, BottomLeftY, TopRightX, TopRightY) 
//borders(1, 1, 4, 4). // for R&N


/* Initial goals */

!main.

/* Plans */

+!main
   <- 
   	!update(breeze); // update perception for location 1,1
    !update(stench);
    !kill_wumpus;
    !find(gold);
    !quit_cave.   

+!kill_wumpus : has_shooted.
+!kill_wumpus 
	<- !update_wumpus;
	   !explore;		
	   !kill_wumpus.

+!wumpus_north : has_shooted.
+!wumpus_north 
	: pos(MyX,MyY) & orientation(O) &
      search( [p(0,[s(MyX,MyY,O,no)],[])], s(MyX,MyY+1,_,_), [Action|_]) 
     <-
     .print("doing kill north - ",Action);
     !do(Action);
     !wumpus_north.
     
+!wumpus_south : has_shooted.
+!wumpus_south 
	: pos(MyX,MyY) & orientation(O) &
      search( [p(0,[s(MyX,MyY,O,no)],[])], s(MyX,MyY-1,_,_), [Action|_]) 
     <-
     .print("doing kill south - ",Action);
     !do(Action);
     !wumpus_south. 
     
+!wumpus_east : has_shooted.
+!wumpus_east 
	: pos(MyX,MyY) & orientation(O) &
      search( [p(0,[s(MyX,MyY,O,no)],[])], s(MyX+1,MyY,_,_), [Action|_]) 
     <-
     .print("doing kill east - ",Action);
     !do(Action);
     !wumpus_east.
     
+!wumpus_west : has_shooted.
+!wumpus_west 
	: pos(MyX,MyY) & orientation(O) &
      search( [p(0,[s(MyX,MyY,O,no)],[])], s(MyX-1,MyY,_,_), [Action|_]) 
     <-
     .print("doing kill west - ",Action);
     !do(Action);
     !wumpus_west.   

+!update_wumpus : pos(MyX,MyY) &     wumpus_north(MyX,MyY+1) <- !wumpus_north.
+!update_wumpus : pos(MyX,MyY) & not wumpus_north(MyX,MyY+1) <- +~wumpus_north.
+!update_wumpus : pos(MyX,MyY) &     wumpus_south(MyX,MyY-1) <- !wumpus_south.
+!update_wumpus : pos(MyX,MyY) & not wumpus_south(MyX,MyY-1) <- +~wumpus_south.
+!update_wumpus : pos(MyX,MyY) &     wumpus_east(MyX+1,MyY)  <- !wumpus_east.
+!update_wumpus : pos(MyX,MyY) & not wumpus_east(MyX+1,MyY)  <- +~wumpus_east.
+!update_wumpus : pos(MyX,MyY) &     wumpus_west(MyX-1,MyY)  <- !wumpus_west.
+!update_wumpus : pos(MyX,MyY) & not wumpus_west(MyX-1,MyY)  <- +~wumpus_west.

+!find(gold) : has_gold.
+!find(gold) 
   <- !explore;
      !find(gold).

+!update_direcao
	<- ?pos(X, Y);
	   ?orientation(O);
	   //primeiro deseja continuar em frente
	   ?next_position(X,Y,O,NX,NY);
	   //pega numero de visitas no local que deseja ir
	   ?get_visited(NX,NY,V);
	   if(not wall(NX,NY)){
	   	-+desire(orientation(O));
	   .print("1 -",O);
	   }
	   //vai na direção que visitou menos
	   ?next_orientation(O,O2);
	   ?next_position(X,Y,O2,NX2,NY2);
	   ?get_visited(NX2,NY2,V2);
	   if(V2 < V & not wall(NX2,NY2) | wall(NX,NY) & not wall(NX2,NY2)){
	   	-+desire(orientation(O2));
	   .print("2-",O2);
	   }
	   ?next_orientation(O2,O3);
	   ?next_position(X,Y,O3,NX3,NY3);
	   ?get_visited(NX3,NY3,V3);
	   if(V3 < V2 & not wall(NX3,NY3) | wall(NX2,NY2) & not wall(NX3,NY3)){
	   	-+desire(orientation(O3));
	   .print("3-",O3);
	   }
	   ?next_orientation(O3,O4);
	   ?next_position(X,Y,O4,NX4,NY4);
	   ?get_visited(NX4,NY4,V4);
	   if(V4 < V3 & not wall(NX4,NY4) | wall(NX3,NY3) & not wall(NX3,NY3)){
	   	-+desire(orientation(O4));
	   .print("4-",O4);
	   }
	   
	.

// TODO: não apenas ir reto e virar quando bater ou não achar um local seguro tentar ir tb para locais novos.   
+!explore : pos(X,Y) & orientation(O) & next_state( s(X,Y,O,_), forward, s(NX,NY,_,_)) 
   <-
   !update_direcao; 
   !avanca(NX, NY).
   
//TODO não apenas virar tentar decidir locais novos
+!explore 
   <- .print("no safe place to explore!");
   	  !do(turn(left)).

+!avanca(X, Y)
	<-.print("doing ",X ,"," ,Y);
      forward;
      !espera;
      if (bump) {
      	.print("bump");
         +wall(X,Y);
      } else {
         -+pos(X,Y);
         !increment_visited(X,Y);
         !update(breeze);
         !update(stench);
      }.

+!do(forward)
  	<- shoot;
  	   .print("atirei");
  	   !espera;
	   if(scream){
	   	+killed;
	   	.print("aew morreu fdp");
	   }
	   +has_shooted.

// perform action turn and update beliefs accordingly     
+!do(turn(D))
   <- turn(D);
      !espera; 
      ?orientation(O);
      !update(orientation(O),D).

+!quit_cave
   <- .print("I am leaving the cave!!!");
      !sair;
      climb.

+!sair : pos(1,1).
+!sair : pos(MyX,MyY) & orientation(O) &
      search( [p(0,[s(MyX,MyY,O,no)],[])], s(1,1,_,_), [Action|_])
   <- if(Action = forward){
    	!explore;
    	!sair;
    }else{
		!do(Action);
		!sair;    
    }.

+!espera <- .wait(3000).
 
+glitter 
   <- grab;
      +has_gold.

// update beliefs using a coordinate system
+!increment_visited(X,Y) : visited(pos(X,Y),N) <- -visited(pos(X,Y),N); +visited(pos(X,Y),N+1).
+!increment_visited(X,Y) <- +visited(pos(X,Y), 1).

+?get_visited(X,Y,N) :  visited(pos(X,Y),N).
+?get_visited(X,Y,N) : not visited(pos(X,Y),N) <- +visited(pos(X,Y), 0); ?get_visited(X,Y,N).

+!update(breeze) : not breeze[source(percept)] & pos(X,Y) <- +~breeze(X,Y). 
+!update(breeze) :     breeze[source(percept)] & pos(X,Y) <- +breeze(X,Y).  

+!update(stench) : not stench[source(percept)] & pos(X,Y) <- +~stench(X,Y). 
+!update(stench) :     stench[source(percept)] & pos(X,Y) <- +stench(X,Y).  

+!update(orientation(Old),D) : next_state( s(_,_,Old,_),  turn(D), s(_,_,New,_)) <- -+ orientation(New). // next_state is define in search.asl
