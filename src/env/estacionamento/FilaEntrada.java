package estacionamento;

import cartago.*;
import model.AgentRequest;

import java.util.PriorityQueue;

public class FilaEntrada extends Artifact {
    PriorityQueue<AgentRequest> filaEntrada = new PriorityQueue<>();
    static String requisicao = "requisicao";
    static String sinal = "pedidoEstacionamento";

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
    void popRequestParking(OpFeedbackParam<AgentRequest> agentRequest) {
        // não é problematico ser null,
        // essa função só será chamada quando o agente controlador
        // receber o sinal de que alguem chegou para estacionar.
        agentRequest.set(filaEntrada.poll());
    }
}
