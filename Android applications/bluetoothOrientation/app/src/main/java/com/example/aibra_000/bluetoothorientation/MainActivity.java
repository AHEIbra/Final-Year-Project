package com.example.aibra_000.bluetoothorientation;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.net.Uri;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.google.android.gms.appindexing.Action;
import com.google.android.gms.appindexing.AppIndex;
import com.google.android.gms.common.api.GoogleApiClient;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

public class MainActivity extends AppCompatActivity {

    private static final int REQUEST_ENABLE_BT = 1;

    private SensorManager mSensorManager;
    private Sensor mOrientation;

    List list;

    private TextView sensorTextView;
    private Button startButton;
    private TextView text;
    private BluetoothAdapter myBluetoothAdapter;

    private int count = 0;
    private String off = "off";

    Timer timer = new Timer();
    int delay = 0;
    int period = 1000;

    String insertUrl = "http://192.168.1.66/scanBluetooth/insertBluetoothTestOrientation.php";
    RequestQueue requestQueue;

    float[] orientationValues = {0.0000f, 0.0000f, 0.0000f, 0.0000f};

    private ArrayAdapter<String> BTArrayAdapter;

    SensorEventListener mSensorListener = new SensorEventListener() {
        @Override
        public void onSensorChanged(SensorEvent sensorEvent) {
            orientationValues = sensorEvent.values;
            sensorTextView.setText("w: " + orientationValues[3] + "\nx: " + orientationValues[0] + "\ny: " + orientationValues[1] + "\nz: " + orientationValues[2]);
        }

        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) {

        }
    };



    /**
     * ATTENTION: This was auto-generated to implement the App Indexing API.
     * See https://g.co/AppIndexing/AndroidStudio for more information.
     */
    private GoogleApiClient client;






    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mSensorManager = (SensorManager) this.getSystemService(SENSOR_SERVICE);
        mOrientation = mSensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR);



        sensorTextView = (TextView) findViewById(R.id.sensorTextView);
        list = mSensorManager.getSensorList(Sensor.TYPE_ROTATION_VECTOR);

        if (list.size() > 0) {
            mSensorManager.registerListener(mSensorListener, (Sensor) list.get(0), mSensorManager.SENSOR_DELAY_NORMAL);
        } else {
            Toast.makeText(getBaseContext(), "Error: No Rotation Sensor", Toast.LENGTH_LONG).show();
        }



        requestQueue = Volley.newRequestQueue(getApplicationContext());
        myBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();


        myBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (myBluetoothAdapter == null) {
            text.setText("Status: not supported");
            Toast.makeText(getApplicationContext(), "Your device does not support Bluetooth",
                    Toast.LENGTH_LONG).show();
        }

        startButton = (Button) findViewById(R.id.startButton);
        startButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                start(view);
            }
        });



        Intent discoverableIntent =
                new Intent(BluetoothAdapter.ACTION_REQUEST_DISCOVERABLE);
        discoverableIntent.putExtra(BluetoothAdapter.EXTRA_DISCOVERABLE_DURATION, 0);
        startActivity(discoverableIntent);

        registerReceiver(newbReceiver, new IntentFilter(BluetoothDevice.ACTION_FOUND));
        registerReceiver(newbReceiver, new IntentFilter(BluetoothAdapter.ACTION_DISCOVERY_FINISHED));


        // ATTENTION: This was auto-generated to implement the App Indexing API.
        // See https://g.co/AppIndexing/AndroidStudio for more information.
        client = new GoogleApiClient.Builder(this).addApi(AppIndex.API).build();
    }



    final BroadcastReceiver newbReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();



            final EditText deviceNametext = (EditText) findViewById(R.id.deviceNameText);
            final EditText distancetext = (EditText) findViewById(R.id.distanceText);
            final EditText orientationtext = (EditText) findViewById(R.id.orientationText);


            final BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);

            if(device != null)
            {

                final int foundRSSI = intent.getShortExtra(BluetoothDevice.EXTRA_RSSI, Short.MIN_VALUE);

                final String deviceName = deviceNametext.getText().toString();

                final double distance = Double.parseDouble(distancetext.getText().toString());
                final double orientation = Double.parseDouble(orientationtext.getText().toString());

                if (BluetoothDevice.ACTION_FOUND.equals(action)) {
                    count++;

                    StringRequest request = new StringRequest(Request.Method.POST, insertUrl, new Response.Listener<String>() {
                        @Override
                        public void onResponse(String s) {

                        }
                    }, new Response.ErrorListener() {
                        @Override
                        public void onErrorResponse(VolleyError volleyError) {
                            Toast.makeText(MainActivity.this, "Error...", Toast.LENGTH_SHORT).show();
                            volleyError.printStackTrace();
                        }
                    }) {
                        @Override
                        protected Map<String, String> getParams() throws AuthFailureError {
                            Map<String, String> params = new HashMap<>();
                            params.put("Curr_Device", deviceName);
                            String found_device = device.getName();
                            if(found_device == null)
                            {
                                    found_device = "NULL";
                            }
                            params.put("Found_Device",  found_device);
                            params.put("RSSI", Integer.toString(foundRSSI));
                            params.put("Distance", Double.toString(distance));
                            params.put("Orientation", Double.toString(orientation));
                            params.put("wOrientation", Float.toString(orientationValues[3]));
                            params.put("xOrientation", Float.toString(orientationValues[0]));
                            params.put("yOrientation", Float.toString(orientationValues[1]));
                            params.put("zOrientation", Float.toString(orientationValues[2]));
                            params.put("Time", Long.toString(System.currentTimeMillis() / 1000L));
                            return params;

                        }

                    };

                    singletonVolley.getInstance(MainActivity.this).addToRequestQueue(request);
                }

                else if (myBluetoothAdapter.ACTION_DISCOVERY_FINISHED.equals(action))
                {
                    myBluetoothAdapter.startDiscovery();
                }
            }

        }
    };


    public void start(View view) {

        if (myBluetoothAdapter.isDiscovering()) {
            // the button is pressed when it discovers, so cancel the discovery
            myBluetoothAdapter.cancelDiscovery();
        } else {
            timer.scheduleAtFixedRate(new TimerTask()
            {
                public void run()
                {
                    //Call function
                    if(myBluetoothAdapter.isDiscovering()) {
                        myBluetoothAdapter.cancelDiscovery();
                        myBluetoothAdapter.startDiscovery();
                    }
                    else
                    {
                        myBluetoothAdapter.startDiscovery();
                    }
                }
            }, delay, period);

        }

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        unregisterReceiver(newbReceiver);
    }


    @Override
    protected void onStop() {
        if (list.size() > 0) {
           // mSensorManager.unregisterListener(mSensorListener);
        }
        super.onStop();
        // ATTENTION: This was auto-generated to implement the App Indexing API.
        // See https://g.co/AppIndexing/AndroidStudio for more information.
        Action viewAction = Action.newAction(
                Action.TYPE_VIEW, // TODO: choose an action type.
                "Main Page", // TODO: Define a title for the content shown.
                // TODO: If you have web page content that matches this app activity's content,
                // make sure this auto-generated web page URL is correct.
                // Otherwise, set the URL to null.
                Uri.parse("http://host/path"),
                // TODO: Make sure this auto-generated app URL is correct.
                Uri.parse("android-app://com.example.aibra_000.bluetoothorientation/http/host/path")
        );
        AppIndex.AppIndexApi.end(client, viewAction);
        // ATTENTION: This was auto-generated to implement the App Indexing API.
        // See https://g.co/AppIndexing/AndroidStudio for more information.
        client.disconnect();
    }


    @Override
    public void onStart() {
        super.onStart();

        // ATTENTION: This was auto-generated to implement the App Indexing API.
        // See https://g.co/AppIndexing/AndroidStudio for more information.
        client.connect();
        Action viewAction = Action.newAction(
                Action.TYPE_VIEW, // TODO: choose an action type.
                "Main Page", // TODO: Define a title for the content shown.
                // TODO: If you have web page content that matches this app activity's content,
                // make sure this auto-generated web page URL is correct.
                // Otherwise, set the URL to null.
                Uri.parse("http://host/path"),
                // TODO: Make sure this auto-generated app URL is correct.
                Uri.parse("android-app://com.example.aibra_000.bluetoothorientation/http/host/path")
        );
        AppIndex.AppIndexApi.start(client, viewAction);
    }
}

