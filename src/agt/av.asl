l_precoLimite([8,9,10,11,12]).
l_bomPreco([3,4,5]).
l_tempoPermanencia([3,4,5,6,7,8,9,20]).
l_prioritario([true, false]).
l_tempoEspera([5, 10, 15, 20]).


!config.


+!config <- 
    ?l_precoLimite(P);
    .random(P, PrecoL);
    ?l_bomPreco(Bp);
    .random(Bp, BomP);
    ?l_tempoPermanencia(TP);
    .random(TP, TempoP);
    ?l_prioritario(Pr);
    .random(Pr, Priori);
    ?l_tempoEspera(TE);
    .random(TE, TempoEspera);
    .random(Peso);
    +precoMaximo(PrecoL);
    +bomPrecoEstacionamento(BomP);
    +tempoPermanencia(TempoP);
    +prioritario(Priori);
    +tempoEsperaMaximo(TempoEspera);
    +peso(Peso);
    -l_precoLimite([10,11,12,13,14,15]);
    -l_bomPreco([3,4,5,6,7,8,9,10]);
    -l_tempoPermanencia([3,4,5,6,7,8,9,20]);
    -l_prioritario([true, false]);
    -l_tempoEspera([5, 10, 15, 20]);

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



+?calcularUtilidade(Preco, TempoEspera, Util) : TempoEspera == 0 <-
    ?bomPrecoEstacionamento(B);
    ?precoMaximo(M);
    ?tempoEsperaMaximo(T);
    Temp = (M - B) / 10 * 3 + B;
    Util = Temp / Preco.

+?calcularUtilidade(Preco, TempoEspera, Util) <-
    ?bomPrecoEstacionamento(B);
    ?precoMaximo(M);
    ?tempoEsperaMaximo(T);
    ?peso(P);
    Temp = (M - B) / 10 * 3 + B;
    A = Temp / Preco;
    Util = P * A + (1 - P) * (T - TempoEspera) / T.

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

