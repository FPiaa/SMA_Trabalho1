package estacionamento;

import cartago.*;
import model.AgentParked;

import java.util.Random;
import java.time.LocalDateTime;
import java.util.ArrayList;

public class Vagas extends Artifact {
    static String vagaLiberada = "vagaLiberada";
    ArrayList<AgentParked> carrosEstacionados;
    long vagas;

    void init(int parkingSize) {
        carrosEstacionados = new ArrayList<>(parkingSize);

        for (int i = 0; i < parkingSize; ++i) {
            carrosEstacionados.add(null);
        }
        vagas = parkingSize;

    }

    int getNextSpot(String nome, int duration) {
        for (int i = 0; i < carrosEstacionados.size(); ++i) {
            if (carrosEstacionados.get(i) == null) {
                AgentParked a = new AgentParked(nome, duration);
                carrosEstacionados.set(i, a);
                return i;
            }
        }
        // Jamais deveria ocorrer essa situação
        return -1;
    }

    @OPERATION
    void getWaitTime(OpFeedbackParam<Long> tempoEspera) {
        if (carrosEstacionados.stream().filter(x -> x == null).findAny().isPresent()) {
            System.out.println(
                    "Não deveria ocorrer, o tempo remanescente só deve ser chamado quando o estacionamento estiver totalmente cheio");
            tempoEspera.set(0l);
            return;
        }
        LocalDateTime now = LocalDateTime.now();
        tempoEspera.set(
                carrosEstacionados.stream()
                        .map(x -> x.getRemainingTime(now))
                        .sorted()
                        .findFirst()
                        .get());

    }

    // esta reserva só será feita quando ouver vagas disponíveis
    // no estacionamento
    @OPERATION
    void reserveSpot(String nome, int duration, OpFeedbackParam<Integer> spot) {
        int a = getNextSpot(nome, duration);
        spot.set(a);
    }

    @OPERATION
    void clearReservation(int spot) {
        carrosEstacionados.set(spot, null);
        signal(vagaLiberada);
    }

    @OPERATION
    void park(int spot, String agent, int duration) {
        AgentParked a = new AgentParked(agent, duration);
        carrosEstacionados.set(spot, a);
        System.out.println("Parking " + agent + " for " + duration + " minutes " + " on " + spot);
    }

    @OPERATION
    void unpark(int spot) {
        carrosEstacionados.set(spot, null);
        signal(vagaLiberada);
    }

    @OPERATION
    void numberOfEmptySpots(OpFeedbackParam<Long> vagasLivres) {
        long vagas = 0;
        for (int i = 0; i < carrosEstacionados.size(); ++i) {
            if (carrosEstacionados.get(i) == null)
                vagas += 1;
        }
        vagasLivres.set(vagas);
    }

}