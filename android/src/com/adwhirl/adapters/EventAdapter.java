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

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import android.util.Log;

import com.adwhirl.AdWhirlLayout;
import com.adwhirl.AdWhirlLayout.AdWhirlInterface;
import com.adwhirl.obj.Ration;
import com.adwhirl.util.AdWhirlUtil;

public class EventAdapter extends AdWhirlAdapter {
	public EventAdapter(AdWhirlLayout adWhirlLayout, Ration ration) {
		super(adWhirlLayout, ration);
	}

	@Override
	public void handle() {
		Log.d(AdWhirlUtil.ADWHIRL, "Event notification request initiated");

		//If the user set a handler for notifications, call it
		if(this.adWhirlLayout.adWhirlInterface != null) {
			String method = this.adWhirlLayout.nextRation.key;

			Class<? extends AdWhirlInterface> listenerClass = this.adWhirlLayout.adWhirlInterface.getClass();
			Method listenerMethod;
			try {
				listenerMethod = listenerClass.getDeclaredMethod(method, (Class[])null);
				listenerMethod.invoke(listenerClass.newInstance(), (Object[])null);
			} catch (SecurityException e) {
				Log.e(AdWhirlUtil.ADWHIRL, "Caught SecurityException in handleEvent()");
				e.printStackTrace();
			} catch (NoSuchMethodException e) {
				Log.e(AdWhirlUtil.ADWHIRL, "Caught NoSuchMethodException in handleEvent()");
				e.printStackTrace();
			} catch (IllegalArgumentException e) {
				Log.e(AdWhirlUtil.ADWHIRL, "Caught IllegalArgumentException in handleEvent()");
				e.printStackTrace();
			} catch (IllegalAccessException e) {
				Log.e(AdWhirlUtil.ADWHIRL, "Caught IllegalAccessException in handleEvent()");
				e.printStackTrace();
			} catch (InvocationTargetException e) {
				Log.e(AdWhirlUtil.ADWHIRL, "Caught InvocationTargetException in handleEvent()");
				e.printStackTrace();
			} catch (InstantiationException e) {
				Log.e(AdWhirlUtil.ADWHIRL, "Caught InstantiationException in handleEvent()");
				e.printStackTrace();
			}
		}
		else {
			Log.w(AdWhirlUtil.ADWHIRL, "Event notification sent, but no interface is listening");
		}

		this.adWhirlLayout.adWhirlManager.resetRollover();
		this.adWhirlLayout.rotateThreadedDelayed();
	}
}
