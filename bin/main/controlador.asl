tempoEspera(10).
precoMinimo(6).
precoDesejado(10).


!start.

+!start <-
    makeArtifact("filaEntrada", "estacionamento.FilaEntrada", [], IdFilaEntrada);
    focus(IdFilaEntrada);
    makeArtifact("vagas", "estacionamento.Vagas", [6], IdVagas);
    focus(IdVagas);
    .print("O agente já está observando a fila de entrada").

+novoVeiculo <-
    popRequestParking(Ag, Duration);
    numberOfEmptySpots(X);
    if (X > 0) {
        reserveSpot(Ag, Duration, Spot);
        !pedidoEstacionamento(Ag, X, Spot);
    } else {
        -vagasLivres(_);
        !pedidoEstacionamento(Ag, X, -1);
    }.


+!pedidoEstacionamento(Ag, Vagas, Spot): Vagas > 0 & precoDesejado(P) <-
    .print("O estacionamento possui vagas, enviando o preco ", P, " para o agente ", Ag);
    +negociar(Ag, P, 0, Spot, 4);
    .send(Ag, achieve, negociar(P, 0)).

+!pedidoEstacionamento(Ag, Vagas, Spot): Vagas == 0 & precoDesejado(P) <-
    getWaitTime(T);
    .print("O estacionamento está lotado, enviando o preco ", P, " e o tempo de espera ", T, " minutos para ", Ag);
    +negociar(Ag, P, T, Spot, 4);
    .send(Ag, achieve, negociar(P, T)).

-!pedidoEstacionamento(Ag, Spot) <-
    ?vagasLivres(X);
    .print("FAlhouw", Ag, " ", Spot, " ", X).


+ofertaAceita[source(Ag)] : .concat("", Ag, A) <-
    ?negociar(A, _, _, Spot, _);
    .print("A vaga ", Spot," será ocupada pelo agente ", A);
    .send(A, tell, vagaEstacionar(Spot));
    -negociar(A,_, _, _, _);
    -ofertaAceita[source(Ag)];
    -pedidoEstacionamento(A, _).

+ofertaRejeitada[source(Ag)] : .concat("", Ag, A) & negociar(A, P, E, Spot, Tentativas) & Tentativas > 0 <-
    .print("O agente ", Ag, " rejeitou a proposta, enviando contraproposta, Preço : ", P-1);
    -negociar(A, _, _, _, _);
    +negociar(A, P-1, E, Spot, Tentativas-1);
    -ofertaRejeitada[source(Ag)];
    .send(Ag, achieve, negociar(P-1, E)).

+ofertaRejeitada[source(Ag)]: .concat("", Ag, A) & negociar(A, _, _, _, _)<-
    .print("Nao foi possivel negociar com o agente ", Ag, " excluindo a reserva da vaga ", Spot);
    -negociar(A,_, _, _, _);
    -ofertaRejeitada[source(Ag)];
    clearReservation(Spot);
    .send(A, tell, cancelarNegociacao).

+cancelarOferta[source(Ag)]: .concat("", Ag, A) & pedidoEstacionamento(A, Spot) <-
    .print("Cancelando a requisicao do agente ", Ag);
    -negociar(A, _, _, _, _);
    -cancelarOferta[source(Ag)];
    -pedidoEstacionamento(A, _).

+vagaLiberada <-
    .print("Foi liberada uma vaga, checando para ver se há carros esperando para estacionar").
