package sdtk.topaz.ne.jp.ibeaconsample2;

import android.Manifest;
import android.app.PendingIntent;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.os.RemoteException;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;
import android.widget.Toast;

import org.altbeacon.beacon.Beacon;
import org.altbeacon.beacon.BeaconConsumer;
import org.altbeacon.beacon.BeaconManager;
import org.altbeacon.beacon.BeaconParser;
import org.altbeacon.beacon.Identifier;
import org.altbeacon.beacon.MonitorNotifier;
import org.altbeacon.beacon.RangeNotifier;
import org.altbeacon.beacon.Region;

import java.util.Collection;

import static org.altbeacon.beacon.service.BeaconService.TAG;

public class iBeaconService extends Service implements BeaconConsumer, MonitorNotifier, RangeNotifier, LocationListener {

    public static final String PARAM_ID = iBeaconService.class.getSimpleName();
    public static final String PARAM_UUID = "uuid";
    public static final String PARAM_MAJOR = "major";

    private static final String IBEACON_FORMAT = "m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24";

    private BeaconManager mBeaconManager = null;

    private Region mRegion = null;

    private static LocationManager mLocationManager = null;

    private double Latitude = 0;

    private double Longtitude = 0;

    public iBeaconService() {
        Log.d(TAG, "---instance---");
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "--onStartCommand");
        String param_uuid = null;
        String param_major = null;
        Identifier uuid = null;//Identifier.parse("53544152-4a50-4e40-8154-2631935eb10b");
        Identifier major = null;//Identifier.parse("1");
        Identifier minor = null;//Identifier.parse("9");
        if (intent != null && PARAM_ID.equals(intent.getAction())) {
            param_uuid = intent.getStringExtra(PARAM_UUID);
            param_major = intent.getStringExtra(PARAM_MAJOR);

        } else {
            SharedPreferences prf = getSharedPreferences(iBeaconService.PARAM_ID, MODE_PRIVATE);
            param_uuid = prf.getString(iBeaconService.PARAM_UUID, null);
            param_major = prf.getString(iBeaconService.PARAM_MAJOR, null);

        }
        if (param_uuid != null) {
            uuid = Identifier.parse(param_uuid);
        }
        if (param_major != null) {
            major = Identifier.parse(param_major);
        }
        mRegion = new Region("10000000-EE6E-2001-B000-005511DDAEGD", uuid, major, minor);

        Log.i(TAG, "---set UUID:[" + uuid + "] major:[" + major + "]");
        create();

        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "--onDestroy");

        if (mBeaconManager != null) {
            mBeaconManager.removeMonitoreNotifier(this);
            mBeaconManager.unbind(this);
        }
    }

    @Override
    public void onBeaconServiceConnect() {
        try {
            // ビーコン情報の監視を開始
            mBeaconManager.startMonitoringBeaconsInRegion(mRegion);

            mBeaconManager.addMonitorNotifier(this);

        } catch (RemoteException e) {
            e.printStackTrace();
        }
    }

    /**
     * create
     */
    private void create() {
        // インスタンス化
        mBeaconManager = BeaconManager.getInstanceForApplication(this);
        mBeaconManager.getBeaconParsers().add(new BeaconParser().setBeaconLayout(IBEACON_FORMAT));
        mBeaconManager.bind(this);

        mBeaconManager.setForegroundBetweenScanPeriod(1000);
        mBeaconManager.setBackgroundBetweenScanPeriod(1000);
    }

    @Override
    public void didEnterRegion(Region region) {
        setLocation();
//        Log.i("TAG,", "enter------[" + region.getId1() + "][" + region.getId2() + "][" + region.getId3() + "]");
        mBeaconManager.addRangeNotifier(this);
        try {
            mBeaconManager.startRangingBeaconsInRegion(region);
        } catch (RemoteException e) {
            e.printStackTrace();
        }

    }

    @Override
    public void didExitRegion(Region region) {
//        Log.i("TAG,", "exit------[" + region.getId1() + "][" + region.getId2() + "][" + region.getId3() + "]");
        try {
            mBeaconManager.stopRangingBeaconsInRegion(region);
        } catch (RemoteException e) {
            e.printStackTrace();
        }
        try {
            mBeaconManager.removeRangeNotifier(this);
        } catch (Exception e) {

        }
        Latitude = 0;
        Longtitude = 0;
    }

    @Override
    public void didDetermineStateForRegion(int i, Region region) {
//        Log.i("TAG,", "determine------[" + i + "][" + region.getId1() + "][" + region.getId2() + "][" + region.getId3() + "]");
    }

    @Override
    public void didRangeBeaconsInRegion(Collection<Beacon> collection, Region region) {
        for (Beacon beacon : collection) {
            String message = "UUID:[" + beacon.getId1() + "]\n major:[" + beacon.getId2() + "]\n minor:[" + beacon.getId3() + "]\n latitude:[" + Latitude + "]\n longitude:[" + Longtitude + "]";
            setToast(message);
            sendSyncBroadcast(message);
            Log.i("TAG,", "beacon------UUID:[" + beacon.getId1() + "] major:[" + beacon.getId2() + "] minor:[" + beacon.getId3() + "] latitude:[" + Latitude + "] longitude:[" + Longtitude + "]");
        }
    }

    @Override
    public void onLocationChanged(Location location) {
        Latitude = location.getLatitude();
        Longtitude = location.getLongitude();
        Log.d(TAG, "--- latitude:" + Latitude + " longitude:" + Longtitude);
    }

    @Override
    public void onStatusChanged(String s, int i, Bundle bundle) {
    }

    @Override
    public void onProviderEnabled(String s) {
    }

    @Override
    public void onProviderDisabled(String s) {
    }

    private void setLocation() {
        // 制度を設定
        Criteria criteria = new Criteria();
        criteria.setBearingRequired(false);    // 方位不要
        criteria.setSpeedRequired(false);    // 速度不要
        criteria.setAltitudeRequired(false);    // 高度不要

        // LocationManagerインスタンスを生成
        mLocationManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return;
        }
        mLocationManager.requestSingleUpdate(criteria, this, Looper.getMainLooper());
    }

    private Handler mHandler = new Handler();

    /**
     * set toast
     * @param message
     */
    private void setToast(final String message) {
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(getApplicationContext(), message, Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void sendSyncBroadcast(String message) {
        BroadcastReceiver receiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {

            }
        };
        IntentFilter filter = new IntentFilter();
        filter.addAction("action2");
        Intent i = new Intent();
        i.setAction("action1");
        i.putExtra("message", message);

        LocalBroadcastManager.getInstance(getApplicationContext()).registerReceiver(receiver, filter);
        Log.d("", "Start Activity");
        LocalBroadcastManager.getInstance(getApplicationContext()).sendBroadcastSync(i);
        Log.d("", "End Activity");
        LocalBroadcastManager.getInstance(getApplicationContext()).unregisterReceiver(receiver);

    }
}
