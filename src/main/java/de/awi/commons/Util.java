package de.awi.commons;


public class Util {

    public static int[] calcTile(int zoom, double lat, double lon) {
        double latRad = Math.toRadians(lat);
        double n = Math.pow(2.0, zoom);
        Double xTile = n * ((lon + 180.0) / 360.0);
        Double yTile = n * (1.0 - (Math.log(Math.tan(latRad) + 1 / Math.cos(latRad)) / Math.PI)) / 2.0;
        return new int[]{xTile.intValue(), yTile.intValue()};
    }
}
