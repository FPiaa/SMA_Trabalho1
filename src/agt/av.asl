bomPrecoEstacionamento(6).
precoMaximo(12).
tempoEsperaMaximo(5).

!trafegar.

+!trafegar <-
    .print("O agente está em circulacao");
    .wait(1000);
    !estacionar.


+!estacionar <-
    .print("O agente deseja estacionar");
    .send(controlador, tell, pedidoEstacionamento);
    .print("Esperando pela oferta do estacionamento");
    .wait(negociar(Preco, TempoEspera)).


+!negociar(_, TempoEspera)[source(controlador)] : tempoEsperaMaximo(T) & TempoEspera > T <-
    .print("O tempo de espera é maior do que o que eu posso aceitar");
    .print("Cancelando o pedido de estacionamento");
    !cancelarOferta.


+!negociar(Preco, TempoEspera)[source(controlador)] <- 
    ?calcularUtilidade(Preco, TempoEspera, Util);
    .print("Utilidade da oferta", Util);
    if (Util > 0.7) {
        .print("A oferta fornece uma utilidade razoável para mim.");
        .print("Preco por hora : ", Preco, " Tmpo Espera: ", TempoEspera);
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


+vagaEstacionar(V)[source(controlador)] <-
    .print("Estacionando o veículo na vaga, ", V);
    .wait(1000);
    .send(controlador, achieve, liberarVaga(V));
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



