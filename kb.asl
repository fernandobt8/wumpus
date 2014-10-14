/* Regras de infer�ncia */

// Teste de adjac�ncia para as posi��es;
adjacent(X,Y,X+1,Y).
adjacent(X,Y,X-1,Y).
adjacent(X,Y,X,Y+1).
adjacent(X,Y,X,Y-1).

// Sequ�ncia de orienta��es a ser seguida;
next_orientation(north,east).
next_orientation(east,south).
next_orientation(south,west).
next_orientation(west,north).

next_position(X, Y, north,X ,Y+1).
next_position(X, Y, south,X ,Y-1).
next_position(X, Y, east,X+1 ,Y).
next_position(X, Y, west,X-1 ,Y).

visited(X,Y) :- ~breeze(X,Y) | breeze(X,Y).

// Defini��o de uma posi��o segura: n�o h� um buraco e, ou n�o h� Wumpus, ou ele j� est� morto;
safe(X,Y) :- ~pit(X,Y) & (~wumpus(X,Y) | killed).

// Regras para infer�ncia da posi��o de um buraco.
// Se n�o � brisa na posi��o, ent�o n�o h� buraco.
~pit(X,Y) :- ~breeze(X,Y).
// Se n�o existe brisa nas posi��es adjacentes, ent�o n�o h� buraco.
~pit(X,Y) :- adjacent(X,Y,X2,Y2) & ~breeze(X2,Y2).
// Se � um muro, n�o � um buraco.
~pit(X,Y) :- wall(X,Y).

// Regras para infer�ncia da exist�ncia de um buraco.
// Se existir brisa numa posi��o e as posi��es adjacentes � brisa n�o tiverem buraco, ent�o ele s� pode estar na posi��o testada;
pit(X,Y) :- breeze(X,Y-1) & ~pit(X-1,Y-1) & ~pit(X,Y-2) & ~pit(X+1,Y-1).
pit(X,Y) :- breeze(X+1,Y) & ~pit(X+2,Y) & ~pit(X+1,Y-1) & ~pit(X+1,Y+1).
pit(X,Y) :- breeze(X,Y+1) & ~pit(X-1,Y+1) & ~pit(X,Y+2) & ~pit(X+1,Y+1).
pit(X,Y) :- breeze(X-1,Y) & ~pit(X-2,Y) & ~pit(X-1,Y-1) & ~pit(X-1,Y+1).

might_be_pit(X,Y) :-  adjacent(X,Y,X2,Y2) & breeze(X2,Y2).

/* Infer�ncias para a posi��o do Wumpus */

// Se n�o tem cheiro, n�o tem Wumpus;
~wumpus(X,Y) :- ~stench(X,Y).
// Se n�o tem cheiro nas posi��es adjacentes, ent�o n�o h� Wumpus na posi��o testada;
~wumpus(X,Y) :- adjacent(X,Y,X2,Y2) & ~stench(X2,Y2).
// Se � um muro, n�o tem Wumpus;
~wumpus(X,Y) :- wall(X,Y).

// Regra muito importante para decidir se a posi��o n�o tem o Wumpus.
// Se n�o tem cheiro OU se � um muro OU se a posi��o � segura;
not_wumpus(X,Y) :- ~stench(X,Y) | wall(X,Y) | safe(X,Y).

// Olha para o norte e para o sul da posi��o onde o Wumpus potencialmente est�.
// Se tanto em cima como embaixo o agente sabe que tem fedor, ent�o o Wumpus s� pode estar ali;
look_vertical(X,Y) :- stench(X,Y-1) & stench(X,Y+1).
// Olha para o leste e para o oeste da posi��o onde o Wumpus potencialmente est�.
// Se tanto na esquerda como na direita o agente sabe que tem fedor, ent�o o Wumpus s� pode estar ali;
look_horizontal(X,Y) :- stench(X-1,Y) & stench(X+1,Y).

// Teste de cren�a para as posi��es do Wumpus.
// Todas as quatro regras a seguir seguem o mesmo padr�o:
//   i) testam as posi��es vertical e horizontal (regras acima).
//  ii) testa as outras posi��es: se estou num lugar que tem fedor e sei que dos meus lados as posi��es s�o seguras 
//		OU � um muro e que atr�s tamb�m, ent�o o Wumpus s� pode estar na frente: atira! 
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
