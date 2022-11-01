package estacionamento;

import cartago.*;
import java.util.Random;

public class Vagas extends Artifact {
    static String vagaLiberada = "vagaLiberada";

    void init() {

    }

    int getNextSpot() {
        Random r = new Random();
        return r.nextInt(10);
    }

    @OPERATION
    void getWaitTime(OpFeedbackParam<Integer> tempoEspera) {
        tempoEspera.set(5);
    }

    @OPERATION
    void reserveSpot(OpFeedbackParam<Integer> spot) {
        spot.set(getNextSpot());
    }

    @OPERATION
    void clearReservation(int spot) {

    }

    @OPERATION
    void park(int spot, String agent, int duration) {
        System.out.println("Parking " + agent + " for " + duration + " minutes " + " on " + spot);
    }

    @OPERATION
    void numberOfEmptySpots(OpFeedbackParam<Integer> vagasLivres) {
        Random r = new Random();
        vagasLivres.set(r.nextInt(2));
    }

    @OPERATION
    void unpark(int spot) {
        signal(vagaLiberada);
    }

}