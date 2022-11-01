tempoEspera(10).
precoMinimo(6).
precoDesejado(10).


!start.

+!start <-
    makeArtifact("filaEntrada", "estacionamento.FilaEntrada", [], IdFilaEntrada);
    focus(IdFilaEntrada);
    makeArtifact("vagas", "estacionamento.Vagas", [], IdVagas);
    focus(IdVagas);
    .print("O agente já está observando a fila de entrada");
    !controlar.

+novoVeiculo <-
    popRequestParking(Ag, Duration);
    numberOfEmptySpots(X);
    +vagasLivres(X);
    reserveSpot(Spot);
    +pedidoEstacionamento(Ag, Duration, Spot).


+pedidoEstacionamento(Ag, _, Spot): vagasLivres(X) & X > 0 & precoDesejado(P) <-
    .print("O estacionamento possui vagas, enviando o preco ", P, " para o agente ", Ag);
    +negociar(Ag, P, 0, 4);
    .send(Ag, achieve, negociar(P, 0)).

+pedidoEstacionamento(Ag, _, Spot): vagasLivres(X) & X == 0 & precoDesejado(P) <-
    getWaitTime(T);
    .print("O estacionamento está lotado, enviando o preco ", P, " e o tempo de espera ", T, " minutos para ", Ag);
    +negociar(Ag, P, T, 4);
    .send(Ag, achieve, negociar(P, T)).

+ofertaAceita[source(Ag)] : .concat("", Ag, A) <-
    ?pedidoEstacionamento(A, _, Spot);
    .print("A vaga ", Spot," será ocupada");
    .send(A, tell, vagaEstacionar(Spot));
    -negociar(A, _, _, _);
    -ofertaAceita[source(Ag)];
    -pedidoEstacionamento(A, _, _).

+ofertaRejeitada[source(Ag)] : .concat("", Ag, A) & negociar(A, P, E, Tentativas) & Tentativas > 0 <-
    .print("O agente ", Ag, " rejeitou a proposta, enviando contraproposta, Preço : ", P-1);
    -negociar(A, _, _, _);
    +negociar(A, P-1, E, Tentativas-1);
    -ofertaRejeitada[source(Ag)];
    .send(Ag, achieve, negociar(P-1, E)).

+ofertaRejeitada[source(Ag)]: .concat("", Ag, A) & pedidoEstacionamento(A, _, Spot) <-
    .print("Nao foi possivel negociar com o agente ", Ag, " excluindo a reserva da vaga ", Spot);
    -negociar(A, _, _, _);
    -ofertaRejeitada[source(Ag)];
    clearReservation(Spot);
    -pedidoEstacionamento(A, _, _);
    .send(A, tell, cancelarNegociacao).

+cancelarOferta[source(Ag)]: .concat("", Ag, A) & pedidoEstacionamento(A, _, Spot) <-
    .print("Cancelando a requisicao do agente ", Ag, " e a reserva da vaga ", Spot);
    -negociar(A, _, _, _);
    -cancelarOferta[source(Ag)];
    clearReservation(Spot);
    -pedidoEstacionamento(A, _, _).

+vagaLiberada <-
    .print("Foi liberada uma vaga, checando para ver se há carros esperando para estacionar").


// +!liberarVaga(V)[source(Ag)] <-
//     ?vagasLivres(Qtd);
//     -+vagasLivres(Qtd+1);
//     .print("Liberando a vaga ", V);
//     !controlar. 

+!controlar <-
    .print("Esperando pedidos de vagas");
    .wait(400);
    !controlar.
