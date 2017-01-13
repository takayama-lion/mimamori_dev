package sdtk.topaz.ne.jp.ibeaconsample2.MimamoriIBeacon;

/**
 * Created by hiroyuki on 2017/01/10.
 */

public class IBeaconConstants {
    /**
     * uniqueid
     */
    public static final String UNIQUE_ID = IBeaconConstants.class.getName() + "_";

    /**
     * beacon service action name
     */
    public static final String SERVICE_ACTION = "beacon_service_action";

    /**
     * beacon receive action name
     */
    public static final String RECEIVE_ACTION = "beacon_receive_";

    /**
     * param action name
     */
    public static final String PARAM_ACTION_NAME = "param_action_";

    /**
     * param status
     */
    public static final String PARAM_STATUS = "param_status";

    /**
     * param uniq
     */
    public static final String PARAM_UNIQID = "param_uniqid";

    /**
     * param uuid
     */
    public static final String PARAM_UUID = "param_uuid";

    // status
    public static final int STATUS_STANDBY = 1;

    public static final int STATUS_START = 2;

    public static final int STATUS_STOP = 3;

    public static final int STATUS_SHUTDOWN = 4;


}
