package sdtk.topaz.ne.jp.ibeaconsample2.MimamoriIBeacon;

/**
 * Created by hiroyuki on 2017/01/12.
 */

public class IBeaconInfoData {
    public static int StatusNon = 0;      // 初期値
    public static int StatusLocation = 1; // 座標取得待ち
    public static int StatusSend = 2;      // 送信待ち

    /**
     * status in
     */
    public static String IN = "in";

    /**
     * status out
     */
    public static String OUT = "out";

    /**
     * status ignore
     */
    public static String IGNORE = "ignore";

    public String UUID;
    public String Major;
    public String Minor;
    public String Latitude;
    public String Longitude;
    public String Status;
    public String MenuId;
    public int Order;

    /**
     * constructor
     */
    public IBeaconInfoData() {
    }

    /**
     * constructor
     * @param menuId
     * @param uuid
     * @param major
     * @param minor
     * @param status
     */
    public IBeaconInfoData(String menuId, String uuid, String major, String minor, String status) {
        MenuId = menuId;
        UUID   = uuid;
        Major  = major;
        Minor  = minor;
        Status = status;
        Order  = StatusNon;
    }

    /**
     * set location value
     * @param latitude
     * @param longitude
     */
    public void setLocation(double latitude, double longitude) {
        Latitude = Double.toString(latitude);
        Longitude = Double.toString(longitude);
        Order = StatusLocation;
    }
}
