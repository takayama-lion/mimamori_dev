package sdtk.topaz.ne.jp.ibeaconsample2.MimamoriIBeacon;

import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by hiroyuki on 2017/01/12.
 */

public class IBeaconInfoDataManager {
    /**
     * database file
     */
    private static final String DB_FILE = "IBeaconInfo.db";

    /**
     * version
     */
    private static final int DB_VERSION = 1;

    /**
     * table name
     */
    private static final String TableName = "ibeacon_info";

    /**
     * db helper
     */
    //private MySQLiteOpenHelper mDbHelper = null;

    /**
     * database
     */
    private SQLiteDatabase mDB = null;

    /**
     * context
     */
    private Context mContext = null;
    /**
     * constructor
     */
    public IBeaconInfoDataManager(Context context) {
        mContext = context;
        mDB = new MySQLiteOpenHelper(context).getWritableDatabase();
    }

    /**
     * begin transcation
     */
    public void begin() {
        mDB.beginTransaction();
    }

    /**
     * success transcation
     */
    public void success() {
        mDB.setTransactionSuccessful();
    }

    /**
     * end transcation
     */
    public void end() {
        if (mDB == null) {
            return;
        }
        try {
            mDB.endTransaction();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * db close
     */
    public void close() {
        if (mDB != null) {
            mDB.close();
        }
    }

    /**
     * insert to IBeaconInfo
     * @param infoData
     */
    public void add(IBeaconInfoData infoData) {
        add(mDB, infoData);
    }

    /**
     * insert to IBeaconInfo
     * @param db
     * @param infoData
     */
    private void add(SQLiteDatabase db, IBeaconInfoData infoData) {
        ContentValues values = new ContentValues();
        values.put("uuid",  infoData.UUID);
        values.put("major", infoData.Major);
        values.put("minor", infoData.Minor);
        values.put("latitude",  infoData.Latitude);
        values.put("longitude", infoData.Longitude);
        values.put("status", infoData.Status);
        values.put("_order",  infoData.Order);
        values.put("menuid", infoData.MenuId);
        db.insert(TableName, null, values);
    }

    /**
     * select infodata
     * @param order
     * @return
     */
    public List<IBeaconInfoData> getInfoWhereOrder(int order) {
        List<IBeaconInfoData>list = new ArrayList<>();
        Cursor cursor = mDB.query(TableName,
                new String[]{
                        "uuid","major","minor","latitude","longitude","status","_order","menuid"
                },
                "_order = ?",
                new String[]{Integer.toString(order)}, null, null, null);
        try {
            while (cursor.moveToNext()) {
                IBeaconInfoData infoData = new IBeaconInfoData();
                infoData.UUID  = cursor.getString(cursor.getColumnIndex("uuid"));
                infoData.Major = cursor.getString(cursor.getColumnIndex("major"));
                infoData.Minor = cursor.getString(cursor.getColumnIndex("minor"));
                infoData.Latitude  = cursor.getString(cursor.getColumnIndex("latitude"));
                infoData.Longitude = cursor.getString(cursor.getColumnIndex("longitude"));
                infoData.Status = cursor.getString(cursor.getColumnIndex("status"));
                infoData.Order  = cursor.getInt(cursor.getColumnIndex("_order"));
                infoData.MenuId = cursor.getString(cursor.getColumnIndex("menuid"));
                list.add(infoData);
            }
        } finally {
            try {
                cursor.close();
            } catch (Exception e){}
            return list;
        }
    }

    /**
     * select infodata
     * @param menuId
     * @return
     */
    public List<IBeaconInfoData> getInfoWhereMenuId(String menuId) {
        List<IBeaconInfoData>list = null;
        list = getInfoWhereMenuId(mDB, menuId);
        return list;
    }

    /**
     * select infodata
     * @param menuId
     * @return
     */
    public List<IBeaconInfoData> getInfoWhereMenuId(SQLiteDatabase db, String menuId) {
        List<IBeaconInfoData>list = new ArrayList<>();
        Cursor cursor = null;
        try {
            cursor = db.query(TableName,
                    new String[]{
                            "uuid","major","minor","latitude","longitude","status","_order","menuid"
                    },
                    "menuid = ?",
                    new String[]{menuId}, null, null, null);
            while (cursor.moveToNext()) {
                IBeaconInfoData infoData = new IBeaconInfoData();
                infoData.UUID  = cursor.getString(cursor.getColumnIndex("uuid"));
                infoData.Major = cursor.getString(cursor.getColumnIndex("major"));
                infoData.Minor = cursor.getString(cursor.getColumnIndex("minor"));
                infoData.Latitude  = cursor.getString(cursor.getColumnIndex("latitude"));
                infoData.Longitude = cursor.getString(cursor.getColumnIndex("longitude"));
                infoData.Status = cursor.getString(cursor.getColumnIndex("status"));
                infoData.Order  = cursor.getInt(cursor.getColumnIndex("_order"));
                infoData.MenuId = cursor.getString(cursor.getColumnIndex("menuid"));
                list.add(infoData);
            }
        } finally {
            if (cursor != null) {
                cursor.close();
            }
            return list;
        }
    }

    /**
     * update
     */
    public void update(IBeaconInfoData infoData) {
        ContentValues values = new ContentValues();
        values.put("latitude", infoData.Latitude);
        values.put("longitude", infoData.Longitude);
        values.put("status", infoData.Status);
        values.put("_order", infoData.Order);
        mDB.update(TableName, values, "uuid = ? AND major = ? AND minor = ?", new String[]{infoData.UUID, infoData.Major, infoData.Minor});
    }

    /**
     * update status
     */
    public void updateStatus(IBeaconInfoData infoData) {
        ContentValues values = new ContentValues();
        values.put("status", infoData.Status);
        values.put("_order", infoData.Order);

        mDB.update(TableName, values, "uuid = ? AND major = ? AND minor = ?", new String[]{infoData.UUID, infoData.Major, infoData.Minor});
    }

    /**
     * delete all
     */
    public void deleteAll(String status, int order) {
        String[] args = new String[]{
                status,
                String.valueOf(order)
        };
        deleteAll(mDB, args);
    }

    /**
     * delete data
     * @param menuId
     */
    public void deleteAllWithMenuId(String menuId) {
        try {
            mDB.delete(TableName, "menuid = ?", new String[]{menuId});
        } catch(Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * delete data
     * @param db
     * @param args
     */
    private void deleteAll(SQLiteDatabase db, String[] args) {
        db.delete(TableName, "status = ? AND _order = ?", args);
    }

    /**
     * create table sql
     */
    private static final String CREATE_TABLE = "CREATE TABLE IF NOT EXISTS " +
            TableName + " (" +
            "id INTEGER PRIMARY KEY" +
            ",uuid TEXT" +
            ",major TEXT" +
            ",minor TEXT" +
            ",latitude TEXT" +
            ",longitude TEXT" +
            ",status TEXT" +
            ",menuid TEXT" +
            ",_order INTEGER" +
            ")";

    /**
     * drop table sql
     */
    private static final String DROP_TABLE = "drop table " + TableName;


    /**
     * sqlite open helper
     */
    private static class MySQLiteOpenHelper extends SQLiteOpenHelper {
        public MySQLiteOpenHelper(Context c) {
            super(c, DB_FILE, null, DB_VERSION);
        }
        public void onCreate(SQLiteDatabase db) {
            db.execSQL(CREATE_TABLE);
        }
        public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
            db.execSQL(DROP_TABLE);
            onCreate(db);
        }
    }
}
