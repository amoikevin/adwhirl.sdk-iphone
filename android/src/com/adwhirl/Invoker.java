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

import com.adwhirl.AdWhirlLayout.AdWhirlInterface;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

public class Invoker extends Activity implements AdWhirlInterface {
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        setContentView(R.layout.main);
        LinearLayout layout = (LinearLayout)findViewById(R.id.layout_main);
        
        if(layout == null) {
        	Log.e("AdWhirl", "Layout is null!");
        	return;
        }
        
        AdWhirlLayout adWhirlLayout = new AdWhirlLayout(this, "2f606d3e3723102d840c2e1e0de86337");
        adWhirlLayout.setAdWhirlInterface(this);
        RelativeLayout.LayoutParams adWhirlLayoutParams = new RelativeLayout.LayoutParams(320, 52);
        layout.addView(adWhirlLayout, adWhirlLayoutParams);
        layout.invalidate();
    }

	@Override
	public void adWhirlGeneric() {
		// TODO Auto-generated method stub
		
	}
	
	public void hello() {
		Log.d("HIII", "ASDFASDF");
	}
	
	public void hello2() {
		Log.d("HIII", "THIS IS A SECOND HELLO!");
	}
}
