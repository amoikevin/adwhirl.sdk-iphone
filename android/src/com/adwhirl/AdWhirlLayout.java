/*
 Copyright 2009-2010 AdMob, Inc.
 
    Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
  http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/

package com.adwhirl;

import java.io.IOException;

import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;

import com.adwhirl.adapters.*;
import com.adwhirl.obj.Custom;
import com.adwhirl.obj.Extra;
import com.adwhirl.obj.Ration;
import com.adwhirl.util.AdWhirlUtil;

import com.qwapi.adclient.android.view.QWAdView;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Handler;
import android.util.Log;
import android.view.*;
import android.widget.RelativeLayout;

public class AdWhirlLayout extends RelativeLayout {
	public final Activity activity;
	
	// Only the UI thread can update the UI, so we need these for callbacks
	public Handler handler;
	private Runnable adRunnable;
	public Runnable viewRunnable;
	
	public Extra extra;
	
	// The current custom ad
	public Custom custom;
	
	// This is just so our threads can reference us explicitly
	public RelativeLayout superView;
	
	public Ration activeRation;
	public Ration nextRation;
	
	public ViewGroup nextView;
	
	// The Quattro callbacks don't contain a reference to the view, so we keep it here
	public QWAdView quattroView;
	
	public AdWhirlInterface adWhirlInterface;  
	
	public AdWhirlManager adWhirlManager;
	
	private boolean hasWindow;
	private boolean isRotating;
	
	public AdWhirlLayout(final Activity context, final String keyAdWhirl) {
		super(context);
		this.activity = context;
		this.superView = this;
		
		this.hasWindow = true;
		this.isRotating = true;
		
		handler = new Handler();
		// Callback for external networks
		adRunnable = new Runnable() {
			public void run() {
				handleAd();
			}
		};
		// Callback for pushing views from ad callbacks
		viewRunnable = new Runnable() {
			public void run() {
				if(nextView == null) {
					return;
				}
				
				pushSubView(nextView);
			}
		};
		
		Thread thread = new Thread() {
		    @Override
			public void run() {
				adWhirlManager = new AdWhirlManager(context, keyAdWhirl);
				extra = adWhirlManager.getExtra();
				if(extra == null) {
					Log.e(AdWhirlUtil.ADWHIRL, "Unable to get configuration info or bad info, exiting AdWhirl");
					return;
				}
				
				rotateAd();
			}
		};
		thread.start();
		
		setHorizontalScrollBarEnabled(false);
		setVerticalScrollBarEnabled(false);
	}
	
	@Override
	protected void onWindowVisibilityChanged(int visibility)
	{
		 if(visibility == VISIBLE) {
			 this.hasWindow = true;
			 if(!this.isRotating) {
				 this.isRotating = true;
				 rotateThreadedNow();
			 }
		}
		 else {
			 this.hasWindow = false;
		 }
	}
	
	private void rotateAd() {
		if(!this.hasWindow) {
			this.isRotating = false;
			return;
		}
		
		Log.i(AdWhirlUtil.ADWHIRL, "Rotating Ad");
		nextRation = adWhirlManager.getRation();
		handler.post(adRunnable);
	}
	
	// Initialize the proper ad view from nextRation
	private void handleAd() {
		// We shouldn't ever get to a state where nextRation is null unless all networks fail
		if(nextRation == null) {
			Log.e(AdWhirlUtil.ADWHIRL, "nextRation is null!");
			rotateThreadedDelayed();
			return;
		}
		
		String rationInfo = String.format("Showing ad:\n\tnid: %s\n\tname: %s\n\ttype: %d\n\tkey: %s\n\tkey2: %s", nextRation.nid, nextRation.name, nextRation.type, nextRation.key, nextRation.key2);
		Log.d(AdWhirlUtil.ADWHIRL, rationInfo);

		try {
		  AdWhirlAdapter.handle(this, nextRation);
		}
		catch(Throwable t) {
		  Log.w(AdWhirlUtil.ADWHIRL, "Caught an exception in adapter:", t);
		    rolloverThreaded();
		    return;
		}
	}
	
	// Rotate immediately
	public void rotateThreadedNow() {
		Thread thread = new Thread() {
		    @Override
			public void run() {
				rotateAd();
			}
		};
		thread.start();
	}
	
	// Rotate in extra.cycleTime seconds
	public void rotateThreadedDelayed() {
		Thread thread = new Thread() {
		    @Override
			public void run() {
				try {
					Log.d(AdWhirlUtil.ADWHIRL, "Will call rotateAd() in " + extra.cycleTime + " seconds");
					Thread.sleep(extra.cycleTime * 1000);
				} catch (InterruptedException e) {
					Log.e(AdWhirlUtil.ADWHIRL, "Caught InterruptedException in rotateThreadedDelayed()", e);
				}
				rotateAd();
			}
		};
		thread.start();
	}
	
	// Remove old views and push the new one
	public void pushSubView(ViewGroup subView) {
		this.superView.removeAllViews();

		RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		layoutParams.addRule(RelativeLayout.CENTER_IN_PARENT);
		superView.addView(subView, layoutParams);
		
		Log.d(AdWhirlUtil.ADWHIRL, "Added subview");
		
		this.activeRation = nextRation;
		countImpressionThreaded();
	}
	
	public void rollover() {
		nextRation = adWhirlManager.getRollover();
		handler.post(adRunnable);
	}
	
	public void rolloverThreaded() {
		Thread thread = new Thread() {
		    @Override
			public void run() {
				nextRation = adWhirlManager.getRollover();
				handler.post(adRunnable);
			}
		};
		thread.start();
	}

	private void countImpressionThreaded() {
		Log.d(AdWhirlUtil.ADWHIRL, "Sending metrics request for impression");
		Thread thread = new Thread() {
		    @Override
			public void run() {
		        HttpClient httpClient = new DefaultHttpClient();
		        
		        String url = String.format(AdWhirlUtil.urlImpression, adWhirlManager.keyAdWhirl, activeRation.nid, activeRation.type, adWhirlManager.deviceIDHash, adWhirlManager.localeString, AdWhirlUtil.VERSION);
		        HttpGet httpGet = new HttpGet(url); 
		 
		        try {
		            httpClient.execute(httpGet);
		        } catch (ClientProtocolException e) {
		        	Log.e(AdWhirlUtil.ADWHIRL, "Caught ClientProtocolException in countImpressionThreaded()", e);
		        } catch (IOException e) {
		        	Log.e(AdWhirlUtil.ADWHIRL, "Caught IOException in countImpressionThreaded()", e);
		        }
			}
		};
		thread.start();
	}
	
	private void countClickThreaded() {
		Log.d(AdWhirlUtil.ADWHIRL, "Sending metrics request for click");
		Thread thread = new Thread() {
		    @Override
			public void run() {
		        HttpClient httpClient = new DefaultHttpClient();
		        
		        String url = String.format(AdWhirlUtil.urlClick, adWhirlManager.keyAdWhirl, activeRation.nid, activeRation.type, adWhirlManager.deviceIDHash, adWhirlManager.localeString, AdWhirlUtil.VERSION);
		        HttpGet httpGet = new HttpGet(url); 
		 
		        try {
		            httpClient.execute(httpGet);
		        } catch (ClientProtocolException e) {
		        	Log.e(AdWhirlUtil.ADWHIRL, "Caught ClientProtocolException in countClickThreaded()", e);
		        } catch (IOException e) {
		        	Log.e(AdWhirlUtil.ADWHIRL, "Caught IOException in countClickThreaded()", e);
		        }
			}
		};
		thread.start();
	}
	
	//We intercept clicks to provide raw metrics
	@Override
	public boolean onInterceptTouchEvent(MotionEvent event) {  
		switch(event.getAction()) {
		//Sending on an ACTION_DOWN isn't 100% correct... user could have touched down and dragged out. Unlikely though.
		case MotionEvent.ACTION_DOWN:
		    Log.d(AdWhirlUtil.ADWHIRL, "Intercepted ACTION_DOWN event");
		    if(activeRation != null) {
			countClickThreaded();
			
			if(activeRation.type == 9) {
				if(custom != null && custom.link != null) {
					Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(custom.link));
				    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				    try {
	    				this.activity.startActivity(intent);
				    } catch (Exception e) {
	        			Log.w(AdWhirlUtil.ADWHIRL, "Could not handle click to " + custom.link, e );
				    }
				}
				else {
					Log.w(AdWhirlUtil.ADWHIRL, "In onInterceptTouchEvent(), but custom or custom.link is null");
				}
			}
			break;
		    }
		}
	
		// Return false so subViews can process event normally.
		return false;
	}
	
	public interface AdWhirlInterface {
		public void adWhirlGeneric();
	}
	
	public void setAdWhirlInterface(AdWhirlInterface i) {
		this.adWhirlInterface = i;
	}
}
