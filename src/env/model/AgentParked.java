package model;

import java.time.Duration;
import java.time.LocalDateTime;

public class AgentParked {
    public String nome;
    int duration;
    public LocalDateTime dataSaida;

    public AgentParked(String nome, int duration) {
        this.nome = nome;
        this.duration = duration;
        dataSaida = LocalDateTime.now().plusSeconds(duration);
    }

    public long getRemainingTime(LocalDateTime current) {
        Duration dur = Duration.between(LocalDateTime.now(), dataSaida);
        return dur.toSeconds();
    }

    public boolean equals(Object o) {
        if (o == this)
            return true;
        if (!(o instanceof AgentParked))
            return false;
        AgentParked other = (AgentParked) o;
        return nome.equals(other.nome);
    }

}
