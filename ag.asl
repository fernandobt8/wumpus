{ include("kb.asl") }
{ include("search.asl") }


/* Cren�as e regras iniciais */

// Agente inicia na posi��o (1,1) voltado para o leste.
// Visitada a posi��o inicial, conta-se o n�mero de vezes que ele passou pelo local procurando pelos objetivos e procurando pela sa�da.
pos(1,1).
orientation(east).
visited(pos(1, 1), 1, 0).
desire(east).

/* Objetivo inicial */

!main.

/* Planos */

// O plano do agente consiste em atualizar as posi��es onde existem as brisas e o fedor do Wumpus, 
// al�m de matar o Wumpus, pegar o ouro e sair da caverna.
+!main
   <-
   	.wait(1000);
   	!update(breeze);
    !update(stench);
    !kill_wumpus;
    !find(gold);
    !quit_cave.

// Testes de posi��o e para tentar matar o Wumpus. Caso o agente j� tenha utilizado sua flecha, nada � feito.
// Do contr�rio, atualiza as cren�as referentes ao posicionamento do Wumpus, explora e tenta mat�-lo.
+!kill_wumpus : has_shooted.
+!kill_wumpus
	<- !update_wumpus;
	   !explore;
	   !kill_wumpus.

// Um teste para cada posi��o que o Wumpus possa estar. Nada � feito se a flecha j� foi utilizada.
// Se o agente recebe o plano que o Wumpus est� na orienta��o O, o agente se volta para O e atira.
+!wumpus_north : has_shooted.
+!wumpus_north
     <-!girar_para(north);
     !do(shoot);
     !wumpus_north.

// O mesmo � feito para as outras posi��es.
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

// Atualiza a cren�a da posi��o do Wumpus e adiciona o plano referente � posi��o.
+!update_wumpus : pos(MyX,MyY) & wumpus_north(MyX,MyY+1) <- !wumpus_north.
+!update_wumpus : pos(MyX,MyY) & wumpus_south(MyX,MyY-1) <- !wumpus_south.
+!update_wumpus : pos(MyX,MyY) & wumpus_east(MyX+1,MyY)  <- !wumpus_east.
+!update_wumpus : pos(MyX,MyY) & wumpus_west(MyX-1,MyY)  <- !wumpus_west.
+!update_wumpus.

// Plano para recuperar o ouro. Caso o agente j� tenha o ouro, nada � feito. Do contr�rio, continua explorando at� encontrar o ouro;
+!find(gold) : has_gold.
+!find(gold)
   <- !explore;
      !find(gold).

// Plano para atualizar a dire��o para a qual o agente est� voltado;
+!update_direcao(O)
	<- ?pos(X, Y);
	   // Primeiro deseja continuar em frente;
	   ?next_position(X,Y,O,NX,NY);
	   // Pega o n�mero de vezes que passou pelo local que deseja ir;
	   ?get_visited(NX,NY,V);
	   -+best(V);
	   -+desire(O);
	   // Vai na dire��o que menos visitou;
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

// Plano b�sico para o agente explorar o mapa.
// Testa a orienta��o e tenta se voltar para a mesma. Se existir o desejo de se virar para outra posi��o, ele o faz e avan�a uma posi��o;
+!explore
   <- ?orientation(O);
      !update_direcao(O);
   	  ?desire(D);
   	  !girar_para(D);
      !avanca.

// Plano para mudar a dire��o. Caso o plano indique uma dire��o que o agente j� quer, nada � feito.
// Sen�o, recupera o pr�ximo estado e se volta para a nova dire��o; 
+!girar_para(O) : orientation(O).
+!girar_para(O) : pos(MyX,MyY) & orientation(O2) &
      next_state(s(MyX,MyY,O2,_), Action, s(MyX,MyY,O,_))
      <- !do(Action);
      	 !girar_para(O).
+!girar_para(O)
	  <- !do(turn(left));
	  	 !girar_para(O).

// Plano para avan�ar uma posi��o.
// Se o agente receber a percep��o de um muro, � adicionada essa cren�a para aquela posi��o (bump);
// Sen�o, � incrementado o n�mero de vezes que o agente passou por aquela posi��o e atualiza-se as percep��es de brisa e fedor;
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

