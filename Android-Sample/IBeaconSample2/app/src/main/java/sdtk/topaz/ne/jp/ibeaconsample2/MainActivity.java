package sdtk.topaz.ne.jp.ibeaconsample2;

import android.Manifest;
import android.app.ActivityManager;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.os.Build;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import java.util.List;

public class MainActivity extends AppCompatActivity {
    private static final String TAG = MainActivity.class.getCanonicalName();

    private static final int PERMISSION_REQUEST_COARSE_LOCATION = 1;

    private EditText mUUIDText;

    private EditText mMajorText;

    private TextView mStatusView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mStatusView = (TextView) findViewById(R.id.status);
        mUUIDText = (EditText) findViewById(R.id.uuid);
        mMajorText = (EditText) findViewById(R.id.major);

        ActivityCompat.requestPermissions(this,
                new String[]{ Manifest.permission.ACCESS_FINE_LOCATION },
                1);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (this.checkSelfPermission(android.Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                requestPermissions(new String[]{android.Manifest.permission.ACCESS_COARSE_LOCATION}, PERMISSION_REQUEST_COARSE_LOCATION);
            }
        }

        SharedPreferences prf = getSharedPreferences(iBeaconService.PARAM_ID, MODE_PRIVATE);
        String uuid = prf.getString(iBeaconService.PARAM_UUID, null);
        String major = prf.getString(iBeaconService.PARAM_MAJOR, null);
        if (uuid != null) {
            mUUIDText.setText(uuid);
        }
        if (major != null) {
            mMajorText.setText(major);
        }
        setText();
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    public void onStart(View view) {
        Log.d(TAG, "--onStart");

        if (isService()) {
            onStop(view);
        }
        Intent intent = new Intent(this, iBeaconService.class);
        intent.setAction(iBeaconService.PARAM_ID);

        String uuid = null;
        if (mUUIDText.getText() != null && mUUIDText.getText().toString().length() > 0) {
            uuid = mUUIDText.getText().toString();
        }
        String major = null;
        if (mMajorText.getText() != null && mMajorText.getText().toString().length() > 0) {
            major = mMajorText.getText().toString();
        }

        SharedPreferences prf = getSharedPreferences(iBeaconService.PARAM_ID, MODE_PRIVATE);
        SharedPreferences.Editor editor = prf.edit();
        if (uuid != null) {
            editor.putString(iBeaconService.PARAM_UUID, uuid);
            intent.putExtra(iBeaconService.PARAM_UUID, uuid);
        }
        if (major != null) {
            editor.putString(iBeaconService.PARAM_MAJOR, major);
            intent.putExtra(iBeaconService.PARAM_MAJOR, major);
        }
        editor.commit();

        startService(intent);
        setText();
    }

    public void onStop(View view) {
        Log.d(TAG, "--onStop");
        if (isService()) {
            stopService(new Intent(this, iBeaconService.class));
        }
        setText();
    }
    
    private boolean isService() {
        ActivityManager am = (ActivityManager)this.getSystemService(ACTIVITY_SERVICE);
        List<ActivityManager.RunningServiceInfo> listServiceInfo = am.getRunningServices(Integer.MAX_VALUE);
        boolean found = false;
        for (ActivityManager.RunningServiceInfo curr : listServiceInfo) {
            // クラス名を比較
            if (curr.service.getClassName().equals(iBeaconService.class.getName())) {
                return true;
            }
        }
        return false;
    }

    public void setText() {
        if (isService()) {
            mStatusView.setText("Beacon 起動中");
            mStatusView.setTextColor(Color.RED);
        } else {
            mStatusView.setText("Beacon 停止中");
            mStatusView.setTextColor(Color.BLACK);
        }

    }
}
