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

package com.adwhirl;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Random;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Log;

import com.adwhirl.obj.Custom;
import com.adwhirl.obj.Extra;
import com.adwhirl.obj.Ration;
import com.adwhirl.util.AdWhirlUtil;

public class AdWhirlManager {
	private Extra extra;
	private List<Ration> rationsList;
	private int totalWeight = 0;
	private Context context;
	
	Iterator<Ration> rollovers;
	
	public AdWhirlManager(Context context) {
		Log.i(AdWhirlUtil.ADWHIRL, "Creating adWhirlManager...");
		this.context = context;
		init();
		Log.i(AdWhirlUtil.ADWHIRL, "Finished creating adWhirlManager");
	}
	
	// This fetches the configuration
	private void init() {
		while(extra == null) {
			if(isNetworkAvailable(this.context)) {
				fetchConfig();
			}
			else { 
				try {
					Log.d(AdWhirlUtil.ADWHIRL, "Sleeping for 30 seconds");
					Thread.sleep(30 * 1000);
				} catch (InterruptedException e) {
					Log.e(AdWhirlUtil.ADWHIRL, "Thread unable to sleep");
					e.printStackTrace();
				}
			}
		}
	}
	
	public Extra getExtra() {
		if(totalWeight <= 0) {
			Log.i(AdWhirlUtil.ADWHIRL, "Sum of ration weights is 0 - no ads to be shown");
			return null;
		}
		else {
			return this.extra;
		}
	}
	
	public Ration getRation() {		
		while(true) {
			if(isNetworkAvailable(this.context)) {
				return pickRation();
			}
			try {
				Thread.sleep(extra.cycleTime * 1000);
			} catch (InterruptedException e) {
				Log.e(AdWhirlUtil.ADWHIRL, "Thread unable to sleep");
				e.printStackTrace();
			}
		}
	}
	
	private Ration pickRation() {
		Random random = new Random();
		
		int r = random.nextInt(totalWeight) + 1;
		int s = 0;
		
		Iterator<Ration> it = this.rationsList.iterator();
		Ration ration = null;
		while(it.hasNext()) {
			ration = it.next();
			s += ration.weight;
			
			if(s >= r) {
				break;
			}
		}
		
		return ration;
	}
	
	public Ration getRollover() {
		if(this.rollovers == null) {
			return null;
		}
		
		Ration ration = null;
		if(this.rollovers.hasNext()) {
			ration = this.rollovers.next();
		}
		
		return ration;
	}
	
	public void resetRollover() {
		this.rollovers = this.rationsList.iterator();
	}
	
	public boolean isNetworkAvailable(Context context) {
		ConnectivityManager connectivity = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
		if (connectivity == null) {
			Log.d(AdWhirlUtil.ADWHIRL, "Network is unavailable");
			return false;
		} else {
			NetworkInfo[] info = connectivity.getAllNetworkInfo();
			if (info != null) {
				for (int i = 0; i < info.length; i++) {
					if (info[i].getState() == NetworkInfo.State.CONNECTED) {
						Log.d(AdWhirlUtil.ADWHIRL, "Network is available");
						return true;
					}
				}
			}
		}
		
		Log.d(AdWhirlUtil.ADWHIRL, "Network is unavailable");
		return false;
	}
	
	public Custom getCustom(String nid) {
        HttpClient httpClient = new DefaultHttpClient();
        
        String url = String.format(AdWhirlUtil.urlCustom, AdWhirlUtil.keyAdWhirl, nid, AdWhirlUtil.VERSION);
        HttpGet httpGet = new HttpGet(url); 
 
        HttpResponse httpResponse;
        try {
            httpResponse = httpClient.execute(httpGet);
     
            Log.d(AdWhirlUtil.ADWHIRL,httpResponse.getStatusLine().toString());
 
            HttpEntity entity = httpResponse.getEntity();
 
            if (entity != null) {
                InputStream inputStream = entity.getContent();
                String jsonString = convertStreamToString(inputStream);                
                return parseCustomJsonString(jsonString);
            }
        } catch (ClientProtocolException e) {
        	Log.e(AdWhirlUtil.ADWHIRL, "Caught ClientProtocolException in getCustom()");
        	e.printStackTrace();
        } catch (IOException e) {
        	Log.e(AdWhirlUtil.ADWHIRL, "Caught IOException in getCustom()");
        	e.printStackTrace();
        }
		
		return null;
	}
	
    public void fetchConfig()
    {
        HttpClient httpClient = new DefaultHttpClient();
        
        String url = String.format(AdWhirlUtil.urlConfig, AdWhirlUtil.keyAdWhirl, AdWhirlUtil.VERSION);
        HttpGet httpGet = new HttpGet(url); 
 
        HttpResponse httpResponse;
        try {
            httpResponse = httpClient.execute(httpGet);
     
            Log.d(AdWhirlUtil.ADWHIRL,httpResponse.getStatusLine().toString());
 
            HttpEntity entity = httpResponse.getEntity();
 
            if (entity != null) {
                InputStream inputStream = entity.getContent();
                String jsonString = convertStreamToString(inputStream);                
                parseConfigurationString(jsonString);
            }
        } catch (ClientProtocolException e) {
        	Log.e(AdWhirlUtil.ADWHIRL, "Caught ClientProtocolException in fetchConfig()");
        	e.printStackTrace();
        } catch (IOException e) {
        	Log.e(AdWhirlUtil.ADWHIRL, "Caught IOException in fetchConfig()");
        	e.printStackTrace();
        }
    }
    
