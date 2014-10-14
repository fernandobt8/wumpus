{ include("kb.asl") }
{ include("search.asl") }


/* Crenças e regras iniciais */

// Agente inicia na posição (1,1) voltado para o leste.
// Visitada a posição inicial, conta-se o número de vezes que ele passou pelo local procurando pelos objetivos e procurando pela saída.
pos(1,1).
orientation(east).
visited(pos(1, 1), 1, 0).
desire(east).

/* Objetivo inicial */

!main.

/* Planos */

// O plano do agente consiste em atualizar as posições onde existem as brisas e o fedor do Wumpus, 
// além de matar o Wumpus, pegar o ouro e sair da caverna.
+!main
   <-
   	.wait(1000);
   	!update(breeze);
    !update(stench);
    !kill_wumpus;
    !find(gold);
    !quit_cave.

// Testes de posição e para tentar matar o Wumpus. Caso o agente já tenha utilizado sua flecha, nada é feito.
// Do contrário, atualiza as crenças referentes ao posicionamento do Wumpus, explora e tenta matá-lo.
+!kill_wumpus : has_shooted.
+!kill_wumpus
	<- !update_wumpus;
	   !explore;
	   !kill_wumpus.

// Um teste para cada posição que o Wumpus possa estar. Nada é feito se a flecha já foi utilizada.
// Se o agente recebe o plano que o Wumpus está na orientação O, o agente se volta para O e atira.
+!wumpus_north : has_shooted.
+!wumpus_north
     <-!girar_para(north);
     !do(shoot);
     !wumpus_north.

// O mesmo é feito para as outras posições.
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

// Atualiza a crença da posição do Wumpus e adiciona o plano referente à posição.
+!update_wumpus : pos(MyX,MyY) & wumpus_north(MyX,MyY+1) <- !wumpus_north.
+!update_wumpus : pos(MyX,MyY) & wumpus_south(MyX,MyY-1) <- !wumpus_south.
+!update_wumpus : pos(MyX,MyY) & wumpus_east(MyX+1,MyY)  <- !wumpus_east.
+!update_wumpus : pos(MyX,MyY) & wumpus_west(MyX-1,MyY)  <- !wumpus_west.
+!update_wumpus.

// Plano para recuperar o ouro. Caso o agente já tenha o ouro, nada é feito. Do contrário, continua explorando até encontrar o ouro;
+!find(gold) : has_gold.
+!find(gold)
   <- !explore;
      !find(gold).

// Plano para atualizar a direção para a qual o agente está voltado;
+!update_direcao(O)
	<- ?pos(X, Y);
	   // Primeiro deseja continuar em frente;
	   ?next_position(X,Y,O,NX,NY);
	   // Pega o número de vezes que passou pelo local que deseja ir;
	   ?get_visited(NX,NY,V);
	   -+best(V);
	   -+desire(O);
	   // Vai na direção que menos visitou;
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

// Plano básico para o agente explorar o mapa.
// Testa a orientação e tenta se voltar para a mesma. Se existir o desejo de se virar para outra posição, ele o faz e avança uma posição;
+!explore
   <- ?orientation(O);
      !update_direcao(O);
   	  ?desire(D);
   	  !girar_para(D);
      !avanca.

// Plano para mudar a direção. Caso o plano indique uma direção que o agente já quer, nada é feito.
// Senão, recupera o próximo estado e se volta para a nova direção; 
+!girar_para(O) : orientation(O).
+!girar_para(O) : pos(MyX,MyY) & orientation(O2) &
      next_state(s(MyX,MyY,O2,_), Action, s(MyX,MyY,O,_))
      <- !do(Action);
      	 !girar_para(O).
+!girar_para(O)
	  <- !do(turn(left));
	  	 !girar_para(O).

// Plano para avançar uma posição.
// Se o agente receber a percepção de um muro, é adicionada essa crença para aquela posição (bump);
// Senão, é incrementado o número de vezes que o agente passou por aquela posição e atualiza-se as percepções de brisa e fedor;
+!avanca : pos(X,Y) & orientation(O) & next_state( s(X,Y,O,_), forward, s(NX,NY,_,_))
	<-.print("doing ",NX ,"," ,NY);
      forward;
      !espera;
      if (bump) {
      	.print("Bump! Encontrou um muro...");
         +wall(NX,NY);
      } else {
         -+pos(NX,NY);
         !increment_visited(NX,NY);
         !update(breeze);
         !update(stench);
      }.

// Caso a posição àfrente não seja segura, o agente se volta para a esquerda e tenta avançar;
+!avanca
	<- .print("Não seguro. Girando...");
	!do(turn(left));
	!avanca.

