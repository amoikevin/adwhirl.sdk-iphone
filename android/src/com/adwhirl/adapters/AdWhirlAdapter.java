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

import com.adwhirl.AdWhirlLayout;
import com.adwhirl.obj.Ration;
import com.adwhirl.util.AdWhirlUtil;

public abstract class AdWhirlAdapter {
	protected AdWhirlLayout adWhirlLayout;
	protected Ration ration;
	
	public AdWhirlAdapter(AdWhirlLayout adWhirlLayout, Ration ration) {
		this.adWhirlLayout = adWhirlLayout;
		this.ration = ration;
	}
	
	public static AdWhirlAdapter getAdapter(AdWhirlLayout adWhirlLayout, Ration ration) {	
		try {
			switch(ration.type) {
				case AdWhirlUtil.NETWORK_TYPE_ADMOB:
					if(Class.forName("com.admob.android.ads.AdView") != null) {
						return new AdMobAdapter(adWhirlLayout, ration);
					}
					else {
						return unknownAdNetwork(adWhirlLayout, ration);
					}
				
				case AdWhirlUtil.NETWORK_TYPE_QUATTRO:
					if(Class.forName("com.qwapi.adclient.android.view.QWAdView") != null) {
						return new QuattroAdapter(adWhirlLayout, ration);
					}
					else {
						return unknownAdNetwork(adWhirlLayout, ration);
					}
					
				default:
					return unknownAdNetwork(adWhirlLayout, ration);
			}
		}
		catch(ClassNotFoundException e) {
			return unknownAdNetwork(adWhirlLayout, ration);
		}
	}
	
	public static AdWhirlAdapter unknownAdNetwork(AdWhirlLayout adWhirlLayout, Ration ration) {
		Log.w(AdWhirlUtil.ADWHIRL, "Unsupported ration type: " + ration.type);
		adWhirlLayout.rotateThreadedNow();
		return null;
	}
	
	public abstract void handle();
}
