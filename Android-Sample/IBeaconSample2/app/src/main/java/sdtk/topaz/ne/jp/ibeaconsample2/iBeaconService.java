package sdtk.topaz.ne.jp.ibeaconsample2;

import android.Manifest;
import android.app.ActivityManager;
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
import java.util.Iterator;
import java.util.List;
import java.util.UUID;

import sdtk.topaz.ne.jp.ibeaconsample2.MimamoriIBeacon.IBeaconConstants;
import sdtk.topaz.ne.jp.ibeaconsample2.MimamoriIBeacon.IBeaconInfoData;
import sdtk.topaz.ne.jp.ibeaconsample2.MimamoriIBeacon.IBeaconInfoDataManager;

import static org.altbeacon.beacon.service.BeaconService.TAG;

public class iBeaconService extends Service implements BeaconConsumer, MonitorNotifier, RangeNotifier, LocationListener {
    private static final String TAG = iBeaconService.class.getSimpleName();

    /**
     * local broadcast receiver用 filter名
     */
    public static final String LOCATION_BROADCAST_FILTER_NAME = TAG + "_Receiver";

    /**
     * format
     */
    private static final String IBEACON_FORMAT = "m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24";

    /**
     * iBeacon manager
     */
    private BeaconManager mBeaconManager = null;

    /**
     * region
     */
    private Region mRegion = null;

    /**
     * LocationManager
     */
    private static LocationManager mLocationManager = null;

    /**
     * ibeacon info data database manager
     */
    private IBeaconInfoDataManager mInfoManager = null;

    /**
     * running フラグ
     */
    private boolean isRunning;

    /**
     * start action name
     */
    public static String StartAction = null;

    private enum catchStatus {
        add,
        remove,
        ignore,
    }

