/*
 Copyright 2009 AdMob, Inc.
 
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

import android.util.Log;

import com.admob.android.ads.AdManager;
import com.admob.android.ads.AdView;
import com.admob.android.ads.AdView.AdListener;
import com.adwhirl.AdWhirlLayout;
import com.adwhirl.obj.Ration;
import com.adwhirl.util.AdWhirlUtil;

public class AdMobAdapter extends AdWhirlAdapter implements AdListener {
	public AdMobAdapter(AdWhirlLayout adWhirlLayout, Ration ration) {
		super(adWhirlLayout, ration);
	}

	@Override
	public void handle() {
		AdManager.setPublisherId(ration.key);
		AdView adMob = new AdView(adWhirlLayout.context);
		adMob.setListener(this);
		adMob.setRequestInterval(0);
		// AdMob callbacks will queue rotate
	}

	// This block contains the AdMob listeners
	/*******************************************************************/
	@Override
	public void onFailedToReceiveAd(AdView adView) {
		Log.d(AdWhirlUtil.ADWHIRL, "AdMob failure");
		adView.setListener(null);
		adWhirlLayout.rollover();
	}

	@Override
	public void onNewAd(){/*@deprecated for onReceiveAd()*/} 
	
	@Override
	public void onReceiveAd(AdView adView) {
 		Log.d(AdWhirlUtil.ADWHIRL, "AdMob success");
 		adView.setListener(null);
 		adWhirlLayout.adWhirlManager.resetRollover();
 		adWhirlLayout.nextView = adView;
 		adWhirlLayout.handler.post(adWhirlLayout.viewRunnable);
		adWhirlLayout.rotateThreadedDelayed();
	}
	/*******************************************************************/
	// End of AdMob listeners
}
