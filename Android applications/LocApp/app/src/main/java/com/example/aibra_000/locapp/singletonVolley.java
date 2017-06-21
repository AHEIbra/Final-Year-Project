package com.example.aibra_000.locapp;

import android.content.Context;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.toolbox.Volley;

/**
 * Created by aibra_000 on 02/01/2017.
 */
public class singletonVolley {

    private static singletonVolley mInstance;
    private RequestQueue requestQueue;
    private static Context mCtx;

    private singletonVolley(Context context)
    {
        mCtx = context;
        requestQueue = getRequestQueue();
    }

    public RequestQueue getRequestQueue()
    {
        if(requestQueue == null)
        {
            requestQueue = Volley.newRequestQueue(mCtx.getApplicationContext());
        }

        return requestQueue;
    }

    public static synchronized singletonVolley getInstance(Context context)
    {
        if(mInstance == null)
        {
            mInstance = new singletonVolley(context);
        }

        return mInstance;
    }

    public<T> void addToRequestQueue(Request<T> request)
    {
        requestQueue.add(request);
    }
}
