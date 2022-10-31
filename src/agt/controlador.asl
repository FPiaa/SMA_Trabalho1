tempoEspera(10).
vagasLivres(2).
precoMinimo(6).
precoDesejado(10).


!start.

+!start <-
    makeArtifact("filaEntrada", "estacionamento.FilaEntrada", [], IdFilaEntrada);
    focus(IdFilaEntrada);
    .print("O agente já está observando a fila de entrada");
    !controlar.

+novoVeiculo <-
    popRequestParking(Ag, Duration);
    // encontre a vaga para o agente;
    +pedidoEstacionamento(Ag, Duration).


+pedidoEstacionamento(Ag, _): vagasLivres(X) & X > 0 & precoDesejado(P) <-
    .print("O estacionamento possui vagas, enviando o preco para o agente");
    +negociar(Ag, P, 0, 4);
    .send(Ag, achieve, negociar(P, 0)).

+pedidoEstacionamento(Ag, _): vagasLivres(X) & X == 0 & precoDesejado(P) & tempoEspera(T) <-
    .print("O estacionamento está lotado, enviando o preco e o tempo de espera para ", Ag);
    +negociar(Ag, P, T, 4);
    .send(Ag, achieve, negociar(P, T)).

+ofertaAceita[source(Ag)] : .concat("", Ag, A) <-
    .print("A vaga 1 será ocupada");
    ?vagasLivres(Qtd);
    -+vagasLivres(Qtd-1);
    .send(A, tell, vagaEstacionar(1));
    -negociar(A, _, _, _);
    -ofertaAceita[source(Ag)];
    -pedidoEstacionamento(A, _).

+ofertaRejeitada[source(Ag)] : .concat("", Ag, A) & negociar(A, P, E, Tentativas) & Tentativas > 0 <-
    .print("O agente ", Ag, " rejeitou a proposta, enviando contraproposta");
    -negociar(A, _, _, _);
    +negociar(A, P-1, E, Tentativas-1);
    -ofertaRejeitada[source(Ag)];
    .send(Ag, achieve, negociar(P-1, E)).

+ofertaRejeitada[source(Ag)]: .concat("", Ag, A) <-
    .print("Nao foi possivel negociar com o agente ", Ag);
    -negociar(A, _, _, _);
    -ofertaRejeitada[source(Ag)];
    -pedidoEstacionamento(A, _);
    .send(A, tell, cancelarNegociacao).

+cancelarOferta[source(Ag)]: .concat("", Ag, A) <-
    .print("Cancelando a requisicao do agente ", Ag);
    -negociar(A, _, _, _);
    -cancelarOferta[source(Ag)];
    -pedidoEstacionamento(A, _).

+!liberarVaga(V)[source(Ag)] <-
    ?vagasLivres(Qtd);
    -+vagasLivres(Qtd+1);
    .print("Liberando a vaga ", V);
    !controlar. 

+!controlar <-
    .print("Esperando pedidos de vagas");
    .wait(400);
    !controlar.