// Plano para atirar a flecha no Wumpus;
// Se o agente receber a percepção de um grito, isso significa que o Wumpus foi atingido e essa crença é adicionada;
+!do(shoot)
  	<- shoot;
  	   .print("Atirando a flecha...");
  	   !espera;
	   if(scream){
	   		+killed;
	   		.print("Acertou o Wumpus!!!");
	   }
	   +has_shooted.

// Plano para mudar a direção a qual o agente está voltado.
// A ação de virar-se é executada;
+!do(turn(D))
   <- turn(D);
      !espera;
      ?orientation(O);
      !update(orientation(O),D).

// Plano para sair da caverna.
// É adicionada a crença e o plano "sair" é criado. Ao voltar, realiza a ação "climb" e o agente está fora da caverna (com la plata)!
+!quit_cave
   <- +saindo;
      .print("I am leaving the cave!!!");
      !sair;
      climb.

// O agente recebe o plano de sair da caverna. A saída sempre está na posição (1,1).
// Enquanto o agente não estiver na posição (1,1), ele tentará se mover na direção da saída, dando prioridade para a dimensão na qual o agente 
// está mais longe de alcançar (DX e DY);
+!sair : pos(1,1).
+!sair
   <- ?pos(X,Y);
   DX = math.abs(X-1);
   DY = math.abs(Y-1);

   if(DX <= DY){
   		if(Y < 1){
			!update_direcao(north);
		}else {
			if(Y > 1){
				!update_direcao(south);
			}
		}
   }else{
   		if(X < 1){
   			!update_direcao(east);
    	}else {
    		if(X > 1){
				!update_direcao(west);
    		}
    	}
   }

   ?desire(D);
   !girar_para(D);
   !avanca;
   !sair;.

+!espera <- .wait(100).

// Se o agente receber a percepção de brilho, coleta o ouro e adiciona essa crença à sua coleção de crenças; 
+glitter
   <- grab;
   	  .print("$$$ !!!O agente achou la plata!!! $$$");
      +has_gold.

// Planos para incrementar o número de vezes que o agente passou por uma determinada posição.
// Estes planos são utilizados enquanto o agente está explorando a caverna em busca do Wumpus e do ouro;
+!increment_visited(X,Y) : not saindo & visited(pos(X,Y),N,NS) <- -visited(pos(X,Y),N,NS); +visited(pos(X,Y),N+1,NS).
+!increment_visited(X,Y) : not saindo <- +visited(pos(X,Y), 1, 0).

// Planos para incrementar o número de vezes que o agente passou por uma determinada posição.
// Estes planos são utilizados enquanto o agente está explorando a caverna em busca da saída;
+!increment_visited(X,Y) : saindo & visited(pos(X,Y),N,NS) <- -visited(pos(X,Y),N,NS); +visited(pos(X,Y),N,NS+1).
+!increment_visited(X,Y) : saindo <- +visited(pos(X,Y), 0, 1).

// Recupera o número de vezes que o agente passou por uma posição enquanto procura pelo Wumpus ou pelo ouro;
+?get_visited(X,Y,N) : not saindo & visited(pos(X,Y),N,NS).
+?get_visited(X,Y,N) : not saindo & not visited(pos(X,Y),N,NS) <- +visited(pos(X,Y), 0, 0); ?get_visited(X,Y,N).

// Recupera o número de vezes que o agente passou por uma posição enquanto procura pela saída da caverna;
+?get_visited(X,Y,NS) : saindo & visited(pos(X,Y),N,NS).
+?get_visited(X,Y,NS) : saindo & not visited(pos(X,Y),N,NS) <- +visited(pos(X,Y), 0, 0); ?get_visited(X,Y,NS).

// Plano para atualizar as crenças do agente a respeito da existência ou não de brisa em uma determinada posição;
+!update(breeze) : not breeze[source(percept)] & pos(X,Y) <- +~breeze(X,Y). 
+!update(breeze) :     breeze[source(percept)] & pos(X,Y) <- +breeze(X,Y).  

// Plano para atualizar as crenças do agente a respeito da existência ou não do fedor do Wumpus em uma determinada posição;
+!update(stench) : not stench[source(percept)] & pos(X,Y) <- +~stench(X,Y). 
+!update(stench) :     stench[source(percept)] & pos(X,Y) <- +stench(X,Y).  

// Plano para atualizar a orientação do agente;
+!update(orientation(Old),D) : next_state( s(_,_,Old,_),  turn(D), s(_,_,New,_)) <- -+ orientation(New).
