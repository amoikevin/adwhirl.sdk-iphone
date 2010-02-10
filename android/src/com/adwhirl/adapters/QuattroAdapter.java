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

import android.content.Context;
import android.util.Log;

import com.adwhirl.AdWhirlLayout;
import com.adwhirl.obj.Ration;
import com.adwhirl.util.AdWhirlUtil;
import com.qwapi.adclient.android.data.Ad;
import com.qwapi.adclient.android.data.Status;
import com.qwapi.adclient.android.requestparams.AdRequestParams;
import com.qwapi.adclient.android.requestparams.AnimationType;
import com.qwapi.adclient.android.requestparams.DisplayMode;
import com.qwapi.adclient.android.requestparams.MediaType;
import com.qwapi.adclient.android.requestparams.Placement;
import com.qwapi.adclient.android.view.AdEventsListener;
import com.qwapi.adclient.android.view.QWAdView;

public class QuattroAdapter extends AdWhirlAdapter implements AdEventsListener {
	private QWAdView quattroView;
	
	public QuattroAdapter(AdWhirlLayout adWhirlLayout, Ration ration) {
		super(adWhirlLayout, ration);
	}

	public void handle() {
		QWAdView quattro = new QWAdView(adWhirlLayout.context, ration.key,  ration.key2, MediaType.banner, Placement.top, DisplayMode.normal, 0, AnimationType.slide, this, true);
		//Make sure to store the view, as Quattro callbacks don't have references to it
		quattroView = quattro;
		// Quattro callbacks will queue rotate
	}
	
	// This block contains the Quattro listeners
	/*******************************************************************/
	@Override
	public void onAdClick(Context arg0, Ad arg1) {}

	@Override
	public void onAdRequest(Context arg0, AdRequestParams arg1) {}

	@Override
	public void onAdRequestFailed(Context arg0, AdRequestParams arg1, Status arg2) {
		Log.d(AdWhirlUtil.ADWHIRL, "Quattro failure");
		quattroView.setAdEventsListener(null, false);
		quattroView = null;
		adWhirlLayout.nextView = null;
		adWhirlLayout.rollover();
	}

	@Override
	public void onAdRequestSuccessful(Context arg0, AdRequestParams arg1, Ad arg2) {
 		Log.d(AdWhirlUtil.ADWHIRL, "Quattro success");
		quattroView.setAdEventsListener(null, false);
 		adWhirlLayout.adWhirlManager.resetRollover();
 		adWhirlLayout.nextView = quattroView;
 		adWhirlLayout.handler.post(adWhirlLayout.viewRunnable);
		adWhirlLayout.rotateThreadedDelayed();
	}

	@Override
	public void onDisplayAd(Context arg0, Ad arg1) {}
	/*******************************************************************/
	// End of Quattro listeners
}