    /**
     * constructor
     */
    public iBeaconService() {
        Log.d(TAG, "---instance---");
        isRunning = false;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, final int startId) {
        Log.d(TAG, "--onStartCommand");

        // LocalBroadcast の設定 - アプリ側からの通知受信
        LocalBroadcastManager.getInstance(this).registerReceiver(
                new DataReceiver(),
                new IntentFilter(LOCATION_BROADCAST_FILTER_NAME));

        if (IBeaconConstants.SERVICE_ACTION.equals(intent.getAction())) {
            StartAction = intent.getStringExtra(IBeaconConstants.PARAM_ACTION_NAME);
        }

        if (!isRunning) {
            // インスタンス化
            mBeaconManager = BeaconManager.getInstanceForApplication(iBeaconService.this);
            mBeaconManager.getBeaconParsers().add(new BeaconParser().setBeaconLayout(IBEACON_FORMAT));
            // ビーコンを探すための各Bluetooth LEスキャンサイクル間の時間をミリ秒単位で設定します。
            mBeaconManager.setForegroundBetweenScanPeriod(1000);
            // ビーコンを探すための各Bluetooth LEスキャンサイクルの時間をミリ秒単位で設定します。
            mBeaconManager.setBackgroundBetweenScanPeriod(1000);
            // bind
            mBeaconManager.bind(iBeaconService.this);

            isRunning = true;
        }
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "--onDestroy");
        if (mBeaconManager != null) {
            Collection<Region> list = mBeaconManager.getMonitoredRegions();
            Iterator iterator = list.iterator();
            while (iterator.hasNext()) {
                Region region = (Region) iterator.next();
                try {
                    mBeaconManager.stopMonitoringBeaconsInRegion(region);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
            mBeaconManager.removeMonitoreNotifier(this);
            mBeaconManager.unbind(this);
        }
        mInfoManager.close();
        mInfoManager = null;
    }

    @Override
    public void onBeaconServiceConnect() {
        // STANDBY OKをアプリに通知する
        sendmessage(StartAction, IBeaconConstants.STATUS_STANDBY);
    }

    /**
     * beacon receiver
     */
    public class DataReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (LOCATION_BROADCAST_FILTER_NAME.equals(intent.getAction())) {
                // Broadcast されたメッセージを取り出す
                int status = intent.getIntExtra(IBeaconConstants.PARAM_STATUS, 0);
                switch (status) {
                    case IBeaconConstants.STATUS_START:
                        Log.d(TAG, "----status start");
                        BeaconStart(intent.getStringExtra(IBeaconConstants.PARAM_UNIQID),
                                intent.getStringExtra(IBeaconConstants.PARAM_UUID));
                        break;
                    case IBeaconConstants.STATUS_STOP:
                        Log.d(TAG, "----status stop");
                        BeaconStop(intent.getStringExtra(IBeaconConstants.PARAM_UNIQID));
                        break;
                }
            }
        }
    }

    /**
     * beacon object create& connect
     * @param uniqueid
     * @param uuid
     */
    private void BeaconStart(String uniqueid, String uuid) {
        try {
            // Beacon設定
            mRegion = new Region(uniqueid, Identifier.parse(uuid), null, null);
            // ビーコン情報の監視を開始
            mBeaconManager.startMonitoringBeaconsInRegion(mRegion);
            // notification
            mBeaconManager.addMonitorNotifier(this);
            // 現在の状況を確認する
            mBeaconManager.	requestStateForRegion(mRegion);

        } catch (RemoteException e) {
            e.printStackTrace();
        }

    }

    /**
     * beacon object stop
     * @param uniqueid
     */
    private void BeaconStop(String uniqueid) {
        if (isRunning && mBeaconManager != null) {
            int count = 0;
            Collection<Region> list = mBeaconManager.getMonitoredRegions();
            Iterator iterator = list.iterator();
            while (iterator.hasNext()) {
                Region region = (Region) iterator.next();
                try {
                    if (uniqueid.equals(region.getUniqueId())) {
                        mBeaconManager.stopMonitoringBeaconsInRegion(region);
                        count++;
                    }
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
            // 設定値が全て停止ならServiceも停止する
            if (list.size() == count) {
                mBeaconManager.removeMonitoreNotifier(this);
                mBeaconManager.unbind(this);
                isRunning = false;
            }
        }
    }

    @Override
    public void didEnterRegion(Region region) {
        if (mInfoManager == null) {
            mInfoManager = new IBeaconInfoDataManager(getApplicationContext());
        }
        // menuid
        String menuId = region.getUniqueId().substring(IBeaconConstants.UNIQUE_ID.length(), region.getUniqueId().length());
        // menuodが一致するデータを削除する
        mInfoManager.deleteAllWithMenuId(menuId);
        mBeaconManager.addRangeNotifier(this);
        try {
            mBeaconManager.startRangingBeaconsInRegion(region);
        } catch (RemoteException e) {
            e.printStackTrace();
        }

    }

    @Override
    public void didExitRegion(Region region) {
        Log.i("TAG,", "exit------[" + region.getId1() + "][" + region.getId2() + "][" + region.getId3() + "]");
        beaconOutput(region);
    }

    @Override
    public void didDetermineStateForRegion(int i, Region region) {
        if (mInfoManager == null) {
            mInfoManager = new IBeaconInfoDataManager(getApplicationContext());
        }
        // menuid
        String menuId = region.getUniqueId().substring(IBeaconConstants.UNIQUE_ID.length(), region.getUniqueId().length());
        // menuodが一致するデータを削除する
        mInfoManager.deleteAllWithMenuId(menuId);
        mBeaconManager.addRangeNotifier(this);
        try {
            mBeaconManager.startRangingBeaconsInRegion(region);
        } catch (RemoteException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void didRangeBeaconsInRegion(Collection<Beacon> collection, Region region) {
        boolean outputFlug = false;
        try {
            catchStatus status = catchStatus.add;
            // get menuid
            String menuId = region.getUniqueId().substring(IBeaconConstants.UNIQUE_ID.length(), region.getUniqueId().length());
            // データ一覧を取得する
            List<IBeaconInfoData> list = mInfoManager.getInfoWhereMenuId(menuId);
            // iBeacon info dataの登録
            if (collection.size() == 0) {
                beaconOutput(region);
                return;
            }
            for (Beacon beacon : collection) {
                IBeaconInfoData infoData = new IBeaconInfoData(
                        menuId,
                        beacon.getId1().toString(),
                        beacon.getId2().toString(),
                        beacon.getId3().toString(),
                        IBeaconInfoData.IN);
                // beaon存在チェック
                if (list.size() > 0) {
                    for (IBeaconInfoData saveData : list) {
                        if (infoData.MenuId.equals(saveData.MenuId)
                                && infoData.Major.equals(saveData.Major)
                                && infoData.Minor.equals(saveData.Minor)) {
                            // すでに追加されているので無視
                            status = catchStatus.ignore;
                            break;
                        }
                    }
                    // データが存在しないのでOUTフラグ
                    if (status != catchStatus.ignore) {
                        infoData.Status = IBeaconInfoData.OUT;
                    }
                }
                switch (status) {
                    case add:
                        mInfoManager.add(infoData);
                        outputFlug = true;
                        break;
                    case remove:
                        outputFlug = true;
                        mInfoManager.update(infoData);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            // 出力対象データが存在するなら座標取得を行う
            if (outputFlug) {
                // 座標取得
                setLocation();
            }
        }
    }

    /**
     * 座標取得
     * 取得した座標をIBeaconInfoDataに設定して更新する。
     * @param location
     */
    @Override
    public void onLocationChanged(Location location) {
        // 座標取得
        double latitude = location.getLatitude();
        double longitude = location.getLongitude();
        try {
            // StatusNonのデータ一覧を取得する
            List<IBeaconInfoData> list = mInfoManager.getInfoWhereOrder(IBeaconInfoData.StatusNon);

            if (list.size() > 0) {
                // 座標設定＆ステータス更新
                mInfoManager.begin();
                try {
                    for (IBeaconInfoData infoData : list) {
                        infoData.setLocation(latitude, longitude);
                        mInfoManager.update(infoData);
                    }
                    mInfoManager.success();
                } finally {
                    mInfoManager.end();
                }
                // サーバに送信する
                setBeaconSend();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        Log.d(TAG, "--- latitude:" + latitude + " longitude:" + longitude);
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

    /**
     * data output process
     * @param region
     */
    private void beaconOutput(Region region) {
        try {
            // get menuid
            String menuId = region.getUniqueId().substring(IBeaconConstants.UNIQUE_ID.length(), region.getUniqueId().length());
            // Exit時に Inデータが存在する場合は全てOUTに変更する
            List<IBeaconInfoData> list = mInfoManager.getInfoWhereMenuId(menuId);
            if (list.size() > 0) {
                mInfoManager.begin();
                for (IBeaconInfoData infoData : list) {
                    infoData.Status = IBeaconInfoData.OUT;
                    infoData.Order = IBeaconInfoData.StatusNon;
                    mInfoManager.update(infoData);
                }
                mInfoManager.success();
                mInfoManager.end();
                // 座標取得
                setLocation();
            }
            // 停止
            mBeaconManager.stopRangingBeaconsInRegion(region);
            mBeaconManager.removeRangeNotifier(this);

            //mInfoManager.success();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 座標取得初期設定
     */
    private void setLocation() {
        try {
            // 制度を設定
            Criteria criteria = new Criteria();
            criteria.setBearingRequired(false);  // 方位不要
            criteria.setSpeedRequired(false);    // 速度不要
            criteria.setAltitudeRequired(false); // 高度不要

            // LocationManagerインスタンスを生成
            mLocationManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED
                    && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                return;
            }
            mLocationManager.requestSingleUpdate(criteria, this, Looper.getMainLooper());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * send message
     * @param actionName
     * @param status
     */
    private void sendmessage(String actionName, int status) {
        Intent intent = new Intent(String.valueOf(System.currentTimeMillis()));
        intent.setAction(actionName);
        intent.putExtra(IBeaconConstants.PARAM_STATUS, status);
        LocalBroadcastManager manager = LocalBroadcastManager.getInstance(this);
        manager.sendBroadcast(intent);
    }

    /**
     * Beacon & 座標が取得した情報をサーバに送信する
     */
    private void setBeaconSend() {
        // StatusNonのデータ一覧を取得する
        List<IBeaconInfoData> list = mInfoManager.getInfoWhereOrder(IBeaconInfoData.StatusLocation);
        if (list.size() > 0) {
            // 座標設定＆ステータス更新
            for (IBeaconInfoData infoData : list) {
                // api実行
                infoData.Order = IBeaconInfoData.StatusSend;
                /** start **/
            Log.d(TAG, "------status=[" + infoData.Status + "][" + infoData.UUID + "][" + infoData.Major + "][" + infoData.Minor + "][" + infoData.Latitude + "][" + infoData.Longitude + "]");
                /** end **/
                try {
                    // 送信完了後にステータス更新
                    mInfoManager.update(infoData);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            // status = OUT and Order = StatusSendのデータを削除する
            mInfoManager.deleteAll(IBeaconInfoData.OUT, IBeaconInfoData.StatusSend);
        }
    }

    /**
     * service の起動確認
     * @param context
     * @return true/false
     */
    public static boolean isRunning(Context context) {
        // サービスが実行中かチェック
        ActivityManager am = (ActivityManager)context.getSystemService(ACTIVITY_SERVICE);
        List<ActivityManager.RunningServiceInfo> listServiceInfo = am.getRunningServices(Integer.MAX_VALUE);
        for (ActivityManager.RunningServiceInfo curr : listServiceInfo) {
            // クラス名を比較
            if (curr.service.getClassName().equals(iBeaconService.class.getName())) {
                // 実行中のサービスと一致
//                Toast.makeText(context, "サービス実行中", Toast.LENGTH_LONG).show();
                Log.d(TAG, "---- service running");
                return true;
            }
        }
//        Toast.makeText(context, "サービス停止中", Toast.LENGTH_LONG).show();
        Log.d(TAG, "---- service stop");
        return false;
    }

}