	private String convertStreamToString(InputStream is) {
	    BufferedReader reader = new BufferedReader(new InputStreamReader(is), 8192);
	    StringBuilder sb = new StringBuilder();
	
	    String line = null;
	    try {
	        while ((line = reader.readLine()) != null) {
	            sb.append(line + "\n");
	        }
	    } 
	    catch (IOException e) {
        	Log.e(AdWhirlUtil.ADWHIRL, "Caught IOException in convertStreamToString()");
        	e.printStackTrace();
        	return null;
	    } 
	    finally {
	        try {
	            is.close();
	        } catch (IOException e) {
	        	Log.e(AdWhirlUtil.ADWHIRL, "Caught IOException in convertStreamToString()");
	        	e.printStackTrace();
	            return null;
	        }
	    }
	    
	    return sb.toString();
	}
	
    private void parseConfigurationString(String jsonString) {
    	Log.d(AdWhirlUtil.ADWHIRL, "Received jsonString: " + jsonString);
    	
    	try {    
	        JSONObject json = new JSONObject(jsonString);
	
	        parseExtraJson(json.getJSONObject("extra"));
	        parseRationsJson(json.getJSONArray("rations"));
    	}
    	catch (JSONException e) {
    		Log.e(AdWhirlUtil.ADWHIRL, "Unable to parse response from JSON. This may or may not be fatal.");
    		e.printStackTrace();
    		this.extra = new Extra();
    	}
    }
    
    private void parseExtraJson(JSONObject json) {
    	Extra extra = new Extra();
    	
    	try {    
	        extra.cycleTime = json.getInt("cycle_time");
	        extra.locationOn = json.getInt("location_on");
	        extra.transition = json.getInt("transition");

	        JSONObject backgroundColor = json.getJSONObject("background_color_rgb");
	        extra.bgRed = backgroundColor.getInt("red");
	        extra.bgGreen = backgroundColor.getInt("green");
	        extra.bgBlue = backgroundColor.getInt("blue");
	        extra.bgAlpha = backgroundColor.getInt("alpha");
	        
	        JSONObject textColor = json.getJSONObject("text_color_rgb");
	        extra.fgRed = textColor.getInt("red");
	        extra.fgGreen = textColor.getInt("green");
	        extra.fgBlue = textColor.getInt("blue");
	        extra.fgAlpha = textColor.getInt("alpha");
    	}
    	catch (JSONException e) {
    		Log.e(AdWhirlUtil.ADWHIRL, "Exception in parsing config.extra JSON. This may or may not be fatal.");
    		e.printStackTrace();
    	}
    	
    	this.extra = extra;
    }
    
    private void parseRationsJson(JSONArray json) {
    	List<Ration> rationsList = new ArrayList<Ration>();
    	
    	this.totalWeight = 0;
    	
    	try {
	    	int i;
	    	for(i=0; i<json.length(); i++) {
				JSONObject jsonRation = json.getJSONObject(i); 
				if(jsonRation == null) {
					continue;
				}
				
				Ration ration = new Ration();

			    ration.nid = jsonRation.getString("nid");
			    ration.type = jsonRation.getInt("type");
			    ration.name = jsonRation.getString("nname");
			    ration.weight = jsonRation.getInt("weight");
			    ration.priority = jsonRation.getInt("priority");
			    
			    switch(ration.type) {
			    case AdWhirlUtil.NETWORK_TYPE_ADMOB:
				    ration.key = jsonRation.getString("key");
			    	break;
			    	
			    case AdWhirlUtil.NETWORK_TYPE_QUATTRO:
			    	JSONObject keyObj = jsonRation.getJSONObject("key");
			    	ration.key = keyObj.getString("siteID");
			    	ration.key2 = keyObj.getString("publisherID");
			    	break;
			    	
			    case AdWhirlUtil.NETWORK_TYPE_CUSTOM:
			    	break;
			    	
			    case AdWhirlUtil.NETWORK_TYPE_GENERIC:
			    	break;
			    	
			    default:
			    	Log.w(AdWhirlUtil.ADWHIRL, "Don't know how to fetch key for unexpected ration type: " + ration.type);
			    	continue;
			    }
				
			    this.totalWeight += ration.weight;
			    
				rationsList.add(ration);
	    	}
    	}
    	catch (JSONException e) {
    		Log.e(AdWhirlUtil.ADWHIRL, "JSONException in parsing config.rations JSON. This may or may not be fatal.");
    		e.printStackTrace();
		}
    	
    	Collections.sort(rationsList);
    	
    	this.rationsList = rationsList;
    	this.rollovers = this.rationsList.iterator();
    }    
    
    private Custom parseCustomJsonString(String jsonString) {
    	Log.d(AdWhirlUtil.ADWHIRL, "Received custom jsonString: " + jsonString);

        Custom custom = new Custom();
    	try {    
	        JSONObject json = new JSONObject(jsonString);
	
	        custom.type = json.getInt("ad_type");
	        custom.imageLink = json.getString("img_url");
	        custom.link = json.getString("redirect_url");
	        custom.description = json.getString("ad_text");
	        
			custom.image = fetchImage(custom.imageLink);
    	}
    	catch (JSONException e) {
    		Log.e(AdWhirlUtil.ADWHIRL, "Caught JSONException in parseCustomJsonString()");
    		e.printStackTrace();
    		return null;
    	}
    	
    	return custom;
    }
    
	private Drawable fetchImage(String urlString) {
		try {
			URL url = new URL(urlString);
			InputStream is = (InputStream) url.getContent();
			Drawable d = Drawable.createFromStream(is, "src");
			return d;
		} catch (IOException e) {
			Log.e(AdWhirlUtil.ADWHIRL, "Caught UIException in fetchImage()");
			e.printStackTrace();
			return null;
		}
	}    
}
