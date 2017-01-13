package sdtk.topaz.ne.jp.ibeaconsample2.MimamoriIBeacon;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;
import android.view.Menu;

import java.util.UUID;

import sdtk.topaz.ne.jp.ibeaconsample2.iBeaconService;

/**
 * Created by hiroyuki on 2017/01/10.
 */

public class IBeaconProcess {
    public static final String TAG = IBeaconProcess.class.getSimpleName();

    /**
     * uuid
     */
    public String Uuid;

    /**
     * menu id
     */
    public String MenuId;

    /**
     * context
     */
    public Context mContext;

    /**
     * action name
     */
    public String ActionName = null;

    /**
     * constructor
     * @param context
     * @param menuId
     */
    public IBeaconProcess(Context context, String menuId, String uuid) {
        mContext = context;
        MenuId = menuId;
        Uuid = uuid;
        ActionName = IBeaconConstants.RECEIVE_ACTION + MenuId;

        // Service側からの送信
        LocalBroadcastManager.getInstance(context).registerReceiver(
                new DataReceiver(),
                new IntentFilter(ActionName));
    }

    /**
     * start
     * @param uuid
     */
    public void start(final String uuid) {
        // serviceが起動しているか調べる
        if (iBeaconService.isRunning(mContext)) { // running
            sendMessage(MenuId, Uuid, IBeaconConstants.STATUS_START);

        } else { // stop
            // 起動していなければ起動
            // 起動していればparam start
            Intent intent = new Intent(mContext, iBeaconService.class);
            intent.setAction(IBeaconConstants.SERVICE_ACTION);
            intent.putExtra(IBeaconConstants.PARAM_ACTION_NAME, ActionName);
            intent.putExtra(IBeaconConstants.PARAM_UUID, uuid);

            mContext.startService(intent);

        }
    }

    /**
     * stop
     * @param uuid
     */
    public void stop(String uuid) {
        // ServiceにStop statusを送信する
        sendMessage(MenuId, Uuid, IBeaconConstants.STATUS_STOP);
    }

    /**
     * beacon receiver
     */
    public class DataReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (ActionName.equals(intent.getAction())) {
                // Broadcast されたメッセージを取り出す
                int status = intent.getIntExtra(IBeaconConstants.PARAM_STATUS, 0);
                switch (status) {
                    case IBeaconConstants.STATUS_STANDBY:
                        Log.d(TAG, "----status standbay");
                        sendMessage(MenuId, Uuid, IBeaconConstants.STATUS_START);
                        break;
                    case IBeaconConstants.STATUS_SHUTDOWN:
                        Log.d(TAG, "----status hutdown");
                        mContext.stopService(new Intent(mContext, iBeaconService.class));
                        break;
                }
            }
        }
    }

    /**
     * send message
     * @param uuid
     * @param status
     */
    private void sendMessage(String menuId, String uuid, int status) {
        Intent intent = new Intent(String.valueOf(System.currentTimeMillis()));
        intent.setAction(iBeaconService.LOCATION_BROADCAST_FILTER_NAME);
        intent.putExtra(IBeaconConstants.PARAM_ACTION_NAME, ActionName);
        intent.putExtra(IBeaconConstants.PARAM_UNIQID, IBeaconConstants.UNIQUE_ID + menuId);
        intent.putExtra(IBeaconConstants.PARAM_UUID, uuid);
        intent.putExtra(IBeaconConstants.PARAM_STATUS, status);
        LocalBroadcastManager manager = LocalBroadcastManager.getInstance(mContext.getApplicationContext());
        manager.sendBroadcast(intent);
    }

}
