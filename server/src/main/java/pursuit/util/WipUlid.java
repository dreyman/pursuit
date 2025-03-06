package pursuit.util;

import java.util.Random;

public class WipUlid {
    final static String alphabet = "0123456789ABCDEFGHJKMNPQRSTVWXYZ";
    static Random rand = new Random();

    public static String encodeTime() {
        var result = new StringBuilder();
        int mo;
        long now = System.currentTimeMillis();
        for (int i = 1; i < 10; i++) {
            mo = (int) (now % alphabet.length());
            result.append(alphabet.charAt(mo));
            now = (now - mo) / alphabet.length();
        }
        return result.reverse().toString();
    }

    public static String encodeRandom() {
        var result = new StringBuilder();
        for (int i = 1; i < 16; i++) {
            result.append(alphabet.charAt(rand.nextInt(alphabet.length())));
        }
        return result.reverse().toString();
    }

    public static String ulid() {
        return encodeTime().concat(encodeRandom());
    }

    public static void main(String[] args) {
        for (int i = 0; i < 20; i++) {
            System.out.println(WipUlid.ulid());
        }
    }

}
