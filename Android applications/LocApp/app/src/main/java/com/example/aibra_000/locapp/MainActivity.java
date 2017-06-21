package com.example.aibra_000.locapp;

import android.content.DialogInterface;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.view.View;
import android.widget.Toast;


import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.net.HttpURLConnection;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

public class MainActivity extends Activity {


    TextView mainText;
    Button AddList;
    Button refresh;
    WifiManager mainWifi;
    WifiReceiver receiverWifi;
    List<ScanResult> wifiList;
    StringBuilder sb = new StringBuilder();
    String insertUrl = "http://129.31.229.215/locApp/insertWifiValues.php";
    RequestQueue requestQueue;

    int size = 0;
    int i = 0;

    Timer timer = new Timer();

    int delay = 0; // delay for 0 sec.
    int period = 4000; // repeat every 4 sec.

    AlertDialog.Builder builder;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        //Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        //setSupportActionBar(toolbar);

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        });

        mainText = (TextView) findViewById(R.id.mainText);

        mainText.setMovementMethod(new ScrollingMovementMethod());

        AddList = (Button) findViewById(R.id.AddList);

        refresh = (Button) findViewById(R.id.refresh);

        requestQueue = Volley.newRequestQueue(getApplicationContext());


        // Initiate wifi service manager
        mainWifi = (WifiManager) getSystemService(Context.WIFI_SERVICE);

        // Check for wifi is disabled
        if (mainWifi.isWifiEnabled() == false)
        {
            Toast.makeText(getApplicationContext(), "wifi is disabled..making it enabled",
                    Toast.LENGTH_LONG).show();

            mainWifi.setWifiEnabled(true);
        }

        // wifi scanned value broadcast receiver
        receiverWifi = new WifiReceiver();

        // Register broadcast receiver
        // Broadcast receiver will automatically call when number of wifi connections changed
        registerReceiver(receiverWifi, new IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION));
        mainWifi.startScan();
        mainText.setText("Starting Scan...");



        refresh.setOnClickListener(new View.OnClickListener()
        {
            public void onClick(View v)
            {
                mainWifi.startScan();
                mainText.setText("Refreshing......");
            }
        });


        AddList.setOnClickListener(new View.OnClickListener()
        {

            @Override
            public void onClick(View view)
            {
                timer.scheduleAtFixedRate(new TimerTask()
                {
                    public void run()
                    {
                        wifiList.clear();
                        mainWifi.startScan();

                        wifiList = mainWifi.getScanResults();
                        size = wifiList.size() - 1;

                        i = 0;

                        final EditText locationText = (EditText) findViewById(R.id.locationText);
                        final EditText deviceNametext = (EditText) findViewById(R.id.deviceNameText);
                        final double location = Double.parseDouble(locationText.getText().toString());
                        final String deviceName = deviceNametext.getText().toString();


                        while (size >= 0){
                            final int currentSize = size;



                            StringRequest request = new StringRequest(Request.Method.POST, insertUrl, new Response.Listener<String>() {
                                @Override
                                public void onResponse(String s) {
                                    Log.i("VOLLEY", s);
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
                                    Map<String, String> params = new HashMap<String, String>();
                                    params.put("Curr_Device", deviceName);
                                    params.put("Location", Double.toString(location));
                                    params.put("wifiID", Integer.toString(currentSize));
                                    params.put("BSSID", wifiList.get(currentSize).BSSID);
                                    //params.put("name",wifiList.get(currentSize).SSID);
                                    params.put("RSSI", Integer.toString(wifiList.get(currentSize).level));
                                    //params.put("level",Integer.toString(wifiList.get(currentSize).level));
                                    params.put("Time", Long.toString(System.currentTimeMillis() / 1000L));
                                    return params;
                                }
                            };
                            singletonVolley.getInstance(MainActivity.this).addToRequestQueue(request);
                            size--;

                        }
                    }


                }, delay, period);}
                });

    }

    public boolean onCreateOptionsMenu(Menu menu) {
        menu.add(0, 0, 0, "Refresh");
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return super.onCreateOptionsMenu(menu);
    }

    public boolean onMenuItemSelected(int featureId, MenuItem item) {
        mainWifi.startScan();
        mainText.setText("Starting Scan");
        return super.onMenuItemSelected(featureId, item);
    }

    protected void onPause() {
        unregisterReceiver(receiverWifi);
        super.onPause();
    }

    protected void onResume() {
        registerReceiver(receiverWifi, new IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION));
        super.onResume();
    }


    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }



    class WifiReceiver extends BroadcastReceiver {

        // This method call when number of wifi connections changed
        public void onReceive(Context c, Intent intent) {

            sb = new StringBuilder();
            wifiList = mainWifi.getScanResults();
            sb.append("\n Number Of Wifi Connections : "+wifiList.size() + "\n");
            // sb.append(wifiList.size() + "\n");
            sb.append("\n");
            sb.append("Connection    |        SSID      |       RSSI    \n ");
            sb.append("----------------------------------------------------");
            sb.append("\n");

            JSONObject jsonObject = new JSONObject();

            for(i = 0; i < wifiList.size(); i++){
                //for(int i = 0; i < 3; i++){


                sb.append(new Integer(i+1).toString() + ".     ");
                //sb.append((wifiList.get(i)).toString());
                sb.append((wifiList.get(i)).BSSID);
                sb.append("    ");
                sb.append((wifiList.get(i).level));
                sb.append("\n\n");

                try {
                    jsonObject.put("BSSID", wifiList.get(i).BSSID);
                    jsonObject.put("level", wifiList.get(i).level);
                } catch (JSONException e)
                {
                    e.printStackTrace();
                }
            }


            mainText.setText(sb);
        }



    }
}
