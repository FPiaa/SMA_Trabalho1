package model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Comparator;

public class AgentRequest implements Comparator<AgentRequest> {
    String nome;
    Boolean prioritario;
    LocalDateTime dataRequisicao;
    LocalDateTime finalEstadia;

    public AgentRequest(String nome, boolean prioritario, int duration) {
        this.nome = nome;
        this.prioritario = prioritario;
        dataRequisicao = LocalDateTime.now();
        finalEstadia = dataRequisicao.plusMinutes(duration);
    }

    @Override
    public int compare(AgentRequest arg0, AgentRequest arg1) {
        int cmp = arg0.prioritario.compareTo(arg1.prioritario);
        if (cmp != 0) {
            return cmp;
        } else {
            return arg0.dataRequisicao.compareTo(arg1.dataRequisicao);
        }
    }

}
