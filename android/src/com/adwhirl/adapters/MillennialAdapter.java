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

package com.adwhirl.adapters;

import java.util.Hashtable;

import android.app.Activity;
import android.util.Log;

import com.adwhirl.AdWhirlLayout;
import com.adwhirl.obj.Extra;
import com.adwhirl.obj.Ration;
import com.adwhirl.util.AdWhirlUtil;
import com.millennialmedia.android.MMAdView;
import com.millennialmedia.android.MMAdView.MMAdListener;

public class MillennialAdapter extends AdWhirlAdapter implements MMAdListener {
	public MillennialAdapter(AdWhirlLayout adWhirlLayout, Ration ration) {
		super(adWhirlLayout, ration);
	}

	@Override
	public void handle() {
	      Hashtable<String, String> map = new Hashtable<String, String>();
	      
	       /*
	      // Optional targeting info
	      map.put("age", "45");
	      map.put("gender", "male");
	      map.put("zip", "21224");
	      map.put("marital", "single");
	      map.put("income", "50000");
	      map.put("keywords", "soccer");
	      // */
	      
	      // MM requests this pair to be specified
	      map.put("vendor", "adwhirl");
	      
	      // Instantiate an ad view and add it to the view
	      MMAdView adView = new MMAdView((Activity)adWhirlLayout.getContext(), ration.key, "MMBannerAdTop", -1, false, map);
	      adView.setListener(this);
	      adView.callForAd();
	      
	      Extra extra = this.adWhirlLayout.extra;
	      if(extra.locationOn == 1) {
	    	  adView.updateUserLocation(adWhirlLayout.adWhirlManager.location);
	      }
	      
	      adView.setHorizontalScrollBarEnabled(false);
	      adView.setVerticalScrollBarEnabled(false);
	}

	public void MMAdReturned(MMAdView adView) {
 		Log.d(AdWhirlUtil.ADWHIRL, "Millennial success");
 		adView.setListener(null);
 		adWhirlLayout.adWhirlManager.resetRollover();
 		adWhirlLayout.nextView = adView;
 		adWhirlLayout.handler.post(adWhirlLayout.viewRunnable);
		adWhirlLayout.rotateThreadedDelayed();
	}
	
	public void MMAdFailed(MMAdView adView) {
		Log.d(AdWhirlUtil.ADWHIRL, "Millennial failure");
		adView.setListener(null);
		adWhirlLayout.rollover();
	}		
	
	public void MMAdClickedToNewBrowser(MMAdView adview) {
		Log.d(AdWhirlUtil.ADWHIRL, "Millennial Ad clicked, new browser launched" );
	}
	
	public void MMAdClickedToOverlay(MMAdView adview) {
		Log.d(AdWhirlUtil.ADWHIRL, "Millennial Ad Clicked to overlay" );
	}
	
	public void MMAdOverlayLaunched(MMAdView adview) {
		Log.d(AdWhirlUtil.ADWHIRL, "Millennial Ad Overlay Launched" );
	}	
}
