/* Regras de inferência */

// Teste de adjacência para as posições;
adjacent(X,Y,X+1,Y).
adjacent(X,Y,X-1,Y).
adjacent(X,Y,X,Y+1).
adjacent(X,Y,X,Y-1).

// Sequência de orientações a ser seguida;
next_orientation(north,east).
next_orientation(east,south).
next_orientation(south,west).
next_orientation(west,north).

next_position(X, Y, north,X ,Y+1).
next_position(X, Y, south,X ,Y-1).
next_position(X, Y, east,X+1 ,Y).
next_position(X, Y, west,X-1 ,Y).

visited(X,Y) :- ~breeze(X,Y) | breeze(X,Y).

// Definição de uma posição segura: não há um buraco e, ou não há Wumpus, ou ele já está morto;
safe(X,Y) :- ~pit(X,Y) & (~wumpus(X,Y) | killed).

// Regras para inferência da posição de um buraco.
// Se não é brisa na posição, então não há buraco.
~pit(X,Y) :- ~breeze(X,Y).
// Se não existe brisa nas posições adjacentes, então não há buraco.
~pit(X,Y) :- adjacent(X,Y,X2,Y2) & ~breeze(X2,Y2).
// Se é um muro, não é um buraco.
~pit(X,Y) :- wall(X,Y).

// Regras para inferência da existência de um buraco.
// Se existir brisa numa posição e as posições adjacentes à brisa não tiverem buraco, então ele só pode estar na posição testada;
pit(X,Y) :- breeze(X,Y-1) & ~pit(X-1,Y-1) & ~pit(X,Y-2) & ~pit(X+1,Y-1).
pit(X,Y) :- breeze(X+1,Y) & ~pit(X+2,Y) & ~pit(X+1,Y-1) & ~pit(X+1,Y+1).
pit(X,Y) :- breeze(X,Y+1) & ~pit(X-1,Y+1) & ~pit(X,Y+2) & ~pit(X+1,Y+1).
pit(X,Y) :- breeze(X-1,Y) & ~pit(X-2,Y) & ~pit(X-1,Y-1) & ~pit(X-1,Y+1).

might_be_pit(X,Y) :-  adjacent(X,Y,X2,Y2) & breeze(X2,Y2).

/* Inferências para a posição do Wumpus */

// Se não tem cheiro, não tem Wumpus;
~wumpus(X,Y) :- ~stench(X,Y).
// Se não tem cheiro nas posições adjacentes, então não há Wumpus na posição testada;
~wumpus(X,Y) :- adjacent(X,Y,X2,Y2) & ~stench(X2,Y2).
// Se é um muro, não tem Wumpus;
~wumpus(X,Y) :- wall(X,Y).

// Regra muito importante para decidir se a posição não tem o Wumpus.
// Se não tem cheiro OU se é um muro OU se a posição é segura;
not_wumpus(X,Y) :- ~stench(X,Y) | wall(X,Y) | safe(X,Y).

// Olha para o norte e para o sul da posição onde o Wumpus potencialmente está.
// Se tanto em cima como embaixo o agente sabe que tem fedor, então o Wumpus só pode estar ali;
look_vertical(X,Y) :- stench(X,Y-1) & stench(X,Y+1).
// Olha para o leste e para o oeste da posição onde o Wumpus potencialmente está.
// Se tanto na esquerda como na direita o agente sabe que tem fedor, então o Wumpus só pode estar ali;
look_horizontal(X,Y) :- stench(X-1,Y) & stench(X+1,Y).

// Teste de crença para as posições do Wumpus.
// Todas as quatro regras a seguir seguem o mesmo padrão:
//   i) testam as posições vertical e horizontal (regras acima).
//  ii) testa as outras posições: se estou num lugar que tem fedor e sei que dos meus lados as posições são seguras 
//		OU é um muro e que atrás também, então o Wumpus só pode estar na frente: atira! 
wumpus_north(X,Y) :- (look_vertical(X,Y)) |
	(stench(X,Y-1) & (stench(X-1,Y) | stench(X+1,Y)) & not_wumpus(X-1,Y-2) & not_wumpus(X+1,Y-2)) |
	(stench(X,Y-1) & not_wumpus(X,Y-2) & not_wumpus(X+1,Y-1) & not_wumpus(X-1,Y-1) & not_wumpus(X+1, Y-2) & not_wumpus(X-1, Y-2)).
wumpus_south(X,Y) :- (look_vertical(X,Y)) |
	(stench(X,Y+1) & (stench(X-1,Y) | stench(X+1,Y)) & not_wumpus(X-1,Y+2) & not_wumpus(X+1,Y+2)) |
	(stench(X,Y+1) & not_wumpus(X,Y+2) & not_wumpus(X+1,Y+1) & not_wumpus(X-1,Y+1) & not_wumpus(X+1, Y+2) & not_wumpus(X-1, Y+2)).
wumpus_west(X,Y) :- (look_horizontal(X,Y)) |
	(stench(X+1,Y) & (stench(X,Y-1) | stench(X,Y+1)) & not_wumpus(X-2,Y+1) & not_wumpus(X-2,Y-1)) |
	(stench(X+1,Y) & not_wumpus(X+2,Y) & not_wumpus(X+1,Y-1) & not_wumpus(X+1,Y+1) & not_wumpus(X+2, Y-1) & not_wumpus(X+2, Y+1)).
wumpus_east(X,Y) :- (look_horizontal(X,Y)) |
	(stench(X-1,Y) & (stench(X,Y-1) | stench(X,Y+1)) & not_wumpus(X-2,Y+1) & not_wumpus(X-2,Y-1)) |
	(stench(X-1,Y) & not_wumpus(X-2,Y) & not_wumpus(X-1,Y-1) & not_wumpus(X-1,Y+1) & not_wumpus(X-2, Y-1) & not_wumpus(X-2, Y+1)).
