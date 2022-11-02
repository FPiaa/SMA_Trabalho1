package estacionamento;

import java.util.PriorityQueue;

import cartago.Artifact;
import cartago.OPERATION;
import cartago.OpFeedbackParam;
import model.AgentRequest;

public class FilaEntrada extends Artifact {
    PriorityQueue<AgentRequest> filaEntrada = new PriorityQueue<>();
    static String requisicao = "requisicao";
    static String sinal = "novoVeiculo";

    void init() {
        defineObsProperty(requisicao);
    }

    @OPERATION
    void requestParking(String agentName, boolean prioritario, int duration) {
        AgentRequest agentRequest = new AgentRequest(agentName, prioritario, duration);
        filaEntrada.add(agentRequest);
        signal(sinal);

    }

    @OPERATION
    void popRequestParking(OpFeedbackParam<String> name, OpFeedbackParam<Integer> duration,
            OpFeedbackParam<Boolean> prefencial) {
        // não é problematico ser null,
        // essa função só será chamada quando o agente controlador
        // receber o sinal de que alguem chegou para estacionar.
        AgentRequest a = filaEntrada.poll();
        name.set(a.nome);
        duration.set(a.duration);
        prefencial.set(a.prioritario);
    }
}
