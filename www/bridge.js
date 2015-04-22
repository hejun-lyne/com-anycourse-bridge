/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */

var argscheck = require('cordova/argscheck'),
	channel = require('cordova/channel'),
	utils = require('cordova/utils'),
	exec = require('cordova/exec'),
	cordova = require('cordova');

channel.createSticky('onCordovaInfoReady');
// Tell cordova channel to wait on the CordovaInfoReady event
channel.waitForInitialization('onCordovaInfoReady');

/**
 * This represents the mobile device, and provides properties for inspecting the model, version, UUID of the
 * phone, etc.
 * @constructor
 */
function Bridge() {
	var me = this;
	channel.onCordovaReady.subscribe(function() {
		me.loadZones();
	});
}
Bridge.prototype.loadZones = function() {
	exec(null, null, "Bridge", "loadZones", []);
};

Bridge.prototype.sendSms = function(areaCode, phone, successCallback, errorCallback) {
	var params = [areaCode, phone];
	//    argscheck.checkArgs('fF', 'Sms.sendSms', params);
	exec(successCallback, errorCallback, "Bridge", "sendSms", params);
};
Bridge.prototype.verify = function(code, successCallback, errorCallback) {
	var params = [code];
	exec(successCallback, errorCallback, "Bridge", "verify", params);
};

Bridge.prototype.verifyOnce = function(areaCode, phone, successCallback, errorCallback) {
	var params = [areaCode, phone];
	exec(successCallback, errorCallback, "Bridge", "verifyOnce", params);
};

module.exports = new Bridge();