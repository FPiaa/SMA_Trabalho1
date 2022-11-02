precoMinimo(6).
precoDesejado(10).
parkingSize(5).


!start.

+!start : parkingSize(P) <-
    makeArtifact("filaEntrada", "estacionamento.FilaEntrada", [], IdFilaEntrada);
    focus(IdFilaEntrada);
    makeArtifact("vagas", "estacionamento.Vagas", [P], IdVagas);
    focus(IdVagas);
    makeArtifact("filaEspera", "estacionamento.FilaEspera", [], IdFilaEspera);
    focus(IdFilaEspera);
    .print("O agente já está observando a fila de entrada").

+novoVeiculo : parkingSize(P) <-
    popRequestParking(Ag, Duration, Prioritario);
    +agentePrioritario(Ag, Prioritario, Duration);
    numberOfEmptySpots(X);
    if (X > 0) {
        reserveSpot(Ag, Duration, Spot);
        !pedidoEstacionamento(Ag, Spot, P - X - 1);
    } else {
        !pedidoEstacionamento(Ag, -1, P - X - 1);
    }.


+!pedidoEstacionamento(Ag,Spot, _): Spot >= 0 & precoDesejado(P) <-
    .print("O estacionamento possui vagas, enviando o preco ", P, " para o agente ", Ag);
    +negociar(Ag, P, 0, Spot, 4);
    .send(Ag, achieve, negociar(P, 0)).

+!pedidoEstacionamento(Ag, Spot, X): Spot < 0 & precoDesejado(P) <-
    getWaitTime(X, T);
    waitTime(F);
    .print("O estacionamento está lotado, enviando o preco ", P, " e o tempo de espera ", T, " minutos para ", Ag);
    +negociar(Ag, P, T+ F, Spot, 4);
    .send(Ag, achieve, negociar(P, T + F)).


+ofertaAceita[source(Ag)] : .concat("", Ag, A) & negociar(A, _, _, Spot, _) & Spot >= 0<-
    .print("A vaga ", Spot," será ocupada pelo agente ", A);
    .send(A, tell, vagaEstacionar(Spot));
    -negociar(A,_, _, _, _);
    -agentePrioritario(A, _, _);
    -ofertaAceita[source(Ag)].
    

+ofertaAceita[source(Ag)] : .concat("", Ag, A) & negociar(A, _, _, Spot, _) & Spot < 0 & agentePrioritario(A, P, D)<-
    .print("O agente ", A, " está esperando por uma vaga.");
    enqueue(A, P, D);
    -negociar(A, _, _, _ ,_);
    -agentePrioritario(A, P , D);
    -ofertaAceita[source(Ag)].

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
    -agentePrioritario(A, _, _);
    clearReservation(Spot);
    .send(A, tell, cancelarNegociacao).

+cancelarOferta[source(Ag)]: .concat("", Ag, A) & pedidoEstacionamento(A, Spot) <-
    .print("Cancelando a requisicao do agente ", Ag);
    -negociar(A, _, _, _, _);
    -agentePrioritario(A, _, _);
    -cancelarOferta[source(Ag)];
    -pedidoEstacionamento(A, _).

+vagaLiberada(V) <-
    waitSize(X);
    if(X > 0) {
        dequeue(A);
        .print("Foi liberada a vaga ", V, " e enviada para o agente ", A);
        .send(A, tell, vagaEstacionar(V));
    }.
