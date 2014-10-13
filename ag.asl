// Agent ag in project wumpus.mas2j

{ include("kb.asl") } 
{ include("search.asl") } 


/* Initial beliefs and rules */

pos(1,1).            // my initial location
orientation(east).   // and orientation 
visited(pos(1, 1), 1).
desire(east).   
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
	<- .print("update w");
	   !update_wumpus;
	   !explore;		
	   !kill_wumpus.

+!wumpus_north : has_shooted.
+!wumpus_north 
     <-!girar_para(north);
     !do(shoot);
     !wumpus_north.
     
+!wumpus_south : has_shooted.
+!wumpus_south 
     <-!girar_para(south);
     !do(shoot);
     !wumpus_south. 
     
+!wumpus_east : has_shooted.
+!wumpus_east 
     <-!girar_para(east);
     !do(shoot);
     !wumpus_east.
     
+!wumpus_west : has_shooted.
+!wumpus_west 
     <-
     !girar_para(west);
     !do(shoot);
     !wumpus_west.   

+!update_wumpus : pos(MyX,MyY) & wumpus_north(MyX,MyY+1) <- !wumpus_north.
+!update_wumpus : pos(MyX,MyY) & wumpus_south(MyX,MyY-1) <- !wumpus_south.
+!update_wumpus : pos(MyX,MyY) & wumpus_east(MyX+1,MyY)  <- !wumpus_east.
+!update_wumpus : pos(MyX,MyY) & wumpus_west(MyX-1,MyY)  <- !wumpus_west.
+!update_wumpus.

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
	   -+best(V);
	   -+desire(O);
	   //vai na direção que visitou menos
	   ?next_orientation(O,O2);
	   ?next_position(X,Y,O2,NX2,NY2);
	   ?get_visited(NX2,NY2,V2);
	   ?best(B);
	   if((V2 < B & not wall(NX2,NY2)) | (wall(NX,NY) & not wall(NX2,NY2))){
	   	-+best(V2);
	   	-+desire(O2);
	   }
	   ?next_orientation(O2,O3);
	   ?next_position(X,Y,O3,NX3,NY3);
	   ?get_visited(NX3,NY3,V3);
	   ?best(B1);
	   if((V3 < B1 & not wall(NX3,NY3)) | (wall(NX,NY) & wall(NX2,NY2) & not wall(NX3,NY3))){
	   	-+best(V3);
	   	-+desire(O3);
	   }
	   ?next_orientation(O3,O4);
	   ?next_position(X,Y,O4,NX4,NY4);
	   ?get_visited(NX4,NY4,V4);
	   ?best(B2);
	   if((V4 < B2 & not wall(NX4,NY4)) | (wall(NX,NY) & wall(NX2,NY2) & wall(NX3,NY3) &  not wall(NX4,NY4))){
	   	-+desire(O4);
	   }.
+!update_best(V, Best).
+!explore 
   <- !update_direcao;
   	  ?desire(D);
   	  !girar_para(D);
      !avanca.

+!girar_para(O) : orientation(O) .
+!girar_para(O) : pos(MyX,MyY) & orientation(O2) &
      next_state(s(MyX,MyY,O2,_), Action, s(MyX,MyY,O,_))
      <- !do(Action); !girar_para(O).
+!girar_para(O) <- !do(turn(left)).

+!avanca : pos(X,Y) & orientation(O) & next_state( s(X,Y,O,_), forward, s(NX,NY,_,_))
	<-.print("doing ",NX ,"," ,NY);
      forward;
      !espera;
      if (bump) {
      	.print("bump");
         +wall(NX,NY);
      } else {
         -+pos(NX,NY);
         !increment_visited(NX,NY);
         !update(breeze);
         !update(stench);
      }.
+!avanca 
	<- .print("not safe girando");
	!do(turn(left));
	!avanca.

+!do(shoot)
  	<- shoot;
  	   .print("atirei-----------------------------------");
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
   <- 
   .print("I am leaving the cave!!!");
      !sair;
      climb.

+!sair : pos(1,1).
+!sair 
   <- ?pos(X,Y);
   if(X < 1){
   		!girar_para(east);
    	!avanca;
    	!sair;
    }
    if(X > 1){
		!girar_para(west);
    	!avanca;
    	!sair;   
    }
    if(Y < 1){
		!girar_para(north);
    	!avanca;
    	!sair;   
    }
    if(Y > 1){
		!girar_para(south);
    	!avanca;
    	!sair;   
    }.
    
+!espera <- .wait(100).
 
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
