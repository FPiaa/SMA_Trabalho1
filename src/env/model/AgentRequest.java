package model;

import java.time.LocalDateTime;

public class AgentRequest implements Comparable<AgentRequest> {
    public String nome;
    Boolean prioritario;
    LocalDateTime dataRequisicao;
    public LocalDateTime finalEstadia;

    public AgentRequest(String nome, boolean prioritario, int duration) {
        this.nome = nome;
        this.prioritario = prioritario;
        dataRequisicao = LocalDateTime.now();
        finalEstadia = dataRequisicao.plusMinutes(duration);
    }

    @Override
    public int compareTo(AgentRequest arg0) {
        int cmp = prioritario.compareTo(arg0.prioritario);
        if (cmp != 0) {
            return cmp;
        } else {
            return dataRequisicao.compareTo(arg0.dataRequisicao);
        }
    }

}