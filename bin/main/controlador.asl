tempoEspera(0).
vagasLivres(1).
precoMinimo(4).
precoDesejado(10).


!controlar.

+pedidoEstacionamento[source(Ag)] : vagasLivres(X) & X > 0 & precoDesejado(P) <-
    .print("O estacionamento possui vagas, enviando o preco para o agente");
    +proposta(Ag, P, 0, 2);
    .send(Ag, achieve, proposta(P, 0)).

+pedidoEstacionamento[source(Ag)] : vagasLivres(X) & X == 0 & precoDesejado(P) & tempoEspera(T) <-
    .print("O estacionamento está lotado, enviando o preco e o tempo de espera para o VA");
    +proposta(Ag, P, T, 2);
    .send(Ag, achieve, proposta(P, T)).

+ofertaAceita[source(Ag)] <-
    .print("A vaga 1 será ocupada");
    ?vagasLivres(Qtd);
    -+vagasLivres(Qtd-1);
    .send(Ag, tell, vagaEstacionar(1));
    -proposta(Ag, _, _, _);
    -ofertaAceita[source(Ag)];
    -pedidoEstacionamento[source(Ag)].

+ofertaRejeitada[source(Ag)] : proposta(Ag, P, E, Tentativas) & Tentativas > 0 <-
    .print("O agente ", Ag, " rejeitou a proposta, enviando contraproposta");
    -+proposta(Ag, P-1, E, Tentativas-1);
    -ofertaRejeitada[source(Ag)];
    .send(Ag, achieve, proposta(P-1, E)).

+ofertaRejeitada[source(Ag)] <-
    .print("Nao foi possivel negociar com o agente ", Ag);
    -proposta(Ag, _, _, _);
    -ofertaRejeitada[source(Ag)];
    -pedidoEstacionamento[source(Ag)];
    .send(Ag, tell, cancelarNegociacao).

+cancelarOferta[source(Ag)] <-
    .print("Cancelando a requisicao do agente ", Ag);
    -proposta(Ag, _, _, _);
    -cancelarOferta[source(Ag)];
    -pedidoEstacionamento[source(Ag)].

+!liberarVaga(V)[source(Ag)] <-
    ?vagasLivres(Qtd);
    -+vagasLivres(Qtd+1);
    .print("Liberando a vaga ", V);
    !controlar. 

+!controlar <-
    .print("Esperando pedidos de vagas");
    .wait(400);
    !controlar.
