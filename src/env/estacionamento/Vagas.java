package estacionamento;

import cartago.*;
import model.AgentParked;

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

        LocalDateTime now = LocalDateTime.now();
        int size = carrosEstacionados.size();
        ArrayList<Long> tempo = new ArrayList<>(size);
        for (int i = 0; i < size; ++i) {
            tempo.add(carrosEstacionados.get(i).getRemainingTime(now));
        }
        System.out.println(tempo.toString());
        tempoEspera.set(tempo.get(0));

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