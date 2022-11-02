bomPrecoEstacionamento(6).
precoMaximo(12).
tempoEsperaMaximo(10).
prioritario(false).
tempoPermanencia(2).


!trafegar.

+!trafegar <-
    .print("O agente está em circulação.");
    .wait(1000);
    !estacionar.


+!estacionar : .my_name(N) & prioritario(P) & tempoPermanencia(T) <-
    .print("O agente deseja estacionar.");
    !locateFilaEntrada(IdFila);
    focus(IdFila);
    !locateVagas(IdVagas);
    focus(IdVagas);
    requestParking(N, P, T);
    .print("Esperando pela oferta do estacionamento.");
    .wait(negociar(Preco, TempoEspera)).


+!negociar(_, TempoEspera)[source(controlador)] : tempoEsperaMaximo(T) & TempoEspera > T <-
    .print("O tempo de espera é maior do que o que eu posso aceitar.");
    .print("Cancelando o pedido de estacionament.");
    !cancelarOferta.


+!negociar(Preco, TempoEspera)[source(controlador)] <- 
    ?calcularUtilidade(Preco, TempoEspera, Util);
    .print("Utilidade da oferta é: ", Util);
    if (Util > 0.7) {
        .print("A oferta fornece uma utilidade razoável para mim.");
        .print("Preco por hora : ", Preco, " Tempo Espera: ", TempoEspera, " minutos.");
        !aceitarOferta;
    } else {
        .print("A oferta não é razoável para mim");
        !rejeitarOferta;
    }.

+!aceitarOferta <-
    .print("Aceitando a oferta");
    .send(controlador, tell, ofertaAceita);
    .print("Esperando qual vaga será utilizada para estacionar");
    .wait(vagaEstacionar(V)).

+!rejeitarOferta <-
    .print("Oferta recusada");
    .send(controlador, tell, ofertaRejeitada);
    .wait(cancelarNegociacao).


+vagaEstacionar(V)[source(controlador)] : .my_name(X) & tempoPermanencia(T) <-
    .print("Estacionando o veículo na vaga, ", V);
    park(V, X, T);
    ?tempoPermanencia(T);
    .wait(1000 *  T);
    // .send(controlador, achieve, liberarVaga(V));
    unpark(V);
    -vagaEstacionar(V)[source(controlador)];
    .print("Saindo do estacionamento");
    !trafegar.

+cancelarNegociacao <-
    .print("Não foi possivel entrar em acordo com o estacionamento");
    .print("Voltando a trafegar");
    -cancelarNegociacao[source(controlador)];
    !trafegar.

+!cancelarOferta <-
    .send(controlador, tell, cancelarOferta);
    -negociar(_, _)[source(controlador)];
    !trafegar.



+?calcularUtilidade(Preco, TempoEspera, Util) <-
    ?bomPrecoEstacionamento(B);
    ?precoMaximo(M);
    ?tempoEsperaMaximo(T);
    Util = 0.8 * ((M - Preco) / B) - 0.1 * TempoEspera / T.



+!locateFilaEntrada(Id) <-
    lookupArtifact("filaEntrada", Id).

-!locateFilaEntrada(Id) <-
    .wait(10);
    !locateFilaEntrada.

+!locateVagas(Id) <-
    lookupArtifact("vagas", Id).

-!locateVagas(Id) <-
    .wait(10);
    !locateVagas.

