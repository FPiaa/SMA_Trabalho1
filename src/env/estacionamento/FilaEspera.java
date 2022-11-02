package estacionamento;

import java.util.PriorityQueue;

import cartago.Artifact;
import cartago.OPERATION;
import cartago.OpFeedbackParam;
import model.AgentRequest;

public class FilaEspera extends Artifact {
    PriorityQueue<AgentRequest> fila = new PriorityQueue<AgentRequest>();

    void init() {

    }

    @OPERATION
    void enqueue(String agentName, boolean prioritario, int duration) {
        AgentRequest a = new AgentRequest(agentName, prioritario, duration);
        fila.add(a);
    }

    @OPERATION
    void dequeue(OpFeedbackParam<String> name) {
        AgentRequest a = fila.poll();
        name.set(a.nome);
    }

    @OPERATION
    void waitSize(OpFeedbackParam<Integer> size) {
        size.set(fila.size());
    }
}