// Caso a posi��o �frente n�o seja segura, o agente se volta para a esquerda e tenta avan�ar;
+!avanca
	<- .print("N�o seguro. Girando...");
	!do(turn(left));
	!avanca.

// Plano para atirar a flecha no Wumpus;
// Se o agente receber a percep��o de um grito, isso significa que o Wumpus foi atingido e essa cren�a � adicionada;
+!do(shoot)
  	<- shoot;
  	   .print("Atirando a flecha...");
  	   !espera;
	   if(scream){
	   		+killed;
	   		.print("Acertou o Wumpus!!!");
	   }
	   +has_shooted.

// Plano para mudar a dire��o a qual o agente est� voltado.
// A a��o de virar-se � executada;
+!do(turn(D))
   <- turn(D);
      !espera;
      ?orientation(O);
      !update(orientation(O),D).

// Plano para sair da caverna.
// � adicionada a cren�a e o plano "sair" � criado. Ao voltar, realiza a a��o "climb" e o agente est� fora da caverna (com la plata)!
+!quit_cave
   <- +saindo;
      .print("I am leaving the cave!!!");
      !sair;
      climb.

// O agente recebe o plano de sair da caverna. A sa�da sempre est� na posi��o (1,1).
// Enquanto o agente n�o estiver na posi��o (1,1), ele tentar� se mover na dire��o da sa�da, dando prioridade para a dimens�o na qual o agente 
// est� mais longe de alcan�ar (DX e DY);
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

// Se o agente receber a percep��o de brilho, coleta o ouro e adiciona essa cren�a � sua cole��o de cren�as; 
+glitter
   <- grab;
   	  .print("$$$ !!!O agente achou la plata!!! $$$");
      +has_gold.

// Planos para incrementar o n�mero de vezes que o agente passou por uma determinada posi��o.
// Estes planos s�o utilizados enquanto o agente est� explorando a caverna em busca do Wumpus e do ouro;
+!increment_visited(X,Y) : not saindo & visited(pos(X,Y),N,NS) <- -visited(pos(X,Y),N,NS); +visited(pos(X,Y),N+1,NS).
+!increment_visited(X,Y) : not saindo <- +visited(pos(X,Y), 1, 0).

// Planos para incrementar o n�mero de vezes que o agente passou por uma determinada posi��o.
// Estes planos s�o utilizados enquanto o agente est� explorando a caverna em busca da sa�da;
+!increment_visited(X,Y) : saindo & visited(pos(X,Y),N,NS) <- -visited(pos(X,Y),N,NS); +visited(pos(X,Y),N,NS+1).
+!increment_visited(X,Y) : saindo <- +visited(pos(X,Y), 0, 1).

// Recupera o n�mero de vezes que o agente passou por uma posi��o enquanto procura pelo Wumpus ou pelo ouro;
+?get_visited(X,Y,N) : not saindo & visited(pos(X,Y),N,NS).
+?get_visited(X,Y,N) : not saindo & not visited(pos(X,Y),N,NS) <- +visited(pos(X,Y), 0, 0); ?get_visited(X,Y,N).

// Recupera o n�mero de vezes que o agente passou por uma posi��o enquanto procura pela sa�da da caverna;
+?get_visited(X,Y,NS) : saindo & visited(pos(X,Y),N,NS).
+?get_visited(X,Y,NS) : saindo & not visited(pos(X,Y),N,NS) <- +visited(pos(X,Y), 0, 0); ?get_visited(X,Y,NS).

// Plano para atualizar as cren�as do agente a respeito da exist�ncia ou n�o de brisa em uma determinada posi��o;
+!update(breeze) : not breeze[source(percept)] & pos(X,Y) <- +~breeze(X,Y). 
+!update(breeze) :     breeze[source(percept)] & pos(X,Y) <- +breeze(X,Y).  

// Plano para atualizar as cren�as do agente a respeito da exist�ncia ou n�o do fedor do Wumpus em uma determinada posi��o;
+!update(stench) : not stench[source(percept)] & pos(X,Y) <- +~stench(X,Y). 
+!update(stench) :     stench[source(percept)] & pos(X,Y) <- +stench(X,Y).  

// Plano para atualizar a orienta��o do agente;
+!update(orientation(Old),D) : next_state( s(_,_,Old,_),  turn(D), s(_,_,New,_)) <- -+ orientation(New).
