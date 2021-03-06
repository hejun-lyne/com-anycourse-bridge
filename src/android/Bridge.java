/*
       Licensed to the Apache Software Foundation (ASF) under one
       or more contributor license agreements.  See the NOTICE file
       distributed with this work for additional information
       regarding copyright ownership.  The ASF licenses this file
       to you under the Apache License, Version 2.0 (the
       "License"); you may not use this file except in compliance
       with the License.  You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing,
       software distributed under the License is distributed on an
       "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
       KIND, either express or implied.  See the License for the
       specific language governing permissions and limitations
       under the License.
*/
package com.anycourse.plugin;

import java.util.TimeZone;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaInterface;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.provider.Settings;

public class Bridge extends CordovaPlugin {
   public static final String TAG = "Bridge";

	CallbackContext callback;
	
	String country, phone;

	/**
	 * Constructor.
	 */
	public Sms() {
	}

	/**
	 * Sets the context of the Command. This can then be used to do things like
	 * get file paths associated with the Activity.
	 *
	 * @param cordova
	 *            The context of the main Activity.
	 * @param webView
	 *            The CordovaWebView Cordova is running in.
	 */
	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
		super.initialize(cordova, webView);
	}

	/**
	 * Executes the request and returns PluginResult.
	 *
	 * @param action
	 *            The action to execute.
	 * @param args
	 *            JSONArry of arguments for the plugin.
	 * @param callbackContext
	 *            The callback id used when calling back into JavaScript.
	 * @return True if the action was valid, false if not.
	 */
	public boolean execute(String action, JSONArray args,
			CallbackContext callbackContext) throws JSONException {
		JSONObject response = new JSONObject();
		if (action.equals("verifyOnce")) {
			if (args.length() < 2) {
				response.put("message", "请输入正确电话号码");
				callbackContext.error(response);
				return true;
			}
			country = args.getString(0);
			phone = args.getString(1);
			// 打开注册页面
			RegisterPage registerPage = new RegisterPage();
			registerPage.setRegisterCallback(new EventHandler() {
				public void afterEvent(int event, int result, Object data) {
					// 解析注册结果
					if (result == SMSSDK.RESULT_COMPLETE) {
						@SuppressWarnings("unchecked")
						HashMap<String,Object> phoneMap = (HashMap<String, Object>) data;
						String country = (String) phoneMap.get("country");
						String phone = (String) phoneMap.get("phone");
						// 验证成功
						JSONObject response;
						try {
							response = new JSONObject("{\"message\":\"验证成功\"}");
							callback.success(response);
						} catch (JSONException e) {
							e.printStackTrace();
						}
						
					} else {
						((Throwable) data).printStackTrace();
					}
				}
			});
			registerPage.show(super.cordova.getActivity());
//			SMSSDK.getVerificationCode(country, phone);
			callback = callbackContext;
		} else {
			return false;
		}
		return true;
	}

}
