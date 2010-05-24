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

import android.graphics.Color;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup.LayoutParams;

import com.admob.android.ads.AdListener;
import com.admob.android.ads.AdManager;
import com.admob.android.ads.AdView;
import com.adwhirl.AdWhirlLayout;
import com.adwhirl.obj.Extra;
import com.adwhirl.obj.Ration;
import com.adwhirl.util.AdWhirlUtil;

public class AdMobAdapter extends AdWhirlAdapter implements AdListener {
	public AdMobAdapter(AdWhirlLayout adWhirlLayout, Ration ration) {
		super(adWhirlLayout, ration);
	}

	@Override
	public void handle() {
		try {
			AdManager.setPublisherId(ration.key);	
		}
		// Thrown on invalid publisher id
		catch(IllegalArgumentException e) {
			adWhirlLayout.rollover();
			return;
		}
	
		AdView adMob = new AdView(this.adWhirlLayout.activity);
		adMob.setAdListener(this);

		Extra extra = adWhirlLayout.extra;
		int bgColor = Color.rgb(extra.bgRed, extra.bgGreen, extra.bgBlue);
		int fgColor = Color.rgb(extra.fgRed, extra.fgGreen, extra.fgBlue);
		adMob.setBackgroundColor(bgColor);
		adMob.setPrimaryTextColor(fgColor);
		
		// The AdMob view has to be in the view hierarchy to make a request - for newer versions of AdMob SDK!
		adMob.setVisibility(View.INVISIBLE);
		adWhirlLayout.addView(adMob, new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
		
		// AdMob callbacks will queue rotate
	}

	// This block contains the AdMob listeners
	/*******************************************************************/
	public void onReceiveAd(AdView adView) {
 		Log.d(AdWhirlUtil.ADWHIRL, "AdMob success");
 		adView.setAdListener(null);
 		
		// The AdMob view has to be in the view hierarchy to make a request - for newer versions of AdMob SDK!
 		adWhirlLayout.removeView(adView);
 		adView.setVisibility(View.VISIBLE);
 		adWhirlLayout.adWhirlManager.resetRollover();
 		adWhirlLayout.nextView = adView;
 		adWhirlLayout.handler.post(adWhirlLayout.viewRunnable);
		adWhirlLayout.rotateThreadedDelayed();
	}
	
	public void onFailedToReceiveAd(AdView adView) {
		Log.d(AdWhirlUtil.ADWHIRL, "AdMob failure");
		adView.setAdListener(null);
		
		// The AdMob view has to be in the view hierarchy to make a request - for newer versions of AdMob SDK!
		adWhirlLayout.removeView(adView);
		adWhirlLayout.rollover();
	}

	public void onFailedToReceiveRefreshedAd(AdView adView)	{
		// Don't call adView.refreshAd so this is never called.
	}

	public void onReceiveRefreshedAd(AdView adView) {
		// Don't call adView.refreshAd so this is never called.
	}
	
	/*******************************************************************/
	// End of AdMob listeners
}
